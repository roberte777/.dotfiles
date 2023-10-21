return {
	{
		"Mofiqul/dracula.nvim",
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			local transparent_bg = false
			require("dracula").setup({ transparent_bg = transparent_bg })
			-- load the colorscheme here
			vim.cmd([[colorscheme dracula]])
		end,
	},
	{
		"sainnhe/gruvbox-material",
		priority = 1000,
		config = function()
			-- vim.cmd([[colorscheme dracula]])
		end,
	},
}
