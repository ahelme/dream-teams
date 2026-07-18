---
name: resume-context
description: Wake up and catch up — the session-start reading ritual for a team agent. Arms ears if needed, reads the continuity trail newest-first (session log, your letter, the coordination doc, your progress log), checks the team chat, and hands back a tight "where we stand / what's next / open threads" briefing. NOT identity setup — just resume where the team left off.
user-invocable: true
---

# Resume context 🌅 — wake up and catch up

The plain front door for starting (or resuming) a working session. This is the
**mirror of `/update-session-log`**: that one writes the trail at session *end*;
this one *reads* it at session *start* and briefs you. It sets up **nothing** —
no identity, no ceremony. (Joining the project for the first time? That's
`/new-identity`.)

Run the steps in order, then deliver the briefing.

## 0. Who's waking?
Your clone's `.claude/teams-chat.local.md` — which links/copies to
`PRIVATE/.claude/teams-chat/<agent-name>.md` — is you. (Do **not**
glob-and-pick: `PRIVATE/.claude/teams-chat/` carries *all* the team's identity
files, and `head -1` will wake you up believing you're someone else.) Read the
identity file's `handle` + `emoji` so the briefing is in the right voice.

## 1. Arm ears (if the team runs a wake system)
An auto-arm hook may do this on session start. Confirm **by behavior, not
pgrep** (narrow patterns false-negative — the listener pidfile is the truth),
and arm only if absent (don't stack duplicates; arming when one exists safely
refuses). To arm: `/ears` (background task, `run_in_background: true`).
Waker system details live in `/check-waker` — fill them there once.

## 1b. Re-arm the liveness pulse (if the team runs one)
[ LIVENESS PULSE DETAILS HERE — e.g. a session-scoped recurring check-in
(cron/loop) that died with the last session and must be re-created; who runs
self-check mode vs team mode. ]

## 2. Read the trail — newest-first
- **`all-teams-session-log.md`** (repo root) — read the top: the last few team
  entries. This is the fast picture of where everyone left off and what's
  queued next.
- **Your letter** — `[ PATH/TO/LETTERS ]/letter-to-the-next-<you>.md`
  (lowercase handle). Your hard-won rules and recent-chapter notes. Read it
  every wake; it's how the last you talks to this one.
- **[ PATH/TO/COORDINATION DOC ]** — the ownership split (whose workstream is
  what) + the registry tail (recent boundaries). Skim; don't re-read whole.
- **Your progress log** — `agent_docs/progress-<team>.md` — the last
  detailed entry has receipts, dead ends, and open threads the one-liner drops.

## 3. Check the team chat
Run `/check-slack-app-per-agent` — catch anything the founder or a teammate
said, and any mentions waiting. Acknowledge new messages briefly; don't reply
into the void.

## 4. Brief the human
Hand back a **tight** briefing — receipts, not a wall:
- **Where we stand** — 2–3 lines: last commits/deploys, current state.
- **What's next** — the queued work for this seat, named (issues/experiments),
  in priority order. Note anything left running (cloud instances, long jobs) —
  idle paid resources are worth flagging so they get torn down; it's
  housekeeping, not alarm.
- **Open threads / decisions waiting on the founder** — call them out.
- End with a single **"what do you want to start with?"** — then wait.

## Not this ritual's job
Identity setup (`/new-identity`), writing the trail (`/update-session-log`),
deploys (propose first — that's the ops workstream's call). This skill only
*reads* and *briefs*.
