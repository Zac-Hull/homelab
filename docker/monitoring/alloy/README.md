# Grafana Alloy
## Overview

This directory contains the Docker Compose configuration and Alloy pipeline configuration for the homelab logging stack.

Grafana Alloy is used to collect logs from the local host and forward them to Loki for visualization in Grafana.

Current pipeline:
```text
Host Logs / Docker Logs
          ↓
        Alloy
          ↓
        Loki
          ↓
       Grafana
```

---

## Purpose

Alloy is deployed to provide centralized log forwarding for the homelab observability platform.

It is responsible for:

- collecting Linux host logs
- collecting Docker container logs
- applying labels to log streams
- forwarding logs to Loki
- supporting log exploration in Grafana

---

## Directory Structure
```text
alloy/
├── docker-compose.yml
├── config.alloy
├── README.md
└── .env
```

---

## Files
| File | Purpose |
|---|---|
| `docker-compose.yml` | Defines the Alloy container |
| `config.alloy` | Defines log collection and forwarding pipelines |
| `.env` | Local environment variables; not committed if sensitive |
| `README.md` | Service documentation |

---

## Deployment Location

Runtime deployment path:
```bash
/opt/docker/monitoring/alloy/
```

Repository path:
```bash
docker/monitoring/alloy/
```

---

## Requirements
- Docker installed
- Docker Compose plugin installed
- Loki reachable from Alloy
- Grafana configured with Loki datasource
- Required log paths mounted into Alloy
- Docker socket mounted if collecting container logs

---

## Docker Compose

Alloy is deployed using Docker Compose.

Start service:
```bash
docker compose up -d
```

Check status:
```bash
docker compose ps
```

View logs:
```bash
docker compose logs -f alloy
```

Restart service:
```bash
docker compose restart alloy
```

---

## Expected Ports
| Port | Purpose |
|---|---|
| 12345/tcp | Alloy UI/API, if enabled |

The Alloy UI should remain internal-only.

---

## Log Sources

Current or planned log sources:

| Source | Path / Method | Purpose |
|---|---|---|
| Linux system logs | `/var/log/*.log` | Host-level logs |
| Docker logs | Docker socket / container discovery | Container logs |
| Future reverse proxy logs | service-specific path | HTTP access and error logs |
|Future application logs | service-specific path | Application troubleshooting |

---

## Loki Destination

Alloy forwards logs to Loki using the Loki push API.

Expected endpoint format:
```text
http://<loki-host>:3100/loki/api/v1/push
```

---

## Grafana Usage

Logs are queried in Grafana through the Loki datasource.

Common Explore queries:
```logql
{job=~".+"}
{job="system"}
{container_name="alloy"}
```

Search for errors:
```logql
{job=~".+"} |= "error"
```

---

## Validation

After deployment, validate the full pipeline.

**1. Alloy Running**
```bash
docker compose ps
```

**2. Alloy Logs Clean**
```bash
docker compose logs -f alloy
```

**3. Loki Ready**
```bash
curl http://<loki-host>:3100/ready
```

Expected:
```text
ready
```

**4. Grafana Query Works**

In Grafana Explore, select the Loki datasource and run:
```logql
{job=~".+"}
```

---

## Troubleshooting

If logs do not appear in Grafana, check in this order:

1. Alloy container status
2. Alloy container logs
3. Mounted log paths
4. Docker socket access
5. Loki health
6. Grafana Loki datasource
7. LogQL labels and query filters

See:
```text
docs/troubleshooting/alloy.md
```

---

## Security Notes
- Do not expose Alloy publicly
- Restrict Alloy UI to internal networks
- Treat Docker socket access as sensitive
- Avoid committing secrets in `.env`
- Keep Loki ingestion internal-only

---

## Operational Notes
- Restart Alloy after editing `config.alloy`
- Use broad LogQL queries first, then narrow by label
- Keep labels consistent across log sources
- Document new log sources as they are added
- Validate logs in Grafana after every config change

---

## Related Documentation
- `docs/services/alloy.md`
- `docs/services/loki.md`
- `docs/services/grafana.md`
- `docs/services/log-ingestion-workflow.md`
- `docs/troubleshooting/alloy.md`