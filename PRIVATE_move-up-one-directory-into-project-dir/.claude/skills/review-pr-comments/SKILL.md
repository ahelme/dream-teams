---
name: review-pr-comments
description: Review all automated comments and findings on a PR — security scanners, Claude ultrareview, error tracker, linters. Triage, resolve conversations, report to user. Use after PR checks complete, or when re-checking after fixes.
user-invocable: true
version: 1.1.0
---

# /review-pr-comments — Review PR Findings & Conversations

## Why this matters

Automated reviewers (e.g. Semgrep, Claude ultrareview, Sentry, ruff) leave findings, comments, and conversations on PRs. Ignoring them creates tech debt and security risk. This skill is the discipline step — treat it as a real task, not optional cleanup.

**Note on review scope:** Testing PRs (`/pr-test`) get automated scanners only — no Claude ultrareview (fast iteration). Prod PRs (`/pr-prod`) get ultrareview when the user pastes `@claude ultrareview` as a PR comment.

## Usage

`/review-pr-comments <PR#>` — review all automated findings on a PR.

## Step 1 — Gather all findings

```bash
# PR status checks (scanners, linters, etc.)
gh pr checks <PR#> --repo [ OWNER/REPO ]

# PR review comments (Claude ultrareview, error tracker)
gh api repos/[ OWNER/REPO ]/pulls/<PR#>/comments --jq '.[] | {user: .user.login, body: .body[:200], path: .path, line: .line, state: .state}'

# PR issue-style comments
gh api repos/[ OWNER/REPO ]/issues/<PR#>/comments --jq '.[] | {user: .author.login, body: .body[:200]}'
```

## Step 2 — Categorise each finding

| Source | What to look for |
|--------|-----------------|
| **Security scanner (e.g. Semgrep)** | Security findings in status checks — triage each one |
| **Claude ultrareview** (prod PRs only) | User-triggered via `@claude ultrareview` comment — thorough code review, suggestions, questions |
| **Error tracker (e.g. Sentry)** | Runtime errors linked to changed code |
| **Linter (e.g. ruff)** | Lint failures — must pass before merge |

## Step 3 — For each finding, decide

| Decision | Action |
|----------|--------|
| **Agree + quick fix** | Fix it, push, add PR comment explaining the fix |
| **Agree + complex** | Create issue via `/gi`, note on PR that it's tracked |
| **Disagree / false positive** | Reply to the comment explaining why, then resolve the conversation |
| **Already fixed** | Reply confirming the fix, resolve the conversation |
| **Not actionable** (vendor code etc.) | Reply noting it's not actionable and why, resolve |

## Step 4 — Resolve conversations

Conversations left unresolved block the "all conversations resolved" merge requirement (if enabled) and create noise for future reviewers.

**Before resolving a conversation, check:**
- Has the finding been addressed (fixed, issue created, or explained)?
- If the finding was a question — has it been answered?
- Would a future reader need this conversation open for context?

**To resolve via CLI:**
```bash
# List unresolved review threads
gh api graphql -f query='{ repository(owner: "[ OWNER ]", name: "[ REPO ]") { pullRequest(number: <PR#>) { reviewThreads(first: 50) { nodes { isResolved comments(first: 1) { nodes { body author { login } } } } } } } }' --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | .comments.nodes[0] | "\(.author.login): \(.body[:100])"'
```

If CLI resolution is not available, note which conversations need resolving and ask the user to resolve them in the GitHub UI.

## Step 5 — Report to user

Present a summary:

```
PR #<number> Review Summary:

| Source | Findings | Resolved | Action Taken |
|--------|----------|----------|-------------|
| Semgrep | 3 | 2 fixed, 1 issue #xyz | triaged |
| Claude ultrareview | 1 suggestion | 1 resolved | Applied suggestion |
| ruff | passing | - | - |

Unresolved conversations: 0 (or list what needs human resolution)
```

## When to run this

- After `/pr-test` or `/pr-prod` — once checks complete (~3 min)
- After pushing fixes to an existing PR — re-check new comments
- When asked to review another team's PR
- Before requesting merge — final check that everything is clean
