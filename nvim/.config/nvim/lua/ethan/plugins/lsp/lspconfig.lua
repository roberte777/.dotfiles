return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"jose-elias-alvarez/typescript.nvim",
			"p00f/clangd_extensions.nvim",
			"hrsh7th/cmp-nvim-lsp",
			{
				"mrcjkb/rustaceanvim",
				version = "^4", -- Recommended
				ft = { "rust" },
			},
			-- Useful status updates for LSP.
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ "j-hui/fidget.nvim", opts = {} },
			-- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
			-- used for completion, annotations and signatures of Neovim apis
			{ "folke/neodev.nvim", opts = {} },
		},
		config = function()
			-- import lspconfig plugin

			local keymap = vim.keymap -- for conciseness

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					-- keybind options
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end
					local opts = { noremap = true, silent = true, buffer = bufnr }
					local builtin = require("telescope.builtin")

					-- set keybinds
					map("gr", builtin.lsp_references, "[G]oto [R]eferences") -- show definition, references

					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration") -- go to declaration

					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					map("<leader>gt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype definition")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map(
						"<leader>lds",
						require("telescope.builtin").lsp_document_symbols,
						"[L]ookat [D]ocument [S]ymbols"
					)

					-- Fuzzy find all the symbols in your current workspace.
					--  Similar to document symbols, except searches over your entire project.
					map(
						"<leader>lws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[L]ookat [W]orkspace [S]ymbols"
					)

					map("gl", vim.diagnostic.open_float, "[G]oto [L]ine diagnostics") -- show diagnostics for line

					map("<leader>lk", vim.diagnostic.goto_prev, "[L]ookat previous diagnostic") -- jump to previous diagnostic in buffer

					map("<leader>lj", vim.diagnostic.goto_next, "[L]ookat next diagnostic") -- jump to next diagnostic in buffer

					map("K", vim.lsp.buf.hover, "Hover Documentation") -- show documentation for what is under cursor

					map("<space>lr", vim.lsp.buf.rename, "[R]ename") -- show documentation for what is under cursor

					map("<space>lw", function()
						require("trouble").open("workspace_diagnostics")
					end, "[L]ookat [W]orkspace trouble diagnostics") -- show documentation for what is under cursor

					map("<space>ld", function()
						require("trouble").open("document_diagnostics")
					end, "[L]ookat [T]rouble diagnostics") -- show documentation for what is under cursor

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.server_capabilities.documentHighlightProvider then
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							callback = vim.lsp.buf.clear_references,
						})
					end

					-- typescript specific keymaps (e.g. rename file and update imports)
					if client.name == "tsserver" then
						opts.desc = "Rename file and update file imports"
						keymap.set("n", "<leader>lf", ":TypescriptRenameFile<CR>") -- rename file and update imports

						opts.desc = "Rename file and update file imports"
						keymap.set("n", "<leader>lo", ":TypescriptOrganizeImports<CR>", opts) -- organize imports (not in youtube nvim video)

						opts.desc = "Remove unused imports"
						keymap.set("n", "<leader>lu", ":TypescriptRemoveUnused<CR>", opts) -- remove unused variables (not in youtube nvim video)
					end

					if client.name == "clangd" then
						opts.desc = "Switch Source/Header"
						keymap.set("n", "<leader>lh", "<cmd>ClangdSwitchSourceHeader<cr>", opts)
					end
				end,
			})

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- Change the Diagnostic symbols in the sign column (gutter)
			-- (not in youtube nvim video)
			local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			-- rust
			vim.g.rustaceanvim = {
				-- LSP configuration
				server = {
					default_settings = {
						-- rust-analyzer language server configuration
						["rust-analyzer"] = {
							cargo = {
								allFeatures = true,
							},
							-- Add clippy lints for Rust.
							checkOnSave = {
								allFeatures = true,
								command = "clippy",
								extraArgs = { "--no-deps" },
							},
						},
					},
				},
			}

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
			local servers = {
				clangd = {
					capabilities = { offsetEncoding = "utf-16" },
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
					},
				},
				gopls = {},
				pyright = {},
				-- rust_analyzer = {},
				tsserver = {},

				lua_ls = {
					-- cmd = {...},
					-- filetypes = { ...},
					-- capabilities = {},
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
							-- diagnostics = { disable = { 'missing-fields' } },
						},
					},
				},
			}

			-- Ensure the servers and tools above are installed
			--  To check the current status of installed tools and/or manually install
			--  other tools, you can run
			--    :Mason
			--
			--  You can press `g?` for help in this menu.
			require("mason").setup()

			-- You can add other tools here that you want Mason to install
			-- for you, so that they are available from within Neovim.
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for tsserver)
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},
}
