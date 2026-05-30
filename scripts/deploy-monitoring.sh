#!/usr/bin/env bash
set -euo pipefail

rsync -avz \
  --exclude ".git/" \
  --exclude ".env" \
  --exclude "*.env" \
  --exclude "secrets/" \
  "$HOME/homelab/docker/monitoring/" monitor01:/opt/docker/monitoring/

ssh monitor01 '
  cd /opt/docker/monitoring &&
  docker compose config &&
  docker exec prometheus promtool check config /etc/prometheus/prometheus.yml &&
  docker exec prometheus promtool check rules /etc/prometheus/rules/alerts.yml &&
  docker compose up -d
'
