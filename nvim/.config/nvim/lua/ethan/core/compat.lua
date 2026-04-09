-- Compatibility shims for plugins that still call deprecated Neovim APIs.
if vim.lsp and vim.lsp.get_client_by_id then
	vim.lsp.get_buffers_by_client_id = function(client_id)
		local client = vim.lsp.get_client_by_id(client_id)
		return client and vim.tbl_keys(client.attached_buffers or {}) or {}
	end
end
