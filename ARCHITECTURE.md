# Kouen Terminal — System Architecture

> Status: **active development**. Companion to `PRODUCT.md` (what/why), `DESIGN.md` (visual layout), and `CONTEXT.md` (domain terms).

## Constraints

- **Platform:** macOS 15+ (Sequoia) for AppKit/SwiftUI GUI; daemon and CLI build headless.
- **Concurrency:** Swift 6 strict concurrency with `-warnings-as-errors` on `KouenCore` and `KouenTerminalEngine`. Warnings fail the build.
- **Persistence:** Running shells and background agent tasks must survive GUI window close and app updates.
- **Security:** Daemon UNIX domain socket is restricted to user-only (`0600`), rejecting connections with different UIDs.

## Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                 KouenApp (SwiftUI / AppKit)                 │
│  - Tabs, Panes, Composer, GitPanelView, Task Dashboard UI   │
│  - WebKit Browser Pane (Design Mode, Inspection)            │
└──────────────┬───────────────────────────────┬──────────────┘
               │                               │
               │ IPC Socket (JSON / Binary)    │
               ▼                               ▼
┌──────────────────────────────┐ ┌─────────────────────────────┐
│         KouenDaemon          │ │          kouen-mcp          │
│ - RealPty / PTY management   │ │ - Embedded Browser Control  │
│ - Session & Surface Registry │ │ - Tasks CRUD Resource       │
│ - DaemonClient / Server      │ │ - Worktrees CRUD Resource   │
│ - Scrollback buffer stream   │ │ - Automations & Hosts API   │
└──────────────┬───────────────┘ └─────────────┬───────────────┘
               │                               │
               ▼                               ▼
┌──────────────────────────────┐ ┌─────────────────────────────┐
│     KouenTerminalEngine      │ │    External Agent CLIs      │
│ - Swift ANSI parser          │ │ - Claude Code / Codex / AGY │
│ - Metal / CoreText renderer  │ │ - Worktree-isolated workers │
└──────────────────────────────┘ └─────────────────────────────┘
```

### 1. KouenTerminalEngine
First-party terminal emulator engine written in pure Swift:
- High-performance ANSI escape sequence parser.
- Terminal character grid and custom rendering.
- Replaces generic third-party terminal wrappers with deep agent-session hooks.

### 2. KouenDaemon & IPC Framing
Background daemon maintaining session state and PTY instances across app restarts:
- **Control channel:** 4-byte big-endian length-prefixed JSON.
- **Hot PTY byte path:** Binary framed with magic byte `0xF5` (PTY output) and `0xF6` (PTY input) to minimize JSON serialization overhead.
- **Byte Ordering Invariant:** Terminal output is dispatched via `DispatchQueue.main.async` + `MainActor.assumeIsolated` to ensure strict FIFO byte ordering; `Task { @MainActor }` is prohibited on the byte stream.
- **Payload bounds:** `IPCCodec.maxPayloadLength` capped at 16 MiB.

### 3. Agent Integration & kouen-mcp
Kouen does not build a proprietary agent brain; it exposes an MCP server for existing CLI agents (Claude Code, Antigravity, Codex):
- **Worktree Management:** Creates and manages git worktrees under `.kouen-worktrees/` for concurrent isolated agent branches.
- **Task Management:** Session-scoped task items accessible and modifiable by agents via MCP tools.
- **Embedded Browser:** MCP-controlled WebKit instance enabling autonomous testing and web exploration directly from the terminal.

## Data Model & Storage

- **Stores:** `SurfaceRegistry`, `RecipesStore`, `RemoteHostStore`, `OutputTriggerStore`.
- **Atomic Release:** Versioning requires atomic synchronization across `Info.plist`, `KouenVersion.swift`, `GeneratedReleaseNotes.swift`, and `CHANGELOG.md` via `prepare-release.sh`.
