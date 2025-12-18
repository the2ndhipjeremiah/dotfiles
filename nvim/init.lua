
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


--------------------------------------- LSP
-- Configure clangd
vim.lsp.config('clangd', {
  cmd = {'clangd', '--background-index', '--clang-tidy'},
  root_markers = {'.git', 'compile_commands.json'},
  filetypes = {'c'},
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
