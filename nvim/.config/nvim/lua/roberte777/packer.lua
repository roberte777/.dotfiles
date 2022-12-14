vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
    -- use {
    --     "folke/twilight.nvim",
    --     config = function()
    --         require("twilight").setup {
    --             -- your configuration comes here
    --             -- or leave it empty to use the default settings
    --             -- refer to the configuration section below
    --         }
    --     end
    -- }
    use {
        "folke/zen-mode.nvim",
        config = function()
            require("zen-mode").setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
                -- starts twilight by default when zen start
            }
        end
    }
    -- Packer can manage itself
    use("wbthomason/packer.nvim")
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
    use("neovim/nvim-lspconfig")
    use("hrsh7th/cmp-nvim-lsp")
    use("hrsh7th/cmp-buffer")
    use("hrsh7th/cmp-path")
    use("hrsh7th/cmp-cmdline")
    use({
        "williamboman/mason.nvim",
        tag = "*",
        config = function()
            require("mason").setup()
        end,
    })
    use({
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup()
        end,
    })
    -- coc in case I ever want to use it
    -- use {'neoclide/coc.nvim', branch = 'release'}
    -- autocmp
    use("hrsh7th/nvim-cmp")
    use("onsails/lspkind-nvim")
    use("L3MON4D3/LuaSnip")
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
