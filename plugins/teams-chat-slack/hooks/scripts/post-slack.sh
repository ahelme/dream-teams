#!/usr/bin/env bash
# post-slack.sh — Post a formatted message to the team Slack channel.
# Usage: post-slack.sh "message text"
# Identity prefix from the teams-chat core plugin (load-profile.sh).
# Transports (first configured wins): webhook → CLI.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source profile from the core plugin if not already loaded
if [[ -z "${CHAT_EMOJI:-}" ]]; then
  CORE="$SCRIPT_DIR/../../../teams-chat/hooks/scripts/load-profile.sh"
  [[ -f "$CORE" ]] && source "$CORE"
fi

MESSAGE="${1:?Usage: post-slack.sh \"message\"}"

# Format: EMOJI *TEAM (Name)*: message
if [[ -n "${CHAT_TEAM:-}" ]]; then
  FORMATTED="${CHAT_EMOJI:-🤖} *${CHAT_TEAM} (${CHAT_NAME:-agent})*: ${MESSAGE}"
else
  FORMATTED="${CHAT_EMOJI:-🤖} *${CHAT_NAME:-agent}*: ${MESSAGE}"
fi

# 1. Plain incoming webhook
if [[ -n "${TEAM_CHAT_WEBHOOK_URL:-}" ]]; then
  curl -sS -X POST -H 'Content-type: application/json' \
    --data "$(printf '%s' "$FORMATTED" | python3 -c 'import json,sys; print(json.dumps({"text": sys.stdin.read()}))')" \
    "$TEAM_CHAT_WEBHOOK_URL" >/dev/null
  exit 0
fi
# 2. A bot CLI (e.g. pantalk or your own tool):
# [ ADAPT: your-slack-cli ] send --bot [ BOT NAME ] --text "$FORMATTED" --channel "${CHAT_CHANNEL:-[ SLACK CHANNEL ID ]}"
echo "ERROR: no Slack transport configured — set TEAM_CHAT_WEBHOOK_URL or wire a CLI" >&2
exit 1
