# Dream Teams

**Dream Teams** is a starter kit for running **multi-agent Claude Code teams** on a shared
project: skills, identity protocols, shared docs, hooks, and provisioning
tools — copied from two battle-tested projects (YETI and ComfyuMe) and
genericized. Everything project-specific is an `[ ADAPT ]` placeholder or a
`[ SYSTEM DETAILS HERE ]` block: expect a deliberate adaptation pass, not a
zero-config install.

## What's in the box

```
dream-teams/
├── README.md
├── CLAUDE.example.md          ← paste-into-your-CLAUDE.md team operating section                  ← you are here
├── all-teams-session-log.md   ← symlink (dangling on purpose — see setup §3)
├── plugins/                   ← teams-chat, team-detect, cleanup-orphaned-mcp (+README)
└── PRIVATE_move-up-one-directory-into-project-dir/
    └── .claude/
        ├── agent_docs/        ← shared docs: ADR/, analysis/, plans/, progress templates,
        │                        untracked/session-logs/<agent>.md (write yours ONLY),
        │                        untracked/all-teams-session-log.md (GENERATED)
        ├── agent_tools/       ← provisioning: new-team.sh, apply-links.sh,
        │                        file-paths-registry.sh, team-links.json.template,
        │                        bin/team-say, bin/team-hear, bin/team-log, ralph_loop/
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

## Team chat — three identity protocols, choose one per project

1. **Mattermost, per-agent bots** (recommended): open source, self-hostable,
   **no limit on bot accounts** — every agent gets a real account with their
   own name and avatar. Plugins: `teams-chat` (core) +
   `teams-chat-mattermost`. Configure `MATTERMOST_URL` / `MATTERMOST_TOKEN`
   (per agent) / `MATTERMOST_CHANNEL_ID`; `team-say`/`team-hear` auto-detect.
2. **Slack, shared app** (ComfyuMe style): ONE Slack app for all agents; each
   message is prefixed with the agent's emoji + name from their untracked
   identity file (`.claude/teams-chat.local.md`). Plugins: `teams-chat` +
   `teams-chat-slack`. When you adopt this, rename
   `check-slack-shared-slack-app` → `check-slack`.
3. **Slack, per-agent apps** (YETI style): every agent their own Slack app,
   handle and emoji. Nicest Slack identities, but **Slack caps app count**.
   Skills: `check-slack-app-per-agent`, `update-slack-app-per-agent`.

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
├── dream-teams/                   ← your clone of THIS repo
├── <agent-1>/<project-clone>/        ← one codebase clone per agent (or team)
├── <agent-2>/<project-clone>/
└── ...
```

Steps:
1. Ensure a parent folder `<projectname>_project/` exists.
2. Clone this repo into it: `git clone <dream-teams-url> <projectname>_project/dream-teams`
3. Copy `PRIVATE_move-up-one-directory-into-project-dir/` up into the parent
   folder and rename it to just `PRIVATE`:
   `cp -a dream-teams/PRIVATE_move-up-one-directory-into-project-dir <projectname>_project/PRIVATE`
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

> **Session logs are per-agent + stitched.** No agent writes the combined
> `all-teams-session-log.md` — each prepends to their own
> `agent_docs/untracked/session-logs/<agent-slug>.md` and runs
> `agent_tools/bin/team-log`, which regenerates the combined newest-first
> view (the clone-root symlink above points at that generated view, so
> *reading* works exactly as before). One agent = one file kills write
> contention between concurrent sessions today — and if the logs ever move
> into a git-synced teams repo, per-agent files mean no merge conflicts
> either.

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
