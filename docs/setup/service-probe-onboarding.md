# Service Probe Onboarding
## Overview

This document defines the standard onboarding workflow for integrating service availability probes into the homelab observability platform.

Service probes are used to monitor:

- service availability
- HTTP/HTTPS responsiveness
- DNS resolution
- TCP connectivity
- external endpoint accessibility
- SSL certificate validity

Unlike full-node onboarding, service probe onboarding focuses on endpoint health rather than full infrastructure telemetry.

The current implementation primarily uses:

- Prometheus
- Blackbox Exporter
- Grafana

---

## Objectives
- Standardize service availability monitoring
- Detect outages quickly
- Validate endpoint accessibility
- Monitor internal and external services
- Create repeatable probe onboarding workflows
- Support future alerting integrations

---

## Current Monitoring Stack
| Component | Purpose |
|---|---|
| Blackbox Exporter | Active probing |
| Prometheus | Metrics scraping |
| Grafana | Visualization and alerting |
| Future Alertmanager | Notifications |

---

## Monitoring Philosophy

Service probes validate:

- whether a service is reachable
- whether a service responds correctly
- whether a service is externally accessible

This differs from:

- Node Exporter → infrastructure metrics
- Alloy/Loki → centralized logs

Service probes answer:

`"Can users actually reach the service?"`

---

## Supported Probe Types
|Probe Type | Purpose |
|---|---|
| HTTP/HTTPS | Website and API monitoring |
| ICMP | Host reachability |
| TCP | Port availability |
| DNS | Resolver validation |
| SSL | Certificate expiration monitoring |

---

## High-Level Workflow
```text
Service Endpoint
       ↓
Blackbox Exporter Probe
       ↓
Prometheus Scrape
       ↓
Grafana Dashboard / Alerting
```

---

## Supported Targets

Examples include:

| Service | Monitoring Type |
|---|---|
| zachull.com | HTTPS probe |
| Jellyfin | HTTP probe |
| Grafana | HTTP probe |
| Proxmox | HTTPS probe |
| WireGuard endpoint | ICMP/TCP |
| Future APIs | HTTP probe |

---

## Step 1 — Document Service Information

Record:

| Item | Example |
|---|---|
| Service Name | `grafana` |
| Hostname | `monitor01` |
| Endpoint | `https://<FQDM>` |
| Protocol | HTTPS |
| VLAN | `20` |
| External/Internal | Internal |
| Expected Status | `200 OK` |

## Step 2 — Select Probe Type
### HTTP/HTTPS Probe

Recommended for:

- websites
- dashboards
- APIs
- reverse proxy services

### ICMP Probe

Recommended for:

- infrastructure reachability
- gateway validation
- network availability

### TCP Probe

Recommended for:

- database ports
- SSH availability
- custom application ports

## Step 3 — Configure Blackbox Exporter Module

Primary config:

`blackbox.yml`

### Example HTTP Module
```yaml
modules:

  http_2xx:
    prober: http

    timeout: 5s

    http:
      preferred_ip_protocol: "ip4"
```

### Example TCP Module
```yaml
tcp_connect:
  prober: tcp
  timeout: 5s
```

### Example ICMP Module
```yaml
icmp:
  prober: icmp
  timeout: 5s
```

## Step 4 — Add Prometheus Scrape Target

In Prometheus config:
```yaml
- job_name: blackbox-http

  metrics_path: /probe

  params:
    module:
      - http_2xx

  static_configs:
    - targets:
        - https://<FQDN>

  relabel_configs:

    - source_labels: [__address__]
      target_label: __param_target

    - source_labels: [__param_target]
      target_label: instance

    - target_label: __address__
      replacement: blackbox-exporter:9115
```

## Step 5 — Restart Prometheus
```bash
docker compose restart prometheus
```

Step 6 — Validate Target in Prometheus

Open:

`http://<prometheus-ip>:9090`

Navigate to:

`Status → Targets`

Expected:

`probe target appears UP`

Step 7 — Validate in Grafana

Open Grafana dashboards or Explore.

Useful metrics:

**Probe Success**
`probe_success`
**Response Duration**
`probe_duration_seconds`
**SSL Expiration**
`probe_ssl_earliest_cert_expiry`

---

## Standard Labels

Use consistent labels.

Recommended:

| Label | Example |
|---|---|
| `service` | `grafana` |
| `environment` | `homelab` |
| `vlan` | `"20"` |
| `site` | `home` |
| `endpoint_type` | `https` |

---

## Validation Checklist
### Configuration

- [ ] Blackbox module configured
- [ ] Prometheus target added
- [ ] Correct endpoint specified
- [ ] Correct protocol selected

### Validation

- [ ] Prometheus target `UP`
- [ ] Grafana metrics visible
- [ ] Probe success confirmed
- [ ] Response metrics visible
- [ ] SSL metrics visible if applicable

---

## SSL Certificate Monitoring
- Requires `HTTPS` target in `blackbox-http.yml`
- Requires `probe_type="https"` label
- Uses `probe_ssl_earliest_cert_expiry`
- Warning threshold: < 21 days
- Critical threshold: < 7 days

---

## Troubleshooting
### Probe Shows `DOWN`

Check:

1. DNS resolution
2. firewall rules
3. reverse proxy
4. target service
5. Blackbox module type
6. protocol mismatch

### HTTPS Probe Failure

Verify:

- TLS certificate valid
- endpoint reachable
- reverse proxy healthy
- DNS correct

### IPv6 vs IPv4 Issues

Symptoms:

- service accessible manually
- probe reports `DOWN`

Potential cause:

- probe attempting IPv6
- service only reachable over IPv4

Fix:
```yaml
preferred_ip_protocol: "ip4"
```

This issue was encountered while probing:

`zachull.com`

### DNS Failures

Check:
```bash
dig <hostname>
```

Validate:

- DNS resolution
- reverse proxy routing
- public accessibility

### TCP Probe Failure

Check:

- port listening
- firewall rules
- VLAN restrictions
- service running

---

## Recommended Probe Categories
### Critical Infrastructure
- Proxmox
- WireGuard gateway
- Grafana
- Prometheus
- Loki

### External Services
- public websites
- reverse proxies
- APIs

### Internal Services
- Jellyfin
- SMB services
- DNS services
- monitoring stack

---

## Security Considerations
- Restrict Blackbox Exporter internally
- Avoid unnecessary public probes
- Monitor only intentionally exposed services
- Validate TLS configurations regularly
- Avoid exposing management endpoints externally

---

## Lessons Learned
- Endpoint accessibility differs from infrastructure health
- Monitoring should validate the actual user path
- IPv6 behavior can create misleading failures
- External probes provide valuable operational visibility
- Standardized probes simplify alerting workflows

---

## Future Improvements
### Planned Alerting

Future integrations:

- Discord notifications
- email alerts
- mobile notifications

### Planned Automation

Future goals include:

- automatic probe registration
- service discovery integration
- template-based onboarding
- Infrastructure-as-Code deployment
- automatic Grafana dashboard provisioning

### Future Monitoring Expansion

Planned additions:

- SSL expiration alerting
- synthetic transactions
- API health validation
- distributed external probing
- multi-region probes

---

## Related Documentation
- Blackbox Exporter Setup
- Prometheus Setup
- Grafana Setup
- Full Node Observability Onboarding
- Observability Platform
