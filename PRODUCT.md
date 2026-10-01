# Product

## Vision
An Agent Development Environment built around a native macOS terminal — a first-party terminal engine, session daemon, scriptable CLI, embedded MCP-controlled browser, and multi-agent orchestration (worktree-isolated sessions, headless workers, a safety net for agent turns). Terminal-first, not an IDE (see `ARCHITECTURE.md` § Terminal, Not IDE).

## Target Users
The maintainer (Vit129). Personal hard fork of `robzilla1738/harness-terminal`, not a distributed product. Built for running Claude Code / Codex / Gemini CLI / other agent CLIs side-by-side.

## Core Problems
- Standard terminals aren't built for supervising multiple concurrent AI coding agents
- No native way to give agents controlled browser/MCP access from inside the terminal
- Session state dies with the terminal window / SSH connection
- No lightweight task tracking across agent sessions
- An agent's bad turn corrupts the working tree with no fast way back except a manual `git diff`/`git checkout` scramble
- An agent and a human (or two agents) can write to the same checkout concurrently with nothing to arbitrate who wins
- No single view of what many concurrent agents across many workspaces are actually doing, or which one needs attention

## Core Features
- **KouenTerminalEngine** — first-party Swift terminal renderer, tmux-style pane control
- **Daemon-persisted sessions/panes** — survive window close, remote/headless SSH
- **kouen-mcp** — embedded browser with MCP control, scriptable via JavaScriptCore
- **Multi-agent awareness** — Agents/Tasks/Board UI, per-agent status/color tinting
- Built-in code editor + LSP (21 languages)
- Sidebar Git workflows, Recipes/Composer/zoxide picker, hint mode
- Four experience modes: Plain Terminal, Persistent Terminal, Full Terminal, Agent Workspace
- **Agent safety net** — automatic per-turn checkpoints (`kouen-cli undo`), two-tier build/test verification (`kouen-cli verify`, opt-in `verify-on-turn`), and write-origin guards refusing an automation write onto a protected branch, a dirty unisolated checkout, or a surface a human is actively typing in
- **Turn review & context tools** — Turn Diff Reviewer (⌘⌥D) to accept/revert an agent's last turn against its checkpoint; Quick Context Injector (⌘K) to resolve `@diff`/`@file`/`@last`/`@error`/`@builderror` tokens straight into a prompt
- **Fleet view** — one sidebar tab flattening every live session across every workspace, needs-attention-first, reached mainly via a notification's "jump to session" action
- **`kouen-cli history`/`task pack-pr`** — cross-session agent transcript search/resume, and PR-description assembly from a tracked feature's diff/gates/checklist
- **Orchestrator & Agent Swarm (P44)** — a CLI agent decomposes a goal into Tasks, spawns headless or interactive Workers, and drives them to merge-ready with a bounded auto-fix loop; inline task status on tabs and sidebar
- **Automations & Jobs view** — scheduled agent launches (`kouenAutomation*` MCP tools) with a Jobs fleet view and result viewer
- **Worktree-first sessions** — worktree lineage/drift tracking, per-ticket isolated worktrees from the Issue Tracker, auto-isolate that no longer strands the primary checkout (P45, P47)
- **History across agents** — Claude Code, Codex, Antigravity, Copilot and VS Code Copilot Chat sessions in one list, resume in place, or hand off between agents (v4.20.0); ◀ ▶ previous/next-session buttons beside the sidebar toggle (P48)
- **Per-agent launch modes** — local, remote-control or cloud per agent via a data-driven launch table (P50); default is remote-control so sessions appear in the vendor's mobile/desktop app while staying on the Mac
- **Agent Notch HUD** — menu-bar-notch summary of agent status (off by default)
- **`kouen-mcp` remote transport** — HTTP/SSE in addition to stdio, with secure defaults

## Out of Scope
- General consumer distribution (personal fork, not shipped as a product)
- Non-macOS GUI (daemon/CLI/core build headless on Linux; GUI is macOS 15+ only)
- Own mobile app or relay. Mobile access relies on each vendor's remote-control app (Claude app / claude.ai/code, ChatGPT for Codex, Antigravity remote control); Codex and Antigravity coverage of CLI sessions launched inside Kouen is not yet verified. The earlier Mobile Connect bridge (P37) and native iOS app (P25) are closed; the bridge code remains, deprecated and off by default. See `ARCHITECTURE.md` § Architecture Decisions (2026-09-23).
- IDE features: Run button, debug console, breakpoints, Problems panel

## Success Metrics
- Multi-session agent workflows (task dashboard, MCP browser control) stay stable and usable as a daily driver

---
Sourced from README.md and Package.swift as of 2026-07-18; extended 2026-09-21 with the P46 agent safety net and 2026-09-30 with P44–P50 (orchestrator/swarm, automations, worktree-first sessions, cross-agent history/handoff, launch modes) — see `ARCHITECTURE.md` § Architecture Decisions for the reasoning behind each.
