return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			bigfile = { enabled = false },
			dashboard = { enabled = false },
			indent = { enabled = true },
			input = { enabled = true },
			quickfile = { enabled = true, exclude = { "latex" } },
			scope = { enabled = true },
			scroll = { enabled = false },
			zen = { enabled = true },
		},
		keys = {
			{
				"<leader>uz",
				function()
					Snacks.zen()
				end,
				desc = "Enable zen mode",
			},
		},
	},
}
