---
name: deploy-prod
description: >
  Deploy main to production (aiworkshop.art). Claude executes deploy steps
  from the wiki in concert with the user, confirming before each destructive step.
  Use when: main has been updated and it's time to deploy to prod.
user-invocable: true
version: 1.1.0
---

# /deploy-prod — Deploy to Production

You (Claude) execute the deploy steps. Confirm with the user before each destructive action.
Reference: https://github.com/ahelme/comfymulti-scripts/wiki/Production-Deployment

## Image Tagging Convention (2026-04-21, supersedes #474)

**Docker images are tagged with the full release tag** (see `/create-release` skill for the release naming convention). Examples: `v0.17.2.1.0.0` (stable minor, no commit), `v0.17.2.1.0.1.9w3z8o` (hotfix, with commit).

### Retag rules

- **Stable release deploy:** retag ALL images with the new stable version (no commit suffix). Prod should end up with every image on the same stable tag.
- **Hotfix deploy:** only images that were **rebuilt for this hotfix** get the new hotfix tag. Images whose code did not change keep the previous stable tag. After a hotfix, prod shows a mix: `<stable-tag>` on unchanged images + `<hotfix-tag>` on rebuilt ones.

**Before deploying,** decide per image whether code has changed since the previous prod release. Rebuild only those. Verify afterwards that the tag on each container matches either the stable tag or the hotfix tag — nothing else.

### Example (post-stable deploy)

All 4 images tagged `v0.17.2.1.0.0` (no commit).

### Example (post-hotfix on top of stable)

| Image | Code changed? | Tag |
|---|---|---|
| `comfyume-v1-admin`, `comfyume-v1-nginx` | no | `v0.17.2.1.0.0` |
| `comfyume-frontend`, `comfyume-v1-queue-manager` | yes (hotfix) | `v0.17.2.1.0.1.9w3z8o` |

### Misc

- `COMFYUI_VERSION` still read from `.env` (part of the release tag)
- `generate-user-compose.sh` writes the frontend image tag — pass the **release tag** in when rebuilding (see step 5)
- Aligns with Sentry release (`deployed-{commit}`) — use the commit hash from the release tag

## 1. Update .env (if needed)

If this deploy includes new env vars, changed values, or updated comments, follow the full procedure **before deploying**:

