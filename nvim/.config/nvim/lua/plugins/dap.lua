return {
	{
		"mfussenegger/nvim-dap",
		config = function()
			-- require("custom.configs.dap")
		end,
	},
	{ "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" } },
}
