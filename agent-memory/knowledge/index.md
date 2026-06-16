# Knowledge Index — Harness Terminal

## Files

| File | Domain | Tags | Score A/P | Summary |
|------|--------|------|-----------|---------|
| appkit-metal.md | AppKit/Metal | CADisplayLink, zPosition, overlay, lifecycle, opacity, layer, preview, transparency, tint, legibility, liquid-glass | 4/0 | Metal surface lifecycle, overlay compositing, compensated NSView preview opacity parity, and window background tint for translucent legibility (CASE-027) |
| ipc-architecture.md | IPC/Daemon | socket, codec, binary-frame, security | 1/0 | Unix socket IPC design: framing, hot-path binary frames, security model |
| split-panes.md | AppKit/UI | NSSplitView, ratio, recursion, reorder, two-axis, split-down, adjustRatio | 4/0 | Split pane management: ratio persistence, infinite-recursion guards, subview reorder, two-axis (Split Right/Split Down) parity (P13) |
| acp-client.md | ACP/Agent | JSON-RPC, stdio, shelved, adapter | 0/0 | ACP protocol integration — shelved due to adapter ecosystem immaturity |
| git-panel.md | AppKit/Git | DispatchSource, worktrees, real-time | 1/0 | Git panel with real-time refresh, history click→editor, worktree support |
| project-history.md | Meta | sprints, releases, architecture | 0/0 | Sprint timeline and architecture decisions from v1.3→v3.0.0 |
| session-tab-hierarchy.md | AppKit/UI | session, tab, pane, top-bar, keybinding, ⌘1-9, ⌘[, ⌘] | 1/0 | Workspace/Session/Tab/Pane hierarchy; top bar = 1 pill per Session, not per-Tab; ⌘1-9 and ⌘[/⌘] both target Session level, Tab-level shortcuts removed |
| agent-session-board.md | AppKit/UI | BoardModel, Kanban, classify, BoardViewController, harness board, ScriptAPI, harnessBoard, MCP | 1/0 | Kanban-style Board view over live sessions/tabs/panes (cards), classified into columns by status, accessible via AppKit GUI sidebar, terminal CLI, scripting API, and read-only MCP tool |
| service-decomposition.md | Architecture | SessionCoordinator, facade, services, @MainActor, unowned, lazy | 2/0 | P17 god-object decomposition: SessionCoordinator 2050→397 LOC via 6 focused services (DaemonSync, SessionLifecycle, SplitPane, Notification, Theme, ActivePane) + HostDelegate extension + Types file |
| ui-automation.md | QA/Testing | Robot Framework, osascript, System Events, accessibility, CLI verification | 1/0 | P18 UI automation: Robot Framework + custom Python library using macOS System Events (AppleScript) for UI interaction + harness CLI for state verification. No Appium dependency. |
| browser-pane.md | AppKit/WebKit | WKWebView, BrowserLeaf, applyLocalSnapshot, hit-testing, URLDetection, localhost | 2/0 | P14 embedded Browser Pane: architecture, applyLocalSnapshot re-injection bug (close button no-op), collapsed errorBanner hit-testing bug, ⌘B shortcut, click-to-open localhost/LAN dev-server links |
| tab-bar.md | AppKit/UI | TabPillView, statusDot, branchLabel, gitBranch, drag, reorder, pill, shouldShowBranch, effectiveAgentKind, agentIcon | 1/0 | Tab bar pill layout; `Tab.effectiveAgentKind` centralized agent detection (daemon + OSC title inference); agent icon in sidebar cards; drag-reorder cancel-on-structural-reload |
| background-polling.md | Performance | SurfaceShellTracker, DaemonSyncService, metadataRefresh, snapshotChanged, fanout, PerfCounters, metadataOnly, double-subscription | 1/0 | P22 background polling architecture: SurfaceShellTracker proc-tree walk, 5-s metadata refresh loop, snapshotChanged fanout consumers and gate logic, PerfCounters instrumentation, known non-P22 syncFromDaemon callers |

## Source Map

