return {
	{
		"echasnovski/mini.nvim",
		version = false,
		config = function()
			require("mini.indentscope").setup()
			require("mini.pairs").setup()
		end,
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"help",
					"alpha",
					"dashboard",
					"NvimTree",
					"Trouble",
					"lazy",
					"mason",
					"notify",
					"toggleterm",
					"lazyterm",
				},
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
		end,
	},
}
