---
name: prt
description: Commit, push, and create PR to all-teams-testing (no review, no merge) — testing PRs skip review for fast iteration
user-invocable: true
version: 1.1.0
---

Commit all staged+unstaged changes, push, and create a PR to all-teams-testing. **Testing PRs skip code review** for fast iteration — Semgrep + ruff still run via GH Actions. Do NOT merge.

1. `git add` changed files (specific files, not -A)
2. `git commit` with conventional commit message
3. `git push origin <current-branch>`
4. `gh pr create --base all-teams-testing --head <current-branch>` (short title, minimal body). PR body footer: `🪶 Scripp — Sys Team` (use your team's emoji + name from `teams-chat.local.md`).
5. Confirm PR created and return the PR URL

## Post-PR Checks

6. **Wait ~3 min**, then run `/review-pr-comments <number>` to triage automated findings (Semgrep, ruff). No Claude ultrareview on testing PRs.
7. **If fixes needed:** fix, commit, push to the same branch. Add a **PR comment** explaining what was changed and why.
8. **Wait for checks to re-run** (~3 min), then run `/review-pr-comments <number>` again
9. **Repeat 6-8** until all checks pass and no blocking findings remain

---

## Doc Debt Check

**Code shipped without docs = tech debt. You're not done.**

After creating the PR, scan what you're shipping. If your change affects how things are configured, deployed, or debugged — docs need updating.

**Minor changes — do it yourself now:**
- Updated a GH issue? Close it or comment with status.
- Changed a config default? Update the relevant wiki page.
- Fixed a bug? Add to gotchas.md if others could hit it.

**Bigger changes — create a GH issue for Scripp (ops team):**

| Your change | What docs need updating | Issue label |
|-------------|------------------------|-------------|
| New/changed env var | .env, docker-compose passthrough, wiki env guide | `mello-scripts-team` |
| New script or Dockerfile change | Infrastructure registry, wiki, role.md | `mello-scripts-team` |
| Architecture change | CLAUDE.md, wiki, agent docs | `mello-scripts-team` |
| New gotcha discovered | gotchas.md, CLAUDE.md, wiki | `mello-scripts-team` |
| API/config behaviour change | Wiki (config precedence, deployment guides) | `mello-scripts-team` |
| New model or workflow template | models_and_data.md, wiki workflow pages | `mello-scripts-team` |
