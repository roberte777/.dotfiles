require("ethan.core")
require("ethan.lazy")

local function wrap_lines_at_80_words()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false) -- Get all lines in the buffer
	local wrapped_lines = {}

	for _, line in ipairs(lines) do
		while #line > 80 do
			local break_point = line:sub(1, 80):match(".*%s") -- Find last space before 80 chars
			if not break_point then
				break_point = #line -- If no space found, use the whole line
			else
				break_point = #break_point -- Length of the string up to the last space
			end
			table.insert(wrapped_lines, line:sub(1, break_point):gsub("%s+$", "")) -- Trim trailing space
			line = line:sub(break_point + 1):gsub("^%s+", "") -- Trim leading spaces in the remaining part
		end
		table.insert(wrapped_lines, line) -- Add the remaining line
	end

	vim.api.nvim_buf_set_lines(0, 0, -1, false, wrapped_lines) -- Replace buffer content with wrapped lines
end

-- Add a command to call the function
vim.api.nvim_create_user_command("WrapAt80Words", wrap_lines_at_80_words, {})
vim.api.nvim_set_keymap("n", "<leader>w", ":WrapAt80Words<CR>", { noremap = true, silent = true })
