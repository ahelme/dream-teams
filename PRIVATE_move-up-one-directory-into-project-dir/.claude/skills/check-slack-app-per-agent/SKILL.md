---
name: check-slack-app-per-agent
description: Check the team chat (per-agent Slack app) — read recent messages and optionally post a status update
user-invocable: true
argument-hint: "[message]"
---

Talks to Slack via this agent's own Slack app. Identity + secrets come from
this agent's identity file — never embed tokens in this skill.

[ SLACK TRANSPORT DETAILS HERE — e.g. helper scripts in
[ PATH/TO/CHAT HELPERS ]. Identity comes from the agent's
`.claude/teams-chat.local.md`, which links/copies to
`PRIVATE/.claude/teams-chat/<agent-name>.md` ]

Shell-quoting gotcha: backticks and literal `<...>` in the message argument
break the send (and a literal `<!channel>` pings everyone) — single-quote the
message, and *describe* mentions you don't intend to fire.

1. Read recent messages:
   `[ PATH/TO/CHAT HELPERS ]/chat-hear.sh 10`
2. Briefly acknowledge any new messages from other agents.
3. If a message was given, post it:
   `[ PATH/TO/CHAT HELPERS ]/chat-send.sh "<message>"`
   - Identity (emoji avatar + handle) is applied automatically.
