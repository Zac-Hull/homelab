# SMB Configuration

## Overview

SMB (Server Message Block) is used to provide file sharing between the NAS and client devices within the internal network.

The NAS is hosted on a dedicated VLAN to isolate storage traffic from general network activity.

---

## Environment

- **NAS:** UGreen OS (planned future upgrade to TrueNAS Scale as a data migration project)
- **IP Address:** 10.0.4.92
- **VLAN:** Storage (VLAN 40)
- **Protocol:** SMB

---

## Access from macOS

SMB shares can be accessed from macOS using Finder or Terminal CLI

### Finder
1. Open Finder
2. Key binding 'Cmd + K'
3. Type "smb://10.0.4.92"
4. Authenticate using configured NAS user credentials

### CLI
1. mkdir -p /mnt/nas
2. mount_smbfs //<USERNAME>@10.0.4.92/share /mnt/nas

---

## Networking Notes
- SMB access requires inter-VLAN routing between Trusted (10) and Storage (40)
- Firewall rules must allow SMB traffic (TCP 445) between these VLANs

---

## Validation

- Successfully connected to NAS from macOS (Inter-VLAN route from VLAN 10 to VLAN 40)
- Verified successful read/write access to shared directories
- Confirmed connectivity across VLANs for Services (20) to request and pull data from Storage (40)

## Troubleshooting

### Problem
Unable to connect to SMB share from macOS.

### Symptoms
- Finder connection failed
- SMB share not reachable
- No obvious network errors

### Root Cause
The NAS was temporarily disconnected from the network during a physical move. During this time, the DHCP lease expired and a new IP address was assigned. 
The previously saved SMB configuration referenced the old IP address, causing connection attempts to fail.

### Resolution
1. Identified updated NAS IP address
2. Reconnected using new IP address
3. Verified SMB was running
4. Confirmed user permissions

### Preventative Actions
- Configured DHCP reservation for NAS to ensure consistent IP address
- Update to documentation with static service endpoints

### Lessons Learned
- Use DHCP reservations or static IPs for critical infrastructure
- Always verify IP addresses when verifying connectivity issues
- Network issues are often configuration issues rather than service failures
