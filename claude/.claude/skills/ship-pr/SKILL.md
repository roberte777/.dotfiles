---
name: ship-pr
description: End-to-end PR pipeline — resolve which worktree(s) hold the work, open the PR, run a local review while waiting for Copilot's, triage every comment, wait for CI, then squash-merge. Handles several worktrees/PRs in one session. Triggers when the user asks to "ship this PR", "ship-pr", "open a PR and merge it", "take this all the way to merge", or otherwise wants the open→review→resolve→merge loop run unattended.
---

# Ship a PR (resolve context → open → review → resolve → CI → merge)

Conductor for the whole path from unopened change to merged PR, across **one or more** worktrees
in a single session. It delegates the real work to [`open-pr`](../open-pr/SKILL.md) and
[`resolve-pr-comments`](../resolve-pr-comments/SKILL.md) and never re-implements their logic —
read both before running so their hard rules carry through here.

Default behaviour is **fully unattended**: open, review, resolve, squash-merge with no check-ins.
Stop early only when a step **needs a human** — an escalated comment, a red check that isn't
auto-recoverable — or when the user said not to merge.

## 0. Read the invocation for overrides

- **"…but don't merge" / "just get it green"** → run every step except the final merge.
- **A named merge method** ("rebase merge", "merge commit") → use it instead of squash.
- **"PR is already open" / a PR number or URL** → skip step 2 for that target.
- **"skip the local review" / "Copilot only"** → drop step 3b.
- **A named branch, worktree, or "all of them"** → feeds step 1's target selection.

## 1. Resolve the targets — do this first, always

**Never assume the current directory is where the work is.** A session frequently starts in the
main checkout while the actual change lives in a `wt` worktree created mid-session, and more
than one may be in flight at once.

Establish the repo-wide facts, then enumerate:

```bash
REPO=$(git -C "$PWD" remote get-url origin | sed -E 's#(git@|https://)github\.com[:/]##; s#\.git$##')
DEFAULT=$(gh repo view -R "$REPO" --json defaultBranchRef --jq .defaultBranchRef.name)
wt list 2>/dev/null || git worktree list           # every worktree of this repo
```

For each candidate path `$WT`:

```bash
git -C "$WT" branch --show-current                 # branch (empty ⇒ detached HEAD)
git -C "$WT" status --porcelain                    # uncommitted work
git -C "$WT" log --oneline "origin/$DEFAULT..HEAD" # commits not on the default branch
```

A candidate is a **ship target** if it is not the default branch **and** has commits ahead of
the default branch or uncommitted changes. Then:

- **Zero targets** → say so and stop. Don't invent work.
- **Exactly one** → ship it without asking.
- **More than one** → if the user named one (or said "all"), honour it. Otherwise list them
  (path, branch, commit subjects, PR if one exists) and ask which to ship. Never guess.

`$DEFAULT` is looked up, never hardcoded to `main`, and never taken from `origin/HEAD` — that's
unset in plenty of clones.

### The target ledger

Open a ledger per target — `$WT`, `$BRANCH`, PR number, comment tallies, CI verdict, end state,
plus the two fields step 4's loop runs on: `$REVIEWED` (the last sha the local review covered)
and the round count — and carry each target through steps 2–6 **independently**. Two rules:

- **Interleave.** The waits are the slow part, so while target A blocks on Copilot or CI,
  advance target B. Don't run the pipeline strictly serially.
- **Never let one target's state leak into another's.** Every command carries its own `$WT` /
  PR number; every report line names its target.

Pin everything: `git -C "$WT"`, `gh -R "$REPO"` with an explicit PR number or `--head "$BRANCH"`.
A bare `gh pr view` reads cwd and will silently address the wrong PR.

## 2. Open the PR

Invoke **`open-pr`** for the target, handing it the resolved `$WT` / `$BRANCH` / `$REPO` so it
skips its own discovery. It commits, pushes, composes title/body from the repo template, sets
the issue-closing keyword, assigns you, and adds gating labels. Do not duplicate its steps here.

Skip for a target that already has an open PR. Record the PR number and URL in the ledger.

**Issue-closing keyword.** When ship-pr was invoked *for an issue* ("ship #1186", a pasted issue
URL), confirm `open-pr` put `Closes #<n>` in the body before moving on — that's what makes
step 6's merge auto-close it. Add it with `gh pr edit <pr> -R "$REPO" --body …` if it's missing.

