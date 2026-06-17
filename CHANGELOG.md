# Changelog

All notable changes to Harness are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and Harness follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). Each released version
has a matching `vX.Y.Z` tag and a signed, notarized DMG on
[GitHub Releases](https://github.com/robzilla1738/harness-terminal/releases).

## [3.2.6] - 2026-06-17

### Added
- Release version bump to v3.2.6.

## [3.2.5] - 2026-06-17

### Added
- Release version bump to v3.2.5.

## [3.2.4] - 2026-06-17

### Added
- Release version bump to v3.2.4.

## [3.2.3] - 2026-06-16

### Fixed
- **Paste protection dialog removed** — Paste now executes immediately without confirmation, regardless of clipboard content (multi-line, control chars).
- **Close confirmation dialog keyboard behavior** — Removed default button so Enter no longer always triggers "Close Session" when Cancel is Tab-focused. Both buttons now require explicit Space activation after Tab selection.
- **Command Prompt (⌘;) not accepting keyboard input** — Panel used plain `NSPanel` which returns `canBecomeKey = false` for borderless style. Replaced with `KeyablePanel` subclass that overrides `canBecomeKey { true }`.
- **Close confirmation re-entrancy** — Added guard to prevent `closeActiveTabWithConfirmation` from being called multiple times while a sheet is already displayed.

### Changed
- **Add Worktree dialog** — Set `initialFirstResponder` to path field for immediate keyboard input on open.

## [3.2.2] - 2026-06-16

### Fixed
- **Blink timer UAF crash** — Timer callback used `MainActor.assumeIsolated` which could fire during dealloc. Replaced with generation-token guard + direct access (RunLoop.main = already main thread).
- **renderLink/blinkTimer deinit off-main** — `deinit` is nonisolated in Swift 6; invalidation now routes through `DispatchQueue.main.sync` if called from background thread.
- **NotificationCenter observer UAF** — Removed redundant `MainActor.assumeIsolated` wrappers from 3 NC observers in `HarnessTerminalSurfaceView` (queue:.main already guarantees main delivery).
- **OverlayWindow timer leak** — Phase67UI clock timer had no `deinit` invalidation; added.
- **StatusLineView timer leak** — refreshTimer had no `deinit` invalidation; added.
- **GitPanelView FSEvents leak** — FSEventStream never stopped on dealloc if `viewDidMoveToWindow(nil)` wasn't called; added `deinit`.
- **TerminalHostView NC observer** — selector-based observer not removed on dealloc; added `removeObserver(self)` in `deinit`.

## [3.2.1] - 2026-06-16

### Fixed
- **UAF crash on pane rebuild** — `ContentAreaViewController` now retains the old `PaneContainerView` for one runloop tick after removal, preventing AppKit from dispatching layout/display to freed views during structural rebuild.
- **UAF crash on tab bar rebuild** — `TerminalTabBarView` defers deallocation of removed `TabPillView` instances so pending tracking-area and layout dispatches complete safely.
- **Off-main-thread `layout()` crash** — added `Thread.isMainThread` guard to all remaining `nonisolated override func layout()` call sites (`HarnessSplitView`, `WindowBorderOverlayView`, `NotificationBellButton`, `HarnessTextField`, `HarnessSearchField`, `HarnessToggle`, `HarnessSlider`, `HarnessSwatchWell`, `HarnessSegmented`, `HarnessSelect`, `SoftIconButton`, `ChromeBackdrop`, `HarnessOverlayBackground`, `StatusDotView`, `AgentChipView`). If called from a background thread, defers to main via `needsLayout = true`.

## [3.2.0] - 2026-06-16

### Fixed
- **TerminalTabBarView.layout() crash (CASE-034)** — Swift 6 executor check failure when AppKit calls `layout()` from non-main executor. Applied `nonisolated + MainActor.assumeIsolated` to all 21 `override func layout()` and `viewDidMoveToWindow()` overrides across HarnessApp.
- **File preview black-flash (task 51)** — opening/closing the file-editor split caused Metal surface flash. `setPresentsWithTransaction(true)` is now set on all terminal hosts before the constraint layout pass.

### Improved
- **Adaptive SurfaceShellTracker** — proc-tree walk interval increases from 500ms to 2s after 4 consecutive no-change ticks. Resets to 500ms on `bumpScan()` (new tab) or CWD change. ~75% CPU reduction when idle.
- **Sidebar skip-on-idle** — `rebuildSidebarRows()` + `configure()` loop now skipped entirely when sessions haven't changed (uses `isStableEqual` ignoring volatile fields like `currentCommand`). ~95% of metadata ticks are no-op.
- **Tab bar skip-on-idle** — `refreshMetadata` pill updates skipped when tabs are stable-equal. Same volatile-field exclusion.
- **`buildSurfaceIndex` conditional** — only rebuilds when pane-tree structure changes, not on every snapshot.
- **Browser pane merge fast-path** — O(W×S×T) loop skipped when no browser panes exist in current snapshot (the common case).
- **Agent icon cache** — sidebar `WorktreeRowView` caches the rendered agent `NSImage` by kind, avoiding re-render every 1.5s.
- **Duplicate `fileTreeView.updateRoot` eliminated** — was called twice per refresh cycle, now once (only when session or branch actually changes).

## [3.1.5] - 2026-06-16

### Added
- **Agent icon in sidebar session cards** — when an agent (Kiro, Claude Code, Codex, etc.) is detected on a tab, the sidebar session card now shows the same NSImage brand icon used in the tab bar instead of a generic dot+label. Falls back to dot+label for non-agent sessions.
- **`Tab.effectiveAgentKind` centralized** — single computed property (`tab.agent?.kind ?? AgentTitleInference.kind(from: title)`) used by tab bar, sidebar, board, menu bar, and notification coordinator. All views now use the same agent detection logic including OSC title inference fallback.
- **`agent_chip` format variable** — new `#{agent_chip}` in status/pane-border format strings returns the 2-letter chip (e.g. `KR`, `CC`) for the active agent.

### Changed
- **Welcome banner unified shortcuts** — merged "Try this" and "Native shortcuts" into a single "Shortcuts" section with 11 Harness-native shortcuts (`⌘⇧N`, `⌘D/⌘⇧D`, `⌘P`, `⌘F`, `⌘B`, `⌘;` etc.). Removed all `ctrl-a` prefix references.
- **`pane-border-format` default** — changed from `#{pane_index} #{pane_title}` to `#{pane_index}`, eliminating tool-injected process names (e.g. `kiro-cli`) from the pane border label. Old value auto-migrated.
- **Command prompt placeholder** — updated from tmux-style `split-window -h ; copy-mode` to Harness-first `find, grep, cd, rename-window`.

### Fixed
- **`FileTreeSwiftUIView` UAF crash** — `context` property changed from `let` to `@Bindable`, ensuring SwiftUI holds a strong reference to the `@Observable FileTreeContext` object throughout the render cycle. Previously SwiftUI could drop the reference mid-layout causing `EXC_BAD_ACCESS` in `swift_getObjectType`.
- **`kiro-cli-term` leaking into sidebar** — daemon now strips ` (kiro-cli…)` suffix from OSC 2 title before storing, preventing Kiro's internal process name from appearing as the session title.

## [3.1.4] - 2026-06-16

### Fixed
- **File tree crash (EXC_BAD_ACCESS in swift_getObjectType)** — `WorkspaceFileTreeView.updateRoot` replaced `hostingView.rootView` with a new `FileTreeSwiftUIView` struct. When this happened mid-layout-pass (triggered by the 500ms shell-tracker poll or a git-branch-change notification), AttributeGraph held a stale observation reference to the old body closure; the subsequent `@MainActor` isolation check inside `@Observable` dereferenced freed memory. Introduced `FileTreeContext` (`@Observable` class) holding `rootPath`/`sessionID`; `updateRoot` now mutates context properties instead of replacing the root view — eliminates the race entirely.
- **Duplicate `.task(id: taskID)` in FileTreeSwiftUIView** — the FSEvents watcher task shadowed the `loadRoot` task (same task ID); `loadRoot` was never called from the task modifier. Gave the watcher task a unique `"\(taskID)|watcher"` key.

## [3.1.3] - 2026-06-16

### Fixed
- **App crash (EXC_BAD_ACCESS) on rapid session close/create** — `CADisplayLink` fired on a deallocated `HarnessTerminalSurfaceView`. macOS `NSView.displayLink(target:selector:)` does not strongly retain its target (unlike iOS); if `viewDidMoveToWindow(nil)` raced or was skipped during teardown, the link fired on a dangling pointer. Added `deinit` to unconditionally invalidate the display link and blink timer as a safety net.
- **Sidebar session tooltip showed full path** — session card tooltip now shows the shortened display path (e.g. `⎇ main  ~/Git/P…`) instead of the raw full path.
- **Sessions on same branch hidden in sidebar** — removed `allSameBranch` collapsing logic; all sessions in a group are always visible as separate rows.
- **Sidebar selection not synced on session switch** — `selectActiveSessionRowIfVisible` now called on every metadata refresh so the highlighted row tracks the active terminal.
- **File tree branch chip stale after tree refresh** — `refreshGitBranch()` now called inside `loadRoot()`.

## [3.1.2] - 2026-06-16

### Fixed
- **Tab bar status dot** now appears after the project name (`name •`) instead of at the pill's leading edge, matching the sidebar session card visual language.
- **Branch label always visible** in inactive tab pills — previously hidden for `main`/`master` unless multiple tabs shared the same folder name.
- **Drag-reorder phantom move** — cancels an in-flight tab drag when a structural reload fires (tab opened/closed elsewhere) instead of committing with a now-stale target index.

### Performance
- Eliminated redundant snapshot rebuilds on every 5-second metadata tick: `DaemonSyncService` skips `syncFromDaemon` when no git-branch deltas were detected; sidebar, Board view, and notch panel skip full card rebuilds on metadata-only ticks (reduces CPU load during long AI-agent sessions).

## [3.1.0] - 2026-06-15

### Added
- **Session status indicators** — sidebar session cards and top bar session pills now show a colored dot (blue=running, green=done, red=error, orange=waiting, gray=idle) derived from `BoardModel.columnKind`, the single source of truth used by the Board tab, CLI, scripting, and MCP.
- **Multi-branch / multi-agent visibility** — sidebar shows a separate row per session when branches differ, enabling Agent A on branch A, Agent B on branch B, etc. to be visible simultaneously.
- **⌘⇧I Notifications Inbox** — bell badge and dropdown now include board error/needs-attention sessions alongside agent notifications. Arrow keys and Enter navigate the dropdown.
- **⌘F Find in Files** — opens the grep palette (project-wide content search), consistent with VS Code/Cursor Cmd+Shift+F.
- **⌘P Command Palette** — replaces ⌘K for fuzzy file search, matching VS Code/Cursor/Zed convention.
- **⌘⌥W Close Pane** — replaces ⌘⇧⌥W, matching iTerm2 convention.
- **Close confirmation dialog on all paths** — ⌘W, tab bar × button, and sidebar × button all show a confirmation dialog before closing.
- **IDE-like Terminal Workbench docs** — USAGE.md, COMMANDS.md, and KEYBINDINGS.md updated with full `:find`/`:recent`/`:grep`/`:errors`/`:make`/`:board` reference and IDE→terminal workflow guide.

### Changed
- **⌘K removed** in favour of ⌘P for Command Palette.
- **⌘⇧U changed to ⌘⇧I** (Notifications Inbox).
- **⌘F** changed from native find bar to Find in Files (grep palette).
- **⌘⇧T Reopen Closed Tab removed** — not implementable as true restore (PTY terminates on close); daemon persistent sessions are the correct equivalent.
- `BoardModel.columnKind()` made public; `BoardModel.shellNames` made public — all surfaces share one classification implementation.
- `BoardColumnKind.color` extension added in HarnessApp for canonical status colors.
- Docs consolidated: Modes and Migration summaries added to USAGE.md; MANUAL_TEST_PLAN moved to agent-memory.

### Fixed
- Sidebar session group header chevron rendered too large; fixed frame (10×10), removed scale-to-fill, weight reduced to regular.
- Sidebar group header click hit-test used wrong coordinate space for add/options buttons; now uses `convert(bounds:from:)`.

## [3.0.0] - 2026-06-15

### Added
- Terminal Workbench aggregation now collects the P4-P19 Vi/Unix/terminal/panel surface into one terminal-first workflow layer: `:recent`, `:copy-path`, `:grep`, `:errors`, `:make`, `:attention`, `:ack`, and the scriptable IDE-migrant profile.
- Pane-aware workbench context resolves the focused terminal pane first, so cwd and current-file behavior follow the active project surface instead of a tab-level fallback.

### Changed
- Sidebar session groups keep a visible header from the first row, and the expand chevron swaps symbols instead of rotating inside layout.


> Older releases (v1.x – v2.x) are in [CHANGELOG-archive.md](CHANGELOG-archive.md).
