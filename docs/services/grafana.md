# Grafana Setup and Visualization Platform

## Overview

Grafana provides centralized visualization for metrics collected throughout the homelab environment.

Grafana is used to:
- visualize infrastructure metrics
- create operational dashboards
- identify trends
- support troubleshooting
- improve visibility across services

---

## Objectives

- Centralize dashboarding
- Improve infrastructure visibility
- Create reusable monitoring dashboards
- Visualize Prometheus metrics
- Support future log aggregation

---

## Deployment Method

Grafana is deployed using Docker Compose.

Deployment location:

```text
/opt/docker/stacks/grafana
```

### Directory Structure
```text
/opt/docker/stacks/grafana/
├── compose.yml
├── data/
└── README.md
```

### Example Compose File
```yaml
services:
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped

    ports:
      - "3000:3000"

    volumes:
      - ./data:/var/lib/grafana
```

### Deploy Grafana

Start stack:
```bash
docker compose up -d
```

Validate:
```bash
docker compose ps
```

Access UI:
```text
http://<server-ip>:3000
```

### Initial Login

Default credentials:
```text
Username: admin
Password: admin
```
**Password should be changed immediately after initial login.**

## Configure Prometheus Data Source
### Add Data Source

Navigate to:
```text
Connections → Data Sources → Add data source
```

Select:
```text
Prometheus
Prometheus Connection
```

Example URL:
```text
http://prometheus:9090
```

Or:
```text
http://<prometheus-server-ip>:9090
```

Save and test connection.

## Dashboard Organization

Recommended folders:

>Infrastructure
>Containers
>Networking
>Storage
>Services
>Security

## Adding Future Monitoring Integrations
### Node Exporter Dashboards

Purpose:

- CPU metrics
- memory usage
- disk metrics
- network throughput

Popular dashboard IDs:

- 1860
- 11074

### Docker / Container Dashboards

Metrics sources:

- cAdvisor
- Docker daemon metrics

Potential dashboards:

- container resource utilization
- restart tracking
- container health

### Proxmox Monitoring

Future integrations:

- Proxmox exporter
- API integrations
- cluster metrics

### NAS Monitoring

Potential metrics:

- storage usage
- disk health
- SMB availability
- NFS metrics

### Loki Log Integration (Planned)

Future logging integration:
```text
Loki → Promtail → Grafana
```

Goals:

- centralized logs
- searchable infrastructure logs
- incident investigation support

## Dashboard Design Philosophy

Dashboards should prioritize:

- readability
- actionable information
- operational usefulness
- reduced clutter
- quick issue identification

## Validation

Validate:

- Prometheus datasource connected
- dashboards loading metrics
- graphs updating correctly
- exporter targets healthy

## Troubleshooting
### No Data in Dashboard

Check:

- Prometheus datasource
- exporter health
- query syntax
- scrape target status

### Dashboard Not Updating

Verify:

- refresh interval
- Prometheus target health
- time synchronization

### Login Issues

Reset admin password if needed:
```bash
docker exec -it grafana grafana-cli admin reset-admin-password <new-password>
```

## Security Considerations
- Change default credentials immediately
- Restrict external dashboard exposure
- Use reverse proxy authentication where possible
- Limit admin accounts
- Restrict anonymous access

## Future Improvements
- SSO integration
- Alerting dashboards
- Mobile dashboards
- Infrastructure maps
- Service dependency visualization
- SLA reporting

## Related Documentation
- Prometheus Setup
- Observability Platform
- Docker Compose Setup