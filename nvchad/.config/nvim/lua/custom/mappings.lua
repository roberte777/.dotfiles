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
}

return M
