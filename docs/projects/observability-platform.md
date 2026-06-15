# Homelab Observability and Reliability Platform

## Overview

The Homelab Observability and Reliability Platform is a centralized monitoring and visibility project for the homelab environment.

The goal is to move the lab from a collection of individually checked systems into a more measurable operational environment. As more services, virtual machines, containers, storage paths, and network routes are added, visibility becomes necessary for maintenance, troubleshooting, and reliability.

This platform is designed to answer practical operational questions:

- Are core services reachable?
- Are hosts reporting metrics?
- Are containers healthy?
- Are public and internal endpoints responding correctly?
- Are infrastructure resources under pressure?
- What changed before a service became unhealthy?
- Where should troubleshooting start?

The platform currently focuses on Prometheus-based metrics collection, Grafana visualization, host metrics, service probing, and early alert routing. Future phases will add container metrics, centralized logging, and broader infrastructure telemetry.

---

## Goals
### Operational Goals

- Centralize infrastructure visibility
- Detect service failures earlier
- Reduce manual checking during troubleshooting
- Establish historical performance visibility
- Improve recovery decisions
- Track service availability
- Build dashboards that support operational response
- Document repeatable monitoring patterns

### Learning Goals

This project is also intended to build hands-on experience with:

- Prometheus scrape configuration
- Grafana dashboards
- Linux host metrics
- Docker-based monitoring services
- Exporter patterns
- Availability probing
- Internal service visibility
- Alerting workflows and future logging workflows

## Current Architecture
```text
Infrastructure / Services
        ↓
Exporters / Metrics Endpoints / Health Probes
        ↓
Prometheus Scraping
        ↓
Metrics Storage
        ↓
Grafana Dashboards
        ↓
Operational Review / Troubleshooting / Alerting
```

The current design keeps monitoring centralized while allowing metrics to be collected from distributed services and hosts.

Prometheus is responsible for scraping metrics and health targets. Grafana is responsible for visualization. Exporters expose host, service, or probe data in a format Prometheus can collect.

---

## Current Stack

| Component         | Purpose                                         | Status    |
| ----------------- | ----------------------------------------------- | --------- |
| Prometheus        | Metrics collection and storage                  | Active    |
| Grafana           | Visualization and dashboards                    | Active    |
| Node Exporter     | Linux host metrics                              | Expanding |
| Blackbox Exporter | HTTP, DNS, TCP, and endpoint probing            | Expanding |
| Alertmanager      | Alert routing and notifications                 | Expanding |
| cAdvisor          | Container metrics                               | Planned   |
| Loki              | Log aggregation                                 | Expanding |
| Promtail          | Log shipping into Loki                          | Expanding |
| Uptime Kuma       | Family-friendly service availability monitoring | Backlog   |

## Design Choices

This observability platform is intentionally built as a layered stack rather than a single all-in-one monitoring tool. The goal is to separate metrics collection, endpoint probing, visualization, container visibility, logging, and alerting so each component has a clear operational purpose.

### Prometheus and Grafana

Prometheus is the core metrics collector because it is widely used, well-documented, and designed around scrape-based time-series monitoring. It gives the lab a practical way to collect host, service, and exporter metrics over time.

Grafana is used as the visualization layer because it separates dashboarding from metrics collection. Prometheus stores and queries the data, while Grafana turns that data into dashboards that support troubleshooting and operational review.

Alternatives such as **VictoriaMetrics** and **Grafana Mimir** may be evaluated later if the environment needs better long-term retention, lower resource usage, or scalable querying. For now, Prometheus and Grafana provide the best balance of learning value, simplicity, and production-aligned patterns.

### Host and Service Visibility

**Node Exporter** provides Linux host metrics such as CPU, memory, disk, filesystem, network usage, load averages, and host uptime. This helps distinguish between a failing service and an unhealthy host.

**Blackbox Exporter** provides endpoint probing for HTTP, DNS, TCP, TLS, and availability checks. This matters because a host can be online while the actual service path is broken. Blackbox checks help validate the user-facing path rather than only the server state.

