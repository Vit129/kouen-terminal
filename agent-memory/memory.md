# Memory — Harness Terminal

## Active Context
- **Project:** harness-terminal (Swift/AppKit macOS terminal emulator)
- **Fork:** Vit129/harness-terminal (fork of robzilla1738/harness-terminal)
- **Working branch:** `main`
- **Preview:** `make preview` (uses `.harness-preview/` dir)
- **Latest release:** v2.1.0

## Current Sprint — ACP Client & Git Polish (post-v2.0.0)
✅ ACP Client actor (JSON-RPC 2.0 over stdio) — initialize, session/new, session/prompt  
✅ ACPSession model — observable conversation state, streaming, tool calls, permissions  
✅ AgentChatPanelView — AppKit chat UI in sidebar (4th tab "Agent")  
✅ Agent tool call approvals — Allow/Reject bar for file edits + command execution  
✅ Settings UI — "ACP Agents (Chat)" section: add/remove/toggle agent configs  
✅ Git real-time refresh — DispatchSource watcher on `.git` with 500ms debounce  
✅ History file click → opens in file editor panel (Zed-like)  
✅ Changes tab double-click → opens file in editor panel  
✅ P2-async implementation in DaemonClientActor, DaemonSessionService, and SessionCoordinator (non-blocking background Task for IPC)  
✅ Separation of Prod/Debug and Preview session states (com.robert.harness bundle filter in HarnessPaths)  

## Known Issues
- **Split right 4+ panes slightly uneven** — NSSplitView default resize algorithm compresses middle panes on window resize. Tolerable for now.
- **ACP: no diff viewer for permission requests** — file edit approvals show text only, no side-by-side diff yet.

## Completed Sprints
- **v1.3.0** — IDE-like Sidebar (PBI-001): Files tab, Git tab, session tabs, recent projects
- **v1.4.0** — Git panel: Commit ▼ menu, Sync button with per-remote options
- **v1.5.0** — CMUX split panes, N-ary flatten, host reuse, split down removed
- **v2.0.0** — File preview, sidebar polish, agent icon art
- **v2.1.0** — ACP Client, real-time Git, history→file editor

## Architecture Notes
- Sidebar: `HarnessSidebarPanelViewController` — tabs (Sessions/Files/Git/Agent) via NSSegmentedControl
- Sidebar position: `MainSplitViewController.updateSidebarPlacement()` — reorders NSSplitView subviews
- File tree: `WorkspaceFileTreeView` — NSOutlineView with `FileTreeWatcher`
- Git panel: `GitPanelView` — custom NSView with scroll views for changes/history; DispatchSource watcher on .git
- Split panes: `PaneContainerView` builds from `PaneNode` binary tree; `HarnessSplitView` (NSSplitView subclass) per branch node
- Split buttons: `PaneSplitButtonsView` — overlay at top-right with zPosition 1000
- Sessions: `SessionCoordinator.shared` manages daemon IPC, snapshot notifications via `NotificationBus.shared.snapshotChanged`
- ACP Client: `ACPClient` actor (HarnessCore) → `ACPSession` model → `AgentChatPanelView` (AppKit)
- ACP lifecycle: initialize → session/new → session/prompt; agent sends session/update notifications
- Agent requests handled: fs/read_text_file, fs/write_text_file, session/request_permission, terminal/create
- Preview uses `.harness-preview/` — socket path max 103 bytes (use `/tmp/hp` symlink for worktree)
- SoftIconButton: supports `rightMouseDown` → pops up assigned `.menu`
