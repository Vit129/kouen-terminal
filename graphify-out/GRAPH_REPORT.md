# Graph Report - review-wave1-critical  (2026-11-14)

## Corpus Check
- 949 files · ~1,054,602 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 20022 nodes · 57797 edges · 2675 communities (1550 shown, 1125 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8454 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `e9763814`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 345 edges
2. `i()` - 318 edges
3. `a()` - 282 edges
4. `SessionCoordinator` - 235 edges
5. `TerminalEmulator` - 229 edges
6. `SurfaceRegistry` - 225 edges
7. `u()` - 217 edges
8. `DaemonClient` - 214 edges
9. `KouenCLI` - 210 edges
10. `IPCRequest` - 208 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 189 areas (208 edges)
2. `Command` - bridges 102 areas (108 edges)
3. `AgentKind` - bridges 87 areas (176 edges)
4. `IPCResponse` - bridges 79 areas (104 edges)
5. `KouenTerminalSurfaceView` - bridges 78 areas (345 edges)
6. `NSView` - bridges 69 areas (193 edges)
7. `SessionCoordinator` - bridges 66 areas (235 edges)
8. `KouenGridTerminal` - bridges 65 areas (117 edges)
9. `SurfaceRegistry` - bridges 64 areas (225 edges)
10. `TerminalEmulator` - bridges 60 areas (229 edges)

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

## Communities (2675 total, 1125 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.01
Nodes (608): _1n(), _1t(), _3e(), _3n(), _5e(), _5n(), _6e(), _8n() (+600 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.01
Nodes (465): l, V, z(), _4n(), a1t(), a5n(), a_n(), aA() (+457 more)

### Community 2 - ".handleNormal"
Cohesion: 0.02
Nodes (343): r, A(), a(), aae(), aDt(), aen(), aHt(), aIt() (+335 more)

### Community 3 - "Changed"
Cohesion: 0.03
Nodes (101): a(), b(), c(), d(), e(), f(), g(), h() (+93 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.04
Nodes (89): Oe(), pe(), X(), ae(), ajt(), azt(), b8(), bat() (+81 more)

### Community 5 - "IPCRequest"
Cohesion: 0.02
Nodes (118): _0t(), _4e(), _6n(), A1(), ag(), ase(), ast(), aTn() (+110 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.05
Nodes (30): .tab(forSurfaceKey:), AgentScanner, Bool, DispatchSourceTimer, TimeInterval, DaemonCommandExecutor, Command, .init(forTesting:) (+22 more)

### Community 7 - "Command"
Cohesion: 0.06
Nodes (31): TerminalModes, InputEncoder, .encode(_:modifiers:event:modes:), .encode(text:modifiers:modes:), .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release (+23 more)

### Community 8 - "LSPMessage"
Cohesion: 0.06
Nodes (37): decodeBoundedCString(), ignoreSIGPIPE(), makeUnixStreamSocket(), setNoSigPipe(), CChar, Int32, sockaddr, socklen_t (+29 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.08
Nodes (45): MTLClearColor, MTLCommandBuffer, MTLLibrary, MTLRenderCommandEncoder, MTLRenderPipelineState, Int, ImageTextureCache, MTLDevice (+37 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.09
Nodes (9): KouenTerminalSurfaceView, .receive(_:), DispatchSemaphore, DispatchWorkItem, NSWindow, KouenTerminalSurfaceWorkerTests, Bool, LiveResizeTests (+1 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.06
Nodes (51): AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, CodingKeys, excludedPaths (+43 more)

### Community 12 - "Changed"
Cohesion: 0.03
Nodes (85): a0n(), b3e(), bd(), ble(), bXe(), c6(), c6n(), cV() (+77 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.12
Nodes (13): KouenGridTerminal, TerminalDamage, RenderColor, MetalRendererTests, RenderedFixture, Bool, MTLDevice, MTLTexture (+5 more)

### Community 14 - "VTParser"
Cohesion: 0.04
Nodes (65): AgentRow, .agentColor, .executables, .hookButton, .hookButtonTitle, SettingsAgentsView, .agentsSection, .body (+57 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.03
Nodes (81): _7n(), a2(), a9e(), abt(), akn(), avn(), aXe(), bee() (+73 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.06
Nodes (15): IndexingIterator, LayoutTemplate, SessionEditor, .tabIndex(surfaceID:), SessionID, GroupedSessionTests, SessionGroup, Set (+7 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.04
Nodes (77): aat(), AS(), c5n(), cc(), d0(), d2(), d6(), dce() (+69 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.06
Nodes (45): clamp(), DotView, .init(coder:), .init(frame:), statusHelp(), Bool, CGFloat, Context (+37 more)

### Community 19 - "SpecialKey"
Cohesion: 0.07
Nodes (26): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, AutomationScheduler (+18 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.08
Nodes (20): DaemonClient, Int32, TimeInterval, UUID, ClaudeCodeHarnessIPCTests, String, URL, DaemonContentionTests (+12 more)

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.09
Nodes (6): KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), SpawnedAgentSurface, ISO8601DateFormatter, String, UUID

### Community 22 - "CopyModeAction"
Cohesion: 0.10
Nodes (12): .agentColorBinding, colors, PerformanceBenchmarks, SurfaceOffMainStallSample, Bool, Double, MTLDevice, MTLTexture (+4 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.06
Nodes (35): .body, MainActor, Void, SessionDividerRowView, .init(coder:), .init(frame:), SessionGroupHeaderRowView, .init(coder:) (+27 more)

### Community 24 - ".request"
Cohesion: 0.10
Nodes (32): .saveRecordsBatch(_:), CachedSessionEntry, AgentHistoryScanner, .parseAntigravityTranscript(sessionID:fileURL:), .parseAntigravityTranscript(sessionID:fileURL:toIndex:), .parseClaudeTranscript(fileURL:), .parseClaudeTranscript(fileURL:toIndex:), .parseCodexTranscript(fileURL:surfaceTag:ftsIndex:) (+24 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.09
Nodes (10): SGRMouseEvent, Bool, Bool, Command, DispatchWorkItem, PaneID, SessionGroup, String (+2 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.08
Nodes (29): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, PaletteMode, errors (+21 more)

### Community 27 - "RGBColor"
Cohesion: 0.11
Nodes (15): .addSurface(tabID:paneID:), .addSurface(to:paneID:surfaceID:cwd:), .tab(containingPaneID:), .tab(for:), .tabIndex(surfaceKey:), .tabIndex(tabID:), .tabIndex(workspaceID:tabID:), Bool (+7 more)

### Community 28 - ".parse"
Cohesion: 0.05
Nodes (25): item, input, .readJSONLLines(from:fromOffset:), ClaudeSessionLocator, ClaudeTranscriptLine, Role, assistant, user (+17 more)

### Community 29 - "Added"
Cohesion: 0.08
Nodes (41): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+33 more)

### Community 30 - "Notification"
Cohesion: 0.08
Nodes (21): Data, DecodedReplyFrame, output, reply, DecodedRequestFrame, input, request, FrameError (+13 more)

### Community 31 - "Sendable"
Cohesion: 0.07
Nodes (28): AppKit, CoreGraphics, CoreText, ImageIO, KouenCopyMode, KouenTerminalEngine, KouenTerminalRenderer, KouenTheme (+20 more)

### Community 32 - ".addTab"
Cohesion: 0.08
Nodes (30): KeybindingsService, Bool, Command, String, KeySpec, .description, .init(from:), .init(key:modifiers:) (+22 more)

### Community 33 - "Equatable"
Cohesion: 0.06
Nodes (43): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, .init(from:), .init(id:name:baseURL:modelID:), ModelProvider (+35 more)

### Community 34 - "DaemonClient"
Cohesion: 0.09
Nodes (25): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+17 more)

### Community 35 - "MenuTarget"
Cohesion: 0.08
Nodes (33): Equatable, Bool, CAMetalDrawable, .currentSelectionRegion, ClosedRange, String, BlockSelection, CursorRender (+25 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.07
Nodes (16): DisplayWidth, String, Unicode, ReleaseNotes, Section, String, Run, String (+8 more)

### Community 37 - "String"
Cohesion: 0.09
Nodes (12): TerminalGridCell, HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor, Bool, ClosedRange (+4 more)

### Community 38 - "code:bash (swift build)"
Cohesion: 0.15
Nodes (7): AnyCodable, JSONRPCError, Bool, Int32, Pipe, String, ToolRegistry

### Community 39 - "TerminalColorGamut"
Cohesion: 0.06
Nodes (28): Notification.Name, KouenGit, os, Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached (+20 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.08
Nodes (12): SessionGroup, SessionID, String, KouenSidebarPanelViewController, NSMenuItem, SessionGroup, String, NSMenu (+4 more)

### Community 41 - "CodingKeys"
Cohesion: 0.08
Nodes (21): InputGate, .siblings, OutputCoalescer, ReconnectLatch, .isTripped, SurfaceIO, .currentSubscription, Bool (+13 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.08
Nodes (27): Array, GroupHeaderRow, .body, PickerItem, .groupLabel, historyBlock, .id, recipe (+19 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.09
Nodes (28): ColorKind, .base, bg, fg, underline, ComposedCell, .asGridCell, .cluster (+20 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.06
Nodes (34): .body, FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body (+26 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.09
Nodes (27): DaemonSubscription, .start(onData:onEnd:buffered:), .start(onResponse:onEnd:), Bool, String, UInt16, UInt64, Void (+19 more)

### Community 46 - ".buildCommand"
Cohesion: 0.10
Nodes (16): TerminalEmulator, .captureLines(joinWrapped:), .feed(_:), .promptRows, .readGrid(scrollbackOffset:), Case, ReflowCorpusTests, .corpus (+8 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.05
Nodes (31): DaemonClientActor, TimeInterval, DaemonSessionError, daemonError, .description, unexpectedResponse, DaemonSessionService, .endpoint (+23 more)

### Community 48 - "HookEvent"
Cohesion: 0.12
Nodes (43): Ame(), aQt(), CUe(), cXt(), een(), eVe(), eXt(), fUe() (+35 more)

### Community 49 - "DaemonServer"
Cohesion: 0.06
Nodes (38): .init(entry:), AgentChipView, .intrinsicContentSize, Colors, FontSize, IconSize, KouenMotion, NSColor (+30 more)

### Community 50 - "Added"
Cohesion: 0.06
Nodes (35): Executor, Hook, HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane (+27 more)

### Community 51 - ".keyEvent"
Cohesion: 0.05
Nodes (18): KouenDaemonCore, DaemonBrowserRoutingTests, IPCCodecInvariantTests, String, URL, ConcurrentIndexSet, .count, RawSocketError (+10 more)

### Community 52 - "Fixed"
Cohesion: 0.07
Nodes (11): NWEndpoint, Bool, NWListener, Sendable, String, UInt16, MobileBridgeServer, PipeBuffer (+3 more)

### Community 53 - "Added"
Cohesion: 0.04
Nodes (55): _2t(), a6e(), ake(), ate(), b6(), c8e(), Cf(), cxn() (+47 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.09
Nodes (11): SessionCoordinator, .selectWorkspace(_:), .selectWorkspace(byIndex:), Bool, Double, PaneID, String, SurfaceID (+3 more)

### Community 55 - "TabCell"
Cohesion: 0.08
Nodes (45): Codable, BrowserSnapshotAck, agentWaitChannel(), BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserRequestPayload (+37 more)

### Community 56 - "NSPanel"
Cohesion: 0.08
Nodes (28): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary, RowKind (+20 more)

### Community 57 - "BellScanState"
Cohesion: 0.07
Nodes (44): Encodable, ExpressibleByStringLiteral, AgyModelsPush, AISuggestionAck, AttachedAck, Body, BrowserFramePush, Cred (+36 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.05
Nodes (53): cYt(), dC(), dm(), ece(), eJ(), fme(), fwn(), FX() (+45 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.07
Nodes (21): SessionStore, DispatchWorkItem, TimeInterval, PendingVersionBanner, welcome, whatsNew, State, Bool (+13 more)

### Community 60 - "ViEngine"
Cohesion: 0.08
Nodes (11): Bool, Range, Set, String, URLDetection, CGFloat, CGRect, Range (+3 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.08
Nodes (14): DiffLineType, added, deleted, modified, Bool, DispatchWorkItem, NSEvent, NSPopover (+6 more)

### Community 62 - "ComposedCell"
Cohesion: 0.07
Nodes (21): GitAheadBehind, GitResult, .isSuccess, GitWorktreeInfo, Bool, Int32, String, GitParsers (+13 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.08
Nodes (30): .filteredJobs, MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith (+22 more)

### Community 64 - ".text"
Cohesion: 0.08
Nodes (31): TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid, .gridOriginPointsX (+23 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.07
Nodes (28): ScriptAPI, .windowSection, JSValue, KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:fileSearchRoots:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:), .scrollbackLines, LegacyKouenSettingsCodingKeys (+20 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.10
Nodes (16): AgentBrowserPaneTracker, SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, SessionID, Set (+8 more)

### Community 67 - "String"
Cohesion: 0.09
Nodes (16): Group, ParsedShortcut, .displayString, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, PrefixKeymap, Any (+8 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.15
Nodes (13): .exit, String, KouenCLI, SessionID, String, Never, SessionGroup, String (+5 more)

### Community 69 - ".compose"
Cohesion: 0.08
Nodes (22): OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, .event(_:), .interval(_:_:), Bool (+14 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.09
Nodes (15): ContextResolutionEngine, Bool, String, Bool, String, TokenGuard, EnvironmentStore, Persisted (+7 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 72 - "XCTestCase"
Cohesion: 0.09
Nodes (17): .requestDaemon(_:), .syncFromDaemon(metadataOnly:), ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy (+9 more)

### Community 73 - "README.md"
Cohesion: 0.11
Nodes (14): MochaTheme, ANSIPalette, UInt8, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors, Bool (+6 more)

### Community 74 - "[2.6.0] - 2026-06-13"
Cohesion: 0.08
Nodes (16): .effectiveResumeCommand(claudeMode:), LiveClaudeAgentEntry, .placement, ClaudeSessionMode, TimeoutFlag, .didFire, ClaudeCloudSessionStore, Entry (+8 more)

### Community 75 - "OptionStore"
Cohesion: 0.08
Nodes (11): surfaceID, .surfaceID(forPaneID:), .surfaceID(forPaneID:in:), Command, Double, PaneID, Tab, SessionEditorPhase4Tests (+3 more)

### Community 76 - ".parse"
Cohesion: 0.10
Nodes (20): DisplayLinkTarget, MainSplitViewController, .setSidebarVisible(_:), SplitChromeDelegate, .sidebarMaxWidth, .sidebarMinWidth, .splitView(_:constrainMaxCoordinate:ofSubviewAt:), .splitView(_:constrainMinCoordinate:ofSubviewAt:) (+12 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.07
Nodes (27): .init(coder:), .init(frame:), .init(coder:), Kind, primary, secondary, .init(coder:), KouenPillButton (+19 more)

### Community 78 - "Added"
Cohesion: 0.09
Nodes (23): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, IssueInfo (+15 more)

### Community 79 - "HarnessDesign"
Cohesion: 0.07
Nodes (32): AgentMark, .body, AgentMarkShape, Scanner, .atEnd, SVGPath, Bool, CGFloat (+24 more)

### Community 80 - "Agent handbook — Harness (extended reference)"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.07
Nodes (17): EditorDividerView, HitTestPassthroughView, .init(coder:), PaneDragGripView, .init(coder:), .init(paneID:), PaneHoverButton, PaneSplitButtonsView (+9 more)

### Community 82 - ".firstMatch"
Cohesion: 0.07
Nodes (29): keys, CGImage, DecodedImage, .byteCount, ImageLimits, Bool, UInt8, ImageDecoder (+21 more)

### Community 83 - "LSPClient"
Cohesion: 0.10
Nodes (22): ArtifactKind, html, image, markdown, text, AutomationsFleetModel, .load(detectScheduledRuns:), AutomationSource (+14 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.08
Nodes (27): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+19 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.09
Nodes (16): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController, CheckpointInfo (+8 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.13
Nodes (20): ClientRecord, CountBox, DaemonServer, .guiBrowserFD, PendingBrowserRequest, PendingWrite, .remaining, Bool (+12 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.09
Nodes (12): CGFloat, NSEvent, NSEvent, UInt8, NSEvent, NSPoint, UInt16, Bool (+4 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.09
Nodes (18): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+10 more)

### Community 89 - ".cursorPos"
Cohesion: 0.10
Nodes (17): .body, .mcpButton, json, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter (+9 more)

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.07
Nodes (11): NSRangePointer, NSEvent, String, Any, NSAttributedString, NSRange, NSRect, .testingPendingResize (+3 more)

### Community 91 - "TerminalModes"
Cohesion: 0.16
Nodes (13): SwarmSpawnSpec, Bool, closeSurface, CallRecorder, .cancelCalls, .closeCalls, .harnessCalls, .surfaceCalls (+5 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.11
Nodes (7): Range, String, TerminalBufferMatch, TerminalBufferSearch, String, TerminalBufferSearchTests, ThaiCombiningMarkTests

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.06
Nodes (16): KouenTerminalKit, Selector, PasteController, Bool, NSPasteboard, String, TimeInterval, URL (+8 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.06
Nodes (29): JSONDecoder, JSONEncoder, CodingKeys, cols, createdAt, dataBase64, rows, timeMs (+21 more)

### Community 95 - "shim.c"
Cohesion: 0.05
Nodes (38): Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions, Logical Design, P41 — Automations, Strategic Design, Tactical Design (+30 more)

### Community 96 - "Harness Usage"
Cohesion: 0.08
Nodes (18): NSScrollView, NSWindow, Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent (+10 more)

### Community 97 - "PaneContainerView"
Cohesion: 0.08
Nodes (31): Configuration, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, ButtonStyle, CommandRow, .body, GlassCard, .body (+23 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.13
Nodes (14): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+6 more)

### Community 99 - ".dispatch"
Cohesion: 0.06
Nodes (37): al(), b1t(), bdn(), bIn(), c4n(), d7e(), dOt(), dZe() (+29 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.15
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.06
Nodes (17): NSResponder, NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent (+9 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.11
Nodes (15): FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect, String, URL (+7 more)

### Community 103 - "AnyCodable"
Cohesion: 0.15
Nodes (9): Process, SSHTunnelManager, .init(makeTunnelProcess:reachabilityProbe:), Bool, URL, Tunnel, SSHTunnelManagerTests, String (+1 more)

### Community 104 - "Recipe"
Cohesion: 0.12
Nodes (14): AsyncRunCoordinator, OutputBuffer, ProcessResult, .isSuccess, ProcessRunner, Bool, CheckedContinuation, DispatchWorkItem (+6 more)

### Community 105 - "Changelog"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 106 - "domain-design.md"
Cohesion: 0.08
Nodes (30): AnyTransition, AgentNotchPeekEvent, Reason, errored, finished, needsInput, RowState, Bool (+22 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.09
Nodes (12): Tab, BrowserIntegrationController, PaneID, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), SurfaceID, PaneLifecycleManager, Bool (+4 more)

### Community 108 - ".resolve"
Cohesion: 0.09
Nodes (21): .agentInfo(forWorktreePath:), MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem (+13 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.10
Nodes (18): NSView, OverlayBackground, Context, OverlayBackground, Context, ChromeBackdrop, .init(role:), ChromeRole (+10 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.12
Nodes (12): MarkdownPreviewView, .webView(_:decidePolicyFor:decisionHandler:), Bool, MainActor, Sendable, String, URL, WKNavigationAction (+4 more)

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.08
Nodes (23): AgentHistoryDateGroup, older, .sortOrder, thisWeek, today, yesterday, AgentSessionHistoryModel, .extraRecordsShown (+15 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.14
Nodes (18): CommandParseError, .description, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand (+10 more)

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.16
Nodes (8): StringKind, apc, dcs, UInt8, UnsafeBufferPointer, VTParser, .feed(_:), VTParserHandler

### Community 114 - ".firstWaitingTab"
Cohesion: 0.09
Nodes (22): CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16, UInt8, BoxDrawing (+14 more)

### Community 115 - ".encode"
Cohesion: 0.13
Nodes (10): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, PaneID (+2 more)

### Community 116 - "SessionGroup"
Cohesion: 0.13
Nodes (4): FilePreviewCoordinator, FileTabID, Set, String

### Community 117 - "PaneNode"
Cohesion: 0.08
Nodes (13): CustomStringConvertible, KouenPaths, KouenPathsError, .description, socketPathTooLong, Bool, String, T (+5 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.13
Nodes (19): AgentHistoryFTSIndex, .deleteSession(sessionID:), .needsReindex(sessionID:mtime:fileSize:), .pruneMissingSessions(validTranscriptPaths:), .saveRecord(_:mtime:fileSize:), .search(query:limit:), .searchRanked(query:limit:includeSnippet:requireAllTokens:includeMetadata:matchingIDs:), .searchSubstring(query:includeEvidence:matchingIDs:) (+11 more)

### Community 119 - "Harness command reference"
Cohesion: 0.16
Nodes (12): FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID, KouenFeature (+4 more)

### Community 120 - "Added"
Cohesion: 0.09
Nodes (30): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+22 more)

### Community 121 - "Changed"
Cohesion: 0.11
Nodes (6): GitPanelView, .isHidden, Any, DispatchWorkItem, NSMenuItem, UnsafeMutableRawPointer

### Community 122 - "ViEngine"
Cohesion: 0.05
Nodes (30): FilterStatus, active, all, completed, CaseIterable, LayoutTemplate, evenHorizontal, evenVertical (+22 more)

### Community 123 - "Pipe"
Cohesion: 0.07
Nodes (13): Bool, NSDraggingInfo, NSDragOperation, NSCursor, Bool, NSDraggingInfo, NSDragOperation, NSPasteboard (+5 more)

### Community 124 - "String"
Cohesion: 0.15
Nodes (6): InstallError, unsupported, hooks, AgentHookInstallerTests, String, URL

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.08
Nodes (28): AnyView, .rowList, Container, .init(coder:), .init(frame:), NotchOverviewRow, .approvalControls, .background (+20 more)

### Community 126 - ".path"
Cohesion: 0.11
Nodes (16): FileNode, GitStatusType, added, deleted, modified, renamed, unmodified, untracked (+8 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.11
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.14
Nodes (8): MutationResult, RemoteHost, RemoteHostStore, Bool, String, RemoteHostStoreTests, String, URL

### Community 129 - "SwiftUI"
Cohesion: 0.12
Nodes (19): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerFooter, .body, DirectoryPickerModel (+11 more)

### Community 130 - "Harness"
Cohesion: 0.17
Nodes (13): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), Bool, Date, Decoder, SessionID, URL (+5 more)

### Community 131 - ".install"
Cohesion: 0.14
Nodes (10): ScrollbackFile, .highWater, Bool, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.12
Nodes (20): SwarmDAGStore, String, UUID, SwarmFleetSnapshot, SwarmLane, pty, structured, SwarmTaskNode (+12 more)

### Community 133 - ".load"
Cohesion: 0.09
Nodes (35): a6(), aJ(), bXt(), cJ(), dXt(), Eme(), F0(), fXt() (+27 more)

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.14
Nodes (36): aQ(), bme(), bqt(), bYt(), cbe(), DD(), dqt(), Dr() (+28 more)

### Community 135 - "CommandTarget"
Cohesion: 0.12
Nodes (11): BrowserPaneView, DesignModeElementInfo, Any, DispatchWorkItem, NSPopover, ObjectIdentifier, Selector, String (+3 more)

### Community 136 - ".startWatching"
Cohesion: 0.10
Nodes (14): NotchMaskAnimator, Bool, CGFloat, CGRect, NotchPanel, .canBecomeKey, .canBecomeMain, Bool (+6 more)

### Community 137 - "ActivePaneService"
Cohesion: 0.21
Nodes (5): Bool, Character, NSRange, NSTextView, String

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.11
Nodes (17): Error, LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed, serverNotExecutable, AsyncStream (+9 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.08
Nodes (13): KouenCore, Phase67Tests, LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab (+5 more)

### Community 140 - "Added"
Cohesion: 0.09
Nodes (23): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+15 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.08
Nodes (25): CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display, found, .isReady (+17 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.07
Nodes (8): B0, BBe(), Fze, Gg(), gPt(), O7, RD, S9

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.08
Nodes (11): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, Task, UUID (+3 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.11
Nodes (15): .init(url:paneID:), .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), .init(frame:), NSRect, URL, WKNavigationAction, WeakScriptMessageHandler (+7 more)

### Community 145 - "AsciiFastPathTests"
Cohesion: 0.11
Nodes (13): FileFuzzyMatcher, FileSearchRootScanner, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool (+5 more)

### Community 146 - "DecodedImage"
Cohesion: 0.11
Nodes (9): .records, .searchQuery, .selectedAgents, .selectedScope, Set, UInt64, AgentSessionHistoryModelTests, Date (+1 more)

### Community 147 - "FileTreeWatcher"
Cohesion: 0.12
Nodes (16): AgentSessionHistoryView, .body, .footerView, HistoryMenuProxy, Any, Bool, CGFloat, Date (+8 more)

### Community 148 - "TriState"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, S (+2 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.15
Nodes (10): OptionStore, Scope, pane, session, tab, workspace, ScopedKey, URL (+2 more)

### Community 151 - ".evaluate"
Cohesion: 0.13
Nodes (10): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String (+2 more)

### Community 152 - "Added"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.09
Nodes (9): KouenCLITests, DetachKeys, absent, invalid, parsed, Int32, String, Bool (+1 more)

### Community 154 - "LiveResizeTests"
Cohesion: 0.14
Nodes (6): ScriptRuntime, Any, String, URL, JSContext, ScriptingTests

### Community 155 - "Int"
Cohesion: 0.10
Nodes (15): StatusLineView, .init(coder:), Bool, CGFloat, Never, NSAttributedString, NSCoder, NSColor (+7 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.15
Nodes (15): AgentIconRenderer, Scanner, .atEnd, SVGPathParser, Bool, CGFloat, CGPath, CGPoint (+7 more)

### Community 157 - "Added"
Cohesion: 0.14
Nodes (12): .webView(_:didCommit:), WKWebViewConfiguration, BrowserPaneViewTests, MockWebView, .isLoading, .title, .url, Bool (+4 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.12
Nodes (12): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+4 more)

### Community 159 - "MatchCategory"
Cohesion: 0.13
Nodes (16): TrackedIssue, IssueTrackerPanelView, .body, .filteredIssues, .statusBannerText, String, GitHubSearchResult, IssueFetchStatus (+8 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.14
Nodes (10): ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID, String, SurfaceID (+2 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.21
Nodes (7): BrowserOkAck, Sendable, T, ConnectionState, ErrorAck, NWConnection, UUID

### Community 162 - "TerminalFindBar"
Cohesion: 0.10
Nodes (5): Bool, String, UInt8, .onResponse, .onSetClipboard

### Community 163 - "Workspace"
Cohesion: 0.12
Nodes (15): SavedLayoutStore, Bool, String, URL, UUID, PaneLayoutShape, branch, leaf (+7 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.08
Nodes (19): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+11 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.12
Nodes (12): center, ComposerPanel, .canBecomeKey, .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange, NSTextView (+4 more)

### Community 166 - "LiveSession"
Cohesion: 0.17
Nodes (11): tool, KouenDaemonToolsTests, String, URL, Document, Bool, Set, String (+3 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.12
Nodes (8): String, LSPDefinitionPayload, LSPDiagnosticsPayload, LSPStatusPayload, String, UInt64, URL, Set

### Community 168 - "Added"
Cohesion: 0.09
Nodes (32): ch(), dV(), dw(), e0n(), Eb(), evn(), hle(), ik() (+24 more)

### Community 169 - "Fixed"
Cohesion: 0.18
Nodes (6): Divergence, Bool, String, TimeInterval, WorktreeInfo, WorktreeManager

### Community 170 - "URLDetection"
Cohesion: 0.12
Nodes (22): FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose, .onSelect (+14 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.16
Nodes (15): ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool, Command (+7 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.15
Nodes (12): Darwin, Foundation, Glibc, AgentRoutingResolver, FormatContextBuilder, daemonLog(), detectStaleInstance(), installSignalHandlers() (+4 more)

### Community 173 - "BoardCard"
Cohesion: 0.06
Nodes (23): Codex → Kouen, One-line install, What you'll see, Grok Build → Kouen, One-line install, What you'll see, Hermes → Kouen, One-line install (+15 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.14
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRectSolver, Bool, Double, .split(node:targetPaneID:direction:paneCount:before:) (+3 more)

### Community 175 - "RGBColorTests"
Cohesion: 0.16
Nodes (9): AgentDetection, AgentDetector, RawMatch, Date, Int32, String, TimeInterval, ProcessScan (+1 more)

### Community 176 - "Added"
Cohesion: 0.09
Nodes (24): QuietRow, .body, StatusPill, .body, .color, Tone, danger, neutral (+16 more)

### Community 177 - ".rects"
Cohesion: 0.13
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 178 - "InlineAICompletionView"
Cohesion: 0.07
Nodes (31): Ac(), aut(), bC(), cae(), cAn(), cFt(), cht(), clamp() (+23 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.09
Nodes (23): aie(), arc(), b2e(), bezierCurveTo(), closePath(), cRe(), cZ(), E7() (+15 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.11
Nodes (3): CSIParams, .count, UInt8

### Community 181 - "GridCompositorTests"
Cohesion: 0.12
Nodes (16): .pairedAlreadyBanner, .pairingQRPanel, AutomationsFleetView, .automationsList, .body, .emptyFleetView, .headerBar, .sidebarEmptyView (+8 more)

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.12
Nodes (10): .removeWorktreeAction(_:), NSButton, NSColor, NSRect, NSStackView, NSTextField, TimeInterval, NSClickGestureRecognizer (+2 more)

### Community 183 - "LSPServerRegistry"
Cohesion: 0.11
Nodes (21): Motion, .entrance, .spring, .standardEase, CAMediaTimingFunction, NSWindowController, NSWindowDelegate, KouenOnboarding (+13 more)

### Community 184 - "targets"
Cohesion: 0.14
Nodes (21): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), .stats (+13 more)

### Community 185 - "SessionSnapshot"
Cohesion: 0.16
Nodes (10): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab, UUID (+2 more)

### Community 186 - "Error"
Cohesion: 0.16
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 187 - "AppDelegate"
Cohesion: 0.15
Nodes (16): ClaudeCodeHarness, Profile, edit, readonly, Run, RunState, cancelled, failed (+8 more)

### Community 188 - "BrowserPaneView"
Cohesion: 0.13
Nodes (14): string, AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID, .snapshotPayload (+6 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.08
Nodes (22): CodingKeys, error, id, jsonrpc, method, params, result, LSPMessage (+14 more)

### Community 190 - "user-stories.md"
Cohesion: 0.09
Nodes (21): AYt(), Cme(), DYt(), e7e(), EUe(), eYt(), hxn(), IR() (+13 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.13
Nodes (9): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, Set, SurfaceID, Tab (+1 more)

### Community 192 - "GlyphRasterizer"
Cohesion: 0.08
Nodes (21): IssueKeychainStore, Bool, String, IssuePriority, .color, high, low, medium (+13 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.10
Nodes (17): .init(coder:), BrowserProgressLine, .init(coder:), BrowserTabButton, .init(coder:), .init(title:isActive:onSelect:onClose:), DesignModePopoverViewController, .init(coder:) (+9 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.11
Nodes (13): CornerInfo, KouenSplitView, .dividerColor, .dividerThickness, DispatchWorkItem, Double, NSColor, NSRect (+5 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.10
Nodes (13): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+5 more)

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.12
Nodes (10): MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, String, SurfaceID (+2 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.08
Nodes (15): Bool, NSEvent, Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint (+7 more)

### Community 198 - ".classify"
Cohesion: 0.13
Nodes (14): .lspPosition(characterOffset:), LSPDiagnostic, LSPDiagnosticSeverity, error, hint, information, warning, LSPHover (+6 more)

### Community 199 - "code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)"
Cohesion: 0.12
Nodes (24): .color, BoardCard, BoardColumn, .name, BoardColumnKind, .displayName, done, error (+16 more)

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.11
Nodes (17): SwarmFleetBody, .body, SwarmFleetView, .init(coder:), SwarmNodeRowView, .body, .statusColor, CGFloat (+9 more)

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.16
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 202 - "PaletteModel"
Cohesion: 0.21
Nodes (5): CopyModeReducerTests, FakeGrid, .totalLines, Set, String

### Community 203 - "Harness keybindings"
Cohesion: 0.12
Nodes (10): .readJSONLLines(from:), AntigravitySessionLocator, AntigravityTranscriptLine, Bool, Int32, NSRegularExpression, String, URL (+2 more)

### Community 204 - "From tmux"
Cohesion: 0.18
Nodes (3): KouenSettingsTests, URL, Void

### Community 205 - "CopyModeState"
Cohesion: 0.09
Nodes (15): ImagePlacementSnapshot, SemanticMark, Bool, TerminalColorRole, background, cursor, foreground, palette (+7 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.09
Nodes (8): HookState, failed, idle, installed, installing, KouenSettings, ExperienceModeTests, UserNotifications

### Community 207 - "scheduleRender"
Cohesion: 0.19
Nodes (11): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, .selectedHost (+3 more)

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.11
Nodes (13): CryptoKit, Network, DecodedWSFrame, Bool, ConnectionState, NWConnection, String, UInt8 (+5 more)

### Community 209 - "SettingsRemoteView"
Cohesion: 0.07
Nodes (28): Additional `kouen-cli` subcommands, Agent safety CLI (`kouen-cli`), Agents, context and scratchpad, Attaching from a plain terminal, Bindings, Board and attention, Buffers (paste store), Composition (+20 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.21
Nodes (4): CommandTarget, String, UUID, TargetSpecTests

### Community 211 - "PaneTarget"
Cohesion: 0.15
Nodes (14): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+6 more)

### Community 212 - ".translate"
Cohesion: 0.22
Nodes (10): CopyModeGridSource, .promptRows, ClosedRange, CopyModeReducer, Bool, Character, NSRegularExpression, Range (+2 more)

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.11
Nodes (6): Bool, NSWindow, OcclusionTests, NSWindow, String, TimeInterval

### Community 215 - ".lines"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 216 - "CellColorResolverTests"
Cohesion: 0.13
Nodes (7): KeybindingsStore, .fileURL, URL, KeybindingsStoreTests, URL, Void, String

### Community 217 - "GridCompositor"
Cohesion: 0.13
Nodes (23): Colors, Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors (+15 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.11
Nodes (19): DataBox, .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:) (+11 more)

### Community 219 - "Prompt"
Cohesion: 0.17
Nodes (11): BranchSwitchHelper, FileTreeNode, FileTreeSwiftUIView, .body, .pastedImagesSection, Notification.Name, Bool, NSMenuItem (+3 more)

### Community 220 - "Section"
Cohesion: 0.13
Nodes (16): .textView(_:doCommandBy:), Selector, CompletionPopupView, .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:) (+8 more)

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.12
Nodes (11): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, osc (+3 more)

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.13
Nodes (12): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+4 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.12
Nodes (14): aXt(), Cqt(), EWt(), gXt(), H7(), hqt(), Lje(), LRt() (+6 more)

### Community 224 - "CellColorResolver"
Cohesion: 0.15
Nodes (5): SQLite3, AgentHistoryMultiAgentCoverageTests, Bool, String, URL

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.16
Nodes (11): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+3 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.15
Nodes (10): BrowserLeaf, PaneNode, PaneID, URL, Decoder, .init(from:), DaemonSyncServiceBrowserPaneMergeTests, PaneID (+2 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.10
Nodes (9): String, WorkspaceID, CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab, DaemonSyncServiceBranchNotifyTests (+1 more)

### Community 228 - "sessionRow"
Cohesion: 0.11
Nodes (10): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+2 more)

### Community 229 - ".decide"
Cohesion: 0.16
Nodes (8): .removeWorktreeAction(path:), GitResult, Bool, GitResult, String, ValidateOutcome, WorktreeEntry, GitPanelViewWorktreeParsingTests

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.18
Nodes (9): FileTreeContext, NSHostingView, SessionID, String, Void, WorkspaceFileTreeView, .init(rootPath:), MainActor (+1 more)

### Community 231 - "ExternalOpenKind"
Cohesion: 0.17
Nodes (11): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, PaletteFooter, .body (+3 more)

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.14
Nodes (15): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+7 more)

### Community 233 - "TextGrid"
Cohesion: 0.14
Nodes (12): .effectiveResumeCommand(mode:), AgentLaunchCommands, String, AgentSessionMode, cloud, .launchCommand, .launchFlags, local (+4 more)

### Community 234 - ".scan"
Cohesion: 0.14
Nodes (11): CKouenSys, pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal (+3 more)

### Community 235 - "WorkbenchCommand"
Cohesion: 0.09
Nodes (7): KouenCLI, BoardCommandTests, HistorySearchQueryTests, MemoCommandTests, URL, TaskCommandTests, String

### Community 236 - "Added"
Cohesion: 0.14
Nodes (5): Any, NSMenu, NSMenuItem, String, String

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.25
Nodes (5): .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:surfaceTag:topicSegments:), AgentHistorySearchTests, String, TimeInterval, URL

### Community 238 - ".make"
Cohesion: 0.24
Nodes (7): FormatContext, FormatString, FormatStyle, Bool, Character, Date, String

### Community 240 - "PaneBorderStatus"
Cohesion: 0.13
Nodes (16): CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, .init(from:), .init(id:surfaceID:daemonSurfaceID:surfaces:activeSurfaceID:) (+8 more)

### Community 241 - "Added"
Cohesion: 0.24
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 243 - ".make"
Cohesion: 0.12
Nodes (16): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+8 more)

### Community 244 - "FileNode"
Cohesion: 0.12
Nodes (15): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, .acceptsFirstResponder (+7 more)

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.11
Nodes (10): NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView, .cornerConfiguration (+2 more)

### Community 246 - "Experience modes"
Cohesion: 0.14
Nodes (12): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+4 more)

### Community 247 - ".renderFixture"
Cohesion: 0.11
Nodes (18): Coordinator, DiffAnalysis, DiffFileItem, DiffFileStatus, added, .color, deleted, modified (+10 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.21
Nodes (9): Bool, CGFloat, Character, NSEvent, NSRange, NSString, NSTextView, String (+1 more)

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.17
Nodes (11): NotchGeometry, .fallback, NSScreen, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics (+3 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.14
Nodes (22): FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView, .body (+14 more)

### Community 251 - "SessionCoordinator"
Cohesion: 0.20
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 252 - "NSViewRepresentable"
Cohesion: 0.13
Nodes (16): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, .bytesPerWakeup, .mbps (+8 more)

### Community 253 - "Split Right"
Cohesion: 0.11
Nodes (16): CodingKeys, error, id, jsonrpc, method, JSONRPCId, int, string (+8 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.16
Nodes (3): CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 256 - "GitMetadataProvider"
Cohesion: 0.24
Nodes (7): BinaryInstaller, .bundledMacOSDir, Bool, TimeInterval, BinaryInstallerVersionTests, String, URL

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.17
Nodes (4): l8e(), $Rt(), tJe(), YUt

### Community 258 - "WindowTitleStripView"
Cohesion: 0.16
Nodes (12): UInt16, TTYSize, RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal (+4 more)

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.17
Nodes (9): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ProcessInfo (+1 more)

### Community 260 - ".welcome"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.13
Nodes (15): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+7 more)

### Community 262 - ".install"
Cohesion: 0.11
Nodes (5): ContentAreaViewController, Bool, CGFloat, String, TabID

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.13
Nodes (20): .modifierFlags, NSEvent, CodingKey, BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts (+12 more)

### Community 264 - "code:bash (harness-cli install-hooks claude-code)"
Cohesion: 0.12
Nodes (8): OnboardingController, KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, BinaryInstallerDisplayTests, OnboardingEnvironmentTests

### Community 265 - "code:bash (harness-cli install-hooks cursor)"
Cohesion: 0.16
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 266 - ".path"
Cohesion: 0.17
Nodes (7): .lspPosition(for:), .onCurrentCWD, .onCurrentFile, Bool, NSString, NSTextView, String

### Community 267 - ".performInstall"
Cohesion: 0.08
Nodes (24): Font, .kouenBadge, .kouenBody, .kouenBodyStrong, .kouenCaption2, .kouenCaption, .kouenKbd, .kouenMono (+16 more)

### Community 268 - "code:bash (# Old (agent-specific):)"
Cohesion: 0.15
Nodes (8): BoardViewController, .isVisible, FlippedView, .isFlipped, Bool, Set, TabID, BoardViewControllerTests

### Community 269 - "DefaultTerminalManager"
Cohesion: 0.12
Nodes (7): TimeInterval, Logger, AgentHandoffBuilder, Bool, String, HandoffDirectoryTests, AgentHandoffBuilderTests

### Community 270 - "WindowSession"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 271 - "StatusLineView.swift"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 272 - "SGRMouseEvent"
Cohesion: 0.16
Nodes (10): String, AgentRoutingRule, Kind, path, stack, Bool, Date, UUID (+2 more)

### Community 273 - "KeySpec"
Cohesion: 0.22
Nodes (7): AgentRoutingRuleStore, Bool, String, URL, UUID, AgentRoutingRuleStoreTests, URL

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.11
Nodes (19): DiscoverStepView, .body, Point, String, OnboardingStep, complete, discover, .id (+11 more)

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 276 - "SyntaxTextView"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 277 - ".run"
Cohesion: 0.08
Nodes (6): CodepointRunFastPathTests, .assertAllPathsAgree(_:cols:rows:file:line:), StaticString, String, UInt, UInt8

### Community 278 - "BlockTintOverlay"
Cohesion: 0.12
Nodes (6): PromptQueue, String, SurfaceID, Void, PromptQueueBar, NSWindow

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.27
Nodes (6): Bool, NSRange, NSString, NSTextView, String, unichar

### Community 280 - ".menu"
Cohesion: 0.23
Nodes (8): NaturalLanguage, AgentHistorySearch, Hit, IDFCache, Bool, Double, String, .tokenHits(_:inNormalized:)

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.17
Nodes (21): Decodable, Item, ItemCompletedLine, LegacyMsgLine, Msg, String, ThreadStartedLine, AgentCommandRequest (+13 more)

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.11
Nodes (10): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, String (+2 more)

### Community 283 - "FormatColor"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 284 - "click_ui_element"
Cohesion: 0.20
Nodes (14): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, SessionGroup, SessionID (+6 more)

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.26
Nodes (7): Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.19
Nodes (7): CGFloat, FluidityBenchmarks, NSWindow, String, UInt64, ScrollReuseTests, NSWindow

### Community 287 - ".apply"
Cohesion: 0.25
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 288 - "AgentHookStrategy"
Cohesion: 0.16
Nodes (13): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+5 more)

### Community 289 - "StatusLineWidthTests"
Cohesion: 0.12
Nodes (9): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, KouenApp, FileChangeWatcherTests (+1 more)

### Community 290 - "Process"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 291 - "JSONDecoder"
Cohesion: 0.18
Nodes (20): CoreImage, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription, .surfaceID, detectHost() (+12 more)

### Community 292 - "Release runbook"
Cohesion: 0.20
Nodes (10): .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didFinish:), .webView(_:didStartProvisionalNavigation:), LoadCompletionState, Bool, CheckedContinuation, Double (+2 more)

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.18
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 294 - "GitHubCLIClient"
Cohesion: 0.14
Nodes (11): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+3 more)

### Community 295 - "AgentApprovalBar"
Cohesion: 0.19
Nodes (13): ProjectGroupWatcher, StreamBox, Bool, DispatchQueue, escaping, FSEventStreamRef, MainActor, Never (+5 more)

### Community 296 - "NotificationBus"
Cohesion: 0.13
Nodes (18): statusColor(), Array, Bool, Date, PaneID, String, TabID, Tab (+10 more)

### Community 297 - "settings.json"
Cohesion: 0.13
Nodes (7): ControlKeyNormalizer, Bool, String, ShortcutRecorderSerializer, String, ControlKeyNormalizerTests, ShortcutRecorderSerializerTests

### Community 298 - "jobs"
Cohesion: 0.17
Nodes (8): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, String, PaneStyleTests

### Community 299 - "PaneNode"
Cohesion: 0.16
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.19
Nodes (6): AgentTableEntry, MatchSource, ownProcess, wrapperLaunch, Bool, Set

### Community 301 - ".parse"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.15
Nodes (16): DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:), .isWorktreeSession (+8 more)

### Community 303 - ".encodeMouse"
Cohesion: 0.14
Nodes (10): apn(), brn, grn, hrn(), JGe(), KGe(), prn(), qGe() (+2 more)

### Community 304 - "00-inception-plan.md"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Kouen, Sparkle (+13 more)

### Community 305 - ".script"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 307 - "ViPathTokenTests"
Cohesion: 0.10
Nodes (20): Agent Memory, AI-SDLC — Dev/QA Workflow Spine, AODD: the operating contract, AODD triage: every request passes this gate (silently, no announcement), Approval Gates (mandatory on the Requirement path), Audit and Done, Cheap-model delegation, Core facts (non-negotiable, not model-inferable — everything else is judgment) (+12 more)

### Community 308 - "Send Ex Command"
Cohesion: 0.17
Nodes (7): AIProviderAwakeService, .closedLidOptedIn, Bool, NSObjectProtocol, Set, String, AIProviderAwakeServiceTests

### Community 309 - "Browser DevTools API (P28)"
Cohesion: 0.18
Nodes (11): Never, NSRegularExpression, Set, String, Task, URL, Void, WorkspaceSymbolIndex (+3 more)

### Community 310 - "FrameSignposter"
Cohesion: 0.16
Nodes (8): CustomEndpointTester, Result, Bool, String, URL, CustomEndpointTesterTests, URLRequest, URLSession

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.11
Nodes (10): KouenSyntaxResources, ObjectiveC, CGFloat, NSControl, StaticString, String, UInt, TabNavigationButtonsTests (+2 more)

### Community 312 - "AgentSnapshot"
Cohesion: 0.24
Nodes (7): NodeRow, .isFocused, .parentDirectory, .resolvedGitStatus, Error, Never, String

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.20
Nodes (6): Keyboard Shortcuts, AI Browser Control (kouen-mcp), HTTP/SSE authentication, Install, Shell integration (OSC 133 semantic prompts), What gets emitted

### Community 314 - "code:bash (harness-cli install-hooks codex)"
Cohesion: 0.16
Nodes (9): AgentListFormatter, Date, String, dvn(), ht(), AgentListFormatterTests, Bool, Date (+1 more)

### Community 315 - "code:bash (harness-cli install-hooks grok)"
Cohesion: 0.17
Nodes (16): SessionRef, byID, byName, next, previous, String, UUID, TargetSpec (+8 more)

### Community 316 - "code:bash (harness-cli install-hooks opencode)"
Cohesion: 0.13
Nodes (9): AgyMobileCommands, String, ClaudeMobileCommands, Set, String, slashCommandChunks(), String, MobileBridgeAgentCommandTests (+1 more)

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.14
Nodes (3): AgentLaunchCommandsTests, URL, Void

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 319 - "FormatColor"
Cohesion: 0.18
Nodes (6): DefaultTerminalLaunchRequest, ShellQuoting, Bool, String, URL, DefaultTerminalLaunchRequestTests

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.16
Nodes (8): String, UInt64, .color(_:), .renderColor(_:), CellOverlayTests, IndexSet, String, UInt64

### Community 321 - "UInt64"
Cohesion: 0.11
Nodes (11): URL, String, String, KouenFilePreviewLoader, KouenViewError, binaryOrUnsupportedEncoding, missingPath, tooLarge (+3 more)

### Community 323 - "LayoutNode"
Cohesion: 0.28
Nodes (7): SSETransport, .isRunning, .listener, Bool, NWConnection, NWListener, String

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.10
Nodes (3): Bool, String, UUID

### Community 325 - "FloatingPaneController"
Cohesion: 0.21
Nodes (8): SettingsAdvancedView, .body, Bool, String, SettingsFileSearchSection, .body, String, SwiftUI

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.15
Nodes (13): PaneDropZoneOverlay, .init(coder:), .init(targetPaneID:), NSCoder, NSPoint, NSRect, PaneID, Zone (+5 more)

### Community 327 - ".theme"
Cohesion: 0.17
Nodes (13): Notification.Name, ObserverToken, NSCoder, NSObjectProtocol, NSRect, NSTextView, SyntaxLineNumberGutterView, .init(coder:) (+5 more)

### Community 328 - "README.md"
Cohesion: 0.17
Nodes (5): TabID, WorkspaceID, AgentCommandTests, String, Tab

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 330 - ".drawGlyph"
Cohesion: 0.14
Nodes (9): PaneRect, PaneID, SurfaceID, SGRMouse, UInt8, SGRMouseTests, String, UInt8 (+1 more)

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.11
Nodes (17): AgentUsage, .contextTokens, .init(from:), .init(inputTokens:outputTokens:cacheReadTokens:cacheWriteTokens:thinkingTokens:totalCostUSD:), .shortSummary, CodingKeys, cacheReadTokens, cacheWriteTokens (+9 more)

### Community 332 - "Added"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 333 - "RealPty"
Cohesion: 0.17
Nodes (3): ShellIntegrationTests, .repoRoot, URL

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.22
Nodes (4): String, URL, UUID, WorktreeIsolationDaemonTests

### Community 335 - ".makeModel"
Cohesion: 0.16
Nodes (9): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+1 more)

### Community 336 - "run.sh"
Cohesion: 0.16
Nodes (6): LSPTextLocation, .position, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 337 - "CommandExecutionError"
Cohesion: 0.15
Nodes (9): _7(), A7(), a8(), bGt(), c8(), ene(), Gnn, IC() (+1 more)

### Community 338 - "CSIParams"
Cohesion: 0.15
Nodes (7): UnsafeBufferPointer, TerminalCellWidth, normal, spacerTail, wide, UnsafeBufferPointer, .cursorVisible

### Community 339 - "Foundation"
Cohesion: 0.17
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.13
Nodes (12): DetachedPaneOverlay, .init(coder:), .init(frame:style:), Style, detached, reconnectingChip, NSCoder, NSEvent (+4 more)

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.23
Nodes (7): StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength, newline, StdioTransport, AsyncStream

### Community 342 - "Added"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.20
Nodes (8): PaneID, SurfaceID, Tab, TabID, PaneLeaf, BrowserPaneReuseScopeTests, Tab, TabID

### Community 345 - "README.md"
Cohesion: 0.18
Nodes (4): Bool, String, SurfaceID, TimeInterval

### Community 346 - "Agent platform icons"
Cohesion: 0.20
Nodes (5): .snapshot, Bool, String, ThemeService, KouenOptions

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.16
Nodes (10): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+2 more)

### Community 348 - "DaemonLifecycleTests"
Cohesion: 0.12
Nodes (8): DispatchSource, DispatchQueue, DispatchSourceFileSystemObject, Int32, URL, Void, TranscriptFileWatcher, MobileBridgeTranscriptWatcherTests

### Community 349 - "Contents.json"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.11
Nodes (18): fix ที่ค้างอยู่ใน working tree (ยังไม่ commit), Terminal grid ไม่ใช่ก้อนใหญ่ที่ระบุชนิดได้, ก้อนหลักเกี่ยวข้องกับ RenderBox, การให้ DeepSeek ตรวจเพิ่ม, ผลตรวจ preview ที่แยกจากแอปหลัก, ผลตรวจแอปหลัก, ภาคผนวก 1 — fleet 9 ต.ค. (P54) กระทบ UI ไหม → กระทบ ตรงจุด, ภาคผนวก 2 — 18 ต.ค. `8c5e0c8d` P59 (agy session, **unreviewed**) (+10 more)

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.20
Nodes (9): KouenCommands, DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String (+1 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.20
Nodes (4): StyledSegment, StatusLineWidthTests, StatusLineWidth, String

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.15
Nodes (9): Bool, Int32, String, URL, SystemdUserInstaller, .backendName, .isInstalled, .unitURL (+1 more)

### Community 355 - ".deepMerge"
Cohesion: 0.14
Nodes (10): bUt(), FBe(), Gbe(), handler(), M9(), mUt(), _Q(), s0n() (+2 more)

### Community 357 - ".handleCat"
Cohesion: 0.16
Nodes (9): Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock, .block(id:) (+1 more)

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.16
Nodes (4): KouenThemeCatalog, .allThemes, String, KouenThemeCatalogTests

### Community 360 - "State"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.17
Nodes (11): Configuration, Int32, SessionID, Tab, TabID, WorkspaceID, TabSelector, active (+3 more)

### Community 362 - "RGBColor"
Cohesion: 0.22
Nodes (5): AgentNotchViewModel, Bool, CGFloat, Duration, String

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.15
Nodes (6): .agentInfo(forWorktreePath:tabs:), Tab, TabID, WorkspaceID, GitPanelViewWorktreeAgentTests, GitPanelViewWorktreeNavigationTests

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.20
Nodes (7): PaneDragController, .isDragging, Any, Bool, NSEvent, NSWindow, PaneID

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.18
Nodes (10): LSPFileSession, Never, String, Task, URL, Void, URL, SyntaxDefinitionTarget (+2 more)

### Community 366 - "Consumers"
Cohesion: 0.19
Nodes (9): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+1 more)

### Community 367 - "DaemonStats"
Cohesion: 0.21
Nodes (13): CellMetrics, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth, Bool (+5 more)

### Community 368 - "Tab"
Cohesion: 0.18
Nodes (13): FeaturePhase, architect, completed, dev, interview, qaDesign, qaVerify, .title (+5 more)

### Community 369 - "Git Panel"
Cohesion: 0.12
Nodes (17): CodingKeys, createdAt, cwd, done, id, sessionID, status, title (+9 more)

### Community 370 - ".encode"
Cohesion: 0.15
Nodes (11): Status, ciFailing, done, mergeReady, open, running, Bool, Date (+3 more)

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.16
Nodes (9): FileGraphInfo, GraphifyLSPBridge, Double, String, URL, GraphifyLSPBridgeTests, Any, String (+1 more)

### Community 373 - "Prompt"
Cohesion: 0.22
Nodes (6): ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 374 - ".run"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 375 - ".install"
Cohesion: 0.14
Nodes (5): HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 376 - "ScrollReuseTests"
Cohesion: 0.23
Nodes (7): PaneOutputWaiter, PaneOutputWaitResult, Bool, CheckedContinuation, Never, Tab, UInt64

### Community 377 - "Identifiable"
Cohesion: 0.17
Nodes (9): GitStatusProvider, OnceResume, Bool, Duration, String, TimeInterval, GitStatusProviderLargeOutputTests, URL (+1 more)

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.18
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 379 - "MCPServer"
Cohesion: 0.15
Nodes (14): SettingsTerminalView, .body, .experienceSection, .fontReadout, .fontSection, .shellSection, Bool, String (+6 more)

### Community 380 - "PromptQueue"
Cohesion: 0.12
Nodes (6): ScreenPos, bottom, middle, top, KouenLSP, QuickLookUI

### Community 381 - "smoke-dmg.sh"
Cohesion: 0.22
Nodes (7): HTTPURLResponse, SSETransportTests, Never, String, Task, UInt16, Void

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.12
Nodes (16): Command, .targetKind, PaneRef, bottom, byID, byIndex, last, left (+8 more)

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 385 - "INDEX.md"
Cohesion: 0.20
Nodes (4): CompletionGenerator, String, .fishCompletionSource, CompletionGeneratorTests

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.22
Nodes (9): SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, Int32, String (+1 more)

### Community 387 - "User Profile"
Cohesion: 0.18
Nodes (10): AssistantLine, ClaudeAdapter, Content, Message, ResultLine, Bool, Double, String (+2 more)

### Community 388 - "Darwin"
Cohesion: 0.18
Nodes (8): ClaudeRunSummary, Date, Double, Int32, String, UUID, String, UUID

### Community 389 - "HarnessCLITests"
Cohesion: 0.14
Nodes (17): dhn(), en(), fhn(), ghn(), gk(), GOt(), iXt(), jUe() (+9 more)

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.26
Nodes (3): String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 392 - "build-release.sh"
Cohesion: 0.27
Nodes (4): ArchitectureGuardTests, .repoRoot, String, URL

### Community 394 - "finalize-release.sh"
Cohesion: 0.17
Nodes (5): KouenMCPServer, String, MCPServer, String, UInt16

### Community 395 - "generate-app-icon.sh"
Cohesion: 0.18
Nodes (7): DragDiagnostics, DispatchSourceTimer, String, AgentRemoteControlDaemonService, Set, String, Void

### Community 396 - "generate-appcast.sh"
Cohesion: 0.17
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 397 - "measure-fluidity.sh"
Cohesion: 0.30
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 398 - "preview.sh"
Cohesion: 0.17
Nodes (8): Bool, CGFloat, NSCoder, Void, TabNavigation, TabNavigationButtons, .init(coder:), NSStackView

### Community 399 - "sign-and-notarize.sh"
Cohesion: 0.18
Nodes (9): Bool, NSCoder, NSEvent, NSTrackingArea, .init(coder:), WorkspaceSwitcherRow, .init(coder:), .init(title:count:isActive:symbol:canDelete:) (+1 more)

### Community 400 - "install-linux.sh"
Cohesion: 0.12
Nodes (15): agy, claude, codex, copilot, hermes, kouen, __kouen_agy_next, __kouen_claude_next (+7 more)

### Community 402 - "View"
Cohesion: 0.19
Nodes (10): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+2 more)

### Community 403 - "PresentAttempt"
Cohesion: 0.26
Nodes (8): InstallResult, Shell, bash, fish, zsh, ShellIntegration, Bool, URL

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.21
Nodes (3): .hasAdapter(for:), Bool, ClaudeCodeHarnessTests

### Community 405 - "AgentIconRenderer"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 406 - "main.swift"
Cohesion: 0.31
Nodes (4): .block(atPromptLine:), .captureLines(fromLine:toLine:), String, TerminalBlockStoreTests

### Community 407 - "Fixed"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 408 - "IPC Architecture"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.18
Nodes (8): BrowserFileReloadTests, CountingWebView, Nav, NSEvent, String, Void, WKNavigation, WKNavigationDelegate

### Community 410 - ".applyTerminalIdentity"
Cohesion: 0.22
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.17
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

### Community 412 - "go.json"
Cohesion: 0.27
Nodes (7): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection, agents

### Community 413 - "javascript.json"
Cohesion: 0.23
Nodes (8): LayoutFileStore, LayoutNode, branch, leaf, LayoutTemplate, Date, Double, String

### Community 414 - "json.json"
Cohesion: 0.20
Nodes (8): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController

### Community 415 - "markdown.json"
Cohesion: 0.17
Nodes (10): Color, .hexString, PickerItemRow, .badgeText, .body, .iconName, .subtitle, .titleText (+2 more)

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.19
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.19
Nodes (8): .init(coder:), NotificationRowView, .init(coder:), .isHighlighted, .isHovered, NSCoder, NSEvent, NSTrackingArea

### Community 419 - "typescript.json"
Cohesion: 0.24
Nodes (11): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Duration, String (+3 more)

### Community 420 - "yaml.json"
Cohesion: 0.23
Nodes (13): kouen.bash script, agy(), claude(), codex(), copilot(), hermes(), kouen(), __kouen_agy_next() (+5 more)

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.17
Nodes (9): Array, FormatColor, none, palette, rgb, Bool, Element, String (+1 more)

### Community 422 - "HintModeOverlay"
Cohesion: 0.22
Nodes (6): ListeningPortScanner, Int32, Set, String, result, ListeningPortScannerTests

### Community 423 - "SixelDecoder"
Cohesion: 0.15
Nodes (12): OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Bool, Value, bool (+4 more)

### Community 424 - ".parseDiffHunks"
Cohesion: 0.13
Nodes (11): Am(), bze(), Cm(), EQ(), Hm(), Im(), lte(), MBe() (+3 more)

### Community 425 - "AgentVectorIcon"
Cohesion: 0.20
Nodes (13): ern(), G4(), G7(), Jnn(), nrn(), Qnn(), sHe(), trn() (+5 more)

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.15
Nodes (12): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+4 more)

### Community 427 - ".delay"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 428 - "TaskDashboardView"
Cohesion: 0.24
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.25
Nodes (4): PortableRelativeDateFormatter, Date, String, UUID

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.19
Nodes (9): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 431 - "BoardCardView"
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 432 - "PathToken"
Cohesion: 0.33
Nodes (6): SurfaceProgressTracker, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.31
Nodes (6): Bool, Counter, Scheduled, SurfaceProgressTrackerTests, DispatchWorkItem, TimeInterval

### Community 434 - "Project History"
Cohesion: 0.21
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 435 - ".init"
Cohesion: 0.19
Nodes (5): FlippedView, .isFlipped, NSScrollView, NSTextView, GitPanelViewDiffPopoverTests

### Community 436 - "WaitForRegistry"
Cohesion: 0.22
Nodes (8): DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSViewCornerConfiguration, SurfaceID, Void

### Community 437 - "PickerItemRow"
Cohesion: 0.21
Nodes (9): CGFloat, NSCoder, SessionID, Void, TaskDashboardView, .init(coder:), .init(onJumpToSession:), TaskRowView (+1 more)

### Community 438 - "SessionEditor"
Cohesion: 0.24
Nodes (8): ProjectDropTarget, .init(coder:), .init(frame:), NSCoder, NSDraggingInfo, NSDragOperation, NSRect, URL

### Community 439 - "SetupStepView"
Cohesion: 0.14
Nodes (14): Agent handbook — Kouen (extended reference), Agent integration, Build and test, IPC, Keyboard shortcuts, kouen-cli, Native terminal renderer, Repository map (+6 more)

### Community 440 - "LegacySnapshot"
Cohesion: 0.41
Nodes (7): FeatureSummary, FeatureTaskSummary, GateSummary, Bool, Date, String, UUID

### Community 441 - "RemoteHostStore"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.23
Nodes (6): ProjectGroupResolver, String, String, .trimmed, AgentTitleInference, Bool

### Community 445 - "Section"
Cohesion: 0.19
Nodes (4): URL, MobileBridgeAttachFileTests, String, URL

### Community 446 - "Modifiers"
Cohesion: 0.23
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 447 - "PaletteMode"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 449 - "PresentAttempt"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 451 - ".run"
Cohesion: 0.18
Nodes (9): BrowserTabRepaintTests, RepaintCountingWebView, Any, Error, MainActor, Sendable, String, TimeInterval (+1 more)

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.30
Nodes (5): SearchBenchmarks, String, UInt64, URL, Void

### Community 454 - ".recordReapedGenerationForTesting"
Cohesion: 0.18
Nodes (3): Bool, Int32, String

### Community 456 - "TerminalModes"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 457 - ".normalizedKey"
Cohesion: 0.15
Nodes (3): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess

### Community 458 - "PaneOutputWaiter"
Cohesion: 0.33
Nodes (4): .setSidebarVisible(_:animated:), SidebarPlacementSyncTests, CGFloat, Void

### Community 459 - ".encode"
Cohesion: 0.22
Nodes (11): MarkdownImageSchemeHandler, .webView(_:start:), .webView(_:stop:), Never, ObjectIdentifier, Task, URL, Void (+3 more)

### Community 460 - "RunState"
Cohesion: 0.21
Nodes (8): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, NSEvent, Observation

### Community 461 - ".worktreeList"
Cohesion: 0.23
Nodes (9): AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor (+1 more)

### Community 462 - "AGENTS.md"
Cohesion: 0.19
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 463 - ".deinit"
Cohesion: 0.24
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 464 - "MouseButton"
Cohesion: 0.21
Nodes (5): FDWatchdog, DispatchSourceTimer, String, TimeInterval, FDWatchdogTests

### Community 465 - "DirectionalAxis"
Cohesion: 0.18
Nodes (5): FormatContextDaemonTests, PaneID, String, SurfaceID, URL

### Community 466 - "PlatformSys.swift"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 467 - ".moveSelection"
Cohesion: 0.24
Nodes (7): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor, .panelBackground

### Community 468 - "Never"
Cohesion: 0.18
Nodes (6): eKe(), irn(), mrn, _rn(), rrn(), srn()

### Community 469 - "PresentAttempt"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 470 - "DispatchTime"
Cohesion: 0.23
Nodes (5): String, TextGrid, .totalLines, .viewportRows, WordColumnRangeTests

### Community 472 - "start.sh script"
Cohesion: 0.26
Nodes (4): PaneLabelDaemonTests, String, URL, UUID

### Community 474 - "String"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 475 - ".hitTest"
Cohesion: 0.19
Nodes (8): CLIInstallLocator, OptionalUUID, absent, dangling, invalid, valid, URL, UUID

### Community 476 - "StatusDotView"
Cohesion: 0.21
Nodes (7): PluginLoader, String, ScriptError, .errorDescription, evaluationError, unsupportedPlatform, JavaScriptCore

### Community 477 - "SavedLayoutIPCDaemonTests"
Cohesion: 0.29
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 478 - ".install"
Cohesion: 0.27
Nodes (4): HintModeOverlay, Any, NSEvent, String

### Community 479 - "ScrollbackTests"
Cohesion: 0.23
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 480 - ".isRisky"
Cohesion: 0.17
Nodes (11): LinePos, end, firstNonBlank, start, ViDiagnosticNavigator, ViMode, insert, normal (+3 more)

### Community 481 - "SecureInputMonitor"
Cohesion: 0.20
Nodes (9): BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool, CGFloat, NSCoder, NSPoint (+1 more)

### Community 482 - ".resolve"
Cohesion: 0.17
Nodes (12): Architecture Decisions (dated log), Commit preparation, Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Markdown preview trust boundary, Post-P50 changes (v4.20.2 → v4.20.11, 2026-10-01 → 2026-10-06) (+4 more)

### Community 483 - "Changed"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 484 - "CopilotAdapter"
Cohesion: 0.17
Nodes (11): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile, regionEdit (+3 more)

### Community 485 - ".testKouenRendererFixtureLigatureShapingPathReportsPlausibleGlyphs"
Cohesion: 0.24
Nodes (9): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+1 more)

### Community 486 - "TabPillView"
Cohesion: 0.41
Nodes (4): KouenFeatureMarkdownSync, Bool, String, URL

### Community 487 - "bC"
Cohesion: 0.41
Nodes (5): InstallResult, ShellCompletionInstaller, Bool, String, URL

### Community 489 - "SurfaceIO"
Cohesion: 0.26
Nodes (5): Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 490 - "ccRunGet"
Cohesion: 0.29
Nodes (4): RepoResolver, Bool, String, RepoResolverTests

### Community 491 - ".update"
Cohesion: 0.39
Nodes (3): data, SixelDecoder, UInt8

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.32
Nodes (3): ReflowPreviewTests, .feeds, String

### Community 493 - "ccRunStart"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 494 - "ccRunInfo"
Cohesion: 0.17
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 495 - ".open"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 497 - ".bind"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 498 - ".runGitDiff"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 499 - "GlassEffectView"
Cohesion: 0.20
Nodes (9): AnyObject, CommandExecutionError, daemonError, .description, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor (+1 more)

### Community 500 - "zO"
Cohesion: 0.33
Nodes (5): AgentBridge, AgentTarget, Bool, String, SurfaceID

### Community 501 - "Fixed"
Cohesion: 0.24
Nodes (5): RiskyCommandClassifier, Bool, NSRegularExpression, String, RiskyCommandClassifierTests

### Community 502 - "Kouen Terminal — System Architecture"
Cohesion: 0.29
Nodes (6): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Carbon

### Community 503 - "Kouen Features"
Cohesion: 0.31
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 504 - "String"
Cohesion: 0.25
Nodes (6): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow

### Community 505 - ".tickFeatureWorktreeSweepLocked"
Cohesion: 0.20
Nodes (7): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, NSCoder, Void

### Community 506 - ".parseGitDiffOutput"
Cohesion: 0.18
Nodes (11): Typography, .badge, .kbd, .paletteHeader, .paletteTitle, .rowMeta, .rowTitle, .sectionLabel (+3 more)

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.29
Nodes (3): KouenCompositor, GridCompositorCopyModeTests, String

### Community 508 - "qLt"
Cohesion: 0.27
Nodes (7): AgyModelCatalog, Catalog, Date, String, TimeInterval, ConnectionState, NWConnection

### Community 509 - "start.mjs"
Cohesion: 0.27
Nodes (7): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8

### Community 510 - "PromptQueue"
Cohesion: 0.24
Nodes (4): aD(), crn, ELt(), n2e()

### Community 511 - ".panePathLookup"
Cohesion: 0.22
Nodes (4): _Bt(), by(), fst(), sBt

### Community 512 - ".setAttribute"
Cohesion: 0.22
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

### Community 513 - "ThemeDocument"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 515 - "RD"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 516 - "terminal_stress_runner.py"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 517 - "KouenCLI+Workbench.swift"
Cohesion: 0.29
Nodes (7): AnimatablePair, NotchShape, .animatableData, CGFloat, CGPath, CGRect, Path

### Community 518 - "Bool"
Cohesion: 0.33
Nodes (6): Bool, NSPasteboard, NSString, String, URL, AutoreleasingUnsafeMutablePointer

### Community 521 - ".daemonIsStale"
Cohesion: 0.38
Nodes (4): .activeTab, BrowserTab, UUID, tabs

### Community 523 - "fFe"
Cohesion: 0.36
Nodes (6): HistorySearchEvidence, .body, .terms, Bool, String, Text

### Community 524 - "รายงานตรวจสอบการใช้หน่วยความจำสูงของ Kouen Terminal"
Cohesion: 0.40
Nodes (3): String, TaskDashboardBody, .body

### Community 525 - ".encodeAndWait"
Cohesion: 0.20
Nodes (10): Agent Safety Net (Checkpoints, Verification, Write Guards), Claude Code Harness, Editor & LSP, How It Feels, Kouen Features, Mobile, Remote And Headless, Stack (+2 more)

### Community 526 - "Kind"
Cohesion: 0.24
Nodes (3): KouenMCP, KouenBrowserToolsTests, URL

### Community 527 - ".show"
Cohesion: 0.31
Nodes (4): GraphifyIndexCache, S, Set, String

### Community 528 - "worktree_review_dashboard.robot"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 529 - "WorktreeAutoIsolateService"
Cohesion: 0.31
Nodes (5): AgyAdapter, Result, ResultLine, String, UUID

### Community 530 - "HarnessChrome"
Cohesion: 0.20
Nodes (7): HeadlessRunEvent, assistantText, result, sessionID, Bool, Double, String

### Community 531 - "BrowserProgressLine"
Cohesion: 0.29
Nodes (8): AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand, Bool, Set

### Community 532 - "OpenClaw → Kouen"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 533 - "Pi → Kouen"
Cohesion: 0.24
Nodes (10): eGt(), HUe(), Ije(), KD(), kXt(), UUe(), uX(), wXt() (+2 more)

### Community 534 - "p12_mcp.robot"
Cohesion: 0.27
Nodes (3): DaemonReconnectPolicy, TimeInterval, DaemonReconnectPolicyTests

### Community 535 - "AgentNotification"
Cohesion: 0.24
Nodes (3): ClaudeSessionModeTests, URL, Void

### Community 536 - ".readGrid(scrollbackOffset:)"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 537 - "NSObject"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.24
Nodes (4): GroupedSessionDaemonTests, SessionGroup, String, URL

### Community 539 - "SavedLayoutIPCDaemonTests"
Cohesion: 0.24
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 540 - ".delay"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 542 - ".init(from:)"
Cohesion: 0.39
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 543 - ".bufferLine"
Cohesion: 0.36
Nodes (4): Bool, String, UUID, TaskDaemonBridge

### Community 544 - "CodingKeys"
Cohesion: 0.36
Nodes (4): BrowserPaneRegistry, NSWindow, PaneID, WeakBrowserPaneView

### Community 545 - ".characterIndex"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 546 - "LegacySnapshot"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Key spec syntax, Kouen keybindings, Persistence (+1 more)

### Community 547 - "NSObject"
Cohesion: 0.42
Nodes (3): KeyTokenParser, Bool, String

### Community 548 - ".encode"
Cohesion: 0.25
Nodes (7): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, String

### Community 549 - ".init(from:)"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 550 - ".init(hex:)"
Cohesion: 0.33
Nodes (4): OutputTrigger, OutputTriggerStore, Bool, String

### Community 551 - ".init(red:green:blue:alpha:)"
Cohesion: 0.33
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

### Community 552 - "PaneLabelDaemonTests"
Cohesion: 0.22
Nodes (8): Build order (unchanged from interview decision), G1 — @ file-path picker, G2 — shell tab-completion suggestion strip (heuristic, explicitly best-effort), G3 — AI command suggestion (via `claude` CLI subprocess), Logical Design, P37 Phase G — Autocomplete (mobile bridge), Strategic Design, Tactical Design

### Community 553 - "harness.resource"
Cohesion: 0.22
Nodes (8): Artifacts, Client Application — Slice 1 (stacked panes, no persistence), Client Application — Slice 2 (per-workspace divider memory), Context, Dev Task Progress — Workspace Sidebar Panels (P42), Integration, Note on task re-sequencing (2026-07-17), Summary

### Community 554 - "eFe"
Cohesion: 0.22
Nodes (9): Contributors, Documentation, Install, Key features, Kouen, License, Requirements, Update (+1 more)

### Community 555 - "code:bash (harness view <file>                        # syntax-highligh)"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 557 - ".viewWillMove"
Cohesion: 0.22
Nodes (7): block, escFn, lineFilter, md, page, script, swift

### Community 558 - "FindWindowMatcherTests"
Cohesion: 0.39
Nodes (4): SessionGroup, Any, String, Tab

### Community 561 - "AppIdleThrottle"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 562 - "BrowserResponsePayload"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 563 - "AgentNotchViewModel.swift"
Cohesion: 0.25
Nodes (8): A `claude` typed by hand, Claude Code → Kouen, Customizing, One-line install, Session mode: Remote Control / cloud / local, The reverse direction: a session opened in Claude showing up in Kouen, Verifying, What gets written

### Community 565 - "WriteOrigin"
Cohesion: 0.32
Nodes (4): PaneID, SessionGroup, Tab, first

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.25
Nodes (4): _c(), Nn(), Pqe, qp()

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.25
Nodes (7): Claude Code hook push (in-process Task subagent detection), Client UI indicator, Detection core (AgentDetector, pure logic), IPC / Tab plumbing, P38 Phase B — Subagent Visibility — Dev Task Progress, Status: Rewritten 2026-07-14 after original implementation (tasks 1-5) was lost to a concurrent git operation before commit. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.25
Nodes (7): Original overlay build (built 2026-07-14, gated green, then deleted 2026-07-15 mid live-test), P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress, Pivot — merge into the Recipes picker (2026-07-15), Stage 1-2 — Engine/surface plumbing (built 2026-07-14, unchanged by the pivot, still in use), Status: Implementation pivoted mid-phase from a standalone overlay to a merge into the existing, Summary, Thread grouping — Zed framing folded into the same picker (2026-07-15)

### Community 571 - "ShellIntegrationTests"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 572 - "LayoutProbeView"
Cohesion: 0.25
Nodes (7): #kouen, #practice, #score, #shell, #total, #unix, #vim

### Community 573 - "tHe"
Cohesion: 0.29
Nodes (5): ThaiClusterCopyTests, ThaiGrid, .columns, .totalLines, .viewportRows

### Community 574 - "FileTreeKeyboardNavigator"
Cohesion: 0.36
Nodes (4): AgentRemoteControlDaemonServiceTests, LogBox, .count, String

### Community 575 - ".toastErrorSummary"
Cohesion: 0.25
Nodes (3): FlushSessionStateTests, String, URL

### Community 580 - "ViInputMode"
Cohesion: 0.38
Nodes (4): AnyObject, ObjectIdentifier, TimeInterval, ZombieHoldRegistry

### Community 581 - "jD"
Cohesion: 0.29
Nodes (5): AgentNotchPresentation, closed, open, peek, AgentNotchWindowActivator

### Community 582 - ".groupByRoot"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 583 - "WorkbenchMRU"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 584 - "GUt"
Cohesion: 0.29
Nodes (7): 1. Plain Terminal, 2. Persistent Terminal, 3. Full Terminal, 4. Agent Workspace, Experience modes, Opting into the prefix + status line without switching modes, Persistence (ephemeral vs. persistent)

### Community 585 - "P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Kouen-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 586 - "Product"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 587 - "sheet-cheat.html"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 588 - "jHt"
Cohesion: 0.29
Nodes (5): DirectionalAxis, down, left, right, up

### Community 589 - "Endpoint"
Cohesion: 0.57
Nodes (3): ProjectConfig, Bool, String

### Community 590 - "lrn"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 591 - "main.swift"
Cohesion: 0.29
Nodes (7): blockTokens(), inlineTokens(), lex(), lexer(), lexInline(), me(), reflink()

### Community 592 - "commit-push.sh"
Cohesion: 0.29
Nodes (7): GRt(), n4e(), p7e(), r2(), tl(), vrt(), xq()

### Community 593 - "dO"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

### Community 594 - "r2"
Cohesion: 0.29
Nodes (6): .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8

### Community 595 - "full-cycle.sh"
Cohesion: 0.29
Nodes (7): TerminalGridUnderline, curly, dashed, dotted, double, none, single

### Community 596 - ".feed(_:)"
Cohesion: 0.29
Nodes (6): Locked decisions (user-confirmed), Logical Design, P38 Phase A — Cross-Agent Worktree Diff/Review Dashboard — Design, Strategic Design, Tactical Design, Verification gate (this phase)

### Community 597 - "TerminalColorRole"
Cohesion: 0.29
Nodes (6): Logical Design, Next Step, P42 — Workspace Sidebar Panels, Parked (not in scope), Strategic Design, Tactical Design

### Community 598 - ".encode"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 599 - ".terminalHostIfExists"
Cohesion: 0.29
Nodes (6): Any, Error, MainActor, Sendable, String, Void

### Community 602 - "Build locally"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 604 - "k0t"
Cohesion: 0.47
Nodes (4): AgentBadgeView, .body, Bool, CGFloat

### Community 608 - "W2"
Cohesion: 0.33
Nodes (6): DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed

### Community 609 - "FormatContextDaemonTests"
Cohesion: 0.33
Nodes (6): DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed

### Community 610 - "TabStatus"
Cohesion: 0.40
Nodes (3): calculate(), constructor(), mBt

### Community 612 - ".init(coder:)"
Cohesion: 0.33
Nodes (6): h1t(), hae(), jgn(), pwn(), sfn(), _Ue()

### Community 614 - "MainSplitViewController"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 615 - "fences"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase D — Kitty Graphics Conformance Slice, Scope (locked), Tests

### Community 616 - "bump-version.sh"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua), Scope (locked), Tests

### Community 617 - "ScriptFileWatcher"
Cohesion: 0.33
Nodes (5): Logical Design, Next Step, P43 — Add Repo/Folder to Workspace, Strategic Design, Tactical Design

### Community 618 - "parse"
Cohesion: 0.33
Nodes (5): Build, Release & Git Workflow, Build / Test / Run, Graphify before every delivery commit, Release packaging order, Worktree constraint

### Community 619 - "_0n"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 620 - "mS"
Cohesion: 0.60
Nodes (5): main(), printHelp(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 622 - "sBt"
Cohesion: 0.40
Nodes (3): String, URL, WorktreeSignatureTests

### Community 625 - "brt"
Cohesion: 0.47
Nodes (3): URL, TimeoutError, WorktreeLargeOutputRegressionTests

### Community 626 - "cGt"
Cohesion: 0.67
Nodes (3): AsyncCLIResultBox, Error, Result

### Community 627 - "ActiveTabCloseDisposition"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 632 - "dne"
Cohesion: 0.40
Nodes (4): Cursor Agent → Kouen, Manual fallback, One-line install, What you'll see

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
Nodes (4): Answer, Outcome, Q: BrowserPaneView createTab openBrowserPane navigation WebKit, Source Nodes

### Community 637 - "TerminalScrollbarView"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: KouenPreviewHome environment key daemon launch at startup, Source Nodes

### Community 638 - "FormatStringExtendedVariableTests"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: session history search ranking branch best matches, Source Nodes

### Community 639 - "gpn"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Kouen terminal product features agent workspace browser daemon session persistence remote control, Source Nodes

### Community 640 - "zpt"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: session persistence focus routing browser disposal memory bounded checkpoint undo verify worktree, Source Nodes

### Community 641 - "[3.10.0] - 2026-06-27"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: How should CheckpointManager.restore preserve the user staged index?, Source Nodes

### Community 642 - "qut"
Cohesion: 0.50
Nodes (3): OptionSet, Modifiers, UInt8

### Community 643 - "h7n"
Cohesion: 0.40
Nodes (5): CodingKeys, bindings, disabledSpecs, id, tables

### Community 644 - "clean-state.sh"
Cohesion: 0.40
Nodes (5): WrapperOptionBehavior, keepScanning, matchValue, skipValue, stopScanning

### Community 646 - ".isRisky"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 647 - "graphify reference: query, path, explain"
Cohesion: 0.40
Nodes (5): ResizeDirection, down, left, right, up

### Community 650 - "hjt"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 651 - "u0n"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 652 - "TerminalHostView"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 653 - "iOn"
Cohesion: 0.70
Nodes (4): restart_daemon(), rollback_version_bump(), full-cycle.sh script, usage()

### Community 654 - "BlockContextMenuTests"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 655 - "nht"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 656 - "Jcn"
Cohesion: 0.40
Nodes (3): Bool, String, UInt16

### Community 659 - "LayoutTemplate"
Cohesion: 0.50
Nodes (3): .body, AttributedString, NSColor

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

### Community 667 - "[3.3.0] - 2026-06-18"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: What commands build and test Kouen and prepare Graphify before commit?

### Community 668 - "nje"
Cohesion: 0.50
Nodes (4): WriteOutcome, complete, failed, wouldBlock

### Community 670 - "pie"
Cohesion: 0.50
Nodes (4): dO(), m8(), rfn(), zfn()

### Community 671 - "AntigravityTranscriptTurnsTests"
Cohesion: 0.67
Nodes (4): FVe(), hJ(), qVe(), Zme()

### Community 672 - "ColorKind"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 673 - "qte"
Cohesion: 0.50
Nodes (4): MouseEventKind, drag, press, release

### Community 674 - "t2e"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 675 - ".detect"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 676 - "vne"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 677 - "New Tab"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 678 - "FormatColor"
Cohesion: 0.67
Nodes (3): commit_with_graph(), prepare_graph_for_commit(), graphify-commit.sh script

### Community 686 - "DECSpecialGraphics"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 687 - "AutomationsFleetModelTests"
Cohesion: 0.67
Nodes (3): cat(), Hwe(), kYe()

### Community 688 - "fut"
Cohesion: 0.67
Nodes (3): cfn(), fut(), qYe()

### Community 689 - ".availableAgentKinds"
Cohesion: 0.67
Nodes (3): dht(), k0t(), l1n()

### Community 692 - "smoke-dmg.sh"
Cohesion: 0.67
Nodes (3): iRe(), jNt(), zNt()

### Community 703 - "WorktreeInfoSummary"
Cohesion: 0.67
Nodes (3): TransportError, invalidUTF8Header, missingContentLength

## Knowledge Gaps
- **2380 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+2375 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1125 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Work-memory lessons

**Known dead ends** — questions that led nowhere; don't re-derive.
- "KouenPreviewHome environment key daemon launch at startup" -> `KouenPaths`

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `TerminalEmulator` to `.setAttribute`, `terminal_stress_runner.py`, `AgentNotchRootView`, `Command`, `LSPMessage`, `.daemonIsStale`, `PerformanceBenchmarks`, `fFe`, `GitPanelView.swift`, `KittyKeyboardTests`, `VTParser`, `.applyPreedit`, `worktree_review_dashboard.robot`, `HarnessUILibrary`, `SpecialKey`, `code:block1 (Agent shell process)`, `HarnessTerminalSurfaceView`, `CopyModeAction`, `SplitPaneCoordinator`, `.request`, `WorktreeManager`, `Harness tmux-style capabilities`, `RGBColor`, `.parse`, `Added`, `Notification`, `Sendable`, `.init`, `.delay`, `DaemonClient`, `NSObject`, `.encode`, `code:bash (harness chat "Use the project map first, then inspect this r)`, `code:bash (swift build)`, `.init(red:green:blue:alpha:)`, `HarnessSettings`, `String`, `HarnessSidebarPanelViewController.swift`, `RenderSchedulerTests`, `HarnessOverlayBackground`, `HarnessTerminalSurfaceView.swift`, `.buildCommand`, `.normalizedKey`, `CodingKeys`, `.keyEvent`, `Fixed`, `WriteOrigin`, `HarnessSplitView`, `TabCell`, `NSPanel`, `BellScanState`, `3.2 สิ่งที่ implement แล้ว`, `ViEngine`, `FrecencyDirectoryStore`, `ComposedCell`, `HarnessCLI+Server.swift`, `.text`, `PrefixKeymap`, `tHe`, `FileTreeKeyboardNavigator`, `.compose`, `worktree_isolation_cli.robot`, `XCTestCase`, `README.md`, `Product`, `OptionStore`, `.parse`, `NSTextField`, `.line`, `Added`, `DaemonSubscription`, `.firstMatch`, `LSPClient`, `LSPDiagnostic`, `TerminalGridCell`, `HarnessPaths`, `r2`, `SessionCoordinator`, `.encode`, `Zombie View Crashes on macOS 26.5 + Swift 6.3.2`, `.cursorPos`, `P2 — Async IPC Refactor: Design Document`, `AttachInputBatcher`, `Harness Usage`, `ScriptRuntime.swift`, `Session Grouping and Split Session Plan`, `DaemonLauncher`, `domain-design.md`, `.resolve`, `SoftIconButton`, `code:text (:workbench start swift)`, `.makeSnapshot`, `HarnessGridTerminal`, `.firstWaitingTab`, `.encode`, `SessionGroup`, `PaneNode`, `WorkspaceFileTreeView`, `Harness command reference`, `brt`, `Changed`, `cGt`, `Pipe`, `HistoryRingBuffer`, `.path`, `p12_mcp.robot`, `SwiftUI`, `.install`, `AgentHookInstaller`, `.isRisky`, `CommandTarget`, `ActivePaneService`, `User Story Mapping (MANDATORY)`, `u0n`, `Added`, `แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)`, `How to use Harness from the terminal only (no GUI)`, `AsciiFastPathTests`, `k0n`, `DecodedImage`, `FileTreeWatcher`, `EnvironmentStore`, `TriState`, `.didCompleteSend`, `Int`, `PaneLabelDaemonTests`, `Harness Terminal — IDE Sidebar Feature Branch`, `MatchCategory`, `What You Must Do When Invoked`, `TerminalFindBar`, `CommandPromptController`, `ActiveTabCloseDisposition`, `LiveSession`, `AgentTableEntry`, `AgentVectorIcon`, `.tabIDsToNotify`, `Fixed`, `.currentSize`, `BinaryRefresherTests`, `RGBColorTests`, `.rects`, `MenuTarget`, `VTConformanceCorpusTests`, `P25 — iOS/iPadOS Support`, `FormatContext`, `targets`, `SessionSnapshot`, `BrowserPaneView`, `P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client`, `ScriptRuntime`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `.classify`, `code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)`, `BinaryInstallerVersionTests`, `MCP Server (harness-mcp)`, `PaletteModel`, `Harness keybindings`, `From tmux`, `CopyModeState`, `.deleteSavedLayout`, `.testDataFrameEncodeVsJSONBase64Output`, `PaneDropZoneOverlay`, `.translate`, `GridCompositor`, `Section`, `HarnessPathDisplay`, `.decide`, `HarnessGridTerminalTests`, `ExternalOpenKind`, `Added`, `TerminalBlockStoreTests`, `.make`, `.init`, `AgentBridge`, `FileNode`, `Experience modes`, `.renderFixture`, `DaemonMetrics`, `.colorRendering`, `HarnessTerminalSurfaceWorkerTests`, `SessionCoordinator`, `.makeDiffScrollView`, `Split Right`, `DecoKind`, `NSViewRepresentable`, `GitMetadataProvider`, `WindowTitleStripView`, `ThemeFileServiceTests`, `Browser Pane (P14)`, `.install`, `.path`, `SGRMouseEvent`, `[2.5.0] - 2026-06-12`, `.run`, `BlockTintOverlay`, `DisplayPanesOverlay`, `.menu`, `TerminalScrollbarView`, `RemoteHostStoreTests`, `FormatColor`, `After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md.`, `code:bash (harness-cli install-hooks hermes)`, `NotificationBus`, `.bufferLine`, `HarnessPaths.swift`, `.parse`, `ThemeDiagnostics`, `.init`, `RegressionBugFixTests`, `.resize`, `Browser DevTools API (P28)`, `FrameSignposter`, `Bug: Tab-Switch Black Screen`, `code:bash (harness-cli install-hooks grok)`, `.bufferLine`, `code:bash (# In a Harness pane:)`, `Focus Persistence — Per-Session-Tab Pane Focus (RL-043)`, `UInt64`, `DesktopNotifier`, `LayoutNode`, `.forkTab`, `.theme`, `ImmersivePalette.swift`, `.drawGlyph`, `.recordReapedGenerationForTesting`, `Added`, `.makeModel`, `run.sh`, `CSIParams`, `Foundation`, `Added`, `README.md`, `Architecture Decisions — harness-terminal`, `Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)`, `.handleCat`, `OcclusionTests`, `State`, `RGBColor`, `.jumpToBlock`, `Fixes Applied (v3.9.1+)`, `Tab`, `P13 — Embedded Browser Pane (cmux parity)`, `DynamicInstanceBuffer`, `Prompt`, `.init`, `ScrollReuseTests`, `terminal_stress_runner.py`, `UI Automation — Robot Framework (P18)`, `AppKit + Metal Patterns`, `build-release.sh`, `create-dmg.sh`, `preview.sh`, `sign-and-notarize.sh`, `main.swift`, `Fixed`, `FilePreviewCoordinatorTabScopeTests`, `HintModeOverlay`, `SixelDecoder`, `TaskDashboardView`, `PathToken`, `LaunchdServiceInstaller`, `.init`, `WaitForRegistry`, `LegacySnapshot`, `main.swift`, `.deleteWorkspaceFromMenu`, `RunState`, `.deinit`, `MouseButton`, `PlatformSys.swift`, `DispatchTime`, `String`, `.install`, `SecureInputMonitor`, `TabPillView`, `SurfaceIO`, `.update`, `Service Decomposition — SessionCoordinator (P17)`, `memory_leak_guards.robot`?**
  _High betweenness centrality (0.248) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `NSPanel` to `MenuTarget`, `sessionRow`, `Browser Pane (P14)`, `R1`, `CFTimeInterval`, `RGBColor`, `TerminalEmulator`, `.resolve`, `TextGrid`, `HarnessTerminalSurfaceView.swift`, `HarnessSplitView`, `TabCell`, `code:bash (harness-cli install-hooks codex)`, `CodingKeyRepresentable`, `DispatchSourceMemoryPressure`, `Added`?**
  _High betweenness centrality (0.205) - this node is a cross-community bridge._
- **Why does `fbt()` connect `callingPaneTarget` to `CodingKey`, `.handleNormal`, `Changed`, `MetalRendererTests`, `code:bash (harness-cli install-hooks codex)`?**
  _High betweenness centrality (0.105) - this node is a cross-community bridge._
- **Are the 18 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `RenderScheduler`) actually correct?**
  _`KouenTerminalSurfaceView` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _2400 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.00658408480686328 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.014241246536399294 - nodes in this community are weakly interconnected._