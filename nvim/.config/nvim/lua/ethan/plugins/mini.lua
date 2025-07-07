local M = {}
-- Mini.ai indent text object
-- For "a", it will include the non-whitespace line surrounding the indent block.
-- "a" is line-wise, "i" is character-wise.
function M.ai_indent(ai_type)
	local spaces = (" "):rep(vim.o.tabstop)
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local indents = {} ---@type {line: number, indent: number, text: string}[]

	for l, line in ipairs(lines) do
		if not line:find("^%s*$") then
			indents[#indents + 1] = { line = l, indent = #line:gsub("\t", spaces):match("^%s*"), text = line }
		end
	end

	local ret = {} ---@type (Mini.ai.region | {indent: number})[]

	for i = 1, #indents do
		if i == 1 or indents[i - 1].indent < indents[i].indent then
			local from, to = i, i
			for j = i + 1, #indents do
				if indents[j].indent < indents[i].indent then
					break
				end
				to = j
			end
			from = ai_type == "a" and from > 1 and from - 1 or from
			to = ai_type == "a" and to < #indents and to + 1 or to
			ret[#ret + 1] = {
				indent = indents[i].indent,
				from = { line = indents[from].line, col = ai_type == "a" and 1 or indents[from].indent + 1 },
				to = { line = indents[to].line, col = #indents[to].text },
			}
		end
	end

	return ret
end

-- taken from MiniExtra.gen_ai_spec.buffer
function M.ai_buffer(ai_type)
	local start_line, end_line = 1, vim.fn.line("$")
	if ai_type == "i" then
		-- Skip first and last blank lines for `i` textobject
		local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
		-- Do nothing for buffer with all blanks
		if first_nonblank == 0 or last_nonblank == 0 then
			return { from = { line = start_line, col = 1 } }
		end
		start_line, end_line = first_nonblank, last_nonblank
	end

	local to_col = math.max(vim.fn.getline(end_line):len(), 1)
	return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
end

-- register all text objects with which-key
---@param opts table
function M.ai_whichkey(opts)
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
end

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
	-- { "echasnovski/mini.indentscope", version = false, setup = true },
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
					o = ai.gen_spec.treesitter({ -- code block
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}),
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
					t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
					d = { "%f[%d]%d+" }, -- digits
					e = { -- Word with case
						{
							"%u[%l%d]+%f[^%l%d]",
							"%f[%S][%l%d]+%f[^%l%d]",
							"%f[%P][%l%d]+%f[^%l%d]",
							"^[%l%d]+%f[^%l%d]",
						},
						"^().*()$",
					},
					i = M.ai_indent, -- indent
					g = M.ai_buffer, -- buffer
					u = ai.gen_spec.function_call(), -- u for "Usage"
					U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
				},
			}
		end,
		config = function(_, opts)
			require("mini.ai").setup(opts)
			M.ai_whichkey(opts)
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
