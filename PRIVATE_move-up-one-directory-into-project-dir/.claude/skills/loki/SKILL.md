---
name: loki
description: Loki log aggregation — query container logs with LogQL, check Promtail shipping, storage.
user-invocable: true
version: 1.0.0
---

Loki log aggregation — query logs with LogQL.

[ MONITORING STACK DETAILS HERE — Loki host/SSH access, port, retention,
data dir, Promtail config path ]

**Server:** [ SSH COMMAND / HOST — or run locally ]
**Port:** 3100 (default)
**Config:** `/etc/loki/config.yml`
**Promtail config:** `/etc/promtail/config.yml`
**Retention:** [ RETENTION, e.g. 7 days ]
**Services:** `systemctl {start|stop|restart|status} loki` / `promtail`

Commands below assume Loki on `localhost:3100` — prefix with
`ssh [ SSH HOST ]` if remote. Container examples use a common name prefix,
shown as `[ CONTAINER PREFIX ]`.

## Common Operations

```bash
# Check Loki is ready
curl -s localhost:3100/ready

# Check Promtail is shipping logs
systemctl is-active promtail && curl -sf localhost:9080/ready && echo 'Promtail: READY' || echo 'Promtail: NOT READY'

# Query logs via LogQL API
curl -s -G 'localhost:3100/loki/api/v1/query_range' --data-urlencode 'query={container_name=~"[ CONTAINER PREFIX ]-.*"}' --data-urlencode 'limit=20' | python3 -m json.tool | head -50

# Check available labels
curl -s localhost:3100/loki/api/v1/labels

# Check storage usage
du -sh [ LOKI DATA DIR ]   # check config — may not be /var/lib/loki

# Check which containers are being indexed
curl -s localhost:3100/loki/api/v1/label/container_name/values | python3 -m json.tool
```

## LogQL Query Syntax

```logql
# All logs from a specific container
{container_name="[ CONTAINER PREFIX ]-api"}

# Filter by text
{container_name="[ CONTAINER PREFIX ]-api"} |= "error"

# Exclude pattern
{container_name="[ CONTAINER PREFIX ]-nginx"} != "health"

# Regex filter
{container_name=~"[ CONTAINER PREFIX ]-user.*"} |~ "model|path|mount"

# Multiple filters (AND)
{container_name="[ CONTAINER PREFIX ]-api"} |= "worker" |= "error"

# JSON parsing
{container_name="[ CONTAINER PREFIX ]-api"} | json | level="error"

# Rate of errors (for alerting)
rate({container_name=~"[ CONTAINER PREFIX ]-.*"} |= "error" [5m])
```

## Starter queries

```logql
# Nginx auth/routing issues
{container_name="[ CONTAINER PREFIX ]-nginx"} |~ "401|403|502|504"

# All errors across all containers
{container_name=~"[ CONTAINER PREFIX ]-.*"} |= "error" != "favicon"
```

[ ADAPT: add queries for your project's recurring issues ]

## Grafana Integration

View logs in Grafana ([ GRAFANA URL ]) → Explore → Select Loki data source → Enter LogQL query.

If $ARGUMENTS provided, treat as a LogQL query or log operation.
