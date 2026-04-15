#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}"
PID_DIR="${PROJECT_DIR}/.pids"

API_PID_FILE="${PID_DIR}/api.pid"

stop_pidfile() {
  local f="$1"
  local name="$2"
  if [[ -f "${f}" ]]; then
    local pid
    pid="$(cat "${f}")"
    if kill -0 "${pid}" 2>/dev/null; then
      kill "${pid}" 2>/dev/null || true
      for _ in {1..20}; do
        if kill -0 "${pid}" 2>/dev/null; then
          sleep 0.1
        else
          break
        fi
      done
      if kill -0 "${pid}" 2>/dev/null; then
        kill -9 "${pid}" 2>/dev/null || true
      fi
      echo "Stopped ${name} (pid ${pid})."
    else
      echo "${name} not running (stale pid ${pid})."
    fi
    rm -f "${f}"
  else
    echo "${name} not running (no pidfile)."
  fi
}

stop_pidfile "${API_PID_FILE}" "API"
