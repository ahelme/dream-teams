#!/usr/bin/env bash
# PreToolUse hook: BLOCK writes containing secrets to context/resume/progress files
# Exit 0 = allow, Exit 2 = block
#
# Input: JSON via stdin with tool_name, tool_input (file_path, new_string/content)
# PERF: ~2ms for non-matching files (jq parse + case), ~5ms for matching files (one grep)

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Extract file_path from tool_input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$FILE_PATH" ] && exit 0

# Only check files in sensitive paths — fast exit for everything else
case "$FILE_PATH" in
  *context.md|*resume*.md|*progress*.md|*skills/*.md) ;;
  *) exit 0 ;;
esac

# Extract content being written (new_string for Edit, content for Write)
CONTENT=$(echo "$INPUT" | jq -r '(.tool_input.new_string // .tool_input.content) // empty' 2>/dev/null)
[ -z "$CONTENT" ] && exit 0

# Single combined regex — all secret patterns in one grep call
COMBINED='xox[bps]-[0-9]|sk-[a-zA-Z0-9]{20,}|gh[po]_[a-zA-Z0-9]{36}|AKIA[0-9A-Z]{16}|password\s*[=:/]\s*\S{8,}|admin\s*/\s*[A-Za-z0-9]{8,}|user[0-9]+\s*/\s*[A-Za-z0-9]{8,}|Bearer\s+[A-Za-z0-9_\-\.]{20,}'

MATCH=$(echo "$CONTENT" | grep -Pi "$COMBINED" || true)
[ -z "$MATCH" ] && exit 0

# False positive filter: env var refs, documentation phrases
if echo "$MATCH" | grep -qP '(\$\{?\w+|\bsee\b.*\.env|\bcreds in\b|\breference\b)'; then
  exit 0
fi

# Output block message to stderr (exit 2 = fed back to Claude)
echo "BLOCKED: Secret detected in write to $FILE_PATH" >&2
echo "Match: $(echo "$MATCH" | head -c 80)..." >&2
echo "" >&2
echo "NEVER put credentials in context/resume/progress files." >&2
echo "Reference .env or server paths instead." >&2
exit 2
