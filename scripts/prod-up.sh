#!/usr/bin/env bash
set -euo pipefail

# Run production-like stack (no hot reload) from bash-compatible shells
COMPOSE_FILES=("docker-compose.yml" "docker-compose.prod.yml")

ARGS=()
for f in "${COMPOSE_FILES[@]}"; do
  ARGS+=( -f "$f" )
done

exec docker compose "${ARGS[@]}" up --build
