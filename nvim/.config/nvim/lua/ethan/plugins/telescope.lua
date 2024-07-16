return {
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",

	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-telescope/telescope-ui-select.nvim",
		"nvim-tree/nvim-web-devicons",
		"ThePrimeagen/harpoon",
	},
	config = function()
		-- import telescope plugin safely
		local telescope = require("telescope")

		-- import telescope actions safely
		local actions = require("telescope.actions")

		-- import telescope-ui-select safely
		local themes = require("telescope.themes")

		-- configure telescope
		telescope.setup({
			-- configure custom mappings
			defaults = {
				-- path_display = { "truncate" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
					},
				},
			},
			extensions = {
				["ui-select"] = {
					themes.get_dropdown({}),
				},
			},
		})

		telescope.load_extension("fzf")
		telescope.load_extension("ui-select")
		-- telescope.load_extension("harpoon")

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		local builtin = require("telescope.builtin")
		keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp tags" })
		keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]ind [K]eymaps" })

		-- Fuzzy find all the symbols in your current document.
		--  Symbols are things like variables, functions, types, etc.
		keymap.set(
			"n",
			"<leader>fs",
			require("telescope.builtin").lsp_document_symbols,
			{ desc = "[L]ookat [D]ocument [S]ymbols" }
		)

		-- Fuzzy find all the symbols in your current workspace.
		--  Similar to document symbols, except searches over your entire project.
		keymap.set(
			"n",
			"<leader>fS",
			require("telescope.builtin").lsp_dynamic_workspace_symbols,
			{ desc = "[L]ookat [W]orkspace [S]ymbols" }
		)
		keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" }) -- find files within current working directory, respects .gitignore
		keymap.set("n", "<leader>ft", builtin.builtin, { desc = "[F]ind [T]elescope builtins" })
		keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind with [G]rep" }) -- find string in current working directory as you type
		keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "[F]ind string under [C]ursor in cwd" }) -- find string under cursor in current working directory
		keymap.set("n", "<leader>fw", builtin.diagnostics, { desc = "[F]ind [W]orkspace diagnostics" }) -- list open buffers in current neovim instance
		keymap.set("n", "<leader>fd", function()
			require("telescope.builtin").diagnostics({ bufnr = 0 })
		end, { desc = "[F]ind file [D]iagnostics" }) -- list open buffers in current neovim instance
		keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind [B]uffers" }) -- list open buffers in current neovim instance
		keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "[F]ind recent files" }) -- find previously opened files
		vim.keymap.set("n", "<leader>/", function()
			-- You can pass additional configuration to Telescope to change the theme, layout, etc.
			builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = false,
			}))
		end, { desc = "[/] [F]uzzily search in current buffer" })
		-- Shortcut for searching your Neovim configuration files
		vim.keymap.set("n", "<leader>fn", function()
			builtin.find_files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "[F]ind [N]eovim files" })
		keymap.set("n", "<leader>hf", "<cmd>Telescope harpoon marks<cr>", { desc = "Show harpoon marks" }) -- show harpoon marks
		keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "Show git commits" }) -- list all git commits (use <cr> to checkout) ["gc" for git commits]
		keymap.set(
			"n",
			"<leader>gfc",
			"<cmd>Telescope git_bcommits<cr>",
			{ desc = "Show git commits for current buffer" }
		) -- list git commits for current file/buffer (use <cr> to checkout) ["gfc" for git file commits]
		keymap.set("n", "<leader>gr", "<cmd>Telescope git_branches<cr>", { desc = "Show git branches" }) -- list git branches (use <cr> to checkout) ["gb" for git branch]
		keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "Show current git changes per file" }) -- list current changes per file with diff preview ["gs" for git status]
	end,
}
