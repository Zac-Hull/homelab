# Homelab Architecture Overview

## Overview

This document provides a high-level overview of the homelab environment, its major infrastructure components, network architecture, service organization, and operational design principles.

The homelab serves three primary purposes:

* Infrastructure engineering education
* Portfolio and professional development
* Self-hosted service experimentation

The environment is intentionally designed to emphasize:

* security
* observability
* documentation
* segmentation
* repeatability
* operational maturity

---

## Design Philosophy

The environment follows several core principles:

### Infrastructure as a Learning Platform

The homelab is built to provide practical experience with:

* Linux administration
* virtualization
* networking
* cloud services
* observability
* automation
* infrastructure documentation

### Separation of Responsibilities

Services are separated into dedicated systems wherever practical.

Examples:

* Monitoring services isolated from application services
* Documentation workflows isolated from media workflows
* Management interfaces isolated from user-facing services

### Documentation First

Major infrastructure changes should be documented before, during, and after implementation.

Documentation is treated as a critical component of the environment.

### Security Through Segmentation

Infrastructure is divided into VLANs and service boundaries to reduce unnecessary trust relationships and improve operational visibility.

---

## High-Level Architecture

```text
Internet
    │
    ▼
AWS WireGuard Relay
    |
    ▼
IPS-Provided ONT
    │
    ▼
UDM-SE
    │
    ├── VL10 - Trusted Devices
    ├── VL20 - Servers
    ├── VL30 - IoT
    ├── VL40 - Storage
    ├── VL50 - Guest
    ├── VL60 - Cameras
    ├── VLAN 100 - External Devices
    └── VLAN 1000 - Management
                │
                ▼
            Proxmox
                │
                ├── mediabe01
                ├── monitor01
                ├── documentation01
                ├── jellyfin01
                └── wg-home-gw
```

---

## Core Infrastructure Components

### UDM-SE

Responsibilities:

* VLAN routing
* firewall enforcement
* DHCP
* internet connectivity
* WireGuard integration

---

### Proxmox

Responsibilities:

* virtualization platform
* VM lifecycle management
* snapshots
* backups
* infrastructure hosting

---

### NAS

Responsibilities:

* centralized storage
* SMB shares
* backup destinations
* media storage

---

## Virtual Machines

### documentation01

Purpose:

* Git operations
* infrastructure documentation
* repository management

Future plans:

* containerization
* automation integration

---

### monitor01

Purpose:

* Prometheus
* Grafana
* Loki
* Alloy
* Blackbox Exporter

Provides centralized observability.

---

### mediabe01

Purpose:

* backend service hosting
* Docker workloads
* media workflow automation
* storage integration

---

### jellyfin01

Purpose:

* media consumption frontend
* isolated user-facing service

---

### wg-home-gw

Purpose:

* WireGuard connectivity
* remote administrative access
* secure tunnel routing

---

## Observability Platform

Current components:

* Prometheus
* Grafana
* Node Exporter
* Blackbox Exporter
* Loki
* Alloy

Primary goals:

* visibility
* reliability
* troubleshooting
* operational awareness

---

## Documentation Structure

Documentation is organized into:

```text
docs/
├── architecture/
├── incidents/
├── networking/
├── onboarding/
├── operations/
├── security/
├── services/
├── setup/
└── troubleshooting/
```

---

## Future Direction

Planned initiatives:

* centralized identity management
* infrastructure automation
* Terraform adoption
* Ansible deployment
* improved backup automation
* expanded observability
* self-hosted documentation tooling

---

## Related Documentation

* security-model.md
* proxmox-layout.md
* backup-strategy.md
* observability-platform.md
* wireguard-architecture.md
* inter-vlan-routing.md
