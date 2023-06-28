local plugins = {
	{
		-- LSP Configuration & Plugins
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs to stdpath for neovim
			{ "williamboman/mason.nvim", config = true, build = ":MasonUpdate" },
			{ "williamboman/mason-lspconfig.nvim", config = true },
		},
		config = function()
			require("plugins.configs.lspconfig")
			require("custom.configs.lspconfig")
		end,
	},
	{
		"mfussenegger/nvim-dap",
		config = function()
			require("custom.configs.dap")
		end,
	},
	{ "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" } },
	{
		"jose-elias-alvarez/null-ls.nvim",
		config = function()
			require("custom.configs.null-ls")
		end,
		event = { "BufReadPost", "BufNewFile" },
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
	{
		"simrat39/rust-tools.nvim",
		dependencies = { "neovim/nvim-lspconfig" },
		ft = "rust",
		config = function()
			require("custom.configs.rust-tools")
		end,
	},
}
return plugins
