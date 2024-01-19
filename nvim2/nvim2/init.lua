
local Plug = vim.fn['plug#']
vim.call('plug#begin')

Plug 'tpope/vim-fugitive'
Plug 'mfussenegger/nvim-jdtls'
Plug 'nvim-lua/plenary.nvim'
Plug ('nvim-telescope/telescope.nvim', { tag = '0.1.x' })
Plug ('ThePrimeagen/harpoon', { branch = 'harpoon2' })
Plug ('nvim-treesitter/nvim-treesitter', {
    ['do'] = function()
    vim.cmd(':TSUpdate')
  end
    })

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

vim.call('plug#end')

require('keymaps')
require('options')
require('plugs')

