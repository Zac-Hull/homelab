# Alloy Log Collection Onboarding Guide
## Overview

This document defines the standard onboarding process for integrating new systems, services, and containers into the centralized logging pipeline using Grafana Alloy.

The current observability pipeline uses:
```text
Log Source → Alloy → Loki → Grafana
```

This onboarding workflow standardizes:

- log discovery
- label conventions
- Docker integration
- filesystem log collection
- validation procedures
- Grafana querying

The goal is to make future log onboarding repeatable, predictable, and operationally consistent.

---

## Objectives
- Standardize centralized logging onboarding
- Reduce logging configuration drift
- Ensure consistent labels across services
- Simplify Grafana log querying
- Improve troubleshooting visibility
- Build scalable observability workflows

---

## Current Logging Architecture
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

## Current Environment
| Component | Purpose |
|---|---|
| Alloy | Log collection and forwarding |
| Loki | Centralized log aggregation |
| Grafana | Visualization and querying |
| Docker | Containerized service environment |

---

## Supported Log Sources

Current and planned supported sources:

| Source Type | Example |
|---|---|
| Linux system logs | `/var/log/*.log` |
| Docker container logs | Docker socket discovery |
| Application logs | Custom bind-mounted log paths |
| Reverse proxy logs | Traefik / NGINX |
| Future service logs | Service-specific log files |

---

## Standard Onboarding Workflow

Every new logging target should follow the same workflow.

### Step 1 — Identify the Log Source

Determine:

| Item | Example |
|---|---|
| Hostname | `mediabe01` |
| Service | `jellyfin` |
| Log Type | Docker logs |
| Log Path | `/var/log/*.log` |
| VLAN | `20` |
| Collection Method | Docker discovery |

#### Log Collection Methods
**Docker Discovery**

Recommended for:

- Docker containers
- Compose-based services
- containerized infrastructure

**File Discovery**

Recommended for:

- Linux system logs
- application logs
- services writing directly to files


### Step 2 — Confirm Required Mounts
#### Docker Log Collection

Verify Docker socket mounted:
```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

Validate:
```bash
ls -la /var/run/docker.sock
```

#### Linux System Log Collection

Verify log directory mounted:
```yaml
volumes:
  - /var/log:/var/log:ro
```

Validate:
```bash
ls -la /var/log
```

#### Container Log Files

For custom application logs:
```yaml
volumes:
  - /path/to/logs:/logs:ro
```

### Step 3 — Configure Alloy Pipeline

Primary config:

`config.alloy`

#### Docker Container Onboarding
**Docker Discovery Block**
```hcl
discovery.docker "containers" {
  host = "unix:///var/run/docker.sock"
}
```

**Docker Log Source**
```hcl
loki.source.docker "containers" {
  host       = "unix:///var/run/docker.sock"
  targets    = discovery.docker.containers.targets
  forward_to = [loki.write.default.receiver]
}
```

#### Linux System Log Onboarding
**File Discovery Block**
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

**File Log Source**
```hcl
loki.source.file "system_logs" {
  targets    = local.file_match.system_logs.targets
  forward_to = [loki.write.default.receiver]
}
```

**Application Log Onboarding**

Example custom application logs:
```hcl
local.file_match "app_logs" {
  path_targets = [
    {
      __path__ = "/logs/*.log",
      job      = "application"
      service  = "custom-app"
    }
  ]
}
```

### Step 4 — Apply Label Standards

Consistent labels are critical for Grafana queries.

#### Recommended Labels
| Label | Example |
|---|---|
| job | `docker` |
| hostname | `monitor01` |
| service | `grafana` |
| environment | `homelab` |
| vlan | `20` |

**Example Labels**
```hcl
{
  __path__   = "/var/log/*.log",
  job        = "system",
  hostname   = "monitor01",
  environment = "homelab"
}
```

### Step 5 — Restart Alloy

After configuration changes:
```bash
docker compose restart alloy
```

Validate:
```bash
docker compose ps
```

Step 6 — Validate Alloy Logs

Check Alloy logs:
```bash
docker compose logs -f alloy
```

Look for:

- discovery errors
- permission errors
- Loki connection failures
- config parsing issues

### Step 7 — Validate Loki Health
```bash
curl http://<loki-host>:3100/ready
```

Expected:

`ready`

### Step 8 — Validate in Grafana

Open Grafana Explore.

Select:

- Loki datasource

Start with broad query:
```logql
{job=~".+"}
```

Then narrow:
```logql
{job="system"}
```
```logql
{service="grafana"}
```
```logql
{container_name="alloy"}
```

### Step 9 — Confirm Label Visibility

Verify:

- labels appear correctly
- hostnames consistent
- service names readable
- expected streams visible

---

## Recommended Query Patterns
### Search Errors
```logql
{job=~".+"} |= "error"
```

### Search Warnings
```logql
{job=~".+"} |= "warn"
```

### Specific Host
```logql
{hostname="monitor01"}
```

### Specific Service
```logql
{service="grafana"}
```

---

## Standard Onboarding Checklist
### Infrastructure Information

- [ ]Hostname documented
- [ ]Service identified
- [ ]VLAN identified
- [ ]Logging method selected

### Alloy Configuration

- [ ]Required mounts added
- [ ]Discovery block configured
- [ ]Labels standardized
- [ ]Loki forwarding configured

### Validation

- [ ]Alloy restarted
- [ ]Alloy logs checked
- [ ]Loki health verified
- [ ]Grafana datasource working
- [ ]Logs visible in Grafana
- [ ]Labels validated
- [ ]Queries tested

---

## Troubleshooting
### No Logs Appearing

Check:

- Alloy running
- Loki reachable
- Grafana datasource healthy
- labels correct
- broad queries work

### Docker Logs Missing

Verify:

- Docker socket mounted
- discovery block exists
- container running

### File Logs Missing

Verify:

- correct file path
- permissions correct
- log files exist
- volume mounted

### Labels Incorrect

Check:

- Alloy labels
- Grafana queries
- stream labels in Explore view

### Loki Connection Failure

Verify:
```bash
curl http://<loki-host>:3100/ready
```

Check Alloy logs for push failures.

---

## Security Considerations
- Do not expose Alloy publicly
- Restrict Docker socket access
- Keep Loki internal-only
- Avoid ingesting sensitive secrets
- Limit unnecessary log exposure

---

## Lessons Learned
- Label consistency matters significantly
- Broad queries help isolate ingestion failures
- Docker socket permissions require careful handling
- End-to-end validation prevents false assumptions
- Centralized logs improve troubleshooting dramatically

---

## Future Improvements
- Automated onboarding
- Label standardization policies
- Log retention policies
- Alerting from logs
- Remote log shipping
- Multi-node Alloy deployments
- Reverse proxy access logging

---

## Related Documentation
- Alloy Setup
- Loki Setup
- Log Ingestion Workflow
- Grafana Setup
- Alloy Troubleshooting