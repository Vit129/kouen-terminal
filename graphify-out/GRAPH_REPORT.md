# Graph Report - harness-terminal  (2026-07-02)

## Corpus Check
- 724 files · ~904,016 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 15060 nodes · 31519 edges · 2921 communities (935 shown, 1986 thin omitted)
- Extraction: 89% EXTRACTED · 11% INFERRED · 0% AMBIGUOUS · INFERRED: 3353 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `587fa906`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `Int` - 927 edges
2. `HarnessCore` - 268 edges
3. `Foundation` - 268 edges
4. `XCTest` - 180 edges
5. `SessionEditor` - 170 edges
6. `SurfaceRegistry` - 154 edges
7. `IPCRequest` - 151 edges
8. `DaemonClient` - 142 edges
9. `AppKit` - 139 edges
10. `SessionCoordinator` - 124 edges

## Surprising Connections (you probably didn't know these)
- `SUI` --calls--> `Color`  [INFERRED]
  Packages/HarnessOnboarding/Sources/HarnessOnboarding/Design/ImmersivePalette.swift → Apps/Harness/Sources/HarnessApp/Settings/SwiftUI/SettingsColorsView.swift
- `register()` --calls--> `Int`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Scripting/ScriptAPI.swift → Packages/HarnessCommands/Sources/HarnessCommands/SGRMouse.swift
- `testingSetSelectionColors()` --references--> `HarnessTheme`  [EXTRACTED]
  Packages/HarnessTerminalKit/Sources/HarnessTerminalKit/HarnessTerminalSurfaceView.swift → Tools/harness/Sources/HarnessCLI/HarnessCLI.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/DaemonSyncService.swift → Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonSessionService.swift