## 3. Review — Copilot and local, in parallel

Start 3a and 3b together; they're independent and both gate step 4.

### 3a. Wait for Copilot

Copilot posts a minute or two after open and **reviews only once per PR** — it does not
re-review later pushes, so this wait applies to the first review only.

```bash
gh api "repos/$REPO/pulls/<pr>/reviews" --paginate \
  --jq '.[] | select(.user.login | test("[Cc]opilot")) | {state, sha: .commit_id, submitted_at}'
```

Poll every 30–60s. The review has landed once any Copilot review exists. If ~5 minutes pass with
nothing (it often stays silent on trivial diffs), treat it as **clean** and move on — don't block
forever.

### 3b. Run the local review — round 1

This is the point of the extra pass: catch what Copilot won't. It is also the **only** review that
runs more than once — Copilot reviews at open and never again, so from here on 3b is what looks at
every commit the pipeline pushes. Round 1 reviews **the PR's full diff against the default
branch**, not just the last commit; step 4's later rounds review only their own increment.

- Prefer the built-in `/code-review` (Skill tool) scoped to `$WT`. **Never** invoke
  `/code-review ultra` — that variant is user-triggered and billed, and can't be launched by an
  agent.
- If it's unavailable, fan out review subagents over the diff, one per dimension, and merge
  their findings: **correctness** (logic, edge cases, error paths), **tests** (does the new logic
  have coverage at the lowest applicable level), **conventions** (the repo's CLAUDE.md and
  `.claude/rules/`), and **security** if the diff touches auth, uploads, or user input.
- Each finding needs a file:line anchor and a concrete failure scenario. A finding that can't
  name how it breaks is speculation — drop it before triage.

Hand the surviving findings to step 4 as extra input; they have no GitHub thread, so they get
fixed and reported but never replied to or resolved. Record the reviewed tip in the ledger —
`REVIEWED=$(git -C "$WT" rev-parse HEAD)` — so step 4 knows where its increment starts.

## 4. The fix loop — triage → fix → re-review

Steps 4 and 5 are **one loop**, not two straight-line steps. Every round pushes a fix commit, and
a commit that changes behaviour gets reviewed before anything lands on top of it. Round 1's input
is Copilot's review plus 3b's findings.

**a. Triage.** Invoke **`resolve-pr-comments`** against the PR, passing that round's local
findings alongside it. It collects all three GitHub surfaces, sorts each item into
fix / dismiss / escalate, applies the fixes as one fresh commit, replies and resolves, and reports
the tallies. Do not duplicate its triage rules here — in particular its bot-may-be-dismissed /
human-may-only-be-escalated rule.

- **Anything escalated** → **stop this target** and hand back its summary. Do **not** merge, even
  in unattended mode — an open escalation is the user's call. Other targets continue.
- **Nothing to triage** — no comments, no findings — → the loop has converged; go to step 5.

**b. Re-review the round's commit.** The round just pushed code nothing has reviewed. Copilot
won't look at it, so without this pass the fixes ship on CI alone — and triage commits are exactly
where that bites, since a finding that says "this error path is wrong" is answered by new logic,
not a typo fix. Re-run 3b scoped to the increment:

```bash
git -C "$WT" diff "$REVIEWED..HEAD" --stat     # what this round changed
git -C "$WT" diff "$REVIEWED..HEAD"            # the review scope
```

Then advance `REVIEWED=$(git -C "$WT" rev-parse HEAD)`.

**Skip the re-review when the round's diff is formatting, comments, or generated output only** —
there is no behaviour there to get wrong, and a round spent reviewing `cargo fmt` output is a
round burned. Advance `$REVIEWED` anyway; the commit is still accounted for.

**c. Loop or exit.** New actionable findings → next round, with those findings as its input.
None → step 5.

### Making the loop terminate

It converges because each round's input is strictly what's new. Two rules keep that true:

- **Carry a findings ledger for the whole PR** — everything already fixed, dismissed, or
  escalated, keyed by its claim. A re-review never re-reports one of them. A dismissal stands for
  the life of the PR unless a later round actually touches the code it was about; re-raising a
  settled finding is how a loop oscillates instead of converging.
- **Review the increment, not the PR.** Round 1 is the only full-diff pass. Later rounds see one
  commit's diff, so the cost falls off per round rather than compounding.