**Uptime Kuma** may still be added later as a simpler human-friendly status view, but it is not the core monitoring system. Blackbox Exporter fits better into the Prometheus metrics pipeline.

### Container Metrics, Logs, and Alerts

**cAdvisor** is planned for container-level metrics so Docker workloads can be monitored below the host level. This should help identify which containers are consuming resources or restarting unexpectedly.

**Loki and Alloy** provide centralized log aggregation. Metrics can show that something is wrong, while logs often explain why. Loki is preferred over heavier logging stacks like Elastic Stack or OpenSearch for now because it integrates well with Grafana and is a better fit for the current lab scale. **Promtail** was considered, but was rejected from this project because of its EOL status as of March 2, 2026.

**Alertmanager** was brought into the platform after the initial metrics and dashboards were stable enough to avoid noisy alerts. It is currently being tested and has passed the initial round of testing with Discord webhooks. Future improvements include email and push alerts.

### Why Not SaaS or All-in-One Monitoring?

A SaaS platform like **Datadog** would provide a polished industry-standard experience, but it can become costly for a homelab and would hide much of the infrastructure this project is meant to teach.

An all-in-one tool would be simpler at first, but this project is intentionally using common observability components to build hands-on experience with metrics, exporters, dashboards, probes, logs, and alerts.

Each tool should earn its place in the stack. The goal is not to collect monitoring tools; the goal is to build a practical observability platform that supports real troubleshooting and reliability work.

---

## Initial Monitoring Targets
### Infrastructure
- Proxmox hosts
- Ubuntu Server VMs
- Docker hosts
- NAS-backed services
- WireGuard gateway or relay paths
- Monitoring host itself

### Services
- Docker containers
- Reverse proxy
- Jellyfin
- SMB/NFS services
- DNS services
- Monitoring stack itself

### Future Targets
- DNS infrastructure
- Network device telemetry

## Metrics Categories
### System Metrics

System metrics are collected from Linux hosts using exporters such as Node Exporter.

Useful metrics include:

- CPU utilization
- Memory usage
- Disk utilization
- Disk I/O
- Filesystem pressure
- Network throughput
- Load averages
- Uptime
- Host availability

These metrics help identify whether an issue is service-specific or caused by underlying host pressure.

### Container Metrics

Container metrics are planned through cAdvisor or similar tooling.

Target container metrics include:

- Running containers
- Stopped containers
- Restart counts
- CPU usage per container
- Memory usage per container
- Network usage per container
- Container filesystem usage

This will become more important as more services are deployed through Docker Compose.

### Service Availability

Service availability is monitored through endpoint probing.

Examples:

- HTTP response success/failure
- HTTP status codes
- DNS resolution behavior
- TCP port reachability
- TLS endpoint behavior
- Probe latency
- Internal versus external reachability

Blackbox Exporter is used for this style of monitoring.

---

## Application Interconnection
### Blackbox Exporter Integration

Blackbox Exporter adds service-level probing to the monitoring stack.

Instead of only monitoring whether a host is alive, Blackbox Exporter can test whether a specific service endpoint behaves correctly.

Example use cases:

- Confirm a web service returns a successful HTTP response
- Confirm a DNS endpoint resolves
- Confirm a TCP service is reachable
- Compare internal and external endpoint behavior
- Monitor public-facing services from inside the lab

This is especially useful for validating services that depend on routing, DNS, certificates, reverse proxies, or CloudFront-style edge delivery.

### Blackbox Exporter Troubleshooting Note

During initial testing, a probe against `zachull.com` did not behave as expected because the probe attempted to use IPv6 while the working path required IPv4, discovered via PromQL querying.

The fix was to adjust the probe configuration so the check used the expected IP protocol path, then validate the result in Prometheus and Grafana.

This was an important lesson because the endpoint itself was not necessarily down. The monitoring behavior needed to match the actual network path being tested.

Lesson:

> Monitoring checks are only useful when the probe behavior matches the service path being validated.

### Alertmanager and Discord Notification Integration

Alertmanager adds the first notification layer to the observability stack.

