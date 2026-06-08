# Memory — Harness Terminal

## Active Context
- **Project:** harness-terminal (Swift/AppKit macOS terminal emulator)
- **Fork:** Vit129/harness-terminal (fork of robzilla1738/harness-terminal)
- **Working branch:** `main`
- **Preview:** `make preview` (uses `.harness-preview/` dir)
- **Latest release:** v2.1.0

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
| 9 | CWD tracking fix (shell integration) | 🔴 Blocked |

### Recent_Lessons

- **RL-001:** ACP requires adapter binaries; can't ship reliably in .app bundle (PATH issues)
- **RL-002:** Shell tracker can't see daemon children properly without shell integration installed
- **RL-003:** sortOrder must persist to UserDefaults on every drag, not just on quit

### Decisions_In_Force

- **ACP shelved** — re-enable when adapters ship with agent CLIs natively
- **Agent tab hidden** — 4th sidebar segment commented out, code preserved
- **CWD tracking deferred** — needs shell integration (OSC 7) installed by user

## Known Issues
- **Split right 4+ panes slightly uneven** — NSSplitView default resize compresses middle panes. Tolerable.
- **CWD tracking not working** — shell integration not installed; SurfaceShellTracker can't see daemon children properly.

## Completed Sprints
- **v1.3.0** — IDE-like Sidebar (PBI-001): Files tab, Git tab, session tabs, recent projects
- **v1.4.0** — Git panel: Commit ▼ menu, Sync button with per-remote options
- **v1.5.0** — CMUX split panes, N-ary flatten, host reuse, split down removed
- **v2.0.0** — File preview, sidebar polish, agent icon art
- **v2.1.0** — ACP Client, real-time Git, history→file editor

## Architecture Notes
- Sidebar: `HarnessSidebarPanelViewController` — tabs (Sessions/Files/Git) via NSSegmentedControl (Agent tab hidden)
- Sidebar position: `MainSplitViewController.updateSidebarPlacement()` — reorders NSSplitView subviews
- File tree: `WorkspaceFileTreeView` — NSOutlineView with `FileTreeWatcher`
- Git panel: `GitPanelView` — changes/history/worktrees; DispatchSource watcher on .git
- Split panes: `PaneContainerView` builds from `PaneNode` binary tree; `HarnessSplitView` per branch node
- Sessions: `SessionCoordinator.shared` — async IPC, snapshot notifications via `NotificationBus.shared.snapshotChanged`
- ACP Client: SHELVED — code intact (`ACPClient`, `ACPSession`, `AgentChatPanelView`, `AgentConfig`)
- Preview uses `.harness-preview/` — socket path max 103 bytes (use `/tmp/hp` symlink for worktree)
- SoftIconButton: supports `rightMouseDown` → pops up assigned `.menu`
