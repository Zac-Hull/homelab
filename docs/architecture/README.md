# Architecture Documentation

This directory contains architecture documentation, diagrams, and design references for the homelab environment.

Architecture documents should explain how major systems relate to each other, how workflows are structured, and how infrastructure components fit into the broader homelab design.

## Available Documents and Diagrams

| Item                                                                               | Purpose                                                                                           |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| [Documentation Workflow Diagram](diagrams/documentation-workflow.drawio.svg)       | Visual overview of the documentation, diagramming, Git, and administrative workflow.              |
| [Documentation Workflow Operations Guide](../operations/documentation-workflow.md) | Operational guide describing how documentation is authored, sanitized, diagrammed, and published. |

## Directory Structure

```text
docs/architecture/
├── README.md
└── diagrams/
    └── documentation-workflow.drawio.svg
```

## Scope

Architecture documentation may include:

* High-level homelab architecture
* Service relationships
* Network and VLAN design
* Monitoring and observability design
* Documentation workflows
* Deployment workflows
* Storage architecture
* Security boundaries
* Public-safe diagrams

## Diagram Standards

Architecture diagrams committed to this repository should be public-safe.

Use role-based labels where possible.

Examples:

| Internal Detail      | Public-Safe Label     |
| -------------------- | --------------------- |
| `doc01`    | Documentation Host    |
| `mon01`          | Monitoring Host       |
| `mbe01`          | Media Backend Host    |
| `media01`         | Media App Host        |
| Internal DNS names   | Generic service names |
| Private IP addresses | Placeholder addresses |

## Do Not Commit

Do not commit diagrams or architecture notes containing:

* Private IP address maps
* Internal DNS records
* Full VLAN layouts
* Firewall rules that expose internal topology
* VPN tunnel details
* SSH keys
* Secrets, passwords, tokens, or webhook URLs
* Unsanitized service inventories
* Sensitive storage paths

## Recommended Review Before Commit

Before committing architecture documentation or diagrams, review for sensitive information:

```bash
grep -RniE "10\.|192\.168|172\.16|password|token|secret|webhook|private key|BEGIN OPENSSH|docs\.lab|8081" docs/architecture/
```

Review all matches before committing. Some matches may be harmless, but they should be checked intentionally.

## Related Areas

* [`docs/operations/`](../operations/) — operational workflows and recurring administrative processes
* [`docs/services/`](../services/) — service-specific documentation
* [`docs/networking/`](../networking/) — network-related documentation
* [`docs/security/`](../security/) — security practices and hardening notes
* [`docs/storage/`](../storage/) — storage layout, backup, and capacity documentation

