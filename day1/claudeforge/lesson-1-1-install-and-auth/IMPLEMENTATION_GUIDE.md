## Implementation Guide (Lesson 1.1)

This project verifies Claude Code authentication **end-to-end** using a real `claude -p ... --print` call, and shows live, non-zero metrics on a small local dashboard.

## How Claude Code auth works (short)

- **OAuth (Pro/Max subscription)**: `claude auth login` opens a browser to authorize, then saves an encrypted token on disk (e.g. Linux: `~/.config/claude/credentials.json`).
- **API key (API billing)**: set `ANTHROPIC_API_KEY` in your environment. This bypasses OAuth and uses API billing.
- **Important**: `claude --version` is not a network test. A real `claude -p` call is.

## Step-by-step (OAuth / subscription mode)

1. Go to the project:

```bash
cd /home/systemdr/git/hands-on-claude-code/day1/claudeforge/lesson-1-1-install-and-auth
```

2. Make sure no API key is set:

```bash
unset ANTHROPIC_API_KEY
```

3. Log in (opens browser):

```bash
claude auth login
```

4. Verify end-to-end:

```bash
claude -p "respond with exactly the string: CLAUDEFORGE_AUTH_OK" --print
echo $?
```

Expected:
- Output contains **`CLAUDEFORGE_AUTH_OK`**
- Exit code is **0**

## Step-by-step (API key mode via `.env`)

1. Create a local `.env` (never commit it):

```bash
cd /home/systemdr/git/hands-on-claude-code/day1/claudeforge/lesson-1-1-install-and-auth
printf "ANTHROPIC_API_KEY=%s\n" "YOUR_KEY_HERE" > .env
```

2. Run verification (loads `.env` automatically):

```bash
make verify
```

Notes:
- You’ll see a **WARN** that API billing is active.
- In `--ci` mode, OAuth checks are skipped, but **`claude -p` still runs** when an API key is present.

## Dashboard (metrics must not stay zero)

1. Start the local dashboard:

```bash
./start.sh
```

2. Open:
- `http://127.0.0.1:8765/dashboard/index.html`

3. Run the demo (updates metrics + runs real `claude -p`):

```bash
make demo
```

What should update:
- **`api_hits`** and **`uptime_sec`** increase while the page polls `/api/metrics`
- **`demo_runs`** increments on each `make demo`
- **`verify_pass`** / **`verify_fail`** increments based on the actual auth result

4. Stop the dashboard:

```bash
./stop.sh
```

## Cleanup (stop services + Docker prune)

```bash
./cleanup.sh
```

This will:
- stop the local dashboard (if running)
- stop any running Docker containers
- prune unused Docker resources (containers/images/networks/volumes/build cache)

## Files to know

- **`scripts/verify_auth.sh`**: main verifier (uses real `claude -p`)
- **`scripts/load_env.sh`**: loads `.env` if present (does not print values)
- **`scripts/demo.sh`**: increments metrics + runs verification
- **`start.sh` / `stop.sh`**: manage the dashboard service
- **`cleanup.sh`**: stop services + Docker cleanup

