set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Go up 2 levels: Run -> scripts -> Infrastructure
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo ":rocket: Starting Passion Tree Development Stack"

# Check if .env exists
if [ ! -f "$PROJECT_DIR/.env" ]; then
    echo ":warning:  .env file not found! Creating from .env.example..."
    if [ -f "$PROJECT_DIR/.env.example" ]; then
        cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
        echo ":pencil: Please edit .env and add your GROQ_API_KEY"
        exit 1
    else
        echo ":x: .env.example not found!"
        exit 1
    fi
fi

# Check if GROQ_API_KEY is set
if grep -q "changeme-groq-key" "$PROJECT_DIR/.env"; then
    echo ":warning:  Warning: GROQ_API_KEY is still set to 'changeme-groq-key'"
    echo ":pencil: Please update your .env file with a real API key"
fi

# Run dev stack (connects directly to Azure SQL Database)
cd "$PROJECT_DIR"
COMPOSE_DIR="docker-compose"
COMPOSE_FILES=("docker-compose.yml" "docker-compose.override.yml")

ARGS=(--env-file "$PROJECT_DIR/.env")
for f in "${COMPOSE_FILES[@]}"; do
  ARGS+=( -f "$COMPOSE_DIR/$f" )
done

# Ask user for build or up only
read -p "Do you want to build images before starting containers? (y/N): " BUILD_CHOICE

if [[ "$BUILD_CHOICE" =~ ^[Yy]$ ]]; then
    DOCKER_CMD="up --build"
else
    DOCKER_CMD="up"
fi

echo "Starting containers ($DOCKER_CMD mode)..."
exec docker compose "${ARGS[@]}" $DOCKER_CMD