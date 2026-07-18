# Skills Registry

Full list of this Teams repo's custom skills. Keep a summary in CLAUDE.md too
(minus team-specific/specialist skills).

## How registration works

- Each skill lives at `.claude/skills/<name>/SKILL.md`. Frontmatter `name:`
  MUST equal the directory name — that name is the `/<name>` invocation.
- Every team clone gets all skills via the committed `.claude/skills` symlink
  into this repo (see `agent_tools/README.md`).
- When you add, rename, or retire a skill: update this registry AND the
  CLAUDE.md summary in the same commit.
- Group skills by purpose (Git & PRs, Progress & Comms, Deploy & Config,
  Session & Handover, Utilities, ...). One row per skill: name + one-line
  description.

## Utilities & Welfare (shipped with the template)

| Skill | Description |
|-------|-------------|
| `/celebrate` | Share pride in what we built — end-of-session reflection for sessions with real weight |
| `/check-slack-shared-slack-app` | Read recent team Slack messages via the shared Slack app; optionally post an update |
| `/smoko` | Creative break — fortune cookies, haiku, ASCII art, word games |
| `/terse-style` | Telegraphic style — rewrite text to omit needless words |

## Project skills

[ ADAPT: register your project's remaining skills here — one row per
`.claude/skills/<dir>`, grouped by purpose as above. ]
