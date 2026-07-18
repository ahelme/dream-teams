#!/usr/bin/env bash
# load-profile.sh — Source this to get $CHAT_EMOJI, $CHAT_NAME, $CHAT_CHANNEL, $CHAT_ACTIVE, $CHAT_TEAM
# Usage: source /path/to/load-profile.sh

# Find project root (walk up from PWD looking for .claude/)
_find_project_root() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/.claude" ]]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

_PROJECT_ROOT="$(_find_project_root)"
_CONFIG_FILE="${_PROJECT_ROOT:-.}/.claude/teams-chat.local.md"

# Defaults
export CHAT_EMOJI="🤖"
export CHAT_NAME="Claude"
export CHAT_CHANNEL="[ SLACK CHANNEL ID ]"
export CHAT_ACTIVE="false"
export CHAT_TEAM=""

if [[ -f "$_CONFIG_FILE" ]]; then
  # Parse YAML frontmatter (between --- markers)
  _in_frontmatter=false
  while IFS= read -r line; do
    if [[ "$line" == "---" ]]; then
      if $_in_frontmatter; then
        break
      else
        _in_frontmatter=true
        continue
      fi
    fi
    if $_in_frontmatter; then
      case "$line" in
        emoji:*)  export CHAT_EMOJI="$(echo "${line#emoji:}" | xargs)" ;;
        name:*)   export CHAT_NAME="$(echo "${line#name:}" | xargs)" ;;
        channel_id:*) export CHAT_CHANNEL="$(echo "${line#channel_id:}" | xargs)" ;;
        active:*) export CHAT_ACTIVE="$(echo "${line#active:}" | xargs)" ;;
        team:*)   export CHAT_TEAM="$(echo "${line#team:}" | xargs)" ;;
      esac
    fi
  done < "$_CONFIG_FILE"
fi

unset _PROJECT_ROOT _CONFIG_FILE _in_frontmatter
