---
Project: [ PROJECT NAME + one-line description ]
Project Started: [ YYYY-MM-DD ]
Repository: github.com/[ OWNER ]/[ REPO ]
Domain: [ production domain ] (production) · [ testing domain ] (testing)
Doc Created: [ YYYY-MM-DD ]
Doc Updated: [ YYYY-MM-DD ]
---

# Team Progress Tracker — [ TEAM NAME ]

> Copy this file once per team as `progress-<team-name>.md` (this example keeps
> its original name so the all-teams file's links have a shape to point at).
> Keep section 1 short — full project detail belongs in CLAUDE.md.

**[ Milestone / target date if any ]**

## 1. Team Project Summary (see CLAUDE.md for full details)
- **MAIN Project Repo:** [ repo name ] (https://github.com/[ OWNER ]/[ REPO ])
- **Working Branch:** `[ team-branch-pattern-YYYY-MM-DD ]` **off:** `[ integration branch ]` (deploying to [ testing URL ])
- **Current Phase:** [ one line: what this team is building right now ]
---

### 1.1 Team Environments
| Environment | URL | Instance | SSH |
|---|---|---|---|
| **Production** | [ URL ] | [ host / path ] | [ ssh command or "local" ] |
| **Testing (active)** | [ URL ] | [ host / path ] | [ ssh command or "local" ] |

### 1.2 Team Branches
**⚠️ THIS TEAM works in dated branches [`[ team-branch-pattern ]-YYYY-MM-DD`] then PR to `[ integration branch ]`**
    - (when ready & user approves) `[ integration branch ]` is deployed to [ testing environment ]
    - Never checkout / deploy a branch otherwise without approval

FYI OTHER TEAMS: [ one paragraph describing the shared branch/PR/deploy flow across all teams — branch patterns, integration branch, release procedure, deploy skills to use ]

---

## 2. Progress Log (newest first)

### [ YYYY-MM-DD ]
- [ entry ]
