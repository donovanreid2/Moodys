$root = Split-Path -Parent $PSScriptRoot
$runnerPath = Join-Path $root "tools\azure-naming-tool-runner"

Write-Host "Stopping Azure Naming Tool..."
docker compose -f "$runnerPath\docker-compose.yml" down
