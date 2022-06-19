local Remap = require("roberte777.keymap")
local nnoremap = Remap.nnoremap
nnoremap("<leader>ff", "<cmd> lua require('telescope.builtin').find_files()<CR>")
Nnoremap("<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>")
Nnoremap("<leader>fb","<cmd>lua require('telescope.builtin').buffers()<cr>")
Nnoremap("<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>")
