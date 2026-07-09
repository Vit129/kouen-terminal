# Context — harness-terminal

## Now
- **Task:** in progress — nested-iframe wheel-scroll fix in browser pane needs manual retest (see below). P35/P36 archived to `plans/completed-archive.md` (2026-07-06). All uncommitted on `main`, along with earlier review action items (H5, H6, notification Step 1, S1).
- **Branch:** `main`
- **Pending:** manual test of `kickCompositorRelayout` scroll fix (repeated scroll over several seconds on the claude.ai artifact URL — watch `kouen.scrollprobe moved=true/false` in the browser console log; a single successful scroll is NOT enough, v1 of this fix looked fine once then failed) — see `knowledge/ui/browser-pane.md`. Also: review action checklist in REVIEW-graphify-harness-2026-07-03.md — remaining: notification Step 2/3 (system-level, needs user), graphify G1/G3/G4 (different repo).

### 2026-07-09 — S1 daemon-restart contradiction fixed (Agy claim → Opus-verified → Sonnet-implemented), re-confirmed independently; UNCOMMITTED
`main` (not a feature branch — `p25-mobile-web-mvp` was merged + released as v4.1.0 outside this session, confirmed via `git log`; all work below sits on top of that on `main`).

Root cause (confirmed real by an Opus verification pass, tracing the actual call chain): `install-graceful.sh` deliberately preserves a running daemon across a release when its IPC protocol version matches (protecting live PTYs/agent sessions) — but `DaemonLauncher.daemonIsStale` → `DaemonStats.isStale` only ever compared the **build** number, never protocol/surfaces. So every UI-only release: install-graceful preserves the daemon → app relaunches → `ensureRunningBlocking` sees old build → `restartStaleDaemon()` kills the "preserved" daemon seconds later anyway, defeating the entire point of S1.

Agy (external tool) proposed a fix but framed it as "split into two branches" and overstated that `bundledDaemonIsNewer` would defeat ANY fix unconditionally — Opus verification found the two-branch shape already exists (build-mismatch vs build-match), the real fix is a `return false` guard inserted inside the existing build-mismatch branch (protocolVersion match + surfaceCount>0 → preserve), and Agy's "unconditional" framing was only true for a naive fall-through fix, not a `return false` one. Sonnet then implemented exactly that.

**Fixed:** `DaemonLauncher.daemonIsStale` (now internal, was private, for `@testable` access) returns false early when `stats.protocolVersion == ipcProtocolVersion && stats.surfaceCount > 0` inside the build-mismatch branch — bypassing `bundledDaemonIsNewer` (which would otherwise force a restart anyway, since `refreshInstalledBinaries()` just gave the on-disk binary a fresh mtime). Nil protocolVersion still falls through to true (old daemons that predate the stats field still restart, correctly). New `Tests/KouenAppTests/DaemonLauncherTests.swift` (5 tests) — re-confirmed independently (not just trusting the subagent): `swift build` clean, `--filter DaemonLauncherTests` 5/5, `Tests/robot/run.sh` 10/10.

**Not live-verified** (honest gap, stated by the implementing agent and not disputed): this is an install/launch-lifecycle fix, hard to safely exercise end-to-end without a real install cycle, which was correctly out of scope for an agent to run against production. Also surfaced in passing: `kouen-cli daemon-stats` SIGSEGVs reproducibly (both debug build and preview bundle CLI, with/without KOUEN_HOME) — pre-existing, unrelated to this fix, not chased (out of scope), worth a look separately.

### 2026-07-09 — Agy second-opinion review of P37 → Opus-verified → Sonnet-fixed, 4 more mobile-bridge hardening bugs closed; UNCOMMITTED
Pipeline: Agy CLI (external tool, known to sometimes hallucinate) reviewed the just-landed P37 hardening → 4 findings → a separate Opus agent independently re-derived each from the real code before trusting any fix → confirmed 3, downgraded 1 (magnitude overstated), corrected 2 of Agy's suggested fixes outright (would have violated this codebase's own locking discipline) → a Sonnet agent implemented the Opus-corrected fixes only. Re-verified independently by main thread after (SourceKit had thrown a stale false-positive "member not found" diagnostic — real `swift build`/`swift test` were clean; don't trust IDE diagnostics over the actual build here).

**Fixed:** (1) revocation-bypass via connection shadowing — `registerLive` now cancels the previous live connection before overwriting the map entry; teardown only removes an entry if it's still reference-identical (`===`) to the connection tearing down, so closing an older shadowed connection can't delete a newer live one out from under `mobile-revoke-client`. (2) unbounded WS frame size pre-auth — Agy's fix (token-length pre-check) was incomplete; real fix is `wsOptions.maximumMessageSize = 64KB`, closing the actual DoS surface (a 200KB frame now gets WS close code 1009). `constantTimeEquals` left untouched — its lack of a length fast-path is intentional timing-safety, not a bug. (3) race in attach/spawn control-message handling — `DispatchQueue.global()` replaced with a private serial `controlQueue` per `ConnectionState`; Agy's suggested fix (hold a lock across the block) would have held a lock across blocking `DaemonClient` IPC calls, an anti-pattern this codebase explicitly avoids elsewhere — rejected in favor of per-connection serialization instead. (4) slowloris on both the page listener AND the WS listener (Agy only flagged the page one) — 5s watchdog cancels an idle pre-response/pre-auth connection; verified an authorized connection is never falsely killed.

Verified: `swift build` clean, `MobileBridgePairingTests` 11/11 (new: `testShouldRemoveLiveEntryOnlyMatchesTheCurrentConnection`), `swift test --filter KouenDaemon` 179 executed 0 failures, `Tests/robot/run.sh` 10/10 — all re-confirmed independently by the main thread, not just taken from the subagent's report. Live-verified against the preview daemon: forced the exact Fix-1 race via a real deviceAuth reconnect while the old connection stayed open (worked — the task brief had flagged this as "may be hard to force externally," it wasn't), oversized-frame rejection, and both slowloris watchdogs timing out at ~5s.

**Lesson for next time a second-opinion tool is used:** don't apply its suggested fixes directly — verify the claimed bug AND the claimed fix separately; a real bug can still come with a wrong fix (2 of 4 here did).

