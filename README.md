# Homelab Infrastructure

##Overview
Self-hosted homelab built on Proxmox with a segmented VLAN architecture.

##Components
- Proxmox Hypervisor
- Docker VM (docker01)
- Jellyfin VM (jellyfin01)
- NAS Storage

##Networking
- VLAN 1: Default
- VLAN 10: Trusted Devices
- VLAN 20: Servers
- VLAN 30: IoT
- VLAN 40: Storage
- VLAN 50: Guest
- VLAN 60: Cameras
- VLAN 100: External Devices
- VLAN 1000: Management

##Services
- whoami (test service for proof of concept)
- Jellyfin (planned service)
- Vaultwarden (planned service)

##Goals
- Learn and practice Infrastructure as Code
- Practice network segmentation and hardening
- Build self-hosted services securely

