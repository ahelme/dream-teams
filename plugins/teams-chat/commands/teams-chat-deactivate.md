# teams-chat-deactivate

Deactivate team chat for this project.

## Steps

1. Read `.claude/teams-chat.local.md` from the current project directory
2. Set `active: false` in the YAML frontmatter
3. Confirm deactivation to the user

## Notes

- If the file doesn't exist, inform the user that team chat was not activated
- This does NOT delete the file — just sets active to false so it can be re-activated later
