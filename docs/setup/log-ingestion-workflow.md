# Log Ingestion Workflow: Alloy → Loki → Grafana

## Overview

This document describes the end-to-end workflow for centralized log ingestion within the homelab observability platform.

The current logging pipeline uses:

- Grafana Alloy for log collection
- Loki for log aggregation
- Grafana for visualization and querying

The goal is to provide searchable infrastructure and container logs from a centralized interface.

---

## High-Level Workflow

```text
System Logs / Docker Logs
            ↓
          Alloy
            ↓
        Loki API
            ↓
        Log Storage
            ↓
         Grafana
            ↓
     Search / Analysis
```

---

## Log Sources

Current log sources include:

| **Source** | **Example** |
|---|---|
| Linux system logs | /var/log/*.log |
| Docker container logs | /var/lib/docker/containers |
| Service logs | application-specific logs |
| Future reverse proxy logs | Traefik / NGINX |

---

## Step 1 — Log Generation

Logs originate from:

- Linux hosts
- Docker containers
- infrastructure services
- future applications

Examples:

- authentication logs
- container startup logs
- network service logs
- reverse proxy access logs

## Step 2 — Alloy Collection

Alloy discovers and reads logs from:

- filesystem paths
- Docker containers
- future telemetry sources

Example file pipeline:
```hcl
local.file_match "system_logs" {
  path_targets = [
    {
      __path__ = "/var/log/*.log",
      job      = "system"
    }
  ]
}
```

Example Docker pipeline:
```hcl
loki.source.docker "containers" {
  host = "unix:///var/run/docker.sock"
}
```

## Step 3 — Alloy Forwards Logs to Loki

Logs are sent to Loki through:
```hcl
loki.write "default" {
  endpoint {
    url = "http://loki:3100/loki/api/v1/push"
  }
}
```

## Step 4 — Loki Stores Logs

Loki:

- indexes labels
- stores log streams
- exposes query APIs

Logs are organized by labels such as:

- job
- hostname
- container
- service

## Step 5 — Grafana Queries Loki

Grafana uses Loki as a datasource.

Common workflow:

- Open Grafana
- Navigate to Explore
- Select Loki datasource
- Query logs using LogQL

### Example Queries

All Docker logs:
```logql
{job="docker"}
```

Specific container:
```logql
{container_name="alloy"}
```

System logs:
```logql
{job="system"}
```

Search for errors:
```logql
{job="docker"} |= "error"
```

---

## Grafana Visualization

Grafana provides:

- live log streaming
- historical search
- label filtering
- correlation with metrics dashboards

Potential future dashboards:

- authentication failures
- reverse proxy errors
- container restart tracking
- service health timelines

---

## Validation Workflow
### Validate Alloy
```bash
docker logs alloy
```

### Validate Loki
```bash
curl http://localhost:3100/ready
```

### Validate Grafana Datasource

In Grafana:

- open Connections → Data Sources
- verify Loki datasource healthy

### Validate Queries

Run:
```logql
{job="docker"}
```

Expected:

- visible log streams
- active labels
- recent timestamps

---

## Troubleshooting Workflow
### No Logs in Grafana

Check in order:

- Alloy container status
- Alloy logs
- Loki health
- Grafana datasource
- Loki labels
- query syntax

### Missing Docker Logs

Verify:

- Docker socket mounted
- Alloy permissions correct
- container discovery enabled

### Missing Labels

Verify:

- labels assigned in Alloy config
- Loki ingestion successful

### Logs Delayed

Potential causes:

- container restart
- network interruption
- filesystem delays
- ingestion bottlenecks

---

## Security Considerations

- Logging infrastructure should remain internal-only
- Docker socket exposure should be minimized
- Sensitive logs should not be publicly accessible
- Retention policies should be monitored
- Authentication logs should be protected carefully

---

## Lessons Learned

- Centralized logging significantly improves troubleshooting
- Metrics and logs complement each other
- Label consistency is critical
- End-to-end validation is required across the entire pipeline
- Observability platforms become increasingly valuable as infrastructure scales

---

## Future Improvements

- Add alerting from logs
- Add log retention tuning
- Add authentication
- Add distributed log collection
- Add trace correlation
- Add incident dashboarding

---

## Related Documentation

- Alloy Setup
- Loki Setup
- Grafana Setup
- Prometheus Setup
- Observability Platform