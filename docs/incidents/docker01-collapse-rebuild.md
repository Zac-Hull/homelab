# docker01 Collapse and Rebuild

## Overview

This document covers the mistakes, failure, investigation, containment, and rebuild of the original `docker01` VM in the homelab environment.

The purpose of this writeup is to document what happened, what I was attempting to do, what went wrong, how the rest of the Proxmox environment was protected, and what changes were made during the rebuild.

---

## Environment

- **Hypervisor:** Proxmox VE
- **Affected VM:** `docker01`
- **Role:** Docker host for containerized homelab services
- **Related Systems:**
	- Proxmox host
	- Jellyfin VM (`jellyfin01`)
	- WireGuard gateway VM (`wg-home-gw`)
	- NAS / storage services

---

## Original Goal

The original goal was to continue expanding the homelab environment by running self-hosted services from `docker01`.

Planned or active services included:

- Reverse proxy testing
- `whoami` test container
- Jellyfin-related service work
- Documentation and GitHub workflow
- Future services such as VaultWarden, Uptime Kuma, and Draw.io

---

## What Happened

The original `docker01` VM became unstable or unusable during service deployment and networking work.

At the time, the VM was responsible for multiple experimental services and had accumulated configuration changes during early homelab development.

The thinLVM was expanded to allow for more data storage, but the disk was filled completely and overutilized the physical space of the host disk.

Without double checking, the thinLVM storage was shrunken back down, causing a data overflow that locked the storage at the host kernel level.

The failure created an opportunity to reassess the environment rather than continue repairing a messy or unreliable VM.

---

## Symptoms

- `docker01` was no longer trusted as a stable service host, predicated by several download and data transfer drops
- Service deployment became difficult to validate
- Configuration state was unclear
- The VM had become harder to troubleshoot than to rebuild
- Risk existed that additional changes could impact the wider Proxmox environment

---

## Initial Assessment

The issue appeared isolated to `docker01`.

Before rebuilding, the rest fo the Proxmox host and other VMs needed to be protected to avoid turning a singular VM problem into a larger infrastructure issue.

Key concern:

> Preserve the healthy parts of the environment before making additional changes.

---

## Containment and Protection Steps

### 1. Stopped Expanding the Broken VM

Further service deployment on `docker01` was paused.

This prevented additional configuration drift and reduced the chance of making the problem harder to diagnose.

---

### 2. Reviewed Remaining VM State

Other VMs were checked to confirm that the failure was limited to `docker01`.

Systems reviewed included:

- Proxmox host
- Jellyfin VM
- WireGuard gateway VM

---

### 3. Created Backups

Backups were created for the remaining important VMs before continuing.

This provided a rollback point in case changes during the rebuild affected the broader environment.

Protected systems included:

- Proxmox-related VM state
- Jellyfin VM
- WireGuard gateway VM

An intentional decision was made to not backup the Proxmox host so that the thinLVM storage issue was not persistent if a new image was required.

---

### 4. Preserved Known-Good Infrastructure

Rather than changing the entire environment, the rebuild was scoped specifically around replacing `docker01`.

The goal was to keep known-good systems stable while rebuilding only the failed service host.

---

## Rebuild Strategy

The decision was made to rebuild instead of repair.

Reasons:

- Faster than untangling unknown configuration issues
- Cleaner baseline
- Better documentation opporitunity
- Reduced long-term technical debt
- Allowed improved segmentation and service separation

---

## Rebuild Steps

### 1. Created New VMs

Two new VMs were created in Proxmox to replace the singular failed Docker host.

**`mediabe01`**
Media Backend VM purpose:

- Host reproducible Docker Compose deployments
- Run containerized services
- Serve as a clean base for future Compose-managed media applications

**`documentation01`**
Documentation VM purpose:

- Clone GitHub repositories for VM-based CLI workflow
- Markdown editing
- Diagram storage / reports

This created a separation of duties that reduce configuration sprawl.

---

### 2. Installed Ubuntu Server

Ubuntu Server was installed as the operating system for the rebuilt media backend host.

Basic setup included:

- User account creation
- SSH access
- System updates
- Basic package installation

Examples:
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl ca-certificates gnupg lsb-release```

---

### 3. Docker was installed on `mediabe01`

Docker was installed on `mediabe01` with the following commands after the appropriate keys were generated and directories were created:
```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update
sudo apt install -y docker-ce docker-ce-cli conainerd.io docker-buildx-plugin docker-compose-plugin```

The user was then added to the Docker group to allow Docker commands without using super user commands.
```sudo usermod -aG docker $USER```

After this, the session needed to be refreshed for the group membership to apply.

---

### 4. Created Docker Directory Structure

A clean Docker working directory was created.

Example:
```sudo mkdir -p /opt/docker
sudo chown -R $USER:$USER /opt/docker```

This location became the base of operation for Docker Compose files and service configuration.

---

### 5. Validated Docker Functionality

A simple test container was deployed to confirm that Docker, networking, and routing worked correctly.

Example service:
- `whoami`

Purpose:
- Validate container deployment
- Confirm internal network reachability
- Confirm reverse proxy testing path later

---

## Further Segmentation

After the rebuild, services were separated more intentionally.

### Previous Pattern

`docker01` was becoming a general-purpose host for too many unrelated tasks.

### Improved Pattern

The environment moved toward clearer separation of responsibilities:
- `mediabe01` for containerized media sorting, compression, indexing, and transport
- `jellyfin01` for a dedicated media server VM
- `documentation01` for a dedicated Git/documentation workflow VM
- Storage isolated on the Storage VLAN
- Infrastructure management isolated on the management VLAN

---

## Security and Stability Improvements

### Improvements Made

- Reduced dependency on a single VM
- Createdc backups/snapshots before further changes
- Separated documentation from service hosting
- Improved VM role clarity
- Began documenting the environment in Git
- Started building `/docs` structure for repeatable operations

---

## Lessons Learned

### Rebuilds Can Be Better Than Repairs

When a system is early in its lifecycle and poorly understood, rebuilding can be faster and safer than attempting to repair unknown configuration drift.

---

### Snapshot Before Risky Changes

Before making major changes, create a rollback point.

This is especially important when multiple services depend on the same infrastructure.

---

### Separate Roles Early

A single VM can quickly become messy when it handles too many responsibilities.

Dedicated VMs make troubleshooting easier.

---

### Documentation Should Follow the Work

The best time to document an issue is immediately after solving it.

Details are easier to remember, and the documentation becomes more accurate.

---

### Validate With Simple Services First

Using a basic test container like `whoami` is useful before deploying larger services.

It confirms that Docker and networking are working before adding complexity.

---

### Future Improvements

- Define standard VM build checklist
- Create a Docker host baseline setup guide
- Add backup schedule documentation
- Document restore testing procedure
- Add monitoring with Uptime Kuma
- Add reverse proxy documentation
- Document firewall reles between VLANs
- Create service deployment templates for Docker Compose
