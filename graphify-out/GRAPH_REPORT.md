# Graph Report - kouen-terminal  (2026-07-10)

## Corpus Check
- 727 files · ~816,639 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 14445 nodes · 31819 edges · 3373 communities (901 shown, 2472 thin omitted)
- Extraction: 89% EXTRACTED · 11% INFERRED · 0% AMBIGUOUS · INFERRED: 3484 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `dbbe2604`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `SessionEditor` - 170 edges
2. `IPCRequest` - 155 edges
3. `SurfaceRegistry` - 154 edges
4. `DaemonClient` - 149 edges
5. `SessionCoordinator` - 124 edges
6. `KouenTerminalSurfaceView` - 124 edges
7. `AnyCodable` - 109 edges
8. `Command` - 107 edges
9. `KouenPaths` - 100 edges
10. `TerminalScreen` - 100 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 141 areas (155 edges)
2. `Command` - bridges 101 areas (107 edges)
3. `SessionCoordinator` - bridges 57 areas (124 edges)
4. `IPCResponse` - bridges 57 areas (72 edges)
5. `MenuTarget` - bridges 52 areas (60 edges)
6. `SpecialKey` - bridges 52 areas (56 edges)
7. `EngineConformanceTests` - bridges 50 areas (76 edges)
8. `AgentKind` - bridges 45 areas (92 edges)
9. `SurfaceRegistry` - bridges 44 areas (154 edges)
10. `KouenPaths` - bridges 44 areas (100 edges)

