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

```bash
~/.claude/scripts/worktree-targets    # REPO, DEFAULT, then per target: path ($WT), branch ($BRANCH), ahead, dirty, pr, base
```

Rows whose PR is based on another row's branch form a **stack** (`-1`, `-2`, …), which is one
target. Then:

- **Zero targets** → say so and stop. Don't invent work.
- **Exactly one** → ship it without asking.
- **More than one** → if the user named one (or said "all"), honour it. Otherwise list them
  (path, branch, commit subjects, PR if one exists) and ask which to ship. Never guess.

## 2. Launch one coordinator per target

Launch every target's `ship-pr-coordinator` in one message, in the background, briefed as its
description lists, with step 0's overrides.

The coordinator starts without this conversation. When it knows something the commits and PR
body don't (why the change is shaped the way it is, a trade-off already settled with the user),
add it in one or two sentences: triage judges comments against it.

## 3. Relay the reports

Each coordinator hands back one report per PR. Relay each as returned, labelled with its target;
**every dismissal** stays listed with its reason, never summarized or merged across targets.

A target that stopped for a human: put its blocker to the user. Once they decide, send the
decision to that coordinator with `SendMessage`; it resumes with its ledger intact.
