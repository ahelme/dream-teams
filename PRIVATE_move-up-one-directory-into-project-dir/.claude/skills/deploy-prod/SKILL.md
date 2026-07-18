---
name: deploy-prod
description: >
  Deploy main to production ([ PRODUCTION URL ]). Claude executes the deploy
  steps in concert with the user, confirming before each destructive step.
  Use when: main has been updated and it's time to deploy to prod.
user-invocable: true
version: 1.0.0
---

# /deploy-prod — Deploy to Production

You (Claude) execute the deploy steps. Confirm with the user before each destructive action.
Reference: [ DEPLOYMENT WIKI / RUNBOOK URL ]

All remote commands below use `ssh [ SSH COMMAND, e.g. user@production-host ]`
and the app dir `[ APP DIR ]` on [ PRODUCTION HOST ]. Adapt if prod runs locally.

## Image Tagging Convention

**Docker images are tagged with the full release tag** (see `/create-release` for the naming convention).

### Retag rules

- **Stable release deploy:** retag ALL images with the new stable version (no commit suffix). Prod ends with every image on the same stable tag.
- **Hotfix deploy:** only images **rebuilt for this hotfix** get the new hotfix tag. Images whose code did not change keep the previous stable tag. After a hotfix, prod shows a mix: `<stable-tag>` on unchanged images + `<hotfix-tag>` on rebuilt ones.

**Before deploying,** decide per image whether code has changed since the previous prod release. Rebuild only those. Verify afterwards that the tag on each container matches either the stable tag or the hotfix tag — nothing else.

## 1. Update .env (if needed)

If this deploy includes new env vars, changed values, or updated comments,
follow the team's env-file update procedure **before deploying**:
[ ENV FILE UPDATE PROCEDURE / WIKI LINK — e.g. edit ground-truth env →
archive prod env → copy → substitute CHANGEME values → commit ops repo ].
Skip if no .env changes are needed.

## 2. Pre-flight

Show the user what's currently on prod vs what main has:

```bash
ssh [ SSH COMMAND ] "cd [ APP DIR ] && git log --oneline -3"
```

Confirm with user: "Ready to deploy main to prod? (This causes downtime during rebuild.)"

## 3. Sync .env

```bash
[ ADAPT: sync the prod env file from its source of truth to [ APP DIR ]/.env ]
```

Show result.

## 3b. Secrets-manager overlay (for vars not in the env file)

**Use this when the release needs a secret that lives only in the secrets
manager.** Skip if not needed for this deploy.

[ SECRETS MANAGER DETAILS & STEPS REQUIRED HERE — CLI location, machine
identity/auth creds location, project/env slugs, and the fetch-and-append
command. ]

Rules when doing this:
- Don't echo the value — pipe straight into sed/append on the env file
- After overlay, restart whichever container consumes the var (`docker restart <name>`)
- Add the var to the canonical prod env file in the next env-update cycle so the overlay becomes redundant — it's a bridge, not a long-term store

## 4. Pull code

```bash
ssh [ SSH COMMAND ] "cd [ APP DIR ] && git pull origin main"
```

## 4b. Disk space preflight (!MANDATORY — blocks Step 5)

A build that fills the disk mid-deploy stalls prod user-facing. Estimate the
build's disk need and **require enough headroom** ([ ADAPT: e.g. ≥30GB free on `/` ]).

```bash
ssh [ SSH COMMAND ] "df -h / | tail -1"
```

If short, show what's using space:

```bash
ssh [ SSH COMMAND ] "
  echo '=== docker system df ==='; docker system df
  echo '=== Top 10 images by size ==='; docker images --format '{{.Size}}\t{{.Repository}}:{{.Tag}}' | sort -rh | head -10
  echo '=== Dangling ==='; docker images -f 'dangling=true' --format '{{.ID}} {{.Size}}' | head
  echo '=== Builder cache ==='; docker builder du 2>/dev/null | head -3
"
```

**Present options and WAIT for explicit confirmation before any destructive command.**

| Option | Command | Risk |
|---|---|---|
| A | `docker builder prune -af` — all build cache | Safe |
| B | `docker image prune -f` — dangling only | Safe |
| C | `docker rmi <image>:<tag>` — specific old tags | Safe if you keep `:latest` + current release + last-known-good rollback |
| D | `docker image prune -af` — ALL unused images | **Dangerous on prod** — loses rollback tags. [ APPROVER ] signoff required. |
| E | Cancel | — |

