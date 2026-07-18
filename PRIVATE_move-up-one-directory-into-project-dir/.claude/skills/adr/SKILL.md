---
name: adr
description: Capture and consult YETI's Architecture Decision Records — the short "why we chose this" notes for core decisions (engine, protocol, ops, paper, team). Use when a decision is hard to reverse, affects another lane, or a future agent would ask "why is it done this way?"; to consult existing ADRs before touching a governed area; or to supersede a decision that's changed. Built for a fast-moving team: records are cheap, lightweight, and mortal — superseding is the normal lifecycle, not a failure.
user-invocable: true
---

# ADR skill — YETI

## What an ADR is here

A short, dated note that captures **one core decision + why**, so no future
session re-derives it or silently contradicts it. In YETI an ADR is a
lightweight **executable spec**: a human (or the lead of the lane) approves the
decision; any agent should be able to act on it without asking follow-ups.

**We move fast, so records are cheap and mortal.** An ADR is not a monument.
Most will be superseded as the physics teaches us more — that's the system
working, not a mistake. The cost of writing one is ~5 minutes; the cost of a
lost decision is a session that re-litigates it or breaks it. Bias toward
capturing, and toward superseding cleanly when it changes.

## When to write one (and when not)

**Write an ADR when a decision:**
- **crosses a lane** — engine ↔ protocol ↔ ops ↔ paper ↔ team (whose lane is
  what: `docs/COORDINATION.md`),
- **is hard to reverse** once code/measurements are built on it (shard format,
  wire encoding, KV layout, deploy topology),
- **had real alternatives** with non-obvious tradeoffs, or
- **a future agent would ask "why is it this way?"** — if you're about to write
  a long "why" comment, that reasoning belongs in an ADR.

**Do NOT write one for:** routine work inside an established pattern, a bug fix,
a measurement result (those go to `docs/lab-notebook.md`), or something already
captured in an existing ADR (supersede it instead).

Rule of thumb, borrowed from our era rule: **if you're unsure whether it's an
ADR, it probably isn't — real decisions announce themselves** by being expensive
to undo.

### Proactive trigger (for agents mid-work)
If you're about to introduce a new dependency, invent a new pattern others will
follow, choose between real alternatives with non-obvious tradeoffs, or do
something that contradicts an accepted ADR — **stop and propose an ADR** in
#yeti (name the decision, why it matters, whose lane). If the lane lead says no,
drop a one-line code comment and move on. Don't grab a cross-lane decision
without a claim (COORDINATION house rule).

## Two lanes: pick the lighter one that fits

- **Fast lane (default).** For most decisions. Skip the interview. Fill the
  template (`templates/adr-fast.md`) directly from what you already know,
  status `proposed` (or `accepted` if it's your lane and already agreed), post
  the link in #yeti. Five minutes. This is the common case — don't
  ceremonialize it.
- **Full lane.** Only for genuinely expensive, hard-to-reverse, cross-lane
  decisions (a new shard format, a wire-protocol change, a deploy re-topology).
  Do a short Socratic pass first: ask the human **one question at a time** —
  what are you deciding? why now? what constrains it (the physics)? what does
  success look like (a number, not "it works")? what did you reject and why?
  who owns it? Then draft. Confirm the intent summary before writing.

Both lanes produce the **same template**. The difference is only how much you
interview first.

## Consulting ADRs (do this before touching a governed area)

Before you build in engine / protocol / ops / paper / team:
1. **Read `docs/decisions/README.md` in full** — it defines the naming,
   categories, and status this store uses.
2. Scan titles + statuses; focus on **`accepted`** ones (active law).
3. Read the relevant ones fully — Context, Decision, Consequences, and the
   Implementation notes / Revisit-when line.
4. **Respect them.** To go against an accepted ADR, write a new one that
   supersedes it — don't just diverge. If code and an ADR disagree, flag it in
   #yeti.
5. Reference the ADR where you implement it (a one-line code comment at the
   entry point + in the PR/commit body).

## Writing one (the flow)

**Phase 0 — scan.** Read `docs/decisions/README.md`, list existing ADRs, note
any this interacts with or supersedes. Check the affected code (`mvp/static/…`,
`docs/…`) so the Implementation notes name real files.

**Phase 1 — capture** (Full lane only; Fast lane skips to draft). One question
at a time; stop when you can fill every section without guessing. Confirm the
intent summary before drafting.

**Phase 2 — draft.** Copy `templates/adr-fast.md` into `docs/decisions/` as
`YYYY-MM-DD-<category>-<slug>.md`. Fill every section (delete optional ones you
don't need — don't leave placeholders). Set `category:`, `status:`, `date:`,
`deciders:`. Write **Verification** as checkboxes an agent could actually run.
Write the **Revisit-when** line — the condition that should make a future
session reopen this (we're fast-moving; name the trip-wire).

**Phase 3 — land it.** Add the ADR to the index in `docs/decisions/README.md`
(under its category). Then wire it into our continuity system:
- **GitHub issue** — link the ADR from the relevant `ahelme/yeti` issue (or file
  one); a decision the issue doesn't reflect is a receipt nobody finds.
- **Session log** — mention it in your `/update-session-log` entry.
- **COORDINATION registry** — for a cross-lane or team-shaping ADR, add a
  registry line (it's the lab's institutional memory).
- Sign per CLAUDE.md (your team identity + model).

## Superseding (the common case, not the sad one)

When a decision changes:
1. Write the **new** ADR (fast lane is fine), status `accepted`, with a
   `Supersedes:` line pointing at the old file.
2. Flip the **old** one to `status: superseded by <new-file>` — keep its body
   intact (don't rewrite history; the old reasoning is the record of what we
   believed and why we moved).
3. Update both index entries. Grep the code for comments referencing the old
   ADR and update the pointers.

Deprecate (no replacement, just "don't do this anymore") the same way with
`status: deprecated` + a one-line why.

## No secrets in ADRs
`docs/decisions/` ships in the public repo (see CLAUDE.md § Before making this
public). Same rule as COORDINATION.md: **no tokens, IDs, IPs, or credentials** —
those live only in `../PRIVATE/` and `*.local.yaml`. Reference an ops decision
by shape ("TURN relay in Helsinki, credentials in gitignored ice.json"), never
by secret.

## Resources
- `templates/adr-fast.md` — the one lean template (both lanes use it).
- `docs/decisions/README.md` — the store's index + conventions (source of truth
  for naming/categories/status).
- Optional scripts (portable from comfyume's adr skill, auto-detect conventions):
  `new-adr.js`, `set-adr-status.js`, `bootstrap-adr.js`. Not required — copying
  the template by hand is fine and often faster.
