---
name: grafana
description: Grafana dashboard management — health, data sources, dashboards, admin, via the HTTP API.
user-invocable: true
version: 1.0.0
---

Grafana dashboard management on the monitoring host.

[ MONITORING STACK DETAILS HERE — Grafana URL, host/SSH access, port,
auth (GRAFANA_USER/GRAFANA_PASS source), dashboards in use ]

**Server:** [ SSH COMMAND / HOST — or run locally ]
**Port:** [ GRAFANA PORT, e.g. 3000 ]
**Config:** `/etc/grafana/grafana.ini`
**Service:** `systemctl {start|stop|restart|status} grafana-server`
**Access:** [ GRAFANA URL ]

Commands below assume Grafana on `localhost:3000` on the monitoring host —
adjust port/host, and prefix with `ssh [ SSH HOST ]` if remote.

## Common Operations

```bash
# Check health
curl -s localhost:3000/api/health

# List data sources
curl -s http://$GRAFANA_USER:$GRAFANA_PASS@localhost:3000/api/datasources | python3 -m json.tool

# List dashboards
curl -s http://$GRAFANA_USER:$GRAFANA_PASS@localhost:3000/api/search | python3 -m json.tool

# Add Prometheus data source
curl -s -X POST -H 'Content-Type: application/json' -d '{"name":"Prometheus","type":"prometheus","url":"http://localhost:9090","access":"proxy","isDefault":true}' http://$GRAFANA_USER:$GRAFANA_PASS@localhost:3000/api/datasources

# Add Loki data source
curl -s -X POST -H 'Content-Type: application/json' -d '{"name":"Loki","type":"loki","url":"http://localhost:3100","access":"proxy"}' http://$GRAFANA_USER:$GRAFANA_PASS@localhost:3000/api/datasources
```

## Useful community dashboards (grafana.com IDs)

| Dashboard | ID | Purpose |
|-----------|-----|---------|
| Docker Container Dashboard | 15331 | Container overview, CPU, memory, network |
| Container Resources | 14678 | Detailed resource usage per container |
| NVIDIA DCGM Exporter | 12239 | GPU metrics (if GPU hosts run) |

[ ADAPT: replace/extend with the dashboards actually installed ]

## Import Dashboard via API

```bash
# Download dashboard JSON from grafana.com then import
curl -s https://grafana.com/api/dashboards/15331/revisions/latest/download | curl -s -X POST -H 'Content-Type: application/json' -d @- http://$GRAFANA_USER:$GRAFANA_PASS@localhost:3000/api/dashboards/import
```

## Change Admin Password

```bash
curl -s -X PUT -H 'Content-Type: application/json' -d '{"oldPassword":"OLD_PASSWORD","newPassword":"NEW_PASSWORD"}' http://$GRAFANA_USER:$GRAFANA_PASS@localhost:3000/api/user/password
```

If $ARGUMENTS provided, treat as a Grafana operation or question.
