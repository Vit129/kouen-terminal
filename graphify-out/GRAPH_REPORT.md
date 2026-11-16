# Graph Report - close-release-2026-11-16  (2026-11-16)

## Corpus Check
- 973 files · ~1,064,969 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 20298 nodes · 58543 edges · 2667 communities (1540 shown, 1127 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8605 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `e36acbfb`
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
1. `IPCRequest` - bridges 191 areas (211 edges)
2. `Command` - bridges 102 areas (108 edges)
3. `IPCResponse` - bridges 82 areas (107 edges)
4. `AgentKind` - bridges 81 areas (176 edges)
5. `KouenTerminalSurfaceView` - bridges 73 areas (346 edges)
6. `SessionCoordinator` - bridges 69 areas (235 edges)
7. `SurfaceRegistry` - bridges 66 areas (231 edges)
8. `KouenGridTerminal` - bridges 66 areas (117 edges)
9. `NSView` - bridges 64 areas (193 edges)
10. `AnyCodable` - bridges 64 areas (190 edges)

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

## Communities (2667 total, 1127 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.01
Nodes (703): _0t(), _1n(), _1t(), _2t(), _3e(), _3n(), _5e(), _5n() (+695 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.01
Nodes (526): l, V, em(), z(), _4n(), _7n(), _8n(), a0() (+518 more)

### Community 2 - ".handleNormal"
Cohesion: 0.02
Nodes (351): pe(), r, X(), A(), code(), R(), a(), ae() (+343 more)

### Community 3 - "Changed"
Cohesion: 0.02
Nodes (188): _4e(), _9n(), a0n(), A1(), a6n(), aat(), AS(), avn() (+180 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.05
Nodes (44): AgentBridge, AgentTarget, Bool, String, SurfaceID, .onCurrentCWD, .onCurrentFile, LinePos (+36 more)

### Community 5 - "IPCRequest"
Cohesion: 0.05
Nodes (37): a4e(), a6(), Ac(), _c(), cht(), e5n(), EWt(), f_n() (+29 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.04
Nodes (31): NSEvent, Any, Bool, CGFloat, NSEvent, NSMenu, NSMenuItem, NSPasteboard (+23 more)

### Community 7 - "Command"
Cohesion: 0.04
Nodes (35): .tab(forSurfaceKey:), AgentScanner, Bool, DispatchSourceTimer, TimeInterval, DaemonCommandExecutor, Command, .init(forTesting:) (+27 more)

### Community 8 - "LSPMessage"
Cohesion: 0.05
Nodes (21): IndexingIterator, LayoutTemplate, SessionEditor, .surfaceID(forPaneID:), .tabIndex(surfaceID:), Command, SessionID, GroupedSessionTests (+13 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.05
Nodes (41): bC(), cFt(), clamp(), cU(), CWt(), dw(), e9n(), eu() (+33 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.06
Nodes (31): TerminalModes, InputEncoder, .encode(_:modifiers:event:modes:), .encode(text:modifiers:modes:), .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release (+23 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.08
Nodes (46): MTLClearColor, MTLCommandBuffer, MTLLibrary, MTLRenderCommandEncoder, MTLRenderPipelineState, Int, ImageTextureCache, MTLDevice (+38 more)

### Community 12 - "Changed"
Cohesion: 0.09
Nodes (22): Bool, Double, .addSurface(tabID:paneID:), .addSurface(to:paneID:surfaceID:cwd:), .split(node:targetPaneID:direction:paneCount:before:), .split(node:targetPaneID:with:direction:beforeTarget:), .tab(containingPaneID:), .tab(for:) (+14 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.08
Nodes (33): DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed, DaemonSubscription, .start(onData:onEnd:buffered:) (+25 more)

### Community 14 - "VTParser"
Cohesion: 0.07
Nodes (13): .receive(_:), DispatchSemaphore, FluidityBenchmarks, NSWindow, String, UInt64, NSWindow, KouenTerminalSurfaceWorkerTests (+5 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.04
Nodes (59): Equatable, MochaTheme, DecodedImage, .byteCount, UInt8, TerminalGridSnapshot, Bool, CAMetalDrawable (+51 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.14
Nodes (12): CGImage, KouenGridTerminal, TerminalDamage, RenderColor, MetalRendererTests, RenderedFixture, Bool, MTLTexture (+4 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.10
Nodes (8): KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), SpawnedAgentSurface, Bool, ISO8601DateFormatter, String, Tab, UUID

### Community 18 - "HarnessUILibrary"
Cohesion: 0.07
Nodes (45): AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem, fetchGitStatus() (+37 more)

### Community 19 - "SpecialKey"
Cohesion: 0.08
Nodes (27): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+19 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.05
Nodes (50): .init(entry:), AgentChipView, .init(coder:), .intrinsicContentSize, ChromeBackdrop, .init(coder:), .init(role:), Colors (+42 more)

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.07
Nodes (36): StyledSegment, ColorKind, .base, bg, fg, underline, ComposedCell, .asGridCell (+28 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.09
Nodes (17): RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), .retainedScrollbackBytesForTesting, ScrollbackEntry, ScrollbackReplaySegment, Bool, CChar, DaemonSurfaceID (+9 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.05
Nodes (50): json, async, .saveRecordsBatch(_:), CachedSessionEntry, SessionIndexItem, Date, historyJSONObject(), Any (+42 more)

### Community 24 - ".request"
Cohesion: 0.07
Nodes (24): MainActor, Void, SessionGroupHeaderRowView, .init(coder:), SessionWorktreeHeaderRowView, .init(coder:), SessionWorktreeRowView, .init(coder:) (+16 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.13
Nodes (19): PaletteAction, PaletteItemRow, PaletteModel, .isGrepMode, .placeholder, PalettePanel, .canBecomeKey, PaletteRow (+11 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.07
Nodes (13): SessionGroup, SessionID, String, KouenSidebarPanelViewController, NSMenuItem, SessionGroup, String, NSMenu (+5 more)

### Community 27 - "RGBColor"
Cohesion: 0.07
Nodes (17): EditorDividerView, HitTestPassthroughView, .init(coder:), PaneDragGripView, .init(coder:), .init(paneID:), PaneHoverButton, PaneSplitButtonsView (+9 more)

### Community 28 - ".parse"
Cohesion: 0.10
Nodes (7): Bool, Command, DispatchWorkItem, PaneID, String, UInt8, WindowSession

### Community 29 - "Added"
Cohesion: 0.10
Nodes (11): PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Double, MTLDevice, MTLTexture, String (+3 more)

### Community 30 - "Notification"
Cohesion: 0.07
Nodes (9): ImagePlacement, Pen, SavedCursor, ClosedRange, Range, UnsafeBufferPointer, TerminalScreen, .cursorVisible (+1 more)

### Community 31 - "Sendable"
Cohesion: 0.09
Nodes (31): ArtifactKind, html, image, markdown, text, AutomationsFleetModel, .load(detectScheduledRuns:), AutomationSource (+23 more)

### Community 32 - ".addTab"
Cohesion: 0.13
Nodes (13): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, AutomationScheduler (+5 more)

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
Cohesion: 0.05
Nodes (39): Array, GroupHeaderRow, .body, PickerItem, .groupLabel, historyBlock, .id, recipe (+31 more)

### Community 37 - "String"
Cohesion: 0.11
Nodes (13): SessionID, Status, ciFailing, done, mergeReady, open, running, Bool (+5 more)

### Community 38 - "code:bash (swift build)"
Cohesion: 0.08
Nodes (42): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+34 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.07
Nodes (23): UInt16, Data, OSCTerminatorMatch, DecodedReplyFrame, output, reply, DecodedRequestFrame, input (+15 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.05
Nodes (48): AnyTransition, AnyView, Color, .hexString, AgentNotchPeekEvent, AgentNotchRootView, .body, .bottomRadius (+40 more)

### Community 41 - "CodingKeys"
Cohesion: 0.06
Nodes (28): Notification.Name, KouenGit, os, Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached (+20 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.09
Nodes (20): .exit, String, String, String, String, KouenCLI, LSPDefinitionPayload, LSPDiagnosticsPayload (+12 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.08
Nodes (23): DaemonClient, Int32, String, TimeInterval, UUID, Void, ClaudeCodeHarnessIPCTests, String (+15 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.08
Nodes (37): SettingsAppearanceView, .autoTheme, .body, .themeSection, Bool, ColorHexRow, .body, .colorBinding (+29 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.15
Nodes (8): MainSplitViewController, .setSidebarVisible(_:), Bool, CGFloat, DispatchWorkItem, NSColor, NSRect, Notification

### Community 46 - ".buildCommand"
Cohesion: 0.06
Nodes (33): FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body, .emptyState (+25 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.06
Nodes (45): Configuration, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, ButtonStyle, CommandRow, .body, GlassCard, .body (+37 more)

### Community 48 - "HookEvent"
Cohesion: 0.07
Nodes (12): NWEndpoint, Bool, NWListener, Sendable, String, UInt16, MobileBridgeServer, .isRunning (+4 more)

### Community 49 - "DaemonServer"
Cohesion: 0.04
Nodes (90): a1t(), a6e(), amn(), b2t(), b6(), cg(), ch(), cvn() (+82 more)

### Community 50 - "Added"
Cohesion: 0.06
Nodes (32): Error, LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed, serverNotExecutable, AsyncStream (+24 more)

### Community 51 - ".keyEvent"
Cohesion: 0.15
Nodes (11): Executor, Hook, HookRegistry, Bool, Command, URL, UUID, HookRegistryTests (+3 more)

### Community 52 - "Fixed"
Cohesion: 0.08
Nodes (29): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary, RowKind (+21 more)

### Community 53 - "Added"
Cohesion: 0.08
Nodes (10): SessionCoordinator, .selectWorkspace(_:), Bool, Double, PaneID, String, SurfaceID, TabID (+2 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.06
Nodes (25): Logger, OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, .event(_:), .interval(_:_:) (+17 more)

### Community 55 - "TabCell"
Cohesion: 0.08
Nodes (11): Bool, Range, Set, String, URLDetection, CGFloat, CGRect, Range (+3 more)

### Community 56 - "NSPanel"
Cohesion: 0.07
Nodes (21): GitAheadBehind, GitResult, .isSuccess, GitWorktreeInfo, Bool, Int32, String, GitParsers (+13 more)

### Community 57 - "BellScanState"
Cohesion: 0.11
Nodes (20): AgentHistoryFTSIndex, .deleteSession(sessionID:), .needsReindex(sessionID:mtime:fileSize:), .pruneMissingSessions(validTranscriptPaths:), .search(query:limit:), .searchRanked(query:limit:includeSnippet:requireAllTokens:includeMetadata:matchingIDs:), .searchSubstring(query:includeEvidence:matchingIDs:), AgentHistoryFTSMatch (+12 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.09
Nodes (19): CoreGraphics, CoreText, ImageIO, KouenCopyMode, KouenTerminalEngine, KouenTerminalRenderer, KouenTheme, Metal (+11 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.09
Nodes (28): .filteredJobs, MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith (+20 more)

### Community 60 - "ViEngine"
Cohesion: 0.04
Nodes (72): ake(), al(), ayn(), b3e(), bdn(), bIn(), c8e(), Cp() (+64 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 62 - "ComposedCell"
Cohesion: 0.09
Nodes (24): KouenChromePalette, Bool, CGFloat, NSColor, String, Coordinator, DiffAnalysis, DiffFileItem (+16 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.09
Nodes (9): Bool, NSDraggingInfo, NSDragOperation, NSCursor, URL, NSPasteboard, String, URL (+1 more)

### Community 64 - ".text"
Cohesion: 0.30
Nodes (4): CellOverlayTests, IndexSet, String, UInt64

### Community 65 - "PrefixKeymap"
Cohesion: 0.06
Nodes (35): OptionSet, KeySpec, .description, .init(from:), .init(key:modifiers:), Modifiers, Decoder, String (+27 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.11
Nodes (22): keys, ITerm2InlineImage, .heightArg, .preserveAspectRatio, .widthArg, Bool, String, UInt8 (+14 more)

### Community 67 - "String"
Cohesion: 0.13
Nodes (11): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, PaneID (+3 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.08
Nodes (15): DiffLineType, added, deleted, modified, Bool, NSEvent, NSPopover, NSRange (+7 more)

### Community 69 - ".compose"
Cohesion: 0.12
Nodes (14): NaturalLanguage, .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:surfaceTag:topicSegments:), .saveRecord(_:mtime:fileSize:), AgentHistorySearch, Hit, IDFCache, Bool, Double (+6 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.06
Nodes (31): DetachedPaneOverlay, .init(coder:), .init(frame:style:), InputGate, .siblings, ReconnectLatch, .isTripped, Style (+23 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.10
Nodes (14): NotchMaskAnimator, Bool, CGFloat, CGRect, NotchPanel, .canBecomeKey, .canBecomeMain, Bool (+6 more)

### Community 72 - "XCTestCase"
Cohesion: 0.08
Nodes (16): .effectiveResumeCommand(claudeMode:), LiveClaudeAgentEntry, .placement, ClaudeSessionMode, TimeoutFlag, .didFire, ClaudeCloudSessionStore, Entry (+8 more)

### Community 73 - "README.md"
Cohesion: 0.05
Nodes (19): input, .readJSONLLines(from:fromOffset:), ClaudeSessionLocator, ClaudeTranscriptLine, Role, assistant, user, Any (+11 more)

### Community 74 - "[2.6.0] - 2026-06-13"
Cohesion: 0.22
Nodes (7): AgentRoutingRuleStore, Bool, String, URL, UUID, AgentRoutingRuleStoreTests, URL

### Community 75 - "OptionStore"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 76 - ".parse"
Cohesion: 0.08
Nodes (23): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSEvent (+15 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.15
Nodes (5): BrowserIntegrationController, PaneID, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), SurfaceID

### Community 78 - "Added"
Cohesion: 0.15
Nodes (9): CheckpointInfo, CheckpointManager, Bool, Date, String, CheckpointManagerTests, String, String (+1 more)

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
Cohesion: 0.11
Nodes (15): FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect, String, URL (+7 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.08
Nodes (18): NSScrollView, NSWindow, Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent (+10 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.07
Nodes (27): AgentSessionHistoryModel, .extraRecordsShown, .filteredRecords, .selectedIndex, RepoRootCache, Bool, Date, String (+19 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.08
Nodes (13): CustomStringConvertible, KouenPaths, KouenPathsError, .description, socketPathTooLong, Bool, String, T (+5 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.08
Nodes (27): ClientRecord, CountBox, DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed (+19 more)

### Community 89 - ".cursorPos"
Cohesion: 0.06
Nodes (25): .init(title:isActive:onSelect:onClose:), Selector, Kind, primary, secondary, KouenPillButton, .init(title:kind:), .isHovered (+17 more)

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.16
Nodes (4): hooks, AgentHookInstallerTests, String, URL

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
Cohesion: 0.12
Nodes (9): .captureLines(joinWrapped:), .feed(_:), .promptRows, .readGrid(scrollbackOffset:), ScrollbackTests, Character, String, SemanticPromptTests (+1 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.23
Nodes (3): CSIParams, .count, UInt8

### Community 99 - ".dispatch"
Cohesion: 0.08
Nodes (17): .selectWorkspace(byIndex:), .syncFromDaemon(metadataOnly:), ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy (+9 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.17
Nodes (19): Codable, BrowserSnapshotAck, agentWaitChannel(), BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserSnapshot (+11 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.13
Nodes (17): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+9 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.13
Nodes (10): ScrollbackFile, .highWater, Bool, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 103 - "AnyCodable"
Cohesion: 0.09
Nodes (30): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+22 more)

### Community 104 - "Recipe"
Cohesion: 0.10
Nodes (16): AgentBrowserPaneTracker, SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, SessionID, Set (+8 more)

### Community 105 - "Changelog"
Cohesion: 0.13
Nodes (14): string, AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID, .snapshotPayload (+6 more)

### Community 106 - "domain-design.md"
Cohesion: 0.06
Nodes (41): .pairedAlreadyBanner, .pairingQRPanel, .sidebarEmptyView, .rootPicker, IssueKeychainStore, Bool, String, IssuePriority (+33 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.11
Nodes (14): FlippedView, .isFlipped, .removeWorktreeAction(_:), NSButton, NSColor, NSRect, NSScrollView, NSStackView (+6 more)

### Community 108 - ".resolve"
Cohesion: 0.13
Nodes (5): GitPanelView, Any, DispatchWorkItem, NSMenuItem, UnsafeMutableRawPointer

### Community 109 - "DamageTrackingTests"
Cohesion: 0.06
Nodes (33): BrowserPaneView, .webView(_:didCommit:), .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didFinish:), .webView(_:didStartProvisionalNavigation:), DesignModeElementInfo, LoadCompletionState (+25 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.10
Nodes (24): TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid, .gridOriginPointsX (+16 more)

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.03
Nodes (91): a(), b(), c(), d(), e(), f(), g(), h() (+83 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.09
Nodes (22): AgentRow, .agentColor, .agentColorBinding, .executables, .hookButton, .hookButtonTitle, HookState, failed (+14 more)

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.05
Nodes (31): DaemonClientActor, TimeInterval, DaemonSessionError, daemonError, .description, unexpectedResponse, DaemonSessionService, .endpoint (+23 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.12
Nodes (10): MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, String, SurfaceID (+2 more)

### Community 115 - ".encode"
Cohesion: 0.06
Nodes (18): NSResponder, NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent (+10 more)

### Community 116 - "SessionGroup"
Cohesion: 0.08
Nodes (25): BrowserPaneRegistry, .activeTab, .init(url:paneID:), .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), BrowserTab, BrowserTabButton, SelectAllOnClickTextField (+17 more)

### Community 117 - "PaneNode"
Cohesion: 0.11
Nodes (13): MarkdownPreviewView, .webView(_:decidePolicyFor:decisionHandler:), Bool, MainActor, Sendable, String, URL, WKNavigationAction (+5 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.21
Nodes (7): BrowserOkAck, Sendable, T, ConnectionState, ErrorAck, NWConnection, UUID

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
Cohesion: 0.16
Nodes (5): CommandPaletteController, PaletteFileEntry, PaletteGrepMatch, String, TimeInterval

### Community 123 - "Pipe"
Cohesion: 0.09
Nodes (21): ModelProvider, .agentKindForLogo, aider, anthropic, azure, copilot, cursor, google (+13 more)

### Community 124 - "String"
Cohesion: 0.06
Nodes (15): KouenCore, PendingVersionBanner, welcome, whatsNew, State, String, Phase67Tests, BellScanTests (+7 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.16
Nodes (14): DirectoryItemRow, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerModel, DirectoryPickerView, .body, DirectoryWindowDelegate (+6 more)

### Community 126 - ".path"
Cohesion: 0.15
Nodes (11): Bool, OptionStore, Scope, pane, session, tab, workspace, ScopedKey (+3 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.07
Nodes (24): ImagePlacementSnapshot, SemanticMark, Bool, TerminalCellWidth, normal, spacerTail, wide, TerminalColorRole (+16 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 129 - "SwiftUI"
Cohesion: 0.14
Nodes (11): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+3 more)

### Community 130 - "Harness"
Cohesion: 0.08
Nodes (17): Bool, URL, VersionBannerStore, GroupedSessionDaemonTests, SessionGroup, String, URL, MobileBridgeSpawnTests (+9 more)

### Community 131 - ".install"
Cohesion: 0.09
Nodes (23): BinaryInstaller, .bundledMacOSDir, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display (+15 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.16
Nodes (10): AgentRoutingResolver, String, AgentRoutingRule, Kind, path, stack, Bool, Date (+2 more)

### Community 133 - ".load"
Cohesion: 0.07
Nodes (15): PluginLoader, String, ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String (+7 more)

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.11
Nodes (14): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+6 more)

### Community 135 - "CommandTarget"
Cohesion: 0.09
Nodes (22): HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane, afterSplitPane, agentStateChanged (+14 more)

### Community 136 - ".startWatching"
Cohesion: 0.12
Nodes (12): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+4 more)

### Community 137 - "ActivePaneService"
Cohesion: 0.11
Nodes (13): FileFuzzyMatcher, FileSearchRootScanner, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool (+5 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.14
Nodes (17): ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool, Command (+9 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.08
Nodes (19): Group, ParsedShortcut, .displayString, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, PrefixKeymap, Any (+11 more)

### Community 140 - "Added"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, Iterator (+2 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.05
Nodes (21): KouenDaemonCore, DaemonAsyncReplyRoutingTests, Int32, String, TimeInterval, UInt8, URL, DaemonBrowserRoutingTests (+13 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.10
Nodes (22): ChecksStatus, fail, none, pass, CIRun, GitHubCLIClient, IssueInfo, MergeMethod (+14 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.14
Nodes (11): String, ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID, String (+3 more)

### Community 146 - "DecodedImage"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 147 - "FileTreeWatcher"
Cohesion: 0.12
Nodes (19): .windowSection, KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:fileSearchRoots:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:), .scrollbackLines, ClaudeSessionMode, Decoder, Double (+11 more)

### Community 148 - "TriState"
Cohesion: 0.17
Nodes (14): AgentIconRenderer, Scanner, .atEnd, SVGPathParser, Bool, CGFloat, CGPath, CGPoint (+6 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.12
Nodes (9): .records, .searchQuery, .selectedAgents, .selectedScope, Set, UInt64, AgentSessionHistoryModelTests, Date (+1 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.17
Nodes (9): Array, FormatColor, none, palette, rgb, Bool, Element, String (+1 more)

### Community 151 - ".evaluate"
Cohesion: 0.16
Nodes (11): tool, KouenDaemonToolsTests, String, URL, Document, Bool, Set, String (+3 more)

### Community 152 - "Added"
Cohesion: 0.08
Nodes (27): BrowserLeaf, CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf (+19 more)

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.21
Nodes (7): NodeRow, .body, .parentDirectory, Error, Never, String, Void

### Community 154 - "LiveResizeTests"
Cohesion: 0.12
Nodes (15): SavedLayoutStore, Bool, String, URL, UUID, PaneLayoutShape, branch, leaf (+7 more)

### Community 155 - "Int"
Cohesion: 0.21
Nodes (8): FileTreeContext, NSHostingView, SessionID, String, Void, WorkspaceFileTreeView, .init(rootPath:), WorkspaceFileTreePinTests

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.21
Nodes (8): DaemonMetrics, Snapshot, .meanLockWaitMicros, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 157 - "Added"
Cohesion: 0.10
Nodes (14): BoardCardView, .init(card:), .init(coder:), .onDismiss, BoardViewController, .isVisible, FlippedView, .isFlipped (+6 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.17
Nodes (12): CGFloat, NSCoder, SessionID, String, Void, TaskDashboardBody, .body, TaskDashboardView (+4 more)

### Community 159 - "MatchCategory"
Cohesion: 0.22
Nodes (5): AgentNotchViewModel, Bool, CGFloat, Duration, String

### Community 160 - "AmbientBackground"
Cohesion: 0.11
Nodes (4): FilePreviewCoordinator, FileTabID, Set, String

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.13
Nodes (13): MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem, SessionGroup (+5 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.10
Nodes (27): clamp(), statusColor(), statusHelp(), CGFloat, Date, Never, Range, String (+19 more)

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
Cohesion: 0.06
Nodes (31): aie(), arc(), ax(), b2e(), bezierCurveTo(), closePath(), cRe(), cZ() (+23 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.07
Nodes (18): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, PaneID, SurfaceID (+10 more)

### Community 168 - "Added"
Cohesion: 0.10
Nodes (22): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, .init(from:), .init(id:name:baseURL:modelID:), Decoder (+14 more)

### Community 169 - "Fixed"
Cohesion: 0.11
Nodes (18): Process, SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, SSHTunnelManager (+10 more)

### Community 170 - "URLDetection"
Cohesion: 0.12
Nodes (21): FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose, FileTabPillView (+13 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.07
Nodes (30): AppKit, Motion, .entrance, .spring, .standardEase, AttentionBeaconDotView, BeaconView, .init(coder:) (+22 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.14
Nodes (10): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab, UUID (+2 more)

### Community 173 - "BoardCard"
Cohesion: 0.16
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.15
Nodes (16): ClaudeCodeHarness, Profile, edit, readonly, Run, RunState, cancelled, failed (+8 more)

### Community 175 - "RGBColorTests"
Cohesion: 0.10
Nodes (23): bNt(), bu(), cNt(), dNt(), eNt(), eRe(), fNt(), iNt() (+15 more)

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
Cohesion: 0.11
Nodes (19): DataBox, .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:) (+11 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.18
Nodes (6): Tab, PaneLifecycleManager, Bool, Set, String, Tab

### Community 181 - "GridCompositorTests"
Cohesion: 0.11
Nodes (12): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+4 more)

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
Cohesion: 0.25
Nodes (8): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String

### Community 186 - "Error"
Cohesion: 0.14
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 187 - "AppDelegate"
Cohesion: 0.13
Nodes (7): Bool, String, UInt8, UnsafeBufferPointer, TerminalEmulator, .captureLines(fromLine:toLine:), .onSetClipboard

### Community 188 - "BrowserPaneView"
Cohesion: 0.12
Nodes (17): FileNode, GitStatusType, added, deleted, modified, renamed, unmodified, untracked (+9 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.20
Nodes (11): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, .selectedHost (+3 more)

### Community 190 - "user-stories.md"
Cohesion: 0.22
Nodes (7): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController

### Community 191 - "ScriptRuntime"
Cohesion: 0.09
Nodes (19): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+11 more)

### Community 192 - "GlyphRasterizer"
Cohesion: 0.07
Nodes (28): Additional `kouen-cli` subcommands, Agent safety CLI (`kouen-cli`), Agents, context and scratchpad, Attaching from a plain terminal, Bindings, Board and attention, Buffers (paste store), Composition (+20 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.08
Nodes (6): KouenSettings, Bool, ExperienceModeTests, KouenSettingsTests, URL, Void

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.12
Nodes (11): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, osc (+3 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.21
Nodes (4): CommandTarget, String, UUID, TargetSpecTests

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.09
Nodes (23): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+15 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.12
Nodes (10): .readJSONLLines(from:), AntigravitySessionLocator, Bool, Int32, NSRegularExpression, S, String, URL (+2 more)

### Community 198 - ".classify"
Cohesion: 0.11
Nodes (3): TimeInterval, String, WorktreeIsolationTests

### Community 199 - "code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)"
Cohesion: 0.12
Nodes (15): CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16, UInt8, DecoKind (+7 more)

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.06
Nodes (30): AgentBadgeView, .body, Bool, CGFloat, FilterStatus, active, all, completed (+22 more)

### Community 202 - "PaletteModel"
Cohesion: 0.11
Nodes (23): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), .stats (+15 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.16
Nodes (14): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+6 more)

### Community 204 - "From tmux"
Cohesion: 0.16
Nodes (7): AgentDetection, AgentDetector, Date, Int32, TimeInterval, ProcessScan, Int32

### Community 205 - "CopyModeState"
Cohesion: 0.18
Nodes (16): decodeBoundedCString(), ignoreSIGPIPE(), makeUnixStreamSocket(), setNoSigPipe(), CChar, Int32, sockaddr, socklen_t (+8 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.19
Nodes (12): DisplayLinkTarget, SplitChromeDelegate, .sidebarMaxWidth, .sidebarMinWidth, .splitView(_:constrainMaxCoordinate:ofSubviewAt:), .splitView(_:constrainMinCoordinate:ofSubviewAt:), .splitView(_:effectiveRect:forDrawnRect:ofDividerAt:), .splitView(_:shouldAdjustSizeOfSubview:) (+4 more)

### Community 207 - "scheduleRender"
Cohesion: 0.19
Nodes (3): fQ, hqe(), M9()

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.15
Nodes (9): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, Set, SurfaceID, Tab (+1 more)

### Community 209 - "SettingsRemoteView"
Cohesion: 0.25
Nodes (4): surfaceID, .surfaceID(forPaneID:in:), AgentSnapshot, AgentSessionSummaryTests

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.13
Nodes (16): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+8 more)

### Community 211 - "PaneTarget"
Cohesion: 0.13
Nodes (13): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+5 more)

### Community 212 - ".translate"
Cohesion: 0.19
Nodes (8): item, CodexSessionLocator, CodexTranscriptLine, Any, Bool, Int32, String, URL

### Community 213 - "String"
Cohesion: 0.17
Nodes (13): Notification.Name, ObserverToken, NSCoder, NSObjectProtocol, NSRect, NSTextView, SyntaxLineNumberGutterView, .init(coder:) (+5 more)

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.08
Nodes (19): SnapshotCoalescer, MainActor, Void, AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide (+11 more)

### Community 215 - ".lines"
Cohesion: 0.16
Nodes (11): ProjectGroupWatcher, StreamBox, Bool, DispatchSourceFileSystemObject, escaping, MainActor, Never, String (+3 more)

### Community 216 - "CellColorResolverTests"
Cohesion: 0.20
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 217 - "GridCompositor"
Cohesion: 0.13
Nodes (23): Colors, Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors (+15 more)

### Community 219 - "Prompt"
Cohesion: 0.22
Nodes (10): CopyModeGridSource, .promptRows, ClosedRange, CopyModeReducer, Bool, Character, NSRegularExpression, Range (+2 more)

### Community 220 - "Section"
Cohesion: 0.09
Nodes (11): KeybindingsService, Bool, Command, String, KeybindingsStore, .fileURL, URL, KeybindingsStoreTests (+3 more)

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.15
Nodes (16): AgentMark, .body, AgentMarkShape, Scanner, .atEnd, SVGPath, Bool, CGFloat (+8 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.11
Nodes (16): .body, .mcpButton, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter, Any (+8 more)

### Community 224 - "CellColorResolver"
Cohesion: 0.18
Nodes (4): Divergence, Bool, String, WorktreeInfo

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.16
Nodes (4): SessionGroup, String, UUID, String

### Community 226 - "FileChangeWatcher"
Cohesion: 0.11
Nodes (20): CodingKeys, error, id, jsonrpc, method, params, result, LSPDiagnostic (+12 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.17
Nodes (10): BranchSwitchHelper, FileTreeNode, FileTreeSwiftUIView, .body, .pastedImagesSection, Notification.Name, Bool, NSMenuItem (+2 more)

### Community 228 - "sessionRow"
Cohesion: 0.17
Nodes (11): NotchGeometry, .fallback, NSScreen, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics (+3 more)

### Community 229 - ".decide"
Cohesion: 0.13
Nodes (16): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, .bytesPerWakeup, .mbps (+8 more)

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.10
Nodes (31): files, Encodable, ExpressibleByStringLiteral, AgyModelsPush, AISuggestionAck, AttachedAck, Body, BrowserFramePush (+23 more)

### Community 231 - "ExternalOpenKind"
Cohesion: 0.12
Nodes (7): CwdAuthorizationError, foreignPathRejected, .message, missingSessionOrCwd, other, Result, MobileBridgeAISuggestTests

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.15
Nodes (12): Configuration, Int32, SessionGroup, SessionID, Tab, TabID, WorkspaceID, TabSelector (+4 more)

### Community 233 - "TextGrid"
Cohesion: 0.13
Nodes (12): pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal, Int32 (+4 more)

### Community 234 - ".scan"
Cohesion: 0.20
Nodes (4): AgentTableEntry, Bool, Set, String

### Community 235 - "WorkbenchCommand"
Cohesion: 0.11
Nodes (12): CodingKeys, error, id, jsonrpc, method, JSONRPCId, int, string (+4 more)

### Community 236 - "Added"
Cohesion: 0.16
Nodes (3): CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.08
Nodes (6): CodepointRunFastPathTests, .assertAllPathsAgree(_:cols:rows:file:line:), StaticString, String, UInt, UInt8

### Community 238 - ".make"
Cohesion: 0.13
Nodes (9): NSDraggingInfo, NSDragOperation, PasteController, Bool, NSPasteboard, String, TimeInterval, URL (+1 more)

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.20
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 240 - "PaneBorderStatus"
Cohesion: 0.11
Nodes (7): Range, String, TerminalBufferMatch, TerminalBufferSearch, String, TerminalBufferSearchTests, ThaiCombiningMarkTests

### Community 241 - "Added"
Cohesion: 0.21
Nodes (10): ContentLengthRejection, SSETransport, .isRunning, .listener, Bool, NWConnection, NWListener, Result (+2 more)

### Community 242 - "AgentBridge"
Cohesion: 0.16
Nodes (11): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+3 more)

### Community 243 - ".make"
Cohesion: 0.17
Nodes (9): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ProcessInfo (+1 more)

### Community 244 - "FileNode"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.24
Nodes (3): StatusLineWidthTests, StatusLineWidth, String

### Community 246 - "Experience modes"
Cohesion: 0.17
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 247 - ".renderFixture"
Cohesion: 0.13
Nodes (15): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+7 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.27
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.13
Nodes (9): .isHidden, .removeWorktreeAction(path:), GitResult, Bool, GitResult, String, ValidateOutcome, WorktreeEntry (+1 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.11
Nodes (10): NSAttributedString, String, SyntaxHighlighter, KouenApp, SyntaxHighlighterTests, NSAttributedString, NSColor, String (+2 more)

### Community 251 - "SessionCoordinator"
Cohesion: 0.08
Nodes (25): Font, .kouenBadge, .kouenBody, .kouenBodyStrong, .kouenCaption2, .kouenCaption, .kouenKbd, .kouenMono (+17 more)

### Community 252 - "NSViewRepresentable"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 253 - "Split Right"
Cohesion: 0.07
Nodes (19): Foundation, AgentHistoryJSONLSequence, .isValid, Iterator, Bool, Date, FileHandle, Iterator (+11 more)

### Community 254 - "BoardViewController"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.28
Nodes (7): Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 256 - "GitMetadataProvider"
Cohesion: 0.15
Nodes (16): DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:), .isWorktreeSession (+8 more)

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.22
Nodes (3): ezt(), GGe, Hzt()

### Community 258 - "WindowTitleStripView"
Cohesion: 0.17
Nodes (3): $Rt(), tJe(), YUt

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 260 - ".welcome"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.33
Nodes (4): .setSidebarVisible(_:animated:), SidebarPlacementSyncTests, CGFloat, Void

### Community 262 - ".install"
Cohesion: 0.13
Nodes (6): PromptQueue, String, SurfaceID, Void, PromptQueueBar, NSWindow

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.15
Nodes (19): .modifierFlags, NSEvent, BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, CodingKeys (+11 more)

### Community 264 - "code:bash (harness-cli install-hooks claude-code)"
Cohesion: 0.21
Nodes (8): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, NSEvent, Observation

### Community 265 - "code:bash (harness-cli install-hooks cursor)"
Cohesion: 0.24
Nodes (4): PortableRelativeDateFormatter, Date, String, UUID

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
Cohesion: 0.20
Nodes (8): KouenCommands, DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String

### Community 273 - "KeySpec"
Cohesion: 0.13
Nodes (14): ExperienceMode, agent, .displayName, .foregroundsAgents, full, .notchEnabledByDefault, persistent, .persistsSessionsByDefault (+6 more)

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.05
Nodes (12): azt(), B0, BBe(), F7, Fze, ibe(), mathmlBuilder(), O7 (+4 more)

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.37
Nodes (3): .block(atPromptLine:), String, TerminalBlockStoreTests

### Community 276 - "SyntaxTextView"
Cohesion: 0.23
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 277 - ".run"
Cohesion: 0.18
Nodes (11): JSONRPCMessage, notification, request, response, StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength (+3 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.19
Nodes (10): RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal, FileHandle, Int32 (+2 more)

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.20
Nodes (7): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, FileChangeWatcherTests

### Community 280 - ".menu"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.18
Nodes (20): CoreImage, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription, .surfaceID, detectHost() (+12 more)

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.14
Nodes (12): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+4 more)

### Community 283 - "FormatColor"
Cohesion: 0.12
Nodes (19): Array, Bool, Date, Decoder, PaneID, String, TabID, Tab (+11 more)

### Community 284 - "click_ui_element"
Cohesion: 0.19
Nodes (8): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, String, PaneStyleTests

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.16
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 287 - ".apply"
Cohesion: 0.16
Nodes (16): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+8 more)

### Community 288 - "AgentHookStrategy"
Cohesion: 0.23
Nodes (5): WorktreeManager, String, URL, UUID, WorktreeIsolationDaemonTests

### Community 289 - "StatusLineWidthTests"
Cohesion: 0.13
Nodes (3): AgentLaunchCommandsTests, URL, Void

### Community 290 - "Process"
Cohesion: 0.20
Nodes (6): Case, ReflowCorpusTests, .corpus, .goldenDir, String, URL

### Community 291 - "JSONDecoder"
Cohesion: 0.10
Nodes (11): KouenTerminalKit, KouenTerminalSurfaceFocusTests, OcclusionTests, NSWindow, String, TimeInterval, SpecialKeyMappingTests, Bool (+3 more)

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
Cohesion: 0.18
Nodes (5): .snapshot, Bool, String, ThemeService, KouenOptions

### Community 298 - "jobs"
Cohesion: 0.18
Nodes (11): Never, NSRegularExpression, Set, String, Task, URL, Void, WorkspaceSymbolIndex (+3 more)

### Community 299 - "PaneNode"
Cohesion: 0.16
Nodes (8): CustomEndpointTester, Result, Bool, String, URL, CustomEndpointTesterTests, URLRequest, URLSession

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.05
Nodes (33): ResubscribingSlot, KeyRecorderRepresentable, SettingsKeysView, .body, String, Void, BrowserProgressLine, .init(frame:) (+25 more)

### Community 301 - ".parse"
Cohesion: 0.13
Nodes (9): NSEvent, BrowserFileReloadTests, CountingWebView, Nav, NSEvent, String, Void, WKNavigation (+1 more)

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.21
Nodes (10): SessionDividerRowView, .init(coder:), .init(frame:), .init(frame:), .init(frame:), .init(frame:), .init(frame:), NSRect (+2 more)

### Community 303 - ".encodeMouse"
Cohesion: 0.14
Nodes (13): .effectiveResumeCommand(mode:), AgentLaunchCommands, String, AgentSessionMode, cloud, .launchCommand, .launchFlags, local (+5 more)

### Community 304 - "00-inception-plan.md"
Cohesion: 0.20
Nodes (6): Keyboard Shortcuts, AI Browser Control (kouen-mcp), HTTP/SSE authentication, Install, Shell integration (OSC 133 semantic prompts), What gets emitted

### Community 305 - ".script"
Cohesion: 0.15
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
Cohesion: 0.21
Nodes (5): NSRangePointer, Any, NSAttributedString, NSRange, NSRect

### Community 310 - "FrameSignposter"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.09
Nodes (16): AgyModelCatalog, Catalog, Date, String, TimeInterval, AgyMobileCommands, String, ClaudeMobileCommands (+8 more)

### Community 312 - "AgentSnapshot"
Cohesion: 0.10
Nodes (17): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+9 more)

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.16
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
Cohesion: 0.16
Nodes (9): URL, KouenFilePreviewLoader, KouenViewError, binaryOrUnsupportedEncoding, missingPath, tooLarge, unreadable, FileManager (+1 more)

### Community 319 - "FormatColor"
Cohesion: 0.09
Nodes (14): Bool, NSEvent, Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint (+6 more)

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.15
Nodes (8): DispatchSource, DispatchQueue, DispatchSourceFileSystemObject, Int32, URL, Void, TranscriptFileWatcher, MobileBridgeTranscriptWatcherTests

### Community 321 - "UInt64"
Cohesion: 0.20
Nodes (7): HTTPURLResponse, SSETransportTests, Never, String, Task, UInt16, Void

### Community 322 - "DesktopNotifier"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 325 - "FloatingPaneController"
Cohesion: 0.18
Nodes (3): ShellIntegrationTests, .repoRoot, URL

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.30
Nodes (4): TaskStore, tasks, URL, TaskStoreTests

### Community 327 - ".theme"
Cohesion: 0.32
Nodes (3): BinaryInstallerVersionTests, String, URL

### Community 328 - "README.md"
Cohesion: 0.13
Nodes (16): OnboardingStep, complete, discover, .id, setup, shell, .title, welcome (+8 more)

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.15
Nodes (8): brn, grn, hrn(), JGe(), KGe(), prn(), qGe(), zGe()

### Community 330 - ".drawGlyph"
Cohesion: 0.39
Nodes (4): SettingsAdvancedView, .body, Bool, String

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.10
Nodes (3): Bool, String, UUID

### Community 332 - "Added"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 333 - "RealPty"
Cohesion: 0.10
Nodes (12): ScriptAPI, ScriptError, .errorDescription, evaluationError, unsupportedPlatform, String, JavaScriptCore, JSStringLiteralTests (+4 more)

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.13
Nodes (5): String, WorkspaceID, DaemonSyncServiceBranchNotifyTests, RegressionBugFixTests, Tab

### Community 335 - ".makeModel"
Cohesion: 0.23
Nodes (8): KouenChrome, PaletteFooter, .body, .body, AttributedString, NSColor, DirectoryPickerFooter, .body

### Community 336 - "run.sh"
Cohesion: 0.11
Nodes (15): .agentInfo(forWorktreePath:), Reason, errored, finished, needsInput, RowState, Bool, Comparable (+7 more)

### Community 337 - "CommandExecutionError"
Cohesion: 0.17
Nodes (5): TabID, WorkspaceID, AgentCommandTests, String, Tab

### Community 338 - "CSIParams"
Cohesion: 0.16
Nodes (17): FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView, .body (+9 more)

### Community 339 - "Foundation"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.31
Nodes (4): GraphifyIndexCache, S, Set, String

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.11
Nodes (18): fix ที่ค้างอยู่ใน working tree (ยังไม่ commit), Terminal grid ไม่ใช่ก้อนใหญ่ที่ระบุชนิดได้, ก้อนหลักเกี่ยวข้องกับ RenderBox, การให้ DeepSeek ตรวจเพิ่ม, ผลตรวจ preview ที่แยกจากแอปหลัก, ผลตรวจแอปหลัก, ภาคผนวก 1 — fleet 9 ต.ค. (P54) กระทบ UI ไหม → กระทบ ตรงจุด, ภาคผนวก 2 — 18 ต.ค. `8c5e0c8d` P59 (agy session, **unreviewed**) (+10 more)

### Community 342 - "Added"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 344 - "FileViewerViewController"
Cohesion: 0.05
Nodes (25): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+17 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.24
Nodes (9): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+1 more)

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
Cohesion: 0.26
Nodes (5): Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.21
Nodes (3): TabID, WorkspaceID, GitPanelViewWorktreeNavigationTests

### Community 355 - ".deepMerge"
Cohesion: 0.29
Nodes (3): KouenCompositor, GridCompositorCopyModeTests, String

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.19
Nodes (9): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+1 more)

### Community 357 - ".handleCat"
Cohesion: 0.19
Nodes (13): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Bool, Duration (+5 more)

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.18
Nodes (6): KeyTokenParser, Bool, String, .remaining, KeyTokenParserTests, Phase6KeysTests

### Community 359 - "OcclusionTests"
Cohesion: 0.11
Nodes (11): SGRMouse, SGRMouseEvent, Bool, UInt8, MouseEventKind, drag, press, release (+3 more)

### Community 360 - "State"
Cohesion: 0.18
Nodes (13): FeaturePhase, architect, completed, dev, interview, qaDesign, qaVerify, .title (+5 more)

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.16
Nodes (9): FileGraphInfo, GraphifyLSPBridge, Double, String, URL, GraphifyLSPBridgeTests, Any, String (+1 more)

### Community 362 - "RGBColor"
Cohesion: 0.11
Nodes (21): bX(), c6(), dUe(), fme(), gce(), _gn(), gSn(), h7e() (+13 more)

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
Cohesion: 0.15
Nodes (5): Security, KouenMCPServer, String, MCPServer, String

### Community 368 - "Tab"
Cohesion: 0.29
Nodes (7): AnimatablePair, NotchShape, .animatableData, CGFloat, CGPath, CGRect, Path

### Community 369 - "Git Panel"
Cohesion: 0.27
Nodes (7): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection, agents

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
Cohesion: 0.18
Nodes (11): table(), tablecell(), tablerow(), Y(), ate(), d5(), eoe(), _Fe() (+3 more)

### Community 374 - ".run"
Cohesion: 0.21
Nodes (13): CellMetrics, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth, Bool (+5 more)

### Community 375 - ".install"
Cohesion: 0.13
Nodes (11): Darwin, Glibc, FormatContextBuilder, daemonLog(), detectStaleInstance(), installSignalHandlers(), removeForeignPIDFile(), removePIDFile() (+3 more)

### Community 376 - "ScrollReuseTests"
Cohesion: 0.11
Nodes (5): KouenCLI, HistorySearchQueryTests, MemoCommandTests, URL, TaskCommandTests

### Community 377 - "Identifiable"
Cohesion: 0.24
Nodes (11): a2(), akn(), ift(), p7n(), R1(), rht(), tun(), ubt() (+3 more)

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

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.13
Nodes (5): ImageLimits, Bool, ImageDecoder, ImageProtocolTests, String

### Community 385 - "INDEX.md"
Cohesion: 0.14
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
Cohesion: 0.20
Nodes (8): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.12
Nodes (5): ContentAreaViewController, Bool, CGFloat, String, TabID

### Community 393 - "create-dmg.sh"
Cohesion: 0.10
Nodes (19): DotView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor, NSHostingView (+11 more)

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
Cohesion: 0.13
Nodes (15): BrowserRequestPayload, close, cookies, evaluate, goBack, goForward, interact, navigate (+7 more)

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
Cohesion: 0.18
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 406 - "main.swift"
Cohesion: 0.27
Nodes (8): LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab, TabID, WorkspaceID

### Community 407 - "Fixed"
Cohesion: 0.23
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 408 - "IPC Architecture"
Cohesion: 0.23
Nodes (8): LayoutFileStore, LayoutNode, branch, leaf, LayoutTemplate, Date, Double, String

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.20
Nodes (8): DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSViewCornerConfiguration, SurfaceID, Void

### Community 410 - ".applyTerminalIdentity"
Cohesion: 0.16
Nodes (10): .init(coder:), .init(coder:), .init(coder:), DesignModePopoverViewController, .init(coder:), .init(title:properties:styles:onStyleChanged:onCopyCSS:onPromptAgent:), NSCoder, NSStackView (+2 more)

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.08
Nodes (17): ObjectiveC, BrowserTabRepaintTests, RepaintCountingWebView, Any, Error, MainActor, Sendable, String (+9 more)

### Community 412 - "go.json"
Cohesion: 0.18
Nodes (10): LSPFileSession, Never, String, Task, URL, Void, URL, SyntaxDefinitionTarget (+2 more)

### Community 413 - "javascript.json"
Cohesion: 0.19
Nodes (6): KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, OnboardingEnvironmentTests

### Community 414 - "json.json"
Cohesion: 0.23
Nodes (13): kouen.bash script, agy(), claude(), codex(), copilot(), hermes(), kouen(), __kouen_agy_next() (+5 more)

### Community 415 - "markdown.json"
Cohesion: 0.23
Nodes (5): ListeningPortScanner, Int32, Set, String, ListeningPortScannerTests

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.15
Nodes (9): Bool, Int32, String, URL, SystemdUserInstaller, .backendName, .isInstalled, .unitURL (+1 more)

### Community 417 - "rust.json"
Cohesion: 0.24
Nodes (8): InstallResult, Shell, bash, fish, zsh, ShellIntegration, Bool, URL

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.29
Nodes (4): RepoResolver, Bool, String, RepoResolverTests

### Community 419 - "typescript.json"
Cohesion: 0.14
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
Cohesion: 0.31
Nodes (4): Bool, String, UUID, TaskDaemonBridge

### Community 438 - "SessionEditor"
Cohesion: 0.20
Nodes (10): BrowserResponsePayload, cookies, error, network, ok, open, screenshot, snapshot (+2 more)

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
Cohesion: 0.22
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

### Community 456 - "TerminalModes"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

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
Cohesion: 0.36
Nodes (3): .agentInfo(forWorktreePath:tabs:), Tab, GitPanelViewWorktreeAgentTests

### Community 462 - "AGENTS.md"
Cohesion: 0.11
Nodes (18): CodingKeys, excludedPaths, id, name, sourceFolder, CodingKey, CodingKeys, createdAt (+10 more)

### Community 463 - ".deinit"
Cohesion: 0.07
Nodes (25): JSONDecoder, JSONEncoder, Kind, input, metadata, output, resize, RecordingEvent (+17 more)

### Community 465 - "DirectionalAxis"
Cohesion: 0.24
Nodes (3): ShortcutRecorderSerializer, String, ShortcutRecorderSerializerTests

### Community 466 - "PlatformSys.swift"
Cohesion: 0.41
Nodes (5): InstallResult, ShellCompletionInstaller, Bool, String, URL

### Community 467 - ".moveSelection"
Cohesion: 0.21
Nodes (5): FDWatchdog, DispatchSourceTimer, String, TimeInterval, FDWatchdogTests

### Community 469 - "PresentAttempt"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 470 - "DispatchTime"
Cohesion: 0.11
Nodes (32): a7e(), b9n(), dU(), Dwe(), Etn(), fae(), gae(), Gwe() (+24 more)

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
Cohesion: 0.24
Nodes (5): String, TextGrid, .totalLines, .viewportRows, WordColumnRangeTests

### Community 476 - "StatusDotView"
Cohesion: 0.26
Nodes (4): PaneLabelDaemonTests, String, URL, UUID

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
Cohesion: 0.33
Nodes (6): Bool, NSPasteboard, NSString, String, URL, AutoreleasingUnsafeMutablePointer

### Community 486 - "TabPillView"
Cohesion: 0.29
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 487 - "bC"
Cohesion: 0.29
Nodes (6): .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8

### Community 488 - "R1"
Cohesion: 0.25
Nodes (6): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow

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

### Community 494 - "ccRunInfo"
Cohesion: 0.41
Nodes (4): KouenFeatureMarkdownSync, Bool, String, URL

### Community 495 - ".open"
Cohesion: 0.29
Nodes (8): AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand, Bool, Set

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.39
Nodes (3): data, SixelDecoder, UInt8

### Community 497 - ".bind"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: LSPFileSession FilePreviewCoordinator LSPClient shutdown GraphifyLSPBridge hover, Source Nodes

### Community 498 - ".runGitDiff"
Cohesion: 0.50
Nodes (4): PaletteMode, errors, grep, normal

### Community 499 - "GlassEffectView"
Cohesion: 0.05
Nodes (37): aDt(), B3(), BDt(), Bpe(), cFe(), dFe(), displayable(), _Dt() (+29 more)

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
Cohesion: 0.13
Nodes (3): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess

### Community 510 - "PromptQueue"
Cohesion: 0.67
Nodes (3): TransportError, invalidUTF8Header, missingContentLength

### Community 511 - ".panePathLookup"
Cohesion: 0.18
Nodes (11): Typography, .badge, .kbd, .paletteHeader, .paletteTitle, .rowMeta, .rowTitle, .sectionLabel (+3 more)

### Community 512 - ".setAttribute"
Cohesion: 0.25
Nodes (7): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, String

### Community 515 - "RD"
Cohesion: 0.24
Nodes (8): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8, .body

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
Cohesion: 0.18
Nodes (5): Network, HTTPRequestPolicy, Bool, String, UInt16

### Community 529 - "WorktreeAutoIsolateService"
Cohesion: 0.20
Nodes (10): PaneRef, bottom, byID, byIndex, last, left, next, previous (+2 more)

### Community 530 - "HarnessChrome"
Cohesion: 0.22
Nodes (9): MatchSource, ownProcess, wrapperLaunch, RawMatch, WrapperOptionBehavior, keepScanning, matchValue, skipValue (+1 more)

### Community 532 - "OpenClaw → Kouen"
Cohesion: 0.25
Nodes (8): CodingKeys, cols, createdAt, dataBase64, rows, timeMs, type, version

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

### Community 539 - "SavedLayoutIPCDaemonTests"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 541 - ".init"
Cohesion: 0.27
Nodes (3): DaemonReconnectPolicy, TimeInterval, DaemonReconnectPolicyTests

### Community 542 - ".init(from:)"
Cohesion: 0.22
Nodes (3): ClaudeSessionModeTests, URL, Void

### Community 543 - ".bufferLine"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 544 - "CodingKeys"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 547 - "NSObject"
Cohesion: 0.24
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 548 - ".encode"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 549 - ".init(from:)"
Cohesion: 0.29
Nodes (3): JobResultSheetView, .body, String

### Community 550 - ".init(hex:)"
Cohesion: 0.09
Nodes (18): SliderRow, .body, .displayValue, ClosedRange, Double, String, SettingsFileSearchSection, .body (+10 more)

### Community 551 - ".init(red:green:blue:alpha:)"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 552 - "PaneLabelDaemonTests"
Cohesion: 0.14
Nodes (5): CKouenSys, PtyError, launchFailed, ShellLaunchProfile, .argv

### Community 553 - "harness.resource"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Key spec syntax, Kouen keybindings, Persistence (+1 more)

### Community 555 - "code:bash (harness view <file>                        # syntax-highligh)"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 556 - "MobileBridgeSpawnTests"
Cohesion: 0.33
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

### Community 557 - ".viewWillMove"
Cohesion: 0.22
Nodes (7): KouenCLIPaths, .applicationSupport, .binDirectory, .installedCLIPath, .installedDaemonPath, .launchAgentURL, URL

### Community 560 - "AgentNotification"
Cohesion: 0.20
Nodes (6): aD(), crn, ELt(), n2e(), PF(), urn

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

### Community 573 - "tHe"
Cohesion: 0.38
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

### Community 577 - "concurrency.md"
Cohesion: 0.23
Nodes (6): ProjectGroupResolver, String, String, .trimmed, AgentTitleInference, Bool

### Community 578 - "TaskDashboardBody"
Cohesion: 0.25
Nodes (3): SessionStore, DispatchWorkItem, TimeInterval

### Community 580 - "ViInputMode"
Cohesion: 0.39
Nodes (5): AutomationSummary, Bool, Date, String, UUID

### Community 584 - "GUt"
Cohesion: 0.03
Nodes (138): aJ(), Ame(), aQ(), aQt(), aUe(), aXt(), AYt(), bme() (+130 more)

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
Cohesion: 0.11
Nodes (13): CornerInfo, KouenSplitView, .dividerColor, .dividerThickness, DispatchWorkItem, Double, NSColor, NSRect (+5 more)

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

### Community 615 - "fences"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 621 - "ViEngine"
Cohesion: 0.40
Nodes (3): calculate(), constructor(), mBt

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

### Community 683 - ".init(coder:)"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

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

### Community 695 - "FormatContext"
Cohesion: 0.15
Nodes (4): PaletteCommandConfig, .body, AttributedString, NSColor

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
- **2390 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+2385 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1127 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Work-memory lessons

**Known dead ends** — questions that led nowhere; don't re-derive.
- "KouenPreviewHome environment key daemon launch at startup" -> `KouenPaths`

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `GitPanelView.swift` to `.setAttribute`, `EngineConformanceTests`, `AgentNotchRootView`, `Command`, `LSPMessage`, `.daemonIsStale`, `PerformanceBenchmarks`, `.viewDidLoad`, `Changed`, `.encodeAndWait`, `KittyKeyboardTests`, `HarnessTerminalSurfaceView`, `.applyPreedit`, `WorktreeAutoIsolateService`, `HarnessUILibrary`, `HarnessChrome`, `VTParser`, `HarnessTerminalSurfaceView`, `CopyModeAction`, `SplitPaneCoordinator`, `.request`, `WorktreeManager`, `Harness tmux-style capabilities`, `RGBColor`, `AgentNotification`, `Added`, `Notification`, `Sendable`, `.addTab`, `Equatable`, `DaemonClient`, `.init`, `code:bash (harness chat "Use the project map first, then inspect this r)`, `.encode`, `code:bash (swift build)`, `TerminalColorGamut`, `HarnessSettings`, `HarnessSidebarPanelViewController.swift`, `RenderSchedulerTests`, `HarnessOverlayBackground`, `HarnessTerminalSurfaceView.swift`, `.buildCommand`, `MobileBridgeSpawnTests`, `HookEvent`, `Added`, `Fixed`, `Added`, `HarnessSplitView`, `TabCell`, `NSPanel`, `BellScanState`, `PasteBufferStore`, `ShellIntegrationTests`, `3.2 สิ่งที่ implement แล้ว`, `ComposedCell`, `HarnessCLI+Server.swift`, `Phase67Tests`, `.text`, `ShellIntegration`, `String`, `Completed Plans Archive`, `.compose`, `ViInputMode`, `worktree_isolation_cli.robot`, `README.md`, `lrn`, `HarnessDesign`, `Added`, `main.swift`, `.firstMatch`, `LSPDiagnostic`, `TerminalGridCell`, `HarnessPaths`, `SessionCoordinator`, `Harness as a terminal multiplexer`, `.cursorPos`, `MetalRendererTests`, `fut`, `code:bash (# Terminal 1: Create workspace with long-running job)`, `AttachInputBatcher`, `shim.c`, `Harness Usage`, `PaneContainerView`, `4. Technical Architecture`, `.dispatch`, `.memoURL`, `.overrideRootRaw`, `DaemonLauncher`, `ScriptRuntime.swift`, `SpecialKey`, `Changelog`, `domain-design.md`, `AgentNotchViewModel`, `.showWorkspaceMenu`, `DamageTrackingTests`, `SoftIconButton`, `.makeSnapshot`, `HarnessGridTerminal`, `.encode`, `SessionGroup`, `PaneNode`, `WorkspaceFileTreeView`, `Changed`, `ViEngine`, `E9`, `String`, `HistoryRingBuffer`, `.path`, `GlyphAtlas`, `code:block1 (SessionCoordinator.snapshot ──┐)`, `TerminalScrollbarView`, `Harness`, `.install`, `AgentHookInstaller`, `code:js (// ~/.config/harness/init.js)`, `.startWatching`, `ActivePaneService`, `Added`, `.parse`, `CopyModeGridSource`, `How to use Harness from the terminal only (no GUI)`, `Jcn`, `FileTreeWatcher`, `EnvironmentStore`, `HarnessDaemonToolsTests`, `I$e`, `.evaluate`, `Int`, `ThaiCombiningMarkTests`, `PaneLabelDaemonTests`, `MatchCategory`, `AmbientBackground`, `What You Must Do When Invoked`, `TerminalFindBar`, `CommandPromptController`, `ActiveTabCloseDisposition`, `AgentTableEntry`, `TriState`, `.decodeKeySpec`, `codex`, `Added`, `.moveActiveSession`, `FormatContext`, `P25 — iOS/iPadOS Support`, `LSPServerRegistry`, `targets`, `Error`, `BrowserPaneView`, `AppDelegate`, `ScriptRuntime`, `MTLCommandQueue`, `BinaryInstaller`, `ResizeHUDView`, `Feature Provenance — harness-terminal`, `AgentSessionSummary`, `.windowedRecords`, `code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)`, `MCP Server (harness-mcp)`, `PaletteModel`, `From tmux`, `CopyModeState`, `HarnessCLI`, `.testDataFrameEncodeVsJSONBase64Output`, `PaneTarget`, `String`, `CellColorResolverTests`, `GridCompositor`, `Prompt`, `qte`, `AgentNotchRowSummary`, `ANSIPalette`, `CellColorResolver`, `FileChangeWatcher`, `.decide`, `HarnessGridTerminalTests`, `.scan`, `WorkbenchCommand`, `TerminalBlockStoreTests`, `PaneBorderStatus`, `Added`, `AgentBridge`, `.make`, `ThemeDocumentTests`, `.renderFixture`, `ReflowPreviewTests`, `Split Right`, `release-hotfix.sh`, `GitMetadataProvider`, `.install`, `.constructor`, `code:bash (harness-cli install-hooks claude-code)`, `.effectiveStatusLineEnabled`, `DecodedWSFrame`, `.performInstall`, `code:bash (# Old (agent-specific):)`, `DefaultTerminalManager`, `menu`, `SGRMouseEvent`, `P8: macOS 27 Golden Gate Adoption`, `BlockTintOverlay`, `FormatColor`, `code:bash (harness-cli install-hooks hermes)`, `AgentHookStrategy`, `Process`, `GitHubCLIClient`, `jobs`, `PaneNode`, `RegressionBugFixTests`, `ViPathTokenTests`, `Send Ex Command`, `FrameSignposter`, `AgentSnapshot`, `Terminal AI Chat (⌘I inline overlay)`, `Memory — harness-terminal`, `code:bash (# In a Harness pane:)`, `space`, `DesktopNotifier`, `WorkspaceSymbolIndex`, `url`, `.theme`, `README.md`, `$3`, `Added`, `.makeModel`, `run.sh`, `TimeInterval`, `CSIParams`, `.isWindowFullScreen`, `FileViewerViewController`, `[3.2.0] - 2026-06-16`, `DaemonLifecycleTests`, `Background Polling & Snapshot Fanout — P22`, `Architecture Decisions — harness-terminal`, `GPU Animation Pattern — Layout Once, GPU Paints`, `.deepMerge`, `[3.5.1] - 2026-06-20`, `OcclusionTests`, `State`, `FormatStyledSegment.swift`, `generate-cheatsheet.js`, `[2.2.4] - 2026-06-11`, `P13 — Embedded Browser Pane (cmux parity)`, `PromptQueue`, `terminal_stress_runner.py`, `NSTextField Leak in BoardViewController (P20 Performance)`, `INDEX.md`, `Agent hooks`, `SKILL-LOG.md`, `User Profile`, `HarnessCLITests`, `AppKit + Metal Patterns`, `generate-app-icon.sh`, `Files`, `preview.sh`, `PresentAttempt`, `AgentIconRenderer`, `main.swift`, `Session/Tab/Pane Hierarchy & Top Bar (CASE-028)`, `Task 1: Redesign Session Sidebar`, `go.json`, `markdown.json`, `typescript.json`, `.parseDiffHunks`, `BoardCardView`, `PathToken`, `RemoteHostStore`, `mobile_bridge_pairing_bugs.robot`, `RunState`, `.deinit`, `.moveSelection`, `PresentAttempt`, `HarnessOnboarding`, `String`, `SecureInputMonitor`, `CopilotAdapter`, `bC`, `SurfaceIO`, `ccRunInfo`, `.testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache`, `zO`?**
  _High betweenness centrality (0.280) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `Fixed` to `ScriptRuntime.swift`, `code:bash (swift build)`, `GitPanelView.swift`, `browserGoBack`, `HarnessTerminalSurfaceView`, `confirmBefore`, `.rects`, `.script`, `SettingsRemoteView`, `copyMode`, `Added`, `run.sh`, `.renderFixture`, `.encodeMouse`, `SplitPaneCoordinator`, `Harness as a terminal multiplexer`, `MatchCategory`?**
  _High betweenness centrality (0.198) - this node is a cross-community bridge._
- **Why does `ht()` connect `.script` to `CodingKey`, `.handleNormal`?**
  _High betweenness centrality (0.102) - this node is a cross-community bridge._
- **Are the 19 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `OutputTriggerMatcher`) actually correct?**
  _`KouenTerminalSurfaceView` has 19 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _2410 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.00582645209249995 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.012535924840665865 - nodes in this community are weakly interconnected._