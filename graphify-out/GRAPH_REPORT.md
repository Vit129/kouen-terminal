# Graph Report - fix-history-discovery  (2026-11-03)

## Corpus Check
- 936 files · ~1,043,041 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 20001 nodes · 58129 edges · 2645 communities (1510 shown, 1135 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8887 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `60dcce1d`
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
1. `IPCRequest` - bridges 188 areas (208 edges)
2. `Command` - bridges 101 areas (108 edges)
3. `t()` - bridges 83 areas (253 edges)
4. `AgentKind` - bridges 82 areas (176 edges)
5. `IPCResponse` - bridges 76 areas (103 edges)
6. `KouenTerminalSurfaceView` - bridges 73 areas (345 edges)
7. `KouenPaths` - bridges 73 areas (150 edges)
8. `SessionCoordinator` - bridges 67 areas (235 edges)
9. `KouenGridTerminal` - bridges 67 areas (117 edges)
10. `NSView` - bridges 65 areas (193 edges)

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

## Communities (2645 total, 1135 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.01
Nodes (545): _0t(), _1n(), _2t(), _3e(), _5n(), _6e(), _6n(), _9e() (+537 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.01
Nodes (461): l, V, z(), _4n(), _5e(), _7n(), a9e(), a9n() (+453 more)

### Community 2 - ".handleNormal"
Cohesion: 0.03
Nodes (292): pe(), r, X(), A(), code(), R(), a(), aDt() (+284 more)

### Community 3 - "Changed"
Cohesion: 0.02
Nodes (150): a(), b(), c(), d(), e(), f(), g(), h() (+142 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.04
Nodes (32): NSEvent, Any, Bool, CGFloat, NSEvent, NSMenu, NSMenuItem, String (+24 more)

### Community 5 - "IPCRequest"
Cohesion: 0.02
Nodes (156): _1t(), _9n(), a0(), a0n(), a6n(), aat(), ag(), avn() (+148 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.14
Nodes (6): .feed(_:), .readGrid(scrollbackOffset:), ImageProtocolTests, String, ScrollbackTests, Character

### Community 7 - "Command"
Cohesion: 0.06
Nodes (31): TerminalModes, InputEncoder, .encode(_:modifiers:event:modes:), .encode(text:modifiers:modes:), .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release (+23 more)

### Community 8 - "LSPMessage"
Cohesion: 0.08
Nodes (12): .receive(_:), DispatchSemaphore, FluidityBenchmarks, NSWindow, String, UInt64, KouenTerminalSurfaceWorkerTests, Bool (+4 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.04
Nodes (95): _4e(), A1(), a4e(), aw(), awt(), b2(), bMt(), bw() (+87 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.08
Nodes (46): MTLClearColor, MTLCommandBuffer, MTLLibrary, MTLRenderCommandEncoder, MTLRenderPipelineState, Int, ImageTextureCache, MTLDevice (+38 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.15
Nodes (10): TerminalDamage, RenderColor, MetalRendererTests, RenderedFixture, Bool, MTLTexture, StaticString, String (+2 more)

### Community 12 - "Changed"
Cohesion: 0.07
Nodes (26): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, AutomationScheduler (+18 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.04
Nodes (68): AgentRow, .agentColor, .executables, .hookButton, .hookButtonTitle, SettingsAgentsView, .agentsSection, .notchSection (+60 more)

### Community 14 - "VTParser"
Cohesion: 0.13
Nodes (12): clamp(), Date, Never, T, Task, Void, TabPillView, .dragGesture (+4 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.09
Nodes (11): surfaceID, SessionEditor, .surfaceID(forPaneID:), Command, Tab, AgentSessionSummaryTests, SessionEditorPhase4Tests, PaneID (+3 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.26
Nodes (4): AgentTableEntry, Bool, Set, String

### Community 17 - "MetalRendererTests"
Cohesion: 0.09
Nodes (12): PanePipe, SurfaceMonitor, SurfaceRegistry, Bool, FileHandle, Int32, SessionID, Set (+4 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.07
Nodes (44): AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem, fetchGitStatus() (+36 more)

### Community 19 - "SpecialKey"
Cohesion: 0.08
Nodes (32): .saveRecordsBatch(_:), CachedSessionEntry, AgentHistoryScanner, .parseAntigravityTranscript(sessionID:fileURL:), .parseAntigravityTranscript(sessionID:fileURL:toIndex:), .parseClaudeTranscript(fileURL:), .parseCodexTranscript(fileURL:surfaceTag:ftsIndex:), .parseCodexTranscript(fileURL:surfaceTag:ftsIndex:toIndex:) (+24 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.07
Nodes (36): StyledSegment, ColorKind, .base, bg, fg, underline, ComposedCell, .asGridCell (+28 more)

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.05
Nodes (52): .init(entry:), AgentChipView, .init(frame:), .intrinsicContentSize, ChromeBackdrop, .init(role:), ChromeRole, sidebar (+44 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.06
Nodes (36): ArtifactKind, html, image, markdown, text, AutomationsFleetModel, .load(detectScheduledRuns:), AutomationSource (+28 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.15
Nodes (14): IndexingIterator, LayoutTemplate, Bool, Double, .addSurface(to:paneID:surfaceID:cwd:), .split(node:targetPaneID:direction:paneCount:before:), .split(node:targetPaneID:with:direction:beforeTarget:), .surfaceID(forPaneID:in:) (+6 more)

### Community 24 - ".request"
Cohesion: 0.06
Nodes (24): CornerInfo, EditorDividerView, KouenSplitView, .dividerColor, .dividerThickness, .init(coder:), PaneDragGripView, .init(coder:) (+16 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.10
Nodes (12): .agentColorBinding, colors, PerformanceBenchmarks, SurfaceMainThreadStallSample, Bool, Double, MTLDevice, MTLTexture (+4 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.08
Nodes (28): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, PaletteMode, errors (+20 more)

### Community 27 - "RGBColor"
Cohesion: 0.06
Nodes (41): .pairedAlreadyBanner, .pairingQRPanel, .sidebarEmptyView, .rootPicker, IssueKeychainStore, Bool, String, IssuePriority (+33 more)

### Community 28 - ".parse"
Cohesion: 0.15
Nodes (15): Notification.Name, ObserverToken, NSCoder, NSObjectProtocol, NSRect, NSTextView, URL, SyntaxDefinitionTarget (+7 more)

### Community 29 - "Added"
Cohesion: 0.08
Nodes (19): OSCTerminatorMatch, RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), ScrollbackEntry, ScrollbackReplaySegment, ShellLaunchProfile, .argv, Bool (+11 more)

### Community 30 - "Notification"
Cohesion: 0.17
Nodes (12): _8n(), a7e(), e3n(), fb(), m5e(), n8e(), obt(), qkn() (+4 more)

### Community 31 - "Sendable"
Cohesion: 0.05
Nodes (37): Bool, NSEvent, .body, MainActor, Void, SessionDividerRowView, .init(coder:), .init(frame:) (+29 more)

### Community 32 - ".addTab"
Cohesion: 0.13
Nodes (14): .exit, String, KouenCLI, SessionID, String, Bool, Int32, Never (+6 more)

### Community 33 - "Equatable"
Cohesion: 0.08
Nodes (27): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+19 more)

### Community 34 - "DaemonClient"
Cohesion: 0.09
Nodes (7): Bool, Command, DispatchWorkItem, PaneID, String, UInt8, WindowSession

### Community 35 - "MenuTarget"
Cohesion: 0.08
Nodes (23): DaemonClient, .start(onResponse:onEnd:), Int32, TimeInterval, UUID, Void, .onResponse, ClaudeCodeHarnessIPCTests (+15 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.07
Nodes (22): String, UInt16, Data, DecodedReplyFrame, output, reply, DecodedRequestFrame, input (+14 more)

### Community 37 - "String"
Cohesion: 0.09
Nodes (25): ClientRecord, CountBox, DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed (+17 more)

### Community 38 - "code:bash (swift build)"
Cohesion: 0.09
Nodes (7): KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), Bool, ISO8601DateFormatter, String, Tab, UUID

### Community 39 - "TerminalColorGamut"
Cohesion: 0.06
Nodes (29): Bool, String, UUID, TaskDaemonBridge, CGFloat, NSCoder, SessionID, String (+21 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.08
Nodes (16): DisplayWidth, String, Unicode, ReleaseNotes, Section, String, Run, String (+8 more)

### Community 41 - "CodingKeys"
Cohesion: 0.07
Nodes (13): SessionGroup, SessionID, String, KouenSidebarPanelViewController, NSMenuItem, SessionGroup, String, NSMenu (+5 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.07
Nodes (14): TerminalGridCell, HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor, Bool, ClosedRange (+6 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.08
Nodes (17): .event(_:), .interval(_:_:), StaticString, T, .testingPendingResize, PendingMainHop, PresentAttempt, encodeFailure (+9 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.05
Nodes (52): AS(), ast(), b3e(), ble(), bvt(), c6(), cc(), cV() (+44 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.08
Nodes (42): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+34 more)

### Community 46 - ".buildCommand"
Cohesion: 0.06
Nodes (35): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, SessionGroup, SessionID (+27 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.02
Nodes (144): a1t(), a8n(), Af(), agn(), agt(), aUe(), aV(), b2t() (+136 more)

### Community 48 - "HookEvent"
Cohesion: 0.13
Nodes (13): .addSurface(tabID:paneID:), .tab(containingPaneID:), .tab(for:), .tab(forSurfaceKey:), .tabIndex(surfaceKey:), .tabIndex(tabID:), .tabIndex(workspaceID:tabID:), Bool (+5 more)

### Community 49 - "DaemonServer"
Cohesion: 0.09
Nodes (13): AgentDetection, AgentDetector, MatchSource, ownProcess, wrapperLaunch, RawMatch, Date, Int32 (+5 more)

### Community 50 - "Added"
Cohesion: 0.16
Nodes (9): Process, SSHTunnelManager, .init(makeTunnelProcess:reachabilityProbe:), Bool, URL, Tunnel, SSHTunnelManagerTests, String (+1 more)

### Community 51 - ".keyEvent"
Cohesion: 0.15
Nodes (7): AnyCodable, JSONRPCError, Bool, Int32, Pipe, String, ToolRegistry

### Community 52 - "Fixed"
Cohesion: 0.05
Nodes (50): _3n(), aR(), bV(), c_n(), cKt(), cYt(), d4e(), DGt() (+42 more)

### Community 53 - "Added"
Cohesion: 0.10
Nodes (53): Ame(), aQt(), aXt(), Cqt(), CUe(), cXt(), DYt(), Eme() (+45 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.08
Nodes (24): .init(coder:), .init(coder:), Kind, primary, secondary, .init(coder:), KouenPillButton, .init(coder:) (+16 more)

### Community 55 - "TabCell"
Cohesion: 0.09
Nodes (30): Equatable, KouenGridTerminal, .currentSelectionRegion, ClosedRange, BlockSelection, CursorRender, CursorStyle, bar (+22 more)

### Community 56 - "NSPanel"
Cohesion: 0.12
Nodes (32): Encodable, ExpressibleByStringLiteral, AgyModelsPush, AISuggestionAck, AttachedAck, Body, BrowserFramePush, BrowserOkAck (+24 more)

### Community 57 - "BellScanState"
Cohesion: 0.09
Nodes (22): AppKit, KouenCopyMode, KouenTerminalEngine, KouenTerminalKit, KouenTerminalRenderer, KouenTheme, Metal, ImmersiveEffects (+14 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.08
Nodes (22): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+14 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.06
Nodes (35): Executor, Hook, HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane (+27 more)

### Community 60 - "ViEngine"
Cohesion: 0.08
Nodes (37): DaemonSubscription, .start(onData:onEnd:buffered:), Bool, UInt64, decodeBoundedCString(), ignoreSIGPIPE(), makeUnixStreamSocket(), setNoSigPipe() (+29 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.06
Nodes (33): keys, CGImage, ImageIO, data, DecodedImage, .byteCount, ImageLimits, Bool (+25 more)

### Community 62 - "ComposedCell"
Cohesion: 0.08
Nodes (24): DisplayLinkTarget, MainSplitViewController, .setSidebarVisible(_:), .setSidebarVisible(_:animated:), SplitChromeDelegate, .sidebarMaxWidth, .sidebarMinWidth, .splitView(_:constrainMaxCoordinate:ofSubviewAt:) (+16 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.09
Nodes (24): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary, RowKind (+16 more)

### Community 64 - ".text"
Cohesion: 0.12
Nodes (16): LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed, serverNotExecutable, AsyncStream, CheckedContinuation (+8 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.06
Nodes (39): KeybindingsService, Bool, Command, String, OptionSet, KeySpec, .description, .init(from:) (+31 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.08
Nodes (50): Codable, BrowserSnapshotAck, agentWaitChannel(), BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserRequestPayload (+42 more)

### Community 67 - "String"
Cohesion: 0.09
Nodes (10): KouenCLITests, DetachKeys, absent, invalid, parsed, Int32, String, Bool (+2 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.06
Nodes (21): PluginLoader, String, ScriptAPI, ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool (+13 more)

### Community 69 - ".compose"
Cohesion: 0.15
Nodes (11): GitRunner, GitResult, String, TimeInterval, URL, GitService, Bool, GitResult (+3 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.09
Nodes (23): OptionStore, OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Scope, global (+15 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.07
Nodes (19): Tab, BrowserIntegrationController, PaneID, HitTestPassthroughView, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), .init(paneID:), NSPoint (+11 more)

### Community 72 - "XCTestCase"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 73 - "README.md"
Cohesion: 0.06
Nodes (25): DaemonClientActor, TimeInterval, daemonError, DaemonSessionService, .endpoint, .request(_:timeout:), Bool, TimeInterval (+17 more)

### Community 74 - "[2.6.0] - 2026-06-13"
Cohesion: 0.13
Nodes (9): AgyMobileCommands, String, ClaudeMobileCommands, Set, String, slashCommandChunks(), String, MobileBridgeAgentCommandTests (+1 more)

### Community 75 - "OptionStore"
Cohesion: 0.10
Nodes (7): Bool, Range, Set, String, URLDetection, StringProtocol, EngineConformanceTests

### Community 76 - ".parse"
Cohesion: 0.09
Nodes (20): InputGate, .siblings, ReconnectLatch, .isTripped, SurfaceIO, .currentSubscription, Bool, CGFloat (+12 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.05
Nodes (45): MochaTheme, TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid (+37 more)

### Community 78 - "Added"
Cohesion: 0.15
Nodes (13): PaneDropZoneOverlay, .init(coder:), .init(targetPaneID:), NSCoder, NSPoint, NSRect, PaneID, Zone (+5 more)

### Community 79 - "HarnessDesign"
Cohesion: 0.09
Nodes (14): ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy, SessionLifecycleService, NSWindow (+6 more)

### Community 80 - "Agent handbook — Harness (extended reference)"
Cohesion: 0.09
Nodes (16): Group, ParsedShortcut, .displayString, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, PrefixKeymap, Any (+8 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.09
Nodes (27): .filteredJobs, MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith (+19 more)

### Community 82 - ".firstMatch"
Cohesion: 0.06
Nodes (12): NWEndpoint, Bool, NWListener, Sendable, String, UInt16, MobileBridgeServer, PipeBuffer (+4 more)

### Community 83 - "LSPClient"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.09
Nodes (26): KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:fileSearchRoots:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:), .scrollbackLines, ResizeOverlayMode, afterFirst, always, never (+18 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.08
Nodes (26): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+18 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.05
Nodes (26): item, .parseClaudeTranscript(fileURL:toIndex:), .readJSONLLines(from:fromOffset:), ClaudeSessionLocator, ClaudeTranscriptLine, Role, assistant, user (+18 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.08
Nodes (32): CGFloat, FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView (+24 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.18
Nodes (7): PaneBorderStatus, bottom, off, top, PaneRectSolver, PaneRectSolverTests, Bool

### Community 89 - ".cursorPos"
Cohesion: 0.13
Nodes (19): AgentHistoryFTSIndex, .deleteSession(sessionID:), .needsReindex(sessionID:mtime:fileSize:), .pruneMissingSessions(validTranscriptPaths:), .saveRecord(_:mtime:fileSize:), .search(query:limit:), .searchRanked(query:limit:includeSnippet:requireAllTokens:includeMetadata:matchingIDs:), .searchSubstring(query:includeEvidence:matchingIDs:) (+11 more)

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.08
Nodes (16): .effectiveResumeCommand(claudeMode:), LiveClaudeAgentEntry, .placement, ClaudeSessionMode, TimeoutFlag, .didFire, ClaudeCloudSessionStore, Entry (+8 more)

### Community 91 - "TerminalModes"
Cohesion: 0.10
Nodes (16): DesktopNotifier, .isUNNotificationCenterAvailable, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool, MainActor, String (+8 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.08
Nodes (24): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, .acceptsFirstResponder (+16 more)

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.10
Nodes (17): .body, .mcpButton, json, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter (+9 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.11
Nodes (19): GroupHeaderRow, .body, PickerItem, .groupLabel, historyBlock, .id, recipe, .searchableText (+11 more)

### Community 95 - "shim.c"
Cohesion: 0.12
Nodes (15): PendingVersionBanner, welcome, whatsNew, State, Bool, String, URL, VersionBannerStore (+7 more)

### Community 96 - "Harness Usage"
Cohesion: 0.15
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 97 - "PaneContainerView"
Cohesion: 0.26
Nodes (12): atomicWrite(), backupCorruptFile(), ensureDirectories(), fnv1aHex(), KouenPaths, Bool, String, T (+4 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.05
Nodes (14): KouenDaemonCore, DaemonBrowserRoutingTests, IPCCodecInvariantTests, String, URL, ConcurrentIndexSet, .count, EndpointClientTests (+6 more)

### Community 99 - ".dispatch"
Cohesion: 0.05
Nodes (38): Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions, Logical Design, P41 — Automations, Strategic Design, Tactical Design (+30 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.07
Nodes (18): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, PaneID, SurfaceID (+10 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.13
Nodes (7): KeybindingsStore, .fileURL, URL, KeybindingsStoreTests, URL, Void, String

### Community 102 - "DaemonLauncher"
Cohesion: 0.08
Nodes (18): NSScrollView, NSWindow, Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent (+10 more)

### Community 103 - "AnyCodable"
Cohesion: 0.11
Nodes (14): AsyncRunCoordinator, OutputBuffer, ProcessResult, .isSuccess, ProcessRunner, Bool, CheckedContinuation, DispatchWorkItem (+6 more)

### Community 104 - "Recipe"
Cohesion: 0.15
Nodes (4): hooks, AgentHookInstallerTests, String, URL

### Community 105 - "Changelog"
Cohesion: 0.18
Nodes (11): SwarmSpawnSpec, CallRecorder, .cancelCalls, .closeCalls, .harnessCalls, .surfaceCalls, SwarmWorkerManagerTests, Bool (+3 more)

### Community 106 - "domain-design.md"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.08
Nodes (6): CodepointRunFastPathTests, .assertAllPathsAgree(_:cols:rows:file:line:), StaticString, String, UInt, UInt8

### Community 108 - ".resolve"
Cohesion: 0.10
Nodes (20): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+12 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.11
Nodes (18): abn(), b1n(), bI(), c2t(), d2n(), dte(), G0(), gA() (+10 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.14
Nodes (18): CommandParseError, .description, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand (+10 more)

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.15
Nodes (13): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+5 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.15
Nodes (9): FormatContext, FormatString, FormatStyle, Bool, Character, Date, String, FormatStyledTests (+1 more)

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.11
Nodes (13): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, PaneID (+5 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.08
Nodes (12): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+4 more)

### Community 115 - ".encode"
Cohesion: 0.12
Nodes (17): FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID, FeatureTask (+9 more)

### Community 116 - "SessionGroup"
Cohesion: 0.07
Nodes (22): CodingKeys, error, id, jsonrpc, method, params, result, LSPMessage (+14 more)

### Community 117 - "PaneNode"
Cohesion: 0.09
Nodes (30): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+22 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.12
Nodes (13): SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, SessionID, String, SurfaceID (+5 more)

### Community 119 - "Harness command reference"
Cohesion: 0.08
Nodes (26): FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body, .emptyState (+18 more)

### Community 120 - "Added"
Cohesion: 0.23
Nodes (8): NaturalLanguage, AgentHistorySearch, Hit, IDFCache, Bool, Double, String, .tokenHits(_:inNormalized:)

### Community 121 - "Changed"
Cohesion: 0.14
Nodes (14): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+6 more)

### Community 122 - "ViEngine"
Cohesion: 0.17
Nodes (8): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, String, PaneStyleTests

### Community 124 - "String"
Cohesion: 0.05
Nodes (48): AnyTransition, AnyView, Color, .hexString, AgentNotchPeekEvent, AgentNotchRootView, .body, .bottomRadius (+40 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.11
Nodes (11): BrowserPaneView, DesignModeElementInfo, Any, DispatchWorkItem, NSPopover, ObjectIdentifier, Selector, String (+3 more)

### Community 126 - ".path"
Cohesion: 0.12
Nodes (12): .webView(_:didCommit:), WKWebViewConfiguration, BrowserPaneViewTests, MockWebView, .isLoading, .title, .url, Bool (+4 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.13
Nodes (10): ScrollbackFile, .highWater, Bool, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.14
Nodes (8): MutationResult, RemoteHost, RemoteHostStore, Bool, String, RemoteHostStoreTests, String, URL

### Community 129 - "SwiftUI"
Cohesion: 0.08
Nodes (7): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess, DaemonReconnectPolicy, OutputCoalescer, Void, DaemonReconnectPolicyTests

### Community 130 - "Harness"
Cohesion: 0.16
Nodes (14): ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool, Command (+6 more)

### Community 131 - ".install"
Cohesion: 0.10
Nodes (15): FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect, String, URL (+7 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.09
Nodes (14): DiffLineType, added, deleted, modified, Bool, NSEvent, NSPopover, NSRange (+6 more)

### Community 133 - ".load"
Cohesion: 0.06
Nodes (45): Configuration, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, ButtonStyle, CommandRow, .body, GlassCard, .body (+37 more)

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.26
Nodes (4): Darwin, Foundation, Glibc, AgentRoutingResolver

### Community 135 - "CommandTarget"
Cohesion: 0.06
Nodes (27): Codex → Kouen, One-line install, What you'll see, Cursor Agent → Kouen, Manual fallback, One-line install, What you'll see, Grok Build → Kouen (+19 more)

### Community 136 - ".startWatching"
Cohesion: 0.08
Nodes (25): CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display, found, .isReady (+17 more)

### Community 137 - "ActivePaneService"
Cohesion: 0.12
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.10
Nodes (31): a6(), aJ(), bXt(), cJ(), dqt(), Dr(), dXt(), F0() (+23 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.08
Nodes (13): Bool, String, UInt8, UnsafeBufferPointer, TerminalEmulator, .captureLines(joinWrapped:), .onSetClipboard, Case (+5 more)

### Community 140 - "Added"
Cohesion: 0.13
Nodes (3): ContentAreaViewController, Bool, TabID

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.09
Nodes (15): DataBox, GitPanelView, .isHidden, .removeWorktreeAction(path:), GitResult, Bool, DispatchWorkItem, GitResult (+7 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.08
Nodes (16): NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent, NSImage (+8 more)

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.10
Nodes (14): AgentNotchViewModel, Bool, CGFloat, Duration, NotchPanel, .canBecomeKey, .canBecomeMain, Bool (+6 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.10
Nodes (18): Bool, AgentSessionHistoryView, .body, .footerView, .subHeaderView, HistoryMenuProxy, Any, Bool (+10 more)

### Community 145 - "AsciiFastPathTests"
Cohesion: 0.11
Nodes (18): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerModel, DirectoryPickerView, .body (+10 more)

### Community 146 - "DecodedImage"
Cohesion: 0.09
Nodes (23): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+15 more)

### Community 147 - "FileTreeWatcher"
Cohesion: 0.09
Nodes (23): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, IssueInfo (+15 more)

### Community 148 - "TriState"
Cohesion: 0.10
Nodes (12): NSRangePointer, Any, NSAttributedString, NSRange, NSRect, String, UInt64, CellOverlayTests (+4 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.11
Nodes (13): FileFuzzyMatcher, FileSearchRootScanner, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool (+5 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.12
Nodes (10): MarkdownPreviewView, .webView(_:decidePolicyFor:decisionHandler:), Bool, MainActor, Sendable, String, URL, WKNavigationAction (+2 more)

### Community 151 - ".evaluate"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, S (+2 more)

### Community 152 - "Added"
Cohesion: 0.16
Nodes (10): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab, UUID (+2 more)

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 154 - "LiveResizeTests"
Cohesion: 0.13
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 155 - "Int"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.17
Nodes (31): aQ(), bme(), bqt(), bYt(), cbe(), DD(), Eqt(), Fa() (+23 more)

### Community 157 - "Added"
Cohesion: 0.12
Nodes (15): SavedLayoutStore, Bool, String, URL, UUID, PaneLayoutShape, branch, leaf (+7 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.08
Nodes (25): KouenChromePalette, Bool, CGFloat, NSColor, String, Coordinator, DiffAnalysis, DiffFileItem (+17 more)

### Community 159 - "MatchCategory"
Cohesion: 0.22
Nodes (5): Bool, Character, NSRange, NSTextView, String

### Community 160 - "AmbientBackground"
Cohesion: 0.11
Nodes (15): StatusLineView, .init(coder:), Bool, CGFloat, Never, NSAttributedString, NSCoder, NSColor (+7 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.12
Nodes (13): .init(url:paneID:), .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), NSRect, NSStackView, URL, WKNavigationAction, WKWebView (+5 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.15
Nodes (8): BoardViewController, .isVisible, FlippedView, .isFlipped, Bool, Set, TabID, BoardViewControllerTests

### Community 163 - "Workspace"
Cohesion: 0.10
Nodes (11): CKouenSys, pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal (+3 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.40
Nodes (3): Bool, CAMetalDrawable, String

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.14
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 166 - "LiveSession"
Cohesion: 0.09
Nodes (22): AYt(), bGt(), Cme(), e7e(), EUe(), eYt(), hxn(), IUe() (+14 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.14
Nodes (10): ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID, String, SurfaceID (+2 more)

### Community 168 - "Added"
Cohesion: 0.11
Nodes (15): ImagePlacementSnapshot, SemanticMark, Bool, TerminalCellWidth, normal, spacerTail, wide, TerminalCursor (+7 more)

### Community 169 - "Fixed"
Cohesion: 0.09
Nodes (7): Divergence, Bool, String, TimeInterval, WorktreeInfo, String, WorktreeIsolationTests

### Community 170 - "URLDetection"
Cohesion: 0.13
Nodes (11): FilePreviewCoordinator, FileTabID, Set, String, FileTab, .title, FileTabManager, .hasOpenTabs (+3 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.23
Nodes (8): KouenChrome, PaletteFooter, .body, .body, AttributedString, NSColor, DirectoryPickerFooter, .body

### Community 172 - ".decodeKeySpec"
Cohesion: 0.13
Nodes (13): MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem, SessionGroup (+5 more)

### Community 173 - "BoardCard"
Cohesion: 0.08
Nodes (15): ContextResolutionEngine, Bool, String, Bool, String, TokenGuard, EnvironmentStore, Persisted (+7 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.16
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 175 - "RGBColorTests"
Cohesion: 0.13
Nodes (16): OnboardingStep, complete, discover, .id, setup, shell, .title, welcome (+8 more)

### Community 176 - "Added"
Cohesion: 0.14
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 177 - ".rects"
Cohesion: 0.11
Nodes (18): aie(), arc(), closePath(), cRe(), cZ(), E7(), frn, hD() (+10 more)

### Community 178 - "InlineAICompletionView"
Cohesion: 0.09
Nodes (28): a6e(), aae(), bX(), c8e(), Cf(), cxn(), eL(), ele() (+20 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.15
Nodes (5): .snapshot, Bool, String, ThemeService, KouenOptions

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.13
Nodes (18): NSEvent, WorktreeCardView, FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:) (+10 more)

### Community 181 - "GridCompositorTests"
Cohesion: 0.15
Nodes (16): ClaudeCodeHarness, Profile, edit, readonly, Run, RunState, cancelled, failed (+8 more)

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.12
Nodes (30): br(), checkbox(), codespan(), constructor(), de(), del(), em(), html() (+22 more)

### Community 183 - "LSPServerRegistry"
Cohesion: 0.16
Nodes (9): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+1 more)

### Community 184 - "targets"
Cohesion: 0.10
Nodes (13): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+5 more)

### Community 185 - "SessionSnapshot"
Cohesion: 0.13
Nodes (12): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+4 more)

### Community 186 - "Error"
Cohesion: 0.12
Nodes (24): .color, BoardCard, BoardColumn, .name, BoardColumnKind, .displayName, done, error (+16 more)

### Community 187 - "AppDelegate"
Cohesion: 0.13
Nodes (10): .effectiveResumeCommand(mode:), AgentLaunchCommands, AgentSessionMode, cloud, .launchCommand, .launchFlags, local, remoteControl (+2 more)

### Community 188 - "BrowserPaneView"
Cohesion: 0.21
Nodes (5): CopyModeReducerTests, FakeGrid, .totalLines, Set, String

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.12
Nodes (10): .readJSONLLines(from:), AntigravitySessionLocator, AntigravityTranscriptLine, Bool, Int32, NSRegularExpression, String, URL (+2 more)

### Community 190 - "user-stories.md"
Cohesion: 0.25
Nodes (5): .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:surfaceTag:topicSegments:), AgentHistorySearchTests, String, TimeInterval, URL

### Community 191 - "ScriptRuntime"
Cohesion: 0.24
Nodes (3): StatusLineWidthTests, StatusLineWidth, String

### Community 192 - "GlyphRasterizer"
Cohesion: 0.23
Nodes (3): CSIParams, .count, UInt8

### Community 193 - "BinaryInstaller"
Cohesion: 0.14
Nodes (28): Cleanup Test Repo, Close Isolated Session Keeps Dirty Worktree, Close Isolated Session Removes Clean Worktree, Close One Isolated Does Not Affect Another, Close Session With Split Panes Removes Worktree, Create Isolated Session, Create Isolated Session Via CLI, Get Active Pane (+20 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.19
Nodes (11): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, .selectedHost (+3 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.27
Nodes (4): HintModeOverlay, Any, NSEvent, String

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.11
Nodes (12): Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint, NSRect, String (+4 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.11
Nodes (20): Motion, .entrance, .spring, .standardEase, CAMediaTimingFunction, NSWindowController, KouenOnboarding, Bool (+12 more)

### Community 198 - ".classify"
Cohesion: 0.07
Nodes (28): Additional `kouen-cli` subcommands, Agent safety CLI (`kouen-cli`), Agents, context and scratchpad, Attaching from a plain terminal, Bindings, Board and attention, Buffers (paste store), Composition (+20 more)

### Community 199 - "code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)"
Cohesion: 0.12
Nodes (12): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, input (+4 more)

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.21
Nodes (4): CommandTarget, String, UUID, TargetSpecTests

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.22
Nodes (10): CopyModeGridSource, .promptRows, ClosedRange, CopyModeReducer, Bool, Character, NSRegularExpression, Range (+2 more)

### Community 202 - "PaletteModel"
Cohesion: 0.21
Nodes (8): StartupMetrics, .logURL, Bool, Double, UInt64, URL, StartupMetricsTests, UInt64

### Community 203 - "Harness keybindings"
Cohesion: 0.14
Nodes (13): AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID, .snapshotPayload, NotificationBus (+5 more)

### Community 204 - "From tmux"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 205 - "CopyModeState"
Cohesion: 0.15
Nodes (15): .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:), .init(frame:) (+7 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.15
Nodes (9): NSEvent, NSHostingView, NSLayoutConstraint, TerminalTabBarView, .delegate, .init(frame:), .leadingInset, .mouseDownCanMoveWindow (+1 more)

### Community 207 - "scheduleRender"
Cohesion: 0.09
Nodes (16): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController, CheckpointInfo (+8 more)

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.13
Nodes (6): TimeInterval, AgentHandoffBuilder, Bool, String, HandoffDirectoryTests, AgentHandoffBuilderTests

### Community 209 - "SettingsRemoteView"
Cohesion: 0.11
Nodes (15): DispatchWorkItem, CompletionPopupView, .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:), .isHovered (+7 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.10
Nodes (23): CoreGraphics, CoreText, Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:) (+15 more)

### Community 211 - "PaneTarget"
Cohesion: 0.11
Nodes (11): KouenCommands, KouenCompositor, DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat (+3 more)

### Community 212 - ".translate"
Cohesion: 0.16
Nodes (8): DaemonLifecycle, Bool, pid_t, String, URL, removePIDFile(), DaemonLifecycleTests, URL

### Community 213 - "String"
Cohesion: 0.19
Nodes (3): fQ, hqe(), M9()

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.09
Nodes (22): CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16, UInt8, BoxDrawing (+14 more)

### Community 215 - ".lines"
Cohesion: 0.09
Nodes (30): eJ(), fme(), fwn(), gKt(), gUe(), $He(), kGt(), LC() (+22 more)

### Community 216 - "CellColorResolverTests"
Cohesion: 0.14
Nodes (6): BrowserLeaf, URL, DaemonSyncServiceBrowserPaneMergeTests, PaneID, PaneNodeBrowserTests, PaneNodeLayoutShapeTests

### Community 217 - "GridCompositor"
Cohesion: 0.13
Nodes (13): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+5 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.16
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 219 - "Prompt"
Cohesion: 0.16
Nodes (6): LSPTextLocation, .position, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 220 - "Section"
Cohesion: 0.14
Nodes (15): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+7 more)

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.19
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.14
Nodes (23): Colors, Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors (+15 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.13
Nodes (11): PaneRect, PaneID, SurfaceID, SGRMouse, SGRMouseEvent, Bool, UInt8, SGRMouseTests (+3 more)

### Community 224 - "CellColorResolver"
Cohesion: 0.16
Nodes (3): KouenSettingsTests, URL, Void

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.18
Nodes (11): Typography, .badge, .kbd, .paletteHeader, .paletteTitle, .rowMeta, .rowTitle, .sectionLabel (+3 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.15
Nodes (16): AgentMark, .body, AgentMarkShape, Scanner, .atEnd, SVGPath, Bool, CGFloat (+8 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.14
Nodes (8): dC(), H7(), mXt(), R0, vD(), vXt(), WBt(), YBt()

### Community 228 - "sessionRow"
Cohesion: 0.16
Nodes (4): l8e(), $Rt(), tJe(), YUt

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.17
Nodes (9): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ProcessInfo (+1 more)

### Community 231 - "ExternalOpenKind"
Cohesion: 0.08
Nodes (7): PromptQueue, String, SurfaceID, Void, Float, PromptQueueBar, NSWindow

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.21
Nodes (9): Bool, CGFloat, Character, NSEvent, NSRange, NSString, NSTextView, String (+1 more)

### Community 233 - "TextGrid"
Cohesion: 0.26
Nodes (6): Bool, NSRange, NSString, NSTextView, String, unichar

### Community 234 - ".scan"
Cohesion: 0.19
Nodes (9): BranchSwitchHelper, FileTreeNode, FileTreeSwiftUIView, .body, .pastedImagesSection, Notification.Name, Bool, NSMenuItem (+1 more)

### Community 235 - "WorkbenchCommand"
Cohesion: 0.08
Nodes (13): NSCursor, TerminalColorRole, background, cursor, foreground, palette, NSPasteboard, URL (+5 more)

### Community 236 - "Added"
Cohesion: 0.17
Nodes (11): NotchGeometry, .fallback, NSScreen, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics (+3 more)

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.13
Nodes (16): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, .bytesPerWakeup, .mbps (+8 more)

### Community 238 - ".make"
Cohesion: 0.11
Nodes (16): CodingKeys, error, id, jsonrpc, method, JSONRPCId, int, string (+8 more)

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.33
Nodes (3): TaskStore, URL, TaskStoreTests

### Community 240 - "PaneBorderStatus"
Cohesion: 0.13
Nodes (12): DetachedPaneOverlay, .init(coder:), .init(frame:style:), Style, detached, reconnectingChip, NSCoder, NSEvent (+4 more)

### Community 241 - "Added"
Cohesion: 0.16
Nodes (3): CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 242 - "AgentBridge"
Cohesion: 0.24
Nodes (7): BinaryInstaller, .bundledMacOSDir, Bool, TimeInterval, BinaryInstallerVersionTests, String, URL

### Community 243 - ".make"
Cohesion: 0.13
Nodes (9): NSDraggingInfo, NSDragOperation, PasteController, Bool, NSPasteboard, String, TimeInterval, URL (+1 more)

### Community 244 - "FileNode"
Cohesion: 0.18
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.05
Nodes (21): AgentListFormatter, Date, String, dvn(), ht(), Range, String, TerminalBufferMatch (+13 more)

### Community 246 - "Experience modes"
Cohesion: 0.16
Nodes (12): UInt16, TTYSize, RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal (+4 more)

### Community 247 - ".renderFixture"
Cohesion: 0.14
Nodes (12): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+4 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.16
Nodes (12): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+4 more)

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.10
Nodes (9): String, WorkspaceID, CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab, DaemonSyncServiceBranchNotifyTests (+1 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 251 - "SessionCoordinator"
Cohesion: 0.13
Nodes (15): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+7 more)

### Community 252 - "NSViewRepresentable"
Cohesion: 0.06
Nodes (42): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, .init(from:), .init(id:name:baseURL:modelID:), ModelProvider (+34 more)

### Community 253 - "Split Right"
Cohesion: 0.16
Nodes (10): Logger, OSSignposter, LatencyMonitor, UInt64, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter (+2 more)

### Community 254 - "BoardViewController"
Cohesion: 0.15
Nodes (19): .modifierFlags, NSEvent, BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, CodingKeys (+11 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.08
Nodes (24): Font, .kouenBadge, .kouenBody, .kouenBodyStrong, .kouenCaption2, .kouenCaption, .kouenKbd, .kouenMono (+16 more)

### Community 256 - "GitMetadataProvider"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 258 - "WindowTitleStripView"
Cohesion: 0.16
Nodes (10): String, AgentRoutingRule, Kind, path, stack, Bool, Date, UUID (+2 more)

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.22
Nodes (7): AgentRoutingRuleStore, Bool, String, URL, UUID, AgentRoutingRuleStoreTests, URL

### Community 260 - ".welcome"
Cohesion: 0.27
Nodes (6): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 262 - ".install"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.11
Nodes (14): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+6 more)

### Community 265 - "code:bash (harness-cli install-hooks cursor)"
Cohesion: 0.18
Nodes (9): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+1 more)

### Community 266 - ".path"
Cohesion: 0.18
Nodes (6): .onCurrentCWD, .onCurrentFile, Bool, NSString, NSTextView, String

### Community 267 - ".performInstall"
Cohesion: 0.09
Nodes (18): AgentHistoryDateGroup, older, .sortOrder, thisWeek, today, yesterday, CaseIterable, LayoutTemplate (+10 more)

### Community 268 - "code:bash (# Old (agent-specific):)"
Cohesion: 0.17
Nodes (21): Decodable, Item, ItemCompletedLine, LegacyMsgLine, Msg, String, ThreadStartedLine, AgentCommandRequest (+13 more)

### Community 269 - "DefaultTerminalManager"
Cohesion: 0.16
Nodes (11): tool, KouenDaemonToolsTests, String, URL, Document, Bool, Set, String (+3 more)

### Community 270 - "WindowSession"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 271 - "StatusLineView.swift"
Cohesion: 0.13
Nodes (14): .lspPosition(for:), LSPDiagnostic, LSPDiagnosticSeverity, error, hint, information, warning, LSPHover (+6 more)

### Community 272 - "SGRMouseEvent"
Cohesion: 0.05
Nodes (13): azt(), B0, BBe(), F7, Fze, ibe(), mathmlBuilder(), O7 (+5 more)

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.09
Nodes (25): bNt(), bu(), cNt(), dNt(), eNt(), eRe(), fNt(), h0t() (+17 more)

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.17
Nodes (10): .block(atPromptLine:), .captureLines(fromLine:toLine:), .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8 (+2 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.27
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 277 - ".run"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.18
Nodes (20): CoreImage, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription, .surfaceID, detectHost() (+12 more)

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.20
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.14
Nodes (12): FileTreeContext, Bool, NSDraggingInfo, NSDragOperation, NSHostingView, SessionID, String, Void (+4 more)

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.18
Nodes (9): NodeRow, .body, .isFocused, .parentDirectory, Error, Never, String, Task (+1 more)

### Community 283 - "FormatColor"
Cohesion: 0.19
Nodes (13): ProjectGroupWatcher, StreamBox, Bool, DispatchQueue, escaping, FSEventStreamRef, MainActor, Never (+5 more)

### Community 284 - "click_ui_element"
Cohesion: 0.21
Nodes (13): CellMetrics, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth, Bool (+5 more)

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.15
Nodes (18): Cjt(), H2e(), hR(), jX(), Kje(), KX(), lR(), N$e() (+10 more)

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.16
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 287 - ".apply"
Cohesion: 0.20
Nodes (7): PaneDragController, .isDragging, Any, Bool, NSEvent, NSWindow, PaneID

### Community 288 - "AgentHookStrategy"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 289 - "StatusLineWidthTests"
Cohesion: 0.17
Nodes (5): SessionID, GroupedSessionTests, SessionGroup, Set, SurfaceID

### Community 290 - "Process"
Cohesion: 0.13
Nodes (17): FormatContextBuilder, DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:) (+9 more)

### Community 291 - "JSONDecoder"
Cohesion: 0.28
Nodes (7): Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 292 - "Release runbook"
Cohesion: 0.18
Nodes (4): ezt(), GGe, Hzt(), urn

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Kouen, Sparkle (+13 more)

### Community 294 - "GitHubCLIClient"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 296 - "NotificationBus"
Cohesion: 0.06
Nodes (28): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+20 more)

### Community 297 - "settings.json"
Cohesion: 0.18
Nodes (11): Never, NSRegularExpression, Set, String, Task, URL, Void, WorkspaceSymbolIndex (+3 more)

### Community 298 - "jobs"
Cohesion: 0.16
Nodes (8): CustomEndpointTester, Result, Bool, String, URL, CustomEndpointTesterTests, URLRequest, URLSession

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.17
Nodes (5): TabID, WorkspaceID, AgentCommandTests, String, Tab

### Community 301 - ".parse"
Cohesion: 0.13
Nodes (10): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, String (+2 more)

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.17
Nodes (16): SessionRef, byID, byName, next, previous, String, UUID, TargetSpec (+8 more)

### Community 303 - ".encodeMouse"
Cohesion: 0.07
Nodes (24): AgentSessionHistoryModel, .extraRecordsShown, .filteredRecords, .records, .searchQuery, .selectedAgents, .selectedIndex, .selectedScope (+16 more)

### Community 304 - "00-inception-plan.md"
Cohesion: 0.18
Nodes (13): Array, Bool, Date, Decoder, PaneID, String, TabID, Tab (+5 more)

### Community 305 - ".script"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.12
Nodes (6): ScreenPos, bottom, middle, top, KouenLSP, QuickLookUI

### Community 307 - "ViPathTokenTests"
Cohesion: 0.16
Nodes (8): _7(), A7(), a8(), c8(), ene(), Gnn, IC(), o8()

### Community 308 - "Send Ex Command"
Cohesion: 0.14
Nodes (10): apn(), brn, grn, hrn(), JGe(), KGe(), prn(), qGe() (+2 more)

### Community 309 - "Browser DevTools API (P28)"
Cohesion: 0.15
Nodes (5): SQLite3, AgentHistoryMultiAgentCoverageTests, Bool, String, URL

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.28
Nodes (7): SSETransport, .isRunning, .listener, Bool, NWConnection, String, UInt16

### Community 312 - "AgentSnapshot"
Cohesion: 0.15
Nodes (12): Configuration, Int32, SessionGroup, SessionID, Tab, TabID, WorkspaceID, TabSelector (+4 more)

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.17
Nodes (7): AIProviderAwakeService, .closedLidOptedIn, Bool, NSObjectProtocol, Set, String, AIProviderAwakeServiceTests

### Community 315 - "code:bash (harness-cli install-hooks grok)"
Cohesion: 0.22
Nodes (5): Keyboard Shortcuts, AI Browser Control (kouen-mcp), Install, Shell integration (OSC 133 semantic prompts), What gets emitted

### Community 316 - "code:bash (harness-cli install-hooks opencode)"
Cohesion: 0.25
Nodes (4): PortableRelativeDateFormatter, Date, String, UUID

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.16
Nodes (15): dhn(), en(), fhn(), ghn(), gk(), GOt(), jUe(), kr() (+7 more)

### Community 319 - "FormatColor"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.18
Nodes (3): ShellIntegrationTests, .repoRoot, URL

### Community 321 - "UInt64"
Cohesion: 0.23
Nodes (5): WorktreeManager, String, URL, UUID, WorktreeIsolationDaemonTests

### Community 322 - "DesktopNotifier"
Cohesion: 0.13
Nodes (14): BinaryInstaller.DetectionStatus, SetupStepView, .body, .canInstall, .hooksDetail, .hooksTone, .hooksValue, .isSuccess (+6 more)

### Community 323 - "LayoutNode"
Cohesion: 0.33
Nodes (6): SurfaceProgressTracker, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.21
Nodes (7): StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength, newline, StdioTransport, AsyncStream

### Community 325 - "FloatingPaneController"
Cohesion: 0.10
Nodes (3): Bool, String, UUID

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 328 - "README.md"
Cohesion: 0.10
Nodes (7): AsciiFastPathTests, StaticString, String, UInt, ReflowPreviewTests, .feeds, String

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.23
Nodes (8): SettingsAdvancedView, .body, Bool, String, SettingsFileSearchSection, .body, String, SwiftUI

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.08
Nodes (23): BrowserPaneRegistry, .init(coder:), BrowserProgressLine, .init(coder:), .init(frame:), BrowserTabButton, .init(coder:), .init(title:isActive:onSelect:onClose:) (+15 more)

### Community 332 - "Added"
Cohesion: 0.12
Nodes (8): OnboardingController, KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, BinaryInstallerDisplayTests, OnboardingEnvironmentTests

### Community 333 - "RealPty"
Cohesion: 0.15
Nodes (11): SwarmFleetBody, .body, SwarmFleetView, .init(coder:), SwarmNodeRowView, .body, .statusColor, CGFloat (+3 more)

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 335 - ".makeModel"
Cohesion: 0.06
Nodes (19): Action, KouenPathDisplay, HookState, failed, idle, installed, installing, Bool (+11 more)

### Community 336 - "run.sh"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 337 - "CommandExecutionError"
Cohesion: 0.15
Nodes (9): Bool, Int32, String, URL, SystemdUserInstaller, .backendName, .isInstalled, .unitURL (+1 more)

### Community 338 - "CSIParams"
Cohesion: 0.16
Nodes (16): SwarmFleetSnapshot, SwarmLane, pty, structured, SwarmTaskNode, SwarmTaskStatus, cancelled, failed (+8 more)

### Community 339 - "Foundation"
Cohesion: 0.15
Nodes (9): bUt(), FBe(), Gbe(), handler(), mUt(), _Q(), s0n(), wHt() (+1 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.16
Nodes (4): KouenThemeCatalog, .allThemes, String, KouenThemeCatalogTests

### Community 342 - "Added"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.13
Nodes (17): FileNode, GitStatusType, added, deleted, modified, renamed, unmodified, untracked (+9 more)

### Community 344 - "FileViewerViewController"
Cohesion: 0.07
Nodes (18): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, Set, SurfaceID, Tab (+10 more)

### Community 345 - "README.md"
Cohesion: 0.10
Nodes (15): .agentInfo(forWorktreePath:), .agentInfo(forWorktreePath:tabs:), Tab, Bool, Date, String, UUID, AgentActivity (+7 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.27
Nodes (3): TabID, WorkspaceID, GitPanelViewWorktreeNavigationTests

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.19
Nodes (10): .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didFinish:), .webView(_:didStartProvisionalNavigation:), LoadCompletionState, Bool, CheckedContinuation, Double (+2 more)

### Community 348 - "DaemonLifecycleTests"
Cohesion: 0.17
Nodes (8): Bool, CGFloat, NSCoder, Void, TabNavigation, TabNavigationButtons, .init(coder:), NSStackView

### Community 349 - "Contents.json"
Cohesion: 0.12
Nodes (10): MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, String, SurfaceID (+2 more)

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.40
Nodes (9): attribute_lines(), main(), redraw_frames(), repeated_chunk(), run_case(), sgr_lines(), truecolor_gradient(), unicode_lines() (+1 more)

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.23
Nodes (8): LSPFileSession, Never, String, Task, URL, Void, object, Bool

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.19
Nodes (9): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+1 more)

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.19
Nodes (13): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Bool, Duration (+5 more)

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.25
Nodes (8): FeaturePhase, architect, completed, dev, interview, qaDesign, qaVerify, .title

### Community 355 - ".deepMerge"
Cohesion: 0.15
Nodes (13): CodingKey, CodingKeys, createdAt, cwd, done, id, sessionID, status (+5 more)

### Community 357 - ".handleCat"
Cohesion: 0.16
Nodes (9): FileGraphInfo, GraphifyLSPBridge, Double, String, URL, GraphifyLSPBridgeTests, Any, String (+1 more)

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.11
Nodes (15): ExperienceMode, agent, .displayName, .foregroundsAgents, full, .notchEnabledByDefault, persistent, .persistsSessionsByDefault (+7 more)

### Community 360 - "State"
Cohesion: 0.22
Nodes (6): ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 362 - "RGBColor"
Cohesion: 0.18
Nodes (9): BrowserTabRepaintTests, RepaintCountingWebView, Any, Error, MainActor, Sendable, String, TimeInterval (+1 more)

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.18
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.27
Nodes (6): PaneOutputWaiter, PaneOutputWaitResult, SpawnedAgentSurface, CheckedContinuation, Never, UInt64

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.17
Nodes (9): GitStatusProvider, OnceResume, Bool, Duration, String, TimeInterval, GitStatusProviderLargeOutputTests, URL (+1 more)

### Community 366 - "Consumers"
Cohesion: 0.21
Nodes (4): Bool, String, SurfaceID, TimeInterval

### Community 367 - "DaemonStats"
Cohesion: 0.19
Nodes (9): NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView, .cornerConfiguration (+1 more)

### Community 368 - "Tab"
Cohesion: 0.09
Nodes (19): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+11 more)

### Community 369 - "Git Panel"
Cohesion: 0.31
Nodes (6): Bool, Counter, Scheduled, SurfaceProgressTrackerTests, DispatchWorkItem, TimeInterval

### Community 370 - ".encode"
Cohesion: 0.12
Nodes (20): AgentBadgeView, .body, Bool, CGFloat, AgentIconRenderer, Scanner, .atEnd, SVGPathParser (+12 more)

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.21
Nodes (8): Container, .init(coder:), .init(frame:), NotchPulseHost, Context, NSCoder, NSHostingView, NSRect

### Community 374 - ".run"
Cohesion: 0.12
Nodes (5): KouenCLI, HistorySearchQueryTests, MemoCommandTests, URL, TaskCommandTests

### Community 376 - "ScrollReuseTests"
Cohesion: 0.18
Nodes (6): KeyTokenParser, Bool, String, .remaining, KeyTokenParserTests, Phase6KeysTests

### Community 377 - "Identifiable"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.20
Nodes (4): CompletionGenerator, String, .fishCompletionSource, CompletionGeneratorTests

### Community 379 - "MCPServer"
Cohesion: 0.18
Nodes (10): AssistantLine, ClaudeAdapter, Content, Message, ResultLine, Bool, Double, String (+2 more)

### Community 380 - "PromptQueue"
Cohesion: 0.18
Nodes (8): ClaudeRunSummary, Date, Double, Int32, String, UUID, String, UUID

### Community 381 - "smoke-dmg.sh"
Cohesion: 0.29
Nodes (4): SwarmDAGStore, String, UUID, SwarmDAGStoreTests

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.20
Nodes (13): ern(), G4(), G7(), Jnn(), nrn(), Qnn(), sHe(), trn() (+5 more)

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.18
Nodes (7): DragDiagnostics, DispatchSourceTimer, String, AgentRemoteControlDaemonService, Set, String, Void

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.26
Nodes (3): String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 385 - "INDEX.md"
Cohesion: 0.27
Nodes (4): ArchitectureGuardTests, .repoRoot, String, URL

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.13
Nodes (3): AgentLaunchCommandsTests, URL, Void

### Community 387 - "User Profile"
Cohesion: 0.19
Nodes (18): Close Pane, Close Tab, Split Down, Split Right, Cmd Shift W Force Closes Tab, Cmd T Creates New Session, Cmd W Closes Pane When Split, Cmd W Closes Tab When Single Pane (+10 more)

### Community 389 - "HarnessCLITests"
Cohesion: 0.18
Nodes (8): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.17
Nodes (3): ProjectConfig, Bool, String

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.18
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 392 - "build-release.sh"
Cohesion: 0.17
Nodes (4): GitAheadBehind, GitParsers, String, GitParsersTests

### Community 393 - "create-dmg.sh"
Cohesion: 0.19
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 394 - "finalize-release.sh"
Cohesion: 0.30
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 395 - "generate-app-icon.sh"
Cohesion: 0.12
Nodes (15): agy, claude, codex, copilot, hermes, kouen, __kouen_agy_next, __kouen_claude_next (+7 more)

### Community 396 - "generate-appcast.sh"
Cohesion: 0.19
Nodes (10): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+2 more)

### Community 397 - "measure-fluidity.sh"
Cohesion: 0.25
Nodes (8): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String

### Community 398 - "preview.sh"
Cohesion: 0.21
Nodes (3): .hasAdapter(for:), Bool, ClaudeCodeHarnessTests

### Community 399 - "sign-and-notarize.sh"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 400 - "install-linux.sh"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 401 - "package-app.sh"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 402 - "View"
Cohesion: 0.18
Nodes (8): BrowserFileReloadTests, CountingWebView, Nav, NSEvent, String, Void, WKNavigation, WKNavigationDelegate

### Community 403 - "PresentAttempt"
Cohesion: 0.34
Nodes (8): CGFloat, Range, Tab, TabBarLayoutMetrics, .pitch, TerminalTabBarBody, .body, TerminalTabBarModel

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.12
Nodes (9): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, KouenApp, FileChangeWatcherTests (+1 more)

### Community 406 - "main.swift"
Cohesion: 0.20
Nodes (8): DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSViewCornerConfiguration, SurfaceID, Void

### Community 407 - "Fixed"
Cohesion: 0.16
Nodes (8): ObjectiveC, CGFloat, NSControl, StaticString, String, UInt, TabNavigationButtonsTests, WebKit

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.18
Nodes (10): statusColor(), statusHelp(), String, tabDisplayTitle(), TabStatus, done, error, idle (+2 more)

### Community 410 - ".applyTerminalIdentity"
Cohesion: 0.13
Nodes (12): CryptoKit, Network, DecodedWSFrame, Bool, ConnectionState, NWConnection, String, UInt8 (+4 more)

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.15
Nodes (8): DispatchSource, DispatchQueue, DispatchSourceFileSystemObject, Int32, URL, Void, TranscriptFileWatcher, MobileBridgeTranscriptWatcherTests

### Community 412 - "go.json"
Cohesion: 0.23
Nodes (13): kouen.bash script, agy(), claude(), codex(), copilot(), hermes(), kouen(), __kouen_agy_next() (+5 more)

### Community 413 - "javascript.json"
Cohesion: 0.24
Nodes (8): InstallResult, Shell, bash, fish, zsh, ShellIntegration, Bool, URL

### Community 414 - "json.json"
Cohesion: 0.17
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 415 - "markdown.json"
Cohesion: 0.18
Nodes (13): BUe(), dme(), eGt(), HUe(), Ije(), KD(), kXt(), nJ() (+5 more)

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.22
Nodes (4): _Bt(), by(), fst(), sBt

### Community 417 - "rust.json"
Cohesion: 0.20
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.20
Nodes (9): SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, Int32, String (+1 more)

### Community 419 - "typescript.json"
Cohesion: 0.15
Nodes (12): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+4 more)

### Community 420 - "yaml.json"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 422 - "HintModeOverlay"
Cohesion: 0.26
Nodes (14): Agent Command Does Not Crash, Agent Waiting Filter Does Not Crash, Board Command Shows Board Panel, Cd Command Switches To Matching Tab, Copy Path Command Does Not Crash, Errors Command Does Not Crash, Find Command Opens Command Palette On Empty Query, Find Command Resolves Unique File (+6 more)

### Community 423 - "SixelDecoder"
Cohesion: 0.24
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 424 - ".parseDiffHunks"
Cohesion: 0.11
Nodes (11): URL, String, String, KouenFilePreviewLoader, KouenViewError, binaryOrUnsupportedEncoding, missingPath, tooLarge (+3 more)

### Community 425 - "AgentVectorIcon"
Cohesion: 0.19
Nodes (9): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.27
Nodes (6): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection

### Community 427 - ".delay"
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 428 - "TaskDashboardView"
Cohesion: 0.22
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.47
Nodes (3): TabID, .body, TerminalTabBarDelegate

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.26
Nodes (6): SwarmFleetSnapshotWire, SwarmTaskNodeWire, Date, Double, String, UUID

### Community 431 - "BoardCardView"
Cohesion: 0.21
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 432 - "PathToken"
Cohesion: 0.24
Nodes (12): a2(), bpn(), cIn(), p7n(), pyn(), R1(), rht(), tun() (+4 more)

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.09
Nodes (17): PaletteWindowDelegate, String, Array, PickerItemRow, .badgeText, .iconName, .subtitle, .titleText (+9 more)

### Community 434 - "Project History"
Cohesion: 0.24
Nodes (8): ProjectDropTarget, .init(coder:), .init(frame:), NSCoder, NSDraggingInfo, NSDragOperation, NSRect, URL

### Community 435 - ".init"
Cohesion: 0.14
Nodes (14): Agent handbook — Kouen (extended reference), Agent integration, Build and test, IPC, Keyboard shortcuts, kouen-cli, Native terminal renderer, Repository map (+6 more)

### Community 436 - "WaitForRegistry"
Cohesion: 0.17
Nodes (5): HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 437 - "PickerItemRow"
Cohesion: 0.18
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 438 - "SessionEditor"
Cohesion: 0.22
Nodes (6): ListeningPortScanner, Int32, Set, String, result, ListeningPortScannerTests

### Community 439 - "SetupStepView"
Cohesion: 0.41
Nodes (7): FeatureSummary, FeatureTaskSummary, GateSummary, Bool, Date, String, UUID

### Community 440 - "LegacySnapshot"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 441 - "RemoteHostStore"
Cohesion: 0.16
Nodes (7): ProjectGroupResolver, String, String, .trimmed, AgentTitleInference, Bool, .effectiveAgentKind

### Community 443 - "main.swift"
Cohesion: 0.23
Nodes (3): MobileBridgeAttachFileTests, String, URL

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 445 - "Section"
Cohesion: 0.20
Nodes (9): AnyObject, CommandExecutionError, daemonError, .description, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor (+1 more)

### Community 446 - "Modifiers"
Cohesion: 0.24
Nodes (9): Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock, .block(id:) (+1 more)

### Community 447 - "PaletteMode"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 449 - "PresentAttempt"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.15
Nodes (11): copyMode, esc(), fs, globalShortcuts, KEYBINDINGS, prefixTable, renderTable(), ROOT (+3 more)

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.30
Nodes (5): SearchBenchmarks, String, UInt64, URL, Void

### Community 454 - ".recordReapedGenerationForTesting"
Cohesion: 0.22
Nodes (10): DotView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor, NSRect (+2 more)

### Community 455 - "ComposerPanel"
Cohesion: 0.18
Nodes (13): Branch Change In Shared Folder Is Not Isolated Unprompted, CLI Isolate Creates Worktree And Session, CLI Isolate With Custom Branch Name, Close Session Keeps Dirty Worktree, Close Session Removes Clean Worktree, Create Isolated Session And Select, Git Checkout In Normal Session Does Not Affect Isolated, Isolate Without Branch Uses Detached HEAD (+5 more)

### Community 457 - ".normalizedKey"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 458 - "FileTreeKeyboardNavigator"
Cohesion: 0.37
Nodes (3): AgentBrowserPaneTracker, Set, AgentBrowserPaneTrackerTests

### Community 459 - ".encode"
Cohesion: 0.13
Nodes (7): ControlKeyNormalizer, Bool, String, ShortcutRecorderSerializer, String, ControlKeyNormalizerTests, ShortcutRecorderSerializerTests

### Community 460 - "RunState"
Cohesion: 0.09
Nodes (13): FlippedView, .isFlipped, .removeWorktreeAction(_:), NSButton, NSColor, NSScrollView, NSStackView, NSTextField (+5 more)

### Community 461 - ".worktreeList"
Cohesion: 0.33
Nodes (4): .activeTab, BrowserTab, UUID, tabs

### Community 462 - "AGENTS.md"
Cohesion: 0.23
Nodes (9): AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor (+1 more)

### Community 463 - ".deinit"
Cohesion: 0.08
Nodes (21): JSONDecoder, JSONEncoder, Kind, input, metadata, output, resize, RecordingEvent (+13 more)

### Community 464 - "MouseButton"
Cohesion: 0.12
Nodes (4): AgentScanner, Bool, DispatchSourceTimer, TimeInterval

### Community 465 - "DirectionalAxis"
Cohesion: 0.24
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 466 - "PlatformSys.swift"
Cohesion: 0.41
Nodes (5): InstallResult, ShellCompletionInstaller, Bool, String, URL

### Community 467 - ".moveSelection"
Cohesion: 0.23
Nodes (5): FDWatchdog, DispatchSourceTimer, String, TimeInterval, FDWatchdogTests

### Community 468 - "Never"
Cohesion: 0.24
Nodes (3): ClaudeSessionModeTests, URL, Void

### Community 469 - "PresentAttempt"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 470 - "DispatchTime"
Cohesion: 0.23
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 471 - ".evaluateStyled"
Cohesion: 0.18
Nodes (6): eKe(), irn(), mrn, _rn(), rrn(), srn()

### Community 472 - "start.sh script"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 473 - "HarnessOnboarding"
Cohesion: 0.17
Nodes (9): Array, FormatColor, none, palette, rgb, Bool, Element, String (+1 more)

### Community 474 - "String"
Cohesion: 0.25
Nodes (7): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, NSEvent

### Community 475 - ".hitTest"
Cohesion: 0.26
Nodes (3): BellScanTests, Bool, UInt8

### Community 477 - ".encode"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 478 - ".install"
Cohesion: 0.60
Nodes (5): Switch To Session 1, Switch To Session 2, Rapid Session Switch While Typing, Switch Between Isolated And Normal Session, Switch Session And Switch Back Preserves Worktree

### Community 479 - "ScrollbackTests"
Cohesion: 0.26
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 480 - "Command Prompt Architecture"
Cohesion: 0.27
Nodes (7): AgyModelCatalog, Catalog, Date, String, TimeInterval, ConnectionState, NWConnection

### Community 481 - ".testKouenRendererFixtureDefaultTextReportsPlausibleGlyphStats"
Cohesion: 0.17
Nodes (5): DirectionalAxis, down, left, right, up

### Community 482 - ".resolve"
Cohesion: 0.33
Nodes (6): Bool, NSPasteboard, NSString, String, URL, AutoreleasingUnsafeMutablePointer

### Community 483 - "Changed"
Cohesion: 0.18
Nodes (7): DaemonCommandExecutor, Command, BellScanState, esc, normal, string, stringEsc

### Community 484 - "CopilotAdapter"
Cohesion: 0.17
Nodes (11): LinePos, end, firstNonBlank, start, ViDiagnosticNavigator, ViMode, insert, normal (+3 more)

### Community 485 - ".testKouenRendererFixtureLigatureShapingPathReportsPlausibleGlyphs"
Cohesion: 0.20
Nodes (9): BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool, CGFloat, NSCoder, NSPoint (+1 more)

### Community 486 - "TabPillView"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 487 - "bC"
Cohesion: 0.09
Nodes (14): .setupPrompt, AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile (+6 more)

### Community 488 - "ccRunCancel"
Cohesion: 0.24
Nodes (9): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+1 more)

### Community 489 - "SurfaceIO"
Cohesion: 0.37
Nodes (4): KouenFeatureMarkdownSync, Bool, String, URL

### Community 490 - "ccRunGet"
Cohesion: 0.22
Nodes (5): RepoResolver, Bool, String, RepoResolverTests, String

### Community 491 - ".update"
Cohesion: 0.07
Nodes (16): files, GitDiffFile, PairingBox, .current, .isLockedOut, PendingPairing, ProcessRunResult, Bool (+8 more)

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 493 - "ccRunStart"
Cohesion: 0.17
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 494 - "ccRunInfo"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 495 - ".makeDiffScrollView"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 497 - ".bind"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 498 - ".automationList"
Cohesion: 0.67
Nodes (3): l1(), TC(), xC()

### Community 499 - "GlassEffectView"
Cohesion: 0.15
Nodes (11): AnimatablePair, NotchMaskAnimator, Bool, CGFloat, CGRect, NotchShape, .animatableData, CGFloat (+3 more)

### Community 500 - "zO"
Cohesion: 0.22
Nodes (3): Notification.Name, KouenGit, os

### Community 501 - "Fixed"
Cohesion: 0.33
Nodes (5): AgentBridge, AgentTarget, Bool, String, SurfaceID

### Community 502 - "ACP Client (Shelved)"
Cohesion: 0.24
Nodes (5): RiskyCommandClassifier, Bool, NSRegularExpression, String, RiskyCommandClassifierTests

### Community 503 - "ReleaseNotesGuardTests"
Cohesion: 0.29
Nodes (6): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Carbon

### Community 504 - "String"
Cohesion: 0.27
Nodes (7): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8

### Community 505 - ".tickFeatureWorktreeSweepLocked"
Cohesion: 0.14
Nodes (5): Set, SurfaceID, Void, TerminalPaneRegistry, NSResponder

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.16
Nodes (17): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+9 more)

### Community 508 - "qLt"
Cohesion: 0.27
Nodes (7): Reason, errored, finished, needsInput, RowState, Bool, Comparable

### Community 509 - "start.mjs"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 510 - "PromptQueue"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 512 - ".setAttribute"
Cohesion: 0.39
Nodes (6): GitResult, .isSuccess, GitWorktreeInfo, Bool, Int32, String

### Community 513 - "ThemeDocument"
Cohesion: 0.27
Nodes (8): LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab, TabID, WorkspaceID

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.20
Nodes (5): FormatContextDaemonTests, PaneID, String, SurfaceID, URL

### Community 515 - "RD"
Cohesion: 0.18
Nodes (10): Bug 1 - Rotation Grace Slot Keeps The Previous Token Redeemable, Bug 1 - Rotation Shifts The Outgoing Token Into The Grace Slot, Bug 1 - Stop Fully Clears The Grace Slot, Bug 1 - Token Lifetime Not Regressed Below The Human-Flow Window, Bug 2 - Client onerror Does Not Clobber The Server Error Banner, Bug 2 - No Abrupt Cancel Immediately After The Error Text, Bug 2 - Reject Path Closes Gracefully With Policy-Violation Code 1008, Bug 3 - QR Not Printed When No Listener Is Ready (+2 more)

### Community 516 - "terminal_stress_runner.py"
Cohesion: 0.31
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 518 - "Bool"
Cohesion: 0.23
Nodes (7): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow, NSHostingController

### Community 519 - ".gestureRecognizer"
Cohesion: 0.14
Nodes (7): .promptRows, ReflowFastPathTests, .feeds, String, String, SemanticPromptTests, String

### Community 520 - "WriteOutcome"
Cohesion: 0.20
Nodes (10): Architecture Decisions (dated log), Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Post-P50 changes (v4.20.2 → v4.20.11, 2026-10-01 → 2026-10-06), Product Identity Guardrail: Terminal, Not IDE, Shipped capability summary, P44–P49 (2026-08-31 → 2026-09-23) (+2 more)

### Community 521 - ".daemonIsStale"
Cohesion: 0.20
Nodes (10): Agent Safety Net (Checkpoints, Verification, Write Guards), Claude Code Harness, Editor & LSP, How It Feels, Kouen Features, Mobile, Remote And Headless, Stack (+2 more)

### Community 522 - ".viewDidLoad"
Cohesion: 0.24
Nodes (3): KouenMCP, KouenBrowserToolsTests, URL

### Community 523 - "fFe"
Cohesion: 0.20
Nodes (10): PaneRef, bottom, byID, byIndex, last, left, next, previous (+2 more)

### Community 525 - ".encodeAndWait"
Cohesion: 0.25
Nodes (8): CodingKeys, cols, createdAt, dataBase64, rows, timeMs, type, version

### Community 526 - "Kind"
Cohesion: 0.36
Nodes (7): daemonLog(), detectStaleInstance(), installSignalHandlers(), removeForeignPIDFile(), Sendable, String, writePIDFile()

### Community 527 - ".show"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 528 - "worktree_review_dashboard.robot"
Cohesion: 0.31
Nodes (5): AgyAdapter, Result, ResultLine, String, UUID

### Community 529 - "WorktreeAutoIsolateService"
Cohesion: 0.20
Nodes (7): HeadlessRunEvent, assistantText, result, sessionID, Bool, Double, String

### Community 530 - "HarnessChrome"
Cohesion: 0.29
Nodes (9): AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand, Bool, Set (+1 more)

### Community 531 - "BrowserProgressLine"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 532 - "OpenClaw → Kouen"
Cohesion: 0.36
Nodes (4): AgentRemoteControlDaemonServiceTests, LogBox, .count, String

### Community 535 - "AgentNotification"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 536 - ".readGrid(scrollbackOffset:)"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 537 - "NSObject"
Cohesion: 0.24
Nodes (4): GroupedSessionDaemonTests, SessionGroup, String, URL

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.24
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 539 - "SavedLayoutIPCDaemonTests"
Cohesion: 0.16
Nodes (5): SSETransportTests, UInt16, MCPServer, String, NWListener

### Community 540 - ".delay"
Cohesion: 0.16
Nodes (13): Command Prompt, Find In Files, Git Panel, New Tab, Next Session, Open Command Palette, Previous Session, Session Navigation Cmd Brackets (+5 more)

### Community 541 - ".init"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 542 - ".init(from:)"
Cohesion: 0.36
Nodes (6): HistorySearchEvidence, .body, .terms, Bool, String, Text

### Community 543 - ".bufferLine"
Cohesion: 0.22
Nodes (7): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, NSCoder, Void

### Community 544 - "CodingKeys"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 545 - ".characterIndex"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Key spec syntax, Kouen keybindings, Persistence (+1 more)

### Community 546 - "LegacySnapshot"
Cohesion: 0.11
Nodes (17): AgentUsage, .contextTokens, .init(from:), .init(inputTokens:outputTokens:cacheReadTokens:cacheWriteTokens:thinkingTokens:totalCostUSD:), .shortSummary, CodingKeys, cacheReadTokens, cacheWriteTokens (+9 more)

### Community 547 - "NSObject"
Cohesion: 0.25
Nodes (7): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, String

### Community 548 - ".encode"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 549 - ".init(from:)"
Cohesion: 0.33
Nodes (4): OutputTrigger, OutputTriggerStore, Bool, String

### Community 550 - ".init(hex:)"
Cohesion: 0.33
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

### Community 551 - ".init(red:green:blue:alpha:)"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 552 - "PaneLabelDaemonTests"
Cohesion: 0.27
Nodes (4): aD(), crn, ELt(), n2e()

### Community 553 - "harness.resource"
Cohesion: 0.22
Nodes (8): Build order (unchanged from interview decision), G1 — @ file-path picker, G2 — shell tab-completion suggestion strip (heuristic, explicitly best-effort), G3 — AI command suggestion (via `claude` CLI subprocess), Logical Design, P37 Phase G — Autocomplete (mobile bridge), Strategic Design, Tactical Design

### Community 554 - "eFe"
Cohesion: 0.22
Nodes (8): Artifacts, Client Application — Slice 1 (stacked panes, no persistence), Client Application — Slice 2 (per-workspace divider memory), Context, Dev Task Progress — Workspace Sidebar Panels (P42), Integration, Note on task re-sequencing (2026-07-17), Summary

### Community 555 - "code:bash (harness view <file>                        # syntax-highligh)"
Cohesion: 0.22
Nodes (9): Contributors, Documentation, Install, Key features, Kouen, License, Requirements, Update (+1 more)

### Community 556 - "MobileBridgeSpawnTests"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 557 - ".viewWillMove"
Cohesion: 0.22
Nodes (8): MCP Control Allowed With Env Var, MCP Control Denied Without Env Var, MCP KouenBoard Returns Columns, MCP KouenList Returns Sessions, MCP ReadPaneOutput Returns Content, Run MCP Request, Run MCP Request Allowed, Run MCP Request Denied

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.08
Nodes (17): KouenTerminalSurfaceFocusTests, OcclusionTests, NSWindow, String, TimeInterval, SpecialKeyMappingTests, Bool, NSEvent (+9 more)

### Community 560 - "AgentNotification"
Cohesion: 0.22
Nodes (7): block, escFn, lineFilter, md, page, script, swift

### Community 561 - ".handleClaudeCode"
Cohesion: 0.31
Nodes (4): GraphifyIndexCache, S, Set, String

### Community 562 - "BrowserResponsePayload"
Cohesion: 0.25
Nodes (7): Agent Memory, Graphify, graphify, kouen-terminal — Agent Instructions, Rules (read when triggered), Session Start, Skills & Rules

### Community 563 - "AgentNotchViewModel.swift"
Cohesion: 0.39
Nodes (4): SessionGroup, Any, String, Tab

### Community 564 - "📁 IDE Sidebar"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 565 - "WriteOrigin"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 566 - "TerminalTabBarView.swift"
Cohesion: 0.25
Nodes (8): A `claude` typed by hand, Claude Code → Kouen, Customizing, One-line install, Session mode: Remote Control / cloud / local, The reverse direction: a session opened in Claude showing up in Kouen, Verifying, What gets written

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.32
Nodes (4): PaneID, SessionGroup, Tab, first

### Community 568 - ".installChromeBackground"
Cohesion: 0.32
Nodes (6): CGFloat, ResizeDirection, down, left, right, up

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.13
Nodes (11): Am(), bze(), Cm(), EQ(), Hm(), Im(), lte(), MBe() (+3 more)

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.25
Nodes (7): Claude Code hook push (in-process Task subagent detection), Client UI indicator, Detection core (AgentDetector, pure logic), IPC / Tab plumbing, P38 Phase B — Subagent Visibility — Dev Task Progress, Status: Rewritten 2026-07-14 after original implementation (tasks 1-5) was lost to a concurrent git operation before commit. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 571 - "ShellIntegrationTests"
Cohesion: 0.25
Nodes (7): Original overlay build (built 2026-07-14, gated green, then deleted 2026-07-15 mid live-test), P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress, Pivot — merge into the Recipes picker (2026-07-15), Stage 1-2 — Engine/surface plumbing (built 2026-07-14, unchanged by the pivot, still in use), Status: Implementation pivoted mid-phase from a standalone overlay to a merge into the existing, Summary, Thread grouping — Zed framing folded into the same picker (2026-07-15)

### Community 572 - "LayoutProbeView"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 573 - "tHe"
Cohesion: 0.25
Nodes (7): #kouen, #practice, #score, #shell, #total, #unix, #vim

### Community 574 - "FileTreeKeyboardNavigator"
Cohesion: 0.29
Nodes (7): Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow, launchStart

### Community 575 - ".toastErrorSummary"
Cohesion: 0.29
Nodes (5): ThaiClusterCopyTests, ThaiGrid, .columns, .totalLines, .viewportRows

### Community 576 - "Phase67Tests"
Cohesion: 0.25
Nodes (3): FlushSessionStateTests, String, URL

### Community 577 - "concurrency.md"
Cohesion: 0.29
Nodes (7): Toggle Sidebar, Sidebar Toggle Works, Board CLI Shows Columns, Board CLI Shows Running After Long Command, Board Columns Visible After Click, Board Tab Accessible In Sidebar, Split Pane And Resize

### Community 578 - "TaskDashboardBody"
Cohesion: 0.25
Nodes (7): Browser Pane Open Close Rapid, File Preview Open Close, Git Fetch Shows Toast, Launch Kouen Staging, Memory Stability After 30 Seconds, Quit Kouen Staging, Sidebar Toggle Immediately After Launch

### Community 583 - "WorkbenchMRU"
Cohesion: 0.38
Nodes (4): AnyObject, ObjectIdentifier, TimeInterval, ZombieHoldRegistry

### Community 584 - "GUt"
Cohesion: 0.29
Nodes (5): AgentNotchPresentation, closed, open, peek, AgentNotchWindowActivator

### Community 585 - "P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress"
Cohesion: 0.25
Nodes (3): SessionStore, DispatchWorkItem, TimeInterval

### Community 586 - "Product"
Cohesion: 0.22
Nodes (3): MobileBridgeSpawnTests, String, URL

### Community 587 - "sheet-cheat.html"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 588 - "jHt"
Cohesion: 0.29
Nodes (7): 1. Plain Terminal, 2. Persistent Terminal, 3. Full Terminal, 4. Agent Workspace, Experience modes, Opting into the prefix + status line without switching modes, Persistence (ephemeral vs. persistent)

### Community 589 - "Endpoint"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Kouen-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 590 - "lrn"
Cohesion: 0.33
Nodes (6): Command, .targetKind, TargetKind, pane, session, window

### Community 592 - "commit-push.sh"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 593 - "dO"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 594 - "r2"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 595 - "full-cycle.sh"
Cohesion: 0.29
Nodes (7): blockTokens(), inlineTokens(), lex(), lexer(), lexInline(), me(), reflink()

### Community 596 - ".feed(_:)"
Cohesion: 0.22
Nodes (6): _c(), jY(), Nn(), _pe(), Pqe, qp()

### Community 597 - "TerminalColorRole"
Cohesion: 0.29
Nodes (7): GRt(), n4e(), p7e(), r2(), tl(), vrt(), xq()

### Community 599 - ".terminalHostIfExists"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

### Community 600 - "stability_release.robot"
Cohesion: 0.29
Nodes (6): Locked decisions (user-confirmed), Logical Design, P38 Phase A — Cross-Agent Worktree Diff/Review Dashboard — Design, Strategic Design, Tactical Design, Verification gate (this phase)

### Community 601 - "Hwe"
Cohesion: 0.29
Nodes (6): Logical Design, Next Step, P42 — Workspace Sidebar Panels, Parked (not in scope), Strategic Design, Tactical Design

### Community 602 - "Build locally"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 603 - "fut"
Cohesion: 0.29
Nodes (6): Any, Error, MainActor, Sendable, String, Void

### Community 605 - "drn"
Cohesion: 0.33
Nodes (6): h1t(), hae(), jgn(), pwn(), sfn(), _Ue()

### Community 606 - "Quick start"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 607 - "iRe"
Cohesion: 0.38
Nodes (6): Cleanup And Quit, Create Config File, No Config File Starts Normally, Script Hot Reload On Save, Script Loads On Startup, Script Syntax Error Does Not Crash

### Community 609 - "FormatContextDaemonTests"
Cohesion: 0.29
Nodes (6): Bug 1 - Browser Pane Deferred Unregister, Bug 1 - Browser Pane Reuse On Rebuild, Bug 2 - New Session Syncs Before Reading Active Tab, Bug 2 - Tab Bar New Tab Also Syncs, Bug 3 - Browser Pane Forces Redraw On Reattach, Build Compiles Successfully

### Community 610 - "TabStatus"
Cohesion: 0.25
Nodes (4): Security, KouenMCPServer, Bool, String

### Community 611 - ".showWorkspaceMenu"
Cohesion: 0.67
Nodes (3): AsyncCLIResultBox, Error, Result

### Community 612 - ".init(coder:)"
Cohesion: 0.40
Nodes (5): CodingKeys, excludedPaths, id, name, sourceFolder

### Community 613 - "INDEX.md"
Cohesion: 0.07
Nodes (36): al(), bdn(), bIn(), Bm(), d7e(), dOt(), Em(), f6n() (+28 more)

### Community 614 - "MainSplitViewController"
Cohesion: 0.50
Nodes (5): aut(), cpn(), hq(), kLt(), q1n()

### Community 616 - "bump-version.sh"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 617 - "ScriptFileWatcher"
Cohesion: 0.47
Nodes (5): AgentIconArt, AgentVectorIcon, Bool, CGSize, String

### Community 618 - "parse"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase D — Kitty Graphics Conformance Slice, Scope (locked), Tests

### Community 619 - "_0n"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua), Scope (locked), Tests

### Community 620 - "mS"
Cohesion: 0.33
Nodes (5): Logical Design, Next Step, P43 — Add Repo/Folder to Workspace, Strategic Design, Tactical Design

### Community 621 - "ViEngine"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 622 - "sBt"
Cohesion: 0.60
Nodes (5): main(), printHelp(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 623 - "inlineTokens"
Cohesion: 0.40
Nodes (3): String, URL, WorktreeSignatureTests

### Community 626 - "cGt"
Cohesion: 0.47
Nodes (3): URL, TimeoutError, WorktreeLargeOutputRegressionTests

### Community 627 - "ActiveTabCloseDisposition"
Cohesion: 0.33
Nodes (5): Kouen LSP Diagnostics Does Not Crash, Kouen LSP Hover Returns Result, Kouen LSP Start Returns JSON, Kouen View Binary Shows Guard Message, Kouen View Prints File Content

### Community 628 - "ReplayStep"
Cohesion: 0.12
Nodes (8): String, LSPDefinitionPayload, LSPDiagnosticsPayload, LSPStatusPayload, String, UInt64, URL, Set

### Community 630 - "HGe"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 633 - "g_n"
Cohesion: 0.50
Nodes (4): PriorInstanceDecision, proceed, refuse, stale

### Community 635 - "yDt"
Cohesion: 0.40
Nodes (4): Findings, Sources, What this means for Kouen, Who creates branches / worktrees in AI coding tools

### Community 636 - ".handleCopyModeKey"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: animateSidebar setContentLeadingInset MainSplitViewController, Source Nodes

### Community 637 - "TerminalScrollbarView"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: ProjectCategory FolderScanner ProjectDirectoryTree, Source Nodes

### Community 638 - "FormatStringExtendedVariableTests"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: BrowserPaneView createTab openBrowserPane navigation WebKit, Source Nodes

### Community 639 - "gpn"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: KouenPreviewHome environment key daemon launch at startup, Source Nodes

### Community 641 - "[3.10.0] - 2026-06-27"
Cohesion: 0.40
Nodes (5): WrapperOptionBehavior, keepScanning, matchValue, skipValue, stopScanning

### Community 642 - "qut"
Cohesion: 0.06
Nodes (30): CustomStringConvertible, Error, InstallError, unsupported, DaemonClientError, connectionFailed, .description, timeout (+22 more)

### Community 643 - "h7n"
Cohesion: 0.40
Nodes (3): .init(forTesting:), UUID, Void

### Community 644 - "clean-state.sh"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 650 - "hjt"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 651 - "u0n"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 652 - "TerminalHostView"
Cohesion: 0.40
Nodes (4): Build, Release & Git Workflow, Build / Test / Run, Release packaging order, Worktree constraint

### Community 653 - "iOn"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 654 - "BlockContextMenuTests"
Cohesion: 0.70
Nodes (4): restart_daemon(), rollback_version_bump(), full-cycle.sh script, usage()

### Community 655 - "nht"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 656 - "Jcn"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 657 - "clear-runtime-state.sh"
Cohesion: 0.40
Nodes (4): Leak A - Retiring A Host Drops Its AI Controllers, Leak B - Browser Network Capture Is Bounded, Leak C - Every Per-Surface Dict In Coordinator Has Retire Cleanup, Leak D - Every Per-Surface Dict In NotificationCoordinator Is Snapshot-Swept

### Community 661 - ".compute"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

### Community 662 - "New Tab"
Cohesion: 0.50
Nodes (3): Caveats, Keep awake with the lid closed, Setup

### Community 663 - "m6e"
Cohesion: 0.50
Nodes (4): Full local signing path (needs a Developer ID cert; not currently used), How this fork actually releases, Release runbook, Scripted flow

### Community 664 - "P37 Phase G — Autocomplete (mobile bridge)"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 665 - "nb"
Cohesion: 0.50
Nodes (3): exclude_hubs, no_viz, wiki

### Community 666 - "BrowserIntegrationController"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: SSETransport auth token isRunning

### Community 668 - "nje"
Cohesion: 0.50
Nodes (4): dO(), m8(), rfn(), zfn()

### Community 669 - "PaneLabelDaemonTests"
Cohesion: 0.67
Nodes (4): FVe(), hJ(), qVe(), Zme()

### Community 670 - "pie"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 671 - "AntigravityTranscriptTurnsTests"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 672 - "ColorKind"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 673 - "qte"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 674 - "t2e"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 676 - "vne"
Cohesion: 0.50
Nodes (3): Bug 1 - Hunks Button Has Explicit Size Constraints, Bug 1 - Hunks Button Symbol Has A Guaranteed-Valid Fallback, Build Compiles Successfully

### Community 677 - "New Tab"
Cohesion: 0.50
Nodes (3): Guard A - Merge Call Site Never Passes --no-ff, Guard B - No Auto-Resolve Anywhere In The Merge/Conflict Path, Guard C - Merge Conflict State Is Reconciled, Not Just Read Once

### Community 678 - "FormatColor"
Cohesion: 0.36
Nodes (3): KouenSplitViewTests, LayoutProbeView, CGFloat

### Community 683 - ".normalizedKey"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 684 - "CommandParseError"
Cohesion: 0.67
Nodes (3): cat(), Hwe(), kYe()

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.67
Nodes (3): cfn(), fut(), qYe()

### Community 686 - "DECSpecialGraphics"
Cohesion: 0.67
Nodes (3): dht(), k0t(), l1n()

### Community 689 - ".hideFind"
Cohesion: 0.67
Nodes (3): iRe(), jNt(), zNt()

### Community 869 - "PairingBox"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: session history search ranking branch best matches, Source Nodes

### Community 870 - ".deinit"
Cohesion: 0.19
Nodes (8): CLIInstallLocator, OptionalUUID, absent, dangling, invalid, valid, URL, UUID

### Community 872 - "FSEventStreamRef"
Cohesion: 0.50
Nodes (4): WriteOutcome, complete, failed, wouldBlock

### Community 873 - ".title"
Cohesion: 0.50
Nodes (4): MouseEventKind, drag, press, release

## Knowledge Gaps
- **2388 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+2383 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1135 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Work-memory lessons

**Known dead ends** — questions that led nowhere; don't re-derive.
- "KouenPreviewHome environment key daemon launch at startup" -> `KouenPaths`

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `PerformanceBenchmarks` to `ThemeDocument`, `EngineConformanceTests`, `GroupedSessionDaemonTests`, `AgentNotchRootView`, `.gestureRecognizer`, `Command`, `LSPMessage`, `fFe`, `Changed`, `KittyKeyboardTests`, `VTParser`, `HarnessTerminalSurfaceView`, `.applyPreedit`, `MetalRendererTests`, `HarnessUILibrary`, `SpecialKey`, `code:block1 (Agent shell process)`, `.show`, `CopyModeAction`, `SplitPaneCoordinator`, `.request`, `WorktreeManager`, `Harness tmux-style capabilities`, `RGBColor`, `.parse`, `Added`, `.init(from:)`, `Sendable`, `.init`, `Equatable`, `LegacySnapshot`, `NSObject`, `code:bash (harness chat "Use the project map first, then inspect this r)`, `String`, `.init(hex:)`, `MenuTarget`, `HarnessSettings`, `CodingKeys`, `HarnessSidebarPanelViewController.swift`, `RenderSchedulerTests`, `code:bash (swift build)`, `HarnessTerminalSurfaceView.swift`, `HookEvent`, `DaemonServer`, `.keyEvent`, `Cross-terminal output-stress benchmark`, `.installChromeBackground`, `NSPanel`, `TabCell`, `GitPanelView.swift`, `ViEngine`, `FrecencyDirectoryStore`, `ComposedCell`, `HarnessCLI+Server.swift`, `.text`, `BellScanState`, `ShellIntegration`, `.toastErrorSummary`, `worktree_isolation_cli.robot`, `README.md`, `OptionStore`, `.parse`, `TerminalProtocolCompatibilityTests`, `HarnessDesign`, `commit-push.sh`, `.init`, `DaemonSubscription`, `.line`, `.firstMatch`, `TerminalGridCell`, `HarnessPaths`, `SessionCoordinator`, `Harness as a terminal multiplexer`, `.cursorPos`, `LSPDiagnostic`, `Build locally`, `P2 — Async IPC Refactor: Design Document`, `code:bash (# Terminal 1: Create workspace with long-running job)`, `AttachInputBatcher`, `shim.c`, `Harness Usage`, `4. Technical Architecture`, `.showWorkspaceMenu`, `ScriptRuntime.swift`, `DaemonLauncher`, `AgentNotchViewModel`, `.resolve`, `SoftIconButton`, `.makeSnapshot`, `HarnessGridTerminal`, `cGt`, `.encode`, `SessionGroup`, `OpenClaw → Kouen`, `ReplayStep`, `Harness command reference`, `Added`, `String`, `HistoryRingBuffer`, `GlyphAtlas`, `SwiftUI`, `qut`, `.install`, `AgentHookInstaller`, `clean-state.sh`, `TimeInterval`, `แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)`, `Added`, `.testPaneLeafLegacyDecodeBackfillsSurfaceTabs`, `CopyModeGridSource`, `How to use Harness from the terminal only (no GUI)`, `PaneStyleSet`, `AsciiFastPathTests`, `DecodedImage`, `LayoutTemplate`, `FileTreeWatcher`, `EnvironmentStore`, `HarnessDaemonToolsTests`, `.evaluate`, `Added`, `What You Must Do When Invoked`, `.currentSize`, `[3.3.0] - 2026-06-18`, `TriState`, `Harness Terminal — IDE Sidebar Feature Branch`, `MatchCategory`, `AmbientBackground`, `ActiveTabCloseDisposition`, `TriState`, `Added`, `Fixed`, `URLDetection`, `ReflowCorpusTests`, `.decodeKeySpec`, `BoardCard`, `DaemonClient`, `RGBColorTests`, `Added`, `[3.13.1] - 2026-07-02`, `HeadlessRunEvent`, `LSPServerRegistry`, `SessionSnapshot`, `Error`, `BrowserPaneView`, `P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client`, `user-stories.md`, `ScriptRuntime`, `GlyphRasterizer`, `ResizeHUDView`, `BinaryInstallerVersionTests`, `MCP Server (harness-mcp)`, `_Ue`, `Harness keybindings`, `u0n`, `scheduleRender`, `SettingsRemoteView`, `PaneDropZoneOverlay`, `PaneTarget`, `NotchLayoutMetrics`, `GridCompositor`, `Prompt`, `TerminalServicesProvider`, `AgentNotchRowSummary`, `ANSIPalette`, `CellColorResolver`, `.init`, `.setCellPixelSize`, `.decide`, `HarnessGridTerminalTests`, `ExternalOpenKind`, `P10 Task: Lazy Scrollback Reflow`, `TextGrid`, `WorkbenchCommand`, `TerminalBlockStoreTests`, `.make`, `AgentBridge`, `.configureEnvironment`, `ThemeDocumentTests`, `remote-ssh.md`, `FileNode`, `DaemonMetrics`, `Experience modes`, `SessionCoordinator`, `WindowTitleStripView`, `HarnessSidebarPanelViewController`, `.path`, `.performInstall`, `code:bash (# Old (agent-specific):)`, `DefaultTerminalManager`, `WindowSession`, `StatusLineView.swift`, `P8: macOS 27 Golden Gate Adoption`, `.vividColors`, `TerminalScrollbarView`, `.init`, `AgentHookStrategy`, `StatusLineWidthTests`, `Process`, `JSONDecoder`, `.resize`, `AgentApprovalBar`, `.bufferLine`, `settings.json`, `jobs`, `.parse`, `ThemeDiagnostics`, `.encodeMouse`, `00-inception-plan.md`, `.script`, `FrameSignposter`, `Bug: Tab-Switch Black Screen`, `code:bash (harness-cli install-hooks codex)`, `Memory — harness-terminal`, `FormatColor`, `UInt64`, `LayoutNode`, `.init`, `worktree_isolation.robot`, `README.md`, `CSIParams`, `code:bash (harness-cli install-hooks pi)`, `Added`, `[2.2.3] - 2026-06-09`, `FileViewerViewController`, `README.md`, `_8e`, `DaemonLifecycleTests`, `.init`, `.handleCat`, `OcclusionTests`, `State`, `[2.2.4] - 2026-06-11`, `Consumers`, `Tab`, `Git Panel`, `ScrollReuseTests`, `smoke-dmg.sh`, `NSTextField Leak in BoardViewController (P20 Performance)`, `INDEX.md`, `Darwin`, `build-release.sh`, `install-linux.sh`, `PresentAttempt`, `main.swift`, `Fixed`, `.applyTerminalIdentity`, `rust.json`, `SixelDecoder`, `.parseDiffHunks`, `Case: cwd "bleed" — session worktree jumps to wrong dir during builds`, `Competitive Position (as of v3.12.0, 2026-07-02)`, `LaunchdServiceInstaller`, `SessionEditor`, `SetupStepView`, `Modifiers`, `tmux parity — status, adaptations, and deliberate divergences`, `RunState`, `.worktreeList`, `.deinit`, `MouseButton`, `DirectionalAxis`, `.moveSelection`, `PresentAttempt`, `HarnessOnboarding`, `String`, `.encode`, `.testKouenRendererFixtureLigatureShapingPathReportsPlausibleGlyphs`, `SurfaceIO`, `.update`, `qLt`?**
  _High betweenness centrality (0.264) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `HarnessCLI+Server.swift` to `ShellIntegration`, `AgentSessionSummary.swift`, `.agentName`, `SessionID`, `PerformanceBenchmarks`, `HarnessTerminalSurfaceView.swift`, `HarnessTerminalSurfaceView`, `How to use Harness from the terminal only (no GUI)`, `.firstWaitingTab`, `.encode`, `ThemeDocumentTests`, `TabCell`, `README.md`, `SessionCoordinator`?**
  _High betweenness centrality (0.201) - this node is a cross-community bridge._
- **Why does `fbt()` connect `callingPaneTarget` to `CodingKey`, `IPCRequest`, `HarnessOverlayBackground`, `ThemeDocumentTests`?**
  _High betweenness centrality (0.110) - this node is a cross-community bridge._
- **Are the 18 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `RenderScheduler`) actually correct?**
  _`KouenTerminalSurfaceView` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _2408 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.006780742690758247 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.014458536942476985 - nodes in this community are weakly interconnected._