return {
	{

		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup({
				extensions = {
					fzf = {
						fuzzy = true, -- false will only do exact matching
						override_generic_sorter = true, -- override the generic sorter
						override_file_sorter = true, -- override the file sorter
						case_mode = "smart_case", -- or "ignore_case" or "respect_case"
						-- the default case_mode is "smart_case"
					},
				},
			})
			-- To get fzf loaded and working with telescope, you need to call
			-- load_extension, somewhere after setup function:
			require("telescope").load_extension("fzf")

			local find_files = function(opts)
				opts = opts or {}
				local clients = vim.lsp.get_active_clients()
				local length = table.getn(clients)
				if length > 0 then
					opts.cwd = clients[1].config.root_dir
				end
				require("telescope.builtin").find_files(opts)
			end

			local project_files = function()
				local opts = {} -- define here if you want to define something
				local ok = pcall(require("telescope.builtin").git_files, opts)
				if not ok then
					require("roberte777._telescope").find_files(opts)
				end
			end

			local Remap = require("roberte777.keymap")
			local nnoremap = Remap.nnoremap

			-- currently, my mappings with telescope are in lsp and here. v is the start
			-- when I want to view something, f for finding. I plan to use g for git. Ex.
			-- vws = view workspace symbols. ff = find files.

			--going to try normal find files for a while, move back to this if it goes
			--poorly
			-- nnoremap("<leader>ff", "<cmd> lua require('roberte777._telescope').project_files()<CR>",
			--     { desc = "Find files in project. Tries git files, then based on lsp if " ..
			--         " not git project,then just regular telescope find files then just" ..
			--         " regular telescope find files" })

			nnoremap("<leader>ff", function()
				require("telescope.builtin").find_files()
			end, {
				desc = "Find files in project. Tries git files, then based on lsp if "
					.. " not git project,then just regular telescope find files then just"
					.. " regular telescope find files",
			})
			nnoremap("<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>", { desc = "live grep" })
			nnoremap("<leader>fs", function()
				require("telescope.builtin").grep_string()
			end, { desc = "grep string" })
			nnoremap("<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>", { desc = "buffers" })
			nnoremap("<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>", { desc = "help tags" })
			nnoremap("<C-h>", function()
				require("telescope.builtin").keymaps()
			end, { desc = "list keymaps" })
			nnoremap("<leader>gs", function()
				require("telescope.builtin").git_status()
			end, { desc = "view git status" })
		end,
	},

	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
	},
}
