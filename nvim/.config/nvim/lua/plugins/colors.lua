return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			require("catppuccin").setup({
				-- mocha, macchiato, frappe, latte
				flavour = "macchiato",
				transparent_background = false,
			})
			-- vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		"sainnhe/gruvbox-material",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			-- load the colorscheme here
			-- vim.g.gruvbox_material_foreground = "original"
			-- vim.g.gruvbox_material_background = "hard"
			-- vim.g.gruvbox_material_transparent_background = false
			vim.cmd.colorscheme("gruvbox-material")
		end,
	},
	{
		"Mofiqul/dracula.nvim",
		lazy = false,
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			-- vim.cmd.colorscheme("dracula")
		end,
	},
}
