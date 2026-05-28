# documentation01 Node Exporter

This Compose file deploys Node Exporter on `documentation01` so Prometheus can scrape host-level metrics from the node.

Live deployment path:

```text
/opt/docker/node-exporter/docker-compose.yml
```

Prometheus target:
```text
{{ $DOC01-NODE-EXPORTER-TARGET }}
```
