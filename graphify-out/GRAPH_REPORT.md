# Graph Report - fix-task-badge-refresh  (2026-11-12)

## Corpus Check
- 946 files · ~1,051,316 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 19967 nodes · 58092 edges · 2656 communities (1489 shown, 1167 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8858 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `20afbf28`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 345 edges
2. `i()` - 321 edges
3. `a()` - 284 edges
4. `t()` - 253 edges
5. `SessionCoordinator` - 235 edges
6. `TerminalEmulator` - 229 edges
7. `SurfaceRegistry` - 224 edges
8. `u()` - 219 edges
9. `DaemonClient` - 214 edges
10. `KouenCLI` - 210 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 190 areas (208 edges)
2. `Command` - bridges 101 areas (108 edges)
3. `AgentKind` - bridges 89 areas (176 edges)
4. `t()` - bridges 83 areas (253 edges)
5. `IPCResponse` - bridges 79 areas (104 edges)
6. `KouenTerminalSurfaceView` - bridges 76 areas (345 edges)
7. `KouenGridTerminal` - bridges 67 areas (117 edges)
8. `SessionCoordinator` - bridges 65 areas (235 edges)
9. `NSView` - bridges 64 areas (193 edges)
10. `SurfaceRegistry` - bridges 61 areas (224 edges)

## Surprising Connections (you probably didn't know these)
- `.selectedHost` --references--> `RemoteHost`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRemoteView.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.terms` --calls--> `SearchMatcher`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/UI/History/HistorySearchEvidence.swift → Packages/KouenCore/Sources/KouenCore/Search/SearchMatcher.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/RemoteHostsService.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.selectWorkspace(byIndex:)` --references--> `SessionSnapshot`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/SessionCoordinator.swift → Packages/KouenIPC/Sources/KouenIPC/SessionSnapshot.swift

## Import Cycles
- None detected.

## Communities (2656 total, 1167 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.01
Nodes (578): _0t(), _1n(), _1t(), _2t(), _3e(), a1t(), a3n(), a4n() (+570 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.01
Nodes (371): l, _4e(), _4n(), _6e(), _6n(), _8n(), _9e(), a0() (+363 more)

### Community 2 - ".handleNormal"
Cohesion: 0.03
Nodes (320): m(), pe(), r, X(), A(), code(), R(), a() (+312 more)

### Community 3 - "Changed"
Cohesion: 0.02
Nodes (316): a(), b(), c(), d(), e(), f(), g(), h() (+308 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.05
Nodes (44): AgentBridge, AgentTarget, Bool, String, SurfaceID, .onCurrentCWD, .onCurrentFile, LinePos (+36 more)

### Community 5 - "IPCRequest"
Cohesion: 0.04
Nodes (21): NSCursor, NSEvent, String, Any, Bool, NSMenu, NSMenuItem, NSPasteboard (+13 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.08
Nodes (26): IndexingIterator, LayoutTemplate, SessionEditor, .addSurface(tabID:paneID:), .addSurface(to:paneID:surfaceID:cwd:), .surfaceID(forPaneID:in:), .tab(containingPaneID:), .tab(for:) (+18 more)

### Community 7 - "Command"
Cohesion: 0.11
Nodes (27): ch(), cvt(), d1t(), dln(), dV(), e9e(), ew(), ik() (+19 more)

### Community 8 - "LSPMessage"
Cohesion: 0.06
Nodes (31): TerminalModes, InputEncoder, .encode(_:modifiers:event:modes:), .encode(text:modifiers:modes:), .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release (+23 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.05
Nodes (32): .tab(forSurfaceKey:), AgentScanner, Bool, DispatchSourceTimer, TimeInterval, DaemonCommandExecutor, Command, .init(forTesting:) (+24 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.09
Nodes (33): .saveRecordsBatch(_:), CachedSessionEntry, AgentHistoryScanner, .parseAntigravityTranscript(sessionID:fileURL:), .parseAntigravityTranscript(sessionID:fileURL:toIndex:), .parseClaudeTranscript(fileURL:), .parseClaudeTranscript(fileURL:toIndex:), .parseCodexTranscript(fileURL:surfaceTag:ftsIndex:) (+25 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.07
Nodes (37): SettingsAppearanceView, .autoTheme, .body, .themeSection, .windowSection, SliderRow, .body, .displayValue (+29 more)

### Community 12 - "Changed"
Cohesion: 0.07
Nodes (31): KeybindingsService, Bool, Command, String, KeySpec, .description, .init(from:), .init(key:modifiers:) (+23 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.09
Nodes (22): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+14 more)

### Community 14 - "VTParser"
Cohesion: 0.07
Nodes (39): Equatable, DecodedImage, .byteCount, UInt8, Bool, CAMetalDrawable, .currentSelectionRegion, ClosedRange (+31 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.10
Nodes (37): MTLClearColor, MTLCommandBuffer, MTLLibrary, MTLRenderCommandEncoder, MTLRenderPipelineState, BgInstance, CursorCacheKey, .invertsGlyph (+29 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.12
Nodes (13): AgentDetection, AgentDetector, MatchSource, ownProcess, wrapperLaunch, RawMatch, Date, Int32 (+5 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.07
Nodes (26): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, AutomationScheduler (+18 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.12
Nodes (15): KouenGridTerminal, TerminalDamage, RenderColor, MTLTexture, MetalRendererTests, .makeRenderer(device:atlasSize:atlasMaxPages:), RenderedFixture, Bool (+7 more)

### Community 19 - "SpecialKey"
Cohesion: 0.10
Nodes (19): .exit, String, String, String, String, KouenCLI, SessionID, String (+11 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.09
Nodes (12): .receive(_:), DispatchSemaphore, FluidityBenchmarks, NSWindow, String, UInt64, KouenTerminalSurfaceWorkerTests, Bool (+4 more)

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.10
Nodes (24): AnyTransition, AgentNotchPeekEvent, Reason, errored, finished, needsInput, AgentNotchRootView, .bottomRadius (+16 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.09
Nodes (28): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, .body, PaletteModel (+20 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.13
Nodes (14): PickerItem, .groupLabel, historyBlock, .id, recipe, .searchableText, RecipePickerModel, NSWindow (+6 more)

### Community 24 - ".request"
Cohesion: 0.06
Nodes (36): .body, MainActor, NSFont, Void, SessionDividerRowView, .init(coder:), .init(frame:), SessionGroupHeaderRowView (+28 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.08
Nodes (16): Darwin, Glibc, KouenCore, KouenDaemonCore, IPCCodecInvariantTests, ConcurrentIndexSet, .count, RawSocketError (+8 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.09
Nodes (12): Configuration, Bool, Command, DispatchWorkItem, PaneID, String, UInt8, TabSelector (+4 more)

### Community 27 - "RGBColor"
Cohesion: 0.08
Nodes (30): ColorKind, .base, bg, fg, underline, ComposedCell, .asGridCell, .cluster (+22 more)

### Community 28 - ".parse"
Cohesion: 0.09
Nodes (11): Int, HistoryLine, ImagePlacement, Pen, SavedCursor, Bool, ClosedRange, Range (+3 more)

### Community 29 - "Added"
Cohesion: 0.09
Nodes (15): PluginLoader, String, ScriptAPI, ScriptError, .errorDescription, evaluationError, unsupportedPlatform, ScriptRuntime (+7 more)

### Community 30 - "Notification"
Cohesion: 0.06
Nodes (42): DaemonSubscription, .start(onData:onEnd:buffered:), Bool, String, UInt16, UInt64, EndpointConnector, Int32 (+34 more)

### Community 31 - "Sendable"
Cohesion: 0.06
Nodes (42): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, .init(from:), .init(id:name:baseURL:modelID:), ModelProvider (+34 more)

### Community 32 - ".addTab"
Cohesion: 0.11
Nodes (11): .agentColorBinding, colors, PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Double, String (+3 more)

### Community 33 - "Equatable"
Cohesion: 0.07
Nodes (16): DisplayWidth, String, Unicode, ReleaseNotes, Section, String, Run, String (+8 more)

### Community 34 - "DaemonClient"
Cohesion: 0.08
Nodes (23): DaemonClient, .start(onResponse:onEnd:), Int32, TimeInterval, UUID, Void, .onResponse, ClaudeCodeHarnessIPCTests (+15 more)

### Community 35 - "MenuTarget"
Cohesion: 0.08
Nodes (20): OSCTerminatorMatch, PtyError, launchFailed, RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), ScrollbackEntry, ScrollbackReplaySegment, ShellLaunchProfile (+12 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.06
Nodes (36): _5e(), a0n(), Bm(), cmn(), dl(), eAn(), eht(), Em() (+28 more)

### Community 37 - "String"
Cohesion: 0.09
Nodes (8): KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), SpawnedAgentSurface, Bool, ISO8601DateFormatter, String, Tab, UUID

### Community 38 - "code:bash (swift build)"
Cohesion: 0.15
Nodes (7): AnyCodable, JSONRPCError, Bool, Int32, Pipe, String, ToolRegistry

### Community 39 - "TerminalColorGamut"
Cohesion: 0.08
Nodes (21): Data, DecodedReplyFrame, output, reply, DecodedRequestFrame, input, request, FrameError (+13 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.05
Nodes (34): o, AI(), aXe(), aZ(), bee(), cy(), Da(), dH() (+26 more)

### Community 41 - "CodingKeys"
Cohesion: 0.06
Nodes (18): KouenCLITests, URL, DetachKeys, absent, invalid, parsed, Int32, String (+10 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.06
Nodes (28): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+20 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.08
Nodes (10): SessionCoordinator, .selectWorkspace(_:), Bool, Double, PaneID, String, SurfaceID, TabID (+2 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.09
Nodes (21): MochaTheme, ANSIPalette, UInt8, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors, Bool (+13 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.08
Nodes (23): Error, LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed, serverNotExecutable, AsyncStream (+15 more)

### Community 46 - ".buildCommand"
Cohesion: 0.06
Nodes (13): NWEndpoint, Bool, NWListener, Sendable, String, UInt16, MobileBridgeServer, PipeBuffer (+5 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.06
Nodes (25): Selector, Kind, primary, secondary, KouenPillButton, .init(title:kind:), .isHovered, .isPressed (+17 more)

### Community 48 - "HookEvent"
Cohesion: 0.04
Nodes (60): al(), ap(), apn(), b1t(), bdn(), bIn(), c4n(), d7e() (+52 more)

### Community 49 - "DaemonServer"
Cohesion: 0.08
Nodes (44): Codable, BrowserSnapshotAck, BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserRequestPayload, close (+36 more)

### Community 50 - "Added"
Cohesion: 0.08
Nodes (28): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary, RowKind (+20 more)

### Community 51 - ".keyEvent"
Cohesion: 0.07
Nodes (21): SessionStore, DispatchWorkItem, TimeInterval, PendingVersionBanner, welcome, whatsNew, State, Bool (+13 more)

### Community 52 - "Fixed"
Cohesion: 0.03
Nodes (88): V, _5n(), a2t(), a4e(), a8n(), agt(), aV(), b2() (+80 more)

### Community 53 - "Added"
Cohesion: 0.10
Nodes (18): .requestDaemon(_:), .selectWorkspace(byIndex:), .syncFromDaemon(metadataOnly:), ActiveTabCloseDisposition, session, tab, window, workspace (+10 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.08
Nodes (14): DetachedPaneOverlay, .init(coder:), .init(frame:style:), OutputCoalescer, Style, detached, reconnectingChip, NSCoder (+6 more)

### Community 55 - "TabCell"
Cohesion: 0.12
Nodes (13): SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, SessionID, String, SurfaceID (+5 more)

### Community 56 - "NSPanel"
Cohesion: 0.13
Nodes (9): Tab, PaneContainerView, SurfaceID, PaneLifecycleManager, Bool, PaneID, Set, String (+1 more)

### Community 57 - "BellScanState"
Cohesion: 0.07
Nodes (40): ButtonStyle, CommandRow, .body, GlassCard, .body, GlassPrimaryButtonStyle, GlassSecondaryButtonStyle, GlassStatusButtonStyle (+32 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.18
Nodes (3): KouenSettingsTests, URL, Void

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.12
Nodes (21): AgentHistoryFTSIndex, .deleteSession(sessionID:), .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:surfaceTag:topicSegments:), .needsReindex(sessionID:mtime:fileSize:), .pruneMissingSessions(validTranscriptPaths:), .saveRecord(_:mtime:fileSize:), .search(query:limit:), .searchRanked(query:limit:includeSnippet:requireAllTokens:includeMetadata:matchingIDs:) (+13 more)

### Community 60 - "ViEngine"
Cohesion: 0.06
Nodes (24): Logger, OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, .event(_:), .interval(_:_:) (+16 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 62 - "ComposedCell"
Cohesion: 0.09
Nodes (7): Divergence, Bool, String, TimeInterval, WorktreeInfo, String, WorktreeIsolationTests

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.15
Nodes (8): MainSplitViewController, .setSidebarVisible(_:), Bool, CGFloat, DispatchWorkItem, NSColor, NSRect, Notification

### Community 64 - ".text"
Cohesion: 0.11
Nodes (14): Group, ParsedShortcut, .displayString, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, PrefixKeymap, Any (+6 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.09
Nodes (14): DiffLineType, added, deleted, modified, Bool, DispatchWorkItem, NSEvent, NSPopover (+6 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.14
Nodes (9): AgentHistoryDateGroup, older, .sortOrder, thisWeek, today, yesterday, Combine, KouenIPC (+1 more)

### Community 67 - "String"
Cohesion: 0.12
Nodes (15): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, Bool, Double (+7 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.12
Nodes (16): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+8 more)

### Community 69 - ".compose"
Cohesion: 0.08
Nodes (11): .isHidden, .removeWorktreeAction(path:), GitResult, Bool, GitResult, String, TimeInterval, ValidateOutcome (+3 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.06
Nodes (13): SessionGroup, SessionID, String, KouenSidebarPanelViewController, NSMenuItem, SessionGroup, String, NSMenu (+5 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.13
Nodes (10): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, PaneID (+2 more)

### Community 72 - "XCTestCase"
Cohesion: 0.07
Nodes (38): .pairedAlreadyBanner, .pairingQRPanel, ArtifactKind, html, image, markdown, text, AutomationsFleetModel (+30 more)

### Community 73 - "README.md"
Cohesion: 0.13
Nodes (14): NSEvent, PaneDropZoneOverlay, .init(coder:), .init(targetPaneID:), NSCoder, NSPoint, NSRect, PaneID (+6 more)

### Community 74 - "[2.6.0] - 2026-06-13"
Cohesion: 0.07
Nodes (15): ScreenPos, bottom, middle, top, KouenLSP, FileGraphInfo, GraphifyLSPBridge, Double (+7 more)

### Community 75 - "OptionStore"
Cohesion: 0.04
Nodes (62): NSView, OverlayBackground, Context, OverlayBackground, Context, AgentChipView, .init(coder:), .init(frame:) (+54 more)

### Community 76 - ".parse"
Cohesion: 0.07
Nodes (15): .readJSONLLines(from:fromOffset:), ClaudeSessionLocator, ClaudeTranscriptLine, Role, assistant, user, Any, Bool (+7 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.09
Nodes (26): .filteredJobs, MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith (+18 more)

### Community 78 - "Added"
Cohesion: 0.06
Nodes (50): AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, CodingKeys, excludedPaths (+42 more)

### Community 79 - "HarnessDesign"
Cohesion: 0.09
Nodes (16): .effectiveResumeCommand(claudeMode:), LiveClaudeAgentEntry, .placement, ClaudeSessionMode, TimeoutFlag, .didFire, ClaudeCloudSessionStore, Entry (+8 more)

### Community 80 - "Agent handbook — Harness (extended reference)"
Cohesion: 0.09
Nodes (23): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, IssueInfo (+15 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.10
Nodes (9): AgentTableEntry, Bool, Set, WrapperOptionBehavior, keepScanning, matchValue, skipValue, stopScanning (+1 more)

### Community 82 - ".firstMatch"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 83 - "LSPClient"
Cohesion: 0.09
Nodes (18): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+10 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.08
Nodes (24): CoreGraphics, CoreText, Foundation, ImageIO, KouenCopyMode, KouenTerminalEngine, KouenTerminalRenderer, KouenTheme (+16 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.18
Nodes (11): .mcpButton, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter, Any, Range (+3 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.10
Nodes (19): Coordinator, DiffAnalysis, DiffFileItem, DiffFileStatus, added, .color, deleted, modified (+11 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.08
Nodes (26): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+18 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.07
Nodes (16): surfaceID, .surfaceID(forPaneID:), Command, SessionEditorPhase4Tests, PaneID, TabID, WorkspaceID, LegacySnapshot (+8 more)

### Community 89 - ".cursorPos"
Cohesion: 0.07
Nodes (11): Bool, Range, Set, String, URLDetection, CGFloat, CGRect, Range (+3 more)

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.09
Nodes (13): CGFloat, NSEvent, NSEvent, UInt8, CGFloat, NSEvent, NSPoint, UInt16 (+5 more)

### Community 91 - "TerminalModes"
Cohesion: 0.06
Nodes (33): JSONDecoder, JSONEncoder, CodingKeys, cols, createdAt, dataBase64, rows, timeMs (+25 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.05
Nodes (39): Completed Plans Archive, Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions, Logical Design, P41 — Automations, Strategic Design (+31 more)

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.07
Nodes (15): EditorDividerView, HitTestPassthroughView, .init(coder:), PaneDragGripView, .init(coder:), PaneHoverButton, PaneSplitButtonsView, .init(coder:) (+7 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.08
Nodes (18): NSScrollView, NSWindow, Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent (+10 more)

### Community 95 - "shim.c"
Cohesion: 0.11
Nodes (17): Bool, AgentSessionHistoryView, .body, .footerView, .subHeaderView, HistoryMenuProxy, Any, Bool (+9 more)

### Community 96 - "Harness Usage"
Cohesion: 0.29
Nodes (3): ChromeRole, sidebar, tabBar

### Community 97 - "PaneContainerView"
Cohesion: 0.12
Nodes (10): ScrollbackFile, .highWater, Bool, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.16
Nodes (4): hooks, AgentHookInstallerTests, String, URL

### Community 99 - ".dispatch"
Cohesion: 0.08
Nodes (27): ClientRecord, CountBox, DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed (+19 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.10
Nodes (47): Ame(), aQt(), aXt(), aze(), Cme(), Cqt(), cXt(), dXt() (+39 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.15
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 102 - "DaemonLauncher"
Cohesion: 0.08
Nodes (24): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, .acceptsFirstResponder (+16 more)

### Community 103 - "AnyCodable"
Cohesion: 0.09
Nodes (22): KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:fileSearchRoots:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:), .scrollbackLines, ResizeOverlayMode, afterFirst, always, never (+14 more)

### Community 104 - "Recipe"
Cohesion: 0.09
Nodes (39): Encodable, ExpressibleByStringLiteral, AgyModelsPush, AISuggestionAck, AttachedAck, Body, BrowserFramePush, Cred (+31 more)

### Community 105 - "Changelog"
Cohesion: 0.10
Nodes (15): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+7 more)

### Community 106 - "domain-design.md"
Cohesion: 0.14
Nodes (15): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+7 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.18
Nodes (11): SwarmSpawnSpec, CallRecorder, .cancelCalls, .closeCalls, .harnessCalls, .surfaceCalls, SwarmWorkerManagerTests, Bool (+3 more)

### Community 108 - ".resolve"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.12
Nodes (23): TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid, .gridOriginPointsX (+15 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.10
Nodes (15): FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect, String, URL (+7 more)

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.11
Nodes (19): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerFooter, .body, DirectoryPickerModel (+11 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.14
Nodes (18): CommandParseError, .description, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand (+10 more)

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.15
Nodes (9): FormatContext, FormatString, FormatStyle, Bool, Character, Date, String, FormatStyledTests (+1 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.11
Nodes (14): AsyncRunCoordinator, OutputBuffer, ProcessResult, .isSuccess, ProcessRunner, Bool, CheckedContinuation, DispatchWorkItem (+6 more)

### Community 115 - ".encode"
Cohesion: 0.08
Nodes (25): CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display, found, .isReady (+17 more)

### Community 116 - "SessionGroup"
Cohesion: 0.15
Nodes (9): StringKind, apc, dcs, UInt8, UnsafeBufferPointer, VTParser, .feed(_:), VTParserHandler (+1 more)

### Community 117 - "PaneNode"
Cohesion: 0.06
Nodes (22): DaemonClientActor, TimeInterval, daemonError, DaemonSessionService, .endpoint, .request(_:timeout:), Bool, TimeInterval (+14 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.16
Nodes (5): ContentAreaViewController, Bool, CGFloat, String, TabID

### Community 119 - "Harness command reference"
Cohesion: 0.15
Nodes (9): MarkdownPreviewView, .webView(_:decidePolicyFor:decisionHandler:), Bool, MainActor, Sendable, String, URL, WKNavigationAction (+1 more)

### Community 120 - "Added"
Cohesion: 0.08
Nodes (41): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+33 more)

### Community 121 - "Changed"
Cohesion: 0.06
Nodes (35): Executor, Hook, HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane (+27 more)

### Community 122 - "ViEngine"
Cohesion: 0.12
Nodes (17): FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID, FeatureTask (+9 more)

### Community 123 - "Pipe"
Cohesion: 0.21
Nodes (7): BrowserOkAck, Sendable, T, ConnectionState, ErrorAck, NWConnection, UUID

### Community 124 - "String"
Cohesion: 0.08
Nodes (30): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+22 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.15
Nodes (20): AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), .stats, GlyphAtlasStats (+12 more)

### Community 126 - ".path"
Cohesion: 0.10
Nodes (12): Bool, String, UInt8, TerminalEmulator, .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .onSetClipboard, TerminalColorRole (+4 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.17
Nodes (8): FileNode, Bool, String, FileTreeScanOptions, ScoredMatch, Bool, String, .scanOptions

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.11
Nodes (10): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+2 more)

### Community 129 - "SwiftUI"
Cohesion: 0.15
Nodes (11): Status, ciFailing, done, mergeReady, open, running, Bool, Date (+3 more)

### Community 130 - "Harness"
Cohesion: 0.06
Nodes (31): .init(coder:), .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), BrowserProgressLine, .init(coder:), .init(frame:), BrowserTabButton, .init(coder:) (+23 more)

### Community 131 - ".install"
Cohesion: 0.05
Nodes (40): BrowserPaneRegistry, BrowserPaneView, .activeTab, .init(url:paneID:), .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), .webView(_:didCommit:), .webView(_:didFinish:) (+32 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.15
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 133 - ".load"
Cohesion: 0.15
Nodes (10): ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID, String, SurfaceID (+2 more)

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.09
Nodes (19): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+11 more)

### Community 135 - "CommandTarget"
Cohesion: 0.10
Nodes (14): T, constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String (+6 more)

### Community 136 - ".startWatching"
Cohesion: 0.14
Nodes (8): MutationResult, RemoteHost, RemoteHostStore, Bool, String, RemoteHostStoreTests, String, URL

### Community 137 - "ActivePaneService"
Cohesion: 0.07
Nodes (23): AgentSessionHistoryModel, .extraRecordsShown, .filteredRecords, .records, .searchQuery, .selectedAgents, .selectedIndex, .selectedScope (+15 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.06
Nodes (27): Codex → Kouen, One-line install, What you'll see, Cursor Agent → Kouen, Manual fallback, One-line install, What you'll see, Grok Build → Kouen (+19 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.11
Nodes (18): ImagePlacementSnapshot, SemanticMark, Bool, TerminalCellWidth, normal, spacerTail, wide, TerminalCursor (+10 more)

### Community 140 - "Added"
Cohesion: 0.14
Nodes (8): .feed(_:), .promptRows, .readGrid(scrollbackOffset:), ScrollbackTests, Character, String, SemanticPromptTests, String

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.11
Nodes (14): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+6 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.10
Nodes (14): NotchMaskAnimator, Bool, CGFloat, CGRect, NotchPanel, .canBecomeKey, .canBecomeMain, Bool (+6 more)

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.06
Nodes (30): LSPFileSession, Never, String, Task, URL, Void, .lspPosition(characterOffset:), .lspPosition(for:) (+22 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 145 - "AsciiFastPathTests"
Cohesion: 0.09
Nodes (19): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+11 more)

### Community 146 - "DecodedImage"
Cohesion: 0.20
Nodes (5): .snapshot, Bool, String, ThemeService, KouenOptions

### Community 147 - "FileTreeWatcher"
Cohesion: 0.11
Nodes (13): FileFuzzyMatcher, FileSearchRootScanner, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool (+5 more)

### Community 148 - "TriState"
Cohesion: 0.18
Nodes (11): TrackedIssue, GitHubSearchResult, IssueFetchStatus, apiError, live, notConfigured, IssueTrackerService, Repository (+3 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, S (+2 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.09
Nodes (23): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+15 more)

### Community 151 - ".evaluate"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 152 - "Added"
Cohesion: 0.14
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 154 - "LiveResizeTests"
Cohesion: 0.20
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 155 - "Int"
Cohesion: 0.12
Nodes (15): SavedLayoutStore, Bool, String, URL, UUID, PaneLayoutShape, branch, leaf (+7 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.11
Nodes (14): StatusLineView, .init(coder:), CGFloat, Never, NSAttributedString, NSCoder, NSColor, NSLayoutConstraint (+6 more)

### Community 157 - "Added"
Cohesion: 0.07
Nodes (16): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, Task, UUID (+8 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.08
Nodes (29): AgentRow, .agentColor, .executables, .hookButton, .hookButtonTitle, HookState, failed, idle (+21 more)

### Community 159 - "MatchCategory"
Cohesion: 0.11
Nodes (18): Process, SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, SSHTunnelManager (+10 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.11
Nodes (12): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+4 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.11
Nodes (19): InputGate, .siblings, ReconnectLatch, .isTripped, SurfaceIO, .currentSubscription, Bool, CGFloat (+11 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.06
Nodes (34): .body, FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body (+26 more)

### Community 163 - "Workspace"
Cohesion: 0.11
Nodes (13): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+5 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.10
Nodes (16): FlippedView, .isFlipped, GitPanelView, .init(frame:), .removeWorktreeAction(_:), Any, NSButton, NSColor (+8 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.13
Nodes (4): FilePreviewCoordinator, FileTabID, Set, String

### Community 166 - "LiveSession"
Cohesion: 0.13
Nodes (13): MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem, SessionGroup (+5 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.11
Nodes (7): Bool, NSDraggingInfo, NSDragOperation, URL, NSPasteboard, URL, KouenTerminalSurfaceDragDropTests

### Community 168 - "Added"
Cohesion: 0.15
Nodes (11): tool, KouenDaemonToolsTests, String, URL, Document, Bool, Set, String (+3 more)

### Community 169 - "Fixed"
Cohesion: 0.13
Nodes (9): AgyMobileCommands, String, ClaudeMobileCommands, Set, String, slashCommandChunks(), String, MobileBridgeAgentCommandTests (+1 more)

### Community 170 - "URLDetection"
Cohesion: 0.10
Nodes (37): blockTokens(), br(), checkbox(), codespan(), constructor(), de(), del(), em() (+29 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.08
Nodes (26): aie(), arc(), b2e(), bezierCurveTo(), closePath(), cRe(), cZ(), e0n() (+18 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.11
Nodes (18): String, Array, GroupHeaderRow, .body, PickerItemRow, .badgeText, .iconName, .subtitle (+10 more)

### Community 173 - "BoardCard"
Cohesion: 0.18
Nodes (3): fQ, hqe(), M9()

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.13
Nodes (14): SettingsAdvancedView, .body, Bool, String, SettingsFileSearchSection, .body, String, KeyRecorderRepresentable (+6 more)

### Community 175 - "RGBColorTests"
Cohesion: 0.15
Nodes (9): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, Set, SurfaceID, Tab (+1 more)

### Community 176 - "Added"
Cohesion: 0.16
Nodes (15): ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool, Command (+7 more)

### Community 177 - ".rects"
Cohesion: 0.17
Nodes (4): SQLite3, AgentHistoryMultiAgentCoverageTests, String, URL

### Community 178 - "InlineAICompletionView"
Cohesion: 0.07
Nodes (18): NSResponder, NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent (+10 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.16
Nodes (10): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab, UUID (+2 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.15
Nodes (9): json, DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests (+1 more)

### Community 181 - "GridCompositorTests"
Cohesion: 0.15
Nodes (16): ClaudeCodeHarness, Profile, edit, readonly, Run, RunState, cancelled, failed (+8 more)

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.16
Nodes (9): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+1 more)

### Community 183 - "LSPServerRegistry"
Cohesion: 0.10
Nodes (18): IssueKeychainStore, Bool, String, IssueTrackerType, azureDevOps, github, .id, jira (+10 more)

### Community 184 - "targets"
Cohesion: 0.08
Nodes (26): keys, CGImage, ImageLimits, Bool, ImageDecoder, ITerm2InlineImage, .heightArg, .preserveAspectRatio (+18 more)

### Community 185 - "SessionSnapshot"
Cohesion: 0.10
Nodes (14): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+6 more)

### Community 186 - "Error"
Cohesion: 0.10
Nodes (14): Bool, NSEvent, Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint (+6 more)

### Community 187 - "AppDelegate"
Cohesion: 0.14
Nodes (14): CompletionPopupView, .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:), .isHovered, Bool (+6 more)

### Community 188 - "BrowserPaneView"
Cohesion: 0.12
Nodes (24): .color, BoardCard, BoardColumn, .name, BoardColumnKind, .displayName, done, error (+16 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.24
Nodes (8): SessionID, String, Void, TaskDashboardBody, .body, .init(onJumpToSession:), TaskRowView, .body

### Community 190 - "user-stories.md"
Cohesion: 0.21
Nodes (5): CopyModeReducerTests, FakeGrid, .totalLines, Set, String

### Community 191 - "ScriptRuntime"
Cohesion: 0.12
Nodes (10): .readJSONLLines(from:), AntigravitySessionLocator, AntigravityTranscriptLine, Bool, Int32, NSRegularExpression, String, URL (+2 more)

### Community 192 - "GlyphRasterizer"
Cohesion: 0.13
Nodes (14): Container, .init(coder:), .init(frame:), HorizontalInsetRect, NotchPulseHost, NotchStatusDot, .body, Bool (+6 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.12
Nodes (27): _7(), aJ(), bXt(), cJ(), Eme(), F0(), fXt(), gC() (+19 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.16
Nodes (9): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSWindow (+1 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.09
Nodes (22): _3n(), bGt(), bV(), c_n(), cKt(), d4e(), dxn(), fvn() (+14 more)

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.07
Nodes (20): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+12 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.12
Nodes (13): CornerInfo, KouenSplitView, .dividerColor, .dividerThickness, DispatchWorkItem, Double, NSColor, NSRect (+5 more)

### Community 198 - ".classify"
Cohesion: 0.12
Nodes (19): Motion, .entrance, .spring, .standardEase, CAMediaTimingFunction, KouenOnboarding, Bool, ImmersiveOnboardingWindowController (+11 more)

### Community 199 - "code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)"
Cohesion: 0.22
Nodes (11): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, PaletteFooter, .body (+3 more)

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.07
Nodes (28): Additional `kouen-cli` subcommands, Agent safety CLI (`kouen-cli`), Agents, context and scratchpad, Attaching from a plain terminal, Bindings, Board and attention, Buffers (paste store), Composition (+20 more)

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.12
Nodes (12): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, input (+4 more)

### Community 202 - "PaletteModel"
Cohesion: 0.21
Nodes (4): CommandTarget, String, UUID, TargetSpecTests

### Community 203 - "Harness keybindings"
Cohesion: 0.23
Nodes (9): CopyModeGridSource, .promptRows, CopyModeReducer, Bool, Character, NSRegularExpression, Range, String (+1 more)

### Community 204 - "From tmux"
Cohesion: 0.12
Nodes (14): CKouenSys, pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal (+6 more)

### Community 205 - "CopyModeState"
Cohesion: 0.14
Nodes (15): Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow, launchStart, StartupMetrics (+7 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.18
Nodes (7): .snapshotPayload, NotificationBus, .postSnapshotChanged(_:), .postSnapshotChanged(revision:), SnapshotChangedPayload, Bool, String

### Community 207 - "scheduleRender"
Cohesion: 0.17
Nodes (10): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+2 more)

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 209 - "SettingsRemoteView"
Cohesion: 0.19
Nodes (11): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, .selectedHost (+3 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.13
Nodes (12): Color, .hexString, .body, AttributedString, NSColor, AmbientBackground, .body, Bool (+4 more)

### Community 211 - "PaneTarget"
Cohesion: 0.16
Nodes (7): CheckpointInfo, CheckpointManager, Bool, Date, String, CheckpointManagerTests, String

### Community 212 - ".translate"
Cohesion: 0.14
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 213 - "String"
Cohesion: 0.16
Nodes (12): BranchSwitchHelper, FileTreeNode, FileTreeSwiftUIView, .body, .pastedImagesSection, Notification.Name, Bool, Never (+4 more)

### Community 215 - ".lines"
Cohesion: 0.10
Nodes (23): bNt(), bu(), cNt(), dNt(), eNt(), eRe(), fNt(), iNt() (+15 more)

### Community 216 - "CellColorResolverTests"
Cohesion: 0.08
Nodes (14): NSRangePointer, Any, NSAttributedString, NSRange, NSRect, String, UInt64, .color(_:) (+6 more)

### Community 217 - "GridCompositor"
Cohesion: 0.15
Nodes (6): CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab, GitMetadataProviderTests

### Community 219 - "Prompt"
Cohesion: 0.20
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 220 - "Section"
Cohesion: 0.13
Nodes (23): Colors, Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors (+15 more)

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.11
Nodes (11): SGRMouse, SGRMouseEvent, Bool, UInt8, MouseEventKind, drag, press, release (+3 more)

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.14
Nodes (19): Cjt(), H2e(), hR(), jX(), Kje(), KX(), lR(), N$e() (+11 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.14
Nodes (7): KeybindingsStore, .fileURL, URL, KeybindingsStoreTests, URL, Void, String

### Community 224 - "CellColorResolver"
Cohesion: 0.14
Nodes (11): AgentRoutingResolver, String, AgentRoutingRule, Kind, path, stack, Bool, Date (+3 more)

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.06
Nodes (35): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, SessionGroup, SessionID (+27 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.07
Nodes (32): AgentMark, .body, AgentMarkShape, Scanner, .atEnd, SVGPath, Bool, CGFloat (+24 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.15
Nodes (12): CUe(), H7(), kUe(), LUe(), lXt(), lYt(), nXt(), Ome() (+4 more)

### Community 229 - ".decide"
Cohesion: 0.15
Nodes (6): BrowserLeaf, URL, DaemonSyncServiceBrowserPaneMergeTests, PaneID, PaneNodeBrowserTests, PaneNodeLayoutShapeTests

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.12
Nodes (22): FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose, .onSelect (+14 more)

### Community 231 - "ExternalOpenKind"
Cohesion: 0.13
Nodes (13): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+5 more)

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.17
Nodes (11): NotchGeometry, .fallback, NSScreen, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics (+3 more)

### Community 233 - "TextGrid"
Cohesion: 0.08
Nodes (32): CGFloat, FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView (+24 more)

### Community 234 - ".scan"
Cohesion: 0.29
Nodes (6): DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed

### Community 235 - "WorkbenchCommand"
Cohesion: 0.13
Nodes (16): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, .bytesPerWakeup, .mbps (+8 more)

### Community 236 - "Added"
Cohesion: 0.11
Nodes (16): CodingKeys, error, id, jsonrpc, method, JSONRPCId, int, string (+8 more)

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.16
Nodes (3): CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 238 - ".make"
Cohesion: 0.10
Nodes (15): LSPMessage, notification, request, response, Decoder, Encoder, KeyedDecodingContainer, LSPTransport (+7 more)

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.10
Nodes (30): eJ(), fme(), gKt(), gUe(), $He(), ixn(), kGt(), LC() (+22 more)

### Community 240 - "PaneBorderStatus"
Cohesion: 0.05
Nodes (21): AgentListFormatter, Date, String, dvn(), ht(), Range, String, TerminalBufferMatch (+13 more)

### Community 241 - "Added"
Cohesion: 0.16
Nodes (9): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ProcessInfo (+1 more)

### Community 242 - "AgentBridge"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 243 - ".make"
Cohesion: 0.13
Nodes (15): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+7 more)

### Community 244 - "FileNode"
Cohesion: 0.25
Nodes (6): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.12
Nodes (8): OnboardingController, KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, BinaryInstallerDisplayTests, OnboardingEnvironmentTests

### Community 246 - "Experience modes"
Cohesion: 0.12
Nodes (16): Notification.Name, ObserverToken, NSCoder, NSObjectProtocol, NSRect, NSTextView, URL, SyntaxDefinitionTarget (+8 more)

### Community 247 - ".renderFixture"
Cohesion: 0.08
Nodes (24): Font, .kouenBadge, .kouenBody, .kouenBodyStrong, .kouenCaption2, .kouenCaption, .kouenKbd, .kouenMono (+16 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.15
Nodes (8): BoardViewController, .isVisible, FlippedView, .isFlipped, Bool, Set, TabID, BoardViewControllerTests

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 251 - "SessionCoordinator"
Cohesion: 0.22
Nodes (7): AgentRoutingRuleStore, Bool, String, URL, UUID, AgentRoutingRuleStoreTests, URL

### Community 252 - "NSViewRepresentable"
Cohesion: 0.28
Nodes (7): Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 253 - "Split Right"
Cohesion: 0.07
Nodes (21): GitAheadBehind, GitResult, .isSuccess, GitWorktreeInfo, Bool, Int32, String, GitParsers (+13 more)

### Community 254 - "BoardViewController"
Cohesion: 0.27
Nodes (6): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor

### Community 255 - "release-hotfix.sh"
Cohesion: 0.18
Nodes (4): Gbe(), handler(), l8e(), YUt

### Community 256 - "GitMetadataProvider"
Cohesion: 0.13
Nodes (9): NSDraggingInfo, NSDragOperation, PasteController, Bool, NSPasteboard, String, TimeInterval, URL (+1 more)

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 258 - "WindowTitleStripView"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.08
Nodes (6): CodepointRunFastPathTests, .assertAllPathsAgree(_:cols:rows:file:line:), StaticString, String, UInt, UInt8

### Community 260 - ".welcome"
Cohesion: 0.11
Nodes (18): DataBox, .init(coder:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:), .init(frame:) (+10 more)

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.12
Nodes (12): NaturalLanguage, AgentHistorySearch, Hit, IDFCache, Bool, Double, String, .tokenHits(_:inNormalized:) (+4 more)

### Community 262 - ".install"
Cohesion: 0.14
Nodes (15): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+7 more)

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.13
Nodes (6): TimeInterval, AgentHandoffBuilder, Bool, String, HandoffDirectoryTests, AgentHandoffBuilderTests

### Community 264 - "code:bash (harness-cli install-hooks claude-code)"
Cohesion: 0.11
Nodes (18): .effectiveResumeCommand(mode:), AgentLaunchCommands, AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand (+10 more)

### Community 265 - "code:bash (harness-cli install-hooks cursor)"
Cohesion: 0.15
Nodes (5): BrowserIntegrationController, PaneID, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), .init(paneID:), PaneID

### Community 266 - ".path"
Cohesion: 0.17
Nodes (21): Decodable, Item, ItemCompletedLine, LegacyMsgLine, Msg, String, ThreadStartedLine, AgentCommandRequest (+13 more)

### Community 267 - ".performInstall"
Cohesion: 0.16
Nodes (13): BoxDrawing, Kind, arms, dashH, dashV, halfDown, halfLeft, halfRight (+5 more)

### Community 268 - "code:bash (# Old (agent-specific):)"
Cohesion: 0.22
Nodes (5): .body, Bool, Bool, String, URL

### Community 269 - "DefaultTerminalManager"
Cohesion: 0.19
Nodes (6): Case, ReflowCorpusTests, .corpus, .goldenDir, String, URL

### Community 270 - "WindowSession"
Cohesion: 0.15
Nodes (14): SettingsTerminalView, .body, .experienceSection, .fontReadout, .fontSection, .shellSection, Bool, String (+6 more)

### Community 271 - "StatusLineView.swift"
Cohesion: 0.25
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 272 - "SGRMouseEvent"
Cohesion: 0.18
Nodes (10): RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal, FileHandle, Int32 (+2 more)

### Community 273 - "KeySpec"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.13
Nodes (6): PromptQueue, String, SurfaceID, Void, PromptQueueBar, NSWindow

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.18
Nodes (20): CoreImage, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription, .surfaceID, detectHost() (+12 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.14
Nodes (19): .modifierFlags, NSEvent, BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, CodingKeys (+11 more)

### Community 277 - ".run"
Cohesion: 0.14
Nodes (12): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+4 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.24
Nodes (8): FileTreeContext, NSHostingView, SessionID, String, Void, WorkspaceFileTreeView, .init(rootPath:), WorkspaceFileTreePinTests

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.17
Nodes (8): item, CodexSessionLocator, CodexTranscriptLine, Any, Bool, Int32, String, URL

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.19
Nodes (13): ProjectGroupWatcher, StreamBox, Bool, DispatchQueue, escaping, FSEventStreamRef, MainActor, Never (+5 more)

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.13
Nodes (7): ControlKeyNormalizer, Bool, String, ShortcutRecorderSerializer, String, ControlKeyNormalizerTests, ShortcutRecorderSerializerTests

### Community 283 - "FormatColor"
Cohesion: 0.17
Nodes (8): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, String, PaneStyleTests

### Community 284 - "click_ui_element"
Cohesion: 0.20
Nodes (7): Scope, global, pane, session, tab, workspace, ScopedKey

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.16
Nodes (17): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+9 more)

### Community 287 - ".apply"
Cohesion: 0.23
Nodes (5): WorktreeManager, String, URL, UUID, WorktreeIsolationDaemonTests

### Community 288 - "AgentHookStrategy"
Cohesion: 0.13
Nodes (17): FormatContextBuilder, DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:) (+9 more)

### Community 289 - "StatusLineWidthTests"
Cohesion: 0.16
Nodes (8): brn, grn, hrn(), JGe(), KGe(), prn(), qGe(), zGe()

### Community 290 - "Process"
Cohesion: 0.26
Nodes (3): CSIParams, .count, UInt8

### Community 291 - "JSONDecoder"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Kouen, Sparkle (+13 more)

### Community 292 - "Release runbook"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 294 - "GitHubCLIClient"
Cohesion: 0.18
Nodes (7): AIProviderAwakeService, .closedLidOptedIn, Bool, NSObjectProtocol, Set, String, AIProviderAwakeServiceTests

### Community 296 - "NotificationBus"
Cohesion: 0.18
Nodes (11): Never, NSRegularExpression, Set, String, Task, URL, Void, WorkspaceSymbolIndex (+3 more)

### Community 297 - "settings.json"
Cohesion: 0.16
Nodes (8): CustomEndpointTester, Result, Bool, String, URL, CustomEndpointTesterTests, URLRequest, URLSession

### Community 298 - "jobs"
Cohesion: 0.15
Nodes (14): GitStatusType, added, deleted, modified, renamed, unmodified, untracked, NodeRow (+6 more)

### Community 299 - "PaneNode"
Cohesion: 0.16
Nodes (5): TabID, WorkspaceID, AgentCommandTests, String, Tab

### Community 301 - ".parse"
Cohesion: 0.13
Nodes (10): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, String (+2 more)

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.17
Nodes (16): SessionRef, byID, byName, next, previous, String, UUID, TargetSpec (+8 more)

### Community 303 - ".encodeMouse"
Cohesion: 0.11
Nodes (17): AgentUsage, .contextTokens, .init(from:), .init(inputTokens:outputTokens:cacheReadTokens:cacheWriteTokens:thinkingTokens:totalCostUSD:), .shortSummary, CodingKeys, cacheReadTokens, cacheWriteTokens (+9 more)

### Community 304 - "00-inception-plan.md"
Cohesion: 0.15
Nodes (8): ContextResolutionEngine, Bool, String, Bool, String, TokenGuard, ContextResolutionEngineTests, String

### Community 305 - ".script"
Cohesion: 0.15
Nodes (15): NotchOverviewRow, .approvalControls, .background, .badge, .body, .openableRow, .progressUnderline, .relativeTime (+7 more)

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.20
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 307 - "ViPathTokenTests"
Cohesion: 0.13
Nodes (3): AgentLaunchCommandsTests, URL, Void

### Community 308 - "Send Ex Command"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 309 - "Browser DevTools API (P28)"
Cohesion: 0.13
Nodes (14): BinaryInstaller.DetectionStatus, SetupStepView, .body, .canInstall, .hooksDetail, .hooksTone, .hooksValue, .isSuccess (+6 more)

### Community 310 - "FrameSignposter"
Cohesion: 0.12
Nodes (7): azt(), cqe(), F7, ibe(), mathmlBuilder(), q$e(), UHt()

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.31
Nodes (5): PaneOutputWaiter, PaneOutputWaitResult, CheckedContinuation, Never, UInt64

### Community 312 - "AgentSnapshot"
Cohesion: 0.06
Nodes (20): SurfaceProgressTracker, Bool, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void, State (+12 more)

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.28
Nodes (7): SSETransport, .isRunning, .listener, Bool, NWConnection, String, UInt16

### Community 315 - "code:bash (harness-cli install-hooks grok)"
Cohesion: 0.17
Nodes (8): Keyboard Shortcuts, AI Browser Control (kouen-mcp), Install, Shell integration (OSC 133 semantic prompts), What gets emitted, Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 316 - "code:bash (harness-cli install-hooks opencode)"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.17
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 319 - "FormatColor"
Cohesion: 0.33
Nodes (3): TaskStore, URL, TaskStoreTests

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.14
Nodes (5): FormatContextDaemonTests, PaneID, String, SurfaceID, URL

### Community 321 - "UInt64"
Cohesion: 0.16
Nodes (6): LSPTextLocation, .position, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 322 - "DesktopNotifier"
Cohesion: 0.24
Nodes (7): BinaryInstaller, .bundledMacOSDir, Bool, TimeInterval, BinaryInstallerVersionTests, String, URL

### Community 323 - "LayoutNode"
Cohesion: 0.11
Nodes (18): GlassSmallButtonStyle, OnboardingStep, complete, discover, .id, setup, shell, .title (+10 more)

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.17
Nodes (7): A7(), a8(), c8(), ene(), Gnn, IC(), o8()

### Community 325 - "FloatingPaneController"
Cohesion: 0.13
Nodes (17): dhn(), en(), fhn(), ghn(), gk(), GOt(), iXt(), jUe() (+9 more)

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.05
Nodes (15): B0, BBe(), cd(), e5e(), Fze, iln(), iwn(), O7 (+7 more)

### Community 327 - ".theme"
Cohesion: 0.11
Nodes (11): UnsafeBufferPointer, UnsafeBufferPointer, CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16 (+3 more)

### Community 328 - "README.md"
Cohesion: 0.23
Nodes (7): AnyView, .body, .rowList, AgentNotchViewModel, Bool, CGFloat, Duration

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.12
Nodes (10): MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, String, SurfaceID (+2 more)

### Community 332 - "Added"
Cohesion: 0.18
Nodes (12): Notification.Name, KouenGit, os, attribute_lines(), main(), redraw_frames(), repeated_chunk(), run_case() (+4 more)

### Community 333 - "RealPty"
Cohesion: 0.19
Nodes (8): SwarmFleetView, .init(coder:), CGFloat, NSCoder, CGFloat, NSCoder, TaskDashboardView, .init(coder:)

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 335 - ".makeModel"
Cohesion: 0.11
Nodes (18): fix ที่ค้างอยู่ใน working tree (ยังไม่ commit), Terminal grid ไม่ใช่ก้อนใหญ่ที่ระบุชนิดได้, ก้อนหลักเกี่ยวข้องกับ RenderBox, การให้ DeepSeek ตรวจเพิ่ม, ผลตรวจ preview ที่แยกจากแอปหลัก, ผลตรวจแอปหลัก, ภาคผนวก 1 — fleet 9 ต.ค. (P54) กระทบ UI ไหม → กระทบ ตรงจุด, ภาคผนวก 2 — 18 ต.ค. `8c5e0c8d` P59 (agy session, **unreviewed**) (+10 more)

### Community 336 - "run.sh"
Cohesion: 0.42
Nodes (3): KeyTokenParser, Bool, String

### Community 337 - "CommandExecutionError"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 338 - "CSIParams"
Cohesion: 0.26
Nodes (5): EnvironmentStore, Persisted, String, EnvironmentStoreTests, URL

### Community 339 - "Foundation"
Cohesion: 0.16
Nodes (7): ProjectGroupResolver, String, String, .trimmed, AgentTitleInference, Bool, .effectiveAgentKind

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.17
Nodes (3): ShellIntegrationTests, .repoRoot, URL

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.12
Nodes (12): CryptoKit, Network, DecodedWSFrame, Bool, ConnectionState, NWConnection, String, UInt8 (+4 more)

### Community 342 - "Added"
Cohesion: 0.16
Nodes (16): SwarmFleetSnapshot, SwarmLane, pty, structured, SwarmTaskNode, SwarmTaskStatus, cancelled, failed (+8 more)

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.17
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

### Community 344 - "FileViewerViewController"
Cohesion: 0.14
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 345 - "README.md"
Cohesion: 0.19
Nodes (12): DisplayLinkTarget, SplitChromeDelegate, .sidebarMaxWidth, .sidebarMinWidth, .splitView(_:constrainMaxCoordinate:ofSubviewAt:), .splitView(_:constrainMinCoordinate:ofSubviewAt:), .splitView(_:effectiveRect:forDrawnRect:ofDividerAt:), .splitView(_:shouldAdjustSizeOfSubview:) (+4 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.15
Nodes (7): ezt(), GGe, Gwe(), Hzt(), Iqt(), Kp(), urn

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.16
Nodes (4): KouenThemeCatalog, .allThemes, String, KouenThemeCatalogTests

### Community 349 - "Contents.json"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.10
Nodes (3): Bool, String, UUID

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.19
Nodes (7): PaneID, SurfaceID, Tab, TabID, BrowserPaneReuseScopeTests, Tab, TabID

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.22
Nodes (6): ListeningPortScanner, Int32, Set, String, result, ListeningPortScannerTests

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.15
Nodes (14): a9e(), Am(), avn(), c0t(), Cm(), Hm(), Im(), lte() (+6 more)

### Community 355 - ".deepMerge"
Cohesion: 0.37
Nodes (3): AgentBrowserPaneTracker, Set, AgentBrowserPaneTrackerTests

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.18
Nodes (9): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+1 more)

### Community 357 - ".handleCat"
Cohesion: 0.18
Nodes (13): aNt(), dwn(), fwn(), HUe(), KD(), kXt(), $o(), sJ() (+5 more)

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.19
Nodes (9): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+1 more)

### Community 359 - "OcclusionTests"
Cohesion: 0.19
Nodes (13): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Bool, Duration (+5 more)

### Community 360 - "State"
Cohesion: 0.19
Nodes (14): CellMetrics, Hashable, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth (+6 more)

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.15
Nodes (8): DispatchSource, DispatchQueue, DispatchSourceFileSystemObject, Int32, URL, Void, TranscriptFileWatcher, MobileBridgeTranscriptWatcherTests

### Community 362 - "RGBColor"
Cohesion: 0.14
Nodes (13): KouenCommands, DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String (+5 more)

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.25
Nodes (8): FeaturePhase, architect, completed, dev, interview, qaDesign, qaVerify, .title

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.06
Nodes (43): a6(), aR(), copy(), cYt(), dFt(), DGt(), dje(), dm() (+35 more)

### Community 366 - "Consumers"
Cohesion: 0.18
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 368 - "Tab"
Cohesion: 0.22
Nodes (6): ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 369 - "Git Panel"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 370 - ".encode"
Cohesion: 0.24
Nodes (9): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+1 more)

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.13
Nodes (6): agentWaitChannel(), HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.17
Nodes (9): GitStatusProvider, OnceResume, Bool, Duration, String, TimeInterval, GitStatusProviderLargeOutputTests, URL (+1 more)

### Community 373 - "Prompt"
Cohesion: 0.21
Nodes (4): Bool, String, SurfaceID, TimeInterval

### Community 374 - ".run"
Cohesion: 0.18
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 375 - ".install"
Cohesion: 0.22
Nodes (9): Scanner, .atEnd, SVGPathParser, Bool, CGPath, CGPoint, Character, Set (+1 more)

### Community 376 - "ScrollReuseTests"
Cohesion: 0.12
Nodes (5): KouenCLI, HistorySearchQueryTests, MemoCommandTests, URL, TaskCommandTests

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 379 - "MCPServer"
Cohesion: 0.20
Nodes (4): CompletionGenerator, String, .fishCompletionSource, CompletionGeneratorTests

### Community 380 - "PromptQueue"
Cohesion: 0.26
Nodes (8): InstallResult, Shell, bash, fish, zsh, ShellIntegration, Bool, URL

### Community 381 - "smoke-dmg.sh"
Cohesion: 0.19
Nodes (8): AgentRemoteControlDaemonService, Set, String, Void, AgentRemoteControlDaemonServiceTests, LogBox, .count, String

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.18
Nodes (10): AssistantLine, ClaudeAdapter, Content, Message, ResultLine, Bool, Double, String (+2 more)

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.29
Nodes (4): SwarmDAGStore, String, UUID, SwarmDAGStoreTests

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.26
Nodes (7): string, AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID

### Community 385 - "INDEX.md"
Cohesion: 0.08
Nodes (13): ImageProtocolTests, String, KouenTerminalSurfaceFocusTests, OcclusionTests, NSWindow, String, TimeInterval, SpecialKeyMappingTests (+5 more)

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.26
Nodes (3): String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 387 - "User Profile"
Cohesion: 0.27
Nodes (4): ArchitectureGuardTests, .repoRoot, String, URL

### Community 388 - "Darwin"
Cohesion: 0.20
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 389 - "HarnessCLITests"
Cohesion: 0.16
Nodes (4): KouenMCP, SSETransportTests, UInt16, NWListener

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.21
Nodes (8): StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength, newline, TransportError, invalidUTF8Header, missingContentLength

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.20
Nodes (9): AnyObject, CommandExecutionError, daemonError, .description, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor (+1 more)

### Community 393 - "create-dmg.sh"
Cohesion: 0.20
Nodes (8): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController

### Community 394 - "finalize-release.sh"
Cohesion: 0.57
Nodes (3): ProjectConfig, Bool, String

### Community 395 - "generate-app-icon.sh"
Cohesion: 0.17
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 396 - "generate-appcast.sh"
Cohesion: 0.19
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 397 - "measure-fluidity.sh"
Cohesion: 0.13
Nodes (15): .agentInfo(forWorktreePath:), AgentNotchPeekDecider, RowState, Bool, String, AgentActivity, awaiting, errored (+7 more)

### Community 398 - "preview.sh"
Cohesion: 0.27
Nodes (7): AgyModelCatalog, Catalog, Date, String, TimeInterval, ConnectionState, NWConnection

### Community 399 - "sign-and-notarize.sh"
Cohesion: 0.15
Nodes (12): Date, Never, TabID, Task, Void, TabPillView, .body, .pillBackground (+4 more)

### Community 400 - "install-linux.sh"
Cohesion: 0.12
Nodes (15): agy, claude, codex, copilot, hermes, kouen, __kouen_agy_next, __kouen_claude_next (+7 more)

### Community 401 - "package-app.sh"
Cohesion: 0.13
Nodes (13): OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Bool, URL, Value (+5 more)

### Community 402 - "View"
Cohesion: 0.25
Nodes (8): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String

### Community 403 - "PresentAttempt"
Cohesion: 0.21
Nodes (3): .hasAdapter(for:), Bool, ClaudeCodeHarnessTests

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.18
Nodes (8): ClaudeRunSummary, Date, Double, Int32, String, UUID, String, UUID

### Community 405 - "AgentIconRenderer"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 406 - "main.swift"
Cohesion: 0.18
Nodes (10): AYt(), EUe(), eYt(), IUe(), j9n(), KYt(), Sme(), tYt() (+2 more)

### Community 407 - "Fixed"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 408 - "IPC Architecture"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.05
Nodes (27): AppKit, KouenSyntaxResources, ObjectiveC, BrowserFileReloadTests, CountingWebView, Nav, NSEvent, String (+19 more)

### Community 410 - ".applyTerminalIdentity"
Cohesion: 0.19
Nodes (9): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.27
Nodes (7): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection, agents

### Community 412 - "go.json"
Cohesion: 0.20
Nodes (7): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, FileChangeWatcherTests

### Community 413 - "javascript.json"
Cohesion: 0.14
Nodes (9): NSEvent, NSHostingView, NSLayoutConstraint, TerminalTabBarView, .delegate, .init(frame:), .leadingInset, .mouseDownCanMoveWindow (+1 more)

### Community 415 - "markdown.json"
Cohesion: 0.23
Nodes (13): kouen.bash script, agy(), claude(), codex(), copilot(), hermes(), kouen(), __kouen_agy_next() (+5 more)

### Community 417 - "rust.json"
Cohesion: 0.22
Nodes (5): RepoResolver, Bool, String, RepoResolverTests, String

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.09
Nodes (19): ExperienceMode, agent, .displayName, .foregroundsAgents, full, .notchEnabledByDefault, persistent, .persistsSessionsByDefault (+11 more)

### Community 419 - "typescript.json"
Cohesion: 0.25
Nodes (4): bze(), EQ(), MBe(), mm

### Community 420 - "yaml.json"
Cohesion: 0.15
Nodes (8): _Bt(), by(), e7e(), fst(), hxn(), lxn(), sBt, XWt()

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.20
Nodes (13): ern(), G4(), G7(), Jnn(), nrn(), Qnn(), sHe(), trn() (+5 more)

### Community 422 - "HintModeOverlay"
Cohesion: 0.15
Nodes (12): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+4 more)

### Community 423 - "SixelDecoder"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 424 - ".parseDiffHunks"
Cohesion: 0.09
Nodes (11): CustomStringConvertible, URL, KouenPaths, KouenPathsError, .description, socketPathTooLong, Bool, String (+3 more)

### Community 425 - "AgentVectorIcon"
Cohesion: 0.20
Nodes (8): IssuePriority, .color, high, low, medium, none, .symbol, urgent

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.24
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 427 - ".delay"
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 428 - "TaskDashboardView"
Cohesion: 0.17
Nodes (9): RemoteHostsService, .activeHostName, String, DaemonSessionError, .description, unexpectedResponse, LatencyMonitor, String (+1 more)

### Community 431 - "BoardCardView"
Cohesion: 0.21
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 432 - "PathToken"
Cohesion: 0.32
Nodes (10): AgentBadgeView, .body, Bool, CGFloat, AgentIconRenderer, CGFloat, NSColor, NSImage (+2 more)

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.22
Nodes (8): DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSViewCornerConfiguration, SurfaceID, Void

### Community 434 - "Project History"
Cohesion: 0.36
Nodes (4): Bool, String, UUID, TaskDaemonBridge

### Community 435 - ".init"
Cohesion: 0.24
Nodes (8): ProjectDropTarget, .init(coder:), .init(frame:), NSCoder, NSDraggingInfo, NSDragOperation, NSRect, URL

### Community 436 - "WaitForRegistry"
Cohesion: 0.31
Nodes (9): CGFloat, Range, Tab, TabBarLayoutMetrics, .pitch, tabDisplayTitle(), TerminalTabBarBody, .body (+1 more)

### Community 437 - "PickerItemRow"
Cohesion: 0.14
Nodes (14): Agent handbook — Kouen (extended reference), Agent integration, Build and test, IPC, Keyboard shortcuts, kouen-cli, Native terminal renderer, Repository map (+6 more)

### Community 438 - "SessionEditor"
Cohesion: 0.18
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 439 - "SetupStepView"
Cohesion: 0.41
Nodes (7): FeatureSummary, FeatureTaskSummary, GateSummary, Bool, Date, String, UUID

### Community 440 - "LegacySnapshot"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 441 - "RemoteHostStore"
Cohesion: 0.18
Nodes (13): Array, Bool, Date, Decoder, PaneID, String, TabID, Tab (+5 more)

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.19
Nodes (8): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus, UserNotifications

### Community 443 - "main.swift"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 445 - "Section"
Cohesion: 0.15
Nodes (12): Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock, .block(atPromptLine:) (+4 more)

### Community 446 - "Modifiers"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 447 - "PaletteMode"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 451 - ".run"
Cohesion: 0.30
Nodes (5): SearchBenchmarks, String, UInt64, URL, Void

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.20
Nodes (4): BoardCommandTests, String, String, Tab

### Community 454 - ".recordReapedGenerationForTesting"
Cohesion: 0.33
Nodes (3): String, WorkspaceID, DaemonSyncServiceBranchNotifyTests

### Community 455 - "ComposerPanel"
Cohesion: 0.25
Nodes (4): PortableRelativeDateFormatter, Date, String, UUID

### Community 457 - ".normalizedKey"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 458 - "PaneOutputWaiter"
Cohesion: 0.18
Nodes (9): NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView, .cornerConfiguration (+1 more)

### Community 459 - ".encode"
Cohesion: 0.33
Nodes (4): .setSidebarVisible(_:animated:), SidebarPlacementSyncTests, CGFloat, Void

### Community 460 - "RunState"
Cohesion: 0.24
Nodes (7): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController

### Community 461 - ".worktreeList"
Cohesion: 0.21
Nodes (8): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, NSEvent, Observation

### Community 462 - "AGENTS.md"
Cohesion: 0.21
Nodes (10): AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor (+2 more)

### Community 463 - ".deinit"
Cohesion: 0.18
Nodes (12): DotView, .init(coder:), .init(frame:), statusColor(), Bool, Context, NSCoder, NSColor (+4 more)

### Community 464 - "MouseButton"
Cohesion: 0.15
Nodes (13): CodingKey, CodingKeys, createdAt, cwd, done, id, sessionID, status (+5 more)

### Community 465 - "DirectionalAxis"
Cohesion: 0.38
Nodes (4): AnyObject, ObjectIdentifier, TimeInterval, ZombieHoldRegistry

### Community 466 - "PlatformSys.swift"
Cohesion: 0.27
Nodes (4): GroupedSessionTests, SessionGroup, Set, SurfaceID

### Community 467 - ".moveSelection"
Cohesion: 0.21
Nodes (5): FDWatchdog, DispatchSourceTimer, String, TimeInterval, FDWatchdogTests

### Community 469 - "PresentAttempt"
Cohesion: 0.27
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 470 - "DispatchTime"
Cohesion: 0.18
Nodes (6): eKe(), irn(), mrn, _rn(), rrn(), srn()

### Community 471 - ".evaluateStyled"
Cohesion: 0.23
Nodes (5): ImageTextureCache, MTLDevice, MTLTexture, Set, UInt8

### Community 472 - "start.sh script"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 473 - "HarnessOnboarding"
Cohesion: 0.07
Nodes (9): Phase67Tests, BellScanTests, Bool, UInt8, GroupedSessionDaemonTests, SessionGroup, String, URL (+1 more)

### Community 476 - "StatusDotView"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 477 - "SavedLayoutIPCDaemonTests"
Cohesion: 0.29
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 479 - "ScrollbackTests"
Cohesion: 0.29
Nodes (5): DirectionalAxis, down, left, right, up

### Community 480 - ".isRisky"
Cohesion: 0.31
Nodes (4): HintModeOverlay, Any, NSEvent, String

### Community 481 - "SecureInputMonitor"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 482 - ".resolve"
Cohesion: 0.10
Nodes (13): BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool, CGFloat, NSCoder, NSPoint (+5 more)

### Community 483 - "Changed"
Cohesion: 0.25
Nodes (6): clamp(), Configuration, T, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, .dragGesture

### Community 484 - "CopilotAdapter"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 485 - ".testKouenRendererFixtureLigatureShapingPathReportsPlausibleGlyphs"
Cohesion: 0.14
Nodes (12): .setupPrompt, AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile (+4 more)

### Community 487 - "bC"
Cohesion: 0.37
Nodes (4): KouenFeatureMarkdownSync, Bool, String, URL

### Community 488 - "R1"
Cohesion: 0.30
Nodes (4): Bool, OptionStore, OptionStoreTests, URL

### Community 489 - "SurfaceIO"
Cohesion: 0.41
Nodes (5): InstallResult, ShellCompletionInstaller, Bool, String, URL

### Community 490 - "ccRunGet"
Cohesion: 0.09
Nodes (16): FilterStatus, active, all, completed, CaseIterable, LayoutTemplate, evenHorizontal, evenVertical (+8 more)

### Community 491 - ".update"
Cohesion: 0.14
Nodes (13): SwarmFleetBody, .body, SwarmNodeRowView, .body, .statusColor, Duration, Void, SwarmFleetSnapshotWire (+5 more)

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.39
Nodes (3): data, SixelDecoder, UInt8

### Community 493 - "ccRunStart"
Cohesion: 0.32
Nodes (3): ReflowPreviewTests, .feeds, String

### Community 494 - "ccRunInfo"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 495 - ".open"
Cohesion: 0.17
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 499 - "GlassEffectView"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 500 - "zO"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 501 - "Fixed"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 502 - "Kouen Terminal — System Architecture"
Cohesion: 0.47
Nodes (6): _9n(), d8e(), hmn(), PKe(), tke(), u7e()

### Community 503 - "Kouen Features"
Cohesion: 0.29
Nodes (7): AnimatablePair, NotchShape, .animatableData, CGFloat, CGPath, CGRect, Path

### Community 504 - "String"
Cohesion: 0.24
Nodes (5): RiskyCommandClassifier, Bool, NSRegularExpression, String, RiskyCommandClassifierTests

### Community 505 - ".tickFeatureWorktreeSweepLocked"
Cohesion: 0.29
Nodes (6): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Carbon

### Community 506 - ".parseGitDiffOutput"
Cohesion: 0.23
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.40
Nodes (3): calculate(), constructor(), mBt

### Community 508 - "qLt"
Cohesion: 0.18
Nodes (11): Typography, .badge, .kbd, .paletteHeader, .paletteTitle, .rowMeta, .rowTitle, .sectionLabel (+3 more)

### Community 509 - "start.mjs"
Cohesion: 0.29
Nodes (3): KouenCompositor, GridCompositorCopyModeTests, String

### Community 510 - "PromptQueue"
Cohesion: 0.20
Nodes (8): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, ClosedRange, String

### Community 511 - ".panePathLookup"
Cohesion: 0.23
Nodes (3): MobileBridgeAttachFileTests, String, URL

### Community 513 - "ThemeDocument"
Cohesion: 0.27
Nodes (4): aD(), crn, ELt(), n2e()

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 515 - "RD"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 516 - "terminal_stress_runner.py"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 517 - "KouenCLI+Workbench.swift"
Cohesion: 0.18
Nodes (4): ClaudeSessionMode, ClaudeSessionModeTests, URL, Void

### Community 519 - ".gestureRecognizer"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Kouen terminal product features agent workspace browser daemon session persistence remote control, Source Nodes

### Community 520 - "WriteOutcome"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 521 - ".daemonIsStale"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: session persistence focus routing browser disposal memory bounded checkpoint undo verify worktree, Source Nodes

### Community 522 - ".viewDidLoad"
Cohesion: 0.29
Nodes (6): SessionGroup, SessionID, Tab, TabID, WorkspaceID, WindowAttachClient

### Community 523 - "fFe"
Cohesion: 0.30
Nodes (7): Bool, NSPasteboard, NSString, String, URL, TerminalServicesProvider, AutoreleasingUnsafeMutablePointer

### Community 524 - "รายงานตรวจสอบการใช้หน่วยความจำสูงของ Kouen Terminal"
Cohesion: 0.27
Nodes (3): TabID, WorkspaceID, GitPanelViewWorktreeNavigationTests

### Community 525 - ".encodeAndWait"
Cohesion: 0.33
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 526 - "Kind"
Cohesion: 0.36
Nodes (6): HistorySearchEvidence, .body, .terms, Bool, String, Text

### Community 527 - ".show"
Cohesion: 0.22
Nodes (7): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, NSCoder, Void

### Community 528 - "worktree_review_dashboard.robot"
Cohesion: 0.18
Nodes (11): Architecture Decisions (dated log), Commit preparation, Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Post-P50 changes (v4.20.2 → v4.20.11, 2026-10-01 → 2026-10-06), Product Identity Guardrail: Terminal, Not IDE (+3 more)

### Community 529 - "WorktreeAutoIsolateService"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: How should CheckpointManager.restore preserve the user staged index?, Source Nodes

### Community 530 - "HarnessChrome"
Cohesion: 0.20
Nodes (10): Agent Safety Net (Checkpoints, Verification, Write Guards), Claude Code Harness, Editor & LSP, How It Feels, Kouen Features, Mobile, Remote And Headless, Stack (+2 more)

### Community 532 - "OpenClaw → Kouen"
Cohesion: 0.20
Nodes (10): PaneRef, bottom, byID, byIndex, last, left, next, previous (+2 more)

### Community 533 - "Pi → Kouen"
Cohesion: 0.31
Nodes (4): GraphifyIndexCache, S, Set, String

### Community 534 - "p12_mcp.robot"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 535 - "AgentNotification"
Cohesion: 0.31
Nodes (5): AgyAdapter, Result, ResultLine, String, UUID

### Community 536 - ".readGrid(scrollbackOffset:)"
Cohesion: 0.20
Nodes (7): HeadlessRunEvent, assistantText, result, sessionID, Bool, Double, String

### Community 537 - "NSObject"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.03
Nodes (63): ayn(), b2t(), b3e(), b5e(), c6(), cke(), Ct(), d9n() (+55 more)

### Community 539 - "SavedLayoutIPCDaemonTests"
Cohesion: 0.50
Nodes (3): OptionSet, Modifiers, UInt8

### Community 540 - ".delay"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 541 - ".init"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 542 - ".init(from:)"
Cohesion: 0.40
Nodes (5): CodingKeys, bindings, disabledSpecs, id, tables

### Community 543 - ".bufferLine"
Cohesion: 0.24
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 545 - ".characterIndex"
Cohesion: 0.25
Nodes (6): String, URL, ThemeCatalogEmbedTests, .embedSwift, .repoRoot, .sourceJSON

### Community 546 - "LegacySnapshot"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 547 - "NSObject"
Cohesion: 0.15
Nodes (3): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess

### Community 548 - ".encode"
Cohesion: 0.50
Nodes (4): PaletteMode, errors, grep, normal

### Community 549 - ".init(from:)"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: What commands build and test Kouen and prepare Graphify before commit?

### Community 550 - ".init(hex:)"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 552 - "PaneLabelDaemonTests"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Key spec syntax, Kouen keybindings, Persistence (+1 more)

### Community 553 - "harness.resource"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 554 - "eFe"
Cohesion: 0.33
Nodes (4): OutputTrigger, OutputTriggerStore, Bool, String

### Community 555 - "code:bash (harness view <file>                        # syntax-highligh)"
Cohesion: 0.33
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

### Community 556 - "MobileBridgeSpawnTests"
Cohesion: 0.67
Nodes (3): commit_with_graph(), prepare_graph_for_commit(), graphify-commit.sh script

### Community 557 - ".viewWillMove"
Cohesion: 0.04
Nodes (61): A1(), a2(), akn(), ast(), B1(), bln(), bpn(), Bsn() (+53 more)

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.22
Nodes (8): Build order (unchanged from interview decision), G1 — @ file-path picker, G2 — shell tab-completion suggestion strip (heuristic, explicitly best-effort), G3 — AI command suggestion (via `claude` CLI subprocess), Logical Design, P37 Phase G — Autocomplete (mobile bridge), Strategic Design, Tactical Design

### Community 560 - "AgentNotification"
Cohesion: 0.22
Nodes (8): Artifacts, Client Application — Slice 1 (stacked panes, no persistence), Client Application — Slice 2 (per-workspace divider memory), Context, Dev Task Progress — Workspace Sidebar Panels (P42), Integration, Note on task re-sequencing (2026-07-17), Summary

### Community 561 - "AppIdleThrottle"
Cohesion: 0.22
Nodes (9): Contributors, Documentation, Install, Key features, Kouen, License, Requirements, Update (+1 more)

### Community 562 - "BrowserResponsePayload"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 566 - "TerminalTabBarView.swift"
Cohesion: 0.22
Nodes (7): block, escFn, lineFilter, md, page, script, swift

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.10
Nodes (20): Agent Memory, AI-SDLC — Dev/QA Workflow Spine, AODD: the operating contract, AODD triage: every request passes this gate (silently, no announcement), Approval Gates (mandatory on the Requirement path), Audit and Done, Cheap-model delegation, Core facts (non-negotiable, not model-inferable — everything else is judgment) (+12 more)

### Community 568 - ".installChromeBackground"
Cohesion: 0.39
Nodes (4): SessionGroup, Any, String, Tab

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.36
Nodes (3): .agentInfo(forWorktreePath:tabs:), Tab, GitPanelViewWorktreeAgentTests

### Community 571 - "ShellIntegrationTests"
Cohesion: 0.20
Nodes (8): statusHelp(), String, TabStatus, done, error, idle, running, waiting

### Community 572 - "LayoutProbeView"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 573 - "tHe"
Cohesion: 0.22
Nodes (8): A `claude` typed by hand, Claude Code → Kouen, Customizing, One-line install, Session mode: Remote Control / cloud / local, The reverse direction: a session opened in Claude showing up in Kouen, Verifying, What gets written

### Community 574 - "FileTreeKeyboardNavigator"
Cohesion: 0.32
Nodes (4): PaneID, SessionGroup, Tab, first

### Community 578 - "TaskDashboardBody"
Cohesion: 0.17
Nodes (4): bUt(), GUt, mUt(), _Q()

### Community 580 - "ViInputMode"
Cohesion: 0.25
Nodes (7): Claude Code hook push (in-process Task subagent detection), Client UI indicator, Detection core (AgentDetector, pure logic), IPC / Tab plumbing, P38 Phase B — Subagent Visibility — Dev Task Progress, Status: Rewritten 2026-07-14 after original implementation (tasks 1-5) was lost to a concurrent git operation before commit. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 581 - "jD"
Cohesion: 0.25
Nodes (7): Original overlay build (built 2026-07-14, gated green, then deleted 2026-07-15 mid live-test), P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress, Pivot — merge into the Recipes picker (2026-07-15), Stage 1-2 — Engine/surface plumbing (built 2026-07-14, unchanged by the pivot, still in use), Status: Implementation pivoted mid-phase from a standalone overlay to a merge into the existing, Summary, Thread grouping — Zed framing folded into the same picker (2026-07-15)

### Community 582 - ".groupByRoot"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 583 - "WorkbenchMRU"
Cohesion: 0.25
Nodes (7): #kouen, #practice, #score, #shell, #total, #unix, #vim

### Community 584 - "GUt"
Cohesion: 0.29
Nodes (5): ThaiClusterCopyTests, ThaiGrid, .columns, .totalLines, .viewportRows

### Community 585 - "P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress"
Cohesion: 0.25
Nodes (3): FlushSessionStateTests, String, URL

### Community 593 - "dO"
Cohesion: 0.13
Nodes (4): NSTextView, KouenApp, GitPanelViewDiffPopoverTests, GitPanelViewFSEventFilterTests

### Community 594 - "r2"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 595 - "full-cycle.sh"
Cohesion: 0.29
Nodes (7): 1. Plain Terminal, 2. Persistent Terminal, 3. Full Terminal, 4. Agent Workspace, Experience modes, Opting into the prefix + status line without switching modes, Persistence (ephemeral vs. persistent)

### Community 596 - ".feed(_:)"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Kouen-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 597 - "TerminalColorRole"
Cohesion: 0.33
Nodes (6): Command, .targetKind, TargetKind, pane, session, window

### Community 598 - ".encode"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 599 - ".terminalHostIfExists"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 600 - "TaskDashboardGroupingTests"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 603 - "fut"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

### Community 604 - "k0t"
Cohesion: 0.29
Nodes (6): .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8

### Community 607 - "iRe"
Cohesion: 0.29
Nodes (6): Locked decisions (user-confirmed), Logical Design, P38 Phase A — Cross-Agent Worktree Diff/Review Dashboard — Design, Strategic Design, Tactical Design, Verification gate (this phase)

### Community 608 - "W2"
Cohesion: 0.29
Nodes (6): Logical Design, Next Step, P42 — Workspace Sidebar Panels, Parked (not in scope), Strategic Design, Tactical Design

### Community 609 - "FormatContextDaemonTests"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 610 - "TabStatus"
Cohesion: 0.29
Nodes (6): Any, Error, MainActor, Sendable, String, Void

### Community 612 - ".init(coder:)"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 616 - "bump-version.sh"
Cohesion: 0.43
Nodes (3): KouenMCPServer, Bool, String

### Community 619 - "_0n"
Cohesion: 0.33
Nodes (6): h1t(), hae(), jgn(), pwn(), sfn(), _Ue()

### Community 622 - "sBt"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 624 - "gmn"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase D — Kitty Graphics Conformance Slice, Scope (locked), Tests

### Community 625 - "brt"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua), Scope (locked), Tests

### Community 626 - "cGt"
Cohesion: 0.33
Nodes (5): Logical Design, Next Step, P43 — Add Repo/Folder to Workspace, Strategic Design, Tactical Design

### Community 627 - "ActiveTabCloseDisposition"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 628 - "ReplayStep"
Cohesion: 0.60
Nodes (5): main(), printHelp(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 629 - "graphify reference: query, path, explain"
Cohesion: 0.40
Nodes (3): String, URL, WorktreeSignatureTests

### Community 632 - "dne"
Cohesion: 0.47
Nodes (3): URL, TimeoutError, WorktreeLargeOutputRegressionTests

### Community 634 - "qC"
Cohesion: 0.23
Nodes (4): MCPServer, String, StdioTransport, AsyncStream

### Community 635 - "yDt"
Cohesion: 0.67
Nodes (3): AsyncCLIResultBox, Error, Result

### Community 637 - "TerminalScrollbarView"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 641 - "[3.10.0] - 2026-06-27"
Cohesion: 0.40
Nodes (4): Findings, Sources, What this means for Kouen, Who creates branches / worktrees in AI coding tools

### Community 642 - "qut"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: animateSidebar setContentLeadingInset MainSplitViewController, Source Nodes

### Community 643 - "h7n"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: ProjectCategory FolderScanner ProjectDirectoryTree, Source Nodes

### Community 644 - "clean-state.sh"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: BrowserPaneView createTab openBrowserPane navigation WebKit, Source Nodes

### Community 645 - ".delay"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: KouenPreviewHome environment key daemon launch at startup, Source Nodes

### Community 646 - ".isRisky"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: session history search ranking branch best matches, Source Nodes

### Community 647 - "graphify reference: query, path, explain"
Cohesion: 0.40
Nodes (5): CwdAuthorizationError, foreignPathRejected, .message, missingSessionOrCwd, other

### Community 649 - "h$t"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 650 - "hjt"
Cohesion: 0.40
Nodes (5): ResizeDirection, down, left, right, up

### Community 653 - "iOn"
Cohesion: 0.04
Nodes (65): _7n(), a7e(), aat(), AS(), c5n(), cc(), cOn(), d2() (+57 more)

### Community 656 - "Jcn"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 657 - "clear-runtime-state.sh"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 658 - "k0n"
Cohesion: 0.33
Nodes (5): Build, Release & Git Workflow, Build / Test / Run, Graphify before every delivery commit, Release packaging order, Worktree constraint

### Community 659 - "LayoutTemplate"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 660 - "qAn"
Cohesion: 0.70
Nodes (4): restart_daemon(), rollback_version_bump(), full-cycle.sh script, usage()

### Community 661 - ".compute"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 662 - "New Tab"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 665 - "nb"
Cohesion: 0.19
Nodes (8): CLIInstallLocator, OptionalUUID, absent, dangling, invalid, valid, URL, UUID

### Community 670 - "pie"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

### Community 671 - "AntigravityTranscriptTurnsTests"
Cohesion: 0.50
Nodes (3): Caveats, Keep awake with the lid closed, Setup

### Community 672 - "ColorKind"
Cohesion: 0.50
Nodes (4): Full local signing path (needs a Developer ID cert; not currently used), How this fork actually releases, Release runbook, Scripted flow

### Community 674 - "t2e"
Cohesion: 0.50
Nodes (3): exclude_hubs, no_viz, wiki

### Community 675 - ".detect"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: SSETransport auth token isRunning

### Community 676 - "vne"
Cohesion: 0.50
Nodes (4): WriteOutcome, complete, failed, wouldBlock

### Community 679 - "TriState"
Cohesion: 0.50
Nodes (4): dO(), m8(), rfn(), zfn()

### Community 680 - "AgentVectorIcon"
Cohesion: 0.67
Nodes (4): FVe(), hJ(), qVe(), Zme()

### Community 681 - ".tabIDsToNotify"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 683 - "TransportError"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 684 - "CommandParseError"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 686 - "DECSpecialGraphics"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 694 - "Result"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 695 - "FormatContext"
Cohesion: 0.67
Nodes (3): cat(), Hwe(), kYe()

### Community 696 - "TerminalTabBarDelegate"
Cohesion: 0.67
Nodes (3): cfn(), fut(), qYe()

### Community 697 - "ReleaseNotes"
Cohesion: 0.67
Nodes (3): dht(), k0t(), l1n()

### Community 700 - ".agentInfo(forWorktreePath:tabs:)"
Cohesion: 0.67
Nodes (3): iRe(), jNt(), zNt()

### Community 701 - ".testOccludedPaneParsesButNeverPresents"
Cohesion: 0.25
Nodes (4): _c(), Nn(), Pqe, qp()

## Knowledge Gaps
- **2379 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+2374 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1167 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Work-memory lessons

**Known dead ends** — questions that led nowhere; don't re-derive.
- "KouenPreviewHome environment key daemon launch at startup" -> `KouenPaths`

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `.parse` to `EngineConformanceTests`, `IPCRequest`, `AgentNotchRootView`, `LSPMessage`, `TerminalEmulator`, `PerformanceBenchmarks`, `GitPanelView.swift`, `WriteOutcome`, `KittyKeyboardTests`, `Kind`, `VTParser`, `.applyPreedit`, `MetalRendererTests`, `HarnessUILibrary`, `HarnessTerminalSurfaceView`, `OpenClaw → Kouen`, `HarnessTerminalSurfaceView`, `CopyModeAction`, `SplitPaneCoordinator`, `.request`, `p12_mcp.robot`, `code:block1 (Agent shell process)`, `RGBColor`, `WorktreeManager`, `Harness tmux-style capabilities`, `Notification`, `.addTab`, `Equatable`, `DaemonClient`, `MenuTarget`, `LegacySnapshot`, `String`, `code:bash (swift build)`, `TerminalColorGamut`, `CodingKeys`, `RenderSchedulerTests`, `code:bash (harness view <file>                        # syntax-highligh)`, `HarnessTerminalSurfaceView.swift`, `.buildCommand`, `.normalizedKey`, `HarnessOverlayBackground`, `DaemonServer`, `Added`, `.keyEvent`, `AgentNotchViewModel.swift`, `Added`, `3.2 สิ่งที่ implement แล้ว`, `ViEngine`, `FileTreeKeyboardNavigator`, `HarnessCLI+Server.swift`, `ComposedCell`, `PrefixKeymap`, `ShellIntegration`, `String`, `.compose`, `worktree_isolation_cli.robot`, `ImportedTerminalConfig`, `XCTestCase`, `GUt`, `[2.6.0] - 2026-06-13`, `.parse`, `TerminalProtocolCompatibilityTests`, `Added`, `Agent handbook — Harness (extended reference)`, `dO`, `DaemonSubscription`, `LSPDiagnostic`, `.init`, `HarnessPaths`, `SessionCoordinator`, `.line`, `Harness as a terminal multiplexer`, `.encode`, `TerminalModes`, `k0t`, `code:bash (# Terminal 1: Create workspace with long-running job)`, `.cursorPos`, `shim.c`, `Zombie View Crashes on macOS 26.5 + Swift 6.3.2`, `PaneContainerView`, `AttachInputBatcher`, `.dispatch`, `FormatContextDaemonTests`, `Session Grouping and Split Session Plan`, `DaemonLauncher`, `AnyCodable`, `Recipe`, `SpecialKey`, `DamageTrackingTests`, `SoftIconButton`, `code:text (:workbench start swift)`, `.makeSnapshot`, `HarnessGridTerminal`, `SessionGroup`, `PaneNode`, `WorkspaceFileTreeView`, `Harness command reference`, `Added`, `dne`, `ViEngine`, `Pipe`, `yDt`, `HistoryRingBuffer`, `.path`, `GlyphAtlas`, `.install`, `AgentHookInstaller`, `ActivePaneService`, `h$t`, `.didCompleteSend`, `Added`, `.testPaneLeafLegacyDecodeBackfillsSurfaceTabs`, `แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)`, `How to use Harness from the terminal only (no GUI)`, `PaneStyleSet`, `clear-runtime-state.sh`, `FileTreeWatcher`, `TriState`, `EnvironmentStore`, `HarnessDaemonToolsTests`, `.evaluate`, `nje`, `Added`, `Harness Terminal — IDE Sidebar Feature Branch`, `ThaiCombiningMarkTests`, `AmbientBackground`, `Any`, `TerminalFindBar`, `Workspace`, `CommandPromptController`, `ActiveTabCloseDisposition`, `LiveSession`, `New Tab`, `What You Must Do When Invoked`, `Added`, `.decodeKeySpec`, `RGBColorTests`, `Additional `kouen-cli` subcommands`, `[3.13.1] - 2026-07-02`, `InlineAICompletionView`, `P25 — iOS/iPadOS Support`, `targets`, `AppDelegate`, `BrowserPaneView`, `user-stories.md`, `ScriptRuntime`, `main.swift`, `Feature Provenance — harness-terminal`, `AgentSessionSummary`, `code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)`, `PaletteModel`, `Harness keybindings`, `HarnessCLI`, `scheduleRender`, `PaneTarget`, `PromptQueueBar`, `CellColorResolverTests`, `Prompt`, `Section`, `TerminalServicesProvider`, `CellColorResolver`, `.init`, `sessionRow`, `ExternalOpenKind`, `.setCellPixelSize`, `TextGrid`, `WorkbenchCommand`, `Added`, `.make`, `PaneBorderStatus`, `Added`, `.make`, `Experience modes`, `NSViewRepresentable`, `Split Right`, `CompositorFixtureSpec.swift`, `create-dmg.sh`, `ThemeFileServiceTests`, `Browser Pane (P14)`, `.path`, `.performInstall`, `code:bash (# Old (agent-specific):)`, `DefaultTerminalManager`, `SGRMouseEvent`, `[2.5.0] - 2026-06-12`, `BlockTintOverlay`, `.bufferLine`, `After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md.`, `.apply`, `AgentHookStrategy`, `.init`, `Process`, `h`, `Fixes Applied (layered)`, `NotificationBus`, `settings.json`, `HarnessPaths.swift`, `.parse`, `ThemeDiagnostics`, `.encodeMouse`, `00-inception-plan.md`, `.script`, `.bufferLine`, `Send Ex Command`, `Bug: Tab-Switch Black Screen`, `AgentSnapshot`, `Terminal AI Chat (⌘I inline overlay)`, `code:bash (harness-cli install-hooks opencode)`, `code:bash (# In a Harness pane:)`, `UInt64`, `DesktopNotifier`, `LayoutNode`, `.theme`, `README.md`, `.toggleWindowOpacity`, `run.sh`, `code:bash (harness-cli install-hooks pi)`, `Added`, `FileViewerViewController`, `README.md`, `.jumpToBlock`, `DaemonLifecycleTests`, `Contents.json`, `Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)`, `GPU Animation Pattern — Layout Once, GPU Paints`, `.init`, `RGBColor`, `Consumers`, `DaemonStats`, `Tab`, `Prompt`, `smoke-dmg.sh`, `terminal_stress_runner.py`, `INDEX.md`, `SKILL-LOG.md`, `User Profile`, `build-release.sh`, `sign-and-notarize.sh`, `package-app.sh`, `Fixed`, `Session/Tab/Pane Hierarchy & Top Bar (CASE-028)`, `.parseDiffHunks`, `Bug — Cmd+\ sidebar toggle gone after collapse`, `Competitive Position (as of v3.12.0, 2026-07-02)`, `LaunchdServiceInstaller`, `WaitForRegistry`, `SetupStepView`, `RemoteHostStore`, `Section`, `.run`, `.worktreeList`, `.moveSelection`, `PresentAttempt`, `.evaluateStyled`, `StatusDotView`, `.isRisky`, `.resolve`, `bC`, `R1`, `ccRunGet`, `.update`, `Service Decomposition — SessionCoordinator (P17)`, `ccRunStart`, `start.mjs`, `PromptQueue`?**
  _High betweenness centrality (0.277) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `Added` to `code:block1 (SessionCoordinator.snapshot ──┐)`, `README.md`, `Changelog`, `RenderSchedulerTests`, `AgentSessionSummary.swift`, `.agentName`, `VTParser`, `Added`, `PaneBorderStatus`, `DaemonServer`, `measure-fluidity.sh`, `.make`, `PathToken`, `Added`, `.parse`?**
  _High betweenness centrality (0.211) - this node is a cross-community bridge._
- **Why does `fbt()` connect `Changed` to `CodingKey`, `callingPaneTarget`, `iOn`, `PaneBorderStatus`, `SessionGroupHeaderRowView`?**
  _High betweenness centrality (0.108) - this node is a cross-community bridge._
- **Are the 18 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `RenderScheduler`) actually correct?**
  _`KouenTerminalSurfaceView` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _2399 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.006576057926286427 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.01348936170212766 - nodes in this community are weakly interconnected._