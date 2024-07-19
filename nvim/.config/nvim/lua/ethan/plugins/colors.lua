return {
	{
		"Mofiqul/dracula.nvim",
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			local transparent_bg = false
			require("dracula").setup({ transparent_bg = transparent_bg })
			-- load the colorscheme here
			-- vim.cmd([[colorscheme dracula]])
		end,
	},
	{
		"sainnhe/gruvbox-material",
		priority = 1000,
		config = function()
			-- vim.cmd([[colorscheme dracula]])
		end,
	},
	{
		-- use this one I think
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function()
			vim.o.background = "dark"

			require("gruvbox").setup({
				transparent_mode = true,
			})

			-- vim.cmd([[colorscheme gruvbox]])
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				transparent_background = true,
			})
			vim.cmd([[colorscheme catppuccin]])
		end,
	},
}
