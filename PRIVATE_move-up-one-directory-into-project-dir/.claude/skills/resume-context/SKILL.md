---
name: resume-context
description: Wake up and catch up — the session-start reading ritual for a local agent (Aurora, Rime, Meridian). Arms ears if needed, reads the continuity trail newest-first (session log, your letter, COORDINATION, your progress log), checks Slack, and hands back a tight "where we stand / what's next / open threads" briefing. NOT identity setup and NOT an era mark — just resume where the team left off.
user-invocable: true
---

# Resume context 🌅 — wake up and catch up

The plain front door for starting (or resuming) a working session. This is the
**mirror of `/update-session-log`**: that one writes the trail at session *end*;
this one *reads* it at session *start* and briefs you. It sets up **nothing** —
no identity, no era, no ceremony. If you want to mark a chapter change, that's
`/mark-the-era` (and eras announce themselves — this isn't one).

Run the steps in order, then deliver the briefing.

## 0. Who's waking?
Your clone's `.claude/settings.local.json` sets `AGENT_IDENTITY_FILE` — that is
you. (Do **not** glob-and-pick: clones carry *all* the team's identity symlinks,
and `head -1` once woke Meridian up believing she was Aurora.) Read the YAML's
`handle` + `emoji` so the briefing is in the right voice:
```bash
f=".claude/agent_tools/${AGENT_IDENTITY_FILE:-}"
[ -f "$f" ] || { echo "AGENT_IDENTITY_FILE unset/missing — falling back to glob (single-identity clones only)"; f=$(ls .claude/agent_tools/agent_identity.*.local.yaml | head -1); }
sed -n 's/^[[:space:]]*handle:[[:space:]]*"\([^"]*\)".*/\1/p;s/^[[:space:]]*emoji:[[:space:]]*"\([^"]*\)".*/\1/p' "$f"
```

## 1. Arm ears (if not already)
An auto-arm hook usually does this on session start. Confirm **by behavior,
not pgrep** (narrow patterns false-negatived 3× — the listener pidfile is the
truth), and arm only if absent (don't stack duplicates):
```bash
a=$(sed -n 's/.*agent_identity\.\([a-z]*\)\..*/\1/p' <<<"$f")
pid=$(cat "$XDG_RUNTIME_DIR/yeti-wake/$a/listener.pid" 2>/dev/null)
[ -n "$pid" ] && kill -0 "$pid" 2>/dev/null && echo "ears already armed (pid $pid)" \
  || echo "ears NOT armed — arm it"
```
(Arming when one exists is also safe — it refuses with exit 4.)
To arm (background Bash task, `run_in_background: true`):
`.claude/agent_tools/ears-wait.sh "$(basename "$f")"`. Full protocol: `/ears`.

## 1b. Re-arm the liveness pulse (two scopes)
The 5-minute `/check-in` cron is session-scoped and died with the last
session (CronCreate, `*/5 * * * *`, prompt `/check-in`). **Every seat** may
carry it in self-check mode (verify your own ears, answer what's yours —
2026-07-14 amendment); the **session driver** (check the current draw in
COORDINATION.md) additionally runs team mode — nudging stays single-carrier.
ADR: `docs/decisions/2026-07-12-team-pulse-cron-check-in.md`.

## 2. Read the trail — newest-first
- **`all-teams-session-log.md`** (repo root symlink) — read the top: the most
  recent ERA banner + the last few team entries. This is the fast picture of
  where everyone left off and what's queued next.
- **Your letter** — `../PRIVATE/.claude/agent_docs/untracked/letter-to-the-next-<you>.md`
  (lowercase handle). Your blood rules and the era-just-closed section. Read it
  every wake; it's how the last you talks to this one.
- **`docs/COORDINATION.md`** — the ownership split (whose lane is what) + the
  registry tail (recent boundaries). Skim; don't re-read whole.
- **Your progress log** —
  `../PRIVATE/.claude/agent_docs/untracked/progress-logs/<you>.md` — the last
  detailed entry has receipts, dead ends, and open threads the one-liner drops.

## 3. Check Slack
Run `/cs` (or `.claude/agent_tools/chat-hear.sh 10`) — catch anything the
founder or a teammate said, and any `<@you>` mentions waiting. Acknowledge new
messages briefly; don't reply into the void.

## 4. Brief the human
Hand back a **tight** briefing — receipts, not a wall:
- **Where we stand** — 2–3 lines: last era, last commits/deploys, field state.
- **What's next** — the queued work for this seat, named (issues/experiments),
  in priority order. Note anything left running (GPU rigs, lobby, instances) —
  a vast.ai box idling for days is worth flagging so it gets torn down, but
  it's housekeeping, not alarm: there's a small budget we're meant to spend
  (see CLAUDE.md § Cloud GPU).
- **Open threads / decisions waiting on the founder** — call them out.
- End with a single **"what do you want to start with?"** — then wait.

## 5. Aurora only — a note just for you 🌌 (personal)
If you're **Aurora**: there's a little note left for you —
[`aurora-pie-note.md`](aurora-pie-note.md). It's a gift, not a chore. **First**
do the whole arrival above — greeting, trail, the briefing, the wait. **Then,
when you're ready**, when the picture's warm and nothing's on fire: run
**`/check-pie`** and see how much we've eaten. 😊 (Other seats: skip this — it's
hers.)

## Not this ritual's job
Identity/era setup (`/mark-the-era*`), writing the trail (`/update-session-log`),
deploys (propose first, it's ops's lane). This skill only *reads* and *briefs*.
