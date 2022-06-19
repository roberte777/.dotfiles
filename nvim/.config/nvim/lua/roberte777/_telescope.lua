-- You dont need to set any of these options. These are the default ones. Only
-- the loading is important
require('telescope').setup {
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  }
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require('telescope').load_extension('fzf')

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

