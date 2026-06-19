# Draw.io Self-Hosted Service

## Purpose

Draw.io is a self-hosted diagramming service used to create and maintain homelab architecture diagrams, service topology maps, and infrastructure planning visuals.

## Host

- VM: `documentation01`
- Runtime: Docker Compose
- Network: VLAN 20 / Servers
- Access: LAN-only

## Service Location

```text
~/homelab/docker/drawio/docker-compose.yml
```

## Access

```
http://documentation01-IP:$(DRAWIO_HOST_PORT)
```

## Deployment

```
cd ~/homelab/docker/drawio
docker compose up -d
```

## Validation

```
docker compose ps
curl -I http://localhost:$(DRAWIO_HOST_PORT)
```

Expected result:

- Container is running
- HTTP response is returned
- Draw.io UI loads in browser

## Monitoring

Draw.io is monitored through Blackbox Exporter using an HTTP probe from the monitoring stack.

The probe validates that the Draw.io web interface is reachable from the internal network and returns a successful HTTP response.

Primary metrics:

- `probe_success`
- `probe_http_status_code`
- `probe_duration_seconds`

Alerting is handled through the central Prometheus and Alertmanager stack.

## Diagram Storage Workflow

Draw.io is treated as a stateless web application. Diagram files should be saved outside the container.

Public-safe diagrams may be stored in the homelab repository after sanitization.

Private diagrams containing internal IP addresses, VLAN details, hostnames, firewall rules, VPN topology, or sensitive architecture details should stay in the private Obsidian vault.

Recommended locations:

```text
Public-safe:
docs/architecture/diagrams/

Private/internal:
vault-of-holding/30_Projects/Homelab/Diagrams/
```

## Storage Model

Draw.io is treated as a stateless application. Diagram files should be saved outside the container.

Storage locations:

- Public-safe diagrams: `docs/architecture/diagrams/`
- Private/internal diagrams: Obsidian vault

## Security Notes

- Keep LAN-only until reverse proxy and identity management are in place.
- Do not commit diagrams containing sensitive IPs, hostnames, VLAN details, firewall rules, or VPN topology.

## Future Improvements

- Add reverse proxy route.
- Add internal DNS name such as `drawio.home.arpa`.
- Document diagram publishing workflow.