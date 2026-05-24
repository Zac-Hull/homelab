# Prometheus Setup and Monitoring Integration

## Overview

This document describes the deployment and configuration of Prometheus within the homelab observability platform.

Prometheus is responsible for:
- metrics collection
- time-series storage
- service scraping
- monitoring integration

---

## Objectives

- Centralize infrastructure metrics
- Enable long-term metric collection
- Provide scalable monitoring integration
- Support Grafana dashboards
- Build future alerting capabilities

---

## Deployment Method

Prometheus is deployed using Docker Compose.

Deployment location:

```text
/opt/docker/stacks/prometheus
```

### Directory Structure
```text
/opt/docker/stacks/prometheus/
├── compose.yml
├── prometheus.yml
├── data/
└── README.md
```

### Example Compose File
```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped

    ports:
      - "9090:9090"

    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./data:/prometheus
```

## Deploy Prometheus

Start the stack:
```bash
docker compose up -d
```

Validate:
```bash
docker compose ps
```

Access dashboard:
```text
http://<server-ip>:9090
```

## Prometheus Configuration

Primary config file:
```text
prometheus.yml
```

### Example Scrape Configuration
```yaml
global:
  scrape_interval: 15s

scrape_configs:

  - job_name: prometheus
    static_configs:
      - targets:
          - localhost:9090
```

## Adding Future Monitoring Targets
### Linux VM Monitoring (Node Exporter)

Example scrape config:
```yaml
- job_name: node-exporter
  static_configs:
    - targets:
        - 10.0.2.10:9100
        - 10.0.2.20:9100
```

### Docker Monitoring (cAdvisor)

Example:
```yaml
- job_name: cadvisor
  static_configs:
    - targets:
        - 10.0.2.10:8080
```

### SMB/NAS Monitoring

Future integrations may include:

- SNMP exporters
- NAS APIs
- storage exporters

### Reverse Proxy Monitoring

Potential metrics:

- request counts
- response times
- error rates
- TLS certificate status

## Validation

Validate targets:
```text
Status → Targets
```

Healthy targets should show:
```text
UP
```

## Troubleshooting
### Target Down

Check:

- firewall rules
- VLAN routing
- exporter container status
- correct target IP/port

## Configuration Errors

Validate config:
```bash
docker logs prometheus
```

## No Metrics Appearing

Verify:

- exporter running
- scrape target reachable
- correct port exposed

## Security Considerations
- Restrict Prometheus UI exposure
- Avoid exposing exporters externally
- Monitor only required ports
- Limit cross-VLAN access where possible

## Future Improvements
- Alertmanager integration
- Long-term storage
- Federation
- HA monitoring architecture
- Service discovery automation

## Related Documentation
- Grafana Setup
- Observability Platform