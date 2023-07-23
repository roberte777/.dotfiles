local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
--regular keybinds
-- Move to previous/next
map("n", "<C-,", ":BufferPrevious<CR>", opts)
map("n", "<C-.>", ":BufferNext<CR>", opts)
-- Re-order to previous/next
map("n", "<leader>bn", ":BufferMovePrevious<CR>", opts)
map("n", "<leader>bp", " :BufferMoveNext<CR>", opts)
-- Goto buffer in position...
map("n", "<C-1>", ":BufferGoto 1<CR>", opts)
map("n", "<C-2>", ":BufferGoto 2<CR>", opts)
map("n", "<C-3>", ":BufferGoto 3<CR>", opts)
map("n", "<C-4>", ":BufferGoto 4<CR>", opts)
map("n", "<C-5>", ":BufferGoto 5<CR>", opts)
map("n", "<C-6>", ":BufferGoto 6<CR>", opts)
map("n", "<C-7>", ":BufferGoto 7<CR>", opts)
map("n", "<C-8>", ":BufferGoto 8<CR>", opts)
map("n", "<C-9>", ":BufferGoto 9<CR>", opts)
map("n", "<C-0>", ":BufferLast<CR>", opts)
-- Pin/unpin buffer
map("n", "<leader>bp", ":BufferPin<CR>", opts)
-- Close buffer
map("n", "<C-x>", ":BufferClose<CR>", opts)
-- Wipeout buffer
--                 :BufferWipeout<CR>
-- Close commands
map("n", "<leader>bc", ":BufferCloseAllButCurrent<CR>", opts)
map("n", "<leader>bP", ":BufferCloseAllButPinned<CR>", opts)
--                 :BufferCloseAllButCurrentOrPinned<CR>
--                 :BufferCloseBuffersLeft<CR>
--                 :BufferCloseBuffersRight<CR>
-- Magic buffer-picking mode
map("n", "<leader>bi", ":BufferPick<CR>", opts)
-- Sort automatically by...
map("n", "<Space>bb", ":BufferOrderByBufferNumber<CR>", opts)
map("n", "<Space>bd", ":BufferOrderByDirectory<CR>", opts)
map("n", "<Space>bl", ":BufferOrderByLanguage<CR>", opts)
map("n", "<Space>bw", ":BufferOrderByWindowNumber<CR>", opts)

-- Other:
-- :BarbarEnable - enables barbar (enabled by default)
-- :BarbarDisable - very bad command, should never be used
-- Set barbar's options
