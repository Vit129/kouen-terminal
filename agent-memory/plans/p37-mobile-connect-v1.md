# P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable

> Continuation of P25 W1 (pairing MVP, shipped on `p25-mobile-web-mvp` `97afd2e4`).
> Numbered P37 because P35 (OAuth fix) / P36 (app icon) are already used — see plans INDEX.
> Design reference for the mobile client UI: `p25-mobile-session-switcher-design.html`
> (approved earlier — extend it, don't redesign).

## Current architecture (as shipped, build 195)

```
Kouen.app (GUI)
 └─ DaemonLauncher ── reads KouenSettings.mobileBridgeEnabled
     ├─ launchd path: LaunchAgentInstaller.install(mobileBridgePort:) → plist env var
     └─ DEBUG/preview path: spawnFallbackProcess(forceRestart:) → env var directly
KouenDaemon (launchd-owned)
 └─ main.swift: KOUEN_MOBILE_BRIDGE_PORT present → MobileBridgeServer.start()
     ├─ WS listeners  : loopback:7777 + tailscale:7777 (NWListener + NWProtocolWebSocket)
     ├─ Page listeners: loopback:8080 + tailscale:8080 (embeddedPageHTML, plain HTTP)
     ├─ Pairing loop  : 6-digit token, 15s lifetime, QR (half-block) → stdout, URL → daemon.log
     └─ PairedDeviceStore: persists device IDs, kouen-cli mobile-list-clients / mobile-revoke-client
Phone (Tailscale app, same tailnet)
 └─ Camera scan QR → http://<ts-ip>:8080/?token=NNNNNN&wsport=7777 → auto-connect WS
     → {"sessions":[…]} → attach/detach/spawn JSON control + binary PTY frames
```

## Risk review (ranked)

| # | Risk | Where | Severity | Phase |
|---|------|-------|----------|-------|
| R1 | **Token brute-force window**: 6-digit token, no attempt limit/throttle on WS auth. A hostile tailnet peer can hammer ~10^6 guesses across the 15s window with parallel connections. Tailscale membership is the only gate. | `receiveLoop` auth branch | High (within threat model "compromised tailnet device") | A |
| R2 | **"Paired device" persistence is cosmetic**: `PairedDeviceStore` registers devices, but reconnect auth still only accepts the *current 15s pairing token* — the store's own comment says a paired device shouldn't need a fresh QR scan, yet there's no re-auth-by-device-secret path. Every reconnect = walk to the Mac. | `receiveLoop` (auth only checks `pairingBox`) | High (UX + defeats the store's purpose) | A |
| R3 | **Everything runs on the daemon's `.main` queue**: all listeners and every connection (`connection.start(queue: .main)`, WS + page). One slow/flooding peer stalls the whole daemon event loop (PTY relay for every GUI pane included). | `makeListener` / `makePageListener` | Medium-High | A |
| R4 | **Port conflict is silent to the user**: 7777/8080 hardcoded; if squatted, listener fails with only a daemon.log line. Settings toggle looks on, nothing works, no UI feedback. (Already bitten once — a stale process squatted 8080 during W1 testing.) | `start()` error paths | Medium | B |
| R5 | **daemon.log grows forever while enabled**: pairing loop logs a URL every 15s (~5,760 lines/day) whether or not anyone intends to pair. | `runPairingLoop` | Medium | B |
| R6 | **No TLS on WS/page** — acceptable *only* because binds are loopback+Tailscale (WireGuard encrypts on the wire). Must stay that way; any future "bind LAN" change re-opens this. | design invariant | Low (documented) | — |
| R7 | **Embedded HTML string** in Swift: single source of truth (good) but no syntax checking; a bad edit ships silently. | `embeddedPageHTML` | Low | C |
| R8 | **QR only visible in daemon.log / dev console** — no in-app surface. Pairing UX requires reading a log file. | (gap, known since W1) | Medium (UX) | B |

## Phases

