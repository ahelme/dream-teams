# teams-chat Plugin

Per-team Slack identity and chat integration via a Slack transport CLI (e.g. pantalk) — ADAPT to your transport.

## What It Does

- Gives each team clone a unique Slack identity (emoji + display name)
- Provides scripts for posting and reading from `#[ TEAM CHANNEL ]`
- Auto-posts milestone events (commits, pushes, PRs) via PostToolUse hook

## Activation

```
/teams-chat-activate
```

This creates `.claude/teams-chat.local.md` in your project with your chosen emoji, name, and team.

To deactivate: `/teams-chat-deactivate`

## Config

Lives at `<project-root>/.claude/teams-chat.local.md`:

```yaml
---
active: true
channel_id: [ SLACK CHANNEL ID ]
emoji: 🪶
name: Scripps
team: mello-scripts-team
---
```

## Scripts

| Script | Purpose |
|--------|---------|
| `load-profile.sh` | Source to get `$CHAT_EMOJI`, `$CHAT_NAME`, `$CHAT_CHANNEL`, `$CHAT_ACTIVE` |
| `post-slack.sh` | Post formatted message: `EMOJI *TEAM (Name)*: message` |
| `set-profile.sh` | CLI: `set-profile.sh "🪶" "Scripps"` — auto-detects team from `$PWD` |

## Skill Integration

Skills (`/us`, `/cs`, `/up`) reference these scripts:

```bash
source ~/.claude/plugins/teams-chat/hooks/scripts/load-profile.sh
~/.claude/plugins/teams-chat/hooks/scripts/post-slack.sh "message"
```

## Note on Symlinked `.claude/` Dirs

If your project uses symlinked `.claude/` dirs, the PostToolUse hook in `hooks.json` uses `${CLAUDE_PLUGIN_ROOT}` which resolves to the plugin's install location, not the project `.claude/`. This works correctly regardless of symlinks.
