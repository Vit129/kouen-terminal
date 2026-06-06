# Memory — Harness Terminal

## Active Context
- **Project:** harness-terminal (Swift/AppKit macOS terminal emulator)
- **Fork:** Vit129/harness-terminal (fork of robzilla1738/harness-terminal)
- **Working branch:** `worktree-feature+acp-aidlc` in `.claude/worktrees/feature+acp-aidlc/`
- **Preview:** `cd /tmp/hp && make preview` (symlink to avoid socket path length limit)

## Current Sprint — IDE-like Sidebar (PBI-001)
✅ Files tab: root follows active session cwd  
✅ + button: opens NSOpenPanel → new session at selected folder  
✅ Recent projects button (clock icon): dropdown of last 10 cwds, switch to existing session if duplicate  
✅ Git tab: Zed-style layout (Changes/History tabs, branch switcher, Fetch▾ dropdown, working stage/unstage checkboxes)

## Known Issues
None

## Architecture Notes
- Sidebar: `HarnessSidebarPanelViewController` — tabs (Sessions/Files/Git) via NSSegmentedControl
- File tree: `WorkspaceFileTreeView` — NSOutlineView with `FileTreeWatcher`
- Git panel: `GitPanelView` — custom NSView with scroll views for changes/history
- Sessions: `SessionCoordinator.shared` manages daemon IPC, snapshot notifications via `NotificationBus.shared.snapshotChanged`
- Preview uses `.harness-preview/` — socket path max 103 bytes (use `/tmp/hp` symlink for worktree)
