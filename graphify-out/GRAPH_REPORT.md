# Graph Report - p52-session-history-search  (2026-10-08)

## Corpus Check
- 880 files · ~999,533 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 19295 nodes · 55658 edges · 2587 communities (1494 shown, 1093 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8291 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `97535819`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 342 edges
2. `i()` - 321 edges
3. `a()` - 284 edges
4. `t()` - 253 edges
5. `SessionCoordinator` - 236 edges
6. `TerminalEmulator` - 229 edges
7. `u()` - 219 edges
8. `KouenCLI` - 219 edges
9. `SurfaceRegistry` - 217 edges
10. `DaemonClient` - 212 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 186 areas (208 edges)
2. `Command` - bridges 101 areas (108 edges)
3. `t()` - bridges 84 areas (253 edges)
4. `AgentKind` - bridges 77 areas (167 edges)
5. `IPCResponse` - bridges 77 areas (103 edges)
6. `KouenTerminalSurfaceView` - bridges 76 areas (342 edges)
7. `SessionCoordinator` - bridges 70 areas (236 edges)
8. `KouenPaths` - bridges 69 areas (150 edges)
9. `KouenGridTerminal` - bridges 68 areas (117 edges)
10. `AnyCodable` - bridges 65 areas (190 edges)

## Surprising Connections (you probably didn't know these)
- `.selectedHost` --references--> `RemoteHost`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRemoteView.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/RemoteHostsService.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.selectWorkspace(byIndex:)` --references--> `SessionSnapshot`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/SessionCoordinator.swift → Packages/KouenIPC/Sources/KouenIPC/SessionSnapshot.swift
- `WorktreeAutoIsolateService` --calls--> `WorktreeManager`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/WorktreeAutoIsolateService.swift → Packages/KouenCore/Sources/KouenCore/Worktree/WorktreeManager.swift

## Import Cycles
- None detected.

## Communities (2587 total, 1093 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.01
Nodes (525): _1n(), _2t(), _3n(), _6e(), _6n(), _9e(), a2n(), a3n() (+517 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.02
Nodes (427): l, V, _4n(), _5e(), _7n(), aA(), act(), adn() (+419 more)

### Community 2 - ".handleNormal"
Cohesion: 0.03
Nodes (296): pe(), r, X(), A(), code(), R(), a(), aDt() (+288 more)

### Community 3 - "Changed"
Cohesion: 0.02
Nodes (223): a(), b(), c(), d(), e(), f(), g(), h() (+215 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.06
Nodes (36): IndexingIterator, LayoutTemplate, surfaceID, tab, SessionEditor, .addSurface(tabID:paneID:), .addSurface(to:paneID:surfaceID:cwd:), .split(node:targetPaneID:direction:paneCount:before:) (+28 more)

### Community 5 - "IPCRequest"
Cohesion: 0.04
Nodes (29): TerminalGridCell, NSEvent, Any, Bool, CGFloat, NSEvent, NSMenu, NSMenuItem (+21 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.07
Nodes (17): Int, SemanticMark, HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor, Bool (+9 more)

### Community 7 - "Command"
Cohesion: 0.06
Nodes (25): .tab(forSurfaceKey:), DaemonCommandExecutor, Command, BellScanState, esc, normal, string, stringEsc (+17 more)

### Community 8 - "LSPMessage"
Cohesion: 0.03
Nodes (96): _3e(), a1t(), b2t(), bC(), bln(), cDt(), cFt(), cg() (+88 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.03
Nodes (87): _5n(), a0(), a2t(), a8n(), ace(), aV(), b6n(), bb() (+79 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.11
Nodes (20): Bool, CGFloat, Character, NSEvent, NSRange, NSString, NSTextView, String (+12 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.03
Nodes (82): _4e(), _8n(), aae(), Ac(), ake(), ate(), b2(), b6() (+74 more)

### Community 12 - "Changed"
Cohesion: 0.05
Nodes (29): OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, .event(_:), .interval(_:_:), Bool (+21 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.05
Nodes (32): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection, agents, AgentLaunchCommands (+24 more)

### Community 14 - "VTParser"
Cohesion: 0.06
Nodes (46): Equatable, DecodedImage, .byteCount, UInt8, KouenGridTerminal, .currentSelectionRegion, ClosedRange, String (+38 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.09
Nodes (40): MTLClearColor, MTLCommandBuffer, MTLLibrary, MTLRenderCommandEncoder, MTLRenderPipelineState, TerminalFrame, BgInstance, CursorCacheKey (+32 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.05
Nodes (49): .init(entry:), AgentChipView, .init(frame:), .intrinsicContentSize, ChromeBackdrop, .init(coder:), .init(role:), ChromeRole (+41 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.09
Nodes (13): .receive(_:), DispatchSemaphore, LiveResizeGeometry, Result, Bool, FluidityBenchmarks, NSWindow, String (+5 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.04
Nodes (60): .notchSection, SettingsAppearanceView, .autoTheme, .body, .themeSection, Bool, Color, .hexString (+52 more)

### Community 19 - "SpecialKey"
Cohesion: 0.05
Nodes (36): Bool, NSEvent, MainActor, Void, SessionDividerRowView, .init(coder:), .init(frame:), SessionGroupHeaderRowView (+28 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.05
Nodes (30): CornerInfo, EditorDividerView, HitTestPassthroughView, KouenSplitView, .dividerColor, .dividerThickness, .init(coder:), PaneDragGripView (+22 more)

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.05
Nodes (33): ClientRecord, CountBox, DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed (+25 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.06
Nodes (40): CommandTarget, Command, .targetKind, PaneRef, bottom, byID, byIndex, last (+32 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.06
Nodes (23): OptionStore, OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Scope, pane (+15 more)

### Community 24 - ".request"
Cohesion: 0.14
Nodes (11): TerminalDamage, RenderColor, MetalRendererTests, RenderedFixture, Bool, MTLTexture, StaticString, String (+3 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.07
Nodes (25): String, UInt16, UUID, Data, DecodedReplyFrame, output, reply, DecodedRequestFrame (+17 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.06
Nodes (24): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+16 more)

### Community 27 - "RGBColor"
Cohesion: 0.08
Nodes (27): item, input, AgentHistoryScanner, .antigravitySubagentIDs(dbPath:), AgentHistoryTurn, AgentSessionPlacement, background, cloud (+19 more)

### Community 28 - ".parse"
Cohesion: 0.07
Nodes (29): DiffLineType, added, deleted, modified, Notification.Name, Bool, DispatchWorkItem, NSCoder (+21 more)

### Community 29 - "Added"
Cohesion: 0.08
Nodes (27): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+19 more)

### Community 30 - "Notification"
Cohesion: 0.08
Nodes (16): RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), ScrollbackEntry, ScrollbackReplaySegment, Bool, CChar, DaemonSurfaceID, Int32 (+8 more)

### Community 31 - "Sendable"
Cohesion: 0.06
Nodes (43): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, .init(from:), .init(id:name:baseURL:modelID:), ModelProvider (+35 more)

### Community 32 - ".addTab"
Cohesion: 0.05
Nodes (23): KouenCore, Mode, compatible, kouen, TerminalIdentity, Phase67Tests, TerminalIdentityTests, BellScanTests (+15 more)

### Community 33 - "Equatable"
Cohesion: 0.07
Nodes (16): DisplayWidth, String, Unicode, ReleaseNotes, Section, String, Run, String (+8 more)

### Community 34 - "DaemonClient"
Cohesion: 0.08
Nodes (35): .pairedAlreadyBanner, .pairingQRPanel, ArtifactKind, html, image, markdown, text, AutomationsFleetModel (+27 more)

### Community 35 - "MenuTarget"
Cohesion: 0.08
Nodes (22): DisplayLinkTarget, MainSplitViewController, .setSidebarVisible(_:), .setSidebarVisible(_:animated:), SplitChromeDelegate, .splitView(_:constrainMaxCoordinate:ofSubviewAt:), .splitView(_:constrainMinCoordinate:ofSubviewAt:), .splitView(_:effectiveRect:forDrawnRect:ofDividerAt:) (+14 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.06
Nodes (36): .agentInfo(forWorktreePath:), AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary (+28 more)

### Community 37 - "String"
Cohesion: 0.09
Nodes (18): DaemonClient, Int32, TimeInterval, ClaudeCodeHarnessIPCTests, String, URL, DaemonContentionTests, URL (+10 more)

### Community 38 - "code:bash (swift build)"
Cohesion: 0.08
Nodes (31): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, .body, PaletteMode (+23 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.11
Nodes (47): Ame(), aQt(), aXt(), Cqt(), CUe(), cXt(), DYt(), eXt() (+39 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.14
Nodes (7): AnyCodable, JSONRPCError, .init(client:subscriptionClient:controlEnabled:), Int32, Pipe, String, ToolRegistry

### Community 41 - "CodingKeys"
Cohesion: 0.10
Nodes (11): PaneBorderStatus, Bool, Command, DispatchWorkItem, PaneID, PaneLeaf, PaneNode, PaneRect (+3 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.06
Nodes (30): AgentHistoryDateGroup, older, .sortOrder, thisWeek, today, yesterday, AgentSessionHistoryModel, .groupedRecords (+22 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.12
Nodes (9): PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Double, String, UInt64, UInt8 (+1 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.06
Nodes (28): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+20 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.07
Nodes (37): IssueKeychainStore, Bool, String, IssuePriority, .color, high, low, medium (+29 more)

### Community 46 - ".buildCommand"
Cohesion: 0.11
Nodes (18): Process, SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, SSHTunnelManager (+10 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.12
Nodes (16): .exit, String, String, String, String, KouenCLI, SessionID, String (+8 more)

### Community 48 - "HookEvent"
Cohesion: 0.09
Nodes (37): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+29 more)

### Community 49 - "DaemonServer"
Cohesion: 0.08
Nodes (17): TerminalGridCell, .captureLines(joinWrapped:), .feed(_:), .promptRows, .readGrid(scrollbackOffset:), Case, ReflowCorpusTests, .corpus (+9 more)

### Community 50 - "Added"
Cohesion: 0.08
Nodes (47): Codable, BrowserSnapshotAck, agentWaitChannel(), BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserRequestPayload (+39 more)

### Community 51 - ".keyEvent"
Cohesion: 0.08
Nodes (21): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+13 more)

### Community 52 - "Fixed"
Cohesion: 0.05
Nodes (53): a0n(), al(), avt(), b1t(), bdn(), bIn(), Bm(), bX() (+45 more)

### Community 53 - "Added"
Cohesion: 0.04
Nodes (50): a6e(), ag(), aoe(), bR(), cCn(), Cf(), d8n(), dZe() (+42 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.06
Nodes (35): Executor, Hook, HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane (+27 more)

### Community 55 - "TabCell"
Cohesion: 0.11
Nodes (8): KouenDaemonTools, SpawnedAgentSurface, Bool, PaneLeaf, Result, String, Tab, UUID

### Community 56 - "NSPanel"
Cohesion: 0.08
Nodes (19): Tab, BrowserIntegrationController, PaneID, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), .init(paneID:), PaneID, PaneNode (+11 more)

### Community 57 - "BellScanState"
Cohesion: 0.04
Nodes (53): b3e(), bd(), bvt(), c6(), cc(), CWt(), d2(), d_n() (+45 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.10
Nodes (10): Bool, String, UInt8, UnsafeBufferPointer, TerminalEmulator, .block(atPromptLine:), .captureLines(fromLine:toLine:), .onSetClipboard (+2 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.11
Nodes (19): .requestDaemon(_:), .syncFromDaemon(metadataOnly:), AgentBrowserPaneTracker, SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID (+11 more)

### Community 60 - "ViEngine"
Cohesion: 0.08
Nodes (26): CoreGraphics, CoreText, KouenCopyMode, KouenTerminalEngine, KouenTerminalRenderer, KouenTheme, Metal, ImmersiveEffects (+18 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.10
Nodes (24): DaemonSubscription, .start(onData:onEnd:buffered:), .start(onResponse:onEnd:), Bool, UInt64, Void, sysClose(), .onResponse (+16 more)

### Community 62 - "ComposedCell"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.08
Nodes (46): aJ(), AYt(), bXt(), cJ(), Cme(), dXt(), Eme(), F0() (+38 more)

### Community 64 - ".text"
Cohesion: 0.09
Nodes (9): SessionCoordinator, .selectWorkspace(_:), Double, PaneID, PaneNode, String, SurfaceID, TabID (+1 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.09
Nodes (21): Error, LSPClient, LSPClientError, missingPipe, processNotRunning, serverNotExecutable, AsyncStream, CheckedContinuation (+13 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.06
Nodes (35): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+27 more)

### Community 67 - "String"
Cohesion: 0.06
Nodes (16): KouenCLITests, URL, DetachKeys, absent, invalid, parsed, Bool, UInt8 (+8 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.08
Nodes (23): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSEvent (+15 more)

### Community 69 - ".compose"
Cohesion: 0.10
Nodes (21): .filteredJobs, MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith (+13 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.08
Nodes (28): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+20 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.08
Nodes (32): CGFloat, FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView (+24 more)

### Community 72 - "XCTestCase"
Cohesion: 0.09
Nodes (23): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, IssueInfo (+15 more)

### Community 73 - "README.md"
Cohesion: 0.07
Nodes (45): br(), checkbox(), codespan(), constructor(), de(), del(), em(), html() (+37 more)

### Community 74 - "[2.6.0] - 2026-06-13"
Cohesion: 0.13
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 75 - "OptionStore"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 76 - ".parse"
Cohesion: 0.10
Nodes (12): MarkdownPreviewView, Any, Bool, Error, String, URL, Void, KouenSyntaxResources (+4 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.07
Nodes (35): ImagePlacementSnapshot, Bool, String, UInt8, TerminalCellWidth, normal, spacerTail, wide (+27 more)

### Community 78 - "Added"
Cohesion: 0.10
Nodes (17): .body, .mcpButton, json, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter (+9 more)

### Community 79 - "HarnessDesign"
Cohesion: 0.12
Nodes (7): ContentAreaViewController, Bool, FilePreviewCoordinator, FileTabID, Set, SplitDirection, String

### Community 80 - "Agent handbook — Harness (extended reference)"
Cohesion: 0.11
Nodes (17): GroupHeaderRow, .body, PickerItem, .groupLabel, historyBlock, .id, recipe, .searchableText (+9 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.13
Nodes (25): fetchGitStatus(), ProjectCategory, ProjectCategorySection, .body, .c, .entries, ProjectDirectoryTreeModel, .isExpanded (+17 more)

### Community 82 - ".firstMatch"
Cohesion: 0.06
Nodes (35): ButtonStyle, CommandRow, .body, GlassCard, .body, GlassPrimaryButtonStyle, GlassSecondaryButtonStyle, GlassSmallButtonStyle (+27 more)

### Community 83 - "LSPClient"
Cohesion: 0.07
Nodes (30): BinaryInstaller, .bundledMacOSDir, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display (+22 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.05
Nodes (44): agn(), agt(), _at(), bce(), c8n(), ctn(), d5e(), fdn() (+36 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.11
Nodes (17): InputGate, .siblings, ReconnectLatch, .isTripped, Bool, CGFloat, FormatColor, NSColor (+9 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.10
Nodes (18): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+10 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.06
Nodes (13): KouenDaemonCore, IPCCodecInvariantTests, ConcurrentIndexSet, .count, HookFiringTests, NSObjectProtocol, String, URL (+5 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.08
Nodes (14): NSRangePointer, Any, NSAttributedString, NSRange, NSRect, String, UInt64, .color(_:) (+6 more)

### Community 89 - ".cursorPos"
Cohesion: 0.05
Nodes (38): Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions, Logical Design, P41 — Automations, Strategic Design, Tactical Design (+30 more)

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.16
Nodes (12): Bool, closeSurface, CallRecorder, .cancelCalls, .closeCalls, .harnessCalls, .surfaceCalls, SwarmWorkerManagerTests (+4 more)

### Community 91 - "TerminalModes"
Cohesion: 0.08
Nodes (29): AgentArt, AgentMark, .body, AgentMarkShape, AgentVectorIcon, Scanner, .atEnd, SVGPath (+21 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.15
Nodes (9): StringKind, apc, dcs, UInt8, UnsafeBufferPointer, VTParser, .feed(_:), VTParserHandler (+1 more)

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.06
Nodes (21): DaemonClientActor, TimeInterval, DaemonSessionService, .endpoint, .request(_:timeout:), Bool, TimeInterval, Endpoint (+13 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.09
Nodes (16): .selectWorkspace(byIndex:), SessionID, ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy (+8 more)

### Community 95 - "shim.c"
Cohesion: 0.13
Nodes (5): .setupPrompt, hooks, AgentHookInstallerTests, String, URL

### Community 96 - "Harness Usage"
Cohesion: 0.10
Nodes (17): SessionStore, DispatchWorkItem, TimeInterval, PendingVersionBanner, welcome, whatsNew, State, Bool (+9 more)

### Community 97 - "PaneContainerView"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.08
Nodes (23): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, .acceptsFirstResponder (+15 more)

### Community 99 - ".dispatch"
Cohesion: 0.10
Nodes (15): String, WorkbenchMRU, FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect (+7 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.15
Nodes (13): Tab, FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID (+5 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.10
Nodes (16): FileTreeContext, Bool, NSCoder, NSDraggingInfo, NSDragOperation, NSHostingView, NSScrollView, NSWindow (+8 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.10
Nodes (24): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), .stats (+16 more)

### Community 103 - "AnyCodable"
Cohesion: 0.14
Nodes (18): CommandParseError, .description, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand (+10 more)

### Community 104 - "Recipe"
Cohesion: 0.11
Nodes (7): Bool, Range, Set, String, URLDetection, StringProtocol, EngineConformanceTests

### Community 105 - "Changelog"
Cohesion: 0.11
Nodes (26): ColorKind, .base, bg, fg, underline, CompositorPane, GridCompositor, .render(panes:status:statusSegments:) (+18 more)

### Community 106 - "domain-design.md"
Cohesion: 0.09
Nodes (31): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+23 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.13
Nodes (11): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, PaneID (+3 more)

### Community 108 - ".resolve"
Cohesion: 0.09
Nodes (19): SavedLayoutStore, Bool, String, URL, UUID, PaneLayoutShape, branch, leaf (+11 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.11
Nodes (15): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+7 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.14
Nodes (15): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+7 more)

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.10
Nodes (17): BoxDrawing, Kind, arms, dashH, dashV, halfDown, halfLeft, halfRight (+9 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.10
Nodes (8): .onCurrentCWD, .onCurrentFile, Bool, NSString, NSTextView, String, unichar, ViPathTokenTests

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.10
Nodes (15): AnyCancellable, NSScreen, NotchMaskAnimator, Bool, CGFloat, CGRect, NotchPanel, .canBecomeKey (+7 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.10
Nodes (13): OptionSet, KeySpec, .description, .init(from:), .init(key:modifiers:), Modifiers, Decoder, String (+5 more)

### Community 115 - ".encode"
Cohesion: 0.07
Nodes (18): NSResponder, NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent (+10 more)

### Community 116 - "SessionGroup"
Cohesion: 0.13
Nodes (12): NWEndpoint, DecodedWSFrame, MobileBridgeServer, Bool, NWListener, String, UInt16, UInt8 (+4 more)

### Community 117 - "PaneNode"
Cohesion: 0.12
Nodes (6): AgentTableEntry, Bool, Set, String, .effectiveAgentKind, AgentDetectorTests

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.11
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 119 - "Harness command reference"
Cohesion: 0.08
Nodes (22): .webView(_:createWebViewWith:for:windowFeatures:), .webView(_:didCommit:), WKNavigationAction, BrowserPaneViewTests, MockWebView, .isLoading, .url, Any (+14 more)

### Community 120 - "Added"
Cohesion: 0.10
Nodes (15): Kind, primary, secondary, KouenPillButton, .init(title:kind:), .isHovered, .isPressed, NSColor (+7 more)

### Community 121 - "Changed"
Cohesion: 0.08
Nodes (20): SGRMouse, SGRMouseEvent, Bool, PaneRect, UInt8, MouseButton, left, middle (+12 more)

### Community 122 - "ViEngine"
Cohesion: 0.17
Nodes (10): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, automations (+2 more)

### Community 123 - "Pipe"
Cohesion: 0.14
Nodes (10): ScrollbackFile, .highWater, Bool, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 124 - "String"
Cohesion: 0.07
Nodes (24): requestFailed, FileHandle, CodingKeys, error, id, jsonrpc, method, params (+16 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.14
Nodes (20): ComposedCell, .asGridCell, .init(_:), .init(codepoint:fg:bg:underlineColor:bold:dim:italic:underline:blink:inverse:invisible:strikethrough:overline:), .scalar, .sgr, CompositorPane, GridCompositor (+12 more)

### Community 126 - ".path"
Cohesion: 0.12
Nodes (12): ANSIPalette, RGBColor, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors, Bool, Double (+4 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.14
Nodes (8): MutationResult, RemoteHost, RemoteHostStore, Bool, String, RemoteHostStoreTests, String, URL

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.14
Nodes (5): String, KouenSidebarPanelViewController, NSMenuItem, String, String

### Community 129 - "SwiftUI"
Cohesion: 0.12
Nodes (18): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerFooter, .body, DirectoryPickerModel (+10 more)

### Community 130 - "Harness"
Cohesion: 0.11
Nodes (18): Darwin, Foundation, Glibc, MatchSource, ownProcess, wrapperLaunch, OSCTerminatorMatch, PtyError (+10 more)

### Community 131 - ".install"
Cohesion: 0.11
Nodes (23): Binding, .init(from:), .init(spec:command:note:repeatable:), CodingKeys, bindings, disabledSpecs, id, tables (+15 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.14
Nodes (9): AgentDetection, AgentDetector, RawMatch, Date, Int32, TimeInterval, ProcessScan, Int32 (+1 more)

### Community 133 - ".load"
Cohesion: 0.09
Nodes (21): FormatContextBuilder, DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:) (+13 more)

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.08
Nodes (35): aR(), cKt(), cYt(), DGt(), dm(), fGt(), FRt(), FX() (+27 more)

### Community 135 - "CommandTarget"
Cohesion: 0.14
Nodes (7): ScriptRuntime, Any, String, URL, JSContext, JSValue, ScriptingTests

### Community 136 - ".startWatching"
Cohesion: 0.12
Nodes (11): FlippedView, .isFlipped, .removeWorktreeAction(_:), NSButton, NSColor, NSRect, NSScrollView, NSStackView (+3 more)

### Community 137 - "ActivePaneService"
Cohesion: 0.14
Nodes (16): Any, ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool (+8 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.09
Nodes (20): Coordinator, DiffAnalysis, DiffFileItem, DiffFileStatus, added, .color, deleted, modified (+12 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.10
Nodes (11): NSAttributedString, String, SyntaxHighlighter, KouenApp, FileChangeWatcherTests, SyntaxHighlighterTests, NSAttributedString, NSColor (+3 more)

### Community 140 - "Added"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, S (+2 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.14
Nodes (10): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab, UUID (+2 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.09
Nodes (23): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+15 more)

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.13
Nodes (10): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String (+2 more)

### Community 145 - "AsciiFastPathTests"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 146 - "DecodedImage"
Cohesion: 0.12
Nodes (15): .windowSection, .renderingSection, KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:), ClaudeSessionMode, Decoder, Double (+7 more)

### Community 147 - "FileTreeWatcher"
Cohesion: 0.12
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 148 - "TriState"
Cohesion: 0.14
Nodes (11): String, ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID, String (+3 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.19
Nodes (12): BrowserOkAck, ConnectionState, .authorized, .browserPaneID, .deviceID, .snapshotSubscription, .subscription, .surfaceID (+4 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.13
Nodes (17): SwarmDAGStore, String, UUID, SwarmFleetSnapshot, SwarmTaskNode, SwarmTaskStatus, cancelled, failed (+9 more)

### Community 151 - ".evaluate"
Cohesion: 0.10
Nodes (26): CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf, .init(from:) (+18 more)

### Community 152 - "Added"
Cohesion: 0.07
Nodes (33): A1(), aat(), bkn(), bw(), d6(), dw(), Eb(), evn() (+25 more)

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.16
Nodes (33): aQ(), bqt(), cbe(), DD(), dqt(), Dr(), Eqt(), Fa() (+25 more)

### Community 154 - "LiveResizeTests"
Cohesion: 0.09
Nodes (22): FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body, .emptyState (+14 more)

### Community 155 - "Int"
Cohesion: 0.18
Nodes (6): CopyModeReducerTests, FakeGrid, .totalLines, Set, String, TerminalGridCell

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.11
Nodes (15): StatusLineView, .init(coder:), CGFloat, FormatColor, Never, NSAttributedString, NSCoder, NSColor (+7 more)

### Community 157 - "Added"
Cohesion: 0.13
Nodes (6): GitPanelView, .isHidden, Any, DispatchWorkItem, NSMenuItem, UnsafeMutableRawPointer

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.12
Nodes (19): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, PaletteFooter, .body (+11 more)

### Community 159 - "MatchCategory"
Cohesion: 0.13
Nodes (13): MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem, SessionGroup (+5 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.12
Nodes (22): FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose, .onSelect (+14 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.15
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 162 - "TerminalFindBar"
Cohesion: 0.16
Nodes (6): ClaudeCodeHarness, .hasAdapter(for:), Bool, UUID, HeadlessCLIAdapter, ClaudeCodeHarnessTests

### Community 163 - "Workspace"
Cohesion: 0.09
Nodes (23): aie(), arc(), b2e(), bezierCurveTo(), closePath(), cRe(), cZ(), E7() (+15 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.17
Nodes (10): SSETransportTests, UInt16, SSETransport, .isRunning, .listener, Bool, NWConnection, NWListener (+2 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.13
Nodes (9): ThemeImportController, ThemeDocument, FileManager, String, URL, ThemeFileService, String, URL (+1 more)

### Community 166 - "LiveSession"
Cohesion: 0.17
Nodes (14): AgentIconRenderer, Scanner, .atEnd, SVGPathParser, Bool, CGFloat, CGPath, CGPoint (+6 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.16
Nodes (11): FileTreeNode, NodeRow, .body, .isFocused, .parentDirectory, .resolvedGitStatus, Bool, Error (+3 more)

### Community 168 - "Added"
Cohesion: 0.16
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 169 - "Fixed"
Cohesion: 0.10
Nodes (25): Bool, UInt8, TerminalCellWidth, normal, spacerTail, wide, TerminalCursor, TerminalCursorShape (+17 more)

### Community 170 - "URLDetection"
Cohesion: 0.11
Nodes (15): Bool, CGFloat, DispatchWorkItem, NSCoder, NSEvent, NSPoint, NSRect, NSTrackingArea (+7 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.12
Nodes (10): WindowInputRouterTests, UInt8, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8 (+2 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.12
Nodes (21): AnyTransition, AgentNotchPeekEvent, AgentNotchRootView, .bottomRadius, .closedAccessibilityLabel, .closedTransition, .closedView, .currentHeight (+13 more)

### Community 173 - "BoardCard"
Cohesion: 0.11
Nodes (10): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+2 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.10
Nodes (13): DetachedPaneOverlay, .init(coder:), .init(frame:style:), Style, detached, reconnectingChip, NSCoder, NSEvent (+5 more)

### Community 175 - "RGBColorTests"
Cohesion: 0.09
Nodes (19): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+11 more)

### Community 176 - "Added"
Cohesion: 0.11
Nodes (22): keys, ITerm2InlineImage, .heightArg, .preserveAspectRatio, .widthArg, Bool, String, UInt8 (+14 more)

### Community 177 - ".rects"
Cohesion: 0.09
Nodes (20): .init(coder:), BrowserProgressLine, .init(coder:), .init(frame:), BrowserTabButton, .init(coder:), .init(title:isActive:onSelect:onClose:), DesignModePopoverViewController (+12 more)

### Community 178 - "InlineAICompletionView"
Cohesion: 0.12
Nodes (10): MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, String, SurfaceID (+2 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.14
Nodes (10): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+2 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.13
Nodes (14): .lspPosition(for:), LSPDiagnostic, LSPDiagnosticSeverity, error, hint, information, warning, LSPHover (+6 more)

### Community 181 - "GridCompositorTests"
Cohesion: 0.07
Nodes (20): Codex → Kouen, One-line install, What you'll see, Cursor Agent → Kouen, Manual fallback, One-line install, What you'll see, Grok Build → Kouen (+12 more)

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.10
Nodes (9): KouenTerminalKit, TerminalGridSnapshot, KouenTerminalSurfaceFocusTests, KouenTerminalSurfaceWorkerTests, Bool, OcclusionTests, NSWindow, String (+1 more)

### Community 183 - "LSPServerRegistry"
Cohesion: 0.15
Nodes (9): CheckpointInfo, CheckpointManager, Bool, Date, String, CheckpointManagerTests, String, String (+1 more)

### Community 184 - "targets"
Cohesion: 0.14
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 185 - "SessionSnapshot"
Cohesion: 0.14
Nodes (28): Cleanup Test Repo, Close Isolated Session Keeps Dirty Worktree, Close Isolated Session Removes Clean Worktree, Close One Isolated Does Not Affect Another, Close Session With Split Panes Removes Worktree, Create Isolated Session, Create Isolated Session Via CLI, Get Active Pane (+20 more)

### Community 186 - "Error"
Cohesion: 0.17
Nodes (3): TerminalGridCell, TerminalGridSnapshot, ThaiCombiningMarkTests

### Community 187 - "AppDelegate"
Cohesion: 0.16
Nodes (14): FileNode, GitStatusType, added, deleted, modified, renamed, unmodified, untracked (+6 more)

### Community 188 - "BrowserPaneView"
Cohesion: 0.15
Nodes (7): .removeWorktreeAction(path:), GitResult, Bool, String, ValidateOutcome, WorktreeEntry, GitPanelViewWorktreeParsingTests

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.19
Nodes (11): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, .selectedHost (+3 more)

### Community 190 - "user-stories.md"
Cohesion: 0.12
Nodes (12): .rowList, AgentNotchPresentation, closed, open, peek, AgentNotchViewModel, AgentNotchWindowActivator, Bool (+4 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.21
Nodes (6): Divergence, Bool, String, TimeInterval, WorktreeInfo, WorktreeManager

### Community 192 - "GlyphRasterizer"
Cohesion: 0.07
Nodes (22): FilterStatus, active, all, completed, CaseIterable, LayoutTemplate, evenHorizontal, evenVertical (+14 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.16
Nodes (6): BrowserPaneView, DesignModeElementInfo, Any, NSPopover, String, TimeInterval

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.10
Nodes (23): .color, Collection, .aggregateBoardStatus, .taskTooltipSummary, TaskSummary.Status, .columnKind, SessionGroup, BoardCard (+15 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.12
Nodes (20): Motion, .entrance, .spring, .standardEase, CAMediaTimingFunction, NSWindowController, KouenOnboarding, Bool (+12 more)

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.07
Nodes (28): Additional `kouen-cli` subcommands, Agent safety CLI (`kouen-cli`), Agents, context and scratchpad, Attaching from a plain terminal, Bindings, Board and attention, Buffers (paste store), Composition (+20 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.13
Nodes (9): ClaudeCloudSessionStore, Entry, Date, String, TimeInterval, URL, AgentHistoryScannerTests, String (+1 more)

### Community 198 - ".classify"
Cohesion: 0.14
Nodes (15): Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow, launchStart, StartupMetrics (+7 more)

### Community 199 - "code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)"
Cohesion: 0.15
Nodes (14): JSONRPCMessage, notification, request, response, StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength (+6 more)

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.16
Nodes (3): KouenSettingsTests, URL, Void

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.14
Nodes (13): AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID, .snapshotPayload, NotificationBus (+5 more)

### Community 202 - "PaletteModel"
Cohesion: 0.16
Nodes (16): TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid, .init(_:gamut:alpha:) (+8 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.16
Nodes (11): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+3 more)

### Community 204 - "From tmux"
Cohesion: 0.15
Nodes (10): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, Set, SurfaceID (+2 more)

### Community 205 - "CopyModeState"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.11
Nodes (19): DataBox, .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:) (+11 more)

### Community 207 - "scheduleRender"
Cohesion: 0.09
Nodes (8): NSCursor, NSPasteboard, URL, NSPasteboard, String, UInt8, URL, KouenTerminalSurfaceDragDropTests

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.12
Nodes (11): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, osc (+3 more)

### Community 209 - "SettingsRemoteView"
Cohesion: 0.13
Nodes (12): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+4 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.11
Nodes (14): a6(), h2(), H7(), Lje(), LRt(), N$e(), pR(), R0 (+6 more)

### Community 211 - "PaneTarget"
Cohesion: 0.15
Nodes (8): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ActivityAssertionManagerTests

### Community 212 - ".translate"
Cohesion: 0.14
Nodes (22): CoreImage, CryptoKit, Network, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription (+14 more)

### Community 213 - "String"
Cohesion: 0.14
Nodes (11): FileFuzzyMatcher, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool, Character (+3 more)

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.14
Nodes (15): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+7 more)

### Community 215 - ".lines"
Cohesion: 0.13
Nodes (22): CustomStringConvertible, DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed, atomicWrite() (+14 more)

### Community 216 - "CellColorResolverTests"
Cohesion: 0.24
Nodes (9): CopyModeGridSource, .promptRows, CopyModeReducer, Bool, Character, NSRegularExpression, Range, String (+1 more)

### Community 217 - "GridCompositor"
Cohesion: 0.14
Nodes (7): KeybindingsStore, .fileURL, URL, KeybindingsStoreTests, URL, Void, String

### Community 219 - "Prompt"
Cohesion: 0.12
Nodes (19): QuietRow, .body, StatusPill, .body, .color, BinaryInstaller.DetectionStatus, SetupStepView, .body (+11 more)

### Community 220 - "Section"
Cohesion: 0.12
Nodes (18): bme(), bYt(), cVe(), fqt(), hVe(), iVe(), n5(), oVe() (+10 more)

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.13
Nodes (3): KittyKeyboardTests, String, UInt8

### Community 223 - "ANSIPalette"
Cohesion: 0.12
Nodes (12): AppKit, NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void (+4 more)

### Community 224 - "CellColorResolver"
Cohesion: 0.11
Nodes (13): ExternalOpenKind, filePreview, terminal, theme, InstallChoice, cancel, install, installAndApply (+5 more)

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.14
Nodes (12): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+4 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.16
Nodes (11): AgentNotchPeekDecider, Reason, errored, finished, needsInput, RowState, Bool, String (+3 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.11
Nodes (10): KouenOnboarding, GridCompositorParityTests, LiveCompositorFixture, Bool, String, TerminalGridSnapshot, PortCompositorFixture, Bool (+2 more)

### Community 228 - "sessionRow"
Cohesion: 0.20
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 229 - ".decide"
Cohesion: 0.18
Nodes (5): CompositorPane, GridCompositorTests, Bool, String, TerminalGridSnapshot

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.13
Nodes (16): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, .bytesPerWakeup, .mbps (+8 more)

### Community 231 - "ExternalOpenKind"
Cohesion: 0.12
Nodes (14): GridCompositor, termios, Configuration, Int32, SessionGroup, SessionID, Tab, TabID (+6 more)

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.18
Nodes (16): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, PaneLeaf, PaneNode (+8 more)

### Community 233 - "TextGrid"
Cohesion: 0.16
Nodes (3): CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 234 - ".scan"
Cohesion: 0.09
Nodes (25): bNt(), bu(), cNt(), dNt(), eNt(), eRe(), fNt(), h0t() (+17 more)

### Community 235 - "WorkbenchCommand"
Cohesion: 0.20
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 236 - "Added"
Cohesion: 0.11
Nodes (9): String, WorkspaceID, CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab, DaemonSyncServiceBranchNotifyTests (+1 more)

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 238 - ".make"
Cohesion: 0.18
Nodes (5): PrefixKeymap, Any, Bool, NSEvent, TimeInterval

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.13
Nodes (15): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+7 more)

### Community 240 - "PaneBorderStatus"
Cohesion: 0.11
Nodes (17): KeyRecorderRepresentable, String, Void, OverlayBackground, Context, OverlayBackground, Context, .init(coder:) (+9 more)

### Community 241 - "Added"
Cohesion: 0.14
Nodes (13): BranchSwitchHelper, FileTreeSwiftUIView, .body, .filteredNodes, .rootPath, .scanOptions, .sessionID, .taskID (+5 more)

### Community 242 - "AgentBridge"
Cohesion: 0.14
Nodes (9): BoardViewController, FlippedView, .isFlipped, Bool, Set, TabID, BoardColumn, .name (+1 more)

### Community 243 - ".make"
Cohesion: 0.13
Nodes (7): TimeInterval, Logger, AgentHandoffBuilder, Bool, String, HandoffDirectoryTests, AgentHandoffBuilderTests

### Community 244 - "FileNode"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.11
Nodes (13): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, PaneLeaf (+5 more)

### Community 246 - "Experience modes"
Cohesion: 0.13
Nodes (19): EndpointConnector, Int32, String, decodeBoundedCString(), ignoreSIGPIPE(), makeUnixStreamSocket(), setNoSigPipe(), CChar (+11 more)

### Community 247 - ".renderFixture"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.14
Nodes (17): PaneBorderStatus, bottom, off, top, PaneLeaf, PaneNode, branch, leaf (+9 more)

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.13
Nodes (9): NSDraggingInfo, NSDragOperation, PasteController, Bool, NSPasteboard, String, TimeInterval, URL (+1 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 251 - "SessionCoordinator"
Cohesion: 0.08
Nodes (6): CodepointRunFastPathTests, .assertAllPathsAgree(_:cols:rows:file:line:), StaticString, String, UInt, UInt8

### Community 252 - "NSViewRepresentable"
Cohesion: 0.12
Nodes (11): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, Task, UUID (+3 more)

### Community 253 - "Split Right"
Cohesion: 0.12
Nodes (6): PromptQueue, String, SurfaceID, Void, PromptQueueBar, NSWindow

### Community 254 - "BoardViewController"
Cohesion: 0.11
Nodes (11): Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint, NSRect, WindowTitleStripView (+3 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.18
Nodes (10): NotchGeometry, .fallback, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics, Bool (+2 more)

### Community 256 - "GitMetadataProvider"
Cohesion: 0.17
Nodes (9): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, FormatColor, String (+1 more)

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.16
Nodes (11): pipe, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal, Int32, String (+3 more)

### Community 258 - "WindowTitleStripView"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.27
Nodes (7): Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 260 - ".welcome"
Cohesion: 0.09
Nodes (19): ExperienceMode, agent, .displayName, .foregroundsAgents, full, .notchEnabledByDefault, persistent, .persistsSessionsByDefault (+11 more)

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.11
Nodes (21): dhn(), en(), fhn(), ghn(), gk(), GOt(), IUe(), iXt() (+13 more)

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.18
Nodes (6): HappyAdoptTests, CopilotSessionInfo, HappyDaemonSession, Bool, Int32, String

### Community 264 - "code:bash (harness-cli install-hooks claude-code)"
Cohesion: 0.13
Nodes (3): KouenGridTerminalTests, String, TerminalGridSnapshot

### Community 265 - "code:bash (harness-cli install-hooks cursor)"
Cohesion: 0.19
Nodes (10): RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal, FileHandle, Int32 (+2 more)

### Community 266 - ".path"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 267 - ".performInstall"
Cohesion: 0.17
Nodes (11): SettingsAdvancedView, .body, Bool, String, SliderRow, .body, .displayValue, ClosedRange (+3 more)

### Community 268 - "code:bash (# Old (agent-specific):)"
Cohesion: 0.14
Nodes (14): .agentColorBinding, colors, ANSIPalette, CellColorResolver, MochaTheme, ResolvedCellColors, .init(hex:), .init(red:green:blue:alpha:) (+6 more)

### Community 269 - "DefaultTerminalManager"
Cohesion: 0.18
Nodes (10): .body, Group, ParsedShortcut, .displayString, PrefixCheatsheetWindow, PrefixIndicatorWindow, CGFloat, NSTextField (+2 more)

### Community 270 - "WindowSession"
Cohesion: 0.13
Nodes (7): ControlKeyNormalizer, Bool, String, ShortcutRecorderSerializer, String, ControlKeyNormalizerTests, ShortcutRecorderSerializerTests

### Community 271 - "StatusLineView.swift"
Cohesion: 0.16
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 272 - "SGRMouseEvent"
Cohesion: 0.11
Nodes (13): CodingKeys, error, id, jsonrpc, method, params, JSONRPCId, int (+5 more)

### Community 273 - "KeySpec"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.18
Nodes (9): String, AgentRoutingRule, Kind, path, stack, Bool, Date, UUID (+1 more)

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.25
Nodes (7): AgentRoutingRuleStore, Bool, String, URL, UUID, AgentRoutingRuleStoreTests, URL

### Community 276 - "SyntaxTextView"
Cohesion: 0.30
Nodes (4): TaskStore, tasks, URL, TaskStoreTests

### Community 277 - ".run"
Cohesion: 0.16
Nodes (9): AgentRemoteControlDaemonService, Bool, Set, String, Void, AgentRemoteControlDaemonServiceTests, LogBox, .count (+1 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.21
Nodes (8): DaemonMetrics, Snapshot, .meanLockWaitMicros, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.11
Nodes (22): aNt(), dwn(), eJ(), fme(), fwn(), gKt(), $He(), kGt() (+14 more)

### Community 280 - ".menu"
Cohesion: 0.14
Nodes (10): apn(), brn, grn, hrn(), JGe(), KGe(), prn(), qGe() (+2 more)

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.30
Nodes (9): .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release, `repeat`, KeyModifiers, Character, String (+1 more)

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.16
Nodes (9): CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16, UInt8, UInt32 (+1 more)

### Community 283 - "FormatColor"
Cohesion: 0.16
Nodes (20): Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors, ContrastGrade (+12 more)

### Community 284 - "click_ui_element"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Kouen, Sparkle (+13 more)

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.17
Nodes (12): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+4 more)

### Community 287 - ".apply"
Cohesion: 0.12
Nodes (10): NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView, .cornerConfiguration (+2 more)

### Community 288 - "AgentHookStrategy"
Cohesion: 0.16
Nodes (8): CustomEndpointTester, Result, Bool, String, URL, CustomEndpointTesterTests, URLRequest, URLSession

### Community 290 - "Process"
Cohesion: 0.16
Nodes (8): AgentListFormatter, Date, String, dvn(), AgentListFormatterTests, Bool, Date, String

### Community 291 - "JSONDecoder"
Cohesion: 0.18
Nodes (12): AgentHistoryFTSIndex, .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:), .needsReindex(sessionID:mtime:fileSize:), .search(query:limit:), AgentHistoryFTSMatch, ExtractedTranscriptContent, Bool, Date (+4 more)

### Community 292 - "Release runbook"
Cohesion: 0.20
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 294 - "GitHubCLIClient"
Cohesion: 0.18
Nodes (6): DefaultTerminalLaunchRequest, ShellQuoting, Bool, String, URL, DefaultTerminalLaunchRequestTests

### Community 295 - "AgentApprovalBar"
Cohesion: 0.27
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 296 - "NotificationBus"
Cohesion: 0.28
Nodes (3): KouenDaemonToolsTests, String, URL

### Community 298 - "jobs"
Cohesion: 0.10
Nodes (3): Bool, String, UUID

### Community 299 - "PaneNode"
Cohesion: 0.18
Nodes (5): .snapshot, Bool, String, ThemeService, KouenOptions

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.15
Nodes (6): Security, KouenMCPServer, Bool, String, MCPServer, String

### Community 301 - ".parse"
Cohesion: 0.15
Nodes (6): .init(url:paneID:webView:), NSStackView, Selector, URL, NSAppearance, WKUserScript

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.15
Nodes (11): PaletteWindowDelegate, Array, RecipePanel, .canBecomeKey, RecipePickerController, RecipePickerView, RecipeWindowDelegate, Bool (+3 more)

### Community 303 - ".encodeMouse"
Cohesion: 0.19
Nodes (12): CGFloat, NSCoder, SessionID, String, Void, TaskDashboardBody, .body, TaskDashboardView (+4 more)

### Community 304 - "00-inception-plan.md"
Cohesion: 0.14
Nodes (14): DotView, .init(coder:), .init(frame:), statusColor(), Bool, Configuration, Context, NSCoder (+6 more)

### Community 305 - ".script"
Cohesion: 0.18
Nodes (15): CellMetrics, ComposedFrame, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth (+7 more)

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.20
Nodes (18): Decodable, Item, ItemCompletedLine, LegacyMsgLine, Msg, String, ThreadStartedLine, AISuggestRequest (+10 more)

### Community 307 - "ViPathTokenTests"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 308 - "Send Ex Command"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 309 - "Browser DevTools API (P28)"
Cohesion: 0.16
Nodes (16): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+8 more)

### Community 310 - "FrameSignposter"
Cohesion: 0.22
Nodes (4): String, URL, UUID, WorktreeIsolationDaemonTests

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.16
Nodes (9): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+1 more)

### Community 312 - "AgentSnapshot"
Cohesion: 0.32
Nodes (3): BinaryInstallerVersionTests, String, URL

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.19
Nodes (11): DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String, StyledSegment (+3 more)

### Community 314 - "code:bash (harness-cli install-hooks codex)"
Cohesion: 0.15
Nodes (9): _7(), A7(), a8(), bGt(), c8(), ene(), Gnn, IC() (+1 more)

### Community 316 - "code:bash (harness-cli install-hooks opencode)"
Cohesion: 0.17
Nodes (4): InputEncoder, InputEncoderTests, String, UInt8

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.19
Nodes (8): Range, String, TerminalGridCell, TerminalBufferMatch, TerminalBufferSearch, String, TerminalGridCell, TerminalBufferSearchTests

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.15
Nodes (4): KouenThemeCatalog, .allThemes, String, KouenThemeCatalogTests

### Community 319 - "FormatColor"
Cohesion: 0.10
Nodes (20): Agent Safety Net (Checkpoints, Verification, Write Guards), AI Browser Control (kouen-mcp), Build From Source, Claude Code Harness, CLI, Development Builds, Documentation, Editor & LSP (+12 more)

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.18
Nodes (8): PaneID, SurfaceID, Tab, TabID, BrowserPaneReuseScopeTests, PaneNode, Tab, TabID

### Community 322 - "DesktopNotifier"
Cohesion: 0.17
Nodes (12): LayoutFileStore, LayoutNode, branch, leaf, LayoutTemplate, Date, Double, PaneNode (+4 more)

### Community 323 - "LayoutNode"
Cohesion: 0.20
Nodes (6): SessionGroup, SessionGroup, NSMenu, NSMenuItem, SessionGroup, SessionID

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.15
Nodes (11): SwarmFleetBody, .body, SwarmFleetView, .init(coder:), SwarmNodeRowView, .body, .statusColor, CGFloat (+3 more)

### Community 325 - "FloatingPaneController"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.15
Nodes (7): ExpressibleByStringLiteral, PipeBuffer, StringError, .init(_:), .init(stringLiteral:), Result, MobileBridgeAISuggestTests

### Community 327 - ".theme"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 328 - "README.md"
Cohesion: 0.15
Nodes (9): Bool, Int32, String, URL, SystemdUserInstaller, .backendName, .isInstalled, .unitURL (+1 more)

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.18
Nodes (6): LSPTextLocation, .position, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 330 - ".drawGlyph"
Cohesion: 0.13
Nodes (15): OnboardingStep, complete, discover, .id, setup, shell, .title, welcome (+7 more)

### Community 332 - "Added"
Cohesion: 0.15
Nodes (3): CellColorResolverTests, .resolver, CellColorResolver

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

### Community 335 - ".makeModel"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 336 - "run.sh"
Cohesion: 0.19
Nodes (9): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+1 more)

### Community 337 - "CommandExecutionError"
Cohesion: 0.19
Nodes (8): AgentHistorySearch, Hit, Double, String, AgentHistorySearchTests, String, TimeInterval, URL

### Community 338 - "CSIParams"
Cohesion: 0.18
Nodes (13): FeaturePhase, architect, completed, dev, interview, qaDesign, qaVerify, .title (+5 more)

### Community 339 - "Foundation"
Cohesion: 0.19
Nodes (15): BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, Keybinding, .displayKey, MenuModifiers (+7 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.16
Nodes (9): FileGraphInfo, GraphifyLSPBridge, Double, String, URL, GraphifyLSPBridgeTests, Any, String (+1 more)

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.20
Nodes (5): CSIParams, .count, TerminalGridColor, TerminalGridUnderline, UInt8

### Community 342 - "Added"
Cohesion: 0.18
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 344 - "FileViewerViewController"
Cohesion: 0.22
Nodes (6): ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 345 - "README.md"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.20
Nodes (3): AgentCommandTests, String, Tab

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.19
Nodes (17): Close Pane, Next Session, Previous Session, Split Down, Split Right, Cmd W Closes Pane When Split, Zombie Crash Rapid Close While Typing, Zombie Crash Rapid Split Close Cycle (+9 more)

### Community 348 - "DaemonLifecycleTests"
Cohesion: 0.20
Nodes (3): String, TerminalGridSnapshot, VTConformanceCorpusTests

### Community 349 - "Contents.json"
Cohesion: 0.14
Nodes (16): AnyView, NotchOverviewRow, .approvalControls, .background, .badge, .body, .openableRow, .progressUnderline (+8 more)

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.18
Nodes (7): PaneNode, BrowserLeaf, URL, DaemonSyncServiceBrowserPaneMergeTests, PaneID, PaneNode, PaneNodeBrowserTests

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.21
Nodes (4): Bool, String, SurfaceID, TimeInterval

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.15
Nodes (9): NSEvent, NSHostingView, NSLayoutConstraint, TerminalTabBarView, .delegate, .init(frame:), .leadingInset, .mouseDownCanMoveWindow (+1 more)

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.12
Nodes (6): ScreenPos, bottom, middle, top, KouenLSP, QuickLookUI

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.26
Nodes (16): Encodable, AISuggestionAck, AttachedAck, BrowserFramePush, Cred, DetachedAck, DeviceCredentials, DirectoryListResponse (+8 more)

### Community 355 - ".deepMerge"
Cohesion: 0.21
Nodes (7): KouenIPC, AgentRoutingResolver, PaneOutputWaiter, PaneOutputWaitResult, CheckedContinuation, Never, UInt64

### Community 357 - ".handleCat"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.20
Nodes (4): CompletionGenerator, String, .fishCompletionSource, CompletionGeneratorTests

### Community 359 - "OcclusionTests"
Cohesion: 0.18
Nodes (10): AssistantLine, ClaudeAdapter, Content, Message, ResultLine, Bool, Double, String (+2 more)

### Community 360 - "State"
Cohesion: 0.16
Nodes (11): Status, ciFailing, done, mergeReady, open, running, Bool, Date (+3 more)

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.18
Nodes (14): Array, Bool, Date, Decoder, PaneID, PaneNode, String, TabID (+6 more)

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.26
Nodes (3): String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.17
Nodes (12): AnimatablePair, .body, HorizontalInsetRect, CGRect, Path, NotchShape, .animatableData, CGFloat (+4 more)

### Community 366 - "Consumers"
Cohesion: 0.19
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 368 - "Tab"
Cohesion: 0.17
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 369 - "Git Panel"
Cohesion: 0.19
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 370 - ".encode"
Cohesion: 0.20
Nodes (6): KouenWindow, NSEvent, MainWindowController, Any, NSRect, NSWindow

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.17
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.13
Nodes (12): clamp(), Date, Never, T, Task, Void, TabPillView, .dragGesture (+4 more)

### Community 373 - "Prompt"
Cohesion: 0.23
Nodes (4): KeyTokenParser, Bool, String, KeyTokenParserTests

### Community 374 - ".run"
Cohesion: 0.17
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, Bool, Double (+3 more)

### Community 376 - "ScrollReuseTests"
Cohesion: 0.19
Nodes (10): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+2 more)

### Community 377 - "Identifiable"
Cohesion: 0.18
Nodes (13): Profile, edit, readonly, Run, RunState, cancelled, failed, running (+5 more)

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.14
Nodes (11): PairingBox, .current, .isLockedOut, PendingPairing, Date, TimeInterval, TokenCheck, accepted (+3 more)

### Community 379 - "MCPServer"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 380 - "PromptQueue"
Cohesion: 0.20
Nodes (4): TerminalModes, .encode(text:modifiers:modes:), Bool, .appCursor

### Community 381 - "smoke-dmg.sh"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.14
Nodes (13): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+5 more)

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.17
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

### Community 385 - "INDEX.md"
Cohesion: 0.30
Nodes (8): .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didStartProvisionalNavigation:), LoadCompletionState, CheckedContinuation, Error, WKNavigation, WKWebView

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.22
Nodes (7): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController

### Community 387 - "User Profile"
Cohesion: 0.23
Nodes (8): LSPFileSession, Never, String, Task, URL, Void, object, Bool

### Community 388 - "Darwin"
Cohesion: 0.16
Nodes (9): Notification.Name, os, DaemonSessionError, daemonError, .description, unexpectedResponse, LatencyMonitor, String (+1 more)

### Community 389 - "HarnessCLITests"
Cohesion: 0.25
Nodes (11): AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem, FolderScanner (+3 more)

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.22
Nodes (8): ProjectDropTarget, .init(coder:), .init(frame:), NSCoder, NSDraggingInfo, NSDragOperation, NSRect, URL

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.31
Nodes (9): CGFloat, Range, Tab, TabBarLayoutMetrics, .pitch, tabDisplayTitle(), TerminalTabBarBody, .body (+1 more)

### Community 392 - "build-release.sh"
Cohesion: 0.13
Nodes (14): CodingKey, CodingKeys, description, key, showInBanner, CodingKeys, createdAt, cwd (+6 more)

### Community 393 - "create-dmg.sh"
Cohesion: 0.22
Nodes (6): ListeningPortScanner, Int32, Set, String, result, ListeningPortScannerTests

### Community 394 - "finalize-release.sh"
Cohesion: 0.22
Nodes (5): RepoResolver, Bool, String, RepoResolverTests, String

### Community 395 - "generate-app-icon.sh"
Cohesion: 0.18
Nodes (15): a2(), akn(), bpn(), cIn(), ift(), p7n(), pyn(), R1() (+7 more)

### Community 396 - "generate-appcast.sh"
Cohesion: 0.13
Nodes (11): Am(), bze(), Cm(), EQ(), Hm(), Im(), lte(), MBe() (+3 more)

### Community 397 - "measure-fluidity.sh"
Cohesion: 0.15
Nodes (8): _Bt(), by(), e7e(), fst(), hxn(), lxn(), sBt, XWt()

### Community 398 - "preview.sh"
Cohesion: 0.20
Nodes (13): ern(), G4(), G7(), Jnn(), nrn(), Qnn(), sHe(), trn() (+5 more)

### Community 399 - "sign-and-notarize.sh"
Cohesion: 0.32
Nodes (3): hqe(), M9(), mUt()

### Community 400 - "install-linux.sh"
Cohesion: 0.25
Nodes (4): TerminalGridSnapshot, ReflowPreviewTests, .feeds, String

### Community 401 - "package-app.sh"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 403 - "PresentAttempt"
Cohesion: 0.26
Nodes (14): Agent Command Does Not Crash, Agent Waiting Filter Does Not Crash, Board Command Shows Board Panel, Cd Command Switches To Matching Tab, Copy Path Command Does Not Crash, Errors Command Does Not Crash, Find Command Opens Command Palette On Empty Query, Find Command Resolves Unique File (+6 more)

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.16
Nodes (14): CLI Isolate Creates Worktree And Session, CLI Isolate With Custom Branch Name, Close Session Keeps Dirty Worktree, Close Session Removes Clean Worktree, Create Isolated Session And Select, Drag Reorder Past Worktree Row No Crash, Git Checkout In Normal Session Does Not Affect Isolated, Isolate Without Branch Uses Detached HEAD (+6 more)

### Community 405 - "AgentIconRenderer"
Cohesion: 0.24
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 406 - "main.swift"
Cohesion: 0.19
Nodes (9): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 407 - "Fixed"
Cohesion: 0.18
Nodes (8): PluginLoader, String, ScriptAPI, ScriptError, .errorDescription, evaluationError, unsupportedPlatform, JavaScriptCore

### Community 408 - "IPC Architecture"
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.33
Nodes (6): SurfaceProgressTracker, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void

### Community 410 - ".applyTerminalIdentity"
Cohesion: 0.31
Nodes (6): Bool, Counter, Scheduled, SurfaceProgressTrackerTests, DispatchWorkItem, TimeInterval

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.27
Nodes (7): Never, Set, String, Task, URL, Void, WorkspaceSymbolIndex

### Community 412 - "go.json"
Cohesion: 0.16
Nodes (6): .automationsList, String, String, .trimmed, AgentTitleInference, Bool

### Community 413 - "javascript.json"
Cohesion: 0.23
Nodes (7): BrowserPaneRegistry, .init(url:paneID:), NSWindow, PaneID, WeakBrowserPaneView, WeakScriptMessageHandler, WKScriptMessageHandler

### Community 414 - "json.json"
Cohesion: 0.21
Nodes (8): Container, .init(coder:), .init(frame:), NotchPulseHost, Context, NSCoder, NSHostingView, NSRect

### Community 415 - "markdown.json"
Cohesion: 0.22
Nodes (8): DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSViewCornerConfiguration, SurfaceID, Void

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.34
Nodes (3): Install, Shell integration (OSC 133 semantic prompts), What gets emitted

### Community 417 - "rust.json"
Cohesion: 0.14
Nodes (14): Agent handbook — Kouen (extended reference), Agent integration, Build and test, IPC, Keyboard shortcuts, kouen-cli, Native terminal renderer, Repository map (+6 more)

### Community 419 - "typescript.json"
Cohesion: 0.18
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 420 - "yaml.json"
Cohesion: 0.41
Nodes (7): FeatureSummary, FeatureTaskSummary, GateSummary, Bool, Date, String, UUID

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 422 - "HintModeOverlay"
Cohesion: 0.22
Nodes (7): DispatchSourceRead, SwarmFleetSnapshotWire, SwarmTaskNodeWire, Date, Double, String, UUID

### Community 424 - ".parseDiffHunks"
Cohesion: 0.19
Nodes (4): URL, MobileBridgeAttachFileTests, String, URL

### Community 425 - "AgentVectorIcon"
Cohesion: 0.19
Nodes (7): .init(forTesting:), UUID, Void, PanePipe, .subscribe(surfaceID:handler:), FileHandle, UUID

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.23
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 427 - ".delay"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 428 - "TaskDashboardView"
Cohesion: 0.24
Nodes (9): Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock, .block(id:) (+1 more)

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 431 - "BoardCardView"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.25
Nodes (4): StatusLineWidthTests, StatusLineWidth, String, StyledSegment

### Community 434 - "Project History"
Cohesion: 0.21
Nodes (6): String, TerminalGridCell, TextGrid, .totalLines, .viewportRows, WordColumnRangeTests

### Community 435 - ".init"
Cohesion: 0.26
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 436 - "WaitForRegistry"
Cohesion: 0.26
Nodes (4): PortableRelativeDateFormatter, Date, String, UUID

### Community 438 - "SessionEditor"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 439 - "SetupStepView"
Cohesion: 0.24
Nodes (6): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 440 - "LegacySnapshot"
Cohesion: 0.22
Nodes (6): GitStatusProvider, Duration, String, GitStatusProviderLargeOutputTests, URL, TimeoutError

### Community 441 - "RemoteHostStore"
Cohesion: 0.18
Nodes (4): KeybindingsService, Bool, Command, String

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.15
Nodes (3): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess

### Community 443 - "main.swift"
Cohesion: 0.24
Nodes (4): HintModeOverlay, Any, NSEvent, String

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.21
Nodes (3): TabID, WorkspaceID, GitPanelViewWorktreeNavigationTests

### Community 445 - "Section"
Cohesion: 0.21
Nodes (3): SessionID, KouenCommands, GitPanelViewWorktreeTaskTests

### Community 446 - "Modifiers"
Cohesion: 0.27
Nodes (5): .activeTab, .webView(_:didFinish:), BrowserTab, UUID, tabs

### Community 447 - "PaletteMode"
Cohesion: 0.17
Nodes (10): .init(frame:), .webView(_:decidePolicyFor:decisionHandler:), .webView(_:didFinish:), MainActor, NSRect, WKNavigation, WKNavigationAction, WKWebView (+2 more)

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.18
Nodes (7): CGFloat, NSColor, NSPoint, NSRect, NSWindow, WindowBorderOverlayView, .windowCornerRadius

### Community 449 - "PresentAttempt"
Cohesion: 0.23
Nodes (9): AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor (+1 more)

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.28
Nodes (10): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Duration, UUID (+2 more)

### Community 451 - ".run"
Cohesion: 0.21
Nodes (4): JSONDecoder, JSONEncoder, String, TerminalRecordingCodec

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.15
Nodes (4): KouenCLI, MemoCommandTests, URL, TaskCommandTests

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.24
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 454 - ".recordReapedGenerationForTesting"
Cohesion: 0.37
Nodes (4): KouenFeatureMarkdownSync, Bool, String, URL

### Community 455 - "ComposerPanel"
Cohesion: 0.42
Nodes (6): InstallResult, ShellCompletionInstaller, Bool, String, URL, ShellIntegration

### Community 456 - "TerminalModes"
Cohesion: 0.26
Nodes (7): InstallResult, Shell, bash, fish, zsh, Bool, URL

### Community 458 - ".deletePersistedScrollback"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 459 - ".encode"
Cohesion: 0.24
Nodes (7): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor, .panelBackground

### Community 460 - "RunState"
Cohesion: 0.18
Nodes (6): eKe(), irn(), mrn, _rn(), rrn(), srn()

### Community 461 - ".worktreeList"
Cohesion: 0.18
Nodes (10): epn(), EUe(), eYt(), lq(), ple(), rp(), Sme(), sut() (+2 more)

### Community 462 - "AGENTS.md"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 463 - ".deinit"
Cohesion: 0.26
Nodes (4): PaneLabelDaemonTests, String, URL, UUID

### Community 465 - "DirectionalAxis"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 466 - "ReflowFastPathTests"
Cohesion: 0.19
Nodes (8): CLIInstallLocator, OptionalUUID, absent, dangling, invalid, valid, URL, UUID

### Community 467 - ".moveSelection"
Cohesion: 0.29
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 468 - "Never"
Cohesion: 0.20
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

### Community 469 - "PresentAttempt"
Cohesion: 0.17
Nodes (5): DirectionalAxis, down, left, right, up

### Community 470 - "DispatchTime"
Cohesion: 0.23
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 471 - ".evaluateStyled"
Cohesion: 0.17
Nodes (11): LinePos, end, firstNonBlank, start, ViDiagnosticNavigator, ViMode, insert, normal (+3 more)

### Community 472 - "start.sh script"
Cohesion: 0.20
Nodes (9): BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool, CGFloat, NSCoder, NSPoint (+1 more)

### Community 473 - "HarnessOnboarding"
Cohesion: 0.17
Nodes (11): agy, claude, copilot, hermes, __kouen_agy_next, __kouen_claude_next, __kouen_copilot_next, __kouen_hermes_next (+3 more)

### Community 474 - "String"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 475 - ".hitTest"
Cohesion: 0.17
Nodes (11): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile, regionEdit (+3 more)

### Community 476 - ".steps"
Cohesion: 0.24
Nodes (9): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+1 more)

### Community 477 - ".endFind"
Cohesion: 0.27
Nodes (4): SurfaceIO, .currentSubscription, UInt16, UInt64

### Community 478 - ".install"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 479 - "ScrollbackTests"
Cohesion: 0.17
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 480 - "Command Prompt Architecture"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 481 - ".testKouenRendererFixtureDefaultTextReportsPlausibleGlyphStats"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 482 - ".resolve"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 483 - "Changed"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 484 - "Added"
Cohesion: 0.20
Nodes (3): SessionGroup, String, UUID

### Community 485 - ".testKouenRendererFixtureLigatureShapingPathReportsPlausibleGlyphs"
Cohesion: 0.20
Nodes (9): AnyObject, CommandExecutionError, daemonError, .description, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor (+1 more)

### Community 486 - "TabPillView"
Cohesion: 0.33
Nodes (5): AgentBridge, AgentTarget, Bool, String, SurfaceID

### Community 487 - "[1.1.2] - 2026-06-02"
Cohesion: 0.24
Nodes (5): RiskyCommandClassifier, Bool, NSRegularExpression, String, RiskyCommandClassifierTests

### Community 488 - "ccRunCancel"
Cohesion: 0.29
Nodes (6): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Carbon

### Community 489 - "Added"
Cohesion: 0.24
Nodes (5): Bool, NSObjectProtocol, String, TabID, WorktreeAutoIsolateService

### Community 490 - "ccRunGet"
Cohesion: 0.31
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 491 - "Added"
Cohesion: 0.25
Nodes (6): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.25
Nodes (7): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, NSEvent

### Community 493 - "ccRunStart"
Cohesion: 0.18
Nodes (11): Typography, .badge, .kbd, .paletteHeader, .paletteTitle, .rowMeta, .rowTitle, .sectionLabel (+3 more)

### Community 494 - "ccRunInfo"
Cohesion: 0.18
Nodes (10): Architecture Decisions (dated log), Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Post-P50 changes (v4.20.2 → v4.20.11, 2026-10-01 → 2026-10-06), Product Identity Guardrail: Terminal, Not IDE, Shipped capability summary, P44–P49 (2026-08-31 → 2026-09-23) (+2 more)

### Community 495 - "ccRuns"
Cohesion: 0.20
Nodes (5): CGImage, ImageIO, ImageLimits, Bool, ImageDecoder

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.25
Nodes (9): kouen.bash script, agy(), claude(), copilot(), hermes(), __kouen_agy_next(), __kouen_claude_next(), __kouen_copilot_next() (+1 more)

### Community 497 - ".bind"
Cohesion: 0.20
Nodes (8): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, ClosedRange, String

### Community 498 - ".automationList"
Cohesion: 0.45
Nodes (3): data, SixelDecoder, UInt8

### Community 499 - ".routingRuleList"
Cohesion: 0.27
Nodes (7): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8

### Community 500 - ".json"
Cohesion: 0.29
Nodes (5): Agent, OnboardingEnvironment, Bool, String, OnboardingEnvironmentTests

### Community 501 - "Fixed"
Cohesion: 0.24
Nodes (4): aD(), crn, ELt(), n2e()

### Community 502 - "ACP Client (Shelved)"
Cohesion: 0.20
Nodes (7): FBe(), Gbe(), handler(), _Q(), s0n(), wHt(), Xo()

### Community 503 - "Build Scripts Self-Kill Protection"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 504 - "WindowBorderOverlayView"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 505 - "Fixed"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 506 - "SwarmFleetBody"
Cohesion: 0.33
Nodes (3): MTLDevice, MTLTexture, TerminalGridSnapshot

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 508 - "SessionStore"
Cohesion: 0.18
Nodes (10): Bug 1 - Rotation Grace Slot Keeps The Previous Token Redeemable, Bug 1 - Rotation Shifts The Outgoing Token Into The Grace Slot, Bug 1 - Stop Fully Clears The Grace Slot, Bug 1 - Token Lifetime Not Regressed Below The Human-Flow Window, Bug 2 - Client onerror Does Not Clobber The Server Error Banner, Bug 2 - No Abrupt Cancel Immediately After The Error Text, Bug 2 - Reject Path Closes Gracefully With Policy-Violation Code 1008, Bug 3 - QR Not Printed When No Listener Is Ready (+2 more)

### Community 509 - "start.mjs"
Cohesion: 0.33
Nodes (6): Bool, NSPasteboard, NSString, String, URL, AutoreleasingUnsafeMutablePointer

### Community 511 - ".panePathLookup"
Cohesion: 0.22
Nodes (7): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, NSCoder, Void

### Community 512 - "Changelog Archive"
Cohesion: 0.20
Nodes (8): statusHelp(), String, TabStatus, done, error, idle, running, waiting

### Community 513 - "ThemeDocument"
Cohesion: 0.40
Nodes (4): SplitDirection, TabID, .body, TerminalTabBarDelegate

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.24
Nodes (3): KouenMCP, KouenBrowserToolsTests, URL

### Community 515 - "[1.0.6] - 2026-06-02"
Cohesion: 0.22
Nodes (4): AgentScanner, Bool, DispatchSourceTimer, TimeInterval

### Community 516 - "[1.3.0] - 2026-06-04"
Cohesion: 0.20
Nodes (7): Kind, input, metadata, output, resize, ReplayStep, Decoder

### Community 517 - ".testManyConcurrentSubscribersAllReceiveOutput"
Cohesion: 0.20
Nodes (9): CodingKeys, cols, createdAt, dataBase64, rows, timeMs, type, version (+1 more)

### Community 518 - "Bool"
Cohesion: 0.20
Nodes (9): RecordingEvent, input, metadata, output, resize, .timeMs, Date, Encoder (+1 more)

### Community 519 - ".gestureRecognizer"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 520 - "WriteOutcome"
Cohesion: 0.31
Nodes (5): AgyAdapter, Result, ResultLine, String, UUID

### Community 521 - "FileTreeKeyboardNavigator"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 522 - "ShellCompletionInstallerTests"
Cohesion: 0.29
Nodes (8): FormatColor, none, palette, rgb, StyledSegment, Bool, String, UInt8

### Community 523 - ".encode"
Cohesion: 0.20
Nodes (7): BBe(), NBe(), PBe(), qLt(), sIt(), VBe(), zLt()

### Community 524 - "RealPtyLifecycleTests"
Cohesion: 0.20
Nodes (6): _c(), jY(), Nn(), _pe(), Pqe, qp()

### Community 527 - "Agent hooks for Harness"
Cohesion: 0.27
Nodes (5): SpecialKeyMappingTests, Bool, NSEvent, String, UInt16

### Community 528 - "worktree_review_dashboard.robot"
Cohesion: 0.27
Nodes (3): DaemonReconnectPolicy, TimeInterval, DaemonReconnectPolicyTests

### Community 529 - "PickerItemRow"
Cohesion: 0.40
Nodes (9): attribute_lines(), main(), redraw_frames(), repeated_chunk(), run_case(), sgr_lines(), truecolor_gradient(), unicode_lines() (+1 more)

### Community 531 - ".recordReapedGenerationForTesting"
Cohesion: 0.29
Nodes (8): LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab, TabID, WorkspaceID

### Community 532 - "OpenClaw → Kouen"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 533 - "flushSessionState"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 534 - ".sessionID"
Cohesion: 0.27
Nodes (9): Command Prompt, Find In Files, Git Panel, Open Command Palette, Switch To Session 1, Switch To Session 2, Rapid Session Switch While Typing, Switch Between Isolated And Normal Session (+1 more)

### Community 535 - "AgentNotification"
Cohesion: 0.33
Nodes (4): GridCompositorCopyModeTests, PaneRect, String, TerminalGridSnapshot

### Community 536 - ".readGrid(scrollbackOffset:)"
Cohesion: 0.22
Nodes (6): String, URL, ThemeCatalogEmbedTests, .embedSwift, .repoRoot, .sourceJSON

### Community 537 - "NSObject"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.36
Nodes (5): PaneLeaf, SessionGroup, Any, String, Tab

### Community 540 - ".taskUpdate"
Cohesion: 0.28
Nodes (6): CGFloat, ResizeDirection, down, left, right, up

### Community 542 - ".init(from:)"
Cohesion: 0.36
Nodes (4): Bool, String, UUID, TaskDaemonBridge

### Community 543 - ".bufferLine"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 545 - ".characterIndex"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Key spec syntax, Kouen keybindings, Persistence (+1 more)

### Community 546 - "LegacySnapshot"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 547 - "NSObject"
Cohesion: 0.33
Nodes (4): OutputTrigger, OutputTriggerStore, Bool, String

### Community 548 - ".encode"
Cohesion: 0.22
Nodes (7): HeadlessRunEvent, assistantText, result, sessionID, Bool, Double, String

### Community 549 - ".init(from:)"
Cohesion: 0.33
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

### Community 550 - ".init(hex:)"
Cohesion: 0.36
Nodes (6): ClaudeRunSummary, Date, Double, Int32, String, UUID

### Community 551 - ".init(red:green:blue:alpha:)"
Cohesion: 0.22
Nodes (9): B3(), dFe(), _Dt(), fFe(), lFe(), _Ot(), sD(), TOt() (+1 more)

### Community 552 - "worktree_auto_isolate_wiring.robot"
Cohesion: 0.25
Nodes (6): calculate(), constructor(), kOt(), mBt, r2e(), sOt()

### Community 553 - "harness.resource"
Cohesion: 0.33
Nodes (4): ImageTextureCache, MTLDevice, MTLTexture, UInt8

### Community 554 - "FileTreeKeyboardNavigator"
Cohesion: 0.22
Nodes (8): Build order (unchanged from interview decision), G1 — @ file-path picker, G2 — shell tab-completion suggestion strip (heuristic, explicitly best-effort), G3 — AI command suggestion (via `claude` CLI subprocess), Logical Design, P37 Phase G — Autocomplete (mobile bridge), Strategic Design, Tactical Design

### Community 555 - "code:bash (harness view <file>                        # syntax-highligh)"
Cohesion: 0.22
Nodes (8): Artifacts, Client Application — Slice 1 (stacked panes, no persistence), Client Application — Slice 2 (per-workspace divider memory), Context, Dev Task Progress — Workspace Sidebar Panels (P42), Integration, Note on task re-sequencing (2026-07-17), Summary

### Community 556 - "BrowserTab"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 557 - ".viewWillMove"
Cohesion: 0.31
Nodes (6): TerminalGridCell, ThaiClusterCopyTests, ThaiGrid, .columns, .totalLines, .viewportRows

### Community 558 - ".sendInput"
Cohesion: 0.28
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.22
Nodes (8): MCP Control Allowed With Env Var, MCP Control Denied Without Env Var, MCP KouenBoard Returns Columns, MCP KouenList Returns Sessions, MCP ReadPaneOutput Returns Content, Run MCP Request, Run MCP Request Allowed, Run MCP Request Denied

### Community 560 - "LayoutTemplate"
Cohesion: 0.22
Nodes (8): Browser Pane Open Close Rapid, File Preview Open Close, Git Fetch Shows Toast, Launch Kouen Staging, Memory Stability After 30 Seconds, Quit Kouen Staging, Sidebar Toggle Immediately After Launch, Tab Close While Mouse Moving

### Community 561 - "Added"
Cohesion: 0.36
Nodes (7): Document, Bool, Set, String, URL, ToolPolicy, .defaultURL

### Community 564 - "📁 IDE Sidebar"
Cohesion: 0.25
Nodes (7): Agent Memory, Graphify, graphify, kouen-terminal — Agent Instructions, Rules (read when triggered), Session Start, Skills & Rules

### Community 565 - "ReleaseNotesGuardTests"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 566 - "TerminalTabBarView.swift"
Cohesion: 0.36
Nodes (3): .agentInfo(forWorktreePath:tabs:), Tab, GitPanelViewWorktreeAgentTests

### Community 568 - ".gestureRecognizer"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.25
Nodes (8): A `claude` typed by hand, Claude Code → Kouen, Customizing, One-line install, Session mode: Remote Control / cloud / local, The reverse direction: a session opened in Claude showing up in Kouen, Verifying, What gets written

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.39
Nodes (5): AutomationSummary, Bool, Date, String, UUID

### Community 572 - "LayoutProbeView"
Cohesion: 0.25
Nodes (5): Bool, NSEvent, ViInputMode, insert, normal

### Community 573 - "main.swift"
Cohesion: 0.25
Nodes (7): Claude Code hook push (in-process Task subagent detection), Client UI indicator, Detection core (AgentDetector, pure logic), IPC / Tab plumbing, P38 Phase B — Subagent Visibility — Dev Task Progress, Status: Rewritten 2026-07-14 after original implementation (tasks 1-5) was lost to a concurrent git operation before commit. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 574 - "generate-release-notes.swift"
Cohesion: 0.25
Nodes (7): Original overlay build (built 2026-07-14, gated green, then deleted 2026-07-15 mid live-test), P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress, Pivot — merge into the Recipes picker (2026-07-15), Stage 1-2 — Engine/surface plumbing (built 2026-07-14, unchanged by the pivot, still in use), Status: Implementation pivoted mid-phase from a standalone overlay to a merge into the existing, Summary, Thread grouping — Zed framing folded into the same picker (2026-07-15)

### Community 575 - ".toastErrorSummary"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 576 - "Phase67Tests"
Cohesion: 0.25
Nodes (7): #kouen, #practice, #score, #shell, #total, #unix, #vim

### Community 577 - "SwarmFleetView"
Cohesion: 0.25
Nodes (3): FlushSessionStateTests, String, URL

### Community 578 - "TaskDashboardBody"
Cohesion: 0.43
Nodes (7): Close Tab, New Tab, Cmd Shift W Force Closes Tab, Cmd T Creates New Session, Cmd W Closes Tab When Single Pane, Window Survives Full Shortcut Sequence, Zombie Crash Close Tab While Typing

### Community 579 - "RunState"
Cohesion: 0.29
Nodes (7): Toggle Sidebar, Sidebar Toggle Works, Board CLI Shows Columns, Board CLI Shows Running After Long Command, Board Columns Visible After Click, Board Tab Accessible In Sidebar, Split Pane And Resize

### Community 584 - ".configureEnvironment"
Cohesion: 0.38
Nodes (4): AnyObject, TimeInterval, ZombieHoldRegistry, ObjectIdentifier

### Community 586 - ".consumeInputCore"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 587 - "BrowserResponsePayload"
Cohesion: 0.29
Nodes (7): Agent hooks for Kouen, CLI notification, Example Claude Code hook, Jump to waiting agent, OSC sequences (from terminal output), Per-agent guides, Set up via your IDE (copy/paste prompt)

### Community 588 - "jHt"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 589 - "Endpoint"
Cohesion: 0.29
Nodes (7): 1. Plain Terminal, 2. Persistent Terminal, 3. Full Terminal, 4. Agent Workspace, Experience modes, Opting into the prefix + status line without switching modes, Persistence (ephemeral vs. persistent)

### Community 590 - "lrn"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Kouen-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 592 - "commit-push.sh"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 593 - "dO"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 594 - "hJ"
Cohesion: 0.38
Nodes (5): SwarmLane, pty, structured, SwarmSpawnSpec, String

### Community 595 - "full-cycle.sh"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 596 - "prepare-release.sh"
Cohesion: 0.29
Nodes (7): blockTokens(), inlineTokens(), lex(), lexer(), lexInline(), me(), reflink()

### Community 597 - "rH"
Cohesion: 0.29
Nodes (7): GRt(), n4e(), p7e(), r2(), tl(), vrt(), xq()

### Community 599 - "nJt"
Cohesion: 0.29
Nodes (6): .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8

### Community 600 - "HarnessTerminalSurfaceView"
Cohesion: 0.33
Nodes (3): Bool, CAMetalDrawable, String

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
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 607 - "iRe"
Cohesion: 0.38
Nodes (6): Cleanup And Quit, Create Config File, No Config File Starts Normally, Script Hot Reload On Save, Script Loads On Startup, Script Syntax Error Does Not Crash

### Community 609 - "FormatContextDaemonTests"
Cohesion: 0.29
Nodes (6): Bug 1 - Browser Pane Deferred Unregister, Bug 1 - Browser Pane Reuse On Rebuild, Bug 2 - New Session Syncs Before Reading Active Tab, Bug 2 - Tab Bar New Tab Also Syncs, Bug 3 - Browser Pane Forces Redraw On Reattach, Build Compiles Successfully

### Community 610 - ".installCLI"
Cohesion: 0.47
Nodes (4): AgentBadgeView, .body, Bool, CGFloat

### Community 611 - ".copy"
Cohesion: 0.47
Nodes (5): AgentIconArt, AgentVectorIcon, Bool, CGSize, String

### Community 613 - "INDEX.md"
Cohesion: 0.53
Nodes (3): ProjectConfig, Bool, String

### Community 614 - "MainSplitViewController"
Cohesion: 0.33
Nodes (6): h1t(), hae(), jgn(), pwn(), sfn(), _Ue()

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

### Community 623 - "BrowserResponsePayload"
Cohesion: 0.33
Nodes (5): Kouen LSP Diagnostics Does Not Crash, Kouen LSP Hover Returns Result, Kouen LSP Start Returns JSON, Kouen View Binary Shows Guard Message, Kouen View Prints File Content

### Community 624 - "[2.5.0] - 2026-06-12"
Cohesion: 0.67
Nodes (3): AsyncCLIResultBox, Error, Result

### Community 626 - "cGt"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 630 - "d3n"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: animateSidebar setContentLeadingInset MainSplitViewController, Source Nodes

### Community 631 - "die"
Cohesion: 0.40
Nodes (5): WrapperOptionBehavior, keepScanning, matchValue, skipValue, stopScanning

### Community 633 - "g_n"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 634 - "qC"
Cohesion: 0.40
Nodes (5): ColorKind, .base, bg, fg, underline

### Community 635 - "hen"
Cohesion: 0.50
Nodes (5): aut(), cpn(), hq(), kLt(), q1n()

### Community 636 - "fht"
Cohesion: 0.50
Nodes (5): aze(), cR(), oze(), xGe(), yGe()

### Community 640 - "zpt"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 641 - "[3.10.0] - 2026-06-27"
Cohesion: 0.60
Nodes (3): .encode(_:modifiers:event:modes:), SpecialKey, insert

### Community 642 - "qut"
Cohesion: 0.40
Nodes (4): Build, Release & Git Workflow, Build / Test / Run, Release packaging order, Worktree constraint

### Community 643 - "h7n"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 644 - "clean-state.sh"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 645 - "stability_release.robot"
Cohesion: 0.70
Nodes (4): main(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 646 - "[3.10.1] - 2026-06-27"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 647 - "graphify reference: query, path, explain"
Cohesion: 0.40
Nodes (4): Leak A - Retiring A Host Drops Its AI Controllers, Leak B - Browser Network Capture Is Bounded, Leak C - Every Per-Surface Dict In Coordinator Has Retire Cleanup, Leak D - Every Per-Surface Dict In NotificationCoordinator Is Snapshot-Swept

### Community 652 - "TerminalHostView"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

### Community 653 - "iOn"
Cohesion: 0.50
Nodes (4): Full local signing path (needs a Developer ID cert; not currently used), How this fork actually releases, Release runbook, Scripted flow

### Community 654 - "press_shortcut"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 655 - "nht"
Cohesion: 0.50
Nodes (3): exclude_hubs, no_viz, wiki

### Community 656 - "Jcn"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: SSETransport auth token isRunning

### Community 658 - "k0n"
Cohesion: 0.50
Nodes (3): SplitDirection, horizontal, vertical

### Community 660 - "qAn"
Cohesion: 0.50
Nodes (3): azt(), ibe(), q$e()

### Community 661 - "Remote SSH — Market Comparison"
Cohesion: 0.50
Nodes (4): dO(), m8(), rfn(), zfn()

### Community 662 - "New Tab"
Cohesion: 0.67
Nodes (4): FVe(), hJ(), qVe(), Zme()

### Community 663 - "m6e"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 665 - "nb"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 666 - "BrowserIntegrationController"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 667 - "[3.3.0] - 2026-06-18"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 668 - "nje"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 669 - ".recordReapedGenerationForTesting"
Cohesion: 0.50
Nodes (3): RawSocketError, connectFailed, writeFailed

### Community 671 - ".getBlock"
Cohesion: 0.50
Nodes (3): Bug 1 - Hunks Button Has Explicit Size Constraints, Bug 1 - Hunks Button Symbol Has A Guaranteed-Valid Fallback, Build Compiles Successfully

### Community 672 - "ColorKind"
Cohesion: 0.50
Nodes (3): Guard A - Merge Call Site Never Passes --no-ff, Guard B - No Auto-Resolve Anywhere In The Merge/Conflict Path, Guard C - Merge Conflict State Is Reconciled, Not Just Read Once

### Community 678 - ".selectAdjacentSession"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 679 - ".daemonIsStale"
Cohesion: 0.67
Nodes (3): cat(), Hwe(), kYe()

### Community 680 - ".recordReapedGenerationForTesting"
Cohesion: 0.67
Nodes (3): cfn(), fut(), qYe()

### Community 681 - ".tabIDsToNotify"
Cohesion: 0.67
Nodes (3): dht(), k0t(), l1n()

### Community 684 - "New Tab"
Cohesion: 0.67
Nodes (3): iRe(), jNt(), zNt()

## Knowledge Gaps
- **2319 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+2314 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1093 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `AgentNotchRootView` to `ThemeDocument`, `[1.3.0] - 2026-06-04`, `IPCRequest`, `Bool`, `EngineConformanceTests`, `.gestureRecognizer`, `Command`, `PerformanceBenchmarks`, `ShellCompletionInstallerTests`, `Changed`, `VTParser`, `HarnessTerminalSurfaceView`, `worktree_review_dashboard.robot`, `MetalRendererTests`, `HarnessUILibrary`, `SpecialKey`, `code:block1 (Agent shell process)`, `HarnessTerminalSurfaceView`, `CopyModeAction`, `SplitPaneCoordinator`, `.request`, `WorktreeManager`, `Harness tmux-style capabilities`, `RGBColor`, `.taskUpdate`, `.parse`, `Notification`, `Added`, `.addTab`, `Equatable`, `DaemonClient`, `MenuTarget`, `code:bash (harness chat "Use the project map first, then inspect this r)`, `.init(from:)`, `code:bash (swift build)`, `String`, `HarnessSettings`, `harness.resource`, `HarnessSidebarPanelViewController.swift`, `RenderSchedulerTests`, `HarnessOverlayBackground`, `HarnessTerminalSurfaceView.swift`, `.viewWillMove`, `.normalizedKey`, `HookEvent`, `DaemonServer`, `Added`, `.keyEvent`, `Added`, `Cross-terminal output-stress benchmark`, `TabCell`, `CommandHistorySearchController`, `PasteBufferStore`, `ViEngine`, `FrecencyDirectoryStore`, `.text`, `PrefixKeymap`, `String`, `.compose`, `worktree_isolation_cli.robot`, `ImportedTerminalConfig`, `XCTestCase`, `[2.6.0] - 2026-06-13`, `NSPanel`, `.parse`, `TerminalProtocolCompatibilityTests`, `Added`, `HarnessDesign`, `Agent handbook — Harness (extended reference)`, `commit-push.sh`, `LSPClient`, `TerminalGridCell`, `nJt`, `Harness as a terminal multiplexer`, `SessionCoordinator`, `fut`, `Fixed`, `code:bash (# Terminal 1: Create workspace with long-running job)`, `AttachInputBatcher`, `P2 — Async IPC Refactor: Design Document`, `Harness Usage`, `4. Technical Architecture`, `.dispatch`, `ScriptRuntime.swift`, `Session Grouping and Split Session Plan`, `DaemonLauncher`, `AnyCodable`, `Recipe`, `Changelog`, `AgentNotchViewModel`, `code:text (:workbench start swift)`, `.makeSnapshot`, `.recordReapedGenerationForTesting`, `[2.5.0] - 2026-06-12`, `.encode`, `SessionGroup`, `PaneNode`, `Changed`, `ViEngine`, `Pipe`, `g_n`, `String`, `qC`, `HistoryRingBuffer`, `SwiftUI`, `AgentHookInstaller`, `.load`, `AgentNotification`, `.startWatching`, `PtyDrainCeilingBenchmark`, `hjt`, `User Story Mapping (MANDATORY)`, `Added`, `.testPaneLeafLegacyDecodeBackfillsSurfaceTabs`, `CopyModeGridSource`, `How to use Harness from the terminal only (no GUI)`, `NSObject`, `DecodedImage`, `MCPServer`, `HarnessDaemonToolsTests`, `Fixed`, `install-app.sh`, `LiveResizeTests`, `Int`, `ThaiCombiningMarkTests`, `Fixed`, `Harness Terminal — IDE Sidebar Feature Branch`, `MatchCategory`, `qte`, `What You Must Do When Invoked`, `CommandPromptController`, `ActiveTabCloseDisposition`, `Fixed`, `URLDetection`, `.decodeKeySpec`, `RGBColorTests`, `Added`, `FormatStringExtendedVariableTests`, `.hold`, `VTConformanceCorpusTests`, `P25 — iOS/iPadOS Support`, `LSPServerRegistry`, `targets`, `Error`, `AppDelegate`, `BrowserPaneView`, `user-stories.md`, `ScriptRuntime`, `BinaryInstaller`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `CodingKeys`, `MCP Server (harness-mcp)`, `Harness keybindings`, `From tmux`, `scheduleRender`, `CodingKeys`, `PaneTarget`, `Fixed`, `String`, `.lines`, `CellColorResolverTests`, `AI-SDLC Task Progress — headless-worker-followup`, `TerminalServicesProvider`, `HarnessPathDisplay`, `FileChangeWatcher`, `SSHTunnelManagerTests`, `sessionRow`, `.decide`, `HarnessGridTerminalTests`, `TerminalMetalRenderer`, `NSDraggingSource`, `graphify reference: commit hook and native CLAUDE.md integration`, `ThemeDocumentTests`, `Experience modes`, `DaemonMetrics`, `SessionCoordinator`, `NSViewRepresentable`, `Split Right`, `WindowTitleStripView`, `ThemeFileServiceTests`, `code:bash (harness-cli install-hooks claude-code)`, `code:bash (harness-cli install-hooks cursor)`, `Fixed`, `code:bash (# Old (agent-specific):)`, `SGRMouseEvent`, `KeySpec`, `[2.5.0] - 2026-06-12`, `.run`, `BlockTintOverlay`, `.textRendering`, `TerminalScrollbarView`, `RemoteHostStoreTests`, `FormatColor`, `code:bash (harness-cli install-hooks hermes)`, `AgentHookStrategy`, `JSONDecoder`, `Fixes Applied (layered)`, `settings.json`, `ThemeDiagnostics`, `.script`, `RegressionBugFixTests`, `ViPathTokenTests`, `Send Ex Command`, `Bug: Tab-Switch Black Screen`, `AgentSnapshot`, `Terminal AI Chat (⌘I inline overlay)`, `Added`, `Memory — harness-terminal`, `ImmersivePalette.swift`, `.drawGlyph`, `RealPty`, `ImageProtocolTests.swift`, `.makeModel`, `CommandExecutionError`, `CSIParams`, `code:bash (harness-cli install-hooks openclaw)`, `code:bash (harness-cli install-hooks pi)`, `Added`, `[2.2.3] - 2026-06-09`, `FileViewerViewController`, `DaemonLifecycleTests`, `Contents.json`, `Architecture Decisions — harness-terminal`, `.deepMerge`, `FormatStyledSegment.swift`, `generate-cheatsheet.js`, `[2.2.4] - 2026-06-11`, `DynamicInstanceBuffer`, `Prompt`, `.run`, `SurfaceProgressTrackerTests.swift`, `PromptQueue`, `smoke-dmg.sh`, `HarnessCLITests`, `AppKit + Metal Patterns`, `create-dmg.sh`, `install-linux.sh`, `AgentIconRenderer`, `Session/Tab/Pane Hierarchy & Top Bar (CASE-028)`, `.applyTerminalIdentity`, `Task 1: Redesign Session Sidebar`, `markdown.json`, `yaml.json`, `HintModeOverlay`, `TaskDashboardView`, `LaunchdServiceInstaller`, `Project History`, `main.swift`, `Modifiers`, `.run`, `.deleteWorkspaceFromMenu`, `.recordReapedGenerationForTesting`, `.deletePersistedScrollback`, `DirectionalAxis`, `Never`, `start.sh script`, `Service Decomposition — SessionCoordinator (P17)`, `ccRuns`, `.bind`, `.automationList`, `SwarmFleetBody`, `memory_leak_guards.robot`?**
  _High betweenness centrality (0.266) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `code:bash (harness chat "Use the project map first, then inspect this r)` to `.text`, `Process`, `AgentNotchRootView`, `.openAnimation`, `Fixed`, `Fixed`, `BoardCard`, `DamageTrackingTests`, `TerminalMetalRenderer`, `VTParser`, `HarnessTerminalSurfaceView.swift`, `Added`, `KittyKeyboardTests`, `user-stories.md`?**
  _High betweenness centrality (0.213) - this node is a cross-community bridge._
- **Why does `fbt()` connect `callingPaneTarget` to `CodingKey`, `BellScanState`, `Process`, `Changed`?**
  _High betweenness centrality (0.113) - this node is a cross-community bridge._
- **Are the 18 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `RenderScheduler`) actually correct?**
  _`KouenTerminalSurfaceView` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _2339 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.006976495345436388 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.01590021391854067 - nodes in this community are weakly interconnected._