local default_opts = require("plugins.configs.cmp")
local cmp = require("cmp")
local mapping = {
	["<C-p>"] = cmp.mapping.select_prev_item(),
	["<C-n>"] = cmp.mapping.select_next_item(),
	["<C-d>"] = cmp.mapping.scroll_docs(-4),
	["<C-f>"] = cmp.mapping.scroll_docs(4),
	["<C-Space>"] = cmp.mapping.complete(),
	["<C-e>"] = cmp.mapping.close(),
	["<CR>"] = cmp.mapping.confirm({
		behavior = cmp.ConfirmBehavior.Replace,
		select = false,
	}),
}

default_opts.mapping = mapping
default_opts.preselect = cmp.PreselectMode.None
default_opts.completion = {
	completeopt = "menu,menuone, noselect",
}
cmp.setup(default_opts)
