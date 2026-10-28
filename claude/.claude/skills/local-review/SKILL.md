---
name: local-review
description: Review and fix local work before any PR exists, committing fixes locally and handing back what's left. Never pushes or touches GitHub. Triggers when the user asks to "review my changes locally", "local review", or wants work cleaned up before opening a PR.
---

# Local review

Gets a branch into better shape before anyone else sees it. Fixes land as local commits for the user to read, squash, and push themselves; the run ends at a hand-back, with the PR still unopened.

This skill finds the targets and launches one [`local-review-coordinator`](../../agents/local-review-coordinator.md) per target. The coordinator commits the user's work and runs the review loop in a fresh context, so this session never re-reads its own history on every review turn.

## 1. Resolve the targets

The current directory is a hint. List the worktrees holding work and pick the targets:

```bash
~/.claude/scripts/worktree-targets    # REPO, DEFAULT, then per target: path ($WT), branch ($BRANCH), ahead, dirty, pr, base
```

Zero targets → say so and stop. One → proceed. Several → honour the ones the user named, or all of them when they said so; otherwise list them and ask.

## 2. Launch one coordinator per target

Launch every target's `local-review-coordinator` in one message, in the background, briefed as its description lists.

The coordinator starts without this conversation. When it knows something the commits don't (why the change is shaped the way it is, a trade-off already settled with the user), add it in one or two sentences: triage judges findings against it.

## 3. Relay the hand-backs

Relay each hand-back as returned, labelled with its target; **every dismissal** stays listed with its reason, never summarized or merged across targets. The user reads the commits and decides what to push.

A target that stopped for a human: put its blocker to the user. Once they decide, send the decision to that coordinator with `SendMessage`; it resumes with its ledger intact.
