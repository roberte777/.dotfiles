return {
  { "Mofiqul/dracula.nvim" },
  {
    "sainnhe/gruvbox-material",
    config = function()
      -- vim.g.gruvbox_material_background = "hard"
      -- vim.g.gruvbox_material_foreground = "mix"
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "dracula",
    },
  },
}
