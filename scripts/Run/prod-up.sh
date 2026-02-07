#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Passion Tree - Production CI/CD Deploy Script
# Build -> Push to ACR -> Deploy to Azure Container App
# ============================================================

# --- 0. Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
BACKEND_DIR="$(dirname "$PROJECT_DIR")/Passion-Tree-Backend"
AI_DIR="$(dirname "$PROJECT_DIR")/Passion-Tree-AI"

export ENV_FILE="$PROJECT_DIR/.env"

# Azure Configuration
ACR_NAME="passiontreecontainerregistry"
ACR_SERVER="${ACR_NAME}.azurecr.io"
RESOURCE_GROUP="passion-tree"
SUBSCRIPTION_ID="739c1374-eb18-4fe9-b200-c7ed0140fa24"

BACKEND_APP_NAME="backend-go"
BACKEND_IMAGE_NAME="backend-app"
AI_APP_NAME="ai-fastapi"
AI_IMAGE_NAME="ai-app"

TIMESTAMP=$(date +%Y%m%d%H%M%S)

# --- 1. Pre-flight Checks ---
echo "============================================"
echo "  Passion Tree - Production Deploy"
echo "============================================"

if [ ! -f "$ENV_FILE" ]; then
    echo "[ERROR] .env not found at $ENV_FILE"
    exit 1
fi
source "$ENV_FILE"

for cmd in az docker; do
    if ! command -v $cmd &> /dev/null; then
        echo "[ERROR] $cmd is not installed"
        exit 1
    fi
done

# --- 2. Select Deploy Target ---
echo ""
echo "Select deploy target:"
echo "1) Backend (Go) only"
echo "2) AI Service (FastAPI) only"
echo "3) Both services"
echo "4) Local production test (docker-compose, no Azure)"
read -p "Enter choice (1-4): " DEPLOY_CHOICE

# --- 3. Azure Login ---
if [[ "$DEPLOY_CHOICE" != "4" ]]; then
    echo ""
    echo "[Step 1/5] Azure Login..."
    az account set --subscription "$SUBSCRIPTION_ID"
    az acr login --name "$ACR_NAME"
    echo "[OK] Azure login successful"
fi

# --- 4. Build ---
build_backend() {
    echo ""
    echo "[Step 2/5] Building Backend..."
    if [ ! -d "$BACKEND_DIR" ]; then
        echo "[ERROR] Backend directory not found: $BACKEND_DIR"
        exit 1
    fi
    cd "$BACKEND_DIR"
    BACKEND_TAG="${ACR_SERVER}/${BACKEND_IMAGE_NAME}:${TIMESTAMP}"
    BACKEND_LATEST="${ACR_SERVER}/${BACKEND_IMAGE_NAME}:latest"
    docker build . -t "$BACKEND_TAG" -t "$BACKEND_LATEST"
    echo "[OK] Backend build successful: $BACKEND_TAG"
}

build_ai() {
    echo ""
    echo "[Step 2/5] Building AI Service..."
    if [ ! -d "$AI_DIR" ]; then
        echo "[ERROR] AI directory not found: $AI_DIR"
        exit 1
    fi
    cd "$AI_DIR"
    AI_TAG="${ACR_SERVER}/${AI_IMAGE_NAME}:${TIMESTAMP}"
    AI_LATEST="${ACR_SERVER}/${AI_IMAGE_NAME}:latest"
    docker build . -t "$AI_TAG" -t "$AI_LATEST"
    echo "[OK] AI Service build successful: $AI_TAG"
}

# --- 5. Push to ACR ---
push_backend() {
    echo ""
    echo "[Step 3/5] Pushing Backend to ACR..."
    docker push "$BACKEND_TAG"
    docker push "$BACKEND_LATEST"
    echo "[OK] Backend pushed"
}

push_ai() {
    echo ""
    echo "[Step 3/5] Pushing AI Service to ACR..."
    docker push "$AI_TAG"
    docker push "$AI_LATEST"
    echo "[OK] AI Service pushed"
}

