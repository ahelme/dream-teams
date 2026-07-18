---
name: review-pr-comments
description: Review all automated comments and findings on a PR — Semgrep, Claude ultrareview, Sentry, ruff. Triage, resolve conversations, report to user. Use after PR checks complete, or when re-checking after fixes.
user-invocable: true
version: 1.1.0
---

# /review-pr-comments — Review PR Findings & Conversations

## Why this matters

Automated reviewers (Semgrep, Claude ultrareview, Sentry, ruff) leave findings, comments, and conversations on PRs. Ignoring them creates tech debt and security risk. This skill is the discipline step — treat it as a real task, not optional cleanup.

**Note on review scope:** Testing PRs (`/prt`) get Semgrep + ruff only — no Claude ultrareview (fast iteration). Prod PRs (`/prp`) and 2.0-branch PRs (`/pr2`) get ultrareview when the user pastes `@claude ultrareview` as a PR comment. Greptile has been retired (out of credits, 2026-04-19).

## Usage

`/review-pr-comments <PR#>` — review all automated findings on a PR.

## Step 1 — Gather all findings

```bash
# PR status checks (Semgrep, ruff, etc.)
gh pr checks <PR#> --repo ahelme/comfyume-v1

# PR review comments (Claude ultrareview, Sentry)
gh api repos/ahelme/comfyume-v1/pulls/<PR#>/comments --jq '.[] | {user: .user.login, body: .body[:200], path: .path, line: .line, state: .state}'

# PR issue-style comments
gh api repos/ahelme/comfyume-v1/issues/<PR#>/comments --jq '.[] | {user: .author.login, body: .body[:200]}'

# Semgrep findings (detailed)
# Run /sem-pr <PR#> for full triage
```

## Step 2 — Categorise each finding

| Source | What to look for |
|--------|-----------------|
| **Semgrep** | Security findings in status checks — run `/sem-pr <PR#>` for full triage |
| **Claude ultrareview** (prod/2.0 PRs only) | User-triggered via `@claude ultrareview` comment — thorough code review, suggestions, questions |
| **Sentry** | Runtime errors linked to changed code |
| **ruff** | Lint failures — must pass before merge |

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
gh api graphql -f query='{ repository(owner: "ahelme", name: "comfyume-v1") { pullRequest(number: <PR#>) { reviewThreads(first: 50) { nodes { isResolved comments(first: 1) { nodes { body author { login } } } } } } } }' --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | .comments.nodes[0] | "\(.author.login): \(.body[:100])"'
```

If CLI resolution is not available, note which conversations need resolving and ask the user to resolve them in the GitHub UI.

## Step 5 — Report to user

Present a summary:

```
PR #<number> Review Summary:

| Source | Findings | Resolved | Action Taken |
|--------|----------|----------|-------------|
| Semgrep | 3 | 2 fixed, 1 issue #xyz | /sem-pr triage |
| Claude ultrareview | 1 suggestion | 1 resolved | Applied suggestion |
| ruff | passing | - | - |

Unresolved conversations: 0 (or list what needs human resolution)
```

## When to run this

- After `/prt`, `/prp`, `/pr2` — once checks complete (~3 min)
- After pushing fixes to an existing PR — re-check new comments
- When asked to review another team's PR
- Before requesting merge — final check that everything is clean
