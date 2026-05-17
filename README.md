# Homelab Infrastructure

## Overview
This homelab is a self-hosted infrastructure environment designed to simulate real-world production systems.

It leverages Proxmox virtualization, VLAN-based network segmentation, and centralized NAS storage to run and manage containerized services in a control environment.

**Focus Areas:**
- Network segmentation and security
- Containerized service deployment
- Infrastructure as Code (Git-based workflow)

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
     |--mediabe01 (media backend sorting)
     |--jellyfin01 (media server)
     |--wg-home-gw (VPS endpoint)
     `--documentation01
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
## Design Principles
- **Segmentation:** VLANs isolate traffic between services, storage, and clients
- **Separation of Concerns:** Dedicated VMs for Docker and media services
- **Scalability:** Architecture supports future expansion (Kubernetes, HA, etc.)
- **Persistence:** Centralized NAS ensures data durability across services

## Components
- **Proxmox VE** - hypervisor managing VMs and containers
- **Media Backend VM (mediabe01)** - hosts containerized metadata and sorting services via Docker Compose
- **Jellyfin VM (jellyfin01)** - dedicated media server for streaming workloads
- **UGOS NAS** - centralized storage for media, backups, and shared data

## Services

### Deployed
- **whoami** - test service validating container networking and routing

### In Progress
- **Jellyfin** - media server deployed on dedicated VM (currently works locally, working on reverse proxy for non-local access)
- **Draw.io** - service to diagram topologies and brainstorm layouts
- **AWS hosted domain** - static Astro portfolio site, deployed by GitHub Actions to S3, fronted by Cloudfront, Route 53, and ACM

### Planned
- **VaultWarden** - self-hosted password manager
- **Uptime Kuma** - service monitoring

### Roadmap
See [roadmap.md](/roadmap.md) for planned services and future improvements.
See [roadmap-standards.md]{/docs/stadards/roadmap-standards.md} for project stages, tags, and domains standards.

## Validation
- Verified SMB access from macOS clients
- Confirmed inter-VLAN routing between services and storage
- Tested container networking using `whoami` service
- Validated persistent storage mounts from NAS to Docker containers

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
