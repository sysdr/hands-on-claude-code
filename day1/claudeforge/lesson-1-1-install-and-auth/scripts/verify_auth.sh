#!/usr/bin/env bash
set -euo pipefail

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${_SCRIPT_DIR}/load_env.sh"

CI_MODE="${1:-}"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

PASS=0; FAIL=0

# Modes:
# - default: run end-to-end checks (login status + -p) when possible
# - --ci: avoid OAuth checks (non-interactive), but still run -p if API key is present
SKIP_OAUTH=0
SKIP_P=0

if [[ "${CI_MODE}" == "--ci" ]]; then
  SKIP_OAUTH=1
  # With API key, -p is safe/non-interactive and is the real connectivity check.
  if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
    SKIP_P=1
  fi
fi

if [[ "${CF_SKIP_AUTH_CHECKS:-}" == "1" ]]; then
  SKIP_OAUTH=1
  SKIP_P=1
fi

if [[ "${CF_SKIP_AUTH_CHECKS:-}" == "0" ]]; then
  SKIP_OAUTH=0
  SKIP_P=0
fi

check() {
  local label="$1"; local cmd="$2"; local expect="$3"
  local actual
  actual=$(eval "${cmd}" 2>/dev/null || echo "ERROR")
  if echo "${actual}" | grep -q "${expect}"; then
    echo -e "${GREEN}PASS${NC} ${label}"
    PASS=$((PASS+1))
  else
    echo -e "${RED}FAIL${NC} ${label}"
    echo "     Expected to contain: ${expect}"
    echo "     Got: ${actual}"
    FAIL=$((FAIL+1))
  fi
}

echo ""
echo "ClaudeForge — Lesson 1.1 Auth Verification"
echo "==========================================="

check "claude --version returns version string" "claude --version" "Claude Code"

if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
  echo -e "${YELLOW}WARN${NC} ANTHROPIC_API_KEY is set — API billing active (not Pro subscription)"
else
  echo -e "${GREEN}PASS${NC} ANTHROPIC_API_KEY is not set — Pro subscription billing"
  PASS=$((PASS+1))
fi

if [[ "${SKIP_OAUTH}" -eq 1 ]]; then
  echo -e "${YELLOW}SKIP${NC} claude login --status (OAuth checks disabled for --ci or CF_SKIP_AUTH_CHECKS=1)"
  PASS=$((PASS+1))
else
  if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
    echo -e "${YELLOW}SKIP${NC} claude login --status (API key mode doesn't require OAuth login)"
    PASS=$((PASS+1))
  else
    check "claude login --status shows logged in email" "claude login --status 2>/dev/null || echo 'not logged in'" "@"
  fi
fi

if [[ "${SKIP_P}" -eq 1 ]]; then
  echo -e "${YELLOW}SKIP${NC} claude -p live call (set ANTHROPIC_API_KEY or run without --ci)"
  PASS=$((PASS+1))
else
  check "claude -p single-shot call returns expected token" "claude -p 'respond with only this exact string: CLAUDEFORGE_AUTH_OK' --print 2>/dev/null" "CLAUDEFORGE_AUTH_OK"
fi

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"

if [[ "${FAIL}" -gt 0 ]]; then
  echo -e "${RED}Auth verification failed. See above.${NC}"
  exit 1
fi

echo -e "${GREEN}All checks passed. Lesson 1.1 complete.${NC}"
exit 0
