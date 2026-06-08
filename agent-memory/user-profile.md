# User Profile

<!-- Stable preferences — update only when user explicitly changes them. -->
<!-- Loaded at session start alongside memory.md. -->

## Identity
- **Language:** Thai (interaction), English (docs/code/files)
- **IDE:** Kiro (Autopilot), Claude Code, Gemini CLI
- **Commits:** Conventional Commits

## Domain Expertise
- macOS/AppKit native development
- Swift 6 strict concurrency (actors, Sendable, MainActor isolation)
- Metal rendering pipeline
- Unix IPC (sockets, PTY, process management)
- Terminal emulator internals (VT parsing, grid model)

## Architecture Preferences
- Actor isolation over locks where possible
- Daemon-owned state for persistence
- Minimal external dependencies (one: Sparkle for auto-update)
- Cross-platform core (macOS GUI, Linux headless daemon+CLI)
- Binary tree models for recursive split structures

## Project Scope
- Single macOS app (Harness.app) with embedded daemon and CLI
- Target: developer terminal with IDE features (Zed-like sidebar, git, file editor)
- Agent integration via process-tree detection (passive) and ACP (active, shelved)
