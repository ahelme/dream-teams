---
name: pull-test
description: Pull latest changes from [ INTEGRATION BRANCH ] into current branch
user-invocable: true
version: 1.1.0
---

1. `git fetch origin [ INTEGRATION BRANCH ]`
2. `git merge origin/[ INTEGRATION BRANCH ]`
3. If conflict: show conflicting files, attempt resolution, ask user if unsure
4. Confirm merge result
