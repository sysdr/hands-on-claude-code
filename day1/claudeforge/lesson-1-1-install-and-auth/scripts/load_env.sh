#!/usr/bin/env bash
# Load project .env when present (never prints values). Safe to source from any script.
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  _LE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  _LE_ROOT="$(cd "${_LE_DIR}/.." && pwd)"
  if [[ -f "${_LE_ROOT}/.env" ]]; then
    set -a
    # shellcheck disable=SC1091
    source "${_LE_ROOT}/.env"
    set +a
  fi
  unset _LE_DIR _LE_ROOT
fi