### 2026-07-09 — P37 Phase A+B done (Opus subagent) + whole-app architecture review, both verified; UNCOMMITTED
**P37 A+B** (plan: `plans/p37-mobile-connect-v1.md`, implemented by Opus subagent, independently re-verified — build clean, MobileBridgePairingTests 10/10, robot 10/10, live preview-daemon WS checks all passed): A1 pairing lockout (5 attempts/window, constant-time compare), A2 device-secret re-auth (SHA-256-at-rest via dependency-free `SHA256Mini` — CryptoKit absent on Linux build; 30-day expiry; legacy-record migration; client stores credentials in localStorage, reconnects without QR), A3 all bridge I/O moved off daemon `.main` onto dedicated `bridgeQueue` (117-marker ordering test passed), B1 `IPCRequest.mobilePairingInfo` (**ipcProtocolVersion 2→3** — deliberate, so install-graceful restarts the daemon and hardening actually activates), B2 Settings ▸ Remote native QR panel (NSImage QR, countdown, copy URL, paired-device list + Revoke, port-conflict error surface), B3 daemon.log pairing spam removed. Remaining accepted risks: client localStorage plaintext (Phase C: PWA/biometric), per-device scopes, live-session expiry. Phase C (xterm.js client) not started. Real-phone-scan-from-Settings-panel E2E still needs the user.

**Architecture review** (second read-only subagent, deliverable `REVIEW-architecture-2026-07-08.md` repo root): A1-High **S1 self-defeating** — install-graceful preserves daemon on protocol match but relaunched GUI's *build*-inequality staleness check (`DaemonStats.swift:55`) kills it seconds later anyway (fix: don't restart when protocolVersion matches + surfaces active); A2-High hooksPath pointed at deleted pre-rename dir (hooks silently dead for weeks) — **fixed same session** (`git config core.hooksPath .githooks`); A3 installer infers running-daemon protocol from on-disk CLI (invalidated by `refreshInstalledBinaries` every launch — query live daemonStats instead); A4 `identifyClient` handshake only guards `kouen-cli -CC`, new IPCResponse cases hard-break old clients; A5 `RecipesStore.load()` clobbers corrupt file with defaults (sole store bypassing `backupCorruptFile`); A6 preview mobile-bridge restart no-ops on prior-run fallback daemons; A7 release pipeline has zero test gate (`verify` = build only); A8 "mktemp failed" test spam root-caused = tearDown deletes KOUEN_HOME before ScrollbackFile's debounced flush — test-env artifact, production unaffected. Concurrency + FIFO patterns spot-checked clean. **A1/A3/A5/A6 unfixed — next candidates.** Note: graphify index stale for untracked files (resolves new MobileBridgeServer to old Spikes path until committed + reindexed).

### 2026-07-08 — P25 mobile terminal: production wiring — Settings toggle enables MobileBridgeServer in the real app
Follows the QR/auto-connect fixes below (real-phone scan already confirmed those work, and confirmed the isolated dev daemon's "no sessions" gap — that's what surfaced this work).

**Built:** `KouenSettings.mobileBridgeEnabled: Bool` (default off, `KouenSettings.swift`) — persisted like any other app setting, no daemon involvement to read/write it. `LaunchAgentInstaller.plist`/`install` (`LaunchAgentInstaller.swift`) take an optional `mobileBridgePort: UInt16?`; nil (default) omits `KOUEN_MOBILE_BRIDGE_PORT` from the generated plist entirely, a value embeds it — reuses the installer's existing content-diff bootout/rewrite, no new mechanism. `DaemonLauncher` (`DaemonLauncher.swift`) reads the setting via `mobileBridgePortIfEnabled()` and threads it into both the launchd path (`installLaunchAgentIfPossible`/`restartStaleDaemon`) and the DEBUG/preview fallback-process path (`spawnFallbackProcess`, now takes `forceRestart:` to actually kill+respawn instead of no-op'ing when one's already running). New `restartForMobileBridgeSettingChange()` is the toggle's restart cue — this setting isn't covered by the existing build-handshake staleness check, so flipping it needs an explicit kick rather than waiting for the next `ensureRunning` poll. UI: `SettingsRemoteView` (Settings ▸ Remote) gained a "Mobile pairing" toggle + explanatory caption at the top, calling `model.update(\.mobileBridgeEnabled, _)` then `DaemonLauncher.shared.restartForMobileBridgeSettingChange()`.

**Design decisions (confirmed with user via AskUserQuestion before writing code):** Settings toggle (not always-on, not a menu item) · bind loopback+Tailscale only, unchanged from the dev path · **restart-required** on toggle (not a live IPC start/stop) — simpler, reuses existing daemon-restart machinery, accepted trade-off is agents/PTYs surviving the restart same as any app-update restart, not zero-disruption.

Tests: new `LaunchAgentInstallerTests.testMobileBridgePortOmittedByDefaultButEmbeddedWhenGiven` (nil→omitted, value→embedded). `swift test --filter KouenSettingsTests` 37/37, `swift test --filter LaunchAgentInstallerTests` 3/3, `swift build` (KouenSettings/Kouen/KouenDaemon/kouen-cli) clean, `Tests/robot/run.sh` 10/10.

**Live-verified against a real preview daemon (not just build/unit level):** flipped `mobileBridgeEnabled` in the preview KOUEN_HOME's `settings.json` directly (isolated, safe — same file the toggle would write), killed the stale preview daemon, `make preview` rebuilt+relaunched. `daemon.log` showed `mobile bridge: listening on 127.0.0.1:7777 and <tailscale-ip>:7777`; a scripted WS client (stands in for a phone, same technique as the earlier W1 bug hunt) connected with the printed token and got back the **real** open preview session (`"tabTitle":"zsh in supavit.cho"`), not an empty list — confirms the Settings-toggle → `DaemonLauncher` → `LaunchAgentInstaller`/fallback-process wiring genuinely reaches the real `SurfaceRegistry`, unlike the isolated `make mobile-web` dev daemon.

