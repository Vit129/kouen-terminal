# Graph Report - kouen-terminal  (2026-10-07)

## Corpus Check
- 876 files · ~993,899 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 21357 nodes · 56249 edges · 3991 communities (1576 shown, 2415 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8243 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `583e9e7f`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 342 edges
2. `i()` - 321 edges
3. `a()` - 284 edges
4. `t()` - 253 edges
5. `SessionCoordinator` - 235 edges
6. `TerminalEmulator` - 229 edges
7. `u()` - 219 edges
8. `SurfaceRegistry` - 217 edges
9. `KouenCLI` - 213 edges
10. `DaemonClient` - 212 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 185 areas (208 edges)
2. `Command` - bridges 102 areas (108 edges)
3. `AgentKind` - bridges 81 areas (167 edges)
4. `t()` - bridges 78 areas (253 edges)
5. `IPCResponse` - bridges 77 areas (103 edges)
6. `KouenPaths` - bridges 74 areas (149 edges)
7. `KouenTerminalSurfaceView` - bridges 72 areas (342 edges)
8. `SurfaceRegistry` - bridges 69 areas (217 edges)
9. `KouenGridTerminal` - bridges 66 areas (117 edges)
10. `SessionCoordinator` - bridges 65 areas (235 edges)

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

## Communities (3991 total, 2415 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.05
Nodes (35): AgentBrowserPaneTracker, SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, SessionID (+27 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.04
Nodes (64): ake(), aoe(), aXe(), b2t(), b6(), bee(), bR(), cvn() (+56 more)

### Community 2 - ".handleNormal"
Cohesion: 0.10
Nodes (15): tab, .addSurface(tabID:paneID:), .tab(containingPaneID:), .tab(for:), .tabIndex(surfaceKey:), .tabIndex(workspaceID:tabID:), Bool, Date (+7 more)

### Community 3 - "Changed"
Cohesion: 0.08
Nodes (22): IndexingIterator, LayoutTemplate, surfaceID, SessionEditor, .addSurface(to:paneID:surfaceID:cwd:), .split(node:targetPaneID:direction:paneCount:before:), .split(node:targetPaneID:with:direction:beforeTarget:), .surfaceID(forPaneID:) (+14 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.06
Nodes (23): ClaudeCodeHarnessIPCTests, String, URL, IPCCodecInvariantTests, ConcurrentIndexSet, .count, DaemonContentionTests, String (+15 more)

### Community 5 - "IPCRequest"
Cohesion: 0.06
Nodes (30): .start(onResponse:onEnd:), Int32, String, TimeInterval, UInt16, UUID, Void, Data (+22 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.10
Nodes (25): AnyTransition, AgentNotchPeekEvent, AgentNotchRootView, .body, .bottomRadius, .closedAccessibilityLabel, .closedTransition, .closedView (+17 more)

### Community 7 - "Command"
Cohesion: 0.09
Nodes (31): AppEnum, AppIntent, AppIntents, GetTerminalOutputIntent, KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound (+23 more)

### Community 8 - "LSPMessage"
Cohesion: 0.37
Nodes (3): .block(atPromptLine:), String, TerminalBlockStoreTests

### Community 9 - "TerminalEmulator"
Cohesion: 0.11
Nodes (11): .agentColorBinding, colors, PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Double, String (+3 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.04
Nodes (49): CGImage, DecodedImage, .byteCount, ImageLimits, Bool, UInt8, ImageDecoder, Bool (+41 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.13
Nodes (15): clamp(), Date, Never, SplitDirection, T, TabID, Task, Void (+7 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.12
Nodes (29): br(), checkbox(), codespan(), constructor(), de(), del(), html(), image() (+21 more)

### Community 14 - "VTParser"
Cohesion: 0.15
Nodes (9): StringKind, apc, dcs, UInt8, UnsafeBufferPointer, VTParser, .feed(_:), VTParserHandler (+1 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.11
Nodes (15): DaemonCommandExecutor, Command, BellScanState, esc, normal, stringEsc, SurfaceMonitor, SurfaceRegistry (+7 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.14
Nodes (6): Run, String, TerminalBanner, WelcomeConfig, String, TerminalBannerTests

### Community 17 - "MetalRendererTests"
Cohesion: 0.08
Nodes (29): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, .body, PaletteMode (+21 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.10
Nodes (22): DaemonSubscription, .start(onData:onEnd:buffered:), Bool, UInt64, UnsafeMutableRawPointer, sysRead(), DaemonClientTests, FrameRecorder (+14 more)

### Community 19 - "SpecialKey"
Cohesion: 0.10
Nodes (18): Darwin, Foundation, Glibc, KouenCore, KouenDaemonCore, ensureDirectories(), T, withFileLock() (+10 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.20
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.04
Nodes (131): a6(), aJ(), Ame(), aQ(), aQt(), aUe(), aXt(), AYt() (+123 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.01
Nodes (636): _0t(), _1n(), _3e(), _3n(), _4e(), _5e(), _5n(), _6e() (+628 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.09
Nodes (23): OptionStore, OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Scope, global (+15 more)

### Community 24 - ".request"
Cohesion: 0.09
Nodes (18): .init(coder:), BrowserProgressLine, .init(coder:), .init(frame:), BrowserTabButton, .init(coder:), DesignModePopoverViewController, .init(coder:) (+10 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.16
Nodes (8): TerminalGridCell, TerminalGridSnapshot, Case, ReflowCorpusTests, .corpus, .goldenDir, String, URL

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.30
Nodes (5): SettingsAdvancedView, .body, Bool, String, SwiftUI

### Community 27 - "RGBColor"
Cohesion: 0.15
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 28 - ".parse"
Cohesion: 0.09
Nodes (25): #attention-btn, #attention-btn-text, #btn-toggle-wait, #content-tab-1, #content-tab-2, #content-tab-3, #desktop-notif, #dock-badge (+17 more)

### Community 30 - "Notification"
Cohesion: 0.09
Nodes (12): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), Bool, Never, Task, UUID (+4 more)

### Community 31 - "Sendable"
Cohesion: 0.14
Nodes (12): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+4 more)

### Community 32 - ".addTab"
Cohesion: 0.09
Nodes (22): FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body, .emptyState (+14 more)

### Community 33 - "Equatable"
Cohesion: 0.09
Nodes (20): AnyObject, DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor (+12 more)

### Community 34 - "DaemonClient"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 35 - "MenuTarget"
Cohesion: 0.05
Nodes (22): Bool, NSObjectProtocol, String, TabID, WorktreeAutoIsolateService, Range, String, TerminalGridCell (+14 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.14
Nodes (28): Cleanup Test Repo, Close Isolated Session Keeps Dirty Worktree, Close Isolated Session Removes Clean Worktree, Close One Isolated Does Not Affect Another, Close Session With Split Panes Removes Worktree, Create Isolated Session, Create Isolated Session Via CLI, Get Active Pane (+20 more)

### Community 37 - "String"
Cohesion: 0.08
Nodes (23): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSEvent (+15 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.19
Nodes (12): BrowserOkAck, ConnectionState, .authorized, .browserPaneID, .deviceID, .snapshotSubscription, .subscription, .surfaceID (+4 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.02
Nodes (290): a(), b(), c(), d(), e(), f(), g(), h() (+282 more)

### Community 41 - "CodingKeys"
Cohesion: 0.08
Nodes (26): ClientRecord, CountBox, DaemonServer, .guiBrowserFD, PendingBrowserRequest, PendingWrite, .remaining, Bool (+18 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.14
Nodes (18): CommandParseError, .description, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand (+10 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.14
Nodes (9): Process, SSHTunnelManager, .init(makeTunnelProcess:reachabilityProbe:), Bool, URL, Tunnel, SSHTunnelManagerTests, String (+1 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.10
Nodes (12): Bool, String, UInt8, TerminalEmulator, .captureLines(fromLine:toLine:), .onResponse, .onSetClipboard, TerminalColorRole (+4 more)

### Community 48 - "HookEvent"
Cohesion: 0.13
Nodes (14): Executor, Hook, HookEvent, HookRegistry, Bool, Command, URL, UUID (+6 more)

### Community 49 - "DaemonServer"
Cohesion: 0.08
Nodes (14): KouenTerminalKit, NSDraggingInfo, NSDragOperation, PasteController, Bool, NSPasteboard, String, TimeInterval (+6 more)

### Community 51 - ".keyEvent"
Cohesion: 0.11
Nodes (26): ColorKind, .base, bg, fg, underline, CompositorPane, GridCompositor, .render(panes:status:statusSegments:) (+18 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.11
Nodes (13): CommandIPCTranslator, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID, PaneLeaf (+5 more)

### Community 55 - "TabCell"
Cohesion: 0.14
Nodes (7): AnyCodable, JSONRPCError, .init(client:subscriptionClient:controlEnabled:), Int32, Pipe, String, ToolRegistry

### Community 56 - "NSPanel"
Cohesion: 0.12
Nodes (3): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess

### Community 57 - "BellScanState"
Cohesion: 0.09
Nodes (19): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+11 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.11
Nodes (32): MTLClearColor, MTLCommandBuffer, MTLRenderCommandEncoder, BgInstance, CursorCacheKey, .invertsGlyph, DecoInstance, EncodedFrameInstances (+24 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.07
Nodes (36): ArtifactKind, html, image, markdown, text, AutomationsFleetModel, .load(detectScheduledRuns:), AutomationSource (+28 more)

### Community 60 - "ViEngine"
Cohesion: 0.02
Nodes (361): pe(), r, X(), A(), code(), R(), a(), ae() (+353 more)

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
Cohesion: 0.05
Nodes (50): AgentChipView, .init(coder:), .init(frame:), .intrinsicContentSize, ChromeBackdrop, .init(coder:), .init(role:), ChromeRole (+42 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.13
Nodes (12): NWEndpoint, DecodedWSFrame, MobileBridgeServer, Bool, NWListener, String, UInt16, UInt8 (+4 more)

### Community 67 - "String"
Cohesion: 0.14
Nodes (15): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+7 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.05
Nodes (44): AgentBridge, AgentTarget, Bool, String, SurfaceID, .onCurrentCWD, .onCurrentFile, LinePos (+36 more)

### Community 69 - ".compose"
Cohesion: 0.12
Nodes (12): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, input (+4 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.08
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
Cohesion: 0.08
Nodes (25): 10. Universal retire-hold via `removeFromSuperview()` override (definitive), 11. NSEvent local monitor installed in AppDelegate (fix #8 actually deployed), 12. `nonisolated` + `MainActor.assumeIsolated` on high-frequency AppKit callbacks (2026-06-21), 1. `TerminalPaneRegistry.retire()` — deferred dealloc (500ms), 2. Remove `nonisolated` from all layout overrides, 3. Remove `MainActor.assumeIsolated` from callbacks, 4. Detach NSHostingView on teardown (FileTreeSwiftUIView), 5. Avoid `Optional.map {}` in @MainActor code (+17 more)

### Community 76 - ".parse"
Cohesion: 0.16
Nodes (11): Equatable, PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab (+3 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.15
Nodes (6): .selectWorkspace(_:), Double, PaneID, PaneNode, SurfaceID, TabID

### Community 79 - "HarnessDesign"
Cohesion: 0.13
Nodes (13): MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem, SessionGroup (+5 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 82 - ".firstMatch"
Cohesion: 0.08
Nodes (12): .receive(_:), DispatchSemaphore, FluidityBenchmarks, NSWindow, String, UInt64, KouenTerminalSurfaceWorkerTests, Bool (+4 more)

### Community 83 - "LSPClient"
Cohesion: 0.08
Nodes (23): Error, LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed, serverNotExecutable, AsyncStream (+15 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.06
Nodes (29): OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, .event(_:), .interval(_:_:), Bool (+21 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.07
Nodes (29): LSPFileSession, Never, String, Task, URL, Void, .lspPosition(for:), object (+21 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.12
Nodes (11): FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect, String, URL (+3 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.10
Nodes (15): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+7 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.09
Nodes (21): 2026-07-26 monthly refresh (last ~30 days only, 3 parallel research agents), Agent Swarm Core (P44 follow-on) — honest gap-check, 2026-09-14, AI-IDE landscape (adjacent category — editors, not terminals), Closed 2026-07-11 (P39 phases A–D — build/test green, live-hardware check still owed on each), Competitive Position (as of v4.10.0, 2026-08-06), Deep web research refresh (2026-07-11, 3 parallel research passes), Feature Matrix (2026-07-11), Feature Matrix — M2-M9 additions (2026-08-06) (+13 more)

### Community 89 - ".cursorPos"
Cohesion: 0.13
Nodes (5): .setupPrompt, hooks, AgentHookInstallerTests, String, URL

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.10
Nodes (11): CKouenSys, pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal (+3 more)

### Community 91 - "TerminalModes"
Cohesion: 0.09
Nodes (21): Agent Swarm Core — Fleet Orchestration (20–50 Agents), Context, Daemon: headless surface creation — CORRECTED during Slice 3 (2026-09-14), DAG signal for the Claude adapter specifically, Data model, Delta + coalesced push (not full-snapshot-per-status-change), Extended OSC 26 protocol (Lane B only) — Slice 3 implemented `identity=`/`status=` only, Lane A — Structured workers (Claude Code today, Codex/Agy/Copilot later): (+13 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.16
Nodes (8): DataBox, FlippedView, .isFlipped, GitResult, Bool, ValidateOutcome, CoreServices, GitPanelViewToastErrorSummaryTests

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.09
Nodes (17): AgentSessionPlacement, background, cloud, local, remoteControl, vscode, .effectiveResumeCommand(claudeMode:), LiveClaudeAgentEntry (+9 more)

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
Cohesion: 0.21
Nodes (4): AgentTableEntry, Bool, Set, String

### Community 98 - "4. Technical Architecture"
Cohesion: 0.17
Nodes (3): KouenSettingsTests, URL, Void

### Community 99 - ".dispatch"
Cohesion: 0.09
Nodes (26): Tab, FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID (+18 more)

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
Cohesion: 0.17
Nodes (8): AgentListFormatter, Date, String, dvn(), AgentListFormatterTests, Bool, Date, String

### Community 106 - "domain-design.md"
Cohesion: 0.13
Nodes (10): ScrollbackFile, .highWater, Bool, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.10
Nodes (19): 1. Git Worktree Management, 2. Multi-Agent Orchestration, 3. Mobile Companion Sync, 4. Tech Stack, 5. Other Notable Design Decisions, Additional Takeaway, cmux (manaflow-ai/cmux, github.com/manaflow-ai/cmux) — open source (Swift/Rust, ELv2-style OSS), no shipped worktree lifecycle feature, Comparison Table (+11 more)

### Community 108 - ".resolve"
Cohesion: 0.13
Nodes (12): ShellLaunchProfile, .argv, ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID (+4 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.13
Nodes (8): SGRMouse, SGRMouseEvent, Bool, PaneRect, UInt8, SGRMouseTests, String, UInt8

### Community 110 - "SoftIconButton"
Cohesion: 0.18
Nodes (6): CopyModeReducerTests, FakeGrid, .totalLines, Set, String, TerminalGridCell

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.09
Nodes (13): HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor, Bool, ClosedRange, Range (+5 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.21
Nodes (11): .activeTab, .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), .webView(_:didFinish:), BrowserTab, UUID, WKNavigationAction, WKWebView (+3 more)

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.09
Nodes (27): .windowSection, CaseIterable, KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:), ResizeOverlayMode, afterFirst, always (+19 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.13
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 115 - ".encode"
Cohesion: 0.06
Nodes (32): CustomEndpointTester, Result, Bool, String, URL, ModelKeyStore, Bool, String (+24 more)

### Community 116 - "SessionGroup"
Cohesion: 0.22
Nodes (8): AgentRoutingRule, AgentRoutingRuleStore, Bool, String, URL, UUID, AgentRoutingRuleStoreTests, URL

### Community 117 - "PaneNode"
Cohesion: 0.11
Nodes (10): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+2 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.09
Nodes (25): bNt(), bu(), cNt(), dNt(), eNt(), eRe(), fNt(), h0t() (+17 more)

### Community 119 - "Harness command reference"
Cohesion: 0.14
Nodes (14): Agent safety CLI (`kouen-cli`), Attaching from a plain terminal, Bindings, Buffers (paste store), Composition, Hooks, Kouen command reference, Modes (+6 more)

### Community 122 - "ViEngine"
Cohesion: 0.05
Nodes (24): KouenCLITests, URL, CLIInstallLocator, DetachKeys, absent, invalid, parsed, OptionalUUID (+16 more)

### Community 123 - "Pipe"
Cohesion: 0.18
Nodes (8): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController

### Community 124 - "String"
Cohesion: 0.13
Nodes (3): KittyKeyboardTests, String, UInt8

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, S (+2 more)

### Community 126 - ".path"
Cohesion: 0.08
Nodes (29): AgentArt, AgentMark, .body, AgentMarkShape, AgentVectorIcon, Scanner, .atEnd, SVGPath (+21 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.11
Nodes (22): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), GlyphKey (+14 more)

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.09
Nodes (20): Coordinator, DiffAnalysis, DiffFileItem, DiffFileStatus, added, .color, deleted, modified (+12 more)

### Community 129 - "SwiftUI"
Cohesion: 0.12
Nodes (12): FilePreviewCoordinator, FileTabID, Set, SplitDirection, String, FileTab, .title, FileTabManager (+4 more)

### Community 131 - ".install"
Cohesion: 0.13
Nodes (15): PendingVersionBanner, welcome, whatsNew, State, Bool, String, URL, VersionBannerStore (+7 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.11
Nodes (16): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, BranchSwitchHelper, Notification.Name (+8 more)

### Community 133 - ".load"
Cohesion: 0.17
Nodes (5): .snapshot, Bool, String, ThemeService, KouenOptions

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.17
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 135 - "CommandTarget"
Cohesion: 0.10
Nodes (19): DiffLineType, added, deleted, modified, Notification.Name, NSCoder, NSObjectProtocol, NSRect (+11 more)

### Community 136 - ".startWatching"
Cohesion: 0.06
Nodes (40): CommandTarget, Command, .targetKind, PaneRef, bottom, byID, byIndex, last (+32 more)

### Community 137 - "ActivePaneService"
Cohesion: 0.11
Nodes (13): constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore, SHA256Mini, Bool, Date, String, TimeInterval (+5 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.09
Nodes (7): SessionCoordinator, Bool, SessionID, SplitDirection, String, UUID, WorkspaceID

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.06
Nodes (36): AgentIconArt, AgentVectorIcon, Bool, CGSize, String, AgentIconRenderer, Scanner, .atEnd (+28 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.13
Nodes (14): CompletionPopupView, .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:), .isHovered, Bool (+6 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.06
Nodes (40): .pairedAlreadyBanner, .pairingQRPanel, .sidebarEmptyView, IssueKeychainStore, Bool, String, IssuePriority, .color (+32 more)

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.13
Nodes (13): DetachedPaneOverlay, .init(coder:), .init(frame:style:), Style, detached, reconnectingChip, NSCoder, NSEvent (+5 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.21
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 146 - "DecodedImage"
Cohesion: 0.08
Nodes (18): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+10 more)

### Community 147 - "FileTreeWatcher"
Cohesion: 0.17
Nodes (8): AgentDetection, AgentDetector, Date, Int32, TimeInterval, ProcessScan, Int32, AgentSnapshot

### Community 148 - "TriState"
Cohesion: 0.08
Nodes (12): o, AI(), aZ(), ck(), cy(), e0(), eie(), eZ() (+4 more)

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
Cohesion: 0.08
Nodes (25): Array, GroupHeaderRow, .body, PickerItem, .groupLabel, historyBlock, .id, recipe (+17 more)

### Community 155 - "Int"
Cohesion: 0.14
Nodes (11): FileFuzzyMatcher, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool, Character (+3 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.08
Nodes (25): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, .acceptsFirstResponder (+17 more)

### Community 157 - "Added"
Cohesion: 0.16
Nodes (4): l8e(), $Rt(), tJe(), YUt

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.19
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 159 - "MatchCategory"
Cohesion: 0.16
Nodes (12): ANSIPalette, CellColorResolver, MochaTheme, ResolvedCellColors, .init(hex:), .init(red:green:blue:alpha:), Bool, Double (+4 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.13
Nodes (18): NSEvent, WorktreeCardView, FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:) (+10 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.14
Nodes (11): PairingBox, .current, .isLockedOut, PendingPairing, Date, TimeInterval, TokenCheck, accepted (+3 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.08
Nodes (18): NSResponder, NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent (+10 more)

### Community 163 - "Workspace"
Cohesion: 0.11
Nodes (19): BinaryInstaller, .bundledMacOSDir, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, InstallError, .errorDescription (+11 more)

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
Cohesion: 0.10
Nodes (36): .resolvedGitStatus, AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem (+28 more)

### Community 170 - "URLDetection"
Cohesion: 0.09
Nodes (10): Bool, Range, Set, String, URLDetection, CGFloat, CGRect, Range (+2 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.14
Nodes (15): AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide, noop, show, NSColor (+7 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.14
Nodes (13): GridCompositor, Configuration, Int32, SessionGroup, SessionID, Tab, TabID, WorkspaceID (+5 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.12
Nodes (8): KouenDaemonTools, SpawnedAgentSurface, Bool, PaneLeaf, Result, String, Tab, UUID

### Community 175 - "RGBColorTests"
Cohesion: 0.23
Nodes (8): SettingsRemoteView, .body, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, NSImage, String

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
Cohesion: 0.16
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 181 - "GridCompositorTests"
Cohesion: 0.18
Nodes (5): CompositorPane, GridCompositorTests, Bool, String, TerminalGridSnapshot

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
Cohesion: 0.17
Nodes (10): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+2 more)

### Community 188 - "BrowserPaneView"
Cohesion: 0.12
Nodes (18): Motion, .entrance, .spring, .standardEase, CAMediaTimingFunction, KouenOnboarding, Bool, ImmersiveOnboardingWindowController (+10 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.18
Nodes (8): PaneID, SurfaceID, Tab, TabID, BrowserPaneReuseScopeTests, PaneNode, Tab, TabID

### Community 190 - "user-stories.md"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.09
Nodes (15): PluginLoader, String, ScriptAPI, ScriptError, .errorDescription, evaluationError, unsupportedPlatform, ScriptRuntime (+7 more)

### Community 192 - "GlyphRasterizer"
Cohesion: 0.08
Nodes (24): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+16 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.16
Nodes (12): UInt16, TTYSize, RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal (+4 more)

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.05
Nodes (40): FileNode, GitStatusType, added, deleted, modified, renamed, unmodified, untracked (+32 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.23
Nodes (6): EnvironmentStore, Persisted, String, URL, EnvironmentStoreTests, URL

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.08
Nodes (19): Collection, .aggregateBoardStatus, .taskTooltipSummary, Kind, primary, secondary, KouenPillButton, .init(title:kind:) (+11 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.16
Nodes (7): ReleaseNotes, Section, String, ReleaseNotesGuardTests, .changelog, String, .sampleNotes

### Community 198 - ".classify"
Cohesion: 0.13
Nodes (15): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+7 more)

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.26
Nodes (7): InstallResult, Shell, bash, fish, zsh, Bool, URL

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.13
Nodes (10): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String (+2 more)

### Community 202 - "PaletteModel"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.11
Nodes (15): ExperienceMode, agent, .displayName, .foregroundsAgents, full, .notchEnabledByDefault, persistent, .persistsSessionsByDefault (+7 more)

### Community 204 - "From tmux"
Cohesion: 0.25
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 205 - "CopyModeState"
Cohesion: 0.14
Nodes (11): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+3 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.13
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 207 - "scheduleRender"
Cohesion: 0.16
Nodes (7): CheckpointInfo, CheckpointManager, Bool, Date, String, CheckpointManagerTests, String

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.15
Nodes (3): .tab(forSurfaceKey:), .surfaceTelemetry, TimeInterval

### Community 209 - "SettingsRemoteView"
Cohesion: 0.08
Nodes (26): Notification.Name, os, Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow (+18 more)

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
Cohesion: 0.14
Nodes (7): TimeInterval, Logger, AgentHandoffBuilder, Bool, String, HandoffDirectoryTests, AgentHandoffBuilderTests

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.06
Nodes (30): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+22 more)

### Community 215 - ".lines"
Cohesion: 0.14
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 216 - "CellColorResolverTests"
Cohesion: 0.11
Nodes (10): WindowInputRouterTests, UInt8, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8 (+2 more)

### Community 217 - "GridCompositor"
Cohesion: 0.19
Nodes (8): SwarmFleetView, .init(coder:), CGFloat, NSCoder, CGFloat, NSCoder, TaskDashboardView, .init(coder:)

### Community 219 - "Prompt"
Cohesion: 0.11
Nodes (6): String, .trimmed, AgentTitleInference, Bool, .effectiveAgentKind, AgentDetectorTests

### Community 220 - "Section"
Cohesion: 0.18
Nodes (10): NotchGeometry, .fallback, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics, Bool (+2 more)

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.11
Nodes (22): keys, ITerm2InlineImage, .heightArg, .preserveAspectRatio, .widthArg, Bool, String, UInt8 (+14 more)

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.13
Nodes (3): Fze, O7, RD

### Community 224 - "CellColorResolver"
Cohesion: 0.24
Nodes (9): ANSIPalette, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors, Bool, Double, TerminalGridCell (+1 more)

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.15
Nodes (14): JSONRPCMessage, notification, request, response, StdioTransportTests, MCPStdioBuffer, MCPStdioFraming, contentLength (+6 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.18
Nodes (16): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, PaneLeaf, PaneNode (+8 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.10
Nodes (11): Bool, DispatchWorkItem, NSEvent, NSPopover, NSRange, NSString, Void, SyntaxTextView (+3 more)

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
Cohesion: 0.17
Nodes (21): Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors, ContrastGrade (+13 more)

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.16
Nodes (7): BoardViewController, FlippedView, .isFlipped, Bool, Set, TabID, BoardViewControllerTests

### Community 234 - ".scan"
Cohesion: 0.23
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 235 - "WorkbenchCommand"
Cohesion: 0.19
Nodes (6): SettingsHostingController, .init(coder:), SettingsWindowController, NSCoder, NSWindow, NSHostingController

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.12
Nodes (10): Bool, CGFloat, NSCoder, NSLayoutConstraint, NSPoint, NSRect, WindowTitleStripView, .init(coder:) (+2 more)

### Community 238 - ".make"
Cohesion: 0.11
Nodes (11): .captureLines(joinWrapped:), .feed(_:), .promptRows, .readGrid(scrollbackOffset:), TerminalGridSnapshot, ScrollbackTests, Character, String (+3 more)

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.11
Nodes (17): Agent Detection, Branch Detection Flow, Branch Label, Chrome Roles, Drag Reorder, File, Files, Git Branch Detection (+9 more)

### Community 240 - "PaneBorderStatus"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 242 - "AgentBridge"
Cohesion: 0.14
Nodes (5): HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 243 - ".make"
Cohesion: 0.25
Nodes (17): Encodable, AISuggestionAck, AttachedAck, BrowserFramePush, BrowserSnapshotAck, Cred, DetachedAck, DeviceCredentials (+9 more)

### Community 244 - "FileNode"
Cohesion: 0.13
Nodes (14): AgentSessionHistoryModel, .hasMoreToLoad, .minimumWindowStart, .searchQuery, .selectedScope, .windowedRecords, AgentSessionHistoryView, .body (+6 more)

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.11
Nodes (14): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+6 more)

### Community 246 - "Experience modes"
Cohesion: 0.19
Nodes (5): KouenFeatureMarkdownSync, Bool, String, URL, String

### Community 247 - ".renderFixture"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.16
Nodes (9): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+1 more)

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.33
Nodes (3): TaskStore, URL, TaskStoreTests

### Community 251 - "SessionCoordinator"
Cohesion: 0.67
Nodes (3): AsyncCLIResultBox, Error, Result

### Community 252 - "NSViewRepresentable"
Cohesion: 0.10
Nodes (16): FileHandle, LSPMessage, notification, request, response, Decoder, Encoder, KeyedDecodingContainer (+8 more)

### Community 253 - "Split Right"
Cohesion: 0.11
Nodes (17): AI-SDLC Task Progress — P45 Orca Architectural Enhancements: Worktrees, Sessions, Dashboard & Visual Tools, Artifacts, Context, Integration & Review, Phase 1: Worktree Core Intelligence & First-Class Sessions, Phase 2: Unified Sessions, Fleet Dashboard & Agent History Hub, Phase 3: Dedicated Rich Diff Viewer & "Annotate AI Diff", Phase 4: Issue Tracker Drawer (Linear / Jira / Azure DevOps) (+9 more)

### Community 254 - "BoardViewController"
Cohesion: 0.11
Nodes (17): 0. `FeatureStore` & Worktree Binding (`KouenCore`) — backs Pillar 0, 1. CLI Integration (`kouen-cli`), 1. Universal Chat History, Session Replay & Turn Navigation, 2. Fast Context Piping, Shell `@`-Mentions & Token Guards, 2. Fast Native Overlay (AppKit / SwiftUI), 3. Transcript Parser Actor (`AgentHistoryScanner`), 3. Turn-Based Micro-Checkpoint, `kouen undo` & Safety Guards, 4. Attention & Fleet Control Hardening — backs Pillar 6 (Existing Asset Scan result) (+9 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.09
Nodes (8): HookState, failed, idle, installed, installing, KouenSettings, ExperienceModeTests, UserNotifications

### Community 256 - "GitMetadataProvider"
Cohesion: 0.12
Nodes (18): _9n(), a9e(), Am(), avn(), Cm(), d8e(), Hm(), hmn() (+10 more)

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.14
Nodes (22): CoreImage, CryptoKit, Network, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription (+14 more)

### Community 258 - "WindowTitleStripView"
Cohesion: 0.11
Nodes (16): AI-SDLC Task Progress — P49 Architectural Hardening, Artifacts, Context, SDLC Workflow Gates, Summary, Tasks, Track 1: IPC Wire Contract Hardening (`Packages/KouenIPC`), Track 2: Core Domain Invariant Enforcement (`Packages/KouenCore`) (+8 more)

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.05
Nodes (30): CornerInfo, EditorDividerView, HitTestPassthroughView, KouenSplitView, .dividerColor, .dividerThickness, .init(coder:), PaneDragGripView (+22 more)

### Community 260 - ".welcome"
Cohesion: 0.12
Nodes (8): FormatContextBuilder, DaemonSurfaceID, String, FormatContextDaemonTests, PaneID, String, SurfaceID, URL

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
Cohesion: 0.06
Nodes (33): aie(), arc(), ax(), b2e(), bezierCurveTo(), closePath(), cRe(), cZ() (+25 more)

### Community 270 - "WindowSession"
Cohesion: 0.09
Nodes (11): PaneBorderStatus, Bool, Command, DispatchWorkItem, PaneID, PaneLeaf, PaneNode, PaneRect (+3 more)

### Community 271 - "StatusLineView.swift"
Cohesion: 0.15
Nodes (22): ch(), cvt(), dV(), ew(), ik(), iPt(), jj(), kae() (+14 more)

### Community 272 - "SGRMouseEvent"
Cohesion: 0.27
Nodes (9): Command Prompt, Find In Files, Git Panel, Open Command Palette, Switch To Session 1, Switch To Session 2, Rapid Session Switch While Typing, Switch Between Isolated And Normal Session (+1 more)

### Community 273 - "KeySpec"
Cohesion: 0.22
Nodes (5): .body, Bool, Bool, String, URL

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.15
Nodes (8): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ActivityAssertionManagerTests

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.18
Nodes (10): AssistantLine, ClaudeAdapter, Content, Message, ResultLine, Bool, Double, String (+2 more)

### Community 277 - ".run"
Cohesion: 0.22
Nodes (7): KouenCLIPaths, .applicationSupport, .binDirectory, .installedCLIPath, .installedDaemonPath, .launchAgentURL, URL

### Community 278 - "BlockTintOverlay"
Cohesion: 0.30
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 280 - ".menu"
Cohesion: 0.18
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
Cohesion: 0.18
Nodes (6): LSPTextLocation, .position, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.18
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.14
Nodes (9): MarkdownPreviewView, Any, Bool, Error, String, URL, Void, KouenSyntaxResources (+1 more)

### Community 287 - ".apply"
Cohesion: 0.42
Nodes (6): InstallResult, ShellCompletionInstaller, Bool, String, URL, ShellIntegration

### Community 288 - "AgentHookStrategy"
Cohesion: 0.12
Nodes (26): RGBColor, TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid (+18 more)

### Community 290 - "Process"
Cohesion: 0.11
Nodes (4): ContentAreaViewController, Bool, SplitDirection, TabID

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
Cohesion: 0.20
Nodes (7): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, FileChangeWatcherTests

### Community 296 - "NotificationBus"
Cohesion: 0.13
Nodes (15): .agentInfo(forWorktreePath:), Reason, errored, finished, needsInput, RowState, Bool, Comparable (+7 more)

### Community 297 - "settings.json"
Cohesion: 0.17
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, Bool, Double (+3 more)

### Community 299 - "PaneNode"
Cohesion: 0.08
Nodes (32): CGFloat, FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView (+24 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.13
Nodes (14): string, AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID, .snapshotPayload (+6 more)

### Community 301 - ".parse"
Cohesion: 0.12
Nodes (9): ParsedShortcut, .displayString, PrefixKeymap, Any, Bool, NSEvent, String, TimeInterval (+1 more)

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.15
Nodes (8): DetectedProfile, HandoffInfo, SignalFileRouter, Bool, FileManager, String, SignalFileRouterTests, URL

### Community 303 - ".encodeMouse"
Cohesion: 0.20
Nodes (3): AgentCommandTests, String, Tab

### Community 304 - "00-inception-plan.md"
Cohesion: 0.11
Nodes (17): CodingKey, CodingKeys, description, key, showInBanner, CodingKeys, createdAt, cwd (+9 more)

### Community 305 - ".script"
Cohesion: 0.08
Nodes (28): aat(), ap(), apn(), c5n(), d6(), f5n(), fle(), gPt() (+20 more)

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 307 - "ViPathTokenTests"
Cohesion: 0.12
Nodes (16): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+8 more)

### Community 308 - "Send Ex Command"
Cohesion: 0.12
Nodes (18): aDt(), Bpe(), cFe(), displayable(), Fpe(), jpe(), KBe(), mFe() (+10 more)

### Community 310 - "FrameSignposter"
Cohesion: 0.07
Nodes (32): KeybindingsService, Bool, Command, String, KeySpec, .init(from:), Decoder, Binding (+24 more)

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.21
Nodes (4): Bool, String, SurfaceID, TimeInterval

### Community 312 - "AgentSnapshot"
Cohesion: 0.18
Nodes (14): Array, Bool, Date, Decoder, PaneID, PaneNode, String, TabID (+6 more)

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.08
Nodes (28): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary, RowKind (+20 more)

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.12
Nodes (16): Agent Config Wiring, Agents, Architecture, Browser Pane, File I/O, Git, Key Files, MCP Server (harness-mcp) (+8 more)

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.15
Nodes (3): CellColorResolverTests, .resolver, CellColorResolver

### Community 319 - "FormatColor"
Cohesion: 0.09
Nodes (19): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+11 more)

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.26
Nodes (14): Agent Command Does Not Crash, Agent Waiting Filter Does Not Crash, Board Command Shows Board Panel, Cd Command Switches To Matching Tab, Copy Path Command Does Not Crash, Errors Command Does Not Crash, Find Command Opens Command Palette On Empty Query, Find Command Resolves Unique File (+6 more)

### Community 321 - "UInt64"
Cohesion: 0.06
Nodes (58): a7e(), al(), b1t(), bdn(), bIn(), c4n(), d7e(), dhn() (+50 more)

### Community 322 - "DesktopNotifier"
Cohesion: 0.18
Nodes (14): Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:), .isWorktreeSession, .worktreePath, Bool (+6 more)

### Community 323 - "LayoutNode"
Cohesion: 0.13
Nodes (7): ControlKeyNormalizer, Bool, String, ShortcutRecorderSerializer, String, ControlKeyNormalizerTests, ShortcutRecorderSerializerTests

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.09
Nodes (16): DaemonClientActor, TimeInterval, DaemonSessionError, daemonError, .description, unexpectedResponse, DaemonSessionService, .endpoint (+8 more)

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.07
Nodes (15): ScreenPos, bottom, middle, top, KouenLSP, FileGraphInfo, GraphifyLSPBridge, Double (+7 more)

### Community 327 - ".theme"
Cohesion: 0.40
Nodes (5): PaneOutputWaiter, PaneOutputWaitResult, CheckedContinuation, Never, UInt64

### Community 328 - "README.md"
Cohesion: 0.31
Nodes (6): Bool, Counter, Scheduled, SurfaceProgressTrackerTests, DispatchWorkItem, TimeInterval

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 330 - ".drawGlyph"
Cohesion: 0.18
Nodes (15): CellMetrics, ComposedFrame, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth (+7 more)

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.19
Nodes (9): NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView, .cornerConfiguration (+1 more)

### Community 332 - "Added"
Cohesion: 0.16
Nodes (14): json, item, OpaquePointer, AgentHistoryScanner, .antigravitySubagentIDs(dbPath:), AgentHistoryTurn, AgentSessionRecord, FileCacheEntry (+6 more)

### Community 333 - "RealPty"
Cohesion: 0.36
Nodes (6): ClaudeRunSummary, Date, Double, Int32, String, UUID

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.18
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 335 - ".makeModel"
Cohesion: 0.18
Nodes (13): Profile, edit, readonly, Run, RunState, cancelled, failed, running (+5 more)

### Community 336 - "run.sh"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 337 - "CommandExecutionError"
Cohesion: 0.21
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 338 - "CSIParams"
Cohesion: 0.16
Nodes (9): AgentRemoteControlDaemonService, Bool, Set, String, Void, AgentRemoteControlDaemonServiceTests, LogBox, .count (+1 more)

### Community 339 - "Foundation"
Cohesion: 0.09
Nodes (28): AppKit, CoreGraphics, CoreText, ImageIO, KouenCopyMode, KouenTerminalEngine, KouenTerminalRenderer, KouenTheme (+20 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.19
Nodes (9): .groupedRecords, .body, Group, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, CGFloat, NSTextField (+1 more)

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.09
Nodes (15): .effectiveResumeCommand(mode:), AgentLaunchCommands, String, AgentSessionMode, cloud, happy, .launchCommand, .launchFlags (+7 more)

### Community 342 - "Added"
Cohesion: 0.27
Nodes (8): Bool, NSPasteboard, NSString, String, URL, TerminalServicesProvider, AutoreleasingUnsafeMutablePointer, NSObject

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.09
Nodes (25): QuietRow, .body, StatusPill, .body, .color, DetectionStatus, .display, found (+17 more)

### Community 344 - "FileViewerViewController"
Cohesion: 0.17
Nodes (8): FileViewerViewController, Bool, NSEvent, Set, String, URL, GitDiffGutter, String

### Community 346 - "Agent platform icons"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.13
Nodes (14): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8, GlassEffectView (+6 more)

### Community 349 - "Contents.json"
Cohesion: 0.12
Nodes (16): AI-SDLC Task Progress — P46 CLI-First Agent Harness & Ergonomics, Artifacts, Context, Follow-up hardening pass (2026-09-21, post-completion), Integration & Review, Phase 0: AI-SDLC Embedded Workflow Engine & Worktree Lifecycle Discipline (Foundational) — [COMPLETED], Phase 1: Universal Chat History, Session Replay & Turn Navigation — [COMPLETED], Phase 2: Fast Context Piping, Shell `@`-Mentions & Token Guards — [COMPLETED] (+8 more)

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.19
Nodes (4): URL, MobileBridgeAttachFileTests, String, URL

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.17
Nodes (9): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.33
Nodes (6): SurfaceProgressTracker, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.15
Nodes (8): NSHostingView, NSLayoutConstraint, TerminalTabBarView, .delegate, .init(frame:), .leadingInset, .mouseDownCanMoveWindow, .trailingInset

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.29
Nodes (4): SwarmDAGStore, String, UUID, SwarmDAGStoreTests

### Community 355 - ".deepMerge"
Cohesion: 0.16
Nodes (17): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+9 more)

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.17
Nodes (4): InputEncoder, InputEncoderTests, String, UInt8

### Community 357 - ".handleCat"
Cohesion: 0.13
Nodes (10): NSPoint, NSView, DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSViewCornerConfiguration (+2 more)

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.20
Nodes (9): BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool, CGFloat, NSCoder, NSPoint (+1 more)

### Community 359 - "OcclusionTests"
Cohesion: 0.17
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

### Community 360 - "State"
Cohesion: 0.12
Nodes (16): Decisions so far, Destination, M2 — Warp custom model router, M3 — cmux Browser Design Mode, M4 — cmux Fork Conversation, M5 — cmux saved workspace layouts, M6 — iTerm2 AI safety-check, M7 — iTerm2 workgroup review automation (+8 more)

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.09
Nodes (15): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, AgentRoutingResolver (+7 more)

### Community 362 - "RGBColor"
Cohesion: 0.24
Nodes (4): CSIParams, .count, TerminalGridColor, UInt8

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.15
Nodes (13): .init(page:), Page, advanced, appearance, automations, models, remote, .symbol (+5 more)

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.25
Nodes (8): CodingKeys, cols, createdAt, dataBase64, rows, timeMs, type, version

### Community 366 - "Consumers"
Cohesion: 0.13
Nodes (15): agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:), AgentInboxRowView (+7 more)

### Community 367 - "DaemonStats"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 368 - "Tab"
Cohesion: 0.13
Nodes (7): Bool, NSDraggingInfo, NSDragOperation, NSPasteboard, URL, NSPasteboard, KouenTerminalSurfaceDragDropTests

### Community 369 - "Git Panel"
Cohesion: 0.39
Nodes (5): AutomationSummary, Bool, Date, String, UUID

### Community 370 - ".encode"
Cohesion: 0.17
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.23
Nodes (9): AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor (+1 more)

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.15
Nodes (14): .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:), .init(frame:) (+6 more)

### Community 373 - "Prompt"
Cohesion: 0.20
Nodes (3): fQ, hqe(), M9()

### Community 374 - ".run"
Cohesion: 0.26
Nodes (10): .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didStartProvisionalNavigation:), .init(title:isActive:onSelect:onClose:), LoadCompletionState, Bool, CheckedContinuation, Error (+2 more)

### Community 375 - ".install"
Cohesion: 0.23
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 376 - "ScrollReuseTests"
Cohesion: 0.08
Nodes (21): sysClose(), RealPty, .init(forTesting:), .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), .write(_:), ScrollbackEntry, ScrollbackReplaySegment, Bool (+13 more)

### Community 377 - "Identifiable"
Cohesion: 0.15
Nodes (15): NotchOverviewRow, .approvalControls, .background, .badge, .body, .openableRow, .progressUnderline, .relativeTime (+7 more)

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 379 - "MCPServer"
Cohesion: 0.07
Nodes (48): Codable, agentWaitChannel(), BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserRequestPayload, close (+40 more)

### Community 380 - "PromptQueue"
Cohesion: 0.14
Nodes (7): KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, BinaryInstallerDisplayTests, OnboardingEnvironmentTests

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.20
Nodes (6): LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.12
Nodes (17): OnboardingStep, complete, discover, .id, setup, shell, .title, welcome (+9 more)

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.09
Nodes (19): .webView(_:didCommit:), BrowserPaneViewTests, MockWebView, .isLoading, .url, Any, Bool, CGFloat (+11 more)

### Community 388 - "Darwin"
Cohesion: 0.12
Nodes (13): AnyView, .rowList, AgentNotchPresentation, closed, open, peek, AgentNotchViewModel, AgentNotchWindowActivator (+5 more)

### Community 389 - "HarnessCLITests"
Cohesion: 0.14
Nodes (13): SwarmFleetBody, .body, SwarmNodeRowView, .body, .statusColor, Duration, Void, SwarmFleetSnapshotWire (+5 more)

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.13
Nodes (14): Bug: Tab-Switch Black Screen, Files changed, Final fast-path guard (PaneLifecycleManager.swift), FM-1: detachHostsOnly() before caching (always broken), FM-2: force=true rebuild caches the stripped container, FM-3: Host theft by another tab's build, FM-4: Cache overwrite leaks orphan containers, FM-5: Fix never extended to WKWebView-backed browser panes (2026-08-23) (+6 more)

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.16
Nodes (14): CLI Isolate Creates Worktree And Session, CLI Isolate With Custom Branch Name, Close Session Keeps Dirty Worktree, Close Session Removes Clean Worktree, Create Isolated Session And Select, Drag Reorder Past Worktree Row No Crash, Git Checkout In Normal Session Does Not Affect Isolated, Isolate Without Branch Uses Detached HEAD (+6 more)

### Community 402 - "View"
Cohesion: 0.06
Nodes (35): ButtonStyle, CommandRow, .body, GlassCard, .body, GlassPrimaryButtonStyle, GlassSecondaryButtonStyle, GlassSmallButtonStyle (+27 more)

### Community 403 - "PresentAttempt"
Cohesion: 0.15
Nodes (10): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, PaneNode, Set, SurfaceID (+2 more)

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.22
Nodes (6): ListeningPortScanner, Int32, Set, String, result, ListeningPortScannerTests

### Community 405 - "AgentIconRenderer"
Cohesion: 0.09
Nodes (23): EndpointError, connectionFailed, .description, notYetSupported, pathTooLong, String, EndpointConnector, Int32 (+15 more)

### Community 406 - "main.swift"
Cohesion: 0.07
Nodes (12): Divergence, Bool, String, TimeInterval, WorktreeInfo, WorktreeManager, String, WorktreeIsolationTests (+4 more)

### Community 407 - "Fixed"
Cohesion: 0.18
Nodes (11): .mcpButton, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter, Any, Range (+3 more)

### Community 408 - "IPC Architecture"
Cohesion: 0.36
Nodes (4): Bool, String, UUID, TaskDaemonBridge

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.20
Nodes (4): TerminalModes, .encode(text:modifiers:modes:), Bool, .appCursor

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.15
Nodes (4): KouenCLI, MemoCommandTests, URL, TaskCommandTests

### Community 412 - "go.json"
Cohesion: 0.19
Nodes (3): aD(), GGe, urn

### Community 414 - "json.json"
Cohesion: 0.13
Nodes (14): 1. @MainActor + Task + Process.waitUntilExit = FREEZE (RL-052), 2. @Observable + mutation in body = infinite re-render loop (RL-053), 3. Re-entrancy guard on rebuildRows, 4. Worktree display rules, Architecture, chromeEpoch — force SwiftUI re-render from static state, Critical Lessons (bugs fixed), File tree: root at git root, expand on CWD change (+6 more)

### Community 415 - "markdown.json"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 416 - ".refreshSurfaceMetadata"
Cohesion: 0.19
Nodes (15): BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, Keybinding, .displayKey, MenuModifiers (+7 more)

### Community 417 - "rust.json"
Cohesion: 0.08
Nodes (26): SettingsTerminalView, .body, .experienceSection, .fontReadout, .fontSection, .shellSection, Bool, String (+18 more)

### Community 419 - "typescript.json"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 420 - "yaml.json"
Cohesion: 0.25
Nodes (4): bze(), EQ(), MBe(), mm

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.09
Nodes (21): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+13 more)

### Community 422 - "HintModeOverlay"
Cohesion: 0.08
Nodes (13): SessionGroup, .automationsList, String, String, KouenSidebarPanelViewController, NSMenuItem, SessionGroup, String (+5 more)

### Community 423 - "SixelDecoder"
Cohesion: 0.21
Nodes (8): .filteredJobs, .filteredRecords, SearchMatcher, .hasQuery, Bool, Character, String, SearchMatcherTests

### Community 424 - ".parseDiffHunks"
Cohesion: 0.14
Nodes (13): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+5 more)

### Community 425 - "AgentVectorIcon"
Cohesion: 0.13
Nodes (14): Architecture, Claude Code Subprocess Harness — Design, Context, Cost/context overhead control — SOLVED, verified, Decisions (user-confirmed), Explicitly NOT built (YAGNI), IPC / wiring, Minor note (+6 more)

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.29
Nodes (6): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Carbon

### Community 427 - ".delay"
Cohesion: 0.23
Nodes (5): HappyAdoptTests, HappyDaemonSession, Bool, Int32, String

### Community 428 - "TaskDashboardView"
Cohesion: 0.19
Nodes (7): MainMenuBuilder, MenuTarget, NSMenu, NSMenuItem, Selector, String, MenuTargetForkConversationTests

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.18
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.11
Nodes (15): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+7 more)

### Community 431 - "BoardCardView"
Cohesion: 0.15
Nodes (19): .color, BoardCard, BoardColumn, .name, BoardColumnKind, .displayName, done, error (+11 more)

### Community 432 - "PathToken"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.21
Nodes (8): DaemonMetrics, Snapshot, .meanLockWaitMicros, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 434 - "Project History"
Cohesion: 0.21
Nodes (4): Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions

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
Cohesion: 0.09
Nodes (17): .requestDaemon(_:), .selectWorkspace(byIndex:), .syncFromDaemon(metadataOnly:), ActiveTabCloseDisposition, session, tab, window, workspace (+9 more)

### Community 439 - "SetupStepView"
Cohesion: 0.16
Nodes (8): brn, grn, hrn(), JGe(), KGe(), prn(), qGe(), zGe()

### Community 440 - "LegacySnapshot"
Cohesion: 0.13
Nodes (14): Aggregate: `AgentRoutingRule`, Aggregate root: `AgentRoutingRuleStore`, Design — M2: Agent Routing Rule, Domain service: `AgentRoutingResolver`, `kouenSpawnAgent` change (`KouenDaemonTools.swift:319-356`), Logical Design, MCP tools (`kouen-mcp`, naming mirrors Automation's tool family), Next Step (+6 more)

### Community 441 - "RemoteHostStore"
Cohesion: 0.45
Nodes (3): data, SixelDecoder, UInt8

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.13
Nodes (14): 0. `FeatureStore` & Worktree Binding (`KouenCore`) — backs Pillar 0, 1. CLI Integration (`kouen-cli`), 1. Universal Chat History, Session Replay & Turn Navigation, 2. Fast Context Piping, Shell `@`-Mentions & Token Guards, 2. Fast Native Overlay (AppKit / SwiftUI), 3. Transcript Parser Actor (`AgentHistoryScanner`), 3. Turn-Based Micro-Checkpoint, `kouen undo` & Safety Guards, 4. Multi-Stage Continuous Verification & Self-Healing (+6 more)

### Community 443 - "main.swift"
Cohesion: 0.07
Nodes (31): ImagePlacementSnapshot, SemanticMark, Bool, String, UInt8, TerminalCellWidth, normal, spacerTail (+23 more)

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 445 - "Section"
Cohesion: 0.22
Nodes (7): NSEvent, BoardCardView, .init(card:), .init(coder:), .onDismiss, NSCoder, Void

### Community 447 - "PaletteMode"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 448 - "mobile_bridge_pairing_bugs.robot"
Cohesion: 0.18
Nodes (10): Bug 1 - Rotation Grace Slot Keeps The Previous Token Redeemable, Bug 1 - Rotation Shifts The Outgoing Token Into The Grace Slot, Bug 1 - Stop Fully Clears The Grace Slot, Bug 1 - Token Lifetime Not Regressed Below The Human-Flow Window, Bug 2 - Client onerror Does Not Clobber The Server Error Banner, Bug 2 - No Abrupt Cancel Immediately After The Error Text, Bug 2 - Reject Path Closes Gracefully With Policy-Violation Code 1008, Bug 3 - QR Not Printed When No Listener Is Ready (+2 more)

### Community 449 - "PresentAttempt"
Cohesion: 0.16
Nodes (16): SwarmFleetSnapshot, SwarmLane, pty, structured, SwarmTaskNode, SwarmTaskStatus, cancelled, failed (+8 more)

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.26
Nodes (5): Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 451 - ".run"
Cohesion: 0.27
Nodes (7): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection, agents

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.09
Nodes (15): GitPanelView, .isHidden, .removeWorktreeAction(_:), .removeWorktreeAction(path:), DispatchWorkItem, NSButton, NSColor, NSRect (+7 more)

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.21
Nodes (8): BrowserPaneRegistry, .init(url:paneID:), DesignModeElementInfo, NSWindow, PaneID, WeakBrowserPaneView, WeakScriptMessageHandler, WKScriptMessageHandler

### Community 454 - ".recordReapedGenerationForTesting"
Cohesion: 0.05
Nodes (56): AgentRow, .agentColor, .executables, .hookButton, .hookButtonTitle, SettingsAgentsView, .agentsSection, .body (+48 more)

### Community 455 - "ComposerPanel"
Cohesion: 0.19
Nodes (13): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Bool, Duration (+5 more)

### Community 456 - "TerminalModes"
Cohesion: 0.31
Nodes (5): AgyAdapter, Result, ResultLine, String, UUID

### Community 457 - ".normalizedKey"
Cohesion: 0.25
Nodes (8): AnimatablePair, NotchShape, .animatableData, CGFloat, CGPath, CGRect, Path, Shape

### Community 459 - ".encode"
Cohesion: 0.18
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

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
Cohesion: 0.12
Nodes (11): FormatContext, FormatString, FormatStyle, Bool, Character, Date, FormatColor, String (+3 more)

### Community 464 - "MouseButton"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 465 - "DirectionalAxis"
Cohesion: 0.36
Nodes (5): PaneLeaf, SessionGroup, Any, String, Tab

### Community 466 - "ReflowFastPathTests"
Cohesion: 0.20
Nodes (10): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+2 more)

### Community 467 - ".moveSelection"
Cohesion: 0.19
Nodes (11): RecordingEvent, input, metadata, output, resize, .timeMs, Date, Decoder (+3 more)

### Community 468 - "Never"
Cohesion: 0.14
Nodes (11): Agent Memory Index — harness-terminal, Navigation, Edges, Files, Knowledge Index — Harness Terminal, Search Instructions, Source Map, Case Index (+3 more)

### Community 469 - "PresentAttempt"
Cohesion: 0.12
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

### Community 476 - ".steps"
Cohesion: 0.22
Nodes (3): Any, NSMenuItem, NSClickGestureRecognizer

### Community 477 - ".endFind"
Cohesion: 0.14
Nodes (13): ACP (Agent Client Protocol) — tried, shelved, erased, Command Palette / Power-User Terminal Features, Embedded Browser, Feature Provenance — harness-terminal, Git Panel, Harness MCP, IDE Track — File Tree / Editor / LSP (the "Zed half" made real), Notifications (+5 more)

### Community 478 - ".install"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 479 - "ScrollbackTests"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 480 - "Command Prompt Architecture"
Cohesion: 0.07
Nodes (20): Tab, AnyObject, TimeInterval, ZombieHoldRegistry, BrowserIntegrationController, PaneID, PaneContainerView, .init(node:cwd:themeName:existingHosts:existingBrowserPanes:) (+12 more)

### Community 481 - ".testKouenRendererFixtureDefaultTextReportsPlausibleGlyphStats"
Cohesion: 0.20
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

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
Cohesion: 0.18
Nodes (12): DotView, .init(coder:), .init(frame:), statusColor(), Bool, Context, NSCoder, NSColor (+4 more)

### Community 490 - "ccRunGet"
Cohesion: 0.25
Nodes (4): StatusLineWidthTests, StatusLineWidth, String, StyledSegment

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
Cohesion: 0.19
Nodes (5): KeyTokenParser, Bool, String, KeyTokenParserTests, Phase6KeysTests

### Community 498 - ".automationList"
Cohesion: 0.15
Nodes (10): Int, Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock (+2 more)

### Community 499 - ".routingRuleList"
Cohesion: 0.18
Nodes (12): MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith, filenameStartsWith (+4 more)

### Community 500 - ".json"
Cohesion: 0.14
Nodes (12): Logical Design, P41 — Automations, Strategic Design, Tactical Design, Docs, kouen-mcp, KouenCore, KouenDaemon (+4 more)

### Community 501 - "Fixed"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 502 - "ACP Client (Shelved)"
Cohesion: 0.22
Nodes (4): RemoteHostsService, .activeHostName, String, Endpoint

### Community 504 - "WindowBorderOverlayView"
Cohesion: 0.14
Nodes (13): AI-SDLC Task Progress — P50 Cloud and Remote Control for Codex, Antigravity and Copilot, Artifacts, Context, Open questions & Real-world observations (Updated 2026-09-25), Phase A: spike on a Mac, Phase B: mode setting and command table, Phase C: remote-control daemons, Phase D: Send to cloud (+5 more)

### Community 507 - "memory_leak_guards.robot"
Cohesion: 0.40
Nodes (4): Leak A - Retiring A Host Drops Its AI Controllers, Leak B - Browser Network Capture Is Bounded, Leak C - Every Per-Surface Dict In Coordinator Has Retire Cleanup, Leak D - Every Per-Surface Dict In NotificationCoordinator Is Snapshot-Swept

### Community 508 - "SessionStore"
Cohesion: 0.20
Nodes (4): BoardCommandTests, String, String, Tab

### Community 509 - "start.mjs"
Cohesion: 0.70
Nodes (4): main(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 510 - "PromptQueue"
Cohesion: 0.18
Nodes (10): Architecture Decisions (dated log), Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Post-P50 changes (v4.20.2 → v4.20.11, 2026-10-01 → 2026-10-06), Product Identity Guardrail: Terminal, Not IDE, Shipped capability summary, P44–P49 (2026-08-31 → 2026-09-23) (+2 more)

### Community 512 - "Changelog Archive"
Cohesion: 0.15
Nodes (12): Architecture, Browser DevTools API (P28), Config, Key Bug Fixed: Round-Trip Timeout (RL-048), Key Files, Phase 1 — Core (all via evaluateJS or WKWebView native), Phase 2 — Network, Phase 3 — Storage (+4 more)

### Community 513 - "ThemeDocument"
Cohesion: 0.13
Nodes (8): BrowserPaneView, Any, NSPopover, Selector, String, TimeInterval, URL, NSAppearance

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
Cohesion: 0.27
Nodes (4): HintModeOverlay, Any, NSEvent, String

### Community 524 - "RealPtyLifecycleTests"
Cohesion: 0.15
Nodes (12): Decisions so far, Destination, Not yet specified (fog), Notes, Out of scope, P44a — MCP Surface Expansion, P44b — Inline UI + Hide Task Dashboard, P44c — Orchestrator Session Contract (+4 more)

### Community 525 - "TabContextCommand"
Cohesion: 0.15
Nodes (12): 5-Phase Architecture Plan, Current State Audit: Kouen Today vs. Orca, Goal & Philosophy, P45 Design — Enhancing Kouen with Orca-Class Capabilities, Phase 1: Worktree Core Intelligence & First-Class Sessions (Shipped), Phase 2: Unified Sessions, Fleet Dashboard & History Hub, Phase 3: Dedicated Rich Diff Viewer & "Annotate AI Diff", Phase 4: Issue Tracker Drawer (Linear / Jira / Azure DevOps) (+4 more)

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
Cohesion: 0.10
Nodes (15): AnyCancellable, NSScreen, NotchMaskAnimator, Bool, CGFloat, CGRect, NotchPanel, .canBecomeKey (+7 more)

### Community 530 - "HarnessChrome"
Cohesion: 0.29
Nodes (8): FormatColor, none, palette, rgb, StyledSegment, Bool, String, UInt8

### Community 531 - ".recordReapedGenerationForTesting"
Cohesion: 0.21
Nodes (12): CGFloat, Configuration, Range, Tab, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, TabBarLayoutMetrics, .pitch (+4 more)

### Community 534 - ".sessionID"
Cohesion: 0.53
Nodes (3): ProjectConfig, Bool, String

### Community 535 - "AgentNotification"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 537 - "NSObject"
Cohesion: 0.15
Nodes (13): 1. IPC Wire Contract Hardening (`Packages/KouenIPC`), 2. Domain Invariant Enforcement (`Packages/KouenCore`), 3. Decouple `KouenMCP` from `KouenDaemonCore`, Affected Call Sites to Update:, Change:, Problem:, Proposed Design:, Proposed Design: (+5 more)

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.06
Nodes (34): MainActor, Void, SessionDividerRowView, .init(coder:), .init(frame:), SessionGroupHeaderRowView, .init(coder:), .init(frame:) (+26 more)

### Community 539 - "install-app.sh"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 540 - ".taskUpdate"
Cohesion: 0.06
Nodes (38): bC(), c8e(), Cf(), clamp(), e9n(), ele(), ezt(), formatHsl() (+30 more)

### Community 544 - "Task Ledger Archive (Tasks 1–50)"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 546 - "LegacySnapshot"
Cohesion: 0.20
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 547 - "NSObject"
Cohesion: 0.16
Nodes (14): ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool, Command (+6 more)

### Community 553 - "harness.resource"
Cohesion: 0.24
Nodes (7): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController

### Community 554 - "FileTreeKeyboardNavigator"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 556 - "BrowserTab"
Cohesion: 0.22
Nodes (7): HeadlessRunEvent, assistantText, result, sessionID, Bool, Double, String

### Community 557 - ".viewWillMove"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 558 - ".sendInput"
Cohesion: 0.27
Nodes (8): LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab, TabID, WorkspaceID

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 560 - "LayoutTemplate"
Cohesion: 0.18
Nodes (9): Bm(), Em(), jm(), kfn(), kIn(), lst(), vn(), ym (+1 more)

### Community 562 - "BrowserResponsePayload"
Cohesion: 0.40
Nodes (4): Build, Release & Git Workflow, Build / Test / Run, Release packaging order, Worktree constraint

### Community 563 - "AgentNotchViewModel.swift"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

### Community 565 - "ReleaseNotesGuardTests"
Cohesion: 0.22
Nodes (8): ProjectDropTarget, .init(coder:), .init(frame:), NSCoder, NSDraggingInfo, NSDragOperation, NSRect, URL

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 568 - ".gestureRecognizer"
Cohesion: 0.24
Nodes (9): SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, Int32, String (+1 more)

### Community 569 - "KouenOverlayBackground"
Cohesion: 0.08
Nodes (26): CustomStringConvertible, DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed, atomicWrite() (+18 more)

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.08
Nodes (27): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+19 more)

### Community 571 - "ShellIntegrationTests"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 572 - "LayoutProbeView"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 573 - "main.swift"
Cohesion: 0.12
Nodes (19): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, PaletteFooter, .body (+11 more)

### Community 574 - "generate-release-notes.swift"
Cohesion: 0.09
Nodes (13): UnsafeBufferPointer, TerminalCellWidth, UnsafeBufferPointer, .cursorVisible, CharacterWidth, Bool, ClosedRange, Unicode (+5 more)

### Community 575 - ".toastErrorSummary"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 576 - "Phase67Tests"
Cohesion: 0.22
Nodes (5): RepoResolver, Bool, String, RepoResolverTests, String

### Community 578 - "TaskDashboardBody"
Cohesion: 0.01
Nodes (490): l, em(), _2t(), _4n(), _6n(), a1t(), a5n(), a7n() (+482 more)

### Community 579 - "RunState"
Cohesion: 0.26
Nodes (4): GroupedSessionTests, SessionGroup, Set, SurfaceID

### Community 580 - "ViInputMode"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 582 - "FileTreeKeyboardNavigator"
Cohesion: 0.15
Nodes (12): MouseButton, left, middle, right, wheelDown, wheelLeft, wheelRight, wheelUp (+4 more)

### Community 584 - ".configureEnvironment"
Cohesion: 0.33
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 586 - ".consumeInputCore"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 587 - "BrowserResponsePayload"
Cohesion: 0.14
Nodes (3): KouenApp, GitPanelViewFSEventFilterTests, GitPanelViewWorktreeParsingTests

### Community 589 - "Endpoint"
Cohesion: 0.33
Nodes (4): GridCompositorCopyModeTests, PaneRect, String, TerminalGridSnapshot

### Community 592 - "commit-push.sh"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Kouen-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

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
Cohesion: 0.29
Nodes (6): .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8

### Community 599 - "nJt"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 600 - "HarnessTerminalSurfaceView"
Cohesion: 0.03
Nodes (38): NSCursor, NSRangePointer, TerminalGridCell, NSEvent, Any, Bool, CGFloat, NSEvent (+30 more)

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
Cohesion: 0.08
Nodes (22): DisplayLinkTarget, MainSplitViewController, .setSidebarVisible(_:), .setSidebarVisible(_:animated:), SplitChromeDelegate, .splitView(_:constrainMaxCoordinate:ofSubviewAt:), .splitView(_:constrainMinCoordinate:ofSubviewAt:), .splitView(_:effectiveRect:forDrawnRect:ofDividerAt:) (+14 more)

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
Cohesion: 0.15
Nodes (7): NSScrollView, CGFloat, DispatchWorkItem, NSColor, NSEvent, TimeInterval, TerminalScrollbarView

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
Cohesion: 0.20
Nodes (6): bUt(), FBe(), Gbe(), handler(), mUt(), _Q()

### Community 669 - ".recordReapedGenerationForTesting"
Cohesion: 0.26
Nodes (4): PaneLabelDaemonTests, String, URL, UUID

### Community 671 - ".getBlock"
Cohesion: 0.15
Nodes (4): cqe(), F7, mathmlBuilder(), UHt()

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

### Community 680 - ".recordReapedGenerationForTesting"
Cohesion: 0.27
Nodes (3): Bool, SurfaceID, MenuTargetPeerReviewTests

### Community 681 - ".tabIDsToNotify"
Cohesion: 0.17
Nodes (11): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile, regionEdit (+3 more)

### Community 682 - ".update"
Cohesion: 0.33
Nodes (6): Board and attention, Errors and LSP, File navigation, Search, Task runner, Workbench commands (IDE-like workflow)

### Community 683 - "ImportedTerminalConfig"
Cohesion: 0.18
Nodes (10): 2026-06-25 — OSC 7735:  opens sidebar file viewer, 2026-06-27 — Block output tint + AI explain (Phase 12b), Pruned from MEMORY.md — 2026-07-02, Pruned from MEMORY.md — 2026-07-03, Pruned from MEMORY.md — 2026-07-04, Pruned from MEMORY.md — 2026-07-06, Pruned from MEMORY.md — 2026-07-07, Pruned from MEMORY.md — 2026-07-08 (+2 more)

### Community 684 - "New Tab"
Cohesion: 0.18
Nodes (10): 1. SurfaceShellTracker (proc tree walk), 2. DaemonSyncService.startMetadataRefresh (5-s loop), 3. snapshotChanged Fanout, 4. PerfCounters — Instrumentation, 5. Performance Lessons (v3.2.0), Adaptive polling, Background Polling & Snapshot Fanout — P22, Known Non-P22 Callers of syncFromDaemon (+2 more)

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 686 - "Fze"
Cohesion: 0.22
Nodes (4): AgentScanner, Bool, DispatchSourceTimer, TimeInterval

### Community 687 - "FormatStringExtendedVariableTests"
Cohesion: 0.18
Nodes (10): AI / Agent Connectivity, Architecture Decisions — harness-terminal, Browser Pane, Config / Settings, File Preview / Split Panes, IPC / Daemon, Keybindings, Sessions / Tabs (+2 more)

### Community 690 - ".update"
Cohesion: 0.40
Nodes (5): Additional `kouen-cli` subcommands, Agents, context and scratchpad, Daemon and diagnostics, Editor, LSP and setup, Sessions, tabs and recording

### Community 692 - ".control"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

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
Cohesion: 0.17
Nodes (5): DirectionalAxis, down, left, right, up

### Community 699 - ".make"
Cohesion: 0.18
Nodes (10): Agent Notch: Approval Buttons Dead + False "Waiting" Badge, Both bugs found via, Bug 1 — Reply/Deny/Allow buttons do nothing (or open the row instead), Bug 2 — Notch shows "waiting for your input" after a completely normal turn, Fix, Fix, Root Cause, Root Cause (+2 more)

### Community 700 - "Typography"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

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
Cohesion: 0.03
Nodes (71): _7n(), aNt(), bvt(), cc(), cOn(), CWt(), d1n(), d2() (+63 more)

### Community 710 - "MainWindowController"
Cohesion: 0.10
Nodes (14): KouenWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+6 more)

### Community 711 - "RunState"
Cohesion: 0.18
Nodes (10): AppKit / Views, Architecture / Daemon, Browser / WKWebView, Chrome / Theming / Rendering, Git / Process, Notifications / UserNotifications, RL Lessons — harness-terminal, Swift 6 / Concurrency (+2 more)

### Community 712 - "ResumeStyle"
Cohesion: 0.26
Nodes (3): BellScanTests, Bool, UInt8

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
Cohesion: 0.29
Nodes (8): SessionID, String, Void, TaskDashboardBody, .body, .init(onJumpToSession:), TaskRowView, .body

### Community 718 - ".deleteSavedLayout"
Cohesion: 0.18
Nodes (10): AI-SDLC Task Progress — Agent Swarm Core (Fleet Orchestration), Artifacts, Context, Delegation comparison (running, update after each slice), First live-daemon check (2026-09-14, user request: "turn on dashboard, test real, Remaining (follow-ups, not blocking — this feature's core loop is complete end to end), Review notes (Slice 1, local-ai delegation), Summary (+2 more)

### Community 719 - "ViInputMode"
Cohesion: 0.60
Nodes (3): .encode(_:modifiers:event:modes:), SpecialKey, insert

### Community 720 - "AgentRoutingRuleSummary"
Cohesion: 0.32
Nodes (6): CGFloat, ResizeDirection, down, left, right, up

### Community 722 - ".configureEnvironment"
Cohesion: 0.36
Nodes (3): crn, ELt(), n2e()

### Community 723 - "Fze"
Cohesion: 0.18
Nodes (10): Cleanup on toggle off / pane close, Design — M3: Browser Design Mode, JS injection (on toggle ON, via `evaluateJS`, not a persistent `WKUserScript` —, Logical Design, Native message handler, Next Step, Popover UI, Strategic Design (+2 more)

### Community 724 - ".detailView"
Cohesion: 0.18
Nodes (10): Artifacts, Context, Data Storage — KouenTask status field, Dev Task Progress — P44a MCP Surface Expansion, Integration, Lessons Learnt reviewed, Server Logic — PR/CI status tool, Server Logic — Reliable spawn-worker tool (+2 more)

### Community 725 - "HintModeOverlay"
Cohesion: 0.18
Nodes (10): Browser-style Back/Forward navigation between tab/session switches, Context, Design, Keyboard shortcuts + menu + command palette, New: `SessionHistoryNavigator` (MainActor, `Apps/Kouen/Sources/KouenApp/Services/SessionHistoryNavigator.swift`), Reuse Table, Test coverage (ponytail: non-trivial logic needs one runnable check), UI: two `SoftIconButton`s in `MainSplitViewController` (+2 more)

### Community 727 - "PromptQueueBar"
Cohesion: 0.17
Nodes (11): agy, claude, copilot, hermes, __kouen_agy_next, __kouen_claude_next, __kouen_copilot_next, __kouen_hermes_next (+3 more)

### Community 728 - ".handleUndo"
Cohesion: 0.09
Nodes (21): InputGate, .siblings, ReconnectLatch, .isTripped, SurfaceIO, .currentSubscription, Bool, CGFloat (+13 more)

### Community 729 - "Lf"
Cohesion: 0.25
Nodes (6): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow

### Community 730 - "ViInputMode"
Cohesion: 0.31
Nodes (6): ClaudeCloudSessionStore, Entry, Date, String, TimeInterval, URL

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
Cohesion: 0.28
Nodes (4): TerminalGridSnapshot, ReflowPreviewTests, .feeds, String

### Community 735 - "ImageTextureCache"
Cohesion: 0.14
Nodes (11): MTLLibrary, MTLRenderPipelineState, ImageTextureCache, MTLDevice, MTLTexture, UInt8, CGFloat, MTLBuffer (+3 more)

### Community 736 - "graphify reference: add a URL and watch a folder"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 737 - ".resolve"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 743 - ".matchingTab"
Cohesion: 0.15
Nodes (6): .agentInfo(forWorktreePath:tabs:), Tab, TabID, WorkspaceID, GitPanelViewWorktreeAgentTests, GitPanelViewWorktreeNavigationTests

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

### Community 755 - "ym"
Cohesion: 0.15
Nodes (13): OverlayBackground, Context, OverlayBackground, Context, KouenOverlayBackground, .init(coder:), .init(coder:), .init(coder:) (+5 more)

### Community 756 - "Consumers"
Cohesion: 0.20
Nodes (9): 1. Board Sidebar Tab (GUI), 2. Harness CLI Command, 3. Scripting API, 4. Read-Only MCP Tool, Agent/Session Board (P16), Centralized Classification, Consumers, Data Model (PBI-BOARD-001) (+1 more)

### Community 759 - "SpecialKey"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 762 - ".main"
Cohesion: 0.20
Nodes (5): KouenMCPServer, Bool, String, MCPServer, String

### Community 763 - "Git Panel"
Cohesion: 0.20
Nodes (9): Architecture, Branch chip — CASE-020, Features, FSEvents Pattern (Swift Actor), Git Panel, History → File Editor, Real-time Refresh, v1 — CASE-009 (resolved, superseded) (+1 more)

### Community 768 - ".tabIDsToNotify"
Cohesion: 0.22
Nodes (9): MatchSource, ownProcess, wrapperLaunch, RawMatch, WrapperOptionBehavior, keepScanning, matchValue, skipValue (+1 more)

### Community 776 - "DecodedWSFrame"
Cohesion: 0.15
Nodes (7): ExpressibleByStringLiteral, PipeBuffer, StringError, .init(_:), .init(stringLiteral:), Result, MobileBridgeAISuggestTests

### Community 778 - "Logical Design"
Cohesion: 0.20
Nodes (9): 1. `KouenTask` status field, drop delete-on-done, 2. Worktree↔session link, MCP-reachable both ways, 3. PR/CI status MCP tool, 4. Reliable "spawn Worker + wait-ready + send prompt" tool, Logical Design, P44a — MCP Surface Expansion — Design, Strategic Design, Tactical Design (+1 more)

### Community 781 - "Dev Task Progress — P44c + P44d Orchestrator Session Contract + Auto-Fix Loop Safety Bounds"
Cohesion: 0.20
Nodes (9): Artifacts, Context, Coordination note, Dev Task Progress — P44c + P44d Orchestrator Session Contract + Auto-Fix Loop Safety Bounds, Review findings (this session, before close), Summary, Verification, What agy produced (+1 more)

### Community 782 - "AI-SDLC Task Progress — P47 Primary Branch Worktree Fix"
Cohesion: 0.20
Nodes (9): AI-SDLC Task Progress — P47 Primary Branch Worktree Fix, Artifacts, Context, Integration & Review, SDLC Workflow Gates, Skill Invocation Log, Summary, Tasks (+1 more)

### Community 784 - "AI-SDLC Task Progress — P48 Session History Navigator"
Cohesion: 0.20
Nodes (9): AI-SDLC Task Progress — P48 Session History Navigator, Artifacts, Context, Integration & Review, SDLC Workflow Gates, Skill Invocation Log, Summary, Tasks (+1 more)

### Community 800 - "TabStatus"
Cohesion: 0.20
Nodes (8): statusHelp(), String, TabStatus, done, error, idle, running, waiting

### Community 803 - ".compute"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 867 - "Fixed"
Cohesion: 0.21
Nodes (8): Container, .init(coder:), .init(frame:), NotchPulseHost, Context, NSCoder, NSHostingView, NSRect

### Community 871 - "SessionStore"
Cohesion: 0.29
Nodes (3): SessionStore, DispatchWorkItem, TimeInterval

### Community 897 - "MobileBridgeSpawnTests"
Cohesion: 0.22
Nodes (3): MobileBridgeSpawnTests, String, URL

### Community 915 - "ResumeStyle"
Cohesion: 0.29
Nodes (8): AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand, Bool, Set

### Community 953 - "Added"
Cohesion: 0.33
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

### Community 979 - "qLt"
Cohesion: 0.20
Nodes (7): BBe(), NBe(), PBe(), qLt(), sIt(), VBe(), zLt()

### Community 991 - "Changed"
Cohesion: 0.22
Nodes (8): Build order (unchanged from interview decision), G1 — @ file-path picker, G2 — shell tab-completion suggestion strip (heuristic, explicitly best-effort), G3 — AI command suggestion (via `claude` CLI subprocess), Logical Design, P37 Phase G — Autocomplete (mobile bridge), Strategic Design, Tactical Design

### Community 1000 - "Changed"
Cohesion: 0.22
Nodes (8): Artifacts, Client Application — Slice 1 (stacked panes, no persistence), Client Application — Slice 2 (per-workspace divider memory), Context, Dev Task Progress — Workspace Sidebar Panels (P42), Integration, Note on task re-sequencing (2026-07-17), Summary

### Community 1015 - ".delay"
Cohesion: 0.27
Nodes (3): DaemonReconnectPolicy, TimeInterval, DaemonReconnectPolicyTests

### Community 1136 - "GroupedSessionDaemonTests"
Cohesion: 0.24
Nodes (4): GroupedSessionDaemonTests, SessionGroup, String, URL

### Community 1151 - "ThemeCatalogEmbedTests"
Cohesion: 0.22
Nodes (6): String, URL, ThemeCatalogEmbedTests, .embedSwift, .repoRoot, .sourceJSON

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

### Community 1577 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.22
Nodes (8): Accessibility Requirements, Files, Permission, Running, Stack, Test Strategy, UI Automation — Robot Framework (P18), Why Not Appium

### Community 1637 - "AppKit + Metal Patterns"
Cohesion: 0.22
Nodes (8): AppKit + Metal Patterns, CADisplayLink Lifetime on macOS (CASE-031), Metal Surface Lifecycle (CASE-003), Mouse Selection Must Use Virtual-Line Coordinates (CASE-029), NSFont Italic (CASE-010), NSView Layer Opacity — Preview Parity Pattern (CASE-011), Overlay Above Metal (CASE-004), Window Background Tint for Legibility (CASE-027)

### Community 1646 - "Split Panes (NSSplitView)"
Cohesion: 0.22
Nodes (8): Architecture, Infinite Recursion (CASE-006), Pane Drag-and-Drop (P27), Ratio Persistence (CASE-002), Split CWD Resolution — Worktree Priority (2026-06-21), Split Panes (NSSplitView), Subview Reorder (CASE-007), Two-Axis Split Parity (P13)

### Community 1692 - "Changed"
Cohesion: 0.25
Nodes (5): Bool, NSEvent, ViInputMode, insert, normal

### Community 1740 - "headless-worker-followup — Phase 2 Architect (Gate 1)"
Cohesion: 0.22
Nodes (8): Context, Decision to confirm, Delivery, Design, headless-worker-followup — Phase 2 Architect (Gate 1), QA coverage (what deserves a test — scenarios in Phase 3), Reuse Table, Verification

### Community 1774 - "M2 — Agent Routing Rule — Task Progress"
Cohesion: 0.22
Nodes (9): Docs, kouen-mcp, KouenApp (Settings UI), KouenCore, KouenDaemon, KouenIPC, M2 — Agent Routing Rule — Task Progress, Tests (+1 more)

### Community 1832 - "Added"
Cohesion: 0.25
Nodes (7): Claude Code hook push (in-process Task subagent detection), Client UI indicator, Detection core (AgentDetector, pure logic), IPC / Tab plumbing, P38 Phase B — Subagent Visibility — Dev Task Progress, Status: Rewritten 2026-07-14 after original implementation (tasks 1-5) was lost to a concurrent git operation before commit. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 1893 - "Dev Task Progress — P44b Inline UI + Hide Task Dashboard"
Cohesion: 0.22
Nodes (8): Artifacts, Context, Coordination note, Dev Task Progress — P44b Inline UI + Hide Task Dashboard, Review findings (this session, before close), Summary, Tasks (delegated to agy, verified by this session), Verification

### Community 1914 - "P43 — Add Repo/Folder to Workspace"
Cohesion: 0.25
Nodes (7): Original overlay build (built 2026-07-14, gated green, then deleted 2026-07-15 mid live-test), P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress, Pivot — merge into the Recipes picker (2026-07-15), Stage 1-2 — Engine/surface plumbing (built 2026-07-14, unchanged by the pivot, still in use), Status: Implementation pivoted mid-phase from a standalone overlay to a merge into the existing, Summary, Thread grouping — Zed framing folded into the same picker (2026-07-15)

### Community 1922 - "Added"
Cohesion: 0.15
Nodes (9): i9e(), Lf(), mAn(), mMt(), nyn(), p4e(), rBt, u3n() (+1 more)

### Community 1926 - "Shadow"
Cohesion: 0.27
Nodes (5): SpecialKeyMappingTests, Bool, NSEvent, String, UInt16

### Community 1930 - ".encodeLine"
Cohesion: 0.22
Nodes (4): JSONDecoder, JSONEncoder, Encoder, TerminalRecordingCodec

### Community 2000 - "fFe"
Cohesion: 0.22
Nodes (9): B3(), dFe(), _Dt(), fFe(), lFe(), _Ot(), sD(), TOt() (+1 more)

### Community 2014 - "Added"
Cohesion: 0.36
Nodes (7): Document, Bool, Set, String, URL, ToolPolicy, .defaultURL

### Community 2079 - ".hold"
Cohesion: 0.25
Nodes (6): calculate(), constructor(), kOt(), mBt, r2e(), sOt()

### Community 2100 - ".handleWake"
Cohesion: 0.12
Nodes (19): .exit, DaemonClient, String, String, KouenCLI, SessionID, String, Bool (+11 more)

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

### Community 2332 - "M5 — Saved Layouts — Task Progress"
Cohesion: 0.25
Nodes (8): Docs, KouenApp, KouenCore, KouenDaemon, KouenIPC, M5 — Saved Layouts — Task Progress, Tests, Verification

### Community 2390 - "Fix: primary tree left squatting on a feature branch after auto-isolate"
Cohesion: 0.25
Nodes (7): Context, Design decision: reorder + real branch checkout (not `--detach`), Fix: primary tree left squatting on a feature branch after auto-isolate, Implementation, Multi-feature-branch requirement — verified, not rebuilt, Reuse Table, Verification

### Community 2483 - ".zoomWindowIfDoubleClick"
Cohesion: 0.25
Nodes (4): Bool, NSEvent, NSEvent, NSEvent

### Community 2541 - "P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable"
Cohesion: 0.17
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 2573 - "P38 Phase D — Kitty Graphics Conformance Slice"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase D — Kitty Graphics Conformance Slice, Scope (locked), Tests

### Community 2583 - "ReplayStep"
Cohesion: 0.25
Nodes (6): Kind, input, metadata, output, resize, ReplayStep

### Community 2587 - "eFe"
Cohesion: 0.25
Nodes (8): BDt(), eFe(), kFe(), pC(), tDt(), Vpe(), xDt(), YBe()

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

### Community 3515 - "Modifiers"
Cohesion: 0.25
Nodes (6): OptionSet, .description, .init(key:modifiers:), Modifiers, String, UInt8

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

### Community 3868 - "DisplayWidth"
Cohesion: 0.33
Nodes (3): DisplayWidth, String, Unicode

### Community 3869 - "inlineTokens"
Cohesion: 0.29
Nodes (7): blockTokens(), inlineTokens(), lex(), lexer(), lexInline(), me(), reflink()

### Community 3870 - "r2"
Cohesion: 0.29
Nodes (7): GRt(), n4e(), p7e(), r2(), tl(), vrt(), xq()

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

### Community 3879 - "Architecture Design — p45-orca-worktree-sessions"
Cohesion: 0.33
Nodes (5): 1. Context & Scope, 2. Core Decisions & Philosophy, 3. System Architecture & Seams, 4. Worktree Lifecycle & Verification, Architecture Design — p45-orca-worktree-sessions

### Community 3880 - "AgentBadgeView"
Cohesion: 0.47
Nodes (4): AgentBadgeView, .body, Bool, CGFloat

### Community 3881 - "HistoryScope"
Cohesion: 0.33
Nodes (5): HistoryScope, all, .id, project, workspace

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

### Community 3888 - "BlockSummary"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 3892 - "azt"
Cohesion: 0.50
Nodes (3): azt(), ibe(), q$e()

### Community 3894 - "NSRect"
Cohesion: 0.50
Nodes (3): NSRect, .init(frame:), .thumbRect

## Knowledge Gaps
- **4209 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+4204 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **2415 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `.automationList` to `ThemeDocument`, `graphify reference: extra exports and benchmark`, `Changed`, `.handleNormal`, `IPCRequest`, `AgentNotchRootView`, `.jumpToBlock`, `LSPMessage`, `TerminalEmulator`, `ShellCompletionInstallerTests`, `GitPanelView.swift`, `PerformanceBenchmarks`, `FileTreeKeyboardNavigator`, `VTParser`, `HarnessTerminalSurfaceView`, `.applyPreedit`, `MetalRendererTests`, `HarnessUILibrary`, `.recordReapedGenerationForTesting`, `HarnessChrome`, `.init`, `EngineConformanceTests`, `ReplayStep`, `SplitPaneCoordinator`, `WorktreeManager`, `SessionGroupHeaderRowView`, `.readGrid(scrollbackOffset:)`, `RGBColor`, `.init`, `Notification`, `Sendable`, `.addTab`, `Equatable`, `.bufferLine`, `MenuTarget`, `.characterIndex`, `Task Ledger Archive (Tasks 1–50)`, `CodingKeys`, `HarnessSidebarPanelViewController.swift`, `.viewWillMove`, `.sendInput`, `.normalizedKey`, `.keyEvent`, `HarnessSplitView`, `TabCell`, `KouenOverlayBackground`, `CommandHistorySearchController`, `3.2 สิ่งที่ implement แล้ว`, `ShellIntegrationTests`, `main.swift`, `FrecencyDirectoryStore`, `HarnessCLI+Server.swift`, `generate-release-notes.swift`, `PasteBufferStore`, `ShellIntegration`, `Changed`, `Completed Plans Archive`, `worktree_isolation_cli.robot`, `FileTreeKeyboardNavigator`, `.parse`, `Endpoint`, `HarnessDesign`, `.firstMatch`, `LSPClient`, `LSPDiagnostic`, `TerminalGridCell`, `HarnessPaths`, `.control`, `HarnessTerminalSurfaceView`, `AttachInputBatcher`, `shim.c`, `PaneContainerView`, `.installCLI`, `.dispatch`, `ScriptRuntime.swift`, `Session Grouping and Split Session Plan`, `MainSplitViewController`, `DaemonLauncher`, `Recipe`, `AnyCodable`, `domain-design.md`, `DamageTrackingTests`, `SoftIconButton`, `code:text (:workbench start swift)`, `.makeSnapshot`, `[2.5.0] - 2026-06-12`, `HarnessGridTerminal`, `.encode`, `SessionGroup`, `.firstWaitingTab`, `ViEngine`, `HistoryRingBuffer`, `ClientSummary`, `GlyphAtlas`, `code:block1 (SessionCoordinator.snapshot ──┐)`, `SwiftUI`, `.install`, `AgentHookInstaller`, `.load`, `CommandTarget`, `.startWatching`, `PtyDrainCeilingBenchmark`, `User Story Mapping (MANDATORY)`, `แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)`, `.testPaneLeafLegacyDecodeBackfillsSurfaceTabs`, `CopyModeGridSource`, `PaneStyleSet`, `AsciiFastPathTests`, `DecodedImage`, `FileTreeWatcher`, `What You Must Do When Invoked`, `LiveResizeTests`, `Int`, `ThaiCombiningMarkTests`, `Harness Terminal — IDE Sidebar Feature Branch`, `MatchCategory`, `What You Must Do When Invoked`, `TerminalFindBar`, `Workspace`, `CommandPromptController`, `ActiveTabCloseDisposition`, `AgentTableEntry`, `URLDetection`, `[1.5.1] - 2026-06-06`, `BinaryRefresherTests`, `.hideFind`, `InlineAICompletionView`, `[3.13.1] - 2026-07-02`, `GridCompositorTests`, `LSPServerRegistry`, `SessionSnapshot`, `AppDelegate`, `main.swift`, `user-stories.md`, `.taskUpdate`, `GlyphRasterizer`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `BinaryInstaller`, `.classify`, `[3.9.5] - 2026-06-26`, `scheduleRender`, `AgentRoutingRuleSummary`, `PaneTarget`, `.lines`, `.handleUndo`, `CellColorResolverTests`, `TerminalServicesProvider`, `b1t`, `ImageTextureCache`, `ThaiGrid`, `SSHTunnelManagerTests`, `ExternalOpenKind`, `WorkbenchCommand`, `.make`, `PaneBorderStatus`, `[3.5.1] - 2026-06-20`, `FileNode`, `ThemeDocumentTests`, `Experience modes`, `ReflowPreviewTests`, `SessionCoordinator`, `NSViewRepresentable`, `workspace`, `.tabIDsToNotify`, `ThemeFileServiceTests`, `.welcome`, `HarnessSidebarPanelViewController`, `.path`, `DefaultTerminalManager`, `WindowSession`, `KeySpec`, `[2.5.0] - 2026-06-12`, `DisplayPanesOverlay`, `.menu`, `TerminalScrollbarView`, `FormatColor`, `DisplayWidth`, `After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md.`, `code:bash (harness-cli install-hooks hermes)`, `click_ui_element`, `AgentHookStrategy`, `StatusLineWidthTests`, `Process`, `.compute`, `JSONDecoder`, `Fixes Applied (layered)`, `GitHubCLIClient`, `NotificationBus`, `settings.json`, `PaneNode`, `HarnessPaths.swift`, `ANSIPalette`, `BlockSummary`, `.handleCat`, `.selectAdjacentSession`, `Bug: Tab-Switch Black Screen`, `Terminal AI Chat (⌘I inline overlay)`, `AgentSnapshot`, `DesktopNotifier`, `worktree_isolation.robot`, `.theme`, `README.md`, `.drawGlyph`, `Added`, `CSIParams`, `Foundation`, `FileViewerViewController`, `Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)`, `P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)`, `.handleCat`, `[3.5.1] - 2026-06-20`, `FormatStyledSegment.swift`, `RGBColor`, `generate-cheatsheet.js`, `Consumers`, `Git Panel`, `ScrollReuseTests`, `Identifiable`, `SurfaceProgressTrackerTests.swift`, `MCPServer`, `NSTextField Leak in BoardViewController (P20 Performance)`, `User Profile`, `Darwin`, `HarnessCLITests`, `.cursorBackwardTabs`, `.init`, `PresentAttempt`, `Split Panes (NSSplitView)`, `AgentIconRenderer`, `.tabIndex(tabID:)`, `main.swift`, `.setCellPixelSize`, `Session/Tab/Pane Hierarchy & Top Bar (CASE-028)`, `javascript.json`, `markdown.json`, `.currentSize`, `SixelDecoder`, `.navigateCurrentFile`, `Competitive Position (as of v3.12.0, 2026-07-02)`, `BoardCardView`, `PathToken`, `LaunchdServiceInstaller`, `SessionEditor`, `Added`, `RemoteHostStore`, `main.swift`, `CopilotAdapter`, `PresentAttempt`, `SessionCoordinator.swift`, `tmux parity — status, adaptations, and deliberate divergences`, `.recordReapedGenerationForTesting`, `.deinit`, `.init`, `ReflowFastPathTests`, `.moveSelection`, `.resize`, `DispatchTime`, `HarnessOnboarding`, `Added`, `ScrollbackTests`, `.testKouenRendererFixtureDefaultTextReportsPlausibleGlyphStats`, `ccRunGet`, `.testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache`, `.bind`, `.routingRuleList`, `.delay`?**
  _High betweenness centrality (0.198) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `Terminal AI Chat (⌘I inline overlay)` to `Darwin`, `AgentSessionSummary.swift`, `worktree_isolation_cli.robot`, `IPCRequest`, `.agentName`, `Changelog`, `.id`, `NotificationBus`, `.parse`, `TerminalProtocolCompatibilityTests`, `Consumers`, `.automationList`, `PaneNode`, `code:bash (harness-cli install-hooks pi)`, `SessionCoordinator`, `MCPServer`?**
  _High betweenness centrality (0.175) - this node is a cross-community bridge._
- **Why does `fbt()` connect `TaskDashboardBody` to `HarnessSettings`, `Changelog`, `String`, `CopyModeAction`?**
  _High betweenness centrality (0.090) - this node is a cross-community bridge._
- **Are the 18 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `RenderScheduler`) actually correct?**
  _`KouenTerminalSurfaceView` has 18 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _4229 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.05339506172839506 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.04265873015873016 - nodes in this community are weakly interconnected._