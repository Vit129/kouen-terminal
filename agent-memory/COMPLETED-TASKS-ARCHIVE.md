# Task Ledger Archive (Tasks 1–50)

Archived from agent-memory/MEMORY.md. Active tasks in [MEMORY.md](MEMORY.md).

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
| 56 | Claude Code statusLine/advisor/remote-control "broke after migrate" — NOT Harness, `~/.claude/settings.json` had invalid `skillOverrides.deep-research:"disabled"`, CC 2.1.195 skips whole file on one bad value (CASE-057) | ✅ Done |
| 57 | Live perf profile of running Harness 3.11.7/183 — CPU 42% from SwiftUI `.repeatForever` re-rendering whole ViewGraph; moved `workingDot`/`NotchStatusDot` pulses to CALayer `CABasicAnimation` | ✅ Done |
| 58 | Cmd+\ sidebar toggle gone after collapse — dead CADisplayLink token guard + zero-delta early exit race; move invalidate() before early-return paths (CASE-058) | ✅ Done |
| 59 | P23 SSH socket auto-detect (PBI-SSH-008) — `harness-cli socket-path` + `SSHTunnelManager.detectSocketPath`, wired into Settings UI + CLI `--detect` | ✅ Done |
| 60 | P32 Phase 1 — New Agent Task command palette flow: command palette clipped fix (`setContentSize`), silent `addAgentTask` failures now surface via NSAlert, `.harness-worktrees/` gitignored | ✅ Done |
| 61 | P32 Phase 2 — worktree tabs invisible to git UI: `gitRoot(for:)` walked past worktree's own `.git` to main repo root for directory inputs; swapped to `WorktreeManager().repoRoot(for:)` at 3 call sites; Git panel paint-before-autostage for instant Changes display | ✅ Done |
| 62 | Sidebar default width 264→220, always-open on launch, divider color unified with pane-split divider; root cause of "still huge after resize" was NSSplitView proportional redistribution on window resize — fixed via `shouldAdjustSizeOfSubview` (holdingPriority has no effect with a classic constrain-coordinate delegate) | ✅ Done |
| 63 | ACP-removal test cleanup — `ACPTransportTests.swift` deleted (no live equivalent), `StdioTransportTests.swift` repaired to use `JSONRPCMessage`; stale robot assertion for deleted `aiChatControllers` removed | ✅ Done |

## Pruned from MEMORY.md — 2026-07-02
- [2026-06-25] OSC 7735 = Harness custom sequence for CLI→app file open. Pattern reusable for any future CLI-triggered app action: emit OSC when HARNESS_SURFACE_ID set → TerminalEmulator callback → SurfaceView → TerminalHostDelegate → SessionCoordinator → MainExecutor.shared.
- [2026-06-24] Hint mode armed monitor MUST have mouse-dismiss + auto-timeout — same bug class as PrefixKeymap. Pattern: `matching: [.keyDown, .leftMouseDown, .rightMouseDown]` + `asyncAfter(3s)`.
- [2026-06-24] Vi mode at emulator layer = wrong layer. Shell (`set -o vi`) handles input editing; CopyMode handles buffer nav. Don't build terminal-level vi input mode.
- [2026-06-24] Otty autocomplete (Fig spec DB + history ghost text) too large to replicate. InlineAICompletionController (Option+Space) covers AI suggestions. Shell plugins cover history.
- [2026-06-24] `presentsWithTransaction` must be set BEFORE `drawableSize` changes in `layout()`. `viewWillMove(toWindow:nil)` resets the flag — external `setPresentsWithTransaction(true)` calls don't survive `removeFromSuperview()`.
- [2026-06-23] `NSSplitView.adjustSubviews()` in sidebar toggle path causes terminal blink — NEVER use it in paths containing Metal surfaces. Use `setSidebarWidth() + split.layout()` only. (RL-058)
- [2026-06-23] `PaneLifecycleManager` fast path: must guard with `cached !== paneContainer` to prevent skipping rebuild on in-place structural changes (e.g. adding browser pane). (RL-057)
## 2026-06-25 — OSC 7735:  opens sidebar file viewer
- New CLI→app channel via custom OSC sequence (7735). Pattern: emit OSC from CLI when HARNESS_SURFACE_ID set → TerminalEmulator callback → SurfaceView → TerminalHostDelegate → SessionCoordinator → MainExecutor.shared. Reuse this pattern for any future CLI-triggered app-layer actions.

