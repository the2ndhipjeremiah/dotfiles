vim.g.mapleader = " "

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)




-- Helper function for creating keymaps
function nnoremap(rhs, lhs, bufopts, desc)
  bufopts.desc = desc
  vim.keymap.set("n", rhs, lhs, bufopts)
end

-- The on_attach function is used to set key maps after the language server
-- attaches to the current buffer
-- Regular Neovim LSP client keymappings
local bufopts = { noremap=true, silent=true, buffer=bufnr }
nnoremap('gD', vim.lsp.buf.declaration, bufopts, "Go to declaration")
nnoremap('gd', vim.lsp.buf.definition, bufopts, "Go to definition")
nnoremap('gi', vim.lsp.buf.implementation, bufopts, "Go to implementation")
nnoremap('K', vim.lsp.buf.hover, bufopts, "Hover text")
nnoremap('<C-k>', vim.lsp.buf.signature_help, bufopts, "Show signature")
nnoremap('<space>wa', vim.lsp.buf.add_workspace_folder, bufopts, "Add workspace folder")
nnoremap('<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts, "Remove workspace folder")

nnoremap('<space>wl', function()
print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, bufopts, "List workspace folders")

nnoremap('<space>D', vim.lsp.buf.type_definition, bufopts, "Go to type definition")
nnoremap('<space>rn', vim.lsp.buf.rename, bufopts, "Rename")
nnoremap('<space>ca', vim.lsp.buf.code_action, bufopts, "Code actions")
vim.keymap.set('v', "<space>ca", "<ESC><CMD>lua vim.lsp.buf.range_code_action()<CR>",
{ noremap=true, silent=true, buffer=bufnr, desc = "Code actions" })
nnoremap('<space>f', function() vim.lsp.buf.format { async = true } end, bufopts, "Format file")

local jdtls = require('jdtls')
-- Java extensions provided by jdtls
-- nnoremap("<C-o>", jdtls.organize_imports, bufopts, "Organize imports")
nnoremap("<space>ev", jdtls.extract_variable, bufopts, "Extract variable")
nnoremap("<space>ec", jdtls.extract_constant, bufopts, "Extract constant")
vim.keymap.set('v', "<space>em", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
{ noremap=true, silent=true, buffer=bufnr, desc = "Extract method" })
