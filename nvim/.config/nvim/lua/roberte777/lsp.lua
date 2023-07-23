--------------------------------------------------
-- Language servers
--------------------------------------------------
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local mason_lspconfig = require("mason-lspconfig")
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
	-- rust_analyzer = {},
	tsserver = {},
}

mason_lspconfig.setup({
	ensure_installed = vim.tbl_keys(servers),
})

mason_lspconfig.setup_handlers({
	function(server_name)
		local cpb = capabilities
		if server_name == "clangd" then
			local clang_capabilities = require("cmp_nvim_lsp").default_capabilities()
			clang_capabilities.offsetEncoding = { "utf-16" }
			cpb = clang_capabilities
		end
		require("lspconfig")[server_name].setup({
			capabilities = cpb,
			settings = servers[server_name],
		})
	end,
})

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
local icons = {
	dap = {
		Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
		Breakpoint = " ",
		BreakpointCondition = " ",
		BreakpointRejected = { " ", "DiagnosticError" },
		LogPoint = ".>",
	},
	diagnostics = {
		Error = " ",
		Warn = " ",
		Hint = " ",
		Info = " ",
	},
	git = {
		added = " ",
		modified = " ",
		removed = " ",
	},
	kinds = {
		Array = " ",
		Boolean = " ",
		Class = " ",
		Color = " ",
		Constant = " ",
		Constructor = " ",
		Copilot = " ",
		Enum = " ",
		EnumMember = " ",
		Event = " ",
		Field = " ",
		File = " ",
		Folder = " ",
		Function = " ",
		Interface = " ",
		Key = " ",
		Keyword = " ",
		Method = " ",
		Module = " ",
		Namespace = " ",
		Null = " ",
		Number = " ",
		Object = " ",
		Operator = " ",
		Package = " ",
		Property = " ",
		Reference = " ",
		Snippet = " ",
		String = " ",
		Struct = " ",
		Text = " ",
		TypeParameter = " ",
		Unit = " ",
		Value = " ",
		Variable = " ",
	},
}

-- local kind_icons = {
-- 	Text = "",
-- 	Method = "",
-- 	Function = "",
-- 	Constructor = "",
-- 	Field = "",
-- 	Variable = "",
-- 	Class = "ﴯ",
-- 	Interface = "",
-- 	Module = "",
-- 	Property = "ﰠ",
-- 	Unit = "",
-- 	Value = "",
-- 	Enum = "",
-- 	Keyword = "",
-- 	Snippet = "",
-- 	Color = "",
-- 	File = "",
-- 	Reference = "",
-- 	Folder = "",
-- 	EnumMember = "",
-- 	Constant = "",
-- 	Struct = "",
-- 	Event = "",
-- 	Operator = "",
-- 	TypeParameter = "",
-- }

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
cmp.setup({
	preselect = cmp.PreselectMode.None,
	completion = {
		completeopt = "menu,menuone,noselect",
	},
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = {
		["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
		["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = false,
		}),
		["<C-Space>"] = cmp.mapping.complete(),
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "path" },
		{ name = "crates" },
	}),
	formatting = {
		format = function(entry, vim_item)
			-- Kind icons
			local kind_icons = icons.kinds
			if kind_icons[vim_item.kind] then
				vim_item.kind = kind_icons[vim_item.kind] .. vim_item.kind
			end
			-- Source
			-- vim_item.menu = ({
			-- 	buffer = "[Buffer]",
			-- 	nvim_lsp = "[LSP]",
			-- 	luasnip = "[LuaSnip]",
			-- 	nvim_lua = "[Lua]",
			-- 	latex_symbols = "[LaTeX]",
			-- })[entry.source.name]
			return vim_item
		end,
	},

	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
})
