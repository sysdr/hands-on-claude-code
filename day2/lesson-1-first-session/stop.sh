#!/usr/bin/env bash
# Stop metrics HTTP server started by start.sh.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="${ROOT}/.metrics-server.pid"

if [[ ! -f "$PID_FILE" ]]; then
  echo "No PID file (${PID_FILE}); nothing to stop."
  exit 0
fi

pid="$(cat "$PID_FILE" 2>/dev/null || true)"
if [[ -z "$pid" ]]; then
  rm -f "$PID_FILE"
  exit 0
fi

if kill -0 "$pid" 2>/dev/null; then
  kill "$pid" 2>/dev/null || true
  echo "Stopped metrics server (PID ${pid})"
else
  echo "Process ${pid} not running; cleaning PID file"
fi
rm -f "$PID_FILE"