### Phase A — Hardening (daemon only, no UI)
- **A1 rate-limit pairing auth**: max 5 failed token attempts per pairing window across all connections → bridge refuses further auth attempts until the next token rotates; log the lockout. Constant-time token compare while at it.
- **A2 real device re-auth**: on first successful pairing, issue a per-device secret (UUID + random 32-byte token, stored in `PairedDeviceStore`, sent to the client once). Client stores it in `localStorage`; reconnect sends `{"deviceAuth":{"id":…,"secret":…}}` as the first TEXT frame instead of a pairing token. Revoke via existing `mobile-revoke-client` already cancels live connections — now it also invalidates the secret.
- **A3 move bridge off `.main`**: dedicated serial `DispatchQueue(label:"…mobile-bridge")` for listeners + connections. PTY data path already hops through `DaemonSubscription` callbacks — verify ordering guarantee (FIFO per connection) survives the queue change with a scripted-client echo test.
- Tests: extend the scripted WS client (`ws_probe.py` pattern) into `Tests/robot/` or a Swift test where feasible; lockout + re-auth round-trip + revoke-kills-secret.

### Phase B — In-app pairing UX (macOS Settings)
- **B1 IPC**: new `IPCRequest.mobilePairingInfo` → `IPCResponse.mobilePairingInfo(url: String?, secondsRemaining: Int, enabled: Bool)`. Daemon returns nil URL when bridge off.
- **B2 Settings ▸ Remote panel**: when toggle is ON, show native QR (reuse `CIQRCodeGenerator` → `NSImage`, ~200×200pt) + the URL + a countdown ring that refreshes with each token rotation. Errors surface here too (R4: "port 7777 in use — bridge not listening"). No more reading daemon.log.
- **B3 log hygiene** (R5): pairing loop only *logs* the URL when it changes state (start/stop/error); token rotations stop writing to daemon.log entirely — the GUI polls `mobilePairingInfo` instead.
- UI spec (native, matches existing Settings style — grouped Form):
  - Section "Mobile pairing" (existing toggle stays at top)
  - QR centered, `secondsRemaining` countdown as a thin `ProgressView` under it
  - URL as selectable monospace `Text` + copy button
  - Paired-devices list below (name, first-paired date, Revoke button) — data from `mobile-list-clients` IPC path

### Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted
- xterm.js terminal + session-switcher list per `p25-mobile-session-switcher-design.html` (dark terminal aesthetic already specified there — implementation agent reads that file for tokens/layout, does NOT invent a new design). Shipped: `@xterm/xterm` 5.5.0 + `@xterm/addon-fit` 0.10.0 vendored from jsdelivr (user-confirmed source), all four views from the design doc (home/paired-toast/list/term/sheet).
- Served the same way (embedded in daemon; consider moving to a generated-resource step if the string gets unwieldy — R7). Shipped as-is, embedded — R7 accepted as designed. One twist R7 didn't anticipate: minified xterm.js has literal C0 control bytes (raw ESC 0x1B for mouse-tracking), which a raw Swift string literal rejects outright — vendored as base64 in a new `MobileBridgeWebAssets.swift` instead, decoded once at load.
- Reconnect flow uses A2 device secret (no re-scan). Shipped, reused as-is from Phase A.
- Resize-sync (old W2) folds in here: client sends `{"resize":{cols,rows}}`, daemon forwards to PTY. Shipped: `FitAddon` → `term.onResize` → WS → `handleControlMessage` → `DaemonSubscription.resize()` (per-connection vote, not a fresh `DaemonClient`).
- Out of scope for v1: file preview/attach, git panel, LSP, notifications (former W4+). Still out of scope, untouched.
- Verified: build clean (app+daemon), `MobileBridgePairingTests` 11/11, robot 10/10, AND a live scripted-WS round-trip (auth → sessions → spawn → attach → resize → real PTY echo → detach) against an isolated daemon instance — not just build-green (see MEMORY.md 2026-07-09).
- **Not done:** real-phone scan E2E (only scripted/loopback verified); deploy to the actual running app (`make prod`/`install` + relaunch).

### Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped)

Extends the existing `{"attach"/"detach"/"spawn"/"resize"}` WS vocabulary on the same connection. No new bounded context, no new process — everything below runs inside the daemon (`MobileBridgeServer` already runs in-process there) or forwards through the daemon→GUI push channel `.activateGUIWindow`/`browserOpen` already use.

