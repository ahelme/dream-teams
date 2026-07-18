---
name: cs
description: Check Slack — read recent messages and optionally post a status update
user-invocable: true
arguments:
  - name: message
    description: Optional message to post (otherwise just read)
    required: false
version: 1.1.0
---

1. Read recent Slack: `~/bin/team-hear`
2. Briefly acknowledge new messages from other teams
3. If message given, post: `~/bin/team-say "<message>"`
   - Your emoji/team/name is prepended automatically from `.claude/teams-chat.local.md`
