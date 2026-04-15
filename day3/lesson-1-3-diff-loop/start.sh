#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}"
PID_DIR="${PROJECT_DIR}/.pids"

mkdir -p "${PID_DIR}"

API_PID_FILE="${PID_DIR}/api.pid"

if [[ -f "${API_PID_FILE}" ]] && kill -0 "$(cat "${API_PID_FILE}")" 2>/dev/null; then
  echo "API already running (pid $(cat "${API_PID_FILE}"))."
  exit 0
fi

cd "${PROJECT_DIR}/sample-api"

PYTHON="python3"
if [[ -x ".venv/bin/python" ]]; then
  PYTHON=".venv/bin/python"
fi

# Load environment variables from sample-api/.env if present
if [[ -f ".env" ]]; then
  set -a
  . ".env"
  set +a
fi

nohup "${PYTHON}" server.py > "${PID_DIR}/api.log" 2>&1 &
echo $! > "${API_PID_FILE}"

echo "Started API (pid $(cat "${API_PID_FILE}"))."
echo "Dashboard: http://localhost:5000/dashboard"
echo "Health:    http://localhost:5000/health"
echo "Metrics:   http://localhost:5000/metrics"
