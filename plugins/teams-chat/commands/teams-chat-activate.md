# teams-chat-activate

Setup wizard for team chat identity.

## Steps

1. **Detect team** from `$PWD` — extract team name from the project directory path (e.g., `[ team-dir-name ]` from `/path/to/<team-dir>/<project-clone>`)

2. **Ask user** for their preferred emoji and display name, or suggest defaults based on the team:
   - mello-scripts-team → 🪶 Scripps
   - mello-team-one → 🤖 Claude
   - mello-admin-panel-team → 🤖 Claude
   - mello-ralph-team → 🤖 Claude
   - claude-desktop-team → 🤖 Claude
   - verda-team-one → 🤖 Claude

3. **Write config** to `.claude/teams-chat.local.md` in the current project directory:

```markdown
---
active: true
channel_id: [ SLACK CHANNEL ID ]
emoji: <chosen emoji>
name: <chosen name>
team: <detected team>
---

# Team Chat Config

Activated by /teams-chat-activate.
```

4. **Confirm** activation to the user: show the emoji, name, team, and channel.

## Notes

- The config file path is `<project-root>/.claude/teams-chat.local.md`
- Channel ID `[ SLACK CHANNEL ID ]` is the `#[ TEAM CHANNEL ]` channel
- If the file already exists, update it (preserve any extra content after frontmatter)
