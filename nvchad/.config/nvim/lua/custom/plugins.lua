local plugins = {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"jose-elias-alvarez/null-ls.nvim",
		},
		config = function()
			require("plugins.configs.lspconfig")
			require("custom.configs.lspconfig")
		end,
	},
	{
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"lua-language-server",
				"html-lsp",
				"prettier",
				"stylua",
				"pyright",
				"typescript-language-server",
				"rust-analyzer",
				"stylua",
			},
		},
	},
	{
		"jose-elias-alvarez/null-ls.nvim",
		config = function()
			require("custom.configs.null-ls")
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		config = function()
			require("plugins.configs.cmp")
			require("custom.configs.cmp")
		end,
	},
	{
		"github/copilot.vim",
		lazy = false,
	},
}
return plugins
