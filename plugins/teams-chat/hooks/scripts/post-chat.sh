#!/usr/bin/env bash
# post-chat.sh — transport-neutral "post to team chat" dispatcher.
# Usage: post-chat.sh "message text"
# Resolves the transport plugin (Teams Chat for Mattermost / for Slack) and
# delegates. Core teams-chat stays transport-free; install ONE transport
# plugin beside this one.
#
# Resolution order:
#   1. $TEAMS_CHAT_POST_SCRIPT        — explicit script path, wins always
#   2. $TEAMS_CHAT_TRANSPORT          — "mattermost" or "slack"
#   3. auto-detect: MATTERMOST_URL set → mattermost; else slack

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARKETPLACE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"   # plugins live side by side

MESSAGE="${1:?Usage: post-chat.sh \"message\"}"

if [[ -n "${TEAMS_CHAT_POST_SCRIPT:-}" ]]; then
  exec "$TEAMS_CHAT_POST_SCRIPT" "$MESSAGE"
fi

TRANSPORT="${TEAMS_CHAT_TRANSPORT:-}"
if [[ -z "$TRANSPORT" ]]; then
  if [[ -n "${MATTERMOST_URL:-}" ]]; then TRANSPORT="mattermost"; else TRANSPORT="slack"; fi
fi

CANDIDATE="$MARKETPLACE_DIR/teams-chat-$TRANSPORT/hooks/scripts/post-$TRANSPORT.sh"
if [[ -x "$CANDIDATE" || -f "$CANDIDATE" ]]; then
  exec bash "$CANDIDATE" "$MESSAGE"
fi
echo "ERROR: no transport plugin found for '$TRANSPORT' (looked at $CANDIDATE)" >&2
exit 1
