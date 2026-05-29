# Homelab Node Onboarding with Node Exporter

## Overview

This document defines the standard process for onboarding Linux homelab nodes into the observability platform using Prometheus Node Exporter.

Node Exporter is used to expose host-level system metrics such as:

- CPU usage
- memory usage
- disk usage
- filesystem metrics
- network throughput
- load average
- system uptime

These metrics are scraped by Prometheus and visualized in Grafana.

---

## Objectives

- Standardize Linux node monitoring
- Make new node onboarding repeatable
- Reduce Prometheus configuration drift
- Support future expansion of monitored systems
- Provide consistent labels for Grafana dashboards

---

## Target Systems

This process applies to Linux-based homelab systems such as:

- `documentation01`
- `mediabe01`
- `docker01`
- `monitor01`
- WireGuard gateway nodes
- future Ubuntu service VMs

---

## Architecture

```text
Linux Node
  └── Node Exporter :9100
        ↓
Prometheus scrape job
        ↓
Prometheus metrics storage
        ↓
Grafana dashboards
```

---

## Standard Port

Node Exporter listens on:
```text
9100/tcp
```

Prometheus must be able to reach each monitored node on this port.

## Node Exporter Installation
### Option 1: Docker Compose Deployment

Recommended for Docker-capable nodes.

Create directory:
```bash
mkdir -p /opt/docker/stacks/node-exporter
cd /opt/docker/stacks/node-exporter
```

Create Compose file:
```bash
nano compose.yml
```

Example:
```yaml
services:
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: unless-stopped
    network_mode: host
    pid: host

    volumes:
      - /:/host:ro,rslave

    command:
      - "--path.rootfs=/host"
```

Start service:
```bash
docker compose up -d
```

Validate:
```bash
docker compose ps
curl http://localhost:9100/metrics
```

### Option 2: Native Systemd Deployment

Recommended for non-Docker nodes or lightweight infrastructure VMs.

Create user:
```bash
sudo useradd --no-create-home --shell /usr/sbin/nologin node_exporter
```

Download the current Node Exporter release from the official Prometheus Node Exporter releases page.

Example flow:
```bash
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v<version>/node_exporter-<version>.linux-amd64.tar.gz
tar xvf node_exporter-<version>.linux-amd64.tar.gz
sudo cp node_exporter-<version>.linux-amd64/node_exporter /usr/local/bin/
```

Set ownership:
```bash
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
```

Create systemd service:
```bash
sudo nano /etc/systemd/system/node_exporter.service
```

Paste:
```INI
[Unit]
Description=Prometheus Node Exporter
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter
```

Validate:
```bash
systemctl status node_exporter
curl http://localhost:9100/metrics
```

---

## Firewall and VLAN Requirements

Prometheus must be able to scrape the node on TCP port `9100`.

Example rule intent:

| Source | Destination | Port | Purpose |
|---|---|---|---|
| Prometheus / monitor01 | Monitored Linux node | TCP 9100 | Node Exporter scrape |

Avoid exposing Node Exporter publicly.

Node Exporter should remain internal-only.

---

## Prometheus Target Onboarding
### Preferred Method: File-Based Target List

Prometheus supports file-based service discovery, which allows target files to be updated independently from the main Prometheus configuration. Prometheus watches those files for changes and applies updates automatically.

Recommended target path:
```text
/opt/docker/stacks/prometheus/targets/nodes.yml
```
Example `nodes.yml`:
```yaml
- targets:
    - 10.0.2.10:9100
    - 10.0.2.20:9100
    - 10.0.2.30:9100
  labels:
    job: node-exporter
    environment: homelab
```

### Prometheus Scrape Config

In `prometheus.yml`:
```yaml
scrape_configs:

  - job_name: node-exporter
    file_sd_configs:
      - files:
          - /etc/prometheus/targets/nodes.yml
```

Docker Compose volume mapping should include the targets directory:
```yaml
volumes:
  - ./prometheus.yml:/etc/prometheus/prometheus.yml
  - ./targets:/etc/prometheus/targets
  - ./data:/prometheus
```

After editing `prometheus.yml`, restart Prometheus:
```bash
docker compose restart prometheus
```

After editing only `targets/nodes.yml`, Prometheus should detect the change automatically.

