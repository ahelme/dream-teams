---
name: gi
description: Create a GitHub issue with project, milestone, team assignment, and team signature
user-invocable: true
version: 1.1.0
---

# /gi — Create GitHub Issue

## Usage

`/gi <title or description>` — creates a well-formed issue from your description.

## Steps

1. **Draft the issue** from `$ARGUMENTS` or ask user if no args given
2. **Determine milestone** — ask if unclear. Current milestones: `1.0` (bugs/current), `2.0` (workshop/websockets), `3.0` (research)
3. **Read team identity** from `.claude/teams-chat.local.md` (emoji, name, team)
4. **Create the issue and add to project:**

```bash
url=$(gh issue create --repo ahelme/comfyume-v1 \
  --title "<title>" \
  --body "$(cat <<'EOF'
<issue body>

<emoji> <name> — <team>
EOF
)" \
  --milestone "<milestone>" \
  --label "<team-label>") \
  && gh project item-add 3 --owner "@me" --url "$url"
```

5. **Set Assigned Team in project** via GraphQL:

```bash
# Get the project item ID, then set Assigned Team field
# Get the project item ID — use items(last: 10) since newly added items appear at the end
item_id=$(gh api graphql -f query='{ user(login: "ahelme") { projectV2(number: 3) { items(last: 10) { nodes { id content { ... on Issue { number } } } } } } }' --jq ".data.user.projectV2.items.nodes[] | select(.content.number == <ISSUE_NUMBER>) | .id")

# Project ID: PVT_kwHOABKH7c4BSHYz (comfyume)
# Field ID: PVTSSF_lAHOABKH7c4BSHYzzg_vq4Y (Assigned Team)
# Options: Admin Panel Team=95978cbd, ComfyUI Team AKA Mello Team One=ce417d87, Sys Team=713b75a7, Desktop Team=08e412ba, Team Ralph=9c366d67, Verda Team One=536b22f9
gh api graphql -f query="mutation { updateProjectV2ItemFieldValue(input: { projectId: \"PVT_kwHOABKH7c4BSHYz\", itemId: \"$item_id\", fieldId: \"PVTSSF_lAHOABKH7c4BSHYzzg_vq4Y\", value: { singleSelectOptionId: \"<team_option_id>\" } }) { projectV2Item { id } } }" --silent
```

6. **Return the issue URL**

## Team Labels → Project Field Options

| Team Label | Assigned Team Option ID |
|------------|------------------------|
| `mello-admin-panel-team` | `95978cbd` (Admin Panel Team) |
| `mello-team-one` | `ce417d87` (ComfyUI Team AKA Mello Team One) |
| `mello-scripts-team` | `713b75a7` (Sys Team) |
| `mello-ralph-team` | `9c366d67` (Team Ralph) |
| `verda-team-one` | `536b22f9` (Verda Team One) |
