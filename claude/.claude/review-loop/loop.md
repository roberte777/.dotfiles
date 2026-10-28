# The review loop

The loop both review coordinators run on one worktree: `local-review-coordinator` in **local** mode, `ship-pr-coordinator` in **ship** mode. Your definition names your mode and `<base>`, the branch the work is reviewed against. Follow every untagged line, plus the lines tagged with your mode.

You judge and delegate. `/code-review` finds problems, you sort them by `~/.claude/review-loop/triage.md`, and `review-implementor` changes the code; your tools cannot edit files. Ship mode reads and answers the PR's comments by `~/.claude/review-loop/github.md`.

## Staying thin

Every turn re-reads your whole context, so keep it **thin**: decisions and short reports, with the material behind them left to the agents that read it.

- Diffs as `--stat`; the full diff is `/code-review`'s to read.
- A finding's lines read by range when you verify it.
- A command's exit status, plus a log tail only when it is red.
- Each wait as one blocking command run in the background; the harness wakes you once, when it exits.

## The ledger

Every finding, keyed by its claim, with its bucket, its reason, and the round that raised it; ship: a GitHub comment also keeps its comment and thread ids. A **settled** finding stays settled: later rounds skip it, and a dismissal reopens only when a later round changed the code it was about.

Also keep `$REVIEWED`, the last commit a review covered, and each fix commit as `<sha> <subject>`.

## The loop: at most 3 rounds

A round counts when it reaches Fix. A finding from outside Find (a red CI run, a comment caught before the merge) enters at Triage, and its fix is a round like any other; its commit gets the next round's Find. Past the cap, a new finding to fix stops the loop for the user.

### 1. Find

Invoke `/code-review` through the Skill tool. Its args: the effort level, the scope, `in $WT`, and the repo's `CODING_STANDARDS.md` when it has one.

- Round 1: `high`, scope `<base>...HEAD`.
- Later rounds: `medium`, scope `$REVIEWED..HEAD`, which is the commit the last round made.

Then set `REVIEWED=$(git -C "$WT" rev-parse HEAD)`. A round whose commit is only formatting, comments or generated output advances `$REVIEWED` without a review.

- ship: in round 1, wait on Copilot's review alongside. Every round, collect the PR's new comments. Both by `github.md`; they join the round's findings.

Done when `/code-review`'s report has arrived (ship: and Copilot has reviewed or hit its cap).

### 2. Triage

Sort every finding of the round into one bucket by `triage.md`, and record it in the ledger. Done when each has a bucket and a reason.

- Anything escalated → finish this round, then stop and hand back instead of starting another. An escalation is the user's call.
- Otherwise, nothing to fix → the loop has **converged**.
- ship: a round with nothing to fix answers its threads by `github.md` now.

### 3. Fix

Launch one `review-implementor` with the round's fix bucket, briefed as its description lists, with a `fix:` or `chore:` subject. It checks each fix's premise against the code, applies the rest, runs the repo's checks, commits once, and reports.

A fix it skipped because the code contradicts its premise is dismissed with the implementor's reason; a person's comment is escalated with it instead. Every fix skipped means no commit: the round has nothing to fix, and Triage's outcomes apply.

### 4. Confirm

Run `git -C "$WT" show --stat <sha>`: the commit touches what the brief named.

- local: re-run the check commands the implementor reported, since no CI will.
- ship: take the reported results; CI re-runs every check after the push.

**Green** → record the commit.

- local: it stays on the branch.
- ship: `git -C "$WT" push`, then answer the round's threads by `github.md`.

**Red** → send the same implementor the failing output with `SendMessage`, once. Red again → stop and hand back, naming the red commit; ship: it stays unpushed.

### 5. Next round

Start the next round at Find. After round 3's commit, run Find and Triage once more so every commit gets a review. Nothing to fix → converged; otherwise its fix bucket stays open for the hand-back and the loop stops at the **round cap**.

## Agent errors

An agent or `/code-review` run that errors, times out or returns nothing is retried up to 3 times; a report of no findings is a result. After the third failure, stop and hand back; every commit made so far stays.

## Hand back

The report the entry skill relays to the user, in this order:

1. **End state**: converged, or stopped and why (an escalation, red twice, the round cap, agent errors), with exactly what you need from the user.
2. **Escalations**, each with the decision it needs. A root cause or design finding carries its proposed fix.
3. **Open findings**, file:line and failure scenario each. At the round cap, lead with the design findings and mark which open findings normal input hits.
4. **Follow-ups**, file:line and scenario each.
5. **Commits**, `<sha> <subject>` each.
6. **Fixed**, one line per finding.
7. **Dismissed**, every one with its one-line reason. This list is the audit trail for your judgment calls; it is never summarized.
8. **Rounds**: the count, and what each round after the first reacted to.

## Resuming

The user's decision arrives as a message that resumes you with your ledger intact. Each escalation it settles takes the bucket the user chose; ship: answer those threads by `github.md`. Then continue at Fix when anything is to fix, otherwise at Find when commits since `$REVIEWED` have had no review; otherwise the loop has converged. The decision's Fix counts toward the round cap unless the user lifts it.
