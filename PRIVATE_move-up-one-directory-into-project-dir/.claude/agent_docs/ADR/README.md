# Architecture Decision Records (ADR)

An Architecture Decision Record captures an important architecture decision along with its context and consequences. These are **binding** — all teams read them before doing related work.

> **Agents: read this README in full before creating or consulting ADRs.** It defines the naming, category, and status conventions this store uses.

## Conventions

- **Directory:** `ADR/` (flat — no subdirectories until the store is large; revisit if it passes ~15 records).
- **Filename:** `YYYY-MM-DD-<category>-<slug>.md`
  - e.g. `2026-07-05-teams-clone-config-and-identity.md`, `2026-07-05-ops-team-provisioning.md`
  - Date sorts chronologically; the category is visible at a glance in `ls`.
- **`category:` front-matter field** (machine-filterable; the index below groups by it).
- **Categories** (mirror our team/commit scopes):
  | Category | Scope |
  |----------|-------|
  | `meta`    | ADR process itself |
  | `teams`   | Claude team org, clone/config, identity, collaboration |
  | `ops`     | Infra, reliability, deploy, backup, tooling, secrets |
  | `[ your-app-scope ]` | [ ADAPT: one category per product scope — e.g. `app` for frontend/API/product behaviour ] |
  | `[ your-app-scope-2 ]` | [ ADAPT: further scopes as needed — e.g. `worker` for workers/inference/pipeline ] |
- **Status values:** `proposed`, `accepted`, `rejected`, `deprecated`, `superseded`.

## Workflow

- Create a new ADR as `proposed` (via the `/adr` skill).
- Discuss and iterate.
- When the team commits: mark it `accepted` (or `rejected`).
- If replaced later: create a new ADR and mark the old one `superseded` with a link.

## ADRs

### meta
- [Adopt architecture decision records](EXAMPLE-2026-07-05-meta-adopt-architecture-decision-records.md) (accepted, 2026-07-05)

### teams
[ ADAPT: index your `teams` ADRs here as they land ]

### ops
[ ADAPT: index your `ops` ADRs here as they land ]

### [ your-app-scope ]
[ ADAPT: one section per app-scope category; index its ADRs here as they land ]
