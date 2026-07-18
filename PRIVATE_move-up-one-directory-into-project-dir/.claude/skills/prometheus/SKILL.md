---
name: prometheus
description: Prometheus monitoring — metrics collection, PromQL querying, config reload, targets.
user-invocable: true
version: 1.0.0
---

Prometheus monitoring — metrics collection and querying.

[ MONITORING STACK DETAILS HERE — host/SSH access, port, data dir,
retention, scrape targets ]

**Server:** [ SSH COMMAND / HOST — or run locally ]
**Port:** 9090 (default)
**Config:** `/etc/prometheus/prometheus.yml`
**Data:** `/var/lib/prometheus/` ([ RETENTION ])
**Service:** `systemctl {start|stop|restart|status} prometheus`

Commands below assume Prometheus on `localhost:9090` — prefix with
`ssh [ SSH HOST ]` if remote. Container examples use `[ CONTAINER PREFIX ]`.

## Common Operations

```bash
# Check targets
curl -s localhost:9090/api/v1/targets | python3 -m json.tool | head -30

# Query a metric (PromQL via API)
curl -s 'localhost:9090/api/v1/query?query=up' | python3 -m json.tool

# Check config
cat /etc/prometheus/prometheus.yml

# Reload config without restart
curl -X POST localhost:9090/-/reload

# Check storage usage
du -sh /var/lib/prometheus/
```

## Useful PromQL Queries

```promql
# Container CPU usage
rate(container_cpu_usage_seconds_total{name=~"[ CONTAINER PREFIX ]-.*"}[5m])

# Container memory usage
container_memory_usage_bytes{name=~"[ CONTAINER PREFIX ]-.*"}

# Container network I/O
rate(container_network_receive_bytes_total{name=~"[ CONTAINER PREFIX ]-.*"}[5m])

# Filesystem usage
container_fs_usage_bytes{name=~"[ CONTAINER PREFIX ]-.*"}

# Container start time (restart debugging)
container_start_time_seconds{name=~"[ CONTAINER PREFIX ]-.*"}

# All targets up/down
up
```

## Scrape Targets

- `prometheus` (self, localhost:9090)
- `cadvisor` (Docker metrics) [ ADAPT: port and any additional targets ]

To add more targets, edit `/etc/prometheus/prometheus.yml` and reload.

If $ARGUMENTS provided, treat as a PromQL query or Prometheus operation.
