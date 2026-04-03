#!/usr/bin/env python3
"""Serve dashboard static files and /api/metrics (merged with on-disk metrics)."""
from __future__ import annotations

import json
import os
import sys
import threading
import time
from http import HTTPStatus
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parent.parent
DASH = ROOT / "dashboard"
METRICS_FILE = ROOT / "src" / "metrics.json"

_lock = threading.Lock()
_api_hits = 0
_start = time.time()


def load_metrics() -> dict:
    with _lock:
        global _api_hits
        _api_hits += 1
        data = {}
        if METRICS_FILE.exists():
            data = json.loads(METRICS_FILE.read_text(encoding="utf-8"))
        data["api_hits"] = _api_hits
        data["uptime_sec"] = int(time.time() - _start)
        data["pid"] = os.getpid()
        return data


class Handler(SimpleHTTPRequestHandler):
    def log_message(self, fmt: str, *args) -> None:
        return  # quiet

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path == "/api/metrics":
            body = json.dumps(load_metrics(), indent=2).encode("utf-8")
            self.send_response(HTTPStatus.OK)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Cache-Control", "no-store")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        if parsed.path in ("/", "/dashboard", "/dashboard/"):
            self.send_response(HTTPStatus.MOVED_PERMANENTLY)
            self.send_header("Location", "/dashboard/index.html")
            self.end_headers()
            return
        super().do_GET()

    def translate_path(self, path: str) -> str:
        parsed = urlparse(path)
        p = parsed.path.lstrip("/")
        if p == "dashboard" or p == "dashboard/":
            return str(DASH / "index.html")
        if p.startswith("dashboard/"):
            rel = p[len("dashboard/") :]
            return str(DASH / rel) if rel else str(DASH / "index.html")
        return super().translate_path(path)


def main() -> None:
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
    os.chdir(ROOT)
    # Stamp server start in metrics file once
    if METRICS_FILE.exists():
        m = json.loads(METRICS_FILE.read_text(encoding="utf-8"))
        m["server_started_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
        METRICS_FILE.write_text(json.dumps(m, indent=2) + "\n", encoding="utf-8")
    server = ThreadingHTTPServer(("127.0.0.1", port), Handler)
    print(f"dashboard listening on http://127.0.0.1:{port}/dashboard/index.html", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
