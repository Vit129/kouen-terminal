# Context — harness-terminal

## Now
- **Task:** in progress — nested-iframe wheel-scroll fix in browser pane needs manual retest (see below). P35 (OAuth login) fixed and verified live; P36 (app icon) shipped light+dark. All uncommitted on `main`, along with earlier review action items (H5, H6, notification Step 1, S1).
- **Branch:** `main`
- **Pending:** manual test of `kickCompositorRelayout` scroll fix (repeated scroll over several seconds on the claude.ai artifact URL — watch `kouen.scrollprobe moved=true/false` in the browser console log; a single successful scroll is NOT enough, v1 of this fix looked fine once then failed) — see `knowledge/ui/browser-pane.md`. Also: review action checklist in REVIEW-graphify-harness-2026-07-03.md — remaining: notification Step 2/3 (system-level, needs user), graphify G1/G3/G4 (different repo).

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
