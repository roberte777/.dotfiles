---
name: open-pr
description: Resolve which worktree holds the work, commit and push it, then open a well-formed GitHub PR — repo template, bullet-list body, issue-closing keyword, assignee, gating labels. Triggers when the user asks to "open a PR", "put this up", "push this and open a PR", or wants a PR created without merging it. Also invoked by ship-pr as its open step.
---

# Open a PR

Takes one worktree's work from unpushed (or uncommitted) to an open, well-formed PR. **Stops
there** — no review wait, no CI wait, no merge. Invoked directly, or by
[`ship-pr-coordinator`](../../agents/ship-pr-coordinator.md) as step 1.

## 1. Resolve the work context — do this first, always

**Never assume the current directory is where the work is.** A session frequently starts in the
main checkout and the actual change lives in a `wt` worktree created mid-session. Opening from
the wrong directory produces an empty PR or, worse, pushes the main checkout.

Skip this step if a caller already handed you a resolved `$WT` / `$BRANCH` / `$REPO`.

Establish the repo-wide facts once, from any worktree of it:

```bash
REPO=$(git -C "$PWD" remote get-url origin | sed -E 's#(git@|https://)github\.com[:/]##; s#\.git$##')
DEFAULT=$(gh repo view "$REPO" --json defaultBranchRef --jq .defaultBranchRef.name)  # positional: `repo view` has no -R
```

Don't hardcode `main` for `$DEFAULT`, and don't reach for `origin/HEAD` instead — it's unset in
plenty of clones. Then enumerate candidates:

```bash
wt list 2>/dev/null || git worktree list           # every worktree of this repo
```

For each candidate path `$WT`, gather the facts that decide whether it has shippable work:

```bash
git -C "$WT" branch --show-current                 # branch (empty ⇒ detached HEAD)
git -C "$WT" status --porcelain                    # uncommitted work
git -C "$WT" log --oneline "origin/$DEFAULT..HEAD" # commits not on the default branch
```

A candidate is a **target** if it is not the default branch **and** has commits ahead of the
default branch or uncommitted changes. Then:

- **Zero targets** → say so and stop. Don't invent work.
- **Exactly one** → that's the target; proceed without asking.
- **More than one** → if the user named one, honour it. Otherwise list them (path, branch,
  commit subjects, PR if one exists) and ask. Never guess.

Pin every later command to the resolved target — no `cd`, no cwd inference:

```bash
WT=~/worktrees/<repo>/<branch>
BRANCH=$(git -C "$WT" branch --show-current)
```

`git` takes `-C "$WT"`. `gh` takes `-R "$REPO"` plus an explicit PR number or `--head "$BRANCH"`
— a bare `gh pr view` reads the cwd and will silently address the wrong PR.

## 2. Already open?

```bash
gh pr list -R "$REPO" --head "$BRANCH" --json number,url,state
```

If an open PR exists, report it and stop — don't open a second one. If the branch has unpushed
commits, push them to that PR first (step 3), then report.

## 3. Commit and push

1. **Commit anything outstanding** in `$WT` with a conventional-commit subject (`feat:`, `fix:`,
   `chore:`). Match the repo's allowed prefixes — some repos enforce a narrow set via a
   `commit-msg` hook.
2. **Never amend or force-push a commit that is already on the remote.** New work goes on top.
3. **Push** — `git -C "$WT" push`. Upstream auto-sets on first push; never pass `--force`.

## 4. Compose the PR

- **Title** = the conventional-commit subject describing the whole change, not just the last
  commit.
- **Body** = fill the repo's template if `.github/PULL_REQUEST_TEMPLATE.md` exists, otherwise a
  plain summary. **Always a bullet list, never prose paragraphs** — including template sections
  that look like they want prose. Write each bullet as one continuous line; no hand-inserted
  line breaks, GitHub soft-wraps.
- **Closing keyword** — `Closes #<n>` when the PR fully resolves a tracked issue; `Part of #<n>`
  when it's one sub-task of a larger issue (a keyword there would wrongly close the parent).
  This is what makes a later merge auto-close the issue, so get it right at open time.
- **Stacked branches** — if this PR sits on another unmerged branch, target the parent with
  `--base <parent>`, never the default branch, and say the stack position in the body
  ("Stacked on #123 — 2 of 3").

## 5. Open it

```bash
gh pr create -R "$REPO" --head "$BRANCH" --assignee @me --title "…" --body "…"
```

- **Gating labels.** Some repos gate expensive checks behind a label, so the check reports
  `SKIPPED` unless it's present — and a skipped required check is **not** a pass. Check the
  repo's workflows and CLAUDE.md, and add what the diff needs (in omnibus, `run_ui_tests` for
  any diff touching rendered markup):

  ```bash
  gh pr edit <pr> -R "$REPO" --add-label <label>
  ```

- **Never request Copilot as a reviewer** — it's auto-attached by repo settings. No
  `--reviewer Copilot`, no `requested_reviewers` POST.

Report the PR number and URL. A caller records them; a direct invocation prints them.

## Hard rules

- **Resolve the work context before anything else.** cwd is a hint, not the answer.
- **Never amend or force-push a pushed commit.** A non-fast-forward rejection means this rule
  was broken — recover with `git reset --soft origin/<branch>` and redo.
- **Never open a second PR for a branch that already has one.**
- **Never request Copilot as a reviewer** — it's auto-attached.
- **No AI attribution anywhere** — not in commit messages, PR bodies, or issue comments. The
  work is the user's.
