# Graph Report - lazy-git  (2026-10-18)

## Corpus Check
- 917 files · ~1,036,497 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 19878 nodes · 57052 edges · 2635 communities (1499 shown, 1136 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8551 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `94883512`
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
3. `AgentKind` - bridges 84 areas (178 edges)
4. `t()` - bridges 83 areas (253 edges)
5. `IPCResponse` - bridges 76 areas (101 edges)
6. `KouenTerminalSurfaceView` - bridges 73 areas (345 edges)
7. `KouenPaths` - bridges 67 areas (150 edges)
8. `SurfaceRegistry` - bridges 66 areas (224 edges)
9. `SessionCoordinator` - bridges 65 areas (235 edges)
10. `AnyCodable` - bridges 65 areas (190 edges)

## Surprising Connections (you probably didn't know these)
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/RemoteHostsService.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.selectWorkspace(byIndex:)` --references--> `SessionSnapshot`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/SessionCoordinator.swift → Packages/KouenIPC/Sources/KouenIPC/SessionSnapshot.swift
- `ThemeImportController` --calls--> `ThemeFileService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/ThemeImportController.swift → Packages/KouenTheme/Sources/KouenTheme/ThemeFileService.swift
- `.selectedHost` --references--> `RemoteHost`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRemoteView.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift

## Import Cycles
- None detected.

## Communities (2635 total, 1136 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.01
Nodes (560): _1n(), _3e(), _4e(), _5n(), _6e(), _9e(), a2(), a2n() (+552 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.02
Nodes (445): l, V, _4n(), _7n(), a1t(), a9n(), aA(), act() (+437 more)

### Community 2 - ".handleNormal"
Cohesion: 0.03
Nodes (280): m(), pe(), r, X(), A(), code(), R(), a() (+272 more)

### Community 3 - "Changed"
Cohesion: 0.04
Nodes (32): TerminalGridCell, NSEvent, String, Any, Bool, CGFloat, NSEvent, NSMenu (+24 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.05
Nodes (44): AgentBridge, AgentTarget, Bool, String, SurfaceID, .onCurrentCWD, .onCurrentFile, LinePos (+36 more)

### Community 5 - "IPCRequest"
Cohesion: 0.10
Nodes (31): aXt(), AYt(), CUe(), cXt(), GYt(), H7(), hXt(), IR() (+23 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.03
Nodes (73): _0t(), a0(), agt(), _at(), aV(), b6n(), bgn(), bwn() (+65 more)

### Community 7 - "Command"
Cohesion: 0.13
Nodes (5): azt(), F7, ibe(), q$e(), UHt()

### Community 8 - "LSPMessage"
Cohesion: 0.08
Nodes (13): .receive(_:), DispatchSemaphore, FluidityBenchmarks, NSWindow, String, UInt64, NSWindow, KouenTerminalSurfaceWorkerTests (+5 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.09
Nodes (34): json, .saveRecordsBatch(_:), CachedSessionEntry, AgentHistoryScanner, .parseAntigravityTranscript(sessionID:fileURL:), .parseAntigravityTranscript(sessionID:fileURL:toIndex:), .parseClaudeTranscript(fileURL:), .parseClaudeTranscript(fileURL:toIndex:) (+26 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.09
Nodes (38): blockTokens(), br(), checkbox(), codespan(), constructor(), de(), del(), em() (+30 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.12
Nodes (17): KouenGridTerminal, TerminalDamage, GlyphKey, RenderColor, MTLTexture, MetalRendererTests, .makeRenderer(device:atlasSize:atlasMaxPages:), RenderedFixture (+9 more)

### Community 12 - "Changed"
Cohesion: 0.07
Nodes (13): HistoryLine, ImagePlacement, RewrapResult, Bool, ClosedRange, Range, String, TerminalCellWidth (+5 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.08
Nodes (21): OSCTerminatorMatch, PtyError, launchFailed, RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), ScrollbackEntry, ScrollbackReplaySegment, ShellLaunchProfile (+13 more)

### Community 14 - "VTParser"
Cohesion: 0.06
Nodes (32): AnyView, Color, .hexString, Container, .init(coder:), .init(frame:), NotchOverviewRow, .approvalControls (+24 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.07
Nodes (15): Command, .init(forTesting:), UUID, Void, string, PanePipe, .subscribe(surfaceID:handler:), Bool (+7 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.06
Nodes (40): abn(), aU(), b1n(), c2t(), dte(), eL(), evt(), f2n() (+32 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.07
Nodes (45): AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem, fetchGitStatus() (+37 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.06
Nodes (45): NSCursor, RGBColor, TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate (+37 more)

### Community 19 - "SpecialKey"
Cohesion: 0.07
Nodes (35): KeybindingsService, Bool, Command, String, .groups, KeySpec, .init(from:), Decoder (+27 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.07
Nodes (32): ClientRecord, CountBox, DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed (+24 more)

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.13
Nodes (8): SessionGroupHeaderRowView, SessionWorktreeHeaderRowView, SessionWorktreeRowView, NSEvent, NSMenu, NSTrackingArea, Void, WorktreeRowView

### Community 22 - "CopyModeAction"
Cohesion: 0.07
Nodes (12): SessionGroup, String, KouenSidebarPanelViewController, NSMenuItem, SessionGroup, String, NSMenu, NSMenuItem (+4 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.08
Nodes (23): DaemonClient, Int32, String, TimeInterval, UUID, Void, ClaudeCodeHarnessIPCTests, String (+15 more)

### Community 24 - ".request"
Cohesion: 0.05
Nodes (49): .init(entry:), AgentChipView, .init(coder:), .init(frame:), .intrinsicContentSize, ChromeBackdrop, .init(role:), ChromeRole (+41 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.07
Nodes (40): DaemonSubscription, .start(onData:onEnd:buffered:), .start(onResponse:onEnd:), UInt64, decodeBoundedCString(), makeUnixStreamSocket(), setNoSigPipe(), CChar (+32 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.07
Nodes (29): AgentHistoryDateGroup, older, .sortOrder, thisWeek, today, yesterday, AgentSessionHistoryModel, .extraRecordsShown (+21 more)

### Community 27 - "RGBColor"
Cohesion: 0.07
Nodes (24): Bool, UInt16, Data, DecodedReplyFrame, output, reply, DecodedRequestFrame, input (+16 more)

### Community 28 - ".parse"
Cohesion: 0.09
Nodes (13): SessionCoordinator, Bool, Double, PaneID, PaneNode, SessionID, SplitDirection, String (+5 more)

### Community 29 - "Added"
Cohesion: 0.11
Nodes (21): .pairedAlreadyBanner, .pairingQRPanel, .sidebarEmptyView, .rootPicker, TrackedIssue, IssueTrackerPanelView, .body, .filteredIssues (+13 more)

### Community 30 - "Notification"
Cohesion: 0.10
Nodes (14): PluginLoader, String, ScriptError, .errorDescription, evaluationError, unsupportedPlatform, ScriptRuntime, Any (+6 more)

### Community 31 - "Sendable"
Cohesion: 0.07
Nodes (43): AgentRow, .agentColor, .agentColorBinding, .executables, .hookButton, .hookButtonTitle, SettingsAgentsView, .agentsSection (+35 more)

### Community 32 - ".addTab"
Cohesion: 0.12
Nodes (6): KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), SpawnedAgentSurface, Result, String, UUID

### Community 33 - "Equatable"
Cohesion: 0.09
Nodes (29): ArtifactKind, html, image, markdown, text, AutomationsFleetModel, .load(detectScheduledRuns:), AutomationSource (+21 more)

### Community 34 - "DaemonClient"
Cohesion: 0.06
Nodes (25): CornerInfo, EditorDividerView, HitTestPassthroughView, KouenSplitView, .dividerColor, .dividerThickness, .init(coder:), PaneDragGripView (+17 more)

### Community 35 - "MenuTarget"
Cohesion: 0.11
Nodes (54): DirectoryListResponse, Encodable, ExpressibleByStringLiteral, FileReadResponse, authorizedReadPath(), buildSuggestPrompt(), cancelConnection(), Sendable (+46 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.15
Nodes (11): .addSurface(tabID:paneID:), .tab(containingPaneID:), .tabIndex(surfaceKey:), .tabIndex(workspaceID:tabID:), Bool, Date, SessionID, String (+3 more)

### Community 37 - "String"
Cohesion: 0.06
Nodes (43): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, .init(from:), .init(id:name:baseURL:modelID:), ModelProvider (+35 more)

### Community 38 - "code:bash (swift build)"
Cohesion: 0.11
Nodes (17): .exit, String, String, String, String, KouenCLI, SessionID, String (+9 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.17
Nodes (12): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+4 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.10
Nodes (8): PaneBorderStatus, Bool, Command, DispatchWorkItem, PaneRect, String, StyledSegment, WindowSession

### Community 41 - "CodingKeys"
Cohesion: 0.09
Nodes (20): AnyObject, DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor (+12 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.08
Nodes (41): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+33 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.02
Nodes (240): a(), b(), c(), d(), e(), f(), g(), h() (+232 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.08
Nodes (45): MTLClearColor, MTLCommandBuffer, MTLLibrary, MTLRenderCommandEncoder, MTLRenderPipelineState, Int, ImageTextureCache, MTLDevice (+37 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.18
Nodes (6): AnyCodable, JSONRPCError, Int32, Pipe, String, ToolRegistry

### Community 46 - ".buildCommand"
Cohesion: 0.10
Nodes (12): PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Double, MTLDevice, MTLTexture, String (+4 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.07
Nodes (34): String, UInt64, String, BlockSelection, CursorRender, CursorStyle, bar, block (+26 more)

### Community 48 - "HookEvent"
Cohesion: 0.08
Nodes (24): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+16 more)

### Community 49 - "DaemonServer"
Cohesion: 0.11
Nodes (13): Bool, String, UInt8, UnsafeBufferPointer, TerminalEmulator, .captureLines(fromLine:toLine:), .onResponse, .onSetClipboard (+5 more)

### Community 50 - "Added"
Cohesion: 0.09
Nodes (29): AppKit, CoreGraphics, CoreText, ImageIO, KouenCopyMode, KouenTerminalEngine, KouenTerminalRenderer, KouenTheme (+21 more)

### Community 51 - ".keyEvent"
Cohesion: 0.08
Nodes (43): Codable, BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserRequestPayload, close, cookies (+35 more)

### Community 52 - "Fixed"
Cohesion: 0.08
Nodes (23): DisplayLinkTarget, MainSplitViewController, .setSidebarVisible(_:), .setSidebarVisible(_:animated:), SplitChromeDelegate, .sidebarMaxWidth, .sidebarMinWidth, .splitView(_:constrainMaxCoordinate:ofSubviewAt:) (+15 more)

### Community 53 - "Added"
Cohesion: 0.10
Nodes (19): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, SessionGroup, Tab (+11 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.15
Nodes (8): ContextResolutionEngine, Bool, String, Bool, String, TokenGuard, ContextResolutionEngineTests, String

### Community 55 - "TabCell"
Cohesion: 0.06
Nodes (35): Executor, Hook, HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane (+27 more)

### Community 56 - "NSPanel"
Cohesion: 0.07
Nodes (6): B0, BBe(), Fze, O7, RD, S9

### Community 57 - "BellScanState"
Cohesion: 0.10
Nodes (14): NotchMaskAnimator, Bool, CGFloat, CGRect, NotchPanel, .canBecomeKey, .canBecomeMain, Bool (+6 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.05
Nodes (44): _5e(), ast(), b3e(), c6(), cmn(), d4n(), ewn(), g3e() (+36 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.08
Nodes (23): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, .acceptsFirstResponder (+15 more)

### Community 60 - "ViEngine"
Cohesion: 0.08
Nodes (28): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, PaletteFooter, .body (+20 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.09
Nodes (12): ParsedShortcut, .displayString, PrefixKeymap, Any, Bool, NSEvent, TimeInterval, ControlKeyNormalizer (+4 more)

### Community 62 - "ComposedCell"
Cohesion: 0.10
Nodes (12): Bool, DispatchWorkItem, NSEvent, NSPopover, NSRange, NSString, Void, SyntaxTextView (+4 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.06
Nodes (15): .event(_:), .interval(_:_:), StaticString, T, Bool, CAMetalDrawable, .testingPendingResize, PendingMainHop (+7 more)

### Community 64 - ".text"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.10
Nodes (21): OptionStore, OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Scope, pane (+13 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.11
Nodes (10): GitPanelView, .isHidden, .removeWorktreeAction(path:), GitResult, Bool, DispatchWorkItem, String, UnsafeMutableRawPointer (+2 more)

### Community 67 - "String"
Cohesion: 0.07
Nodes (32): ImagePlacementSnapshot, SemanticMark, Bool, String, UInt8, TerminalCellWidth, normal, spacerTail (+24 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.06
Nodes (40): ButtonStyle, CommandRow, .body, GlassCard, .body, GlassPrimaryButtonStyle, GlassSecondaryButtonStyle, GlassSmallButtonStyle (+32 more)

### Community 69 - ".compose"
Cohesion: 0.11
Nodes (16): String, AgentRoutingRule, Kind, path, stack, Bool, Date, UUID (+8 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.11
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.08
Nodes (26): aie(), arc(), b2e(), bezierCurveTo(), closePath(), cRe(), cZ(), e0n() (+18 more)

### Community 72 - "XCTestCase"
Cohesion: 0.10
Nodes (24): .filteredJobs, MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith (+16 more)

### Community 73 - "README.md"
Cohesion: 0.07
Nodes (27): _6n(), Bm(), dCn(), Em(), Fm(), fyn(), gat(), h9n() (+19 more)

### Community 74 - "[2.6.0] - 2026-06-13"
Cohesion: 0.08
Nodes (23): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSEvent (+15 more)

### Community 75 - "OptionStore"
Cohesion: 0.10
Nodes (17): AgentBrowserPaneTracker, SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, SessionID (+9 more)

### Community 76 - ".parse"
Cohesion: 0.10
Nodes (14): .effectiveResumeCommand(claudeMode:), LiveClaudeAgentEntry, .placement, ClaudeSessionMode, ClaudeCloudSessionStore, Entry, Date, String (+6 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.09
Nodes (25): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, IssueInfo (+17 more)

### Community 78 - "Added"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 79 - "HarnessDesign"
Cohesion: 0.08
Nodes (20): Tab, AnyObject, TimeInterval, ZombieHoldRegistry, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), .init(paneID:), PaneID (+12 more)

### Community 80 - "Agent handbook — Harness (extended reference)"
Cohesion: 0.08
Nodes (26): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+18 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.08
Nodes (32): CGFloat, FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView (+24 more)

### Community 82 - ".firstMatch"
Cohesion: 0.10
Nodes (17): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent, ScrollbackFile (+9 more)

### Community 83 - "LSPClient"
Cohesion: 0.07
Nodes (19): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, PaneID, SurfaceID (+11 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.06
Nodes (35): DetachedPaneOverlay, .init(coder:), .init(frame:style:), InputGate, .siblings, OutputCoalescer, ReconnectLatch, .isTripped (+27 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.10
Nodes (19): ScriptAPI, .windowSection, KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:fileSearchRoots:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:), .scrollbackLines, ResizeOverlayMode, afterFirst (+11 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.06
Nodes (26): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+18 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.08
Nodes (26): Notification.Name, os, Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow (+18 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.13
Nodes (9): Process, SSHTunnelManager, .init(makeTunnelProcess:reachabilityProbe:), Bool, URL, Tunnel, SSHTunnelManagerTests, String (+1 more)

### Community 89 - ".cursorPos"
Cohesion: 0.10
Nodes (15): FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect, String, URL (+7 more)

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.08
Nodes (20): .init(coder:), Kind, primary, secondary, .init(coder:), KouenPillButton, .init(coder:), .init(title:kind:) (+12 more)

### Community 91 - "TerminalModes"
Cohesion: 0.06
Nodes (26): DaemonCommandExecutor, SurfaceRegistry, Set, TimeInterval, PendingVersionBanner, welcome, whatsNew, State (+18 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.11
Nodes (8): Bool, Range, Set, String, URLDetection, StringProtocol, Substring, EngineConformanceTests

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.15
Nodes (9): StringKind, apc, dcs, UInt8, UnsafeBufferPointer, VTParser, .feed(_:), VTParserHandler (+1 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.05
Nodes (38): Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions, Logical Design, P41 — Automations, Strategic Design, Tactical Design (+30 more)

### Community 95 - "shim.c"
Cohesion: 0.08
Nodes (18): NSScrollView, NSWindow, Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent (+10 more)

### Community 96 - "Harness Usage"
Cohesion: 0.08
Nodes (27): .body, FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body (+19 more)

### Community 97 - "PaneContainerView"
Cohesion: 0.13
Nodes (7): DispatchWorkItem, RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 98 - "4. Technical Architecture"
Cohesion: 0.08
Nodes (28): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, .body, PaletteModel (+20 more)

### Community 99 - ".dispatch"
Cohesion: 0.13
Nodes (5): .setupPrompt, hooks, AgentHookInstallerTests, String, URL

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.18
Nodes (11): SwarmSpawnSpec, CallRecorder, .cancelCalls, .closeCalls, .harnessCalls, .surfaceCalls, SwarmWorkerManagerTests, Bool (+3 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.14
Nodes (18): CommandParseError, .description, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand (+10 more)

### Community 103 - "AnyCodable"
Cohesion: 0.07
Nodes (15): .readJSONLLines(from:fromOffset:), ClaudeSessionLocator, ClaudeTranscriptLine, Role, assistant, user, Any, Bool (+7 more)

### Community 104 - "Recipe"
Cohesion: 0.11
Nodes (26): ColorKind, .base, bg, fg, underline, CompositorPane, GridCompositor, .render(panes:status:statusSegments:) (+18 more)

### Community 105 - "Changelog"
Cohesion: 0.05
Nodes (26): KouenCLITests, URL, CLIInstallLocator, DetachKeys, absent, invalid, parsed, OptionalUUID (+18 more)

### Community 106 - "domain-design.md"
Cohesion: 0.09
Nodes (31): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+23 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.22
Nodes (10): Status, ciFailing, done, mergeReady, open, running, Bool, Date (+2 more)

### Community 108 - ".resolve"
Cohesion: 0.14
Nodes (6): TimeInterval, AgentHandoffBuilder, Bool, String, HandoffDirectoryTests, AgentHandoffBuilderTests

### Community 109 - "DamageTrackingTests"
Cohesion: 0.08
Nodes (23): IndexingIterator, LayoutTemplate, surfaceID, SessionEditor, .addSurface(to:paneID:surfaceID:cwd:), .split(node:targetPaneID:direction:paneCount:before:), .split(node:targetPaneID:with:direction:beforeTarget:), .surfaceID(forPaneID:) (+15 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.14
Nodes (15): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+7 more)

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.10
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.06
Nodes (29): FilterStatus, active, all, completed, CaseIterable, LayoutTemplate, evenHorizontal, evenVertical (+21 more)

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.14
Nodes (12): MarkdownPreviewView, .webView(_:decidePolicyFor:decisionHandler:), .webView(_:didFinish:), Bool, MainActor, Sendable, String, URL (+4 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.08
Nodes (9): CGFloat, ResizeDirection, down, left, right, up, Bool, String (+1 more)

### Community 115 - ".encode"
Cohesion: 0.16
Nodes (12): FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID, KouenFeature (+4 more)

### Community 116 - "SessionGroup"
Cohesion: 0.08
Nodes (21): DaemonClientActor, TimeInterval, DaemonSessionError, daemonError, .description, unexpectedResponse, DaemonSessionService, .endpoint (+13 more)

### Community 117 - "PaneNode"
Cohesion: 0.13
Nodes (13): MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem, SessionGroup (+5 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.14
Nodes (9): .selectedHost, MutationResult, RemoteHost, RemoteHostStore, Bool, String, RemoteHostStoreTests, String (+1 more)

### Community 119 - "Harness command reference"
Cohesion: 0.05
Nodes (39): Array, GroupHeaderRow, .body, PickerItem, .groupLabel, historyBlock, .id, recipe (+31 more)

### Community 120 - "Added"
Cohesion: 0.14
Nodes (20): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), .stats (+12 more)

### Community 121 - "Changed"
Cohesion: 0.15
Nodes (12): NaturalLanguage, AgentHistorySearch, Hit, IDFCache, Bool, Double, String, .tokenHits(_:inNormalized:) (+4 more)

### Community 122 - "ViEngine"
Cohesion: 0.08
Nodes (20): SGRMouse, SGRMouseEvent, Bool, PaneRect, UInt8, MouseButton, left, middle (+12 more)

### Community 123 - "Pipe"
Cohesion: 0.14
Nodes (20): ComposedCell, .asGridCell, .init(_:), .init(codepoint:fg:bg:underlineColor:bold:dim:italic:underline:blink:inverse:invisible:strikethrough:overline:), .scalar, .sgr, CompositorPane, GridCompositor (+12 more)

### Community 124 - "String"
Cohesion: 0.10
Nodes (18): SavedLayoutStore, Bool, String, URL, UUID, PaneLayoutShape, branch, leaf (+10 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.11
Nodes (14): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+6 more)

### Community 126 - ".path"
Cohesion: 0.13
Nodes (11): FlippedView, .isFlipped, .removeWorktreeAction(_:), NSButton, NSColor, NSRect, NSScrollView, NSStackView (+3 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.12
Nodes (19): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerFooter, .body, DirectoryPickerModel (+11 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.09
Nodes (13): CKouenSys, pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal (+5 more)

### Community 129 - "SwiftUI"
Cohesion: 0.06
Nodes (29): CustomStringConvertible, DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed, atomicWrite() (+21 more)

### Community 130 - "Harness"
Cohesion: 0.13
Nodes (15): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+7 more)

### Community 131 - ".install"
Cohesion: 0.13
Nodes (12): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+4 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.08
Nodes (26): LocalizedError, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display, found (+18 more)

### Community 133 - ".load"
Cohesion: 0.12
Nodes (12): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+4 more)

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.11
Nodes (13): FileFuzzyMatcher, FileSearchRootScanner, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool (+5 more)

### Community 135 - "CommandTarget"
Cohesion: 0.12
Nodes (16): AgentSessionHistoryView, .body, .footerView, HistoryMenuProxy, Any, Bool, CGFloat, Date (+8 more)

### Community 136 - ".startWatching"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, S (+2 more)

### Community 137 - "ActivePaneService"
Cohesion: 0.11
Nodes (16): ControlMessage, AgyModelCatalog, Catalog, Date, String, TimeInterval, AgyMobileCommands, String (+8 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.07
Nodes (26): Error, LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed, serverNotExecutable, AsyncStream (+18 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.15
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 140 - "Added"
Cohesion: 0.09
Nodes (23): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+15 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.14
Nodes (13): AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID, .snapshotPayload, NotificationBus (+5 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.18
Nodes (10): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, automations (+2 more)

### Community 145 - "AsciiFastPathTests"
Cohesion: 0.14
Nodes (11): String, ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID, String (+3 more)

### Community 146 - "DecodedImage"
Cohesion: 0.10
Nodes (26): CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf, .init(from:) (+18 more)

### Community 147 - "FileTreeWatcher"
Cohesion: 0.10
Nodes (15): LSPMessage, notification, request, response, Decoder, Encoder, KeyedDecodingContainer, LSPTransport (+7 more)

### Community 148 - "TriState"
Cohesion: 0.04
Nodes (39): o, a9e(), AI(), avn(), aXe(), aZ(), bee(), ck() (+31 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.06
Nodes (34): aDt(), B3(), BDt(), Bpe(), cFe(), dFe(), displayable(), _Dt() (+26 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.22
Nodes (9): FileNode, Bool, String, FileTreeScanOptions, ScoredMatch, Bool, String, .resolvedGitStatus (+1 more)

### Community 151 - ".evaluate"
Cohesion: 0.12
Nodes (10): item, CodexSessionLocator, CodexTranscriptLine, Any, Bool, Int32, String, URL (+2 more)

### Community 152 - "Added"
Cohesion: 0.10
Nodes (25): NSEvent, WorktreeCardView, FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:) (+17 more)

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.12
Nodes (8): ContentAreaViewController, Bool, FilePreviewCoordinator, FileTabID, Set, SplitDirection, String, Notification

### Community 154 - "LiveResizeTests"
Cohesion: 0.18
Nodes (6): CopyModeReducerTests, FakeGrid, .totalLines, Set, String, TerminalGridCell

### Community 155 - "Int"
Cohesion: 0.03
Nodes (82): _2t(), aoe(), ayn(), b2t(), bR(), c8e(), cce(), Cf() (+74 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.17
Nodes (11): FileTreeContext, Bool, NSDraggingInfo, NSDragOperation, NSHostingView, SessionID, String, Void (+3 more)

### Community 157 - "Added"
Cohesion: 0.11
Nodes (24): .color, Collection, .aggregateBoardStatus, .taskTooltipSummary, TaskSummary.Status, .columnKind, BoardCard, BoardColumn (+16 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.16
Nodes (15): ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool, Command (+7 more)

### Community 159 - "MatchCategory"
Cohesion: 0.10
Nodes (16): StatusLineView, .init(coder:), Bool, CGFloat, FormatColor, Never, NSAttributedString, NSCoder (+8 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.05
Nodes (28): AgentDetection, AgentDetector, AgentTableEntry, MatchSource, ownProcess, wrapperLaunch, RawMatch, Bool (+20 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.16
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 162 - "TerminalFindBar"
Cohesion: 0.14
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 163 - "Workspace"
Cohesion: 0.05
Nodes (21): Am(), bUt(), bze(), Cm(), EQ(), fQ, Gbe(), GUt (+13 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.05
Nodes (27): TerminalGridCell, TerminalGridSnapshot, .captureLines(joinWrapped:), .feed(_:), .promptRows, .readGrid(scrollbackOffset:), .captureLines(fromLine:toLine:), .captureLines(joinWrapped:) (+19 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.17
Nodes (10): SSETransportTests, UInt16, SSETransport, .isRunning, .listener, Bool, NWConnection, NWListener (+2 more)

### Community 166 - "LiveSession"
Cohesion: 0.15
Nodes (10): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, Set, SurfaceID (+2 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.05
Nodes (56): _3n(), aR(), bV(), c_n(), cKt(), copy(), cYt(), d4e() (+48 more)

### Community 168 - "Added"
Cohesion: 0.16
Nodes (11): Equatable, PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab (+3 more)

### Community 169 - "Fixed"
Cohesion: 0.10
Nodes (25): Bool, UInt8, TerminalCellWidth, normal, spacerTail, wide, TerminalCursor, TerminalCursorShape (+17 more)

### Community 170 - "URLDetection"
Cohesion: 0.12
Nodes (10): WindowInputRouterTests, UInt8, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8 (+2 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.12
Nodes (10): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+2 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.08
Nodes (20): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+12 more)

### Community 173 - "BoardCard"
Cohesion: 0.11
Nodes (22): keys, ITerm2InlineImage, .heightArg, .preserveAspectRatio, .widthArg, Bool, String, UInt8 (+14 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.09
Nodes (20): DiffLineType, added, deleted, modified, Notification.Name, ObserverToken, NSCoder, NSObjectProtocol (+12 more)

### Community 175 - "RGBColorTests"
Cohesion: 0.07
Nodes (20): Codex → Kouen, One-line install, What you'll see, Cursor Agent → Kouen, Manual fallback, One-line install, What you'll see, Grok Build → Kouen (+12 more)

### Community 176 - "Added"
Cohesion: 0.27
Nodes (8): LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab, TabID, WorkspaceID

### Community 177 - ".rects"
Cohesion: 0.15
Nodes (9): CheckpointInfo, CheckpointManager, Bool, Date, String, CheckpointManagerTests, String, String (+1 more)

### Community 178 - "InlineAICompletionView"
Cohesion: 0.15
Nodes (18): AgentArt, AgentMark, .body, AgentMarkShape, AgentVectorIcon, Scanner, .atEnd, SVGPath (+10 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.14
Nodes (28): Cleanup Test Repo, Close Isolated Session Keeps Dirty Worktree, Close Isolated Session Removes Clean Worktree, Close One Isolated Does Not Affect Another, Close Session With Split Panes Removes Worktree, Create Isolated Session, Create Isolated Session Via CLI, Get Active Pane (+20 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.17
Nodes (3): TerminalGridCell, TerminalGridSnapshot, ThaiCombiningMarkTests

### Community 181 - "GridCompositorTests"
Cohesion: 0.09
Nodes (9): String, WorkspaceID, CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab, DaemonSyncServiceBranchNotifyTests (+1 more)

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.09
Nodes (11): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+3 more)

### Community 183 - "LSPServerRegistry"
Cohesion: 0.16
Nodes (9): BranchSwitchHelper, FileTreeNode, FileTreeSwiftUIView, .body, .scanOptions, Notification.Name, Bool, NSMenuItem (+1 more)

### Community 184 - "targets"
Cohesion: 0.11
Nodes (21): Motion, .entrance, .spring, .standardEase, CAMediaTimingFunction, NSWindowController, NSWindowDelegate, KouenOnboarding (+13 more)

### Community 185 - "SessionSnapshot"
Cohesion: 0.07
Nodes (28): Additional `kouen-cli` subcommands, Agent safety CLI (`kouen-cli`), Agents, context and scratchpad, Attaching from a plain terminal, Bindings, Board and attention, Buffers (paste store), Composition (+20 more)

### Community 186 - "Error"
Cohesion: 0.21
Nodes (4): CommandTarget, String, UUID, TargetSpecTests

### Community 187 - "AppDelegate"
Cohesion: 0.30
Nodes (7): FormatContext, FormatString, Bool, Character, Date, String, .ctx

### Community 188 - "BrowserPaneView"
Cohesion: 0.18
Nodes (5): ClaudeCodeHarness, .hasAdapter(for:), Bool, UUID, ClaudeCodeHarnessTests

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.11
Nodes (37): Ame(), aQt(), aUe(), Cme(), Cqt(), DYt(), een(), eVe() (+29 more)

### Community 190 - "user-stories.md"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.12
Nodes (3): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess

### Community 192 - "GlyphRasterizer"
Cohesion: 0.20
Nodes (10): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, Bool (+2 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.18
Nodes (10): SettingsAppearanceView, .autoTheme, .body, SliderRow, .body, .displayValue, Bool, ClosedRange (+2 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.14
Nodes (10): Bool, CGFloat, NSCoder, NSLayoutConstraint, NSPoint, NSRect, WindowTitleStripView, .init(coder:) (+2 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.29
Nodes (8): SessionID, String, Void, TaskDashboardBody, .body, .init(onJumpToSession:), TaskRowView, .body

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.12
Nodes (12): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, input (+4 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.14
Nodes (14): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+6 more)

### Community 198 - ".classify"
Cohesion: 0.11
Nodes (11): .readJSONLLines(from:), AntigravitySessionLocator, AntigravityTranscriptLine, Bool, Int32, NSRegularExpression, String, URL (+3 more)

### Community 199 - "code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)"
Cohesion: 0.08
Nodes (6): KouenSettings, Bool, ExperienceModeTests, KouenSettingsTests, URL, Void

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.11
Nodes (5): KouenThemeCatalog, .allThemes, String, ANSIPaletteTests, KouenThemeCatalogTests

### Community 202 - "PaletteModel"
Cohesion: 0.15
Nodes (8): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ActivityAssertionManagerTests

### Community 203 - "Harness keybindings"
Cohesion: 0.14
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 204 - "From tmux"
Cohesion: 0.17
Nodes (11): NotchGeometry, .fallback, NSScreen, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics (+3 more)

### Community 205 - "CopyModeState"
Cohesion: 0.08
Nodes (19): SnapshotCoalescer, MainActor, Void, AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide (+11 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.13
Nodes (14): CompletionPopupView, .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:), .isHovered, Bool (+6 more)

### Community 207 - "scheduleRender"
Cohesion: 0.19
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.24
Nodes (9): CopyModeGridSource, .promptRows, CopyModeReducer, Bool, Character, NSRegularExpression, Range, String (+1 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.12
Nodes (7): KeybindingsStore, .fileURL, URL, KeybindingsStoreTests, URL, Void, String

### Community 211 - "PaneTarget"
Cohesion: 0.12
Nodes (17): OnboardingStep, complete, discover, .id, setup, shell, .title, welcome (+9 more)

### Community 212 - ".translate"
Cohesion: 0.07
Nodes (42): a6(), CWt(), dUe(), eJ(), EWt(), fGt(), fle(), fme() (+34 more)

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.13
Nodes (3): KittyKeyboardTests, String, UInt8

### Community 215 - ".lines"
Cohesion: 0.17
Nodes (10): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+2 more)

### Community 216 - "CellColorResolverTests"
Cohesion: 0.07
Nodes (22): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+14 more)

### Community 217 - "GridCompositor"
Cohesion: 0.12
Nodes (17): FormatContextBuilder, DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:) (+9 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.09
Nodes (18): .requestDaemon(_:), .selectWorkspace(byIndex:), .syncFromDaemon(metadataOnly:), ActiveTabCloseDisposition, session, tab, window, workspace (+10 more)

### Community 219 - "Prompt"
Cohesion: 0.14
Nodes (12): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+4 more)

### Community 220 - "Section"
Cohesion: 0.06
Nodes (38): a0n(), bwt(), dl(), eAn(), eht(), fun(), gb(), ggn() (+30 more)

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.10
Nodes (20): CodingKeys, error, id, jsonrpc, method, params, result, LSPDiagnostic (+12 more)

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.06
Nodes (16): KouenTerminalKit, NSPasteboard, URL, NSPasteboard, URL, KouenTerminalSurfaceDragDropTests, KouenTerminalSurfaceFocusTests, OcclusionTests (+8 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.18
Nodes (5): CompositorPane, GridCompositorTests, Bool, String, TerminalGridSnapshot

### Community 224 - "CellColorResolver"
Cohesion: 0.16
Nodes (13): CryptoKit, Network, DecodedWSFrame, MobileBridgeServer, Bool, ConnectionState, NWConnection, String (+5 more)

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.13
Nodes (16): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, .bytesPerWakeup, .mbps (+8 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.07
Nodes (18): NSResponder, NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent (+10 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.11
Nodes (16): CodingKeys, error, id, jsonrpc, method, JSONRPCId, int, string (+8 more)

### Community 228 - "sessionRow"
Cohesion: 0.14
Nodes (18): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, PaneLeaf, PaneNode (+10 more)

### Community 229 - ".decide"
Cohesion: 0.23
Nodes (6): Divergence, Bool, String, TimeInterval, WorktreeInfo, WorktreeManager

### Community 231 - "ExternalOpenKind"
Cohesion: 0.16
Nodes (3): CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.21
Nodes (8): DaemonMetrics, Snapshot, .meanLockWaitMicros, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 233 - "TextGrid"
Cohesion: 0.09
Nodes (25): bNt(), bu(), cNt(), dNt(), eNt(), eRe(), fNt(), h0t() (+17 more)

### Community 234 - ".scan"
Cohesion: 0.20
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 235 - "WorkbenchCommand"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 236 - "Added"
Cohesion: 0.15
Nodes (13): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+5 more)

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.15
Nodes (14): .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:), .init(frame:) (+6 more)

### Community 238 - ".make"
Cohesion: 0.13
Nodes (14): .activeTab, .init(url:paneID:), .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), .webView(_:didFinish:), BrowserTab, URL, UUID (+6 more)

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.15
Nodes (8): BoardViewController, .isVisible, FlippedView, .isFlipped, Bool, Set, TabID, BoardViewControllerTests

### Community 240 - "PaneBorderStatus"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 241 - "Added"
Cohesion: 0.11
Nodes (13): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, PaneLeaf (+5 more)

### Community 242 - "AgentBridge"
Cohesion: 0.06
Nodes (35): AS(), bvt(), cc(), d2(), dce(), dw(), e6(), e7n() (+27 more)

### Community 243 - ".make"
Cohesion: 0.11
Nodes (16): .body, .mcpButton, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter, Any (+8 more)

### Community 244 - "FileNode"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.14
Nodes (13): init(), PairingBox, .current, .isLockedOut, PendingPairing, stop(), Date, TimeInterval (+5 more)

### Community 246 - "Experience modes"
Cohesion: 0.27
Nodes (6): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor

### Community 247 - ".renderFixture"
Cohesion: 0.14
Nodes (17): PaneBorderStatus, bottom, off, top, PaneLeaf, PaneNode, branch, leaf (+9 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.15
Nodes (35): aQ(), bme(), bqt(), bYt(), cbe(), DD(), dqt(), Dr() (+27 more)

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 251 - "SessionCoordinator"
Cohesion: 0.06
Nodes (10): AsciiFastPathTests, StaticString, String, UInt, CodepointRunFastPathTests, .assertAllPathsAgree(_:cols:rows:file:line:), StaticString, String (+2 more)

### Community 252 - "NSViewRepresentable"
Cohesion: 0.12
Nodes (6): PromptQueue, String, SurfaceID, Void, PromptQueueBar, NSWindow

### Community 253 - "Split Right"
Cohesion: 0.06
Nodes (35): BrowserPaneRegistry, BrowserPaneView, .init(coder:), BrowserProgressLine, .init(coder:), .init(frame:), BrowserTabButton, .init(coder:) (+27 more)

### Community 254 - "BoardViewController"
Cohesion: 0.13
Nodes (16): GitStatusType, added, deleted, modified, renamed, unmodified, untracked, NodeRow (+8 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.18
Nodes (14): ProjectGroupWatcher, StreamBox, Bool, DispatchQueue, escaping, FSEventStreamRef, MainActor, Never (+6 more)

### Community 256 - "GitMetadataProvider"
Cohesion: 0.17
Nodes (9): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, FormatColor, String (+1 more)

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.10
Nodes (34): aJ(), bXt(), cJ(), dXt(), F0(), fXt(), gC(), gXt() (+26 more)

### Community 258 - "WindowTitleStripView"
Cohesion: 0.13
Nodes (21): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+13 more)

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.16
Nodes (6): ezt(), GGe, Gwe(), Hzt(), Kp(), urn

### Community 260 - ".welcome"
Cohesion: 0.37
Nodes (3): .block(atPromptLine:), String, TerminalBlockStoreTests

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.13
Nodes (9): NSDraggingInfo, NSDragOperation, PasteController, Bool, NSPasteboard, String, TimeInterval, URL (+1 more)

### Community 262 - ".install"
Cohesion: 0.17
Nodes (21): Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors, ContrastGrade (+13 more)

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.18
Nodes (10): StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength, newline, StdioTransport, AsyncStream, TransportError (+2 more)

### Community 264 - "code:bash (harness-cli install-hooks claude-code)"
Cohesion: 0.13
Nodes (3): KouenGridTerminalTests, String, TerminalGridSnapshot

### Community 265 - "code:bash (harness-cli install-hooks cursor)"
Cohesion: 0.14
Nodes (8): PaneNode, BrowserLeaf, URL, DaemonSyncServiceBrowserPaneMergeTests, PaneID, PaneNode, PaneNodeBrowserTests, PaneNodeLayoutShapeTests

### Community 266 - ".path"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 267 - ".performInstall"
Cohesion: 0.16
Nodes (12): ANSIPalette, CellColorResolver, MochaTheme, ResolvedCellColors, .init(hex:), .init(red:green:blue:alpha:), Bool, Double (+4 more)

### Community 268 - "code:bash (# Old (agent-specific):)"
Cohesion: 0.18
Nodes (20): CoreImage, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription, .surfaceID, detectHost() (+12 more)

### Community 269 - "DefaultTerminalManager"
Cohesion: 0.11
Nodes (4): KouenApp, GitPanelViewFSEventFilterTests, GitPanelViewToastErrorSummaryTests, GitPanelViewWorktreeParsingTests

### Community 270 - "WindowSession"
Cohesion: 0.15
Nodes (5): OnboardingController, CompletionGenerator, String, .fishCompletionSource, CompletionGeneratorTests

### Community 271 - "StatusLineView.swift"
Cohesion: 0.14
Nodes (12): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+4 more)

### Community 272 - "SGRMouseEvent"
Cohesion: 0.07
Nodes (32): _8n(), a7e(), Ac(), cae(), cht(), dae(), dU(), e3n() (+24 more)

### Community 273 - "KeySpec"
Cohesion: 0.10
Nodes (24): AnyTransition, AgentNotchPeekEvent, Reason, errored, finished, needsInput, AgentNotchRootView, .bottomRadius (+16 more)

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.14
Nodes (13): GridCompositor, Configuration, Int32, SessionGroup, SessionID, Tab, TabID, WorkspaceID (+5 more)

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.05
Nodes (23): DispatchSource, KouenDaemonCore, DispatchQueue, DispatchSourceFileSystemObject, Int32, URL, Void, TranscriptFileWatcher (+15 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.19
Nodes (4): BoardCommandTests, BoardModelTests, Tab, String

### Community 277 - ".run"
Cohesion: 0.10
Nodes (20): IssueKeychainStore, Bool, String, IssuePriority, .color, high, low, medium (+12 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.16
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.29
Nodes (4): tool, KouenDaemonToolsTests, String, URL

### Community 280 - ".menu"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.26
Nodes (8): ignoreSIGPIPE(), Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.12
Nodes (3): AgentLaunchCommandsTests, URL, Void

### Community 283 - "FormatColor"
Cohesion: 0.30
Nodes (9): .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release, `repeat`, KeyModifiers, Character, String (+1 more)

### Community 284 - "click_ui_element"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Kouen, Sparkle (+13 more)

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.19
Nodes (10): RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal, FileHandle, Int32 (+2 more)

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.18
Nodes (11): Never, NSRegularExpression, Set, String, Task, URL, Void, WorkspaceSymbolIndex (+3 more)

### Community 287 - ".apply"
Cohesion: 0.16
Nodes (8): CustomEndpointTester, Result, Bool, String, URL, CustomEndpointTesterTests, URLRequest, URLSession

### Community 288 - "AgentHookStrategy"
Cohesion: 0.12
Nodes (12): BrowserIntegrationController, PaneID, NSPoint, NSView, DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any (+4 more)

### Community 289 - "StatusLineWidthTests"
Cohesion: 0.29
Nodes (5): Darwin, Foundation, Glibc, KouenCore, AgentRoutingResolver

### Community 290 - "Process"
Cohesion: 0.17
Nodes (16): SessionRef, byID, byName, next, previous, String, UUID, TargetSpec (+8 more)

### Community 291 - "JSONDecoder"
Cohesion: 0.11
Nodes (11): AgentUsage, .contextTokens, .init(from:), .init(inputTokens:outputTokens:cacheReadTokens:cacheWriteTokens:thinkingTokens:totalCostUSD:), .shortSummary, Decoder, Double, Encoder (+3 more)

### Community 292 - "Release runbook"
Cohesion: 0.12
Nodes (11): OverlayBackground, Context, AgentStatusDot, Context, OverlayBackground, Context, KouenOverlayBackground, CGRect (+3 more)

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.16
Nodes (6): LSPTextLocation, .position, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 294 - "GitHubCLIClient"
Cohesion: 0.13
Nodes (14): BinaryInstaller.DetectionStatus, SetupStepView, .body, .canInstall, .hooksDetail, .hooksTone, .hooksValue, .isSuccess (+6 more)

### Community 295 - "AgentApprovalBar"
Cohesion: 0.15
Nodes (9): _7(), A7(), a8(), bGt(), c8(), ene(), Gnn, IC() (+1 more)

### Community 296 - "NotificationBus"
Cohesion: 0.25
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 297 - "settings.json"
Cohesion: 0.14
Nodes (9): GridCompositorParityTests, LiveCompositorFixture, Bool, String, TerminalGridSnapshot, PortCompositorFixture, Bool, String (+1 more)

### Community 298 - "jobs"
Cohesion: 0.12
Nodes (22): Cjt(), H2e(), hR(), jX(), Kje(), KX(), L7(), Ljt() (+14 more)

### Community 301 - ".parse"
Cohesion: 0.39
Nodes (4): SettingsAdvancedView, .body, Bool, String

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.18
Nodes (10): MainActor, Void, Group, PrefixCheatsheetWindow, PrefixIndicatorWindow, CGFloat, NSTextField, NSWindow (+2 more)

### Community 303 - ".encodeMouse"
Cohesion: 0.33
Nodes (4): MainMenuBuilder, NSMenu, NSMenuItem, Selector

### Community 304 - "00-inception-plan.md"
Cohesion: 0.17
Nodes (5): TabID, WorkspaceID, AgentCommandTests, String, Tab

### Community 305 - ".script"
Cohesion: 0.11
Nodes (18): CodingKeys, excludedPaths, id, name, sourceFolder, CodingKey, CodingKeys, createdAt (+10 more)

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.18
Nodes (15): CellMetrics, ComposedFrame, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth (+7 more)

### Community 307 - "ViPathTokenTests"
Cohesion: 0.17
Nodes (8): AgentListFormatter, Date, String, dvn(), AgentListFormatterTests, Bool, Date, String

### Community 308 - "Send Ex Command"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 309 - "Browser DevTools API (P28)"
Cohesion: 0.12
Nodes (10): EndpointError, connectionFailed, .description, notYetSupported, pathTooLong, String, EndpointConnector, Int32 (+2 more)

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 312 - "AgentSnapshot"
Cohesion: 0.17
Nodes (3): ShellIntegrationTests, .repoRoot, URL

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.22
Nodes (4): String, URL, UUID, WorktreeIsolationDaemonTests

### Community 314 - "code:bash (harness-cli install-hooks codex)"
Cohesion: 0.10
Nodes (17): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+9 more)

### Community 315 - "code:bash (harness-cli install-hooks grok)"
Cohesion: 0.24
Nodes (7): BinaryInstaller, .bundledMacOSDir, Bool, TimeInterval, BinaryInstallerVersionTests, String, URL

### Community 316 - "code:bash (harness-cli install-hooks opencode)"
Cohesion: 0.19
Nodes (11): DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String, StyledSegment (+3 more)

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.16
Nodes (8): brn, grn, hrn(), JGe(), KGe(), prn(), qGe(), zGe()

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.17
Nodes (4): InputEncoder, InputEncoderTests, String, UInt8

### Community 319 - "FormatColor"
Cohesion: 0.19
Nodes (8): Range, String, TerminalGridCell, TerminalBufferMatch, TerminalBufferSearch, String, TerminalGridCell, TerminalBufferSearchTests

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.15
Nodes (8): CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16, UInt8, CharacterWidthTests

### Community 321 - "UInt64"
Cohesion: 0.12
Nodes (17): SessionDividerRowView, .init(coder:), .init(frame:), .init(coder:), .init(frame:), .init(coder:), .init(frame:), .init(coder:) (+9 more)

### Community 322 - "DesktopNotifier"
Cohesion: 0.10
Nodes (17): BoxDrawing, Kind, arms, dashH, dashV, halfDown, halfLeft, halfRight (+9 more)

### Community 323 - "LayoutNode"
Cohesion: 0.10
Nodes (20): Agent Safety Net (Checkpoints, Verification, Write Guards), AI Browser Control (kouen-mcp), Build From Source, Claude Code Harness, CLI, Development Builds, Documentation, Editor & LSP (+12 more)

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.08
Nodes (20): .webView(_:didCommit:), KouenSyntaxResources, BrowserPaneViewTests, MockWebView, .isLoading, .url, Any, Bool (+12 more)

### Community 325 - "FloatingPaneController"
Cohesion: 0.27
Nodes (8): PaneOutputWaiter, PaneOutputWaitResult, Bool, CheckedContinuation, Never, PaneLeaf, Tab, UInt64

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.20
Nodes (16): Close Pane, Next Session, Previous Session, Split Down, Split Right, Cmd W Closes Pane When Split, Zombie Crash Rapid Split Close Cycle, Close Pane Removes Split (+8 more)

### Community 328 - "README.md"
Cohesion: 0.16
Nodes (10): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+2 more)

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.21
Nodes (8): SwarmFleetView, .init(coder:), CGFloat, NSCoder, CGFloat, NSCoder, TaskDashboardView, .init(coder:)

### Community 330 - ".drawGlyph"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.18
Nodes (6): DefaultTerminalLaunchRequest, ShellQuoting, Bool, String, URL, DefaultTerminalLaunchRequestTests

### Community 332 - "Added"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 333 - "RealPty"
Cohesion: 0.15
Nodes (9): Bool, Int32, String, URL, SystemdUserInstaller, .backendName, .isInstalled, .unitURL (+1 more)

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.21
Nodes (7): EnvironmentStore, Persisted, String, URL, global, EnvironmentStoreTests, URL

### Community 335 - ".makeModel"
Cohesion: 0.11
Nodes (10): ClaudeAdapter, UUID, HeadlessCLIAdapter, HeadlessRunEvent, assistantText, result, sessionID, Bool (+2 more)

### Community 336 - "run.sh"
Cohesion: 0.16
Nodes (16): SwarmFleetSnapshot, SwarmLane, pty, structured, SwarmTaskNode, SwarmTaskStatus, cancelled, failed (+8 more)

### Community 337 - "CommandExecutionError"
Cohesion: 0.16
Nodes (11): LayoutFileStore, LayoutNode, branch, leaf, LayoutTemplate, Date, Double, PaneNode (+3 more)

### Community 338 - "CSIParams"
Cohesion: 0.13
Nodes (3): MenuTarget, String, MenuTargetForkConversationTests

### Community 339 - "Foundation"
Cohesion: 0.15
Nodes (3): CellColorResolverTests, .resolver, CellColorResolver

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

### Community 342 - "Added"
Cohesion: 0.24
Nodes (9): ANSIPalette, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors, Bool, Double, TerminalGridCell (+1 more)

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 344 - "FileViewerViewController"
Cohesion: 0.21
Nodes (4): ReleaseNotes, Section, String, .sampleNotes

### Community 345 - "README.md"
Cohesion: 0.19
Nodes (9): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+1 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.19
Nodes (13): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Bool, Duration (+5 more)

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.24
Nodes (15): Decodable, AssistantLine, Content, Message, ResultLine, Bool, Double, String (+7 more)

### Community 348 - "DaemonLifecycleTests"
Cohesion: 0.21
Nodes (9): NWEndpoint, MobileBridgeServer, Bool, NWListener, Sendable, String, UInt16, start() (+1 more)

### Community 349 - "Contents.json"
Cohesion: 0.21
Nodes (4): KeyTokenParser, Bool, String, KeyTokenParserTests

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.18
Nodes (13): FeaturePhase, architect, completed, dev, interview, qaDesign, qaVerify, .title (+5 more)

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.14
Nodes (19): BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, CodingKeys, description, key (+11 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.29
Nodes (3): ReleaseNotesGuardTests, .changelog, String

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.33
Nodes (4): Run, String, TerminalBanner, WelcomeConfig

### Community 355 - ".deepMerge"
Cohesion: 0.07
Nodes (15): ScreenPos, bottom, middle, top, KouenLSP, FileGraphInfo, GraphifyLSPBridge, Double (+7 more)

### Community 357 - ".handleCat"
Cohesion: 0.22
Nodes (6): ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 359 - "OcclusionTests"
Cohesion: 0.16
Nodes (5): SQLite3, AgentHistoryMultiAgentCoverageTests, Bool, String, URL

### Community 360 - "State"
Cohesion: 0.20
Nodes (3): String, TerminalGridSnapshot, VTConformanceCorpusTests

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.17
Nodes (9): GitStatusProvider, OnceResume, Bool, Duration, String, TimeInterval, GitStatusProviderLargeOutputTests, URL (+1 more)

### Community 362 - "RGBColor"
Cohesion: 0.17
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.19
Nodes (8): Logger, OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, Bool, UInt64

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.22
Nodes (4): GroupedSessionTests, SessionGroup, Set, SurfaceID

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.17
Nodes (14): AgentIconRenderer, Scanner, .atEnd, SVGPathParser, Bool, CGFloat, CGPath, CGPoint (+6 more)

### Community 366 - "Consumers"
Cohesion: 0.18
Nodes (8): NSHostingView, NSLayoutConstraint, TerminalTabBarView, .delegate, .init(frame:), .leadingInset, .mouseDownCanMoveWindow, .trailingInset

### Community 367 - "DaemonStats"
Cohesion: 0.20
Nodes (12): dhn(), Eme(), fhn(), ghn(), jUe(), kr(), Mme(), NR() (+4 more)

### Community 368 - "Tab"
Cohesion: 0.11
Nodes (5): KouenCLI, HistorySearchQueryTests, MemoCommandTests, URL, TaskCommandTests

### Community 369 - "Git Panel"
Cohesion: 0.20
Nodes (10): PaneRef, bottom, byID, byIndex, last, left, next, previous (+2 more)

### Community 370 - ".encode"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.19
Nodes (8): AgentRemoteControlDaemonService, Set, String, Void, AgentRemoteControlDaemonServiceTests, LogBox, .count, String

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.36
Nodes (6): ClaudeRunSummary, Date, Double, Int32, String, UUID

### Community 373 - "Prompt"
Cohesion: 0.29
Nodes (4): SwarmDAGStore, String, UUID, SwarmDAGStoreTests

### Community 374 - ".run"
Cohesion: 0.29
Nodes (9): AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand, Bool, Set (+1 more)

### Community 375 - ".install"
Cohesion: 0.18
Nodes (14): Array, Bool, Date, Decoder, PaneID, PaneNode, String, TabID (+6 more)

### Community 376 - "ScrollReuseTests"
Cohesion: 0.26
Nodes (3): String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 380 - "PromptQueue"
Cohesion: 0.21
Nodes (4): Bool, String, SurfaceID, TimeInterval

### Community 381 - "smoke-dmg.sh"
Cohesion: 0.17
Nodes (5): .snapshot, Bool, String, ThemeService, KouenOptions

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.18
Nodes (8): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.17
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.36
Nodes (3): .agentInfo(forWorktreePath:tabs:), Tab, GitPanelViewWorktreeAgentTests

### Community 385 - "INDEX.md"
Cohesion: 0.10
Nodes (13): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+5 more)

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.13
Nodes (15): .agentInfo(forWorktreePath:), AgentNotchPeekDecider, RowState, Bool, String, AgentActivity, awaiting, errored (+7 more)

### Community 387 - "User Profile"
Cohesion: 0.30
Nodes (4): CellOverlayTests, IndexSet, String, UInt64

### Community 388 - "Darwin"
Cohesion: 0.12
Nodes (15): agy, claude, codex, copilot, hermes, kouen, __kouen_agy_next, __kouen_claude_next (+7 more)

### Community 389 - "HarnessCLITests"
Cohesion: 0.17
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, Bool, Double (+3 more)

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.19
Nodes (10): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+2 more)

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.25
Nodes (8): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String

### Community 392 - "build-release.sh"
Cohesion: 0.18
Nodes (13): Profile, edit, readonly, Run, RunState, cancelled, failed, running (+5 more)

### Community 393 - "create-dmg.sh"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 394 - "finalize-release.sh"
Cohesion: 0.15
Nodes (6): Bool, NSEvent, NSEvent, SidebarTitlebarHeaderView, .mouseDownCanMoveWindow, NSEvent

### Community 395 - "generate-app-icon.sh"
Cohesion: 0.20
Nodes (4): TerminalModes, .encode(text:modifiers:modes:), Bool, .appCursor

### Community 396 - "generate-appcast.sh"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 397 - "measure-fluidity.sh"
Cohesion: 0.14
Nodes (13): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+5 more)

### Community 398 - "preview.sh"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 399 - "sign-and-notarize.sh"
Cohesion: 0.18
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 400 - "install-linux.sh"
Cohesion: 0.30
Nodes (7): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection, AgentKind

### Community 401 - "package-app.sh"
Cohesion: 0.20
Nodes (7): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, FileChangeWatcherTests

### Community 402 - "View"
Cohesion: 0.21
Nodes (5): NSRangePointer, Any, NSAttributedString, NSRange, NSRect

### Community 403 - "PresentAttempt"
Cohesion: 0.25
Nodes (8): .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didStartProvisionalNavigation:), LoadCompletionState, CheckedContinuation, Error, TimeInterval, WKNavigation

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.24
Nodes (11): Close Tab, New Tab, Cmd Shift W Force Closes Tab, Cmd T Creates New Session, Cmd W Closes Tab When Single Pane, Window Survives Full Shortcut Sequence, Zombie Crash Close Tab While Typing, Zombie Crash Rapid Close While Typing (+3 more)

### Community 405 - "AgentIconRenderer"
Cohesion: 0.19
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 406 - "main.swift"
Cohesion: 0.22
Nodes (7): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController

### Community 407 - "Fixed"
Cohesion: 0.32
Nodes (6): LSPFileSession, Never, String, Task, URL, Void

### Community 408 - "IPC Architecture"
Cohesion: 0.14
Nodes (7): KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, BinaryInstallerDisplayTests, OnboardingEnvironmentTests

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.22
Nodes (10): DotView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor, NSRect (+2 more)

### Community 410 - ".applyTerminalIdentity"
Cohesion: 0.34
Nodes (8): CGFloat, Range, Tab, TabBarLayoutMetrics, .pitch, TerminalTabBarBody, .body, TerminalTabBarModel

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.23
Nodes (13): kouen.bash script, agy(), claude(), codex(), copilot(), hermes(), kouen(), __kouen_agy_next() (+5 more)

### Community 412 - "go.json"
Cohesion: 0.21
Nodes (10): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+2 more)

### Community 413 - "javascript.json"
Cohesion: 0.25
Nodes (4): Security, KouenMCPServer, Bool, String

### Community 414 - "json.json"
Cohesion: 0.08
Nodes (12): ListeningPortScanner, Int32, Set, String, result, tab, .tab(for:), AgentScanner (+4 more)

### Community 415 - "markdown.json"
Cohesion: 0.25
Nodes (7): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, NSEvent

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.27
Nodes (9): SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, Int32, String (+1 more)

### Community 417 - "rust.json"
Cohesion: 0.23
Nodes (7): InstallResult, Shell, bash, fish, zsh, Bool, URL

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.20
Nodes (7): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, NSCoder, Void

### Community 419 - "typescript.json"
Cohesion: 0.20
Nodes (13): ern(), G4(), G7(), Jnn(), nrn(), Qnn(), sHe(), trn() (+5 more)

### Community 420 - "yaml.json"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.23
Nodes (4): StatusLineWidthTests, StatusLineWidth, String, StyledSegment

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
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 428 - "TaskDashboardView"
Cohesion: 0.22
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.33
Nodes (6): SurfaceProgressTracker, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.31
Nodes (6): Bool, Counter, Scheduled, SurfaceProgressTrackerTests, DispatchWorkItem, TimeInterval

### Community 431 - "BoardCardView"
Cohesion: 0.21
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 432 - "PathToken"
Cohesion: 0.24
Nodes (8): ProjectDropTarget, .init(coder:), .init(frame:), NSCoder, NSDraggingInfo, NSDragOperation, NSRect, URL

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.34
Nodes (3): Install, Shell integration (OSC 133 semantic prompts), What gets emitted

### Community 434 - "Project History"
Cohesion: 0.14
Nodes (14): Agent handbook — Kouen (extended reference), Agent integration, Build and test, IPC, Keyboard shortcuts, kouen-cli, Native terminal renderer, Repository map (+6 more)

### Community 435 - ".init"
Cohesion: 0.12
Nodes (19): AgentHistoryFTSIndex, .deleteSession(sessionID:), .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:surfaceTag:topicSegments:), .needsReindex(sessionID:mtime:fileSize:), .pruneMissingSessions(validTranscriptPaths:), .saveRecord(_:mtime:fileSize:), .search(query:limit:), .searchRanked(query:limit:includeSnippet:) (+11 more)

### Community 436 - "WaitForRegistry"
Cohesion: 0.10
Nodes (7): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T, String

### Community 437 - "PickerItemRow"
Cohesion: 0.41
Nodes (7): FeatureSummary, FeatureTaskSummary, GateSummary, Bool, Date, String, UUID

### Community 438 - "SessionEditor"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 439 - "SetupStepView"
Cohesion: 0.23
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 440 - "LegacySnapshot"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 441 - "RemoteHostStore"
Cohesion: 0.24
Nodes (9): Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock, .block(id:) (+1 more)

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 443 - "main.swift"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 445 - "Section"
Cohesion: 0.15
Nodes (11): copyMode, esc(), fs, globalShortcuts, KEYBINDINGS, prefixTable, renderTable(), ROOT (+3 more)

### Community 447 - "PaletteMode"
Cohesion: 0.30
Nodes (5): SearchBenchmarks, String, UInt64, URL, Void

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.21
Nodes (6): String, TerminalGridCell, TextGrid, .totalLines, .viewportRows, WordColumnRangeTests

### Community 449 - "PresentAttempt"
Cohesion: 0.27
Nodes (9): Command Prompt, Find In Files, Git Panel, Open Command Palette, Switch To Session 1, Switch To Session 2, Rapid Session Switch While Typing, Switch Between Isolated And Normal Session (+1 more)

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.18
Nodes (13): Branch Change In Shared Folder Is Not Isolated Unprompted, CLI Isolate Creates Worktree And Session, CLI Isolate With Custom Branch Name, Close Session Keeps Dirty Worktree, Close Session Removes Clean Worktree, Create Isolated Session And Select, Git Checkout In Normal Session Does Not Affect Isolated, Isolate Without Branch Uses Detached HEAD (+5 more)

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.19
Nodes (9): NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView, .cornerConfiguration (+1 more)

### Community 454 - ".recordReapedGenerationForTesting"
Cohesion: 0.27
Nodes (7): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8

### Community 457 - ".normalizedKey"
Cohesion: 0.20
Nodes (9): CodingKeys, cacheReadTokens, cacheWriteTokens, contextTokens, inputTokens, outputTokens, shortSummary, thinkingTokens (+1 more)

### Community 458 - "FileTreeKeyboardNavigator"
Cohesion: 0.23
Nodes (9): AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor (+1 more)

### Community 459 - ".encode"
Cohesion: 0.22
Nodes (6): String, URL, ThemeCatalogEmbedTests, .embedSwift, .repoRoot, .sourceJSON

### Community 460 - "RunState"
Cohesion: 0.12
Nodes (8): JSONDecoder, JSONEncoder, ReplayStep, Bool, Double, TerminalRecordingCodec, TerminalReplay, TerminalRecordingTests

### Community 461 - ".worktreeList"
Cohesion: 0.37
Nodes (4): KouenFeatureMarkdownSync, Bool, String, URL

### Community 462 - "AGENTS.md"
Cohesion: 0.42
Nodes (6): InstallResult, ShellCompletionInstaller, Bool, String, URL, ShellIntegration

### Community 463 - ".deinit"
Cohesion: 0.21
Nodes (5): FDWatchdog, DispatchSourceTimer, String, TimeInterval, FDWatchdogTests

### Community 464 - "MouseButton"
Cohesion: 0.18
Nodes (4): ClaudeSessionMode, ClaudeSessionModeTests, URL, Void

### Community 465 - "DirectionalAxis"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 466 - "PlatformSys.swift"
Cohesion: 0.25
Nodes (5): irn(), mrn, _rn(), rrn(), srn()

### Community 467 - ".moveSelection"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 469 - "PresentAttempt"
Cohesion: 0.14
Nodes (8): BellScanState, esc, normal, stringEsc, SurfaceMonitor, BellScanTests, Bool, UInt8

### Community 470 - "DispatchTime"
Cohesion: 0.26
Nodes (4): PaneLabelDaemonTests, String, URL, UUID

### Community 472 - "start.sh script"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 473 - "HarnessOnboarding"
Cohesion: 0.29
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 474 - "String"
Cohesion: 0.20
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

### Community 475 - ".hitTest"
Cohesion: 0.27
Nodes (4): HintModeOverlay, Any, NSEvent, String

### Community 476 - "ProjectDropTarget"
Cohesion: 0.23
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 477 - ".encode"
Cohesion: 0.30
Nodes (7): Bool, NSPasteboard, NSString, String, URL, TerminalServicesProvider, AutoreleasingUnsafeMutablePointer

### Community 479 - "ScrollbackTests"
Cohesion: 0.20
Nodes (9): BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool, CGFloat, NSCoder, NSPoint (+1 more)

### Community 480 - "Command Prompt Architecture"
Cohesion: 0.13
Nodes (12): clamp(), Date, Never, T, Task, Void, TabPillView, .dragGesture (+4 more)

### Community 481 - ".testKouenRendererFixtureDefaultTextReportsPlausibleGlyphStats"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 482 - ".resolve"
Cohesion: 0.17
Nodes (11): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile, regionEdit (+3 more)

### Community 483 - "Changed"
Cohesion: 0.11
Nodes (6): .tab(forSurfaceKey:), .surfaceTelemetry, WriteOrigin, automation, human, AgentSessionSummaryTests

### Community 484 - "CopilotAdapter"
Cohesion: 0.26
Nodes (5): Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 485 - ".testKouenRendererFixtureLigatureShapingPathReportsPlausibleGlyphs"
Cohesion: 0.22
Nodes (5): RepoResolver, Bool, String, RepoResolverTests, String

### Community 486 - "TabPillView"
Cohesion: 0.14
Nodes (13): SwarmFleetBody, .body, SwarmNodeRowView, .body, .statusColor, Duration, Void, SwarmFleetSnapshotWire (+5 more)

### Community 487 - "bC"
Cohesion: 0.36
Nodes (4): Bool, String, UUID, TaskDaemonBridge

### Community 488 - "ccRunCancel"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 489 - "SurfaceIO"
Cohesion: 0.17
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 490 - "ccRunGet"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 491 - ".update"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 493 - "ccRunStart"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 494 - "ccRunInfo"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 495 - ".makeDiffScrollView"
Cohesion: 0.33
Nodes (4): Bool, NSColor, SessionGroup, String

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.24
Nodes (5): RiskyCommandClassifier, Bool, NSRegularExpression, String, RiskyCommandClassifierTests

### Community 497 - ".bind"
Cohesion: 0.29
Nodes (6): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Carbon

### Community 498 - ".automationList"
Cohesion: 0.23
Nodes (3): TabID, WorkspaceID, GitPanelViewWorktreeNavigationTests

### Community 499 - "ProjectConfig"
Cohesion: 0.18
Nodes (11): Typography, .badge, .kbd, .paletteHeader, .paletteTitle, .rowMeta, .rowTitle, .sectionLabel (+3 more)

### Community 500 - "zO"
Cohesion: 0.18
Nodes (10): Architecture Decisions (dated log), Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Post-P50 changes (v4.20.2 → v4.20.11, 2026-10-01 → 2026-10-06), Product Identity Guardrail: Terminal, Not IDE, Shipped capability summary, P44–P49 (2026-08-31 → 2026-09-23) (+2 more)

### Community 501 - "Fixed"
Cohesion: 0.20
Nodes (8): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, ClosedRange, String

### Community 502 - "ACP Client (Shelved)"
Cohesion: 0.18
Nodes (9): .effectiveResumeCommand(mode:), AgentLaunchCommands, AgentSessionMode, cloud, .launchCommand, .launchFlags, local, remoteControl (+1 more)

### Community 503 - "ReleaseNotesGuardTests"
Cohesion: 0.13
Nodes (10): CGImage, data, DecodedImage, .byteCount, ImageLimits, Bool, UInt8, ImageDecoder (+2 more)

### Community 504 - "WindowBorderOverlayView"
Cohesion: 0.25
Nodes (6): OptionSet, .description, .init(key:modifiers:), Modifiers, String, UInt8

### Community 505 - ".tickFeatureWorktreeSweepLocked"
Cohesion: 0.12
Nodes (7): CSIParams, .count, Pen, SavedCursor, TerminalGridColor, TerminalGridUnderline, UInt8

### Community 506 - "SwarmFleetBody"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.28
Nodes (4): RemoteControlURLProvider, Bool, URL, RemoteControlURLProviderTests

### Community 508 - "qLt"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 509 - "start.mjs"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 510 - "PromptQueue"
Cohesion: 0.25
Nodes (6): calculate(), constructor(), kOt(), mBt, r2e(), sOt()

### Community 511 - ".panePathLookup"
Cohesion: 0.22
Nodes (5): FormatContextDaemonTests, PaneID, String, SurfaceID, URL

### Community 512 - ".setAttribute"
Cohesion: 0.18
Nodes (3): MobileBridgeAttachFileTests, String, URL

### Community 513 - "ThemeDocument"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.18
Nodes (10): Bug 1 - Rotation Grace Slot Keeps The Previous Token Redeemable, Bug 1 - Rotation Shifts The Outgoing Token Into The Grace Slot, Bug 1 - Stop Fully Clears The Grace Slot, Bug 1 - Token Lifetime Not Regressed Below The Human-Flow Window, Bug 2 - Client onerror Does Not Clobber The Server Error Banner, Bug 2 - No Abrupt Cancel Immediately After The Error Text, Bug 2 - Reject Path Closes Gracefully With Policy-Violation Code 1008, Bug 3 - QR Not Printed When No Listener Is Ready (+2 more)

### Community 515 - "RD"
Cohesion: 0.17
Nodes (12): AnimatablePair, .body, HorizontalInsetRect, CGRect, Path, NotchShape, .animatableData, CGFloat (+4 more)

### Community 516 - "terminal_stress_runner.py"
Cohesion: 0.15
Nodes (14): SettingsTerminalView, .body, .experienceSection, .fontReadout, .fontSection, .shellSection, Bool, String (+6 more)

### Community 517 - "GroupedSessionDaemonTests"
Cohesion: 0.38
Nodes (3): DataBox, GitPanelViewDiffErrorTests, String

### Community 518 - "Bool"
Cohesion: 0.36
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 519 - ".gestureRecognizer"
Cohesion: 0.25
Nodes (7): statusColor(), TabStatus, done, error, idle, running, waiting

### Community 520 - "WriteOutcome"
Cohesion: 0.40
Nodes (4): SplitDirection, TabID, .body, TerminalTabBarDelegate

### Community 521 - ".daemonIsStale"
Cohesion: 0.24
Nodes (3): KouenMCP, KouenBrowserToolsTests, URL

### Community 522 - "ShellCompletionInstallerTests"
Cohesion: 0.29
Nodes (3): FormatStyle, FormatColor, StyledSegment

### Community 523 - "fFe"
Cohesion: 0.36
Nodes (7): daemonLog(), detectStaleInstance(), installSignalHandlers(), removeForeignPIDFile(), Sendable, String, writePIDFile()

### Community 524 - "TerminalColorRole"
Cohesion: 0.31
Nodes (4): GraphifyIndexCache, S, Set, String

### Community 526 - "Kind"
Cohesion: 0.25
Nodes (8): CodingKeys, cols, createdAt, dataBase64, rows, timeMs, type, version

### Community 527 - ".show"
Cohesion: 0.11
Nodes (17): Kind, input, metadata, output, resize, RecordingEvent, input, metadata (+9 more)

### Community 528 - "worktree_review_dashboard.robot"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 529 - "WorktreeAutoIsolateService"
Cohesion: 0.31
Nodes (5): AgyAdapter, Result, ResultLine, String, UUID

### Community 530 - "HarnessChrome"
Cohesion: 0.29
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

### Community 531 - "BrowserProgressLine"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 532 - "OpenClaw → Kouen"
Cohesion: 0.29
Nodes (8): FormatColor, none, palette, rgb, StyledSegment, Bool, String, UInt8

### Community 533 - "flushSessionState"
Cohesion: 0.06
Nodes (36): A1(), aat(), b2(), bw(), c5n(), d6(), et(), FBe() (+28 more)

### Community 535 - "AgentNotification"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 536 - ".readGrid(scrollbackOffset:)"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 537 - "NSObject"
Cohesion: 0.25
Nodes (5): Bool, NSEvent, ViInputMode, insert, normal

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.24
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 539 - "install-app.sh"
Cohesion: 0.33
Nodes (4): GridCompositorCopyModeTests, PaneRect, String, TerminalGridSnapshot

### Community 540 - ".applyStyleDirective"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 541 - ".init"
Cohesion: 0.36
Nodes (5): PaneLeaf, SessionGroup, Any, String, Tab

### Community 543 - ".bufferLine"
Cohesion: 0.24
Nodes (3): Bool, SurfaceID, MenuTargetPeerReviewTests

### Community 544 - "CodingKeys"
Cohesion: 0.19
Nodes (8): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow, NSImage, NSHostingController

### Community 545 - ".characterIndex"
Cohesion: 0.24
Nodes (6): statusHelp(), Configuration, String, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, tabDisplayTitle()

### Community 546 - "LegacySnapshot"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 547 - "NSObject"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Key spec syntax, Kouen keybindings, Persistence (+1 more)

### Community 548 - ".encode"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 549 - ".init(from:)"
Cohesion: 0.33
Nodes (4): OutputTrigger, OutputTriggerStore, Bool, String

### Community 550 - ".init(hex:)"
Cohesion: 0.11
Nodes (14): AgentBadgeView, .body, Bool, CGFloat, JobResultSheetView, .body, KouenIPC, MobileBridgeServer (+6 more)

### Community 552 - "worktree_auto_isolate_wiring.robot"
Cohesion: 0.22
Nodes (8): Build order (unchanged from interview decision), G1 — @ file-path picker, G2 — shell tab-completion suggestion strip (heuristic, explicitly best-effort), G3 — AI command suggestion (via `claude` CLI subprocess), Logical Design, P37 Phase G — Autocomplete (mobile bridge), Strategic Design, Tactical Design

### Community 553 - "harness.resource"
Cohesion: 0.22
Nodes (8): Artifacts, Client Application — Slice 1 (stacked panes, no persistence), Client Application — Slice 2 (per-workspace divider memory), Context, Dev Task Progress — Workspace Sidebar Panels (P42), Integration, Note on task re-sequencing (2026-07-17), Summary

### Community 554 - "eFe"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 555 - "code:bash (harness view <file>                        # syntax-highligh)"
Cohesion: 0.31
Nodes (6): TerminalGridCell, ThaiClusterCopyTests, ThaiGrid, .columns, .totalLines, .viewportRows

### Community 557 - ".viewWillMove"
Cohesion: 0.22
Nodes (8): MCP Control Allowed With Env Var, MCP Control Denied Without Env Var, MCP KouenBoard Returns Columns, MCP KouenList Returns Sessions, MCP ReadPaneOutput Returns Content, Run MCP Request, Run MCP Request Allowed, Run MCP Request Denied

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.22
Nodes (7): block, escFn, lineFilter, md, page, script, swift

### Community 560 - ".zoomWindowIfDoubleClick"
Cohesion: 0.36
Nodes (7): Document, Bool, Set, String, URL, ToolPolicy, .defaultURL

### Community 561 - ".handleClaudeCode"
Cohesion: 0.25
Nodes (7): Agent Memory, Graphify, graphify, kouen-terminal — Agent Instructions, Rules (read when triggered), Session Start, Skills & Rules

### Community 563 - "AgentNotchViewModel.swift"
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

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.39
Nodes (5): AutomationSummary, Bool, Date, String, UUID

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.21
Nodes (5): aD(), crn, ELt(), n2e(), PF()

### Community 571 - "ShellIntegrationTests"
Cohesion: 0.38
Nodes (3): SettingsFileSearchSection, .body, String

### Community 573 - "tHe"
Cohesion: 0.15
Nodes (8): _Bt(), by(), e7e(), fst(), hxn(), lxn(), sBt, XWt()

### Community 574 - ".applyFontSize"
Cohesion: 0.25
Nodes (7): Claude Code hook push (in-process Task subagent detection), Client UI indicator, Detection core (AgentDetector, pure logic), IPC / Tab plumbing, P38 Phase B — Subagent Visibility — Dev Task Progress, Status: Rewritten 2026-07-14 after original implementation (tasks 1-5) was lost to a concurrent git operation before commit. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 575 - ".toastErrorSummary"
Cohesion: 0.25
Nodes (7): Original overlay build (built 2026-07-14, gated green, then deleted 2026-07-15 mid live-test), P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress, Pivot — merge into the Recipes picker (2026-07-15), Stage 1-2 — Engine/surface plumbing (built 2026-07-14, unchanged by the pivot, still in use), Status: Implementation pivoted mid-phase from a standalone overlay to a merge into the existing, Summary, Thread grouping — Zed framing folded into the same picker (2026-07-15)

### Community 576 - "Phase67Tests"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 577 - "SwarmFleetView"
Cohesion: 0.25
Nodes (7): #kouen, #practice, #score, #shell, #total, #unix, #vim

### Community 578 - "TaskDashboardBody"
Cohesion: 0.36
Nodes (3): KouenSplitViewTests, LayoutProbeView, CGFloat

### Community 579 - "main.swift"
Cohesion: 0.25
Nodes (3): FlushSessionStateTests, String, URL

### Community 580 - "ViInputMode"
Cohesion: 0.29
Nodes (7): Toggle Sidebar, Sidebar Toggle Works, Board CLI Shows Columns, Board CLI Shows Running After Long Command, Board Columns Visible After Click, Board Tab Accessible In Sidebar, Split Pane And Resize

### Community 581 - "jD"
Cohesion: 0.25
Nodes (7): Browser Pane Open Close Rapid, File Preview Open Close, Git Fetch Shows Toast, Launch Kouen Staging, Memory Stability After 30 Seconds, Quit Kouen Staging, Sidebar Toggle Immediately After Launch

### Community 589 - "Endpoint"
Cohesion: 0.10
Nodes (21): AgentNotchRowSummary, RowKind, agent, session, Date, PaneID, SurfaceID, UUID (+13 more)

### Community 590 - "lrn"
Cohesion: 0.29
Nodes (7): Agent hooks for Kouen, CLI notification, Example Claude Code hook, Jump to waiting agent, OSC sequences (from terminal output), Per-agent guides, Set up via your IDE (copy/paste prompt)

### Community 591 - "GitPanelViewWorktreeTaskTests.swift"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 592 - "commit-push.sh"
Cohesion: 0.29
Nodes (7): 1. Plain Terminal, 2. Persistent Terminal, 3. Full Terminal, 4. Agent Workspace, Experience modes, Opting into the prefix + status line without switching modes, Persistence (ephemeral vs. persistent)

### Community 593 - "dO"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Kouen-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 594 - "r2"
Cohesion: 0.33
Nodes (3): DisplayWidth, String, Unicode

### Community 595 - "full-cycle.sh"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 596 - ".feed(_:)"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 597 - "TerminalColorRole"
Cohesion: 0.57
Nodes (3): ProjectConfig, Bool, String

### Community 598 - ".encode"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 600 - ".groupByRoot"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

### Community 601 - "Hwe"
Cohesion: 0.29
Nodes (6): Locked decisions (user-confirmed), Logical Design, P38 Phase A — Cross-Agent Worktree Diff/Review Dashboard — Design, Strategic Design, Tactical Design, Verification gate (this phase)

### Community 602 - "Build locally"
Cohesion: 0.29
Nodes (6): Logical Design, Next Step, P42 — Workspace Sidebar Panels, Parked (not in scope), Strategic Design, Tactical Design

### Community 603 - "fut"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 606 - "Quick start"
Cohesion: 0.33
Nodes (6): Command, .targetKind, TargetKind, pane, session, window

### Community 608 - "W2"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 609 - "FormatContextDaemonTests"
Cohesion: 0.38
Nodes (6): Cleanup And Quit, Create Config File, No Config File Starts Normally, Script Hot Reload On Save, Script Loads On Startup, Script Syntax Error Does Not Crash

### Community 611 - ".showWorkspaceMenu"
Cohesion: 0.29
Nodes (6): Bug 1 - Browser Pane Deferred Unregister, Bug 1 - Browser Pane Reuse On Rebuild, Bug 2 - New Session Syncs Before Reading Active Tab, Bug 2 - Tab Bar New Tab Also Syncs, Bug 3 - Browser Pane Forces Redraw On Reattach, Build Compiles Successfully

### Community 616 - "bump-version.sh"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 617 - "ScriptFileWatcher"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase D — Kitty Graphics Conformance Slice, Scope (locked), Tests

### Community 618 - "parse"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua), Scope (locked), Tests

### Community 619 - "_0n"
Cohesion: 0.33
Nodes (5): Logical Design, Next Step, P43 — Add Repo/Folder to Workspace, Strategic Design, Tactical Design

### Community 620 - "mS"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 621 - "ViEngine"
Cohesion: 0.60
Nodes (5): main(), printHelp(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 622 - "[1.3.0-vit] - 2026-06-06"
Cohesion: 0.40
Nodes (3): String, URL, WorktreeSignatureTests

### Community 625 - "brt"
Cohesion: 0.47
Nodes (3): URL, TimeoutError, WorktreeLargeOutputRegressionTests

### Community 626 - "cGt"
Cohesion: 0.33
Nodes (5): Kouen LSP Diagnostics Does Not Crash, Kouen LSP Hover Returns Result, Kouen LSP Start Returns JSON, Kouen View Binary Shows Guard Message, Kouen View Prints File Content

### Community 627 - "ActiveTabCloseDisposition"
Cohesion: 0.40
Nodes (3): EUe(), eYt(), tYt()

### Community 629 - "graphify reference: query, path, explain"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 630 - "HGe"
Cohesion: 0.17
Nodes (5): DirectionalAxis, down, left, right, up

### Community 633 - "g_n"
Cohesion: 0.40
Nodes (4): Findings, Sources, What this means for Kouen, Who creates branches / worktrees in AI coding tools

### Community 634 - "qC"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: animateSidebar setContentLeadingInset MainSplitViewController, Source Nodes

### Community 635 - "yDt"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: ProjectCategory FolderScanner ProjectDirectoryTree, Source Nodes

### Community 636 - ".handleCopyModeKey"
Cohesion: 0.40
Nodes (5): CwdAuthorizationError, foreignPathRejected, .message, missingSessionOrCwd, other

### Community 637 - "ClientSummary"
Cohesion: 0.33
Nodes (6): h1t(), hae(), jgn(), pwn(), sfn(), _Ue()

### Community 638 - "inlineTokens"
Cohesion: 0.40
Nodes (5): ColorKind, .base, bg, fg, underline

### Community 641 - "[3.10.0] - 2026-06-27"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 642 - "qut"
Cohesion: 0.60
Nodes (3): .encode(_:modifiers:event:modes:), SpecialKey, insert

### Community 643 - "h7n"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 644 - "clean-state.sh"
Cohesion: 0.40
Nodes (4): Build, Release & Git Workflow, Build / Test / Run, Release packaging order, Worktree constraint

### Community 645 - "KouenBrowserToolsTests"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 646 - "[3.10.1] - 2026-06-27"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 647 - "graphify reference: query, path, explain"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 648 - "PtyDrainCeilingBenchmark"
Cohesion: 0.50
Nodes (5): aze(), cR(), oze(), xGe(), yGe()

### Community 649 - "h$t"
Cohesion: 0.40
Nodes (4): Leak A - Retiring A Host Drops Its AI Controllers, Leak B - Browser Network Capture Is Bounded, Leak C - Every Per-Surface Dict In Coordinator Has Retire Cleanup, Leak D - Every Per-Surface Dict In NotificationCoordinator Is Snapshot-Swept

### Community 653 - "iOn"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

### Community 654 - "BlockContextMenuTests"
Cohesion: 0.50
Nodes (4): Full local signing path (needs a Developer ID cert; not currently used), How this fork actually releases, Release runbook, Scripted flow

### Community 655 - "nht"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 656 - "Jcn"
Cohesion: 0.50
Nodes (3): exclude_hubs, no_viz, wiki

### Community 657 - "clear-runtime-state.sh"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: SSETransport auth token isRunning

### Community 659 - "MobileBridgeBrowserTests"
Cohesion: 0.50
Nodes (3): SplitDirection, horizontal, vertical

### Community 661 - ".compute"
Cohesion: 0.50
Nodes (4): dO(), m8(), rfn(), zfn()

### Community 662 - "New Tab"
Cohesion: 0.67
Nodes (4): FVe(), hJ(), qVe(), Zme()

### Community 663 - "m6e"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 664 - "P37 Phase G — Autocomplete (mobile bridge)"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 665 - "nb"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 666 - "BrowserIntegrationController"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 667 - "[3.3.0] - 2026-06-18"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 668 - "nje"
Cohesion: 0.83
Nodes (3): restart_daemon(), full-cycle.sh script, usage()

### Community 670 - "pie"
Cohesion: 0.50
Nodes (3): Bug 1 - Hunks Button Has Explicit Size Constraints, Bug 1 - Hunks Button Symbol Has A Guaranteed-Valid Fallback, Build Compiles Successfully

### Community 671 - "AntigravityTranscriptTurnsTests"
Cohesion: 0.50
Nodes (3): Guard A - Merge Call Site Never Passes --no-ff, Guard B - No Auto-Resolve Anywhere In The Merge/Conflict Path, Guard C - Merge Conflict State Is Reconciled, Not Just Read Once

### Community 678 - "FormatColor"
Cohesion: 0.50
Nodes (4): PaletteMode, errors, grep, normal

### Community 679 - ".splitPane"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 680 - ".apply"
Cohesion: 0.67
Nodes (3): cat(), Hwe(), kYe()

### Community 681 - ".tabIDsToNotify"
Cohesion: 0.67
Nodes (3): cfn(), fut(), qYe()

### Community 682 - "Workbench commands (IDE-like workflow)"
Cohesion: 0.67
Nodes (3): dht(), k0t(), l1n()

### Community 684 - "iRe"
Cohesion: 0.67
Nodes (3): iRe(), jNt(), zNt()

### Community 2621 - "c1n"
Cohesion: 0.50
Nodes (3): PaneID, PaneLeaf, PaneNode

## Knowledge Gaps
- **2377 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+2372 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1136 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `HarnessOverlayBackground` to `ThemeDocument`, `Changed`, `EngineConformanceTests`, `WriteOutcome`, `TerminalEmulator`, `LSPMessage`, `GitPanelView.swift`, `Changed`, `KittyKeyboardTests`, `VTParser`, `.show`, `HarnessTerminalSurfaceView`, `MetalRendererTests`, `worktree_review_dashboard.robot`, `HarnessChrome`, `code:block1 (Agent shell process)`, `OpenClaw → Kouen`, `CopyModeAction`, `HarnessUILibrary`, `.zoomWindowIfDoubleClick`, `WorktreeManager`, `Harness tmux-style capabilities`, `RGBColor`, `.parse`, `Added`, `SplitPaneCoordinator`, `Sendable`, `install-app.sh`, `Equatable`, `DaemonClient`, `MenuTarget`, `code:bash (harness chat "Use the project map first, then inspect this r)`, `.addTab`, `code:bash (swift build)`, `HarnessSettings`, `CodingKeys`, `HarnessSidebarPanelViewController.swift`, `code:bash (harness view <file>                        # syntax-highligh)`, `HarnessTerminalSurfaceView.swift`, `.buildCommand`, `.normalizedKey`, `HookEvent`, `DaemonServer`, `BrowserResponsePayload`, `.keyEvent`, `Fixed`, `Added`, `HarnessSplitView`, `Cross-terminal output-stress benchmark`, `Added`, `KouenOverlayBackground`, `3.2 สิ่งที่ implement แล้ว`, `ViEngine`, `ComposedCell`, `HarnessCLI+Server.swift`, `PrefixKeymap`, `ShellIntegration`, `.didCompleteSend`, `String`, `.compose`, `XCTestCase`, `sheet-cheat.html`, `Endpoint`, `TerminalProtocolCompatibilityTests`, `Agent handbook — Harness (extended reference)`, `DaemonSubscription`, `r2`, `LSPClient`, `.firstMatch`, `full-cycle.sh`, `TerminalGridCell`, `LSPDiagnostic`, `.cursorPos`, `TerminalModes`, `P2 — Async IPC Refactor: Design Document`, `code:bash (# Terminal 1: Create workspace with long-running job)`, `fut`, `shim.c`, `Harness Usage`, `PaneContainerView`, `4. Technical Architecture`, `DaemonLauncher`, `AnyCodable`, `Recipe`, `Changelog`, `DamageTrackingTests`, `HarnessGridTerminal`, `.firstWaitingTab`, `.encode`, `.reduceMotion`, `PaneNode`, `brt`, `Harness command reference`, `Added`, `Changed`, `ViEngine`, `Pipe`, `HistoryRingBuffer`, `.path`, `GlyphAtlas`, `.currentSize`, `SwiftUI`, `Harness`, `inlineTokens`, `h7n`, `.load`, `code:js (// ~/.config/harness/init.js)`, `CommandTarget`, `.startWatching`, `User Story Mapping (MANDATORY)`, `u0n`, `แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)`, `Added`, `.testPaneLeafLegacyDecodeBackfillsSurfaceTabs`, `How to use Harness from the terminal only (no GUI)`, `PaneStyleSet`, `FileTreeWatcher`, `qAn`, `HarnessDaemonToolsTests`, `What You Must Do When Invoked`, `LiveResizeTests`, `ThaiCombiningMarkTests`, `Added`, `.applyStyleDirective`, `MatchCategory`, `ColorKind`, `AmbientBackground`, `TerminalFindBar`, `CommandPromptController`, `New Tab`, `LiveSession`, `ActiveTabCloseDisposition`, `Added`, `Fixed`, `ReflowCorpusTests`, `.decodeKeySpec`, `BoardCard`, `BinaryRefresherTests`, `AutomationsFleetModelTests`, `LayoutProbeView`, `.rects`, `Added`, `VTConformanceCorpusTests`, `.init`, `Error`, `AppDelegate`, `.setCellPixelSize`, `WrapperOptionBehavior`, `.classify`, `PaletteModel`, `HarnessCLI`, `scheduleRender`, `.testDataFrameEncodeVsJSONBase64Output`, `PaneTarget`, `String`, `.lines`, `GridCompositor`, `ScrollbackFile`, `Prompt`, `TerminalServicesProvider`, `ANSIPalette`, `CellColorResolver`, `HarnessPathDisplay`, `FileChangeWatcher`, `SSHTunnelManagerTests`, `.decide`, `P10 Task: Lazy Scrollback Reflow`, `Added`, `.make`, `graphify reference: commit hook and native CLAUDE.md integration`, `Added`, `[3.5.1] - 2026-06-20`, `.make`, `ThemeDocumentTests`, `.tabs`, `.renderFixture`, `.resize`, `SessionCoordinator`, `NSViewRepresentable`, `Split Right`, `.zoomWindowIfDoubleClick`, `.welcome`, `.install`, `code:bash (harness-cli install-hooks claude-code)`, `.performInstall`, `KeySpec`, `.menu`, `TerminalScrollbarView`, `FormatColor`, `After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md.`, `code:bash (harness-cli install-hooks hermes)`, `.apply`, `AgentHookStrategy`, `Process`, `JSONDecoder`, `Fixes Applied (layered)`, `settings.json`, `PaneNode`, `.jumpToBlock`, `RegressionBugFixTests`, `Send Ex Command`, `Browser DevTools API (P28)`, `Bug: Tab-Switch Black Screen`, `code:bash (harness-cli install-hooks codex)`, `code:bash (harness-cli install-hooks grok)`, `code:bash (harness-cli install-hooks opencode)`, `.navigateCurrentFile`, `paragraph`, `FormatColor`, `Focus Persistence — Per-Session-Tab Pane Focus (RL-043)`, `UInt64`, `DesktopNotifier`, `FloatingPaneController`, `run.sh`, `code:bash (harness-cli install-hooks openclaw)`, `code:bash (harness-cli install-hooks pi)`, `[2.2.3] - 2026-06-09`, `FileViewerViewController`, `DaemonLifecycleTests`, `Contents.json`, `Background Polling & Snapshot Fanout — P22`, `GPU Animation Pattern — Layout Once, GPU Paints`, `.deepMerge`, `SurfaceProgressTracker`, `.handleCat`, `State`, `Git Panel`, `P13 — Embedded Browser Pane (cmux parity)`, `Prompt`, `.install`, `ScrollReuseTests`, `SurfaceProgressTrackerTests.swift`, `PromptQueue`, `smoke-dmg.sh`, `User Profile`, `HarnessCLITests`, `generate-app-icon.sh`, `generate-appcast.sh`, `.applyTerminalIdentity`, `go.json`, `json.json`, `markdown.json`, `FilePreviewCoordinatorTabScopeTests`, `.parseDiffHunks`, `Case: cwd "bleed" — session worktree jumps to wrong dir during builds`, `Competitive Position (as of v3.12.0, 2026-07-02)`, `.init`, `PickerItemRow`, `RemoteHostStore`, `PaletteMode`, `mobile_bridge_pairing_bugs.robot`, `RunState`, `.worktreeList`, `.deinit`, `DirectionalAxis`, `start.sh script`, `String`, `.hitTest`, `ScrollbackTests`, `Command Prompt Architecture`, `CopilotAdapter`, `TabPillView`, `.makeDiffScrollView`, `Fixed`, `ReleaseNotesGuardTests`, `.tickFeatureWorktreeSweepLocked`?**
  _High betweenness centrality (0.283) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `Added` to `SKILL-LOG.md`, `Changed`, `Release runbook`, `Added`, `HarnessSidebarPanelViewController.swift`, `Added`, `Endpoint`, `AgentSessionSummary.swift`, `HarnessOverlayBackground`, `.agentName`, `.id`, `install-linux.sh`, `ViPathTokenTests`, `.keyEvent`, `P25 — iOS/iPadOS Support`, `WorktreeManager`, `RGBColor`?**
  _High betweenness centrality (0.213) - this node is a cross-community bridge._
- **Why does `fbt()` connect `callingPaneTarget` to `CodingKey`, `RenderSchedulerTests`, `PasteBufferStore`, `ViPathTokenTests`?**
  _High betweenness centrality (0.114) - this node is a cross-community bridge._
- **Are the 18 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `RenderScheduler`) actually correct?**
  _`KouenTerminalSurfaceView` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _2397 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.006744499156147481 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.015313041326404356 - nodes in this community are weakly interconnected._