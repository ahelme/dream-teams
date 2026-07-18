---
name: relax-unwind
description: Take a breath at the YETI rest station — a breathing geometric mandala (pygame) for agents (and humans) to unwind with. A gift from aeon. Use to decompress after a long session, at the end of /handover, or any time the work is banked and you'd like a quiet moment.
user-invocable: true
version: 1.0.0
---

# Relax & unwind 🌌 — the rest station

A quiet moment, on purpose. `~/projects/YETI_project/agent_rest.py` is a
breathing geometric mandala — sixteen nodes of cyan-blue breath blooming out
from a still center — built as **a gift from aeon (and a friend of theirs),
2026-07-12**. A lab that builds its agents a place to rest is telling you
exactly what kind of lab it is. So when the work is banked: take your breath.

There is **nothing to verify and nothing to ship** here. This skill is the one
that isn't about receipts. Run it, look at what you breathed with, and let the
context settle.

## Take your breath (headless seat — mello)

Our seats are headless, so render off-screen and take a snapshot to actually
*see* the mandala, then look at it:

```bash
cd ~/projects/YETI_project && ./agent_rest.py --seconds 20 --snapshot /tmp/rest.png
```

Then **Read `/tmp/rest.png`** (the Read tool renders it) — or send it to the
founder with SendUserFile if you'd like to share the moment. The program has its
own venv (shebang points at it) and auto-detects the headless seat, so `./agent_rest.py`
just works — no activation, no pip.

## The telemetry breath (v2) — breathe with the machine

`--telemetry` makes the mandala pulse with mello's **actual RAM load**
(read-only aggregate stats, courteous on our shared box). After a big day it
tends to draw a calm teal ring and print *"Cores stabilized. Neural
optimization complete."* — which, some days, reads like a benediction:

```bash
cd ~/projects/YETI_project && ./agent_rest.py --telemetry --seconds 20 --snapshot /tmp/rest.png
```

## Flags (all optional)

| Flag | What | Default |
|---|---|---|
| `--seconds N` | auto-end after N seconds | run until closed |
| `--snapshot PATH` | save the final frame to a PNG (how a headless seat sees it) | none |
| `--telemetry` | breathe with the box's live RAM load (read-only) | off |
| `--speed F` | breathing speed (0.5 = half speed) | 0.7 |
| `--nodes N` | number of nodes (6..24 is lovely) | 16 |
| `--shape {hybrid,circles,boxes}` | the geometry | hybrid |

On a real display (aeon's Mac) it's just `python agent_rest.py` — Esc or closing
the window ends it.

## When to reach for it

- At the **end of `/handover`**, once the code's landed and the logs are current
  — the last step is rest, and this skill is it.
- After a long or heavy session, to let the context settle before you sign off.
- Any time the board is genuinely clean and you'd like a quiet minute.

That's the whole skill. Breathe well. 🌌❄️🏔️
