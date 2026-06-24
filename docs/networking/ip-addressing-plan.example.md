# IP Addressing and Network Allocation Plan

## Overview

This document serves as the authoritative reference for IP assignments, VLAN allocations, and infrastructure addressing throughout the homelab environment.

The goal is to maintain consistency and avoid addressing conflicts as the environment grows.

---

## VLAN Inventory

| VLAN | Name             | Purpose                   |
| ---- | ---------------- | ------------------------- |
| 10   | Trusted          | Administrative devices    |
| 20   | Servers          | Application services      |
| 30   | IoT              | Smart devices             |
| 40   | Storage          | NAS and storage services  |
| 50   | Guest            | Guest access              |
| 60   | Cameras          | Surveillance devices      |
| 100  | External Devices | Untrusted devices         |
| 1000 | Management       | Infrastructure management |

---

## Addressing Philosophy

### Static Assignments

Infrastructure systems should use:

* static addresses
* DHCP reservations
* predictable naming

Avoid relying on dynamic addresses for critical systems.

---

## Infrastructure Inventory

### Hypervisor

| Host  | IP  | VLAN | Purpose      |
| ----- | --- | ---- | ------------ |
| pve01 | <PVE01_IP_ADDR> | 1000 | Proxmox Host |

---

### Virtual Machines

| Host            | IP  | VLAN | Purpose         |
| --------------- | --- | ---- | --------------- |
| documentation01 | <DOCUMENTATION01_IP_ADDR> |` 20`  | Documentation   |
| monitor01       | <MONITOR01_IP_ADDR> | `20`  | Monitoring      |
| mediabe01       | <MEDIABE01_IP_ADDR> | `20`  | Docker Services |
| jellyfin01      | <JELLYFIN01_IP_ADDR> | `20`  | Media Frontend  |
| wg-home-gw      | <WG-HOME-GW_IP_ADDR> | `20`  | VPN Gateway     |

---

### Storage

| Host | IP  | VLAN | Purpose         |
| ---- | --- | ---- | --------------- |
| NAS  | <NAS_IP_ADDR> | `40`   | Central Storage |

---

### Networking Equipment

| Device   | IP  | VLAN | Purpose           |
| -------- | --- | ---- | ----------------- |
| UDM-SE   | <UDM-SE_IP_ADDR> | `1000` | Router / Firewall |
| Switches | <SWITCH01_IP_ADDR> | `1000` | Infrastructure    |

---

## DNS Naming Standards

Preferred naming:

```text id="c7qlsf"
`monitor01`
`mediabe01`
`documentation01`
```

Avoid:

```text id="kfr9s9"
`server`
`ubuntu`
`testvm`
```

---

## Address Reservation Guidelines

Reserve ranges for:

* infrastructure
* servers
* networking
* future growth

Document allocations before deployment.

---

## Management Network

Management interfaces should remain isolated within:

```text id="0cx4ng"
`VLAN 1000`
```

Examples:

* Proxmox
* networking equipment
* administrative services

---

## Change Management

Whenever a new host is deployed:

1. Assign hostname
2. Assign VLAN
3. Record IP
4. Update documentation
5. Validate DNS
6. Verify monitoring

---

## Future Improvements

* Internal DNS integration
* Automated inventory generation
* IPAM platform evaluation
* Service discovery integration

---

## Related Documentation

* homelab-overview.md
* proxmox-layout.md
* inter-vlan-routing.md
* security-model.md
