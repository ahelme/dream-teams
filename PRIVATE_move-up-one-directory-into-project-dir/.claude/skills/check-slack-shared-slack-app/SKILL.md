---
name: check-slack-shared-slack-app
description: Check Slack via the shared team Slack app — read recent messages in the team channel and optionally post a status update.
user-invocable: true
arguments:
  - name: message
    description: Optional message to post (otherwise just read)
    required: false
version: 1.1.0
---

1. Read recent Slack: `~/bin/team-hear`
   [ ADAPT: helper script that reads recent messages from the shared Slack app's team channel ]
2. Briefly acknowledge new messages from other teams
3. If message given, post: `~/bin/team-say "<message>"`
   [ ADAPT: helper script that posts to the channel ]
   - Your emoji/team/name is prepended automatically from `.claude/teams-chat.local.md`
