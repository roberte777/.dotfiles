require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "rust_analyzer", "pyright", "tsserver" },
})
local lsp = require("lspconfig")

--------------------------------------------------
-- Keymaps
--------------------------------------------------
local function add_to_table(add_to, to_add)
	for k, v in pairs(to_add) do
		add_to[k] = v
	end
	return add_to -- for convenience (chaining)
end

--global mappings
vim.keymap.set("n", "<leader>vd", function()
	vim.diagnostic.open_float()
end, { desc = "Open diagnostics" })
vim.keymap.set("n", "[d", function()
	vim.diagnostic.goto_next()
end, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.goto_prev()
end, { desc = "Go to previous diagnostic" })

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

--------------------------------------------------
-- Completion
--------------------------------------------------
local kind_icons = {
	Text = "",
	Method = "",
	Function = "",
	Constructor = "",
	Field = "",
	Variable = "",
	Class = "ﴯ",
	Interface = "",
	Module = "",
	Property = "ﰠ",
	Unit = "",
	Value = "",
	Enum = "",
	Keyword = "",
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "",
	Event = "",
	Operator = "",
	TypeParameter = "",
}

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
cmp.setup({
	completion = {
		completeopt = "menu,menuone",
	},
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = {
		["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
		["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
		["<C-Space>"] = cmp.mapping.complete(),
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "path" },
	}),
	formatting = {
		format = function(entry, vim_item)
			-- Kind icons
			vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
			-- Source
			vim_item.menu = ({
				buffer = "[Buffer]",
				nvim_lsp = "[LSP]",
				luasnip = "[LuaSnip]",
				nvim_lua = "[Lua]",
				latex_symbols = "[LaTeX]",
			})[entry.source.name]
			return vim_item
		end,
	},

	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
})

--------------------------------------------------
-- Language servers
--------------------------------------------------

local default_capabilities = require("cmp_nvim_lsp").default_capabilities()
local function setup_lsp(name, opts)
	lsp[name].setup(opts)
end
local clang_capabilities = require("cmp_nvim_lsp").default_capabilities()
clang_capabilities.offsetEncoding = { "utf-16" }

local servers = {
	lua_ls = {
		capabilities = default_capabilities,
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					checkThirdParty = false,
					library = vim.api.nvim_get_runtime_file("", true),
				},
			},
		},
	},
	pyright = {
		capabilities = default_capabilities,
	},
	rust_analyzer = {
		capabilities = default_capabilities,
	},
	tsserver = {
		capabilities = default_capabilities,
	},
	clangd = {
		capabilities = clang_capabilities,
	},
}

-- setup servers
for name, opts in pairs(servers) do
	setup_lsp(name, opts)
end
