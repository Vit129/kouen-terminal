# Graph Report - kouen-terminal  (2026-10-29)

## Corpus Check
- 928 files · ~1,037,624 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 19905 nodes · 57656 edges · 2777 communities (1505 shown, 1272 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8792 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `8ceb38ff`
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
2. `Command` - bridges 102 areas (108 edges)
3. `AgentKind` - bridges 85 areas (178 edges)
4. `t()` - bridges 81 areas (253 edges)
5. `IPCResponse` - bridges 78 areas (103 edges)
6. `KouenTerminalSurfaceView` - bridges 76 areas (345 edges)
7. `KouenPaths` - bridges 68 areas (150 edges)
8. `NSView` - bridges 66 areas (189 edges)
9. `KouenGridTerminal` - bridges 65 areas (117 edges)
10. `SessionCoordinator` - bridges 62 areas (235 edges)

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

## Communities (2777 total, 1272 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.12
Nodes (15): SavedLayoutStore, Bool, String, URL, UUID, PaneLayoutShape, branch, leaf (+7 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.02
Nodes (469): f(), l, V, z(), _4n(), _5e(), _7n(), _9n() (+461 more)

### Community 2 - ".handleNormal"
Cohesion: 0.19
Nodes (10): BrowserOkAck, Sendable, T, ConnectionState, DraftPRAck, ErrorAck, FileAttachedAck, NWConnection (+2 more)

### Community 3 - "Changed"
Cohesion: 0.10
Nodes (8): Bool, String, UInt8, TerminalEmulator, .captureLines(fromLine:toLine:), .onSetClipboard, ImageProtocolTests, String

### Community 4 - "EngineConformanceTests"
Cohesion: 0.08
Nodes (21): DaemonClient, Int32, TimeInterval, UUID, ClaudeCodeHarnessIPCTests, String, URL, ConcurrentIndexSet (+13 more)

### Community 5 - "IPCRequest"
Cohesion: 0.07
Nodes (26): String, UInt16, Data, DecodedReplyFrame, output, reply, DecodedRequestFrame, input (+18 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.08
Nodes (23): Logger, OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, .event(_:), .interval(_:_:) (+15 more)

### Community 7 - "Command"
Cohesion: 0.10
Nodes (29): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+21 more)

### Community 8 - "LSPMessage"
Cohesion: 0.10
Nodes (25): DaemonSubscription, .start(onData:onEnd:buffered:), .start(onResponse:onEnd:), Bool, UInt64, Void, sysClose(), .onResponse (+17 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.09
Nodes (15): ImagePlacementSnapshot, SemanticMark, Bool, TerminalColorRole, background, cursor, foreground, palette (+7 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.07
Nodes (42): Int, DecodedImage, .byteCount, UInt8, KouenGridTerminal, TerminalGridSnapshot, .currentRawSelection, .currentSelectionRegion (+34 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.67
Nodes (3): AsyncCLIResultBox, Error, Result

### Community 12 - "Changed"
Cohesion: 0.21
Nodes (3): DispatchWorkItem, UnsafeMutableRawPointer, GitPanelViewFSEventFilterTests

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.08
Nodes (36): blockquote(), br(), checkbox(), codespan(), constructor(), de(), del(), em() (+28 more)

### Community 14 - "VTParser"
Cohesion: 0.16
Nodes (9): StringKind, apc, dcs, UInt8, UnsafeBufferPointer, VTParser, .feed(_:), VTParserHandler (+1 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.03
Nodes (49): .tab(for:), DaemonCommandExecutor, Command, .init(forTesting:), UUID, Void, BellScanState, esc (+41 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.10
Nodes (12): .agentColorBinding, colors, PerformanceBenchmarks, SurfaceMainThreadStallSample, Bool, Double, MTLDevice, MTLTexture (+4 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.19
Nodes (11): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, .selectedHost (+3 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.09
Nodes (18): Selector, .init(frame:), Kind, primary, secondary, KouenPillButton, .init(title:kind:), .isHovered (+10 more)

### Community 19 - "SpecialKey"
Cohesion: 0.21
Nodes (15): CustomStringConvertible, atomicWrite(), backupCorruptFile(), ensureDirectories(), fnv1aHex(), KouenPathsError, .description, socketPathTooLong (+7 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.20
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.07
Nodes (25): TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid, .gridOriginPointsX (+17 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.01
Nodes (557): _1n(), _2t(), _3e(), _3n(), _4e(), _6e(), _8n(), _9e() (+549 more)

### Community 24 - ".request"
Cohesion: 0.11
Nodes (15): .addSurface(tabID:paneID:), .addSurface(to:paneID:surfaceID:cwd:), .tab(containingPaneID:), .tab(forSurfaceKey:), .tabIndex(surfaceKey:), .tabIndex(tabID:), .tabIndex(workspaceID:tabID:), Bool (+7 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.06
Nodes (11): Bool, CAMetalDrawable, NSEvent, String, NSMenuItem, String, .testingPendingResize, T (+3 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.08
Nodes (25): AgentHistoryFTSIndex, .deleteSession(sessionID:), .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:surfaceTag:topicSegments:), .needsReindex(sessionID:mtime:fileSize:), .pruneMissingSessions(validTranscriptPaths:), .saveRecord(_:mtime:fileSize:), .saveRecordsBatch(_:), .search(query:limit:) (+17 more)

### Community 27 - "RGBColor"
Cohesion: 0.15
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 28 - ".parse"
Cohesion: 0.08
Nodes (12): Bool, NSDraggingInfo, NSDragOperation, ImageDecoder, Bool, NSDraggingInfo, NSDragOperation, NSPasteboard (+4 more)

### Community 29 - "Added"
Cohesion: 0.14
Nodes (12): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, AutomationScheduler (+4 more)

### Community 30 - "Notification"
Cohesion: 0.15
Nodes (29): Ame(), aQt(), aze(), een(), eVe(), eXt(), hXt(), HYt() (+21 more)

### Community 31 - "Sendable"
Cohesion: 0.14
Nodes (12): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+4 more)

### Community 32 - ".addTab"
Cohesion: 0.08
Nodes (28): .body, FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body (+20 more)

### Community 33 - "Equatable"
Cohesion: 0.09
Nodes (19): AnyObject, DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor (+11 more)

### Community 34 - "DaemonClient"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 35 - "MenuTarget"
Cohesion: 0.06
Nodes (51): AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, CodingKeys, excludedPaths (+43 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.14
Nodes (28): Cleanup Test Repo, Close Isolated Session Keeps Dirty Worktree, Close Isolated Session Removes Clean Worktree, Close One Isolated Does Not Affect Another, Close Session With Split Panes Removes Worktree, Create Isolated Session, Create Isolated Session Via CLI, Get Active Pane (+20 more)

### Community 37 - "String"
Cohesion: 0.06
Nodes (30): LSPFileSession, Never, String, Task, URL, Void, .lspPosition(characterOffset:), .lspPosition(for:) (+22 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.16
Nodes (33): aQ(), bqt(), cbe(), DD(), dqt(), Dr(), Eqt(), Fa() (+25 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.24
Nodes (8): ProjectDropTarget, .init(coder:), .init(frame:), NSCoder, NSDraggingInfo, NSDragOperation, NSRect, URL

### Community 41 - "CodingKeys"
Cohesion: 0.07
Nodes (31): ClientRecord, CountBox, DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed (+23 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.14
Nodes (18): CommandParseError, .description, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand (+10 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.05
Nodes (20): KouenCore, AgentScanner, Bool, DispatchSourceTimer, TimeInterval, Phase67Tests, LegacySnapshot, LegacyWorkspace (+12 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.10
Nodes (18): Process, SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, SSHTunnelManager (+10 more)

### Community 46 - ".buildCommand"
Cohesion: 0.06
Nodes (17): input, .readJSONLLines(from:fromOffset:), ClaudeSessionLocator, ClaudeTranscriptLine, Role, assistant, user, Any (+9 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.15
Nodes (8): CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16, UInt8, CharacterWidthTests

### Community 48 - "HookEvent"
Cohesion: 0.06
Nodes (35): Executor, Hook, HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane (+27 more)

### Community 49 - "DaemonServer"
Cohesion: 0.18
Nodes (15): .modifierFlags, NSEvent, BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, Keybinding (+7 more)

### Community 50 - "Added"
Cohesion: 0.12
Nodes (13): TerminalDamage, RenderColor, MetalRendererTests, .makeRenderer(device:atlasSize:atlasMaxPages:), RenderedFixture, Bool, MTLDevice, MTLTexture (+5 more)

### Community 51 - ".keyEvent"
Cohesion: 0.08
Nodes (31): ColorKind, .base, bg, fg, underline, ComposedCell, .asGridCell, .cluster (+23 more)

### Community 52 - "Fixed"
Cohesion: 0.09
Nodes (18): .init(coder:), .init(coder:), BrowserTabButton, .init(coder:), .init(title:isActive:onSelect:onClose:), DesignModeElementInfo, DesignModePopoverViewController, .init(coder:) (+10 more)

### Community 53 - "Added"
Cohesion: 0.11
Nodes (25): al(), ax(), bdn(), bIn(), d7e(), dOt(), f6n(), fLt() (+17 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.11
Nodes (23): AnyTransition, AgentNotchPeekEvent, AgentNotchRootView, .body, .bottomRadius, .closedAccessibilityLabel, .closedTransition, .closedView (+15 more)

### Community 55 - "TabCell"
Cohesion: 0.15
Nodes (7): AnyCodable, JSONRPCError, Bool, Int32, Pipe, String, ToolRegistry

### Community 56 - "NSPanel"
Cohesion: 0.02
Nodes (158): _0t(), _5n(), _6n(), a2t(), a6(), a8n(), agn(), agt() (+150 more)

### Community 57 - "BellScanState"
Cohesion: 0.16
Nodes (7): DaemonLifecycle, Bool, pid_t, String, URL, DaemonLifecycleTests, URL

### Community 58 - "PasteBufferStore"
Cohesion: 0.10
Nodes (38): MTLClearColor, MTLCommandBuffer, MTLLibrary, MTLRenderCommandEncoder, MTLRenderPipelineState, BgInstance, CursorCacheKey, .invertsGlyph (+30 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.08
Nodes (23): DetachedPaneOverlay, .init(coder:), .init(frame:style:), OutputCoalescer, ReconnectLatch, .isTripped, Style, detached (+15 more)

### Community 60 - "ViEngine"
Cohesion: 0.02
Nodes (348): m(), pe(), r, X(), A(), code(), R(), a() (+340 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.08
Nodes (15): GitAheadBehind, GitParsers, String, GitRunner, GitResult, String, TimeInterval, URL (+7 more)

### Community 62 - "ComposedCell"
Cohesion: 0.18
Nodes (11): SwarmSpawnSpec, CallRecorder, .cancelCalls, .closeCalls, .harnessCalls, .surfaceCalls, SwarmWorkerManagerTests, Bool (+3 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 64 - ".text"
Cohesion: 0.13
Nodes (10): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, String (+2 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.13
Nodes (16): .init(entry:), KouenMotion, StatusDotView, .init(diameter:), .style, Style, accent, agent (+8 more)

### Community 67 - "String"
Cohesion: 0.14
Nodes (15): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+7 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.22
Nodes (5): Bool, Character, NSRange, NSTextView, String

### Community 69 - ".compose"
Cohesion: 0.12
Nodes (11): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, osc (+3 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.08
Nodes (41): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+33 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 72 - "XCTestCase"
Cohesion: 0.12
Nodes (21): AS(), bvt(), cc(), d2(), dce(), e6(), eOn(), ev() (+13 more)

### Community 73 - "README.md"
Cohesion: 0.50
Nodes (3): Hermes → Kouen, One-line install, Required: approve the hook

### Community 74 - "[2.6.0] - 2026-06-13"
Cohesion: 0.02
Nodes (157): _1t(), a0n(), a3n(), a6n(), a9n(), ag(), b1t(), bC() (+149 more)

### Community 75 - "OptionStore"
Cohesion: 0.11
Nodes (14): StatusLineView, .init(coder:), CGFloat, Never, NSAttributedString, NSCoder, NSColor, NSLayoutConstraint (+6 more)

### Community 76 - ".parse"
Cohesion: 0.16
Nodes (11): Equatable, PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab (+3 more)

### Community 78 - "Added"
Cohesion: 0.16
Nodes (8): CustomEndpointTester, Result, Bool, String, URL, CustomEndpointTesterTests, URLRequest, URLSession

### Community 79 - "HarnessDesign"
Cohesion: 0.13
Nodes (13): MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem, SessionGroup (+5 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 82 - ".firstMatch"
Cohesion: 0.07
Nodes (16): NSCursor, KouenTerminalSurfaceView, .receive(_:), DispatchSemaphore, DispatchWorkItem, String, FluidityBenchmarks, NSWindow (+8 more)

### Community 83 - "LSPClient"
Cohesion: 0.15
Nodes (17): CUe(), cXt(), GYt(), H7(), hqt(), kCn(), kUe(), LUe() (+9 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.08
Nodes (26): .windowSection, KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:fileSearchRoots:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:), .scrollbackLines, LegacyKouenSettingsCodingKeys, commandFinishedNotifications, tmuxControlsEnabled (+18 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.30
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 86 - "HarnessPaths"
Cohesion: 0.11
Nodes (15): FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect, String, URL (+7 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.15
Nodes (14): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+6 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.06
Nodes (28): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+20 more)

### Community 89 - ".cursorPos"
Cohesion: 0.10
Nodes (7): .setupPrompt, hooks, AgentHookInstallerTests, String, URL, GitHubCLIClientTests, String

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.13
Nodes (12): pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal, Int32 (+4 more)

### Community 91 - "TerminalModes"
Cohesion: 0.09
Nodes (12): NSRangePointer, Any, NSAttributedString, NSRange, NSRect, String, UInt64, CellOverlayTests (+4 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.16
Nodes (5): SQLite3, AgentHistoryMultiAgentCoverageTests, Bool, String, URL

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.17
Nodes (8): ClaudeCloudSessionStore, Entry, Date, String, TimeInterval, URL, String, Void

### Community 94 - "AttachInputBatcher"
Cohesion: 0.20
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 95 - "shim.c"
Cohesion: 0.12
Nodes (19): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerFooter, .body, DirectoryPickerModel (+11 more)

### Community 96 - "Harness Usage"
Cohesion: 0.17
Nodes (8): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, String, PaneStyleTests

### Community 97 - "PaneContainerView"
Cohesion: 0.02
Nodes (159): a(), b(), c(), d(), e(), g(), h(), I() (+151 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.11
Nodes (19): DiffLineType, added, deleted, modified, Notification.Name, ObserverToken, NSCoder, NSObjectProtocol (+11 more)

### Community 99 - ".dispatch"
Cohesion: 0.16
Nodes (12): FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID, KouenFeature (+4 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.08
Nodes (23): Error, LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed, serverNotExecutable, AsyncStream (+15 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.12
Nodes (14): AsyncRunCoordinator, OutputBuffer, ProcessResult, .isSuccess, ProcessRunner, Bool, CheckedContinuation, DispatchWorkItem (+6 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.09
Nodes (23): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+15 more)

### Community 104 - "Recipe"
Cohesion: 0.05
Nodes (56): ch(), cse(), cvt(), d1n(), d1t(), dV(), e4e(), e6n() (+48 more)

### Community 105 - "Changelog"
Cohesion: 0.20
Nodes (10): .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didStartProvisionalNavigation:), LoadCompletionState, Bool, CheckedContinuation, Double, Error (+2 more)

### Community 106 - "domain-design.md"
Cohesion: 0.10
Nodes (17): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent, ScrollbackFile (+9 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.13
Nodes (11): KouenCompositor, PaneRect, PaneID, SurfaceID, GridCompositor, GridCompositorCopyModeTests, String, GridCompositorTests (+3 more)

### Community 108 - ".resolve"
Cohesion: 0.13
Nodes (11): String, ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID, String (+3 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.11
Nodes (11): SGRMouse, SGRMouseEvent, Bool, UInt8, MouseEventKind, drag, press, release (+3 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.21
Nodes (5): CopyModeReducerTests, FakeGrid, .totalLines, Set, String

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.07
Nodes (12): TerminalGridCell, HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor, Bool, ClosedRange (+4 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.09
Nodes (15): FlippedView, .isFlipped, GitPanelView, .removeWorktreeAction(_:), Any, NSButton, NSColor, NSMenuItem (+7 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.14
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 115 - ".encode"
Cohesion: 0.23
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 116 - "SessionGroup"
Cohesion: 0.10
Nodes (16): AgentBrowserPaneTracker, SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, SessionID, Set (+8 more)

### Community 117 - "PaneNode"
Cohesion: 0.06
Nodes (21): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+13 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.20
Nodes (7): AgentRoutingRuleStore, Bool, String, URL, UUID, AgentRoutingRuleStoreTests, URL

### Community 119 - "Harness command reference"
Cohesion: 0.12
Nodes (17): Agent safety CLI (`kouen-cli`), Attaching from a plain terminal, Bindings, Buffers (paste store), Composition, Hooks, Inspection (CLI / control mode), Kouen command reference (+9 more)

### Community 120 - "Added"
Cohesion: 0.05
Nodes (44): AgentHistoryDateGroup, older, .sortOrder, thisWeek, today, yesterday, AgentSessionHistoryModel, .extraRecordsShown (+36 more)

### Community 121 - "Changed"
Cohesion: 0.04
Nodes (22): DispatchSource, KouenDaemonCore, DispatchQueue, DispatchSourceFileSystemObject, Int32, URL, Void, TranscriptFileWatcher (+14 more)

### Community 123 - "Pipe"
Cohesion: 0.13
Nodes (16): TrackedIssue, IssueTrackerPanelView, .body, .filteredIssues, .statusBannerText, String, GitHubSearchResult, IssueFetchStatus (+8 more)

### Community 124 - "String"
Cohesion: 0.06
Nodes (31): TerminalModes, InputEncoder, .encode(_:modifiers:event:modes:), .encode(text:modifiers:modes:), .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release (+23 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, S (+2 more)

### Community 126 - ".path"
Cohesion: 0.16
Nodes (14): AgentMark, .body, Scanner, .atEnd, SVGPath, Bool, CGFloat, CGPoint (+6 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.17
Nodes (19): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), GlyphKey (+11 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.08
Nodes (27): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, PaletteFooter, .body (+19 more)

### Community 129 - "SwiftUI"
Cohesion: 0.18
Nodes (4): FilePreviewCoordinator, FileTabID, Set, String

### Community 131 - ".install"
Cohesion: 0.24
Nodes (3): TabID, WorkspaceID, GitPanelViewWorktreeNavigationTests

### Community 132 - "AgentHookInstaller"
Cohesion: 0.16
Nodes (11): AgentDetection, AgentDetector, MatchSource, ownProcess, wrapperLaunch, RawMatch, Date, Int32 (+3 more)

### Community 133 - ".load"
Cohesion: 0.14
Nodes (19): EndpointConnector, Int32, String, decodeBoundedCString(), ignoreSIGPIPE(), makeUnixStreamSocket(), setNoSigPipe(), CChar (+11 more)

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.19
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 135 - "CommandTarget"
Cohesion: 0.11
Nodes (9): Bool, NSEvent, NSRange, NSString, URL, Void, SyntaxDefinitionTarget, SyntaxTextView (+1 more)

### Community 136 - ".startWatching"
Cohesion: 0.21
Nodes (4): CommandTarget, String, UUID, TargetSpecTests

### Community 137 - "ActivePaneService"
Cohesion: 0.11
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.05
Nodes (13): SessionCoordinator, .selectWorkspace(_:), Bool, Double, PaneID, SessionID, String, SurfaceID (+5 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.21
Nodes (9): Scanner, .atEnd, SVGPathParser, Bool, CGPath, CGPoint, Character, Set (+1 more)

### Community 140 - "Added"
Cohesion: 0.20
Nodes (4): AgentTableEntry, Bool, Set, String

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.12
Nodes (9): .isHidden, .removeWorktreeAction(path:), GitResult, Bool, GitResult, String, ValidateOutcome, WorktreeEntry (+1 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.08
Nodes (31): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, .body, PaletteMode (+23 more)

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.08
Nodes (27): AnyView, Container, .init(coder:), .init(frame:), NotchOverviewRow, .approvalControls, .background, .badge (+19 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 146 - "DecodedImage"
Cohesion: 0.09
Nodes (15): ContextResolutionEngine, Bool, String, Bool, String, TokenGuard, EnvironmentStore, Persisted (+7 more)

### Community 147 - "FileTreeWatcher"
Cohesion: 0.57
Nodes (3): ProjectConfig, Bool, String

### Community 148 - "TriState"
Cohesion: 0.09
Nodes (29): a4e(), b2(), e3(), ece(), ert(), gIn(), goe(), gV() (+21 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.27
Nodes (4): tool, KouenDaemonToolsTests, String, URL

### Community 151 - ".evaluate"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 152 - "Added"
Cohesion: 0.15
Nodes (11): copyMode, esc(), fs, globalShortcuts, KEYBINDINGS, prefixTable, renderTable(), ROOT (+3 more)

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.10
Nodes (15): UnsafeBufferPointer, .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8, TerminalCellWidth (+7 more)

### Community 154 - "LiveResizeTests"
Cohesion: 0.08
Nodes (12): SessionGroup, String, KouenSidebarPanelViewController, NSMenuItem, SessionGroup, String, NSMenu, NSMenuItem (+4 more)

### Community 155 - "Int"
Cohesion: 0.11
Nodes (13): FileFuzzyMatcher, FileSearchRootScanner, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool (+5 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.08
Nodes (25): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, .onSelect, .body (+17 more)

### Community 157 - "Added"
Cohesion: 0.21
Nodes (9): Bool, CGFloat, Character, NSEvent, NSRange, NSString, NSTextView, String (+1 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 159 - "MatchCategory"
Cohesion: 0.05
Nodes (26): CornerInfo, EditorDividerView, HitTestPassthroughView, KouenSplitView, .dividerColor, .dividerThickness, .init(coder:), PaneDragGripView (+18 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.11
Nodes (21): FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose, FileTabPillView (+13 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.12
Nodes (10): .readJSONLLines(from:), AntigravitySessionLocator, AntigravityTranscriptLine, Bool, Int32, NSRegularExpression, String, URL (+2 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.07
Nodes (18): NSResponder, NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent (+10 more)

### Community 163 - "Workspace"
Cohesion: 0.20
Nodes (4): KouenPaths, KouenSettingsTests, URL, Void

### Community 164 - "CommandPromptController"
Cohesion: 0.12
Nodes (21): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, IssueInfo (+13 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.28
Nodes (7): SSETransport, .isRunning, .listener, Bool, NWConnection, String, UInt16

### Community 166 - "LiveSession"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.30
Nodes (4): TaskStore, tasks, URL, TaskStoreTests

### Community 168 - "Added"
Cohesion: 0.07
Nodes (21): .agentChipsView, AgentUsage, .contextTokens, .init(from:), .init(inputTokens:outputTokens:cacheReadTokens:cacheWriteTokens:thinkingTokens:totalCostUSD:), .shortSummary, CodingKeys, cacheReadTokens (+13 more)

### Community 169 - "Fixed"
Cohesion: 0.29
Nodes (8): AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand, Bool, Set

### Community 170 - "URLDetection"
Cohesion: 0.10
Nodes (8): Bool, Range, Set, String, URLDetection, StringProtocol, Substring, EngineConformanceTests

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.10
Nodes (16): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+8 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.10
Nodes (18): .agentInfo(forWorktreePath:), .agentInfo(forWorktreePath:tabs:), Tab, Reason, errored, finished, needsInput, RowState (+10 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.10
Nodes (6): KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), SpawnedAgentSurface, ISO8601DateFormatter, String, UUID

### Community 175 - "RGBColorTests"
Cohesion: 0.23
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 176 - "Added"
Cohesion: 0.06
Nodes (12): NWEndpoint, Bool, NWListener, Sendable, String, UInt16, MobileBridgeServer, PipeBuffer (+4 more)

### Community 177 - ".rects"
Cohesion: 0.11
Nodes (8): AgyAdapter, Result, ResultLine, String, UUID, CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 178 - "InlineAICompletionView"
Cohesion: 0.22
Nodes (10): CopyModeGridSource, .promptRows, ClosedRange, CopyModeReducer, Bool, Character, NSRegularExpression, Range (+2 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.26
Nodes (6): Bool, NSRange, NSString, NSTextView, String, unichar

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.05
Nodes (26): KouenCLITests, URL, CLIInstallLocator, DetachKeys, absent, invalid, parsed, OptionalUUID (+18 more)

### Community 181 - "GridCompositorTests"
Cohesion: 0.08
Nodes (40): _7(), aJ(), aXt(), bXt(), cJ(), Cqt(), dXt(), F0() (+32 more)

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
Cohesion: 0.15
Nodes (12): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+4 more)

### Community 188 - "BrowserPaneView"
Cohesion: 0.15
Nodes (13): KouenOnboarding, Bool, ImmersiveOnboardingWindowController, .init(coder:), .init(onDismiss:), ImmersivePanel, .canBecomeKey, .canBecomeMain (+5 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.12
Nodes (9): BrowserLeaf, PaneID, URL, Decoder, .init(from:), DaemonSyncServiceBrowserPaneMergeTests, PaneID, PaneNodeBrowserTests (+1 more)

### Community 190 - "user-stories.md"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.06
Nodes (21): PluginLoader, String, ScriptAPI, ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool (+13 more)

### Community 192 - "GlyphRasterizer"
Cohesion: 0.08
Nodes (25): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), RasterizedGlyph, ShapedGlyph (+17 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.19
Nodes (10): RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal, FileHandle, Int32 (+2 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.18
Nodes (6): Divergence, Bool, String, TimeInterval, WorktreeInfo, WorktreeManager

### Community 195 - "ResizeHUDView"
Cohesion: 0.31
Nodes (4): OcclusionTests, NSWindow, String, TimeInterval

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.15
Nodes (15): Eme(), en(), gk(), GOt(), jUe(), kr(), Mme(), n6() (+7 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.21
Nodes (7): AIProviderAwakeService, .closedLidOptedIn, Bool, NSObjectProtocol, Set, String, AIProviderAwakeServiceTests

### Community 198 - ".classify"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.09
Nodes (27): aNt(), bNt(), bu(), cNt(), dNt(), dwn(), eNt(), eRe() (+19 more)

### Community 202 - "PaletteModel"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.13
Nodes (11): Am(), bze(), Cm(), EQ(), Hm(), Im(), lte(), MBe() (+3 more)

### Community 204 - "From tmux"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 205 - "CopyModeState"
Cohesion: 0.14
Nodes (12): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+4 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.08
Nodes (25): Font, .kouenBadge, .kouenBody, .kouenBodyStrong, .kouenCaption2, .kouenCaption, .kouenKbd, .kouenMono (+17 more)

### Community 207 - "scheduleRender"
Cohesion: 0.07
Nodes (20): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController, ProjectGroupResolver (+12 more)

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.17
Nodes (3): SessionID, GitPanelViewWorktreeTaskTests, TaskStatusMappingTests

### Community 209 - "SettingsRemoteView"
Cohesion: 0.14
Nodes (15): Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow, launchStart, StartupMetrics (+7 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.20
Nodes (4): CompletionGenerator, String, .fishCompletionSource, CompletionGeneratorTests

### Community 211 - "PaneTarget"
Cohesion: 0.28
Nodes (7): Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 212 - ".translate"
Cohesion: 0.11
Nodes (9): String, WorkspaceID, CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab, DaemonSyncServiceBranchNotifyTests (+1 more)

### Community 213 - "String"
Cohesion: 0.13
Nodes (6): TimeInterval, AgentHandoffBuilder, Bool, String, HandoffDirectoryTests, AgentHandoffBuilderTests

### Community 215 - ".lines"
Cohesion: 0.15
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 216 - "CellColorResolverTests"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 217 - "GridCompositor"
Cohesion: 0.07
Nodes (18): .captureLines(joinWrapped:), .feed(_:), .promptRows, .readGrid(scrollbackOffset:), Case, ReflowCorpusTests, .corpus, .goldenDir (+10 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.16
Nodes (10): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+2 more)

### Community 220 - "Section"
Cohesion: 0.17
Nodes (11): NotchGeometry, .fallback, NSScreen, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics (+3 more)

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.18
Nodes (12): GitStatusType, added, deleted, modified, renamed, unmodified, untracked, NodeRow (+4 more)

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.12
Nodes (15): DispatchWorkItem, CompletionPopupView, .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:), .isHovered (+7 more)

### Community 224 - "CellColorResolver"
Cohesion: 0.08
Nodes (23): MochaTheme, ANSIPalette, UInt8, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors, Bool (+15 more)

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.18
Nodes (6): .onCurrentCWD, .onCurrentFile, Bool, NSString, NSTextView, String

### Community 226 - "FileChangeWatcher"
Cohesion: 0.18
Nodes (10): MainActor, Void, Group, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, CGFloat, NSTextField (+2 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.21
Nodes (8): DaemonMetrics, Snapshot, .meanLockWaitMicros, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 228 - "sessionRow"
Cohesion: 0.12
Nodes (7): KeybindingsStore, .fileURL, URL, KeybindingsStoreTests, URL, Void, String

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

### Community 234 - ".scan"
Cohesion: 0.24
Nodes (6): Darwin, Foundation, Glibc, AgentRoutingResolver, FormatContextBuilder, AgentHookInstallerCLI

### Community 235 - "WorkbenchCommand"
Cohesion: 0.11
Nodes (16): BrowserPaneView, .webView(_:didCommit:), .webView(_:didFinish:), Any, DispatchWorkItem, BrowserPaneViewTests, MockWebView, .isLoading (+8 more)

### Community 236 - "Added"
Cohesion: 0.18
Nodes (6): Range, String, TerminalBufferMatch, TerminalBufferSearch, String, TerminalBufferSearchTests

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.09
Nodes (14): Bool, NSEvent, Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint (+6 more)

### Community 238 - ".make"
Cohesion: 0.18
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.15
Nodes (5): HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 240 - "PaneBorderStatus"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 242 - "AgentBridge"
Cohesion: 0.06
Nodes (43): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, .init(from:), .init(id:name:baseURL:modelID:), ModelProvider (+35 more)

### Community 243 - ".make"
Cohesion: 0.06
Nodes (39): .pairedAlreadyBanner, .pairingQRPanel, ArtifactKind, html, image, markdown, text, AutomationsFleetModel (+31 more)

### Community 244 - "FileNode"
Cohesion: 0.18
Nodes (8): FileNode, Bool, String, FileTreeScanOptions, ScoredMatch, Bool, String, .body

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.10
Nodes (19): ClaudeCodeHarness, .hasAdapter(for:), Profile, edit, readonly, Run, RunState, cancelled (+11 more)

### Community 247 - ".renderFixture"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.13
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.16
Nodes (9): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+1 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 251 - "SessionCoordinator"
Cohesion: 0.05
Nodes (18): Any, CGFloat, NSEvent, NSMenu, NSEvent, Selector, UInt8, CGFloat (+10 more)

### Community 252 - "NSViewRepresentable"
Cohesion: 0.24
Nodes (8): PickerItemRow, .badgeText, .body, .iconName, .subtitle, .titleText, AttributedString, NSColor

### Community 253 - "Split Right"
Cohesion: 0.32
Nodes (3): BinaryInstallerVersionTests, String, URL

### Community 254 - "BoardViewController"
Cohesion: 0.16
Nodes (9): AgentListFormatter, Date, String, dvn(), ht(), AgentListFormatterTests, Bool, Date (+1 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.07
Nodes (19): Color, .hexString, ColorHexRow, .body, .colorBinding, .currentHex, .isCustom, PaletteCell (+11 more)

### Community 256 - "GitMetadataProvider"
Cohesion: 0.24
Nodes (8): InstallResult, Shell, bash, fish, zsh, ShellIntegration, Bool, URL

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.18
Nodes (20): CoreImage, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription, .surfaceID, detectHost() (+12 more)

### Community 258 - "WindowTitleStripView"
Cohesion: 0.07
Nodes (16): DisplayWidth, String, Unicode, ReleaseNotes, Section, String, Run, String (+8 more)

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.12
Nodes (17): AYt(), Cme(), DYt(), EUe(), eYt(), gUe(), IUe(), j9n() (+9 more)

### Community 260 - ".welcome"
Cohesion: 0.09
Nodes (23): BinaryInstaller, .bundledMacOSDir, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display (+15 more)

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 262 - ".install"
Cohesion: 0.07
Nodes (23): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSEvent (+15 more)

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
Cohesion: 0.09
Nodes (23): aie(), arc(), b2e(), bezierCurveTo(), closePath(), cRe(), cZ(), E7() (+15 more)

### Community 270 - "WindowSession"
Cohesion: 0.09
Nodes (9): Configuration, Bool, Command, DispatchWorkItem, PaneID, SessionGroup, String, UInt8 (+1 more)

### Community 271 - "StatusLineView.swift"
Cohesion: 0.09
Nodes (13): ParsedShortcut, .displayString, PrefixKeymap, Any, Bool, NSEvent, String, TimeInterval (+5 more)

### Community 272 - "SGRMouseEvent"
Cohesion: 0.20
Nodes (16): Close Pane, Next Session, Previous Session, Split Down, Split Right, Cmd W Closes Pane When Split, Zombie Crash Rapid Split Close Cycle, Close Pane Removes Split (+8 more)

### Community 273 - "KeySpec"
Cohesion: 0.33
Nodes (6): SurfaceProgressTracker, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.15
Nodes (9): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ProcessInfo (+1 more)

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.09
Nodes (15): RemoteHostsService, .activeHostName, String, Endpoint, .localControlSocket, tcp, unix, EndpointError (+7 more)

### Community 277 - ".run"
Cohesion: 0.14
Nodes (14): GroupHeaderRow, .body, RecipePanel, .canBecomeKey, RecipePickerController, RecipePickerFooter, .body, RecipePickerModel (+6 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.14
Nodes (3): Fze, O7, RD

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.16
Nodes (10): String, AgentRoutingRule, Kind, path, stack, Bool, Date, UUID (+2 more)

### Community 280 - ".menu"
Cohesion: 0.15
Nodes (9): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, Set, SurfaceID, Tab (+1 more)

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.12
Nodes (15): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, FileTreeContext, NSEvent (+7 more)

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.16
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 283 - "FormatColor"
Cohesion: 0.26
Nodes (3): String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 284 - "click_ui_element"
Cohesion: 0.16
Nodes (6): LSPTextLocation, .position, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.25
Nodes (4): PortableRelativeDateFormatter, Date, String, UUID

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.11
Nodes (15): MarkdownPreviewView, .webView(_:decidePolicyFor:decisionHandler:), .webView(_:didFinish:), Bool, MainActor, Sendable, String, URL (+7 more)

### Community 287 - ".apply"
Cohesion: 0.41
Nodes (5): InstallResult, ShellCompletionInstaller, Bool, String, URL

### Community 288 - "AgentHookStrategy"
Cohesion: 0.17
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 290 - "Process"
Cohesion: 0.13
Nodes (10): NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView, .cornerConfiguration (+2 more)

### Community 292 - "Release runbook"
Cohesion: 0.29
Nodes (4): Full local signing path (needs a Developer ID cert; not currently used), How this fork actually releases, Release runbook, Scripted flow

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.11
Nodes (16): CodingKeys, error, id, jsonrpc, method, JSONRPCId, int, string (+8 more)

### Community 294 - "GitHubCLIClient"
Cohesion: 0.24
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 295 - "AgentApprovalBar"
Cohesion: 0.11
Nodes (9): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, KouenApp, FileChangeWatcherTests (+1 more)

### Community 296 - "NotificationBus"
Cohesion: 0.17
Nodes (16): SessionRef, byID, byName, next, previous, String, UUID, TargetSpec (+8 more)

### Community 297 - "settings.json"
Cohesion: 0.17
Nodes (12): CGFloat, NSCoder, SessionID, String, Void, TaskDashboardBody, .body, TaskDashboardView (+4 more)

### Community 299 - "PaneNode"
Cohesion: 0.14
Nodes (22): FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView, .body (+14 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.13
Nodes (14): string, AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID, .snapshotPayload (+6 more)

### Community 301 - ".parse"
Cohesion: 0.16
Nodes (13): BoxDrawing, Kind, arms, dashH, dashV, halfDown, halfLeft, halfRight (+5 more)

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.16
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 303 - ".encodeMouse"
Cohesion: 0.17
Nodes (5): TabID, WorkspaceID, AgentCommandTests, String, Tab

### Community 304 - "00-inception-plan.md"
Cohesion: 0.14
Nodes (14): CodingKey, CodingKeys, description, key, showInBanner, CodingKeys, createdAt, cwd (+6 more)

### Community 305 - ".script"
Cohesion: 0.27
Nodes (6): Int32, SessionID, Tab, TabID, WorkspaceID, WindowAttachClient

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 307 - "ViPathTokenTests"
Cohesion: 0.08
Nodes (15): DaemonSyncService, .sync(metadataOnly:), Bool, Never, PaneID, SurfaceID, Tab, TabID (+7 more)

### Community 308 - "Send Ex Command"
Cohesion: 0.18
Nodes (7): PaneBorderStatus, bottom, off, top, PaneRectSolver, PaneRectSolverTests, Bool

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.11
Nodes (22): keys, ITerm2InlineImage, .heightArg, .preserveAspectRatio, .widthArg, Bool, String, UInt8 (+14 more)

### Community 312 - "AgentSnapshot"
Cohesion: 0.23
Nodes (11): Array, Bool, Date, PaneID, String, TabID, Tab, .alertFlags (+3 more)

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.08
Nodes (28): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary, RowKind (+20 more)

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.15
Nodes (10): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+2 more)

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.17
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 319 - "FormatColor"
Cohesion: 0.15
Nodes (9): Bool, Int32, String, URL, SystemdUserInstaller, .backendName, .isInstalled, .unitURL (+1 more)

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.26
Nodes (14): Agent Command Does Not Crash, Agent Waiting Filter Does Not Crash, Board Command Shows Board Panel, Cd Command Switches To Matching Tab, Copy Path Command Does Not Crash, Errors Command Does Not Crash, Find Command Opens Command Palette On Empty Query, Find Command Resolves Unique File (+6 more)

### Community 321 - "UInt64"
Cohesion: 0.15
Nodes (12): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+4 more)

### Community 322 - "DesktopNotifier"
Cohesion: 0.09
Nodes (20): DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:), .isWorktreeSession (+12 more)

### Community 323 - "LayoutNode"
Cohesion: 0.29
Nodes (4): SwarmDAGStore, String, UUID, SwarmDAGStoreTests

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.08
Nodes (20): .logIfFailed(_:), .request(_:), DaemonClientActor, TimeInterval, DaemonSessionError, daemonError, .description, unexpectedResponse (+12 more)

### Community 325 - "FloatingPaneController"
Cohesion: 0.21
Nodes (8): KouenCommands, DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.18
Nodes (5): .snapshot, Bool, String, ThemeService, KouenOptions

### Community 327 - ".theme"
Cohesion: 0.23
Nodes (7): PaneOutputWaiter, PaneOutputWaitResult, Bool, CheckedContinuation, Never, Tab, UInt64

### Community 328 - "README.md"
Cohesion: 0.11
Nodes (14): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+6 more)

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 330 - ".drawGlyph"
Cohesion: 0.21
Nodes (4): Bool, String, SurfaceID, TimeInterval

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.38
Nodes (3): SnapshotCoalescer, MainActor, Void

### Community 332 - "Added"
Cohesion: 0.08
Nodes (34): json, AgentHistoryScanner, .parseAntigravityTranscript(sessionID:fileURL:), .parseAntigravityTranscript(sessionID:fileURL:toIndex:), .parseClaudeTranscript(fileURL:), .parseClaudeTranscript(fileURL:toIndex:), .parseCodexTranscript(fileURL:surfaceTag:ftsIndex:), .parseCodexTranscript(fileURL:surfaceTag:ftsIndex:toIndex:) (+26 more)

### Community 333 - "RealPty"
Cohesion: 0.18
Nodes (8): ClaudeRunSummary, Date, Double, Int32, String, UUID, String, UUID

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.28
Nodes (4): RemoteControlURLProvider, Bool, URL, RemoteControlURLProviderTests

### Community 335 - ".makeModel"
Cohesion: 0.14
Nodes (12): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID, HeadlessRunEvent, assistantText, result (+4 more)

### Community 336 - "run.sh"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 337 - "CommandExecutionError"
Cohesion: 0.15
Nodes (9): FormatContext, FormatString, FormatStyle, Bool, Character, Date, String, FormatStyledTests (+1 more)

### Community 338 - "CSIParams"
Cohesion: 0.14
Nodes (14): Bool, String, UUID, TaskDaemonBridge, Status, ciFailing, done, mergeReady (+6 more)

### Community 339 - "Foundation"
Cohesion: 0.08
Nodes (26): AppKit, CoreGraphics, CoreText, ImageIO, KouenCopyMode, KouenTerminalEngine, KouenTerminalKit, KouenTerminalRenderer (+18 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.18
Nodes (9): Bool, NSCoder, NSEvent, NSTrackingArea, .init(coder:), WorkspaceSwitcherRow, .init(coder:), .init(title:count:isActive:symbol:canDelete:) (+1 more)

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.19
Nodes (8): AgentRemoteControlDaemonService, Set, String, Void, AgentRemoteControlDaemonServiceTests, LogBox, .count, String

### Community 342 - "Added"
Cohesion: 0.33
Nodes (6): Bool, NSPasteboard, NSString, String, URL, AutoreleasingUnsafeMutablePointer

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.17
Nodes (21): Decodable, Item, ItemCompletedLine, LegacyMsgLine, Msg, String, ThreadStartedLine, AgentCommandRequest (+13 more)

### Community 344 - "FileViewerViewController"
Cohesion: 0.11
Nodes (12): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+4 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.16
Nodes (11): SettingsAppearanceView, .autoTheme, .body, .themeSection, SliderRow, .body, .displayValue, Bool (+3 more)

### Community 349 - "Contents.json"
Cohesion: 0.21
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.23
Nodes (3): MobileBridgeAttachFileTests, String, URL

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.06
Nodes (45): AgentRow, .agentColor, .executables, .hookButton, .hookButtonTitle, HookState, failed, idle (+37 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.27
Nodes (3): SSETransportTests, UInt16, NWListener

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.21
Nodes (8): StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength, newline, TransportError, invalidUTF8Header, missingContentLength

### Community 355 - ".deepMerge"
Cohesion: 0.19
Nodes (13): ProjectGroupWatcher, StreamBox, Bool, DispatchQueue, escaping, FSEventStreamRef, MainActor, Never (+5 more)

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.15
Nodes (12): NaturalLanguage, AgentHistorySearch, Hit, IDFCache, Bool, Double, String, .tokenHits(_:inNormalized:) (+4 more)

### Community 357 - ".handleCat"
Cohesion: 0.13
Nodes (24): Codable, BrowserSnapshotAck, BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserResponsePayload, cookies (+16 more)

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.37
Nodes (3): .block(atPromptLine:), String, TerminalBlockStoreTests

### Community 359 - "OcclusionTests"
Cohesion: 0.13
Nodes (4): AgentTitleInference, Bool, .effectiveAgentKind, AgentDetectorTests

### Community 360 - "State"
Cohesion: 0.19
Nodes (10): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+2 more)

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.07
Nodes (24): IndexingIterator, LayoutTemplate, Bool, Double, surfaceID, SessionEditor, .split(node:targetPaneID:direction:paneCount:before:), .split(node:targetPaneID:with:direction:beforeTarget:) (+16 more)

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.08
Nodes (20): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+12 more)

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.09
Nodes (16): AgyModelCatalog, Catalog, Date, String, TimeInterval, AgyMobileCommands, String, ClaudeMobileCommands (+8 more)

### Community 366 - "Consumers"
Cohesion: 0.13
Nodes (14): agentDetail(), AgentInboxBody, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView, .body (+6 more)

### Community 367 - "DaemonStats"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 368 - "Tab"
Cohesion: 0.24
Nodes (11): Close Tab, New Tab, Cmd Shift W Force Closes Tab, Cmd T Creates New Session, Cmd W Closes Tab When Single Pane, Window Survives Full Shortcut Sequence, Zombie Crash Close Tab While Typing, Zombie Crash Rapid Close While Typing (+3 more)

### Community 370 - ".encode"
Cohesion: 0.17
Nodes (7): PasteController, Bool, NSPasteboard, String, TimeInterval, URL, PasteControllerTests

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.16
Nodes (4): KouenThemeCatalog, .allThemes, String, KouenThemeCatalogTests

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.11
Nodes (19): DataBox, .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:) (+11 more)

### Community 373 - "Prompt"
Cohesion: 0.18
Nodes (3): fQ, hqe(), M9()

### Community 374 - ".run"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

### Community 375 - ".install"
Cohesion: 0.23
Nodes (5): String, TextGrid, .totalLines, .viewportRows, WordColumnRangeTests

### Community 376 - "ScrollReuseTests"
Cohesion: 0.08
Nodes (20): OSCTerminatorMatch, PtyError, launchFailed, RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), ScrollbackEntry, ScrollbackReplaySegment, ShellLaunchProfile (+12 more)

### Community 377 - "Identifiable"
Cohesion: 0.55
Nodes (5): AgentIconRenderer, CGFloat, NSColor, NSImage, String

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 379 - "MCPServer"
Cohesion: 0.09
Nodes (31): Encodable, AgyModelsPush, AISuggestionAck, AttachedAck, Body, BrowserFramePush, Cred, DetachedAck (+23 more)

### Community 380 - "PromptQueue"
Cohesion: 0.13
Nodes (12): clamp(), Date, Never, T, Task, Void, TabPillView, .dragGesture (+4 more)

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.20
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.16
Nodes (16): SwarmFleetSnapshot, SwarmLane, pty, structured, SwarmTaskNode, SwarmTaskStatus, cancelled, failed (+8 more)

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.10
Nodes (19): CompleteStepView, Void, OnboardingStep, complete, discover, .id, setup, shell (+11 more)

### Community 385 - "INDEX.md"
Cohesion: 0.12
Nodes (10): item, CodexSessionLocator, CodexTranscriptLine, Any, Bool, Int32, String, URL (+2 more)

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.07
Nodes (15): ScreenPos, bottom, middle, top, KouenLSP, FileGraphInfo, GraphifyLSPBridge, Double (+7 more)

### Community 387 - "User Profile"
Cohesion: 0.36
Nodes (4): KeyTokenParser, Bool, String, .remaining

### Community 388 - "Darwin"
Cohesion: 0.30
Nodes (4): Bool, OptionStore, OptionStoreTests, URL

### Community 389 - "HarnessCLITests"
Cohesion: 0.27
Nodes (6): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.23
Nodes (3): files, GitDiffFile, MobileBridgeGitDiffTests

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.18
Nodes (13): Branch Change In Shared Folder Is Not Isolated Unprompted, CLI Isolate Creates Worktree And Session, CLI Isolate With Custom Branch Name, Close Session Keeps Dirty Worktree, Close Session Removes Clean Worktree, Create Isolated Session And Select, Git Checkout In Normal Session Does Not Affect Isolated, Isolate Without Branch Uses Detached HEAD (+5 more)

### Community 402 - "View"
Cohesion: 0.19
Nodes (6): KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, OnboardingEnvironmentTests

### Community 403 - "PresentAttempt"
Cohesion: 0.10
Nodes (3): Bool, String, UUID

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.22
Nodes (6): ListeningPortScanner, Int32, Set, String, result, ListeningPortScannerTests

### Community 405 - "AgentIconRenderer"
Cohesion: 0.19
Nodes (13): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Bool, Duration (+5 more)

### Community 406 - "main.swift"
Cohesion: 0.25
Nodes (8): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String

### Community 407 - "Fixed"
Cohesion: 0.11
Nodes (16): .body, .mcpButton, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter, Any (+8 more)

### Community 408 - "IPC Architecture"
Cohesion: 0.18
Nodes (10): AssistantLine, ClaudeAdapter, Content, Message, ResultLine, Bool, Double, String (+2 more)

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.18
Nodes (3): ShellIntegrationTests, .repoRoot, URL

### Community 414 - "json.json"
Cohesion: 0.06
Nodes (33): JSONDecoder, JSONEncoder, CodingKeys, cols, createdAt, dataBase64, rows, timeMs (+25 more)

### Community 415 - "markdown.json"
Cohesion: 0.18
Nodes (8): NSHostingView, NSLayoutConstraint, TerminalTabBarView, .delegate, .init(frame:), .leadingInset, .mouseDownCanMoveWindow, .trailingInset

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.29
Nodes (3): BellScanTests, Bool, UInt8

### Community 417 - "rust.json"
Cohesion: 0.21
Nodes (5): FDWatchdog, DispatchSourceTimer, String, TimeInterval, FDWatchdogTests

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.08
Nodes (23): DisplayLinkTarget, MainSplitViewController, .setSidebarVisible(_:), .setSidebarVisible(_:animated:), SplitChromeDelegate, .sidebarMaxWidth, .sidebarMinWidth, .splitView(_:constrainMaxCoordinate:ofSubviewAt:) (+15 more)

### Community 419 - "typescript.json"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.06
Nodes (26): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+18 more)

### Community 422 - "HintModeOverlay"
Cohesion: 0.08
Nodes (13): .effectiveResumeCommand(mode:), AgentLaunchCommands, String, AgentSessionMode, cloud, .launchCommand, .launchFlags, local (+5 more)

### Community 423 - "SixelDecoder"
Cohesion: 0.09
Nodes (29): .filteredJobs, MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith (+21 more)

### Community 424 - ".parseDiffHunks"
Cohesion: 0.20
Nodes (8): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController

### Community 425 - "AgentVectorIcon"
Cohesion: 0.18
Nodes (13): FeaturePhase, architect, completed, dev, interview, qaDesign, qaVerify, .title (+5 more)

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.29
Nodes (6): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Carbon

### Community 427 - ".delay"
Cohesion: 0.20
Nodes (10): PaneRef, bottom, byID, byIndex, last, left, next, previous (+2 more)

### Community 428 - "TaskDashboardView"
Cohesion: 0.27
Nodes (9): Command Prompt, Find In Files, Git Panel, Open Command Palette, Switch To Session 1, Switch To Session 2, Rapid Session Switch While Typing, Switch Between Isolated And Normal Session (+1 more)

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.19
Nodes (7): Scope, pane, session, tab, workspace, ScopedKey, URL

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.19
Nodes (9): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+1 more)

### Community 431 - "BoardCardView"
Cohesion: 0.12
Nodes (24): .color, BoardCard, BoardColumn, .name, BoardColumnKind, .displayName, done, error (+16 more)

### Community 432 - "PathToken"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 434 - "Project History"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 436 - "WaitForRegistry"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: animateSidebar setContentLeadingInset MainSplitViewController, Source Nodes

### Community 437 - "PickerItemRow"
Cohesion: 0.17
Nodes (7): A7(), a8(), c8(), ene(), Gnn, IC(), o8()

### Community 438 - "SessionEditor"
Cohesion: 0.10
Nodes (18): .requestDaemon(_:), .selectWorkspace(byIndex:), .syncFromDaemon(metadataOnly:), ActiveTabCloseDisposition, session, tab, window, workspace (+10 more)

### Community 439 - "SetupStepView"
Cohesion: 0.14
Nodes (10): apn(), brn, grn, hrn(), JGe(), KGe(), prn(), qGe() (+2 more)

### Community 440 - "LegacySnapshot"
Cohesion: 0.16
Nodes (9): bUt(), FBe(), Gbe(), handler(), mUt(), _Q(), s0n(), wHt() (+1 more)

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.20
Nodes (9): BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool, CGFloat, NSCoder, NSPoint (+1 more)

### Community 443 - "main.swift"
Cohesion: 0.18
Nodes (4): ClaudeSessionMode, ClaudeSessionModeTests, URL, Void

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 445 - "Section"
Cohesion: 0.40
Nodes (4): Findings, Sources, What this means for Kouen, Who creates branches / worktrees in AI coding tools

### Community 446 - "Modifiers"
Cohesion: 0.18
Nodes (9): Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock, .block(id:) (+1 more)

### Community 447 - "PaletteMode"
Cohesion: 0.18
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.18
Nodes (10): Bug 1 - Rotation Grace Slot Keeps The Previous Token Redeemable, Bug 1 - Rotation Shifts The Outgoing Token Into The Grace Slot, Bug 1 - Stop Fully Clears The Grace Slot, Bug 1 - Token Lifetime Not Regressed Below The Human-Flow Window, Bug 2 - Client onerror Does Not Clobber The Server Error Banner, Bug 2 - No Abrupt Cancel Immediately After The Error Text, Bug 2 - Reject Path Closes Gracefully With Policy-Violation Code 1008, Bug 3 - QR Not Printed When No Listener Is Ready (+2 more)

### Community 449 - "PresentAttempt"
Cohesion: 0.08
Nodes (16): Tab, BrowserIntegrationController, PaneID, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), .init(paneID:), PaneID, String (+8 more)

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.12
Nodes (3): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess

### Community 451 - ".run"
Cohesion: 0.47
Nodes (4): AgentBadgeView, .body, Bool, CGFloat

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.20
Nodes (13): ern(), G4(), G7(), Jnn(), nrn(), Qnn(), sHe(), trn() (+5 more)

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.12
Nodes (16): BrowserRequestPayload, close, cookies, evaluate, goBack, goForward, interact, navigate (+8 more)

### Community 455 - "ComposerPanel"
Cohesion: 0.12
Nodes (16): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+8 more)

### Community 456 - "TerminalModes"
Cohesion: 0.16
Nodes (12): Notification.Name, KouenGit, os, attribute_lines(), main(), redraw_frames(), repeated_chunk(), run_case() (+4 more)

### Community 457 - ".normalizedKey"
Cohesion: 0.18
Nodes (11): Typography, .badge, .kbd, .paletteHeader, .paletteTitle, .rowMeta, .rowTitle, .sectionLabel (+3 more)

### Community 459 - ".encode"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 460 - "RunState"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 461 - ".worktreeList"
Cohesion: 0.22
Nodes (8): MCP Control Allowed With Env Var, MCP Control Denied Without Env Var, MCP KouenBoard Returns Columns, MCP KouenList Returns Sessions, MCP ReadPaneOutput Returns Content, Run MCP Request, Run MCP Request Allowed, Run MCP Request Denied

### Community 462 - "AGENTS.md"
Cohesion: 0.29
Nodes (7): Toggle Sidebar, Sidebar Toggle Works, Board CLI Shows Columns, Board CLI Shows Running After Long Command, Board Columns Visible After Click, Board Tab Accessible In Sidebar, Split Pane And Resize

### Community 463 - ".deinit"
Cohesion: 0.29
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 464 - "MouseButton"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 465 - "DirectionalAxis"
Cohesion: 0.39
Nodes (4): SessionGroup, Any, String, Tab

### Community 466 - "PlatformSys.swift"
Cohesion: 0.31
Nodes (4): GraphifyIndexCache, S, Set, String

### Community 467 - ".moveSelection"
Cohesion: 0.23
Nodes (9): AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor (+1 more)

### Community 468 - "Never"
Cohesion: 0.05
Nodes (30): FilterStatus, active, all, completed, CaseIterable, LayoutTemplate, evenHorizontal, evenVertical (+22 more)

### Community 469 - "PresentAttempt"
Cohesion: 0.22
Nodes (8): DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSViewCornerConfiguration, SurfaceID, Void

### Community 470 - "DispatchTime"
Cohesion: 0.10
Nodes (24): NSView, OverlayBackground, Context, OverlayBackground, Context, ChromeBackdrop, .init(role:), Colors (+16 more)

### Community 471 - ".evaluateStyled"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 473 - "HarnessOnboarding"
Cohesion: 0.27
Nodes (4): ArchitectureGuardTests, .repoRoot, String, URL

### Community 474 - "String"
Cohesion: 0.10
Nodes (15): LSPMessage, notification, request, response, Decoder, Encoder, KeyedDecodingContainer, LSPTransport (+7 more)

### Community 475 - ".hitTest"
Cohesion: 0.30
Nodes (5): SearchBenchmarks, String, UInt64, URL, Void

### Community 476 - "ProjectDropTarget"
Cohesion: 0.27
Nodes (4): .activeTab, BrowserTab, UUID, tabs

### Community 477 - ".encode"
Cohesion: 0.04
Nodes (60): a6e(), a9e(), aoe(), aTn(), avn(), bR(), c0t(), c2t() (+52 more)

### Community 478 - ".install"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 479 - "ScrollbackTests"
Cohesion: 0.31
Nodes (6): Bool, Counter, Scheduled, SurfaceProgressTrackerTests, DispatchWorkItem, TimeInterval

### Community 480 - "Command Prompt Architecture"
Cohesion: 0.17
Nodes (11): LinePos, end, firstNonBlank, start, ViDiagnosticNavigator, ViMode, insert, normal (+3 more)

### Community 482 - ".resolve"
Cohesion: 0.22
Nodes (10): DotView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor, NSRect (+2 more)

### Community 483 - "Changed"
Cohesion: 0.25
Nodes (3): FlushSessionStateTests, String, URL

### Community 485 - ".testKouenRendererFixtureLigatureShapingPathReportsPlausibleGlyphs"
Cohesion: 0.38
Nodes (6): Cleanup And Quit, Create Config File, No Config File Starts Normally, Script Hot Reload On Save, Script Loads On Startup, Script Syntax Error Does Not Crash

### Community 486 - "TabPillView"
Cohesion: 0.29
Nodes (6): Bug 1 - Browser Pane Deferred Unregister, Bug 1 - Browser Pane Reuse On Rebuild, Bug 2 - New Session Syncs Before Reading Active Tab, Bug 2 - Tab Bar New Tab Also Syncs, Bug 3 - Browser Pane Forces Redraw On Reattach, Build Compiles Successfully

### Community 487 - "bC"
Cohesion: 0.41
Nodes (7): FeatureSummary, FeatureTaskSummary, GateSummary, Bool, Date, String, UUID

### Community 488 - "ccRunCancel"
Cohesion: 0.29
Nodes (10): CGFloat, Range, Tab, TabBarIconButtonStyle, TabBarLayoutMetrics, .pitch, tabDisplayTitle(), TerminalTabBarBody (+2 more)

### Community 489 - "SurfaceIO"
Cohesion: 0.21
Nodes (5): ImageTextureCache, MTLDevice, MTLTexture, Set, UInt8

### Community 490 - "ccRunGet"
Cohesion: 0.14
Nodes (13): SwarmFleetBody, .body, SwarmNodeRowView, .body, .statusColor, Duration, Void, SwarmFleetSnapshotWire (+5 more)

### Community 491 - ".update"
Cohesion: 0.31
Nodes (8): daemonLog(), detectStaleInstance(), installSignalHandlers(), removeForeignPIDFile(), removePIDFile(), Sendable, String, writePIDFile()

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 494 - "ccRunInfo"
Cohesion: 0.33
Nodes (5): Kouen LSP Diagnostics Does Not Crash, Kouen LSP Hover Returns Result, Kouen LSP Start Returns JSON, Kouen View Binary Shows Guard Message, Kouen View Prints File Content

### Community 495 - ".makeDiffScrollView"
Cohesion: 0.33
Nodes (5): AgentBridge, AgentTarget, Bool, String, SurfaceID

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.29
Nodes (6): Motion, .entrance, .spring, .standardEase, CGFloat, CAMediaTimingFunction

### Community 498 - ".automationList"
Cohesion: 0.39
Nodes (6): GitResult, .isSuccess, GitWorktreeInfo, Bool, Int32, String

### Community 499 - "ProjectConfig"
Cohesion: 0.27
Nodes (6): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor

### Community 501 - "Fixed"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 502 - "ACP Client (Shelved)"
Cohesion: 0.40
Nodes (5): WrapperOptionBehavior, keepScanning, matchValue, skipValue, stopScanning

### Community 503 - "ReleaseNotesGuardTests"
Cohesion: 0.22
Nodes (4): String, URL, UUID, WorktreeIsolationDaemonTests

### Community 504 - "WindowBorderOverlayView"
Cohesion: 0.22
Nodes (7): KouenCLIPaths, .applicationSupport, .binDirectory, .installedCLIPath, .installedDaemonPath, .launchAgentURL, URL

### Community 506 - "SwarmFleetBody"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.40
Nodes (4): Leak A - Retiring A Host Drops Its AI Controllers, Leak B - Browser Network Capture Is Bounded, Leak C - Every Per-Surface Dict In Coordinator Has Retire Cleanup, Leak D - Every Per-Surface Dict In NotificationCoordinator Is Snapshot-Swept

### Community 509 - "start.mjs"
Cohesion: 0.60
Nodes (5): main(), printHelp(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 510 - "PromptQueue"
Cohesion: 0.20
Nodes (10): Architecture Decisions (dated log), Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Post-P50 changes (v4.20.2 → v4.20.11, 2026-10-01 → 2026-10-06), Product Identity Guardrail: Terminal, Not IDE, Shipped capability summary, P44–P49 (2026-08-31 → 2026-09-23) (+2 more)

### Community 511 - ".panePathLookup"
Cohesion: 0.20
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

### Community 512 - ".setAttribute"
Cohesion: 0.08
Nodes (21): IssueKeychainStore, Bool, String, IssuePriority, .color, high, low, medium (+13 more)

### Community 513 - "ThemeDocument"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.18
Nodes (11): Never, NSRegularExpression, Set, String, Task, URL, Void, WorkspaceSymbolIndex (+3 more)

### Community 515 - "RD"
Cohesion: 0.37
Nodes (4): KouenFeatureMarkdownSync, Bool, String, URL

### Community 516 - "terminal_stress_runner.py"
Cohesion: 0.17
Nodes (5): DirectionalAxis, down, left, right, up

### Community 521 - ".daemonIsStale"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 523 - "fFe"
Cohesion: 0.13
Nodes (11): Bool, Int32, InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal (+3 more)

### Community 524 - "TerminalColorRole"
Cohesion: 0.22
Nodes (6): .rowList, AgentNotchViewModel, Bool, CGFloat, Duration, String

### Community 526 - "Kind"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 527 - ".show"
Cohesion: 0.50
Nodes (3): Bug 1 - Hunks Button Has Explicit Size Constraints, Bug 1 - Hunks Button Symbol Has A Guaranteed-Valid Fallback, Build Compiles Successfully

### Community 528 - "worktree_review_dashboard.robot"
Cohesion: 0.50
Nodes (3): Guard A - Merge Call Site Never Passes --no-ff, Guard B - No Auto-Resolve Anywhere In The Merge/Conflict Path, Guard C - Merge Conflict State Is Reconciled, Not Just Read Once

### Community 529 - "WorktreeAutoIsolateService"
Cohesion: 0.10
Nodes (14): NotchMaskAnimator, Bool, CGFloat, CGRect, NotchPanel, .canBecomeKey, .canBecomeMain, Bool (+6 more)

### Community 530 - "HarnessChrome"
Cohesion: 0.23
Nodes (3): ContentAreaViewController, Bool, Notification

### Community 531 - "BrowserProgressLine"
Cohesion: 0.22
Nodes (7): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, NSCoder, Void

### Community 534 - ".zoomWindowIfDoubleClick"
Cohesion: 0.24
Nodes (9): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+1 more)

### Community 535 - "AgentNotification"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 537 - "NSObject"
Cohesion: 0.29
Nodes (3): ChromeRole, sidebar, tabBar

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.06
Nodes (31): NSFont, SessionDividerRowView, .init(coder:), SessionGroupHeaderRowView, .init(coder:), .init(frame:), SessionWorktreeHeaderRowView, .init(coder:) (+23 more)

### Community 539 - "install-app.sh"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 540 - ".applyStyleDirective"
Cohesion: 0.27
Nodes (3): DaemonReconnectPolicy, TimeInterval, DaemonReconnectPolicyTests

### Community 544 - "CodingKeys"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 546 - "LegacySnapshot"
Cohesion: 0.22
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 547 - "NSObject"
Cohesion: 0.15
Nodes (14): ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool, Command (+6 more)

### Community 552 - "worktree_auto_isolate_wiring.robot"
Cohesion: 0.29
Nodes (5): AgentNotchPresentation, closed, open, peek, AgentNotchWindowActivator

### Community 553 - "harness.resource"
Cohesion: 0.29
Nodes (6): DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed

### Community 554 - "eFe"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 556 - "sBt"
Cohesion: 0.32
Nodes (4): SwarmFleetView, .init(coder:), CGFloat, NSCoder

### Community 557 - ".viewWillMove"
Cohesion: 0.47
Nodes (3): URL, TimeoutError, WorktreeLargeOutputRegressionTests

### Community 558 - "FindWindowMatcherTests"
Cohesion: 0.16
Nodes (16): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+8 more)

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 560 - ".zoomWindowIfDoubleClick"
Cohesion: 0.24
Nodes (8): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8, .body

### Community 561 - ".handleClaudeCode"
Cohesion: 0.12
Nodes (21): aVe(), bme(), bYt(), cVe(), fqt(), hVe(), iVe(), lVe() (+13 more)

### Community 562 - "BrowserResponsePayload"
Cohesion: 0.40
Nodes (4): Build, Release & Git Workflow, Build / Test / Run, Release packaging order, Worktree constraint

### Community 563 - "AgentNotchViewModel.swift"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

### Community 565 - "WriteOrigin"
Cohesion: 0.11
Nodes (18): BrowserPaneRegistry, .init(url:paneID:), .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), BrowserProgressLine, .init(frame:), NSLayoutConstraint, NSRect (+10 more)

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 568 - ".installChromeBackground"
Cohesion: 0.08
Nodes (21): AgentChipView, .init(coder:), .intrinsicContentSize, .init(coder:), .init(coder:), .init(coder:), Shadow, elevation1 (+13 more)

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.26
Nodes (5): Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.08
Nodes (26): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+18 more)

### Community 571 - "ShellIntegrationTests"
Cohesion: 0.48
Nodes (3): KouenMCPServer, Bool, String

### Community 572 - "LayoutProbeView"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 574 - ".applyFontSize"
Cohesion: 0.23
Nodes (6): CGImage, data, ImageLimits, Bool, SixelDecoder, UInt8

### Community 575 - ".toastErrorSummary"
Cohesion: 0.18
Nodes (6): eKe(), irn(), mrn, _rn(), rrn(), srn()

### Community 576 - "Phase67Tests"
Cohesion: 0.22
Nodes (5): RepoResolver, Bool, String, RepoResolverTests, String

### Community 579 - "main.swift"
Cohesion: 0.29
Nodes (7): AnimatablePair, NotchShape, .animatableData, CGFloat, CGPath, CGRect, Path

### Community 580 - "ViInputMode"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 583 - "WorkbenchMRU"
Cohesion: 0.13
Nodes (12): CryptoKit, Network, DecodedWSFrame, Bool, ConnectionState, NWConnection, String, UInt8 (+4 more)

### Community 584 - "GUt"
Cohesion: 0.31
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 585 - "P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress"
Cohesion: 0.04
Nodes (53): aae(), c6(), calculate(), constructor(), cxn(), edn(), eL(), evt() (+45 more)

### Community 586 - "Product"
Cohesion: 0.20
Nodes (10): Agent Safety Net (Checkpoints, Verification, Write Guards), Claude Code Harness, Editor & LSP, How It Feels, Kouen Features, Mobile, Remote And Headless, Stack (+2 more)

### Community 591 - "main.swift"
Cohesion: 0.21
Nodes (8): SettingsAdvancedView, .body, Bool, String, SettingsFileSearchSection, .body, String, SwiftUI

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
Cohesion: 0.83
Nodes (3): restart_daemon(), full-cycle.sh script, usage()

### Community 596 - ".feed(_:)"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 597 - "TerminalColorRole"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 598 - ".encode"
Cohesion: 0.31
Nodes (3): crn, ELt(), n2e()

### Community 599 - ".terminalHostIfExists"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 600 - ".groupByRoot"
Cohesion: 0.25
Nodes (7): Browser Pane Open Close Rapid, File Preview Open Close, Git Fetch Shows Toast, Launch Kouen Staging, Memory Stability After 30 Seconds, Quit Kouen Staging, Sidebar Toggle Immediately After Launch

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

### Community 609 - "FormatContextDaemonTests"
Cohesion: 0.18
Nodes (9): statusColor(), statusHelp(), String, TabStatus, done, error, idle, running (+1 more)

### Community 613 - "INDEX.md"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 617 - "ScriptFileWatcher"
Cohesion: 0.06
Nodes (34): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, SessionGroup, SessionID (+26 more)

### Community 623 - "inlineTokens"
Cohesion: 0.29
Nodes (7): blockTokens(), inlineTokens(), lex(), lexer(), lexInline(), me(), reflink()

### Community 624 - "[2.5.0] - 2026-06-12"
Cohesion: 0.25
Nodes (7): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, String

### Community 627 - "ActiveTabCloseDisposition"
Cohesion: 0.33
Nodes (4): OutputTrigger, OutputTriggerStore, Bool, String

### Community 628 - "ReplayStep"
Cohesion: 0.12
Nodes (5): KouenCLI, HistorySearchQueryTests, MemoCommandTests, URL, TaskCommandTests

### Community 629 - "graphify reference: query, path, explain"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 637 - "ClientSummary"
Cohesion: 0.08
Nodes (18): NSScrollView, NSWindow, Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent (+10 more)

### Community 641 - "[3.10.0] - 2026-06-27"
Cohesion: 0.25
Nodes (7): #kouen, #practice, #score, #shell, #total, #unix, #vim

### Community 645 - "KouenBrowserToolsTests"
Cohesion: 0.24
Nodes (3): KouenMCP, KouenBrowserToolsTests, URL

### Community 646 - "[3.10.1] - 2026-06-27"
Cohesion: 0.24
Nodes (5): RiskyCommandClassifier, Bool, NSRegularExpression, String, RiskyCommandClassifierTests

### Community 648 - "PtyDrainCeilingBenchmark"
Cohesion: 0.13
Nodes (16): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, .bytesPerWakeup, .mbps (+8 more)

### Community 659 - "MobileBridgeBrowserTests"
Cohesion: 0.29
Nodes (5): ThaiClusterCopyTests, ThaiGrid, .columns, .totalLines, .viewportRows

### Community 661 - ".compute"
Cohesion: 0.15
Nodes (12): OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Bool, Value, bool (+4 more)

### Community 662 - "New Tab"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 664 - "P37 Phase G — Autocomplete (mobile bridge)"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 666 - "BrowserIntegrationController"
Cohesion: 0.17
Nodes (9): GitStatusProvider, OnceResume, Bool, Duration, String, TimeInterval, GitStatusProviderLargeOutputTests, URL (+1 more)

### Community 671 - "AntigravityTranscriptTurnsTests"
Cohesion: 0.24
Nodes (4): HintModeOverlay, Any, NSEvent, String

### Community 675 - ".detect"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 678 - "FormatColor"
Cohesion: 0.11
Nodes (13): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+5 more)

### Community 679 - "Notification"
Cohesion: 0.25
Nodes (3): SessionStore, DispatchWorkItem, TimeInterval

### Community 680 - ".kouenSpawnWorker"
Cohesion: 0.29
Nodes (7): GRt(), n4e(), p7e(), r2(), tl(), vrt(), xq()

### Community 681 - ".tabIDsToNotify"
Cohesion: 0.17
Nodes (11): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile, regionEdit (+3 more)

### Community 682 - "Workbench commands (IDE-like workflow)"
Cohesion: 0.33
Nodes (6): Board and attention, Errors and LSP, File navigation, Search, Task runner, Workbench commands (IDE-like workflow)

### Community 683 - "hJ"
Cohesion: 0.32
Nodes (6): CGFloat, ResizeDirection, down, left, right, up

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 686 - "DECSpecialGraphics"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 688 - ".evaluateJavaScript"
Cohesion: 0.29
Nodes (6): Any, Error, MainActor, Sendable, String, Void

### Community 690 - ".update"
Cohesion: 0.40
Nodes (5): Additional `kouen-cli` subcommands, Agents, context and scratchpad, Daemon and diagnostics, Editor, LSP and setup, Sessions, tabs and recording

### Community 692 - "smoke-dmg.sh"
Cohesion: 0.38
Nodes (4): AnyObject, TimeInterval, ZombieHoldRegistry, ObjectIdentifier

### Community 694 - "Result"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 696 - "TerminalTabBarDelegate"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 698 - ".findSession"
Cohesion: 0.32
Nodes (4): PaneID, SessionGroup, Tab, first

### Community 700 - ".installCLI"
Cohesion: 0.40
Nodes (4): PriorInstanceDecision, proceed, refuse, stale

### Community 702 - "PromptQueue"
Cohesion: 0.10
Nodes (6): PromptQueue, String, SurfaceID, Void, PromptQueueBar, NSWindow

### Community 703 - "ColorKind"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 704 - "AutomationsFleetModelTests"
Cohesion: 0.40
Nodes (5): CwdAuthorizationError, foreignPathRejected, .message, missingSessionOrCwd, other

### Community 709 - "String"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 710 - "MainWindowController"
Cohesion: 0.10
Nodes (14): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+6 more)

### Community 713 - "AutomationScheduler"
Cohesion: 0.24
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 714 - "_Ue"
Cohesion: 0.33
Nodes (6): h1t(), hae(), jgn(), pwn(), sfn(), _Ue()

### Community 715 - "TerminalProgressReport"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 719 - "ViInputMode"
Cohesion: 0.50
Nodes (5): aut(), cpn(), hq(), kLt(), q1n()

### Community 723 - "Color"
Cohesion: 0.15
Nodes (11): PickerItem, .groupLabel, historyBlock, .id, recipe, .searchableText, SurfaceID, RecipePickerModelMergeTests (+3 more)

### Community 724 - ".copy"
Cohesion: 0.17
Nodes (7): MainMenuBuilder, Bool, NSMenu, NSMenuItem, Selector, String, MenuTargetForkConversationTests

### Community 727 - "PromptQueueBar"
Cohesion: 0.12
Nodes (15): agy, claude, codex, copilot, hermes, kouen, __kouen_agy_next, __kouen_claude_next (+7 more)

### Community 728 - "TerminalHostView"
Cohesion: 0.14
Nodes (10): InputGate, .siblings, SurfaceIO, .currentSubscription, String, SurfaceID, UInt16, UInt64 (+2 more)

### Community 729 - "TerminalColorRole"
Cohesion: 0.20
Nodes (7): BBe(), NBe(), PBe(), qLt(), sIt(), VBe(), zLt()

### Community 731 - "Phase6KeysTests"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: SSETransport auth token isRunning

### Community 733 - "MobileBridgeBrowserTests"
Cohesion: 0.28
Nodes (9): dhn(), fhn(), ghn(), iXt(), jXt(), l8n(), nXt(), soe() (+1 more)

### Community 735 - "companion.test.mjs"
Cohesion: 0.22
Nodes (7): block, escFn, lineFilter, md, page, script, swift

### Community 736 - "graphify reference: add a URL and watch a folder"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 737 - ".resolve"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 741 - "LayoutProbeView"
Cohesion: 0.36
Nodes (3): KouenSplitViewTests, LayoutProbeView, CGFloat

### Community 745 - "p11_scripting.robot"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 750 - "ClipboardOSCTests"
Cohesion: 0.23
Nodes (13): kouen.bash script, agy(), claude(), codex(), copilot(), hermes(), kouen(), __kouen_agy_next() (+5 more)

### Community 755 - "_Ue"
Cohesion: 0.33
Nodes (6): Command, .targetKind, TargetKind, pane, session, window

### Community 756 - "I$e"
Cohesion: 0.06
Nodes (38): KeybindingsService, Bool, Command, String, OptionSet, KeySpec, .description, .init(from:) (+30 more)

### Community 762 - ".body"
Cohesion: 0.47
Nodes (3): TabID, .body, TerminalTabBarDelegate

### Community 763 - "fFe"
Cohesion: 0.50
Nodes (4): TabSelector, active, id, session

### Community 770 - "create-dmg.sh"
Cohesion: 0.13
Nodes (14): BinaryInstaller.DetectionStatus, SetupStepView, .body, .canInstall, .hooksDetail, .hooksTone, .hooksValue, .isSuccess (+6 more)

### Community 772 - ".show"
Cohesion: 0.25
Nodes (6): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow

### Community 776 - "DecodedWSFrame"
Cohesion: 0.16
Nodes (6): ExpressibleByStringLiteral, StringError, .init(_:), .init(stringLiteral:), Result, MobileBridgeAISuggestTests

### Community 778 - "ToolPolicy"
Cohesion: 0.36
Nodes (7): Document, Bool, Set, String, URL, ToolPolicy, .defaultURL

### Community 784 - "AutomationSummary"
Cohesion: 0.39
Nodes (5): AutomationSummary, Bool, Date, String, UUID

### Community 787 - ".handleSettings"
Cohesion: 0.40
Nodes (3): String, URL, WorktreeSignatureTests

### Community 791 - "Set"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 793 - ".keyEvent"
Cohesion: 0.32
Nodes (5): SpecialKeyMappingTests, Bool, NSEvent, String, UInt16

### Community 802 - ".compute"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 809 - "AgentVectorIcon"
Cohesion: 0.32
Nodes (7): AgentMarkShape, AgentIconArt, AgentVectorIcon, Bool, CGSize, String, Shape

### Community 810 - "Keep awake with the lid closed"
Cohesion: 0.50
Nodes (3): Caveats, Keep awake with the lid closed, Setup

### Community 814 - "StdioTransport"
Cohesion: 0.23
Nodes (4): MCPServer, String, StdioTransport, AsyncStream

### Community 871 - "azt"
Cohesion: 0.50
Nodes (3): azt(), ibe(), q$e()

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
Nodes (17): .exit, String, String, String, String, KouenCLI, SessionID, String (+9 more)

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

### Community 2633 - "P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua)"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua), Scope (locked), Tests

### Community 2642 - "KouenCLI+Verify.swift"
Cohesion: 0.33
Nodes (5): Logical Design, Next Step, P43 — Add Repo/Folder to Workspace, Strategic Design, Tactical Design

### Community 3131 - "P38 Phase D — Kitty Conformance — Dev Task Progress"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 3132 - "P38 Phase E — Scripting Hooks — Dev Task Progress"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 3860 - "BrowserFileReloadTests.swift"
Cohesion: 0.12
Nodes (11): KouenSyntaxResources, BrowserFileReloadTests, CountingWebView, Nav, NSEvent, String, Void, WKNavigation (+3 more)

### Community 3896 - "Components.swift"
Cohesion: 0.07
Nodes (38): ButtonStyle, CommandRow, .body, GlassCard, .body, GlassPrimaryButtonStyle, GlassSecondaryButtonStyle, GlassSmallButtonStyle (+30 more)

## Knowledge Gaps
- **2396 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+2391 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1272 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `PerformanceBenchmarks` to `ThemeDocument`, `graphify reference: extra exports and benchmark`, `RD`, `.handleNormal`, `IPCRequest`, `Changed`, `AgentNotchRootView`, `LSPMessage`, `TerminalEmulator`, `.jumpToBlock`, `EngineConformanceTests`, `TerminalColorRole`, `GitPanelView.swift`, `VTParser`, `HarnessTerminalSurfaceView`, `.applyPreedit`, `.init`, `HarnessChrome`, `SpecialKey`, `HarnessTerminalSurfaceView`, `.request`, `WorktreeManager`, `SessionGroupHeaderRowView`, `Harness tmux-style capabilities`, `.readGrid(scrollbackOffset:)`, `.init`, `Added`, `Sendable`, `.addTab`, `Equatable`, `.bufferLine`, `MenuTarget`, `.characterIndex`, `String`, `CodingKeys`, `CodingKeys`, `HarnessSidebarPanelViewController.swift`, `eFe`, `RenderSchedulerTests`, `.viewWillMove`, `.buildCommand`, `.normalizedKey`, `Added`, `.keyEvent`, `.handleWake`, `HarnessSplitView`, `TabCell`, `KouenOverlayBackground`, `CommandHistorySearchController`, `PasteBufferStore`, `FrecencyDirectoryStore`, `.applyFontSize`, `HarnessCLI+Server.swift`, `.text`, `Completed Plans Archive`, `worktree_isolation_cli.robot`, `WorkbenchMRU`, `OptionStore`, `.parse`, `Added`, `HarnessDesign`, `.firstMatch`, `LSPDiagnostic`, `HarnessPaths`, `TerminalModes`, `AttachInputBatcher`, `shim.c`, `4. Technical Architecture`, `.dispatch`, `ScriptRuntime.swift`, `DaemonLauncher`, `AnyCodable`, `domain-design.md`, `AgentNotchViewModel`, `DamageTrackingTests`, `SoftIconButton`, `code:text (:workbench start swift)`, `[2.5.0] - 2026-06-12`, `HarnessGridTerminal`, `.firstWaitingTab`, `Added`, `Pipe`, `String`, `HistoryRingBuffer`, `ClientSummary`, `GlyphAtlas`, `code:block1 (SessionCoordinator.snapshot ──┐)`, `SwiftUI`, `AgentHookInstaller`, `.load`, `CommandTarget`, `.startWatching`, `PtyDrainCeilingBenchmark`, `User Story Mapping (MANDATORY)`, `RGBColor`, `Added`, `.testPaneLeafLegacyDecodeBackfillsSurfaceTabs`, `CopyModeGridSource`, `How to use Harness from the terminal only (no GUI)`, `PaneStyleSet`, `AsciiFastPathTests`, `DecodedImage`, `MobileBridgeBrowserTests`, `.compute`, `What You Must Do When Invoked`, `LiveResizeTests`, `Int`, `ThaiCombiningMarkTests`, `Added`, `.applyStyleDirective`, `MatchCategory`, `AntigravityTranscriptTurnsTests`, `What You Must Do When Invoked`, `TerminalFindBar`, `Harness Terminal — IDE Sidebar Feature Branch`, `CommandPromptController`, `ActiveTabCloseDisposition`, `FormatColor`, `Added`, `URLDetection`, `hJ`, `.decodeKeySpec`, `[1.5.1] - 2026-06-06`, `DECSpecialGraphics`, `BinaryRefresherTests`, `Added`, `InlineAICompletionView`, `[3.13.1] - 2026-07-02`, `VTConformanceCorpusTests`, `LSPServerRegistry`, `SessionSnapshot`, `.findSession`, `AppDelegate`, `PromptQueue`, `user-stories.md`, `GlyphRasterizer`, `BinaryInstaller`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `String`, `.classify`, `[3.9.5] - 2026-06-26`, `scheduleRender`, `PaneTarget`, `.lines`, `TerminalHostView`, `GridCompositor`, `Prompt`, `ANSIPalette`, `CellColorResolver`, `HarnessPathDisplay`, `SSHTunnelManagerTests`, `ExternalOpenKind`, `WorkbenchCommand`, `Added`, `PaneBorderStatus`, `[3.5.1] - 2026-06-20`, `.make`, `FileNode`, `ReflowPreviewTests`, `.body`, `HarnessTerminalSurfaceWorkerTests`, `SessionCoordinator`, `Split Right`, `workspace`, `FormatContextDaemonTests`, `release-hotfix.sh`, `WindowTitleStripView`, `.welcome`, `.path`, `ToolPolicy`, `DefaultTerminalManager`, `WindowSession`, `AutomationSummary`, `KeySpec`, `[2.5.0] - 2026-06-12`, `eFe`, `SyntaxTextView`, `.run`, `DisplayPanesOverlay`, `.menu`, `TerminalScrollbarView`, `FormatColor`, `click_ui_element`, `code:bash (harness-cli install-hooks hermes)`, `AgentHookStrategy`, `StatusLineWidthTests`, `.compute`, `JSONDecoder`, `Fixes Applied (layered)`, `GitHubCLIClient`, `NotificationBus`, `PaneNode`, `HarnessPaths.swift`, `.parse`, `PaletteFooter`, `ViPathTokenTests`, `Send Ex Command`, `Phase6KeysTests`, `Bug: Tab-Switch Black Screen`, `AgentSnapshot`, `Terminal AI Chat (⌘I inline overlay)`, `DesktopNotifier`, `LayoutNode`, `WorkspaceSymbolIndex`, `FloatingPaneController`, `.theme`, `README.md`, `.drawGlyph`, `Added`, `.makeModel`, `CommandExecutionError`, `.contentVC`, `Foundation`, `code:bash (harness-cli install-hooks openclaw)`, `code:bash (harness-cli install-hooks pi)`, `[2.2.3] - 2026-06-09`, `FileViewerViewController`, `Architecture Decisions — harness-terminal`, `SurfaceProgressTracker`, `.handleCat`, `[3.5.1] - 2026-06-20`, `.bufferLine`, `FormatStyledSegment.swift`, `RGBColor`, `generate-cheatsheet.js`, `Consumers`, `Git Panel`, `.run`, `.install`, `ScrollReuseTests`, `SurfaceProgressTrackerTests.swift`, `MCPServer`, `PromptQueue`, `terminal_stress_runner.py`, `NSTextField Leak in BoardViewController (P20 Performance)`, `SKILL-LOG.md`, `User Profile`, `Darwin`, `UI Automation — Robot Framework (P18)`, `.init`, `Split Panes (NSSplitView)`, `.setCellPixelSize`, `Fixed`, `json.json`, `rust.json`, `RealPtyLifecycleTests`, `.currentSize`, `SixelDecoder`, `AgentVectorIcon`, `.navigateCurrentFile`, `.delay`, `BoardCardView`, `PathToken`, `SessionEditor`, `GroupedSessionDaemonTests`, `Modifiers`, `FileTreeKeyboardNavigator`, `.encode`, `.init`, `.resize`, `PresentAttempt`, `HarnessOnboarding`, `String`, `.hitTest`, `ProjectDropTarget`, `ScrollbackTests`, `bC`, `ccRunCancel`, `SurfaceIO`, `ccRunGet`, `.bind`, `.panePathLookup`?**
  _High betweenness centrality (0.277) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `Terminal AI Chat (⌘I inline overlay)` to `AgentSessionSummary.swift`, `.handleCat`, `worktree_isolation_cli.robot`, `IPCRequest`, `.agentName`, `FormatStyledSegment.swift`, `User Story Mapping (MANDATORY)`, `PerformanceBenchmarks`, `TerminalColorRole`, `.parse`, `Consumers`, `.id`, `.decodeKeySpec`, `LSPMessage`, `PaneNode`, `Memory — harness-terminal`, `BoardViewController`?**
  _High betweenness centrality (0.220) - this node is a cross-community bridge._
- **Why does `fbt()` connect `callingPaneTarget` to `Recipe`, `[2.6.0] - 2026-06-13`, `CopyModeAction`, `BoardViewController`?**
  _High betweenness centrality (0.110) - this node is a cross-community bridge._
- **Are the 18 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `RenderScheduler`) actually correct?**
  _`KouenTerminalSurfaceView` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _2416 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.11895161290322581 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.015081822202565237 - nodes in this community are weakly interconnected._