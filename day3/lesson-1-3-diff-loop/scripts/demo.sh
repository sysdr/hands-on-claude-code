#!/bin/bash
# demo.sh: Interactive walkthrough of the diff loop workflow
# Usage: bash scripts/demo.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
API_DIR="${PROJECT_ROOT}/sample-api"

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Lesson 1.3: First AI-Assisted Code Edit Using the Diff Loop${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

# Step 1: Verify Claude Code CLI is installed
echo -e "${YELLOW}Step 1: Verify Claude Code CLI is installed${NC}"
# Non-login shells often omit nvm/fnm from PATH; load common shims so `claude` resolves.
if ! command -v claude &> /dev/null; then
    if [[ -s "${HOME}/.nvm/nvm.sh" ]]; then
        # shellcheck source=/dev/null
        source "${HOME}/.nvm/nvm.sh"
    elif command -v fnm &> /dev/null; then
        eval "$(fnm env)"
    fi
fi
if command -v claude &> /dev/null; then
    CLAUDE_BIN="$(command -v claude)"
    version=$("${CLAUDE_BIN}" --version)
    echo -e "${GREEN}✓ Claude Code CLI found: ${version}${NC}"
    echo -e "  (${CLAUDE_BIN})"
else
    echo -e "${RED}✗ Claude Code CLI not found. Install with: npm install -g @anthropic-ai/claude-code${NC}"
    exit 1
fi
echo ""

# Step 2: Verify Python and dependencies
echo -e "${YELLOW}Step 2: Verify Python 3.11+ installed${NC}"
python_version=$(python3 --version 2>&1 | awk '{print $2}')
echo -e "${GREEN}✓ Python ${python_version} found${NC}"
echo ""

# Step 3: Create venv + install dependencies
echo -e "${YELLOW}Step 3: Create virtualenv + install dependencies (Flask, pytest)${NC}"
cd "${API_DIR}"
if [[ ! -d ".venv" ]]; then
    python3 -m venv .venv
fi
. .venv/bin/activate
python -m pip install -q --upgrade pip
python -m pip install -q -r requirements.txt
echo -e "${GREEN}✓ Dependencies installed into .venv${NC}"
echo ""

# Step 4: Run tests to establish baseline
echo -e "${YELLOW}Step 4: Run baseline tests (before Claude Code edits)${NC}"
echo "Running: python -m pytest tests/test_server.py -v"
echo ""
python -m pytest tests/test_server.py -v --tb=short 2>&1 | grep -E "PASSED|FAILED|ERROR" || echo "Tests completed"
echo ""

# Step 5: Display current server.py
echo -e "${YELLOW}Step 5: Examine the current server.py (intentionally imperfect)${NC}"
echo ""
cat server.py
echo ""

# Step 6: Explain what Claude will be asked to do
echo -e "${YELLOW}Step 6: What we'll ask Claude Code to fix${NC}"
cat << 'INSTRUCTIONS'

We'll use Claude Code's diff loop to:
  1. Add structured logging using Python's logging module
  2. Convert health_check() to async
  3. Return ISO 8601 timestamps from health endpoints
  4. Improve error handling in readiness check

This demonstrates:
  ✓ How to use @ file mentions (e.g. @server.py) to pull files into the conversation
  ✓ How Claude presents diffs for you to review before accepting
  ✓ How CLAUDE.md anchors Claude's understanding (see CLAUDE.md for details)
  ✓ How to use /cost (and /context) to inspect token and context usage — type / for the full menu
  ✓ How to accept (y), reject (n), or edit (e) the diff

INSTRUCTIONS

echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Run: cd $(pwd) && \"${CLAUDE_BIN}\""
echo "  2. In the Claude prompt, mention the file with @server.py (type @ for path autocomplete), then ask:"
echo "     'Add structured logging using the logging module, and convert health_check to async'"
echo "  3. Review the diff Claude generates, then type 'y' to accept"
echo "  4. Type /exit (or /quit) to leave the session when finished"
echo "  5. Run tests again with: ./.venv/bin/python -m pytest tests/test_server.py -v"
echo ""
if [[ "${CLAUDE_BIN}" == *"/.nvm/"* ]] || [[ -n "${NVM_DIR:-}" ]]; then
    echo -e "${YELLOW}If another terminal says ${RED}claude: command not found${YELLOW}:${NC}"
    echo -e "  ${GREEN}source \"\${HOME}/.nvm/nvm.sh\"${NC}   # then ${GREEN}claude --version${NC}"
    echo -e "  or run step 1 using the full path above (quotes matter)."
    echo ""
fi
echo -e "${GREEN}Ready? Run the next step to begin the interactive diff loop.${NC}"
