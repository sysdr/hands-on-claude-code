#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"
# shellcheck disable=SC1091
source "${ROOT}/scripts/load_env.sh"
python3 << 'PY'
import json
import time
from pathlib import Path

p = Path("src/metrics.json")
data = json.loads(p.read_text(encoding="utf-8"))
data["demo_runs"] = int(data.get("demo_runs", 0)) + 1
data["last_demo_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
data["demo_last_status"] = "running"
Path("src/metrics.json").write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
print("Updated metrics: demo_runs =", data["demo_runs"])
PY
set +e
bash "${ROOT}/scripts/verify_auth.sh"
AUTH_EC=$?
set -e
export AUTH_EC
python3 << 'PY'
import json
import os
from pathlib import Path

p = Path("src/metrics.json")
data = json.loads(p.read_text(encoding="utf-8"))
ec = int(os.environ.get("AUTH_EC", "1"))
data["verify_pass"] = int(data.get("verify_pass", 0)) + (1 if ec == 0 else 0)
data["verify_fail"] = int(data.get("verify_fail", 0)) + (0 if ec == 0 else 1)
data["demo_last_status"] = "ok" if ec == 0 else "failed"
p.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY
exit "${AUTH_EC}"
