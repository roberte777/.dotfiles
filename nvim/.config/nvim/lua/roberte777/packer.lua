vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
    -- Packer can manage itself
    use("wbthomason/packer.nvim")
    use {
        "folke/zen-mode.nvim",
        config = function()
            require("zen-mode").setup {}
        end
    }
    -- common deps
    use("nvim-lua/plenary.nvim")
    -- terminal
    use({
        "akinsho/toggleterm.nvim",
        tag = "*",
        config = function()
            require("toggleterm").setup()
        end,
    })
    -- lsp
    use ({
  'VonHeikemen/lsp-zero.nvim',
  branch = 'v1.x',
  requires = {
    -- LSP Support
    {'neovim/nvim-lspconfig'},             -- Required
    {'williamboman/mason.nvim'},           -- Optional
    {'williamboman/mason-lspconfig.nvim'}, -- Optional

    -- Autocompletion
    {'hrsh7th/nvim-cmp'},         -- Required
    {'hrsh7th/cmp-nvim-lsp'},     -- Required
    {'hrsh7th/cmp-buffer'},       -- Optional
    {'hrsh7th/cmp-path'},         -- Optional
    {'saadparwaiz1/cmp_luasnip'}, -- Optional
    {'hrsh7th/cmp-nvim-lua'},     -- Optional

    -- Snippets
    {'L3MON4D3/LuaSnip'},             -- Required
    {'rafamadriz/friendly-snippets'}, -- Optional
  }
})
    -- coc in case I ever want to use it
    -- use {'neoclide/coc.nvim', branch = 'release'}
    -- autocmp
    use("nvim-treesitter/nvim-treesitter", {
        run = ":TSUpdate",
    })
    -- colorthemes
    use({ "catppuccin/nvim", as = "catppuccin" })
    use({ "sainnhe/gruvbox-material" })
    use("jose-elias-alvarez/null-ls.nvim")
    -- file exploration
    use("kyazdani42/nvim-web-devicons")
    use("kyazdani42/nvim-tree.lua")
    use("romgrk/barbar.nvim")
    -- comment toggling
    use("tpope/vim-commentary")
    -- statusline
    use("nvim-lualine/lualine.nvim")
    -- git
    use("lewis6991/gitsigns.nvim")
    -- telescope
    use({
        "nvim-telescope/telescope-fzf-native.nvim",
        run = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
    })
    use("nvim-telescope/telescope.nvim")
    -- indent line
    use("lukas-reineke/indent-blankline.nvim")
    --copilot
    use("github/copilot.vim")
    use("roberte777/keep-it-secret.nvim")
    --local plugins
    -- use("~/coding/nvim-plugins/keep-it-secret.nvim")
end)
