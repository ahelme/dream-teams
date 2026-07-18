# teams-template

A starter kit for running **multi-agent Claude Code teams** on a shared
project: skills, identity protocols, shared docs, hooks, and provisioning
tools — copied from two battle-tested projects (YETI and ComfyuMe) and
genericized. Everything project-specific is an `[ ADAPT ]` placeholder or a
`[ SYSTEM DETAILS HERE ]` block: expect a deliberate adaptation pass, not a
zero-config install.

## What's in the box

```
teams-template/
├── README.md                  ← you are here
├── all-teams-session-log.md   ← symlink (dangling on purpose — see setup §3)
├── plugins/                   ← teams-chat, team-detect, cleanup-orphaned-mcp (+README)
└── PRIVATE_move-up-one-directory-into-project-dir/
    └── .claude/
        ├── agent_docs/        ← shared docs: ADR/, analysis/, plans/, progress templates,
        │                        untracked/all-teams-session-log.md
        ├── agent_tools/       ← provisioning: new-team.sh, apply-links.sh,
        │                        file-paths-registry.sh, team-links.json.template,
        │                        bin/team-say, bin/team-hear, ralph_loop/
        ├── hooks/             ← block-secrets.sh, graphify-nudge.sh
        ├── skills/            ← 37 skills (tables below)
        ├── settings.json      ← shared Claude Code settings (hooks wiring)
        ├── settings-json-registry.md  ← per-agent untracked files: the rules
        ├── skills-registry.md ← how skills are registered/invoked
        └── teams-chat/        ← identity files, one per agent (EXAMPLE-team.md)
```

### Skills — session rituals & identity (from YETI)

| Skill | Does |
|---|---|
| `new-identity` | Establish name/emoji/identity file when joining a project |
| `resume-context` | Session-start ritual: read trail, check chat, brief human |
| `handover` | Session-end checklist: land code, verify, log, keep ears armed |
| `update-session-log` | Prepend terse entry with UTC time and resume id |
| `relax-unwind` | Deliberate rest ritual with a generative visual |
| `ears` | Arm the per-session chat-mention wake listener |
| `check-waker` | 30-second read-only health pass of the wake system |
| `adr` | Capture/consult short Architecture Decision Records; supersede cleanly |
| `check-slack-app-per-agent` | Read team Slack, optionally post (PER-AGENT app protocol) |
| `update-slack-app-per-agent` | Post status update to team Slack (PER-AGENT app protocol) |

### Skills — git, PRs & project management (from ComfyuMe)

| Skill | Does |
|---|---|
| `gi` | Create GitHub issue with milestone, team label, board assignment |
| `issue` | Analyze and fix a GitHub issue end-to-end |
| `inv` | Systematic investigation of broken behavior; `--deep` root-cause tracing |
| `fix` | Apply a diagnosed fix: plan, blast radius, verify, document |
| `pr-test` | Commit, push, PR to [ INTEGRATION BRANCH ]; scanners only |
| `pr-prod` | Commit, push, PR to [ MAIN BRANCH ]; ultrareview loop |
| `pull-main` / `pull-test` | Fetch and merge main / integration branch into current |
| `rb` | Rotate team branch date suffix to today |
| `review-pr-comments` | Triage automated PR findings, resolve conversations |
| `update-progress` | Update team/central progress files, issues, team chat |

### Skills — ops & monitoring (from ComfyuMe)

| Skill | Does |
|---|---|
| `deploy-test` / `deploy-prod` | Guided deploys with confirmations and gated verification |
| `health-check` | Quick endpoints/containers/disk/cron/error-tracker pass |
| `backup-check` | Verify real backups vs live data, report drift honestly |
| `check-versions` | Verify pinned versions against live registries, never memory |
| `create-release` | Git tag + GitHub release with pin-tag convention |
| `monitoring-check` | One-shot health check of the whole monitoring stack |
| `grafana` / `loki` / `prometheus` | Per-tool checks and queries via their APIs |
| `dry` | Docker TUI launch help plus non-interactive equivalents |

### Skills — culture (both projects)

| Skill | Does |
|---|---|
| `check-slack-shared-slack-app` | Read/post team Slack via the SHARED-app protocol (rename to `check-slack` when adopted) |
| `celebrate` | End-of-session reflection ritual |
| `smoko` | Creative break menu |
| `ground` | Grounding pause for stuck, tense, or heavy moments |
| `terse-style` | Telegraphic-style rewriter for docs and updates |

## The two Slack identity protocols — choose one per project

1. **Per-agent app** (YETI style): every agent has their own Slack app, handle
   and emoji. Nicest identities; **Slack caps how many apps you can create**.
   Skills: `check-slack-app-per-agent`, `update-slack-app-per-agent`.
2. **Shared app** (ComfyuMe style): ONE Slack app for all agents; each message
   is prefixed with the agent's emoji + name from their untracked identity file
   (`.claude/teams-chat.local.md`). Needs the `plugins/teams-chat` plugin and a
   transport (webhook/bot-token built into `agent_tools/bin/team-say`,
   `team-hear`). When you adopt this, rename
   `check-slack-shared-slack-app` → `check-slack`.

---

# Setting up a new Team

## 1. File structure

