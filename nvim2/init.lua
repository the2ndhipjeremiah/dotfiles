
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
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'L3MON4D3/LuaSnip'

vim.call('plug#end')

require('keymaps')
require('options')
require('plugs')
