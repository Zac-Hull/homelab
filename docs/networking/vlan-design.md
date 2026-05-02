# VLAN Design

## Overview

The homelab network is segmented using VLANs to separate infrastructure, services, and storage traffic. This improves organization, security, and scalability.

Inter-VLAN routing and access control are enforced at the firewall to restrict unnecessary communication between network segments.

---

VLAN Configuration

| VLAN | Name              | Subnet        | Purpose                                                |
|------|-------------------|---------------|--------------------------------------------------------|
|    1 | Default           | 10.0.0.0/24   | Holding area for new devices                           |
|   10 | Trusted Devices   | 10.0.1.0/24   | Devices that have advanced priviledge                  |
|   20 | Services          | 10.0.2.0/24   | VMs and applications                                   |
|   30 | IoT               | 10.0.3.0/24   | Devices without a manageable OS                        |
|   40 | Storage           | 10.0.4.0/24   | NAS and storage traffic                                |
|   50 | Guest             | 10.0.5.0/24   | Access to external internet only                       |
|   60 | Cameras           | 10.0.6.0/24   | Internal camera traffic                                |
|  100 | Untrusted Devices | 10.0.100.0/29 | Lockdown with limited access to external internet only |
| 1000 | Management        | 10.1.0.0/16   | Infrastructure management                              |

## Current Devices

### VLAN 10 - Trusted Devices
- personal cell phone (iOS)
- wife's cell phone (iOS)
- personal desktop (Windows 11 Pro)
- personal laptop (macOS)
- personal tablet (ipadOS)
- wife's tablet (ipadOS)
- printer

### VLAN 20 - Services
- docker01 (Docker VM)
- jellyfin01 (Media Server **deployment in progress**)
- WireGuard Gateway

### VLAN 30 - IoT
- smart lights (Govee)
- smart lights (TP-Link)
- air purifiers (Levoit)
- car
- thermostats (Nest)
- doorbell camera (**pending migration**)
- smoke/CO2 detector (Nest)
- smart TV (Roku)
- adjustable bed base
- smart speakers with voice assistance

### VLAN 40 - Storage
- UGreen OS Storage (10.0.4.92)

### VLAN 50 - Guest
- None currently deployed

### VLAN 60 - Cameras
- None currently deployed

### VLAN 100 - Untrusted Devices
- work laptop
- school mini PC

### VLAN 1000 - Management
- Firewall/Router (10.1.0.1)
- WAPs 
- Proxmox Node (10.1.0.10)

---

## Design Decisions

- **Segmentation:** Keeps storage traffic isolated from general services
- **Security:** Reduces attack surface between network zones
- **Performance:** Prevents unnecessary broadcast traffic
- **Scalability:** Allows future VLAN expansion (IoT testing, isolated services)

## Traffic Flow

- Trusted Devices (10) can access Services (20) and Storage (40)
- Services (20) can access Storage (40)
- IoT (30) is restricted from accessing other internal VLANs
- Guest (50) has internet-only access
- Management (1000) is restricted to infrastructure devices only

---

## Notes

- VLANs are trunked between router, switch, and Proxmox host
- DHCP reservations are used for critical infrastructure
- Inter-VLAN routing is handled by the firewall/router, pending future upgrade to dedicated devices
- Most VLANs use /24 for simplicity and scalability 
- VLAN 100 uses /29 to restrict the nubmer of allowed devices (untrusted/external)
- VLAN 1000 uses /16 to allow for larger DHCP pools once clustering starts taking place
