function ColorMyPencils()
    vim.g.everforest_background = "hard"
    vim.g.everforest_transparent_background = 1
    vim.g.everforest_ui_contrast = "high"
    -- vim.cmd("colorscheme everforest")
    vim.g.gruvbox_material_foreground = "original"
    vim.g.gruvbox_material_transparent_background = 1
    vim.cmd("colorscheme gruvbox-material")

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
end
ColorMyPencils()
