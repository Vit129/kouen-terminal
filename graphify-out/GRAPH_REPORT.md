# Graph Report - kouen-terminal  (2026-11-18)

## Corpus Check
- 996 files · ~1,079,295 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 20580 nodes · 59323 edges · 2835 communities (1585 shown, 1250 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8863 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `b4c2e11c`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 346 edges
2. `i()` - 318 edges
3. `a()` - 282 edges
4. `SessionCoordinator` - 237 edges
5. `SurfaceRegistry` - 236 edges
6. `TerminalEmulator` - 235 edges
7. `DaemonClient` - 217 edges
8. `u()` - 217 edges
9. `KouenCLI` - 216 edges
10. `IPCRequest` - 212 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 191 areas (212 edges)
2. `Command` - bridges 101 areas (108 edges)
3. `AgentKind` - bridges 82 areas (186 edges)
4. `IPCResponse` - bridges 81 areas (108 edges)
5. `KouenTerminalSurfaceView` - bridges 77 areas (346 edges)
6. `SurfaceRegistry` - bridges 67 areas (236 edges)
7. `SessionCoordinator` - bridges 66 areas (237 edges)
8. `NSView` - bridges 64 areas (193 edges)
9. `KouenGridTerminal` - bridges 63 areas (117 edges)
10. `AnyCodable` - bridges 60 areas (190 edges)

## Surprising Connections (you probably didn't know these)
- `.selectedHost` --references--> `RemoteHost`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRemoteView.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.terms` --calls--> `SearchMatcher`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/UI/History/HistorySearchEvidence.swift → Packages/KouenCore/Sources/KouenCore/Search/SearchMatcher.swift
- `.cleanPrompt` --references--> `AgentSessionRecord`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/UI/History/HistorySessionDetailsView.swift → Packages/KouenCore/Sources/KouenCore/Agents/AgentHistoryScanner.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/RemoteHostsService.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift

## Import Cycles
- None detected.

## Communities (2835 total, 1250 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.12
Nodes (15): SavedLayoutStore, Bool, String, URL, UUID, PaneLayoutShape, branch, leaf (+7 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.09
Nodes (27): DaemonSubscription, .start(onData:onEnd:buffered:), PendingFrameSpool, Bool, FileHandle, String, UInt16, URL (+19 more)

### Community 2 - ".handleNormal"
Cohesion: 0.12
Nodes (12): BrowserLeaf, PaneNode, PaneID, URL, Decoder, .init(from:), DaemonSyncServiceBrowserLeafIdentityTests, Tab (+4 more)

### Community 3 - "Changed"
Cohesion: 0.05
Nodes (13): azt(), B0, BBe(), F7, Fze, ibe(), mathmlBuilder(), O7 (+5 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.08
Nodes (23): DaemonClient, .start(onResponse:onEnd:), Int32, TimeInterval, UInt64, UUID, Void, ClaudeCodeHarnessIPCTests (+15 more)

### Community 5 - "IPCRequest"
Cohesion: 0.08
Nodes (20): Data, DecodedReplyFrame, output, reply, DecodedRequestFrame, input, request, FrameError (+12 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.06
Nodes (26): OSSignposter, TerminalColorRole, background, cursor, foreground, palette, FrameDropCause, encodeFailure (+18 more)

### Community 7 - "Command"
Cohesion: 0.10
Nodes (29): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+21 more)

### Community 8 - "LSPMessage"
Cohesion: 0.04
Nodes (56): a2(), agn(), agt(), akn(), bce(), bpn(), c8n(), cIn() (+48 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.09
Nodes (20): ag(), d8n(), dZe(), ha(), i9e(), jke(), k7e(), Lf() (+12 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.07
Nodes (34): .currentRawSelection, .currentSelectionRegion, RawSelection, Bool, ClosedRange, SelectionResolver, String, BlockSelection (+26 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.03
Nodes (69): _5e(), Ac(), b3e(), bvt(), bX(), c6(), c6n(), cae() (+61 more)

### Community 12 - "Changed"
Cohesion: 0.10
Nodes (15): .windowSection, KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:showMenuBarIcon:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:fileSearchRoots:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:), .scrollbackLines, ResizeOverlayPosition, bottomRight, center (+7 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.10
Nodes (25): item, AgentHistoryFTSIndex, .deleteSession(sessionID:), .incrementalCursor(sessionID:path:), .indexSessionsBatch(_:), .needsReindex(sessionID:mtime:fileSize:), .pruneMissingSessions(validTranscriptPaths:), .saveRecord(_:mtime:fileSize:) (+17 more)

### Community 14 - "VTParser"
Cohesion: 0.15
Nodes (8): StringKind, apc, dcs, UInt8, UnsafeBufferPointer, VTParser, .feed(_:), VTParserHandler

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.05
Nodes (31): .tab(forSurfaceKey:), DaemonCommandExecutor, Command, .init(forTesting:), UUID, Void, BellScanState, esc (+23 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.11
Nodes (10): .agentColorBinding, colors, PerformanceBenchmarks, SurfaceMainThreadStallSample, Bool, Double, String, UInt64 (+2 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.19
Nodes (11): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, .selectedHost (+3 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.08
Nodes (21): .init(frame:), Kind, primary, secondary, KouenPillButton, .init(title:kind:), .isHovered, .isPressed (+13 more)

### Community 19 - "SpecialKey"
Cohesion: 0.13
Nodes (12): DetachedPaneOverlay, .init(coder:), .init(frame:style:), Style, detached, reconnectingChip, NSCoder, NSEvent (+4 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.20
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.06
Nodes (23): Void, IndexingIterator, LayoutTemplate, Bool, Double, surfaceID, SessionEditor, .split(node:targetPaneID:direction:paneCount:before:) (+15 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.01
Nodes (583): _0t(), _1n(), _2t(), _3n(), _5n(), _6e(), _8n(), _9e() (+575 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.17
Nodes (8): AgentListFormatter, Date, String, dvn(), AgentListFormatterTests, Bool, Date, String

### Community 24 - ".request"
Cohesion: 0.14
Nodes (13): String, CGFloat, NSCoder, SessionID, String, Void, TaskDashboardBody, .body (+5 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.04
Nodes (38): o, AI(), aXe(), aZ(), bee(), ck(), cy(), Da() (+30 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.12
Nodes (16): .textView(_:doCommandBy:), Selector, CompletionPopupView, .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:) (+8 more)

### Community 27 - "RGBColor"
Cohesion: 0.15
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 28 - ".parse"
Cohesion: 0.02
Nodes (266): l, V, a1t(), a7n(), a8n(), aA(), abn(), ace() (+258 more)

### Community 29 - "Added"
Cohesion: 0.03
Nodes (88): _3e(), A1(), aat(), AS(), bw(), c5n(), cc(), cOn() (+80 more)

### Community 30 - "Notification"
Cohesion: 0.05
Nodes (50): a4e(), aae(), ake(), ate(), b2(), b6(), e3(), eL() (+42 more)

### Community 31 - "Sendable"
Cohesion: 0.19
Nodes (9): LayoutFileStore, LayoutNode, branch, leaf, LayoutTemplate, Date, Double, String (+1 more)

### Community 32 - ".addTab"
Cohesion: 0.07
Nodes (33): .body, FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body (+25 more)

### Community 33 - "Equatable"
Cohesion: 0.13
Nodes (10): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, PaneID (+2 more)

### Community 34 - "DaemonClient"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 35 - "MenuTarget"
Cohesion: 0.09
Nodes (25): .body, ProjectCategory, .init(from:), .init(id:name:sourceFolder:excludedPaths:), ProjectEntry, .id, .init(from:), .init(path:categoryID:stableID:) (+17 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.14
Nodes (7): Any, ConsoleLineCapTests, NetworkCaptureDecisionTests, Bool, String, WKScriptMessage, WKUserContentController

### Community 37 - "String"
Cohesion: 0.08
Nodes (31): .lspPosition(for:), Codable, Equatable, CodingKeys, error, id, jsonrpc, method (+23 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.08
Nodes (39): json, async, .saveRecordsBatch(_:), CachedSessionEntry, autoreleasepool(), T, AgentHistoryScanner, .parseAntigravityTranscript(sessionID:fileURL:) (+31 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.08
Nodes (35): AddToWorkspaceSheet, .allSelected, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem, fetchGitStatus(), ProjectCategorySection (+27 more)

### Community 41 - "CodingKeys"
Cohesion: 0.08
Nodes (28): ClientRecord, CountBox, DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed (+20 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.14
Nodes (18): CommandParseError, .description, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand (+10 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.09
Nodes (15): .addSurface(tabID:paneID:), .addSurface(to:paneID:surfaceID:cwd:), .tab(containingPaneID:), .tab(for:), .tabIndex(surfaceKey:), .tabIndex(tabID:), .tabIndex(workspaceID:tabID:), Bool (+7 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.10
Nodes (18): Process, SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, SSHTunnelManager (+10 more)

### Community 46 - ".buildCommand"
Cohesion: 0.04
Nodes (31): historyJSONObject(), Any, String, .readJSONLLines(from:fromOffset:), AntigravityTranscriptLine, ClaudeSessionLocator, ClaudeTranscriptLine, Role (+23 more)

### Community 48 - "HookEvent"
Cohesion: 0.06
Nodes (35): Executor, Hook, HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane (+27 more)

### Community 49 - "DaemonServer"
Cohesion: 0.14
Nodes (19): .modifierFlags, NSEvent, BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, CodingKeys (+11 more)

### Community 50 - "Added"
Cohesion: 0.12
Nodes (13): TerminalDamage, RenderColor, MetalRendererTests, .makeRenderer(device:atlasSize:atlasMaxPages:), RenderedFixture, Bool, MTLDevice, MTLTexture (+5 more)

### Community 51 - ".keyEvent"
Cohesion: 0.09
Nodes (28): ColorKind, .base, bg, fg, underline, ComposedCell, .asGridCell, .cluster (+20 more)

### Community 52 - "Fixed"
Cohesion: 0.08
Nodes (27): KeyRecorderRepresentable, String, Void, NSView, OverlayBackground, Context, OverlayBackground, Context (+19 more)

### Community 53 - "Added"
Cohesion: 0.18
Nodes (17): aJ(), bXt(), cJ(), dXt(), F0(), fXt(), Ime(), kXt() (+9 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.06
Nodes (45): AnyTransition, AnyView, Color, .hexString, AgentNotchPeekEvent, AgentNotchRootView, .body, .bottomRadius (+37 more)

### Community 55 - "TabCell"
Cohesion: 0.15
Nodes (8): AnyCodable, JSONRPCError, Bool, Int32, Pipe, String, TimeInterval, ToolRegistry

### Community 57 - "BellScanState"
Cohesion: 0.09
Nodes (19): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+11 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.10
Nodes (37): MTLClearColor, MTLCommandBuffer, MTLRenderCommandEncoder, BgInstance, CursorCacheKey, .invertsGlyph, DecoInstance, EncodedFrameInstances (+29 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.14
Nodes (15): Lease, SSHTunnelLeaseStore, .isPrivateDirectory, SSHTunnelProcessIdentity, Bool, Error, Int32, ObjectIdentifier (+7 more)

### Community 60 - "ViEngine"
Cohesion: 0.02
Nodes (339): pe(), r, X(), A(), code(), R(), a(), aDt() (+331 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.11
Nodes (12): center, ComposerPanel, .canBecomeKey, .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange, NSTextView (+4 more)

### Community 62 - "ComposedCell"
Cohesion: 0.18
Nodes (11): SwarmSpawnSpec, CallRecorder, .cancelCalls, .closeCalls, .harnessCalls, .surfaceCalls, SwarmWorkerManagerTests, Bool (+3 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 64 - ".text"
Cohesion: 0.14
Nodes (9): CommandIPCTranslator, CommandTranslation, clientLocal, unresolved, Command, PaneID, String, TabID (+1 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.12
Nodes (16): a6(), h2(), H7(), kCn(), lXt(), N$e(), pR(), qUe() (+8 more)

### Community 67 - "String"
Cohesion: 0.13
Nodes (14): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+6 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.22
Nodes (5): Bool, Character, NSRange, NSTextView, String

### Community 69 - ".compose"
Cohesion: 0.12
Nodes (12): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, input (+4 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.07
Nodes (45): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+37 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 72 - "XCTestCase"
Cohesion: 0.12
Nodes (19): .pairedAlreadyBanner, .pairingQRPanel, FleetJobItem, .isActive, .launchAgentScriptPath, .statusDisplay, AutomationsFleetView, .automationsList (+11 more)

### Community 73 - "README.md"
Cohesion: 0.50
Nodes (3): Hermes → Kouen, One-line install, Required: approve the hook

### Community 74 - "[2.6.0] - 2026-06-13"
Cohesion: 0.08
Nodes (14): CGFloat, NSEvent, NSEvent, UInt8, NSEvent, NSPoint, UInt16, Bool (+6 more)

### Community 75 - "OptionStore"
Cohesion: 0.11
Nodes (15): StatusLineView, .init(coder:), Bool, CGFloat, Never, NSAttributedString, NSCoder, NSColor (+7 more)

### Community 76 - ".parse"
Cohesion: 0.16
Nodes (10): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab, UUID (+2 more)

### Community 78 - "Added"
Cohesion: 0.16
Nodes (8): CustomEndpointTester, Result, Bool, String, URL, CustomEndpointTesterTests, URLRequest, URLSession

### Community 79 - "HarnessDesign"
Cohesion: 0.09
Nodes (17): MenuBarController, .init(visibilityProvider:), MenuRef, SessionRow, Bool, CGFloat, NSImage, NSMenu (+9 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 82 - ".firstMatch"
Cohesion: 0.08
Nodes (13): .receive(_:), DispatchSemaphore, FluidityBenchmarks, NSWindow, String, UInt64, SurfaceOffMainStallSample, KouenTerminalSurfaceWorkerTests (+5 more)

### Community 83 - "LSPClient"
Cohesion: 0.12
Nodes (44): Ame(), aQt(), Cqt(), CUe(), cXt(), Eme(), eXt(), gXt() (+36 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.13
Nodes (9): .captureLines(joinWrapped:), .feed(_:), .promptRows, .readGrid(scrollbackOffset:), ScrollbackTests, Character, String, SemanticPromptTests (+1 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.05
Nodes (41): BrowserPaneRegistry, BrowserPaneView, .activeTab, .init(url:paneID:), .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), .webView(_:didCommit:), .webView(_:didFail:withError:) (+33 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.15
Nodes (9): FileEditorView, Bool, NSEvent, NSHostingView, String, URL, FileEditorViewQuickLookRoutingTests, String (+1 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.15
Nodes (14): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+6 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.16
Nodes (13): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+5 more)

### Community 89 - ".cursorPos"
Cohesion: 0.16
Nodes (4): hooks, AgentHookInstallerTests, String, URL

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.14
Nodes (12): pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal, Int32 (+4 more)

### Community 91 - "TerminalModes"
Cohesion: 0.29
Nodes (7): Bm(), kfn(), rDt(), ryn(), vn(), w4e(), z0n()

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.17
Nodes (4): AgentHistoryMultiAgentCoverageTests, Bool, String, URL

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.09
Nodes (16): .effectiveResumeCommand(claudeMode:), LiveClaudeAgentEntry, .placement, ClaudeSessionMode, TimeoutFlag, .didFire, ClaudeCloudSessionStore, Entry (+8 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.19
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 95 - "shim.c"
Cohesion: 0.13
Nodes (16): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerModel, DirectoryPickerView, .body (+8 more)

### Community 96 - "Harness Usage"
Cohesion: 0.17
Nodes (8): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, String, PaneStyleTests

### Community 97 - "PaneContainerView"
Cohesion: 0.02
Nodes (184): a(), b(), c(), d(), e(), f(), g(), h() (+176 more)

### Community 99 - ".dispatch"
Cohesion: 0.12
Nodes (17): FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID, FeatureTask (+9 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.07
Nodes (28): LSPFileSession, Bool, Never, String, Task, URL, Void, LSPClient (+20 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.15
Nodes (15): AsyncRunCoordinator, drainOutput(), OutputBuffer, OutputCapture, ProcessCancellation, ProcessResult, .isSuccess, Bool (+7 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.11
Nodes (18): GroupHeaderRow, .body, PickerItem, .groupLabel, historyBlock, .id, recipe, .searchableText (+10 more)

### Community 104 - "Recipe"
Cohesion: 0.10
Nodes (12): AgentDetection, AgentDetector, MatchSource, ownProcess, wrapperLaunch, RawMatch, Date, Int32 (+4 more)

### Community 105 - "Changelog"
Cohesion: 0.10
Nodes (27): TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid, TerminalTextRenderingMode (+19 more)

### Community 106 - "domain-design.md"
Cohesion: 0.14
Nodes (10): ScrollbackFile, .highWater, Bool, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.05
Nodes (29): .init(coder:), BrowserProgressLine, .init(coder:), .init(frame:), BrowserTabButton, .init(coder:), .init(title:isActive:onSelect:onClose:), DesignModeElementInfo (+21 more)

### Community 108 - ".resolve"
Cohesion: 0.15
Nodes (10): ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID, String, SurfaceID (+2 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.13
Nodes (11): PaneRect, PaneID, SurfaceID, SGRMouse, SGRMouseEvent, Bool, UInt8, SGRMouseTests (+3 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.07
Nodes (40): ch(), cvt(), d1t(), dV(), epn(), ew(), fpt(), gU() (+32 more)

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.08
Nodes (11): TerminalGridCell, HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor, Bool, String (+3 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.12
Nodes (3): KouenApp, GitPanelViewToastErrorSummaryTests, GitPanelViewWorktreeParsingTests

### Community 114 - ".firstWaitingTab"
Cohesion: 0.14
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 115 - ".encode"
Cohesion: 0.20
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 116 - "SessionGroup"
Cohesion: 0.12
Nodes (13): SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, SessionID, String, SurfaceID (+5 more)

### Community 117 - "PaneNode"
Cohesion: 0.12
Nodes (10): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+2 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.06
Nodes (26): AgentRoutingResolver, String, AgentRoutingRule, Kind, path, stack, Bool, Date (+18 more)

### Community 119 - "Harness command reference"
Cohesion: 0.12
Nodes (17): Agent safety CLI (`kouen-cli`), Attaching from a plain terminal, Bindings, Buffers (paste store), Composition, Hooks, Inspection (CLI / control mode), Kouen command reference (+9 more)

### Community 120 - "Added"
Cohesion: 0.19
Nodes (6): Case, ReflowCorpusTests, .corpus, .goldenDir, String, URL

### Community 121 - "Changed"
Cohesion: 0.05
Nodes (12): KeyTokenParser, Bool, String, DirectionalAxis, down, left, right, up (+4 more)

### Community 122 - "ViEngine"
Cohesion: 0.11
Nodes (18): CodingKeys, excludedPaths, id, name, sourceFolder, CodingKey, CodingKeys, cacheReadTokens (+10 more)

### Community 123 - "Pipe"
Cohesion: 0.11
Nodes (18): IssueKeychainStore, Bool, String, IssueTrackerType, azureDevOps, github, .id, jira (+10 more)

### Community 124 - "String"
Cohesion: 0.06
Nodes (31): TerminalModes, InputEncoder, .encode(_:modifiers:event:modes:), .encode(text:modifiers:modes:), .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release (+23 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.12
Nodes (9): ContiguousArray, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, Iterator, S (+1 more)

### Community 126 - ".path"
Cohesion: 0.15
Nodes (16): AgentMark, .body, AgentMarkShape, Scanner, .atEnd, SVGPath, Bool, CGFloat (+8 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.17
Nodes (19): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), GlyphKey (+11 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.10
Nodes (19): Coordinator, DiffAnalysis, DiffFileItem, DiffFileStatus, added, .color, deleted, modified (+11 more)

### Community 129 - "SwiftUI"
Cohesion: 0.18
Nodes (4): FilePreviewCoordinator, FileTabID, Set, String

### Community 131 - ".install"
Cohesion: 0.15
Nodes (6): .agentInfo(forWorktreePath:tabs:), Tab, TabID, WorkspaceID, GitPanelViewWorktreeAgentTests, GitPanelViewWorktreeNavigationTests

### Community 132 - "AgentHookInstaller"
Cohesion: 0.10
Nodes (13): OptionSet, KeySpec, .description, .init(from:), .init(key:modifiers:), Modifiers, Decoder, String (+5 more)

### Community 133 - ".load"
Cohesion: 0.12
Nodes (17): AgentSessionHistoryView, .body, .emptyStateTitle, .footerView, .historyCountText, HistoryMenuProxy, Any, Bool (+9 more)

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.19
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 135 - "CommandTarget"
Cohesion: 0.13
Nodes (9): DispatchWorkItem, NSRange, NSString, Void, SyntaxTextView, .init(frame:), .lspPosition(characterOffset:), FilePreviewReleaseTests (+1 more)

### Community 136 - ".startWatching"
Cohesion: 0.21
Nodes (4): CommandTarget, String, UUID, TargetSpecTests

### Community 137 - "ActivePaneService"
Cohesion: 0.12
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.09
Nodes (25): aNt(), bNt(), bu(), cNt(), dNt(), dwn(), eNt(), eRe() (+17 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.10
Nodes (14): Bool, CGFloat, NSCoder, Void, TabNavigation, TabNavigationButtons, .init(coder:), NSStackView (+6 more)

### Community 140 - "Added"
Cohesion: 0.16
Nodes (15): dhn(), en(), fhn(), ghn(), gk(), GOt(), jUe(), kr() (+7 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.09
Nodes (23): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+15 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.07
Nodes (32): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, .body, PaletteMode (+24 more)

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.18
Nodes (6): DefaultTerminalLaunchRequest, ShellQuoting, Bool, String, URL, DefaultTerminalLaunchRequestTests

### Community 144 - "PaneStyleSet"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 146 - "DecodedImage"
Cohesion: 0.18
Nodes (4): Gbe(), handler(), l8e(), YUt

### Community 147 - "FileTreeWatcher"
Cohesion: 0.09
Nodes (32): eJ(), fme(), gC(), gKt(), gUe(), $He(), iXt(), kGt() (+24 more)

### Community 148 - "TriState"
Cohesion: 0.01
Nodes (329): _4e(), _4n(), _6n(), _7n(), a0(), a0n(), a2n(), a5n() (+321 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.13
Nodes (8): KouenMCP, tool, KouenBrowserToolsTests, URL, KouenDaemonToolsTests, String, URL, McpHardeningTests

### Community 151 - ".evaluate"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 152 - "Added"
Cohesion: 0.16
Nodes (6): TimeInterval, WorktreeManager, String, URL, UUID, WorktreeIsolationDaemonTests

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.17
Nodes (7): CGImage, DecodedImage, .byteCount, ImageLimits, Bool, UInt8, ImageDecoder

### Community 154 - "LiveResizeTests"
Cohesion: 0.10
Nodes (5): String, KouenSidebarPanelViewController, MainActor, String, FolderScanner

### Community 155 - "Int"
Cohesion: 0.11
Nodes (13): FileFuzzyMatcher, FileSearchRootScanner, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool (+5 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.08
Nodes (24): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, .acceptsFirstResponder (+16 more)

### Community 157 - "Added"
Cohesion: 0.14
Nodes (36): aQ(), bme(), bqt(), bYt(), cbe(), DD(), dqt(), Dr() (+28 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 159 - "MatchCategory"
Cohesion: 0.05
Nodes (28): CornerInfo, EditorDividerView, HitTestPassthroughView, KouenSplitView, .dividerColor, .dividerThickness, .init(coder:), PaneDragGripView (+20 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.10
Nodes (24): NSEvent, FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose (+16 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.08
Nodes (18): .readJSONLLines(from:), AgentUsage, .contextTokens, .init(from:), .init(inputTokens:outputTokens:cacheReadTokens:cacheWriteTokens:thinkingTokens:totalCostUSD:), .shortSummary, Decoder, Double (+10 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.10
Nodes (17): NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent, NSImage (+9 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.09
Nodes (24): ChecksStatus, fail, none, pass, CIRun, GitHubCLIClient, IssueInfo, MergeMethod (+16 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.15
Nodes (14): ContentLengthRejection, SSETransport, .isRunning, .listener, Bool, CheckedContinuation, DispatchTimeInterval, Never (+6 more)

### Community 166 - "LiveSession"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.16
Nodes (17): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+9 more)

### Community 168 - "Added"
Cohesion: 0.08
Nodes (23): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSEvent (+15 more)

### Community 169 - "Fixed"
Cohesion: 0.16
Nodes (6): AgentTableEntry, Bool, Set, String, .effectiveAgentKind, AgentDetectorTests

### Community 170 - "URLDetection"
Cohesion: 0.08
Nodes (11): Bool, Range, Set, String, URLDetection, CGFloat, CGRect, Range (+3 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.14
Nodes (15): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+7 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.17
Nodes (12): SurfaceProgressTracker, Bool, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void, Counter (+4 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.09
Nodes (8): KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), SpawnedAgentSurface, Bool, ISO8601DateFormatter, String, Tab, UUID

### Community 175 - "RGBColorTests"
Cohesion: 0.23
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 176 - "Added"
Cohesion: 0.06
Nodes (15): NWEndpoint, Bool, NWListener, Sendable, String, UInt16, MobileBridgeServer, .isRunning (+7 more)

### Community 177 - ".rects"
Cohesion: 0.17
Nodes (4): AgyAdapter, CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 178 - "InlineAICompletionView"
Cohesion: 0.09
Nodes (24): Binding, .init(from:), .init(spec:command:note:repeatable:), CodingKeys, bindings, disabledSpecs, id, tables (+16 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.11
Nodes (13): SessionID, Status, ciFailing, done, mergeReady, open, running, Bool (+5 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.11
Nodes (15): ProjectMoveReviewView, Set, String, KouenCore, Candidate, String, WorkspaceReconciliation, WorkspaceReconciliationTests (+7 more)

### Community 181 - "GridCompositorTests"
Cohesion: 0.07
Nodes (21): GitAheadBehind, GitResult, .isSuccess, GitWorktreeInfo, Bool, Int32, String, GitParsers (+13 more)

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.14
Nodes (13): BranchSwitchHelper, FileTreeNode, FileTreeSwiftUIView, .body, .pastedImagesSection, .scanOptions, Notification.Name, Bool (+5 more)

### Community 183 - "LSPServerRegistry"
Cohesion: 0.08
Nodes (6): CodepointRunFastPathTests, .assertAllPathsAgree(_:cols:rows:file:line:), StaticString, String, UInt, UInt8

### Community 184 - "targets"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Kouen, Sparkle (+13 more)

### Community 187 - "AppDelegate"
Cohesion: 0.18
Nodes (10): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+2 more)

### Community 188 - "BrowserPaneView"
Cohesion: 0.11
Nodes (20): Motion, .entrance, .spring, .standardEase, CAMediaTimingFunction, NSWindowController, NSWindowDelegate, KouenOnboarding (+12 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.13
Nodes (9): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, Set, SurfaceID, Tab (+1 more)

### Community 190 - "user-stories.md"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.12
Nodes (11): ScriptError, .errorDescription, evaluationError, unsupportedPlatform, ScriptRuntime, Any, String, URL (+3 more)

### Community 192 - "GlyphRasterizer"
Cohesion: 0.08
Nodes (28): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+20 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.19
Nodes (10): RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal, FileHandle, Int32 (+2 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.09
Nodes (9): Any, Bool, NSMenu, NSMenuItem, NSPasteboard, String, URL, String (+1 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.07
Nodes (19): AgentHistoryDateGroup, older, .sortOrder, thisWeek, today, yesterday, HistoryScope, all (+11 more)

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.06
Nodes (34): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, SessionGroup, SessionID (+26 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.18
Nodes (7): AIProviderAwakeService, .closedLidOptedIn, Bool, NSObjectProtocol, Set, String, AIProviderAwakeServiceTests

### Community 198 - ".classify"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.22
Nodes (10): CopyModeGridSource, .promptRows, ClosedRange, CopyModeReducer, Bool, Character, NSRegularExpression, Range (+2 more)

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.13
Nodes (10): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String (+2 more)

### Community 202 - "PaletteModel"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.15
Nodes (8): ContextResolutionEngine, Bool, String, Bool, String, TokenGuard, ContextResolutionEngineTests, String

### Community 204 - "From tmux"
Cohesion: 0.25
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 205 - "CopyModeState"
Cohesion: 0.14
Nodes (12): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+4 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.08
Nodes (24): Font, .kouenBadge, .kouenBody, .kouenBodyStrong, .kouenCaption2, .kouenCaption, .kouenKbd, .kouenMono (+16 more)

### Community 207 - "scheduleRender"
Cohesion: 0.15
Nodes (9): CheckpointInfo, CheckpointManager, Bool, Date, String, CheckpointManagerTests, String, String (+1 more)

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.09
Nodes (17): Int, Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock (+9 more)

### Community 209 - "SettingsRemoteView"
Cohesion: 0.06
Nodes (29): Notification.Name, KouenGit, os, Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached (+21 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.20
Nodes (4): CompletionGenerator, String, .fishCompletionSource, CompletionGeneratorTests

### Community 211 - "PaneTarget"
Cohesion: 0.28
Nodes (7): Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 212 - ".translate"
Cohesion: 0.16
Nodes (7): CwdMetadataProvider, GitMetadataProvider, MetadataProvider, Bool, String, Tab, GitMetadataProviderTests

### Community 213 - "String"
Cohesion: 0.11
Nodes (7): TimeInterval, Logger, AgentHandoffBuilder, Bool, String, HandoffDirectoryTests, AgentHandoffBuilderTests

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.10
Nodes (8): SessionStore, DispatchWorkItem, TimeInterval, SessionPersistenceTests, Bool, String, TabID, URL

### Community 215 - ".lines"
Cohesion: 0.15
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 216 - "CellColorResolverTests"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 217 - "GridCompositor"
Cohesion: 0.21
Nodes (9): Bool, CGFloat, Character, NSEvent, NSRange, NSString, NSTextView, String (+1 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.27
Nodes (7): Reason, errored, finished, needsInput, RowState, Bool, Comparable

### Community 219 - "Prompt"
Cohesion: 0.22
Nodes (8): DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSViewCornerConfiguration, SurfaceID, Void

### Community 220 - "Section"
Cohesion: 0.17
Nodes (11): NotchGeometry, .fallback, NSScreen, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics (+3 more)

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.24
Nodes (5): NodeRow, .body, .parentDirectory, Error, String

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.13
Nodes (7): ControlKeyNormalizer, Bool, String, ShortcutRecorderSerializer, String, ControlKeyNormalizerTests, ShortcutRecorderSerializerTests

### Community 224 - "CellColorResolver"
Cohesion: 0.10
Nodes (14): MochaTheme, ANSIPalette, UInt8, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors, Bool (+6 more)

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.11
Nodes (7): ScreenPos, bottom, middle, top, KouenLSP, QuickLookUI, LSPLifecycleTests

### Community 226 - "FileChangeWatcher"
Cohesion: 0.21
Nodes (5): CopyModeReducerTests, FakeGrid, .totalLines, Set, String

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.25
Nodes (18): Encodable, AgyModelsPush, AISuggestionAck, AttachedAck, Body, BrowserFramePush, Cred, DetachedAck (+10 more)

### Community 228 - "sessionRow"
Cohesion: 0.09
Nodes (11): KeybindingsService, Bool, Command, String, KeybindingsStore, .fileURL, URL, KeybindingsStoreTests (+3 more)

### Community 229 - ".decide"
Cohesion: 0.14
Nodes (8): MutationResult, RemoteHost, RemoteHostStore, Bool, String, RemoteHostStoreTests, String, URL

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.25
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 231 - "ExternalOpenKind"
Cohesion: 0.13
Nodes (23): Colors, Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors (+15 more)

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.15
Nodes (8): BoardViewController, .isVisible, FlippedView, .isFlipped, Bool, Set, TabID, BoardViewControllerTests

### Community 233 - "TextGrid"
Cohesion: 0.17
Nodes (3): RegressionBugFixTests, Tab, TaskRequestCounter

### Community 234 - ".scan"
Cohesion: 0.17
Nodes (5): .snapshot, Bool, String, ThemeService, KouenOptions

### Community 235 - "WorkbenchCommand"
Cohesion: 0.15
Nodes (10): String, Array, RecipePanel, .canBecomeKey, RecipePickerController, RecipePickerView, RecipeWindowDelegate, Bool (+2 more)

### Community 236 - "Added"
Cohesion: 0.24
Nodes (8): NaturalLanguage, AgentHistorySearch, Hit, IDFCache, Bool, Double, String, .tokenHits(_:inNormalized:)

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.08
Nodes (15): Bool, NSEvent, Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint (+7 more)

### Community 238 - ".make"
Cohesion: 0.26
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.17
Nodes (5): HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 240 - "PaneBorderStatus"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 241 - "Added"
Cohesion: 0.14
Nodes (4): ProcessRunner, ReaderStop, String, ProcessRunnerTests

### Community 242 - "AgentBridge"
Cohesion: 0.26
Nodes (5): StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength, newline

### Community 243 - ".make"
Cohesion: 0.29
Nodes (4): SwarmDAGStore, String, UUID, SwarmDAGStoreTests

### Community 244 - "FileNode"
Cohesion: 0.13
Nodes (16): FileNode, GitStatusType, added, deleted, modified, renamed, unmodified, untracked (+8 more)

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.16
Nodes (14): Profile, edit, readonly, Run, RunState, cancelled, failed, running (+6 more)

### Community 247 - ".renderFixture"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.06
Nodes (42): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, .init(from:), .init(id:name:baseURL:modelID:), ModelProvider (+34 more)

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.16
Nodes (9): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+1 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 251 - "SessionCoordinator"
Cohesion: 0.14
Nodes (12): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+4 more)

### Community 252 - "NSViewRepresentable"
Cohesion: 0.10
Nodes (6): Divergence, Bool, String, WorktreeInfo, String, WorktreeIsolationTests

### Community 253 - "Split Right"
Cohesion: 0.24
Nodes (7): BinaryInstaller, .bundledMacOSDir, Bool, TimeInterval, BinaryInstallerVersionTests, String, URL

### Community 254 - "BoardViewController"
Cohesion: 0.18
Nodes (11): Typography, .badge, .kbd, .paletteHeader, .paletteTitle, .rowMeta, .rowTitle, .sectionLabel (+3 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.11
Nodes (13): MarkdownPreviewView, .webView(_:decidePolicyFor:decisionHandler:), Bool, MainActor, Sendable, String, URL, WKNavigationAction (+5 more)

### Community 256 - "GitMetadataProvider"
Cohesion: 0.26
Nodes (8): InstallResult, Shell, bash, fish, zsh, ShellIntegration, Bool, URL

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.18
Nodes (20): CoreImage, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription, .surfaceID, detectHost() (+12 more)

### Community 260 - ".welcome"
Cohesion: 0.08
Nodes (25): CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display, found, .isReady (+17 more)

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 262 - ".install"
Cohesion: 0.12
Nodes (12): IteratorProtocol, AgentHistoryJSONLSequence, .isValid, Iterator, Bool, Date, FileHandle, Iterator (+4 more)

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.21
Nodes (13): CellMetrics, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth, Bool (+5 more)

### Community 266 - ".path"
Cohesion: 0.22
Nodes (6): ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 267 - ".performInstall"
Cohesion: 0.05
Nodes (38): Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions, Logical Design, P41 — Automations, Strategic Design, Tactical Design (+30 more)

### Community 268 - "code:bash (# Old (agent-specific):)"
Cohesion: 0.08
Nodes (26): aie(), arc(), b2e(), bezierCurveTo(), closePath(), cRe(), cZ(), e0n() (+18 more)

### Community 270 - "WindowSession"
Cohesion: 0.09
Nodes (7): Bool, Command, DispatchWorkItem, PaneID, String, UInt8, WindowSession

### Community 271 - "StatusLineView.swift"
Cohesion: 0.16
Nodes (8): ParsedShortcut, .displayString, PrefixKeymap, Any, Bool, NSEvent, String, TimeInterval

### Community 272 - "SGRMouseEvent"
Cohesion: 0.12
Nodes (20): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, PaletteFooter, .body (+12 more)

### Community 273 - "KeySpec"
Cohesion: 0.12
Nodes (15): Notification.Name, ObserverToken, NSCoder, NSObjectProtocol, NSPopover, NSRect, NSTextView, SyntaxLineNumberGutterView (+7 more)

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.16
Nodes (9): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ProcessInfo (+1 more)

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.09
Nodes (27): Darwin, Glibc, DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed (+19 more)

### Community 277 - ".run"
Cohesion: 0.18
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 278 - "BlockTintOverlay"
Cohesion: 0.12
Nodes (13): AgentSessionHistoryModel, .extraRecordsShown, .filteredRecords, .records, .searchQuery, .selectedAgents, .selectedIndex, .selectedScope (+5 more)

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.15
Nodes (12): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+4 more)

### Community 280 - ".menu"
Cohesion: 0.21
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.12
Nodes (17): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, .rootPicker, FileTreeContext (+9 more)

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.14
Nodes (9): NSAttributedString, NSRegularExpression, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String (+1 more)

### Community 283 - "FormatColor"
Cohesion: 0.26
Nodes (3): String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 284 - "click_ui_element"
Cohesion: 0.16
Nodes (6): LSPTextLocation, .position, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.14
Nodes (6): UserDefaults, ScanCallCounter, PortableRelativeDateFormatter, Date, String, UUID

### Community 287 - ".apply"
Cohesion: 0.41
Nodes (5): InstallResult, ShellCompletionInstaller, Bool, String, URL

### Community 288 - "AgentHookStrategy"
Cohesion: 0.26
Nodes (6): Bool, NSRange, NSString, NSTextView, String, unichar

### Community 290 - "Process"
Cohesion: 0.09
Nodes (23): OptionStore, OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Scope, global (+15 more)

### Community 292 - "Release runbook"
Cohesion: 0.33
Nodes (4): Full local signing path (needs a Developer ID cert; not currently used), How this fork actually releases, Release runbook, Scripted flow

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.11
Nodes (16): CodingKeys, error, id, jsonrpc, method, JSONRPCId, int, string (+8 more)

### Community 294 - "GitHubCLIClient"
Cohesion: 0.22
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 295 - "AgentApprovalBar"
Cohesion: 0.20
Nodes (7): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, FileChangeWatcherTests

### Community 297 - "settings.json"
Cohesion: 0.21
Nodes (10): AutomationsFleetModel, .load(detectScheduledRuns:), JobResultArtifact, .systemImage, Any, Bool, Date, String (+2 more)

### Community 299 - "PaneNode"
Cohesion: 0.08
Nodes (32): CGFloat, FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView (+24 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.13
Nodes (14): string, AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID, .snapshotPayload (+6 more)

### Community 301 - ".parse"
Cohesion: 0.08
Nodes (14): NSRangePointer, Any, NSAttributedString, NSRange, NSRect, String, UInt64, .color(_:) (+6 more)

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.18
Nodes (11): TrackedIssue, GitHubSearchResult, IssueFetchStatus, apiError, live, notConfigured, IssueTrackerService, Repository (+3 more)

### Community 303 - ".encodeMouse"
Cohesion: 0.17
Nodes (5): TabID, WorkspaceID, AgentCommandTests, String, Tab

### Community 304 - "00-inception-plan.md"
Cohesion: 0.14
Nodes (14): AYt(), Cme(), DYt(), EUe(), eYt(), IUe(), j9n(), KYt() (+6 more)

### Community 305 - ".script"
Cohesion: 0.16
Nodes (10): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+2 more)

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 307 - "ViPathTokenTests"
Cohesion: 0.08
Nodes (12): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), StructureFingerprint, Bool, Never, Set (+4 more)

### Community 308 - "Send Ex Command"
Cohesion: 0.09
Nodes (20): PaneBorderStatus, bottom, off, top, PaneRectSolver, BoxDrawing, Kind, arms (+12 more)

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.11
Nodes (22): keys, ITerm2InlineImage, .heightArg, .preserveAspectRatio, .widthArg, Bool, String, UInt8 (+14 more)

### Community 312 - "AgentSnapshot"
Cohesion: 0.14
Nodes (17): Array, Bool, Date, PaneID, String, TabID, Tab, .alertFlags (+9 more)

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.06
Nodes (36): .agentInfo(forWorktreePath:), AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary (+28 more)

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.17
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.17
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 319 - "FormatColor"
Cohesion: 0.15
Nodes (9): Bool, Int32, String, URL, SystemdUserInstaller, .backendName, .isInstalled, .unitURL (+1 more)

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.19
Nodes (3): ContentAreaViewController, Bool, Notification

### Community 321 - "UInt64"
Cohesion: 0.14
Nodes (10): OutputCoalescer, .bufferedMemoryBytes, .bufferedSpoolBytes, .retainedChunkSlots, OutputDiskSpool, .isDrained, .remainingBytes, FileHandle (+2 more)

### Community 322 - "DesktopNotifier"
Cohesion: 0.13
Nodes (17): FormatContextBuilder, DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:) (+9 more)

### Community 323 - "LayoutNode"
Cohesion: 0.20
Nodes (9): AnyObject, CommandExecutionError, daemonError, .description, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor (+1 more)

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.05
Nodes (28): DaemonClientActor, TimeInterval, DaemonSessionError, daemonError, .description, unexpectedResponse, DaemonSessionService, .endpoint (+20 more)

### Community 325 - "FloatingPaneController"
Cohesion: 0.18
Nodes (6): .onCurrentCWD, .onCurrentFile, Bool, NSString, NSTextView, String

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.04
Nodes (24): KouenDaemonCore, DaemonAsyncReplyRoutingTests, Int32, String, TimeInterval, UInt8, URL, DaemonBrowserRoutingTests (+16 more)

### Community 327 - ".theme"
Cohesion: 0.14
Nodes (12): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, AutomationScheduler (+4 more)

### Community 328 - "README.md"
Cohesion: 0.37
Nodes (3): .block(atPromptLine:), String, TerminalBlockStoreTests

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 330 - ".drawGlyph"
Cohesion: 0.19
Nodes (13): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Bool, Duration (+5 more)

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.19
Nodes (9): SessionTaskRequests, Bool, escaping, Never, Sendable, Task, UUID, TaskDaemonBridge (+1 more)

### Community 332 - "Added"
Cohesion: 0.20
Nodes (6): .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:surfaceTag:topicSegments:), AgentHistorySearchTests, String, TimeInterval, URL, skipUnlessSQLiteAvailable()

### Community 333 - "RealPty"
Cohesion: 0.18
Nodes (8): ClaudeRunSummary, Date, Double, Int32, String, UUID, String, UUID

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.11
Nodes (17): clamp(), statusHelp(), Configuration, Date, String, T, TabID, TabBarIconButtonStyle (+9 more)

### Community 335 - ".makeModel"
Cohesion: 0.22
Nodes (7): HeadlessRunEvent, assistantText, result, sessionID, Bool, Double, String

### Community 336 - "run.sh"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 337 - "CommandExecutionError"
Cohesion: 0.15
Nodes (9): FormatContext, FormatString, FormatStyle, Bool, Character, Date, String, FormatStyledTests (+1 more)

### Community 338 - "CSIParams"
Cohesion: 0.13
Nodes (9): NSDraggingInfo, NSDragOperation, PasteController, Bool, NSPasteboard, String, TimeInterval, URL (+1 more)

### Community 339 - "Foundation"
Cohesion: 0.11
Nodes (18): AppKit, CoreGraphics, CoreText, ImageIO, KouenCopyMode, KouenTerminalEngine, KouenTerminalRenderer, KouenTheme (+10 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.15
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.19
Nodes (8): AgentRemoteControlDaemonService, Set, String, Void, AgentRemoteControlDaemonServiceTests, LogBox, .count, String

### Community 342 - "Added"
Cohesion: 0.30
Nodes (7): Bool, NSPasteboard, NSString, String, URL, TerminalServicesProvider, AutoreleasingUnsafeMutablePointer

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.17
Nodes (21): Decodable, Item, ItemCompletedLine, LegacyMsgLine, Msg, String, ThreadStartedLine, AgentCommandRequest (+13 more)

### Community 344 - "FileViewerViewController"
Cohesion: 0.14
Nodes (11): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+3 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.17
Nodes (7): EnvironmentStore, Persisted, String, URL, URL, EnvironmentStoreTests, URL

### Community 348 - "DaemonLifecycleTests"
Cohesion: 0.09
Nodes (13): CustomStringConvertible, KouenPaths, KouenPathsError, .description, socketPathTooLong, Bool, String, T (+5 more)

### Community 349 - "Contents.json"
Cohesion: 0.17
Nodes (16): SessionRef, byID, byName, next, previous, String, UUID, TargetSpec (+8 more)

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.40
Nodes (5): PaneOutputWaiter, PaneOutputWaitResult, CheckedContinuation, Never, UInt64

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.06
Nodes (50): AgentRow, .agentColor, .executables, .hookButton, .hookButtonTitle, .mcpButton, SettingsAgentsView, .agentsSection (+42 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.20
Nodes (4): Bool, String, SurfaceID, TimeInterval

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.15
Nodes (11): copyMode, esc(), fs, globalShortcuts, KEYBINDINGS, prefixTable, renderTable(), ROOT (+3 more)

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.19
Nodes (10): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+2 more)

### Community 355 - ".deepMerge"
Cohesion: 0.16
Nodes (11): ProjectGroupWatcher, StreamBox, Bool, DispatchSourceFileSystemObject, escaping, MainActor, Never, String (+3 more)

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.18
Nodes (7): StaleTemporaryFileSweeper, Bool, Date, String, URL, Void, AppLaunchTempCleanupTests

### Community 357 - ".handleCat"
Cohesion: 0.08
Nodes (46): BrowserSnapshotAck, agentWaitChannel(), BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserRequestPayload, close (+38 more)

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.19
Nodes (4): GitPanelRefreshGate, .stats, GlyphAtlasStats, GitPanelViewFSEventFilterTests

### Community 359 - "OcclusionTests"
Cohesion: 0.14
Nodes (13): .body, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter, Any, Bool (+5 more)

### Community 360 - "State"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.22
Nodes (11): MarkdownImageSchemeHandler, .webView(_:start:), .webView(_:stop:), Never, ObjectIdentifier, Task, URL, Void (+3 more)

### Community 362 - "RGBColor"
Cohesion: 0.10
Nodes (15): GitPanelView, .isHidden, .removeWorktreeAction(path:), GitResult, Bool, GitResult, NSColor, NSStackView (+7 more)

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.08
Nodes (19): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+11 more)

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.09
Nodes (16): AgyModelCatalog, Catalog, Date, String, TimeInterval, AgyMobileCommands, String, ClaudeMobileCommands (+8 more)

### Community 366 - "Consumers"
Cohesion: 0.13
Nodes (15): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+7 more)

### Community 367 - "DaemonStats"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 368 - "Tab"
Cohesion: 0.18
Nodes (12): MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith, filenameStartsWith (+4 more)

### Community 369 - "Git Panel"
Cohesion: 0.25
Nodes (4): .init(frame:), NSRect, URL, SyntaxDefinitionTarget

### Community 370 - ".encode"
Cohesion: 0.18
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.16
Nodes (4): KouenThemeCatalog, .allThemes, String, KouenThemeCatalogTests

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.11
Nodes (20): DataBox, .init(coder:), .init(frame:), .removeWorktreeAction(_:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton (+12 more)

### Community 373 - "Prompt"
Cohesion: 0.18
Nodes (3): fQ, hqe(), M9()

### Community 374 - ".run"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

### Community 375 - ".install"
Cohesion: 0.17
Nodes (11): BrowserOkAck, Sendable, T, ConnectionState, DraftPRAck, ErrorAck, FileAttachedAck, NWConnection (+3 more)

### Community 376 - "ScrollReuseTests"
Cohesion: 0.07
Nodes (22): OSCTerminatorMatch, PtyError, launchFailed, RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), .retainedScrollbackBytesForTesting, ScrollbackEntry, ScrollbackReplaySegment (+14 more)

### Community 377 - "Identifiable"
Cohesion: 0.19
Nodes (4): URL, MobileBridgeAttachFileTests, String, URL

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 379 - "MCPServer"
Cohesion: 0.27
Nodes (4): HintModeOverlay, Any, NSEvent, String

### Community 380 - "PromptQueue"
Cohesion: 0.16
Nodes (11): FileGraphInfo, GraphifyLSPBridge, GraphIndexCache, Date, Double, String, URL, GraphifyLSPBridgeTests (+3 more)

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.16
Nodes (12): Configuration, Int32, SessionGroup, SessionID, Tab, TabID, WorkspaceID, TabSelector (+4 more)

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.10
Nodes (19): CompleteStepView, Void, OnboardingStep, complete, discover, .id, setup, shell (+11 more)

### Community 385 - "INDEX.md"
Cohesion: 0.21
Nodes (8): DaemonMetrics, Snapshot, .meanLockWaitMicros, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.19
Nodes (10): Entry, Failure, unavailable, SharedMetalResources, MTLCommandQueue, MTLDevice, MTLLibrary, MTLRenderPipelineState (+2 more)

### Community 387 - "User Profile"
Cohesion: 0.06
Nodes (22): .effectiveResumeCommand(mode:), AgentLaunchCommands, AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand (+14 more)

### Community 388 - "Darwin"
Cohesion: 0.24
Nodes (8): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8, .body

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.37
Nodes (4): KouenFeatureMarkdownSync, Bool, String, URL

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.16
Nodes (9): CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16, UInt8, UInt32 (+1 more)

### Community 402 - "View"
Cohesion: 0.14
Nodes (7): KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, BinaryInstallerDisplayTests, OnboardingEnvironmentTests

### Community 403 - "PresentAttempt"
Cohesion: 0.05
Nodes (19): Phase67Tests, LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab, TabID (+11 more)

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.23
Nodes (8): SettingsAdvancedView, .body, Bool, String, SettingsFileSearchSection, .body, String, SwiftUI

### Community 405 - "AgentIconRenderer"
Cohesion: 0.18
Nodes (13): AgentIconRenderer, Scanner, .atEnd, SVGPathParser, Bool, CGFloat, CGPath, CGPoint (+5 more)

### Community 406 - "main.swift"
Cohesion: 0.20
Nodes (13): ern(), G4(), G7(), Jnn(), nrn(), Qnn(), sHe(), trn() (+5 more)

### Community 407 - "Fixed"
Cohesion: 0.07
Nodes (14): HookState, failed, idle, installed, installing, SliderRow, .body, .displayValue (+6 more)

### Community 408 - "IPC Architecture"
Cohesion: 0.18
Nodes (10): AssistantLine, ClaudeAdapter, Content, Message, ResultLine, Bool, Double, String (+2 more)

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.33
Nodes (3): TaskStore, URL, TaskStoreTests

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.17
Nodes (3): ShellIntegrationTests, .repoRoot, URL

### Community 412 - "go.json"
Cohesion: 0.21
Nodes (4): ezt(), GGe, Hzt(), Kp()

### Community 413 - "javascript.json"
Cohesion: 0.17
Nodes (4): KouenGridTerminal, .onResponse, .onSetClipboard, ParserRobustnessTests

### Community 414 - "json.json"
Cohesion: 0.22
Nodes (4): JSONDecoder, JSONEncoder, Encoder, TerminalRecordingCodec

### Community 415 - "markdown.json"
Cohesion: 0.07
Nodes (29): KouenCommands, DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String (+21 more)

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.18
Nodes (6): Range, String, TerminalBufferMatch, TerminalBufferSearch, String, TerminalBufferSearchTests

### Community 417 - "rust.json"
Cohesion: 0.15
Nodes (11): SwarmFleetBody, .body, SwarmFleetView, .init(coder:), SwarmNodeRowView, .body, .statusColor, CGFloat (+3 more)

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.08
Nodes (23): DisplayLinkTarget, MainSplitViewController, .setSidebarVisible(_:), .setSidebarVisible(_:animated:), SplitChromeDelegate, .sidebarMaxWidth, .sidebarMinWidth, .splitView(_:constrainMaxCoordinate:ofSubviewAt:) (+15 more)

### Community 419 - "typescript.json"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 420 - "yaml.json"
Cohesion: 0.39
Nodes (3): data, SixelDecoder, UInt8

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.09
Nodes (18): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+10 more)

### Community 422 - "HintModeOverlay"
Cohesion: 0.18
Nodes (8): BrowserFileReloadTests, CountingWebView, Nav, NSEvent, String, Void, WKNavigation, WKNavigationDelegate

### Community 423 - "SixelDecoder"
Cohesion: 0.16
Nodes (13): .filteredJobs, RankedHistoryMatchResult, SearchMatcher, .matchHistory(normalizedTitle:normalizedBranchFilesTools:normalizedRepoAgent:normalizedChatContent:rawChatContent:rawBranchFilesTools:tokenWeights:), .matchHistory(title:branchFilesTools:repoAgent:chatContent:tokenWeights:), .tokenHits(_:in:), .tokenNear(_:in:), Bool (+5 more)

### Community 424 - ".parseDiffHunks"
Cohesion: 0.20
Nodes (8): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController

### Community 425 - "AgentVectorIcon"
Cohesion: 0.25
Nodes (8): FeaturePhase, architect, completed, dev, interview, qaDesign, qaVerify, .title

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.17
Nodes (14): SecureInputMonitor, DispatchQueue, DispatchWorkItem, MainActor, Sendable, Set, SurfaceID, UUID (+6 more)

### Community 427 - ".delay"
Cohesion: 0.31
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 428 - "TaskDashboardView"
Cohesion: 0.24
Nodes (9): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+1 more)

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.23
Nodes (9): AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor (+1 more)

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.19
Nodes (9): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+1 more)

### Community 431 - "BoardCardView"
Cohesion: 0.12
Nodes (24): .color, BoardCard, BoardColumn, .name, BoardColumnKind, .displayName, done, error (+16 more)

### Community 432 - "PathToken"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.17
Nodes (4): Any, NSMenuItem, GitPanelViewDiffErrorTests, String

### Community 434 - "Project History"
Cohesion: 0.20
Nodes (6): SessionGroup, SessionGroup, NSMenu, NSMenuItem, SessionGroup, SessionID

### Community 435 - ".init"
Cohesion: 0.20
Nodes (5): Network, HTTPRequestPolicy, Bool, String, UInt16

### Community 436 - "WaitForRegistry"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: animateSidebar setContentLeadingInset MainSplitViewController, Source Nodes

### Community 437 - "PickerItemRow"
Cohesion: 0.15
Nodes (9): _7(), A7(), a8(), bGt(), c8(), ene(), Gnn, IC() (+1 more)

### Community 438 - "SessionEditor"
Cohesion: 0.10
Nodes (18): .requestDaemon(_:), .selectWorkspace(byIndex:), .syncFromDaemon(metadataOnly:), ActiveTabCloseDisposition, session, tab, window, workspace (+10 more)

### Community 439 - "SetupStepView"
Cohesion: 0.15
Nodes (8): brn, grn, hrn(), JGe(), KGe(), prn(), qGe(), zGe()

### Community 440 - "LegacySnapshot"
Cohesion: 0.21
Nodes (5): ImageTextureCache, MTLDevice, MTLTexture, Set, UInt8

### Community 441 - "RemoteHostStore"
Cohesion: 0.16
Nodes (7): ReleaseNotes, Section, String, ReleaseNotesGuardTests, .changelog, String, .sampleNotes

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.10
Nodes (12): BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool, CGFloat, NSCoder, NSPoint (+4 more)

### Community 443 - "main.swift"
Cohesion: 0.17
Nodes (5): ExpressibleByStringLiteral, StringError, .init(_:), .init(stringLiteral:), MobileBridgeAISuggestTests

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 445 - "Section"
Cohesion: 0.40
Nodes (4): Findings, Sources, What this means for Kouen, Who creates branches / worktrees in AI coding tools

### Community 446 - "Modifiers"
Cohesion: 0.13
Nodes (11): Am(), bze(), Cm(), EQ(), Hm(), Im(), lte(), MBe() (+3 more)

### Community 447 - "PaletteMode"
Cohesion: 0.21
Nodes (3): files, GitDiffFile, MobileBridgeGitDiffTests

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.36
Nodes (7): Document, Bool, Set, String, URL, ToolPolicy, .defaultURL

### Community 449 - "PresentAttempt"
Cohesion: 0.23
Nodes (6): ProjectGroupResolver, String, String, .trimmed, AgentTitleInference, Bool

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.12
Nodes (6): Bool, String, UInt8, UnsafeBufferPointer, TerminalEmulator, .captureLines(fromLine:toLine:)

### Community 451 - ".run"
Cohesion: 0.39
Nodes (5): AutomationSummary, Bool, Date, String, UUID

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.15
Nodes (3): AgentHookInstallerCLI, String, String

### Community 454 - ".recordReapedGenerationForTesting"
Cohesion: 0.20
Nodes (5): aD(), crn, ELt(), n2e(), urn

### Community 455 - "ComposerPanel"
Cohesion: 0.12
Nodes (16): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+8 more)

### Community 456 - "TerminalModes"
Cohesion: 0.27
Nodes (7): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection, agents

### Community 457 - ".normalizedKey"
Cohesion: 0.19
Nodes (5): ClaudeCodeHarness, .hasAdapter(for:), Bool, HeadlessCLIAdapter, ClaudeCodeHarnessTests

### Community 458 - "PaneOutputWaiter"
Cohesion: 0.16
Nodes (16): SwarmFleetSnapshot, SwarmLane, pty, structured, SwarmTaskNode, SwarmTaskStatus, cancelled, failed (+8 more)

### Community 459 - ".encode"
Cohesion: 0.22
Nodes (7): Group, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, CGFloat, NSTextField, NSWindow

### Community 460 - "RunState"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 461 - ".worktreeList"
Cohesion: 0.32
Nodes (3): ReflowPreviewTests, .feeds, String

### Community 462 - "AGENTS.md"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 463 - ".deinit"
Cohesion: 0.29
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 464 - "MouseButton"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 465 - "DirectionalAxis"
Cohesion: 0.20
Nodes (7): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, NSCoder, Void

### Community 466 - "PlatformSys.swift"
Cohesion: 0.33
Nodes (3): ResubscribingSlot, Maker, Subscription

### Community 467 - ".moveSelection"
Cohesion: 0.24
Nodes (7): HTTPURLResponse, SSETransportTests, Never, String, Task, UInt16, Void

### Community 468 - "Never"
Cohesion: 0.20
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

### Community 469 - "TerminalTabBarView"
Cohesion: 0.13
Nodes (19): CGFloat, Never, NSHostingView, NSLayoutConstraint, Range, Tab, Task, Void (+11 more)

### Community 470 - "DispatchTime"
Cohesion: 0.39
Nodes (4): SessionGroup, Any, String, Tab

### Community 471 - ".evaluateStyled"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 473 - "HarnessOnboarding"
Cohesion: 0.27
Nodes (4): ArchitectureGuardTests, .repoRoot, String, URL

### Community 474 - ".show"
Cohesion: 0.19
Nodes (9): NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView, .cornerConfiguration (+1 more)

### Community 475 - ".hitTest"
Cohesion: 0.30
Nodes (5): SearchBenchmarks, String, UInt64, URL, Void

### Community 476 - "StatusDotView"
Cohesion: 0.11
Nodes (17): AgentBadgeView, .body, Bool, CGFloat, .agentFilterMenu, AgentSessionShortcutManagerView, .body, .orderedKinds (+9 more)

### Community 478 - ".install"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 480 - ".isRisky"
Cohesion: 0.33
Nodes (4): Run, String, TerminalBanner, WelcomeConfig

### Community 481 - "SecureInputMonitor"
Cohesion: 0.31
Nodes (4): OcclusionTests, NSWindow, String, TimeInterval

### Community 483 - "Changed"
Cohesion: 0.25
Nodes (3): FlushSessionStateTests, String, URL

### Community 484 - "CopilotAdapter"
Cohesion: 0.33
Nodes (6): HistorySessionDetailsView, .body, .cleanPrompt, .hasAvailableWorktree, Bool, String

### Community 486 - "TabPillView"
Cohesion: 0.25
Nodes (6): Kind, input, metadata, output, resize, ReplayStep

### Community 487 - "bC"
Cohesion: 0.41
Nodes (7): FeatureSummary, FeatureTaskSummary, GateSummary, Bool, Date, String, UUID

### Community 488 - "R1"
Cohesion: 0.19
Nodes (7): PaneID, SurfaceID, Tab, TabID, BrowserPaneReuseScopeTests, Tab, TabID

### Community 489 - "SurfaceIO"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: BrowserPaneView createTab openBrowserPane navigation WebKit, Source Nodes

### Community 490 - "ccRunGet"
Cohesion: 0.25
Nodes (8): CodingKeys, cols, createdAt, dataBase64, rows, timeMs, type, version

### Community 491 - ".update"
Cohesion: 0.19
Nodes (11): RecordingEvent, input, metadata, output, resize, .timeMs, Date, Decoder (+3 more)

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 494 - "ccRunInfo"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Where are the Wave 1 deadlock, HTTP transport and markdown preview paths?, Source Nodes

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.15
Nodes (14): SettingsTerminalView, .body, .experienceSection, .fontReadout, .fontSection, .shellSection, Bool, String (+6 more)

### Community 498 - ".runGitDiff"
Cohesion: 0.11
Nodes (15): Error, InstallError, unsupported, CwdAuthorizationError, foreignPathRejected, .message, missingSessionOrCwd, other (+7 more)

### Community 499 - "GlassEffectView"
Cohesion: 0.39
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 501 - "Fixed"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 502 - "Kouen Terminal — System Architecture"
Cohesion: 0.32
Nodes (6): CGFloat, ResizeDirection, down, left, right, up

### Community 503 - "Kouen Features"
Cohesion: 0.25
Nodes (14): Oe(), a(), D(), e(), i(), k(), n(), o() (+6 more)

### Community 504 - "String"
Cohesion: 0.18
Nodes (12): DotView, .init(coder:), .init(frame:), statusColor(), Bool, Context, NSCoder, NSColor (+4 more)

### Community 505 - ".tickFeatureWorktreeSweepLocked"
Cohesion: 0.36
Nodes (3): KouenSplitViewTests, LayoutProbeView, CGFloat

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.24
Nodes (4): GroupedSessionDaemonTests, SessionGroup, String, URL

### Community 509 - "start.mjs"
Cohesion: 0.60
Nodes (5): main(), printHelp(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 510 - "PromptQueue"
Cohesion: 0.14
Nodes (14): Architecture Decisions (dated log), Commit preparation, Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Markdown preview trust boundary, Menu-bar icon visibility (+6 more)

### Community 511 - ".panePathLookup"
Cohesion: 0.12
Nodes (5): Float, Set, SurfaceID, Void, TerminalPaneRegistry

### Community 513 - "DynamicInstanceBuffer"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.18
Nodes (11): Never, NSRegularExpression, Set, String, Task, URL, Void, WorkspaceSymbolIndex (+3 more)

### Community 515 - "RD"
Cohesion: 0.05
Nodes (30): CaseIterable, LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled, ExperienceMode (+22 more)

### Community 517 - "KouenCLI+Workbench.swift"
Cohesion: 0.13
Nodes (16): aXt(), dme(), fwn(), HUe(), IR(), KD(), nJ(), $o() (+8 more)

### Community 521 - ".daemonIsStale"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 523 - "fFe"
Cohesion: 0.17
Nodes (9): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 524 - "รายงานตรวจสอบการใช้หน่วยความจำสูงของ Kouen Terminal"
Cohesion: 0.11
Nodes (18): fix ที่ค้างอยู่ใน working tree (ยังไม่ commit), Terminal grid ไม่ใช่ก้อนใหญ่ที่ระบุชนิดได้, ก้อนหลักเกี่ยวข้องกับ RenderBox, การให้ DeepSeek ตรวจเพิ่ม, ผลตรวจ preview ที่แยกจากแอปหลัก, ผลตรวจแอปหลัก, ภาคผนวก 1 — fleet 9 ต.ค. (P54) กระทบ UI ไหม → กระทบ ตรงจุด, ภาคผนวก 2 — 18 ต.ค. `8c5e0c8d` P59 (agy session, **unreviewed**) (+10 more)

### Community 526 - "Kind"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 527 - ".show"
Cohesion: 0.16
Nodes (6): PluginLoader, String, ScriptAPI, String, JavaScriptCore, JSStringLiteralTests

### Community 528 - "worktree_review_dashboard.robot"
Cohesion: 0.15
Nodes (8): _Bt(), by(), e7e(), fst(), hxn(), lxn(), sBt, XWt()

### Community 529 - "NotchPanelController"
Cohesion: 0.10
Nodes (14): AgentNotchViewModel, Bool, CGFloat, Duration, NotchPanel, .canBecomeKey, .canBecomeMain, Bool (+6 more)

### Community 530 - "HarnessChrome"
Cohesion: 0.07
Nodes (18): Tab, AnyObject, ObjectIdentifier, TimeInterval, ZombieHoldRegistry, BrowserIntegrationController, PaneID, PaneContainerView (+10 more)

### Community 531 - "BrowserProgressLine"
Cohesion: 0.17
Nodes (4): bUt(), GUt, mUt(), _Q()

### Community 534 - "p12_mcp.robot"
Cohesion: 0.17
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

### Community 535 - "AgentNotification"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 537 - "NSObject"
Cohesion: 0.11
Nodes (6): KouenCLI, HistorySearchQueryTests, MemoCommandTests, URL, TaskCommandTests, WorkspaceCLITests

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.06
Nodes (34): .body, MainActor, Void, SessionDividerRowView, .init(coder:), SessionGroupHeaderRowView, .init(coder:), .init(frame:) (+26 more)

### Community 539 - "SavedLayoutIPCDaemonTests"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 540 - ".delay"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 544 - "KouenCLI+Workbench.swift"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 546 - "LegacySnapshot"
Cohesion: 0.21
Nodes (5): FlippedView, .isFlipped, NSScrollView, NSTextView, GitPanelViewDiffPopoverTests

### Community 547 - "NSObject"
Cohesion: 0.14
Nodes (16): ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool, Command (+8 more)

### Community 553 - "harness.resource"
Cohesion: 0.33
Nodes (3): String, WorkspaceID, DaemonSyncServiceBranchNotifyTests

### Community 554 - "eFe"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 556 - "MobileBridgeSpawnTests"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 557 - ".viewWillMove"
Cohesion: 0.47
Nodes (3): URL, TimeoutError, WorktreeLargeOutputRegressionTests

### Community 558 - "AutomationSummary"
Cohesion: 0.07
Nodes (24): CryptoKit, Foundation, KouenIPC, Cursor, Result, Bool, Date, Set (+16 more)

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 560 - ".feed(_:)"
Cohesion: 0.29
Nodes (6): .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8

### Community 561 - "CodexTranscriptTests"
Cohesion: 0.29
Nodes (5): AgentNotchPresentation, closed, open, peek, AgentNotchWindowActivator

### Community 562 - "BrowserResponsePayload"
Cohesion: 0.33
Nodes (5): Build, Release & Git Workflow, Build / Test / Run, Graphify refresh policy, Release packaging order, Worktree constraint

### Community 563 - "AgentNotchViewModel.swift"
Cohesion: 0.40
Nodes (4): Kouen Terminal — Domain Language, Language, Menu-bar icon, Relationships

### Community 565 - ".hold"
Cohesion: 0.22
Nodes (7): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 568 - ".installChromeBackground"
Cohesion: 0.05
Nodes (46): AgentChipView, .init(coder:), .intrinsicContentSize, .init(coder:), ChromeRole, sidebar, tabBar, Colors (+38 more)

### Community 569 - ".openRecentProject"
Cohesion: 0.26
Nodes (5): Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.08
Nodes (26): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+18 more)

### Community 571 - "ShellIntegrationTests"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 572 - "LayoutProbeView"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 574 - "FileTreeKeyboardNavigator"
Cohesion: 0.36
Nodes (6): HistorySearchEvidence, .body, .terms, Bool, String, Text

### Community 575 - ".toastErrorSummary"
Cohesion: 0.13
Nodes (3): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess

### Community 576 - ".handleWake"
Cohesion: 0.22
Nodes (5): RepoResolver, Bool, String, RepoResolverTests, String

### Community 579 - "main.swift"
Cohesion: 0.15
Nodes (11): AnimatablePair, NotchMaskAnimator, Bool, CGFloat, CGRect, NotchShape, .animatableData, CGFloat (+3 more)

### Community 580 - "ViInputMode"
Cohesion: 0.09
Nodes (10): MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, String, SurfaceID (+2 more)

### Community 582 - ".groupByRoot"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

### Community 583 - ".handleFrame"
Cohesion: 0.18
Nodes (10): DecodedWSFrame, Bool, ConnectionState, NWConnection, String, UInt8, WSFrameParseResult, frame (+2 more)

### Community 584 - "GUt"
Cohesion: 0.36
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 586 - ".parseWorktreePorcelain"
Cohesion: 0.20
Nodes (10): Agent Safety Net (Checkpoints, Verification, Write Guards), Claude Code Harness, Editor & LSP, How It Feels, Kouen Features, Mobile, Remote And Headless, Stack (+2 more)

### Community 589 - "Endpoint"
Cohesion: 0.15
Nodes (8): DispatchSource, DispatchQueue, DispatchSourceFileSystemObject, Int32, URL, Void, TranscriptFileWatcher, MobileBridgeTranscriptWatcherTests

### Community 591 - "main.swift"
Cohesion: 0.29
Nodes (6): Any, Error, MainActor, Sendable, String, Void

### Community 592 - "commit-push.sh"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Kouen-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 593 - "dO"
Cohesion: 0.50
Nodes (4): dO(), m8(), rfn(), zfn()

### Community 594 - "r2"
Cohesion: 0.67
Nodes (4): FVe(), hJ(), qVe(), Zme()

### Community 595 - "full-cycle.sh"
Cohesion: 0.70
Nodes (4): restart_daemon(), rollback_version_bump(), full-cycle.sh script, usage()

### Community 596 - ".userContentController"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 597 - "mBt"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 598 - ".testConcurrentKicksRestoreEveryTabsMagnification"
Cohesion: 0.10
Nodes (13): ObjectiveC, BrowserOcclusionTests, BrowserTabRepaintTests, RepaintCountingWebView, Any, Bool, Error, MainActor (+5 more)

### Community 599 - ".terminalHostIfExists"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

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

### Community 613 - "shim.c"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 622 - "sBt"
Cohesion: 0.17
Nodes (9): Array, FormatColor, none, palette, rgb, Bool, Element, String (+1 more)

### Community 623 - "jD"
Cohesion: 0.22
Nodes (6): ListeningPortScanner, Int32, Set, String, result, ListeningPortScannerTests

### Community 624 - "gmn"
Cohesion: 0.15
Nodes (11): PairingBox, .current, .isLockedOut, PendingPairing, Date, TimeInterval, TokenCheck, accepted (+3 more)

### Community 627 - "ActiveTabCloseDisposition"
Cohesion: 0.16
Nodes (8): OutputTrigger, OutputTriggerStore, Bool, String, OutputTriggerMatcher, .matches(in:patterns:), String, OutputTriggerMatcherTests

### Community 628 - "ReplayStep"
Cohesion: 0.21
Nodes (8): Container, .init(coder:), .init(frame:), NotchPulseHost, Context, NSCoder, NSHostingView, NSRect

### Community 629 - "graphify reference: query, path, explain"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 637 - "TerminalScrollbarView"
Cohesion: 0.08
Nodes (18): NSScrollView, NSWindow, Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent (+10 more)

### Community 638 - "FormatStringExtendedVariableTests"
Cohesion: 0.40
Nodes (3): calculate(), constructor(), mBt

### Community 641 - "[3.10.0] - 2026-06-27"
Cohesion: 0.25
Nodes (7): #kouen, #practice, #score, #shell, #total, #unix, #vim

### Community 645 - ".test_TC0801_FE_UT_closingEarlierTabKeepsBrowserLeafInItsOwnTab"
Cohesion: 0.23
Nodes (4): GroupedSessionTests, SessionGroup, Set, SurfaceID

### Community 646 - "KouenBrowserToolsTests"
Cohesion: 0.24
Nodes (5): RiskyCommandClassifier, Bool, NSRegularExpression, String, RiskyCommandClassifierTests

### Community 648 - "PtyDrainCeilingBenchmark"
Cohesion: 0.13
Nodes (16): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, .bytesPerWakeup, .mbps (+8 more)

### Community 659 - "LayoutTemplate"
Cohesion: 0.33
Nodes (6): h1t(), hae(), jgn(), pwn(), sfn(), _Ue()

### Community 661 - ".compute"
Cohesion: 0.18
Nodes (6): eKe(), irn(), mrn, _rn(), rrn(), srn()

### Community 662 - "I$e"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 664 - "P37 Phase G — Autocomplete (mobile bridge)"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 666 - "BrowserIntegrationController"
Cohesion: 0.17
Nodes (9): GitStatusProvider, OnceResume, Bool, Duration, String, TimeInterval, GitStatusProviderLargeOutputTests, URL (+1 more)

### Community 669 - "PaneLabelDaemonTests"
Cohesion: 0.29
Nodes (4): FileViewRouting, Bool, Set, String

### Community 671 - "AntigravityTranscriptTurnsTests"
Cohesion: 0.37
Nodes (3): AgentBrowserPaneTracker, Set, AgentBrowserPaneTrackerTests

### Community 675 - ".detect"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 678 - "CheckedContinuation"
Cohesion: 0.21
Nodes (4): StyledSegment, StatusLineWidthTests, StatusLineWidth, String

### Community 679 - "TriState"
Cohesion: 0.07
Nodes (12): SessionCoordinator, .selectWorkspace(_:), Bool, Double, PaneID, SessionID, String, SurfaceID (+4 more)

### Community 681 - ".tabIDsToNotify"
Cohesion: 0.17
Nodes (11): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile, regionEdit (+3 more)

### Community 682 - "Never"
Cohesion: 0.33
Nodes (6): Board and attention, Errors and LSP, File navigation, Search, Task runner, Workbench commands (IDE-like workflow)

### Community 684 - "AgentVectorIcon"
Cohesion: 0.47
Nodes (5): AgentIconArt, AgentVectorIcon, Bool, CGSize, String

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 686 - "P38 Phase E — Scripting Hooks — Dev Task Progress"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 690 - "Additional `kouen-cli` subcommands"
Cohesion: 0.40
Nodes (5): Additional `kouen-cli` subcommands, Agents, context and scratchpad, Daemon and diagnostics, Editor, LSP and setup, Sessions, tabs and recording

### Community 692 - ".init"
Cohesion: 0.05
Nodes (26): KouenCLITests, URL, CLIInstallLocator, DetachKeys, absent, invalid, parsed, OptionalUUID (+18 more)

### Community 694 - ".activePaneID"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 696 - ".closeFileTab"
Cohesion: 0.18
Nodes (10): Avoid, Colors, Components, Design Direction, Design System, Menu-bar icon preference, Projects, Session History (+2 more)

### Community 698 - "AgentVectorIcon"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: sidebar project discovered git worktrees detached stale removed refresh ProjectSidebar, Source Nodes

### Community 700 - ".closeActiveSession"
Cohesion: 0.38
Nodes (4): Result, ResultLine, String, UUID

### Community 702 - "PromptQueue"
Cohesion: 0.15
Nodes (6): PromptQueue, String, SurfaceID, Void, PromptQueueBar, NSWindow

### Community 703 - "WorktreeInfoSummary"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 709 - "String"
Cohesion: 0.08
Nodes (18): PendingVersionBanner, welcome, whatsNew, State, Bool, String, URL, VersionBannerStore (+10 more)

### Community 710 - "MainWindowController"
Cohesion: 0.11
Nodes (12): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+4 more)

### Community 713 - "AutomationScheduler"
Cohesion: 0.24
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 715 - "TerminalProgressReport"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 721 - "zpt"
Cohesion: 0.22
Nodes (6): String, URL, ThemeCatalogEmbedTests, .embedSwift, .repoRoot, .sourceJSON

### Community 724 - ".copy"
Cohesion: 0.57
Nodes (3): ProjectConfig, Bool, String

### Community 727 - "PromptQueueBar"
Cohesion: 0.12
Nodes (15): agy, claude, codex, copilot, hermes, kouen, __kouen_agy_next, __kouen_claude_next (+7 more)

### Community 728 - "TerminalHostView"
Cohesion: 0.08
Nodes (20): InputGate, .siblings, ReconnectLatch, .isTripped, SurfaceIO, .currentSubscription, Bool, CGFloat (+12 more)

### Community 731 - "Phase6KeysTests"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: SSETransport auth token isRunning

### Community 734 - "qut"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Kouen terminal product features agent workspace browser daemon session persistence remote control, Source Nodes

### Community 735 - "companion.test.mjs"
Cohesion: 0.22
Nodes (7): block, escFn, lineFilter, md, page, script, swift

### Community 736 - "graphify reference: add a URL and watch a folder"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 737 - ".resolve"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 738 - "t2e"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: session persistence focus routing browser disposal memory bounded checkpoint undo verify worktree, Source Nodes

### Community 745 - "p11_scripting.robot"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 750 - "ClipboardOSCTests"
Cohesion: 0.23
Nodes (13): kouen.bash script, agy(), claude(), codex(), copilot(), hermes(), kouen(), __kouen_agy_next() (+5 more)

### Community 755 - ".focusPaneDirectional"
Cohesion: 0.32
Nodes (4): PaneID, SessionGroup, Tab, first

### Community 756 - "graphify-refresh.sh"
Cohesion: 0.15
Nodes (12): ArtifactKind, html, image, markdown, text, AutomationSource, daemon, launchAgent (+4 more)

### Community 762 - ".buildSearchTree"
Cohesion: 0.67
Nodes (3): commit_with_graph(), prepare_graph_for_commit(), graphify-commit.sh script

### Community 763 - "start.sh script"
Cohesion: 0.50
Nodes (4): SelectionGranularity, character, line, word

### Community 770 - "create-dmg.sh"
Cohesion: 0.13
Nodes (14): BinaryInstaller.DetectionStatus, SetupStepView, .body, .canInstall, .hooksDetail, .hooksTone, .hooksValue, .isSuccess (+6 more)

### Community 772 - ".show"
Cohesion: 0.23
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

### Community 776 - "DecodedWSFrame"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: session history search ranking branch best matches, Source Nodes

### Community 781 - ".closeActiveTabWithConfirmation"
Cohesion: 0.22
Nodes (5): Bool, NSDraggingInfo, NSDragOperation, NSPasteboard, URL

### Community 795 - "SettingsFileSearchSection"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 797 - "CopyModeSideEffect"
Cohesion: 0.09
Nodes (38): blockquote(), blockTokens(), br(), checkbox(), codespan(), constructor(), de(), del() (+30 more)

### Community 802 - ".compute"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 803 - ".refreshPaneStyles"
Cohesion: 0.25
Nodes (4): _c(), Nn(), Pqe, qp()

### Community 809 - "WriteOrigin"
Cohesion: 0.18
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 810 - "Keep awake with the lid closed"
Cohesion: 0.50
Nodes (3): Caveats, Keep awake with the lid closed, Setup

### Community 814 - ".resolveAgentName"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: KouenPreviewHome environment key daemon launch at startup, Source Nodes

### Community 833 - "StdioTransport"
Cohesion: 0.15
Nodes (6): KouenMCPServer, String, MCPServer, String, StdioTransport, AsyncStream

### Community 834 - "AsyncCLIResultBox"
Cohesion: 0.15
Nodes (8): AsyncCLIResultBox, LSPDefinitionPayload, LSPStatusPayload, Error, Result, String, UInt64, URL

### Community 886 - "Switch To Session 1"
Cohesion: 0.21
Nodes (5): FDWatchdog, DispatchSourceTimer, String, TimeInterval, FDWatchdogTests

### Community 908 - "TargetSpec.swift"
Cohesion: 0.33
Nodes (6): Command, .targetKind, TargetKind, pane, session, window

### Community 909 - ".doCommandBy"
Cohesion: 0.05
Nodes (27): NSCursor, Bool, CAMetalDrawable, NSEvent, String, Bool, Selector, KouenTerminalSurfaceView (+19 more)

### Community 911 - "Q: How should CheckpointManager.restore preserve the user staged index?"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: How should CheckpointManager.restore preserve the user staged index?, Source Nodes

### Community 914 - "BlockSummary"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 917 - "Q: What commands build and test Kouen and prepare Graphify before commit?"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: What commands build and test Kouen and prepare Graphify before commit?

### Community 919 - "hmn"
Cohesion: 0.19
Nodes (13): _9n(), a9e(), avn(), c0t(), d8e(), hmn(), ovn(), p5n() (+5 more)

### Community 922 - "TextGrid"
Cohesion: 0.23
Nodes (5): String, TextGrid, .totalLines, .viewportRows, WordColumnRangeTests

### Community 925 - "SecureInputPromptScanner"
Cohesion: 0.33
Nodes (4): SecureInputPromptScanner, Bool, SecureInputPromptScannerTests, String

### Community 927 - "ViMode"
Cohesion: 0.17
Nodes (11): LinePos, end, firstNonBlank, start, ViDiagnosticNavigator, ViMode, insert, normal (+3 more)

### Community 929 - ".scan"
Cohesion: 0.26
Nodes (5): Bool, Set, String, WorkspaceRepositoryScanner, WorkspaceRepositoryScannerTests

### Community 930 - "SwarmTaskNodeWire"
Cohesion: 0.26
Nodes (6): SwarmFleetSnapshotWire, SwarmTaskNodeWire, Date, Double, String, UUID

### Community 931 - ".sendToAgent"
Cohesion: 0.33
Nodes (5): AgentBridge, AgentTarget, Bool, String, SurfaceID

### Community 932 - ".show"
Cohesion: 0.25
Nodes (6): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow

### Community 935 - ".snapshot"
Cohesion: 0.29
Nodes (3): KouenCompositor, GridCompositorCopyModeTests, String

### Community 940 - "AgentScanner"
Cohesion: 0.27
Nodes (4): AgentScanner, Bool, DispatchSourceTimer, TimeInterval

### Community 942 - "IssuePriority"
Cohesion: 0.20
Nodes (8): IssuePriority, .color, high, low, medium, none, .symbol, urgent

### Community 943 - "PaneRef"
Cohesion: 0.20
Nodes (10): PaneRef, bottom, byID, byIndex, last, left, next, previous (+2 more)

### Community 944 - "ClaudeSessionModeTests"
Cohesion: 0.24
Nodes (3): ClaudeSessionModeTests, URL, Void

### Community 947 - "CopyModeLine"
Cohesion: 0.25
Nodes (7): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, String

### Community 948 - "CodingKeys"
Cohesion: 0.22
Nodes (9): CodingKeys, createdAt, cwd, done, id, sessionID, status, title (+1 more)

### Community 950 - ".send"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 953 - "ThaiGrid"
Cohesion: 0.29
Nodes (5): ThaiClusterCopyTests, ThaiGrid, .columns, .totalLines, .viewportRows

### Community 959 - "TabContextCommand"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 962 - "DisplayWidth"
Cohesion: 0.33
Nodes (3): DisplayWidth, String, Unicode

### Community 972 - "DiffLineType"
Cohesion: 0.40
Nodes (4): DiffLineType, added, deleted, modified

### Community 973 - "Q: Project sidebar refresh rescan registered projects and remove deleted linked git worktree branch entries stale project metadata"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Project sidebar refresh rescan registered projects and remove deleted linked git worktree branch entries stale project metadata, Source Nodes

### Community 975 - "WrapperOptionBehavior"
Cohesion: 0.40
Nodes (5): WrapperOptionBehavior, keepScanning, matchValue, skipValue, stopScanning

### Community 976 - "Motion"
Cohesion: 0.40
Nodes (5): Motion, .reduce, .spring, Animation, Bool

### Community 977 - "gmn"
Cohesion: 0.50
Nodes (5): ehn(), gmn(), Jc(), pce(), s7e()

### Community 979 - "MouseEventKind"
Cohesion: 0.50
Nodes (4): MouseEventKind, drag, press, release

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

### Community 1832 - "Added"
Cohesion: 0.25
Nodes (7): Claude Code hook push (in-process Task subagent detection), Client UI indicator, Detection core (AgentDetector, pure logic), IPC / Tab plumbing, P38 Phase B — Subagent Visibility — Dev Task Progress, Status: Rewritten 2026-07-14 after original implementation (tasks 1-5) was lost to a concurrent git operation before commit. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 1914 - "P43 — Add Repo/Folder to Workspace"
Cohesion: 0.25
Nodes (7): Original overlay build (built 2026-07-14, gated green, then deleted 2026-07-15 mid live-test), P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress, Pivot — merge into the Recipes picker (2026-07-15), Stage 1-2 — Engine/surface plumbing (built 2026-07-14, unchanged by the pivot, still in use), Status: Implementation pivoted mid-phase from a standalone overlay to a merge into the existing, Summary, Thread grouping — Zed framing folded into the same picker (2026-07-15)

### Community 1977 - "Added"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: ProjectCategory FolderScanner ProjectDirectoryTree, Source Nodes

### Community 2100 - ".handleWake"
Cohesion: 0.10
Nodes (18): .exit, String, String, String, String, KouenCLI, SessionID, String (+10 more)

### Community 2176 - "Changed"
Cohesion: 0.29
Nodes (6): Locked decisions (user-confirmed), Logical Design, P38 Phase A — Cross-Agent Worktree Diff/Review Dashboard — Design, Strategic Design, Tactical Design, Verification gate (this phase)

### Community 2242 - "P42 — Workspace Sidebar Panels"
Cohesion: 0.29
Nodes (6): Logical Design, Next Step, P42 — Workspace Sidebar Panels, Parked (not in scope), Strategic Design, Tactical Design

### Community 2541 - "P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable"
Cohesion: 0.17
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 2573 - "P38 Phase D — Kitty Graphics Conformance Slice"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase D — Kitty Graphics Conformance Slice, Scope (locked), Tests

### Community 2633 - ".kouenBrowserReload"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua), Scope (locked), Tests

### Community 2642 - ".setPaneLabel"
Cohesion: 0.33
Nodes (5): Logical Design, Next Step, P43 — Add Repo/Folder to Workspace, Strategic Design, Tactical Design

### Community 3131 - "P38 Phase D — Kitty Conformance — Dev Task Progress"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 3132 - "P38 Phase E — Scripting Hooks — Dev Task Progress"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 3896 - "View"
Cohesion: 0.09
Nodes (34): ButtonStyle, CommandRow, .body, GlassCard, .body, GlassPrimaryButtonStyle, GlassSecondaryButtonStyle, GlassSmallButtonStyle (+26 more)

## Knowledge Gaps
- **2417 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+2412 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1250 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Work-memory lessons

**Known dead ends** — questions that led nowhere; don't re-derive.
- "KouenPreviewHome environment key daemon launch at startup" -> `KouenPaths`

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `.testDataFrameEncodeVsJSONBase64Output` to `.setAttribute`, `callingPaneTarget`, `graphify reference: extra exports and benchmark`, `DynamicInstanceBuffer`, `EngineConformanceTests`, `IPCRequest`, `AgentNotchRootView`, `.jumpToBlock`, `PerformanceBenchmarks`, `.viewDidLoad`, `Changed`, `KittyKeyboardTests`, `VTParser`, `HarnessTerminalSurfaceView`, `.applyPreedit`, `NotchPanelController`, `.init`, `HarnessTerminalSurfaceView`, `.readGrid(scrollbackOffset:)`, `SessionGroupHeaderRowView`, `Harness tmux-style capabilities`, `RGBColor`, `.init`, `.bufferLine`, `.addTab`, `Equatable`, `LegacySnapshot`, `.characterIndex`, `KouenCLI+Workbench.swift`, `String`, `TerminalColorGamut`, `HarnessSettings`, `CodingKeys`, `HarnessSidebarPanelViewController.swift`, `RenderSchedulerTests`, `eFe`, `.viewWillMove`, `AutomationSummary`, `.buildCommand`, `.feed(_:)`, `.normalizedKey`, `Added`, `.keyEvent`, `MobileBridgeSpawnTests`, `.handleWake`, `HarnessSplitView`, `TabCell`, `.openRecentProject`, `CommandHistorySearchController`, `PasteBufferStore`, `FrecencyDirectoryStore`, `FileTreeKeyboardNavigator`, `HarnessCLI+Server.swift`, `.text`, `Completed Plans Archive`, `worktree_isolation_cli.robot`, `.handleFrame`, `XCTestCase`, `[2.6.0] - 2026-06-13`, `OptionStore`, `.parse`, `Added`, `HarnessDesign`, `.firstMatch`, `LSPDiagnostic`, `TerminalGridCell`, `AttachInputBatcher`, `shim.c`, `FormatContextDaemonTests`, `.dispatch`, `ScriptRuntime.swift`, `DaemonLauncher`, `AnyCodable`, `Recipe`, `Changelog`, `domain-design.md`, `DamageTrackingTests`, `sBt`, `jD`, `gmn`, `code:text (:workbench start swift)`, `.firstWaitingTab`, `WorkspaceFileTreeView`, `Added`, `Changed`, `String`, `HistoryRingBuffer`, `TerminalScrollbarView`, `GlyphAtlas`, `code:block1 (SessionCoordinator.snapshot ──┐)`, `SwiftUI`, `.load`, `CommandTarget`, `.startWatching`, `PtyDrainCeilingBenchmark`, `แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)`, `.testPaneLeafLegacyDecodeBackfillsSurfaceTabs`, `CopyModeGridSource`, `PaneStyleSet`, `AsciiFastPathTests`, `Added`, `What You Must Do When Invoked`, `LiveResizeTests`, `Int`, `ThaiCombiningMarkTests`, `Harness Terminal — IDE Sidebar Feature Branch`, `MatchCategory`, `What You Must Do When Invoked`, `Workspace`, `CommandPromptController`, `ActiveTabCloseDisposition`, `CheckedContinuation`, `TriState`, `Fixed`, `URLDetection`, `.decodeKeySpec`, `[1.5.1] - 2026-06-06`, `P38 Phase E — Scripting Hooks — Dev Task Progress`, `BinaryRefresherTests`, `Added`, `.init`, `GridCompositorTests`, `LSPServerRegistry`, `SessionSnapshot`, `AppDelegate`, `P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client`, `PromptQueue`, `user-stories.md`, `GlyphRasterizer`, `BinaryInstaller`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `ResizeHUDView`, `String`, `.classify`, `BinaryInstallerVersionTests`, `Harness keybindings`, `.activePaneID`, `scheduleRender`, `PaneTarget`, `.lines`, `TerminalHostView`, `GridCompositor`, `ScrollbackFile`, `Prompt`, `CellColorResolver`, `FileChangeWatcher`, `SSHTunnelManagerTests`, `ExternalOpenKind`, `WorkbenchCommand`, `Added`, `PaneBorderStatus`, `[3.5.1] - 2026-06-20`, `.focusPaneDirectional`, `FileNode`, `.make`, `ReflowPreviewTests`, `HarnessTerminalSurfaceWorkerTests`, `SessionCoordinator`, `NSViewRepresentable`, `Split Right`, `release-hotfix.sh`, `workspace`, `WindowTitleStripView`, `ThemeFileServiceTests`, `.show`, `.install`, `.path`, `DefaultTerminalManager`, `WindowSession`, `SGRMouseEvent`, `KeySpec`, `[2.5.0] - 2026-06-12`, `SyntaxTextView`, `BlockTintOverlay`, `TerminalScrollbarView`, `FormatColor`, `click_ui_element`, `AgentHookStrategy`, `StatusLineWidthTests`, `Process`, `JSONDecoder`, `.compute`, `Fixes Applied (layered)`, `GitHubCLIClient`, `settings.json`, `PaneNode`, `HarnessPaths.swift`, `.parse`, `ThemeDiagnostics`, `PaletteFooter`, `ViPathTokenTests`, `Send Ex Command`, `Phase6KeysTests`, `Bug: Tab-Switch Black Screen`, `AgentSnapshot`, `Terminal AI Chat (⌘I inline overlay)`, `Memory — harness-terminal`, `Focus Persistence — Per-Session-Tab Pane Focus (RL-043)`, `UInt64`, `DesktopNotifier`, `AsyncCLIResultBox`, `WorkspaceSymbolIndex`, `FloatingPaneController`, `worktree_isolation.robot`, `.theme`, `README.md`, `Added`, `ImageProtocolTests.swift`, `CommandExecutionError`, `.contentVC`, `Foundation`, `code:bash (harness-cli install-hooks pi)`, `[2.2.3] - 2026-06-09`, `DaemonLifecycleTests`, `Contents.json`, `Background Polling & Snapshot Fanout — P22`, `Architecture Decisions — harness-terminal`, `Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)`, `.bufferLine`, `.handleCat`, `[3.5.1] - 2026-06-20`, `OcclusionTests`, `RGBColor`, `generate-cheatsheet.js`, `Consumers`, `Tab`, `Git Panel`, `.encode`, `Switch To Session 1`, `.install`, `ScrollReuseTests`, `.run`, `SurfaceProgressTrackerTests.swift`, `MCPServer`, `PromptQueue`, `NSTextField Leak in BoardViewController (P20 Performance)`, `INDEX.md`, `UI Automation — Robot Framework (P18)`, `AppKit + Metal Patterns`, `.doCommandBy`, `.init`, `BlockSummary`, `PresentAttempt`, `.setCellPixelSize`, `TextGrid`, `javascript.json`, `markdown.json`, `.refreshSurfaceMetadata`, `.scan`, `RealPtyLifecycleTests`, `SwarmTaskNodeWire`, `yaml.json`, `.currentSize`, `SixelDecoder`, `.snapshot`, `.navigateCurrentFile`, `BoardCardView`, `PaneRef`, `PathToken`, `CopyModeLine`, `SessionEditor`, `LegacySnapshot`, `ThaiGrid`, `GroupedSessionDaemonTests`, `PaletteMode`, `mobile_bridge_pairing_bugs.robot`, `DisplayWidth`, `.run`, `SessionCoordinator.swift`, `PaneOutputWaiter`, `DiffLineType`, `.worktreeList`, `.init`, `.resize`, `Never`, `TerminalTabBarView`, `HarnessOnboarding`, `.hitTest`, `.isRisky`, `CopilotAdapter`, `.testKouenRendererFixtureLigatureShapingPathReportsPlausibleGlyphs`, `TabPillView`, `bC`, `.update`, `.open`, `.bind`, `.runGitDiff`, `Kouen Terminal — System Architecture`?**
  _High betweenness centrality (0.230) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `Terminal AI Chat (⌘I inline overlay)` to `AgentSessionSummary.swift`, `String`, `worktree_isolation_cli.robot`, `TriState`, `.agentName`, `.id`, `.handleCat`, `Consumers`, `.testDataFrameEncodeVsJSONBase64Output`, `NotchPanelController`, `PaneNode`, `HarnessTerminalSurfaceView`, `SplitPaneCoordinator`, `StatusDotView`?**
  _High betweenness centrality (0.179) - this node is a cross-community bridge._
- **Why does `fbt()` connect `.parse` to `PaneContainerView`, `GitPanelView.swift`, `TriState`, `CopyModeAction`, `SplitPaneCoordinator`, `Added`?**
  _High betweenness centrality (0.100) - this node is a cross-community bridge._
- **Are the 19 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `OutputTriggerMatcher`) actually correct?**
  _`KouenTerminalSurfaceView` has 19 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _2437 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.11895161290322581 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.08644067796610169 - nodes in this community are weakly interconnected._