#!/usr/bin/env bash
# Bump demo counters so dashboard values are non-zero.
set -euo pipefail
PORT="${METRICS_PORT:-8765}"
BASE="http://127.0.0.1:${PORT}"
for i in 1 2 3; do
  curl -sS -X POST "${BASE}/api/demo/register" -H "Content-Type: application/json" \
    -d "{\"username\":\"demo${i}\",\"email\":\"demo${i}@example.com\"}" >/dev/null
done
curl -sS -X POST "${BASE}/api/demo/login" -H "Content-Type: application/json" -d "{}" >/dev/null
curl -sS -X POST "${BASE}/api/demo/login" -H "Content-Type: application/json" -d "{}" >/dev/null
echo "Demo traffic sent to ${BASE} (registrations + logins)."
