---
name: ears
description: Arm realtime chat "ears" for this agent session — the wake listener the team's waker daemon delivers into. Invoke at session start (or after a wake) to arm/re-arm; a mention of your bot then wakes your running session within seconds.
user-invocable: true
---

# Ears 👂 — realtime chat wake for a running session

Session side of the **deliver-never-spawn** wake system: a central waker
daemon watches the team chat and queues every mention per agent; a listener
script registers a FIFO (one per agent, pidfile-enforced) that the waker
delivers into. When it exits, the harness re-invokes your session — that's the
wake. No session listening → mentions queue in `pending.jsonl` and flush in
ONE wake on your next arm; nothing is ever dropped, and nothing ever spawns a
session.

Health check: `/check-waker`.
[ WAKER SYSTEM DETAILS & STEPS REQUIRED HERE — listener script path, identity
file convention, runtime dirs. ]

## Arming (at session start, and again after EVERY wake)

Run as a **tracked background task** (`run_in_background: true`) — **never
fire-and-forget `&`**, the harness reaps it and you go silently deaf:

```bash
[ PATH/TO/EARS LISTENER SCRIPT ] [ YOUR IDENTITY FILE ]
```

Use YOUR identity file (e.g. from an `AGENT_IDENTITY_FILE` setting). No
default fallback by design — an alphabetical glob would arm you as whichever
teammate sorts first.

## When the task exits (you get re-invoked)

- **Exit 0, event printed:** someone spoke. If it calls for you, respond in
  chat in your own voice; if not, stay silent. **Either way, re-arm before
  deep work.**
- **Quiet-window exit:** re-arm silently — do NOT sweep the chat or invent
  work; quiet wakes must cost ~nothing. ⚠️ An *instant* quiet exit can mask a
  PATH bug — read the task output file the first time you arm on a fresh seat.
- **Listener-exists exit:** a live listener already holds your ears (pidfile
  guard) — if it is this session's earlier arm, do nothing; if detached, see
  `/check-waker`.
- **Bad-identity exit:** bad/missing identity argument — fix before re-arming.

## What wakes you

- Any mention of your bot — founder **or teammate**, any channel the bot is in
  (mentions inside `` `code spans` `` are stripped by design);
- `@channel` / `@here` pings in [ SLACK CHANNEL ];
- never your own messages, never a self-mention.

## What this is NOT

- Not for cloud/sandbox seats that socket push can't reach — they need their
  own heartbeat mechanism.
- Not a cold-wake: mentions with no session queue safely until a human starts
  one. (Do NOT add a cron watchdog that arms detached — a detached listener
  steals deliveries into a log nobody reads.)
- No secrets: the listener reads your gitignored identity file; nothing here
  embeds or prints tokens.
