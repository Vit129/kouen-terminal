# Graph Report - close-release-2026-11-16  (2026-11-16)

## Corpus Check
- 972 files · ~1,064,768 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 20289 nodes · 58522 edges · 2701 communities (1564 shown, 1137 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8600 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `033e9d28`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 346 edges
2. `i()` - 318 edges
3. `a()` - 282 edges
4. `SessionCoordinator` - 235 edges
5. `SurfaceRegistry` - 231 edges
6. `TerminalEmulator` - 229 edges
7. `DaemonClient` - 217 edges
8. `u()` - 217 edges
9. `IPCRequest` - 211 edges
10. `KouenCLI` - 210 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 193 areas (211 edges)
2. `Command` - bridges 102 areas (108 edges)
3. `AgentKind` - bridges 86 areas (176 edges)
4. `IPCResponse` - bridges 83 areas (107 edges)
5. `KouenTerminalSurfaceView` - bridges 75 areas (346 edges)
6. `SessionCoordinator` - bridges 71 areas (235 edges)
7. `NSView` - bridges 70 areas (193 edges)
8. `SurfaceRegistry` - bridges 69 areas (231 edges)
9. `KouenGridTerminal` - bridges 64 areas (117 edges)
10. `AnyCodable` - bridges 62 areas (190 edges)

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

## Communities (2701 total, 1137 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.01
Nodes (689): _0t(), _1n(), _2t(), _3e(), _3n(), _5n(), _6e(), _6n() (+681 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.01
Nodes (526): l, V, em(), z(), _4n(), _5e(), _7n(), _8n() (+518 more)

### Community 2 - ".handleNormal"
Cohesion: 0.02
Nodes (441): pe(), X(), A(), code(), R(), a(), aD(), ae() (+433 more)

### Community 3 - "Changed"
Cohesion: 0.02
Nodes (232): a(), b(), c(), d(), e(), f(), g(), h() (+224 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.05
Nodes (44): AgentBridge, AgentTarget, Bool, String, SurfaceID, .onCurrentCWD, .onCurrentFile, LinePos (+36 more)

### Community 5 - "IPCRequest"
Cohesion: 0.03
Nodes (113): Oe(), _4e(), a2n(), a4e(), a4n(), a6e(), ag(), b2() (+105 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.04
Nodes (30): NSCursor, NSEvent, Bool, Selector, KouenTerminalSurfaceView, .gridOriginPointsX, .gridOriginPointsY, .init(themeName:fontFamily:fontSize:vivid:colorRendering:colorGamut:offMainParserFramePipeline:liveResizeReflow:) (+22 more)

### Community 7 - "Command"
Cohesion: 0.04
Nodes (37): .tab(for:), .tab(forSurfaceKey:), AgentScanner, Bool, DispatchSourceTimer, TimeInterval, DaemonCommandExecutor, Command (+29 more)

### Community 8 - "LSPMessage"
Cohesion: 0.05
Nodes (20): IndexingIterator, LayoutTemplate, surfaceID, SessionEditor, .surfaceID(forPaneID:), .surfaceID(forPaneID:in:), .tabIndex(surfaceID:), Command (+12 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.03
Nodes (98): a0(), a6(), agt(), b6n(), bC(), bce(), bFe(), c8n() (+90 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.06
Nodes (31): TerminalModes, InputEncoder, .encode(_:modifiers:event:modes:), .encode(text:modifiers:modes:), .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release (+23 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.08
Nodes (47): MTLClearColor, MTLCommandBuffer, MTLLibrary, MTLRenderCommandEncoder, MTLRenderPipelineState, Int, ImageTextureCache, MTLDevice (+39 more)

### Community 12 - "Changed"
Cohesion: 0.09
Nodes (20): Bool, Double, .addSurface(tabID:paneID:), .addSurface(to:paneID:surfaceID:cwd:), .split(node:targetPaneID:direction:paneCount:before:), .split(node:targetPaneID:with:direction:beforeTarget:), .tab(containingPaneID:), .tabIndex(surfaceKey:) (+12 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.06
Nodes (44): DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed, DaemonSubscription, .start(onData:onEnd:buffered:) (+36 more)

### Community 14 - "VTParser"
Cohesion: 0.08
Nodes (11): .receive(_:), DispatchSemaphore, FluidityBenchmarks, NSWindow, String, UInt64, KouenTerminalSurfaceWorkerTests, LiveResizeTests (+3 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.06
Nodes (36): MochaTheme, TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid (+28 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.12
Nodes (12): TerminalDamage, RenderColor, MetalRendererTests, RenderedFixture, Bool, MTLDevice, MTLTexture, StaticString (+4 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.09
Nodes (9): KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), SpawnedAgentSurface, Bool, ISO8601DateFormatter, Result, String, Tab (+1 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.07
Nodes (44): AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem, fetchGitStatus() (+36 more)

### Community 19 - "SpecialKey"
Cohesion: 0.06
Nodes (31): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+23 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.05
Nodes (48): .init(entry:), AgentChipView, .init(coder:), .init(frame:), .intrinsicContentSize, ChromeBackdrop, .init(role:), Colors (+40 more)

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.06
Nodes (37): KouenCommands, ColorKind, .base, bg, fg, underline, ComposedCell, .asGridCell (+29 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.08
Nodes (23): Data, OSCTerminatorMatch, PtyError, launchFailed, RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), .retainedScrollbackBytesForTesting, ScrollbackEntry (+15 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.09
Nodes (36): json, async, AgentHistoryScanner, .parseAntigravityTranscript(sessionID:fileURL:), .parseAntigravityTranscript(sessionID:fileURL:toIndex:), .parseClaudeTranscript(fileURL:), .parseClaudeTranscript(fileURL:toIndex:), .parseCodexTranscript(fileURL:surfaceTag:ftsIndex:) (+28 more)

### Community 24 - ".request"
Cohesion: 0.06
Nodes (34): NSView, NSPoint, SessionDividerRowView, .init(coder:), .init(frame:), SessionGroupHeaderRowView, .init(coder:), .init(frame:) (+26 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.07
Nodes (32): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, .body, PaletteMode (+24 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.07
Nodes (13): SessionGroup, SessionID, String, KouenSidebarPanelViewController, NSMenuItem, SessionGroup, String, NSMenu (+5 more)

### Community 27 - "RGBColor"
Cohesion: 0.05
Nodes (28): CornerInfo, EditorDividerView, HitTestPassthroughView, KouenSplitView, .dividerColor, .dividerThickness, .init(coder:), PaneDragGripView (+20 more)

### Community 28 - ".parse"
Cohesion: 0.09
Nodes (7): Bool, Command, DispatchWorkItem, PaneID, String, UInt8, WindowSession

### Community 29 - "Added"
Cohesion: 0.11
Nodes (10): .agentColorBinding, colors, PerformanceBenchmarks, Bool, Double, MTLDevice, MTLTexture, String (+2 more)

### Community 30 - "Notification"
Cohesion: 0.08
Nodes (13): TerminalGridCell, HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor, Bool, ClosedRange (+5 more)

### Community 31 - "Sendable"
Cohesion: 0.07
Nodes (32): ArtifactKind, html, image, markdown, text, AutomationsFleetModel, .load(detectScheduledRuns:), AutomationSource (+24 more)

### Community 32 - ".addTab"
Cohesion: 0.08
Nodes (21): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, AutomationScheduler (+13 more)

### Community 33 - "Equatable"
Cohesion: 0.07
Nodes (16): DisplayWidth, String, Unicode, ReleaseNotes, Section, String, Run, String (+8 more)

### Community 34 - "DaemonClient"
Cohesion: 0.15
Nodes (7): AnyCodable, JSONRPCError, Bool, Int32, Pipe, String, ToolRegistry

### Community 35 - "MenuTarget"
Cohesion: 0.07
Nodes (21): GitCommitCommand, String, AsyncRunCoordinator, drainOutput(), OutputBuffer, OutputCapture, ProcessCancellation, ProcessResult (+13 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.07
Nodes (30): GroupHeaderRow, .body, PickerItem, .groupLabel, historyBlock, .id, recipe, .searchableText (+22 more)

### Community 37 - "String"
Cohesion: 0.06
Nodes (31): Bool, String, UUID, TaskDaemonBridge, SessionID, CGFloat, NSCoder, SessionID (+23 more)

### Community 38 - "code:bash (swift build)"
Cohesion: 0.08
Nodes (42): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+34 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.07
Nodes (20): DecodedReplyFrame, output, reply, DecodedRequestFrame, input, request, FrameError, tooLarge (+12 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.05
Nodes (47): AnyTransition, AnyView, Color, .hexString, AgentNotchPeekEvent, AgentNotchRootView, .body, .bottomRadius (+39 more)

### Community 41 - "CodingKeys"
Cohesion: 0.06
Nodes (28): Notification.Name, KouenGit, os, Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached (+20 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.14
Nodes (15): .exit, DaemonClient, String, KouenCLI, SessionID, String, Bool, Int32 (+7 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.08
Nodes (19): ConcurrentIndexSet, .count, DaemonContentionTests, SubscriptionBox, .count, URL, DaemonRoundTripTests, RawSocketError (+11 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.06
Nodes (46): AgentRow, .agentColor, .executables, .hookButton, .hookButtonTitle, SettingsAgentsView, .agentsSection, .notchSection (+38 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.08
Nodes (23): DisplayLinkTarget, MainSplitViewController, .setSidebarVisible(_:), .setSidebarVisible(_:animated:), SplitChromeDelegate, .sidebarMaxWidth, .sidebarMinWidth, .splitView(_:constrainMaxCoordinate:ofSubviewAt:) (+15 more)

### Community 46 - ".buildCommand"
Cohesion: 0.06
Nodes (33): FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body, .emptyState (+25 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.06
Nodes (45): Configuration, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, ButtonStyle, CommandRow, .body, GlassCard, .body (+37 more)

### Community 48 - "HookEvent"
Cohesion: 0.07
Nodes (10): NWEndpoint, Bool, NWListener, Sendable, String, UInt16, MobileBridgeServer, PipeBuffer (+2 more)

### Community 49 - "DaemonServer"
Cohesion: 0.09
Nodes (30): Equatable, KouenGridTerminal, TerminalGridSnapshot, .currentSelectionRegion, ClosedRange, String, BlockSelection, CursorRender (+22 more)

### Community 50 - "Added"
Cohesion: 0.06
Nodes (31): Error, LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed, serverNotExecutable, AsyncStream (+23 more)

### Community 51 - ".keyEvent"
Cohesion: 0.06
Nodes (35): Executor, Hook, HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane (+27 more)

### Community 52 - "Fixed"
Cohesion: 0.08
Nodes (28): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary, RowKind (+20 more)

### Community 53 - "Added"
Cohesion: 0.09
Nodes (10): SessionCoordinator, .selectWorkspace(_:), Bool, Double, PaneID, String, SurfaceID, TabID (+2 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.07
Nodes (22): Logger, OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, .event(_:), .interval(_:_:) (+14 more)

### Community 55 - "TabCell"
Cohesion: 0.08
Nodes (11): Bool, Range, Set, String, URLDetection, CGFloat, CGRect, Range (+3 more)

### Community 56 - "NSPanel"
Cohesion: 0.07
Nodes (21): GitAheadBehind, GitResult, .isSuccess, GitWorktreeInfo, Bool, Int32, String, GitParsers (+13 more)

### Community 57 - "BellScanState"
Cohesion: 0.11
Nodes (22): AgentHistoryFTSIndex, .deleteSession(sessionID:), .needsReindex(sessionID:mtime:fileSize:), .pruneMissingSessions(validTranscriptPaths:), .saveRecord(_:mtime:fileSize:), .saveRecordsBatch(_:), .search(query:limit:), .searchRanked(query:limit:includeSnippet:requireAllTokens:includeMetadata:matchingIDs:) (+14 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.10
Nodes (20): AppKit, CoreGraphics, CoreText, ImageIO, KouenCopyMode, KouenTerminalEngine, KouenTerminalKit, KouenTerminalRenderer (+12 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.08
Nodes (29): .filteredJobs, MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith (+21 more)

### Community 60 - "ViEngine"
Cohesion: 0.05
Nodes (51): ake(), al(), ase(), aTn(), aV(), bdn(), bIn(), d6n() (+43 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 62 - "ComposedCell"
Cohesion: 0.08
Nodes (28): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, PaletteFooter, .body (+20 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.07
Nodes (13): Bool, NSDraggingInfo, NSDragOperation, Any, Bool, NSMenu, NSMenuItem, NSPasteboard (+5 more)

### Community 64 - ".text"
Cohesion: 0.07
Nodes (17): NSRangePointer, Bool, CAMetalDrawable, String, Any, NSAttributedString, NSRange, NSRect (+9 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.10
Nodes (23): String, KeySpec, Binding, .init(from:), .init(spec:command:note:repeatable:), KeyTable, .init(from:), .init(id:bindings:disabledSpecs:) (+15 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.06
Nodes (29): keys, CGImage, DecodedImage, .byteCount, ImageLimits, Bool, UInt8, ImageDecoder (+21 more)

### Community 67 - "String"
Cohesion: 0.12
Nodes (13): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, PaneID (+5 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.09
Nodes (14): DiffLineType, added, deleted, modified, Bool, NSEvent, NSPopover, NSRange (+6 more)

### Community 69 - ".compose"
Cohesion: 0.13
Nodes (13): NaturalLanguage, .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:surfaceTag:topicSegments:), AgentHistorySearch, Hit, IDFCache, Bool, Double, String (+5 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.10
Nodes (19): InputGate, .siblings, ReconnectLatch, .isTripped, SurfaceIO, .currentSubscription, Bool, CGFloat (+11 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.09
Nodes (16): .rowList, AgentNotchViewModel, Bool, CGFloat, Duration, String, NotchPanel, .canBecomeKey (+8 more)

### Community 72 - "XCTestCase"
Cohesion: 0.09
Nodes (16): .effectiveResumeCommand(claudeMode:), LiveClaudeAgentEntry, .placement, ClaudeSessionMode, TimeoutFlag, .didFire, ClaudeCloudSessionStore, Entry (+8 more)

### Community 73 - "README.md"
Cohesion: 0.07
Nodes (16): .readJSONLLines(from:fromOffset:), ClaudeSessionLocator, ClaudeTranscriptLine, Role, assistant, user, Any, Bool (+8 more)

### Community 74 - "[2.6.0] - 2026-06-13"
Cohesion: 0.11
Nodes (16): String, AgentRoutingRule, Kind, path, stack, Bool, Date, UUID (+8 more)

### Community 75 - "OptionStore"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 76 - ".parse"
Cohesion: 0.08
Nodes (23): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSEvent (+15 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.08
Nodes (13): Tab, BrowserIntegrationController, PaneID, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), SurfaceID, PaneLifecycleManager, Bool (+5 more)

### Community 78 - "Added"
Cohesion: 0.09
Nodes (16): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController, CheckpointInfo (+8 more)

### Community 79 - "HarnessDesign"
Cohesion: 0.08
Nodes (26): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+18 more)

### Community 80 - "Agent handbook — Harness (extended reference)"
Cohesion: 0.07
Nodes (17): KouenCLITests, CLIInstallLocator, DetachKeys, absent, invalid, parsed, OptionalUUID, absent (+9 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.10
Nodes (18): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+10 more)

### Community 82 - ".firstMatch"
Cohesion: 0.15
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 83 - "LSPClient"
Cohesion: 0.05
Nodes (38): Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions, Logical Design, P41 — Automations, Strategic Design, Tactical Design (+30 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.10
Nodes (15): FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect, String, URL (+7 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.08
Nodes (18): NSScrollView, NSWindow, Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent (+10 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.08
Nodes (23): AgentHistoryDateGroup, older, .sortOrder, thisWeek, today, yesterday, AgentSessionHistoryModel, .extraRecordsShown (+15 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.07
Nodes (14): CustomStringConvertible, KouenPaths, KouenPathsError, .description, socketPathTooLong, Bool, String, T (+6 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.14
Nodes (17): ClientRecord, CountBox, DaemonServer, .guiBrowserFD, PendingBrowserRequest, PendingWrite, Bool, CheckedContinuation (+9 more)

### Community 89 - ".cursorPos"
Cohesion: 0.08
Nodes (23): .init(coder:), Kind, primary, secondary, .init(coder:), KouenPillButton, .init(coder:), .init(title:kind:) (+15 more)

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.13
Nodes (5): .setupPrompt, hooks, AgentHookInstallerTests, String, URL

### Community 91 - "TerminalModes"
Cohesion: 0.18
Nodes (11): SwarmSpawnSpec, CallRecorder, .cancelCalls, .closeCalls, .harnessCalls, .surfaceCalls, SwarmWorkerManagerTests, Bool (+3 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.15
Nodes (9): StringKind, apc, dcs, UInt8, UnsafeBufferPointer, VTParser, .feed(_:), VTParserHandler (+1 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.14
Nodes (18): CommandParseError, .description, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand (+10 more)

### Community 95 - "shim.c"
Cohesion: 0.15
Nodes (12): FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID, KouenFeature (+4 more)

### Community 96 - "Harness Usage"
Cohesion: 0.15
Nodes (9): FormatContext, FormatString, FormatStyle, Bool, Character, Date, String, FormatStyledTests (+1 more)

### Community 97 - "PaneContainerView"
Cohesion: 0.14
Nodes (10): TerminalEmulator, .captureLines(joinWrapped:), .feed(_:), .promptRows, .readGrid(scrollbackOffset:), ScrollbackTests, Character, String (+2 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.11
Nodes (4): CSIParams, .count, UInt8, .cursorVisible

### Community 99 - ".dispatch"
Cohesion: 0.10
Nodes (15): ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy, SessionLifecycleService, Bool (+7 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.13
Nodes (29): Codable, BrowserSnapshotAck, agentWaitChannel(), BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserResponsePayload (+21 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.14
Nodes (15): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+7 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.12
Nodes (10): ScrollbackFile, .highWater, Bool, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 103 - "AnyCodable"
Cohesion: 0.09
Nodes (30): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+22 more)

### Community 104 - "Recipe"
Cohesion: 0.12
Nodes (13): SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, SessionID, String, SurfaceID (+5 more)

### Community 105 - "Changelog"
Cohesion: 0.11
Nodes (17): SettingsAdvancedView, .body, Bool, String, AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date (+9 more)

### Community 106 - "domain-design.md"
Cohesion: 0.11
Nodes (21): .pairedAlreadyBanner, .pairingQRPanel, .sidebarEmptyView, .rootPicker, TrackedIssue, IssueTrackerPanelView, .body, .filteredIssues (+13 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.10
Nodes (14): FlippedView, .isFlipped, .removeWorktreeAction(_:), NSButton, NSColor, NSRect, NSScrollView, NSStackView (+6 more)

### Community 108 - ".resolve"
Cohesion: 0.12
Nodes (6): GitPanelView, .isHidden, Any, DispatchWorkItem, NSMenuItem, UnsafeMutableRawPointer

### Community 109 - "DamageTrackingTests"
Cohesion: 0.11
Nodes (10): BrowserPaneView, DesignModeElementInfo, Any, DispatchWorkItem, NSPopover, ObjectIdentifier, Selector, String (+2 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.06
Nodes (12): o, r, aZ(), b8(), e0(), eie(), eZ(), h$() (+4 more)

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.10
Nodes (37): blockquote(), blockTokens(), br(), checkbox(), codespan(), constructor(), de(), del() (+29 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.06
Nodes (38): A1(), aat(), bln(), bw(), bwt(), bYe(), d1t(), d6() (+30 more)

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.08
Nodes (21): DaemonClientActor, TimeInterval, DaemonSessionError, daemonError, .description, unexpectedResponse, DaemonSessionService, .endpoint (+13 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.09
Nodes (10): MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, String, SurfaceID (+2 more)

### Community 115 - ".encode"
Cohesion: 0.07
Nodes (18): NSResponder, NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent (+10 more)

### Community 116 - "SessionGroup"
Cohesion: 0.12
Nodes (15): .activeTab, .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), BrowserTab, NSStackView, URL, UUID, WKNavigationAction (+7 more)

### Community 117 - "PaneNode"
Cohesion: 0.14
Nodes (9): MarkdownPreviewView, Bool, String, URL, KouenSyntaxResources, MarkdownPreviewTests, StaticString, String (+1 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.20
Nodes (10): BrowserOkAck, Sendable, T, ConnectionState, DraftPRAck, ErrorAck, FileAttachedAck, NWConnection (+2 more)

### Community 119 - "Harness command reference"
Cohesion: 0.11
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 120 - "Added"
Cohesion: 0.14
Nodes (8): MutationResult, RemoteHost, RemoteHostStore, Bool, String, RemoteHostStoreTests, String, URL

### Community 121 - "Changed"
Cohesion: 0.09
Nodes (17): ChromeRole, sidebar, tabBar, StatusLineView, .init(coder:), CGFloat, Never, NSAttributedString (+9 more)

### Community 122 - "ViEngine"
Cohesion: 0.09
Nodes (12): DetachedPaneOverlay, .init(coder:), .init(frame:style:), Style, detached, reconnectingChip, NSCoder, NSEvent (+4 more)

### Community 123 - "Pipe"
Cohesion: 0.06
Nodes (32): ModelProvider, .agentKindForLogo, aider, anthropic, azure, copilot, cursor, google (+24 more)

### Community 124 - "String"
Cohesion: 0.08
Nodes (13): KouenCore, Phase67Tests, LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab (+5 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.12
Nodes (19): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerFooter, .body, DirectoryPickerModel (+11 more)

### Community 126 - ".path"
Cohesion: 0.14
Nodes (12): Bool, OptionStore, Scope, global, pane, session, tab, workspace (+4 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.07
Nodes (21): ImagePlacementSnapshot, SemanticMark, Bool, TerminalCellWidth, normal, spacerTail, wide, TerminalColorRole (+13 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.13
Nodes (15): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+7 more)

### Community 129 - "SwiftUI"
Cohesion: 0.10
Nodes (19): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+11 more)

### Community 130 - "Harness"
Cohesion: 0.13
Nodes (15): PendingVersionBanner, welcome, whatsNew, State, Bool, String, URL, VersionBannerStore (+7 more)

### Community 131 - ".install"
Cohesion: 0.09
Nodes (23): BinaryInstaller, .bundledMacOSDir, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display (+15 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.13
Nodes (7): CGFloat, NSEvent, NSEvent, UInt8, NSEvent, NSPoint, UInt16

### Community 133 - ".load"
Cohesion: 0.14
Nodes (7): ScriptRuntime, Any, String, URL, JSContext, JSValue, ScriptingTests

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.11
Nodes (14): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+6 more)

### Community 135 - "CommandTarget"
Cohesion: 0.13
Nodes (12): .webView(_:didCommit:), WKWebViewConfiguration, BrowserPaneViewTests, MockWebView, .isLoading, .title, .url, Bool (+4 more)

### Community 136 - ".startWatching"
Cohesion: 0.12
Nodes (12): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+4 more)

### Community 137 - "ActivePaneService"
Cohesion: 0.11
Nodes (13): FileFuzzyMatcher, FileSearchRootScanner, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool (+5 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.14
Nodes (16): ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool, Command (+8 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.12
Nodes (9): ParsedShortcut, .displayString, PrefixKeymap, Any, Bool, NSEvent, String, TimeInterval (+1 more)

### Community 140 - "Added"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, Iterator (+2 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.07
Nodes (11): KouenDaemonCore, DaemonBrowserRoutingTests, IPCCodecInvariantTests, String, URL, DaemonOffLockWorktreeTests, String, URL (+3 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.13
Nodes (20): ChecksStatus, fail, none, pass, CIRun, GitHubCLIClient, IssueInfo, MergeMethod (+12 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.13
Nodes (11): String, ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID, String (+3 more)

### Community 145 - "AsciiFastPathTests"
Cohesion: 0.13
Nodes (10): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String (+2 more)

### Community 146 - "DecodedImage"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 147 - "FileTreeWatcher"
Cohesion: 0.13
Nodes (16): .windowSection, .renderingSection, KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:fileSearchRoots:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:), .scrollbackLines, ClaudeSessionMode, Decoder (+8 more)

### Community 148 - "TriState"
Cohesion: 0.15
Nodes (15): AgentIconRenderer, Scanner, .atEnd, SVGPathParser, Bool, CGFloat, CGPath, CGPoint (+7 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.12
Nodes (9): .records, .searchQuery, .selectedAgents, .selectedScope, Set, UInt64, AgentSessionHistoryModelTests, Date (+1 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.10
Nodes (13): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+5 more)

### Community 151 - ".evaluate"
Cohesion: 0.16
Nodes (11): tool, KouenDaemonToolsTests, String, URL, Document, Bool, Set, String (+3 more)

### Community 152 - "Added"
Cohesion: 0.12
Nodes (11): BrowserLeaf, PaneNode, URL, Decoder, .init(from:), DaemonSyncServiceBrowserLeafIdentityTests, Tab, DaemonSyncServiceBrowserPaneMergeTests (+3 more)

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.14
Nodes (15): GitStatusType, added, deleted, modified, renamed, unmodified, untracked, NodeRow (+7 more)

### Community 154 - "LiveResizeTests"
Cohesion: 0.12
Nodes (15): SavedLayoutStore, Bool, String, URL, UUID, PaneLayoutShape, branch, leaf (+7 more)

### Community 155 - "Int"
Cohesion: 0.13
Nodes (16): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, FileTreeContext, NSEvent (+8 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.12
Nodes (16): AgentSessionHistoryView, .body, .footerView, HistoryMenuProxy, Any, Bool, CGFloat, Date (+8 more)

### Community 157 - "Added"
Cohesion: 0.10
Nodes (14): BoardCardView, .init(card:), .init(coder:), .onDismiss, BoardViewController, .isVisible, FlippedView, .isFlipped (+6 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.12
Nodes (8): String, LSPDefinitionPayload, LSPDiagnosticsPayload, LSPStatusPayload, String, UInt64, URL, Set

### Community 159 - "MatchCategory"
Cohesion: 0.07
Nodes (32): aae(), aoe(), bR(), d9n(), e8n(), eL(), evt(), ha() (+24 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.18
Nodes (4): FilePreviewCoordinator, FileTabID, Set, String

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.13
Nodes (13): MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem, SessionGroup (+5 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.12
Nodes (18): clamp(), statusHelp(), Date, Never, String, T, TabID, Task (+10 more)

### Community 163 - "Workspace"
Cohesion: 0.06
Nodes (23): Codex → Kouen, One-line install, What you'll see, Grok Build → Kouen, One-line install, What you'll see, Hermes → Kouen, One-line install (+15 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.15
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.15
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, PaneID, SurfaceID (+3 more)

### Community 166 - "LiveSession"
Cohesion: 0.09
Nodes (23): aie(), arc(), b2e(), bezierCurveTo(), closePath(), cRe(), cZ(), E7() (+15 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.09
Nodes (11): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, PaneID, Task (+3 more)

### Community 168 - "Added"
Cohesion: 0.16
Nodes (11): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, .init(from:), .init(id:name:baseURL:modelID:), Decoder (+3 more)

### Community 169 - "Fixed"
Cohesion: 0.16
Nodes (15): Process, SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, SSHTunnelManager (+7 more)

### Community 170 - "URLDetection"
Cohesion: 0.12
Nodes (21): FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose, FileTabPillView (+13 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.11
Nodes (21): Motion, .entrance, .spring, .standardEase, CAMediaTimingFunction, NSWindowController, NSWindowDelegate, KouenOnboarding (+13 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.16
Nodes (10): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab, UUID (+2 more)

### Community 173 - "BoardCard"
Cohesion: 0.16
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.15
Nodes (16): ClaudeCodeHarness, Profile, edit, readonly, Run, RunState, cancelled, failed (+8 more)

### Community 175 - "RGBColorTests"
Cohesion: 0.07
Nodes (30): bNt(), bu(), cNt(), dNt(), eNt(), eRe(), fNt(), GRt() (+22 more)

### Community 176 - "Added"
Cohesion: 0.12
Nodes (10): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+2 more)

### Community 177 - ".rects"
Cohesion: 0.11
Nodes (10): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+2 more)

### Community 178 - "InlineAICompletionView"
Cohesion: 0.17
Nodes (14): SecureInputMonitor, DispatchQueue, DispatchWorkItem, MainActor, Sendable, Set, SurfaceID, UUID (+6 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.10
Nodes (20): DataBox, .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:) (+12 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.10
Nodes (15): BrowserPaneRegistry, .init(url:paneID:), .init(frame:), NSRect, NSWindow, PaneID, WeakBrowserPaneView, WeakScriptMessageHandler (+7 more)

### Community 181 - "GridCompositorTests"
Cohesion: 0.10
Nodes (13): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+5 more)

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.12
Nodes (15): DispatchWorkItem, CompletionPopupView, .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:), .isHovered (+7 more)

### Community 183 - "LSPServerRegistry"
Cohesion: 0.12
Nodes (24): .color, BoardCard, BoardColumn, .name, BoardColumnKind, .displayName, done, error (+16 more)

### Community 184 - "targets"
Cohesion: 0.21
Nodes (5): CopyModeReducerTests, FakeGrid, .totalLines, Set, String

### Community 185 - "SessionSnapshot"
Cohesion: 0.18
Nodes (3): SSHTunnelManagerTests, String, URL

### Community 186 - "Error"
Cohesion: 0.14
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 187 - "AppDelegate"
Cohesion: 0.12
Nodes (5): Bool, String, UInt8, .onResponse, .onSetClipboard

### Community 188 - "BrowserPaneView"
Cohesion: 0.16
Nodes (10): FileNode, Bool, String, FileTreeScanOptions, ScoredMatch, Bool, String, .scanOptions (+2 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.19
Nodes (11): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, .selectedHost (+3 more)

### Community 190 - "user-stories.md"
Cohesion: 0.09
Nodes (21): IssueKeychainStore, Bool, String, IssuePriority, .color, high, low, medium (+13 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.09
Nodes (18): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+10 more)

### Community 192 - "GlyphRasterizer"
Cohesion: 0.07
Nodes (28): Additional `kouen-cli` subcommands, Agent safety CLI (`kouen-cli`), Agents, context and scratchpad, Attaching from a plain terminal, Bindings, Board and attention, Buffers (paste store), Composition (+20 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.12
Nodes (12): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, input (+4 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.21
Nodes (4): CommandTarget, String, UUID, TargetSpecTests

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.11
Nodes (19): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+11 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.12
Nodes (10): .readJSONLLines(from:), AntigravitySessionLocator, Bool, Int32, NSRegularExpression, S, String, URL (+2 more)

### Community 198 - ".classify"
Cohesion: 0.11
Nodes (3): TimeInterval, String, WorktreeIsolationTests

### Community 199 - "code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)"
Cohesion: 0.11
Nodes (10): UnsafeBufferPointer, CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16, UInt8 (+2 more)

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.09
Nodes (18): FilterStatus, active, all, completed, CaseIterable, Mode, compatible, kouen (+10 more)

### Community 202 - "PaletteModel"
Cohesion: 0.17
Nodes (19): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), GlyphKey (+11 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.16
Nodes (14): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+6 more)

### Community 204 - "From tmux"
Cohesion: 0.17
Nodes (8): AgentDetection, AgentDetector, Date, Int32, TimeInterval, ProcessScan, Int32, AgentSnapshot

### Community 205 - "CopyModeState"
Cohesion: 0.09
Nodes (17): EndpointError, connectionFailed, .description, notYetSupported, pathTooLong, String, EndpointConnector, Int32 (+9 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.15
Nodes (18): CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf, .init(from:) (+10 more)

### Community 207 - "scheduleRender"
Cohesion: 0.20
Nodes (3): fQ, hqe(), M9()

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.15
Nodes (9): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, Set, SurfaceID, Tab (+1 more)

### Community 209 - "SettingsRemoteView"
Cohesion: 0.12
Nodes (10): String, SurfaceID, Tab, TabID, UUID, WorkspaceID, BrowserPaneReuseScopeTests, Tab (+2 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.12
Nodes (18): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+10 more)

### Community 211 - "PaneTarget"
Cohesion: 0.13
Nodes (13): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+5 more)

### Community 212 - ".translate"
Cohesion: 0.10
Nodes (14): item, historyJSONObject(), Any, String, CodexSessionLocator, CodexTranscriptLine, Any, Bool (+6 more)

### Community 213 - "String"
Cohesion: 0.13
Nodes (16): Notification.Name, ObserverToken, NSCoder, NSObjectProtocol, NSRect, NSTextView, URL, SyntaxDefinitionTarget (+8 more)

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.14
Nodes (15): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+7 more)

### Community 215 - ".lines"
Cohesion: 0.16
Nodes (11): ProjectGroupWatcher, StreamBox, Bool, DispatchSourceFileSystemObject, escaping, MainActor, Never, String (+3 more)

### Community 216 - "CellColorResolverTests"
Cohesion: 0.19
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 217 - "GridCompositor"
Cohesion: 0.14
Nodes (23): Colors, Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors (+15 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.18
Nodes (4): BoardCommandTests, BoardModelTests, Tab, String

### Community 219 - "Prompt"
Cohesion: 0.24
Nodes (9): CopyModeGridSource, .promptRows, CopyModeReducer, Bool, Character, NSRegularExpression, Range, String (+1 more)

### Community 220 - "Section"
Cohesion: 0.14
Nodes (7): KeybindingsStore, .fileURL, URL, KeybindingsStoreTests, URL, Void, String

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.15
Nodes (16): AgentMark, .body, AgentMarkShape, Scanner, .atEnd, SVGPath, Bool, CGFloat (+8 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.18
Nodes (11): .mcpButton, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter, Any, Range (+3 more)

### Community 224 - "CellColorResolver"
Cohesion: 0.18
Nodes (4): Divergence, Bool, String, WorktreeInfo

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.17
Nodes (13): .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didFinish:), .webView(_:didStartProvisionalNavigation:), BrowserTabButton, .init(title:isActive:onSelect:onClose:), LoadCompletionState, Bool (+5 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.15
Nodes (12): LSPDiagnostic, LSPDiagnosticSeverity, error, hint, information, warning, LSPHover, .plainText (+4 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.19
Nodes (9): BranchSwitchHelper, FileTreeNode, FileTreeSwiftUIView, .body, .pastedImagesSection, Notification.Name, Bool, NSMenuItem (+1 more)

### Community 228 - "sessionRow"
Cohesion: 0.17
Nodes (11): NotchGeometry, .fallback, NSScreen, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics (+3 more)

### Community 229 - ".decide"
Cohesion: 0.13
Nodes (16): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, .bytesPerWakeup, .mbps (+8 more)

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.18
Nodes (22): Encodable, AgyModelsPush, AISuggestionAck, AttachedAck, Body, BrowserFramePush, Cred, DetachedAck (+14 more)

### Community 231 - "ExternalOpenKind"
Cohesion: 0.10
Nodes (11): ExpressibleByStringLiteral, CwdAuthorizationError, foreignPathRejected, .message, missingSessionOrCwd, other, StringError, .init(_:) (+3 more)

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.12
Nodes (13): KouenCompositor, Configuration, Int32, SessionGroup, SessionID, Tab, TabID, WorkspaceID (+5 more)

### Community 233 - "TextGrid"
Cohesion: 0.14
Nodes (12): pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal, Int32 (+4 more)

### Community 234 - ".scan"
Cohesion: 0.21
Nodes (4): AgentTableEntry, Bool, Set, String

### Community 235 - "WorkbenchCommand"
Cohesion: 0.11
Nodes (16): CodingKeys, error, id, jsonrpc, method, JSONRPCId, int, string (+8 more)

### Community 236 - "Added"
Cohesion: 0.16
Nodes (3): CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.08
Nodes (6): CodepointRunFastPathTests, .assertAllPathsAgree(_:cols:rows:file:line:), StaticString, String, UInt, UInt8

### Community 238 - ".make"
Cohesion: 0.12
Nodes (9): NSDraggingInfo, NSDragOperation, PasteController, Bool, NSPasteboard, String, TimeInterval, URL (+1 more)

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.20
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 241 - "Added"
Cohesion: 0.22
Nodes (9): ContentLengthRejection, SSETransport, .isRunning, .listener, Bool, NWConnection, NWListener, Result (+1 more)

### Community 242 - "AgentBridge"
Cohesion: 0.18
Nodes (10): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+2 more)

### Community 243 - ".make"
Cohesion: 0.17
Nodes (9): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ProcessInfo (+1 more)

### Community 244 - "FileNode"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.09
Nodes (11): KeybindingsService, Bool, Command, OptionSet, .description, .init(from:), .init(key:modifiers:), Modifiers (+3 more)

### Community 246 - "Experience modes"
Cohesion: 0.11
Nodes (11): HookState, failed, idle, installed, installing, NotificationCenterProbe, .isKnownBad, Bool (+3 more)

### Community 247 - ".renderFixture"
Cohesion: 0.13
Nodes (15): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+7 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.11
Nodes (5): Float, Set, SurfaceID, Void, TerminalPaneRegistry

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.17
Nodes (7): .removeWorktreeAction(path:), GitResult, Bool, GitResult, String, ValidateOutcome, GitPanelViewToastErrorSummaryTests

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.16
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 251 - "SessionCoordinator"
Cohesion: 0.08
Nodes (24): Font, .kouenBadge, .kouenBody, .kouenBodyStrong, .kouenCaption2, .kouenCaption, .kouenKbd, .kouenMono (+16 more)

### Community 252 - "NSViewRepresentable"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 253 - "Split Right"
Cohesion: 0.13
Nodes (11): AgentHistoryJSONLSequence, .isValid, Iterator, Bool, Date, FileHandle, Iterator, URL (+3 more)

### Community 254 - "BoardViewController"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.25
Nodes (8): ignoreSIGPIPE(), Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 256 - "GitMetadataProvider"
Cohesion: 0.13
Nodes (17): FormatContextBuilder, DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:) (+9 more)

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.16
Nodes (6): ezt(), GGe, Gwe(), Hzt(), Kp(), urn

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 260 - ".welcome"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.17
Nodes (4): AgentHistoryMultiAgentCoverageTests, Bool, String, URL

### Community 262 - ".install"
Cohesion: 0.12
Nodes (6): PromptQueue, String, SurfaceID, Void, PromptQueueBar, NSWindow

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.14
Nodes (19): .modifierFlags, NSEvent, BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, CodingKeys (+11 more)

### Community 264 - "code:bash (harness-cli install-hooks claude-code)"
Cohesion: 0.17
Nodes (11): .body, MainActor, Void, Group, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, CGFloat (+3 more)

### Community 265 - "code:bash (harness-cli install-hooks cursor)"
Cohesion: 0.16
Nodes (5): ScanCallCounter, PortableRelativeDateFormatter, Date, String, UUID

### Community 266 - ".path"
Cohesion: 0.14
Nodes (6): TimeInterval, AgentHandoffBuilder, Bool, String, HandoffDirectoryTests, AgentHandoffBuilderTests

### Community 267 - ".performInstall"
Cohesion: 0.14
Nodes (13): SwarmFleetBody, .body, SwarmNodeRowView, .body, .statusColor, Duration, Void, SwarmFleetSnapshotWire (+5 more)

### Community 268 - "code:bash (# Old (agent-specific):)"
Cohesion: 0.15
Nodes (11): CryptoKit, DecodedWSFrame, Bool, ConnectionState, NWConnection, String, UInt8, WSFrameParseResult (+3 more)

### Community 269 - "DefaultTerminalManager"
Cohesion: 0.17
Nodes (21): Decodable, Item, ItemCompletedLine, LegacyMsgLine, Msg, String, ThreadStartedLine, AgentCommandRequest (+13 more)

### Community 270 - "WindowSession"
Cohesion: 0.16
Nodes (8): OutputTrigger, OutputTriggerStore, Bool, String, OutputTriggerMatcher, .matches(in:patterns:), String, OutputTriggerMatcherTests

### Community 271 - "StatusLineView.swift"
Cohesion: 0.20
Nodes (14): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, SessionGroup, SessionID (+6 more)

### Community 272 - "SGRMouseEvent"
Cohesion: 0.16
Nodes (12): DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String, UInt8 (+4 more)

### Community 273 - "KeySpec"
Cohesion: 0.09
Nodes (19): ExperienceMode, agent, .displayName, .foregroundsAgents, full, .notchEnabledByDefault, persistent, .persistsSessionsByDefault (+11 more)

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.13
Nodes (6): azt(), F7, ibe(), mathmlBuilder(), q$e(), UHt()

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.17
Nodes (10): .block(atPromptLine:), .captureLines(fromLine:toLine:), .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8 (+2 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.25
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 277 - ".run"
Cohesion: 0.18
Nodes (10): StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength, newline, StdioTransport, AsyncStream, TransportError (+2 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.19
Nodes (10): RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal, FileHandle, Int32 (+2 more)

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.12
Nodes (9): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, KouenApp, FileChangeWatcherTests (+1 more)

### Community 280 - ".menu"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.18
Nodes (20): CoreImage, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription, .surfaceID, detectHost() (+12 more)

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.14
Nodes (11): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+3 more)

### Community 283 - "FormatColor"
Cohesion: 0.13
Nodes (18): statusColor(), Array, Bool, Date, PaneID, String, TabID, Tab (+10 more)

### Community 284 - "click_ui_element"
Cohesion: 0.17
Nodes (8): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, String, PaneStyleTests

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.16
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 287 - ".apply"
Cohesion: 0.16
Nodes (17): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+9 more)

### Community 288 - "AgentHookStrategy"
Cohesion: 0.23
Nodes (5): WorktreeManager, String, URL, UUID, WorktreeIsolationDaemonTests

### Community 289 - "StatusLineWidthTests"
Cohesion: 0.14
Nodes (3): AgentLaunchCommandsTests, URL, Void

### Community 290 - "Process"
Cohesion: 0.20
Nodes (6): Case, ReflowCorpusTests, .corpus, .goldenDir, String, URL

### Community 291 - "JSONDecoder"
Cohesion: 0.13
Nodes (11): KouenTerminalSurfaceFocusTests, OcclusionTests, NSWindow, String, TimeInterval, SpecialKeyMappingTests, Bool, NSEvent (+3 more)

### Community 292 - "Release runbook"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Kouen, Sparkle (+13 more)

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 295 - "AgentApprovalBar"
Cohesion: 0.10
Nodes (20): Agent Memory, AI-SDLC — Dev/QA Workflow Spine, AODD: the operating contract, AODD triage: every request passes this gate (silently, no announcement), Approval Gates (mandatory on the Requirement path), Audit and Done, Cheap-model delegation, Core facts (non-negotiable, not model-inferable — everything else is judgment) (+12 more)

### Community 296 - "NotificationBus"
Cohesion: 0.17
Nodes (7): AIProviderAwakeService, .closedLidOptedIn, Bool, NSObjectProtocol, Set, String, AIProviderAwakeServiceTests

### Community 297 - "settings.json"
Cohesion: 0.17
Nodes (5): .snapshot, Bool, String, ThemeService, KouenOptions

### Community 298 - "jobs"
Cohesion: 0.18
Nodes (11): Never, NSRegularExpression, Set, String, Task, URL, Void, WorkspaceSymbolIndex (+3 more)

### Community 299 - "PaneNode"
Cohesion: 0.16
Nodes (8): CustomEndpointTester, Result, Bool, String, URL, CustomEndpointTesterTests, URLRequest, URLSession

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.14
Nodes (13): KeyRecorderRepresentable, SettingsKeysView, .body, String, Void, OverlayBackground, Context, OverlayBackground (+5 more)

### Community 301 - ".parse"
Cohesion: 0.13
Nodes (10): SelectAllOnClickTextField, NSEvent, BrowserFileReloadTests, CountingWebView, Nav, NSEvent, String, Void (+2 more)

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.21
Nodes (4): ContentAreaViewController, Bool, String, Notification

### Community 303 - ".encodeMouse"
Cohesion: 0.14
Nodes (10): .effectiveResumeCommand(mode:), AgentLaunchCommands, AgentSessionMode, cloud, .launchCommand, .launchFlags, local, remoteControl (+2 more)

### Community 304 - "00-inception-plan.md"
Cohesion: 0.20
Nodes (6): Keyboard Shortcuts, AI Browser Control (kouen-mcp), HTTP/SSE authentication, Install, Shell integration (OSC 133 semantic prompts), What gets emitted

### Community 305 - ".script"
Cohesion: 0.16
Nodes (9): AgentListFormatter, Date, String, dvn(), ht(), AgentListFormatterTests, Bool, Date (+1 more)

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.13
Nodes (10): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, String (+2 more)

### Community 307 - "ViPathTokenTests"
Cohesion: 0.17
Nodes (16): SessionRef, byID, byName, next, previous, String, UUID, TargetSpec (+8 more)

### Community 308 - "Send Ex Command"
Cohesion: 0.10
Nodes (17): AgentUsage, .contextTokens, .init(from:), .init(inputTokens:outputTokens:cacheReadTokens:cacheWriteTokens:thinkingTokens:totalCostUSD:), .shortSummary, CodingKeys, cacheReadTokens, cacheWriteTokens (+9 more)

### Community 309 - "Browser DevTools API (P28)"
Cohesion: 0.28
Nodes (3): KouenSettingsTests, URL, Void

### Community 310 - "FrameSignposter"
Cohesion: 0.20
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.13
Nodes (9): AgyMobileCommands, String, ClaudeMobileCommands, Set, String, slashCommandChunks(), String, MobileBridgeAgentCommandTests (+1 more)

### Community 312 - "AgentSnapshot"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.15
Nodes (6): LSPTextLocation, .position, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 314 - "code:bash (harness-cli install-hooks codex)"
Cohesion: 0.13
Nodes (14): BinaryInstaller.DetectionStatus, SetupStepView, .body, .canInstall, .hooksDetail, .hooksTone, .hooksValue, .isSuccess (+6 more)

### Community 315 - "code:bash (harness-cli install-hooks grok)"
Cohesion: 0.18
Nodes (6): DefaultTerminalLaunchRequest, ShellQuoting, Bool, String, URL, DefaultTerminalLaunchRequestTests

### Community 316 - "code:bash (harness-cli install-hooks opencode)"
Cohesion: 0.15
Nodes (9): _7(), A7(), a8(), bGt(), c8(), ene(), Gnn, IC() (+1 more)

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.11
Nodes (11): URL, String, String, KouenFilePreviewLoader, KouenViewError, binaryOrUnsupportedEncoding, missingPath, tooLarge (+3 more)

### Community 319 - "FormatColor"
Cohesion: 0.13
Nodes (10): Bool, CGFloat, NSCoder, NSLayoutConstraint, NSPoint, NSRect, WindowTitleStripView, .init(coder:) (+2 more)

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.11
Nodes (8): DispatchSource, DispatchQueue, DispatchSourceFileSystemObject, Int32, URL, Void, TranscriptFileWatcher, MobileBridgeTranscriptWatcherTests

### Community 321 - "UInt64"
Cohesion: 0.20
Nodes (7): HTTPURLResponse, SSETransportTests, Never, String, Task, UInt16, Void

### Community 322 - "DesktopNotifier"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 323 - "LayoutNode"
Cohesion: 0.14
Nodes (6): String, .trimmed, AgentTitleInference, Bool, .effectiveAgentKind, AgentDetectorTests

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 325 - "FloatingPaneController"
Cohesion: 0.17
Nodes (3): ShellIntegrationTests, .repoRoot, URL

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.33
Nodes (3): TaskStore, URL, TaskStoreTests

### Community 327 - ".theme"
Cohesion: 0.32
Nodes (3): BinaryInstallerVersionTests, String, URL

### Community 328 - "README.md"
Cohesion: 0.13
Nodes (16): OnboardingStep, complete, discover, .id, setup, shell, .title, welcome (+8 more)

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.16
Nodes (8): brn, grn, hrn(), JGe(), KGe(), prn(), qGe(), zGe()

### Community 330 - ".drawGlyph"
Cohesion: 0.18
Nodes (6): Range, String, TerminalBufferMatch, TerminalBufferSearch, String, TerminalBufferSearchTests

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.11
Nodes (3): Bool, String, UUID

### Community 332 - "Added"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 333 - "RealPty"
Cohesion: 0.12
Nodes (10): PluginLoader, String, ScriptAPI, ScriptError, .errorDescription, evaluationError, unsupportedPlatform, String (+2 more)

### Community 335 - ".makeModel"
Cohesion: 0.13
Nodes (12): SettingsAppearanceView, .autoTheme, .body, .themeSection, SliderRow, .body, .displayValue, Bool (+4 more)

### Community 336 - "run.sh"
Cohesion: 0.13
Nodes (15): .agentInfo(forWorktreePath:), Reason, errored, finished, needsInput, RowState, Bool, Comparable (+7 more)

### Community 337 - "CommandExecutionError"
Cohesion: 0.18
Nodes (5): TabID, WorkspaceID, AgentCommandTests, String, Tab

### Community 338 - "CSIParams"
Cohesion: 0.16
Nodes (17): FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView, .body (+9 more)

### Community 339 - "Foundation"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.13
Nodes (7): Foundation, AntigravityTranscriptLine, GraphifyIndexCache, Set, String, params, SQLite3

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.11
Nodes (18): fix ที่ค้างอยู่ใน working tree (ยังไม่ commit), Terminal grid ไม่ใช่ก้อนใหญ่ที่ระบุชนิดได้, ก้อนหลักเกี่ยวข้องกับ RenderBox, การให้ DeepSeek ตรวจเพิ่ม, ผลตรวจ preview ที่แยกจากแอปหลัก, ผลตรวจแอปหลัก, ภาคผนวก 1 — fleet 9 ต.ค. (P54) กระทบ UI ไหม → กระทบ ตรงจุด, ภาคผนวก 2 — 18 ต.ค. `8c5e0c8d` P59 (agy session, **unreviewed**) (+10 more)

### Community 342 - "Added"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 344 - "FileViewerViewController"
Cohesion: 0.26
Nodes (4): ContextResolutionEngine, Bool, String, String

### Community 345 - "README.md"
Cohesion: 0.23
Nodes (6): EnvironmentStore, Persisted, String, URL, EnvironmentStoreTests, URL

### Community 346 - "Agent platform icons"
Cohesion: 0.19
Nodes (5): SessionID, GroupedSessionTests, SessionGroup, Set, SurfaceID

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.16
Nodes (16): SwarmFleetSnapshot, SwarmLane, pty, structured, SwarmTaskNode, SwarmTaskStatus, cancelled, failed (+8 more)

### Community 348 - "DaemonLifecycleTests"
Cohesion: 0.16
Nodes (13): BoxDrawing, Kind, arms, dashH, dashV, halfDown, halfLeft, halfRight (+5 more)

### Community 349 - "Contents.json"
Cohesion: 0.16
Nodes (4): KouenThemeCatalog, .allThemes, String, KouenThemeCatalogTests

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.16
Nodes (7): CwdMetadataProvider, GitMetadataProvider, MetadataProvider, Bool, String, Tab, GitMetadataProviderTests

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.22
Nodes (5): .body, Bool, Bool, String, URL

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.15
Nodes (6): .agentInfo(forWorktreePath:tabs:), Tab, TabID, WorkspaceID, GitPanelViewWorktreeAgentTests, GitPanelViewWorktreeNavigationTests

### Community 355 - ".deepMerge"
Cohesion: 0.18
Nodes (9): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+1 more)

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.19
Nodes (9): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+1 more)

### Community 357 - ".handleCat"
Cohesion: 0.19
Nodes (13): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Bool, Duration (+5 more)

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.19
Nodes (5): KeyTokenParser, Bool, String, .remaining, KeyTokenParserTests

### Community 359 - "OcclusionTests"
Cohesion: 0.16
Nodes (7): SGRMouse, SGRMouseEvent, Bool, UInt8, SGRMouseTests, String, UInt8

### Community 360 - "State"
Cohesion: 0.18
Nodes (13): FeaturePhase, architect, completed, dev, interview, qaDesign, qaVerify, .title (+5 more)

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.16
Nodes (9): FileGraphInfo, GraphifyLSPBridge, Double, String, URL, GraphifyLSPBridgeTests, Any, String (+1 more)

### Community 362 - "RGBColor"
Cohesion: 0.11
Nodes (18): bvt(), CWt(), dUe(), hyn(), j4n(), l7e(), ly(), m2t() (+10 more)

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.22
Nodes (6): ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 366 - "Consumers"
Cohesion: 0.14
Nodes (5): HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 367 - "DaemonStats"
Cohesion: 0.16
Nodes (5): KouenMCPServer, String, MCPServer, String, UInt16

### Community 368 - "Tab"
Cohesion: 0.15
Nodes (11): AnimatablePair, NotchMaskAnimator, Bool, CGFloat, CGRect, NotchShape, .animatableData, CGFloat (+3 more)

### Community 369 - "Git Panel"
Cohesion: 0.26
Nodes (8): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection, agents, AgentKind

### Community 370 - ".encode"
Cohesion: 0.17
Nodes (9): GitStatusProvider, OnceResume, Bool, Duration, String, TimeInterval, GitStatusProviderLargeOutputTests, URL (+1 more)

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.21
Nodes (4): Bool, String, SurfaceID, TimeInterval

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.12
Nodes (6): ScreenPos, bottom, middle, top, KouenLSP, QuickLookUI

### Community 373 - "Prompt"
Cohesion: 0.15
Nodes (8): Bool, CGFloat, NSCoder, Void, TabNavigation, TabNavigationButtons, .init(coder:), NSStackView

### Community 374 - ".run"
Cohesion: 0.21
Nodes (13): CellMetrics, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth, Bool (+5 more)

### Community 375 - ".install"
Cohesion: 0.21
Nodes (3): Darwin, Glibc, AgentRoutingResolver

### Community 376 - "ScrollReuseTests"
Cohesion: 0.12
Nodes (5): KouenCLI, HistorySearchQueryTests, MemoCommandTests, URL, TaskCommandTests

### Community 377 - "Identifiable"
Cohesion: 0.15
Nodes (9): JSONLReadError, oversizedRecord, Void, AgentHistoryTranscriptSpool, FileHandle, String, URL, Void (+1 more)

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 379 - "MCPServer"
Cohesion: 0.20
Nodes (4): CompletionGenerator, String, .fishCompletionSource, CompletionGeneratorTests

### Community 380 - "PromptQueue"
Cohesion: 0.19
Nodes (8): AgentRemoteControlDaemonService, Set, String, Void, AgentRemoteControlDaemonServiceTests, LogBox, .count, String

### Community 381 - "smoke-dmg.sh"
Cohesion: 0.18
Nodes (10): AssistantLine, ClaudeAdapter, Content, Message, ResultLine, Bool, Double, String (+2 more)

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.18
Nodes (8): ClaudeRunSummary, Date, Double, Int32, String, UUID, String, UUID

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.29
Nodes (4): SwarmDAGStore, String, UUID, SwarmDAGStoreTests

### Community 385 - "INDEX.md"
Cohesion: 0.15
Nodes (10): OutputCoalescer, .bufferedMemoryBytes, .bufferedSpoolBytes, .retainedChunkSlots, OutputDiskSpool, .isDrained, .remainingBytes, FileHandle (+2 more)

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.26
Nodes (3): String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 387 - "User Profile"
Cohesion: 0.27
Nodes (4): ArchitectureGuardTests, .repoRoot, String, URL

### Community 388 - "Darwin"
Cohesion: 0.20
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.18
Nodes (8): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController

### Community 392 - "build-release.sh"
Cohesion: 0.19
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 393 - "create-dmg.sh"
Cohesion: 0.17
Nodes (8): NSHostingView, NSLayoutConstraint, TerminalTabBarView, .delegate, .init(frame:), .leadingInset, .mouseDownCanMoveWindow, .trailingInset

### Community 394 - "finalize-release.sh"
Cohesion: 0.17
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 395 - "generate-app-icon.sh"
Cohesion: 0.19
Nodes (10): .onSelect, NotificationDropdownPanelView, .acceptsFirstResponder, .cornerConfiguration, .init(entries:onSelect:onClearAll:onDismiss:), Bool, CGFloat, NSScrollView (+2 more)

### Community 396 - "generate-appcast.sh"
Cohesion: 0.30
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 397 - "measure-fluidity.sh"
Cohesion: 0.12
Nodes (15): agy, claude, codex, copilot, hermes, kouen, __kouen_agy_next, __kouen_claude_next (+7 more)

### Community 398 - "preview.sh"
Cohesion: 0.15
Nodes (12): OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Bool, Value, bool (+4 more)

### Community 399 - "sign-and-notarize.sh"
Cohesion: 0.19
Nodes (10): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+2 more)

### Community 400 - "install-linux.sh"
Cohesion: 0.21
Nodes (3): .hasAdapter(for:), Bool, ClaudeCodeHarnessTests

### Community 401 - "package-app.sh"
Cohesion: 0.12
Nodes (16): BrowserRequestPayload, close, cookies, evaluate, goBack, goForward, interact, navigate (+8 more)

### Community 402 - "View"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 403 - "PresentAttempt"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 405 - "AgentIconRenderer"
Cohesion: 0.21
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 406 - "main.swift"
Cohesion: 0.17
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

### Community 407 - "Fixed"
Cohesion: 0.21
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 408 - "IPC Architecture"
Cohesion: 0.23
Nodes (8): LayoutFileStore, LayoutNode, branch, leaf, LayoutTemplate, Date, Double, String

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.20
Nodes (8): DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSViewCornerConfiguration, SurfaceID, Void

### Community 410 - ".applyTerminalIdentity"
Cohesion: 0.15
Nodes (11): .init(coder:), BrowserProgressLine, .init(coder:), .init(coder:), DesignModePopoverViewController, .init(coder:), .init(title:properties:styles:onStyleChanged:onCopyCSS:onPromptAgent:), NSCoder (+3 more)

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.16
Nodes (8): ObjectiveC, CGFloat, NSControl, StaticString, String, UInt, TabNavigationButtonsTests, WebKit

### Community 412 - "go.json"
Cohesion: 0.23
Nodes (8): LSPFileSession, Never, String, Task, URL, Void, object, Bool

### Community 413 - "javascript.json"
Cohesion: 0.19
Nodes (6): KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, OnboardingEnvironmentTests

### Community 414 - "json.json"
Cohesion: 0.23
Nodes (13): kouen.bash script, agy(), claude(), codex(), copilot(), hermes(), kouen(), __kouen_agy_next() (+5 more)

### Community 415 - "markdown.json"
Cohesion: 0.22
Nodes (6): ListeningPortScanner, Int32, Set, String, result, ListeningPortScannerTests

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.21
Nodes (8): Bool, Int32, String, URL, SystemdUserInstaller, .backendName, .isInstalled, .unitURL

### Community 417 - "rust.json"
Cohesion: 0.23
Nodes (7): InstallResult, Shell, bash, fish, zsh, Bool, URL

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.22
Nodes (5): RepoResolver, Bool, String, RepoResolverTests, String

### Community 419 - "typescript.json"
Cohesion: 0.15
Nodes (11): PairingBox, .current, .isLockedOut, PendingPairing, Date, TimeInterval, TokenCheck, accepted (+3 more)

### Community 420 - "yaml.json"
Cohesion: 0.13
Nodes (11): Am(), bze(), Cm(), EQ(), Hm(), Im(), lte(), MBe() (+3 more)

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
Cohesion: 0.24
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.19
Nodes (9): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 427 - ".delay"
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 428 - "TaskDashboardView"
Cohesion: 0.15
Nodes (10): DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary, Bool (+2 more)

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.18
Nodes (9): NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView, .cornerConfiguration (+1 more)

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.18
Nodes (7): StaleTemporaryFileSweeper, Bool, Date, String, URL, Void, AppLaunchTempCleanupTests

### Community 431 - "BoardCardView"
Cohesion: 0.33
Nodes (6): SurfaceProgressTracker, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void

### Community 432 - "PathToken"
Cohesion: 0.31
Nodes (6): Bool, Counter, Scheduled, SurfaceProgressTrackerTests, DispatchWorkItem, TimeInterval

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.21
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 434 - "Project History"
Cohesion: 0.21
Nodes (8): .init(coder:), NotificationRowView, .init(coder:), .isHighlighted, .isHovered, NSCoder, NSEvent, NSTrackingArea

### Community 435 - ".init"
Cohesion: 0.21
Nodes (9): CGFloat, CGFloat, NSCoder, Void, WorkspaceID, WorkspaceSwitcherPanelView, .init(coder:), .init(workspaces:activeWorkspaceID:onSelect:onNew:onDelete:) (+1 more)

### Community 436 - "WaitForRegistry"
Cohesion: 0.24
Nodes (8): ProjectDropTarget, .init(coder:), .init(frame:), NSCoder, NSDraggingInfo, NSDragOperation, NSRect, URL

### Community 437 - "PickerItemRow"
Cohesion: 0.20
Nodes (11): DotView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor, NSRect (+3 more)

### Community 438 - "SessionEditor"
Cohesion: 0.34
Nodes (8): CGFloat, Range, Tab, TabBarLayoutMetrics, .pitch, TerminalTabBarBody, .body, TerminalTabBarModel

### Community 439 - "SetupStepView"
Cohesion: 0.14
Nodes (14): Agent handbook — Kouen (extended reference), Agent integration, Build and test, IPC, Keyboard shortcuts, kouen-cli, Native terminal renderer, Repository map (+6 more)

### Community 440 - "LegacySnapshot"
Cohesion: 0.18
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 441 - "RemoteHostStore"
Cohesion: 0.41
Nodes (7): FeatureSummary, FeatureTaskSummary, GateSummary, Bool, Date, String, UUID

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.19
Nodes (4): URL, MobileBridgeAttachFileTests, String, URL

### Community 445 - "Section"
Cohesion: 0.23
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 446 - "Modifiers"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 447 - "PaletteMode"
Cohesion: 0.20
Nodes (6): bUt(), FBe(), Gbe(), handler(), mUt(), _Q()

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.24
Nodes (9): Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock, .block(id:) (+1 more)

### Community 449 - "PresentAttempt"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 451 - ".run"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.15
Nodes (11): copyMode, esc(), fs, globalShortcuts, KEYBINDINGS, prefixTable, renderTable(), ROOT (+3 more)

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.18
Nodes (9): BrowserTabRepaintTests, RepaintCountingWebView, Any, Error, MainActor, Sendable, String, TimeInterval (+1 more)

### Community 456 - "TerminalModes"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 457 - ".normalizedKey"
Cohesion: 0.37
Nodes (3): AgentBrowserPaneTracker, Set, AgentBrowserPaneTrackerTests

### Community 458 - "PaneOutputWaiter"
Cohesion: 0.22
Nodes (11): MarkdownImageSchemeHandler, .webView(_:start:), .webView(_:stop:), Never, ObjectIdentifier, Task, URL, Void (+3 more)

### Community 459 - ".encode"
Cohesion: 0.22
Nodes (8): Container, .init(coder:), .init(frame:), NotchPulseHost, Context, NSCoder, NSHostingView, NSRect

### Community 460 - "RunState"
Cohesion: 0.24
Nodes (6): Bool, NSEvent, NSTrackingArea, WorkspaceSwitcherRow, .init(title:count:isActive:symbol:canDelete:), .isHovered

### Community 461 - ".worktreeList"
Cohesion: 0.23
Nodes (9): AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor (+1 more)

### Community 462 - "AGENTS.md"
Cohesion: 0.15
Nodes (13): CodingKey, CodingKeys, createdAt, cwd, done, id, sessionID, status (+5 more)

### Community 463 - ".deinit"
Cohesion: 0.21
Nodes (4): JSONDecoder, JSONEncoder, String, TerminalRecordingCodec

### Community 464 - "MouseButton"
Cohesion: 0.24
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 465 - "DirectionalAxis"
Cohesion: 0.24
Nodes (3): ShortcutRecorderSerializer, String, ShortcutRecorderSerializerTests

### Community 466 - "PlatformSys.swift"
Cohesion: 0.42
Nodes (6): InstallResult, ShellCompletionInstaller, Bool, String, URL, ShellIntegration

### Community 467 - ".moveSelection"
Cohesion: 0.21
Nodes (5): FDWatchdog, DispatchSourceTimer, String, TimeInterval, FDWatchdogTests

### Community 468 - "Never"
Cohesion: 0.18
Nodes (5): FormatContextDaemonTests, PaneID, String, SurfaceID, URL

### Community 469 - "PresentAttempt"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 470 - "DispatchTime"
Cohesion: 0.18
Nodes (13): dU(), e9n(), fae(), GDt(), iat(), nwn(), Pin(), Rm() (+5 more)

### Community 471 - ".evaluateStyled"
Cohesion: 0.18
Nodes (6): eKe(), irn(), mrn, _rn(), rrn(), srn()

### Community 472 - "start.sh script"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 473 - "HarnessOnboarding"
Cohesion: 0.33
Nodes (5): SearchBenchmarks, String, UInt64, URL, Void

### Community 474 - "String"
Cohesion: 0.23
Nodes (5): String, TextGrid, .totalLines, .viewportRows, WordColumnRangeTests

### Community 475 - ".hitTest"
Cohesion: 0.22
Nodes (6): DaemonAsyncReplyRoutingTests, Int32, String, TimeInterval, UInt8, URL

### Community 476 - "StatusDotView"
Cohesion: 0.26
Nodes (4): PaneLabelDaemonTests, String, URL, UUID

### Community 478 - ".install"
Cohesion: 0.15
Nodes (3): AgentHookInstallerCLI, String, String

### Community 479 - "ScrollbackTests"
Cohesion: 0.29
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 480 - ".isRisky"
Cohesion: 0.33
Nodes (4): SecureInputPromptScanner, Bool, SecureInputPromptScannerTests, String

### Community 481 - "SecureInputMonitor"
Cohesion: 0.20
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

### Community 482 - ".resolve"
Cohesion: 0.21
Nodes (6): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID

### Community 483 - "Changed"
Cohesion: 0.17
Nodes (5): DirectionalAxis, down, left, right, up

### Community 484 - "CopilotAdapter"
Cohesion: 0.27
Nodes (4): HintModeOverlay, Any, NSEvent, String

### Community 485 - ".testKouenRendererFixtureLigatureShapingPathReportsPlausibleGlyphs"
Cohesion: 0.30
Nodes (7): Bool, NSPasteboard, NSString, String, URL, TerminalServicesProvider, AutoreleasingUnsafeMutablePointer

### Community 486 - "TabPillView"
Cohesion: 0.29
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 487 - "bC"
Cohesion: 0.23
Nodes (4): ConsoleLineCapTests, NetworkCaptureDecisionTests, Bool, String

### Community 488 - "R1"
Cohesion: 0.23
Nodes (7): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow, NSHostingController

### Community 489 - "SurfaceIO"
Cohesion: 0.20
Nodes (9): BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool, CGFloat, NSCoder, NSPoint (+1 more)

### Community 490 - "ccRunGet"
Cohesion: 0.17
Nodes (12): Architecture Decisions (dated log), Commit preparation, Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Markdown preview trust boundary, Post-P50 changes (v4.20.2 → v4.20.11, 2026-10-01 → 2026-10-06) (+4 more)

### Community 491 - ".update"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.17
Nodes (11): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile, regionEdit (+3 more)

### Community 493 - "ccRunStart"
Cohesion: 0.27
Nodes (4): Bool, String, TokenGuard, ContextResolutionEngineTests

### Community 494 - "ccRunInfo"
Cohesion: 0.41
Nodes (4): KouenFeatureMarkdownSync, Bool, String, URL

### Community 495 - ".open"
Cohesion: 0.26
Nodes (9): AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand, Bool, Set (+1 more)

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.39
Nodes (3): data, SixelDecoder, UInt8

### Community 497 - ".bind"
Cohesion: 0.27
Nodes (6): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor

### Community 499 - "GlassEffectView"
Cohesion: 0.18
Nodes (12): Bpe(), cFe(), displayable(), Fpe(), jpe(), KBe(), oFe(), rgb() (+4 more)

### Community 500 - "zO"
Cohesion: 0.32
Nodes (3): ReflowPreviewTests, .feeds, String

### Community 501 - "Fixed"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 502 - "Kouen Terminal — System Architecture"
Cohesion: 0.17
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 503 - "Kouen Features"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 504 - "String"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 505 - ".tickFeatureWorktreeSweepLocked"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 506 - ".parseGitDiffOutput"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.20
Nodes (9): AnyObject, CommandExecutionError, daemonError, .description, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor (+1 more)

### Community 508 - "qLt"
Cohesion: 0.24
Nodes (5): RiskyCommandClassifier, Bool, NSRegularExpression, String, RiskyCommandClassifierTests

### Community 509 - "start.mjs"
Cohesion: 0.18
Nodes (3): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess

### Community 511 - ".panePathLookup"
Cohesion: 0.18
Nodes (11): Typography, .badge, .kbd, .paletteHeader, .paletteTitle, .rowMeta, .rowTitle, .sectionLabel (+3 more)

### Community 512 - ".setAttribute"
Cohesion: 0.20
Nodes (8): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, ClosedRange, String

### Community 513 - "ThemeDocument"
Cohesion: 0.27
Nodes (7): AgyModelCatalog, Catalog, Date, String, TimeInterval, ConnectionState, NWConnection

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.18
Nodes (9): CodingKeys, error, id, jsonrpc, method, params, result, Decoder (+1 more)

### Community 515 - "RD"
Cohesion: 0.27
Nodes (7): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8

### Community 516 - "terminal_stress_runner.py"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 517 - "KouenCLI+Workbench.swift"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 518 - "Bool"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 521 - ".daemonIsStale"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 522 - ".viewDidLoad"
Cohesion: 0.40
Nodes (5): PaneOutputWaiter, PaneOutputWaitResult, CheckedContinuation, Never, UInt64

### Community 523 - "fFe"
Cohesion: 0.42
Nodes (4): DefaultTerminalManager, String, URL, UTType

### Community 525 - ".encodeAndWait"
Cohesion: 0.36
Nodes (6): HistorySearchEvidence, .body, .terms, Bool, String, Text

### Community 526 - "Kind"
Cohesion: 0.20
Nodes (10): Agent Safety Net (Checkpoints, Verification, Write Guards), Claude Code Harness, Editor & LSP, How It Feels, Kouen Features, Mobile, Remote And Headless, Stack (+2 more)

### Community 527 - ".show"
Cohesion: 0.24
Nodes (3): KouenMCP, KouenBrowserToolsTests, URL

### Community 528 - "worktree_review_dashboard.robot"
Cohesion: 0.20
Nodes (5): Network, HTTPRequestPolicy, Bool, String, UInt16

### Community 529 - "WorktreeAutoIsolateService"
Cohesion: 0.20
Nodes (10): PaneRef, bottom, byID, byIndex, last, left, next, previous (+2 more)

### Community 530 - "HarnessChrome"
Cohesion: 0.22
Nodes (9): MatchSource, ownProcess, wrapperLaunch, RawMatch, WrapperOptionBehavior, keepScanning, matchValue, skipValue (+1 more)

### Community 531 - "BrowserProgressLine"
Cohesion: 0.20
Nodes (7): Kind, input, metadata, output, resize, ReplayStep, Decoder

### Community 532 - "OpenClaw → Kouen"
Cohesion: 0.20
Nodes (9): CodingKeys, cols, createdAt, dataBase64, rows, timeMs, type, version (+1 more)

### Community 533 - "Pi → Kouen"
Cohesion: 0.20
Nodes (9): RecordingEvent, input, metadata, output, resize, .timeMs, Date, Encoder (+1 more)

### Community 534 - "p12_mcp.robot"
Cohesion: 0.20
Nodes (6): LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled

### Community 535 - "AgentNotification"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 536 - ".readGrid(scrollbackOffset:)"
Cohesion: 0.31
Nodes (5): AgyAdapter, Result, ResultLine, String, UUID

### Community 537 - "NSObject"
Cohesion: 0.20
Nodes (7): HeadlessRunEvent, assistantText, result, sessionID, Bool, Double, String

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.22
Nodes (3): MobileBridgeSpawnTests, String, URL

### Community 539 - "SavedLayoutIPCDaemonTests"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 540 - ".delay"
Cohesion: 0.20
Nodes (7): BBe(), NBe(), PBe(), qLt(), sIt(), VBe(), zLt()

### Community 541 - ".init"
Cohesion: 0.27
Nodes (3): DaemonReconnectPolicy, TimeInterval, DaemonReconnectPolicyTests

### Community 542 - ".init(from:)"
Cohesion: 0.24
Nodes (3): ClaudeSessionModeTests, URL, Void

### Community 543 - ".bufferLine"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 544 - "CodingKeys"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 545 - ".characterIndex"
Cohesion: 0.22
Nodes (3): ClaudeCodeHarnessIPCTests, String, URL

### Community 546 - "LegacySnapshot"
Cohesion: 0.24
Nodes (4): GroupedSessionDaemonTests, SessionGroup, String, URL

### Community 547 - "NSObject"
Cohesion: 0.24
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 548 - ".encode"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 549 - ".init(from:)"
Cohesion: 0.25
Nodes (3): JobResultSheetView, .body, String

### Community 550 - ".init(hex:)"
Cohesion: 0.25
Nodes (8): Bool, String, TriState, auto, .boolValue, .label, off, on

### Community 551 - ".init(red:green:blue:alpha:)"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 553 - "harness.resource"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Key spec syntax, Kouen keybindings, Persistence (+1 more)

### Community 554 - "eFe"
Cohesion: 0.25
Nodes (4): ControlKeyNormalizer, Bool, String, ControlKeyNormalizerTests

### Community 555 - "code:bash (harness view <file>                        # syntax-highligh)"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 556 - "MobileBridgeSpawnTests"
Cohesion: 0.33
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

### Community 557 - ".viewWillMove"
Cohesion: 0.22
Nodes (7): KouenCLIPaths, .applicationSupport, .binDirectory, .installedCLIPath, .installedDaemonPath, .launchAgentURL, URL

### Community 558 - "FindWindowMatcherTests"
Cohesion: 0.22
Nodes (9): B3(), dFe(), _Dt(), fFe(), lFe(), _Ot(), sD(), TOt() (+1 more)

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.22
Nodes (9): BDt(), eFe(), kFe(), pC(), tDt(), Vpe(), WY(), xDt() (+1 more)

### Community 560 - "AgentNotification"
Cohesion: 0.31
Nodes (3): crn, ELt(), n2e()

### Community 562 - "BrowserResponsePayload"
Cohesion: 0.22
Nodes (8): Build order (unchanged from interview decision), G1 — @ file-path picker, G2 — shell tab-completion suggestion strip (heuristic, explicitly best-effort), G3 — AI command suggestion (via `claude` CLI subprocess), Logical Design, P37 Phase G — Autocomplete (mobile bridge), Strategic Design, Tactical Design

### Community 563 - "AgentNotchViewModel.swift"
Cohesion: 0.22
Nodes (8): Artifacts, Client Application — Slice 1 (stacked panes, no persistence), Client Application — Slice 2 (per-workspace divider memory), Context, Dev Task Progress — Workspace Sidebar Panels (P42), Integration, Note on task re-sequencing (2026-07-17), Summary

### Community 564 - "📁 IDE Sidebar"
Cohesion: 0.22
Nodes (9): Contributors, Documentation, Install, Key features, Kouen, License, Requirements, Update (+1 more)

### Community 565 - "WriteOrigin"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.25
Nodes (6): String, URL, ThemeCatalogEmbedTests, .embedSwift, .repoRoot, .sourceJSON

### Community 568 - ".installChromeBackground"
Cohesion: 0.22
Nodes (7): block, escFn, lineFilter, md, page, script, swift

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.39
Nodes (4): SessionGroup, Any, String, Tab

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 572 - "LayoutProbeView"
Cohesion: 0.25
Nodes (4): Bool, NSEvent, NSEvent, NSEvent

### Community 573 - "tHe"
Cohesion: 0.32
Nodes (4): SwarmFleetView, .init(coder:), CGFloat, NSCoder

### Community 574 - "FileTreeKeyboardNavigator"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 575 - ".toastErrorSummary"
Cohesion: 0.25
Nodes (8): A `claude` typed by hand, Claude Code → Kouen, Customizing, One-line install, Session mode: Remote Control / cloud / local, The reverse direction: a session opened in Claude showing up in Kouen, Verifying, What gets written

### Community 576 - "Phase67Tests"
Cohesion: 0.32
Nodes (4): PaneID, SessionGroup, Tab, first

### Community 578 - "TaskDashboardBody"
Cohesion: 0.32
Nodes (3): SessionStore, DispatchWorkItem, TimeInterval

### Community 580 - "ViInputMode"
Cohesion: 0.39
Nodes (5): AutomationSummary, Bool, Date, String, UUID

### Community 586 - "Product"
Cohesion: 0.25
Nodes (7): Claude Code hook push (in-process Task subagent detection), Client UI indicator, Detection core (AgentDetector, pure logic), IPC / Tab plumbing, P38 Phase B — Subagent Visibility — Dev Task Progress, Status: Rewritten 2026-07-14 after original implementation (tasks 1-5) was lost to a concurrent git operation before commit. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 587 - "sheet-cheat.html"
Cohesion: 0.25
Nodes (7): Original overlay build (built 2026-07-14, gated green, then deleted 2026-07-15 mid live-test), P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress, Pivot — merge into the Recipes picker (2026-07-15), Stage 1-2 — Engine/surface plumbing (built 2026-07-14, unchanged by the pivot, still in use), Status: Implementation pivoted mid-phase from a standalone overlay to a merge into the existing, Summary, Thread grouping — Zed framing folded into the same picker (2026-07-15)

### Community 588 - "jHt"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 589 - "Endpoint"
Cohesion: 0.25
Nodes (7): #kouen, #practice, #score, #shell, #total, #unix, #vim

### Community 590 - "lrn"
Cohesion: 0.36
Nodes (3): KouenSplitViewTests, LayoutProbeView, CGFloat

### Community 591 - "main.swift"
Cohesion: 0.29
Nodes (5): ThaiClusterCopyTests, ThaiGrid, .columns, .totalLines, .viewportRows

### Community 592 - "commit-push.sh"
Cohesion: 0.25
Nodes (3): FlushSessionStateTests, String, URL

### Community 596 - ".feed(_:)"
Cohesion: 0.38
Nodes (4): AnyObject, ObjectIdentifier, TimeInterval, ZombieHoldRegistry

### Community 597 - "TerminalColorRole"
Cohesion: 0.29
Nodes (5): AgentNotchPresentation, closed, open, peek, AgentNotchWindowActivator

### Community 598 - ".encode"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 599 - ".terminalHostIfExists"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 600 - "TaskDashboardGroupingTests"
Cohesion: 0.29
Nodes (7): 1. Plain Terminal, 2. Persistent Terminal, 3. Full Terminal, 4. Agent Workspace, Experience modes, Opting into the prefix + status line without switching modes, Persistence (ephemeral vs. persistent)

### Community 601 - "Hwe"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Kouen-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 602 - "Build locally"
Cohesion: 0.33
Nodes (6): Command, .targetKind, TargetKind, pane, session, window

### Community 603 - "fut"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 604 - "k0t"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 605 - "drn"
Cohesion: 0.57
Nodes (3): ProjectConfig, Bool, String

### Community 606 - "Quick start"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 607 - "iRe"
Cohesion: 0.33
Nodes (4): EUe(), eYt(), Sme(), tYt()

### Community 608 - ".zoomWindowIfDoubleClick"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

### Community 609 - "FormatContextDaemonTests"
Cohesion: 0.29
Nodes (6): Locked decisions (user-confirmed), Logical Design, P38 Phase A — Cross-Agent Worktree Diff/Review Dashboard — Design, Strategic Design, Tactical Design, Verification gate (this phase)

### Community 610 - "TabStatus"
Cohesion: 0.29
Nodes (6): Logical Design, Next Step, P42 — Workspace Sidebar Panels, Parked (not in scope), Strategic Design, Tactical Design

### Community 611 - ".showWorkspaceMenu"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 612 - ".init(coder:)"
Cohesion: 0.29
Nodes (6): Any, Error, MainActor, Sendable, String, Void

### Community 614 - "MainSplitViewController"
Cohesion: 0.29
Nodes (3): ScrollbackPersistenceTests, String, URL

### Community 615 - "fences"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 617 - "ScriptFileWatcher"
Cohesion: 0.33
Nodes (3): ResubscribingSlot, Maker, Subscription

### Community 620 - "mS"
Cohesion: 0.33
Nodes (6): DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed

### Community 621 - "ViEngine"
Cohesion: 0.40
Nodes (3): calculate(), constructor(), mBt

### Community 624 - "gmn"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 625 - "brt"
Cohesion: 0.47
Nodes (5): AgentIconArt, AgentVectorIcon, Bool, CGSize, String

### Community 626 - "cGt"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase D — Kitty Graphics Conformance Slice, Scope (locked), Tests

### Community 627 - "ActiveTabCloseDisposition"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua), Scope (locked), Tests

### Community 628 - "ReplayStep"
Cohesion: 0.33
Nodes (5): Logical Design, Next Step, P43 — Add Repo/Folder to Workspace, Strategic Design, Tactical Design

### Community 629 - "graphify reference: query, path, explain"
Cohesion: 0.33
Nodes (5): Build, Release & Git Workflow, Build / Test / Run, Graphify before every delivery commit, Release packaging order, Worktree constraint

### Community 630 - "HGe"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 631 - "die"
Cohesion: 0.60
Nodes (5): main(), printHelp(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 632 - "dne"
Cohesion: 0.40
Nodes (3): String, URL, WorktreeSignatureTests

### Community 635 - "E9"
Cohesion: 0.47
Nodes (3): URL, TimeoutError, WorktreeLargeOutputRegressionTests

### Community 637 - "TerminalScrollbarView"
Cohesion: 0.67
Nodes (3): AsyncCLIResultBox, Error, Result

### Community 638 - "FormatStringExtendedVariableTests"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 640 - "zpt"
Cohesion: 0.60
Nodes (4): AgentBadgeView, .body, Bool, CGFloat

### Community 643 - "h7n"
Cohesion: 0.40
Nodes (5): CodingKeys, excludedPaths, id, name, sourceFolder

### Community 644 - "clean-state.sh"
Cohesion: 0.40
Nodes (4): Cursor Agent → Kouen, Manual fallback, One-line install, What you'll see

### Community 645 - ".delay"
Cohesion: 0.40
Nodes (4): Findings, Sources, What this means for Kouen, Who creates branches / worktrees in AI coding tools

### Community 646 - "String"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: animateSidebar setContentLeadingInset MainSplitViewController, Source Nodes

### Community 647 - "graphify reference: query, path, explain"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: ProjectCategory FolderScanner ProjectDirectoryTree, Source Nodes

### Community 648 - "PtyDrainCeilingBenchmark"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: BrowserPaneView createTab openBrowserPane navigation WebKit, Source Nodes

### Community 649 - "h$t"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: KouenPreviewHome environment key daemon launch at startup, Source Nodes

### Community 650 - "hjt"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: session history search ranking branch best matches, Source Nodes

### Community 651 - "u0n"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Kouen terminal product features agent workspace browser daemon session persistence remote control, Source Nodes

### Community 652 - "TerminalHostView"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: session persistence focus routing browser disposal memory bounded checkpoint undo verify worktree, Source Nodes

### Community 653 - "iOn"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: How should CheckpointManager.restore preserve the user staged index?, Source Nodes

### Community 654 - "BlockContextMenuTests"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Where are the Wave 1 deadlock, HTTP transport and markdown preview paths?, Source Nodes

### Community 655 - "nht"
Cohesion: 0.40
Nodes (5): CodingKeys, bindings, disabledSpecs, id, tables

### Community 656 - "Jcn"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 657 - "AgentNotchViewModel.swift"
Cohesion: 0.40
Nodes (5): ResizeDirection, down, left, right, up

### Community 661 - ".compute"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 662 - "I$e"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 663 - "m6e"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 664 - "P37 Phase G — Autocomplete (mobile bridge)"
Cohesion: 0.70
Nodes (4): restart_daemon(), rollback_version_bump(), full-cycle.sh script, usage()

### Community 665 - "nb"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 666 - "BrowserIntegrationController"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 671 - "AntigravityTranscriptTurnsTests"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

### Community 672 - "ColorKind"
Cohesion: 0.50
Nodes (3): Caveats, Keep awake with the lid closed, Setup

### Community 673 - "qte"
Cohesion: 0.50
Nodes (4): Full local signing path (needs a Developer ID cert; not currently used), How this fork actually releases, Release runbook, Scripted flow

### Community 674 - "t2e"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 675 - ".detect"
Cohesion: 0.50
Nodes (3): exclude_hubs, no_viz, wiki

### Community 676 - "vne"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: SSETransport auth token isRunning

### Community 677 - "New Tab"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: What commands build and test Kouen and prepare Graphify before commit?

### Community 678 - "FormatColor"
Cohesion: 0.50
Nodes (4): WriteOutcome, complete, failed, wouldBlock

### Community 680 - "AgentVectorIcon"
Cohesion: 0.50
Nodes (4): dO(), m8(), rfn(), zfn()

### Community 681 - ".tabIDsToNotify"
Cohesion: 0.67
Nodes (4): FVe(), hJ(), qVe(), Zme()

### Community 682 - "Workbench commands (IDE-like workflow)"
Cohesion: 0.50
Nodes (4): mFe(), WDt(), Wpe(), yDt()

### Community 683 - ".init(coder:)"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 684 - "CommandParseError"
Cohesion: 0.50
Nodes (4): MouseEventKind, drag, press, release

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 686 - "DECSpecialGraphics"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 687 - "AutomationsFleetModelTests"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 688 - ".copy"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 689 - ".availableAgentKinds"
Cohesion: 0.67
Nodes (3): commit_with_graph(), prepare_graph_for_commit(), graphify-commit.sh script

### Community 691 - ".stopProjectScript"
Cohesion: 0.67
Nodes (3): SurfaceMainThreadStallSample, SurfaceOffMainStallSample, UInt64

### Community 702 - "PromptQueue"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 703 - "WorktreeInfoSummary"
Cohesion: 0.67
Nodes (3): cat(), Hwe(), kYe()

### Community 704 - "main.swift"
Cohesion: 0.67
Nodes (3): cfn(), fut(), qYe()

### Community 705 - "[2.3.0] - 2026-06-11"
Cohesion: 0.67
Nodes (3): dht(), k0t(), l1n()

### Community 708 - "WrapperOptionBehavior"
Cohesion: 0.67
Nodes (3): iRe(), jNt(), zNt()

## Knowledge Gaps
- **2388 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+2383 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1137 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Work-memory lessons

**Known dead ends** — questions that led nowhere; don't re-derive.
- "KouenPreviewHome environment key daemon launch at startup" -> `KouenPaths`

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `GitPanelView.swift` to `.setAttribute`, `.showWorkspaceMenu`, `EngineConformanceTests`, `AgentNotchRootView`, `Command`, `LSPMessage`, `.daemonIsStale`, `PerformanceBenchmarks`, `.viewDidLoad`, `Changed`, `.encodeAndWait`, `KittyKeyboardTests`, `VTParser`, `.applyPreedit`, `WorktreeAutoIsolateService`, `HarnessUILibrary`, `HarnessChrome`, `BrowserProgressLine`, `HarnessTerminalSurfaceView`, `Pi → Kouen`, `SplitPaneCoordinator`, `.request`, `WorktreeManager`, `Harness tmux-style capabilities`, `RGBColor`, `AgentNotification`, `CopyModeAction`, `Added`, `Sendable`, `.addTab`, `Equatable`, `DaemonClient`, `Notification`, `code:bash (harness chat "Use the project map first, then inspect this r)`, `.init`, `code:bash (swift build)`, `TerminalColorGamut`, `HarnessSettings`, `.encode`, `RenderSchedulerTests`, `HarnessOverlayBackground`, `HarnessTerminalSurfaceView.swift`, `.buildCommand`, `MobileBridgeSpawnTests`, `HookEvent`, `DaemonServer`, `Added`, `Fixed`, `Added`, `HarnessSplitView`, `TabCell`, `NSPanel`, `BellScanState`, `PasteBufferStore`, `ShellIntegrationTests`, `3.2 สิ่งที่ implement แล้ว`, `ComposedCell`, `HarnessCLI+Server.swift`, `Phase67Tests`, `.text`, `ShellIntegration`, `String`, `Completed Plans Archive`, `.compose`, `ViInputMode`, `ImportedTerminalConfig`, `worktree_isolation_cli.robot`, `README.md`, `[2.6.0] - 2026-06-13`, `HarnessTerminalSurfaceView`, `Added`, `HarnessDesign`, `main.swift`, `.firstMatch`, `LSPDiagnostic`, `TerminalGridCell`, `HarnessPaths`, `SessionCoordinator`, `Harness as a terminal multiplexer`, `MetalRendererTests`, `fut`, `code:bash (# Terminal 1: Create workspace with long-running job)`, `AttachInputBatcher`, `shim.c`, `Harness Usage`, `PaneContainerView`, `4. Technical Architecture`, `.dispatch`, `.memoURL`, `.overrideRootRaw`, `DaemonLauncher`, `ScriptRuntime.swift`, `SpecialKey`, `Changelog`, `domain-design.md`, `AgentNotchViewModel`, `.resolve`, `DamageTrackingTests`, `.encode`, `SessionGroup`, `PaneNode`, `WorkspaceFileTreeView`, `Changed`, `E9`, `String`, `HistoryRingBuffer`, `.path`, `GlyphAtlas`, `code:block1 (SessionCoordinator.snapshot ──┐)`, `TerminalScrollbarView`, `Harness`, `.install`, `AgentHookInstaller`, `code:js (// ~/.config/harness/init.js)`, `.startWatching`, `ActivePaneService`, `Added`, `.parse`, `CopyModeGridSource`, `How to use Harness from the terminal only (no GUI)`, `Jcn`, `FileTreeWatcher`, `EnvironmentStore`, `HarnessDaemonToolsTests`, `I$e`, `.evaluate`, `Int`, `ThaiCombiningMarkTests`, `PaneLabelDaemonTests`, `Harness Terminal — IDE Sidebar Feature Branch`, `AmbientBackground`, `What You Must Do When Invoked`, `TerminalFindBar`, `CommandPromptController`, `ActiveTabCloseDisposition`, `AgentTableEntry`, `TriState`, `.decodeKeySpec`, `codex`, `Added`, `[3.13.1] - 2026-07-02`, `.stopProjectScript`, `.moveActiveSession`, `FormatContext`, `P25 — iOS/iPadOS Support`, `.activePaneID`, `LSPServerRegistry`, `targets`, `BrowserPaneView`, `Error`, `AppDelegate`, `ScriptRuntime`, `MTLCommandQueue`, `ResizeHUDView`, `Feature Provenance — harness-terminal`, `AgentSessionSummary`, `.windowedRecords`, `code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)`, `MCP Server (harness-mcp)`, `PaletteModel`, `From tmux`, `CopyModeState`, `.testDataFrameEncodeVsJSONBase64Output`, `PaneTarget`, `String`, `CellColorResolverTests`, `GridCompositor`, `Prompt`, `qte`, `AgentNotchRowSummary`, `CellColorResolver`, `FileChangeWatcher`, `.decide`, `HarnessGridTerminalTests`, `.scan`, `WorkbenchCommand`, `TerminalBlockStoreTests`, `PaneBorderStatus`, `Added`, `AgentBridge`, `.make`, `.renderFixture`, `Split Right`, `release-hotfix.sh`, `GitMetadataProvider`, `.install`, `.constructor`, `.effectiveStatusLineEnabled`, `DecodedWSFrame`, `.performInstall`, `code:bash (# Old (agent-specific):)`, `DefaultTerminalManager`, `menu`, `SGRMouseEvent`, `P8: macOS 27 Golden Gate Adoption`, `BlockTintOverlay`, `FormatColor`, `code:bash (harness-cli install-hooks hermes)`, `AgentHookStrategy`, `Process`, `GitHubCLIClient`, `jobs`, `PaneNode`, `ThemeDiagnostics`, `RegressionBugFixTests`, `ViPathTokenTests`, `Send Ex Command`, `AgentSnapshot`, `Terminal AI Chat (⌘I inline overlay)`, `Memory — harness-terminal`, `code:bash (# In a Harness pane:)`, `space`, `DesktopNotifier`, `WorkspaceSymbolIndex`, `url`, `.theme`, `README.md`, `$3`, `.drawGlyph`, `Added`, `run.sh`, `TimeInterval`, `CSIParams`, `.isWindowFullScreen`, `FileViewerViewController`, `Agent platform icons`, `[3.2.0] - 2026-06-16`, `DaemonLifecycleTests`, `Background Polling & Snapshot Fanout — P22`, `Architecture Decisions — harness-terminal`, `GPU Animation Pattern — Layout Once, GPU Paints`, `[3.5.1] - 2026-06-20`, `OcclusionTests`, `State`, `FormatStyledSegment.swift`, `generate-cheatsheet.js`, `[2.2.4] - 2026-06-11`, `P13 — Embedded Browser Pane (cmux parity)`, `Prompt`, `Identifiable`, `PromptQueue`, `terminal_stress_runner.py`, `NSTextField Leak in BoardViewController (P20 Performance)`, `INDEX.md`, `Agent hooks`, `SKILL-LOG.md`, `User Profile`, `HarnessCLITests`, `AppKit + Metal Patterns`, `generate-app-icon.sh`, `Files`, `preview.sh`, `PresentAttempt`, `AgentIconRenderer`, `Session/Tab/Pane Hierarchy & Top Bar (CASE-028)`, `Task 1: Redesign Session Sidebar`, `markdown.json`, `typescript.json`, `.parseDiffHunks`, `BoardCardView`, `PathToken`, `SessionEditor`, `RemoteHostStore`, `mobile_bridge_pairing_bugs.robot`, `RunState`, `.deinit`, `MouseButton`, `.moveSelection`, `PresentAttempt`, `HarnessOnboarding`, `String`, `SecureInputMonitor`, `CopilotAdapter`, `SurfaceIO`, `ccRunStart`, `ccRunInfo`, `.testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache`, `zO`?**
  _High betweenness centrality (0.253) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `Fixed` to `ScriptRuntime.swift`, `code:bash (swift build)`, `ImportedTerminalConfig`, `LSPMessage`, `GitPanelView.swift`, `browserGoBack`, `confirmBefore`, `copyMode`, `.rects`, `.script`, `DaemonServer`, `run.sh`, `Added`, `Git Panel`, `.renderFixture`, `BellScanState`?**
  _High betweenness centrality (0.195) - this node is a cross-community bridge._
- **Why does `dvn()` connect `.script` to `CodingKey`, `callingPaneTarget`?**
  _High betweenness centrality (0.101) - this node is a cross-community bridge._
- **Are the 19 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `OutputTriggerMatcher`) actually correct?**
  _`KouenTerminalSurfaceView` has 19 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _2408 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.005622299570426372 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.01249333759727108 - nodes in this community are weakly interconnected._