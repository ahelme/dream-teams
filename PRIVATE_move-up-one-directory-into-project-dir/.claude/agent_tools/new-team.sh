#!/usr/bin/env bash
#
# new-team.sh — stand up a fully-wired project clone for a new team.
# VERSION: 1.1.0
#
# Lives in TEAMS_REPO/.claude/agent_tools/ so it rides along with every clone
# as a shared agent tool. Delegates symlink wiring to apply-links.sh (same dir).
# ADAPT: all project-specific paths/names come from file-paths-registry.sh —
# edit that file, not this script.
#
# Replaces the fragile "copy a template dir" approach (cp -r dereferences the
# .claude symlinks, carries stale code, and copies the wrong team's identity).
# A fresh `git clone` already brings the code + canonical .gitignore + the
# committed symlinks (agent_docs/hooks/skills/agent_tools); this script adds the
# non-tracked per-clone bits and the teams-chat identity.
#
# Usage:
#   new-team.sh <slug> "<emoji>" "<name>" [options]
#
# Args:
#   slug     team dir + identity slug, e.g. refactoring-team
#   emoji    teams-chat emoji, e.g. 🌿  (any single grapheme)
#   name     teams-chat display name, e.g. Willow
#
# Options:
#   --base <branch>     base branch to fork from        (default: $DEFAULT_BASE_BRANCH from registry)
#   --branch <name>     new team branch name            (default: <slug>-YYYY-MM-DD)
#   --dir <path>        clone target dir                (default: $TEAM_CLONES_DIR/<slug>/$PROJECT_DIRNAME)
#   --no-push           create the branch locally but don't push it
#   -h | --help         show this help
#
# Paths are read from file-paths-registry.sh (same dir). Edit that when repos move.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=file-paths-registry.sh
source "${SCRIPT_DIR}/file-paths-registry.sh"

die()  { printf '\033[31m✗ %s\033[0m\n' "$*" >&2; exit 1; }
info() { printf '\033[36m→ %s\033[0m\n' "$*"; }
ok()   { printf '\033[32m✓ %s\033[0m\n' "$*"; }

# --- parse args ---
[[ $# -lt 3 ]] && { grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 1; }
SLUG="$1"; EMOJI="$2"; NAME="$3"; shift 3
BASE="${DEFAULT_BASE_BRANCH:-main}"; BRANCH=""; TARGET=""; PUSH=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --base)   BASE="$2"; shift 2 ;;
    --branch) BRANCH="$2"; shift 2 ;;
    --dir)    TARGET="$2"; shift 2 ;;
    --no-push) PUSH=0; shift ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

TODAY="$(date +%F)"
[[ -z "$BRANCH" ]] && BRANCH="${SLUG}-${TODAY}"
[[ -z "$TARGET" ]] && TARGET="${TEAM_CLONES_DIR}/${SLUG}/${PROJECT_DIRNAME:-project}"

# --- preflight ---
[[ -d "$TEAMS_REPO" ]]     || die "TEAMS_REPO not found: $TEAMS_REPO (check registry)"
[[ -d "$HEALTHY_CLONE" ]]  || die "HEALTHY_CLONE not found: $HEALTHY_CLONE (check registry)"
[[ -e "${TARGET}/.git" ]]  && die "A clone already exists at ${TARGET} — refusing to clobber."

info "Creating team '${SLUG}'  ${EMOJI} ${NAME}"
info "  branch ${BRANCH}  (base ${BASE})   →  ${TARGET}"

# --- 1. clone ---
mkdir -p "$(dirname "$TARGET")"
git clone --quiet "$REPO_URL" "$TARGET"
cd "$TARGET"
ok "cloned $REPO_URL"

# --- 2. branch off base ---
git fetch --quiet origin "$BASE" || die "base branch '$BASE' not found on origin"
git checkout -q -B "$BRANCH" "origin/${BASE}"
ok "checked out ${BRANCH} from origin/${BASE}"

# --- 3. always-on local symlinks (.mcp.json + settings.json) ---
ln -sfn "${TEAMS_REPO}/.mcp.json"             .mcp.json
ln -sfn "${TEAMS_REPO}/.claude/settings.json" .claude/settings.json
ok "linked .mcp.json + .claude/settings.json → Teams Repo"

# --- 4. local settings.local.json (plugins etc.) ---
if [[ -f "${HEALTHY_CLONE}/.claude/settings.local.json" ]]; then
  cp "${HEALTHY_CLONE}/.claude/settings.local.json" .claude/settings.local.json
  ok "seeded .claude/settings.local.json from healthy clone"
else
  info "no settings.local.json in healthy clone — skipped (plugins may need enabling)"
fi

# --- 5. teams-chat identity file ---
IDENTITY_FILE="${TEAMS_CHAT_DIR}/${SLUG}.md"
if [[ ! -f "$IDENTITY_FILE" ]]; then
  mkdir -p "$TEAMS_CHAT_DIR"
  cat > "$IDENTITY_FILE" <<EOF
---
active: true
channel_id: ${SLACK_CHANNEL_ID}
emoji: ${EMOJI}
name: ${NAME}
team: ${SLUG}
---

# Team Chat Config

Created by new-team.sh for ${SLUG} (${EMOJI} ${NAME}).
EOF
  ok "created identity file ${IDENTITY_FILE}"
else
  info "identity file already exists — leaving it: ${IDENTITY_FILE}"
fi

# --- 6. toggles + wiring: write default team-links.json (all-on, identity=slug)
#         then let apply-links.sh create the shared symlinks + identity link. ---
python3 - "$SCRIPT_DIR/team-links.json.template" "$SLUG" .claude/team-links.json <<'PY'
import json, sys
c = json.load(open(sys.argv[1]))
c.pop("_comment", None)
c["identity"] = sys.argv[2]
with open(sys.argv[3], "w") as f:
    json.dump(c, f, indent=2); f.write("\n")
PY
ok "wrote .claude/team-links.json (all-on, identity=${SLUG})"
"${SCRIPT_DIR}/apply-links.sh" --dir "$TARGET"

# --- 7. verify ---
info "verifying…"
git status --porcelain | grep -q . && { git status --short; info "working tree not clean (see above)"; } || ok "git status clean (local files ignored)"
for l in .mcp.json .claude/settings.json .claude/teams-chat.local.md "${SHARED_LINKS[@]/#/.claude/}"; do
  [[ -e "$l" ]] && ok "symlink resolves: $l" || die "broken/missing: $l"
done
NEG="$(grep -c '!\.claude/settings\.local\.json\|!\.claude/teams-chat\.local\.md' .gitignore || true)"
[[ "$NEG" == "0" ]] && ok ".gitignore has 0 identity-negations" || die ".gitignore has dangerous negations!"

# --- 8. push ---
if [[ "$PUSH" == "1" ]]; then
  git push -q -u origin "$BRANCH" && ok "pushed ${BRANCH}"
else
  info "--no-push: branch ${BRANCH} is local only"
fi

echo
ok "Team '${SLUG}' ready: ${EMOJI} ${NAME}  @ ${TARGET}  (branch ${BRANCH})"
