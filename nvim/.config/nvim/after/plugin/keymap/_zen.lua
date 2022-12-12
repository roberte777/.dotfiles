local Remap = require("roberte777.keymap")
local nnoremap = Remap.nnoremap
nnoremap("<leader>tz",function()
    require("zen-mode").toggle({
  window = {
    width = .85 -- width will be 85% of the editor width
  }})
  end
  )
