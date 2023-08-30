return {
	"ThePrimeagen/harpoon",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		-- set keymaps
		local ui = require("harpoon.ui")
		local wk = require("which-key")

		wk.register({
			h = {
				name = "Harpoon",
				g = {
					function()
						ui.toggle_quick_menu()
					end,
					"Open Harpoon menu",
				},

				a = { "<cmd>lua require('harpoon.mark').add_file()<cr>", "Add file to harpoon menu" },

				h = {
					function()
						ui.nav_file(1)
					end,
					"Go to first marked file",
				},

				j = {
					function()
						ui.nav_file(2)
					end,
					"Go to second marked file",
				},

				k = {
					function()
						ui.nav_file(3)
					end,
					"Go to third marked file",
				},

				l = {
					function()
						ui.nav_file(4)
					end,
					"Go to fourth marked file",
				},

				[";"] = {
					function()
						ui.nav_file(5)
					end,
					"Go to fifth marked file",
				},

				n = {
					"<cmd>lua require('harpoon.ui').nav_next()<cr>",
					"Next Harpoon mark",
				},

				p = {
					"<cmd>lua require('harpoon.ui').nav_prev()<cr>",
					"Previous Harpoon mark",
				},
			},
		}, { prefix = "<leader>" })
	end,
}
