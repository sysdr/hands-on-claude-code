#!/usr/bin/env bash
# verify_session.sh — Run after completing the Lesson 1.2 interactive session.
# Checks that the student's Claude Code edit was accepted and tests pass.
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RESET='\033[0m'
pass() { echo -e "${GREEN}[PASS]${RESET} $*"; }
fail() { echo -e "${RED}[FAIL]${RESET} $*"; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ClaudeForge Lesson 1.2 — Session Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

FAILURES=0

# Check 1: CLAUDE.md exists and is non-empty
if [[ -s "CLAUDE.md" ]]; then
  pass "CLAUDE.md exists and is non-empty"
else
  fail "CLAUDE.md is missing or empty"
  FAILURES=$((FAILURES + 1))
fi

# Check 2: ANTHROPIC_API_KEY is not set (unless automation skip)
if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  pass "ANTHROPIC_API_KEY is unset (correct for Modules 1-7)"
elif [[ -n "${SKIP_API_KEY_GUARD:-}" ]]; then
  pass "SKIP_API_KEY_GUARD set — skipping API key check"
else
  fail "ANTHROPIC_API_KEY is set — unset it before running Modules 1-7"
  FAILURES=$((FAILURES + 1))
fi

# Check 3: git repo is initialised
if git rev-parse --git-dir &>/dev/null; then
  pass "git repository detected"
else
  fail "Not a git repository — run project_setup.sh first"
  FAILURES=$((FAILURES + 1))
fi

# Check 4: get_user_by_email exists in service (post-edit check)
if grep -q "def get_user_by_email" src/auth/user_auth_service.py 2>/dev/null; then
  pass "get_user_by_email method found in UserAuthService"
else
  warn "get_user_by_email not yet added — complete the interactive session first"
fi

# Check 5: virtualenv + pytest module
PY_BIN="./.venv/bin/python"
if [[ -x "$PY_BIN" ]]; then
  pass "Virtualenv found at .venv/"
else
  warn "No .venv — run setup.sh or: python3 -m venv .venv && .venv/bin/pip install -e '.[dev]'"
fi

# Check 6: Run test suite
if [[ -x "$PY_BIN" ]]; then
  echo ""
  echo "Running test suite..."
  if "$PY_BIN" -m pytest tests/unit/ -v --tb=short 2>&1; then
    pass "All tests pass (including get_user_by_email tests)"
  else
    fail "Some tests failed — review the diff Claude applied"
    FAILURES=$((FAILURES + 1))
  fi
elif command -v pytest &>/dev/null; then
  echo ""
  echo "Running test suite (system pytest)..."
  if pytest tests/unit/ -v --tb=short 2>&1; then
    pass "All tests pass"
  else
    fail "Some tests failed"
    FAILURES=$((FAILURES + 1))
  fi
else
  warn "pytest not available — use .venv: .venv/bin/python -m pytest"
fi

# Check 7: Claude Code CLI is available (optional in CI)
if command -v claude &>/dev/null; then
  CLAUDE_VER=$(claude --version 2>/dev/null || echo "unknown")
  pass "Claude Code CLI found: ${CLAUDE_VER}"
else
  warn "Claude Code CLI not found — install for interactive lesson: npm install -g @anthropic-ai/claude-code"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ ${FAILURES} -eq 0 ]]; then
  echo -e "${GREEN}  All checks passed. Lesson 1.2 complete.${RESET}"
else
  echo -e "${RED}  ${FAILURES} check(s) failed. Review output above.${RESET}"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

exit ${FAILURES}
