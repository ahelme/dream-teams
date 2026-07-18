---
name: pr-prod
description: Commit, push, and create PR to [ MAIN BRANCH ] (production). Prod PRs get thorough Claude review — user triggers it by pasting `@claude ultrareview` as a PR comment. No merge.
user-invocable: true
version: 1.1.0
---

Commit all staged+unstaged changes, push, and create a PR to [ MAIN BRANCH ]. Prod PRs get **Claude ultrareview** (user-triggered; requires the Claude GitHub app/workflow). Do NOT merge.

0. [ ADAPT: if you have a pre-production readiness skill, run it here — analyse what this code assumes about production (environment manifest, dependencies, blockers) BEFORE creating the PR ]
1. `git add` changed files (specific files, not -A)
2. `git commit` with conventional commit message
3. `git push origin <current-branch>`
4. `gh pr create --base [ MAIN BRANCH ] --head <current-branch>` (short title, minimal body). PR body footer: `<emoji> <name> — <team>` (use your team's emoji + name from `teams-chat.local.md`)
5. Confirm PR created and return the PR URL
6. **Tell the user:** "PR created. Paste `@claude ultrareview` as a PR comment to trigger thorough code review." (User triggers manually — don't do it automatically.)

## PR Review Loop

7. **Wait ~3 min** after user triggers ultrareview, then run `/review-pr-comments <number>` to triage all findings from your automated reviewers (e.g. Semgrep, Claude ultrareview, Sentry, ruff).
8. **If fixes needed:** fix, commit, push to the same branch. Add a **PR comment** explaining what was changed and why.
9. **Wait for checks to re-run** (~3 min), then run `/review-pr-comments <number>` again
10. **Repeat 7-9** until all checks pass, no blocking findings remain, and conversations are resolved

---

## Doc Debt Check

**Code shipped without docs = tech debt. You're not done.**

After creating the PR, scan what you're shipping. If your change affects how things are configured, deployed, or debugged — docs need updating.

**Minor changes — do it yourself now:**
- Updated a GH issue? Close it or comment with status.
- Changed a config default? Update the relevant wiki/docs page.
- Fixed a bug? Add to gotchas.md if others could hit it.

**Bigger changes — create a GH issue for the ops/docs team:**

| Your change | What docs need updating | Issue label |
|-------------|------------------------|-------------|
| New/changed env var | .env.example, compose passthrough, env docs | `[ OPS TEAM LABEL ]` |
| New script or Dockerfile change | Infrastructure docs, wiki | `[ OPS TEAM LABEL ]` |
| Architecture change | CLAUDE.md, wiki, agent docs | `[ OPS TEAM LABEL ]` |
| New gotcha discovered | gotchas.md, CLAUDE.md, wiki | `[ OPS TEAM LABEL ]` |
| API/config behaviour change | Wiki (config precedence, deployment guides) | `[ OPS TEAM LABEL ]` |
