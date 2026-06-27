# Context — harness-terminal

## Now
- **Task:** idle
- **Branch:** main
- **Status:** AppKit low→medium migration wave done.

### This session (2026-06-27) — AppKit → SwiftUI migration wave

**Wave summary (5 tasks, all committed on main):**
- `HarnessSidebarPanelViewController+DragReorder.swift` — deleted (dead stub)
- `NotificationBellButton.swift` — deleted (zero call sites)
- `Toast.swift` — rewritten with `NSHostingView<ToastBody>`; -19 lines
- `AboutPanelController.swift` — rewritten with `NSHostingController<AboutView>`; -50 lines
- `WorkspacePillButton` (128 lines) — replaced by `WorkspacePillModel (@Observable)` + `WorkspacePillView (SwiftUI)`; theme re-render via `chromeEpoch` pattern

**Deferred:** `WorkspaceSwitcherPanelView` (dropdown) — positioning/dismiss stays in AppKit VC; bridge cost ≥ AppKit code; bundle with VC migration when workspace switcher is re-enabled.

**Robot test fix (commit `ad792c9`):** Bug 1 was checking `ContentAreaViewController` for `existingBrowserPanes.removeValue` — refactored into `BrowserIntegrationController`; test updated.

**deep-research skill** disabled in `~/.claude/settings.json` (`skillOverrides`).

### This session (2026-06-27) — SwiftUI Settings S6–S9 + Cmd+\ fixes
**Cmd+\ black flash fix** (commits `d5833b0`, `28d0233`):
- `MainActor.assumeIsolated` replaces `Task { @MainActor in }` in animation loop — stops jitter on macOS 26
- `presentsWithTransaction` bracketing around sidebar animations — Metal/CA sync, kills black gap
- `ContentAreaViewController.collectTerminalHosts()` forwarding accessor added

**SwiftUI Settings migration complete** (commit `94c9491`):
- S6: `SettingsAdvancedView` — daemon set-option surface + local perf toggles; `SwiftUI.Binding<>` prefix required due to `HarnessCommands.Binding` shadow via HarnessCore re-export
- S7: `SettingsRemoteView` — SwiftUI List + master-detail form, SSH host CRUD
- S8: `SettingsRootView` (NavigationSplitView) + `SettingsHostingController`; `SettingsWindowController` moved here, int-page API preserved
- S9: 10 AppKit files deleted (−2800 lines); `ansiNames` promoted into `PaletteCell`

### This session (2026-06-26) — cwd bleed during builds
**Symptom:** during `make build`/`install` the session's tab pill, git panel, and file tree all jump to the wrong directory (another repo / `/`) — "1 session = 1 worktree" broke.
**Root cause:** `RealPty.probeWorkingDirectory()` reported the **deepest foreground descendant's** cwd (`deepestReadableDescendant`). A build subprocess that cd's elsewhere (cp → /Applications, sub-build in /tmp, agent in sibling repo) hijacked the session's cwd → spurious revision bumps → reload storm → blank/wrong panel.
**Fix:** report the shell's own cwd (`Self.cwd(for: childPID)`); removed `deepestReadableDescendant`. Genuine shell `cd` still tracked. See [knowledge/cases/cwd-worktree-bleed.md].
**Also:** `WorkspaceFileTreeView` re-attaches its hosting view in `viewDidMoveToWindow` (was blank after sidebar position swap).
**Repro tool:** headless `HarnessDaemon` + `harness-cli new-session --cwd` + `send` a foreground subshell that cd's to another repo, poll `list-surfaces` cwd.

## Last Session (2026-06-26) — Memory-leak audit + v3.9.4 release prep

**Diagnosis (live pid via vmmap/footprint):** 34 GB was MALLOC_SMALL (Swift heap), NOT GPU/Metal. Dominant cause = `existingHosts` strongly pinning per-pane TerminalScreen graphs — **already fixed in `0430ed8`**; the leaking process ran a binary built Jun 24, before that Jun-25 fix. → user must rebuild+reinstall (`make install`) and re-measure over a long session.

**Fixed this session (real, smaller leaks remaining on main):**
- `SessionCoordinator.inlineAIControllers/aiChatControllers` leaked one pair per closed pane (insert-only dicts). Fix: `TerminalPaneRegistry.onRetire` hook from `retire()` (covers removeHost + prune) drops both entries.
- `BrowserPaneView` injected network capture array uncapped → cap 500 + monotonic id.
- Guard: `Tests/robot/memory_leak_guards.robot` (3 tests, green) + `Tests/robot/helpers/check_retire_coverage.py` structural guard for future dicts.

**v3.9.4 prep done:**
- Info.plist → 3.9.4 / build 170
- HarnessVersion.swift updated
- CHANGELOG.md entry written with real content (2 Added, 5 Fixed)
- GeneratedReleaseNotes.swift regenerated
- graphify updated (16146 nodes, 36693 edges)
- knowledge/cases/memory-leak-audit.md created

**Reverted:** an autoreleasepool wrap on the Metal present loop — GPU was ruled out by vmmap.

**Flagged, separate:** robot `Bug 1 - Browser Pane Reuse On Rebuild` fails on clean main (pre-existing) — `existingBrowserPanes`/`collectBrowserPanes()` gone from ContentAreaViewController; browser panes may no longer be reused across rebuilds. Needs its own look.

## Previous Sessions

### 2026-06-25 — `harness view` opens sidebar viewer
- `harness-cli view <file>` now opens the file in the sidebar file editor when inside Harness, instead of printing to stdout. OSC 7735 mechanism.

### 2026-06-24 — Otty Feature Import
- Hint mode (Cmd+Shift+U) — Vimium-style link picker overlay
- Vi mode / autocomplete intentionally skipped (shell handles it better)
- Send selection → AI chat (~30 lines) — still pending, low priority

### 2026-06-23 — Sidebar SwiftUI Migration Complete
- All 6 phases done; NSTableView removed; VC 1676 → 890 lines

## Unresolved
- Cmd+\ intermittent failure — PrefixKeymap disarm-on-click fix committed but root cause unknown
- Pre-existing robot failure: "Bug 1 - Browser Pane Reuse On Rebuild"
