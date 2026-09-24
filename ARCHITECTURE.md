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

**2026-09-23 — Mobile access: depend on each vendor's own remote-control app, don't build a
kouen relay/mobile client.** Surfaced while comparing kouen against Orca (which ships its own
iOS/Android app + cloud relay with X25519 pairing — see
`agent-memory/knowledge/architecture/orca-orchestrator-research.md`). Verified per vendor
(web search, 2026-09-23) rather than assumed:

- **Claude Code**: `claude remote-control` (v2.1.52+, Claude Max) bridges the actual local CLI
  session — the same one `kouen resumeCommand` launches — to the Claude mobile app / claude.ai/code
  via an outbound-only HTTPS connection (no inbound ports), QR-paired, with push notifications
  (`/config` → Push when Claude decides). CLI-level, not tied to Anthropic's own desktop app
  wrapper — works for a session kouen started same as any other terminal. **Confirmed fit.**
- **Codex**: ChatGPT mobile pairs with "Codex Mac app" via QR, loads live state, sends
  notifications on completion/input-needed. Officially documented as syncing "across your laptops,
  devboxes, or remote environments." **Not yet confirmed** whether this covers a bare `codex`
  CLI session launched inside a third-party terminal (kouen) the same way as sessions started
  through OpenAI's own Mac app wrapper — the docs describe the Mac app as the paired endpoint,
  not the CLI directly. Re-verify before relying on this for kouen-launched Codex sessions.
- **Antigravity**: shipped browser-based "Remote Control" (Aug 2026) plus a mobile companion that
  tunnels into a Mac and streams the active session. Antigravity's CLI (`agy`) and IDE share the
  same local data store (`~/.gemini/antigravity-cli/`, confirmed by `AgentHistoryScanner`'s own
  Antigravity scanner reading it) — plausible this covers `agy` CLI sessions too, but not directly
  confirmed reading the actual remote-control code path.

**Decision**: kouen stays a session *launcher* (resume commands, worktree isolation, unified
history across all four sources — the work landed 2026-09-23) and does not build its own
relay/mobile app. Reversal cost if this turns out wrong: low for now (no code deleted, just an
unbuilt feature), but gets more expensive the more kouen-specific UX (Fleet, Attention Beacon)
implicitly assumes "the phone story is someone else's problem." Trade-off accepted knowingly: no
unified cross-vendor mobile dashboard (Orca's actual differentiator) — a phone user checking on
4 concurrent agents needs 3 different apps (Claude, ChatGPT, Antigravity), each showing only its
own vendor's sessions, not kouen's Fleet view.

**2026-09-24 — Claude Code sessions default to `--cloud`; History reads `claude agents --json`
back for the reverse direction.** Two additions on top of the decision above, both still inside
its boundary (kouen reads a vendor CLI's own listing; it still doesn't run a relay or app):

- `claudeSessionMode` setting (default `cloud`) makes every kouen-launched Claude Code session
  (`kouenSpawnAgent`, `kouen-cli wake`, Automations, the ViEx spawn command) start with `claude
  --cloud`, so it shows up in the Claude Desktop/mobile app and claude.ai/code without an extra
  step. History resume uses `--remote-control` instead, since `--cloud` only resumes a cloud
  session by its own id, not an arbitrary local transcript.
- The reverse direction — a session opened from the Claude app showing up in kouen — has a real
  gap for `--cloud` sessions specifically: their transcript lives in the cloud container, never
  touches this disk, so the existing JSONL scan can't see them at all. `AgentHistoryScanner` now
  also shells out to `claude agents --json` (`AgentSessionPlacement`/`LiveClaudeAgentEntry`),
  merging cloud/background/remote-control rows into History by session id, with a resume command
  matched to how each one is actually reachable (`claude --cloud <id>` /
  `claude attach <id>`). `interactive`-kind rows are skipped — already covered by the JSONL scan,
  so merging them in too would only risk a duplicate. `claude attach`'s id has not been verified
  against a real `--bg` session (none available to test against while building this).

**2026-09-24 (later) — Revised after a live check on the Mac: default is Remote Control, not
cloud.** The first cut (above) defaulted to `--cloud` and assumed `claude agents --json` would
list account cloud sessions. Both were wrong for this project:

- **Default `remote-control`.** A cloud session runs in a Linux container, so it can't build or
  test Kouen (a macOS app needing Xcode), and loses local MCP/hooks/`$KOUEN_SURFACE`. Remote
  Control keeps the agent on the Mac and still shows it in the Claude apps. `cloud` stays
  available per-user in `settings.json`.
- **Hand-typed `claude` now follows the setting.** The first cut only covered commands Kouen
  typed itself; a user typing `claude` in a pane got a plain local session. The daemon now
  exports `KOUEN_CLAUDE_SESSION_MODE` and the shell integration wraps `claude()` (chaining to any
  existing user function, bypassable with `command claude`).
- **`claude agents --json` is machine-local.** It lists only sessions with a client on this
  Mac — confirmed by running it in a cloud session, where it listed just that session. There
  is no non-interactive CLI to list the account's cloud sessions, so cloud sessions started
  from the phone/web can't be auto-discovered; the supported route is `claude --teleport`
  (interactive picker). What Kouen *can* do: remember every cloud session it has seen live
  (`ClaudeCloudSessionStore`) so it stays in History after its pane closes.
- **Cloud resume is `claude --teleport <id>`.** `claude --cloud <id>` only attaches together
  with `-p` (post one message and exit), so the first cut's resume command would have failed.
