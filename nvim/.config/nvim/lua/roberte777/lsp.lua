local Remap = require("roberte777.keymap")
local nnoremap = Remap.nnoremap
local inoremap = Remap.inoremap
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
		capabilities = require("cmp_nvim_lsp").default_capabilities(),
		on_attach = function()
            nnoremap("<leader>gtd",function()
                require("telescope.builtin").lsp_type_definitions()
            end, {desc = "go to type definitions"})
			nnoremap("gd", function()
                require("telescope.builtin").lsp_definitions()
            end, {desc = "go to definitions"})
			nnoremap("K", ":lua vim.lsp.buf.hover()<CR>")
			nnoremap("<leader>vs", function()
                require("telescope.builtin").lsp_document_symbols()
            end, {desc = "view document symbols"})
			nnoremap("<leader>vws", function()
                require("telescope.builtin").lsp_workspace_symbols()
            end, {desc = "view workspace symbols"})
			nnoremap("<leader>vd", function()
                require("telescope.builtin").diagnostics({bufnr=0})
            end, {desc = "view diagnostics for file"})
			nnoremap("<leader>vad", function()
                require("telescope.builtin").diagnostics()
            end, {desc = "view all diagnostics"})
			nnoremap("<leader>vld", function()
                vim.diagnostic.open_float()
            end, {desc = "view line diagnostics"})
			nnoremap("dn", ":lua vim.lsp.diagnostic.goto_next()<CR>")
			nnoremap("dp", ":lua vim.lsp.diagnostic.goto_prev()<CR>")
			nnoremap("<leader>vca", ":lua vim.lsp.buf.code_action()<CR>", {desc = "view code actions"})
			nnoremap("<leader>vrr", function()
                require("telescope.builtin").lsp_references()
            end, {desc = "view references"})
			nnoremap("<leader>vrn", ":lua vim.lsp.buf.rename()<CR>", {desc = "rename"})
			inoremap("<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", {desc = "signature help"})
		end,
	}, _config or {})
end

require("lspconfig").tsserver.setup(config({
        root_dir = require("lspconfig").util.root_pattern("package.json", "tsconfig.json", "jsconfig.json")
    })
)
require("lspconfig").ccls.setup(config())

require("lspconfig").pyright.setup(config())

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

--deno, alternate to node, setup
-- require("lspconfig").denols.setup(config({
--   root_dir = require("lspconfig").util.root_pattern("deno.json", "deno.jsonc"),
-- }))

--basic rust setup
require("lspconfig").rust_analyzer.setup(config())
require("lspconfig").sumneko_lua.setup(config({settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = vim.split(package.path, ';'),
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
            [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
        },
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },}))

-- hope you never need this, but if you do:
-- this is to get the lsp:
--https://github.com/eruizc-dev/jdtls-launcher#installation
--this is to get java:
--https://www.oracle.com/java/technologies/downloads/
--make sure your machine is pointing to the right java
-- require'lspconfig'.jdtls.setup(config({cmd = { 'jdtls' } }))
