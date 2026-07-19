# plugins/

Claude Code plugins for Dream Teams. Install into a plugins marketplace
directory (e.g. `~/.claude/plugins/marketplaces/<your-plugins-marketplace>/`)
**side by side** — the core dispatcher finds transport plugins as siblings.
Update paths in `PRIVATE/.claude/settings.json` and (if needed)
`agent_tools/bin/team-say` / `team-hear` env overrides.

| Plugin | What it does | Needed by |
|---|---|---|
| `teams-chat/` | **Core (transport-free)**: agent chat identity — `load-profile.sh` parses `.claude/teams-chat.local.md` (emoji, name, team, channel); activate/deactivate commands; milestone auto-echo hook; `post-chat.sh` dispatcher that delegates to the installed transport plugin. | everything chat-related |
| `teams-chat-mattermost/` | **Teams Chat for Mattermost** (recommended): post/read via the Mattermost REST API. Unlimited per-agent bot accounts = native identities; shared-bot prefix mode available. Open sauce. 🍝 | shared-app-style skills, `team-say`/`team-hear` |
| `teams-chat-slack/` | **Teams Chat for Slack**: identity-prefixed posting via incoming webhook or a CLI (e.g. the original projects' compiled `pantalk`, not shipped). | shared-app-style skills, `team-say`/`team-hear` |
| `team-detect/` | SessionStart/PreCompact hook: maps `$PWD` to a team and emits the team's resume/handover skill invocation. Edit the case-map for your layout. | `settings.json` SessionStart hook |
| `cleanup-orphaned-mcp/` | SessionStart hygiene hook: removes orphaned MCP server state. | `settings.json` SessionStart hook |

## Transport resolution (post-chat.sh, team-say, team-hear)

1. Explicit override: `TEAMS_CHAT_POST_SCRIPT` / `TEAMS_CHAT_MM_SCRIPT` / `TEAMS_CHAT_MM_READ_SCRIPT`
2. `TEAMS_CHAT_TRANSPORT=mattermost|slack`
3. Auto-detect: `MATTERMOST_URL` set → Mattermost; else Slack
   (Slack needs `TEAM_CHAT_WEBHOOK_URL` to post, `TEAM_CHAT_BOT_TOKEN` to read)

The PER-AGENT-Slack-app protocol (each agent its own Slack app — capped by
Slack) needs no plugin: see `check-slack-app-per-agent` /
`update-slack-app-per-agent` skills. With Mattermost the cap disappears, which
is the point.
