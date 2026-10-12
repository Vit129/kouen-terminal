# Graph Report - p55-antigravity-history-coverage  (2026-10-12)

## Corpus Check
- 894 files · ~1,018,430 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 19606 nodes · 56489 edges · 2591 communities (1486 shown, 1105 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8442 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `f413d48c`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 345 edges
2. `i()` - 321 edges
3. `a()` - 284 edges
4. `t()` - 253 edges
5. `SessionCoordinator` - 236 edges
6. `TerminalEmulator` - 229 edges
7. `SurfaceRegistry` - 223 edges
8. `KouenCLI` - 222 edges
9. `u()` - 219 edges
10. `DaemonClient` - 213 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 189 areas (208 edges)
2. `Command` - bridges 101 areas (108 edges)
3. `AgentKind` - bridges 81 areas (177 edges)
4. `IPCResponse` - bridges 80 areas (103 edges)
5. `KouenTerminalSurfaceView` - bridges 75 areas (345 edges)
6. `t()` - bridges 75 areas (253 edges)
7. `KouenPaths` - bridges 72 areas (150 edges)
8. `KouenGridTerminal` - bridges 67 areas (117 edges)
9. `SessionCoordinator` - bridges 65 areas (236 edges)
10. `SurfaceRegistry` - bridges 65 areas (223 edges)

## Surprising Connections (you probably didn't know these)
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/RemoteHostsService.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.selectWorkspace(byIndex:)` --references--> `SessionSnapshot`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/SessionCoordinator.swift → Packages/KouenIPC/Sources/KouenIPC/SessionSnapshot.swift
- `.selectedHost` --references--> `RemoteHost`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRemoteView.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.heightArg` --calls--> `keys`  [INFERRED]
  Packages/KouenTerminalEngine/Sources/KouenTerminalEngine/Images/ITerm2InlineImage.swift → Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRootView.swift

## Import Cycles
- None detected.

## Communities (2591 total, 1105 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.01
Nodes (699): _0t(), _1n(), _2t(), _3e(), _3n(), _4e(), _5e(), _5n() (+691 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.01
Nodes (490): l, V, z(), _4n(), _7n(), _8n(), a0(), a2() (+482 more)

### Community 2 - ".handleNormal"
Cohesion: 0.02
Nodes (390): pe(), r, X(), A(), code(), R(), a(), aD() (+382 more)

### Community 3 - "Changed"
Cohesion: 0.02
Nodes (295): a(), b(), c(), d(), e(), f(), g(), h() (+287 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.04
Nodes (123): aJ(), Ame(), aQ(), aQt(), aUe(), aXt(), AYt(), bqt() (+115 more)

### Community 5 - "IPCRequest"
Cohesion: 0.05
Nodes (45): AgentBridge, AgentTarget, Bool, String, SurfaceID, .lspPosition(for:), .onCurrentCWD, .onCurrentFile (+37 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.03
Nodes (111): a1t(), a6(), amn(), b2t(), bC(), bpn(), _Bt(), by() (+103 more)

### Community 7 - "Command"
Cohesion: 0.04
Nodes (34): NSRangePointer, TerminalGridCell, NSEvent, Any, Bool, CGFloat, NSEvent, NSMenu (+26 more)

### Community 8 - "LSPMessage"
Cohesion: 0.07
Nodes (17): DaemonCommandExecutor, Command, PanePipe, SurfaceMonitor, SurfaceRegistry, .subscribe(surfaceID:handler:), Bool, FileHandle (+9 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.09
Nodes (40): MTLClearColor, MTLCommandBuffer, MTLLibrary, MTLRenderCommandEncoder, MTLRenderPipelineState, TerminalFrame, BgInstance, CursorCacheKey (+32 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.08
Nodes (13): .receive(_:), DispatchSemaphore, FluidityBenchmarks, NSWindow, String, UInt64, NSWindow, KouenTerminalSurfaceWorkerTests (+5 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.18
Nodes (3): fQ, hqe(), M9()

### Community 12 - "Changed"
Cohesion: 0.05
Nodes (62): SettingsAgentsView, .agentsSection, .body, .deliverySection, .notchSection, .notifySection, Bool, SettingsAppearanceView (+54 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.13
Nodes (3): AgentLaunchCommandsTests, URL, Void

### Community 14 - "VTParser"
Cohesion: 0.08
Nodes (12): HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor, Bool, ClosedRange, Range (+4 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.08
Nodes (22): IndexingIterator, LayoutTemplate, surfaceID, SessionEditor, .addSurface(to:paneID:surfaceID:cwd:), .split(node:targetPaneID:direction:paneCount:before:), .split(node:targetPaneID:with:direction:beforeTarget:), .surfaceID(forPaneID:) (+14 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.05
Nodes (55): AnyTransition, AnyView, Color, .hexString, AgentNotchPeekEvent, AgentNotchRootView, .body, .bottomRadius (+47 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.11
Nodes (22): OptionStore, OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Scope, pane (+14 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.12
Nodes (14): TerminalDamage, RenderColor, MetalRendererTests, .makeRenderer(device:atlasSize:atlasMaxPages:), RenderedFixture, Bool, MTLDevice, MTLTexture (+6 more)

### Community 19 - "SpecialKey"
Cohesion: 0.21
Nodes (4): CommandTarget, String, UUID, TargetSpecTests

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.10
Nodes (11): PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Double, MTLDevice, MTLTexture, String (+3 more)

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.11
Nodes (14): .addSurface(tabID:paneID:), .tab(containingPaneID:), .tab(forSurfaceKey:), .tabIndex(surfaceKey:), .tabIndex(workspaceID:tabID:), Bool, Date, Double (+6 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.09
Nodes (11): .start(onResponse:onEnd:), String, UInt16, UUID, Void, tooLarge, T, IPCEnvelope (+3 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.10
Nodes (19): TerminalGridCell, TerminalEmulator, .captureLines(joinWrapped:), .feed(_:), .promptRows, .readGrid(scrollbackOffset:), TerminalGridSnapshot, Case (+11 more)

### Community 24 - ".request"
Cohesion: 0.10
Nodes (21): ClientRecord, CountBox, DaemonServer, .guiBrowserFD, PendingBrowserRequest, PendingWrite, .remaining, Bool (+13 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.15
Nodes (8): ContextResolutionEngine, Bool, String, Bool, String, TokenGuard, ContextResolutionEngineTests, String

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.07
Nodes (21): OSCTerminatorMatch, PtyError, launchFailed, RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), ScrollbackEntry, ScrollbackReplaySegment, ShellLaunchProfile (+13 more)

### Community 27 - "RGBColor"
Cohesion: 0.06
Nodes (31): SessionDividerRowView, .init(coder:), .init(frame:), SessionGroupHeaderRowView, .init(coder:), .init(frame:), SessionWorktreeHeaderRowView, .init(coder:) (+23 more)

### Community 28 - ".parse"
Cohesion: 0.08
Nodes (27): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+19 more)

### Community 29 - "Added"
Cohesion: 0.09
Nodes (17): ConcurrentIndexSet, .count, DaemonContentionTests, SubscriptionBox, .count, String, URL, DaemonRoundTripTests (+9 more)

### Community 30 - "Notification"
Cohesion: 0.04
Nodes (29): CornerInfo, EditorDividerView, HitTestPassthroughView, KouenSplitView, .dividerColor, .dividerThickness, .init(coder:), PaneDragGripView (+21 more)

### Community 31 - "Sendable"
Cohesion: 0.09
Nodes (28): DaemonSubscription, .start(onData:onEnd:buffered:), Bool, Int32, TimeInterval, UInt64, UnsafeMutableRawPointer, sysClose() (+20 more)

### Community 32 - ".addTab"
Cohesion: 0.11
Nodes (14): json, AgentHistoryScanner, .antigravitySubagentIDs(dbPath:), .readAntigravitySummaries(dbPath:brainDir:ftsIndex:), AgentHistoryTurn, FileCacheEntry, MatchLocationInfo, Bool (+6 more)

### Community 33 - "Equatable"
Cohesion: 0.14
Nodes (9): .selectedHost, MutationResult, RemoteHost, RemoteHostStore, Bool, String, RemoteHostStoreTests, String (+1 more)

### Community 34 - "DaemonClient"
Cohesion: 0.13
Nodes (7): ScriptRuntime, Any, String, URL, JSContext, JSValue, ScriptingTests

### Community 35 - "MenuTarget"
Cohesion: 0.06
Nodes (41): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, .init(from:), .init(id:name:baseURL:modelID:), ModelProvider (+33 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.07
Nodes (45): Codable, BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserRequestPayload, close, cookies (+37 more)

### Community 37 - "String"
Cohesion: 0.06
Nodes (13): SessionCoordinator, Bool, Double, PaneID, PaneNode, SessionID, SplitDirection, String (+5 more)

### Community 38 - "code:bash (swift build)"
Cohesion: 0.08
Nodes (36): Equatable, KouenGridTerminal, .currentSelectionRegion, ClosedRange, String, BlockSelection, CursorRender, CursorStyle (+28 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.09
Nodes (16): DaemonClientActor, TimeInterval, DaemonSessionError, daemonError, .description, unexpectedResponse, DaemonSessionService, .endpoint (+8 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.15
Nodes (15): .exit, DaemonClient, String, KouenCLI, SessionID, String, Bool, Int32 (+7 more)

### Community 41 - "CodingKeys"
Cohesion: 0.09
Nodes (11): SessionGroup, String, KouenSidebarPanelViewController, NSMenuItem, SessionGroup, String, NSMenu, NSMenuItem (+3 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.07
Nodes (27): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+19 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.14
Nodes (9): Process, SSHTunnelManager, .init(makeTunnelProcess:reachabilityProbe:), Bool, URL, Tunnel, SSHTunnelManagerTests, String (+1 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.10
Nodes (10): PaneBorderStatus, Bool, Command, DispatchWorkItem, PaneID, PaneLeaf, PaneNode, PaneRect (+2 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.03
Nodes (97): a0n(), a7e(), b9n(), Bm(), cc(), d2(), dU(), Dwe() (+89 more)

### Community 46 - ".buildCommand"
Cohesion: 0.10
Nodes (10): Bool, String, UInt8, .onResponse, .onSetClipboard, TerminalColorRole, background, cursor (+2 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.10
Nodes (20): InputGate, .siblings, ReconnectLatch, .isTripped, SurfaceIO, .currentSubscription, Bool, CGFloat (+12 more)

### Community 48 - "HookEvent"
Cohesion: 0.08
Nodes (28): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary, RowKind (+20 more)

### Community 49 - "DaemonServer"
Cohesion: 0.08
Nodes (25): LSPFileSession, Never, String, Task, URL, Void, .lspPosition(characterOffset:), Error (+17 more)

### Community 50 - "Added"
Cohesion: 0.11
Nodes (56): DecodedWSFrame, DirectoryListResponse, ExpressibleByStringLiteral, FileReadResponse, buildSuggestPrompt(), cancelConnection(), ConnectionState, .authorized (+48 more)

### Community 51 - ".keyEvent"
Cohesion: 0.07
Nodes (13): .event(_:), .interval(_:_:), StaticString, T, .testingPendingResize, PendingMainHop, SurfaceEmulatorState, SurfaceFrameBuildResult (+5 more)

### Community 52 - "Fixed"
Cohesion: 0.08
Nodes (23): DisplayLinkTarget, MainSplitViewController, .setSidebarVisible(_:), .setSidebarVisible(_:animated:), SplitChromeDelegate, .sidebarMaxWidth, .sidebarMinWidth, .splitView(_:constrainMaxCoordinate:ofSubviewAt:) (+15 more)

### Community 53 - "Added"
Cohesion: 0.15
Nodes (6): AnyCodable, JSONRPCError, Int32, Pipe, String, ToolRegistry

### Community 54 - "HarnessSplitView"
Cohesion: 0.08
Nodes (27): KeybindingsService, Bool, Command, String, Binding, .init(from:), .init(spec:command:note:repeatable:), CodingKeys (+19 more)

### Community 55 - "TabCell"
Cohesion: 0.08
Nodes (33): MonoPillButtonStyle, Configuration, ButtonStyle, CommandRow, .body, GlassCard, .body, GlassPrimaryButtonStyle (+25 more)

### Community 56 - "NSPanel"
Cohesion: 0.09
Nodes (18): PendingVersionBanner, welcome, whatsNew, State, Bool, String, URL, VersionBannerStore (+10 more)

### Community 57 - "BellScanState"
Cohesion: 0.07
Nodes (35): NSCursor, TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid (+27 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.15
Nodes (8): StringKind, apc, dcs, UInt8, UnsafeBufferPointer, VTParser, .feed(_:), VTParserHandler

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.08
Nodes (13): DiffLineType, added, deleted, modified, DispatchWorkItem, NSEvent, NSPopover, NSRange (+5 more)

### Community 60 - "ViEngine"
Cohesion: 0.06
Nodes (36): Executor, Hook, HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane (+28 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.08
Nodes (6): KouenSettings, Bool, ExperienceModeTests, KouenSettingsTests, URL, Void

### Community 62 - "ComposedCell"
Cohesion: 0.12
Nodes (10): Divergence, Bool, String, TimeInterval, WorktreeInfo, WorktreeManager, String, URL (+2 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.13
Nodes (17): AgentSessionHistoryView, .body, .footerView, HistoryMenuProxy, Any, Bool, CGFloat, Date (+9 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.10
Nodes (26): AppKit, CoreGraphics, CoreText, ImageIO, KouenCopyMode, KouenTerminalEngine, KouenTerminalRenderer, KouenTheme (+18 more)

### Community 67 - "String"
Cohesion: 0.10
Nodes (26): CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf, .init(from:) (+18 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.26
Nodes (3): BellScanTests, Bool, UInt8

### Community 69 - ".compose"
Cohesion: 0.09
Nodes (28): A1(), aat(), bw(), c5n(), d6(), f7e(), fae(), gwn() (+20 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.11
Nodes (7): Bool, Range, Set, String, URLDetection, StringProtocol, EngineConformanceTests

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.13
Nodes (5): KouenDaemonTools, SpawnedAgentSurface, Result, String, UUID

### Community 72 - "XCTestCase"
Cohesion: 0.09
Nodes (27): .filteredJobs, MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith (+19 more)

### Community 73 - "README.md"
Cohesion: 0.16
Nodes (10): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab, UUID (+2 more)

### Community 74 - "[2.6.0] - 2026-06-13"
Cohesion: 0.12
Nodes (21): AgentHistoryFTSIndex, .deleteSession(sessionID:), .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:surfaceTag:topicSegments:), .needsReindex(sessionID:mtime:fileSize:), .pruneMissingSessions(validTranscriptPaths:), .saveRecord(_:mtime:fileSize:), .saveRecordsBatch(_:), .search(query:limit:) (+13 more)

### Community 75 - "OptionStore"
Cohesion: 0.08
Nodes (31): FilterStatus, active, all, completed, CaseIterable, KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:) (+23 more)

### Community 76 - ".parse"
Cohesion: 0.09
Nodes (17): ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy, SessionLifecycleService, NSWindow (+9 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.08
Nodes (23): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSEvent (+15 more)

### Community 78 - "Added"
Cohesion: 0.10
Nodes (14): Tab, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), .init(paneID:), PaneID, PaneNode, SurfaceID, PaneLifecycleManager (+6 more)

### Community 79 - "HarnessDesign"
Cohesion: 0.14
Nodes (12): AgentBrowserPaneTracker, SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), PaneID, PaneNode, Set, String (+4 more)

### Community 80 - "Agent handbook — Harness (extended reference)"
Cohesion: 0.14
Nodes (12): ProjectCategory, .init(from:), ProjectEntry, .id, ProjectStore, .init(userDefaults:), Decoder, ProjectStoreSyncTests (+4 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.07
Nodes (30): Endpoint, .localControlSocket, tcp, unix, EndpointError, connectionFailed, .description, notYetSupported (+22 more)

### Community 82 - ".firstMatch"
Cohesion: 0.07
Nodes (31): ImagePlacementSnapshot, SemanticMark, Bool, String, UInt8, TerminalCellWidth, normal, spacerTail (+23 more)

### Community 83 - "LSPClient"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.09
Nodes (11): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, Task, UUID (+3 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.06
Nodes (31): AgentHistoryDateGroup, older, .sortOrder, thisWeek, today, yesterday, AgentSessionHistoryModel, .extraRecordsShown (+23 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.15
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 87 - "SessionCoordinator"
Cohesion: 0.09
Nodes (18): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+10 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.08
Nodes (26): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+18 more)

### Community 89 - ".cursorPos"
Cohesion: 0.07
Nodes (25): Notification.Name, Logger, os, OSSignposter, Phase, daemonConnected, firstDrawablePresented, firstSnapshot (+17 more)

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.18
Nodes (11): SwarmSpawnSpec, CallRecorder, .cancelCalls, .closeCalls, .harnessCalls, .surfaceCalls, SwarmWorkerManagerTests, Bool (+3 more)

### Community 91 - "TerminalModes"
Cohesion: 0.09
Nodes (23): BinaryInstaller, .bundledMacOSDir, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display (+15 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.09
Nodes (10): KouenCLITests, DetachKeys, absent, invalid, parsed, Int32, String, Bool (+2 more)

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.14
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 94 - "AttachInputBatcher"
Cohesion: 0.05
Nodes (38): Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions, Logical Design, P41 — Automations, Strategic Design, Tactical Design (+30 more)

### Community 95 - "shim.c"
Cohesion: 0.08
Nodes (19): SnapshotCoalescer, MainActor, Void, .rowList, AgentNotchViewModel, Bool, CGFloat, Duration (+11 more)

### Community 96 - "Harness Usage"
Cohesion: 0.12
Nodes (14): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, PaneID (+6 more)

### Community 97 - "PaneContainerView"
Cohesion: 0.20
Nodes (9): NotificationDropdownPanelView, .acceptsFirstResponder, .cornerConfiguration, .init(entries:onSelect:onClearAll:onDismiss:), Bool, CGFloat, NSScrollView, NSViewCornerConfiguration (+1 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.12
Nodes (9): ParsedShortcut, .displayString, PrefixKeymap, Any, Bool, NSEvent, String, TimeInterval (+1 more)

### Community 99 - ".dispatch"
Cohesion: 0.06
Nodes (24): KouenIPC, AgentSessionPlacement, background, cloud, local, remoteControl, vscode, .effectiveResumeCommand(claudeMode:) (+16 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.14
Nodes (4): hooks, AgentHookInstallerTests, String, URL

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.13
Nodes (7): KeybindingsStore, .fileURL, URL, KeybindingsStoreTests, URL, Void, String

### Community 103 - "AnyCodable"
Cohesion: 0.11
Nodes (16): NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent, NSImage (+8 more)

### Community 104 - "Recipe"
Cohesion: 0.08
Nodes (32): CGFloat, FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView (+24 more)

### Community 105 - "Changelog"
Cohesion: 0.14
Nodes (18): CommandParseError, .description, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand (+10 more)

### Community 106 - "domain-design.md"
Cohesion: 0.11
Nodes (26): ColorKind, .base, bg, fg, underline, CompositorPane, GridCompositor, .render(panes:status:statusSegments:) (+18 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.08
Nodes (31): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+23 more)

### Community 108 - ".resolve"
Cohesion: 0.10
Nodes (24): CustomStringConvertible, DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed, atomicWrite() (+16 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.14
Nodes (21): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), .stats (+13 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.14
Nodes (15): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+7 more)

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.12
Nodes (16): FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID, KouenFeature (+8 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.10
Nodes (17): BoxDrawing, Kind, arms, dashH, dashV, halfDown, halfLeft, halfRight (+9 more)

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.13
Nodes (7): GitPanelView, Any, DispatchWorkItem, NSMenuItem, UnsafeMutableRawPointer, .init(card:), NSClickGestureRecognizer

### Community 114 - ".firstWaitingTab"
Cohesion: 0.13
Nodes (14): PickerItem, .groupLabel, historyBlock, .id, recipe, .searchableText, RecipePickerModel, NSWindow (+6 more)

### Community 115 - ".encode"
Cohesion: 0.16
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 116 - "SessionGroup"
Cohesion: 0.08
Nodes (14): UnsafeBufferPointer, TerminalCellWidth, UInt8, UnsafeBufferPointer, .cursorVisible, CharacterWidth, Bool, ClosedRange (+6 more)

### Community 117 - "PaneNode"
Cohesion: 0.12
Nodes (19): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerFooter, .body, DirectoryPickerModel (+11 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.14
Nodes (15): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+7 more)

### Community 119 - "Harness command reference"
Cohesion: 0.14
Nodes (12): NaturalLanguage, AgentHistorySearch, Hit, IDFCache, Bool, Double, String, .tokenHits(_:inNormalized:) (+4 more)

### Community 120 - "Added"
Cohesion: 0.08
Nodes (20): SGRMouse, SGRMouseEvent, Bool, PaneRect, UInt8, MouseButton, left, middle (+12 more)

### Community 121 - "Changed"
Cohesion: 0.16
Nodes (16): SwarmFleetSnapshot, SwarmLane, pty, structured, SwarmTaskNode, SwarmTaskStatus, cancelled, failed (+8 more)

### Community 122 - "ViEngine"
Cohesion: 0.14
Nodes (20): ComposedCell, .asGridCell, .init(_:), .init(codepoint:fg:bg:underlineColor:bold:dim:italic:underline:blink:inverse:invisible:strikethrough:overline:), .scalar, .sgr, CompositorPane, GridCompositor (+12 more)

### Community 123 - "Pipe"
Cohesion: 0.12
Nodes (12): ANSIPalette, RGBColor, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors, Bool, Double (+4 more)

### Community 124 - "String"
Cohesion: 0.15
Nodes (9): .removeWorktreeAction(_:), NSButton, NSColor, NSRect, NSScrollView, NSStackView, NSTextField, NSUserInterfaceItemIdentifier (+1 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.11
Nodes (10): MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, String, SurfaceID (+2 more)

### Community 126 - ".path"
Cohesion: 0.14
Nodes (9): MarkdownPreviewView, Any, Bool, Error, String, URL, Void, KouenSyntaxResources (+1 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.10
Nodes (11): CKouenSys, pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal (+3 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.09
Nodes (23): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, IssueInfo (+15 more)

### Community 129 - "SwiftUI"
Cohesion: 0.11
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 130 - "Harness"
Cohesion: 0.10
Nodes (16): StatusLineView, .init(coder:), Bool, CGFloat, FormatColor, Never, NSAttributedString, NSCoder (+8 more)

### Community 131 - ".install"
Cohesion: 0.10
Nodes (20): .agentInfo(forWorktreePath:), AgentNotchPeekDecider, Reason, errored, finished, needsInput, RowState, Bool (+12 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.14
Nodes (10): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+2 more)

### Community 133 - ".load"
Cohesion: 0.10
Nodes (14): NSEvent, BoardCardView, .init(coder:), .onDismiss, BoardViewController, .isVisible, FlippedView, .isFlipped (+6 more)

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.13
Nodes (6): TimeInterval, AgentHandoffBuilder, Bool, String, HandoffDirectoryTests, AgentHandoffBuilderTests

### Community 135 - "CommandTarget"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, S (+2 more)

### Community 136 - ".startWatching"
Cohesion: 0.09
Nodes (23): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+15 more)

### Community 137 - "ActivePaneService"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.13
Nodes (10): ScrollbackFile, .highWater, Bool, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 140 - "Added"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.09
Nodes (20): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+12 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.10
Nodes (19): Coordinator, DiffAnalysis, DiffFileItem, DiffFileStatus, added, .color, deleted, modified (+11 more)

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.22
Nodes (9): Style, accent, agent, agentWorking, done, error, idle, running (+1 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.13
Nodes (10): ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID, String, SurfaceID (+2 more)

### Community 145 - "AsciiFastPathTests"
Cohesion: 0.11
Nodes (22): FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose, .onSelect (+14 more)

### Community 146 - "DecodedImage"
Cohesion: 0.12
Nodes (8): String, LSPDefinitionPayload, LSPDiagnosticsPayload, LSPStatusPayload, String, UInt64, URL, Set

### Community 147 - "FileTreeWatcher"
Cohesion: 0.18
Nodes (6): CopyModeReducerTests, FakeGrid, .totalLines, Set, String, TerminalGridCell

### Community 148 - "TriState"
Cohesion: 0.14
Nodes (12): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, AutomationScheduler (+4 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.07
Nodes (22): CodingKeys, error, id, jsonrpc, method, params, result, LSPMessage (+14 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.09
Nodes (24): QuietRow, .body, StatusPill, .body, .color, Tone, danger, neutral (+16 more)

### Community 151 - ".evaluate"
Cohesion: 0.09
Nodes (38): blockTokens(), br(), checkbox(), codespan(), constructor(), de(), del(), em() (+30 more)

### Community 152 - "Added"
Cohesion: 0.11
Nodes (17): aie(), arc(), closePath(), cRe(), cZ(), E7(), frn, hD() (+9 more)

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.13
Nodes (17): FileNode, GitStatusType, added, deleted, modified, renamed, unmodified, untracked (+9 more)

### Community 154 - "LiveResizeTests"
Cohesion: 0.07
Nodes (36): .pairedAlreadyBanner, .pairingQRPanel, ArtifactKind, html, image, markdown, text, AutomationsFleetModel (+28 more)

### Community 155 - "Int"
Cohesion: 0.17
Nodes (5): FilePreviewCoordinator, FileTabID, Set, SplitDirection, String

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.12
Nodes (13): FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect, String, URL (+5 more)

### Community 157 - "Added"
Cohesion: 0.11
Nodes (15): .automationsList, MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem (+7 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.16
Nodes (15): ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool, Command (+7 more)

### Community 159 - "MatchCategory"
Cohesion: 0.12
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 160 - "AmbientBackground"
Cohesion: 0.11
Nodes (18): ClaudeCodeHarness, .hasAdapter(for:), Profile, edit, readonly, Run, RunState, cancelled (+10 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.17
Nodes (10): SSETransportTests, UInt16, SSETransport, .isRunning, .listener, Bool, NWConnection, NWListener (+2 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.27
Nodes (6): DesktopNotifier, .isUNNotificationCenterAvailable, Bool, MainActor, String, Void

### Community 163 - "Workspace"
Cohesion: 0.13
Nodes (9): ThemeImportController, ThemeDocument, FileManager, String, URL, ThemeFileService, String, URL (+1 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.11
Nodes (21): .body, AgentBadgeView, .body, Bool, CGFloat, AgentIconRenderer, Scanner, .atEnd (+13 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.10
Nodes (19): Array, GroupHeaderRow, .body, PickerItemRow, .badgeText, .iconName, .subtitle, .titleText (+11 more)

### Community 166 - "LiveSession"
Cohesion: 0.10
Nodes (22): BranchSwitchHelper, FileTreeNode, FileTreeSwiftUIView, .body, .filteredNodes, .rootPath, .sessionID, .taskID (+14 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.16
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 168 - "Added"
Cohesion: 0.10
Nodes (25): Bool, UInt8, TerminalCellWidth, normal, spacerTail, wide, TerminalCursor, TerminalCursorShape (+17 more)

### Community 169 - "Fixed"
Cohesion: 0.11
Nodes (15): Bool, CGFloat, DispatchWorkItem, NSCoder, NSEvent, NSPoint, NSRect, NSTrackingArea (+7 more)

### Community 170 - "URLDetection"
Cohesion: 0.12
Nodes (10): WindowInputRouterTests, UInt8, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8 (+2 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.08
Nodes (12): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+4 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.08
Nodes (21): IssueKeychainStore, Bool, String, IssuePriority, .color, high, low, medium (+13 more)

### Community 173 - "BoardCard"
Cohesion: 0.07
Nodes (29): keys, CGImage, DecodedImage, .byteCount, ImageLimits, Bool, UInt8, ImageDecoder (+21 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.10
Nodes (14): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+6 more)

### Community 175 - "RGBColorTests"
Cohesion: 0.07
Nodes (20): Codex → Kouen, One-line install, What you'll see, Cursor Agent → Kouen, Manual fallback, One-line install, What you'll see, Grok Build → Kouen (+12 more)

### Community 176 - "Added"
Cohesion: 0.18
Nodes (3): ShellIntegrationTests, .repoRoot, URL

### Community 177 - ".rects"
Cohesion: 0.15
Nodes (9): CheckpointInfo, CheckpointManager, Bool, Date, String, CheckpointManagerTests, String, String (+1 more)

### Community 178 - "InlineAICompletionView"
Cohesion: 0.14
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.14
Nodes (28): Cleanup Test Repo, Close Isolated Session Keeps Dirty Worktree, Close Isolated Session Removes Clean Worktree, Close One Isolated Does Not Affect Another, Close Session With Split Panes Removes Worktree, Create Isolated Session, Create Isolated Session Via CLI, Get Active Pane (+20 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.12
Nodes (15): MockWebView, .isLoading, .url, Any, Bool, CGFloat, CGPoint, Error (+7 more)

### Community 181 - "GridCompositorTests"
Cohesion: 0.04
Nodes (59): BrowserPaneRegistry, BrowserPaneView, .activeTab, .init(coder:), .init(url:paneID:), .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), .webView(_:didCommit:) (+51 more)

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.09
Nodes (16): .body, Kind, primary, secondary, KouenPillButton, .init(title:kind:), .isHovered, .isPressed (+8 more)

### Community 183 - "LSPServerRegistry"
Cohesion: 0.14
Nodes (14): object, Bool, LSPDiagnostic, LSPDiagnosticSeverity, error, hint, information, warning (+6 more)

### Community 184 - "targets"
Cohesion: 0.14
Nodes (13): SwarmFleetBody, .body, SwarmNodeRowView, .body, .statusColor, Duration, Void, SwarmFleetSnapshotWire (+5 more)

### Community 185 - "SessionSnapshot"
Cohesion: 0.07
Nodes (28): Additional `kouen-cli` subcommands, Agent safety CLI (`kouen-cli`), Agents, context and scratchpad, Attaching from a plain terminal, Bindings, Board and attention, Buffers (paste store), Composition (+20 more)

### Community 186 - "Error"
Cohesion: 0.12
Nodes (12): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, input (+4 more)

### Community 187 - "AppDelegate"
Cohesion: 0.14
Nodes (14): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+6 more)

### Community 188 - "BrowserPaneView"
Cohesion: 0.12
Nodes (15): init(), PairingBox, .current, .isLockedOut, PendingPairing, pruneAttachedFiles(), stop(), Date (+7 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.14
Nodes (13): AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID, .snapshotPayload, NotificationBus (+5 more)

### Community 190 - "user-stories.md"
Cohesion: 0.08
Nodes (30): AgentArt, AgentMark, .body, AgentMarkShape, AgentVectorIcon, Scanner, .atEnd, SVGPath (+22 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.15
Nodes (10): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, Set, SurfaceID (+2 more)

### Community 192 - "GlyphRasterizer"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.10
Nodes (18): SavedLayoutStore, Bool, String, URL, UUID, PaneLayoutShape, branch, leaf (+10 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.14
Nodes (14): .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:), .init(frame:) (+6 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.08
Nodes (14): Bool, NSEvent, Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint (+6 more)

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.29
Nodes (5): AgentNotchPresentation, closed, open, peek, AgentNotchWindowActivator

### Community 197 - "AgentSessionSummary"
Cohesion: 0.11
Nodes (32): AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem, fetchGitStatus() (+24 more)

### Community 199 - "code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)"
Cohesion: 0.08
Nodes (17): AgentDetection, AgentDetector, AgentTableEntry, MatchSource, ownProcess, wrapperLaunch, RawMatch, Bool (+9 more)

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.18
Nodes (5): String, .trimmed, AgentTitleInference, Bool, .effectiveAgentKind

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.17
Nodes (10): StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength, newline, StdioTransport, AsyncStream, TransportError (+2 more)

### Community 202 - "PaletteModel"
Cohesion: 0.12
Nodes (11): Bool, CAMetalDrawable, String, String, UInt64, .color(_:), .renderColor(_:), CellOverlayTests (+3 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.15
Nodes (8): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ActivityAssertionManagerTests

### Community 205 - "CopyModeState"
Cohesion: 0.14
Nodes (22): CoreImage, CryptoKit, Network, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription (+14 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.14
Nodes (11): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+3 more)

### Community 207 - "scheduleRender"
Cohesion: 0.14
Nodes (11): FileFuzzyMatcher, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool, Character (+3 more)

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.19
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 209 - "SettingsRemoteView"
Cohesion: 0.24
Nodes (9): CopyModeGridSource, .promptRows, CopyModeReducer, Bool, Character, NSRegularExpression, Range, String (+1 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.15
Nodes (5): OnboardingController, CompletionGenerator, String, .fishCompletionSource, CompletionGeneratorTests

### Community 211 - "PaneTarget"
Cohesion: 0.13
Nodes (12): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+4 more)

### Community 213 - "String"
Cohesion: 0.13
Nodes (3): KittyKeyboardTests, String, UInt8

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.17
Nodes (3): TerminalGridCell, TerminalGridSnapshot, ThaiCombiningMarkTests

### Community 215 - ".lines"
Cohesion: 0.18
Nodes (10): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+2 more)

### Community 216 - "CellColorResolverTests"
Cohesion: 0.20
Nodes (10): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, Bool (+2 more)

### Community 217 - "GridCompositor"
Cohesion: 0.18
Nodes (10): MainActor, Void, Group, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, CGFloat, NSTextField (+2 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.11
Nodes (13): ExternalOpenKind, filePreview, terminal, theme, InstallChoice, cancel, install, installAndApply (+5 more)

### Community 220 - "Section"
Cohesion: 0.17
Nodes (16): SessionRef, byID, byName, next, previous, String, UUID, TargetSpec (+8 more)

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.11
Nodes (12): BrowserIntegrationController, PaneID, NSPoint, NSView, DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any (+4 more)

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.14
Nodes (12): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+4 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.12
Nodes (17): item, TrackedIssue, IssueTrackerPanelView, .body, .filteredIssues, .statusBannerText, String, GitHubSearchResult (+9 more)

### Community 224 - "CellColorResolver"
Cohesion: 0.09
Nodes (17): FileTreeContext, Bool, NSCoder, NSDraggingInfo, NSDragOperation, NSHostingView, NSScrollView, NSWindow (+9 more)

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.17
Nodes (11): NotchGeometry, .fallback, NSScreen, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics (+3 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.05
Nodes (48): AgentChipView, .init(coder:), .init(frame:), .intrinsicContentSize, ChromeBackdrop, .init(coder:), .init(role:), ChromeRole (+40 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.14
Nodes (9): GridCompositorParityTests, LiveCompositorFixture, Bool, String, TerminalGridSnapshot, PortCompositorFixture, Bool, String (+1 more)

### Community 228 - "sessionRow"
Cohesion: 0.45
Nodes (3): data, SixelDecoder, UInt8

### Community 229 - ".decide"
Cohesion: 0.18
Nodes (5): CompositorPane, GridCompositorTests, Bool, String, TerminalGridSnapshot

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.13
Nodes (16): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, .bytesPerWakeup, .mbps (+8 more)

### Community 231 - "ExternalOpenKind"
Cohesion: 0.12
Nodes (21): Encodable, NWEndpoint, allowedBindHosts(), Entry, FileInfo, GitDiffFile, isDark(), Listing (+13 more)

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.18
Nodes (13): InstallResult, ShellCompletionInstaller, Bool, String, URL, InstallResult, Shell, bash (+5 more)

### Community 233 - "TextGrid"
Cohesion: 0.18
Nodes (16): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, PaneLeaf, PaneNode (+8 more)

### Community 234 - ".scan"
Cohesion: 0.11
Nodes (9): AgyAdapter, CodexAdapter, UUID, AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID (+1 more)

### Community 235 - "WorkbenchCommand"
Cohesion: 0.05
Nodes (33): o, AI(), aXe(), aZ(), bee(), ck(), cy(), Da() (+25 more)

### Community 236 - "Added"
Cohesion: 0.12
Nodes (6): tab, .tab(for:), AgentScanner, Bool, DispatchSourceTimer, TimeInterval

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.20
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 238 - ".make"
Cohesion: 0.14
Nodes (12): FileTreeWatcher, FSEventStreamBox, escaping, FileManager, FSEventStreamRef, MainActor, Set, UnsafeMutableRawPointer (+4 more)

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.12
Nodes (6): PromptQueue, String, SurfaceID, Void, PromptQueueBar, NSWindow

### Community 240 - "PaneBorderStatus"
Cohesion: 0.13
Nodes (15): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+7 more)

### Community 241 - "Added"
Cohesion: 0.10
Nodes (16): KeyRecorderRepresentable, String, Void, OverlayBackground, Context, OverlayBackground, Context, OverlayBackground (+8 more)

### Community 242 - "AgentBridge"
Cohesion: 0.15
Nodes (4): ContentAreaViewController, Bool, String, Notification

### Community 243 - ".make"
Cohesion: 0.13
Nodes (16): Notification.Name, ObserverToken, Bool, NSCoder, NSObjectProtocol, NSRect, NSTextView, URL (+8 more)

### Community 244 - "FileNode"
Cohesion: 0.16
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.11
Nodes (24): .color, Collection, .aggregateBoardStatus, .taskTooltipSummary, TaskSummary.Status, .columnKind, BoardCard, BoardColumn (+16 more)

### Community 246 - "Experience modes"
Cohesion: 0.08
Nodes (30): SidebarSessionListView, .body, .filterChipsHeader, SessionID, WorkspaceID, FleetRowView, .body, .statusColor (+22 more)

### Community 247 - ".renderFixture"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.14
Nodes (14): KouenOnboarding, Bool, ImmersiveOnboardingWindowController, .init(coder:), .init(onDismiss:), ImmersivePanel, .canBecomeKey, .canBecomeMain (+6 more)

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.11
Nodes (13): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, PaneLeaf (+5 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 251 - "SessionCoordinator"
Cohesion: 0.08
Nodes (16): DisplayWidth, String, Unicode, ReleaseNotes, Section, String, Run, String (+8 more)

### Community 252 - "NSViewRepresentable"
Cohesion: 0.18
Nodes (9): String, AgentRoutingRule, Kind, path, stack, Bool, Date, UUID (+1 more)

### Community 253 - "Split Right"
Cohesion: 0.22
Nodes (7): AgentRoutingRuleStore, Bool, String, URL, UUID, AgentRoutingRuleStoreTests, URL

### Community 254 - "BoardViewController"
Cohesion: 0.13
Nodes (17): FormatContextBuilder, DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:) (+9 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.14
Nodes (17): PaneBorderStatus, bottom, off, top, PaneLeaf, PaneNode, branch, leaf (+9 more)

### Community 256 - "GitMetadataProvider"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.08
Nodes (6): CodepointRunFastPathTests, .assertAllPathsAgree(_:cols:rows:file:line:), StaticString, String, UInt, UInt8

### Community 258 - "WindowTitleStripView"
Cohesion: 0.15
Nodes (8): .isHidden, .removeWorktreeAction(path:), GitResult, Bool, String, ValidateOutcome, WorktreeEntry, CoreServices

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.11
Nodes (11): URL, String, String, KouenFilePreviewLoader, KouenViewError, binaryOrUnsupportedEncoding, missingPath, tooLarge (+3 more)

### Community 260 - ".welcome"
Cohesion: 0.21
Nodes (7): EnvironmentStore, Persisted, String, URL, global, EnvironmentStoreTests, URL

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.22
Nodes (3): AgentHistoryMultiAgentCoverageTests, String, URL

### Community 262 - ".install"
Cohesion: 0.17
Nodes (9): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, FormatColor, String (+1 more)

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 264 - "code:bash (harness-cli install-hooks claude-code)"
Cohesion: 0.28
Nodes (7): Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 266 - ".path"
Cohesion: 0.04
Nodes (27): azt(), B0, BBe(), F7, fle(), Fze, Gg(), gPt() (+19 more)

### Community 267 - ".performInstall"
Cohesion: 0.09
Nodes (13): DetachedPaneOverlay, .init(coder:), .init(frame:style:), OutputCoalescer, Style, detached, reconnectingChip, NSCoder (+5 more)

### Community 268 - "code:bash (# Old (agent-specific):)"
Cohesion: 0.25
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 269 - "DefaultTerminalManager"
Cohesion: 0.13
Nodes (3): KouenGridTerminalTests, String, TerminalGridSnapshot

### Community 270 - "WindowSession"
Cohesion: 0.17
Nodes (12): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+4 more)

### Community 271 - "StatusLineView.swift"
Cohesion: 0.20
Nodes (7): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, FileChangeWatcherTests

### Community 272 - "SGRMouseEvent"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 273 - "KeySpec"
Cohesion: 0.19
Nodes (13): ProjectGroupWatcher, StreamBox, Bool, DispatchQueue, escaping, FSEventStreamRef, MainActor, Never (+5 more)

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.14
Nodes (13): GridCompositor, Configuration, Int32, SessionGroup, SessionID, Tab, TabID, WorkspaceID (+5 more)

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.10
Nodes (17): CodingKeys, error, id, jsonrpc, method, params, JSONRPCId, int (+9 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 277 - ".run"
Cohesion: 0.13
Nodes (21): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+13 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.16
Nodes (9): AgentRemoteControlDaemonService, Bool, Set, String, Void, AgentRemoteControlDaemonServiceTests, LogBox, .count (+1 more)

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.21
Nodes (8): DaemonMetrics, Snapshot, .meanLockWaitMicros, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 280 - ".menu"
Cohesion: 0.12
Nodes (17): OnboardingStep, complete, discover, .id, setup, shell, .title, welcome (+9 more)

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.30
Nodes (9): .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release, `repeat`, KeyModifiers, Character, String (+1 more)

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.16
Nodes (20): Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors, ContrastGrade (+12 more)

### Community 283 - "FormatColor"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Kouen, Sparkle (+13 more)

### Community 284 - "click_ui_element"
Cohesion: 0.18
Nodes (6): HappyAdoptTests, CopilotSessionInfo, HappyDaemonSession, Bool, Int32, String

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.16
Nodes (12): UInt16, TTYSize, RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal (+4 more)

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.16
Nodes (8): CustomEndpointTester, Result, Bool, String, URL, CustomEndpointTesterTests, URLRequest, URLSession

### Community 287 - ".apply"
Cohesion: 0.17
Nodes (5): TabID, WorkspaceID, AgentCommandTests, String, Tab

### Community 288 - "AgentHookStrategy"
Cohesion: 0.09
Nodes (35): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+27 more)

### Community 289 - "StatusLineWidthTests"
Cohesion: 0.14
Nodes (11): FormatContext, FormatString, FormatStyle, Bool, Character, Date, FormatColor, String (+3 more)

### Community 290 - "Process"
Cohesion: 0.20
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 291 - "JSONDecoder"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 292 - "Release runbook"
Cohesion: 0.18
Nodes (6): DefaultTerminalLaunchRequest, ShellQuoting, Bool, String, URL, DefaultTerminalLaunchRequestTests

### Community 294 - "GitHubCLIClient"
Cohesion: 0.23
Nodes (4): brn, grn, JGe(), zGe()

### Community 295 - "AgentApprovalBar"
Cohesion: 0.28
Nodes (3): KouenDaemonToolsTests, String, URL

### Community 297 - "settings.json"
Cohesion: 0.12
Nodes (17): SettingsAdvancedView, .body, Bool, String, AgentRow, .agentColor, .executables, .hookButton (+9 more)

### Community 298 - "jobs"
Cohesion: 0.18
Nodes (8): PaneID, SurfaceID, Tab, TabID, BrowserPaneReuseScopeTests, PaneNode, Tab, TabID

### Community 299 - "PaneNode"
Cohesion: 0.27
Nodes (4): PortableRelativeDateFormatter, Date, String, UUID

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.19
Nodes (12): CGFloat, NSCoder, SessionID, String, Void, TaskDashboardBody, .body, TaskDashboardView (+4 more)

### Community 301 - ".parse"
Cohesion: 0.18
Nodes (15): CellMetrics, ComposedFrame, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth (+7 more)

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.15
Nodes (18): Decodable, Item, ItemCompletedLine, LegacyMsgLine, Msg, String, ThreadStartedLine, AISuggestRequest (+10 more)

### Community 303 - ".encodeMouse"
Cohesion: 0.17
Nodes (8): AgentListFormatter, Date, String, dvn(), AgentListFormatterTests, Bool, Date, String

### Community 304 - "00-inception-plan.md"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 305 - ".script"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.16
Nodes (10): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+2 more)

### Community 307 - "ViPathTokenTests"
Cohesion: 0.16
Nodes (9): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+1 more)

### Community 308 - "Send Ex Command"
Cohesion: 0.16
Nodes (6): LSPTextLocation, .position, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 309 - "Browser DevTools API (P28)"
Cohesion: 0.32
Nodes (3): BinaryInstallerVersionTests, String, URL

### Community 310 - "FrameSignposter"
Cohesion: 0.11
Nodes (16): .agentColorBinding, colors, ANSIPalette, CellColorResolver, MochaTheme, ResolvedCellColors, .init(hex:), .init(red:green:blue:alpha:) (+8 more)

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.19
Nodes (11): DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String, StyledSegment (+3 more)

### Community 312 - "AgentSnapshot"
Cohesion: 0.17
Nodes (4): InputEncoder, InputEncoderTests, String, UInt8

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.19
Nodes (8): Range, String, TerminalGridCell, TerminalBufferMatch, TerminalBufferSearch, String, TerminalGridCell, TerminalBufferSearchTests

### Community 314 - "code:bash (harness-cli install-hooks codex)"
Cohesion: 0.06
Nodes (17): KouenTerminalKit, NSPasteboard, URL, NSPasteboard, URL, KouenTerminalSurfaceDragDropTests, KouenTerminalSurfaceFocusTests, OcclusionTests (+9 more)

### Community 315 - "code:bash (harness-cli install-hooks grok)"
Cohesion: 0.19
Nodes (5): TerminalGridSnapshot, TerminalGridSnapshot, ReflowPreviewTests, .feeds, String

### Community 316 - "code:bash (harness-cli install-hooks opencode)"
Cohesion: 0.15
Nodes (4): KouenThemeCatalog, .allThemes, String, KouenThemeCatalogTests

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.10
Nodes (20): Agent Safety Net (Checkpoints, Verification, Write Guards), AI Browser Control (kouen-mcp), Build From Source, Claude Code Harness, CLI, Development Builds, Documentation, Editor & LSP (+12 more)

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.10
Nodes (3): Bool, String, UUID

### Community 319 - "FormatColor"
Cohesion: 0.18
Nodes (5): .snapshot, Bool, String, ThemeService, KouenOptions

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.29
Nodes (4): SwarmDAGStore, String, UUID, SwarmDAGStoreTests

### Community 321 - "UInt64"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 323 - "LayoutNode"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 325 - "FloatingPaneController"
Cohesion: 0.15
Nodes (9): Bool, Int32, String, URL, SystemdUserInstaller, .backendName, .isInstalled, .unitURL (+1 more)

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.07
Nodes (15): crn, eKe(), EUe(), eYt(), ezt(), GGe, Gwe(), hOt() (+7 more)

### Community 327 - ".theme"
Cohesion: 0.13
Nodes (9): NSDraggingInfo, NSDragOperation, PasteController, Bool, NSPasteboard, String, TimeInterval, URL (+1 more)

### Community 328 - "README.md"
Cohesion: 0.15
Nodes (3): CellColorResolverTests, .resolver, CellColorResolver

### Community 330 - ".drawGlyph"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.17
Nodes (12): LayoutFileStore, LayoutNode, branch, leaf, LayoutTemplate, Date, Double, PaneNode (+4 more)

### Community 332 - "Added"
Cohesion: 0.21
Nodes (4): Bool, String, SurfaceID, TimeInterval

### Community 333 - "RealPty"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.11
Nodes (16): .body, .mcpButton, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter, Any (+8 more)

### Community 335 - ".makeModel"
Cohesion: 0.17
Nodes (3): KouenApp, ComposerPanelSlashCommandTests, SyntaxLineIndexTests

### Community 336 - "run.sh"
Cohesion: 0.24
Nodes (9): SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, Int32, String (+1 more)

### Community 337 - "CommandExecutionError"
Cohesion: 0.19
Nodes (9): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+1 more)

### Community 338 - "CSIParams"
Cohesion: 0.11
Nodes (18): CodingKeys, excludedPaths, id, name, sourceFolder, CodingKey, CodingKeys, createdAt (+10 more)

### Community 339 - "Foundation"
Cohesion: 0.25
Nodes (4): KeyTokenParser, Bool, String, KeyTokenParserTests

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.18
Nodes (13): FeaturePhase, architect, completed, dev, interview, qaDesign, qaVerify, .title (+5 more)

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.25
Nodes (8): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String

### Community 342 - "Added"
Cohesion: 0.14
Nodes (19): BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, CodingKeys, description, key (+11 more)

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.17
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

### Community 344 - "FileViewerViewController"
Cohesion: 0.16
Nodes (9): FileGraphInfo, GraphifyLSPBridge, Double, String, URL, GraphifyLSPBridgeTests, Any, String (+1 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.20
Nodes (9): .init(coder:), NotificationRowView, .init(coder:), .init(entry:), .isHighlighted, .isHovered, NSCoder, NSEvent (+1 more)

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.22
Nodes (6): ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 348 - "DaemonLifecycleTests"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 349 - "Contents.json"
Cohesion: 0.19
Nodes (17): Close Pane, Next Session, Previous Session, Split Down, Split Right, Cmd W Closes Pane When Split, Zombie Crash Rapid Close While Typing, Zombie Crash Rapid Split Close Cycle (+9 more)

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.20
Nodes (3): String, TerminalGridSnapshot, VTConformanceCorpusTests

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.11
Nodes (9): String, WorkspaceID, CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab, DaemonSyncServiceBranchNotifyTests (+1 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.17
Nodes (9): GitStatusProvider, OnceResume, Bool, Duration, String, TimeInterval, GitStatusProviderLargeOutputTests, URL (+1 more)

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.24
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.20
Nodes (9): BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool, CGFloat, NSCoder, NSPoint (+1 more)

### Community 355 - ".deepMerge"
Cohesion: 0.19
Nodes (6): KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, OnboardingEnvironmentTests

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.22
Nodes (9): .experienceSection, Bool, String, TriState, auto, .boolValue, .label, off (+1 more)

### Community 357 - ".handleCat"
Cohesion: 0.12
Nodes (6): ScreenPos, bottom, middle, top, KouenLSP, QuickLookUI

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.20
Nodes (10): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+2 more)

### Community 359 - "OcclusionTests"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 360 - "State"
Cohesion: 0.18
Nodes (10): AssistantLine, ClaudeAdapter, Content, Message, ResultLine, Bool, Double, String (+2 more)

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.10
Nodes (14): SessionID, KouenCommands, Status, ciFailing, done, mergeReady, open, running (+6 more)

### Community 362 - "RGBColor"
Cohesion: 0.18
Nodes (14): Array, Bool, Date, Decoder, PaneID, PaneNode, String, TabID (+6 more)

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.26
Nodes (3): String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.20
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 366 - "Consumers"
Cohesion: 0.21
Nodes (8): PaneOutputWaiter, PaneOutputWaitResult, Bool, CheckedContinuation, Never, PaneLeaf, Tab, UInt64

### Community 367 - "DaemonStats"
Cohesion: 0.20
Nodes (5): KouenMCPServer, Bool, String, MCPServer, String

### Community 368 - "Tab"
Cohesion: 0.22
Nodes (4): GroupedSessionTests, SessionGroup, Set, SurfaceID

### Community 369 - "Git Panel"
Cohesion: 0.30
Nodes (8): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, PaletteFooter, .body

### Community 370 - ".encode"
Cohesion: 0.08
Nodes (32): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, .body, PaletteMode (+24 more)

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.14
Nodes (11): clamp(), Date, Never, T, Task, Void, TabPillView, .dragGesture (+3 more)

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.07
Nodes (24): Darwin, Foundation, Glibc, KouenCore, KouenDaemonCore, ensureDirectories(), T, withFileLock() (+16 more)

### Community 373 - "Prompt"
Cohesion: 0.12
Nodes (5): KouenCLI, HistorySearchQueryTests, MemoCommandTests, URL, TaskCommandTests

### Community 374 - ".run"
Cohesion: 0.17
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, Bool, Double (+3 more)

### Community 375 - ".install"
Cohesion: 0.19
Nodes (10): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+2 more)

### Community 376 - "ScrollReuseTests"
Cohesion: 0.13
Nodes (11): Am(), bze(), Cm(), EQ(), Hm(), Im(), lte(), MBe() (+3 more)

### Community 377 - "Identifiable"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.11
Nodes (14): Int, Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock (+6 more)

### Community 379 - "MCPServer"
Cohesion: 0.20
Nodes (4): TerminalModes, .encode(text:modifiers:modes:), Bool, .appCursor

### Community 380 - "PromptQueue"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 381 - "smoke-dmg.sh"
Cohesion: 0.14
Nodes (13): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+5 more)

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.14
Nodes (6): agentWaitChannel(), HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.18
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 385 - "INDEX.md"
Cohesion: 0.15
Nodes (6): .agentInfo(forWorktreePath:tabs:), Tab, TabID, WorkspaceID, GitPanelViewWorktreeAgentTests, GitPanelViewWorktreeNavigationTests

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.19
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 387 - "User Profile"
Cohesion: 0.21
Nodes (7): Bool, NSObjectProtocol, Set, String, Tab, TabID, WorktreeAutoIsolateService

### Community 388 - "Darwin"
Cohesion: 0.13
Nodes (10): .init(frame:), NSHostingView, NSLayoutConstraint, NSRect, TerminalTabBarView, .delegate, .init(frame:), .leadingInset (+2 more)

### Community 389 - "HarnessCLITests"
Cohesion: 0.17
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.22
Nodes (7): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.18
Nodes (8): PluginLoader, String, ScriptAPI, ScriptError, .errorDescription, evaluationError, unsupportedPlatform, JavaScriptCore

### Community 392 - "build-release.sh"
Cohesion: 0.27
Nodes (6): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection

### Community 393 - "create-dmg.sh"
Cohesion: 0.19
Nodes (13): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Bool, Duration (+5 more)

### Community 394 - "finalize-release.sh"
Cohesion: 0.22
Nodes (6): ListeningPortScanner, Int32, Set, String, result, ListeningPortScannerTests

### Community 396 - "generate-appcast.sh"
Cohesion: 0.22
Nodes (5): RepoResolver, Bool, String, RepoResolverTests, String

### Community 397 - "measure-fluidity.sh"
Cohesion: 0.39
Nodes (5): AutomationSummary, Bool, Date, String, UUID

### Community 398 - "preview.sh"
Cohesion: 0.13
Nodes (14): ExperienceMode, agent, .displayName, .foregroundsAgents, full, .notchEnabledByDefault, persistent, .persistsSessionsByDefault (+6 more)

### Community 399 - "sign-and-notarize.sh"
Cohesion: 0.22
Nodes (12): apn(), ern(), G7(), Jnn(), nrn(), Qnn(), trn(), Wnn() (+4 more)

### Community 400 - "install-linux.sh"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 401 - "package-app.sh"
Cohesion: 0.25
Nodes (4): StatusLineWidthTests, StatusLineWidth, String, StyledSegment

### Community 403 - "PresentAttempt"
Cohesion: 0.26
Nodes (14): Agent Command Does Not Crash, Agent Waiting Filter Does Not Crash, Board Command Shows Board Panel, Cd Command Switches To Matching Tab, Copy Path Command Does Not Crash, Errors Command Does Not Crash, Find Command Opens Command Palette On Empty Query, Find Command Resolves Unique File (+6 more)

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.16
Nodes (14): CLI Isolate Creates Worktree And Session, CLI Isolate With Custom Branch Name, Close Session Keeps Dirty Worktree, Close Session Removes Clean Worktree, Create Isolated Session And Select, Drag Reorder Past Worktree Row No Crash, Git Checkout In Normal Session Does Not Affect Isolated, Isolate Without Branch Uses Detached HEAD (+6 more)

### Community 405 - "AgentIconRenderer"
Cohesion: 0.24
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 407 - "Fixed"
Cohesion: 0.19
Nodes (9): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 408 - "IPC Architecture"
Cohesion: 0.18
Nodes (9): NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView, .cornerConfiguration (+1 more)

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.33
Nodes (6): SurfaceProgressTracker, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void

### Community 410 - ".applyTerminalIdentity"
Cohesion: 0.31
Nodes (6): Bool, Counter, Scheduled, SurfaceProgressTrackerTests, DispatchWorkItem, TimeInterval

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.27
Nodes (7): Never, Set, String, Task, URL, Void, WorkspaceSymbolIndex

### Community 413 - "javascript.json"
Cohesion: 0.20
Nodes (9): ProjectDropTarget, .init(coder:), .init(frame:), .init(userDefaultsSuite:), NSCoder, NSDraggingInfo, NSDragOperation, NSRect (+1 more)

### Community 414 - "json.json"
Cohesion: 0.31
Nodes (9): CGFloat, Range, Tab, TabBarLayoutMetrics, .pitch, tabDisplayTitle(), TerminalTabBarBody, .body (+1 more)

### Community 415 - "markdown.json"
Cohesion: 0.34
Nodes (3): Install, Shell integration (OSC 133 semantic prompts), What gets emitted

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.14
Nodes (14): Agent handbook — Kouen (extended reference), Agent integration, Build and test, IPC, Keyboard shortcuts, kouen-cli, Native terminal renderer, Repository map (+6 more)

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.41
Nodes (7): FeatureSummary, FeatureTaskSummary, GateSummary, Bool, Date, String, UUID

### Community 419 - "typescript.json"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.18
Nodes (3): MobileBridgeAttachFileTests, String, URL

### Community 422 - "HintModeOverlay"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 423 - "SixelDecoder"
Cohesion: 0.15
Nodes (3): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess

### Community 424 - ".parseDiffHunks"
Cohesion: 0.31
Nodes (4): .block(atPromptLine:), .captureLines(fromLine:toLine:), String, TerminalBlockStoreTests

### Community 425 - "AgentVectorIcon"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 427 - ".delay"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 428 - "TaskDashboardView"
Cohesion: 0.17
Nodes (8): .effectiveResumeCommand(mode:), AgentSessionMode, cloud, happy, .launchCommand, .launchFlags, local, remoteControl

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.30
Nodes (5): SearchBenchmarks, String, UInt64, URL, Void

### Community 431 - "BoardCardView"
Cohesion: 0.21
Nodes (6): String, TerminalGridCell, TextGrid, .totalLines, .viewportRows, WordColumnRangeTests

### Community 432 - "PathToken"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.24
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 434 - "Project History"
Cohesion: 0.24
Nodes (4): HintModeOverlay, Any, NSEvent, String

### Community 435 - ".init"
Cohesion: 0.18
Nodes (4): ClaudeSessionMode, ClaudeSessionModeTests, URL, Void

### Community 436 - "WaitForRegistry"
Cohesion: 0.21
Nodes (5): ImageTextureCache, MTLDevice, MTLTexture, Set, UInt8

### Community 437 - "PickerItemRow"
Cohesion: 0.21
Nodes (8): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, NSEvent, Observation

### Community 438 - "SessionEditor"
Cohesion: 0.23
Nodes (9): AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor (+1 more)

### Community 439 - "SetupStepView"
Cohesion: 0.21
Nodes (6): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID

### Community 440 - "LegacySnapshot"
Cohesion: 0.22
Nodes (10): DotView, .init(coder:), statusColor(), Bool, Context, NSCoder, NSColor, .workingDot (+2 more)

### Community 441 - "RemoteHostStore"
Cohesion: 0.21
Nodes (4): JSONDecoder, JSONEncoder, String, TerminalRecordingCodec

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.27
Nodes (5): Bool, SessionID, SplitDirection, TabID, WorkspaceID

### Community 443 - "main.swift"
Cohesion: 0.18
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.24
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 445 - "Section"
Cohesion: 0.13
Nodes (7): ControlKeyNormalizer, Bool, String, ShortcutRecorderSerializer, String, ControlKeyNormalizerTests, ShortcutRecorderSerializerTests

### Community 446 - "Modifiers"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 447 - "PaletteMode"
Cohesion: 0.14
Nodes (8): PaneNode, BrowserLeaf, URL, DaemonSyncServiceBrowserPaneMergeTests, PaneID, PaneNode, PaneNodeBrowserTests, PaneNodeLayoutShapeTests

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.25
Nodes (5): irn(), mrn, _rn(), rrn(), srn()

### Community 449 - "PresentAttempt"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.26
Nodes (4): PaneLabelDaemonTests, String, URL, UUID

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.19
Nodes (8): CLIInstallLocator, OptionalUUID, absent, dangling, invalid, valid, URL, UUID

### Community 454 - ".recordReapedGenerationForTesting"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 455 - "ComposerPanel"
Cohesion: 0.17
Nodes (5): DirectionalAxis, down, left, right, up

### Community 456 - "TerminalModes"
Cohesion: 0.16
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 457 - ".normalizedKey"
Cohesion: 0.30
Nodes (7): Bool, NSPasteboard, NSString, String, URL, TerminalServicesProvider, AutoreleasingUnsafeMutablePointer

### Community 458 - ".deletePersistedScrollback"
Cohesion: 0.17
Nodes (10): .init(frame:), .webView(_:decidePolicyFor:decisionHandler:), .webView(_:didFinish:), MainActor, NSRect, WKNavigation, WKNavigationAction, WKWebView (+2 more)

### Community 459 - ".encode"
Cohesion: 0.12
Nodes (15): agy, claude, codex, copilot, hermes, kouen, __kouen_agy_next, __kouen_claude_next (+7 more)

### Community 460 - "RunState"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 461 - ".worktreeList"
Cohesion: 0.40
Nodes (5): WrapperOptionBehavior, keepScanning, matchValue, skipValue, stopScanning

### Community 462 - "AGENTS.md"
Cohesion: 0.14
Nodes (12): .setupPrompt, AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile (+4 more)

### Community 463 - ".deinit"
Cohesion: 0.24
Nodes (9): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+1 more)

### Community 464 - "MouseButton"
Cohesion: 0.25
Nodes (3): SessionStore, DispatchWorkItem, TimeInterval

### Community 465 - "DirectionalAxis"
Cohesion: 0.26
Nodes (5): Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 467 - ".moveSelection"
Cohesion: 0.06
Nodes (35): aDt(), B3(), BDt(), Bpe(), cFe(), dFe(), displayable(), _Dt() (+27 more)

### Community 468 - "Never"
Cohesion: 0.20
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

### Community 469 - "PresentAttempt"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 470 - "DispatchTime"
Cohesion: 0.17
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 471 - ".evaluateStyled"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 472 - "start.sh script"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 473 - "HarnessOnboarding"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 474 - "String"
Cohesion: 0.20
Nodes (9): AnyObject, CommandExecutionError, daemonError, .description, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor (+1 more)

### Community 475 - ".hitTest"
Cohesion: 0.24
Nodes (5): RiskyCommandClassifier, Bool, NSRegularExpression, String, RiskyCommandClassifierTests

### Community 476 - ".steps"
Cohesion: 0.29
Nodes (6): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Carbon

### Community 477 - ".endFind"
Cohesion: 0.31
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 478 - ".install"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 479 - "ScrollbackTests"
Cohesion: 0.18
Nodes (11): Typography, .badge, .kbd, .paletteHeader, .paletteTitle, .rowMeta, .rowTitle, .sectionLabel (+3 more)

### Community 480 - "Command Prompt Architecture"
Cohesion: 0.18
Nodes (10): Architecture Decisions (dated log), Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Post-P50 changes (v4.20.2 → v4.20.11, 2026-10-01 → 2026-10-06), Product Identity Guardrail: Terminal, Not IDE, Shipped capability summary, P44–P49 (2026-08-31 → 2026-09-23) (+2 more)

### Community 481 - ".testKouenRendererFixtureDefaultTextReportsPlausibleGlyphStats"
Cohesion: 0.22
Nodes (13): kouen.bash script, agy(), claude(), codex(), copilot(), hermes(), kouen(), __kouen_agy_next() (+5 more)

### Community 482 - ".resolve"
Cohesion: 0.20
Nodes (8): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, ClosedRange, String

### Community 484 - "Added"
Cohesion: 0.27
Nodes (7): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8

### Community 486 - "TabPillView"
Cohesion: 0.28
Nodes (9): akn(), ift(), p7n(), R1(), rht(), tun(), ubt(), v0n() (+1 more)

### Community 487 - "[1.1.2] - 2026-06-02"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 488 - "ccRunCancel"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 489 - "Added"
Cohesion: 0.27
Nodes (8): LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab, TabID, WorkspaceID

### Community 490 - "ccRunGet"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 491 - "Added"
Cohesion: 0.18
Nodes (10): Bug 1 - Rotation Grace Slot Keeps The Previous Token Redeemable, Bug 1 - Rotation Shifts The Outgoing Token Into The Grace Slot, Bug 1 - Stop Fully Clears The Grace Slot, Bug 1 - Token Lifetime Not Regressed Below The Human-Flow Window, Bug 2 - Client onerror Does Not Clobber The Server Error Banner, Bug 2 - No Abrupt Cancel Immediately After The Error Text, Bug 2 - Reject Path Closes Gracefully With Policy-Violation Code 1008, Bug 3 - QR Not Printed When No Listener Is Ready (+2 more)

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.15
Nodes (11): AnimatablePair, NotchMaskAnimator, Bool, CGFloat, CGRect, NotchShape, .animatableData, CGFloat (+3 more)

### Community 493 - "ccRunStart"
Cohesion: 0.39
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 494 - "ccRunInfo"
Cohesion: 0.36
Nodes (4): Bool, String, UUID, TaskDaemonBridge

### Community 495 - "ccRuns"
Cohesion: 0.33
Nodes (3): DataBox, GitPanelViewDiffErrorTests, String

### Community 497 - ".bind"
Cohesion: 0.20
Nodes (10): PaneRef, bottom, byID, byIndex, last, left, next, previous (+2 more)

### Community 498 - ".automationList"
Cohesion: 0.40
Nodes (4): SplitDirection, TabID, .body, TerminalTabBarDelegate

### Community 499 - ".routingRuleList"
Cohesion: 0.24
Nodes (3): KouenMCP, KouenBrowserToolsTests, URL

### Community 500 - ".json"
Cohesion: 0.20
Nodes (7): Kind, input, metadata, output, resize, ReplayStep, Decoder

### Community 501 - "Fixed"
Cohesion: 0.20
Nodes (9): CodingKeys, cols, createdAt, dataBase64, rows, timeMs, type, version (+1 more)

### Community 502 - "ACP Client (Shelved)"
Cohesion: 0.20
Nodes (9): RecordingEvent, input, metadata, output, resize, .timeMs, Date, Encoder (+1 more)

### Community 503 - "Build Scripts Self-Kill Protection"
Cohesion: 0.20
Nodes (6): LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled

### Community 504 - "WindowBorderOverlayView"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 505 - "Fixed"
Cohesion: 0.38
Nodes (4): Result, ResultLine, String, UUID

### Community 506 - "SwarmFleetBody"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.29
Nodes (8): FormatColor, none, palette, rgb, StyledSegment, Bool, String, UInt8

### Community 508 - "SessionStore"
Cohesion: 0.29
Nodes (8): AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand, Bool, Set

### Community 509 - "start.mjs"
Cohesion: 0.20
Nodes (9): DecodedReplyFrame, output, reply, DecodedRequestFrame, input, request, FrameError, undecodable (+1 more)

### Community 510 - "PromptQueue"
Cohesion: 0.24
Nodes (6): bUt(), FBe(), Gbe(), handler(), mUt(), _Q()

### Community 511 - ".panePathLookup"
Cohesion: 0.27
Nodes (3): DaemonReconnectPolicy, TimeInterval, DaemonReconnectPolicyTests

### Community 512 - "Changelog Archive"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 513 - "ThemeDocument"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.27
Nodes (9): Command Prompt, Find In Files, Git Panel, Open Command Palette, Switch To Session 1, Switch To Session 2, Rapid Session Switch While Typing, Switch Between Isolated And Normal Session (+1 more)

### Community 515 - "[1.0.6] - 2026-06-02"
Cohesion: 0.33
Nodes (4): GridCompositorCopyModeTests, PaneRect, String, TerminalGridSnapshot

### Community 516 - "[1.3.0] - 2026-06-04"
Cohesion: 0.25
Nodes (6): String, URL, ThemeCatalogEmbedTests, .embedSwift, .repoRoot, .sourceJSON

### Community 517 - ".testManyConcurrentSubscribersAllReceiveOutput"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 518 - "Bool"
Cohesion: 0.36
Nodes (5): PaneLeaf, SessionGroup, Any, String, Tab

### Community 520 - "WriteOutcome"
Cohesion: 0.40
Nodes (9): attribute_lines(), main(), redraw_frames(), repeated_chunk(), run_case(), sgr_lines(), truecolor_gradient(), unicode_lines() (+1 more)

### Community 521 - "FileTreeKeyboardNavigator"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 522 - "ShellCompletionInstallerTests"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Key spec syntax, Kouen keybindings, Persistence (+1 more)

### Community 523 - ".encode"
Cohesion: 0.13
Nodes (11): OptionSet, KeySpec, .description, .init(from:), .init(key:modifiers:), Modifiers, Decoder, String (+3 more)

### Community 524 - "RealPtyLifecycleTests"
Cohesion: 0.33
Nodes (4): OutputTrigger, OutputTriggerStore, Bool, String

### Community 525 - "TabContextCommand"
Cohesion: 0.17
Nodes (8): HeadlessCLIAdapter, HeadlessRunEvent, assistantText, result, sessionID, Bool, Double, String

### Community 527 - ".show"
Cohesion: 0.36
Nodes (6): ClaudeRunSummary, Date, Double, Int32, String, UUID

### Community 528 - "worktree_review_dashboard.robot"
Cohesion: 0.20
Nodes (5): FormatContextDaemonTests, PaneID, String, SurfaceID, URL

### Community 529 - "WorktreeAutoIsolateService"
Cohesion: 0.24
Nodes (4): GroupedSessionDaemonTests, SessionGroup, String, URL

### Community 530 - "HarnessChrome"
Cohesion: 0.28
Nodes (4): RemoteControlURLProvider, Bool, URL, RemoteControlURLProviderTests

### Community 531 - ".recordReapedGenerationForTesting"
Cohesion: 0.22
Nodes (8): Build order (unchanged from interview decision), G1 — @ file-path picker, G2 — shell tab-completion suggestion strip (heuristic, explicitly best-effort), G3 — AI command suggestion (via `claude` CLI subprocess), Logical Design, P37 Phase G — Autocomplete (mobile bridge), Strategic Design, Tactical Design

### Community 532 - "OpenClaw → Kouen"
Cohesion: 0.22
Nodes (8): Artifacts, Client Application — Slice 1 (stacked panes, no persistence), Client Application — Slice 2 (per-workspace divider memory), Context, Dev Task Progress — Workspace Sidebar Panels (P42), Integration, Note on task re-sequencing (2026-07-17), Summary

### Community 533 - "flushSessionState"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 534 - ".sessionID"
Cohesion: 0.31
Nodes (6): TerminalGridCell, ThaiClusterCopyTests, ThaiGrid, .columns, .totalLines, .viewportRows

### Community 535 - "AgentNotification"
Cohesion: 0.28
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 536 - ".readGrid(scrollbackOffset:)"
Cohesion: 0.22
Nodes (8): MCP Control Allowed With Env Var, MCP Control Denied Without Env Var, MCP KouenBoard Returns Columns, MCP KouenList Returns Sessions, MCP ReadPaneOutput Returns Content, Run MCP Request, Run MCP Request Allowed, Run MCP Request Denied

### Community 537 - "NSObject"
Cohesion: 0.22
Nodes (8): Browser Pane Open Close Rapid, File Preview Open Close, Git Fetch Shows Toast, Launch Kouen Staging, Memory Stability After 30 Seconds, Quit Kouen Staging, Sidebar Toggle Immediately After Launch, Tab Close While Mouse Moving

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 539 - "install-app.sh"
Cohesion: 0.36
Nodes (7): Document, Bool, Set, String, URL, ToolPolicy, .defaultURL

### Community 542 - ".init(from:)"
Cohesion: 0.25
Nodes (7): Agent Memory, Graphify, graphify, kouen-terminal — Agent Instructions, Rules (read when triggered), Session Start, Skills & Rules

### Community 544 - "CodingKeys"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 545 - ".characterIndex"
Cohesion: 0.22
Nodes (7): KouenCLIPaths, .applicationSupport, .binDirectory, .installedCLIPath, .installedDaemonPath, .launchAgentURL, URL

### Community 547 - "NSObject"
Cohesion: 0.22
Nodes (8): _7(), A7(), a8(), bGt(), c8(), ene(), IC(), o8()

### Community 548 - ".encode"
Cohesion: 0.22
Nodes (9): Motion, .entrance, .spring, .standardEase, SwarmFleetView, .init(coder:), CGFloat, NSCoder (+1 more)

### Community 549 - ".init(from:)"
Cohesion: 0.20
Nodes (8): statusHelp(), String, TabStatus, done, error, idle, running, waiting

### Community 550 - ".init(hex:)"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 551 - ".init(red:green:blue:alpha:)"
Cohesion: 0.25
Nodes (8): A `claude` typed by hand, Claude Code → Kouen, Customizing, One-line install, Session mode: Remote Control / cloud / local, The reverse direction: a session opened in Claude showing up in Kouen, Verifying, What gets written

### Community 552 - "worktree_auto_isolate_wiring.robot"
Cohesion: 0.25
Nodes (3): Action, KouenPathDisplay, UserNotifications

### Community 553 - "harness.resource"
Cohesion: 0.32
Nodes (6): CGFloat, ResizeDirection, down, left, right, up

### Community 554 - "FileTreeKeyboardNavigator"
Cohesion: 0.29
Nodes (8): NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), UNNotification, UNNotificationPresentationOptions, UNNotificationResponse, UNUserNotificationCenter, UNUserNotificationCenterDelegate

### Community 558 - ".sendInput"
Cohesion: 0.25
Nodes (7): Claude Code hook push (in-process Task subagent detection), Client UI indicator, Detection core (AgentDetector, pure logic), IPC / Tab plumbing, P38 Phase B — Subagent Visibility — Dev Task Progress, Status: Rewritten 2026-07-14 after original implementation (tasks 1-5) was lost to a concurrent git operation before commit. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.25
Nodes (7): Original overlay build (built 2026-07-14, gated green, then deleted 2026-07-15 mid live-test), P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress, Pivot — merge into the Recipes picker (2026-07-15), Stage 1-2 — Engine/surface plumbing (built 2026-07-14, unchanged by the pivot, still in use), Status: Implementation pivoted mid-phase from a standalone overlay to a merge into the existing, Summary, Thread grouping — Zed framing folded into the same picker (2026-07-15)

### Community 560 - "LayoutTemplate"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 561 - "Added"
Cohesion: 0.25
Nodes (7): #kouen, #practice, #score, #shell, #total, #unix, #vim

### Community 562 - "BrowserResponsePayload"
Cohesion: 0.32
Nodes (4): PaneID, SessionGroup, Tab, first

### Community 563 - "AgentNotchViewModel.swift"
Cohesion: 0.25
Nodes (3): FlushSessionStateTests, String, URL

### Community 564 - "📁 IDE Sidebar"
Cohesion: 0.43
Nodes (7): Close Tab, New Tab, Cmd Shift W Force Closes Tab, Cmd T Creates New Session, Cmd W Closes Tab When Single Pane, Window Survives Full Shortcut Sequence, Zombie Crash Close Tab While Typing

### Community 565 - "ReleaseNotesGuardTests"
Cohesion: 0.29
Nodes (7): Toggle Sidebar, Sidebar Toggle Works, Board CLI Shows Columns, Board CLI Shows Running After Long Command, Board Columns Visible After Click, Board Tab Accessible In Sidebar, Split Pane And Resize

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.38
Nodes (4): AnyObject, TimeInterval, ZombieHoldRegistry, ObjectIdentifier

### Community 571 - "ShellIntegrationTests"
Cohesion: 0.32
Nodes (3): GraphifyIndexCache, Set, String

### Community 573 - "main.swift"
Cohesion: 0.43
Nodes (3): AboutPanelController, AboutView, NSWindow

### Community 574 - "generate-release-notes.swift"
Cohesion: 0.17
Nodes (10): Configuration, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, TabContextCommand, close, closeOthers, rename, splitHorizontal (+2 more)

### Community 575 - ".toastErrorSummary"
Cohesion: 0.29
Nodes (7): Agent hooks for Kouen, CLI notification, Example Claude Code hook, Jump to waiting agent, OSC sequences (from terminal output), Per-agent guides, Set up via your IDE (copy/paste prompt)

### Community 576 - "Phase67Tests"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 577 - "SwarmFleetView"
Cohesion: 0.29
Nodes (7): 1. Plain Terminal, 2. Persistent Terminal, 3. Full Terminal, 4. Agent Workspace, Experience modes, Opting into the prefix + status line without switching modes, Persistence (ephemeral vs. persistent)

### Community 578 - "TaskDashboardBody"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Kouen-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 580 - "ViInputMode"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 581 - "jD"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 582 - "FileTreeKeyboardNavigator"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 583 - "WorkbenchMRU"
Cohesion: 0.25
Nodes (4): _c(), Nn(), Pqe, qp()

### Community 584 - "GUt"
Cohesion: 0.25
Nodes (5): Bool, NSEvent, ViInputMode, insert, normal

### Community 585 - "TargetSpec.swift"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

### Community 586 - ".consumeInputCore"
Cohesion: 0.29
Nodes (6): Locked decisions (user-confirmed), Logical Design, P38 Phase A — Cross-Agent Worktree Diff/Review Dashboard — Design, Strategic Design, Tactical Design, Verification gate (this phase)

### Community 587 - "BrowserResponsePayload"
Cohesion: 0.29
Nodes (6): Logical Design, Next Step, P42 — Workspace Sidebar Panels, Parked (not in scope), Strategic Design, Tactical Design

### Community 588 - "jHt"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 591 - "FormatContextDaemonTests"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 592 - "commit-push.sh"
Cohesion: 0.38
Nodes (6): Cleanup And Quit, Create Config File, No Config File Starts Normally, Script Hot Reload On Save, Script Loads On Startup, Script Syntax Error Does Not Crash

### Community 594 - "r2"
Cohesion: 0.29
Nodes (6): Bug 1 - Browser Pane Deferred Unregister, Bug 1 - Browser Pane Reuse On Rebuild, Bug 2 - New Session Syncs Before Reading Active Tab, Bug 2 - Tab Bar New Tab Also Syncs, Bug 3 - Browser Pane Forces Redraw On Reattach, Build Compiles Successfully

### Community 596 - ".feed(_:)"
Cohesion: 0.47
Nodes (5): AgentIconArt, AgentVectorIcon, Bool, CGSize, String

### Community 598 - "DecodedWSFrame"
Cohesion: 0.29
Nodes (3): ScrollbackPersistenceTests, String, URL

### Community 600 - "PaletteWindowDelegate"
Cohesion: 0.33
Nodes (6): Command, .targetKind, TargetKind, pane, session, window

### Community 601 - "Hwe"
Cohesion: 0.29
Nodes (6): .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8

### Community 605 - "drn"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 606 - "Quick start"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase D — Kitty Graphics Conformance Slice, Scope (locked), Tests

### Community 607 - "iRe"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua), Scope (locked), Tests

### Community 608 - "W2"
Cohesion: 0.33
Nodes (5): Logical Design, Next Step, P43 — Add Repo/Folder to Workspace, Strategic Design, Tactical Design

### Community 609 - "FormatContextDaemonTests"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 613 - "INDEX.md"
Cohesion: 0.47
Nodes (3): URL, TimeoutError, WorktreeLargeOutputRegressionTests

### Community 614 - "MainSplitViewController"
Cohesion: 0.33
Nodes (5): Kouen LSP Diagnostics Does Not Crash, Kouen LSP Hover Returns Result, Kouen LSP Start Returns JSON, Kouen View Binary Shows Guard Message, Kouen View Prints File Content

### Community 615 - "fences"
Cohesion: 0.67
Nodes (3): AsyncCLIResultBox, Error, Result

### Community 617 - "ScriptFileWatcher"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 618 - "parse"
Cohesion: 0.40
Nodes (3): NSEvent, WorktreeCardView, NSGestureRecognizer

### Community 620 - "mS"
Cohesion: 0.40
Nodes (5): CwdAuthorizationError, foreignPathRejected, .message, missingSessionOrCwd, other

### Community 622 - "[1.3.0-vit] - 2026-06-06"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: animateSidebar setContentLeadingInset MainSplitViewController, Source Nodes

### Community 623 - "BrowserResponsePayload"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: ProjectCategory FolderScanner ProjectDirectoryTree, Source Nodes

### Community 624 - "[2.5.0] - 2026-06-12"
Cohesion: 0.40
Nodes (5): ColorKind, .base, bg, fg, underline

### Community 625 - "brt"
Cohesion: 0.40
Nodes (3): .init(forTesting:), UUID, Void

### Community 626 - "cGt"
Cohesion: 0.40
Nodes (5): BellScanState, esc, normal, string, stringEsc

### Community 629 - "graphify reference: query, path, explain"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 630 - "d3n"
Cohesion: 0.60
Nodes (3): .encode(_:modifiers:event:modes:), SpecialKey, insert

### Community 631 - "ImmersiveEffects"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 632 - "dne"
Cohesion: 0.40
Nodes (4): Build, Release & Git Workflow, Build / Test / Run, Release packaging order, Worktree constraint

### Community 633 - "g_n"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 634 - "qC"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 635 - "yDt"
Cohesion: 0.70
Nodes (4): main(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 636 - ".handleCopyModeKey"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 637 - "ClientSummary"
Cohesion: 0.40
Nodes (4): Leak A - Retiring A Host Drops Its AI Controllers, Leak B - Browser Network Capture Is Bounded, Leak C - Every Per-Surface Dict In Coordinator Has Retire Cleanup, Leak D - Every Per-Surface Dict In NotificationCoordinator Is Snapshot-Swept

### Community 639 - "gpn"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 643 - "h7n"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

### Community 644 - "clean-state.sh"
Cohesion: 0.50
Nodes (4): Full local signing path (needs a Developer ID cert; not currently used), How this fork actually releases, Release runbook, Scripted flow

### Community 645 - "stability_release.robot"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 646 - "[3.10.1] - 2026-06-27"
Cohesion: 0.50
Nodes (3): exclude_hubs, no_viz, wiki

### Community 647 - "graphify reference: query, path, explain"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: SSETransport auth token isRunning

### Community 648 - "PtyDrainCeilingBenchmark"
Cohesion: 0.40
Nodes (4): hrn(), KGe(), prn(), qGe()

### Community 649 - "h$t"
Cohesion: 0.50
Nodes (3): SplitDirection, horizontal, vertical

### Community 651 - "u0n"
Cohesion: 0.50
Nodes (4): dO(), m8(), rfn(), zfn()

### Community 653 - "iOn"
Cohesion: 0.67
Nodes (4): FVe(), hJ(), qVe(), Zme()

### Community 655 - "nht"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 656 - "Jcn"
Cohesion: 0.50
Nodes (3): WriteOrigin, automation, human

### Community 657 - "clear-runtime-state.sh"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 658 - "k0n"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 659 - "MCPServer"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 660 - "qAn"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 662 - "New Tab"
Cohesion: 0.50
Nodes (3): Bug 1 - Hunks Button Has Explicit Size Constraints, Bug 1 - Hunks Button Symbol Has A Guaranteed-Valid Fallback, Build Compiles Successfully

### Community 663 - "m6e"
Cohesion: 0.50
Nodes (3): Guard A - Merge Call Site Never Passes --no-ff, Guard B - No Auto-Resolve Anywhere In The Merge/Conflict Path, Guard C - Merge Conflict State Is Reconciled, Not Just Read Once

### Community 664 - "P37 Phase G — Autocomplete (mobile bridge)"
Cohesion: 0.50
Nodes (3): RawSocketError, connectFailed, writeFailed

### Community 669 - ".handleUndo"
Cohesion: 0.67
Nodes (3): G4(), sHe(), U3()

### Community 670 - "pie"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 671 - "Hwe"
Cohesion: 0.67
Nodes (3): cat(), Hwe(), kYe()

### Community 672 - "ColorKind"
Cohesion: 0.67
Nodes (3): cfn(), fut(), qYe()

### Community 673 - "qte"
Cohesion: 0.67
Nodes (3): dht(), k0t(), l1n()

### Community 675 - ".detect"
Cohesion: 0.67
Nodes (3): iRe(), jNt(), zNt()

### Community 703 - "ColorKind"
Cohesion: 0.09
Nodes (6): ClaudeCodeHarnessIPCTests, String, URL, EndpointClientTests, String, URL

## Knowledge Gaps
- **2346 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+2341 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1105 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `SurfaceProgressTrackerTests.swift` to `[1.0.6] - 2026-06-02`, `IPCRequest`, `.testManyConcurrentSubscribersAllReceiveOutput`, `Command`, `LSPMessage`, `TerminalEmulator`, `PerformanceBenchmarks`, `.gestureRecognizer`, `Changed`, `VTParser`, `HarnessTerminalSurfaceView`, `.applyPreedit`, `MetalRendererTests`, `HarnessUILibrary`, `SpecialKey`, `code:block1 (Agent shell process)`, `HarnessTerminalSurfaceView`, `CopyModeAction`, `SplitPaneCoordinator`, `.request`, `WorktreeManager`, `Harness tmux-style capabilities`, `RGBColor`, `.parse`, `.sessionID`, `Notification`, `Sendable`, `.addTab`, `Added`, `LegacySnapshot`, `install-app.sh`, `code:bash (harness chat "Use the project map first, then inspect this r)`, `String`, `code:bash (swift build)`, `harness.resource`, `HarnessSidebarPanelViewController.swift`, `HarnessOverlayBackground`, `.buildCommand`, `.normalizedKey`, `HookEvent`, `DaemonServer`, `BrowserResponsePayload`, `Added`, `Fixed`, `Added`, `.keyEvent`, `NSPanel`, `BellScanState`, `PasteBufferStore`, `3.2 สิ่งที่ implement แล้ว`, `ComposedCell`, `HarnessCLI+Server.swift`, `ShellIntegration`, `ViInputMode`, `worktree_isolation_cli.robot`, `ImportedTerminalConfig`, `XCTestCase`, `README.md`, `[2.6.0] - 2026-06-13`, `OptionStore`, `.parse`, `jHt`, `Added`, `DaemonSubscription`, `.firstMatch`, `full-cycle.sh`, `LSPDiagnostic`, `TerminalGridCell`, `HarnessPaths`, `Harness as a terminal multiplexer`, `Hwe`, `TerminalModes`, `code:bash (# Terminal 1: Create workspace with long-running job)`, `shim.c`, `Harness Usage`, `PaneContainerView`, `.hasOverflowRows`, `INDEX.md`, `fences`, `Recipe`, `Changelog`, `domain-design.md`, `.resolve`, `DamageTrackingTests`, `code:text (:workbench start swift)`, `[2.5.0] - 2026-06-12`, `.makeSnapshot`, `.firstWaitingTab`, `SessionGroup`, `PaneNode`, `Harness command reference`, `Added`, `Changed`, `ViEngine`, `ImmersiveEffects`, `String`, `.path`, `gpn`, `code:block1 (SessionCoordinator.snapshot ──┐)`, `[3.10.0] - 2026-06-27`, `Harness`, `.install`, `rPt`, `CommandTarget`, `.startWatching`, `ActivePaneService`, `hjt`, `แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)`, `TerminalHostView`, `.testPaneLeafLegacyDecodeBackfillsSurfaceTabs`, `CopyModeGridSource`, `DecodedImage`, `FileTreeWatcher`, `TriState`, `EnvironmentStore`, `nb`, `What You Must Do When Invoked`, `LiveResizeTests`, `Int`, `ThaiCombiningMarkTests`, `Added`, `Fixed`, `Fixed`, `What You Must Do When Invoked`, `Workspace`, `ActiveTabCloseDisposition`, `.selectAdjacentSession`, `.daemonIsStale`, `Added`, `Fixed`, `BoardCard`, `.rects`, `InlineAICompletionView`, `GridCompositorTests`, `LSPServerRegistry`, `targets`, `.make`, `BrowserPaneView`, `P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client`, `ScriptRuntime`, `AgentSessionSummary`, `code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)`, `PaletteModel`, `Harness keybindings`, `scheduleRender`, `.testDataFrameEncodeVsJSONBase64Output`, `SettingsRemoteView`, `.translate`, `NotchLayoutMetrics`, `.lines`, `AI-SDLC Task Progress — headless-worker-followup`, `Section`, `TerminalServicesProvider`, `AgentNotchRowSummary`, `ANSIPalette`, `CellColorResolver`, `Fixed`, `SSHTunnelManagerTests`, `sessionRow`, `.decide`, `HarnessGridTerminalTests`, `ExternalOpenKind`, `.matchingTab`, `DecodedWSFrame`, `.scan`, `Added`, `TerminalMetalRenderer`, `PaneBorderStatus`, `AgentBridge`, `.make`, `ThemeDocumentTests`, `Experience modes`, `ReflowPreviewTests`, `SessionCoordinator`, `NSViewRepresentable`, `BoardViewController`, `release-hotfix.sh`, `Sidebar SwiftUI Migration — Knowledge`, `WindowTitleStripView`, `ThemeFileServiceTests`, `HarnessSidebarPanelViewController`, `code:bash (harness-cli install-hooks claude-code)`, `DefaultTerminalManager`, `Fixed`, `P8: macOS 27 Golden Gate Adoption`, `SyntaxTextView`, `BlockTintOverlay`, `DisplayPanesOverlay`, `.menu`, `TerminalScrollbarView`, `RemoteHostStoreTests`, `M5 — Saved Layouts — Task Progress`, `After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md.`, `code:bash (harness-cli install-hooks hermes)`, `AgentHookStrategy`, `StatusLineWidthTests`, `JSONDecoder`, `NotificationBus`, `.parse`, `ThemeDiagnostics`, `00-inception-plan.md`, `.script`, `Fixed`, `ViPathTokenTests`, `Send Ex Command`, `Browser DevTools API (P28)`, `FrameSignposter`, `Bug: Tab-Switch Black Screen`, `Terminal AI Chat (⌘I inline overlay)`, `code:bash (harness-cli install-hooks grok)`, `Focus Persistence — Per-Session-Tab Pane Focus (RL-043)`, `WorkspaceSymbolIndex`, `ImmersivePalette.swift`, `.drawGlyph`, `Added`, `RealPty`, `ImageProtocolTests.swift`, `.makeModel`, `Foundation`, `code:bash (harness-cli install-hooks openclaw)`, `FileViewerViewController`, `README.md`, `[3.2.0] - 2026-06-16`, `Background Polling & Snapshot Fanout — P22`, `P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)`, `[3.5.1] - 2026-06-20`, `RGBColor`, `generate-cheatsheet.js`, `Added`, `Fixes Applied (v3.9.1+)`, `Consumers`, `Git Panel`, `.encode`, `P13 — Embedded Browser Pane (cmux parity)`, `.run`, `MCPServer`, `PromptQueue`, `NSTextField Leak in BoardViewController (P20 Performance)`, `finalize-release.sh`, `measure-fluidity.sh`, `package-app.sh`, `AgentIconRenderer`, `Session/Tab/Pane Hierarchy & Top Bar (CASE-028)`, `.applyTerminalIdentity`, `Task 1: Redesign Session Sidebar`, `json.json`, `RealPtyLifecycleTests`, `.parseDiffHunks`, `Competitive Position (as of v3.12.0, 2026-07-02)`, `BoardCardView`, `Project History`, `WaitForRegistry`, `PickerItemRow`, `RemoteHostStore`, `BlockContextMenuTests`, `Modifiers`, `tmux parity — status, adaptations, and deliberate divergences`, `DirectionalAxis`, `Never`, `.resolve`, `Added`, `ccRunGet`, `.bind`, `.automationList`, `.json`, `ACP Client (Shelved)`, `WindowBorderOverlayView`, `memory_leak_guards.robot`, `start.mjs`, `.panePathLookup`?**
  _High betweenness centrality (0.280) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `HookEvent` to `AgentHookStrategy`, `Changed`, `code:bash (harness chat "Use the project map first, then inspect this r)`, `.install`, `code:bash (swift build)`, `CommandPromptController`, `ReflowCorpusTests`, `Fixed`, `.encodeMouse`, `PaneBorderStatus`, `Fixed`, `GroupedSessionDaemonTests`, `SurfaceProgressTrackerTests.swift`, `shim.c`?**
  _High betweenness centrality (0.219) - this node is a cross-community bridge._
- **Why does `fbt()` connect `callingPaneTarget` to `CodingKey`, `Changed`, `HarnessTerminalSurfaceView.swift`, `.encodeMouse`?**
  _High betweenness centrality (0.122) - this node is a cross-community bridge._
- **Are the 18 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `RenderScheduler`) actually correct?**
  _`KouenTerminalSurfaceView` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _2366 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.005621201344885555 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.013057296072135401 - nodes in this community are weakly interconnected._