return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
		config = function() -- This is the function that runs, AFTER loading
			require("which-key").setup()

			-- Document existing key chains
			require("which-key").register({
				["<leader>g"] = { name = "[G]it", _ = "which_key_ignore" },
				["<leader>c"] = { name = "[C]ode Actions", _ = "which_key_ignore" },
				["<leader>h"] = { name = "[H]arpoon", _ = "which_key_ignore" },
				["<leader>f"] = { name = "[F]ind", _ = "which_key_ignore" },
				["<leader>u"] = { name = "Toggle", _ = "which_key_ignore" },
				["<leader>x"] = { name = "Trouble", _ = "which_key_ignore" },
			})
		end,
	},
}
