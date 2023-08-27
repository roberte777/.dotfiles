return {
	"ThePrimeagen/harpoon",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		-- set keymaps
		local ui = require("harpoon.ui")
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>hg", ui.toggle_quick_menu)

		keymap.set(
			"n",
			"<leader>ha",
			"<cmd>lua require('harpoon.mark').add_file()<cr>",
			{ desc = "Mark file with harpoon" }
		)
		keymap.set("n", "<leader>hh", function()
			ui.nav_file(1)
		end)
		keymap.set("n", "<leader>hj", function()
			ui.nav_file(2)
		end)
		keymap.set("n", "<leader>hk", function()
			ui.nav_file(3)
		end)
		keymap.set("n", "<leader>hl", function()
			ui.nav_file(4)
		end)
		keymap.set("n", "<leader>h;", function()
			ui.nav_file(5)
		end)
		keymap.set(
			"n",
			"<leader>hn",
			"<cmd>lua require('harpoon.ui').nav_next()<cr>",
			{ desc = "Go to next harpoon mark" }
		)
		keymap.set(
			"n",
			"<leader>hp",
			"<cmd>lua require('harpoon.ui').nav_prev()<cr>",
			{ desc = "Go to previous harpoon mark" }
		)
	end,
}
