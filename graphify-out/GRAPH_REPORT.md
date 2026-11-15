# Graph Report - review-wave3-perf  (2026-11-15)

## Corpus Check
- 967 files · ~1,059,515 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 20155 nodes · 58137 edges · 2688 communities (1552 shown, 1136 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8519 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `8f0c277e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 346 edges
2. `i()` - 318 edges
3. `a()` - 282 edges
4. `SessionCoordinator` - 235 edges
5. `SurfaceRegistry` - 230 edges
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
1. `IPCRequest` - bridges 189 areas (211 edges)
2. `Command` - bridges 102 areas (108 edges)
3. `AgentKind` - bridges 82 areas (176 edges)
4. `IPCResponse` - bridges 81 areas (107 edges)
5. `KouenTerminalSurfaceView` - bridges 76 areas (346 edges)
6. `SessionCoordinator` - bridges 66 areas (235 edges)
7. `NSView` - bridges 65 areas (193 edges)
8. `KouenGridTerminal` - bridges 64 areas (117 edges)
9. `AnyCodable` - bridges 63 areas (190 edges)
10. `i()` - bridges 62 areas (318 edges)

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

## Communities (2688 total, 1136 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.01
Nodes (566): _0t(), _1n(), _3n(), _4n(), _5e(), _6e(), _9e(), a3n() (+558 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.02
Nodes (286): f(), l, V, z(), _6n(), _9n(), a0(), a5n() (+278 more)

### Community 2 - ".handleNormal"
Cohesion: 0.03
Nodes (324): pe(), X(), A(), code(), R(), a(), ae(), aen() (+316 more)

### Community 3 - "Changed"
Cohesion: 0.05
Nodes (44): a(), b(), c(), d(), e(), g(), h(), I() (+36 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.10
Nodes (50): Ame(), aQt(), aXt(), bme(), bYt(), Cme(), Cqt(), CUe() (+42 more)

### Community 5 - "IPCRequest"
Cohesion: 0.11
Nodes (23): AgentHistoryFTSIndex, .deleteSession(sessionID:), .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:surfaceTag:topicSegments:), .needsReindex(sessionID:mtime:fileSize:), .pruneMissingSessions(validTranscriptPaths:), .saveRecord(_:mtime:fileSize:), .search(query:limit:), .searchRanked(query:limit:includeSnippet:requireAllTokens:includeMetadata:matchingIDs:) (+15 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.18
Nodes (15): a2(), akn(), bpn(), cIn(), ift(), p7n(), pyn(), R1() (+7 more)

### Community 7 - "Command"
Cohesion: 0.05
Nodes (35): TerminalModes, InputEncoder, .encode(_:modifiers:event:modes:), .encode(text:modifiers:modes:), .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release (+27 more)

### Community 8 - "LSPMessage"
Cohesion: 0.06
Nodes (48): .notchSection, .notifySection, SettingsAppearanceView, .autoTheme, .body, .themeSection, Bool, ColorHexRow (+40 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.06
Nodes (46): a4e(), aae(), adn(), cvn(), dw(), eL(), f8n(), f_n() (+38 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.07
Nodes (17): Int, SemanticMark, TerminalGridCell, HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor (+9 more)

### Community 12 - "Changed"
Cohesion: 0.09
Nodes (27): AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem, FolderScanner (+19 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.05
Nodes (31): tab, .tab(for:), .tab(forSurfaceKey:), DaemonCommandExecutor, Command, .init(forTesting:), UUID, Void (+23 more)

### Community 14 - "VTParser"
Cohesion: 0.05
Nodes (31): IndexingIterator, LayoutTemplate, surfaceID, SessionEditor, .addSurface(tabID:paneID:), .addSurface(to:paneID:surfaceID:cwd:), .surfaceID(forPaneID:), .surfaceID(forPaneID:in:) (+23 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.08
Nodes (11): .receive(_:), DispatchSemaphore, FluidityBenchmarks, NSWindow, String, UInt64, KouenTerminalSurfaceWorkerTests, LiveResizeTests (+3 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.05
Nodes (44): _3e(), avt(), b3e(), bd(), c6(), d_n(), gce(), ggn() (+36 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.09
Nodes (22): MochaTheme, SurfaceColorProviderState, ANSIPalette, UInt8, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors (+14 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.11
Nodes (7): Bool, Command, DispatchWorkItem, PaneID, String, UInt8, WindowSession

### Community 19 - "SpecialKey"
Cohesion: 0.10
Nodes (38): MTLClearColor, MTLCommandBuffer, MTLLibrary, MTLRenderCommandEncoder, MTLRenderPipelineState, BgInstance, CursorCacheKey, .invertsGlyph (+30 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.07
Nodes (21): OSCTerminatorMatch, PtyError, launchFailed, RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), ScrollbackEntry, ScrollbackReplaySegment, ShellLaunchProfile (+13 more)

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.12
Nodes (13): TerminalDamage, RenderColor, MetalRendererTests, .makeRenderer(device:atlasSize:atlasMaxPages:), RenderedFixture, Bool, MTLDevice, MTLTexture (+5 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.08
Nodes (31): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, .body, PaletteMode (+23 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.08
Nodes (21): BrowserPaneView, .activeTab, .webView(_:didCommit:), .webView(_:didFinish:), BrowserTab, DispatchWorkItem, NSWindow, ObjectIdentifier (+13 more)

### Community 24 - ".request"
Cohesion: 0.06
Nodes (40): CommandTarget, Command, .targetKind, PaneRef, bottom, byID, byIndex, last (+32 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.17
Nodes (10): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, automations (+2 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.06
Nodes (36): .pairedAlreadyBanner, .pairingQRPanel, ArtifactKind, html, image, markdown, text, AutomationsFleetModel (+28 more)

### Community 27 - "RGBColor"
Cohesion: 0.09
Nodes (31): .saveRecordsBatch(_:), CachedSessionEntry, AgentHistoryScanner, .parseAntigravityTranscript(sessionID:fileURL:), .parseClaudeTranscript(fileURL:), .parseCodexTranscript(fileURL:surfaceTag:ftsIndex:), .readAntigravitySummaries(dbPath:brainDir:ftsIndex:), .readAntigravitySummaries(dbPath:brainDir:ftsIndex:fileCache:) (+23 more)

### Community 28 - ".parse"
Cohesion: 0.06
Nodes (12): NWEndpoint, Bool, NWListener, Sendable, String, UInt16, MobileBridgeServer, PipeBuffer (+4 more)

### Community 29 - "Added"
Cohesion: 0.10
Nodes (8): .onCurrentCWD, .onCurrentFile, Bool, NSString, NSTextView, String, unichar, ViPathTokenTests

### Community 30 - "Notification"
Cohesion: 0.07
Nodes (34): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+26 more)

### Community 31 - "Sendable"
Cohesion: 0.10
Nodes (24): Binding, .init(from:), .init(spec:command:note:repeatable:), CodingKeys, bindings, disabledSpecs, id, tables (+16 more)

### Community 34 - "DaemonClient"
Cohesion: 0.14
Nodes (16): .exit, DaemonClient, String, String, String, String, KouenCLI, SessionID (+8 more)

### Community 35 - "MenuTarget"
Cohesion: 0.08
Nodes (17): GitPanelView, .isHidden, .removeWorktreeAction(_:), Any, DispatchWorkItem, NSButton, NSColor, NSMenuItem (+9 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.12
Nodes (26): CodingKeys, excludedPaths, id, name, sourceFolder, fetchGitStatus(), ProjectCategorySection, .body (+18 more)

### Community 37 - "String"
Cohesion: 0.09
Nodes (21): InputGate, .siblings, OutputCoalescer, ReconnectLatch, .isTripped, SurfaceIO, .currentSubscription, Bool (+13 more)

### Community 38 - "code:bash (swift build)"
Cohesion: 0.22
Nodes (5): AnyCodable, JSONRPCError, Bool, String, ToolRegistry

### Community 39 - "TerminalColorGamut"
Cohesion: 0.06
Nodes (42): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, .init(from:), .init(id:name:baseURL:modelID:), ModelProvider (+34 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.18
Nodes (11): TrackedIssue, GitHubSearchResult, IssueFetchStatus, apiError, live, notConfigured, IssueTrackerService, Repository (+3 more)

### Community 41 - "CodingKeys"
Cohesion: 0.08
Nodes (41): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+33 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.10
Nodes (13): .agentColorBinding, colors, PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Double, MTLDevice (+5 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.07
Nodes (21): Data, DecodedReplyFrame, output, reply, DecodedRequestFrame, input, request, FrameError (+13 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.14
Nodes (15): Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow, launchStart, StartupMetrics (+7 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.15
Nodes (10): PaneRect, PaneID, SurfaceID, GridCompositor, GridCompositorCopyModeTests, String, GridCompositorTests, Bool (+2 more)

### Community 46 - ".buildCommand"
Cohesion: 0.11
Nodes (26): DaemonSubscription, .start(onData:onEnd:buffered:), .start(onResponse:onEnd:), Bool, String, UInt16, UInt64, Void (+18 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.06
Nodes (34): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+26 more)

### Community 48 - "HookEvent"
Cohesion: 0.08
Nodes (15): UUID, DaemonRoundTripTests, RawSocketError, connectFailed, writeFailed, String, TimeInterval, URL (+7 more)

### Community 49 - "DaemonServer"
Cohesion: 0.12
Nodes (6): KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), SpawnedAgentSurface, ISO8601DateFormatter, String, UUID

### Community 50 - "Added"
Cohesion: 0.09
Nodes (29): A1(), aat(), bln(), bw(), bwt(), c5n(), d6(), f7e() (+21 more)

### Community 51 - ".keyEvent"
Cohesion: 0.10
Nodes (11): SessionGroup, String, KouenSidebarPanelViewController, NSMenuItem, SessionGroup, String, NSMenu, NSMenuItem (+3 more)

### Community 52 - "Fixed"
Cohesion: 0.06
Nodes (34): .body, FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body (+26 more)

### Community 53 - "Added"
Cohesion: 0.07
Nodes (28): .init(frame:), NSRect, LSPFileSession, Never, String, Task, URL, Void (+20 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.15
Nodes (4): cqe(), F7, mathmlBuilder(), UHt()

### Community 55 - "TabCell"
Cohesion: 0.10
Nodes (18): Process, SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, SSHTunnelManager (+10 more)

### Community 56 - "NSPanel"
Cohesion: 0.06
Nodes (31): SessionDividerRowView, .init(coder:), .init(frame:), SessionGroupHeaderRowView, .init(coder:), .init(frame:), SessionWorktreeHeaderRowView, .init(coder:) (+23 more)

### Community 57 - "BellScanState"
Cohesion: 0.06
Nodes (35): Executor, Hook, HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane (+27 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.06
Nodes (26): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+18 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.15
Nodes (13): AgentTableEntry, MatchSource, ownProcess, wrapperLaunch, RawMatch, Bool, Set, String (+5 more)

### Community 60 - "ViEngine"
Cohesion: 0.09
Nodes (23): .windowSection, KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:fileSearchRoots:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:), .scrollbackLines, ResizeOverlayMode, afterFirst, always (+15 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.10
Nodes (34): Codable, BrowserSnapshotAck, BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserResponsePayload, cookies (+26 more)

### Community 62 - "ComposedCell"
Cohesion: 0.06
Nodes (30): DiffLineType, added, deleted, modified, Notification.Name, ObserverToken, Bool, DispatchWorkItem (+22 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.15
Nodes (11): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, PaneID (+3 more)

### Community 64 - ".text"
Cohesion: 0.08
Nodes (15): PluginLoader, String, ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String (+7 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.11
Nodes (14): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+6 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.17
Nodes (3): KouenSettingsTests, URL, Void

### Community 67 - "String"
Cohesion: 0.08
Nodes (19): Int32, TimeInterval, EndpointConnector, Int32, String, decodeBoundedCString(), makeUnixStreamSocket(), setNoSigPipe() (+11 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.13
Nodes (7): Bool, String, UInt8, UnsafeBufferPointer, TerminalEmulator, .captureLines(joinWrapped:), .onSetClipboard

### Community 69 - ".compose"
Cohesion: 0.11
Nodes (16): .selectWorkspace(byIndex:), .syncFromDaemon(metadataOnly:), ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy (+8 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf, .init(from:) (+10 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.06
Nodes (40): MonoPillButtonStyle, Configuration, ButtonStyle, CommandRow, .body, GlassCard, .body, GlassPrimaryButtonStyle (+32 more)

### Community 72 - "XCTestCase"
Cohesion: 0.06
Nodes (24): Logger, OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, .event(_:), .interval(_:_:) (+16 more)

### Community 73 - "README.md"
Cohesion: 0.09
Nodes (23): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+15 more)

### Community 74 - "[2.6.0] - 2026-06-13"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 75 - "OptionStore"
Cohesion: 0.14
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRectSolver, Bool, Double, .split(node:targetPaneID:direction:paneCount:before:) (+3 more)

### Community 76 - ".parse"
Cohesion: 0.10
Nodes (11): KouenCLITests, URL, Bool, KouenFilePreviewLoader, KouenViewError, binaryOrUnsupportedEncoding, missingPath, tooLarge (+3 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.07
Nodes (36): Equatable, DecodedImage, .byteCount, UInt8, KouenGridTerminal, .currentSelectionRegion, ClosedRange, SelectionResolver (+28 more)

### Community 78 - "Added"
Cohesion: 0.03
Nodes (34): KouenCore, KouenDaemonCore, Phase67Tests, Tab, TabID, WorkspaceID, TabAlertTests, ClaudeCodeHarnessIPCTests (+26 more)

### Community 79 - "HarnessDesign"
Cohesion: 0.10
Nodes (20): AppKit, CoreGraphics, CoreText, KouenCopyMode, KouenTerminalEngine, KouenTerminalKit, KouenTerminalRenderer, KouenTheme (+12 more)

### Community 80 - "Agent handbook — Harness (extended reference)"
Cohesion: 0.09
Nodes (27): .filteredJobs, MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith (+19 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.06
Nodes (33): JSONDecoder, JSONEncoder, CodingKeys, cols, createdAt, dataBase64, rows, timeMs (+25 more)

### Community 82 - ".firstMatch"
Cohesion: 0.12
Nodes (17): FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID, FeatureTask (+9 more)

### Community 83 - "LSPClient"
Cohesion: 0.25
Nodes (7): OptionStore, Scope, pane, session, workspace, ScopedKey, URL

### Community 84 - "LSPDiagnostic"
Cohesion: 0.10
Nodes (14): .effectiveResumeCommand(claudeMode:), LiveClaudeAgentEntry, .placement, ClaudeSessionMode, ClaudeCloudSessionStore, Entry, Date, String (+6 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.22
Nodes (11): AsyncRunCoordinator, ProcessResult, .isSuccess, Bool, CheckedContinuation, DispatchWorkItem, Int32, Never (+3 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.11
Nodes (23): TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid, .gridOriginPointsX (+15 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.09
Nodes (10): Bool, Range, Set, String, URLDetection, CGFloat, CGRect, Range (+2 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 89 - ".cursorPos"
Cohesion: 0.07
Nodes (34): .agentInfo(forWorktreePath:), AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary (+26 more)

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.04
Nodes (35): json, item, .parseAntigravityTranscript(sessionID:fileURL:toIndex:), .parseClaudeTranscript(fileURL:toIndex:), .parseCodexTranscript(fileURL:surfaceTag:ftsIndex:toIndex:), .readJSONLLines(from:fromOffset:), Any, ClaudeSessionLocator (+27 more)

### Community 91 - "TerminalModes"
Cohesion: 0.11
Nodes (24): ClientRecord, CountBox, DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed (+16 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.11
Nodes (16): .body, .mcpButton, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter, Any (+8 more)

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.08
Nodes (26): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+18 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.10
Nodes (8): SliderRow, .body, .displayValue, ClosedRange, Double, String, KouenSettings, ExperienceModeTests

### Community 95 - "shim.c"
Cohesion: 0.15
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 96 - "Harness Usage"
Cohesion: 0.17
Nodes (18): AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), GlyphKey, ShapedGlyphKey (+10 more)

### Community 97 - "PaneContainerView"
Cohesion: 0.18
Nodes (5): CellOverlayTests, IndexSet, NSWindow, String, UInt64

### Community 98 - "4. Technical Architecture"
Cohesion: 0.24
Nodes (8): NaturalLanguage, AgentHistorySearch, Hit, IDFCache, Bool, Double, String, .tokenHits(_:inNormalized:)

### Community 99 - ".dispatch"
Cohesion: 0.05
Nodes (38): Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions, Logical Design, P41 — Automations, Strategic Design, Tactical Design (+30 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.06
Nodes (31): AgentHistoryDateGroup, older, .sortOrder, thisWeek, today, yesterday, AgentSessionHistoryModel, .extraRecordsShown (+23 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.08
Nodes (18): NSScrollView, NSWindow, Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent (+10 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.13
Nodes (5): .setupPrompt, hooks, AgentHookInstallerTests, String, URL

### Community 103 - "AnyCodable"
Cohesion: 0.15
Nodes (9): FormatContext, FormatString, FormatStyle, Bool, Character, Date, String, FormatStyledTests (+1 more)

### Community 104 - "Recipe"
Cohesion: 0.10
Nodes (20): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+12 more)

### Community 105 - "Changelog"
Cohesion: 0.07
Nodes (25): .body, .init(coder:), Kind, primary, secondary, .init(coder:), KouenPillButton, .init(coder:) (+17 more)

### Community 106 - "domain-design.md"
Cohesion: 0.13
Nodes (11): FilePreviewCoordinator, FileTabID, Set, String, FileTab, .title, FileTabManager, .hasOpenTabs (+3 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.09
Nodes (20): String, DisplayLinkTarget, MainSplitViewController, .setSidebarVisible(_:), SplitChromeDelegate, .sidebarMaxWidth, .sidebarMinWidth, .splitView(_:constrainMaxCoordinate:ofSubviewAt:) (+12 more)

### Community 108 - ".resolve"
Cohesion: 0.18
Nodes (11): SwarmSpawnSpec, CallRecorder, .cancelCalls, .closeCalls, .harnessCalls, .surfaceCalls, SwarmWorkerManagerTests, Bool (+3 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.16
Nodes (34): aQ(), bqt(), cbe(), DD(), dqt(), Dr(), Eqt(), Fa() (+26 more)

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.13
Nodes (9): FileEditorView, Bool, NSEvent, NSHostingView, String, URL, FileEditorViewQuickLookRoutingTests, String (+1 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.09
Nodes (12): CustomStringConvertible, KouenPaths, KouenPathsError, .description, socketPathTooLong, Bool, String, URL (+4 more)

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.14
Nodes (18): CommandParseError, .description, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand (+10 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.11
Nodes (15): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+7 more)

### Community 115 - ".encode"
Cohesion: 0.14
Nodes (15): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+7 more)

### Community 116 - "SessionGroup"
Cohesion: 0.12
Nodes (13): SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, SessionID, String, SurfaceID (+5 more)

### Community 117 - "PaneNode"
Cohesion: 0.08
Nodes (16): .init(coder:), .init(coder:), BrowserTabButton, .init(coder:), DesignModePopoverViewController, .init(coder:), .init(title:properties:styles:onStyleChanged:onCopyCSS:onPromptAgent:), SelectAllOnClickTextField (+8 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.09
Nodes (30): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+22 more)

### Community 119 - "Harness command reference"
Cohesion: 0.09
Nodes (22): BrowserPaneRegistry, .init(url:paneID:), .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), BrowserProgressLine, .init(frame:), DesignModeElementInfo, NSLayoutConstraint (+14 more)

### Community 120 - "Added"
Cohesion: 0.06
Nodes (27): DaemonClientActor, TimeInterval, DaemonSessionError, daemonError, .description, unexpectedResponse, DaemonSessionService, .endpoint (+19 more)

### Community 121 - "Changed"
Cohesion: 0.14
Nodes (8): MutationResult, RemoteHost, RemoteHostStore, Bool, String, RemoteHostStoreTests, String, URL

### Community 122 - "ViEngine"
Cohesion: 0.11
Nodes (19): String, DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerFooter, .body (+11 more)

### Community 123 - "Pipe"
Cohesion: 0.11
Nodes (16): PaletteWindowDelegate, Array, PickerItemRow, .badgeText, .iconName, .subtitle, .titleText, RecipePanel (+8 more)

### Community 124 - "String"
Cohesion: 0.17
Nodes (8): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, String, PaneStyleTests

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.10
Nodes (14): T, constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String (+6 more)

### Community 126 - ".path"
Cohesion: 0.13
Nodes (10): ScrollbackFile, .highWater, Bool, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.11
Nodes (32): blockquote(), br(), checkbox(), codespan(), constructor(), de(), del(), em() (+24 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.20
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 129 - "SwiftUI"
Cohesion: 0.04
Nodes (55): AnyTransition, AnyView, Color, .hexString, AgentNotchRootView, .body, .bottomRadius, .closedAccessibilityLabel (+47 more)

### Community 130 - "Harness"
Cohesion: 0.05
Nodes (43): a0n(), Ac(), cae(), cht(), e3n(), e5n(), eAn(), ebt() (+35 more)

### Community 131 - ".install"
Cohesion: 0.14
Nodes (13): Bool, CGFloat, NSEvent, NSRange, NSString, NSTextView, String, ViEngine (+5 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.22
Nodes (10): CopyModeGridSource, .promptRows, ClosedRange, CopyModeReducer, Bool, Character, NSRegularExpression, Range (+2 more)

### Community 133 - ".load"
Cohesion: 0.14
Nodes (7): KeybindingsStore, .fileURL, URL, KeybindingsStoreTests, URL, Void, String

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.06
Nodes (24): AgentNotchPresentation, closed, open, peek, AgentNotchViewModel, AgentNotchWindowActivator, Bool, CGFloat (+16 more)

### Community 135 - "CommandTarget"
Cohesion: 0.11
Nodes (13): MarkdownPreviewView, .webView(_:decidePolicyFor:decisionHandler:), Bool, MainActor, Sendable, String, URL, WKNavigationAction (+5 more)

### Community 136 - ".startWatching"
Cohesion: 0.11
Nodes (19): CodingKeys, error, id, jsonrpc, method, params, result, LSPDiagnostic (+11 more)

### Community 137 - "ActivePaneService"
Cohesion: 0.06
Nodes (23): Codex → Kouen, One-line install, What you'll see, Grok Build → Kouen, One-line install, What you'll see, Hermes → Kouen, One-line install (+15 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.11
Nodes (23): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, IssueInfo (+15 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.13
Nodes (12): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+4 more)

### Community 140 - "Added"
Cohesion: 0.11
Nodes (22): BinaryInstaller, .bundledMacOSDir, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display (+14 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.07
Nodes (18): Tab, BrowserIntegrationController, PaneID, ContentAreaViewController, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), .init(paneID:), Bool (+10 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.09
Nodes (11): Bool, NSDraggingInfo, NSDragOperation, Bool, NSDraggingInfo, NSDragOperation, NSPasteboard, URL (+3 more)

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, S (+2 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.27
Nodes (4): tool, KouenDaemonToolsTests, String, URL

### Community 145 - "AsciiFastPathTests"
Cohesion: 0.14
Nodes (14): CompletionPopupView, .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:), .isHovered, Bool (+6 more)

### Community 146 - "DecodedImage"
Cohesion: 0.26
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 147 - "FileTreeWatcher"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 148 - "TriState"
Cohesion: 0.15
Nodes (9): AsyncCLIResultBox, LSPDefinitionPayload, LSPDiagnosticsPayload, LSPStatusPayload, Error, Result, String, UInt64 (+1 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.09
Nodes (23): aie(), arc(), b2e(), bezierCurveTo(), closePath(), cRe(), cZ(), E7() (+15 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.11
Nodes (15): SavedLayoutStore, Bool, String, URL, UUID, PaneLayoutShape, branch, leaf (+7 more)

### Community 151 - ".evaluate"
Cohesion: 0.10
Nodes (15): StatusLineView, .init(coder:), Bool, CGFloat, Never, NSAttributedString, NSCoder, NSColor (+7 more)

### Community 152 - "Added"
Cohesion: 0.10
Nodes (20): Coordinator, DiffAnalysis, DiffFileItem, DiffFileStatus, added, .color, deleted, modified (+12 more)

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.12
Nodes (12): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+4 more)

### Community 154 - "LiveResizeTests"
Cohesion: 0.11
Nodes (13): FileFuzzyMatcher, FileSearchRootScanner, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool (+5 more)

### Community 155 - "Int"
Cohesion: 0.03
Nodes (87): _1t(), _5n(), a2t(), agn(), agt(), bce(), c8n(), cAn() (+79 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.14
Nodes (16): Any, ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool (+8 more)

### Community 157 - "Added"
Cohesion: 0.15
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.15
Nodes (8): CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16, UInt8, CharacterWidthTests

### Community 159 - "MatchCategory"
Cohesion: 0.08
Nodes (10): .feed(_:), .promptRows, .readGrid(scrollbackOffset:), ImageProtocolTests, String, ScrollbackTests, Character, String (+2 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.08
Nodes (16): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, SurfaceID, Tab (+8 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.16
Nodes (16): FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose, .onSelect (+8 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.15
Nodes (8): BoardViewController, .isVisible, FlippedView, .isFlipped, Bool, Set, TabID, BoardViewControllerTests

### Community 163 - "Workspace"
Cohesion: 0.13
Nodes (10): ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID, String, SurfaceID (+2 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.04
Nodes (29): NSCursor, NSRangePointer, Bool, CAMetalDrawable, NSEvent, String, Any, Bool (+21 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.25
Nodes (5): FileTreeScanOptions, ScoredMatch, Bool, String, .scanOptions

### Community 166 - "LiveSession"
Cohesion: 0.17
Nodes (7): ParsedShortcut, .displayString, PrefixKeymap, Any, NSEvent, String, TimeInterval

### Community 167 - "AgentTableEntry"
Cohesion: 0.18
Nodes (10): BranchSwitchHelper, FileTreeNode, FileTreeSwiftUIView, .body, .pastedImagesSection, Notification.Name, Bool, NSMenuItem (+2 more)

### Community 168 - "Added"
Cohesion: 0.12
Nodes (13): CKouenSys, pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal (+5 more)

### Community 169 - "Fixed"
Cohesion: 0.16
Nodes (10): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab, UUID (+2 more)

### Community 170 - "URLDetection"
Cohesion: 0.05
Nodes (25): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+17 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.01
Nodes (340): _2t(), _4e(), _7n(), a2n(), a8n(), a_n(), aA(), aAn() (+332 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.08
Nodes (31): ColorKind, .base, bg, fg, underline, ComposedCell, .asGridCell, .cluster (+23 more)

### Community 173 - "BoardCard"
Cohesion: 0.15
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.15
Nodes (16): ClaudeCodeHarness, Profile, edit, readonly, Run, RunState, cancelled, failed (+8 more)

### Community 175 - "RGBColorTests"
Cohesion: 0.10
Nodes (15): LSPMessage, notification, request, response, Decoder, Encoder, KeyedDecodingContainer, LSPTransport (+7 more)

### Community 176 - "Added"
Cohesion: 0.12
Nodes (10): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+2 more)

### Community 177 - ".rects"
Cohesion: 0.15
Nodes (9): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSWindow (+1 more)

### Community 178 - "InlineAICompletionView"
Cohesion: 0.09
Nodes (19): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+11 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.14
Nodes (10): .rootPicker, FileTreeContext, NSHostingView, SessionID, String, Void, WorkspaceFileTreeView, .init(rootPath:) (+2 more)

### Community 181 - "GridCompositorTests"
Cohesion: 0.09
Nodes (11): KouenLSP, FileGraphInfo, GraphifyLSPBridge, Double, String, URL, QuickLookUI, GraphifyLSPBridgeTests (+3 more)

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.13
Nodes (13): MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem, SessionGroup (+5 more)

### Community 183 - "LSPServerRegistry"
Cohesion: 0.12
Nodes (24): .color, BoardCard, BoardColumn, .name, BoardColumnKind, .displayName, done, error (+16 more)

### Community 184 - "targets"
Cohesion: 0.21
Nodes (5): CopyModeReducerTests, FakeGrid, .totalLines, Set, String

### Community 185 - "SessionSnapshot"
Cohesion: 0.12
Nodes (10): .readJSONLLines(from:), AntigravitySessionLocator, AntigravityTranscriptLine, Bool, Int32, NSRegularExpression, String, URL (+2 more)

### Community 186 - "Error"
Cohesion: 0.14
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 187 - "AppDelegate"
Cohesion: 0.11
Nodes (22): keys, ITerm2InlineImage, .heightArg, .preserveAspectRatio, .widthArg, Bool, String, UInt8 (+14 more)

### Community 188 - "BrowserPaneView"
Cohesion: 0.09
Nodes (17): Bool, String, UUID, TaskDaemonBridge, SessionID, Status, ciFailing, done (+9 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.18
Nodes (7): CheckpointInfo, CheckpointManager, Bool, Date, String, CheckpointManagerTests, String

### Community 190 - "user-stories.md"
Cohesion: 0.10
Nodes (31): a6(), aJ(), bXt(), cJ(), dXt(), F0(), fXt(), gC() (+23 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.07
Nodes (28): Additional `kouen-cli` subcommands, Agent safety CLI (`kouen-cli`), Agents, context and scratchpad, Attaching from a plain terminal, Bindings, Board and attention, Buffers (paste store), Composition (+20 more)

### Community 192 - "GlyphRasterizer"
Cohesion: 0.12
Nodes (12): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, input (+4 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.07
Nodes (12): Divergence, Bool, String, TimeInterval, WorktreeInfo, WorktreeManager, String, WorktreeIsolationTests (+4 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.11
Nodes (14): string, AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID, .snapshotPayload (+6 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.25
Nodes (4): ControlKeyNormalizer, Bool, String, ControlKeyNormalizerTests

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.11
Nodes (10): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+2 more)

### Community 198 - ".classify"
Cohesion: 0.13
Nodes (23): Colors, Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors (+15 more)

### Community 199 - "code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)"
Cohesion: 0.19
Nodes (11): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, .selectedHost (+3 more)

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.15
Nodes (16): dhn(), en(), fhn(), ghn(), gk(), GOt(), jUe(), kr() (+8 more)

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.12
Nodes (8): AgentDetection, AgentDetector, Date, Int32, TimeInterval, ProcessScan, Int32, AgentSnapshot

### Community 202 - "PaletteModel"
Cohesion: 0.13
Nodes (9): AgyMobileCommands, String, ClaudeMobileCommands, Set, String, slashCommandChunks(), String, MobileBridgeAgentCommandTests (+1 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.16
Nodes (11): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+3 more)

### Community 204 - "From tmux"
Cohesion: 0.12
Nodes (14): CGFloat, NSCoder, SessionID, String, Void, TaskDashboardBody, .body, TaskDashboardView (+6 more)

### Community 205 - "CopyModeState"
Cohesion: 0.11
Nodes (9): String, WorkspaceID, CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab, DaemonSyncServiceBranchNotifyTests (+1 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.21
Nodes (8): SettingsAdvancedView, .body, Bool, String, SettingsFileSearchSection, .body, String, SwiftUI

### Community 207 - "scheduleRender"
Cohesion: 0.06
Nodes (15): Any, CGFloat, NSEvent, NSMenu, NSMenuItem, String, NSEvent, UInt8 (+7 more)

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.14
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 209 - "SettingsRemoteView"
Cohesion: 0.20
Nodes (10): .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didStartProvisionalNavigation:), LoadCompletionState, Bool, CheckedContinuation, Double, Error (+2 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.14
Nodes (15): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+7 more)

### Community 211 - "PaneTarget"
Cohesion: 0.13
Nodes (16): clamp(), Date, Never, T, TabID, Task, Void, TabPillView (+8 more)

### Community 212 - ".translate"
Cohesion: 0.19
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.15
Nodes (9): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, Set, SurfaceID, Tab (+1 more)

### Community 215 - ".lines"
Cohesion: 0.13
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 217 - "GridCompositor"
Cohesion: 0.15
Nodes (9): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ProcessInfo (+1 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.11
Nodes (16): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+8 more)

### Community 219 - "Prompt"
Cohesion: 0.17
Nodes (11): NotchGeometry, .fallback, NSScreen, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics (+3 more)

### Community 220 - "Section"
Cohesion: 0.08
Nodes (24): Font, .kouenBadge, .kouenBody, .kouenBodyStrong, .kouenCaption2, .kouenCaption, .kouenKbd, .kouenMono (+16 more)

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.20
Nodes (4): AgentHandoffBuilder, Bool, String, AgentHandoffBuilderTests

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.15
Nodes (11): CryptoKit, DecodedWSFrame, Bool, ConnectionState, NWConnection, String, UInt8, WSFrameParseResult (+3 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.13
Nodes (16): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, .bytesPerWakeup, .mbps (+8 more)

### Community 224 - "CellColorResolver"
Cohesion: 0.04
Nodes (92): a1t(), amn(), b2t(), cDt(), cg(), ch(), cU(), cvt() (+84 more)

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.11
Nodes (16): CodingKeys, error, id, jsonrpc, method, JSONRPCId, int, string (+8 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.14
Nodes (13): IssueKeychainStore, Bool, String, IssueTrackerType, azureDevOps, github, .id, jira (+5 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.16
Nodes (3): CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 228 - "sessionRow"
Cohesion: 0.11
Nodes (21): AgentMark, .body, AgentMarkShape, Scanner, .atEnd, SVGPath, Bool, CGFloat (+13 more)

### Community 229 - ".decide"
Cohesion: 0.32
Nodes (3): BinaryInstallerVersionTests, String, URL

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.15
Nodes (7): PasteController, Bool, NSPasteboard, String, TimeInterval, URL, PasteControllerTests

### Community 231 - "ExternalOpenKind"
Cohesion: 0.19
Nodes (10): RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal, FileHandle, Int32 (+2 more)

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 233 - "TextGrid"
Cohesion: 0.13
Nodes (15): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+7 more)

### Community 234 - ".scan"
Cohesion: 0.11
Nodes (11): DataBox, .removeWorktreeAction(path:), GitResult, Bool, GitResult, String, ValidateOutcome, WorktreeEntry (+3 more)

### Community 235 - "WorkbenchCommand"
Cohesion: 0.21
Nodes (7): BrowserOkAck, Sendable, T, ConnectionState, ErrorAck, NWConnection, UUID

### Community 236 - "Added"
Cohesion: 0.21
Nodes (8): DaemonMetrics, Snapshot, .meanLockWaitMicros, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.20
Nodes (6): Keyboard Shortcuts, AI Browser Control (kouen-mcp), HTTP/SSE authentication, Install, Shell integration (OSC 133 semantic prompts), What gets emitted

### Community 238 - ".make"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 240 - "PaneBorderStatus"
Cohesion: 0.26
Nodes (7): Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 241 - "Added"
Cohesion: 0.14
Nodes (11): AgentRoutingResolver, String, AgentRoutingRule, Kind, path, stack, Bool, Date (+3 more)

### Community 242 - "AgentBridge"
Cohesion: 0.22
Nodes (7): AgentRoutingRuleStore, Bool, String, URL, UUID, AgentRoutingRuleStoreTests, URL

### Community 243 - ".make"
Cohesion: 0.15
Nodes (16): DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:), .isWorktreeSession (+8 more)

### Community 244 - "FileNode"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 246 - "Experience modes"
Cohesion: 0.17
Nodes (4): AgentHistoryMultiAgentCoverageTests, Bool, String, URL

### Community 247 - ".renderFixture"
Cohesion: 0.08
Nodes (6): CodepointRunFastPathTests, .assertAllPathsAgree(_:cols:rows:file:line:), StaticString, String, UInt, UInt8

### Community 248 - "DaemonMetrics"
Cohesion: 0.11
Nodes (6): PromptQueue, String, SurfaceID, Void, PromptQueueBar, NSWindow

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.14
Nodes (12): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+4 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.13
Nodes (14): NSEvent, PaneDropZoneOverlay, .init(coder:), .init(targetPaneID:), NSCoder, NSPoint, NSRect, PaneID (+6 more)

### Community 251 - "SessionCoordinator"
Cohesion: 0.17
Nodes (3): OutputBuffer, ProcessRunner, ProcessRunnerTests

### Community 252 - "NSViewRepresentable"
Cohesion: 0.22
Nodes (8): NodeRow, .body, .parentDirectory, .resolvedGitStatus, Error, Never, String, Task

### Community 253 - "Split Right"
Cohesion: 0.11
Nodes (16): AgentSessionHistoryView, .body, .footerView, HistoryMenuProxy, Any, Bool, CGFloat, Date (+8 more)

### Community 254 - "BoardViewController"
Cohesion: 0.19
Nodes (13): ProjectGroupWatcher, StreamBox, Bool, DispatchQueue, escaping, FSEventStreamRef, MainActor, Never (+5 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.15
Nodes (11): SwarmFleetBody, .body, SwarmFleetView, .init(coder:), SwarmNodeRowView, .body, .statusColor, CGFloat (+3 more)

### Community 256 - "GitMetadataProvider"
Cohesion: 0.17
Nodes (21): Decodable, Item, ItemCompletedLine, LegacyMsgLine, Msg, String, ThreadStartedLine, AgentCommandRequest (+13 more)

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.08
Nodes (26): Motion, .entrance, .spring, .standardEase, CAMediaTimingFunction, AmbientBackground, .body, Bool (+18 more)

### Community 258 - "WindowTitleStripView"
Cohesion: 0.14
Nodes (7): SGRMouse, SGRMouseEvent, Bool, UInt8, SGRMouseTests, String, UInt8

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.15
Nodes (4): .selectWorkspace(_:), Bool, TimeInterval, HandoffDirectoryTests

### Community 260 - ".welcome"
Cohesion: 0.13
Nodes (15): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+7 more)

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.10
Nodes (8): ProjectGroupResolver, String, String, .trimmed, AgentTitleInference, Bool, .effectiveAgentKind, AgentDetectorTests

### Community 262 - ".install"
Cohesion: 0.05
Nodes (27): CornerInfo, EditorDividerView, HitTestPassthroughView, KouenSplitView, .dividerColor, .dividerThickness, .init(coder:), PaneDragGripView (+19 more)

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.25
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 264 - "code:bash (harness-cli install-hooks claude-code)"
Cohesion: 0.18
Nodes (6): DefaultTerminalLaunchRequest, ShellQuoting, Bool, String, URL, DefaultTerminalLaunchRequestTests

### Community 265 - "code:bash (harness-cli install-hooks cursor)"
Cohesion: 0.16
Nodes (14): SecureInputMonitor, DispatchQueue, DispatchWorkItem, MainActor, Sendable, Set, SurfaceID, UUID (+6 more)

### Community 266 - ".path"
Cohesion: 0.13
Nodes (11): GitRunner, GitResult, String, TimeInterval, URL, GitService, Bool, GitResult (+3 more)

### Community 267 - ".performInstall"
Cohesion: 0.18
Nodes (20): CoreImage, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription, .surfaceID, detectHost() (+12 more)

### Community 268 - "code:bash (# Old (agent-specific):)"
Cohesion: 0.20
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 269 - "DefaultTerminalManager"
Cohesion: 0.22
Nodes (7): Group, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, CGFloat, NSTextField, NSWindow

### Community 270 - "WindowSession"
Cohesion: 0.14
Nodes (10): Bool, CGFloat, NSCoder, NSLayoutConstraint, NSPoint, NSRect, WindowTitleStripView, .init(coder:) (+2 more)

### Community 271 - "StatusLineView.swift"
Cohesion: 0.16
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 272 - "SGRMouseEvent"
Cohesion: 0.20
Nodes (14): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, SessionGroup, SessionID (+6 more)

### Community 273 - "KeySpec"
Cohesion: 0.15
Nodes (10): .effectiveResumeCommand(mode:), AgentLaunchCommands, AgentSessionMode, cloud, .launchCommand, .launchFlags, local, remoteControl (+2 more)

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.20
Nodes (6): Case, ReflowCorpusTests, .corpus, .goldenDir, String, URL

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.13
Nodes (3): Fze, O7, RD

### Community 276 - "SyntaxTextView"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 277 - ".run"
Cohesion: 0.16
Nodes (17): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+9 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.12
Nodes (3): AgentLaunchCommandsTests, URL, Void

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Kouen, Sparkle (+13 more)

### Community 280 - ".menu"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.10
Nodes (20): Agent Memory, AI-SDLC — Dev/QA Workflow Spine, AODD: the operating contract, AODD triage: every request passes this gate (silently, no announcement), Approval Gates (mandatory on the Requirement path), Audit and Done, Cheap-model delegation, Core facts (non-negotiable, not model-inferable — everything else is judgment) (+12 more)

### Community 283 - "FormatColor"
Cohesion: 0.17
Nodes (12): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+4 more)

### Community 284 - "click_ui_element"
Cohesion: 0.18
Nodes (11): Never, NSRegularExpression, Set, String, Task, URL, Void, WorkspaceSymbolIndex (+3 more)

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.16
Nodes (8): CustomEndpointTester, Result, Bool, String, URL, CustomEndpointTesterTests, URLRequest, URLSession

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.17
Nodes (5): TabID, WorkspaceID, AgentCommandTests, String, Tab

### Community 287 - ".apply"
Cohesion: 0.08
Nodes (31): CGFloat, FooterIconButton, .body, RecentProjectsMenuButton, .recents, SidebarFooterModel, SidebarFooterView, .body (+23 more)

### Community 288 - "AgentHookStrategy"
Cohesion: 0.13
Nodes (10): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, String (+2 more)

### Community 289 - "StatusLineWidthTests"
Cohesion: 0.19
Nodes (13): Array, Bool, Date, Decoder, PaneID, String, TabID, Tab (+5 more)

### Community 290 - "Process"
Cohesion: 0.13
Nodes (14): BinaryInstaller.DetectionStatus, SetupStepView, .body, .canInstall, .hooksDetail, .hooksTone, .hooksValue, .isSuccess (+6 more)

### Community 291 - "JSONDecoder"
Cohesion: 0.10
Nodes (18): CompleteStepView, Void, OnboardingStep, complete, discover, .id, setup, shell (+10 more)

### Community 294 - "GitHubCLIClient"
Cohesion: 0.20
Nodes (10): ContentLengthRejection, SSETransport, .isRunning, .listener, Bool, NWConnection, NWListener, Result (+2 more)

### Community 295 - "AgentApprovalBar"
Cohesion: 0.19
Nodes (7): AIProviderAwakeService, .closedLidOptedIn, Bool, NSObjectProtocol, Set, String, AIProviderAwakeServiceTests

### Community 296 - "NotificationBus"
Cohesion: 0.18
Nodes (6): Range, String, TerminalBufferMatch, TerminalBufferSearch, String, TerminalBufferSearchTests

### Community 297 - "settings.json"
Cohesion: 0.19
Nodes (5): FlippedView, .isFlipped, NSScrollView, NSTextView, GitPanelViewDiffPopoverTests

### Community 298 - "jobs"
Cohesion: 0.14
Nodes (9): BrowserLeaf, PaneNode, URL, DaemonSyncServiceBrowserLeafIdentityTests, Tab, DaemonSyncServiceBrowserPaneMergeTests, PaneID, PaneNodeBrowserTests (+1 more)

### Community 299 - "PaneNode"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 301 - ".parse"
Cohesion: 0.11
Nodes (19): GroupHeaderRow, .body, PickerItem, .groupLabel, historyBlock, .id, recipe, .searchableText (+11 more)

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.16
Nodes (10): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+2 more)

### Community 303 - ".encodeMouse"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 304 - "00-inception-plan.md"
Cohesion: 0.18
Nodes (6): LSPTextLocation, .position, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 305 - ".script"
Cohesion: 0.15
Nodes (9): _7(), A7(), a8(), bGt(), c8(), ene(), Gnn, IC() (+1 more)

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.14
Nodes (10): apn(), brn, grn, hrn(), JGe(), KGe(), prn(), qGe() (+2 more)

### Community 307 - "ViPathTokenTests"
Cohesion: 0.16
Nodes (10): FileNode, GitStatusType, added, deleted, modified, renamed, unmodified, untracked (+2 more)

### Community 308 - "Send Ex Command"
Cohesion: 0.21
Nodes (8): StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength, newline, TransportError, invalidUTF8Header, missingContentLength

### Community 309 - "Browser DevTools API (P28)"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.10
Nodes (14): .snapshot, Bool, String, ThemeService, BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped (+6 more)

### Community 312 - "AgentSnapshot"
Cohesion: 0.15
Nodes (8): CGImage, ImageIO, data, ImageLimits, Bool, ImageDecoder, SixelDecoder, UInt8

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.11
Nodes (17): .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:), .init(frame:) (+9 more)

### Community 314 - "code:bash (harness-cli install-hooks codex)"
Cohesion: 0.14
Nodes (19): .modifierFlags, NSEvent, BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, CodingKeys (+11 more)

### Community 315 - "code:bash (harness-cli install-hooks grok)"
Cohesion: 0.57
Nodes (3): ProjectConfig, Bool, String

### Community 316 - "code:bash (harness-cli install-hooks opencode)"
Cohesion: 0.11
Nodes (13): DetachedPaneOverlay, .init(coder:), .init(frame:style:), Style, detached, reconnectingChip, NSCoder, NSEvent (+5 more)

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.14
Nodes (7): KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, BinaryInstallerDisplayTests, OnboardingEnvironmentTests

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.21
Nodes (13): CellMetrics, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth, Bool (+5 more)

### Community 319 - "FormatColor"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.11
Nodes (18): fix ที่ค้างอยู่ใน working tree (ยังไม่ commit), Terminal grid ไม่ใช่ก้อนใหญ่ที่ระบุชนิดได้, ก้อนหลักเกี่ยวข้องกับ RenderBox, การให้ DeepSeek ตรวจเพิ่ม, ผลตรวจ preview ที่แยกจากแอปหลัก, ผลตรวจแอปหลัก, ภาคผนวก 1 — fleet 9 ต.ค. (P54) กระทบ UI ไหม → กระทบ ตรงจุด, ภาคผนวก 2 — 18 ต.ค. `8c5e0c8d` P59 (agy session, **unreviewed**) (+10 more)

### Community 321 - "UInt64"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 322 - "DesktopNotifier"
Cohesion: 0.12
Nodes (14): LayoutFileStore, LayoutNode, branch, leaf, LayoutTemplate, Date, Double, String (+6 more)

### Community 323 - "LayoutNode"
Cohesion: 0.09
Nodes (19): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+11 more)

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.18
Nodes (3): ShellIntegrationTests, .repoRoot, URL

### Community 325 - "FloatingPaneController"
Cohesion: 0.16
Nodes (16): SwarmFleetSnapshot, SwarmLane, pty, structured, SwarmTaskNode, SwarmTaskStatus, cancelled, failed (+8 more)

### Community 327 - ".theme"
Cohesion: 0.16
Nodes (4): KouenThemeCatalog, .allThemes, String, KouenThemeCatalogTests

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

### Community 330 - ".drawGlyph"
Cohesion: 0.19
Nodes (8): KouenCommands, DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.18
Nodes (4): GitAheadBehind, GitParsers, String, GitParsersTests

### Community 332 - "Added"
Cohesion: 0.11
Nodes (22): AgentBadgeView, .body, Bool, CGFloat, AgentIconRenderer, Scanner, .atEnd, SVGPathParser (+14 more)

### Community 333 - "RealPty"
Cohesion: 0.19
Nodes (9): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+1 more)

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.19
Nodes (13): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Bool, Duration (+5 more)

### Community 335 - ".makeModel"
Cohesion: 0.12
Nodes (18): Darwin, Foundation, Glibc, DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse (+10 more)

### Community 336 - "run.sh"
Cohesion: 0.21
Nodes (4): KeyTokenParser, Bool, String, KeyTokenParserTests

### Community 337 - "CommandExecutionError"
Cohesion: 0.13
Nodes (10): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String (+2 more)

### Community 338 - "CSIParams"
Cohesion: 0.21
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 339 - "Foundation"
Cohesion: 0.09
Nodes (25): bNt(), bu(), cNt(), dNt(), eNt(), eRe(), fNt(), h0t() (+17 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.13
Nodes (16): aDt(), Bpe(), cFe(), displayable(), Fpe(), KBe(), mFe(), oFe() (+8 more)

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.22
Nodes (6): ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 342 - "Added"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 344 - "FileViewerViewController"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 345 - "README.md"
Cohesion: 0.17
Nodes (9): GitStatusProvider, OnceResume, Bool, Duration, String, TimeInterval, GitStatusProviderLargeOutputTests, URL (+1 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.18
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.10
Nodes (14): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+6 more)

### Community 348 - "DaemonLifecycleTests"
Cohesion: 0.16
Nodes (13): BoxDrawing, Kind, arms, dashH, dashV, halfDown, halfLeft, halfRight (+5 more)

### Community 349 - "Contents.json"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.13
Nodes (11): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String, CompletionGenerator (+3 more)

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.24
Nodes (8): InstallResult, Shell, bash, fish, zsh, ShellIntegration, Bool, URL

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.19
Nodes (8): AgentRemoteControlDaemonService, Set, String, Void, AgentRemoteControlDaemonServiceTests, LogBox, .count, String

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.18
Nodes (10): AssistantLine, ClaudeAdapter, Content, Message, ResultLine, Bool, Double, String (+2 more)

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.11
Nodes (17): AgentUsage, .contextTokens, .init(from:), .init(inputTokens:outputTokens:cacheReadTokens:cacheWriteTokens:thinkingTokens:totalCostUSD:), .shortSummary, CodingKeys, cacheReadTokens, cacheWriteTokens (+9 more)

### Community 355 - ".deepMerge"
Cohesion: 0.26
Nodes (3): String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.12
Nodes (11): ObjectiveC, BrowserTabRepaintTests, RepaintCountingWebView, Any, Error, MainActor, Sendable, String (+3 more)

### Community 357 - ".handleCat"
Cohesion: 0.27
Nodes (4): ArchitectureGuardTests, .repoRoot, String, URL

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.13
Nodes (6): agentWaitChannel(), HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 360 - "State"
Cohesion: 0.23
Nodes (7): PaneOutputWaiter, PaneOutputWaitResult, Bool, CheckedContinuation, Never, Tab, UInt64

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.21
Nodes (4): Bool, String, SurfaceID, TimeInterval

### Community 362 - "RGBColor"
Cohesion: 0.17
Nodes (8): AgentListFormatter, Date, String, dvn(), AgentListFormatterTests, Bool, Date, String

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.17
Nodes (7): ConcurrentIndexSet, .count, DaemonContentionTests, SubscriptionBox, .count, String, URL

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.15
Nodes (12): OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Bool, Value, bool (+4 more)

### Community 366 - "Consumers"
Cohesion: 0.09
Nodes (15): .init(title:isActive:onSelect:onClose:), Bool, CGFloat, NSCoder, Void, TabNavigation, TabNavigationButtons, .init(coder:) (+7 more)

### Community 367 - "DaemonStats"
Cohesion: 0.12
Nodes (15): agy, claude, codex, copilot, hermes, kouen, __kouen_agy_next, __kouen_claude_next (+7 more)

### Community 368 - "Tab"
Cohesion: 0.07
Nodes (17): NSResponder, NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent (+9 more)

### Community 369 - "Git Panel"
Cohesion: 0.04
Nodes (70): _8n(), al(), ayn(), bdn(), bIn(), Bm(), bYe(), Cp() (+62 more)

### Community 370 - ".encode"
Cohesion: 0.24
Nodes (7): Int32, SessionGroup, SessionID, Tab, TabID, WorkspaceID, WindowAttachClient

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.33
Nodes (3): TaskStore, URL, TaskStoreTests

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.08
Nodes (16): DisplayWidth, String, Unicode, ReleaseNotes, Section, String, Run, String (+8 more)

### Community 373 - "Prompt"
Cohesion: 0.18
Nodes (8): ClaudeRunSummary, Date, Double, Int32, String, UUID, String, UUID

### Community 374 - ".run"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 375 - ".install"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 376 - "ScrollReuseTests"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 377 - "Identifiable"
Cohesion: 0.18
Nodes (8): BrowserFileReloadTests, CountingWebView, Nav, NSEvent, String, Void, WKNavigation, WKNavigationDelegate

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.18
Nodes (4): KeybindingsService, Bool, Command, String

### Community 379 - "MCPServer"
Cohesion: 0.37
Nodes (3): AgentBrowserPaneTracker, Set, AgentBrowserPaneTrackerTests

### Community 380 - "PromptQueue"
Cohesion: 0.27
Nodes (7): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection, agents

### Community 381 - "smoke-dmg.sh"
Cohesion: 0.20
Nodes (7): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, FileChangeWatcherTests

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.20
Nodes (8): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.33
Nodes (4): .setSidebarVisible(_:animated:), SidebarPlacementSyncTests, CGFloat, Void

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.16
Nodes (8): NSHostingView, NSLayoutConstraint, TerminalTabBarView, .delegate, .init(frame:), .leadingInset, .mouseDownCanMoveWindow, .trailingInset

### Community 385 - "INDEX.md"
Cohesion: 0.17
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.22
Nodes (11): MarkdownImageSchemeHandler, .webView(_:start:), .webView(_:stop:), Never, ObjectIdentifier, Task, URL, Void (+3 more)

### Community 387 - "User Profile"
Cohesion: 0.29
Nodes (4): SwarmDAGStore, String, UUID, SwarmDAGStoreTests

### Community 388 - "Darwin"
Cohesion: 0.15
Nodes (13): AgentNotchPeekDecider, AgentNotchPeekEvent, Reason, errored, finished, needsInput, RowState, Bool (+5 more)

### Community 389 - "HarnessCLITests"
Cohesion: 0.08
Nodes (14): ScriptAPI, ScriptError, .errorDescription, evaluationError, unsupportedPlatform, String, JavaScriptCore, KouenApp (+6 more)

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.15
Nodes (12): LinePos, end, firstNonBlank, start, Character, ViDiagnosticNavigator, ViMode, insert (+4 more)

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.13
Nodes (15): BrowserRequestPayload, close, cookies, evaluate, goBack, goForward, interact, navigate (+7 more)

### Community 392 - "build-release.sh"
Cohesion: 0.22
Nodes (10): DotView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor, NSRect (+2 more)

### Community 393 - "create-dmg.sh"
Cohesion: 0.15
Nodes (8): DispatchSource, DispatchQueue, DispatchSourceFileSystemObject, Int32, URL, Void, TranscriptFileWatcher, MobileBridgeTranscriptWatcherTests

### Community 394 - "finalize-release.sh"
Cohesion: 0.23
Nodes (13): kouen.bash script, agy(), claude(), codex(), copilot(), hermes(), kouen(), __kouen_agy_next() (+5 more)

### Community 395 - "generate-app-icon.sh"
Cohesion: 0.20
Nodes (7): HTTPURLResponse, SSETransportTests, Never, String, Task, UInt16, Void

### Community 396 - "generate-appcast.sh"
Cohesion: 0.22
Nodes (6): ListeningPortScanner, Int32, Set, String, result, ListeningPortScannerTests

### Community 397 - "measure-fluidity.sh"
Cohesion: 0.22
Nodes (5): RepoResolver, Bool, String, RepoResolverTests, String

### Community 398 - "preview.sh"
Cohesion: 0.18
Nodes (10): ScreenPos, bottom, middle, top, Bool, NSRange, NSString, NSTextView (+2 more)

### Community 399 - "sign-and-notarize.sh"
Cohesion: 0.13
Nodes (11): Am(), bze(), Cm(), EQ(), Hm(), Im(), lte(), MBe() (+3 more)

### Community 400 - "install-linux.sh"
Cohesion: 0.05
Nodes (30): FilterStatus, active, all, completed, CaseIterable, LayoutTemplate, evenHorizontal, evenVertical (+22 more)

### Community 401 - "package-app.sh"
Cohesion: 0.20
Nodes (13): ern(), G4(), G7(), Jnn(), nrn(), Qnn(), sHe(), trn() (+5 more)

### Community 402 - "View"
Cohesion: 0.21
Nodes (8): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, NSEvent, Observation

### Community 403 - "PresentAttempt"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.24
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 405 - "AgentIconRenderer"
Cohesion: 0.13
Nodes (11): Bool, Int32, InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal (+3 more)

### Community 406 - "main.swift"
Cohesion: 0.24
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 407 - "Fixed"
Cohesion: 0.13
Nodes (11): H7(), Lje(), Lme(), LRt(), N$e(), pR(), R0, vD() (+3 more)

### Community 408 - "IPC Architecture"
Cohesion: 0.09
Nodes (13): Any, NSPopover, NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body (+5 more)

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.17
Nodes (12): SurfaceProgressTracker, Bool, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void, Counter (+4 more)

### Community 410 - ".applyTerminalIdentity"
Cohesion: 0.21
Nodes (3): .hasAdapter(for:), Bool, ClaudeCodeHarnessTests

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.09
Nodes (17): ResubscribingSlot, OverlayBackground, Context, OverlayBackground, Context, .init(frame:), KouenOverlayBackground, RuntimeGlassEffectView (+9 more)

### Community 412 - "go.json"
Cohesion: 0.23
Nodes (9): AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor (+1 more)

### Community 413 - "javascript.json"
Cohesion: 0.20
Nodes (8): DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSViewCornerConfiguration, SurfaceID, Void

### Community 414 - "json.json"
Cohesion: 0.15
Nodes (13): CodingKey, CodingKeys, createdAt, cwd, done, id, sessionID, status (+5 more)

### Community 415 - "markdown.json"
Cohesion: 0.21
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.14
Nodes (7): KouenIPC, ExtractedTranscriptContent, SQLite3, PortableRelativeDateFormatter, Date, String, UUID

### Community 417 - "rust.json"
Cohesion: 0.08
Nodes (24): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, .acceptsFirstResponder (+16 more)

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.14
Nodes (14): Agent handbook — Kouen (extended reference), Agent integration, Build and test, IPC, Keyboard shortcuts, kouen-cli, Native terminal renderer, Repository map (+6 more)

### Community 419 - "typescript.json"
Cohesion: 0.16
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 420 - "yaml.json"
Cohesion: 0.41
Nodes (7): FeatureSummary, FeatureTaskSummary, GateSummary, Bool, Date, String, UUID

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 422 - "HintModeOverlay"
Cohesion: 0.15
Nodes (12): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+4 more)

### Community 424 - ".parseDiffHunks"
Cohesion: 0.23
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 425 - "AgentVectorIcon"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.24
Nodes (4): aD(), crn, ELt(), n2e()

### Community 427 - ".delay"
Cohesion: 0.23
Nodes (5): String, TextGrid, .totalLines, .viewportRows, WordColumnRangeTests

### Community 428 - "TaskDashboardView"
Cohesion: 0.11
Nodes (3): Bool, String, UUID

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.33
Nodes (4): SecureInputPromptScanner, Bool, SecureInputPromptScannerTests, String

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.24
Nodes (9): Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock, .block(id:) (+1 more)

### Community 431 - "BoardCardView"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 432 - "PathToken"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 434 - "Project History"
Cohesion: 0.12
Nodes (3): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess

### Community 436 - "WaitForRegistry"
Cohesion: 0.30
Nodes (5): SearchBenchmarks, String, UInt64, URL, Void

### Community 437 - "PickerItemRow"
Cohesion: 0.10
Nodes (13): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+5 more)

### Community 439 - "SetupStepView"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 440 - "LegacySnapshot"
Cohesion: 0.32
Nodes (3): hqe(), M9(), mUt()

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.24
Nodes (8): ProjectDropTarget, .init(coder:), .init(frame:), NSCoder, NSDraggingInfo, NSDragOperation, NSRect, URL

### Community 445 - "Section"
Cohesion: 0.24
Nodes (7): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor, .panelBackground

### Community 446 - "Modifiers"
Cohesion: 0.21
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 447 - "PaletteMode"
Cohesion: 0.15
Nodes (8): _Bt(), by(), e7e(), fst(), hxn(), lxn(), sBt, XWt()

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.22
Nodes (7): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController

### Community 449 - "PresentAttempt"
Cohesion: 0.41
Nodes (4): KouenFeatureMarkdownSync, Bool, String, URL

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.21
Nodes (5): FDWatchdog, DispatchSourceTimer, String, TimeInterval, FDWatchdogTests

### Community 451 - ".run"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.12
Nodes (5): KouenCLI, HistorySearchQueryTests, MemoCommandTests, URL, TaskCommandTests

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.18
Nodes (6): eKe(), irn(), mrn, _rn(), rrn(), srn()

### Community 454 - ".recordReapedGenerationForTesting"
Cohesion: 0.29
Nodes (3): BellScanTests, Bool, UInt8

### Community 455 - "ComposerPanel"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 456 - "TerminalModes"
Cohesion: 0.17
Nodes (10): .block(atPromptLine:), .captureLines(fromLine:toLine:), .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8 (+2 more)

### Community 458 - "PaneOutputWaiter"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 459 - ".encode"
Cohesion: 0.15
Nodes (6): KouenMCPServer, String, MCPServer, String, StdioTransport, AsyncStream

### Community 460 - "RunState"
Cohesion: 0.29
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 461 - ".worktreeList"
Cohesion: 0.24
Nodes (4): GroupedSessionTests, SessionGroup, Set, SurfaceID

### Community 462 - "AGENTS.md"
Cohesion: 0.22
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 463 - ".deinit"
Cohesion: 0.24
Nodes (6): DaemonAsyncReplyRoutingTests, Int32, String, TimeInterval, UInt8, URL

### Community 464 - "MouseButton"
Cohesion: 0.31
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 466 - "PlatformSys.swift"
Cohesion: 0.24
Nodes (4): HintModeOverlay, Any, NSEvent, String

### Community 467 - ".moveSelection"
Cohesion: 0.21
Nodes (5): ImageTextureCache, MTLDevice, MTLTexture, Set, UInt8

### Community 468 - "Never"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 469 - "PresentAttempt"
Cohesion: 0.17
Nodes (11): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile, regionEdit (+3 more)

### Community 470 - "DispatchTime"
Cohesion: 0.26
Nodes (4): PaneLabelDaemonTests, String, URL, UUID

### Community 471 - ".evaluateStyled"
Cohesion: 0.41
Nodes (5): InstallResult, ShellCompletionInstaller, Bool, String, URL

### Community 472 - "start.sh script"
Cohesion: 0.18
Nodes (11): Typography, .badge, .kbd, .paletteHeader, .paletteTitle, .rowMeta, .rowTitle, .sectionLabel (+3 more)

### Community 473 - "HarnessOnboarding"
Cohesion: 0.23
Nodes (3): MobileBridgeAttachFileTests, String, URL

### Community 474 - "String"
Cohesion: 0.26
Nodes (6): SwarmFleetSnapshotWire, SwarmTaskNodeWire, Date, Double, String, UUID

### Community 475 - ".hitTest"
Cohesion: 0.20
Nodes (9): AnyObject, CommandExecutionError, daemonError, .description, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor (+1 more)

### Community 476 - "StatusDotView"
Cohesion: 0.33
Nodes (5): AgentBridge, AgentTarget, Bool, String, SurfaceID

### Community 477 - "SavedLayoutIPCDaemonTests"
Cohesion: 0.18
Nodes (6): KouenCompositor, Configuration, TabSelector, active, id, session

### Community 478 - ".install"
Cohesion: 0.17
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 479 - "ScrollbackTests"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 480 - ".isRisky"
Cohesion: 0.06
Nodes (17): CLIInstallLocator, DetachKeys, absent, invalid, parsed, OptionalUUID, absent, dangling (+9 more)

### Community 481 - "SecureInputMonitor"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 482 - ".resolve"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 483 - "Changed"
Cohesion: 0.32
Nodes (3): ReflowPreviewTests, .feeds, String

### Community 485 - ".testKouenRendererFixtureLigatureShapingPathReportsPlausibleGlyphs"
Cohesion: 0.24
Nodes (5): RiskyCommandClassifier, Bool, NSRegularExpression, String, RiskyCommandClassifierTests

### Community 486 - "TabPillView"
Cohesion: 0.25
Nodes (7): DYt(), IR(), oXt(), pUe(), pXt(), rYt(), z7()

### Community 487 - "bC"
Cohesion: 0.27
Nodes (3): TabID, WorkspaceID, GitPanelViewWorktreeNavigationTests

### Community 488 - "R1"
Cohesion: 0.29
Nodes (9): AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand, Bool, Set (+1 more)

### Community 490 - "ccRunGet"
Cohesion: 0.17
Nodes (12): Architecture Decisions (dated log), Commit preparation, Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Markdown preview trust boundary, Post-P50 changes (v4.20.2 → v4.20.11, 2026-10-01 → 2026-10-06) (+4 more)

### Community 491 - ".update"
Cohesion: 0.27
Nodes (8): LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab, TabID, WorkspaceID

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.22
Nodes (3): Notification.Name, KouenGit, os

### Community 493 - "ccRunStart"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 494 - "ccRunInfo"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 495 - ".open"
Cohesion: 0.20
Nodes (5): Network, HTTPRequestPolicy, Bool, String, UInt16

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.34
Nodes (8): CGFloat, Range, Tab, TabBarLayoutMetrics, .pitch, TerminalTabBarBody, .body, TerminalTabBarModel

### Community 497 - ".bind"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 498 - ".runGitDiff"
Cohesion: 0.29
Nodes (7): AnimatablePair, NotchShape, .animatableData, CGFloat, CGPath, CGRect, Path

### Community 499 - "GlassEffectView"
Cohesion: 0.33
Nodes (6): Bool, NSPasteboard, NSString, String, URL, AutoreleasingUnsafeMutablePointer

### Community 500 - "zO"
Cohesion: 0.26
Nodes (5): Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 501 - "Fixed"
Cohesion: 0.15
Nodes (11): copyMode, esc(), fs, globalShortcuts, KEYBINDINGS, prefixTable, renderTable(), ROOT (+3 more)

### Community 502 - "Kouen Terminal — System Architecture"
Cohesion: 0.20
Nodes (7): HeadlessRunEvent, assistantText, result, sessionID, Bool, Double, String

### Community 503 - "Kouen Features"
Cohesion: 0.36
Nodes (6): HistorySearchEvidence, .body, .terms, Bool, String, Text

### Community 504 - "String"
Cohesion: 0.30
Nodes (8): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, PaletteFooter, .body

### Community 505 - ".tickFeatureWorktreeSweepLocked"
Cohesion: 0.20
Nodes (10): Agent Safety Net (Checkpoints, Verification, Write Guards), Claude Code Harness, Editor & LSP, How It Feels, Kouen Features, Mobile, Remote And Headless, Stack (+2 more)

### Community 506 - ".parseGitDiffOutput"
Cohesion: 0.17
Nodes (7): MainMenuBuilder, Bool, NSMenu, NSMenuItem, Selector, String, MenuTargetForkConversationTests

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.24
Nodes (4): AgentScanner, Bool, DispatchSourceTimer, TimeInterval

### Community 508 - "qLt"
Cohesion: 0.20
Nodes (7): BBe(), NBe(), PBe(), qLt(), sIt(), VBe(), zLt()

### Community 509 - "start.mjs"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 510 - "PromptQueue"
Cohesion: 0.20
Nodes (6): _c(), jY(), Nn(), _pe(), Pqe, qp()

### Community 511 - ".panePathLookup"
Cohesion: 0.05
Nodes (44): AgentChipView, .init(coder:), .intrinsicContentSize, ChromeBackdrop, .init(role:), ChromeRole, sidebar, tabBar (+36 more)

### Community 512 - ".setAttribute"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 513 - "ThemeDocument"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 515 - "RD"
Cohesion: 0.24
Nodes (3): ClaudeSessionModeTests, URL, Void

### Community 516 - "terminal_stress_runner.py"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 517 - "KouenCLI+Workbench.swift"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 518 - "Bool"
Cohesion: 0.24
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 519 - ".gestureRecognizer"
Cohesion: 0.24
Nodes (10): fwn(), HUe(), KD(), kXt(), $o(), UUe(), wXt(), xXt() (+2 more)

### Community 520 - "WriteOutcome"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 522 - ".viewDidLoad"
Cohesion: 0.13
Nodes (13): statusColor(), statusHelp(), Configuration, String, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, tabDisplayTitle(), TabStatus (+5 more)

### Community 523 - "fFe"
Cohesion: 0.27
Nodes (7): AgyModelCatalog, Catalog, Date, String, TimeInterval, ConnectionState, NWConnection

### Community 524 - "รายงานตรวจสอบการใช้หน่วยความจำสูงของ Kouen Terminal"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 525 - ".encodeAndWait"
Cohesion: 0.25
Nodes (8): A `claude` typed by hand, Claude Code → Kouen, Customizing, One-line install, Session mode: Remote Control / cloud / local, The reverse direction: a session opened in Claude showing up in Kouen, Verifying, What gets written

### Community 526 - "Kind"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Key spec syntax, Kouen keybindings, Persistence (+1 more)

### Community 527 - ".show"
Cohesion: 0.20
Nodes (8): IssuePriority, .color, high, low, medium, none, .symbol, urgent

### Community 528 - "worktree_review_dashboard.robot"
Cohesion: 0.40
Nodes (9): attribute_lines(), main(), redraw_frames(), repeated_chunk(), run_case(), sgr_lines(), truecolor_gradient(), unicode_lines() (+1 more)

### Community 529 - "WorktreeAutoIsolateService"
Cohesion: 0.16
Nodes (8): OutputTrigger, OutputTriggerStore, Bool, String, OutputTriggerMatcher, .matches(in:patterns:), String, OutputTriggerMatcherTests

### Community 530 - "HarnessChrome"
Cohesion: 0.22
Nodes (6): String, URL, ThemeCatalogEmbedTests, .embedSwift, .repoRoot, .sourceJSON

### Community 531 - "BrowserProgressLine"
Cohesion: 0.20
Nodes (4): BoardCommandTests, String, String, Tab

### Community 532 - "OpenClaw → Kouen"
Cohesion: 0.22
Nodes (8): Build order (unchanged from interview decision), G1 — @ file-path picker, G2 — shell tab-completion suggestion strip (heuristic, explicitly best-effort), G3 — AI command suggestion (via `claude` CLI subprocess), Logical Design, P37 Phase G — Autocomplete (mobile bridge), Strategic Design, Tactical Design

### Community 533 - "Pi → Kouen"
Cohesion: 0.22
Nodes (8): Artifacts, Client Application — Slice 1 (stacked panes, no persistence), Client Application — Slice 2 (per-workspace divider memory), Context, Dev Task Progress — Workspace Sidebar Panels (P42), Integration, Note on task re-sequencing (2026-07-17), Summary

### Community 534 - "p12_mcp.robot"
Cohesion: 0.22
Nodes (9): Contributors, Documentation, Install, Key features, Kouen, License, Requirements, Update (+1 more)

### Community 535 - "AgentNotification"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.22
Nodes (7): block, escFn, lineFilter, md, page, script, swift

### Community 539 - "SavedLayoutIPCDaemonTests"
Cohesion: 0.39
Nodes (4): SessionGroup, Any, String, Tab

### Community 541 - ".init"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 542 - ".init(from:)"
Cohesion: 0.39
Nodes (6): GitResult, .isSuccess, GitWorktreeInfo, Bool, Int32, String

### Community 543 - ".bufferLine"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 544 - "CodingKeys"
Cohesion: 0.31
Nodes (5): IssueTrackerPanelView, .body, .filteredIssues, .statusBannerText, String

### Community 545 - ".characterIndex"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 547 - "NSObject"
Cohesion: 0.25
Nodes (8): FeaturePhase, architect, completed, dev, interview, qaDesign, qaVerify, .title

### Community 548 - ".encode"
Cohesion: 0.40
Nodes (5): ResizeDirection, down, left, right, up

### Community 549 - ".init(from:)"
Cohesion: 0.33
Nodes (7): AYt(), IUe(), j9n(), KYt(), WYt(), yD(), _Yt()

### Community 550 - ".init(hex:)"
Cohesion: 0.22
Nodes (9): B3(), dFe(), _Dt(), fFe(), lFe(), _Ot(), sD(), TOt() (+1 more)

### Community 552 - "PaneLabelDaemonTests"
Cohesion: 0.25
Nodes (7): Claude Code hook push (in-process Task subagent detection), Client UI indicator, Detection core (AgentDetector, pure logic), IPC / Tab plumbing, P38 Phase B — Subagent Visibility — Dev Task Progress, Status: Rewritten 2026-07-14 after original implementation (tasks 1-5) was lost to a concurrent git operation before commit. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 553 - "harness.resource"
Cohesion: 0.25
Nodes (7): Original overlay build (built 2026-07-14, gated green, then deleted 2026-07-15 mid live-test), P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress, Pivot — merge into the Recipes picker (2026-07-15), Stage 1-2 — Engine/surface plumbing (built 2026-07-14, unchanged by the pivot, still in use), Status: Implementation pivoted mid-phase from a standalone overlay to a merge into the existing, Summary, Thread grouping — Zed framing folded into the same picker (2026-07-15)

### Community 554 - "eFe"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 555 - "code:bash (harness view <file>                        # syntax-highligh)"
Cohesion: 0.25
Nodes (7): #kouen, #practice, #score, #shell, #total, #unix, #vim

### Community 556 - "MobileBridgeSpawnTests"
Cohesion: 0.29
Nodes (5): ThaiClusterCopyTests, ThaiGrid, .columns, .totalLines, .viewportRows

### Community 557 - ".viewWillMove"
Cohesion: 0.25
Nodes (3): FlushSessionStateTests, String, URL

### Community 558 - "FindWindowMatcherTests"
Cohesion: 0.28
Nodes (5): SpecialKeyMappingTests, Bool, NSEvent, String, UInt16

### Community 561 - "AppIdleThrottle"
Cohesion: 0.31
Nodes (5): AgyAdapter, Result, ResultLine, String, UUID

### Community 563 - "AgentNotchViewModel.swift"
Cohesion: 0.11
Nodes (4): MenuTarget, AboutPanelController, AboutView, NSWindow

### Community 564 - "📁 IDE Sidebar"
Cohesion: 0.18
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

### Community 565 - "WriteOrigin"
Cohesion: 0.22
Nodes (7): KouenCLIPaths, .applicationSupport, .binDirectory, .installedCLIPath, .installedDaemonPath, .launchAgentURL, URL

### Community 566 - "TerminalTabBarView.swift"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.29
Nodes (7): 1. Plain Terminal, 2. Persistent Terminal, 3. Full Terminal, 4. Agent Workspace, Experience modes, Opting into the prefix + status line without switching modes, Persistence (ephemeral vs. persistent)

### Community 568 - ".installChromeBackground"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Kouen-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.36
Nodes (7): Document, Bool, Set, String, URL, ToolPolicy, .defaultURL

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.36
Nodes (3): .agentInfo(forWorktreePath:tabs:), Tab, GitPanelViewWorktreeAgentTests

### Community 571 - "ShellIntegrationTests"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 572 - "LayoutProbeView"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 574 - "FileTreeKeyboardNavigator"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 575 - ".toastErrorSummary"
Cohesion: 0.33
Nodes (6): h1t(), hae(), jgn(), pwn(), sfn(), _Ue()

### Community 576 - "Phase67Tests"
Cohesion: 0.20
Nodes (7): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, NSCoder, Void

### Community 577 - "concurrency.md"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

### Community 578 - "TaskDashboardBody"
Cohesion: 0.06
Nodes (11): SessionCoordinator, Bool, Double, PaneID, SessionID, String, SurfaceID, TabID (+3 more)

### Community 579 - "main.swift"
Cohesion: 0.33
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

### Community 580 - "ViInputMode"
Cohesion: 0.29
Nodes (6): Locked decisions (user-confirmed), Logical Design, P38 Phase A — Cross-Agent Worktree Diff/Review Dashboard — Design, Strategic Design, Tactical Design, Verification gate (this phase)

### Community 581 - "jD"
Cohesion: 0.29
Nodes (6): Logical Design, Next Step, P42 — Workspace Sidebar Panels, Parked (not in scope), Strategic Design, Tactical Design

### Community 582 - ".groupByRoot"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 585 - "P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 587 - "sheet-cheat.html"
Cohesion: 0.39
Nodes (5): AutomationSummary, Bool, Date, String, UUID

### Community 588 - "jHt"
Cohesion: 0.25
Nodes (8): BDt(), eFe(), kFe(), pC(), tDt(), Vpe(), xDt(), YBe()

### Community 589 - "Endpoint"
Cohesion: 0.29
Nodes (6): TerminalColorRole, background, cursor, foreground, palette, UInt8

### Community 590 - "lrn"
Cohesion: 0.36
Nodes (3): KouenSplitViewTests, LayoutProbeView, CGFloat

### Community 591 - "main.swift"
Cohesion: 0.32
Nodes (4): OcclusionTests, NSWindow, String, TimeInterval

### Community 592 - "commit-push.sh"
Cohesion: 0.25
Nodes (6): calculate(), constructor(), kOt(), mBt, r2e(), sOt()

### Community 593 - "dO"
Cohesion: 0.38
Nodes (4): AnyObject, ObjectIdentifier, TimeInterval, ZombieHoldRegistry

### Community 595 - "full-cycle.sh"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 596 - ".feed(_:)"
Cohesion: 0.29
Nodes (7): GRt(), n4e(), p7e(), r2(), tl(), vrt(), xq()

### Community 597 - "TerminalColorRole"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase D — Kitty Graphics Conformance Slice, Scope (locked), Tests

### Community 598 - ".encode"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua), Scope (locked), Tests

### Community 599 - ".terminalHostIfExists"
Cohesion: 0.33
Nodes (5): Logical Design, Next Step, P43 — Add Repo/Folder to Workspace, Strategic Design, Tactical Design

### Community 600 - "TaskDashboardGroupingTests"
Cohesion: 0.33
Nodes (5): Build, Release & Git Workflow, Build / Test / Run, Graphify before every delivery commit, Release packaging order, Worktree constraint

### Community 601 - "Hwe"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 602 - "Build locally"
Cohesion: 0.60
Nodes (5): main(), printHelp(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 603 - "fut"
Cohesion: 0.40
Nodes (3): String, URL, WorktreeSignatureTests

### Community 606 - "Quick start"
Cohesion: 0.47
Nodes (3): URL, TimeoutError, WorktreeLargeOutputRegressionTests

### Community 607 - "iRe"
Cohesion: 0.29
Nodes (6): Any, Error, MainActor, Sendable, String, Void

### Community 608 - ".zoomWindowIfDoubleClick"
Cohesion: 0.25
Nodes (4): Bool, NSEvent, NSEvent, NSEvent

### Community 610 - "TabStatus"
Cohesion: 0.29
Nodes (3): ScrollbackPersistenceTests, String, URL

### Community 613 - "shim.c"
Cohesion: 0.47
Nodes (4): Eme(), NR(), TUe(), uQt()

### Community 614 - "MainSplitViewController"
Cohesion: 0.40
Nodes (4): Findings, Sources, What this means for Kouen, Who creates branches / worktrees in AI coding tools

### Community 615 - "fences"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: animateSidebar setContentLeadingInset MainSplitViewController, Source Nodes

### Community 616 - "bump-version.sh"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: ProjectCategory FolderScanner ProjectDirectoryTree, Source Nodes

### Community 617 - "ScriptFileWatcher"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: BrowserPaneView createTab openBrowserPane navigation WebKit, Source Nodes

### Community 618 - "parse"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: KouenPreviewHome environment key daemon launch at startup, Source Nodes

### Community 619 - "_0n"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: session history search ranking branch best matches, Source Nodes

### Community 620 - "mS"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Kouen terminal product features agent workspace browser daemon session persistence remote control, Source Nodes

### Community 621 - "ViEngine"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: session persistence focus routing browser disposal memory bounded checkpoint undo verify worktree, Source Nodes

### Community 622 - "sBt"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: How should CheckpointManager.restore preserve the user staged index?, Source Nodes

### Community 623 - "inlineTokens"
Cohesion: 0.25
Nodes (7): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, String

### Community 624 - "gmn"
Cohesion: 0.07
Nodes (44): Encodable, ExpressibleByStringLiteral, AgyModelsPush, AISuggestionAck, AttachedAck, Body, BrowserFramePush, Cred (+36 more)

### Community 625 - "brt"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: OutputTriggerMatcher SecureInputMonitor UTF8, Source Nodes

### Community 628 - "ReplayStep"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 629 - "graphify reference: query, path, explain"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 630 - "HGe"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 631 - "die"
Cohesion: 0.70
Nodes (4): restart_daemon(), rollback_version_bump(), full-cycle.sh script, usage()

### Community 632 - "dne"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 633 - "g_n"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 634 - "qC"
Cohesion: 0.24
Nodes (3): KouenMCP, KouenBrowserToolsTests, URL

### Community 636 - ".handleCopyModeKey"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 640 - "zpt"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

### Community 641 - "[3.10.0] - 2026-06-27"
Cohesion: 0.50
Nodes (3): Caveats, Keep awake with the lid closed, Setup

### Community 642 - "qut"
Cohesion: 0.50
Nodes (4): Full local signing path (needs a Developer ID cert; not currently used), How this fork actually releases, Release runbook, Scripted flow

### Community 643 - "h7n"
Cohesion: 0.50
Nodes (3): exclude_hubs, no_viz, wiki

### Community 644 - "clean-state.sh"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: SSETransport auth token isRunning

### Community 645 - ".delay"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: What commands build and test Kouen and prepare Graphify before commit?

### Community 646 - "String"
Cohesion: 0.15
Nodes (3): AgentHookInstallerCLI, String, String

### Community 648 - "PtyDrainCeilingBenchmark"
Cohesion: 0.50
Nodes (4): dO(), m8(), rfn(), zfn()

### Community 649 - "h$t"
Cohesion: 0.67
Nodes (4): FVe(), hJ(), qVe(), Zme()

### Community 650 - "hjt"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 651 - "u0n"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 652 - "TerminalHostView"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 653 - "iOn"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 654 - "BlockContextMenuTests"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 655 - "nht"
Cohesion: 0.67
Nodes (3): commit_with_graph(), prepare_graph_for_commit(), graphify-commit.sh script

### Community 657 - "AgentNotchViewModel.swift"
Cohesion: 0.20
Nodes (7): FBe(), Gbe(), handler(), _Q(), s0n(), wHt(), Xo()

### Community 663 - "m6e"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 664 - "P37 Phase G — Autocomplete (mobile bridge)"
Cohesion: 0.67
Nodes (3): cat(), Hwe(), kYe()

### Community 665 - "nb"
Cohesion: 0.67
Nodes (3): cfn(), fut(), qYe()

### Community 666 - "BrowserIntegrationController"
Cohesion: 0.67
Nodes (3): dht(), k0t(), l1n()

### Community 668 - "nje"
Cohesion: 0.67
Nodes (3): iRe(), jNt(), zNt()

### Community 669 - "PaneLabelDaemonTests"
Cohesion: 0.40
Nodes (4): Cursor Agent → Kouen, Manual fallback, One-line install, What you'll see

### Community 739 - "graphify reference: commit hook and native CLAUDE.md integration"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Where are the Wave 1 deadlock, HTTP transport and markdown preview paths?, Source Nodes

### Community 2468 - "CommandParserTests.swift"
Cohesion: 0.10
Nodes (14): Bool, OptionSet, KeySpec, .description, .init(from:), .init(key:modifiers:), Modifiers, Decoder (+6 more)

### Community 2651 - ".detect"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 2652 - "TerminalCellWidth"
Cohesion: 0.08
Nodes (16): ImagePlacementSnapshot, Bool, TerminalCellWidth, normal, spacerTail, wide, TerminalCursor, TerminalCursorShape (+8 more)

### Community 2654 - ".loadFromDisk"
Cohesion: 0.50
Nodes (5): aut(), cpn(), hq(), kLt(), q1n()

### Community 2655 - "sBt"
Cohesion: 0.12
Nodes (18): eJ(), EUe(), eYt(), fme(), gKt(), gUe(), $He(), LC() (+10 more)

### Community 2656 - ".loadFromDisk"
Cohesion: 0.09
Nodes (17): SessionStore, DispatchWorkItem, TimeInterval, PendingVersionBanner, welcome, whatsNew, State, Bool (+9 more)

### Community 2660 - "MouseEventKind"
Cohesion: 0.50
Nodes (5): aze(), cR(), oze(), xGe(), yGe()

### Community 2661 - "inlineTokens"
Cohesion: 0.29
Nodes (7): blockTokens(), inlineTokens(), lex(), lexer(), lexInline(), me(), reflink()

### Community 2663 - "THIRD-PARTY-NOTICES.md"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 2664 - "WriteOutcome"
Cohesion: 0.50
Nodes (4): WriteOutcome, complete, failed, wouldBlock

### Community 2666 - "l1"
Cohesion: 0.04
Nodes (59): aV(), bC(), bX(), c6n(), cFt(), clamp(), CWt(), d0() (+51 more)

### Community 2667 - "azt"
Cohesion: 0.50
Nodes (3): azt(), ibe(), q$e()

### Community 2671 - "WriteOrigin"
Cohesion: 0.67
Nodes (3): WriteOrigin, automation, human

## Knowledge Gaps
- **2385 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+2380 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1136 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Work-memory lessons

**Known dead ends** — questions that led nowhere; don't re-derive.
- "KouenPreviewHome environment key daemon launch at startup" -> `KouenPaths`

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `PerformanceBenchmarks` to `graphify reference: extra exports and benchmark`, `IPCRequest`, `Command`, `LSPMessage`, `WriteOutcome`, `Changed`, `KittyKeyboardTests`, `VTParser`, `HarnessTerminalSurfaceView`, `MetalRendererTests`, `HarnessUILibrary`, `SpecialKey`, `code:block1 (Agent shell process)`, `HarnessTerminalSurfaceView`, `CopyModeAction`, `SplitPaneCoordinator`, `.request`, `WorktreeManager`, `Harness tmux-style capabilities`, `RGBColor`, `.parse`, `Added`, `Notification`, `Equatable`, `DaemonClient`, `MenuTarget`, `String`, `code:bash (swift build)`, `HarnessSettings`, `CodingKeys`, `HarnessSidebarPanelViewController.swift`, `RenderSchedulerTests`, `MobileBridgeSpawnTests`, `HarnessTerminalSurfaceView.swift`, `.buildCommand`, `HookEvent`, `DaemonServer`, `AgentNotchViewModel.swift`, `Fixed`, `Added`, `.init`, `.line`, `NSPanel`, `📁 IDE Sidebar`, `KouenOverlayBackground`, `3.2 สิ่งที่ implement แล้ว`, `ShellIntegrationTests`, `FrecencyDirectoryStore`, `ComposedCell`, `HarnessCLI+Server.swift`, `ViEngine`, `PrefixKeymap`, `TaskDashboardBody`, `String`, `main.swift`, `.compose`, `Completed Plans Archive`, `.groupByRoot`, `XCTestCase`, `README.md`, `OptionStore`, `sheet-cheat.html`, `TerminalProtocolCompatibilityTests`, `Endpoint`, `HarnessDesign`, `Agent handbook — Harness (extended reference)`, `DaemonSubscription`, `.firstMatch`, `.parse`, `HarnessPaths`, `SessionCoordinator`, `.cursorPos`, `Zombie View Crashes on macOS 26.5 + Swift 6.3.2`, `TerminalModes`, `TerminalCellWidth`, `code:bash (# Terminal 1: Create workspace with long-running job)`, `Quick start`, `shim.c`, `.loadFromDisk`, `PaneContainerView`, `4. Technical Architecture`, `Harness Usage`, `ScriptRuntime.swift`, `Session Grouping and Split Session Plan`, `AnyCodable`, `Recipe`, `domain-design.md`, `AgentNotchViewModel`, `code:text (:workbench start swift)`, `inlineTokens`, `HarnessGridTerminal`, `.makeSnapshot`, `gmn`, `graphify reference: query, path, explain`, `Added`, `ViEngine`, `Pipe`, `.handleCopyModeKey`, `FormatStringExtendedVariableTests`, `.path`, `SwiftUI`, `.install`, `AgentHookInstaller`, `Never`, `code:js (// ~/.config/harness/init.js)`, `CommandTarget`, `.startWatching`, `graphify reference: query, path, explain`, `User Story Mapping (MANDATORY)`, `Added`, `.testPaneLeafLegacyDecodeBackfillsSurfaceTabs`, `How to use Harness from the terminal only (no GUI)`, `AsciiFastPathTests`, `k0n`, `TriState`, `KouenSidebarPanelViewController+RecentProjects.swift`, `.evaluate`, `Added`, `What You Must Do When Invoked`, `LiveResizeTests`, `Added`, `Harness Terminal — IDE Sidebar Feature Branch`, `MatchCategory`, `AmbientBackground`, `ColorKind`, `CommandPromptController`, `ActiveTabCloseDisposition`, `Fixed`, `URLDetection`, `.decodeKeySpec`, `RGBColorTests`, `Added`, `InlineAICompletionView`, `[3.13.1] - 2026-07-02`, `VTConformanceCorpusTests`, `GridCompositorTests`, `P25 — iOS/iPadOS Support`, `LSPServerRegistry`, `Result`, `targets`, `SessionSnapshot`, `Error`, `AppDelegate`, `P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client`, `BinaryInstaller`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `.classify`, `MCP Server (harness-mcp)`, `Harness keybindings`, `scheduleRender`, `PaneTarget`, `.translate`, `NotchLayoutMetrics`, `CellColorResolverTests`, `GridCompositor`, `ScrollbackFile`, `.init`, `AgentNotchRowSummary`, `ANSIPalette`, `.setCellPixelSize`, `HarnessPathDisplay`, `graphify reference: add a URL and watch a folder`, `.resolve`, `.decide`, `ExternalOpenKind`, `TextGrid`, `.scan`, `WorkbenchCommand`, `Added`, `PaneBorderStatus`, `Added`, `.make`, `.renderFixture`, `DaemonMetrics`, `Split Right`, `GitMetadataProvider`, `WindowTitleStripView`, `.welcome`, `.install`, `[2.5.0] - 2026-06-12`, `.bufferLine`, `SyntaxTextView`, `autolink`, `TerminalScrollbarView`, `click_ui_element`, `After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md.`, `.resize`, `.apply`, `AgentHookStrategy`, `StatusLineWidthTests`, `JSONDecoder`, `escape`, `Fixes Applied (layered)`, `GitHubCLIClient`, `NotificationBus`, `settings.json`, `PaneNode`, `HarnessPaths.swift`, `.parse`, `.encodeMouse`, `E9`, `00-inception-plan.md`, `Browser DevTools API (P28)`, `Bug: Tab-Switch Black Screen`, `AgentSnapshot`, `FloatingPaneController`, `README.md`, `ImmersivePalette.swift`, `.drawGlyph`, `.recordReapedGenerationForTesting`, `run.sh`, `CSIParams`, `.jumpToBlock`, `code:bash (harness-cli install-hooks pi)`, `DaemonLifecycleTests`, `.init`, `Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)`, `P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)`, `.deepMerge`, `.handleCat`, `OcclusionTests`, `State`, `FormatStyledSegment.swift`, `[2.2.4] - 2026-06-11`, `Fixes Applied (v3.9.1+)`, `Consumers`, `Tab`, `DynamicInstanceBuffer`, `.install`, `User Profile`, `Darwin`, `generate-appcast.sh`, `preview.sh`, `View`, `Split Panes (NSSplitView)`, `Session/Tab/Pane Hierarchy & Top Bar (CASE-028)`, `javascript.json`, `rust.json`, `yaml.json`, `.delay`, `Competitive Position (as of v3.12.0, 2026-07-02)`, `WaitForRegistry`, `PickerItemRow`, `main.swift`, `PresentAttempt`, `SessionCoordinator.swift`, `.run`, `TerminalModes`, `PaneOutputWaiter`, `P2 — Async IPC Refactor: Design Document`, `PlatformSys.swift`, `.moveSelection`, `String`, `Changed`, `.update`, `.testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache`, `.bind`, `zO`, `Kouen Features`, `String`, `start.mjs`?**
  _High betweenness centrality (0.255) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `.cursorPos` to `ThemeFileServiceTests`, `SessionGroup`, `AgentSessionSummary`, `code:js (// ~/.config/harness/init.js)`, `.agentName`, `.id`, `TextGrid`, `RGBColor`, `CodingKeys`, `PerformanceBenchmarks`, `TerminalProtocolCompatibilityTests`, `Added`, `.firstWaitingTab`, `RGBColor`, `FrecencyDirectoryStore`?**
  _High betweenness centrality (0.210) - this node is a cross-community bridge._
- **Why does `fbt()` connect `callingPaneTarget` to `CodingKey`, `.applyPreedit`, `RGBColor`, `ReflowCorpusTests`?**
  _High betweenness centrality (0.108) - this node is a cross-community bridge._
- **Are the 19 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `OutputTriggerMatcher`) actually correct?**
  _`KouenTerminalSurfaceView` has 19 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _2405 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.006507512213107199 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.022160728698258966 - nodes in this community are weakly interconnected._