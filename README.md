# Hands-On Claude Code & Claude Skills: From Zero to Production-Ready AI Workflows

## Why This Course?

AI-assisted development is no longer optional — it is the new baseline for engineering velocity. Most developers have used Claude.ai to answer a question or explain code. Very few know how to make Claude a first-class, automated member of their engineering workflow: reviewing PRs without being asked, writing and running tests, enforcing coding standards across a monorepo, or packaging reusable AI capabilities their entire team can install in two minutes.

This course closes that gap. It goes far beyond "prompt Claude in a chat box" and teaches you to wire Claude Code into your terminal, your CI pipeline, and your GitHub Actions — then build, test, evaluate, and ship custom Claude Skills that extend what Claude can do for your specific domain.

Every lesson is hands-on. Every module ends with something deployed and working.

---

## What You'll Build

By the end of this course you will have shipped the following real artifacts:

1. A `CLAUDE.md` project memory file that gives Claude persistent context about your codebase, coding standards, and hard constraints.

2. A shell script that batch-processes an entire codebase — adding type hints, replacing `console.log` with structured logging, or enforcing naming conventions — using Claude Code in headless mode.

3. A self-healing test pipeline: Claude Code writes unit tests, runs them, reads the failures, and patches the implementation — all without human intervention.

4. A GitHub Actions workflow that automatically reviews every PR diff, posts a structured review comment with categorised findings (bugs, security, missing tests), and requires zero manual setup per repo.

5. A custom MCP server (Node.js) that exposes a `search-docs` tool backed by a local documentation index, registered and usable inside Claude Code sessions.

6. A standup-formatter Claude Skill (`SKILL.md`) with a formal eval set, a passing quality score from the description optimizer, and a packaged `.skill` file your teammates can install from a README in under 5 minutes.

7. A multi-turn AI chatbot React Artifact that calls the Anthropic API directly, maintains conversation history in state, and handles structured JSON output.

8. A drag-and-drop PDF analyser Artifact that accepts file uploads, converts them to base64, sends them as document blocks to the API, and renders summary, key points, and action items.

9. A production-ready PR assistant: a `SKILL.md` with three action handlers, a bundled Python changelog script, a GitHub Actions headless pipeline, and a 10-case eval set with >80% pass rate — all packaged and documented for distribution.

---

## Who Should Take This Course?

This course is built for anyone who writes, reviews, designs, or ships software professionally and wants Claude working as an automated, reliable team member — not just a chat assistant.

- Software Engineers and Developers who want to automate repetitive workflow tasks: code review, test writing, documentation, and style enforcement.
- System Engineers and DevOps/SRE Engineers who want Claude Code running in CI/CD pipelines, reviewing diffs, and enforcing standards.
- Software Architects and Tech Leads who want to package reusable AI capabilities as Claude Skills and distribute them across teams.
- Product Managers and Engineering Managers who want to understand capability and cost tradeoffs of Claude Code vs API usage.
- QA Engineers who want automated test generation, coverage gap detection, and self-healing pipelines.
- Data Engineers and Technical Writers building AI-powered interactive artifacts.
- UI/UX Designers prototyping AI-powered interfaces using the Anthropic API.
- IT consultants and technical writers entering AI-augmented workflows.

Fresh CS/CE graduates are welcome. Only prerequisites are terminal comfort and basic coding experience.

---

## What Makes This Course Different?

1. Every lesson has running code and a clear expected output — not theory-only.
2. Claude Code (Modules 1–4) and Claude Skills (Modules 5–8) are treated as distinct systems with real integration.
3. The Skill evaluation loop is real: `evals.json`, `run_loop.py`, and measurable trigger accuracy.
4. Honest coverage of cost and authentication models (Pro vs API keys, real tradeoffs).
5. The capstone ships a real, production-ready tool with onboarding documentation.

---

## Key Topics Covered

### Claude Code Fundamentals

- Installation, authentication (Pro vs API key), and when each applies  
- Interactive session management: `/add`, `/remove`, `/status`, `@file`, glob patterns  
- `CLAUDE.md` project memory design and constraints  
- Headless mode with `--print` and `-p`  
- Piping shell data (git diff, logs, tests) via stdin  
- Bash automation scripts for large-scale refactors  
- Self-healing pipelines (generate → run → fix loop)  
- GitHub Actions CI integration for PR review  
- MCP protocol, config, CLI usage, and tool schemas  
- Official MCP servers (filesystem, GitHub, inspector)  
- Building custom MCP servers in Node.js  

