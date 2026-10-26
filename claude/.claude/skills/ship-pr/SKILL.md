---
name: ship-pr
description: End-to-end PR pipeline — resolve which worktree(s) hold the work, open the PR, run a local review while waiting for Copilot's, triage every comment, wait for CI, then squash-merge. Handles several worktrees/PRs in one session. Triggers when the user asks to "ship this PR", "ship-pr", "open a PR and merge it", "take this all the way to merge", or otherwise wants the open→review→resolve→merge loop run unattended.
---

# Ship a PR (resolve targets → launch coordinators → relay)

Takes every ship target from unopened change to merged PR. This skill finds the targets and
launches one [`ship-pr-coordinator`](../../agents/ship-pr-coordinator.md) agent per target; the
coordinator does the shipping (open, review, fix, CI, merge) in a fresh context, so the session
that wrote the code never re-reads its own history on every shipping turn.

Default behaviour is **fully unattended**: open, review, resolve, squash-merge with no check-ins.
A target stops early only when it **needs a human**, or when the user said not to merge.

## 0. Read the invocation for overrides

These pass through to the coordinator's brief:

- **"…but don't merge" / "just get it green"** → every step except the final merge.
- **A named merge method** ("rebase merge", "merge commit") → that method instead of squash.
- **"PR is already open" / a PR number or URL** → the PR number, so it skips opening.
- **"skip the local review" / "Copilot only"** → no local review in round 1.
- **An issue** ("ship #1186", a pasted issue URL) → the issue number, so the merge closes it.
- **A named branch, worktree, or "all of them"** → feeds step 1's target selection.

## 1. Resolve the targets — do this first, always

**Never assume the current directory is where the work is.** A session frequently starts in the
main checkout while the actual change lives in a `wt` worktree created mid-session, and more
than one may be in flight at once.

Establish the repo-wide facts, then enumerate:

```bash
REPO=$(git -C "$PWD" remote get-url origin | sed -E 's#(git@|https://)github\.com[:/]##; s#\.git$##')
DEFAULT=$(gh repo view "$REPO" --json defaultBranchRef --jq .defaultBranchRef.name)  # positional: `repo view` has no -R
wt list 2>/dev/null || git worktree list           # every worktree of this repo
```

For each candidate path `$WT`:

```bash
git -C "$WT" branch --show-current                 # branch (empty ⇒ detached HEAD)
git -C "$WT" status --porcelain                    # uncommitted work
git -C "$WT" log --oneline "origin/$DEFAULT..HEAD" # commits not on the default branch
gh pr list -R "$REPO" --head "<branch>" --json number,baseRefName   # open PR, and what it's based on
```

A candidate is a **ship target** if it is not the default branch **and** has commits ahead of
the default branch or uncommitted changes. A **stack** (PRs based on one another, `-1`, `-2`, …)
is one target. Then:

- **Zero targets** → say so and stop. Don't invent work.
- **Exactly one** → ship it without asking.
- **More than one** → if the user named one (or said "all"), honour it. Otherwise list them
  (path, branch, commit subjects, PR if one exists) and ask which to ship. Never guess.

`$DEFAULT` is looked up, never hardcoded to `main`, and never taken from `origin/HEAD` — that's
unset in plenty of clones.

## 2. Launch one coordinator per target

Launch every target's `ship-pr-coordinator` in one message, in the background. Each brief
carries `$REPO`, `$DEFAULT`, `$WT`, `$BRANCH`, the PR number if one is open (for a stack: every
PR, bottom first, with its worktree), the issue number, and step 0's overrides.

The coordinator starts without this conversation. When it knows something the commits and PR
body don't (why the change is shaped the way it is, a trade-off already settled with the user),
add it in one or two sentences: triage judges comments against it.

## 3. Relay the reports

Each coordinator hands back one report per PR. Relay each as returned, labelled with its target;
**every dismissal** stays listed with its reason, never summarized or merged across targets.

A target that stopped for a human: put its blocker to the user. Once they decide, send the
decision to that coordinator with `SendMessage`; it resumes with its ledger intact.
