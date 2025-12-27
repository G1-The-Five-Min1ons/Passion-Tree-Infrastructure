# Start development stack with Azure SQL Edge overlay
param(
    [switch]$Rebuild,
    [switch]$Detached
)

Write-Host "🚀 Starting Passion Tree Development Stack (Azure SQL)" -ForegroundColor Cyan

# Check if .env exists
if (-not (Test-Path "../../.env")) {
    Write-Host "⚠️  .env file not found!" -ForegroundColor Yellow
    if (Test-Path "../../.env.example") {
        Copy-Item "../../.env.example" "../../.env"
        Write-Host "📝 Created .env from .env.example" -ForegroundColor Green
        Write-Host "Please edit .env and add your GROQ_API_KEY" -ForegroundColor Yellow
        exit 1
    } else {
        Write-Host "❌ .env.example not found!" -ForegroundColor Red
        exit 1
    }
}

# Check if GROQ_API_KEY is set
$envContent = Get-Content "../../.env" -Raw
if ($envContent -match "changeme-groq-key") {
    Write-Host "⚠️  Warning: GROQ_API_KEY is still set to 'changeme-groq-key'" -ForegroundColor Yellow
    Write-Host "📝 Please update your .env file with a real API key" -ForegroundColor Yellow
}

Set-Location ../..

$composeDir = "docker-compose"
$files = @("docker-compose.yml", "docker-compose.override.yml", "docker-compose.mssql.yml")

# Build proper -f arguments for multiple compose files (PowerShell-safe)
$composeArgs = @('--env-file', '.env')
foreach ($f in $files) { $composeArgs += @('-f', "$composeDir\$f") }

Write-Host "🐳 Starting containers..." -ForegroundColor Cyan

if ($Rebuild) {
    $composeArgs += 'up', '--build'
} else {
    $composeArgs += 'up'
}

if ($Detached) {
    $composeArgs += '-d'
}

docker compose @composeArgs
