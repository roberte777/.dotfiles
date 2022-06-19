local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Setup nvim-cmp.
local cmp = require("cmp")
-- source mapping dictates how the source of the autocomplete is shown
-- by cmp, ex autocomplete suggestions that come from lsp will have
-- [LSP] at the end of the row
local lspkind = require("lspkind")

cmp.setup({
	snippet = {
		expand = function(args)
			-- For `vsnip` user.
			-- vim.fn["vsnip#anonymous"](args.body)

			-- For `luasnip` user.
			require("luasnip").lsp_expand(args.body)

			-- For `ultisnips` user.
			-- vim.fn["UltiSnips#Anon"](args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-u>"] = cmp.mapping.scroll_docs(-4),
		["<C-d>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ['<C-e>'] = cmp.mapping.abort(),
        ['<Tab>'] = function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end
	}),

 formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol', -- show only symbol annotations
      maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      menu = {
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        nvim_lua = "[API]",
        path = "[PATH]"
      },

    }),
  },
  sources = cmp.config.sources({

		{ name = "nvim_lsp" },

		-- For vsnip user.
		-- { name = 'vsnip' },

		-- For luasnip user.
		{ name = "luasnip" },

		-- For ultisnips user.
		-- { name = 'ultisnips' },

		{ name = "buffer" },
	}),
})


local function config(_config)
	return vim.tbl_deep_extend("force", {
		capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()),
		on_attach = function()
            Nnoremap("<leader>vtd",":lua vim.lsp.buf.type_definition()<CR>")
			Nnoremap("gd", ":lua vim.lsp.buf.definition()<CR>")
			Nnoremap("K", ":lua vim.lsp.buf.hover()<CR>")
			Nnoremap("<leader>vws", ":lua vim.lsp.buf.workspace_symbol()<CR>")
			Nnoremap("<leader>vd", ":lua vim.diagnostic.open_float()<CR>")
			Nnoremap("dn", ":lua vim.lsp.diagnostic.goto_next()<CR>")
			Nnoremap("dp", ":lua vim.lsp.diagnostic.goto_prev()<CR>")
			Nnoremap("<leader>vca", ":lua vim.lsp.buf.code_action()<CR>")
			-- Nnoremap("<leader>vrr", ":lua vim.lsp.buf.references()<CR>")
			Nnoremap("<leader>vrn", ":lua vim.lsp.buf.rename()<CR>")
			Inoremap("<C-h>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
		end,
	}, _config or {})
end

require("lspconfig").tsserver.setup(config())
--require("lspconfig").pyright.setup(config())
--[[  I cannot seem to get this woring on new computer..
require("lspconfig").clangd.setup(config({
	cmd = { "clangd", "--background-index", "--log=verbose" },
    root_dir = function()
        print("clangd-Rootdir", vim.loop.cwd())
		return vim.loop.cwd()
	end,
}))
--]]
require("lspconfig").ccls.setup(config())

require("lspconfig").jedi_language_server.setup(config())

require("lspconfig").svelte.setup(config())

require("lspconfig").solang.setup(config())

require("lspconfig").cssls.setup(config())

require("lspconfig").gopls.setup(config({
	cmd = { "gopls", "serve" },
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
		},
	},
}))

-- I dont know what this stuff does, dis how prime had it
--require("lspconfig").rust_analyzer.setup(config({
--	cmd = { "rustup", "run", "nightly", "rust-analyzer" },
--	--[[
--    settings = {
--        rust = {
--            unstable_features = true,
--            build_on_save = false,
--            all_features = true,
--        },
--    }
--    --]]
--}))
--basic rust setup
require("lspconfig").rust_analyzer.setup(config())
