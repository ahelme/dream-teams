---
name: pull-main
description: Pulls latest changes from [ MAIN BRANCH ] into the current branch and reports the result. Use when the user asks to pull, sync, or update from main.
user-invocable: true
version: 1.1.0
---

Please pull latest changes from [ MAIN BRANCH ] into the current branch.

**Steps:**
1. Run `git fetch origin [ MAIN BRANCH ]`
2. Show me what's new: `git log --oneline HEAD..origin/[ MAIN BRANCH ]`
3. If there are new commits, merge with `git merge origin/[ MAIN BRANCH ]`
4. Report result (clean merge, conflicts, or already up to date)
