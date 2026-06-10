# Backup and Recovery Strategy

## Overview

This document defines the backup, snapshot, and recovery strategy used throughout the homelab environment.

The goal is to reduce recovery time, preserve operational continuity, and minimize the impact of hardware failures, software failures, and administrative mistakes.

This document should be reviewed whenever major infrastructure changes occur.

---

## Objectives

* Protect critical infrastructure
* Minimize downtime
* Preserve documentation
* Maintain rollback capability
* Improve recovery confidence
* Support disaster recovery planning

---

## Recovery Priorities

In a full environment loss scenario, systems should be restored in the following order:

### Priority 1 — Network Access

Restore:

* external/edge networking device configuration
* VLAN functionality
* routing tables and firewall policies
* internet connectivity

Without network access, all other recovery efforts become significantly more difficult.

---

### Priority 2 — Hypervisor Platform

Restore:

* Proxmox host
* storage configuration
* virtual machine inventory

---

### Priority 3 — Storage

Restore:

* NAS services
* SMB shares
* persistent storage

---

### Priority 4 — Administrative Access

Restore:

* WireGuard connectivity
* management VLAN access
* SSH connectivity

---

### Priority 5 — Monitoring

Restore:

* `Prometheus`
* `Grafana`
* `Loki`
* `Alloy`

Observability should be restored early to assist further recovery.

---

### Priority 6 — Application Services

Restore:

* `mediabe01`
* `jellyfin01`
* future services

---

## Protection Methods

| Asset                     | Protection Method   |
| ------------------------- | ------------------- |
| Proxmox VMs               | Snapshots + Backups |
| Documentation             | GitHub Repository   |
| Docker Configurations     | Git Repository      |
| NAS Data                  | NAS Backup Strategy |
| SSH Keys                  | Secure Key Storage  |
| Monitoring Configurations | Git Repository      |

---

## Snapshot Policy

Snapshots should be created before:

* OS upgrades
* Docker upgrades
* storage modifications
* network changes
* firewall changes
* observability changes
* major application deployments

---

## Snapshot Naming Standard

Examples:

```text id="k3baxh"
pre-docker-upgrade
pre-storage-expansion
pre-vlan-change
baseline-clean-install
```

---

## Git as Infrastructure Backup

The Git repository serves as the authoritative source for:

* documentation
* deployment procedures
* architecture decisions
* observability configurations
* onboarding procedures

The repository should not contain:

* secrets
* private keys
* passwords
* sensitive internal information

---

## Validation Schedule

Regularly verify:

* backups complete successfully
* snapshots exist
* restore procedures remain valid
* documentation remains current

---

## Disaster Recovery Testing

Future goal:

Perform periodic recovery testing to validate:

* VM restoration
* configuration recovery
* documentation accuracy
* operational readiness

---

## Lessons Learned

The `docker01` collapse demonstrated:

* recovery is easier when documentation exists
* snapshots are critical before risky changes
* rebuilding is sometimes faster than repairing
* infrastructure should be designed for replacement

---

## Future Improvements

* Automated Proxmox backups
* Offsite backup replication
* Automated backup verification
* Infrastructure-as-Code deployments
* Recovery drills
* Backup monitoring dashboards

---

## Related Documentation

* `proxmox-layout.md`
* `homelab-overview.md`
* `security-model.md`
* `docker01-collapse-rebuild.md`

