## Standard Labels

Consistent labels are critical for Grafana dashboards and Loki queries.

Use these labels whenever possible:

| Label          | Purpose                   | Example         |
| -------------- | ------------------------- | --------------- |
| `job`          | Log source category       | `docker`        |
| `host`         | Node producing the logs   | `mediabe01`     |
| `service_name` | Container or service name | `jellyfin`      |
| `environment`  | Environment name          | `homelab`       |
| `site`         | Physical/logical site     | `home`          |
| `role`         | Node or service role      | `media-backend` |

Current Docker log collection should at minimum apply:

```hcl
labels = {
  job  = "docker",
  host = "<TARGET_HOSTNAME>",
}
```

Grafana queries should use `host`, not `hostname`.

Example:

```logql
{host="mediabe01"}
```

For cross-host queries:

```logql
{job="docker", host=~"$host"}
```
