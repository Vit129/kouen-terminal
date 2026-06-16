# Changelog

All notable changes to Harness are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and Harness follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). Each released version
has a matching `vX.Y.Z` tag and a signed, notarized DMG on
[GitHub Releases](https://github.com/robzilla1738/harness-terminal/releases).

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

## [2.7.1] - 2026-06-15

### Fixed
- **Browser Pane close button now works.** `closeBrowserPane`'s pane-tree mutation was being silently overwritten by `DaemonSyncService`'s browser-pane re-injection logic running on local snapshots too; `applyLocalSnapshot` no longer re-injects closed browser panes.
- **Browser Pane toolbar buttons no longer blocked by a hidden error banner.** The collapsed error banner's dismiss button extended into the toolbar and intercepted clicks meant for refresh/close; the banner is now hidden (not just zero-height) when collapsed.

### Added
- **⌘B opens a new Browser Pane** from the Window menu and the per-pane toolbar, matching the existing split-pane shortcuts.
- **Clicking a localhost or LAN dev-server link in terminal output opens it in the in-app Browser Pane** instead of the system browser — covers `localhost`, `127.0.0.1`, `0.0.0.0`, `::1`, and private IPv4/IPv6 ranges (`10.x`, `172.16-31.x`, `192.168.x`, `fe80::/10`, `fc00::/7`).

## [2.7.0] - 2026-06-15

### Added
- Release version bump to v2.7.0 (build 135).

## [2.6.3] - 2026-06-13

### Added
- Release version bump to v2.6.3.

## [2.6.2] - 2026-06-13

### Added
- Release version bump to v2.6.2.

## [2.6.1] - 2026-06-13

### Added
- Release version bump to v2.6.1.

## [2.6.0] - 2026-06-13

### Added
- Release version bump to v2.6.0.

## [2.5.3] - 2026-06-13

### Changed
- **`⌘[` / `⌘]` repurposed for session navigation.** Previously bound to `⌘⇧[`/`⌘⇧]` and wired to dead tab-switching code with no visible UI effect. Now they cycle to the previous/next session (same `selectAdjacentSession` mechanism as `⌘1–9`), matching the top bar's one-pill-per-session model.

### Removed
- **Dead tab-switching shortcuts and code.** `selectTabNumber(_:)`, `SessionCoordinator.selectTab(atIndex:)`, and the old `selectAdjacentTab(offset:)` operated on a `Tab` collection with no separate UI representation — switching "tabs" was a silent no-op from the user's perspective. Removed in favor of the session-level navigation that actually matches the top bar pills.

## [2.5.2] - 2026-06-12

### Fixed
- **Metal surface memory leak on pane close.** The async `syncFromDaemon` path (used by all real-time snapshot refreshes) was missing `terminalHosts.prune(keeping:)` — dead `TerminalHostView` instances and their Metal surfaces accumulated for the app lifetime every time a pane was closed via a daemon-side event. The prune now runs in both the sync and async variants.
- **Vi mode crash on malformed clipboard content.** `ViNormalMode.isWordChar` force-unwrapped `UnicodeScalar(unichar)`, which returns `nil` for surrogate code units (U+D800–U+DFFF). Pastes containing unpaired surrogates would crash. Now guarded with `guard let`.
- **`⌘1–9` method rename.** `MenuTarget.selectSessionNumber` renamed to `selectWorkspaceNumber` to match its actual behaviour (switches workspaces, not sessions within a workspace).

## [2.5.1] - 2026-06-12

### Fixed
- **Translucent window legibility.** Window background now uses the theme color at the current opacity instead of pure `.clear` when translucent. At any opacity below 100 %, the terminal background colour acts as a tint layer behind the CGS blur, so text remains readable regardless of what is displayed behind the window — matching the semi-opaque tinted glass behaviour Apple introduced in iOS/macOS 27.

### Added
- **Per-theme-mode background opacity.** When "Auto light/dark" is enabled, separate opacity sliders for the light and dark themes appear in Settings → Appearance. Lets a white/light theme stay fully opaque (unreadable otherwise) while a dark theme keeps its translucent look. Opacity is saved and applied automatically on every system-appearance switch.
- **⌘1–9 session switch fixed.** Keyboard shortcuts now correctly switch to the Nth session inside the active workspace instead of calling `selectWorkspace(byIndex:)` which was a no-op when only one workspace existed.

## [2.5.0] - 2026-06-12

### Added

**Terminal power-user (vi, tmux, keyboard navigation)**

- **Full vi normal mode in file editor.** `ViNormalMode.swift` implements the complete vi modal editing model: normal / insert / visual (v, V) / replace (R) / operator-pending modes; hjkl/wWbBeE/0^$/gg/G/{}/% motions; H/M/L screen-position jumps; Ctrl+d/u/f/b scroll; f/F/t/T/;/, character-find; `d/c/y` operators + text objects (`iw/aw`, `i"/a"`, `i'/a'`, `` i`/a` ``, `i(/a(`, `i[/a[`, `i{/a{`, `ip/ap`, `is/as`); `dd/cc/yy`; visual operators `d/y/c/>/</u/U/~/=`; `gv` reselect; marks `ma/'a/\`a`; named registers `"ayy/"ap`; macros `qa/@a/@@`; count prefix `3w`; `.` repeat; `ZZ/ZQ`; H/M/L; jump list Ctrl+o/Ctrl+i; inline `*/#` search highlight.
- **Vi `:` ex command mode.** Overlay panel at window bottom: `:w` save, `:q`/`:wq`/`:x`/`:q!` close, `:N` go-to-line, `:s/old/new/g`, `:%s`, `:noh`, `:set number/relativenumber/hlsearch/ignorecase/wrap`, `:e <file>`, `:bn`/`:bp`, `:ls`/`:buffers`.
- **`:set relativenumber`** renders true relative line numbers in the editor gutter.
- **Inline `*` search highlight** — all occurrences highlighted in yellow; cleared by `:noh`.
- **Jump list** — Ctrl+o (back) / Ctrl+i (forward); pushes on mark jump and go-to-definition.
- **Keyboard navigation in file tree.** j/k move cursor, h/l collapse/expand folder, Enter/o open/preview file, g/G first/last entry, Ctrl+d/u half-page scroll, `/` focuses the filter field. Focused row is highlighted.
- **LSP activated in file editor.** Hover tooltip (mouse-over), go-to-definition (⌘+click), and diagnostics underline now live. Supports Swift (sourcekit-lsp), TypeScript, Python (pyright), Rust (rust-analyzer), Go (gopls) — auto-detected by project root markers.
- **⌘1–9 switches sidebar sessions** (workspaces) instead of tabs within a workspace.
- **zoxide integration in Switch Project** (⌘K) — frecency list from `zoxide query -l` appended to open-tabs projects; selecting opens a new session in that directory.
- **`clear-history` tmux command** — clears pane scrollback without respawning the shell.
- **`word-separators` option** — configure double-click word boundary characters (`set-option -g word-separators " \t/.:"`).
- **`wrap-search` option** — copy-mode `/` search stops at buffer edge when `off`; wraps when `on` (default).
- **`show-prompt-history`** — displays `:` command history via display-message.
- **`resize-window -x <cols> -y <rows>`** — overrides tab surface dimensions.
- **`list-sessions/windows/panes/clients -F <format>`** — format-string output for all four list commands.
- **`list-sessions/windows/panes/clients --json`** — JSON array output.
- **`window-size` option** — vote aggregation strategy: `smallest` (default), `largest`, `latest`.
- **`destroy-unattached` option** — kills all sessions when the last client detaches.
- **`find-window -C` from hooks** — daemon-side content search via `capturePane`; no longer silently dropped.
- **`resize-window` IPC** — `IPCMessage.resizeWindow(tabID:rows:cols:)` + SurfaceRegistry handler.
- **`:bn`/`:bp` navigate file tabs** from vi ex command; `:ls`/`:buffers` lists open tabs.

### Changed
- `word-separators` default: space + tab (tmux default extended with tab).
- `applyEffectiveSize` in DaemonServer reads `window-size` option to pick smallest/largest/latest client vote.

## [2.4.0] - 2026-06-12

### Added
- **Ctrl+R command history search.** Fuzzy search overlay for past commands — type to filter, sorted by recency; selecting a command seeds the command prompt with the cursor at the end.
- **Layout presets (⌘⌥1–5).** One-key pane layouts: Even Horizontal, Even Vertical, Main Horizontal, Main Vertical, Tiled — available from the View menu.
- **Fuzzy file quick-open in command palette.** The command palette now includes a "Files" section when searching — fuzzy-matches filenames and relative paths in the active workspace. File enumeration runs in a background task (no main-thread stutter).
- **Switch Project section in command palette.** tmux-sessionizer-style project switcher — lists open tabs' CWDs as projects; selecting one focuses that session.
- **Workspace symbol search in command palette.** "Symbols" section matches function/class/variable names from source files in the active workspace; selecting a symbol sends it as keystrokes to the active terminal.
- **Git worktree → session tab integration.** Adding a worktree automatically opens a new session tab for it; removing a worktree closes its tabs.
- **Terminal cheatsheets.** `Scripts/cheat.sh` + fzf-searchable Linux and Vi/Vim cheatsheets under `Scripts/cheatsheets/`.

### Fixed
- **Split-pane close button closes the clicked pane, not the active one.** The per-pane hover close button now uses `killPane(paneID:)` instead of `killActivePane()`.
- **Text wrap incorrect in newly split panes.** `HarnessSplitView.layout()` now forces a synchronous child layout pass after setting divider positions, so the PTY sizes against the correct post-split width.
- **Snapshot notification burst stacking.** `snapshotChangedNotification` now coalesces repeated notifications into a single async refresh task instead of stacking synchronous `syncFromDaemon()` calls on the main actor, eliminating the reconnect/back-to-app slowdown.

## [2.3.0] - 2026-06-11

### Added
- **Local workspace completion.** The file editor now offers autocomplete suggestions
  from workspace symbols (functions, classes, variables) — powered by a lightweight
  off-main tokenizer. Type 2+ characters to see matches; Tab/Enter to accept.
- **IDE Mode shortcut (⌘+⇧+D).** Toggles between full terminal and IDE layout
  (sidebar + editor panel + terminal) with a single keystroke.
- **Session state indicator.** Sidebar session cards now show a colored dot:
  blue = command running, gray = idle, green = exited OK, red = exited with error.
- **IDE mode persistence.** Editor split visibility, open tabs, and active tab
  are remembered across app launches via UserDefaults.
- **Diff/patch syntax highlighting.** `.diff` and `.patch` files get colored
  `+`/`-` lines (green/red), `@@` hunk headers (cyan), and bold file headers.
  Gutter markers also show add/delete/modify bars per line.
- **Git Changes click-to-preview.** Clicking a changed file in the Git Changes tab
  opens its diff in the editor panel.
- **Git History right-click menu.** Right-click a commit card for: Copy Commit ID,
  Copy Commit Message, Copy Summary (hash + subject), or Show Diff.

### Changed
- **P9 complexity reduction.** Extracted `LiveResizeGeometry`, `PasteController`,
  `SelectionResolver` from `HarnessTerminalSurfaceView`; extracted `FormatContextBuilder`
  and `HookExecutor` from `SurfaceRegistry`; extracted 8 CLI handler groups from
  `HarnessCLI.swift`; extracted `WindowInputRouter` with unit tests.

### Fixed
- **Terminal flicker on file preview open/close (CASE-025).** Set
  `presentsWithTransaction = true` during programmatic layout changes to sync
  Metal rendering with the main CATransaction.

## [2.2.4] - 2026-06-11

### Added
- **File preview live reload.** The file editor tab and sidebar file viewer now watch
  the previewed file on disk and automatically reload (debounced) when it changes
  externally — including QuickLook previews (images, PDFs, Office docs, Excel, CSV),
  which now call `refreshPreviewItem()` so they don't show a stale cached render.

### Fixed
- **Terminal rendering corruption from interleaved status messages.** OSC 133;D
  (command-finished) was clearing DEC 2026 synchronized-output mode, even when a
  sub-command's shell integration fired it while an outer TUI's `?2026h` redraw batch
  was still open (e.g. an agentic CLI's status box around a tool's shell output). This
  made the renderer present a half-applied frame, splicing fragments of two unrelated
  redraws into the same rows. `resetForShellPrompt()` no longer touches
  `synchronizedOutput`; the existing sync-timeout safety valve still recovers from a
  program that never clears `?2026h`.
- **Sidebar disappears after collapse-then-expand with "Always collapse sidebar on
  launch" enabled.** Forcing the sidebar closed on launch left the persisted
  `sidebarVisible` setting stale (`true`), so the first expand toggle computed
  `!true -> false` and was a no-op. The forced-collapse path now syncs
  `sidebarVisible` to `false` so the next toggle correctly expands.

## [2.2.3] - 2026-06-09

### Fixed
- **File editor opacity parity with terminal.** The file editor panel now respects the
  Background Opacity slider in Settings > Appearance. Previously the editor always showed
  full window vibrancy regardless of the opacity setting; now it applies
  `terminalBackground × opacity` to the panel layer — matching how the terminal chrome
  and sidebar handle translucency.

## [2.2.2] - 2026-06-08

### Fixed
- **File preview text rendering.** Reverted NSTextView layout changes that caused text
  to be invisible (zero-width text container). Preview now reliably displays file content.
- **File preview background matches terminal.** Removed opaque backgrounds from editor
  panel, tab bar, and gutter — window vibrancy now shows through identically to the
  terminal pane.
- **File path handling.** Strip surrounding quotes and resolve symlinks when opening
  file paths from terminal clicks or sidebar.
- **Sidebar group header buttons on FHD displays.** The `+` (new session in group) and `…`
  (group options) buttons in the session group header now use `SoftIconButton` instead of
  `NSButton` with `.inline` bezelStyle. The old bezel style rendered a visible native
  AppKit background on non-Retina (FHD) screens, making these icons look different from
  the footer `+` button. Both now share the same layer-driven, bezel-free chrome.
- **Terminal tab bar background.** The terminal tab bar now uses a flat background matching
  the terminal canvas color with a single bottom border, replacing the elevated
  sidebar-tinted glass backdrop. This aligns it visually with the file-editor tab bar.

### Added
- **Draggable file editor divider.** The editor/terminal split can now be resized by
  dragging, like Zed.
- **Cmd-click file paths in terminal.** Detect and open quoted/unquoted file paths,
  `file://` URLs, and paths with `:line:col` suffixes.

## [2.2.1] - 2026-06-08

### Fixed
- **Git panel "Changes" row layout.** Rows now pin to the full list width instead of
  sizing to their own content, so checkboxes sit flush left/right consistently instead of
  drifting based on filename length. Same width-pinning applied to History commit cards
  and Worktree rows.
- **File preview rendering.** The text editor pane now draws an explicit dark background
  and brighter foreground text, fixing a black-screen/invisible-text regression when
  previewing files.
- **Sidebar session card consistency with the tab bar.** Session rows now derive their
  agent icon from any tab in the session (not just the active one) and always show the
  active tab's live folder/agent name as the title, instead of a custom session name that
  could go stale once the session `cd`'d to a different project.

### Changed
- **Git "Changes" row redesign.** Each row now shows a colored status badge (M/A/D/U),
  the filename, `+N -M` insertion/deletion counts (from `git diff --numstat HEAD`), and
  a right-aligned stage checkbox.
- **Files sidebar search.** Added an inline filter field above the file tree for
  fuzzy-matching file names.
- **File editor panel background** now matches the terminal background (including the
  user's opacity setting) instead of the sidebar background.

## [2.1.0] - 2026-06-08

### Added
- **ACP Client (shelved).** Agent Chat Protocol client with sidebar panel, config UI,
  and per-agent adapter resolution. Shelved due to ecosystem immaturity (adapter binaries
  not widely available, PATH unreliable inside .app bundles).
- **Real-time Git panel refresh.** DispatchSource watcher on `.git` directory with 500ms
  debounce triggers automatic refresh on commit/stage/checkout.
- **Git History → file editor.** Clicking a commit in History opens the full diff in the
  file editor panel with syntax coloring (green/red/blue/purple).

### Fixed
- **macOS 26 Swift 6 crashes.** Replaced `MainActor.assumeIsolated` inside
  `DispatchQueue.main.async` with `Task { @MainActor in }` in GitPanelView,
  SurfaceShellTracker, and DaemonLauncher (CASE-013).

## [2.0.0] - 2026-06-08

### Added
- **File preview panel.** Constraint-based sibling panel (40% editor / 60% terminal)
  — never reparents terminal Metal surfaces (CASE-012). Supports syntax highlighting,
  Quick Look for images/PDFs, vi-like edit mode, and git diff gutter.
- **CWD tracking via daemon.** `AgentScanner.cwdTimer` polls proc_pidinfo every 500ms,
  updates sidebar and tab bar in real-time without shell integration.
- **Session grouping by CWD.** New tabs insert adjacent to tabs with the same working
  directory.

### Changed
- **Sidebar polish.** Session ID shown in cards, Agent tab hidden (code preserved),
  tab reorder persists sortOrder to UserDefaults on every drag.

## [1.9.0] - 2026-06-08

### Added
- **Git panel: Worktrees tab.** Add/remove worktrees from the sidebar Git panel.
- **SurfaceShellTracker.** Daemon-side process tree scanning for running agent detection.
- **Async IPC (P2-async).** `DaemonClientActor` and `SessionCoordinator` for
  non-blocking daemon communication with snapshot notifications via `NotificationBus`.
- **Preview/production session isolation.** Preview builds use `.harness-preview/`
  directory with isolated daemon socket.

### Fixed
- **DECRQM echo race.** Stop replying to DECRQM 2026/2027 and Kitty keyboard queries
  to prevent garbled shell output.
- **File tree performance.** Removed 3s polling (FSEvents sufficient), reconcile nodes
  in-place to preserve expand/collapse state (CASE-015).

## [1.8.0] - 2026-06-07

The tmux-parity close-out: every remaining tracked gap is either shipped, adapted with a
documented rationale, or explicitly rejected in [docs/TMUX_PARITY.md](docs/TMUX_PARITY.md) —
Harness now carries its own complete tmux at the capability level. Plus the first-run /
what's-new terminal banner. Each piece was review-hardened pre-merge (every Bugbot finding
adversarially verified, 39 additional findings fixed, all pinned by tests).

### Added
- **First-run welcome tour and post-update "what's new" banner.** A one-shot MOTD in the
  first fresh terminal: a quick tour on a clean install, the release highlights after an
  update. Daemon-injected like real shell output, never repeated (durable ack with retry),
  suppressible via the `update-banner` option.
- **~25 new `#{…}` format variables** — `pane_pid`, `pane_current_command`, `pane_width/height`,
  `pane_dead(+_status)`, `history_bytes`, `session_id`, `window_id`, `session_windows`,
  `window_panes`, `window_active`, `window_flags`, `session_attached`, `session_group`,
  `client_width/height/tty/termname`, `host(_short)`, `pid`, … — with tmux's `$`/`@`/`%`
  ID prefixes so displayed IDs round-trip into `-t` targets.
- **Full `-t` target grammar for `select-pane` / `swap-pane`**, plus `swap-pane -s <src>`
  (swap two arbitrary panes). Strict resolution everywhere: a `-t`/`-s` that names a missing
  session/window/pane fails loudly in every front-end — `kill-pane -t bogus` can no longer
  silently kill the focused pane.
- **Bindable config/buffer/hook verbs** — `set`/`setw`/`show`/`setenv`/`showenv`/`setb`/
  `pasteb`/`deleteb`/`lsb`/`showb`/`set-hook [--if]`/`show-hooks`/`unbind-hook` work from
  `bind-key`, the `:` prompt, hooks, and `source-file`, so a `.tmux.conf`'s config lines
  migrate unchanged.
- **`find-window`** (name/title by default, `-C` pane-content) with loud no-match in every
  front-end; tmux's `copy-mode-vi` table name accepted everywhere a table is typed.
- **Session/window lifecycle hook events** — `session-created/renamed/closed`,
  `window-renamed/linked/unlinked/layout-changed` — with subject-true contexts (a
  `session-closed` hook formats the closed session, not the survivor), plus `set-titles(+string)`,
  `detach-on-destroy`, and `display-time` options.
- **Grouped sessions** (`new-session -t <session>`, CLI `--group-with`): a shared window
  list with per-member focus; window create/kill propagates group-wide, including after
  members' layouts diverge.
- **Server-admin verbs** — `kill-server` / `start-server` adapted to launchd supervision
  (PID-identity-checked, remote-`--host` safe), `respawn-window`, `refresh-client`,
  `show-messages` (includes hook-fired messages).
- **`docs/TMUX_PARITY.md`** — the honest capability ledger: at-parity / adapted / rejected /
  deferred, with the no-silent-misroute invariant it protects.

### Fixed
- `synchronize-panes` is one state across the GUI, the SSH compositor, and `setw` — toggles
  write the per-tab option through, so a snapshot push can't revert a local toggle.
- GUI, compositor, and control mode surface daemon validation errors (unknown hook event,
  bad option scope) instead of reading as success; control mode emits `%error` for them.
- CLI `setw` writes the tab scope like every other front-end (it silently wrote a global);
  scoped CLI sets resolve the calling pane via `$HARNESS_SURFACE`.
- Option/env/buffer values that begin with `-` are no longer swallowed as flags (getopt-style
  parsing with `--` support); a bare `set-environment KEY` errors instead of persisting `""`.
- Detaching `attach-window` restores the outer terminal title (`set-titles`); destroying the
  attached session re-pins the surviving session's workspace.

## [1.7.1] - 2026-06-06

The post-release audit of 1.7.0: a second exhaustive multi-agent pass (56 hunt dimensions across
the release diff and the whole app, refute-by-default verification, every fix below pinned by a
regression test that fails on the pre-fix code where feasible).

### Fixed
- **RIS left the saved cursor alive, so `DECSC → RIS → DECRC` restored pre-reset state.** A full
  reset (`ESC c`) now clears the DECSC save like xterm; DECRC after RIS restores home + the
  default pen instead of leaking the old position and colors into freshly-reset programs.
- **A torn read in the hook registry could crash the daemon.** `bind-hook`/`unbind-hook` saves
  encoded the live hook array outside the lock; concurrent mutations made `JSONEncoder` trap
  (reproduced: index-out-of-range within 15 runs). Saves now snapshot under the lock, matching
  the option/environment stores.
- **Copying a selection after scrollback eviction silently produced blank text.** The selection
  anchor (unlike the cursor) was never clamped when history shrank under copy mode; stale anchors
  now clamp on every motion and at extraction, so `y` copies real content instead of whitespace.
- **Block/char selections dropped a wide (CJK) glyph when only its trailing cell was covered.**
  Extraction now includes any character whose span intersects the selected columns — the text you
  copy matches the cells the highlight covers.
- **`n`/`N` in copy-mode search jumped to stale rows after scrollback eviction.** Matches are
  re-derived from the live buffer on every search step instead of trusting line numbers cached at
  search time.
- **A wedged binary froze onboarding forever.** The install step's `version --json` probe had no
  timeout; a corrupted/stuck binary blocked the main actor with Continue/Skip locked until
  force-quit. The probe is now fully bounded (3s + SIGTERM/SIGKILL escalation) and surfaces as
  "no version info" so the install continues on the fallback path.
- **Settings fields could show a value the terminals weren't using.** Committing an out-of-range
  fontSize / window padding / scrollback now reflects the clamped value back into the field (the
  command-finished threshold already did); color swatches and placeholder hex now refresh when
  auto light/dark flips the theme while Settings is open.
- **`bind -n` (root-table) bindings ignored caps lock.** An uppercase letter typed without Shift
  now falls back to the lowercase binding, mirroring the prefix table — while Shift+letter stays
  distinct so a typed `C` is never swallowed when only `bind -n c` exists.
- **IME composition over a selection was indistinguishable from the selection.** Preedit text
  inherited the selection / find-highlight background; it now resets its cells to the canvas
  background (translucency intact) so composition always reads as "being typed".
- **`select-pane`/`swap-pane -t` silently misrouted bad targets to the next pane.** Unrecognized
  or dangling `-t` values now fail loudly with the accepted forms (`:.+`, `:.-`, `!`), like every
  other validated flag.
- **Status-line layout counted scalars, not columns.** `status-left`/`status-right` padding and
  `display-message`/`status-format` clipping in `attach-window` overflowed one column per wide
  (CJK) glyph; all measurement and truncation is now display-width-aware.
- **`harness-cli remote add` could report success without persisting.** Write failures in
  `remote-hosts.json` are now surfaced (exit 1, naming the file); concurrent CLI invocations are
  serialized with a cross-process file lock so the second writer no longer silently discards the
  first's hosts.
- **SSH tunnel failures all read as timeouts.** When `ssh` exits before the tunnel is ready the
  error now reports its exit status ("check the host, credentials, and remote socket path")
  instead of the generic not-ready-in-time message.
- **A dangling `--ssh-arg` was silently dropped**; it now errors with exit 64 like the other
  validated flags, and `bind-key`/`unbind-key` no longer eat a key spec literally named `prefix`
  when `-T` wasn't passed.
- **Killed panes leaked their terminal views.** The pane registry now prunes hosts that left the
  daemon snapshot on every structural sync, so split+kill cycles no longer accumulate dead
  Metal-backed views for the life of the app.
- **Hooks installed on Linux pointed at the macOS binary path.** `install-hooks` now emits the
  XDG path (`${XDG_DATA_HOME:-$HOME/.local/share}/harness/bin`) on Linux, so agent notifications
  actually reach the daemon there.
- **Closing a session never cleaned its scoped environment.** `set-environment -t <session>`
  entries now clear on session/workspace close instead of accumulating in `environment.json`
  forever.
- **A respawn racing the metadata scan could briefly publish the dead shell's cwd.** The off-lock
  cwd probe now records which child PID it measured and skips the commit when a respawn swapped
  the child mid-probe.

### Added
- **`.harnesstheme` files now open in Harness.** Double-click (or Open With) imports the theme —
  validate → "Install / Install and Apply" — installing into `Application Support/Harness/themes`
  and optionally applying its colors and appearance immediately. The format was already shipped;
  the app-side wiring was the missing piece.
- Regression tests pinning the daemon-reconnect backoff policy, the OSC 9;4 stale-progress
  timeout, corrupt `layout.json` recovery, reap-generation eviction order, and the onboarding
  probe failure modes (~45 new tests).

## [1.7.0] - 2026-06-06

The production-hardening release: a full adversarial audit (multi-dimension bug hunt →
refute-by-default verification → fixes → post-fix review → live validation) across the daemon,
IPC, terminal engine, CLI, settings, and onboarding. Every fix below was verified with a repro
or code-trace before it was written, and the fix batch itself was adversarially re-reviewed
(#96–#98 are that review's catches).

### Fixed
- **Daemon could refuse to start forever after a force-kill or reboot.** (#93) The stale-instance
  gate trusted `daemon.pid` + `kill(pid, 0)` alone; a recycled PID belonging to any live process
  made the fresh daemon exit, and launchd's restart loop never escaped. The gate now verifies the
  prior PID is actually a HarnessDaemon via `proc_pidpath` and otherwise clears the stale file —
  the socket-ping guard remains the authority.
- **Attaching to a busy surface could silently drop output.** (#95) Attach was
  replay-then-subscribe across two sockets with no backfill: bytes arriving in the window were
  persisted but never delivered (repro'd: 217 lost markers). Attach now subscribes first, buffers
  live frames, replays, then flushes the buffer deduplicated by the daemon's byte sequence — with
  a compatible fallback against older daemons.
- **Keystrokes typed while a daemon subscription was dying were silently dropped.** (#95)
  `sendInput` now reports failure and input immediately falls back to the one-shot request path.
- **Daemon startup could permanently delete scrollback for a surface whose shell failed to
  spawn.** (#93) The orphan-file sweep only considered live PTYs; it now keeps any scrollback
  referenced by the layout, so a transient spawn failure (fork pressure, missing shell) no longer
  costs the pane's history.
- **A keystroke could stall behind a full process-tree scan every 1.5s.** (#93) The metadata
  refresher held the registry lock — the one every IPC request needs — across an
  all-system-PIDs walk per pane (measured 6–12ms at 10–20 panes). The scan now runs off-lock
  with identity-checked write-back, plus a `childPID` read race and the log-rotation race fixed
  and the PID file made owner-checked.
- **Children that ignore SIGTERM+SIGHUP leaked a blocked reaper thread per close.** (#93)
  `close()`/`respawn()` now escalate to SIGKILL after a grace period, with PID-reuse guards;
  the watcher remains the sole reaper.
- **Thai: SARA AM after a marked base rendered a dotted circle** (น้ำ, ต่ำ, ซ้ำ). (#94, closes #66)
  U+0E33 now decomposes on input into NIKHAHIT (folded onto the base) + SARA AA, so CoreText never
  shapes an orphaned spacing mark; buffer search splits the needle the same way so precomposed
  queries keep matching, and the cursor-text color now applies on marked clusters.
- **`harness-cli bind-hook --if <cond>` crashed with a Swift range trap.** (#92) Malformed
  argument shapes now print usage and exit 1 before any IPC.
- **Invalid `--detach-keys` silently attached with the default detach binding.** (#92) Both attach
  paths now fail loudly (exit 64) naming the bad value and accepted formats; `new-split --pane`
  and `select-layout --main` with a malformed UUID now error instead of silently acting on the
  active pane.
- **CSI parameters above 65535 dropped the whole control sequence.** (#91) `ESC[99999H` (the
  "jump to bottom" idiom) was a no-op; oversized values now clamp (xterm/Ghostty parity) while the
  DoS guards for parameter count stay intact. Invalid DECSTBM (`top ≥ bottom`) no longer clobbers
  the scroll region and homes the cursor (now a no-op), and DECRC without a prior DECSC restores
  the default pen instead of leaking the current SGR state.
- **`fontSize` from a hand-edited settings.json was unclamped.** (#89) Extreme values blanked
  glyphs (atlas overflow at ~500pt) or allocated hundreds of MB of grid (sub-1pt); the persistence
  boundary now clamps to the same 8–32 the zoom shortcuts use. An empty font family now falls back
  to Menlo like an unknown one.
- **Re-running onboarding from an older Harness.app could silently downgrade newer installed
  binaries.** (#90) Install is now version-aware (build-number probe): byte-identical copies are
  skipped and a newer installed daemon/CLI is kept, with the outcome shown in the wizard.
- **The onboarding fish completion drifted from the real CLI.** (#90) The wizard now uses the same
  catalog-driven generator as `harness-cli completions`; the catalog gained the missing verbs and
  a drift-guard test asserts it covers every dispatch case.

### Changed
- **Slider drags persist once on release.** (#89) Opacity/blur/border/contrast drags wrote
  settings.json on every tick (60–120Hz); live-apply is now decoupled from persistence.
- **Destructive resets ask first.** (#89) "Reset to defaults" and "Reset agent colors" confirm
  before wiping; the resize-overlay position picker is now exposed in Appearance.
- **Hex color fields and the notification threshold re-sync after commit** instead of silently
  reverting invalid input. (#89)
- **A disconnected pane now shows a "Reconnecting…" chip** instead of freezing silently for up to
  a minute, and the Settings Advanced page shows an explicit banner (controls disabled) when the
  daemon is unreachable instead of rendering defaults as if they were real. Session IPC requests
  past 250ms now emit throttled signposts. (#95)
- **Onboarding locks navigation while installs run, notes when the CLI won't be on PATH, and
  rescans for agents when the window regains focus.** (#90)

### Added
- **SSH tunnel characterization tests** (16 — the remote-host path previously had zero coverage)
  and a **GridCompositor drift canary** asserting the onboarding preview's compositor port stays
  byte-identical to the live one. (#88)

## [1.6.0] - 2026-06-05

The redraw-efficiency release, from a proven-best-practice deep dive (kitty/foot/Alacritty/
Windows Terminal parity + Apple Metal guidance): overlays no longer disable damage-driven
rendering, streaming output reuses the scrolled band, and invisible panes stop presenting.

### Changed
- **Selection, find highlights, and IME composition ride damage-driven rendering.** (#85) Any of
  these used to force a full grid rebuild every frame for their whole duration and poison the
  reuse caches. The live view now always builds clean and a cell-overlay pass re-shades only the
  overlay rows (byte-identical by construction — it runs the same row resolver the baked path
  used); per-row fingerprints add exactly the changed rows to the damage. A selection drag
  re-encodes the rows it crossed instead of the grid; an idle find bar adds zero per-frame work;
  composition dirties only its row.
- **Streaming output shift-copies the scrolled band.** (#84) Whole-viewport scrolls (`cat`,
  builds, `tail -f`) report a purely additive damage hint; the frame builder re-resolves only the
  fresh rows and the renderer rotates its row-instance cache, as it already did for scrollback
  scrolls. Frame builds during streaming: 299µs → 74µs per tick at 200×60 (4×).
- **Covered and minimized windows stop presenting.** (#86) A pane with output flowing in a fully
  occluded window presented invisibly at full cadence; per Apple guidance it now never acquires a
  drawable while covered (parsing continues; one fresh frame presents on un-occlusion).
- **ProMotion displays render at the panel's full rate while active.** (#83) The render display
  link now requests the variable-refresh panel's maximum via `preferredFrameRateRange`; the link
  still pauses at idle.
- **Frame telemetry: p99 percentiles and classified drops.** (#83) The signpost flush line gains
  p99 (tail dropouts were invisible between p95 and max) and splits dropped presents by cause
  (drawable-pool exhaustion vs encode failure). Cursor-blink cost is pinned by test at ≤1
  re-encoded row per toggle (#87).

## [1.5.1] - 2026-06-05

Cursor and resize-fluidity fixes on the live-resize release: the cursor no longer turns into a
permanent block after a TUI resets it, streaming output keeps moving while you drag, and the
per-boundary re-wrap is 3× faster on deep scrollback.

### Fixed
- **Cursor stuck as a thick block after running a TUI.** (#80) `CSI 0 SP q` (and the parameter-less
  `CSI SP q`) — the standard "reset cursor" sequence programs emit on exit — was mapped to a hard
  blinking block instead of the user's configured style (the Ghostty/kitty/xterm de-facto
  semantics). Because attach replays the persisted scrollback tail, a leaked reset re-applied the
  block at every launch, making it look permanent. `0` now resolves back to your configured
  cursor style; `1` remains the explicit blinking block.

### Changed
- **PTY output presents live during a drag.** (#81) Output arriving mid-drag (a TUI's redraw after
  `SIGWINCH`, streaming logs, keystroke echo) previously reached the screen only at the next
  cell-boundary commit — content rode one boundary behind the drag and froze while the pointer
  held still. Output now presents continuously during the drag inside explicit Core Animation
  transactions. The resize target moved into queue-shared state (`pendingResize`) applied by
  whichever build runs next, so the latest-wins build coalescing can never strand the grid at a
  stale size after the PTY vote went out.
- **Width reflow is 3× faster on deep scrollback.** (#82) The per-boundary re-wrap — paid at every
  cell-boundary crossing of a live drag — streamed source rows by reference and re-wraps
  wide-glyph-free lines with bulk slice copies instead of three full buffer materializations and
  per-cell stepping. Measured at the 10k-line scrollback cap (release): 30.25ms → 10.04ms per
  reflow (CJK-heavy content 1.5×; the drag preview 2.6×). Byte-identical to the previous
  algorithm across the golden corpus, property, fast-path, and preview-parity suites.

## [1.5.0] - 2026-06-05

The live-resize release: dragging a window edge now drives the running program in real time
(Ghostty parity), notifications split into per-event controls, and agents launched through
wrappers are recognized.

### Added
- **Real-time live resize (Ghostty parity).** (#77) Dragging the window edge now reflows the grid and
  signals the running program (`SIGWINCH`) at every cell boundary, so interactive programs
  (vim/htop/btop/tmux/less) and alternate-screen TUIs redraw *during* the drag instead of snapping
  at release. The authoritative reflow runs off-main with latest-wins coalescing (a fast drag runs
  ~1–3 reflows, not one per column), presents inside an explicit `CATransaction` so it flushes even
  when the pointer is held still, and the PTY vote coalesces per-fd and to distinct cell counts so
  the daemon isn't stormed. Default on, with a **Real-time resize** setting (`liveResizeReflow`)
  that reverts to the previous defer-to-release behavior. The non-mutating re-wrap preview is
  retained as instant feedback under the live reflow.
- **Tab persistence indicator.** (#78) A tab pinned to stay running after a clean quit
  ("Keep Tab Running After Quit") now shows a small accent pin at the leading edge of
  its tab pill — a tmux-style window flag — so kept-alive tabs are identifiable at a
  glance instead of only through the right-click checkmark. The pin also appears beside
  the tab in the overflow menu.
- **Granular notification settings.** (#79) Settings → Agents now splits notifications into
  *Notify me about* (per-event toggles for **Agent needs input**, **Agent finished**,
  **Terminal bell**, and **Command finished**) and *Delivery* (macOS banner + sound),
  so you can pick exactly which events ping you instead of one all-or-nothing switch.
  Defaults preserve prior behavior, and an existing "command finished" choice migrates
  automatically. Backed by a new `NotificationEvent` type and a sparse
  `notificationEvents` map in settings; only desktop banners are gated — the in-app
  bell/waiting indicators are unaffected.
- **Wrapper-aware agent detection (Hermes).** (#51) Agents launched through a wrapper —
  `python3 …/hermes --tui`, `uv run hermes`, `env FOO=1 hermes` — are now detected: the
  process scan parses wrapper argv with flag-aware semantics (a `-c` body never false-matches;
  non-wrapper commands never scan their arguments, so `vim hermes-notes.txt` stays invisible).
  Agents without a bundled icon get a monogram glyph in the tab pill and agent UI instead of
  falling back to generic text.

### Fixed
- **Focusing a pane clears its notification.** (#61) Clicking into a pane or ⌘-Tabbing back to
  the app now clears its waiting badge — previously only a programmatic tab switch did. The
  clear is gated on the tab actually showing a waiting badge, so ordinary focus changes skip
  the daemon round-trip.

## [1.4.1] - 2026-06-04

The resize-parity release: the live render path stops crossing full-frame value boundaries.
A width-drag boundary tick now costs the main thread no more than a sub-cell tick, and
steady-state frames cost O(damage), not O(grid) — the Ghostty `Contents` model.

### Performance
- **Async re-wrap preview.** (#72) Crossing a cell boundary mid-drag no longer blocks the main
  thread on the emulator queue for the reflow + full frame build (~3ms per crossing, scaling
  with grid height): the preview builds asynchronously with latest-wins coalescing and lands on
  the next hop, while the drag keeps re-presenting the cached frame at full frame rate. Under
  heavy output the re-wrap now works instead of being skipped. Hardening: previews coalesce in
  their own token namespace (output bursts during animated resizes — sidebar slides — can no
  longer cancel them), the debounced grid commit defers while the drag holds (a stationary
  >60ms hold used to freeze the screen until the next pointer move), and stale previews are
  dropped at drag end and across pane re-mounts.
- **Content-keyed row salvage.** (#76) A column-count change used to discard the renderer's
  whole row cache; rows whose rendered content is unchanged (hashed over every render-affecting
  field) now re-bind their cached instances across the width change — per crossing, the CPU
  instance encode drops 1510→338µs and the GPU upload 71KB→13KB; a non-rewrapping width change
  re-encodes zero rows.
- **Persistent instance arrays.** (#74) Every frame used to re-flatten all rows' instances into
  freshly allocated arrays (megabytes of copies per frame on large grids, even for a one-row
  keystroke). The renderer now owns persistent flat arrays with a per-row segment table and
  splices only dirty rows in place — clean rows' bytes are never touched, and steady state
  allocates nothing. Scattered damage (a status row plus the cursor row) uploads two row-sized
  spans instead of everything between them.
- **Images no longer disable render caching.** (#75) Any inline image (Sixel / Kitty / iTerm2)
  forced every frame of that pane to re-encode every row; images draw as a separate quad pass,
  so image-bearing panes now keep incremental row reuse — typing next to an image re-encodes
  one row instead of the whole grid.

### Added
- **Per-boundary render instrumentation.** (#72) `TerminalRenderStats` splits encode time into
  CPU instance build vs GPU upload; `HARNESS_FRAME_SIGNPOSTS=1` brackets the grid read and
  frame build on the signpost track; a boundary-crossing benchmark steps a full cell column per
  tick and attributes each crossing's cost per pipeline stage.

## [1.4.0] - 2026-06-04

The control release: experience presets unbundle into per-piece overrides, persistence gets
per-tab pins, and the renderer stops re-uploading the whole screen on every keystroke.

### Added
- **Per-tab persistence pins.** (#71) Right-click a tab → "Keep Tab Running After Quit" — the
  finest-grained keep-on-quit control. A tab survives a clean quit iff the global switch, its
  session's pin, or its own pin is set; unpinned siblings close individually while the pinned
  tab keeps its session alive as a container. The session pin is now always shown in the
  sidebar (with a note when the global switch supersedes it).
- **Decoupled experience-preset controls.** (#71) The presets (Plain / Persistent / Full /
  Agent) now just seed defaults: separate **Command prefix** and **Status line** tri-states
  (Auto / On / Off) replace the single "Harness controls" umbrella, so e.g. a Plain terminal
  can show a status line without arming the prefix. Existing settings keep their exact
  behavior, and switching presets re-syncs the keep-on-quit default without clobbering an
  explicit choice made in Settings.

### Performance
- **Row-incremental GPU instance upload.** (#70) Outside the stable-frame fast path, every
  frame re-uploaded the whole screen's instance arrays to the GPU — one keystroke forced a
  full-screen memcpy. Frames now upload only the changed rows' bytes (per-stream dirty spans,
  reconciled across both in-flight ring slots); scroll and full repaints are unchanged — the
  worst case is identical to the old whole-array upload.

### Fixed
- **Thai and other combining marks render correctly.** (#59, fixes #56) Zero-width marks now
  stack onto their base cell instead of occupying their own.
- **Multi-client sizing actually holds.** (#67) Resize votes ride the persistent subscription
  fd, so the smallest-client rule survives reconnects instead of decaying to the last writer.
- **Daemon/session correctness.** (#69) `joinPane` validates before mutating (no partial
  layouts), client attach/detach hooks always fire in pairs, and dead panes drop their stale
  metadata and keep their exit status.
- **Config/CLI hardening.** (#68) `unbind` now writes a tombstone so a re-`source-file` can't
  resurrect the binding, a corrupt `buffers.json` is backed up instead of silently replaced,
  CLI targets are strictly validated, and `set-environment` global writes land in
  `environment.json`.

## [1.3.2] - 2026-06-04

The delivery release: updates now reach the parts of Harness that live outside the app bundle.
After updating, the first launch restarts the daemon once to pick up the new build — sessions
and scrollback come right back; anything running in a pane restarts.

### Fixed
- **App updates now actually update the daemon and CLI.** (#60) The launchd-supervised
  `HarnessDaemon` and the on-PATH `harness-cli` live under
  `~/Library/Application Support/Harness/bin/` (placed there by onboarding or
  `harness-cli install`), but app updates only replaced the copies inside Harness.app — so
  daemon-side fixes (like the 1.2.0 `TERM_PROGRAM` identity fix, #39) never reached updated
  installs. The app now refreshes the installed copies from the bundle on launch
  (remove-then-copy, so the kernel's per-vnode code-signature cache can't kill the new daemon),
  points the LaunchAgent at the canonical installed copy, and detects a stale running daemon
  through a real version handshake — `daemon-stats` now reports the daemon's version/build —
  instead of a file-timestamp heuristic that any daemon restart defeated. The first launch
  after updating restarts the daemon once to pick up the new build (sessions and scrollback
  replay; running pane processes restart).
- **Daemon/CLI version constants no longer drift.** `TERM_PROGRAM_VERSION` and the XTVERSION
  reply said 1.2.0 on 1.3.x builds because the shared version constant missed the release
  bump; packaging and the release workflow now fail when it disagrees with Info.plist.

### Added
- **`harness-cli version`** prints the CLI's version/build and the running daemon's, and flags
  a mismatch. `harness-cli doctor` gained a "Daemon version" check that warns when the running
  daemon's build differs from the CLI's.

## [1.3.1] - 2026-06-04

The fluidity release: resize-drag and scrolling re-measured on 120Hz hardware and fixed at the
root — drag presents now cost ~1.7ms on the main thread (was ~12ms) and trackpad scrolling is
pixel-smooth.

### Added
- **Pixel-smooth scrolling.** Trackpad scrolling moves by sub-line fractions instead of whole
  cells: the fraction renders as a vertex-stage translate over the unchanged GPU row cache (a
  fraction-only tick re-encodes nothing and uploads nothing), with a real content row revealed
  at the edge. Line-based features (selection, copy mode, find, prompt jumps, mouse reporting)
  keep their exact semantics; clicky mouse wheels keep the classic 3-line notch.
- **Fluidity measurement tooling.** `PREVIEW_SIGNPOSTS=1 make preview` now actually enables the
  frame signposts (`open` strips the environment, so the flag travels as a launch argument), and
  `Scripts/measure-fluidity.sh` drives a real resize drag + scroll fling while reporting present
  p50/p95 breakdowns from the unified log.

### Fixed
- **Resize-drag lag.** Three compounding causes: every drag tick paid a full GPU re-encode
  (the repaint now reuses the row cache — zero rows re-encoded on sub-cell ticks); streaming
  output presented through the synchronized path mid-drag (it now defers to the per-tick
  repaint and flushes at drag end); and the drawable pool of two blocked the next tick behind
  the window server for most of a frame (a third drawable is held for the duration of the drag
  only — keystroke echo latency is untouched). Measured: drag present p50 ~12ms → ~1.7ms,
  zero dropped frames, with the glitchless edge-latch preserved.
- **Scroll-while-busy hitches.** Wheel events no longer wait on the parser's queue for the
  history count; a main-thread mirror keeps the clamp lock-free under heavy output.

## [1.3.0] - 2026-06-04

The smoothness release: window resizing and scrollback scrolling rebuilt at the presentation
layer for Ghostty-class feel, plus a first-run font fix.

### Added
- **Glitchless live resize.** While dragging a window edge, every frame now presents inside
  the same Core Animation transaction as the window's new frame
  (`presentsWithTransaction` + commit → wait-until-scheduled → present), so the terminal
  content stays latched to the edge instead of lagging it by a frame or two.
- **Scroll-delta rendering.** Scrolling through history now rebuilds only the rows the scroll
  exposed: the frame builder shifts the previous frame's surviving rows (~7× faster per
  tick), and the GPU row cache rotates in place — kept rows skip glyph shaping and atlas
  work entirely.
- **Present-pipeline instrumentation.** With `HARNESS_FRAME_SIGNPOSTS=1`, the present
  signpost now logs a rolling p50/p95 breakdown (drawable wait / GPU back-pressure /
  transaction schedule) plus a genuine frame-drop counter.

### Fixed
- **Text shimmer while resizing.** Balanced window padding re-centered the grid on every
  sub-cell layout, shifting the text ±1px per pixel of drag; the origin now anchors for the
  duration of the drag and re-centers once at release.
- **Resize lag after release.** The grid reflow + `SIGWINCH` commit now fires the moment the
  drag ends instead of waiting out the coalescing delay (which still applies to animated
  resizes like sidebar slides).
- **Broken letter-spacing on first run.** On machines without the configured font family
  (e.g. a fresh install without the default Nerd Font), the renderer silently accepted a
  proportional system font whose advances disagree with the cell grid; it now falls back to
  Menlo, keeping text monospace-correct. Nerd icon coverage is unchanged.
- **Stale rows after a dropped frame.** A present that failed transiently (no drawable /
  encode failure) could leave the renderer's row-reuse cache disagreeing with the screen;
  the caches now reset on any drop so the retry re-encodes from frame content.

## [1.2.0] - 2026-06-03

A quality-of-life release aimed at 1:1 parity with the polish of a mainstream GPU terminal:
resize that feels instant, Ghostty-minimal chrome, protocol fills (focus reporting, alternate
scroll, OSC 9;4 progress), and a pre-release audit's worth of bug fixes.

### Added
- **Live re-wrap while resizing.** Dragging the window edge now re-wraps the visible viewport
  every frame (at viewport cost, not history cost) and the full reflow commits when the drag
  settles — with a byte-identical wide-character (CJK/emoji) reflow fix and a height-only
  resize fast path that skips re-wrapping entirely when the width didn't change.
- **Agent working dot (OSC 9;4).** Agents that emit ConEmu progress reports (Claude Code, …)
  drive a working indicator on the tab pill directly from the protocol — same handling as
  Ghostty, including consuming `OSC 9;4` so it never fires as a desktop notification. Agents
  that don't emit it fall back to output-recency detection.
- **Transient scrollbar.** A thumb-only overlay scrollbar appears on the right edge while
  scrolling and fades out once the viewport settles.
- **Draggable title strip.** A slim strip above the tab bar shows the active tab's folder
  icon + basename and gives the window a generous drag target (hidden while an agent owns
  the pane).
- **Window edge hairline.** A faint perimeter line around the window (Ghostty-style), themed
  and configurable (`windowBorderHex` / `windowBorderOpacity` in Settings ▸ Colors).
- **Alternate-screen wheel scrolling (DECSET 1007).** The scroll wheel/trackpad now scrolls
  `less`, `man`, and other full-screen TUIs by synthesizing arrow keys when the program didn't
  enable mouse reporting — on by default, programs can opt out with `CSI ? 1007 l`.
- **Middle-click paste.** Middle click pastes the current selection (the X11/Ghostty primary-
  paste convention), falling back to the clipboard — with bracketed paste and paste protection
  applied exactly like ⌘V.
- **Bold is bright toggle.** Settings ▸ Colors can now disable the classic bold→bright-palette
  mapping (`bold-is-bright` in an imported Ghostty config is honored too).
- **Command-finished threshold control.** The long-running-command notification threshold is
  now editable in Settings ▸ Agents (previously JSON-only).
- **Live resize overlay.** Resizing the window shows the live grid size (e.g. `120 × 32`) and fades
  out once it settles. Configurable in Settings ▸ Appearance (`after-first` / `always` / `never`).
- **Balanced window padding.** The grid is now centered — the leftover sub-cell space is split
  evenly on both sides instead of being parked at the bottom-right edge. Toggle "Center grid" in
  Settings ▸ Appearance.
- **Word, line, and rectangular selection.** Double-click selects a word, triple-click selects a
  line, and Option-drag makes a rectangular (block) selection — using the same word rule as copy
  mode. Copy-on-select copies the expanded selection.
- **Hollow cursor when unfocused.** When the window loses focus the cursor becomes a hollow box
  outline (standard macOS behavior), so it's clear which window is active.
- **Minimum contrast.** An optional WCAG contrast floor lifts dim foreground text to a chosen ratio
  (Settings ▸ Colors, 1 = off). Honored from an imported `minimum-contrast` config value.
- **Automatic light/dark theme.** Pick a light and a dark theme and Harness follows the macOS system
  appearance, switching live (Settings ▸ Appearance ▸ "Auto light/dark").
- **Paste protection.** Pasting text with line breaks or control characters now asks for
  confirmation when the program hasn't enabled bracketed paste — guarding against blind command
  execution. On by default (Settings ▸ Terminal).
- **Long-running command notifications.** Optionally get a desktop notification when a command that
  ran longer than a threshold finishes in an unfocused window (uses OSC 133 shell-integration
  timing; off by default, Settings ▸ Agents).
- **Non-native ("fast") full screen.** A new ⌃⌘⇧F fills the screen without the macOS Spaces
  animation, alongside the existing native ⌃⌘F.
- **Terminal identity (`TERM_PROGRAM`, XTVERSION, secondary DA).** Harness now introduces itself to
  programs: it exports `TERM_PROGRAM`/`TERM_PROGRAM_VERSION` and answers the XTVERSION (`CSI > q`) and
  secondary-DA (`CSI > c`) identity queries. A new Settings ▸ Advanced ▸ "Terminal identity" control
  (also `harness-cli set-option terminal-identity …`) chooses between **Compatible** (default —
  reports a protocol-compatible identity so tools like Claude Code enable the Kitty keyboard protocol
  immediately) and **Harness** (the true name + version).
- **Paste a screenshot.** ⌘V with an image on the clipboard now writes it to a temp PNG and pastes
  the file path (bracketed-paste-wrapped), so agents that accept image-file paths — Claude Code, etc.
  — attach it. Pasting a file copied in Finder works the same way.
- **Agent activity indicators.** Tab pills and the notch HUD show a working dot while an agent
  is busy (driven by OSC 9;4 when the agent emits it, output recency otherwise) — alongside the
  existing red waiting count and sidebar bell. Honors Reduce Motion.

### Changed
- **Ghostty-minimal pane chrome.** Pane borders, waiting rings, and corner badges are removed
  by design — the tab dot (plus the sidebar bell and desktop notifications) is the working /
  attention indicator. Unfocused panes still dim. If you relied on the blue waiting ring,
  watch the tab pill instead.
- **Typing latency.** A measurement pass confirmed keystroke→photon latency is at the local
  floor; input handling gained no extra cost from this release's features.

### Fixed
- **Resize-drag preview cursor.** With the cursor parked well above the bottom of a filled
  viewport, the live re-wrap preview mapped the cursor to the top-left corner for the duration
  of the drag (it snapped back on release). The preview also no longer flashes a cursor that
  the program explicitly hid (DECTCEM).
- **Selected text honors minimum contrast.** With a contrast floor set, selected cells lifted
  their text color against the cell's own background, not the selection highlight actually
  drawn behind them — dim text could turn unreadable while selected.
- **Cursor-text color is honored.** The theme/imported `cursor-text` color (the glyph under a
  block cursor) was accepted by Settings but never reached the renderer, silently drawing the
  canvas background color instead.
- **Working state agrees everywhere.** The notch HUD now consumes the same OSC 9;4 progress
  signal as the tab-pill dot, so the two can't disagree about whether an agent is busy; the
  tab dot's animation now honors Reduce Motion.
- **Settings: toggling auto light/dark no longer drops in-flight edits.** The toggle bypassed
  the normal flush path, losing e.g. a color-well change made just before it.
- **`ESC c` (RIS) abandons command timing.** A full reset no longer lets a later OSC 133;D
  report a spurious "command finished" measured from before the reset. (Plus: XTVERSION replies
  no longer carry a trailing space when no version is set.)
- **Copy-mode scroll state stays in sync.** Entering/leaving copy mode resets the scrollbar
  and the sub-line wheel remainder, so the first wheel tick afterwards isn't swallowed.
- **`respawn-pane` clear-history flags unified.** `harness-cli respawn-pane` accepts `-k`
  alongside `--clear-history`, and the command grammar accepts `--clear-history` alongside
  `-k` — the two layers previously each understood only their own spelling.
- **Focus reporting (DECSET 1004) now actually reports.** The mode was tracked but `CSI I`/
  `CSI O` were never sent on focus changes — vim/tmux autocommands now fire, including when
  the whole window activates or deactivates (which also fixes the hollow-cursor state for
  window-level focus changes).
- **Ghostty `theme = light:Name,dark:Name` imports correctly.** The dual-appearance form was
  stored verbatim, failed the catalog lookup, and silently fell back to the default theme; it
  now maps onto the auto light/dark theme pair.
- **Unterminated escape strings can no longer eat your output.** CAN/SUB now abort an
  in-progress OSC/DCS/APC sequence (VT500 "anywhere" rule); previously an unterminated string
  left the parser consuming everything until the next ESC.
- **Scrollback persistence can no longer truncate itself.** If the scrollback log couldn't be
  opened for append, the fallback rewrote the whole file with just the newest chunk —
  discarding all prior history. The fallback now rewrites existing + new content, and drops
  the write rather than the history when the file can't be read.
- **`respawn-pane` keeps your working directory.** The cwd is probed before the old shell is
  signalled (not after, when the PID is already gone), and a shell that exited on its own
  respawns into the tab's last-known cwd instead of `$HOME`.
- **Command palette covers every tab.** The Tabs section listed only the active session's
  tabs; tabs in other sessions were unreachable. It now lists all sessions' tabs (labelled by
  session) and removes a duplicate "New Session" entry that corrupted the recents list.
- **Command prompt history navigation.** Down from a blank prompt no longer recalls history,
  and Down past the newest entry returns to your in-progress draft (readline behavior).
- **Tab drag survives background reloads.** A metadata refresh landing mid-drag (e.g. an
  agent status update) silently cancelled the reorder; the drag now commits first.
- **Waiting tabs in the overflow menu show a bell, not a checkmark.**
- **Security: OSC 8 hyperlinks no longer open `file://` URLs.** Terminal output (including
  from remote hosts) could plant a ⌘-clickable link to an arbitrary local path —
  NSWorkspace executes `.app`/`.command` targets on open. `http(s)`, `mailto`, `ftp(s)`
  remain allowed.
- **Daemon shutdown no longer truncates in-flight replies.** Pending client responses (e.g. a
  large `capture-pane`) get a bounded drain before the sockets close.
- **`harness-cli` reaps its SSH tunnels.** Tunnel `ssh` processes and forwarded sockets in
  `runtime/tunnels/` are cleaned up on process exit instead of lingering.
- **Shift+Enter inserts a newline in Claude Code (#39).** Claude Code only enables native Shift+Enter
  once it recognizes the terminal; Harness previously advertised no identity, so the Kitty keyboard
  protocol stayed off and Shift+Enter submitted. Harness now reports a compatible identity by default
  (see "Terminal identity" above), so Shift+Enter works out of the box.
- **Onboarding is readable in light mode.** The onboarding window is now pinned to a fixed dark
  appearance, so its light text/logo no longer rendered invisibly on a light glass panel on
  light-mode Macs. The install screen's Daemon row now reports "Found HarnessDaemon" instead of
  duplicating the CLI's "Found harness-cli".
- **Nerd Font / Powerline glyphs render correctly (#37).** Prompt icons and Powerline separators
  rendered as "tofu" boxes (□) when the configured font wasn't a Nerd Font or its name didn't
  resolve cleanly. Harness now bundles a symbols-only Nerd Font as a guaranteed fallback for icon
  codepoints and resolves the configured font more robustly, so shell prompts (Starship,
  Powerlevel10k, …) render their symbols regardless of the primary font.

## [1.1.2] - 2026-06-02

### Added
- **Finder "New Harness Tab/Window Here."** Right-clicking a folder in Finder now offers
  "New Harness Tab Here" and "New Harness Window Here" (via `NSServices`), opening a Harness
  terminal rooted at that folder — the system "open terminal here" workflow, at parity with
  other terminals.
- **Full Kitty keyboard protocol.** The terminal now implements the complete progressive-
  enhancement protocol — event types (press/repeat/release), alternate keys, report-all-keys,
  and associated text — so modern TUIs (Neovim, Helix, …) get unambiguous key reporting.
  Functional, lock, and modifier keys report their Kitty codepoints; F13–F20 are supported.
  Legacy output is byte-identical until a program opts in.

### Fixed
- **Shift+Tab (back-tab) now reaches the PTY.** macOS delivers Shift+Tab as `NSBackTabCharacter`
  (0x19), which was dropped before encoding — it now correctly emits `ESC[Z` (and the Kitty
  form when enabled), so back-tab navigation in full-screen TUIs works.
- **Smooth window resize during heavy output.** Resizing while text streamed was jumpy because
  each drag frame rebuilt the terminal frame synchronously behind the output parser. The drag
  now re-presents the cached frame without touching the parser queue; the grid reflows once when
  the drag settles — matching the smoothness of other GPU terminals.

### Changed
- **"Set as default terminal" now claims the full terminal type set.** Beyond
  `ssh`/`telnet`/`x-man-page` links and `.command`/`.tool` files, Harness now registers for
  `public.unix-executable` and shell scripts (`.sh`/`.zsh`/`.csh`/`.pl`, `public.shell-script`),
  and the script/command claim is promoted from Alternate to Default rank — so scripts and
  executables open in Harness instead of falling through to another terminal.

## [1.1.1] - 2026-06-02

### Fixed
- **Crash when setting Harness as the default terminal.** Clicking "Set Harness
  as default terminal" in Settings ▸ Terminal crashed immediately
  (`EXC_BREAKPOINT`). `NSWorkspace` invokes its `setDefaultApplication`
  completion handlers on a background queue, but the handlers had inherited
  `@MainActor` isolation from the enclosing type, so Swift 6's executor-isolation
  check trapped on entry. The completion closures are now `@Sendable`
  (non-isolated); the `NSWorkspace` call itself still runs on the main actor.

## [1.1.0] - 2026-06-02

### Added
- **Remote & headless daemon.** Run `HarnessDaemon` on a headless or remote box and
  drive it from the CLI with a global `--host <name>` flag, tunnelled over your existing
  SSH trust — no new crypto. Register hosts with
  `harness-cli remote add --name <name> --ssh <user@host> --socket <remote-path>`, and
  list/remove them with `harness-cli remote list` / `harness-cli remote remove`. Every
  client command (`ping`, `new-session`, `send-keys`, `capture-pane`, `doctor`, …) accepts
  `--host`. The daemon and `harness-cli` now build and run on **Linux** (headless), in
  addition to the macOS app.
- **Persistent scrollback.** A pane's scrollback is persisted to disk per surface and
  restored when the daemon restarts, so history survives a daemon restart or crash.
  `respawn-pane --clear-history` drops the persisted history.

### Changed
- **Settings overhaul.** A native, themed Settings window with grouped sections
  (Appearance · Colors · Terminal · Keys · Agents · Advanced) and more customization;
  the placeholder preview was replaced with a theme-true live pane.
- **Agent tooling.** Agent hooks and setup prompts, with a one-click "Install hooks"
  button per agent in Settings ▸ Agents.
- **Window memory & terminal UX.** Window position/size is remembered across launches,
  plus assorted terminal UX improvements.
- **Faster VT engine.** The VT parse hot path is 1.5–1.66× faster on unicode/throughput
  workloads, with byte-identical output.

### Fixed
- **Daemon launch reliability.** Release startup now installs/bootstraps the launchd
  LaunchAgent first, so `HarnessDaemon` is launchd-supervised from the start. This
  eliminates an "another HarnessDaemon is already running" retry loop; a directly-spawned
  child is used only when launchd can't bring one up. Verified on a clean macOS VM
  (launchd-parented, `runs = 1`, no retry loop).
- **IME composition.** The input method now owns keys while a composition is active, so
  dead keys and multi-stroke input commit correctly.
- **Xcode/package wiring.** The first-party `CHarnessSys` C shim is exposed as an SwiftPM
  product so xcodegen-generated Xcode builds match the SwiftPM build.

## [1.0.6] - 2026-06-02

### Added
- Agent Notch HUD for at-a-glance agent activity.

### Changed
- Daemon read-path performance improvements.

## [1.0.5] - 2026-06-01

### Fixed
- Theme fidelity fix plus a batch of reliability and security-audit fixes.

## [1.0.0] - [1.0.4] - 2026-06-01

Initial public releases of Harness: a native macOS terminal with its own GPU
rendering engine, daemon-owned sessions/tabs/splits, `harness-cli` automation, the
`attach-window` compositor, agent detection and notifications, 490 built-in themes,
and a signed/notarized DMG with Sparkle auto-update. See the
[GitHub Releases](https://github.com/robzilla1738/harness-terminal/releases) for the
per-patch detail.

[1.5.1]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.5.1
[1.5.0]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.5.0
[1.4.1]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.4.1
[1.4.0]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.4.0
[1.3.2]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.3.2
[1.3.1]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.3.1
[1.3.0]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.3.0
[1.2.0]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.2.0
[1.1.2]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.1.2
[1.1.1]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.1.1
[1.1.0]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.1.0
[1.0.6]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.0.6
[1.0.5]: https://github.com/robzilla1738/harness-terminal/releases/tag/v1.0.5
