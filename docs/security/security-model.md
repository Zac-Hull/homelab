# Homelab Security Model

## Overview

This document describes the security philosophy, trust boundaries, and access control model used throughout the homelab environment.

The goal is not absolute security, but rather the implementation of reasonable operational controls appropriate for a self-hosted infrastructure environment.

---

## Security Principles

### Least Privilege

Systems should only receive the permissions required to perform their intended function.

Examples:

* Monitoring services cannot administer infrastructure.
* Documentation systems do not host production services.
* External devices receive limited access.

---

### Segmentation

Network segmentation is used extensively.

Benefits include:

* reduced attack surface
* improved containment
* simplified troubleshooting
* clearer trust boundaries

---

### Defense in Depth

Security controls exist at multiple layers:

* VLAN isolation
* firewall rules
* SSH authentication
* WireGuard access controls
* service-level authentication
* monitoring and logging

---

## Trust Zones

### Management VLAN (1000)

Trust Level:

```text
Highest
```

Contains:

* Proxmox
* infrastructure management
* administrative interfaces

Access restricted to trusted administrators.

---

### Trusted Devices VLAN (10)

Trust Level:

```text
High
```

Contains:

* personal workstations
* administrative devices

Used for infrastructure administration.

---

### Server VLAN (20)

Trust Level:

```text
Moderate
```

Contains:

* Docker services
* monitoring services
* application workloads

---

### Storage VLAN (40)

Trust Level:

```text
Moderate
```

Contains:

* NAS systems
* storage resources

Access restricted to authorized workloads.

---

### IoT VLAN (30)

Trust Level:

```text
Low
```

Contains:

* smart devices
* appliances
* non-administrative hardware

Highly restricted.

---

### Guest VLAN (50)

Trust Level:

```text
Very Low
```

Wireless, internet-only access.

---

### External Devices VLAN (100)

Trust Level:

```text
Very Low
```

Only used for permanently untrusted or temporary devices.

Typically, these are:

* devices that have external scripts running while in use
* devices that patch management is not possible at local level

---

## Administrative Access

### SSH

Primary administrative access method.

Standards:

* key-based authentication
* no routine root logins
* dedicated administrative accounts

---

### WireGuard

Remote administration occurs through WireGuard.

Benefits:

* encrypted connectivity
* no public management interfaces
* restricted administrative access

---

## Authentication Strategy

### Current State

Authentication relies primarily on:

* SSH keys
* GitHub-hosted public keys
* service-specific credentials

---

### Future State

Planned improvements:

* centralized identity management
* SSO integration
* Authentik deployment
* centralized user lifecycle management

---

## Monitoring and Detection

Security visibility currently includes:

* Prometheus metrics
* Grafana dashboards
* centralized logging via Loki
* Alloy log collection
* Blackbox service probes

---

## Secrets Management

Current approach:

* SSH key authentication
* `.env` files for local configuration
* Git exclusions for sensitive files

Repository rules:

* no secrets committed
* no private keys committed
* no internal addressing exposed unnecessarily

---

## Incident Response Philosophy

When instability or compromise is suspected:

1. Contain
2. Preserve data
3. Assess impact
4. Restore critical services
5. Document findings
6. Implement preventative improvements

The `docker01` collapse and rebuild serves as the primary example of this approach.

---

## Future Security Initiatives

Planned projects:

* centralized identity management
* MFA integration
* secret management platform
* certificate lifecycle management
* automated configuration validation
* expanded log analysis

---

## Lessons Learned

* Segmentation becomes harder after growth
* Documentation improves security
* Visibility improves incident response
* Simplicity often improves reliability
* Recovery planning is part of security

---

## Related Documentation

* inter-vlan-routing.md
* firewall-rules.md
* wireguard-architecture.md
* backup-strategy.md
* docker01-collapse-rebuild.md
