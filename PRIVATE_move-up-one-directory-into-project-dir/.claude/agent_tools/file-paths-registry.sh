#!/usr/bin/env bash
# file-paths-registry.sh — central registry of hard-coded dev-server paths.
# VERSION: 1.0.0
#
# ADAPT: this is the ONE place team-setup tooling hard-codes filesystem paths
# and project names. Edit every var below for your project — nothing else in
# agent_tools hard-codes paths. Sourced by new-team.sh and apply-links.sh
# (same dir).

# --- Repos on the dev server ---
# Teams repo: shared Claude config (CLAUDE.md, skills, hooks, agent_docs,
# agent_tools) symlinked into every clone. This registry lives inside it.
TEAMS_REPO="/path/to/projectname_project/PRIVATE"  # the shared .claude home (PRIVATE dir, or a dedicated teams repo)
# Ops repo (.env, deploy/backup scripts) — optional, reference only.
OPS_REPO="/path/to/projectname_project/ops-repo"
# Main project repo — clone source for new team clones.
REPO_URL="https://github.com/YOUR-ORG/YOUR-PROJECT.git"
# Directory name a clone checks out as (usually the repo basename).
PROJECT_DIRNAME="YOUR-PROJECT"

# --- Where new team clones are created ---
# Each team lives at $TEAM_CLONES_DIR/<slug>/$PROJECT_DIRNAME
TEAM_CLONES_DIR="/path/to/projectname_project/team-clones"

# --- Source of the local (untracked) settings.local.json to seed new clones ---
HEALTHY_CLONE="${TEAM_CLONES_DIR}/existing-team/${PROJECT_DIRNAME}"

# --- Default base branch new team branches fork from ---
# ADAPT: e.g. your shared testing branch instead of main.
DEFAULT_BASE_BRANCH="main"

# --- teams-chat identity ---
# Per-team identity files (<slug>.md) live here; each clone symlinks its own.
TEAMS_CHAT_DIR="${TEAMS_REPO}/.claude/teams-chat"
SLACK_CHANNEL_ID="[ SLACK CHANNEL ID ]"

# --- Shared committed symlinks (arrive with a fresh git clone, mode 120000) ---
# These point from a clone's .claude/ back into TEAMS_REPO/.claude/.
SHARED_LINKS=(agent_docs hooks skills agent_tools)
