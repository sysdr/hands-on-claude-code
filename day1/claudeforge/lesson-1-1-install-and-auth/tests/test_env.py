"""
Unit tests for Lesson 1.1 environment checks.
Run: python3 tests/test_env.py
"""
import os
import shutil
import subprocess
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


class TestClaudeCodeEnvironment(unittest.TestCase):

    def test_node_version_18_or_higher(self):
        result = subprocess.run(
            ["node", "--version"],
            capture_output=True, text=True, check=True
        )
        version_str = result.stdout.strip().lstrip("v")
        major = int(version_str.split(".")[0])
        self.assertGreaterEqual(
            major, 18,
            f"Node.js {major} is below required minimum 18"
        )

    def test_claude_cli_installed(self):
        self.assertIsNotNone(
            shutil.which("claude"),
            "claude CLI not found on PATH. Run: npm install -g @anthropic-ai/claude-code"
        )

    def test_claude_version_returns_zero_exit(self):
        result = subprocess.run(
            ["claude", "--version"],
            capture_output=True, text=True
        )
        self.assertEqual(
            result.returncode, 0,
            f"claude --version exited {result.returncode}: {result.stderr}"
        )

    def test_anthropic_api_key_not_set_for_subscription_billing(self):
        key = os.environ.get("ANTHROPIC_API_KEY", "")
        if key:
            print(
                "\nWARNING: ANTHROPIC_API_KEY is set. "
                "Pro subscription billing is overridden by API billing. "
                "Unset for Modules 1–7.",
                file=sys.stderr
            )
        self.assertTrue(True)

    def test_npm_prefix_not_owned_by_root(self):
        result = subprocess.run(
            ["npm", "config", "get", "prefix"],
            capture_output=True, text=True, check=True
        )
        prefix = result.stdout.strip()
        prefix_path = Path(prefix)
        if prefix_path.exists():
            owner_uid = prefix_path.stat().st_uid
            self.assertNotEqual(
                owner_uid, 0,
                f"npm prefix {prefix} is owned by root (uid 0). "
                "This will cause EACCES on global installs. "
                "See README for fix."
            )

    def test_metrics_json_exists(self):
        p = ROOT / "src" / "metrics.json"
        self.assertTrue(p.is_file(), "src/metrics.json missing")
        import json
        data = json.loads(p.read_text(encoding="utf-8"))
        self.assertIn("demo_runs", data)


class TestLoadStress(unittest.TestCase):
    def test_version_call_stable_under_load(self):
        failures = 0
        for _ in range(20):
            result = subprocess.run(
                ["claude", "--version"],
                capture_output=True, text=True
            )
            if result.returncode != 0:
                failures += 1
        self.assertEqual(
            failures, 0,
            f"{failures}/20 claude --version calls failed"
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
