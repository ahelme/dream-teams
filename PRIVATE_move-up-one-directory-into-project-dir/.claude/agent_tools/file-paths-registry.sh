#!/usr/bin/env bash
# file-paths-registry.sh — central registry of hard-coded Mello (dev server) paths.
# VERSION: 1.0.0
#
# This is the ONE place team-setup tooling hard-codes filesystem paths.
# When we move the ops/teams repos to their new homes, edit the vars here only.
# Sourced by new-team.sh and apply-links.sh (same dir).

# --- Repos on Mello ---
# Claude config (CLAUDE.md, skills, hooks, agent_docs, agent_tools, ADRs) —
# symlinked into every clone. This registry now lives inside it (agent_tools/).
TEAMS_REPO="/home/dev/projects/claude-code-comfyume-teams"
# Ops repo (.env, deploy/backup scripts) — retained for reference; team-setup
# tooling moved OUT of it into TEAMS_REPO/.claude/agent_tools (2026-07-06).
OPS_REPO="/home/dev/projects/comfymulti-scripts"
# Main project repo — clone source for new team clones
REPO_URL="https://github.com/ahelme/comfyume-v1.git"

# --- Where new team clones are created ---
# Each team lives at $TEAM_CLONES_DIR/<slug>/comfyume-v1
TEAM_CLONES_DIR="/home/dev/projects/comfyume-new/team-clones"

# --- Source of the local (untracked) settings.local.json to seed new clones ---
HEALTHY_CLONE="/home/dev/projects/testing-mello-scripts-team/comfyume-v1"

# --- teams-chat identity ---
# Per-team identity files (<slug>.md) live here; each clone symlinks its own
TEAMS_CHAT_DIR="${TEAMS_REPO}/.claude/teams-chat"
SLACK_CHANNEL_ID="C0AHFTPDABX"

# --- Shared committed symlinks (arrive with a fresh git clone, mode 120000) ---
# These point from a clone's .claude/ back into TEAMS_REPO/.claude/.
# agent_tools joined the family 2026-07-06 (this toolkit).
SHARED_LINKS=(agent_docs hooks skills agent_tools)

# --- Planned future homes (placeholders exist; NOT yet in use) ---
#   TEAMS_REPO -> /home/dev/projects/comfyume-new/teams-repo--placeholder-only
#   OPS_REPO   -> /home/dev/projects/comfyume-new/ops--placeholder-only
# When those moves happen, update TEAMS_REPO / OPS_REPO above — nothing else hard-codes paths.
