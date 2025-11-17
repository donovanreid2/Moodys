#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER_DIR="$ROOT_DIR/tools/azure-naming-tool-runner"

echo "Stopping Azure Naming Tool..."
docker compose -f "$RUNNER_DIR/docker-compose.yml" down
