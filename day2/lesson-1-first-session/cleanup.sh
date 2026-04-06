#!/usr/bin/env bash
# Stop the lesson metrics server, prune Docker resources, and remove local caches
# that should not be committed (venv, pytest cache, __pycache__, egg-info, logs, .env).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="${ROOT}/sample-repo"

echo "[1/3] Stopping lesson metrics server (if any)..."
if [[ -x "${ROOT}/stop.sh" ]]; then
  bash "${ROOT}/stop.sh" || true
fi

echo "[2/3] Docker: stop running containers and prune unused resources..."
if command -v docker &>/dev/null; then
  running="$(docker ps -q 2>/dev/null || true)"
  if [[ -n "${running}" ]]; then
    docker stop ${running} 2>/dev/null || true
  fi
  docker container prune -f 2>/dev/null || true
  docker image prune -af 2>/dev/null || true
  docker network prune -f 2>/dev/null || true
  docker builder prune -af 2>/dev/null || true
  docker volume prune -f 2>/dev/null || true
  docker system prune -af 2>/dev/null || true
  echo "Docker cleanup finished."
else
  echo "docker not found; skipping Docker steps."
fi

echo "[3/3] Removing local Python caches, venv, logs, and env secrets under lesson..."
if [[ -d "${REPO}" ]]; then
  find "${REPO}" -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
  find "${REPO}" -type d -name .pytest_cache -exec rm -rf {} + 2>/dev/null || true
  find "${REPO}" -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
  rm -rf "${REPO}/.venv" 2>/dev/null || true
fi
rm -f "${ROOT}/.metrics-server.pid" "${ROOT}/metrics-server.log" 2>/dev/null || true
rm -f "${ROOT}/.env" "${ROOT}/.env.*" "${REPO}/.env" "${REPO}/.env.*" 2>/dev/null || true

echo "Cleanup complete."
