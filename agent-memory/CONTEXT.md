# Context — harness-terminal

## Now
- **Task:** None active — ready for next session
- **Branch:** main
- **Latest release:** v3.5.0
- **Status:** idle

## Open Questions
- [open] 3 remaining crashes on 2026-06-17: 2× layout()+assumeIsolated, 1× keyDown — likely zombie-view (same mechanism as resetCursorRects, 0xa3 free-fill). Root path not yet identified.
- [open] RL-043: Per-session-tab focus not restored on cmd+1/2/3 or cmd+shift+[/] switch. Partial fix in `SessionLifecycleService` + `MainExecutor` (nil activeSurfaceID before sync) — compiles but not verified working. Deep investigation in `knowledge/focus-persistence.md`.

## Key Files
- `HarnessApp/UI/FileTree/WorkspaceFileTreeView.swift` — file tree context + reveal logic
- `HarnessApp/UI/Sidebar/HarnessSidebarPanelViewController.swift` — sidebar tab switching
- `HarnessApp/UI/Chrome/MainSplitViewController.swift` — cmd+click handler, sidebar visibility

## Session Notes
- Build: `make preview` (uses `.harness-preview/` dir)
- Never reparent Metal terminal surfaces — causes black screen (RL-004)
- Read `knowledge/background-polling.md` before touching DaemonSyncService