Prometheus is responsible for evaluating alert rules. Alertmanager receives those alerts, groups or routes them, and sends notifications to the configured destination.

For this phase, Discord was used as the notification target because it provides a simple, visible channel for homelab alerts without requiring a full paging system.

The initial validation path was:

```text
Service target unavailable
        ↓
Prometheus alert rule fires
        ↓
Alertmanager receives alert
        ↓
Discord notification is delivered
        ↓
Service restored
        ↓
Alert resolves
```

A successful test was performed by intentionally taking down a monitored service, confirming that the alert fired, then restoring the service and confirming the alert resolved.

Lesson:

> Alerting is most useful when both the fire and resolve paths are validated.

### Prometheus Design

Prometheus is the central metrics collector.

Its responsibilities include:

- Scraping exporters
- Storing time-series metrics
- Tracking target health
- Providing query access through PromQL
- Feeding Grafana dashboards
- Supporting alert rules

Prometheus scrape targets should be added intentionally and documented as the monitoring environment grows.

### Prometheus Target Patterns

Targets should be grouped by function where possible.

Example target categories:

- linux_hosts
- docker_hosts
- service_probes
- network_services
- monitoring_stack

A consistent target naming pattern makes dashboards and alerts easier to maintain.

### Grafana Design

Grafana is used as the visualization layer.

Dashboard goals:

- Show high-level service health quickly
- Provide enough detail for troubleshooting
- Avoid noisy panels that do not drive decisions
- Separate infrastructure views from service views
- Support future alert review and incident analysis

Initial dashboard categories:

- Host overview
- Service availability
- Docker/container health
- Public endpoint checks
- Monitoring stack health

## Segmentation and Security

The observability platform is intended to run inside the services VLAN of the homelab network.

Key design considerations:

- Keep dashboards internal-only where possible
- Avoid exposing Grafana directly to the public internet
- Require authentication for dashboard access
- Restrict exporter access to required ports only
- Avoid sending unnecessary sensitive data into dashboards
- Monitor across VLANs only where explicitly allowed
- Document firewall and routing dependencies

The platform should improve visibility without becoming an unnecessary exposure point.

## Reliability Goals

The platform exists to improve operational reliability.

Target improvements:

- Faster detection of service failures
- Faster diagnosis of degraded systems
- Better understanding of host resource pressure
- Better visibility into service dependencies
- Reduced guesswork during troubleshooting
- Cleaner recovery documentation
- Better confidence before and after infrastructure changes

Key reliability concepts:

- Mean time to detection
- Mean time to recovery
- Service health
- Historical trends
- Alert quality
- Repeatable troubleshooting

---

## Implementation Status
### Completed / Active
- Prometheus deployed as the primary metrics collector
- Grafana deployed as the dashboard layer
- Node Exporter integrated for initial Linux host metrics, with coverage expanding
- Blackbox Exporter integrated for service probing
- Initial dashboards created or under active development
- Basic monitoring project documentation created
- Troubleshooting notes captured for endpoint probing behavior
- Loki and Alloy integrated for centralized logging
- Alertmanager integrated for initial alert routing and Discord notification testing

### In Progress
- Expanding host coverage
- Improving dashboards
- Cleaning up scrape target organization
- Adding repeatable documentation for future monitoring targets
- Validating which services should be monitored by metrics, probes, or both
- Expand Alertmanager routing and notification coverage
- Create service-specific runbooks

### Planned
- Add cAdvisor for Docker container metrics
- Add Uptime Kuma or similar status monitoring
- Add NAS and network device telemetry
- Add DNS service monitoring
- Add UPS/environmental monitoring if supported

---

## Issues Encountered
### Monitoring Behavior Did Not Always Match Service Behavior

The Blackbox Exporter IPv6/IPv4 issue showed that a failed probe does not always mean the service itself is broken.

The probe path, DNS response, IP protocol behavior, and actual user path all matter.

Lesson:

> A monitoring failure should be investigated as both a possible service issue and a possible monitoring configuration issue.

### Dashboards Need Purpose

It is easy to add panels because metrics are available. That does not automatically make the dashboard useful.

