
--------------------------------------- CONFIG
-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs & indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Searching
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- UI
vim.opt.cursorline = true
vim.opt.wrap = true
vim.opt.scrolloff = 4

-- Misc
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true

--------------------------------------- PLUGS
vim.cmd([[
  call plug#begin()
  Plug 'mfussenegger/nvim-dap'
  call plug#end()
]])
--------------------------------------- LSP
-- Configure clangd
vim.lsp.config('clangd', {
  cmd = {'clangd', '--background-index', '--clang-tidy'},
  root_markers = {'.git', 'compile_commands.json'},
  filetypes = {'c'},
})

vim.diagnostic.config({
  signs = false,
})

-- Enable for C files
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'c'},
  callback = function()
    vim.lsp.enable('clangd')
  end,
})

-- Keybinds when LSP attaches
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = {buffer = args.buf}
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
  end,
})
--------------------------------------- DEBUG

local dap = require("dap")
dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
}

dap.configurations.c = {
  {
    name = "Launch",
    type = "gdb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
  },
}

local widgets = require('dap.ui.widgets')
--------------------------------------- KEYMAPS
local default_opts = {silent = true, noremap = true}
vim.g.mapleader = " "
vim.g.maplocalleader = " "

function space_norm_map(lhs, rhs, opts)
    vim.keymap.set("n", "<leader>"..lhs, rhs, vim.tbl_extend("force", default_opts, opts or {}))
end

-- General
space_norm_map("e", ":Explore<CR>")
-- Buffer Nav
space_norm_map("<leader>", ":b#<CR>")  -- Space + Space → previous buffer (alternate)
space_norm_map("n", ":bn<CR>")         -- Space + n → next buffer
space_norm_map("p", ":bp<CR>")         -- Space + p → previous buffer

-- run build.sh for current open file and open res in quickfix
vim.keymap.set('n', '<leader>b', function()
    local file = vim.fn.expand('%:p')
    vim.opt.makeprg = './build.sh ' .. vim.fn.shellescape(file)
    vim.cmd('make!')
    vim.cmd('copen')
end)

-- convenience
vim.keymap.set('i', '<C-s>', 'SDL_')
-- Debug
vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F6>', function() require('dap').terminate() end)

vim.keymap.set('n', '<Left>', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<Right>', function() require('dap').step_over() end)
vim.keymap.set('n', '<Down>', function() require('dap').step_into() end)
vim.keymap.set('n', '<Up>', function() require('dap').step_out() end)

vim.keymap.set('n', '<F12>', function() require('dap').repl.toggle() end)

--vim.keymap.set('n', '<leader>ds', function()
--  local widgets = require('dap.ui.widgets')
--  widgets.sidebar(widgets.scopes).open()
--end)

vim.keymap.set('n', '<leader>df', function()
  local widgets = require('dap.ui.widgets')
  widgets.sidebar(widgets.frames).open()
end)

local filter_enabled = false
local hidden_lines = {}
local ns_id = vim.api.nvim_create_namespace('dap_scopes_highlight')

local function highlight_scopes(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
  
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  
  for i, line in ipairs(lines) do
    -- Highlight variable names (before colon)
    local var_name = line:match('^%s+([%w_#]+):')
    if var_name then
      local col_start = line:find(var_name, 1, true) - 1
      vim.api.nvim_buf_add_highlight(bufnr, ns_id, 'Identifier', i - 1, col_start, col_start + #var_name)
    end
    
    -- Highlight section headers
    if line:match('^[A-Z]') then
      vim.api.nvim_buf_add_highlight(bufnr, ns_id, 'Title', i - 1, 0, -1)
    end
    
    -- Highlight values (after colon)
    local colon_pos = line:find(':')
    if colon_pos then
      vim.api.nvim_buf_add_highlight(bufnr, ns_id, 'String', i - 1, colon_pos, -1)
    end
  end
end

local function toggle_filter_scopes()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match('dap%-scopes') then
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      
      vim.api.nvim_buf_set_option(buf, 'modifiable', true)
      
      if filter_enabled then
        local args_start, args_end
        local locals_start, locals_end
        
        for i, line in ipairs(lines) do
          if line == 'Arguments' then
            args_start = i
          elseif line == 'Locals' then
            if args_start and not args_end then
              args_end = i - 1
            end
            locals_start = i
          elseif line:match('^[A-Z]') then
            if locals_start and not locals_end then
              locals_end = i - 1
              break
            elseif args_start and not args_end then
              args_end = i - 1
            end
          end
        end
        
        -- Build filtered content with both sections
        local filtered = {}
        if args_start then
          args_end = args_end or (locals_start and locals_start - 1) or #lines
          for i = args_start, args_end do
            table.insert(filtered, lines[i])
          end
        end
        
        if locals_start then
          locals_end = locals_end or #lines
          for i = locals_start, locals_end do
            table.insert(filtered, lines[i])
          end
        end
        
        if #filtered > 0 then
          hidden_lines[buf] = lines
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, filtered)
        end
      else
        if hidden_lines[buf] then
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, hidden_lines[buf])
        end
      end
      
      vim.api.nvim_buf_set_option(buf, 'modifiable', false)
      highlight_scopes(buf)
    end
  end
end

vim.keymap.set('n', '<leader>dt', function()
  filter_enabled = not filter_enabled
  print("Locals filter:", filter_enabled and "ON" or "OFF")
  toggle_filter_scopes()
end)

vim.keymap.set('n', '<leader>ds', function()
  require('dap.ui.widgets').sidebar(require('dap.ui.widgets').scopes).open()
end)

local dap = require('dap')
dap.listeners.after.event_stopped['filter_locals'] = function()
  vim.defer_fn(toggle_filter_scopes, 40)  -- , ms
end
