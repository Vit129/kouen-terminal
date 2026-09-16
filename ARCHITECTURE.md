# Kouen Terminal — System Architecture

> Status: **active**. Companion to `PRODUCT.md` (vision/features), `DESIGN.md` (visual system & tokens), and `CONTEXT.md` (domain terms).

## Constraints & System Invariants

- **Swift 6 Strict Concurrency:** Tools version 6.0 with strict concurrency enforcement everywhere. `KouenCore` and `KouenTerminalEngine` have `-warnings-as-errors` enabled; any concurrency or deprecation warnings cause immediate build failure.
- **Concurrency Locks & Confinement:** `@unchecked Sendable` classes (`DaemonClient`, `DaemonServer`, `SurfaceRegistry`, `RealPty`, `DaemonLauncher`, `SurfaceIO`, `InputGate`, `SSHTunnelManager`) maintain strict lock/queue ownership invariants.
- **FIFO Terminal Stream:** `TerminalHostView` uses `DispatchQueue.main.async` + `MainActor.assumeIsolated` to preserve exact byte sequence order. Unstructured `Task { @MainActor in }` is forbidden on terminal byte replays.
- **Cross-Platform Separation:**
  - GUI and Metal renderer (`KouenApp`, `KouenTerminalRenderer`, `KouenTerminalKit`, `KouenOnboarding`) are macOS-only.
  - Headless core (`KouenDaemon`, `KouenCLI`, `KouenTerminalEngine`, `KouenCore`, `KouenCopyMode`, `CKouenSys`) build and run cross-platform on Linux.

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
