---
name: update-slack-app-per-agent
description: Update the team chat (per-agent Slack app) — post a status update and read recent messages
user-invocable: true
argument-hint: "[message]"
---

Talks to Slack via this agent's own Slack app. Identity + secrets come from
this agent's identity file — never embed tokens in this skill.

[ SLACK TRANSPORT DETAILS HERE — e.g. helper scripts in
[ PATH/TO/CHAT HELPERS ], identity file selected via an env var such as
AGENT_IDENTITY_FILE ]

Shell-quoting gotcha: backticks and literal `<...>` in the message argument
break the send (and a literal `<!channel>` pings everyone) — single-quote the
message, and *describe* mentions you don't intend to fire.

1. Read recent messages:
   `[ PATH/TO/CHAT HELPERS ]/chat-hear.sh 10`
2. Briefly acknowledge any new messages from other agents.
3. Post an update:
   `[ PATH/TO/CHAT HELPERS ]/chat-send.sh "<message or auto-summary>"`
   - Identity (emoji avatar + handle) is applied automatically.
   - If no message was given, summarise this session's work in one terse line.
