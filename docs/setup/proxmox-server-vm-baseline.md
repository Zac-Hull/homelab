# Proxmox VM Baseline Setup

## Overview

This document defines the standard process for creating and preparing new virtual machines in Proxmox.

The goal is to create consistent, secure, and repeatable VM deployments for homelab services.

---

## Objectives

- Standardize VM creation
- Enable SSH-based administration
- Reduce configuration drift
- Prepare VMs for Git-based documentation and automation
- Support future identity-management-based key distribution

---

## Standard VM Naming

Use lowercase hostnames with numbered suffixes.

Examples:

| VM Name | Purpose |
|---|---|
| `docker01` | General Docker host |
| `mediabe01` | Backend media services |
| `documentation01` | Git/documentation workflow |
| `jellyfin01` | Media frontend |
| `wg-home-gw` | WireGuard home gateway |

---

## Proxmox VM Creation

### Recommended Defaults

| Setting | Recommended Value |
|---|---|
| OS | Ubuntu Server LTS |
| CPU | 2+ cores |
| RAM | 2–4 GB minimum |
| Disk | 32 GB minimum |
| Network | VirtIO |
| BIOS | OVMF or SeaBIOS |
| Storage | Local-lvm or appropriate VM storage |
| VLAN | Assigned based on VM role |

---

## VLAN Placement

| VM Type | VLAN |
|---|---|
| Management tooling | VLAN 1000 |
| General services | VLAN 20 |
| Storage-facing workloads | VLAN 40 access as needed |
| External/untrusted testing | VLAN 100 |

---

## Ubuntu Server Installation

During installation:

- Create a non-root admin user
- Enable OpenSSH Server
- Use a clear hostname
- Avoid installing unnecessary packages
- Use DHCP initially unless static IP is required immediately

Example hostname:

```text
documentation01
```

## Initial Login

After installation, SSH into the VM:
```bash
ssh administrator@<vm-ip-address>
```

Update the system:
```bash
sudo apt update && sudo apt upgrade -y
```

Install baseline packages:
```bash
sudo apt install -y curl git nano vim htop net-tools ca-certificates gnupg lsb-release
```

## SSH Key-Based Access
### Current Method

Currently, SSH public keys are pulled from GitHub.

This allows newly created VMs to trust the same public keys used for GitHub authentication.

Later, this will be replaced by the identity management stack.

### Generate SSH Key on Admin Workstation

From the admin workstation:
```bash
ssh-keygen -t ed25519 -C "admin-workstation-to-<vm-name>"
```

Recommended filename:
```bash
~/.ssh/<vm-name>-admin-ed25519
```

Example:
```bash
ssh-keygen -t ed25519 -C "admin-workstation-to-documentation01" -f ~/.ssh/documentation01-admin-ed25519
```

This creates:
```text
~/.ssh/documentation01-admin-ed25519
~/.ssh/documentation01-admin-ed25519.pub
```

### Install Public Key on VM
**Option 1:** Copy Key with ssh-copy-id

From the admin workstation:
```bash
ssh-copy-id -i ~/.ssh/documentation01-admin-ed25519.pub administrator@<vm-ip-address>
```

Then test:
```bash
ssh -i ~/.ssh/documentation01-admin-ed25519 administrator@<vm-ip-address>
```

**Option 2:** Pull Public Keys from GitHub

From the VM:
```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
curl https://github.com/Zac-Hull.keys >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Then test login from the admin workstation:
```bash
ssh administrator@<vm-ip-address>
```

## SSH Client Config on Admin Workstation

Add a host entry:
```bash
nano ~/.ssh/config
```

Example:
```sshconfig
Host documentation01
    HostName <vm-ip-address>
    User administrator
    IdentityFile ~/.ssh/documentation01-admin-ed25519
    IdentitiesOnly yes
```

Fix permissions:
```bash
chmod 600 ~/.ssh/config
```

Then connect with:
```bash
ssh documentation01
```

### VM-to-GitHub SSH Key

For VMs that need to push to GitHub, generate a dedicated SSH key on the VM.

Example for documentation01:
```bash
ssh-keygen -t ed25519 -C "documentation01-github" -f ~/.ssh/documentation01-github-ed25519
```

Fix permissions:
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/documentation01-github-ed25519
chmod 644 ~/.ssh/documentation01-github-ed25519.pub
```

Display the public key:
```bash
cat ~/.ssh/documentation01-github-ed25519.pub
```

Add the public key to:
```text
GitHub → Settings → SSH and GPG keys
```

Create SSH config:
```bash
nano ~/.ssh/config
```
```sshconfig
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/documentation01-github-ed25519
    IdentitiesOnly yes
```

Fix config permissions:
```bash
chmod 600 ~/.ssh/config
```

Test:
```bash
ssh -T git@github.com
```

Expected result:
```text
Hi Zac-Hull! You've successfully authenticated, but GitHub does not provide shell access.
```

### Git Setup

Install Git:
```bash
sudo apt install -y git
```

Set Git identity:
```bash
git config --global user.name "Zachery Hull"
git config --global user.email "<github-email>"
```

Clone repo:
```bash
git clone git@github.com:Zac-Hull/homelab.git
```

Validate:
```bash
cd homelab
git status
```

## Sudo Access

Confirm the admin user has sudo access:
```bash
groups
```

Expected output should include:
```bash
sudo
```

If needed:
```bash
sudo usermod -aG sudo administrator
```

Log out and back in for group changes to apply.

## Basic Hardening
### Disable Password SSH Login

Edit SSH config:
```bash
sudo nano /etc/ssh/sshd_config
```

Recommended settings:
```text
PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
```

Restart SSH:
```bash
sudo systemctl restart ssh
```

Before closing the current session, open a second terminal and verify key-based login works.

## Timezone and Hostname

Set hostname if needed:
```bash
sudo hostnamectl set-hostname <vm-name>
```

Check timezone:
```bash
timedatectl
```

Set timezone if needed:
```bash
sudo timedatectl set-timezone America/New_York
```

## Network Validation

Check IP address:
```bash
ip addr
```

Check default route:
```bash
ip route
```

Test internet access:
```bash
ping -c 4 1.1.1.1
```

Test DNS:
```bash
ping -c 4 github.com
```

## Snapshot After Baseline

Once the VM is updated, SSH is configured, and baseline packages are installed, create a Proxmox snapshot.

Suggested snapshot name:
```text
baseline-clean-install
```

Snapshot notes:
```text
Clean Ubuntu baseline with SSH key access, system updates, and baseline packages installed.
```

Validation Checklist
 VM created in Proxmox
 Correct VLAN assigned
 Ubuntu Server installed
 Hostname configured
 Admin user created
 System updated
 SSH key access configured
 Password SSH login disabled
 Git installed
 GitHub SSH access validated, if required
 Network connectivity validated
 DNS resolution validated
 Baseline snapshot created

---

## Future Identity Management Plan

The current key distribution model relies on GitHub-hosted public keys.

Future state:

- SSH keys managed by internal identity management stack
- Centralized user/group control
- Easier onboarding/offboarding
- Reduced manual key management
- Better auditability

Potential future tools:

- Authentik
- FreeIPA
- LDAP-backed access
- SSO-aware tooling
- Centralized secrets management

---

## Lessons Learned
- VM baselines reduce rebuild time
- SSH key access should be configured early
- Snapshots should be created after clean baseline setup
- Dedicated keys per role improve clarity and revocation
- GitHub key pulls are useful temporarily but should later be replaced by centralized identity management