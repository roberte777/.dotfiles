return {
	{
		"mfussenegger/nvim-dap",
		optional = true,
		dependencies = {
			"mfussenegger/nvim-dap-python",
			keys = {
				{
					"<leader>dPt",
					function()
						require("dap-python").test_method()
					end,
					desc = "Debug Method",
				},
				{
					"<leader>dPc",
					function()
						require("dap-python").test_class()
					end,
					desc = "Debug Class",
				},
			},
			config = function()
				local path = require("mason-registry").get_package("debugpy"):get_install_path()
				require("dap-python").setup(path .. "/venv/bin/python")
			end,
		},
	},
	{
		"linux-cultist/venv-selector.nvim",
		cmd = "VenvSelect",
		opts = {},
		keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv" } },
	},
}
