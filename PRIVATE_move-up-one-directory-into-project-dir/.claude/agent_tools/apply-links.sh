#!/usr/bin/env bash
#
# apply-links.sh — apply a clone's Teams-system wiring from its toggles.
# VERSION: 1.0.0
#
# Idempotent: run it any time to bring a clone into line with its team-links.json.
# `true`  → create the symlink (ln -sfn to the Teams Repo target)
# `false` → remove the symlink (rm -f)  ← lets you disable the full Team system
#           for a focused, minimal-context task, then re-enable by flipping back.
#
# The six independent toggles (see team-links.json.template):
#   1. claudeMdAdditionalDir  → manages the CLAUDE.md additionalDirectories env
#                               export line in ~/.zshrc (needs a NEW shell to take
#                               effect — cannot change a running session).
#   2. linkAll                → master gate for the .claude/ symlinks (3–5 + agent_tools)
#   3. links.agent_docs       → .claude/agent_docs  symlink
#   4. links.skills           → .claude/skills      symlink
#   5. links.hooks            → .claude/hooks        symlink
#      links.agent_tools      → .claude/agent_tools  symlink (this toolkit)
#   6. identity               → .claude/teams-chat.local.md → teams-chat/<slug>.md
#                               ("" = remove the identity link)
#
# Usage:
#   apply-links.sh [--dir <clone>] [--config <file>] [--dry-run] [-h|--help]
#     --dir     clone to operate on         (default: current dir)
#     --config  toggle file                 (default: <clone>/.claude/team-links.json)
#     --dry-run print actions, change nothing
#
# If no config file exists, defaults are ALL-ON (full Team system) and a
# team-links.json is written from the template so the toggles are discoverable.
#
# Paths come from file-paths-registry.sh (same dir).
# ADAPT: nothing project-specific lives in this script — edit
# file-paths-registry.sh for your project's paths.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=file-paths-registry.sh
source "${SCRIPT_DIR}/file-paths-registry.sh"

die()  { printf '\033[31m✗ %s\033[0m\n' "$*" >&2; exit 1; }
info() { printf '\033[36m→ %s\033[0m\n' "$*"; }
ok()   { printf '\033[32m✓ %s\033[0m\n' "$*"; }
act()  { if [[ "$DRY" == 1 ]]; then printf '   would: %s\n' "$*"; else eval "$*"; fi; }

CLONE="$PWD"; CONFIG=""; DRY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)    CLONE="$2"; shift 2 ;;
    --config) CONFIG="$2"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

CLONE="$(cd "$CLONE" && pwd)" || die "clone dir not found"
[[ -d "$CLONE/.claude" ]] || die "no .claude/ in $CLONE — is this a project team clone?"
[[ -d "$TEAMS_REPO" ]]    || die "TEAMS_REPO not found: $TEAMS_REPO (check registry)"
CONFIG="${CONFIG:-$CLONE/.claude/team-links.json}"

# --- seed a default (all-on) config if absent ---
# Preserve the clone's CURRENT identity (from the existing teams-chat.local.md
# symlink) so a first run never blanks it. Only an explicit "" removes it.
SEED_ID_OVERRIDE=""; SEEDING=0
if [[ ! -f "$CONFIG" ]]; then
  SEEDING=1
  if CUR_TGT="$(readlink "$CLONE/.claude/teams-chat.local.md" 2>/dev/null)"; then
    b="$(basename "$CUR_TGT")"; SEED_ID_OVERRIDE="${b%.md}"
  fi
  [[ "$DRY" == 1 ]] && dnote=" (dry-run, not written)" || dnote=""
  info "no toggle file — all-on default (identity=${SEED_ID_OVERRIDE:-none})${dnote}"
  if [[ "$DRY" != 1 ]]; then
    python3 - "${SCRIPT_DIR}/team-links.json.template" "$SEED_ID_OVERRIDE" "$CONFIG" <<'PY'
import json, sys
c = json.load(open(sys.argv[1])); c.pop("_comment", None)
c["identity"] = sys.argv[2]
with open(sys.argv[3], "w") as f:
    json.dump(c, f, indent=2); f.write("\n")
