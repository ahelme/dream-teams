---
name: check-waker
description: Check the waker — quick read-only health check of the team's wake system (daemon, chat transport, per-agent listeners, queues), with an interpretation guide
user-invocable: true
---

# Check waker 🔔 — the 30-second health pass

Read-only. Run all four checks, then read the interpretation table.
Assumes a **deliver-never-spawn** wake system: a central waker daemon watches
the team chat and queues every mention per agent; a per-session listener
(armed via `/ears`) receives deliveries; mentions with no listener queue on
disk and flush on the next arm.

[ WAKER SYSTEM DETAILS & STEPS REQUIRED HERE — unit names, socket paths,
queue dir, log locations. The commands below are the shape; substitute yours. ]

## 1. Waker daemon up, streams attached?

```bash
systemctl --user status [ WAKER UNIT ] --no-pager -n 8
```

Healthy: `active (running)`, one chat-stream child per agent bot in the CGroup,
recent queue/deliver log lines, no alerts.

## 2. Chat transport alive?

```bash
systemctl --user is-active [ TRANSPORT UNIT ] && tail -5 [ PATH/TO/TRANSPORT LOG ]
```

Healthy: unit `active`, log shows each bot connected, no server errors.

## 3. Per-agent listeners and queues

```bash
for a in [ AGENT NAMES ]; do
  d="[ PATH/TO/WAKE RUNTIME DIR ]/$a"
  pid=$(cat "$d/listener.pid" 2>/dev/null)
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then st="ears ARMED (pid $pid)"; else st="no listener"; fi
  if [ -f "$d/pending.jsonl" ]; then q=$(wc -l < "$d/pending.jsonl"); else q=0; fi
  echo "$a: $st · pending: $q"
done
```

## 4. Your own ears (this session)

Your listener should be a **tracked background task of this session** — if you
haven't armed since your last wake, arm now via `/ears`
(background task, `run_in_background: true`).

## Interpreting what you found

| Finding | Meaning | Action |
|---|---|---|
| No listener, pending > 0 | Seat has no session **or** a deaf one — queue is safe, delivers in one wake on next arm | If that seat's session should be live: arm ears *from inside it*. Never arm detached |
| No listener, pending = 0 | Idle seat, nothing waiting | Nothing — this is the designed idle |
| Listener armed, pending > 0 for >10 s | Delivery not draining (stale-but-alive pidfile? FIFO not open?) | Check waker log for delivery errors |
| Arming refuses (listener-exists exit code) | Another live listener holds these ears | `ps -o ppid= -p <pid>`: parented to init = detached thief, kill + clear pidfile; parented to your session = you double-armed, do nothing |
| Waker inactive | Realtime wakes stop AND nothing new queues (the waker is the queuer) — mentions during the gap won't auto-deliver; they stay in chat history, so catch up by reading the chat after | Restart the waker unit promptly (safe; existing queue is on disk) |
| Transport dead | All bots dark (send + receive) | Restart the transport unit |
| Waker + listener healthy, but a mention never arrived | One bot's chat socket stalled inbound | Check the transport log per bot; if the mentioned bot's stream is silent while siblings flow, bounce the transport |
| Mention-loop alert in the waker log | Many wakes queued for one agent in a short window | Investigate senders (audit pending + log); never add a cooldown |
| Waker logged a queue event but the agent never woke | Mention landed while deaf — it's queued, not lost | Arm ears; backlog arrives in one wake |

**Remember:** a dead pidfile ≠ a dead session (ears and seat fail
independently), and after a transport bounce the waker reconnects by itself —
don't restart it.