**Found + fixed a second real gap this same session:** `curl http://127.0.0.1:8080/mobile-web-test.html` on that live preview daemon returned connection-refused — `MobileBridgeServer` only ever *printed* a URL pointing at a page (`mobile-web-test.html`); nothing served it. That page was only ever reachable in the dev flow because `Scripts/mobile-web.sh` separately ran `python3 -m http.server` next to the daemon — production/preview daemons (spawned by `DaemonLauncher`, no such script involved) never had anything listening on the page port at all, so the printed QR/URL was silently unusable by a real phone. **Fixed:** `MobileBridgeServer.swift` now embeds the page HTML directly (`embeddedPageHTML`, single source of truth) and serves it itself via a new `makePageListener` (plain HTTP, same loopback+Tailscale-only bind scope as the WS listeners, `Connection: close` per request). `Scripts/mobile-web-test.html` deleted (content now lives in Swift); `Scripts/mobile-web.sh` simplified — no more spawning/cleaning up a separate `python3 -m http.server` process. Re-verified after this fix: `curl` returned HTTP 200 with the correct page (`Content-Length: 3856`, right `<title>`), and the WS session-list probe above still returned the real session — both listeners coexist correctly. `swift test --filter KouenDaemon` 168/168 (52 skipped, pre-existing), `Tests/robot/run.sh` 10/10 after this fix too.

