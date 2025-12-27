#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Go up 2 levels: Run -> scripts -> Infrastructure
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Set the path to the .env file
export ENV_FILE="$PROJECT_DIR/.env"

# Run production-like stack (no hot reload) from bash-compatible shells
cd "$PROJECT_DIR"

COMPOSE_DIR="docker-compose"
COMPOSE_FILES=("docker-compose.yml" "docker-compose.prod.yml")

ARGS=(--env-file "$ENV_FILE")
for f in "${COMPOSE_FILES[@]}"; do
  ARGS+=( -f "$COMPOSE_DIR/$f" )
done

exec docker compose "${ARGS[@]}" up --build