---

## New Node Onboarding Checklist
1. Confirm Node Identity

Record:

| Item | Value |
|---|---|
| Hostname | <hostname> |
| IP Address | <ip-address> |
| VLAN | <vlan-id> |
| Role | <node-purpose> |
| Owner | Homelab |
| Monitoring Port | 9100 |

2. Install Node Exporter

Use either Docker Compose or systemd.

Validation from the node:
```bash
curl http://localhost:9100/metrics
```

Expected result:
```text
# HELP ...
# TYPE ...
```

3. Validate Network Reachability from Prometheus Host

From `monitor01` or the Prometheus host:
```bash
curl http://<node-ip>:9100/metrics
```

If this fails, check:

- node firewall
- VLAN rules
- IP address
- Node Exporter service status
- Docker container status

4. Add Node to Prometheus Targets

Edit:
```bash
nano /opt/docker/stacks/prometheus/targets/nodes.yml
```

Add the new node:
```yaml
- targets:
    - <node-ip>:9100
  labels:
    hostname: <hostname>
    role: <role>
    vlan: "<vlan-id>"
    environment: homelab
```

Example:
```yaml
- targets:
    - 10.0.2.25:9100
  labels:
    hostname: mediabe01
    role: backend-media
    vlan: "20"
    environment: homelab
```

5. Validate in Prometheus

Open Prometheus:
```text
http://<prometheus-ip>:9090
```

Navigate to:
```text
Status → Targets
```

Expected result:
```text
node-exporter target is UP
```

6. Validate in Grafana

In Grafana:

a. Open the Linux node dashboard
b. Select the new host from the instance dropdown
c. Confirm CPU, memory, disk, and network metrics populate

Useful PromQL checks:
```promql
up{job="node-exporter"}
```
```promql
node_uname_info
```
```promql
node_filesystem_avail_bytes
```

---

## Standard Labels

Use consistent labels to make Grafana filtering easier.

Recommended labels:

| Label | Example |
|---|---|
| hostname | mediabe01 |
| role | backend-media |
| vlan | "20" |
| environment | homelab |
| site | home |

---

## Troubleshooting
###Target Shows DOWN in Prometheus

Check from Prometheus host:
```bash
curl http://<node-ip>:9100/metrics
```

Check Node Exporter service:
```bash
systemctl status node_exporter
```

Or Docker:
```bash
docker ps
docker logs node-exporter
```

### Connection Refused

Likely causes:

- Node Exporter is not running
- Port 9100 is not exposed
- Docker container failed
- Service is bound incorrectly
- Timeout

Likely causes:

- VLAN firewall blocking traffic
- Wrong IP address
- Node offline
- Routing issue


### Metrics Work Locally but Not from Prometheus

Likely causes:

- host firewall
- inter-VLAN rule missing
- Prometheus target IP incorrect
- service bound only to localhost


Node Appears with IP Instead of Hostname in Grafana

Add or correct labels in `targets/nodes.yml`:
```yaml
labels:
  hostname: documentation01
  role: documentation
  vlan: "20"
```

Then update Grafana dashboard variables to use hostname when possible.

---

## Security Considerations
- Do not expose Node Exporter to the public internet
- Restrict port 9100 to the Prometheus host where possible
- Keep exporter access internal to the homelab
- Use VLAN firewall rules to limit scrape access
- Avoid exporting unnecessary collectors unless needed

---

## Validation Checklist
-  Node hostname recorded
-  Node IP recorded
-  VLAN identified
-  Node Exporter installed
-  Local metrics endpoint works
-  Prometheus host can reach :9100
-  Node added to targets/nodes.yml
-  Prometheus target shows UP
-  Grafana dashboard displays metrics
-  Firewall exposure reviewed
-  Documentation updated

---

## Future Improvements
- Automate Node Exporter deployment with Ansible
- Use DNS names instead of IP addresses
- Add alert rules for node downtime
- Add disk usage alerts
- Add CPU and memory saturation alerts
- Add dashboard variables by hostname, role, and VLAN
- Integrate node inventory with documentation
- Move target generation into automation later

---

## Related Documentation
- Prometheus Setup
- Grafana Setup
- Observability Platform
- Inter-VLAN Routing
- Firewall Rules
