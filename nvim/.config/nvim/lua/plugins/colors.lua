return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = true,
        config = function()
            require("catppuccin").setup({
                -- mocha, macchiato, frappe, latte
                flavour = "macchiato",
                transparent_background = false,
                integrations = {
                    treesitter = true,
                    native_lsp = {
                        enabled = true,
                        styles = {
                            errors = "italic",
                            hints = "italic",
                            warnings = "italic",
                            information = "italic",
                        },
                    },
                    cmp = true,
                    lsp_trouble = true,
                    lsp_saga = false,
                    gitgutter = false,
                    gitsigns = true,
                    telescope = true,
                    nvimtree = true,
                    which_key = true,
                    indent_blankline = {
                        enabled = true,
                        colored_indent_levels = true,
                    },
                    dashboard = true,
                    neogit = false,
                    vim_sneak = false,
                    fern = false,
                    barbar = true,
                    bufferline = false,
                    markdown = true,
                },
            })
        end,
    },
    {
        "sainnhe/gruvbox-material",
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            -- load the colorscheme here
            vim.g.gruvbox_material_foreground = "original"
            vim.g.gruvbox_material_background = "hard"
            vim.g.gruvbox_material_transparent_background = false
            vim.cmd([[colorscheme gruvbox-material]])
        end,
    },
}
