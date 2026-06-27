require("ethan.core")

-- Toggle Neovim's experimental native UI2 message/cmdline UI.
vim.g.use_ui2 = true

if vim.g.use_ui2 then
	local ok, ui2 = pcall(require, "vim._core.ui2")
	if ok and ui2 and ui2.enable then
		ui2.enable({})
	end
end

require("ethan.lazy")
vim.g._ts_force_sync_parsing = true
