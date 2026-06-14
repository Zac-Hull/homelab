# Homelab Service Catalog

## Overview

This document serves as the central catalog of services, infrastructure components, and operational workloads within the homelab environment.

The goal of the service catalog is to provide a single reference for:

* what services exist
* where services run
* what each service does
* how critical each service is
* what systems depend on each service
* where related documentation lives

This document should be updated whenever a service is added, removed, migrated, or significantly changed.

---

## Service Catalog

| Service / Component       | Host              | Category                          | Purpose                                                         | Criticality | Status               | Related Docs                                |
| ------------------------- | ----------------- | --------------------------------- | --------------------------------------------------------------- | ----------- | -------------------- | ------------------------------------------- |
| Proxmox VE                | `pve01`           | Virtualization                    | Hosts homelab VMs and core infrastructure workloads             | High        | Active               | `docs/architecture/proxmox-layout.md`       |
| UDM-SE                    | Network Edge      | Networking                        | Router, firewall, VLAN routing, DHCP, and network control       | High        | Active               | `docs/security/security-model.md`           |
| NAS / Storage             | NAS               | Storage                           | Centralized storage, SMB shares, backups, and persistent data   | High        | Active               | `docs/storage/smb.md`                       |
| WireGuard Gateway         | `wg-home-gw`      | Remote Access                     | Secure remote administrative access into the homelab            | High        | Active               | `docs/networking/wireguard-architecture.md` |
| Prometheus                | `monitor01`       | Observability                     | Metrics scraping and time-series storage                        | High        | Active               | `docs/services/prometheus.md`               |
| Grafana                   | `monitor01`       | Observability                     | Dashboards, visualization, and monitoring interface             | High        | Active               | `docs/services/grafana.md`                  |
| Loki                      | `monitor01`       | Observability                     | Centralized log aggregation                                     | Medium      | Active               | `docs/services/loki.md`                     |
| Alloy                     | `monitor01`       | Observability                     | Log collection and forwarding to Loki                           | Medium      | Active               | `docs/services/alloy.md`                    |
| Blackbox Exporter         | `monitor01`       | Observability                     | Endpoint probing for HTTP, TCP, ICMP, DNS, and SSL checks       | Medium      | Active               | `docs/services/blackbox-exporter.md`        |
| Node Exporter             | Multiple Nodes    | Observability                     | Linux host metrics collection                                   | Medium      | Active               | `docs/services/node-exporter-onboarding.md` |
| documentation01           | `documentation01` | Documentation                     | Git operations and infrastructure documentation workflow        | Medium      | Active               | `docs/setup/proxmox-vm-baseline.md`         |
| mediabe01                 | `mediabe01`       | Backend Services                  | Backend service hosting and media workflow orchestration        | Medium      | Active               | `docs/services/mediabe01-overview.md`       |
| Jellyfin                  | `jellyfin01`      | Application                       | Media frontend and user-facing streaming service                | Low         | Active / In Progress | TBD                                         |
| SMB                       | NAS               | Storage Protocol                  | Shared file access between clients, services, and storage       | High        | Active               | `docs/storage/smb.md`                       |
| GitHub Homelab Repo       | GitHub            | Documentation / Source Control    | Version-controlled infrastructure documentation and public repo | High        | Active               | `README.md`                                 |
| Uptime Kuma               | TBD               | Observability                     | Service availability monitoring and alerting                    | Medium      | Planned              | TBD                                         |
| Identity Management Stack | TBD               | Security                          | Future centralized identity, access, and authentication control | High        | Planned              | TBD                                         |
| Reverse Proxy             | TBD               | Networking / Application Delivery | Future internal and external service routing                    | High        | Planned              | TBD                                         |
| Internal DNS              | TBD               | Networking                        | Future internal name resolution and service discovery           | High        | Planned              | TBD                                         |
| Alertmanager              | `monitor01`       | Observability                     | Future alert routing and notification handling                  | Medium      | Planned              | TBD                                         |

---

## Criticality Rating Criteria

Criticality ratings describe the operational importance of a service or component within the homelab environment.

