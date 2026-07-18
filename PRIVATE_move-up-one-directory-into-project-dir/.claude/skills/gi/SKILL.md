---
name: gi
description: Create a GitHub issue with milestone, team assignment, project-board placement, and team signature
user-invocable: true
version: 1.1.0
---

# /gi — Create GitHub Issue

## Usage

`/gi <title or description>` — creates a well-formed issue from your description.

## Steps

1. **Draft the issue** from `$ARGUMENTS` or ask user if no args given
2. **Determine milestone** — ask if unclear. [ ADAPT: list your current milestones here ]
3. **Read team identity** from `.claude/teams-chat.local.md` (emoji, name, team)
4. **Create the issue and add to project:**

```bash
url=$(gh issue create --repo [ OWNER/REPO ] \
  --title "<title>" \
  --body "$(cat <<'EOF'
<issue body>

<emoji> <name> — <team>
EOF
)" \
  --milestone "<milestone>" \
  --label "<team-label>") \
  && gh project item-add [ PROJECT NUMBER ] --owner "@me" --url "$url"
```

5. **Set Assigned Team in project** via GraphQL (skip if your project board has no team field):

```bash
# Get the project item ID — use items(last: 10) since newly added items appear at the end
item_id=$(gh api graphql -f query='{ user(login: "[ OWNER ]") { projectV2(number: [ PROJECT NUMBER ]) { items(last: 10) { nodes { id content { ... on Issue { number } } } } } } }' --jq ".data.user.projectV2.items.nodes[] | select(.content.number == <ISSUE_NUMBER>) | .id")

# [ ADAPT: fill in your project ID, "Assigned Team" field ID, and option IDs.
#   Discover them with: gh project field-list [ PROJECT NUMBER ] --owner "@me" --format json ]
gh api graphql -f query="mutation { updateProjectV2ItemFieldValue(input: { projectId: \"[ PROJECT ID ]\", itemId: \"$item_id\", fieldId: \"[ TEAM FIELD ID ]\", value: { singleSelectOptionId: \"<team_option_id>\" } }) { projectV2Item { id } } }" --silent
```

6. **Return the issue URL**

## Team Labels → Project Field Options

[ ADAPT: table mapping each team label to its Assigned Team option ID ]

| Team Label | Assigned Team Option ID |
|------------|------------------------|
| `[ team-a-label ]` | `[ option-id ]` |
| `[ team-b-label ]` | `[ option-id ]` |
