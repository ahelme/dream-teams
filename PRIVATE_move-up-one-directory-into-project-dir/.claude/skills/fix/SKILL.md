---
name: fix
description: Fix a diagnosed issue using best practices. Use after /inv has identified the root cause, or for known issues. Ensures fixes are planned, tested, verified, and documented.
user-invocable: true
version: 1.1.0
---

# /fix — Fix

**You've done the hard work of understanding. Now apply the solution carefully.**

Use after `/inv` has diagnosed the issue, or when the problem is already known. This skill prevents the other failure mode — knowing what's wrong but introducing new problems while fixing it.

## Why Fixes Go Wrong

- **Fixing the symptom** — patching what you see instead of what `/inv` found. Always fix the root cause.
- **Blast radius blindness** — not considering what else your change touches.
- **No verification** — "it works now" without checking if anything else broke.
- **No documentation** — fixing it today, debugging it again in three weeks.
- **Scope creep** — "while I'm here, I'll also..." — don't. Fix the issue. Propose extras separately.

## The Fix Process

### 1. Restate the Root Cause

One sentence. If you can't say it in one sentence, you might not understand it yet — consider another `/inv` cycle.

### 2. Plan the Fix

- What files change?
- What's the minimal change that addresses the root cause?
- Are there related files that need the same fix? (Propose, don't impose.)

> **Orient with graphify first.** If `graphify-out/graph.json` exists, run `graphify query "<question>"` (or `explain`/`path`) before grepping/reading raw source to find related files. It's more thorough than grep — grep only finds the string you searched for and misses the call/config edges around it. Rebuild stale with `graphify update .`. *(When dispatching subagents to explore, include this instruction in their prompt.)*

### 3. Blast Radius Check

- What else uses this code/config/service?
- Could this change break something downstream?
- Does this affect other environments (testing vs prod)?
- Does this need a migration, restart, or rebuild?

### 4. Test Plan

Before applying:
- How will you verify the fix works?
- How will you verify nothing else broke?
- What does "fixed" look like — specific observable outcome?

### 5. Apply

Make the change. Keep it minimal.

### 6. Verify

- Confirm the fix: check the specific observable outcome from step 4
- Run `/health-check` if appropriate
- Check Sentry for new errors
- Check the area around the fix — any side effects?

### 7. Document

- Update the GH issue with: root cause, fix applied, verification result
- Update the `/inv` analysis doc status → `resolved`
- If the fix revealed a gotcha → add to `gotchas.md`
- If the fix is non-obvious → comment the code explaining WHY

## Linking to /inv

If an analysis doc exists in `docs/analysis/`:
- Reference it in your commit message
- Update its status to `resolved`
- Add the fix details to its Findings section

If no analysis doc exists (known issue, simple fix):
- Still follow steps 1-7 — they're quick for simple fixes
- Skip the doc unless the fix was surprising
