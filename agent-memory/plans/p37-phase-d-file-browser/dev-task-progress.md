# Dev Task Progress — P37 Phase D: File preview, file attach, browser mirror

Last updated: 2026-07-12
Status: In Progress

## Context

Continuation of P37 (mobile bridge). Pairing, real xterm.js client, and resize-sync already
shipped (v4.3.0+). Phase D is the former W4/W4b/W5 from the superseded p25 plan, confirmed by
user still needed: file preview, file/image attach (upload), and an embedded browser mirroring
the Mac's real `BrowserPaneView` (not an external Safari open, not an in-page WKWebView —
platform-impossible on a Safari PWA page).

No new bounded context. Everything runs inside the existing daemon process (`MobileBridgeServer`)
or forwards through the existing daemon→GUI push channel. Per-device permission scoping (file vs
shell vs browser) was considered and dropped — shell access already implies file+browser reach
transitively, so gating them separately adds nothing under the existing "shell access is shell
access" threat model.

## Artifacts
- Design: `agent-memory/plans/p37-mobile-connect-v1.md` (## Phase D section)
- Test Scripts: none pre-existing — this project verifies via `swift test --filter` + `Tests/robot/run.sh` + a scripted live-daemon WS client (see P37's own verification gates), not a TDD-skeleton-first flow

## Summary
- Total tasks: 15
- Completed: 5
- Remaining: 10

## D1 — File preview (read-only)

### Server Logic
- [x] Add `.readFile(path:)` / `.listDirectory(path:)` handling to `MobileBridgeServer.handleControlMessage` (`MobileBridgeServer.swift`) — plain `FileManager` read/list in-process via new pure statics `readFileInfo(path:)`/`listDirectoryEntries(path:)`, same pattern as `ToolRegistry.readFile`/`.listDirectory`. No IPC round-trip — bridge already runs in the daemon process.
- [x] MIME/encoding detection: text-vs-binary split reuses the exact UTF-8-decode check `ToolRegistry.readFile` already uses (no extension allowlist needed for the split itself); binary gets a small extension→mimeType map (`imageMimeTypesByExtension`: png/jpg/jpeg/gif/webp) for `<img>`-able types, `application/octet-stream` otherwise.
- [x] Size cap: 5 MiB read ceiling (`maxFileReadBytes`), `truncated:true` past that. Correction from original plan: outgoing WS frames aren't capped by `IPCCodec.maxPayloadLength` at all (that's the separate control-socket IPC) — `encodeWSFrame` has no send-side limit, so 5 MiB is a sanity cap, not a protocol requirement.
- [x] ✅ Run test scripts — `Tests/KouenDaemonTests/MobileBridgeFilePreviewTests.swift` (7 tests: utf8 text, binary→base64+image mime, unknown-ext→octet-stream, missing path, directory-as-file, sorted listing with isDirectory flags, missing dir) — all pass. Full `swift test` green except a pre-existing, unrelated `UNUserNotificationCenter` sandbox crash documented at `SessionCoordinatorTypes.swift:51` (macOS-install-specific, nothing to do with this change). `Tests/robot/run.sh` 23/23.

### Client Application
- [x] Embedded page: files sheet (reuses `.list-header`/`.sessions`/`.session-card` classes as-is — zero new list CSS needed) with drill-in/up navigation, opened via a new 📁 toolbar button in `.term-header`; preview view (`#view-file`, wired into the existing `goto()` view switcher) renders `<pre>` for text, `<img src="data:...">` for images, a fallback message for anything else.
- [x] ✅ Run test scripts — `swift test --filter MobileBridge`, `Tests/robot/run.sh` (23/23) both green. Additionally verified LIVE against a real isolated daemon (`make mobile-web`) through a real Chrome tab (not just the WKWebView `kouenBrowserOpen` pane — that one silently failed to open the WS connection at all, root cause not yet understood, noted below as a follow-up rather than blocking this task): full flow exercised — pair → session list → attach → open files sheet (defaulted to the session's own cwd) → drill into `subdir` (renders "Empty directory") → up-navigate back → open `notes.txt` (renders exact text content) → open `pixel.png` (renders the actual base64 image). All matched expectations exactly.

**Note for later:** `mcp__kouen__kouenBrowserOpen` (Kouen's own WKWebView browser pane) opened this page fine but its WebSocket connection silently closed with no error reaching the daemon at all (`ws.onerror` fired client-side, zero corresponding connection ever logged server-side) — worth a follow-up investigation (WKWebView ATS or App-Bound Domains restriction is the leading guess) since it means that pane can't currently be used to dogfood mobile-bridge pages from the desktop app itself. Not a regression from this change and not blocking — real Chrome and (per P37's own gates) a real phone are the actual target clients.

## D2 — File/image attach (upload)

### Server Logic
- [ ] **Blocking prerequisite found while building D1 (2026-07-12):** the real incoming-frame ceiling is `MobileBridgeServer.maxWSFrameBytes` (64 KiB, `MobileBridgeServer.swift:1502`), enforced by `parseOneWSFrame`/`drainFrames` — NOT the 16 MiB `IPCCodec.maxPayloadLength` this doc originally assumed (that governs the separate control-socket IPC, unrelated to this WS transport). A base64-encoded photo upload will exceed 64 KiB immediately. Worse: `drainFrames`'s `.oversized` case does an abrupt `connection.cancel()` (`:1370`) — kills the whole session with no error shown to the client, the exact "abrupt cancel clobbers the error" anti-pattern this file's own P37 comments elsewhere warn against (see `rejectAndClose`, added specifically to avoid it). Before writing the attach handler: raise `maxWSFrameBytes` to a real upload ceiling (a few MiB) AND swap the `.oversized` abrupt cancel for `rejectAndClose` with a proper `{"error":...}` message. Outgoing frames (D1's `readFile` responses) are unaffected — `encodeWSFrame` has no send-side cap.
- [ ] Add `.attachFile(name:mimeType:content:)` handling to `handleControlMessage` — decode base64, write to temp path, paste shell-quoted path into the attached surface's PTY input. Reuse `PasteController.writePastedImage`'s temp-file convention and `shellQuote` (`FilePreviewCoordinator.swift:352`) — mirror `KouenTerminalSurfaceView+Find.swift:233-257`'s drop-to-paste flow exactly, don't re-derive quoting/temp-path rules.
- [ ] Size cap on raw upload, enforced against the new `maxWSFrameBytes` ceiling (not 16 MiB).
- [ ] ✅ Run test scripts — new tests: attach writes file + pastes correct shell-quoted path, oversize rejected, no attached surface → clean error

### Client Application
- [ ] Embedded page: `<input type="file">` in terminal toolbar (accept="*/*", camera capture where available), base64-encode + send over existing JSON control-frame channel.
- [ ] ✅ Run test scripts — `swift test --filter MobileBridge`, `Tests/robot/run.sh`

## D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView)

### Server Logic
- [ ] Add `.browserNavigate(url:)` / `.browserSnapshot` / `.browserInteract(ref:action:)` handling to `handleControlMessage` — forward through the existing `browserOpen`/`forwardBrowserRequest` IPC path (`DaemonServer.swift:837`) the MCP tools already use, targeting the active `BrowserPaneView` tab (open one via `.show()`/`direction` if none active).
- [ ] `.browserFrame` push: periodic base64 PNG from `BrowserPaneView.screenshot()` (`:871`) — start disabled/manual-refresh only; do not build continuous polling until D3's snapshot+ref-tap path is validated live (see risk note below).
- [ ] ✅ Run test scripts — new tests: navigate reaches a real `BrowserPaneView` tab, snapshot returns the same ref-tree shape `kouenBrowserSnapshot` MCP tool returns, interact-by-ref lands on the right element

### Client Application
- [ ] Embedded page: browser view — url bar, snapshot-driven tappable ref list/overlay (not raw x/y hit-testing), manual "refresh frame" button for the screenshot view.
- [ ] ✅ Run test scripts — `swift test --filter MobileBridge`, `Tests/robot/run.sh`

## Integration
- [ ] End-to-end wiring — full flow through one connection: attach → readFile/listDirectory → attachFile upload → browserNavigate/snapshot/interact, no reconnect needed between capabilities
- [ ] ✅ Run all test scripts (verify GREEN) — `swift build`, `swift test`, `Tests/robot/run.sh` 10/10+
- [ ] Live check against a real (isolated `KOUEN_HOME`) daemon via scripted WS client — per P37's own verification gate, build-green alone is NOT done (MEMORY.md 2026-07-07 lesson)
- [ ] Code review — `review-personas`, then the standing lesson: review against `agent-memory/knowledge/rl-lessons.md` + `cases/*.md` before calling multi-file new-feature work done

## Risks carried into implementation
- D3 interaction latency/touch-mapping is the one open UX question in the design — validate snapshot+ref-tap manually before investing in the screenshot-polling client UI.
- Real-phone E2E (camera QR scan → Safari → touch) still hasn't been done for any P37 phase, D included — scripted WS client only proves the protocol, not the on-device UX.
