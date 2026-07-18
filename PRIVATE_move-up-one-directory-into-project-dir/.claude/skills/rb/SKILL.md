---
name: rb
description: Rotate branch — rename current team branch date suffix to match today's AEDT date. Use at session start when branch date doesn't match AEDT, or when user says "rotate branch", "update branch", "rename branch to today", or "/rb".
user-invocable: true
version: 1.1.0
---

# Rotate Branch

Team branches (from 2026-04-17): `[deploy-branch]-[team-short]-YYYY-MM-DD`. Date suffix must match current AEDT date.

**Team shorts:** `adm` · `cui` · `sys` · `ralph` · `verda` · `rev`

(Mapping: `adm`=ADM/Admin Panel, `cui`=CUI/ComfyUI, `sys`=SYS/Systems & Ops, `rev`=REV/Review, `ralph`=Ralph, `verda`=Verda.)

**Examples:**
- `testing-adm-2026-04-17` (ADM team off all-teams-testing)
- `testing-cui-2026-04-17` (CUI team off all-teams-testing)
- `main-adm-2026-04-17` (ADM off main — e.g. for prod patches)

**Legacy pattern** (pre-2026-04-17): `testing-mello-admin-panel-team-YYYY-MM-DD` etc. Still supported — convert to new short form during rotation.

## Steps

1. Get AEDT date: `TZ=Australia/Sydney date '+%Y-%m-%d'`
2. Get branch: `git branch --show-current` — extract trailing `YYYY-MM-DD`
3. If dates match AND branch already uses new short form → "Branch is current." Stop.
4. If no `YYYY-MM-DD` suffix → warn, stop.
5. Compute new name:
   - If current branch uses legacy long form (e.g. `testing-mello-admin-panel-team-<date>`), convert to new short form (e.g. `testing-adm-<today>`)
   - Else keep the same `[deploy]-[short]` prefix, just update the date
6. Rename + push:
   ```bash
   git branch -m <old> <new>
   git push origin -u <new>
   ```
7. Confirm to user.

Old remote branch left intact — GitHub cleans up after merge.
