# Graph Report - browser-reload  (2026-10-18)

## Corpus Check
- 918 files · ~1,036,886 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 19892 nodes · 57085 edges · 2647 communities (1515 shown, 1132 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8555 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `7119f160`
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
9. `KouenCLI` - 210 edges
10. `DaemonClient` - 209 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 186 areas (206 edges)
2. `Command` - bridges 102 areas (108 edges)
3. `t()` - bridges 83 areas (253 edges)
4. `AgentKind` - bridges 81 areas (178 edges)
5. `KouenTerminalSurfaceView` - bridges 77 areas (345 edges)
6. `IPCResponse` - bridges 77 areas (101 edges)
7. `KouenPaths` - bridges 73 areas (150 edges)
8. `NSView` - bridges 68 areas (189 edges)
9. `SessionCoordinator` - bridges 67 areas (235 edges)
10. `SurfaceRegistry` - bridges 67 areas (224 edges)

## Surprising Connections (you probably didn't know these)
- `.selectedHost` --references--> `RemoteHost`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRemoteView.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/RemoteHostsService.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.selectWorkspace(byIndex:)` --references--> `SessionSnapshot`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/SessionCoordinator.swift → Packages/KouenIPC/Sources/KouenIPC/SessionSnapshot.swift
- `.heightArg` --calls--> `keys`  [INFERRED]
  Packages/KouenTerminalEngine/Sources/KouenTerminalEngine/Images/ITerm2InlineImage.swift → Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRootView.swift

## Import Cycles
- None detected.

## Communities (2647 total, 1132 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.01
Nodes (577): _1n(), _2t(), _3n(), _5e(), _5n(), _6e(), _9e(), a2() (+569 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.02
Nodes (348): pe(), X(), A(), code(), R(), a(), ae(), aen() (+340 more)

### Community 2 - ".handleNormal"
Cohesion: 0.01
Nodes (356): l, _3e(), _4n(), _7n(), _8n(), a0(), a1t(), a6() (+348 more)

### Community 3 - "Changed"
Cohesion: 0.02
Nodes (279): e(), f(), t(), z(), _1t(), a6e(), a6n(), aae() (+271 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.02
Nodes (262): V, _6n(), a5n(), a7n(), adn(), Af(), ag(), ah() (+254 more)

### Community 5 - "IPCRequest"
Cohesion: 0.04
Nodes (127): aJ(), Ame(), aQ(), aQt(), aUe(), aXt(), AYt(), bme() (+119 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.05
Nodes (44): AgentBridge, AgentTarget, Bool, String, SurfaceID, .onCurrentCWD, .onCurrentFile, LinePos (+36 more)

### Community 7 - "Command"
Cohesion: 0.04
Nodes (38): TerminalGridCell, Bool, CAMetalDrawable, NSEvent, String, Any, Bool, CGFloat (+30 more)

### Community 8 - "LSPMessage"
Cohesion: 0.07
Nodes (17): Int, CSIParams, .count, HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor (+9 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.06
Nodes (24): tab, .tab(for:), OSCTerminatorMatch, RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), ScrollbackEntry, ScrollbackReplaySegment, ShellLaunchProfile (+16 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.07
Nodes (20): TerminalGridCell, TerminalEmulator, .captureLines(joinWrapped:), .feed(_:), .promptRows, .readGrid(scrollbackOffset:), ImageProtocolTests, String (+12 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.04
Nodes (56): amn(), B0, BBe(), cg(), ch(), cvt(), d1t(), dV() (+48 more)

### Community 12 - "Changed"
Cohesion: 0.06
Nodes (23): DaemonCommandExecutor, Command, .init(forTesting:), UUID, Void, BellScanState, esc, normal (+15 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.09
Nodes (12): .receive(_:), DispatchSemaphore, FluidityBenchmarks, NSWindow, String, UInt64, KouenTerminalSurfaceWorkerTests, Bool (+4 more)

### Community 14 - "VTParser"
Cohesion: 0.14
Nodes (13): TerminalDamage, RenderColor, MetalRendererTests, .makeRenderer(device:atlasSize:atlasMaxPages:), RenderedFixture, Bool, MTLDevice, MTLTexture (+5 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.08
Nodes (23): IndexingIterator, LayoutTemplate, surfaceID, SessionEditor, .addSurface(to:paneID:surfaceID:cwd:), .split(node:targetPaneID:direction:paneCount:before:), .split(node:targetPaneID:with:direction:beforeTarget:), .surfaceID(forPaneID:) (+15 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.10
Nodes (10): KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), SpawnedAgentSurface, Bool, ISO8601DateFormatter, PaneLeaf, Result, String (+2 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.09
Nodes (39): MTLClearColor, MTLCommandBuffer, MTLLibrary, MTLRenderCommandEncoder, MTLRenderPipelineState, BgInstance, CursorCacheKey, .invertsGlyph (+31 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.09
Nodes (34): .saveRecordsBatch(_:), CachedSessionEntry, AgentHistoryScanner, .parseAntigravityTranscript(sessionID:fileURL:), .parseAntigravityTranscript(sessionID:fileURL:toIndex:), .parseClaudeTranscript(fileURL:), .parseClaudeTranscript(fileURL:toIndex:), .parseCodexTranscript(fileURL:surfaceTag:ftsIndex:) (+26 more)

### Community 19 - "SpecialKey"
Cohesion: 0.08
Nodes (24): DaemonClient, .start(onResponse:onEnd:), Int32, String, TimeInterval, UUID, Void, ClaudeCodeHarnessIPCTests (+16 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.06
Nodes (34): ClientRecord, CountBox, DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed (+26 more)

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.06
Nodes (33): NSView, NSFont, SessionDividerRowView, .init(coder:), .init(frame:), SessionGroupHeaderRowView, .init(coder:), .init(frame:) (+25 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.07
Nodes (38): DecodedImage, .byteCount, UInt8, .currentSelectionRegion, ClosedRange, String, BlockSelection, CursorRender (+30 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.11
Nodes (17): .exit, String, String, String, String, KouenCLI, SessionID, String (+9 more)

### Community 24 - ".request"
Cohesion: 0.07
Nodes (25): UInt16, Data, DecodedReplyFrame, output, reply, DecodedRequestFrame, input, request (+17 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.09
Nodes (12): PaneBorderStatus, Bool, Command, DispatchWorkItem, PaneID, PaneLeaf, PaneNode, PaneRect (+4 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.08
Nodes (27): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+19 more)

### Community 27 - "RGBColor"
Cohesion: 0.05
Nodes (31): CornerInfo, EditorDividerView, HitTestPassthroughView, KouenSplitView, .dividerColor, .dividerThickness, .init(coder:), PaneDragGripView (+23 more)

### Community 28 - ".parse"
Cohesion: 0.07
Nodes (24): DisplayLinkTarget, MainSplitViewController, .setSidebarVisible(_:), .setSidebarVisible(_:animated:), SplitChromeDelegate, .sidebarMaxWidth, .sidebarMinWidth, .splitView(_:constrainMaxCoordinate:ofSubviewAt:) (+16 more)

### Community 29 - "Added"
Cohesion: 0.06
Nodes (21): PluginLoader, String, ScriptAPI, ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool (+13 more)

### Community 30 - "Notification"
Cohesion: 0.07
Nodes (36): DaemonSubscription, .start(onData:onEnd:buffered:), Bool, UInt64, decodeBoundedCString(), makeUnixStreamSocket(), setNoSigPipe(), CChar (+28 more)

### Community 31 - "Sendable"
Cohesion: 0.07
Nodes (33): KeybindingsService, Bool, Command, String, KeySpec, .init(from:), Decoder, Binding (+25 more)

### Community 32 - ".addTab"
Cohesion: 0.08
Nodes (11): SessionGroup, KouenSidebarPanelViewController, NSMenuItem, SessionGroup, String, NSMenu, NSMenuItem, SessionGroup (+3 more)

### Community 33 - "Equatable"
Cohesion: 0.08
Nodes (41): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+33 more)

### Community 34 - "DaemonClient"
Cohesion: 0.04
Nodes (63): _4e(), a4e(), aOn(), cae(), cAn(), cvn(), e2n(), e3() (+55 more)

### Community 35 - "MenuTarget"
Cohesion: 0.06
Nodes (42): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, .init(from:), .init(id:name:baseURL:modelID:), ModelProvider (+34 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.11
Nodes (12): .agentColorBinding, colors, PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Double, String (+4 more)

### Community 37 - "String"
Cohesion: 0.11
Nodes (54): DirectoryListResponse, Encodable, ExpressibleByStringLiteral, FileReadResponse, authorizedReadPath(), buildSuggestPrompt(), cancelConnection(), Sendable (+46 more)

### Community 38 - "code:bash (swift build)"
Cohesion: 0.06
Nodes (29): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+21 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.07
Nodes (18): DiffLineType, added, deleted, modified, Bool, DispatchWorkItem, NSEvent, NSPopover (+10 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.16
Nodes (7): AnyCodable, JSONRPCError, Bool, Int32, Pipe, String, ToolRegistry

### Community 41 - "CodingKeys"
Cohesion: 0.09
Nodes (8): Divergence, Bool, String, TimeInterval, WorktreeInfo, WorktreeManager, String, WorktreeIsolationTests

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.06
Nodes (43): SettingsAppearanceView, .autoTheme, .body, .themeSection, Bool, ColorHexRow, .body, .colorBinding (+35 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.07
Nodes (36): IssueKeychainStore, Bool, String, IssuePriority, .color, high, low, medium (+28 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.07
Nodes (21): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+13 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.07
Nodes (46): Codable, BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserRequestPayload, close, cookies (+38 more)

### Community 46 - ".buildCommand"
Cohesion: 0.13
Nodes (11): .addSurface(tabID:paneID:), .tab(containingPaneID:), .tabIndex(surfaceKey:), .tabIndex(workspaceID:tabID:), Bool, Date, SessionID, String (+3 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.09
Nodes (13): SessionCoordinator, .selectWorkspace(_:), Bool, Double, PaneID, PaneNode, SplitDirection, String (+5 more)

### Community 48 - "HookEvent"
Cohesion: 0.11
Nodes (18): Process, SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, SSHTunnelManager (+10 more)

### Community 49 - "DaemonServer"
Cohesion: 0.08
Nodes (24): Error, LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed, serverNotExecutable, AsyncStream (+16 more)

### Community 50 - "Added"
Cohesion: 0.06
Nodes (35): Executor, Hook, HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane (+27 more)

### Community 51 - ".keyEvent"
Cohesion: 0.07
Nodes (20): OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, .event(_:), .interval(_:_:), Bool (+12 more)

### Community 52 - "Fixed"
Cohesion: 0.07
Nodes (16): ContextResolutionEngine, Bool, String, Bool, String, TokenGuard, EnvironmentStore, Persisted (+8 more)

### Community 53 - "Added"
Cohesion: 0.06
Nodes (43): AnyTransition, AnyView, Color, .hexString, AgentNotchRootView, .body, .bottomRadius, .closedAccessibilityLabel (+35 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.08
Nodes (28): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary, RowKind (+20 more)

### Community 55 - "TabCell"
Cohesion: 0.06
Nodes (22): .effectiveResumeCommand(mode:), AgentLaunchCommands, AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand (+14 more)

### Community 56 - "NSPanel"
Cohesion: 0.08
Nodes (21): AgentRoutingResolver, String, AgentRoutingRule, Kind, path, stack, Bool, Date (+13 more)

### Community 57 - "BellScanState"
Cohesion: 0.09
Nodes (20): AnyObject, DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor (+12 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.08
Nodes (22): CGImage, CoreGraphics, CoreText, ImageIO, KouenCopyMode, KouenTerminalEngine, KouenTerminalRenderer, KouenTheme (+14 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.10
Nodes (19): .snapshot, InputGate, .siblings, ReconnectLatch, .isTripped, SurfaceIO, .currentSubscription, Bool (+11 more)

### Community 60 - "ViEngine"
Cohesion: 0.08
Nodes (30): .filteredJobs, MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith (+22 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 62 - "ComposedCell"
Cohesion: 0.11
Nodes (20): AgentHistoryFTSIndex, .deleteSession(sessionID:), .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:surfaceTag:topicSegments:), .needsReindex(sessionID:mtime:fileSize:), .pruneMissingSessions(validTranscriptPaths:), .saveRecord(_:mtime:fileSize:), .search(query:limit:), .searchRanked(query:limit:includeSnippet:) (+12 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.06
Nodes (40): ButtonStyle, CommandRow, .body, GlassCard, .body, GlassPrimaryButtonStyle, GlassSecondaryButtonStyle, GlassSmallButtonStyle (+32 more)

### Community 64 - ".text"
Cohesion: 0.09
Nodes (31): TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid, .gridOriginPointsX (+23 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.05
Nodes (49): al(), b1t(), bdn(), bIn(), c4n(), d7e(), d9n(), dhn() (+41 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.10
Nodes (18): .requestDaemon(_:), .selectWorkspace(byIndex:), .syncFromDaemon(metadataOnly:), ActiveTabCloseDisposition, session, tab, window, workspace (+10 more)

### Community 67 - "String"
Cohesion: 0.06
Nodes (41): .init(entry:), FontSize, IconSize, KouenMotion, Radius, Shadow, elevation1, elevation2 (+33 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.10
Nodes (21): OptionStore, OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Scope, pane (+13 more)

### Community 69 - ".compose"
Cohesion: 0.07
Nodes (46): blockTokens(), br(), checkbox(), codespan(), de(), del(), em(), html() (+38 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.07
Nodes (36): ImagePlacementSnapshot, SemanticMark, Bool, String, UInt8, TerminalCellWidth, normal, spacerTail (+28 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.08
Nodes (23): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSEvent (+15 more)

### Community 72 - "XCTestCase"
Cohesion: 0.09
Nodes (23): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, IssueInfo (+15 more)

### Community 73 - "README.md"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 74 - "[2.6.0] - 2026-06-13"
Cohesion: 0.07
Nodes (17): KouenCLITests, CLIInstallLocator, DetachKeys, absent, invalid, parsed, OptionalUUID, absent (+9 more)

### Community 75 - "OptionStore"
Cohesion: 0.07
Nodes (18): Kind, primary, secondary, KouenPillButton, .init(title:kind:), .isHovered, .isPressed, NSColor (+10 more)

### Community 76 - ".parse"
Cohesion: 0.07
Nodes (28): AgentHistoryDateGroup, older, .sortOrder, thisWeek, today, yesterday, AgentSessionHistoryModel, .extraRecordsShown (+20 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.08
Nodes (32): CGFloat, FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView (+24 more)

### Community 78 - "Added"
Cohesion: 0.05
Nodes (33): CaseIterable, Mode, compatible, kouen, TerminalIdentity, ExperienceMode, agent, .displayName (+25 more)

### Community 79 - "HarnessDesign"
Cohesion: 0.08
Nodes (26): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+18 more)

### Community 80 - "Agent handbook — Harness (extended reference)"
Cohesion: 0.07
Nodes (20): AgentUsage, .contextTokens, .init(from:), .init(inputTokens:outputTokens:cacheReadTokens:cacheWriteTokens:thinkingTokens:totalCostUSD:), .shortSummary, CodingKeys, cacheReadTokens, cacheWriteTokens (+12 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.13
Nodes (16): ProjectCategory, .init(from:), .init(id:name:sourceFolder:excludedPaths:), ProjectEntry, .id, ProjectStore, .init(userDefaults:), .init(userDefaultsSuite:) (+8 more)

### Community 82 - ".firstMatch"
Cohesion: 0.08
Nodes (14): NSRangePointer, Any, NSAttributedString, NSRange, NSRect, String, UInt64, .color(_:) (+6 more)

### Community 83 - "LSPClient"
Cohesion: 0.09
Nodes (18): PendingVersionBanner, welcome, whatsNew, State, Bool, String, URL, VersionBannerStore (+10 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.11
Nodes (16): .body, json, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter, Any (+8 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.09
Nodes (15): BrowserIntegrationController, PaneID, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), PaneNode, String, SurfaceID, PaneLifecycleManager (+7 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.05
Nodes (38): Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions, Logical Design, P41 — Automations, Strategic Design, Tactical Design (+30 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.06
Nodes (21): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+13 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.10
Nodes (22): ArtifactKind, html, image, markdown, text, AutomationsFleetModel, .load(detectScheduledRuns:), AutomationSource (+14 more)

### Community 89 - ".cursorPos"
Cohesion: 0.08
Nodes (18): NSScrollView, NSWindow, Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent (+10 more)

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.09
Nodes (13): ParsedShortcut, .displayString, PrefixKeymap, Any, Bool, NSEvent, String, TimeInterval (+5 more)

### Community 91 - "TerminalModes"
Cohesion: 0.06
Nodes (12): KouenCLI, SQLite3, HistorySearchQueryTests, MemoCommandTests, URL, TaskCommandTests, AntigravityTranscriptTurnsTests, ClaudeHumanTextTests (+4 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.08
Nodes (29): BrowserLeaf, CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf (+21 more)

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.15
Nodes (9): StringKind, apc, dcs, UInt8, UnsafeBufferPointer, VTParser, .feed(_:), VTParserHandler (+1 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.15
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 95 - "shim.c"
Cohesion: 0.11
Nodes (15): FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect, String, URL (+7 more)

### Community 96 - "Harness Usage"
Cohesion: 0.13
Nodes (5): .setupPrompt, hooks, AgentHookInstallerTests, String, URL

### Community 97 - "PaneContainerView"
Cohesion: 0.18
Nodes (11): SwarmSpawnSpec, CallRecorder, .cancelCalls, .closeCalls, .harnessCalls, .surfaceCalls, SwarmWorkerManagerTests, Bool (+3 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 99 - ".dispatch"
Cohesion: 0.08
Nodes (23): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, .acceptsFirstResponder (+15 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.07
Nodes (17): NSResponder, NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent (+9 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.14
Nodes (18): CommandParseError, .description, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand (+10 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.11
Nodes (7): Bool, Range, Set, String, URLDetection, StringProtocol, EngineConformanceTests

### Community 103 - "AnyCodable"
Cohesion: 0.11
Nodes (26): ColorKind, .base, bg, fg, underline, CompositorPane, GridCompositor, .render(panes:status:statusSegments:) (+18 more)

### Community 104 - "Recipe"
Cohesion: 0.09
Nodes (31): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+23 more)

### Community 105 - "Changelog"
Cohesion: 0.08
Nodes (27): .body, FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body (+19 more)

### Community 106 - "domain-design.md"
Cohesion: 0.14
Nodes (15): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+7 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.16
Nodes (12): FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID, KouenFeature (+4 more)

### Community 108 - ".resolve"
Cohesion: 0.10
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.10
Nodes (17): BoxDrawing, Kind, arms, dashH, dashV, halfDown, halfLeft, halfRight (+9 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.10
Nodes (21): .pairedAlreadyBanner, .pairingQRPanel, FleetJobItem, .isActive, .launchAgentScriptPath, .statusDisplay, AutomationsFleetView, .automationsList (+13 more)

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.13
Nodes (6): AgentTableEntry, Bool, Set, String, .effectiveAgentKind, AgentDetectorTests

### Community 112 - ".makeSnapshot"
Cohesion: 0.06
Nodes (36): a0n(), aA(), eAn(), ebt(), eht(), Em(), eMt(), ewn() (+28 more)

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.08
Nodes (21): DaemonClientActor, TimeInterval, DaemonSessionError, daemonError, .description, unexpectedResponse, DaemonSessionService, .endpoint (+13 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.08
Nodes (25): keys, Bool, ImageLimits, Bool, ITerm2InlineImage, .heightArg, .preserveAspectRatio, .widthArg (+17 more)

### Community 115 - ".encode"
Cohesion: 0.08
Nodes (11): TimeInterval, Logger, AgentHandoffBuilder, Bool, String, RemoteControlURLProvider, Bool, URL (+3 more)

### Community 116 - "SessionGroup"
Cohesion: 0.14
Nodes (13): PickerItem, .groupLabel, historyBlock, .id, recipe, .searchableText, RecipePickerModel, NSWindow (+5 more)

### Community 117 - "PaneNode"
Cohesion: 0.11
Nodes (28): AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem, fetchGitStatus() (+20 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.14
Nodes (14): NaturalLanguage, MatchLocationInfo, AgentHistorySearch, Hit, IDFCache, Bool, Double, String (+6 more)

### Community 119 - "Harness command reference"
Cohesion: 0.09
Nodes (13): input, ClaudeSessionLocator, ClaudeTranscriptLine, Role, assistant, user, Any, Bool (+5 more)

### Community 120 - "Added"
Cohesion: 0.09
Nodes (22): PaletteMode, errors, grep, normal, PaletteModel, .isGrepMode, .placeholder, PalettePanel (+14 more)

### Community 121 - "Changed"
Cohesion: 0.12
Nodes (19): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerFooter, .body, DirectoryPickerModel (+11 more)

### Community 122 - "ViEngine"
Cohesion: 0.08
Nodes (26): LocalizedError, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display, found (+18 more)

### Community 123 - "Pipe"
Cohesion: 0.08
Nodes (20): SGRMouse, SGRMouseEvent, Bool, PaneRect, UInt8, MouseButton, left, middle (+12 more)

### Community 124 - "String"
Cohesion: 0.10
Nodes (13): .effectiveResumeCommand(claudeMode:), LiveClaudeAgentEntry, .placement, ClaudeSessionMode, ClaudeCloudSessionStore, Entry, Date, String (+5 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.13
Nodes (15): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+7 more)

### Community 126 - ".path"
Cohesion: 0.10
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 127 - "GlyphAtlas"
Cohesion: 0.14
Nodes (20): ComposedCell, .asGridCell, .init(_:), .init(codepoint:fg:bg:underlineColor:bold:dim:italic:underline:blink:inverse:invisible:strikethrough:overline:), .scalar, .sgr, CompositorPane, GridCompositor (+12 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.12
Nodes (12): ANSIPalette, RGBColor, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors, Bool, Double (+4 more)

### Community 129 - "SwiftUI"
Cohesion: 0.15
Nodes (8): MutationResult, RemoteHost, RemoteHostStore, Bool, String, RemoteHostStoreTests, String, URL

### Community 130 - "Harness"
Cohesion: 0.12
Nodes (6): GitPanelView, .isHidden, Any, DispatchWorkItem, NSMenuItem, UnsafeMutableRawPointer

### Community 131 - ".install"
Cohesion: 0.10
Nodes (14): NotchMaskAnimator, Bool, CGFloat, CGRect, NotchPanel, .canBecomeKey, .canBecomeMain, Bool (+6 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.11
Nodes (12): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+4 more)

### Community 133 - ".load"
Cohesion: 0.14
Nodes (12): MarkdownPreviewView, .webView(_:decidePolicyFor:decisionHandler:), .webView(_:didFinish:), Bool, MainActor, Sendable, String, URL (+4 more)

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.12
Nodes (20): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), GlyphKey (+12 more)

### Community 135 - "CommandTarget"
Cohesion: 0.11
Nodes (14): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+6 more)

### Community 136 - ".startWatching"
Cohesion: 0.10
Nodes (20): Coordinator, DiffAnalysis, DiffFileItem, DiffFileStatus, added, .color, deleted, modified (+12 more)

### Community 137 - "ActivePaneService"
Cohesion: 0.11
Nodes (13): FileFuzzyMatcher, FileSearchRootScanner, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool (+5 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.08
Nodes (12): Bool, NSDraggingInfo, NSDragOperation, NSCursor, NSPasteboard, URL, SurfaceColorProviderState, NSPasteboard (+4 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.12
Nodes (16): AgentSessionHistoryView, .body, .footerView, HistoryMenuProxy, Any, Bool, CGFloat, Date (+8 more)

### Community 140 - "Added"
Cohesion: 0.10
Nodes (15): .init(frame:), ChromeBackdrop, .init(coder:), .init(role:), ChromeRole, sidebar, tabBar, KouenDesign (+7 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, S (+2 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.15
Nodes (14): Darwin, Foundation, Glibc, KouenCore, PtyError, launchFailed, daemonLog(), detectStaleInstance() (+6 more)

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.09
Nodes (23): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+15 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 145 - "AsciiFastPathTests"
Cohesion: 0.13
Nodes (10): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String (+2 more)

### Community 146 - "DecodedImage"
Cohesion: 0.15
Nodes (10): ScrollbackFile, .highWater, Bool, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 147 - "FileTreeWatcher"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 148 - "TriState"
Cohesion: 0.08
Nodes (26): aie(), arc(), b2e(), bezierCurveTo(), closePath(), cRe(), cZ(), e0n() (+18 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.20
Nodes (10): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, automations (+2 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.14
Nodes (11): String, ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID, String (+3 more)

### Community 151 - ".evaluate"
Cohesion: 0.14
Nodes (16): FileNode, GitStatusType, added, deleted, modified, renamed, unmodified, untracked (+8 more)

### Community 152 - "Added"
Cohesion: 0.11
Nodes (19): CodingKeys, error, id, jsonrpc, method, params, result, LSPDiagnostic (+11 more)

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.11
Nodes (16): StatusLineView, .init(coder:), Bool, CGFloat, FormatColor, Never, NSAttributedString, NSCoder (+8 more)

### Community 154 - "LiveResizeTests"
Cohesion: 0.15
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 155 - "Int"
Cohesion: 0.18
Nodes (6): CopyModeReducerTests, FakeGrid, .totalLines, Set, String, TerminalGridCell

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.14
Nodes (12): AgentDetection, AgentDetector, MatchSource, ownProcess, wrapperLaunch, RawMatch, Date, Int32 (+4 more)

### Community 157 - "Added"
Cohesion: 0.09
Nodes (4): Bool, DispatchWorkItem, NSWindow, KouenTerminalSurfaceFocusTests

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.14
Nodes (15): .windowSection, KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:fileSearchRoots:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:), .scrollbackLines, ClaudeSessionMode, Decoder, Double (+7 more)

### Community 159 - "MatchCategory"
Cohesion: 0.14
Nodes (9): CheckpointInfo, CheckpointManager, Bool, Date, String, CheckpointManagerTests, String, String (+1 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.13
Nodes (13): MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem, SessionGroup (+5 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.16
Nodes (15): ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool, Command (+7 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.16
Nodes (11): Equatable, PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab (+3 more)

### Community 163 - "Workspace"
Cohesion: 0.17
Nodes (10): SSETransportTests, UInt16, SSETransport, .isRunning, .listener, Bool, NWConnection, NWListener (+2 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.13
Nodes (9): ThemeImportController, ThemeDocument, FileManager, String, URL, ThemeFileService, String, URL (+1 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.11
Nodes (12): DetachedPaneOverlay, .init(coder:), .init(frame:style:), OutputCoalescer, Style, detached, reconnectingChip, NSCoder (+4 more)

### Community 166 - "LiveSession"
Cohesion: 0.09
Nodes (19): .init(coder:), BrowserProgressLine, .init(coder:), BrowserTabButton, .init(coder:), .init(title:isActive:onSelect:onClose:), DesignModePopoverViewController, .init(coder:) (+11 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.16
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 168 - "Added"
Cohesion: 0.15
Nodes (3): KouenSettingsTests, URL, Void

### Community 169 - "Fixed"
Cohesion: 0.10
Nodes (25): Bool, UInt8, TerminalCellWidth, normal, spacerTail, wide, TerminalCursor, TerminalCursorShape (+17 more)

### Community 170 - "URLDetection"
Cohesion: 0.12
Nodes (10): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+2 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.09
Nodes (19): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+11 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.11
Nodes (19): Array, GroupHeaderRow, .body, PickerItemRow, .badgeText, .iconName, .subtitle, .titleText (+11 more)

### Community 173 - "BoardCard"
Cohesion: 0.10
Nodes (18): OverlayBackground, Context, OverlayBackground, Context, AgentChipView, .init(coder:), .intrinsicContentSize, KouenOverlayBackground (+10 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.11
Nodes (24): .color, Collection, .aggregateBoardStatus, .taskTooltipSummary, TaskSummary.Status, .columnKind, BoardCard, BoardColumn (+16 more)

### Community 175 - "RGBColorTests"
Cohesion: 0.07
Nodes (20): Codex → Kouen, One-line install, What you'll see, Cursor Agent → Kouen, Manual fallback, One-line install, What you'll see, Grok Build → Kouen (+12 more)

### Community 176 - "Added"
Cohesion: 0.14
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 177 - ".rects"
Cohesion: 0.12
Nodes (16): BrowserPaneViewTests, MockWebView, .isLoading, .url, Any, Bool, CGFloat, CGPoint (+8 more)

### Community 178 - "InlineAICompletionView"
Cohesion: 0.14
Nodes (28): Cleanup Test Repo, Close Isolated Session Keeps Dirty Worktree, Close Isolated Session Removes Clean Worktree, Close One Isolated Does Not Affect Another, Close Session With Split Panes Removes Worktree, Create Isolated Session, Create Isolated Session Via CLI, Get Active Pane (+20 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.17
Nodes (3): TerminalGridCell, TerminalGridSnapshot, ThaiCombiningMarkTests

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.12
Nodes (7): KeybindingsStore, .fileURL, URL, KeybindingsStoreTests, URL, Void, String

### Community 181 - "GridCompositorTests"
Cohesion: 0.11
Nodes (18): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+10 more)

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.15
Nodes (7): .removeWorktreeAction(path:), GitResult, Bool, String, ValidateOutcome, WorktreeEntry, GitPanelViewToastErrorSummaryTests

### Community 183 - "LSPServerRegistry"
Cohesion: 0.19
Nodes (11): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, .selectedHost (+3 more)

### Community 184 - "targets"
Cohesion: 0.17
Nodes (12): SurfaceProgressTracker, Bool, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void, Counter (+4 more)

### Community 185 - "SessionSnapshot"
Cohesion: 0.12
Nodes (20): Motion, .entrance, .spring, .standardEase, CAMediaTimingFunction, NSWindowController, NSWindowDelegate, KouenOnboarding (+12 more)

### Community 186 - "Error"
Cohesion: 0.11
Nodes (22): CustomStringConvertible, DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed, atomicWrite() (+14 more)

### Community 187 - "AppDelegate"
Cohesion: 0.07
Nodes (28): Additional `kouen-cli` subcommands, Agent safety CLI (`kouen-cli`), Agents, context and scratchpad, Attaching from a plain terminal, Bindings, Board and attention, Buffers (paste store), Composition (+20 more)

### Community 188 - "BrowserPaneView"
Cohesion: 0.21
Nodes (4): CommandTarget, String, UUID, TargetSpecTests

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.15
Nodes (14): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+6 more)

### Community 190 - "user-stories.md"
Cohesion: 0.12
Nodes (10): AntigravitySessionLocator, AntigravityTranscriptLine, Bool, Int32, NSRegularExpression, String, URL, params (+2 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.14
Nodes (15): Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow, launchStart, StartupMetrics (+7 more)

### Community 192 - "GlyphRasterizer"
Cohesion: 0.22
Nodes (9): FormatContext, FormatString, FormatStyle, Bool, Character, Date, FormatColor, String (+1 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.15
Nodes (14): JSONRPCMessage, notification, request, response, StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength (+6 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.18
Nodes (5): ClaudeCodeHarness, .hasAdapter(for:), Bool, UUID, ClaudeCodeHarnessTests

### Community 195 - "ResizeHUDView"
Cohesion: 0.15
Nodes (18): AgentArt, AgentMark, .body, AgentMarkShape, AgentVectorIcon, Scanner, .atEnd, SVGPath (+10 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.11
Nodes (13): AppKit, NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void (+5 more)

### Community 198 - ".classify"
Cohesion: 0.16
Nodes (11): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+3 more)

### Community 199 - "code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)"
Cohesion: 0.15
Nodes (10): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, Set, SurfaceID (+2 more)

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.17
Nodes (9): SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, SurfaceID, TabID (+1 more)

### Community 202 - "PaletteModel"
Cohesion: 0.10
Nodes (8): SliderRow, .body, .displayValue, ClosedRange, Double, String, KouenSettings, ExperienceModeTests

### Community 203 - "Harness keybindings"
Cohesion: 0.10
Nodes (19): .agentInfo(forWorktreePath:), .agentInfo(forWorktreePath:tabs:), Tab, AgentNotchPeekEvent, Reason, errored, finished, needsInput (+11 more)

### Community 204 - "From tmux"
Cohesion: 0.11
Nodes (17): .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:), .init(frame:) (+9 more)

### Community 205 - "CopyModeState"
Cohesion: 0.12
Nodes (11): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, osc (+3 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.18
Nodes (4): BoardCommandTests, BoardModelTests, Tab, String

### Community 207 - "scheduleRender"
Cohesion: 0.13
Nodes (12): pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal, Int32 (+4 more)

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.09
Nodes (27): A1(), aat(), ast(), bw(), c5n(), d4n(), d6(), f7e() (+19 more)

### Community 209 - "SettingsRemoteView"
Cohesion: 0.13
Nodes (3): String, UInt8, .onResponse

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.15
Nodes (8): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ActivityAssertionManagerTests

### Community 211 - "PaneTarget"
Cohesion: 0.13
Nodes (13): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+5 more)

### Community 212 - ".translate"
Cohesion: 0.10
Nodes (14): Bool, NSEvent, Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint (+6 more)

### Community 213 - "String"
Cohesion: 0.19
Nodes (8): FileTreeNode, NodeRow, .body, .isFocused, .parentDirectory, Bool, Error, String

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.14
Nodes (15): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+7 more)

### Community 215 - ".lines"
Cohesion: 0.19
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 216 - "CellColorResolverTests"
Cohesion: 0.11
Nodes (16): ControlMessage, AgyModelCatalog, Catalog, Date, String, TimeInterval, AgyMobileCommands, String (+8 more)

### Community 217 - "GridCompositor"
Cohesion: 0.24
Nodes (9): CopyModeGridSource, .promptRows, CopyModeReducer, Bool, Character, NSRegularExpression, Range, String (+1 more)

### Community 219 - "Prompt"
Cohesion: 0.11
Nodes (6): .tab(forSurfaceKey:), .surfaceTelemetry, WriteOrigin, automation, human, AgentSessionSummaryTests

### Community 220 - "Section"
Cohesion: 0.14
Nodes (11): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+3 more)

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.10
Nodes (15): LSPMessage, notification, request, response, Decoder, Encoder, KeyedDecodingContainer, LSPTransport (+7 more)

### Community 224 - "CellColorResolver"
Cohesion: 0.13
Nodes (3): KittyKeyboardTests, String, UInt8

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.11
Nodes (11): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, Task, UUID (+3 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.12
Nodes (17): FormatContextBuilder, DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:) (+9 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.11
Nodes (13): ExternalOpenKind, filePreview, terminal, theme, InstallChoice, cancel, install, installAndApply (+5 more)

### Community 228 - "sessionRow"
Cohesion: 0.13
Nodes (18): NSEvent, WorktreeCardView, FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:) (+10 more)

### Community 229 - ".decide"
Cohesion: 0.18
Nodes (6): BrowserPaneView, DesignModeElementInfo, Any, NSPopover, String, TimeInterval

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.15
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 231 - "ExternalOpenKind"
Cohesion: 0.17
Nodes (11): NotchGeometry, .fallback, NSScreen, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics (+3 more)

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.11
Nodes (10): KouenTerminalKit, OcclusionTests, NSWindow, String, TimeInterval, SpecialKeyMappingTests, Bool, NSEvent (+2 more)

### Community 233 - "TextGrid"
Cohesion: 0.18
Nodes (5): CompositorPane, GridCompositorTests, Bool, String, TerminalGridSnapshot

### Community 234 - ".scan"
Cohesion: 0.16
Nodes (13): CryptoKit, Network, DecodedWSFrame, MobileBridgeServer, Bool, ConnectionState, NWConnection, String (+5 more)

### Community 235 - "WorkbenchCommand"
Cohesion: 0.13
Nodes (16): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, .bytesPerWakeup, .mbps (+8 more)

### Community 236 - "Added"
Cohesion: 0.18
Nodes (16): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, PaneLeaf, PaneNode (+8 more)

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.16
Nodes (3): CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 238 - ".make"
Cohesion: 0.24
Nodes (7): BinaryInstaller, .bundledMacOSDir, Bool, TimeInterval, BinaryInstallerVersionTests, String, URL

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.09
Nodes (25): aDt(), BDt(), Bpe(), cFe(), displayable(), eFe(), Fpe(), KBe() (+17 more)

### Community 240 - "PaneBorderStatus"
Cohesion: 0.09
Nodes (25): bNt(), bu(), cNt(), dNt(), eNt(), eRe(), fNt(), h0t() (+17 more)

### Community 241 - "Added"
Cohesion: 0.17
Nodes (4): l8e(), $Rt(), tJe(), YUt

### Community 242 - "AgentBridge"
Cohesion: 0.08
Nodes (6): CodepointRunFastPathTests, .assertAllPathsAgree(_:cols:rows:file:line:), StaticString, String, UInt, UInt8

### Community 243 - ".make"
Cohesion: 0.20
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 244 - "FileNode"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.11
Nodes (6): PromptQueue, String, SurfaceID, Void, PromptQueueBar, NSWindow

### Community 246 - "Experience modes"
Cohesion: 0.13
Nodes (15): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+7 more)

### Community 247 - ".renderFixture"
Cohesion: 0.16
Nodes (10): BranchSwitchHelper, FileTreeSwiftUIView, .body, .scanOptions, Notification.Name, Never, NSMenuItem, Task (+2 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.15
Nodes (8): BoardViewController, .isVisible, FlippedView, .isFlipped, Bool, Set, TabID, BoardViewControllerTests

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.11
Nodes (13): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, PaneLeaf (+5 more)

### Community 251 - "SessionCoordinator"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 252 - "NSViewRepresentable"
Cohesion: 0.13
Nodes (14): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8, GlassEffectView (+6 more)

### Community 253 - "Split Right"
Cohesion: 0.14
Nodes (17): PaneBorderStatus, bottom, off, top, PaneLeaf, PaneNode, branch, leaf (+9 more)

### Community 254 - "BoardViewController"
Cohesion: 0.13
Nodes (17): Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock, .block(id:) (+9 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.13
Nodes (9): NSDraggingInfo, NSDragOperation, PasteController, Bool, NSPasteboard, String, TimeInterval, URL (+1 more)

### Community 256 - "GitMetadataProvider"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 258 - "WindowTitleStripView"
Cohesion: 0.11
Nodes (11): Bool, NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView (+3 more)

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.13
Nodes (8): .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), Selector, URL, WKNavigationAction, NSAppearance, WKUserScript, WKWindowFeatures

### Community 260 - ".welcome"
Cohesion: 0.14
Nodes (15): Notification.Name, ObserverToken, NSCoder, NSObjectProtocol, NSRect, NSTextView, URL, SyntaxDefinitionTarget (+7 more)

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.18
Nodes (14): ProjectGroupWatcher, StreamBox, Bool, DispatchQueue, escaping, FSEventStreamRef, MainActor, Never (+6 more)

### Community 262 - ".install"
Cohesion: 0.14
Nodes (13): SwarmFleetBody, .body, SwarmNodeRowView, .body, .statusColor, Duration, Void, SwarmFleetSnapshotWire (+5 more)

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.17
Nodes (9): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, FormatColor, String (+1 more)

### Community 264 - "code:bash (harness-cli install-hooks claude-code)"
Cohesion: 0.26
Nodes (8): ignoreSIGPIPE(), Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 265 - "code:bash (harness-cli install-hooks cursor)"
Cohesion: 0.16
Nodes (13): InstallResult, Shell, bash, fish, zsh, ShellIntegration, Bool, URL (+5 more)

### Community 266 - ".path"
Cohesion: 0.16
Nodes (20): a(), b(), c(), d(), g(), h(), I(), j() (+12 more)

### Community 267 - ".performInstall"
Cohesion: 0.13
Nodes (6): azt(), F7, ibe(), mathmlBuilder(), q$e(), UHt()

### Community 268 - "code:bash (# Old (agent-specific):)"
Cohesion: 0.13
Nodes (3): KouenGridTerminalTests, String, TerminalGridSnapshot

### Community 269 - "DefaultTerminalManager"
Cohesion: 0.18
Nodes (10): RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal, FileHandle, Int32 (+2 more)

### Community 270 - "WindowSession"
Cohesion: 0.12
Nodes (9): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, KouenApp, FileChangeWatcherTests (+1 more)

### Community 271 - "StatusLineView.swift"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 272 - "SGRMouseEvent"
Cohesion: 0.12
Nodes (19): AgentRow, .agentColor, .executables, .hookButton, .hookButtonTitle, .mcpButton, HookState, failed (+11 more)

### Community 273 - "KeySpec"
Cohesion: 0.18
Nodes (20): CoreImage, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription, .surfaceID, detectHost() (+12 more)

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.18
Nodes (10): MainActor, Void, Group, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, CGFloat, NSTextField (+2 more)

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.24
Nodes (6): CommandPaletteController, PaletteAction, PaletteFileEntry, PaletteGrepMatch, String, TimeInterval

### Community 276 - "SyntaxTextView"
Cohesion: 0.14
Nodes (13): GridCompositor, Configuration, Int32, SessionGroup, SessionID, Tab, TabID, WorkspaceID (+5 more)

### Community 277 - ".run"
Cohesion: 0.16
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.29
Nodes (4): tool, KouenDaemonToolsTests, String, URL

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 280 - ".menu"
Cohesion: 0.15
Nodes (19): BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, CodingKeys, description, key (+11 more)

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.30
Nodes (4): TaskStore, tasks, URL, TaskStoreTests

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.21
Nodes (8): DaemonMetrics, Snapshot, .meanLockWaitMicros, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 283 - "FormatColor"
Cohesion: 0.12
Nodes (17): OnboardingStep, complete, discover, .id, setup, shell, .title, welcome (+9 more)

### Community 284 - "click_ui_element"
Cohesion: 0.11
Nodes (4): o, aZ(), e0(), h$()

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.30
Nodes (9): .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release, `repeat`, KeyModifiers, Character, String (+1 more)

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.16
Nodes (20): Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors, ContrastGrade (+12 more)

### Community 287 - ".apply"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Kouen, Sparkle (+13 more)

### Community 288 - "AgentHookStrategy"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 289 - "StatusLineWidthTests"
Cohesion: 0.13
Nodes (6): CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab, GitMetadataProviderTests

### Community 290 - "Process"
Cohesion: 0.18
Nodes (11): Never, NSRegularExpression, Set, String, Task, URL, Void, WorkspaceSymbolIndex (+3 more)

### Community 291 - "JSONDecoder"
Cohesion: 0.16
Nodes (8): CustomEndpointTester, Result, Bool, String, URL, CustomEndpointTesterTests, URLRequest, URLSession

### Community 292 - "Release runbook"
Cohesion: 0.15
Nodes (3): Set, SplitDirection, String

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.14
Nodes (11): KouenSyntaxResources, BrowserFileReloadTests, CountingWebView, Nav, NSEvent, String, Void, WKNavigation (+3 more)

### Community 294 - "GitHubCLIClient"
Cohesion: 0.16
Nodes (5): TabID, WorkspaceID, AgentCommandTests, String, Tab

### Community 295 - "AgentApprovalBar"
Cohesion: 0.17
Nodes (16): SessionRef, byID, byName, next, previous, String, UUID, TargetSpec (+8 more)

### Community 296 - "NotificationBus"
Cohesion: 0.11
Nodes (12): CodingKeys, error, id, jsonrpc, method, JSONRPCId, int, string (+4 more)

### Community 297 - "settings.json"
Cohesion: 0.20
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 299 - "PaneNode"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.13
Nodes (14): BinaryInstaller.DetectionStatus, SetupStepView, .body, .canInstall, .hooksDetail, .hooksTone, .hooksValue, .isSuccess (+6 more)

### Community 301 - ".parse"
Cohesion: 0.27
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.14
Nodes (9): GridCompositorParityTests, LiveCompositorFixture, Bool, String, TerminalGridSnapshot, PortCompositorFixture, Bool, String (+1 more)

### Community 304 - "00-inception-plan.md"
Cohesion: 0.10
Nodes (3): Bool, String, UUID

### Community 305 - ".script"
Cohesion: 0.15
Nodes (6): Security, KouenMCPServer, Bool, String, MCPServer, String

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.21
Nodes (8): SettingsAdvancedView, .body, Bool, String, SettingsFileSearchSection, .body, String, SwiftUI

### Community 307 - "ViPathTokenTests"
Cohesion: 0.27
Nodes (11): AgentBadgeView, .body, Bool, CGFloat, AgentIconRenderer, CGFloat, NSColor, NSImage (+3 more)

### Community 308 - "Send Ex Command"
Cohesion: 0.22
Nodes (10): .webView(_:didCommit:), .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didFinish:), .webView(_:didStartProvisionalNavigation:), LoadCompletionState, CheckedContinuation, Error (+2 more)

### Community 310 - "FrameSignposter"
Cohesion: 0.25
Nodes (8): FileTreeContext, NSHostingView, SessionID, String, Void, WorkspaceFileTreeView, .init(rootPath:), WorkspaceFileTreePinTests

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.18
Nodes (15): CellMetrics, ComposedFrame, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth (+7 more)

### Community 312 - "AgentSnapshot"
Cohesion: 0.17
Nodes (8): AgentListFormatter, Date, String, dvn(), AgentListFormatterTests, Bool, Date, String

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 314 - "code:bash (harness-cli install-hooks codex)"
Cohesion: 0.12
Nodes (10): EndpointError, connectionFailed, .description, notYetSupported, pathTooLong, String, EndpointConnector, Int32 (+2 more)

### Community 315 - "code:bash (harness-cli install-hooks grok)"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 316 - "code:bash (harness-cli install-hooks opencode)"
Cohesion: 0.17
Nodes (3): ShellIntegrationTests, .repoRoot, URL

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.16
Nodes (16): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+8 more)

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.16
Nodes (6): LSPTextLocation, .position, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 319 - "FormatColor"
Cohesion: 0.16
Nodes (12): ANSIPalette, CellColorResolver, MochaTheme, ResolvedCellColors, .init(hex:), .init(red:green:blue:alpha:), Bool, Double (+4 more)

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.19
Nodes (11): DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String, StyledSegment (+3 more)

### Community 321 - "UInt64"
Cohesion: 0.15
Nodes (9): _7(), A7(), a8(), bGt(), c8(), ene(), Gnn, IC() (+1 more)

### Community 322 - "DesktopNotifier"
Cohesion: 0.16
Nodes (8): brn, grn, hrn(), JGe(), KGe(), prn(), qGe(), zGe()

### Community 323 - "LayoutNode"
Cohesion: 0.17
Nodes (4): InputEncoder, InputEncoderTests, String, UInt8

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.19
Nodes (8): Range, String, TerminalGridCell, TerminalBufferMatch, TerminalBufferSearch, String, TerminalGridCell, TerminalBufferSearchTests

### Community 325 - "FloatingPaneController"
Cohesion: 0.15
Nodes (8): CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16, UInt8, CharacterWidthTests

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.15
Nodes (4): KouenThemeCatalog, .allThemes, String, KouenThemeCatalogTests

### Community 327 - ".theme"
Cohesion: 0.10
Nodes (20): Agent Safety Net (Checkpoints, Verification, Write Guards), AI Browser Control (kouen-mcp), Build From Source, Claude Code Harness, CLI, Development Builds, Documentation, Editor & LSP (+12 more)

### Community 328 - "README.md"
Cohesion: 0.19
Nodes (4): AgentHistoryMultiAgentCoverageTests, Bool, String, URL

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.18
Nodes (8): PaneID, SurfaceID, Tab, TabID, BrowserPaneReuseScopeTests, PaneNode, Tab, TabID

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.14
Nodes (8): Set, SurfaceID, Void, TerminalPaneRegistry, AnyObject, TimeInterval, ZombieHoldRegistry, ObjectIdentifier

### Community 332 - "Added"
Cohesion: 0.16
Nodes (7): FlippedView, .isFlipped, NSStackView, NSTextField, agentInfo, .stats, GlyphAtlasStats

### Community 333 - "RealPty"
Cohesion: 0.16
Nodes (5): .removeWorktreeAction(_:), NSButton, NSScrollView, NSTextView, GitPanelViewDiffPopoverTests

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.16
Nodes (7): MainMenuBuilder, Bool, NSMenu, NSMenuItem, Selector, String, MenuTargetForkConversationTests

### Community 335 - ".makeModel"
Cohesion: 0.14
Nodes (7): KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, BinaryInstallerDisplayTests, OnboardingEnvironmentTests

### Community 336 - "run.sh"
Cohesion: 0.19
Nodes (12): CGFloat, NSCoder, SessionID, String, Void, TaskDashboardBody, .body, TaskDashboardView (+4 more)

### Community 337 - "CommandExecutionError"
Cohesion: 0.15
Nodes (12): .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:), .isHovered, Bool, NSCoder (+4 more)

### Community 338 - "CSIParams"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 339 - "Foundation"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.15
Nodes (9): Bool, Int32, String, URL, SystemdUserInstaller, .backendName, .isInstalled, .unitURL (+1 more)

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.11
Nodes (10): ClaudeAdapter, UUID, HeadlessCLIAdapter, HeadlessRunEvent, assistantText, result, sessionID, Bool (+2 more)

### Community 342 - "Added"
Cohesion: 0.16
Nodes (16): SwarmFleetSnapshot, SwarmLane, pty, structured, SwarmTaskNode, SwarmTaskStatus, cancelled, failed (+8 more)

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.13
Nodes (6): agentWaitChannel(), HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 344 - "FileViewerViewController"
Cohesion: 0.20
Nodes (3): ezt(), GGe, Hzt()

### Community 345 - "README.md"
Cohesion: 0.15
Nodes (3): CellColorResolverTests, .resolver, CellColorResolver

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

### Community 348 - "DaemonLifecycleTests"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 349 - "Contents.json"
Cohesion: 0.21
Nodes (9): Scanner, .atEnd, SVGPathParser, Bool, CGPath, CGPoint, Character, Set (+1 more)

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.14
Nodes (9): CGFloat, NSHostingView, NSLayoutConstraint, TerminalTabBarView, .delegate, .init(frame:), .leadingInset, .mouseDownCanMoveWindow (+1 more)

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.18
Nodes (9): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+1 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.11
Nodes (18): CodingKeys, excludedPaths, id, name, sourceFolder, CodingKey, CodingKeys, createdAt (+10 more)

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.19
Nodes (9): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+1 more)

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.19
Nodes (13): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Bool, Duration (+5 more)

### Community 355 - ".deepMerge"
Cohesion: 0.24
Nodes (15): Decodable, AssistantLine, Content, Message, ResultLine, Bool, Double, String (+7 more)

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.11
Nodes (8): KouenDaemonCore, IPCCodecInvariantTests, RawSocketError, connectFailed, writeFailed, ScrollbackPersistenceTests, String, URL

### Community 357 - ".handleCat"
Cohesion: 0.21
Nodes (9): NWEndpoint, MobileBridgeServer, Bool, NWListener, Sendable, String, UInt16, start() (+1 more)

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.19
Nodes (5): KeyTokenParser, Bool, String, KeyTokenParserTests, Phase6KeysTests

### Community 360 - "State"
Cohesion: 0.18
Nodes (13): FeaturePhase, architect, completed, dev, interview, qaDesign, qaVerify, .title (+5 more)

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.20
Nodes (7): SavedLayoutStore, Bool, String, URL, UUID, SavedLayoutStoreTests, URL

### Community 362 - "RGBColor"
Cohesion: 0.18
Nodes (7): ReleaseNotes, Section, String, ReleaseNotesGuardTests, .changelog, String, .sampleNotes

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.33
Nodes (4): Run, String, TerminalBanner, WelcomeConfig

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.24
Nodes (7): .snapshotPayload, NotificationBus, .postSnapshotChanged(_:), .postSnapshotChanged(revision:), SnapshotChangedPayload, Bool, String

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.16
Nodes (9): FileGraphInfo, GraphifyLSPBridge, Double, String, URL, GraphifyLSPBridgeTests, Any, String (+1 more)

### Community 366 - "Consumers"
Cohesion: 0.12
Nodes (18): _9n(), a9e(), Am(), avn(), Cm(), d8e(), Hm(), hmn() (+10 more)

### Community 367 - "DaemonStats"
Cohesion: 0.22
Nodes (6): ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 368 - "Tab"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 369 - "Git Panel"
Cohesion: 0.18
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 370 - ".encode"
Cohesion: 0.20
Nodes (3): String, TerminalGridSnapshot, VTConformanceCorpusTests

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.17
Nodes (9): GitStatusProvider, OnceResume, Bool, Duration, String, TimeInterval, GitStatusProviderLargeOutputTests, URL (+1 more)

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.21
Nodes (4): Bool, String, SurfaceID, TimeInterval

### Community 373 - "Prompt"
Cohesion: 0.16
Nodes (11): PaneLayoutShape, branch, leaf, PaneNode, .paneLayoutShape, SavedLayout, Date, Double (+3 more)

### Community 374 - ".run"
Cohesion: 0.17
Nodes (7): string, AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID

### Community 375 - ".install"
Cohesion: 0.18
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 376 - "ScrollReuseTests"
Cohesion: 0.12
Nodes (6): ScreenPos, bottom, middle, top, KouenLSP, QuickLookUI

### Community 377 - "Identifiable"
Cohesion: 0.27
Nodes (9): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, PaletteFooter, .body (+1 more)

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.23
Nodes (5): AgentNotchViewModel, Bool, CGFloat, Duration, String

### Community 379 - "MCPServer"
Cohesion: 0.12
Nodes (16): Command, .targetKind, PaneRef, bottom, byID, byIndex, last, left (+8 more)

### Community 380 - "PromptQueue"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 381 - "smoke-dmg.sh"
Cohesion: 0.20
Nodes (4): CompletionGenerator, String, .fishCompletionSource, CompletionGeneratorTests

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.19
Nodes (8): AgentRemoteControlDaemonService, Set, String, Void, AgentRemoteControlDaemonServiceTests, LogBox, .count, String

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.18
Nodes (8): ClaudeRunSummary, Date, Double, Int32, String, UUID, String, UUID

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.16
Nodes (11): Status, ciFailing, done, mergeReady, open, running, Bool, Date (+3 more)

### Community 385 - "INDEX.md"
Cohesion: 0.29
Nodes (4): SwarmDAGStore, String, UUID, SwarmDAGStoreTests

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.18
Nodes (14): Array, Bool, Date, Decoder, PaneID, PaneNode, String, TabID (+6 more)

### Community 387 - "User Profile"
Cohesion: 0.27
Nodes (5): .block(atPromptLine:), .captureLines(fromLine:toLine:), String, String, TerminalBlockStoreTests

### Community 388 - "Darwin"
Cohesion: 0.26
Nodes (3): String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 389 - "HarnessCLITests"
Cohesion: 0.20
Nodes (16): Close Pane, Next Session, Previous Session, Split Down, Split Right, Cmd W Closes Pane When Split, Zombie Crash Rapid Split Close Cycle, Close Pane Removes Split (+8 more)

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.22
Nodes (4): Bool, String, ThemeService, KouenOptions

### Community 392 - "build-release.sh"
Cohesion: 0.17
Nodes (4): SessionID, ContentAreaViewController, SplitDirection, TabID

### Community 393 - "create-dmg.sh"
Cohesion: 0.17
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 394 - "finalize-release.sh"
Cohesion: 0.20
Nodes (6): KouenWindow, NSEvent, MainWindowController, Any, NSRect, NSWindow

### Community 395 - "generate-app-icon.sh"
Cohesion: 0.17
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 396 - "generate-appcast.sh"
Cohesion: 0.20
Nodes (11): Notification.Name, os, attribute_lines(), main(), redraw_frames(), repeated_chunk(), run_case(), sgr_lines() (+3 more)

### Community 397 - "measure-fluidity.sh"
Cohesion: 0.30
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 398 - "preview.sh"
Cohesion: 0.12
Nodes (15): agy, claude, codex, copilot, hermes, kouen, __kouen_agy_next, __kouen_claude_next (+7 more)

### Community 399 - "sign-and-notarize.sh"
Cohesion: 0.17
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, Bool, Double (+3 more)

### Community 400 - "install-linux.sh"
Cohesion: 0.19
Nodes (10): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+2 more)

### Community 401 - "package-app.sh"
Cohesion: 0.18
Nodes (13): Profile, edit, readonly, Run, RunState, cancelled, failed, running (+5 more)

### Community 402 - "View"
Cohesion: 0.14
Nodes (13): init(), PairingBox, .current, .isLockedOut, PendingPairing, stop(), Date, TimeInterval (+5 more)

### Community 403 - "PresentAttempt"
Cohesion: 0.20
Nodes (4): TerminalModes, .encode(text:modifiers:modes:), Bool, .appCursor

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 405 - "AgentIconRenderer"
Cohesion: 0.14
Nodes (13): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+5 more)

### Community 406 - "main.swift"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 407 - "Fixed"
Cohesion: 0.16
Nodes (9): URL, KouenFilePreviewLoader, KouenViewError, binaryOrUnsupportedEncoding, missingPath, tooLarge, unreadable, FileManager (+1 more)

### Community 408 - "IPC Architecture"
Cohesion: 0.21
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.23
Nodes (8): LSPFileSession, Never, String, Task, URL, Void, object, Bool

### Community 410 - ".applyTerminalIdentity"
Cohesion: 0.31
Nodes (9): CGFloat, Range, Tab, TabBarLayoutMetrics, .pitch, tabDisplayTitle(), TerminalTabBarBody, .body (+1 more)

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.15
Nodes (8): DispatchSource, DispatchQueue, DispatchSourceFileSystemObject, Int32, URL, Void, TranscriptFileWatcher, MobileBridgeTranscriptWatcherTests

### Community 412 - "go.json"
Cohesion: 0.23
Nodes (13): kouen.bash script, agy(), claude(), codex(), copilot(), hermes(), kouen(), __kouen_agy_next() (+5 more)

### Community 413 - "javascript.json"
Cohesion: 0.20
Nodes (10): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+2 more)

### Community 414 - "json.json"
Cohesion: 0.16
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 415 - "markdown.json"
Cohesion: 0.18
Nodes (4): AgentScanner, Bool, DispatchSourceTimer, TimeInterval

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.22
Nodes (6): ListeningPortScanner, Int32, Set, String, result, ListeningPortScannerTests

### Community 417 - "rust.json"
Cohesion: 0.22
Nodes (5): RepoResolver, Bool, String, RepoResolverTests, String

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.20
Nodes (13): ern(), G4(), G7(), Jnn(), nrn(), Qnn(), sHe(), trn() (+5 more)

### Community 419 - "typescript.json"
Cohesion: 0.23
Nodes (5): UnsafeBufferPointer, TerminalCellWidth, UInt8, UnsafeBufferPointer, UInt32

### Community 420 - "yaml.json"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 422 - "HintModeOverlay"
Cohesion: 0.23
Nodes (4): String, URL, UUID, WorktreeIsolationDaemonTests

### Community 423 - "SixelDecoder"
Cohesion: 0.26
Nodes (14): Agent Command Does Not Crash, Agent Waiting Filter Does Not Crash, Board Command Shows Board Panel, Cd Command Switches To Matching Tab, Copy Path Command Does Not Crash, Errors Command Does Not Crash, Find Command Opens Command Palette On Empty Query, Find Command Resolves Unique File (+6 more)

### Community 424 - ".parseDiffHunks"
Cohesion: 0.24
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 425 - "AgentVectorIcon"
Cohesion: 0.25
Nodes (4): PortableRelativeDateFormatter, Date, String, UUID

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.19
Nodes (9): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 427 - ".delay"
Cohesion: 0.27
Nodes (6): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection

### Community 428 - "TaskDashboardView"
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.22
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.19
Nodes (8): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow, NSImage, NSHostingController

### Community 431 - "BoardCardView"
Cohesion: 0.20
Nodes (9): Container, .init(coder:), .init(frame:), NotchPulseHost, .body, Context, NSCoder, NSHostingView (+1 more)

### Community 432 - "PathToken"
Cohesion: 0.22
Nodes (8): DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSViewCornerConfiguration, SurfaceID, Void

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.24
Nodes (8): ProjectDropTarget, .init(coder:), .init(frame:), NSCoder, NSDraggingInfo, NSDragOperation, NSRect, URL

### Community 434 - "Project History"
Cohesion: 0.20
Nodes (11): DotView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor, NSRect (+3 more)

### Community 435 - ".init"
Cohesion: 0.34
Nodes (3): Install, Shell integration (OSC 133 semantic prompts), What gets emitted

### Community 436 - "WaitForRegistry"
Cohesion: 0.14
Nodes (14): Agent handbook — Kouen (extended reference), Agent integration, Build and test, IPC, Keyboard shortcuts, kouen-cli, Native terminal renderer, Repository map (+6 more)

### Community 437 - "PickerItemRow"
Cohesion: 0.19
Nodes (7): CodexSessionLocator, CodexTranscriptLine, Any, Bool, Int32, String, URL

### Community 438 - "SessionEditor"
Cohesion: 0.41
Nodes (7): FeatureSummary, FeatureTaskSummary, GateSummary, Bool, Date, String, UUID

### Community 439 - "SetupStepView"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 440 - "LegacySnapshot"
Cohesion: 0.23
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 441 - "RemoteHostStore"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.20
Nodes (5): aD(), crn, ELt(), n2e(), urn

### Community 443 - "main.swift"
Cohesion: 0.19
Nodes (14): AOt(), Ape(), bOt(), cX(), eJe(), iD(), jY(), LOt() (+6 more)

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 445 - "Section"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 446 - "Modifiers"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 447 - "PaletteMode"
Cohesion: 0.15
Nodes (11): copyMode, esc(), fs, globalShortcuts, KEYBINDINGS, prefixTable, renderTable(), ROOT (+3 more)

### Community 449 - "PresentAttempt"
Cohesion: 0.25
Nodes (4): StatusLineWidthTests, StatusLineWidth, String, StyledSegment

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.21
Nodes (6): String, TerminalGridCell, TextGrid, .totalLines, .viewportRows, WordColumnRangeTests

### Community 451 - ".run"
Cohesion: 0.18
Nodes (13): Branch Change In Shared Folder Is Not Isolated Unprompted, CLI Isolate Creates Worktree And Session, CLI Isolate With Custom Branch Name, Close Session Keeps Dirty Worktree, Close Session Removes Clean Worktree, Create Isolated Session And Select, Git Checkout In Normal Session Does Not Affect Isolated, Isolate Without Branch Uses Detached HEAD (+5 more)

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 454 - ".recordReapedGenerationForTesting"
Cohesion: 0.15
Nodes (3): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess

### Community 455 - "ComposerPanel"
Cohesion: 0.18
Nodes (8): KouenIPC, MobileBridgeServer, String, AgentIconArt, AgentVectorIcon, Bool, CGSize, String

### Community 456 - "TerminalModes"
Cohesion: 0.21
Nodes (3): SessionID, KouenCommands, GitPanelViewWorktreeTaskTests

### Community 457 - ".normalizedKey"
Cohesion: 0.18
Nodes (7): CGFloat, NSColor, NSPoint, NSRect, NSWindow, WindowBorderOverlayView, .windowCornerRadius

### Community 458 - "FileTreeKeyboardNavigator"
Cohesion: 0.24
Nodes (7): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController

### Community 459 - ".encode"
Cohesion: 0.23
Nodes (9): AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor (+1 more)

### Community 460 - "RunState"
Cohesion: 0.21
Nodes (4): JSONDecoder, JSONEncoder, String, TerminalRecordingCodec

### Community 461 - ".worktreeList"
Cohesion: 0.24
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 462 - "AGENTS.md"
Cohesion: 0.21
Nodes (5): FDWatchdog, DispatchSourceTimer, String, TimeInterval, FDWatchdogTests

### Community 463 - ".deinit"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 464 - "MouseButton"
Cohesion: 0.18
Nodes (6): eKe(), irn(), mrn, _rn(), rrn(), srn()

### Community 465 - "DirectionalAxis"
Cohesion: 0.28
Nodes (4): TerminalGridSnapshot, ReflowPreviewTests, .feeds, String

### Community 466 - "PlatformSys.swift"
Cohesion: 0.21
Nodes (5): ImageTextureCache, MTLDevice, MTLTexture, Set, UInt8

### Community 467 - ".moveSelection"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 468 - "Never"
Cohesion: 0.33
Nodes (5): SearchBenchmarks, String, UInt64, URL, Void

### Community 470 - "DispatchTime"
Cohesion: 0.26
Nodes (3): BellScanTests, Bool, UInt8

### Community 471 - ".evaluateStyled"
Cohesion: 0.26
Nodes (4): PaneLabelDaemonTests, String, URL, UUID

### Community 473 - "HarnessOnboarding"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 474 - "String"
Cohesion: 0.15
Nodes (3): AgentHookInstallerCLI, String, String

### Community 475 - ".hitTest"
Cohesion: 0.29
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 476 - "ProjectDropTarget"
Cohesion: 0.20
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

### Community 477 - ".encode"
Cohesion: 0.27
Nodes (4): HintModeOverlay, Any, NSEvent, String

### Community 478 - ".install"
Cohesion: 0.26
Nodes (5): BrowserPaneRegistry, .init(url:paneID:), NSWindow, PaneID, WeakBrowserPaneView

### Community 479 - "ScrollbackTests"
Cohesion: 0.20
Nodes (9): BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool, CGFloat, NSCoder, NSPoint (+1 more)

### Community 480 - "Command Prompt Architecture"
Cohesion: 0.18
Nodes (8): Date, Never, Task, Void, TabPillView, .pillBackground, .pillBorder, Gesture

### Community 481 - ".testKouenRendererFixtureDefaultTextReportsPlausibleGlyphStats"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 482 - ".resolve"
Cohesion: 0.17
Nodes (11): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile, regionEdit (+3 more)

### Community 483 - "Changed"
Cohesion: 0.41
Nodes (4): KouenFeatureMarkdownSync, Bool, String, URL

### Community 484 - "CopilotAdapter"
Cohesion: 0.41
Nodes (5): InstallResult, ShellCompletionInstaller, Bool, String, URL

### Community 485 - ".testKouenRendererFixtureLigatureShapingPathReportsPlausibleGlyphs"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 486 - "TabPillView"
Cohesion: 0.17
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 487 - "bC"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 489 - "SurfaceIO"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 490 - "ccRunGet"
Cohesion: 0.18
Nodes (5): FormatContextDaemonTests, PaneID, String, SurfaceID, URL

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 493 - "ccRunStart"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 494 - "ccRunInfo"
Cohesion: 0.24
Nodes (11): Close Tab, New Tab, Cmd Shift W Force Closes Tab, Cmd T Creates New Session, Cmd W Closes Tab When Single Pane, Window Survives Full Shortcut Sequence, Zombie Crash Close Tab While Typing, Zombie Crash Rapid Close While Typing (+3 more)

### Community 495 - ".makeDiffScrollView"
Cohesion: 0.25
Nodes (8): AnimatablePair, NotchShape, .animatableData, CGFloat, CGPath, CGRect, Path, Shape

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.24
Nodes (5): RiskyCommandClassifier, Bool, NSRegularExpression, String, RiskyCommandClassifierTests

### Community 497 - ".bind"
Cohesion: 0.29
Nodes (6): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Carbon

### Community 499 - "ProjectConfig"
Cohesion: 0.33
Nodes (3): DataBox, GitPanelViewDiffErrorTests, String

### Community 500 - "zO"
Cohesion: 0.24
Nodes (3): TabID, WorkspaceID, GitPanelViewWorktreeNavigationTests

### Community 501 - "Fixed"
Cohesion: 0.31
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 502 - "ACP Client (Shelved)"
Cohesion: 0.35
Nodes (7): FileTab, .title, FileTabManager, .hasOpenTabs, Bool, FileTabID, String

### Community 503 - "ReleaseNotesGuardTests"
Cohesion: 0.25
Nodes (7): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, NSEvent

### Community 504 - "WindowBorderOverlayView"
Cohesion: 0.20
Nodes (7): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, NSCoder, Void

### Community 505 - ".tickFeatureWorktreeSweepLocked"
Cohesion: 0.18
Nodes (9): statusColor(), statusHelp(), String, TabStatus, done, error, idle, running (+1 more)

### Community 506 - "SwarmFleetBody"
Cohesion: 0.18
Nodes (10): Architecture Decisions (dated log), Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Post-P50 changes (v4.20.2 → v4.20.11, 2026-10-01 → 2026-10-06), Product Identity Guardrail: Terminal, Not IDE, Shipped capability summary, P44–P49 (2026-08-31 → 2026-09-23) (+2 more)

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.20
Nodes (8): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, ClosedRange, String

### Community 508 - "qLt"
Cohesion: 0.45
Nodes (3): data, SixelDecoder, UInt8

### Community 509 - "start.mjs"
Cohesion: 0.27
Nodes (6): bUt(), Gbe(), handler(), M9(), mUt(), _Q()

### Community 510 - "PromptQueue"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 511 - ".panePathLookup"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 512 - ".setAttribute"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 513 - "ThemeDocument"
Cohesion: 0.27
Nodes (8): LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab, TabID, WorkspaceID

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.18
Nodes (3): MobileBridgeAttachFileTests, String, URL

### Community 515 - "RD"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 516 - "terminal_stress_runner.py"
Cohesion: 0.18
Nodes (10): Bug 1 - Rotation Grace Slot Keeps The Previous Token Redeemable, Bug 1 - Rotation Shifts The Outgoing Token Into The Grace Slot, Bug 1 - Stop Fully Clears The Grace Slot, Bug 1 - Token Lifetime Not Regressed Below The Human-Flow Window, Bug 2 - Client onerror Does Not Clobber The Server Error Banner, Bug 2 - No Abrupt Cancel Immediately After The Error Text, Bug 2 - Reject Path Closes Gracefully With Policy-Violation Code 1008, Bug 3 - QR Not Printed When No Listener Is Ready (+2 more)

### Community 517 - "GroupedSessionDaemonTests"
Cohesion: 0.40
Nodes (5): PaneOutputWaiter, PaneOutputWaitResult, CheckedContinuation, Never, UInt64

### Community 518 - "Bool"
Cohesion: 0.31
Nodes (4): Bool, String, UUID, TaskDaemonBridge

### Community 519 - ".gestureRecognizer"
Cohesion: 0.33
Nodes (6): Bool, NSPasteboard, NSString, String, URL, AutoreleasingUnsafeMutablePointer

### Community 520 - "WriteOutcome"
Cohesion: 0.22
Nodes (8): Bool, String, TriState, auto, .boolValue, .label, off, on

### Community 521 - ".daemonIsStale"
Cohesion: 0.33
Nodes (4): .activeTab, BrowserTab, UUID, tabs

### Community 522 - "ShellCompletionInstallerTests"
Cohesion: 0.40
Nodes (4): SplitDirection, TabID, .body, TerminalTabBarDelegate

### Community 523 - "fFe"
Cohesion: 0.24
Nodes (3): KouenMCP, KouenBrowserToolsTests, URL

### Community 524 - "TerminalColorRole"
Cohesion: 0.31
Nodes (4): GraphifyIndexCache, S, Set, String

### Community 525 - ".encodeAndWait"
Cohesion: 0.20
Nodes (7): Kind, input, metadata, output, resize, ReplayStep, Decoder

### Community 526 - "Kind"
Cohesion: 0.20
Nodes (9): CodingKeys, cols, createdAt, dataBase64, rows, timeMs, type, version (+1 more)

### Community 527 - ".show"
Cohesion: 0.20
Nodes (9): RecordingEvent, input, metadata, output, resize, .timeMs, Date, Encoder (+1 more)

### Community 528 - "worktree_review_dashboard.robot"
Cohesion: 0.20
Nodes (6): LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled

### Community 529 - "WorktreeAutoIsolateService"
Cohesion: 0.29
Nodes (3): SessionStore, DispatchWorkItem, TimeInterval

### Community 530 - "HarnessChrome"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 531 - "BrowserProgressLine"
Cohesion: 0.31
Nodes (5): AgyAdapter, Result, ResultLine, String, UUID

### Community 532 - "OpenClaw → Kouen"
Cohesion: 0.29
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

### Community 533 - "flushSessionState"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 534 - ".zoomWindowIfDoubleClick"
Cohesion: 0.29
Nodes (8): FormatColor, none, palette, rgb, StyledSegment, Bool, String, UInt8

### Community 535 - "AgentNotification"
Cohesion: 0.20
Nodes (8): n, Oe(), N(), AI(), cy(), k$(), s$(), we()

### Community 536 - ".readGrid(scrollbackOffset:)"
Cohesion: 0.27
Nodes (3): DaemonReconnectPolicy, TimeInterval, DaemonReconnectPolicyTests

### Community 537 - "NSObject"
Cohesion: 0.24
Nodes (3): ClaudeSessionModeTests, URL, Void

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.24
Nodes (4): GroupedSessionTests, SessionGroup, Set, SurfaceID

### Community 539 - "install-app.sh"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 540 - ".applyStyleDirective"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 541 - ".init"
Cohesion: 0.24
Nodes (4): GroupedSessionDaemonTests, SessionGroup, String, URL

### Community 542 - ".init(from:)"
Cohesion: 0.24
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 543 - ".bufferLine"
Cohesion: 0.27
Nodes (9): Command Prompt, Find In Files, Git Panel, Open Command Palette, Switch To Session 1, Switch To Session 2, Rapid Session Switch While Typing, Switch Between Isolated And Normal Session (+1 more)

### Community 544 - "CodingKeys"
Cohesion: 0.33
Nodes (4): GridCompositorCopyModeTests, PaneRect, String, TerminalGridSnapshot

### Community 545 - ".characterIndex"
Cohesion: 0.22
Nodes (6): String, URL, ThemeCatalogEmbedTests, .embedSwift, .repoRoot, .sourceJSON

### Community 546 - "LegacySnapshot"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 547 - "NSObject"
Cohesion: 0.36
Nodes (5): PaneLeaf, SessionGroup, Any, String, Tab

### Community 548 - ".encode"
Cohesion: 0.36
Nodes (4): PaneNode, DaemonSyncServiceBrowserPaneMergeTests, PaneID, PaneNode

### Community 549 - ".init(from:)"
Cohesion: 0.31
Nodes (4): SessionID, SplitDirection, String, WorkspaceID

### Community 550 - ".init(hex:)"
Cohesion: 0.28
Nodes (6): .init(frame:), NSRect, WeakScriptMessageHandler, WKScriptMessage, WKScriptMessageHandler, WKUserContentController

### Community 552 - "worktree_auto_isolate_wiring.robot"
Cohesion: 0.25
Nodes (6): clamp(), Configuration, T, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, .dragGesture

### Community 553 - "harness.resource"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 555 - "code:bash (harness view <file>                        # syntax-highligh)"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Key spec syntax, Kouen keybindings, Persistence (+1 more)

### Community 556 - "sBt"
Cohesion: 0.25
Nodes (6): OptionSet, .description, .init(key:modifiers:), Modifiers, String, UInt8

### Community 557 - ".viewWillMove"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 558 - "FindWindowMatcherTests"
Cohesion: 0.33
Nodes (4): OutputTrigger, OutputTriggerStore, Bool, String

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.22
Nodes (9): B3(), dFe(), _Dt(), fFe(), lFe(), _Ot(), sD(), TOt() (+1 more)

### Community 560 - ".zoomWindowIfDoubleClick"
Cohesion: 0.25
Nodes (6): calculate(), constructor(), kOt(), mBt, r2e(), sOt()

### Community 561 - ".handleClaudeCode"
Cohesion: 0.22
Nodes (8): Build order (unchanged from interview decision), G1 — @ file-path picker, G2 — shell tab-completion suggestion strip (heuristic, explicitly best-effort), G3 — AI command suggestion (via `claude` CLI subprocess), Logical Design, P37 Phase G — Autocomplete (mobile bridge), Strategic Design, Tactical Design

### Community 562 - "BrowserResponsePayload"
Cohesion: 0.22
Nodes (8): Artifacts, Client Application — Slice 1 (stacked panes, no persistence), Client Application — Slice 2 (per-workspace divider memory), Context, Dev Task Progress — Workspace Sidebar Panels (P42), Integration, Note on task re-sequencing (2026-07-17), Summary

### Community 563 - "AgentNotchViewModel.swift"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 564 - "📁 IDE Sidebar"
Cohesion: 0.31
Nodes (6): TerminalGridCell, ThaiClusterCopyTests, ThaiGrid, .columns, .totalLines, .viewportRows

### Community 566 - "TerminalTabBarView.swift"
Cohesion: 0.22
Nodes (8): MCP Control Allowed With Env Var, MCP Control Denied Without Env Var, MCP KouenBoard Returns Columns, MCP KouenList Returns Sessions, MCP ReadPaneOutput Returns Content, Run MCP Request, Run MCP Request Allowed, Run MCP Request Denied

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.22
Nodes (7): block, escFn, lineFilter, md, page, script, swift

### Community 568 - ".installChromeBackground"
Cohesion: 0.36
Nodes (7): Document, Bool, Set, String, URL, ToolPolicy, .defaultURL

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.25
Nodes (7): Agent Memory, Graphify, graphify, kouen-terminal — Agent Instructions, Rules (read when triggered), Session Start, Skills & Rules

### Community 571 - "ShellIntegrationTests"
Cohesion: 0.39
Nodes (3): AgentBrowserPaneTracker, Set, AgentBrowserPaneTrackerTests

### Community 572 - "LayoutProbeView"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 573 - "tHe"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 574 - ".applyFontSize"
Cohesion: 0.25
Nodes (8): A `claude` typed by hand, Claude Code → Kouen, Customizing, One-line install, Session mode: Remote Control / cloud / local, The reverse direction: a session opened in Claude showing up in Kouen, Verifying, What gets written

### Community 575 - ".toastErrorSummary"
Cohesion: 0.32
Nodes (4): PaneID, SessionGroup, Tab, first

### Community 576 - "Phase67Tests"
Cohesion: 0.32
Nodes (6): CGFloat, ResizeDirection, down, left, right, up

### Community 577 - "SwarmFleetView"
Cohesion: 0.39
Nodes (5): AutomationSummary, Bool, Date, String, UUID

### Community 579 - "main.swift"
Cohesion: 0.25
Nodes (4): bze(), EQ(), MBe(), mm

### Community 580 - "ViInputMode"
Cohesion: 0.25
Nodes (4): _c(), Nn(), Pqe, qp()

### Community 583 - "WorkbenchMRU"
Cohesion: 0.29
Nodes (4): NSPoint, NSRect, TerminalFrameOverlayView, .isOpaque

### Community 584 - "GUt"
Cohesion: 0.25
Nodes (7): Claude Code hook push (in-process Task subagent detection), Client UI indicator, Detection core (AgentDetector, pure logic), IPC / Tab plumbing, P38 Phase B — Subagent Visibility — Dev Task Progress, Status: Rewritten 2026-07-14 after original implementation (tasks 1-5) was lost to a concurrent git operation before commit. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 585 - "P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress"
Cohesion: 0.25
Nodes (7): Original overlay build (built 2026-07-14, gated green, then deleted 2026-07-15 mid live-test), P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress, Pivot — merge into the Recipes picker (2026-07-15), Stage 1-2 — Engine/surface plumbing (built 2026-07-14, unchanged by the pivot, still in use), Status: Implementation pivoted mid-phase from a standalone overlay to a merge into the existing, Summary, Thread grouping — Zed framing folded into the same picker (2026-07-15)

### Community 586 - "Product"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 587 - "sheet-cheat.html"
Cohesion: 0.25
Nodes (7): #kouen, #practice, #score, #shell, #total, #unix, #vim

### Community 588 - "jHt"
Cohesion: 0.25
Nodes (3): FlushSessionStateTests, String, URL

### Community 590 - "lrn"
Cohesion: 0.29
Nodes (7): Toggle Sidebar, Sidebar Toggle Works, Board CLI Shows Columns, Board CLI Shows Running After Long Command, Board Columns Visible After Click, Board Tab Accessible In Sidebar, Split Pane And Resize

### Community 591 - "GitPanelViewWorktreeTaskTests.swift"
Cohesion: 0.25
Nodes (7): Browser Pane Open Close Rapid, File Preview Open Close, Git Fetch Shows Toast, Launch Kouen Staging, Memory Stability After 30 Seconds, Quit Kouen Staging, Sidebar Toggle Immediately After Launch

### Community 595 - "full-cycle.sh"
Cohesion: 0.33
Nodes (3): String, WorkspaceID, DaemonSyncServiceBranchNotifyTests

### Community 597 - "TerminalColorRole"
Cohesion: 0.29
Nodes (5): AgentNotchPresentation, closed, open, peek, AgentNotchWindowActivator

### Community 598 - ".encode"
Cohesion: 0.38
Nodes (4): SwarmFleetView, .init(coder:), CGFloat, NSCoder

### Community 600 - ".groupByRoot"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 601 - "Hwe"
Cohesion: 0.29
Nodes (7): Agent hooks for Kouen, CLI notification, Example Claude Code hook, Jump to waiting agent, OSC sequences (from terminal output), Per-agent guides, Set up via your IDE (copy/paste prompt)

### Community 602 - "Build locally"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 603 - "fut"
Cohesion: 0.29
Nodes (7): 1. Plain Terminal, 2. Persistent Terminal, 3. Full Terminal, 4. Agent Workspace, Experience modes, Opting into the prefix + status line without switching modes, Persistence (ephemeral vs. persistent)

### Community 604 - "k0t"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Kouen-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 605 - "drn"
Cohesion: 0.33
Nodes (3): DisplayWidth, String, Unicode

### Community 606 - "Quick start"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 607 - "iRe"
Cohesion: 0.57
Nodes (3): ProjectConfig, Bool, String

### Community 608 - "W2"
Cohesion: 0.29
Nodes (7): GRt(), n4e(), p7e(), r2(), tl(), vrt(), xq()

### Community 610 - "TabStatus"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

### Community 611 - ".showWorkspaceMenu"
Cohesion: 0.29
Nodes (6): Locked decisions (user-confirmed), Logical Design, P38 Phase A — Cross-Agent Worktree Diff/Review Dashboard — Design, Strategic Design, Tactical Design, Verification gate (this phase)

### Community 612 - ".init(coder:)"
Cohesion: 0.29
Nodes (6): Logical Design, Next Step, P42 — Workspace Sidebar Panels, Parked (not in scope), Strategic Design, Tactical Design

### Community 613 - "INDEX.md"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 618 - "parse"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 619 - "_0n"
Cohesion: 0.38
Nodes (6): Cleanup And Quit, Create Config File, No Config File Starts Normally, Script Hot Reload On Save, Script Loads On Startup, Script Syntax Error Does Not Crash

### Community 621 - "ViEngine"
Cohesion: 0.29
Nodes (6): Bug 1 - Browser Pane Deferred Unregister, Bug 1 - Browser Pane Reuse On Rebuild, Bug 2 - New Session Syncs Before Reading Active Tab, Bug 2 - Tab Bar New Tab Also Syncs, Bug 3 - Browser Pane Forces Redraw On Reattach, Build Compiles Successfully

### Community 624 - "[2.5.0] - 2026-06-12"
Cohesion: 0.33
Nodes (3): .body, AttributedString, NSColor

### Community 625 - "brt"
Cohesion: 0.33
Nodes (6): table(), tablecell(), tablerow(), Y(), d5(), _Fe()

### Community 628 - "ReplayStep"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 629 - "graphify reference: query, path, explain"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase D — Kitty Graphics Conformance Slice, Scope (locked), Tests

### Community 630 - "HGe"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua), Scope (locked), Tests

### Community 631 - "die"
Cohesion: 0.33
Nodes (5): Logical Design, Next Step, P43 — Add Repo/Folder to Workspace, Strategic Design, Tactical Design

### Community 632 - "dne"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 633 - "g_n"
Cohesion: 0.60
Nodes (5): main(), printHelp(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 634 - "qC"
Cohesion: 0.40
Nodes (3): String, URL, WorktreeSignatureTests

### Community 637 - "ClientSummary"
Cohesion: 0.47
Nodes (3): URL, TimeoutError, WorktreeLargeOutputRegressionTests

### Community 638 - "inlineTokens"
Cohesion: 0.33
Nodes (5): Kouen LSP Diagnostics Does Not Crash, Kouen LSP Hover Returns Result, Kouen LSP Start Returns JSON, Kouen View Binary Shows Guard Message, Kouen View Prints File Content

### Community 639 - "gpn"
Cohesion: 0.67
Nodes (3): AsyncCLIResultBox, Error, Result

### Community 641 - "[3.10.0] - 2026-06-27"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 645 - "KouenBrowserToolsTests"
Cohesion: 0.50
Nodes (4): PaletteItemRow, .body, AttributedString, NSColor

### Community 647 - "graphify reference: query, path, explain"
Cohesion: 0.40
Nodes (4): Findings, Sources, What this means for Kouen, Who creates branches / worktrees in AI coding tools

### Community 648 - "PtyDrainCeilingBenchmark"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: animateSidebar setContentLeadingInset MainSplitViewController, Source Nodes

### Community 649 - "h$t"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: ProjectCategory FolderScanner ProjectDirectoryTree, Source Nodes

### Community 650 - "hjt"
Cohesion: 0.40
Nodes (5): WrapperOptionBehavior, keepScanning, matchValue, skipValue, stopScanning

### Community 651 - "u0n"
Cohesion: 0.40
Nodes (5): CwdAuthorizationError, foreignPathRejected, .message, missingSessionOrCwd, other

### Community 652 - "TerminalHostView"
Cohesion: 0.40
Nodes (5): ColorKind, .base, bg, fg, underline

### Community 655 - "nht"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 656 - "Jcn"
Cohesion: 0.60
Nodes (3): .encode(_:modifiers:event:modes:), SpecialKey, insert

### Community 657 - "clear-runtime-state.sh"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 658 - "k0n"
Cohesion: 0.40
Nodes (4): Build, Release & Git Workflow, Build / Test / Run, Release packaging order, Worktree constraint

### Community 659 - "MobileBridgeBrowserTests"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 660 - "qAn"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 661 - ".compute"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 663 - "m6e"
Cohesion: 0.40
Nodes (4): Leak A - Retiring A Host Drops Its AI Controllers, Leak B - Browser Network Capture Is Bounded, Leak C - Every Per-Surface Dict In Coordinator Has Retire Cleanup, Leak D - Every Per-Surface Dict In NotificationCoordinator Is Snapshot-Swept

### Community 667 - "[3.3.0] - 2026-06-18"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

### Community 668 - "nje"
Cohesion: 0.50
Nodes (4): Full local signing path (needs a Developer ID cert; not currently used), How this fork actually releases, Release runbook, Scripted flow

### Community 669 - "PaneLabelDaemonTests"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 670 - "pie"
Cohesion: 0.50
Nodes (3): exclude_hubs, no_viz, wiki

### Community 671 - "AntigravityTranscriptTurnsTests"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: SSETransport auth token isRunning

### Community 673 - "qte"
Cohesion: 0.50
Nodes (3): SplitDirection, horizontal, vertical

### Community 675 - ".detect"
Cohesion: 0.50
Nodes (4): dO(), m8(), rfn(), zfn()

### Community 676 - "vne"
Cohesion: 0.50
Nodes (3): eie(), eZ(), wZ()

### Community 677 - "New Tab"
Cohesion: 0.67
Nodes (4): FVe(), hJ(), qVe(), Zme()

### Community 678 - "FormatColor"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 679 - ".splitPane"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 680 - ".apply"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 681 - ".tabIDsToNotify"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 682 - "Workbench commands (IDE-like workflow)"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 683 - "hJ"
Cohesion: 0.83
Nodes (3): restart_daemon(), full-cycle.sh script, usage()

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.50
Nodes (3): Bug 1 - Hunks Button Has Explicit Size Constraints, Bug 1 - Hunks Button Symbol Has A Guaranteed-Valid Fallback, Build Compiles Successfully

### Community 686 - "DECSpecialGraphics"
Cohesion: 0.50
Nodes (3): Guard A - Merge Call Site Never Passes --no-ff, Guard B - No Auto-Resolve Anywhere In The Merge/Conflict Path, Guard C - Merge Conflict State Is Reconciled, Not Just Read Once

### Community 692 - "smoke-dmg.sh"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 693 - "HeadlessRunEvent"
Cohesion: 0.67
Nodes (3): cat(), Hwe(), kYe()

### Community 694 - "Result"
Cohesion: 0.67
Nodes (3): cfn(), fut(), qYe()

### Community 695 - "FormatContext"
Cohesion: 0.67
Nodes (3): dht(), k0t(), l1n()

### Community 698 - ".snapshotChangedNotification"
Cohesion: 0.67
Nodes (3): iRe(), jNt(), zNt()

## Knowledge Gaps
- **2378 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+2373 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1132 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `LSPMessage` to `ThemeDocument`, `RD`, `GroupedSessionDaemonTests`, `AgentNotchRootView`, `Command`, `.daemonIsStale`, `ShellCompletionInstallerTests`, `TerminalEmulator`, `Changed`, `.encodeAndWait`, `PerformanceBenchmarks`, `.show`, `HarnessTerminalSurfaceView`, `VTParser`, `HarnessUILibrary`, `HarnessChrome`, `OpenClaw → Kouen`, `HarnessTerminalSurfaceView`, `code:block1 (Agent shell process)`, `.zoomWindowIfDoubleClick`, `.request`, `CopyModeAction`, `.readGrid(scrollbackOffset:)`, `RGBColor`, `.parse`, `Harness tmux-style capabilities`, `Notification`, `SplitPaneCoordinator`, `.addTab`, `Equatable`, `CodingKeys`, `LegacySnapshot`, `code:bash (harness chat "Use the project map first, then inspect this r)`, `String`, `TerminalColorGamut`, `HarnessSettings`, `CodingKeys`, `HarnessSidebarPanelViewController.swift`, `RenderSchedulerTests`, `HarnessTerminalSurfaceView.swift`, `.buildCommand`, `.normalizedKey`, `DaemonServer`, `.keyEvent`, `Fixed`, `Added`, `HarnessSplitView`, `📁 IDE Sidebar`, `NSPanel`, `BellScanState`, `PasteBufferStore`, `3.2 สิ่งที่ implement แล้ว`, `ViEngine`, `.installChromeBackground`, `ComposedCell`, `.toastErrorSummary`, `Phase67Tests`, `SwarmFleetView`, `ShellIntegration`, `KittyKeyboardTests`, `Completed Plans Archive`, `.text`, `worktree_isolation_cli.robot`, `XCTestCase`, `.parse`, `TerminalProtocolCompatibilityTests`, `Added`, `HarnessDesign`, `Agent handbook — Harness (extended reference)`, `.applyPreedit`, `.firstMatch`, `LSPClient`, `LSPDiagnostic`, `MetalRendererTests`, `Harness as a terminal multiplexer`, `.cursorPos`, `drn`, `code:bash (# Terminal 1: Create workspace with long-running job)`, `shim.c`, `SpecialKey`, `AttachInputBatcher`, `.dispatch`, `ScriptRuntime.swift`, `Session Grouping and Split Session Plan`, `DaemonLauncher`, `AnyCodable`, `INDEX.md`, `Changelog`, `AgentNotchViewModel`, `DamageTrackingTests`, `SoftIconButton`, `code:text (:workbench start swift)`, `.firstWaitingTab`, `SessionGroup`, `PaneNode`, `WorkspaceFileTreeView`, `Added`, `Changed`, `Pipe`, `HistoryRingBuffer`, `ClientSummary`, `.historyBytes`, `GlyphAtlas`, `gpn`, `WorktreeManager`, `AgentHookInstaller`, `.load`, `code:js (// ~/.config/harness/init.js)`, `CommandTarget`, `.startWatching`, `ActivePaneService`, `User Story Mapping (MANDATORY)`, `แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)`, `TerminalHostView`, `.testPaneLeafLegacyDecodeBackfillsSurfaceTabs`, `.id`, `How to use Harness from the terminal only (no GUI)`, `PaneStyleSet`, `clear-runtime-state.sh`, `DecodedImage`, `EnvironmentStore`, `.evaluate`, `Added`, `nb`, `What You Must Do When Invoked`, `LiveResizeTests`, `Int`, `ThaiCombiningMarkTests`, `gemini`, `MatchCategory`, `AmbientBackground`, `Harness Terminal — IDE Sidebar Feature Branch`, `TerminalFindBar`, `t2e`, `Added`, `CommandPromptController`, `Workspace`, `Added`, `Fixed`, `URLDetection`, `ReflowCorpusTests`, `.decodeKeySpec`, `BinaryRefresherTests`, `AutomationsFleetModelTests`, `Added`, `[3.13.1] - 2026-07-02`, `P25 — iOS/iPadOS Support`, `targets`, `Error`, `BrowserPaneView`, `.testOccludedPaneParsesButNeverPresents`, `PromptQueue`, `GlyphRasterizer`, `.classify`, `code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)`, `Harness keybindings`, `From tmux`, `SettingsRemoteView`, `PaneDropZoneOverlay`, `PaneTarget`, `Color`, `f18`, `.lines`, `f4`, `GridCompositor`, `TerminalServicesProvider`, `ANSIPalette`, `HarnessPathDisplay`, `FileChangeWatcher`, `.decide`, `TextGrid`, `.scan`, `WorkbenchCommand`, `.make`, `AgentBridge`, `ThemeDocumentTests`, `Experience modes`, `HarnessTerminalSurfaceWorkerTests`, `Split Right`, `BoardViewController`, `Motion`, `clear-runtime-state.sh`, `.welcome`, `.install`, `code:bash (harness-cli install-hooks claude-code)`, `code:bash (# Old (agent-specific):)`, `DefaultTerminalManager`, `.showsKouenControls`, `P8: macOS 27 Golden Gate Adoption`, `.testingOriginOffset`, `DisplayPanesOverlay`, `RemoteHostStoreTests`, `FormatColor`, `After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md.`, `code:bash (harness-cli install-hooks hermes)`, `Process`, `JSONDecoder`, `AgentApprovalBar`, `NotificationBus`, `jobs`, `PaneNode`, `ThemeDiagnostics`, `.encodeMouse`, `Browser DevTools API (P28)`, `FrameSignposter`, `Bug: Tab-Switch Black Screen`, `Terminal AI Chat (⌘I inline overlay)`, `code:bash (harness-cli install-hooks codex)`, `code:bash (harness-cli install-hooks grok)`, `code:bash (# In a Harness pane:)`, `FormatColor`, `Focus Persistence — Per-Session-Tab Pane Focus (RL-043)`, `WorkspaceSymbolIndex`, `FloatingPaneController`, `_2n`, `.openComposer`, `Added`, `RealPty`, `P30 — Otty Feature Parity (v3.11.x)`, `Added`, `Agent platform icons`, `[3.2.0] - 2026-06-16`, `DaemonLifecycleTests`, `.handleCat`, `[3.5.1] - 2026-06-20`, `State`, `generate-cheatsheet.js`, `[2.2.4] - 2026-06-11`, `Fixes Applied (v3.9.1+)`, `DaemonStats`, `.encode`, `DynamicInstanceBuffer`, `Identifiable`, `SurfaceProgressTrackerTests.swift`, `MCPServer`, `ThaiClusterRenderTests`, `INDEX.md`, `SKILL-LOG.md`, `User Profile`, `Darwin`, `UI Automation — Robot Framework (P18)`, `build-release.sh`, `sign-and-notarize.sh`, `View`, `PresentAttempt`, `Split Panes (NSSplitView)`, `Fixed`, `IPC Architecture`, `.applyTerminalIdentity`, `javascript.json`, `markdown.json`, `.refreshSurfaceMetadata`, `typescript.json`, `.parseDiffHunks`, `PathToken`, `SessionEditor`, `PresentAttempt`, `SessionCoordinator.swift`, `RunState`, `.worktreeList`, `AGENTS.md`, `.deinit`, `DirectionalAxis`, `PlatformSys.swift`, `Never`, `HarnessOnboarding`, `ProjectDropTarget`, `.encode`, `ScrollbackTests`, `Command Prompt Architecture`, `Changed`, `ccRunCancel`, `.automationList`, `ReleaseNotesGuardTests`, `memory_leak_guards.robot`, `qLt`?**
  _High betweenness centrality (0.290) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `HarnessSplitView` to `Equatable`, `TerminalFindBar`, `automationCreate`, `automationDelete`, `LSPMessage`, `SessionID`, `Harness keybindings`, `HarnessTerminalSurfaceView.swift`, `.normalizedKey`, `ViPathTokenTests`, `Experience modes`, `SessionCoordinator`, `AgentSnapshot`, `WorkspaceFileTreeView`, `SurfaceProgressTrackerTests.swift`, `Prompt`, `.request`?**
  _High betweenness centrality (0.212) - this node is a cross-community bridge._
- **Why does `fbt()` connect `EngineConformanceTests` to `CodingKey`, `Changed`, `AgentSnapshot`, `.handleNormal`?**
  _High betweenness centrality (0.114) - this node is a cross-community bridge._
- **Are the 18 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `RenderScheduler`) actually correct?**
  _`KouenTerminalSurfaceView` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _2398 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.006992129372321925 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.02437325905292479 - nodes in this community are weakly interconnected._