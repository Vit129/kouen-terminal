# Changelog

All notable changes to Harness are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and Harness follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). Each released version
has a matching `vX.Y.Z` tag and a signed, notarized DMG on
[GitHub Releases](https://github.com/robzilla1738/harness-terminal/releases).

## [3.10.0] - 2026-06-24

### Fixed
- **Terminal flash eliminated** on sidebar toggle (⌘\\), tab switch (⌘1-9), split pane (⌘D), file preview open/close, and tab close. Root cause: `metalLayer.presentsWithTransaction` was set after `updateGridSize()` changed `drawableSize` — Metal immediately invalidates cached content on size change, so the compositor saw one black frame before the new present arrived. Fix arms the flag before any drawable size change so both land in the same CA transaction. Also fixes the REBUILD path where `viewWillMove(toWindow:nil)` silently reset the flag between `PaneLifecycleManager`'s setup and `layout()`.
- Removed 5 `BLINKDBG` debug log statements left in production code (`HarnessTerminalSurfaceView`, `PaneLifecycleManager`, `FilePreviewCoordinator`).

## [3.9.1] - 2026-06-22

### Added
- Release version bump to v3.9.1.

## [3.9.0] - 2026-06-22

### Added
- Release version bump to v3.9.0.

## [3.8.0] - 2026-06-22

### Changed
- **ContentAreaViewController decomposed** into three focused coordinators: `PaneLifecycleManager` (pane rebuild/zombie lifecycle), `FilePreviewCoordinator` (file editor split panel), and `BrowserIntegrationController` (browser pane build/collect/detach). ContentAreaVC is now a thin coordinator (~270 lines, down from 58 KB).
- **ZombieHoldRegistry** centralises the retire-hold pattern (RL-040/RL-041) previously duplicated across 5+ files. All zombie-hold sites (`TerminalPaneRegistry`, `TerminalTabBarView`, `ContentAreaVC/PaneContainerView`, `GitPanelView`) now call `ZombieHoldRegistry.shared.hold()`.
- **Typed `snapshotChanged` notifications** — replaced stringly-typed `userInfo` dictionary with `SnapshotChangedPayload` struct (`revision`, `structureChanged`, `metadataOnly`, `chromeChanged`). All posting sites use `NotificationBus.shared.postSnapshotChanged(_:)`; consumers read `notification.snapshotPayload`.
- **IPC protocol versioning** — `identifyClient` now carries a `protocolVersion: Int` field matching `ipcProtocolVersion = 1`. The daemon returns `.protocolRejected` and closes the connection on version mismatch, preventing silent misbehaviour from version-skewed client/daemon pairs.

### Fixed
- `full-cycle.sh` CHANGELOG prompt used bash-only `${confirm,,}` lowercase expansion — replaced with `tr` for zsh compatibility.

## [3.7.0] - 2026-06-21

### Added
- Release version bump to v3.7.0.

## [3.6.2] - 2026-06-21

### Fixed
- **RL-040 zombie crashes (6 sites)** — applied `nonisolated + MainActor.assumeIsolated` to all remaining `@objc` callbacks on `HarnessTerminalSurfaceView`: `viewDidMoveToWindow`, `viewDidMoveToSuperview`, `viewWillMove(toWindow:)`, `displayTick`, `keyDown`, `keyUp`. Eliminates the Swift 6.3 thunk's `swift_getObjectType` isa read on freed views.
- **RL-040 TerminalTabBarView.layout crash** — increased retire-hold from 500ms to 1.5s
- **RL-040 FlippedView.isFlipped crash** — added `nonisolated` on property + retire-hold
- **Split pane goes to wrong branch** — Cmd+D/Cmd+Shift+D now starts in the session's worktree (not repo root). When an agent runs, its process CWD resolves to repo root; fixed by preferring `worktreePath` over live process CWD.

## [3.5.3] - 2026-06-21

### Added
- File click action setting — choose preview, editor, vi, cat, or terminal-only
- Tab pill: branch name as primary title, repo name as context subtitle
- Sidebar worktree grouping fix — uses parentRepoPath for correct repo grouping
- `harness-cli install-tools` — one command to install zoxide, fd, fzf, rg, bat, eza, jq, lazygit
- ⌘⇧I toggles the Agent Notch panel so you can select the notifying agent directly
- ⌘⇧U opens the Notifications inbox/dropdown
- Agent Notch rows show both agent and source tab/session so notifications are easier to trace
- Persistent notch peek — notification stays until user clicks
- macOS native toast notifications for agent done/waiting (osascript fallback)
- Always auto-isolate worktrees on branch switch (not config-gated)

## [3.5.2] - 2026-06-20

### Added
- **Split pane shortcuts** — split right/down with `⌘D`/`⌘⇧D` (`:split-window` supports `--right/--bottom` flags)

### Fixed
- **Window not showing on launch** — `HarnessAIChatView` constraint activation order caused NSGenericException (no common ancestor), swallowed by AppKit leaving app running with zero windows
- **RL-040 keyDown/keyUp/mouseMoved/resetCursorRects crashes** — removed all remaining `nonisolated + MainActor.assumeIsolated` patterns from `HarnessTerminalSurfaceView`; Swift 6.3 allows `@MainActor override` directly
- **TerminalTabBarView.layout() crash** — same RL-040 pattern fix

### Removed
- Built-in AI chat sidebar tab (Harness connects AI via CLI agents + MCP/ACP instead)
- Search sessions field from sidebar header (⌘P palette is the primary search)
- Search panel sidebar tab (`:grep` command and ⌘P palette cover this)
- Notification bell from sidebar (Notch panel ⌘I is the single notification UI)
- `MANUAL_TEST_PLAN.md`

## [3.4.0] - 2026-06-19

### Added
- GitHub PR/CI integration — sidebar badge click opens PR in browser pane, CI status indicators (✓/✗/○)
- Browser pane multi-tab support (tab bar, new tab, close tab, target=_blank handling)
- Auto-isolate worktrees on branch switch (when `harness.json` `isolateAgents=true`)
- Auto-archive worktrees on session close when branch merged
- Personal project config override (`~/.config/harness/projects/`)
- `:recent` scoped to current worktree, `:make` uses `harness.json` `runScript`
- Hover-to-reveal pane controls with button hover highlight
- ⌘-click GitHub URLs opens in browser pane (not external browser)

## [3.3.0] - 2026-06-18

### Added
- Single source of truth for keybindings (BannerShortcutRegistry.Keybinding)
- ⌘W close pane/tab (iTerm2/Warp pattern), ⌘T new tab
- IDE-like navigation: folder double-click cd, ⌘P zoxide jump, :cd to shell
- Interactive cheat sheet (make cheatsheet)
- Welcome banner with categorized shortcuts (Sessions/Navigation/Search & Navigate/Shell)
- Robot Framework: keybinding_crash_regression.robot

### Fixed
- Zombie crash (RL-040/041): guard window != nil in keyDown/keyUp
- full-cycle.sh now auto-tags + creates GitHub release

## [3.2.11] - 2026-06-18

### Fixed
- **Eliminate macOS 26.5 zombie view crashes** — 40+ crashes resolved via NSEvent local monitor, deferred dealloc (500ms), tracking area guards (18 sites), layout override cleanup (16 sites), and first-responder resign before rebuild.
- **Memory leak** — BoardViewController NSTextField leak (21GB over 11hrs) fixed with column-diff guard.
- **Image preview blink** — reuse QLPreviewView instead of recreating on each file click.
- **Sidebar tableView crash** — bounds-check row index in delegate methods.
- **⌘\\ sidebar toggle on first launch** — force apply initial sidebar state if not yet run.
- **Git panel Fetch/Pull/Push** — add loading indicator, success/error toast, ahead/behind count on sync button.

### Changed
- Build scripts kill app before build to prevent crash loop during install.
- Retire delay increased to 500ms to cover full key press/release cycle.

## [3.2.10] - 2026-06-18

### Added
- Release version bump to v3.2.10.

## [3.2.9] - 2026-06-18

### Added
- Release version bump to v3.2.9.

## [3.2.8] - 2026-06-18

### Added
- Release version bump to v3.2.8.

## [3.2.7] - 2026-06-17

### Added
- Release version bump to v3.2.7.

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
- **Welcome banner unified shortcuts** — merged "Try this" and "Native shortcuts" into a single "Shortcuts" section with Harness-native shortcuts (`⌘⇧N`, `⌘D`, `⌘⇧D`, `⌘P`, `⌘F`, `⌘B`, `⌘;` etc.). Removed all `ctrl-a` prefix references.
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
