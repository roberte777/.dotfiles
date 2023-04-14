local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
	"tsserver",
	"eslint",
	"lua_ls",
	"rust_analyzer",
})

lsp.set_preferences({
	sign_icons = {},
})
local function add_to_table(add_to, to_add)
	for k, v in pairs(to_add) do
		add_to[k] = v
	end
	return add_to -- for convenience (chaining)
end

lsp.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }

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
	vim.keymap.set("n", "<leader>vd", function()
		vim.diagnostic.open_float()
	end, add_to_table(opts, { desc = "Open diagnostics" }))
	vim.keymap.set("n", "[d", function()
		vim.diagnostic.goto_next()
	end, add_to_table(opts, { desc = "Go to next diagnostic" }))
	vim.keymap.set("n", "]d", function()
		vim.diagnostic.goto_prev()
	end, add_to_table(opts, { desc = "Go to previous diagnostic" }))
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
end)

-- setup CPP
local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
lsp_capabilities.offsetEncoding = { "utf-16" }
lsp.configure("clangd", {
	capabilities = lsp_capabilities,
})

lsp.nvim_workspace()

lsp.setup()

-- setup completions
local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
cmp.setup({
	preset = "none",
	completion = {
		completeopt = "menu,menuone,noinsert,noselect",
	},
	mapping = {
		["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
		["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
		["<C-Space>"] = cmp.mapping.complete(),
	},
})
