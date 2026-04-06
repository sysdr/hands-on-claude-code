#!/usr/bin/env bash
# context_inspector.sh — Interactive helper that shows which files to /add
# for common Lesson 1.2 tasks, and estimates their token cost.
#
# Run before starting your claude session to plan your context loading.
set -euo pipefail

REPO_DIR="${1:-$(pwd)}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; RESET='\033[0m'

# Rough token estimator: 1 token ≈ 4 chars (conservative)
estimate_tokens() {
  local path="$1"
  if [[ -d "$path" ]]; then
    local chars
    chars=$(find "$path" -type f -name "*.py" \
              -exec wc -c {} + 2>/dev/null | tail -1 | awk '{print $1}')
    echo $(( ${chars:-0} / 4 ))
  elif [[ -f "$path" ]]; then
    local chars
    chars=$(wc -c < "$path" 2>/dev/null || echo 0)
    echo $(( chars / 4 ))
  else
    echo 0
  fi
}

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}  ClaudeForge — Lesson 1.2 Context Inspector${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  Repository: ${BLUE}${REPO_DIR}${RESET}"
echo ""

declare -A SCENARIOS
SCENARIOS["auth_bug"]="src/auth/user_auth_service.py src/models/user.py"
SCENARIOS["api_issue"]="src/api/routes.py src/auth/user_auth_service.py"
SCENARIOS["full_review"]="src/"

for scenario in auth_bug api_issue full_review; do
  paths="${SCENARIOS[$scenario]}"
  total_tokens=0
  for p in $paths; do
    full_path="${REPO_DIR}/${p}"
    t=$(estimate_tokens "$full_path")
    total_tokens=$((total_tokens + t))
  done

  if (( total_tokens < 20000 )); then
    status="${GREEN}✓ safe${RESET}"
  elif (( total_tokens < 50000 )); then
    status="${YELLOW}⚠ moderate${RESET}"
  else
    status="${RED}✗ heavy — remove unneeded files${RESET}"
  fi

  echo -e "  ${BOLD}Scenario: ${scenario}${RESET}"
  for p in $paths; do
    echo "    /add ${p}"
  done
  echo -e "  Estimated tokens: ~${total_tokens}  ${status}"
  echo ""
done

echo -e "  ${BOLD}Budget reference:${RESET}"
echo -e "    Context window: 200,000 tokens"
echo -e "    Target: load <25% before first message (<50,000 tokens)"
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
