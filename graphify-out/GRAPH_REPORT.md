# Graph Report - graphify-commit-flows-20261109  (2026-11-09)

## Corpus Check
- 942 files · ~1,050,691 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 20085 nodes · 58282 edges · 2654 communities (1514 shown, 1140 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8903 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `bf6cfd1f`
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
9. `DaemonClient` - 212 edges
10. `KouenCLI` - 210 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 187 areas (208 edges)
2. `Command` - bridges 102 areas (108 edges)
3. `AgentKind` - bridges 85 areas (176 edges)
4. `t()` - bridges 84 areas (253 edges)
5. `IPCResponse` - bridges 79 areas (103 edges)
6. `KouenTerminalSurfaceView` - bridges 78 areas (345 edges)
7. `KouenPaths` - bridges 70 areas (150 edges)
8. `NSView` - bridges 67 areas (193 edges)
9. `KouenGridTerminal` - bridges 65 areas (117 edges)
10. `SessionCoordinator` - bridges 64 areas (235 edges)

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

## Communities (2654 total, 1140 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.01
Nodes (560): _0t(), _1n(), _1t(), _5e(), _5n(), _6e(), _9e(), a2t() (+552 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.02
Nodes (319): e(), f(), t(), V, z(), _6n(), _7n(), _9n() (+311 more)

### Community 2 - ".handleNormal"
Cohesion: 0.03
Nodes (299): pe(), r, X(), A(), code(), R(), a(), aD() (+291 more)

### Community 3 - "Changed"
Cohesion: 0.05
Nodes (44): ake(), aoe(), ate(), b2(), b6(), bR(), cd(), Cf() (+36 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.04
Nodes (28): NSCursor, NSRangePointer, Bool, CAMetalDrawable, NSEvent, String, Any, Bool (+20 more)

### Community 5 - "IPCRequest"
Cohesion: 0.05
Nodes (44): AgentBridge, AgentTarget, Bool, String, SurfaceID, .onCurrentCWD, .onCurrentFile, LinePos (+36 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.09
Nodes (21): Int, ImagePlacementSnapshot, SemanticMark, Bool, TerminalCursor, TerminalCursorShape, bar, block (+13 more)

### Community 7 - "Command"
Cohesion: 0.05
Nodes (35): TerminalModes, InputEncoder, .encode(_:modifiers:event:modes:), .encode(text:modifiers:modes:), .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release (+27 more)

### Community 8 - "LSPMessage"
Cohesion: 0.11
Nodes (15): MochaTheme, ANSIPalette, UInt8, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors, Bool (+7 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.10
Nodes (12): .receive(_:), DispatchSemaphore, FluidityBenchmarks, NSWindow, String, UInt64, KouenTerminalSurfaceWorkerTests, Bool (+4 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.05
Nodes (34): .snapshot, DetachedPaneOverlay, .init(coder:), .init(frame:style:), InputGate, .siblings, OutputCoalescer, ReconnectLatch (+26 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.12
Nodes (21): ArtifactKind, html, image, markdown, text, AutomationsFleetModel, .load(detectScheduledRuns:), AutomationSource (+13 more)

### Community 12 - "Changed"
Cohesion: 0.06
Nodes (41): Equatable, DecodedImage, .byteCount, UInt8, KouenGridTerminal, .currentSelectionRegion, ClosedRange, String (+33 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.08
Nodes (17): .event(_:), .interval(_:_:), StaticString, T, .init(themeName:fontFamily:fontSize:vivid:colorRendering:colorGamut:offMainParserFramePipeline:liveResizeReflow:), .testingPendingResize, PendingMainHop, SurfaceColorProviderState (+9 more)

### Community 14 - "VTParser"
Cohesion: 0.05
Nodes (25): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+17 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.21
Nodes (4): CommandTarget, String, UUID, TargetSpecTests

### Community 16 - ".applyPreedit"
Cohesion: 0.07
Nodes (26): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, AutomationScheduler (+18 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.06
Nodes (24): Command, .init(forTesting:), UUID, Void, BellScanState, esc, normal, string (+16 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.10
Nodes (11): .agentColorBinding, colors, PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Double, String (+3 more)

### Community 19 - "SpecialKey"
Cohesion: 0.06
Nodes (31): SessionDividerRowView, .init(coder:), .init(frame:), SessionGroupHeaderRowView, .init(coder:), .init(frame:), SessionWorktreeHeaderRowView, .init(coder:) (+23 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.14
Nodes (15): .exit, DaemonClient, String, String, KouenCLI, SessionID, String, Bool (+7 more)

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.07
Nodes (17): surfaceID, .surfaceID(forPaneID:), Command, Tab, SessionEditorPhase4Tests, PaneID, TabID, WorkspaceID (+9 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.07
Nodes (11): NWEndpoint, Bool, NWListener, Sendable, String, UInt16, MobileBridgeServer, PipeBuffer (+3 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.04
Nodes (55): _4n(), Af(), aIn(), aOn(), Bm(), ck(), cle(), D1() (+47 more)

### Community 24 - ".request"
Cohesion: 0.09
Nodes (15): RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), ScrollbackEntry, ScrollbackReplaySegment, Bool, CChar, DaemonSurfaceID, Int32 (+7 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.12
Nodes (13): TerminalDamage, RenderColor, MetalRendererTests, .makeRenderer(device:atlasSize:atlasMaxPages:), RenderedFixture, Bool, MTLDevice, MTLTexture (+5 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.09
Nodes (10): SessionCoordinator, .selectWorkspace(_:), Bool, Double, PaneID, String, SurfaceID, TabID (+2 more)

### Community 27 - "RGBColor"
Cohesion: 0.07
Nodes (20): CornerInfo, EditorDividerView, HitTestPassthroughView, KouenSplitView, .dividerColor, .dividerThickness, PaneDragGripView, PaneHoverButton (+12 more)

### Community 28 - ".parse"
Cohesion: 0.07
Nodes (32): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, .body, PaletteMode (+24 more)

### Community 29 - "Added"
Cohesion: 0.10
Nodes (31): files, Encodable, ExpressibleByStringLiteral, AgyModelsPush, AISuggestionAck, AttachedAck, Body, BrowserFramePush (+23 more)

### Community 30 - "Notification"
Cohesion: 0.06
Nodes (38): Bool, OptionSet, KeySpec, .description, .init(from:), .init(key:modifiers:), Modifiers, Decoder (+30 more)

### Community 31 - "Sendable"
Cohesion: 0.08
Nodes (23): DisplayLinkTarget, MainSplitViewController, .setSidebarVisible(_:), .setSidebarVisible(_:animated:), SplitChromeDelegate, .sidebarMaxWidth, .sidebarMinWidth, .splitView(_:constrainMaxCoordinate:ofSubviewAt:) (+15 more)

### Community 32 - ".addTab"
Cohesion: 0.08
Nodes (26): Array, GroupHeaderRow, .body, PickerItem, .groupLabel, historyBlock, .id, recipe (+18 more)

### Community 33 - "Equatable"
Cohesion: 0.10
Nodes (15): ConcurrentIndexSet, .count, DaemonContentionTests, String, URL, DaemonRoundTripTests, String, TimeInterval (+7 more)

### Community 34 - "DaemonClient"
Cohesion: 0.04
Nodes (76): a4e(), aae(), adn(), AI(), aXe(), B1(), bee(), Bsn() (+68 more)

### Community 35 - "MenuTarget"
Cohesion: 0.09
Nodes (8): KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), SpawnedAgentSurface, Bool, ISO8601DateFormatter, String, Tab, UUID

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.07
Nodes (35): .init(entry:), AgentChipView, .init(coder:), .intrinsicContentSize, Colors, FontSize, IconSize, KouenMotion (+27 more)

### Community 37 - "String"
Cohesion: 0.12
Nodes (10): .readJSONLLines(from:fromOffset:), ClaudeSessionLocator, Role, assistant, user, Int32, URL, TranscriptItem (+2 more)

### Community 38 - "code:bash (swift build)"
Cohesion: 0.18
Nodes (15): a2(), akn(), bpn(), cIn(), ift(), p7n(), pyn(), R1() (+7 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.11
Nodes (11): Bool, String, UInt8, TerminalEmulator, .captureLines(fromLine:toLine:), .onSetClipboard, TerminalColorRole, background (+3 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.12
Nodes (17): IssueKeychainStore, Bool, String, IssueTrackerType, azureDevOps, github, .id, jira (+9 more)

### Community 41 - "CodingKeys"
Cohesion: 0.08
Nodes (16): DisplayWidth, String, Unicode, ReleaseNotes, Section, String, Run, String (+8 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.11
Nodes (12): .addSurface(tabID:paneID:), .tab(containingPaneID:), .tab(for:), .tab(forSurfaceKey:), .tabIndex(surfaceKey:), .tabIndex(tabID:), .tabIndex(workspaceID:tabID:), Date (+4 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.10
Nodes (41): Ame(), aQt(), aXt(), Cme(), cXt(), DYt(), een(), Eme() (+33 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.10
Nodes (38): MTLClearColor, MTLCommandBuffer, MTLLibrary, MTLRenderCommandEncoder, MTLRenderPipelineState, BgInstance, CursorCacheKey, .invertsGlyph (+30 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.10
Nodes (7): Bool, Command, DispatchWorkItem, PaneID, String, UInt8, WindowSession

### Community 46 - ".buildCommand"
Cohesion: 0.09
Nodes (30): DaemonSubscription, .start(onData:onEnd:buffered:), .start(onResponse:onEnd:), Bool, Int32, TimeInterval, UInt64, UUID (+22 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.15
Nodes (7): AnyCodable, JSONRPCError, Bool, Int32, Pipe, String, ToolRegistry

### Community 48 - "HookEvent"
Cohesion: 0.07
Nodes (24): String, UInt16, Data, OSCTerminatorMatch, DecodedReplyFrame, output, reply, DecodedRequestFrame (+16 more)

### Community 49 - "DaemonServer"
Cohesion: 0.17
Nodes (12): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+4 more)

### Community 50 - "Added"
Cohesion: 0.07
Nodes (50): Codable, BrowserSnapshotAck, agentWaitChannel(), BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserRequestPayload (+42 more)

### Community 51 - ".keyEvent"
Cohesion: 0.17
Nodes (3): AgentSessionHistoryModelTests, Date, String

### Community 52 - "Fixed"
Cohesion: 0.07
Nodes (10): ClaudeCodeHarnessIPCTests, String, URL, DaemonBrowserRoutingTests, IPCCodecInvariantTests, String, URL, EndpointClientTests (+2 more)

### Community 53 - "Added"
Cohesion: 0.08
Nodes (27): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+19 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.11
Nodes (28): .saveRecordsBatch(_:), CachedSessionEntry, AgentHistoryScanner, .parseAntigravityTranscript(sessionID:fileURL:), .parseClaudeTranscript(fileURL:), .parseCodexTranscript(fileURL:surfaceTag:ftsIndex:), .readAntigravitySummaries(dbPath:brainDir:ftsIndex:), .readAntigravitySummaries(dbPath:brainDir:ftsIndex:fileCache:) (+20 more)

### Community 55 - "TabCell"
Cohesion: 0.14
Nodes (17): ClientRecord, CountBox, DaemonServer, .guiBrowserFD, PendingBrowserRequest, PendingWrite, Bool, CheckedContinuation (+9 more)

### Community 56 - "NSPanel"
Cohesion: 0.08
Nodes (31): a0n(), aA(), dl(), eAn(), ebt(), eht(), eMt(), ewn() (+23 more)

### Community 57 - "BellScanState"
Cohesion: 0.10
Nodes (18): Process, SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, SSHTunnelManager (+10 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.07
Nodes (25): Error, LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed, serverNotExecutable, AsyncStream (+17 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.05
Nodes (51): AnyTransition, Color, .hexString, AgentNotchPeekEvent, AgentNotchRootView, .body, .bottomRadius, .closedAccessibilityLabel (+43 more)

### Community 60 - "ViEngine"
Cohesion: 0.09
Nodes (18): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+10 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.06
Nodes (34): Executor, Hook, HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane (+26 more)

### Community 62 - "ComposedCell"
Cohesion: 0.06
Nodes (29): JSONDecoder, JSONEncoder, CodingKeys, cols, createdAt, dataBase64, rows, timeMs (+21 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.08
Nodes (26): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary, RowKind (+18 more)

### Community 64 - ".text"
Cohesion: 0.05
Nodes (24): AgentDetection, AgentDetector, AgentTableEntry, MatchSource, ownProcess, wrapperLaunch, RawMatch, Bool (+16 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.10
Nodes (22): AppKit, CoreGraphics, CoreText, ImageIO, KouenCopyMode, KouenTerminalEngine, KouenTerminalRenderer, KouenTheme (+14 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.09
Nodes (18): .requestDaemon(_:), .selectWorkspace(byIndex:), .syncFromDaemon(metadataOnly:), ActiveTabCloseDisposition, session, tab, window, workspace (+10 more)

### Community 67 - "String"
Cohesion: 0.05
Nodes (28): DaemonClientActor, TimeInterval, DaemonSessionError, daemonError, .description, unexpectedResponse, DaemonSessionService, .endpoint (+20 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.08
Nodes (13): SessionGroup, SessionID, String, KouenSidebarPanelViewController, NSMenuItem, SessionGroup, String, NSMenu (+5 more)

### Community 69 - ".compose"
Cohesion: 0.06
Nodes (31): AgentBrowserPaneTracker, SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, SessionID, Set (+23 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.11
Nodes (11): ParsedShortcut, .displayString, PrefixKeymap, Any, NSEvent, String, TimeInterval, ControlKeyNormalizer (+3 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.08
Nodes (30): .filteredJobs, MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith (+22 more)

### Community 72 - "XCTestCase"
Cohesion: 0.08
Nodes (42): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+34 more)

### Community 73 - "README.md"
Cohesion: 0.09
Nodes (23): OptionStore, OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Scope, global (+15 more)

### Community 74 - "[2.6.0] - 2026-06-13"
Cohesion: 0.15
Nodes (9): StringKind, apc, dcs, UInt8, UnsafeBufferPointer, VTParser, .feed(_:), VTParserHandler (+1 more)

### Community 75 - "OptionStore"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 76 - ".parse"
Cohesion: 0.06
Nodes (45): aR(), cKt(), cYt(), dC(), DGt(), dm(), ece(), fGt() (+37 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.07
Nodes (36): .notifySection, .themeSection, ColorHexRow, .body, .colorBinding, .currentHex, .isCustom, PaletteCell (+28 more)

### Community 78 - "Added"
Cohesion: 0.08
Nodes (14): Tab, BrowserIntegrationController, PaneID, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), .init(paneID:), PaneID, SurfaceID (+6 more)

### Community 79 - "HarnessDesign"
Cohesion: 0.08
Nodes (6): KouenSettings, Bool, ExperienceModeTests, KouenSettingsTests, URL, Void

### Community 80 - "Agent handbook — Harness (extended reference)"
Cohesion: 0.07
Nodes (17): KouenCLITests, CLIInstallLocator, DetachKeys, absent, invalid, parsed, OptionalUUID, absent (+9 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.09
Nodes (10): Bool, DispatchWorkItem, NSEvent, NSPopover, NSRange, NSString, Void, SyntaxTextView (+2 more)

### Community 82 - ".firstMatch"
Cohesion: 0.12
Nodes (19): AgentHistoryFTSIndex, .deleteSession(sessionID:), .needsReindex(sessionID:mtime:fileSize:), .pruneMissingSessions(validTranscriptPaths:), .saveRecord(_:mtime:fileSize:), .search(query:limit:), .searchRanked(query:limit:includeSnippet:requireAllTokens:includeMetadata:matchingIDs:), .searchSubstring(query:includeEvidence:matchingIDs:) (+11 more)

### Community 83 - "LSPClient"
Cohesion: 0.13
Nodes (19): eJ(), fme(), fwn(), gKt(), gUe(), $He(), LC(), lKt() (+11 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.11
Nodes (22): keys, ITerm2InlineImage, .heightArg, .preserveAspectRatio, .widthArg, Bool, String, UInt8 (+14 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.07
Nodes (35): ColorKind, .base, bg, fg, underline, ComposedCell, .asGridCell, .cluster (+27 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.09
Nodes (16): .effectiveResumeCommand(claudeMode:), LiveClaudeAgentEntry, .placement, ClaudeSessionMode, TimeoutFlag, .didFire, ClaudeCloudSessionStore, Entry (+8 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.12
Nodes (14): AsyncRunCoordinator, OutputBuffer, ProcessResult, .isSuccess, ProcessRunner, Bool, CheckedContinuation, DispatchWorkItem (+6 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.03
Nodes (90): _2t(), a8n(), ase(), aTn(), aV(), bb(), c2t(), c9e() (+82 more)

### Community 89 - ".cursorPos"
Cohesion: 0.15
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 91 - "TerminalModes"
Cohesion: 0.12
Nodes (10): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, PaneID (+2 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.07
Nodes (25): BrowserPaneRegistry, .init(coder:), .init(url:paneID:), BrowserProgressLine, .init(coder:), .init(frame:), BrowserTabButton, .init(coder:) (+17 more)

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.13
Nodes (14): .lspPosition(characterOffset:), LSPDiagnostic, LSPDiagnosticSeverity, error, hint, information, warning, LSPHover (+6 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.08
Nodes (37): MonoPillButtonStyle, Configuration, ButtonStyle, CommandRow, .body, GlassCard, .body, GlassPrimaryButtonStyle (+29 more)

### Community 95 - "shim.c"
Cohesion: 0.08
Nodes (26): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+18 more)

### Community 96 - "Harness Usage"
Cohesion: 0.09
Nodes (20): .body, Kind, primary, secondary, KouenDesign, KouenPillButton, .init(title:kind:), .isHovered (+12 more)

### Community 97 - "PaneContainerView"
Cohesion: 0.07
Nodes (45): AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem, fetchGitStatus() (+37 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.18
Nodes (11): .mcpButton, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter, Any, Range (+3 more)

### Community 99 - ".dispatch"
Cohesion: 0.05
Nodes (38): Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions, Logical Design, P41 — Automations, Strategic Design, Tactical Design (+30 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.09
Nodes (23): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, IssueInfo (+15 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.10
Nodes (14): NotchMaskAnimator, Bool, CGFloat, CGRect, NotchPanel, .canBecomeKey, .canBecomeMain, Bool (+6 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.16
Nodes (11): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, .init(from:), .init(id:name:baseURL:modelID:), Decoder (+3 more)

### Community 103 - "AnyCodable"
Cohesion: 0.08
Nodes (18): NSScrollView, NSWindow, Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent (+10 more)

### Community 104 - "Recipe"
Cohesion: 0.07
Nodes (21): GitAheadBehind, GitResult, .isSuccess, GitWorktreeInfo, Bool, Int32, String, GitParsers (+13 more)

### Community 105 - "Changelog"
Cohesion: 0.08
Nodes (18): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, PaneID, SurfaceID (+10 more)

### Community 106 - "domain-design.md"
Cohesion: 0.11
Nodes (10): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+2 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.16
Nodes (4): hooks, AgentHookInstallerTests, String, URL

### Community 108 - ".resolve"
Cohesion: 0.18
Nodes (11): SwarmSpawnSpec, CallRecorder, .cancelCalls, .closeCalls, .harnessCalls, .surfaceCalls, SwarmWorkerManagerTests, Bool (+3 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.16
Nodes (11): AYt(), epn(), EUe(), eYt(), lq(), ple(), rp(), sut() (+3 more)

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.05
Nodes (23): NSResponder, FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel, NSSearchFieldDelegate (+15 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.17
Nodes (4): FilePreviewCoordinator, FileTabID, Set, String

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.14
Nodes (21): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), .stats (+13 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.14
Nodes (18): CommandParseError, .description, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand (+10 more)

### Community 115 - ".encode"
Cohesion: 0.14
Nodes (14): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+6 more)

### Community 116 - "SessionGroup"
Cohesion: 0.15
Nodes (9): FormatContext, FormatString, FormatStyle, Bool, Character, Date, String, FormatStyledTests (+1 more)

### Community 117 - "PaneNode"
Cohesion: 0.11
Nodes (7): Bool, Range, Set, String, URLDetection, StringProtocol, EngineConformanceTests

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.14
Nodes (8): MutationResult, RemoteHost, RemoteHostStore, Bool, String, RemoteHostStoreTests, String, URL

### Community 119 - "Harness command reference"
Cohesion: 0.11
Nodes (15): FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect, String, URL (+7 more)

### Community 120 - "Added"
Cohesion: 0.13
Nodes (10): MarkdownPreviewView, .webView(_:decidePolicyFor:decisionHandler:), Bool, MainActor, Sendable, String, URL, WKNavigationAction (+2 more)

### Community 121 - "Changed"
Cohesion: 0.13
Nodes (15): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+7 more)

### Community 122 - "ViEngine"
Cohesion: 0.10
Nodes (17): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent, ScrollbackFile (+9 more)

### Community 123 - "Pipe"
Cohesion: 0.09
Nodes (30): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+22 more)

### Community 124 - "String"
Cohesion: 0.07
Nodes (25): FilterStatus, active, all, completed, CaseIterable, LayoutTemplate, evenHorizontal, evenVertical (+17 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.12
Nodes (17): FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID, FeatureTask (+9 more)

### Community 126 - ".path"
Cohesion: 0.09
Nodes (15): PluginLoader, String, ScriptAPI, ScriptError, .errorDescription, evaluationError, unsupportedPlatform, ScriptRuntime (+7 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.11
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.11
Nodes (6): GitPanelView, .isHidden, Any, DispatchWorkItem, NSMenuItem, UnsafeMutableRawPointer

### Community 129 - "SwiftUI"
Cohesion: 0.12
Nodes (9): BrowserPaneView, DesignModeElementInfo, Any, DispatchWorkItem, NSPopover, ObjectIdentifier, Selector, String (+1 more)

### Community 130 - "Harness"
Cohesion: 0.11
Nodes (19): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerFooter, .body, DirectoryPickerModel (+11 more)

### Community 131 - ".install"
Cohesion: 0.14
Nodes (15): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+7 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.12
Nodes (9): .captureLines(joinWrapped:), .feed(_:), .promptRows, .readGrid(scrollbackOffset:), ScrollbackTests, Character, String, SemanticPromptTests (+1 more)

### Community 133 - ".load"
Cohesion: 0.08
Nodes (31): .windowSection, .renderingSection, KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:fileSearchRoots:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:), .scrollbackLines, LegacyKouenSettingsCodingKeys, commandFinishedNotifications (+23 more)

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.06
Nodes (27): Codex → Kouen, One-line install, What you'll see, Cursor Agent → Kouen, Manual fallback, One-line install, What you'll see, Grok Build → Kouen (+19 more)

### Community 135 - "CommandTarget"
Cohesion: 0.09
Nodes (23): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+15 more)

### Community 136 - ".startWatching"
Cohesion: 0.16
Nodes (17): EndpointConnector, Int32, String, decodeBoundedCString(), ignoreSIGPIPE(), makeUnixStreamSocket(), setNoSigPipe(), CChar (+9 more)

### Community 137 - "ActivePaneService"
Cohesion: 0.07
Nodes (22): DaemonCommandExecutor, SurfaceRegistry, Set, PendingVersionBanner, welcome, whatsNew, State, Bool (+14 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.11
Nodes (22): BinaryInstaller, .bundledMacOSDir, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display (+14 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.01
Nodes (294): _3n(), _4e(), _8n(), a2n(), a6(), a7e(), a9e(), a_n() (+286 more)

### Community 140 - "Added"
Cohesion: 0.07
Nodes (39): A1(), AS(), bvt(), bw(), cc(), d2(), d6(), dce() (+31 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.12
Nodes (28): aJ(), bXt(), cJ(), dXt(), F0(), fXt(), gC(), gXt() (+20 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.11
Nodes (14): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+6 more)

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.16
Nodes (9): FileGraphInfo, GraphifyLSPBridge, Double, String, URL, GraphifyLSPBridgeTests, Any, String (+1 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.11
Nodes (13): FileFuzzyMatcher, FileSearchRootScanner, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool (+5 more)

### Community 145 - "AsciiFastPathTests"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, S (+2 more)

### Community 146 - "DecodedImage"
Cohesion: 0.14
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 147 - "FileTreeWatcher"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 148 - "TriState"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.02
Nodes (118): a1t(), amn(), B0, BBe(), bCn(), _c(), cA(), cEn() (+110 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.07
Nodes (20): StatusLineView, .init(coder:), Bool, CGFloat, Never, NSAttributedString, NSCoder, NSColor (+12 more)

### Community 151 - ".evaluate"
Cohesion: 0.10
Nodes (19): Coordinator, DiffAnalysis, DiffFileItem, DiffFileStatus, added, .color, deleted, modified (+11 more)

### Community 152 - "Added"
Cohesion: 0.10
Nodes (13): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+5 more)

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.18
Nodes (8): FileNode, Bool, String, FileTreeScanOptions, ScoredMatch, Bool, String, .body

### Community 154 - "LiveResizeTests"
Cohesion: 0.10
Nodes (4): Pen, SavedCursor, TerminalScreen, .cursorVisible

### Community 155 - "Int"
Cohesion: 0.11
Nodes (11): DataBox, .removeWorktreeAction(path:), GitResult, Bool, GitResult, String, TimeInterval, ValidateOutcome (+3 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.12
Nodes (12): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+4 more)

### Community 157 - "Added"
Cohesion: 0.17
Nodes (11): AgentSessionHistoryView, .body, .footerView, Bool, CGFloat, Date, NSColor, NSFont (+3 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.16
Nodes (15): ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool, Command (+7 more)

### Community 159 - "MatchCategory"
Cohesion: 0.12
Nodes (12): ShellLaunchProfile, .argv, ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID (+4 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.06
Nodes (53): a(), b(), c(), d(), g(), h(), I(), j() (+45 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.11
Nodes (12): FlippedView, .isFlipped, .removeWorktreeAction(_:), NSButton, NSColor, NSRect, NSScrollView, NSStackView (+4 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.13
Nodes (13): MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem, SessionGroup (+5 more)

### Community 163 - "Workspace"
Cohesion: 0.13
Nodes (14): CompletionPopupView, .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:), .isHovered, Bool (+6 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.09
Nodes (11): Bool, NSDraggingInfo, NSDragOperation, Bool, NSDraggingInfo, NSDragOperation, NSPasteboard, URL (+3 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.06
Nodes (34): FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body, .emptyState (+26 more)

### Community 166 - "LiveSession"
Cohesion: 0.08
Nodes (24): Darwin, Foundation, Glibc, KouenCore, AgentRoutingResolver, FormatContextBuilder, PtyError, launchFailed (+16 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.12
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 168 - "Added"
Cohesion: 0.11
Nodes (8): CGFloat, NSEvent, CGFloat, CGRect, NSEvent, NSPoint, Range, String

### Community 169 - "Fixed"
Cohesion: 0.08
Nodes (24): aie(), arc(), b2e(), bezierCurveTo(), closePath(), cRe(), cZ(), E7() (+16 more)

### Community 170 - "URLDetection"
Cohesion: 0.14
Nodes (36): aQ(), bme(), bqt(), bYt(), cbe(), DD(), dqt(), Dr() (+28 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.11
Nodes (25): Cqt(), CUe(), eXt(), GYt(), H7(), hqt(), IUe(), iXt() (+17 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.08
Nodes (7): Divergence, Bool, String, TimeInterval, WorktreeInfo, String, WorktreeIsolationTests

### Community 173 - "BoardCard"
Cohesion: 0.15
Nodes (13): .webView(_:didCommit:), .webView(_:didFinish:), WKWebViewConfiguration, BrowserPaneViewTests, MockWebView, .isLoading, .title, .url (+5 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.11
Nodes (15): OverlayBackground, Context, OverlayBackground, Context, .init(coder:), KouenOverlayBackground, .init(coder:), .init(coder:) (+7 more)

### Community 175 - "RGBColorTests"
Cohesion: 0.12
Nodes (21): FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose, FileTabPillView (+13 more)

### Community 176 - "Added"
Cohesion: 0.16
Nodes (10): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab, UUID (+2 more)

### Community 177 - ".rects"
Cohesion: 0.16
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 178 - "InlineAICompletionView"
Cohesion: 0.15
Nodes (16): ClaudeCodeHarness, Profile, edit, readonly, Run, RunState, cancelled, failed (+8 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.13
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.12
Nodes (16): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, .rootPicker, FileTreeContext (+8 more)

### Community 181 - "GridCompositorTests"
Cohesion: 0.12
Nodes (24): .color, BoardCard, BoardColumn, .name, BoardColumnKind, .displayName, done, error (+16 more)

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.21
Nodes (5): CopyModeReducerTests, FakeGrid, .totalLines, Set, String

### Community 183 - "LSPServerRegistry"
Cohesion: 0.12
Nodes (10): .readJSONLLines(from:), AntigravitySessionLocator, AntigravityTranscriptLine, Bool, Int32, NSRegularExpression, String, URL (+2 more)

### Community 184 - "targets"
Cohesion: 0.14
Nodes (28): Cleanup Test Repo, Close Isolated Session Keeps Dirty Worktree, Close Isolated Session Removes Clean Worktree, Close One Isolated Does Not Affect Another, Close Session With Split Panes Removes Worktree, Create Isolated Session, Create Isolated Session Via CLI, Get Active Pane (+20 more)

### Community 185 - "SessionSnapshot"
Cohesion: 0.14
Nodes (7): KeybindingsStore, .fileURL, URL, KeybindingsStoreTests, URL, Void, String

### Community 186 - "Error"
Cohesion: 0.09
Nodes (18): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+10 more)

### Community 187 - "AppDelegate"
Cohesion: 0.11
Nodes (20): Motion, .entrance, .spring, .standardEase, CAMediaTimingFunction, NSWindowController, KouenOnboarding, Bool (+12 more)

### Community 188 - "BrowserPaneView"
Cohesion: 0.07
Nodes (28): Additional `kouen-cli` subcommands, Agent safety CLI (`kouen-cli`), Agents, context and scratchpad, Attaching from a plain terminal, Bindings, Board and attention, Buffers (paste store), Composition (+20 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.22
Nodes (10): CopyModeGridSource, .promptRows, ClosedRange, CopyModeReducer, Bool, Character, NSRegularExpression, Range (+2 more)

### Community 190 - "user-stories.md"
Cohesion: 0.22
Nodes (4): tool, KouenDaemonToolsTests, String, URL

### Community 191 - "ScriptRuntime"
Cohesion: 0.06
Nodes (28): Notification.Name, KouenGit, os, Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached (+20 more)

### Community 192 - "GlyphRasterizer"
Cohesion: 0.14
Nodes (13): AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID, .snapshotPayload, NotificationBus (+5 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.18
Nodes (3): fQ, hqe(), M9()

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.24
Nodes (9): Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock, .block(id:) (+1 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.13
Nodes (18): AgentRow, .agentColor, .executables, .hookButton, .hookButtonTitle, HookState, failed, idle (+10 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.13
Nodes (23): Colors, Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors (+15 more)

### Community 198 - ".classify"
Cohesion: 0.19
Nodes (11): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, .selectedHost (+3 more)

### Community 199 - "code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)"
Cohesion: 0.15
Nodes (14): SettingsTerminalView, .body, .experienceSection, .fontReadout, .fontSection, .shellSection, Bool, String (+6 more)

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.11
Nodes (17): .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:), .init(frame:) (+9 more)

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.12
Nodes (18): .agentInfo(forWorktreePath:), AgentNotchPeekDecider, Reason, errored, finished, needsInput, RowState, Bool (+10 more)

### Community 202 - "PaletteModel"
Cohesion: 0.07
Nodes (22): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController, ProjectGroupResolver (+14 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.14
Nodes (13): BranchSwitchHelper, FileTreeNode, FileTreeSwiftUIView, .body, .pastedImagesSection, .scanOptions, Notification.Name, Bool (+5 more)

### Community 204 - "From tmux"
Cohesion: 0.18
Nodes (12): GitStatusType, added, deleted, modified, renamed, unmodified, untracked, NodeRow (+4 more)

### Community 205 - "CopyModeState"
Cohesion: 0.10
Nodes (16): .pairedAlreadyBanner, .pairingQRPanel, AutomationsFleetView, .automationsList, .body, .emptyFleetView, .headerBar, .sidebarEmptyView (+8 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.12
Nodes (11): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, osc (+3 more)

### Community 207 - "scheduleRender"
Cohesion: 0.14
Nodes (7): SGRMouse, SGRMouseEvent, Bool, UInt8, SGRMouseTests, String, UInt8

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.09
Nodes (16): AgyModelCatalog, Catalog, Date, String, TimeInterval, AgyMobileCommands, String, ClaudeMobileCommands (+8 more)

### Community 209 - "SettingsRemoteView"
Cohesion: 0.13
Nodes (12): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+4 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.09
Nodes (27): aNt(), bNt(), bu(), cNt(), dNt(), dwn(), eNt(), eRe() (+19 more)

### Community 211 - "PaneTarget"
Cohesion: 0.10
Nodes (9): String, WorkspaceID, CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab, DaemonSyncServiceBranchNotifyTests (+1 more)

### Community 212 - ".translate"
Cohesion: 0.15
Nodes (11): .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), NSStackView, URL, WKNavigationAction, WKWebView, NSAppearance, BrowserOcclusionTests (+3 more)

### Community 213 - "String"
Cohesion: 0.11
Nodes (20): DiffLineType, added, deleted, modified, Notification.Name, ObserverToken, NSCoder, NSObjectProtocol (+12 more)

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.20
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 215 - ".lines"
Cohesion: 0.15
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, PaneID, SurfaceID (+3 more)

### Community 216 - "CellColorResolverTests"
Cohesion: 0.10
Nodes (9): SessionEditor, .tabIndex(surfaceID:), SessionID, AgentSessionSummaryTests, GroupedSessionTests, SessionGroup, Set, SurfaceID (+1 more)

### Community 217 - "GridCompositor"
Cohesion: 0.06
Nodes (34): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, SessionGroup, SessionID (+26 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.10
Nodes (19): CompleteStepView, Void, OnboardingStep, complete, discover, .id, setup, shell (+11 more)

### Community 220 - "Section"
Cohesion: 0.18
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.09
Nodes (21): ModelProvider, .agentKindForLogo, aider, anthropic, azure, copilot, cursor, google (+13 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.15
Nodes (11): .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didStartProvisionalNavigation:), .init(title:isActive:onSelect:onClose:), LoadCompletionState, Bool, CheckedContinuation, Double (+3 more)

### Community 224 - "CellColorResolver"
Cohesion: 0.18
Nodes (9): AnyView, .rowList, AgentNotchViewModel, .visibleRows, .waitingCount, Bool, CGFloat, Duration (+1 more)

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.17
Nodes (11): NotchGeometry, .fallback, NSScreen, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics (+3 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.07
Nodes (32): CGFloat, FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView (+24 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.12
Nodes (12): CryptoKit, Network, DecodedWSFrame, Bool, ConnectionState, NWConnection, String, UInt8 (+4 more)

### Community 228 - "sessionRow"
Cohesion: 0.25
Nodes (5): .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:surfaceTag:topicSegments:), AgentHistorySearchTests, String, TimeInterval, URL

### Community 229 - ".decide"
Cohesion: 0.11
Nodes (16): CodingKeys, error, id, jsonrpc, method, JSONRPCId, int, string (+8 more)

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.21
Nodes (7): BrowserOkAck, Sendable, T, ConnectionState, ErrorAck, NWConnection, UUID

### Community 231 - "ExternalOpenKind"
Cohesion: 0.12
Nodes (8): String, LSPDefinitionPayload, LSPDiagnosticsPayload, LSPStatusPayload, String, UInt64, URL, Set

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.16
Nodes (3): CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 233 - "TextGrid"
Cohesion: 0.15
Nodes (16): AgentMark, .body, AgentMarkShape, Scanner, .atEnd, SVGPath, Bool, CGFloat (+8 more)

### Community 234 - ".scan"
Cohesion: 0.05
Nodes (33): l, o, al(), aZ(), bct(), bdn(), bIn(), c9n() (+25 more)

### Community 235 - "WorkbenchCommand"
Cohesion: 0.12
Nodes (7): azt(), cqe(), F7, ibe(), mathmlBuilder(), q$e(), UHt()

### Community 236 - "Added"
Cohesion: 0.16
Nodes (4): l8e(), $Rt(), tJe(), YUt

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.07
Nodes (12): Range, String, TerminalBufferMatch, TerminalBufferSearch, String, TextGrid, .totalLines, .viewportRows (+4 more)

### Community 238 - ".make"
Cohesion: 0.16
Nodes (11): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+3 more)

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.17
Nodes (9): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ProcessInfo (+1 more)

### Community 240 - "PaneBorderStatus"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 241 - "Added"
Cohesion: 0.10
Nodes (4): TabID, WorkspaceID, MenuTarget, GitPanelViewWorktreeNavigationTests

### Community 242 - "AgentBridge"
Cohesion: 0.12
Nodes (16): .onSelect, agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:) (+8 more)

### Community 243 - ".make"
Cohesion: 0.14
Nodes (12): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+4 more)

### Community 244 - "FileNode"
Cohesion: 0.15
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.08
Nodes (25): Font, .kouenBadge, .kouenBody, .kouenBodyStrong, .kouenCaption2, .kouenCaption, .kouenKbd, .kouenMono (+17 more)

### Community 246 - "Experience modes"
Cohesion: 0.15
Nodes (8): BoardViewController, .isVisible, FlippedView, .isFlipped, Bool, Set, TabID, BoardViewControllerTests

### Community 247 - ".renderFixture"
Cohesion: 0.17
Nodes (8): Keyboard Shortcuts, AI Browser Control (kouen-mcp), Install, Shell integration (OSC 133 semantic prompts), What gets emitted, Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 248 - "DaemonMetrics"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.22
Nodes (4): AgentScanner, Bool, DispatchSourceTimer, TimeInterval

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 251 - "SessionCoordinator"
Cohesion: 0.16
Nodes (10): String, AgentRoutingRule, Kind, path, stack, Bool, Date, UUID (+2 more)

### Community 252 - "NSViewRepresentable"
Cohesion: 0.22
Nodes (7): AgentRoutingRuleStore, Bool, String, URL, UUID, AgentRoutingRuleStoreTests, URL

### Community 253 - "Split Right"
Cohesion: 0.15
Nodes (16): DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:), .isWorktreeSession (+8 more)

### Community 254 - "BoardViewController"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 255 - "release-hotfix.sh"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 256 - "GitMetadataProvider"
Cohesion: 0.17
Nodes (4): AgentHistoryMultiAgentCoverageTests, Bool, String, URL

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.08
Nodes (6): CodepointRunFastPathTests, .assertAllPathsAgree(_:cols:rows:file:line:), StaticString, String, UInt, UInt8

### Community 258 - "WindowTitleStripView"
Cohesion: 0.16
Nodes (12): UInt16, TTYSize, RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal (+4 more)

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.12
Nodes (9): BrowserLeaf, PaneID, URL, Decoder, .init(from:), DaemonSyncServiceBrowserPaneMergeTests, PaneID, PaneNodeBrowserTests (+1 more)

### Community 260 - ".welcome"
Cohesion: 0.13
Nodes (20): .modifierFlags, NSEvent, CodingKey, BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts (+12 more)

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.14
Nodes (12): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+4 more)

### Community 262 - ".install"
Cohesion: 0.08
Nodes (23): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSEvent (+15 more)

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.23
Nodes (8): NaturalLanguage, AgentHistorySearch, Hit, IDFCache, Bool, Double, String, .tokenHits(_:inNormalized:)

### Community 264 - "code:bash (harness-cli install-hooks claude-code)"
Cohesion: 0.14
Nodes (6): TimeInterval, AgentHandoffBuilder, Bool, String, HandoffDirectoryTests, AgentHandoffBuilderTests

### Community 265 - "code:bash (harness-cli install-hooks cursor)"
Cohesion: 0.08
Nodes (29): _3e(), bwt(), d2t(), fun(), ggn(), ixn(), k3n(), k5n() (+21 more)

### Community 266 - ".path"
Cohesion: 0.18
Nodes (14): ProjectGroupWatcher, StreamBox, Bool, DispatchQueue, escaping, FSEventStreamRef, MainActor, Never (+6 more)

### Community 267 - ".performInstall"
Cohesion: 0.07
Nodes (32): CustomStringConvertible, URL, DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed (+24 more)

### Community 268 - "code:bash (# Old (agent-specific):)"
Cohesion: 0.17
Nodes (21): Decodable, Item, ItemCompletedLine, LegacyMsgLine, Msg, String, ThreadStartedLine, AgentCommandRequest (+13 more)

### Community 269 - "DefaultTerminalManager"
Cohesion: 0.14
Nodes (11): CKouenSys, pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal (+3 more)

### Community 270 - "WindowSession"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 271 - "StatusLineView.swift"
Cohesion: 0.27
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 272 - "SGRMouseEvent"
Cohesion: 0.16
Nodes (4): ContentAreaViewController, Bool, String, Notification

### Community 273 - "KeySpec"
Cohesion: 0.12
Nodes (9): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, KouenApp, FileChangeWatcherTests (+1 more)

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.18
Nodes (20): CoreImage, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription, .surfaceID, detectHost() (+12 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.14
Nodes (6): KouenIPC, SQLite3, PortableRelativeDateFormatter, Date, String, UUID

### Community 277 - ".run"
Cohesion: 0.16
Nodes (12): CGFloat, NSCoder, SessionID, String, Void, TaskDashboardBody, .body, TaskDashboardView (+4 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.13
Nodes (10): .effectiveResumeCommand(mode:), AgentLaunchCommands, AgentSessionMode, cloud, .launchCommand, .launchFlags, local, remoteControl (+2 more)

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.16
Nodes (9): AgentListFormatter, Date, String, dvn(), ht(), AgentListFormatterTests, Bool, Date (+1 more)

### Community 280 - ".menu"
Cohesion: 0.17
Nodes (8): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, String, PaneStyleTests

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.15
Nodes (9): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, Set, SurfaceID, Tab (+1 more)

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.17
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 283 - "FormatColor"
Cohesion: 0.14
Nodes (16): AgentSessionHistoryModel, .extraRecordsShown, .filteredRecords, .records, .searchQuery, .selectedAgents, .selectedIndex, .selectedScope (+8 more)

### Community 284 - "click_ui_element"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.30
Nodes (4): TaskStore, tasks, URL, TaskStoreTests

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.28
Nodes (7): Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 287 - ".apply"
Cohesion: 0.13
Nodes (3): AgentLaunchCommandsTests, URL, Void

### Community 289 - "StatusLineWidthTests"
Cohesion: 0.19
Nodes (6): Case, ReflowCorpusTests, .corpus, .goldenDir, String, URL

### Community 290 - "Process"
Cohesion: 0.14
Nodes (5): Any, NSMenu, NSMenuItem, String, String

### Community 291 - "JSONDecoder"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Kouen, Sparkle (+13 more)

### Community 292 - "Release runbook"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 294 - "GitHubCLIClient"
Cohesion: 0.10
Nodes (20): Agent Memory, AI-SDLC — Dev/QA Workflow Spine, AODD: the operating contract, AODD triage: every request passes this gate (silently, no announcement), Approval Gates (mandatory on the Requirement path), Audit and Done, Cheap-model delegation, Core facts (non-negotiable, not model-inferable — everything else is judgment) (+12 more)

### Community 295 - "AgentApprovalBar"
Cohesion: 0.17
Nodes (7): AIProviderAwakeService, .closedLidOptedIn, Bool, NSObjectProtocol, Set, String, AIProviderAwakeServiceTests

### Community 296 - "NotificationBus"
Cohesion: 0.13
Nodes (16): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+8 more)

### Community 297 - "settings.json"
Cohesion: 0.18
Nodes (11): Never, NSRegularExpression, Set, String, Task, URL, Void, WorkspaceSymbolIndex (+3 more)

### Community 298 - "jobs"
Cohesion: 0.16
Nodes (8): CustomEndpointTester, Result, Bool, String, URL, CustomEndpointTesterTests, URLRequest, URLSession

### Community 299 - "PaneNode"
Cohesion: 0.11
Nodes (13): AgentHistoryDateGroup, older, .sortOrder, thisWeek, today, yesterday, RepoRootCache, Bool (+5 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.17
Nodes (5): TabID, WorkspaceID, AgentCommandTests, String, Tab

### Community 301 - ".parse"
Cohesion: 0.13
Nodes (10): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, String (+2 more)

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.18
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 303 - ".encodeMouse"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 304 - "00-inception-plan.md"
Cohesion: 0.15
Nodes (9): _7(), A7(), a8(), bGt(), c8(), ene(), Gnn, IC() (+1 more)

### Community 305 - ".script"
Cohesion: 0.16
Nodes (8): brn, grn, hrn(), JGe(), KGe(), prn(), qGe(), zGe()

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.16
Nodes (18): Cjt(), H2e(), hR(), jX(), Kje(), KX(), lR(), N$e() (+10 more)

### Community 308 - "Send Ex Command"
Cohesion: 0.28
Nodes (7): SSETransport, .isRunning, .listener, Bool, NWConnection, String, UInt16

### Community 309 - "Browser DevTools API (P28)"
Cohesion: 0.18
Nodes (15): TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid, .init(_:gamut:alpha:) (+7 more)

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.24
Nodes (4): Bool, String, ThemeService, KouenOptions

### Community 312 - "AgentSnapshot"
Cohesion: 0.21
Nodes (8): SettingsAdvancedView, .body, Bool, String, SettingsFileSearchSection, .body, String, SwiftUI

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 314 - "code:bash (harness-cli install-hooks codex)"
Cohesion: 0.10
Nodes (17): AgentUsage, .contextTokens, .init(from:), .init(inputTokens:outputTokens:cacheReadTokens:cacheWriteTokens:thinkingTokens:totalCostUSD:), .shortSummary, CodingKeys, cacheReadTokens, cacheWriteTokens (+9 more)

### Community 315 - "code:bash (harness-cli install-hooks grok)"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 316 - "code:bash (harness-cli install-hooks opencode)"
Cohesion: 0.16
Nodes (16): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+8 more)

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.23
Nodes (5): WorktreeManager, String, URL, UUID, WorktreeIsolationDaemonTests

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.15
Nodes (6): DaemonStats, Bool, Double, Int32, DaemonLauncherTests, DaemonStatsTests

### Community 319 - "FormatColor"
Cohesion: 0.16
Nodes (6): LSPTextLocation, .position, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.32
Nodes (3): BinaryInstallerVersionTests, String, URL

### Community 321 - "UInt64"
Cohesion: 0.13
Nodes (13): BinaryInstaller.DetectionStatus, SetupStepView, .canInstall, .hooksDetail, .hooksTone, .hooksValue, .isSuccess, .notifTone (+5 more)

### Community 322 - "DesktopNotifier"
Cohesion: 0.10
Nodes (24): dhn(), eGt(), fhn(), ghn(), GOt(), HUe(), Ije(), jUe() (+16 more)

### Community 323 - "LayoutNode"
Cohesion: 0.15
Nodes (8): CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16, UInt8, CharacterWidthTests

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.15
Nodes (7): PasteController, Bool, NSPasteboard, String, TimeInterval, URL, PasteControllerTests

### Community 325 - "FloatingPaneController"
Cohesion: 0.40
Nodes (5): PaneOutputWaiter, PaneOutputWaitResult, CheckedContinuation, Never, UInt64

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 327 - ".theme"
Cohesion: 0.13
Nodes (18): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, PaletteFooter, .body (+10 more)

### Community 328 - "README.md"
Cohesion: 0.15
Nodes (11): SwarmFleetBody, .body, SwarmFleetView, .init(coder:), SwarmNodeRowView, .body, .statusColor, CGFloat (+3 more)

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 330 - ".drawGlyph"
Cohesion: 0.11
Nodes (18): fix ที่ค้างอยู่ใน working tree (ยังไม่ commit), Terminal grid ไม่ใช่ก้อนใหญ่ที่ระบุชนิดได้, ก้อนหลักเกี่ยวข้องกับ RenderBox, การให้ DeepSeek ตรวจเพิ่ม, ผลตรวจ preview ที่แยกจากแอปหลัก, ผลตรวจแอปหลัก, ภาคผนวก 1 — fleet 9 ต.ค. (P54) กระทบ UI ไหม → กระทบ ตรงจุด, ภาคผนวก 2 — 18 ต.ค. `8c5e0c8d` P59 (agy session, **unreviewed**) (+10 more)

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.19
Nodes (8): KouenCommands, DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String

### Community 332 - "Added"
Cohesion: 0.21
Nodes (5): ImageTextureCache, MTLDevice, MTLTexture, Set, UInt8

### Community 333 - "RealPty"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.12
Nodes (8): .parseAntigravityTranscript(sessionID:fileURL:toIndex:), Any, GraphifyIndexCache, S, Set, String, params, AntigravityTranscriptTurnsTests

### Community 335 - ".makeModel"
Cohesion: 0.18
Nodes (10): MainActor, Void, Group, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, CGFloat, NSTextField (+2 more)

### Community 336 - "run.sh"
Cohesion: 0.15
Nodes (9): Bool, Int32, String, URL, SystemdUserInstaller, .backendName, .isInstalled, .unitURL (+1 more)

### Community 337 - "CommandExecutionError"
Cohesion: 0.17
Nodes (3): ShellIntegrationTests, .repoRoot, URL

### Community 338 - "CSIParams"
Cohesion: 0.16
Nodes (16): SwarmFleetSnapshot, SwarmLane, pty, structured, SwarmTaskNode, SwarmTaskStatus, cancelled, failed (+8 more)

### Community 339 - "Foundation"
Cohesion: 0.16
Nodes (9): bUt(), FBe(), Gbe(), handler(), mUt(), _Q(), s0n(), wHt() (+1 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.16
Nodes (13): BoxDrawing, Kind, arms, dashH, dashV, halfDown, halfLeft, halfRight (+5 more)

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.16
Nodes (4): KouenThemeCatalog, .allThemes, String, KouenThemeCatalogTests

### Community 342 - "Added"
Cohesion: 0.13
Nodes (16): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, .bytesPerWakeup, .mbps (+8 more)

### Community 344 - "FileViewerViewController"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

### Community 345 - "README.md"
Cohesion: 0.19
Nodes (9): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.21
Nodes (4): Bool, String, SurfaceID, TimeInterval

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.23
Nodes (12): AgentBadgeView, .body, Bool, CGFloat, AgentIconRenderer, CGFloat, NSColor, NSImage (+4 more)

### Community 348 - "DaemonLifecycleTests"
Cohesion: 0.17
Nodes (8): NSHostingView, NSLayoutConstraint, TerminalTabBarView, .delegate, .init(frame:), .leadingInset, .mouseDownCanMoveWindow, .trailingInset

### Community 349 - "Contents.json"
Cohesion: 0.17
Nodes (7): MainMenuBuilder, Bool, NSMenu, NSMenuItem, Selector, String, MenuTargetForkConversationTests

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.13
Nodes (10): Bool, CGFloat, NSCoder, NSLayoutConstraint, NSPoint, NSRect, WindowTitleStripView, .init(coder:) (+2 more)

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.08
Nodes (24): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, .acceptsFirstResponder (+16 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.22
Nodes (9): CodingKeys, createdAt, cwd, done, id, sessionID, status, title (+1 more)

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.19
Nodes (9): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+1 more)

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.19
Nodes (13): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Bool, Duration (+5 more)

### Community 355 - ".deepMerge"
Cohesion: 0.21
Nodes (13): CellMetrics, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth, Bool (+5 more)

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.29
Nodes (3): KouenCompositor, GridCompositorCopyModeTests, String

### Community 357 - ".handleCat"
Cohesion: 0.25
Nodes (8): FeaturePhase, architect, completed, dev, interview, qaDesign, qaVerify, .title

### Community 359 - "OcclusionTests"
Cohesion: 0.18
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.22
Nodes (6): ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 362 - "RGBColor"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.20
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.17
Nodes (9): GitStatusProvider, OnceResume, Bool, Duration, String, TimeInterval, GitStatusProviderLargeOutputTests, URL (+1 more)

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.19
Nodes (9): NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView, .cornerConfiguration (+1 more)

### Community 366 - "Consumers"
Cohesion: 0.21
Nodes (9): Scanner, .atEnd, SVGPathParser, Bool, CGPath, CGPoint, Character, Set (+1 more)

### Community 368 - "Tab"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 369 - "Git Panel"
Cohesion: 0.15
Nodes (5): OnboardingController, CompletionGenerator, String, .fishCompletionSource, CompletionGeneratorTests

### Community 370 - ".encode"
Cohesion: 0.23
Nodes (7): InstallResult, Shell, bash, fish, zsh, Bool, URL

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.19
Nodes (8): AgentRemoteControlDaemonService, Set, String, Void, AgentRemoteControlDaemonServiceTests, LogBox, .count, String

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.18
Nodes (10): AssistantLine, ClaudeAdapter, Content, Message, ResultLine, Bool, Double, String (+2 more)

### Community 373 - "Prompt"
Cohesion: 0.20
Nodes (8): ClaudeRunSummary, Date, Double, Int32, String, UUID, String, UUID

### Community 374 - ".run"
Cohesion: 0.16
Nodes (11): Status, ciFailing, done, mergeReady, open, running, Bool, Date (+3 more)

### Community 375 - ".install"
Cohesion: 0.29
Nodes (4): SwarmDAGStore, String, UUID, SwarmDAGStoreTests

### Community 376 - "ScrollReuseTests"
Cohesion: 0.13
Nodes (18): statusColor(), Array, Bool, Date, PaneID, String, TabID, Tab (+10 more)

### Community 377 - "Identifiable"
Cohesion: 0.17
Nodes (15): apn(), ern(), G4(), G7(), Jnn(), nrn(), Qnn(), sHe() (+7 more)

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.26
Nodes (3): String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 379 - "MCPServer"
Cohesion: 0.27
Nodes (4): ArchitectureGuardTests, .repoRoot, String, URL

### Community 380 - "PromptQueue"
Cohesion: 0.18
Nodes (5): SSETransportTests, UInt16, MCPServer, String, NWListener

### Community 381 - "smoke-dmg.sh"
Cohesion: 0.27
Nodes (5): StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength, newline

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.20
Nodes (16): Close Pane, Next Session, Previous Session, Split Down, Split Right, Zombie Crash Rapid Close While Typing, Zombie Crash Rapid Split Close Cycle, Close Pane Removes Split (+8 more)

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.17
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 385 - "INDEX.md"
Cohesion: 0.10
Nodes (13): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+5 more)

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.19
Nodes (11): TrackedIssue, GitHubSearchResult, IssueFetchStatus, apiError, live, notConfigured, IssueTrackerService, Repository (+3 more)

### Community 387 - "User Profile"
Cohesion: 0.15
Nodes (8): ObjectiveC, CGFloat, NSControl, StaticString, String, UInt, TabNavigationButtonsTests, WebKit

### Community 388 - "Darwin"
Cohesion: 0.23
Nodes (8): LSPFileSession, Never, String, Task, URL, Void, object, Bool

### Community 389 - "HarnessCLITests"
Cohesion: 0.20
Nodes (5): CellOverlayTests, IndexSet, NSWindow, String, UInt64

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.17
Nodes (8): Bool, CGFloat, NSCoder, Void, TabNavigation, TabNavigationButtons, .init(coder:), NSStackView

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.11
Nodes (13): AnyObject, KeybindingsService, Bool, Command, String, CommandExecutionError, daemonError, .description (+5 more)

### Community 392 - "build-release.sh"
Cohesion: 0.12
Nodes (15): agy, claude, codex, copilot, hermes, kouen, __kouen_agy_next, __kouen_claude_next (+7 more)

### Community 393 - "create-dmg.sh"
Cohesion: 0.11
Nodes (5): KouenCLI, HistorySearchQueryTests, MemoCommandTests, URL, TaskCommandTests

### Community 394 - "finalize-release.sh"
Cohesion: 0.19
Nodes (10): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+2 more)

### Community 395 - "generate-app-icon.sh"
Cohesion: 0.25
Nodes (8): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String

### Community 396 - "generate-appcast.sh"
Cohesion: 0.21
Nodes (3): .hasAdapter(for:), Bool, ClaudeCodeHarnessTests

### Community 397 - "measure-fluidity.sh"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 398 - "preview.sh"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 399 - "sign-and-notarize.sh"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 400 - "install-linux.sh"
Cohesion: 0.18
Nodes (8): BrowserFileReloadTests, CountingWebView, Nav, NSEvent, String, Void, WKNavigation, WKNavigationDelegate

### Community 401 - "package-app.sh"
Cohesion: 0.14
Nodes (5): HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 402 - "View"
Cohesion: 0.17
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

### Community 403 - "PresentAttempt"
Cohesion: 0.27
Nodes (7): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection, agents

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.17
Nodes (16): SessionRef, byID, byName, next, previous, String, UUID, TargetSpec (+8 more)

### Community 405 - "AgentIconRenderer"
Cohesion: 0.08
Nodes (10): .init(coder:), .init(coder:), PaneSplitButtonsView, .init(coder:), .init(tabID:paneID:), NSButton, NSCoder, NSPoint (+2 more)

### Community 406 - "main.swift"
Cohesion: 0.13
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 407 - "Fixed"
Cohesion: 0.20
Nodes (8): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController

### Community 408 - "IPC Architecture"
Cohesion: 0.18
Nodes (6): DefaultTerminalLaunchRequest, ShellQuoting, Bool, String, URL, DefaultTerminalLaunchRequestTests

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.14
Nodes (7): KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, BinaryInstallerDisplayTests, OnboardingEnvironmentTests

### Community 410 - ".applyTerminalIdentity"
Cohesion: 0.23
Nodes (13): kouen.bash script, agy(), claude(), codex(), copilot(), hermes(), kouen(), __kouen_agy_next() (+5 more)

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.11
Nodes (11): URL, String, String, KouenFilePreviewLoader, KouenViewError, binaryOrUnsupportedEncoding, missingPath, tooLarge (+3 more)

### Community 412 - "go.json"
Cohesion: 0.22
Nodes (6): ListeningPortScanner, Int32, Set, String, result, ListeningPortScannerTests

### Community 413 - "javascript.json"
Cohesion: 0.22
Nodes (5): RepoResolver, Bool, String, RepoResolverTests, String

### Community 414 - "json.json"
Cohesion: 0.13
Nodes (11): PairingBox, .current, .isLockedOut, PendingPairing, Date, TimeInterval, TokenCheck, accepted (+3 more)

### Community 415 - "markdown.json"
Cohesion: 0.13
Nodes (11): Am(), bze(), Cm(), EQ(), Hm(), Im(), lte(), MBe() (+3 more)

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.31
Nodes (3): CSIParams, .count, UInt8

### Community 417 - "rust.json"
Cohesion: 0.15
Nodes (12): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+4 more)

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 419 - "typescript.json"
Cohesion: 0.18
Nodes (10): LayoutFileStore, LayoutNode, branch, leaf, LayoutTemplate, Date, Double, String (+2 more)

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.26
Nodes (14): Agent Command Does Not Crash, Agent Waiting Filter Does Not Crash, Board Command Shows Board Panel, Cd Command Switches To Matching Tab, Copy Path Command Does Not Crash, Errors Command Does Not Crash, Find Command Opens Command Palette On Empty Query, Find Command Resolves Unique File (+6 more)

### Community 422 - "HintModeOverlay"
Cohesion: 0.24
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 423 - "SixelDecoder"
Cohesion: 0.22
Nodes (5): .body, Bool, Bool, String, URL

### Community 424 - ".parseDiffHunks"
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 425 - "AgentVectorIcon"
Cohesion: 0.33
Nodes (6): SurfaceProgressTracker, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.31
Nodes (6): Bool, Counter, Scheduled, SurfaceProgressTrackerTests, DispatchWorkItem, TimeInterval

### Community 427 - ".delay"
Cohesion: 0.21
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 428 - "TaskDashboardView"
Cohesion: 0.12
Nodes (8): DispatchSource, DispatchQueue, DispatchSourceFileSystemObject, Int32, URL, Void, TranscriptFileWatcher, MobileBridgeTranscriptWatcherTests

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.08
Nodes (23): NSView, DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSViewCornerConfiguration, SurfaceID (+15 more)

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.12
Nodes (6): ScreenPos, bottom, middle, top, KouenLSP, QuickLookUI

### Community 431 - "BoardCardView"
Cohesion: 0.24
Nodes (8): ProjectDropTarget, .init(coder:), .init(frame:), NSCoder, NSDraggingInfo, NSDragOperation, NSRect, URL

### Community 432 - "PathToken"
Cohesion: 0.34
Nodes (8): CGFloat, Range, Tab, TabBarLayoutMetrics, .pitch, TerminalTabBarBody, .body, TerminalTabBarModel

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.15
Nodes (10): Date, Never, Task, Void, TabPillView, .pillBackground, .pillBorder, .workingDot (+2 more)

### Community 434 - "Project History"
Cohesion: 0.14
Nodes (14): Agent handbook — Kouen (extended reference), Agent integration, Build and test, IPC, Keyboard shortcuts, kouen-cli, Native terminal renderer, Repository map (+6 more)

### Community 435 - ".init"
Cohesion: 0.18
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 436 - "WaitForRegistry"
Cohesion: 0.41
Nodes (7): FeatureSummary, FeatureTaskSummary, GateSummary, Bool, Date, String, UUID

### Community 437 - "PickerItemRow"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 439 - "SetupStepView"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 440 - "LegacySnapshot"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 441 - "RemoteHostStore"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 443 - "main.swift"
Cohesion: 0.15
Nodes (11): copyMode, esc(), fs, globalShortcuts, KEYBINDINGS, prefixTable, renderTable(), ROOT (+3 more)

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.18
Nodes (9): BrowserTabRepaintTests, RepaintCountingWebView, Any, Error, MainActor, Sendable, String, TimeInterval (+1 more)

### Community 446 - "Modifiers"
Cohesion: 0.30
Nodes (5): SearchBenchmarks, String, UInt64, URL, Void

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.18
Nodes (13): Branch Change In Shared Folder Is Not Isolated Unprompted, CLI Isolate Creates Worktree And Session, CLI Isolate With Custom Branch Name, Close Session Keeps Dirty Worktree, Close Session Removes Clean Worktree, Create Isolated Session And Select, Git Checkout In Normal Session Does Not Affect Isolated, Isolate Without Branch Uses Detached HEAD (+5 more)

### Community 449 - "PresentAttempt"
Cohesion: 0.15
Nodes (12): Configuration, Int32, SessionGroup, SessionID, Tab, TabID, WorkspaceID, TabSelector (+4 more)

### Community 451 - ".run"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.09
Nodes (7): PromptQueue, String, SurfaceID, Void, Float, PromptQueueBar, NSWindow

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.31
Nodes (4): HintModeOverlay, Any, NSEvent, String

### Community 454 - ".recordReapedGenerationForTesting"
Cohesion: 0.18
Nodes (6): input, .parseClaudeTranscript(fileURL:toIndex:), ClaudeTranscriptLine, Any, Bool, ClaudeHumanTextTests

### Community 455 - "ComposerPanel"
Cohesion: 0.12
Nodes (14): CodingKeys, error, id, jsonrpc, method, params, result, LSPMessage (+6 more)

### Community 457 - ".normalizedKey"
Cohesion: 0.23
Nodes (9): AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor (+1 more)

### Community 458 - "PaneOutputWaiter"
Cohesion: 0.22
Nodes (10): DotView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor, NSRect (+2 more)

### Community 459 - ".encode"
Cohesion: 0.37
Nodes (4): KouenFeatureMarkdownSync, Bool, String, URL

### Community 460 - "RunState"
Cohesion: 0.19
Nodes (10): json, item, .parseCodexTranscript(fileURL:surfaceTag:ftsIndex:toIndex:), CodexSessionLocator, CodexTranscriptLine, Any, Bool, Int32 (+2 more)

### Community 461 - ".worktreeList"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 463 - ".deinit"
Cohesion: 0.27
Nodes (6): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor

### Community 464 - "MouseButton"
Cohesion: 0.19
Nodes (8): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus, UserNotifications

### Community 465 - "DirectionalAxis"
Cohesion: 0.18
Nodes (6): eKe(), irn(), mrn, _rn(), rrn(), srn()

### Community 466 - "PlatformSys.swift"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 467 - ".moveSelection"
Cohesion: 0.19
Nodes (8): Logger, OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, Bool, UInt64

### Community 468 - "Never"
Cohesion: 0.08
Nodes (12): KouenDaemonCore, BellScanTests, Bool, UInt8, FormatContextDaemonTests, PaneID, String, SurfaceID (+4 more)

### Community 469 - "PresentAttempt"
Cohesion: 0.37
Nodes (3): .block(atPromptLine:), String, TerminalBlockStoreTests

### Community 471 - ".evaluateStyled"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 473 - "HarnessOnboarding"
Cohesion: 0.29
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 474 - "String"
Cohesion: 0.20
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

### Community 475 - ".hitTest"
Cohesion: 0.18
Nodes (3): Bool, Int32, String

### Community 476 - "StatusDotView"
Cohesion: 0.23
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 477 - "SavedLayoutIPCDaemonTests"
Cohesion: 0.33
Nodes (6): Bool, NSPasteboard, NSString, String, URL, AutoreleasingUnsafeMutablePointer

### Community 479 - "ScrollbackTests"
Cohesion: 0.29
Nodes (4): .activeTab, BrowserTab, UUID, tabs

### Community 480 - ".isRisky"
Cohesion: 0.07
Nodes (16): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess, BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool (+8 more)

### Community 481 - "SecureInputMonitor"
Cohesion: 0.24
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 482 - ".resolve"
Cohesion: 0.20
Nodes (9): clamp(), statusHelp(), Configuration, String, T, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, tabDisplayTitle() (+1 more)

### Community 483 - "Changed"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 484 - "CopilotAdapter"
Cohesion: 0.09
Nodes (14): .setupPrompt, AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile (+6 more)

### Community 485 - ".testKouenRendererFixtureLigatureShapingPathReportsPlausibleGlyphs"
Cohesion: 0.24
Nodes (9): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+1 more)

### Community 486 - "TabPillView"
Cohesion: 0.42
Nodes (6): InstallResult, ShellCompletionInstaller, Bool, String, URL, ShellIntegration

### Community 487 - "bC"
Cohesion: 0.26
Nodes (5): Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 488 - "R1"
Cohesion: 0.26
Nodes (6): SwarmFleetSnapshotWire, SwarmTaskNodeWire, Date, Double, String, UUID

### Community 489 - "SurfaceIO"
Cohesion: 0.23
Nodes (3): MobileBridgeAttachFileTests, String, URL

### Community 490 - "ccRunGet"
Cohesion: 0.39
Nodes (3): data, SixelDecoder, UInt8

### Community 491 - ".update"
Cohesion: 0.32
Nodes (3): ReflowPreviewTests, .feeds, String

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 493 - "ccRunStart"
Cohesion: 0.17
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 494 - "ccRunInfo"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 495 - ".open"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 497 - ".bind"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 498 - ".runGitDiff"
Cohesion: 0.24
Nodes (11): Close Tab, New Tab, Cmd Shift W Force Closes Tab, Cmd T Creates New Session, Cmd W Closes Pane When Split, Cmd W Closes Tab When Single Pane, Window Survives Full Shortcut Sequence, Zombie Crash Close Tab While Typing (+3 more)

### Community 499 - "GlassEffectView"
Cohesion: 0.29
Nodes (7): AnimatablePair, NotchShape, .animatableData, CGFloat, CGPath, CGRect, Path

### Community 500 - "zO"
Cohesion: 0.24
Nodes (5): RiskyCommandClassifier, Bool, NSRegularExpression, String, RiskyCommandClassifierTests

### Community 501 - "Fixed"
Cohesion: 0.29
Nodes (6): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Carbon

### Community 502 - "Kouen Terminal — System Architecture"
Cohesion: 0.25
Nodes (4): Security, KouenMCPServer, Bool, String

### Community 503 - "Kouen Features"
Cohesion: 0.31
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 504 - "String"
Cohesion: 0.18
Nodes (11): Typography, .badge, .kbd, .paletteHeader, .paletteTitle, .rowMeta, .rowTitle, .sectionLabel (+3 more)

### Community 505 - ".tickFeatureWorktreeSweepLocked"
Cohesion: 0.18
Nodes (11): Architecture Decisions (dated log), Commit preparation, Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Post-P50 changes (v4.20.2 → v4.20.11, 2026-10-01 → 2026-10-06), Product Identity Guardrail: Terminal, Not IDE (+3 more)

### Community 506 - ".parseGitDiffOutput"
Cohesion: 0.24
Nodes (3): ShortcutRecorderSerializer, String, ShortcutRecorderSerializerTests

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.26
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 508 - "qLt"
Cohesion: 0.29
Nodes (9): AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand, Bool, Set (+1 more)

### Community 509 - "start.mjs"
Cohesion: 0.27
Nodes (7): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8

### Community 510 - "PromptQueue"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 511 - ".panePathLookup"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 512 - ".setAttribute"
Cohesion: 0.18
Nodes (10): SettingsAppearanceView, .autoTheme, .body, SliderRow, .body, .displayValue, Bool, ClosedRange (+2 more)

### Community 513 - "ThemeDocument"
Cohesion: 0.18
Nodes (11): EndpointTestStatus, done, idle, testing, ProviderKeyRow, .body, Bool, String (+3 more)

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 515 - "RD"
Cohesion: 0.18
Nodes (10): Bug 1 - Rotation Grace Slot Keeps The Previous Token Redeemable, Bug 1 - Rotation Shifts The Outgoing Token Into The Grace Slot, Bug 1 - Stop Fully Clears The Grace Slot, Bug 1 - Token Lifetime Not Regressed Below The Human-Flow Window, Bug 2 - Client onerror Does Not Clobber The Server Error Banner, Bug 2 - No Abrupt Cancel Immediately After The Error Text, Bug 2 - Reject Path Closes Gracefully With Policy-Violation Code 1008, Bug 3 - QR Not Printed When No Listener Is Ready (+2 more)

### Community 516 - "terminal_stress_runner.py"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 520 - "WriteOutcome"
Cohesion: 0.20
Nodes (6): AgentNotchPresentation, closed, open, peek, AgentNotchWindowActivator, Combine

### Community 521 - ".daemonIsStale"
Cohesion: 0.36
Nodes (6): HistorySearchEvidence, .body, .terms, Bool, String, Text

### Community 522 - ".viewDidLoad"
Cohesion: 0.22
Nodes (7): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, NSCoder, Void

### Community 523 - "fFe"
Cohesion: 0.20
Nodes (10): Agent Safety Net (Checkpoints, Verification, Write Guards), Claude Code Harness, Editor & LSP, How It Feels, Kouen Features, Mobile, Remote And Headless, Stack (+2 more)

### Community 524 - "รายงานตรวจสอบการใช้หน่วยความจำสูงของ Kouen Terminal"
Cohesion: 0.24
Nodes (3): KouenMCP, KouenBrowserToolsTests, URL

### Community 525 - ".encodeAndWait"
Cohesion: 0.20
Nodes (8): IssuePriority, .color, high, low, medium, none, .symbol, urgent

### Community 526 - "Kind"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 527 - ".show"
Cohesion: 0.31
Nodes (5): AgyAdapter, Result, ResultLine, String, UUID

### Community 528 - "worktree_review_dashboard.robot"
Cohesion: 0.20
Nodes (7): HeadlessRunEvent, assistantText, result, sessionID, Bool, Double, String

### Community 529 - "WorktreeAutoIsolateService"
Cohesion: 0.20
Nodes (10): PaneRef, bottom, byID, byIndex, last, left, next, previous (+2 more)

### Community 530 - "HarnessChrome"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 531 - "BrowserProgressLine"
Cohesion: 0.31
Nodes (4): OcclusionTests, NSWindow, String, TimeInterval

### Community 532 - "OpenClaw → Kouen"
Cohesion: 0.25
Nodes (4): CGImage, ImageLimits, Bool, ImageDecoder

### Community 534 - "p12_mcp.robot"
Cohesion: 0.24
Nodes (3): ClaudeSessionModeTests, URL, Void

### Community 535 - "AgentNotification"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 536 - ".readGrid(scrollbackOffset:)"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 537 - "NSObject"
Cohesion: 0.36
Nodes (3): .agentInfo(forWorktreePath:tabs:), Tab, GitPanelViewWorktreeAgentTests

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.36
Nodes (4): HistoryMenuProxy, Any, NSMenuItem, Void

### Community 539 - "SavedLayoutIPCDaemonTests"
Cohesion: 0.24
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 540 - ".delay"
Cohesion: 0.27
Nodes (9): Command Prompt, Find In Files, Git Panel, Open Command Palette, Switch To Session 1, Switch To Session 2, Rapid Session Switch While Typing, Switch Between Isolated And Normal Session (+1 more)

### Community 541 - ".init"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 542 - ".init(from:)"
Cohesion: 0.32
Nodes (4): PaneID, SessionGroup, Tab, first

### Community 543 - ".bufferLine"
Cohesion: 0.36
Nodes (4): Bool, String, UUID, TaskDaemonBridge

### Community 545 - ".characterIndex"
Cohesion: 0.47
Nodes (3): TabID, .body, TerminalTabBarDelegate

### Community 546 - "LegacySnapshot"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 548 - ".encode"
Cohesion: 0.22
Nodes (8): A `claude` typed by hand, Claude Code → Kouen, Customizing, One-line install, Session mode: Remote Control / cloud / local, The reverse direction: a session opened in Claude showing up in Kouen, Verifying, What gets written

### Community 549 - ".init(from:)"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Key spec syntax, Kouen keybindings, Persistence (+1 more)

### Community 551 - ".init(red:green:blue:alpha:)"
Cohesion: 0.21
Nodes (5): KeyTokenParser, Bool, String, .remaining, KeyTokenParserTests

### Community 552 - "PaneLabelDaemonTests"
Cohesion: 0.25
Nodes (7): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, String

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
Cohesion: 0.22
Nodes (7): KouenCLIPaths, .applicationSupport, .binDirectory, .installedCLIPath, .installedDaemonPath, .launchAgentURL, URL

### Community 557 - ".viewWillMove"
Cohesion: 0.31
Nodes (3): crn, ELt(), n2e()

### Community 558 - "FindWindowMatcherTests"
Cohesion: 0.22
Nodes (8): Build order (unchanged from interview decision), G1 — @ file-path picker, G2 — shell tab-completion suggestion strip (heuristic, explicitly best-effort), G3 — AI command suggestion (via `claude` CLI subprocess), Logical Design, P37 Phase G — Autocomplete (mobile bridge), Strategic Design, Tactical Design

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.22
Nodes (8): Artifacts, Client Application — Slice 1 (stacked panes, no persistence), Client Application — Slice 2 (per-workspace divider memory), Context, Dev Task Progress — Workspace Sidebar Panels (P42), Integration, Note on task re-sequencing (2026-07-17), Summary

### Community 560 - "AgentNotification"
Cohesion: 0.22
Nodes (9): Contributors, Documentation, Install, Key features, Kouen, License, Requirements, Update (+1 more)

### Community 561 - "AppIdleThrottle"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 562 - "BrowserResponsePayload"
Cohesion: 0.22
Nodes (8): MCP Control Allowed With Env Var, MCP Control Denied Without Env Var, MCP KouenBoard Returns Columns, MCP KouenList Returns Sessions, MCP ReadPaneOutput Returns Content, Run MCP Request, Run MCP Request Allowed, Run MCP Request Denied

### Community 564 - "📁 IDE Sidebar"
Cohesion: 0.22
Nodes (6): String, URL, ThemeCatalogEmbedTests, .embedSwift, .repoRoot, .sourceJSON

### Community 565 - "WriteOrigin"
Cohesion: 0.22
Nodes (7): block, escFn, lineFilter, md, page, script, swift

### Community 566 - "TerminalTabBarView.swift"
Cohesion: 0.36
Nodes (7): Document, Bool, Set, String, URL, ToolPolicy, .defaultURL

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.39
Nodes (4): SessionGroup, Any, String, Tab

### Community 568 - ".installChromeBackground"
Cohesion: 0.33
Nodes (6): Command, .targetKind, TargetKind, pane, session, window

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.36
Nodes (4): AboutPanelController, AboutView, NSWindow, NSHostingController

### Community 571 - "ShellIntegrationTests"
Cohesion: 0.25
Nodes (4): Bool, NSEvent, NSEvent, NSEvent

### Community 572 - "LayoutProbeView"
Cohesion: 0.57
Nodes (3): ProjectConfig, Bool, String

### Community 573 - "tHe"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 574 - "FileTreeKeyboardNavigator"
Cohesion: 0.11
Nodes (20): IndexingIterator, LayoutTemplate, Bool, Double, .addSurface(to:paneID:surfaceID:cwd:), .split(node:targetPaneID:direction:paneCount:before:), .split(node:targetPaneID:with:direction:beforeTarget:), .surfaceID(forPaneID:in:) (+12 more)

### Community 579 - "main.swift"
Cohesion: 0.15
Nodes (8): _Bt(), by(), e7e(), fst(), hxn(), lxn(), sBt, XWt()

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

### Community 586 - "Product"
Cohesion: 0.25
Nodes (3): FlushSessionStateTests, String, URL

### Community 587 - "sheet-cheat.html"
Cohesion: 0.29
Nodes (7): Toggle Sidebar, Sidebar Toggle Works, Board CLI Shows Columns, Board CLI Shows Running After Long Command, Board Columns Visible After Click, Board Tab Accessible In Sidebar, Split Pane And Resize

### Community 588 - "jHt"
Cohesion: 0.25
Nodes (7): Browser Pane Open Close Rapid, File Preview Open Close, Git Fetch Shows Toast, Launch Kouen Staging, Memory Stability After 30 Seconds, Quit Kouen Staging, Sidebar Toggle Immediately After Launch

### Community 591 - "main.swift"
Cohesion: 0.08
Nodes (15): NSEvent, Selector, UInt8, UInt16, Bool, NSEvent, ViInputMode, insert (+7 more)

### Community 592 - "commit-push.sh"
Cohesion: 0.53
Nodes (4): ClientSummary, Date, String, UUID

### Community 594 - "r2"
Cohesion: 0.38
Nodes (4): AnyObject, ObjectIdentifier, TimeInterval, ZombieHoldRegistry

### Community 597 - "TerminalColorRole"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 598 - ".encode"
Cohesion: 0.29
Nodes (7): 1. Plain Terminal, 2. Persistent Terminal, 3. Full Terminal, 4. Agent Workspace, Experience modes, Opting into the prefix + status line without switching modes, Persistence (ephemeral vs. persistent)

### Community 599 - ".terminalHostIfExists"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Kouen-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 600 - "TaskDashboardGroupingTests"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 601 - "Hwe"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 603 - "fut"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 604 - "k0t"
Cohesion: 0.29
Nodes (7): blockTokens(), inlineTokens(), lex(), lexer(), lexInline(), me(), reflink()

### Community 605 - "drn"
Cohesion: 0.29
Nodes (7): GRt(), n4e(), p7e(), r2(), tl(), vrt(), xq()

### Community 606 - "Quick start"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

### Community 607 - "iRe"
Cohesion: 0.12
Nodes (13): UnsafeBufferPointer, .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8, TerminalCellWidth (+5 more)

### Community 608 - "W2"
Cohesion: 0.29
Nodes (6): Locked decisions (user-confirmed), Logical Design, P38 Phase A — Cross-Agent Worktree Diff/Review Dashboard — Design, Strategic Design, Tactical Design, Verification gate (this phase)

### Community 609 - "FormatContextDaemonTests"
Cohesion: 0.29
Nodes (6): Logical Design, Next Step, P42 — Workspace Sidebar Panels, Parked (not in scope), Strategic Design, Tactical Design

### Community 610 - "TabStatus"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 611 - ".showWorkspaceMenu"
Cohesion: 0.29
Nodes (6): Any, Error, MainActor, Sendable, String, Void

### Community 613 - "INDEX.md"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 614 - "MainSplitViewController"
Cohesion: 0.38
Nodes (6): Cleanup And Quit, Create Config File, No Config File Starts Normally, Script Hot Reload On Save, Script Loads On Startup, Script Syntax Error Does Not Crash

### Community 616 - "bump-version.sh"
Cohesion: 0.29
Nodes (6): Bug 1 - Browser Pane Deferred Unregister, Bug 1 - Browser Pane Reuse On Rebuild, Bug 2 - New Session Syncs Before Reading Active Tab, Bug 2 - Tab Bar New Tab Also Syncs, Bug 3 - Browser Pane Forces Redraw On Reattach, Build Compiles Successfully

### Community 618 - "parse"
Cohesion: 0.40
Nodes (5): KeyRecorderRepresentable, SettingsKeysView, .body, String, Void

### Community 620 - "mS"
Cohesion: 0.40
Nodes (5): CodingKeys, excludedPaths, id, name, sourceFolder

### Community 622 - "sBt"
Cohesion: 0.40
Nodes (3): calculate(), constructor(), mBt

### Community 624 - "gmn"
Cohesion: 0.33
Nodes (6): h1t(), hae(), jgn(), pwn(), sfn(), _Ue()

### Community 626 - "cGt"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 627 - "ActiveTabCloseDisposition"
Cohesion: 0.47
Nodes (5): AgentIconArt, AgentVectorIcon, Bool, CGSize, String

### Community 628 - "ReplayStep"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase D — Kitty Graphics Conformance Slice, Scope (locked), Tests

### Community 629 - "graphify reference: query, path, explain"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua), Scope (locked), Tests

### Community 630 - "HGe"
Cohesion: 0.33
Nodes (5): Logical Design, Next Step, P43 — Add Repo/Folder to Workspace, Strategic Design, Tactical Design

### Community 631 - "die"
Cohesion: 0.33
Nodes (5): Build, Release & Git Workflow, Build / Test / Run, Graphify before every delivery commit, Release packaging order, Worktree constraint

### Community 632 - "dne"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 633 - "g_n"
Cohesion: 0.60
Nodes (5): main(), printHelp(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 634 - "qC"
Cohesion: 0.40
Nodes (3): String, URL, WorktreeSignatureTests

### Community 637 - "TerminalScrollbarView"
Cohesion: 0.47
Nodes (3): URL, TimeoutError, WorktreeLargeOutputRegressionTests

### Community 638 - "FormatStringExtendedVariableTests"
Cohesion: 0.33
Nodes (5): Kouen LSP Diagnostics Does Not Crash, Kouen LSP Hover Returns Result, Kouen LSP Start Returns JSON, Kouen View Binary Shows Guard Message, Kouen View Prints File Content

### Community 639 - "gpn"
Cohesion: 0.50
Nodes (5): aut(), cpn(), hq(), kLt(), q1n()

### Community 641 - "[3.10.0] - 2026-06-27"
Cohesion: 0.67
Nodes (3): AsyncCLIResultBox, Error, Result

### Community 643 - "h7n"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 647 - "graphify reference: query, path, explain"
Cohesion: 0.50
Nodes (4): WriteOutcome, complete, failed, wouldBlock

### Community 648 - "PtyDrainCeilingBenchmark"
Cohesion: 0.40
Nodes (4): Findings, Sources, What this means for Kouen, Who creates branches / worktrees in AI coding tools

### Community 649 - "h$t"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: animateSidebar setContentLeadingInset MainSplitViewController, Source Nodes

### Community 650 - "hjt"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: ProjectCategory FolderScanner ProjectDirectoryTree, Source Nodes

### Community 651 - "u0n"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: BrowserPaneView createTab openBrowserPane navigation WebKit, Source Nodes

### Community 652 - "TerminalHostView"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: KouenPreviewHome environment key daemon launch at startup, Source Nodes

### Community 653 - "iOn"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: session history search ranking branch best matches, Source Nodes

### Community 657 - "clear-runtime-state.sh"
Cohesion: 0.40
Nodes (5): CwdAuthorizationError, foreignPathRejected, .message, missingSessionOrCwd, other

### Community 658 - "k0n"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 659 - "LayoutTemplate"
Cohesion: 0.40
Nodes (5): Motion, .reduce, .spring, Animation, Bool

### Community 663 - "m6e"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 664 - "P37 Phase G — Autocomplete (mobile bridge)"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 665 - "nb"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 666 - "BrowserIntegrationController"
Cohesion: 0.70
Nodes (4): restart_daemon(), rollback_version_bump(), full-cycle.sh script, usage()

### Community 667 - "[3.3.0] - 2026-06-18"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 668 - "nje"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 669 - "PaneLabelDaemonTests"
Cohesion: 0.40
Nodes (4): Leak A - Retiring A Host Drops Its AI Controllers, Leak B - Browser Network Capture Is Bounded, Leak C - Every Per-Surface Dict In Coordinator Has Retire Cleanup, Leak D - Every Per-Surface Dict In NotificationCoordinator Is Snapshot-Swept

### Community 673 - "qte"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

### Community 674 - "t2e"
Cohesion: 0.50
Nodes (3): Caveats, Keep awake with the lid closed, Setup

### Community 675 - ".detect"
Cohesion: 0.50
Nodes (4): Full local signing path (needs a Developer ID cert; not currently used), How this fork actually releases, Release runbook, Scripted flow

### Community 676 - "vne"
Cohesion: 0.50
Nodes (3): exclude_hubs, no_viz, wiki

### Community 677 - "New Tab"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: SSETransport auth token isRunning

### Community 679 - "TriState"
Cohesion: 0.50
Nodes (4): dO(), m8(), rfn(), zfn()

### Community 680 - "AgentVectorIcon"
Cohesion: 0.67
Nodes (4): FVe(), hJ(), qVe(), Zme()

### Community 681 - ".tabIDsToNotify"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 682 - "Workbench commands (IDE-like workflow)"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 683 - "TransportError"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 684 - "CommandParseError"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 686 - "DECSpecialGraphics"
Cohesion: 0.67
Nodes (3): commit_with_graph(), prepare_graph_for_commit(), graphify-commit.sh script

### Community 688 - ".init(coder:)"
Cohesion: 0.50
Nodes (3): Bug 1 - Hunks Button Has Explicit Size Constraints, Bug 1 - Hunks Button Symbol Has A Guaranteed-Valid Fallback, Build Compiles Successfully

### Community 689 - ".hideFind"
Cohesion: 0.50
Nodes (3): Guard A - Merge Call Site Never Passes --no-ff, Guard B - No Auto-Resolve Anywhere In The Merge/Conflict Path, Guard C - Merge Conflict State Is Reconciled, Not Just Read Once

### Community 696 - "TerminalTabBarDelegate"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 697 - "ReleaseNotes"
Cohesion: 0.67
Nodes (3): cat(), Hwe(), kYe()

### Community 698 - ".send"
Cohesion: 0.67
Nodes (3): cfn(), fut(), qYe()

### Community 699 - ".make"
Cohesion: 0.67
Nodes (3): dht(), k0t(), l1n()

### Community 702 - "PromptQueue"
Cohesion: 0.67
Nodes (3): iRe(), jNt(), zNt()

### Community 714 - "die"
Cohesion: 0.67
Nodes (3): TransportError, invalidUTF8Header, missingContentLength

## Knowledge Gaps
- **2415 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+2410 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1140 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Work-memory lessons

**Known dead ends** — questions that led nowhere; don't re-derive.
- "KouenPreviewHome environment key daemon launch at startup" -> `KouenPaths`

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `AgentNotchRootView` to `graphify reference: extra exports and benchmark`, `EngineConformanceTests`, `IPCRequest`, `Command`, `LSPMessage`, `.daemonIsStale`, `TerminalEmulator`, `GitPanelView.swift`, `Changed`, `KittyKeyboardTests`, `VTParser`, `HarnessTerminalSurfaceView`, `.applyPreedit`, `WorktreeAutoIsolateService`, `MetalRendererTests`, `SpecialKey`, `Kind`, `HarnessTerminalSurfaceView`, `CopyModeAction`, `OpenClaw → Kouen`, `.request`, `HarnessUILibrary`, `Harness tmux-style capabilities`, `RGBColor`, `.parse`, `Added`, `.init(from:)`, `Sendable`, `.addTab`, `.characterIndex`, `WorktreeManager`, `Equatable`, `MenuTarget`, `String`, `.init`, `.init(red:green:blue:alpha:)`, `PaneLabelDaemonTests`, `CodingKeys`, `HarnessSidebarPanelViewController.swift`, `code:bash (harness view <file>                        # syntax-highligh)`, `TerminalColorGamut`, `HarnessOverlayBackground`, `.buildCommand`, `.normalizedKey`, `HookEvent`, `HarnessTerminalSurfaceView.swift`, `Added`, `PerformanceBenchmarks`, `Added`, `HarnessSplitView`, `TabCell`, `TerminalTabBarView.swift`, `PasteBufferStore`, `3.2 สิ่งที่ implement แล้ว`, `FileTreeKeyboardNavigator`, `HarnessCLI+Server.swift`, `.text`, `ComposedCell`, `ShellIntegration`, `String`, `Completed Plans Archive`, `PrefixKeymap`, `ImportedTerminalConfig`, `XCTestCase`, `README.md`, `[2.6.0] - 2026-06-13`, `GUt`, `TerminalProtocolCompatibilityTests`, `DaemonSubscription`, `.firstMatch`, `LSPDiagnostic`, `TerminalGridCell`, `.runtimeDirectory`, `TaskDashboardGroupingTests`, `.sessionsDirectory`, `TerminalModes`, `.cursorPos`, `code:bash (# Terminal 1: Create workspace with long-running job)`, `shim.c`, `iRe`, `PaneContainerView`, `TabStatus`, `ScriptRuntime.swift`, `AnyCodable`, `Recipe`, `Changelog`, `code:text (:workbench start swift)`, `.makeSnapshot`, `HarnessGridTerminal`, `.firstWaitingTab`, `SessionGroup`, `PaneNode`, `Harness command reference`, `Added`, `ViEngine`, `Pi → Kouen`, `HistoryRingBuffer`, `TerminalScrollbarView`, `code:block1 (SessionCoordinator.snapshot ──┐)`, `SwiftUI`, `Harness`, `[3.10.0] - 2026-06-27`, `AgentHookInstaller`, `.load`, `CommandTarget`, `.startWatching`, `ActivePaneService`, `User Story Mapping (MANDATORY)`, `BlockContextMenuTests`, `CopyModeGridSource`, `PaneStyleSet`, `AgentSessionSummary.swift`, `DecodedImage`, `FileTreeWatcher`, `k0n`, `How to use Harness from the terminal only (no GUI)`, `HarnessDaemonToolsTests`, `.evaluate`, `Added`, `What You Must Do When Invoked`, `LiveResizeTests`, `Int`, `ThaiCombiningMarkTests`, `Added`, `P37 Phase G — Autocomplete (mobile bridge)`, `AntigravityTranscriptTurnsTests`, `NSResponder`, `What You Must Do When Invoked`, `TerminalFindBar`, `Workspace`, `ActiveTabCloseDisposition`, `FormatColor`, `Added`, `.decodeKeySpec`, `Added`, `Additional `kouen-cli` subcommands`, `[3.13.1] - 2026-07-02`, `VTConformanceCorpusTests`, `GridCompositorTests`, `P25 — iOS/iPadOS Support`, `LSPServerRegistry`, `Error`, `P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client`, `GlyphRasterizer`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `[2.5.1] - 2026-06-12`, `AgentSessionSummary`, `MCP Server (harness-mcp)`, `PaletteModel`, `scheduleRender`, `String`, `NotchLayoutMetrics`, `.lines`, `CellColorResolverTests`, `DaemonError`, `ScrollbackFile`, `AsciiFastPathTests`, `TerminalServicesProvider`, `CellColorResolver`, `FileChangeWatcher`, `SSHTunnelManagerTests`, `sessionRow`, `.decide`, `HarnessGridTerminalTests`, `f5`, `ExternalOpenKind`, `.activeWorkspace`, `TerminalBlockStoreTests`, `.make`, `TerminalMetalRenderer`, `AgentBridge`, `.make`, `SessionCoordinator`, `Split Right`, `Sidebar SwiftUI Migration — Knowledge`, `WindowTitleStripView`, `.show`, `run.sh`, `HarnessSidebarPanelViewController`, `.performInstall`, `code:bash (# Old (agent-specific):)`, `WindowSession`, `SGRMouseEvent`, `TerminalScrollbarView`, `FormatColor`, `click_ui_element`, `code:bash (harness-cli install-hooks hermes)`, `def`, `StatusLineWidthTests`, `Process`, `emStrong`, `Fixes Applied (layered)`, `.testingRenderPending`, `settings.json`, `jobs`, `PaneNode`, `.parse`, `Never`, `.encodeMouse`, `ViPathTokenTests`, `Send Ex Command`, `Terminal AI Chat (⌘I inline overlay)`, `code:bash (harness-cli install-hooks codex)`, `code:bash (harness-cli install-hooks grok)`, `Memory — harness-terminal`, `code:bash (# In a Harness pane:)`, `FormatColor`, `Focus Persistence — Per-Session-Tab Pane Focus (RL-043)`, `LayoutNode`, `FloatingPaneController`, `worktree_isolation.robot`, `.theme`, `.recordReapedGenerationForTesting`, `Added`, `CSIParams`, `.deinit`, `code:bash (harness-cli install-hooks openclaw)`, `Added`, `[2.2.3] - 2026-06-09`, `FileViewerViewController`, `Agent platform icons`, `P22 — Long-Session Responsiveness Hardening`, `Architecture Decisions — harness-terminal`, `SurfaceProgressTracker`, `OcclusionTests`, `State`, `P36 — App icon Auto/Light/Dark support (2026-07-06)`, `FormatStyledSegment.swift`, `P13 — Embedded Browser Pane (cmux parity)`, `.install`, `ScrollReuseTests`, `SurfaceProgressTrackerTests.swift`, `MCPServer`, `terminal_stress_runner.py`, `SKILL-LOG.md`, `User Profile`, `HarnessCLITests`, `UI Automation — Robot Framework (P18)`, `preview.sh`, `Split Panes (NSSplitView)`, `Task 1: Redesign Session Sidebar`, `go.json`, `json.json`, `.refreshSurfaceMetadata`, `HintModeOverlay`, `SixelDecoder`, `AgentVectorIcon`, `Bug — Cmd+\ sidebar toggle gone after collapse`, `Case: cwd "bleed" — session worktree jumps to wrong dir during builds`, `PathToken`, `LaunchdServiceInstaller`, `WaitForRegistry`, `Modifiers`, `tmux parity — status, adaptations, and deliberate divergences`, `.deleteWorkspaceFromMenu`, `TerminalModes`, `.encode`, `.worktreeList`, `PresentAttempt`, `.evaluateStyled`, `String`, `.install`, `ScrollbackTests`, `.isRisky`, `SecureInputMonitor`, `bC`, `R1`, `ccRunGet`, `.update`?**
  _High betweenness centrality (0.263) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `HarnessCLI+Server.swift` to `CellColorResolver`, `AgentNotchRootView`, `XCTestCase`, `MCP Server (harness-mcp)`, `domain-design.md`, `Changed`, `automationUpdate`, `bindHook`, `breakPane`, `.buildCommand`, `AgentBridge`, `Added`, `DisplayPanesOverlay`, `CellColorResolverTests`, `Harness tmux-style capabilities`, `[3.2.0] - 2026-06-16`?**
  _High betweenness centrality (0.207) - this node is a cross-community bridge._
- **Why does `fbt()` connect `callingPaneTarget` to `CodingKey`, `แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)`, `DisplayPanesOverlay`?**
  _High betweenness centrality (0.108) - this node is a cross-community bridge._
- **Are the 18 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `RenderScheduler`) actually correct?**
  _`KouenTerminalSurfaceView` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _2435 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.007237536582744954 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.021727229825389334 - nodes in this community are weakly interconnected._