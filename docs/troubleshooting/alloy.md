# Alloy Troubleshooting Guide
## Overview

This document provides troubleshooting procedures for Grafana Alloy within the homelab observability stack.

Alloy is responsible for collecting logs and forwarding them to Loki for visualization in Grafana. When logging breaks, troubleshooting should follow the full pipeline:
```text
Log Source → Alloy → Loki → Grafana
```

The goal is to isolate whether the issue is caused by:

- the original log source
- Alloy configuration
- Docker permissions
- Loki ingestion
- Grafana datasource or query configuration

---

## Service Location

Alloy is deployed as a Docker Compose service.

Common paths:
```bash
/opt/docker/monitoring/alloy/
```

Public repo path:
```bash
docker/monitoring/alloy/
```

Expected files:
```text
alloy/
├── docker-compose.yml
├── config.alloy
├── README.md
└── .env
```

---

## Quick Health Checks
### Check Container Status
```bash
docker compose ps
```

Expected:
```bash
alloy    running
```

### Check Alloy Logs
```bash
docker logs alloy
```

or from the stack directory:
```bash
docker compose logs -f alloy
```

Look for:

- configuration errors
- Loki connection failures
- permission errors
- file discovery issues
- Docker socket errors

### Check Alloy UI

If enabled:
```bash
http://<alloy-host>:12345
```

Use this to inspect:

- loaded components
- pipeline health
- targets
- runtime status

---

## Common Issues
### 1. Alloy Container Will Not Start
#### Symptoms
- Container exits immediately
- `docker compose ps` shows `Exited`
- Logs show configuration parsing errors

#### Check
```bash
docker logs alloy
```

#### Common Causes
- invalid `config.alloy` syntax
- incorrect volume mount
- missing config file
- typo in component names
- invalid Loki endpoint

#### Fix

Validate the config file path in `docker-compose.yml`:
```yaml
volumes:
  - ./config.alloy:/etc/alloy/config.alloy
```

Confirm the file exists:
```bash
ls -la
```

#### Restart after correction:
```bash
docker compose down
docker compose up -d
```

### 2. No Logs Appearing in Grafana
#### Symptoms
- Alloy container is running
- Loki datasource is healthy
- Grafana Explore returns no results

#### Troubleshooting Path

Check Alloy logs:
```bash
docker compose logs -f alloy
```

Check Loki health:
```bash
curl http://<loki-host>:3100/ready
```

Check Grafana Explore with a broad query:
```logql
{job=~".+"}
```

#### Common Causes
- Alloy is not finding log files
- Alloy is not forwarding to Loki
- labels are different than expected
- Grafana query is too narrow
- Loki datasource is pointed to the wrong URL

### 3. Docker Logs Are Missing
#### Symptoms
- System logs appear
- Docker container logs do not appear
- Alloy logs mention Docker socket problems

#### Check Docker Socket Mount

In `docker-compose.yml`:
```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

Validate on host:
```bash
ls -la /var/run/docker.sock
```

#### Common Causes
- Docker socket not mounted
- Alloy cannot access Docker socket
- Docker discovery not configured
- container labels differ from expected queries

#### Fix

Confirm Alloy has access to the Docker socket and that the Docker discovery block exists in `config.alloy`.

Example:
```hcl
discovery.docker "containers" {
  host = "unix:///var/run/docker.sock"
}
```

### 4. System Logs Are Missing
#### Symptoms
- Docker logs appear
- Linux system logs do not appear

#### Check Volume Mount

In `docker-compose.yml`:
```yaml
volumes:
  - /var/log:/var/log:ro
```

Validate on host:
```bash
ls -la /var/log
```

#### Common Causes

- `/var/log` not mounted
- wrong path in `config.alloy`
- permissions issue
- log file pattern does not match

#### Fix

Confirm `config.alloy` includes the correct path:
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

### 5. Loki Connection Errors
#### Symptoms
- Alloy logs show failed pushes
- Grafana shows no logs
- Loki is unreachable from Alloy

#### Check Loki Health

From the Alloy host:
```bash
curl http://<loki-host>:3100/ready
```

Expected:
```text
ready
```

#### Common Causes
- Loki container is down
- incorrect Loki URL
- Docker network issue
- firewall rule blocking port `3100`
- hostname does not resolve

#### Fix

Check the Loki endpoint in `config.alloy`:
```hcl
loki.write "default" {
  endpoint {
    url = "http://<loki-host>:3100/loki/api/v1/push"
  }
}
```

Restart Alloy after changing the endpoint:
```bash
docker compose restart alloy
```

### 6. Labels Do Not Match Grafana Queries
#### Symptoms
- Logs exist in Grafana
- Expected queries return nothing
- Broad queries work but specific queries fail

**Example Broad Query**
```logql
{job=~".+"}
```

#### Common Causes
- incorrect label names
- missing job label
- container labels differ from expected names
- hostname labels not applied

#### Fix

Use Grafana Explore to inspect available labels.

Then update queries or update Alloy labels.

Example labels:

job      = "system"
hostname = "monitor01"
service  = "alloy"

### 7. Alloy Starts but Reloads Incorrectly
#### Symptoms
- config changes do not appear active
- old targets remain
- expected logs are missing after config edit

#### Fix

Restart Alloy:
```bash
docker compose restart alloy
```

If needed:
```bash
docker compose down
docker compose up -d
```

Check logs immediately:
```bash
docker compose logs -f alloy
```

---

## End-to-End Validation Workflow

Use this order when troubleshooting.

1. Confirm Log Source Exists
```bash
ls -la /var/log
```

For Docker logs:
```bash
docker ps
```

2. Confirm Alloy Is Running
```bash
docker compose ps
```

3. Confirm Alloy Can Read Sources
```bash
docker logs alloy
```

Look for file discovery or Docker discovery errors.

4. Confirm Loki Is Healthy
```bash
curl http://<loki-host>:3100/ready
```

5. Confirm Grafana Datasource

In Grafana:

Connections → Data Sources → Loki → Save & Test

6. Confirm Logs Are Queryable

In Grafana Explore:
```logql
{job=~".+"}
```

Then narrow down:
```logql
{job="system"}
{container_name="alloy"}
```

---

## Useful Commands
### Restart Alloy
```bash
docker compose restart alloy
```

### View Logs
```bash
docker compose logs -f alloy
```

### Recreate Container
```bash
docker compose down
docker compose up -d
```

### Check Docker Socket
```bash
ls -la /var/run/docker.sock
```

### Check Mounted Logs
```bash
ls -la /var/log
```

---

## Security Notes
- Do not expose Alloy publicly
- Keep Alloy UI restricted to internal networks
- Treat Docker socket access as sensitive
- Avoid collecting secrets into logs when possible
- Restrict Loki ingestion to trusted internal sources

---

## Lessons Learned
- Logging failures should be traced through the entire pipeline
- Label consistency is critical for Grafana queries
- Docker socket access must be intentional and protected
- Alloy config syntax errors usually appear clearly in container logs
- Broad LogQL queries are useful before narrowing filters

---

## Related Documentation
- Alloy Setup
- Loki Setup
- Grafana Setup
- Log Ingestion Workflow