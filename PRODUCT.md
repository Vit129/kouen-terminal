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

## Core Features
- **KouenTerminalEngine** — first-party Swift terminal renderer, tmux-style pane control
- **Daemon-persisted sessions/panes** — survive window close, remote/headless SSH
- **kouen-mcp** — embedded browser with MCP control, scriptable via JavaScriptCore
- **Multi-agent awareness** — Agents/Tasks/Board UI, per-agent status/color tinting
- Built-in code editor + LSP (21 languages), inline AI command suggestions (⌥Space)
- Sidebar Git workflows, Recipes/Composer/zoxide picker, hint mode
- Four experience modes: Plain Terminal, Persistent Terminal, Full Terminal, Agent Workspace

## Out of Scope
- General consumer distribution (personal fork, not shipped as a product)
- Non-macOS GUI (daemon/CLI/core build headless on Linux; GUI is macOS 15+ only)

## Success Metrics
- Multi-session agent workflows (task dashboard, MCP browser control) stay stable and usable as a daily driver

---
Sourced from README.md and Package.swift as of 2026-07-18.
