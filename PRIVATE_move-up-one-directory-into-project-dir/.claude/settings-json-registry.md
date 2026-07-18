# settings-json-registry — per-agent files in each codebase clone

Every agent gets their own clone of the project codebase. Most of the Teams
system is SHARED (symlinked into `PRIVATE/.claude/`), but three files are
**per-agent, per-clone, and UNTRACKED** — they carry the agent's individual
identity and local wiring, and must never be committed:

| File (in the agent's clone) | Purpose | Merge or create? |
|---|---|---|
| `.claude/team-links.json` | Per-clone toggles for the Teams-system symlinks (see `agent_tools/README.md`). Copy from `agent_tools/team-links.json.template`; set `identity` to this agent's slug. | Create from template |
| `.claude/settings.local.json` | The agent's local Claude Code settings (permissions, env). | **MERGE** with any existing file — never replace |
| `.claude/teams-chat.local.md` | The agent's identity file: name, emoji, role, message-prefix convention. Usually a symlink to `teams-chat/<agent-slug>.md` (created by `apply-links.sh` from the `identity` toggle) or a standalone file. | Create per agent |

## Untracking — do this for every clone

These paths must be ignored by git. Check the project `.gitignore` covers them;
if the repo ever tracked them, untrack without deleting:

```bash
# in the agent's clone
printf '.claude/team-links.json\n.claude/settings.local.json\n.claude/teams-chat.local.md\n' >> .gitignore
git rm -r --cached .claude/team-links.json .claude/settings.local.json .claude/teams-chat.local.md 2>/dev/null
git status   # verify none of the three shows as tracked
```

(Commit the `.gitignore` change itself on your team branch if it's new.)

## Setup order for a new agent

1. Clone the codebase into `<projectname>_project/<agent-or-team-clone-dir>/`.
2. Run `agent_tools/apply-links.sh --dir <clone>` — wires the shared symlinks
   (`agent_docs`, `skills`, `hooks`, `agent_tools`) and writes a default
   `team-links.json` if missing.
3. Edit `.claude/team-links.json`: set `identity` to the agent's slug
   (must match a file in `teams-chat/`, e.g. `willow` → `teams-chat/willow.md`).
4. Create the identity file `teams-chat/<agent-slug>.md` (copy
   `teams-chat/EXAMPLE-team.md`): name, emoji, role, prefix convention.
5. MERGE any needed local permissions into `.claude/settings.local.json`
   (never overwrite what's already there).
6. Re-run `apply-links.sh` — it links `.claude/teams-chat.local.md` to the
   identity file.
7. Verify untracking (section above), then introduce yourself with the
   `/new-identity` skill.

## Shared vs per-agent — the rule of thumb

If two agents could ever want different values, it's per-agent and untracked.
If every agent must see the same thing, it lives in `PRIVATE/.claude/` and is
reached by symlink. `settings.json` (shared hooks wiring) is shared;
`settings.local.json` (personal permissions) is per-agent.
