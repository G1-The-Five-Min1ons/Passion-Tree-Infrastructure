# Passion-Tree Infrastructure

## Architecture Mapping to Diagram

- Application Gateway (WAF): Public entry with L7/8 reverse proxy. Route traffic to Azure Container Apps external ingress for `backend-go`.
- Azure Container Apps Environment: Placed in `aca-infrastructure-subnet` inside VNet. Hosts two apps:
  - `backend-go` (Go): External ingress on 8080; orchestrates storage and AI; provides `/health` for probes.
  - `ai-fastapi` (FastAPI): Internal-only ingress on 8000; connects to Redis and Azure SQL; uses `GROQ_API_KEY` for LLM.
- Storage Service: Use Azure SQL (connection via `backend_db_url` variable). Redis is internal cache (`redis_url`).

## Terraform Inputs

Set these variables (e.g., in `terraform.tfvars`):

```
backend_image   = "<acr>.azurecr.io/backend-go:latest"
ai_image        = "<acr>.azurecr.io/ai-fastapi:latest"
acr_server      = "<acr>.azurecr.io"
acr_username    = "<acr-username>"
acr_password    = "<acr-password>"
groq_api_key    = "<groq-api-key>"
backend_db_url  = "<azure-sql-conn-string>"
ai_service_url  = "http://ai-fastapi:8000"
redis_url       = "redis://<redis-host>:6379"
```

## Deploy

```
cd terraform
terraform init
terraform apply -var-file=terraform.tfvars
```

## Notes

- Health probes are configured on `/health` for both apps.
- `backend-go` is publicly reachable; `ai-fastapi` is private inside VNet.
- For production image pulls, consider Managed Identity for ACR instead of username/password.

## Dev with Azure SQL (local)

- Use Azure SQL Edge locally via an overlay compose file.

Start:

```powershell
cd Passion-Tree-Infrastructure
./scripts/dev-up-mssql.ps1 -Rebuild
```

- This adds the `azuresql` container on port 1433 and overrides `DB_URL` for `backend-go` and `ai-fastapi` to SQL Server format.
- Default SA password is `StrongPassword!123` (change in `docker-compose.mssql.yml`).

### Environment variables

- Copy `.env.example` to `.env` and set values:

```
GROQ_API_KEY=your-groq-key
MSSQL_SA_PASSWORD=your-strong-password
MSSQL_DB=project_db
```

- Docker Compose auto-loads `.env` in this folder for `${...}` substitutions.

Stop:

```powershell
docker compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.mssql.yml down
```

Note: When connecting to a real Azure SQL from dev, set `DB_URL` to your Azure SQL connection string and open firewall rules for your IP.

## Local Production-like run

Build and run using the production Dockerfiles (no hot-reload):

```powershell
cd Passion-Tree-Infrastructure
./scripts/prod-up.ps1 -Rebuild
```

- Backend is exposed at http://localhost:8080
- AI service is internal-only (no host port published)

Stop:

```powershell
docker compose -f docker-compose.yml -f docker-compose.prod.yml down
```

## Shells: PowerShell vs Bash

- PowerShell scripts:
  - Dev (Postgres): `./scripts/dev-up.ps1 -Rebuild`
  - Dev (MSSQL): `./scripts/dev-up-mssql.ps1 -Rebuild`
  - Prod-like: `./scripts/prod-up.ps1 -Rebuild`
- Bash scripts (Git Bash, WSL, etc.):
  - Dev (Postgres): `./scripts/dev-up.sh`
  - Dev (MSSQL): `./scripts/dev-up-mssql.sh`
  - Prod-like: `./scripts/prod-up.sh`

Note: `.ps1` requires PowerShell. If you see a `param(...)` syntax error in bash, use the `.sh` scripts above.
