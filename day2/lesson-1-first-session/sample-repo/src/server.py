"""HTTP server: live metrics API and dashboard for Lesson 1.2."""
from __future__ import annotations

import json
import os
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any
from urllib.parse import urlparse

PORT = int(os.environ.get("METRICS_PORT", "8765"))
STARTED = time.time()
_lock = threading.Lock()
_metrics: dict[str, int] = {
    "http_requests_total": 0,
    "demo_registrations": 0,
    "demo_logins": 0,
    "active_sessions": 0,
}


def _lesson_root() -> str:
    """sample-repo/src/server.py -> lesson-1-first-session/"""
    here = os.path.dirname(os.path.abspath(__file__))
    sample_repo = os.path.dirname(here)
    return os.path.dirname(sample_repo)


def _dashboard_dir() -> str:
    return os.path.join(_lesson_root(), "dashboard")


def _inc_http() -> None:
    with _lock:
        _metrics["http_requests_total"] += 1


def snapshot() -> dict[str, Any]:
    now = time.time()
    with _lock:
        out: dict[str, Any] = {k: int(v) for k, v in _metrics.items()}
    out["uptime_seconds"] = round(now - STARTED, 3)
    out["server_epoch_unix"] = int(now)
    out["pid"] = os.getpid()
    return out


class MetricsHandler(BaseHTTPRequestHandler):
    def log_message(self, fmt: str, *args: Any) -> None:
        if os.environ.get("METRICS_QUIET") == "1":
            return
        super().log_message(fmt, *args)

    def do_GET(self) -> None:
        _inc_http()
        parsed = urlparse(self.path)
        path = parsed.path or "/"
        if path == "/api/metrics":
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.end_headers()
            self.wfile.write(json.dumps(snapshot()).encode())
            return
        if path in ("/", "/index.html"):
            index_path = os.path.join(_dashboard_dir(), "index.html")
            if os.path.isfile(index_path):
                self.send_response(200)
                self.send_header("Content-Type", "text/html; charset=utf-8")
                self.end_headers()
                with open(index_path, "rb") as f:
                    self.wfile.write(f.read())
                return
        self.send_response(404)
        self.end_headers()

    def do_POST(self) -> None:
        _inc_http()
        parsed = urlparse(self.path)
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length) if length else b"{}"
        try:
            data = json.loads(raw.decode() or "{}")
        except json.JSONDecodeError:
            data = {}

        if parsed.path == "/api/demo/register":
            with _lock:
                _metrics["demo_registrations"] += 1
                _metrics["active_sessions"] += 1
            self._json(200, {"status": "ok", "event": "register", "username": data.get("username")})
            return
        if parsed.path == "/api/demo/login":
            with _lock:
                _metrics["demo_logins"] += 1
            self._json(200, {"status": "ok", "event": "login"})
            return

        self.send_response(404)
        self.end_headers()

    def _json(self, code: int, obj: dict[str, Any]) -> None:
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.end_headers()
        self.wfile.write(json.dumps(obj).encode())


def run() -> None:
    server = ThreadingHTTPServer(("127.0.0.1", PORT), MetricsHandler)
    print(f"metrics server listening on http://127.0.0.1:{PORT}/", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    run()
