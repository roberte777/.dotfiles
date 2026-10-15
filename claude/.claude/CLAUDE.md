- NEVER say "Co-authored by Claude" in commit messages. All work was done by the user.
- NEVER mention "Generated with Claude" in pull request descriptions. All work was done by the user.
- All work pushed to remote should have no references to Claude.
- **Worktrunk trial, started 2026-08-07.** The previous jj-based rules are preserved verbatim at `~/.claude/CLAUDE.md.jj-backup` — restore that file to revert.
- Always use git + worktrunk (`wt`) for all version control -- never use jj.
  - The `jj-basics`, `jj-advanced`, and `jj-workspaces` skills are PAUSED for the duration of the trial. Do not invoke them, even when a request would normally trigger one ("commit this", "push it up", "make a branch"). Use the commands below instead.
  - Many repos are still jj-colocated (they have both `.git/` and `.jj/`). Ignore `.jj/` entirely — do not run jj commands in them, and do not treat jj state as authoritative.
  - You should always check what's currently modified via `git status`
    - **Before ANY Edit/Write tool call, run `git status` and `git branch --show-current` first.** If you are on `main` (or any branch you don't intend to add commits to), create the branch *before* the first edit, not after.
    - **Never rewrite published history.** No `git commit --amend`, `git rebase`, or `git push --force` on a commit that has already been pushed. Add a new commit on top instead. This includes follow-up commits on a PR branch.
    - `git add .` and `git commit` only affect the current worktree — each worktree has its own index and HEAD. The stash, however, is shared across every worktree of a repo.
  - Use `git fetch origin` to get the latest changes.
  - Start any new piece of work with `wt switch --create <branch_name>` — this creates the branch and its worktree together and cds into it. Use `-b <base>` to base it on something other than the default branch.
    - `wt switch <branch>` returns to an existing worktree; bare `wt switch` opens a picker
    - `wt list` shows every worktree and its status
    - `wt remove` deletes the worktree, and the branch if it has been merged
    - Worktrees live at `~/worktrees/<repo>/<branch>`
    - A `pre-start` hook copies gitignored secrets into new worktrees, but only in repos that have a `.worktreeinclude`. If a new worktree is missing its `.env`, add `.worktreeinclude` to that repo rather than copying files by hand.
  - Commit with `git add .` then `git commit -m "<message>"`
  - Push with `git push`. `push.autoSetupRemote` is enabled globally, so the first push on a new branch sets the upstream automatically — do not pass `--set-upstream`, and never pass `--force`.
  - Refer to `wt --help`, `wt <command> --help`, or https://worktrunk.dev for more information
  - For parallel agent work, give each agent its own worktrunk worktree via `wt switch --create <branch>` rather than the Agent tool's `isolation: "worktree"`, so the worktrees show up in `wt list` and get cleaned up by `wt remove`.
  - **Never call the `EnterWorktree` tool.** It hardcodes `<repo>/.claude/worktrees/<name>` and a `claude/<name>` branch, which is outside worktrunk's layout and naming. Always `wt switch --create <branch>` instead. If a session *starts* inside `.claude/worktrees/` (the app's Claude Worktrees toggle), create the proper `wt` worktree and work there via absolute paths — `ExitWorktree` can't move a session the harness placed.
- **Starting new work — always begin in a fresh worktree, before touching any file.** When I ask you to work on something new (an issue, a bug, a feature):
  1. Look into the issue first — read the relevant code/issue and determine whether a code change is actually required. If none is, say so and stop; don't create a branch.
  2. Determine a branch name per the naming rules below (prompt me for a ticket; fall back to `u/ewilkes/<feature>` if there isn't one).
  3. **Immediately** run `wt switch -c <branch_name>` (`-c` is shorthand for `--create`) to create the branch + worktree, and do all the work there.
  4. Only then make the first Edit/Write. Never investigate-then-edit on `main`.
- Use branch naming patterns that match a ticket name. For example:
  - ADA-123/updates-some-setting
  - AAA-6721/refactor-launch
  - AE-90/more-tests
- **Work that comes from a GitHub issue uses the repo's own prefix plus the issue number** — issue #123 becomes `OMNI-123/<slug>` in `omnibus` and `DOT-123/<slug>` in `dot-files`.
  - The prefixes live in `~/.config/git/issue-prefixes` (`<repo name>  <PREFIX>`, one per line). Read that file rather than inventing a prefix, and add a row when a new repo starts tracking work in GitHub issues.
  - The number is *always* the GitHub issue number, so `DOT-123` means issue #123 and the PR body closes it with `Closes #123`.
  - A repo absent from that file has no GitHub prefix — use its Jira ticket, or the `u/ewilkes/<feature>` fallback.
  - Two global git hooks back this up: `pre-commit` rejects a commit whose branch carries a *different* repo's prefix, and `prepare-commit-msg` turns `DOT-123` into a `Refs: #123` trailer so the commit links to the issue. Unknown prefixes (Jira keys) pass through untouched.
- Prompt the user for a ticket when creating a branch.
  - No prompt is needed when the work is a GitHub issue — derive the branch from the repo prefix and the issue number.
  - If the user says there is no ticket, fallback to u/ewilkes/<feature> for the branch name
- Use conventional commits in all repositories by prefixing commits with `feat`, `fix`, or `chore`
- Break work into stacked branches when:
  - Work exceeds 500 lines across multiple files
  - Work has changed more than 20 files for various changes
  - Work can be meaningfully broken down into smaller PRs for better reviewability
- Stacked branches should be denoted so other developers can tell which one is the head of the train
  - The branch that everything is based off of should be `-1`
  - The next branch and the branch after that would be `-2` and `-3` respectively
  - As branches are code complete, the branches should be pushed up and follow @skills/open-pr/SKILL.md
- PR descriptions are **ALWAYS** a bullet point list — never prose paragraphs.
  - **Never insert your own line breaks.** Write each bullet as one continuous line and let it soft-wrap. Hard-wrapping mid-sentence to hit some column width renders as ragged text in the GitHub UI.
  - This applies to every section of the PR body, including template sections that look like they want prose.

@RTK.md
