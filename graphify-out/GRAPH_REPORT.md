# Graph Report - kouen-terminal  (2026-09-27)

## Corpus Check
- 871 files · ~989,630 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 20336 nodes · 54888 edges · 2055 communities (634 shown, 1421 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8141 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `e0409fad`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 343 edges
2. `i()` - 321 edges
3. `a()` - 284 edges
4. `t()` - 253 edges
5. `SessionCoordinator` - 235 edges
6. `TerminalEmulator` - 229 edges
7. `u()` - 219 edges
8. `SurfaceRegistry` - 215 edges
9. `DaemonClient` - 210 edges
10. `IPCRequest` - 208 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `KouenPaths` - bridges 60 areas (149 edges)
2. `Process` - bridges 55 areas (105 edges)
3. `SessionCoordinator` - bridges 54 areas (235 edges)
4. `AgentKind` - bridges 54 areas (158 edges)
5. `SessionSnapshot` - bridges 46 areas (181 edges)
6. `DaemonClient` - bridges 41 areas (210 edges)
7. `t()` - bridges 39 areas (253 edges)
8. `SurfaceRegistry` - bridges 39 areas (215 edges)
9. `Notification` - bridges 37 areas (67 edges)
10. `KouenTerminalSurfaceView` - bridges 36 areas (343 edges)

## Surprising Connections (you probably didn't know these)
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/RemoteHostsService.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.selectWorkspace(byIndex:)` --references--> `SessionSnapshot`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/SessionCoordinator.swift → Packages/KouenIPC/Sources/KouenIPC/SessionSnapshot.swift
- `ThemeImportController` --calls--> `ThemeFileService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/ThemeImportController.swift → Packages/KouenTheme/Sources/KouenTheme/ThemeFileService.swift
- `WorktreeAutoIsolateService` --calls--> `WorktreeManager`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/WorktreeAutoIsolateService.swift → Packages/KouenCore/Sources/KouenCore/Worktree/WorktreeManager.swift

## Import Cycles
- None detected.

## Communities (2055 total, 1421 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.12
Nodes (14): SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, SessionID, SplitDirection (+6 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.15
Nodes (3): AgentLaunchCommandsTests, URL, Void

### Community 2 - ".handleNormal"
Cohesion: 0.08
Nodes (20): IndexingIterator, LayoutTemplate, surfaceID, SessionEditor, .split(node:targetPaneID:direction:paneCount:before:), .split(node:targetPaneID:with:direction:beforeTarget:), .surfaceID(forPaneID:), .surfaceID(forPaneID:in:) (+12 more)

### Community 3 - "Changed"
Cohesion: 0.03
Nodes (106): _0t(), a8n(), agn(), agt(), _at(), bce(), byn(), c8n() (+98 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.08
Nodes (24): DaemonClient, Int32, String, TimeInterval, UUID, Void, ClaudeCodeHarnessIPCTests, String (+16 more)

### Community 5 - "IPCRequest"
Cohesion: 0.08
Nodes (23): UInt16, Data, DecodedReplyFrame, output, reply, DecodedRequestFrame, input, request (+15 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.06
Nodes (44): AnyTransition, AnyView, AgentNotchPeekEvent, AgentNotchRootView, .body, .bottomRadius, .closedAccessibilityLabel, .closedTransition (+36 more)

### Community 7 - "Command"
Cohesion: 0.09
Nodes (31): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+23 more)

### Community 8 - "LSPMessage"
Cohesion: 0.06
Nodes (42): a6(), aJ(), bvt(), CWt(), dUe(), eJ(), EWt(), fle() (+34 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.10
Nodes (13): .agentColorBinding, colors, PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Double, MTLDevice (+5 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.07
Nodes (43): KouenGridTerminal, .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8, RawSelection (+35 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.11
Nodes (15): .addSurface(tabID:paneID:), .addSurface(to:paneID:surfaceID:cwd:), .tab(containingPaneID:), .tab(forSurfaceKey:), .tabIndex(surfaceID:), .tabIndex(surfaceKey:), .tabIndex(workspaceID:tabID:), Bool (+7 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.06
Nodes (63): a(), b(), c(), d(), f(), g(), h(), I() (+55 more)

### Community 14 - "VTParser"
Cohesion: 0.16
Nodes (8): StringKind, apc, dcs, UInt8, UnsafeBufferPointer, VTParser, .feed(_:), VTParserHandler

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.05
Nodes (36): DaemonCommandExecutor, Command, HookExecutor, DispatchQueue, .init(forTesting:), UUID, Void, BellScanState (+28 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.09
Nodes (9): Bool, String, UInt8, UnsafeBufferPointer, TerminalEmulator, .captureLines(fromLine:toLine:), .onSetClipboard, ImageProtocolTests (+1 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.21
Nodes (10): PaletteAction, PaletteGrepMatch, PaletteModel, PaletteRow, header, PaletteSectionHeader, .body, .body (+2 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.10
Nodes (26): DaemonSubscription, .start(onData:onEnd:buffered:), .start(onResponse:onEnd:), Bool, UInt64, UnsafeMutableRawPointer, sysClose(), sysRead() (+18 more)

### Community 19 - "SpecialKey"
Cohesion: 0.15
Nodes (12): CKouenSys, Darwin, Dispatch, Foundation, Glibc, PtyError, launchFailed, ShellLaunchProfile (+4 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.20
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.04
Nodes (63): _5e(), ast(), b3e(), c2t(), c6(), cmn(), d1n(), d4n() (+55 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.01
Nodes (486): _1n(), _2t(), _3n(), _5n(), _6e(), _8n(), _9e(), a2n() (+478 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.10
Nodes (21): OptionStore, OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Scope, pane (+13 more)

### Community 24 - ".request"
Cohesion: 0.04
Nodes (66): aae(), aR(), Cjt(), cKt(), copy(), cYt(), dC(), DGt() (+58 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.10
Nodes (18): PendingVersionBanner, welcome, whatsNew, State, Bool, String, URL, VersionBannerStore (+10 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.11
Nodes (48): aVe(), b(), Bje(), cVe(), DJt(), dzt(), FR(), gJt() (+40 more)

### Community 27 - "RGBColor"
Cohesion: 0.15
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 28 - ".parse"
Cohesion: 0.03
Nodes (268): e(), pe(), r, t(), X(), A(), code(), R() (+260 more)

### Community 30 - "Notification"
Cohesion: 0.13
Nodes (10): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, Task, Void (+2 more)

### Community 31 - "Sendable"
Cohesion: 0.14
Nodes (12): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+4 more)

### Community 32 - ".addTab"
Cohesion: 0.09
Nodes (22): FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body, .emptyState (+14 more)

### Community 33 - "Equatable"
Cohesion: 0.12
Nodes (13): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, PaneID (+5 more)

### Community 34 - "DaemonClient"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 35 - "MenuTarget"
Cohesion: 0.17
Nodes (3): TerminalGridCell, TerminalGridSnapshot, ThaiCombiningMarkTests

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.14
Nodes (28): Cleanup Test Repo, Close Isolated Session Keeps Dirty Worktree, Close Isolated Session Removes Clean Worktree, Close One Isolated Does Not Affect Another, Close Session With Split Panes Removes Worktree, Create Isolated Session, Create Isolated Session Via CLI, Get Active Pane (+20 more)

### Community 37 - "String"
Cohesion: 0.07
Nodes (24): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSEvent (+16 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.16
Nodes (14): BrowserOkAck, ConnectionState, .authorized, .browserPaneID, .deviceID, .snapshotSubscription, .subscription, .surfaceID (+6 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.05
Nodes (30): o, AI(), aXe(), aZ(), bee(), cy(), Da(), dAn() (+22 more)

### Community 41 - "CodingKeys"
Cohesion: 0.06
Nodes (34): ClientRecord, CountBox, DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed (+26 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.14
Nodes (18): CommandParseError, .description, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand (+10 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.08
Nodes (24): 1 — Process lifecycle & supervision, 2 — IPC protocol evolution, 3 — Concurrency architecture, 4 — State persistence, 5 — Render/PTY data path & the "mktemp failed" spam, 6 — Build/release pipeline, A10 (Low) — stale `@unchecked Sendable` inventory, A1 (High) — S1 daemon-reuse is undone at GUI relaunch by the build-handshake staleness check (+16 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.15
Nodes (9): Process, SSHTunnelManager, .init(makeTunnelProcess:reachabilityProbe:), Bool, URL, Tunnel, SSHTunnelManagerTests, String (+1 more)

### Community 46 - ".buildCommand"
Cohesion: 0.09
Nodes (16): DaemonClientActor, TimeInterval, DaemonSessionError, daemonError, .description, unexpectedResponse, DaemonSessionService, .endpoint (+8 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.06
Nodes (22): TerminalGridCell, TerminalGridSnapshot, .captureLines(joinWrapped:), .feed(_:), .promptRows, .readGrid(scrollbackOffset:), TerminalGridSnapshot, Case (+14 more)

### Community 48 - "HookEvent"
Cohesion: 0.16
Nodes (12): Executor, Hook, HookEvent, HookRegistry, Bool, Command, URL, UUID (+4 more)

### Community 49 - "DaemonServer"
Cohesion: 0.09
Nodes (43): A1(), aw(), awt(), b2(), bMt(), bw(), cw(), e3() (+35 more)

### Community 51 - ".keyEvent"
Cohesion: 0.11
Nodes (26): ColorKind, .base, bg, fg, underline, CompositorPane, GridCompositor, .render(panes:status:statusSegments:) (+18 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.07
Nodes (38): .pairedAlreadyBanner, .pairingQRPanel, .body, ArtifactKind, html, image, markdown, text (+30 more)

### Community 55 - "TabCell"
Cohesion: 0.18
Nodes (6): AnyCodable, JSONRPCError, Int32, Pipe, String, ToolRegistry

### Community 56 - "NSPanel"
Cohesion: 0.16
Nodes (10): QuickTerminalController, QuickTerminalPanelDelegate, Any, Bool, NSEvent, NSPanel, NSRect, NSScreen (+2 more)

### Community 57 - "BellScanState"
Cohesion: 0.13
Nodes (12): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+4 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.11
Nodes (32): MTLClearColor, MTLCommandBuffer, MTLRenderCommandEncoder, BgInstance, CursorCacheKey, .invertsGlyph, DecoInstance, EncodedFrameInstances (+24 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.07
Nodes (37): TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid, TerminalTextRenderingMode (+29 more)

### Community 60 - "ViEngine"
Cohesion: 0.05
Nodes (43): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, SwarmDAGStore, String, UUID, SwarmFleetSnapshot (+35 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.14
Nodes (20): ComposedCell, .asGridCell, .init(_:), .init(codepoint:fg:bg:underlineColor:bold:dim:italic:underline:blink:inverse:invisible:strikethrough:overline:), .scalar, .sgr, CompositorPane, GridCompositor (+12 more)

### Community 62 - "ComposedCell"
Cohesion: 0.08
Nodes (32): b2n(), b2t(), cdn(), Dwe(), f6(), gCn(), ght(), hg() (+24 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 64 - ".text"
Cohesion: 0.13
Nodes (9): NSDraggingInfo, NSDragOperation, PasteController, Bool, NSPasteboard, String, TimeInterval, URL (+1 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.12
Nodes (5): KouenThemeCatalog, .allThemes, String, KouenThemeCatalogTests, ThemeDiagnosticsTests

### Community 67 - "String"
Cohesion: 0.13
Nodes (16): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+8 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.05
Nodes (44): AgentBridge, AgentTarget, Bool, String, SurfaceID, .onCurrentCWD, .onCurrentFile, LinePos (+36 more)

### Community 69 - ".compose"
Cohesion: 0.12
Nodes (12): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, input (+4 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.09
Nodes (39): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+31 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 72 - "XCTestCase"
Cohesion: 0.22
Nodes (10): Status, ciFailing, done, mergeReady, open, running, Bool, Date (+2 more)

### Community 73 - "README.md"
Cohesion: 0.50
Nodes (3): Hermes → Kouen, One-line install, Required: approve the hook

### Community 75 - "OptionStore"
Cohesion: 0.10
Nodes (23): bNt(), bu(), cNt(), dNt(), eNt(), eRe(), fNt(), iNt() (+15 more)

### Community 76 - ".parse"
Cohesion: 0.15
Nodes (10): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab, UUID (+2 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.11
Nodes (13): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, PaneLeaf (+5 more)

### Community 79 - "HarnessDesign"
Cohesion: 0.13
Nodes (13): MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem, SessionGroup (+5 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 82 - ".firstMatch"
Cohesion: 0.06
Nodes (20): .receive(_:), DispatchSemaphore, LiveResizeGeometry, Result, Bool, FluidityBenchmarks, NSWindow, String (+12 more)

### Community 83 - "LSPClient"
Cohesion: 0.14
Nodes (15): Error, LSPClient, LSPClientError, missingPipe, processNotRunning, serverNotExecutable, AsyncStream, CheckedContinuation (+7 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.06
Nodes (25): Logger, OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, .event(_:), .interval(_:_:) (+17 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.11
Nodes (19): CodingKeys, error, id, jsonrpc, method, params, result, LSPDiagnostic (+11 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.16
Nodes (9): FileEditorView, Bool, NSEvent, NSHostingView, String, URL, FileEditorViewQuickLookRoutingTests, String (+1 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.15
Nodes (14): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+6 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.08
Nodes (37): bXt(), cJ(), dXt(), eGt(), Eme(), F0(), fXt(), gC() (+29 more)

### Community 89 - ".cursorPos"
Cohesion: 0.15
Nodes (5): .hookButtonTitle, hooks, AgentHookInstallerTests, String, URL

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.16
Nodes (10): pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal, Int32 (+2 more)

### Community 91 - "TerminalModes"
Cohesion: 0.12
Nodes (6): Bool, NSPasteboard, URL, NSPasteboard, URL, KouenTerminalSurfaceDragDropTests

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.14
Nodes (8): .effectiveResumeCommand(claudeMode:), LiveClaudeAgentEntry, .placement, ClaudeSessionMode, AgentHistoryScannerTests, Date, String, Void

### Community 94 - "AttachInputBatcher"
Cohesion: 0.19
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 95 - "shim.c"
Cohesion: 0.12
Nodes (19): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerFooter, .body, DirectoryPickerModel (+11 more)

### Community 96 - "Harness Usage"
Cohesion: 0.18
Nodes (9): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, FormatColor, String (+1 more)

### Community 97 - "PaneContainerView"
Cohesion: 0.15
Nodes (10): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, Set, SurfaceID (+2 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.09
Nodes (5): KouenSettings, ExperienceModeTests, KouenSettingsTests, URL, Void

### Community 99 - ".dispatch"
Cohesion: 0.16
Nodes (12): FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID, KouenFeature (+4 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.11
Nodes (15): StatusLineView, .init(coder:), CGFloat, FormatColor, Never, NSAttributedString, NSCoder, NSColor (+7 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.15
Nodes (11): TerminalDamage, RenderColor, MetalRendererTests, RenderedFixture, Bool, MTLTexture, StaticString, String (+3 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.09
Nodes (23): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+15 more)

### Community 104 - "Recipe"
Cohesion: 0.10
Nodes (25): Bool, UInt8, TerminalCellWidth, normal, spacerTail, wide, TerminalCursor, TerminalCursorShape (+17 more)

### Community 105 - "Changelog"
Cohesion: 0.16
Nodes (9): AgentListFormatter, Date, String, dvn(), ht(), AgentListFormatterTests, Bool, Date (+1 more)

### Community 106 - "domain-design.md"
Cohesion: 0.13
Nodes (10): ScrollbackFile, .highWater, Bool, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.07
Nodes (12): SessionCoordinator, Bool, Double, PaneID, PaneNode, SessionID, SplitDirection, String (+4 more)

### Community 108 - ".resolve"
Cohesion: 0.11
Nodes (18): SavedLayoutStore, Bool, String, URL, UUID, PaneLayoutShape, branch, leaf (+10 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.13
Nodes (8): SGRMouse, SGRMouseEvent, Bool, PaneRect, UInt8, SGRMouseTests, String, UInt8

### Community 110 - "SoftIconButton"
Cohesion: 0.18
Nodes (6): CopyModeReducerTests, FakeGrid, .totalLines, Set, String, TerminalGridCell

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.07
Nodes (17): Int, HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor, Bool, ClosedRange (+9 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.21
Nodes (4): KeyTokenParser, Bool, String, KeyTokenParserTests

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.06
Nodes (41): FilterStatus, active, all, completed, CaseIterable, ExperienceMode, agent, .displayName (+33 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.14
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 115 - ".encode"
Cohesion: 0.13
Nodes (16): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, ModelProvider, ProviderKeyRow, .body (+8 more)

### Community 116 - "SessionGroup"
Cohesion: 0.20
Nodes (7): AgentRoutingRuleStore, Bool, String, URL, UUID, AgentRoutingRuleStoreTests, URL

### Community 117 - "PaneNode"
Cohesion: 0.10
Nodes (11): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+3 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.04
Nodes (67): a9n(), aat(), AS(), Bm(), bTn(), c5n(), cc(), d2() (+59 more)

### Community 119 - "Harness command reference"
Cohesion: 0.06
Nodes (30): Agent safety CLI (`kouen-cli`), Attaching from a plain terminal, Bindings, Board and attention, Buffers (paste store), Composition, Errors and LSP, File navigation (+22 more)

### Community 122 - "ViEngine"
Cohesion: 0.08
Nodes (15): KouenCLITests, CLIInstallLocator, DetachKeys, absent, invalid, parsed, OptionalUUID, absent (+7 more)

### Community 123 - "Pipe"
Cohesion: 0.10
Nodes (14): ExternalOpenKind, filePreview, terminal, theme, InstallChoice, cancel, install, installAndApply (+6 more)

### Community 124 - "String"
Cohesion: 0.12
Nodes (4): .encode(text:modifiers:modes:), KittyKeyboardTests, String, UInt8

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, S (+2 more)

### Community 126 - ".path"
Cohesion: 0.08
Nodes (29): AgentArt, AgentMark, .body, AgentMarkShape, AgentVectorIcon, Scanner, .atEnd, SVGPath (+21 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.10
Nodes (23): AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), .stats, GlyphAtlasStats (+15 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.09
Nodes (20): Coordinator, DiffAnalysis, DiffFileItem, DiffFileStatus, added, .color, deleted, modified (+12 more)

### Community 129 - "SwiftUI"
Cohesion: 0.16
Nodes (6): FilePreviewCoordinator, FileTabID, NSView, Set, SplitDirection, String

### Community 131 - ".install"
Cohesion: 0.12
Nodes (16): Array, GroupHeaderRow, .body, RecipePanel, .canBecomeKey, RecipePickerController, RecipePickerFooter, .body (+8 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.18
Nodes (3): ContentAreaViewController, Bool, Notification

### Community 133 - ".load"
Cohesion: 0.06
Nodes (33): B3(), BDt(), Bpe(), cFe(), dFe(), displayable(), _Dt(), eFe() (+25 more)

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.19
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 135 - "CommandTarget"
Cohesion: 0.16
Nodes (5): GitPanelView, .isHidden, .removeWorktreeAction(path:), DispatchWorkItem, UnsafeMutableRawPointer

### Community 136 - ".startWatching"
Cohesion: 0.06
Nodes (40): CommandTarget, Command, .targetKind, PaneRef, bottom, byID, byIndex, last (+32 more)

### Community 137 - "ActivePaneService"
Cohesion: 0.12
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.06
Nodes (11): tab, .tab(for:), AgentScanner, Bool, DispatchSourceTimer, TimeInterval, Int32, SessionID (+3 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.17
Nodes (14): AgentIconRenderer, Scanner, .atEnd, SVGPathParser, Bool, CGFloat, CGPath, CGPoint (+6 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.20
Nodes (5): String, .trimmed, AgentTitleInference, Bool, .effectiveAgentKind

### Community 142 - "CopyModeGridSource"
Cohesion: 0.11
Nodes (3): Bool, String, UUID

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.09
Nodes (23): InputGate, .siblings, ReconnectLatch, .isTripped, SurfaceIO, .currentSubscription, Bool, CGFloat (+15 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.21
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 146 - "DecodedImage"
Cohesion: 0.15
Nodes (8): ContextResolutionEngine, Bool, String, Bool, String, TokenGuard, ContextResolutionEngineTests, String

### Community 147 - "FileTreeWatcher"
Cohesion: 0.20
Nodes (6): InlineFilePreview, NodeRow, .body, Context, Error, String

### Community 148 - "TriState"
Cohesion: 0.12
Nodes (12): AgentDetection, AgentDetector, MatchSource, ownProcess, wrapperLaunch, RawMatch, Date, Int32 (+4 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.28
Nodes (3): KouenDaemonToolsTests, String, URL

### Community 151 - ".evaluate"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.30
Nodes (9): .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release, `repeat`, KeyModifiers, Character, String (+1 more)

### Community 154 - "LiveResizeTests"
Cohesion: 0.15
Nodes (11): PickerItem, .groupLabel, historyBlock, .id, recipe, .searchableText, SurfaceID, RecipePickerModelMergeTests (+3 more)

### Community 155 - "Int"
Cohesion: 0.14
Nodes (11): FileFuzzyMatcher, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool, Character (+3 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.08
Nodes (25): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, .onSelect, NotificationDropdownPanelView (+17 more)

### Community 157 - "Added"
Cohesion: 0.18
Nodes (12): Notification.Name, NSCoder, NSObjectProtocol, NSRect, NSTextView, SyntaxLineNumberGutterView, .init(coder:), .init(frame:) (+4 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.21
Nodes (5): .init(url:paneID:webView:), SelectAllOnClickTextField, NSStackView, NSTextField, URL

### Community 159 - "MatchCategory"
Cohesion: 0.16
Nodes (12): ANSIPalette, CellColorResolver, MochaTheme, ResolvedCellColors, .init(hex:), .init(red:green:blue:alpha:), Bool, Double (+4 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.11
Nodes (21): FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose, FileTabPillView (+13 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.10
Nodes (17): DecodedWSFrame, PairingBox, .current, .isLockedOut, PendingPairing, Bool, Date, TimeInterval (+9 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.10
Nodes (17): NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent, NSImage (+9 more)

### Community 163 - "Workspace"
Cohesion: 0.27
Nodes (6): BinaryInstaller, .bundledMacOSDir, TimeInterval, BinaryInstallerVersionTests, String, URL

### Community 164 - "CommandPromptController"
Cohesion: 0.09
Nodes (23): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, IssueInfo (+15 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.28
Nodes (7): SSETransport, .isRunning, .listener, Bool, NWConnection, String, UInt16

### Community 166 - "LiveSession"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.12
Nodes (26): .resolvedGitStatus, fetchGitStatus(), ProjectCategory, ProjectCategorySection, .body, .c, .entries, ProjectDirectoryTreeModel (+18 more)

### Community 170 - "URLDetection"
Cohesion: 0.11
Nodes (7): Bool, Range, Set, String, URLDetection, StringProtocol, EngineConformanceTests

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.14
Nodes (15): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+7 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.14
Nodes (13): GridCompositor, Configuration, Int32, SessionGroup, SessionID, Tab, TabID, WorkspaceID (+5 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.11
Nodes (9): ISO8601DateFormatter, KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), SpawnedAgentSurface, Bool, PaneLeaf, String, Tab (+1 more)

### Community 175 - "RGBColorTests"
Cohesion: 0.20
Nodes (10): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, Bool (+2 more)

### Community 176 - "Added"
Cohesion: 0.05
Nodes (46): a0n(), abt(), bX(), c6e(), c6n(), d0(), dgn(), dl() (+38 more)

### Community 177 - ".rects"
Cohesion: 0.18
Nodes (3): CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 178 - "InlineAICompletionView"
Cohesion: 0.22
Nodes (10): CopyModeGridSource, .promptRows, ClosedRange, CopyModeReducer, Bool, Character, NSRegularExpression, Range (+2 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.14
Nodes (17): PaneBorderStatus, bottom, off, top, PaneLeaf, PaneNode, branch, leaf (+9 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.20
Nodes (5): .snapshot, Bool, String, ThemeService, KouenOptions

### Community 181 - "GridCompositorTests"
Cohesion: 0.18
Nodes (5): CompositorPane, GridCompositorTests, Bool, String, TerminalGridSnapshot

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.22
Nodes (9): FormatContext, FormatString, FormatStyle, Bool, Character, Date, FormatColor, String (+1 more)

### Community 183 - "LSPServerRegistry"
Cohesion: 0.08
Nodes (6): CodepointRunFastPathTests, .assertAllPathsAgree(_:cols:rows:file:line:), StaticString, String, UInt, UInt8

### Community 184 - "targets"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Kouen, Sparkle (+13 more)

### Community 185 - "SessionSnapshot"
Cohesion: 0.13
Nodes (3): KouenGridTerminalTests, String, TerminalGridSnapshot

### Community 187 - "AppDelegate"
Cohesion: 0.18
Nodes (10): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+2 more)

### Community 188 - "BrowserPaneView"
Cohesion: 0.12
Nodes (19): Motion, .entrance, .spring, .standardEase, CAMediaTimingFunction, NSWindowController, KouenOnboarding, Bool (+11 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.06
Nodes (43): Codable, BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserRequestPayload, close, cookies (+35 more)

### Community 190 - "user-stories.md"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.08
Nodes (15): PluginLoader, String, ScriptAPI, ScriptError, .errorDescription, evaluationError, unsupportedPlatform, ScriptRuntime (+7 more)

### Community 192 - "GlyphRasterizer"
Cohesion: 0.10
Nodes (21): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+13 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.16
Nodes (12): UInt16, TTYSize, RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal (+4 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.16
Nodes (14): FileNode, GitStatusType, added, deleted, modified, renamed, unmodified, untracked (+6 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.11
Nodes (17): 1.1 Architecture, 1.2 Algorithm review, 1.3 Structure findings, 2.1 Structure, 2.2 Risk register (ranked), 3.1 Current implementation, 3.2 Why nothing shows (ranked root-cause candidates), 3.3 Fix plan (+9 more)

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.07
Nodes (26): Selector, .init(coder:), .init(frame:), .init(coder:), Kind, primary, secondary, .init(coder:) (+18 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.10
Nodes (13): ChromeBackdrop, .init(role:), KouenDesign, KouenOverlayBackground, RuntimeGlassEffectView, Bool, CGRect, NSColor (+5 more)

### Community 198 - ".classify"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.26
Nodes (8): InstallResult, Shell, bash, fish, zsh, ShellIntegration, Bool, URL

### Community 202 - "PaletteModel"
Cohesion: 0.09
Nodes (14): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+6 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.08
Nodes (11): Any, CGFloat, NSEvent, NSMenu, CGFloat, CGRect, NSEvent, NSPoint (+3 more)

### Community 204 - "From tmux"
Cohesion: 0.25
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 205 - "CopyModeState"
Cohesion: 0.12
Nodes (13): AppKit, NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void (+5 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.11
Nodes (11): FlippedView, .isFlipped, .removeWorktreeAction(_:), NSButton, NSColor, NSRect, NSScrollView, NSStackView (+3 more)

### Community 207 - "scheduleRender"
Cohesion: 0.18
Nodes (7): CheckpointInfo, CheckpointManager, Bool, Date, String, CheckpointManagerTests, String

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.14
Nodes (13): .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:), .isHovered, Bool, NSCoder (+5 more)

### Community 209 - "SettingsRemoteView"
Cohesion: 0.11
Nodes (17): Notification.Name, os, Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow (+9 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.22
Nodes (3): CompletionGenerator, String, CompletionGeneratorTests

### Community 211 - "PaneTarget"
Cohesion: 0.28
Nodes (7): Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 212 - ".translate"
Cohesion: 0.09
Nodes (10): String, TabID, WorkspaceID, CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab (+2 more)

### Community 213 - "String"
Cohesion: 0.15
Nodes (8): EnvironmentStore, Persisted, String, URL, global, URL, EnvironmentStoreTests, URL

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.09
Nodes (24): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+16 more)

### Community 215 - ".lines"
Cohesion: 0.14
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 216 - "CellColorResolverTests"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.05
Nodes (27): CornerInfo, EditorDividerView, KouenSplitView, .dividerColor, .dividerThickness, .init(coder:), PaneDragGripView, .init(coder:) (+19 more)

### Community 220 - "Section"
Cohesion: 0.17
Nodes (11): NotchGeometry, .fallback, NSScreen, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics (+3 more)

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.11
Nodes (22): keys, ITerm2InlineImage, .heightArg, .preserveAspectRatio, .widthArg, Bool, String, UInt8 (+14 more)

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.23
Nodes (9): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor, NSView, .body (+1 more)

### Community 224 - "CellColorResolver"
Cohesion: 0.12
Nodes (12): ANSIPalette, RGBColor, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors, Bool, Double (+4 more)

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.18
Nodes (11): JSONRPCMessage, notification, request, response, StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength (+3 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.18
Nodes (16): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, PaneLeaf, PaneNode (+8 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.12
Nodes (10): Bool, DispatchWorkItem, NSEvent, NSPopover, NSRange, NSString, Void, SyntaxTextView (+2 more)

### Community 228 - "sessionRow"
Cohesion: 0.09
Nodes (11): KeybindingsService, Bool, Command, String, KeybindingsStore, .fileURL, URL, KeybindingsStoreTests (+3 more)

### Community 229 - ".decide"
Cohesion: 0.21
Nodes (6): .selectedHost, MutationResult, RemoteHost, RemoteHostStore, Bool, String

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.27
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 231 - "ExternalOpenKind"
Cohesion: 0.17
Nodes (21): Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors, ContrastGrade (+13 more)

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.16
Nodes (7): BoardViewController, FlippedView, .isFlipped, Bool, Set, TabID, BoardViewControllerTests

### Community 234 - ".scan"
Cohesion: 0.10
Nodes (6): Float, Set, SurfaceID, Void, TerminalPaneRegistry, NSWindow

### Community 235 - "WorkbenchCommand"
Cohesion: 0.10
Nodes (17): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+9 more)

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.13
Nodes (11): Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint, NSRect, WindowTitleStripView (+3 more)

### Community 238 - ".make"
Cohesion: 0.15
Nodes (8): BoxDrawing, Bool, CGContext, CGFloat, PaneRectSolverTests, Bool, PaneNode, PaneRect

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.16
Nodes (34): aQ(), bqt(), cbe(), DD(), dqt(), Dr(), Eqt(), Fa() (+26 more)

### Community 240 - "PaneBorderStatus"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 242 - "AgentBridge"
Cohesion: 0.13
Nodes (6): agentWaitChannel(), HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 243 - ".make"
Cohesion: 0.17
Nodes (24): CryptoKit, Encodable, ExpressibleByStringLiteral, Network, AISuggestionAck, AttachedAck, BrowserFramePush, BrowserSnapshotAck (+16 more)

### Community 244 - "FileNode"
Cohesion: 0.11
Nodes (19): AgentSessionHistoryModel, .hasMoreToLoad, .minimumWindowStart, .searchQuery, .selectedScope, .windowedRecords, AgentSessionHistoryView, .body (+11 more)

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.08
Nodes (56): Ame(), aQt(), aXt(), Cqt(), CUe(), cXt(), DYt(), een() (+48 more)

### Community 247 - ".renderFixture"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.22
Nodes (5): GitResult, Bool, String, ValidateOutcome, GitPanelViewToastErrorSummaryTests

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.16
Nodes (9): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+1 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.16
Nodes (9): Range, String, TerminalGridCell, TerminalBufferMatch, TerminalBufferSearch, TerminalGridCell, String, TerminalGridCell (+1 more)

### Community 251 - "SessionCoordinator"
Cohesion: 0.13
Nodes (14): OverlayBackground, Context, OverlayBackground, Context, AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:) (+6 more)

### Community 252 - "NSViewRepresentable"
Cohesion: 0.29
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 253 - "Split Right"
Cohesion: 0.11
Nodes (12): .init(frame:), NSRect, LSPFileSession, Never, String, Task, URL, Void (+4 more)

### Community 254 - "BoardViewController"
Cohesion: 0.08
Nodes (16): DisplayWidth, String, Unicode, ReleaseNotes, Section, String, Run, String (+8 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.10
Nodes (10): BrowserPaneView, DesignModeElementInfo, DesignModePopoverViewController, .init(title:properties:styles:onStyleChanged:onCopyCSS:onPromptAgent:), Any, NSPopover, String, TimeInterval (+2 more)

### Community 256 - "GitMetadataProvider"
Cohesion: 0.11
Nodes (16): InlineAICompletionController, KouenSettings, String, InlineAICompletionView, .init(coder:), .init(frame:), .suggestion, Bool (+8 more)

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.18
Nodes (20): CoreImage, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription, .surfaceID, detectHost() (+12 more)

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.10
Nodes (13): OptionSet, KeySpec, .description, .init(from:), .init(key:modifiers:), Modifiers, Decoder, String (+5 more)

### Community 260 - ".welcome"
Cohesion: 0.16
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 262 - ".install"
Cohesion: 0.22
Nodes (5): AgentRoutingResolver, String, AgentRoutingRule, AgentRoutingResolverTests, Result

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.19
Nodes (11): DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String, StyledSegment (+3 more)

### Community 266 - ".path"
Cohesion: 0.22
Nodes (6): ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 267 - ".performInstall"
Cohesion: 0.11
Nodes (19): Context, Non-goals, P8: macOS 27 Golden Gate Adoption, Phase 10 — WidgetKit & Desktop Status Panel (P2), Phase 11 — Metal Frame Pacing & DisplayLink Optimization (P2), Phase 12 — Terminal Accessibility Tree (P2), Phase 1 — Compatibility (P0), Phase 2 — Quick Wins (P1) (+11 more)

### Community 268 - "code:bash (# Old (agent-specific):)"
Cohesion: 0.08
Nodes (26): aie(), arc(), b2e(), bezierCurveTo(), closePath(), cRe(), cZ(), E7() (+18 more)

### Community 270 - "WindowSession"
Cohesion: 0.12
Nodes (7): PaneBorderStatus, Bool, Command, DispatchWorkItem, PaneRect, String, WindowSession

### Community 271 - "StatusLineView.swift"
Cohesion: 0.30
Nodes (8): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, PaletteFooter, .body

### Community 272 - "SGRMouseEvent"
Cohesion: 0.16
Nodes (13): Command Prompt, Find In Files, Git Panel, New Tab, Next Session, Open Command Palette, Previous Session, Cmd T Creates New Session (+5 more)

### Community 273 - "KeySpec"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.15
Nodes (8): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ActivityAssertionManagerTests

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.20
Nodes (9): .groupedRecords, Group, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, CGFloat, NSTextField, NSView (+1 more)

### Community 277 - ".run"
Cohesion: 0.08
Nodes (26): CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display, found, .isReady (+18 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.15
Nodes (5): CommandPaletteController, PaletteCommandConfig, PaletteFileEntry, String, TimeInterval

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 280 - ".menu"
Cohesion: 0.21
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.16
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 284 - "click_ui_element"
Cohesion: 0.12
Nodes (9): .lspPosition(characterOffset:), .lspPosition(for:), LSPPosition, LSPTextLocation, .position, LSPTextLocationParser, String, URL (+1 more)

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.11
Nodes (13): bme(), bYt(), fqt(), hVe(), Iin(), jun(), qme(), qrn (+5 more)

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.16
Nodes (8): MarkdownPreviewView, Any, Bool, Error, String, URL, Void, MarkdownPreviewTests

### Community 287 - ".apply"
Cohesion: 0.36
Nodes (6): InstallResult, ShellCompletionInstaller, .fishCompletionSource, Bool, String, URL

### Community 288 - "AgentHookStrategy"
Cohesion: 0.22
Nodes (9): DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSView, NSViewCornerConfiguration, SurfaceID (+1 more)

### Community 290 - "Process"
Cohesion: 0.13
Nodes (8): PaneID, SurfaceID, Tab, UUID, BrowserPaneReuseScopeTests, PaneNode, Tab, TabID

### Community 291 - "JSONDecoder"
Cohesion: 0.20
Nodes (3): String, TerminalGridSnapshot, VTConformanceCorpusTests

### Community 292 - "Release runbook"
Cohesion: 0.25
Nodes (7): Full local signing path (needs a Developer ID cert; not currently used), Full pipeline reference (not implemented in this fork), How this fork actually releases, If the workflow existed: running a release, One-time GitHub setup, Release runbook, What that workflow would publish

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.11
Nodes (13): CodingKeys, error, id, jsonrpc, method, params, JSONRPCId, int (+5 more)

### Community 294 - "GitHubCLIClient"
Cohesion: 0.24
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 295 - "AgentApprovalBar"
Cohesion: 0.11
Nodes (10): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, KouenApp, KouenSyntaxResources (+2 more)

### Community 296 - "NotificationBus"
Cohesion: 0.12
Nodes (10): String, UInt64, ANSIPalette, UInt8, .color(_:), .renderColor(_:), CellOverlayTests, IndexSet (+2 more)

### Community 297 - "settings.json"
Cohesion: 0.17
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, Bool, Double (+3 more)

### Community 298 - "jobs"
Cohesion: 0.18
Nodes (4): BoardCommandTests, BoardModelTests, Tab, String

### Community 299 - "PaneNode"
Cohesion: 0.07
Nodes (32): CGFloat, FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView (+24 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.25
Nodes (6): .snapshotPayload, NotificationBus, .postSnapshotChanged(_:), SnapshotChangedPayload, Bool, String

### Community 301 - ".parse"
Cohesion: 0.11
Nodes (12): ParsedShortcut, .displayString, PrefixKeymap, Any, Bool, NSEvent, String, TimeInterval (+4 more)

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.16
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 303 - ".encodeMouse"
Cohesion: 0.14
Nodes (5): AgentCommandTests, String, Tab, String, Tab

### Community 304 - "00-inception-plan.md"
Cohesion: 0.22
Nodes (4): String, URL, UUID, WorktreeIsolationDaemonTests

### Community 305 - ".script"
Cohesion: 0.23
Nodes (7): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow, NSHostingController

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 307 - "ViPathTokenTests"
Cohesion: 0.09
Nodes (20): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+12 more)

### Community 310 - "FrameSignposter"
Cohesion: 0.11
Nodes (14): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+6 more)

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.18
Nodes (6): DefaultTerminalLaunchRequest, ShellQuoting, Bool, String, URL, DefaultTerminalLaunchRequestTests

### Community 312 - "AgentSnapshot"
Cohesion: 0.18
Nodes (14): Array, Bool, Date, Decoder, PaneID, PaneNode, String, TabID (+6 more)

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.08
Nodes (27): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary, RowKind (+19 more)

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.09
Nodes (17): requestFailed, FileHandle, LSPMessage, notification, request, response, Decoder, Encoder (+9 more)

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.08
Nodes (13): URL, String, String, String, Set, KouenFilePreviewLoader, KouenViewError, binaryOrUnsupportedEncoding (+5 more)

### Community 319 - "FormatColor"
Cohesion: 0.15
Nodes (9): Bool, Int32, String, URL, SystemdUserInstaller, .backendName, .isInstalled, .unitURL (+1 more)

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.26
Nodes (14): Agent Command Does Not Crash, Agent Waiting Filter Does Not Crash, Board Command Shows Board Panel, Cd Command Switches To Matching Tab, Copy Path Command Does Not Crash, Errors Command Does Not Crash, Find Command Opens Command Palette On Empty Query, Find Command Resolves Unique File (+6 more)

### Community 321 - "UInt64"
Cohesion: 0.11
Nodes (17): AYt(), Cme(), e7e(), EUe(), eYt(), hxn(), IUe(), j9n() (+9 more)

### Community 322 - "DesktopNotifier"
Cohesion: 0.13
Nodes (17): FormatContextBuilder, DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:) (+9 more)

### Community 323 - "LayoutNode"
Cohesion: 0.10
Nodes (17): NSWindow, Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent, NSPoint (+9 more)

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.19
Nodes (5): TerminalGridCell, NSMenuItem, String, TerminalGridCell, String

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.33
Nodes (3): TaskStore, URL, TaskStoreTests

### Community 327 - ".theme"
Cohesion: 0.40
Nodes (5): PaneOutputWaiter, PaneOutputWaitResult, CheckedContinuation, Never, UInt64

### Community 328 - "README.md"
Cohesion: 0.12
Nodes (14): .init(coder:), BrowserProgressLine, .init(coder:), .init(frame:), BrowserTabButton, .init(coder:), .init(title:isActive:onSelect:onClose:), .init(coder:) (+6 more)

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 330 - ".drawGlyph"
Cohesion: 0.18
Nodes (15): CellMetrics, ComposedFrame, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth (+7 more)

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.16
Nodes (10): NSView, NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView (+2 more)

### Community 332 - "Added"
Cohesion: 0.15
Nodes (14): OpaquePointer, AgentHistoryScanner, .home, AgentHistoryTurn, AgentSessionRecord, FileCacheEntry, Bool, Date (+6 more)

### Community 333 - "RealPty"
Cohesion: 0.18
Nodes (8): ClaudeRunSummary, Date, Double, Int32, String, UUID, String, UUID

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.18
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 335 - ".makeModel"
Cohesion: 0.18
Nodes (13): FeaturePhase, architect, completed, dev, interview, qaDesign, qaVerify, .title (+5 more)

### Community 336 - "run.sh"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 337 - "CommandExecutionError"
Cohesion: 0.26
Nodes (6): SwarmFleetSnapshotWire, SwarmTaskNodeWire, Date, Double, String, UUID

### Community 338 - "CSIParams"
Cohesion: 0.19
Nodes (8): AgentRemoteControlDaemonService, Set, String, Void, AgentRemoteControlDaemonServiceTests, LogBox, .count, String

### Community 339 - "Foundation"
Cohesion: 0.17
Nodes (13): KouenCopyMode, KouenTerminalEngine, KouenTerminalRenderer, KouenTheme, Metal, .currentRawSelection, RawSelection, Bool (+5 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.15
Nodes (8): JSONOutputFormatter, Bool, String, T, OptionEntry, WorkspaceSummary, JSONOutputFormatterTests, T

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.25
Nodes (8): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String

### Community 342 - "Added"
Cohesion: 0.30
Nodes (7): Bool, NSPasteboard, NSString, String, URL, TerminalServicesProvider, AutoreleasingUnsafeMutablePointer

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.07
Nodes (23): Tab, BrowserIntegrationController, NSView, PaneID, HitTestPassthroughView, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), .init(paneID:) (+15 more)

### Community 344 - "FileViewerViewController"
Cohesion: 0.12
Nodes (12): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+4 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.09
Nodes (12): BellScanTests, Bool, UInt8, IPCCodecInvariantTests, GroupedSessionDaemonTests, SessionGroup, String, URL (+4 more)

### Community 349 - "Contents.json"
Cohesion: 0.13
Nodes (6): ScreenPos, bottom, middle, top, KouenLSP, QuickLookUI

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.19
Nodes (4): URL, MobileBridgeAttachFileTests, String, URL

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.19
Nodes (9): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.31
Nodes (6): Bool, Counter, Scheduled, SurfaceProgressTrackerTests, DispatchWorkItem, TimeInterval

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.15
Nodes (5): AgentTableEntry, Bool, Set, String, AgentDetectorTests

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.21
Nodes (8): DaemonMetrics, Snapshot, .meanLockWaitMicros, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 355 - ".deepMerge"
Cohesion: 0.16
Nodes (17): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+9 more)

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.17
Nodes (4): InputEncoder, InputEncoderTests, String, UInt8

### Community 357 - ".handleCat"
Cohesion: 0.37
Nodes (3): .block(atPromptLine:), String, TerminalBlockStoreTests

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.20
Nodes (9): BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool, CGFloat, NSCoder, NSPoint (+1 more)

### Community 359 - "OcclusionTests"
Cohesion: 0.27
Nodes (6): ClaudeCloudSessionStore, Entry, Date, String, TimeInterval, URL

### Community 360 - "State"
Cohesion: 0.03
Nodes (81): _4e(), a4e(), bhn(), c_n(), cct(), cvn(), cxn(), dV() (+73 more)

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.14
Nodes (12): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, AutomationScheduler (+4 more)

### Community 362 - "RGBColor"
Cohesion: 0.09
Nodes (12): HintModeOverlay, Any, NSEvent, NSView, String, KouenTerminalKit, KouenTerminalSurfaceFocusTests, SpecialKeyMappingTests (+4 more)

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.29
Nodes (5): bUt(), Gbe(), handler(), mUt(), _Q()

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.15
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.20
Nodes (3): PipeBuffer, Result, MobileBridgeAISuggestTests

### Community 366 - "Consumers"
Cohesion: 0.13
Nodes (15): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+7 more)

### Community 367 - "DaemonStats"
Cohesion: 0.16
Nodes (9): FileGraphInfo, GraphifyLSPBridge, Double, String, URL, GraphifyLSPBridgeTests, Any, String (+1 more)

### Community 368 - "Tab"
Cohesion: 0.15
Nodes (3): CellColorResolverTests, .resolver, CellColorResolver

### Community 369 - "Git Panel"
Cohesion: 0.26
Nodes (5): String, TextGrid, .totalLines, .viewportRows, WordColumnRangeTests

### Community 370 - ".encode"
Cohesion: 0.19
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.19
Nodes (10): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+2 more)

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.11
Nodes (18): .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:), .init(frame:) (+10 more)

### Community 373 - "Prompt"
Cohesion: 0.19
Nodes (3): fQ, hqe(), M9()

### Community 374 - ".run"
Cohesion: 0.19
Nodes (6): KouenCore, KouenDaemonCore, RawSocketError, connectFailed, writeFailed, XCTest

### Community 375 - ".install"
Cohesion: 0.24
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 376 - "ScrollReuseTests"
Cohesion: 0.09
Nodes (19): CoreGraphics, CoreText, ImageIO, ImageDecoder, Kind, arms, dashH, dashV (+11 more)

### Community 377 - "Identifiable"
Cohesion: 0.10
Nodes (12): ScriptConfigLocator, Bool, String, ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval (+4 more)

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 379 - "MCPServer"
Cohesion: 0.20
Nodes (10): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+2 more)

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.16
Nodes (10): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+2 more)

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.09
Nodes (22): CompleteStepView, Void, DiscoverStepView, .body, Point, String, OnboardingStep, complete (+14 more)

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.09
Nodes (19): .webView(_:didCommit:), BrowserPaneViewTests, MockWebView, .isLoading, .url, Any, Bool, CGFloat (+11 more)

### Community 387 - "User Profile"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 388 - "Darwin"
Cohesion: 0.06
Nodes (38): item, IssueKeychainStore, Bool, String, IssuePriority, .color, high, low (+30 more)

### Community 389 - "HarnessCLITests"
Cohesion: 0.27
Nodes (7): SwarmFleetBody, .body, SwarmNodeRowView, .body, .statusColor, Duration, Void

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.21
Nodes (7): BrowserPaneRegistry, .init(url:paneID:), NSWindow, PaneID, WeakBrowserPaneView, WeakScriptMessageHandler, WKScriptMessageHandler

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.19
Nodes (12): CLI Isolate Creates Worktree And Session, CLI Isolate With Custom Branch Name, Close Session Keeps Dirty Worktree, Close Session Removes Clean Worktree, Create Isolated Session And Select, Git Checkout In Normal Session Does Not Affect Isolated, Isolate Without Branch Uses Detached HEAD, Run CLI (+4 more)

### Community 402 - "View"
Cohesion: 0.10
Nodes (30): ButtonStyle, CommandRow, .body, GlassCard, .body, GlassPrimaryButtonStyle, GlassSecondaryButtonStyle, GlassSmallButtonStyle (+22 more)

### Community 403 - "PresentAttempt"
Cohesion: 0.31
Nodes (4): CSIParams, .count, TerminalGridColor, UInt8

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.09
Nodes (23): a6e(), aoe(), bI(), bR(), Cf(), f9e(), Gg(), gPt() (+15 more)

### Community 405 - "AgentIconRenderer"
Cohesion: 0.08
Nodes (26): Endpoint, EndpointError, connectionFailed, .description, notYetSupported, pathTooLong, String, EndpointConnector (+18 more)

### Community 407 - "Fixed"
Cohesion: 0.09
Nodes (20): ProjectTask, ProjectTaskDetector, String, .body, .mcpButton, json, ConfigError, .errorDescription (+12 more)

### Community 408 - "IPC Architecture"
Cohesion: 0.12
Nodes (6): SessionID, GroupedSessionTests, SessionGroup, Set, SurfaceID, Phase67Tests

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.27
Nodes (3): TerminalModes, Bool, .appCursor

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.13
Nodes (13): BinaryInstaller.DetectionStatus, SetupStepView, .canInstall, .hooksDetail, .hooksTone, .hooksValue, .isSuccess, .notifTone (+5 more)

### Community 412 - "go.json"
Cohesion: 0.15
Nodes (6): aD(), ezt(), GGe, Hzt(), Kp(), urn

### Community 414 - "json.json"
Cohesion: 0.15
Nodes (14): a9e(), Am(), avn(), c0t(), Cm(), Hm(), Im(), lte() (+6 more)

### Community 415 - "markdown.json"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.19
Nodes (15): BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, Keybinding, .displayKey, MenuModifiers (+7 more)

### Community 417 - "rust.json"
Cohesion: 0.18
Nodes (5): DiffLineType, added, deleted, modified, SyntaxTextViewDirtyStateTests

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.23
Nodes (5): ListeningPortScanner, Int32, Set, String, ListeningPortScannerTests

### Community 419 - "typescript.json"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 420 - "yaml.json"
Cohesion: 0.16
Nodes (3): NWEndpoint, NWListener, UInt16

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.06
Nodes (26): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+18 more)

### Community 422 - "HintModeOverlay"
Cohesion: 0.08
Nodes (13): SessionGroup, String, KouenSidebarPanelViewController, NSMenuItem, NSView, SessionGroup, String, NSMenu (+5 more)

### Community 423 - "SixelDecoder"
Cohesion: 0.11
Nodes (20): .filteredJobs, .filteredRecords, MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens (+12 more)

### Community 424 - ".parseDiffHunks"
Cohesion: 0.37
Nodes (4): KouenFeatureMarkdownSync, Bool, String, URL

### Community 425 - "AgentVectorIcon"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.29
Nodes (6): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Carbon

### Community 427 - ".delay"
Cohesion: 0.06
Nodes (33): JSONDecoder, JSONEncoder, CodingKeys, cols, createdAt, dataBase64, rows, timeMs (+25 more)

### Community 428 - "TaskDashboardView"
Cohesion: 0.12
Nodes (10): MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, String, SurfaceID (+2 more)

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.27
Nodes (5): SplitDirection, TabID, .body, .dragGesture, TerminalTabBarDelegate

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.15
Nodes (14): Ac(), cae(), cAn(), cht(), e2n(), e3n(), e5n(), fb() (+6 more)

### Community 431 - "BoardCardView"
Cohesion: 0.13
Nodes (21): .color, TaskSummary.Status, .columnKind, BoardCard, BoardColumn, .name, BoardColumnKind, .displayName (+13 more)

### Community 432 - "PathToken"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.22
Nodes (11): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, agents, AgentBadgeView, .body (+3 more)

### Community 434 - "Project History"
Cohesion: 0.38
Nodes (4): AnyObject, TimeInterval, ZombieHoldRegistry, ObjectIdentifier

### Community 435 - ".init"
Cohesion: 0.30
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 436 - "WaitForRegistry"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: animateSidebar setContentLeadingInset MainSplitViewController, Source Nodes

### Community 437 - "PickerItemRow"
Cohesion: 0.15
Nodes (9): _7(), A7(), a8(), bGt(), c8(), ene(), Gnn, IC() (+1 more)

### Community 438 - "SessionEditor"
Cohesion: 0.10
Nodes (15): .selectWorkspace(byIndex:), ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy, SessionLifecycleService (+7 more)

### Community 439 - "SetupStepView"
Cohesion: 0.16
Nodes (8): brn, grn, hrn(), JGe(), KGe(), prn(), qGe(), zGe()

### Community 440 - "LegacySnapshot"
Cohesion: 0.17
Nodes (5): DirectionalAxis, down, left, right, up

### Community 441 - "RemoteHostStore"
Cohesion: 0.24
Nodes (3): TabID, WorkspaceID, GitPanelViewWorktreeNavigationTests

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.24
Nodes (9): Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock, .block(id:) (+1 more)

### Community 443 - "main.swift"
Cohesion: 0.07
Nodes (37): Equatable, ImagePlacementSnapshot, SemanticMark, Bool, String, UInt8, TerminalCellWidth, normal (+29 more)

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 445 - "Section"
Cohesion: 0.22
Nodes (7): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, NSCoder, Void

### Community 446 - "Modifiers"
Cohesion: 0.20
Nodes (6): LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.18
Nodes (10): Bug 1 - Rotation Grace Slot Keeps The Previous Token Redeemable, Bug 1 - Rotation Shifts The Outgoing Token Into The Grace Slot, Bug 1 - Stop Fully Clears The Grace Slot, Bug 1 - Token Lifetime Not Regressed Below The Human-Flow Window, Bug 2 - Client onerror Does Not Clobber The Server Error Banner, Bug 2 - No Abrupt Cancel Immediately After The Error Text, Bug 2 - Reject Path Closes Gracefully With Policy-Violation Code 1008, Bug 3 - QR Not Printed When No Listener Is Ready (+2 more)

### Community 449 - "PresentAttempt"
Cohesion: 0.27
Nodes (7): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.23
Nodes (6): Divergence, Bool, String, TimeInterval, WorktreeInfo, WorktreeManager

### Community 451 - ".run"
Cohesion: 0.15
Nodes (12): .init(coder:), NSCoder, NSHostingView, NSLayoutConstraint, Tab, TerminalTabBarView, .delegate, .init(coder:) (+4 more)

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.11
Nodes (17): BranchSwitchHelper, FileTreeNode, FileTreeSwiftUIView, .body, .filteredNodes, .rootPath, .scanOptions, .sessionID (+9 more)

### Community 454 - ".recordReapedGenerationForTesting"
Cohesion: 0.04
Nodes (73): AgentRow, .agentColor, .executables, .hookButton, HookState, failed, idle, installed (+65 more)

### Community 455 - "ComposerPanel"
Cohesion: 0.14
Nodes (13): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+5 more)

### Community 456 - "TerminalModes"
Cohesion: 0.24
Nodes (9): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+1 more)

### Community 457 - ".normalizedKey"
Cohesion: 0.13
Nodes (13): AnimatablePair, NotchMaskAnimator, Bool, CGFloat, CGRect, NSView, NotchShape, .animatableData (+5 more)

### Community 458 - ".deletePersistedScrollback"
Cohesion: 0.33
Nodes (3): DataBox, GitPanelViewDiffErrorTests, String

### Community 459 - ".encode"
Cohesion: 0.24
Nodes (8): PickerItemRow, .badgeText, .body, .iconName, .subtitle, .titleText, AttributedString, NSColor

### Community 460 - "RunState"
Cohesion: 0.24
Nodes (3): RemoteHostStoreTests, String, URL

### Community 461 - ".worktreeList"
Cohesion: 0.22
Nodes (8): MCP Control Allowed With Env Var, MCP Control Denied Without Env Var, MCP KouenBoard Returns Columns, MCP KouenList Returns Sessions, MCP ReadPaneOutput Returns Content, Run MCP Request, Run MCP Request Allowed, Run MCP Request Denied

### Community 462 - "AGENTS.md"
Cohesion: 0.22
Nodes (8): Browser Pane Open Close Rapid, File Preview Open Close, Git Fetch Shows Toast, Launch Kouen Staging, Memory Stability After 30 Seconds, Quit Kouen Staging, Sidebar Toggle Immediately After Launch, Tab Close While Mouse Moving

### Community 463 - ".deinit"
Cohesion: 0.08
Nodes (19): .agentInfo(forWorktreePath:), .agentInfo(forWorktreePath:tabs:), Tab, Reason, errored, finished, needsInput, RowState (+11 more)

### Community 464 - "MouseButton"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 465 - "DirectionalAxis"
Cohesion: 0.36
Nodes (5): PaneLeaf, SessionGroup, Any, String, Tab

### Community 466 - "ReflowFastPathTests"
Cohesion: 0.20
Nodes (6): Bool, NSObjectProtocol, String, Tab, TabID, WorktreeAutoIsolateService

### Community 467 - ".moveSelection"
Cohesion: 0.39
Nodes (4): SettingsAdvancedView, .body, Bool, String

### Community 468 - "Never"
Cohesion: 0.18
Nodes (7): HeadlessCLIAdapter, HeadlessRunEvent, assistantText, result, Bool, Double, String

### Community 469 - "PresentAttempt"
Cohesion: 0.17
Nodes (10): .init(frame:), .webView(_:decidePolicyFor:decisionHandler:), .webView(_:didFinish:), MainActor, NSRect, WKNavigation, WKNavigationAction, WKWebView (+2 more)

### Community 470 - "DispatchTime"
Cohesion: 0.41
Nodes (7): FeatureSummary, FeatureTaskSummary, GateSummary, Bool, Date, String, UUID

### Community 471 - ".evaluateStyled"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 473 - "HarnessOnboarding"
Cohesion: 0.14
Nodes (9): GridCompositorParityTests, LiveCompositorFixture, Bool, String, TerminalGridSnapshot, PortCompositorFixture, Bool, String (+1 more)

### Community 474 - "String"
Cohesion: 0.29
Nodes (7): Toggle Sidebar, Sidebar Toggle Works, Board CLI Shows Columns, Board CLI Shows Running After Long Command, Board Columns Visible After Click, Board Tab Accessible In Sidebar, Split Pane And Resize

### Community 475 - ".hitTest"
Cohesion: 0.31
Nodes (8): .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didStartProvisionalNavigation:), LoadCompletionState, CheckedContinuation, Error, Void, WKNavigation

### Community 476 - ".steps"
Cohesion: 0.31
Nodes (7): DotView, .init(frame:), Bool, Context, NSColor, NSRect, WorkingDotView

### Community 477 - ".endFind"
Cohesion: 0.27
Nodes (8): LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab, TabID, WorkspaceID

### Community 478 - ".install"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 479 - "ScrollbackTests"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 480 - "Command Prompt Architecture"
Cohesion: 0.15
Nodes (12): MouseButton, left, middle, right, wheelDown, wheelLeft, wheelRight, wheelUp (+4 more)

### Community 481 - ".testKouenRendererFixtureDefaultTextReportsPlausibleGlyphStats"
Cohesion: 0.09
Nodes (25): CustomStringConvertible, DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed, atomicWrite() (+17 more)

### Community 483 - "Changed"
Cohesion: 0.25
Nodes (3): FlushSessionStateTests, String, URL

### Community 485 - ".testKouenRendererFixtureLigatureShapingPathReportsPlausibleGlyphs"
Cohesion: 0.38
Nodes (6): Cleanup And Quit, Create Config File, No Config File Starts Normally, Script Hot Reload On Save, Script Loads On Startup, Script Syntax Error Does Not Crash

### Community 486 - "TabPillView"
Cohesion: 0.29
Nodes (6): Bug 1 - Browser Pane Deferred Unregister, Bug 1 - Browser Pane Reuse On Rebuild, Bug 2 - New Session Syncs Before Reading Active Tab, Bug 2 - Tab Bar New Tab Also Syncs, Bug 3 - Browser Pane Forces Redraw On Reattach, Build Compiles Successfully

### Community 488 - "ccRunCancel"
Cohesion: 0.20
Nodes (9): Date, Never, Task, Void, TabPillView, .pillBackground, .pillBorder, .workingDot (+1 more)

### Community 490 - "ccRunGet"
Cohesion: 0.25
Nodes (4): StatusLineWidthTests, StatusLineWidth, String, StyledSegment

### Community 491 - "Added"
Cohesion: 0.18
Nodes (4): ClaudeSessionMode, ClaudeSessionModeTests, URL, Void

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 493 - "ccRunStart"
Cohesion: 0.15
Nodes (4): KouenCLI, MemoCommandTests, URL, TaskCommandTests

### Community 494 - "ccRunInfo"
Cohesion: 0.33
Nodes (5): Kouen LSP Diagnostics Does Not Crash, Kouen LSP Hover Returns Result, Kouen LSP Start Returns JSON, Kouen View Binary Shows Guard Message, Kouen View Prints File Content

### Community 495 - "ccRuns"
Cohesion: 0.29
Nodes (8): SessionID, String, Void, TaskDashboardBody, .body, .init(onJumpToSession:), TaskRowView, .body

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.22
Nodes (9): SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, Int32, String (+1 more)

### Community 498 - ".automationList"
Cohesion: 0.13
Nodes (16): AgentLaunchCommands, AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand, Bool (+8 more)

### Community 499 - ".routingRuleList"
Cohesion: 0.22
Nodes (10): en(), gk(), GOt(), jUe(), kr(), Mme(), n6(), YC() (+2 more)

### Community 500 - ".json"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 501 - "Fixed"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 502 - "ACP Client (Shelved)"
Cohesion: 0.22
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 503 - "Build Scripts Self-Kill Protection"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 504 - "WindowBorderOverlayView"
Cohesion: 0.19
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 506 - "SwarmFleetBody"
Cohesion: 0.33
Nodes (6): AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.40
Nodes (4): Leak A - Retiring A Host Drops Its AI Controllers, Leak B - Browser Network Capture Is Bounded, Leak C - Every Per-Surface Dict In Coordinator Has Retire Cleanup, Leak D - Every Per-Surface Dict In NotificationCoordinator Is Snapshot-Swept

### Community 509 - "start.mjs"
Cohesion: 0.70
Nodes (4): main(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 510 - "PromptQueue"
Cohesion: 0.22
Nodes (8): Architecture Decisions (dated log), Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Multi-Agent Session Modes & Launch Table (P50 Phase B), Product Identity Guardrail: Terminal, Not IDE, Subsystems & Package Map

### Community 511 - ".panePathLookup"
Cohesion: 0.20
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

### Community 512 - "Changelog Archive"
Cohesion: 0.11
Nodes (17): CodingKey, CodingKeys, description, key, showInBanner, CodingKeys, createdAt, cwd (+9 more)

### Community 513 - "ThemeDocument"
Cohesion: 0.40
Nodes (9): attribute_lines(), main(), redraw_frames(), repeated_chunk(), run_case(), sgr_lines(), truecolor_gradient(), unicode_lines() (+1 more)

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.27
Nodes (7): Never, Set, String, Task, URL, Void, WorkspaceSymbolIndex

### Community 517 - ".testManyConcurrentSubscribersAllReceiveOutput"
Cohesion: 0.22
Nodes (6): AgentNotchPresentation, closed, open, peek, AgentNotchWindowActivator, Combine

### Community 519 - ".gestureRecognizer"
Cohesion: 0.18
Nodes (6): eKe(), irn(), mrn, _rn(), rrn(), srn()

### Community 520 - "WriteOutcome"
Cohesion: 0.20
Nodes (13): ern(), G4(), G7(), Jnn(), nrn(), Qnn(), sHe(), trn() (+5 more)

### Community 521 - "FileTreeKeyboardNavigator"
Cohesion: 0.25
Nodes (7): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, NSEvent

### Community 522 - "ShellCompletionInstallerTests"
Cohesion: 0.06
Nodes (40): .init(entry:), AgentChipView, .intrinsicContentSize, ChromeRole, sidebar, tabBar, Collection, .aggregateBoardStatus (+32 more)

### Community 523 - ".encode"
Cohesion: 0.25
Nodes (7): statusColor(), TabStatus, done, error, idle, running, waiting

### Community 524 - "RealPtyLifecycleTests"
Cohesion: 0.15
Nodes (14): Profile, edit, readonly, Run, RunState, cancelled, failed, running (+6 more)

### Community 525 - "TabContextCommand"
Cohesion: 0.36
Nodes (7): daemonLog(), detectStaleInstance(), installSignalHandlers(), removeForeignPIDFile(), Sendable, String, writePIDFile()

### Community 526 - "Kind"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 527 - "Agent hooks for Harness"
Cohesion: 0.50
Nodes (3): Bug 1 - Hunks Button Has Explicit Size Constraints, Bug 1 - Hunks Button Symbol Has A Guaranteed-Valid Fallback, Build Compiles Successfully

### Community 528 - "worktree_review_dashboard.robot"
Cohesion: 0.50
Nodes (3): Guard A - Merge Call Site Never Passes --no-ff, Guard B - No Auto-Resolve Anywhere In The Merge/Conflict Path, Guard C - Merge Conflict State Is Reconciled, Not Just Read Once

### Community 529 - "PickerItemRow"
Cohesion: 0.09
Nodes (16): AnyCancellable, .rowList, AgentNotchViewModel, .visibleRows, Bool, CGFloat, Duration, String (+8 more)

### Community 530 - "HarnessChrome"
Cohesion: 0.29
Nodes (8): FormatColor, none, palette, rgb, StyledSegment, Bool, String, UInt8

### Community 531 - ".recordReapedGenerationForTesting"
Cohesion: 0.36
Nodes (7): CGFloat, Range, TabBarLayoutMetrics, .pitch, TerminalTabBarBody, .body, TerminalTabBarModel

### Community 534 - ".sessionID"
Cohesion: 0.11
Nodes (21): AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem, FolderScanner (+13 more)

### Community 535 - "AgentNotification"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 537 - "NSObject"
Cohesion: 0.31
Nodes (6): TerminalGridCell, ThaiClusterCopyTests, ThaiGrid, .columns, .totalLines, .viewportRows

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.06
Nodes (34): MainActor, Void, SessionDividerRowView, .init(coder:), .init(frame:), SessionGroupHeaderRowView, .init(coder:), .init(frame:) (+26 more)

### Community 539 - "install-app.sh"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 544 - "Task Ledger Archive (Tasks 1–50)"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 546 - "LegacySnapshot"
Cohesion: 0.20
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 547 - "NSObject"
Cohesion: 0.14
Nodes (16): Any, ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool (+8 more)

### Community 553 - "harness.resource"
Cohesion: 0.29
Nodes (4): _c(), Nn(), Pqe, qp()

### Community 554 - "FileTreeKeyboardNavigator"
Cohesion: 0.33
Nodes (6): SurfaceProgressTracker, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void

### Community 556 - "BrowserTab"
Cohesion: 0.19
Nodes (10): .activeTab, .webView(_:createWebViewWith:for:windowFeatures:), .webView(_:didFinish:), BrowserTab, UUID, WKNavigationAction, WKWebView, tabs (+2 more)

### Community 558 - ".sendInput"
Cohesion: 0.16
Nodes (5): SSETransportTests, UInt16, MCPServer, String, NWListener

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 560 - "LayoutTemplate"
Cohesion: 0.22
Nodes (6): String, URL, ThemeCatalogEmbedTests, .embedSwift, .repoRoot, .sourceJSON

### Community 562 - "BrowserResponsePayload"
Cohesion: 0.40
Nodes (4): Build, Release & Git Workflow, Build / Test / Run, Release packaging order, Worktree constraint

### Community 563 - "AgentNotchViewModel.swift"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

### Community 565 - "ReleaseNotesGuardTests"
Cohesion: 0.36
Nodes (4): Bool, String, UUID, TaskDaemonBridge

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 568 - ".gestureRecognizer"
Cohesion: 0.31
Nodes (6): Container, .init(coder:), .init(frame:), NSCoder, NSHostingView, NSRect

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.33
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.08
Nodes (27): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+19 more)

### Community 572 - "LayoutProbeView"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 574 - "generate-release-notes.swift"
Cohesion: 0.16
Nodes (9): CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16, UInt8, UInt32 (+1 more)

### Community 575 - ".toastErrorSummary"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 576 - "Phase67Tests"
Cohesion: 0.22
Nodes (5): RepoResolver, Bool, String, RepoResolverTests, String

### Community 578 - "TaskDashboardBody"
Cohesion: 0.02
Nodes (431): l, V, em(), z(), _4n(), _6n(), _7n(), a0() (+423 more)

### Community 582 - "FileTreeKeyboardNavigator"
Cohesion: 0.22
Nodes (6): GitStatusProvider, Duration, String, GitStatusProviderLargeOutputTests, URL, TimeoutError

### Community 583 - "WorkbenchMRU"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 584 - ".configureEnvironment"
Cohesion: 0.31
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 585 - ".feed(_:)"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 587 - "BrowserResponsePayload"
Cohesion: 0.33
Nodes (4): .setSidebarVisible(_:animated:), SidebarPlacementSyncTests, CGFloat, Void

### Community 589 - "Endpoint"
Cohesion: 0.33
Nodes (4): GridCompositorCopyModeTests, PaneRect, String, TerminalGridSnapshot

### Community 592 - "commit-push.sh"
Cohesion: 0.22
Nodes (7): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController

### Community 593 - "dO"
Cohesion: 0.50
Nodes (4): dO(), m8(), rfn(), zfn()

### Community 594 - "hJ"
Cohesion: 0.67
Nodes (4): FVe(), hJ(), qVe(), Zme()

### Community 596 - "prepare-release.sh"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 597 - "rH"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 598 - ".control"
Cohesion: 0.18
Nodes (11): Typography, .badge, .kbd, .paletteHeader, .paletteTitle, .rowMeta, .rowTitle, .sectionLabel (+3 more)

### Community 599 - "nJt"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 600 - "HarnessTerminalSurfaceView"
Cohesion: 0.04
Nodes (31): NSCursor, NSRangePointer, Bool, CAMetalDrawable, NSEvent, String, Any, Bool (+23 more)

### Community 601 - "Hwe"
Cohesion: 0.67
Nodes (3): cat(), Hwe(), kYe()

### Community 603 - "fut"
Cohesion: 0.67
Nodes (3): cfn(), fut(), qYe()

### Community 604 - "k0t"
Cohesion: 0.67
Nodes (3): dht(), k0t(), l1n()

### Community 607 - "iRe"
Cohesion: 0.67
Nodes (3): iRe(), jNt(), zNt()

### Community 610 - ".installCLI"
Cohesion: 0.20
Nodes (17): Decodable, Item, ItemCompletedLine, LegacyMsgLine, Msg, String, AISuggestRequest, AttachFileRequest (+9 more)

### Community 613 - "INDEX.md"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 614 - "MainSplitViewController"
Cohesion: 0.09
Nodes (18): DisplayLinkTarget, MainSplitViewController, .setSidebarVisible(_:), SplitChromeDelegate, .splitView(_:constrainMaxCoordinate:ofSubviewAt:), .splitView(_:constrainMinCoordinate:ofSubviewAt:), .splitView(_:effectiveRect:forDrawnRect:ofDividerAt:), .splitView(_:shouldAdjustSizeOfSubview:) (+10 more)

### Community 617 - "ScriptFileWatcher"
Cohesion: 0.10
Nodes (26): CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf, .init(from:) (+18 more)

### Community 622 - "[1.3.0-vit] - 2026-06-06"
Cohesion: 0.32
Nodes (5): AgentSessionPlacement, background, cloud, local, remoteControl

### Community 623 - "BrowserResponsePayload"
Cohesion: 0.13
Nodes (8): PaneNode, BrowserLeaf, URL, DaemonSyncServiceBrowserPaneMergeTests, PaneID, PaneNode, PaneNodeBrowserTests, PaneNodeLayoutShapeTests

### Community 624 - "[2.5.0] - 2026-06-12"
Cohesion: 0.25
Nodes (7): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, String

### Community 627 - "ActiveTabCloseDisposition"
Cohesion: 0.33
Nodes (4): OutputTrigger, OutputTriggerStore, Bool, String

### Community 628 - "ReplayStep"
Cohesion: 0.31
Nodes (3): PortableRelativeDateFormatter, Date, String

### Community 629 - "graphify reference: query, path, explain"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 637 - "ClientSummary"
Cohesion: 0.15
Nodes (14): FileTreeContext, Bool, NSCoder, NSDraggingInfo, NSDragOperation, NSHostingView, NSScrollView, SessionID (+6 more)

### Community 641 - "[3.10.0] - 2026-06-27"
Cohesion: 0.25
Nodes (7): #kouen, #practice, #score, #shell, #total, #unix, #vim

### Community 645 - "stability_release.robot"
Cohesion: 0.24
Nodes (3): KouenMCP, KouenBrowserToolsTests, URL

### Community 646 - "[3.10.1] - 2026-06-27"
Cohesion: 0.24
Nodes (5): RiskyCommandClassifier, Bool, NSRegularExpression, String, RiskyCommandClassifierTests

### Community 648 - "PtyDrainCeilingBenchmark"
Cohesion: 0.18
Nodes (12): Counter, DrainResult, .bytesPerWakeup, .mbps, DrainState, EchoRTT, PtyDrainCeilingBenchmark, Bool (+4 more)

### Community 661 - "Remote SSH — Market Comparison"
Cohesion: 0.33
Nodes (5): Kouen vs Competitors (Remote Development over SSH), Our Gaps (vs leaders), Our Strengths, Remote SSH — Market Comparison, Roadmap Opportunities

### Community 662 - "New Tab"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 664 - "P37 Phase G — Autocomplete (mobile bridge)"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 666 - "BrowserIntegrationController"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 669 - ".recordReapedGenerationForTesting"
Cohesion: 0.26
Nodes (4): PaneLabelDaemonTests, String, URL, UUID

### Community 675 - ".detect"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 677 - "WriteOutcome"
Cohesion: 0.19
Nodes (8): SwarmFleetView, .init(coder:), CGFloat, NSCoder, CGFloat, NSCoder, TaskDashboardView, .init(coder:)

### Community 681 - ".tabIDsToNotify"
Cohesion: 0.14
Nodes (12): .setupPrompt, AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile (+4 more)

### Community 682 - ".update"
Cohesion: 0.12
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 683 - "ImportedTerminalConfig"
Cohesion: 0.26
Nodes (5): Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 684 - "New Tab"
Cohesion: 0.33
Nodes (5): ColorKind, .base, bg, fg, underline

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 686 - "AgyAdapter.swift"
Cohesion: 0.36
Nodes (5): AgyAdapter, Result, ResultLine, String, UUID

### Community 687 - "FormatStringExtendedVariableTests"
Cohesion: 0.47
Nodes (5): AgentIconArt, AgentVectorIcon, Bool, CGSize, String

### Community 690 - ".init"
Cohesion: 0.53
Nodes (3): ProjectConfig, Bool, String

### Community 693 - ".loadFromDisk"
Cohesion: 0.20
Nodes (9): AnyObject, CommandExecutionError, daemonError, .description, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor (+1 more)

### Community 694 - "zGe"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 696 - "TerminalTabBarDelegate"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 698 - "LayoutProbeView"
Cohesion: 0.22
Nodes (9): AssistantLine, ClaudeAdapter, Content, Message, ResultLine, Bool, Double, String (+1 more)

### Community 699 - ".makeDiffScrollView"
Cohesion: 0.39
Nodes (5): AutomationSummary, Bool, Date, String, UUID

### Community 700 - ".init"
Cohesion: 0.25
Nodes (6): Kind, path, stack, Bool, Date, UUID

### Community 701 - ".nextBrowserPaneID"
Cohesion: 0.47
Nodes (6): _9n(), d8e(), hmn(), PKe(), tke(), u7e()

### Community 702 - "main.swift"
Cohesion: 0.14
Nodes (5): PromptQueue, String, SurfaceID, Void, PromptQueueBar

### Community 703 - "ColorKind"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 704 - "oh"
Cohesion: 0.25
Nodes (4): bze(), EQ(), MBe(), mm

### Community 708 - "WrapperOptionBehavior"
Cohesion: 0.12
Nodes (8): OnboardingController, KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, BinaryInstallerDisplayTests, OnboardingEnvironmentTests

### Community 710 - "MainWindowController"
Cohesion: 0.10
Nodes (13): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+5 more)

### Community 711 - "RunState"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 712 - "ResumeStyle"
Cohesion: 0.50
Nodes (3): PaneID, PaneLeaf, PaneNode

### Community 713 - "AutomationScheduler"
Cohesion: 0.28
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 714 - "SwarmFleetView"
Cohesion: 0.16
Nodes (9): CGImage, data, DecodedImage, .byteCount, ImageLimits, Bool, UInt8, SixelDecoder (+1 more)

### Community 715 - "TerminalProgressReport"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 716 - "TabContextCommand"
Cohesion: 0.60
Nodes (5): Switch To Session 1, Switch To Session 2, Rapid Session Switch While Typing, Switch Between Isolated And Normal Session, Switch Session And Switch Back Preserves Worktree

### Community 719 - "DaemonRoundTripTests.swift"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 720 - "DisplayWidth"
Cohesion: 0.67
Nodes (3): AsyncCLIResultBox, Error, Result

### Community 721 - "MobileBridgeSpawnTests"
Cohesion: 0.40
Nodes (5): WrapperOptionBehavior, keepScanning, matchValue, skipValue, stopScanning

### Community 722 - ".configureEnvironment"
Cohesion: 0.36
Nodes (3): crn, ELt(), n2e()

### Community 723 - "Fze"
Cohesion: 0.04
Nodes (16): azt(), B0, BBe(), F7, Fze, ibe(), lS(), mathmlBuilder() (+8 more)

### Community 725 - "WriteOutcome"
Cohesion: 0.10
Nodes (16): aNt(), _Bt(), by(), dwn(), fst(), fwn(), gKt(), LC() (+8 more)

### Community 726 - "Switch To Session 1"
Cohesion: 0.12
Nodes (13): PaletteItemRow, .body, PaletteMode, errors, grep, normal, PalettePanel, .canBecomeKey (+5 more)

### Community 727 - "PromptQueueBar"
Cohesion: 0.17
Nodes (11): agy, claude, copilot, hermes, __kouen_agy_next, __kouen_claude_next, __kouen_copilot_next, __kouen_hermes_next (+3 more)

### Community 728 - ".handleUndo"
Cohesion: 0.06
Nodes (16): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess, DetachedPaneOverlay, .init(coder:), .init(frame:style:), Style, detached (+8 more)

### Community 730 - "Switch To Session 1"
Cohesion: 0.39
Nodes (3): KouenMCPServer, Bool, String

### Community 731 - "Phase6KeysTests"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: SSETransport auth token isRunning

### Community 732 - "ReplayStep"
Cohesion: 0.50
Nodes (3): SplitDirection, horizontal, vertical

### Community 733 - ".gestureRecognizer"
Cohesion: 0.67
Nodes (3): TransportError, invalidUTF8Header, missingContentLength

### Community 734 - "ResizeDirection"
Cohesion: 0.32
Nodes (6): CGFloat, ResizeDirection, down, left, right, up

### Community 735 - "ImageTextureCache"
Cohesion: 0.14
Nodes (11): MTLLibrary, MTLRenderPipelineState, ImageTextureCache, MTLDevice, MTLTexture, UInt8, CGFloat, MTLBuffer (+3 more)

### Community 736 - "graphify reference: add a URL and watch a folder"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 737 - ".resolve"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 744 - ".lex"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

### Community 745 - "p11_scripting.robot"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 750 - "ClipboardOSCTests"
Cohesion: 0.25
Nodes (9): kouen.bash script, agy(), claude(), copilot(), hermes(), __kouen_agy_next(), __kouen_claude_next(), __kouen_copilot_next() (+1 more)

### Community 754 - "BlockSummary"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 755 - "Motion"
Cohesion: 0.40
Nodes (5): Motion, .reduce, .spring, Animation, Bool

### Community 758 - "mm"
Cohesion: 0.22
Nodes (4): ClaudeCodeHarness, .hasAdapter(for:), Bool, ClaudeCodeHarnessTests

### Community 764 - ".main"
Cohesion: 0.20
Nodes (6): LSPDefinitionPayload, LSPDiagnosticsPayload, LSPStatusPayload, String, UInt64, URL

### Community 768 - ".tabIDsToNotify"
Cohesion: 0.40
Nodes (5): h1t(), hae(), jgn(), sfn(), _Ue()

### Community 774 - "TabContextCommand"
Cohesion: 0.12
Nodes (15): clamp(), statusHelp(), Configuration, String, T, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, TabContextCommand (+7 more)

### Community 775 - ".fontMetrics"
Cohesion: 0.18
Nodes (15): a2(), akn(), bpn(), cIn(), ift(), p7n(), pyn(), R1() (+7 more)

### Community 781 - ".statusLineSet"
Cohesion: 0.47
Nodes (3): .encode(_:modifiers:event:modes:), SpecialKey, insert

### Community 782 - "qk"
Cohesion: 0.03
Nodes (109): _1t(), a6n(), ag(), b1t(), b6n(), bd(), bkn(), ble() (+101 more)

### Community 790 - "DecoKind"
Cohesion: 0.04
Nodes (62): _3e(), calculate(), constructor(), d1t(), d2t(), dTn(), eMt(), evt() (+54 more)

### Community 804 - "ArtifactKind"
Cohesion: 0.21
Nodes (17): Close Pane, Close Tab, Split Down, Split Right, Cmd Shift W Force Closes Tab, Cmd W Closes Pane When Split, Cmd W Closes Tab When Single Pane, Window Survives Full Shortcut Sequence (+9 more)

### Community 991 - "Changed"
Cohesion: 0.22
Nodes (8): Build order (unchanged from interview decision), G1 — @ file-path picker, G2 — shell tab-completion suggestion strip (heuristic, explicitly best-effort), G3 — AI command suggestion (via `claude` CLI subprocess), Logical Design, P37 Phase G — Autocomplete (mobile bridge), Strategic Design, Tactical Design

### Community 1000 - "Changed"
Cohesion: 0.22
Nodes (8): Artifacts, Client Application — Slice 1 (stacked panes, no persistence), Client Application — Slice 2 (per-workspace divider memory), Context, Dev Task Progress — Workspace Sidebar Panels (P42), Integration, Note on task re-sequencing (2026-07-17), Summary

### Community 1303 - ".pushAgentActivityNotifications"
Cohesion: 0.50
Nodes (3): exclude_hubs, no_viz, wiki

### Community 1309 - ".startMetadataRefresh"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 1801 - "ClientSummary"
Cohesion: 0.22
Nodes (5): Completed Plans Archive, Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions

### Community 1832 - "Added"
Cohesion: 0.25
Nodes (7): Claude Code hook push (in-process Task subagent detection), Client UI indicator, Detection core (AgentDetector, pure logic), IPC / Tab plumbing, P38 Phase B — Subagent Visibility — Dev Task Progress, Status: Rewritten 2026-07-14 after original implementation (tasks 1-5) was lost to a concurrent git operation before commit. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 1914 - "P43 — Add Repo/Folder to Workspace"
Cohesion: 0.25
Nodes (7): Original overlay build (built 2026-07-14, gated green, then deleted 2026-07-15 mid live-test), P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress, Pivot — merge into the Recipes picker (2026-07-15), Stage 1-2 — Engine/surface plumbing (built 2026-07-14, unchanged by the pivot, still in use), Status: Implementation pivoted mid-phase from a standalone overlay to a merge into the existing, Summary, Thread grouping — Zed framing folded into the same picker (2026-07-15)

### Community 1943 - "ITerm2InlineImage"
Cohesion: 0.25
Nodes (8): Docs, kouen-mcp, KouenCore, KouenDaemon, KouenIPC, P41 — Automations — Task Progress, Tests, Verification

### Community 2014 - "Added"
Cohesion: 0.36
Nodes (7): Document, Bool, Set, String, URL, ToolPolicy, .defaultURL

### Community 2100 - ".handleWake"
Cohesion: 0.12
Nodes (14): .exit, String, String, KouenCLI, SessionID, String, Bool, Int32 (+6 more)

### Community 2176 - "Changed"
Cohesion: 0.29
Nodes (6): Locked decisions (user-confirmed), Logical Design, P38 Phase A — Cross-Agent Worktree Diff/Review Dashboard — Design, Strategic Design, Tactical Design, Verification gate (this phase)

### Community 2242 - "P42 — Workspace Sidebar Panels"
Cohesion: 0.29
Nodes (6): Logical Design, Next Step, P42 — Workspace Sidebar Panels, Parked (not in scope), Strategic Design, Tactical Design

### Community 2541 - "P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable"
Cohesion: 0.18
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 2573 - "P38 Phase D — Kitty Graphics Conformance Slice"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase D — Kitty Graphics Conformance Slice, Scope (locked), Tests

### Community 2633 - "P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua)"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua), Scope (locked), Tests

### Community 2639 - "P41 — Automations"
Cohesion: 0.33
Nodes (4): Logical Design, P41 — Automations, Strategic Design, Tactical Design

### Community 2642 - "P43 — Add Repo/Folder to Workspace"
Cohesion: 0.33
Nodes (5): Logical Design, Next Step, P43 — Add Repo/Folder to Workspace, Strategic Design, Tactical Design

### Community 2735 - "BlockSummary"
Cohesion: 0.09
Nodes (16): RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), ScrollbackEntry, ScrollbackReplaySegment, Bool, CChar, DaemonSurfaceID, Int32 (+8 more)

### Community 3131 - "P38 Phase D — Kitty Conformance — Dev Task Progress"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 3132 - "P38 Phase E — Scripting Hooks — Dev Task Progress"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 3135 - "Phase 0 — Swift 6.3+ Concurrency Safety (P0, LESSONS FROM macOS 26.5 CRASH SAGA)"
Cohesion: 0.67
Nodes (3): Phase 0 — Swift 6.3+ Concurrency Safety (P0, LESSONS FROM macOS 26.5 CRASH SAGA), Rules (enforced, not optional), Verification checklist for macOS 27 beta

### Community 3515 - "RawRepresentable"
Cohesion: 0.10
Nodes (23): Binding, .init(from:), .init(spec:command:note:repeatable:), CodingKeys, bindings, disabledSpecs, id, tables (+15 more)

## Knowledge Gaps
- **3507 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+3502 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1421 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `code:text (:workbench start swift)` to `graphify reference: extra exports and benchmark`, `.handleNormal`, `EngineConformanceTests`, `IPCRequest`, `AgentNotchRootView`, `FileTreeKeyboardNavigator`, `TerminalEmulator`, `GitPanelView.swift`, `PerformanceBenchmarks`, `VTParser`, `HarnessTerminalSurfaceView`, `.applyPreedit`, `MetalRendererTests`, `PickerItemRow`, `.recordReapedGenerationForTesting`, `HarnessUILibrary`, `HarnessChrome`, `.sessionID`, `SplitPaneCoordinator`, `.readGrid(scrollbackOffset:)`, `WorktreeManager`, `SessionGroupHeaderRowView`, `NSObject`, `RGBColor`, `.init`, `Notification`, `Sendable`, `.addTab`, `Equatable`, `.bufferLine`, `.characterIndex`, `MenuTarget`, `Task Ledger Archive (Tasks 1–50)`, `CodingKeys`, `FileTreeKeyboardNavigator`, `HarnessSidebarPanelViewController.swift`, `BrowserTab`, `.normalizedKey`, `.keyEvent`, `HarnessSplitView`, `TabCell`, `KouenOverlayBackground`, `CommandHistorySearchController`, `3.2 สิ่งที่ implement แล้ว`, `ViEngine`, `FrecencyDirectoryStore`, `generate-release-notes.swift`, `HarnessCLI+Server.swift`, `PasteBufferStore`, `Completed Plans Archive`, `worktree_isolation_cli.robot`, `WorkbenchMRU`, `.feed(_:)`, `.parse`, `TerminalProtocolCompatibilityTests`, `Endpoint`, `HarnessDesign`, `FormatContextDaemonTests`, `.firstMatch`, `LSPClient`, `LSPDiagnostic`, `TerminalGridCell`, `HarnessTerminalSurfaceView`, `AttachInputBatcher`, `shim.c`, `PaneContainerView`, `.installCLI`, `.dispatch`, `ScriptRuntime.swift`, `4. Technical Architecture`, `MainSplitViewController`, `DaemonLauncher`, `Recipe`, `Session Grouping and Split Session Plan`, `domain-design.md`, `AgentNotchViewModel`, `AnyCodable`, `DamageTrackingTests`, `SoftIconButton`, `.makeSnapshot`, `[2.5.0] - 2026-06-12`, `HarnessGridTerminal`, `.firstWaitingTab`, `HistoryRingBuffer`, `GlyphAtlas`, `code:block1 (SessionCoordinator.snapshot ──┐)`, `SwiftUI`, `.install`, `AgentHookInstaller`, `CommandTarget`, `.startWatching`, `PtyDrainCeilingBenchmark`, `User Story Mapping (MANDATORY)`, `How to use Harness from the terminal only (no GUI)`, `PaneStyleSet`, `AsciiFastPathTests`, `DecodedImage`, `TriState`, `Community None`, `What You Must Do When Invoked`, `Int`, `ThaiCombiningMarkTests`, `Added`, `MatchCategory`, `What You Must Do When Invoked`, `Workspace`, `CommandPromptController`, `ActiveTabCloseDisposition`, `URLDetection`, `ImportedTerminalConfig`, `New Tab`, `[1.5.1] - 2026-06-06`, `BinaryRefresherTests`, `BlockSummary`, `.hideFind`, `InlineAICompletionView`, `[3.13.1] - 2026-07-02`, `GridCompositorTests`, `P25 — iOS/iPadOS Support`, `LSPServerRegistry`, `SessionSnapshot`, `AppDelegate`, `.init`, `.makeDiffScrollView`, `main.swift`, `P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client`, `user-stories.md`, `GlyphRasterizer`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `BinaryInstaller`, `.classify`, `PaletteModel`, `SwarmFleetView`, `Harness keybindings`, `[3.9.5] - 2026-06-26`, `HarnessCLI`, `scheduleRender`, `DisplayWidth`, `PaneTarget`, `.lines`, `ScrollbackFile`, `TerminalServicesProvider`, `ResizeDirection`, `ImageTextureCache`, `SSHTunnelManagerTests`, `ExternalOpenKind`, `.scan`, `WorkbenchCommand`, `.make`, `PaneBorderStatus`, `[3.5.1] - 2026-06-20`, `BlockSummary`, `FileNode`, `.makeDiffScrollView`, `ReflowPreviewTests`, `HarnessTerminalSurfaceWorkerTests`, `.main`, `Split Right`, `BoardViewController`, `release-hotfix.sh`, `workspace`, `.install`, `HarnessSidebarPanelViewController`, `.path`, `ScrollbackPersistenceTests`, `DefaultTerminalManager`, `WindowSession`, `StatusLineView.swift`, `[2.5.0] - 2026-06-12`, `BlockTintOverlay`, `DisplayPanesOverlay`, `.menu`, `TerminalScrollbarView`, `FormatColor`, `click_ui_element`, `code:bash (harness-cli install-hooks hermes)`, `AgentHookStrategy`, `StatusLineWidthTests`, `JSONDecoder`, `Fixes Applied (layered)`, `GitHubCLIClient`, `NotificationBus`, `settings.json`, `PaneNode`, `HarnessPaths.swift`, `Send Ex Command`, `FrameSignposter`, `AgentSnapshot`, `Terminal AI Chat (⌘I inline overlay)`, `Memory — harness-terminal`, `code:bash (# In a Harness pane:)`, `DesktopNotifier`, `LayoutNode`, `WorkspaceSymbolIndex`, `.theme`, `.drawGlyph`, `Added`, `.makeModel`, `CommandExecutionError`, `CSIParams`, `Foundation`, `code:bash (harness-cli install-hooks openclaw)`, `FileViewerViewController`, `Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)`, `GPU Animation Pattern — Layout Once, GPU Paints`, `P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)`, `.handleCat`, `[3.5.1] - 2026-06-20`, `FormatStyledSegment.swift`, `RGBColor`, `Consumers`, `DaemonStats`, `Git Panel`, `ScrollReuseTests`, `SurfaceProgressTrackerTests.swift`, `MCPServer`, `PromptQueue`, `NSTextField Leak in BoardViewController (P20 Performance)`, `Darwin`, `PresentAttempt`, `AgentIconRenderer`, `Fixed`, `IPC Architecture`, `Session/Tab/Pane Hierarchy & Top Bar (CASE-028)`, `markdown.json`, `rust.json`, `RealPtyLifecycleTests`, `yaml.json`, `HintModeOverlay`, `SixelDecoder`, `.parseDiffHunks`, `.delay`, `Case: cwd "bleed" — session worktree jumps to wrong dir during builds`, `BoardCardView`, `PathToken`, `SessionEditor`, `GroupedSessionDaemonTests`, `main.swift`, `SessionCoordinator.swift`, `.recordReapedGenerationForTesting`, `.deinit`, `DispatchTime`, `HarnessOnboarding`, `.endFind`, `Added`, `ScrollbackTests`, `Command Prompt Architecture`, `.testKouenRendererFixtureDefaultTextReportsPlausibleGlyphStats`, `ccRunCancel`, `ccRunGet`, `.bind`, `.json`, `FormatContextDaemonTests`, `SessionStore`, `.panePathLookup`?**
  _High betweenness centrality (0.238) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `Terminal AI Chat (⌘I inline overlay)` to `IPCRequest`, `worktree_isolation_cli.robot`, `Changelog`, `Consumers`, `code:text (:workbench start swift)`, `.deinit`, `PickerItemRow`, `LaunchdServiceInstaller`, `HarnessUILibrary`, `PaneNode`, `main.swift`, `Community None`, `Prompt`, `P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client`?**
  _High betweenness centrality (0.189) - this node is a cross-community bridge._
- **Why does `fbt()` connect `qk` to `TaskDashboardBody`, `Changelog`, `HarnessTerminalSurfaceView`, `WorkspaceFileTreeView`, `CopyModeAction`?**
  _High betweenness centrality (0.101) - this node is a cross-community bridge._
- **Are the 18 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `RenderScheduler`) actually correct?**
  _`KouenTerminalSurfaceView` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _3527 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.12012012012012012 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.14736842105263157 - nodes in this community are weakly interconnected._