# --- 6. Deploy to Azure Container App ---
deploy_backend() {
    echo ""
    echo "[Step 4/5] Setting Backend secrets..."
    az containerapp secret set \
        --name "$BACKEND_APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --secrets \
            "azuresql-password=${AZURESQL_PASSWORD}" \
            "azure-storage-conn=${AZURE_STORAGE_CONNECTION_STRING}" \
            "smtp-password=${SMTP_PASSWORD}" \
            "mailersend-api-key=${MAILERSEND_API_KEY}" \
        2>/dev/null || true

    echo ""
    echo "[Step 5/5] Deploying Backend..."
    az containerapp update \
        --name "$BACKEND_APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --image "$BACKEND_TAG" \
        --set-env-vars \
            "APP_ENV=production" \
            "APP_URL=${APP_URL}" \
            "PORT=5000" \
            "AZURESQL_SERVER=${AZURESQL_SERVER}" \
            "AZURESQL_PORT=${AZURESQL_PORT}" \
            "AZURESQL_USER=${AZURESQL_USER}" \
            "AZURESQL_PASSWORD=secretref:azuresql-password" \
            "AZURESQL_DATABASE=${AZURESQL_DATABASE}" \
            "AI_SERVICE_URL=${AI_SERVICE_URL}" \
            "AZURE_STORAGE_CONNECTION_STRING=secretref:azure-storage-conn" \
            "CONTAINER_LEARNING_PATH=${CONTAINER_LEARNING_PATH}" \
            "CONTAINER_PROFILE=${CONTAINER_PROFILE}" \
            "SMTP_HOST=${SMTP_HOST}" \
            "SMTP_PORT=${SMTP_PORT}" \
            "SMTP_USERNAME=${SMTP_USERNAME}" \
            "SMTP_PASSWORD=secretref:smtp-password" \
            "SMTP_FROM_EMAIL=${SMTP_FROM_EMAIL}" \
            "MAILERSEND_API_KEY=secretref:mailersend-api-key"
    echo "[OK] Backend deployed!"
}

deploy_ai() {
    echo ""
    echo "[Step 4/5] Setting AI Service secrets..."
    az containerapp secret set \
        --name "$AI_APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --secrets \
            "groq-api-key=${GROQ_API_KEY}" \
            "jina-api-key=${JINA_API_KEY}" \
            "qdrant-api-key=${QDRANT_API_KEY}" \
        2>/dev/null || true

    echo ""
    echo "[Step 5/5] Deploying AI Service..."
    az containerapp update \
        --name "$AI_APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --image "$AI_TAG" \
        --set-env-vars \
            "PORT=8000" \
            "REDIS_URL=${REDIS_URL}" \
            "QDRANT_URL=${QDRANT_URL}" \
            "GROQ_API_KEY=secretref:groq-api-key" \
            "JINA_API_KEY=secretref:jina-api-key" \
            "QDRANT_API_KEY=secretref:qdrant-api-key" \
            "MODEL_CACHE_DIR=${MODEL_CACHE_DIR:-/app/models/cache}"
    echo "[OK] AI Service deployed!"
}

# --- 7. Local Production Test ---
run_local_prod() {
    echo ""
    echo "[Local] Running production docker-compose..."
    cd "$PROJECT_DIR"
    COMPOSE_DIR="docker-compose"
    COMPOSE_FILES=("docker-compose.yml" "docker-compose.prod.yml")
    ARGS=(--env-file "$ENV_FILE")
    for f in "${COMPOSE_FILES[@]}"; do
        ARGS+=( -f "$COMPOSE_DIR/$f" )
    done
    exec docker compose "${ARGS[@]}" up --build
}

# --- 8. Execute ---
case $DEPLOY_CHOICE in
    1) build_backend && push_backend && deploy_backend ;;
    2) build_ai && push_ai && deploy_ai ;;
    3)
        build_backend
        build_ai
        push_backend
        push_ai
        deploy_backend
        deploy_ai
        ;;
    4) run_local_prod ;;
    *) echo "[ERROR] Invalid choice"; exit 1 ;;
esac

# --- 9. Summary ---
if [[ "$DEPLOY_CHOICE" != "4" ]]; then
    echo ""
    echo "============================================"
    echo "  Deploy Complete!"
    echo "============================================"
    echo "  Resource Group: $RESOURCE_GROUP"
    [[ "$DEPLOY_CHOICE" == "1" || "$DEPLOY_CHOICE" == "3" ]] && echo "  Backend Image:  $BACKEND_TAG"
    [[ "$DEPLOY_CHOICE" == "2" || "$DEPLOY_CHOICE" == "3" ]] && echo "  AI Image:       $AI_TAG"
    echo "============================================"
fi
