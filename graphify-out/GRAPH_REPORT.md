# Graph Report - kouen-terminal  (2026-09-09)

## Corpus Check
- 791 files · ~909,206 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 19209 nodes · 50810 edges · 2221 communities (613 shown, 1608 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 7491 edges (avg confidence: 0.73)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `cbcf7fa0`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 343 edges
2. `i()` - 321 edges
3. `a()` - 284 edges
4. `t()` - 253 edges
5. `SessionCoordinator` - 231 edges
6. `TerminalEmulator` - 229 edges
7. `u()` - 219 edges
8. `SurfaceRegistry` - 200 edges
9. `IPCRequest` - 193 edges
10. `SessionEditor` - 180 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `KouenPaths` - bridges 60 areas (135 edges)
2. `SessionCoordinator` - bridges 56 areas (231 edges)
3. `SessionSnapshot` - bridges 45 areas (167 edges)
4. `SurfaceRegistry` - bridges 42 areas (200 edges)
5. `i()` - bridges 41 areas (321 edges)
6. `Process` - bridges 41 areas (89 edges)
7. `AgentKind` - bridges 38 areas (112 edges)
8. `KouenTerminalSurfaceView` - bridges 37 areas (343 edges)
9. `Notification` - bridges 37 areas (63 edges)
10. `a()` - bridges 35 areas (284 edges)

## Surprising Connections (you probably didn't know these)
- `.selectedHost` --references--> `RemoteHost`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRemoteView.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/RemoteHostsService.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.selectWorkspace(byIndex:)` --references--> `SessionSnapshot`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/SessionCoordinator.swift → Packages/KouenIPC/Sources/KouenIPC/SessionSnapshot.swift
- `ThemeImportController` --calls--> `ThemeFileService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/ThemeImportController.swift → Packages/KouenTheme/Sources/KouenTheme/ThemeFileService.swift

## Import Cycles
- None detected.

## Communities (2221 total, 1608 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.12
Nodes (45): aVe(), b(), Bje(), cVe(), DJt(), dzt(), FR(), gJt() (+37 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.12
Nodes (14): TerminalDamage, RenderColor, MetalRendererTests, .makeRenderer(device:atlasSize:atlasMaxPages:), RenderedFixture, Bool, MTLDevice, MTLTexture (+6 more)

### Community 2 - ".handleNormal"
Cohesion: 0.20
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 4 - "EngineConformanceTests"
Cohesion: 0.10
Nodes (11): DaemonRoundTripTests, String, TimeInterval, URL, RealPtyLifecycleTests, AtomicCounter, .value, OutputAccumulator (+3 more)

### Community 5 - "IPCRequest"
Cohesion: 0.07
Nodes (24): String, UInt16, UUID, DecodedReplyFrame, output, reply, DecodedRequestFrame, input (+16 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.09
Nodes (29): AnyTransition, Color, .hexString, AgentNotchPeekEvent, AgentNotchRootView, .body, .bottomRadius, .closedAccessibilityLabel (+21 more)

### Community 7 - "Command"
Cohesion: 0.08
Nodes (31): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+23 more)

### Community 8 - "LSPMessage"
Cohesion: 0.12
Nodes (12): .tab(containingPaneID:), .tab(forSurfaceKey:), .tabIndex(surfaceKey:), .tabIndex(workspaceID:tabID:), Bool, Date, SessionID, String (+4 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.11
Nodes (9): PerformanceBenchmarks, SurfaceOffMainStallSample, Bool, Data, Double, String, UInt64, UInt8 (+1 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.08
Nodes (23): IndexingIterator, LayoutTemplate, surfaceID, SessionEditor, .addSurface(tabID:paneID:), .addSurface(to:paneID:surfaceID:cwd:), .split(node:targetPaneID:direction:paneCount:before:), .split(node:targetPaneID:with:direction:beforeTarget:) (+15 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.09
Nodes (12): SessionCoordinator, Bool, Double, PaneID, PaneNode, SessionID, SplitDirection, String (+4 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.05
Nodes (33): SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, SessionID, SplitDirection (+25 more)

### Community 14 - "VTParser"
Cohesion: 0.15
Nodes (10): StringKind, apc, dcs, Data, UInt8, UnsafeBufferPointer, VTParser, .feed(_:) (+2 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.11
Nodes (15): StatusLineView, .init(coder:), CGFloat, FormatColor, Never, NSAttributedString, NSCoder, NSColor (+7 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.05
Nodes (42): Decodable, AssistantLine, ClaudeCodeHarness, Message, Profile, edit, readonly, ResultLine (+34 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.13
Nodes (11): ScrollbackFile, .highWater, Bool, Data, DispatchTime, DispatchWorkItem, TimeInterval, URL (+3 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.10
Nodes (25): DaemonSubscription, .start(onData:onEnd:buffered:), .start(onResponse:onEnd:), Bool, Data, Int32, TimeInterval, UInt64 (+17 more)

### Community 19 - "SpecialKey"
Cohesion: 0.10
Nodes (19): CodingKeys, error, id, jsonrpc, method, params, result, LSPDiagnostic (+11 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.24
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.08
Nodes (36): aR(), cKt(), cYt(), dC(), DGt(), dm(), ece(), FRt() (+28 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.01
Nodes (495): _0t(), _1n(), _2t(), _3n(), _5e(), _5n(), _6e(), _6n() (+487 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.27
Nodes (9): OptionStore, Scope, global, pane, session, workspace, ScopedKey, URL (+1 more)

### Community 24 - ".request"
Cohesion: 0.07
Nodes (19): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, PaneID, SurfaceID (+11 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.09
Nodes (16): DaemonCommandExecutor, Command, BellScanState, esc, normal, string, stringEsc, PanePipe (+8 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.15
Nodes (10): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, Set, SurfaceID (+2 more)

### Community 27 - "RGBColor"
Cohesion: 0.15
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 28 - ".parse"
Cohesion: 0.17
Nodes (7): ParsedShortcut, .displayString, PrefixKeymap, Any, NSEvent, String, TimeInterval

### Community 30 - "Notification"
Cohesion: 0.09
Nodes (8): Bool, String, UInt8, UnsafeBufferPointer, TerminalEmulator, .captureLines(fromLine:toLine:), ImageProtocolTests, String

### Community 31 - "Sendable"
Cohesion: 0.13
Nodes (13): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+5 more)

### Community 32 - ".addTab"
Cohesion: 0.14
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 33 - "Equatable"
Cohesion: 0.11
Nodes (15): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, PaneID (+7 more)

### Community 34 - "DaemonClient"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 35 - "MenuTarget"
Cohesion: 0.17
Nodes (3): TerminalGridCell, TerminalGridSnapshot, ThaiCombiningMarkTests

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.14
Nodes (28): Cleanup Test Repo, Close Isolated Session Keeps Dirty Worktree, Close Isolated Session Removes Clean Worktree, Close One Isolated Does Not Affect Another, Close Session With Split Panes Removes Worktree, Create Isolated Session, Create Isolated Session Via CLI, Get Active Pane (+20 more)

### Community 37 - "String"
Cohesion: 0.08
Nodes (24): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSEvent (+16 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.18
Nodes (13): BrowserOkAck, ConnectionState, .authorized, .browserPaneID, .deviceID, .snapshotSubscription, .subscription, .surfaceID (+5 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.16
Nodes (3): Data, String, TerminalBannerTests

### Community 41 - "CodingKeys"
Cohesion: 0.13
Nodes (19): ClientRecord, CountBox, DaemonServer, .guiBrowserFD, PendingBrowserRequest, PendingWrite, .remaining, Bool (+11 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.14
Nodes (18): CommandParseError, .description, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand (+10 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.07
Nodes (31): Ac(), agt(), aoe(), bR(), c8n(), cae(), cAn(), cht() (+23 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.14
Nodes (10): Process, SSHTunnelManager, .init(makeTunnelProcess:reachabilityProbe:), Bool, TimeInterval, URL, Tunnel, SSHTunnelManagerTests (+2 more)

### Community 46 - ".buildCommand"
Cohesion: 0.07
Nodes (28): EndpointError, connectionFailed, .description, notYetSupported, pathTooLong, String, EndpointConnector, Int32 (+20 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.15
Nodes (12): Array, GroupHeaderRow, .body, RecipePanel, .canBecomeKey, RecipePickerController, RecipePickerView, .body (+4 more)

### Community 48 - "HookEvent"
Cohesion: 0.13
Nodes (14): Executor, Hook, HookEvent, HookRegistry, Bool, Command, URL, UUID (+6 more)

### Community 49 - "DaemonServer"
Cohesion: 0.06
Nodes (40): CommandTarget, Command, .targetKind, PaneRef, bottom, byID, byIndex, last (+32 more)

### Community 51 - ".keyEvent"
Cohesion: 0.11
Nodes (26): ColorKind, .base, bg, fg, underline, CompositorPane, GridCompositor, .render(panes:status:statusSegments:) (+18 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.23
Nodes (5): Bool, Character, NSRange, NSTextView, String

### Community 55 - "TabCell"
Cohesion: 0.17
Nodes (6): AnyCodable, JSONRPCError, Bool, Int32, String, ToolRegistry

### Community 56 - "NSPanel"
Cohesion: 0.16
Nodes (10): QuickTerminalController, QuickTerminalPanelDelegate, Any, Bool, NSEvent, NSPanel, NSRect, NSScreen (+2 more)

### Community 57 - "BellScanState"
Cohesion: 0.13
Nodes (12): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+4 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.09
Nodes (39): MTLClearColor, MTLCommandBuffer, MTLLibrary, MTLRenderCommandEncoder, MTLRenderPipelineState, BgInstance, CursorCacheKey, .invertsGlyph (+31 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.09
Nodes (9): String, KouenSidebarPanelViewController, CGFloat, NSMenuItem, NSView, String, String, SidebarTitlebarHeaderView (+1 more)

### Community 60 - "ViEngine"
Cohesion: 0.14
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.14
Nodes (20): ComposedCell, .asGridCell, .init(_:), .init(codepoint:fg:bg:underlineColor:bold:dim:italic:underline:blink:inverse:invisible:strikethrough:overline:), .scalar, .sgr, CompositorPane, GridCompositor (+12 more)

### Community 62 - "ComposedCell"
Cohesion: 0.28
Nodes (5): SpecialKeyMappingTests, Bool, NSEvent, String, UInt16

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.14
Nodes (11): Buffer, .preview, Configuration, PasteBufferStore, Bool, Data, Date, String (+3 more)

### Community 64 - ".text"
Cohesion: 0.14
Nodes (15): CGFloat, NSHostingView, Range, Tab, TabBarLayoutMetrics, .pitch, TerminalTabBarBody, .body (+7 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.12
Nodes (5): KouenThemeCatalog, .allThemes, String, KouenThemeCatalogTests, ThemeDiagnosticsTests

### Community 67 - "String"
Cohesion: 0.13
Nodes (17): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+9 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.26
Nodes (3): BellScanTests, Bool, UInt8

### Community 69 - ".compose"
Cohesion: 0.11
Nodes (5): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess, Carbon, KouenTerminalKit

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.11
Nodes (24): RepoGitMetadata, SidebarListModel, SidebarSessionRow, divider, groupHeader, .id, session, worktree (+16 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 72 - "XCTestCase"
Cohesion: 0.02
Nodes (360): l, em(), _4n(), a7n(), a_n(), abn(), ace(), act() (+352 more)

### Community 73 - "README.md"
Cohesion: 0.50
Nodes (3): Hermes → Kouen, One-line install, Required: approve the hook

### Community 75 - "OptionStore"
Cohesion: 0.11
Nodes (15): ExperienceMode, agent, .displayName, .foregroundsAgents, full, .notchEnabledByDefault, persistent, .persistsSessionsByDefault (+7 more)

### Community 76 - ".parse"
Cohesion: 0.16
Nodes (10): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab, UUID (+2 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.23
Nodes (6): EnvironmentStore, Persisted, String, URL, EnvironmentStoreTests, URL

### Community 79 - "HarnessDesign"
Cohesion: 0.08
Nodes (25): MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem, SessionGroup (+17 more)

### Community 80 - "Agent handbook — Harness (extended reference)"
Cohesion: 0.25
Nodes (8): Agent Memory, Build / Test / Run, Graphify, graphify, kouen-terminal — Claude Instructions, Non-obvious Constraints, Session Start, Skills

### Community 81 - "DaemonSubscription"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 82 - ".firstMatch"
Cohesion: 0.10
Nodes (12): .receive(_:), FluidityBenchmarks, NSWindow, String, UInt64, KouenTerminalSurfaceWorkerTests, Bool, LiveResizeTests (+4 more)

### Community 83 - "LSPClient"
Cohesion: 0.12
Nodes (8): String, LSPDefinitionPayload, LSPDiagnosticsPayload, LSPStatusPayload, String, UInt64, URL, Set

### Community 84 - "LSPDiagnostic"
Cohesion: 0.14
Nodes (14): CGFloat, NSCoder, SessionID, String, Void, TaskDashboardBody, .body, TaskDashboardView (+6 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.10
Nodes (20): Error, ExpressibleByStringLiteral, StringError, .init(_:), .init(stringLiteral:), LSPClient, LSPClientError, missingPipe (+12 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.16
Nodes (8): FileEditorView, Bool, NSEvent, String, URL, FileEditorViewQuickLookRoutingTests, String, URL

### Community 87 - "SessionCoordinator"
Cohesion: 0.15
Nodes (14): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+6 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.14
Nodes (19): BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, CodingKeys, description, key (+11 more)

### Community 89 - ".cursorPos"
Cohesion: 0.16
Nodes (4): hooks, AgentHookInstallerTests, String, URL

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.14
Nodes (11): pipe, termios, AttachClient, Configuration, LiveSession, Bool, Data, DispatchSourceSignal (+3 more)

### Community 91 - "TerminalModes"
Cohesion: 0.08
Nodes (13): EditorDividerView, .init(coder:), PaneDragGripView, .init(coder:), PaneHoverButton, PaneSplitButtonsView, .init(coder:), .init(tabID:paneID:) (+5 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.14
Nodes (13): AgentTableEntry, MatchSource, ownProcess, wrapperLaunch, RawMatch, Bool, Set, String (+5 more)

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.07
Nodes (17): Int, HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor, Bool, ClosedRange (+9 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.19
Nodes (9): C, AttachInputBatcher, .hasPending, Outcome, Bool, Data, UInt8, AttachInputBatcherTests (+1 more)

### Community 95 - "shim.c"
Cohesion: 0.13
Nodes (16): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerModel, DirectoryPickerView, .body (+8 more)

### Community 96 - "Harness Usage"
Cohesion: 0.17
Nodes (9): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, FormatColor, String (+1 more)

### Community 97 - "PaneContainerView"
Cohesion: 0.12
Nodes (14): PendingVersionBanner, welcome, whatsNew, State, Bool, String, URL, VersionBannerStore (+6 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.15
Nodes (10): HitTestPassthroughView, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), .init(paneID:), NSPoint, NSView, PaneID, PaneNode (+2 more)

### Community 99 - ".dispatch"
Cohesion: 0.10
Nodes (28): TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid, TerminalTextRenderingMode (+20 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.09
Nodes (18): requestFailed, FileHandle, LSPMessage, notification, request, response, Decoder, Encoder (+10 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.11
Nodes (24): .color, Collection, .aggregateBoardStatus, .taskTooltipSummary, SessionGroup, .sessionBoardStatus, BoardCard, BoardColumn (+16 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.09
Nodes (23): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+15 more)

### Community 104 - "Recipe"
Cohesion: 0.10
Nodes (25): Bool, UInt8, TerminalCellWidth, normal, spacerTail, wide, TerminalCursor, TerminalCursorShape (+17 more)

### Community 105 - "Changelog"
Cohesion: 0.09
Nodes (15): AgentListFormatter, Date, String, JSONOutputFormatter, Bool, String, T, dvn() (+7 more)

### Community 106 - "domain-design.md"
Cohesion: 0.09
Nodes (25): aNt(), bNt(), bu(), cNt(), dNt(), dwn(), eNt(), eRe() (+17 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 108 - ".resolve"
Cohesion: 0.02
Nodes (267): pe(), r, X(), A(), code(), R(), z(), a() (+259 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.13
Nodes (8): SGRMouse, SGRMouseEvent, Bool, PaneRect, UInt8, SGRMouseTests, String, UInt8

### Community 110 - "SoftIconButton"
Cohesion: 0.18
Nodes (6): CopyModeReducerTests, FakeGrid, .totalLines, Set, String, TerminalGridCell

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.24
Nodes (4): CSIParams, .count, TerminalGridColor, UInt8

### Community 112 - ".makeSnapshot"
Cohesion: 0.26
Nodes (5): KeyTokenParser, Bool, Data, String, KeyTokenParserTests

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.10
Nodes (20): .windowSection, CaseIterable, KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:claudeAPIKey:inlineAICompletion:terminalShaderEffect:browserHomePage:), .init(from:), ResizeOverlayMode, afterFirst, always (+12 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.13
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 115 - ".encode"
Cohesion: 0.20
Nodes (9): Bool, CGFloat, Character, NSEvent, NSRange, NSString, NSTextView, String (+1 more)

### Community 116 - "SessionGroup"
Cohesion: 0.20
Nodes (7): AgentRoutingRuleStore, Bool, String, URL, UUID, AgentRoutingRuleStoreTests, URL

### Community 117 - "PaneNode"
Cohesion: 0.12
Nodes (10): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+2 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.09
Nodes (16): ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy, SessionLifecycleService, NSWindow (+8 more)

### Community 119 - "Harness command reference"
Cohesion: 0.06
Nodes (29): Attaching from a plain terminal, Bindings, Board and attention, Buffers (paste store), Composition, Errors and LSP, File navigation, Hooks (+21 more)

### Community 122 - "ViEngine"
Cohesion: 0.19
Nodes (8): Range, String, TerminalGridCell, TerminalBufferMatch, TerminalBufferSearch, String, TerminalGridCell, TerminalBufferSearchTests

### Community 123 - "Pipe"
Cohesion: 0.10
Nodes (14): ExternalOpenKind, filePreview, terminal, theme, InstallChoice, cancel, install, installAndApply (+6 more)

### Community 124 - "String"
Cohesion: 0.23
Nodes (12): .encode(_:modifiers:event:modes:), .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release, `repeat`, KeyModifiers, SpecialKey (+4 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, S (+2 more)

### Community 126 - ".path"
Cohesion: 0.15
Nodes (18): AgentArt, AgentMark, .body, AgentMarkShape, AgentVectorIcon, Scanner, .atEnd, SVGPath (+10 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.14
Nodes (21): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), .stats (+13 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.27
Nodes (7): Reason, errored, finished, needsInput, RowState, Bool, Comparable

### Community 129 - "SwiftUI"
Cohesion: 0.15
Nodes (6): FilePreviewCoordinator, FileTabID, NSView, Set, SplitDirection, String

### Community 131 - ".install"
Cohesion: 0.13
Nodes (14): PickerItem, .groupLabel, historyBlock, .id, recipe, .searchableText, RecipePickerModel, NSWindow (+6 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.26
Nodes (6): Bool, NSRange, NSString, NSTextView, String, unichar

### Community 133 - ".load"
Cohesion: 0.21
Nodes (6): FileTreeNode, NodeRow, .body, Bool, Error, String

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.19
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 135 - "CommandTarget"
Cohesion: 0.13
Nodes (3): KittyKeyboardTests, String, UInt8

### Community 136 - ".startWatching"
Cohesion: 0.07
Nodes (57): Codable, CGFloat, BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserRequestPayload, close (+49 more)

### Community 137 - "ActivePaneService"
Cohesion: 0.11
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.23
Nodes (5): ListeningPortScanner, Int32, Set, String, ListeningPortScannerTests

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.09
Nodes (18): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+10 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.14
Nodes (15): Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow, launchStart, StartupMetrics (+7 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.18
Nodes (6): .onCurrentCWD, .onCurrentFile, Bool, NSString, NSTextView, String

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.23
Nodes (8): SidebarSessionItemRow, .body, .waitingNotificationText, Bool, Never, SessionGroup, String, Task

### Community 144 - "PaneStyleSet"
Cohesion: 0.19
Nodes (10): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Data, Pipe, String (+2 more)

### Community 146 - "DecodedImage"
Cohesion: 0.13
Nodes (19): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+11 more)

### Community 147 - "FileTreeWatcher"
Cohesion: 0.12
Nodes (15): BranchSwitchHelper, FileTreeSwiftUIView, .body, .filteredNodes, .rootPath, .scanOptions, .sessionID, .taskID (+7 more)

### Community 148 - "TriState"
Cohesion: 0.17
Nodes (7): BoardViewController, FlippedView, .isFlipped, Bool, Set, TabID, BoardViewControllerTests

### Community 149 - "EnvironmentStore"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.28
Nodes (3): KouenDaemonToolsTests, String, URL

### Community 151 - ".evaluate"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.08
Nodes (15): KouenCLITests, CLIInstallLocator, DetachKeys, absent, invalid, parsed, OptionalUUID, absent (+7 more)

### Community 154 - "LiveResizeTests"
Cohesion: 0.11
Nodes (19): Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock, .block(id:) (+11 more)

### Community 155 - "Int"
Cohesion: 0.14
Nodes (11): FileFuzzyMatcher, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool, Character (+3 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.12
Nodes (15): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, .acceptsFirstResponder (+7 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.02
Nodes (132): _1t(), _7n(), a0(), a6n(), abt(), b1t(), b6n(), bd() (+124 more)

### Community 159 - "MatchCategory"
Cohesion: 0.14
Nodes (14): .agentColorBinding, colors, ANSIPalette, CellColorResolver, MochaTheme, ResolvedCellColors, .init(hex:), .init(red:green:blue:alpha:) (+6 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.13
Nodes (18): FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose, .onSelect (+10 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.11
Nodes (12): PairingBox, .current, .isLockedOut, PendingPairing, Bool, Date, TimeInterval, TokenCheck (+4 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.07
Nodes (18): NSResponder, NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent (+10 more)

### Community 163 - "Workspace"
Cohesion: 0.24
Nodes (7): BinaryInstaller, .bundledMacOSDir, Bool, TimeInterval, BinaryInstallerVersionTests, String, URL

### Community 164 - "CommandPromptController"
Cohesion: 0.09
Nodes (25): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, IssueInfo (+17 more)

### Community 166 - "LiveSession"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.07
Nodes (35): AgentChipView, .init(coder:), .intrinsicContentSize, ChromeRole, sidebar, tabBar, Divider, FontSize (+27 more)

### Community 170 - "URLDetection"
Cohesion: 0.12
Nodes (7): Bool, Range, Set, String, URLDetection, StringProtocol, EngineConformanceTests

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.14
Nodes (15): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+7 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.14
Nodes (13): GridCompositor, Configuration, Int32, SessionGroup, SessionID, Tab, TabID, WorkspaceID (+5 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.10
Nodes (7): ISO8601DateFormatter, KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), SpawnedAgentSurface, Result, String, UUID

### Community 175 - "RGBColorTests"
Cohesion: 0.17
Nodes (13): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedAlreadyBanner, .pairedDevicesList (+5 more)

### Community 176 - "Added"
Cohesion: 0.11
Nodes (20): AgentRow, .agentColor, .executables, .hookButton, .hookButtonTitle, .mcpButton, HookState, failed (+12 more)

### Community 177 - ".rects"
Cohesion: 0.17
Nodes (11): MainActor, Void, Group, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, CGFloat, NSTextField (+3 more)

### Community 178 - "InlineAICompletionView"
Cohesion: 0.24
Nodes (9): CopyModeGridSource, .promptRows, CopyModeReducer, Bool, Character, NSRegularExpression, Range, String (+1 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.14
Nodes (17): PaneBorderStatus, bottom, off, top, PaneLeaf, PaneNode, branch, leaf (+9 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.10
Nodes (12): NSRangePointer, Any, NSAttributedString, NSRange, NSRect, String, UInt64, CellOverlayTests (+4 more)

### Community 181 - "GridCompositorTests"
Cohesion: 0.18
Nodes (5): CompositorPane, GridCompositorTests, Bool, String, TerminalGridSnapshot

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.21
Nodes (4): Bool, String, SurfaceID, TimeInterval

### Community 183 - "LSPServerRegistry"
Cohesion: 0.08
Nodes (6): CodepointRunFastPathTests, .assertAllPathsAgree(_:cols:rows:file:line:), StaticString, String, UInt, UInt8

### Community 184 - "targets"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Kouen, Sparkle (+13 more)

### Community 185 - "SessionSnapshot"
Cohesion: 0.13
Nodes (3): KouenGridTerminalTests, String, TerminalGridSnapshot

### Community 187 - "AppDelegate"
Cohesion: 0.18
Nodes (10): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+2 more)

### Community 188 - "BrowserPaneView"
Cohesion: 0.12
Nodes (19): Motion, .entrance, .spring, .standardEase, CAMediaTimingFunction, NSWindowController, KouenOnboarding, Bool (+11 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.05
Nodes (17): KouenDaemonCore, ClaudeCodeHarnessIPCTests, String, URL, DaemonBrowserRoutingTests, IPCCodecInvariantTests, String, URL (+9 more)

### Community 190 - "user-stories.md"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.07
Nodes (21): PluginLoader, String, ScriptAPI, ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool (+13 more)

### Community 192 - "GlyphRasterizer"
Cohesion: 0.08
Nodes (27): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+19 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.15
Nodes (13): UInt16, TTYSize, RecordClient, RecordingWriter, RecordSession, Summary, Bool, Data (+5 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.15
Nodes (16): FileTreeScanOptions, MatchCategory, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith, filenameStartsWith, fuzzy (+8 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.04
Nodes (100): _3e(), a1t(), a6e(), amn(), b2t(), b6(), cg(), ch() (+92 more)

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.11
Nodes (15): Selector, .init(frame:), Kind, primary, secondary, KouenPillButton, .init(title:kind:), .isHovered (+7 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.08
Nodes (23): FlippedView, .isFlipped, GitPanelView, .isHidden, .removeWorktreeAction(_:), .removeWorktreeAction(path:), GitResult, Any (+15 more)

### Community 198 - ".classify"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.08
Nodes (23): InstallResult, ShellCompletionInstaller, Bool, String, URL, InstallResult, Shell, bash (+15 more)

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.06
Nodes (44): Equatable, Bool, CAMetalDrawable, .currentRawSelection, .currentSelectionRegion, RawSelection, Bool, ClosedRange (+36 more)

### Community 202 - "PaletteModel"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.17
Nodes (4): InputEncoder, InputEncoderTests, String, UInt8

### Community 204 - "From tmux"
Cohesion: 0.25
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 205 - "CopyModeState"
Cohesion: 0.14
Nodes (12): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+4 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.27
Nodes (7): PaletteAction, PaletteFileEntry, PaletteGrepMatch, PaletteModel, NSWindow, String, Void

### Community 207 - "scheduleRender"
Cohesion: 0.12
Nodes (9): AgentDetection, AgentDetector, AgentTable, Date, Int32, TimeInterval, ProcessScan, Int32 (+1 more)

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.13
Nodes (14): CompletionPopupView, .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:), .isHovered, Bool (+6 more)

### Community 209 - "SettingsRemoteView"
Cohesion: 0.14
Nodes (25): br(), checkbox(), codespan(), constructor(), de(), del(), html(), image() (+17 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.13
Nodes (11): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String, CompletionGenerator (+3 more)

### Community 211 - "PaneTarget"
Cohesion: 0.28
Nodes (7): Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 212 - ".translate"
Cohesion: 0.11
Nodes (9): String, WorkspaceID, CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab, DaemonSyncServiceBranchNotifyTests (+1 more)

### Community 213 - "String"
Cohesion: 0.08
Nodes (24): 1 — Process lifecycle & supervision, 2 — IPC protocol evolution, 3 — Concurrency architecture, 4 — State persistence, 5 — Render/PTY data path & the "mktemp failed" spam, 6 — Build/release pipeline, A10 (Low) — stale `@unchecked Sendable` inventory, A1 (High) — S1 daemon-reuse is undone at GUI relaunch by the build-handshake staleness check (+16 more)

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.09
Nodes (24): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+16 more)

### Community 215 - ".lines"
Cohesion: 0.11
Nodes (13): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, PaneLeaf (+5 more)

### Community 216 - "CellColorResolverTests"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 217 - "GridCompositor"
Cohesion: 0.13
Nodes (15): PaletteCommandConfig, PaletteFooter, .body, PaletteItemRow, .body, PaletteMode, errors, grep (+7 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.12
Nodes (15): DetachedPaneOverlay, .init(coder:), .init(frame:style:), Style, detached, reconnectingChip, NSCoder, NSEvent (+7 more)

### Community 219 - "Prompt"
Cohesion: 0.25
Nodes (4): StatusLineWidthTests, StatusLineWidth, String, StyledSegment

### Community 220 - "Section"
Cohesion: 0.17
Nodes (11): NotchGeometry, .fallback, NSScreen, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics (+3 more)

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.06
Nodes (31): keys, CGImage, DecodedImage, .byteCount, ImageLimits, Bool, UInt8, ImageDecoder (+23 more)

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.25
Nodes (8): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor, NSView, .panelBackground

### Community 224 - "CellColorResolver"
Cohesion: 0.26
Nodes (9): ANSIPalette, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors, Bool, Double, TerminalGridCell (+1 more)

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.23
Nodes (7): StdioTransportTests, Data, MCPStdioBuffer, MCPStdioFraming, contentLength, newline, Data

### Community 226 - "FileChangeWatcher"
Cohesion: 0.14
Nodes (18): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, PaneLeaf, PaneNode (+10 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.02
Nodes (162): a(), b(), c(), d(), e(), f(), g(), h() (+154 more)

### Community 228 - "sessionRow"
Cohesion: 0.13
Nodes (10): KeybindingsService, Bool, Command, String, KeybindingsStore, .fileURL, URL, KeybindingsStoreTests (+2 more)

### Community 229 - ".decide"
Cohesion: 0.21
Nodes (6): MutationResult, RemoteHost, RemoteHostStore, Bool, String, T

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.25
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 231 - "ExternalOpenKind"
Cohesion: 0.17
Nodes (21): Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors, ContrastGrade (+13 more)

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.36
Nodes (4): OcclusionTests, NSWindow, String, TimeInterval

### Community 234 - ".scan"
Cohesion: 0.11
Nodes (5): Float, Set, SurfaceID, Void, TerminalPaneRegistry

### Community 235 - "WorkbenchCommand"
Cohesion: 0.08
Nodes (18): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+10 more)

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.13
Nodes (11): Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint, NSRect, WindowTitleStripView (+3 more)

### Community 238 - ".make"
Cohesion: 0.06
Nodes (36): AgentIconArt, AgentVectorIcon, Bool, CGSize, String, AgentIconRenderer, Scanner, .atEnd (+28 more)

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.15
Nodes (8): CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16, UInt8, CharacterWidthTests

### Community 240 - "PaneBorderStatus"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 242 - "AgentBridge"
Cohesion: 0.15
Nodes (5): HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 243 - ".make"
Cohesion: 0.25
Nodes (17): Encodable, AISuggestionAck, AttachedAck, BrowserFramePush, BrowserSnapshotAck, Cred, DetachedAck, DeviceCredentials (+9 more)

### Community 244 - "FileNode"
Cohesion: 0.12
Nodes (10): DaemonClientActor, TimeInterval, DaemonSessionService, .endpoint, .request(_:timeout:), Bool, TimeInterval, Endpoint (+2 more)

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.03
Nodes (70): AS(), ase(), aTn(), bXe(), _c(), cc(), cdn(), d2() (+62 more)

### Community 246 - "Experience modes"
Cohesion: 0.11
Nodes (5): .init(from:), Decoder, CommandParserTests, KeyTableTests, Phase6KeysTests

### Community 247 - ".renderFixture"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.07
Nodes (13): Bool, String, TimeInterval, WorktreeInfo, WorktreeManager, String, WorktreeIsolationTests, String (+5 more)

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.16
Nodes (9): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+1 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.03
Nodes (84): aae(), bce(), bhn(), c_n(), cct(), Cf(), crt(), cSn() (+76 more)

### Community 251 - "SessionCoordinator"
Cohesion: 0.14
Nodes (4): AgentTitleInference, Bool, .effectiveAgentKind, AgentDetectorTests

### Community 252 - "NSViewRepresentable"
Cohesion: 0.29
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 253 - "Split Right"
Cohesion: 0.10
Nodes (9): CGFloat, NSEvent, CGFloat, CGRect, NSEvent, NSPoint, Range, String (+1 more)

### Community 254 - "BoardViewController"
Cohesion: 0.05
Nodes (61): a8n(), aV(), bb(), c9e(), ckn(), clamp(), db(), dle() (+53 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.16
Nodes (9): FileGraphInfo, GraphifyLSPBridge, Double, String, URL, GraphifyLSPBridgeTests, Any, String (+1 more)

### Community 256 - "GitMetadataProvider"
Cohesion: 0.11
Nodes (16): InlineAICompletionController, KouenSettings, String, InlineAICompletionView, .init(coder:), .init(frame:), .suggestion, Bool (+8 more)

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.15
Nodes (22): CoreImage, Network, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription, .surfaceID (+14 more)

### Community 258 - "WindowTitleStripView"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.05
Nodes (56): a6(), aJ(), bXt(), cJ(), dXt(), eGt(), eJ(), EWt() (+48 more)

### Community 260 - ".welcome"
Cohesion: 0.04
Nodes (65): a0n(), aA(), agn(), _at(), avt(), b3e(), c6(), dbt() (+57 more)

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.18
Nodes (8): HookNotificationParser, Parsed, Any, Data, String, HookNotificationParserTests, Data, String

### Community 262 - ".install"
Cohesion: 0.17
Nodes (8): AgentRoutingResolver, String, AgentRoutingRule, AgentRoutingRuleSummary, Bool, String, UUID, AgentRoutingResolverTests

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.19
Nodes (11): DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String, StyledSegment (+3 more)

### Community 266 - ".path"
Cohesion: 0.20
Nodes (7): Data, ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 267 - ".performInstall"
Cohesion: 0.11
Nodes (19): Context, Non-goals, P8: macOS 27 Golden Gate Adoption, Phase 10 — WidgetKit & Desktop Status Panel (P2), Phase 11 — Metal Frame Pacing & DisplayLink Optimization (P2), Phase 12 — Terminal Accessibility Tree (P2), Phase 1 — Compatibility (P0), Phase 2 — Quick Wins (P1) (+11 more)

### Community 268 - "code:bash (# Old (agent-specific):)"
Cohesion: 0.11
Nodes (17): aie(), arc(), closePath(), cRe(), cZ(), E7(), frn, hD() (+9 more)

### Community 270 - "WindowSession"
Cohesion: 0.10
Nodes (8): PaneBorderStatus, Bool, Command, DispatchWorkItem, PaneRect, String, StyledSegment, WindowSession

### Community 271 - "StatusLineView.swift"
Cohesion: 0.24
Nodes (10): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, DirectoryPickerFooter, .body (+2 more)

### Community 272 - "SGRMouseEvent"
Cohesion: 0.21
Nodes (17): Close Pane, Close Tab, Split Down, Split Right, Cmd Shift W Force Closes Tab, Cmd W Closes Pane When Split, Cmd W Closes Tab When Single Pane, Window Survives Full Shortcut Sequence (+9 more)

### Community 273 - "KeySpec"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.15
Nodes (8): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ActivityAssertionManagerTests

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.06
Nodes (43): .notchSection, SettingsAppearanceView, .autoTheme, .body, .themeSection, SliderRow, .body, .displayValue (+35 more)

### Community 277 - ".run"
Cohesion: 0.09
Nodes (20): CopyOutcome, copied, keptNewerInstalled, skippedIdentical, InstallError, .errorDescription, missingBundledTools, InstallReport (+12 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.09
Nodes (24): .init(coder:), BrowserProgressLine, .init(coder:), .init(frame:), BrowserTabButton, .init(coder:), .init(title:isActive:onSelect:onClose:), DesignModePopoverViewController (+16 more)

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.14
Nodes (11): FormatContext, FormatString, FormatStyle, Bool, Character, Date, FormatColor, String (+3 more)

### Community 280 - ".menu"
Cohesion: 0.17
Nodes (11): LinePos, end, firstNonBlank, start, ViDiagnosticNavigator, ViMode, insert, normal (+3 more)

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.18
Nodes (12): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+4 more)

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.14
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 284 - "click_ui_element"
Cohesion: 0.16
Nodes (6): LSPTextLocation, .position, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.29
Nodes (3): SessionStore, DispatchWorkItem, TimeInterval

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.08
Nodes (23): .init(frame:), NSRect, MarkdownPreviewView, .acceptsFirstResponder, .init(coder:), .init(frame:), .isAppearanceDark, .webView(_:decidePolicyFor:decisionHandler:) (+15 more)

### Community 288 - "AgentHookStrategy"
Cohesion: 0.18
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 291 - "JSONDecoder"
Cohesion: 0.20
Nodes (3): String, TerminalGridSnapshot, VTConformanceCorpusTests

### Community 292 - "Release runbook"
Cohesion: 0.25
Nodes (7): Full local signing path (needs a Developer ID cert; not currently used), Full pipeline reference (not implemented in this fork), How this fork actually releases, If the workflow existed: running a release, One-time GitHub setup, Release runbook, What that workflow would publish

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.10
Nodes (17): CodingKeys, error, id, jsonrpc, method, params, JSONRPCId, int (+9 more)

### Community 294 - "GitHubCLIClient"
Cohesion: 0.24
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 295 - "AgentApprovalBar"
Cohesion: 0.20
Nodes (7): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, FileChangeWatcherTests

### Community 296 - "NotificationBus"
Cohesion: 0.21
Nodes (6): String, TerminalGridCell, TextGrid, .totalLines, .viewportRows, WordColumnRangeTests

### Community 297 - "settings.json"
Cohesion: 0.17
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, Bool, Double (+3 more)

### Community 298 - "jobs"
Cohesion: 0.09
Nodes (57): Ame(), aQt(), aXt(), Cqt(), CUe(), cXt(), DYt(), een() (+49 more)

### Community 299 - "PaneNode"
Cohesion: 0.09
Nodes (31): FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView, .body (+23 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.21
Nodes (8): .snapshotPayload, NotificationBus, .postSnapshotChanged(_:), .postSnapshotChanged(revision:), SnapshotChangedPayload, Bool, Data, String

### Community 301 - ".parse"
Cohesion: 0.09
Nodes (13): TerminalGridSnapshot, .feed(_:), .promptRows, .readGrid(scrollbackOffset:), ReflowPreviewTests, .feeds, String, ScrollbackTests (+5 more)

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.16
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 303 - ".encodeMouse"
Cohesion: 0.13
Nodes (16): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+8 more)

### Community 304 - "00-inception-plan.md"
Cohesion: 0.25
Nodes (8): .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didStartProvisionalNavigation:), LoadCompletionState, CheckedContinuation, Error, TimeInterval, WKNavigation

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 308 - "Send Ex Command"
Cohesion: 0.44
Nodes (5): SettingsAdvancedView, .body, Bool, String, SwiftUI

### Community 310 - "FrameSignposter"
Cohesion: 0.15
Nodes (6): Int32, SessionID, String, TabID, UInt16, URL

### Community 312 - "AgentSnapshot"
Cohesion: 0.13
Nodes (19): Array, Bool, Date, Decoder, PaneID, PaneNode, String, TabID (+11 more)

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.09
Nodes (24): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary, RowKind (+16 more)

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.14
Nodes (13): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+5 more)

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.09
Nodes (17): Bool, String, UUID, TaskDaemonBridge, SessionID, Status, ciFailing, done (+9 more)

### Community 319 - "FormatColor"
Cohesion: 0.09
Nodes (19): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+11 more)

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.26
Nodes (14): Agent Command Does Not Crash, Agent Waiting Filter Does Not Crash, Board Command Shows Board Panel, Cd Command Switches To Matching Tab, Copy Path Command Does Not Crash, Errors Command Does Not Crash, Find Command Opens Command Palette On Empty Query, Find Command Resolves Unique File (+6 more)

### Community 321 - "UInt64"
Cohesion: 0.16
Nodes (34): aQ(), bqt(), cbe(), DD(), dqt(), Dr(), Eqt(), Fa() (+26 more)

### Community 322 - "DesktopNotifier"
Cohesion: 0.21
Nodes (12): Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:), Bool, Decoder, SessionID (+4 more)

### Community 323 - "LayoutNode"
Cohesion: 0.10
Nodes (16): Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent, NSPoint, NSRect (+8 more)

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.05
Nodes (41): _4e(), ag(), b5e(), bj(), d8n(), dZe(), e2t(), fle() (+33 more)

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.09
Nodes (6): RGBColor, ANSIPaletteTests, CellColorResolverTests, .resolver, CellColorResolver, RGBColorTests

### Community 327 - ".theme"
Cohesion: 0.21
Nodes (8): PaneOutputWaiter, PaneOutputWaitResult, Bool, CheckedContinuation, Never, PaneLeaf, Tab, UInt64

### Community 328 - "README.md"
Cohesion: 0.21
Nodes (4): GroupedSessionTests, SessionGroup, Set, SurfaceID

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 330 - ".drawGlyph"
Cohesion: 0.19
Nodes (14): CellMetrics, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth, Bool (+6 more)

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.34
Nodes (4): Darwin, Foundation, Glibc, KouenCore

### Community 333 - "RealPty"
Cohesion: 0.14
Nodes (9): bme(), bYt(), fqt(), hVe(), qme(), qrn, s5(), tHe (+1 more)

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.11
Nodes (11): URL, String, String, KouenFilePreviewLoader, KouenViewError, binaryOrUnsupportedEncoding, missingPath, tooLarge (+3 more)

### Community 335 - ".makeModel"
Cohesion: 0.18
Nodes (10): NSView, NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView (+2 more)

### Community 336 - "run.sh"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 337 - "CommandExecutionError"
Cohesion: 0.19
Nodes (6): SessionGroup, SessionGroup, NSMenu, NSMenuItem, SessionGroup, SessionID

### Community 338 - "CSIParams"
Cohesion: 0.30
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 339 - "Foundation"
Cohesion: 0.10
Nodes (20): AppKit, CoreGraphics, CoreText, ImageIO, KouenCopyMode, KouenTerminalEngine, KouenTerminalRenderer, KouenTheme (+12 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.27
Nodes (9): Command Prompt, Find In Files, Git Panel, Open Command Palette, Switch To Session 1, Switch To Session 2, Rapid Session Switch While Typing, Switch Between Isolated And Normal Session (+1 more)

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.11
Nodes (7): ScreenPos, bottom, middle, top, KouenCLI, KouenLSP, QuickLookUI

### Community 342 - "Added"
Cohesion: 0.30
Nodes (7): Bool, NSPasteboard, NSString, String, URL, TerminalServicesProvider, AutoreleasingUnsafeMutablePointer

### Community 344 - "FileViewerViewController"
Cohesion: 0.12
Nodes (11): FileViewerViewController, .acceptsFirstResponder, Any, Bool, NSEvent, Set, String, URL (+3 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.11
Nodes (17): 1.1 Architecture, 1.2 Algorithm review, 1.3 Structure findings, 2.1 Structure, 2.2 Risk register (ranked), 3.1 Current implementation, 3.2 Why nothing shows (ranked root-cause candidates), 3.3 Fix plan (+9 more)

### Community 349 - "Contents.json"
Cohesion: 0.18
Nodes (5): KouenPaths, KouenSettingsTests, URL, Void, String

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.19
Nodes (4): URL, MobileBridgeAttachFileTests, String, URL

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.17
Nodes (10): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, Data, DispatchSourceSignal, Double (+2 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.29
Nodes (6): SurfaceProgressTracker, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.15
Nodes (12): MouseButton, left, middle, right, wheelDown, wheelLeft, wheelRight, wheelUp (+4 more)

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.11
Nodes (44): A1(), aat(), aw(), awt(), b2(), bMt(), bw(), c5n() (+36 more)

### Community 355 - ".deepMerge"
Cohesion: 0.20
Nodes (11): DotView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor, NSRect (+3 more)

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.16
Nodes (5): .snapshot, Bool, String, ThemeService, KouenOptions

### Community 357 - ".handleCat"
Cohesion: 0.31
Nodes (6): Bool, Counter, Scheduled, SurfaceProgressTrackerTests, DispatchWorkItem, TimeInterval

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.11
Nodes (20): clamp(), statusColor(), statusHelp(), Date, Never, SplitDirection, String, T (+12 more)

### Community 359 - "OcclusionTests"
Cohesion: 0.10
Nodes (14): AnyCancellable, NotchMaskAnimator, Bool, CGFloat, CGRect, NSView, NotchPanel, .canBecomeKey (+6 more)

### Community 360 - "State"
Cohesion: 0.23
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.08
Nodes (21): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, AutomationScheduler (+13 more)

### Community 362 - "RGBColor"
Cohesion: 0.18
Nodes (7): MainMenuBuilder, MenuTarget, NSMenu, NSMenuItem, Selector, String, MenuTargetForkConversationTests

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.36
Nodes (5): PaneLeaf, SessionGroup, Any, String, Tab

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.09
Nodes (22): JSONDecoder, JSONEncoder, Kind, input, metadata, output, resize, RecordingEvent (+14 more)

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.27
Nodes (3): DaemonReconnectPolicy, TimeInterval, DaemonReconnectPolicyTests

### Community 366 - "Consumers"
Cohesion: 0.16
Nodes (13): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+5 more)

### Community 367 - "DaemonStats"
Cohesion: 0.25
Nodes (10): BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool, CGFloat, NSCoder, NSEvent (+2 more)

### Community 368 - "Tab"
Cohesion: 0.19
Nodes (10): ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter, Any, Range, String (+2 more)

### Community 369 - "Git Panel"
Cohesion: 0.19
Nodes (7): Bool, NSObjectProtocol, Set, String, Tab, TabID, WorktreeAutoIsolateService

### Community 370 - ".encode"
Cohesion: 0.17
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.11
Nodes (16): Logger, os, OSSignposter, DaemonSessionError, daemonError, .description, unexpectedResponse, LatencyMonitor (+8 more)

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.15
Nodes (13): CodingKey, CodingKeys, createdAt, cwd, done, id, sessionID, status (+5 more)

### Community 373 - "Prompt"
Cohesion: 0.17
Nodes (4): bUt(), fQ, hqe(), M9()

### Community 374 - ".run"
Cohesion: 0.14
Nodes (10): ChromeBackdrop, .init(role:), KouenDesign, RuntimeGlassEffectView, Bool, NSColor, NSPoint, NSView (+2 more)

### Community 375 - ".install"
Cohesion: 0.23
Nodes (3): BoardCommandTests, String, String

### Community 376 - "ScrollReuseTests"
Cohesion: 0.24
Nodes (3): ShortcutRecorderSerializer, String, ShortcutRecorderSerializerTests

### Community 377 - "Identifiable"
Cohesion: 0.13
Nodes (16): Bpe(), cFe(), displayable(), Fpe(), jpe(), KBe(), mFe(), oFe() (+8 more)

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 379 - "MCPServer"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 380 - "PromptQueue"
Cohesion: 0.13
Nodes (10): ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID, String, SurfaceID (+2 more)

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.19
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.10
Nodes (21): Identifiable, DiscoverStepView, .body, Point, String, OnboardingStep, complete, discover (+13 more)

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.15
Nodes (12): .webView(_:didCommit:), BrowserPaneViewTests, MockWebView, .isLoading, .url, Bool, CGFloat, CGPoint (+4 more)

### Community 387 - "User Profile"
Cohesion: 0.22
Nodes (9): DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSView, NSViewCornerConfiguration, SurfaceID (+1 more)

### Community 388 - "Darwin"
Cohesion: 0.14
Nodes (8): Gbe(), handler(), l8e(), $Rt(), s0n(), tJe(), Xo(), YUt

### Community 389 - "HarnessCLITests"
Cohesion: 0.13
Nodes (8): GroupedSessionDaemonTests, SessionGroup, String, URL, MobileBridgeSpawnTests, String, URL, skipUnlessLiveDaemonTests()

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.15
Nodes (20): Cjt(), Ejt(), H2e(), hR(), jX(), Kje(), KX(), lR() (+12 more)

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.19
Nodes (12): CLI Isolate Creates Worktree And Session, CLI Isolate With Custom Branch Name, Close Session Keeps Dirty Worktree, Close Session Removes Clean Worktree, Create Isolated Session And Select, Git Checkout In Normal Session Does Not Affect Isolated, Isolate Without Branch Uses Detached HEAD, Run CLI (+4 more)

### Community 402 - "View"
Cohesion: 0.07
Nodes (39): Configuration, TabBarIconButtonStyle, ButtonStyle, CommandRow, .body, GlassCard, .body, GlassPrimaryButtonStyle (+31 more)

### Community 403 - "PresentAttempt"
Cohesion: 0.30
Nodes (5): Run, Data, String, TerminalBanner, WelcomeConfig

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.33
Nodes (5): AgentBridge, AgentTarget, Bool, String, SurfaceID

### Community 405 - "AgentIconRenderer"
Cohesion: 0.27
Nodes (8): SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, Int32, String

### Community 406 - "main.swift"
Cohesion: 0.07
Nodes (28): DiffLineType, added, deleted, modified, Notification.Name, Bool, NSCoder, NSEvent (+20 more)

### Community 407 - "Fixed"
Cohesion: 0.13
Nodes (17): AnyView, NotchOverviewRow, .approvalControls, .background, .badge, .body, .openableRow, .progressUnderline (+9 more)

### Community 408 - "IPC Architecture"
Cohesion: 0.05
Nodes (20): NSCursor, TerminalGridCell, Bool, NSDraggingInfo, NSDragOperation, NSPasteboard, String, TerminalGridCell (+12 more)

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.13
Nodes (19): CustomStringConvertible, DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed, atomicWrite() (+11 more)

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.10
Nodes (20): DetectionStatus, .display, found, .isReady, notFound, willInstall, BinaryInstaller.DetectionStatus, SetupStepView (+12 more)

### Community 412 - "go.json"
Cohesion: 0.13
Nodes (9): ezt(), GGe, Gwe(), Hzt(), Kp(), l1(), TC(), urn (+1 more)

### Community 414 - "json.json"
Cohesion: 0.37
Nodes (3): .block(atPromptLine:), String, TerminalBlockStoreTests

### Community 415 - "markdown.json"
Cohesion: 0.12
Nodes (5): FormatContextDaemonTests, PaneID, String, SurfaceID, URL

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.17
Nodes (8): TerminalGridCell, .captureLines(joinWrapped:), Case, ReflowCorpusTests, .corpus, .goldenDir, String, URL

### Community 417 - "rust.json"
Cohesion: 0.11
Nodes (3): .selectWorkspace(_:), String, .body

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.10
Nodes (15): AgentStatusDot, Context, .init(coder:), KouenMotion, .init(coder:), .init(coder:), .init(coder:), StatusDotView (+7 more)

### Community 419 - "typescript.json"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 420 - "yaml.json"
Cohesion: 0.12
Nodes (5): KouenApp, KouenCommands, KouenIPC, GitPanelViewFSEventFilterTests, GitPanelViewWorktreeParsingTests

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.18
Nodes (11): FileNode, GitStatusType, added, deleted, modified, renamed, unmodified, untracked (+3 more)

### Community 422 - "HintModeOverlay"
Cohesion: 0.26
Nodes (5): Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 423 - "SixelDecoder"
Cohesion: 0.20
Nodes (9): AnyObject, CommandExecutionError, daemonError, .description, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor (+1 more)

### Community 424 - ".parseDiffHunks"
Cohesion: 0.29
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 425 - "AgentVectorIcon"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.12
Nodes (12): .setupPrompt, AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile (+4 more)

### Community 427 - ".delay"
Cohesion: 0.22
Nodes (6): AgentNotchPresentation, closed, open, peek, AgentNotchWindowActivator, Combine

### Community 428 - "TaskDashboardView"
Cohesion: 0.24
Nodes (8): PickerItemRow, .badgeText, .body, .iconName, .subtitle, .titleText, AttributedString, NSColor

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.32
Nodes (7): FileTab, .title, FileTabManager, .hasOpenTabs, Bool, FileTabID, String

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.08
Nodes (26): SettingsTerminalView, .body, .experienceSection, .fontReadout, .fontSection, .shellSection, Bool, String (+18 more)

### Community 431 - "BoardCardView"
Cohesion: 0.24
Nodes (3): RemoteHostStoreTests, String, URL

### Community 432 - "PathToken"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.27
Nodes (7): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection, agents

### Community 434 - "Project History"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 435 - ".init"
Cohesion: 0.33
Nodes (4): ImageTextureCache, MTLDevice, MTLTexture, UInt8

### Community 436 - "WaitForRegistry"
Cohesion: 0.15
Nodes (6): .agentInfo(forWorktreePath:tabs:), Tab, TabID, WorkspaceID, GitPanelViewWorktreeAgentTests, GitPanelViewWorktreeNavigationTests

### Community 437 - "PickerItemRow"
Cohesion: 0.13
Nodes (10): _7(), A7(), a8(), bGt(), c8(), ene(), Gnn, IC() (+2 more)

### Community 438 - "SessionEditor"
Cohesion: 0.23
Nodes (5): HintModeOverlay, Any, NSEvent, NSView, String

### Community 439 - "SetupStepView"
Cohesion: 0.16
Nodes (8): brn, grn, hrn(), JGe(), KGe(), prn(), qGe(), zGe()

### Community 440 - "LegacySnapshot"
Cohesion: 0.27
Nodes (8): LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab, TabID, WorkspaceID

### Community 441 - "RemoteHostStore"
Cohesion: 0.18
Nodes (6): DefaultTerminalLaunchRequest, ShellQuoting, Bool, String, URL, DefaultTerminalLaunchRequestTests

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 443 - "main.swift"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 445 - "Section"
Cohesion: 0.16
Nodes (11): BrowserPaneRegistry, .init(url:paneID:), .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), NSWindow, PaneID, WKNavigationAction, WKWebView (+3 more)

### Community 446 - "Modifiers"
Cohesion: 0.45
Nodes (3): data, SixelDecoder, UInt8

### Community 447 - "PaletteMode"
Cohesion: 0.17
Nodes (9): Tab, PaneLifecycleManager, Bool, NSView, PaneID, PaneNode, Set, String (+1 more)

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.18
Nodes (10): Bug 1 - Rotation Grace Slot Keeps The Previous Token Redeemable, Bug 1 - Rotation Shifts The Outgoing Token Into The Grace Slot, Bug 1 - Stop Fully Clears The Grace Slot, Bug 1 - Token Lifetime Not Regressed Below The Human-Flow Window, Bug 2 - Client onerror Does Not Clobber The Server Error Banner, Bug 2 - No Abrupt Cancel Immediately After The Error Text, Bug 2 - Reject Path Closes Gracefully With Policy-Violation Code 1008, Bug 3 - QR Not Printed When No Listener Is Ready (+2 more)

### Community 449 - "PresentAttempt"
Cohesion: 0.06
Nodes (29): .event(_:), .interval(_:_:), StaticString, T, .init(themeName:fontFamily:fontSize:vivid:colorRendering:colorGamut:offMainParserFramePipeline:liveResizeReflow:), .testingPendingResize, PendingMainHop, PresentAttempt (+21 more)

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 451 - ".run"
Cohesion: 0.31
Nodes (3): NSMenu, NSMenuItem, String

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.22
Nodes (9): B3(), dFe(), _Dt(), fFe(), lFe(), _Ot(), sD(), TOt() (+1 more)

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.15
Nodes (4): cqe(), F7, mathmlBuilder(), UHt()

### Community 454 - ".recordReapedGenerationForTesting"
Cohesion: 0.22
Nodes (6): .rowList, AgentNotchViewModel, Bool, CGFloat, String, Duration

### Community 455 - "ComposerPanel"
Cohesion: 0.11
Nodes (14): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+6 more)

### Community 456 - "TerminalModes"
Cohesion: 0.23
Nodes (3): TerminalModes, .encode(text:modifiers:modes:), .appCursor

### Community 457 - ".normalizedKey"
Cohesion: 0.25
Nodes (8): AnimatablePair, NotchShape, .animatableData, CGFloat, CGPath, CGRect, Path, Shape

### Community 459 - ".encode"
Cohesion: 0.22
Nodes (6): .body, Bool, AgentKind, Bool, String, URL

### Community 460 - "RunState"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 461 - ".worktreeList"
Cohesion: 0.22
Nodes (8): MCP Control Allowed With Env Var, MCP Control Denied Without Env Var, MCP KouenBoard Returns Columns, MCP KouenList Returns Sessions, MCP ReadPaneOutput Returns Content, Run MCP Request, Run MCP Request Allowed, Run MCP Request Denied

### Community 462 - "AGENTS.md"
Cohesion: 0.25
Nodes (7): Browser Pane Open Close Rapid, File Preview Open Close, Git Fetch Shows Toast, Launch Kouen Staging, Memory Stability After 30 Seconds, Quit Kouen Staging, Sidebar Toggle Immediately After Launch

### Community 463 - ".deinit"
Cohesion: 0.18
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 464 - "MouseButton"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 465 - "DirectionalAxis"
Cohesion: 0.11
Nodes (6): tab, .tab(for:), AgentScanner, Bool, DispatchSourceTimer, TimeInterval

### Community 466 - "ReflowFastPathTests"
Cohesion: 0.12
Nodes (8): OnboardingController, KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, BinaryInstallerDisplayTests, OnboardingEnvironmentTests

### Community 467 - ".moveSelection"
Cohesion: 0.13
Nodes (16): AYt(), Cme(), EUe(), eYt(), HUe(), KD(), kXt(), pXt() (+8 more)

### Community 469 - "PresentAttempt"
Cohesion: 0.36
Nodes (7): daemonLog(), detectStaleInstance(), installSignalHandlers(), removeForeignPIDFile(), Sendable, String, writePIDFile()

### Community 470 - "DispatchTime"
Cohesion: 0.20
Nodes (10): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+2 more)

### Community 471 - ".evaluateStyled"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 473 - "HarnessOnboarding"
Cohesion: 0.14
Nodes (9): GridCompositorParityTests, LiveCompositorFixture, Bool, String, TerminalGridSnapshot, PortCompositorFixture, Bool, String (+1 more)

### Community 474 - "String"
Cohesion: 0.29
Nodes (7): Toggle Sidebar, Sidebar Toggle Works, Board CLI Shows Columns, Board CLI Shows Running After Long Command, Board Columns Visible After Click, Board Tab Accessible In Sidebar, Split Pane And Resize

### Community 475 - ".hitTest"
Cohesion: 0.07
Nodes (32): ImagePlacementSnapshot, SemanticMark, Bool, String, UInt8, TerminalCellWidth, normal, spacerTail (+24 more)

### Community 477 - ".endFind"
Cohesion: 0.17
Nodes (3): CommandPaletteController, PaletteWindowDelegate, TimeInterval

### Community 478 - ".install"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 479 - "ScrollbackTests"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 480 - "Command Prompt Architecture"
Cohesion: 0.40
Nodes (5): New Tab, Cmd T Creates New Session, Tab Close While Mouse Moving, Drag Reorder Past Worktree Row No Crash, New Tab Shares Branch No Worktree

### Community 481 - ".testKouenRendererFixtureDefaultTextReportsPlausibleGlyphStats"
Cohesion: 0.21
Nodes (7): .activeTab, .webView(_:didFinish:), BrowserTab, UUID, tabs, WKScriptMessage, WKUserContentController

### Community 482 - ".resolve"
Cohesion: 0.21
Nodes (9): LSPFileSession, Never, String, Task, URL, Void, object, Bool (+1 more)

### Community 483 - "Changed"
Cohesion: 0.25
Nodes (3): FlushSessionStateTests, String, URL

### Community 485 - ".testKouenRendererFixtureLigatureShapingPathReportsPlausibleGlyphs"
Cohesion: 0.38
Nodes (6): Cleanup And Quit, Create Config File, No Config File Starts Normally, Script Hot Reload On Save, Script Loads On Startup, Script Syntax Error Does Not Crash

### Community 486 - "TabPillView"
Cohesion: 0.29
Nodes (6): Bug 1 - Browser Pane Deferred Unregister, Bug 1 - Browser Pane Reuse On Rebuild, Bug 2 - New Session Syncs Before Reading Active Tab, Bug 2 - Tab Bar New Tab Also Syncs, Bug 3 - Browser Pane Forces Redraw On Reattach, Build Compiles Successfully

### Community 488 - "ccRunCancel"
Cohesion: 0.22
Nodes (4): ANSIPalette, UInt8, .color(_:), .renderColor(_:)

### Community 490 - "ccRunGet"
Cohesion: 0.25
Nodes (4): bze(), EQ(), MBe(), mm

### Community 491 - "Added"
Cohesion: 0.15
Nodes (12): OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Bool, Value, bool (+4 more)

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.39
Nodes (5): AutomationSummary, Bool, Date, String, UUID

### Community 493 - "ccRunStart"
Cohesion: 0.17
Nodes (7): ConcurrentIndexSet, .count, DaemonContentionTests, SubscriptionBox, .count, String, URL

### Community 494 - "ccRunInfo"
Cohesion: 0.33
Nodes (5): Kouen LSP Diagnostics Does Not Crash, Kouen LSP Hover Returns Result, Kouen LSP Start Returns JSON, Kouen View Binary Shows Guard Message, Kouen View Prints File Content

### Community 495 - "ccRuns"
Cohesion: 0.09
Nodes (18): _Bt(), by(), e7e(), fst(), fwn(), gKt(), hxn(), LC() (+10 more)

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.20
Nodes (9): .init(coder:), NotificationRowView, .init(coder:), .init(entry:), .isHighlighted, .isHovered, NSCoder, NSEvent (+1 more)

### Community 497 - "Bool"
Cohesion: 0.21
Nodes (9): Container, .init(coder:), .init(frame:), NotchPulseHost, Context, NSCoder, NSHostingView, NSRect (+1 more)

### Community 498 - ".automationList"
Cohesion: 0.15
Nodes (14): a9e(), Am(), avn(), c0t(), Cm(), Hm(), Im(), lte() (+6 more)

### Community 499 - ".routingRuleList"
Cohesion: 0.24
Nodes (9): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+1 more)

### Community 500 - ".json"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 501 - "Fixed"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 502 - "ACP Client (Shelved)"
Cohesion: 0.39
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 503 - "Build Scripts Self-Kill Protection"
Cohesion: 0.16
Nodes (5): BrowserPaneView, DesignModeElementInfo, Any, NSPopover, String

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.40
Nodes (4): Leak A - Retiring A Host Drops Its AI Controllers, Leak B - Browser Network Capture Is Bounded, Leak C - Every Per-Surface Dict In Coordinator Has Retire Cleanup, Leak D - Every Per-Surface Dict In NotificationCoordinator Is Snapshot-Swept

### Community 509 - "start.mjs"
Cohesion: 0.70
Nodes (4): main(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 510 - "graphify reference: extra exports and benchmark"
Cohesion: 0.15
Nodes (11): copyMode, esc(), fs, globalShortcuts, KEYBINDINGS, prefixTable, renderTable(), ROOT (+3 more)

### Community 511 - ".panePathLookup"
Cohesion: 0.22
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

### Community 512 - "Changelog Archive"
Cohesion: 0.14
Nodes (6): PromptQueue, String, SurfaceID, Void, PromptQueueBar, NSWindow

### Community 513 - "ThemeDocument"
Cohesion: 0.33
Nodes (4): .setSidebarVisible(_:animated:), SidebarPlacementSyncTests, CGFloat, Void

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.27
Nodes (7): Never, Set, String, Task, URL, Void, WorkspaceSymbolIndex

### Community 517 - ".testManyConcurrentSubscribersAllReceiveOutput"
Cohesion: 0.25
Nodes (6): String, URL, ThemeCatalogEmbedTests, .embedSwift, .repoRoot, .sourceJSON

### Community 519 - ".gestureRecognizer"
Cohesion: 0.25
Nodes (5): irn(), mrn, _rn(), rrn(), srn()

### Community 520 - "WriteOutcome"
Cohesion: 0.24
Nodes (12): ern(), G4(), G7(), Jnn(), Qnn(), sHe(), trn(), U3() (+4 more)

### Community 522 - "ShellCompletionInstallerTests"
Cohesion: 0.24
Nodes (8): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8, .body

### Community 524 - "notifyDone"
Cohesion: 0.20
Nodes (7): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, NSCoder, Void

### Community 525 - "TabContextCommand"
Cohesion: 0.14
Nodes (12): table(), tablecell(), tablerow(), Y(), ate(), d5(), eKe(), eoe() (+4 more)

### Community 526 - "Kind"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 527 - "Agent hooks for Harness"
Cohesion: 0.50
Nodes (3): Bug 1 - Hunks Button Has Explicit Size Constraints, Bug 1 - Hunks Button Symbol Has A Guaranteed-Valid Fallback, Build Compiles Successfully

### Community 528 - "worktree_review_dashboard.robot"
Cohesion: 0.50
Nodes (3): Guard A - Merge Call Site Never Passes --no-ff, Guard B - No Auto-Resolve Anywhere In The Merge/Conflict Path, Guard C - Merge Conflict State Is Reconciled, Not Just Read Once

### Community 529 - ".snapshotChanged"
Cohesion: 0.20
Nodes (6): LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled

### Community 530 - "HarnessChrome"
Cohesion: 0.29
Nodes (8): FormatColor, none, palette, rgb, StyledSegment, Bool, String, UInt8

### Community 531 - ".text"
Cohesion: 0.29
Nodes (7): AgentNotification, OSCNotificationParser, DaemonSurfaceID, Data, Date, String, SurfaceID

### Community 534 - "ANSIPalette"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 535 - "AgentNotification"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 537 - "NSRect"
Cohesion: 0.29
Nodes (7): DecodedWSFrame, Data, UInt8, WSFrameParseResult, frame, incomplete, oversized

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.07
Nodes (30): NSButton, NSImage, SessionDividerRowView, .init(coder:), SessionGroupHeaderRowView, .init(coder:), .init(frame:), SessionWorktreeHeaderRowView (+22 more)

### Community 539 - "install-app.sh"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 540 - "TransportError"
Cohesion: 0.12
Nodes (5): ContentAreaViewController, Bool, CGFloat, SplitDirection, TabID

### Community 544 - "Task Ledger Archive (Tasks 1–50)"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 546 - "LegacySnapshot"
Cohesion: 0.20
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 547 - "NSObject"
Cohesion: 0.15
Nodes (16): ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool, Command (+8 more)

### Community 553 - "harness.resource"
Cohesion: 0.33
Nodes (3): MTLDevice, MTLTexture, TerminalGridSnapshot

### Community 556 - ".updateTrackingAreas"
Cohesion: 0.40
Nodes (9): attribute_lines(), main(), redraw_frames(), repeated_chunk(), run_case(), sgr_lines(), truecolor_gradient(), unicode_lines() (+1 more)

### Community 557 - ".viewWillMove"
Cohesion: 0.42
Nodes (3): BrowserIntegrationController, NSView, PaneID

### Community 558 - ".sendInput"
Cohesion: 0.20
Nodes (7): SurfaceIO, .currentSubscription, Data, SurfaceID, UInt16, UInt64, TerminalHostDelegate

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.18
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 560 - ".init(coder:)"
Cohesion: 0.50
Nodes (3): OptionSet, Modifiers, UInt8

### Community 562 - ".hitTest"
Cohesion: 0.27
Nodes (3): Bool, SurfaceID, MenuTargetPeerReviewTests

### Community 563 - "WrapperOptionBehavior"
Cohesion: 0.24
Nodes (6): PaletteRow, header, item, PaletteSectionHeader, .body, .body

### Community 565 - "Motion"
Cohesion: 0.10
Nodes (24): dhn(), en(), fhn(), ghn(), gk(), GOt(), IUe(), iXt() (+16 more)

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 568 - ".gestureRecognizer"
Cohesion: 0.27
Nodes (4): aD(), crn, ELt(), n2e()

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.21
Nodes (8): OverlayBackground, Context, OverlayBackground, Context, KouenOverlayBackground, OverlayBackground, Context, NSViewRepresentable

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.08
Nodes (27): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+19 more)

### Community 571 - "GUt"
Cohesion: 0.18
Nodes (3): GUt, mUt(), _Q()

### Community 572 - "LayoutProbeView"
Cohesion: 0.11
Nodes (13): CornerInfo, KouenSplitView, .dividerColor, .dividerThickness, DispatchWorkItem, Double, NSColor, NSRect (+5 more)

### Community 573 - "WriteOutcome"
Cohesion: 0.29
Nodes (3): ReleaseNotesGuardTests, .changelog, String

### Community 574 - ".agentInfo(forWorktreePath:tabs:)"
Cohesion: 0.20
Nodes (7): BBe(), NBe(), PBe(), qLt(), sIt(), VBe(), zLt()

### Community 578 - "TerminalProgressReport"
Cohesion: 0.21
Nodes (8): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, NSEvent, Observation

### Community 580 - "uV"
Cohesion: 0.39
Nodes (5): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID

### Community 582 - "FileTreeKeyboardNavigator"
Cohesion: 0.22
Nodes (6): GitStatusProvider, Data, String, GitStatusProviderLargeOutputTests, URL, TimeoutError

### Community 585 - ".diffLines"
Cohesion: 0.25
Nodes (4): ControlKeyNormalizer, Bool, String, ControlKeyNormalizerTests

### Community 586 - ".statusLineSet"
Cohesion: 0.36
Nodes (4): ReleaseNotes, Section, String, .sampleNotes

### Community 587 - "_Ue"
Cohesion: 0.40
Nodes (5): h1t(), hae(), jgn(), sfn(), _Ue()

### Community 589 - "Endpoint"
Cohesion: 0.39
Nodes (4): GridCompositorCopyModeTests, PaneRect, String, TerminalGridSnapshot

### Community 591 - "azt"
Cohesion: 0.50
Nodes (3): azt(), ibe(), q$e()

### Community 593 - "dO"
Cohesion: 0.50
Nodes (4): dO(), m8(), rfn(), zfn()

### Community 594 - "hJ"
Cohesion: 0.67
Nodes (4): FVe(), hJ(), qVe(), Zme()

### Community 596 - "prepare-release.sh"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 597 - "rH"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 598 - ".findLeaf"
Cohesion: 0.50
Nodes (3): PaneID, PaneLeaf, PaneNode

### Community 599 - "nJt"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 600 - "HarnessTerminalSurfaceView"
Cohesion: 0.04
Nodes (24): NSEvent, String, Any, Bool, NSEvent, Selector, UInt8, KouenTerminalSurfaceView (+16 more)

### Community 601 - "Hwe"
Cohesion: 0.67
Nodes (3): cat(), Hwe(), kYe()

### Community 603 - "fut"
Cohesion: 0.67
Nodes (3): cfn(), fut(), qYe()

### Community 604 - "k0t"
Cohesion: 0.67
Nodes (3): dht(), k0t(), l1n()

### Community 607 - "iRe"
Cohesion: 0.67
Nodes (3): iRe(), jNt(), zNt()

### Community 609 - "TerminalGridCell"
Cohesion: 0.22
Nodes (9): BDt(), eFe(), kFe(), pC(), tDt(), Vpe(), WY(), xDt() (+1 more)

### Community 610 - "TransportError"
Cohesion: 0.67
Nodes (3): TransportError, invalidUTF8Header, missingContentLength

### Community 613 - "INDEX.md"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 614 - "MainSplitViewController"
Cohesion: 0.11
Nodes (19): MainSplitViewController, .setSidebarVisible(_:), SplitChromeDelegate, .splitView(_:constrainMaxCoordinate:ofSubviewAt:), .splitView(_:constrainMinCoordinate:ofSubviewAt:), .splitView(_:effectiveRect:forDrawnRect:ofDividerAt:), .splitView(_:shouldAdjustSizeOfSubview:), Bool (+11 more)

### Community 617 - "ScriptFileWatcher"
Cohesion: 0.08
Nodes (29): BrowserLeaf, CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf (+21 more)

### Community 622 - "[1.3.0-vit] - 2026-06-06"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 623 - "BrowserResponsePayload"
Cohesion: 0.36
Nodes (4): PaneNode, DaemonSyncServiceBrowserPaneMergeTests, PaneID, PaneNode

### Community 624 - "[2.5.0] - 2026-06-12"
Cohesion: 0.20
Nodes (8): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, ClosedRange, String

### Community 627 - "ActiveTabCloseDisposition"
Cohesion: 0.29
Nodes (5): OutputTrigger, OutputTriggerStore, Bool, String, Data

### Community 629 - "graphify reference: query, path, explain"
Cohesion: 0.25
Nodes (6): calculate(), constructor(), kOt(), mBt, r2e(), sOt()

### Community 637 - "ClientSummary"
Cohesion: 0.14
Nodes (15): FileTreeContext, Bool, NSCoder, NSDraggingInfo, NSDragOperation, NSHostingView, NSScrollView, NSWindow (+7 more)

### Community 641 - "[3.10.0] - 2026-06-27"
Cohesion: 0.25
Nodes (7): #kouen, #practice, #score, #shell, #total, #unix, #vim

### Community 645 - "stability_release.robot"
Cohesion: 0.28
Nodes (3): KouenMCP, KouenBrowserToolsTests, URL

### Community 646 - "[3.10.1] - 2026-06-27"
Cohesion: 0.24
Nodes (5): RiskyCommandClassifier, Bool, NSRegularExpression, String, RiskyCommandClassifierTests

### Community 648 - "PtyDrainCeilingBenchmark"
Cohesion: 0.18
Nodes (12): Counter, DrainResult, .bytesPerWakeup, .mbps, DrainState, EchoRTT, PtyDrainCeilingBenchmark, Bool (+4 more)

### Community 661 - "Remote SSH — Market Comparison"
Cohesion: 0.33
Nodes (5): Kouen vs Competitors (Remote Development over SSH), Our Gaps (vs leaders), Our Strengths, Remote SSH — Market Comparison, Roadmap Opportunities

### Community 662 - "New Tab"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 664 - "P37 Phase G — Autocomplete (mobile bridge)"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 669 - ".recordReapedGenerationForTesting"
Cohesion: 0.26
Nodes (4): PaneLabelDaemonTests, String, URL, UUID

### Community 671 - "AgentKind"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 675 - ".detect"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 679 - "CodingKeys"
Cohesion: 0.25
Nodes (8): CodingKeys, cols, createdAt, dataBase64, rows, timeMs, type, version

### Community 682 - ".hold"
Cohesion: 0.38
Nodes (4): AnyObject, TimeInterval, ZombieHoldRegistry, ObjectIdentifier

### Community 684 - "TabContextCommand"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 686 - "DisplayWidth"
Cohesion: 0.33
Nodes (3): DisplayWidth, String, Unicode

### Community 687 - "ComposedFrame"
Cohesion: 0.29
Nodes (6): ColorKind, .base, bg, fg, underline, ComposedFrame

### Community 689 - "inlineTokens"
Cohesion: 0.29
Nodes (7): blockTokens(), inlineTokens(), lex(), lexer(), lexInline(), me(), reflink()

### Community 690 - ".resourceURL"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

### Community 691 - ".evaluateJavaScript"
Cohesion: 0.29
Nodes (6): Any, Error, MainActor, Sendable, String, Void

### Community 693 - "DaemonError"
Cohesion: 0.33
Nodes (6): DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed

### Community 694 - "TerminalScreen"
Cohesion: 0.47
Nodes (6): _9n(), d8e(), hmn(), PKe(), tke(), u7e()

### Community 695 - "AsyncCLIResultBox"
Cohesion: 0.67
Nodes (3): AsyncCLIResultBox, Error, Result

### Community 696 - "TerminalTabBarDelegate"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 697 - ".detect"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 699 - "TerminalEmulator.swift"
Cohesion: 0.40
Nodes (4): Dispatch, Charset, ascii, decSpecialGraphics

### Community 700 - ".subscribe"
Cohesion: 0.40
Nodes (3): .init(forTesting:), UUID, Void

### Community 701 - "TerminalColorRole"
Cohesion: 0.40
Nodes (5): TerminalColorRole, background, cursor, foreground, palette

### Community 702 - "Next Session"
Cohesion: 0.40
Nodes (5): Next Session, Previous Session, Session Navigation Cmd Brackets, Next Pane In Isolated Session Stays In Worktree, Prev Pane In Isolated Session Stays In Worktree

### Community 703 - "WriteOutcome"
Cohesion: 0.50
Nodes (4): WriteOutcome, complete, failed, wouldBlock

### Community 704 - ".build"
Cohesion: 0.50
Nodes (3): FormatContextBuilder, DaemonSurfaceID, String

### Community 709 - ".start"
Cohesion: 0.12
Nodes (7): NWEndpoint, NWListener, PipeBuffer, Result, String, UInt16, MobileBridgeAISuggestTests

### Community 710 - "MainWindowController"
Cohesion: 0.10
Nodes (13): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+5 more)

### Community 713 - "AutomationScheduler"
Cohesion: 0.28
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 715 - "TerminalProgressReport"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 716 - "ReplayStep"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 718 - "[2.4.0] - 2026-06-12"
Cohesion: 0.13
Nodes (17): DataBox, .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:) (+9 more)

### Community 727 - "PromptQueueBar"
Cohesion: 0.50
Nodes (3): __kouen_osc133_postexec, __kouen_osc133_preexec, __kouen_osc133_prompt

### Community 732 - "ReplayStep"
Cohesion: 0.50
Nodes (3): SplitDirection, horizontal, vertical

### Community 736 - "graphify reference: add a URL and watch a folder"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 737 - ".resolve"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 745 - "p11_scripting.robot"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 797 - "Motion"
Cohesion: 0.50
Nodes (3): Kouen Domain Language, MCP Surface, Relationships

### Community 865 - "MCPServer"
Cohesion: 0.21
Nodes (5): KouenMCPServer, MCPServer, String, StdioTransport, AsyncStream

### Community 991 - "Changed"
Cohesion: 0.22
Nodes (8): Build order (unchanged from interview decision), G1 — @ file-path picker, G2 — shell tab-completion suggestion strip (heuristic, explicitly best-effort), G3 — AI command suggestion (via `claude` CLI subprocess), Logical Design, P37 Phase G — Autocomplete (mobile bridge), Strategic Design, Tactical Design

### Community 1000 - "Changed"
Cohesion: 0.22
Nodes (8): Artifacts, Client Application — Slice 1 (stacked panes, no persistence), Client Application — Slice 2 (per-workspace divider memory), Context, Dev Task Progress — Workspace Sidebar Panels (P42), Integration, Note on task re-sequencing (2026-07-17), Summary

### Community 1109 - ".tomlKouenBlock"
Cohesion: 0.11
Nodes (14): InputGate, .siblings, ReconnectLatch, .isTripped, Bool, CGFloat, FormatColor, KouenSettings (+6 more)

### Community 1303 - ".pushAgentActivityNotifications"
Cohesion: 0.50
Nodes (3): exclude_hubs, no_viz, wiki

### Community 1309 - ".startMetadataRefresh"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 1801 - "ClientSummary"
Cohesion: 0.22
Nodes (5): Completed Plans Archive, Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions

### Community 1832 - "Added"
Cohesion: 0.25
Nodes (7): Claude Code hook push (in-process Task subagent detection), Client UI indicator, Detection core (AgentDetector, pure logic), IPC / Tab plumbing, P38 Phase B — Subagent Visibility — Dev Task Progress, Status: Rewritten 2026-07-14 after original implementation (tasks 1-5) was lost to a concurrent git operation before commit. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 1914 - "P43 — Add Repo/Folder to Workspace"
Cohesion: 0.25
Nodes (7): Original overlay build (built 2026-07-14, gated green, then deleted 2026-07-15 mid live-test), P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress, Pivot — merge into the Recipes picker (2026-07-15), Stage 1-2 — Engine/surface plumbing (built 2026-07-14, unchanged by the pivot, still in use), Status: Implementation pivoted mid-phase from a standalone overlay to a merge into the existing, Summary, Thread grouping — Zed framing folded into the same picker (2026-07-15)

### Community 1933 - ".load"
Cohesion: 0.25
Nodes (6): Kind, path, stack, Bool, Date, UUID

### Community 1943 - "ITerm2InlineImage"
Cohesion: 0.25
Nodes (8): Docs, kouen-mcp, KouenCore, KouenDaemon, KouenIPC, P41 — Automations — Task Progress, Tests, Verification

### Community 2014 - "Added"
Cohesion: 0.36
Nodes (7): Document, Bool, Set, String, URL, ToolPolicy, .defaultURL

### Community 2100 - ".handleWake"
Cohesion: 0.12
Nodes (17): .exit, DaemonClient, String, String, KouenCLI, SessionID, String, Bool (+9 more)

### Community 2176 - "Changed"
Cohesion: 0.29
Nodes (6): Locked decisions (user-confirmed), Logical Design, P38 Phase A — Cross-Agent Worktree Diff/Review Dashboard — Design, Strategic Design, Tactical Design, Verification gate (this phase)

### Community 2242 - "P42 — Workspace Sidebar Panels"
Cohesion: 0.29
Nodes (6): Logical Design, Next Step, P42 — Workspace Sidebar Panels, Parked (not in scope), Strategic Design, Tactical Design

### Community 2541 - "P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable"
Cohesion: 0.18
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 2573 - "P38 Phase D — Kitty Graphics Conformance Slice"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase D — Kitty Graphics Conformance Slice, Scope (locked), Tests

### Community 2633 - "P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua)"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua), Scope (locked), Tests

### Community 2639 - "P41 — Automations"
Cohesion: 0.33
Nodes (4): Logical Design, P41 — Automations, Strategic Design, Tactical Design

### Community 2642 - "P43 — Add Repo/Folder to Workspace"
Cohesion: 0.33
Nodes (5): Logical Design, Next Step, P43 — Add Repo/Folder to Workspace, Strategic Design, Tactical Design

### Community 2735 - "BlockSummary"
Cohesion: 0.08
Nodes (21): PtyError, launchFailed, RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), ScrollbackEntry, ScrollbackReplaySegment, ShellLaunchProfile, .argv (+13 more)

### Community 3131 - "P38 Phase D — Kitty Conformance — Dev Task Progress"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 3132 - "P38 Phase E — Scripting Hooks — Dev Task Progress"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 3135 - "Phase 0 — Swift 6.3+ Concurrency Safety (P0, LESSONS FROM macOS 26.5 CRASH SAGA)"
Cohesion: 0.67
Nodes (3): Phase 0 — Swift 6.3+ Concurrency Safety (P0, LESSONS FROM macOS 26.5 CRASH SAGA), Rules (enforced, not optional), Verification checklist for macOS 27 beta

### Community 3419 - "Page"
Cohesion: 0.21
Nodes (7): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow, NSHostingController

### Community 3515 - "RawRepresentable"
Cohesion: 0.10
Nodes (27): KeySpec, .description, .init(key:modifiers:), String, Binding, .init(from:), .init(spec:command:note:repeatable:), CodingKeys (+19 more)

## Knowledge Gaps
- **3506 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+3501 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1608 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `code:bash (# Terminal 1: Create workspace with long-running job)` to `Changelog Archive`, `callingPaneTarget`, `graphify reference: extra exports and benchmark`, `EngineConformanceTests`, `IPCRequest`, `AgentNotchRootView`, `LSPMessage`, `TerminalEmulator`, `PerformanceBenchmarks`, `GitPanelView.swift`, `VTParser`, `HarnessTerminalSurfaceView`, `.applyPreedit`, `MetalRendererTests`, `HarnessUILibrary`, `SpecialKey`, `HarnessChrome`, `.request`, `NSRect`, `Harness tmux-style capabilities`, `SessionGroupHeaderRowView`, `TransportError`, `.init`, `WorktreeManager`, `Sendable`, `.addTab`, `Equatable`, `Notification`, `.bufferLine`, `.characterIndex`, `MenuTarget`, `Task Ledger Archive (Tasks 1–50)`, `HarnessSettings`, `CodingKeys`, `HarnessSidebarPanelViewController.swift`, `harness.resource`, `.buildCommand`, `.normalizedKey`, `.sendInput`, `DaemonServer`, `WrapperOptionBehavior`, `.keyEvent`, `HarnessSplitView`, `TabCell`, `CommandHistorySearchController`, `PasteBufferStore`, `LayoutProbeView`, `FrecencyDirectoryStore`, `HarnessCLI+Server.swift`, `.text`, `TerminalProgressReport`, `AutomationScheduler`, `worktree_isolation_cli.robot`, `.parse`, `Endpoint`, `HarnessDesign`, `.firstMatch`, `LSPClient`, `TerminalGridCell`, `HarnessPaths`, `.tomlKouenBlock`, `HarnessTerminalSurfaceView`, `TerminalModes`, `P2 — Async IPC Refactor: Design Document`, `AttachInputBatcher`, `shim.c`, `PaneContainerView`, `.dispatch`, `ScriptRuntime.swift`, `Session Grouping and Split Session Plan`, `MainSplitViewController`, `DaemonLauncher`, `Recipe`, `AnyCodable`, `DamageTrackingTests`, `SoftIconButton`, `code:text (:workbench start swift)`, `.makeSnapshot`, `[2.5.0] - 2026-06-12`, `HarnessGridTerminal`, `.encode`, `.firstWaitingTab`, `[1.3.0-vit] - 2026-06-06`, `WorkspaceFileTreeView`, `ViEngine`, `String`, `HistoryRingBuffer`, `GlyphAtlas`, `code:block1 (SessionCoordinator.snapshot ──┐)`, `SwiftUI`, `.install`, `AgentHookInstaller`, `.startWatching`, `.readGrid(scrollbackOffset:)`, `User Story Mapping (MANDATORY)`, `PtyDrainCeilingBenchmark`, `RGBColor`, `CopyModeGridSource`, `How to use Harness from the terminal only (no GUI)`, `PaneStyleSet`, `AsciiFastPathTests`, `Community None`, `LiveResizeTests`, `Int`, `ThaiCombiningMarkTests`, `MatchCategory`, `What You Must Do When Invoked`, `TerminalFindBar`, `Workspace`, `CommandPromptController`, `URLDetection`, `.makeDiffScrollView`, `[1.5.1] - 2026-06-06`, `DisplayWidth`, `BlockSummary`, `ComposedFrame`, `BinaryRefresherTests`, `InlineAICompletionView`, `[3.13.1] - 2026-07-02`, `VTConformanceCorpusTests`, `GridCompositorTests`, `P25 — iOS/iPadOS Support`, `LSPServerRegistry`, `AsyncCLIResultBox`, `SessionSnapshot`, `AppDelegate`, `TerminalColorRole`, `user-stories.md`, `.build`, `GlyphRasterizer`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `.apply`, `BinaryInstaller`, `AgentSessionSummary`, `.classify`, `.start`, `MCP Server (harness-mcp)`, `[3.9.5] - 2026-06-26`, `HarnessCLI`, `scheduleRender`, `.testDataFrameEncodeVsJSONBase64Output`, `PaneTarget`, `.lines`, `Prompt`, `TerminalServicesProvider`, `ExternalOpenKind`, `WorkbenchCommand`, `.make`, `TerminalMetalRenderer`, `PaneBorderStatus`, `[3.5.1] - 2026-06-20`, `ReflowPreviewTests`, `Split Right`, `workspace`, `release-hotfix.sh`, `GitMetadataProvider`, `WindowTitleStripView`, `.install`, `HarnessSidebarPanelViewController`, `.path`, `DefaultTerminalManager`, `WindowSession`, `StatusLineView.swift`, `[2.5.0] - 2026-06-12`, `SyntaxTextView`, `DisplayPanesOverlay`, `TerminalScrollbarView`, `FormatColor`, `click_ui_element`, `AgentHookStrategy`, `StatusLineWidthTests`, `JSONDecoder`, `Fixes Applied (layered)`, `GitHubCLIClient`, `NotificationBus`, `settings.json`, `PaneNode`, `HarnessPaths.swift`, `.parse`, `ViPathTokenTests`, `FrameSignposter`, `AgentSnapshot`, `Terminal AI Chat (⌘I inline overlay)`, `DesktopNotifier`, `LayoutNode`, `.theme`, `ImageProtocolTests.swift`, `Foundation`, `FileViewerViewController`, `GPU Animation Pattern — Layout Once, GPU Paints`, `.handleCat`, `[3.5.1] - 2026-06-20`, `FormatStyledSegment.swift`, `[2.2.4] - 2026-06-11`, `Fixes Applied (v3.9.1+)`, `Consumers`, `DaemonStats`, `SurfaceProgressTrackerTests.swift`, `NSTextField Leak in BoardViewController (P20 Performance)`, `User Profile`, `.load`, `PresentAttempt`, `main.swift`, `Fixed`, `IPC Architecture`, `Session/Tab/Pane Hierarchy & Top Bar (CASE-028)`, `json.json`, `.refreshSurfaceMetadata`, `rust.json`, `HintModeOverlay`, `PathToken`, `Project History`, `.init`, `SessionEditor`, `LegacySnapshot`, `GroupedSessionDaemonTests`, `main.swift`, `Modifiers`, `PresentAttempt`, `.run`, `.recordReapedGenerationForTesting`, `ComposerPanel`, `TerminalModes`, `.encode`, `.deinit`, `DirectionalAxis`, `DispatchTime`, `HarnessOnboarding`, `.hitTest`, `Added`, `ScrollbackTests`, `.testKouenRendererFixtureDefaultTextReportsPlausibleGlyphStats`, `ccRunCancel`, `Added`, `Service Decomposition — SessionCoordinator (P17)`, `ccRunStart`, `.json`, `Build Scripts Self-Kill Protection`, `.panePathLookup`?**
  _High betweenness centrality (0.232) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `Terminal AI Chat (⌘I inline overlay)` to `NSTextField Leak in BoardViewController (P20 Performance)`, `rust.json`, `RealPtyLifecycleTests`, `.recordReapedGenerationForTesting`, `.startWatching`, `Changelog`, `MCP Server (harness-mcp)`, `PaneNode`, `.encode`, `.encode`, `Consumers`, `HarnessDesign`, `PaneNode`, `Community None`, `code:bash (# Terminal 1: Create workspace with long-running job)`?**
  _High betweenness centrality (0.184) - this node is a cross-community bridge._
- **Why does `fbt()` connect `XCTestCase` to `SSHTunnelManagerTests`, `.welcome`, `Changelog`, `ThemeDocumentTests`, `CopyModeAction`, `Harness Terminal — IDE Sidebar Feature Branch`?**
  _High betweenness centrality (0.100) - this node is a cross-community bridge._
- **Are the 18 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `RenderScheduler`) actually correct?**
  _`KouenTerminalSurfaceView` has 18 INFERRED edges - model-reasoned connections that need verification._
- **Are the 294 inferred relationships involving `i()` (e.g. with `blockquote()` and `aD()`) actually correct?**
  _`i()` has 294 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _3526 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.11840888066604996 - nodes in this community are weakly interconnected._