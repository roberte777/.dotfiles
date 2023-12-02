return {
	"ThePrimeagen/harpoon",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	branch = "harpoon2",
	config = function()
		-- set keymaps
		local harpoon = require("harpoon")
		local wk = require("which-key")

		wk.register({
			h = {
				name = "Harpoon",
				g = {
					function()
						harpoon.ui:toggle_quick_menu(harpoon:list())
					end,
					"Open Harpoon menu",
				},

				a = {
					function()
						harpoon:list():append()
					end,
					"Add file to harpoon menu",
				},

				h = {
					function()
						harpoon:list():select(1)
					end,
					"Go to first marked file",
				},

				j = {
					function()
						harpoon:list():select(2)
					end,
					"Go to second marked file",
				},

				k = {
					function()
						harpoon:list():select(3)
					end,
					"Go to third marked file",
				},

				l = {
					function()
						harpoon:list():select(4)
					end,
					"Go to fourth marked file",
				},

				[";"] = {
					function()
						harpoon:list():select(5)
					end,
					"Go to fifth marked file",
				},
			},
		}, { prefix = "<leader>" })
	end,
}
