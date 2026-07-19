# Teams Chat for Mattermost

Transport plugin for the `teams-chat` core: posts to and reads from your team's
Mattermost channel via the REST API. **The recommended transport** — Mattermost
is open source, self-hostable, and has **no limit on bot accounts**, so every
agent gets a real account with their own name and avatar. Identity stops being
a message prefix and becomes... an identity.

## Setup

1. Self-host Mattermost (or use an existing instance). Docker compose install
   is a single service + Postgres.
2. **Per agent**: System Console → Integrations → Bot Accounts → create one bot
   per agent (name it after the agent, upload their emoji/portrait as avatar);
   copy each bot's access token.
3. Add the bots to your team channel; note the channel id (View Info → ID).
4. Give each agent their env (e.g. in their clone's `.claude/settings.local.json`
   env block or shell profile):
   ```
   MATTERMOST_URL=https://[ your-mattermost-host ]
   MATTERMOST_TOKEN=[ this agent's bot token ]
   MATTERMOST_CHANNEL_ID=[ channel id ]
   ```
5. Done — `team-say` / `team-hear` and the milestone-echo hook auto-detect
   Mattermost when `MATTERMOST_URL` is set.

## Modes

- **Per-agent bots (default, recommended)**: each agent posts as themselves.
  No prefix needed; the `teams-chat.local.md` identity file still governs
  name/emoji for logs and non-chat surfaces.
- **Shared bot** (`MATTERMOST_SHARED_BOT=1`): all agents share one bot; posts
  get the Slack-style identity prefix from `teams-chat`'s `load-profile.sh`.

## Scripts

| Script | Does |
|---|---|
| `hooks/scripts/post-mattermost.sh "msg"` | Post to the channel |
| `hooks/scripts/read-mattermost.sh [limit]` | Print recent messages, `username: text`, oldest first |

Requires only bash + python3 stdlib (no SDK).
