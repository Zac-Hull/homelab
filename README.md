# Homelab Infrastructure

## Overview
Self-hosted infrastructure built on Proxmox with a segmented VLAN architecture, designed to simulate real-world environments.

Focus: networking, containerization, and infrastructure as code

## Architecture
```
   ISP
    |
   ONT
    |
[Firewall/Router]
    |
|--VLAN 1 (Default)
|--VLAN 10 (Trusted Devices)
|--VLAN 20 (Servers)
     |--docker01 (containers)
     `--jellyfin01
|--VLAN 30 (IoT)
|--VLAN 40 (Storage)
     `--NAS
|--VLAN 50 (Guest)
|--VLAN 60 (Cameras)
|--VLAN 100 (External Devices)
`--VLAN 1000 (Management)
     |--Access Switch
     `--Wireless Access Points
```
## Components
- Proxmox Hypervisor - organization of virtualization
- Docker VM (docker01) - hosts containerized services using Docker Compose
- Jellyfin VM (jellyfin01) - dedicated host for media playback services
- NAS Storage - storage pool for media, documents, and backups for system restoration

## Services

### Deployed
- whoami - test service validating container networking and routing

### In Progress
- Jellyfin - media server deployed on dedicated VM

### Planned
- VaultWarden - self-hosted password manager
- Uptime Kuma - service monitoring

### Roadmap
See [roadmap.md](docs/roadmap.md) for planned services and future improvements.

## Tech Stack
- Proxmox VE
- Ubuntu Server
- Docker & Docker Compose
- VLAN-based network segmentation
- Git & GitHub (IaC)

## Hardware
- Router/Firewall/Access Switch: Unifi UDM-SE
- NAS: UGreen NASync DXP4800 Plus
- Hypervisor Node: Beelink EQR6
- Wireless APs: Unifi U7-Pro

## Goals
- Learn and practice Infrastructure as Code
- Practice network segmentation and hardening
- Build self-hosted services securely

## Key Learnings
- Implemented VLAN segmentation for network isolation
- Deployed containerized services using Docker Compose
- Managed infrastructure as code using Git
- Configured SSH-based authentication for secure GitHub access
