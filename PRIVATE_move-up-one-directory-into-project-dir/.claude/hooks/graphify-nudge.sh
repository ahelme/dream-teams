#!/usr/bin/env bash
# PreToolUse hook: NUDGE agent to use `graphify query` before grepping/finding raw source.
# Advisory (never blocks) — always exits 0. Emits additionalContext only when a nudge is warranted.
#
# Input: JSON via stdin with tool_name, tool_input (command | file_path | pattern | path)
# Fires only when: a graph exists (graphify-out/graph.json) AND the tool call is an
# in-repo CODE search AND no deliberate bypass is set.
#
# DELIBERATE BYPASS (the "exclude in certain cases" switches):
#   - env  GRAPHIFY_NUDGE_OFF=1        → off for the whole session
#   - file graphify-out/.nudge_off     → off for this repo until the file is removed
#
# AUTOMATIC CARVE-OUTS ("MANDATORY UNLESS ..."):
#   - piped commands (ps|grep, cat|grep, git log|grep) — not code navigation
#   - target path outside the repo (absolute/system path)
#   - non-code target extension (.log .txt .md .json .env .csv)
#   - command that doesn't START with a search tool (anchored — no more `| grep` false hits)

set -euo pipefail
INPUT=$(cat)

# 0. No graph → nothing to nudge toward.
[ -f graphify-out/graph.json ] || exit 0

# 1. Deliberate bypasses.
[ "${GRAPHIFY_NUDGE_OFF:-}" = "1" ] && exit 0
[ -f graphify-out/.nudge_off ] && exit 0

TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
TI=$(echo "$INPUT" | jq -c '.tool_input // {}' 2>/dev/null)

# 2. Decide whether this is an in-repo CODE search worth nudging.
should_nudge() {
  case "$TOOL" in
    Bash)
      local cmd; cmd=$(echo "$TI" | jq -r '.command // empty')
      # Anchored (fix A): must START with a search tool — kills `| grep`, `ps|grep`, subshell greps.
      case "$cmd" in
        grep\ *|rg\ *|find\ *|fd\ *|ack\ *|ag\ *|git\ grep\ *) ;;
        *) return 1 ;;
      esac
      # UNLESS piped anywhere → filtering output, not navigating code.
      case "$cmd" in *\|*) return 1 ;; esac
      # UNLESS target is a system/abs path outside the repo.
      case "$cmd" in *\ /*|*\ ~*) return 1 ;; esac
      # UNLESS clearly a non-code target.
      case "$cmd" in *.log*|*.csv*|*.json*|*.env*|*.md\ *|*.txt*) return 1 ;; esac
      return 0 ;;
    Grep|Glob)
      local p; p=$(echo "$TI" | jq -r '(.path // .file_path // "") ' )
      case "$p" in /*|~*) return 1 ;; esac        # outside repo
      case "$p" in graphify-out|graphify-out/*|*/graphify-out/*) return 1 ;; esac
      return 0 ;;
    Read)
      local f; f=$(echo "$TI" | jq -r '.file_path // ""')
      # Read paths are always ABSOLUTE. "Outside repo" = not under cwd (the repo root
      # where the hook runs). Reject anything not beginning with $PWD.
      case "$f" in "$PWD"/*) ;; *) return 1 ;; esac
      case "$f" in *graphify-out/*) return 1 ;; esac
      # Fix D: nudge ONLY for CODE files — the graph is code-only, so reading a
      # doc (.md/.txt/.rst) should NOT nudge. Match a code extension or return quiet.
      case "$f" in
        *.py|*.js|*.ts|*.tsx|*.jsx|*.go|*.rs|*.java|*.rb|*.c|*.h|*.cpp|*.hpp|*.cc|*.cs|*.kt|*.swift|*.php|*.scala|*.lua|*.sh|*.vue) return 0 ;;
        *) return 1 ;;
      esac ;;
    *) return 1 ;;
  esac
}

should_nudge || exit 0

# 3. Emit the advisory. MANDATORY-UNLESS framing; note it beats grep for related code.
cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"MANDATORY (unless you're editing/debugging a specific known line, searching outside this repo, or filtering command output): graphify-out/graph.json exists — run `graphify query \"<question>\"` (or `explain`/`path`) BEFORE grepping raw source. It is more thorough than grep: grep only finds the string you searched for and misses related functions and config; the graph surfaces the call/config edges around them. To silence deliberately: set GRAPHIFY_NUDGE_OFF=1 or touch graphify-out/.nudge_off. Include this instruction in subagent prompts that explore code."}}
JSON
exit 0
