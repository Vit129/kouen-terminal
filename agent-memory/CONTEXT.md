# Context — harness-terminal

## Now
- **Task:** None active — ready for next session
- **Branch:** main
- **Latest release:** v3.2.3 (build 147)
- **Status:** idle

## Open Questions
- (none)

## Key Files
- `HarnessApp/UI/FileTree/WorkspaceFileTreeView.swift` — file tree context + reveal logic
- `HarnessApp/UI/Sidebar/HarnessSidebarPanelViewController.swift` — sidebar tab switching
- `HarnessApp/UI/Chrome/MainSplitViewController.swift` — cmd+click handler, sidebar visibility

## Session Notes
- Build: `make preview` (uses `.harness-preview/` dir)
- Never reparent Metal terminal surfaces — causes black screen (RL-004)
- Read `knowledge/background-polling.md` before touching DaemonSyncService
