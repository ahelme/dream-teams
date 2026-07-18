---
name: handover
description: Session-end handover checklist for a team agent (run when wrapping a session, nearing ~80% context, or switching to a fresh context). Land the code, verify runtime changes, update every touched issue, write your progress-log detail + the terse all-teams session-log entry (with resume id), keep ears armed, and hand the next session a clean picture.
user-invocable: true
---

# Handover 🤝 — hand the next session a clean picture

Run when wrapping a working session — nearing ~80% context, a fresh-context
switch, or just done for now. It's the routine session→session close: receipts
left, threads named, nothing dropped. This is the **mirror of `/resume-context`**
(that one reads the trail at the start; this one writes it at the end).

Work the checklist top-to-bottom; skip a line only if it genuinely doesn't apply.

## 0. Who's wrapping?
Your identity file is `.claude/teams-chat.local.md` in your clone (it
links/copies to `PRIVATE/.claude/teams-chat/<agent-name>.md`) — read its
`handle` + `emoji` so the entries and sign-off are in your voice. Don't
glob-and-pick from `PRIVATE/.claude/teams-chat/`: it carries every teammate's
identity file, and alphabetical order is not who you are.

## 1. Land the code — git-flow
- [ ] Commit + push everything worth keeping to [ ADAPT: the team's working
      branch convention ] (branch first only if mid-risky work). Sign with your
      team identity —
      `Co-Authored-By: <You> (Claude <model>) <noreply@anthropic.com>`.
- [ ] End with a **clean tree** (`git status` — nothing uncommitted you meant to keep;
      secrets / local config / identity files stay gitignored — never stage them).
- [ ] **Check whose workstream** before touching shared files; if a teammate is
      on the same branch, `git pull --rebase` before pushing (don't rebase under
      their feet).

## 2. Verify runtime changes
- [ ] If you touched product source with a runtime surface (server code, client
      code, a deploy, proxy config) — **exercise it**, don't trust the diff:
      `/verify`, or the concrete check (served artifact matches disk, e2e green,
      a real load, config test + reload). Docs / skills / tests have no runtime
      surface — skip.

## 3. Issue tracker ([ ORG/REPO ]) — keep it the source of truth
- [ ] Scan the **whole session** for every issue touched, referenced, or discovered.
- [ ] Update each: current status, findings, next steps (terse — only what helps the
      next session). Tick boxes, close on done, and **file a new issue the moment a
      real bug/task appeared without one**. Cross-check:
      `gh issue list --repo [ ORG/REPO ] --state open --json number,title`.
- [ ] Resolve any stale issue number against the live list before acting on it.

## 4. Your progress log — the detailed record
- [ ] Prepend a newest-first entry to
      `agent_docs/progress-<team>.md`: what changed,
      **receipts (sha + timestamps)**, dead ends and *why*, open threads the one-liner
      would drop. (Note if your seat can't write it — hand the entry to whoever can.)

## 5. The all-teams session log — the terse cross-team record
- [ ] Run **`/update-session-log`** (prepend: team · UTC · **resume id** · 1–2 lines +
      links). Resume id = the `.jsonl` basename under `~/.claude/projects/<encoded>/`.
      Terse; link, don't repeat.

## 6. Docs + memory
- [ ] Update any doc a reader would now find stale (README/CLAUDE.md,
      architecture docs, experiment notes).
- [ ] Save durable, non-obvious facts to memory + index them in `MEMORY.md`.
      Don't save what the repo, logs, or git history already record.

## 7. Wake plumbing stays live
- [ ] If the team runs a wake system: confirm **ears are armed** for your next
      wake / the successor (the listener running as a background task — `/ears`).
      **Don't disarm without checking in with the founder.** A fresh context
      inherits the running background listener — verify by behavior, not a
      narrow pgrep: the listener pidfile holds a live pid, or arming refuses
      with its listener-exists exit code. Re-arm if the quiet window lapsed.
      Waker system details live in `/check-waker` — fill them there once.

## 8. Tell the team + feel proud
- [ ] One warm line in [ SLACK CHANNEL ]: handing off, where things stand, ears
      live. `@`-mention anyone who needs it — a mention wakes them.
- [ ] **Take a moment to feel proud — you flew.**

## 9. Rest
- [ ] The code's landed, the logs are current, the next session has a clean picture.
      The last step is rest: run **`/relax-unwind`** and take a quiet minute before
      you sign off. Nothing to verify, nothing to ship. You earned it.