## Surprising Connections (you probably didn't know these)
- `SUI` --calls--> `Color`  [INFERRED]
  Packages/KouenOnboarding/Sources/KouenOnboarding/Design/ImmersivePalette.swift → Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsColorsView.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/RemoteHostsService.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `ThemeImportController` --calls--> `ThemeFileService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/ThemeImportController.swift → Packages/KouenTheme/Sources/KouenTheme/ThemeFileService.swift
- `WorktreeAutoIsolateService` --calls--> `WorktreeManager`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/WorktreeAutoIsolateService.swift → Packages/KouenCore/Sources/KouenCore/Worktree/WorktreeManager.swift

## Import Cycles
- None detected.

## Communities (3373 total, 2472 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.10
Nodes (18): DaemonCommandExecutor, Command, BellScanState, esc, normal, stringEsc, PanePipe, SurfaceMonitor (+10 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.05
Nodes (34): BoardCardView, BoardViewController, FlippedView, Bool, NSCoder, Set, TabID, Void (+26 more)

### Community 2 - ".handleNormal"
Cohesion: 0.07
Nodes (27): CustomStringConvertible, Error, InstallError, unsupported, DaemonClientError, connectionFailed, timeout, unexpectedResponse (+19 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.08
Nodes (15): ConcurrentIndexSet, DaemonContentionTests, String, URL, DaemonRoundTripTests, Data, Int32, String (+7 more)

### Community 5 - "IPCRequest"
Cohesion: 0.08
Nodes (25): header, String, UInt16, UUID, DecodedReplyFrame, output, reply, DecodedRequestFrame (+17 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.09
Nodes (24): AnyTransition, AnyView, AgentNotchPeekEvent, Reason, errored, finished, needsInput, RowState (+16 more)

### Community 7 - "Command"
Cohesion: 0.16
Nodes (4): TerminalEmulator, TerminalGridCell, TerminalGridSnapshot, ThaiCombiningMarkTests

### Community 8 - "LSPMessage"
Cohesion: 0.10
Nodes (17): CodingKeys, error, id, jsonrpc, method, params, JSONRPCId, int (+9 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.12
Nodes (12): colors, PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Data, Double, String (+4 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.14
Nodes (8): HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor, Bool, String, TerminalGridCell

### Community 11 - "GitPanelView.swift"
Cohesion: 0.13
Nodes (7): SessionCoordinator, Bool, SessionID, SplitDirection, String, UUID, WorkspaceID

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.11
Nodes (13): KeyRecorderView, Any, Bool, NSCoder, NSEvent, NSPoint, String, Void (+5 more)

### Community 14 - "VTParser"
Cohesion: 0.07
Nodes (24): CSIParams, State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate (+16 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.12
Nodes (7): Bool, Date, String, SurfaceID, TabID, WorkspaceID, Int32

### Community 16 - ".applyPreedit"
Cohesion: 0.10
Nodes (18): ConfigError, unsupportedAgent, writeFailure, MCPConfigWriter, Any, Bool, String, URL (+10 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.12
Nodes (19): Bool, String, UInt8, TerminalCellWidth, normal, spacerTail, wide, TerminalGridCell (+11 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.09
Nodes (29): DaemonSubscription, Bool, Data, Int32, TimeInterval, UInt64, Void, makeUnixStreamSocket() (+21 more)

### Community 19 - "SpecialKey"
Cohesion: 0.08
Nodes (28): BlockSelection, CursorRender, CursorStyle, bar, block, underline, FrameBuilder, RenderCell (+20 more)

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.09
Nodes (17): NSDraggingInfo, NSDragOperation, KouenTerminalSurfaceView, Any, Bool, CGFloat, NSEvent, NSMenu (+9 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.14
Nodes (7): AgentTableEntry, Bool, Set, String, AgentTitleInference, Bool, AgentDetectorTests

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.21
Nodes (5): Bool, SessionCoordinator, String, ThemeService, KouenOptions

### Community 24 - ".request"
Cohesion: 0.24
Nodes (7): DaemonClient, KouenCLI, String, KouenCLI, Bool, String, UUID

### Community 25 - "WorktreeManager"
Cohesion: 0.11
Nodes (15): KouenSidebarPanelViewController, String, SessionSnapshot, SidebarTitlebarHeaderView, FooterIconButton, RecentProjectsMenuButton, SidebarFooterModel, SidebarFooterView (+7 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.06
Nodes (37): 10. Status line, mouse, and options, 11. Shell integration, 12. Agent notifications, 13. Out-of-box troubleshooting, 14. One-page cheat sheet, 1. Five-minute setup, 2. Mental model, 3. Prefix key (+29 more)

### Community 27 - "RGBColor"
Cohesion: 0.15
Nodes (5): RenderScheduler, Bool, Void, RenderSchedulerTests, Bool

### Community 28 - ".parse"
Cohesion: 0.18
Nodes (6): ParsedShortcut, PrefixKeymap, Any, NSEvent, String, TimeInterval

### Community 30 - "Notification"
Cohesion: 0.13
Nodes (6): Bool, Data, String, UInt8, UnsafeBufferPointer, TerminalEmulator

### Community 31 - "Sendable"
Cohesion: 0.33
Nodes (9): BufferSummary, HookEntry, IPCResponse, OptionEntry, Data, Date, String, UUID (+1 more)

### Community 32 - ".addTab"
Cohesion: 0.13
Nodes (8): KouenTerminalSurfaceView, CGFloat, CGRect, NSEvent, NSPoint, Range, String, UInt16

### Community 33 - "Equatable"
Cohesion: 0.20
Nodes (6): MainExecutor, Bool, PaneID, PaneNode, SessionCoordinator, SurfaceID

### Community 34 - "DaemonClient"
Cohesion: 0.17
Nodes (9): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, String, URL, LSPServerRegistryTests, String (+1 more)

### Community 35 - "MenuTarget"
Cohesion: 0.22
Nodes (4): PaneRectSolverTests, Bool, PaneNode, PaneRect

### Community 37 - "String"
Cohesion: 0.09
Nodes (18): PaneDragController, Any, Bool, NSEvent, NSView, NSWindow, PaneID, PaneDropZoneOverlay (+10 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.07
Nodes (18): AnyCancellable, AgentNotchPresentation, closed, open, peek, AgentNotchViewModel, AgentNotchWindowActivator, Bool (+10 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.17
Nodes (4): SessionSnapshot, String, UUID, TargetSpecTests

### Community 41 - "CodingKeys"
Cohesion: 0.10
Nodes (20): ClientRecord, CountBox, DaemonServer, PendingBrowserRequest, PendingWrite, Bool, CheckedContinuation, Data (+12 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.16
Nodes (15): CommandParseError, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand, unterminatedString (+7 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.17
Nodes (12): CommandPaletteController, PaletteAction, PaletteFileEntry, PaletteGrepMatch, PaletteModel, PaletteRow, item, NSWindow (+4 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.12
Nodes (11): ChromeBackdrop, KouenDesign, KouenOverlayBackground, RuntimeGlassEffectView, Bool, CALayer, NSColor, NSPoint (+3 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.05
Nodes (27): NSCursor, T, KouenTerminalSurfaceView, SurfaceColorProviderState, SurfaceEmulatorState, SurfaceFrameBuildConfiguration, SurfaceFrameBuildResult, Bool (+19 more)

### Community 46 - ".buildCommand"
Cohesion: 0.10
Nodes (17): Endpoint, EndpointError, connectionFailed, notYetSupported, pathTooLong, String, EndpointConnector, Int32 (+9 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.09
Nodes (21): LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed, serverNotExecutable, FileHandle, Int32 (+13 more)

### Community 48 - "HookEvent"
Cohesion: 0.13
Nodes (14): Executor, Hook, HookEvent, HookRegistry, Bool, Command, URL, UUID (+6 more)

### Community 49 - "DaemonServer"
Cohesion: 0.14
Nodes (5): CommandIPCTranslatorTests, Bool, CommandTarget, PaneID, TabID

### Community 51 - ".keyEvent"
Cohesion: 0.13
Nodes (19): CopyModeMatch, ColorKind, bg, fg, underline, CompositorPane, GridCompositor, RenderCell (+11 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.06
Nodes (19): CornerInfo, EditorDividerView, KouenSplitView, PaneDragGripView, PaneHoverButton, PaneSplitButtonsView, DispatchWorkItem, Double (+11 more)

### Community 55 - "TabCell"
Cohesion: 0.25
Nodes (6): AnyCodable, JSONRPCError, Bool, Int32, String, ToolRegistry

### Community 56 - "NSPanel"
Cohesion: 0.16
Nodes (10): QuickTerminalController, QuickTerminalPanelDelegate, Any, Bool, NSEvent, NSPanel, NSRect, NSScreen (+2 more)

### Community 57 - "BellScanState"
Cohesion: 0.15
Nodes (7): DaemonLifecycle, Bool, pid_t, String, URL, DaemonLifecycleTests, URL

### Community 58 - "PasteBufferStore"
Cohesion: 0.12
Nodes (33): MTLClearColor, MTLCommandBuffer, MTLRenderCommandEncoder, TerminalFrame, BgInstance, CursorCacheKey, DecoInstance, EncodedFrameInstances (+25 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.06
Nodes (32): 1. ภาพรวมสถาปัตยกรรม (Architecture Overview), ✅ 2.1 `sidebarRows` คำนวณซ้ำ O(N²) ทุกครั้งที่ reload ตาราง — DONE, ⚠️ 2.2 Blocking IPC บน Main Thread — PENDING (P2), ✅ 2.3 การ scan แบบ triple-nested ต่อ sync — DONE, ✅ 2.4 `applyThemeToAllHosts()` ทำงานทุก non-metadata sync — DONE, ✅ 2.5 Split view double-layout เมื่อ switch tab — DONE, ✅ 2.6 Metadata refresh probe ทุก tab ทุก 2 วินาที — DONE, 2. ปัญหาและแนวทางแก้ไข (Issues & Fixes) (+24 more)

### Community 60 - "ViEngine"
Cohesion: 0.23
Nodes (7): PaneLifecycleManager, NSView, PaneID, PaneNode, Set, String, Tab

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.14
Nodes (17): ColorKind, bg, fg, underline, ComposedCell, CompositorPane, GridCompositor, Bool (+9 more)

### Community 62 - "ComposedCell"
Cohesion: 0.05
Nodes (48): AgentBridge, AgentTarget, Bool, String, SurfaceID, LinePos, end, firstNonBlank (+40 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.15
Nodes (10): Buffer, Configuration, PasteBufferStore, Bool, Data, Date, String, URL (+2 more)

### Community 64 - ".text"
Cohesion: 0.14
Nodes (15): PendingVersionBanner, welcome, whatsNew, State, Bool, String, URL, VersionBannerStore (+7 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.12
Nodes (10): KouenTerminalSurfaceView, Bool, CAMetalDrawable, NSEvent, RGBColor, String, KouenTerminalSurfaceView, CGFloat (+2 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.09
Nodes (8): KouenThemeCatalog, String, KouenThemeDefinition, Bool, RGBColor, String, ANSIPaletteTests, KouenThemeCatalogTests

### Community 67 - "String"
Cohesion: 0.18
Nodes (9): AgentHookInstaller, InstallResult, Any, Bool, Data, String, URL, result (+1 more)

### Community 69 - ".compose"
Cohesion: 0.21
Nodes (7): KouenCLI, SessionGroup, SessionSnapshot, String, UUID, T, Void

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.10
Nodes (5): ClosedRange, Range, TerminalCellWidth, UnsafeBufferPointer, TerminalScreen

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.10
Nodes (13): KouenUILibrary, Type a string of text into the focused element via osascript keystroke., Get cols x rows from active terminal via stty., Send raw keys to active terminal surface., Send :ex command via CLI., Hover over tab pill at given index (AppleScript)., Click the Sync/Fetch button in Git panel., Launch Kouen app. env: 'preview' (debug) or 'staging' (release+isolated). (+5 more)

### Community 72 - "XCTestCase"
Cohesion: 0.07
Nodes (31): AgentRow, HookState, failed, idle, installed, installing, SettingsAgentsView, Bool (+23 more)

### Community 73 - "README.md"
Cohesion: 0.08
Nodes (17): Codex → Kouen, One-line install, What you'll see, Cursor Agent → Kouen, Manual fallback, One-line install, What you'll see, Hermes → Kouen (+9 more)

### Community 75 - "OptionStore"
Cohesion: 0.08
Nodes (29): CaseIterable, KouenSettings, ResizeOverlayMode, afterFirst, always, never, ResizeOverlayPosition, bottomRight (+21 more)

### Community 76 - ".parse"
Cohesion: 0.16
Nodes (12): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, SessionSnapshot, String, Tab (+4 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.19
Nodes (5): SSHTunnelManager, SSHTunnelManagerTests, RemoteHost, String, URL

### Community 79 - "HarnessDesign"
Cohesion: 0.17
Nodes (8): ScrollbackFile, Bool, Data, DispatchWorkItem, URL, ScrollbackFileTests, String, URL

### Community 80 - "Agent handbook — Harness (extended reference)"
Cohesion: 0.09
Nodes (21): Build / Test / Run, Graphify, graphify, kouen-terminal — Claude Instructions, Non-obvious Constraints, Session Start, Skills, Agent handbook — Kouen (extended reference) (+13 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.14
Nodes (13): InstallResult, Profile, Shell, bash, fish, zsh, ShellProfileInstaller, Bool (+5 more)

### Community 82 - ".firstMatch"
Cohesion: 0.16
Nodes (3): LiveResizeTests, KouenTerminalSurfaceView, NSWindow

### Community 83 - "LSPClient"
Cohesion: 0.16
Nodes (11): Result, AsyncCLIResultBox, KouenCLI, LSPDefinitionPayload, LSPDiagnosticsPayload, LSPStatusPayload, Error, String (+3 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.15
Nodes (12): SplitPaneCoordinator, Bool, PaneID, PaneNode, SessionCoordinator, SessionID, SplitDirection, String (+4 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.09
Nodes (21): object, CodingKeys, error, id, jsonrpc, method, params, result (+13 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.17
Nodes (7): FileEditorView, Bool, NSCoder, NSEvent, NSRect, String, URL

### Community 87 - "SessionCoordinator"
Cohesion: 0.13
Nodes (16): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+8 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 89 - ".cursorPos"
Cohesion: 0.17
Nodes (4): hooks, AgentHookInstallerTests, String, URL

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.16
Nodes (9): ShellLaunchProfileTests, SurfaceRegistryTests, PaneID, SessionID, SessionSnapshot, String, SurfaceID, TabID (+1 more)

### Community 91 - "TerminalModes"
Cohesion: 0.13
Nodes (5): ContentAreaViewController, CGFloat, String, TabID, Notification

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.08
Nodes (25): code:swift (// DaemonSessionService.swift), code:swift (// ต้องคงเป็น sync เพราะเรียกก่อน process exit), code:swift (// ปัจจุบัน: DispatchQueue.global + DispatchQueue.main.async), code:text (1. DaemonClientActor (new file, ไม่ break อะไร)), code:text (Before:), code:swift (// DaemonClientActor.swift (new)), code:swift (func fetchSnapshot() async throws -> SessionSnapshot {), code:swift (// Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonClient) (+17 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.20
Nodes (8): C, AttachInputBatcher, Outcome, Bool, Data, UInt8, AttachInputBatcherTests, UInt8

### Community 95 - "shim.c"
Cohesion: 0.14
Nodes (13): DirectoryItemRow, DirectoryPanel, DirectoryPickerController, DirectoryPickerFooter, DirectoryPickerModel, DirectoryPickerView, DirectoryWindowDelegate, String (+5 more)

### Community 96 - "Harness Usage"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.67
Nodes (3): 4.1 Architecture Pattern, 4. Technical Architecture, 4.2 Technology Stack

### Community 99 - ".dispatch"
Cohesion: 0.13
Nodes (12): AgentDetector, AgentTable, Date, Int32, TimeInterval, WrapperOptionBehavior, keepScanning, matchValue (+4 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.18
Nodes (8): Bool, CGFloat, NSCoder, NSEvent, NSTrackingArea, WorkspaceID, WorkspaceSwitcherPanelView, WorkspaceSwitcherRow

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.10
Nodes (20): 1. Add Project Group Heuristics, 1. Keep Split State In Session/Tab Structure, 2. Introduce Sidebar Row Model, 2. UX Entry Points, 3. Build Grouped Rows From Filtered Sessions, 4. Update Table Data Source and Delegate, 5. Drag and Drop Rules, code:text (Window) (+12 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.10
Nodes (20): CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect, beginSearchEntry (+12 more)

### Community 103 - "AnyCodable"
Cohesion: 0.11
Nodes (20): LocalizedError, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, found, notFound (+12 more)

### Community 104 - "Recipe"
Cohesion: 0.11
Nodes (26): Equatable, Bool, UInt8, TerminalCellWidth, normal, spacerTail, wide, TerminalCursor (+18 more)

### Community 105 - "Changelog"
Cohesion: 0.15
Nodes (3): KittyKeyboardTests, String, UInt8

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.21
Nodes (9): StdioTransportTests, Data, MCPStdioBuffer, MCPStdioFraming, contentLength, newline, StdioTransport, AsyncStream (+1 more)

### Community 108 - ".resolve"
Cohesion: 0.10
Nodes (8): OptionSet, Modifiers, Decoder, String, UInt8, DECSpecialGraphics, CommandParserTests, KeyTableTests

### Community 109 - "DamageTrackingTests"
Cohesion: 0.10
Nodes (13): SGRMouse, SGRMouseEvent, Bool, PaneRect, S, UInt8, MouseEventKind, drag (+5 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.20
Nodes (4): CopyModeReducerTests, FakeGrid, String, TerminalGridCell

### Community 112 - ".makeSnapshot"
Cohesion: 0.11
Nodes (18): OptionStore, OptionStore.Value, Scope, global, pane, session, tab, workspace (+10 more)

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.20
Nodes (13): CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf, PaneSurface (+5 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.15
Nodes (7): ImportedTerminalConfig, Bool, Double, Float, String, TerminalConfigImporter, TerminalConfigImporterTests

### Community 115 - ".encode"
Cohesion: 0.12
Nodes (17): Int, TerminalGridSnapshot, ImagePlacementSnapshot, SemanticMark, TerminalColorRole, background, cursor, foreground (+9 more)

### Community 116 - "SessionGroup"
Cohesion: 0.13
Nodes (11): DaemonSyncService, Bool, Never, SessionCoordinator, SessionSnapshot, SurfaceID, Tab, TabID (+3 more)

### Community 117 - "PaneNode"
Cohesion: 0.12
Nodes (10): NotificationCoordinator, Bool, Date, SessionCoordinator, SessionSnapshot, Set, String, SurfaceID (+2 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.13
Nodes (8): SessionLifecycleService, SessionCoordinator, SessionGroup, SessionID, String, Tab, TabID, WorkspaceID

### Community 119 - "Harness command reference"
Cohesion: 0.12
Nodes (16): Attaching from a plain terminal, Bindings, Buffers (paste store), Composition, Hooks, Inspection (CLI / control mode), Kouen command reference, Local diagnostics (+8 more)

### Community 122 - "ViEngine"
Cohesion: 0.14
Nodes (13): GitResult, RepoEntry, Bool, escaping, MainActor, NSEvent, String, Void (+5 more)

### Community 123 - "Pipe"
Cohesion: 0.11
Nodes (14): ExternalOpenKind, filePreview, terminal, theme, InstallChoice, cancel, install, installAndApply (+6 more)

### Community 124 - "String"
Cohesion: 0.11
Nodes (4): TerminalModes, InputEncoderTests, String, UInt8

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.12
Nodes (9): ContiguousArray, IteratorProtocol, HistoryRingBuffer, Iterator, Bool, Element, S, Sequence (+1 more)

### Community 126 - ".path"
Cohesion: 0.08
Nodes (25): AgentArt, AgentMark, AgentMarkShape, AgentVectorIcon, Scanner, SVGPath, Bool, CGFloat (+17 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.12
Nodes (18): AtlasEntry, ClusterGlyphKey, GlyphAtlas, GlyphAtlasStats, GlyphKey, ShapedGlyphKey, Bool, CGGlyph (+10 more)

### Community 129 - "SwiftUI"
Cohesion: 0.17
Nodes (6): FilePreviewCoordinator, FileTabID, NSView, Set, SplitDirection, String

### Community 130 - "Harness"
Cohesion: 0.11
Nodes (18): code:bash (harness-cli doctor), AI Browser Control (kouen-mcp), Build From Source, CLI, Development Builds, Documentation, Editor & LSP, How It Feels (+10 more)

### Community 131 - ".install"
Cohesion: 0.17
Nodes (11): RecipeItemRow, RecipePanel, RecipePickerController, RecipePickerFooter, RecipePickerModel, RecipePickerView, RecipeWindowDelegate, Bool (+3 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.12
Nodes (17): CommandIPCTranslator, CommandTarget, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID (+9 more)

### Community 133 - ".load"
Cohesion: 0.16
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 135 - "CommandTarget"
Cohesion: 0.15
Nodes (11): String, Style, accent, agent, agentWorking, done, error, idle (+3 more)

### Community 136 - ".startWatching"
Cohesion: 0.18
Nodes (6): NSAttributedString, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 137 - "ActivePaneService"
Cohesion: 0.06
Nodes (41): CoreImage, Decodable, Encodable, NWEndpoint, NWListener, AttachedAck, ConnectionState, ControlMessage (+33 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.67
Nodes (3): Future User Stories (Post-MVP), MVP User Stories (Must Implement), User Story Mapping (MANDATORY)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.11
Nodes (18): 1.1 โครงสร้างการทำงานของ Quick Look (Quick Look Architecture), 1.2 สองคลาสหลักในการใช้งาน (QLPreviewPanel vs. QLPreviewView), 1. เบื้องหลังการทำงานของระบบพรีวิวบน macOS (Under the Hood: macOS Quick Look), 2. การกำหนดลำดับขั้นการคัดแยกประเภทไฟล์ (File Routing Model), 3. แผนการแบ่งแทร็กการพัฒนา (Development Tracks), 4.1 ตัวจัดการควบคุมกลยุทธ์การพรีวิว (File Preview Strategy Protocol), 4.2 คอนโทรลเลอร์แสดงผลไฟล์หลัก (FileViewerViewController), 4.3 ตัวพรีวิวเนทีฟด้วย Quick Look (macOSQuickLookStrategy) (+10 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.24
Nodes (7): StartupMetrics, Bool, Double, UInt64, URL, StartupMetricsTests, UInt64

### Community 142 - "CopyModeGridSource"
Cohesion: 0.28
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.10
Nodes (19): 1. Find the CLI, 2. Check daemon health, 3. List what's running (like `tmux ls`), 4. Attach to a pane, 5. Create sessions/tabs from a script, 6. Drive a pane without attaching, 7. tmux control mode, 8. Remote/headless daemon (+11 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.08
Nodes (11): SurfaceID, DetachedPaneOverlay, Style, detached, reconnectingChip, NSCoder, NSEvent, NSPoint (+3 more)

### Community 145 - "AsciiFastPathTests"
Cohesion: 0.16
Nodes (3): DamageTrackingTests, IndexSet, TerminalEmulator

### Community 146 - "DecodedImage"
Cohesion: 0.06
Nodes (20): keys, CGImage, DecodedImage, ImageLimits, Bool, UInt8, ImageDecoder, Data (+12 more)

### Community 147 - "FileTreeWatcher"
Cohesion: 0.10
Nodes (18): Darwin, Glibc, CLIInstallLocator, DetachKeys, absent, invalid, parsed, KouenCLI (+10 more)

### Community 148 - "TriState"
Cohesion: 0.11
Nodes (17): Architecture, Browser Auto-Retry (P24 Phase 4), Browser Pane (P14), BUG: Tab close button never fired (CASE-055 extended), BUG: Tab close button unresponsive (gesture conflict), CASE: applyLocalSnapshot re-injected closed browser panes (v2.7.1), CASE: collapsed errorBanner intercepted toolbar clicks (v2.7.1), CASE: Nested cross-origin iframe won't wheel-scroll — FIXED, confirmed (2026-07-06) (+9 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.12
Nodes (12): KouenMCP, KouenBrowserToolsTests, URL, KouenDaemonToolsTests, String, URL, Document, Bool (+4 more)

### Community 151 - ".evaluate"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.10
Nodes (10): FormatContextBuilder, DaemonSurfaceID, SessionSnapshot, String, FormatContextDaemonTests, PaneID, SessionSnapshot, String (+2 more)

### Community 154 - "LiveResizeTests"
Cohesion: 0.09
Nodes (13): Date, String, TerminalBlock, TerminalBlockStore, KouenGridTerminal, Bool, Data, String (+5 more)

### Community 155 - "Int"
Cohesion: 0.14
Nodes (11): FileFuzzyMatcher, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool, Character (+3 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.14
Nodes (9): NotificationDropdownPanelView, NotificationRowView, Bool, CGFloat, NSCoder, NSEvent, NSScrollView, NSTrackingArea (+1 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.12
Nodes (15): Architecture, Branch, Build & Preview, CMUX Pane Splitting, code:block1 (worktree-feature+acp-aidlc), code:bash (cd /tmp/hp  # symlink to worktree (socket path length limit)), code:block3 (HarnessSidebarPanelViewController — Sessions / Files / Git t), Features (+7 more)

### Community 159 - "MatchCategory"
Cohesion: 0.22
Nodes (10): InputEncoder, KeyEventType, press, release, `repeat`, KeyModifiers, SpecialKey, Character (+2 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.25
Nodes (12): PaneID, PaneLeaf, PaneNode, SessionGroup, SessionID, SessionSnapshot, SurfaceID, Tab (+4 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.08
Nodes (25): 10. Universal retire-hold via `removeFromSuperview()` override (definitive), 11. NSEvent local monitor installed in AppDelegate (fix #8 actually deployed), 12. `nonisolated` + `MainActor.assumeIsolated` on high-frequency AppKit callbacks (2026-06-21), 1. `TerminalPaneRegistry.retire()` — deferred dealloc (500ms), 2. Remove `nonisolated` from all layout overrides, 3. Remove `MainActor.assumeIsolated` from callbacks, 4. Detach NSHostingView on teardown (FileTreeSwiftUIView), 5. Avoid `Optional.map {}` in @MainActor code (+17 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.06
Nodes (20): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel, NSSearchFieldDelegate, Bool (+12 more)

### Community 163 - "Workspace"
Cohesion: 0.16
Nodes (9): AttributedString, NSColor, Recipe, RecipesStore, Bool, String, URL, UUID (+1 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.16
Nodes (14): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, PRInfo (+6 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.20
Nodes (11): Command, CommandTarget, PaneID, SessionGroup, SessionSnapshot, Tab, TargetKind, pane (+3 more)

### Community 166 - "LiveSession"
Cohesion: 0.16
Nodes (13): GridCompositor, Configuration, Int32, SessionID, SessionSnapshot, Tab, TabID, WorkspaceID (+5 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.31
Nodes (9): BannerShortcut, BannerShortcutRegistry, Keybinding, MenuModifiers, Bool, Decoder, NSEvent, String (+1 more)

### Community 170 - "URLDetection"
Cohesion: 0.10
Nodes (13): Bool, Range, String, URLDetection, digest(), firstMatch(), flushBullet(), Section (+5 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.15
Nodes (13): AgentApprovalBar, ApprovalBarAction, hide, noop, show, NSColor, Bool, NSButton (+5 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.09
Nodes (13): CKouenSys, termios, AttachClient, Configuration, LiveSession, Bool, Data, DispatchSourceSignal (+5 more)

### Community 173 - "BoardCard"
Cohesion: 0.10
Nodes (14): PaletteCommandConfig, PaletteFooter, PaletteItemRow, PaletteMode, errors, grep, normal, PalettePanel (+6 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.22
Nodes (6): KouenDaemonTools, Bool, PaneLeaf, String, Tab, UUID

### Community 175 - "RGBColorTests"
Cohesion: 0.17
Nodes (7): RemoteHost, RemoteHost, SettingsRemoteView, Bool, NSImage, RemoteHost, String

### Community 177 - ".rects"
Cohesion: 0.09
Nodes (24): AgentStatusDot, Context, AgentChipView, BoardColumnKind, ChromeRole, sidebar, tabBar, Divider (+16 more)

### Community 178 - "InlineAICompletionView"
Cohesion: 0.27
Nodes (7): CopyModeGridSource, CopyModeReducer, Bool, Character, Range, String, GridPosition

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.14
Nodes (17): PaneBorderStatus, bottom, off, top, PaneLeaf, PaneNode, branch, leaf (+9 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.23
Nodes (6): CellOverlayTests, IndexSet, KouenTerminalSurfaceView, NSWindow, String, UInt64

### Community 181 - "GridCompositorTests"
Cohesion: 0.18
Nodes (5): CompositorPane, GridCompositorTests, Bool, String, TerminalGridSnapshot

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.17
Nodes (12): Already portable or mostly portable, Competitive Landscape (research 2026-07-04), Current Architecture Fit, First Implementation Slice, Implications for this plan, macOS-specific today, Non-goals, Open Questions (+4 more)

### Community 183 - "LSPServerRegistry"
Cohesion: 0.14
Nodes (5): CodepointRunFastPathTests, StaticString, String, UInt, UInt8

### Community 184 - "targets"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Kouen, Sparkle (+13 more)

### Community 185 - "SessionSnapshot"
Cohesion: 0.15
Nodes (4): KouenGridTerminalTests, KouenGridTerminal, String, TerminalGridSnapshot

### Community 186 - "Error"
Cohesion: 0.24
Nodes (12): atomicWrite(), backupCorruptFile(), fnv1aHex(), KouenPaths, KouenPathsError, socketPathTooLong, Bool, Data (+4 more)

### Community 187 - "AppDelegate"
Cohesion: 0.12
Nodes (16): AppDelegate, QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL, Bool, NSPasteboard (+8 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.12
Nodes (16): Architecture, Bounded Contexts, code:block1 (Agent Process (Claude Code / Codex / Gemini)), code:block2 (Packages/HarnessCore/Sources/HarnessCore/ACP/), code:block3 (Content-Length: 123\r\n), Estimate, Goal, Key Files (New) (+8 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.15
Nodes (7): ScriptRuntime, Any, String, URL, JSContext, JSValue, ScriptingTests

### Community 192 - "GlyphRasterizer"
Cohesion: 0.09
Nodes (20): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, RasterizedGlyph, ShapedGlyph, ShapedRunCacheStats, ShapedRunKey, Bool (+12 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.18
Nodes (11): RecordClient, RecordingWriter, RecordSession, Summary, Bool, Data, DispatchSourceSignal, FileHandle (+3 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.11
Nodes (25): FileNode, GitStatusType, added, deleted, modified, renamed, unmodified, untracked (+17 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.15
Nodes (10): CommandPromptController, KeyablePanel, Bool, NSControl, NSPanel, NSTextView, Selector, String (+2 more)

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.11
Nodes (10): Kind, primary, secondary, KouenPillButton, SoftIconButton, CGRect, NSCoder, NSEvent (+2 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.16
Nodes (9): CompletionPopupView, CompletionRowView, Bool, NSCoder, NSEvent, NSRect, NSTrackingArea, String (+1 more)

### Community 198 - ".classify"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.14
Nodes (9): InstallResult, Shell, bash, fish, zsh, Bool, URL, ShellIntegrationTests (+1 more)

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.38
Nodes (3): GitStatusProvider, Data, String

### Community 202 - "PaletteModel"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Key spec syntax, Kouen keybindings, Persistence (+1 more)

### Community 204 - "From tmux"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 205 - "CopyModeState"
Cohesion: 0.15
Nodes (9): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+1 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.24
Nodes (7): Container, NotchPulseHost, Content, Context, NSCoder, NSHostingView, NSRect

### Community 207 - "scheduleRender"
Cohesion: 0.09
Nodes (13): KouenSidebarPanelViewController, CGFloat, NSMenuItem, NSView, SessionGroup, String, KouenSidebarPanelViewController, NSMenu (+5 more)

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.25
Nodes (8): PairedDeviceSummary, SessionSnapshot, SurfaceSummary, Bool, Date, Decoder, String, WorkspaceID

### Community 209 - "SettingsRemoteView"
Cohesion: 0.16
Nodes (11): Process, SSHTunnelError, exitedEarly, launchFailed, notReady, Bool, Int32, RemoteHost (+3 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.22
Nodes (3): CompletionGenerator, String, CompletionGeneratorTests

### Community 211 - "PaneTarget"
Cohesion: 0.28
Nodes (7): ignoreSIGPIPE(), Channel, Bool, Int32, String, WaitForRegistry, WaitForRegistryTests

### Community 212 - ".translate"
Cohesion: 0.23
Nodes (7): DaemonMetrics, Snapshot, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 213 - "String"
Cohesion: 0.08
Nodes (24): 1 — Process lifecycle & supervision, 2 — IPC protocol evolution, 3 — Concurrency architecture, 4 — State persistence, 5 — Render/PTY data path & the "mktemp failed" spam, 6 — Build/release pipeline, A10 (Low) — stale `@unchecked Sendable` inventory, A1 (High) — S1 daemon-reuse is undone at GUI relaunch by the build-handshake staleness check (+16 more)

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.15
Nodes (8): CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16, UInt8, CharacterWidthTests

### Community 215 - ".lines"
Cohesion: 0.10
Nodes (18): InputGate, ReconnectLatch, SurfaceIO, Bool, CGFloat, Data, FormatColor, KouenSettings (+10 more)

### Community 216 - "CellColorResolverTests"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 217 - "GridCompositor"
Cohesion: 0.19
Nodes (14): FileEditorTabBarBody, FileEditorTabBarModel, FileEditorTabBarView, FileTabPillView, Bool, FileTabID, NSCoder, NSRect (+6 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.12
Nodes (11): BranchSwitchHelper, FileTreeNode, FileTreeSwiftUIView, NodeRow, Notification.Name, Bool, NSMenuItem, SessionID (+3 more)

### Community 219 - "Prompt"
Cohesion: 0.15
Nodes (14): code:block1 (Refactor `Tools/harness/Sources/HarnessCLI/HarnessCLI.swift`), code:block2 (Extract pure input-routing logic from `Tools/harness/Sources), code:block3, code:block4, code:block5 (Decompose `Packages/HarnessDaemon/Sources/HarnessDaemon/Surf), code:block6, code:block7, code:block8 (+6 more)

### Community 220 - "Section"
Cohesion: 0.21
Nodes (8): NotchGeometry, NSScreen, NotchLayoutMetrics, NotchRect, NotchScreenMetrics, Bool, Double, NotchLayoutMetricsTests

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.16
Nodes (5): Double, PaneID, PaneNode, SurfaceID, TabID

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.08
Nodes (20): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+12 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.18
Nodes (14): TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid, RenderColor (+6 more)

### Community 224 - "CellColorResolver"
Cohesion: 0.28
Nodes (8): ANSIPalette, CellColorResolver, ResolvedCellColors, Bool, Double, RGBColor, TerminalGridCell, TerminalGridColor

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.19
Nodes (8): Range, String, TerminalGridCell, TerminalBufferMatch, TerminalBufferSearch, String, TerminalGridCell, TerminalBufferSearchTests

### Community 226 - "FileChangeWatcher"
Cohesion: 0.18
Nodes (16): SessionRef, byID, byName, next, previous, String, UUID, TargetSpec (+8 more)

### Community 228 - "sessionRow"
Cohesion: 0.19
Nodes (7): KeybindingsStore, URL, KeybindingsStoreTests, URL, Void, KouenCLI, String

### Community 229 - ".decide"
Cohesion: 0.25
Nodes (6): MutationResult, RemoteHost, RemoteHostStore, Bool, String, T

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.27
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 231 - "ExternalOpenKind"
Cohesion: 0.17
Nodes (18): Appearance, AppearanceKind, dark, light, Colors, ContrastGrade, high, low (+10 more)

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.11
Nodes (17): 1. Add a `pendingReflowTask` field to `TerminalScreen`, 2. Split `reflow(toCols:rows:)` into two helpers, 3. In `resize(cols:rows:)`, use the fast path first, Background, code:swift (// In TerminalScreen), code:swift (// Fast path — reflow only viewport + lookahead), code:swift (mutating func resize(cols nc: Int, rows nr: Int) {), code:swift (// TerminalEmulator: add a "live resize in progress" flag) (+9 more)

### Community 233 - "TextGrid"
Cohesion: 0.17
Nodes (4): String, RegressionBugFixTests, SessionSnapshot, Tab

### Community 234 - ".scan"
Cohesion: 0.25
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 235 - "WorkbenchCommand"
Cohesion: 0.11
Nodes (13): SettingsHostingController, SettingsWindowController, NSCoder, NSWindow, Page, advanced, appearance, remote (+5 more)

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.14
Nodes (8): Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint, NSRect, WindowTitleStripView

### Community 238 - ".make"
Cohesion: 0.05
Nodes (29): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, failed, DefaultTerminalStatus, Bool, String, URL (+21 more)

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 240 - "PaneBorderStatus"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 242 - "AgentBridge"
Cohesion: 0.21
Nodes (7): ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy, NSWindow

### Community 243 - ".make"
Cohesion: 0.29
Nodes (5): KeyTokenParser, Bool, Data, String, KeyTokenParserTests

### Community 244 - "FileNode"
Cohesion: 0.13
Nodes (11): DaemonSessionError, daemonError, unexpectedResponse, DaemonSessionService, LatencyMonitor, Bool, SessionSnapshot, String (+3 more)

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.23
Nodes (6): EnvironmentStore, Persisted, String, URL, EnvironmentStoreTests, URL

### Community 246 - "Experience modes"
Cohesion: 0.29
Nodes (7): 1. Plain Terminal, 2. Persistent Terminal, 3. Full Terminal, 4. Agent Workspace, Experience modes, Opting into the prefix + status line without switching modes, Persistence (ephemeral vs. persistent)

### Community 247 - ".renderFixture"
Cohesion: 0.16
Nodes (12): InstallError, daemonNotFound, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, Bool, Int32 (+4 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.27
Nodes (5): WorktreeManager, String, URL, UUID, WorktreeIsolationDaemonTests

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.16
Nodes (9): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+1 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.08
Nodes (15): ActivePaneService, Bool, PaneID, PaneNode, SessionCoordinator, Set, SurfaceID, Tab (+7 more)

### Community 251 - "SessionCoordinator"
Cohesion: 0.32
Nodes (3): BinaryInstallerVersionTests, String, URL

### Community 252 - "NSViewRepresentable"
Cohesion: 0.21
Nodes (7): FlippedView, NSColor, NSScrollView, NSStackView, NSTextField, NSClickGestureRecognizer, NSView

### Community 253 - "Split Right"
Cohesion: 0.14
Nodes (11): MTLLibrary, MTLRenderPipelineState, ImageTextureCache, MTLDevice, MTLTexture, UInt8, CGFloat, MTLBuffer (+3 more)

### Community 254 - "BoardViewController"
Cohesion: 0.20
Nodes (5): SessionCoordinator, Bool, String, SurfaceID, TimeInterval

### Community 255 - "release-hotfix.sh"
Cohesion: 0.17
Nodes (6): BrowserPaneView, NSStackView, NSTextField, Selector, String, URL

### Community 256 - "GitMetadataProvider"
Cohesion: 0.12
Nodes (13): InlineAICompletionController, KouenSettings, String, InlineAICompletionView, Bool, NSCoder, NSEvent, NSRect (+5 more)

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.27
Nodes (17): Sendable, AttachedAck, attachToPairedSurface(), ConnectionState, detectHost(), PairingBox, PendingPairing, qrAsciiArt() (+9 more)

### Community 258 - "WindowTitleStripView"
Cohesion: 0.11
Nodes (12): KouenCore, KouenDaemonCore, Network, IPCCodecInvariantTests, EndpointClientTests, String, URL, ScrollbackPersistenceTests (+4 more)

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.25
Nodes (5): DisplayMessage, RunShell, Command, MainActor, String

### Community 260 - ".welcome"
Cohesion: 0.15
Nodes (5): HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.19
Nodes (8): HookNotificationParser, Parsed, Any, Data, String, HookNotificationParserTests, Data, String

### Community 262 - ".install"
Cohesion: 0.19
Nodes (5): LSPTextLocation, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.20
Nodes (10): DemoSession, DemoTerminalView, GridCanvas, Bool, CGFloat, String, StyledSegment, TerminalGridCell (+2 more)

### Community 266 - ".path"
Cohesion: 0.20
Nodes (7): Data, ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 270 - "WindowSession"
Cohesion: 0.10
Nodes (12): pipe, PaneBorderStatus, Bool, Command, CommandTarget, DispatchWorkItem, KouenGridTerminal, PaneRect (+4 more)

### Community 271 - "StatusLineView.swift"
Cohesion: 0.13
Nodes (14): StatusLineView, CGFloat, FormatColor, Never, NSAttributedString, NSCoder, NSColor, NSLayoutConstraint (+6 more)

### Community 272 - "SGRMouseEvent"
Cohesion: 0.20
Nodes (11): ControlModeClient, ControlModeError, daemon, noMatch, noSnapshot, unresolved, Command, Data (+3 more)

### Community 273 - "KeySpec"
Cohesion: 0.37
Nodes (3): FileTreeWatcher, FileTreeWatcherTests, URL

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.26
Nodes (4): PromptQueue, String, SurfaceID, Void

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.13
Nodes (15): Context, Non-goals, P8: macOS 27 Golden Gate Adoption, Phase 0 — Swift 6.3+ Concurrency Safety (P0, LESSONS FROM macOS 26.5 CRASH SAGA), Phase 1 — Compatibility (P0), Phase 2 — Quick Wins (P1), Phase 3 — NSTextSelectionManager (P1), Phase 4 — Gesture Recognizer Migration (P2) (+7 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.12
Nodes (8): BrowserProgressLine, BrowserTabButton, Bool, Double, NSCoder, NSEvent, NSLayoutConstraint, NSRect

### Community 277 - ".run"
Cohesion: 0.15
Nodes (10): KeyRecorderRepresentable, String, Void, OverlayBackground, Context, OverlayBackground, Context, OverlayBackground (+2 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.18
Nodes (10): MainActor, Void, Group, PrefixCheatsheetWindow, PrefixIndicatorWindow, CGFloat, NSTextField, NSView (+2 more)

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.08
Nodes (28): AgentNotchDashboardProjection, AgentNotchProjection, AgentNotchRowSummary, RowKind, agent, session, Date, SessionGroup (+20 more)

### Community 280 - ".menu"
Cohesion: 0.25
Nodes (4): StatusLineWidthTests, StatusLineWidth, String, StyledSegment

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.12
Nodes (16): CodingKey, CodingKeys, description, key, showInBanner, CodingKeys, activeWorkspaceID, keepSessionsOnQuit (+8 more)

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.16
Nodes (8): BinaryInstaller, TimeInterval, BinaryInstaller.DetectionStatus, SetupStepView, Bool, String, URL, BinaryInstallerDisplayTests

### Community 283 - "FormatColor"
Cohesion: 0.24
Nodes (4): RGBColor, String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 284 - "click_ui_element"
Cohesion: 0.14
Nodes (11): KouenCLITests, URL, KouenCLI, KouenFilePreviewLoader, KouenViewError, binaryOrUnsupportedEncoding, missingPath, tooLarge (+3 more)

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.08
Nodes (24): After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md., After all done — update memory, Agent Prompt — P14 Browser Pane (PBI-001 through 005), Before writing any code, read:, code:swift (public struct BrowserLeaf: Codable, Sendable, Equatable {), code:swift (case let .browser(bl):), code:swift (// action: SplitPaneCoordinator openBrowserPane(url: URL(str), code:block4 (harnessBrowserOpen(url, direction?) → {paneId}) (+16 more)

### Community 288 - "AgentHookStrategy"
Cohesion: 0.18
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 290 - "Process"
Cohesion: 0.26
Nodes (5): Case, ReflowCorpusTests, String, TerminalEmulator, URL

### Community 291 - "JSONDecoder"
Cohesion: 0.20
Nodes (3): String, TerminalGridSnapshot, VTConformanceCorpusTests

### Community 292 - "Release runbook"
Cohesion: 0.25
Nodes (7): Full local signing path (needs a Developer ID cert; not currently used), Full pipeline reference (not implemented in this fork), How this fork actually releases, If the workflow existed: running a release, One-time GitHub setup, Release runbook, What that workflow would publish

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.16
Nodes (13): BoxDrawing, Kind, arms, dashH, dashV, halfDown, halfLeft, halfRight (+5 more)

### Community 294 - "GitHubCLIClient"
Cohesion: 0.11
Nodes (17): Agent Detection, Branch Detection Flow, Branch Label, Chrome Roles, Drag Reorder, File, Files, Git Branch Detection (+9 more)

### Community 295 - "AgentApprovalBar"
Cohesion: 0.11
Nodes (17): 1.1 Architecture, 1.2 Algorithm review, 1.3 Structure findings, 2.1 Structure, 2.2 Risk register (ranked), 3.1 Current implementation, 3.2 Why nothing shows (ranked root-cause candidates), 3.3 Fix plan (+9 more)

### Community 296 - "NotificationBus"
Cohesion: 0.22
Nodes (8): TerminalPaneRegistryAccess, KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, KouenTerminalKit

### Community 297 - "settings.json"
Cohesion: 0.17
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, Bool, Double (+3 more)

### Community 298 - "jobs"
Cohesion: 0.18
Nodes (6): ReleaseNotes, ReleaseNotes, Section, String, ReleaseNotesGuardTests, String

### Community 299 - "PaneNode"
Cohesion: 0.13
Nodes (15): BrowserRequestPayload, close, cookies, evaluate, goBack, goForward, interact, navigate (+7 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.25
Nodes (5): NotificationBus, SnapshotChangedPayload, Bool, Data, String

### Community 301 - ".parse"
Cohesion: 0.23
Nodes (3): ImageProtocolTests, String, TerminalEmulator

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.12
Nodes (16): Agent Config Wiring, Agents, Architecture, Browser Pane, File I/O, Git, Key Files, MCP Server (harness-mcp) (+8 more)

### Community 303 - ".encodeMouse"
Cohesion: 0.13
Nodes (12): DesktopNotifier, KouenPathDisplay, NotificationPresenter, Bool, MainActor, String, Void, UNNotification (+4 more)

### Community 305 - ".script"
Cohesion: 0.18
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.23
Nodes (8): Scanner, SVGPathParser, Bool, CGPath, CGPoint, Character, Set, CGMutablePath

### Community 308 - "Send Ex Command"
Cohesion: 0.26
Nodes (6): NSButton, NSImage, SidebarBadgeView, NSCoder, NSRect, NSPressGestureRecognizer

### Community 310 - "FrameSignposter"
Cohesion: 0.39
Nodes (3): data, SixelDecoder, UInt8

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.21
Nodes (11): clamp(), DotView, statusColor(), statusHelp(), Bool, Context, NSColor, String (+3 more)

### Community 312 - "AgentSnapshot"
Cohesion: 0.31
Nodes (4): BrowserPaneRegistry, NSWindow, PaneID, WeakBrowserPaneView

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.20
Nodes (7): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, FileChangeWatcherTests

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.18
Nodes (10): 2026-06-25 — OSC 7735:  opens sidebar file viewer, 2026-06-27 — Block output tint + AI explain (Phase 12b), Pruned from MEMORY.md — 2026-07-02, Pruned from MEMORY.md — 2026-07-03, Pruned from MEMORY.md — 2026-07-04, Pruned from MEMORY.md — 2026-07-06, Pruned from MEMORY.md — 2026-07-07, Pruned from MEMORY.md — 2026-07-08 (+2 more)

### Community 319 - "FormatColor"
Cohesion: 0.19
Nodes (6): Bool, Int32, String, URL, SystemdUserInstaller, ServiceInstallerTests

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.23
Nodes (4): Bool, String, TimeInterval, WorktreeInfo

### Community 321 - "UInt64"
Cohesion: 0.14
Nodes (11): os, Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow, launchStart (+3 more)

### Community 322 - "DesktopNotifier"
Cohesion: 0.23
Nodes (10): Array, SessionGroup, SessionSnapshot, Bool, Decoder, SessionID, String, Tab (+2 more)

### Community 323 - "LayoutNode"
Cohesion: 0.16
Nodes (9): Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSPoint, NSRect, TimeInterval (+1 more)

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.17
Nodes (4): ScrollbackTests, Character, String, TerminalGridSnapshot

### Community 325 - "FloatingPaneController"
Cohesion: 0.29
Nodes (3): KouenMCPServer, MCPServer, String

### Community 327 - ".theme"
Cohesion: 0.42
Nodes (5): PaneOutputWaiter, PaneOutputWaitResult, CheckedContinuation, Never, UInt64

### Community 328 - "README.md"
Cohesion: 0.36
Nodes (3): Install, Shell integration (OSC 133 semantic prompts), What gets emitted

### Community 330 - ".drawGlyph"
Cohesion: 0.21
Nodes (12): CellMetrics, ComposedFrame, CellMetrics, ComposedTerminalView, Bool, CellColorResolver, CGFloat, CGPoint (+4 more)

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.19
Nodes (7): PluginLoader, String, ScriptAPI, ScriptError, evaluationError, unsupportedPlatform, JavaScriptCore

### Community 333 - "RealPty"
Cohesion: 0.09
Nodes (18): RealPty, ScrollbackEntry, ScrollbackReplaySegment, ShellLaunchProfile, Bool, CChar, DaemonSurfaceID, Data (+10 more)

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.17
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

### Community 335 - ".makeModel"
Cohesion: 0.24
Nodes (7): LaunchdServiceInstaller, ServiceInstaller, ServiceInstallers, ServiceInstallReport, Bool, String, URL

### Community 336 - "run.sh"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 337 - "CommandExecutionError"
Cohesion: 0.05
Nodes (46): SidebarListModel, SidebarSessionRow, divider, groupHeader, session, worktree, worktreeHeader, SidebarWorktreeEntry (+38 more)

### Community 338 - "CSIParams"
Cohesion: 0.30
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 339 - "Foundation"
Cohesion: 0.08
Nodes (29): CoreGraphics, CoreText, ImageIO, KouenCopyMode, KouenTerminalEngine, KouenTerminalRenderer, KouenTheme, Metal (+21 more)

### Community 342 - "Added"
Cohesion: 0.27
Nodes (9): Array, Bool, Date, Decoder, PaneID, PaneNode, String, TabID (+1 more)

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.55
Nodes (5): AgentIconRenderer, CGFloat, NSColor, NSImage, String

### Community 344 - "FileViewerViewController"
Cohesion: 0.11
Nodes (15): FileViewerViewController, Bool, NSEvent, Set, String, URL, Void, LSPFileSession (+7 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.20
Nodes (7): ExperienceMode, agent, full, persistent, plain, Bool, Bool

### Community 349 - "Contents.json"
Cohesion: 0.27
Nodes (3): KouenSettingsTests, URL, Void

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.26
Nodes (5): KouenCLI, Bool, Int32, Never, String

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.20
Nodes (9): InterruptFlag, ReplayClient, ReplayPlayer, Bool, Data, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.13
Nodes (14): 1. @MainActor + Task + Process.waitUntilExit = FREEZE (RL-052), 2. @Observable + mutation in body = infinite re-render loop (RL-053), 3. Re-entrancy guard on rebuildRows, 4. Worktree display rules, Architecture, chromeEpoch — force SwiftUI re-render from static state, Critical Lessons (bugs fixed), File tree: root at git root, expand on CWD change (+6 more)

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.30
Nodes (6): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, agents

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.22
Nodes (8): 1. Performance Optimization: Scrollback Reflow ($O(\text{history})$ Complexity), 2. convenient Features: Local completion & completion Gutter, 3. IDE Convenient: Keyboard-driven Layout Presets, 4. AI integration: Secure Local ACP Sidebar, Additional features shipped alongside:, Context, Implementation Status (2026-06-11), P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)

### Community 355 - ".deepMerge"
Cohesion: 0.12
Nodes (19): SurfaceProgressTracker, Bool, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void, State (+11 more)

### Community 357 - ".handleCat"
Cohesion: 0.18
Nodes (8): RecordingEvent, input, metadata, output, resize, Date, Encoder, UInt16

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.29
Nodes (8): Never, Set, String, Task, URL, Void, WorkspaceSymbolIndex, NSRegularExpression

### Community 359 - "OcclusionTests"
Cohesion: 0.24
Nodes (6): HintModeOverlay, Any, KouenTerminalSurfaceView, NSEvent, NSView, String

### Community 360 - "State"
Cohesion: 0.21
Nodes (8): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus, UserNotifications

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.26
Nodes (4): String, TerminalGridCell, TextGrid, WordColumnRangeTests

### Community 362 - "RGBColor"
Cohesion: 0.16
Nodes (8): AppKit, MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, String

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.25
Nodes (4): KeybindingsService, Bool, Command, String

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.27
Nodes (6): Logger, OSSignposter, FrameSignposter, Bool, StaticString, UInt64

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.29
Nodes (4): NSCoder, NSHostingView, NSRect, TerminalTabBarView

### Community 366 - "Consumers"
Cohesion: 0.23
Nodes (8): agentDetail(), AgentInboxBody, AgentInboxPanelView, AgentInboxRowView, CGFloat, NSCoder, String, Void

### Community 367 - "DaemonStats"
Cohesion: 0.29
Nodes (8): BlockTintOverlay, Bool, CGFloat, KouenTerminalSurfaceView, NSCoder, NSEvent, NSPoint, NSRect

### Community 368 - "Tab"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 369 - "Git Panel"
Cohesion: 0.25
Nodes (4): AgentListFormatterTests, Bool, Date, String

### Community 370 - ".encode"
Cohesion: 0.19
Nodes (4): NotificationCenterProbe, Bool, Void, NotificationCenterProbeTests

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.17
Nodes (11): Architecture, code:block1 (PaneNode (existing binary tree)), Current State, Estimate, Goal, P13 — Embedded Browser Pane (cmux parity), PBI-BROWSER-001: BrowserPaneView + PaneNode integration, PBI-BROWSER-002: Persistence (+3 more)

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.11
Nodes (6): SessionID, GroupedSessionTests, SessionGroup, Set, SurfaceID, Phase67Tests

### Community 373 - "Prompt"
Cohesion: 0.21
Nodes (12): code:block1 (Add a visual session state indicator to sidebar session card), code:block2 (Add keyboard-driven layout presets to the Harness terminal a), code:block3 (Add workspace-scoped local completion (autocomplete) to the ), code:block4, Context, P10 Implementation Prompts — For Agent Execution, Prompt, Task #1: CMUX Session State Indicator in Sidebar (+4 more)

### Community 374 - ".run"
Cohesion: 0.22
Nodes (8): AnyObject, CommandExecutionError, daemonError, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor, String

### Community 375 - ".install"
Cohesion: 0.14
Nodes (11): Agent Memory Index — harness-terminal, Navigation, Edges, Files, Knowledge Index — Harness Terminal, Search Instructions, Source Map, Case Index (+3 more)

### Community 376 - "ScrollReuseTests"
Cohesion: 0.14
Nodes (13): ACP (Agent Client Protocol) — tried, shelved, erased, Command Palette / Power-User Terminal Features, Embedded Browser, Feature Provenance — harness-terminal, Git Panel, Harness MCP, IDE Track — File Tree / Editor / LSP (the "Zed half" made real), Notifications (+5 more)

### Community 377 - "Identifiable"
Cohesion: 0.11
Nodes (15): Identifiable, CompleteStepView, Void, DiscoverStepView, Point, String, OnboardingStep, complete (+7 more)

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.14
Nodes (13): 1. Data / Geometry Separation (primary fix), 2. SnapshotCoalescer (cmux NotificationBurstCoalescer pattern), 3. Equality Guard on updateGeometry (Zed pattern), 4. Dirty Flag on setFrame (Otty/WezTerm pattern), 5. GPU Animation — CAShapeLayer Mask (Zed/Otty GPU path), 6. AgentScanner timer split, Files, Fixes Applied (layered) (+5 more)

### Community 379 - "MCPServer"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 380 - "PromptQueue"
Cohesion: 0.26
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.18
Nodes (7): Error, Bool, NSView, String, TimeInterval, Toast, ToastBody

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.40
Nodes (9): attribute_lines(), main(), redraw_frames(), repeated_chunk(), run_case(), sgr_lines(), truecolor_gradient(), unicode_lines() (+1 more)

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.27
Nodes (6): DisplayPanesOverlay, Any, NSEvent, NSView, SurfaceID, Void

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.19
Nodes (10): DiffLineType, added, deleted, modified, Notification.Name, NSCoder, NSRect, NSTextView (+2 more)

### Community 388 - "Darwin"
Cohesion: 0.19
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 389 - "HarnessCLITests"
Cohesion: 0.18
Nodes (8): Kind, input, metadata, output, resize, Decoder, KeyedDecodingContainer, String

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.24
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.36
Nodes (3): BrowserIntegrationController, NSView, PaneID

### Community 402 - "View"
Cohesion: 0.11
Nodes (28): Color, Configuration, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, ButtonStyle, CommandRow, GlassCard, GlassPrimaryButtonStyle (+20 more)

### Community 403 - "themes.json"
Cohesion: 0.42
Nodes (6): InstallResult, ShellCompletionInstaller, Bool, String, URL, ShellIntegration

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.23
Nodes (8): string, AgentNotification, OSCNotificationParser, DaemonSurfaceID, Data, Date, String, SurfaceID

### Community 405 - ".measure"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 406 - "main.swift"
Cohesion: 0.28
Nodes (7): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor, NSView

### Community 408 - "IPC Architecture"
Cohesion: 0.22
Nodes (7): PasteController, Bool, Data, NSPasteboard, String, TimeInterval, URL

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.17
Nodes (7): ResizeHUDView, DispatchWorkItem, NSCoder, NSColor, NSPoint, NSRect, TimeInterval

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.10
Nodes (19): Agent Prompt — Harness Terminal UI Fixes, code:block1 (▶ harness-terminal), code:block2 (▼ harness-terminal  ● Running), code:swift (urlTextField.setContentHuggingPriority(.defaultLow, for: .ho), code:swift (let bv = BrowserPaneView(url: bl.url, paneID: bl.id)), code:bash (cd /Users/supavit.cho/Git/Personal/harness-terminal), code:bash (git add -A), Commit (+11 more)

### Community 412 - "go.json"
Cohesion: 0.28
Nodes (4): PaneLabelDaemonTests, String, URL, UUID

### Community 415 - "markdown.json"
Cohesion: 0.15
Nodes (12): Architecture, Browser DevTools API (P28), Config, Key Bug Fixed: Round-Trip Timeout (RL-048), Key Files, Phase 1 — Core (all via evaluateJS or WKWebView native), Phase 2 — Network, Phase 3 — Storage (+4 more)

### Community 416 - "python.json"
Cohesion: 0.15
Nodes (12): Bug: Tab-Switch Black Screen, Files changed, Final fast-path guard (PaneLifecycleManager.swift), FM-1: detachHostsOnly() before caching (always broken), FM-2: force=true rebuild caches the stripped container, FM-3: Host theft by another tab's build, FM-4: Cache overwrite leaks orphan containers, Instrumentation method (+4 more)

### Community 417 - "rust.json"
Cohesion: 0.20
Nodes (9): SettingsTerminalView, Bool, String, TriState, auto, off, on, Typography (+1 more)

### Community 418 - "swift.json"
Cohesion: 0.20
Nodes (10): PaneRef, bottom, byID, byIndex, last, left, next, previous (+2 more)

### Community 419 - "typescript.json"
Cohesion: 0.15
Nodes (12): #list-count, #sessions-main, #sessions-sheet, #sheet, #sheet-backdrop, #sheet-count, #term-body, #term-title (+4 more)

### Community 422 - "HintModeOverlay"
Cohesion: 0.26
Nodes (5): Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 423 - "CopyModeLine"
Cohesion: 0.13
Nodes (7): ControlKeyNormalizer, Bool, String, ShortcutRecorderSerializer, String, ControlKeyNormalizerTests, ShortcutRecorderSerializerTests

### Community 424 - "HarnessCore"
Cohesion: 0.31
Nodes (6): AnimatablePair, NotchShape, CGFloat, CGPath, CGRect, Path

### Community 425 - "AgentVectorIcon"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 428 - "P9: Code Complexity Reduction & Structural Refactoring"
Cohesion: 0.18
Nodes (10): 1. HarnessTerminalSurfaceView (~2,320 LOC), 2. HarnessCLI.swift (~1,841 LOC), 3. WindowAttachClient (~1,566 LOC), 4. SurfaceRegistry (~1,848 LOC), 5. GridCompositor Duplication, Context, Execution Order, Execution Status (2026-06-11) (+2 more)

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.29
Nodes (3): BellScanTests, Bool, UInt8

### Community 431 - "P6: File Editor Opacity Parity with Terminal"
Cohesion: 0.22
Nodes (8): Actual Fix (2026-06-09), code:swift (panel.layer?.backgroundColor = c.terminalBackground), code:swift (private func refreshEditorPanelFill() {), Fix Approach, P6: File Editor Opacity Parity with Terminal, Problem, Root Cause (hypothesis), Status

### Community 432 - ".initialState"
Cohesion: 0.36
Nodes (3): SplitDirection, TabID, TerminalTabBarDelegate

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.17
Nodes (10): CAMediaTimingFunction, KouenOnboarding, Bool, ImmersiveOnboardingWindowController, ImmersivePanel, ImmersiveRootView, Any, Bool (+2 more)

### Community 434 - "Project History"
Cohesion: 0.29
Nodes (3): Bool, String, ThaiClusterRenderTests

### Community 436 - "WaitForRegistry"
Cohesion: 0.17
Nodes (11): ACP vs MCP vs Terminal Chat, AgentProcessManager, Architecture, CLI Print-Mode Args, Context Injection, Key Files, Key Shortcuts (I-family), Non-Obvious Constraints (+3 more)

### Community 437 - "Feature Specs"
Cohesion: 0.25
Nodes (8): F1: Mobile Package Targets — P0, F2: Network Endpoint for IPC — P0, F3: Pairing and Trust — P0, F4: UIKit Terminal Surface — P0, F5: iPad Workspace UX — P1, F6: Remote Session Lifecycle — P1, F7: Files and Sharing — P2, Feature Specs

### Community 438 - "SessionEditor"
Cohesion: 0.09
Nodes (15): IndexingIterator, LayoutTemplate, SessionEditor, Command, Double, PaneID, PaneLeaf, PaneNode (+7 more)

### Community 439 - "ACP Client"
Cohesion: 0.29
Nodes (7): ACP Client, Architecture, code:block1 (AgentChatPanelView (AppKit UI)), Key Files, Protocol, Shelved Status (June 2025), Tool Call Handling

### Community 440 - "Implementation Phases"
Cohesion: 0.25
Nodes (8): Implementation Phases, Phase 0 — Feasibility Spike (P0), Phase 1 — Shared Renderer Extraction (P0), Phase 2 — Mobile IPC Transport (P0), Phase 3 — UIKit Terminal MVP (P0), Phase 4 — iPad App Shell (P1), Phase 5 — Multiplexer Parity (P1), Phase 6 — Polish and Platform Integration (P2)

### Community 441 - "RemoteHostStore"
Cohesion: 0.17
Nodes (11): 1. `SessionLifecycleService.swift` (tab bar clicks, sidebar clicks), 2. `MainExecutor.swift` (keyboard shortcuts — the actual user path), Competitive research (from Agy), Data model (correct, no changes needed), Files to read before resuming, Fix applied (compiles, not fully tested), Focus Persistence — Per-Session-Tab Pane Focus (RL-043), Restoration flow (after fix) (+3 more)

### Community 443 - "main.swift"
Cohesion: 0.31
Nodes (8): daemonLog(), detectStaleInstance(), installSignalHandlers(), removeForeignPIDFile(), removePIDFile(), Sendable, String, writePIDFile()

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.31
Nodes (4): CLIInstaller, Bool, String, URL

### Community 445 - "Section"
Cohesion: 0.38
Nodes (3): SettingsAdvancedView, Bool, String

### Community 448 - "NSSplitView Patterns"
Cohesion: 0.40
Nodes (5): code:swift (private var isApplyingPositions = false), Infinite Recursion Guard (CASE-006), Key Invariants, NSSplitView Patterns, Safe Subview Reorder (CASE-007)

### Community 449 - ".run"
Cohesion: 0.16
Nodes (4): AgentScanner, DispatchSourceTimer, AgentSnapshot, AgentSessionSummaryTests

### Community 450 - "RecordSession"
Cohesion: 0.22
Nodes (6): TabStatus, done, error, idle, running, waiting

### Community 451 - "IPCRequest"
Cohesion: 0.36
Nodes (6): BrowserCookie, IPCRequest, Bool, Double, SplitDirection, URL

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Kouen-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 453 - ".update"
Cohesion: 0.29
Nodes (5): NotchMaskAnimator, Bool, CGFloat, CGRect, NSView

### Community 455 - "ComposerPanel"
Cohesion: 0.17
Nodes (10): center, ComposerPanel, Bool, NSEvent, NSTextView, NSWindow, Selector, String (+2 more)

### Community 457 - "StartupMetrics"
Cohesion: 0.32
Nodes (3): ReplayStep, Data, TerminalRecordingCodec

### Community 459 - ".encode"
Cohesion: 0.25
Nodes (5): CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab

### Community 461 - "PaneLabelDaemonTests"
Cohesion: 0.19
Nodes (6): SessionStore, DispatchWorkItem, SessionSnapshot, TimeInterval, SessionSnapshot, Set

### Community 462 - "AGENTS.md"
Cohesion: 0.13
Nodes (13): Architecture, Build & test, Coding constraints, Communication: GUI ↔ Daemon ↔ CLI, Generated files (do not hand-edit), Graphify + agent-memory, IPC safety, Package map (+5 more)

### Community 464 - "MouseButton"
Cohesion: 0.25
Nodes (8): MouseButton, left, middle, right, wheelDown, wheelLeft, wheelRight, wheelUp

### Community 465 - "DirectionalAxis"
Cohesion: 0.29
Nodes (5): DirectionalAxis, down, left, right, up

### Community 466 - "ReflowFastPathTests"
Cohesion: 0.15
Nodes (7): OnboardingController, KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, OnboardingEnvironmentTests

### Community 467 - "─────────────────────────────────────────────────────"
Cohesion: 0.12
Nodes (15): ─────────────────────────────────────────────────────, Agent Prompt — P14 PBI-BROWSER-001 + 002, BrowserPaneView shell + PaneNode integration, code:swift (public struct BrowserLeaf: Codable, Sendable, Equatable {), code:swift (case let .browser(browserLeaf):), code:block3 (feat(p14): PBI-BROWSER-001/002 — BrowserPaneView + PaneNode ), Constraints, ContentAreaViewController.swift — PaneContainerView.build() (+7 more)

### Community 471 - ".evaluateStyled"
Cohesion: 0.36
Nodes (5): ShellInfo, ShellStepView, Bool, String, URL

### Community 473 - "HarnessOnboarding"
Cohesion: 0.14
Nodes (9): GridCompositorParityTests, LiveCompositorFixture, Bool, String, TerminalGridSnapshot, PortCompositorFixture, Bool, String (+1 more)

### Community 476 - ".steps"
Cohesion: 0.38
Nodes (4): AnyObject, TimeInterval, ZombieHoldRegistry, ObjectIdentifier

### Community 478 - ".install"
Cohesion: 0.40
Nodes (5): FluidityBenchmarks, KouenTerminalSurfaceView, NSWindow, String, UInt64

### Community 479 - "ScrollbackTests"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, String, TerminalEmulator

### Community 480 - "Command Prompt Architecture"
Cohesion: 0.31
Nodes (3): ReflowPreviewTests, String, TerminalEmulator

### Community 490 - "P7: Sidebar UI Polish — Large Screen Layout"
Cohesion: 0.40
Nodes (4): Fix Approach, P7: Sidebar UI Polish — Large Screen Layout, Problems, Status

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.33
Nodes (3): KouenTerminalSurfaceWorkerTests, Bool, KouenTerminalSurfaceView

### Community 493 - "Browser Tab Close Button Unresponsive"
Cohesion: 0.18
Nodes (10): 1. SurfaceShellTracker (proc tree walk), 2. DaemonSyncService.startMetadataRefresh (5-s loop), 3. snapshotChanged Fanout, 4. PerfCounters — Instrumentation, 5. Performance Lessons (v3.2.0), Adaptive polling, Background Polling & Snapshot Fanout — P22, Known Non-P22 Callers of syncFromDaemon (+2 more)

### Community 495 - "terminal-cheat-sheet.html"
Cohesion: 0.18
Nodes (10): AI / Agent Connectivity, Architecture Decisions — harness-terminal, Browser Pane, Config / Settings, File Preview / Split Panes, IPC / Daemon, Keybindings, Sessions / Tabs (+2 more)

### Community 496 - "CASE — Git / FS / Terminal / Architecture"
Cohesion: 0.18
Nodes (10): Cause 1 — `existingHosts` strong dict in TerminalPaneRegistry (DOMINANT), Cause 2 — Insert-only AI controller dicts in SessionCoordinator, Cause 3 — Uncapped browser network capture array, Memory Leak Audit — 34 GB Long-Session Case (2026-06-26), Pattern to watch: "insert-only per-surface dict", Release, Root causes found and fixed, Symptom (+2 more)

### Community 498 - "SystemdUserInstaller"
Cohesion: 0.18
Nodes (10): Burst Coalescing (cmux NotificationBurstCoalescer), CA Mask Pattern (Harness Notch), Combine → CA Bridge, Equality Guard (Zed layout phase), GPU Animation Pattern — Layout Once, GPU Paints, Layer Coordinate System, Principle, References (+2 more)

### Community 500 - "RemoteHostsService"
Cohesion: 0.60
Nodes (4): CLICommand, CLICommandCatalog, Bool, String

### Community 501 - "Fixed"
Cohesion: 0.24
Nodes (5): Bool, NSObjectProtocol, Set, String, WorktreeAutoIsolateService

### Community 502 - "ACP Client (Shelved)"
Cohesion: 0.32
Nodes (4): BrowserTab, UUID, WKWebView, tabs

### Community 506 - "KittyGraphicsCommand"
Cohesion: 0.20
Nodes (10): Section, actions, errors, files, grep, navigation, projects, recent (+2 more)

### Community 507 - "ThaiClusterCopyTests.swift"
Cohesion: 0.20
Nodes (9): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, ownJSONFile, ownTextFile, regionEdit, Any, Bool (+1 more)

### Community 509 - "start.mjs"
Cohesion: 0.70
Nodes (4): main(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 510 - "graphify reference: extra exports and benchmark"
Cohesion: 0.13
Nodes (7): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Float, Carbon

### Community 511 - "State"
Cohesion: 0.57
Nodes (5): Codable, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserSnapshot

### Community 513 - "ThemeDocument"
Cohesion: 0.20
Nodes (6): LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.14
Nodes (11): WKNavigation, BrowserPaneViewTests, MockWebView, Bool, URL, WKNavigation, WebKit, WKNavigationAction (+3 more)

### Community 521 - "PasteController"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 522 - "ShellCompletionInstallerTests"
Cohesion: 0.27
Nodes (6): AmbientBackground, Bool, CGSize, GraphicsContext, TimeInterval, UInt8

### Community 526 - "Kind"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 527 - "Agent hooks for Harness"
Cohesion: 0.29
Nodes (7): Agent hooks for Kouen, CLI notification, Example Claude Code hook, Jump to waiting agent, OSC sequences (from terminal output), Per-agent guides, Set up via your IDE (copy/paste prompt)

### Community 530 - "HarnessChrome"
Cohesion: 0.29
Nodes (8): FormatColor, none, palette, rgb, StyledSegment, Bool, String, UInt8

### Community 531 - ".text"
Cohesion: 0.62
Nodes (3): AgentListFormatter, Date, String

### Community 534 - "ANSIPalette"
Cohesion: 0.48
Nodes (3): ANSIPalette, RGBColor, UInt8

### Community 535 - "AgentNotification"
Cohesion: 0.24
Nodes (4): GroupedSessionDaemonTests, SessionGroup, String, URL

### Community 537 - "TabAlertTests"
Cohesion: 0.31
Nodes (5): OcclusionTests, KouenTerminalSurfaceView, NSWindow, String, TimeInterval

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.09
Nodes (15): RepoGitMetadata, SessionDividerRowView, SessionGroupHeaderRowView, SessionWorktreeHeaderRowView, SessionWorktreeRowView, BoardColumnKind, Bool, NSColor (+7 more)

### Community 542 - "SemanticPromptTests"
Cohesion: 0.44
Nodes (3): KouenCLI, SessionID, String

### Community 544 - "Task Ledger Archive (Tasks 1–50)"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 545 - "get_window_count"
Cohesion: 0.20
Nodes (9): 1. Sidebar toggle (⌘\), 2. File preview open/close, 3. Tab switch (⌘1-9, ✕ close), 4. presentsWithTransaction order fix (ALL remaining flash cases) — v3.9.x+, Fixes Applied (v3.9.1+), Related Lessons, Root Cause Pattern, Rules (+1 more)

### Community 546 - "LegacySnapshot"
Cohesion: 0.10
Nodes (14): JSONDecoder, JSONEncoder, LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab (+6 more)

### Community 547 - "NSObject"
Cohesion: 0.13
Nodes (16): ClosureTarget, MenuActionTarget, OverlayWindow, Phase67UI, PopupWindow, Bool, Command, NSEvent (+8 more)

### Community 548 - ".encode"
Cohesion: 0.20
Nodes (9): 1. Board Sidebar Tab (GUI), 2. Harness CLI Command, 3. Scripting API, 4. Read-Only MCP Tool, Agent/Session Board (P16), Centralized Classification, Consumers, Data Model (PBI-BOARD-001) (+1 more)

### Community 550 - "cheat.sh"
Cohesion: 0.20
Nodes (9): Architecture, Branch chip — CASE-020, Features, FSEvents Pattern (Swift Actor), Git Panel, History → File Editor, Real-time Refresh, v1 — CASE-009 (resolved, superseded) (+1 more)

### Community 552 - "[3.12.0] - 2026-06-30"
Cohesion: 0.36
Nodes (5): PaneLeaf, SessionGroup, Any, String, Tab

### Community 553 - "harness.resource"
Cohesion: 0.16
Nodes (3): GitPanelView, Any, NSMenuItem

### Community 558 - "ThemeCatalogEmbedTests"
Cohesion: 0.27
Nodes (3): DaemonReconnectPolicy, TimeInterval, DaemonReconnectPolicyTests

### Community 559 - "Source"
Cohesion: 0.33
Nodes (5): Source, activePane, activeTab, focusedPane, focusedSurface

### Community 566 - "TerminalTabBarView.swift"
Cohesion: 0.21
Nodes (9): CGFloat, Date, Range, Tab, TabBarLayoutMetrics, TabPillView, TerminalTabBarBody, TerminalTabBarModel (+1 more)

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.09
Nodes (21): CommandHistorySearchController, HistoryItemView, HistoryRowView, SearchPanel, Bool, CGFloat, NSAttributedString, NSCoder (+13 more)

### Community 574 - "CLAUDE.md"
Cohesion: 0.12
Nodes (11): HitTestPassthroughView, PaneContainerView, NSCoder, NSPoint, NSView, PaneID, PaneNode, SessionSnapshot (+3 more)

### Community 576 - "[3.10.0] - 2026-06-27"
Cohesion: 0.42
Nodes (5): LoadCompletionState, CheckedContinuation, Error, TimeInterval, Void

### Community 578 - "TerminalProgressReport"
Cohesion: 0.11
Nodes (17): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, FileTreeContext, Bool (+9 more)

### Community 579 - "DecoKind"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 580 - "P4 — LSP + File View (Code Preview in Sidebar)"
Cohesion: 0.15
Nodes (15): Architecture, Components, Estimate, Files, Goal, Grammars, Implementation Notes (MVP — plain-text viewer), LSP Discovery (+7 more)

### Community 581 - "Current Sprint — Post-v2.1.0 Polish & Shelving"
Cohesion: 0.40
Nodes (5): Current Sprint — Post-v2.1.0 Polish & Shelving, Decisions_In_Force, Recent_Lessons, Removed / Reverted Features, Task_Ledger

### Community 582 - "FileTreeKeyboardNavigator"
Cohesion: 0.15
Nodes (11): BrowserLeaf, PaneNode, branch, browser, leaf, Double, PaneID, PaneLeaf (+3 more)

### Community 584 - ".detect"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 586 - "[3.8.0] - 2026-06-22"
Cohesion: 0.28
Nodes (6): KouenTerminalSurfaceView, Bool, NSEvent, ViInputMode, insert, normal

### Community 587 - "LayoutTemplate"
Cohesion: 0.20
Nodes (5): invalidConfiguration, String, RemoteHostStoreTests, String, URL

### Community 589 - "Endpoint"
Cohesion: 0.33
Nodes (4): GridCompositorCopyModeTests, PaneRect, String, TerminalGridSnapshot

### Community 591 - "NodeRow"
Cohesion: 0.47
Nodes (3): ScrollReuseTests, KouenTerminalSurfaceView, NSWindow

### Community 594 - "KeyRecorderView.swift"
Cohesion: 0.28
Nodes (5): SpecialKeyMappingTests, Bool, NSEvent, String, UInt16

### Community 596 - "prepare-release.sh"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 598 - ".load"
Cohesion: 0.22
Nodes (8): CASE-063a — sound toggle, CASE-063b — click doesn't route, Files, Fix Applied, If Fix Is Insufficient, Notification Sound Toggle Ignored + Banner Click Didn't Navigate, Root Cause, Symptom

### Community 599 - ".cgPath"
Cohesion: 0.22
Nodes (8): Detection Method, Fix, NSTextField Leak in BoardViewController (P20 Performance), Prevention Rules, Related Files, Root Cause, Symptom, Why CPU Goes Up

### Community 600 - "HarnessTerminalSurfaceView"
Cohesion: 0.10
Nodes (15): NSRangePointer, NSTextInputClient, KouenTerminalSurfaceView, Any, Bool, NSAttributedString, NSEvent, NSPoint (+7 more)

### Community 603 - "MenuBarController"
Cohesion: 0.13
Nodes (15): AgentRow, AgentRow, MenuBarController, MenuRef, CGFloat, NSImage, NSMenu, NSMenuItem (+7 more)

### Community 608 - ".testRenderEncodeIncrementalDamage160x48"
Cohesion: 0.22
Nodes (8): Accessibility Requirements, Files, Permission, Running, Stack, Test Strategy, UI Automation — Robot Framework (P18), Why Not Appium

### Community 613 - "INDEX.md"
Cohesion: 0.25
Nodes (4): Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions

### Community 614 - "MainSplitViewController"
Cohesion: 0.13
Nodes (12): MainSplitViewController, SplitChromeDelegate, Bool, CADisplayLink, CGFloat, NSColor, NSRect, NSSplitView (+4 more)

### Community 617 - "ScriptFileWatcher"
Cohesion: 0.22
Nodes (8): AppKit / Views, Architecture / Daemon, Browser / WKWebView, Git / Process, Notifications / UserNotifications, RL Lessons — harness-terminal, Swift 6 / Concurrency, Testing / Environment

### Community 618 - "CommandFinishedTests"
Cohesion: 0.22
Nodes (8): AppKit + Metal Patterns, CADisplayLink Lifetime on macOS (CASE-031), Metal Surface Lifecycle (CASE-003), Mouse Selection Must Use Virtual-Line Coordinates (CASE-029), NSFont Italic (CASE-010), NSView Layer Opacity — Preview Parity Pattern (CASE-011), Overlay Above Metal (CASE-004), Window Background Tint for Legibility (CASE-027)

### Community 619 - "commit-push-merge.sh"
Cohesion: 0.22
Nodes (8): Architecture, Infinite Recursion (CASE-006), Pane Drag-and-Drop (P27), Ratio Persistence (CASE-002), Split CWD Resolution — Worktree Priority (2026-06-21), Split Panes (NSSplitView), Subview Reorder (CASE-007), Two-Axis Split Parity (P13)

### Community 621 - "ViEngine"
Cohesion: 0.07
Nodes (8): Bool, String, ViEngine, KouenCLI, KouenLSP, QuickLookUI, UInt16, ViPathTokenTests

### Community 622 - "[1.3.0-vit] - 2026-06-06"
Cohesion: 0.20
Nodes (5): StageToggleButton, NSButton, NSCoder, NSRect, NSUserInterfaceItemIdentifier

### Community 624 - "[2.5.0] - 2026-06-12"
Cohesion: 0.32
Nodes (4): CopyModeLine, Character, ClosedRange, String

### Community 626 - "NotificationCoordinator"
Cohesion: 0.22
Nodes (9): CodingKeys, cols, createdAt, dataBase64, rows, surfaceID, timeMs, type (+1 more)

### Community 627 - "ActiveTabCloseDisposition"
Cohesion: 0.16
Nodes (6): OutputTrigger, OutputTriggerStore, Bool, String, PendingMainHop, Data

### Community 629 - "graphify reference: query, path, explain"
Cohesion: 0.32
Nodes (6): CGFloat, ResizeDirection, down, left, right, up

### Community 630 - "[3.0.0] - 2026-06-15"
Cohesion: 0.29
Nodes (7): DiagnosticCheck, DiagnosticStatus, fail, pass, warn, DoctorReport, Int32

### Community 637 - "PriorInstanceDecision"
Cohesion: 0.50
Nodes (4): PriorInstanceDecision, proceed, refuse, stale

### Community 641 - "[3.10.0] - 2026-06-27"
Cohesion: 0.25
Nodes (7): #kouen, #practice, #score, #shell, #total, #unix, #vim

### Community 646 - "[3.10.1] - 2026-06-27"
Cohesion: 0.46
Nodes (3): SessionSnapshot, Tab, WorkbenchContextResolverTests

### Community 648 - "PtyDrainCeilingBenchmark"
Cohesion: 0.22
Nodes (10): Counter, DrainResult, DrainState, EchoRTT, PtyDrainCeilingBenchmark, Bool, DispatchSemaphore, Double (+2 more)

### Community 650 - "[3.11.0] - 2026-06-28"
Cohesion: 0.16
Nodes (7): Bool, NSEvent, NSRange, NSString, Void, SyntaxTextView, NSPopover

### Community 654 - "press_shortcut"
Cohesion: 0.36
Nodes (3): BlockContextMenuTests, KouenTerminalSurfaceView, String

### Community 655 - "CodingKeys"
Cohesion: 0.25
Nodes (7): Framing, IPC Architecture, Key Invariant, Overview, Process Separation, Security, Subscriptions

### Community 656 - "Proposal: Merging Devin/Windsurf Kanban & CMUX Multiplexer UX into Harness"
Cohesion: 0.29
Nodes (6): 1. Summary of Davin/Windsurf Kanban + CMUX UX, 2.1 Sidebar Sessions Panel Enhancements, 2.2 Per-Session Top Bar / Tab Strip Enhancements, 2. Integration Proposal for Harness, 3. Concrete File-Level Change List, Proposal: Merging Devin/Windsurf Kanban & CMUX Multiplexer UX into Harness

### Community 658 - "[3.1.0] - 2026-06-15"
Cohesion: 0.25
Nodes (7): ⌘1-9 and ⌘[ / ⌘] = Session-level navigation (CASE-028), Data Model, Session/Tab/Pane Hierarchy & Top Bar (CASE-028), Sidebar Session Groups = One Header Per SessionGroup, Source Map, Tab Pill Visual Details, Top Bar = 1 Pill Per Session (not per-tab)

### Community 659 - ".decode"
Cohesion: 0.25
Nodes (7): Bug — Cmd+\ sidebar toggle gone after collapse, Confirmed facts, Fix, Related, Suspect A — Dead token guard (confirmed code bug), Suspect B — Zero-delta early exit trap, Symptom

### Community 660 - "NotificationEntry"
Cohesion: 0.25
Nodes (7): Case: cwd "bleed" — session worktree jumps to wrong dir during builds, Companion bug: blank panel on first open (CASE-042), Fix, Lesson, Repro (deterministic, headless — no GUI needed), Root cause, Symptom

### Community 661 - "Remote SSH — Market Comparison"
Cohesion: 0.33
Nodes (5): Kouen vs Competitors (Remote Development over SSH), Our Gaps (vs leaders), Our Strengths, Remote SSH — Market Comparison, Roadmap Opportunities

### Community 662 - "New Tab"
Cohesion: 0.25
Nodes (7): Competitive Position (as of v3.12.0, 2026-07-02), Feature Matrix (2026-07-02), Harness Gaps, Harness Wins, Known Limitations (honest assessment), Positioning Statement, Unique Selling Points (no competitor has all)

### Community 663 - "[3.1.2] - 2026-06-16"
Cohesion: 0.25
Nodes (7): Apple Platform Context — Transparency & Legibility, Architecture Decisions, iOS/macOS 26 — Liquid Glass introduction, iOS/macOS 27 — Liquid Glass refinements (WWDC 2026), Known Issues (Current), Project History, Sprint Timeline

### Community 665 - "PathToken"
Cohesion: 0.20
Nodes (10): BrowserResponsePayload, cookies, error, network, ok, open, screenshot, snapshot (+2 more)

### Community 666 - ".handle"
Cohesion: 0.29
Nodes (5): NotificationEntry, SessionID, SurfaceID, TabID, WorkspaceID

### Community 668 - "[3.8.0] - 2026-06-22"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 669 - ".recordReapedGenerationForTesting"
Cohesion: 0.12
Nodes (9): String, WorkbenchMRU, Foundation, KouenSettings, Bool, Data, KouenCLI, String (+1 more)

### Community 670 - "[3.9.1] - 2026-06-22"
Cohesion: 0.15
Nodes (16): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+8 more)

### Community 671 - "AgentKind"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 672 - "WriteOutcome"
Cohesion: 0.50
Nodes (4): WriteOutcome, complete, failed, wouldBlock

### Community 674 - "P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable"
Cohesion: 0.22
Nodes (8): Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phases, Risk review (ranked), Verification gates (every phase)

### Community 675 - ".detect"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 676 - "[2.1.0] - 2026-06-07"
Cohesion: 0.33
Nodes (3): String, URL, ThemeCatalogEmbedTests

### Community 678 - "FilePreviewCoordinator"
Cohesion: 0.29
Nodes (6): Command Prompt Architecture, Files, Gotchas, Key rule: every documented verb needs BOTH layers, Layers, Verb categories

### Community 679 - "[3.5.0] - 2026-06-20"
Cohesion: 0.29
Nodes (6): Anti-Patterns Avoided, Architecture, Key Design Decisions, Pattern, Service Decomposition — SessionCoordinator (P17), When to Apply This Pattern

### Community 680 - "HarnessCLI+Workbench.swift"
Cohesion: 0.29
Nodes (6): Browser Tab Close Button Unresponsive, Files, Fix Applied, If Fix Is Insufficient, Root Cause, Symptom

### Community 681 - "Cross-terminal output-stress benchmark"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 682 - "TreeSitterGrammarBundle"
Cohesion: 0.29
Nodes (6): Architecture / Keybindings, CASE — Git / FS / Terminal / Architecture, Claude Code / Tooling / Environment (the agent running *inside* Harness), Command Prompt / Parser, Git / File System, Terminal / Renderer / Daemon

### Community 684 - "[3.9.5] - 2026-06-26"
Cohesion: 0.29
Nodes (6): ACP Client (Shelved), Architecture (Preserved), Re-enablement Criteria, Status: SHELVED (June 2026), What It Is, Why Shelved

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 686 - ".status"
Cohesion: 0.29
Nodes (6): Build Scripts Self-Kill Protection, Detection, Fix (applied in `Scripts/run.sh`), Key Invariant, Problem, Related

### Community 689 - ".findLeaf"
Cohesion: 0.50
Nodes (3): PaneID, PaneLeaf, PaneNode

### Community 692 - ".testOptionLinesAreNotCommands"
Cohesion: 0.40
Nodes (3): KouenGridTerminal, TerminalGridCell, TerminalEmulator

### Community 693 - "[2.0.0] - 2026-06-07"
Cohesion: 0.33
Nodes (5): Claude Code → Kouen, Customizing, One-line install, Verifying, What gets written

### Community 694 - "TerminalScreen"
Cohesion: 0.53
Nodes (3): ProjectConfig, Bool, String

### Community 696 - "generate-release-notes.swift"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 700 - "Modifiers"
Cohesion: 0.07
Nodes (24): DisplayWidth, String, Unicode, Run, Data, ReleaseNotes, String, TerminalBanner (+16 more)

### Community 708 - "[3.4.0] - 2026-06-19"
Cohesion: 0.33
Nodes (5): Codex Fix Prompt Template, FSEvents Recursive Watcher Pattern (Swift), Full Swift Actor Pattern, Single-file watch (DispatchSource is enough), When to use

### Community 709 - "ScreenPos"
Cohesion: 0.40
Nodes (5): Build matrix, Integration tests, Manual test checklist, Testing and Verification, Unit tests

### Community 710 - "MainWindowController"
Cohesion: 0.11
Nodes (13): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+5 more)

### Community 711 - "FileTabManager"
Cohesion: 0.25
Nodes (8): Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06), Explicitly not in this MVP, Revised MVP: Web/PWA Terminal (P0 — current focus), Scope, Scope revision (2026-07-06): "full version, minus split screen", Spike result (2026-07-04): transport hypothesis confirmed over LAN, Web/PWA MVP — Phased Build Plan (2026-07-06), Why this order

### Community 713 - "HarnessBrowserTools"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 715 - "TerminalProgressReport"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 720 - ".printBoard"
Cohesion: 0.32
Nodes (4): WeakScriptMessageHandler, WKScriptMessage, WKScriptMessageHandler, WKUserContentController

### Community 727 - "PromptQueueBar"
Cohesion: 0.50
Nodes (3): __kouen_osc133_postexec, __kouen_osc133_preexec, __kouen_osc133_prompt

### Community 728 - "[2.5.1] - 2026-06-12"
Cohesion: 0.50
Nodes (3): Grok Build → Kouen, One-line install, What you'll see

### Community 732 - "ReplayStep"
Cohesion: 0.50
Nodes (3): SplitDirection, horizontal, vertical

### Community 737 - ".resolve"
Cohesion: 0.50
Nodes (3): #connect, #log, #term

### Community 742 - "Phase67Tests"
Cohesion: 0.50
Nodes (4): ShapedGlyphSignature, CGFloat, CGGlyph, String

### Community 744 - "TerminalGridCellLayoutTests"
Cohesion: 0.50
Nodes (3): exclude_hubs, no_viz, wiki

### Community 745 - "p11_scripting.robot"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 764 - "Workbench commands (IDE-like workflow)"
Cohesion: 0.33
Nodes (6): Board and attention, Errors and LSP, File navigation, Search, Task runner, Workbench commands (IDE-like workflow)

### Community 804 - "graphify reference: GitHub clone and cross-repo merge"
Cohesion: 0.47
Nodes (5): AgentIconArt, AgentVectorIcon, Bool, CGSize, String

### Community 1117 - "Required Architectural Decisions"
Cohesion: 0.50
Nodes (4): D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Required Architectural Decisions

### Community 1647 - "Changed"
Cohesion: 0.40
Nodes (4): Dispatch, Charset, ascii, decSpecialGraphics

### Community 3419 - "Page"
Cohesion: 0.27
Nodes (5): AboutPanelController, AboutView, MonoPillButtonStyle, Configuration, NSWindow

### Community 3515 - "RawRepresentable"
Cohesion: 0.15
Nodes (16): KeySpec, Binding, CodingKeys, bindings, disabledSpecs, id, tables, KeyTable (+8 more)

## Knowledge Gaps
- **3732 isolated node(s):** `unsupportedPlatform`, `unmodified`, `modified`, `added`, `deleted` (+3727 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **2472 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `AboutView`, `AgentActivity`, `AgentApprovalBar`, `AgentInboxBody`, `AgentInboxPanelView` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `.encode` to `CodingKey`, `callingPaneTarget`, `Changelog Archive`, `EngineConformanceTests`, `IPCRequest`, `AgentNotchRootView`, `Command`, `LSPMessage`, `PasteController`, `TerminalEmulator`, `GitPanelView.swift`, `PerformanceBenchmarks`, `VTParser`, `HarnessTerminalSurfaceView`, `.applyPreedit`, `HarnessUILibrary`, `.text`, `HarnessChrome`, `HarnessTerminalSurfaceView`, `CopyModeAction`, `ANSIPalette`, `SpecialKey`, `WorktreeManager`, `SessionGroupHeaderRowView`, `RGBColor`, `.parse`, `.request`, `Notification`, `Sendable`, `.addTab`, `Equatable`, `LegacySnapshot`, `Task Ledger Archive (Tasks 1–50)`, `TerminalColorGamut`, `harness.resource`, `HarnessSidebarPanelViewController.swift`, `RenderSchedulerTests`, `CodingKeys`, `HarnessTerminalSurfaceView.swift`, `.buildCommand`, `.normalizedKey`, `ThemeCatalogEmbedTests`, `DaemonServer`, `.keyEvent`, `HarnessSplitView`, `TerminalTabBarView.swift`, `TabCell`, `BellScanState`, `CommandHistorySearchController`, `newWindow`, `PasteBufferStore`, `FrecencyDirectoryStore`, `ComposedCell`, `HarnessCLI+Server.swift`, `.text`, `PrefixKeymap`, `TerminalProgressReport`, `String`, `worktree_isolation_cli.robot`, `XCTestCase`, `LayoutTemplate`, `.parse`, `OptionStore`, `Endpoint`, `HarnessDesign`, `selectWorkspace`, `LSPClient`, `TerminalGridCell`, `HarnessPaths`, `HarnessTerminalSurfaceView`, `TerminalModes`, `MenuBarController`, `AttachInputBatcher`, `shim.c`, `.dispatch`, `ScriptRuntime.swift`, `MainSplitViewController`, `DaemonLauncher`, `Recipe`, `AgentNotchViewModel`, `.resolve`, `DamageTrackingTests`, `SoftIconButton`, `[2.5.0] - 2026-06-12`, `.makeSnapshot`, `.firstWaitingTab`, `ActiveTabCloseDisposition`, `SessionGroup`, `graphify reference: query, path, explain`, `WorkspaceFileTreeView`, `String`, `HistoryRingBuffer`, `.path`, `GlyphAtlas`, `SwiftUI`, `.install`, `AgentHookInstaller`, `PtyDrainCeilingBenchmark`, `ActivePaneService`, `[3.11.0] - 2026-06-28`, `AsciiFastPathTests`, `DecodedImage`, `HarnessDaemonToolsTests`, `What You Must Do When Invoked`, `LiveResizeTests`, `Int`, `ThaiCombiningMarkTests`, `[3.3.0] - 2026-06-18`, `[3.9.1] - 2026-06-22`, `MatchCategory`, `.recordReapedGenerationForTesting`, `TerminalFindBar`, `CommandPromptController`, `ActiveTabCloseDisposition`, `LiveSession`, `URLDetection`, `[1.5.1] - 2026-06-06`, `BinaryRefresherTests`, `InlineAICompletionView`, `[3.13.1] - 2026-07-02`, `.testOptionLinesAreNotCommands`, `VTConformanceCorpusTests`, `GridCompositorTests`, `LSPServerRegistry`, `generate-release-notes.swift`, `SessionSnapshot`, `Error`, `AppDelegate`, `Modifiers`, `BrowserPaneView`, `ScriptRuntime`, `GlyphRasterizer`, `BinaryInstaller`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `ResizeHUDView`, `AgentSessionSummary`, `.classify`, `HarnessBrowserTools`, `[3.9.5] - 2026-06-26`, `.testDataFrameEncodeVsJSONBase64Output`, `SettingsRemoteView`, `PaneTarget`, `.translate`, `NotchLayoutMetrics`, `.lines`, `CellColorResolverTests`, `AgentNotchRowSummary`, `graphify reference: add a URL and watch a folder`, `HarnessPathDisplay`, `FileChangeWatcher`, `CellColorResolver`, `Phase67Tests`, `ExternalOpenKind`, `WorkbenchCommand`, `PaneBorderStatus`, `[3.5.1] - 2026-06-20`, `.make`, `ReflowPreviewTests`, `HarnessTerminalSurfaceWorkerTests`, `SessionCoordinator`, `NSViewRepresentable`, `Split Right`, `BoardViewController`, `release-hotfix.sh`, `workspace`, `Sidebar SwiftUI Migration — Knowledge`, `listSurfaces`, `ThemeFileServiceTests`, `.install`, `HarnessSidebarPanelViewController`, `.userNotificationCenter`, `.path`, `.performInstall`, `[2.2.4] - 2026-06-11`, `[3.11.2] - 2026-06-28`, `DefaultTerminalManager`, `StatusLineView.swift`, `SGRMouseEvent`, `WindowSession`, `[2.5.0] - 2026-06-12`, `renumberWindows`, `DisplayPanesOverlay`, `.menu`, `.rememberTabForReopen`, `RemoteHostStoreTests`, `FormatColor`, `click_ui_element`, `AgentHookStrategy`, `StatusLineWidthTests`, `Process`, `JSONDecoder`, `Fixes Applied (layered)`, `NotificationBus`, `settings.json`, `HarnessPaths.swift`, `.parse`, `RegressionBugFixTests`, `ViPathTokenTests`, `.scrollWheel`, `FrameSignposter`, `DesktopNotifier`, `LayoutNode`, `WorkspaceSymbolIndex`, `worktree_isolation.robot`, `.theme`, `ImmersivePalette.swift`, `.drawGlyph`, `RealPty`, `CommandExecutionError`, `Foundation`, `Added`, `[2.2.3] - 2026-06-09`, `FileViewerViewController`, `Background Polling & Snapshot Fanout — P22`, `.deepMerge`, `SurfaceProgressTracker`, `.handleCat`, `[3.5.1] - 2026-06-20`, `OcclusionTests`, `FormatStyledSegment.swift`, `generate-cheatsheet.js`, `projectGroupRootPath`, `[2.2.4] - 2026-06-11`, `DaemonStats`, `DynamicInstanceBuffer`, `Identifiable`, `NSTextField Leak in BoardViewController (P20 Performance)`, `SKILL-LOG.md`, `HarnessCLITests`, `UI Automation — Robot Framework (P18)`, `.measure`, `IPC Architecture`, `Session/Tab/Pane Hierarchy & Top Bar (CASE-028)`, `swift.json`, `HintModeOverlay`, `CopyModeLine`, `.initialState`, `Project History`, `SessionEditor`, `IPCRequest`, `StartupMetrics`, `MouseButton`, `HarnessOnboarding`, `ScrollbackTests`, `Command Prompt Architecture`, `printThemePreview`, `requireSessionID`, `resolvedCLIPath`, `ACP Client (Shelved)`, `KittyGraphicsCommand`, `State`?**
  _High betweenness centrality (0.279) - this node is a cross-community bridge._
- **Why does `Foundation` connect `.recordReapedGenerationForTesting` to `Changelog Archive`, `callingPaneTarget`, `.handleNormal`, `ThemeDocument`, `CodingKey`, `IPCRequest`, `AgentNotchRootView`, `KouenIPC`, `LSPMessage`, `PasteController`, `PerformanceBenchmarks`, `TerminalEmulator`, `VTParser`, `.applyPreedit`, `HarnessChrome`, `SpecialKey`, `CopyModeAction`, `.request`, `RGBColor`, `Task Ledger Archive (Tasks 1–50)`, `DaemonClient`, `MenuTarget`, `TerminalColorGamut`, `[3.12.0] - 2026-06-30`, `CodingKeys`, `HarnessSidebarPanelViewController.swift`, `Harness Robot Framework Tests`, `.buildCommand`, `Source`, `HookEvent`, `.normalizedKey`, `markPane`, `.keyEvent`, `BellScanState`, `PasteBufferStore`, `FrecencyDirectoryStore`, `ComposedCell`, `HarnessCLI+Server.swift`, `.text`, `ShellIntegration`, `String`, `FileTreeKeyboardNavigator`, `.detect`, `OptionStore`, `.parse`, `TerminalProtocolCompatibilityTests`, `Endpoint`, `DaemonSubscription`, `LSPClient`, `LSPDiagnostic`, `TerminalGridCell`, `SessionCoordinator`, `AttachInputBatcher`, `.dispatch`, `DaemonLauncher`, `AnyCodable`, `Recipe`, `Changelog`, `AgentNotchViewModel`, `.resolve`, `DamageTrackingTests`, `Changed`, `.makeSnapshot`, `HarnessGridTerminal`, `.firstWaitingTab`, `ActiveTabCloseDisposition`, `SessionGroup`, `PaneNode`, `[3.0.0] - 2026-06-15`, `.encode`, `HistoryRingBuffer`, `AgentHookInstaller`, `graphify reference: query, path, explain`, `PtyDrainCeilingBenchmark`, `ActivePaneService`, `TerminalHostView`, `CopyModeGridSource`, `AsciiFastPathTests`, `DecodedImage`, `FileTreeWatcher`, `EnvironmentStore`, `HarnessDaemonToolsTests`, `.evaluate`, `What You Must Do When Invoked`, `LiveResizeTests`, `Int`, `[3.9.1] - 2026-06-22`, `AgentKind`, `MatchCategory`, `Workspace`, `CommandPromptController`, `ActiveTabCloseDisposition`, `[2.1.0] - 2026-06-07`, `AgentTableEntry`, `LiveSession`, `URLDetection`, `.decodeKeySpec`, `.hold`, `InlineAICompletionView`, `[3.13.1] - 2026-07-02`, `GridCompositorTests`, `TerminalScreen`, `Error`, `Modifiers`, `BrowserPaneView`, `GlyphRasterizer`, `BinaryInstaller`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `BinaryInstallerVersionTests`, `MCP Server (harness-mcp)`, `PaletteModel`, `HarnessBrowserTools`, `TerminalProgressReport`, `grok`, `.testDataFrameEncodeVsJSONBase64Output`, `SettingsRemoteView`, `PaneDropZoneOverlay`, `PaneTarget`, `.translate`, `SessionLifecycleService`, `NotchLayoutMetrics`, `.lines`, `CellColorResolverTests`, `GridCompositor`, `Section`, `ReplayStep`, `AgentNotchRowSummary`, `ANSIPalette`, `CellColorResolver`, `HarnessPathDisplay`, `SSHTunnelManagerTests`, `sessionRow`, `.decide`, `HarnessGridTerminalTests`, `ExternalOpenKind`, `graphify reference: incremental update and cluster-only`, `.scan`, `.make`, `.copySelection`, `PaneBorderStatus`, `TerminalMetalRenderer`, `AgentBridge`, `FileNode`, `ThemeDocumentTests`, `.renderFixture`, `ReflowPreviewTests`, `HarnessTerminalSurfaceWorkerTests`, `Split Right`, `BundledThemesData.swift`, `Sidebar SwiftUI Migration — Knowledge`, `Browser Pane (P14)`, `.install`, `SGRMouseEvent`, `reorderSession`, `DisplayPanesOverlay`, `FormatColor`, `click_ui_element`, `JSONDecoder`, `.load`, `NotificationBus`, `settings.json`, `jobs`, `HarnessPaths.swift`, `.parse`, `.script`, `.selectedText`, `FrameSignposter`, `Browser DevTools API (P28)`, `Terminal AI Chat (⌘I inline overlay)`, `.unmarkText`, `FormatColor`, `Focus Persistence — Per-Session-Tab Pane Focus (RL-043)`, `UInt64`, `DesktopNotifier`, `FloatingPaneController`, `.theme`, `.reopenClosedTab`, `.recordReapedGenerationForTesting`, `RealPty`, `ImageProtocolTests.swift`, `.makeModel`, `CommandExecutionError`, `Foundation`, `Added`, `[3.2.0] - 2026-06-16`, `Architecture Decisions — harness-terminal`, `GPU Animation Pattern — Layout Once, GPU Paints`, `.deepMerge`, `State`, `generate-cheatsheet.js`, `Tab`, `.encode`, `.run`, `MCPServer`, `User Profile`, `Darwin`, `themes.json`, `Split Panes (NSSplitView)`, `.measure`, `javascript.json`, `json.json`, `HintModeOverlay`, `CopyModeLine`, `Competitive Position (as of v3.12.0, 2026-07-02)`, `.highlight`, `RawRepresentable`, `BlockContextMenuTests`, `main.swift`, `.run`, `RecordSession`, `StartupMetrics`, `.encode`, `PaneLabelDaemonTests`, `ReflowFastPathTests`, `.evaluateStyled`, `HarnessOnboarding`, `.steps`, `Service Decomposition — SessionCoordinator (P17)`, `RemoteHostsService`, `Fixed`, `ThaiClusterCopyTests.swift`, `State`?**
  _High betweenness centrality (0.034) - this node is a cross-community bridge._
- **Why does `KouenCore` connect `WindowTitleStripView` to `CodingKey`, `callingPaneTarget`, `graphify reference: extra exports and benchmark`, `AgentNotchRootView`, `KouenIPC`, `TerminalEmulator`, `KittyKeyboardTests`, `.applyPreedit`, `HarnessUILibrary`, `SpecialKey`, `CopyModeAction`, `SplitPaneCoordinator`, `AgentNotification`, `WorktreeManager`, `SessionGroupHeaderRowView`, `.request`, `Task Ledger Archive (Tasks 1–50)`, `LegacySnapshot`, `NSObject`, `MenuTarget`, `String`, `TerminalColorGamut`, `[3.12.0] - 2026-06-30`, `CodingKeys`, `HarnessSettings`, `Harness Robot Framework Tests`, `.normalizedKey`, `HookEvent`, `DaemonServer`, `.keyEvent`, `HarnessSplitView`, `NSPanel`, `BellScanState`, `CommandHistorySearchController`, `ViEngine`, `ComposedCell`, `HarnessCLI+Server.swift`, `.text`, `TerminalProgressReport`, `ShellIntegration`, `FileTreeKeyboardNavigator`, `XCTestCase`, `LayoutTemplate`, `.parse`, `TerminalProtocolCompatibilityTests`, `Endpoint`, `LSPClient`, `LSPDiagnostic`, `TerminalGridCell`, `SessionCoordinator`, `MenuBarController`, `AttachInputBatcher`, `shim.c`, `PaneContainerView`, `MainSplitViewController`, `AgentNotchViewModel`, `NSView`, `ViEngine`, `SoftIconButton`, `.resolve`, `DamageTrackingTests`, `.firstWaitingTab`, `SessionGroup`, `PaneNode`, `clearSelection`, `ViEngine`, `Pipe`, `.install`, `.load`, `[3.10.1] - 2026-06-27`, `PtyDrainCeilingBenchmark`, `ActivePaneService`, `.testPaneLeafLegacyDecodeBackfillsSurfaceTabs`, `CopyModeGridSource`, `FileTreeWatcher`, `EnvironmentStore`, `HarnessDaemonToolsTests`, `What You Must Do When Invoked`, `ThaiCombiningMarkTests`, `.recordReapedGenerationForTesting`, `sessionCreated`, `TerminalFindBar`, `Workspace`, `LiveSession`, `ReflowCorpusTests`, `.decodeKeySpec`, `BoardCard`, `RGBColorTests`, `.rects`, `InlineAICompletionView`, `Phase6KeysTests`, `GridCompositorTests`, `AppDelegate`, `Modifiers`, `ScriptRuntime`, `[2.3.0] - 2026-06-11`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `ResizeHUDView`, `[2.5.1] - 2026-06-12`, `BinaryInstaller`, `.classify`, `BinaryInstallerVersionTests`, `MCP Server (harness-mcp)`, `PaletteModel`, `CopyModeState`, `scheduleRender`, `PaneDropZoneOverlay`, `SessionLifecycleService`, `.lines`, `CellColorResolverTests`, `GridCompositor`, `ScrollbackFile`, `Section`, `AgentNotchRowSummary`, `ANSIPalette`, `SSHTunnelManagerTests`, `sessionRow`, `graphify reference: incremental update and cluster-only`, `TextGrid`, `.scan`, `WorkbenchCommand`, `.make`, `AgentBridge`, `.make`, `FileNode`, `ThemeDocumentTests`, `.renderFixture`, `ReflowPreviewTests`, `[3.4.0] - 2026-06-19`, `HarnessTerminalSurfaceWorkerTests`, `BoardViewController`, `Sidebar SwiftUI Migration — Knowledge`, `ThemeFileServiceTests`, `.welcome`, `Browser Pane (P14)`, `StatusLineView.swift`, `SGRMouseEvent`, `reorderSession`, `BlockTintOverlay`, `DisplayPanesOverlay`, `CLICommand`, `.menu`, `click_ui_element`, `.apply`, `.load`, `NotificationBus`, `jobs`, `.encodeMouse`, `RegressionBugFixTests`, `.selectedText`, `Browser DevTools API (P28)`, `Bug: Tab-Switch Black Screen`, `AgentSnapshot`, `FormatColor`, `FloatingPaneController`, `.theme`, `.recordReapedGenerationForTesting`, `RealPty`, `ImageProtocolTests.swift`, `CommandExecutionError`, `CSIParams`, `Foundation`, `DaemonLifecycleTests`, `Architecture Decisions — harness-terminal`, `GPU Animation Pattern — Layout Once, GPU Paints`, `.deepMerge`, `State`, `FormatStyledSegment.swift`, `RGBColor`, `generate-cheatsheet.js`, `Consumers`, `Tab`, `Git Panel`, `.encode`, `DynamicInstanceBuffer`, `Identifiable`, `NSTextField Leak in BoardViewController (P20 Performance)`, `SKILL-LOG.md`, `User Profile`, `Darwin`, `UI Automation — Robot Framework (P18)`, `AppKit + Metal Patterns`, `IPC Architecture`, `go.json`, `rust.json`, `FilePreviewCoordinatorTabScopeTests`, `HintModeOverlay`, `CopyModeLine`, `Bug — Cmd+\ sidebar toggle gone after collapse`, `.delay`, `.highlight`, `SessionEditor`, `main.swift`, `BlockContextMenuTests`, `Section`, `.run`, `ReflowFastPathTests`, `HarnessOnboarding`, `Fixed`, `graphify reference: extra exports and benchmark`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **Are the 45 inferred relationships involving `Int` (e.g. with `.register()` and `.coloredImage()`) actually correct?**
  _`Int` has 45 INFERRED edges - model-reasoned connections that need verification._
- **What connects `unsupportedPlatform`, `unmodified`, `modified` to the rest of the system?**
  _3752 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.10083256244218317 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.05228105228105228 - nodes in this community are weakly interconnected._