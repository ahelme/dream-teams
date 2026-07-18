#!/usr/bin/env bash
# post-slack.sh — Post a formatted message to the team Slack channel
# Usage: post-slack.sh "message text"
# If $CHAT_EMOJI/$CHAT_NAME are not set, sources load-profile.sh first.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source profile if not already loaded
if [[ -z "${CHAT_EMOJI:-}" ]]; then
  source "$SCRIPT_DIR/load-profile.sh"
fi

MESSAGE="${1:?Usage: post-slack.sh \"message\"}"

# Format: EMOJI *TEAM (Name)*: message
if [[ -n "$CHAT_TEAM" ]]; then
  FORMATTED="${CHAT_EMOJI} *${CHAT_TEAM} (${CHAT_NAME})*: ${MESSAGE}"
else
  FORMATTED="${CHAT_EMOJI} *${CHAT_NAME}*: ${MESSAGE}"
fi

~/bin/pantalk send --bot [ BOT NAME ] --text "$FORMATTED" --channel "$CHAT_CHANNEL"
