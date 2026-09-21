# Kouen Terminal — System Architecture

> Status: **active**. Companion to `PRODUCT.md` (vision/features), `DESIGN.md` (visual system & tokens), and `CONTEXT.md` (domain terms).

## Constraints & System Invariants

- **Swift 6 Strict Concurrency:** Tools version 6.0 with strict concurrency enforcement everywhere. `KouenCore` and `KouenTerminalEngine` have `-warnings-as-errors` enabled; any concurrency or deprecation warnings cause immediate build failure.
- **Concurrency Locks & Confinement:** `@unchecked Sendable` classes (`DaemonClient`, `DaemonServer`, `SurfaceRegistry`, `RealPty`, `DaemonLauncher`, `SurfaceIO`, `InputGate`, `SSHTunnelManager`) maintain strict lock/queue ownership invariants.
- **FIFO Terminal Stream:** `TerminalHostView` uses `DispatchQueue.main.async` + `MainActor.assumeIsolated` to preserve exact byte sequence order. Unstructured `Task { @MainActor in }` is forbidden on terminal byte replays.
- **Cross-Platform Separation:**
  - GUI and Metal renderer (`KouenApp`, `KouenTerminalRenderer`, `KouenTerminalKit`, `KouenOnboarding`) are macOS-only.
  - Headless core (`KouenDaemon`, `KouenCLI`, `KouenTerminalEngine`, `KouenCore`, `KouenCopyMode`, `CKouenSys`) build and run cross-platform on Linux.

## Product Identity Guardrail: Terminal, Not IDE

Added 2026-09-17 while scoping `agent-memory/plans/p45-orca-worktree-sessions/` (Orca-inspired
Worktree Lineage, Fleet Dashboard, History Hub, Diff Viewer, Issue Tracker Drawer, Browser
Design Mode Bridge) — adopting UI/UX patterns from IDE-shaped competitors (Orca, onorca.dev)
without letting Kouen's own identity drift from terminal-first to IDE.

**Working definition, sharpened against real evidence (Orca forks VS Code's shell but strips
this out; a stock VS Code + Copilot Chat window has it):**

IDE = has tooling bound to source code **as something to run/debug**, as a first-class citizen:
- A **Run** action/menu item
- A **Debug Console** (breakpoints, call stack — distinct from a plain terminal)
- A **Problems** panel (compiler/LSP diagnostics tied to specific file locations)
- **Ports** management for dev servers the app itself supervises

Orca has none of these despite being VS-Code-shaped — it's an agent-orchestrator wearing an
IDE's window chrome (explorer tree, side panels, tabs), not an IDE. That chrome (sidebar
tabs, file tree, split panes) is *not* the dividing line — Kouen already has sidebar tabs
(Sessions/Files/Git/Issues) and that alone doesn't make it an IDE either.

**The actual test for any new Kouen feature:** does it require a Run button, a
breakpoint/Debug Console, or a Problems panel showing inline compiler/LSP errors bound to a
file? If yes → that's IDE territory, out of scope. If it only reads/displays **process state**
(PTY/agent session) or **git state** (diff, worktree, branch) and dispatches actions back into
a real terminal pane — it stays terminal/orchestrator territory, in scope.

Checked against the P45 plan (all pass): Worktree Lineage & Fleet Dashboard (git/process
state only), History Hub — resuming a session always re-attaches a **real PTY** replaying
real CLI scrollback (`claude --resume <id>` etc.), never a separate chat-bubble/document
reader — Diff Viewer (reads git diff, no compile/lint), Issue Tracker Drawer (fetches
tickets, spawns worktrees/sessions), Browser Design Mode Bridge (forwards a CSS string to an
agent, never executes user code). `FileEditorView`/`DiffPaneView` do syntax highlighting only
— no LSP diagnostics, no breakpoints.

## Subsystems & Package Map

```
┌────────────────────────────────────────────────────────┐
│              KouenApp (macOS GUI App)                  │
│  - AppKit Windows, SwiftUI Sidebar, Git Panel          │
│  - Metal Glyph Renderer (KouenTerminalRenderer)        │
│  - AppKit Surface Host (KouenTerminalKit)              │
└──────────────────────────┬─────────────────────────────┘
                           │ Unix Domain Socket (IPC)
                           ▼
┌────────────────────────────────────────────────────────┐
│           KouenDaemon (Background Server)              │
│  - SurfaceRegistry (PTY Sessions & Lifecycle)          │
│  - Unix Domain Socket Server (chmod 0600)              │
│  - Scrollback Buffer & Hook Event Interception         │
└──────────▲───────────────────────────────▲─────────────┘
           │                               │
           ▼ Unix Domain Socket            ▼ Stdin/Pipes
┌──────────────────────────────┐ ┌───────────────────────┐
│     KouenCLI (Frontend)      │ │   ACP / Agent Hooks   │
│ - attach / send-keys         │ │ - Agent stdin pipe    │
│ - capture-pane / hooks       │ │ - LSP-style framing   │
└──────────────────────────────┘ └───────────────────────┘
```

