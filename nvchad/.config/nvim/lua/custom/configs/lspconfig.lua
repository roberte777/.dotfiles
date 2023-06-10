local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities
local mason_lspconfig = require 'mason-lspconfig'
local servers = {
	html = {},
	cssls = {},
	clangd = {},
	pyright = {},
	lua_ls = {
			Lua = {
				diagnostics = { globals = "vim" },
				workspace = {
					checkThirdParty = false,
					library = vim.api.nvim_get_runtime_file("", true),
				},
			},
		},
	rust_analyzer = {},
	tsserver = {},
}

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
    }
  end,
}

local function add_to_table(add_to, to_add)
	for k, v in pairs(to_add) do
		add_to[k] = v
	end
	return add_to -- for convenience (chaining)
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gd", function()
			vim.lsp.buf.definition()
		end, add_to_table(opts, { desc = "Go to definition" }))
		vim.keymap.set("n", "gtd", function()
			vim.lsp.buf.type_definition()
		end, add_to_table(opts, { desc = "Go to type definition" }))
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover()
		end, add_to_table(opts, { desc = "Hover" }))
		vim.keymap.set("n", "<leader>vws", function()
			vim.lsp.buf.workspace_symbol()
		end, add_to_table(opts, { desc = "Workspace symbols" }))
		vim.keymap.set("n", "<leader>vca", function()
			vim.lsp.buf.code_action()
		end, add_to_table(opts, { desc = "Code actions" }))
		vim.keymap.set("n", "<leader>vrr", function()
			vim.lsp.buf.references()
		end, add_to_table(opts, { desc = "References" }))
		vim.keymap.set("n", "<leader>vrn", function()
			vim.lsp.buf.rename()
		end, add_to_table(opts, { desc = "Rename" }))
		-- vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
	end,
})
