-- return {
-- 	{
-- 		"VonHeikemen/lsp-zero.nvim",
-- 		branch = "v2.x",
-- 		config = function()
-- 			require("roberte777.lsp")
-- 		end,
-- 		dependencies = {
-- 			-- LSP Support
-- 			{ "neovim/nvim-lspconfig" }, -- Required
-- 			{
-- 				"williamboman/mason.nvim",
-- 				build = function()
-- 					pcall(vim.cmd, "MasonUpdate")
-- 				end,
-- 			}, -- Optional
-- 			{ "williamboman/mason-lspconfig.nvim" }, -- Optional

-- 			-- Autocompletion
-- 			{ "hrsh7th/nvim-cmp" }, -- Required
-- 			{ "hrsh7th/cmp-nvim-lsp" }, -- Required
-- 			{ "hrsh7th/cmp-buffer" }, -- Optional
-- 			{ "hrsh7th/cmp-path" }, -- Optional
-- 			{ "saadparwaiz1/cmp_luasnip" }, -- Optional
-- 			{ "hrsh7th/cmp-nvim-lua" }, -- Optional

-- 			-- Snippets
-- 			{ "L3MON4D3/LuaSnip" }, -- Required
-- 			{ "rafamadriz/friendly-snippets" }, -- Optional
-- 		},
-- 	},
-- }
return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("roberte777.lsp")
		end,
	},
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"saadparwaiz1/cmp_luasnip",
	"L3MON4D3/LuaSnip",
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
	},
	"williamboman/mason-lspconfig.nvim",
}
