local function git(root, ...)
	return vim.system({ "git", "-C", root, ... }, { text = true }):wait()
end

-- Resolve the repo's default branch: prefer origin/HEAD, fall back to common names.
local function default_branch()
	local root = vim.fs.root(0, ".git") or vim.uv.cwd()

	local head = git(root, "symbolic-ref", "--short", "refs/remotes/origin/HEAD")
	if head.code == 0 then
		return vim.trim(head.stdout)
	end

	for _, name in ipairs({ "main", "master", "develop" }) do
		if git(root, "rev-parse", "--verify", "--quiet", name).code == 0 then
			return name
		end
	end
end

-- Every mapping doubles as a toggle so views don't pile up in new tabs.
-- `cmd` may be a function returning nil to abort (it reports its own reason).
local function toggle(cmd)
	return function()
		if require("diffview.lib").get_current_view() then
			return vim.cmd.DiffviewClose()
		end
		local resolved = type(cmd) == "function" and cmd() or cmd
		if resolved then
			vim.cmd(resolved)
		end
	end
end

return {
	{
		"sindrets/diffview.nvim",
		cmd = {
			"DiffviewOpen",
			"DiffviewClose",
			"DiffviewFileHistory",
			"DiffviewFocusFiles",
			"DiffviewToggleFiles",
			"DiffviewRefresh",
		},
		opts = {
			enhanced_diff_hl = true,
			view = {
				merge_tool = {
					layout = "diff3_mixed",
					disable_diagnostics = true,
				},
			},
			keymaps = {
				view = {
					{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
				},
				file_panel = {
					{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
				},
				file_history_panel = {
					{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
				},
			},
		},
		keys = {
			{
				"<leader>gv",
				toggle("DiffviewOpen"),
				desc = "Diff Working Tree (Diffview)",
			},
			{
				"<leader>gm",
				toggle(function()
					local branch = default_branch()
					if not branch then
						vim.notify("Diffview: could not determine the default branch", vim.log.levels.WARN)
						return
					end
					return "DiffviewOpen " .. branch .. "...HEAD"
				end),
				desc = "Diff vs Default Branch (Diffview)",
			},
			{
				"<leader>gf",
				toggle("DiffviewFileHistory --follow %"),
				desc = "File History (Diffview)",
			},
			{
				"<leader>gf",
				":DiffviewFileHistory<CR>",
				mode = "v",
				desc = "Selection History (Diffview)",
			},
			{
				"<leader>gF",
				toggle("DiffviewFileHistory"),
				desc = "Repo History (Diffview)",
			},
		},
	},
}
