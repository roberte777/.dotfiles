# Triage

The rules for sorting review findings, applied by the coordinator running the review loop (`~/.claude/review-loop/loop.md`) to every finding, whatever its source: `/code-review`, Copilot, a PR comment, a red CI run.

Verify each finding before sorting it: read the lines it names and trace its failure scenario through the code. Each finding lands in exactly one bucket, with its reason in the ledger.

## Fix

The finding is real and earns the fix, as one of:

- A bug whose **reach** is in scope. Reach is what input gets to the failure: **normal input** hits it (the input the change exists to handle, in the shapes real users and real data produce), or **any input** turns it into a security hole, a crash, or data loss.
- A small, correct cleanup inside the diff: a convention the repo states, reuse of an existing helper, a missing test for new logic, a typo.

## Follow-up

The finding is real, but only malformed or adversarial input reaches it, and the result is a wrong output rather than a security hole, crash or data loss. Record its scenario for the hand-back. A follow-up leaves the merge unblocked and spends no round.

## Dismiss

Dismiss with a concrete reason from this list:

- **Wrong about the code**: cite the line that disproves it.
- **No failure scenario**: a claimed bug that names no input or state that breaks it.
- **Out of scope**: pre-existing behaviour other than the PR's root cause, or an unrelated file the diff only touched.
- **Against a repo convention**: cite the rule file or the surrounding pattern.
- **Already handled**: point at where.
- **Stale**: about code a later commit replaced, including a GitHub thread marked outdated.

Effort and doubt are never reasons: a large refactor is a design finding, and a finding you can't verify is an escalation.

A **person's** comment is fixed or escalated, even when you are sure it is wrong, unless the invocation lets you dismiss a person's comments. Bot comments (Copilot, linters, review bots) and `/code-review`'s findings take any bucket.

## Escalate

The user decides these:

- A **design finding**: the code works, but a different shape solves the problem better, such as fixing a value once at its source instead of patching each place that reads it. Scope never rules one out.
- The PR's **root cause**: the pre-existing defect the PR's bug comes from. Fixing it at its source can replace the PR's own fix, so carry the proposed source fix into the escalation.
- A product decision.
- A finding whose correctness you can't determine.
- A person's comment you disagree with, with your reasoning.

An escalation blocks the merge until the user decides.

## No action

A comment that asks for nothing takes no bucket and gets no reply: an approval, a review's summary, a coverage or deploy report, and the replies the loop posted itself, which the ledger holds. Name a person's no-action comment in the hand-back.
