local Remap = require("roberte777.keymap")
local nnoremap = Remap.nnoremap
nnoremap("<C-n>", "<cmd> :NvimTreeToggle<CR>")
nnoremap("<leader>r", "<cmd> :NvimTreeRefresh<CR>")
nnoremap("<leader>n", "<cmd> :NvimTreeToggle<CR>")
