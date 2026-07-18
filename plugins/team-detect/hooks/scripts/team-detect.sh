#!/bin/bash
# Detects which team context to load based on project directory.
# Called by SessionStart hook — outputs /resume-context-{team} skill command.

case "$PWD" in
  */[ team-dir-name ]/*)
    TEAM="mello-scripts-team" ;;
  */testing-mello-team-one/*)
    TEAM="mello-team-one" ;;
  */testing-mello-ralph-team/*)
    TEAM="mello-ralph-team" ;;
  */testing-mello-admin-panel-team/*)
    TEAM="mello-admin-panel-team" ;;
  */testing-claude-desktop-team/*)
    TEAM="claude-desktop-team" ;;
  */testing-verda-team-one/*)
    TEAM="verda-team-one" ;;
  */team-clones/spl-team/*)
    TEAM="split-app-team" ;;
  */team-clones/dsk-team/*)
    TEAM="claude-desktop-team" ;;
  *)
    exit 0 ;;
esac

echo "/resume-context-${TEAM}"