### Claude Skills Fundamentals

- Skill anatomy: YAML + Markdown + resources  
- Writing high-performance description fields (trigger optimization)  
- Progressive disclosure with references/  
- Skill folder structure (`scripts/`, `references/`, `assets/`)  
- Skill intent documentation  
- Manual testing strategies and edge case handling  
- Iteration using `skill-creator`  
- Bundled scripts and execution patterns  
- Multi-domain Skills with routing logic  
- `evals.json` structure and evaluation strategies  
- Description optimizer (`run_loop.py`) workflow  
- Packaging and distributing `.skill` files  

### Anthropic API in Artifacts

- Calling `/v1/messages` from React  
- Structured JSON prompting and UI rendering  
- Multi-turn conversation state management  
- MCP integration in API calls  
- PDF upload, base64 handling, and structured output  

---

## Prerequisites

### Required

- Terminal/CLI familiarity  
- Basic coding experience (Python or JavaScript preferred)  
- Claude.ai account (Pro recommended)  
- Node.js 18+  

### Helpful (Optional)

- Git & GitHub familiarity  
- Basic API/HTTP understanding  
- Intro-level React exposure  

### Not Required

- Prior Claude Code / Skills experience  
- AI/ML background  
- CI/CD experience  

---

## Course Structure

The course includes 9 modules and ~30 hours of hands-on work.

### Part 1 — Claude Code (Modules 1–4, ~14 hours)

Covers installation → automation → MCP tools → CI pipelines.

### Part 2 — Claude Skills (Modules 5–8, ~14 hours)

Covers Skill creation → testing → evaluation → distribution.

### Capstone (Module C, ~2 hours)

Build a full PR assistant combining:
- Claude Skill  
- GitHub Actions pipeline  
- MCP integration  
- Evaluation gate  

---

## Lesson Structure

Each lesson includes:

- **Concept** — core understanding  
- **Task** — hands-on objective  
- **Code** — working implementation  
- **Expected Output** — clear success criteria  

---

## Curriculum

### MODULE 1 — Environment Setup & First Session (3 hours)

- 1.1 Install Claude Code  
- 1.2 First interactive session  
- 1.3 AI-assisted code edit  
- 1.4 Write `CLAUDE.md`  
- 1.5 VS Code integration  

### MODULE 2 — Core Commands & File Context (3 hours)

- 2.1 Context management commands  
- 2.2 File mentions  
- 2.3 Glob patterns  
- 2.4 Multi-file refactoring  
- 2.5 Permission modes  

### MODULE 3 — Agentic & Headless Workflows (4 hours)

- 3.1 `--print` automation  
- 3.2 Shell piping  
- 3.3 Batch scripting  
- 3.4 Self-healing pipelines  
- 3.5 GitHub Actions integration  

### MODULE 4 — MCP Servers & Custom Tools (4 hours)

- 4.1 MCP config  
- 4.2 Filesystem server  
- 4.3 GitHub server  
- 4.4 Custom MCP server  
- 4.5 Debugging tools  

### MODULE 5 — Anatomy of a Claude Skill (3 hours)

- 5.1 SKILL.md breakdown  
- 5.2 Description optimization  
- 5.3 Progressive disclosure  
- 5.4 Folder structure  
- 5.5 Packaging & install  

### MODULE 6 — Writing & Testing Your First Skill (4 hours)

- 6.1 Intent doc  
- 6.2 Full SKILL.md  
- 6.3 Test cases  
- 6.4 Manual testing loop  
- 6.5 Iteration workflow  

### MODULE 7 — Advanced Skill Patterns (4 hours)

- 7.1 Bundled scripts  
- 7.2 Multi-domain Skills  
- 7.3 evals.json  
- 7.4 Optimizer  
- 7.5 Distribution  

### MODULE 8 — Anthropic API in Artifacts (3 hours)

- 8.1 First API call  
- 8.2 JSON output  
- 8.3 Multi-turn state  
- 8.4 MCP in API  
- 8.5 PDF analyser  

### MODULE C — CAPSTONE (2 hours)

- C.1 Architecture design  
- C.2 Build SKILL.md + handlers  
- C.3 GitHub Actions pipeline  
- C.4 Eval + optimizer (>80% pass)  
- C.5 Package and onboarding README  
