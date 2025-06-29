local find_rust_edition = function(params)
	local Path = require("plenary.path")
	local cargo_toml = Path:new(params.root .. "/" .. "Cargo.toml")

	if cargo_toml:exists() and cargo_toml:is_file() then
		for _, line in ipairs(cargo_toml:readlines()) do
			local edition = line:match([[^edition%s*=%s*%"(%d+)%"]])
			if edition then
				return { "--edition=" .. edition }
			end
		end
	end
	-- default edition when we don't find `Cargo.toml` or the `edition` in it.
	return { "--edition=2021" }
end
return {
	{
		"stevearc/conform.nvim",
		dependencies = { "mason.nvim" },
		lazy = true,
		event = { "BufWritePre" },
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>cF",
				function()
					require("conform").format({ formatters = { "injected" } })
				end,
				mode = { "n", "v" },
				desc = "Format Injected Langs",
			},
		},
		init = function()
			-- If you want the formatexpr, here is the place to set it
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
		opts = {
			notify_on_error = false,
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },
				-- Use a sub-list to run only the first available formatter
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
				jsonc = { "prettierd", "prettier", stop_after_first = true },
				rust = { "rustfmt" },
				go = { "gofmt" },
				c = { "clang-format" },
				cpp = { "clang-format" },
			},
			format_on_save = function(bufnr)
				-- Disable with a global or buffer-local variable
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				return { timeout_ms = 500, lsp_format = "fallback" }
			end,
		},
		config = function(_, opts)
			local util = require("conform.util")
			-- util.add_formatter_args(require("conform.formatters.rustfmt"), { "--edition", "2021" })
			require("conform").setup(opts)
			vim.api.nvim_create_user_command("FormatDisable", function(args)
				if args.bang then
					-- FormatDisable! will disable formatting just for this buffer
					vim.b.disable_autoformat = true
				else
					vim.g.disable_autoformat = true
				end
			end, {
				desc = "Disable autoformat-on-save",
				bang = true,
			})
			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
			end, {
				desc = "Re-enable autoformat-on-save",
			})
		end,
	},
}
