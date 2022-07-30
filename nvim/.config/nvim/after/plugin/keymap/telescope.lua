local Remap = require("roberte777.keymap")
local nnoremap = Remap.nnoremap

-- currently, my mappings with telescope are in lsp and here. v is the start
-- when I want to view something, f for finding. I plan to use g for git. Ex.
-- vws = view workspace symbols. ff = find files.

nnoremap("<leader>ff", "<cmd> lua require('roberte777._telescope').project_files()<CR>")
nnoremap("<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>")
nnoremap("<leader>fs",function()
    require('telescope.builtin').grep_string()
end)
nnoremap("<leader>fb","<cmd>lua require('telescope.builtin').buffers()<cr>")
nnoremap("<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>")
nnoremap("<C-h>",function()
    require("telescope.builtin").keymaps()
end)
nnoremap("<leader>gs",function()
    require("telescope.builtin").git_status()
end)
