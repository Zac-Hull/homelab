# Full Node Observability Onboarding
## Overview

This document defines the standardized onboarding workflow for integrating a new Linux node into the homelab observability platform.

The purpose of this process is to ensure every onboarded node receives:

- metrics collection
- centralized logging
- Prometheus visibility
- Grafana visualization
- standardized labels
- repeatable observability integration

This document serves as the primary onboarding workflow for monitored infrastructure nodes.

Detailed implementation references are delegated to service-specific onboarding documentation.

---

## Objectives
- Standardize observability onboarding
- Reduce onboarding drift
- Simplify future scaling
- Ensure consistent labels and naming
- Minimize duplicated onboarding procedures
- Create a future automation foundation

---

### Current Observability Stack
| Component | Purpose |
|---|---|
| Prometheus | Metrics collection |
| Grafana | Visualization |
|Node Exporter | Linux host metrics |
| Alloy | Log collection and forwarding |
| Loki | Log aggregation |
| Docker Compose | Service orchestration |

---

## High-Level Workflow
```text
New Linux Node
       ↓
Node Exporter Installed
       ↓
Alloy Log Collection Configured
       ↓
Prometheus Target Added
       ↓
Logs Sent to Loki
       ↓
Metrics and Logs Visualized in Grafana
```

---

## Supported Node Types

This onboarding workflow applies to:

- Ubuntu Server VMs
- Docker hosts
- utility infrastructure VMs
- monitoring nodes
- future Linux-based service nodes

Examples:

- `mediabe01`
- `documentation01`
- `monitor01`
- future observability nodes

---

## Pre-Onboarding Requirements

Before onboarding, confirm:

| Requirement | Status |
|---|---|
| VM deployed | Required |
| SSH access working | Required |
| Docker installed (if applicable) | Recommended |
| Correct VLAN assigned | Required |
| Internet connectivity working | Required |
| DNS resolution working | Recommended |

---

## Onboarding Process
### Step 1 — Document Node Information

Record the following information:

| Item | Example |
|---|---|
| Hostname | `mediabe01` |
| IP Address | `10.0.2.20` |
| VLAN | `20` |
| Node Role | backend-media |
| Operating System | Ubuntu Server |
| Monitoring Method | Docker Compose |

### Step 2 — Install Node Exporter

Node Exporter provides:

- CPU metrics
- memory metrics
- disk metrics
- filesystem metrics
- network metrics

Follow:

`docs/services/node-exporter-onboarding.md`

Validation target:

`http://<node-ip>:9100/metrics`

Expected result:

- Prometheus target appears UP
- Grafana dashboards populate

### Step 3 — Configure Alloy Logging

Alloy provides:

- centralized log collection
- Docker log forwarding
- Linux system log forwarding
- future telemetry pipelines

Follow:

`docs/onboarding/alloy-onboarding.md`

Validation target:

- logs visible in Grafana Explore
- Loki labels visible
- Alloy container healthy

### Step 4 — Validate Network Reachability

From the Prometheus host:
```bash
curl http://<node-ip>:9100/metrics
```

From the Alloy/Loki environment:
```bash
curl http://<loki-host>:3100/ready
```

Check:

- VLAN rules
- firewall rules
- routing
- Docker networking

### Step 5 — Validate Metrics in Prometheus

Open:

`http://<prometheus-ip>:9090`

Navigate to:

`Status → Targets`

Expected:

- Node Exporter target appears `UP`

### Step 6 — Validate Metrics in Grafana

Open the Linux node dashboard.

Validate:

- CPU metrics
- memory usage
- disk usage
- filesystem metrics
- network metrics

Example PromQL:
```promql
up{job="node-exporter"}
```

### Step 7 — Validate Logs in Grafana

Open:

- Grafana → Explore
- Select Loki datasource

Run broad query first:
```logql
{job=~".+"}
```

Then narrow:
```logql
{hostname="<hostname>"}
```

Expected:

- active log streams
- labels visible
- recent timestamps

### Step 8 — Apply Standard Labels

Consistent labels are critical.

Recommended labels:

| Label | Example |
|---|---|
| `hostname` | `mediabe01` |
| `role` | `backend-media` |
| `environment` | `homelab` |
| `vlan` | `"20"` |
| `site` | `home` |

---

## Recommended Validation Order

Always validate in this order:

1. Node Exporter
2. Prometheus
3. Grafana metrics
4. Alloy
5. Loki
6. Grafana logs

This reduces troubleshooting complexity significantly.

## Standard Onboarding Checklist
### Infrastructure

- [ ] VM deployed
- [ ] Hostname configured
- [ ] Correct VLAN assigned
- [ ] SSH access validated
- [ ] DNS resolution working

### Metrics

- [ ] Node Exporter installed
- [ ] Port 9100 reachable
- [ ] Prometheus target added
- [ ] Prometheus target UP
- [ ] Grafana metrics visible

### Logging

- [ ] Alloy configured
- [ ] Docker socket mounted if needed
- [ ] System log mounts configured
- [ ] Loki reachable
- [ ] Grafana logs visible

### Labels

- [ ] Hostname labels consistent
- [ ] Service labels consistent
- [ ] VLAN labels assigned
- [ ] Environment labels assigned

---

## Troubleshooting Workflow
### Metrics Missing

Check:

- Node Exporter running
- Prometheus scrape target
- firewall rules
- VLAN routing
- Grafana datasource

### Logs Missing

Check:

- Alloy running
- Loki healthy
- Grafana datasource
- mounted log paths
- Docker socket access
- label queries

### Labels Inconsistent

Verify:

- Alloy labels
- Prometheus labels
- Grafana variables
- hostname consistency

---

## Operational Standards
### Naming Standards

Use:

- lowercase hostnames
- consistent service names
- descriptive labels

Examples:

- `monitor01`
- `mediabe01`
- `documentation01`

### Label Standards

Avoid:

- inconsistent capitalization
- duplicate meanings
- temporary labels

Prefer:

- stable operational identifiers

---

## Security Considerations
- Observability infrastructure should remain internal-only
- Node Exporter should not be publicly exposed
- Alloy Docker socket access should be minimized
- Loki ingestion should remain internal
- Grafana admin access should be restricted

---

## Lessons Learned
- Standardized onboarding reduces operational drift
- Metrics and logs complement each other significantly
- Label consistency matters early
- Broad validation queries reduce troubleshooting time
- Centralized observability becomes increasingly valuable as infrastructure scales

---

## Future Improvements
### Planned Automation

The current onboarding workflow is manual.

Future goals include:

- automated node onboarding
- configuration templating
- centralized service discovery
- automated label assignment
- Infrastructure-as-Code deployment
- Ansible-based provisioning
- automatic Prometheus target generation
- automatic Alloy pipeline deployment

### Future Monitoring Expansion

Planned additions:

- SNMP monitoring
- UPS monitoring
- Proxmox exporters
- reverse proxy metrics
- alerting pipelines
- distributed observability agents

---

## Related Documentation
- Node Exporter Onboarding
- Alloy Onboarding
- Prometheus Setup
- Grafana Setup
- Alloy Setup
- Loki Setup
- Log Ingestion Workflow
- Observability Platform