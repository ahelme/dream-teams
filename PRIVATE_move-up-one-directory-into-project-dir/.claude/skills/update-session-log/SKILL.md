---
name: update-session-log
description: Add a terse, newest-first entry to YOUR per-agent session log (team · UTC time · Claude resume session id · 1–2 line summary + links), then restitch the all-teams view. Use at the end of a working session and whenever you make ops changes or significant code changes.
user-invocable: true
---

# Update the session log

Prepend a **newest-first** entry to **your own** log file
`session-logs/<your-agent-slug>.md` (location per step 6 below), then
regenerate the combined view. You write ONLY to your own file — the combined
`all-teams-session-log.md` is GENERATED; never edit it directly.

1. **UTC time:** `date -u +"%Y-%m-%d %H:%M"`
2. **Resume session id:** basename (minus `.jsonl`) of the most-recently-modified file in
   **this project's** encoded dir (don't glob all projects — another project's
   session could be newer):
   `basename "$(ls -t ~/.claude/projects/<encoded-project>/*.jsonl | head -1)" .jsonl`
3. **Prepend the entry** at the top of your file's entry list:
   ```
   ## <YYYY-MM-DD HH:MM> UTC — [ Agent Name emoji ] ([ TEAM NAME ])

   - 1–2 line terse summary of what changed / was decided · resume `<session-id>`
   - → links: `path/to/file` · #issue · <commit-sha> · [ PATH/TO/DETAIL DOCS ]
   - NEXT: what's next
   ```
4. **Restitch the combined view:** `.claude/agent_tools/bin/team-log`
5. **Terse — link, don't repeat.** Point to where the detail lives, don't restate it.
6. [ ADAPT: where the logs live and whether they're tracked. Shipped default:
   per-agent files in `PRIVATE/.claude/agent_docs/untracked/session-logs/`,
   with the generated `all-teams-session-log.md` beside them (reachable via
   the gitignored clone-root symlink). Because each agent owns one file,
   tracking the `session-logs/` dir in git is also safe — no two agents ever
   edit the same file, so no merge conflicts; commit your own log with your
   session's changes and treat the stitched view as a build artifact. ]
