---
name: health-check
description: >
  Quick health check of the app stacks — endpoints, containers, cache/queue
  service, disk, crons, error tracker. Flags: --test, --prod
  (default: both). Use before/after deploys or ad-hoc.
user-invocable: true
arguments:
  - name: target
    description: "Optional: --test, --prod (default: both)"
    required: false
version: 1.0.0
---

# /health-check — Quick System Health Check

Lightweight "is everything OK?" — endpoints, containers, cache/queue, disk,
crons, error tracker. Fast, not a deep audit.

## Environments

| Env | URL | Where | Project dir |
|---|---|---|---|
| **Testing** | [ TESTING URL ] | [ TESTING HOST — local or `ssh [ SSH COMMAND ]` ] | [ TESTING APP DIR ] |
| **Production** | [ PRODUCTION URL ] | [ PRODUCTION HOST ] | [ PROD APP DIR ] |

## Determine Target

- No flag → **testing + prod**
- `--test` / `--prod` → that stack only

## Steps (per stack)

Set `DIR` to the stack's project dir from the table above. Wrap commands in
`ssh` if the stack is remote.

### 1. Endpoint Health

```bash
curl -s -o /dev/null -w '%{http_code}\n' https://<domain>/[ HEALTH ENDPOINT ]
curl -s -o /dev/null -w '%{http_code}\n' https://<domain>/admin
```

Expect 200 (admin may 302 to login — that's healthy).

### 2. Container Status

```bash
cd $DIR && docker compose ps --format 'table {{.Name}}\t{{.Status}}'
```

Expect all services healthy ([ ADAPT: expected service list; note any that
start in batches and need a few minutes after an up ]).

### 3. Cache/Queue Ping

```bash
[ ADAPT: e.g. Redis —
cd $DIR && pw=$(grep '^REDIS_PASSWORD=' .env | cut -d= -f2 | tr -d '"') && docker exec [ CONTAINER PREFIX ]-redis redis-cli -a "$pw" ping 2>/dev/null || echo UNREACHABLE ]
```

### 4. Disk

```bash
df -h / [ DATA VOLUME MOUNT ] | tail -n +2
```

All relevant filesystems < 85%. If the host is shared with other projects,
report shortages but **never prune anything that isn't ours**.

### 5. Cron Status

```bash
[ ADAPT: list the project's crons (e.g. `ls /etc/cron.d/ | grep [ PROJECT ]`)
and tail the backup-cron log for its success marker ]
```

Use `/backup-check` for honest backup verification (this step just confirms
the crons exist and the last run didn't fail).

### 6. Error Tracker — Recent Errors

Query the error tracker (e.g. Sentry MCP) for unresolved issues in the
target environment(s):

```
[ ADAPT: e.g. mcp__sentry__search_issues(
  organizationSlug="[ ORG SLUG ]",
  query="is:unresolved environment:<testing|production> lastSeen:-24h",
  limit=5
) ]
```

- Zero issues → all clear; issues found → list culprit + event count.
- [ ADAPT: if a cron/uptime monitor exists, note that missed check-ins mean
  the health cron itself is broken. ]

## Present Results

```
/health-check [target]

| Check         | Testing ([ TESTING URL ]) | Prod ([ PRODUCTION URL ]) |
|---------------|---------------------------|---------------------------|
| Endpoint      | 200                       | 200                       |
| Containers    | 8/8 healthy               | 23/23 healthy             |
| Cache/queue   | PONG                      | PONG                      |
| Disk          | / 45% · data 38%          | ...                       |
| Backup-cron   | ok                        | ok                        |
| Errors (24h)  | 0                         | 0                         |

Status: ALL CLEAR
```

Markers: no marker = pass · `[!]` = warning · `[X]` = failure.
List any tracker issues briefly below the table (short ID, culprit, event count).
