function CreateNoremap(type, opts)
	return function(lhs, rhs, bufnr)
		bufnr = bufnr or 0
		vim.api.nvim_buf_set_keymap(bufnr, type, lhs, rhs, opts)
	end
end
Nnoremap = CreateNoremap("n", { noremap = true })
Inoremap = CreateNoremap("i", { noremap = true })
require("roberte777.lsp")
require("roberte777.tree")
require("roberte777._barbar")
require("roberte777._lualine")
require("roberte777._gitsigns")
require("roberte777._telescope")
require("roberte777._indentline")
require("roberte777.copilot")
require("roberte777._toggleterm")
require("roberte777._null-ls")
