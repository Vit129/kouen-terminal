# Context — harness-terminal

## Now
- **Task:** idle
- **Branch:** `main`

### 2026-07-01 — P23 socket auto-detect (PBI-SSH-008) ✅ FIXED — P23 now Complete

Added `harness-cli socket-path` (prints `HarnessPaths.socketURL.path`) as the single source of
truth; `SSHTunnelManager.detectSocketPath(sshTarget:sshArgs:)` runs it over `ssh` reusing the
tunnel's existing arg-validation seams (`validatedSSHTarget`/`validatedUserSSHArgs`,
`isSafeArgumentToken`) — no new injection surface. Consumed by both surfaces: `SettingsRemoteView`'s
new "Detect" button (async off main thread via `RemoteHostsService.detectSocketPath`) and
`harness-cli remote add --detect` (alternative to passing `--socket` by hand). 3 new unit tests in
`SSHTunnelManagerTests.swift` using the existing injectable-process-seam pattern.

`swift build --product Harness` and `--product harness-cli` both clean. `swift test` could **not**
be run to completion — see Unresolved below (pre-existing, unrelated breakage). P23 moved to
`completed-archive.md`; plan file deleted.

### 2026-06-30 — Cmd+\ sidebar toggle gone after collapse ✅ FIXED

**Root cause:** B triggers A — zero-delta early exit in `applySidebarVisibility` returned without replacing `sidebarDisplayLink`, leaving the old collapse link running. Dead token guard (A) allowed it to continue despite `sidebarAnimToken` increment. Old link completed with `_sidebarVisible=false` → `panel.isHidden=true` → sidebar gone.

**Fix (MainSplitViewController.swift):** Move `sidebarDisplayLink?.invalidate(); sidebarDisplayLink = nil` to BEFORE reading `panel.frame.width` — kills in-flight animation before any early-exit path, making all return paths safe. Removed `[DBG-sb]` instrumentation.

See `knowledge/bugs/sidebar-cmdbackslash-toggle.md`.

### 2026-06-29 — Live perf profile of running Harness 3.11.7/183 ✅ (diagnosis only)

Profiled the actually-running app (PID via `ps aux | grep MACOS/Harness`; build mtime
newer than all fix commits → fixes ARE live).
- **Memory: CLEAN** — RSS ~110 MB, delta 0 MB over 3 s. No leak. The 34 GB / 21 GB leak
  fixes are confirmed working in build 183.
- **CPU: ~42%** — `sample` shows main thread ~33% in `NSHostingView.layout()` →
  `ViewGraph.updateOutputs(at:)`, i.e. a SwiftUI hosting view re-rendering its **whole**
  ViewGraph every display frame.
- **Root cause:** SwiftUI `.repeatForever` animation near a hosting-view root. Primary
  suspect `TerminalTabBarView.swift` `workingDot` (`.easeInOut.repeatForever`) — pulses
  while any tab is `working` (an agent was working during the profile). Same class as the
  Notch CPU bug.
- **FIXED (`dd7a78c`, pushed):** both `workingDot` and notch `NotchStatusDot` pulses moved off
  SwiftUI `.repeatForever` to `CABasicAnimation`/`CAAnimationGroup` on a CALayer (render server
  paints; ViewGraph no longer re-renders per frame). Build + robot guards green. Live CPU
  re-profile pending `make install` (running instance hosts this session). See
  `knowledge/bugs/notch-cpu-animation.md` Instance 2.

### 2026-06-29 — Claude Code statusLine/advisor/remote-control "broke after migrate" ✅

**User report:** statusLine, advisor, remote-control all stopped after the SwiftUI
settings migration → blamed the migration. **It was NOT the migration.**