**Prod order: A → B → C.** D requires [ APPROVER ]'s OK. Re-run `df -h /`; continue only with enough headroom.

## 5. Build images outside compose (if any)

[ ADAPT: some stacks have images built outside `docker compose build`
(e.g. a large frontend image). Build them here, tagged per the release
convention; long builds can run in background. ]

## 6. Rebuild compose services

[ ADAPT: regenerate any generated compose files BEFORE `docker compose up`
if the stack uses them (e.g. per-user service generation from .env). ]

**Cache strategy:** use `--pull` (refresh base images), not `--no-cache`
(force-rebuild-all). Docker's layer cache skips unchanged services,
preserving the stable-retag-all vs hotfix-retag-changed rules.

Snapshot image IDs before build (to detect which images actually changed):

```bash
ssh [ SSH COMMAND ] 'for s in [ SERVICE LIST ]; do docker image inspect [ IMAGE PREFIX ]-$s:latest --format "{{.Id}}" 2>/dev/null > /tmp/$s.id.before || echo none > /tmp/$s.id.before; done'
```

Build + restart:

```bash
ssh [ SSH COMMAND ] "cd [ APP DIR ] && docker compose build --pull && docker compose down && docker compose up -d"
```

**STABLE deploys — retag ALL** (post-deploy = all images on same stable tag):

```bash
ssh [ SSH COMMAND ] 'cd [ APP DIR ] && RELEASE_TAG="<STABLE_TAG>" && for s in [ SERVICE LIST ]; do
  docker tag [ IMAGE PREFIX ]-$s:latest [ IMAGE PREFIX ]-$s:$RELEASE_TAG; echo "RETAG $s → $RELEASE_TAG"
done'
```

**HOTFIX deploys — retag only changed** (post-deploy = mix: unchanged on stable tag + rebuilt on hotfix tag):

```bash
ssh [ SSH COMMAND ] 'cd [ APP DIR ] && RELEASE_TAG="<HOTFIX_TAG>" && for s in [ SERVICE LIST ]; do
  before=$(cat /tmp/$s.id.before)
  after=$(docker image inspect [ IMAGE PREFIX ]-$s:latest --format "{{.Id}}")
  if [ "$before" != "$after" ]; then
    docker tag [ IMAGE PREFIX ]-$s:latest [ IMAGE PREFIX ]-$s:$RELEASE_TAG; echo "RETAG $s → $RELEASE_TAG"
  else
    echo "SKIP  $s (cache hit, keeping previous stable tag)"
  fi
done'
```

## 7. Verify

```bash
ssh [ SSH COMMAND ] "cd [ APP DIR ] && docker compose ps --format 'table {{.Name}}\t{{.Status}}' && echo '--- git ---' && git log --oneline -3"
```

```bash
curl -s -o /dev/null -w '%{http_code}' [ PRODUCTION URL ]
curl -s -o /dev/null -w '%{http_code}' [ PRODUCTION URL ]/admin
```

**Error-tracker environment assertion** — the runtime environment tag must be
`production` on this server:

```bash
[ ADAPT: for each app container, assert its environment env var, e.g.
docker exec <container> env | grep '^SENTRY_ENVIRONMENT=' — expect production ]
```

Any FAIL → stop, investigate `.env` drift before continuing.

Report: container count + health, HTTP status codes, current commit on prod.
If anything looks wrong, check the runbook's Gotchas and Rollback sections.

## 8. Post-Deploy Health Check

Run `/health-check --prod` to verify endpoints, containers, services, and the error tracker:
- If new errors appear that weren't there before deploy → flag immediately
- If all clear → confirm deploy is healthy

## 9. Update Environment Manifest

**This is not optional.** Read the server's actual state and update the
environment manifest in the ops repo ([ ADAPT: manifest path, e.g.
`environments/production.yaml` — commit hash, tag, upstream pin, container
image tags ]):

```bash
ssh [ SSH COMMAND ] 'cd [ APP DIR ] && echo "commit=$(git rev-parse --short HEAD)" && echo "tag=$(git describe --tags --always)"'
```

Also update the infrastructure registry if any high-level inventory changed.

## 10. Announce

Post the deploy result to the team channel ([ ADAPT: Slack/other ]) and read recent messages.
