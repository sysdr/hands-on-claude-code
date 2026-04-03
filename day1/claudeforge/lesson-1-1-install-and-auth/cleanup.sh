#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[cleanup] stopping local dashboard (if running)"
bash "${ROOT}/stop.sh" >/dev/null 2>&1 || true

if ! command -v docker >/dev/null 2>&1; then
  echo "[cleanup] docker not installed; skipping docker cleanup"
  exit 0
fi

if ! docker info >/dev/null 2>&1; then
  echo "[cleanup] docker daemon not reachable; skipping docker cleanup"
  exit 0
fi

echo "[cleanup] stopping all running containers"
CONTAINERS="$(docker ps -q || true)"
if [[ -n "${CONTAINERS}" ]]; then
  docker stop ${CONTAINERS} >/dev/null
else
  echo "[cleanup] no running containers"
fi

echo "[cleanup] pruning unused docker resources (containers/images/networks/volumes/build cache)"
docker container prune -f >/dev/null || true
docker image prune -af >/dev/null || true
docker network prune -f >/dev/null || true
docker volume prune -f >/dev/null || true
docker builder prune -af >/dev/null || true

echo "[cleanup] done"

