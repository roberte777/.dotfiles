# GitHub comments

How ship mode reads and answers a PR's comments. Mechanics only: `~/.claude/review-loop/triage.md` decides what each comment means.

Pin every command to the PR: `-R "$REPO"` and its number.

## Copilot's review

Copilot is attached by the repo's settings, posts a minute or two after the PR opens, and reviews **once**: it never sees the fix commits. Wait for it in round 1 with one command, capped at five minutes; silence at the cap counts as a clean review, since it often stays silent on trivial diffs:

```bash
for i in $(seq 1 10); do
  gh api "repos/$REPO/pulls/<pr>/reviews" --paginate \
    --jq '.[] | select(.user.login | test("[Cc]opilot")) | .state' | grep -q . && { echo reviewed; break; }
  [ "$i" -eq 10 ] && echo "silent after 5 min" || sleep 30
done
```

## Collect

Comments live on three surfaces that don't overlap. Collect all three every round, and once more before the merge, since a person can comment at any time:

```bash
gh api "repos/$REPO/pulls/<pr>/reviews"   --paginate --jq '.[] | {id, user: .user.login, state, body}'
gh api "repos/$REPO/pulls/<pr>/comments"  --paginate --jq '.[] | {id, user: .user.login, path, line: (.line // .original_line), in_reply_to_id, body}'
gh api "repos/$REPO/issues/<pr>/comments" --paginate --jq '.[] | {id, user: .user.login, body}'
```

The `--jq` filters keep diff hunks, URLs and reactions out of your context; read the file at `path:line` when a comment needs its surroundings.

Thread ids and state:

```bash
gh api graphql -f query='
  query($owner:String!,$repo:String!,$pr:Int!){ repository(owner:$owner,name:$repo){
    pullRequest(number:$pr){ reviewThreads(first:100){ nodes{
      id isResolved isOutdated comments(first:1){nodes{author{login} path line body}} }}}}}' \
  -F owner="${REPO%%/*}" -F repo="${REPO##*/}" -F pr=<pr>
```

A resolved thread is already handled; skip it. An `isOutdated` thread on code a later commit replaced is stale.

## Answer

Answer each comment the round triaged. Every reply is public and stands on its own.

| Bucket | Reply | Thread |
|---|---|---|
| fix | the commit SHA alone | resolve |
| dismiss, follow-up | the reason, in one or two sentences | resolve |
| escalate | your reasoning, when you have something useful to say | leave open: the open thread is the signal |

```bash
# Reply to an inline comment thread
gh api "repos/$REPO/pulls/<pr>/comments/<comment_id>/replies" -f body='…'

# Reply to a review body or conversation comment, which has no thread
gh pr comment <pr> -R "$REPO" --body '…'

# Resolve a thread
gh api graphql -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' \
  -F id=<thread-id>
```

Replies carry no AI attribution; the work is the user's.
