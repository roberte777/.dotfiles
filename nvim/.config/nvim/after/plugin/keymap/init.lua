local Remap  = require("roberte777.keymap")
local inoremap = Remap.inoremap
local nnoremap = Remap.nnoremap
inoremap("<C-c>", "<Esc>")
nnoremap("<leader><CR>", "<cmd>:luafile $MYVIMRC<CR>")



