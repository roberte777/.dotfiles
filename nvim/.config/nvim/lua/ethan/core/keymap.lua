vim.g.mapleader = " "
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end)
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
-- increase/decrease horizontal split size
vim.keymap.set("n", "+", "<C-w>>")
vim.keymap.set("n", "-", "<C-w><")
-- increase/decrease vertical split size
vim.keymap.set("n", "=", "<C-w>+")
vim.keymap.set("n", "_", "<C-w>-")
