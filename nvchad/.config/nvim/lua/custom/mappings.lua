local M = {}
M.disabled = {
	n = {
		["<C-c>"] = "",
	},
}
M.abc = {
	i = {
		["<C-c>"] = { "<ESC>", "escape insert mode", opts = { nowait = true } },
		-- copiloat accept suggestion
		["<C-l>"] = { 'copilot#Accept("<CR>")', opts = { silent = true, expr = true } },
	},
}

return M
