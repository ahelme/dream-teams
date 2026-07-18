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
  | `app`     | Admin panel, frontend, queue-manager, product behaviour |
  | `comfyui` | ComfyUI, workers, inference, models |
- **Status values:** `proposed`, `accepted`, `rejected`, `deprecated`, `superseded`.

## Workflow

- Create a new ADR as `proposed` (via the `/adr` skill).
- Discuss and iterate.
- When the team commits: mark it `accepted` (or `rejected`).
- If replaced later: create a new ADR and mark the old one `superseded` with a link.

## ADRs

### meta
- [Adopt architecture decision records](2026-07-05-meta-adopt-architecture-decision-records.md) (accepted, 2026-07-05)

### teams
- [Team-clone config wiring & identity protection](2026-07-05-teams-clone-config-and-identity.md) (accepted, 2026-07-05)

### ops
- [Provision team clones with new-team.sh, not template-copy](2026-07-05-ops-team-provisioning.md) (accepted, 2026-07-05)
- [Graphify code knowledge-graph — code-only scoping + portable kit](2026-07-06-ops-graphify-code-knowledge-graph.md) (accepted, 2026-07-06)
- [Re-home production on mello and promote split-app to mainline](2026-07-15-ops-rehome-production-on-mello.md) (accepted, 2026-07-15)

### app
- [Admin-Controlled Workflows and Templates](2026-02-27-app-admin-controlled-workflows-and-templates.md) (accepted, 2026-02-27) — formerly "ADR-001"

### comfyui
- [API-first generation — external APIs primary, worker mothballed](2026-07-15-comfyui-api-first-generation.md) (accepted, 2026-07-15)
