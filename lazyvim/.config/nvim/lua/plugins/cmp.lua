return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.mapping["<CR>"] = nil
      opts.mapping["<C-y>"] = require("cmp").mapping.confirm({ select = true })
    end,
  },
}
