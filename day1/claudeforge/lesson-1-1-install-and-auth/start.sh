#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="${ROOT}/.dashboard.pid"
PORT="${PORT:-8765}"
PY="${ROOT}/scripts/serve_dashboard.py"
LOG="${ROOT}/logs/dashboard.log"

if [[ ! -f "${PY}" ]]; then
  echo "Missing ${PY}. Run setup.sh from day1 first." >&2
  exit 1
fi

if [[ -f "${PID_FILE}" ]]; then
  OLD_PID="$(cat "${PID_FILE}" 2>/dev/null || true)"
  if [[ -n "${OLD_PID}" ]] && kill -0 "${OLD_PID}" 2>/dev/null; then
    echo "Dashboard already running (PID ${OLD_PID}). Use stop.sh first." >&2
    exit 1
  fi
  rm -f "${PID_FILE}"
fi

if command -v lsof &>/dev/null; then
  if lsof -i ":${PORT}" -sTCP:LISTEN &>/dev/null; then
    echo "Port ${PORT} is already in use. Stop the other process or set PORT=." >&2
    exit 1
  fi
elif command -v ss &>/dev/null; then
  if ss -ltn 2>/dev/null | grep -q ":${PORT} "; then
    echo "Port ${PORT} appears in use (ss). Stop the other process or set PORT=." >&2
    exit 1
  fi
fi

mkdir -p "${ROOT}/logs"
nohup python3 "${PY}" "${PORT}" >> "${LOG}" 2>&1 &
echo $! > "${PID_FILE}"
echo "Started dashboard PID $(cat "${PID_FILE}") — http://127.0.0.1:${PORT}/dashboard/index.html"
