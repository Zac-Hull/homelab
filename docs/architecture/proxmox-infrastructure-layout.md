# Proxmox Infrastructure Layout

## Overview

This document describes the virtualization architecture hosted on the Proxmox platform.

The goal is to maintain a clear inventory of workloads, resource allocation, and infrastructure responsibilities.

---

## Hypervisor Platform

| Component  | Value                     |
| ---------- | ------------------------- |
| Hypervisor | Proxmox VE                |
| Purpose    | Virtualization Platform   |
| Role       | Infrastructure Foundation |

---

## High-Level Layout

```text id="2mpbqq"
Proxmox
├── documentation01
├── monitor01
├── mediabe01
├── jellyfin01
└── wg-home-gw
```

---

## VM Inventory

### documentation01

Purpose:

* Git operations
* Infrastructure documentation
* Repository management

Characteristics:

* Minimal resource requirements
* Administrative workload
* Future containerization candidate

---

### `monitor01`

Purpose:

* `Prometheus`
* `Grafana`
* `Loki`
* `Alloy`
* `Blackbox Exporter`

Responsibilities:

* metrics collection
* logging
* observability

---

### `mediabe01`

Purpose:

* Docker service hosting
* backend automation
* service orchestration

Responsibilities:

* container workloads
* service integrations
* storage consumption

---

### `jellyfin01`

Purpose:

* media streaming frontend
* user-facing application services

Responsibilities:

* media access
* streaming workloads

---

### `wg-home-gw`

Purpose:

* WireGuard tunnel endpoint
* secure remote administration

Responsibilities:

* VPN connectivity
* secure infrastructure access

---

## Resource Tracking

Populate and update as infrastructure evolves.

| VM                | vCPU | RAM | Storage | VLAN |
| ----------------- | ---- | --- | ------- | ---- |
| `documentation01` | TBD  | TBD | TBD     | TBD  |
| `monitor01`       | TBD  | TBD | TBD     | TBD  |
| `mediabe01`       | TBD  | TBD | TBD     | TBD  |
| `jellyfin01`      | TBD  | TBD | TBD     | TBD  |
| `wg-home-gw`      | TBD  | TBD | TBD     | TBD  |

---

## Operational Standards

### VM Naming

Use:

```text id="tlqvt0"
<role><number>
```

Examples:

```text id="q3z6xj"
`monitor01`
`mediabe01`
`documentation01`
```

---

### VM Separation Philosophy

Each VM should maintain a clearly defined responsibility.

Preferred:

```text id="jlwmkc"
One VM
One Purpose
```

Avoid:

```text id="6fph3v"
One VM
Many Unrelated Responsibilities
```

This lesson was reinforced during the docker01 collapse and rebuild.

---

## Backup Coverage

All production VMs should have:

* snapshots
* backup procedures
* documented recovery methods

---

## Future VM Candidates

Potential future additions:

* Identity Management
* Draw.io Service
* DNS Infrastructure
* Automation Platform
* Database Services
* Development Environment

---

## Lessons Learned

* Clear VM boundaries simplify troubleshooting
* Smaller workloads are easier to rebuild
* Documentation improves maintainability
* Separation reduces blast radius

---

## Related Documentation

* homelab-overview.md
* backup-strategy.md
* security-model.md
* wireguard-architecture.md

