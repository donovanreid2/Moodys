#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-8081}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER_DIR="$ROOT_DIR/tools/azure-naming-tool-runner"

echo "Starting Azure Naming Tool on http://localhost:${PORT} ..."
PORT="$PORT" docker compose -f "$RUNNER_DIR/docker-compose.yml" up -d

echo "Azure Naming Tool is running."
echo "Open: http://localhost:${PORT}"
