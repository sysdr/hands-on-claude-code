#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="${ROOT}/.dashboard.pid"
if [[ ! -f "${PID_FILE}" ]]; then
  echo "No PID file; dashboard not started by start.sh."
  exit 0
fi
PID="$(cat "${PID_FILE}" 2>/dev/null || true)"
if [[ -z "${PID}" ]]; then
  rm -f "${PID_FILE}"
  exit 0
fi
if kill -0 "${PID}" 2>/dev/null; then
  kill "${PID}" 2>/dev/null || true
  sleep 0.5
  if kill -0 "${PID}" 2>/dev/null; then kill -9 "${PID}" 2>/dev/null || true; fi
  echo "Stopped dashboard (PID ${PID})."
else
  echo "Stale PID ${PID}; removing PID file."
fi
rm -f "${PID_FILE}"
