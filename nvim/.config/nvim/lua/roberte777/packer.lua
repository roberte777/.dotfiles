vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
 -- Packer can manage itself
 use 'wbthomason/packer.nvim'
 -- common deps
 use 'nvim-lua/plenary.nvim'
 -- terminal
 use {"akinsho/toggleterm.nvim", tag = '*', config = function()
 require("toggleterm").setup()
 end
 }
-- lsp
 use 'neovim/nvim-lspconfig'
 use 'hrsh7th/cmp-nvim-lsp'
 use 'hrsh7th/cmp-buffer'
 use 'hrsh7th/cmp-path'
 use 'hrsh7th/cmp-cmdline'
 use {'williamboman/mason.nvim', tag = '*', config = function()
        require('mason').setup()
    end
 }
 use {'williamboman/mason-lspconfig.nvim', config = function()
        require('mason-lspconfig').setup()
    end
 }

 -- coc in case I ever want to use it
 -- use {'neoclide/coc.nvim', branch = 'release'}
 -- autocmp
 use 'hrsh7th/nvim-cmp'
 use 'onsails/lspkind-nvim'
 use 'L3MON4D3/LuaSnip'
 use("nvim-treesitter/nvim-treesitter", {
     run = ":TSUpdate"
 })
 -- colorthemes
 use { "catppuccin/nvim", as = "catppuccin" }
 use { 'sainnhe/gruvbox-material'}
 use 'sbdchd/neoformat'
 use 'jose-elias-alvarez/null-ls.nvim'
 -- file exploration
 use 'kyazdani42/nvim-web-devicons'
 use 'kyazdani42/nvim-tree.lua'
 use 'romgrk/barbar.nvim'
 -- comment toggling
 use 'tpope/vim-commentary'
 -- statusline
 use 'nvim-lualine/lualine.nvim'
 -- git
 use 'lewis6991/gitsigns.nvim'
 -- telescope
 use {'nvim-telescope/telescope-fzf-native.nvim', run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
 use 'nvim-telescope/telescope.nvim'
 -- indent line
 use 'lukas-reineke/indent-blankline.nvim'
 --copilot
 use 'github/copilot.vim'

end)
