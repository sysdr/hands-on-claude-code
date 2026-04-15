#!/bin/bash
# verify.sh: Check that lesson 1.3 is complete

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_ROOT}"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Verification checks for Lesson 1.3${NC}"
echo ""

# Check 1: Claude Code CLI
if command -v claude &> /dev/null; then
    echo -e "${GREEN}✓${NC} Claude Code CLI installed"
else
    echo -e "${RED}✗${NC} Claude Code CLI not found"
fi

# Check 2: Python version
python_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
if (( $(echo "$python_version >= 3.11" | bc -l) )); then
    echo -e "${GREEN}✓${NC} Python 3.11+ installed (found ${python_version})"
else
    echo -e "${RED}✗${NC} Python version too old (found ${python_version}, need 3.11+)"
fi

# Check 3: Dependencies installed (prefer venv)
API_DIR="${PROJECT_ROOT}/sample-api"
if [[ ! -d "${API_DIR}" ]]; then
    echo -e "${RED}✗${NC} sample-api directory missing under ${PROJECT_ROOT}"
elif [[ -x "${API_DIR}/.venv/bin/python" ]] && "${API_DIR}/.venv/bin/python" -m pip show flask > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Flask installed (in .venv)"
elif python3 -m pip show flask > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Flask installed (system)"
else
    echo -e "${RED}✗${NC} Flask not installed; run: python3 -m venv sample-api/.venv && sample-api/.venv/bin/python -m pip install -r sample-api/requirements.txt"
fi

# Check 4: CLAUDE.md exists
if [[ -f "${PROJECT_ROOT}/sample-api/CLAUDE.md" ]]; then
    echo -e "${GREEN}✓${NC} CLAUDE.md found"
else
    echo -e "${RED}✗${NC} CLAUDE.md missing"
fi

# Check 5: Tests pass (prefer venv)
if (
    cd "${API_DIR}" || exit 1
    if [[ -x .venv/bin/python ]]; then
        .venv/bin/python -m pytest tests/test_server.py -q
    else
        python3 -m pytest tests/test_server.py -q
    fi
) 2>/dev/null; then
    echo -e "${GREEN}✓${NC} All tests pass"
else
    echo -e "${YELLOW}⚠${NC} Some tests failed (expected before Claude edits)"
fi

# Check 6: server.py has expected structure
if grep -q "def health_check" "${API_DIR}/server.py" && \
   grep -q "@app.route" "${API_DIR}/server.py"; then
    echo -e "${GREEN}✓${NC} server.py has expected structure"
else
    echo -e "${RED}✗${NC} server.py structure unexpected"
fi

echo ""
echo -e "${GREEN}Ready to begin Lesson 1.3!${NC}"
