---
status: accepted
date: 2026-07-05
category: meta
decision-makers: Aeon, Rho, Coda, Scripp
---

# Adopt architecture decision records

## Context and Problem Statement

Architecture decisions in this project are made implicitly — through code, conversations, and tribal knowledge. When a new contributor (human or AI agent) joins the codebase, there is no record of *why* things are built the way they are. This makes it hard to:

- Understand whether a pattern is intentional or accidental
- Know if a past decision still applies or has been superseded
- Avoid relitigating decisions that were already carefully considered

We need a lightweight, version-controlled way to capture decisions in one shared, cross-team location. ComfyuMe is built by three parallel Claude teams (Rho — admin panel, Coda — backend/inference, Scripp — ops/reliability) plus Aeon coordinating. Shared decisions must be visible to every team and to every future Claude session. An informal `architectural_decision_log.md` existed in `.claude/agent_docs/` (one entry: ADR-001, Admin-Controlled Workflows) but was never maintained, and the `/adr` skill that would formalise the process had never been used (and was in fact broken — see #593).

## Decision

Adopt Architecture Decision Records (ADRs) using the `/adr` skill (MADR / simple templates), stored in **`.claude/agent_docs/ADR/`** in the Teams Repo (`claude-code-comfyume-teams`), reachable from every team clone via the symlinked `agent_docs/`.

**Why the Teams Repo's `agent_docs/`, not the main `comfyume-v1` repo:** ADRs here are cross-team coordination artifacts that sit alongside the other core docs (CLAUDE.md, progress files, gotchas) every Claude session already loads. `agent_docs/` is already symlinked into each clone, so ADRs are reachable at `.claude/agent_docs/ADR/` from any team's project with no new symlinks and no main-repo churn.

Conventions:
- Location: `.claude/agent_docs/ADR/` (decisions) and `.claude/agent_docs/plans/` (implementation plans)
- One ADR per file, named `YYYY-MM-DD-title-with-dashes.md`
- New ADRs start as `proposed`, move to `accepted` or `rejected`
- Superseded ADRs link to their replacement
- ADRs are self-contained — a coding agent should be able to read one and implement the decision without further context
- When an ADR (or any work) produces an implementation plan, save it in `.claude/agent_docs/plans/`

## Consequences

* Good, because decisions are discoverable and version-controlled alongside the code
* Good, because new contributors (human or agent) can understand the "why" behind architecture choices
* Good, because the team builds a shared decision log that prevents relitigating settled questions
* Bad, because writing ADRs takes time — though a good ADR saves more time than it costs
* Neutral, because ADRs require periodic review to mark outdated decisions as deprecated or superseded

## Implementation Plan

- **Affected paths**: `.claude/agent_docs/ADR/` (new), `.claude/agent_docs/plans/` (new), `.claude/skills/adr/` (skill fixes), `CLAUDE.md` + core agent_docs + per-team resume/handover skills (ADR pointers)
- **Dependencies**: Node.js (already present, v20) for the `/adr` skill scripts
- **Patterns to follow**: run the `/adr` skill to create/update ADRs; `node .claude/skills/adr/scripts/new-adr.js --title "..." --status proposed --update-index`; save any implementation plan to `.claude/agent_docs/plans/`
- **Patterns to avoid**: do not add new decisions to the retired `architectural_decision_log.md` (removed); do not scatter ADRs into the main repo or wiki

### Verification

- [x] `ADR/` and `plans/` exist under `.claude/agent_docs/`
- [x] `/adr` skill scripts run without error (bootstrap + new-adr smoke-tested)
- [x] ADR-001 (Admin-Controlled Workflows) ported; old `architectural_decision_log.md` removed
- [x] `progress-all-teams.md` cross-team pointer updated to `ADR/`
- [x] ADR + skill referenced from CLAUDE.md, core docs, and per-team resume/handover skills
- [x] Wiki front page points to `ADR/` and where to find docs on Mello

## Alternatives Considered

* No formal records: Continue making decisions in conversations and code comments. Rejected because context is lost and decisions get relitigated.
* Wiki or Notion pages: Capture decisions outside the repo. Rejected because they drift out of sync with the code and are not version-controlled.
* Lightweight RFCs: More heavyweight process with formal review cycles. Rejected as overkill for most decisions — ADRs can scale up to RFC-level detail when needed.

## More Information

* Setup tracked in [comfyume-v1#593](https://github.com/ahelme/comfyume-v1/issues/593)
* `/adr` skill: `.claude/skills/adr/SKILL.md`
* Ported first decision: [ADR-001 Admin-Controlled Workflows and Templates](2026-02-27-app-admin-controlled-workflows-and-templates.md)
* MADR: <https://adr.github.io/madr/>
* Michael Nygard, "Documenting Architecture Decisions": <https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions>
