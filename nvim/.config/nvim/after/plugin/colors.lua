function ColorMyPencils()
    vim.g.gruvbox_material_foreground = "original"
    vim.g.gruvbox_material_transparent_background = 1
    -- vim.cmd("colorscheme gruvbox-material")

    local hl = function(thing, opts)
        vim.api.nvim_set_hl(0, thing, opts)
    end

    -- hl("SignColumn", {
    --     bg = "none",
    -- })

    -- hl("ColorColumn", {
    --     ctermbg = 0,
    --     bg = "#555555",
    -- })

    -- hl("CursorLineNR", {
    --     bg = "None"
    -- })

    -- hl("Normal", {
    --     bg = "none"
    -- })

    hl("LineNr", {
        fg = "#5eacd3"
    })
    require("catppuccin").setup {
        -- mocha, macchiato, frappe, latte
        flavour = "macchiato",
        integrations = {
            treesitter = true,
            native_lsp = {
                enabled = true,
                styles = {
                    errors = "italic",
                    hints = "italic",
                    warnings = "italic",
                    information = "italic"
                }
            },
            cmp = true,
            lsp_trouble = true,
            lsp_saga = false,
            gitgutter = false,
            gitsigns = true,
            telescope = true,
            nvimtree = {
                enabled = true,
                show_root = true
            },
            which_key = true,
            indent_blankline = {
                enabled = true,
                colored_indent_levels = true
            },
            dashboard = true,
            neogit = false,
            vim_sneak = false,
            fern = false,
            barbar = true,
            bufferline = false,
            markdown = true
        }
    }
    vim.cmd("colorscheme catppuccin")
end
ColorMyPencils()
