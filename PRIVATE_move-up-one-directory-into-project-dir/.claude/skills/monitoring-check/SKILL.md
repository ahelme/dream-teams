---
name: monitoring-check
description: Quick health check of the full monitoring stack (Prometheus, Loki, Grafana, cAdvisor, Promtail).
user-invocable: true
version: 1.0.0
---

Quick health check of the full monitoring stack.

[ MONITORING STACK DETAILS HERE — host/SSH access, ports if non-default,
data dirs ]

Run ALL of these on the monitoring host in a single command (wrap in
`ssh [ SSH COMMAND ]` if remote):

```bash
echo "=== PROMETHEUS ===" && curl -sf localhost:9090/-/healthy && echo " OK" || echo " FAIL"
echo "=== LOKI ===" && curl -sf localhost:3100/ready && echo " OK" || echo " FAIL"
echo "=== GRAFANA ===" && curl -sf localhost:3000/api/health && echo "" || echo " FAIL"
echo "=== CADVISOR ===" && docker ps --filter name=cadvisor --format "{{.Status}}" || echo "NOT RUNNING"
echo "=== PROMTAIL ===" && systemctl is-active promtail
echo "=== PROMETHEUS TARGETS ===" && curl -s localhost:9090/api/v1/targets | python3 -c "import json,sys; d=json.load(sys.stdin); [print(f\"  {t['labels']['job']}: {t['health']}\") for t in d['data']['activeTargets']]" 2>/dev/null || echo "  Cannot fetch targets"
echo "=== LOKI LOG INGESTION ===" && curl -s localhost:3100/loki/api/v1/label/container_name/values | python3 -c "import json,sys; d=json.load(sys.stdin); print(f\"  Containers indexed: {len(d.get('data',[]))}\")" 2>/dev/null || echo "  Cannot query labels"
echo "=== DISK ===" && du -sh [ PROMETHEUS DATA DIR ] [ LOKI DATA DIR ] /var/lib/grafana/ 2>/dev/null
```

Adjust ports to your install ([ ADAPT: Grafana port varies; Loki data dir
may not be the default ]).

Present results as a clean status table:

| Service | Status |
|---------|--------|
| Prometheus (:9090) | OK/FAIL |
| Loki (:3100) | OK/FAIL |
| Grafana (:3000) | OK/FAIL |
| cAdvisor | running/stopped |
| Promtail | active/inactive |

Also show Prometheus scrape targets and monitoring data disk usage.
