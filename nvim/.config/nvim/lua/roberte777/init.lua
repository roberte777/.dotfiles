local augroup = vim.api.nvim_create_augroup
local ethan = augroup("ethan", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

function R(name)
	require("plenary.reload").reload_module(name)
end

autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})
autocmd({ "BufWritePre" }, {
	group = ethan,
	pattern = "*",
	command = "%s/\\s\\+$//e",
})
require("roberte777.set")
require("roberte777.lsp")
require("roberte777._lualine")
require("roberte777._gitsigns")
require("roberte777._telescope")
require("roberte777._indentline")
require("roberte777.copilot")
require("roberte777._toggleterm")
require("roberte777._null-ls")
require("roberte777._keep-it-secret")
