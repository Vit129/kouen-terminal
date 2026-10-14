# Graph Report - kouen-terminal  (2026-10-14)

## Corpus Check
- 902 files · ~1,022,824 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 20627 nodes · 56274 edges · 3787 communities (1530 shown, 2257 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8440 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `77958460`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 345 edges
2. `i()` - 321 edges
3. `a()` - 284 edges
4. `t()` - 253 edges
5. `SessionCoordinator` - 236 edges
6. `TerminalEmulator` - 229 edges
7. `SurfaceRegistry` - 223 edges
8. `u()` - 219 edges
9. `KouenCLI` - 210 edges
10. `IPCRequest` - 205 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 188 areas (205 edges)
2. `Command` - bridges 101 areas (108 edges)
3. `t()` - bridges 89 areas (253 edges)
4. `AgentKind` - bridges 88 areas (178 edges)
5. `IPCResponse` - bridges 79 areas (101 edges)
6. `KouenTerminalSurfaceView` - bridges 76 areas (345 edges)
7. `KouenPaths` - bridges 74 areas (150 edges)
8. `SessionCoordinator` - bridges 69 areas (236 edges)
9. `SurfaceRegistry` - bridges 65 areas (223 edges)
10. `KouenGridTerminal` - bridges 64 areas (117 edges)

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

## Communities (3787 total, 2257 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.17
Nodes (9): SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, SurfaceID, TabID (+1 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.02
Nodes (312): l, _4n(), a_n(), abn(), act(), adn(), Af(), aIn() (+304 more)

### Community 3 - "Changed"
Cohesion: 0.05
Nodes (79): V, z(), A1(), a6e(), aw(), awt(), b2(), bMt() (+71 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.08
Nodes (18): ClaudeCodeHarnessIPCTests, String, URL, ConcurrentIndexSet, .count, DaemonContentionTests, String, URL (+10 more)

### Community 5 - "IPCRequest"
Cohesion: 0.07
Nodes (24): Data, DecodedReplyFrame, output, reply, DecodedRequestFrame, input, request, FrameError (+16 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.08
Nodes (21): FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, .event(_:), .interval(_:_:), Bool, StaticString (+13 more)

### Community 7 - "Command"
Cohesion: 0.09
Nodes (31): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+23 more)

### Community 8 - "LSPMessage"
Cohesion: 0.07
Nodes (39): DaemonSubscription, .start(onData:onEnd:buffered:), .start(onResponse:onEnd:), Bool, Int32, String, TimeInterval, UInt16 (+31 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.04
Nodes (80): _5n(), _8n(), a2t(), a8n(), aae(), bce(), c9e(), ckn() (+72 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.04
Nodes (61): CGImage, RGBColor, DecodedImage, .byteCount, ImageLimits, Bool, UInt8, ImageDecoder (+53 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.08
Nodes (24): DetachedPaneOverlay, .init(coder:), .init(frame:style:), OutputCoalescer, ReconnectLatch, .isTripped, Style, detached (+16 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.11
Nodes (37): blockTokens(), br(), checkbox(), code(), codespan(), constructor(), de(), del() (+29 more)

### Community 14 - "VTParser"
Cohesion: 0.10
Nodes (19): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+11 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.08
Nodes (18): .init(forTesting:), UUID, Void, PanePipe, SurfaceMonitor, SurfaceRegistry, .subscribe(surfaceID:handler:), Bool (+10 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.11
Nodes (9): PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Double, String, UInt64, UInt8 (+1 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.16
Nodes (8): String, UInt64, TerminalSelection, CellOverlayTests, IndexSet, NSWindow, String, UInt64

### Community 19 - "SpecialKey"
Cohesion: 0.21
Nodes (15): CustomStringConvertible, atomicWrite(), backupCorruptFile(), ensureDirectories(), fnv1aHex(), KouenPathsError, .description, socketPathTooLong (+7 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.20
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.08
Nodes (17): OverlayBackground, Context, OverlayBackground, Context, ChromeBackdrop, .init(role:), KouenDesign, KouenOverlayBackground (+9 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.01
Nodes (369): _0t(), _1t(), _6e(), _6n(), _9e(), a4e(), a4n(), a7n() (+361 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.04
Nodes (54): ast(), B1(), bhn(), bln(), bwt(), cct(), cle(), D1() (+46 more)

### Community 24 - ".request"
Cohesion: 0.04
Nodes (43): a(), b(), c(), d(), g(), h(), I(), j() (+35 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.11
Nodes (11): .captureLines(joinWrapped:), .feed(_:), .promptRows, .readGrid(scrollbackOffset:), TerminalGridSnapshot, ScrollbackTests, Character, String (+3 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.10
Nodes (25): a2(), akn(), bpn(), Bsn(), bYe(), cIn(), h3n(), jmn() (+17 more)

### Community 27 - "RGBColor"
Cohesion: 0.14
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 28 - ".parse"
Cohesion: 0.06
Nodes (37): _5e(), a5n(), bTn(), bXe(), cmn(), dst(), e5e(), g0t() (+29 more)

### Community 30 - "Notification"
Cohesion: 0.17
Nodes (4): InputEncoder, InputEncoderTests, String, UInt8

### Community 31 - "Sendable"
Cohesion: 0.13
Nodes (13): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+5 more)

### Community 32 - ".addTab"
Cohesion: 0.07
Nodes (31): SidebarSessionListView, .body, .filterChipsHeader, SessionID, WorkspaceID, FleetRowView, .body, .statusColor (+23 more)

### Community 33 - "Equatable"
Cohesion: 0.15
Nodes (8): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, String

### Community 34 - "DaemonClient"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 35 - "MenuTarget"
Cohesion: 0.10
Nodes (16): StatusLineView, .init(coder:), Bool, CGFloat, FormatColor, Never, NSAttributedString, NSCoder (+8 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.14
Nodes (28): Cleanup Test Repo, Close Isolated Session Keeps Dirty Worktree, Close Isolated Session Removes Clean Worktree, Close One Isolated Does Not Affect Another, Close Session With Split Panes Removes Worktree, Create Isolated Session, Create Isolated Session Via CLI, Get Active Pane (+20 more)

### Community 37 - "String"
Cohesion: 0.05
Nodes (47): AgentChipView, .init(coder:), .intrinsicContentSize, .init(coder:), ChromeRole, sidebar, tabBar, Collection (+39 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.09
Nodes (43): Encodable, NWEndpoint, allowedBindHosts(), append(), cancelConnection(), ConnectionState, .agentMode, .authorized (+35 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.05
Nodes (56): al(), ayn(), b2t(), b3e(), bdn(), bEn(), bIn(), cMt() (+48 more)

### Community 41 - "CodingKeys"
Cohesion: 0.07
Nodes (31): ClientRecord, CountBox, DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed (+23 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.33
Nodes (6): invalidArgument, missingArgument, CommandParser, Command, Set, String

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.11
Nodes (13): .addSurface(tabID:paneID:), .tab(containingPaneID:), .tab(forSurfaceKey:), .tabIndex(surfaceKey:), .tabIndex(workspaceID:tabID:), Bool, Date, SessionID (+5 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.17
Nodes (6): SSHTunnelManager, .init(makeTunnelProcess:reachabilityProbe:), Bool, SSHTunnelManagerTests, String, URL

### Community 46 - ".buildCommand"
Cohesion: 0.09
Nodes (12): ClaudeSessionLocator, ClaudeTranscriptLine, Role, assistant, user, Any, Bool, Int32 (+4 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.10
Nodes (24): Int, Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock (+16 more)

### Community 48 - "HookEvent"
Cohesion: 0.13
Nodes (15): Executor, Hook, HookEvent, HookRegistry, Bool, Command, URL, UUID (+7 more)

### Community 49 - "DaemonServer"
Cohesion: 0.30
Nodes (4): Darwin, Foundation, Glibc, KouenCore

### Community 51 - ".keyEvent"
Cohesion: 0.11
Nodes (26): ColorKind, .base, bg, fg, underline, CompositorPane, GridCompositor, .render(panes:status:statusSegments:) (+18 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.12
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 55 - "TabCell"
Cohesion: 0.16
Nodes (7): AnyCodable, JSONRPCError, Bool, Int32, Pipe, String, ToolRegistry

### Community 56 - "NSPanel"
Cohesion: 0.11
Nodes (46): aQ(), aVe(), bme(), bqt(), cbe(), cVe(), DD(), dqt() (+38 more)

### Community 57 - "BellScanState"
Cohesion: 0.14
Nodes (11): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+3 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.11
Nodes (30): MTLClearColor, MTLCommandBuffer, BgInstance, CursorCacheKey, .invertsGlyph, DecoInstance, EncodedFrameInstances, EncodedRowInstances (+22 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.14
Nodes (15): IndexingIterator, LayoutTemplate, surfaceID, .addSurface(to:paneID:surfaceID:cwd:), .split(node:targetPaneID:direction:paneCount:before:), .split(node:targetPaneID:with:direction:beforeTarget:), .surfaceID(forPaneID:in:), .tabIndex(surfaceID:) (+7 more)

### Community 60 - "ViEngine"
Cohesion: 0.05
Nodes (161): A(), a(), aIt(), aR(), b(), B3(), Bje(), bLt() (+153 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.14
Nodes (20): ComposedCell, .asGridCell, .init(_:), .init(codepoint:fg:bg:underlineColor:bold:dim:italic:underline:blink:inverse:invisible:strikethrough:overline:), .scalar, .sgr, CompositorPane, GridCompositor (+12 more)

### Community 62 - "ComposedCell"
Cohesion: 0.19
Nodes (9): SwarmSpawnSpec, CallRecorder, .harnessCalls, .surfaceCalls, SwarmWorkerManagerTests, Bool, Duration, String (+1 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 64 - ".text"
Cohesion: 0.04
Nodes (26): _2t(), B0, BBe(), Fze, g8e(), Gg(), gPt(), hH() (+18 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.09
Nodes (43): a7e(), b9n(), cR(), dU(), Etn(), f7e(), fae(), gae() (+35 more)

### Community 67 - "String"
Cohesion: 0.15
Nodes (14): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+6 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.05
Nodes (44): AgentBridge, AgentTarget, Bool, String, SurfaceID, .onCurrentCWD, .onCurrentFile, LinePos (+36 more)

### Community 69 - ".compose"
Cohesion: 0.12
Nodes (12): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, input (+4 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.09
Nodes (35): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+27 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 72 - "XCTestCase"
Cohesion: 0.05
Nodes (96): aJ(), Ame(), aQt(), aUe(), aXt(), AYt(), bXt(), cJ() (+88 more)

### Community 73 - "README.md"
Cohesion: 0.50
Nodes (3): Hermes → Kouen, One-line install, Required: approve the hook

### Community 75 - "OptionStore"
Cohesion: 0.17
Nodes (6): Bool, NSEvent, NSEvent, SidebarTitlebarHeaderView, .mouseDownCanMoveWindow, NSEvent

### Community 76 - ".parse"
Cohesion: 0.16
Nodes (10): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab, UUID (+2 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.15
Nodes (14): FileTreeContext, Bool, NSCoder, NSDraggingInfo, NSDragOperation, NSHostingView, NSScrollView, SessionID (+6 more)

### Community 79 - "HarnessDesign"
Cohesion: 0.09
Nodes (21): .agentInfo(forWorktreePath:), MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem (+13 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 82 - ".firstMatch"
Cohesion: 0.08
Nodes (12): .receive(_:), DispatchSemaphore, FluidityBenchmarks, NSWindow, String, UInt64, KouenTerminalSurfaceWorkerTests, Bool (+4 more)

### Community 83 - "LSPClient"
Cohesion: 0.06
Nodes (37): KeybindingsService, Bool, Command, String, OptionSet, KeySpec, .description, .init(from:) (+29 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.23
Nodes (4): AgentTableEntry, Bool, Set, String

### Community 85 - "TerminalGridCell"
Cohesion: 0.07
Nodes (33): .lspPosition(for:), Codable, Equatable, object, Bool, CodingKeys, error, id (+25 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.12
Nodes (13): FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect, String, URL (+5 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.14
Nodes (14): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+6 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.13
Nodes (24): ch(), cvt(), dV(), e0n(), Eb(), evn(), ik(), iPt() (+16 more)

### Community 89 - ".cursorPos"
Cohesion: 0.13
Nodes (5): .setupPrompt, hooks, AgentHookInstallerTests, String, URL

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.09
Nodes (12): CKouenSys, pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal (+4 more)

### Community 91 - "TerminalModes"
Cohesion: 0.09
Nodes (18): FlippedView, .isFlipped, .removeWorktreeAction(_:), NSButton, NSColor, NSEvent, NSRect, NSScrollView (+10 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.17
Nodes (5): .readAntigravitySummaries(dbPath:brainDir:ftsIndex:), SQLite3, AgentHistoryMultiAgentCoverageTests, String, URL

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.09
Nodes (16): .effectiveResumeCommand(claudeMode:), LiveClaudeAgentEntry, .placement, ClaudeSessionMode, TimeoutFlag, .didFire, ClaudeCloudSessionStore, Entry (+8 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.19
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 95 - "shim.c"
Cohesion: 0.12
Nodes (19): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerFooter, .body, DirectoryPickerModel (+11 more)

### Community 96 - "Harness Usage"
Cohesion: 0.17
Nodes (9): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, FormatColor, String (+1 more)

### Community 97 - "PaneContainerView"
Cohesion: 0.06
Nodes (32): AgentHistoryDateGroup, older, .sortOrder, thisWeek, today, yesterday, AgentSessionHistoryModel, .extraRecordsShown (+24 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.16
Nodes (3): KouenSettingsTests, URL, Void

### Community 99 - ".dispatch"
Cohesion: 0.16
Nodes (12): FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID, KouenFeature (+4 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.12
Nodes (16): AgentSessionHistoryView, .body, .footerView, HistoryMenuProxy, Any, Bool, CGFloat, Date (+8 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.08
Nodes (30): AnyTransition, AgentNotchPeekEvent, Reason, errored, finished, needsInput, RowState, Bool (+22 more)

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
Cohesion: 0.10
Nodes (17): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent, ScrollbackFile (+9 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.13
Nodes (17): DiffLineType, added, deleted, modified, Notification.Name, ObserverToken, NSCoder, NSObjectProtocol (+9 more)

### Community 108 - ".resolve"
Cohesion: 0.14
Nodes (10): ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID, String, SurfaceID (+2 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.08
Nodes (20): SGRMouse, SGRMouseEvent, Bool, PaneRect, UInt8, MouseButton, left, middle (+12 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.18
Nodes (6): CopyModeReducerTests, FakeGrid, .totalLines, Set, String, TerminalGridCell

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.08
Nodes (10): HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor, Bool, String, TerminalGridCell (+2 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.30
Nodes (3): FileTreeWatcher, FileTreeWatcherTests, URL

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.05
Nodes (44): aoe(), BDt(), Bpe(), bR(), BUe(), c2t(), cFe(), displayable() (+36 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.14
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 115 - ".encode"
Cohesion: 0.11
Nodes (5): Float, Set, SurfaceID, Void, TerminalPaneRegistry

### Community 116 - "SessionGroup"
Cohesion: 0.05
Nodes (42): ap(), apn(), bGe(), bH(), f5n(), fd(), g9e(), HF() (+34 more)

### Community 117 - "PaneNode"
Cohesion: 0.11
Nodes (10): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+2 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.13
Nodes (14): CompletionPopupView, .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:), .isHovered, Bool (+6 more)

### Community 119 - "Harness command reference"
Cohesion: 0.14
Nodes (14): Agent safety CLI (`kouen-cli`), Attaching from a plain terminal, Bindings, Buffers (paste store), Composition, Hooks, Kouen command reference, Modes (+6 more)

### Community 122 - "ViEngine"
Cohesion: 0.06
Nodes (18): KouenCLITests, URL, CLIInstallLocator, DetachKeys, absent, invalid, parsed, OptionalUUID (+10 more)

### Community 123 - "Pipe"
Cohesion: 0.07
Nodes (36): IssueKeychainStore, Bool, String, IssuePriority, .color, high, low, medium (+28 more)

### Community 124 - "String"
Cohesion: 0.13
Nodes (3): KittyKeyboardTests, String, UInt8

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, S (+2 more)

### Community 126 - ".path"
Cohesion: 0.08
Nodes (30): AgentArt, AgentMark, .body, AgentMarkShape, AgentVectorIcon, Scanner, .atEnd, SVGPath (+22 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.11
Nodes (22): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), GlyphKey (+14 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.10
Nodes (20): Coordinator, DiffAnalysis, DiffFileItem, DiffFileStatus, added, .color, deleted, modified (+12 more)

### Community 129 - "SwiftUI"
Cohesion: 0.16
Nodes (5): FilePreviewCoordinator, FileTabID, Set, SplitDirection, String

### Community 131 - ".install"
Cohesion: 0.15
Nodes (6): .agentInfo(forWorktreePath:tabs:), Tab, TabID, WorkspaceID, GitPanelViewWorktreeAgentTests, GitPanelViewWorktreeNavigationTests

### Community 132 - "AgentHookInstaller"
Cohesion: 0.30
Nodes (9): .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release, `repeat`, KeyModifiers, Character, String (+1 more)

### Community 133 - ".load"
Cohesion: 0.22
Nodes (4): GroupedSessionTests, SessionGroup, Set, SurfaceID

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.17
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 135 - "CommandTarget"
Cohesion: 0.10
Nodes (11): Bool, DispatchWorkItem, NSEvent, NSPopover, NSRange, NSString, Void, SyntaxTextView (+3 more)

### Community 136 - ".startWatching"
Cohesion: 0.21
Nodes (4): CommandTarget, String, UUID, TargetSpecTests

### Community 137 - "ActivePaneService"
Cohesion: 0.11
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.17
Nodes (14): AgentIconRenderer, Scanner, .atEnd, SVGPathParser, Bool, CGFloat, CGPath, CGPoint (+6 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.16
Nodes (4): l8e(), $Rt(), tJe(), YUt

### Community 142 - "CopyModeGridSource"
Cohesion: 0.13
Nodes (11): Am(), bze(), Cm(), EQ(), Hm(), Im(), lte(), MBe() (+3 more)

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.02
Nodes (130): e(), t(), _3e(), a2n(), aU(), aXe(), b_n(), bct() (+122 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 146 - "DecodedImage"
Cohesion: 0.15
Nodes (8): ContextResolutionEngine, Bool, String, Bool, String, TokenGuard, ContextResolutionEngineTests, String

### Community 147 - "FileTreeWatcher"
Cohesion: 0.07
Nodes (12): SessionCoordinator, .selectWorkspace(_:), Bool, Double, PaneID, PaneNode, SplitDirection, String (+4 more)

### Community 148 - "TriState"
Cohesion: 0.02
Nodes (162): f(), _9n(), a0n(), a3n(), a6n(), a9n(), aHt(), aMt() (+154 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.29
Nodes (4): tool, KouenDaemonToolsTests, String, URL

### Community 151 - ".evaluate"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 154 - "LiveResizeTests"
Cohesion: 0.08
Nodes (25): Array, GroupHeaderRow, .body, PickerItem, .groupLabel, historyBlock, .id, recipe (+17 more)

### Community 155 - "Int"
Cohesion: 0.14
Nodes (11): FileFuzzyMatcher, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool, Character (+3 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.07
Nodes (25): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, .acceptsFirstResponder (+17 more)

### Community 157 - "Added"
Cohesion: 0.10
Nodes (11): Bool, String, UInt8, TerminalEmulator, .captureLines(fromLine:toLine:), .onSetClipboard, TerminalColorRole, background (+3 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 159 - "MatchCategory"
Cohesion: 0.04
Nodes (31): SessionID, CornerInfo, EditorDividerView, HitTestPassthroughView, KouenSplitView, .dividerColor, .dividerThickness, .init(coder:) (+23 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.16
Nodes (15): FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose, .onSelect (+7 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.14
Nodes (13): init(), PairingBox, .current, .isLockedOut, PendingPairing, stop(), Date, TimeInterval (+5 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.06
Nodes (18): NSResponder, NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent (+10 more)

### Community 163 - "Workspace"
Cohesion: 0.17
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

### Community 164 - "CommandPromptController"
Cohesion: 0.10
Nodes (21): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, IssueInfo (+13 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.28
Nodes (7): SSETransport, .isRunning, .listener, Bool, NWConnection, String, UInt16

### Community 166 - "LiveSession"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.08
Nodes (42): .resolvedGitStatus, AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem (+34 more)

### Community 169 - "Fixed"
Cohesion: 0.16
Nodes (9): PaneID, SurfaceID, Tab, TabID, UUID, BrowserPaneReuseScopeTests, PaneNode, Tab (+1 more)

### Community 170 - "URLDetection"
Cohesion: 0.12
Nodes (7): Bool, Range, Set, String, URLDetection, StringProtocol, EngineConformanceTests

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.14
Nodes (15): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+7 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.07
Nodes (24): LSPFileSession, Never, String, Task, URL, Void, URL, SyntaxDefinitionTarget (+16 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.10
Nodes (5): ISO8601DateFormatter, KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), Bool, String

### Community 175 - "RGBColorTests"
Cohesion: 0.19
Nodes (11): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, .selectedHost (+3 more)

### Community 177 - ".rects"
Cohesion: 0.16
Nodes (3): CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 178 - "InlineAICompletionView"
Cohesion: 0.24
Nodes (9): CopyModeGridSource, .promptRows, CopyModeReducer, Bool, Character, NSRegularExpression, Range, String (+1 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.14
Nodes (17): PaneBorderStatus, bottom, off, top, PaneLeaf, PaneNode, branch, leaf (+9 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.16
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 181 - "GridCompositorTests"
Cohesion: 0.18
Nodes (5): CompositorPane, GridCompositorTests, Bool, String, TerminalGridSnapshot

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.13
Nodes (15): BranchSwitchHelper, FileTreeSwiftUIView, .body, .filteredNodes, .rootPath, .scanOptions, .sessionID, .taskID (+7 more)

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
Cohesion: 0.15
Nodes (13): KouenOnboarding, Bool, ImmersiveOnboardingWindowController, .init(coder:), .init(onDismiss:), ImmersivePanel, .canBecomeKey, .canBecomeMain (+5 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.13
Nodes (9): NSDraggingInfo, NSDragOperation, PasteController, Bool, NSPasteboard, String, TimeInterval, URL (+1 more)

### Community 190 - "user-stories.md"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.13
Nodes (7): ScriptRuntime, Any, String, URL, JSContext, JSValue, ScriptingTests

### Community 192 - "GlyphRasterizer"
Cohesion: 0.11
Nodes (18): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), RasterizedGlyph, ShapedGlyph (+10 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.16
Nodes (12): UInt16, TTYSize, RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal (+4 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.03
Nodes (38): TerminalGridCell, NSEvent, Any, Bool, CGFloat, NSEvent, NSMenu, NSMenuItem (+30 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.19
Nodes (7): TerminalGridCell, Case, ReflowCorpusTests, .corpus, .goldenDir, String, URL

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.09
Nodes (19): Selector, .init(frame:), Kind, primary, secondary, KouenPillButton, .init(title:kind:), .isHovered (+11 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.11
Nodes (12): UnsafeBufferPointer, TerminalCellWidth, UnsafeBufferPointer, CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable (+4 more)

### Community 198 - ".classify"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.26
Nodes (8): InstallResult, Shell, bash, fish, zsh, ShellIntegration, Bool, URL

### Community 202 - "PaletteModel"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.06
Nodes (31): CaseIterable, ExperienceMode, agent, .displayName, .foregroundsAgents, full, .notchEnabledByDefault, persistent (+23 more)

### Community 204 - "From tmux"
Cohesion: 0.25
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 205 - "CopyModeState"
Cohesion: 0.14
Nodes (11): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+3 more)

### Community 207 - "scheduleRender"
Cohesion: 0.18
Nodes (7): CheckpointInfo, CheckpointManager, Bool, Date, String, CheckpointManagerTests, String

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.22
Nodes (8): AgentRoutingRule, AgentRoutingRuleStore, Bool, String, URL, UUID, AgentRoutingRuleStoreTests, URL

### Community 209 - "SettingsRemoteView"
Cohesion: 0.14
Nodes (15): Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow, launchStart, StartupMetrics (+7 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.20
Nodes (4): CompletionGenerator, String, .fishCompletionSource, CompletionGeneratorTests

### Community 211 - "PaneTarget"
Cohesion: 0.26
Nodes (8): ignoreSIGPIPE(), Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 212 - ".translate"
Cohesion: 0.11
Nodes (9): String, WorkspaceID, CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab, DaemonSyncServiceBranchNotifyTests (+1 more)

### Community 213 - "String"
Cohesion: 0.09
Nodes (10): TimeInterval, AgentHandoffBuilder, Bool, String, RemoteControlURLProvider, Bool, URL, HandoffDirectoryTests (+2 more)

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.06
Nodes (30): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+22 more)

### Community 215 - ".lines"
Cohesion: 0.14
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 216 - "CellColorResolverTests"
Cohesion: 0.12
Nodes (10): WindowInputRouterTests, UInt8, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8 (+2 more)

### Community 217 - "GridCompositor"
Cohesion: 0.10
Nodes (20): .pairedAlreadyBanner, .pairingQRPanel, FleetJobItem, .isActive, .launchAgentScriptPath, .statusDisplay, AutomationsFleetView, .automationsList (+12 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.18
Nodes (4): AgentScanner, Bool, DispatchSourceTimer, TimeInterval

### Community 219 - "Prompt"
Cohesion: 0.12
Nodes (10): DaemonSyncService, .sync(metadataOnly:), Bool, Never, PaneNode, Task, Void, DaemonSyncServiceBrowserPaneMergeTests (+2 more)

### Community 220 - "Section"
Cohesion: 0.17
Nodes (11): NotchGeometry, .fallback, NSScreen, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics (+3 more)

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.07
Nodes (32): ace(), ake(), ate(), avt(), b6(), cvn(), eoe(), fH() (+24 more)

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.18
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 224 - "CellColorResolver"
Cohesion: 0.24
Nodes (9): ANSIPalette, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors, Bool, Double, TerminalGridCell (+1 more)

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.18
Nodes (11): JSONRPCMessage, notification, request, response, StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength (+3 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.14
Nodes (18): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, PaneLeaf, PaneNode (+10 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.06
Nodes (25): NSCursor, TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid (+17 more)

### Community 228 - "sessionRow"
Cohesion: 0.13
Nodes (7): KeybindingsStore, .fileURL, URL, KeybindingsStoreTests, URL, Void, String

### Community 229 - ".decide"
Cohesion: 0.23
Nodes (5): MutationResult, RemoteHost, RemoteHostStore, Bool, String

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.21
Nodes (6): FormatColor, ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 231 - "ExternalOpenKind"
Cohesion: 0.17
Nodes (21): Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors, ContrastGrade (+13 more)

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.15
Nodes (8): BoardViewController, .isVisible, FlippedView, .isFlipped, Bool, Set, TabID, BoardViewControllerTests

### Community 234 - ".scan"
Cohesion: 0.09
Nodes (7): Divergence, Bool, String, TimeInterval, WorktreeInfo, String, WorktreeIsolationTests

### Community 235 - "WorkbenchCommand"
Cohesion: 0.22
Nodes (4): PaneRectSolverTests, Bool, PaneNode, PaneRect

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.14
Nodes (10): Bool, CGFloat, NSCoder, NSLayoutConstraint, NSPoint, NSRect, WindowTitleStripView, .init(coder:) (+2 more)

### Community 238 - ".make"
Cohesion: 0.08
Nodes (23): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSEvent (+15 more)

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.22
Nodes (7): Group, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, CGFloat, NSTextField, NSWindow

### Community 240 - "PaneBorderStatus"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 242 - "AgentBridge"
Cohesion: 0.06
Nodes (32): CustomEndpointTester, Result, Bool, String, URL, ModelKeyStore, Bool, String (+24 more)

### Community 243 - ".make"
Cohesion: 0.12
Nodes (20): ArtifactKind, html, image, markdown, text, AutomationsFleetModel, .load(detectScheduledRuns:), AutomationSource (+12 more)

### Community 244 - "FileNode"
Cohesion: 0.15
Nodes (14): FileNode, GitStatusType, added, deleted, modified, renamed, unmodified, untracked (+6 more)

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.18
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 247 - ".renderFixture"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.06
Nodes (34): agt(), c8n(), cAn(), ctn(), dmn(), e2n(), g7e(), If() (+26 more)

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.16
Nodes (9): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+1 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.30
Nodes (4): TaskStore, tasks, URL, TaskStoreTests

### Community 251 - "SessionCoordinator"
Cohesion: 0.16
Nodes (5): SSETransportTests, UInt16, MCPServer, String, NWListener

### Community 252 - "NSViewRepresentable"
Cohesion: 0.08
Nodes (22): .init(coder:), BrowserProgressLine, .init(coder:), .init(frame:), BrowserTabButton, .init(coder:), .init(title:isActive:onSelect:onClose:), DesignModePopoverViewController (+14 more)

### Community 253 - "Split Right"
Cohesion: 0.24
Nodes (7): BinaryInstaller, .bundledMacOSDir, Bool, TimeInterval, BinaryInstallerVersionTests, String, URL

### Community 254 - "BoardViewController"
Cohesion: 0.08
Nodes (30): aOn(), ase(), aTn(), aV(), bb(), cce(), ef(), f4n() (+22 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.08
Nodes (22): BrowserPaneRegistry, BrowserPaneView, .init(url:paneID:), .webView(_:didCommit:), DesignModeElementInfo, Any, NSPopover, NSWindow (+14 more)

### Community 256 - "GitMetadataProvider"
Cohesion: 0.13
Nodes (6): agentWaitChannel(), HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.18
Nodes (20): CoreImage, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription, .surfaceID, detectHost() (+12 more)

### Community 258 - "WindowTitleStripView"
Cohesion: 0.19
Nodes (7): AnyView, .rowList, AgentNotchViewModel, Bool, CGFloat, Duration, String

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.29
Nodes (5): AgentNotchPresentation, closed, open, peek, AgentNotchWindowActivator

### Community 260 - ".welcome"
Cohesion: 0.08
Nodes (25): CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display, found, .isReady (+17 more)

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 262 - ".install"
Cohesion: 0.37
Nodes (3): .block(atPromptLine:), String, TerminalBlockStoreTests

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.19
Nodes (11): DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String, StyledSegment (+3 more)

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
Nodes (11): PaneBorderStatus, Bool, Command, DispatchWorkItem, PaneID, PaneLeaf, PaneNode, PaneRect (+3 more)

### Community 271 - "StatusLineView.swift"
Cohesion: 0.14
Nodes (3): AgentLaunchCommandsTests, URL, Void

### Community 272 - "SGRMouseEvent"
Cohesion: 0.27
Nodes (9): Command Prompt, Find In Files, Git Panel, Open Command Palette, Switch To Session 1, Switch To Session 2, Rapid Session Switch While Typing, Switch Between Isolated And Normal Session (+1 more)

### Community 273 - "KeySpec"
Cohesion: 0.18
Nodes (13): FeaturePhase, architect, completed, dev, interview, qaDesign, qaVerify, .title (+5 more)

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.15
Nodes (8): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ActivityAssertionManagerTests

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.18
Nodes (5): KeyTokenParser, Bool, String, KeyTokenParserTests, Phase6KeysTests

### Community 277 - ".run"
Cohesion: 0.23
Nodes (9): AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor (+1 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.30
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 280 - ".menu"
Cohesion: 0.15
Nodes (10): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, Set, SurfaceID (+2 more)

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.31
Nodes (4): GraphifyIndexCache, S, Set, String

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.15
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 283 - "FormatColor"
Cohesion: 0.26
Nodes (3): String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 284 - "click_ui_element"
Cohesion: 0.16
Nodes (6): LSPTextLocation, .position, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.14
Nodes (9): MarkdownPreviewView, Any, Bool, Error, String, URL, Void, KouenSyntaxResources (+1 more)

### Community 287 - ".apply"
Cohesion: 0.41
Nodes (5): InstallResult, ShellCompletionInstaller, Bool, String, URL

### Community 288 - "AgentHookStrategy"
Cohesion: 0.12
Nodes (9): .activeTab, .init(url:paneID:webView:), .webView(_:didFinish:), BrowserTab, Double, URL, UUID, tabs (+1 more)

### Community 290 - "Process"
Cohesion: 0.08
Nodes (13): GitPanelView, .isHidden, .removeWorktreeAction(path:), GitResult, Bool, DispatchWorkItem, NSMenuItem, String (+5 more)

### Community 291 - "JSONDecoder"
Cohesion: 0.20
Nodes (3): String, TerminalGridSnapshot, VTConformanceCorpusTests

### Community 292 - "Release runbook"
Cohesion: 0.25
Nodes (4): Full local signing path (needs a Developer ID cert; not currently used), How this fork actually releases, Release runbook, Scripted flow

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.11
Nodes (12): CodingKeys, error, id, jsonrpc, method, JSONRPCId, int, string (+4 more)

### Community 294 - "GitHubCLIClient"
Cohesion: 0.24
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 295 - "AgentApprovalBar"
Cohesion: 0.12
Nodes (9): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, KouenApp, FileChangeWatcherTests (+1 more)

### Community 296 - "NotificationBus"
Cohesion: 0.41
Nodes (4): KouenFeatureMarkdownSync, Bool, String, URL

### Community 297 - "settings.json"
Cohesion: 0.17
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, Bool, Double (+3 more)

### Community 299 - "PaneNode"
Cohesion: 0.11
Nodes (23): CGFloat, FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView (+15 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.14
Nodes (13): AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID, .snapshotPayload, NotificationBus (+5 more)

### Community 301 - ".parse"
Cohesion: 0.09
Nodes (13): ParsedShortcut, .displayString, PrefixKeymap, Any, Bool, NSEvent, String, TimeInterval (+5 more)

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.15
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 303 - ".encodeMouse"
Cohesion: 0.17
Nodes (5): TabID, WorkspaceID, AgentCommandTests, String, Tab

### Community 304 - "00-inception-plan.md"
Cohesion: 0.16
Nodes (16): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+8 more)

### Community 305 - ".script"
Cohesion: 0.22
Nodes (11): .webView(_:createWebViewWith:for:windowFeatures:), .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didStartProvisionalNavigation:), LoadCompletionState, CheckedContinuation, Error, WKNavigation (+3 more)

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 307 - "ViPathTokenTests"
Cohesion: 0.14
Nodes (14): Bool, String, UUID, TaskDaemonBridge, Status, ciFailing, done, mergeReady (+6 more)

### Community 308 - "Send Ex Command"
Cohesion: 0.13
Nodes (18): AgentHistoryFTSIndex, .deleteSession(sessionID:), .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:surfaceTag:topicSegments:), .needsReindex(sessionID:mtime:fileSize:), .pruneMissingSessions(validTranscriptPaths:), .saveRecord(_:mtime:fileSize:), .search(query:limit:), .searchRanked(query:limit:includeSnippet:) (+10 more)

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.11
Nodes (22): keys, ITerm2InlineImage, .heightArg, .preserveAspectRatio, .widthArg, Bool, String, UInt8 (+14 more)

### Community 312 - "AgentSnapshot"
Cohesion: 0.12
Nodes (20): Array, Bool, Date, Decoder, PaneID, PaneNode, String, TabID (+12 more)

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.08
Nodes (28): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary, RowKind (+20 more)

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.06
Nodes (42): _7n(), a0(), abt(), aen(), b5e(), bOn(), c6e(), d9n() (+34 more)

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
Cohesion: 0.10
Nodes (13): DaemonCommandExecutor, Command, BellScanState, esc, normal, string, stringEsc, PendingVersionBanner (+5 more)

### Community 322 - "DesktopNotifier"
Cohesion: 0.13
Nodes (17): FormatContextBuilder, DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:) (+9 more)

### Community 323 - "LayoutNode"
Cohesion: 0.15
Nodes (9): InputGate, .siblings, SurfaceIO, .currentSubscription, String, SurfaceID, UInt16, UInt64 (+1 more)

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.07
Nodes (24): .logIfFailed(_:), .request(_:), Error, Logger, OSSignposter, DaemonClientActor, TimeInterval, DaemonSessionError (+16 more)

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.07
Nodes (15): ScreenPos, bottom, middle, top, KouenLSP, FileGraphInfo, GraphifyLSPBridge, Double (+7 more)

### Community 327 - ".theme"
Cohesion: 0.31
Nodes (7): PaneOutputWaiter, PaneOutputWaitResult, SpawnedAgentSurface, CheckedContinuation, Never, UInt64, UUID

### Community 328 - "README.md"
Cohesion: 0.11
Nodes (14): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+6 more)

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 330 - ".drawGlyph"
Cohesion: 0.18
Nodes (15): CellMetrics, ComposedFrame, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth (+7 more)

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.05
Nodes (61): em(), _4e(), aA(), ag(), bj(), cae(), d0t(), d8n() (+53 more)

### Community 332 - "Added"
Cohesion: 0.11
Nodes (22): item, .saveRecordsBatch(_:), CachedSessionEntry, Date, AgentHistoryScanner, .readJSONLLines(from:), .readJSONLLines(from:fromOffset:), AgentHistoryTurn (+14 more)

### Community 333 - "RealPty"
Cohesion: 0.18
Nodes (8): ClaudeRunSummary, Date, Double, Int32, String, UUID, String, UUID

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.09
Nodes (17): EndpointError, connectionFailed, .description, notYetSupported, pathTooLong, String, EndpointConnector, Int32 (+9 more)

### Community 335 - ".makeModel"
Cohesion: 0.24
Nodes (6): FileTreeNode, NodeRow, .body, Bool, Error, String

### Community 336 - "run.sh"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 337 - "CommandExecutionError"
Cohesion: 0.22
Nodes (9): FormatContext, FormatString, FormatStyle, Bool, Character, Date, FormatColor, String (+1 more)

### Community 338 - "CSIParams"
Cohesion: 0.19
Nodes (8): AgentRemoteControlDaemonService, Set, String, Void, AgentRemoteControlDaemonServiceTests, LogBox, .count, String

### Community 339 - "Foundation"
Cohesion: 0.14
Nodes (15): AppKit, KouenCopyMode, KouenTerminalEngine, KouenTerminalKit, KouenTerminalRenderer, KouenTheme, Metal, ImmersiveEffects (+7 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.15
Nodes (3): CellColorResolverTests, .resolver, CellColorResolver

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.25
Nodes (8): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String

### Community 342 - "Added"
Cohesion: 0.30
Nodes (7): Bool, NSPasteboard, NSString, String, URL, TerminalServicesProvider, AutoreleasingUnsafeMutablePointer

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.24
Nodes (15): Decodable, AssistantLine, Content, Message, ResultLine, Bool, Double, String (+7 more)

### Community 344 - "FileViewerViewController"
Cohesion: 0.14
Nodes (10): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+2 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.19
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 349 - "Contents.json"
Cohesion: 0.16
Nodes (16): SwarmFleetSnapshot, SwarmLane, pty, structured, SwarmTaskNode, SwarmTaskStatus, cancelled, failed (+8 more)

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.18
Nodes (3): MobileBridgeAttachFileTests, String, URL

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.17
Nodes (9): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.11
Nodes (13): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, PaneLeaf (+5 more)

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.15
Nodes (16): CGFloat, NSHostingView, NSLayoutConstraint, Range, Tab, TabBarLayoutMetrics, .pitch, TerminalTabBarBody (+8 more)

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.23
Nodes (5): WorktreeManager, String, URL, UUID, WorktreeIsolationDaemonTests

### Community 355 - ".deepMerge"
Cohesion: 0.18
Nodes (14): ProjectGroupWatcher, StreamBox, Bool, DispatchQueue, escaping, FSEventStreamRef, MainActor, Never (+6 more)

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.15
Nodes (9): PaneID, PaneNode, SurfaceID, CGFloat, ResizeDirection, down, left, right (+1 more)

### Community 357 - ".handleCat"
Cohesion: 0.13
Nodes (17): BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserResponsePayload, cookies, error, network (+9 more)

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.12
Nodes (3): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess

### Community 359 - "OcclusionTests"
Cohesion: 0.12
Nodes (5): KouenCLI, HistorySearchQueryTests, MemoCommandTests, URL, TaskCommandTests

### Community 360 - "State"
Cohesion: 0.18
Nodes (14): KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:), .scrollbackLines, ClaudeSessionMode, Decoder, Double, Float (+6 more)

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.09
Nodes (15): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, AgentRoutingResolver (+7 more)

### Community 362 - "RGBColor"
Cohesion: 0.19
Nodes (13): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Bool, Duration (+5 more)

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.09
Nodes (19): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+11 more)

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.08
Nodes (18): ControlMessage, AgyModelCatalog, Catalog, Date, String, TimeInterval, AgyMobileCommands, String (+10 more)

### Community 366 - "Consumers"
Cohesion: 0.13
Nodes (15): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+7 more)

### Community 367 - "DaemonStats"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 368 - "Tab"
Cohesion: 0.14
Nodes (5): CSIParams, .count, TerminalGridColor, TerminalGridUnderline, UInt8

### Community 369 - "Git Panel"
Cohesion: 0.03
Nodes (122): _3n(), a6(), aDt(), ak(), AOt(), Ape(), bOt(), _Bt() (+114 more)

### Community 370 - ".encode"
Cohesion: 0.19
Nodes (10): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+2 more)

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.12
Nodes (8): OnboardingController, KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, BinaryInstallerDisplayTests, OnboardingEnvironmentTests

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.15
Nodes (14): .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:), .init(frame:) (+6 more)

### Community 373 - "Prompt"
Cohesion: 0.18
Nodes (3): fQ, hqe(), M9()

### Community 374 - ".run"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

### Community 375 - ".install"
Cohesion: 0.23
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 376 - "ScrollReuseTests"
Cohesion: 0.07
Nodes (21): OSCTerminatorMatch, PtyError, launchFailed, RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), ScrollbackEntry, ScrollbackReplaySegment, ShellLaunchProfile (+13 more)

### Community 377 - "Identifiable"
Cohesion: 0.22
Nodes (7): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 379 - "MCPServer"
Cohesion: 0.13
Nodes (6): azt(), F7, ibe(), mathmlBuilder(), q$e(), UHt()

### Community 380 - "PromptQueue"
Cohesion: 0.12
Nodes (6): String, .trimmed, AgentTitleInference, Bool, .effectiveAgentKind, AgentDetectorTests

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.18
Nodes (8): .effectiveResumeCommand(mode:), AgentSessionMode, cloud, .launchCommand, .launchFlags, local, remoteControl, Decoder

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.12
Nodes (17): OnboardingStep, complete, discover, .id, setup, shell, .title, welcome (+9 more)

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.29
Nodes (6): Any, Error, MainActor, Sendable, String, Void

### Community 387 - "User Profile"
Cohesion: 0.06
Nodes (28): TerminalDamage, Range, String, TerminalGridCell, TerminalBufferMatch, TerminalBufferSearch, RenderColor, String (+20 more)

### Community 388 - "Darwin"
Cohesion: 0.14
Nodes (14): .agentColorBinding, colors, ANSIPalette, CellColorResolver, MochaTheme, ResolvedCellColors, .init(hex:), .init(red:green:blue:alpha:) (+6 more)

### Community 389 - "HarnessCLITests"
Cohesion: 0.14
Nodes (13): SwarmFleetBody, .body, SwarmNodeRowView, .body, .statusColor, Duration, Void, SwarmFleetSnapshotWire (+5 more)

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.41
Nodes (7): FeatureSummary, FeatureTaskSummary, GateSummary, Bool, Date, String, UUID

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.16
Nodes (14): CLI Isolate Creates Worktree And Session, CLI Isolate With Custom Branch Name, Close Session Keeps Dirty Worktree, Close Session Removes Clean Worktree, Create Isolated Session And Select, Drag Reorder Past Worktree Row No Crash, Git Checkout In Normal Session Does Not Affect Isolated, Isolate Without Branch Uses Detached HEAD (+6 more)

### Community 402 - "View"
Cohesion: 0.12
Nodes (19): QuietRow, .body, StatusPill, .body, .color, BinaryInstaller.DetectionStatus, SetupStepView, .body (+11 more)

### Community 403 - "PresentAttempt"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.23
Nodes (5): ListeningPortScanner, Int32, Set, String, ListeningPortScannerTests

### Community 405 - "AgentIconRenderer"
Cohesion: 0.28
Nodes (4): TerminalGridSnapshot, ReflowPreviewTests, .feeds, String

### Community 406 - "main.swift"
Cohesion: 0.29
Nodes (4): SwarmDAGStore, String, UUID, SwarmDAGStoreTests

### Community 407 - "Fixed"
Cohesion: 0.10
Nodes (17): .body, .mcpButton, json, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter (+9 more)

### Community 408 - "IPC Architecture"
Cohesion: 0.21
Nodes (8): DaemonMetrics, Snapshot, .meanLockWaitMicros, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.33
Nodes (6): SurfaceProgressTracker, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.17
Nodes (3): ShellIntegrationTests, .repoRoot, URL

### Community 412 - "go.json"
Cohesion: 0.15
Nodes (6): aD(), ezt(), GGe, Hzt(), Kp(), urn

### Community 414 - "json.json"
Cohesion: 0.17
Nodes (16): SessionRef, byID, byName, next, previous, String, UUID, TargetSpec (+8 more)

### Community 415 - "markdown.json"
Cohesion: 0.27
Nodes (6): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.19
Nodes (15): BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, Keybinding, .displayKey, MenuModifiers (+7 more)

### Community 417 - "rust.json"
Cohesion: 0.08
Nodes (26): Container, .init(coder:), .init(frame:), NotchOverviewRow, .approvalControls, .background, .badge, .body (+18 more)

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.20
Nodes (4): Bool, String, SurfaceID, TimeInterval

### Community 419 - "typescript.json"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 420 - "yaml.json"
Cohesion: 0.24
Nodes (6): bUt(), FBe(), Gbe(), handler(), mUt(), _Q()

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.07
Nodes (21): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+13 more)

### Community 422 - "HintModeOverlay"
Cohesion: 0.07
Nodes (13): SessionGroup, SettingsModelsFocus, String, KouenSidebarPanelViewController, NSMenuItem, SessionGroup, String, NSMenu (+5 more)

### Community 423 - "SixelDecoder"
Cohesion: 0.05
Nodes (42): .filteredJobs, NaturalLanguage, MatchLocationInfo, AgentHistorySearch, Hit, IDFCache, Bool, Double (+34 more)

### Community 424 - ".parseDiffHunks"
Cohesion: 0.20
Nodes (11): Notification.Name, os, attribute_lines(), main(), redraw_frames(), repeated_chunk(), run_case(), sgr_lines() (+3 more)

### Community 425 - "AgentVectorIcon"
Cohesion: 0.25
Nodes (4): StatusLineWidthTests, StatusLineWidth, String, StyledSegment

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.29
Nodes (6): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Carbon

### Community 427 - ".delay"
Cohesion: 0.21
Nodes (7): EnvironmentStore, Persisted, String, URL, global, EnvironmentStoreTests, URL

### Community 428 - "TaskDashboardView"
Cohesion: 0.20
Nodes (4): TerminalModes, .encode(text:modifiers:modes:), Bool, .appCursor

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.11
Nodes (22): OptionStore, OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Scope, pane (+14 more)

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.11
Nodes (15): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+7 more)

### Community 431 - "BoardCardView"
Cohesion: 0.14
Nodes (19): .color, BoardCard, BoardColumn, .name, BoardColumnKind, .displayName, done, error (+11 more)

### Community 432 - "PathToken"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.23
Nodes (4): DataBox, Any, GitPanelViewDiffErrorTests, String

### Community 434 - "Project History"
Cohesion: 0.11
Nodes (23): a9e(), avn(), c0t(), cdn(), Dwe(), eSn(), f6(), Fsn() (+15 more)

### Community 435 - ".init"
Cohesion: 0.11
Nodes (5): KouenThemeCatalog, .allThemes, String, ANSIPaletteTests, KouenThemeCatalogTests

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
Cohesion: 0.16
Nodes (8): brn, grn, hrn(), JGe(), KGe(), prn(), qGe(), zGe()

### Community 440 - "LegacySnapshot"
Cohesion: 0.14
Nodes (13): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+5 more)

### Community 441 - "RemoteHostStore"
Cohesion: 0.24
Nodes (8): ProjectDropTarget, .init(coder:), .init(frame:), NSCoder, NSDraggingInfo, NSDragOperation, NSRect, URL

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.22
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 443 - "main.swift"
Cohesion: 0.11
Nodes (20): Bool, String, UInt8, TerminalCellWidth, normal, spacerTail, wide, TerminalGridCell (+12 more)

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 445 - "Section"
Cohesion: 0.17
Nodes (5): DirectionalAxis, down, left, right, up

### Community 446 - "Modifiers"
Cohesion: 0.27
Nodes (6): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection

### Community 447 - "PaletteMode"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.18
Nodes (10): Bug 1 - Rotation Grace Slot Keeps The Previous Token Redeemable, Bug 1 - Rotation Shifts The Outgoing Token Into The Grace Slot, Bug 1 - Stop Fully Clears The Grace Slot, Bug 1 - Token Lifetime Not Regressed Below The Human-Flow Window, Bug 2 - Client onerror Does Not Clobber The Server Error Banner, Bug 2 - No Abrupt Cancel Immediately After The Error Text, Bug 2 - Reject Path Closes Gracefully With Policy-Violation Code 1008, Bug 3 - QR Not Printed When No Listener Is Ready (+2 more)

### Community 449 - "PresentAttempt"
Cohesion: 0.08
Nodes (15): Tab, BrowserIntegrationController, PaneID, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), PaneNode, String, SurfaceID (+7 more)

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.16
Nodes (13): Motion, .entrance, .spring, .standardEase, SwarmFleetView, .init(coder:), CGFloat, NSCoder (+5 more)

### Community 451 - ".run"
Cohesion: 0.18
Nodes (10): SessionID, String, Void, TaskDashboardBody, .body, .init(onJumpToSession:), TaskRowView, .body (+2 more)

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.12
Nodes (12): CoreGraphics, CoreText, ImageIO, .shapedRunStats, ShapedRunCacheStats, ShapedGlyphSignature, Bool, CGFloat (+4 more)

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.18
Nodes (12): DotView, .init(coder:), .init(frame:), statusColor(), Bool, Context, NSCoder, NSColor (+4 more)

### Community 454 - ".recordReapedGenerationForTesting"
Cohesion: 0.07
Nodes (38): SettingsAppearanceView, .autoTheme, .body, .themeSection, .windowSection, SliderRow, .body, .displayValue (+30 more)

### Community 455 - "ComposerPanel"
Cohesion: 0.20
Nodes (9): AnyObject, CommandExecutionError, daemonError, .description, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor (+1 more)

### Community 456 - "TerminalModes"
Cohesion: 0.15
Nodes (12): GridCompositor, Configuration, SessionGroup, SessionID, Tab, TabID, WorkspaceID, TabSelector (+4 more)

### Community 457 - ".normalizedKey"
Cohesion: 0.25
Nodes (7): CommandParseError, .description, emptyInput, expectedCommand, missingFlag, unknownCommand, unterminatedString

### Community 459 - ".encode"
Cohesion: 0.18
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 460 - "RunState"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 461 - ".worktreeList"
Cohesion: 0.22
Nodes (8): MCP Control Allowed With Env Var, MCP Control Denied Without Env Var, MCP KouenBoard Returns Columns, MCP KouenList Returns Sessions, MCP ReadPaneOutput Returns Content, Run MCP Request, Run MCP Request Allowed, Run MCP Request Denied

### Community 462 - "AGENTS.md"
Cohesion: 0.22
Nodes (8): Browser Pane Open Close Rapid, File Preview Open Close, Git Fetch Shows Toast, Launch Kouen Staging, Memory Stability After 30 Seconds, Quit Kouen Staging, Sidebar Toggle Immediately After Launch, Tab Close While Mouse Moving

### Community 463 - ".deinit"
Cohesion: 0.26
Nodes (3): BellScanTests, Bool, UInt8

### Community 464 - "MouseButton"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 465 - "DirectionalAxis"
Cohesion: 0.36
Nodes (5): PaneLeaf, SessionGroup, Any, String, Tab

### Community 466 - "ReflowFastPathTests"
Cohesion: 0.24
Nodes (8): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8, .body

### Community 467 - ".moveSelection"
Cohesion: 0.22
Nodes (3): ClaudeSessionModeTests, URL, Void

### Community 468 - "Never"
Cohesion: 0.18
Nodes (13): Profile, edit, readonly, Run, RunState, cancelled, failed, running (+5 more)

### Community 469 - "PresentAttempt"
Cohesion: 0.14
Nodes (12): WeakScriptMessageHandler, .init(frame:), .webView(_:decidePolicyFor:decisionHandler:), .webView(_:didFinish:), MainActor, NSRect, WKNavigation, WKNavigationAction (+4 more)

### Community 470 - "DispatchTime"
Cohesion: 0.29
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

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
Cohesion: 0.30
Nodes (5): SearchBenchmarks, String, UInt64, URL, Void

### Community 476 - ".steps"
Cohesion: 0.22
Nodes (7): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, NSCoder, Void

### Community 477 - ".endFind"
Cohesion: 0.16
Nodes (13): BoxDrawing, Kind, arms, dashH, dashV, halfDown, halfLeft, halfRight (+5 more)

### Community 478 - ".install"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 479 - "ScrollbackTests"
Cohesion: 0.25
Nodes (6): calculate(), constructor(), kOt(), mBt, r2e(), sOt()

### Community 480 - "Command Prompt Architecture"
Cohesion: 0.20
Nodes (8): DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSViewCornerConfiguration, SurfaceID, Void

### Community 482 - ".resolve"
Cohesion: 0.19
Nodes (17): Close Pane, Next Session, Previous Session, Split Down, Split Right, Cmd W Closes Pane When Split, Zombie Crash Rapid Close While Typing, Zombie Crash Rapid Split Close Cycle (+9 more)

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
Cohesion: 0.06
Nodes (36): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+28 more)

### Community 490 - "ccRunGet"
Cohesion: 0.21
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 491 - "Added"
Cohesion: 0.18
Nodes (9): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+1 more)

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 494 - "ccRunInfo"
Cohesion: 0.33
Nodes (5): Kouen LSP Diagnostics Does Not Crash, Kouen LSP Hover Returns Result, Kouen LSP Start Returns JSON, Kouen View Binary Shows Guard Message, Kouen View Prints File Content

### Community 495 - "ccRuns"
Cohesion: 0.38
Nodes (4): AnyObject, TimeInterval, ZombieHoldRegistry, ObjectIdentifier

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.18
Nodes (11): Typography, .badge, .kbd, .paletteHeader, .paletteTitle, .rowMeta, .rowTitle, .sectionLabel (+3 more)

### Community 498 - ".automationList"
Cohesion: 0.19
Nodes (11): SettingsAdvancedView, .body, Bool, String, KeyRecorderRepresentable, SettingsKeysView, .body, String (+3 more)

### Community 499 - ".routingRuleList"
Cohesion: 0.18
Nodes (10): Process, SSHTunnelError, .description, exitedEarly, launchFailed, notReady, Int32, TimeInterval (+2 more)

### Community 500 - ".json"
Cohesion: 0.29
Nodes (3): SessionStore, DispatchWorkItem, TimeInterval

### Community 501 - "Fixed"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 502 - "ACP Client (Shelved)"
Cohesion: 0.29
Nodes (4): AgentLaunchCommands, AgentKind, ClaudeSessionMode, Result

### Community 506 - "SwarmFleetBody"
Cohesion: 0.45
Nodes (3): data, SixelDecoder, UInt8

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.40
Nodes (4): Leak A - Retiring A Host Drops Its AI Controllers, Leak B - Browser Network Capture Is Bounded, Leak C - Every Per-Surface Dict In Coordinator Has Retire Cleanup, Leak D - Every Per-Surface Dict In NotificationCoordinator Is Snapshot-Swept

### Community 508 - "SessionStore"
Cohesion: 0.18
Nodes (7): ReleaseNotes, Section, String, ReleaseNotesGuardTests, .changelog, String, .sampleNotes

### Community 509 - "start.mjs"
Cohesion: 0.70
Nodes (4): main(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 510 - "PromptQueue"
Cohesion: 0.18
Nodes (10): Architecture Decisions (dated log), Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Post-P50 changes (v4.20.2 → v4.20.11, 2026-10-01 → 2026-10-06), Product Identity Guardrail: Terminal, Not IDE, Shipped capability summary, P44–P49 (2026-08-31 → 2026-09-23) (+2 more)

### Community 511 - ".panePathLookup"
Cohesion: 0.13
Nodes (14): CodingKey, CodingKeys, description, key, showInBanner, CodingKeys, createdAt, cwd (+6 more)

### Community 512 - "Changelog Archive"
Cohesion: 0.27
Nodes (8): LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab, TabID, WorkspaceID

### Community 513 - "ThemeDocument"
Cohesion: 0.13
Nodes (12): URL, VersionBannerStore, MobileBridgeSpawnTests, String, URL, skipUnlessLiveDaemonTests(), Bool, Set (+4 more)

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.27
Nodes (7): Never, Set, String, Task, URL, Void, WorkspaceSymbolIndex

### Community 517 - ".testManyConcurrentSubscribersAllReceiveOutput"
Cohesion: 0.33
Nodes (4): Run, String, TerminalBanner, WelcomeConfig

### Community 519 - ".gestureRecognizer"
Cohesion: 0.18
Nodes (6): eKe(), irn(), mrn, _rn(), rrn(), srn()

### Community 520 - "WriteOutcome"
Cohesion: 0.20
Nodes (13): ern(), G4(), G7(), Jnn(), nrn(), Qnn(), sHe(), trn() (+5 more)

### Community 521 - "FileTreeKeyboardNavigator"
Cohesion: 0.20
Nodes (5): invalidConfiguration, String, RemoteHostStoreTests, String, URL

### Community 522 - "ShellCompletionInstallerTests"
Cohesion: 0.13
Nodes (11): String, String, Set, KouenFilePreviewLoader, KouenViewError, binaryOrUnsupportedEncoding, missingPath, tooLarge (+3 more)

### Community 523 - ".encode"
Cohesion: 0.22
Nodes (4): JSONDecoder, JSONEncoder, Encoder, TerminalRecordingCodec

### Community 524 - "RealPtyLifecycleTests"
Cohesion: 0.22
Nodes (11): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, PaletteFooter, .body (+3 more)

### Community 525 - "TabContextCommand"
Cohesion: 0.29
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

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
Cohesion: 0.29
Nodes (8): FormatColor, none, palette, rgb, StyledSegment, Bool, String, UInt8

### Community 534 - ".sessionID"
Cohesion: 0.24
Nodes (4): GroupedSessionDaemonTests, SessionGroup, String, URL

### Community 535 - "AgentNotification"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 537 - "NSObject"
Cohesion: 0.11
Nodes (10): ClaudeAdapter, UUID, HeadlessCLIAdapter, HeadlessRunEvent, assistantText, result, sessionID, Bool (+2 more)

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.06
Nodes (32): MainActor, Void, SessionDividerRowView, .init(coder:), .init(frame:), SessionGroupHeaderRowView, .init(coder:), .init(frame:) (+24 more)

### Community 539 - "install-app.sh"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 540 - ".taskUpdate"
Cohesion: 0.25
Nodes (6): Kind, input, metadata, output, resize, ReplayStep

### Community 544 - "CodingKeys"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 546 - "LegacySnapshot"
Cohesion: 0.18
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 547 - "NSObject"
Cohesion: 0.14
Nodes (16): Any, ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool (+8 more)

### Community 553 - "harness.resource"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 554 - "FileTreeKeyboardNavigator"
Cohesion: 0.25
Nodes (8): CodingKeys, cols, createdAt, dataBase64, rows, timeMs, type, version

### Community 556 - "BrowserTab"
Cohesion: 0.19
Nodes (11): RecordingEvent, input, metadata, output, resize, .timeMs, Date, Decoder (+3 more)

### Community 557 - ".viewWillMove"
Cohesion: 0.47
Nodes (3): URL, TimeoutError, WorktreeLargeOutputRegressionTests

### Community 558 - ".sendInput"
Cohesion: 0.16
Nodes (11): PaneLayoutShape, branch, leaf, PaneNode, .paneLayoutShape, SavedLayout, Date, Double (+3 more)

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 560 - "LayoutTemplate"
Cohesion: 0.05
Nodes (16): KouenDaemonCore, tab, .tab(for:), DaemonBrowserRoutingTests, IPCCodecInvariantTests, String, URL, FormatContextDaemonTests (+8 more)

### Community 562 - "BrowserResponsePayload"
Cohesion: 0.40
Nodes (4): Build, Release & Git Workflow, Build / Test / Run, Release packaging order, Worktree constraint

### Community 563 - "AgentNotchViewModel.swift"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

### Community 565 - "ReleaseNotesGuardTests"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 568 - ".gestureRecognizer"
Cohesion: 0.19
Nodes (9): NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView, .cornerConfiguration (+1 more)

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.26
Nodes (5): Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.08
Nodes (27): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+19 more)

### Community 571 - "ShellIntegrationTests"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 572 - "LayoutProbeView"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 575 - ".toastErrorSummary"
Cohesion: 0.09
Nodes (21): clamp(), statusHelp(), Configuration, Date, Never, SplitDirection, String, T (+13 more)

### Community 576 - "Phase67Tests"
Cohesion: 0.22
Nodes (5): RepoResolver, Bool, String, RepoResolverTests, String

### Community 578 - "TaskDashboardBody"
Cohesion: 0.47
Nodes (5): AgentIconArt, AgentVectorIcon, Bool, CGSize, String

### Community 579 - "RunState"
Cohesion: 0.25
Nodes (6): String, URL, ThemeCatalogEmbedTests, .embedSwift, .repoRoot, .sourceJSON

### Community 580 - "ViInputMode"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 582 - "FileTreeKeyboardNavigator"
Cohesion: 0.15
Nodes (14): SettingsTerminalView, .body, .experienceSection, .fontReadout, .fontSection, .shellSection, Bool, String (+6 more)

### Community 583 - "WorkbenchMRU"
Cohesion: 0.15
Nodes (15): CryptoKit, Network, DecodedWSFrame, MobileBridgeServer, Bool, ConnectionState, NWConnection, Sendable (+7 more)

### Community 584 - "GUt"
Cohesion: 0.31
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 585 - "TargetSpec.swift"
Cohesion: 0.15
Nodes (4): SessionID, KouenCommands, GitPanelViewWorktreeTaskTests, TaskStatusMappingTests

### Community 586 - ".consumeInputCore"
Cohesion: 0.36
Nodes (4): OcclusionTests, NSWindow, String, TimeInterval

### Community 587 - "BrowserResponsePayload"
Cohesion: 0.12
Nodes (16): Command, .targetKind, PaneRef, bottom, byID, byIndex, last, left (+8 more)

### Community 589 - "Endpoint"
Cohesion: 0.33
Nodes (4): GridCompositorCopyModeTests, PaneRect, String, TerminalGridSnapshot

### Community 591 - "FormatContextDaemonTests"
Cohesion: 0.12
Nodes (17): BrowserRequestPayload, close, cookies, evaluate, goBack, goForward, interact, navigate (+9 more)

### Community 592 - "commit-push.sh"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Kouen-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 593 - "dO"
Cohesion: 0.50
Nodes (4): dO(), m8(), rfn(), zfn()

### Community 594 - "r2"
Cohesion: 0.67
Nodes (4): FVe(), hJ(), qVe(), Zme()

### Community 596 - ".feed(_:)"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 597 - "TerminalColorRole"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 599 - ".terminalHostIfExists"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 600 - ".groupByRoot"
Cohesion: 0.18
Nodes (8): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController

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
Cohesion: 0.08
Nodes (29): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, .body, PaletteMode (+21 more)

### Community 610 - ".installCLI"
Cohesion: 0.31
Nodes (5): SpecialKeyMappingTests, Bool, NSEvent, String, UInt16

### Community 613 - "INDEX.md"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 614 - "MainSplitViewController"
Cohesion: 0.07
Nodes (25): CGFloat, DisplayLinkTarget, MainSplitViewController, .setSidebarVisible(_:), .setSidebarVisible(_:animated:), SplitChromeDelegate, .sidebarMaxWidth, .sidebarMinWidth (+17 more)

### Community 617 - "ScriptFileWatcher"
Cohesion: 0.08
Nodes (29): BrowserLeaf, CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf (+21 more)

### Community 622 - "[1.3.0-vit] - 2026-06-06"
Cohesion: 0.18
Nodes (5): ClaudeCodeHarness, .hasAdapter(for:), Bool, UUID, ClaudeCodeHarnessTests

### Community 623 - "BrowserResponsePayload"
Cohesion: 0.20
Nodes (7): SavedLayoutStore, Bool, String, URL, UUID, SavedLayoutStoreTests, URL

### Community 624 - "[2.5.0] - 2026-06-12"
Cohesion: 0.20
Nodes (8): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, ClosedRange, String

### Community 627 - "ActiveTabCloseDisposition"
Cohesion: 0.33
Nodes (4): OutputTrigger, OutputTriggerStore, Bool, String

### Community 628 - "ReplayStep"
Cohesion: 0.18
Nodes (4): PortableRelativeDateFormatter, Date, String, UUID

### Community 629 - "graphify reference: query, path, explain"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 637 - "ClientSummary"
Cohesion: 0.10
Nodes (17): NSWindow, Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent, NSPoint (+9 more)

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

### Community 662 - "New Tab"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 664 - "P37 Phase G — Autocomplete (mobile bridge)"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 666 - "BrowserIntegrationController"
Cohesion: 0.17
Nodes (9): GitStatusProvider, OnceResume, Bool, Duration, String, TimeInterval, GitStatusProviderLargeOutputTests, URL (+1 more)

### Community 669 - "PaneLabelDaemonTests"
Cohesion: 0.26
Nodes (4): PaneLabelDaemonTests, String, URL, UUID

### Community 671 - "WorkspaceSwitcherRow"
Cohesion: 0.18
Nodes (9): Bool, NSCoder, NSEvent, NSTrackingArea, .init(coder:), WorkspaceSwitcherRow, .init(coder:), .init(title:count:isActive:symbol:canDelete:) (+1 more)

### Community 675 - ".detect"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 677 - "WriteOutcome"
Cohesion: 0.43
Nodes (7): Close Tab, New Tab, Cmd Shift W Force Closes Tab, Cmd T Creates New Session, Cmd W Closes Tab When Single Pane, Window Survives Full Shortcut Sequence, Zombie Crash Close Tab While Typing

### Community 678 - "FormatColor"
Cohesion: 0.20
Nodes (10): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+2 more)

### Community 679 - "TransportError"
Cohesion: 0.16
Nodes (8): LSPTransport, LSPTransportBuffer, String, TransportError, invalidContentLength, invalidUTF8Header, malformedHeader, missingContentLength

### Community 680 - ".recordReapedGenerationForTesting"
Cohesion: 0.39
Nodes (5): AutomationSummary, Bool, Date, String, UUID

### Community 681 - ".tabIDsToNotify"
Cohesion: 0.17
Nodes (11): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile, regionEdit (+3 more)

### Community 682 - ".update"
Cohesion: 0.33
Nodes (6): Board and attention, Errors and LSP, File navigation, Search, Task runner, Workbench commands (IDE-like workflow)

### Community 683 - ".load"
Cohesion: 0.14
Nodes (8): PluginLoader, String, ScriptAPI, ScriptError, .errorDescription, evaluationError, unsupportedPlatform, JavaScriptCore

### Community 684 - "New Tab"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 687 - "FormatStringExtendedVariableTests"
Cohesion: 0.31
Nodes (6): Bool, Counter, Scheduled, SurfaceProgressTrackerTests, DispatchWorkItem, TimeInterval

### Community 688 - "LayoutProbeView"
Cohesion: 0.36
Nodes (3): KouenSplitViewTests, LayoutProbeView, CGFloat

### Community 690 - ".update"
Cohesion: 0.40
Nodes (5): Additional `kouen-cli` subcommands, Agents, context and scratchpad, Daemon and diagnostics, Editor, LSP and setup, Sessions, tabs and recording

### Community 692 - ".control"
Cohesion: 0.10
Nodes (14): MTLLibrary, MTLRenderCommandEncoder, MTLRenderPipelineState, ImageTextureCache, MTLDevice, MTLTexture, Set, UInt8 (+6 more)

### Community 694 - "zGe"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 696 - "TerminalTabBarDelegate"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 700 - "CLICommand"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 702 - "PromptQueue"
Cohesion: 0.23
Nodes (4): PromptQueue, String, SurfaceID, Void

### Community 703 - "ColorKind"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 704 - ".taskUpdate"
Cohesion: 0.40
Nodes (5): ColorKind, .base, bg, fg, underline

### Community 709 - "String"
Cohesion: 0.31
Nodes (5): AgyAdapter, Result, ResultLine, String, UUID

### Community 710 - "MainWindowController"
Cohesion: 0.09
Nodes (15): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+7 more)

### Community 713 - "AutomationScheduler"
Cohesion: 0.28
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 714 - ".daemonIsStale"
Cohesion: 0.67
Nodes (3): Inspection (CLI / control mode), Local diagnostics, Sessions / workspaces

### Community 715 - "TerminalProgressReport"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 719 - "ViInputMode"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 721 - "HGe"
Cohesion: 0.12
Nodes (10): MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, String, SurfaceID (+2 more)

### Community 722 - ".configureEnvironment"
Cohesion: 0.09
Nodes (9): SessionEditor, .surfaceID(forPaneID:), Command, AgentSessionSummaryTests, SessionEditorPhase4Tests, PaneID, TabID, WorkspaceID (+1 more)

### Community 723 - "Color"
Cohesion: 0.19
Nodes (10): Color, .hexString, PickerItemRow, .badgeText, .body, .iconName, .subtitle, .titleText (+2 more)

### Community 724 - ".setMarkedText"
Cohesion: 0.21
Nodes (5): NSRangePointer, Any, NSAttributedString, NSRange, NSRect

### Community 726 - "String"
Cohesion: 0.15
Nodes (3): AgentHookInstallerCLI, String, String

### Community 727 - "PromptQueueBar"
Cohesion: 0.12
Nodes (15): agy, claude, codex, copilot, hermes, kouen, __kouen_agy_next, __kouen_claude_next (+7 more)

### Community 728 - "TerminalHostView"
Cohesion: 0.18
Nodes (5): .snapshot, Bool, String, ThemeService, KouenOptions

### Community 729 - "Lf"
Cohesion: 0.19
Nodes (8): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow, NSImage, NSHostingController

### Community 730 - "TerminalProgressReport"
Cohesion: 0.20
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

### Community 731 - "Phase6KeysTests"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: SSETransport auth token isRunning

### Community 732 - "ReplayStep"
Cohesion: 0.50
Nodes (3): SplitDirection, horizontal, vertical

### Community 733 - "ThaiGrid"
Cohesion: 0.31
Nodes (6): TerminalGridCell, ThaiClusterCopyTests, ThaiGrid, .columns, .totalLines, .viewportRows

### Community 734 - "b1t"
Cohesion: 0.21
Nodes (7): Bool, NSObjectProtocol, Set, String, Tab, TabID, WorktreeAutoIsolateService

### Community 735 - "companion.test.mjs"
Cohesion: 0.25
Nodes (6): block, lineFilter, md, page, script, swift

### Community 736 - "graphify reference: add a URL and watch a folder"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 737 - ".resolve"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 741 - "BlockTintOverlay"
Cohesion: 0.20
Nodes (9): BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool, CGFloat, NSCoder, NSPoint (+1 more)

### Community 743 - "DiagnosticCheck"
Cohesion: 0.24
Nodes (9): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+1 more)

### Community 744 - "FileTabManager"
Cohesion: 0.35
Nodes (7): FileTab, .title, FileTabManager, .hasOpenTabs, Bool, FileTabID, String

### Community 745 - "p11_scripting.robot"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 746 - ".findSession"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 750 - "ClipboardOSCTests"
Cohesion: 0.23
Nodes (13): kouen.bash script, agy(), claude(), codex(), copilot(), hermes(), kouen(), __kouen_agy_next() (+5 more)

### Community 754 - "FileTreeKeyboardNavigator"
Cohesion: 0.25
Nodes (7): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, NSEvent

### Community 755 - "HintModeOverlay"
Cohesion: 0.31
Nodes (4): HintModeOverlay, Any, NSEvent, String

### Community 756 - "TabContextCommand"
Cohesion: 0.31
Nodes (5): Lexer, .atEnd, .peek, Bool, Character

### Community 759 - "SpecialKey"
Cohesion: 0.53
Nodes (3): ProjectConfig, Bool, String

### Community 762 - ".main"
Cohesion: 0.48
Nodes (3): KouenMCPServer, Bool, String

### Community 763 - "ResumeStyle"
Cohesion: 0.29
Nodes (9): AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand, Bool, Set (+1 more)

### Community 768 - ".tabIDsToNotify"
Cohesion: 0.05
Nodes (50): aat(), AS(), bvt(), c5n(), cc(), d2(), d6(), dce() (+42 more)

### Community 782 - "inlineTokens"
Cohesion: 0.29
Nodes (7): AnimatablePair, NotchShape, .animatableData, CGFloat, CGPath, CGRect, Path

### Community 784 - "LayoutTemplate"
Cohesion: 0.20
Nodes (6): LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled

### Community 800 - ".groupedByRepo"
Cohesion: 0.40
Nodes (5): WrapperOptionBehavior, keepScanning, matchValue, skipValue, stopScanning

### Community 803 - ".splitActivePane"
Cohesion: 0.31
Nodes (4): SessionID, SplitDirection, String, WorkspaceID

### Community 820 - "Fixed"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 823 - ".antigravityTurn"
Cohesion: 0.22
Nodes (3): Any, AntigravityTranscriptTurnsTests, ClaudeHumanTextTests

### Community 834 - "Fixed"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 863 - "main.swift"
Cohesion: 0.31
Nodes (8): daemonLog(), detectStaleInstance(), installSignalHandlers(), removeForeignPIDFile(), removePIDFile(), Sendable, String, writePIDFile()

### Community 873 - "Added"
Cohesion: 0.24
Nodes (5): AgentBadgeView, .body, Bool, CGFloat, KouenIPC

### Community 897 - "CodingKeys"
Cohesion: 0.40
Nodes (5): CodingKeys, excludedPaths, id, name, sourceFolder

### Community 915 - "AgentBrowserPaneTracker"
Cohesion: 0.39
Nodes (3): AgentBrowserPaneTracker, Set, AgentBrowserPaneTrackerTests

### Community 953 - "Added"
Cohesion: 0.32
Nodes (4): PaneID, SessionGroup, Tab, first

### Community 954 - "ProjectStoreSyncTests"
Cohesion: 0.25
Nodes (4): ProjectStoreSyncTests, .tempPath, String, URL

### Community 978 - "Changed"
Cohesion: 0.13
Nodes (10): JSONOutputFormatter, Bool, String, T, HookEntry, OptionEntry, UUID, WorkspaceSummary (+2 more)

### Community 979 - "qLt"
Cohesion: 0.29
Nodes (4): _c(), Nn(), Pqe, qp()

### Community 987 - "DisplayWidth"
Cohesion: 0.33
Nodes (3): DisplayWidth, String, Unicode

### Community 991 - "Changed"
Cohesion: 0.22
Nodes (8): Build order (unchanged from interview decision), G1 — @ file-path picker, G2 — shell tab-completion suggestion strip (heuristic, explicitly best-effort), G3 — AI command suggestion (via `claude` CLI subprocess), Logical Design, P37 Phase G — Autocomplete (mobile bridge), Strategic Design, Tactical Design

### Community 998 - "DaemonClientError"
Cohesion: 0.32
Nodes (8): bX(), dbt(), gSn(), k8n(), Km(), o7e(), q1t(), vTn()

### Community 1000 - "Changed"
Cohesion: 0.22
Nodes (8): Artifacts, Client Application — Slice 1 (stacked panes, no persistence), Client Application — Slice 2 (per-workspace divider memory), Context, Dev Task Progress — Workspace Sidebar Panels (P42), Integration, Note on task re-sequencing (2026-07-17), Summary

### Community 1001 - ".feed(_:)"
Cohesion: 0.29
Nodes (6): .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8

### Community 1007 - "SpecialKey"
Cohesion: 0.60
Nodes (3): .encode(_:modifiers:event:modes:), SpecialKey, insert

### Community 1014 - "_Ue"
Cohesion: 0.33
Nodes (6): h1t(), hae(), jgn(), pwn(), sfn(), _Ue()

### Community 1015 - "Modifiers"
Cohesion: 0.25
Nodes (5): Bool, NSEvent, ViInputMode, insert, normal

### Community 1017 - "zUe"
Cohesion: 0.60
Nodes (5): dhn(), fhn(), ghn(), soe(), zUe()

### Community 1051 - "SS"
Cohesion: 0.50
Nodes (4): kte(), SS(), vte(), yte()

### Community 1081 - "MatchSource"
Cohesion: 0.67
Nodes (3): MatchSource, ownProcess, wrapperLaunch

### Community 1110 - "WriteOrigin"
Cohesion: 0.67
Nodes (3): WriteOrigin, automation, human

### Community 1193 - "WorkspaceID"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

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

### Community 1924 - "Added"
Cohesion: 0.05
Nodes (72): pe(), X(), _1n(), a1t(), ae(), ajt(), b8(), bat() (+64 more)

### Community 1930 - "AsyncCLIResultBox"
Cohesion: 0.67
Nodes (3): AsyncCLIResultBox, Error, Result

### Community 1977 - "Added"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: ProjectCategory FolderScanner ProjectDirectoryTree, Source Nodes

### Community 1983 - "CopilotAdapter"
Cohesion: 0.14
Nodes (9): AgentDetection, AgentDetector, RawMatch, Date, Int32, TimeInterval, ProcessScan, Int32 (+1 more)

### Community 2014 - "Added"
Cohesion: 0.36
Nodes (7): Document, Bool, Set, String, URL, ToolPolicy, .defaultURL

### Community 2100 - ".handleWake"
Cohesion: 0.12
Nodes (19): .exit, DaemonClient, String, String, KouenCLI, SessionID, String, Bool (+11 more)

### Community 2176 - "Changed"
Cohesion: 0.29
Nodes (6): Locked decisions (user-confirmed), Logical Design, P38 Phase A — Cross-Agent Worktree Diff/Review Dashboard — Design, Strategic Design, Tactical Design, Verification gate (this phase)

### Community 2242 - "P42 — Workspace Sidebar Panels"
Cohesion: 0.29
Nodes (6): Logical Design, Next Step, P42 — Workspace Sidebar Panels, Parked (not in scope), Strategic Design, Tactical Design

### Community 2269 - "WriteOutcome"
Cohesion: 0.11
Nodes (15): Error, InstallError, unsupported, DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse (+7 more)

### Community 2363 - "Fixed"
Cohesion: 0.27
Nodes (3): DaemonReconnectPolicy, TimeInterval, DaemonReconnectPolicyTests

### Community 2541 - "P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable"
Cohesion: 0.17
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 2573 - "P38 Phase D — Kitty Graphics Conformance Slice"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase D — Kitty Graphics Conformance Slice, Scope (locked), Tests

### Community 2633 - "P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua)"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua), Scope (locked), Tests

### Community 2642 - "P43 — Add Repo/Folder to Workspace"
Cohesion: 0.33
Nodes (5): Logical Design, Next Step, P43 — Add Repo/Folder to Workspace, Strategic Design, Tactical Design

### Community 3131 - "P38 Phase D — Kitty Conformance — Dev Task Progress"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 3132 - "P38 Phase E — Scripting Hooks — Dev Task Progress"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 3880 - "crn"
Cohesion: 0.36
Nodes (3): crn, ELt(), n2e()

### Community 3896 - "Components.swift"
Cohesion: 0.06
Nodes (35): ButtonStyle, CommandRow, .body, GlassCard, .body, GlassPrimaryButtonStyle, GlassSecondaryButtonStyle, GlassSmallButtonStyle (+27 more)

## Knowledge Gaps
- **3348 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+3343 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **2257 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `.normalizedKey` to `Changelog Archive`, `graphify reference: extra exports and benchmark`, `.handleNormal`, `EngineConformanceTests`, `.testManyConcurrentSubscribersAllReceiveOutput`, `IPCRequest`, `AgentNotchRootView`, `LSPMessage`, `.jumpToBlock`, `PerformanceBenchmarks`, `ShellCompletionInstallerTests`, `RealPtyLifecycleTests`, `TabContextCommand`, `VTParser`, `HarnessTerminalSurfaceView`, `.applyPreedit`, `.init`, `HarnessChrome`, `SpecialKey`, `HarnessUILibrary`, `.readGrid(scrollbackOffset:)`, `WorktreeManager`, `SessionGroupHeaderRowView`, `RGBColor`, `.taskUpdate`, `.init`, `Sendable`, `.addTab`, `Equatable`, `.bufferLine`, `MenuTarget`, `.characterIndex`, `CodingKeys`, `TerminalColorGamut`, `CodingKeys`, `HarnessSidebarPanelViewController.swift`, `RenderSchedulerTests`, `BrowserTab`, `.viewWillMove`, `.keyEvent`, `ReleaseNotesGuardTests`, `TabCell`, `KouenOverlayBackground`, `CommandHistorySearchController`, `3.2 สิ่งที่ implement แล้ว`, `ShellIntegrationTests`, `FrecencyDirectoryStore`, `PasteBufferStore`, `.toastErrorSummary`, `HarnessCLI+Server.swift`, `Completed Plans Archive`, `worktree_isolation_cli.robot`, `WorkbenchMRU`, `BrowserResponsePayload`, `.parse`, `Endpoint`, `HarnessDesign`, `.firstMatch`, `LSPDiagnostic`, `TerminalGridCell`, `HarnessPaths`, `TerminalModes`, `AttachInputBatcher`, `shim.c`, `FormatContextDaemonTests`, `PaneContainerView`, `.dispatch`, `ScriptRuntime.swift`, `Session Grouping and Split Session Plan`, `MainSplitViewController`, `DaemonLauncher`, `Recipe`, `4. Technical Architecture`, `domain-design.md`, `AgentNotchViewModel`, `AnyCodable`, `DamageTrackingTests`, `SoftIconButton`, `code:text (:workbench start swift)`, `[2.5.0] - 2026-06-12`, `.firstWaitingTab`, `WorkspaceFileTreeView`, `Pipe`, `HistoryRingBuffer`, `ClientSummary`, `GlyphAtlas`, `code:block1 (SessionCoordinator.snapshot ──┐)`, `SwiftUI`, `AgentHookInstaller`, `CommandTarget`, `.startWatching`, `PtyDrainCeilingBenchmark`, `PaneStyleSet`, `AsciiFastPathTests`, `DecodedImage`, `FileTreeWatcher`, `LiveResizeTests`, `Int`, `ThaiCombiningMarkTests`, `Added`, `Harness Terminal — IDE Sidebar Feature Branch`, `MatchCategory`, `WorkspaceSwitcherRow`, `What You Must Do When Invoked`, `TerminalFindBar`, `CommandPromptController`, `ActiveTabCloseDisposition`, `FormatColor`, `AgentTableEntry`, `.recordReapedGenerationForTesting`, `TransportError`, `URLDetection`, `.decodeKeySpec`, `[1.5.1] - 2026-06-06`, `BinaryRefresherTests`, `FormatStringExtendedVariableTests`, `InlineAICompletionView`, `[3.13.1] - 2026-07-02`, `.control`, `GridCompositorTests`, `LSPServerRegistry`, `SessionSnapshot`, `AppDelegate`, `PromptQueue`, `user-stories.md`, `.taskUpdate`, `GlyphRasterizer`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `ResizeHUDView`, `BinaryInstaller`, `AgentSessionSummary`, `.classify`, `[3.9.5] - 2026-06-26`, `scheduleRender`, `.testDataFrameEncodeVsJSONBase64Output`, `ViInputMode`, `.configureEnvironment`, `PaneTarget`, `.lines`, `GridCompositor`, `ScrollbackFile`, `Prompt`, `TerminalProgressReport`, `WriteOutcome`, `ThaiGrid`, `SSHTunnelManagerTests`, `BlockTintOverlay`, `ExternalOpenKind`, `.scan`, `PaneBorderStatus`, `[3.5.1] - 2026-06-20`, `AgentBridge`, `.make`, `FileNode`, `FileTreeKeyboardNavigator`, `HintModeOverlay`, `TabContextCommand`, `ThemeDocumentTests`, `ReflowPreviewTests`, `Split Right`, `release-hotfix.sh`, `workspace`, `WindowTitleStripView`, `.install`, `HarnessSidebarPanelViewController`, `.path`, `DefaultTerminalManager`, `WindowSession`, `KeySpec`, `[2.5.0] - 2026-06-12`, `SyntaxTextView`, `DisplayPanesOverlay`, `.menu`, `FormatColor`, `click_ui_element`, `After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md.`, `code:bash (harness-cli install-hooks hermes)`, `.daemonIsStale`, `AgentHookStrategy`, `StatusLineWidthTests`, `Process`, `JSONDecoder`, `Fixes Applied (layered)`, `GitHubCLIClient`, `NotificationBus`, `settings.json`, `PaneNode`, `HarnessPaths.swift`, `Send Ex Command`, `Fixed`, `Bug: Tab-Switch Black Screen`, `AgentSnapshot`, `Terminal AI Chat (⌘I inline overlay)`, `Fixed`, `UInt64`, `DesktopNotifier`, `LayoutNode`, `WorkspaceSymbolIndex`, `Fixed`, `worktree_isolation.robot`, `.theme`, `README.md`, `.drawGlyph`, `Added`, `ImageProtocolTests.swift`, `CommandExecutionError`, `CSIParams`, `Foundation`, `Contents.json`, `Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)`, `GPU Animation Pattern — Layout Once, GPU Paints`, `P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)`, `.encodeAndWait`, `SurfaceProgressTracker`, `.handleCat`, `State`, `FormatStyledSegment.swift`, `generate-cheatsheet.js`, `Consumers`, `Tab`, `.run`, `PromptQueueBar`, `ScrollReuseTests`, `SurfaceProgressTrackerTests.swift`, `NSTextField Leak in BoardViewController (P20 Performance)`, `User Profile`, `Darwin`, `HarnessCLITests`, `UI Automation — Robot Framework (P18)`, `AsyncCLIResultBox`, `.init`, `PresentAttempt`, `Split Panes (NSSplitView)`, `.tabIndex(tabID:)`, `main.swift`, `AgentIconRenderer`, `IPC Architecture`, `Session/Tab/Pane Hierarchy & Top Bar (CASE-028)`, `.setCellPixelSize`, `Fixed`, `javascript.json`, `json.json`, `rust.json`, `RealPtyLifecycleTests`, `HintModeOverlay`, `SixelDecoder`, `.currentSize`, `AgentVectorIcon`, `.navigateCurrentFile`, `TaskDashboardView`, `Case: cwd "bleed" — session worktree jumps to wrong dir during builds`, `Competitive Position (as of v3.12.0, 2026-07-02)`, `BoardCardView`, `PathToken`, `SessionEditor`, `Added`, `CopilotAdapter`, `tmux parity — status, adaptations, and deliberate divergences`, `.recordReapedGenerationForTesting`, `.deletePersistedScrollback`, `.encode`, `.init`, `Changed`, `.resize`, `HarnessOnboarding`, `DisplayWidth`, `.hitTest`, `.endFind`, `Added`, `Command Prompt Architecture`, `.testKouenRendererFixtureDefaultTextReportsPlausibleGlyphStats`, `.feed(_:)`, `.bind`, `SwarmFleetBody`?**
  _High betweenness centrality (0.251) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `Terminal AI Chat (⌘I inline overlay)` to `Equatable`, `WindowTitleStripView`, `AgentSessionSummary.swift`, `IPCRequest`, `worktree_isolation_cli.robot`, `.agentName`, `Changelog`, `.id`, `LSPMessage`, `Consumers`, `.normalizedKey`, `HarnessDesign`, `.configureEnvironment`, `FileTreeWatcher`, `PaneNode`, `TerminalGridCell`, `ACP Client (Shelved)`?**
  _High betweenness centrality (0.198) - this node is a cross-community bridge._
- **Why does `fbt()` connect `HarnessSettings` to `.tabIDsToNotify`, `callingPaneTarget`, `Changelog`, `TriState`, `CopyModeAction`?**
  _High betweenness centrality (0.100) - this node is a cross-community bridge._
- **Are the 18 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `RenderScheduler`) actually correct?**
  _`KouenTerminalSurfaceView` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _3368 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.020835844886477797 - nodes in this community are weakly interconnected._
- **Should `Changed` be split into smaller, more focused modules?**
  _Cohesion score 0.04722222222222222 - nodes in this community are weakly interconnected._