**Still not done:** an actual phone camera scanning the actual QR end-to-end (this session's verification used curl + a scripted WS client standing in for the phone/browser, not a real device) — that's the natural next check, and needs the user (no native macOS UI automation or physical phone available to this agent).

### 2026-07-08 — P25 mobile terminal: 3 more live-test bugs found + fixed on `p25-mobile-web-mvp`, QR retest PASSED
Continuing W1 live-testing (the "not yet done" real-usage pass from 07-07's entry below).

**Fixed:** (1) pairing QR too big to fit the terminal pane — `qrAsciiArt` (`MobileBridgeServer.swift`) switched from double-width-block-per-module (78x39 chars) to the half-block trick (▀▄█ packs 2 module-rows per terminal row, same technique as `qrencode -t utf8`) → 39x17 chars, confirmed square by user's live retest. A middle attempt (quadrant-block, packing a 2x2 module block per char → 20x17) was tried and reverted — it visibly stretched the QR non-square (user screenshot), and more fundamentally doesn't reduce the true on-screen pixel footprint at all (that's fixed by module-count × font-size, not by ASCII-packing scheme) — see MEMORY.md lesson. (2) No auto-connect on QR scan — `mobile-web-test.html` only pre-filled the token field, required a manual Connect click, and the pairing token's 15s lifetime routinely expired before the tap; now calls `connect()` immediately when `?token=` is present in the URL. (3) A stale `.kouen-preview` daemon (unrelated PID, pre-dated this session) kept serving the OLD QR code across `make preview` relaunches because S1's daemon-reuse skips restart when `ipcProtocolVersion` is unchanged — killed manually, not a code bug.

**Clarified, not a bug:** `make mobile-web`'s smoke-test daemon shows zero sessions when paired from a phone — by design (`Scripts/mobile-web.sh` runs a fully separate `KouenDaemon` process against an isolated `/tmp/kouen-mobile-web-<hash>` `KOUEN_HOME`, its own `SurfaceRegistry`, never the real running Kouen.app's sessions). Real gap surfaced by this: production `Kouen.app` had no wired-up way to enable `MobileBridgeServer` itself — **now built same day, see the entry above** (Settings ▸ Remote toggle).

**Real-phone scan test: DONE, not "never done" — user directly confirmed** (this is literally how the "doesn't show real sessions" isolation-gap was found — scanned with a real phone against the `make mobile-web` isolated daemon, QR was square/scannable, connect worked, and the empty session list was the observation that led to the production-wiring work above). Correcting the 07-07 entry below, which still says this was never done.

### 2026-07-07 — P25 mobile terminal: W1 (all 4 slices) done and live-verified, branch `p25-mobile-web-mvp`
Separate branch, separate concurrent track from the `main`-branch browser-pane work above — does not touch it. Full detail: `agent-memory/plans/p25-ios-ipados-support.md` (section "Web/PWA MVP — Phased Build Plan").

**Done:** moved `Spikes/MobileBridgeSpike`'s WS↔daemon bridge into real `KouenDaemonCore` (`MobileBridgeServer.swift`, opt-in via `KOUEN_MOBILE_BRIDGE_PORT`, binds loopback+Tailscale only); persistent disk-backed multi-device pairing (`PairedDeviceStore.swift`, `kouen-cli mobile-list-clients`/`mobile-revoke-client`, `ipcProtocolVersion` bumped 1→2); multiplexed session-switcher protocol (one token grants the whole daemon — `{"sessions":[...]}` push, `{"attach"/"detach"/"spawn"}` JSON control + binary PTY frames on one connection); `make mobile-web` isolated dev target (`Scripts/mobile-web.sh` + `mobile-web-test.html` smoke-test page).

**7 real bugs found via direct testing** (not just build-green — a Python `websockets` client stood in for a phone, later also verified against a real `make preview`-spawned GUI daemon): NWListener EINVAL (duplicate port spec), EADDRINUSE binding two interfaces same port (needed `allowLocalEndpointReuse`), QR invisible when stdout isn't a TTY (needed `fflush`), **`MobileBridgeServer()` was an unretained temporary — ARC killed it right after `start()` returned, silently no-opping every closure inside it** (biggest one — build/tests were green throughout but the bridge had never actually run), spurious `"surface ended"` on ordinary detach (cancel-before-nil ordering bug), QR pointed at bare `/` instead of the actual page file (directory listing instead of the page), and a stale unrelated process squatting the default page port on this machine (environmental, not code).

**Not yet done:** a real phone has still never scanned the QR (only scripted WS clients + the real daemon so far); W2 (resize-sync), W3 (real xterm.js frontend), W4+ (file preview/attach, git panel, LSP, notifications) not started. Also open: no in-app way to see the pairing QR yet (only `daemon.log` or `make mobile-web`'s console) — noted as follow-up in the plan doc.

### 2026-07-06 — Nested cross-origin iframe won't wheel-scroll — fix implemented, UNVERIFIED
claude.ai artifact URLs render content in a nested cross-origin iframe; wheel/trackpad scroll over that content does nothing in Kouen's browser pane (scrollbar drag works, ordinary pages scroll fine, Safari scrolls the same artifact fine — Kouen-specific). Root cause via Opus subagent deep-dive: WebKit's async scrolling thread never builds a scrolling-tree node for the nested iframe at initial layout (WebKit bugzilla 124139); a magnification change forces the commit that builds it — matches the user's own observation that pinch-zooming made scroll start working. Fix: `kickCompositorRelayout(for:)` nudges `webView.magnification` briefly, triggered by an in-frame script on the nested frame's first `pointermove`/`wheel` (not a blind timer — an earlier version fired before the iframe mounted). Known unresolved risk flagged by the investigation itself: the revert-to-original step could re-drop the node if it's fragile, reproducing an earlier "scrolled a little then stopped" symptom from an abandoned JS-polyfill attempt (v1, different mechanism, already removed). A `#if DEBUG` probe logs scrollTop before/after each wheel event to the existing `kouenConsoleLog` file pipe — needs `moved=true` to persist across several repeated gestures, not just one, before trusting this. Full ledger: `knowledge/ui/browser-pane.md`.

### 2026-07-06 — P35 fixed: Google OAuth login in browser pane (`BrowserPaneView.swift`)
Plan doc's original hypothesis (Google's anti-phishing embedded-webview block) was wrong — live repro via `make preview` reached the Google consent screen fine (that block fires before login). Real bug: `createTab` called `.load()` on the popup webview `createWebViewWith` had already created — WebKit auto-loads `navigationAction.request` into a returned view, so the redundant `.load()` started a second, disconnected navigation that severed `window.opener`. Confirmed via injected `console.log('opener=' + (window.opener ? 'set' : 'null'))` diagnostic (routes through the existing `kouenConsoleLog` pipe to a per-pane `/tmp` file, not app stdout — `$TMPDIR` for a directly-launched GUI binary is `/var/folders/.../T/`, learned the hard way after `/tmp/kouen-browser-*.log` came up empty). `opener` was `null` on every popup navigation, ruling out COOP (would break real Safari too). Fix: `createTab(..., skipLoad:)` skips the load on the popup path, `createWebViewWith` returns the view (was `nil`), added missing `webViewDidClose` (JS `window.close()` was a no-op, orphaning Google's `gsi/transform` relay tab). Verified end-to-end: login → Allow → popup closes → claude.ai artifact loads authenticated. Full detail: `knowledge/ui/browser-pane.md`.

### 2026-07-06 — P36 (app icon dark mode) closed
See `agent-memory/plans/p36-app-use-white-dark-auto-mode.md` — light-only shipped (mark recolor + white-edge fix), OS-native dark swap not built (decision, not a bug — opaque icon isn't affected by system appearance either way).

### 2026-07-03 (cont'd) — Wired S1 into the actual daily release flow
User asked "what happens if I run `make start` full cycle now" — traced the real call chain (`start.mjs` → `full-cycle.sh` Step 4 → was `make install` → `install-app.sh`) and found S1 had ZERO effect on it: `install-app.sh` kills daemon+GUI unconditionally before build, no protocol check, plus wipes session state via `clear-runtime-state.sh` (incompatible with graceful's preserve-state goal — never call both). Fixed: `full-cycle.sh` Step 4 now calls `Scripts/install-graceful.sh` directly instead of `make install`.

### 2026-07-03 — Implemented review fixes: H5, H6, notification Step 1, S1 daemon-reuse ✅ DONE, not committed
- **H5:** `Scripts/install-graceful.sh` — `UID_NUM=$(id -u)` computed in parent, interpolated as literal into the detached child script (old `\$(id -u)` never expanded, `launchctl bootout` silently no-op'd).
- **H6:** `.gitignore` + `git rm --cached graphify-out/graph.json` (file stays on disk).
- **Notification Step 1:** `DesktopNotifier.show` (`SessionCoordinatorTypes.swift`) moved from background queue to `DispatchQueue.main.async` (NSAppleScript is main-thread-only), logs the error instead of discarding, `sendTest`/Settings UI (`SettingsAgentsView.swift`) show real success/failure via a `@MainActor @Sendable` completion.
- **S1 (the big one — install/build no longer kills running agent tasks for UI-only releases):** Added `DaemonStats.protocolVersion` + `harness-cli protocol-version` (no-daemon-required, prints the compile-time `ipcProtocolVersion` constant). `install-graceful.sh` compares installed-CLI vs new-build-CLI protocol version; daemon restart (and the `launchctl bootout`/`pkill` sequence) is skipped entirely when they match — only the GUI restarts, PTYs/agents under the daemon survive. Applies to both the "GUI running" (detached nohup) and "GUI closed, daemon detached" branches.
- Verified: full `swift build` clean, `swift test --filter DaemonStatsTests` 6/6, isolated bash dry-run of match/mismatch detection logic, `Tests/robot/run.sh` 10/10. Not yet committed — user hasn't asked to commit.

### 2026-07-03 — Review: graphify + harness-terminal ✅ DONE (Sonnet-5 verified)
Deliverable: `REVIEW-graphify-harness-2026-07-03.md` (repo root). Key findings:
- **Notifications not showing:** `DesktopNotifier.show` runs `NSAppleScript` on a background queue (main-thread-only API), swallows the error dict, and `authorizationStatus` hard-codes `.authorized` — failures are invisible by design. Underlying: UNUserNotificationCenter disabled due to corrupted notification DB on macOS 26. Fix plan: main-thread/osascript + surfaced errors → reset notification DB → probe-guarded return to UNUserNotificationCenter.
- **Install kills running tasks:** only because daemon restarts; `identifyClient` handshake requires exact `ipcProtocolVersion` equality (`IPCMessage.swift:129`). Solution S1: install-graceful compares old-daemon vs new-binary protocol version, skips daemon restart when equal → agents survive. Also found `launchctl bootout 'gui/\$(id -u)'` quoting bug in install-graceful.sh (never expands, always falls through to pkill) — Sonnet confirmed `KeepAlive` IS set on the LaunchAgent, so the respawn race this causes is real, not hypothetical.
- **graphify:** algorithms sound (deterministic Leiden + churn-hardening, well-guarded MinHash/JW dedup); structural debt = extract.py 16k lines (correction: an active `extractors/MIGRATION.md` batch plan already covers this, not a neglected split), __main__.py 5.2k; installed pkg 0.10.0 vs repo 0.14.0 skew; god nodes include both `Int` (927 edges, builtin) and module names (`HarnessCore`/`Foundation` — a builtin-only filter wouldn't catch these).
- **Repo hygiene:** 20MB graph.json tracked in git (recommend .gitignore).
- **Retracted finding:** original draft claimed the 2026-07-02 file-preview fixes were uncommitted — false, they shipped in `587fa906` before this review ran. Caught by Sonnet's independent git-log check; report corrected. **Lesson: verify "uncommitted work" claims against `git log`, not against CONTEXT.md, which can go stale.**

### 2026-07-02 — File preview: selection dropped on background reload + clicking agent tool-call paths failed ✅ FIXED and committed (`587fa906`)
User report (Thai) was two bugs conflated in one message, split via `AskUserQuestion`: (1) drag-selecting
text in the file preview then scrolling to reach Cmd+C — the gray highlight "disappears too fast to
register"; (2) clicking a file path inside an AI agent's own tool-call summary line printed in the
terminal (e.g. Claude Code's `⏺ Update(Apps/Harness/.../SyntaxTextView.swift)`) didn't open the preview,
while the file tab/tree and MCP paths worked fine.

**Bug 1 root cause (confirmed via `swift` script repro, not guessed):** `SyntaxTextView.load()` and
`applyDiagnosticAttributes()` (`SyntaxTextView.swift`) both do a full `textView.textStorage?.setAttributedString(...)`
replace — on file-watcher reload (`FileChangeWatcher` fires on *any* fs event including a bare `.attrib`
touch, 300ms debounced) and on async LSP diagnostics push, respectively. Repro proved a full textStorage
swap collapses `NSTextView.selectedRange()` to `{length, 0}` even when the text content is byte-identical
— and, separately, proved scrolling alone never touches selection (ruled out "scroll" as the literal
cause). Since Harness previews files that agents are actively writing, one of these two async reloads
landing mid-select during a multi-second drag+scroll+copy gesture is the actual trigger.
**Fix:** new `SyntaxTextView.preservingSelection(_:)` helper captures `selectedRange()` before the replace
and restores it (clamped to the new length) after; applied at both call sites.

**Bug 2 root cause:** `URLDetection.detectFilePath`'s unquoted-token fallback (`URLDetection.swift`)
only treated whitespace/quotes as token boundaries — not `(`/`)`. Coding-agent CLIs print tool calls with
no space before the path (`Update(path/to/file)`), so the scan swept `Update(` into the token; the
trailing-strip only removes trailing punctuation, so the mangled `Update(path...` string never matched a
real file and the click silently no-opped.
**Fix:** added `(`/`)` to the boundary-char set in that one fallback branch only (quoted-path branches
and `detectLocalhost` untouched).

Tests: `testDetectFilePathStripsToolCallParens` (new, `EngineConformanceTests.swift`) — reproduces the
exact `⏺ Update(...)` line shape. `swift test`: only 3 pre-existing unrelated failures
(`ExperienceModeTests`, `Phase6KeysTests`, `ReleaseNotesGuardTests` — changelog/checksum drift, none
touch these files). `Tests/robot/run.sh` 10/10 clean.
**Lesson:** when a bug report bundles two symptoms, don't assume they share a root cause — `AskUserQuestion`
to split them up front turned out to be two unrelated defects in two different subsystems (AppKit
text-view selection vs. terminal link-detection regex).

### 2026-07-02 — spawnSession/splitPane set a pane label atomically ✅ DONE, committed (`c9ee32ce`)
User asked to make pane labeling "auto" and whether other terminals do this. No terminal tool
(tmux included) does true semantic auto-labeling — tmux's `automatic-rename` only shows the literal
foreground command. Landed on: the agent creating a pane labels it in the same call. Added optional
`label` param to `spawnSession`/`splitPane` (both previously returned only `sessionId`/`paneId`, so
labeling required a 3rd `harnessList` round-trip to resolve `surfaceId` first) — new
`labelPrimarySurface`/`labelPaneSurface` helpers in `HarnessDaemonTools.swift` do one internal
snapshot lookup + `setPaneLabel` call, best-effort. No live-daemon test harness exists for
`HarnessDaemonTools`, so verified via a real headless daemon + real MCP stdio round-trip instead of
building new test infra. Careless moment: cleanup used `pkill -f "HarnessDaemon"` which could have
matched the production `/Applications/Harness.app` daemon — verified after the fact it was untouched
(unchanged start time), but should have killed only the smoke-test PID.

### 2026-07-02 — P32 `setPaneLabel` MCP tool + P34 right-click block menu ✅ DONE, committed (`1723136`, `965f7b3e`)
User said "ทำ p32,34 ต่อ" to implement two backlog items logged earlier this session.

**P34 (`1723136`):** User rejected ⌘-click as the block-action trigger (not discoverable); chose
right-click context menu over plain ⌘C/⌘V via AskUserQuestion. Removed `BlockActionBar` (~95 lines)
from `BlockTintOverlay.swift` entirely; ⌘-click now only opens links. Block actions moved into
`menu(for:)` (`HarnessTerminalSurfaceView+Find.swift`), gated on whether the right-clicked line
falls inside a captured OSC-133 block (degrades to Re-run-only for bash panes). `cell(at:)` widened
`private`→internal (needed cross-file within the same type's extensions). Tests: `BlockContextMenuTests` 2/2.

**P32 (`965f7b3e`):** Backlog note assumed reusing `IPCRequest.updateTabTitle` needed no new
schema — wrong on inspection (see MEMORY.md lesson). Built a dedicated `PaneSurface.label: String?`
field instead, wired through `SessionEditor.setPaneLabel` → new `IPCRequest.setPaneLabel` →
`SurfaceRegistry` handler → `harnessList`'s `paneJSON` (`"label"` key) → policy-gated `setPaneLabel`
MCP tool (mirrors `sendPaneText`). Tests: `PaneLabelDaemonTests` 4/4.

Both: `swift build`/`swift test` (2 pre-existing unrelated failures only)/`Tests/robot/run.sh` 10/10 clean.
Consulted `advisor` before starting — recommended committing the already-complete P34 refactor
first (separate commit, avoid tangling with the new P32 feature) and flagged the `PaneSurface`
Codable-safety check before adding the field. Both followed.

### 2026-07-02 — P34 F2 (block actions) + F3 (MCP block access) ✅ DONE, committed (`8049605`)
Continuation of F1 slice 1 (`2ca7fbb`) — user said "phase 2,3" to proceed.

**F2:** Promoted `TerminalBlock` back to `public` (needed cross-module now) and replaced the F1
`commandText(atPromptLine:)` accessor with a fuller `block(atPromptLine:) -> TerminalBlock?`
(command, output line range, exit code) plus `lastBlock`/`block(id:)` and a ranged
`captureLines(fromLine:toLine:)` on `TerminalEmulator`/`HarnessGridTerminal`/
`HarnessTerminalSurfaceView`. `BlockActionBar` (`BlockTintOverlay.swift`) grew two buttons —
Copy Output Only, Copy Command Only — shown only when the pane's shell actually emitted a block
(`hasBlock` check in `showActionBar`); bash panes still get the original 2-button Copy/Re-run
bar instead of two buttons with nothing precise to act on. Re-run's fallback regex-strip is
unchanged for that same bash case.

**F3:** Found via code read (not the plan doc's assumption) that OSC-133 parsing only happens
client-side (GUI's `HarnessTerminalSurfaceView` / `harness attach`'s `HarnessGridTerminal`) — the
daemon itself is a dumb byte-relay + raw scrollback store, confirmed by `RealPty.captureGrid`
already replaying retained scrollback bytes through a **fresh** `HarnessGridTerminal` on every
call (not a live/always-on parser). This meant `harnessGetLastBlock`/`harnessGetBlock` didn't
need a new daemon-side OSC-133 subsystem — just a sibling method next to `captureGrid` that does
the same replay, then reads the replayed instance's block store. Not "retroactive backfill"
(explicitly rejected in F1's interview) since the replayed bytes contain the SAME live OSC 133
`C`/`D` sequences originally parsed — deterministic recomputation, not guessing.
New: `IPCRequest.getBlock(surfaceID:blockID:)` / `IPCResponse.blockInfo(BlockSummary?)`
(`HarnessIPC`), `RealPty.block(id:)` (daemon), `SurfaceRegistry.handle(.getBlock)`,
`HarnessDaemonTools.getBlock` + `harnessGetLastBlock`/`harnessGetBlock` MCP tool registration
(`ToolRegistry.swift`). Nil `blockID` = most recent *finished* block; a still-running block (no
`D` yet) returns nil even by exact id since there's no output range to read yet.
Tests: extended `TerminalBlockStoreTests` (full block shape, exit code, output range,
lastFinishedBlock-only), new `HarnessGridTerminalTests` cases for the wrapper forwarding
(`lastBlock`/`block(id:)`) that `RealPty.block(id:)` calls into — no daemon-level PTY-spawning
test added, matching the existing precedent that `captureGrid`/`captureRange` (same replay
shape) have never had one either.
`swift build --product Harness` clean; `swift test` (2 full runs) only the 2 pre-existing
unrelated failures; `Tests/robot/run.sh` 10/10. One transient signal-11 crash in an unrelated
Metal/GPU test (`GridCompositorCopyModeTests`) during a single full-suite run — reproduced
against the clean pre-F2/F3 baseline commit via `git stash`/re-run to rule out a regression;
did not recur across 2 more full runs with these changes present, so treated as a pre-existing
flake, not caused by this work.
**Lesson:** before assuming a daemon-side MCP tool needs new live state tracking, check whether
the daemon already has an on-demand "replay stored bytes through a fresh headless instance"
pattern for a sibling feature (`captureGrid` here) — it may already be the source of truth you
need, with no new subsystem required.

### 2026-07-02 — P34 F1 slice 1: OSC 133 command-boundary + block command-text capture ✅ DONE, committed (`2ca7fbb`)
`interview` skill (doc.md, codebase-aware) before implementing, since research found the plan
doc's own premise partly wrong: `SemanticMark` (`TerminalScreen.swift`) tracks only `exit: Int?`
per row — no command text, no persistent block model — and none of zsh/bash/fish
shell-integration scripts actually emit OSC `133;B`/`133;C` (only `A`/`D`), so the existing
"command duration" feature (`onCommandFinished`) never fires against a real shell, only
hand-fed tests. `BlockTintOverlay`'s Re-run already existed (Warp-style ⌘-click overlay,
Copy/Re-run buttons) but used a regex prompt-prefix strip to guess the command — an
already-flagged `ponytail:` ceiling comment pointed at exactly this fix.

User confirmed via interview: F1 only this pass (no F2 UI-actions/F3 MCP tools yet, same
"ทำ 1 ก่อนแล้วค่อย improve" pattern as file-preview), shell-script changes requiring re-install
on other machines acceptable, no retroactive scrollback backfill, and fix Re-run's regex-strip
now since the real data would be available. Consulted `advisor` before touching 3 shell
scripts (every pane sources them) — confirmed direction, added two corrections: (1) skip
emitting `133;B` entirely — engine code already treats it as fallback-only ("C deliberately
overwrites B"), so embedding a marker in `$PROMPT`/`PS1` (fragile against starship/p10k
dynamic-prompt themes) is unnecessary; (2) bash's only preexec mechanism is the `DEBUG` trap
(fires per pipeline-stage, needs a `PROMPT_COMMAND`/reentrancy guard) — too much of a footgun
to hand-roll into every bash user's rc without dedicated test coverage, so deferred (bash
stays A+D only, `ponytail:` comment names the ceiling and upgrade path).

**Fix:** zsh (`add-zsh-hook preexec`) and fish (`--on-event fish_preexec`) now also emit
`133;C;<base64 command>` — the shell's own preexec hook already knows the exact typed command,
so this carries real data instead of reconstructing it from rendered terminal columns. Base64
avoids the payload colliding with the OSC-133 `;`-field-separator the parser already splits on.
`TerminalEmulator.handleSemanticPrompt` decodes it and opens a `TerminalBlock` (new file,
`Emulator/TerminalBlock.swift`) in a new per-pane `TerminalBlockStore` — deliberately decoupled
from `HistoryLine`/scrollback (own last-N cap) so a block survives `dropHistoryHead` eviction,
matching F1's "forward-only, no retroactive rescan" scope. `133;D` closes the block (exit code
+ end line). New `TerminalEmulator.commandText(atPromptLine:)` is the only new public surface
crossing into `HarnessTerminalKit` (mirrored via `HarnessTerminalSurfaceView.commandText`);
`BlockActionBar.rerunBlock()` now uses it when available, falling back to the old regex-strip
only for panes whose shell doesn't emit `C` yet (bash).
Bonus: emitting `C` also fixes the latent bug where `onCommandFinished`'s duration/"long
command finished in background" notification never fired against a real shell (`C→D` timing
now actually happens).
Tests: `Tests/HarnessTerminalEngineTests/TerminalBlockStoreTests.swift` (4 cases — capture,
no-C-no-text, unknown-prompt-line nil, two-blocks-don't-bleed), extended
`ShellIntegrationTests.testZshAndFishEmitCommandBoundary` (+ explicit bash-must-not assertion).
`swift build --product Harness` clean; `swift test` only the 2 pre-existing unrelated failures
(`ExperienceModeTests`, `Phase6KeysTests`); `Tests/robot/run.sh` 10/10.
**Lesson:** when a plan doc's "extend the shell script" step turns out to need a *payload*
(not just a boundary marker), check whether the shell's own hook already carries the data
(zsh/fish preexec receive the literal command as an argument) before reaching for
screen-scrape/regex — it's both more accurate and avoids touching fragile territory like
`$PROMPT`/`PS1` that prompt-theme frameworks reset on every render.

### 2026-07-02 — File preview tabs leaked across terminal Tabs (global singleton) ✅ FIXED, not committed
Feature request via `interview` skill (per-Tab scope confirmed with user, not per-Session/per-Pane —
split panes were just an example of already-correct isolation, not an additional requirement).
Double-clicking a file (from Git panel Changes list or file tree) opened it into a single
app-wide `FileTabManager` singleton owned by `FilePreviewCoordinator` — any Tab showed the
same file-preview state, deduped only by path, no session/tab awareness at all.

**Fix:** promoted `FileTabManager` from one `let` instance to a `var` swapped via
`switchToTab(tabID:)`, backed by `fileTabManagers: [String: FileTabManager]` keyed by tabID —
mirrors `PaneLifecycleManager.containerCache`'s exact pattern (already proven for terminal
panes) rather than inventing a new one. Wired into `ContentAreaViewController.snapshotChanged`
(switch on every snapshot tick, cheap tabID-equality guard) and `viewDidLoad` (seed initial tab
before `restoreEditorState()`, so restored paths land in the correctly-keyed manager, not an
orphaned throwaway instance). `pruneFileTabManagers(keepingTabIDs:)` added alongside
`paneLifecycle.pruneCache` on structural changes, same leak-prevention shape.
Persistence across app restart intentionally deferred (user: ship in-session scoping first,
improve to cross-restart persistence later) — `UserDefaults` keys stay flat/global for now,
so restored state on next launch reflects whichever tab last touched it, not true per-tab.
Test: `Tests/HarnessAppTests/FilePreviewCoordinatorTabScopeTests.swift` (3 cases: leak-hidden
on switch-away, correct-file-restored on switch-back, pruned-tab starts fresh).
**Lesson:** when a new per-X-scoped state need comes up, check for an existing per-tabID/
per-sessionID dictionary-cache pattern already proven elsewhere (`PaneLifecycleManager`) before
designing a new one — same shape, same pruning discipline, smaller diff.

### 2026-07-02 — Git sidebar panel didn't refresh after external `git commit`/`push` ✅ FIXED, not committed
User report: after `git commit`+`push` from a terminal pane, the sidebar Git tab kept showing stale
status. (Two other hypotheses investigated first and disproven via source-level tracing per
debug-mantra: split-pane shared `Tab.cwd` overwrite — ruled out, user had no split panes; Cmd+T
new-tab creation/registration/probe/propagation chain — traced end-to-end, architecturally sound,
landed on a shell-rc-race explanation for that specific symptom instead, unconfirmed.)

**Root cause:** `f6ffb0a` ("eliminate CPU spikes from FSEvent storm during agent writes") added a
blanket filter in `GitPanelView.swift`'s FSEvent callback — any event path containing `/.git/` was
ignored, to stop the panel's own auto-stage (`refresh()`'s `git add` at the time) from
self-triggering a refresh loop. But a plain `git commit`/`push` from a terminal *only* touches paths
under `.git/` (`index`, `COMMIT_EDITMSG`, `logs/HEAD`, `refs/heads/*`, `refs/remotes/*`) — no
working-tree files change — so the blanket filter also silently swallowed the exact events a
refresh should react to. `suppressingFSEvents` already guarded the panel's own `git add` write
separately; the blanket `.git/` filter was redundant *and* too broad.

**Fix:** narrowed the filter to `nonisolated static func isNoisyGitInternalPath(_:)` — only
`.git/index`, `.git/index.lock`, `.git/objects/**` are treated as noise; everything else under
`.git/` (HEAD/refs/logs/COMMIT_EDITMSG/FETCH_HEAD) now correctly triggers a refresh. Regression
test: `Tests/HarnessAppTests/GitPanelViewFSEventFilterTests.swift` (3 assertions). Build + targeted
test green; not yet run through `Tests/robot/run.sh` or committed.
**Lesson:** a blanket "ignore all noise from path X" filter meant to fix a self-triggering loop can
silently kill legitimate external events that live under the same path prefix — narrow the filter to
the specific noisy sub-paths, not the whole prefix.

### 2026-07-02 — agy logo color mismatch (preview vs prod) ✅ RESOLVED — not a Harness bug
Long investigation (many rounds, see below) into why `antigravity`/`agy`'s CLI logo rendered with
different colors in `.harness-preview` vs production. Ruled out, in order (all equal between
builds): `TERM`/`COLORTERM`/`TERM_PROGRAM`/`terminal-identity` spoofing, `terminalShaderEffect`,
`colorGamut`/`CAMetalLayer.colorspace`, sampler filtering, SGR truecolor parser
(`38;2;r;g;b;48;2;r;g;b` combined-attribute parsing), half-block bg/fg compositing. `script -q`
raw-byte capture confirmed both builds receive byte-identical `38;2` truecolor SGR from the CLI —
so it was never a rendering/parsing bug.

**Actual root cause:** `make preview`'s isolated state dir (`/tmp/harness-preview-<hash>/settings.json`,
fresh per run — by design, to avoid polluting daily-use state) doesn't inherit the user's real
`~/Library/Application Support/Harness/settings.json`. Two settings there directly recolor terminal
output: `minimumContrast` (prod: `1`=off; preview default: `3.5`, WCAG-brightens/shifts foreground)
and `paletteHex` (prod: custom 16-color; preview default: `null` → falls back to built-in theme
palette). Confirmed fixed by copying production `settings.json` into the preview state dir.

**Process note:** the winning diagnostic was empirical (raw-byte diff via `script -q`), not static
code reading — static analysis of the renderer/parser (which was exhaustive and correct) couldn't
have found this since the bug was never in code. See `knowledge/cases/misc.md` CASE-060.

### 2026-07-02 — Near-miss: `git revert --abort` wiped uncommitted session work
Found an unexpected in-progress `git revert eb0c89b` (REVERT_HEAD set, conflicts pre-resolved and
staged) while preparing to commit — not something this session started. User confirmed intent was
to keep the current (later) state, not actually revert. `git revert --abort` was the wrong recovery
step here: it does `git reset --merge` back to the pre-revert HEAD, which discarded **all**
working-tree edits to every file that had been part of the revert's index — not just the revert's
own changes — including hand-written fixes made *after* the revert began. Files reset: `CONTEXT.md`,
`HarnessSidebarPanelViewController.swift`, `SidebarSessionListView.swift`, `TerminalTabBarView.swift`.
Recovered by reconstructing each diff from conversation history (`CONTEXT.md`/`MEMORY.md` had scratch
backups; the 3 Swift files were retyped from diffs already read earlier in the session) — full
recovery confirmed via `git diff` matching pre-abort content exactly, build+test green.
**Lesson:** `git revert --abort` / `git merge --abort` mid-operation is NOT safe to run casually
when working-tree files were edited after the operation started — it discards those edits too, not
just the operation's own changes. Back up (or `git stash`) any files touched since the operation
began before aborting. See RL-060 in `knowledge/rl-lessons.md`.

### 2026-07-02 — Sidebar status classification/color unification + Board tab flip bug ✅ FIXED, committed & pushed (`49a67ba`)

Chain of fixes across one session, each surfaced by the user spotting a visual mismatch:

1. **Classification duplication regression** — staged (uncommitted) edits to `SidebarListModel.swift`
   had grown a local `columnKind(for:)` copy that dropped the `agent.activity == .working` check
   `BoardModel.columnKind` (the single classifier `eb0c89b` introduced) relies on. Restored: doc
   comment + `.working` check back in `BoardModel.swift`; `SidebarListModel` now calls
   `BoardModel.columnKind(for:)` directly, no local copy.
2. **Sidebar row visual regression** — same staged diff had also dropped the real agent icon
   (`AgentIconRenderer.templateOrMonogramImage`) from `SidebarSessionItemRow`, replacing it with a
   static branch glyph + ad-hoc dot color. Restored icon to match `TabPillView`'s pattern; dot
   color bugs fixed twice — first wrong-mapped (`.running`→green instead of blue), fixed to use
   canonical `BoardColumnKind.color`; then per user's actual ask, replaced the dot entirely with a
   colored status **text** label (`sessionBoardStatus.displayName` at `sessionBoardStatus.color`)
   for all non-idle states, mirroring the existing "Needs Attention" text pattern.
3. **Board tab visual bug (CASE-059 / RL-059)** — switching Sessions→Board showed the first column
   header ("Needs Attention (0)") squashed to a sliver, later reduced to "shifted down slightly"
   after several timing nudges (`reload(force:)`, `layoutSubtreeIfNeeded()`, `displayIfNeeded()`,
   `scrollToTop()` in that order). None of these were the real fix — root cause was
   `BoardViewController`'s scroll `documentView` being a plain non-flipped `NSView()`, so content
   anchors bottom-left and `scroll(to: .zero)` scrolled to the bottom, not the top. Fixed with a
   flipped `documentView` subclass (same pattern as `GitPanelView.swift`'s existing `FlippedView`).
   **Lesson:** when several small timing nudges only partially converge on a layout bug, stop
   nudging and check `isFlipped` before adding a 6th nudge.

## Previous sessions (abbreviated)

Full detail for anything below → `COMPLETED-TASKS-ARCHIVE.md` (rows 56–63 = 2026-06-29 to 07-01).

| Date | Task | Key outcome |
|------|------|-------------|
| 2026-06-27 | otty-features P1–P20 | All phases shipped; P13/P21 deferred |
| 2026-06-26 | Memory-leak audit | existingHosts pin, BrowserPaneView cap, AI controller retire → v3.9.4 |
| 2026-06-26 | cwd bleed | deepestReadableDescendant removed; shell pid direct |
| 2026-06-25 | harness view | OSC 7735 → sidebar file viewer |
| 2026-06-23 | Sidebar SwiftUI | NSTableView removed; VC 1676 → 890 lines |

## Unresolved
- 3 pre-existing `swift test` failures unrelated to any recent work: `ExperienceModeTests.testShowsHarnessControlsDerivesFromMode`,
  `Phase6KeysTests.testRootTableSeededAndBindable`, `ReleaseNotesGuardTests.testGeneratedNotesMatchChangelogBlock`
  (changelog changed since notes generated — run `make release-notes` if that's ever the actual task). Not investigated — check if still failing before next test-suite work.
