# Lesson 1.2 — First Interactive Session Inside a Real Repository

## What's here

Generated next to `setup.sh` (not the current working directory):

```
lesson-1-first-session/
├── README.md                     ← this file
├── start.sh                      ← metrics server + dashboard
├── stop.sh                       ← stop server
├── Makefile                      ← make test, make demo, …
├── sample-repo/
│   ├── CLAUDE.md
│   ├── pyproject.toml
│   ├── src/
│   │   ├── server.py             ← metrics HTTP server (stdlib)
│   │   ├── auth/user_auth_service.py
│   │   ├── models/user.py
│   │   ├── api/routes.py
│   │   └── utils/config.py
│   ├── tests/unit/test_user_auth_service.py
│   └── scripts/
│       ├── verify_session.sh
│       └── demo_metrics.sh       ← bump demo counters
└── dashboard/
    ├── context_inspector.sh
    └── index.html                ← live metrics UI
```

## Quick start

```bash
# 1. Verify environment
echo $ANTHROPIC_API_KEY   # Must be empty (unless SKIP_API_KEY_GUARD)
claude --version          # Optional for interactive lesson

# 2. From this directory: metrics + dashboard
./start.sh
# Open http://127.0.0.1:8765/

# 3. Bump demo metrics (separate terminal)
./sample-repo/scripts/demo_metrics.sh

# 4. Tests
make test
# or: cd sample-repo && pip install -e ".[dev]" && pytest tests/unit/ -v

# 5. Full demo (inspector + pytest + start + demo traffic)
make demo

# 6. Stop server
./stop.sh

# 7. Optional: Claude Code session in sample-repo
cd sample-repo && claude
```

## Verification targets

| Check | Expected |
|-------|---------|
| `grep "get_user_by_email" sample-repo/src/auth/user_auth_service.py` | method present |
| `make test` or `pytest` in `sample-repo` | all tests pass |
| `./start.sh` then `./sample-repo/scripts/demo_metrics.sh` | dashboard counters non-zero |
| `echo $ANTHROPIC_API_KEY` | empty for Modules 1-7 |
