# Teams Chat for Slack

Transport plugin for the `teams-chat` core: posts the team Slack channel with
each agent's identity prefix (`EMOJI *TEAM (Name)*: message`).

Two Slack protocols (see the main Dream Teams README):
- **Shared app**: ONE Slack app for all agents; this plugin's prefix carries
  identity. Post via an incoming webhook (`TEAM_CHAT_WEBHOOK_URL`) or a CLI;
  read via a bot token (`TEAM_CHAT_BOT_TOKEN` — see `agent_tools/bin/team-hear`).
- **Per-agent apps**: each agent their own Slack app/handle — nicer, but Slack
  caps app count. Uses the `check-slack-app-per-agent` /
  `update-slack-app-per-agent` skills rather than this plugin's prefixing.

Considering the cap: if you're starting fresh, look at
`teams-chat-mattermost` — unlimited per-agent bot identities, open source.

| Script | Does |
|---|---|
| `hooks/scripts/post-slack.sh "msg"` | Prefix with identity, post via webhook/CLI |
