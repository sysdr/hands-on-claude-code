# Lesson 1.3: Make Your First AI-Assisted Code Edit Using the Diff Loop

## Quick Start

```bash
# 1. Run the setup (from this directory)
bash setup.sh

# 2. Start the demo application (API + dashboard)
./lesson-1-3-diff-loop/start.sh

# 3. Run verification
bash lesson-1-3-diff-loop/scripts/verify.sh

# 4. Launch the interactive demo
bash lesson-1-3-diff-loop/scripts/demo.sh

# 5. Start the Claude Code session
cd lesson-1-3-diff-loop/sample-api
claude
```

## What You'll Learn

- How Claude Code's **diff loop** works: prompt → Claude generates diff → you review → accept/reject
- How to use **`@` file mentions** (for example `@server.py`) to bring files into the conversation — see the [interactive mode](https://docs.claude.com/en/docs/claude-code/interactive-mode) docs; the `/add` shortcut from older walkthroughs is **not** a command in Claude Code v2.1
- How **`/cost`** shows token usage (and **`/context`** visualizes context); type **`/`** to open the full command list
- How CLAUDE.md anchors Claude's understanding across edits
- Why rejecting a diff is safe and encourages iteration

## Lesson Structure

```
lesson-1-3-diff-loop/
├── README.md                 # This file
├── start.sh                  # Start API + dashboard
├── stop.sh                   # Stop services started by start.sh
├── sample-api/
│   ├── server.py            # Intentionally imperfect Flask app
│   ├── CLAUDE.md            # Project memory that anchors Claude's understanding
│   ├── requirements.txt      # Python dependencies
│   └── tests/
│       └── test_server.py    # Test suite (baseline: all should pass)
├── scripts/
│   ├── demo.sh              # Interactive walkthrough
│   └── verify.sh            # Verification checks
└── dashboard/
    └── index.html           # Simple dashboard that polls /metrics
```

## The Sample Code

`sample-api/server.py` is intentionally written with these issues:
- Uses `print()` for logging instead of structured logging
- `health_check()` is a separate function that could be inlined
- No async/await (CLAUDE.md says we're adding this)
- Metrics endpoint is stubbed out

This gives Claude something realistic and bounded to improve.

## The Workflow

1. **Before**: Tests pass; code is functional but inelegant
2. **Run Claude Code**: You'll use the diff loop to request improvements
3. **Accept diffs**: You review each change, then accept (y) or reject (n)
4. **After**: Tests still pass; code is cleaner and follows CLAUDE.md conventions

## Key Insights

### Why the Diff Loop Matters

In Claude.ai chat, you:
- Ask Claude to rewrite code
- Copy the response
- Paste it into your editor

With Claude Code's diff loop, you:
- Ask Claude to improve code
- Claude generates a unified diff
- You **review and accept** before it's applied to disk
- Rejection doesn't start from scratch; Claude stays in context

This is the core of why Claude Code changes developer workflow.

### CLAUDE.md is Your Anchor

The file `sample-api/CLAUDE.md` tells Claude:
- Your codebase uses Python 3.11, Flask, and async/await
- You're converting endpoints to async
- You want structured logging, not print()
- Error responses follow a specific JSON format

Without CLAUDE.md, Claude would suggest generic improvements. With it, every suggestion is grounded in your project's conventions.

## Troubleshooting

**Claude Code CLI not found?**
```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

**Python version error?**
- Check version: `python3 --version`
- Need 3.11+; macOS users may need to install Python separately

**`RuntimeError: Install Flask with the 'async' extra` when running tests?**
- Async routes need **`asgiref`**. From `sample-api/`: `.venv/bin/python -m pip install -r requirements.txt` (requirements use `Flask[async]` and pin `asgiref`).

**Tests failing after accepting a diff?**
- Run tests to catch issues: `pytest tests/test_server.py -v`
- If a diff breaks tests, reject it and ask Claude to fix it

**CLAUDE.md not being used?**
- CLAUDE.md is read at session start only
- If you change CLAUDE.md mid-session, exit with `/exit` (or `/quit`) and restart `claude`

## Next Steps

After completing this lesson:
- **Lesson 1.4**: Write a production CLAUDE.md for your own codebase
- **Lesson 2.1**: Learn context control in the current CLI (`/` menu, `@` mentions, `/compact`, `/cost`, `/permissions`, …)
- **Lesson 3.1**: Use `--print` and `--chat` flags for headless, scriptable workflows

## Deliverable

By the end of this lesson, you should have:
- ✅ Successfully used `claude` in interactive mode
- ✅ Accepted at least one diff from Claude
- ✅ Understood why the diff loop is safer than copy-paste
- ✅ Seen how CLAUDE.md influences Claude's suggestions
- ✅ Verified that tests still pass after your changes

---

**Duration:** 45 minutes  
**Prior lessons:** 1.1, 1.2  
**Next lesson:** 1.4 (Write a production CLAUDE.md)