- `ThemeImportController` --calls--> `ThemeFileService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/ThemeImportController.swift → Packages/HarnessTheme/Sources/HarnessTheme/ThemeFileService.swift

## Import Cycles
- None detected.

## Communities (2921 total, 1986 thin omitted)

### Community 0 - "Terminal Engine: Model / TerminalGridModel"
Cohesion: 0.09
Nodes (26): CodingKey, MenuModifiers, BannerShortcut, BannerShortcutRegistry, CodingKeys, description, key, showInBanner (+18 more)

### Community 2 - "Tests: HarnessTerminalRendererTests / MetalRendererTests"
Cohesion: 0.05
Nodes (53): ProjectTask, ProjectTaskDetector, String, LinePos, end, firstNonBlank, start, Bool (+45 more)

### Community 5 - "HarnessCore: IPC / IPCMessage"
Cohesion: 0.02
Nodes (117): IPCRequest, applyLayout, attachSurface, bindHook, breakPane, browserClose, browserCookies, browserEvaluate (+109 more)

### Community 6 - "Terminal Renderer: HarnessTerminalRenderer / TerminalMetalRenderer"
Cohesion: 0.15
Nodes (15): AnyTransition, AnyView, AgentNotchPeekEvent, AgentNotchRootView, NotchOverviewRow, NotchStatusDot, Bool, CGFloat (+7 more)

### Community 7 - "HarnessCore: Commands / Command"
Cohesion: 0.02
Nodes (94): Command, bindKey, breakPane, choose, clearHistory, clockMode, commandPrompt, confirmBefore (+86 more)

### Community 8 - "Terminal Engine: Emulator / TerminalEmulator"
Cohesion: 0.08
Nodes (28): Error, DaemonClientError, connectionFailed, timeout, unexpectedResponse, writeFailed, PtyError, launchFailed (+20 more)

### Community 9 - "Harness App: Settings / SettingsViewController"
Cohesion: 0.06
Nodes (23): Dispatch, Date, String, TerminalBlock, TerminalBlockStore, Charset, ascii, decSpecialGraphics (+15 more)

### Community 10 - "Tests: HarnessBenchmarks / PerformanceBenchmarks"
Cohesion: 0.10
Nodes (15): colors, PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Data, Double, MTLDevice (+7 more)

### Community 11 - "Harness App: UI / TerminalTabBarView"
Cohesion: 0.06
Nodes (85): addWorktreeAction(), agentInfo(), applyState(), buildRepoRow(), cdToWorktree(), clearRoot(), commitAction(), copyCommitID() (+77 more)

### Community 13 - "Tests: HarnessTerminalEngineTests / KittyKeyboardTests"
Cohesion: 0.15
Nodes (3): KittyKeyboardTests, String, UInt8

### Community 14 - "Terminal Engine: Parser / VTParser"
Cohesion: 0.10
Nodes (20): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+12 more)

### Community 15 - "Tests: HarnessCoreTests / FormatStringTests"
Cohesion: 0.11
Nodes (16): inputModes(), resetCursorRects(), HarnessTerminalSurfaceView, RawSelection, Bool, CGFloat, CGRect, NSEvent (+8 more)

### Community 17 - "HarnessCore: ACP / ACPClient"
Cohesion: 0.11
Nodes (15): Bool, IndexSet, TerminalDamage, MetalRendererTests, RenderedFixture, Bool, MTLDevice, MTLTexture (+7 more)

### Community 18 - "Tests: HarnessDaemonTests / ScrollbackFileTests"
Cohesion: 0.06
Nodes (21): HarnessUILibrary, HarnessUILibrary — Robot Framework keyword library for Harness terminal automati, Verify a board column exists using harness CLI., Run a harness CLI command and assert exit code 0., Run harness view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 19 - "Terminal Engine: HarnessTerminalEngine / InputEncoder"
Cohesion: 0.04
Nodes (48): SpecialKey, backspace, capsLock, deleteForward, down, end, enter, escape (+40 more)

### Community 21 - "Terminal Kit: HarnessTerminalKit / HarnessTerminalSurfaceView"
Cohesion: 0.08
Nodes (18): NSDraggingInfo, NSDragOperation, HarnessTerminalSurfaceView, Any, Bool, CGFloat, NSEvent, NSMenu (+10 more)

### Community 22 - "HarnessCore: Agents / AgentHookInstaller"
Cohesion: 0.06
Nodes (31): CopyModeAction, beginSelection, bottom, cancel, clearSelection, copyPipe, copySelection, copySelectionAndCancel (+23 more)

### Community 23 - "Daemon: HarnessDaemon / RealPty"
Cohesion: 0.15
Nodes (12): SplitPaneCoordinator, Bool, PaneID, PaneNode, SessionCoordinator, SessionID, SplitDirection, String (+4 more)

### Community 24 - "Tests: HarnessDaemonTests / DaemonRoundTripTests"
Cohesion: 0.13
Nodes (14): DaemonClient, ConcurrentIndexSet, DaemonContentionTests, String, URL, DaemonRoundTripTests, Data, Int32 (+6 more)

### Community 25 - "HarnessCore: Session / SessionEditor"
Cohesion: 0.08
Nodes (16): Bool, NSObjectProtocol, Set, String, WorktreeAutoIsolateService, Bool, String, TimeInterval (+8 more)

### Community 26 - "Docs: HARNESS_TMUX_CAPABILITIES"
Cohesion: 0.06
Nodes (37): 10. Status line, mouse, and options, 11. Shell integration, 12. Agent notifications, 13. Out-of-box troubleshooting, 14. One-page cheat sheet, 1. Five-minute setup, 2. Mental model, 3. Prefix key (+29 more)

### Community 27 - "Tests: HarnessTerminalRendererTests / CellColorResolverTests"
Cohesion: 0.23
Nodes (11): ANSIPalette, CellColorResolver, MochaTheme, ResolvedCellColors, RGBColor, Bool, Double, String (+3 more)

### Community 30 - "Harness App: UI / CommandPaletteController"
Cohesion: 0.09
Nodes (32): applyChrome(), closeFileTab(), eventIsInsideTerminalArea(), installCopySelectionToast(), navigateCurrentFile(), refreshTabBarMetadata(), refreshTerminalHostFill(), reloadTabBar() (+24 more)

### Community 31 - "Tests: HarnessCoreTests / IPCCodecTests"
Cohesion: 0.03
Nodes (88): JSONOutputFormatter, Bool, String, T, BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry (+80 more)

### Community 32 - "Tests: HarnessCoreTests / JSONMergeTests"
Cohesion: 0.16
Nodes (10): FileHandle, LSPTransport, LSPTransportBuffer, Data, String, TransportError, invalidContentLength, invalidUTF8Header (+2 more)

### Community 33 - "Tests: HarnessTerminalEngineTests / EngineConformanceTests"
Cohesion: 0.04
Nodes (42): Bool, CAMetalDrawable, RGBColor, String, UInt64, TerminalEmulator, RawSelection, Bool (+34 more)

### Community 34 - "Theme: HarnessTheme / ThemeDocument"
Cohesion: 0.13
Nodes (12): String, HarnessCLI, String, HarnessCLI, String, HarnessCLI, Bool, String (+4 more)

### Community 37 - "Harness App: UI / GitPanelView"
Cohesion: 0.23
Nodes (6): FormatColor, ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 39 - "HarnessCore: Settings / HarnessSettings"
Cohesion: 0.19
Nodes (14): TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid, RenderColor (+6 more)

### Community 40 - "Tests: HarnessTerminalEngineTests / ParserRobustnessTests"
Cohesion: 0.10
Nodes (20): HarnessSettings, LegacyHarnessSettingsCodingKeys, commandFinishedNotifications, tmuxControlsEnabled, ResizeOverlayMode, afterFirst, always, never (+12 more)

### Community 41 - "Harness CLI: HarnessCLI / WindowAttachClient"
Cohesion: 0.22
Nodes (7): CodingKeys, error, id, jsonrpc, method, params, String

### Community 42 - "Copy Mode: HarnessCopyMode / CopyModeState"
Cohesion: 0.11
Nodes (41): addSession(), addSessionInGroup(), agentsButtonClicked(), applyChromeColors(), confirmDeleteWorkspace(), deleteWorkspaceFromMenu(), dismissAgentsInbox(), fetchRepoName() (+33 more)

### Community 43 - "Tests: HarnessTerminalKitTests / RenderSchedulerTests"
Cohesion: 0.16
Nodes (5): RenderScheduler, Bool, Void, RenderSchedulerTests, Bool

### Community 44 - "Tests: HarnessCoreTests / PaneRectSolverTests"
Cohesion: 0.09
Nodes (17): OverlayBackground, Context, OverlayBackground, Context, ChromeBackdrop, ChromeRole, sidebar, tabBar (+9 more)

### Community 45 - "HarnessCore: Models / SessionSnapshot"
Cohesion: 0.07
Nodes (50): appendingPeekRow(), commitGridSize(), computeGridGeometry(), layout(), PendingMainHop, PresentAttempt, encodeFailure, nilDrawable (+42 more)

### Community 46 - "HarnessCore: Commands / CopyModeAction"
Cohesion: 0.15
Nodes (15): CommandParseError, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand, unterminatedString (+7 more)

### Community 47 - "Tests: HarnessDaemonTests / SurfaceRegistryTests"
Cohesion: 0.17
Nodes (5): RasterizedGlyph, CGContext, CGGlyph, UInt8, GlyphRasterizerTests

### Community 48 - "HarnessCore: Events / HookRegistry"
Cohesion: 0.07
Nodes (33): Executor, Hook, HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane (+25 more)

### Community 49 - "Daemon: HarnessDaemon / DaemonServer"
Cohesion: 0.13
Nodes (19): DispatchSourceWrite, ClientRecord, CountBox, DaemonServer, PendingBrowserRequest, PendingWrite, Bool, CheckedContinuation (+11 more)

### Community 51 - "Tests: HarnessTerminalKitTests / GridCompositorCopyModeTests"
Cohesion: 0.32
Nodes (5): SpecialKeyMappingTests, Bool, NSEvent, String, UInt16

### Community 54 - "Harness App: UI / HarnessSidebarPanelViewController"
Cohesion: 0.08
Nodes (18): EditorDividerView, HitTestPassthroughView, loadView(), openFileTab(), PaneDragGripView, PaneHoverButton, paneShell(), PaneSplitButtonsView (+10 more)

### Community 55 - "Tests: HarnessCoreTests / AgentHookInstallerTests"
Cohesion: 0.15
Nodes (10): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+2 more)

### Community 56 - "Tests: HarnessCoreTests / TargetSpecTests"
Cohesion: 0.13
Nodes (13): DirectoryItemRow, DirectoryPanel, DirectoryPickerController, DirectoryPickerFooter, DirectoryPickerModel, DirectoryPickerView, DirectoryWindowDelegate, String (+5 more)

### Community 57 - "HarnessCore: Commands / TargetSpec"
Cohesion: 0.14
Nodes (28): Cleanup Test Repo, Close Isolated Session Keeps Dirty Worktree, Close Isolated Session Removes Clean Worktree, Close One Isolated Does Not Affect Another, Close Session With Split Panes Removes Worktree, Create Isolated Session, Create Isolated Session Via CLI, Get Active Pane (+20 more)

### Community 58 - "Tests: HarnessCoreTests / PasteBufferStoreTests"
Cohesion: 0.16
Nodes (10): Buffer, Configuration, PasteBufferStore, Bool, Data, Date, String, URL (+2 more)

### Community 59 - "Agent Memory: plans / panel-session-performance"
Cohesion: 0.06
Nodes (32): 1. ภาพรวมสถาปัตยกรรม (Architecture Overview), ✅ 2.1 `sidebarRows` คำนวณซ้ำ O(N²) ทุกครั้งที่ reload ตาราง — DONE, ⚠️ 2.2 Blocking IPC บน Main Thread — PENDING (P2), ✅ 2.3 การ scan แบบ triple-nested ต่อ sync — DONE, ✅ 2.4 `applyThemeToAllHosts()` ทำงานทุก non-metadata sync — DONE, ✅ 2.5 Split view double-layout เมื่อ switch tab — DONE, ✅ 2.6 Metadata refresh probe ทุก tab ทุก 2 วินาที — DONE, 2. ปัญหาและแนวทางแก้ไข (Issues & Fixes) (+24 more)

### Community 60 - "AIDLC: harness / ide-file-tree / outputs / domain-decomposition"
Cohesion: 0.22
Nodes (9): FormatContext, FormatString, FormatStyle, Bool, Character, Date, FormatColor, String (+1 more)

### Community 61 - "Tests: HarnessCoreTests / KeyTableTests"
Cohesion: 0.15
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 62 - "Onboarding: TerminalKit / GridCompositor"
Cohesion: 0.05
Nodes (43): CellMetrics, ColorKind, bg, fg, underline, ComposedCell, ComposedFrame, CompositorPane (+35 more)

### Community 63 - "Tests: HarnessTerminalKitTests / LiveResizeTests"
Cohesion: 0.13
Nodes (16): CLIInstallLocator, DetachKeys, absent, invalid, parsed, HarnessCLI, OptionalUUID, absent (+8 more)

### Community 64 - "Daemon: HarnessDaemon / SurfaceRegistry"
Cohesion: 0.12
Nodes (15): agentDetail(), String, AgentListFormatter, Date, String, cols, AgentSessionSummary, Bool (+7 more)

### Community 65 - "HarnessCore: IPC / IPCCodec"
Cohesion: 0.11
Nodes (13): Group, ParsedShortcut, PrefixCheatsheetWindow, PrefixIndicatorWindow, PrefixKeymap, Any, CGFloat, NSEvent (+5 more)

### Community 66 - "Terminal Kit: HarnessTerminalKit / HarnessTerminalSurfaceView"
Cohesion: 0.06
Nodes (30): CLICommand, CLICommandCatalog, Bool, String, CompletionGenerator, String, InstallResult, ShellCompletionInstaller (+22 more)

### Community 67 - "Terminal Kit: HarnessTerminalKit / TerminalHostView"
Cohesion: 0.14
Nodes (13): InstallResult, Profile, Shell, bash, fish, zsh, ShellProfileInstaller, Bool (+5 more)

### Community 68 - "HarnessCore: ACP / ACPMessage"
Cohesion: 0.06
Nodes (36): Completed Plans Archive, HarnessCore Package Split (v3.9.0), P10 — Terminal Performance and Convenience, P11 — Scripting & Config API (WezTerm parity), P12 — Agent Orchestration via MCP, P13 — Split Pane Parity, P14 — Embedded Browser Pane, P15 — Integration Roadmap (+28 more)

### Community 69 - "Harness App: Settings / KeyRecorderView"
Cohesion: 0.18
Nodes (21): acceptsFirstMouse(), becomeFirstResponder(), clear(), hitTest(), init(), keyDown(), keyModifiers(), mouseDown() (+13 more)

### Community 70 - "Harness App: UI / HarnessControls"
Cohesion: 0.19
Nodes (16): PaletteFooter, SidebarBadgeLabel, SidebarDividerRow, SidebarGroupHeaderRow, SidebarSessionItemRow, SidebarSessionListView, SidebarWorktreeHeaderRow, SidebarWorktreeItemRow (+8 more)

### Community 71 - "Harness App: UI / MenuBarController"
Cohesion: 0.17
Nodes (7): ImportedTerminalConfig, Bool, Double, Float, String, TerminalConfigImporter, TerminalConfigImporterTests

### Community 72 - "Harness CLI: HarnessCLI / WindowAttachClient"
Cohesion: 0.15
Nodes (7): GitPanelView, NSGestureRecognizerDelegate, GitPanelViewDiffErrorTests, String, GitPanelViewDiffPopoverTests, GitPanelViewFSEventFilterTests, GitPanelViewWorktreeAgentTests

### Community 73 - "Tests: HarnessDaemonTests / HookFiringTests"
Cohesion: 0.08
Nodes (18): Claude Code → Harness, Customizing, One-line install, Verifying, What gets written, Codex → Harness, One-line install, What you'll see (+10 more)

### Community 75 - "Terminal Kit: HarnessTerminalKit / GridCompositor"
Cohesion: 0.11
Nodes (19): OptionStore, OptionStore.Value, Scope, pane, session, tab, workspace, ScopedKey (+11 more)

### Community 76 - "HarnessCore: Agents / AgentSnapshot"
Cohesion: 0.18
Nodes (4): SessionSnapshot, String, UUID, TargetSpecTests

### Community 77 - "AIDLC: harness / ide-file-tree / outputs / domain-design"
Cohesion: 0.12
Nodes (9): State, error, indeterminate, paused, remove, set, TerminalProgressReport, TerminalEmulator (+1 more)

### Community 79 - "HarnessCore: Keybindings / KeyTable"
Cohesion: 0.12
Nodes (15): AgentStatusDot, Context, HarnessMotion, StatusDotView, Style, accent, agent, agentWorking (+7 more)

### Community 80 - "Docs: AGENT-HANDBOOK"
Cohesion: 0.09
Nodes (20): Build / Test / Run, Graphify, harness-terminal — Claude Instructions, Non-obvious Constraints, Session Start, Skills, Agent handbook — Harness (extended reference), Agent integration (+12 more)

### Community 81 - "Tests: HarnessCoreTests / DaemonClientTests"
Cohesion: 0.11
Nodes (23): DaemonSubscription, Bool, Data, Int32, TimeInterval, UInt64, UUID, Void (+15 more)

### Community 82 - "Tests: HarnessCoreTests / HarnessSettingsTests"
Cohesion: 0.15
Nodes (16): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+8 more)

### Community 83 - "HarnessCore: ACP / ACPTransport"
Cohesion: 0.17
Nodes (10): Result, AsyncCLIResultBox, HarnessCLI, LSPDefinitionPayload, LSPDiagnosticsPayload, LSPStatusPayload, Error, String (+2 more)

### Community 84 - "Tests: HarnessCoreTests / CommandParserTests"
Cohesion: 0.07
Nodes (31): ViDiagnosticNavigator, Equatable, JSONRPCId, int, string, CodingKeys, error, id (+23 more)

### Community 85 - "Harness App: UI / SearchPanelView"
Cohesion: 0.08
Nodes (33): NotificationPermission, State, denied, granted, undetermined, MainActor, Bool, UInt8 (+25 more)

### Community 86 - "Harness App: UI / GitPanelView"
Cohesion: 0.08
Nodes (8): HarnessPaths, HarnessSettings, Bool, Data, HarnessPathsTests, String, URL, Void

### Community 87 - "Harness App: Services / SessionCoordinator"
Cohesion: 0.03
Nodes (20): SessionCoordinator, Bool, Date, Double, Error, PaneID, PaneNode, SessionGroup (+12 more)

### Community 88 - "Docs: MULTIPLEXER_GUIDE"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 89 - "HarnessCore: Remote / SSHTunnelManager"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Harness, Sparkle (+13 more)

### Community 90 - "Tests: HarnessCoreTests / AgentNotchProjectionTests"
Cohesion: 0.08
Nodes (25): 10. Universal retire-hold via `removeFromSuperview()` override (definitive), 11. NSEvent local monitor installed in AppDelegate (fix #8 actually deployed), 12. `nonisolated` + `MainActor.assumeIsolated` on high-frequency AppKit callbacks (2026-06-21), 1. `TerminalPaneRegistry.retire()` — deferred dealloc (500ms), 2. Remove `nonisolated` from all layout overrides, 3. Remove `MainActor.assumeIsolated` from callbacks, 4. Detach NSHostingView on teardown (FileTreeSwiftUIView), 5. Avoid `Optional.map {}` in @MainActor code (+17 more)

### Community 91 - "Terminal Engine: HarnessTerminalEngine / InputEncoder"
Cohesion: 0.27
Nodes (9): InputEncoder, KeyEventType, press, release, `repeat`, KeyModifiers, Character, String (+1 more)

### Community 92 - "Agent Memory: plans / p2-async-ipc-design"
Cohesion: 0.08
Nodes (25): code:swift (// DaemonSessionService.swift), code:swift (// ต้องคงเป็น sync เพราะเรียกก่อน process exit), code:swift (// ปัจจุบัน: DispatchQueue.global + DispatchQueue.main.async), code:text (1. DaemonClientActor (new file, ไม่ break อะไร)), code:text (Before:), code:swift (// DaemonClientActor.swift (new)), code:swift (func fetchSnapshot() async throws -> SessionSnapshot {), code:swift (// Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonClient) (+17 more)

### Community 94 - "Tests: HarnessCoreTests / AttachInputBatcherTests"
Cohesion: 0.22
Nodes (8): C, AttachInputBatcher, Outcome, Bool, Data, UInt8, AttachInputBatcherTests, UInt8

### Community 95 - "Tests: HarnessTerminalRendererTests / FrameBuilderTests"
Cohesion: 0.15
Nodes (12): termios, AttachClient, Configuration, LiveSession, Bool, Data, DispatchSourceSignal, Int32 (+4 more)

### Community 96 - "Tests: HarnessTerminalKitTests / GridCompositorTests"
Cohesion: 0.17
Nodes (12): 1. Install Harness, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Harness Usage, More Docs (+4 more)

### Community 97 - "Onboarding: TerminalKit / PaneLayout"
Cohesion: 0.11
Nodes (16): AnyObject, TimeInterval, ZombieHoldRegistry, collectTerminalHosts(), PaneContainerView, SessionSnapshot, SurfaceID, PaneLifecycleManager (+8 more)

### Community 98 - "AIDLC: harness / acp / outputs / logical-design"
Cohesion: 0.67
Nodes (3): 4.1 Architecture Pattern, 4. Technical Architecture, 4.2 Technology Stack

### Community 99 - "Harness App: Services / MainExecutor"
Cohesion: 0.14
Nodes (12): DisplayMessage, MainExecutor, RunShell, Bool, Command, ContentAreaViewController, MainActor, PaneID (+4 more)

### Community 100 - "Onboarding: Design / Components"
Cohesion: 0.36
Nodes (5): ShellInfo, ShellStepView, Bool, String, URL

### Community 101 - "Agent Memory: plans / session-group-split-session"
Cohesion: 0.10
Nodes (20): 1. Add Project Group Heuristics, 1. Keep Split State In Session/Tab Structure, 2. Introduce Sidebar Row Model, 2. UX Entry Points, 3. Build Grouped Rows From Filtered Sessions, 4. Update Table Data Source and Delegate, 5. Drag and Drop Rules, code:text (Window) (+12 more)

### Community 102 - "Harness App: Services / DaemonLauncher"
Cohesion: 0.18
Nodes (8): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, URL

### Community 103 - "Tests: HarnessTerminalEngineTests / HarnessGridTerminalTests"
Cohesion: 0.15
Nodes (14): AnyCodable, array, bool, double, int, null, string, JSONRPCError (+6 more)

### Community 104 - "Tests: HarnessTerminalEngineTests / CodepointRunFastPathTests"
Cohesion: 0.09
Nodes (19): RecipeItemRow, RecipePanel, RecipePickerController, RecipePickerFooter, RecipePickerModel, RecipePickerView, RecipeWindowDelegate, AttributedString (+11 more)

### Community 105 - "Release Notes: CHANGELOG"
Cohesion: 0.08
Nodes (24): [1.0.0] - 2026-05-31, [2.2.0] - 2026-06-07, [2.2.2] - 2026-06-08, [2.5.2] - 2026-06-12, [3.11.2] - 2026-06-28, [3.11.4] - 2026-06-28, [3.11.7] - 2026-06-29, [3.1.3] - 2026-06-16 (+16 more)

### Community 107 - "Harness App: UI / Notch / AgentNotchViewModel"
Cohesion: 0.07
Nodes (21): AnyCancellable, AgentNotchViewModel, AgentNotchWindowActivator, Animation, Bool, CGFloat, Date, Never (+13 more)

### Community 108 - "Harness App: UI / HarnessControls"
Cohesion: 0.17
Nodes (17): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, PaneLeaf, PaneNode (+9 more)

### Community 109 - "Tests: HarnessCoreTests / PaneStyleTests"
Cohesion: 0.17
Nodes (3): DamageTrackingTests, IndexSet, TerminalEmulator

### Community 110 - "Harness CLI: HarnessCLI / AttachClient"
Cohesion: 0.06
Nodes (34): String, AgentChipView, BoardColumnKind, Divider, FontSize, HarnessDesign, HarnessPillButton, IconSize (+26 more)

### Community 112 - "Tests: HarnessTerminalEngineTests / ThaiCombiningMarkTests"
Cohesion: 0.16
Nodes (12): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, SessionSnapshot, String, Tab (+4 more)

### Community 113 - "HarnessCore: Persistence / SessionStore"
Cohesion: 0.13
Nodes (9): HarnessGridTerminal, Bool, Data, String, TerminalEmulator, TerminalGridCell, TerminalGridSnapshot, UInt8 (+1 more)

### Community 115 - "Harness App: UI / HarnessDesign"
Cohesion: 0.09
Nodes (23): header, String, UInt16, DecodedReplyFrame, output, reply, DecodedRequestFrame, input (+15 more)

### Community 116 - "Harness App: UI / PrefixKeymap"
Cohesion: 0.23
Nodes (10): Array, SessionGroup, SessionSnapshot, Bool, Decoder, SessionID, String, Tab (+2 more)

### Community 117 - "Harness App: UI / WorkspaceFileTreeView"
Cohesion: 0.08
Nodes (27): BrowserLeaf, CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf (+19 more)

### Community 118 - "Theme: HarnessTheme / ThemeDiagnostics"
Cohesion: 0.21
Nodes (9): FileTreeContext, Bool, NSCoder, NSHostingView, NSWindow, SessionID, String, Void (+1 more)

### Community 119 - "Docs: COMMANDS"
Cohesion: 0.12
Nodes (16): Attaching from a plain terminal, Bindings, Buffers (paste store), Composition, Harness command reference, Hooks, Inspection (CLI / control mode), Local diagnostics (+8 more)

### Community 122 - "Tests: HarnessTerminalEngineTests / ImageProtocolTests"
Cohesion: 0.29
Nodes (3): Install, Shell integration (OSC 133 semantic prompts), What gets emitted

### Community 123 - "HarnessCore: Commands / Command"
Cohesion: 0.11
Nodes (23): RepoGitMetadata, SidebarListModel, SidebarSessionRow, divider, groupHeader, session, worktree, worktreeHeader (+15 more)

### Community 124 - "HarnessCore: Options / EnvironmentStore"
Cohesion: 0.12
Nodes (3): FormatStringExtendedVariableTests, FormatStringTests, FormatStyledTests

### Community 125 - "Terminal Engine: Screen / HistoryRingBuffer"
Cohesion: 0.12
Nodes (9): ContiguousArray, IteratorProtocol, HistoryRingBuffer, Iterator, Bool, Element, S, Sequence (+1 more)

### Community 126 - "Onboarding: Design / AgentMark"
Cohesion: 0.08
Nodes (25): AgentArt, AgentMark, AgentMarkShape, AgentVectorIcon, Scanner, SVGPath, Bool, CGFloat (+17 more)

### Community 127 - "Copy Mode: HarnessCopyMode / CopyModeReducer"
Cohesion: 0.16
Nodes (17): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, GlyphAtlasStats, GlyphKey, ShapedGlyphKey, Bool (+9 more)

### Community 129 - "HarnessCore: Settings / TerminalConfigImporter"
Cohesion: 0.07
Nodes (24): AgentRow, HookState, failed, idle, installed, installing, SettingsAgentsView, Bool (+16 more)

### Community 130 - "Daemon: HarnessDaemon / DaemonMetrics"
Cohesion: 0.11
Nodes (17): code:bash (harness-cli doctor), AI Browser Control (harness-mcp), Build From Source, CLI, Development Builds, Documentation, Editor & LSP, Harness (+9 more)

### Community 131 - "Tests: HarnessTerminalEngineTests / VTConformanceCorpusTests"
Cohesion: 0.12
Nodes (5): AgentHookInstallerTests, String, URL, AgentHookInstallerCLI, String

### Community 132 - "Terminal Kit: HarnessTerminalKit / TerminalHostView"
Cohesion: 0.16
Nodes (16): AgentHookInstaller, escapedForJSON(), InstallResult, notifyCommand(), notifyFromHookCommand(), osc26AndNotify(), osc26AndNotifyFromHook(), osc26Emit() (+8 more)

### Community 133 - "Tests: HarnessTerminalEngineTests / DamageTrackingTests"
Cohesion: 0.23
Nodes (7): KeybindingsStore, URL, KeybindingsStoreTests, URL, Void, HarnessCLI, String

### Community 135 - "Harness App: Settings / SettingsViewController"
Cohesion: 0.15
Nodes (15): CommandIPCTranslator, CommandTarget, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID (+7 more)

### Community 136 - "Harness App: UI / AgentIconRenderer"
Cohesion: 0.26
Nodes (7): FSEventStreamBox, escaping, MainActor, UnsafeMutableRawPointer, Void, WatcherContext, FSEventStreamRef

### Community 137 - "Onboarding: UI / ImmersiveOnboardingWindowController"
Cohesion: 0.15
Nodes (9): ActivePaneService, Bool, PaneID, PaneNode, SessionCoordinator, Set, SurfaceID, Tab (+1 more)

### Community 138 - "AIDLC: harness / acp / planning / 05-implementation"
Cohesion: 0.67
Nodes (3): Future User Stories (Post-MVP), MVP User Stories (Must Implement), User Story Mapping (MANDATORY)

### Community 139 - "Agent Memory: plans / file-viewer-integration"
Cohesion: 0.11
Nodes (18): 1.1 โครงสร้างการทำงานของ Quick Look (Quick Look Architecture), 1.2 สองคลาสหลักในการใช้งาน (QLPreviewPanel vs. QLPreviewView), 1. เบื้องหลังการทำงานของระบบพรีวิวบน macOS (Under the Hood: macOS Quick Look), 2. การกำหนดลำดับขั้นการคัดแยกประเภทไฟล์ (File Routing Model), 3. แผนการแบ่งแทร็กการพัฒนา (Development Tracks), 4.1 ตัวจัดการควบคุมกลยุทธ์การพรีวิว (File Preview Strategy Protocol), 4.2 คอนโทรลเลอร์แสดงผลไฟล์หลัก (FileViewerViewController), 4.3 ตัวพรีวิวเนทีฟด้วย Quick Look (macOSQuickLookStrategy) (+10 more)

### Community 142 - "Release Notes: CHANGELOG"
Cohesion: 0.27
Nodes (7): CopyModeGridSource, CopyModeReducer, Bool, Character, Range, String, GridPosition

### Community 143 - "Tests: HarnessTerminalEngineTests / TerminalBufferSearchTests"
Cohesion: 0.10
Nodes (19): 1. Find the CLI, 2. Check daemon health, 3. List what's running (like `tmux ls`), 4. Attach to a pane, 5. Create sessions/tabs from a script, 6. Drive a pane without attaching, 7. tmux control mode, 8. Remote/headless daemon (+11 more)

### Community 144 - "HarnessCore: IPC / DaemonSessionService"
Cohesion: 0.20
Nodes (6): PaneStyle, PaneStyleSet, Bool, FormatColor, String, PaneStyleTests

### Community 145 - "Tests: HarnessTerminalEngineTests / AsciiFastPathTests"
Cohesion: 0.18
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 146 - "Tests: HarnessThemeTests"
Cohesion: 0.07
Nodes (35): CGImage, data, DecodedImage, ImageLimits, Bool, UInt8, ImageDecoder, rasterize() (+27 more)

### Community 147 - "AIDLC: harness / ide-file-tree / planning / 05-implementation"
Cohesion: 0.29
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 148 - "Harness App: Services / SessionCoordinator"
Cohesion: 0.07
Nodes (23): CaseIterable, Mode, compatible, harness, TerminalIdentity, ExperienceMode, agent, full (+15 more)

### Community 149 - "Root Docs: README"
Cohesion: 0.23
Nodes (7): EnvironmentStore, Persisted, String, URL, global, EnvironmentStoreTests, URL

### Community 150 - "Harness App: UI / AgentChatPanelView"
Cohesion: 0.13
Nodes (12): Decodable, SplitDirection, String, HarnessDaemonToolsTests, String, URL, Document, Bool (+4 more)

### Community 151 - "Harness App: UI / HarnessControls"
Cohesion: 0.29
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 153 - "Harness App: UI / Notch / NotchPanelController"
Cohesion: 0.19
Nodes (17): Close Pane, Next Session, Previous Session, Split Down, Split Right, Cmd W Closes Pane When Split, Zombie Crash Rapid Close While Typing, Zombie Crash Rapid Split Close Cycle (+9 more)

### Community 154 - "AIDLC: harness / ide-file-tree / outputs / logical-design"
Cohesion: 0.12
Nodes (3): LiveResizeTests, HarnessTerminalSurfaceView, NSWindow

### Community 155 - "Onboarding: Install / BinaryInstaller"
Cohesion: 0.09
Nodes (27): ImagePlacementSnapshot, Bool, String, UInt8, TerminalCellWidth, normal, spacerTail, wide (+19 more)

### Community 156 - "HarnessCore: Notch / AgentNotchProjection"
Cohesion: 0.09
Nodes (12): Range, String, TerminalGridCell, TerminalBufferMatch, TerminalBufferSearch, String, TerminalGridCell, TerminalBufferSearchTests (+4 more)

### Community 158 - "Docs: IDE-SIDEBAR"
Cohesion: 0.12
Nodes (15): Architecture, Branch, Build & Preview, CMUX Pane Splitting, code:block1 (worktree-feature+acp-aidlc), code:bash (cd /tmp/hp  # symlink to worktree (socket path length limit)), code:block3 (HarnessSidebarPanelViewController — Sessions / Files / Git t), Features (+7 more)

### Community 159 - "HarnessCore: FileExplorer / FileTreeWatcher"
Cohesion: 0.14
Nodes (16): FileTreeScanOptions, MatchCategory, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith, filenameStartsWith, fuzzy (+8 more)

### Community 160 - "Harness App: UI / CommandPaletteController"
Cohesion: 0.27
Nodes (6): AmbientBackground, Bool, CGSize, GraphicsContext, TimeInterval, UInt8

### Community 161 - "Tests: HarnessDaemonTests / VersionBannerTests"
Cohesion: 0.15
Nodes (12): Reason, errored, finished, needsInput, RowState, Bool, Comparable, AgentActivity (+4 more)

### Community 162 - "Terminal Kit: HarnessTerminalKit / TerminalFindBar"
Cohesion: 0.09
Nodes (14): NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent, NSImage (+6 more)

### Community 163 - "Terminal Kit: HarnessTerminalKit / TerminalHostView"
Cohesion: 0.13
Nodes (17): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+9 more)

### Community 164 - "Tests: HarnessCoreTests / HarnessPathsTests"
Cohesion: 0.14
Nodes (6): Tab, SessionPersistenceTests, Bool, String, TabID, URL

### Community 165 - "Tests: HarnessCoreTests / TerminalRecordingTests"
Cohesion: 0.29
Nodes (6): ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy

### Community 166 - "HarnessCore: Diagnostics / DoctorRunner"
Cohesion: 0.25
Nodes (15): handleAttach(), handleAttachWindow(), handleKillServer(), handleRecord(), handleReplay(), handleStartServer(), handleStopServer(), isLiveHarnessDaemon() (+7 more)

### Community 167 - "HarnessCore: ACP / ACPSession"
Cohesion: 0.15
Nodes (7): AgentTableEntry, Bool, Set, String, AgentTitleInference, Bool, AgentDetectorTests

### Community 170 - "Terminal Kit: HarnessTerminalKit / ThemeManager"
Cohesion: 0.23
Nodes (6): Bool, Range, String, tokenMatch(), URLDetection, StringProtocol

### Community 171 - "HarnessCore: Commands / TargetSpec"
Cohesion: 0.26
Nodes (5): Case, ReflowCorpusTests, String, TerminalEmulator, URL

### Community 173 - "HarnessCore: Shell / ShellIntegration"
Cohesion: 0.13
Nodes (14): concurrency, cancel-in-progress, group, env, jobs, Benchmarks (non-blocking), Build & test (macOS), Format lint (advisory) (+6 more)

### Community 174 - "Harness CLI: HarnessCLI"
Cohesion: 0.27
Nodes (6): BinaryRefresher, Bool, URL, BinaryRefresherTests, String, URL

### Community 175 - "HarnessCore: IPC / IPCMessage"
Cohesion: 0.08
Nodes (6): IPCCodecInvariantTests, CommandFinishedTests, HarnessTerminalSurfaceDragDropTests, HarnessTerminalSurfaceFocusTests, RGBColorTests, XCTestCase

### Community 177 - "AIDLC: harness / acp / outputs / user-stories"
Cohesion: 0.23
Nodes (4): PaneRectSolverTests, Bool, PaneNode, PaneRect

### Community 178 - "Tests: HarnessCoreTests / SessionEditorPhase4Tests"
Cohesion: 0.12
Nodes (13): InlineAICompletionController, HarnessSettings, String, InlineAICompletionView, Bool, NSCoder, NSEvent, NSRect (+5 more)

### Community 179 - "Onboarding: UI / WelcomeStepView"
Cohesion: 0.40
Nodes (5): [3.13.0] - 2026-07-02, Added, Changed, Documentation, Fixed

### Community 180 - "Harness CLI: HarnessCLI / WindowAttachClient"
Cohesion: 0.22
Nodes (3): String, TerminalGridSnapshot, VTConformanceCorpusTests

### Community 181 - "Copy Mode: HarnessCopyMode / CopyModeGridSource"
Cohesion: 0.20
Nodes (5): CompositorPane, GridCompositorTests, Bool, String, TerminalGridSnapshot

### Community 182 - "HarnessCore: ACP / ACPProcess"
Cohesion: 0.11
Nodes (19): Already portable or mostly portable, Build matrix, Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), First Implementation Slice, Integration tests (+11 more)

### Community 183 - "HarnessCore: Keybindings / KeyTokenParser"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 185 - "Terminal Renderer: HarnessTerminalRenderer / TerminalFrame"
Cohesion: 0.15
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 186 - "Tests: HarnessTerminalEngineTests / ReflowCorpusTests"
Cohesion: 0.13
Nodes (11): os, Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow, launchStart (+3 more)

### Community 187 - "Tests: HarnessTerminalEngineTests / ScrollbackTests"
Cohesion: 0.19
Nodes (9): AppDelegate, QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL, TerminalServicesProvider, NSApplication (+1 more)

### Community 188 - "Harness App: UI / ContentAreaViewController"
Cohesion: 0.04
Nodes (47): BrowserIntegrationController, NSView, PaneID, BrowserPaneRegistry, BrowserPaneView, BrowserProgressLine, BrowserTab, BrowserTabButton (+39 more)

### Community 189 - "Agent Memory: plans / p5-acp-implementation"
Cohesion: 0.12
Nodes (16): Architecture, Bounded Contexts, code:block1 (Agent Process (Claude Code / Codex / Gemini)), code:block2 (Packages/HarnessCore/Sources/HarnessCore/ACP/), code:block3 (Content-Length: 123\r\n), Estimate, Goal, Key Files (New) (+8 more)

### Community 191 - "AIDLC: harness / ide-file-tree / planning / 00-inception-plan"
Cohesion: 0.09
Nodes (10): PluginLoader, String, ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String (+2 more)

### Community 192 - "Tests: HarnessTerminalEngineTests / HistoryRingBufferTests"
Cohesion: 0.26
Nodes (14): Agent Command Does Not Crash, Agent Waiting Filter Does Not Crash, Board Command Shows Board Panel, Cd Command Switches To Matching Tab, Copy Path Command Does Not Crash, Errors Command Does Not Crash, Find Command Opens Command Palette On Empty Query, Find Command Resolves Unique File (+6 more)

### Community 193 - "Terminal Renderer: HarnessTerminalRenderer / TerminalMetalRenderer"
Cohesion: 0.16
Nodes (14): CLI Isolate Creates Worktree And Session, CLI Isolate With Custom Branch Name, Close Session Keeps Dirty Worktree, Close Session Removes Clean Worktree, Create Isolated Session And Select, Drag Reorder Past Worktree Row No Crash, Git Checkout In Normal Session Does Not Affect Isolated, Isolate Without Branch Uses Detached HEAD (+6 more)

### Community 194 - "Harness App: UI / HarnessDesign"
Cohesion: 0.11
Nodes (17): Agent Detection, Branch Detection Flow, Branch Label, Chrome Roles, Drag Reorder, File, Files, Git Branch Detection (+9 more)

### Community 195 - "Harness App: UI / HarnessDesign"
Cohesion: 0.17
Nodes (7): ResizeHUDView, DispatchWorkItem, NSCoder, NSColor, NSPoint, NSRect, TimeInterval

### Community 196 - "Harness App: UI / HarnessControls"
Cohesion: 0.14
Nodes (13): ACP (Agent Client Protocol) — tried, shelved, erased, Command Palette / Power-User Terminal Features, Embedded Browser, Feature Provenance — harness-terminal, Git Panel, Harness MCP, IDE Track — File Tree / Editor / LSP (the "Zed half" made real), Notifications (+5 more)

### Community 197 - "HarnessCore: CLI / TerminalRecording"
Cohesion: 0.21
Nodes (3): SessionID, String, WorkspaceID

### Community 198 - "Tests: HarnessCoreTests / SessionPersistenceTests"
Cohesion: 0.17
Nodes (11): #harness, #practice, #practice-terminal, #practice-terminal-input, #practice-terminal-output, #score, #shell, #total (+3 more)

### Community 200 - "HarnessCore: Agents / AgentDetector"
Cohesion: 0.23
Nodes (5): URL, HarnessCLI, HarnessFilePreviewLoader, FileManager, String

### Community 201 - "HarnessCore: Agents / AgentDetector"
Cohesion: 0.12
Nodes (16): Agent Config Wiring, Agents, Architecture, Browser Pane, File I/O, Git, Key Files, MCP Server (harness-mcp) (+8 more)

### Community 202 - "HarnessCore: Commands / CommandIPCTranslator"
Cohesion: 0.12
Nodes (21): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, PaletteModel, PalettePanel (+13 more)

### Community 203 - "Docs: KEYBINDINGS"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Harness keybindings, Key spec syntax, Persistence (+1 more)

### Community 204 - "Docs: MIGRATION"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Harness the default terminal, Migrating to Harness

### Community 205 - "HarnessCore: ACP / ACPSession"
Cohesion: 0.09
Nodes (22): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect (+14 more)

### Community 206 - "Tests: HarnessCoreTests / BinaryRefresherTests"
Cohesion: 0.16
Nodes (12): ConfigError, unsupportedAgent, writeFailure, MCPConfigWriter, Any, Bool, String, URL (+4 more)

### Community 207 - "HarnessCore: Paths / HarnessPaths"
Cohesion: 0.12
Nodes (12): HarnessTerminalSurfaceView, NSEvent, RGBColor, String, emulatorSync(), scheduleRender(), HarnessTerminalSurfaceView, CGFloat (+4 more)

### Community 208 - "Terminal Renderer: HarnessTerminalRenderer / CellColorResolver"
Cohesion: 0.21
Nodes (7): HarnessCLI, SessionGroup, SessionSnapshot, String, UUID, T, Void

### Community 209 - "Terminal Engine: HarnessTerminalEngine / InputEncoder"
Cohesion: 0.27
Nodes (5): RemoteHost, SettingsRemoteView, Bool, RemoteHost, String

### Community 210 - "Tests: HarnessTerminalEngineTests / SemanticPromptTests"
Cohesion: 0.10
Nodes (18): PaneDragController, Any, Bool, NSEvent, NSView, NSWindow, PaneID, PaneDropZoneOverlay (+10 more)

### Community 211 - "HarnessCore: Format / FormatStyledSegment"
Cohesion: 0.12
Nodes (6): DaemonBrowserRoutingTests, String, URL, EndpointClientTests, String, URL

### Community 212 - "Tests: HarnessCoreTests / CommandIPCTranslatorTests"
Cohesion: 0.16
Nodes (5): CommandIPCTranslatorTests, Bool, CommandTarget, PaneID, TabID

### Community 213 - "Tests: HarnessCoreTests / FormatStyledTests"
Cohesion: 0.09
Nodes (20): DispatchTimeInterval, RealPty, ScrollbackEntry, ScrollbackReplaySegment, Bool, CChar, DaemonSurfaceID, Data (+12 more)

### Community 214 - "HarnessCore: Notch / NotchLayoutMetrics"
Cohesion: 0.23
Nodes (8): NotchGeometry, NotchLayoutMetrics, NotchRect, NotchScreenMetrics, Bool, Double, NSScreen, NotchLayoutMetricsTests

### Community 215 - "Tests: HarnessOnboardingTests / ShellProfileInstallerTests"
Cohesion: 0.26
Nodes (6): MainMenuBuilder, Bool, NSMenu, NSMenuItem, Selector, String

### Community 217 - "HarnessCore: Session / PaneRectSolver"
Cohesion: 0.17
Nodes (14): CompositorPane, GridCompositor, RenderCell, Bool, FormatColor, PaneRect, RenderCell, String (+6 more)

### Community 218 - "Onboarding: Install / NotificationPermission"
Cohesion: 0.13
Nodes (10): ScrollbackFile, Bool, Data, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 219 - "Harness App: Services / RemoteHostsService"
Cohesion: 0.15
Nodes (14): code:block1 (Refactor `Tools/harness/Sources/HarnessCLI/HarnessCLI.swift`), code:block2 (Extract pure input-routing logic from `Tools/harness/Sources), code:block3, code:block4, code:block5 (Decompose `Packages/HarnessDaemon/Sources/HarnessDaemon/Surf), code:block6, code:block7, code:block8 (+6 more)

### Community 220 - "Terminal Renderer: HarnessTerminalRenderer / GlyphAtlas"
Cohesion: 0.20
Nodes (6): ReleaseNotes, ReleaseNotes, Section, String, ReleaseNotesGuardTests, String

### Community 221 - "Harness App: UI / HarnessSidebarPanelViewController"
Cohesion: 0.33
Nodes (6): Bool, NSPasteboard, NSString, String, URL, AutoreleasingUnsafeMutablePointer

### Community 222 - "Harness App: UI / NotificationBellButton"
Cohesion: 0.11
Nodes (16): AgentNotchDashboardProjection, AgentNotchProjection, AgentNotchRowSummary, RowKind, agent, session, Date, SessionGroup (+8 more)

### Community 223 - "AIDLC: harness / acp / outputs / domain-decomposition"
Cohesion: 0.48
Nodes (3): ANSIPalette, RGBColor, UInt8

### Community 224 - "Scripts: terminal_stress_runner.py"
Cohesion: 0.30
Nodes (8): ANSIPalette, CellColorResolver, ResolvedCellColors, Bool, Double, RGBColor, TerminalGridCell, TerminalGridColor

### Community 226 - "AIDLC: harness / ide-file-tree / planning / 00-inception-decisions"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 227 - "Harness CLI: HarnessCLI / RecordClient"
Cohesion: 0.11
Nodes (19): Process, SSHTunnelError, exitedEarly, invalidConfiguration, launchFailed, notReady, SSHTunnelManager, Bool (+11 more)

### Community 229 - "Harness App: UI / SyntaxTextView"
Cohesion: 0.33
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 230 - "Tests: HarnessCoreTests / TabAlertTests"
Cohesion: 0.15
Nodes (4): HarnessGridTerminalTests, HarnessGridTerminal, String, TerminalGridSnapshot

### Community 231 - "Harness App: UI / HarnessSidebarPanelViewController"
Cohesion: 0.21
Nodes (8): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController

### Community 232 - "HarnessCore: Models / Workspace"
Cohesion: 0.11
Nodes (17): 1. Add a `pendingReflowTask` field to `TerminalScreen`, 2. Split `reflow(toCols:rows:)` into two helpers, 3. In `resize(cols:rows:)`, use the fast path first, Background, code:swift (// In TerminalScreen), code:swift (// Fast path — reflow only viewport + lookahead), code:swift (mutating func resize(cols nc: Int, rows nr: Int) {), code:swift (// TerminalEmulator: add a "live resize in progress" flag) (+9 more)

### Community 233 - "HarnessCore: Notifications / NotificationBus"
Cohesion: 0.26
Nodes (4): String, TerminalGridCell, TextGrid, WordColumnRangeTests

### Community 234 - "Harness App: Services / SessionCoordinator"
Cohesion: 0.13
Nodes (10): BellScanState, esc, normal, string, stringEsc, SurfaceMonitor, Data, BellScanTests (+2 more)

### Community 235 - "Terminal Kit: HarnessTerminalKit / TerminalHostView"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 238 - "Tests: HarnessCoreTests / TerminalBannerTests"
Cohesion: 0.17
Nodes (6): DefaultTerminalLaunchRequest, ShellQuoting, Bool, String, URL, DefaultTerminalLaunchRequestTests

### Community 239 - "Harness App: UI / HarnessSidebarPanelViewController"
Cohesion: 0.09
Nodes (43): MTLClearColor, MTLCommandBuffer, MTLCommandQueue, MTLLibrary, MTLPixelFormat, MTLRenderCommandEncoder, MTLRenderPipelineState, MTLSamplerState (+35 more)

### Community 240 - "Tests: HarnessOnboardingTests / BinaryInstallerVersionTests"
Cohesion: 0.17
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, Bool, Double (+3 more)

### Community 242 - "HarnessCore: Metadata / MetadataProvider"
Cohesion: 0.33
Nodes (5): AgentBridge, AgentTarget, Bool, String, SurfaceID

### Community 244 - "Onboarding: Design / GlassEffectView"
Cohesion: 0.15
Nodes (9): FileNode, Bool, String, FileTreeNode, FileTreeSwiftUIView, Bool, NSMenuItem, SessionID (+1 more)

### Community 245 - "Onboarding: UI / SetupStepView"
Cohesion: 0.18
Nodes (10): concurrency, cancel-in-progress, group, env, XCODE_VERSION, jobs, Build, sign, notarize, and publish, name (+2 more)

### Community 246 - "Docs: MODES"
Cohesion: 0.29
Nodes (7): 1. Plain Terminal, 2. Persistent Terminal, 3. Full Terminal, 4. Agent Workspace, Experience modes, Opting into the prefix + status line without switching modes, Persistence (ephemeral vs. persistent)

### Community 247 - "Harness App: UI / MainSplitViewController"
Cohesion: 0.20
Nodes (6): FormatContextDaemonTests, PaneID, SessionSnapshot, String, SurfaceID, URL

### Community 248 - "Tests: HarnessCoreTests / SnapshotQueryFormatterTests"
Cohesion: 0.23
Nodes (7): DaemonMetrics, Snapshot, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 249 - "Tests: HarnessTerminalEngineTests / ReflowPreviewTests"
Cohesion: 0.31
Nodes (3): ReflowPreviewTests, String, TerminalEmulator

### Community 250 - "Tests: HarnessTerminalKitTests / HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.38
Nodes (3): HarnessTerminalSurfaceWorkerTests, Bool, HarnessTerminalSurfaceView

### Community 251 - "Tests: HarnessCoreTests / TerminalConfigImporterTests"
Cohesion: 0.22
Nodes (5): SessionCoordinator, Bool, String, SurfaceID, TimeInterval

### Community 252 - "Tests: HarnessTerminalEngineTests / ReflowFastPathTests"
Cohesion: 0.07
Nodes (12): CoreGraphics, CoreText, HarnessCopyMode, HarnessTerminalEngine, HarnessTerminalRenderer, HarnessTheme, ImageIO, Metal (+4 more)

### Community 254 - "HarnessCore: Paths / ShellCompletionInstaller"
Cohesion: 0.06
Nodes (32): BoardCardView, BoardViewController, FlippedView, Bool, NSCoder, Set, TabID, Void (+24 more)

### Community 255 - "Scripts: release-hotfix.sh"
Cohesion: 0.42
Nodes (7): plist_set(), require_clean_tracked_worktree(), run(), release-hotfix.sh script, update_readme_download(), usage(), write_release_notes()

### Community 256 - "Harness App: Services / SessionCoordinator"
Cohesion: 0.31
Nodes (4): CwdMetadataProvider, GitMetadataProvider, MetadataProvider, Tab

### Community 257 - "Harness App: Services / SurfaceProgressTracker"
Cohesion: 0.13
Nodes (14): 1. @MainActor + Task + Process.waitUntilExit = FREEZE (RL-052), 2. @Observable + mutation in body = infinite re-render loop (RL-053), 3. Re-entrancy guard on rebuildRows, 4. Worktree display rules, Architecture, chromeEpoch — force SwiftUI re-render from static state, Critical Lessons (bugs fixed), File tree: root at git root, expand on CWD change (+6 more)

### Community 258 - "Harness App: UI / HarnessChrome"
Cohesion: 0.14
Nodes (8): Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint, NSRect, WindowTitleStripView

### Community 259 - "Tests: HarnessThemeTests / ThemeFileServiceTests"
Cohesion: 0.16
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 260 - "HarnessCore: ReleaseNotes / TerminalBanner"
Cohesion: 0.11
Nodes (13): DisplayWidth, String, Unicode, Run, Data, ReleaseNotes, String, TerminalBanner (+5 more)

### Community 261 - "Onboarding: UI / DemoSession"
Cohesion: 0.13
Nodes (14): Architecture, Browser Auto-Retry (P24 Phase 4), Browser Pane (P14), BUG: Tab close button never fired (CASE-055 extended), BUG: Tab close button unresponsive (gesture conflict), CASE: applyLocalSnapshot re-injected closed browser panes (v2.7.1), CASE: collapsed errorBanner intercepted toolbar clicks (v2.7.1), Click-to-open localhost/LAN dev-server links (+6 more)

### Community 262 - "Agent Instructions: AGENTS"
Cohesion: 0.19
Nodes (11): InstallError, daemonNotFound, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, Bool, Int32 (+3 more)

### Community 263 - "Harness App: UI / FileViewerViewController"
Cohesion: 0.12
Nodes (11): HarnessSidebarPanelViewController, CGFloat, NSMenuItem, NSView, SessionGroup, String, HarnessSidebarPanelViewController, NSMenu (+3 more)

### Community 266 - "Tests: HarnessCopyModeTests / WordColumnRangeTests"
Cohesion: 0.24
Nodes (8): Scanner, SVGPathParser, Bool, CGPath, CGPoint, Character, Set, CGMutablePath

### Community 267 - "Onboarding: UI / ShellStepView"
Cohesion: 0.06
Nodes (35): BinaryInstaller, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, found, notFound (+27 more)

### Community 269 - "Terminal Kit: HarnessTerminalKit / FrameSignposter"
Cohesion: 0.09
Nodes (22): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, failed, DefaultTerminalStatus, Bool, String, URL (+14 more)

### Community 270 - "Tests: HarnessCoreTests / CompletionGeneratorTests"
Cohesion: 0.07
Nodes (26): GridCompositor, PaneBorderStatus, Configuration, Bool, Command, CommandTarget, Data, DispatchSourceSignal (+18 more)

### Community 271 - "Tests: HarnessCoreTests / DefaultTerminalLaunchRequestTests"
Cohesion: 0.17
Nodes (11): Motion, CAMediaTimingFunction, HarnessOnboarding, Bool, ImmersiveOnboardingWindowController, ImmersivePanel, ImmersiveRootView, Any (+3 more)

### Community 272 - "Tests: HarnessCoreTests / SGRMouseTests"
Cohesion: 0.13
Nodes (9): SGRMouse, SGRMouseEvent, Bool, PaneRect, S, UInt8, SGRMouseTests, String (+1 more)

### Community 273 - "Tests: HarnessCoreTests / ShellCompletionInstallerTests"
Cohesion: 0.08
Nodes (21): register(), KeybindingsService, Bool, Command, String, Binding, CodingKeys, bindings (+13 more)

### Community 274 - "Theme: HarnessTheme / ThemeFileService"
Cohesion: 0.40
Nodes (5): [2.5.0] - 2026-06-12, Added, Changed, Documentation, Fixed

### Community 275 - "AIDLC: harness / ide-file-tree / PROGRESS.md / PROGRESS"
Cohesion: 0.13
Nodes (15): Context, Non-goals, P8: macOS 27 Golden Gate Adoption, Phase 0 — Swift 6.3+ Concurrency Safety (P0, LESSONS FROM macOS 26.5 CRASH SAGA), Phase 1 — Compatibility (P0), Phase 2 — Quick Wins (P1), Phase 3 — NSTextSelectionManager (P1), Phase 4 — Gesture Recognizer Migration (P2) (+7 more)

### Community 276 - "HarnessCore: Platform / PlatformSys"
Cohesion: 0.10
Nodes (13): Bool, NSCoder, NSEvent, NSRange, NSRect, NSString, NSTextView, Void (+5 more)

### Community 277 - "Terminal Kit: HarnessTerminalKit / HarnessTerminalSurfaceView"
Cohesion: 0.20
Nodes (11): ControlModeClient, ControlModeError, daemon, noMatch, noSnapshot, unresolved, Command, Data (+3 more)

### Community 278 - "Harness App: UI / ContentAreaViewController"
Cohesion: 0.26
Nodes (8): BlockTintOverlay, Bool, CGFloat, HarnessTerminalSurfaceView, NSCoder, NSEvent, NSPoint, NSRect

### Community 279 - "HarnessCore: Models / PaneNode"
Cohesion: 0.31
Nodes (6): DisplayPanesOverlay, Any, NSEvent, NSView, SurfaceID, Void

### Community 280 - "Terminal Engine: Images / DecodedImage"
Cohesion: 0.20
Nodes (6): CGFloat, NSColor, NSPoint, NSRect, NSWindow, WindowBorderOverlayView

### Community 281 - "Terminal Kit: HarnessTerminalKit / TerminalScrollbarView"
Cohesion: 0.16
Nodes (9): Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSPoint, NSRect, TimeInterval (+1 more)

### Community 282 - "Tests: HarnessTerminalKitTests / ScrollReuseTests"
Cohesion: 0.44
Nodes (3): SettingsAdvancedView, Bool, String

### Community 283 - "Harness CLI: HarnessCLI / WindowAttachClient"
Cohesion: 0.29
Nodes (8): FormatColor, none, palette, rgb, StyledSegment, Bool, String, UInt8

### Community 285 - "LSP: HarnessLSP / LSPTransport"
Cohesion: 0.08
Nodes (24): After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md., After all done — update memory, Agent Prompt — P14 Browser Pane (PBI-001 through 005), Before writing any code, read:, code:swift (public struct BrowserLeaf: Codable, Sendable, Equatable {), code:swift (case let .browser(bl):), code:swift (// action: SplitPaneCoordinator openBrowserPane(url: URL(str), code:block4 (harnessBrowserOpen(url, direction?) → {paneId}) (+16 more)

### Community 288 - "HarnessCore: Agents / AgentHookStrategy"
Cohesion: 0.20
Nodes (9): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, ownJSONFile, ownTextFile, regionEdit, Any, Bool (+1 more)

### Community 289 - "HarnessCore: CLI / CompletionGenerator"
Cohesion: 0.19
Nodes (5): StatusLineWidthTests, StatusLineWidth, String, StyledSegment, StyledSegment

### Community 290 - "Tests: HarnessCoreTests / Phase67Tests"
Cohesion: 0.27
Nodes (9): Command Prompt, Find In Files, Git Panel, Open Command Palette, Switch To Session 1, Switch To Session 2, Rapid Session Switch While Typing, Switch Between Isolated And Normal Session (+1 more)

### Community 291 - "Tests: HarnessDaemonTests / BellScanTests"
Cohesion: 0.06
Nodes (10): HarnessCommands, HarnessSettings, JSONDecoder, JSONEncoder, TerminalRecordingCodec, DaemonStatsTests, ExperienceModeTests, HarnessSettingsTests (+2 more)

### Community 292 - "Docs: RELEASE"
Cohesion: 0.33
Nodes (5): Local release path, One-time GitHub setup, Release runbook, Running a release from GitHub, What the workflow publishes

### Community 293 - "Harness App: UI / FileEditorView"
Cohesion: 0.14
Nodes (13): 1. Data / Geometry Separation (primary fix), 2. SnapshotCoalescer (cmux NotificationBurstCoalescer pattern), 3. Equality Guard on updateGeometry (Zed pattern), 4. Dirty Flag on setFrame (Otty/WezTerm pattern), 5. GPU Animation — CAShapeLayer Mask (Zed/Otty GPU path), 6. AgentScanner timer split, Files, Fixes Applied (layered) (+5 more)

### Community 294 - "Terminal Engine: Width / CharacterWidth"
Cohesion: 0.16
Nodes (14): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, PRInfo (+6 more)

### Community 295 - "Harness CLI: HarnessCLI / WindowAttachClient"
Cohesion: 0.09
Nodes (17): SnapshotCoalescer, MainActor, Void, AgentApprovalBar, ApprovalBarAction, hide, noop, show (+9 more)

### Community 296 - "Tests: HarnessCoreTests / EndpointTests"
Cohesion: 0.25
Nodes (5): NotificationBus, SnapshotChangedPayload, Bool, Data, String

### Community 297 - "Tests: HarnessCoreTests / HookNotificationParserTests"
Cohesion: 0.11
Nodes (18): HARNESS_MCP_ALLOW_CONTROL, args, command, args, command, env, hooks, PreToolUse (+10 more)

### Community 298 - "Tests: HarnessCoreTests / ShellIntegrationTests"
Cohesion: 0.16
Nodes (13): BoxDrawing, Kind, arms, dashH, dashV, halfDown, halfLeft, halfRight (+5 more)

### Community 299 - "Release Notes: CHANGELOG"
Cohesion: 0.14
Nodes (17): PaneBorderStatus, bottom, off, top, PaneLeaf, PaneNode, branch, leaf (+9 more)

### Community 300 - "Tests: HarnessTerminalKitTests / HarnessTerminalSurfaceDragDropTests"
Cohesion: 0.26
Nodes (11): atomicWrite(), backupCorruptFile(), fnv1aHex(), HarnessPathsError, socketPathTooLong, Bool, Data, String (+3 more)

### Community 301 - "HarnessCore: Agents / HookNotificationParser"
Cohesion: 0.20
Nodes (8): HookNotificationParser, Parsed, Any, Data, String, HookNotificationParserTests, Data, String

### Community 302 - "AIDLC: harness / acp / outputs / brainstorming-summary"
Cohesion: 0.26
Nodes (4): RGBColor, String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 305 - "Harness App: Services / CLIInstaller"
Cohesion: 0.08
Nodes (35): NSCursor, applyPointerShape(), applyPreferredFrameRateRange(), buildRenderer(), captureVisibleLines(), configureAppearance(), configureEmulatorCallbacks(), configureLayer() (+27 more)

### Community 306 - "Harness App: UI / HarnessSidebarPanelViewController"
Cohesion: 0.18
Nodes (4): String, RegressionBugFixTests, SessionSnapshot, Tab

### Community 308 - "Release Notes: CHANGELOG"
Cohesion: 0.36
Nodes (5): Logger, OSSignposter, FrameSignposter, Bool, UInt64

### Community 309 - "HarnessCore: Agents / AgentDetector"
Cohesion: 0.15
Nodes (12): Architecture, Browser DevTools API (P28), Config, Key Bug Fixed: Round-Trip Timeout (RL-048), Key Files, Phase 1 — Core (all via evaluateJS or WKWebView native), Phase 2 — Network, Phase 3 — Storage (+4 more)

### Community 310 - "Harness App: Services / SessionCoordinator"
Cohesion: 0.40
Nodes (5): FluidityBenchmarks, HarnessTerminalSurfaceView, NSWindow, String, UInt64

### Community 311 - "HarnessCore: IPC / IPCMessage"
Cohesion: 0.15
Nodes (12): Bug: Tab-Switch Black Screen, Files changed, Final fast-path guard (PaneLifecycleManager.swift), FM-1: detachHostsOnly() before caching (always broken), FM-2: force=true rebuild caches the stripped container, FM-3: Host theft by another tab's build, FM-4: Cache overwrite leaks orphan containers, Instrumentation method (+4 more)

### Community 312 - "Harness App: UI / Phase67UI"
Cohesion: 0.30
Nodes (4): AgentSnapshot, Date, Int32, AgentSessionSummaryTests

### Community 313 - "Terminal Renderer: HarnessTerminalRenderer / RenderColorConversion"
Cohesion: 0.17
Nodes (11): ACP vs MCP vs Terminal Chat, AgentProcessManager, Architecture, CLI Print-Mode Args, Context Injection, Key Files, Key Shortcuts (I-family), Non-Obvious Constraints (+3 more)

### Community 317 - "Agent Memory: Agent Memory / memory"
Cohesion: 0.13
Nodes (15): 2026-06-27 — Block output tint + AI explain (Phase 12b), Active Context, Active Decisions, Architecture Notes, Completed Sprints, Conventions, Current Sprint — ACP Client & Git Polish (post-v2.0.0), Current Sprint — IDE-like Sidebar (PBI-001) (+7 more)

### Community 319 - "Harness App: UI / Notch / NotchShape"
Cohesion: 0.21
Nodes (10): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+2 more)

### Community 320 - "HarnessCore: Format / AgentListFormatter"
Cohesion: 0.17
Nodes (11): 1. `SessionLifecycleService.swift` (tab bar clicks, sidebar clicks), 2. `MainExecutor.swift` (keyboard shortcuts — the actual user path), Competitive research (from Agy), Data model (correct, no changes needed), Files to read before resuming, Fix applied (compiles, not fully tested), Focus Persistence — Per-Session-Tab Pane Focus (RL-043), Restoration flow (after fix) (+3 more)

### Community 321 - "Harness App: UI / HarnessControls"
Cohesion: 0.50
Nodes (4): [1.8.0] - 2026-06-07, Added, Documentation, Fixed

### Community 323 - "Release Notes: CHANGELOG"
Cohesion: 0.28
Nodes (3): SettingsWindowController, NSWindow, NSAppearance

### Community 324 - "HarnessCore: CLI / TerminalRecording"
Cohesion: 0.26
Nodes (8): Never, Set, String, Task, URL, Void, WorkspaceSymbolIndex, NSRegularExpression

### Community 325 - "Harness CLI: HarnessCLI"
Cohesion: 0.21
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 326 - "Tests: HarnessDaemonTests / ShellLaunchProfileTests"
Cohesion: 0.24
Nodes (6): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 327 - "Tests: HarnessTerminalEngineTests / CharacterWidthTests"
Cohesion: 0.10
Nodes (8): HarnessThemeCatalog, String, HarnessThemeDefinition, Bool, RGBColor, String, ANSIPaletteTests, HarnessThemeCatalogTests

### Community 328 - "Tests: HarnessTerminalRendererTests / ThaiClusterRenderTests"
Cohesion: 0.23
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 329 - "Onboarding: Design / ImmersivePalette"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 330 - "Harness CLI: HarnessCLI / ReplayClient"
Cohesion: 0.37
Nodes (6): SurfaceProgressTracker, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void

### Community 333 - "Agent Memory: plans / completed-archive"
Cohesion: 0.50
Nodes (4): [2.0.0] - 2026-06-07, Added, Documentation, Fixed

### Community 334 - "Harness App: UI / HarnessSidebarPanelViewController"
Cohesion: 0.22
Nodes (8): MCP Control Allowed With Env Var, MCP Control Denied Without Env Var, MCP HarnessBoard Returns Columns, MCP HarnessList Returns Sessions, MCP ReadPaneOutput Returns Content, Run MCP Request, Run MCP Request Allowed, Run MCP Request Denied

### Community 336 - "Scripts: run.sh"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 337 - "Harness App: UI / SyntaxTextView"
Cohesion: 0.22
Nodes (8): AnyObject, CommandExecutionError, daemonError, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor, String

### Community 338 - "Harness App: UI / HarnessControls"
Cohesion: 0.22
Nodes (8): Browser Pane Open Close Rapid, File Preview Open Close, Git Fetch Shows Toast, Launch Harness Staging, Memory Stability After 30 Seconds, Quit Harness Staging, Sidebar Toggle Immediately After Launch, Tab Close While Mouse Moving

### Community 339 - "Harness App: UI / HarnessControls"
Cohesion: 0.04
Nodes (11): AppKit, HarnessPathDisplay, Carbon, Combine, HarnessLSP, HarnessTerminalKit, Observation, QuickLookUI (+3 more)

### Community 343 - "Harness App: AppIcon.appiconset / Contents"
Cohesion: 0.50
Nodes (4): [2.2.3] - 2026-06-09, Added, Documentation, Fixed

### Community 344 - "Release Notes: CHANGELOG"
Cohesion: 0.11
Nodes (16): FileViewerViewController, Bool, NSEvent, Set, String, URL, Void, LSPFileSession (+8 more)

### Community 346 - "Docs: THIRD-PARTY-NOTICES"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 347 - "Tests: HarnessAppTests / ExternalOpenKindTests"
Cohesion: 0.50
Nodes (4): [3.2.0] - 2026-06-16, Changed, Documentation, Fixed

### Community 348 - "Tests: HarnessDaemonTests / DaemonLifecycleTests"
Cohesion: 0.10
Nodes (19): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+11 more)

### Community 350 - "Terminal Renderer: HarnessTerminalRenderer / ImageTextureCache"
Cohesion: 0.18
Nodes (10): 1. SurfaceShellTracker (proc tree walk), 2. DaemonSyncService.startMetadataRefresh (5-s loop), 3. snapshotChanged Fanout, 4. PerfCounters — Instrumentation, 5. Performance Lessons (v3.2.0), Adaptive polling, Background Polling & Snapshot Fanout — P22, Known Non-P22 Callers of syncFromDaemon (+2 more)

### Community 351 - "Harness App: UI / HarnessDesign"
Cohesion: 0.18
Nodes (10): AI / Agent Connectivity, Architecture Decisions — harness-terminal, Browser Pane, Config / Settings, File Preview / Split Panes, IPC / Daemon, Keybindings, Sessions / Tabs (+2 more)

### Community 352 - "Terminal Kit: HarnessTerminalKit / TerminalHostView"
Cohesion: 0.18
Nodes (10): Cause 1 — `existingHosts` strong dict in TerminalPaneRegistry (DOMINANT), Cause 2 — Insert-only AI controller dicts in SessionCoordinator, Cause 3 — Uncapped browser network capture array, Memory Leak Audit — 34 GB Long-Session Case (2026-06-26), Pattern to watch: "insert-only per-surface dict", Release, Root causes found and fixed, Symptom (+2 more)

### Community 353 - "Harness App: UI / HarnessDesign"
Cohesion: 0.18
Nodes (10): Burst Coalescing (cmux NotificationBurstCoalescer), CA Mask Pattern (Harness Notch), Combine → CA Bridge, Equality Guard (Zed layout phase), GPU Animation Pattern — Layout Once, GPU Paints, Layer Coordinate System, Principle, References (+2 more)

### Community 354 - "Harness App: UI / AgentInboxPanelView"
Cohesion: 0.22
Nodes (8): 1. Performance Optimization: Scrollback Reflow ($O(\text{history})$ Complexity), 2. convenient Features: Local completion & completion Gutter, 3. IDE Convenient: Keyboard-driven Layout Presets, 4. AI integration: Secure Local ACP Sidebar, Additional features shipped alongside:, Context, Implementation Status (2026-06-11), P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)

### Community 355 - "Onboarding: UI / ComposedTerminalView"
Cohesion: 0.24
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 356 - "Tests: HarnessDaemonTests / DaemonContentionTests"
Cohesion: 0.22
Nodes (5): ShapedGlyphSignature, Bool, CGFloat, CGGlyph, String

### Community 357 - "Theme: HarnessTheme / HarnessThemeCatalog"
Cohesion: 0.44
Nodes (3): HarnessCLI, SessionID, String

### Community 358 - "HarnessCore: Keybindings / ShortcutRecorderSerializer"
Cohesion: 0.50
Nodes (4): [3.5.1] - 2026-06-20, Added, Documentation, Fixed

### Community 359 - "Scripts: generate-release-notes"
Cohesion: 0.36
Nodes (5): OcclusionTests, HarnessTerminalSurfaceView, NSWindow, String, TimeInterval

### Community 360 - "LSP: HarnessLSP / LSPServerRegistry"
Cohesion: 0.43
Nodes (7): Close Tab, New Tab, Cmd Shift W Force Closes Tab, Cmd T Creates New Session, Cmd W Closes Tab When Single Pane, Window Survives Full Shortcut Sequence, Zombie Crash Close Tab While Typing

### Community 362 - "Harness App: UI / HarnessDesign"
Cohesion: 0.24
Nodes (7): RGBColor, Bool, Decoder, Double, Encoder, String, UInt8

### Community 363 - "AIDLC: harness / acp / PROGRESS.md / PROGRESS"
Cohesion: 0.29
Nodes (7): Toggle Sidebar, Sidebar Toggle Works, Board CLI Shows Columns, Board CLI Shows Running After Long Command, Board Columns Visible After Click, Board Tab Accessible In Sidebar, Split Pane And Resize

### Community 364 - "Tests: HarnessDaemonTests / PtyDrainCeilingBenchmark"
Cohesion: 0.40
Nodes (5): [2.2.4] - 2026-06-11, Added, Changed, Documentation, Fixed

### Community 365 - "Harness App: App / Contents"
Cohesion: 0.20
Nodes (9): 1. Sidebar toggle (⌘\), 2. File preview open/close, 3. Tab switch (⌘1-9, ✕ close), 4. presentsWithTransaction order fix (ALL remaining flash cases) — v3.9.x+, Fixes Applied (v3.9.1+), Related Lessons, Root Cause Pattern, Rules (+1 more)

### Community 366 - "Root Docs: README"
Cohesion: 0.20
Nodes (9): 1. Board Sidebar Tab (GUI), 2. Harness CLI Command, 3. Scripting API, 4. Read-Only MCP Tool, Agent/Session Board (P16), Centralized Classification, Consumers, Data Model (PBI-BOARD-001) (+1 more)

### Community 367 - "Onboarding: Design / Effects"
Cohesion: 0.24
Nodes (8): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID

### Community 368 - "Claude Instructions: CLAUDE"
Cohesion: 0.14
Nodes (16): statusColor(), Array, Bool, Date, Decoder, PaneID, PaneNode, String (+8 more)

### Community 369 - "HarnessCore: Keybindings / KeybindingsStore"
Cohesion: 0.20
Nodes (9): Architecture, Branch chip — CASE-020, Features, FSEvents Pattern (Swift Actor), Git Panel, History → File Editor, Real-time Refresh, v1 — CASE-009 (resolved, superseded) (+1 more)

### Community 370 - "HarnessCore: Paths / BinaryRefresher"
Cohesion: 0.16
Nodes (3): InputEncoderTests, String, UInt8

### Community 371 - "Harness App: UI / LSPFileSession"
Cohesion: 0.17
Nodes (11): Architecture, code:block1 (PaneNode (existing binary tree)), Current State, Estimate, Goal, P13 — Embedded Browser Pane (cmux parity), PBI-BROWSER-001: BrowserPaneView + PaneNode integration, PBI-BROWSER-002: Persistence (+3 more)

### Community 372 - "HarnessCore: Settings / JSONMerge"
Cohesion: 0.27
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 373 - "Tests: HarnessCoreTests / KeybindingsStoreTests"
Cohesion: 0.21
Nodes (12): code:block1 (Add a visual session state indicator to sidebar session card), code:block2 (Add keyboard-driven layout presets to the Harness terminal a), code:block3 (Add workspace-scoped local completion (autocomplete) to the ), code:block4, Context, P10 Implementation Prompts — For Agent Execution, Prompt, Task #1: CMUX Session State Indicator in Sidebar (+4 more)

### Community 374 - "Terminal Engine: Images / SixelDecoder"
Cohesion: 0.15
Nodes (13): DiagnosticCheck, DiagnosticStatus, fail, pass, warn, DoctorReport, DoctorRunner, Bool (+5 more)

### Community 375 - "Harness App: Services / SparkleUpdater"
Cohesion: 0.36
Nodes (4): CLIInstaller, Bool, String, URL

### Community 376 - "Onboarding: Design / WindowBlur"
Cohesion: 0.47
Nodes (3): ScrollReuseTests, HarnessTerminalSurfaceView, NSWindow

### Community 377 - "Community 377"
Cohesion: 0.10
Nodes (16): Identifiable, CompleteStepView, Void, DiscoverStepView, Point, String, OnboardingStep, complete (+8 more)

### Community 378 - "HarnessCore: Format / JSONOutputFormatter"
Cohesion: 0.31
Nodes (6): Bool, Counter, Scheduled, SurfaceProgressTrackerTests, DispatchWorkItem, TimeInterval

### Community 380 - "HarnessCore: Keybindings / ControlKeyNormalizer"
Cohesion: 0.26
Nodes (4): PromptQueue, String, SurfaceID, Void

### Community 382 - "Community 382"
Cohesion: 0.29
Nodes (3): Bool, String, ThaiClusterRenderTests

### Community 383 - "Harness App: UI / AgentIconArt"
Cohesion: 0.40
Nodes (9): attribute_lines(), main(), redraw_frames(), repeated_chunk(), run_case(), sgr_lines(), truecolor_gradient(), unicode_lines() (+1 more)

### Community 384 - "Harness App: UI / WindowBlur"
Cohesion: 0.22
Nodes (8): Detection Method, Fix, NSTextField Leak in BoardViewController (P20 Performance), Prevention Rules, Related Files, Root Cause, Symptom, Why CPU Goes Up

### Community 385 - "Agent Memory: Agent Memory / playbook"
Cohesion: 0.12
Nodes (12): Agent Memory Index — harness-terminal, Navigation, Edges, Files, Knowledge Index, Knowledge Index — Harness Terminal, Search Instructions, Source Map (+4 more)

### Community 387 - "Agent Memory: Agent Memory / user-profile"
Cohesion: 0.29
Nodes (6): Architecture Preferences, Domain Expertise, Identity, Project Scope, User Profile, Workflow Preferences

### Community 388 - "HarnessCore: HarnessCore / HarnessVersion"
Cohesion: 0.08
Nodes (13): CHarnessSys, Darwin, Foundation, Glibc, HarnessIPC, HarnessVersion, WriteOutcome, complete (+5 more)

### Community 389 - "Terminal Engine: Width / CharacterWidthTable"
Cohesion: 0.06
Nodes (3): HarnessCLITests, Set, String

### Community 390 - "Terminal Renderer: HarnessTerminalRenderer / MetalShaders"
Cohesion: 0.22
Nodes (8): Accessibility Requirements, Files, Permission, Running, Stack, Test Strategy, UI Automation — Robot Framework (P18), Why Not Appium

### Community 391 - "Theme: HarnessTheme / BundledThemesData"
Cohesion: 0.22
Nodes (8): AppKit + Metal Patterns, CADisplayLink Lifetime on macOS (CASE-031), Metal Surface Lifecycle (CASE-003), Mouse Selection Must Use Virtual-Line Coordinates (CASE-029), NSFont Italic (CASE-010), NSView Layer Opacity — Preview Parity Pattern (CASE-011), Overlay Above Metal (CASE-004), Window Background Tint for Legibility (CASE-027)

### Community 402 - "Package.Swift: Package"
Cohesion: 0.07
Nodes (36): Color, ColorHexRow, PaletteCell, Bool, String, WritableKeyPath, NotchRowButtonStyle, Configuration (+28 more)

### Community 404 - "HarnessCore: Models / Identifiers"
Cohesion: 0.22
Nodes (8): Architecture, Infinite Recursion (CASE-006), Pane Drag-and-Drop (P27), Ratio Persistence (CASE-002), Split CWD Resolution — Worktree Priority (2026-06-21), Split Panes (NSSplitView), Subview Reorder (CASE-007), Two-Axis Split Parity (P13)

### Community 405 - "C System Shim: CHarnessSys"
Cohesion: 0.24
Nodes (6): PaletteMode, errors, grep, normal, AttributedString, NSColor

### Community 408 - "Community 408"
Cohesion: 0.25
Nodes (7): Framing, IPC Architecture, Key Invariant, Overview, Process Separation, Security, Subscriptions

### Community 409 - "Tests: HarnessCLITests"
Cohesion: 0.25
Nodes (7): ⌘1-9 and ⌘[ / ⌘] = Session-level navigation (CASE-028), Data Model, Session/Tab/Pane Hierarchy & Top Bar (CASE-028), Sidebar Session Groups = One Header Per SessionGroup, Source Map, Tab Pill Visual Details, Top Bar = 1 Pill Per Session (not per-tab)

### Community 411 - "HarnessCore: Shell / ShellRCWiring"
Cohesion: 0.10
Nodes (19): Agent Prompt — Harness Terminal UI Fixes, code:block1 (▶ harness-terminal), code:block2 (▼ harness-terminal  ● Running), code:swift (urlTextField.setContentHuggingPriority(.defaultLow, for: .ho), code:swift (let bv = BrowserPaneView(url: bl.url, paneID: bl.id)), code:bash (cd /Users/supavit.cho/Git/Personal/harness-terminal), code:bash (git add -A), Commit (+11 more)

### Community 422 - "Harness App: UI / HarnessDesign"
Cohesion: 0.15
Nodes (11): keys, HintModeOverlay, Any, HarnessTerminalSurfaceView, NSEvent, NSView, String, ITerm2InlineImage (+3 more)

### Community 423 - "HarnessCore: ACP / ACPClient"
Cohesion: 0.32
Nodes (4): CopyModeLine, Character, ClosedRange, String

### Community 424 - "Harness App: UI / ContentAreaViewController"
Cohesion: 0.04
Nodes (6): HarnessApp, HarnessCLI, HarnessCore, HarnessDaemonCore, HarnessMCP, XCTest

### Community 425 - "Community 425"
Cohesion: 0.29
Nodes (10): AgentIconArt, AgentVectorIcon, Bool, CGSize, String, AgentIconRenderer, CGFloat, NSColor (+2 more)

### Community 426 - "Daemon: HarnessDaemon / DaemonLifecycle"
Cohesion: 0.25
Nodes (7): Bug — Cmd+\ sidebar toggle gone after collapse, Confirmed facts, Fix, Related, Suspect A — Dead token guard (confirmed code bug), Suspect B — Zero-delta early exit trap, Symptom

### Community 428 - "Terminal Renderer: HarnessTerminalRenderer / TerminalMetalRenderer"
Cohesion: 0.18
Nodes (10): 1. HarnessTerminalSurfaceView (~2,320 LOC), 2. HarnessCLI.swift (~1,841 LOC), 3. WindowAttachClient (~1,566 LOC), 4. SurfaceRegistry (~1,848 LOC), 5. GridCompositor Duplication, Context, Execution Order, Execution Status (2026-06-11) (+2 more)

### Community 429 - "Harness App: UI / SearchPanelView"
Cohesion: 0.25
Nodes (7): Case: cwd "bleed" — session worktree jumps to wrong dir during builds, Companion bug: blank panel on first open (CASE-042), Fix, Lesson, Repro (deterministic, headless — no GUI needed), Root cause, Symptom

### Community 430 - "HarnessCore: Session / SessionEditor"
Cohesion: 0.25
Nodes (7): Competitive Position (as of v3.12.0, 2026-07-02), Feature Matrix (2026-07-02), Harness Gaps, Harness Wins, Known Limitations (honest assessment), Positioning Statement, Unique Selling Points (no competitor has all)

### Community 431 - "Agent Memory: plans / p6-editor-opacity-parity"
Cohesion: 0.22
Nodes (8): Actual Fix (2026-06-09), code:swift (panel.layer?.backgroundColor = c.terminalBackground), code:swift (private func refreshEditorPanelFill() {), Fix Approach, P6: File Editor Opacity Parity with Terminal, Problem, Root Cause (hypothesis), Status

### Community 432 - "Harness App: UI / HarnessDesign"
Cohesion: 0.20
Nodes (4): CopyModeReducerTests, FakeGrid, String, TerminalGridCell

### Community 433 - "Community 433"
Cohesion: 0.24
Nodes (7): LaunchdServiceInstaller, ServiceInstaller, ServiceInstallers, ServiceInstallReport, Bool, String, URL

### Community 434 - "Tests: HarnessThemeTests / ThemeCatalogEmbedTests"
Cohesion: 0.25
Nodes (7): Apple Platform Context — Transparency & Legibility, Architecture Decisions, iOS/macOS 26 — Liquid Glass introduction, iOS/macOS 27 — Liquid Glass refinements (WWDC 2026), Known Issues (Current), Project History, Sprint Timeline

### Community 435 - "Community 435"
Cohesion: 0.16
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 436 - "Tests: HarnessCoreTests / GroupedSessionTests"
Cohesion: 0.30
Nodes (6): Channel, Bool, Int32, String, WaitForRegistry, WaitForRegistryTests

### Community 437 - "Harness App: UI / HarnessSidebarPanelViewController"
Cohesion: 0.25
Nodes (8): F1: Mobile Package Targets — P0, F2: Network Endpoint for IPC — P0, F3: Pairing and Trust — P0, F4: UIKit Terminal Surface — P0, F5: iPad Workspace UX — P1, F6: Remote Session Lifecycle — P1, F7: Files and Sharing — P2, Feature Specs

### Community 438 - "Onboarding: UI / OnboardingWizardView"
Cohesion: 0.06
Nodes (24): IndexingIterator, LayoutTemplate, SessionEditor, Bool, CGFloat, Command, Date, Double (+16 more)

### Community 439 - "Agent Memory: knowledge / acp-client"
Cohesion: 0.29
Nodes (7): ACP Client, Architecture, code:block1 (AgentChatPanelView (AppKit UI)), Key Files, Protocol, Shelved Status (June 2025), Tool Call Handling

### Community 440 - "Harness App: UI / CommandPaletteController"
Cohesion: 0.25
Nodes (8): Implementation Phases, Phase 0 — Feasibility Spike (P0), Phase 1 — Shared Renderer Extraction (P0), Phase 2 — Mobile IPC Transport (P0), Phase 3 — UIKit Terminal MVP (P0), Phase 4 — iPad App Shell (P1), Phase 5 — Multiplexer Parity (P1), Phase 6 — Polish and Platform Integration (P2)

### Community 441 - "Community 441"
Cohesion: 0.10
Nodes (13): RemoteHostsService, RemoteHost, String, MutationResult, RemoteHost, RemoteHostStore, Bool, String (+5 more)

### Community 443 - "Community 443"
Cohesion: 0.38
Nodes (6): Cleanup And Quit, Create Config File, No Config File Starts Normally, Script Hot Reload On Save, Script Loads On Startup, Script Syntax Error Does Not Crash

### Community 444 - "Community 444"
Cohesion: 0.43
Nodes (3): BlockContextMenuTests, HarnessTerminalSurfaceView, String

### Community 445 - "Community 445"
Cohesion: 0.20
Nodes (10): Section, actions, errors, files, grep, navigation, projects, recent (+2 more)

### Community 448 - "Agent Memory: knowledge / split-panes"
Cohesion: 0.40
Nodes (5): code:swift (private var isApplyingPositions = false), Infinite Recursion Guard (CASE-006), Key Invariants, NSSplitView Patterns, Safe Subview Reorder (CASE-007)

### Community 449 - "Community 449"
Cohesion: 0.20
Nodes (9): InterruptFlag, ReplayClient, ReplayPlayer, Bool, Data, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 450 - "Release Notes: CHANGELOG"
Cohesion: 0.19
Nodes (11): RecordClient, RecordingWriter, RecordSession, Summary, Bool, Data, DispatchSourceSignal, FileHandle (+3 more)

### Community 451 - "Community 451"
Cohesion: 0.24
Nodes (7): Container, NotchPulseHost, Content, Context, NSCoder, NSHostingView, NSRect

### Community 452 - "Docs: TMUX_PARITY"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Harness-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 453 - "Community 453"
Cohesion: 0.28
Nodes (6): HarnessTerminalSurfaceView, Bool, NSEvent, ViInputMode, insert, normal

### Community 455 - "Community 455"
Cohesion: 0.16
Nodes (10): center, ComposerPanel, Bool, NSEvent, NSTextView, NSWindow, Selector, String (+2 more)

### Community 457 - "Community 457"
Cohesion: 0.26
Nodes (7): StartupMetrics, Bool, Double, UInt64, URL, StartupMetricsTests, UInt64

### Community 459 - "Agent Memory: knowledge / index"
Cohesion: 0.25
Nodes (8): MouseButton, left, middle, right, wheelDown, wheelLeft, wheelRight, wheelUp

### Community 461 - "Community 461"
Cohesion: 0.16
Nodes (7): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Float, NSWindow

### Community 462 - "Community 462"
Cohesion: 0.13
Nodes (13): Architecture, Build & test, Coding constraints, Communication: GUI ↔ Daemon ↔ CLI, Generated files (do not hand-edit), Graphify + agent-memory, IPC safety, Package map (+5 more)

### Community 465 - "Tests: HarnessCoreTests / OptionValueTests"
Cohesion: 0.08
Nodes (22): Kind, input, metadata, output, resize, RecordingEvent, input, metadata (+14 more)

### Community 466 - "Community 466"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, String, TerminalEmulator

### Community 467 - "Community 467"
Cohesion: 0.12
Nodes (15): ─────────────────────────────────────────────────────, Agent Prompt — P14 PBI-BROWSER-001 + 002, BrowserPaneView shell + PaneNode integration, code:swift (public struct BrowserLeaf: Codable, Sendable, Equatable {), code:swift (case let .browser(browserLeaf):), code:block3 (feat(p14): PBI-BROWSER-001/002 — BrowserPaneView + PaneNode ), Constraints, ContentAreaViewController.swift — PaneContainerView.build() (+7 more)

### Community 473 - "Tests: GridCompositorParityTests / LiveCompositorFixture"
Cohesion: 0.11
Nodes (10): HarnessOnboarding, GridCompositorParityTests, LiveCompositorFixture, Bool, String, TerminalGridSnapshot, PortCompositorFixture, Bool (+2 more)

### Community 476 - "Community 476"
Cohesion: 0.29
Nodes (6): Bug 1 - Browser Pane Deferred Unregister, Bug 1 - Browser Pane Reuse On Rebuild, Bug 2 - New Session Syncs Before Reading Active Tab, Bug 2 - Tab Bar New Tab Also Syncs, Bug 3 - Browser Pane Forces Redraw On Reattach, Build Compiles Successfully

### Community 478 - "Tests: HarnessCoreTests / TerminalIdentityTests"
Cohesion: 0.33
Nodes (6): Board and attention, Errors and LSP, File navigation, Search, Task runner, Workbench commands (IDE-like workflow)

### Community 479 - "Community 479"
Cohesion: 0.17
Nodes (4): ScrollbackTests, Character, String, TerminalGridSnapshot

### Community 480 - "Onboarding: HarnessOnboarding / OnboardingManager"
Cohesion: 0.29
Nodes (6): Command Prompt Architecture, Files, Gotchas, Key rule: every documented verb needs BOTH layers, Layers, Verb categories

### Community 490 - "Agent Memory: plans / p7-sidebar-ui-large-screen"
Cohesion: 0.40
Nodes (4): Fix Approach, P7: Sidebar UI Polish — Large Screen Layout, Problems, Status

### Community 492 - "Harness CLI: HarnessCLI"
Cohesion: 0.29
Nodes (6): Anti-Patterns Avoided, Architecture, Key Design Decisions, Pattern, Service Decomposition — SessionCoordinator (P17), When to Apply This Pattern

### Community 493 - "Tests: HarnessBenchmarks / PerformanceBenchmarks"
Cohesion: 0.29
Nodes (6): Browser Tab Close Button Unresponsive, Files, Fix Applied, If Fix Is Insufficient, Root Cause, Symptom

### Community 495 - "Community 495"
Cohesion: 0.29
Nodes (4): GroupedSessionTests, SessionGroup, Set, SurfaceID

### Community 496 - "Tests: GridCompositorParityTests / CompositorFixtureSpec"
Cohesion: 0.29
Nodes (6): Architecture / Keybindings, CASE — Git / FS / Terminal / Architecture, Claude Code / Tooling / Environment (the agent running *inside* Harness), Command Prompt / Parser, Git / File System, Terminal / Renderer / Daemon

### Community 498 - "Community 498"
Cohesion: 0.21
Nodes (6): Bool, Int32, String, URL, SystemdUserInstaller, ServiceInstallerTests

### Community 499 - "Release Notes: CHANGELOG"
Cohesion: 0.33
Nodes (5): #header, #javascript-disabled, #statistics-container, #status-bar, #test-details-container

### Community 502 - "Community 502"
Cohesion: 0.29
Nodes (6): ACP Client (Shelved), Architecture (Preserved), Re-enablement Criteria, Status: SHELVED (June 2026), What It Is, Why Shelved

### Community 503 - "Scripts: generate-width-table"
Cohesion: 0.29
Nodes (6): Build Scripts Self-Kill Protection, Detection, Fix (applied in `Scripts/run.sh`), Key Invariant, Problem, Related

### Community 506 - "Community 506"
Cohesion: 0.33
Nodes (5): #header, #javascript-disabled, #statistics-container, #status-bar, #test-details-container

### Community 507 - "Community 507"
Cohesion: 0.53
Nodes (3): TerminalGridCell, ThaiClusterCopyTests, ThaiGrid

### Community 509 - "Community 509"
Cohesion: 0.70
Nodes (4): main(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 510 - "Community 510"
Cohesion: 0.14
Nodes (7): ControlKeyNormalizer, Bool, String, ShortcutRecorderSerializer, String, ControlKeyNormalizerTests, ShortcutRecorderSerializerTests

### Community 511 - "Community 511"
Cohesion: 0.33
Nodes (3): ScrollbackPersistenceTests, String, URL

### Community 512 - "Harness App: UI / OnboardingController"
Cohesion: 0.09
Nodes (22): [1.0.0] - [1.0.4] - 2026-06-01, [1.0.0] - 2026-05-31, [2.2.0] - 2026-06-07, [2.5.2] - 2026-06-12, [3.11.4] - 2026-06-28, [3.11.7] - 2026-06-29, [3.1.3] - 2026-06-16, [3.2.1] - 2026-06-16 (+14 more)

### Community 513 - "Community 513"
Cohesion: 0.09
Nodes (29): Codable, SplitDirection, horizontal, vertical, Appearance, AppearanceKind, dark, light (+21 more)

### Community 514 - "Community 514"
Cohesion: 0.33
Nodes (5): Harness LSP Diagnostics Does Not Crash, Harness LSP Hover Returns Result, Harness LSP Start Returns JSON, Harness View Binary Shows Guard Message, Harness View Prints File Content

### Community 518 - "Harness CLI: HarnessCLI"
Cohesion: 0.14
Nodes (12): TimeInterval, HarnessDaemonTools, PaneOutputWaiter, PaneOutputWaitResult, Bool, CheckedContinuation, Never, PaneLeaf (+4 more)

### Community 521 - "Community 521"
Cohesion: 0.24
Nodes (7): PasteController, Bool, Data, NSPasteboard, String, TimeInterval, URL

### Community 522 - "Community 522"
Cohesion: 0.39
Nodes (4): ImageTextureCache, MTLDevice, MTLTexture, UInt8

### Community 527 - "Community 527"
Cohesion: 0.29
Nodes (7): Agent hooks for Harness, CLI notification, Example Claude Code hook, Jump to waiting agent, OSC sequences (from terminal output), Per-agent guides, Set up via your IDE (copy/paste prompt)

### Community 530 - "Release Notes: CHANGELOG"
Cohesion: 0.40
Nodes (6): HarnessChrome, HarnessChromePalette, Bool, CGFloat, NSColor, String

### Community 531 - "Release Notes: CHANGELOG"
Cohesion: 0.06
Nodes (23): DECSpecialGraphics, CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16, UInt8 (+15 more)

### Community 534 - "Release Notes: CHANGELOG"
Cohesion: 0.40
Nodes (3): HarnessCLI, String, String

### Community 535 - "Community 535"
Cohesion: 0.29
Nodes (7): AgentNotification, OSCNotificationParser, DaemonSurfaceID, Data, Date, String, SurfaceID

### Community 537 - "Release Notes: CHANGELOG"
Cohesion: 0.30
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 538 - "Community 538"
Cohesion: 0.07
Nodes (22): MainActor, Void, SessionDividerRowView, SessionGroupHeaderRowView, SessionWorktreeHeaderRowView, SessionWorktreeRowView, SidebarBadgeView, SidebarTitlebarHeaderView (+14 more)

### Community 544 - "Community 544"
Cohesion: 0.40
Nodes (3): 2026-06-25 — OSC 7735:  opens sidebar file viewer, Pruned from MEMORY.md — 2026-07-02, Task Ledger Archive (Tasks 1–50)

### Community 546 - "Community 546"
Cohesion: 0.36
Nodes (7): LegacySnapshot, LegacyWorkspace, Bool, Date, String, TabID, WorkspaceID

### Community 547 - "Community 547"
Cohesion: 0.13
Nodes (18): BranchSwitchHelper, ClosureTarget, keyDown(), MenuActionTarget, Phase67UI, PopupWindow, Command, NSEvent (+10 more)

### Community 548 - "Community 548"
Cohesion: 0.26
Nodes (6): KeyTokenParser, Bool, Data, String, KeyTokenParserTests, Phase6KeysTests

### Community 550 - "Community 550"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 551 - "Community 551"
Cohesion: 0.21
Nodes (4): DesktopNotifier, Bool, MainActor, String

### Community 552 - "Community 552"
Cohesion: 0.40
Nodes (5): [3.12.0] - 2026-06-30, Added, Changed, Documentation, Fixed

### Community 557 - "Community 557"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Harness Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 558 - "Community 558"
Cohesion: 0.40
Nodes (3): String, URL, ThemeCatalogEmbedTests

### Community 559 - "Community 559"
Cohesion: 0.33
Nodes (5): Codex Fix Prompt Template, FSEvents Recursive Watcher Pattern (Swift), Full Swift Actor Pattern, Single-file watch (DispatchSource is enough), When to use

### Community 566 - "Community 566"
Cohesion: 0.08
Nodes (26): clamp(), DotView, statusHelp(), Bool, CGFloat, Context, Date, NSCoder (+18 more)

### Community 570 - "Community 570"
Cohesion: 0.06
Nodes (30): CommandHistorySearchController, HistoryItemView, HistoryRowView, SearchPanel, Bool, CGFloat, NSAttributedString, NSCoder (+22 more)

### Community 576 - "Community 576"
Cohesion: 0.40
Nodes (5): [3.10.0] - 2026-06-27, Added, Changed, Documentation, Fixed

### Community 578 - "Community 578"
Cohesion: 0.40
Nodes (5): [3.11.0] - 2026-06-28, Added, Changed, Documentation, Fixed

### Community 579 - "Community 579"
Cohesion: 0.25
Nodes (7): AppKit / Views, Architecture / Daemon, Browser / WKWebView, Git / Process, RL Lessons — harness-terminal, Swift 6 / Concurrency, Testing / Environment

### Community 580 - "Community 580"
Cohesion: 0.15
Nodes (15): Architecture, Components, Estimate, Files, Goal, Grammars, Implementation Notes (MVP — plain-text viewer), LSP Discovery (+7 more)

### Community 581 - "Community 581"
Cohesion: 0.50
Nodes (4): [2.2.3] - 2026-06-09, Added, Documentation, Fixed

### Community 582 - "Community 582"
Cohesion: 0.27
Nodes (7): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, NSEvent

### Community 584 - "Community 584"
Cohesion: 0.36
Nodes (5): PaneLeaf, SessionGroup, Any, String, Tab

### Community 586 - "Community 586"
Cohesion: 0.40
Nodes (5): [3.8.0] - 2026-06-22, Added, Changed, Documentation, Fixed

### Community 587 - "Community 587"
Cohesion: 0.25
Nodes (6): LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled

### Community 589 - "Community 589"
Cohesion: 0.08
Nodes (22): CustomStringConvertible, DaemonClientActor, DaemonSessionError, daemonError, unexpectedResponse, DaemonSessionService, LatencyMonitor, Bool (+14 more)

### Community 591 - "Community 591"
Cohesion: 0.20
Nodes (9): GitStatusType, added, deleted, modified, renamed, unmodified, untracked, NodeRow (+1 more)

### Community 594 - "Community 594"
Cohesion: 0.20
Nodes (9): KeyRecorderRepresentable, Context, String, Void, KeyRecorderView, KeyRecorderViewTests, NSEvent, String (+1 more)

### Community 596 - "Community 596"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 597 - "Community 597"
Cohesion: 0.40
Nodes (5): WrapperOptionBehavior, keepScanning, matchValue, skipValue, stopScanning

### Community 598 - "Community 598"
Cohesion: 0.17
Nodes (20): applyChrome(), buildContext(), HarnessOptions, init(), nsColor(), paletteColor(), refresh(), resolvedTextColor() (+12 more)

### Community 599 - "Community 599"
Cohesion: 0.11
Nodes (15): AnimatablePair, HorizontalInsetRect, CGRect, Path, NotchMaskAnimator, Bool, CGFloat, CGRect (+7 more)

### Community 600 - "Community 600"
Cohesion: 0.12
Nodes (13): NSRangePointer, NSTextInputClient, HarnessTerminalSurfaceView, Any, Bool, NSAttributedString, NSEvent, NSPoint (+5 more)

### Community 603 - "Community 603"
Cohesion: 0.13
Nodes (15): AgentRow, AgentRow, MenuBarController, MenuRef, CGFloat, NSImage, NSMenu, NSMenuItem (+7 more)

### Community 608 - "MatchCategory"
Cohesion: 0.40
Nodes (5): DaemonError, alreadyRunning, bindFailed, listenFailed, socketFailed

### Community 613 - "Community 613"
Cohesion: 0.25
Nodes (4): Active Plans, Completed, Plans Index — harness-terminal, Quick ref — recent completions

### Community 614 - "Community 614"
Cohesion: 0.09
Nodes (19): MainSplitViewController, SplitChromeDelegate, Bool, CGFloat, ContentAreaViewController, NSColor, NSLayoutConstraint, NSRect (+11 more)

### Community 617 - "Community 617"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 618 - "TriState"
Cohesion: 0.25
Nodes (7): SettingsTerminalView, Bool, String, TriState, auto, off, on

### Community 620 - "Community 620"
Cohesion: 0.10
Nodes (26): AgentInboxBody, AgentInboxPanelView, AgentInboxRowView, CGFloat, NSCoder, Void, FooterIconButton, RecentProjectsMenuButton (+18 more)

### Community 621 - ".webView"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 622 - "Community 622"
Cohesion: 0.40
Nodes (5): [1.3.0-vit] - 2026-06-06, Added, Changed, Documentation, Fixed

### Community 623 - "Community 623"
Cohesion: 0.09
Nodes (18): Bool, OptionSet, KeySpec, Modifiers, Decoder, Encoder, String, UInt8 (+10 more)

### Community 624 - "Community 624"
Cohesion: 0.40
Nodes (5): [2.5.0] - 2026-06-12, Added, Changed, Documentation, Fixed

### Community 626 - "Community 626"
Cohesion: 0.11
Nodes (12): NotificationCoordinator, Bool, Date, SessionCoordinator, SessionSnapshot, Set, String, SurfaceID (+4 more)

### Community 629 - "LoadCompletionState"
Cohesion: 0.50
Nodes (3): LSPTextLocation, LSPTextLocationParser, URL

### Community 630 - "Community 630"
Cohesion: 0.40
Nodes (5): [3.0.0] - 2026-06-15, Added, Changed, Documentation, Fixed

### Community 637 - ".testRenderEncodeIncrementalDamage160x48"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 641 - "Community 641"
Cohesion: 0.40
Nodes (5): [3.10.0] - 2026-06-27, Added, Changed, Documentation, Fixed

### Community 646 - "Community 646"
Cohesion: 0.40
Nodes (5): [3.10.1] - 2026-06-27, Added, Changed, Documentation, Fixed

### Community 647 - ".normalizedKey"
Cohesion: 0.40
Nodes (4): Leak A - Retiring A Host Drops Its AI Controllers, Leak B - Browser Network Capture Is Bounded, Leak C - Every Per-Surface Dict In Coordinator Has Retire Cleanup, Leak D - Every Per-Surface Dict In NotificationCoordinator Is Snapshot-Swept

### Community 648 - "Community 648"
Cohesion: 0.22
Nodes (10): Counter, DrainResult, DrainState, EchoRTT, PtyDrainCeilingBenchmark, Bool, DispatchSemaphore, Double (+2 more)

### Community 650 - "Community 650"
Cohesion: 0.40
Nodes (5): [3.11.0] - 2026-06-28, Added, Changed, Documentation, Fixed

### Community 652 - "Community 652"
Cohesion: 0.06
Nodes (29): DetachedPaneOverlay, InputGate, ReconnectLatch, Style, detached, reconnectingChip, SurfaceIO, Bool (+21 more)

### Community 655 - "CodingKeys"
Cohesion: 0.25
Nodes (8): CodingKeys, createdAt, dataBase64, rows, surfaceID, timeMs, type, version

### Community 656 - "Community 656"
Cohesion: 0.29
Nodes (6): 1. Summary of Davin/Windsurf Kanban + CMUX UX, 2.1 Sidebar Sessions Panel Enhancements, 2.2 Per-Session Top Bar / Tab Strip Enhancements, 2. Integration Proposal for Harness, 3. Concrete File-Level Change List, Proposal: Merging Devin/Windsurf Kanban & CMUX Multiplexer UX into Harness

### Community 658 - "Community 658"
Cohesion: 0.40
Nodes (5): [3.1.0] - 2026-06-15, Added, Changed, Documentation, Fixed

### Community 659 - "Community 659"
Cohesion: 0.12
Nodes (17): ChooseScope, buffer, client, session, tree, window, MenuItem, PaneTarget (+9 more)

### Community 660 - "Community 660"
Cohesion: 0.11
Nodes (17): NotificationEntry, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, NotificationRowView, Bool (+9 more)

### Community 661 - "Community 661"
Cohesion: 0.33
Nodes (5): Harness vs Competitors (Remote Development over SSH), Our Gaps (vs leaders), Our Strengths, Remote SSH — Market Comparison, Roadmap Opportunities

### Community 662 - ".capsLockRootFallback"
Cohesion: 0.40
Nodes (5): HarnessViewError, binaryOrUnsupportedEncoding, missingPath, tooLarge, unreadable

### Community 663 - "Community 663"
Cohesion: 0.40
Nodes (5): [3.1.2] - 2026-06-16, Added, Changed, Documentation, Fixed

### Community 664 - "Community 664"
Cohesion: 0.18
Nodes (8): CompletionRowView, Bool, NSCoder, NSEvent, NSRect, NSTrackingArea, String, Void

### Community 665 - "Community 665"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 666 - "Community 666"
Cohesion: 0.04
Nodes (39): AgentScanner, DispatchSourceTimer, DaemonCommandExecutor, Command, PanePipe, SurfaceRegistry, Bool, DaemonSurfaceID (+31 more)

### Community 667 - "Community 667"
Cohesion: 0.40
Nodes (5): [3.3.0] - 2026-06-18, Added, Changed, Documentation, Fixed

### Community 668 - "Community 668"
Cohesion: 0.40
Nodes (5): [3.8.0] - 2026-06-22, Added, Changed, Documentation, Fixed

### Community 669 - "Community 669"
Cohesion: 0.40
Nodes (5): [3.9.0] - 2026-06-22, Added, Changed, Documentation, Fixed

### Community 670 - "Community 670"
Cohesion: 0.40
Nodes (5): [3.9.1] - 2026-06-22, Added, Changed, Documentation, Fixed

### Community 671 - "Community 671"
Cohesion: 0.11
Nodes (23): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, agents, InstallError, unsupported (+15 more)

### Community 672 - "Community 672"
Cohesion: 0.40
Nodes (4): Cursor Agent → Harness, Manual fallback, One-line install, What you'll see

### Community 674 - "Community 674"
Cohesion: 0.50
Nodes (4): [3.11.6] - 2026-06-29, Added, Documentation, Fixed

### Community 675 - ".show"
Cohesion: 0.12
Nodes (24): ScriptAPI, dispatchEvent(), evaluate(), handleAgentStateChanged(), handleConfigReloaded(), handleSnapshotChanged(), init(), registerNotificationBridge() (+16 more)

### Community 676 - "DaemonClientActor"
Cohesion: 0.50
Nodes (4): [2.1.0] - 2026-06-07, Added, Documentation, Fixed

### Community 678 - "Community 678"
Cohesion: 0.15
Nodes (8): FilePreviewCoordinator, Bool, FileTabID, NSLayoutConstraint, NSView, Set, SplitDirection, String

### Community 679 - ".load"
Cohesion: 0.50
Nodes (4): [3.5.0] - 2026-06-20, Added, Documentation, Fixed

### Community 680 - "Community 680"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 681 - "Community 681"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 682 - "Community 682"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 684 - "TabStatus"
Cohesion: 0.50
Nodes (4): [3.9.5] - 2026-06-26, Added, Documentation, Fixed

### Community 685 - "Community 685"
Cohesion: 0.50
Nodes (4): [1.5.1] - 2026-06-06, Added, Documentation, Fixed

### Community 686 - ".status"
Cohesion: 0.38
Nodes (3): GitStatusProvider, Data, String

### Community 689 - "Community 689"
Cohesion: 0.50
Nodes (4): [1.6.0] - 2026-06-07, Added, Documentation, Fixed

### Community 691 - "Community 691"
Cohesion: 0.50
Nodes (4): [1.8.0] - 2026-06-07, Added, Documentation, Fixed

### Community 693 - "Community 693"
Cohesion: 0.50
Nodes (4): [2.0.0] - 2026-06-07, Added, Documentation, Fixed

### Community 694 - "Community 694"
Cohesion: 0.05
Nodes (25): Int, HarnessGridTerminal, TerminalGridCell, TerminalEmulator, TerminalGridSnapshot, SemanticMark, CSIParams, HistoryLine (+17 more)

### Community 696 - "Community 696"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 697 - "Community 697"
Cohesion: 0.50
Nodes (4): [2.1.0] - 2026-06-07, Added, Documentation, Fixed

### Community 700 - "Community 700"
Cohesion: 0.50
Nodes (4): [2.2.1] - 2026-06-08, Added, Documentation, Fixed

### Community 702 - "Community 702"
Cohesion: 0.39
Nodes (4): OutputTrigger, OutputTriggerStore, Bool, String

### Community 704 - ".layout"
Cohesion: 0.50
Nodes (3): __harness_osc133_postexec, __harness_osc133_preexec, __harness_osc133_prompt

### Community 705 - "Community 705"
Cohesion: 0.50
Nodes (4): [2.3.0] - 2026-06-11, Added, Changed, Documentation

### Community 706 - "Community 706"
Cohesion: 0.50
Nodes (4): [2.5.1] - 2026-06-12, Added, Documentation, Fixed

### Community 707 - "Community 707"
Cohesion: 0.50
Nodes (4): [3.2.0] - 2026-06-16, Changed, Documentation, Fixed

### Community 708 - "Community 708"
Cohesion: 0.50
Nodes (4): [3.4.0] - 2026-06-19, Added, Documentation, Fixed

### Community 709 - "AsyncCLIResultBox"
Cohesion: 0.50
Nodes (3): #header, #javascript-disabled, #statistics-container

### Community 710 - "Community 710"
Cohesion: 0.20
Nodes (7): HarnessWindow, NSEvent, MainWindowController, Any, NSRect, NSWindow, NSWindowController

### Community 711 - "Community 711"
Cohesion: 0.19
Nodes (14): FileEditorTabBarBody, FileEditorTabBarModel, FileEditorTabBarView, FileTabPillView, Bool, FileTabID, NSCoder, NSRect (+6 more)

### Community 712 - "Community 712"
Cohesion: 0.13
Nodes (11): CornerInfo, HarnessSplitView, DispatchWorkItem, Double, NSColor, NSRect, NSTrackingArea, NSSplitView (+3 more)

### Community 713 - "Community 713"
Cohesion: 0.30
Nodes (5): HarnessBrowserTools, Bool, Double, String, TimeInterval

### Community 715 - "Community 715"
Cohesion: 0.50
Nodes (4): [3.5.0] - 2026-06-20, Added, Documentation, Fixed

### Community 717 - "Community 717"
Cohesion: 0.50
Nodes (4): [3.9.5] - 2026-06-26, Added, Documentation, Fixed

### Community 718 - "Community 718"
Cohesion: 0.40
Nodes (5): [2.4.0] - 2026-06-12, Added, Changed, Documentation, Fixed

### Community 723 - "Community 723"
Cohesion: 0.20
Nodes (5): SessionLifecycleService, NSWindow, SessionCoordinator, SessionGroup, Tab

### Community 724 - "Community 724"
Cohesion: 0.22
Nodes (6): FormatContextBuilder, DaemonSurfaceID, SessionSnapshot, String, HookExecutor, DispatchQueue

### Community 727 - "Community 727"
Cohesion: 0.50
Nodes (3): Hermes → Harness, One-line install, Required: approve the hook

### Community 728 - "Community 728"
Cohesion: 0.50
Nodes (4): [2.5.1] - 2026-06-12, Added, Documentation, Fixed

### Community 729 - "Community 729"
Cohesion: 0.50
Nodes (4): [3.6.2] - 2026-06-21, Added, Documentation, Fixed

### Community 732 - "Community 732"
Cohesion: 0.50
Nodes (4): [3.11.6] - 2026-06-29, Added, Documentation, Fixed

### Community 736 - "WorkbenchMRU"
Cohesion: 0.50
Nodes (4): MouseEventKind, drag, press, release

### Community 737 - "Community 737"
Cohesion: 0.15
Nodes (11): FileFuzzyMatcher, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool, Character (+3 more)

### Community 739 - "Community 739"
Cohesion: 0.53
Nodes (3): ProjectConfig, Bool, String

### Community 743 - "WatcherContext"
Cohesion: 0.50
Nodes (3): #header, #javascript-disabled, #statistics-container

### Community 745 - "Community 745"
Cohesion: 0.50
Nodes (3): PaneID, PaneLeaf, PaneNode

### Community 750 - "DiffLineType"
Cohesion: 0.67
Nodes (3): [3.9.2] - 2026-06-22, Documentation, Fixed

### Community 753 - "[3.5.1] - 2026-06-20"
Cohesion: 0.50
Nodes (4): [3.5.1] - 2026-06-20, Added, Documentation, Fixed

### Community 754 - "Community 754"
Cohesion: 0.17
Nodes (11): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, ShapedGlyph, ShapedRunCacheStats, ShapedRunKey, Bool, CGFloat (+3 more)

### Community 759 - "ColorKind"
Cohesion: 0.50
Nodes (4): ColorKind, bg, fg, underline

### Community 761 - "Community 761"
Cohesion: 0.40
Nodes (5): [3.9.0] - 2026-06-22, Added, Changed, Documentation, Fixed

### Community 762 - "Community 762"
Cohesion: 0.50
Nodes (4): [3.4.0] - 2026-06-19, Added, Documentation, Fixed

### Community 764 - "DetachKeys"
Cohesion: 0.67
Nodes (3): [2.2.2] - 2026-06-08, Documentation, Fixed

### Community 767 - "Community 767"
Cohesion: 0.16
Nodes (11): DaemonSyncService, Bool, Never, SessionCoordinator, SessionSnapshot, SurfaceID, Tab, TabID (+3 more)

### Community 768 - "Community 768"
Cohesion: 0.67
Nodes (3): [3.11.2] - 2026-06-28, Changed, Fixed

### Community 771 - "Community 771"
Cohesion: 0.11
Nodes (13): String, WorkbenchMRU, FileEditorView, Bool, NSCoder, NSEvent, NSRect, String (+5 more)

### Community 780 - "Community 780"
Cohesion: 0.40
Nodes (5): [2.2.4] - 2026-06-11, Added, Changed, Documentation, Fixed

### Community 781 - "Community 781"
Cohesion: 0.40
Nodes (5): [3.1.0] - 2026-06-15, Added, Changed, Documentation, Fixed

### Community 786 - "Community 786"
Cohesion: 0.40
Nodes (5): [2.4.0] - 2026-06-12, Added, Changed, Documentation, Fixed

### Community 789 - "Community 789"
Cohesion: 0.50
Nodes (4): [1.5.1] - 2026-06-06, Added, Documentation, Fixed

### Community 790 - "Community 790"
Cohesion: 0.50
Nodes (4): [1.6.0] - 2026-06-07, Added, Documentation, Fixed

### Community 796 - "Community 796"
Cohesion: 0.50
Nodes (4): [2.3.0] - 2026-06-11, Added, Changed, Documentation

### Community 797 - "Community 797"
Cohesion: 0.40
Nodes (5): [3.0.0] - 2026-06-15, Added, Changed, Documentation, Fixed

### Community 798 - "Community 798"
Cohesion: 0.40
Nodes (5): [3.9.1] - 2026-06-22, Added, Changed, Documentation, Fixed

### Community 817 - "Community 817"
Cohesion: 0.25
Nodes (4): Bool, SessionCoordinator, String, ThemeService

### Community 841 - "Community 841"
Cohesion: 0.13
Nodes (14): 2026-07-02 — agy logo color mismatch (preview vs prod) ✅ RESOLVED — not a Harness bug, 2026-07-02 — File preview: selection dropped on background reload + clicking agent tool-call paths failed ✅ FIXED, not committed, 2026-07-02 — File preview tabs leaked across terminal Tabs (global singleton) ✅ FIXED, not committed, 2026-07-02 — Git sidebar panel didn't refresh after external `git commit`/`push` ✅ FIXED, not committed, 2026-07-02 — Near-miss: `git revert --abort` wiped uncommitted session work, 2026-07-02 — P32 `setPaneLabel` MCP tool + P34 right-click block menu ✅ DONE, committed (`1723136`, `965f7b3e`), 2026-07-02 — P34 F1 slice 1: OSC 133 command-boundary + block command-text capture ✅ DONE, committed (`2ca7fbb`), 2026-07-02 — P34 F2 (block actions) + F3 (MCP block access) ✅ DONE, committed (`8049605`) (+6 more)

### Community 956 - "Community 956"
Cohesion: 0.40
Nodes (5): [3.1.2] - 2026-06-16, Added, Changed, Documentation, Fixed

### Community 1003 - "Community 1003"
Cohesion: 0.40
Nodes (5): [3.10.1] - 2026-06-27, Added, Changed, Documentation, Fixed

### Community 2761 - "Community 2761"
Cohesion: 0.23
Nodes (10): StaticString, T, applyPendingMainHop(), armSyncTimeout(), receive(), receiveOffMain(), scanOutputTriggers(), Data (+2 more)

### Community 3120 - "Community 3120"
Cohesion: 0.30
Nodes (7): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor, NSView

### Community 3202 - "Community 3202"
Cohesion: 0.12
Nodes (19): EndpointConnector, Int32, String, decodeBoundedCString(), ignoreSIGPIPE(), makeUnixStreamSocket(), setNoSigPipe(), CChar (+11 more)

### Community 3203 - "Community 3203"
Cohesion: 0.14
Nodes (5): CodepointRunFastPathTests, StaticString, String, UInt, UInt8

### Community 3211 - "Community 3211"
Cohesion: 0.23
Nodes (6): CellOverlayTests, HarnessTerminalSurfaceView, IndexSet, NSWindow, String, UInt64

### Community 3257 - "Community 3257"
Cohesion: 0.13
Nodes (15): JSONRPCMessage, notification, request, response, Decoder, KeyedDecodingContainer, StdioTransportTests, Data (+7 more)

### Community 3379 - "Community 3379"
Cohesion: 0.08
Nodes (38): Command, CommandTarget, PaneRef, bottom, byID, byIndex, last, left (+30 more)

### Community 3380 - "Community 3380"
Cohesion: 0.08
Nodes (23): SessionStore, DispatchWorkItem, SessionSnapshot, TimeInterval, PendingVersionBanner, welcome, whatsNew, State (+15 more)

### Community 3419 - "Community 3419"
Cohesion: 0.13
Nodes (13): SettingsHostingController, NSCoder, Page, advanced, appearance, remote, terminal, SettingsRootView (+5 more)

### Community 3676 - "Community 3676"
Cohesion: 0.40
Nodes (5): Current Sprint — Post-v2.1.0 Polish & Shelving, Decisions_In_Force, Recent_Lessons, Removed / Reverted Features, Task_Ledger

### Community 3681 - "Community 3681"
Cohesion: 0.40
Nodes (5): [3.3.0] - 2026-06-18, Added, Changed, Documentation, Fixed

### Community 3738 - "Community 3738"
Cohesion: 0.50
Nodes (4): [3.6.2] - 2026-06-21, Added, Documentation, Fixed

### Community 3739 - "Community 3739"
Cohesion: 0.50
Nodes (4): [2.2.1] - 2026-06-08, Added, Documentation, Fixed

### Community 3774 - "Community 3774"
Cohesion: 0.15
Nodes (7): AgentDetector, AgentTable, Date, Int32, TimeInterval, ProcessScan, Int32

## Knowledge Gaps
- **4063 isolated node(s):** `$schema`, `allow`, `ask`, `PreToolUse`, `UserPromptSubmit` (+4058 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1986 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `AboutView`, `AgentActivity`, `AgentApprovalBar`, `AgentInboxBody`, `AgentKind` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `Community 694` to `Community 513`, `Tests: HarnessTerminalRendererTests / MetalRendererTests`, `HarnessCore: Settings / HarnessSettings`, `HarnessCore: IPC / IPCMessage`, `Terminal Renderer: HarnessTerminalRenderer / TerminalMetalRenderer`, `HarnessCore: Commands / Command`, `Terminal Engine: Emulator / TerminalEmulator`, `Harness App: Settings / SettingsViewController`, `Tests: HarnessBenchmarks / PerformanceBenchmarks`, `Harness App: UI / TerminalTabBarView`, `Community 521`, `Community 522`, `Terminal Engine: Parser / VTParser`, `Tests: HarnessCoreTests / FormatStringTests`, `HarnessCore: ACP / ACPClient`, `Release Notes: CHANGELOG`, `Release Notes: CHANGELOG`, `Terminal Kit: HarnessTerminalKit / HarnessTerminalSurfaceView`, `Release Notes: CHANGELOG`, `Tests: HarnessDaemonTests / DaemonRoundTripTests`, `Community 538`, `Tests: HarnessTerminalRendererTests / CellColorResolverTests`, `Harness App: UI / CommandPaletteController`, `Tests: HarnessCoreTests / IPCCodecTests`, `Tests: HarnessCoreTests / JSONMergeTests`, `Tests: HarnessTerminalEngineTests / EngineConformanceTests`, `Community 546`, `Theme: HarnessTheme / ThemeDocument`, `Community 548`, `Tests: HarnessTerminalEngineTests / ParserRobustnessTests`, `Harness CLI: HarnessCLI / WindowAttachClient`, `Copy Mode: HarnessCopyMode / CopyModeState`, `Tests: HarnessTerminalKitTests / RenderSchedulerTests`, `HarnessCore: Models / SessionSnapshot`, `HarnessCore: Commands / CopyModeAction`, `Tests: HarnessDaemonTests / SurfaceRegistryTests`, `Harness CLI: HarnessCLI`, `Daemon: HarnessDaemon / DaemonServer`, `Harness App: UI / HarnessSidebarPanelViewController`, `Community 566`, `Tests: HarnessCoreTests / TargetSpecTests`, `Community 570`, `Tests: HarnessCoreTests / PasteBufferStoreTests`, `AIDLC: harness / ide-file-tree / outputs / domain-decomposition`, `Onboarding: TerminalKit / GridCompositor`, `Daemon: HarnessDaemon / SurfaceRegistry`, `HarnessCore: IPC / IPCCodec`, `Community 582`, `Harness App: UI / HarnessControls`, `Harness App: UI / MenuBarController`, `Terminal Kit: HarnessTerminalKit / GridCompositor`, `Community 589`, `AIDLC: harness / ide-file-tree / outputs / domain-design`, `Tests: HarnessCoreTests / DaemonClientTests`, `HarnessCore: ACP / ACPTransport`, `Tests: HarnessCoreTests / CommandParserTests`, `Harness App: UI / SearchPanelView`, `Community 598`, `Harness App: Services / SessionCoordinator`, `Community 600`, `Community 603`, `Terminal Engine: HarnessTerminalEngine / InputEncoder`, `Tests: HarnessCoreTests / AttachInputBatcherTests`, `Harness App: Services / MainExecutor`, `Community 614`, `Tests: HarnessTerminalEngineTests / HarnessGridTerminalTests`, `Tests: HarnessTerminalEngineTests / CodepointRunFastPathTests`, `Harness App: UI / Notch / AgentNotchViewModel`, `Community 620`, `.webView`, `Tests: HarnessCoreTests / PaneStyleTests`, `Community 623`, `Tests: HarnessTerminalEngineTests / ThaiCombiningMarkTests`, `HarnessCore: Persistence / SessionStore`, `Harness App: UI / HarnessDesign`, `Harness App: UI / PrefixKeymap`, `LoadCompletionState`, `HarnessCore: Commands / Command`, `Terminal Engine: Screen / HistoryRingBuffer`, `Onboarding: Design / AgentMark`, `.testRenderEncodeIncrementalDamage160x48`, `Copy Mode: HarnessCopyMode / CopyModeReducer`, `Community 3202`, `Community 3203`, `Terminal Kit: HarnessTerminalKit / TerminalHostView`, `Harness App: Settings / SettingsViewController`, `Community 648`, `Onboarding: UI / ImmersiveOnboardingWindowController`, `Community 3211`, `Community 652`, `Release Notes: CHANGELOG`, `Tests: HarnessTerminalEngineTests / AsciiFastPathTests`, `Tests: HarnessThemeTests`, `Community 660`, `Harness App: Services / SessionCoordinator`, `Harness App: UI / AgentChatPanelView`, `.capsLockRootFallback`, `Community 665`, `Community 666`, `Onboarding: Install / BinaryInstaller`, `HarnessCore: Notch / AgentNotchProjection`, `HarnessCore: FileExplorer / FileTreeWatcher`, `Tests: HarnessDaemonTests / VersionBannerTests`, `Terminal Kit: HarnessTerminalKit / TerminalFindBar`, `Terminal Kit: HarnessTerminalKit / TerminalHostView`, `Community 678`, `HarnessCore: ACP / ACPSession`, `HarnessCore: Diagnostics / DoctorRunner`, `Community 680`, `Terminal Kit: HarnessTerminalKit / ThemeManager`, `HarnessCore: Commands / TargetSpec`, `Harness CLI: HarnessCLI`, `Tests: HarnessCoreTests / SessionEditorPhase4Tests`, `Harness CLI: HarnessCLI / WindowAttachClient`, `Copy Mode: HarnessCopyMode / CopyModeGridSource`, `HarnessCore: Paths / LaunchAgentInstaller`, `Terminal Renderer: HarnessTerminalRenderer / TerminalFrame`, `Community 3257`, `Tests: HarnessTerminalEngineTests / ScrollbackTests`, `Harness App: UI / ContentAreaViewController`, `Community 3774`, `AIDLC: harness / ide-file-tree / planning / 00-inception-plan`, `Harness App: UI / HarnessDesign`, `HarnessCore: CLI / TerminalRecording`, `Community 712`, `HarnessCore: Agents / AgentDetector`, `HarnessCore: Commands / CommandIPCTranslator`, `HarnessCore: ACP / ACPSession`, `Tests: HarnessCoreTests / BinaryRefresherTests`, `HarnessCore: Paths / HarnessPaths`, `Community 723`, `Tests: HarnessCoreTests / CommandIPCTranslatorTests`, `Community 724`, `Tests: HarnessCoreTests / FormatStyledTests`, `Harness App: UI / PrefixKeymap`, `HarnessCore: Session / PaneRectSolver`, `Onboarding: Install / NotificationPermission`, `Harness App: UI / NotificationBellButton`, `Community 735`, `AIDLC: harness / acp / outputs / domain-decomposition`, `Community 737`, `Scripts: terminal_stress_runner.py`, `Harness CLI: HarnessCLI / RecordClient`, `Tests: HarnessCoreTests / TabAlertTests`, `HarnessCore: Notifications / NotificationBus`, `Harness App: UI / HarnessSidebarPanelViewController`, `Tests: HarnessOnboardingTests / BinaryInstallerVersionTests`, `Community 754`, `ColorKind`, `Tests: HarnessCoreTests / SnapshotQueryFormatterTests`, `Harness App: UI / MainSplitViewController`, `Tests: HarnessTerminalEngineTests / ReflowPreviewTests`, `Tests: HarnessCoreTests / TerminalConfigImporterTests`, `AIDLC: harness / ide-file-tree / audit.md / audit`, `HarnessCore: Paths / ShellCompletionInstaller`, `Community 767`, `Community 771`, `HarnessCore: ReleaseNotes / TerminalBanner`, `Community 777`, `Tests: HarnessCopyModeTests / WordColumnRangeTests`, `Onboarding: UI / ShellStepView`, `Tests: HarnessCoreTests / CompletionGeneratorTests`, `Tests: HarnessCoreTests / SGRMouseTests`, `Tests: HarnessCoreTests / ShellCompletionInstallerTests`, `HarnessCore: Platform / PlatformSys`, `Terminal Kit: HarnessTerminalKit / HarnessTerminalSurfaceView`, `Harness App: UI / ContentAreaViewController`, `HarnessCore: Models / PaneNode`, `Terminal Kit: HarnessTerminalKit / TerminalScrollbarView`, `Harness CLI: HarnessCLI / WindowAttachClient`, `Tests: HarnessCoreTests / AgentDetectorTests`, `HarnessCore: CLI / CompletionGenerator`, `Terminal Engine: Width / CharacterWidth`, `Tests: HarnessCoreTests / EndpointTests`, `Tests: HarnessCoreTests / ShellIntegrationTests`, `Release Notes: CHANGELOG`, `Tests: HarnessTerminalKitTests / HarnessTerminalSurfaceDragDropTests`, `AIDLC: harness / acp / outputs / brainstorming-summary`, `AIDLC: harness / ide-file-tree / outputs / brainstorming-summary`, `Harness App: Services / CLIInstaller`, `Community 3379`, `Community 3380`, `Release Notes: CHANGELOG`, `Harness App: UI / Phase67UI`, `Harness App: UI / Notch / NotchShape`, `Release Notes: CHANGELOG`, `HarnessCore: CLI / TerminalRecording`, `Harness CLI: HarnessCLI / ReplayClient`, `Release Notes: CHANGELOG`, `Community 3419`, `Tests: HarnessDaemonTests / DaemonLifecycleTests`, `Tests: HarnessDaemonTests / DaemonContentionTests`, `Onboarding: Design / Effects`, `Claude Instructions: CLAUDE`, `HarnessCore: Settings / JSONMerge`, `Terminal Engine: Images / SixelDecoder`, `Community 377`, `HarnessCore: Format / JSONOutputFormatter`, `HarnessCore: Keybindings / ControlKeyNormalizer`, `Community 382`, `Package.Swift: Package`, `Harness App: UI / HarnessDesign`, `HarnessCore: ACP / ACPClient`, `Community 425`, `Community 427`, `Harness App: UI / HarnessDesign`, `Tests: HarnessCoreTests / GroupedSessionTests`, `Onboarding: UI / OnboardingWizardView`, `Community 445`, `Release Notes: CHANGELOG`, `Agent Memory: knowledge / index`, `Community 461`, `Tests: HarnessCoreTests / OptionValueTests`, `Community 466`, `Tests: GridCompositorParityTests / LiveCompositorFixture`, `Community 479`, `Community 507`, `Community 510`?**
  _High betweenness centrality (0.224) - this node is a cross-community bridge._
- **Why does `HarnessCore` connect `Harness App: UI / ContentAreaViewController` to `Harness CLI: HarnessCLI`, `Terminal Engine: Emulator / TerminalEmulator`, `Harness App: UI / TerminalTabBarView`, `Release Notes: CHANGELOG`, `HarnessCore: Session / SessionEditor`, `Community 538`, `Harness App: UI / CommandPaletteController`, `Tests: HarnessTerminalEngineTests / EngineConformanceTests`, `Community 546`, `Community 547`, `HarnessCore: Settings / HarnessSettings`, `Copy Mode: HarnessCopyMode / CopyModeState`, `HarnessCore: Models / SessionSnapshot`, `Community 566`, `Tests: HarnessCoreTests / TargetSpecTests`, `Community 570`, `Tests: HarnessCoreTests / KeyTableTests`, `HarnessCore: IPC / IPCCodec`, `Harness App: Settings / KeyRecorderView`, `Harness App: UI / HarnessControls`, `Community 584`, `Community 591`, `Tests: HarnessCoreTests / DaemonClientTests`, `HarnessCore: ACP / ACPTransport`, `Tests: HarnessCoreTests / CommandParserTests`, `Community 598`, `Community 603`, `Harness App: Services / MainExecutor`, `Harness App: Services / DaemonLauncher`, `Tests: HarnessTerminalEngineTests / CodepointRunFastPathTests`, `Community 620`, `Harness CLI: HarnessCLI / AttachClient`, `Community 623`, `HarnessCore: Commands / Command`, `HarnessCore: Settings / TerminalConfigImporter`, `Community 648`, `Release Notes: CHANGELOG`, `Harness App: UI / AgentChatPanelView`, `Community 666`, `HarnessCore: FileExplorer / FileTreeWatcher`, `Community 671`, `Tests: HarnessDaemonTests / VersionBannerTests`, `.show`, `HarnessCore: Diagnostics / DoctorRunner`, `Community 680`, `.status`, `Community 3257`, `Tests: HarnessTerminalEngineTests / ScrollbackTests`, `Harness App: UI / ContentAreaViewController`, `Community 711`, `HarnessCore: Agents / AgentDetector`, `HarnessCore: Commands / CommandIPCTranslator`, `Tests: HarnessCoreTests / BinaryRefresherTests`, `.printBoard`, `Community 724`, `HarnessCore: Notch / NotchLayoutMetrics`, `Onboarding: Install / NotificationPermission`, `Harness App: UI / NotificationBellButton`, `HarnessCore: Notifications / NotificationBus`, `Harness App: Services / SessionCoordinator`, `HarnessCore: Metadata / MetadataProvider`, `Tests: HarnessTerminalEngineTests / ReflowFastPathTests`, `Terminal Kit: HarnessTerminalKit / FrameSignposter`, `Tests: HarnessCoreTests / ShellCompletionInstallerTests`, `Terminal Kit: HarnessTerminalKit / HarnessTerminalSurfaceView`, `HarnessCore: CLI / CompletionGenerator`, `Community 3380`, `Harness App: UI / HarnessControls`, `Tests: HarnessDaemonTests / DaemonLifecycleTests`, `HarnessCore: Format / JSONOutputFormatter`, `Onboarding: Install / HarnessCLIPaths`, `HarnessCore: HarnessCore / HarnessVersion`, `Harness App: UI / HarnessDesign`, `Community 441`, `Community 449`, `Release Notes: CHANGELOG`, `Tests: GridCompositorParityTests / LiveCompositorFixture`, `Community 507`?**
  _High betweenness centrality (0.043) - this node is a cross-community bridge._
- **Why does `AppKit` connect `Harness App: UI / HarnessControls` to `Terminal Engine: Model / TerminalGridModel`, `Harness App: UI / HarnessChrome`, `HarnessCore: HarnessCore / HarnessVersion`, `Community 777`, `Harness App: UI / TerminalTabBarView`, `Onboarding: UI / ShellStepView`, `Terminal Kit: HarnessTerminalKit / FrameSignposter`, `Tests: HarnessCoreTests / DefaultTerminalLaunchRequestTests`, `Release Notes: CHANGELOG`, `Package.Swift: Package`, `Terminal Kit: HarnessTerminalKit / HarnessTerminalSurfaceView`, `Harness App: UI / ContentAreaViewController`, `Terminal Engine: Images / DecodedImage`, `Community 664`, `Community 538`, `Terminal Kit: HarnessTerminalKit / TerminalScrollbarView`, `Harness App: UI / CommandPaletteController`, `Tests: HarnessCoreTests / AgentDetectorTests`, `Terminal Kit: HarnessTerminalKit / TerminalFindBar`, `.show`, `Community 547`, `Harness App: UI / HarnessDesign`, `Harness App: UI / ContentAreaViewController`, `Community 553`, `Copy Mode: HarnessCopyMode / CopyModeState`, `HarnessCore: Models / SessionSnapshot`, `Community 688`, `Tests: HarnessCoreTests / SessionEditorPhase4Tests`, `Community 566`, `Tests: HarnessCoreTests / TargetSpecTests`, `Community 570`, `Tests: HarnessTerminalEngineTests / ScrollbackTests`, `Harness App: UI / ContentAreaViewController`, `Onboarding: TerminalKit / GridCompositor`, `HarnessCore: IPC / IPCCodec`, `Harness App: UI / HarnessDesign`, `Harness App: Settings / KeyRecorderView`, `Community 710`, `Community 711`, `Community 455`, `Onboarding: Design / ImmersivePalette`, `HarnessCore: Commands / CommandIPCTranslator`, `Community 453`, `Harness App: UI / SearchPanelView`, `Community 598`, `Community 471`, `Community 599`, `Tests: GridCompositorParityTests / LiveCompositorFixture`, `Community 603`, `Community 3419`, `Harness App: Services / MainExecutor`, `Tests: HarnessTerminalEngineTests / CodepointRunFastPathTests`, `Harness App: UI / Notch / AgentNotchViewModel`, `SparkleUpdater.swift`, `Community 620`, `Harness CLI: HarnessCLI / AttachClient`, `HarnessCore: Commands / Command`, `Tests: HarnessTerminalEngineTests / ReflowFastPathTests`, `Onboarding: Design / AgentMark`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **Are the 43 inferred relationships involving `Int` (e.g. with `register()` and `.coloredImage()`) actually correct?**
  _`Int` has 43 INFERRED edges - model-reasoned connections that need verification._
- **What connects `$schema`, `allow`, `ask` to the rest of the system?**
  _4083 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Terminal Engine: Model / TerminalGridModel` be split into smaller, more focused modules?**
  _Cohesion score 0.09359605911330049 - nodes in this community are weakly interconnected._
- **Should `Tests: HarnessTerminalRendererTests / MetalRendererTests` be split into smaller, more focused modules?**
  _Cohesion score 0.051570415400202636 - nodes in this community are weakly interconnected._