Criticality is based on:

* infrastructure dependency
* recovery priority
* security importance
* number of dependent systems
* impact of downtime
* difficulty of replacement
* role in monitoring or recovery

---

## High Criticality

A service or component is rated **High** if its failure would significantly impair the ability to operate, access, recover, or secure the homelab.

High criticality systems usually meet one or more of the following criteria:

* Required for network access
* Required for infrastructure administration
* Required for storage access
* Required for recovery or disaster response
* Required by multiple dependent systems
* Security-sensitive or access-control related
* Difficult or time-consuming to rebuild

Examples:

* Proxmox
* UDM-SE
* NAS / Storage
* WireGuard Gateway
* Prometheus
* Grafana
* SMB
* GitHub Homelab Repository
* Identity Management Stack

---

## Medium Criticality

A service or component is rated **Medium** if its failure would reduce visibility, automation, convenience, or service quality, but would not immediately prevent core infrastructure operation.

Medium criticality systems usually meet one or more of the following criteria:

* Important for monitoring or troubleshooting
* Supports operational workflows
* Supports automation or service management
* Has workarounds during an outage
* Can be rebuilt without major data loss
* Impacts a subset of services rather than the entire environment

Examples:

* Loki
* Alloy
* Blackbox Exporter
* Node Exporter
* documentation01
* mediabe01
* Uptime Kuma
* Alertmanager

---

## Low Criticality

A service or component is rated **Low** if its failure impacts convenience or non-essential functionality but does not significantly affect infrastructure administration, recovery, or security.

Low criticality systems usually meet one or more of the following criteria:

* User-facing but non-essential
* Minimal dependency from other systems
* Easy to rebuild or replace
* Does not block infrastructure recovery
* Does not affect security boundaries
* Outage is inconvenient but tolerable

Examples:

* Jellyfin
* lab test services
* temporary containers
* experimental applications

---

## Status Definitions

| Status      | Meaning                                   |
| ----------- | ----------------------------------------- |
| Active      | Currently deployed and in use             |
| In Progress | Being deployed, tested, or migrated       |
| Planned     | Intended future service or component      |
| Deprecated  | No longer recommended but may still exist |
| Retired     | Removed from active infrastructure        |

---

## Category Definitions

| Category         | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| Virtualization   | Hypervisors and VM platforms                                 |
| Networking       | Routing, firewalling, VLANs, DNS, and connectivity           |
| Storage          | NAS, shares, backups, and persistent storage                 |
| Observability    | Metrics, logs, probes, dashboards, and alerting              |
| Security         | Authentication, access control, secrets, and identity        |
| Application      | User-facing services                                         |
| Documentation    | Git, docs, diagrams, and operational knowledge               |
| Backend Services | Internal automation, orchestration, and supporting workloads |

---

## Operational Notes

* High criticality systems should have documented recovery procedures.
* Medium criticality systems should have setup documentation and monitoring.
* Low criticality systems should still be documented if they introduce dependencies.
* Any service with persistent data should have a backup or rebuild strategy.
* Any service exposed outside the local network should have security documentation.
* Any service used by multiple systems should be monitored.

---

## Maintenance Guidelines

Update this catalog when:

* a new VM is created
* a new Docker service is deployed
* a service changes host
* a service changes criticality
* a service becomes externally accessible
* a service is retired
* new documentation is created

---

## Future Improvements

* Add owner/contact column
* Add exposed ports
* Add backup status
* Add monitoring status
* Add alerting status
* Add recovery procedure links
* Add service dependency map
* Add internal DNS names
* Add dashboard links

---

## Related Documentation

* [Homelab Architecture Overview](../architecture/homelab-overview.md)
* [Proxmox Infrastructure Layout](../architecture/proxmox-layout.md)
* [Security Model](../security/security-model.md)
* [Backup and Recovery Strategy](../operations/backup-strategy.md)
* [Observability Platform](../projects/observability-platform.md)
* [IP Addressing and Network Allocation Plan](../networking/ip-addressing-plan.md)
