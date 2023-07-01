local rt = require("rust-tools")
local function get_codelldb()
	local mason_registry = require("mason-registry")
	local codelldb = mason_registry.get_package("codelldb")
	local extension_path = codelldb:get_install_path() .. "/extension/"
	local codelldb_path = extension_path .. "adapter/codelldb"
	local liblldb_path = extension_path .. "lldb/lib/liblldb.so"
	return codelldb_path, liblldb_path
end
local codelldb_path, liblldb_path = get_codelldb()

rt.setup({
	tools = {
		on_initialized = function()
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "CursorHold", "InsertLeave" }, {
				pattern = { "*.rs" },
				callback = function()
					vim.lsp.codelens.refresh()
				end,
			})
		end,
		runnables = {
			use_telescope = true,
		},
	},
	server = {
		on_attach = function(client, bufnr)
			local map = function(mode, lhs, rhs, desc)
				if desc then
					desc = desc
				end
				vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = bufnr, noremap = true })
			end

			client.server_capabilities.semanticTokensProvider = nil
			-- Hover actions
			vim.keymap.set("n", "<C-b>", rt.hover_actions.hover_actions, { buffer = bufnr })
			-- Code action groups
			vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
			map("n", "<leader>le", "<cmd>RustRunnables<cr>", "Runnables")
			map("n", "K", "<cmd>RustHoverActions<cr>", "Hover Actions")
			map("n", "<leader>ll", function()
				vim.lsp.codelens.run()
			end, "Code Lens")
			map("n", "<leader>lt", ":!cargo test<CR>", "Cargo test")
			map("n", "<leader>lR", ":!cargo run<CR>", "Cargo run")
			map("n", "<leader>lb", ":!cargo build<CR>", "Cargo build")
		end,
		standalone = true,
		settings = {
			-- to enable rust-analyzer settings visit:
			-- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
			["rust-analyzer"] = {
				checkOnSave = {
					command = "clippy",
					extraArgs = { "--no-deps" },
				},
			},
		},
	},
	dap = {
		adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
	},
})
