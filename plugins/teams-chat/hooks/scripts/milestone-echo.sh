#!/usr/bin/env bash
# milestone-echo.sh — PostToolUse hook: auto-post to Slack on key milestones
# Reads PostToolUse JSON from stdin, checks for milestone patterns, posts if matched.
# Fast exit (~2ms) when no match.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read hook input from stdin
INPUT="$(cat)"

# Extract the command from tool_input.command
COMMAND="$(echo "$INPUT" | grep -oP '"command"\s*:\s*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"$//')"

# Fast exit if no command or not a milestone
[[ -z "$COMMAND" ]] && exit 0

# Check for milestone patterns
MILESTONE=""
case "$COMMAND" in
  *"git commit"*)  MILESTONE="committed" ;;
  *"git push"*)    MILESTONE="pushed" ;;
  *"gh pr create"*) MILESTONE="opened PR" ;;
  *"gh pr merge"*) MILESTONE="merged PR" ;;
  *"deploy"*)      MILESTONE="deployed" ;;
  *)               exit 0 ;;
esac

# Source profile to check if active
source "$SCRIPT_DIR/load-profile.sh"

[[ "$CHAT_ACTIVE" != "true" ]] && exit 0

# Extract a brief description from the command
BRIEF="$(echo "$COMMAND" | head -c 120)"

# Post the milestone
"$SCRIPT_DIR/post-slack.sh" "${MILESTONE}: ${BRIEF}" 2>/dev/null || true
