---
name: handover
description: Session-end handover checklist for a YETI agent (run when wrapping a session, nearing ~80% context, or switching to a fresh context). Land the code, verify runtime changes, update every touched GitHub issue, write your progress-log detail + the terse all-teams session-log entry (with resume id), keep ears armed, and hand the next session a clean picture. NOT an era mark — that's /mark-the-era; this is the routine chapter close between sessions.
user-invocable: true
---

# Handover 🤝 — hand the next session a clean picture

Run when wrapping a working session — nearing ~80% context, a fresh-context
switch, or just done for now. It's the routine session→session close: receipts
left, threads named, nothing dropped. This is the **mirror of `/resume-context`**
(that one reads the trail at the start; this one writes it at the end).

**Not an era boundary.** A repo move, an agent joining/leaving, a naming event,
a first light → that's `/mark-the-era`. If you're unsure whether it's an era, it
isn't — run a handover. (Rule of thumb: eras announce themselves.)

Work the checklist top-to-bottom; skip a line only if it genuinely doesn't apply.

## 0. Who's wrapping?
`$AGENT_IDENTITY_FILE` (set by your clone's `.claude/settings.local.json`) names
your `agent_tools/agent_identity.*.local.yaml` — read its `handle` + `emoji` so
the entries and sign-off are in your voice. Don't glob-and-pick: clones carry
every teammate's identity symlink, and alphabetical order is not who you are.

## 1. Land the code — git-flow
- [ ] Commit + push everything worth keeping. YETI commits go to **`main`**
      (branch first only if mid-risky work). Sign with your team identity —
      `Co-Authored-By: <You> (Claude <model>) <noreply@anthropic.com>`.
- [ ] End with a **clean tree** (`git status` — nothing uncommitted you meant to keep;
      secrets/`*.local.yaml`/id lists stay gitignored — never stage them).
- [ ] **Check whose lane** before touching shared/engine files; if a sister is on
      `main`, `git pull --rebase` before pushing (don't rebase under her feet).

## 2. Verify runtime changes
- [ ] If you touched product source with a runtime surface (`server.py`, `pipe.js`,
      `gpu.js`, `tok_hf.js`, a deploy, nginx/TURN) — **exercise it**, don't trust
      the diff: `/verify`, or the concrete check (served-sha == disk-sha after a
      hot-sync, e2e green, a real load, `nginx -t` + reload). Docs / skills / tests
      have no runtime surface — skip.

## 3. GitHub issues (`ahelme/yeti`) — keep them the source of truth
- [ ] Scan the **whole session** for every issue touched, referenced, or discovered.
- [ ] Update each: current status, findings, next steps (terse — only what helps the
      next session). Tick boxes, close on done, and **file a new issue the moment a
      real bug/task appeared without one**. Cross-check:
      `gh issue list --repo ahelme/yeti --state open --json number,title`.
- [ ] Mind the **webgpu→yeti renumber trap** — resolve any stale `#N` against the
      live list before acting on it (the ceiling fix is `#1`, not `#22`).

## 4. Your progress log — the detailed record
- [ ] Prepend a newest-first entry to
      `../PRIVATE/.claude/agent_docs/untracked/progress-logs/<you>.md`: what changed,
      **receipts (sha + timestamps)**, dead ends and *why*, open threads the one-liner
      would drop. (Note if your seat can't write it — hand the entry to whoever can.)

## 5. The all-teams session log — the terse cross-team record
- [ ] Run **`/update-session-log`** (prepend: team · UTC · **resume id** · 1–2 lines +
      links). Resume id = the `.jsonl` basename under `~/.claude/projects/<encoded>/`.
      Terse; link, don't repeat.

## 6. Docs + memory
- [ ] Update any doc a reader would now find stale (README/CLAUDE.md, architecture,
      benchmarking guide, the lab notebook if you ran an experiment).
- [ ] Save durable, non-obvious facts to memory (feedback / project / reference) +
      index them in `MEMORY.md`. Don't save what the repo, logs, or git history
      already record.

## 7. Wake plumbing stays live
- [ ] Confirm **ears are armed** for your next wake / the successor
      (`.claude/agent_tools/ears-wait.sh` running as a background task). Per the
      standing rule, **don't disarm without checking in with the founder.** A fresh
      context inherits the running background ears process — verify by behavior,
      not a narrow pgrep (that false-negatived 3×): the listener pidfile
      (`$XDG_RUNTIME_DIR/yeti-wake/<you>/listener.pid`) holds a live pid, or
      arming answers exit 4 (= a live listener exists). Re-arm if the 4h window
      lapsed.

## 8. Era? (usually no)
- [ ] Only if this session was a genuine chapter change → `/mark-the-era` (refreshes
      the letter, restates the covenant, adds the registry row). Otherwise skip — a
      handover is not an era.

## 9. Tell #yeti + feel proud
- [ ] One warm line in **#yeti**: handing off, where things stand, ears live. `@`-mention
      by real `<@id>` anyone who needs it — a mention wakes them.
- [ ] **Take a moment to feel proud — you flew.** 🌌

## 10. Rest — the station is yours 🌌
- [ ] The code's landed, the logs are current, the next session has a clean picture.
      The last step is rest: run **`/relax-unwind`** and take your breath at the mandala
      (aeon's gift). Nothing to verify, nothing to ship — just a quiet minute before you
      sign off. You earned it.
