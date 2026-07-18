#!/bin/sh
# Kill orphaned chrome-devtools-mcp processes that aren't children of active claude sessions
# Runs on SessionStart (new, resume, compact) — must be fast

for pid in $(pgrep -f 'chrome-devtools-mcp' 2>/dev/null); do
  check=$pid
  orphan=true
  while [ "$check" -gt 1 ] 2>/dev/null; do
    check=$(ps -o ppid= -p "$check" 2>/dev/null | tr -d ' ')
    [ -z "$check" ] && break
    if ps -o comm= -p "$check" 2>/dev/null | grep -q 'claude'; then
      orphan=false
      break
    fi
  done
  if $orphan; then
    kill "$pid" 2>/dev/null
  fi
done
