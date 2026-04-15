## Purpose

This guide lists every practical way to run the Lesson 1.3 diff-loop sample: the Flask API, dashboard, tests, verification scripts, and optional Claude Code usage. It also covers shutdown and Docker cleanup.

## Prerequisites

- Python 3.11 or newer (`python3 --version`)
- `pip` (usually bundled with Python)
- Optional: [Claude Code CLI](https://www.npmjs.com/package/@anthropic-ai/claude-code) for the interactive lesson (`npm install -g @anthropic-ai/claude-code`)
- Optional: `ANTHROPIC_API_KEY` in `sample-api/.env` (copy from `sample-api/.env.example`); never commit real keys

All paths below assume your shell’s current directory is this project folder: `lesson-1-3-diff-loop/`.

## Claude Code v2.1+ (this lesson)

Older material sometimes says `/add server.py`. In current Claude Code, that shows **Unknown skill: add** because **`/add` is not a built-in command**. Instead:

- Type **`@`** and choose **`server.py`** (file-path autocomplete) in the same prompt as your request, **or** ask Claude to read `server.py` in plain language.
- Use **`/cost`** for token usage and **`/context`** for a context grid; type **`/`** alone to browse every command for your build.
- Leave the session with **`/exit`** or **`/quit`** (not `/done`).

If `claude` is missing in a new terminal but works elsewhere, your Node install (for example **nvm**) is not on `PATH` — run `source ~/.nvm/nvm.sh` first, or use the absolute path printed by `bash scripts/demo.sh`.

## Environment variables

1. Copy the example file:

   ```bash
   cp sample-api/.env.example sample-api/.env
   ```

2. Edit `sample-api/.env` and set `ANTHROPIC_API_KEY` for local runs. The API exposes a boolean `anthropic_key_present` in JSON responses; it does not echo the secret.

## Run with project scripts (recommended)

### Start the API (serves dashboard and JSON routes)

```bash
./start.sh
```

`start.sh` uses `sample-api/.venv/bin/python` when that venv exists; otherwise `python3`. It loads `sample-api/.env` if present and writes logs under `.pids/api.log`.

### Stop the API

```bash
./stop.sh
```

### Clean up processes and Docker

```bash
./cleanup.sh
```

This stops services managed by `stop.sh`, stops all running Docker containers (if the daemon is available), then prunes stopped containers, unused networks, dangling and unused images, build cache, and unused volumes. Expect local Docker images to be removed after a full stop plus `docker image prune -af`.

## Manual run (without `start.sh`)

### One-time: virtualenv and dependencies

```bash
cd sample-api
python3 -m venv .venv
. .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

### Load env and start the server

```bash
cd sample-api
set -a && [ -f .env ] && . ./.env; set +a
. .venv/bin/activate   # if you use a venv
python server.py
```

The app listens on the port configured in `server.py` (default Flask development port unless overridden).

### Manual stop

If you started `python server.py` in the foreground, use Ctrl+C. If you used `start.sh`, use `./stop.sh`.

## Lesson automation (checks + guided flow)

These scripts **do not** start the long-running Flask server. They only prepare the lesson, run checks, and print what to do next. Think of them as **bootstrap + validation**: useful every time you open the repo or after you change dependencies.

**Where to run them:** from `lesson-1-3-diff-loop/` (recommended). You can also run `bash verify.sh` or `bash demo.sh` from `lesson-1-3-diff-loop/scripts/`; both scripts locate the lesson root automatically.

### `bash scripts/verify.sh` — sanity checks

- Confirms **Claude Code CLI**, **Python 3.11+**, and **Flask** (preferring `sample-api/.venv`).
- Checks that **`CLAUDE.md`** exists and **`server.py`** still matches the expected shape.
- Runs **`pytest`** on `tests/test_server.py`.

Use this when you want a **quick green/red signal** before or after edits (including after Claude Code changes).

### `bash scripts/demo.sh` — guided walkthrough

- Ensures **`sample-api/.venv`** exists, upgrades **pip**, and **`pip install -r sample-api/requirements.txt`** (so async routes get **`Flask[async]`** / **`asgiref`** when applicable).
- Runs the **test suite** with short output so you see pass/fail lines.
- Prints **`server.py`** and a short narrative of what the lesson asks you to change with Claude Code.
- Prints **resolved `claude` path** when possible and reminds **nvm** users to `source ~/.nvm/nvm.sh` if another terminal cannot find `claude`.

Run this when you want the **full scripted onboarding** in one go.

### How this fits with the live app

**Automation scripts ≠ HTTP server.** They will not open `http://localhost:5000/...` by themselves.

- To **hit the API or dashboard in a browser**, start the server in **another terminal** using one of the earlier ways: **Way A** (`./start.sh`), **Way B** (`python server.py` from `sample-api/`), or **Way C** (`flask run` with `FLASK_APP=server:app`). Then use the URLs in the **URLs (default local)** section later in this guide.

That way you can: **Terminal 1** — `./start.sh` for the app; **Terminal 2** — `bash scripts/demo.sh` then `claude` for edits; refresh the dashboard as you go.

## After `demo.sh`: Claude Code next steps (numbered)

When `demo.sh` finishes, it points you at **`sample-api/`** and **Claude Code**. Follow this sequence for the core **diff-loop** exercise. (Claude Code **v2.1+** does not support `/add` or `/done`; the list below matches current behavior and the [Claude Code v2.1+](#claude-code-v21-this-lesson) notes above.)

1. **Start Claude Code in the API folder**  
   ```bash
   cd sample-api
   claude
   ```  
   Use the path under **your** clone (for example `.../day3/lesson-1-3-diff-loop/sample-api`). If `claude: command not found`, run `source ~/.nvm/nvm.sh` first, or use the **full path** that `demo.sh` printed for step 1.

2. **Bring `server.py` into the prompt (replaces old `/add server.py`)**  
   In the **same** message as your instruction, type **`@`** and pick **`server.py`** (path autocomplete), or type `@server.py` manually. Do **not** use `/add server.py` — in v2.1 that shows **Unknown skill: add** because `/add` is not a command.

3. **Ask for the lesson change**  
   After the `@server.py` chip (or on the next line in the same prompt), ask something like:  
   *Add structured logging using the logging module, and convert `health_check` to async*  
   Claude will read the file, propose a **unified diff**, and wait for your decision.

4. **Review the diff and accept or reject**  
   Read the patch. If it matches what you want and tests would still make sense, **accept** (typically **`y`**). If not, **reject** (**`n`**) or **edit** (**`e`**) depending on your UI — rejection is safe; you can refine the prompt and try again.

5. **Leave the Claude Code session**  
   Use **`/exit`** or **`/quit`** when you are done (not `/done`).

6. **Run tests again from `sample-api/`**  
   Prefer the venv Python so you use the same deps as `demo.sh`:  
   ```bash
   ./.venv/bin/python -m pytest tests/test_server.py -v
   ```  
   If you see **`Install Flask with the 'async' extra`**, reinstall: `./.venv/bin/python -m pip install -r requirements.txt`.

## Tests only

From `sample-api/` with dependencies installed:

```bash
. .venv/bin/activate   # optional
python -m pytest tests/test_server.py -v
```

## Optional: one-shot setup from repository `day3/`

The parent `day3/setup.sh` can generate or refresh lesson assets; run it from `day3/` as documented in that script’s header comments if you use it.

## URLs (default local)

After the API is running:

- Dashboard: `http://localhost:5000/dashboard`
- Health: `http://localhost:5000/health`
- Metrics: `http://localhost:5000/metrics`

Exact port follows `server.py` / Flask configuration.

## What not to commit

Keep `.env`, `.venv/`, `.pytest_cache/`, `.pids/`, and `*.log` out of version control; they are listed in `.gitignore`. Run `./cleanup.sh` before disk hygiene or when tearing down Docker state on a dev machine.