**[Environment Files Update & Deployment Guide](https://github.com/ahelme/ops/wiki/Updating-&-Deploying-Environment-Files)**

Key steps: edit `.env` ground truth → archive `prod.env` → copy `.env` → substitute CHANGEME values → commit + push Ops Repo. Skip this step if no .env changes are needed.

## 2. Pre-flight

Show the user what's currently on prod vs what main has:

```bash
ssh dev@135.181.63.152 "cd ~/comfyume-v1 && git log --oneline -3"
```

Confirm with user: "Ready to deploy main to prod? (This causes downtime during rebuild.)"

## 3. Sync .env

```bash
ssh dev@135.181.63.152 "cd ~/comfymulti-scripts && git pull && yes | cp prod.env ~/comfyume-v1/.env"
```

Show result. If it fails, check the wiki Gotchas section.

## 3b. Tier-0 Infisical overlay (for Infisical-only vars)

**Use this when the release needs a secret that is in Infisical but not in `prod.env`.** Skip if no Infisical-only vars for this deploy.

_Why:_ #540 moves .env generation to Infisical eventually; Tier 0 is an interim — Infisical CLI is installed on prod (`/usr/bin/infisical`, 0.38.0, 2026-04-21), Machine Identity creds live in `~/.infisical.env` (project-level `production-instance` MI, scoped to `production` + `ops` envs, viewer role). This lets us ship a new secret in Infisical without editing `prod.env`.

For each Infisical-only key you need:

```bash
ssh dev@135.181.63.152 'source ~/.infisical.env && \
  export INFISICAL_TOKEN=$(infisical login --method=universal-auth \
    --client-id="$INFISICAL_UNIVERSAL_AUTH_CLIENT_ID" \
    --client-secret="$INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET" --plain --silent) && \
  val=$(infisical secrets get <KEY> \
    --projectId=21f0f464-9020-4109-9eda-5b0907b9c89e \
    --env=<production|ops> --path=<PATH> --plain --silent) && \
  grep -q "^<KEY>=" ~/comfyume-v1/.env \
    && sed -i "s|^<KEY>=.*|<KEY>=$val|" ~/comfyume-v1/.env \
    || echo "<KEY>=$val" >> ~/comfyume-v1/.env'
```

_Note when doing this:_
- Use `--env=production` for per-env secrets (passwords, tokens); `--env=ops` for shared org creds
- **Env slug is `production` on prod, NOT `prod`** — the Infisical env is named `production` in the project (distinct from testing's `testing`)
- Path lookup: see `/use-infisical` skill
- Don't echo the value — pipe straight into sed/append
- After overlay, restart whichever container consumes the var (`docker restart <name>`)
- Add the var to `prod.env` in the next /update-env cycle so the overlay becomes redundant — Tier 0 is a bridge, not a long-term store

_Next step (post-next release):_ replace this manual overlay with Tier 1 `generate-env.sh` wrapper (see #540).

## 4. Pull code

```bash
ssh dev@135.181.63.152 "cd ~/comfyume-v1 && git pull origin main"
```

If permission errors on `.claude/`, fix with `sudo chown -R dev:dev ~/comfyume-v1/.claude/` then retry.

## 4b. Disk space preflight (!MANDATORY — blocks Step 5)

**Why:** 2026-04-22 testing server filled mid-build. On prod a stall is user-facing. Frontend build needs ~25GB (ComfyUI clone + pip), compose adds 2-5GB. **Require ≥ 30GB free on `/`.**

```bash
ssh dev@135.181.63.152 "df -h / | tail -1"
```

If under 30GB, show what's using space:

```bash
ssh dev@135.181.63.152 "
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
| D | `docker image prune -af` — ALL unused images | **Dangerous on prod** — loses rollback tags. Aeon signoff required. |
| E | Cancel | — |

**Prod order: A → B → C.** D requires Aeon's OK. Re-run `df -h /`; continue only when free ≥ 30GB.

## 5. Build frontend image

Frontend is a separate image (not in docker-compose build). Tag pattern: `{COMFYUI_VERSION}-{commit}` (#474).

```bash
ssh dev@135.181.63.152 "cd ~/comfyume-v1 && source .env && COMMIT=\$(git rev-parse --short HEAD) && docker build -t comfyume-frontend:\${COMFYUI_VERSION}-\${COMMIT} -f comfyui-frontend/Dockerfile ."
```

This takes ~10 min (clones ComfyUI + pip install). Run in background if needed.

## 6. Regenerate user compose + rebuild compose services

Regenerate `docker-compose.users.yml` BEFORE `docker compose up` — it reads `NUM_USERS` and `COMFYUI_VERSION` from `.env` and sets the correct frontend image tag (#474).

```bash
ssh dev@135.181.63.152 "cd ~/comfyume-v1 && scripts/generate-user-compose.sh"
```

Then rebuild compose services and bring everything up.

**Cache strategy** (2026-04-22 clash fix, #474): `--pull` (refresh base images) not `--no-cache` (force-rebuild-all). Docker's layer cache skips unchanged services, preserving the stable-retag-all vs hotfix-retag-changed rules. `admin`+`queue-manager` always rebuild (their `ARG SENTRY_RELEASE` invalidates cache); `nginx` cache-hits when unchanged.

Snapshot image IDs before build:

```bash
ssh dev@135.181.63.152 'for s in admin queue-manager nginx; do docker image inspect comfyume-v1-$s:latest --format "{{.Id}}" 2>/dev/null > /tmp/$s.id.before || echo none > /tmp/$s.id.before; done'
```

Build + restart:

```bash
ssh dev@135.181.63.152 "cd ~/comfyume-v1 && docker compose build --pull --build-arg SENTRY_RELEASE=\"deployed-\$(git rev-parse --short HEAD)\" && docker compose down && docker compose up -d"
```

Replace `<RELEASE_TAG>` with your tag (stable: `v0.17.2.1.0.0` · hotfix: `v0.17.2.1.0.1.9w3z8o`).

**STABLE deploys — retag ALL** (post-deploy = all images on same stable tag):

```bash
ssh dev@135.181.63.152 'cd ~/comfyume-v1 && RELEASE_TAG="<STABLE_TAG>" && for s in admin queue-manager nginx; do
  docker tag comfyume-v1-$s:latest comfyume-v1-$s:$RELEASE_TAG; echo "RETAG $s → $RELEASE_TAG"
done'
```

**HOTFIX deploys — retag only changed** (post-deploy = mix: unchanged on stable tag + rebuilt on hotfix tag):

```bash
ssh dev@135.181.63.152 'cd ~/comfyume-v1 && RELEASE_TAG="<HOTFIX_TAG>" && for s in admin queue-manager nginx; do
  before=$(cat /tmp/$s.id.before)
  after=$(docker image inspect comfyume-v1-$s:latest --format "{{.Id}}")
  if [ "$before" != "$after" ]; then
    docker tag comfyume-v1-$s:latest comfyume-v1-$s:$RELEASE_TAG; echo "RETAG $s → $RELEASE_TAG"
  else
    echo "SKIP  $s (cache hit, keeping previous stable tag)"
  fi
done'
```

## 7. Verify

```bash
ssh dev@135.181.63.152 "cd ~/comfyume-v1 && docker compose ps --format 'table {{.Name}}\t{{.Status}}' && echo '--- git ---' && git log --oneline -3"
```

```bash
curl -s -o /dev/null -w '%{http_code}' https://aiworkshop.art
curl -s -o /dev/null -w '%{http_code}' https://aiworkshop.art/admin
```

**Sentry env tag assertion** — must be `production` on this server (compose now fails loud if unset, but verify runtime too):

```bash
ssh dev@135.181.63.152 'for c in comfy-admin comfy-queue-manager; do
  v=$(docker exec $c env 2>/dev/null | grep "^SENTRY_ENVIRONMENT=")
  [ "$v" = "SENTRY_ENVIRONMENT=production" ] && echo "OK   $c: $v" || echo "FAIL $c: $v (expected production)"
done'
```

Any FAIL → stop, investigate `.env` drift before continuing.

Report: container count + health, HTTP status codes, current commit on prod.
If anything looks wrong, check the **Gotchas** and **Rollback** sections on the wiki.

## 8. Post-Deploy Health Check

Run `/health-check --prod` to verify endpoints, containers, Redis, and Sentry:
- If new Sentry errors appear that weren't there before deploy → flag immediately
- If all clear → confirm deploy is healthy

## 9. Update Environment Manifest

**This is not optional.** Read the server's actual state and update `environments/production.yaml` in the Ops Repo:

```bash
# Get actual state from prod
ssh dev@135.181.63.152 'cd ~/comfyume-v1 && echo "commit=$(git rev-parse --short HEAD)" && echo "tag=$(git describe --tags --always)" && source .env && echo "comfyui=$COMFYUI_VERSION"'
```

Update `config_snapshot_id`, `codebase` block, and `containers` image tags. Commit via `/mo`.

Also update `infrastructure-registry.md` if any high-level inventory changed.

**If the worker image was rebuilt + pushed to VCCR this deploy:**
- Add a row to the worker image history table in `infrastructure-registry.md` (lines ~115-135) with: tag name, ComfyUI version, app version, build date, builder, source branch, ts_authkey (`NO` post-#446 Phase 2), Sentry, notes
- Worker image builds happen outside this skill flow — a dedicated `/deploy-worker` skill is tracked separately

## 10. Slack Update

Post deploy result to Slack and read recent messages (same as /us).
