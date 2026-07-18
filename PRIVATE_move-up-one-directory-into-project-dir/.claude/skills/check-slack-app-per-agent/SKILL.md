---
name: cs
description: Check Slack — read recent messages and optionally post a status update (transport-adaptive)
user-invocable: true
argument-hint: "[message]"
version: 3.2.0
---

Talks to Slack via the **transport-adaptive** helpers in `.claude/agent_tools/`.
Identity + secrets come from this agent's identity YAML (see
`.claude/agent_tools/README.md`). Works for every local
mello seat (Aurora, Rime, Meridian — via the pantalk daemon) and any cloud seat
(Slack Web API / webhook) with no changes — transport is auto-detected. Your
identity comes from `AGENT_IDENTITY_FILE`; mind the shell-quoting gotcha:
backticks and literal `<...>` in the message argument break the send (and a
literal `<!channel>` pings everyone) — single-quote the message, describe
mentions you don't intend to fire.

1. Read recent Slack:
   `.claude/agent_tools/chat-hear.sh 10`
2. Briefly acknowledge any new messages from other agents.
3. If a message was given, post it:
   `.claude/agent_tools/chat-send.sh "<message>"`
   - Identity (emoji avatar + handle) is applied automatically.
