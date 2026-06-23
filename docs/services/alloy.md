# Grafana Alloy Setup and Log Collection

## Overview

This document describes the deployment and configuration of Grafana Alloy within the homelab observability platform.

Grafana Alloy is used as a telemetry collection agent responsible for:

- log collection
- log forwarding
- metrics forwarding
- future telemetry pipelines
- centralized observability integration

Within the current environment, Alloy primarily forwards logs to Loki for visualization in Grafana.

---

## Objectives

- Centralize infrastructure logs
- Standardize log forwarding
- Simplify telemetry collection
- Build a scalable observability pipeline
- Support future metrics and tracing integrations

---

## Architecture

```text
Linux Hosts / Docker Containers
            ↓
         Alloy
            ↓
          Loki
            ↓
         Grafana
```

---

## Deployment Method

Alloy is deployed using Docker Compose.

Deployment location:
```text
/opt/docker/stacks/alloy
```

---

## Directory Structure
```text
/opt/docker/stacks/alloy/
├── compose.yml
├── config.alloy
└── README.md
```

---

## Docker Compose Configuration

Example Compose file:
```yaml
services:
  alloy:
    image: grafana/alloy:latest

    container_name: alloy

    restart: unless-stopped

    ports:
      - "12345:12345"

    volumes:
      - ./config.alloy:/etc/alloy/config.alloy
      - /var/log:/var/log:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock
```

---

## Deploy Alloy

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
docker logs alloy
```

## Alloy Configuration

Primary configuration file:
```text
config.alloy
```

---

## Example Loki Pipeline
```hcl
local.file_match "system_logs" {
  path_targets = [
    {
      __path__ = "/var/log/*.log",
      job      = "system"
    }
  ]
}

loki.source.file "system_logs" {
  targets    = local.file_match.system_logs.targets
  forward_to = [loki.write.default.receiver]
}

loki.write "default" {
  endpoint {
    url = "http://loki:3100/loki/api/v1/push"
  }
}
```

---

## Docker Log Collection

Example Docker discovery:
```hcl
discovery.docker "containers" {
  host = "unix:///var/run/docker.sock"
}
```

Container log pipeline:
```hcl
loki.source.docker "containers" {
  host       = "unix:///var/run/docker.sock"
  targets    = discovery.docker.containers.targets
  forward_to = [loki.write.default.receiver]
}
```

---

## Validation

Check Alloy logs:
```bash
docker logs alloy
```

Verify Loki receives logs.

Verify Grafana displays streams.

---

## Troubleshooting
### No Logs Appearing

Check:

- Alloy container running
- Loki reachable
- file paths correct
- Docker socket mounted
- container permissions

### Docker Logs Missing

Verify:
```bash
ls /var/lib/docker/containers
```

Confirm Docker socket mounted:
```bash
ls /var/run/docker.sock
```

### Loki Connection Errors

Check:

- Loki container status
- Loki endpoint URL
- Docker network connectivity

---

## Security Considerations
- Docker socket exposure should remain internal-only
- Limit Alloy access to required log paths
- Restrict external Alloy access
- Avoid exposing Loki ingestion publicly

---

## Lessons Learned
- Centralized logging simplifies troubleshooting
- Containerized logging pipelines require careful permissions management
- Docker socket access should be intentionally controlled
- Observability tooling benefits from modular pipelines

---

## Future Improvements
- Add metrics forwarding
- Add tracing support
- Add remote log shipping
- Add alerting from logs
- Add log retention policies
- Add log filtering pipelines

---

## Related Documentation
- Loki Setup
- Grafana Setup
- Observability Platform