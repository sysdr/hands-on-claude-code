# Lesson 1.1 — Install Claude Code and Verify Authentication

## Goal
Install Claude Code CLI, authenticate via Pro subscription OAuth,
and confirm end-to-end connectivity with a verified -p call.

## Auth model
- Modules 1–7 + Capstone: `claude login` (OAuth, Pro subscription)
- Module 8 only: `ANTHROPIC_API_KEY` env var (API billing)
- WARNING: ANTHROPIC_API_KEY overrides OAuth for ALL sessions

## Layout
- `start.sh` / `stop.sh` — dashboard HTTP server (metrics + UI)
- `make demo` — run demo (updates metrics + auth verification)
- `make verify` — run all checks
- Optional `.env` in this directory with `ANTHROPIC_API_KEY=...` (API billing; **gitignored** — never commit). Scripts load it automatically.
- See `IMPLEMENTATION_GUIDE.md` for a step-by-step runbook.

## Verify setup
```bash
make verify
```

## Commands
- `./start.sh`   — start dashboard (http://127.0.0.1:8765/dashboard/)
- `./stop.sh`    — stop dashboard
- `make demo`    — run the auth verification scenario (updates dashboard metrics)
- `make verify`  — runs `verify_auth.sh --ci` (skips live OAuth; set `CF_SKIP_AUTH_CHECKS=0` to force full auth)
- `make cleanup` — reset workspace fingerprints