**Root cause:** `~/.claude/settings.json` had `skillOverrides.deep-research: "disabled"`
(invalid; valid = `on|name-only|user-invocable-only|off`). **Claude Code 2.1.195**
(updated Jun 28) tightened validation and now **skips the ENTIRE settings.json** on any
single invalid value → `statusLine`, `advisorModel`, `remoteControlAtStartup`, `tui`,
`model` all ignored. Timing coincided with the Harness migration → looked migration-caused.

**Fix:** `"disabled"` → `"off"`. Verified: statusLine invocation 0 → 36 calls.

**Diagnostic that cracked it:** `script -q /dev/null claude` (real PTY) surfaced the
`SettingsError` startup dialog — invisible in background/`-p` sessions. See
`knowledge/cases/misc.md` CASE-057.

**Secondary (separate) issues:** remote-control needs re-auth (`daemon-auth-status.json`
= `auth_required`, cooldown expired → `claude --remote-control`); advisor on/off is a
per-session toggle by design (no persist field — only `advisorModel` persists).

---

## Previous
- **Task:** CPU peaks + memory guards session ✅ (`5cbbe82`, `ffb059a`, `81fe735` on main)
  - Phase-1/Phase-2 double snapshot fanout → payload-type guard in 5 UI observers + SnapshotCoalescer
- **Task:** tab-switch black screen ✅
- **Commits:** `f6a0182`, `2b9295d`, `1a2ca4c`, `9c5c1fa`, `0a5f2fe` on main (squash-merged from fix branch)
- **4 failure modes fixed:** detach-then-cache, structural rebuild caches empty shell, host theft, orphan overwrite

### Previous sessions (abbreviated)

| Date | Task | Key outcome |
|------|------|-------------|
| 2026-06-27 | otty-features P1–P20 | All phases shipped; P13/P21 deferred |
| 2026-06-26 | Memory-leak audit | existingHosts pin, BrowserPaneView cap, AI controller retire → v3.9.4 |
| 2026-06-26 | cwd bleed | deepestReadableDescendant removed; shell pid direct |
| 2026-06-25 | harness view | OSC 7735 → sidebar file viewer |
| 2026-06-23 | Sidebar SwiftUI | NSTableView removed; VC 1676 → 890 lines |

## Unresolved
- 2 pre-existing `swift test` failures unrelated to any recent work: `ExperienceModeTests.testShowsHarnessControlsDerivesFromMode`,
  `Phase6KeysTests.testRootTableSeededAndBindable`. Not investigated this session.

### 2026-07-01 — ACP-removal cleanup (items 1 & 2 from P23 wrap-up) ✅ FIXED
- **`swift test` couldn't build** — `Tests/HarnessCoreTests/ACPTransportTests.swift` and
  `Tests/HarnessMCPTests/StdioTransportTests.swift` referenced `ACPMessage`/`ACPTransport`/`TransportBuffer`
  removed by `c4e1e15` ("remove: ACP + ⌘I — erase as if never built"). Root cause for both this and the
  robot failure below.
  - `ACPTransportTests.swift` deleted — `ACPTransport`/`TransportBuffer` have no live equivalent (pure
    ACP transport-layer types, intentionally erased with no replacement).
  - `StdioTransportTests.swift` repaired, not deleted — it tests `MCPStdioBuffer`
    (`Tools/harness-mcp/Sources/HarnessMCP/StdioTransport.swift`), which is still live and already uses
    `JSONRPCMessage`. Swapped `ACPMessage` → `JSONRPCMessage`, replaced `ACPTransport.encode` with a local
    `contentLengthFrame` helper matching the same `Content-Length: N\r\n\r\n<body>` framing `StdioTransport.send` uses.
  - `swift test` now builds and runs 1673 tests (only the 2 unrelated failures above).
- Robot "Leak A - Retiring A Host Drops Its AI Controllers" stale assertion removed from
  `Tests/robot/memory_leak_guards.robot` — it checked for `aiChatControllers.removeValue`, a dict that
  `c4e1e15` deliberately deleted along with the ⌘I feature (only `inlineAIControllers` remains). All 10
  robot tests pass.
