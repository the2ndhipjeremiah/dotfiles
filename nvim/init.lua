
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


vim.keymap.set('n', '<leader>ds', function()
  local widgets = require('dap.ui.widgets')
  local sidebar = widgets.sidebar(widgets.scopes)
  sidebar.open()
  
  vim.defer_fn(function()
    local sidebar_buf = nil
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local name = vim.api.nvim_buf_get_name(buf)
      if name:match('dap%-scopes') or name:match('Scopes') then
        sidebar_buf = buf
        break
      end
    end
    
    if not sidebar_buf then return end
    
    vim.api.nvim_buf_set_option(sidebar_buf, 'modifiable', true)
    
    local lines = vim.api.nvim_buf_get_lines(sidebar_buf, 0, -1, false)
    
    local start_idx, end_idx
    for i, line in ipairs(lines) do
      if line == 'Locals' then
        start_idx = i
      elseif start_idx and line:match('^[A-Z]') then  -- next section (starts with capital, no indent)
        end_idx = i - 1
        break
      end
    end
    
    if start_idx then
      end_idx = end_idx or #lines
      local filtered = {}
      for i = start_idx, end_idx do
        table.insert(filtered, lines[i])
      end
      
      vim.api.nvim_buf_set_lines(sidebar_buf, 0, -1, false, filtered)
    end
    
    vim.api.nvim_buf_set_option(sidebar_buf, 'modifiable', false)
  end, 200)
end)
