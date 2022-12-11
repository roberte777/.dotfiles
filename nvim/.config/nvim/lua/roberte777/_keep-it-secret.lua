require("keep-it-secret").setup({
	wildcards = { ".*(.env)$", ".*(.secret)$" },
	enabled = false,
})
