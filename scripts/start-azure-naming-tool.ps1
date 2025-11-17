Param(
    [int]$Port = 8081
)

$root = Split-Path -Parent $PSScriptRoot
$runnerPath = Join-Path $root "tools\azure-naming-tool-runner"

Write-Host "Starting Azure Naming Tool on http://localhost:$Port ..."
docker compose -f "$runnerPath\docker-compose.yml" up -d

Write-Host "Azure Naming Tool is running."
Write-Host "Open: http://localhost:$Port"
