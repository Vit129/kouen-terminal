# Graph Report - kouen-terminal  (2026-11-02)

## Corpus Check
- 934 files · ~1,040,501 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 19973 nodes · 57842 edges · 2776 communities (1518 shown, 1258 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8861 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `3d6a2e39`
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
1. `IPCRequest` - bridges 189 areas (208 edges)
2. `Command` - bridges 102 areas (108 edges)
3. `AgentKind` - bridges 86 areas (176 edges)
4. `IPCResponse` - bridges 80 areas (103 edges)
5. `t()` - bridges 79 areas (253 edges)
6. `KouenTerminalSurfaceView` - bridges 72 areas (345 edges)
7. `KouenPaths` - bridges 71 areas (150 edges)
8. `SessionCoordinator` - bridges 70 areas (235 edges)
9. `NSView` - bridges 69 areas (193 edges)
10. `SurfaceRegistry` - bridges 63 areas (224 edges)

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

## Communities (2776 total, 1258 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.12
Nodes (15): SavedLayoutStore, Bool, String, URL, UUID, PaneLayoutShape, branch, leaf (+7 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.08
Nodes (35): DaemonSubscription, .start(onData:onEnd:buffered:), .start(onResponse:onEnd:), Bool, Int32, TimeInterval, UInt64, UUID (+27 more)

### Community 2 - ".handleNormal"
Cohesion: 0.19
Nodes (10): BrowserOkAck, Sendable, T, ConnectionState, DraftPRAck, ErrorAck, FileAttachedAck, NWConnection (+2 more)

### Community 3 - "Changed"
Cohesion: 0.10
Nodes (9): Bool, String, UInt8, TerminalEmulator, .block(atPromptLine:), .captureLines(fromLine:toLine:), .onSetClipboard, String (+1 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.08
Nodes (20): ConcurrentIndexSet, .count, DaemonContentionTests, SubscriptionBox, .count, String, URL, DaemonRoundTripTests (+12 more)

### Community 5 - "IPCRequest"
Cohesion: 0.07
Nodes (23): String, UInt16, Data, DecodedReplyFrame, output, reply, DecodedRequestFrame, input (+15 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.09
Nodes (16): .event(_:), .interval(_:_:), StaticString, T, .testingPendingResize, PendingMainHop, PresentAttempt, encodeFailure (+8 more)

### Community 7 - "Command"
Cohesion: 0.09
Nodes (30): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+22 more)

### Community 8 - "LSPMessage"
Cohesion: 0.21
Nodes (10): EndpointConnector, Int32, String, decodeBoundedCString(), CChar, sockaddr, socklen_t, String (+2 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.10
Nodes (26): Int, Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock (+18 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.05
Nodes (43): DecodedImage, .byteCount, UInt8, Bool, CAMetalDrawable, String, String, UInt64 (+35 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.07
Nodes (29): IssueKeychainStore, Bool, String, IssuePriority, .color, high, low, medium (+21 more)

### Community 12 - "Changed"
Cohesion: 0.19
Nodes (10): .windowSection, KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:fileSearchRoots:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:), .scrollbackLines, ClaudeSessionMode, Decoder, Double (+2 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.12
Nodes (29): blockTokens(), br(), checkbox(), codespan(), constructor(), de(), del(), html() (+21 more)

### Community 14 - "VTParser"
Cohesion: 0.15
Nodes (8): StringKind, apc, dcs, UInt8, UnsafeBufferPointer, VTParser, .feed(_:), VTParserHandler

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.05
Nodes (24): .tab(forSurfaceKey:), AgentScanner, Bool, DispatchSourceTimer, TimeInterval, DaemonCommandExecutor, Command, SurfaceRegistry (+16 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.11
Nodes (11): .agentColorBinding, colors, PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Double, String (+3 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.19
Nodes (11): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, .selectedHost (+3 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.11
Nodes (14): Kind, primary, secondary, KouenPillButton, .init(title:kind:), .isHovered, .isPressed, SoftIconButton (+6 more)

### Community 19 - "SpecialKey"
Cohesion: 0.21
Nodes (15): CustomStringConvertible, atomicWrite(), backupCorruptFile(), ensureDirectories(), fnv1aHex(), KouenPathsError, .description, socketPathTooLong (+7 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.20
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.08
Nodes (22): IndexingIterator, LayoutTemplate, Bool, Double, surfaceID, SessionEditor, .split(node:targetPaneID:direction:paneCount:before:), .split(node:targetPaneID:with:direction:beforeTarget:) (+14 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.01
Nodes (593): _0t(), _1n(), _3n(), _4e(), _5e(), _5n(), _6e(), _8n() (+585 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.11
Nodes (6): SessionID, GroupedSessionTests, SessionGroup, Set, SurfaceID, Phase67Tests

### Community 24 - ".request"
Cohesion: 0.13
Nodes (14): .addSurface(tabID:paneID:), .addSurface(to:paneID:surfaceID:cwd:), .tab(containingPaneID:), .tab(for:), .tabIndex(surfaceKey:), .tabIndex(tabID:), .tabIndex(workspaceID:tabID:), Bool (+6 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.09
Nodes (21): ModelProvider, .agentKindForLogo, aider, anthropic, azure, copilot, cursor, google (+13 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.14
Nodes (14): CompletionPopupView, .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:), .isHovered, Bool (+6 more)

### Community 27 - "RGBColor"
Cohesion: 0.15
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 28 - ".parse"
Cohesion: 0.01
Nodes (473): l, V, em(), z(), _4n(), _6n(), _7n(), a0() (+465 more)

### Community 29 - "Added"
Cohesion: 0.08
Nodes (21): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, AutomationScheduler (+13 more)

### Community 30 - "Notification"
Cohesion: 0.10
Nodes (45): Ame(), aQt(), CUe(), cXt(), een(), Eme(), eVe(), eXt() (+37 more)

### Community 31 - "Sendable"
Cohesion: 0.14
Nodes (12): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+4 more)

### Community 32 - ".addTab"
Cohesion: 0.08
Nodes (27): .body, FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body (+19 more)

### Community 33 - "Equatable"
Cohesion: 0.12
Nodes (10): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, PaneID (+2 more)

### Community 34 - "DaemonClient"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 35 - "MenuTarget"
Cohesion: 0.07
Nodes (44): AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem, fetchGitStatus() (+36 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.14
Nodes (28): Cleanup Test Repo, Close Isolated Session Keeps Dirty Worktree, Close Isolated Session Removes Clean Worktree, Close One Isolated Does Not Affect Another, Close Session With Split Panes Removes Worktree, Create Isolated Session, Create Isolated Session Via CLI, Get Active Pane (+20 more)

### Community 37 - "String"
Cohesion: 0.08
Nodes (23): .lspPosition(characterOffset:), CodingKeys, error, id, jsonrpc, method, params, result (+15 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.07
Nodes (21): SessionStore, DispatchWorkItem, TimeInterval, PendingVersionBanner, welcome, whatsNew, State, Bool (+13 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.24
Nodes (8): ProjectDropTarget, .init(coder:), .init(frame:), NSCoder, NSDraggingInfo, NSDragOperation, NSRect, URL

### Community 41 - "CodingKeys"
Cohesion: 0.14
Nodes (18): ClientRecord, CountBox, DaemonServer, .guiBrowserFD, PendingBrowserRequest, PendingWrite, .remaining, Bool (+10 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.33
Nodes (6): invalidArgument, missingArgument, CommandParser, Command, Set, String

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.12
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.11
Nodes (18): Process, SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, SSHTunnelManager (+10 more)

### Community 46 - ".buildCommand"
Cohesion: 0.06
Nodes (16): .readJSONLLines(from:fromOffset:), ClaudeSessionLocator, ClaudeTranscriptLine, Role, assistant, user, Any, Bool (+8 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.08
Nodes (16): UnsafeBufferPointer, TerminalCellWidth, normal, spacerTail, wide, UnsafeBufferPointer, .cursorVisible, CharacterWidth (+8 more)

### Community 48 - "HookEvent"
Cohesion: 0.07
Nodes (33): Executor, Hook, HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane (+25 more)

### Community 49 - "DaemonServer"
Cohesion: 0.14
Nodes (19): .modifierFlags, NSEvent, BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, CodingKeys (+11 more)

### Community 50 - "Added"
Cohesion: 0.06
Nodes (22): TerminalDamage, Range, String, TerminalBufferMatch, TerminalBufferSearch, RenderColor, String, TextGrid (+14 more)

### Community 51 - ".keyEvent"
Cohesion: 0.07
Nodes (36): KouenCommands, ColorKind, .base, bg, fg, underline, ComposedCell, .asGridCell (+28 more)

### Community 52 - "Fixed"
Cohesion: 0.06
Nodes (43): A1(), a2(), aat(), akn(), bEn(), bln(), bpn(), bw() (+35 more)

### Community 53 - "Added"
Cohesion: 0.11
Nodes (20): AgentRow, .agentColor, .executables, .hookButton, .hookButtonTitle, HookState, failed, idle (+12 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.04
Nodes (56): AnyTransition, AnyView, Color, .hexString, AgentNotchPeekEvent, AgentNotchRootView, .body, .bottomRadius (+48 more)

### Community 55 - "TabCell"
Cohesion: 0.15
Nodes (7): AnyCodable, JSONRPCError, Bool, Int32, Pipe, String, ToolRegistry

### Community 56 - "NSPanel"
Cohesion: 0.14
Nodes (13): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+5 more)

### Community 57 - "BellScanState"
Cohesion: 0.13
Nodes (12): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+4 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.13
Nodes (27): MTLClearColor, MTLCommandBuffer, BgInstance, CursorCacheKey, .invertsGlyph, DecoInstance, EncodedFrameInstances, EncodedRowInstances (+19 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.18
Nodes (3): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess

### Community 60 - "ViEngine"
Cohesion: 0.02
Nodes (356): pe(), r, X(), A(), code(), R(), a(), aDt() (+348 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.07
Nodes (21): GitAheadBehind, GitResult, .isSuccess, GitWorktreeInfo, Bool, Int32, String, GitParsers (+13 more)

### Community 62 - "ComposedCell"
Cohesion: 0.16
Nodes (13): SwarmSpawnSpec, Bool, closeSurface, CallRecorder, .cancelCalls, .closeCalls, .harnessCalls, .surfaceCalls (+5 more)

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
Cohesion: 0.02
Nodes (136): _2t(), _3e(), a1t(), Af(), b2t(), bC(), bCn(), cDt() (+128 more)

### Community 67 - "String"
Cohesion: 0.13
Nodes (16): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+8 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.20
Nodes (6): NSEvent, Bool, Character, NSRange, NSTextView, String

### Community 69 - ".compose"
Cohesion: 0.12
Nodes (12): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, input (+4 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.08
Nodes (41): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+33 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 72 - "XCTestCase"
Cohesion: 0.09
Nodes (24): Ac(), agt(), c8n(), cae(), cAn(), cht(), ctn(), e2n() (+16 more)

### Community 73 - "README.md"
Cohesion: 0.50
Nodes (3): Hermes → Kouen, One-line install, Required: approve the hook

### Community 74 - "[2.6.0] - 2026-06-13"
Cohesion: 0.03
Nodes (38): NSRangePointer, NSEvent, Any, Bool, CGFloat, NSEvent, NSMenu, NSMenuItem (+30 more)

### Community 75 - "OptionStore"
Cohesion: 0.11
Nodes (14): StatusLineView, .init(coder:), CGFloat, Never, NSAttributedString, NSCoder, NSColor, NSLayoutConstraint (+6 more)

### Community 76 - ".parse"
Cohesion: 0.16
Nodes (10): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab, UUID (+2 more)

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
Cohesion: 0.08
Nodes (13): .receive(_:), DispatchSemaphore, FluidityBenchmarks, NSWindow, String, UInt64, NSWindow, KouenTerminalSurfaceWorkerTests (+5 more)

### Community 83 - "LSPClient"
Cohesion: 0.11
Nodes (16): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeState (+8 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.12
Nodes (9): .captureLines(joinWrapped:), .feed(_:), .promptRows, .readGrid(scrollbackOffset:), ScrollbackTests, Character, String, SemanticPromptTests (+1 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.07
Nodes (28): BrowserPaneRegistry, BrowserPaneView, .activeTab, .init(url:paneID:), .init(url:paneID:webView:), BrowserProgressLine, .init(frame:), BrowserTab (+20 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.10
Nodes (15): FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect, String, URL (+7 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.14
Nodes (14): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+6 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.09
Nodes (22): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+14 more)

### Community 89 - ".cursorPos"
Cohesion: 0.13
Nodes (5): .setupPrompt, hooks, AgentHookInstallerTests, String, URL

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.14
Nodes (11): CKouenSys, pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal (+3 more)

### Community 91 - "TerminalModes"
Cohesion: 0.13
Nodes (7): ControlKeyNormalizer, Bool, String, ShortcutRecorderSerializer, String, ControlKeyNormalizerTests, ShortcutRecorderSerializerTests

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.19
Nodes (4): AgentHistoryMultiAgentCoverageTests, Bool, String, URL

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.08
Nodes (17): .pruneMissingSessions(validTranscriptPaths:), .search(query:limit:), Set, .effectiveResumeCommand(claudeMode:), LiveClaudeAgentEntry, .placement, ClaudeSessionMode, ClaudeCloudSessionStore (+9 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.20
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 95 - "shim.c"
Cohesion: 0.13
Nodes (17): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerModel, DirectoryPickerView, .body (+9 more)

### Community 96 - "Harness Usage"
Cohesion: 0.19
Nodes (8): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, String, PaneStyleTests

### Community 97 - "PaneContainerView"
Cohesion: 0.02
Nodes (229): a(), b(), c(), d(), e(), f(), g(), h() (+221 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.10
Nodes (6): o, aZ(), e0(), eie(), eZ(), wZ()

### Community 99 - ".dispatch"
Cohesion: 0.16
Nodes (12): FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID, KouenFeature (+4 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.06
Nodes (35): Error, PtyError, launchFailed, LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed (+27 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.12
Nodes (14): AsyncRunCoordinator, OutputBuffer, ProcessResult, .isSuccess, ProcessRunner, Bool, CheckedContinuation, DispatchWorkItem (+6 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.05
Nodes (39): Array, GroupHeaderRow, .body, PickerItem, .groupLabel, historyBlock, .id, recipe (+31 more)

### Community 104 - "Recipe"
Cohesion: 0.18
Nodes (6): AgentDetector, Date, Int32, TimeInterval, ProcessScan, Int32

### Community 105 - "Changelog"
Cohesion: 0.18
Nodes (13): .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didFinish:), .webView(_:didStartProvisionalNavigation:), .init(title:isActive:onSelect:onClose:), LoadCompletionState, Bool, CheckedContinuation (+5 more)

### Community 106 - "domain-design.md"
Cohesion: 0.13
Nodes (10): ScrollbackFile, .highWater, Bool, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.10
Nodes (24): aNt(), AS(), bvt(), cc(), d2(), dce(), dwn(), e6() (+16 more)

### Community 108 - ".resolve"
Cohesion: 0.14
Nodes (10): ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID, String, SurfaceID (+2 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.16
Nodes (7): SGRMouse, SGRMouseEvent, Bool, UInt8, SGRMouseTests, String, UInt8

### Community 110 - "SoftIconButton"
Cohesion: 0.21
Nodes (5): CopyModeReducerTests, FakeGrid, .totalLines, Set, String

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.08
Nodes (12): TerminalGridCell, HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor, Bool, ClosedRange (+4 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.11
Nodes (6): GitPanelView, .isHidden, Any, DispatchWorkItem, NSMenuItem, UnsafeMutableRawPointer

### Community 114 - ".firstWaitingTab"
Cohesion: 0.14
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 115 - ".encode"
Cohesion: 0.10
Nodes (11): String, AsyncCLIResultBox, LSPDefinitionPayload, LSPDiagnosticsPayload, LSPStatusPayload, Error, Result, String (+3 more)

### Community 116 - "SessionGroup"
Cohesion: 0.10
Nodes (16): AgentBrowserPaneTracker, SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, SessionID, Set (+8 more)

### Community 117 - "PaneNode"
Cohesion: 0.09
Nodes (11): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+3 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.22
Nodes (7): AgentRoutingRuleStore, Bool, String, URL, UUID, AgentRoutingRuleStoreTests, URL

### Community 119 - "Harness command reference"
Cohesion: 0.12
Nodes (17): Agent safety CLI (`kouen-cli`), Attaching from a plain terminal, Bindings, Buffers (paste store), Composition, Hooks, Inspection (CLI / control mode), Kouen command reference (+9 more)

### Community 120 - "Added"
Cohesion: 0.29
Nodes (7): CopyModeSideEffect, beginSearchEntry, cancel, copy, copyAndCancel, none, paste

### Community 121 - "Changed"
Cohesion: 0.19
Nodes (6): Case, ReflowCorpusTests, .corpus, .goldenDir, String, URL

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
Cohesion: 0.17
Nodes (13): AgentMark, Scanner, .atEnd, SVGPath, Bool, CGFloat, CGPoint, CGRect (+5 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.10
Nodes (24): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), .stats (+16 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.08
Nodes (25): KouenChromePalette, Bool, CGFloat, NSColor, String, Coordinator, DiffAnalysis, DiffFileItem (+17 more)

### Community 129 - "SwiftUI"
Cohesion: 0.12
Nodes (11): FilePreviewCoordinator, FileTabID, Set, String, FileTab, .title, FileTabManager, .hasOpenTabs (+3 more)

### Community 131 - ".install"
Cohesion: 0.27
Nodes (3): TabID, WorkspaceID, GitPanelViewWorktreeNavigationTests

### Community 132 - "AgentHookInstaller"
Cohesion: 0.25
Nodes (4): AgentTableEntry, Bool, Set, String

### Community 133 - ".load"
Cohesion: 0.12
Nodes (16): AgentSessionHistoryView, .body, .footerView, HistoryMenuProxy, Any, Bool, CGFloat, Date (+8 more)

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.17
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 135 - "CommandTarget"
Cohesion: 0.16
Nodes (7): DispatchWorkItem, NSRange, NSString, Void, SyntaxTextView, .init(frame:), SyntaxTextViewDirtyStateTests

### Community 136 - ".startWatching"
Cohesion: 0.21
Nodes (4): CommandTarget, String, UUID, TargetSpecTests

### Community 137 - "ActivePaneService"
Cohesion: 0.11
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.16
Nodes (9): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, Set, SurfaceID, Tab (+1 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.21
Nodes (9): Scanner, .atEnd, SVGPathParser, Bool, CGPath, CGPoint, Character, Set (+1 more)

### Community 140 - "Added"
Cohesion: 0.06
Nodes (35): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, SessionGroup, SessionID (+27 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.10
Nodes (17): AgentUsage, .contextTokens, .init(from:), .init(inputTokens:outputTokens:cacheReadTokens:cacheWriteTokens:thinkingTokens:totalCostUSD:), .shortSummary, CodingKeys, cacheReadTokens, cacheWriteTokens (+9 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.08
Nodes (28): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, PaletteMode, errors (+20 more)

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.17
Nodes (31): aQ(), bme(), bqt(), bYt(), cbe(), DD(), Eqt(), Fa() (+23 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 146 - "DecodedImage"
Cohesion: 0.15
Nodes (8): ContextResolutionEngine, Bool, String, Bool, String, TokenGuard, ContextResolutionEngineTests, String

### Community 147 - "FileTreeWatcher"
Cohesion: 0.11
Nodes (20): .pairedAlreadyBanner, .pairingQRPanel, FleetJobItem, .isActive, .launchAgentScriptPath, .statusDisplay, AutomationsFleetView, .automationsList (+12 more)

### Community 148 - "TriState"
Cohesion: 0.03
Nodes (129): a4e(), al(), aTn(), aw(), awt(), axn(), b2(), b6() (+121 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.16
Nodes (11): tool, KouenDaemonToolsTests, String, URL, Document, Bool, Set, String (+3 more)

### Community 151 - ".evaluate"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 152 - "Added"
Cohesion: 0.11
Nodes (17): clamp(), statusHelp(), Date, Never, String, T, TabID, Task (+9 more)

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.23
Nodes (6): Divergence, Bool, String, TimeInterval, WorktreeInfo, WorktreeManager

### Community 154 - "LiveResizeTests"
Cohesion: 0.10
Nodes (10): SessionGroup, String, KouenSidebarPanelViewController, SessionGroup, String, NSMenu, NSMenuItem, SessionGroup (+2 more)

### Community 155 - "Int"
Cohesion: 0.11
Nodes (13): FileFuzzyMatcher, FileSearchRootScanner, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool (+5 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.08
Nodes (24): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, .acceptsFirstResponder (+16 more)

### Community 157 - "Added"
Cohesion: 0.18
Nodes (6): DefaultTerminalLaunchRequest, ShellQuoting, Bool, String, URL, DefaultTerminalLaunchRequestTests

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 159 - "MatchCategory"
Cohesion: 0.05
Nodes (26): CornerInfo, EditorDividerView, HitTestPassthroughView, KouenSplitView, .dividerColor, .dividerThickness, .init(coder:), PaneDragGripView (+18 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.13
Nodes (17): NSEvent, FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose (+9 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.11
Nodes (11): .readJSONLLines(from:), AntigravitySessionLocator, AntigravityTranscriptLine, Bool, Int32, NSRegularExpression, String, URL (+3 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.07
Nodes (18): NSResponder, NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent (+10 more)

### Community 163 - "Workspace"
Cohesion: 0.09
Nodes (22): AgentHistoryDateGroup, older, .sortOrder, thisWeek, today, yesterday, AgentSessionHistoryModel, .extraRecordsShown (+14 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.09
Nodes (23): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, IssueInfo (+15 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.10
Nodes (15): SSETransportTests, UInt16, KouenMCPServer, Bool, String, MCPServer, String, SSETransport (+7 more)

### Community 166 - "LiveSession"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.33
Nodes (3): TaskStore, URL, TaskStoreTests

### Community 168 - "Added"
Cohesion: 0.07
Nodes (23): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSEvent (+15 more)

### Community 169 - "Fixed"
Cohesion: 0.12
Nodes (12): FlippedView, .isFlipped, .removeWorktreeAction(_:), NSButton, NSColor, NSRect, NSScrollView, NSStackView (+4 more)

### Community 170 - "URLDetection"
Cohesion: 0.09
Nodes (11): Bool, Range, Set, String, URLDetection, CGFloat, CGRect, Range (+3 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.14
Nodes (15): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+7 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.18
Nodes (5): AgentNotchViewModel, Bool, CGFloat, Duration, String

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.09
Nodes (8): KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), SpawnedAgentSurface, Bool, ISO8601DateFormatter, String, Tab, UUID

### Community 175 - "RGBColorTests"
Cohesion: 0.23
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 176 - "Added"
Cohesion: 0.06
Nodes (13): NWEndpoint, Bool, NWListener, Sendable, String, UInt16, MobileBridgeServer, PipeBuffer (+5 more)

### Community 177 - ".rects"
Cohesion: 0.16
Nodes (3): CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 178 - "InlineAICompletionView"
Cohesion: 0.10
Nodes (24): Binding, .init(from:), .init(spec:command:note:repeatable:), CodingKeys, bindings, disabledSpecs, id, tables (+16 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.11
Nodes (13): SessionID, Status, ciFailing, done, mergeReady, open, running, Bool (+5 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.07
Nodes (17): KouenCLITests, CLIInstallLocator, DetachKeys, absent, invalid, parsed, OptionalUUID, absent (+9 more)

### Community 181 - "GridCompositorTests"
Cohesion: 0.14
Nodes (9): .removeWorktreeAction(path:), GitResult, Bool, GitResult, String, ValidateOutcome, WorktreeEntry, GitPanelViewToastErrorSummaryTests (+1 more)

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
Cohesion: 0.16
Nodes (11): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+3 more)

### Community 188 - "BrowserPaneView"
Cohesion: 0.12
Nodes (19): Motion, .entrance, .spring, .standardEase, CAMediaTimingFunction, KouenOnboarding, Bool, ImmersiveOnboardingWindowController (+11 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.11
Nodes (19): SurfaceProgressTracker, Bool, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void, State (+11 more)

### Community 190 - "user-stories.md"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.13
Nodes (7): ScriptRuntime, Any, String, URL, JSContext, JSValue, ScriptingTests

### Community 192 - "GlyphRasterizer"
Cohesion: 0.10
Nodes (21): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+13 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.16
Nodes (12): UInt16, TTYSize, RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal (+4 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.08
Nodes (11): Bool, NSDraggingInfo, NSDragOperation, NSCursor, NSPasteboard, URL, NSPasteboard, String (+3 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.17
Nodes (16): SessionRef, byID, byName, next, previous, String, UUID, TargetSpec (+8 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.18
Nodes (7): AIProviderAwakeService, .closedLidOptedIn, Bool, NSObjectProtocol, Set, String, AIProviderAwakeServiceTests

### Community 198 - ".classify"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.09
Nodes (25): bNt(), bu(), cNt(), dNt(), eNt(), eRe(), fNt(), h0t() (+17 more)

### Community 202 - "PaletteModel"
Cohesion: 0.09
Nodes (14): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+6 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.21
Nodes (7): EnvironmentStore, Persisted, String, URL, global, EnvironmentStoreTests, URL

### Community 204 - "From tmux"
Cohesion: 0.29
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
Cohesion: 0.13
Nodes (6): BrowserLeaf, URL, DaemonSyncServiceBrowserPaneMergeTests, PaneID, PaneNodeBrowserTests, PaneNodeLayoutShapeTests

### Community 209 - "SettingsRemoteView"
Cohesion: 0.15
Nodes (14): Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow, launchStart, StartupMetrics (+6 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.20
Nodes (4): CompletionGenerator, String, .fishCompletionSource, CompletionGeneratorTests

### Community 211 - "PaneTarget"
Cohesion: 0.25
Nodes (7): Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 212 - ".translate"
Cohesion: 0.11
Nodes (9): String, WorkspaceID, CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab, DaemonSyncServiceBranchNotifyTests (+1 more)

### Community 213 - "String"
Cohesion: 0.11
Nodes (6): TimeInterval, AgentHandoffBuilder, Bool, String, HandoffDirectoryTests, AgentHandoffBuilderTests

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.33
Nodes (3): Any, WKScriptMessage, WKUserContentController

### Community 215 - ".lines"
Cohesion: 0.14
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 216 - "CellColorResolverTests"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 217 - "GridCompositor"
Cohesion: 0.08
Nodes (26): _7(), a6(), aJ(), AYt(), Cme(), DYt(), evt(), h2() (+18 more)

### Community 219 - "Prompt"
Cohesion: 0.12
Nodes (20): table(), tablecell(), tablerow(), Y(), AOt(), Ape(), bOt(), cX() (+12 more)

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
Cohesion: 0.24
Nodes (9): CopyModeGridSource, .promptRows, CopyModeReducer, Bool, Character, NSRegularExpression, Range, String (+1 more)

### Community 224 - "CellColorResolver"
Cohesion: 0.05
Nodes (48): MochaTheme, TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid (+40 more)

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.10
Nodes (11): .init(coder:), .init(coder:), .init(coder:), DesignModeElementInfo, DesignModePopoverViewController, .init(coder:), .init(title:properties:styles:onStyleChanged:onCopyCSS:onPromptAgent:), NSCoder (+3 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.04
Nodes (66): a9e(), aae(), aOn(), avn(), aXe(), bee(), c_n(), cvn() (+58 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.12
Nodes (9): .records, .searchQuery, .selectedAgents, .selectedScope, Set, UInt64, AgentSessionHistoryModelTests, Date (+1 more)

### Community 228 - "sessionRow"
Cohesion: 0.14
Nodes (7): KeybindingsStore, .fileURL, URL, KeybindingsStoreTests, URL, Void, String

### Community 229 - ".decide"
Cohesion: 0.12
Nodes (10): .logURL, KouenPaths, MutationResult, RemoteHost, RemoteHostStore, Bool, String, RemoteHostStoreTests (+2 more)

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
Cohesion: 0.09
Nodes (12): .snapshot, Bool, String, ThemeService, KouenOptions, ReconnectLatch, .isTripped, Bool (+4 more)

### Community 235 - "WorkbenchCommand"
Cohesion: 0.06
Nodes (29): .webView(_:createWebViewWith:for:windowFeatures:), .webView(_:didCommit:), WKNavigationAction, WKWebViewConfiguration, ObjectiveC, BrowserPaneViewTests, MockWebView, .isLoading (+21 more)

### Community 236 - "Added"
Cohesion: 0.20
Nodes (10): PaneRef, bottom, byID, byIndex, last, left, next, previous (+2 more)

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.12
Nodes (11): Bool, CGFloat, NSCoder, NSLayoutConstraint, NSPoint, NSRect, String, WindowTitleStripView (+3 more)

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.13
Nodes (6): agentWaitChannel(), HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 240 - "PaneBorderStatus"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 241 - "Added"
Cohesion: 0.04
Nodes (16): azt(), B0, BBe(), F7, Fze, Gg(), gPt(), ibe() (+8 more)

### Community 242 - "AgentBridge"
Cohesion: 0.22
Nodes (7): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController

### Community 243 - ".make"
Cohesion: 0.10
Nodes (22): ArtifactKind, html, image, markdown, text, AutomationsFleetModel, .load(detectScheduledRuns:), AutomationSource (+14 more)

### Community 244 - "FileNode"
Cohesion: 0.18
Nodes (8): FileNode, Bool, String, FileTreeScanOptions, ScoredMatch, Bool, String, .body

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.15
Nodes (16): ClaudeCodeHarness, Profile, edit, readonly, Run, RunState, cancelled, failed (+8 more)

### Community 247 - ".renderFixture"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.16
Nodes (11): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, .init(from:), .init(id:name:baseURL:modelID:), Decoder (+3 more)

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.12
Nodes (10): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+2 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 251 - "SessionCoordinator"
Cohesion: 0.15
Nodes (13): CodingKey, CodingKeys, createdAt, cwd, done, id, sessionID, status (+5 more)

### Community 252 - "NSViewRepresentable"
Cohesion: 0.13
Nodes (6): KeybindingsService, Bool, Command, String, .init(from:), Decoder

### Community 253 - "Split Right"
Cohesion: 0.24
Nodes (7): BinaryInstaller, .bundledMacOSDir, Bool, TimeInterval, BinaryInstallerVersionTests, String, URL

### Community 254 - "BoardViewController"
Cohesion: 0.16
Nodes (9): AgentListFormatter, Date, String, dvn(), ht(), AgentListFormatterTests, Bool, Date (+1 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.11
Nodes (12): MarkdownPreviewView, .webView(_:decidePolicyFor:decisionHandler:), Bool, MainActor, Sendable, String, URL, WKNavigationAction (+4 more)

### Community 256 - "GitMetadataProvider"
Cohesion: 0.26
Nodes (8): InstallResult, Shell, bash, fish, zsh, ShellIntegration, Bool, URL

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.18
Nodes (20): CoreImage, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription, .surfaceID, detectHost() (+12 more)

### Community 258 - "WindowTitleStripView"
Cohesion: 0.07
Nodes (16): DisplayWidth, String, Unicode, ReleaseNotes, Section, String, Run, String (+8 more)

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.16
Nodes (10): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+2 more)

### Community 260 - ".welcome"
Cohesion: 0.08
Nodes (25): CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display, found, .isReady (+17 more)

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 262 - ".install"
Cohesion: 0.14
Nodes (5): ContentAreaViewController, Bool, String, TabID, Notification

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
Nodes (7): Bool, Command, DispatchWorkItem, PaneID, String, UInt8, WindowSession

### Community 271 - "StatusLineView.swift"
Cohesion: 0.16
Nodes (8): ParsedShortcut, .displayString, PrefixKeymap, Any, Bool, NSEvent, String, TimeInterval

### Community 272 - "SGRMouseEvent"
Cohesion: 0.20
Nodes (16): Close Pane, Next Session, Previous Session, Split Down, Split Right, Cmd W Closes Pane When Split, Zombie Crash Rapid Split Close Cycle, Close Pane Removes Split (+8 more)

### Community 273 - "KeySpec"
Cohesion: 0.16
Nodes (13): BoxDrawing, Kind, arms, dashH, dashV, halfDown, halfLeft, halfRight (+5 more)

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.16
Nodes (9): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ProcessInfo (+1 more)

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.13
Nodes (15): EndpointTestStatus, done, idle, testing, ProviderKeyRow, .body, Bool, String (+7 more)

### Community 277 - ".run"
Cohesion: 0.14
Nodes (9): MTLRenderCommandEncoder, ImageTextureCache, MTLDevice, MTLTexture, Set, UInt8, ImageZBand, aboveText (+1 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.12
Nodes (6): ScreenPos, bottom, middle, top, KouenLSP, QuickLookUI

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.15
Nodes (12): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+4 more)

### Community 280 - ".menu"
Cohesion: 0.21
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.13
Nodes (9): FileTreeContext, NSHostingView, SessionID, String, Void, WorkspaceFileTreeView, .init(rootPath:), MainActor (+1 more)

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.14
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 283 - "FormatColor"
Cohesion: 0.26
Nodes (3): String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 284 - "click_ui_element"
Cohesion: 0.16
Nodes (6): LSPTextLocation, .position, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.17
Nodes (6): KouenIPC, SQLite3, PortableRelativeDateFormatter, Date, String, UUID

### Community 287 - ".apply"
Cohesion: 0.41
Nodes (5): InstallResult, ShellCompletionInstaller, Bool, String, URL

### Community 288 - "AgentHookStrategy"
Cohesion: 0.18
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 290 - "Process"
Cohesion: 0.23
Nodes (8): Bool, CGFloat, Character, NSRange, NSString, NSTextView, String, ViEngine

### Community 291 - "JSONDecoder"
Cohesion: 0.14
Nodes (9): KouenGridTerminal, .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8, String (+1 more)

### Community 292 - "Release runbook"
Cohesion: 0.29
Nodes (4): Full local signing path (needs a Developer ID cert; not currently used), How this fork actually releases, Release runbook, Scripted flow

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.08
Nodes (23): CodingKeys, error, id, jsonrpc, method, JSONRPCId, int, string (+15 more)

### Community 294 - "GitHubCLIClient"
Cohesion: 0.24
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 295 - "AgentApprovalBar"
Cohesion: 0.20
Nodes (7): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, FileChangeWatcherTests

### Community 296 - "NotificationBus"
Cohesion: 0.16
Nodes (3): KouenSettingsTests, URL, Void

### Community 297 - "settings.json"
Cohesion: 0.12
Nodes (20): SwarmDAGStore, String, UUID, SwarmFleetSnapshot, SwarmLane, pty, structured, SwarmTaskNode (+12 more)

### Community 299 - "PaneNode"
Cohesion: 0.06
Nodes (34): NSPoint, NSView, CGFloat, FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents (+26 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.13
Nodes (14): string, AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID, .snapshotPayload (+6 more)

### Community 301 - ".parse"
Cohesion: 0.22
Nodes (7): Group, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, CGFloat, NSTextField, NSWindow

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.15
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 303 - ".encodeMouse"
Cohesion: 0.17
Nodes (5): TabID, WorkspaceID, AgentCommandTests, String, Tab

### Community 304 - "00-inception-plan.md"
Cohesion: 0.16
Nodes (17): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+9 more)

### Community 305 - ".script"
Cohesion: 0.15
Nodes (12): Configuration, Int32, SessionGroup, SessionID, Tab, TabID, WorkspaceID, TabSelector (+4 more)

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 307 - "ViPathTokenTests"
Cohesion: 0.06
Nodes (19): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, PaneID, SurfaceID (+11 more)

### Community 308 - "Send Ex Command"
Cohesion: 0.15
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, PaneID, SurfaceID (+3 more)

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.11
Nodes (22): keys, ITerm2InlineImage, .heightArg, .preserveAspectRatio, .widthArg, Bool, String, UInt8 (+14 more)

### Community 312 - "AgentSnapshot"
Cohesion: 0.11
Nodes (20): statusColor(), Array, Bool, Date, Decoder, PaneID, String, TabID (+12 more)

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.08
Nodes (28): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary, RowKind (+20 more)

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.16
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

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
Cohesion: 0.19
Nodes (8): Darwin, Foundation, Glibc, AgentRoutingResolver, FormatContextBuilder, OSCTerminatorMatch, ShellLaunchProfile, .argv

### Community 322 - "DesktopNotifier"
Cohesion: 0.15
Nodes (16): DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:), .isWorktreeSession (+8 more)

### Community 323 - "LayoutNode"
Cohesion: 0.13
Nodes (18): dhn(), en(), fhn(), ghn(), gk(), GOt(), jUe(), kr() (+10 more)

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.06
Nodes (21): DaemonClientActor, TimeInterval, DaemonSessionService, .endpoint, .request(_:timeout:), Bool, TimeInterval, Endpoint (+13 more)

### Community 325 - "FloatingPaneController"
Cohesion: 0.24
Nodes (7): DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.15
Nodes (8): DispatchSource, DispatchQueue, DispatchSourceFileSystemObject, Int32, URL, Void, TranscriptFileWatcher, MobileBridgeTranscriptWatcherTests

### Community 327 - ".theme"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 330 - ".drawGlyph"
Cohesion: 0.24
Nodes (11): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Duration, String (+3 more)

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.26
Nodes (6): Bool, NSRange, NSString, NSTextView, String, unichar

### Community 332 - "Added"
Cohesion: 0.08
Nodes (36): AgentHistoryFTSIndex, .saveRecordsBatch(_:), CachedSessionEntry, Int32, Void, AgentHistoryScanner, .parseAntigravityTranscript(sessionID:fileURL:), .parseAntigravityTranscript(sessionID:fileURL:toIndex:) (+28 more)

### Community 333 - "RealPty"
Cohesion: 0.20
Nodes (8): ClaudeRunSummary, Date, Double, Int32, String, UUID, String, UUID

### Community 335 - ".makeModel"
Cohesion: 0.20
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
Nodes (20): AppKit, KouenCopyMode, KouenTerminalEngine, KouenTerminalKit, KouenTerminalRenderer, KouenTheme, Metal, ImmersiveEffects (+12 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.18
Nodes (9): String, AgentRoutingRule, Kind, path, stack, Bool, Date, UUID (+1 more)

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
Cohesion: 0.12
Nodes (12): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+4 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.13
Nodes (3): AgentLaunchCommandsTests, URL, Void

### Community 349 - "Contents.json"
Cohesion: 0.18
Nodes (3): Bool, NSEvent, NSPopover

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.40
Nodes (5): PaneOutputWaiter, PaneOutputWaitResult, CheckedContinuation, Never, UInt64

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.06
Nodes (42): SettingsAppearanceView, .autoTheme, .body, .themeSection, SliderRow, .body, .displayValue, Bool (+34 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.15
Nodes (9): CoreGraphics, CoreText, ImageIO, ShapedGlyphSignature, CGFloat, CGGlyph, String, NerdFontFallbackTests (+1 more)

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.15
Nodes (11): copyMode, esc(), fs, globalShortcuts, KEYBINDINGS, prefixTable, renderTable(), ROOT (+3 more)

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.18
Nodes (3): Bool, Int32, String

### Community 355 - ".deepMerge"
Cohesion: 0.19
Nodes (13): ProjectGroupWatcher, StreamBox, Bool, DispatchQueue, escaping, FSEventStreamRef, MainActor, Never (+5 more)

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.08
Nodes (25): NaturalLanguage, .deleteSession(sessionID:), .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:surfaceTag:topicSegments:), .needsReindex(sessionID:mtime:fileSize:), .saveRecord(_:mtime:fileSize:), .searchRanked(query:limit:includeSnippet:), AgentHistoryFTSMatch, ExtractedTranscriptContent (+17 more)

### Community 357 - ".handleCat"
Cohesion: 0.07
Nodes (49): Codable, BrowserSnapshotAck, BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserRequestPayload, close (+41 more)

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.18
Nodes (9): NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView, .cornerConfiguration (+1 more)

### Community 359 - "OcclusionTests"
Cohesion: 0.18
Nodes (11): Typography, .badge, .kbd, .paletteHeader, .paletteTitle, .rowMeta, .rowTitle, .sectionLabel (+3 more)

### Community 360 - "State"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.27
Nodes (8): LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab, TabID, WorkspaceID

### Community 362 - "RGBColor"
Cohesion: 0.13
Nodes (4): NSTextView, KouenApp, GitPanelViewDiffPopoverTests, GitPanelViewFSEventFilterTests

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.08
Nodes (19): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+11 more)

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.10
Nodes (16): AgyModelCatalog, Catalog, Date, String, TimeInterval, AgyMobileCommands, String, ClaudeMobileCommands (+8 more)

### Community 366 - "Consumers"
Cohesion: 0.13
Nodes (15): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+7 more)

### Community 367 - "DaemonStats"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 368 - "Tab"
Cohesion: 0.23
Nodes (8): LSPFileSession, Never, String, Task, URL, Void, object, Bool

### Community 370 - ".encode"
Cohesion: 0.17
Nodes (7): .lspPosition(for:), .onCurrentCWD, .onCurrentFile, Bool, NSString, NSTextView, String

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.16
Nodes (4): KouenThemeCatalog, .allThemes, String, KouenThemeCatalogTests

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.12
Nodes (17): DataBox, .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:) (+9 more)

### Community 373 - "Prompt"
Cohesion: 0.05
Nodes (22): Am(), bze(), _c(), Cm(), EQ(), FBe(), fQ, Gbe() (+14 more)

### Community 374 - ".run"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

### Community 375 - ".install"
Cohesion: 0.09
Nodes (32): Encodable, AgyModelsPush, AISuggestionAck, AttachedAck, Body, BrowserFramePush, Cred, DetachedAck (+24 more)

### Community 376 - "ScrollReuseTests"
Cohesion: 0.08
Nodes (16): RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), ScrollbackEntry, ScrollbackReplaySegment, Bool, CChar, DaemonSurfaceID, Int32 (+8 more)

### Community 377 - "Identifiable"
Cohesion: 0.19
Nodes (10): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+2 more)

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 379 - "MCPServer"
Cohesion: 0.11
Nodes (11): URL, String, String, KouenFilePreviewLoader, KouenViewError, binaryOrUnsupportedEncoding, missingPath, tooLarge (+3 more)

### Community 380 - "PromptQueue"
Cohesion: 0.17
Nodes (8): NSHostingView, NSLayoutConstraint, TerminalTabBarView, .delegate, .init(frame:), .leadingInset, .mouseDownCanMoveWindow, .trailingInset

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.13
Nodes (6): CGImage, ImageLimits, Bool, ImageDecoder, ImageProtocolTests, String

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.12
Nodes (17): OnboardingStep, complete, discover, .id, setup, shell, .title, welcome (+9 more)

### Community 385 - "INDEX.md"
Cohesion: 0.15
Nodes (11): KouenTerminalSurfaceFocusTests, OcclusionTests, NSWindow, String, TimeInterval, SpecialKeyMappingTests, Bool, NSEvent (+3 more)

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.16
Nodes (9): FileGraphInfo, GraphifyLSPBridge, Double, String, URL, GraphifyLSPBridgeTests, Any, String (+1 more)

### Community 387 - "User Profile"
Cohesion: 0.16
Nodes (12): .effectiveResumeCommand(mode:), AgentLaunchCommands, String, AgentSessionMode, cloud, .launchCommand, .launchFlags, local (+4 more)

### Community 388 - "Darwin"
Cohesion: 0.17
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

### Community 389 - "HarnessCLITests"
Cohesion: 0.07
Nodes (50): aUe(), aXt(), aze(), bXt(), cJ(), Cqt(), dqt(), Dr() (+42 more)

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.37
Nodes (4): KouenFeatureMarkdownSync, Bool, String, URL

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.18
Nodes (13): Branch Change In Shared Folder Is Not Isolated Unprompted, CLI Isolate Creates Worktree And Session, CLI Isolate With Custom Branch Name, Close Session Keeps Dirty Worktree, Close Session Removes Clean Worktree, Create Isolated Session And Select, Git Checkout In Normal Session Does Not Affect Isolated, Isolate Without Branch Uses Detached HEAD (+5 more)

### Community 402 - "View"
Cohesion: 0.14
Nodes (7): KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, BinaryInstallerDisplayTests, OnboardingEnvironmentTests

### Community 403 - "PresentAttempt"
Cohesion: 0.25
Nodes (4): KeyTokenParser, Bool, String, KeyTokenParserTests

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.22
Nodes (4): String, URL, UUID, WorktreeIsolationDaemonTests

### Community 405 - "AgentIconRenderer"
Cohesion: 0.14
Nodes (12): CGFloat, NSCoder, SessionID, String, Void, TaskDashboardBody, .body, TaskDashboardView (+4 more)

### Community 406 - "main.swift"
Cohesion: 0.25
Nodes (8): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String

### Community 407 - "Fixed"
Cohesion: 0.10
Nodes (17): .body, .mcpButton, json, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter (+9 more)

### Community 408 - "IPC Architecture"
Cohesion: 0.18
Nodes (10): AssistantLine, ClaudeAdapter, Content, Message, ResultLine, Bool, Double, String (+2 more)

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.30
Nodes (4): Bool, OptionStore, OptionStoreTests, URL

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.17
Nodes (3): ShellIntegrationTests, .repoRoot, URL

### Community 412 - "go.json"
Cohesion: 0.10
Nodes (11): aD(), crn, ELt(), ezt(), GGe, Gwe(), Hzt(), Kp() (+3 more)

### Community 414 - "json.json"
Cohesion: 0.06
Nodes (29): JSONDecoder, JSONEncoder, CodingKeys, cols, createdAt, dataBase64, rows, timeMs (+21 more)

### Community 415 - "markdown.json"
Cohesion: 0.24
Nodes (7): MTLLibrary, MTLRenderPipelineState, CGFloat, MTLBuffer, MTLDevice, String, T

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.27
Nodes (6): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection

### Community 417 - "rust.json"
Cohesion: 0.21
Nodes (5): FDWatchdog, DispatchSourceTimer, String, TimeInterval, FDWatchdogTests

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.09
Nodes (20): CGFloat, DisplayLinkTarget, MainSplitViewController, .setSidebarVisible(_:), SplitChromeDelegate, .sidebarMaxWidth, .sidebarMinWidth, .splitView(_:constrainMaxCoordinate:ofSubviewAt:) (+12 more)

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
Cohesion: 0.29
Nodes (8): AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand, Bool, Set

### Community 423 - "SixelDecoder"
Cohesion: 0.10
Nodes (25): .filteredJobs, MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith (+17 more)

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
Cohesion: 0.30
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 428 - "TaskDashboardView"
Cohesion: 0.27
Nodes (9): Command Prompt, Find In Files, Git Panel, Open Command Palette, Switch To Session 1, Switch To Session 2, Rapid Session Switch While Typing, Switch Between Isolated And Normal Session (+1 more)

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.23
Nodes (9): AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor (+1 more)

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.18
Nodes (10): ArraySlice, Equatable, Request, Any, Bool, Date, String, VSCodeChatSession (+2 more)

### Community 431 - "BoardCardView"
Cohesion: 0.12
Nodes (24): .color, BoardCard, BoardColumn, .name, BoardColumnKind, .displayName, done, error (+16 more)

### Community 432 - "PathToken"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 434 - "Project History"
Cohesion: 0.15
Nodes (12): OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Bool, Value, bool (+4 more)

### Community 435 - ".init"
Cohesion: 0.14
Nodes (8): BellScanState, esc, normal, stringEsc, SurfaceMonitor, BellScanTests, Bool, UInt8

### Community 436 - "WaitForRegistry"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: animateSidebar setContentLeadingInset MainSplitViewController, Source Nodes

### Community 437 - "PickerItemRow"
Cohesion: 0.07
Nodes (26): A7(), a8(), bGt(), c8(), ene(), ern(), G4(), G7() (+18 more)

### Community 438 - "SessionEditor"
Cohesion: 0.10
Nodes (17): .requestDaemon(_:), .syncFromDaemon(metadataOnly:), ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy (+9 more)

### Community 439 - "SetupStepView"
Cohesion: 0.16
Nodes (8): brn, grn, hrn(), JGe(), KGe(), prn(), qGe(), zGe()

### Community 440 - "LegacySnapshot"
Cohesion: 0.18
Nodes (8): PluginLoader, String, ScriptAPI, ScriptError, .errorDescription, evaluationError, unsupportedPlatform, JavaScriptCore

### Community 441 - "RemoteHostStore"
Cohesion: 0.23
Nodes (6): ProjectGroupResolver, String, String, .trimmed, AgentTitleInference, Bool

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
Cohesion: 0.24
Nodes (9): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+1 more)

### Community 447 - "PaletteMode"
Cohesion: 0.19
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.18
Nodes (10): Bug 1 - Rotation Grace Slot Keeps The Previous Token Redeemable, Bug 1 - Rotation Shifts The Outgoing Token Into The Grace Slot, Bug 1 - Stop Fully Clears The Grace Slot, Bug 1 - Token Lifetime Not Regressed Below The Human-Flow Window, Bug 2 - Client onerror Does Not Clobber The Server Error Banner, Bug 2 - No Abrupt Cancel Immediately After The Error Text, Bug 2 - Reject Path Closes Gracefully With Policy-Violation Code 1008, Bug 3 - QR Not Printed When No Listener Is Ready (+2 more)

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.14
Nodes (11): BrowserOcclusionTests, BrowserTabRepaintTests, RepaintCountingWebView, Any, Bool, Error, MainActor, Sendable (+3 more)

### Community 451 - ".run"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.42
Nodes (6): AgentIconRenderer, CGFloat, NSColor, NSImage, String, .agentChipsView

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.24
Nodes (4): GroupedSessionDaemonTests, SessionGroup, String, URL

### Community 455 - "ComposerPanel"
Cohesion: 0.12
Nodes (16): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+8 more)

### Community 457 - ".normalizedKey"
Cohesion: 0.21
Nodes (3): .hasAdapter(for:), Bool, ClaudeCodeHarnessTests

### Community 458 - "FileTreeKeyboardNavigator"
Cohesion: 0.33
Nodes (4): .setSidebarVisible(_:animated:), SidebarPlacementSyncTests, CGFloat, Void

### Community 459 - ".encode"
Cohesion: 0.36
Nodes (3): KouenSplitViewTests, LayoutProbeView, CGFloat

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
Cohesion: 0.27
Nodes (7): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8

### Community 466 - "PlatformSys.swift"
Cohesion: 0.22
Nodes (10): DotView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor, NSRect (+2 more)

### Community 467 - ".moveSelection"
Cohesion: 0.14
Nodes (14): OverlayBackground, Context, OverlayBackground, Context, .init(coder:), KouenOverlayBackground, .init(coder:), .init(coder:) (+6 more)

### Community 468 - "Never"
Cohesion: 0.24
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 469 - "PresentAttempt"
Cohesion: 0.22
Nodes (8): DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSViewCornerConfiguration, SurfaceID, Void

### Community 470 - "DispatchTime"
Cohesion: 0.39
Nodes (4): SessionGroup, Any, String, Tab

### Community 471 - ".evaluateStyled"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 473 - "HarnessOnboarding"
Cohesion: 0.27
Nodes (4): ArchitectureGuardTests, .repoRoot, String, URL

### Community 474 - "String"
Cohesion: 0.25
Nodes (6): calculate(), constructor(), kOt(), mBt, r2e(), sOt()

### Community 475 - ".hitTest"
Cohesion: 0.30
Nodes (5): SearchBenchmarks, String, UInt64, URL, Void

### Community 476 - "StatusDotView"
Cohesion: 0.40
Nodes (3): EUe(), eYt(), tYt()

### Community 477 - ".encode"
Cohesion: 0.13
Nodes (11): .init(frame:), ChromeBackdrop, .init(role:), KouenDesign, RuntimeGlassEffectView, .init(frame:), Bool, NSColor (+3 more)

### Community 478 - ".install"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 479 - "ScrollbackTests"
Cohesion: 0.21
Nodes (7): .init(forTesting:), UUID, Void, PanePipe, .subscribe(surfaceID:handler:), FileHandle, UUID

### Community 480 - "Command Prompt Architecture"
Cohesion: 0.24
Nodes (11): Close Tab, New Tab, Cmd Shift W Force Closes Tab, Cmd T Creates New Session, Cmd W Closes Tab When Single Pane, Window Survives Full Shortcut Sequence, Zombie Crash Close Tab While Typing, Zombie Crash Rapid Close While Typing (+3 more)

### Community 481 - ".testKouenRendererFixtureDefaultTextReportsPlausibleGlyphStats"
Cohesion: 0.12
Nodes (10): item, CodexSessionLocator, CodexTranscriptLine, Any, Bool, Int32, String, URL (+2 more)

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
Cohesion: 0.50
Nodes (5): ehn(), gmn(), Jc(), pce(), s7e()

### Community 489 - "SurfaceIO"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: BrowserPaneView createTab openBrowserPane navigation WebKit, Source Nodes

### Community 490 - "ccRunGet"
Cohesion: 0.10
Nodes (18): a9n(), Bm(), Em(), Fm(), gat(), h9n(), j_n(), jm() (+10 more)

### Community 491 - ".update"
Cohesion: 0.32
Nodes (4): PaneID, SessionGroup, Tab, first

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 494 - "ccRunInfo"
Cohesion: 0.33
Nodes (5): Kouen LSP Diagnostics Does Not Crash, Kouen LSP Hover Returns Result, Kouen LSP Start Returns JSON, Kouen View Binary Shows Guard Message, Kouen View Prints File Content

### Community 495 - ".makeDiffScrollView"
Cohesion: 0.13
Nodes (3): CSIParams, .count, UInt8

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.25
Nodes (3): MobileBridgeAttachFileTests, String, URL

### Community 499 - "GlassEffectView"
Cohesion: 0.21
Nodes (8): RemoteHostsService, .activeHostName, String, DaemonSessionError, daemonError, .description, unexpectedResponse, String

### Community 501 - "Fixed"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 502 - "ACP Client (Shelved)"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 503 - "ReleaseNotesGuardTests"
Cohesion: 0.23
Nodes (8): KouenChrome, PaletteFooter, .body, .body, AttributedString, NSColor, DirectoryPickerFooter, .body

### Community 504 - "String"
Cohesion: 0.12
Nodes (11): PaletteWindowDelegate, AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow, NSImage (+3 more)

### Community 505 - ".tickFeatureWorktreeSweepLocked"
Cohesion: 0.15
Nodes (3): AgentHookInstallerCLI, String, String

### Community 506 - "SwarmFleetBody"
Cohesion: 0.11
Nodes (5): files, CryptoKit, KouenDaemonCore, Network, MobileBridgeGitDiffTests

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
Cohesion: 0.23
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 512 - ".setAttribute"
Cohesion: 0.40
Nodes (5): CodingKeys, excludedPaths, id, name, sourceFolder

### Community 513 - "ThemeDocument"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.18
Nodes (11): Never, NSRegularExpression, Set, String, Task, URL, Void, WorkspaceSymbolIndex (+3 more)

### Community 515 - "RD"
Cohesion: 0.09
Nodes (19): ExperienceMode, agent, .displayName, .foregroundsAgents, full, .notchEnabledByDefault, persistent, .persistsSessionsByDefault (+11 more)

### Community 516 - "terminal_stress_runner.py"
Cohesion: 0.27
Nodes (6): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor

### Community 521 - ".daemonIsStale"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 523 - "fFe"
Cohesion: 0.19
Nodes (9): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 524 - "TerminalColorRole"
Cohesion: 0.09
Nodes (18): .agentInfo(forWorktreePath:), .agentInfo(forWorktreePath:tabs:), Tab, Reason, errored, finished, needsInput, RowState (+10 more)

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
Cohesion: 0.07
Nodes (17): Tab, AnyObject, ObjectIdentifier, TimeInterval, ZombieHoldRegistry, BrowserIntegrationController, PaneID, PaneContainerView (+9 more)

### Community 531 - "BrowserProgressLine"
Cohesion: 0.18
Nodes (10): AgentDetection, MatchSource, ownProcess, wrapperLaunch, RawMatch, WrapperOptionBehavior, keepScanning, matchValue (+2 more)

### Community 534 - ".zoomWindowIfDoubleClick"
Cohesion: 0.32
Nodes (3): ReflowPreviewTests, .feeds, String

### Community 535 - "AgentNotification"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 537 - "NSObject"
Cohesion: 0.40
Nodes (5): CwdAuthorizationError, foreignPathRejected, .message, missingSessionOrCwd, other

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.06
Nodes (33): .body, MainActor, Void, SessionDividerRowView, .init(coder:), .init(frame:), SessionGroupHeaderRowView, .init(coder:) (+25 more)

### Community 539 - "SavedLayoutIPCDaemonTests"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 540 - ".delay"
Cohesion: 0.14
Nodes (12): InputGate, .siblings, SurfaceIO, .currentSubscription, String, SurfaceID, UInt16, UInt64 (+4 more)

### Community 544 - "CodingKeys"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 546 - "LegacySnapshot"
Cohesion: 0.18
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 547 - "NSObject"
Cohesion: 0.16
Nodes (14): ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool, Command (+6 more)

### Community 552 - "PaneLabelDaemonTests"
Cohesion: 0.60
Nodes (4): DiscoverStepView, .body, Point, String

### Community 553 - "harness.resource"
Cohesion: 0.21
Nodes (12): CGFloat, Configuration, Range, Tab, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, TabBarLayoutMetrics, .pitch (+4 more)

### Community 554 - "eFe"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 556 - "MobileBridgeSpawnTests"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 557 - ".viewWillMove"
Cohesion: 0.47
Nodes (3): URL, TimeoutError, WorktreeLargeOutputRegressionTests

### Community 558 - "FindWindowMatcherTests"
Cohesion: 0.11
Nodes (4): TimeInterval, EndpointClientTests, String, URL

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 560 - "AgentNotification"
Cohesion: 0.23
Nodes (5): ListeningPortScanner, Int32, Set, String, ListeningPortScannerTests

### Community 561 - ".handleClaudeCode"
Cohesion: 0.20
Nodes (9): AnyObject, CommandExecutionError, daemonError, .description, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor (+1 more)

### Community 562 - "BrowserResponsePayload"
Cohesion: 0.40
Nodes (4): Build, Release & Git Workflow, Build / Test / Run, Release packaging order, Worktree constraint

### Community 563 - "AgentNotchViewModel.swift"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

### Community 565 - "WriteOrigin"
Cohesion: 0.09
Nodes (22): Notification.Name, KouenGit, Logger, os, OSSignposter, LatencyMonitor, UInt64, FrameDropCause (+14 more)

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 568 - ".installChromeBackground"
Cohesion: 0.06
Nodes (38): AgentChipView, .init(coder:), .intrinsicContentSize, ChromeRole, sidebar, tabBar, Colors, FontSize (+30 more)

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.26
Nodes (5): Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.08
Nodes (26): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+18 more)

### Community 572 - "LayoutProbeView"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 574 - "FileTreeKeyboardNavigator"
Cohesion: 0.36
Nodes (4): Bool, String, UUID, TaskDaemonBridge

### Community 576 - "Phase67Tests"
Cohesion: 0.22
Nodes (5): RepoResolver, Bool, String, RepoResolverTests, String

### Community 579 - "main.swift"
Cohesion: 0.29
Nodes (7): AnimatablePair, NotchShape, .animatableData, CGFloat, CGPath, CGRect, Path

### Community 580 - "ViInputMode"
Cohesion: 0.20
Nodes (7): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, NSCoder, Void

### Community 582 - ".groupByRoot"
Cohesion: 0.31
Nodes (5): Lexer, .atEnd, .peek, Bool, Character

### Community 583 - "WorkbenchMRU"
Cohesion: 0.18
Nodes (10): DecodedWSFrame, Bool, ConnectionState, NWConnection, String, UInt8, WSFrameParseResult, frame (+2 more)

### Community 584 - "GUt"
Cohesion: 0.36
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 585 - "P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress"
Cohesion: 0.24
Nodes (4): HintModeOverlay, Any, NSEvent, String

### Community 586 - "Product"
Cohesion: 0.20
Nodes (10): Agent Safety Net (Checkpoints, Verification, Write Guards), Claude Code Harness, Editor & LSP, How It Feels, Kouen Features, Mobile, Remote And Headless, Stack (+2 more)

### Community 587 - "sheet-cheat.html"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 589 - "Endpoint"
Cohesion: 0.22
Nodes (6): String, URL, ThemeCatalogEmbedTests, .embedSwift, .repoRoot, .sourceJSON

### Community 591 - "main.swift"
Cohesion: 0.20
Nodes (3): ClaudeCodeHarnessIPCTests, String, URL

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

### Community 596 - ".feed(_:)"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 597 - "TerminalColorRole"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 598 - ".encode"
Cohesion: 0.20
Nodes (6): LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled

### Community 599 - ".terminalHostIfExists"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 600 - "stability_release.robot"
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
Cohesion: 0.17
Nodes (6): Bool, NSEvent, NSEvent, SidebarTitlebarHeaderView, .mouseDownCanMoveWindow, NSEvent

### Community 613 - "INDEX.md"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 617 - "ScriptFileWatcher"
Cohesion: 0.17
Nodes (11): LinePos, end, firstNonBlank, start, ViDiagnosticNavigator, ViMode, insert, normal (+3 more)

### Community 622 - "sBt"
Cohesion: 0.33
Nodes (5): AgentBridge, AgentTarget, Bool, String, SurfaceID

### Community 623 - "inlineTokens"
Cohesion: 0.24
Nodes (3): KouenMCP, KouenBrowserToolsTests, URL

### Community 627 - "ActiveTabCloseDisposition"
Cohesion: 0.33
Nodes (4): OutputTrigger, OutputTriggerStore, Bool, String

### Community 628 - "ReplayStep"
Cohesion: 0.10
Nodes (7): KouenCLI, KouenCompositor, KouenCore, HistorySearchQueryTests, MemoCommandTests, URL, TaskCommandTests

### Community 629 - "graphify reference: query, path, explain"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 637 - "TerminalScrollbarView"
Cohesion: 0.08
Nodes (18): NSScrollView, NSWindow, Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent (+10 more)

### Community 641 - "[3.10.0] - 2026-06-27"
Cohesion: 0.25
Nodes (7): #kouen, #practice, #score, #shell, #total, #unix, #vim

### Community 645 - "KouenBrowserToolsTests"
Cohesion: 0.27
Nodes (3): DaemonReconnectPolicy, TimeInterval, DaemonReconnectPolicyTests

### Community 646 - "[3.10.1] - 2026-06-27"
Cohesion: 0.24
Nodes (5): RiskyCommandClassifier, Bool, NSRegularExpression, String, RiskyCommandClassifierTests

### Community 648 - "PtyDrainCeilingBenchmark"
Cohesion: 0.13
Nodes (16): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, .bytesPerWakeup, .mbps (+8 more)

### Community 659 - "LayoutTemplate"
Cohesion: 0.25
Nodes (7): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, NSEvent

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
Cohesion: 0.22
Nodes (4): DaemonBrowserRoutingTests, IPCCodecInvariantTests, String, URL

### Community 675 - ".detect"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 677 - "New Tab"
Cohesion: 0.15
Nodes (14): SettingsTerminalView, .body, .experienceSection, .fontReadout, .fontSection, .shellSection, Bool, String (+6 more)

### Community 678 - "FormatColor"
Cohesion: 0.11
Nodes (13): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+5 more)

### Community 679 - "TriState"
Cohesion: 0.08
Nodes (11): SessionCoordinator, .selectWorkspace(byIndex:), Bool, Double, PaneID, SessionID, String, SurfaceID (+3 more)

### Community 680 - "AgentVectorIcon"
Cohesion: 0.28
Nodes (8): .body, AgentMarkShape, AgentIconArt, AgentVectorIcon, Bool, CGSize, String, Shape

### Community 681 - ".tabIDsToNotify"
Cohesion: 0.17
Nodes (11): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile, regionEdit (+3 more)

### Community 682 - "Workbench commands (IDE-like workflow)"
Cohesion: 0.33
Nodes (6): Board and attention, Errors and LSP, File navigation, Search, Task runner, Workbench commands (IDE-like workflow)

### Community 683 - ".normalizedKey"
Cohesion: 0.31
Nodes (4): GraphifyIndexCache, S, Set, String

### Community 684 - "CommandParseError"
Cohesion: 0.25
Nodes (7): CommandParseError, .description, emptyInput, expectedCommand, missingFlag, unknownCommand, unterminatedString

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 686 - "DECSpecialGraphics"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 688 - ".keyEvent"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 690 - ".update"
Cohesion: 0.40
Nodes (5): Additional `kouen-cli` subcommands, Agents, context and scratchpad, Daemon and diagnostics, Editor, LSP and setup, Sessions, tabs and recording

### Community 692 - "smoke-dmg.sh"
Cohesion: 0.32
Nodes (6): CGFloat, ResizeDirection, down, left, right, up

### Community 694 - "Result"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 696 - "TerminalTabBarDelegate"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 698 - ".send"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 700 - ".agentInfo(forWorktreePath:tabs:)"
Cohesion: 0.31
Nodes (5): AgyAdapter, Result, ResultLine, String, UUID

### Community 702 - "PromptQueue"
Cohesion: 0.12
Nodes (6): PromptQueue, String, SurfaceID, Void, PromptQueueBar, NSWindow

### Community 703 - "ColorKind"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 704 - "main.swift"
Cohesion: 0.36
Nodes (7): daemonLog(), detectStaleInstance(), installSignalHandlers(), removeForeignPIDFile(), Sendable, String, writePIDFile()

### Community 709 - "String"
Cohesion: 0.57
Nodes (3): ProjectConfig, Bool, String

### Community 710 - "MainWindowController"
Cohesion: 0.10
Nodes (14): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+6 more)

### Community 713 - "AutomationScheduler"
Cohesion: 0.24
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 714 - "_Ue"
Cohesion: 0.29
Nodes (3): ScrollbackPersistenceTests, String, URL

### Community 715 - "TerminalProgressReport"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 721 - "ThaiGrid"
Cohesion: 0.20
Nodes (8): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, ClosedRange, String

### Community 723 - "DaemonClientError"
Cohesion: 0.33
Nodes (6): DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed

### Community 724 - ".copy"
Cohesion: 0.09
Nodes (10): MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, String, SurfaceID (+2 more)

### Community 726 - "AgentNotchViewModel.swift"
Cohesion: 0.20
Nodes (7): Scope, pane, session, tab, workspace, ScopedKey, URL

### Community 727 - "PromptQueueBar"
Cohesion: 0.12
Nodes (15): agy, claude, codex, copilot, hermes, kouen, __kouen_agy_next, __kouen_claude_next (+7 more)

### Community 728 - "TerminalHostView"
Cohesion: 0.08
Nodes (14): DetachedPaneOverlay, .init(coder:), .init(frame:style:), OutputCoalescer, Style, detached, reconnectingChip, NSCoder (+6 more)

### Community 729 - "DaemonError"
Cohesion: 0.33
Nodes (6): DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed

### Community 730 - "TargetSpec.swift"
Cohesion: 0.33
Nodes (6): Command, .targetKind, TargetKind, pane, session, window

### Community 731 - "Phase6KeysTests"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: SSETransport auth token isRunning

### Community 733 - "KouenIPC"
Cohesion: 0.40
Nodes (4): AgentNotchPresentation, closed, open, peek

### Community 735 - "companion.test.mjs"
Cohesion: 0.22
Nodes (7): block, escFn, lineFilter, md, page, script, swift

### Community 736 - "graphify reference: add a URL and watch a folder"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 737 - ".resolve"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 745 - "p11_scripting.robot"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 750 - "ClipboardOSCTests"
Cohesion: 0.23
Nodes (13): kouen.bash script, agy(), claude(), codex(), copilot(), hermes(), kouen(), __kouen_agy_next() (+5 more)

### Community 763 - "AntigravityTranscriptTurnsTests"
Cohesion: 0.40
Nodes (5): Motion, .reduce, .spring, Animation, Bool

### Community 768 - "CodexTranscriptTests"
Cohesion: 0.29
Nodes (5): ThaiClusterCopyTests, ThaiGrid, .columns, .totalLines, .viewportRows

### Community 770 - "create-dmg.sh"
Cohesion: 0.13
Nodes (13): BinaryInstaller.DetectionStatus, SetupStepView, .canInstall, .hooksDetail, .hooksTone, .hooksValue, .isSuccess, .notifTone (+5 more)

### Community 772 - ".show"
Cohesion: 0.33
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

### Community 776 - "DecodedWSFrame"
Cohesion: 0.19
Nodes (5): ExpressibleByStringLiteral, StringError, .init(_:), .init(stringLiteral:), MobileBridgeAISuggestTests

### Community 778 - "URL"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 781 - ".encode"
Cohesion: 0.50
Nodes (4): WriteOutcome, complete, failed, wouldBlock

### Community 784 - "AutomationSummary"
Cohesion: 0.39
Nodes (5): AutomationSummary, Bool, Date, String, UUID

### Community 785 - "TaskDashboardGroupingTests"
Cohesion: 0.50
Nodes (4): MouseEventKind, drag, press, release

### Community 787 - ".handleSettings"
Cohesion: 0.40
Nodes (3): String, URL, WorktreeSignatureTests

### Community 793 - ".configureEnvironment"
Cohesion: 0.11
Nodes (17): SwarmFleetBody, .body, SwarmFleetView, .init(coder:), SwarmNodeRowView, .body, .statusColor, CGFloat (+9 more)

### Community 795 - "SettingsFileSearchSection"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 797 - "CopyModeSideEffect"
Cohesion: 0.33
Nodes (6): h1t(), hae(), jgn(), pwn(), sfn(), _Ue()

### Community 802 - ".compute"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 809 - "WriteOrigin"
Cohesion: 0.18
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 810 - "Keep awake with the lid closed"
Cohesion: 0.50
Nodes (3): Caveats, Keep awake with the lid closed, Setup

### Community 813 - "Phase6KeysTests"
Cohesion: 0.12
Nodes (18): DiffLineType, added, deleted, modified, Notification.Name, ObserverToken, NSCoder, NSObjectProtocol (+10 more)

### Community 814 - ".resolveAgentName"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: KouenPreviewHome environment key daemon launch at startup, Source Nodes

### Community 886 - "Switch To Session 1"
Cohesion: 0.21
Nodes (8): SettingsAdvancedView, .body, Bool, String, SettingsFileSearchSection, .body, String, SwiftUI

### Community 887 - "PaletteMode"
Cohesion: 0.11
Nodes (10): OptionSet, KeySpec, .description, .init(key:modifiers:), Modifiers, String, UInt8, PrefixKeymapFallbackTests (+2 more)

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
Cohesion: 0.14
Nodes (15): .exit, DaemonClient, String, KouenCLI, SessionID, String, Bool, String (+7 more)

### Community 2176 - "Changed"
Cohesion: 0.29
Nodes (6): Locked decisions (user-confirmed), Logical Design, P38 Phase A — Cross-Agent Worktree Diff/Review Dashboard — Design, Strategic Design, Tactical Design, Verification gate (this phase)

### Community 2242 - "P42 — Workspace Sidebar Panels"
Cohesion: 0.29
Nodes (6): Logical Design, Next Step, P42 — Workspace Sidebar Panels, Parked (not in scope), Strategic Design, Tactical Design

### Community 2462 - "NSStackView"
Cohesion: 0.14
Nodes (11): Bool, CGFloat, NSCoder, Selector, String, Void, TabNavigation, TabNavigationButtons (+3 more)

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
Cohesion: 0.14
Nodes (9): NSEvent, BrowserFileReloadTests, CountingWebView, Nav, NSEvent, String, Void, WKNavigation (+1 more)

### Community 3896 - "View"
Cohesion: 0.09
Nodes (33): ButtonStyle, CommandRow, .body, GlassCard, .body, GlassPrimaryButtonStyle, GlassSecondaryButtonStyle, GlassSmallButtonStyle (+25 more)

## Knowledge Gaps
- **2404 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+2399 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1258 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Work-memory lessons

**Known dead ends** — questions that led nowhere; don't re-derive.
- "KouenPreviewHome environment key daemon launch at startup" -> `KouenPaths`

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `TerminalEmulator` to `callingPaneTarget`, `graphify reference: extra exports and benchmark`, `.handleNormal`, `Changed`, `IPCRequest`, `AgentNotchRootView`, `.jumpToBlock`, `LSPMessage`, `ThemeDocument`, `PerformanceBenchmarks`, `EngineConformanceTests`, `TerminalColorRole`, `Changed`, `VTParser`, `HarnessTerminalSurfaceView`, `.applyPreedit`, `.init`, `BrowserProgressLine`, `SpecialKey`, `HarnessTerminalSurfaceView`, `.zoomWindowIfDoubleClick`, `SplitPaneCoordinator`, `.request`, `.readGrid(scrollbackOffset:)`, `SessionGroupHeaderRowView`, `Harness tmux-style capabilities`, `.delay`, `.init`, `Added`, `Sendable`, `.addTab`, `Equatable`, `.bufferLine`, `MenuTarget`, `.characterIndex`, `String`, `CodingKeys`, `TerminalColorGamut`, `harness.resource`, `HarnessSidebarPanelViewController.swift`, `CodingKeys`, `eFe`, `.viewWillMove`, `.buildCommand`, `.normalizedKey`, `AgentNotification`, `MobileBridgeSpawnTests`, `Added`, `.keyEvent`, `HarnessSplitView`, `TabCell`, `KouenOverlayBackground`, `CommandHistorySearchController`, `PasteBufferStore`, `FrecencyDirectoryStore`, `HarnessCLI+Server.swift`, `.text`, `Completed Plans Archive`, `worktree_isolation_cli.robot`, `.groupByRoot`, `WorkbenchMRU`, `P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress`, `[2.6.0] - 2026-06-13`, `OptionStore`, `.parse`, `Added`, `HarnessDesign`, `.firstMatch`, `LSPClient`, `LSPDiagnostic`, `TerminalGridCell`, `HarnessPaths`, `code:bash (# Terminal 1: Create workspace with long-running job)`, `AttachInputBatcher`, `shim.c`, `.dispatch`, `ScriptRuntime.swift`, `DaemonLauncher`, `AnyCodable`, `Recipe`, `domain-design.md`, `DamageTrackingTests`, `SoftIconButton`, `code:text (:workbench start swift)`, `HarnessGridTerminal`, `.firstWaitingTab`, `.encode`, `Changed`, `Pipe`, `String`, `HistoryRingBuffer`, `TerminalScrollbarView`, `GlyphAtlas`, `code:block1 (SessionCoordinator.snapshot ──┐)`, `SwiftUI`, `AgentHookInstaller`, `.load`, `KouenBrowserToolsTests`, `CommandTarget`, `.startWatching`, `PtyDrainCeilingBenchmark`, `User Story Mapping (MANDATORY)`, `RGBColor`, `.testPaneLeafLegacyDecodeBackfillsSurfaceTabs`, `CopyModeGridSource`, `PaneStyleSet`, `AsciiFastPathTests`, `DecodedImage`, `FileTreeWatcher`, `LayoutTemplate`, `HarnessDaemonToolsTests`, `Added`, `What You Must Do When Invoked`, `Int`, `ThaiCombiningMarkTests`, `Harness Terminal — IDE Sidebar Feature Branch`, `MatchCategory`, `What You Must Do When Invoked`, `TerminalFindBar`, `Workspace`, `CommandPromptController`, `ActiveTabCloseDisposition`, `FormatColor`, `TriState`, `Fixed`, `URLDetection`, `.decodeKeySpec`, `[1.5.1] - 2026-06-06`, `DECSpecialGraphics`, `BinaryRefresherTests`, `Added`, `smoke-dmg.sh`, `GridCompositorTests`, `LSPServerRegistry`, `SessionSnapshot`, `AppDelegate`, `P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client`, `PromptQueue`, `user-stories.md`, `GlyphRasterizer`, `BinaryInstaller`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `ResizeHUDView`, `Feature Provenance — harness-terminal`, `.classify`, `PaletteModel`, `[3.9.5] - 2026-06-26`, `scheduleRender`, `ThaiGrid`, `PaneTarget`, `.lines`, `ANSIPalette`, `CellColorResolver`, `SSHTunnelManagerTests`, `ExternalOpenKind`, `.scan`, `WorkbenchCommand`, `Added`, `PaneBorderStatus`, `[3.5.1] - 2026-06-20`, `.make`, `FileNode`, `ReflowPreviewTests`, `HarnessTerminalSurfaceWorkerTests`, `Split Right`, `release-hotfix.sh`, `workspace`, `CodexTranscriptTests`, `WindowTitleStripView`, `.show`, `.install`, `.path`, `DefaultTerminalManager`, `WindowSession`, `AutomationSummary`, `KeySpec`, `[2.5.0] - 2026-06-12`, `.run`, `TerminalScrollbarView`, `.configureEnvironment`, `FormatColor`, `click_ui_element`, `AgentHookStrategy`, `StatusLineWidthTests`, `Process`, `JSONDecoder`, `.compute`, `Fixes Applied (layered)`, `GitHubCLIClient`, `NotificationBus`, `settings.json`, `PaneNode`, `HarnessPaths.swift`, `Phase6KeysTests`, `PaletteFooter`, `ViPathTokenTests`, `Send Ex Command`, `Phase6KeysTests`, `Bug: Tab-Switch Black Screen`, `AgentSnapshot`, `Terminal AI Chat (⌘I inline overlay)`, `DesktopNotifier`, `WorkspaceSymbolIndex`, `FloatingPaneController`, `README.md`, `.recordReapedGenerationForTesting`, `Added`, `CommandExecutionError`, `.contentVC`, `Foundation`, `code:bash (harness-cli install-hooks openclaw)`, `code:bash (harness-cli install-hooks pi)`, `[2.2.3] - 2026-06-09`, `FileViewerViewController`, `Contents.json`, `Background Polling & Snapshot Fanout — P22`, `Architecture Decisions — harness-terminal`, `Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)`, `SurfaceProgressTracker`, `.handleCat`, `.bufferLine`, `FormatStyledSegment.swift`, `RGBColor`, `generate-cheatsheet.js`, `Consumers`, `.encode`, `.run`, `.install`, `ScrollReuseTests`, `SurfaceProgressTrackerTests.swift`, `MCPServer`, `terminal_stress_runner.py`, `NSTextField Leak in BoardViewController (P20 Performance)`, `SKILL-LOG.md`, `UI Automation — Robot Framework (P18)`, `.selectAdjacentSession`, `.init`, `PresentAttempt`, `.setCellPixelSize`, `Fixed`, `Session/Tab/Pane Hierarchy & Top Bar (CASE-028)`, `NSStackView`, `json.json`, `markdown.json`, `rust.json`, `RealPtyLifecycleTests`, `yaml.json`, `.currentSize`, `SixelDecoder`, `AgentVectorIcon`, `.navigateCurrentFile`, `BoardCardView`, `PathToken`, `Project History`, `SessionEditor`, `GroupedSessionDaemonTests`, `TerminalModes`, `.init`, `.resize`, `Never`, `PresentAttempt`, `HarnessOnboarding`, `.hitTest`, `bC`, `.update`, `.makeDiffScrollView`, `.bind`, `ACP Client (Shelved)`, `ReleaseNotesGuardTests`?**
  _High betweenness centrality (0.248) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `Terminal AI Chat (⌘I inline overlay)` to `PresentAttempt`, `User Profile`, `AgentSessionSummary.swift`, `.handleCat`, `worktree_isolation_cli.robot`, `.agentName`, `TerminalEmulator`, `.id`, `.decodeKeySpec`, `TerminalColorRole`, `Consumers`, `Competitive Position (as of v3.12.0, 2026-07-02)`, `.buildCommand`, `PaneNode`, `BoardViewController`?**
  _High betweenness centrality (0.202) - this node is a cross-community bridge._
- **Why does `fbt()` connect `.parse` to `PaneContainerView`, `CopyModeAction`, `BoardViewController`?**
  _High betweenness centrality (0.110) - this node is a cross-community bridge._
- **Are the 18 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `RenderScheduler`) actually correct?**
  _`KouenTerminalSurfaceView` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _2424 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.11895161290322581 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.07832167832167833 - nodes in this community are weakly interconnected._