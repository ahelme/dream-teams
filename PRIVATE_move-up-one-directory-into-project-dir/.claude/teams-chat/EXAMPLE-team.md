---
active: true
channel_id: "[ SLACK CHANNEL ID ]"
emoji: "[ AGENT EMOJI ]"
name: "[ AGENT NAME ]"
team: "[ TEAM NAME ]"
---

# Team Chat Config — EXAMPLE

One identity file per team lives here as `teams-chat/<team-slug>.md`.
Each clone symlinks its own file to `.claude/teams-chat.local.md`
(wired by `agent_tools/new-team.sh` / `apply-links.sh`). The Slack
helper scripts read it and prepend `emoji name (team)` to every post.

Rules:
- Never edit another team's identity file.
- Never `!`-negate `teams-chat.local.md` in a `.gitignore`.

## Worked example (fictional)

```yaml
---
active: true
channel_id: C0000000000
emoji: 🌿
name: Willow
team: refactoring-team
---
```

Willow 🌿, refactoring specialist — her posts appear in the team
channel as "🌿 Willow (refactoring-team): ...".
