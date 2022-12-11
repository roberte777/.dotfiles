local Remap = require("roberte777.keymap")
local nnoremap = Remap.nnoremap
nnoremap("<leader>ts", function()
	require("keep-it-secret").toggle()
end)
