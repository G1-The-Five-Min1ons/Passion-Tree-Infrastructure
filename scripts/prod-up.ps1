# Start production-like stack (no hot-reload)
param(
    [switch]$Rebuild
)

$files = @("docker-compose.yml", "docker-compose.prod.yml")

# Build proper -f arguments for multiple compose files (PowerShell-safe)
$composeArgs = @()
foreach ($f in $files) { $composeArgs += @('-f', $f) }

if ($Rebuild) {
    docker compose @composeArgs up --build
} else {
    docker compose @composeArgs up
}
