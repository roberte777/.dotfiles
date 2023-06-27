return {
	-- Packer can manage itself
	{
		"folke/zen-mode.nvim",
		lazy = true,
		config = function()
			require("zen-mode").setup({})
		end,
	},
	-- common deps
	"nvim-lua/plenary.nvim",
	-- terminal
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = 20,
				open_mapping = [[<C-t>]],
				hide_numbers = true,
				close_on_exit = true,
			})
			require("roberte777._toggleterm")
		end,
	},
	-- coc in case I ever want to use it
	-- use {'neoclide/coc.nvim', branch = 'release'}
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				-- A list of parser names, or "all"
				ensure_installed = {
					"python",
					"lua",
					"javascript",
					"typescript",
					"tsx",
					"rust",
					"go",
					"c",
					"cpp",
					"java",
					"html",
					"css",
					"bash",
					"json",
					"yaml",
					"toml",
					"regex",
					"comment",
				},
				-- Install parsers synchronously (only applied to `ensure_installed`)
				sync_install = false,
				highlight = {
					-- `false` will disable the whole extension
					enable = true,
				},
			})
		end,
	},
	{
		"nvim-tree/nvim-web-devicons",
	},
	-- comment toggling
	{ "tpope/vim-commentary" },
	-- git
	{ "lewis6991/gitsigns.nvim", config = true },
	-- indent line
	{ "lukas-reineke/indent-blankline.nvim", config = true },
	{
		"nvim-lualine/lualine.nvim",
		config = true,
	},
	{
		"roberte777/keep-it-secret.nvim",
		config = function()
			require("keep-it-secret").setup({
				wildcards = { ".*(.env)$", ".*(.secret)$" },
				enabled = false,
			})
		end,
	},
	--local plugins
	-- use("~/coding/nvim-plugins/keep-it-secret.nvim")
}
