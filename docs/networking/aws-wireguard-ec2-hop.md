# Site-to-Site WireGuard VPN via AWS EC2 Relay

Production-style hybrid networking project connecting a home homelab to cloud infrastructure using WireGuard, AWS EC2, VLAN segmentation, and routed private subnets.

---

## Overview

This project implements a secure site-to-site WireGuard VPN tunnel between a home homelab environment and a cloud-hosted AWS EC2 instance acting as a relay gateway.

The design enables:

- Secure remote access into the homelab
- Private routed communication between networks
- Segmented management VLAN access
- Future expansion for remote clients, cloud workloads, or additional sites
- Encrypted transport over the public internet
- Reduced attack surface compared to exposing services publicly

This project was also used as a hands-on exercise in:

- Linux networking
- Routing
- Firewall management
- WireGuard administration
- VLAN segmentation
- AWS infrastructure
- Troubleshooting distributed systems

---

## Project Goals
### Primary Goals
- Build a secure remote access solution
- Avoid exposing internal services directly to the internet
- Learn WireGuard networking in a production-style environment
- Create scalable architecture for future multi-site expansion
- Enable access to isolated VLANs remotely
### Secondary Goals
- Improve Linux CLI proficiency
- Practice infrastructure documentation
- Understand routing and firewall behavior
- Learn cloud-to-homelab integration

---

## Architecture

                Internet
                    │
                    │
        ┌─────────────────────┐
        │ AWS EC2 Relay Node  │
        │ -Ubuntu Server      │
        │ -WireGuard Server   │
        │ -Public IP         |
        └─────────┬───────────┘
                  │ WG Tunnel
                  | 10.200.0.0/24
                  │
        ┌─────────┴───────────┐
        │ Home Gateway VM    │
        │ -wg_home_gw        |
        │ - WireGuard Clien   │
        └─────────┬───────────┘
                  │
        ┌─────────┴───────────┐
        │     UniFi Network   │
        └─────────┬───────────┘
                  │
     ┌────────────┼────────────┐
     │            │            │
 Management    Services      Storage
 VLAN          VLAN          VLAN
10.1.0.0/16   10.0.2.0/24   10.0.4.0/24

---

## Environment
### Cloud Infrastructure
| Component | Details |
|---|---|
| Cloud Provider | AWS |
| Service | EC2 |
| OS | Ubuntu Server |
| VPN Software | WireGuard |
| Role | Public relay / VPN endpoint |

---
### Homelab Infrastructure
| Component | Details |
|---|---|
| Hypervisor | Proxmox VE |
| Router | UniFi |
| VPN Gateway | Ubuntu VM |
| Internal VLANs | Segmented |
| DNS | Internal lab DNS |
| Services | Jellyfin, Docker workloads, documentation systems |

---

## Why an EC2 Relay Was Used

Residential ISPs often introduce several limitations:

- Dynamic IP addresses
- CGNAT (Carrier-Grade Network Address Translation)  restrictions
- Inbound port filtering
- Reliability concerns

Using AWS EC2 solved these problems by providing:

- Stable public endpoint
- Static elastic IP capability
- Always-online relay
- Easy WireGuard peer connectivity
- Centralized routing point for future clients

This architecture also creates a foundation for:

- Road-warrior VPN clients
- Multi-site VPN
- Cloud-hosted services
- Hybrid infrastructure

---

## WireGuard Network Design

Tunnel Network
`10.100.0.0/24`

Device Tunnel IP
- EC2 Relay `10.200.0.1`
- Home Gateway `10.200.0.2`

---

## EC2 WireGuard Configuration
### Install WireGuard
```bash
sudo apt update
sudo apt install wireguard
```

### Enable IP Forwarding

Edit:
```bash
/etc/sysctl.conf
```
Uncomment or add:
```bash
net.ipv4.ip_forward=1
```
Apply:
```bash
sudo sysctl -p
```
### Generate Keys
```bash
wg genkey | tee privatekey | wg pubkey > publickey
```
### Example EC2 Config
```INI
[Interface]
Address = 10.100.0.1/24
ListenPort = 51820
PrivateKey = <EC2_PRIVATE_KEY>

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -A FORWARD -o wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -D FORWARD -o wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = <HOME_PUBLIC_KEY>
AllowedIPs = 10.1.0.0/24,10.2.0.0/24,10.3.0.0/24
```
---
## Home Gateway Configuration
###Install WireGuard
```bash
sudo apt update
sudo apt install wireguard
```
###Example Home Gateway Config
```INI
[Interface]
Address = 10.100.0.2/24
PrivateKey = <HOME_PRIVATE_KEY>

[Peer]
PublicKey = <EC2_PUBLIC_KEY>
Endpoint = <EC2_PUBLIC_IP>:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```
---
## AWS Security Group Configuration

The EC2 instance required inbound UDP access for WireGuard.

### Required Rule
Type	Protocol	Port	Source
Custom UDP	UDP	51820	Trusted IPs or 0.0.0.0/0

## Major Issues Encountered
**1. EC2 Username Confusion**

One of the earliest blockers was authentication into the EC2 instance.

Different AMIs use different default usernames:

| Distribution | Username |
|---|---|
| Ubuntu | ubuntu |
| Amazon Linux | ec2-user
| Debian | admin/debian

This caused repeated SSH failures until the correct username was identified.

