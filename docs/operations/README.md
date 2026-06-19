# Operations Documentation

This directory contains operational documentation for maintaining, managing, and improving the homelab environment.

Operations documents focus on recurring workflows, administrative processes, maintenance routines, and day-to-day practices used to keep the homelab understandable and reliable.

## Available Documents

| Document                                            | Purpose                                                                                          |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| [Documentation Workflow](documentation-workflow.md) | Describes how homelab documentation is authored, diagrammed, reviewed, sanitized, and published. |

## Scope

Documents in this directory should describe operational practices such as:

* Documentation workflows
* Change management
* Maintenance routines
* Backup and restore procedures
* Monitoring and alerting operations
* Service onboarding workflows
* Incident response practices
* Administrative review checklists

## Public-Safe Documentation Standards

Operational documentation should avoid committing sensitive internal details unless they are intentionally sanitized.

Not to be committed:

* Secrets, tokens, passwords, or webhook URLs
* SSH private keys
* VPN private keys or tunnel secrets
* Internal-only DNS records
* Private IP address maps
* Unsanitized firewall rules
* Unsanitized service inventories
* Full internal network diagrams

Use role-based labels where possible.

Examples:

| Internal Detail      | Public-Safe Label                   |
| -------------------- | ----------------------------------- |
| Specific hostnames   | Role-based host names               |
| Private IP addresses | Placeholder addresses               |
| Real service ports   | Placeholder ports when not relevant |
| Internal DNS names   | Generic service names               |
| Real config files    | Sanitized example files             |

## Recommended Review Before Commit

Before committing operational documentation, review changes for sensitive information:

```bash
grep -RniE "password|token|secret|webhook|private key|BEGIN OPENSSH|10\.|192\.168|172\.16" docs/operations/
```

Review all matches before committing. Some matches may be harmless, but they should be checked intentionally.

## Related Areas

* [`docs/architecture/`](../architecture/) — architecture diagrams and structural design documentation
* [`docs/services/`](../services/) — service-specific documentation
* [`docs/setup/`](../setup/) — setup and installation procedures
* [`docs/security/`](../security/) — security practices and hardening notes
* [`docs/troubleshooting/`](../troubleshooting/) — known issues and resolution notes

