# teams-chat Plugin

Per-team chat identity — transport-free core; pair with teams-chat-mattermost or teams-chat-slack.

## What It Does

- Gives each team clone a unique chat identity (emoji + display name)
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
channel_id: [ CHANNEL ID — Slack or Mattermost ]
emoji: 🪶
name: Scripps
team: mello-scripts-team
---
```

## Scripts

| Script | Purpose |
|--------|---------|
| `load-profile.sh` | Source to get `$CHAT_EMOJI`, `$CHAT_NAME`, `$CHAT_CHANNEL`, `$CHAT_ACTIVE` |
| `post-chat.sh` | Dispatch a post to the installed transport plugin (mattermost/slack) |
| `set-profile.sh` | CLI: `set-profile.sh "🪶" "Scripps"` — auto-detects team from `$PWD` |

## Skill Integration

Skills (`/us`, `/cs`, `/up`) reference these scripts:

```bash
source ~/.claude/plugins/teams-chat/hooks/scripts/load-profile.sh
~/.claude/plugins/[ marketplace ]/teams-chat/hooks/scripts/post-chat.sh "message"
```

## Note on Symlinked `.claude/` Dirs

If your project uses symlinked `.claude/` dirs, the PostToolUse hook in `hooks.json` uses `${CLAUDE_PLUGIN_ROOT}` which resolves to the plugin's install location, not the project `.claude/`. This works correctly regardless of symlinks.
