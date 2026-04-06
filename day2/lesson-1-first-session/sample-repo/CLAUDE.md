# claudeforge-sample-service — Project Memory

## Stack
- Language: Python 3.11+
- Metrics/dashboard: `src/server.py` (stdlib `http.server` only — Lesson 1.2 harness)
- Testing: pytest 8.x
- Package manager: pip with pyproject.toml + `sample-repo/.venv` (created by `setup.sh`)

## Key Files
- `src/auth/user_auth_service.py` — primary service class; includes `get_user_by_email`
- `src/models/user.py` — User dataclass; do not change field names without updating tests
- `src/server.py` — local metrics HTTP server for the lesson dashboard
- `tests/unit/test_user_auth_service.py` — test suite; run after every edit

## Conventions
- All functions must have type annotations (PEP 484)
- Use `Optional[X]` not `X | None` for compatibility with tooling
- Raise `ValueError` for invalid inputs, not `TypeError`
- No bare `except` clauses; always name the exception type
- `password_hash` is SHA-256 hex; never log or return it in API responses

## Off-Limits
- Do not modify `tests/unit/test_user_auth_service.py` unless the student explicitly asks
- Do not add third-party dependencies without asking first
- Do not change `User.id` generation strategy (time-based int)

## Running Tests
```bash
pip install -e ".[dev]"
pytest tests/unit/ -v
```

## Session Context Loading Guide
Load only what you need. Recommended patterns:
- Bug in auth: /add src/auth/ && /add src/models/user.py
- API route issue: /add src/api/ && /add src/auth/user_auth_service.py
- Full service review: /add src/ (check /status first — should be <15k tokens)
