---
name: deploy-test
description: >
  SUPERSEDED (2026-07-15 re-home, ADR ops/rehome) — testing now deploys
  LOCALLY on mello via /deploy-mello-test. This skill used to deploy
  all-teams-testing to the retired Verda testing box (anegg.app /
  fair-snow, on death row). Do NOT run the old flow. Tombstone kept until
  fair-snow is deleted, then this skill is removed.
user-invocable: true
version: 2.0.0
---

# /deploy-test — SUPERSEDED, do not use

**The Verda testing server (anegg.app / fair-snow) is being decommissioned**
(round-earth already deleted 2026-07-15; fair-snow follows ~48h after
prod-on-mello is live — #639/#642).

| You wanted | Use instead |
|---|---|
| Deploy the testing stack | **`/deploy-mello-test`** — deploys locally on mello at https://mello-testing.aiworkshop.art (no SSH, no SFS, split-app) |
| Deploy production | **`/deploy-prod`** (being refreshed for prod-on-mello, #639) — never without explicit approval |
| Config-only change | `/deploy-config` |

**Do not SSH to 65.108.33.109 to deploy.** The box still answers while on
death row, but nothing new ships there — deploys to it are wasted work and
create confusing state during the decommission.

The full legacy flow (image tagging/retag rules, Infisical Tier-0 overlay,
disk preflight, 5-user scaling) lives in git history: `git log --follow --
.claude/skills/deploy-test/SKILL.md` (v1.1.0). The retag rules referenced by
other skills were copied into `/deploy-mello-test` step 3.
