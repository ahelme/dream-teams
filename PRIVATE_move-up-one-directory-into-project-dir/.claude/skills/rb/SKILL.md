---
name: rb
description: Rotate branch — rename current team branch date suffix to match today's date. Use at session start when the branch date is stale, or when user says "rotate branch", "update branch", "rename branch to today", or "/rb".
user-invocable: true
version: 1.1.0
---

# Rotate Branch

Team branches follow [ TEAM BRANCH PATTERN ]: `[base-branch]-[team-short]-YYYY-MM-DD` (e.g. `testing-<team>-2026-01-05` off [ INTEGRATION BRANCH ], `main-<team>-2026-01-05` off [ MAIN BRANCH ] for prod patches). Date suffix must match today's date in [ TIMEZONE ].

**Team shorts:** [ ADAPT: list your team short codes and their meanings ]

## Steps

1. Get today's date: `TZ=[ TIMEZONE ] date '+%Y-%m-%d'`
2. Get branch: `git branch --show-current` — extract trailing `YYYY-MM-DD`
3. If dates match → "Branch is current." Stop.
4. If no `YYYY-MM-DD` suffix → warn, stop.
5. Compute new name: keep the same `[base]-[short]` prefix, just update the date
6. Rename + push:
   ```bash
   git branch -m <old> <new>
   git push origin -u <new>
   ```
7. Confirm to user.

Old remote branch left intact — GitHub cleans up after merge.
