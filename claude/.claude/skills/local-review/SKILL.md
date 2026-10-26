---
name: local-review
description: Review and fix local work before any PR exists — a three-agent loop (orchestrator, reviewer, implementor) that commits fixes locally and hands back what's left. Never pushes or touches GitHub. Triggers when the user asks to "review my changes locally", "local review", or wants work cleaned up before opening a PR.
---

# Local review

Gets a branch into better shape before anyone else sees it. Fixes land as local commits for the user to read, squash, and push themselves; the run ends at a handoff, with the PR still unopened.

The loop lives in three agents (`~/.claude/agents/`): `local-review-orchestrator` decides, `local-review-reviewer` finds, `local-review-implementor` fixes. This skill resolves the target, commits the user's work, launches the orchestrator, and relays what it returns.

## 1. Resolve the target

The current directory is a hint. List the worktrees holding work and pick the target:

```bash
~/.claude/scripts/worktree-targets    # REPO, DEFAULT, then per target: path ($WT), branch ($BRANCH), ahead, dirty, pr, base
```

Zero targets → say so and stop. One → proceed. Several → honour a named one, otherwise list them and ask.

## 2. Commit the user's work

Uncommitted changes in `$WT` become a commit before review, so the loop sees everything the PR would hold. Infer a conventional subject (`feat:`, `fix:`, `chore:`) from the diff; no WIP marker. Remember the subject for the handoff. A clean tree skips this step.

## 3. Launch the orchestrator

Spawn `local-review-orchestrator` (Agent tool, `subagent_type: local-review-orchestrator`), briefed as its description lists, with step 2's commit subject. It runs the whole loop and returns the handoff.

## 4. Relay the handoff

Pass the orchestrator's handoff to the user as returned: open findings first, then commits, fixed, dismissed. Add nothing; they read the commits and decide what to push.

## Boundaries

Everything stays on this machine: no `git push`, no `gh pr create`, no GitHub writes, no amends of any commit. Commits carry the change alone, with no AI attribution.
