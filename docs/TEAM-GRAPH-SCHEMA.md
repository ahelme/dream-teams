# Dream Teams Agents Graph — `team.yaml` schema (v1)

One file is the source of truth for a whole team: who the agents are, what
they may touch, which channels they speak in, and which pieces of the kit
catalogue each one enables. Everything else — identity stubs, session logs,
chat profiles, branch names — is *derived* from it by `bin/team-graph`.

Design rules:

- **The graph is declarative.** `team.yaml` says what the team looks like;
  `team-graph scaffold` makes the filesystem match. Hand-editing generated
  files is fine, but structural changes belong in the YAML.
- **Catalogue vs. enablement.** The kit ships a catalogue (all skills, hooks,
  plugins, agent_docs that exist). Agents *enable subsets*. `team-graph
  validate` rejects an enablement that names something not in the catalogue —
  typos fail loudly at config time, not silently at runtime.
- **No secrets.** `team.yaml` is committed. Tokens, webhook URLs and other
  credentials stay in env files / the container secrets mount; the YAML holds
  only *names* of things (`channel: "#team-main"`), never credentials.

## Top-level shape

```yaml
version: 1            # schema version; bump on breaking changes

project:              # the project this team works on
channels:             # where the team talks
claude_md:            # the shared brain
catalogue:            # what exists (skills/hooks/plugins/agent_docs)
users:                # the humans
messaging:            # which chat app carries the channels
graph:                # team-level roles: coach, deployer, size
agents:               # one entry per agent — the nodes of the graph
```

## Sections

### `project`

```yaml
project:
  name: split-app                # short slug; used in branch patterns
  description: "Split the monolith into services"
  repo: ahelme/split-app         # owner/repo the agents push to
```

### `channels`

`main` and `coaching` are required (they're what the teams-chat plugin and
the coach loop assume). Any number of extra channels may be added.

```yaml
channels:
  main: "#split-app"             # main messaging channel
  coaching: "#split-app-coach"   # coach ↔ agents channel
  extra:
    - name: "#split-app-alerts"
      purpose: "CI + monitoring noise, so main stays humane"
```

### `claude_md`

Path (relative to project root) of the main CLAUDE.md every agent loads.
The configurator's add/upload/edit buttons write this file; the YAML only
points at it.

```yaml
claude_md: CLAUDE.md
```

### `catalogue`

What exists in this deployment of the kit. `team-graph scaffold --refresh-catalogue`
regenerates this section by scanning `.claude/skills/*/`, `.claude/hooks/*.sh`,
`plugins/*/` and `.claude/agent_docs/*/` — so the catalogue never drifts from
the filesystem. Hand-added entries are allowed (e.g. project-local skills).

```yaml
catalogue:
  skills: [adr, backup-check, celebrate, check-versions, deploy-test, dry,
           ears, fix, ground, handover, health-check, resume-context, smoko,
           update-progress, update-session-log]   # ...etc, scanned
  hooks: [block-secrets, graphify-nudge]
  plugins: [teams-chat, teams-chat-slack, teams-chat-mattermost,
            team-detect, cleanup-orphaned-mcp]
  agent_docs: [ADR, analysis, plans]
```

### `users`

The humans in the loop. `handle` is the chat @-handle. Other fields that
have proven relevant: timezone (the coach paces standups by it), notify
(what may ping this human), and git identity (so `Co-Authored-By` trailers
and PR reviews map to a real account).

```yaml
users:
  - handle: "@aeh"
    role: operator            # operator | reviewer | stakeholder
    timezone: Australia/Sydney
    notify: [blockers, milestones]   # blockers | milestones | mentions | all
    github: ahelme
```

### `messaging`

```yaml
messaging:
  app: mattermost             # mattermost | slack | other
  # For `other`, point at setup instructions; for the known two, the
  # matching teams-chat-* plugin README is the config reference.
  config: plugins/teams-chat-mattermost/README.md
```

### `graph`

Team-level structure. `agents` is the declared size and must equal the
length of the `agents:` list — a deliberately redundant check, because size
mismatches are the most common hand-edit error.

```yaml
graph:
  team_coach: true            # spawn a coach agent (y/n)
  team_deployer: patch        # agent name holding deploy skills, or false
  agents: 4
```

### `agents` — the nodes

One entry per agent. Everything an agent is allowed to do is stated here.

```yaml
agents:
  - name: patch               # unique; lowercase slug
    role: backend             # free text, shows in chat profile + logs
    identity: .claude/identities/patch.md   # add/upload/edit via configurator
    context_files:            # extra files loaded into this agent's context
      - .claude/agent_docs/plans/split-plan.md
    permissions: default      # readonly | default | trusted
                              # maps to a settings.json permission preset
    shared_files:             # the file-access edges of the graph
      read:  [services/, docs/]
      write: [services/billing/]
    enable:                   # subsets of `catalogue` — validated against it
      skills: [fix, dry, handover, update-session-log, update-progress]
      hooks: [block-secrets]
      plugins: [teams-chat, teams-chat-mattermost]
      agent_docs: [ADR, plans]
    git:
      branch_pattern: "claude/{agent}-{feature}"   # {agent}, {project}, {feature}, {date}
      rotation: per-feature   # per-feature | per-session | fixed
```

`permissions` presets (applied by scaffold into the agent's settings):

| preset     | meaning                                                        |
|------------|----------------------------------------------------------------|
| `readonly` | read + search only; no Edit/Write/Bash-mutating permissions    |
| `default`  | kit's shipped `settings.json` as-is                            |
| `trusted`  | default plus deploy/release skills allowed without prompting   |

## The graph, literally

`team-graph mermaid team.yaml` renders the config as a Mermaid diagram:
agents as nodes; edges to the channels they post in, the paths they may
write, and coach→agent coaching edges. Paste it into any README — or let
the stitch-session-log Action append it to the combined log header so the
team's shape is always visible next to what it did.

## Why YAML (decision)

JSON was the alternative. YAML wins here because the file is *hand-edited
between scaffolds* — comments are load-bearing (the examples above lean on
them), multi-line strings appear in identity blurbs, and diffs read well in
PRs. The CLI accepts `.yaml` only; the web configurator emits the same.
