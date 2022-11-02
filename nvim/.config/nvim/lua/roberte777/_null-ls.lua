local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

require("null-ls").setup({
    debug = false,
    sources = {
        require("null-ls").builtins.diagnostics.pylint,
        require("null-ls").builtins.diagnostics.eslint,
    },
})