**Bound: 3 rounds**, shared with step 5's CI fixes. If round 3 still surfaces actionable findings,
stop the target and surface what's open rather than looping — a fix that keeps generating findings
is a design problem, not a triage one.

## 5. Wait for CI

```bash
gh pr checks <pr> -R "$REPO" --watch --fail-fast
```

The **verdict** is this command's own exit status, so run it as the entire command, in the
background when the wait is long: the status the harness reports back is then gh's. Anything
chained after it (`; echo`, `| tail`, a log redirect) reports *its* success instead, and turns a
red run green. Green is both of:

- the watch exited `0`, and
- this listing is empty:

  ```bash
  gh pr checks <pr> -R "$REPO" | awk -F'\t' '$2=="fail" || $2=="pending"'
  ```

Anything else is red or unfinished; the same listing names the jobs to read.

- **A `SKIPPED` required check is not a pass** when the diff is in its scope — it means a gating
  label is missing. Add it (which re-triggers the workflow), then re-watch.
- **On a red check**, read the failure (`gh run view <run-id> -R "$REPO" --log-failed`). A
  genuine failure in this branch's code (fmt, clippy, a broken test) is real work: fix it as a
  fresh commit on top and push. **That commit re-enters the loop at 4b** — CI-driven code is
  unreviewed code like any other, and a test fixed by changing the assertion rather than the bug
  is precisely what the pass is for. It counts against the same 3-round bound, and a
  formatting-or-lint-autofix commit skips the re-review under 4b's own rule. Then re-watch. No
  Copilot re-review wait — it only reviews once. A plain flake or infra blip gets **one**
  `gh run rerun <run-id> -R "$REPO" --failed`; if it fails the same way again, stop and surface
  it. Never merge over red.

## 6. Merge and clean up

Merge when CI is green **and** step 4 escalated nothing **and** `$REVIEWED` equals the pushed tip
(`git -C "$WT" rev-parse HEAD` — every commit has been through a review round or was exempt under
4b) **and** the user didn't say not to:

```bash
gh pr merge <pr> -R "$REPO" --squash --delete-branch
```

Squash is the default (one commit per PR, matching the conventional-commit-title convention).
Use `--merge` / `--rebase` only if step 0 said so.

Then sync local state so the next change starts from the merged tip:

```bash
wt remove <branch>          # drop the merged worktree and its local branch
wt switch ^ && git pull     # default-branch worktree, updated
```

Do **not** remove a worktree while another target still needs it, and don't `wt switch` away
mid-pipeline — every other target's commands are pinned with `-C`, but the shell's cwd is shared.

**Confirm the issue closed** if the PR carried a `Closes #<n>`:

```bash
gh issue view <n> -R "$REPO" --json state --jq .state    # want: CLOSED
```

Still `OPEN` and the PR fully resolved it? Close it manually:

```bash
gh issue close <n> -R "$REPO" --comment "Shipped in #<pr> (merged to \`main\`). <one line on what landed>."
```

Leave it open for a `Part of #<n>` partial, and say so in the report.

## 7. Final report

One compact block **per target**: PR URL, end state (merged / stopped-before-merge / handed
back), and tallies for `fixed` / `dismissed` / `escalated` / `local findings fixed`. State the
**round count** and what each round after the first was reacting to (triage fixes, a CI failure) —
a PR that took three rounds to settle is worth knowing about even when it merged clean.

List **every dismissal** with its one-line reason — that list is the audit trail for the
judgment calls the pipeline was trusted with, so it never gets summarized away, and it doesn't
get merged across targets. If a target stopped early, state exactly what's blocking and what you
need to continue.

## Hard rules

- **Resolve the work context before anything else.** cwd is a hint, not the answer.
- **Never amend or force-push a pushed commit.** Every fix — review-driven or CI-driven — lands
  as a fresh commit on top. A non-fast-forward rejection means this rule was broken; recover with
  `git reset --soft origin/<branch>` and redo.
- **Never merge with an open escalation**, even in unattended mode.
- **Never merge over a red or falsely-skipped required check.**
- **Never merge a commit no review has seen.** Copilot reviews once, at open; every commit after
  that is covered by 4b's re-review or by its formatting-only exemption, and nothing else.
- **Never request Copilot as a reviewer** — it's auto-attached.
- **Never invent a review or CI state.** Poll the real API; on a timeout, follow the documented
  fallback and say you did.
- **No AI attribution anywhere** — not in commit messages, PR bodies, thread replies, or issue
  comments. The work is the user's.
