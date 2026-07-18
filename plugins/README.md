# plugins/

Claude Code plugins referenced by the template's skills and settings. Install
them into a plugins marketplace directory (e.g.
`~/.claude/plugins/marketplaces/<your-plugins-marketplace>/`) or copy the hook
scripts to paths of your choosing — then update the paths in
`PRIVATE/.claude/settings.json` and `agent_tools/bin/team-say`.

| Plugin | What it does | Needed by |
|---|---|---|
| `teams-chat/` | The SHARED-Slack-app identity protocol: `load-profile.sh` reads the agent's `.claude/teams-chat.local.md` (emoji, name, team, channel) so every message is prefixed with the agent's identity; activate/deactivate commands; milestone auto-echo hook. | `check-slack-shared-slack-app` skill, `agent_tools/bin/team-say`/`team-hear` |
| `team-detect/` | SessionStart/PreCompact hook: maps `$PWD` to a team and emits the team's resume/handover skill invocation. Edit the case-map for your directory layout. | `settings.json` SessionStart hook |
| `cleanup-orphaned-mcp/` | SessionStart hygiene hook: removes orphaned MCP server state. | `settings.json` SessionStart hook |

Transport note: posting/reading Slack needs a transport — either a plain
incoming webhook + bot token (built into `team-say`/`team-hear` via
`TEAM_CHAT_WEBHOOK_URL` / `TEAM_CHAT_BOT_TOKEN` env vars) or your own CLI
(the original projects used a compiled `pantalk` tool, not shipped here).

The PER-AGENT-Slack-app protocol (each agent its own Slack app/handle — nicer
identities, but Slack caps the number of free apps) needs no plugin: see the
`check-slack-app-per-agent` / `update-slack-app-per-agent` skills.
