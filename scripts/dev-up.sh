#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Starting Passion Tree Development Stack"

# Check if .env exists
if [ ! -f "$PROJECT_DIR/.env" ]; then
    echo "⚠️  .env file not found! Creating from .env.example..."
    if [ -f "$PROJECT_DIR/.env.example" ]; then
        cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
        echo "📝 Please edit .env and add your GROQ_API_KEY"
        exit 1
    else
        echo "❌ .env.example not found!"
        exit 1
    fi
fi

# Check if GROQ_API_KEY is set
if grep -q "changeme-groq-key" "$PROJECT_DIR/.env"; then
    echo "⚠️  Warning: GROQ_API_KEY is still set to 'changeme-groq-key'"
    echo "📝 Please update your .env file with a real API key"
fi

# Run dev stack (connects directly to Azure SQL Database)
cd "$PROJECT_DIR"
COMPOSE_FILES=("docker-compose.yml" "docker-compose.override.yml")

ARGS=()
for f in "${COMPOSE_FILES[@]}"; do
  ARGS+=( -f "$f" )
done

echo "🐳 Starting containers..."
exec docker compose "${ARGS[@]}" up --build --no-cache
