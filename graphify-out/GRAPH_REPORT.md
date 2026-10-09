# Graph Report - kouen-terminal  (2026-10-09)

## Corpus Check
- 889 files · ~1,018,602 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 21410 nodes · 57140 edges · 3931 communities (1572 shown, 2359 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8402 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `5e0b62dd`
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
9. `KouenCLI` - 219 edges
10. `DaemonClient` - 212 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 188 areas (208 edges)
2. `Command` - bridges 101 areas (108 edges)
3. `KouenTerminalSurfaceView` - bridges 83 areas (345 edges)
4. `AgentKind` - bridges 82 areas (177 edges)
5. `t()` - bridges 80 areas (253 edges)
6. `IPCResponse` - bridges 77 areas (103 edges)
7. `SessionCoordinator` - bridges 69 areas (236 edges)
8. `KouenPaths` - bridges 69 areas (150 edges)
9. `KouenGridTerminal` - bridges 65 areas (117 edges)
10. `AnyCodable` - bridges 62 areas (190 edges)

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

## Communities (3931 total, 2359 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.11
Nodes (18): SavedLayoutStore, Bool, String, URL, UUID, PaneLayoutShape, branch, leaf (+10 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.02
Nodes (429): l, V, _4n(), _7n(), a1t(), a8n(), a_n(), aA() (+421 more)

### Community 2 - ".handleNormal"
Cohesion: 0.14
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 3 - "Changed"
Cohesion: 0.04
Nodes (60): _4e(), ag(), al(), b1t(), bdn(), bIn(), bj(), c4n() (+52 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.07
Nodes (15): ClaudeCodeHarnessIPCTests, String, URL, DaemonRoundTripTests, String, TimeInterval, URL, RealPtyLifecycleTests (+7 more)

### Community 5 - "IPCRequest"
Cohesion: 0.08
Nodes (20): Data, DecodedReplyFrame, output, reply, DecodedRequestFrame, input, request, FrameError (+12 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.07
Nodes (23): OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, .event(_:), .interval(_:_:), Bool (+15 more)

### Community 7 - "Command"
Cohesion: 0.09
Nodes (31): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+23 more)

### Community 8 - "LSPMessage"
Cohesion: 0.08
Nodes (35): DaemonSubscription, .start(onData:onEnd:buffered:), .start(onResponse:onEnd:), Bool, Int32, String, TimeInterval, UInt16 (+27 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.05
Nodes (46): CGImage, ImageIO, Int, data, DecodedImage, .byteCount, ImageLimits, Bool (+38 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.03
Nodes (65): _2t(), ase(), aTn(), aV(), bYe(), cce(), d0t(), d6n() (+57 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.10
Nodes (40): blockTokens(), br(), checkbox(), code(), codespan(), constructor(), de(), del() (+32 more)

### Community 14 - "VTParser"
Cohesion: 0.15
Nodes (9): StringKind, apc, dcs, UInt8, UnsafeBufferPointer, VTParser, .feed(_:), VTParserHandler (+1 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.06
Nodes (28): .tab(forSurfaceKey:), DaemonCommandExecutor, Command, .init(forTesting:), UUID, Void, BellScanState, esc (+20 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.07
Nodes (16): DisplayWidth, String, Unicode, ReleaseNotes, Section, String, Run, String (+8 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.08
Nodes (28): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, .body, PaletteMode (+20 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.09
Nodes (13): FlippedView, .isFlipped, .removeWorktreeAction(_:), NSButton, NSColor, NSRect, NSScrollView, NSStackView (+5 more)

### Community 19 - "SpecialKey"
Cohesion: 0.21
Nodes (15): CustomStringConvertible, atomicWrite(), backupCorruptFile(), ensureDirectories(), fnv1aHex(), KouenPathsError, .description, socketPathTooLong (+7 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.20
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.12
Nodes (14): NSView, OverlayBackground, Context, ChromeBackdrop, .init(role:), KouenDesign, KouenOverlayBackground, RuntimeGlassEffectView (+6 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.01
Nodes (591): _0t(), _1n(), _3e(), _3n(), _5e(), _5n(), _6e(), _6n() (+583 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.04
Nodes (56): aNt(), aOn(), AS(), bhn(), bvt(), cc(), cct(), d2() (+48 more)

### Community 24 - ".request"
Cohesion: 0.10
Nodes (13): UnsafeBufferPointer, TerminalCellWidth, UnsafeBufferPointer, .cursorVisible, CharacterWidth, Bool, ClosedRange, Unicode (+5 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.05
Nodes (36): .agentColorBinding, colors, TerminalGridCell, TerminalGridSnapshot, TerminalEmulator, .captureLines(joinWrapped:), .feed(_:), .promptRows (+28 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.17
Nodes (11): SettingsAdvancedView, .body, Bool, String, SliderRow, .body, .displayValue, ClosedRange (+3 more)

### Community 27 - "RGBColor"
Cohesion: 0.15
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 28 - ".parse"
Cohesion: 0.11
Nodes (11): NWEndpoint, DecodedWSFrame, MobileBridgeServer, Bool, NWListener, UInt16, UInt8, WSFrameParseResult (+3 more)

### Community 30 - "Notification"
Cohesion: 0.13
Nodes (3): KittyKeyboardTests, String, UInt8

### Community 31 - "Sendable"
Cohesion: 0.13
Nodes (13): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+5 more)

### Community 32 - ".addTab"
Cohesion: 0.07
Nodes (28): .body, FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body (+20 more)

### Community 33 - "Equatable"
Cohesion: 0.10
Nodes (18): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, PaneID (+10 more)

### Community 34 - "DaemonClient"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.14
Nodes (28): Cleanup Test Repo, Close Isolated Session Keeps Dirty Worktree, Close Isolated Session Removes Clean Worktree, Close One Isolated Does Not Affect Another, Close Session With Split Panes Removes Worktree, Create Isolated Session, Create Isolated Session Via CLI, Get Active Pane (+20 more)

### Community 37 - "String"
Cohesion: 0.08
Nodes (23): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSEvent (+15 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.26
Nodes (6): BrowserOkAck, ConnectionState, ErrorAck, NWConnection, T, UUID

### Community 40 - "HarnessSettings"
Cohesion: 0.21
Nodes (5): NSRangePointer, Any, NSAttributedString, NSRange, NSRect

### Community 41 - "CodingKeys"
Cohesion: 0.08
Nodes (27): ClientRecord, CountBox, DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed (+19 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.33
Nodes (6): invalidArgument, missingArgument, CommandParser, Command, Set, String

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.08
Nodes (17): SessionEditor, .addSurface(tabID:paneID:), .tab(containingPaneID:), .tabIndex(surfaceKey:), .tabIndex(workspaceID:tabID:), Bool, Date, SessionID (+9 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.14
Nodes (9): Process, SSHTunnelManager, .init(makeTunnelProcess:reachabilityProbe:), Bool, URL, Tunnel, SSHTunnelManagerTests, String (+1 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.11
Nodes (4): Bool, String, UInt8, .onSetClipboard

### Community 48 - "HookEvent"
Cohesion: 0.13
Nodes (14): Executor, Hook, HookEvent, HookRegistry, Bool, Command, URL, UUID (+6 more)

### Community 49 - "DaemonServer"
Cohesion: 0.16
Nodes (7): PasteController, Bool, NSPasteboard, String, TimeInterval, URL, PasteControllerTests

### Community 51 - ".keyEvent"
Cohesion: 0.11
Nodes (26): ColorKind, .base, bg, fg, underline, CompositorPane, GridCompositor, .render(panes:status:statusSegments:) (+18 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.18
Nodes (10): _c(), kse(), mP(), Nn(), pae(), Pqe, qp(), tSn() (+2 more)

### Community 55 - "TabCell"
Cohesion: 0.17
Nodes (7): AnyCodable, JSONRPCError, Bool, Int32, Pipe, String, ToolRegistry

### Community 56 - "NSPanel"
Cohesion: 0.23
Nodes (9): CGFloat, NSCoder, SessionID, Void, TaskDashboardView, .init(coder:), .init(onJumpToSession:), TaskRowView (+1 more)

### Community 57 - "BellScanState"
Cohesion: 0.13
Nodes (12): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+4 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.13
Nodes (28): MTLClearColor, MTLCommandBuffer, BgInstance, CursorCacheKey, .invertsGlyph, DecoInstance, EncodedFrameInstances, EncodedRowInstances (+20 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.07
Nodes (32): ArtifactKind, html, image, markdown, text, AutomationsFleetModel, .load(detectScheduledRuns:), AutomationSource (+24 more)

### Community 60 - "ViEngine"
Cohesion: 0.02
Nodes (344): pe(), r, X(), A(), a(), ae(), aen(), aHt() (+336 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.14
Nodes (20): ComposedCell, .asGridCell, .init(_:), .init(codepoint:fg:bg:underlineColor:bold:dim:italic:underline:blink:inverse:invisible:strikethrough:overline:), .scalar, .sgr, CompositorPane, GridCompositor (+12 more)

### Community 62 - "ComposedCell"
Cohesion: 0.07
Nodes (42): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, SwarmDAGStore, String, UUID, SwarmFleetSnapshot (+34 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 64 - ".text"
Cohesion: 0.05
Nodes (43): .init(entry:), AgentChipView, .init(coder:), .intrinsicContentSize, ChromeRole, sidebar, tabBar, Collection (+35 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.10
Nodes (26): PaneRef, bottom, byID, byIndex, last, left, next, previous (+18 more)

### Community 67 - "String"
Cohesion: 0.13
Nodes (14): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+6 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.05
Nodes (44): AgentBridge, AgentTarget, Bool, String, SurfaceID, .onCurrentCWD, .onCurrentFile, LinePos (+36 more)

### Community 69 - ".compose"
Cohesion: 0.12
Nodes (11): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, osc (+3 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.08
Nodes (39): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+31 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 72 - "XCTestCase"
Cohesion: 0.12
Nodes (38): Ame(), aQt(), cXt(), een(), eVe(), eXt(), gUe(), GYt() (+30 more)

### Community 73 - "README.md"
Cohesion: 0.50
Nodes (3): Hermes → Kouen, One-line install, Required: approve the hook

### Community 75 - "OptionStore"
Cohesion: 0.08
Nodes (25): 10. Universal retire-hold via `removeFromSuperview()` override (definitive), 11. NSEvent local monitor installed in AppDelegate (fix #8 actually deployed), 12. `nonisolated` + `MainActor.assumeIsolated` on high-frequency AppKit callbacks (2026-06-21), 1. `TerminalPaneRegistry.retire()` — deferred dealloc (500ms), 2. Remove `nonisolated` from all layout overrides, 3. Remove `MainActor.assumeIsolated` from callbacks, 4. Detach NSHostingView on teardown (FileTreeSwiftUIView), 5. Avoid `Optional.map {}` in @MainActor code (+17 more)

### Community 76 - ".parse"
Cohesion: 0.16
Nodes (10): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab, UUID (+2 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.10
Nodes (21): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, FileTreeContext, Bool (+13 more)

### Community 79 - "HarnessDesign"
Cohesion: 0.13
Nodes (13): MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem, SessionGroup (+5 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 82 - ".firstMatch"
Cohesion: 0.05
Nodes (22): NSCursor, KouenTerminalSurfaceView, .gridOriginPointsX, .gridOriginPointsY, .receive(_:), CGFloat, DispatchSemaphore, DispatchWorkItem (+14 more)

### Community 83 - "LSPClient"
Cohesion: 0.07
Nodes (33): b3e(), c6(), gce(), _gn(), h7e(), HKe(), hyn(), igt() (+25 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.11
Nodes (32): a7e(), b9n(), dU(), Eb(), Etn(), evn(), gae(), i0() (+24 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.07
Nodes (22): IndexingIterator, LayoutTemplate, surfaceID, .addSurface(to:paneID:surfaceID:cwd:), .split(node:targetPaneID:direction:paneCount:before:), .split(node:targetPaneID:with:direction:beforeTarget:), .surfaceID(forPaneID:), .surfaceID(forPaneID:in:) (+14 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.10
Nodes (15): String, WorkbenchMRU, FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect (+7 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.15
Nodes (14): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+6 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.09
Nodes (21): 2026-07-26 monthly refresh (last ~30 days only, 3 parallel research agents), Agent Swarm Core (P44 follow-on) — honest gap-check, 2026-09-14, AI-IDE landscape (adjacent category — editors, not terminals), Closed 2026-07-11 (P39 phases A–D — build/test green, live-hardware check still owed on each), Competitive Position (as of v4.10.0, 2026-08-06), Deep web research refresh (2026-07-11, 3 parallel research passes), Feature Matrix (2026-07-11), Feature Matrix — M2-M9 additions (2026-08-06) (+13 more)

### Community 89 - ".cursorPos"
Cohesion: 0.16
Nodes (4): hooks, AgentHookInstallerTests, String, URL

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.09
Nodes (12): pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal, Int32 (+4 more)

### Community 91 - "TerminalModes"
Cohesion: 0.09
Nodes (21): Agent Swarm Core — Fleet Orchestration (20–50 Agents), Context, Daemon: headless surface creation — CORRECTED during Slice 3 (2026-09-14), DAG signal for the Claude adapter specifically, Data model, Delta + coalesced push (not full-snapshot-per-status-change), Extended OSC 26 protocol (Lane B only) — Slice 3 implemented `identity=`/`status=` only, Lane A — Structured workers (Claude Code today, Codex/Agy/Copilot later): (+13 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.17
Nodes (5): .readAntigravitySummaries(dbPath:brainDir:ftsIndex:), SQLite3, AgentHistoryMultiAgentCoverageTests, String, URL

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.11
Nodes (12): .effectiveResumeCommand(claudeMode:), ClaudeSessionMode, ClaudeCloudSessionStore, Entry, Date, String, TimeInterval, URL (+4 more)

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
Cohesion: 0.05
Nodes (48): AgentBadgeView, .body, Bool, CGFloat, DiffPaneView, .body, AgentHistoryDateGroup, older (+40 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.09
Nodes (10): ScriptAPI, .windowSection, KouenSettings, .init(from:), Decoder, Double, Float, KouenSettingsTests (+2 more)

### Community 99 - ".dispatch"
Cohesion: 0.16
Nodes (12): FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID, KouenFeature (+4 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.10
Nodes (16): StatusLineView, .init(coder:), Bool, CGFloat, FormatColor, Never, NSAttributedString, NSCoder (+8 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.06
Nodes (42): AnyTransition, AnyView, AgentNotchPeekEvent, AgentNotchRootView, .body, .bottomRadius, .closedAccessibilityLabel, .closedTransition (+34 more)

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
Cohesion: 0.14
Nodes (10): ScrollbackFile, .highWater, Bool, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.10
Nodes (19): 1. Git Worktree Management, 2. Multi-Agent Orchestration, 3. Mobile Companion Sync, 4. Tech Stack, 5. Other Notable Design Decisions, Additional Takeaway, cmux (manaflow-ai/cmux, github.com/manaflow-ai/cmux) — open source (Swift/Rust, ELv2-style OSS), no shipped worktree lifecycle feature, Comparison Table (+11 more)

### Community 108 - ".resolve"
Cohesion: 0.08
Nodes (17): ConcurrentIndexSet, .count, DaemonContentionTests, SubscriptionBox, .count, String, URL, ShellLaunchProfileTests (+9 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.08
Nodes (20): SGRMouse, SGRMouseEvent, Bool, PaneRect, UInt8, MouseButton, left, middle (+12 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.18
Nodes (6): CopyModeReducerTests, FakeGrid, .totalLines, Set, String, TerminalGridCell

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.08
Nodes (12): HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor, Bool, ClosedRange, Range (+4 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.15
Nodes (14): FileNode, GitStatusType, added, deleted, modified, renamed, unmodified, untracked (+6 more)

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.08
Nodes (30): a0(), b6n(), bC(), clamp(), cte(), f8e(), formatHsl(), gkn() (+22 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.13
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 115 - ".encode"
Cohesion: 0.13
Nodes (16): AgentNotchRowSummary, RowKind, agent, session, Date, PaneID, SurfaceID, UUID (+8 more)

### Community 116 - "SessionGroup"
Cohesion: 0.20
Nodes (7): AgentRoutingRuleStore, Bool, String, URL, UUID, AgentRoutingRuleStoreTests, URL

### Community 117 - "PaneNode"
Cohesion: 0.11
Nodes (10): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+2 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.03
Nodes (66): amn(), azt(), B0, BBe(), cg(), ch(), cvt(), dV() (+58 more)

### Community 119 - "Harness command reference"
Cohesion: 0.14
Nodes (14): Agent safety CLI (`kouen-cli`), Attaching from a plain terminal, Bindings, Buffers (paste store), Composition, Hooks, Kouen command reference, Modes (+6 more)

### Community 122 - "ViEngine"
Cohesion: 0.08
Nodes (15): KouenCLITests, CLIInstallLocator, DetachKeys, absent, invalid, parsed, OptionalUUID, absent (+7 more)

### Community 123 - "Pipe"
Cohesion: 0.06
Nodes (41): .pairedAlreadyBanner, .pairingQRPanel, .body, .sidebarEmptyView, IssueKeychainStore, Bool, String, IssuePriority (+33 more)

### Community 124 - "String"
Cohesion: 0.10
Nodes (18): Array, PickerItemRow, .badgeText, .body, .iconName, .subtitle, .titleText, RecipePanel (+10 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, S (+2 more)

### Community 126 - ".path"
Cohesion: 0.08
Nodes (29): AgentArt, AgentMark, .body, AgentMarkShape, AgentVectorIcon, Scanner, .atEnd, SVGPath (+21 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.10
Nodes (24): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), .stats (+16 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.12
Nodes (17): Coordinator, DiffAnalysis, DiffFileItem, DiffFileStatus, added, .color, deleted, modified (+9 more)

### Community 129 - "SwiftUI"
Cohesion: 0.18
Nodes (4): FilePreviewCoordinator, FileTabID, SplitDirection, String

### Community 131 - ".install"
Cohesion: 0.24
Nodes (3): TabID, WorkspaceID, GitPanelViewWorktreeNavigationTests

### Community 132 - "AgentHookInstaller"
Cohesion: 0.15
Nodes (14): SettingsTerminalView, .body, .experienceSection, .fontReadout, .fontSection, .shellSection, Bool, String (+6 more)

### Community 133 - ".load"
Cohesion: 0.19
Nodes (29): aQ(), bqt(), cbe(), DD(), Eqt(), Fa(), gqt(), ize() (+21 more)

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.17
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 135 - "CommandTarget"
Cohesion: 0.06
Nodes (29): DiffLineType, added, deleted, modified, Notification.Name, ObserverToken, Bool, DispatchWorkItem (+21 more)

### Community 136 - ".startWatching"
Cohesion: 0.21
Nodes (4): CommandTarget, String, UUID, TargetSpecTests

### Community 137 - "ActivePaneService"
Cohesion: 0.11
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.13
Nodes (19): AgentIconArt, AgentVectorIcon, Bool, CGSize, String, AgentIconRenderer, Scanner, .atEnd (+11 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.11
Nodes (16): Error, CommandParseError, .description, emptyInput, expectedCommand, missingFlag, unknownCommand, unterminatedString (+8 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 146 - "DecodedImage"
Cohesion: 0.06
Nodes (24): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+16 more)

### Community 147 - "FileTreeWatcher"
Cohesion: 0.09
Nodes (9): .selectWorkspace(_:), Double, PaneID, SessionID, SplitDirection, SurfaceID, TabID, WorkspaceID (+1 more)

### Community 148 - "TriState"
Cohesion: 0.02
Nodes (260): a(), b(), c(), d(), e(), f(), g(), h() (+252 more)

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
Cohesion: 0.17
Nodes (11): CUe(), H7(), hqt(), kCn(), kUe(), LUe(), lXt(), Ome() (+3 more)

### Community 154 - "LiveResizeTests"
Cohesion: 0.12
Nodes (17): GroupHeaderRow, .body, PickerItem, .groupLabel, historyBlock, .id, recipe, .searchableText (+9 more)

### Community 155 - "Int"
Cohesion: 0.14
Nodes (11): FileFuzzyMatcher, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool, Character (+3 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.08
Nodes (24): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, .acceptsFirstResponder (+16 more)

### Community 157 - "Added"
Cohesion: 0.14
Nodes (13): GridCompositor, Configuration, Int32, SessionGroup, SessionID, Tab, TabID, WorkspaceID (+5 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 159 - "MatchCategory"
Cohesion: 0.05
Nodes (26): CornerInfo, EditorDividerView, HitTestPassthroughView, KouenSplitView, .dividerColor, .dividerThickness, .init(coder:), PaneDragGripView (+18 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.12
Nodes (21): FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose, FileTabPillView (+13 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.14
Nodes (11): PairingBox, .current, .isLockedOut, PendingPairing, Date, TimeInterval, TokenCheck, accepted (+3 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.07
Nodes (17): NSResponder, NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent (+9 more)

### Community 163 - "Workspace"
Cohesion: 0.08
Nodes (25): CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display, found, .isReady (+17 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.09
Nodes (23): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, IssueInfo (+15 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.17
Nodes (10): SSETransportTests, UInt16, SSETransport, .isRunning, .listener, Bool, NWConnection, NWListener (+2 more)

### Community 166 - "LiveSession"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.07
Nodes (47): .resolvedGitStatus, AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem (+39 more)

### Community 169 - "Fixed"
Cohesion: 0.12
Nodes (9): PaneID, SurfaceID, Tab, TabID, UUID, BrowserPaneReuseScopeTests, PaneNode, Tab (+1 more)

### Community 170 - "URLDetection"
Cohesion: 0.11
Nodes (7): Bool, Range, Set, String, URLDetection, StringProtocol, EngineConformanceTests

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.10
Nodes (16): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+8 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.06
Nodes (30): LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed, serverNotExecutable, FileHandle, Int32 (+22 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.11
Nodes (6): ISO8601DateFormatter, KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), SpawnedAgentSurface, String, UUID

### Community 175 - "RGBColorTests"
Cohesion: 0.20
Nodes (10): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, Bool (+2 more)

### Community 176 - "Added"
Cohesion: 0.11
Nodes (18): Architecture, Browser Auto-Retry (P24 Phase 4), Browser Pane (P14), BUG: Tab close button never fired (CASE-055 extended), BUG: Tab close button unresponsive (gesture conflict), CASE: applyLocalSnapshot re-injected closed browser panes (v2.7.1), CASE: collapsed errorBanner intercepted toolbar clicks (v2.7.1), CASE: Google/Apple OAuth blocked by default WKWebView user agent (2026-07-10) (+10 more)

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
Cohesion: 0.17
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 181 - "GridCompositorTests"
Cohesion: 0.18
Nodes (5): CompositorPane, GridCompositorTests, Bool, String, TerminalGridSnapshot

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.24
Nodes (6): FileTreeNode, NodeRow, .body, Bool, Error, String

### Community 184 - "targets"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Kouen, Sparkle (+13 more)

### Community 185 - "SessionSnapshot"
Cohesion: 0.13
Nodes (3): KouenGridTerminalTests, String, TerminalGridSnapshot

### Community 187 - "AppDelegate"
Cohesion: 0.17
Nodes (10): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+2 more)

### Community 188 - "BrowserPaneView"
Cohesion: 0.08
Nodes (26): Motion, .entrance, .spring, .standardEase, CAMediaTimingFunction, AmbientBackground, .body, Bool (+18 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.12
Nodes (16): CKouenSys, Darwin, Foundation, Glibc, OSCTerminatorMatch, PtyError, launchFailed, ShellLaunchProfile (+8 more)

### Community 190 - "user-stories.md"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.10
Nodes (14): PluginLoader, String, ScriptError, .errorDescription, evaluationError, unsupportedPlatform, ScriptRuntime, Any (+6 more)

### Community 192 - "GlyphRasterizer"
Cohesion: 0.10
Nodes (20): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+12 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.19
Nodes (10): RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal, FileHandle, Int32 (+2 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.12
Nodes (4): NSEvent, CGFloat, .blocks, .promptRows

### Community 195 - "ResizeHUDView"
Cohesion: 0.13
Nodes (15): BranchSwitchHelper, FileTreeSwiftUIView, .body, .filteredNodes, .rootPath, .scanOptions, .sessionID, .taskID (+7 more)

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.05
Nodes (36): .init(frame:), .init(coder:), Kind, primary, secondary, .init(coder:), KouenPillButton, .init(coder:) (+28 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.09
Nodes (26): bNt(), bu(), cNt(), dNt(), eNt(), eRe(), fNt(), h0t() (+18 more)

### Community 198 - ".classify"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.26
Nodes (8): InstallResult, Shell, bash, fish, zsh, ShellIntegration, Bool, URL

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.13
Nodes (10): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String (+2 more)

### Community 202 - "PaletteModel"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.07
Nodes (24): FilterStatus, active, all, completed, CaseIterable, ExperienceMode, agent, .displayName (+16 more)

### Community 204 - "From tmux"
Cohesion: 0.25
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 205 - "CopyModeState"
Cohesion: 0.14
Nodes (12): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+4 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.27
Nodes (6): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor

### Community 207 - "scheduleRender"
Cohesion: 0.09
Nodes (16): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController, CheckpointInfo (+8 more)

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.08
Nodes (26): .lspPosition(characterOffset:), Equatable, object, Bool, CodingKeys, error, id, jsonrpc (+18 more)

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
Cohesion: 0.22
Nodes (4): AgentHandoffBuilder, Bool, String, AgentHandoffBuilderTests

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.06
Nodes (30): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+22 more)

### Community 215 - ".lines"
Cohesion: 0.12
Nodes (5): CommandIPCTranslatorTests, Bool, PaneID, TabID, Phase67Tests

### Community 216 - "CellColorResolverTests"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 217 - "GridCompositor"
Cohesion: 0.14
Nodes (24): aJ(), bXt(), cJ(), Cqt(), dXt(), F0(), fXt(), gXt() (+16 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.14
Nodes (5): ContentAreaViewController, Bool, TabID, Set, Notification

### Community 219 - "Prompt"
Cohesion: 0.29
Nodes (4): String, .trimmed, AgentTitleInference, Bool

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
Cohesion: 0.20
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 224 - "CellColorResolver"
Cohesion: 0.24
Nodes (9): ANSIPalette, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors, Bool, Double, TerminalGridCell (+1 more)

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.18
Nodes (11): JSONRPCMessage, notification, request, response, StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength (+3 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.18
Nodes (16): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, PaneLeaf, PaneNode (+8 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.03
Nodes (67): RGBColor, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:claudeAPIKey:terminalShaderEffect:browserHomePage:), .scrollbackLines, ResizeOverlayMode, afterFirst, always, never, ResizeOverlayPosition (+59 more)

### Community 228 - "sessionRow"
Cohesion: 0.14
Nodes (7): KeybindingsStore, .fileURL, URL, KeybindingsStoreTests, URL, Void, String

### Community 229 - ".decide"
Cohesion: 0.14
Nodes (9): .selectedHost, MutationResult, RemoteHost, RemoteHostStore, Bool, String, RemoteHostStoreTests, String (+1 more)

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.25
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 231 - "ExternalOpenKind"
Cohesion: 0.17
Nodes (21): Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors, ContrastGrade (+13 more)

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.09
Nodes (15): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, BoardViewController, .isVisible, FlippedView (+7 more)

### Community 234 - ".scan"
Cohesion: 0.09
Nodes (6): String, WorktreeIsolationTests, String, URL, UUID, WorktreeIsolationDaemonTests

### Community 235 - "WorkbenchCommand"
Cohesion: 0.10
Nodes (17): BoxDrawing, Kind, arms, dashH, dashV, halfDown, halfLeft, halfRight (+9 more)

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.09
Nodes (14): Bool, NSEvent, Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint (+6 more)

### Community 238 - ".make"
Cohesion: 0.16
Nodes (17): aXt(), AYt(), Cme(), DYt(), IR(), IUe(), j9n(), KYt() (+9 more)

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.11
Nodes (17): Agent Detection, Branch Detection Flow, Branch Label, Chrome Roles, Drag Reorder, File, Files, Git Branch Detection (+9 more)

### Community 240 - "PaneBorderStatus"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 242 - "AgentBridge"
Cohesion: 0.06
Nodes (33): CustomEndpointTester, Result, Bool, String, URL, ModelKeyStore, Bool, String (+25 more)

### Community 243 - ".make"
Cohesion: 0.23
Nodes (21): Encodable, ExpressibleByStringLiteral, AISuggestionAck, AttachedAck, BrowserFramePush, Cred, DetachedAck, DeviceCredentials (+13 more)

### Community 244 - "FileNode"
Cohesion: 0.22
Nodes (7): Group, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, CGFloat, NSTextField, NSWindow

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.06
Nodes (34): DetachedPaneOverlay, .init(coder:), .init(frame:style:), InputGate, .siblings, OutputCoalescer, ReconnectLatch, .isTripped (+26 more)

### Community 247 - ".renderFixture"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.13
Nodes (12): AgentBrowserPaneTracker, SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), PaneID, PaneNode, Set, SurfaceID (+4 more)

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.16
Nodes (9): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+1 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.29
Nodes (4): TaskStore, tasks, URL, TaskStoreTests

### Community 251 - "SessionCoordinator"
Cohesion: 0.25
Nodes (4): KeyTokenParser, Bool, String, KeyTokenParserTests

### Community 252 - "NSViewRepresentable"
Cohesion: 0.09
Nodes (22): .init(coder:), BrowserProgressLine, .init(coder:), .init(frame:), BrowserTabButton, .init(coder:), .init(title:isActive:onSelect:onClose:), DesignModePopoverViewController (+14 more)

### Community 254 - "BoardViewController"
Cohesion: 0.30
Nodes (9): .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release, `repeat`, KeyModifiers, Character, String (+1 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.14
Nodes (6): BrowserPaneView, DesignModeElementInfo, Any, NSPopover, String, TimeInterval

### Community 256 - "GitMetadataProvider"
Cohesion: 0.30
Nodes (3): FileTreeWatcher, FileTreeWatcherTests, URL

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.14
Nodes (22): CoreImage, CryptoKit, Network, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription (+14 more)

### Community 258 - "WindowTitleStripView"
Cohesion: 0.13
Nodes (10): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, Task, Void (+2 more)

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.19
Nodes (8): Range, String, TerminalGridCell, TerminalBufferMatch, TerminalBufferSearch, String, TerminalGridCell, TerminalBufferSearchTests

### Community 260 - ".welcome"
Cohesion: 0.24
Nodes (7): BinaryInstaller, .bundledMacOSDir, Bool, TimeInterval, BinaryInstallerVersionTests, String, URL

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 262 - ".install"
Cohesion: 0.11
Nodes (17): 1. Codex / ChatGPT App-Server Daemon, 1. Generalize the mode setting: `ClaudeSessionMode` → `AgentSessionMode`, 2. Antigravity Ecosystem Splintering (Google Rebranding & Storage Divergence), 2. One data-driven command table instead of repeated switches, 3. GitHub Copilot CLI & VS Code / GitHub Web, 3. Remote-control daemons (Codex and Antigravity), 4. "Send to cloud" as an explicit action (Codex and Copilot), 5. History reverse direction for more agents (+9 more)

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
Cohesion: 0.08
Nodes (24): aie(), arc(), b2e(), bezierCurveTo(), closePath(), cRe(), cZ(), E7() (+16 more)

### Community 270 - "WindowSession"
Cohesion: 0.09
Nodes (9): PaneBorderStatus, Bool, Command, DispatchWorkItem, PaneRect, String, StyledSegment, UInt8 (+1 more)

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
Cohesion: 0.12
Nodes (19): dhn(), Eme(), en(), fhn(), ghn(), gk(), GOt(), jUe() (+11 more)

### Community 277 - ".run"
Cohesion: 0.33
Nodes (6): Command, .targetKind, TargetKind, pane, session, window

### Community 278 - "BlockTintOverlay"
Cohesion: 0.30
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 280 - ".menu"
Cohesion: 0.09
Nodes (15): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, Set, SurfaceID (+7 more)

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

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
Cohesion: 0.20
Nodes (9): RecordingEvent, input, metadata, output, resize, .timeMs, Date, Encoder (+1 more)

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.12
Nodes (11): MarkdownPreviewView, Any, Bool, Error, String, URL, Void, MarkdownBundle (+3 more)

### Community 287 - ".apply"
Cohesion: 0.41
Nodes (5): InstallResult, ShellCompletionInstaller, Bool, String, URL

### Community 288 - "AgentHookStrategy"
Cohesion: 0.20
Nodes (11): .activeTab, .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), .webView(_:didFinish:), BrowserTab, UUID, WKNavigationAction, WKWebView (+3 more)

### Community 290 - "Process"
Cohesion: 0.11
Nodes (10): GitPanelView, .isHidden, .removeWorktreeAction(path:), GitResult, Bool, DispatchWorkItem, String, UnsafeMutableRawPointer (+2 more)

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
Cohesion: 0.24
Nodes (6): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 296 - "NotificationBus"
Cohesion: 0.11
Nodes (10): AppKit, ScreenPos, bottom, middle, top, KouenApp, KouenLSP, KouenSyntaxResources (+2 more)

### Community 297 - "settings.json"
Cohesion: 0.17
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, Bool, Double (+3 more)

### Community 299 - "PaneNode"
Cohesion: 0.08
Nodes (31): CGFloat, FooterIconButton, .body, RecentProjectsMenuButton, .recents, SidebarFooterModel, SidebarFooterView, .body (+23 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.14
Nodes (13): AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID, .snapshotPayload, NotificationBus (+5 more)

### Community 301 - ".parse"
Cohesion: 0.18
Nodes (7): ParsedShortcut, .displayString, PrefixKeymap, Any, NSEvent, String, TimeInterval

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.16
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 303 - ".encodeMouse"
Cohesion: 0.16
Nodes (5): TabID, WorkspaceID, AgentCommandTests, String, Tab

### Community 304 - "00-inception-plan.md"
Cohesion: 0.17
Nodes (16): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+8 more)

### Community 305 - ".script"
Cohesion: 0.30
Nodes (7): .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didStartProvisionalNavigation:), LoadCompletionState, CheckedContinuation, Error, WKNavigation

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 307 - "ViPathTokenTests"
Cohesion: 0.20
Nodes (3): AgentSessionHistoryModelTests, Date, String

### Community 308 - "Send Ex Command"
Cohesion: 0.12
Nodes (20): AgentHistoryFTSIndex, .deleteSession(sessionID:), .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:surfaceTag:topicSegments:), .needsReindex(sessionID:mtime:fileSize:), .pruneMissingSessions(validTranscriptPaths:), .saveRecord(_:mtime:fileSize:), .search(query:limit:), .searchRanked(query:limit:includeSnippet:) (+12 more)

### Community 310 - "FrameSignposter"
Cohesion: 0.07
Nodes (31): KeybindingsService, Bool, Command, String, KeySpec, .init(from:), Decoder, Binding (+23 more)

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.11
Nodes (11): URL, String, String, KouenFilePreviewLoader, KouenViewError, binaryOrUnsupportedEncoding, missingPath, tooLarge (+3 more)

### Community 312 - "AgentSnapshot"
Cohesion: 0.18
Nodes (14): Array, Bool, Date, Decoder, PaneID, PaneNode, String, TabID (+6 more)

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.09
Nodes (18): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, SessionGroup, Tab (+10 more)

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.12
Nodes (16): Agent Config Wiring, Agents, Architecture, Browser Pane, File I/O, Git, Key Files, MCP Server (harness-mcp) (+8 more)

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.11
Nodes (11): HookState, failed, idle, installed, installing, NotificationCenterProbe, .isKnownBad, Bool (+3 more)

### Community 319 - "FormatColor"
Cohesion: 0.15
Nodes (9): Bool, Int32, String, URL, SystemdUserInstaller, .backendName, .isInstalled, .unitURL (+1 more)

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.26
Nodes (14): Agent Command Does Not Crash, Agent Waiting Filter Does Not Crash, Board Command Shows Board Panel, Cd Command Switches To Matching Tab, Copy Path Command Does Not Crash, Errors Command Does Not Crash, Find Command Opens Command Palette On Empty Query, Find Command Resolves Unique File (+6 more)

### Community 321 - "UInt64"
Cohesion: 0.23
Nodes (6): BrowserPaneRegistry, .init(url:paneID:), NSWindow, PaneID, WeakBrowserPaneView, WebKit

### Community 322 - "DesktopNotifier"
Cohesion: 0.13
Nodes (17): FormatContextBuilder, DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:) (+9 more)

### Community 323 - "LayoutNode"
Cohesion: 0.14
Nodes (12): NaturalLanguage, AgentHistorySearch, Hit, IDFCache, Bool, Double, String, .tokenHits(_:inNormalized:) (+4 more)

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.09
Nodes (17): DaemonClientActor, TimeInterval, DaemonSessionError, daemonError, .description, unexpectedResponse, DaemonSessionService, .endpoint (+9 more)

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.16
Nodes (9): FileGraphInfo, GraphifyLSPBridge, Double, String, URL, GraphifyLSPBridgeTests, Any, String (+1 more)

### Community 327 - ".theme"
Cohesion: 0.25
Nodes (8): PaneOutputWaiter, PaneOutputWaitResult, Bool, CheckedContinuation, Never, PaneLeaf, Tab, UInt64

### Community 328 - "README.md"
Cohesion: 0.06
Nodes (27): ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange, NSTextView (+19 more)

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 330 - ".drawGlyph"
Cohesion: 0.18
Nodes (15): CellMetrics, ComposedFrame, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth (+7 more)

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.13
Nodes (17): a6(), EUe(), eYt(), gC(), h2(), kme(), MR(), N9() (+9 more)

### Community 332 - "Added"
Cohesion: 0.08
Nodes (24): item, input, .saveRecordsBatch(_:), AgentHistoryScanner, AgentHistoryTurn, AgentSessionPlacement, background, cloud (+16 more)

### Community 333 - "RealPty"
Cohesion: 0.18
Nodes (8): ClaudeRunSummary, Date, Double, Int32, String, UUID, String, UUID

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.13
Nodes (19): cYt(), dqt(), Dr(), Fwe(), G3(), gKt(), LC(), lKt() (+11 more)

### Community 335 - ".makeModel"
Cohesion: 0.19
Nodes (10): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+2 more)

### Community 336 - "run.sh"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 337 - "CommandExecutionError"
Cohesion: 0.22
Nodes (9): FormatContext, FormatString, FormatStyle, Bool, Character, Date, FormatColor, String (+1 more)

### Community 338 - "CSIParams"
Cohesion: 0.16
Nodes (9): AgentRemoteControlDaemonService, Bool, Set, String, Void, AgentRemoteControlDaemonServiceTests, LogBox, .count (+1 more)

### Community 339 - "Foundation"
Cohesion: 0.15
Nodes (12): KouenCopyMode, KouenTerminalEngine, KouenTerminalKit, KouenTerminalRenderer, KouenTheme, Metal, ImmersiveEffects, CALayer (+4 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.12
Nodes (6): tab, .tab(for:), AgentScanner, Bool, DispatchSourceTimer, TimeInterval

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.18
Nodes (11): AgentLaunchCommands, String, AgentSessionMode, cloud, happy, .launchCommand, .launchFlags, local (+3 more)

### Community 342 - "Added"
Cohesion: 0.27
Nodes (8): Bool, NSPasteboard, NSString, String, URL, TerminalServicesProvider, AutoreleasingUnsafeMutablePointer, NSObject

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.18
Nodes (10): AssistantLine, ClaudeAdapter, Content, Message, ResultLine, Bool, Double, String (+2 more)

### Community 344 - "FileViewerViewController"
Cohesion: 0.14
Nodes (10): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+2 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.24
Nodes (9): SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, Int32, String (+1 more)

### Community 349 - "Contents.json"
Cohesion: 0.17
Nodes (4): InputEncoder, InputEncoderTests, String, UInt8

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.19
Nodes (4): URL, MobileBridgeAttachFileTests, String, URL

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.19
Nodes (9): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.11
Nodes (13): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, PaneLeaf (+5 more)

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.13
Nodes (10): .init(frame:), NSHostingView, NSLayoutConstraint, NSRect, TerminalTabBarView, .delegate, .init(frame:), .leadingInset (+2 more)

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.20
Nodes (4): Any, NSMenu, NSMenuItem, String

### Community 355 - ".deepMerge"
Cohesion: 0.19
Nodes (13): ProjectGroupWatcher, StreamBox, Bool, DispatchQueue, escaping, FSEventStreamRef, MainActor, Never (+5 more)

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.11
Nodes (3): Bool, String, UUID

### Community 357 - ".handleCat"
Cohesion: 0.08
Nodes (48): Codable, BrowserSnapshotAck, agentWaitChannel(), BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserRequestPayload (+40 more)

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.20
Nodes (9): BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool, CGFloat, NSCoder, NSPoint (+1 more)

### Community 359 - "OcclusionTests"
Cohesion: 0.14
Nodes (13): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+5 more)

### Community 360 - "State"
Cohesion: 0.12
Nodes (16): Decisions so far, Destination, M2 — Warp custom model router, M3 — cmux Browser Design Mode, M4 — cmux Fork Conversation, M5 — cmux saved workspace layouts, M6 — iTerm2 AI safety-check, M7 — iTerm2 workgroup review automation (+8 more)

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.05
Nodes (26): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, AutomationScheduler (+18 more)

### Community 362 - "RGBColor"
Cohesion: 0.22
Nodes (6): Divergence, Bool, String, TimeInterval, WorktreeInfo, WorktreeManager

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.09
Nodes (19): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+11 more)

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.19
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 366 - "Consumers"
Cohesion: 0.11
Nodes (17): .onSelect, agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:) (+9 more)

### Community 367 - "DaemonStats"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 368 - "Tab"
Cohesion: 0.18
Nodes (8): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController

### Community 369 - "Git Panel"
Cohesion: 0.30
Nodes (8): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, PaletteFooter, .body

### Community 370 - ".encode"
Cohesion: 0.20
Nodes (4): TerminalModes, .encode(text:modifiers:modes:), Bool, .appCursor

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.11
Nodes (17): KeyRecorderRepresentable, String, Void, OverlayBackground, Context, OverlayBackground, Context, AttentionBeaconDotView (+9 more)

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.11
Nodes (19): DataBox, .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:) (+11 more)

### Community 373 - "Prompt"
Cohesion: 0.05
Nodes (23): Am(), bUt(), bze(), Cm(), EQ(), FBe(), fQ, Gbe() (+15 more)

### Community 374 - ".run"
Cohesion: 0.18
Nodes (13): Profile, edit, readonly, Run, RunState, cancelled, failed, running (+5 more)

### Community 375 - ".install"
Cohesion: 0.23
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 376 - "ScrollReuseTests"
Cohesion: 0.08
Nodes (16): RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), ScrollbackEntry, ScrollbackReplaySegment, Bool, CChar, DaemonSurfaceID, Int32 (+8 more)

### Community 377 - "Identifiable"
Cohesion: 0.10
Nodes (18): .agentInfo(forWorktreePath:), .agentInfo(forWorktreePath:tabs:), Tab, Reason, errored, finished, needsInput, RowState (+10 more)

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.17
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.12
Nodes (17): OnboardingStep, complete, discover, .id, setup, shell, .title, welcome (+9 more)

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.10
Nodes (18): .webView(_:didCommit:), BrowserPaneViewTests, MockWebView, .isLoading, .url, Any, Bool, CGFloat (+10 more)

### Community 387 - "User Profile"
Cohesion: 0.15
Nodes (11): TerminalDamage, RenderColor, MetalRendererTests, RenderedFixture, Bool, MTLTexture, StaticString, String (+3 more)

### Community 388 - "Darwin"
Cohesion: 0.22
Nodes (10): ANSIPalette, CellColorResolver, MochaTheme, ResolvedCellColors, .init(hex:), Bool, Double, String (+2 more)

### Community 389 - "HarnessCLITests"
Cohesion: 0.26
Nodes (6): SwarmFleetSnapshotWire, SwarmTaskNodeWire, Date, Double, String, UUID

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.13
Nodes (14): Bug: Tab-Switch Black Screen, Files changed, Final fast-path guard (PaneLifecycleManager.swift), FM-1: detachHostsOnly() before caching (always broken), FM-2: force=true rebuild caches the stripped container, FM-3: Host theft by another tab's build, FM-4: Cache overwrite leaks orphan containers, FM-5: Fix never extended to WKWebView-backed browser panes (2026-08-23) (+6 more)

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.16
Nodes (14): CLI Isolate Creates Worktree And Session, CLI Isolate With Custom Branch Name, Close Session Keeps Dirty Worktree, Close Session Removes Clean Worktree, Create Isolated Session And Select, Drag Reorder Past Worktree Row No Crash, Git Checkout In Normal Session Does Not Affect Isolated, Isolate Without Branch Uses Detached HEAD (+6 more)

### Community 402 - "View"
Cohesion: 0.09
Nodes (19): Agent, OnboardingEnvironment, Bool, String, BinaryInstaller.DetectionStatus, SetupStepView, .body, .canInstall (+11 more)

### Community 403 - "PresentAttempt"
Cohesion: 0.22
Nodes (5): AgentRoutingResolver, String, AgentRoutingRule, AgentRoutingResolverTests, Result

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.22
Nodes (6): ListeningPortScanner, Int32, Set, String, result, ListeningPortScannerTests

### Community 405 - "AgentIconRenderer"
Cohesion: 0.09
Nodes (17): EndpointError, connectionFailed, .description, notYetSupported, pathTooLong, String, EndpointConnector, Int32 (+9 more)

### Community 406 - "main.swift"
Cohesion: 0.23
Nodes (8): LSPFileSession, Never, String, Task, URL, Void, URL, SyntaxDefinitionTarget

### Community 407 - "Fixed"
Cohesion: 0.10
Nodes (17): .body, .mcpButton, json, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter (+9 more)

### Community 408 - "IPC Architecture"
Cohesion: 0.31
Nodes (9): CGFloat, Range, Tab, TabBarLayoutMetrics, .pitch, tabDisplayTitle(), TerminalTabBarBody, .body (+1 more)

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.33
Nodes (6): SurfaceProgressTracker, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void

### Community 412 - "go.json"
Cohesion: 0.19
Nodes (5): ezt(), GGe, Gwe(), Hzt(), Kp()

### Community 414 - "json.json"
Cohesion: 0.13
Nodes (14): 1. @MainActor + Task + Process.waitUntilExit = FREEZE (RL-052), 2. @Observable + mutation in body = infinite re-render loop (RL-053), 3. Re-entrancy guard on rebuildRows, 4. Worktree display rules, Architecture, chromeEpoch — force SwiftUI re-render from static state, Critical Lessons (bugs fixed), File tree: root at git root, expand on CWD change (+6 more)

### Community 415 - "markdown.json"
Cohesion: 0.31
Nodes (6): Bool, Counter, Scheduled, SurfaceProgressTrackerTests, DispatchWorkItem, TimeInterval

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.14
Nodes (19): BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, CodingKeys, description, key (+11 more)

### Community 417 - "rust.json"
Cohesion: 0.23
Nodes (5): CSIParams, .count, TerminalGridColor, TerminalGridUnderline, UInt8

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.21
Nodes (4): Bool, String, SurfaceID, TimeInterval

### Community 419 - "typescript.json"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 420 - "yaml.json"
Cohesion: 0.24
Nodes (9): Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock, .block(id:) (+1 more)

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.09
Nodes (18): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+10 more)

### Community 422 - "HintModeOverlay"
Cohesion: 0.06
Nodes (15): SessionGroup, String, KouenSidebarPanelViewController, NSMenuItem, SessionGroup, String, NSMenu, NSMenuItem (+7 more)

### Community 423 - "SixelDecoder"
Cohesion: 0.08
Nodes (30): .filteredJobs, MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith (+22 more)

### Community 424 - ".parseDiffHunks"
Cohesion: 0.17
Nodes (5): DirectionalAxis, down, left, right, up

### Community 425 - "AgentVectorIcon"
Cohesion: 0.13
Nodes (14): Architecture, Claude Code Subprocess Harness — Design, Context, Cost/context overhead control — SOLVED, verified, Decisions (user-confirmed), Explicitly NOT built (YAGNI), IPC / wiring, Minor note (+6 more)

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.29
Nodes (6): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Carbon

### Community 427 - ".delay"
Cohesion: 0.18
Nodes (6): HappyAdoptTests, CopilotSessionInfo, HappyDaemonSession, Bool, Int32, String

### Community 428 - "TaskDashboardView"
Cohesion: 0.16
Nodes (4): SelectAllOnClickTextField, Selector, URL, NSAppearance

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.14
Nodes (14): OptionStore, Scope, pane, session, workspace, ScopedKey, Bool, URL (+6 more)

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.11
Nodes (15): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+7 more)

### Community 431 - "BoardCardView"
Cohesion: 0.11
Nodes (21): .color, BoardCard, BoardColumn, .name, BoardColumnKind, .displayName, done, error (+13 more)

### Community 432 - "PathToken"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.20
Nodes (9): Container, .init(coder:), .init(frame:), NotchPulseHost, .body, Context, NSCoder, NSHostingView (+1 more)

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
Cohesion: 0.13
Nodes (11): ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy, SessionLifecycleService, NSWindow (+3 more)

### Community 439 - "SetupStepView"
Cohesion: 0.14
Nodes (8): brn, grn, hrn(), JGe(), KGe(), prn(), qGe(), zGe()

### Community 440 - "LegacySnapshot"
Cohesion: 0.13
Nodes (14): Aggregate: `AgentRoutingRule`, Aggregate root: `AgentRoutingRuleStore`, Design — M2: Agent Routing Rule, Domain service: `AgentRoutingResolver`, `kouenSpawnAgent` change (`KouenDaemonTools.swift:319-356`), Logical Design, MCP tools (`kouen-mcp`, naming mirrors Automation's tool family), Next Step (+6 more)

### Community 441 - "RemoteHostStore"
Cohesion: 0.24
Nodes (8): ProjectDropTarget, .init(coder:), .init(frame:), NSCoder, NSDraggingInfo, NSDragOperation, NSRect, URL

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.15
Nodes (9): CoreGraphics, CoreText, ShapedGlyphSignature, Bool, CGFloat, CGGlyph, String, NerdFontFallbackTests (+1 more)

### Community 443 - "main.swift"
Cohesion: 0.07
Nodes (31): ImagePlacementSnapshot, SemanticMark, Bool, String, UInt8, TerminalCellWidth, normal, spacerTail (+23 more)

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 445 - "Section"
Cohesion: 0.18
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 446 - "Modifiers"
Cohesion: 0.14
Nodes (14): dme(), dw(), evt(), Lje(), LRt(), nJ(), nMt(), pme() (+6 more)

### Community 447 - "PaletteMode"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.18
Nodes (10): Bug 1 - Rotation Grace Slot Keeps The Previous Token Redeemable, Bug 1 - Rotation Shifts The Outgoing Token Into The Grace Slot, Bug 1 - Stop Fully Clears The Grace Slot, Bug 1 - Token Lifetime Not Regressed Below The Human-Flow Window, Bug 2 - Client onerror Does Not Clobber The Server Error Banner, Bug 2 - No Abrupt Cancel Immediately After The Error Text, Bug 2 - Reject Path Closes Gracefully With Policy-Violation Code 1008, Bug 3 - QR Not Printed When No Listener Is Ready (+2 more)

### Community 449 - "PresentAttempt"
Cohesion: 0.08
Nodes (18): Tab, BrowserIntegrationController, PaneID, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:), .init(paneID:), PaneID, PaneNode (+10 more)

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.26
Nodes (5): Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 451 - ".run"
Cohesion: 0.28
Nodes (6): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.22
Nodes (10): Status, ciFailing, done, mergeReady, open, running, Bool, Date (+2 more)

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.22
Nodes (10): DotView, .init(coder:), statusColor(), Bool, Context, NSCoder, NSColor, .workingDot (+2 more)

### Community 454 - ".recordReapedGenerationForTesting"
Cohesion: 0.06
Nodes (50): AgentRow, .agentColor, .executables, .hookButton, .hookButtonTitle, SettingsAgentsView, .agentsSection, .body (+42 more)

### Community 455 - "ComposerPanel"
Cohesion: 0.19
Nodes (3): Bool, Int32, String

### Community 456 - "TerminalModes"
Cohesion: 0.24
Nodes (5): Bool, SessionID, SplitDirection, String, WorkspaceID

### Community 457 - ".normalizedKey"
Cohesion: 0.20
Nodes (9): AnyObject, CommandExecutionError, daemonError, .description, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor (+1 more)

### Community 459 - ".encode"
Cohesion: 0.24
Nodes (5): DisplayLinkTarget, CADisplayLink, Void, Notification.Name, os

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
Cohesion: 0.29
Nodes (3): BellScanTests, Bool, UInt8

### Community 464 - "MouseButton"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 465 - "DirectionalAxis"
Cohesion: 0.36
Nodes (5): PaneLeaf, SessionGroup, Any, String, Tab

### Community 466 - "ReflowFastPathTests"
Cohesion: 0.10
Nodes (8): KouenCLI, MemoCommandTests, URL, StatusLineWidthTests, TaskCommandTests, StatusLineWidth, String, StyledSegment

### Community 467 - ".moveSelection"
Cohesion: 0.27
Nodes (7): SwarmFleetBody, .body, SwarmNodeRowView, .body, .statusColor, Duration, Void

### Community 468 - "Never"
Cohesion: 0.14
Nodes (11): Agent Memory Index — harness-terminal, Navigation, Edges, Files, Knowledge Index — Harness Terminal, Search Instructions, Source Map, Case Index (+3 more)

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
Cohesion: 0.09
Nodes (11): KouenOnboarding, GridCompositorParityTests, LiveCompositorFixture, Bool, String, TerminalGridSnapshot, PortCompositorFixture, Bool (+3 more)

### Community 474 - "String"
Cohesion: 0.29
Nodes (7): Toggle Sidebar, Sidebar Toggle Works, Board CLI Shows Columns, Board CLI Shows Running After Long Command, Board Columns Visible After Click, Board Tab Accessible In Sidebar, Split Pane And Resize

### Community 475 - ".hitTest"
Cohesion: 0.30
Nodes (5): SearchBenchmarks, String, UInt64, URL, Void

### Community 477 - ".endFind"
Cohesion: 0.14
Nodes (13): ACP (Agent Client Protocol) — tried, shelved, erased, Command Palette / Power-User Terminal Features, Embedded Browser, Feature Provenance — harness-terminal, Git Panel, Harness MCP, IDE Track — File Tree / Editor / LSP (the "Zed half" made real), Notifications (+5 more)

### Community 478 - ".install"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 479 - "ScrollbackTests"
Cohesion: 0.37
Nodes (4): KouenFeatureMarkdownSync, Bool, String, URL

### Community 480 - "Command Prompt Architecture"
Cohesion: 0.22
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
Cohesion: 0.12
Nodes (16): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+8 more)

### Community 490 - "ccRunGet"
Cohesion: 0.21
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 491 - "Added"
Cohesion: 0.24
Nodes (3): ClaudeSessionModeTests, URL, Void

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 494 - "ccRunInfo"
Cohesion: 0.33
Nodes (5): Kouen LSP Diagnostics Does Not Crash, Kouen LSP Hover Returns Result, Kouen LSP Start Returns JSON, Kouen View Binary Shows Guard Message, Kouen View Prints File Content

### Community 495 - "ccRuns"
Cohesion: 0.14
Nodes (13): 1. Data / Geometry Separation (primary fix), 2. SnapshotCoalescer (cmux NotificationBurstCoalescer pattern), 3. Equality Guard on updateGeometry (Zed pattern), 4. Dirty Flag on setFrame (Otty/WezTerm pattern), 5. GPU Animation — CAShapeLayer Mask (Zed/Otty GPU path), 6. AgentScanner timer split, Files, Fixes Applied (layered) (+5 more)

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.10
Nodes (22): a0n(), bX(), dl(), eAn(), eht(), Em(), gb(), gSn() (+14 more)

### Community 498 - ".automationList"
Cohesion: 0.20
Nodes (8): statusHelp(), String, TabStatus, done, error, idle, running, waiting

### Community 499 - ".routingRuleList"
Cohesion: 0.20
Nodes (10): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+2 more)

### Community 500 - ".json"
Cohesion: 0.40
Nodes (4): SplitDirection, TabID, .body, TerminalTabBarDelegate

### Community 501 - "Fixed"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 502 - "ACP Client (Shelved)"
Cohesion: 0.22
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 503 - "Build Scripts Self-Kill Protection"
Cohesion: 0.20
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

### Community 504 - "WindowBorderOverlayView"
Cohesion: 0.14
Nodes (13): AI-SDLC Task Progress — P50 Cloud and Remote Control for Codex, Antigravity and Copilot, Artifacts, Context, Open questions & Real-world observations (Updated 2026-09-25), Phase A: spike on a Mac, Phase B: mode setting and command table, Phase C: remote-control daemons, Phase D: Send to cloud (+5 more)

### Community 506 - "SwarmFleetBody"
Cohesion: 0.24
Nodes (7): MTLLibrary, MTLRenderPipelineState, CGFloat, MTLBuffer, MTLDevice, String, T

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.40
Nodes (4): Leak A - Retiring A Host Drops Its AI Controllers, Leak B - Browser Network Capture Is Bounded, Leak C - Every Per-Surface Dict In Coordinator Has Retire Cleanup, Leak D - Every Per-Surface Dict In NotificationCoordinator Is Snapshot-Swept

### Community 508 - "SessionStore"
Cohesion: 0.40
Nodes (9): attribute_lines(), main(), redraw_frames(), repeated_chunk(), run_case(), sgr_lines(), truecolor_gradient(), unicode_lines() (+1 more)

### Community 509 - "start.mjs"
Cohesion: 0.70
Nodes (4): main(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 510 - "PromptQueue"
Cohesion: 0.18
Nodes (10): Architecture Decisions (dated log), Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Post-P50 changes (v4.20.2 → v4.20.11, 2026-10-01 → 2026-10-06), Product Identity Guardrail: Terminal, Not IDE, Shipped capability summary, P44–P49 (2026-08-31 → 2026-09-23) (+2 more)

### Community 511 - ".panePathLookup"
Cohesion: 0.11
Nodes (18): CodingKeys, excludedPaths, id, name, sourceFolder, CodingKey, CodingKeys, createdAt (+10 more)

### Community 512 - "Changelog Archive"
Cohesion: 0.15
Nodes (12): Architecture, Browser DevTools API (P28), Config, Key Bug Fixed: Round-Trip Timeout (RL-048), Key Files, Phase 1 — Core (all via evaluateJS or WKWebView native), Phase 2 — Network, Phase 3 — Storage (+4 more)

### Community 513 - "ThemeDocument"
Cohesion: 0.04
Nodes (35): KouenCore, KouenPaths, SessionStore, DispatchWorkItem, TimeInterval, PendingVersionBanner, welcome, whatsNew (+27 more)

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.27
Nodes (7): Never, Set, String, Task, URL, Void, WorkspaceSymbolIndex

### Community 517 - ".testManyConcurrentSubscribersAllReceiveOutput"
Cohesion: 0.15
Nodes (12): 1. Synchronous Disk I/O on Main Thread (`settings.save()`), 2. False "Live Resize" Triggered During Slide (`requestLiveResizeCommit`), 3. Ease-In-Out Animation Physics (Perceived Dead Pause), 4. CADisplayLink Hardcoded to 60Hz on 120Hz ProMotion Displays, 5. First Frame Timing Hitch, 6. Redundant `split.needsDisplay = true` and `sidebarLog.debug` on Every Frame, Fix, Post-mortem: Cmd+\ sidebar toggle latency and animation lag (2026-09-19) (+4 more)

### Community 519 - ".gestureRecognizer"
Cohesion: 0.18
Nodes (6): eKe(), irn(), mrn, _rn(), rrn(), srn()

### Community 520 - "WriteOutcome"
Cohesion: 0.20
Nodes (13): ern(), G4(), G7(), Jnn(), nrn(), Qnn(), sHe(), trn() (+5 more)

### Community 522 - "ShellCompletionInstallerTests"
Cohesion: 0.22
Nodes (6): AgentNotchPresentation, closed, open, peek, AgentNotchWindowActivator, Combine

### Community 523 - ".encode"
Cohesion: 0.24
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 524 - "RealPtyLifecycleTests"
Cohesion: 0.25
Nodes (6): OptionSet, .description, .init(key:modifiers:), Modifiers, String, UInt8

### Community 525 - "TabContextCommand"
Cohesion: 0.36
Nodes (3): TerminalGridCell, String, TerminalGridCell

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
Cohesion: 0.08
Nodes (17): SnapshotCoalescer, MainActor, Void, NotchMaskAnimator, Bool, CGFloat, CGRect, NotchPanel (+9 more)

### Community 530 - "HarnessChrome"
Cohesion: 0.29
Nodes (8): FormatColor, none, palette, rgb, StyledSegment, Bool, String, UInt8

### Community 531 - ".recordReapedGenerationForTesting"
Cohesion: 0.07
Nodes (31): aDt(), B3(), Bpe(), cFe(), dFe(), displayable(), _Dt(), eFe() (+23 more)

### Community 534 - ".sessionID"
Cohesion: 0.21
Nodes (6): String, TerminalGridCell, TextGrid, .totalLines, .viewportRows, WordColumnRangeTests

### Community 535 - "AgentNotification"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 537 - "NSObject"
Cohesion: 0.33
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.06
Nodes (32): MainActor, Void, SessionDividerRowView, .init(coder:), .init(frame:), SessionGroupHeaderRowView, .init(coder:), SessionWorktreeHeaderRowView (+24 more)

### Community 539 - "install-app.sh"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 544 - "CodingKeys"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 546 - "LegacySnapshot"
Cohesion: 0.22
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 547 - "NSObject"
Cohesion: 0.12
Nodes (17): Any, center, ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow (+9 more)

### Community 553 - "harness.resource"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 556 - "BrowserTab"
Cohesion: 0.32
Nodes (4): SwarmFleetView, .init(coder:), CGFloat, NSCoder

### Community 557 - ".viewWillMove"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 558 - ".sendInput"
Cohesion: 0.29
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 560 - "LayoutTemplate"
Cohesion: 0.18
Nodes (4): HookFiringTests, NSObjectProtocol, String, URL

### Community 562 - "BrowserResponsePayload"
Cohesion: 0.40
Nodes (4): Build, Release & Git Workflow, Build / Test / Run, Release packaging order, Worktree constraint

### Community 563 - "AgentNotchViewModel.swift"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

### Community 565 - "ReleaseNotesGuardTests"
Cohesion: 0.24
Nodes (4): HintModeOverlay, Any, NSEvent, String

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 568 - ".gestureRecognizer"
Cohesion: 0.19
Nodes (9): NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView, .cornerConfiguration (+1 more)

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.57
Nodes (3): String, TaskDashboardBody, .body

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.09
Nodes (26): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+18 more)

### Community 571 - "ShellIntegrationTests"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 572 - "LayoutProbeView"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 573 - "main.swift"
Cohesion: 0.29
Nodes (3): Bool, CAMetalDrawable, String

### Community 575 - ".toastErrorSummary"
Cohesion: 0.14
Nodes (11): clamp(), Date, Never, T, Task, Void, TabPillView, .dragGesture (+3 more)

### Community 576 - "Phase67Tests"
Cohesion: 0.26
Nodes (4): RepoResolver, Bool, String, RepoResolverTests

### Community 578 - "TaskDashboardBody"
Cohesion: 0.39
Nodes (3): CGFloat, CGRect, Range

### Community 579 - "RunState"
Cohesion: 0.13
Nodes (7): ControlKeyNormalizer, Bool, String, ShortcutRecorderSerializer, String, ControlKeyNormalizerTests, ShortcutRecorderSerializerTests

### Community 580 - "ViInputMode"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 582 - "FileTreeKeyboardNavigator"
Cohesion: 0.24
Nodes (9): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+1 more)

### Community 583 - "WorkbenchMRU"
Cohesion: 0.10
Nodes (6): KouenDaemonCore, IPCCodecInvariantTests, MobileBridgeBrowserTests, ScrollbackPersistenceTests, String, URL

### Community 584 - "GUt"
Cohesion: 0.31
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 585 - "TargetSpec.swift"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 586 - ".consumeInputCore"
Cohesion: 0.05
Nodes (52): A1(), a2(), aAn(), aat(), akn(), ast(), bEn(), bln() (+44 more)

### Community 587 - "BrowserResponsePayload"
Cohesion: 0.25
Nodes (5): Bool, NSEvent, ViInputMode, insert, normal

### Community 589 - "Endpoint"
Cohesion: 0.33
Nodes (4): GridCompositorCopyModeTests, PaneRect, String, TerminalGridSnapshot

### Community 591 - "FormatContextDaemonTests"
Cohesion: 0.36
Nodes (3): KouenSplitViewTests, LayoutProbeView, CGFloat

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

### Community 598 - "DecodedWSFrame"
Cohesion: 0.38
Nodes (4): AnyObject, TimeInterval, ZombieHoldRegistry, ObjectIdentifier

### Community 599 - ".terminalHostIfExists"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 600 - "PaletteWindowDelegate"
Cohesion: 0.13
Nodes (7): .currentRawSelection, RawSelection, Bool, NSEvent, NSPoint, String, UInt16

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
Nodes (11): Gate: browser-pane-intermittent-black-screen, Gate: cmd-backslash-sidebar-launch-race-6th, Gate: cmd-backslash-sidebar-toggle, Gate: cmd-backslash-sidebar-zero-width, Gate: git-status-process-leak, Gate: kouen-browser-mcp-intermittent-unresponsive, Gate State, Gate: terminal-output-garbled-mid-session (+3 more)

### Community 610 - ".installCLI"
Cohesion: 0.20
Nodes (18): Decodable, Item, ItemCompletedLine, LegacyMsgLine, Msg, String, ThreadStartedLine, AISuggestRequest (+10 more)

### Community 613 - "INDEX.md"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 614 - "MainSplitViewController"
Cohesion: 0.09
Nodes (20): MainSplitViewController, .setSidebarVisible(_:), .setSidebarVisible(_:animated:), SplitChromeDelegate, .sidebarMaxWidth, .sidebarMinWidth, .splitView(_:constrainMaxCoordinate:ofSubviewAt:), .splitView(_:constrainMinCoordinate:ofSubviewAt:) (+12 more)

### Community 617 - "ScriptFileWatcher"
Cohesion: 0.10
Nodes (26): CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf, .init(from:) (+18 more)

### Community 622 - "[1.3.0-vit] - 2026-06-06"
Cohesion: 0.16
Nodes (6): ClaudeCodeHarness, .hasAdapter(for:), Bool, UUID, HeadlessCLIAdapter, ClaudeCodeHarnessTests

### Community 623 - "BrowserResponsePayload"
Cohesion: 0.13
Nodes (8): PaneNode, BrowserLeaf, URL, DaemonSyncServiceBrowserPaneMergeTests, PaneID, PaneNode, PaneNodeBrowserTests, PaneNodeLayoutShapeTests

### Community 624 - "[2.5.0] - 2026-06-12"
Cohesion: 0.20
Nodes (8): CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn, .text, Character, ClosedRange, String

### Community 627 - "ActiveTabCloseDisposition"
Cohesion: 0.33
Nodes (4): OutputTrigger, OutputTriggerStore, Bool, String

### Community 628 - "ReplayStep"
Cohesion: 0.26
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

### Community 661 - "Remote SSH — Market Comparison"
Cohesion: 0.17
Nodes (11): ACP vs MCP vs Terminal Chat, AgentProcessManager, Architecture, CLI Print-Mode Args, Context Injection, Key Files, Key Shortcuts (I-family), Non-Obvious Constraints (+3 more)

### Community 662 - "New Tab"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 664 - "P37 Phase G — Autocomplete (mobile bridge)"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 666 - "BrowserIntegrationController"
Cohesion: 0.17
Nodes (9): GitStatusProvider, OnceResume, Bool, Duration, String, TimeInterval, GitStatusProviderLargeOutputTests, URL (+1 more)

### Community 669 - ".handleUndo"
Cohesion: 0.26
Nodes (4): PaneLabelDaemonTests, String, URL, UUID

### Community 675 - ".detect"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 677 - "WriteOutcome"
Cohesion: 0.43
Nodes (7): Close Tab, New Tab, Cmd Shift W Force Closes Tab, Cmd T Creates New Session, Cmd W Closes Tab When Single Pane, Window Survives Full Shortcut Sequence, Zombie Crash Close Tab While Typing

### Community 678 - ".selectAdjacentSession"
Cohesion: 0.17
Nodes (11): Action items, Fix, How it was found, Post-mortem: Cmd+\ sidebar toggle produces zero visible change (2026-07-29), Related, Root cause, Summary, Symptom (+3 more)

### Community 679 - ".daemonIsStale"
Cohesion: 0.17
Nodes (11): 1. `SessionLifecycleService.swift` (tab bar clicks, sidebar clicks), 2. `MainExecutor.swift` (keyboard shortcuts — the actual user path), Competitive research (from Agy), Data model (correct, no changes needed), Files to read before resuming, Fix applied (compiles, not fully tested), Focus Persistence — Per-Session-Tab Pane Focus (RL-043), Restoration flow (after fix) (+3 more)

### Community 681 - ".tabIDsToNotify"
Cohesion: 0.17
Nodes (11): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile, regionEdit (+3 more)

### Community 682 - ".update"
Cohesion: 0.33
Nodes (6): Board and attention, Errors and LSP, File navigation, Search, Task runner, Workbench commands (IDE-like workflow)

### Community 683 - "RecipePickerFooter"
Cohesion: 0.18
Nodes (10): 2026-06-25 — OSC 7735:  opens sidebar file viewer, 2026-06-27 — Block output tint + AI explain (Phase 12b), Pruned from MEMORY.md — 2026-07-02, Pruned from MEMORY.md — 2026-07-03, Pruned from MEMORY.md — 2026-07-04, Pruned from MEMORY.md — 2026-07-06, Pruned from MEMORY.md — 2026-07-07, Pruned from MEMORY.md — 2026-07-08 (+2 more)

### Community 684 - "New Tab"
Cohesion: 0.18
Nodes (10): 1. SurfaceShellTracker (proc tree walk), 2. DaemonSyncService.startMetadataRefresh (5-s loop), 3. snapshotChanged Fanout, 4. PerfCounters — Instrumentation, 5. Performance Lessons (v3.2.0), Adaptive polling, Background Polling & Snapshot Fanout — P22, Known Non-P22 Callers of syncFromDaemon (+2 more)

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 686 - "Fze"
Cohesion: 0.10
Nodes (6): o, aZ(), e0(), eie(), eZ(), wZ()

### Community 687 - "FormatStringExtendedVariableTests"
Cohesion: 0.18
Nodes (10): AI / Agent Connectivity, Architecture Decisions — harness-terminal, Browser Pane, Config / Settings, File Preview / Split Panes, IPC / Daemon, Keybindings, Sessions / Tabs (+2 more)

### Community 690 - ".update"
Cohesion: 0.40
Nodes (5): Additional `kouen-cli` subcommands, Agents, context and scratchpad, Daemon and diagnostics, Editor, LSP and setup, Sessions, tabs and recording

### Community 691 - "TaskDashboardBody"
Cohesion: 0.29
Nodes (6): DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed

### Community 692 - ".control"
Cohesion: 0.14
Nodes (9): MTLRenderCommandEncoder, ImageTextureCache, MTLDevice, MTLTexture, Set, UInt8, ImageZBand, aboveText (+1 more)

### Community 693 - "HeadlessRunEvent"
Cohesion: 0.18
Nodes (10): Action items, Fix, How it was found, Post-mortem: Cmd+\ sidebar toggle unreliable (2026-07-27), Root cause, Summary, Symptom, Validation (+2 more)

### Community 694 - "zGe"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 696 - "TerminalTabBarDelegate"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 698 - "LayoutProbeView"
Cohesion: 0.21
Nodes (4): JSONDecoder, JSONEncoder, String, TerminalRecordingCodec

### Community 699 - ".make"
Cohesion: 0.18
Nodes (10): Agent Notch: Approval Buttons Dead + False "Waiting" Badge, Both bugs found via, Bug 1 — Reply/Deny/Allow buttons do nothing (or open the row instead), Bug 2 — Notch shows "waiting for your input" after a completely normal turn, Fix, Fix, Root Cause, Root Cause (+2 more)

### Community 700 - "Typography"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 701 - ".testOccludedPaneParsesButNeverPresents"
Cohesion: 0.18
Nodes (10): Cause 1 — `existingHosts` strong dict in TerminalPaneRegistry (DOMINANT), Cause 2 — Insert-only AI controller dicts in SessionCoordinator, Cause 3 — Uncapped browser network capture array, Memory Leak Audit — 34 GB Long-Session Case (2026-06-26), Pattern to watch: "insert-only per-surface dict", Release, Root causes found and fixed, Symptom (+2 more)

### Community 702 - "main.swift"
Cohesion: 0.12
Nodes (6): PromptQueue, String, SurfaceID, Void, PromptQueueBar, NSWindow

### Community 703 - "ColorKind"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 704 - ".taskUpdate"
Cohesion: 0.40
Nodes (5): ColorKind, .base, bg, fg, underline

### Community 708 - "WrapperOptionBehavior"
Cohesion: 0.18
Nodes (10): Burst Coalescing (cmux NotificationBurstCoalescer), CA Mask Pattern (Harness Notch), Combine → CA Bridge, Equality Guard (Zed layout phase), GPU Animation Pattern — Layout Once, GPU Paints, Layer Coordinate System, Principle, References (+2 more)

### Community 709 - "String"
Cohesion: 0.31
Nodes (5): AgyAdapter, Result, ResultLine, String, UUID

### Community 710 - "MainWindowController"
Cohesion: 0.10
Nodes (14): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+6 more)

### Community 711 - "RunState"
Cohesion: 0.18
Nodes (10): AppKit / Views, Architecture / Daemon, Browser / WKWebView, Chrome / Theming / Rendering, Git / Process, Notifications / UserNotifications, RL Lessons — harness-terminal, Swift 6 / Concurrency (+2 more)

### Community 712 - "ResumeStyle"
Cohesion: 0.29
Nodes (5): .assertAllPathsAgree(_:cols:rows:file:line:), StaticString, String, UInt, UInt8

### Community 713 - "AutomationScheduler"
Cohesion: 0.28
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 714 - ".daemonIsStale"
Cohesion: 0.67
Nodes (3): Inspection (CLI / control mode), Local diagnostics, Sessions / workspaces

### Community 715 - "TerminalProgressReport"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 716 - "Pqe"
Cohesion: 0.23
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 718 - ".deleteSavedLayout"
Cohesion: 0.18
Nodes (10): AI-SDLC Task Progress — Agent Swarm Core (Fleet Orchestration), Artifacts, Context, Delegation comparison (running, update after each slice), First live-daemon check (2026-09-14, user request: "turn on dashboard, test real, Remaining (follow-ups, not blocking — this feature's core loop is complete end to end), Review notes (Slice 1, local-ai delegation), Summary (+2 more)

### Community 719 - "ViInputMode"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 720 - "AgentRoutingRuleSummary"
Cohesion: 0.32
Nodes (6): CGFloat, ResizeDirection, down, left, right, up

### Community 721 - "HGe"
Cohesion: 0.10
Nodes (10): MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, String, SurfaceID (+2 more)

### Community 722 - ".configureEnvironment"
Cohesion: 0.27
Nodes (8): LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab, TabID, WorkspaceID

### Community 723 - "Fze"
Cohesion: 0.18
Nodes (10): Cleanup on toggle off / pane close, Design — M3: Browser Design Mode, JS injection (on toggle ON, via `evaluateJS`, not a persistent `WKUserScript` —, Logical Design, Native message handler, Next Step, Popover UI, Strategic Design (+2 more)

### Community 724 - ".detailView"
Cohesion: 0.29
Nodes (6): TerminalColorRole, background, cursor, foreground, palette, UInt8

### Community 726 - ".scan"
Cohesion: 0.31
Nodes (5): Lexer, .atEnd, .peek, Bool, Character

### Community 727 - "PromptQueueBar"
Cohesion: 0.17
Nodes (11): agy, claude, copilot, hermes, __kouen_agy_next, __kouen_claude_next, __kouen_copilot_next, __kouen_hermes_next (+3 more)

### Community 728 - "TerminalHostView"
Cohesion: 0.18
Nodes (5): .snapshot, Bool, String, ThemeService, KouenOptions

### Community 729 - "Lf"
Cohesion: 0.23
Nodes (6): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow

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
Cohesion: 0.16
Nodes (7): Bool, NSObjectProtocol, Set, String, Tab, TabID, WorktreeAutoIsolateService

### Community 735 - "ImageTextureCache"
Cohesion: 0.20
Nodes (5): .effectiveResumeCommand(mode:), RemoteControlURLProvider, Bool, URL, RemoteControlURLProviderTests

### Community 736 - "graphify reference: add a URL and watch a folder"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 737 - ".resolve"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 743 - ".matchingTab"
Cohesion: 0.13
Nodes (3): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess

### Community 744 - "DecodedWSFrame"
Cohesion: 0.20
Nodes (9): Bug #2 — Cmd+\ squeezes the real terminal pane, real sidebar shows black (2026-07-13), Bug #3 — Same squeeze/black symptom, but from a launch-time layout race, not Settings (2026-07-13), Bug — Cmd+\ sidebar toggle gone after collapse, Confirmed facts, Fix, Related, Suspect A — Dead token guard (confirmed code bug), Suspect B — Zero-delta early exit trap (+1 more)

### Community 745 - "p11_scripting.robot"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 746 - ".findSession"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 750 - "ClipboardOSCTests"
Cohesion: 0.25
Nodes (9): kouen.bash script, agy(), claude(), copilot(), hermes(), __kouen_agy_next(), __kouen_claude_next(), __kouen_copilot_next() (+1 more)

### Community 754 - "hmn"
Cohesion: 0.20
Nodes (9): 1. Sidebar toggle (⌘\), 2. File preview open/close, 3. Tab switch (⌘1-9, ✕ close), 4. presentsWithTransaction order fix (ALL remaining flash cases) — v3.9.x+, Fixes Applied (v3.9.1+), Related Lessons, Root Cause Pattern, Rules (+1 more)

### Community 756 - "Consumers"
Cohesion: 0.20
Nodes (9): 1. Board Sidebar Tab (GUI), 2. Harness CLI Command, 3. Scripting API, 4. Read-Only MCP Tool, Agent/Session Board (P16), Centralized Classification, Consumers, Data Model (PBI-BOARD-001) (+1 more)

### Community 759 - "SpecialKey"
Cohesion: 0.22
Nodes (7): HeadlessRunEvent, assistantText, result, sessionID, Bool, Double, String

### Community 762 - ".main"
Cohesion: 0.20
Nodes (5): KouenMCPServer, Bool, String, MCPServer, String

### Community 763 - "Git Panel"
Cohesion: 0.20
Nodes (9): Architecture, Branch chip — CASE-020, Features, FSEvents Pattern (Swift Actor), Git Panel, History → File Editor, Real-time Refresh, v1 — CASE-009 (resolved, superseded) (+1 more)

### Community 768 - ".tabIDsToNotify"
Cohesion: 0.32
Nodes (4): PaneID, SessionGroup, Tab, first

### Community 776 - "DecodedWSFrame"
Cohesion: 0.20
Nodes (3): PipeBuffer, Result, MobileBridgeAISuggestTests

### Community 781 - "Dev Task Progress — P44c + P44d Orchestrator Session Contract + Auto-Fix Loop Safety Bounds"
Cohesion: 0.33
Nodes (5): OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue

### Community 782 - "AI-SDLC Task Progress — P47 Primary Branch Worktree Fix"
Cohesion: 0.33
Nodes (6): h1t(), hae(), jgn(), pwn(), sfn(), _Ue()

### Community 797 - ".sessionID"
Cohesion: 0.29
Nodes (7): AnimatablePair, NotchShape, .animatableData, CGFloat, CGPath, CGRect, Path

### Community 800 - "TabStatus"
Cohesion: 0.20
Nodes (6): LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled

### Community 803 - ".compute"
Cohesion: 0.50
Nodes (5): aze(), cR(), oze(), xGe(), yGe()

### Community 820 - "Fixed"
Cohesion: 0.20
Nodes (9): CodingKeys, cols, createdAt, dataBase64, rows, timeMs, type, version (+1 more)

### Community 834 - "Fixed"
Cohesion: 0.10
Nodes (14): ReflowFastPathTests, .feeds, String, OcclusionTests, NSWindow, String, TimeInterval, String (+6 more)

### Community 867 - "Fixed"
Cohesion: 0.60
Nodes (3): .encode(_:modifiers:event:modes:), SpecialKey, insert

### Community 873 - "Added"
Cohesion: 0.50
Nodes (4): Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions

### Community 897 - "MobileBridgeSpawnTests"
Cohesion: 0.29
Nodes (8): AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand, Bool, Set

### Community 915 - "ResumeStyle"
Cohesion: 0.50
Nodes (4): WriteOutcome, complete, failed, wouldBlock

### Community 978 - "Changed"
Cohesion: 0.15
Nodes (3): AgentHookInstallerCLI, String, String

### Community 979 - "qLt"
Cohesion: 0.11
Nodes (8): Bool, NSDraggingInfo, NSDragOperation, NSPasteboard, URL, NSPasteboard, URL, KouenTerminalSurfaceDragDropTests

### Community 991 - "Changed"
Cohesion: 0.22
Nodes (8): Build order (unchanged from interview decision), G1 — @ file-path picker, G2 — shell tab-completion suggestion strip (heuristic, explicitly best-effort), G3 — AI command suggestion (via `claude` CLI subprocess), Logical Design, P37 Phase G — Autocomplete (mobile bridge), Strategic Design, Tactical Design

### Community 998 - "Changed"
Cohesion: 0.50
Nodes (3): i5e(), ort(), wHt()

### Community 1000 - "Changed"
Cohesion: 0.22
Nodes (8): Artifacts, Client Application — Slice 1 (stacked panes, no persistence), Client Application — Slice 2 (per-workspace divider memory), Context, Dev Task Progress — Workspace Sidebar Panels (P42), Integration, Note on task re-sequencing (2026-07-17), Summary

### Community 1001 - "Changed"
Cohesion: 0.16
Nodes (3): ProjectConfig, Bool, String

### Community 1026 - "Fixed"
Cohesion: 0.50
Nodes (3): PaneID, PaneLeaf, PaneNode

### Community 1079 - "Fixed"
Cohesion: 0.11
Nodes (9): Bool, NSEvent, UInt8, KouenTerminalSurfaceFocusTests, SpecialKeyMappingTests, Bool, NSEvent, String (+1 more)

### Community 1136 - "GroupedSessionDaemonTests"
Cohesion: 0.36
Nodes (4): Bool, String, UUID, TaskDaemonBridge

### Community 1139 - "Fixed"
Cohesion: 0.20
Nodes (7): Kind, input, metadata, output, resize, ReplayStep, Decoder

### Community 1193 - "WorkspaceID"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 1230 - "Notification Sound Toggle Ignored + Banner Click Didn't Navigate"
Cohesion: 0.22
Nodes (8): CASE-063a — sound toggle, CASE-063b — click doesn't route, Files, Fix Applied, If Fix Is Insufficient, Notification Sound Toggle Ignored + Banner Click Didn't Navigate, Root Cause, Symptom

### Community 1303 - ".pushAgentActivityNotifications"
Cohesion: 0.50
Nodes (3): exclude_hubs, no_viz, wiki

### Community 1309 - ".startMetadataRefresh"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 1453 - "Added"
Cohesion: 0.22
Nodes (8): Detection Method, Fix, NSTextField Leak in BoardViewController (P20 Performance), Prevention Rules, Related Files, Root Cause, Symptom, Why CPU Goes Up

### Community 1470 - "Changed"
Cohesion: 0.22
Nodes (8): 1. Self-clear needs a buffer reset on mark, or it can never fire, 2. The real human-keystroke path bypasses the JSON `.sendData` request entirely, 3. `BannerShortcutRegistry.shortcuts` descriptions MUST contain wrap points, 4. Daemon-side `NotificationBus.shared.post(...)` never reaches the GUI process, 5. `kouen context inject`/`@error`/`@last` used a tab's id where a surface id was required, 6. `.onTapGesture` on a `List` row silently does nothing on macOS, 7. `processMonitors`/`noteSurfaceOutput` tests must kill the real background timer first, P46 Pillar 6 — Attention & Fleet Control Hardening (2026-09-21)

### Community 1517 - "Changed"
Cohesion: 0.40
Nodes (3): calculate(), constructor(), mBt

### Community 1577 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.22
Nodes (8): Accessibility Requirements, Files, Permission, Running, Stack, Test Strategy, UI Automation — Robot Framework (P18), Why Not Appium

### Community 1637 - "AppKit + Metal Patterns"
Cohesion: 0.22
Nodes (8): AppKit + Metal Patterns, CADisplayLink Lifetime on macOS (CASE-031), Metal Surface Lifecycle (CASE-003), Mouse Selection Must Use Virtual-Line Coordinates (CASE-029), NSFont Italic (CASE-010), NSView Layer Opacity — Preview Parity Pattern (CASE-011), Overlay Above Metal (CASE-004), Window Background Tint for Legibility (CASE-027)

### Community 1646 - "Split Panes (NSSplitView)"
Cohesion: 0.22
Nodes (8): Architecture, Infinite Recursion (CASE-006), Pane Drag-and-Drop (P27), Ratio Persistence (CASE-002), Split CWD Resolution — Worktree Priority (2026-06-21), Split Panes (NSSplitView), Subview Reorder (CASE-007), Two-Axis Split Parity (P13)

### Community 1692 - "r2"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 1740 - "headless-worker-followup — Phase 2 Architect (Gate 1)"
Cohesion: 0.22
Nodes (8): Context, Decision to confirm, Delivery, Design, headless-worker-followup — Phase 2 Architect (Gate 1), QA coverage (what deserves a test — scenarios in Phase 3), Reuse Table, Verification

### Community 1774 - "M2 — Agent Routing Rule — Task Progress"
Cohesion: 0.22
Nodes (9): Docs, kouen-mcp, KouenApp (Settings UI), KouenCore, KouenDaemon, KouenIPC, M2 — Agent Routing Rule — Task Progress, Tests (+1 more)

### Community 1779 - "Fixed"
Cohesion: 0.17
Nodes (10): Configuration, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, TabContextCommand, close, closeOthers, rename, splitHorizontal (+2 more)

### Community 1832 - "Added"
Cohesion: 0.25
Nodes (7): Claude Code hook push (in-process Task subagent detection), Client UI indicator, Detection core (AgentDetector, pure logic), IPC / Tab plumbing, P38 Phase B — Subagent Visibility — Dev Task Progress, Status: Rewritten 2026-07-14 after original implementation (tasks 1-5) was lost to a concurrent git operation before commit. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 1914 - "P43 — Add Repo/Folder to Workspace"
Cohesion: 0.25
Nodes (7): Original overlay build (built 2026-07-14, gated green, then deleted 2026-07-15 mid live-test), P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress, Pivot — merge into the Recipes picker (2026-07-15), Stage 1-2 — Engine/surface plumbing (built 2026-07-14, unchanged by the pivot, still in use), Status: Implementation pivoted mid-phase from a standalone overlay to a merge into the existing, Summary, Thread grouping — Zed framing folded into the same picker (2026-07-15)

### Community 1922 - "Added"
Cohesion: 0.17
Nodes (10): .block(atPromptLine:), .captureLines(fromLine:toLine:), .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8 (+2 more)

### Community 1930 - "AsyncCLIResultBox"
Cohesion: 0.67
Nodes (3): AsyncCLIResultBox, Error, Result

### Community 1942 - "SpecialKey"
Cohesion: 0.15
Nodes (8): _Bt(), by(), e7e(), fst(), hxn(), lxn(), sBt, XWt()

### Community 1977 - "Added"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: ProjectCategory FolderScanner ProjectDirectoryTree, Source Nodes

### Community 1983 - "CopilotAdapter"
Cohesion: 0.06
Nodes (23): AgentDetection, AgentDetector, AgentTableEntry, MatchSource, ownProcess, wrapperLaunch, RawMatch, Bool (+15 more)

### Community 2014 - "Added"
Cohesion: 0.36
Nodes (7): Document, Bool, Set, String, URL, ToolPolicy, .defaultURL

### Community 2100 - ".handleWake"
Cohesion: 0.17
Nodes (13): .exit, DaemonClient, String, KouenCLI, SessionID, String, Never, SessionGroup (+5 more)

### Community 2176 - "Changed"
Cohesion: 0.29
Nodes (6): Locked decisions (user-confirmed), Logical Design, P38 Phase A — Cross-Agent Worktree Diff/Review Dashboard — Design, Strategic Design, Tactical Design, Verification gate (this phase)

### Community 2181 - "IPC Architecture"
Cohesion: 0.25
Nodes (7): Framing, IPC Architecture, Key Invariant, Overview, Process Separation, Security, Subscriptions

### Community 2182 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.25
Nodes (7): ⌘1-9 and ⌘[ / ⌘] = Session-level navigation (CASE-028), Data Model, Session/Tab/Pane Hierarchy & Top Bar (CASE-028), Sidebar Session Groups = One Header Per SessionGroup, Source Map, Tab Pill Visual Details, Top Bar = 1 Pill Per Session (not per-tab)

### Community 2217 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.25
Nodes (7): Case: cwd "bleed" — session worktree jumps to wrong dir during builds, Companion bug: blank panel on first open (CASE-042), Fix, Lesson, Repro (deterministic, headless — no GUI needed), Root cause, Symptom

### Community 2240 - "Project History"
Cohesion: 0.25
Nodes (7): Apple Platform Context — Transparency & Legibility, Architecture Decisions, iOS/macOS 26 — Liquid Glass introduction, iOS/macOS 27 — Liquid Glass refinements (WWDC 2026), Known Issues (Current), Project History, Sprint Timeline

### Community 2242 - "P42 — Workspace Sidebar Panels"
Cohesion: 0.29
Nodes (6): Logical Design, Next Step, P42 — Workspace Sidebar Panels, Parked (not in scope), Strategic Design, Tactical Design

### Community 2264 - "AI-SDLC Task Progress — headless-worker-followup"
Cohesion: 0.25
Nodes (7): AI-SDLC Task Progress — headless-worker-followup, Artifacts, Context, Phase 1 — Interview (done 2026-09-27), SDLC Workflow Gates, Skill Invocation Log, Tasks

### Community 2269 - "WriteOutcome"
Cohesion: 0.47
Nodes (3): URL, TimeoutError, WorktreeLargeOutputRegressionTests

### Community 2332 - "M5 — Saved Layouts — Task Progress"
Cohesion: 0.25
Nodes (8): Docs, KouenApp, KouenCore, KouenDaemon, KouenIPC, M5 — Saved Layouts — Task Progress, Tests, Verification

### Community 2363 - "Fixed"
Cohesion: 0.27
Nodes (3): DaemonReconnectPolicy, TimeInterval, DaemonReconnectPolicyTests

### Community 2483 - "gmn"
Cohesion: 0.50
Nodes (5): ehn(), gmn(), Jc(), pce(), s7e()

### Community 2541 - "P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable"
Cohesion: 0.17
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 2573 - "P38 Phase D — Kitty Graphics Conformance Slice"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase D — Kitty Graphics Conformance Slice, Scope (locked), Tests

### Community 2628 - "Command Prompt Architecture"
Cohesion: 0.29
Nodes (6): Command Prompt Architecture, Files, Gotchas, Key rule: every documented verb needs BOTH layers, Layers, Verb categories

### Community 2633 - "P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua)"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua), Scope (locked), Tests

### Community 2642 - "P43 — Add Repo/Folder to Workspace"
Cohesion: 0.33
Nodes (5): Logical Design, Next Step, P43 — Add Repo/Folder to Workspace, Strategic Design, Tactical Design

### Community 2676 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.29
Nodes (6): Anti-Patterns Avoided, Architecture, Key Design Decisions, Pattern, Service Decomposition — SessionCoordinator (P17), When to Apply This Pattern

### Community 2735 - "Browser Tab Close Button Unresponsive"
Cohesion: 0.29
Nodes (6): Browser Tab Close Button Unresponsive, Files, Fix Applied, If Fix Is Insufficient, Root Cause, Symptom

### Community 3131 - "P38 Phase D — Kitty Conformance — Dev Task Progress"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 3132 - "P38 Phase E — Scripting Hooks — Dev Task Progress"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 3862 - "P8 macOS27 adoption — Liquid Glass chrome regressions (2026-07-25/26)"
Cohesion: 0.29
Nodes (6): 1. Transparency pipeline hardcoded off, 2. Chrome tint double-composited over the window's own tint, 3. One chrome strip not routed through the shared ChromeBackdrop system, 4. Accessibility contrast floor corrupting ANSI/pixel-art content, Cross-cutting, P8 macOS27 adoption — Liquid Glass chrome regressions (2026-07-25/26)

### Community 3863 - "CASE — Git / FS / Terminal / Architecture"
Cohesion: 0.29
Nodes (6): Architecture / Keybindings, CASE — Git / FS / Terminal / Architecture, Claude Code / Tooling / Environment (the agent running *inside* Harness), Command Prompt / Parser, Git / File System, Terminal / Renderer / Daemon

### Community 3864 - "ACP Client (Shelved)"
Cohesion: 0.29
Nodes (6): ACP Client (Shelved), Architecture (Preserved), Re-enablement Criteria, Status: SHELVED (June 2026), What It Is, Why Shelved

### Community 3865 - "Build Scripts Self-Kill Protection"
Cohesion: 0.29
Nodes (6): Build Scripts Self-Kill Protection, Detection, Fix (applied in `Scripts/run.sh`), Key Invariant, Problem, Related

### Community 3873 - "File Tree: New File/Folder invisible inside an already-expanded subfolder"
Cohesion: 0.33
Nodes (5): File Tree: New File/Folder invisible inside an already-expanded subfolder, Fix (2026-08-19), Prevention, Root cause, Symptom

### Community 3874 - "FSEvents Recursive Watcher Pattern (Swift)"
Cohesion: 0.33
Nodes (5): Codex Fix Prompt Template, FSEvents Recursive Watcher Pattern (Swift), Full Swift Actor Pattern, Single-file watch (DispatchSource is enough), When to use

### Community 3875 - "Foundation `Process`/`Pipe` deadlock pattern — stuck/"zombie" subprocesses"
Cohesion: 0.33
Nodes (5): Fix pattern (applied 2026-08-19 to `GitStatusProvider.swift`, `SidebarListModel.swift`,, Foundation `Process`/`Pipe` deadlock pattern — stuck/"zombie" subprocesses, Prevention, Symptom, Two independent failure modes, both from the same `Process`+`Pipe` API misuse

### Community 3876 - "M3 — Browser Design Mode — Task Progress"
Cohesion: 0.33
Nodes (6): Docs, Environment fix discovered this session (not part of M3's diff — `.build/` is gitignored), KouenApp — BrowserPaneView.swift, M3 — Browser Design Mode — Task Progress, Tests, Verification

### Community 3877 - "Design — M4: Fork Conversation"
Cohesion: 0.33
Nodes (5): Design — M4: Fork Conversation, Logical Design, Next Step, Strategic Design, Tactical Design

### Community 3878 - "M8 — Merge Waiver — Task Progress"
Cohesion: 0.33
Nodes (6): Docs, KouenApp, KouenCore — GitHubCLIClient.swift, M8 — Merge Waiver — Task Progress, Tests, Verification

### Community 3880 - "AgentBadgeView"
Cohesion: 0.22
Nodes (5): aD(), crn, ELt(), n2e(), urn

### Community 3884 - "M4 — Fork Conversation — Task Progress"
Cohesion: 0.40
Nodes (5): Docs, KouenApp — MainMenuBuilder.swift, M4 — Fork Conversation — Task Progress, Tests, Verification

### Community 3885 - "M6 — Risky Command Advisory — Task Progress"
Cohesion: 0.40
Nodes (5): Docs, KouenApp, M6 — Risky Command Advisory — Task Progress, Tests, Verification

### Community 3886 - "M7 — Request Peer Review — Task Progress"
Cohesion: 0.40
Nodes (5): Docs, KouenApp — MainMenuBuilder.swift, M7 — Request Peer Review — Task Progress, Tests, Verification

### Community 3887 - "M9 — Slash Command Picker — Task Progress"
Cohesion: 0.40
Nodes (5): Docs, KouenApp — ComposerPanel.swift, M9 — Slash Command Picker — Task Progress, Tests, Verification

### Community 3896 - "Motion"
Cohesion: 0.06
Nodes (40): ButtonStyle, CommandRow, .body, GlassCard, .body, GlassPrimaryButtonStyle, GlassSecondaryButtonStyle, GlassSmallButtonStyle (+32 more)

## Knowledge Gaps
- **3990 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+3985 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **2359 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `PerformanceBenchmarks` to `ThemeDocument`, `graphify reference: extra exports and benchmark`, `EngineConformanceTests`, `IPCRequest`, `AgentNotchRootView`, `.jumpToBlock`, `LSPMessage`, `TerminalEmulator`, `.encode`, `TabContextCommand`, `VTParser`, `HarnessTerminalSurfaceView`, `.applyPreedit`, `MetalRendererTests`, `HarnessUILibrary`, `SpecialKey`, `HarnessChrome`, `.init`, `.sessionID`, `.readGrid(scrollbackOffset:)`, `NSObject`, `SessionGroupHeaderRowView`, `WorktreeManager`, `.parse`, `.init`, `.request`, `Sendable`, `.addTab`, `Equatable`, `.bufferLine`, `.characterIndex`, `RGBColor`, `CodingKeys`, `TerminalColorGamut`, `CodingKeys`, `HarnessSidebarPanelViewController.swift`, `RenderSchedulerTests`, `.viewWillMove`, `.normalizedKey`, `.keyEvent`, `ReleaseNotesGuardTests`, `TabCell`, `CommandHistorySearchController`, `3.2 สิ่งที่ implement แล้ว`, `ShellIntegrationTests`, `FrecencyDirectoryStore`, `ComposedCell`, `.toastErrorSummary`, `HarnessCLI+Server.swift`, `PasteBufferStore`, `ShellIntegration`, `TaskDashboardBody`, `Completed Plans Archive`, `worktree_isolation_cli.robot`, `.parse`, `TerminalProtocolCompatibilityTests`, `Endpoint`, `HarnessDesign`, `.firstMatch`, `TerminalGridCell`, `HarnessPaths`, `PaletteWindowDelegate`, `AttachInputBatcher`, `shim.c`, `PaneContainerView`, `.installCLI`, `.dispatch`, `ScriptRuntime.swift`, `Session Grouping and Split Session Plan`, `MainSplitViewController`, `DaemonLauncher`, `Recipe`, `4. Technical Architecture`, `domain-design.md`, `AnyCodable`, `.resolve`, `DamageTrackingTests`, `SoftIconButton`, `code:text (:workbench start swift)`, `.makeSnapshot`, `[2.5.0] - 2026-06-12`, `.firstWaitingTab`, `.encode`, `Fixed`, `Pipe`, `String`, `HistoryRingBuffer`, `ClientSummary`, `GlyphAtlas`, `code:block1 (SessionCoordinator.snapshot ──┐)`, `SwiftUI`, `CommandTarget`, `.startWatching`, `PtyDrainCeilingBenchmark`, `.testPaneLeafLegacyDecodeBackfillsSurfaceTabs`, `How to use Harness from the terminal only (no GUI)`, `PaneStyleSet`, `AsciiFastPathTests`, `DecodedImage`, `FileTreeWatcher`, `LiveResizeTests`, `Int`, `ThaiCombiningMarkTests`, `r2`, `Harness Terminal — IDE Sidebar Feature Branch`, `MatchCategory`, `What You Must Do When Invoked`, `TerminalFindBar`, `CommandPromptController`, `ActiveTabCloseDisposition`, `AgentTableEntry`, `URLDetection`, `.decodeKeySpec`, `[1.5.1] - 2026-06-06`, `BinaryRefresherTests`, `InlineAICompletionView`, `[3.13.1] - 2026-07-02`, `.control`, `GridCompositorTests`, `SessionSnapshot`, `LayoutProbeView`, `AppDelegate`, `main.swift`, `user-stories.md`, `.taskUpdate`, `GlyphRasterizer`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `BinaryInstaller`, `.classify`, `ResumeStyle`, `[3.9.5] - 2026-06-26`, `scheduleRender`, `.testDataFrameEncodeVsJSONBase64Output`, `AgentRoutingRuleSummary`, `ViInputMode`, `PaneTarget`, `.detailView`, `HintModeOverlay`, `.scan`, `.lines`, `.configureEnvironment`, `ScrollbackFile`, `TerminalServicesProvider`, `ThaiGrid`, `WriteOutcome`, `SSHTunnelManagerTests`, `ExternalOpenKind`, `WorkbenchCommand`, `PaneBorderStatus`, `[3.5.1] - 2026-06-20`, `AgentBridge`, `ym`, `ThemeDocumentTests`, `ReflowPreviewTests`, `SessionCoordinator`, `Split Right`, `BoardViewController`, `release-hotfix.sh`, `workspace`, `.tabIDsToNotify`, `WindowTitleStripView`, `ThemeFileServiceTests`, `.welcome`, `HarnessSidebarPanelViewController`, `.path`, `Dev Task Progress — P44c + P44d Orchestrator Session Contract + Auto-Fix Loop Safety Bounds`, `DefaultTerminalManager`, `WindowSession`, `KeySpec`, `[2.5.0] - 2026-06-12`, `DisplayPanesOverlay`, `.menu`, `TerminalScrollbarView`, `FormatColor`, `click_ui_element`, `After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md.`, `code:bash (harness-cli install-hooks hermes)`, `AgentHookStrategy`, `StatusLineWidthTests`, `Process`, `JSONDecoder`, `Fixes Applied (layered)`, `GitHubCLIClient`, `settings.json`, `PaneNode`, `HarnessPaths.swift`, `ViPathTokenTests`, `Send Ex Command`, `Bug: Tab-Switch Black Screen`, `AgentSnapshot`, `Terminal AI Chat (⌘I inline overlay)`, `Fixed`, `DesktopNotifier`, `LayoutNode`, `Fixed`, `worktree_isolation.robot`, `.theme`, `README.md`, `.drawGlyph`, `Added`, `CommandExecutionError`, `CSIParams`, `Foundation`, `code:bash (harness-cli install-hooks openclaw)`, `Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)`, `P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)`, `.handleCat`, `[3.5.1] - 2026-06-20`, `FormatStyledSegment.swift`, `RGBColor`, `generate-cheatsheet.js`, `Fixes Applied (v3.9.1+)`, `Consumers`, `Git Panel`, `.encode`, `ScrollReuseTests`, `Identifiable`, `SurfaceProgressTrackerTests.swift`, `NSTextField Leak in BoardViewController (P20 Performance)`, `Added`, `User Profile`, `Darwin`, `HarnessCLITests`, `AsyncCLIResultBox`, `.init`, `PresentAttempt`, `Split Panes (NSSplitView)`, `AgentIconRenderer`, `main.swift`, `.tabIndex(tabID:)`, `IPC Architecture`, `Session/Tab/Pane Hierarchy & Top Bar (CASE-028)`, `.setCellPixelSize`, `Fixed`, `markdown.json`, `rust.json`, `RealPtyLifecycleTests`, `yaml.json`, `.selectAdjacentSession`, `HintModeOverlay`, `SixelDecoder`, `.currentSize`, `.navigateCurrentFile`, `Case: cwd "bleed" — session worktree jumps to wrong dir during builds`, `Competitive Position (as of v3.12.0, 2026-07-02)`, `BoardCardView`, `PathToken`, `SessionEditor`, `GroupedSessionDaemonTests`, `main.swift`, `CopilotAdapter`, `SessionCoordinator.swift`, `.recordReapedGenerationForTesting`, `.init`, `ReflowFastPathTests`, `.resize`, `DispatchTime`, `HarnessOnboarding`, `Changed`, `.hitTest`, `Added`, `ScrollbackTests`, `Command Prompt Architecture`, `.bind`, `.routingRuleList`, `.json`, `Build Scripts Self-Kill Protection`, `SwarmFleetBody`?**
  _High betweenness centrality (0.211) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `Terminal AI Chat (⌘I inline overlay)` to `AgentSessionSummary.swift`, `.handleCat`, `worktree_isolation_cli.robot`, `.agentName`, `Changelog`, `PerformanceBenchmarks`, `RenderSchedulerTests`, `.id`, `Consumers`, `.testDataFrameEncodeVsJSONBase64Output`, `.encode`, `FileTreeWatcher`, `PaneNode`, `code:bash (harness-cli install-hooks pi)`, `Identifiable`?**
  _High betweenness centrality (0.178) - this node is a cross-community bridge._
- **Why does `fbt()` connect `callingPaneTarget` to `Changelog`, `LSPClient`, `TriState`, `CopyModeAction`?**
  _High betweenness centrality (0.098) - this node is a cross-community bridge._
- **Are the 18 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `RenderScheduler`) actually correct?**
  _`KouenTerminalSurfaceView` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _4010 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.10588235294117647 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.015161235138140449 - nodes in this community are weakly interconnected._