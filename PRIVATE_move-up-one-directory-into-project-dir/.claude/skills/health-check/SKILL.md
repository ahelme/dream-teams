---
name: health-check
description: >
  Quick health check of the ComfyuMe stacks — both run LOCALLY on mello
  (post re-home 2026-07-15): endpoints, containers, Redis, disk, crons,
  Sentry. No SSH needed. Flags: --test, --prod (default: both), --legacy
  (fair-snow, while it still exists). Use before/after deploys or ad-hoc.
user-invocable: true
arguments:
  - name: target
    description: "Optional: --test, --prod, --legacy (default: --test --prod)"
    required: false
version: 2.0.0
---

# /health-check — Quick System Health Check

Lightweight "is everything OK?" — endpoints, containers, Redis, disk, crons, Sentry.
Fast, not a deep audit. **For a deep audit use `/config-audit` instead.**

## Environments (post re-home, ADR ops/rehome 2026-07-15)

| Env | URL | Where | Project dir |
|---|---|---|---|
| **Testing** | https://mello-testing.aiworkshop.art | mello (local) | `/home/dev/projects/comfyume-new/team-clones/spl-team/comfyume-v1` |
| **Production** | https://aiworkshop.art | mello (local) | `/home/dev/deploy/comfyume-prod` (data: `/mnt/volume-1/comfyume-prod/data`) |
| Legacy testing | https://anegg.app | fair-snow `ssh dev@65.108.33.109` | **death row** — deleted ~48h after prod cutover; `--legacy` only |

round-earth (old Verda prod) was **DELETED 2026-07-15** — never SSH to 135.181.63.152.
Project dirs may move as #639 settles — if a dir is missing, `ls /mnt/volume-1/` and
check `#639`/progress files before assuming the stack is down.

## Determine Target

- No flag → **testing + prod** (both local)
- `--test` / `--prod` → that stack only
- `--legacy` → fair-snow read-only check (add only while the box exists)

## Steps (per local stack — no SSH)

Set `DIR` to the stack's project dir from the table above.

### 1. Endpoint Health

```bash
curl -s -o /dev/null -w '%{http_code}\n' https://<domain>/health/ping
curl -s -o /dev/null -w '%{http_code}\n' https://<domain>/admin
```

Expect 200 (admin may 302 to login — that's healthy). If prod isn't cut over yet
(#639 in flight), note "pre-cutover" rather than flagging a failure.

### 2. Container Status

```bash
cd $DIR && docker compose ps --format 'table {{.Name}}\t{{.Status}}'
```

Expect nginx + redis + QM + N user frontends, all healthy. Frontends start in
batches (~2-3 min after an up).

### 3. Redis Ping

```bash
cd $DIR && pw=$(grep '^REDIS_PASSWORD=' .env | cut -d= -f2 | tr -d '"') && docker exec comfy-redis redis-cli -a "$pw" ping 2>/dev/null || echo UNREACHABLE
```

### 4. Disk

```bash
df -h / /mnt/volume-1 | tail -n +2
```

Root and `/mnt/volume-1` (Docker data-root + backups + prod data) both < 85%.
mello is a **shared box** — if space is short, report it; never prune anything
that isn't ours.

### 5. Cron Status

Both comfyume crons are root system crons in `/etc/cron.d/`:

```bash
ls /etc/cron.d/ | grep comfyume
echo "Backup-cron last: $(sudo tail -1 /var/log/backup-cron.log 2>/dev/null || echo 'no log')"
```

- `comfyume-backup` — hourly `/usr/local/bin/backup-cron.sh` (configs + user-data
  tarballs → `/mnt/volume-1/backups/comfyume`, R2 at 02/06/14/18 UTC, Slack on
  failure + 06/18 UTC summary). Log shows `done — ok: N` on success.
- `comfyume-certbot-status` — hourly cert visibility check.

Use `/backup-check` for honest backup verification (this step just confirms the
crons exist and the last run didn't fail).

### 6. Sentry — Recent Errors

Query Sentry MCP for unresolved issues in the target environment(s):

```
mcp__sentry__search_issues(
  organizationSlug="aeon-lab",
  query="is:unresolved environment:<testing|production> lastSeen:-24h",
  limit=5
)
```

- Zero issues → all clear; issues found → list culprit + event count.
- Cron monitor **comfyume-health-mello** (repointed 2026-07-15, #642) tracks BOTH
  stacks — env `testing` + `production` in one monitor (Sentry bills per-monitor
  seat). Missed check-ins there = the mello health-cron itself is broken.

## Legacy fair-snow check (--legacy, while the box exists)

```bash
ssh dev@65.108.33.109 'cd ~/comfyume-v1 && docker compose ps --format "{{.Name}} {{.Status}}" | head -5 && df -h / | tail -1'
```

Read-only. No fixes, no deploys — the box is winding down (#642 graceful cron
retirement). If SSH fails, it may simply have been deleted; check progress files.

## Present Results

```
/health-check [target]

| Check        | Testing (mello-testing.aiworkshop.art) | Prod (aiworkshop.art)  |
|--------------|----------------------------------------|------------------------|
| Endpoint     | 200                                    | 200                    |
| Containers   | 8/8 healthy                            | 23/23 healthy          |
| Redis        | PONG                                   | PONG                   |
| Disk         | / 45% · vol-1 38%                      | (same box)             |
| Backup-cron  | done — ok: 2                           | [!] prod dirs not yet in scope (#642) |
| Sentry (24h) | 0 errors                               | 0 errors               |

Status: ALL CLEAR
```

Markers: no marker = pass · `[!]` = warning · `[X]` = failure.
List any Sentry issues briefly below the table (short ID, culprit, event count).