**2. Security Group Misconfiguration**

Initial WireGuard connectivity failed because UDP port 51820 was not properly exposed in the AWS Security Group.

**Symptoms included:**

- No tunnel handshake
- No peer communication
- WireGuard appearing "up" locally

**Resolution:**

- Add inbound UDP rule for port 51820
- Verify source ranges
- Confirm EC2 public IP

**3. Management VLAN Isolation**

A major pain point involved accessing Proxmox remotely.

**Initially:**

- Internal services worked
- Jellyfin was reachable
- Proxmox management interface was not

**Root cause:**

The management VLAN firewall policies were intentionally restrictive.

This was actually desirable from a security standpoint, but required explicit inter-VLAN allowances.

**Resolution involved:**

- Adjusting UniFi firewall rules
- Allowing traffic from WireGuard subnet
- Verifying routes between VLANs

**4. Incorrect Internal Subnet Assumptions**

There was confusion between:

`10.0.2.x`

and

`10.1.0.x`

This caused routing mismatches and failed connectivity tests.

The actual Proxmox management subnet was:

`10.1.0.0/24`

Correcting the route tables resolved the issue.

**5. UniFi Firewall Complexity**

UniFi firewall logic introduced additional troubleshooting complexity.

Pain points included:

- Hidden implicit deny behavior
- VLAN isolation rules
- Directional firewall logic
- GUI terminology confusion

**Key lesson:**

Inter-VLAN routing does not automatically imply inter-VLAN firewall permission.

**6. Split-Tunnel vs Full-Tunnel Behavior**

Using:

```INI
AllowedIPs = 0.0.0.0/0
```

initially created routing behavior that redirected all traffic through the tunnel.

While useful for some deployments, it introduced troubleshooting complexity.

A more production-ready approach is selective routing:
```INI
AllowedIPs = 10.1.0.0/24,10.2.0.0/24
```

---

## Validation & Testing
### Tunnel Status
```bash
sudo wg show
```
## Connectivity Testing
### Ping Internal Hosts
```bash
ping 10.1.0.10
```
### Verify Listening Port
```bash
sudo ss -ulpn | grep 51820
```
### Check Routing Table
```bash
ip route
```
---

## Adding Additional Clients

This architecture was intentionally designed to scale.

Additional peers can be added on either side of the EC2 relay.

### Option 1 — Add Remote Client Devices

Example:

- Laptop
- Phone
- Tablet
- Remote workstation

These devices connect directly to the EC2 relay.

### Example Client Config
```INI
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.100.0.10/24
DNS = 10.1.0.1

[Peer]
PublicKey = <EC2_PUBLIC_KEY>
Endpoint = <EC2_PUBLIC_IP>:51820
AllowedIPs = 10.1.0.0/24,10.2.0.0/24
PersistentKeepalive = 25
```
### Add Peer to EC2
```INI
[Peer]
PublicKey = <CLIENT_PUBLIC_KEY>
AllowedIPs = 10.100.0.10/32
```
---

### Option 2 — Add Another Site

A second homelab or remote network can be connected similarly.

Example:
```INI
Remote Site LAN:
10.50.0.0/24
```
### Add Peer on EC2
```INI
[Peer]
PublicKey = <REMOTE_SITE_PUBLIC_KEY>
AllowedIPs = 10.50.0.0/24
```
### Remote Site Config
```INI
[Interface]
Address = 10.100.0.20/24
PrivateKey = <REMOTE_PRIVATE_KEY>

[Peer]
PublicKey = <EC2_PUBLIC_KEY>
Endpoint = <EC2_PUBLIC_IP>:51820
AllowedIPs = 10.1.0.0/24,10.2.0.0/24
PersistentKeepalive = 25
```
---
### Routing Considerations for Expansion

As additional sites are added:

### Important Rules
### Each LAN Must Be Unique

Bad:
```INI
Home:   10.1.0.0/24
Remote: 10.1.0.0/24
```

Good:
```INI
Home:   10.1.0.0/24
Remote: 10.50.0.0/24
```

### Avoid Overlapping Tunnel IPs

Each WireGuard peer should receive unique tunnel addresses.

### Maintain Route Awareness

Each peer must know:

- Which networks exist
- Which peer owns them
- Which routes should traverse the tunnel

---

## Security Improvements Planned
### Future Improvements
- MFA-protected access gateway
- Internal DNS over tunnel
- ACL-based segmentation
- Reverse proxy integration
- Dynamic routing experimentation
- High availability relay nodes
- Terraform deployment automation
- Automated configuration backups

---

## Lessons Learned

This project reinforced several critical infrastructure concepts:

### Networking
- Routing vs firewalling are separate systems
- VLAN isolation is extremely important
- Public cloud networking differs significantly from home networking
### Linux
- Linux networking tools are essential
- Logs and CLI troubleshooting matter
- Understanding interfaces/routes/firewalls is mandatory
### Infrastructure Design
- Documentation is critical
- Small subnet mistakes create major issues
- Simplicity beats cleverness in networking

---

## Commands Reference
### Start WireGuard
```bash
sudo systemctl start wg-quick@wg0
```
### Enable at Boot
```bash
sudo systemctl enable wg-quick@wg0
```
###Restart Tunnel
```bash
sudo systemctl restart wg-quick@wg0
```
### View Logs
```bash
sudo journalctl -u wg-quick@wg0
```
