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

Unless a step explicitly says otherwise, assume commands are run on the target node being monitored.

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

## Standard Remote Docker Log Onboarding Workflow

This workflow applies when onboarding Docker container logs from a remote Linux node.

Example target node:

```text
mbd01
```

Central logging destination:

```text
mon01 → Loki :3100
```

### Stage 1 — Identify the Target Node

Run from: **admin workstation or documentation notes**

Record the following before making changes:

| Item               | Example                                    |
| ------------------ | ------------------------------------------ |
| Hostname           | `mbd01`                                    |
| Role               | `media-backend`                            |
| Site               | `home`                                     |
| Environment        | `homelab`                                  |
| Log source type    | Docker containers                          |
| Loki endpoint      | `http://<LOKI_HOST>:3100/loki/api/v1/push` |
| Alloy metrics port | `12345/tcp`                                |

### Stage 2 — Install Alloy on the Target Node

Run from: **target node**

Create the Alloy deployment directory:

```bash
sudo mkdir -p /opt/docker/alloy
sudo chown -R administrator:administrator /opt/docker/alloy
cd /opt/docker/alloy
```

Create:

```text
/opt/docker/alloy/docker-compose.yml
/opt/docker/alloy/config.alloy
```

Risk: **low risk**. Creating the Alloy directory does not modify existing services.

### Stage 3 — Configure Docker Log Collection

Run from: **target node**

Alloy must be able to read Docker container metadata and logs through the Docker socket.

The Compose file should include:

```yaml
volumes:
  - ./config.alloy:/etc/alloy/config.alloy:ro
  - /var/run/docker.sock:/var/run/docker.sock:ro
```

Validate the socket exists on the target node:

```bash
ls -la /var/run/docker.sock
```

### Stage 4 — Configure Alloy to Push to Loki

Run from: **target node**

Example `config.alloy`:

```hcl
discovery.docker "local" {
  host = "unix:///var/run/docker.sock"
}

loki.source.docker "local" {
  host       = "unix:///var/run/docker.sock"
  targets    = discovery.docker.local.targets
  forward_to = [loki.write.<MONITORING_NODE_HOST>.receiver]

  labels = {
    job  = "docker",
    host = "<TARGET_HOSTNAME>",
  }
}

loki.write "<MONITORING_NODE_HOST>" {
  endpoint {
    url = "http://<LOKI_HOST>:3100/loki/api/v1/push"
  }
}
```

Replace:

```text
<MONITORING_NODE_HOST>
<TARGET_HOSTNAME>
<LOKI_HOST>
```

with the real runtime values on the target node.

### Stage 5 — Start Alloy

Run from: **target node**

```bash
cd /opt/docker/alloy
docker compose up -d
```

Risk: **medium risk**. This starts or recreates the Alloy container. It should not affect existing application containers, but it does modify live log collection behavior.

Validate Alloy:

```bash
docker compose ps
curl http://localhost:12345/-/ready
```

Expected result:

```text
Alloy is ready.
```

### Stage 6 — Confirm the Target Node Can Reach Loki

Run from: **target node**

```bash
curl http://<LOKI_HOST>:3100/ready
```

Expected result:

```text
ready
```

If this fails, check VLAN rules, firewall rules, Loki port exposure, and routing between the target node and `mon01`.

### Stage 7 — Confirm Loki Received Logs

Run from: **monitor01**

```bash
curl -s http://localhost:3100/loki/api/v1/label/host/values | python3 -m json.tool
```

Expected result includes the target host:

```text
mbd01
```

If the host does not appear, generate a long-running test container on the target node and check again.

### Stage 8 — Validate in Grafana

Run from: **Grafana UI**

Open:

```text
Explore → Loki
```

Query:

```logql
{host="<TARGET_HOSTNAME>"}
```

Example:

```logql
{host="mbd01"}
```

Then test error filtering:

```logql
{host="<TARGET_HOSTNAME>"} |~ "(?i)error|failed|denied|panic|fatal|exception"
```

### Stage 9 — Add Alloy to Prometheus Monitoring

Run from: **documentation01**

Add the target node’s Alloy endpoint to the private runtime target file:

```text
docker/monitoring/prometheus/targets/alloy.yml
```

Example:

```yaml
- targets:
    - "<TARGET_IP>:12345"
  labels:
    environment: "homelab"
    site: "home"
    host: "<TARGET_HOSTNAME>"
    role: "log-collector"
    component: "alloy"
```

Deploy the monitoring config to `mon01` using the monitoring deployment script.

### Stage 10 — Commit Sanitized Documentation

Run from: **doc01**

Commit only public-safe examples and documentation.

Do not commit:

```text
real target files
real internal IP inventories
secrets
.env files
webhook URLs
```

Commit examples such as:

```text
alloy.example.yml
config.alloy.example
alloy-onboarding.md
```

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

- [ ] Hostname documented
- [ ] Service identified
- [ ] VLAN identified
- [ ] Logging method selected

### Alloy Configuration

- [ ] Required mounts added
- [ ] Discovery block configured
- [ ] Labels standardized
- [ ] Loki forwarding configured

### Validation

- [ ] Alloy restarted
- [ ] Alloy logs checked
- [ ] Loki health verified
- [ ] Grafana datasource working
- [ ] Logs visible in Grafana
- [ ] Labels validated
- [ ] Queries tested

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
