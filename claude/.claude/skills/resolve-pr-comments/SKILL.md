---
name: resolve-pr-comments
description: Triage every comment on one PR into fix / dismiss-as-irrelevant / escalate — apply the fixes as a fresh commit, reply and resolve threads, and report the dismissals. Bot comments may be dismissed with a stated reason; human comments may only be escalated. Triggers when the user asks to "resolve the PR comments", "address Copilot's review", "handle the review feedback", or names a PR with outstanding comments. Also invoked by ship-pr as its triage step.
---

# Resolve PR comments

Handles **one PR** end to end at the comment level: collect every surface, sort each item into
exactly one bucket, act, reply, resolve, report. Knows nothing about other PRs in flight — a
caller shipping several runs this once per PR.

Invoked directly, or by [`ship-pr-coordinator`](../../agents/ship-pr-coordinator.md) as step 3a.

## 1. Resolve the PR and its worktree

Take the PR number from the invocation. If the user didn't name one, find it from the current
branch — and if that's the default branch, list the session's open PRs and ask rather than
guessing.

Once you have the PR, its worktree is **derivable** — no discovery heuristics needed:

```bash
REPO=$(git -C "$PWD" remote get-url origin | sed -E 's#(git@|https://)github\.com[:/]##; s#\.git$##')
BRANCH=$(gh pr view <pr> -R "$REPO" --json headRefName --jq .headRefName)
WT=$(git worktree list --porcelain | awk -v b="refs/heads/$BRANCH" '
  /^worktree /{p=$2} $0=="branch "b{print p}')
```

If no worktree holds that branch, check one out before touching code — never apply fixes in a
worktree that isn't on the PR's head branch. Pin everything after this: `git -C "$WT"`,
`gh -R "$REPO"` with the explicit PR number. A bare `gh pr view` reads cwd and will silently
address the wrong PR.

## 2. Collect every surface

Three GitHub surfaces, and they don't overlap — missing one silently drops comments:

```bash
gh api "repos/$REPO/pulls/<pr>/reviews"   --paginate --jq '.[] | {id, user: .user.login, state, body}'
gh api "repos/$REPO/pulls/<pr>/comments"  --paginate --jq '.[] | {id, user: .user.login, path, line: (.line // .original_line), in_reply_to_id, body}'
gh api "repos/$REPO/issues/<pr>/comments" --paginate --jq '.[] | {id, user: .user.login, body}'
```

The `--jq` filters keep the raw payloads (diff hunks, URLs, reactions) out of context; read the
file at `path:line` when a comment needs its surroundings.

A caller may also hand you **local review findings** (from `/code-review` or review subagents).
Triage those in the same three buckets, but they have no GitHub thread — never reply to or
resolve them, just fix and report.

Get the thread IDs and resolution state up front so you know what's already handled:

```bash
gh api graphql -f query='
  query($owner:String!,$repo:String!,$pr:Int!){ repository(owner:$owner,name:$repo){
    pullRequest(number:$pr){ reviewThreads(first:100){ nodes{
      id isResolved isOutdated comments(first:1){nodes{author{login} path line body}} }}}}}' \
  -F owner="${REPO%%/*}" -F repo="${REPO##*/}" -F pr=<pr>
```

Skip threads already `isResolved`. An `isOutdated` thread on code the diff has since replaced is
usually a dismissal ("the line this refers to no longer exists"), not a fix.

## 3. Sort each item into exactly one bucket

### Fix

The comment is right, or right enough that acting is cheaper than arguing. Apply the change in
`$WT`, reply on the thread saying what you changed, and resolve it.

Batch all the fixes into **one fresh commit** on top (never an amend) and push once. A dozen
one-line fix commits is noise; so is a force-push that rewrites the tip Copilot reviewed.

Inside `ship-pr-coordinator`, whose tools cannot edit files, the batch goes through its
*Delegating a fix* section, which ends in that same single commit and push.

### Dismiss — not relevant

You are trusted to judge this. Dismiss when you can state a concrete reason from one of these:

- **Factually wrong about the code** — cite the line that disproves it.
- **Out of scope** — pre-existing behaviour, or an unrelated file the diff merely touched.
- **Contradicts a repo convention** — cite the rule file or the surrounding pattern.
- **Already handled** — point at where in the diff.
- **Stale** — the thread is outdated against code the diff replaced.

Then reply on the thread with that reason in one or two sentences, resolve it, and record it for
the report. The reply is public and stands on its own — no hedging, no "the agent thinks".

**Never dismiss** on these grounds, ever: it's inconvenient, it's a large refactor, you're
unsure whether it's right, or you couldn't verify it. Uncertainty is an escalation, not a
dismissal.

**A bot's comment may be dismissed; a human's may not.** Copilot, linters, and review bots are
fair game. Anything from a human reviewer goes to *escalate* even when you're confident it's
wrong — reply with your reasoning, leave the thread open, and let them close it. The user can
override per-PR ("dismiss whatever you're sure about").

### Escalate

A product or design decision, a comment whose correctness you can't determine, a real problem
better handled in a follow-up, or any human comment you disagree with. Reply if you have
something useful to say, and **leave the thread unresolved**.

An escalation is a **blocking** outcome: report it and let the user decide. A caller must not
merge over it.

## 4. Reply and resolve

```bash
# Reply to an inline comment thread
gh api "repos/$REPO/pulls/<pr>/comments/<comment_id>/replies" -f body='…'

# Reply to a review-body or conversation comment (no thread to nest under)
gh pr comment <pr> -R "$REPO" --body '…'

# Resolve a thread
gh api graphql -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' \
  -F id=<thread-id>
```

**Copilot reviews only once per PR** — it does not re-review the fix commits — so one invocation
is **one round of GitHub comments**. Don't wait for a second review that will never come.

That's a bound on waiting, not on being called again: a caller running a review loop
(`ship-pr-coordinator` step 3) invokes this repeatedly, each time with fresh **local** findings
against the commit the previous round pushed. Treat each invocation as its own round — collect
the GitHub surfaces again (a human may have commented meanwhile) and triage the supplied findings
alongside them.

## 5. Report

Tallies for `fixed` / `dismissed` / `escalated` (plus local findings fixed, if a caller supplied
any), then:

- **Every dismissal, listed individually with its one-line reason.** That list is the audit trail
  for the judgment calls you were trusted with — it never gets summarized away.
- **Every escalation**, with what you need from the user to proceed.

## Hard rules

- **Never amend or force-push a pushed commit.** Fixes land as a fresh commit on top. A
  non-fast-forward rejection means this rule was broken — recover with
  `git reset --soft origin/<branch>` and redo.
- **Never dismiss a human's comment**, and never dismiss anything you couldn't verify.
- **Never resolve a thread you escalated.** Leaving it open is the signal.
- **Never apply fixes in a worktree that isn't on the PR's head branch.**
- **Never invent a review state.** Poll the real API.
- **No AI attribution anywhere** — not in commit messages or thread replies. The work is the
  user's.
