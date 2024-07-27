return {
	-- {
	-- 	"echasnovski/mini.pairs",
	-- 	config = function()
	-- 		require("mini.pairs").setup({})
	-- 	end,
	-- },
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		-- use opts = {} for passing setup options
		-- this is equalent to setup({}) function
	},
	{
		"echasnovski/mini.completion",
	},
	{
		"echasnovski/mini.indentscope",
		version = false, -- wait till new 0.7.0 release to put it back on semver
		opts = {
			-- symbol = "▏",
			symbol = "│",
			options = { try_as_border = true },
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"NvimTree",
					"Trouble",
					"trouble",
					"lazy",
					"mason",
					"notify",
					"toggleterm",
					"lazyterm",
				},
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
		end,
	},
	{
		"echasnovski/mini.ai",
		-- keys = {
		--   { "a", mode = { "x", "o" } },
		--   { "i", mode = { "x", "o" } },
		-- },
		event = "VeryLazy",
		dependencies = {
			"folke/which-key.nvim",
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				init = function()
					-- no need to load the plugin, since we only need its queries
					require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
				end,
			},
		},
		opts = function()
			local ai = require("mini.ai")
			return {
				n_lines = 500,
				custom_textobjects = {
					o = ai.gen_spec.treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}, {}),
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
					t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
				},
			}
		end,
		config = function(_, opts)
			local objects = {
				{ " ", desc = "whitespace" },
				{ '"', desc = '" string' },
				{ "'", desc = "' string" },
				{ "(", desc = "() block" },
				{ ")", desc = "() block with ws" },
				{ "<", desc = "<> block" },
				{ ">", desc = "<> block with ws" },
				{ "?", desc = "user prompt" },
				{ "U", desc = "use/call without dot" },
				{ "[", desc = "[] block" },
				{ "]", desc = "[] block with ws" },
				{ "_", desc = "underscore" },
				{ "`", desc = "` string" },
				{ "a", desc = "argument" },
				{ "b", desc = ")]} block" },
				{ "c", desc = "class" },
				{ "d", desc = "digit(s)" },
				{ "e", desc = "CamelCase / snake_case" },
				{ "f", desc = "function" },
				{ "g", desc = "entire file" },
				{ "i", desc = "indent" },
				{ "o", desc = "block, conditional, loop" },
				{ "q", desc = "quote `\"'" },
				{ "t", desc = "tag" },
				{ "u", desc = "use/call" },
				{ "{", desc = "{} block" },
				{ "}", desc = "{} with ws" },
			}

			local ret = { mode = { "o", "x" } }
			---@type table<string, string>
			local mappings = vim.tbl_extend("force", {}, {
				around = "a",
				inside = "i",
				around_next = "an",
				inside_next = "in",
				around_last = "al",
				inside_last = "il",
			}, opts.mappings or {})
			mappings.goto_left = nil
			mappings.goto_right = nil

			for name, prefix in pairs(mappings) do
				name = name:gsub("^around_", ""):gsub("^inside_", "")
				ret[#ret + 1] = { prefix, group = name }
				for _, obj in ipairs(objects) do
					local desc = obj.desc
					if prefix:sub(1, 1) == "i" then
						desc = desc:gsub(" with ws", "")
					end
					ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
				end
			end
			require("which-key").add(ret, { notify = false })
		end,
	},
	{
		"echasnovski/mini.surround",
		recommended = true,
		keys = function(_, keys)
			local mappings = {
				{ "gsa", desc = "Add Surrounding", mode = { "n", "v" } },
				{ "gsd", desc = "Delete Surrounding" },
				{ "gsf", desc = "Find Right Surrounding" },
				{ "gsF", desc = "Find Left Surrounding" },
				{ "gsh", desc = "Highlight Surrounding" },
				{ "gsr", desc = "Replace Surrounding" },
				{ "gsn", desc = "Update `MiniSurround.config.n_lines`" },
			}
			mappings = vim.tbl_filter(function(m)
				return m[1] and #m[1] > 0
			end, mappings)
			return vim.list_extend(mappings, keys)
		end,
		opts = {
			mappings = {
				add = "gsa", -- Add surrounding in Normal and Visual modes
				delete = "gsd", -- Delete surrounding
				find = "gsf", -- Find surrounding (to the right)
				find_left = "gsF", -- Find surrounding (to the left)
				highlight = "gsh", -- Highlight surrounding
				replace = "gsr", -- Replace surrounding
				update_n_lines = "gsn", -- Update `n_lines`
			},
		},
	},
}
