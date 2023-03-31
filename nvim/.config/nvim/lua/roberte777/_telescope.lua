
local M = {}

M.find_files = function(opts)
    opts = opts or {}
    local clients = vim.lsp.get_active_clients()
    local length = table.getn(clients)
    if length > 0 then
        opts.cwd = clients[1].config.root_dir
    end
    require'telescope.builtin'.find_files(opts)
end

M.project_files = function()
  local opts = {} -- define here if you want to define something
  local ok = pcall(require"telescope.builtin".git_files, opts)
  if not ok then require"roberte777._telescope".find_files(opts) end
end

M.live_grep = function()
end


return M