**Permission scoping — deliberately dropped.** The original p25 plan wanted a per-device "shell only" vs "shell+files" vs "shell+files+browser" grant field on `PairedDeviceRecord`. Checked: no such field exists today, and it shouldn't be added — a device with shell access already has file and browser reach transitively (`cat`/`curl`/`open` from the PTY itself). Gating D1-D3 behind a separate capability the shell already grants is complexity with no real security benefit under the existing "shell access is shell access" threat model (`p37` intro). Skip it.

- **D1 — File preview (read-only).** New WS request `{"readFile":{"path":"..."}}` → `{"file":{"path","mimeType","content","encoding":"utf8"|"base64","truncated"}}`; `{"listDirectory":{"path":"..."}}` → entry list, for the phone's own file picker. Reuse target: `ToolRegistry.readFile`/`.listDirectory` (`Tools/kouen-mcp/Sources/KouenMCP/ToolRegistry.swift:324-360`) — both are a bare `FileManager.default.contents(atPath:)`/`contentsOfDirectory`, no IPC hop, because the caller already runs on the same machine. Mobile bridge is in the same position (in-process in the daemon) — call `FileManager` directly, don't add a round-trip through anything. New case in `handleControlMessage` (`MobileBridgeServer.swift:1273`). Cap reads below `IPCCodec.maxPayloadLength` (16 MiB) with real headroom (e.g. 5 MiB, `truncated:true` past that) — base64 for images adds ~33%. Client: new message handlers + a preview overlay in the embedded page (`<pre>` for text, `<img src="data:...">` for images).

- **D2 — File/image attach (upload).** New WS request `{"attachFile":{"name","mimeType","content":"<base64>"}}`. Daemon decodes, writes to a temp path, then pastes the shell-quoted path into the attached surface's PTY input — mirror the desktop drag-drop flow exactly: `KouenTerminalSurfaceView+Find.swift:233-257` (dropped file URL → paste path) and `PasteController.writePastedImage` (dropped image → temp PNG → paste path); reuse `shellQuote` (`FilePreviewCoordinator.swift:352`) rather than re-deriving quoting rules. Client: `<input type="file">` in the terminal toolbar, base64-encoded over the existing JSON control-frame channel. Cap raw upload size below the same 16 MiB ceiling with margin for base64 overhead.

- **D3 — Browser mirror (embedded, not external-open).** Confirmed with user: mobile "browser" means driving the Mac's real `BrowserPaneView` (`Apps/Kouen/Sources/KouenApp/UI/Chrome/BrowserPaneView.swift`, P14) remotely, not an in-page WKWebView (impossible — Safari can't host one) and not opening the phone's own Safari (that was the old W5, rejected as too shallow a reading of "embed"). New WS requests: `{"browserNavigate":{"url"}}`, `{"browserSnapshot"}` (element-ref tree, same shape `kouenBrowserSnapshot` MCP tool already returns — `KouenBrowserTools.swift:126`), `{"browserInteract":{"ref","action"}}` (ref-based, reusing the *same* contract `kouenBrowserInteract` uses — `KouenBrowserTools.swift:172` — deliberately not raw x/y touch coordinates, which don't map cleanly onto a desktop-rendered page), and `{"browserFrame":{"png":"<base64>"}}` pushes sourced from `BrowserPaneView.screenshot()` (`:871`) for the visual view. Wiring: `MobileBridgeServer` forwards through the same `browserOpen`/`forwardBrowserRequest` IPC path (`DaemonServer.swift:837`) the MCP tools already use, targeting the active `BrowserPaneView` tab (or opens one via its existing `.show()`/`direction` param). Open risk: streaming cadence and interaction cost — start with snapshot+ref-tap only (zero new native code, MCP path already does this today) before adding screenshot polling; only add frame streaming if ref-only proves too sparse for a human visually scanning a page.

Task order: **D1 → D2 → D3**, each independently shippable. D1/D2 are pure WS-glue + reused daemon-local file I/O (small). D3 is pure WS-glue + reused MCP browser-control path (small) but carries the only real open UX question (interaction latency/mapping) — validate that early with a manual round-trip before polishing the mobile page around it.

## Verification gates (every phase)
- `swift build` + `swift test` green, `Tests/robot/run.sh` 10/10
- Live check against a real daemon (preview KOUEN_HOME flip, scripted WS client) — build-green alone is NOT done (see MEMORY.md 2026-07-07 lesson)
- Phase B: real phone scans QR from the Settings panel end-to-end
