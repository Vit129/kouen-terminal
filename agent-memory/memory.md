# Memory — Harness Terminal

## Active Context
- **Project:** harness-terminal (Swift/AppKit macOS terminal emulator)
- **Fork:** Vit129/harness-terminal (fork of robzilla1738/harness-terminal)
- **Working branch:** `main`
- **Preview:** `make preview` (uses `.harness-preview/` dir)
- **Latest release:** v2.2.4

## Current Sprint — Post-v2.1.0 Polish & Shelving

### Task_Ledger

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

### Recent_Lessons

- **RL-001:** ACP requires adapter binaries; can't ship reliably in .app bundle (PATH issues)
- **RL-002:** Shell tracker can't read env vars from /bin/zsh (macOS hardened runtime blocks KERN_PROCARGS2). CWD tracking relies on daemon-side proc_pidinfo polling only.
- **RL-003:** sortOrder must persist to UserDefaults on every drag, not just on quit
- **RL-004:** Never reparent Metal terminal surfaces for file preview split — causes 1-2s black screen (CASE-003). Use constraint-based sibling panel instead.
- **RL-005:** DispatchSource on .main queue directly (not .global with async hop) for Swift 6 MainActor isolation.
- **RL-006:** AppKit panels alongside Metal surfaces must apply opacity explicitly to their CALayer, but file editor/preview panels need a denser compensated alpha (`opacity + (1 - opacity) * 0.55`) rather than raw opacity. Metal handles terminal canvas alpha and terminal programs may paint opaque cell backgrounds, while preview text sits over mostly transparent AppKit canvas; raw parity can look too transparent. Hook into `applyChrome()` + panel-creation site. (CASE-011)
- **RL-007:** DispatchSource.makeFileSystemObjectSource on a directory is non-recursive — only detects root-level changes. Use FSEventStreamCreate with kFSEventStreamCreateFlagFileEvents for recursive watching. (CASE-016, CASE-021)
- **RL-008:** Swift actor + FSEvents C callback: use WatcherContext class (@unchecked Sendable) + Unmanaged.passRetained to pass onChange closure via FSEventStreamContext.info. Release in stopWatching via Unmanaged.fromOpaque().release(). (CASE-016)
- **RL-009:** SwiftUI @State in list rows resets on every view reconciliation. State that must survive tree refresh belongs in the @Observable model, not the View. (CASE-017)
- **RL-010:** NSView wrapping NSTextView must forward mouseDown/mouseDragged/mouseUp to the inner textView explicitly — super.mouseDown doesn't cascade to child views. (CASE-018)
- **RL-011:** For watching a single file (not a directory), plain `DispatchSource.makeFileSystemObjectSource(O_EVTONLY)` is sufficient — no need for FSEvents recursion (RL-007 only applies to directories). Re-arm by reopening the path on every reload to survive atomic-save-by-rename. For a reused `QLPreviewView`, call `refreshPreviewItem()` instead of re-setting an unchanged `previewItem` (QuickLook caches by URL). (CASE-022)
- **RL-012:** When a forced visual state on launch (e.g. collapse) diverges from the persisted toggle-state field, sync the persisted field too — otherwise the first user toggle computes against stale state and is a no-op. (CASE-024)
- **RL-013:** `TerminalModes.resetForShellPrompt()` (OSC 133;D) must only reset *input* modes (mouse tracking, bracketed paste, kitty keyboard, etc.), never `synchronizedOutput` — a sub-command's 133;D can fire mid-batch inside an outer TUI's `?2026h`/`?2026l` redraw, and clearing it there causes the renderer to present a half-applied frame (interleaved garbled rows). The 150ms sync-timeout in `HarnessTerminalSurfaceView` already handles a program that never sends `?2026l`. (CASE-023)

### Decisions_In_Force

- **ACP shelved** — re-enable when adapters ship with agent CLIs natively
- **Agent tab hidden** — 4th sidebar segment commented out, code preserved
- **CWD tracking** — daemon polls proc_pidinfo every 500ms (lightweight); no shell integration needed
- **File preview** — constraint-based sibling panel (never reparent terminal views)

## Known Issues
- **Split right 4+ panes slightly uneven** — NSSplitView default resize compresses middle panes. Tolerable.
- **CWD detection latency** — up to 500ms after `cd` for sidebar to update (daemon poll interval). Acceptable.

## Completed Sprints
- **v1.3.0** — IDE-like Sidebar (PBI-001): Files tab, Git tab, session tabs, recent projects
- **v1.4.0** — Git panel: Commit ▼ menu, Sync button with per-remote options
- **v1.5.0** — CMUX split panes, N-ary flatten, host reuse, split down removed
- **v2.0.0** — File preview, sidebar polish, agent icon art
- **v2.1.0** — ACP Client, real-time Git, history→file editor

## Architecture Notes
- Sidebar: `HarnessSidebarPanelViewController` — tabs (Sessions/Files/Git) via NSSegmentedControl (Agent tab hidden)
- Sidebar position: `MainSplitViewController.updateSidebarPlacement()` — reorders NSSplitView subviews
- File tree: `WorkspaceFileTreeView` → `FileTreeSwiftUIView` (SwiftUI) with `FileTreeWatcher` (FSEvents)
- Git panel: `GitPanelView` — changes/history/worktrees; FSEvents recursive watcher on rootPath (utility queue, 500ms debounce)
- Split panes: `PaneContainerView` builds from `PaneNode` binary tree; `HarnessSplitView` per branch node
- Sessions: `SessionCoordinator.shared` — async IPC, snapshot notifications via `NotificationBus.shared.snapshotChanged`
- File preview: `ContentAreaViewController.showFileEditorSplit()` — constraint-based sibling panel (40% editor / 60% terminal), never reparents terminal views; `refreshEditorPanelFill()` uses compensated opacity so editor preview visually matches terminal density
- File preview live reload: `FileChangeWatcher` (Services/FileExplorer) — single-file DispatchSource, 0.3s debounce, used by `FileEditorView` and `FileViewerViewController` to reload on external edits
- CWD tracking: `AgentScanner.cwdTimer` (500ms) → `SurfaceRegistry.refreshCwdOnly()` (proc_pidinfo) → `snapshotChanged` → sidebar reload
- ACP Client: SHELVED — code intact (`ACPClient`, `ACPSession`, `AgentChatPanelView`, `AgentConfig`)
- Preview uses `.harness-preview/` — socket path max 103 bytes (use `/tmp/hp` symlink for worktree)
- SoftIconButton: supports `rightMouseDown` → pops up assigned `.menu`
