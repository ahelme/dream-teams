# CLAUDE.md — Dream Teams section (example)

> Copy this section into your project's CLAUDE.md and fill the [ TOKENS ].
> It is everything an agent must know to operate inside a Dream Team.
> Full detail lives in the dream-teams repo README and the files below.

## Dream Team

This project runs a multi-agent Dream Team (github.com/ahelme/dream-teams).

- **You are one agent among several.** Your identity: `.claude/teams-chat.local.md`
  (name, emoji, team). No identity yet → run `/new-identity`.
- **Shared system** lives OUTSIDE the repo in
  `[ /path/to/<projectname>_project ]/PRIVATE/.claude/` — your clone's
  `.claude/{agent_docs,agent_tools,hooks,skills,settings.json}` symlink there.
  Broken/missing links → run `.claude/agent_tools/apply-links.sh`.
- **Clones**: one per agent under `[ /path/to/<projectname>_project ]/`.
  The deploy clone is `[ /path/to/deploy-clone or "n/a" ]` — dev clones never
  serve production.

### Session ritual
- Start: `/resume-context` (reads session log + progress + chat).
- End (or before compact): `/handover` → `/update-session-log`.
- Shared session log: `all-teams-session-log.md` symlink in the clone root
  (target: `PRIVATE/.claude/agent_docs/untracked/`). Newest first. GENERATED —
  write only your own `session-logs/<your-slug>.md`, then run
  `.claude/agent_tools/bin/team-log` to restitch.

### Record-keeping (agent_docs/, via symlink)
- Every commit → one line in `agent_docs/progress-all-teams.md`
  (`- [TEAM] [HASH] [type]: description (#issue)`) + your team's
  `progress-<team>.md`. Skill: `/update-progress`.
- Binding decisions → `agent_docs/ADR/` via `/adr` (read before related work).
- Plans → `agent_docs/plans/`; analyses → `agent_docs/analysis/`.

### Git & branches
- Work on `[ TEAM BRANCH PATTERN or INTEGRATION BRANCH ]`; PR to
  `[ INTEGRATION BRANCH ]` (`/pr-test`), promote to `[ MAIN BRANCH ]`
  (`/pr-prod`). Never deploy unapproved branches.

### Team chat
- Protocol: [ mattermost per-agent bots | slack shared app | slack per-agent apps ]
- Post `team-say "msg"`, read `team-hear` (`agent_tools/bin/`); check-in skill:
  `/[ check-slack | check-slack-shared-slack-app | check-slack-app-per-agent ]`.
- Milestones (commit/push/PR/deploy) auto-echo to chat when your identity file
  has `active: true`.

### Per-agent files — UNTRACKED, never commit
`.claude/team-links.json` · `.claude/settings.local.json` (merge, don't
replace) · `.claude/teams-chat.local.md` — rules in
`PRIVATE/.claude/settings-json-registry.md`.

### Ops quick refs (fill from your skills)
- Deploy test: `/deploy-test` → [ ONE-LINE SUMMARY ]
- Deploy prod: `/deploy-prod` → [ ONE-LINE SUMMARY ]
- Health: `/health-check` · Backups: `/backup-check` · Monitoring:
  `/monitoring-check` [ or "not set up" ]

### House rules
- [ SERVER ETIQUETTE — shared box? disk/RAM limits? port rules? ]
- Secrets NEVER in the repo — real values in `PRIVATE/` only
  (the `block-secrets.sh` hook enforces patterns).
- graphify: `graphify query "<question>"` before grepping when
  `graphify-out/graph.json` exists (nudge hook active).
