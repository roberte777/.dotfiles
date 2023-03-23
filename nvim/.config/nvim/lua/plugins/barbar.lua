return {
	{
		"romgrk/barbar.nvim",
		config = function()
			local map = vim.api.nvim_set_keymap
			local opts = { noremap = true, silent = true }

			--regular keybinds
			-- Move to previous/next
			map("n", "<C-k>", ":BufferPrevious<CR>", opts)
			map("n", "<C-j>", ":BufferNext<CR>", opts)
			-- Re-order to previous/next
			map("n", "<C-<>", ":BufferMovePrevious<CR>", opts)
			map("n", "<C->>", " :BufferMoveNext<CR>", opts)
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
			--                 :BufferCloseAllButCurrent<CR>
			--                 :BufferCloseAllButPinned<CR>
			--                 :BufferCloseAllButCurrentOrPinned<CR>
			--                 :BufferCloseBuffersLeft<CR>
			--                 :BufferCloseBuffersRight<CR>
			-- Magic buffer-picking mode
			map("n", "<C-p>", ":BufferPick<CR>", opts)
			-- Sort automatically by...
			map("n", "<Space>bb", ":BufferOrderByBufferNumber<CR>", opts)
			map("n", "<Space>bd", ":BufferOrderByDirectory<CR>", opts)
			map("n", "<Space>bl", ":BufferOrderByLanguage<CR>", opts)
			map("n", "<Space>bw", ":BufferOrderByWindowNumber<CR>", opts)

			-- Other:
			-- :BarbarEnable - enables barbar (enabled by default)
			-- :BarbarDisable - very bad command, should never be used
			-- Set barbar's options

			require("bufferline").setup({
				-- Enable/disable animations
				animation = true,
				-- Enable/disable auto-hiding the tab bar when there is a single buffer
				auto_hide = false,
				-- Enable/disable current/total tabpages indicator (top right corner)
				tabpages = true,
				-- Enable/disable close button
				closable = true,
				-- Enables/disable clickable tabs
				--  - left-click: go to buffer
				--  - middle-click: delete buffer
				clickable = true,
				-- Excludes buffers from the tabline
				exclude_ft = { "javascript" },
				exclude_name = { "package.json" },
				-- Enable/disable icons
				-- if set to 'numbers', will show buffer index in the tabline
				-- if set to 'both', will show buffer index and icons in the tabline
				icons = true,
				-- If set, the icon color will follow its corresponding buffer
				-- highlight group. By default, the Buffer*Icon group is linked to the
				-- Buffer* group (see Highlighting below). Otherwise, it will take its
				-- default value as defined by devicons.
				icon_custom_colors = false,
				-- Configure icons on the bufferline.
				icon_separator_active = "▎",
				icon_separator_inactive = "▎",
				icon_close_tab = "X",
				icon_close_tab_modified = "●",
				icon_pinned = "車",
				-- If true, new buffers will be inserted at the start/end of the list.
				-- Default is to insert after current buffer.
				insert_at_end = false,
				insert_at_start = false,
				-- Sets the maximum padding width with which to surround each tab
				maximum_padding = 1,
				-- Sets the maximum buffer name length.
				maximum_length = 30,
				-- If set, the letters for each buffer in buffer-pick mode will be
				-- assigned based on their name. Otherwise or in case all letters are
				-- already assigned, the behavior is to assign letters in order of
				-- usability (see order below)
				semantic_letters = true,
				-- New buffer letters are assigned in this order. This order is
				-- optimal for the qwerty keyboard layout but might need adjustement
				-- for other layouts.
				letters = "asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP",
				-- Sets the name of unnamed buffers. By default format is "[Buffer X]"
				-- where X is the buffer number. But only a static string is accepted here.
				no_name_title = nil,
			})
		end,
	},
}
