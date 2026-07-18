---
name: pull-main
description: Pulls latest changes from main into the current branch and reports the result. Use when the user asks to pull, sync, or update from main.
user-invocable: true
version: 1.1.0
---

Please pull latest changes from main into the current branch.

**Steps:**
1. Run `git fetch origin main`
2. Show me what's new: `git log --oneline HEAD..origin/main`
3. If there are new commits, merge with `git merge origin/main`
4. Report result (clean merge, conflicts, or already up to date)
