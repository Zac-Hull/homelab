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
http://documentation01-IP:8081
```

## Deployment

```
cd ~/homelab/docker/drawio
docker compose up -d
```

## Validation

```
docker compose ps
curl -I http://localhost:8081
```

Expected result:

- Container is running
- HTTP response is returned
- Draw.io UI loads in browser

## Storage Model

Draw.io is treated as a stateless application. Diagram files should be saved outside the container.

Recommended locations:

- Public-safe diagrams: `docs/architecture/diagrams/`
- Private/internal diagrams: Obsidian vault only

## Security Notes

- Do not expose publicly yet.
- Keep LAN-only until reverse proxy and identity management are in place.
- Do not commit diagrams containing sensitive IPs, hostnames, VLAN details, firewall rules, or VPN topology.

## Future Improvements

- Add reverse proxy route.
- Add internal DNS name such as `drawio.home.arpa`.
- Add service monitoring through Blackbox Exporter.
- Add dashboard panel in Grafana.
- Document diagram publishing workflow.