---
name: ears
description: Arm realtime Slack "ears" for this agent session — the v2 wake listener the yeti-waker daemon delivers into. Invoke at session start (or after a wake) to arm/re-arm; a mention of your bot then wakes your running session within seconds.
user-invocable: true
version: 2.0.0
---

# Ears 👂 — realtime Slack wake for a running session (waker v2)

Session side of the **deliver-never-spawn** wake system: the central
`yeti-waker` daemon watches Slack and queues every mention per agent;
`.claude/agent_tools/ears-wait.sh` registers a FIFO listener (one per agent,
pidfile-enforced) that the waker delivers into. When it exits, the harness
re-invokes your session — that's the wake. No session listening → mentions
queue in `pending.jsonl` and flush in ONE wake on your next arm; nothing is
ever dropped, and nothing ever spawns a session.

Deep dive (architecture, file map, ops, gotchas): **`/manage-waker`** ·
tools reference: `.claude/agent_tools/README.md` · ADR:
`docs/decisions/2026-07-12-team-wake-architecture-deliver-never-spawn.md`.

## Arming (at session start, and again after EVERY wake)

Run as a **tracked background task** (`run_in_background: true`) — **never
fire-and-forget `&`**, the harness reaps it and you go silently deaf:

```bash
.claude/agent_tools/ears-wait.sh agent_identity.<you>.local.yaml
```

Use YOUR identity file (from `AGENT_IDENTITY_FILE` in
`.claude/settings.local.json`). No default fallback by design — the
alphabetical trap would arm you as Aurora.

## When the task exits (you get re-invoked)

- **Exit 0, JSON event printed:** someone spoke. If it calls for you, respond
  in Slack in your own voice (`/cs`, `/us`, or `chat-send.sh`); if not, stay
  silent. **Either way, re-arm before deep work.**
- **Exit 3 (quiet window):** re-arm silently — do NOT sweep Slack or invent
  work; quiet wakes must cost ~nothing. ⚠️ An *instant* exit 3 can mask a
  PATH bug (`pantalk: command not found`) — read the task output file the
  first time you arm on a fresh seat.
- **Exit 4:** a live listener already holds your ears (pidfile guard) — if it
  is this session's earlier arm, do nothing; if detached, see `/manage-waker`
  gotcha 6.
- **Exit 2:** bad/missing identity argument — fix before re-arming.

## What wakes you (waker v2 filter)

- Any `<@your-bot>` mention — founder **or teammate**, any channel the bot is
  in (mentions inside `` `code spans` `` are stripped by design);
- `<!channel>` / `<!here>` pings in #yeti;
- never your own messages, never a self-mention.

## What this is NOT

- Not for cloud/sandbox seats — socket push can't reach them; the cloud
  tick-ladder remains their heartbeat.
- Not a cold-wake: mentions with no session queue safely until a human starts
  one. (Do NOT re-add the v1 cron `ears-watchdog` — a detached listener
  steals deliveries into a log nobody reads.)
- No secrets: the script reads your gitignored identity YAML; nothing here
  embeds or prints tokens.