Grafana dashboards should answer operational questions.

**Better questions:**

- Is the service reachable?
- Is the host under pressure?
- Is the issue recent or recurring?
- Which dependency is likely involved?
- What should I check next?

Lesson:

> A dashboard should support a decision, not just display data.

### Monitoring Should Be Built Before Major Failures

The value of monitoring is highest when it is already in place before an outage.

Adding observability after something breaks is still useful, but historical data is missing.

Lesson:

> Historical metrics become useful only after they have been collected for a while.

---

## High Points
### The Homelab Became More Measurable

Before this project, troubleshooting depended more heavily on manual checks and memory.

With Prometheus and Grafana in place, the lab now has a foundation for measurable service operations.

### Service Health Became Easier to Validate

Blackbox Exporter made it possible to test whether services and endpoints are actually reachable, not just whether a host exists.

This is especially useful for services that depend on DNS, routing, reverse proxies, TLS, or external access paths.

### The Project Creates a Foundation for Future Automation

Metrics and health checks can eventually support:

- alerting
- maintenance decisions
- capacity planning
- automated remediation
- SLA-style service tracking
- incident documentation

## Low Points
### Observability Can Get Noisy Quickly

Monitoring tools can produce a lot of data quickly. Without clear dashboard and alert design, the system can become noisy instead of useful.

### The Stack Adds More Services to Maintain

Prometheus, Grafana, exporters, and future logging/alerting tools are themselves services that require maintenance.

The monitoring stack must also be monitored.

### Network Segmentation Adds Complexity

Monitoring across VLANs or isolated networks requires deliberate firewall and routing decisions.

This is valuable, but it also means monitoring design must respect the security model of the lab.

---

## Planned Future Improvements
### Monitoring Expansion

Planned monitoring expansion:

- cAdvisor for Docker metrics
- NAS telemetry
- SNMP monitoring
- Proxmox metrics
- DNS service health
- Network switch/AP telemetry
- UPS monitoring
- Environmental monitoring
- Remote access path monitoring

### Logging

Planned migration toward centralized logging using:

- Grafana log exploration

Goals:

- Centralized service logs
- Easier incident review
- Correlation between logs and metrics
- Better troubleshooting after failures

### Alerting

Planned integrations:

- Email notifications
- Mobile push notifications

Alerting should be added carefully. The goal is useful signal, not noise. My RTLS work has reinforced that alert fatigue is a real operational risk.

### Documentation

Planned documentation:

- Blackbox Exporter setup guide
- Monitoring target template
- Dashboard design notes
- Alert rule documentation
- Troubleshooting runbooks

## Validation Checklist

As monitoring expands, each monitored target should be validated.

For each target:
```text
Target name:
Target type:
Exporter or probe:
Expected endpoint:
Expected port:
Network path:
Dashboard panel:
Alert rule:
Runbook link:
Last validated:
```

This keeps monitoring targets understandable over time.

---

## Current State

The observability platform is active and expanding.

Current state:

- Core monitoring architecture is defined.
- Prometheus and Grafana are the foundation.
- Host and endpoint monitoring are being added.
- Blackbox Exporter is being used for service probing.
- Future phases will expand alerting and add container metrics and logs.

The next major step is to expand coverage while keeping the configuration documented and repeatable.

## Long-Term Goals
- Infrastructure trend analysis
- Capacity planning
- Automated remediation
- Configuration drift detection
- SLA-style service tracking

## Lessons Learned
- Visibility becomes increasingly important as infrastructure grows
- Monitoring should be implemented before major failures occur
- Dashboards are most effective when they answer specific operational questions
- Historical metrics improve troubleshooting significantly
- Reliability engineering starts with observability
- Failed probes need investigation before assuming a service is down
- Private/internal dashboards are preferable unless there is a strong reason to expose them
- Monitoring should be treated as infrastructure, not decoration

## Related Documentation

- Prometheus Setup
- Grafana Setup
- Blackbox Exporter Setup
- Docker Compose Setup
- Inter-VLAN Routing
- Standard VM Setup