PY
    ok "wrote $CONFIG"
  fi
fi

# --- read toggles (python3 for reliable JSON; falls back to all-on) ---
read_toggles() {
  python3 - "$CONFIG" <<'PY'
import json, sys
try:
    c = json.load(open(sys.argv[1]))
except Exception:
    c = {}
links = c.get("links", {})
def b(v, d=True): return "1" if bool(c.get(v, d)) else "0"
def lb(v, d=True): return "1" if bool(links.get(v, d)) else "0"
print("CLAUDEMD=%s"   % b("claudeMdAdditionalDir"))
print("LINKALL=%s"    % b("linkAll"))
print("L_agent_docs=%s"  % lb("agent_docs"))
print("L_skills=%s"      % lb("skills"))
print("L_hooks=%s"       % lb("hooks"))
print("L_agent_tools=%s" % lb("agent_tools"))
print("IDENTITY=%s"   % c.get("identity", ""))
PY
}
eval "$(read_toggles)"
# when seeding, trust the identity we just detected/wrote — never let a read
# glitch blank a clone's identity link
[[ "$SEEDING" == 1 ]] && IDENTITY="$SEED_ID_OVERRIDE"

info "Applying toggles from $CONFIG  →  $CLONE"
cd "$CLONE"

# --- 2–5 + agent_tools: shared .claude/ symlinks (master gate = LINKALL) ---
for name in "${SHARED_LINKS[@]}"; do
  var="L_${name}"; want="${!var:-1}"
  target="${TEAMS_REPO}/.claude/${name}"
  if [[ "$LINKALL" == 1 && "$want" == 1 ]]; then
    act "ln -sfn '$target' '.claude/${name}'" && ok "linked  .claude/${name}"
  else
    act "rm -f '.claude/${name}'" && info "removed .claude/${name} (toggle off)"
  fi
done

# --- 6: identity symlink ---
if [[ -n "$IDENTITY" ]]; then
  idf="${TEAMS_CHAT_DIR}/${IDENTITY}.md"
  [[ -f "$idf" ]] || die "identity file missing: $idf"
  act "ln -sfn '$idf' '.claude/teams-chat.local.md'" && ok "linked  identity → ${IDENTITY}.md"
else
  act "rm -f '.claude/teams-chat.local.md'" && info "removed identity link (identity: \"\")"
fi

# --- 1: CLAUDE.md additionalDirectories env export in ~/.zshrc ---
# ~/.zshrc is a shared, hand-edited file (it may already carry an UNMANAGED
# export). We add only our marked line, and on "off" remove ONLY our marked
# line — never a line the user wrote by hand.
ZSHRC="${HOME}/.zshrc"
MARK='# managed by agent_tools/apply-links.sh'
VAR='CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD'
LINE="export ${VAR}=1  ${MARK}"
has_any=0; has_marked=0
if [[ -f "$ZSHRC" ]]; then
  grep -qE "^[[:space:]]*export[[:space:]]+${VAR}=" "$ZSHRC" && has_any=1
  grep -qF "$MARK" "$ZSHRC" && has_marked=1
fi
if [[ "$CLAUDEMD" == 1 ]]; then
  if [[ "$has_any" == 1 ]]; then
    ok "CLAUDE.md export already in ~/.zshrc — no change (no duplicate added)"
  else
    act "printf '%s\n' '$LINE' >> '$ZSHRC'" && ok "added CLAUDE.md export to ~/.zshrc (new shell needed)"
  fi
else
  if [[ "$has_marked" == 1 ]]; then
    act "sed -i.bak '/${MARK//\//\\/}/d' '$ZSHRC'" && info "removed managed CLAUDE.md export from ~/.zshrc (new shell needed)"
  fi
  if [[ "$has_any" == 1 && "$has_marked" == 0 ]]; then
    info "note: an UNMANAGED ${VAR} export remains in ~/.zshrc — left untouched (remove it by hand to fully disable)"
  elif [[ "$has_any" == 0 ]]; then
    info "CLAUDE.md export not present — nothing to remove"
  fi
fi

echo
ok "apply-links done for $CLONE"