| Package | Path | Role | Target Platform |
|---|---|---|---|
| `KouenCore` | `Packages/KouenCore/` | Shared foundation: IPC codec/client, commands, settings, keybindings, persistence. | All |
| `KouenTerminalEngine` | `Packages/KouenTerminalEngine/` | Pure-Swift VT100/Xterm parser and screen grid model. No AppKit/Metal. | All |
| `KouenCopyMode` | `Packages/KouenCopyMode/` | UI-agnostic keyboard copy-mode reducer. | All |
| `KouenTheme` | `Packages/KouenTheme/` | Theme catalog (`.kouentheme`), base64 embedded in `BundledThemesData.swift`. | All |
| `CKouenSys` | `Packages/CKouenSys/` | C shim for variadic `ioctl` and POSIX PTY helpers. | Darwin / Glibc |
| `KouenDaemonCore` | `Packages/KouenDaemon/` | Daemon library: socket server, PTY registry, lifecycle management. | All |
| `KouenCLI` | `Tools/kouen/Sources/KouenCLI/` | Command-line client (`attach`, `send-keys`, `capture-pane`). | All |
| `KouenTerminalRenderer` | `Packages/KouenTerminalRenderer/` | CoreText & Metal glyph atlas, GPU frame builder, wide-gamut sRGB/Display P3. | macOS |
| `KouenTerminalKit` | `Packages/KouenTerminalKit/` | AppKit terminal host view (`TerminalHostView`, gesture/input handling). | macOS |
| `KouenApp` | `Apps/Kouen/Sources/KouenApp/` | Native macOS application container and window manager. | macOS |

## Communication Protocols

1. **GUI ↔ Daemon ↔ CLI (Unix Domain Sockets):**
   - **Control Frames:** 4-byte big-endian length-prefixed JSON (`IPCCodec`). Max payload length is 16 MiB.
   - **PTY Hot Path (Output):** Binary frame with magic byte `0xF5` + sequence number + raw output bytes.
   - **PTY Hot Path (Input):** Binary frame with magic byte `0xF6` + target surface ID + raw keystroke bytes.
   - **Daemon Socket Security:** Socket file permissions are owner-only (`chmod 0600`); peer kernel UID is validated against `geteuid()`.
2. **Remote Daemon (SSH Tunneling):**
   - Managed via `SSHTunnelManager` (`ssh -N -L <local>:<remote>`) exposing a local loopback Unix endpoint with transparent IPC.

## Dev & QA Verification Invariants

| Component / Invariant | Requirement / Verification Rule |
|---|---|
| **Version Quad-Sync** | Release version must be atomic across `Info.plist`, `KouenVersion.swift`, `GeneratedReleaseNotes.swift`, and `CHANGELOG.md` via `prepare-release.sh`. |
| **Theme Catalog Sync** | Editing `themes.json` requires regenerating `BundledThemesData.swift` via `EXPORT_THEMES=1 swift test --filter ThemeCatalogEmbedTests`. |
| **Character Width Sync** | Changing Unicode width definitions requires re-running `Scripts/generate-width-table.swift` to regenerate `CharacterWidthTable.swift`. |
| **Regression Guard** | `Tests/robot/run.sh` and `swift test` must pass before any prod release build. |
| **Release Artifact Order** | Build order must follow `make release` ➔ `make sign` ➔ `make dmg` ➔ `make finalize` (creating DMG before signing breaks the signature). |

## Architecture Decisions (dated log)

**2026-09-21 — Agent safety net: shadow-git checkpoints + write-origin arbitration, not a VCS-level solution.**
P46 needed "undo the agent's last turn" and "don't let an agent clobber human work" without
requiring every project to adopt worktree-per-agent. Two decisions:

- **Checkpoints via a temporary `GIT_INDEX_FILE`, not `git stash` or a real commit.** `git stash`
  mutates the reflog/stash list the human is also using and can conflict with a stash they're
  mid-use of; a real commit on the active branch pollutes history the human didn't ask for.
  Building the tree with a throwaway index (`git read-tree HEAD` + `git add -A` + `git write-tree`
  + `git commit-tree`) and storing the result under `refs/kouen/checkpoints/<session>/<turn>`
  captures tracked+untracked state with zero visible side effect on the real index or branch.
  Cost: checkpoints are per-`cwd`+session, not a full VCS history browser — acceptable, since the
  only consumer is `kouen undo` reverting to the immediately-prior turn, not arbitrary time travel.
- **Write-origin tagging (`human`/`automation`) at the IPC layer, arbitrated in the daemon, not the
  GUI.** The alternative — a GUI-side "pause automation while I type" toggle — requires the human
  to remember to flip it. Tagging every `.send`/`.sendData`/`.sendKeys` call with its origin and
  refusing an `automation` write within 1.5s of the last `human` one, or onto a protected branch /
  dirty checkout with no worktree isolation, makes the safety default-on and enforced at the one
  choke point (`SurfaceRegistry.checkWriteOriginLocked`) every write path already goes through —
  including the daemon's own `0xF6` hot-path keystroke frame, not just CLI/MCP call sites (missed
  on the first pass, see `agent-memory/knowledge/cases/attention-fleet-hardening.md`).

**2026-09-21 — Two-tier verification is opt-in for tier1, always-manual for tier2.**
Running a syntax/build check (`tier1`) after every agent turn is cheap enough to default-enable
per-project via `set-option -g verify-on-turn on`; running the project's full test suite (`tier2`)
after every turn is not — a multi-minute suite on every turn would make agents feel like they've
stalled. `tier2` stays a deliberate `kouen-cli verify tier2` invocation, never automatic.

**2026-09-21 — Fleet sidebar tab: a notification destination, not a primary browsing surface.**
Fleet flattens every live tab across every workspace into one sortable list. Its value only shows
up with multiple concurrent agents across multiple workspaces/worktrees — a single-workspace,
few-tab session sees no visible difference from the existing Sessions tab. Kept as a full tab
(not collapsed into a popover) because the cost of keeping it is low and it's the correct landing
surface for a notification's "jump to this session" action; it is not expected to be opened and
browsed directly in normal single-agent use.
