---
name: update-progress
description: Update the team progress file and central progress file, comment on touched GitHub issues, and notify the team chat
user-invocable: true
version: 1.1.0
---

Please update the team progress file and central progress file.

**Progress files** live in the teams repo under `agent_docs/`:
- Per-team: `agent_docs/progress-<team>.md` (ships as a fill-in template)
- Central: `agent_docs/progress-all-teams.md`

**Detect team** from the current working directory / your team identity in `.claude/teams-chat.local.md`. [ ADAPT: map each team's project directory to its progress file ]

**Steps:**

1. Identify which team progress file matches the current working directory

2. Update that team's progress file with recent work done this session

3. Update `agent_docs/progress-all-teams.md` with 1-line-per-commit entries

4. **⚠️ Update GitHub issues** — analyse the FULL SESSION for ALL open issues touched, referenced, or discovered. For each: `gh issue comment <number> --body "..."` with concise status (what was done, what's pending). Close resolved issues with `gh issue close <number>`.

5. **Post summary to team chat** [ ADAPT: your team-chat post command, e.g. a Slack helper script ]

6. **Read recent team chat** [ ADAPT: your team-chat read command ]. Briefly acknowledge any new messages from other teams.

7. Show me what was added before committing

8. [ ADAPT: if agent_docs lives in a git repo (teams-repo style), commit+push it — cd to the teams repo, `git add` changed files, commit, `git pull --rebase`, push, return to original dir; if it lives in a non-git PRIVATE dir, skip this step ]
