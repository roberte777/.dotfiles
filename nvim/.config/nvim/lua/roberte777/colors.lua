require("gruvbox").setup({
  undercurl = true,
  underline = true,
  bold = true,
  italic = true,
  strikethrough = true,
  invert_selection = true,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = true, -- invert background for search, diffs, statuslines and errors
  contrast = "hard", -- can be "hard", "soft" or empty string
  overrides = {
      Normal = {
        --total bg of all of neovim
        bg="",
      },
      LineNr = {
          -- line numbers color
          fg = "#aed75f",
      },
      SignColumn = {
          -- column on far left hand side, to the left of line
          -- numbers
          bg = "",
      },
      TelescopeBorder = {
          -- telescope border around the title
          -- of the picker
            bg = "#5eacd3",

      },
      ColorColumn = {
          -- this is the column that tells
          -- me when my line is too long
            ctermbg = 0,
            bg = "grey",
      },
      CursorLineNR = {
          -- this is the line number
          -- of the cursor
          bg = "",
      },
  },
})
vim.o.background = "dark"
vim.cmd("colorscheme gruvbox")
