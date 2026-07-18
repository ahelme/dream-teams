# Agent Tools

Shared, versioned tooling that every team clone gets **by default** — a `.claude/agent_tools`
committed symlink (mode `120000`) points here from each clone, alongside `agent_docs`,
`hooks`, and `skills`. These are the scripts that provision and configure the Team system
itself, so any team can run them without copying anything.

> **Agents: read this README in full before running any tool here.** It defines what each
> script does, its version, and the safety rules (especially the identity/`.gitignore` guard).

> **ADAPT:** all project-specific paths, repo URLs, and names live in
> `file-paths-registry.sh`. Edit that one file for your project before using these tools.

## Versions

| Tool | Version | Purpose |
|------|---------|---------|
| `new-team.sh` | 1.1.0 | Stand up a fully-wired project clone for a new team. |
| `apply-links.sh` | 1.0.0 | Idempotently apply a clone's Teams-system wiring from its toggles. Also the "update an existing team to current settings" tool. |
| `file-paths-registry.sh` | 1.0.0 | The single place hard-coded dev-server paths live. Edit here when repos move. |
| `team-links.json.template` | — | Template for a clone's per-clone toggle file. |

Bump the `# VERSION:` header in a script **and** this table together when you change one.

## `apply-links.sh` — the six toggles

Each clone may carry `.claude/team-links.json` (local, gitignored). `apply-links.sh` reads it
and makes reality match: `true` → create the symlink, `false` → remove it. Missing file →
all-on default is written from the template. This lets you **disable the full Team system for
a focused, minimal-context task**, then flip it back on.

```jsonc
{
  "claudeMdAdditionalDir": true,   // 1. CLAUDE.md additionalDirectories env export in ~/.zshrc
  "linkAll": true,                 // 2. master gate for the .claude/ symlinks below
  "links": {
    "agent_docs": true,            // 3.
    "skills": true,                // 4.
    "hooks": true,                 // 5.
    "agent_tools": true            //    this toolkit
  },
  "identity": "[ TEAM NAME ]"      // 6. teams-chat.local.md → teams-chat/<slug>.md ("" = none)
}
```

```bash
# apply / re-assert wiring for the current clone
.claude/agent_tools/apply-links.sh
# preview only
.claude/agent_tools/apply-links.sh --dry-run
# operate on another clone
.claude/agent_tools/apply-links.sh --dir /path/to/clone
```

Notes:
- **Toggle 1 (`claudeMdAdditionalDir`) edits `~/.zshrc`** (a sentinel-marked export line) and only
  takes effect in a **new shell** — it cannot change a running Claude Code session.
- `agent_docs`/`hooks`/`skills`/`agent_tools` are *committed* symlinks; toggling one off removes it
  locally (git will show a deletion — don't commit that on a shared branch). Toggling back on
  restores it.
- `.mcp.json` and `.claude/settings.json` are always-on essentials created by `new-team.sh`, not
  gated by toggles.

## `new-team.sh` — provision a new team

```bash
.claude/agent_tools/new-team.sh <slug> "<emoji>" "<name>" \
  [--base <branch>] [--branch <name>] [--dir <path>] [--no-push]
```
Clones the app repo, branches off `$DEFAULT_BASE_BRANCH` (from the registry), creates the
always-on symlinks, seeds `settings.local.json`, creates the team's identity file, writes an
all-on `team-links.json`, then calls `apply-links.sh` to wire the shared symlinks + identity.
Ends with a verify pass (clean tree, all symlinks resolve, `0` `.gitignore` identity-negations).
Refuses to clobber an existing clone.

## Launch aliases — required, NOT yet automated by `new-team.sh`

Wiring the clone is not enough to make the shared `CLAUDE.md` load. A team session **must be
launched with `--add-dir <TEAMS_REPO path>`** — that flag is what actually pulls the Teams-repo
`CLAUDE.md` into context. The `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1`
export (toggle 1) only *enables* additional-dir CLAUDE.md discovery; on its own, launching a bare
`claude` still starts **without** the project instructions. Relying on the export alone is fragile.

The robust mechanism is a **per-team launch alias** in `~/.zshrc` (one direct + one tmux):

```bash
# direct launch
alias claude-<slug>='cd <clone-path> && CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 \
  claude --add-dir [ /path/to/<projectname>_project/teams-repo ] -c --dangerously-skip-permissions'
# persistent tmux session (survives SSH disconnect)
alias tm-claude-<slug>='tmux new-session -As <slug> -c <clone-path>'
```

**This step is currently manual** — `new-team.sh` does *not* add these aliases, so a freshly
provisioned clone whose operator types plain `claude` will silently run without the Teams
`CLAUDE.md` and the session runs context-blind (this has happened in practice).
**When provisioning a team, add both aliases and start a new shell.**
(TODO: fold alias creation into `new-team.sh`.)

## External tools (standalone repos, not in this dir)

These live in their **own repos** and are invoked from a target project, not vendored here.

| Tool | Purpose | Repo |
|---|---|---|
| **graphify-kit** | Optional. Drop-in [graphify](https://pypi.org/project/graphifyy/) knowledge-graph setup for any git repo: scoping (`.graphifyignore`), a versioned Claude Code nudge hook, and **ignition** (initial build + auto-updating post-commit/post-checkout git hooks). Self-contained — no Teams-repo/symlink dependency. | https://github.com/ahelme/graphify-kit |

```bash
git clone https://github.com/ahelme/graphify-kit ~/projects/dev-tools/graphify-kit  # once per machine
cd /path/to/repo && ~/projects/dev-tools/graphify-kit/install.sh                     # per target repo
```

For a **team clone** its unique job is **ignition** (`.graphifyignore`, the nudge hook, and
the `graphify-out/` gitignore already ship via committed files + Teams symlinks). Run it *after*
the Teams symlinks so the nudge step no-ops on the identical hook.

## Guard rails (do not break)

- Never `!`-negate `settings.local.json` or `teams-chat.local.md` in a `.gitignore` — that
  re-arms the identity-overwrite failure mode (one team's identity silently replacing another's).
- Never `cp -r` a clone (dereferences the shared symlinks). Use `new-team.sh`.
- Never edit another team's identity file.

## See also

- ADRs in `agent_docs/ADR/` (clone config + identity model; provisioning-by-script rationale)
- [ ADAPT: link your operator guide / wiki page for team setup here ]
