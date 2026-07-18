#!/usr/bin/env bash
# set-profile.sh — Write or update teams-chat.local.md
# Usage: set-profile.sh "emoji" "name"
# Auto-detects team from $PWD

set -euo pipefail

EMOJI="${1:?Usage: set-profile.sh \"emoji\" \"name\"}"
NAME="${2:?Usage: set-profile.sh \"emoji\" \"name\"}"

# Find project root
_find_project_root() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/.claude" ]]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  echo "$PWD"
}

PROJECT_ROOT="$(_find_project_root)"
CONFIG_FILE="$PROJECT_ROOT/.claude/teams-chat.local.md"

# Auto-detect team from path
TEAM=""
if [[ "$PROJECT_ROOT" =~ testing-([^/]+)/ ]] || [[ "$PROJECT_ROOT" =~ testing-([^/]+)$ ]]; then
  TEAM="${BASH_REMATCH[1]}"
elif [[ "$PROJECT_ROOT" =~ /([^/]*team[^/]*)/ ]] || [[ "$PROJECT_ROOT" =~ /([^/]*team[^/]*)$ ]]; then
  TEAM="${BASH_REMATCH[1]}"
fi

mkdir -p "$(dirname "$CONFIG_FILE")"

cat > "$CONFIG_FILE" << EOF
---
active: true
channel_id: [ SLACK CHANNEL ID ]
emoji: ${EMOJI}
name: ${NAME}
team: ${TEAM}
---

# Team Chat Config

Set by set-profile.sh on $(date -u +%Y-%m-%dT%H:%M:%SZ).
EOF

echo "Profile saved: ${EMOJI} ${NAME} (team: ${TEAM:-unknown})"
echo "Config: ${CONFIG_FILE}"
