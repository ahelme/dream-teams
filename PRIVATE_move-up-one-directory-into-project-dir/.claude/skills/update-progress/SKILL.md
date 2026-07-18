---
name: up
description: Update progress — alias for /update-progress
user-invocable: true
version: 1.1.0
---

Please update the team progress file and central progress file.

**Detect team from project directory:**
- `/home/dev/projects/testing-mello-team-one` → `~/projects/claude-code-comfyume-teams/.claude/agent_docs/progress-mello-team-one-dev.md`
- `/home/dev/projects/testing-mello-scripts-team` → `~/projects/claude-code-comfyume-teams/.claude/agent_docs/progress-mello-scripts-team-dev.md`
- `/home/dev/projects/testing-mello-admin-panel-team` → `~/projects/claude-code-comfyume-teams/.claude/agent_docs/progress-mello-admin-panel-team-dev.md`
- `/home/dev/comfyume` → `~/projects/claude-code-comfyume-teams/.claude/agent_docs/progress-verda-team-one-dev.md`

**Steps:**

1. Identify which team progress file matches the current working directory

2. Update that team's progress file with recent work done this session

3. Update `~/projects/claude-code-comfyume-teams/.claude/agent_docs/progress-all-teams.md` with 1-line-per-commit entries

4. **⚠️ Update GitHub issues** — analyse the FULL SESSION for ALL open issues touched, referenced, or discovered. For each: `gh issue comment <number> --body "..."` with concise status (what was done, what's pending). Close resolved issues with `gh issue close <number>`.

5. **Post summary to Slack** via `~/bin/team-say "brief progress summary"`

6. **Read recent Slack** via `~/bin/team-hear`. Briefly acknowledge any new messages from other teams.

7. Show me what was added before committing

8. **Commit and push the Teams Repo** — run the /mc steps inline (cd to `~/projects/claude-code-comfyume-teams`, git add changed files, commit, pull --rebase, push to main, return to original dir)
