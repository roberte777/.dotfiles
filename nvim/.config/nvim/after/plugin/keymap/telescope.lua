local Remap = require("roberte777.keymap")
local nnoremap = Remap.nnoremap

-- currently, my mappings with telescope are in lsp and here. v is the start
-- when I want to view something, f for finding. I plan to use g for git. Ex.
-- vws = view workspace symbols. ff = find files.

--going to try normal find files for a while, move back to this if it goes
--poorly
-- nnoremap("<leader>ff", "<cmd> lua require('roberte777._telescope').project_files()<CR>",
--     { desc = "Find files in project. Tries git files, then based on lsp if " ..
--         " not git project,then just regular telescope find files then just" ..
--         " regular telescope find files" })

nnoremap("<leader>ff", function()
    require("telescope.builtin").find_files()
end, { desc = "Find files in project. Tries git files, then based on lsp if " ..
    " not git project,then just regular telescope find files then just" ..
    " regular telescope find files" })
nnoremap("<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>", { desc = "live grep" })
nnoremap("<leader>fs", function()
    require('telescope.builtin').grep_string()
end, { desc = "grep string" })
nnoremap("<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>", { desc = "buffers" })
nnoremap("<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>", { desc = "help tags" })
nnoremap("<C-h>", function()
    require("telescope.builtin").keymaps()
end, { desc = "list keymaps" })
nnoremap("<leader>gs", function()
    require("telescope.builtin").git_status()
end, { desc = "view git status" })
