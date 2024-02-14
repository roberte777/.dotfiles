return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"jose-elias-alvarez/typescript.nvim",
			"p00f/clangd_extensions.nvim",
			"hrsh7th/cmp-nvim-lsp",
			{
				"mrcjkb/rustaceanvim",
				version = "^4", -- Recommended
				ft = { "rust" },
			},
		},
		config = function()
			-- import lspconfig plugin
			local lspconfig = require("lspconfig")

			-- import cmp-nvim-lsp plugin
			local cmp_nvim_lsp = require("cmp_nvim_lsp")

			-- import typescript plugin
			local typescript = require("typescript")

			local keymap = vim.keymap -- for conciseness

			-- enable keybinds only for when lsp server available
			local on_attach = function(client, bufnr)
				-- keybind options
				local opts = { noremap = true, silent = true, buffer = bufnr }

				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Show line diagnostics"
				keymap.set("n", "gl", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "<leader>lk", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "<leader>lj", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Rename"
				keymap.set("n", "<space>lr", vim.lsp.buf.rename, opts) -- show documentation for what is under cursor

				opts.desc = "Workspace diagnostics"
				keymap.set("n", "<space>lw", function()
					require("trouble").open("workspace_diagnostics")
				end, opts) -- show documentation for what is under cursor

				opts.desc = "Document diagnostics"
				keymap.set("n", "<space>ld", function()
					require("trouble").open("document_diagnostics")
				end, opts) -- show documentation for what is under cursor

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
			end

			-- used to enable autocompletion (assign to every lsp server config)
			local capabilities = cmp_nvim_lsp.default_capabilities()

			-- Change the Diagnostic symbols in the sign column (gutter)
			-- (not in youtube nvim video)
			local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			-- rust
			vim.g.rustaceanvim = {
				-- Plugin configuration
				tools = {},
				-- LSP configuration
				server = {
					on_attach = on_attach,
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
				-- DAP configuration
				dap = {},
			}

			-- python
			lspconfig["pyright"].setup({
				single_file_support = true,
				settings = {
					pyright = {
						disableLanguageServices = false,
						disableOrganizeImports = false,
					},
					python = {
						analysis = {
							autoImportCompletions = true,
							autoSearchPaths = true,
							diagnosticMode = "workspace", -- openFilesOnly, workspace
							typeCheckingMode = "basic", -- off, basic, strict
							useLibraryCodeForTypes = true,
						},
					},
				},
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- cpp
			local cppCapabilities = cmp_nvim_lsp.default_capabilities()
			cppCapabilities.offsetEncoding = "utf-16"
			lspconfig["clangd"].setup({
				settings = {},
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--function-arg-placeholders",
					"--fallback-style=llvm",
				},
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- go
			lspconfig["gopls"].setup({
				settings = {
					gopls = {
						gofumpt = true,
						codelenses = {
							gc_details = false,
							generate = true,
							regenerate_cgo = true,
							run_govulncheck = true,
							test = true,
							tidy = true,
							upgrade_dependency = true,
							vendor = true,
						},
						hints = {
							assignVariableTypes = true,
							compositeLiteralFields = true,
							compositeLiteralTypes = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
						analyses = {
							fieldalignment = true,
							nilness = true,
							unusedparams = true,
							unusedwrite = true,
							useany = true,
						},
						usePlaceholders = true,
						completeUnimported = true,
						staticcheck = true,
						directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
					},
				},
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- configure typescript server with plugin
			typescript.setup({
				server = {
					capabilities = capabilities,
					on_attach = on_attach,
				},
			})

			-- configure html server
			lspconfig["html"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- configure css server
			lspconfig["cssls"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- configure lua server (with special settings)
			lspconfig["lua_ls"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = { -- custom settings for lua
					Lua = {
						-- make the language server recognize "vim" global
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							-- make language server aware of runtime files
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.stdpath("config") .. "/lua"] = true,
							},
						},
					},
				},
			})
		end,
	},
}
