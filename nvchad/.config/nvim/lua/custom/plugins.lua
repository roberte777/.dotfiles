local plugins = {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"jose-elias-alvarez/null-ls.nvim",
		},
		config = function() end,
	},
	{
		"mfussenegger/nvim-dap",
		config = function()
			require("custom.configs.dap")
		end,
	},
	{ "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" } },
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
		lazy = false,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "jose-elias-alvarez/null-ls.nvim" },
		config = function()
			require("plugins.configs.lspconfig")
			require("custom.configs.lspconfig")
		end,
		lazy = false,
	},
	{
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"jose-elias-alvarez/null-ls.nvim",
		},
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
