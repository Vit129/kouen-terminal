# Graph Report - kouen-file-types  (2026-10-16)

## Corpus Check
- 909 files · ~1,027,586 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 19739 nodes · 56628 edges · 2610 communities (1506 shown, 1104 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8463 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `eb4172e9`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 345 edges
2. `i()` - 321 edges
3. `a()` - 284 edges
4. `t()` - 253 edges
5. `SessionCoordinator` - 236 edges
6. `TerminalEmulator` - 229 edges
7. `SurfaceRegistry` - 224 edges
8. `u()` - 219 edges
9. `KouenCLI` - 210 edges
10. `IPCRequest` - 205 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 189 areas (205 edges)
2. `Command` - bridges 102 areas (108 edges)
3. `AgentKind` - bridges 83 areas (178 edges)
4. `t()` - bridges 79 areas (253 edges)
5. `IPCResponse` - bridges 79 areas (101 edges)
6. `KouenTerminalSurfaceView` - bridges 76 areas (345 edges)
7. `KouenPaths` - bridges 74 areas (150 edges)
8. `SessionCoordinator` - bridges 69 areas (236 edges)
9. `KouenGridTerminal` - bridges 65 areas (117 edges)
10. `NSView` - bridges 64 areas (190 edges)

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

## Communities (2610 total, 1104 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.01
Nodes (674): _0t(), _1n(), _1t(), _2t(), _3e(), _3n(), _4e(), _5e() (+666 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.01
Nodes (478): V, em(), _4n(), _7n(), _8n(), a8n(), a9e(), a_n() (+470 more)

### Community 2 - ".handleNormal"
Cohesion: 0.11
Nodes (14): CornerInfo, KouenSplitView, .dividerColor, .dividerThickness, DispatchWorkItem, Double, NSColor, NSRect (+6 more)

### Community 3 - "Changed"
Cohesion: 0.03
Nodes (321): pe(), r, X(), A(), code(), R(), a(), aDt() (+313 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.02
Nodes (278): a(), b(), c(), d(), e(), f(), g(), h() (+270 more)

### Community 5 - "IPCRequest"
Cohesion: 0.05
Nodes (44): AgentBridge, AgentTarget, Bool, String, SurfaceID, .onCurrentCWD, .onCurrentFile, LinePos (+36 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.04
Nodes (138): _7(), a6(), aJ(), Ame(), aQ(), aQt(), aUe(), aXt() (+130 more)

### Community 7 - "Command"
Cohesion: 0.04
Nodes (40): l, o, AI(), aXe(), aZ(), bee(), ck(), cy() (+32 more)

### Community 8 - "LSPMessage"
Cohesion: 0.04
Nodes (84): a1t(), amn(), b2t(), cg(), ch(), cse(), cvt(), d1n() (+76 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.09
Nodes (24): BDt(), Bpe(), cFe(), displayable(), eFe(), Fpe(), KBe(), kFe() (+16 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.10
Nodes (10): .receive(_:), DispatchSemaphore, FluidityBenchmarks, NSWindow, String, UInt64, LiveResizeTests, NSWindow (+2 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.07
Nodes (45): AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem, fetchGitStatus() (+37 more)

### Community 12 - "Changed"
Cohesion: 0.20
Nodes (7): BBe(), NBe(), PBe(), qLt(), sIt(), VBe(), zLt()

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.08
Nodes (27): Array, GroupHeaderRow, .body, PickerItem, .groupLabel, historyBlock, .id, recipe (+19 more)

### Community 14 - "VTParser"
Cohesion: 0.05
Nodes (54): TerminalGridCell, RGBColor, KouenGridTerminal, Bool, CAMetalDrawable, String, UInt64, .currentSelectionRegion (+46 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.10
Nodes (16): StatusLineView, .init(coder:), Bool, CGFloat, FormatColor, Never, NSAttributedString, NSCoder (+8 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.15
Nodes (13): BrowserPaneRegistry, .init(url:paneID:), .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), NSWindow, PaneID, WKNavigationAction, WKWebView (+5 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.06
Nodes (33): KeybindingsService, Bool, Command, String, KeySpec, .init(from:), Decoder, Binding (+25 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.04
Nodes (66): SettingsAppearanceView, .autoTheme, .body, .themeSection, .windowSection, SliderRow, .body, .displayValue (+58 more)

### Community 19 - "SpecialKey"
Cohesion: 0.06
Nodes (46): keys, HintModeOverlay, Any, NSEvent, String, CGImage, DecodedImage, .byteCount (+38 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.13
Nodes (26): br(), checkbox(), codespan(), constructor(), de(), del(), html(), list() (+18 more)

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.09
Nodes (16): RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), ScrollbackEntry, ScrollbackReplaySegment, Bool, CChar, DaemonSurfaceID, Int32 (+8 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.07
Nodes (15): EditorDividerView, HitTestPassthroughView, .init(coder:), PaneDragGripView, .init(coder:), PaneHoverButton, PaneSplitButtonsView, .init(coder:) (+7 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.08
Nodes (21): Data, DecodedReplyFrame, output, reply, DecodedRequestFrame, input, request, FrameError (+13 more)

### Community 24 - ".request"
Cohesion: 0.04
Nodes (33): NSRangePointer, NSEvent, String, Any, Bool, NSMenu, NSMenuItem, String (+25 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.05
Nodes (25): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+17 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.11
Nodes (32): MTLClearColor, MTLCommandBuffer, MTLRenderCommandEncoder, BgInstance, CursorCacheKey, .invertsGlyph, DecoInstance, EncodedFrameInstances (+24 more)

### Community 27 - "RGBColor"
Cohesion: 0.04
Nodes (34): .tab(forSurfaceKey:), AgentScanner, Bool, DispatchSourceTimer, TimeInterval, AutomationScheduler, DispatchSourceTimer, DaemonCommandExecutor (+26 more)

### Community 28 - ".parse"
Cohesion: 0.04
Nodes (70): a0n(), aA(), aie(), arc(), _Bt(), bX(), closePath(), cZ() (+62 more)

### Community 29 - "Added"
Cohesion: 0.07
Nodes (12): SessionCoordinator, Bool, Double, PaneID, PaneNode, SessionID, SplitDirection, String (+4 more)

### Community 30 - "Notification"
Cohesion: 0.08
Nodes (27): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+19 more)

### Community 31 - "Sendable"
Cohesion: 0.08
Nodes (13): Int, SemanticMark, HistoryLine, ImagePlacement, RewrapResult, Bool, ClosedRange, Range (+5 more)

### Community 32 - ".addTab"
Cohesion: 0.18
Nodes (3): fQ, hqe(), M9()

### Community 33 - "Equatable"
Cohesion: 0.04
Nodes (47): Bool, NSEvent, NSEvent, NSFont, Typography, .badge, .kbd, .paletteHeader (+39 more)

### Community 34 - "DaemonClient"
Cohesion: 0.10
Nodes (23): TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid, .gridOriginPointsX (+15 more)

### Community 35 - "MenuTarget"
Cohesion: 0.04
Nodes (58): A1(), aat(), AS(), bhn(), bvt(), bw(), cc(), cct() (+50 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.10
Nodes (4): B0, Fze, O7, RD

### Community 37 - "String"
Cohesion: 0.08
Nodes (12): SessionGroup, String, KouenSidebarPanelViewController, NSMenuItem, SessionGroup, String, NSMenu, NSMenuItem (+4 more)

### Community 38 - "code:bash (swift build)"
Cohesion: 0.07
Nodes (33): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, .body, PaletteMode (+25 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.15
Nodes (4): KouenDaemonTools, SpawnedAgentSurface, String, UUID

### Community 40 - "HarnessSettings"
Cohesion: 0.06
Nodes (40): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, .init(from:), .init(id:name:baseURL:modelID:), ModelProvider (+32 more)

### Community 41 - "CodingKeys"
Cohesion: 0.10
Nodes (19): .saveRecordsBatch(_:), CachedSessionEntry, Date, AgentHistoryScanner, .readJSONLLines(from:), .readJSONLLines(from:fromOffset:), AgentHistoryTurn, AgentSessionRecord (+11 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.11
Nodes (12): .event(_:), .interval(_:_:), StaticString, T, .testingPendingResize, PendingMainHop, SurfaceEmulatorState, SurfaceFrameBuildResult (+4 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.12
Nodes (10): .captureLines(joinWrapped:), .feed(_:), .promptRows, .readGrid(scrollbackOffset:), ScrollbackTests, Character, String, TerminalGridSnapshot (+2 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.11
Nodes (18): Process, SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, SSHTunnelManager (+10 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.11
Nodes (15): tab, .addSurface(tabID:paneID:), .addSurface(to:paneID:surfaceID:cwd:), .tab(containingPaneID:), .tab(for:), .tabIndex(surfaceKey:), .tabIndex(workspaceID:tabID:), Bool (+7 more)

### Community 46 - ".buildCommand"
Cohesion: 0.10
Nodes (11): PaneBorderStatus, Bool, Command, DispatchWorkItem, PaneID, PaneLeaf, PaneNode, PaneRect (+3 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.08
Nodes (39): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+31 more)

### Community 48 - "HookEvent"
Cohesion: 0.06
Nodes (26): CGFloat, String, DisplayLinkTarget, MainSplitViewController, .setSidebarVisible(_:), .setSidebarVisible(_:animated:), SplitChromeDelegate, .sidebarMaxWidth (+18 more)

### Community 49 - "DaemonServer"
Cohesion: 0.07
Nodes (45): Encodable, append(), cancelConnection(), ConnectionState, .agentMode, .authorized, .browserPaneID, .deviceID (+37 more)

### Community 50 - "Added"
Cohesion: 0.08
Nodes (12): Divergence, Bool, String, TimeInterval, WorktreeInfo, WorktreeManager, String, WorktreeIsolationTests (+4 more)

### Community 51 - ".keyEvent"
Cohesion: 0.11
Nodes (8): ISO8601DateFormatter, AnyCodable, JSONRPCError, .init(client:subscriptionClient:controlEnabled:), Int32, Pipe, String, ToolRegistry

### Community 52 - "Fixed"
Cohesion: 0.09
Nodes (18): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+10 more)

### Community 53 - "Added"
Cohesion: 0.05
Nodes (37): Error, PtyError, launchFailed, LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed (+29 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.09
Nodes (17): ConcurrentIndexSet, .count, DaemonContentionTests, SubscriptionBox, .count, String, URL, DaemonRoundTripTests (+9 more)

### Community 55 - "TabCell"
Cohesion: 0.12
Nodes (9): PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Double, String, UInt64, UInt8 (+1 more)

### Community 56 - "NSPanel"
Cohesion: 0.11
Nodes (14): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+6 more)

### Community 57 - "BellScanState"
Cohesion: 0.09
Nodes (35): ButtonStyle, CommandRow, .body, GlassCard, .body, GlassPrimaryButtonStyle, GlassSecondaryButtonStyle, GlassSmallButtonStyle (+27 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.09
Nodes (22): HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane, afterSplitPane, agentStateChanged (+14 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.08
Nodes (15): PluginLoader, String, ScriptAPI, ScriptError, .errorDescription, evaluationError, unsupportedPlatform, ScriptRuntime (+7 more)

### Community 60 - "ViEngine"
Cohesion: 0.07
Nodes (19): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, PaneID, SurfaceID (+11 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.09
Nodes (28): DaemonSubscription, .start(onData:onEnd:buffered:), .start(onResponse:onEnd:), Bool, Int32, String, TimeInterval, UInt16 (+20 more)

### Community 62 - "ComposedCell"
Cohesion: 0.12
Nodes (18): ClientRecord, CountBox, DaemonServer, .guiBrowserFD, PendingBrowserRequest, PendingWrite, .remaining, Bool (+10 more)

### Community 64 - ".text"
Cohesion: 0.07
Nodes (34): .agentInfo(forWorktreePath:), AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary (+26 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.13
Nodes (17): .exit, DaemonClient, String, String, String, String, KouenCLI, SessionID (+9 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.08
Nodes (30): .filteredJobs, MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith (+22 more)

### Community 67 - "String"
Cohesion: 0.16
Nodes (9): BrowserPaneView, .activeTab, .webView(_:didFinish:), BrowserTab, Any, URL, UUID, tabs (+1 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 69 - ".compose"
Cohesion: 0.08
Nodes (17): Tab, BrowserIntegrationController, PaneID, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), .init(paneID:), PaneID, PaneNode (+9 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.07
Nodes (33): .init(entry:), ChromeRole, sidebar, tabBar, FontSize, IconSize, KouenMotion, Radius (+25 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.09
Nodes (6): Phase67Tests, SessionPersistenceTests, Bool, String, TabID, URL

### Community 72 - "XCTestCase"
Cohesion: 0.10
Nodes (18): .requestDaemon(_:), .selectWorkspace(byIndex:), .syncFromDaemon(metadataOnly:), ActiveTabCloseDisposition, session, tab, window, workspace (+10 more)

### Community 73 - "README.md"
Cohesion: 0.08
Nodes (14): .snapshot, Bool, String, ThemeService, KouenOptions, ReconnectLatch, .isTripped, Bool (+6 more)

### Community 74 - "[2.6.0] - 2026-06-13"
Cohesion: 0.08
Nodes (21): IndexingIterator, LayoutTemplate, surfaceID, SessionEditor, .split(node:targetPaneID:direction:paneCount:before:), .split(node:targetPaneID:with:direction:beforeTarget:), .surfaceID(forPaneID:), .surfaceID(forPaneID:in:) (+13 more)

### Community 75 - "OptionStore"
Cohesion: 0.16
Nodes (9): Bool, URL, VersionBannerStore, Bool, Set, String, TimeInterval, URL (+1 more)

### Community 76 - ".parse"
Cohesion: 0.06
Nodes (36): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+28 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.12
Nodes (16): FleetJobItem, .isActive, .launchAgentScriptPath, .statusDisplay, AutomationsFleetView, .automationsList, .body, .emptyFleetView (+8 more)

### Community 78 - "Added"
Cohesion: 0.18
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 79 - "HarnessDesign"
Cohesion: 0.05
Nodes (26): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentDetection (+18 more)

### Community 80 - "Agent handbook — Harness (extended reference)"
Cohesion: 0.09
Nodes (25): bNt(), bu(), cNt(), dNt(), eNt(), eRe(), fNt(), h0t() (+17 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.09
Nodes (12): CGFloat, NSEvent, .currentRawSelection, RawSelection, Bool, CGFloat, CGRect, NSEvent (+4 more)

### Community 82 - ".firstMatch"
Cohesion: 0.15
Nodes (9): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSWindow (+1 more)

### Community 83 - "LSPClient"
Cohesion: 0.06
Nodes (24): KouenIPC, AgentSessionPlacement, background, cloud, local, remoteControl, vscode, .effectiveResumeCommand(claudeMode:) (+16 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.09
Nodes (23): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, IssueInfo (+15 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.10
Nodes (26): CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf, .init(from:) (+18 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.09
Nodes (31): al(), b1t(), bdn(), bIn(), c4n(), d7e(), dOt(), EWt() (+23 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 89 - ".cursorPos"
Cohesion: 0.09
Nodes (9): ContentAreaViewController, TabID, NSCoder, NSRect, String, Void, WorktreeIsolationNoticeView, .init(coder:) (+1 more)

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.06
Nodes (32): AgentHistoryDateGroup, older, .sortOrder, thisWeek, today, yesterday, AgentSessionHistoryModel, .extraRecordsShown (+24 more)

### Community 91 - "TerminalModes"
Cohesion: 0.18
Nodes (7): CSIParams, .count, Pen, SavedCursor, TerminalGridColor, TerminalGridUnderline, UInt8

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.18
Nodes (12): .mcpButton, json, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter, Any (+4 more)

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.08
Nodes (26): Notification.Name, os, Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow (+18 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.23
Nodes (9): AutomationsFleetModel, .load(detectScheduledRuns:), JobResultArtifact, .systemImage, Any, Bool, Date, String (+1 more)

### Community 95 - "shim.c"
Cohesion: 0.15
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 96 - "Harness Usage"
Cohesion: 0.08
Nodes (24): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, .onSelect, NotificationDropdownPanelView (+16 more)

### Community 97 - "PaneContainerView"
Cohesion: 0.08
Nodes (18): .init(coder:), BrowserTabButton, .init(coder:), .init(title:isActive:onSelect:onClose:), DesignModeElementInfo, DesignModePopoverViewController, .init(coder:), .init(title:properties:styles:onStyleChanged:onCopyCSS:onPromptAgent:) (+10 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.10
Nodes (20): NSView, DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSViewCornerConfiguration, SurfaceID (+12 more)

### Community 99 - ".dispatch"
Cohesion: 0.08
Nodes (26): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+18 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.08
Nodes (27): .body, FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body (+19 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.08
Nodes (21): MainActor, Void, Group, ParsedShortcut, .displayString, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow (+13 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.08
Nodes (32): CGFloat, FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView (+24 more)

### Community 103 - "AnyCodable"
Cohesion: 0.16
Nodes (14): CoreGraphics, CoreText, ImageIO, KouenCopyMode, KouenTerminalEngine, KouenTerminalRenderer, KouenTheme, Metal (+6 more)

### Community 104 - "Recipe"
Cohesion: 0.05
Nodes (39): Completed Plans Archive, Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions, Logical Design, P41 — Automations, Strategic Design (+31 more)

### Community 105 - "Changelog"
Cohesion: 0.06
Nodes (45): agentWaitChannel(), BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserRequestPayload, close, cookies (+37 more)

### Community 106 - "domain-design.md"
Cohesion: 0.08
Nodes (15): DiffLineType, added, deleted, modified, Notification.Name, Bool, DispatchWorkItem, NSEvent (+7 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.09
Nodes (8): DaemonBrowserRoutingTests, IPCCodecInvariantTests, String, URL, ScrollbackPersistenceTests, String, URL, XCTestCase

### Community 108 - ".resolve"
Cohesion: 0.18
Nodes (7): KouenWindow, NSEvent, MainWindowController, Any, NSRect, NSWindow, NSWindowController

### Community 109 - "DamageTrackingTests"
Cohesion: 0.10
Nodes (15): FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect, String, URL (+7 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.14
Nodes (17): AgentHistoryFTSIndex, .deleteSession(sessionID:), .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:surfaceTag:topicSegments:), .needsReindex(sessionID:mtime:fileSize:), .pruneMissingSessions(validTranscriptPaths:), .saveRecord(_:mtime:fileSize:), .search(query:limit:), .searchRanked(query:limit:includeSnippet:) (+9 more)

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.13
Nodes (5): .setupPrompt, hooks, AgentHookInstallerTests, String, URL

### Community 112 - ".makeSnapshot"
Cohesion: 0.18
Nodes (11): SwarmSpawnSpec, CallRecorder, .cancelCalls, .closeCalls, .harnessCalls, .surfaceCalls, SwarmWorkerManagerTests, Bool (+3 more)

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.15
Nodes (9): StringKind, apc, dcs, UInt8, UnsafeBufferPointer, VTParser, .feed(_:), VTParserHandler (+1 more)

### Community 115 - ".encode"
Cohesion: 0.12
Nodes (11): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, PaneID (+3 more)

### Community 116 - "SessionGroup"
Cohesion: 0.06
Nodes (28): SettingsAdvancedView, .body, Bool, String, .body, SettingsHostingController, .init(coder:), .init(page:) (+20 more)

### Community 117 - "PaneNode"
Cohesion: 0.07
Nodes (19): Kind, primary, secondary, KouenPillButton, .init(title:kind:), .isHovered, .isPressed, NSColor (+11 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.14
Nodes (18): CommandParseError, .description, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand (+10 more)

### Community 119 - "Harness command reference"
Cohesion: 0.11
Nodes (20): bH(), cOt(), i4e(), i6e(), jIt(), nae(), oOt(), q4e() (+12 more)

### Community 120 - "Added"
Cohesion: 0.10
Nodes (7): Bool, Range, Set, String, URLDetection, StringProtocol, EngineConformanceTests

### Community 121 - "Changed"
Cohesion: 0.08
Nodes (30): ImagePlacementSnapshot, Bool, String, UInt8, TerminalCellWidth, normal, spacerTail, wide (+22 more)

### Community 122 - "ViEngine"
Cohesion: 0.11
Nodes (26): ColorKind, .base, bg, fg, underline, CompositorPane, GridCompositor, .render(panes:status:statusSegments:) (+18 more)

### Community 123 - "Pipe"
Cohesion: 0.09
Nodes (31): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+23 more)

### Community 124 - "String"
Cohesion: 0.08
Nodes (21): DaemonClientActor, TimeInterval, DaemonSessionError, daemonError, .description, unexpectedResponse, DaemonSessionService, .endpoint (+13 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.13
Nodes (14): NSEvent, PaneDropZoneOverlay, .init(coder:), .init(targetPaneID:), NSCoder, NSPoint, NSRect, PaneID (+6 more)

### Community 126 - ".path"
Cohesion: 0.14
Nodes (15): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+7 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.10
Nodes (25): FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID, FeaturePhase (+17 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.10
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 129 - "SwiftUI"
Cohesion: 0.06
Nodes (45): AnyTransition, AnyView, AgentNotchPeekEvent, AgentNotchRootView, .body, .bottomRadius, .closedAccessibilityLabel, .closedTransition (+37 more)

### Community 130 - "Harness"
Cohesion: 0.10
Nodes (17): AgentBrowserPaneTracker, SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, SessionID (+9 more)

### Community 131 - ".install"
Cohesion: 0.15
Nodes (15): .pairedAlreadyBanner, .pairingQRPanel, .sidebarEmptyView, TrackedIssue, GitHubSearchResult, IssueFetchStatus, apiError, live (+7 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.19
Nodes (7): TerminalGridCell, Case, ReflowCorpusTests, .corpus, .goldenDir, String, URL

### Community 133 - ".load"
Cohesion: 0.11
Nodes (22): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), GlyphKey (+14 more)

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.08
Nodes (15): item, input, ClaudeSessionLocator, ClaudeTranscriptLine, Role, assistant, user, Any (+7 more)

### Community 135 - "CommandTarget"
Cohesion: 0.18
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 136 - ".startWatching"
Cohesion: 0.05
Nodes (25): KouenCLITests, URL, CLIInstallLocator, DetachKeys, absent, invalid, parsed, OptionalUUID (+17 more)

### Community 137 - "ActivePaneService"
Cohesion: 0.17
Nodes (10): SSETransportTests, UInt16, SSETransport, .isRunning, .listener, Bool, NWConnection, NWListener (+2 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.28
Nodes (5): SpecialKeyMappingTests, Bool, NSEvent, String, UInt16

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.12
Nodes (6): GitPanelView, .isHidden, Any, DispatchWorkItem, NSMenuItem, UnsafeMutableRawPointer

### Community 140 - "Added"
Cohesion: 0.10
Nodes (14): NotchMaskAnimator, Bool, CGFloat, CGRect, NotchPanel, .canBecomeKey, .canBecomeMain, Bool (+6 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.15
Nodes (10): ScrollbackFile, .highWater, Bool, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.14
Nodes (5): FilePreviewCoordinator, FileTabID, Set, SplitDirection, String

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.15
Nodes (12): NaturalLanguage, AgentHistorySearch, Hit, IDFCache, Bool, Double, String, .tokenHits(_:inNormalized:) (+4 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.13
Nodes (8): SGRMouse, SGRMouseEvent, Bool, PaneRect, UInt8, SGRMouseTests, String, UInt8

### Community 145 - "AsciiFastPathTests"
Cohesion: 0.12
Nodes (10): EndpointError, connectionFailed, .description, notYetSupported, pathTooLong, String, EndpointConnector, Int32 (+2 more)

### Community 146 - "DecodedImage"
Cohesion: 0.14
Nodes (20): ComposedCell, .asGridCell, .init(_:), .init(codepoint:fg:bg:underlineColor:bold:dim:italic:underline:blink:inverse:invisible:strikethrough:overline:), .scalar, .sgr, CompositorPane, GridCompositor (+12 more)

### Community 147 - "FileTreeWatcher"
Cohesion: 0.14
Nodes (8): MutationResult, RemoteHost, RemoteHostStore, Bool, String, RemoteHostStoreTests, String, URL

### Community 148 - "TriState"
Cohesion: 0.10
Nodes (18): SavedLayoutStore, Bool, String, URL, UUID, PaneLayoutShape, branch, leaf (+10 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.15
Nodes (12): AgentNotchPeekDecider, Reason, errored, finished, needsInput, RowState, Bool, String (+4 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.12
Nodes (12): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+4 more)

### Community 151 - ".evaluate"
Cohesion: 0.13
Nodes (17): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerModel, DirectoryPickerView, .body (+9 more)

### Community 152 - "Added"
Cohesion: 0.07
Nodes (30): BinaryInstaller, .bundledMacOSDir, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display (+22 more)

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.10
Nodes (13): FlippedView, .isFlipped, .removeWorktreeAction(_:), NSButton, NSColor, NSRect, NSScrollView, NSStackView (+5 more)

### Community 154 - "LiveResizeTests"
Cohesion: 0.08
Nodes (19): .webView(_:didCommit:), BrowserPaneViewTests, MockWebView, .isLoading, .url, Any, Bool, CGFloat (+11 more)

### Community 155 - "Int"
Cohesion: 0.15
Nodes (8): MarkdownPreviewView, Any, Bool, Error, String, URL, Void, MarkdownPreviewTests

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.10
Nodes (17): NSWindow, Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent, NSPoint (+9 more)

### Community 157 - "Added"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, S (+2 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.09
Nodes (23): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+15 more)

### Community 159 - "MatchCategory"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.08
Nodes (31): FilterStatus, active, all, completed, CaseIterable, KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:) (+23 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.10
Nodes (19): Coordinator, DiffAnalysis, DiffFileItem, DiffFileStatus, added, .color, deleted, modified (+11 more)

### Community 163 - "Workspace"
Cohesion: 0.09
Nodes (12): CKouenSys, pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal (+4 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.20
Nodes (10): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, automations (+2 more)

### Community 166 - "LiveSession"
Cohesion: 0.16
Nodes (15): ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool, Command (+7 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.14
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 168 - "Added"
Cohesion: 0.18
Nodes (6): CopyModeReducerTests, FakeGrid, .totalLines, Set, String, TerminalGridCell

### Community 169 - "Fixed"
Cohesion: 0.19
Nodes (5): .readAntigravitySummaries(dbPath:brainDir:ftsIndex:), AgentHistoryMultiAgentCoverageTests, Bool, String, URL

### Community 170 - "URLDetection"
Cohesion: 0.12
Nodes (12): ShellLaunchProfile, .argv, ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID (+4 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.14
Nodes (18): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, PaneLeaf, PaneNode (+10 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.10
Nodes (12): Bool, String, UInt8, TerminalEmulator, .captureLines(fromLine:toLine:), .onResponse, .onSetClipboard, TerminalColorRole (+4 more)

### Community 173 - "BoardCard"
Cohesion: 0.27
Nodes (7): FileNode, Bool, String, FileTreeScanOptions, ScoredMatch, Bool, String

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.16
Nodes (7): .removeWorktreeAction(path:), GitResult, Bool, String, ValidateOutcome, WorktreeEntry, GitPanelViewWorktreeParsingTests

### Community 175 - "RGBColorTests"
Cohesion: 0.11
Nodes (21): FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose, FileTabPillView (+13 more)

### Community 176 - "Added"
Cohesion: 0.12
Nodes (16): AgentSessionHistoryView, .body, .footerView, HistoryMenuProxy, Any, Bool, CGFloat, Date (+8 more)

### Community 177 - ".rects"
Cohesion: 0.20
Nodes (5): CellOverlayTests, IndexSet, NSWindow, String, UInt64

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.16
Nodes (11): Equatable, PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab (+3 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.16
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 181 - "GridCompositorTests"
Cohesion: 0.10
Nodes (25): Bool, UInt8, TerminalCellWidth, normal, spacerTail, wide, TerminalCursor, TerminalCursorShape (+17 more)

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.10
Nodes (11): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+3 more)

### Community 183 - "LSPServerRegistry"
Cohesion: 0.13
Nodes (13): MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem, SessionGroup (+5 more)

### Community 184 - "targets"
Cohesion: 0.11
Nodes (24): .color, Collection, .aggregateBoardStatus, .taskTooltipSummary, TaskSummary.Status, .columnKind, BoardCard, BoardColumn (+16 more)

### Community 185 - "SessionSnapshot"
Cohesion: 0.19
Nodes (13): DecodedWSFrame, MobileBridgeServer, Bool, ConnectionState, NWConnection, Sendable, String, T (+5 more)

### Community 186 - "Error"
Cohesion: 0.07
Nodes (20): Codex → Kouen, One-line install, What you'll see, Cursor Agent → Kouen, Manual fallback, One-line install, What you'll see, Grok Build → Kouen (+12 more)

### Community 187 - "AppDelegate"
Cohesion: 0.12
Nodes (11): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, osc (+3 more)

### Community 188 - "BrowserPaneView"
Cohesion: 0.12
Nodes (7): NSCursor, NSPasteboard, URL, NSPasteboard, String, URL, KouenTerminalSurfaceDragDropTests

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.13
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 190 - "user-stories.md"
Cohesion: 0.14
Nodes (28): Cleanup Test Repo, Close Isolated Session Keeps Dirty Worktree, Close Isolated Session Removes Clean Worktree, Close One Isolated Does Not Affect Another, Close Session With Split Panes Removes Worktree, Create Isolated Session, Create Isolated Session Via CLI, Get Active Pane (+20 more)

### Community 192 - "GlyphRasterizer"
Cohesion: 0.09
Nodes (9): String, WorkspaceID, CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab, DaemonSyncServiceBranchNotifyTests (+1 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.10
Nodes (19): DataBox, .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:) (+11 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.12
Nodes (10): Bool, CGFloat, NSCoder, NSLayoutConstraint, NSPoint, NSRect, WindowTitleStripView, .init(coder:) (+2 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.15
Nodes (14): FileTreeContext, Bool, NSCoder, NSDraggingInfo, NSDragOperation, NSHostingView, NSScrollView, SessionID (+6 more)

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.13
Nodes (18): Motion, .entrance, .spring, .standardEase, CAMediaTimingFunction, KouenOnboarding, Bool, ImmersiveOnboardingWindowController (+10 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.07
Nodes (28): Additional `kouen-cli` subcommands, Agent safety CLI (`kouen-cli`), Agents, context and scratchpad, Attaching from a plain terminal, Bindings, Board and attention, Buffers (paste store), Composition (+20 more)

### Community 198 - ".classify"
Cohesion: 0.21
Nodes (4): CommandTarget, String, UUID, TargetSpecTests

### Community 199 - "code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)"
Cohesion: 0.14
Nodes (14): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+6 more)

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.30
Nodes (6): FormatContext, FormatString, Bool, Character, Date, String

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.18
Nodes (5): ClaudeCodeHarness, .hasAdapter(for:), Bool, UUID, ClaudeCodeHarnessTests

### Community 202 - "PaletteModel"
Cohesion: 0.14
Nodes (13): AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID, .snapshotPayload, NotificationBus (+5 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.14
Nodes (19): AgentArt, AgentMark, .body, AgentMarkShape, AgentVectorIcon, Scanner, .atEnd, SVGPath (+11 more)

### Community 204 - "From tmux"
Cohesion: 0.15
Nodes (10): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, Set, SurfaceID (+2 more)

### Community 205 - "CopyModeState"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.14
Nodes (7): KeybindingsStore, .fileURL, URL, KeybindingsStoreTests, URL, Void, String

### Community 207 - "scheduleRender"
Cohesion: 0.12
Nodes (10): Bool, NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView (+2 more)

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.19
Nodes (11): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, .selectedHost (+3 more)

### Community 209 - "SettingsRemoteView"
Cohesion: 0.16
Nodes (8): MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, SurfaceID, MenuTargetPeerReviewTests

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.14
Nodes (14): ObserverToken, NSCoder, NSObjectProtocol, NSPopover, NSRect, NSTextView, SyntaxLineNumberGutterView, .init(coder:) (+6 more)

### Community 211 - "PaneTarget"
Cohesion: 0.21
Nodes (8): FileTreeNode, NodeRow, .body, .isFocused, .parentDirectory, Bool, Error, String

### Community 212 - ".translate"
Cohesion: 0.08
Nodes (6): KouenSettings, Bool, ExperienceModeTests, KouenSettingsTests, URL, Void

### Community 213 - "String"
Cohesion: 0.13
Nodes (12): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+4 more)

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.14
Nodes (8): PaneNode, BrowserLeaf, URL, DaemonSyncServiceBrowserPaneMergeTests, PaneID, PaneNode, PaneNodeBrowserTests, PaneNodeLayoutShapeTests

### Community 215 - ".lines"
Cohesion: 0.11
Nodes (5): KouenThemeCatalog, .allThemes, String, ANSIPaletteTests, KouenThemeCatalogTests

### Community 216 - "CellColorResolverTests"
Cohesion: 0.15
Nodes (8): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ActivityAssertionManagerTests

### Community 217 - "GridCompositor"
Cohesion: 0.14
Nodes (11): FileFuzzyMatcher, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool, Character (+3 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.16
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 219 - "Prompt"
Cohesion: 0.13
Nodes (15): BranchSwitchHelper, FileTreeSwiftUIView, .body, .filteredNodes, .rootPath, .scanOptions, .sessionID, .taskID (+7 more)

### Community 220 - "Section"
Cohesion: 0.14
Nodes (15): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+7 more)

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.11
Nodes (16): ControlMessage, AgyModelCatalog, Catalog, Date, String, TimeInterval, AgyMobileCommands, String (+8 more)

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.24
Nodes (9): CopyModeGridSource, .promptRows, CopyModeReducer, Bool, Character, NSRegularExpression, Range, String (+1 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.18
Nodes (5): KouenFeatureMarkdownSync, Bool, String, URL, String

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.19
Nodes (9): Executor, Hook, HookRegistry, Bool, Command, URL, UUID, HookExecutor (+1 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.13
Nodes (3): KittyKeyboardTests, String, UInt8

### Community 228 - "sessionRow"
Cohesion: 0.18
Nodes (10): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+2 more)

### Community 229 - ".decide"
Cohesion: 0.14
Nodes (12): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+4 more)

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.10
Nodes (20): IssueKeychainStore, Bool, String, IssuePriority, .color, high, low, medium (+12 more)

### Community 231 - "ExternalOpenKind"
Cohesion: 0.17
Nodes (11): NotchGeometry, .fallback, NSScreen, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics (+3 more)

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.19
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 233 - "TextGrid"
Cohesion: 0.08
Nodes (26): .lspPosition(characterOffset:), .lspPosition(for:), Codable, CodingKeys, error, id, jsonrpc, method (+18 more)

### Community 234 - ".scan"
Cohesion: 0.18
Nodes (5): CompositorPane, GridCompositorTests, Bool, String, TerminalGridSnapshot

### Community 235 - "WorkbenchCommand"
Cohesion: 0.13
Nodes (16): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, .bytesPerWakeup, .mbps (+8 more)

### Community 236 - "Added"
Cohesion: 0.15
Nodes (14): JSONRPCMessage, notification, request, response, StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength (+6 more)

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.18
Nodes (7): CheckpointInfo, CheckpointManager, Bool, Date, String, CheckpointManagerTests, String

### Community 238 - ".make"
Cohesion: 0.16
Nodes (3): CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.32
Nodes (3): BinaryInstallerVersionTests, String, URL

### Community 240 - "PaneBorderStatus"
Cohesion: 0.11
Nodes (12): UnsafeBufferPointer, TerminalCellWidth, UnsafeBufferPointer, CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable (+4 more)

### Community 241 - "Added"
Cohesion: 0.19
Nodes (7): Scope, global, pane, session, workspace, ScopedKey, URL

### Community 242 - "AgentBridge"
Cohesion: 0.20
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 243 - ".make"
Cohesion: 0.16
Nodes (12): UInt16, TTYSize, RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal (+4 more)

### Community 244 - "FileNode"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.20
Nodes (6): LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled

### Community 246 - "Experience modes"
Cohesion: 0.21
Nodes (8): LSPFileSession, Never, String, Task, URL, Void, object, Bool

### Community 247 - ".renderFixture"
Cohesion: 0.29
Nodes (5): Agent, OnboardingEnvironment, Bool, String, OnboardingEnvironmentTests

### Community 248 - "DaemonMetrics"
Cohesion: 0.15
Nodes (8): BoardViewController, .isVisible, FlippedView, .isFlipped, Bool, Set, TabID, BoardViewControllerTests

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.06
Nodes (17): NSResponder, NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent (+9 more)

### Community 251 - "SessionCoordinator"
Cohesion: 0.11
Nodes (13): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, PaneLeaf (+5 more)

### Community 252 - "NSViewRepresentable"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 253 - "Split Right"
Cohesion: 0.14
Nodes (11): AgentRoutingResolver, String, AgentRoutingRule, Kind, path, stack, Bool, Date (+3 more)

### Community 254 - "BoardViewController"
Cohesion: 0.22
Nodes (7): AgentRoutingRuleStore, Bool, String, URL, UUID, AgentRoutingRuleStoreTests, URL

### Community 255 - "release-hotfix.sh"
Cohesion: 0.13
Nodes (17): FormatContextBuilder, DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:) (+9 more)

### Community 256 - "GitMetadataProvider"
Cohesion: 0.13
Nodes (14): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8, GlassEffectView (+6 more)

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.14
Nodes (17): PaneBorderStatus, bottom, off, top, PaneLeaf, PaneNode, branch, leaf (+9 more)

### Community 258 - "WindowTitleStripView"
Cohesion: 0.13
Nodes (9): NSDraggingInfo, NSDragOperation, PasteController, Bool, NSPasteboard, String, TimeInterval, URL (+1 more)

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 260 - ".welcome"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.06
Nodes (10): AsciiFastPathTests, StaticString, String, UInt, CodepointRunFastPathTests, .assertAllPathsAgree(_:cols:rows:file:line:), StaticString, String (+2 more)

### Community 262 - ".install"
Cohesion: 0.11
Nodes (12): AgentNotchPresentation, closed, open, peek, AgentNotchViewModel, .visibleRows, .waitingCount, AgentNotchWindowActivator (+4 more)

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.10
Nodes (6): PromptQueue, String, SurfaceID, Void, PromptQueueBar, NSWindow

### Community 264 - "code:bash (harness-cli install-hooks claude-code)"
Cohesion: 0.15
Nodes (4): SessionStore, DispatchWorkItem, TimeInterval, Set

### Community 265 - "code:bash (harness-cli install-hooks cursor)"
Cohesion: 0.13
Nodes (15): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+7 more)

### Community 266 - ".path"
Cohesion: 0.19
Nodes (13): PreparedWorktree, Bool, MainActor, NSObjectProtocol, Set, String, Tab, TabID (+5 more)

### Community 267 - ".performInstall"
Cohesion: 0.12
Nodes (13): AppKit, NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void (+5 more)

### Community 268 - "code:bash (# Old (agent-specific):)"
Cohesion: 0.23
Nodes (4): Bool, Bool, String, URL

### Community 269 - "DefaultTerminalManager"
Cohesion: 0.14
Nodes (13): SwarmFleetBody, .body, SwarmNodeRowView, .body, .statusColor, Duration, Void, SwarmFleetSnapshotWire (+5 more)

### Community 270 - "WindowSession"
Cohesion: 0.18
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 271 - "StatusLineView.swift"
Cohesion: 0.15
Nodes (9): GitStatusType, added, deleted, modified, renamed, unmodified, untracked, .resolvedGitStatus (+1 more)

### Community 272 - "SGRMouseEvent"
Cohesion: 0.12
Nodes (16): .effectiveResumeCommand(mode:), AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand, Bool (+8 more)

### Community 273 - "KeySpec"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.17
Nodes (21): Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors, ContrastGrade (+13 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.13
Nodes (3): KouenGridTerminalTests, String, TerminalGridSnapshot

### Community 277 - ".run"
Cohesion: 0.16
Nodes (13): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+5 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.09
Nodes (14): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+6 more)

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.14
Nodes (14): .agentColorBinding, colors, ANSIPalette, CellColorResolver, MochaTheme, ResolvedCellColors, .init(hex:), .init(red:green:blue:alpha:) (+6 more)

### Community 280 - ".menu"
Cohesion: 0.18
Nodes (20): CoreImage, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription, .surfaceID, detectHost() (+12 more)

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.15
Nodes (12): OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Bool, Value, bool (+4 more)

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.09
Nodes (10): TimeInterval, AgentHandoffBuilder, Bool, String, RemoteControlURLProvider, Bool, URL, HandoffDirectoryTests (+2 more)

### Community 283 - "FormatColor"
Cohesion: 0.19
Nodes (13): ProjectGroupWatcher, StreamBox, Bool, DispatchQueue, escaping, FSEventStreamRef, MainActor, Never (+5 more)

### Community 284 - "click_ui_element"
Cohesion: 0.12
Nodes (16): Darwin, Foundation, Glibc, KouenCore, KouenDaemonCore, OSCTerminatorMatch, daemonLog(), detectStaleInstance() (+8 more)

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.11
Nodes (14): GridCompositor, Bool, Int32, Configuration, SessionGroup, SessionID, Tab, TabID (+6 more)

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.17
Nodes (9): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, FormatColor, String (+1 more)

### Community 287 - ".apply"
Cohesion: 0.18
Nodes (14): decodeBoundedCString(), ignoreSIGPIPE(), makeUnixStreamSocket(), setNoSigPipe(), CChar, Int32, sockaddr, socklen_t (+6 more)

### Community 288 - "AgentHookStrategy"
Cohesion: 0.19
Nodes (8): Logger, OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, Bool, UInt64

### Community 289 - "StatusLineWidthTests"
Cohesion: 0.29
Nodes (4): tool, KouenDaemonToolsTests, String, URL

### Community 290 - "Process"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 291 - "JSONDecoder"
Cohesion: 0.16
Nodes (16): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+8 more)

### Community 292 - "Release runbook"
Cohesion: 0.21
Nodes (8): DaemonMetrics, Snapshot, .meanLockWaitMicros, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.26
Nodes (7): Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 294 - "GitHubCLIClient"
Cohesion: 0.13
Nodes (3): AgentLaunchCommandsTests, URL, Void

### Community 295 - "AgentApprovalBar"
Cohesion: 0.10
Nodes (19): CompleteStepView, Void, OnboardingStep, complete, discover, .id, setup, shell (+11 more)

### Community 296 - "NotificationBus"
Cohesion: 0.15
Nodes (4): cqe(), F7, mathmlBuilder(), UHt()

### Community 297 - "settings.json"
Cohesion: 0.30
Nodes (9): .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release, `repeat`, KeyModifiers, Character, String (+1 more)

### Community 298 - "jobs"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Kouen, Sparkle (+13 more)

### Community 299 - "PaneNode"
Cohesion: 0.11
Nodes (10): WindowInputRouterTests, UInt8, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8 (+2 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.16
Nodes (8): CustomEndpointTester, Result, Bool, String, URL, CustomEndpointTesterTests, URLRequest, URLSession

### Community 301 - ".parse"
Cohesion: 0.17
Nodes (16): SessionRef, byID, byName, next, previous, String, UUID, TargetSpec (+8 more)

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.11
Nodes (12): CodingKeys, error, id, jsonrpc, method, JSONRPCId, int, string (+4 more)

### Community 303 - ".encodeMouse"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 304 - "00-inception-plan.md"
Cohesion: 0.16
Nodes (6): LSPTextLocation, .position, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 305 - ".script"
Cohesion: 0.13
Nodes (13): BinaryInstaller.DetectionStatus, SetupStepView, .canInstall, .hooksDetail, .hooksTone, .hooksValue, .isSuccess, .notifTone (+5 more)

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.18
Nodes (6): DefaultTerminalLaunchRequest, ShellQuoting, Bool, String, URL, DefaultTerminalLaunchRequestTests

### Community 307 - "ViPathTokenTests"
Cohesion: 0.25
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 308 - "Send Ex Command"
Cohesion: 0.11
Nodes (10): KouenOnboarding, GridCompositorParityTests, LiveCompositorFixture, Bool, String, TerminalGridSnapshot, PortCompositorFixture, Bool (+2 more)

### Community 309 - "Browser DevTools API (P28)"
Cohesion: 0.19
Nodes (11): RecordingEvent, input, metadata, output, resize, .timeMs, Date, Decoder (+3 more)

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.36
Nodes (3): OptionStore, OptionStoreTests, URL

### Community 312 - "AgentSnapshot"
Cohesion: 0.31
Nodes (6): Container, .init(coder:), .init(frame:), NSCoder, NSHostingView, NSRect

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.17
Nodes (5): TabID, WorkspaceID, AgentCommandTests, String, Tab

### Community 314 - "code:bash (harness-cli install-hooks codex)"
Cohesion: 0.18
Nodes (15): CellMetrics, ComposedFrame, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth (+7 more)

### Community 315 - "code:bash (harness-cli install-hooks grok)"
Cohesion: 0.25
Nodes (4): PortableRelativeDateFormatter, Date, String, UUID

### Community 316 - "code:bash (harness-cli install-hooks opencode)"
Cohesion: 0.06
Nodes (29): aAn(), ag(), bln(), bwt(), d6e(), d8n(), fun(), i9e() (+21 more)

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.11
Nodes (12): MTLLibrary, MTLRenderPipelineState, ImageTextureCache, MTLDevice, MTLTexture, Set, UInt8, CGFloat (+4 more)

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.17
Nodes (8): AgentListFormatter, Date, String, dvn(), AgentListFormatterTests, Bool, Date, String

### Community 319 - "FormatColor"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.05
Nodes (35): DisplayWidth, String, Unicode, BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts (+27 more)

### Community 321 - "UInt64"
Cohesion: 0.06
Nodes (33): CodingKeys, excludedPaths, id, name, sourceFolder, CodingKey, CodingKeys, createdAt (+25 more)

### Community 322 - "DesktopNotifier"
Cohesion: 0.17
Nodes (3): ShellIntegrationTests, .repoRoot, URL

### Community 323 - "LayoutNode"
Cohesion: 0.30
Nodes (4): TaskStore, tasks, URL, TaskStoreTests

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.37
Nodes (3): AgentLaunchCommands, String, AgentKind

### Community 325 - "FloatingPaneController"
Cohesion: 0.12
Nodes (10): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+2 more)

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.19
Nodes (11): DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String, StyledSegment (+3 more)

### Community 327 - ".theme"
Cohesion: 0.17
Nodes (7): A7(), a8(), c8(), ene(), Gnn, IC(), o8()

### Community 328 - "README.md"
Cohesion: 0.16
Nodes (8): brn, grn, hrn(), JGe(), KGe(), prn(), qGe(), zGe()

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.17
Nodes (4): InputEncoder, InputEncoderTests, String, UInt8

### Community 330 - ".drawGlyph"
Cohesion: 0.19
Nodes (8): Range, String, TerminalGridCell, TerminalBufferMatch, TerminalBufferSearch, String, TerminalGridCell, TerminalBufferSearchTests

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.10
Nodes (17): BoxDrawing, Kind, arms, dashH, dashV, halfDown, halfLeft, halfRight (+9 more)

### Community 332 - "Added"
Cohesion: 0.10
Nodes (20): Agent Safety Net (Checkpoints, Verification, Write Guards), AI Browser Control (kouen-mcp), Build From Source, Claude Code Harness, CLI, Development Builds, Documentation, Editor & LSP (+12 more)

### Community 333 - "RealPty"
Cohesion: 0.11
Nodes (3): Bool, String, UUID

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 336 - "run.sh"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 337 - "CommandExecutionError"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 338 - "CSIParams"
Cohesion: 0.15
Nodes (9): Bool, Int32, String, URL, SystemdUserInstaller, .backendName, .isInstalled, .unitURL (+1 more)

### Community 339 - "Foundation"
Cohesion: 0.11
Nodes (10): ClaudeAdapter, UUID, HeadlessCLIAdapter, HeadlessRunEvent, assistantText, result, sessionID, Bool (+2 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.16
Nodes (16): SwarmFleetSnapshot, SwarmLane, pty, structured, SwarmTaskNode, SwarmTaskStatus, cancelled, failed (+8 more)

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.14
Nodes (8): aD(), ezt(), GGe, Gwe(), Hzt(), Iqt(), Kp(), urn

### Community 342 - "Added"
Cohesion: 0.09
Nodes (14): DetachedPaneOverlay, .init(coder:), .init(frame:style:), Style, detached, reconnectingChip, NSCoder, NSEvent (+6 more)

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.14
Nodes (14): cDt(), dIt(), eD(), f9n(), fIt(), jBe(), MDt(), MF() (+6 more)

### Community 344 - "FileViewerViewController"
Cohesion: 0.15
Nodes (3): CellColorResolverTests, .resolver, CellColorResolver

### Community 346 - "Agent platform icons"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.24
Nodes (9): ANSIPalette, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors, Bool, Double, TerminalGridCell (+1 more)

### Community 348 - "DaemonLifecycleTests"
Cohesion: 0.18
Nodes (11): LayoutFileStore, LayoutNode, branch, leaf, LayoutTemplate, Date, Double, PaneNode (+3 more)

### Community 349 - "Contents.json"
Cohesion: 0.21
Nodes (9): Scanner, .atEnd, SVGPathParser, Bool, CGPath, CGPoint, Character, Set (+1 more)

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.18
Nodes (8): NSHostingView, NSLayoutConstraint, TerminalTabBarView, .delegate, .init(frame:), .leadingInset, .mouseDownCanMoveWindow, .trailingInset

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.25
Nodes (6): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.19
Nodes (9): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+1 more)

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.19
Nodes (13): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Bool, Duration (+5 more)

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.18
Nodes (14): eIt(), F3(), gIt(), H4(), hIt(), jpe(), kIt(), mIt() (+6 more)

### Community 355 - ".deepMerge"
Cohesion: 0.24
Nodes (15): Decodable, AssistantLine, Content, Message, ResultLine, Bool, Double, String (+7 more)

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.21
Nodes (9): NWEndpoint, MobileBridgeServer, Bool, NWListener, Sendable, String, UInt16, start() (+1 more)

### Community 357 - ".handleCat"
Cohesion: 0.24
Nodes (9): Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock, .block(id:) (+1 more)

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.18
Nodes (7): CGFloat, NSColor, NSPoint, NSRect, NSWindow, WindowBorderOverlayView, .windowCornerRadius

### Community 359 - "OcclusionTests"
Cohesion: 0.24
Nodes (3): ShortcutRecorderSerializer, String, ShortcutRecorderSerializerTests

### Community 360 - "State"
Cohesion: 0.15
Nodes (12): MouseButton, left, middle, right, wheelDown, wheelLeft, wheelRight, wheelUp (+4 more)

### Community 362 - "RGBColor"
Cohesion: 0.07
Nodes (15): ScreenPos, bottom, middle, top, KouenLSP, FileGraphInfo, GraphifyLSPBridge, Double (+7 more)

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.13
Nodes (14): ExperienceMode, agent, .displayName, .foregroundsAgents, full, .notchEnabledByDefault, persistent, .persistsSessionsByDefault (+6 more)

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.30
Nodes (4): HookRegistryTests, SeededIDs, URL, UUID

### Community 366 - "Consumers"
Cohesion: 0.22
Nodes (6): ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 367 - "DaemonStats"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 368 - "Tab"
Cohesion: 0.20
Nodes (3): String, TerminalGridSnapshot, VTConformanceCorpusTests

### Community 369 - "Git Panel"
Cohesion: 0.17
Nodes (9): GitStatusProvider, OnceResume, Bool, Duration, String, TimeInterval, GitStatusProviderLargeOutputTests, URL (+1 more)

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.18
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.12
Nodes (22): CustomStringConvertible, DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed, atomicWrite() (+14 more)

### Community 373 - "Prompt"
Cohesion: 0.12
Nodes (5): KouenCLI, HistorySearchQueryTests, MemoCommandTests, URL, TaskCommandTests

### Community 375 - ".install"
Cohesion: 0.31
Nodes (3): KeyTokenParser, Bool, String

### Community 376 - "ScrollReuseTests"
Cohesion: 0.12
Nodes (16): Command, .targetKind, PaneRef, bottom, byID, byIndex, last, left (+8 more)

### Community 377 - "Identifiable"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.15
Nodes (5): OnboardingController, CompletionGenerator, String, .fishCompletionSource, CompletionGeneratorTests

### Community 379 - "MCPServer"
Cohesion: 0.19
Nodes (8): AgentRemoteControlDaemonService, Set, String, Void, AgentRemoteControlDaemonServiceTests, LogBox, .count, String

### Community 380 - "PromptQueue"
Cohesion: 0.29
Nodes (4): SwarmDAGStore, String, UUID, SwarmDAGStoreTests

### Community 381 - "smoke-dmg.sh"
Cohesion: 0.18
Nodes (14): Array, Bool, Date, Decoder, PaneID, PaneNode, String, TabID (+6 more)

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.26
Nodes (3): String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.20
Nodes (16): Close Pane, Next Session, Previous Session, Split Down, Split Right, Cmd W Closes Pane When Split, Zombie Crash Rapid Split Close Cycle, Close Pane Removes Split (+8 more)

### Community 385 - "INDEX.md"
Cohesion: 0.18
Nodes (8): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.27
Nodes (8): LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab, TabID, WorkspaceID

### Community 387 - "User Profile"
Cohesion: 0.11
Nodes (21): Color, .hexString, KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String (+13 more)

### Community 388 - "Darwin"
Cohesion: 0.19
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 389 - "HarnessCLITests"
Cohesion: 0.20
Nodes (3): ClaudeCodeHarnessIPCTests, String, URL

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.14
Nodes (14): CompletionPopupView, .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:), .isHovered, Bool (+6 more)

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.31
Nodes (9): CGFloat, Range, Tab, TabBarLayoutMetrics, .pitch, tabDisplayTitle(), TerminalTabBarBody, .body (+1 more)

### Community 392 - "build-release.sh"
Cohesion: 0.18
Nodes (8): Date, Never, Task, Void, TabPillView, .pillBorder, .workingDot, Gesture

### Community 393 - "create-dmg.sh"
Cohesion: 0.12
Nodes (15): agy, claude, codex, copilot, hermes, kouen, __kouen_agy_next, __kouen_claude_next (+7 more)

### Community 394 - "finalize-release.sh"
Cohesion: 0.17
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, Bool, Double (+3 more)

### Community 396 - "generate-appcast.sh"
Cohesion: 0.19
Nodes (10): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+2 more)

### Community 397 - "measure-fluidity.sh"
Cohesion: 0.26
Nodes (8): InstallResult, Shell, bash, fish, zsh, ShellIntegration, Bool, URL

### Community 398 - "preview.sh"
Cohesion: 0.25
Nodes (8): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String

### Community 399 - "sign-and-notarize.sh"
Cohesion: 0.18
Nodes (13): Profile, edit, readonly, Run, RunState, cancelled, failed, running (+5 more)

### Community 400 - "install-linux.sh"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 401 - "package-app.sh"
Cohesion: 0.31
Nodes (5): IssueTrackerPanelView, .body, .filteredIssues, .statusBannerText, String

### Community 402 - "View"
Cohesion: 0.37
Nodes (3): .block(atPromptLine:), String, TerminalBlockStoreTests

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
Cohesion: 0.17
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

### Community 408 - "IPC Architecture"
Cohesion: 0.11
Nodes (10): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, KouenApp, KouenSyntaxResources (+2 more)

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.17
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 410 - ".applyTerminalIdentity"
Cohesion: 0.20
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.22
Nodes (7): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController

### Community 412 - "go.json"
Cohesion: 0.14
Nodes (13): SwarmFleetView, .init(coder:), CGFloat, NSCoder, CGFloat, NSCoder, SessionID, Void (+5 more)

### Community 413 - "javascript.json"
Cohesion: 0.22
Nodes (10): DotView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor, NSRect (+2 more)

### Community 414 - "json.json"
Cohesion: 0.23
Nodes (13): kouen.bash script, agy(), claude(), codex(), copilot(), hermes(), kouen(), __kouen_agy_next() (+5 more)

### Community 415 - "markdown.json"
Cohesion: 0.21
Nodes (10): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+2 more)

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.19
Nodes (6): ListeningPortScanner, Int32, Set, String, result, ListeningPortScannerTests

### Community 417 - "rust.json"
Cohesion: 0.22
Nodes (5): RepoResolver, Bool, String, RepoResolverTests, String

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.22
Nodes (7): clamp(), statusColor(), Configuration, T, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, .dragGesture

### Community 419 - "typescript.json"
Cohesion: 0.20
Nodes (13): ern(), G4(), G7(), Jnn(), nrn(), Qnn(), sHe(), trn() (+5 more)

### Community 420 - "yaml.json"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 422 - "HintModeOverlay"
Cohesion: 0.22
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 423 - "SixelDecoder"
Cohesion: 0.14
Nodes (5): HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 424 - ".parseDiffHunks"
Cohesion: 0.26
Nodes (14): Agent Command Does Not Crash, Agent Waiting Filter Does Not Crash, Board Command Shows Board Panel, Cd Command Switches To Matching Tab, Copy Path Command Does Not Crash, Errors Command Does Not Crash, Find Command Opens Command Palette On Empty Query, Find Command Resolves Unique File (+6 more)

### Community 425 - "AgentVectorIcon"
Cohesion: 0.24
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 427 - ".delay"
Cohesion: 0.27
Nodes (6): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection

### Community 428 - "TaskDashboardView"
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.24
Nodes (6): bUt(), FBe(), Gbe(), handler(), mUt(), _Q()

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.11
Nodes (19): SurfaceProgressTracker, Bool, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void, State (+11 more)

### Community 431 - "BoardCardView"
Cohesion: 0.21
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 432 - "PathToken"
Cohesion: 0.27
Nodes (7): Never, Set, String, Task, URL, Void, WorkspaceSymbolIndex

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.22
Nodes (4): JSONDecoder, JSONEncoder, Encoder, TerminalRecordingCodec

### Community 434 - "Project History"
Cohesion: 0.25
Nodes (6): OptionSet, .description, .init(key:modifiers:), Modifiers, String, UInt8

### Community 435 - ".init"
Cohesion: 0.24
Nodes (8): ProjectDropTarget, .init(coder:), .init(frame:), NSCoder, NSDraggingInfo, NSDragOperation, NSRect, URL

### Community 436 - "WaitForRegistry"
Cohesion: 0.34
Nodes (3): Install, Shell integration (OSC 133 semantic prompts), What gets emitted

### Community 437 - "PickerItemRow"
Cohesion: 0.14
Nodes (14): Agent handbook — Kouen (extended reference), Agent integration, Build and test, IPC, Keyboard shortcuts, kouen-cli, Native terminal renderer, Repository map (+6 more)

### Community 438 - "SessionEditor"
Cohesion: 0.22
Nodes (9): B3(), dFe(), _Dt(), fFe(), lFe(), _Ot(), sD(), TOt() (+1 more)

### Community 439 - "SetupStepView"
Cohesion: 0.41
Nodes (7): FeatureSummary, FeatureTaskSummary, GateSummary, Bool, Date, String, UUID

### Community 440 - "LegacySnapshot"
Cohesion: 0.25
Nodes (6): BrowserProgressLine, .init(coder:), .init(frame:), Double, NSLayoutConstraint, NSRect

### Community 441 - "RemoteHostStore"
Cohesion: 0.23
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 443 - "main.swift"
Cohesion: 0.25
Nodes (4): _c(), Nn(), Pqe, qp()

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.31
Nodes (4): crn, ELt(), n2e(), PF()

### Community 445 - "Section"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 446 - "Modifiers"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 447 - "PaletteMode"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.15
Nodes (11): copyMode, esc(), fs, globalShortcuts, KEYBINDINGS, prefixTable, renderTable(), ROOT (+3 more)

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.33
Nodes (3): String, Tab, WorktreeAutoIsolateServiceTests

### Community 451 - ".run"
Cohesion: 0.30
Nodes (5): SearchBenchmarks, String, UInt64, URL, Void

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.25
Nodes (4): StatusLineWidthTests, StatusLineWidth, String, StyledSegment

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.21
Nodes (6): String, TerminalGridCell, TextGrid, .totalLines, .viewportRows, WordColumnRangeTests

### Community 455 - "ComposerPanel"
Cohesion: 0.18
Nodes (13): Branch Change In Shared Folder Is Not Isolated Unprompted, CLI Isolate Creates Worktree And Session, CLI Isolate With Custom Branch Name, Close Session Keeps Dirty Worktree, Close Session Removes Clean Worktree, Create Isolated Session And Select, Git Checkout In Normal Session Does Not Affect Isolated, Isolate Without Branch Uses Detached HEAD (+5 more)

### Community 456 - "TerminalModes"
Cohesion: 0.17
Nodes (9): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 457 - ".normalizedKey"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 458 - "FileTreeKeyboardNavigator"
Cohesion: 0.15
Nodes (6): Security, KouenMCPServer, Bool, String, MCPServer, String

### Community 459 - ".encode"
Cohesion: 0.27
Nodes (5): String, TaskDashboardBody, .body, String, TaskDashboardGroupingTests

### Community 460 - "RunState"
Cohesion: 0.23
Nodes (9): AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor (+1 more)

### Community 461 - ".worktreeList"
Cohesion: 0.21
Nodes (5): FDWatchdog, DispatchSourceTimer, String, TimeInterval, FDWatchdogTests

### Community 462 - "AGENTS.md"
Cohesion: 0.16
Nodes (11): Status, ciFailing, done, mergeReady, open, running, Bool, Date (+3 more)

### Community 463 - ".deinit"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 464 - "MouseButton"
Cohesion: 0.18
Nodes (6): eKe(), irn(), mrn, _rn(), rrn(), srn()

### Community 465 - "DirectionalAxis"
Cohesion: 0.19
Nodes (5): TerminalGridSnapshot, TerminalGridSnapshot, ReflowPreviewTests, .feeds, String

### Community 466 - "PlatformSys.swift"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 467 - ".moveSelection"
Cohesion: 0.12
Nodes (5): FormatStyle, FormatColor, StyledSegment, FormatStyledTests, .ctx

### Community 468 - "Never"
Cohesion: 0.26
Nodes (3): BellScanTests, Bool, UInt8

### Community 469 - "PresentAttempt"
Cohesion: 0.26
Nodes (4): PaneLabelDaemonTests, String, URL, UUID

### Community 471 - ".evaluateStyled"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 472 - "start.sh script"
Cohesion: 0.29
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 473 - "HarnessOnboarding"
Cohesion: 0.25
Nodes (6): Kind, input, metadata, output, resize, ReplayStep

### Community 474 - "String"
Cohesion: 0.17
Nodes (5): DirectionalAxis, down, left, right, up

### Community 475 - ".hitTest"
Cohesion: 0.23
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 476 - "ProjectDropTarget"
Cohesion: 0.30
Nodes (7): Bool, NSPasteboard, NSString, String, URL, TerminalServicesProvider, AutoreleasingUnsafeMutablePointer

### Community 477 - ".encode"
Cohesion: 0.55
Nodes (5): AgentIconRenderer, CGFloat, NSColor, NSImage, String

### Community 478 - ".install"
Cohesion: 0.17
Nodes (10): .init(frame:), .webView(_:decidePolicyFor:decisionHandler:), .webView(_:didFinish:), MainActor, NSRect, WKNavigation, WKNavigationAction, WKWebView (+2 more)

### Community 479 - "ScrollbackTests"
Cohesion: 0.08
Nodes (14): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess, BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool (+6 more)

### Community 480 - "Command Prompt Architecture"
Cohesion: 0.32
Nodes (8): bFe(), clamp(), formatHsl(), jDt(), tFe(), vFe(), XY(), YY()

### Community 481 - ".testKouenRendererFixtureDefaultTextReportsPlausibleGlyphStats"
Cohesion: 0.40
Nodes (4): SplitDirection, TabID, .body, TerminalTabBarDelegate

### Community 482 - ".resolve"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 483 - "Changed"
Cohesion: 0.17
Nodes (11): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile, regionEdit (+3 more)

### Community 484 - "CopilotAdapter"
Cohesion: 0.24
Nodes (9): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+1 more)

### Community 485 - ".testKouenRendererFixtureLigatureShapingPathReportsPlausibleGlyphs"
Cohesion: 0.20
Nodes (8): InstallResult, ShellCompletionInstaller, Bool, String, URL, ShellCompletionInstallerTests, String, URL

### Community 487 - "bC"
Cohesion: 0.26
Nodes (5): Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 488 - "ccRunCancel"
Cohesion: 0.13
Nodes (11): Am(), bze(), Cm(), EQ(), Hm(), Im(), lte(), MBe() (+3 more)

### Community 489 - "SurfaceIO"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 490 - "ccRunGet"
Cohesion: 0.17
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 491 - ".update"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 493 - "ccRunStart"
Cohesion: 0.25
Nodes (3): EndpointClientTests, String, URL

### Community 495 - ".makeDiffScrollView"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 497 - ".bind"
Cohesion: 0.24
Nodes (11): Close Tab, New Tab, Cmd Shift W Force Closes Tab, Cmd T Creates New Session, Cmd W Closes Tab When Single Pane, Window Survives Full Shortcut Sequence, Zombie Crash Close Tab While Typing, Zombie Crash Rapid Close While Typing (+3 more)

### Community 498 - ".automationList"
Cohesion: 0.20
Nodes (9): AnyObject, CommandExecutionError, daemonError, .description, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor (+1 more)

### Community 499 - "ProjectConfig"
Cohesion: 0.24
Nodes (5): RiskyCommandClassifier, Bool, NSRegularExpression, String, RiskyCommandClassifierTests

### Community 500 - "zO"
Cohesion: 0.39
Nodes (5): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID

### Community 501 - "Fixed"
Cohesion: 0.31
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 502 - "ACP Client (Shelved)"
Cohesion: 0.25
Nodes (7): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, NSEvent

### Community 504 - "WindowBorderOverlayView"
Cohesion: 0.18
Nodes (10): Architecture Decisions (dated log), Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Post-P50 changes (v4.20.2 → v4.20.11, 2026-10-01 → 2026-10-06), Product Identity Guardrail: Terminal, Not IDE, Shipped capability summary, P44–P49 (2026-08-31 → 2026-09-23) (+2 more)

### Community 505 - ".tickFeatureWorktreeSweepLocked"
Cohesion: 0.20
Nodes (8): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, ClosedRange, String

### Community 506 - "SwarmFleetBody"
Cohesion: 0.45
Nodes (3): data, SixelDecoder, UInt8

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 508 - "qLt"
Cohesion: 0.12
Nodes (7): TerminalGridSnapshot, KouenTerminalSurfaceWorkerTests, Bool, OcclusionTests, NSWindow, String, TimeInterval

### Community 510 - "PromptQueue"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 511 - ".panePathLookup"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 512 - ".setAttribute"
Cohesion: 0.18
Nodes (5): FormatContextDaemonTests, PaneID, String, SurfaceID, URL

### Community 513 - "ThemeDocument"
Cohesion: 0.18
Nodes (3): MobileBridgeAttachFileTests, String, URL

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 515 - "RD"
Cohesion: 0.18
Nodes (10): Bug 1 - Rotation Grace Slot Keeps The Previous Token Redeemable, Bug 1 - Rotation Shifts The Outgoing Token Into The Grace Slot, Bug 1 - Stop Fully Clears The Grace Slot, Bug 1 - Token Lifetime Not Regressed Below The Human-Flow Window, Bug 2 - Client onerror Does Not Clobber The Server Error Banner, Bug 2 - No Abrupt Cancel Immediately After The Error Text, Bug 2 - Reject Path Closes Gracefully With Policy-Violation Code 1008, Bug 3 - QR Not Printed When No Listener Is Ready (+2 more)

### Community 516 - "terminal_stress_runner.py"
Cohesion: 0.21
Nodes (8): PaneOutputWaiter, PaneOutputWaitResult, Bool, CheckedContinuation, Never, PaneLeaf, Tab, UInt64

### Community 517 - "GroupedSessionDaemonTests"
Cohesion: 0.29
Nodes (7): AnimatablePair, NotchShape, .animatableData, CGFloat, CGPath, CGRect, Path

### Community 519 - ".gestureRecognizer"
Cohesion: 0.24
Nodes (3): TabID, WorkspaceID, GitPanelViewWorktreeNavigationTests

### Community 520 - "WriteOutcome"
Cohesion: 0.21
Nodes (3): SessionID, KouenCommands, GitPanelViewWorktreeTaskTests

### Community 522 - "ShellCompletionInstallerTests"
Cohesion: 0.24
Nodes (9): .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didStartProvisionalNavigation:), LoadCompletionState, Bool, CheckedContinuation, Error, TimeInterval (+1 more)

### Community 523 - "fFe"
Cohesion: 0.29
Nodes (7): blockTokens(), inlineTokens(), lex(), lexer(), lexInline(), me(), reflink()

### Community 524 - "TerminalColorRole"
Cohesion: 0.22
Nodes (7): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, NSCoder, Void

### Community 525 - ".encodeAndWait"
Cohesion: 0.24
Nodes (3): KouenMCP, KouenBrowserToolsTests, URL

### Community 526 - "Kind"
Cohesion: 0.31
Nodes (4): GraphifyIndexCache, S, Set, String

### Community 527 - ".show"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 528 - "worktree_review_dashboard.robot"
Cohesion: 0.31
Nodes (5): AgyAdapter, Result, ResultLine, String, UUID

### Community 529 - "WorktreeAutoIsolateService"
Cohesion: 0.29
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

### Community 530 - "HarnessChrome"
Cohesion: 0.24
Nodes (11): a2(), akn(), ift(), p7n(), R1(), rht(), tun(), ubt() (+3 more)

### Community 531 - "BrowserProgressLine"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 532 - "OpenClaw → Kouen"
Cohesion: 0.29
Nodes (8): FormatColor, none, palette, rgb, StyledSegment, Bool, String, UInt8

### Community 533 - "flushSessionState"
Cohesion: 0.27
Nodes (3): DaemonReconnectPolicy, TimeInterval, DaemonReconnectPolicyTests

### Community 534 - ".zoomWindowIfDoubleClick"
Cohesion: 0.14
Nodes (11): InputGate, .siblings, OutputCoalescer, SurfaceIO, .currentSubscription, SurfaceID, UInt16, UInt64 (+3 more)

### Community 536 - ".readGrid(scrollbackOffset:)"
Cohesion: 0.18
Nodes (4): ClaudeSessionMode, ClaudeSessionModeTests, URL, Void

### Community 537 - "NSObject"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 539 - "install-app.sh"
Cohesion: 0.11
Nodes (8): GroupedSessionDaemonTests, SessionGroup, String, URL, MobileBridgeSpawnTests, String, URL, skipUnlessLiveDaemonTests()

### Community 540 - ".applyStyleDirective"
Cohesion: 0.24
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 541 - ".init"
Cohesion: 0.27
Nodes (9): Command Prompt, Find In Files, Git Panel, Open Command Palette, Switch To Session 1, Switch To Session 2, Rapid Session Switch While Typing, Switch Between Isolated And Normal Session (+1 more)

### Community 542 - ".init(from:)"
Cohesion: 0.33
Nodes (4): GridCompositorCopyModeTests, PaneRect, String, TerminalGridSnapshot

### Community 543 - ".bufferLine"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 544 - "CodingKeys"
Cohesion: 0.36
Nodes (5): PaneLeaf, SessionGroup, Any, String, Tab

### Community 545 - ".characterIndex"
Cohesion: 0.29
Nodes (7): GRt(), n4e(), p7e(), r2(), tl(), vrt(), xq()

### Community 546 - "LegacySnapshot"
Cohesion: 0.39
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 548 - ".encode"
Cohesion: 0.36
Nodes (4): Bool, String, UUID, TaskDaemonBridge

### Community 549 - ".init(from:)"
Cohesion: 0.50
Nodes (4): jQt(), qee(), w1(), XD()

### Community 550 - ".init(hex:)"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 551 - ".init(red:green:blue:alpha:)"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Key spec syntax, Kouen keybindings, Persistence (+1 more)

### Community 553 - "harness.resource"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 554 - "eFe"
Cohesion: 0.33
Nodes (4): OutputTrigger, OutputTriggerStore, Bool, String

### Community 555 - "code:bash (harness view <file>                        # syntax-highligh)"
Cohesion: 0.18
Nodes (8): ClaudeRunSummary, Date, Double, Int32, String, UUID, String, UUID

### Community 556 - "sBt"
Cohesion: 0.25
Nodes (6): calculate(), constructor(), kOt(), mBt, r2e(), sOt()

### Community 557 - ".viewWillMove"
Cohesion: 0.22
Nodes (8): Build order (unchanged from interview decision), G1 — @ file-path picker, G2 — shell tab-completion suggestion strip (heuristic, explicitly best-effort), G3 — AI command suggestion (via `claude` CLI subprocess), Logical Design, P37 Phase G — Autocomplete (mobile bridge), Strategic Design, Tactical Design

### Community 558 - "FindWindowMatcherTests"
Cohesion: 0.22
Nodes (8): Artifacts, Client Application — Slice 1 (stacked panes, no persistence), Client Application — Slice 2 (per-workspace divider memory), Context, Dev Task Progress — Workspace Sidebar Panels (P42), Integration, Note on task re-sequencing (2026-07-17), Summary

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 560 - "LayoutTemplate"
Cohesion: 0.31
Nodes (6): TerminalGridCell, ThaiClusterCopyTests, ThaiGrid, .columns, .totalLines, .viewportRows

### Community 561 - ".handleClaudeCode"
Cohesion: 0.23
Nodes (4): GroupedSessionTests, SessionGroup, Set, SurfaceID

### Community 563 - "AgentNotchViewModel.swift"
Cohesion: 0.33
Nodes (6): DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed

### Community 564 - "📁 IDE Sidebar"
Cohesion: 0.22
Nodes (8): MCP Control Allowed With Env Var, MCP Control Denied Without Env Var, MCP KouenBoard Returns Columns, MCP KouenList Returns Sessions, MCP ReadPaneOutput Returns Content, Run MCP Request, Run MCP Request Allowed, Run MCP Request Denied

### Community 566 - "TerminalTabBarView.swift"
Cohesion: 0.25
Nodes (6): String, URL, ThemeCatalogEmbedTests, .embedSwift, .repoRoot, .sourceJSON

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.36
Nodes (7): Document, Bool, Set, String, URL, ToolPolicy, .defaultURL

### Community 568 - ".gestureRecognizer"
Cohesion: 0.25
Nodes (7): Agent Memory, Graphify, graphify, kouen-terminal — Agent Instructions, Rules (read when triggered), Session Start, Skills & Rules

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.33
Nodes (5): TokenCheck, accepted, expired, mismatch, noActivePairing

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 571 - "ShellIntegrationTests"
Cohesion: 0.43
Nodes (3): .agentInfo(forWorktreePath:tabs:), Tab, GitPanelViewWorktreeAgentTests

### Community 573 - "main.swift"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 574 - ".applyFontSize"
Cohesion: 0.25
Nodes (8): A `claude` typed by hand, Claude Code → Kouen, Customizing, One-line install, Session mode: Remote Control / cloud / local, The reverse direction: a session opened in Claude showing up in Kouen, Verifying, What gets written

### Community 575 - ".toastErrorSummary"
Cohesion: 0.32
Nodes (4): PaneID, SessionGroup, Tab, first

### Community 576 - "Phase67Tests"
Cohesion: 0.25
Nodes (8): CodingKeys, cols, createdAt, dataBase64, rows, timeMs, type, version

### Community 577 - "SwarmFleetView"
Cohesion: 0.32
Nodes (6): CGFloat, ResizeDirection, down, left, right, up

### Community 578 - "TaskDashboardBody"
Cohesion: 0.39
Nodes (5): AutomationSummary, Bool, Date, String, UUID

### Community 579 - "main.swift"
Cohesion: 0.33
Nodes (5): PendingVersionBanner, welcome, whatsNew, State, String

### Community 583 - "WorkbenchMRU"
Cohesion: 0.40
Nodes (5): Motion, .reduce, .spring, Animation, Bool

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

### Community 591 - "stability_release.robot"
Cohesion: 0.25
Nodes (7): Browser Pane Open Close Rapid, File Preview Open Close, Git Fetch Shows Toast, Launch Kouen Staging, Memory Stability After 30 Seconds, Quit Kouen Staging, Sidebar Toggle Immediately After Launch

### Community 594 - "r2"
Cohesion: 0.25
Nodes (6): block, lineFilter, md, page, script, swift

### Community 597 - "TerminalColorRole"
Cohesion: 0.38
Nodes (4): AnyObject, TimeInterval, ZombieHoldRegistry, ObjectIdentifier

### Community 598 - "AgentBadgeView"
Cohesion: 0.38
Nodes (5): .body, AgentBadgeView, .body, Bool, CGFloat

### Community 601 - "Hwe"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 602 - "Build locally"
Cohesion: 0.29
Nodes (7): Agent hooks for Kouen, CLI notification, Example Claude Code hook, Jump to waiting agent, OSC sequences (from terminal output), Per-agent guides, Set up via your IDE (copy/paste prompt)

### Community 603 - "fut"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 604 - "k0t"
Cohesion: 0.29
Nodes (7): 1. Plain Terminal, 2. Persistent Terminal, 3. Full Terminal, 4. Agent Workspace, Experience modes, Opting into the prefix + status line without switching modes, Persistence (ephemeral vs. persistent)

### Community 605 - "drn"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Kouen-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 606 - "Quick start"
Cohesion: 0.50
Nodes (3): azt(), ibe(), q$e()

### Community 607 - "iRe"
Cohesion: 0.50
Nodes (3): i5e(), ort(), wHt()

### Community 608 - "W2"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 609 - "FormatContextDaemonTests"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 610 - "TabStatus"
Cohesion: 0.20
Nodes (8): statusHelp(), String, TabStatus, done, error, idle, running, waiting

### Community 611 - ".showWorkspaceMenu"
Cohesion: 0.57
Nodes (3): ProjectConfig, Bool, String

### Community 612 - ".init(coder:)"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 614 - "MainSplitViewController"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

### Community 615 - "fences"
Cohesion: 0.29
Nodes (6): .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8

### Community 616 - "bump-version.sh"
Cohesion: 0.29
Nodes (6): Locked decisions (user-confirmed), Logical Design, P38 Phase A — Cross-Agent Worktree Diff/Review Dashboard — Design, Strategic Design, Tactical Design, Verification gate (this phase)

### Community 617 - "ScriptFileWatcher"
Cohesion: 0.29
Nodes (6): Logical Design, Next Step, P42 — Workspace Sidebar Panels, Parked (not in scope), Strategic Design, Tactical Design

### Community 618 - "parse"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 620 - "mS"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 621 - "ViEngine"
Cohesion: 0.38
Nodes (6): Cleanup And Quit, Create Config File, No Config File Starts Normally, Script Hot Reload On Save, Script Loads On Startup, Script Syntax Error Does Not Crash

### Community 623 - "BrowserResponsePayload"
Cohesion: 0.29
Nodes (6): Bug 1 - Browser Pane Deferred Unregister, Bug 1 - Browser Pane Reuse On Rebuild, Bug 2 - New Session Syncs Before Reading Active Tab, Bug 2 - Tab Bar New Tab Also Syncs, Bug 3 - Browser Pane Forces Redraw On Reattach, Build Compiles Successfully

### Community 625 - "brt"
Cohesion: 0.47
Nodes (5): AgentIconArt, AgentVectorIcon, Bool, CGSize, String

### Community 628 - "ReplayStep"
Cohesion: 0.09
Nodes (19): OverlayBackground, Context, OverlayBackground, Context, AgentChipView, .init(coder:), .intrinsicContentSize, .init(coder:) (+11 more)

### Community 633 - "g_n"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 634 - "qC"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase D — Kitty Graphics Conformance Slice, Scope (locked), Tests

### Community 635 - "yDt"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua), Scope (locked), Tests

### Community 636 - ".handleCopyModeKey"
Cohesion: 0.33
Nodes (5): Logical Design, Next Step, P43 — Add Repo/Folder to Workspace, Strategic Design, Tactical Design

### Community 637 - "ClientSummary"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 640 - "zpt"
Cohesion: 0.47
Nodes (3): URL, TimeoutError, WorktreeLargeOutputRegressionTests

### Community 641 - "[3.10.0] - 2026-06-27"
Cohesion: 0.33
Nodes (5): Kouen LSP Diagnostics Does Not Crash, Kouen LSP Hover Returns Result, Kouen LSP Start Returns JSON, Kouen View Binary Shows Guard Message, Kouen View Prints File Content

### Community 642 - "qut"
Cohesion: 0.67
Nodes (3): AsyncCLIResultBox, Error, Result

### Community 644 - "clean-state.sh"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 647 - "graphify reference: query, path, explain"
Cohesion: 0.22
Nodes (8): ArtifactKind, html, image, markdown, text, AutomationSource, daemon, launchAgent

### Community 649 - "h$t"
Cohesion: 0.40
Nodes (4): Findings, Sources, What this means for Kouen, Who creates branches / worktrees in AI coding tools

### Community 650 - "hjt"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: animateSidebar setContentLeadingInset MainSplitViewController, Source Nodes

### Community 651 - "u0n"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: ProjectCategory FolderScanner ProjectDirectoryTree, Source Nodes

### Community 652 - "TerminalHostView"
Cohesion: 0.40
Nodes (5): WrapperOptionBehavior, keepScanning, matchValue, skipValue, stopScanning

### Community 653 - "iOn"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 654 - "BlockContextMenuTests"
Cohesion: 0.40
Nodes (5): ColorKind, .base, bg, fg, underline

### Community 659 - "MobileBridgeBrowserTests"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 660 - "qAn"
Cohesion: 0.60
Nodes (3): .encode(_:modifiers:event:modes:), SpecialKey, insert

### Community 661 - ".compute"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 662 - "New Tab"
Cohesion: 0.40
Nodes (4): Build, Release & Git Workflow, Build / Test / Run, Release packaging order, Worktree constraint

### Community 663 - "m6e"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 664 - "P37 Phase G — Autocomplete (mobile bridge)"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 665 - "nb"
Cohesion: 0.70
Nodes (4): main(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 666 - "BrowserIntegrationController"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 667 - "[3.3.0] - 2026-06-18"
Cohesion: 0.40
Nodes (4): Leak A - Retiring A Host Drops Its AI Controllers, Leak B - Browser Network Capture Is Bounded, Leak C - Every Per-Surface Dict In Coordinator Has Retire Cleanup, Leak D - Every Per-Surface Dict In NotificationCoordinator Is Snapshot-Swept

### Community 672 - "ColorKind"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

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

### Community 678 - "FormatColor"
Cohesion: 0.50
Nodes (4): WriteOutcome, complete, failed, wouldBlock

### Community 679 - "TransportError"
Cohesion: 0.50
Nodes (3): SplitDirection, horizontal, vertical

### Community 681 - ".tabIDsToNotify"
Cohesion: 0.50
Nodes (4): dO(), m8(), rfn(), zfn()

### Community 683 - "hJ"
Cohesion: 0.67
Nodes (4): FVe(), hJ(), qVe(), Zme()

### Community 684 - "New Tab"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 686 - "I$e"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 687 - "FormatStringExtendedVariableTests"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 688 - "LayoutProbeView"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 690 - ".update"
Cohesion: 0.50
Nodes (3): Bug 1 - Hunks Button Has Explicit Size Constraints, Bug 1 - Hunks Button Symbol Has A Guaranteed-Valid Fallback, Build Compiles Successfully

### Community 691 - ".stopProjectScript"
Cohesion: 0.50
Nodes (3): Guard - Branch Change Only Publishes A Notice, Guard - Isolate Is Only Reachable From The Notice Action, Guard - WorktreeAutoIsolateService Is Actually Started At Launch

### Community 692 - ".control"
Cohesion: 0.50
Nodes (3): Guard A - Merge Call Site Never Passes --no-ff, Guard B - No Auto-Resolve Anywhere In The Merge/Conflict Path, Guard C - Merge Conflict State Is Reconciled, Not Just Read Once

### Community 701 - ".testOccludedPaneParsesButNeverPresents"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 702 - "PromptQueue"
Cohesion: 0.67
Nodes (3): cat(), Hwe(), kYe()

### Community 703 - "ColorKind"
Cohesion: 0.67
Nodes (3): cfn(), fut(), qYe()

### Community 704 - ".taskUpdate"
Cohesion: 0.67
Nodes (3): dht(), k0t(), l1n()

### Community 706 - "[2.5.1] - 2026-06-12"
Cohesion: 0.67
Nodes (3): iRe(), jNt(), zNt()

## Knowledge Gaps
- **2366 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+2361 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1104 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `Sendable` to `.handleNormal`, `graphify reference: extra exports and benchmark`, `terminal_stress_runner.py`, `IPCRequest`, `PerformanceBenchmarks`, `GitPanelView.swift`, `KittyKeyboardTests`, `VTParser`, `HarnessTerminalSurfaceView`, `.show`, `WorktreeAutoIsolateService`, `HarnessUILibrary`, `SpecialKey`, `OpenClaw → Kouen`, `HarnessTerminalSurfaceView`, `CopyModeAction`, `SplitPaneCoordinator`, `.request`, `WorktreeManager`, `flushSessionState`, `RGBColor`, `.zoomWindowIfDoubleClick`, `Added`, `Notification`, `Harness tmux-style capabilities`, `.init(from:)`, `Equatable`, `DaemonClient`, `.bufferLine`, `String`, `code:bash (swift build)`, `TerminalColorGamut`, `CodingKeys`, `HarnessSidebarPanelViewController.swift`, `RenderSchedulerTests`, `HarnessTerminalSurfaceView.swift`, `.buildCommand`, `.normalizedKey`, `HookEvent`, `DaemonServer`, `Added`, `.keyEvent`, `LayoutTemplate`, `Added`, `HarnessSplitView`, `TabCell`, `NSPanel`, `Cross-terminal output-stress benchmark`, `ViEngine`, `LayoutProbeView`, `FrecencyDirectoryStore`, `.toastErrorSummary`, `.text`, `SwarmFleetView`, `ShellIntegration`, `String`, `ComposedCell`, `main.swift`, `TaskDashboardBody`, `PrefixKeymap`, `XCTestCase`, `README.md`, `[2.6.0] - 2026-06-13`, `OptionStore`, `TerminalProtocolCompatibilityTests`, `Added`, `HarnessDesign`, `DaemonSubscription`, `LSPDiagnostic`, `.groupByRoot`, `.cursorPos`, `Zombie View Crashes on macOS 26.5 + Swift 6.3.2`, `TerminalModes`, `AttachInputBatcher`, `shim.c`, `Harness Usage`, `W2`, `4. Technical Architecture`, `.dispatch`, `ScriptRuntime.swift`, `DaemonLauncher`, `fences`, `Changelog`, `domain-design.md`, `parse`, `DamageTrackingTests`, `SoftIconButton`, `[2.5.0] - 2026-06-12`, `.tabIndex(tabID:)`, `.firstWaitingTab`, `.encode`, `SessionGroup`, `WorkspaceFileTreeView`, `Added`, `Changed`, `ViEngine`, `.currentSize`, `GlyphAtlas`, `zpt`, `SwiftUI`, `qut`, `.install`, `AgentHookInstaller`, `.load`, `.startWatching`, `ActivePaneService`, `.testPaneLeafLegacyDecodeBackfillsSurfaceTabs`, `CopyModeGridSource`, `How to use Harness from the terminal only (no GUI)`, `PaneStyleSet`, `AsciiFastPathTests`, `iOn`, `BlockContextMenuTests`, `DecodedImage`, `EnvironmentStore`, `HarnessDaemonToolsTests`, `.evaluate`, `Added`, `What You Must Do When Invoked`, `.compute`, `Int`, `ThaiCombiningMarkTests`, `Added`, `pie`, `Harness Terminal — IDE Sidebar Feature Branch`, `MatchCategory`, `What You Must Do When Invoked`, `TerminalFindBar`, `CommandPromptController`, `AgentTableEntry`, `Added`, `.apply`, `.decodeKeySpec`, `BoardCard`, `BinaryRefresherTests`, `Added`, `.rects`, `[3.13.1] - 2026-07-02`, `GridCompositorTests`, `FormatContext`, `LSPServerRegistry`, `targets`, `SessionSnapshot`, `Motion`, `P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client`, `.setCellPixelSize`, `ScriptRuntime`, `String`, `.classify`, `MainWindowController`, `BinaryInstallerVersionTests`, `PaletteModel`, `From tmux`, `PaneDropZoneOverlay`, `.translate`, `CellColorResolverTests`, `GridCompositor`, `TerminalHostView`, `AgentNotchRowSummary`, `ANSIPalette`, `FileChangeWatcher`, `sessionRow`, `.decide`, `P10 Task: Lazy Scrollback Reflow`, `TextGrid`, `.scan`, `WorkbenchCommand`, `TerminalBlockStoreTests`, `TerminalMetalRenderer`, `PaneBorderStatus`, `.make`, `.init`, `.resize`, `HarnessTerminalSurfaceWorkerTests`, `SessionCoordinator`, `Split Right`, `release-hotfix.sh`, `Sidebar SwiftUI Migration — Knowledge`, `run.sh`, `.install`, `HarnessSidebarPanelViewController`, `cpn`, `code:bash (harness-cli install-hooks cursor)`, `.path`, `Browser Pane (P14)`, `code:bash (# Old (agent-specific):)`, `DefaultTerminalManager`, `KeySpec`, `[2.5.0] - 2026-06-12`, `SyntaxTextView`, `BlockTintOverlay`, `DisplayPanesOverlay`, `TerminalScrollbarView`, `.apply`, `Process`, `Release runbook`, `Fixes Applied (layered)`, `AgentApprovalBar`, `settings.json`, `PaneNode`, `HarnessPaths.swift`, `.parse`, `ThemeDiagnostics`, `.encodeMouse`, `00-inception-plan.md`, `.jumpToBlock`, `Send Ex Command`, `Browser DevTools API (P28)`, `FrameSignposter`, `.init`, `code:bash (harness-cli install-hooks codex)`, `Memory — harness-terminal`, `FormatColor`, `Focus Persistence — Per-Session-Tab Pane Focus (RL-043)`, `UInt64`, `FloatingPaneController`, `worktree_isolation.robot`, `.drawGlyph`, `.recordReapedGenerationForTesting`, `ImageProtocolTests.swift`, `.navigateCurrentFile`, `code:bash (harness-cli install-hooks openclaw)`, `README.md`, `Agent platform icons`, `SurfaceProgressTracker`, `.handleCat`, `State`, `RGBColor`, `Fixes Applied (v3.9.1+)`, `Consumers`, `Tab`, `DynamicInstanceBuffer`, `.install`, `ScrollReuseTests`, `MCPServer`, `PromptQueue`, `smoke-dmg.sh`, `ThaiClusterRenderTests`, `NSTextField Leak in BoardViewController (P20 Performance)`, `SKILL-LOG.md`, `User Profile`, `UI Automation — Robot Framework (P18)`, `AppKit + Metal Patterns`, `build-release.sh`, `finalize-release.sh`, `View`, `PresentAttempt`, `Split Panes (NSSplitView)`, `markdown.json`, `.refreshSurfaceMetadata`, `AgentVectorIcon`, `Competitive Position (as of v3.12.0, 2026-07-02)`, `PathToken`, `SetupStepView`, `.run`, `tmux parity — status, adaptations, and deliberate divergences`, `.deleteWorkspaceFromMenu`, `.worktreeList`, `.deinit`, `DirectionalAxis`, `.evaluateStyled`, `HarnessOnboarding`, `ScrollbackTests`, `.testKouenRendererFixtureDefaultTextReportsPlausibleGlyphStats`, `bC`, `Service Decomposition — SessionCoordinator (P17)`, `ACP Client (Shelved)`, `.tickFeatureWorktreeSweepLocked`, `SwarmFleetBody`, `qLt`?**
  _High betweenness centrality (0.276) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `.text` to `WorkspaceSymbolIndex`, `TabPillView`, `.install`, `code:bash (harness-cli install-hooks cursor)`, `TextGrid`, `AgentSessionSummary.swift`, `.agentName`, `.id`, `CodingKeys`, `.normalizedKey`, `Changelog`, `[3.13.1] - 2026-07-02`, `P25 — iOS/iPadOS Support`, `code:bash (# In a Harness pane:)`, `Sendable`?**
  _High betweenness centrality (0.215) - this node is a cross-community bridge._
- **Why does `fbt()` connect `callingPaneTarget` to `CodingKey`, `LSPMessage`, `EngineConformanceTests`, `code:bash (# In a Harness pane:)`?**
  _High betweenness centrality (0.108) - this node is a cross-community bridge._
- **Are the 18 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `RenderScheduler`) actually correct?**
  _`KouenTerminalSurfaceView` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _2386 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.0059389201884071235 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.013392238392238392 - nodes in this community are weakly interconnected._