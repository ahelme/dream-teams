---
name: update-session-log
description: Add a terse, newest-first entry to all-teams-session-log.md (team · UTC time · Claude resume session id · 1–2 line summary + links). Use at the end of a working session and whenever you make ops changes or significant code changes.
user-invocable: true
---

# Update the session log

Prepend a **newest-first** entry to `all-teams-session-log.md` (repo root).

1. **UTC time:** `date -u +"%Y-%m-%d %H:%M"`
2. **Resume session id:** basename (minus `.jsonl`) of the most-recently-modified file in
   **this project's** encoded dir (don't glob all projects — another project's
   session could be newer):
   `basename "$(ls -t ~/.claude/projects/<encoded-project>/*.jsonl | head -1)" .jsonl`
3. **Prepend the entry** at the top of the list:
   ```
   - **[ TEAM NAME ]** · <YYYY-MM-DD HH:MM> UTC · resume `<session-id>`
     — 1–2 line terse summary of what changed / was decided.
     → links: `path/to/file` · #issue · <commit-sha> · [ PATH/TO/DETAIL DOCS ]
   ```
4. **Terse — link, don't repeat.** Point to where the detail lives, don't restate it.
5. [ ADAPT: decide whether the log is tracked in git (commit it with the session's
   changes) or lives outside the repo (e.g. a gitignored symlink into a private
   dir — then writing the file IS the update). ]
