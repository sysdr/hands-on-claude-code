#!/usr/bin/env bash
# Start metrics HTTP server + dashboard (sample-repo).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="${ROOT}/sample-repo"
PID_FILE="${ROOT}/.metrics-server.pid"
LOG_FILE="${ROOT}/metrics-server.log"
export METRICS_PORT="${METRICS_PORT:-8765}"

if [[ ! -d "$REPO" ]]; then
  echo "Missing ${REPO}. Run setup.sh from the directory that contains it first." >&2
  exit 1
fi

if [[ -f "$PID_FILE" ]]; then
  oldpid="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [[ -n "${oldpid}" ]] && kill -0 "${oldpid}" 2>/dev/null; then
    echo "Metrics server already running (PID ${oldpid}) on port ${METRICS_PORT}"
    echo "Open http://127.0.0.1:${METRICS_PORT}/"
    exit 0
  fi
  rm -f "$PID_FILE"
fi

cd "$REPO"
PY="${REPO}/.venv/bin/python"
if [[ ! -x "$PY" ]]; then
  echo "Missing ${PY}. Run setup.sh to create .venv, or: python3 -m venv .venv && .venv/bin/pip install -e '.[dev]'" >&2
  exit 1
fi
"$PY" -m pip install -e ".[dev]" -q
export METRICS_QUIET="${METRICS_QUIET:-1}"
nohup env METRICS_PORT="$METRICS_PORT" METRICS_QUIET="$METRICS_QUIET" "$PY" -m src.server >>"$LOG_FILE" 2>&1 &
echo $! >"$PID_FILE"
sleep 1
if kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo "Started metrics server PID $(cat "$PID_FILE")"
  echo "Dashboard: http://127.0.0.1:${METRICS_PORT}/"
  echo "Run demo:    ${ROOT}/sample-repo/scripts/demo_metrics.sh"
else
  echo "Server failed to start. See ${LOG_FILE}" >&2
  exit 1
fi
