# Product

## Vision
Native macOS terminal built for AI agent workflows — one app combining a first-party terminal engine, session daemon, scriptable CLI, embedded MCP-controlled browser, and multi-agent awareness.

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
- Built-in code editor + LSP (21 languages), inline AI command suggestions (⌥Space)
- Sidebar Git workflows, Recipes/Composer/zoxide picker, hint mode
- Four experience modes: Plain Terminal, Persistent Terminal, Full Terminal, Agent Workspace
- **Agent safety net** — automatic per-turn checkpoints (`kouen-cli undo`), two-tier build/test verification (`kouen-cli verify`, opt-in `verify-on-turn`), and write-origin guards refusing an automation write onto a protected branch, a dirty unisolated checkout, or a surface a human is actively typing in
- **Turn review & context tools** — Turn Diff Reviewer (⌘⌥D) to accept/revert an agent's last turn against its checkpoint; Quick Context Injector (⌘K) to resolve `@diff`/`@file`/`@last`/`@error`/`@builderror` tokens straight into a prompt
- **Fleet view** — one sidebar tab flattening every live session across every workspace, needs-attention-first, reached mainly via a notification's "jump to session" action
- **`kouen-cli history`/`task pack-pr`** — cross-session agent transcript search/resume, and PR-description assembly from a tracked feature's diff/gates/checklist

## Out of Scope
- General consumer distribution (personal fork, not shipped as a product)
- Non-macOS GUI (daemon/CLI/core build headless on Linux; GUI is macOS 15+ only)

## Success Metrics
- Multi-session agent workflows (task dashboard, MCP browser control) stay stable and usable as a daily driver

---
Sourced from README.md and Package.swift as of 2026-07-18; Core Problems/Features extended 2026-09-21 with the P46 agent safety net (checkpoints, verification, write-origin guards, Fleet view) — see `ARCHITECTURE.md` § Architecture Decisions for the reasoning behind each.
