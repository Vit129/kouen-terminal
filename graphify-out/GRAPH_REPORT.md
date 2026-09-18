# Graph Report - kouen-terminal  (2026-09-18)

## Corpus Check
- 824 files · ~935,831 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 19672 nodes · 52470 edges · 2150 communities (615 shown, 1535 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 7701 edges (avg confidence: 0.73)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `99614f0c`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 343 edges
2. `i()` - 321 edges
3. `a()` - 284 edges
4. `t()` - 253 edges
5. `SessionCoordinator` - 232 edges
6. `TerminalEmulator` - 229 edges
7. `u()` - 219 edges
8. `SurfaceRegistry` - 200 edges
9. `IPCRequest` - 197 edges
10. `SessionEditor` - 182 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `KouenPaths` - bridges 60 areas (137 edges)
2. `AgentKind` - bridges 54 areas (137 edges)
3. `SessionCoordinator` - bridges 52 areas (232 edges)
4. `SurfaceRegistry` - bridges 43 areas (200 edges)
5. `Process` - bridges 42 areas (89 edges)
6. `SessionSnapshot` - bridges 40 areas (167 edges)
7. `IPCResponse` - bridges 35 areas (99 edges)
8. `Notification` - bridges 35 areas (66 edges)
9. `KouenTerminalSurfaceView` - bridges 34 areas (343 edges)
10. `MenuTarget` - bridges 34 areas (71 edges)

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

## Communities (2150 total, 1535 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.06
Nodes (32): SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, SessionID, SplitDirection (+24 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.15
Nodes (11): TerminalDamage, RenderColor, MetalRendererTests, RenderedFixture, Bool, MTLTexture, StaticString, String (+3 more)

### Community 2 - ".handleNormal"
Cohesion: 0.20
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 4 - "EngineConformanceTests"
Cohesion: 0.07
Nodes (29): DaemonClient, Int32, TimeInterval, UUID, Void, ClaudeCodeHarnessIPCTests, String, URL (+21 more)

### Community 5 - "IPCRequest"
Cohesion: 0.07
Nodes (23): UInt16, Data, OSCTerminatorMatch, DecodedReplyFrame, output, reply, DecodedRequestFrame, input (+15 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.11
Nodes (23): AnyTransition, AgentNotchPeekEvent, AgentNotchRootView, .body, .bottomRadius, .closedAccessibilityLabel, .closedTransition, .closedView (+15 more)

### Community 7 - "Command"
Cohesion: 0.09
Nodes (31): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+23 more)

### Community 8 - "LSPMessage"
Cohesion: 0.12
Nodes (13): .addSurface(tabID:paneID:), .addSurface(to:paneID:surfaceID:cwd:), .tab(containingPaneID:), .tabIndex(surfaceKey:), .tabIndex(workspaceID:tabID:), Bool, Date, SessionID (+5 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.12
Nodes (8): PerformanceBenchmarks, SurfaceMainThreadStallSample, Bool, Double, String, UInt64, UInt8, Void

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.06
Nodes (35): NSCursor, ResizeOverlayMode, afterFirst, always, never, ResizeOverlayPosition, bottomRight, center (+27 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.11
Nodes (13): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, PaneLeaf (+5 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.07
Nodes (43): a6(), aJ(), bXt(), cJ(), Cme(), dXt(), DYt(), F0() (+35 more)

### Community 14 - "VTParser"
Cohesion: 0.16
Nodes (8): StringKind, apc, dcs, UInt8, UnsafeBufferPointer, VTParser, .feed(_:), VTParserHandler

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.05
Nodes (44): aNt(), AS(), bhn(), bvt(), cc(), cct(), d2(), dce() (+36 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.12
Nodes (10): .captureLines(joinWrapped:), .feed(_:), .promptRows, .readGrid(scrollbackOffset:), ScrollbackTests, Character, String, TerminalGridSnapshot (+2 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.14
Nodes (10): ScrollbackFile, .highWater, Bool, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.08
Nodes (30): DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed, DaemonSubscription, .start(onData:onEnd:buffered:) (+22 more)

### Community 19 - "SpecialKey"
Cohesion: 0.04
Nodes (90): pe(), X(), ae(), ajt(), ate(), b6(), b8(), bat() (+82 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.24
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.06
Nodes (31): OverlayBackground, Context, OverlayBackground, Context, AgentChipView, .init(coder:), .init(frame:), .intrinsicContentSize (+23 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.01
Nodes (655): _0t(), _1n(), _2t(), _3e(), _4e(), _5e(), _5n(), a0() (+647 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.26
Nodes (8): OptionStore, Scope, pane, session, workspace, ScopedKey, URL, String

### Community 24 - ".request"
Cohesion: 0.14
Nodes (13): aXt(), Cqt(), Eme(), gXt(), GYt(), H7(), NR(), R0 (+5 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.07
Nodes (17): tab, SessionStore, DispatchWorkItem, TimeInterval, .tab(for:), .tab(forSurfaceKey:), DaemonCommandExecutor, Command (+9 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.12
Nodes (8): SessionCoordinator, Bool, Double, PaneID, PaneNode, SurfaceID, TabID, UUID

### Community 27 - "RGBColor"
Cohesion: 0.15
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 28 - ".parse"
Cohesion: 0.12
Nodes (15): StatusLineView, .init(coder:), CGFloat, FormatColor, Never, NSAttributedString, NSCoder, NSColor (+7 more)

### Community 30 - "Notification"
Cohesion: 0.14
Nodes (6): BrowserPaneView, DesignModeElementInfo, Any, NSPopover, NSWindow, String

### Community 31 - "Sendable"
Cohesion: 0.13
Nodes (13): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+5 more)

### Community 32 - ".addTab"
Cohesion: 0.14
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 33 - "Equatable"
Cohesion: 0.11
Nodes (14): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, PaneID (+6 more)

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
Cohesion: 0.08
Nodes (24): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSEvent (+16 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.15
Nodes (14): BrowserOkAck, ConnectionState, .authorized, .browserPaneID, .deviceID, .snapshotSubscription, .subscription, .surfaceID (+6 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.21
Nodes (9): Scanner, .atEnd, SVGPathParser, Bool, CGPath, CGPoint, Character, Set (+1 more)

### Community 41 - "CodingKeys"
Cohesion: 0.09
Nodes (22): ClientRecord, CountBox, DaemonServer, .guiBrowserFD, PendingBrowserRequest, PendingWrite, .remaining, Bool (+14 more)

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
Cohesion: 0.18
Nodes (4): TimeInterval, SSHTunnelManagerTests, String, URL

### Community 46 - ".buildCommand"
Cohesion: 0.09
Nodes (17): DaemonClientActor, TimeInterval, DaemonSessionError, daemonError, .description, unexpectedResponse, DaemonSessionService, .endpoint (+9 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.15
Nodes (9): ExpressibleByStringLiteral, NWEndpoint, StringError, .init(_:), .init(stringLiteral:), Bool, NWListener, String (+1 more)

### Community 48 - "HookEvent"
Cohesion: 0.13
Nodes (14): Executor, Hook, HookEvent, HookRegistry, Bool, Command, URL, UUID (+6 more)

### Community 49 - "DaemonServer"
Cohesion: 0.06
Nodes (40): CommandTarget, Command, .targetKind, PaneRef, bottom, byID, byIndex, last (+32 more)

### Community 51 - ".keyEvent"
Cohesion: 0.14
Nodes (21): CompositorPane, GridCompositor, .render(panes:status:statusSegments:), .render(panes:statusLines:), RenderCell, .cluster, .init(_:), .init(codepoint:combining0:combining1:fg:bg:underlineColor:bold:dim:italic:underline:blink:inverse:invisible:strikethrough:overline:) (+13 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.21
Nodes (9): Bool, CGFloat, Character, NSEvent, NSRange, NSString, NSTextView, String (+1 more)

### Community 55 - "TabCell"
Cohesion: 0.20
Nodes (6): AnyCodable, JSONRPCError, Bool, Int32, String, ToolRegistry

### Community 56 - "NSPanel"
Cohesion: 0.16
Nodes (10): QuickTerminalController, QuickTerminalPanelDelegate, Any, Bool, NSEvent, NSPanel, NSRect, NSScreen (+2 more)

### Community 57 - "BellScanState"
Cohesion: 0.09
Nodes (19): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+11 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.11
Nodes (34): MTLClearColor, MTLCommandBuffer, MTLRenderCommandEncoder, BgInstance, CursorCacheKey, .invertsGlyph, DecoInstance, EncodedFrameInstances (+26 more)

### Community 60 - "ViEngine"
Cohesion: 0.11
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.11
Nodes (25): ColorKind, .base, bg, fg, underline, ComposedCell, .asGridCell, .init(_:) (+17 more)

### Community 62 - "ComposedCell"
Cohesion: 0.22
Nodes (8): Group, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, CGFloat, NSTextField, NSView, NSWindow

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.08
Nodes (17): KouenThemeCatalog, .allThemes, String, KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex (+9 more)

### Community 67 - "String"
Cohesion: 0.13
Nodes (16): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+8 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.08
Nodes (13): String, UInt8, UnsafeBufferPointer, TerminalEmulator, .blocks, .onSetClipboard, TerminalColorRole, background (+5 more)

### Community 69 - ".compose"
Cohesion: 0.13
Nodes (7): ControlKeyNormalizer, Bool, String, ShortcutRecorderSerializer, String, ControlKeyNormalizerTests, ShortcutRecorderSerializerTests

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.09
Nodes (38): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+30 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 72 - "XCTestCase"
Cohesion: 0.02
Nodes (401): l, _4n(), _6n(), _7n(), a5n(), a8n(), aA(), abn() (+393 more)

### Community 73 - "README.md"
Cohesion: 0.50
Nodes (3): Hermes → Kouen, One-line install, Required: approve the hook

### Community 75 - "OptionStore"
Cohesion: 0.13
Nodes (14): ExperienceMode, agent, .displayName, .foregroundsAgents, full, .notchEnabledByDefault, persistent, .persistsSessionsByDefault (+6 more)

### Community 76 - ".parse"
Cohesion: 0.16
Nodes (11): Equatable, PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab (+3 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.21
Nodes (7): EnvironmentStore, Persisted, String, URL, global, EnvironmentStoreTests, URL

### Community 79 - "HarnessDesign"
Cohesion: 0.13
Nodes (13): MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem, SessionGroup (+5 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 82 - ".firstMatch"
Cohesion: 0.06
Nodes (17): .receive(_:), DispatchSemaphore, FluidityBenchmarks, NSWindow, String, UInt64, NSWindow, KouenTerminalSurfaceWorkerTests (+9 more)

### Community 83 - "LSPClient"
Cohesion: 0.21
Nodes (8): DaemonMetrics, Snapshot, .meanLockWaitMicros, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 84 - "LSPDiagnostic"
Cohesion: 0.10
Nodes (22): BrowserCookie, BrowserRequestPayload, close, cookies, evaluate, goBack, goForward, interact (+14 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.05
Nodes (35): Error, LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed, serverNotExecutable, AsyncStream (+27 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.14
Nodes (11): FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect, String, URL (+3 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.14
Nodes (14): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+6 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.14
Nodes (19): BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, CodingKeys, description, key (+11 more)

### Community 89 - ".cursorPos"
Cohesion: 0.13
Nodes (5): .setupPrompt, hooks, AgentHookInstallerTests, String, URL

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.13
Nodes (12): pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal, Int32 (+4 more)

### Community 91 - "TerminalModes"
Cohesion: 0.06
Nodes (21): CornerInfo, KouenSplitView, .dividerColor, .dividerThickness, .init(coder:), PaneDragGripView, .init(coder:), PaneHoverButton (+13 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.35
Nodes (4): TrackedIssue, IssueTrackerService, Bool, String

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.15
Nodes (9): JSONOutputFormatter, Bool, String, T, HookEntry, UUID, WorkspaceSummary, JSONOutputFormatterTests (+1 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.20
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 95 - "shim.c"
Cohesion: 0.12
Nodes (18): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerFooter, .body, DirectoryPickerModel (+10 more)

### Community 96 - "Harness Usage"
Cohesion: 0.17
Nodes (9): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, FormatColor, String (+1 more)

### Community 97 - "PaneContainerView"
Cohesion: 0.09
Nodes (18): PendingVersionBanner, welcome, whatsNew, State, Bool, String, URL, VersionBannerStore (+10 more)

### Community 99 - ".dispatch"
Cohesion: 0.06
Nodes (43): a2(), akn(), ast(), B1(), Bsn(), bYe(), cIn(), d4n() (+35 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.10
Nodes (22): Codable, CodingKeys, error, id, jsonrpc, method, params, result (+14 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.13
Nodes (21): .color, TaskSummary.Status, .columnKind, BoardCard, BoardColumn, .name, BoardColumnKind, .displayName (+13 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.09
Nodes (23): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+15 more)

### Community 104 - "Recipe"
Cohesion: 0.10
Nodes (25): Bool, UInt8, TerminalCellWidth, normal, spacerTail, wide, TerminalCursor, TerminalCursorShape (+17 more)

### Community 105 - "Changelog"
Cohesion: 0.16
Nodes (8): AgentListFormatter, Date, String, dvn(), AgentListFormatterTests, Bool, Date, String

### Community 106 - "domain-design.md"
Cohesion: 0.27
Nodes (7): SwarmFleetBody, .body, SwarmNodeRowView, .body, .statusColor, Duration, Void

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.15
Nodes (10): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, Set, SurfaceID (+2 more)

### Community 108 - ".resolve"
Cohesion: 0.02
Nodes (268): r, A(), a(), aDt(), aen(), aHt(), aIt(), aMt() (+260 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.08
Nodes (20): SGRMouse, SGRMouseEvent, Bool, PaneRect, UInt8, MouseButton, left, middle (+12 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.18
Nodes (6): CopyModeReducerTests, FakeGrid, .totalLines, Set, String, TerminalGridCell

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.07
Nodes (11): Bool, ImagePlacement, Pen, SavedCursor, ClosedRange, Range, TerminalCellWidth, UnsafeBufferPointer (+3 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.18
Nodes (5): KeyTokenParser, Bool, String, KeyTokenParserTests, Phase6KeysTests

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.16
Nodes (13): .windowSection, KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:claudeAPIKey:inlineAICompletion:terminalShaderEffect:browserHomePage:), .init(from:), Decoder, Double, Float, TerminalTextRenderingMode (+5 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.15
Nodes (8): ImportedTerminalConfig, .hasTerminalColorOverrides, Bool, Double, Float, String, TerminalConfigImporter, TerminalConfigImporterTests

### Community 115 - ".encode"
Cohesion: 0.09
Nodes (25): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, ModelProvider, .agentKindForLogo, anthropic (+17 more)

### Community 116 - "SessionGroup"
Cohesion: 0.20
Nodes (7): AgentRoutingRuleStore, Bool, String, URL, UUID, AgentRoutingRuleStoreTests, URL

### Community 117 - "PaneNode"
Cohesion: 0.10
Nodes (11): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+3 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.09
Nodes (14): ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy, SessionLifecycleService, NSWindow (+6 more)

### Community 119 - "Harness command reference"
Cohesion: 0.06
Nodes (29): Attaching from a plain terminal, Bindings, Board and attention, Buffers (paste store), Composition, Errors and LSP, File navigation, Hooks (+21 more)

### Community 122 - "ViEngine"
Cohesion: 0.14
Nodes (19): Cjt(), H2e(), hR(), jX(), Kje(), KX(), lR(), N$e() (+11 more)

### Community 123 - "Pipe"
Cohesion: 0.18
Nodes (9): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController (+1 more)

### Community 124 - "String"
Cohesion: 0.30
Nodes (9): .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release, `repeat`, KeyModifiers, Character, String (+1 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, S (+2 more)

### Community 126 - ".path"
Cohesion: 0.14
Nodes (19): AgentArt, AgentMark, .body, AgentMarkShape, AgentVectorIcon, Scanner, .atEnd, SVGPath (+11 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.10
Nodes (24): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), .stats (+16 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.09
Nodes (20): Coordinator, DiffAnalysis, DiffFileItem, DiffFileStatus, added, .color, deleted, modified (+12 more)

### Community 129 - "SwiftUI"
Cohesion: 0.16
Nodes (8): EditorDividerView, NSLayoutConstraint, FilePreviewCoordinator, FileTabID, NSView, Set, SplitDirection, String

### Community 131 - ".install"
Cohesion: 0.12
Nodes (17): GroupHeaderRow, .body, PickerItem, .groupLabel, historyBlock, .id, recipe, .searchableText (+9 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.03
Nodes (91): a1t(), amn(), B0, b2t(), BBe(), bpn(), cg(), ch() (+83 more)

### Community 133 - ".load"
Cohesion: 0.18
Nodes (8): PaneID, SurfaceID, Tab, TabID, BrowserPaneReuseScopeTests, PaneNode, Tab, TabID

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.19
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 135 - "CommandTarget"
Cohesion: 0.13
Nodes (3): KittyKeyboardTests, String, UInt8

### Community 136 - ".startWatching"
Cohesion: 0.04
Nodes (58): _3n(), abt(), ag(), b5e(), bV(), c6e(), c_n(), d0() (+50 more)

### Community 137 - "ActivePaneService"
Cohesion: 0.11
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.23
Nodes (5): ListeningPortScanner, Int32, Set, String, ListeningPortScannerTests

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.09
Nodes (21): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+13 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.21
Nodes (8): StartupMetrics, .logURL, Bool, Double, UInt64, URL, StartupMetricsTests, UInt64

### Community 142 - "CopyModeGridSource"
Cohesion: 0.09
Nodes (20): .init(coder:), BrowserProgressLine, .init(coder:), .init(frame:), BrowserTabButton, .init(coder:), .init(title:isActive:onSelect:onClose:), DesignModePopoverViewController (+12 more)

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.21
Nodes (8): PaletteAction, PaletteModel, PaletteRow, header, item, .body, NSWindow, Void

### Community 144 - "PaneStyleSet"
Cohesion: 0.21
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 146 - "DecodedImage"
Cohesion: 0.18
Nodes (14): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+6 more)

### Community 147 - "FileTreeWatcher"
Cohesion: 0.09
Nodes (23): BranchSwitchHelper, FileTreeNode, FileTreeSwiftUIView, .body, .filteredNodes, .rootPath, .scanOptions, .sessionID (+15 more)

### Community 148 - "TriState"
Cohesion: 0.07
Nodes (33): .init(entry:), ChromeRole, sidebar, tabBar, FontSize, IconSize, KouenMotion, Radius (+25 more)

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
Cohesion: 0.06
Nodes (24): KouenCLITests, URL, CLIInstallLocator, DetachKeys, absent, invalid, parsed, OptionalUUID (+16 more)

### Community 154 - "LiveResizeTests"
Cohesion: 0.08
Nodes (30): ImagePlacementSnapshot, Bool, String, UInt8, TerminalCellWidth, normal, spacerTail, wide (+22 more)

### Community 155 - "Int"
Cohesion: 0.14
Nodes (11): FileFuzzyMatcher, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool, Character (+3 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.12
Nodes (15): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, .acceptsFirstResponder (+7 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.15
Nodes (10): Tab, PaneLifecycleManager, Bool, NSView, PaneID, PaneNode, Set, String (+2 more)

### Community 159 - "MatchCategory"
Cohesion: 0.14
Nodes (14): .agentColorBinding, colors, ANSIPalette, CellColorResolver, MochaTheme, ResolvedCellColors, .init(hex:), .init(red:green:blue:alpha:) (+6 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.11
Nodes (22): FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose, .onSelect (+14 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.14
Nodes (11): PairingBox, .current, .isLockedOut, PendingPairing, Date, TimeInterval, TokenCheck, accepted (+3 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.14
Nodes (12): NSSearchFieldDelegate, CGFloat, NSButton, NSCoder, NSImage, NSRect, String, Void (+4 more)

### Community 163 - "Workspace"
Cohesion: 0.32
Nodes (3): BinaryInstallerVersionTests, String, URL

### Community 164 - "CommandPromptController"
Cohesion: 0.09
Nodes (23): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, IssueInfo (+15 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.38
Nodes (4): SSETransport, NWConnection, String, UInt16

### Community 166 - "LiveSession"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.11
Nodes (28): .resolvedGitStatus, fetchGitStatus(), ProjectCategory, ProjectCategorySection, .body, .c, .entries, ProjectDirectoryTreeModel (+20 more)

### Community 170 - "URLDetection"
Cohesion: 0.12
Nodes (7): Bool, Range, Set, String, URLDetection, StringProtocol, EngineConformanceTests

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.14
Nodes (15): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+7 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.14
Nodes (13): GridCompositor, Configuration, Int32, SessionGroup, SessionID, Tab, TabID, WorkspaceID (+5 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.11
Nodes (10): ISO8601DateFormatter, KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), SpawnedAgentSurface, Bool, PaneLeaf, Result, String (+2 more)

### Community 175 - "RGBColorTests"
Cohesion: 0.17
Nodes (13): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedAlreadyBanner, .pairedDevicesList (+5 more)

### Community 176 - "Added"
Cohesion: 0.07
Nodes (32): a0n(), Bm(), bX(), dl(), eAn(), eht(), Em(), gb() (+24 more)

### Community 177 - ".rects"
Cohesion: 0.18
Nodes (3): CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 178 - "InlineAICompletionView"
Cohesion: 0.24
Nodes (9): CopyModeGridSource, .promptRows, CopyModeReducer, Bool, Character, NSRegularExpression, Range, String (+1 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.14
Nodes (17): PaneBorderStatus, bottom, off, top, PaneLeaf, PaneNode, branch, leaf (+9 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.23
Nodes (8): LSPFileSession, Never, String, Task, URL, Void, object, Bool

### Community 181 - "GridCompositorTests"
Cohesion: 0.18
Nodes (5): CompositorPane, GridCompositorTests, Bool, String, TerminalGridSnapshot

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.21
Nodes (4): Bool, String, SurfaceID, TimeInterval

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
Cohesion: 0.13
Nodes (16): PaletteFooter, .body, PaletteItemRow, .body, PaletteMode, errors, grep, normal (+8 more)

### Community 190 - "user-stories.md"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.13
Nodes (7): ScriptRuntime, Any, String, URL, JSContext, JSValue, ScriptingTests

### Community 192 - "GlyphRasterizer"
Cohesion: 0.07
Nodes (28): CoreText, CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats (+20 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.18
Nodes (10): RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal, FileHandle, Int32 (+2 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.10
Nodes (26): FileNode, GitStatusType, added, deleted, modified, renamed, unmodified, untracked (+18 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.11
Nodes (17): 1.1 Architecture, 1.2 Algorithm review, 1.3 Structure findings, 2.1 Structure, 2.2 Risk register (ranked), 3.1 Current implementation, 3.2 Why nothing shows (ranked root-cause candidates), 3.3 Fix plan (+9 more)

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.08
Nodes (19): Selector, Collection, .aggregateBoardStatus, .taskTooltipSummary, Kind, primary, secondary, KouenPillButton (+11 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.21
Nodes (4): AgentTableEntry, Bool, Set, String

### Community 198 - ".classify"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.15
Nodes (10): InstallResult, Shell, bash, fish, zsh, ShellIntegration, Bool, URL (+2 more)

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.04
Nodes (58): TerminalGridCell, DecodedImage, .byteCount, UInt8, KouenGridTerminal, Bool, CAMetalDrawable, String (+50 more)

### Community 202 - "PaletteModel"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.17
Nodes (4): InputEncoder, InputEncoderTests, String, UInt8

### Community 204 - "From tmux"
Cohesion: 0.25
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 205 - "CopyModeState"
Cohesion: 0.14
Nodes (12): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+4 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.21
Nodes (5): CommandPaletteController, PaletteFileEntry, PaletteGrepMatch, String, TimeInterval

### Community 207 - "scheduleRender"
Cohesion: 0.25
Nodes (4): AgentScanner, Bool, DispatchSourceTimer, TimeInterval

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.13
Nodes (14): CompletionPopupView, .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:), .isHovered, Bool (+6 more)

### Community 209 - "SettingsRemoteView"
Cohesion: 0.10
Nodes (40): blockTokens(), br(), checkbox(), code(), codespan(), constructor(), de(), del() (+32 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.20
Nodes (4): CompletionGenerator, String, .fishCompletionSource, CompletionGeneratorTests

### Community 211 - "PaneTarget"
Cohesion: 0.28
Nodes (7): Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 212 - ".translate"
Cohesion: 0.09
Nodes (9): String, WorkspaceID, CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab, DaemonSyncServiceBranchNotifyTests (+1 more)

### Community 213 - "String"
Cohesion: 0.11
Nodes (5): NSTextView, KouenApp, GitPanelViewDiffPopoverTests, GitPanelViewFSEventFilterTests, GitPanelViewWorktreeParsingTests

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.09
Nodes (24): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+16 more)

### Community 215 - ".lines"
Cohesion: 0.08
Nodes (29): b3e(), c6(), gce(), _gn(), h7e(), HKe(), igt(), jTn() (+21 more)

### Community 216 - "CellColorResolverTests"
Cohesion: 0.13
Nodes (10): WindowInputRouterTests, UInt8, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8 (+2 more)

### Community 217 - "GridCompositor"
Cohesion: 0.22
Nodes (5): Bool, Character, NSRange, NSTextView, String

### Community 218 - "ScrollbackFile"
Cohesion: 0.05
Nodes (43): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, SwarmDAGStore, String, UUID, SwarmFleetSnapshot (+35 more)

### Community 219 - "Prompt"
Cohesion: 0.25
Nodes (4): StatusLineWidthTests, StatusLineWidth, String, StyledSegment

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
Cohesion: 0.25
Nodes (8): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor, NSView, .panelBackground

### Community 224 - "CellColorResolver"
Cohesion: 0.12
Nodes (12): ANSIPalette, RGBColor, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors, Bool, Double (+4 more)

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.17
Nodes (10): StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength, newline, StdioTransport, AsyncStream, TransportError (+2 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.14
Nodes (18): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, PaneLeaf, PaneNode (+10 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.07
Nodes (27): DiffLineType, added, deleted, modified, Notification.Name, Bool, NSCoder, NSEvent (+19 more)

### Community 228 - "sessionRow"
Cohesion: 0.14
Nodes (7): KeybindingsStore, .fileURL, URL, KeybindingsStoreTests, URL, Void, String

### Community 229 - ".decide"
Cohesion: 0.21
Nodes (6): MutationResult, RemoteHost, RemoteHostStore, Bool, String, T

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.26
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 231 - "ExternalOpenKind"
Cohesion: 0.16
Nodes (20): Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors, ContrastGrade (+12 more)

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.25
Nodes (4): TerminalGridSnapshot, ReflowPreviewTests, .feeds, String

### Community 234 - ".scan"
Cohesion: 0.23
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 235 - "WorkbenchCommand"
Cohesion: 0.08
Nodes (19): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+11 more)

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.11
Nodes (11): Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint, NSRect, WindowTitleStripView (+3 more)

### Community 238 - ".make"
Cohesion: 0.08
Nodes (25): CoreGraphics, BoxDrawing, Kind, arms, dashH, dashV, halfDown, halfLeft (+17 more)

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.15
Nodes (8): CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16, UInt8, CharacterWidthTests

### Community 240 - "PaneBorderStatus"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 242 - "AgentBridge"
Cohesion: 0.15
Nodes (5): HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 243 - ".make"
Cohesion: 0.17
Nodes (21): Encodable, AISuggestionAck, AttachedAck, BrowserFramePush, Cred, DecodedWSFrame, DetachedAck, DeviceCredentials (+13 more)

### Community 244 - "FileNode"
Cohesion: 0.14
Nodes (11): FormatContext, FormatString, FormatStyle, Bool, Character, Date, FormatColor, String (+3 more)

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.10
Nodes (23): bNt(), bu(), cNt(), dNt(), eNt(), eRe(), fNt(), iNt() (+15 more)

### Community 247 - ".renderFixture"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.08
Nodes (12): Divergence, Bool, String, TimeInterval, WorktreeInfo, WorktreeManager, String, WorktreeIsolationTests (+4 more)

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.16
Nodes (9): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+1 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.10
Nodes (25): aVe(), bme(), bYt(), cVe(), fqt(), hVe(), Iin(), iVe() (+17 more)

### Community 251 - "SessionCoordinator"
Cohesion: 0.19
Nodes (9): Array, RecipePanel, .canBecomeKey, RecipePickerController, RecipePickerView, RecipeWindowDelegate, Bool, Element (+1 more)

### Community 252 - "NSViewRepresentable"
Cohesion: 0.29
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 253 - "Split Right"
Cohesion: 0.06
Nodes (17): CKouenSys, Darwin, Foundation, Glibc, KouenCore, KouenDaemonCore, Network, AgentRoutingResolver (+9 more)

### Community 254 - "BoardViewController"
Cohesion: 0.12
Nodes (12): BrowserIntegrationController, NSView, PaneID, HitTestPassthroughView, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), .init(paneID:), NSPoint (+4 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.16
Nodes (9): FileGraphInfo, GraphifyLSPBridge, Double, String, URL, GraphifyLSPBridgeTests, Any, String (+1 more)

### Community 256 - "GitMetadataProvider"
Cohesion: 0.11
Nodes (16): InlineAICompletionController, KouenSettings, String, InlineAICompletionView, .init(coder:), .init(frame:), .suggestion, Bool (+8 more)

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.09
Nodes (30): CoreImage, .start(onResponse:onEnd:), PanePipe, .subscribe(surfaceID:handler:), FileHandle, UUID, BlockSummary, Date (+22 more)

### Community 258 - "WindowTitleStripView"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.36
Nodes (3): KouenSplitViewTests, LayoutProbeView, CGFloat

### Community 260 - ".welcome"
Cohesion: 0.16
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 262 - ".install"
Cohesion: 0.19
Nodes (7): String, AgentRoutingRule, AgentRoutingRuleSummary, Bool, String, UUID, AgentRoutingResolverTests

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.19
Nodes (11): DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String, StyledSegment (+3 more)

### Community 266 - ".path"
Cohesion: 0.20
Nodes (6): ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 267 - ".performInstall"
Cohesion: 0.11
Nodes (19): Context, Non-goals, P8: macOS 27 Golden Gate Adoption, Phase 10 — WidgetKit & Desktop Status Panel (P2), Phase 11 — Metal Frame Pacing & DisplayLink Optimization (P2), Phase 12 — Terminal Accessibility Tree (P2), Phase 1 — Compatibility (P0), Phase 2 — Quick Wins (P1) (+11 more)

### Community 268 - "code:bash (# Old (agent-specific):)"
Cohesion: 0.09
Nodes (23): aie(), arc(), b2e(), bezierCurveTo(), closePath(), cRe(), cZ(), E7() (+15 more)

### Community 270 - "WindowSession"
Cohesion: 0.12
Nodes (7): PaneBorderStatus, Bool, Command, DispatchWorkItem, PaneRect, String, WindowSession

### Community 271 - "StatusLineView.swift"
Cohesion: 0.30
Nodes (8): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, RecipePickerFooter, .body

### Community 272 - "SGRMouseEvent"
Cohesion: 0.19
Nodes (18): Close Pane, Close Tab, Split Down, Split Right, Cmd Shift W Force Closes Tab, Cmd W Closes Pane When Split, Cmd W Closes Tab When Single Pane, Window Survives Full Shortcut Sequence (+10 more)

### Community 273 - "KeySpec"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.17
Nodes (8): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ActivityAssertionManagerTests

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.06
Nodes (46): SettingsAgentsView, .agentsSection, .detectionSection, .notchSection, .notifySection, Bool, SettingsAppearanceView, .autoTheme (+38 more)

### Community 277 - ".run"
Cohesion: 0.07
Nodes (30): BinaryInstaller, .bundledMacOSDir, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display (+22 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.11
Nodes (11): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, Task, UUID (+3 more)

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.14
Nodes (12): epn(), EUe(), eYt(), lq(), ple(), rp(), Sme(), sut() (+4 more)

### Community 280 - ".menu"
Cohesion: 0.17
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

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
Cohesion: 0.14
Nodes (19): CustomStringConvertible, atomicWrite(), backupCorruptFile(), fnv1aHex(), KouenPaths, KouenPathsError, .description, socketPathTooLong (+11 more)

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.16
Nodes (8): MarkdownPreviewView, Any, Bool, Error, String, URL, Void, MarkdownPreviewTests

### Community 287 - ".apply"
Cohesion: 0.41
Nodes (5): InstallResult, ShellCompletionInstaller, Bool, String, URL

### Community 288 - "AgentHookStrategy"
Cohesion: 0.22
Nodes (9): DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSView, NSViewCornerConfiguration, SurfaceID (+1 more)

### Community 290 - "Process"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 291 - "JSONDecoder"
Cohesion: 0.20
Nodes (3): String, TerminalGridSnapshot, VTConformanceCorpusTests

### Community 292 - "Release runbook"
Cohesion: 0.25
Nodes (7): Full local signing path (needs a Developer ID cert; not currently used), Full pipeline reference (not implemented in this fork), How this fork actually releases, If the workflow existed: running a release, One-time GitHub setup, Release runbook, What that workflow would publish

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.10
Nodes (17): CodingKeys, error, id, jsonrpc, method, params, JSONRPCId, int (+9 more)

### Community 294 - "GitHubCLIClient"
Cohesion: 0.24
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 295 - "AgentApprovalBar"
Cohesion: 0.20
Nodes (7): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, FileChangeWatcherTests

### Community 296 - "NotificationBus"
Cohesion: 0.20
Nodes (10): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+2 more)

### Community 297 - "settings.json"
Cohesion: 0.17
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, Bool, Double (+3 more)

### Community 298 - "jobs"
Cohesion: 0.10
Nodes (47): Ame(), aQt(), AYt(), CUe(), cXt(), een(), eVe(), eXt() (+39 more)

### Community 299 - "PaneNode"
Cohesion: 0.08
Nodes (32): CGFloat, FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView (+24 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.25
Nodes (6): .snapshotPayload, NotificationBus, .postSnapshotChanged(_:), SnapshotChangedPayload, Bool, String

### Community 301 - ".parse"
Cohesion: 0.19
Nodes (8): Range, String, TerminalGridCell, TerminalBufferMatch, TerminalBufferSearch, String, TerminalGridCell, TerminalBufferSearchTests

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.16
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 303 - ".encodeMouse"
Cohesion: 0.04
Nodes (69): _6e(), _8n(), _9e(), a4e(), a9e(), Ac(), ace(), aoe() (+61 more)

### Community 304 - "00-inception-plan.md"
Cohesion: 0.18
Nodes (6): DefaultTerminalLaunchRequest, ShellQuoting, Bool, String, URL, DefaultTerminalLaunchRequestTests

### Community 305 - ".script"
Cohesion: 0.12
Nodes (7): azt(), cqe(), F7, ibe(), mathmlBuilder(), q$e(), UHt()

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 307 - "ViPathTokenTests"
Cohesion: 0.08
Nodes (24): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+16 more)

### Community 308 - "Send Ex Command"
Cohesion: 0.30
Nodes (5): SettingsAdvancedView, .body, Bool, String, SwiftUI

### Community 310 - "FrameSignposter"
Cohesion: 0.08
Nodes (17): .removeWorktreeAction(path:), GitResult, Bool, String, ValidateOutcome, WorktreeEntry, NSView, NSViewCornerConfiguration (+9 more)

### Community 312 - "AgentSnapshot"
Cohesion: 0.12
Nodes (20): Array, Bool, Date, Decoder, PaneID, PaneNode, String, TabID (+12 more)

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.08
Nodes (28): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary, RowKind (+20 more)

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.15
Nodes (12): OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Bool, Value, bool (+4 more)

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.22
Nodes (10): Status, ciFailing, done, mergeReady, open, running, Bool, Date (+2 more)

### Community 319 - "FormatColor"
Cohesion: 0.09
Nodes (19): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+11 more)

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.26
Nodes (14): Agent Command Does Not Crash, Agent Waiting Filter Does Not Crash, Board Command Shows Board Panel, Cd Command Switches To Matching Tab, Copy Path Command Does Not Crash, Errors Command Does Not Crash, Find Command Opens Command Palette On Empty Query, Find Command Resolves Unique File (+6 more)

### Community 321 - "UInt64"
Cohesion: 0.18
Nodes (30): aQ(), bqt(), cbe(), DD(), Eqt(), Fa(), gqt(), hqt() (+22 more)

### Community 322 - "DesktopNotifier"
Cohesion: 0.12
Nodes (17): FormatContextBuilder, DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:) (+9 more)

### Community 323 - "LayoutNode"
Cohesion: 0.10
Nodes (16): Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent, NSPoint, NSRect (+8 more)

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.14
Nodes (33): Bje(), Czt(), DJt(), dzt(), FR(), gJt(), gzt(), Hl() (+25 more)

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.09
Nodes (22): DetachedPaneOverlay, .init(coder:), .init(frame:style:), ReconnectLatch, .isTripped, Style, detached, reconnectingChip (+14 more)

### Community 327 - ".theme"
Cohesion: 0.40
Nodes (5): PaneOutputWaiter, PaneOutputWaitResult, CheckedContinuation, Never, UInt64

### Community 328 - "README.md"
Cohesion: 0.21
Nodes (6): .rowList, AgentNotchViewModel, Bool, CGFloat, Duration, String

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 330 - ".drawGlyph"
Cohesion: 0.18
Nodes (15): CellMetrics, ComposedFrame, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth (+7 more)

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.18
Nodes (8): PluginLoader, String, ScriptAPI, ScriptError, .errorDescription, evaluationError, unsupportedPlatform, JavaScriptCore

### Community 333 - "RealPty"
Cohesion: 0.18
Nodes (8): ClaudeRunSummary, Date, Double, Int32, String, UUID, String, UUID

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.08
Nodes (27): AnyView, Container, .init(coder:), .init(frame:), NotchOverviewRow, .approvalControls, .background, .badge (+19 more)

### Community 335 - ".makeModel"
Cohesion: 0.26
Nodes (9): BrowserSnapshotAck, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserSnapshot, BufferSummary, OptionEntry, Date (+1 more)

### Community 336 - "run.sh"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 337 - "CommandExecutionError"
Cohesion: 0.28
Nodes (8): .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didStartProvisionalNavigation:), LoadCompletionState, CheckedContinuation, Error, TimeInterval, WKNavigation

### Community 338 - "CSIParams"
Cohesion: 0.30
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 339 - "Foundation"
Cohesion: 0.07
Nodes (30): AppKit, KouenCopyMode, KouenTerminalEngine, KouenTerminalKit, KouenTerminalRenderer, KouenTheme, Metal, ImmersiveEffects (+22 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.27
Nodes (9): Command Prompt, Find In Files, Git Panel, Open Command Palette, Switch To Session 1, Switch To Session 2, Rapid Session Switch While Typing, Switch Between Isolated And Normal Session (+1 more)

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.15
Nodes (14): aat(), d6(), Eb(), evn(), gwn(), i9n(), iCn(), k2t() (+6 more)

### Community 342 - "Added"
Cohesion: 0.30
Nodes (7): Bool, NSPasteboard, NSString, String, URL, TerminalServicesProvider, AutoreleasingUnsafeMutablePointer

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 344 - "FileViewerViewController"
Cohesion: 0.12
Nodes (11): FileViewerViewController, .acceptsFirstResponder, Any, Bool, NSEvent, Set, String, URL (+3 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.25
Nodes (7): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, NSEvent

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.19
Nodes (4): URL, MobileBridgeAttachFileTests, String, URL

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.19
Nodes (9): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.33
Nodes (6): SurfaceProgressTracker, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.16
Nodes (8): AgentDetection, AgentDetector, Date, Int32, TimeInterval, ProcessScan, Int32, AgentSnapshot

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.09
Nodes (20): FlippedView, .isFlipped, GitPanelView, .init(frame:), .isHidden, .removeWorktreeAction(_:), Any, DispatchWorkItem (+12 more)

### Community 355 - ".deepMerge"
Cohesion: 0.28
Nodes (8): AgentRow, .agentColor, .executables, .hookButton, .hookButtonTitle, .mcpButton, String, Void

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.18
Nodes (5): .snapshot, Bool, String, ThemeService, KouenOptions

### Community 357 - ".handleCat"
Cohesion: 0.31
Nodes (6): Bool, Counter, Scheduled, SurfaceProgressTrackerTests, DispatchWorkItem, TimeInterval

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.15
Nodes (4): AgentTitleInference, Bool, .effectiveAgentKind, AgentDetectorTests

### Community 359 - "OcclusionTests"
Cohesion: 0.10
Nodes (14): AnyCancellable, NotchMaskAnimator, Bool, CGFloat, CGRect, NSView, NotchPanel, .canBecomeKey (+6 more)

### Community 360 - "State"
Cohesion: 0.21
Nodes (10): Color, .hexString, PickerItemRow, .badgeText, .body, .iconName, .subtitle, .titleText (+2 more)

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.18
Nodes (10): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, automations (+2 more)

### Community 362 - "RGBColor"
Cohesion: 0.06
Nodes (23): IndexingIterator, LayoutTemplate, surfaceID, SessionEditor, .split(node:targetPaneID:direction:paneCount:before:), .split(node:targetPaneID:with:direction:beforeTarget:), .surfaceID(forPaneID:), .surfaceID(forPaneID:in:) (+15 more)

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.15
Nodes (9): Notification.Name, os, Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow (+1 more)

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.15
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.12
Nodes (13): InputGate, .siblings, SurfaceIO, .currentSubscription, CGFloat, FormatColor, KouenSettings, String (+5 more)

### Community 366 - "Consumers"
Cohesion: 0.13
Nodes (15): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+7 more)

### Community 367 - "DaemonStats"
Cohesion: 0.20
Nodes (9): BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool, CGFloat, NSCoder, NSPoint (+1 more)

### Community 368 - "Tab"
Cohesion: 0.15
Nodes (3): CellColorResolverTests, .resolver, CellColorResolver

### Community 369 - "Git Panel"
Cohesion: 0.28
Nodes (6): Bool, NSRange, NSString, NSTextView, String, unichar

### Community 370 - ".encode"
Cohesion: 0.19
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.16
Nodes (7): BoardViewController, FlippedView, .isFlipped, Bool, Set, TabID, BoardViewControllerTests

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.15
Nodes (13): CodingKey, CodingKeys, createdAt, cwd, done, id, sessionID, status (+5 more)

### Community 373 - "Prompt"
Cohesion: 0.05
Nodes (23): Am(), bUt(), bze(), Cm(), EQ(), FBe(), fQ, Gbe() (+15 more)

### Community 374 - ".run"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 375 - ".install"
Cohesion: 0.13
Nodes (13): BrowserPaneRegistry, .init(url:paneID:), .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), PaneID, URL, WKNavigationAction, WKWebView (+5 more)

### Community 376 - "ScrollReuseTests"
Cohesion: 0.18
Nodes (6): .onCurrentCWD, .onCurrentFile, Bool, NSString, NSTextView, String

### Community 377 - "Identifiable"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 379 - "MCPServer"
Cohesion: 0.27
Nodes (8): LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab, TabID, WorkspaceID

### Community 380 - "PromptQueue"
Cohesion: 0.12
Nodes (13): ShellLaunchProfile, .argv, String, ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID (+5 more)

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.09
Nodes (21): Bundle, OnboardingStep, complete, discover, .id, setup, shell, .title (+13 more)

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.08
Nodes (20): .webView(_:didCommit:), KouenSyntaxResources, BrowserPaneViewTests, MockWebView, .isLoading, .url, Any, Bool (+12 more)

### Community 387 - "User Profile"
Cohesion: 0.10
Nodes (7): ScreenPos, bottom, middle, top, KouenCLI, KouenLSP, QuickLookUI

### Community 388 - "Darwin"
Cohesion: 0.24
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 389 - "HarnessCLITests"
Cohesion: 0.22
Nodes (12): dqt(), Dr(), Ejt(), Fwe(), G3(), gUe(), jXt(), lqt() (+4 more)

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.15
Nodes (8): _Bt(), by(), e7e(), fst(), hxn(), lxn(), sBt, XWt()

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.14
Nodes (17): New Tab, Cmd T Creates New Session, Tab Close While Mouse Moving, CLI Isolate Creates Worktree And Session, CLI Isolate With Custom Branch Name, Close Session Keeps Dirty Worktree, Close Session Removes Clean Worktree, Create Isolated Session And Select (+9 more)

### Community 402 - "View"
Cohesion: 0.06
Nodes (43): Configuration, TabBarInlineIconButtonStyle, ButtonStyle, CommandRow, .body, GlassCard, .body, GlassPrimaryButtonStyle (+35 more)

### Community 403 - "PresentAttempt"
Cohesion: 0.09
Nodes (10): CGImage, ImageIO, ImageLimits, Bool, ImageDecoder, NSPasteboard, URL, NSPasteboard (+2 more)

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.36
Nodes (4): Bool, String, UUID, TaskDaemonBridge

### Community 405 - "AgentIconRenderer"
Cohesion: 0.08
Nodes (25): EndpointError, connectionFailed, .description, notYetSupported, pathTooLong, String, EndpointConnector, Int32 (+17 more)

### Community 406 - "main.swift"
Cohesion: 0.17
Nodes (5): DirectionalAxis, down, left, right, up

### Community 407 - "Fixed"
Cohesion: 0.18
Nodes (12): DotView, .init(coder:), .init(frame:), statusColor(), Bool, Context, NSCoder, NSColor (+4 more)

### Community 408 - "IPC Architecture"
Cohesion: 0.18
Nodes (8): NSDraggingInfo, NSDragOperation, PasteController, Bool, NSPasteboard, String, TimeInterval, URL

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.17
Nodes (10): .block(atPromptLine:), .captureLines(fromLine:toLine:), .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8 (+2 more)

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.09
Nodes (21): NotificationPermission, State, denied, granted, undetermined, MainActor, BinaryInstaller.DetectionStatus, SetupStepView (+13 more)

### Community 412 - "go.json"
Cohesion: 0.15
Nodes (6): aD(), ezt(), GGe, Hzt(), Kp(), urn

### Community 414 - "json.json"
Cohesion: 0.15
Nodes (11): copyMode, esc(), fs, globalShortcuts, KEYBINDINGS, prefixTable, renderTable(), ROOT (+3 more)

### Community 415 - "markdown.json"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.19
Nodes (7): TerminalGridCell, Case, ReflowCorpusTests, .corpus, .goldenDir, String, URL

### Community 417 - "rust.json"
Cohesion: 0.09
Nodes (18): .agentInfo(forWorktreePath:), .agentInfo(forWorktreePath:tabs:), Tab, Reason, errored, finished, needsInput, RowState (+10 more)

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.15
Nodes (4): KouenSettingsTests, URL, Void, String

### Community 419 - "typescript.json"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 420 - "yaml.json"
Cohesion: 0.13
Nodes (15): Int, Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock (+7 more)

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 422 - "HintModeOverlay"
Cohesion: 0.11
Nodes (12): SessionGroup, String, KouenSidebarPanelViewController, NSMenuItem, NSView, SessionGroup, String, NSMenu (+4 more)

### Community 423 - "SixelDecoder"
Cohesion: 0.33
Nodes (3): MTLDevice, MTLTexture, TerminalGridSnapshot

### Community 424 - ".parseDiffHunks"
Cohesion: 0.36
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 425 - "AgentVectorIcon"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.17
Nodes (11): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile, regionEdit (+3 more)

### Community 427 - ".delay"
Cohesion: 0.31
Nodes (4): TaskStore, tasks, URL, TaskStoreTests

### Community 428 - "TaskDashboardView"
Cohesion: 0.16
Nodes (8): MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, SurfaceID, MenuTargetPeerReviewTests

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.21
Nodes (5): CSIParams, .count, TerminalGridColor, TerminalGridUnderline, UInt8

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.10
Nodes (5): ContentAreaViewController, Bool, String, TabID, Notification

### Community 431 - "BoardCardView"
Cohesion: 0.29
Nodes (3): ReleaseNotesGuardTests, .changelog, String

### Community 432 - "PathToken"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.32
Nodes (7): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, agents, AgentKind

### Community 434 - "Project History"
Cohesion: 0.33
Nodes (4): .setSidebarVisible(_:animated:), SidebarPlacementSyncTests, CGFloat, Void

### Community 435 - ".init"
Cohesion: 0.17
Nodes (9): MTLLibrary, MTLRenderPipelineState, ImageTextureCache, MTLDevice, MTLTexture, UInt8, CGFloat, MTLDevice (+1 more)

### Community 436 - "WaitForRegistry"
Cohesion: 0.06
Nodes (43): CGFloat, clamp(), statusHelp(), CGFloat, Date, Never, NSHostingView, NSLayoutConstraint (+35 more)

### Community 437 - "PickerItemRow"
Cohesion: 0.13
Nodes (10): _7(), A7(), a8(), bGt(), c8(), ene(), Gnn, IC() (+2 more)

### Community 438 - "SessionEditor"
Cohesion: 0.33
Nodes (4): Run, String, TerminalBanner, WelcomeConfig

### Community 439 - "SetupStepView"
Cohesion: 0.14
Nodes (10): apn(), brn, grn, hrn(), JGe(), KGe(), prn(), qGe() (+2 more)

### Community 440 - "LegacySnapshot"
Cohesion: 0.18
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 441 - "RemoteHostStore"
Cohesion: 0.25
Nodes (3): TabID, WorkspaceID, GitPanelViewWorktreeNavigationTests

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.55
Nodes (5): AgentIconRenderer, CGFloat, NSColor, NSImage, String

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 445 - "Section"
Cohesion: 0.22
Nodes (4): GroupedSessionTests, SessionGroup, Set, SurfaceID

### Community 446 - "Modifiers"
Cohesion: 0.50
Nodes (3): data, SixelDecoder, UInt8

### Community 447 - "PaletteMode"
Cohesion: 0.22
Nodes (9): IssueKeychainStore, Bool, String, IssueTrackerType, azureDevOps, .id, jira, linear (+1 more)

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.18
Nodes (10): Bug 1 - Rotation Grace Slot Keeps The Previous Token Redeemable, Bug 1 - Rotation Shifts The Outgoing Token Into The Grace Slot, Bug 1 - Stop Fully Clears The Grace Slot, Bug 1 - Token Lifetime Not Regressed Below The Human-Flow Window, Bug 2 - Client onerror Does Not Clobber The Server Error Banner, Bug 2 - No Abrupt Cancel Immediately After The Error Text, Bug 2 - Reject Path Closes Gracefully With Policy-Violation Code 1008, Bug 3 - QR Not Printed When No Listener Is Ready (+2 more)

### Community 449 - "PresentAttempt"
Cohesion: 0.06
Nodes (25): Logger, OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, .event(_:), .interval(_:_:) (+17 more)

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.12
Nodes (9): ParsedShortcut, .displayString, PrefixKeymap, Any, Bool, NSEvent, String, TimeInterval (+1 more)

### Community 451 - ".run"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.21
Nodes (6): String, TerminalGridCell, TextGrid, .totalLines, .viewportRows, WordColumnRangeTests

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.29
Nodes (4): IssueTrackerPanelView, .body, .filteredIssues, String

### Community 454 - ".recordReapedGenerationForTesting"
Cohesion: 0.20
Nodes (9): AnyObject, CommandExecutionError, daemonError, .description, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor (+1 more)

### Community 455 - "ComposerPanel"
Cohesion: 0.11
Nodes (14): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+6 more)

### Community 456 - "TerminalModes"
Cohesion: 0.23
Nodes (3): TerminalModes, .encode(text:modifiers:modes:), .appCursor

### Community 457 - ".normalizedKey"
Cohesion: 0.29
Nodes (7): AnimatablePair, NotchShape, .animatableData, CGFloat, CGPath, CGRect, Path

### Community 460 - "RunState"
Cohesion: 0.29
Nodes (6): SwarmFleetSnapshotWire, SwarmTaskNodeWire, Date, Double, String, UUID

### Community 461 - ".worktreeList"
Cohesion: 0.22
Nodes (8): MCP Control Allowed With Env Var, MCP Control Denied Without Env Var, MCP KouenBoard Returns Columns, MCP KouenList Returns Sessions, MCP ReadPaneOutput Returns Content, Run MCP Request, Run MCP Request Allowed, Run MCP Request Denied

### Community 462 - "AGENTS.md"
Cohesion: 0.25
Nodes (7): Browser Pane Open Close Rapid, File Preview Open Close, Git Fetch Shows Toast, Launch Kouen Staging, Memory Stability After 30 Seconds, Quit Kouen Staging, Sidebar Toggle Immediately After Launch

### Community 463 - ".deinit"
Cohesion: 0.12
Nodes (19): AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem, FolderScanner (+11 more)

### Community 464 - "MouseButton"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 465 - "DirectionalAxis"
Cohesion: 0.36
Nodes (5): PaneLeaf, SessionGroup, Any, String, Tab

### Community 466 - "ReflowFastPathTests"
Cohesion: 0.19
Nodes (7): Bool, NSObjectProtocol, Set, String, Tab, TabID, WorktreeAutoIsolateService

### Community 467 - ".moveSelection"
Cohesion: 0.20
Nodes (6): LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled

### Community 469 - "PresentAttempt"
Cohesion: 0.17
Nodes (10): .init(frame:), .webView(_:decidePolicyFor:decisionHandler:), .webView(_:didFinish:), MainActor, NSRect, WKNavigation, WKNavigationAction, WKWebView (+2 more)

### Community 470 - "DispatchTime"
Cohesion: 0.29
Nodes (6): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Carbon

### Community 471 - ".evaluateStyled"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 473 - "HarnessOnboarding"
Cohesion: 0.14
Nodes (9): GridCompositorParityTests, LiveCompositorFixture, Bool, String, TerminalGridSnapshot, PortCompositorFixture, Bool, String (+1 more)

### Community 474 - "String"
Cohesion: 0.33
Nodes (6): Toggle Sidebar, Board CLI Shows Columns, Board CLI Shows Running After Long Command, Board Columns Visible After Click, Board Tab Accessible In Sidebar, Split Pane And Resize

### Community 475 - ".hitTest"
Cohesion: 0.18
Nodes (7): CGFloat, NSColor, NSPoint, NSRect, NSWindow, WindowBorderOverlayView, .windowCornerRadius

### Community 476 - ".steps"
Cohesion: 0.15
Nodes (7): OnboardingController, KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, OnboardingEnvironmentTests

### Community 477 - ".endFind"
Cohesion: 0.06
Nodes (29): JSONDecoder, JSONEncoder, CodingKeys, cols, createdAt, dataBase64, rows, timeMs (+21 more)

### Community 478 - ".install"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 479 - "ScrollbackTests"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 480 - "Command Prompt Architecture"
Cohesion: 0.12
Nodes (3): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess

### Community 482 - ".resolve"
Cohesion: 0.24
Nodes (9): AssistantLine, ClaudeAdapter, Content, Message, ResultLine, Bool, Double, String (+1 more)

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
Cohesion: 0.24
Nodes (10): dhn(), fhn(), ghn(), jUe(), Lme(), Mme(), RUe(), soe() (+2 more)

### Community 490 - "ccRunGet"
Cohesion: 0.26
Nodes (5): HintModeOverlay, Any, NSEvent, NSView, String

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.17
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

### Community 494 - "ccRunInfo"
Cohesion: 0.33
Nodes (5): Kouen LSP Diagnostics Does Not Crash, Kouen LSP Hover Returns Result, Kouen LSP Start Returns JSON, Kouen View Binary Shows Guard Message, Kouen View Prints File Content

### Community 495 - "ccRuns"
Cohesion: 0.08
Nodes (26): SettingsTerminalView, .body, .experienceSection, .fontReadout, .fontSection, .shellSection, Bool, String (+18 more)

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.18
Nodes (14): Process, SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, SSHTunnelManager (+6 more)

### Community 498 - ".automationList"
Cohesion: 0.02
Nodes (228): a(), b(), c(), d(), e(), f(), g(), h() (+220 more)

### Community 499 - ".routingRuleList"
Cohesion: 0.16
Nodes (18): al(), bdn(), bIn(), d7e(), dOt(), fLt(), g1n(), J0() (+10 more)

### Community 500 - ".json"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 501 - "Fixed"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 502 - "ACP Client (Shelved)"
Cohesion: 0.31
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 503 - "Build Scripts Self-Kill Protection"
Cohesion: 0.38
Nodes (5): .activeTab, .webView(_:didFinish:), BrowserTab, UUID, tabs

### Community 504 - "WindowBorderOverlayView"
Cohesion: 0.24
Nodes (3): RemoteHostStoreTests, String, URL

### Community 506 - "ViMode"
Cohesion: 0.23
Nodes (9): CGFloat, NSCoder, SessionID, Void, TaskDashboardView, .init(coder:), .init(onJumpToSession:), TaskRowView (+1 more)

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.40
Nodes (4): Leak A - Retiring A Host Drops Its AI Controllers, Leak B - Browser Network Capture Is Bounded, Leak C - Every Per-Surface Dict In Coordinator Has Retire Cleanup, Leak D - Every Per-Surface Dict In NotificationCoordinator Is Snapshot-Swept

### Community 509 - "start.mjs"
Cohesion: 0.70
Nodes (4): main(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 510 - "PromptQueue"
Cohesion: 0.29
Nodes (6): Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Product Identity Guardrail: Terminal, Not IDE, Subsystems & Package Map

### Community 511 - ".panePathLookup"
Cohesion: 0.20
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

### Community 512 - "Changelog Archive"
Cohesion: 0.09
Nodes (6): PromptQueue, String, SurfaceID, Void, PromptQueueBar, NSWindow

### Community 513 - "ThemeDocument"
Cohesion: 0.32
Nodes (5): SpecialKeyMappingTests, Bool, NSEvent, String, UInt16

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.27
Nodes (7): Never, Set, String, Task, URL, Void, WorkspaceSymbolIndex

### Community 517 - ".testManyConcurrentSubscribersAllReceiveOutput"
Cohesion: 0.25
Nodes (6): String, URL, ThemeCatalogEmbedTests, .embedSwift, .repoRoot, .sourceJSON

### Community 519 - ".gestureRecognizer"
Cohesion: 0.25
Nodes (5): irn(), mrn, _rn(), rrn(), srn()

### Community 520 - "WriteOutcome"
Cohesion: 0.24
Nodes (12): ern(), G4(), G7(), Jnn(), Qnn(), sHe(), trn(), U3() (+4 more)

### Community 521 - "CodingKey"
Cohesion: 0.24
Nodes (8): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8, .body

### Community 522 - "ShellCompletionInstallerTests"
Cohesion: 0.21
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 523 - ".encode"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 524 - "RealPtyLifecycleTests"
Cohesion: 0.22
Nodes (6): BellScanState, esc, normal, string, stringEsc, SurfaceMonitor

### Community 525 - "TabContextCommand"
Cohesion: 0.38
Nodes (4): AnyObject, TimeInterval, ZombieHoldRegistry, ObjectIdentifier

### Community 526 - "Kind"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 527 - "Agent hooks for Harness"
Cohesion: 0.50
Nodes (3): Bug 1 - Hunks Button Has Explicit Size Constraints, Bug 1 - Hunks Button Symbol Has A Guaranteed-Valid Fallback, Build Compiles Successfully

### Community 528 - "worktree_review_dashboard.robot"
Cohesion: 0.50
Nodes (3): Guard A - Merge Call Site Never Passes --no-ff, Guard B - No Auto-Resolve Anywhere In The Merge/Conflict Path, Guard C - Merge Conflict State Is Reconciled, Not Just Read Once

### Community 529 - ".build"
Cohesion: 0.19
Nodes (10): ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter, Any, Range, String (+2 more)

### Community 530 - "HarnessChrome"
Cohesion: 0.29
Nodes (8): FormatColor, none, palette, rgb, StyledSegment, Bool, String, UInt8

### Community 531 - ".recordReapedGenerationForTesting"
Cohesion: 0.09
Nodes (22): AutomationsFleetModel, .enabledCount, .failedCount, .filteredAutomations, .groupedByRepo, .runningCount, .totalCount, Bool (+14 more)

### Community 534 - "ANSIPalette"
Cohesion: 0.22
Nodes (6): HeadlessRunEvent, assistantText, result, Bool, Double, String

### Community 535 - "AgentNotification"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 537 - "NSRect"
Cohesion: 0.33
Nodes (6): AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.06
Nodes (34): MainActor, Void, SessionDividerRowView, .init(coder:), .init(frame:), SessionGroupHeaderRowView, .init(coder:), .init(frame:) (+26 more)

### Community 539 - "install-app.sh"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 540 - "TransportError"
Cohesion: 0.24
Nodes (4): GroupedSessionDaemonTests, SessionGroup, String, URL

### Community 544 - "Task Ledger Archive (Tasks 1–50)"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 546 - "LegacySnapshot"
Cohesion: 0.20
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 547 - "NSObject"
Cohesion: 0.15
Nodes (16): ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool, Command (+8 more)

### Community 553 - "harness.resource"
Cohesion: 0.21
Nodes (8): .init(coder:), NotificationRowView, .init(coder:), .isHighlighted, .isHovered, NSCoder, NSEvent, NSTrackingArea

### Community 554 - "FileTreeKeyboardNavigator"
Cohesion: 0.40
Nodes (9): attribute_lines(), main(), redraw_frames(), repeated_chunk(), run_case(), sgr_lines(), truecolor_gradient(), unicode_lines() (+1 more)

### Community 557 - ".viewWillMove"
Cohesion: 0.08
Nodes (7): SessionID, SplitDirection, String, WorkspaceID, SplitDirection, NSMenuItem, NSView

### Community 558 - ".sendInput"
Cohesion: 0.20
Nodes (10): BrowserResponsePayload, cookies, error, network, ok, open, screenshot, snapshot (+2 more)

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.18
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 560 - "LayoutTemplate"
Cohesion: 0.22
Nodes (5): .body, Bool, Bool, String, URL

### Community 562 - "BrowserResponsePayload"
Cohesion: 0.40
Nodes (4): Build, Release & Git Workflow, Build / Test / Run, Release packaging order, Worktree constraint

### Community 563 - "AgentNotchViewModel.swift"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

### Community 565 - "Motion"
Cohesion: 0.25
Nodes (4): Security, KouenMCPServer, Bool, String

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 568 - ".gestureRecognizer"
Cohesion: 0.36
Nodes (3): crn, ELt(), n2e()

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.29
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.08
Nodes (27): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+19 more)

### Community 571 - ".withinPixelCap"
Cohesion: 0.23
Nodes (6): CaseIterable, Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 572 - "LayoutProbeView"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 573 - "main.swift"
Cohesion: 0.27
Nodes (3): DaemonReconnectPolicy, TimeInterval, DaemonReconnectPolicyTests

### Community 574 - "generate-release-notes.swift"
Cohesion: 0.22
Nodes (6): AgentNotchPresentation, closed, open, peek, AgentNotchWindowActivator, Combine

### Community 575 - ".toastErrorSummary"
Cohesion: 0.36
Nodes (4): ReleaseNotes, Section, String, .sampleNotes

### Community 576 - "Phase67Tests"
Cohesion: 0.29
Nodes (4): RepoResolver, Bool, String, RepoResolverTests

### Community 578 - "TaskDashboardBody"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 579 - "RunState"
Cohesion: 0.17
Nodes (12): ClaudeCodeHarness, Profile, edit, readonly, Run, RunSummary, Bool, Date (+4 more)

### Community 580 - ".findSession"
Cohesion: 0.40
Nodes (3): calculate(), constructor(), mBt

### Community 582 - "FileTreeKeyboardNavigator"
Cohesion: 0.24
Nodes (5): GitStatusProvider, String, GitStatusProviderLargeOutputTests, URL, TimeoutError

### Community 584 - ".configureEnvironment"
Cohesion: 0.17
Nodes (11): LinePos, end, firstNonBlank, start, ViDiagnosticNavigator, ViMode, insert, normal (+3 more)

### Community 585 - ".feed(_:)"
Cohesion: 0.60
Nodes (3): .encode(_:modifiers:event:modes:), SpecialKey, insert

### Community 587 - "TargetSpec.swift"
Cohesion: 0.32
Nodes (4): SwarmFleetView, .init(coder:), CGFloat, NSCoder

### Community 589 - "Endpoint"
Cohesion: 0.39
Nodes (4): GridCompositorCopyModeTests, PaneRect, String, TerminalGridSnapshot

### Community 591 - "FormatContextDaemonTests"
Cohesion: 0.24
Nodes (9): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+1 more)

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
Cohesion: 0.22
Nodes (9): MatchSource, ownProcess, wrapperLaunch, RawMatch, WrapperOptionBehavior, keepScanning, matchValue, skipValue (+1 more)

### Community 599 - "nJt"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 600 - "HarnessTerminalSurfaceView"
Cohesion: 0.03
Nodes (41): NSRangePointer, NSEvent, Any, Bool, CGFloat, NSEvent, NSMenu, NSMenuItem (+33 more)

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

### Community 609 - "KeyRecorderRepresentable"
Cohesion: 0.14
Nodes (5): FormatContextDaemonTests, PaneID, String, SurfaceID, URL

### Community 610 - ".installCLI"
Cohesion: 0.20
Nodes (17): Decodable, Item, ItemCompletedLine, LegacyMsgLine, Msg, String, AISuggestRequest, AttachFileRequest (+9 more)

### Community 613 - "INDEX.md"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 614 - "MainSplitViewController"
Cohesion: 0.09
Nodes (18): MainSplitViewController, .setSidebarVisible(_:), SplitChromeDelegate, .splitView(_:constrainMaxCoordinate:ofSubviewAt:), .splitView(_:constrainMinCoordinate:ofSubviewAt:), .splitView(_:effectiveRect:forDrawnRect:ofDividerAt:), .splitView(_:shouldAdjustSizeOfSubview:), Bool (+10 more)

### Community 617 - "ScriptFileWatcher"
Cohesion: 0.10
Nodes (26): CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf, .init(from:) (+18 more)

### Community 622 - "[1.3.0-vit] - 2026-06-06"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 623 - "BrowserResponsePayload"
Cohesion: 0.12
Nodes (9): PaneNode, KouenIPC, BrowserLeaf, URL, DaemonSyncServiceBrowserPaneMergeTests, PaneID, PaneNode, PaneNodeBrowserTests (+1 more)

### Community 624 - "[2.5.0] - 2026-06-12"
Cohesion: 0.20
Nodes (8): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, ClosedRange, String

### Community 627 - "ActiveTabCloseDisposition"
Cohesion: 0.33
Nodes (4): OutputTrigger, OutputTriggerStore, Bool, String

### Community 629 - "graphify reference: query, path, explain"
Cohesion: 0.23
Nodes (3): BoardCommandTests, String, String

### Community 637 - "ClientSummary"
Cohesion: 0.12
Nodes (16): FileTreeContext, Bool, NSCoder, NSDraggingInfo, NSDragOperation, NSHostingView, NSScrollView, NSWindow (+8 more)

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
Cohesion: 0.13
Nodes (16): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, .bytesPerWakeup, .mbps (+8 more)

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
Cohesion: 0.57
Nodes (3): String, TaskDashboardBody, .body

### Community 678 - ".selectAdjacentSession"
Cohesion: 0.33
Nodes (5): AgentBridge, AgentTarget, Bool, String, SurfaceID

### Community 679 - "CodingKeys"
Cohesion: 0.32
Nodes (6): CGFloat, ResizeDirection, down, left, right, up

### Community 681 - ".tabIDsToNotify"
Cohesion: 0.20
Nodes (7): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, NSCoder, Void

### Community 682 - "MobileBridgeSpawnTests"
Cohesion: 0.25
Nodes (3): AutomationScheduler, DispatchSourceTimer, .surfaceTelemetry

### Community 684 - "New Tab"
Cohesion: 0.39
Nodes (5): AutomationSummary, Bool, Date, String, UUID

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 686 - "AgyAdapter.swift"
Cohesion: 0.36
Nodes (5): AgyAdapter, Result, ResultLine, String, UUID

### Community 689 - ".selectPane"
Cohesion: 0.25
Nodes (5): NotchVisibilityMode, automatic, off, on, Bool

### Community 690 - ".resourceURL"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

### Community 692 - ".control"
Cohesion: 0.16
Nodes (5): SSETransportTests, UInt16, MCPServer, String, NWListener

### Community 693 - ".loadFromDisk"
Cohesion: 0.22
Nodes (8): IssuePriority, .color, high, low, medium, none, .symbol, urgent

### Community 696 - "TerminalTabBarDelegate"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 699 - "eYt"
Cohesion: 0.10
Nodes (6): o, aZ(), e0(), eie(), eZ(), wZ()

### Community 700 - ".init"
Cohesion: 0.25
Nodes (6): Kind, path, stack, Bool, Date, UUID

### Community 701 - "b1t"
Cohesion: 0.29
Nodes (5): Bool, NSControl, NSEvent, NSTextView, Selector

### Community 702 - ".handleClaudeCode"
Cohesion: 0.47
Nodes (5): AgentIconArt, AgentVectorIcon, Bool, CGSize, String

### Community 703 - "ColorKind"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 704 - "oh"
Cohesion: 0.26
Nodes (3): BellScanTests, Bool, UInt8

### Community 708 - ".toastErrorSummary"
Cohesion: 0.40
Nodes (5): RunState, cancelled, failed, running, succeeded

### Community 709 - ".start"
Cohesion: 0.20
Nodes (3): PipeBuffer, Result, MobileBridgeAISuggestTests

### Community 710 - "MainWindowController"
Cohesion: 0.20
Nodes (6): KouenWindow, NSEvent, MainWindowController, Any, NSRect, NSWindow

### Community 711 - "DisplayWidth"
Cohesion: 0.33
Nodes (3): DisplayWidth, String, Unicode

### Community 713 - "AutomationScheduler"
Cohesion: 0.28
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 714 - "RawSelection"
Cohesion: 0.40
Nodes (5): h1t(), hae(), jgn(), sfn(), _Ue()

### Community 715 - "TerminalProgressReport"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 716 - "Phase67Tests"
Cohesion: 0.40
Nodes (5): ColorKind, .base, bg, fg, underline

### Community 718 - "[2.4.0] - 2026-06-12"
Cohesion: 0.14
Nodes (15): DataBox, .init(coder:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:), .init(frame:) (+7 more)

### Community 720 - ".closeActivePane"
Cohesion: 0.40
Nodes (5): Next Session, Previous Session, Session Navigation Cmd Brackets, Next Pane In Isolated Session Stays In Worktree, Prev Pane In Isolated Session Stays In Worktree

### Community 722 - ".isNoisyGitInternalPath"
Cohesion: 0.50
Nodes (3): PaneID, PaneLeaf, PaneNode

### Community 724 - "ProjectConfig"
Cohesion: 0.53
Nodes (3): ProjectConfig, Bool, String

### Community 727 - "PromptQueueBar"
Cohesion: 0.50
Nodes (3): __kouen_osc133_postexec, __kouen_osc133_preexec, __kouen_osc133_prompt

### Community 729 - "AsyncCLIResultBox"
Cohesion: 0.16
Nodes (8): AsyncCLIResultBox, LSPDefinitionPayload, LSPStatusPayload, Error, Result, String, UInt64, URL

### Community 732 - "ReplayStep"
Cohesion: 0.50
Nodes (3): SplitDirection, horizontal, vertical

### Community 736 - "graphify reference: add a URL and watch a folder"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 737 - ".resolve"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 745 - "p11_scripting.robot"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

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
Cohesion: 0.10
Nodes (19): .exit, String, String, String, String, KouenCLI, SessionID, String (+11 more)

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
Cohesion: 0.08
Nodes (19): RealPty, .init(forTesting:), .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), ScrollbackEntry, ScrollbackReplaySegment, Bool, CChar, DaemonSurfaceID (+11 more)

### Community 3131 - "P38 Phase D — Kitty Conformance — Dev Task Progress"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 3132 - "P38 Phase E — Scripting Hooks — Dev Task Progress"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 3135 - "Phase 0 — Swift 6.3+ Concurrency Safety (P0, LESSONS FROM macOS 26.5 CRASH SAGA)"
Cohesion: 0.67
Nodes (3): Phase 0 — Swift 6.3+ Concurrency Safety (P0, LESSONS FROM macOS 26.5 CRASH SAGA), Rules (enforced, not optional), Verification checklist for macOS 27 beta

### Community 3419 - "Page"
Cohesion: 0.23
Nodes (6): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow

### Community 3515 - "RawRepresentable"
Cohesion: 0.06
Nodes (38): KeybindingsService, Bool, Command, String, OptionSet, KeySpec, .description, .init(from:) (+30 more)

## Knowledge Gaps
- **3525 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+3520 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1535 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `yaml.json` to `Changelog Archive`, `callingPaneTarget`, `graphify reference: extra exports and benchmark`, `EngineConformanceTests`, `IPCRequest`, `AgentNotchRootView`, `LSPMessage`, `TerminalEmulator`, `PerformanceBenchmarks`, `GitPanelView.swift`, `VTParser`, `.applyPreedit`, `MetalRendererTests`, `HarnessUILibrary`, `.recordReapedGenerationForTesting`, `HarnessChrome`, `.readGrid(scrollbackOffset:)`, `WorktreeManager`, `Harness tmux-style capabilities`, `SessionGroupHeaderRowView`, `.parse`, `.init`, `Notification`, `Sendable`, `.addTab`, `Equatable`, `.bufferLine`, `.characterIndex`, `MenuTarget`, `Task Ledger Archive (Tasks 1–50)`, `CodingKeys`, `HarnessSidebarPanelViewController.swift`, `.normalizedKey`, `LayoutTemplate`, `DaemonServer`, `.keyEvent`, `.handleWake`, `HarnessSplitView`, `TabCell`, `KouenOverlayBackground`, `CommandHistorySearchController`, `3.2 สิ่งที่ implement แล้ว`, `.withinPixelCap`, `FrecencyDirectoryStore`, `main.swift`, `HarnessCLI+Server.swift`, `.text`, `PasteBufferStore`, `Completed Plans Archive`, `worktree_isolation_cli.robot`, `.parse`, `Endpoint`, `HarnessDesign`, `.firstMatch`, `LSPClient`, `LSPDiagnostic`, `TerminalGridCell`, `HarnessPaths`, `.control`, `HarnessTerminalSurfaceView`, `TerminalModes`, `code:bash (# Terminal 1: Create workspace with long-running job)`, `AttachInputBatcher`, `shim.c`, `PaneContainerView`, `.installCLI`, `ScriptRuntime.swift`, `Session Grouping and Split Session Plan`, `MainSplitViewController`, `DaemonLauncher`, `Recipe`, `AnyCodable`, `AgentNotchViewModel`, `DamageTrackingTests`, `SoftIconButton`, `code:text (:workbench start swift)`, `.makeSnapshot`, `[2.5.0] - 2026-06-12`, `HarnessGridTerminal`, `.firstWaitingTab`, `AgentVectorIcon`, `[1.3.0-vit] - 2026-06-06`, `WorkspaceFileTreeView`, `Pipe`, `String`, `HistoryRingBuffer`, `GlyphAtlas`, `code:block1 (SessionCoordinator.snapshot ──┐)`, `SwiftUI`, `.install`, `PtyDrainCeilingBenchmark`, `RGBColor`, `User Story Mapping (MANDATORY)`, `How to use Harness from the terminal only (no GUI)`, `PaneStyleSet`, `AsciiFastPathTests`, `Community None`, `What You Must Do When Invoked`, `LiveResizeTests`, `Int`, `ThaiCombiningMarkTests`, `MatchCategory`, `What You Must Do When Invoked`, `Workspace`, `CommandPromptController`, `ActiveTabCloseDisposition`, `CodingKeys`, `TransportError`, `URLDetection`, `New Tab`, `[1.5.1] - 2026-06-06`, `BinaryRefresherTests`, `BlockSummary`, `.daemonIsStale`, `InlineAICompletionView`, `[3.13.1] - 2026-07-02`, `GridCompositorTests`, `P25 — iOS/iPadOS Support`, `LSPServerRegistry`, `SessionSnapshot`, `.openRecentProject`, `AppDelegate`, `.init`, `user-stories.md`, `GlyphRasterizer`, `BinaryInstaller`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `AgentSessionSummary`, `.classify`, `DisplayWidth`, `MCP Server (harness-mcp)`, `Phase67Tests`, `[3.9.5] - 2026-06-26`, `HarnessCLI`, `.statusLineSet`, `.testDataFrameEncodeVsJSONBase64Output`, `PaneTarget`, `String`, `den`, `GridCompositor`, `ScrollbackFile`, `AsyncCLIResultBox`, `Prompt`, `TerminalServicesProvider`, `SSHTunnelManagerTests`, `ExternalOpenKind`, `P10 Task: Lazy Scrollback Reflow`, `WorkbenchCommand`, `.make`, `TerminalMetalRenderer`, `PaneBorderStatus`, `[3.5.1] - 2026-06-20`, `.make`, `FileNode`, `DaemonMetrics`, `ReflowPreviewTests`, `SessionCoordinator`, `workspace`, `release-hotfix.sh`, `Sidebar SwiftUI Migration — Knowledge`, `WindowTitleStripView`, `GitMetadataProvider`, `.install`, `HarnessSidebarPanelViewController`, `.path`, `DefaultTerminalManager`, `WindowSession`, `StatusLineView.swift`, `[2.5.0] - 2026-06-12`, `SyntaxTextView`, `.run`, `BlockTintOverlay`, `.menu`, `TerminalScrollbarView`, `FormatColor`, `click_ui_element`, `After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md.`, `code:bash (harness-cli install-hooks hermes)`, `AgentHookStrategy`, `StatusLineWidthTests`, `JSONDecoder`, `Fixes Applied (layered)`, `GitHubCLIClient`, `NotificationBus`, `settings.json`, `PaneNode`, `HarnessPaths.swift`, `.parse`, `FrameSignposter`, `AgentSnapshot`, `Terminal AI Chat (⌘I inline overlay)`, `Memory — harness-terminal`, `DesktopNotifier`, `LayoutNode`, `.theme`, `README.md`, `.drawGlyph`, `ImageProtocolTests.swift`, `.makeModel`, `Foundation`, `FileViewerViewController`, `[3.2.0] - 2026-06-16`, `Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)`, `GPU Animation Pattern — Layout Once, GPU Paints`, `P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)`, `SurfaceProgressTracker`, `.handleCat`, `FormatStyledSegment.swift`, `RGBColor`, `Fixes Applied (v3.9.1+)`, `Consumers`, `DaemonStats`, `Git Panel`, `ScrollReuseTests`, `SurfaceProgressTrackerTests.swift`, `MCPServer`, `NSTextField Leak in BoardViewController (P20 Performance)`, `Darwin`, `PresentAttempt`, `AgentIconRenderer`, `Session/Tab/Pane Hierarchy & Top Bar (CASE-028)`, `markdown.json`, `.refreshSurfaceMetadata`, `rust.json`, `FilePreviewCoordinatorTabScopeTests`, `SixelDecoder`, `Case: cwd "bleed" — session worktree jumps to wrong dir during builds`, `Competitive Position (as of v3.12.0, 2026-07-02)`, `PathToken`, `.init`, `WaitForRegistry`, `SessionEditor`, `Modifiers`, `PresentAttempt`, `tmux parity — status, adaptations, and deliberate divergences`, `ComposerPanel`, `TerminalModes`, `RunState`, `.deinit`, `HarnessOnboarding`, `.endFind`, `Added`, `ScrollbackTests`, `ccRunGet`, `.json`, `Build Scripts Self-Kill Protection`, `.panePathLookup`?**
  _High betweenness centrality (0.244) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `Terminal AI Chat (⌘I inline overlay)` to `rust.json`, `Sidebar SwiftUI Migration — Knowledge`, `ScriptRuntime.swift`, `yaml.json`, `AgentTableEntry`, `README.md`, `Changelog`, `RGBColor`, `CodingKeys`, `.parse`, `Consumers`, `LaunchdServiceInstaller`, `PaneNode`, `Community None`?**
  _High betweenness centrality (0.183) - this node is a cross-community bridge._
- **Why does `fbt()` connect `XCTestCase` to `Changelog`, `.automationList`, `CopyModeAction`, `.lines`?**
  _High betweenness centrality (0.098) - this node is a cross-community bridge._
- **Are the 18 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `RenderScheduler`) actually correct?**
  _`KouenTerminalSurfaceView` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _3545 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.05712050078247261 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.14699792960662525 - nodes in this community are weakly interconnected._