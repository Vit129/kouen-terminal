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
- Completed: 9
- Remaining: 6

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
- [x] **Blocking prerequisite found while building D1 (2026-07-12):** the real incoming-frame ceiling is `MobileBridgeServer.maxWSFrameBytes` (was 64 KiB), enforced by `parseOneWSFrame`/`drainFrames` — NOT the 16 MiB `IPCCodec.maxPayloadLength` this doc originally assumed. Fixed: raised to 8 MiB (headroom above a 5 MiB raw file's base64 size) and swapped the `.oversized` abrupt `connection.cancel()` for `rejectAndClose` with a proper `{"error":"message too large"}`.
- [x] Add `.attachFile(name:mimeType:content:)` handling to `handleControlMessage` — decode base64, write to temp path via new `writeAttachedFile(name:data:)`, paste shell-quoted path into the attached surface's PTY input via `subscription.sendInput`. Reuses `KouenPaths.pastedImagesDirectory` (same dir/permissions/naming convention as desktop's `PasteController.writePastedImage`, not importable directly — AppKit target — so the convention is replicated) and `KouenSettings.ShellQuoting.quote` directly (importable, zero duplication — `KouenDaemonCore` already depends on `KouenSettings`). Filename comes only from the caller's extension, never a full path component, so `name` can't path-traverse.
- [x] Size cap on raw upload: reuses `maxFileReadBytes` (5 MiB, same constant D1 already defined) rather than inventing a second cap.
- [x] ✅ Run test scripts — `Tests/KouenDaemonTests/MobileBridgeAttachFileTests.swift` (5 tests: extension preserved, no-extension name, path-traversal-safe via extension-only usage, 0o644 permissions, 24h prune-on-write) — all pass. Full suite 80/80 (25 skipped, pre-existing sandbox noise), `Tests/robot/run.sh` 23/23.

### Client Application
- [x] Embedded page: attach affordance is a leading "Upload photo or file" row in the files sheet (locked design decision, see Phase E below — not a 4th toolbar icon), wired to a hidden `<input type="file">`. `FileReader.readAsDataURL` → strip the `data:...;base64,` prefix → `{"attachFile":{name,mimeType,content}}` over the existing control-frame channel. Client-side 5 MiB pre-check mirrors the server's own cap so an oversized pick fails fast instead of wasting a slow mobile upload.
- [x] ✅ Run test scripts — `swift test --filter MobileBridge` (85/85), `Tests/robot/run.sh` (23/23). Live-verified against a real isolated daemon (`make mobile-web`) through real Chrome: attached a session, opened the files sheet, dispatched the real `attachSelectedFile` client function against constructed `File` objects (native OS file-picker dialogs aren't automatable through the available browser tools) for both a text file and a binary PNG-header blob — both wrote correctly to `pasted-images/` (content byte-for-byte verified via `xxd`/`cat` on disk) and the shell-quoted path appeared typed into the live terminal, matching the desktop drag-drop flow's end state exactly.

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

## Phase E — Preview chrome redesign + tablet layout (locked design, not yet built)

Design session 2026-07-12, artifact: https://claude.ai/code/artifact/f97619f7-dff3-41b6-8df9-7d8bf4ff2f64 (frames 01–06; 05's docked side-panel was explored and explicitly rejected in favor of 06 — see decision below). Scope confirmed with user to start **after D2 ships**, not instead of it.

**Locked decisions:**
- File preview (D1's current `#view-file`, plain `<pre>`/`<img>`) gets replaced by a **tab strip + webview-style chrome**, ported from desktop's own `FileEditorTabBarView`/`FileTabPillView` (26px pill tabs, accent top-edge on active, `×` close — multiple files open at once, not one-at-a-time) and `BrowserPaneView`'s toolbar shape (back/forward/reload/path field, reused verbatim — path field just shows a file path today, becomes a real URL field once D3 lands and reuses the *same* chrome for a mirrored browser tab).
- Tablet (≥768px): persistent left rail replaces the phone's full-screen session list + bottom switcher sheet (mirrors the desktop app's own sidebar+terminal shape). Rail is independently collapsible (toggle in the terminal header collapses it to a 40px strip with just a reopen control + session-count badge — never a dead end).
- Opening a file (or later, a mirrored browser page) is a **full-screen takeover** on tablet — same pattern as Facebook/Instagram's in-app browser (SFSafariViewController-style): rail and terminal are fully hidden, not squeezed into a side panel. A single back button (top-left, same convention already used everywhere on this page) is the only way out, back to the terminal. On phone this needs no new layout — phone preview was already full-screen, it just gains the new tab-strip/webview chrome (frame 04).
- **Explicitly dropped:** the docked right-side panel (frame 05) — user's call after comparing both: a 300px panel is cramped for actually reading a file or a mirrored page; full-screen reads better for both phone and tablet, one pattern instead of two.

**Not yet task-broken-down** — do this properly (read the artifact, re-open `dev-architect`/`task-design` for this phase specifically) once D2 is fully shipped and committed. Flagging now only so it isn't lost: this is real new scope (multi-tab preview state, a new tablet breakpoint, rail collapse state, full-screen modal takeover), not a styling tweak on top of D1.

## Risks carried into implementation
- D3 interaction latency/touch-mapping is the one open UX question in the design — validate snapshot+ref-tap manually before investing in the screenshot-polling client UI.
- Real-phone E2E (camera QR scan → Safari → touch) still hasn't been done for any P37 phase, D included — scripted WS client only proves the protocol, not the on-device UX.
