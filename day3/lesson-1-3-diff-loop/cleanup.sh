#!/usr/bin/env bash
# Stop lesson processes and prune Docker resources (safe for CI / disk cleanup).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "==> Stopping lesson services (API pidfile)..."
if [[ -x "${SCRIPT_DIR}/stop.sh" ]]; then
  "${SCRIPT_DIR}/stop.sh" || true
else
  echo "    (no stop.sh)"
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "==> Docker not installed; skipping Docker cleanup."
  exit 0
fi

if ! docker info >/dev/null 2>&1; then
  echo "==> Docker daemon not reachable; skipping Docker cleanup."
  exit 0
fi

echo "==> Stopping running containers..."
mapfile -t running < <(docker ps -q 2>/dev/null || true)
if ((${#running[@]})); then
  docker stop "${running[@]}" || true
else
  echo "    (none running)"
fi

echo "==> Pruning stopped containers, unused networks, dangling images, build cache..."
docker container prune -f
docker network prune -f
docker image prune -f
docker builder prune -f

echo "==> Deep clean: remove unused images (after stops, most local images qualify)..."
docker image prune -af || true

echo "==> Pruning unused volumes (not attached to a container)..."
docker volume prune -f

echo "Done."