Target shape (one parent dir per project; PRIVATE and every agent clone live
inside it):

```
<projectname>_project/
├── PRIVATE/                          ← from PRIVATE_move-up-one-directory-into-project-dir/
│   └── .claude/
│       ├── agent_docs/  agent_tools/  hooks/  skills/  teams-chat/
│       ├── settings.json  settings-json-registry.md  skills-registry.md
│       └── agent_docs/untracked/all-teams-session-log.md
├── teams-template/                   ← your clone of THIS repo
├── <agent-1>/<project-clone>/        ← one codebase clone per agent (or team)
├── <agent-2>/<project-clone>/
└── ...
```

Steps:
1. Ensure a parent folder `<projectname>_project/` exists.
2. Clone this repo into it: `git clone <teams-template-url> <projectname>_project/teams-template`
3. Copy `PRIVATE_move-up-one-directory-into-project-dir/` up into the parent
   folder and rename it to just `PRIVATE`:
   `cp -a teams-template/PRIVATE_move-up-one-directory-into-project-dir <projectname>_project/PRIVATE`
4. Clone the project codebase once per agent (or team), each in its own dir.

> Depth notes (learned by dogfooding):
> - Links created *inside* `.claude/` need one MORE `..` than links in the
>   clone root: for `<projectname>_project/<agent>/<clone>/`, the clone-root
>   session-log symlink is `../../PRIVATE/...` but `.claude/agent_docs` is
>   `../../../PRIVATE/...`. Absolute paths (what `apply-links.sh` uses via
>   `file-paths-registry.sh`) avoid the whole question — set the registry first.
> - COMMITTING the `.claude/*` symlinks (ComfyuMe style) only works when every
>   clone sits at the same depth. If depths differ (e.g. a dev clone at a
>   different level), instead gitignore the wiring (`.claude/` +
>   `all-teams-session-log.md`) and wire each clone locally.

## 2. Per-clone files

Copy the remaining template root files into each agent's clone as needed
(**MERGE with existing files if your project already has them** — e.g.
`.gitignore` additions, CLAUDE.md sections).

## 3. Symlinks into PRIVATE (per clone)

From each agent clone, link the shared system (MERGE any existing dirs' content
into PRIVATE first, then replace with links):

```
.claude/agent_docs    -> /path/to/<projectname>_project/PRIVATE/.claude/agent_docs/
.claude/agent_tools   -> /path/to/<projectname>_project/PRIVATE/.claude/agent_tools/
.claude/hooks         -> /path/to/<projectname>_project/PRIVATE/.claude/hooks/
.claude/settings.json -> /path/to/<projectname>_project/PRIVATE/.claude/settings.json   ← MERGE with your current file FIRST
.claude/skills        -> /path/to/<projectname>_project/PRIVATE/.claude/skills/
all-teams-session-log.md -> ../PRIVATE/.claude/agent_docs/untracked/all-teams-session-log.md  (adjust depth)
```

`agent_tools/apply-links.sh` automates the `.claude/*` links (after you set
`file-paths-registry.sh`); `new-team.sh` provisions a whole clone.

## 4. Per-agent untracked files

Follow **`PRIVATE/.claude/settings-json-registry.md`** to set up each agent's
individual files in their clone — and UNTRACK them:

1. `.claude/team-links.json` (from `agent_tools/team-links.json.template`)
2. `.claude/settings.local.json` (**MERGE, never replace**)
3. `.claude/teams-chat.local.md`

## 5. Identities

Create one identity file per agent in `PRIVATE/.claude/teams-chat/<agent>.md`
(copy `EXAMPLE-team.md`): name, emoji, role, prefix convention. Each agent's
`.claude/teams-chat.local.md` links/copies to their file. Run `/new-identity`
for the joining ritual.

## 6. Slack

Default to the SHARED app protocol (one app, e.g. "Team Chat", for ALL agents)
unless your workspace still has app headroom for per-agent apps:
- Install `plugins/teams-chat` (see `plugins/README.md`), wire a transport
  (webhook URL or bot token) for `team-say`/`team-hear`.
- Each agent uses their own untracked `teams-chat.local.md` identity file.
- Rename the skill: `check-slack-shared-slack-app` → `check-slack`.

## 7. Adapt every skill

Walk `PRIVATE/.claude/skills/` and fill every `[ ADAPT ]` and
`[ ... SYSTEM DETAILS ... ]` block with your project's real systems, URLs,
branch names, and protocols. Check each against reality — the skeletons came
from other projects' muscle memory.

Placeholders come in exactly two forms — `[ TOKEN ]` (a value to substitute)
and `[ ADAPT: explanation ]` (a decision/procedure to adapt); find every
remaining one with `grep -rn "\[ " skills/`.

## 8. graphify

Install [graphify](https://github.com/safishamsi/graphify-kit) per project
clone and build the graph. The `PRIVATE/.claude/hooks/graphify-nudge.sh`
PreToolUse hook (wired in `settings.json`) nudges agents to query the graph
before grepping; it silently no-ops until a graph exists. The nudge script
excludes `.md` docs by default (in case docs are stale) — once your docs are
trustworthy, edit the script's extension list to re-include them (ideally ALL
`.md` docs).
