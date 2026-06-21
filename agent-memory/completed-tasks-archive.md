# Task Ledger Archive (Tasks 1–50)

Archived from agent-memory/memory.md. Active tasks in [memory.md](memory.md).

| # | Task | Status |
|---|------|--------|
| 1 | ACP Client shelved (adapters not ready) | ✅ Done |
| 2 | Session ID shown in sidebar cards | ✅ Done |
| 3 | Tab reorder fix (sortOrder persistence) | ✅ Done |
| 4 | Session grouping by CWD (adjacent insert) | ✅ Done |
| 5 | Agent sidebar tab hidden | ✅ Done |
| 6 | SurfaceShellTracker (daemon process tree scan) | ✅ Done |
| 7 | GitPanelView: Worktrees tab | ✅ Done |
| 8 | P2-async IPC (DaemonClientActor, SessionCoordinator) | ✅ Done |
| 9 | CWD tracking via daemon proc_pidinfo polling | ✅ Done |
| 10 | Git History diff coloring + file navigation | ✅ Done |
| 11 | macOS 26 Swift 6 crash fixes (MainActor isolation) | ✅ Done |
| 12 | File tree performance (remove polling, reconcile in-place) | ✅ Done |
| 13 | Preview/production session isolation | ✅ Done |
| 14 | File preview: no-reparent constraint split (40/60) | ✅ Done |
| 15 | File preview: brighter syntax colors + chrome bg | ✅ Done |
| 16 | Sidebar session card: icon scans all tabs + title always tracks live folder (matches tab bar) | ✅ Done |
| 17 | P6 — File editor opacity parity with terminal (compensated refreshEditorPanelFill) | ✅ Done |
| 18 | File tree FSEvents recursive watcher (CASE-016) | ✅ Done |
| 19 | Folder expand state persist in @Observable model (CASE-017) | ✅ Done |
| 20 | File preview drag-to-select text (CASE-018) | ✅ Done |
| 21 | Terminal selection highlight visible (CASE-019) | ✅ Done |
| 22 | Branch chip real-time via git rev-parse in loadRoot() (CASE-020) | ✅ Done |
| 23 | Git Changes FSEvents recursive watcher on rootPath (CASE-021) | ✅ Done |
| 24 | File preview live reload via single-file DispatchSource watcher (CASE-022) | ✅ Done |
| 25 | Sidebar collapse-then-expand fix: sync sidebarVisible on forced launch collapse (CASE-024) | ✅ Done |
| 26 | Terminal rendering corruption fix: don't clear synchronizedOutput on shell-prompt reset (CASE-023) | ✅ Done |
| 27 | v2.2.4 release prep: CHANGELOG Fixed entries, version bump (build 125), release notes regen, graphify refresh, tag | ✅ Done |
| 28 | P9 complexity reduction: extract LiveResizeGeometry, PasteController, SelectionResolver from SurfaceView; document GridCompositor duplication; plan macOS 27 adoption (P8) | ✅ Done |
| 29 | Terminal blink fix when file preview split opens/closes (CASE-025) | ✅ Done |
| 30 | P10 features: Local Completion, IDE Mode (⌘+⇧+D), Session State Dot, diff coloring, git panel improvements, IDE mode persistence | ✅ Done |
| 31 | CASE-026 black terminal on new session — display link race fix | ✅ Done |
| 32 | Lazy scrollback reflow (skip O(history) during live resize), Task Board sidebar, Focus Mode (⌘P) | ✅ Done |
| 30 | P10 implementation: Sidebar session state dots, Toggle IDE Mode shortcut (⌘⇧D), and Workspace Symbol Index autocomplete completions popup | ✅ Done |
| 33 | Implement Ctrl+R-style fuzzy command-history search overlay | ✅ Done |
| 34 | Fix Focus Mode (⌘P) out-of-sync sidebar state when manual visibility toggles occur | ✅ Done |
| 35 | Terminal power-user sprint: vi mode (ViNormalMode.swift), tmux parity (clear-history, word-separators, wrap-search, resize-window, list-* -F/--json, window-size, destroy-unattached, show-prompt-history, find-window -C from hooks), LSP activation, ⌘1-9 session switch, zoxide in Switch Project | ✅ Done |
| 36 | Keyboard file tree navigation (j/k/h/l/Enter, FileTreeKeyboardNav.swift) | ✅ Done |
| 37 | Vi ex command mode (:w/:q/:wq/:set/:e/:bn/:bp/:ls), jump list (Ctrl+o/i), backtick marks, named registers, macros, inline * search, relative numbers | ✅ Done |
| 38 | tmux deferred list closed: window-size option (smallest/largest/latest), list-* --json, find-window -C from hooks, destroy-unattached | ✅ Done |
| 39 | ⌘1–9 session switch: fix selectSessionNumber calling selectWorkspace(byIndex:) instead of selectSession | ✅ Done |
| 40 | Per-theme-mode background opacity (lightThemeOpacity/darkThemeOpacity in HarnessSettings + Settings UI sliders) | ✅ Done |
| 41 | Translucent window legibility: use terminalBackground.withAlphaComponent(opacity) instead of .clear (CASE-027) | ✅ Done |
| 42 | Code review + bug fixes: async syncFromDaemon missing terminalHosts.prune(), ViNormalMode force-unwrap crash on surrogate unichars, selectSessionNumber rename to selectWorkspaceNumber | ✅ Done |
| 43 | fzf install + shell integration (brew install fzf + source <(fzf --zsh) in ~/.zshrc) | ✅ Done |
| 44 | CASE-028: ⌘1-9 verified/kept as Switch to Session N (selectWorkspaceNumber→selectSession); added ⌘[/⌘] = Previous/Next Session (selectAdjacentSession); removed dead selectTabNumber/selectTab(atIndex:)/selectAdjacentTab; menu cleanup (removed New Tab, Layout presets, native fullscreen; Toggle Focus Mode → Show Git Panel ⌘G); fixed make preview socket path | ✅ Done |
| 45 | Notification dropdown keyboard nav (arrow/Enter/Escape + first-responder restore); tab bar close-button vs ⌘N badge overlap at rest fix | ✅ Done |
| 46 | CASE-029: terminal text selection survives scroll — selectionAnchor/Head now virtual-line coords (matches CopyModeGridSource convention); removed clearSelection() on scroll; copy reads via TerminalEmulator.line(_:) | ✅ Done |
| 47 | Rework file-tree sidebar search with Spotlight-style relevance ranking, fuzzy fallback, suffix matching, robust path value checking, search safety checks, and fix git status update/blinking issues | ✅ Done |
| 48 | AI-Agent Notification Rings (TerminalHostView.isWaiting + syncWaitingRings) and ⌘⇧U notifications dropdown wiring | ✅ Done |
| 49 | Quick Select Mode (⌘⇧Y) removed at user's request — didn't work, all related code deleted (HarnessTerminalSurfaceView+QuickSelect.swift, +Input.swift hook, TerminalHostView.enterQuickSelectMode, MainMenuBuilder menu item) | ✅ Done |
| 50 | Fix git history card click not opening file preview (GitPanelView: replaced dead NSClickGestureRecognizer with HistoryCardView.onTap closure) | ✅ Done |
| 51 | P26 — Agent Connection: MCP wiring (harness-mcp existing) + ⌘I inline AI chat (Path B, PR #28). ACP remains shelved. | ✅ Done |
| 52 | P27 — Pane Drag-and-Drop: grip icon in pane hover buttons, PaneDragController state machine, PaneDropZoneOverlay (L/R/T/B/Center zones), joinPane `before` param, SplitPaneCoordinator wrappers | ✅ Done |
| 53 | Fix tab bar wrong branch display when agent uses worktree (probe worktreePath instead of cwd) | ✅ Done |
| 54 | Fix split pane inherits worktree path (not repo root) for new shell CWD | ✅ Done |
| 55 | Wire missing command prompt verbs: :z, :view, :edit, :e, :split, :vsplit, :agent, :fzf, :zi, :rg, :fd, :bat, :eza, :jq (RL-044, CASE-042) | ✅ Done |
