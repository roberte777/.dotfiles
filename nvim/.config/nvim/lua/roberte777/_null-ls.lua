local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
    return
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
require("null-ls").setup({
    debug = false,
    sources = {
        require("null-ls").builtins.diagnostics.pylint,
        require("null-ls").builtins.diagnostics.eslint,
        require("null-ls").builtins.formatting.prettier,
        require("null-ls").builtins.formatting.stylua,
        require("null-ls").builtins.formatting.rustfmt,
    },
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ bufnr = bufnr })
                end,
            })
        end
    end,
})
