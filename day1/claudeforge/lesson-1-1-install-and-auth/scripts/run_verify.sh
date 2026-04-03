#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
# shellcheck disable=SC1091
source "${ROOT}/scripts/load_env.sh"
bash "${ROOT}/scripts/verify_auth.sh" --ci
python3 tests/test_env.py
