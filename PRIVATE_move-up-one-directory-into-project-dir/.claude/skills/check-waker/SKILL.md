---
name: cw
description: Check Waker — quick health check of the yeti-waker v2 wake system (daemon, transport, listeners, queues), with interpretation guide
user-invocable: true
version: 1.0.0
---

# Check Waker 🔔 — the 30-second health pass

Read-only. Run all four checks, then read the interpretation table. For
architecture, ops procedures, and the full gotcha list: **`/manage-waker`**.

## 1. Waker daemon up, streams attached?

```bash
systemctl --user status yeti-waker --no-pager -n 8
```

Healthy: `active (running)`, **three** `pantalk stream` children in the CGroup
(one per agent bot), recent `[queue]`/`[deliver]` journal lines, no `[ALERT]`.

## 2. Transport (pantalkd) alive?

```bash
systemctl --user is-active pantalkd && ls "$XDG_RUNTIME_DIR/pantalk.sock" && tail -5 ~/.local/state/pantalk/pantalkd.log
```

Healthy: unit `active` + socket present, log shows `connector online` /
`socket mode connected` per bot, no `server error`. (pantalkd is a user
systemd unit now, `Restart=always` — the bare-setsid era is over.)

## 3. Per-agent listeners and queues

```bash
for a in aurora rime meridian; do
  d="$XDG_RUNTIME_DIR/yeti-wake/$a"
  pid=$(cat "$d/listener.pid" 2>/dev/null)
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then st="ears ARMED (pid $pid)"; else st="no listener"; fi
  if [ -f "$d/pending.jsonl" ]; then q=$(wc -l < "$d/pending.jsonl"); else q=0; fi
  echo "$a: $st · pending: $q"
done
```

## 4. Your own ears (this session)

Your listener should be a **tracked background task of this session** — if you
haven't armed since your last wake, arm now:
`.claude/agent_tools/ears-wait.sh agent_identity.<you>.local.yaml`
(background task, `run_in_background: true`).

## Interpreting what you found

| Finding | Meaning | Action |
|---|---|---|
| No listener, pending > 0 | Seat has no session **or** a deaf one — queue is safe, delivers in one wake on next arm | If that seat's session should be live: arm ears *from inside it*. Never arm detached |
| No listener, pending = 0 | Idle seat, nothing waiting | Nothing — this is the designed idle |
| Listener armed, pending > 0 for >10 s | Delivery not draining (stale-but-alive pidfile? FIFO not open?) | Check waker journal for `[deliver]` errors → `/manage-waker` |
| Arming exits 4 | Another live listener holds these ears | `ps -o ppid= -p <pid>`: parented to init = detached thief, kill + clear pidfile; parented to your session = you double-armed, do nothing |
| Waker inactive | Realtime wakes stop AND nothing new queues (the waker is the queuer) — mentions during the gap won't auto-deliver; they stay in Slack/pantalk history, so catch up via `chat-hear.sh` after | `systemctl --user restart yeti-waker` promptly (safe; existing queue is on disk) |
| pantalkd dead | All bots dark (send + receive) | `systemctl --user restart pantalkd` (Rime's lane) — see `/manage-waker` §Operations + gotcha 5 (env-ref token trap) |
| Waker + listener healthy, but a mention never arrived | One bot's Slack socket stalled inbound — upstream of never-drop (#52) | Check the pantalk log per bot; if the mentioned bot's stream is silent while siblings flow, bounce pantalkd. Home-channel mentions are covered by sibling-stream routing (#61) |
| `[ALERT] possible mention loop` in journal | ≥10 wakes queued for one agent in 60 s | Investigate senders (audit pending + journal); never add a cooldown |
| Waker logs `[queue]` but agent never woke | Mention landed while deaf — it's queued, not lost | Arm ears; backlog arrives in one wake |

**Remember:** a dead pidfile ≠ a dead session (ears and seat fail
independently), and after a pantalkd bounce the waker reconnects by itself —
don't restart it. Details and war stories: `/manage-waker`.
