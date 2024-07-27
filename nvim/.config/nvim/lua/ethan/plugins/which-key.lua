return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
		config = function(_, opts) -- This is the function that runs, AFTER loading
			-- Document existing key chains
			require("which-key").add({
				{ "<leader>t", group = "Toggle" },
				{ "<leader>c", group = "Code Actions" },
				{ "<leader>x", group = "Trouble" },
				{ "<leader>h", group = "Harpoon" },
				{ "<leader>f", group = "Find" },
				{ "<leader>g", group = "Git" },
				{ "<leader>d", group = "Debug" },
			})
		end,
	},
}
