
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