| Knowledge | Implementation Files |
|-----------|---------------------|
| appkit-metal.md | `HarnessTerminalKit/HarnessTerminalSurfaceView.swift`, `HarnessApp/UI/PaneSplitButtonsView.swift`, `HarnessApp/UI/ContentAreaViewController.swift` |
| ipc-architecture.md | `HarnessCore/IPC/IPCCodec.swift`, `HarnessCore/IPC/DaemonClient.swift`, `HarnessDaemon/DaemonServer.swift` |
| split-panes.md | `HarnessApp/UI/HarnessSplitView.swift`, `HarnessApp/UI/ContentAreaViewController.swift` (PaneContainerView), `HarnessApp/Services/SessionCoordinator.swift`, `HarnessCore/Session/SessionEditor.swift` |
| acp-client.md | `HarnessCore/ACP/ACPClient.swift`, `HarnessCore/ACP/ACPSession.swift`, `HarnessApp/UI/AgentChatPanelView.swift` |
| git-panel.md | `HarnessApp/UI/GitPanelView.swift` |
| session-tab-hierarchy.md | `HarnessApp/UI/ContentAreaViewController.swift`, `HarnessApp/UI/MainMenuBuilder.swift`, `HarnessApp/Services/SessionCoordinator.swift`, `HarnessCore/Session/SessionEditor.swift` |
| agent-session-board.md | `HarnessCore/Board/BoardModel.swift`, `HarnessCLI/HarnessCLI+Board.swift`, `HarnessApp/UI/BoardViewController.swift`, `HarnessApp/Scripting/ScriptAPI.swift`, `HarnessMCP/HarnessDaemonTools.swift`, `HarnessMCP/ToolRegistry.swift` |
| browser-pane.md | `HarnessApp/UI/Chrome/BrowserPaneView.swift`, `HarnessApp/Services/SplitPaneCoordinator.swift`, `HarnessApp/Services/DaemonSyncService.swift`, `HarnessApp/UI/Chrome/MainMenuBuilder.swift`, `HarnessApp/UI/Chrome/ContentAreaViewController.swift`, `HarnessApp/UI/Chrome/MainSplitViewController.swift`, `HarnessTerminalEngine/URLDetection.swift`, `HarnessTerminalKit/HarnessTerminalSurfaceView+SelectionAndLinks.swift` |
| tab-bar.md | `HarnessApp/UI/Terminal/TerminalTabBarView.swift`, `HarnessCore/Metadata/MetadataProvider.swift`, `HarnessApp/Services/DaemonSyncService.swift`, `HarnessApp/UI/Chrome/ContentAreaViewController.swift` |
| background-polling.md | `HarnessApp/Services/SurfaceShellTracker.swift`, `HarnessApp/Services/DaemonSyncService.swift`, `HarnessApp/Services/PerfCounters.swift`, `HarnessApp/UI/Chrome/MainSplitViewController.swift`, `HarnessApp/UI/Sidebar/BoardViewController.swift`, `HarnessApp/UI/Notch/NotchPanelController.swift`, `HarnessApp/UI/Sidebar/HarnessSidebarPanelViewController.swift` |

## Edges

| From | To | Shared Keywords |
|------|----|-----------------|
| appkit-metal.md | split-panes.md | NSView lifecycle, removeFromSuperview, rebuild |
| ipc-architecture.md | acp-client.md | framing, protocol, stdio |
| git-panel.md | split-panes.md | DispatchSource, real-time refresh |
| session-tab-hierarchy.md | appkit-metal.md | ContentAreaViewController, top bar |
| agent-session-board.md | session-tab-hierarchy.md | SessionSnapshot, Tab, PaneLeaf, status classification |
| browser-pane.md | split-panes.md | PaneNode, PaneContainerView, SplitPaneCoordinator |
| browser-pane.md | ipc-architecture.md | DaemonSyncService, snapshot, applySnapshot |
| tab-bar.md | session-tab-hierarchy.md | reloadTabBar, TabPillView, SessionGroup, pill-per-session |
| tab-bar.md | agent-session-board.md | statusDot, BoardColumnKind, tab status classification |

## Search Instructions

When loading context for a task, search this index by:
1. **Domain** column for the subsystem being modified
2. **Tags** for specific technologies/patterns
3. **Edges** for related cross-domain knowledge
