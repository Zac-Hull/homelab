# Loki Setup and Log Aggregation

## Overview

This document describes the deployment and configuration of Grafana Loki within the homelab observability platform.

Loki is used for centralized log aggregation and integration with Grafana.

The goal is to:
- centralize infrastructure logs
- simplify troubleshooting
- improve operational visibility
- support future incident investigation workflows

---

## Objectives

- Aggregate logs centrally
- Store infrastructure and container logs
- Support Grafana log visualization
- Reduce distributed log troubleshooting
- Build searchable operational history

---

## Architecture

```text
Infrastructure Logs
        ↓
      Alloy
        ↓
       Loki
        ↓
     Grafana
```

---

## Deployment Method

Loki is deployed using Docker Compose.

Deployment location:
```text
/opt/docker/stacks/loki
```

---

## Directory Structure
```text
/opt/docker/stacks/loki/
├── compose.yml
├── loki-config.yml
├── data/
└── README.md
```

---

## Docker Compose Configuration

Example:
```yaml
services:
  loki:
    image: grafana/loki:latest

    container_name: loki

    restart: unless-stopped

    ports:
      - "3100:3100"

    volumes:
      - ./loki-config.yml:/etc/loki/local-config.yaml
      - ./data:/loki
```

---

## Deploy Loki

Start stack:
```bash
docker compose up -d
```

Validate:
```bash
docker compose ps
```

Check logs:
```bash
docker logs loki
```

---

## Loki Configuration

Main configuration file:
```text
loki-config.yml
```

Example minimal config:
```yaml
auth_enabled: false

server:
  http_listen_port: 3100

common:
  path_prefix: /loki

schema_config:
  configs:
    - from: 2024-01-01
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

storage_config:
  filesystem:
    directory: /loki/chunks
```

---

## Validation

Validate API:
```bash
curl http://localhost:3100/ready
```

Expected:
```bash
ready
```

---

## Grafana Integration

Loki is added as a Grafana datasource.

Example URL:
```text
http://loki:3100
```

Validation:

- datasource connected
- log labels visible
- log streams queryable

---

## Example Queries

System logs:
```logql
{job="system"}
```

Docker logs:
```logql
{job="docker"}
```

Container logs:
```logql
{container_name="alloy"}
```

---

## Troubleshooting
### Loki Not Ready

Check:
```bash
docker logs loki
```

Common issues:

- bad config syntax
- missing mounted directories
- permissions problems

### No Labels Visible in Grafana

Verify:

- Alloy forwarding working
- Loki receiving logs
- labels correctly assigned

### Logs Not Queryable

Check:

- datasource configuration
- Loki API health
- Grafana Explore view
- log retention timing

---

## Security Considerations
- Keep Loki internal-only
- Avoid public ingestion endpoints
- Limit dashboard access
- Monitor log retention growth

---

## Lessons Learned
- Log aggregation improves troubleshooting speed
- Centralized logs simplify incident investigation
- Label consistency matters significantly
- Logging pipelines require end-to-end validation

---

## Future Improvements
- Add retention policies
- Add multi-node log shipping
- Add authentication
- Add long-term storage
- Add alerting from log patterns

---

## Related Documentation
- Alloy Setup
- Grafana Setup
- Observability Platform