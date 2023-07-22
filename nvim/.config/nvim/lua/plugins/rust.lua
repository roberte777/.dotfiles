return {
	{
		"simrat39/rust-tools.nvim",
		dependencies = { "neovim/nvim-lspconfig" },
		ft = "rust",
		config = function()
			require("roberte777.rust_tools")
		end,
	},
}
