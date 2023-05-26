local M = {}
M.disabled = {
	n = {
		["<C-c>"] = "",
	},
}
M.abc = {
	i = {
		["<C-c>"] = { "<ESC>", "escape insert mode", opts = { nowait = true } },
	},
	n = {
		["<leader>db"] = {
			function()
				require("dap").toggle_breakpoint()
			end,
			"DAP Toggle Breakpoint",
		},
		["<leader>dc"] = {
			function()
				require("dap").continue()
			end,
			"DAP Continue",
		},
		["<leader>di"] = {
			function()
				require("dap").step_into()
			end,
			"DAP Step Into",
		},
		["<leader>do"] = {
			function()
				require("dap").step_over()
			end,
			"DAP Step Over",
		},
	},
}

return M
