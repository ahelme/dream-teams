---
name: pt
description: Pull latest changes from all-teams-testing into current branch
user-invocable: true
version: 1.1.0
---

1. `git fetch origin all-teams-testing`
2. `git merge origin/all-teams-testing`
3. If conflict: show conflicting files, attempt resolution, ask user if unsure
4. Confirm merge result
