#!/usr/bin/env bash
# post-mattermost.sh — Post a message to the team Mattermost channel.
# Usage: post-mattermost.sh "message text"
#
# Env (put in the agent's shell env or settings.local.json env block):
#   MATTERMOST_URL         e.g. https://chat.example.com   (no trailing slash)
#   MATTERMOST_TOKEN       bot/personal access token — PER AGENT (Mattermost
#                          has no bot-count limit: give every agent their own
#                          bot account = native identity, no prefix needed)
#   MATTERMOST_CHANNEL_ID  the team channel id
#   MATTERMOST_SHARED_BOT  set to 1 ONLY if all agents share one bot account —
#                          then messages get the identity prefix (Slack-style)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

: "${MATTERMOST_URL:?set MATTERMOST_URL}"
: "${MATTERMOST_TOKEN:?set MATTERMOST_TOKEN}"
: "${MATTERMOST_CHANNEL_ID:?set MATTERMOST_CHANNEL_ID}"

MESSAGE="${1:?Usage: post-mattermost.sh \"message\"}"

if [[ "${MATTERMOST_SHARED_BOT:-0}" == "1" ]]; then
  # Shared-bot mode: prefix with identity from teams-chat core plugin.
  CORE="$SCRIPT_DIR/../../../teams-chat/hooks/scripts/load-profile.sh"
  if [[ -f "$CORE" ]]; then
    source "$CORE"
    if [[ -n "${CHAT_TEAM:-}" ]]; then
      MESSAGE="${CHAT_EMOJI} **${CHAT_TEAM} (${CHAT_NAME})**: ${MESSAGE}"
    else
      MESSAGE="${CHAT_EMOJI} **${CHAT_NAME}**: ${MESSAGE}"
    fi
  fi
fi

python3 - "$MESSAGE" <<'EOF'
import json, os, sys, urllib.request
body = json.dumps({
    "channel_id": os.environ["MATTERMOST_CHANNEL_ID"],
    "message": sys.argv[1],
}).encode()
req = urllib.request.Request(
    os.environ["MATTERMOST_URL"] + "/api/v4/posts",
    data=body,
    headers={
        "Content-Type": "application/json",
        "Authorization": "Bearer " + os.environ["MATTERMOST_TOKEN"],
    },
)
with urllib.request.urlopen(req, timeout=15) as r:
    r.read()
EOF
