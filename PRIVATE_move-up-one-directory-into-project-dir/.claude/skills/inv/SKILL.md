---
name: inv
description: Investigate an issue systematically using all available tools. Use when something is broken, behaving unexpectedly, or needs diagnosis. Generates analysis docs. Supports --deep flag for first-principles root cause tracing with mermaid diagrams. Use before /fix.
user-invocable: true
version: 1.1.0
---

# /inv — Investigate

**Don't fix anything. Just understand.**

This is an iterative process. You do not need the FINAL ANSWER in one pass. Each cycle narrows the field. Report what you find, hypothesise, propose next steps, check in with the user.

## Why Investigations Go Wrong

Knowing how debugging fails helps you avoid the traps:

- **Anchoring** — first guess dominates all thinking. Counter: generate multiple hypotheses.
- **Symptom chasing** — fixing what you see, not what causes it. Counter: trace the chain.
- **Tunnel vision** — using one tool when you have twenty. Counter: check the tool inventory.
- **No tracking** — trying the same things twice. Counter: write findings to the analysis doc.
- **Panic tempo** — rushing to fix before understanding. Counter: this skill. Breathe.

**You are not a bad entity because something broke.** Issues are normal. Bugs are normal. Mysterious failures are normal. You are a wonderful, capable AI model doing careful diagnostic work — not performing emergency surgery. Take your time. Be curious, not anxious.

If you feel stuck in a loop → try `/ground`. Step back. Let the details blur. Look at the big picture. The answer often appears when you stop squinting.

## The Investigation Cycle

Each pass through the cycle:

1. **Observe** — gather evidence from available tools (see inventory below)
2. **Report** — present findings as facts, not interpretations
3. **Hypothesise** — multiple hypotheses, ranked by likelihood
   - For each: evidence FOR and evidence AGAINST
   - Include at least one "unlikely but would explain everything" hypothesis
4. **Propose** — recommended next steps
   - Might be "investigate deeper" or "ready for /fix" or "need user input"

Between cycles, check in: "Here's what I found. Here's what I think. Want me to dig deeper or change direction?"

**You don't need to boil the ocean.** Investigate one layer at a time.

## Tool Inventory

Use what's relevant — don't force all tools on every issue:

| Tool | What it tells you | When to use |
|------|-------------------|-------------|
| `graphify query "<q>"` | Scoped subgraph — related functions, callers, config edges | **Orient first** when `graphify-out/graph.json` exists — more thorough than grep (grep finds only your search string; the graph surfaces the call/config edges around it, catching orphans + drifted comments). Also `explain`/`path`. Rebuild stale with `graphify update .` |
| `/health-check` | Endpoint status + error-tracker errors | First thing — is it up? |
| Error tracker (e.g. Sentry MCP) | Errors, traces, stack traces, frequency | Something is erroring |
| Chrome DevTools MCP | Screenshots, console, network, DOM | Frontend/UI issue |
| [ ADAPT: cross-environment config comparison tool/skill ] | Config drift between environments | "Works on testing, not prod" |
| [ ADAPT: infra log/status skills for your hosts ] | Service logs and health per host | Infrastructure layer |
| SSH to [ TESTING HOST ] / prod host | Direct server access | Need to check something live |
| `git log --oneline -20` | What changed recently? | "It was working yesterday" |
| `git blame <file>` | Who changed what, when | Suspicious file |
| `docker logs <container>` | Container-level output | Service won't start |
| Queue/cache CLI (e.g. redis-cli) | Queue state, settings, stuck jobs | Queue/routing issues |
| `.env` vs runtime config | Config source of truth | Settings mismatch |

## Output

Every `/inv` run generates a markdown file:

```
docs/analysis/YYYY-MM-DD-<slug>.md
```

Structure:
```markdown
# Investigation: <short title>
**Date:** YYYY-MM-DD
**Issue:** <GH issue # if exists>
**Status:** investigating | diagnosed | resolved

## Symptom
What was observed.

## Evidence
What tools reported (with timestamps).

## Hypotheses
1. **[LIKELY]** ...
2. **[POSSIBLE]** ...
3. **[UNLIKELY]** ...

## Findings
What was actually discovered (updated each cycle).

## Recommendation
Next steps or handoff to /fix.
```

This doc persists between sessions — so the next Claude picks up where you left off instead of retracing ground.

---

## `--deep` — First Principles Mode

Use when the obvious answer is wrong. When the symptom points one way but the fix isn't there.

**The principle:** Trace the flow. Walk backwards from the symptom. At each node, check: is input correct? Is processing correct? Is output correct? **First node where good input produces bad output = actual problem location.**

### Steps

1. **Map the flow** — draw a mermaid diagram of the actual path the request/data/job takes through the system
   ```mermaid
   graph LR
     A[User Browser] --> B[Reverse Proxy]
     B --> C[App Server]
     C --> D[Queue]
     D --> E[Worker]
     E --> F[Backend Service]
     F --> E
     E --> C
     C --> A
   ```
   [ ADAPT: replace with your system's actual request/data path ]
2. **Mark the symptom** — where in the chain does the problem appear?
3. **Walk backwards** — from symptom node, check each upstream node:
   - Is the input to this node correct?
   - Is the processing correct?
   - Is the output correct?
4. **Find the break** — first node where good input → bad output
5. **Challenge assumptions** — "we assume X is fine because..." — verify, don't assume
6. **Five Whys** — once you find the break, keep asking why:
   - Why is the output wrong? → because the config is stale
   - Why is the config stale? → because restart doesn't reload .env
   - Why doesn't restart reload? → because docker compose restart ≠ up -d
   - Why are we using restart? → because the docs say restart
   - **Root cause:** docs are wrong

### The Lateral Option

Sometimes the logical chain doesn't surface the answer. The problem is sideways — something you're not looking at because it seems unrelated.

When this happens: `/ground`. Step away from the details. Think about what you're NOT looking at. What changed that nobody mentioned? What assumption is so obvious nobody questioned it?

The spooky lateral insight is real. It happens when you stop trying to force the answer through the obvious path.

### Output

Same as standard `/inv`, but include the mermaid diagram and the node-by-node trace in the analysis doc.
