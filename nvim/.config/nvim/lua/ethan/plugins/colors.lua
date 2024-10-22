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
			-- vim.cmd([[colorscheme gruvbox-material]])
			vim.cmd([[let g:gruvbox_material_background = 'hard']])
		end,
	},
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function()
			require("gruvbox").setup({
				contrast = "hard",
				transparent_mode = true,
			})
			vim.cmd("colorscheme gruvbox")
		end,
	},
	{
		"wincent/base16-nvim",
		lazy = false, -- load at start
		priority = 1000, -- load first
		config = function()
			-- vim.cmd([[colorscheme base16-gruvbox-dark-hard]])
			vim.o.background = "dark"
			-- Make it clearly visible which argument we're at.
			local marked = vim.api.nvim_get_hl(0, { name = "PMenu" })
			vim.api.nvim_set_hl(
				0,
				"LspSignatureActiveParameter",
				{ fg = marked.fg, bg = marked.bg, ctermfg = marked.ctermfg, ctermbg = marked.ctermbg, bold = true }
			)
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
			-- vim.cmd([[colorscheme catppuccin]])
		end,
	},
}
