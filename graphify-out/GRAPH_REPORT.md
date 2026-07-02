# Graph Report - harness-terminal  (2026-07-02)

## Corpus Check
- 688 files · ~882,847 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 14838 nodes · 30209 edges · 3092 communities (1105 shown, 1987 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 2732 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `49a67bab`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `Int` - 894 edges
2. `HarnessCore` - 267 edges
3. `Foundation` - 266 edges
4. `XCTest` - 170 edges
5. `SessionEditor` - 169 edges
6. `SurfaceRegistry` - 147 edges
7. `DaemonClient` - 142 edges
8. `AppKit` - 136 edges
9. `IPCRequest` - 134 edges
10. `SessionCoordinator` - 124 edges

## Surprising Connections (you probably didn't know these)
- `SUI` --calls--> `Color`  [INFERRED]
  Packages/HarnessOnboarding/Sources/HarnessOnboarding/Design/ImmersivePalette.swift → Apps/Harness/Sources/HarnessApp/Settings/SwiftUI/SettingsColorsView.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/DaemonSyncService.swift → Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonSessionService.swift
- `ThemeImportController` --calls--> `ThemeFileService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/ThemeImportController.swift → Packages/HarnessTheme/Sources/HarnessTheme/ThemeFileService.swift
- `vfork_and_exec()` --calls--> `Process`  [INFERRED]
  Tools/harness/Sources/HarnessCLI/HarnessCLI+Workbench.swift → Apps/Harness/Sources/HarnessApp/UI/CommandPalette/CommandPaletteController.swift
- `LSPFileSession` --calls--> `LSPServerRegistry`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/UI/FileEditor/LSPFileSession.swift → Packages/HarnessLSP/Sources/HarnessLSP/LSPServerRegistry.swift

## Import Cycles
- None detected.

## Communities (3092 total, 1987 thin omitted)

### Community 0 - "Terminal Engine: Model / TerminalGridModel"
Cohesion: 0.21
Nodes (13): BannerShortcut, BannerShortcutRegistry, CodingKeys, description, key, showInBanner, Keybinding, MenuModifiers (+5 more)

### Community 2 - "Tests: HarnessTerminalRendererTests / MetalRendererTests"
Cohesion: 0.05
Nodes (51): LinePos, end, firstNonBlank, start, Bool, CGFloat, Character, NSEvent (+43 more)

### Community 5 - "HarnessCore: IPC / IPCMessage"
Cohesion: 0.02
Nodes (114): IPCRequest, applyLayout, attachSurface, bindHook, breakPane, browserClose, browserCookies, browserEvaluate (+106 more)

### Community 6 - "Terminal Renderer: HarnessTerminalRenderer / TerminalMetalRenderer"
Cohesion: 0.09
Nodes (27): AnyTransition, AnyView, PaletteFooter, AgentNotchPeekEvent, Reason, errored, finished, needsInput (+19 more)

### Community 7 - "HarnessCore: Commands / Command"
Cohesion: 0.02
Nodes (90): Command, bindKey, breakPane, choose, clearHistory, clockMode, commandPrompt, confirmBefore (+82 more)

### Community 8 - "Terminal Engine: Emulator / TerminalEmulator"
Cohesion: 0.13
Nodes (15): LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed, serverNotExecutable, AsyncStream, CheckedContinuation (+7 more)

### Community 9 - "Harness App: Settings / SettingsViewController"
Cohesion: 0.09
Nodes (15): Bool, Data, DispatchTime, String, TerminalGridCell, TimeInterval, UInt8, UnsafeBufferPointer (+7 more)

### Community 10 - "Tests: HarnessBenchmarks / PerformanceBenchmarks"
Cohesion: 0.15
Nodes (9): PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Data, Double, TerminalEmulator, UInt64 (+1 more)

### Community 11 - "Harness App: UI / TerminalTabBarView"
Cohesion: 0.08
Nodes (22): FlippedView, GitPanelView, GitResult, RepoEntry, Any, Bool, DispatchWorkItem, FSEventStreamRef (+14 more)

### Community 13 - "Tests: HarnessTerminalEngineTests / KittyKeyboardTests"
Cohesion: 0.14
Nodes (3): KittyKeyboardTests, String, UInt8

### Community 14 - "Terminal Engine: Parser / VTParser"
Cohesion: 0.14
Nodes (9): StringKind, apc, dcs, Data, UInt8, UnsafeBufferPointer, VTParser, VTParserHandler (+1 more)

### Community 15 - "Tests: HarnessCoreTests / FormatStringTests"
Cohesion: 0.13
Nodes (11): HarnessTerminalSurfaceView, RawSelection, Bool, CGFloat, CGRect, NSEvent, NSPoint, Range (+3 more)

### Community 17 - "HarnessCore: ACP / ACPClient"
Cohesion: 0.13
Nodes (13): Bool, IndexSet, TerminalDamage, MetalRendererTests, RenderedFixture, Bool, MTLTexture, RenderColor (+5 more)

### Community 18 - "Tests: HarnessDaemonTests / ScrollbackFileTests"
Cohesion: 0.06
Nodes (21): HarnessUILibrary, HarnessUILibrary — Robot Framework keyword library for Harness terminal automati, Verify a board column exists using harness CLI., Run a harness CLI command and assert exit code 0., Run harness view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 19 - "Terminal Engine: HarnessTerminalEngine / InputEncoder"
Cohesion: 0.04
Nodes (48): SpecialKey, backspace, capsLock, deleteForward, down, end, enter, escape (+40 more)

### Community 21 - "Terminal Kit: HarnessTerminalKit / HarnessTerminalSurfaceView"
Cohesion: 0.10
Nodes (12): NSDraggingInfo, NSDragOperation, HarnessTerminalSurfaceView, Any, Bool, CGFloat, NSEvent, NSMenu (+4 more)

### Community 22 - "HarnessCore: Agents / AgentHookInstaller"
Cohesion: 0.06
Nodes (31): CopyModeAction, beginSelection, bottom, cancel, clearSelection, copyPipe, copySelection, copySelectionAndCancel (+23 more)

### Community 23 - "Daemon: HarnessDaemon / RealPty"
Cohesion: 0.15
Nodes (12): SplitPaneCoordinator, Bool, PaneID, PaneNode, SessionCoordinator, SessionID, SplitDirection, String (+4 more)

### Community 24 - "Tests: HarnessDaemonTests / DaemonRoundTripTests"
Cohesion: 0.12
Nodes (14): DaemonClient, ConcurrentIndexSet, DaemonContentionTests, String, URL, DaemonRoundTripTests, Data, Int32 (+6 more)

### Community 25 - "HarnessCore: Session / SessionEditor"
Cohesion: 0.07
Nodes (16): Bool, NSObjectProtocol, Set, String, WorktreeAutoIsolateService, Bool, String, WorktreeInfo (+8 more)

### Community 26 - "Docs: HARNESS_TMUX_CAPABILITIES"
Cohesion: 0.06
Nodes (37): 10. Status line, mouse, and options, 11. Shell integration, 12. Agent notifications, 13. Out-of-box troubleshooting, 14. One-page cheat sheet, 1. Five-minute setup, 2. Mental model, 3. Prefix key (+29 more)

### Community 27 - "Tests: HarnessTerminalRendererTests / CellColorResolverTests"
Cohesion: 0.23
Nodes (11): ANSIPalette, CellColorResolver, MochaTheme, ResolvedCellColors, RGBColor, Bool, Double, String (+3 more)

### Community 28 - "Harness App: UI / GitPanelView"
Cohesion: 0.07
Nodes (3): CommandParserTests, Phase67Tests, TmuxMigrationTests

### Community 30 - "Harness App: UI / CommandPaletteController"
Cohesion: 0.09
Nodes (6): ContentAreaViewController, Any, Bool, FileTabID, TabID, Notification

### Community 31 - "Tests: HarnessCoreTests / IPCCodecTests"
Cohesion: 0.06
Nodes (41): Codable, Bool, String, T, BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry (+33 more)

### Community 32 - "Tests: HarnessCoreTests / JSONMergeTests"
Cohesion: 0.10
Nodes (16): LSPMessage, notification, request, response, Decoder, Encoder, KeyedDecodingContainer, LSPTransport (+8 more)

### Community 33 - "Tests: HarnessTerminalEngineTests / EngineConformanceTests"
Cohesion: 0.06
Nodes (36): RawSelection, SelectionResolver, Bool, HarnessTerminalSurfaceView, String, TerminalEmulator, BlockSelection, CursorRender (+28 more)

### Community 34 - "Theme: HarnessTheme / ThemeDocument"
Cohesion: 0.13
Nodes (9): HarnessCLI, String, HarnessCLI, String, HarnessCLI, Bool, Int32, Never (+1 more)

### Community 35 - "Harness App: Settings / SettingsViewController"
Cohesion: 0.05
Nodes (3): MenuTarget, NSMenuDelegate, NSMenuItemValidation

### Community 37 - "Harness App: UI / GitPanelView"
Cohesion: 0.29
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 39 - "HarnessCore: Settings / HarnessSettings"
Cohesion: 0.10
Nodes (22): TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid, SurfaceColorProviderState (+14 more)

### Community 40 - "Tests: HarnessTerminalEngineTests / ParserRobustnessTests"
Cohesion: 0.07
Nodes (31): CaseIterable, ExperienceMode, agent, full, persistent, plain, Bool, HarnessSettings (+23 more)

### Community 41 - "Harness CLI: HarnessCLI / WindowAttachClient"
Cohesion: 0.13
Nodes (9): CodingKeys, error, id, jsonrpc, method, params, Decoder, KeyedDecodingContainer (+1 more)

### Community 42 - "Copy Mode: HarnessCopyMode / CopyModeState"
Cohesion: 0.10
Nodes (10): HarnessSidebarPanelViewController, Any, NSMenuItem, NSView, SessionGroup, SessionID, String, WorkspaceID (+2 more)

### Community 43 - "Tests: HarnessTerminalKitTests / RenderSchedulerTests"
Cohesion: 0.09
Nodes (5): RenderScheduler, Bool, Void, RenderSchedulerTests, Bool

### Community 44 - "Tests: HarnessCoreTests / PaneRectSolverTests"
Cohesion: 0.11
Nodes (11): String, ChromeBackdrop, HarnessDesign, RuntimeGlassEffectView, Bool, NSColor, NSImage, NSPoint (+3 more)

### Community 45 - "HarnessCore: Models / SessionSnapshot"
Cohesion: 0.06
Nodes (18): PendingMainHop, PresentAttempt, encodeFailure, nilDrawable, presented, SelectionGranularity, character, line (+10 more)

### Community 46 - "HarnessCore: Commands / CopyModeAction"
Cohesion: 0.15
Nodes (15): CommandParseError, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand, unterminatedString (+7 more)

### Community 47 - "Tests: HarnessDaemonTests / SurfaceRegistryTests"
Cohesion: 0.11
Nodes (6): GlyphRasterizerTests, ShapedGlyphSignature, Bool, CGFloat, CGGlyph, String

### Community 48 - "HarnessCore: Events / HookRegistry"
Cohesion: 0.07
Nodes (33): Executor, Hook, HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane (+25 more)

### Community 49 - "Daemon: HarnessDaemon / DaemonServer"
Cohesion: 0.11
Nodes (24): DispatchSourceWrite, ClientRecord, CountBox, DaemonError, alreadyRunning, bindFailed, listenFailed, socketFailed (+16 more)

### Community 51 - "Tests: HarnessTerminalKitTests / GridCompositorCopyModeTests"
Cohesion: 0.32
Nodes (5): SpecialKeyMappingTests, Bool, NSEvent, String, UInt16

### Community 54 - "Harness App: UI / HarnessSidebarPanelViewController"
Cohesion: 0.08
Nodes (14): HitTestPassthroughView, PaneDragGripView, PaneHoverButton, PaneSplitButtonsView, NSButton, NSCoder, NSEvent, NSPoint (+6 more)

### Community 55 - "Tests: HarnessCoreTests / AgentHookInstallerTests"
Cohesion: 0.15
Nodes (10): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+2 more)

### Community 56 - "Tests: HarnessCoreTests / TargetSpecTests"
Cohesion: 0.13
Nodes (13): DirectoryItemRow, DirectoryPanel, DirectoryPickerController, DirectoryPickerFooter, DirectoryPickerModel, DirectoryPickerView, DirectoryWindowDelegate, String (+5 more)

### Community 57 - "HarnessCore: Commands / TargetSpec"
Cohesion: 0.15
Nodes (11): KeyRecorderRepresentable, String, Void, OverlayBackground, Context, OverlayBackground, Context, HarnessOverlayBackground (+3 more)

### Community 58 - "Tests: HarnessCoreTests / PasteBufferStoreTests"
Cohesion: 0.14
Nodes (10): Buffer, Configuration, PasteBufferStore, Bool, Data, Date, String, URL (+2 more)

### Community 59 - "Agent Memory: plans / panel-session-performance"
Cohesion: 0.06
Nodes (32): 1. ภาพรวมสถาปัตยกรรม (Architecture Overview), ✅ 2.1 `sidebarRows` คำนวณซ้ำ O(N²) ทุกครั้งที่ reload ตาราง — DONE, ⚠️ 2.2 Blocking IPC บน Main Thread — PENDING (P2), ✅ 2.3 การ scan แบบ triple-nested ต่อ sync — DONE, ✅ 2.4 `applyThemeToAllHosts()` ทำงานทุก non-metadata sync — DONE, ✅ 2.5 Split view double-layout เมื่อ switch tab — DONE, ✅ 2.6 Metadata refresh probe ทุก tab ทุก 2 วินาที — DONE, 2. ปัญหาและแนวทางแก้ไข (Issues & Fixes) (+24 more)

### Community 60 - "AIDLC: harness / ide-file-tree / outputs / domain-decomposition"
Cohesion: 0.22
Nodes (9): FormatContext, FormatString, FormatStyle, Bool, Character, Date, FormatColor, String (+1 more)

### Community 61 - "Tests: HarnessCoreTests / KeyTableTests"
Cohesion: 0.13
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 62 - "Onboarding: TerminalKit / GridCompositor"
Cohesion: 0.13
Nodes (18): ColorKind, bg, fg, underline, ComposedCell, ComposedFrame, CompositorPane, GridCompositor (+10 more)

### Community 63 - "Tests: HarnessTerminalKitTests / LiveResizeTests"
Cohesion: 0.08
Nodes (18): HarnessCLI, String, String, CLIInstallLocator, HarnessCLI, OptionalUUID, absent, dangling (+10 more)

### Community 64 - "Daemon: HarnessDaemon / SurfaceRegistry"
Cohesion: 0.10
Nodes (21): agentDetail(), AgentInboxBody, AgentInboxPanelView, AgentInboxRowView, CGFloat, NSCoder, String, Void (+13 more)

### Community 65 - "HarnessCore: IPC / IPCCodec"
Cohesion: 0.20
Nodes (4): PrefixKeymap, Any, NSEvent, TimeInterval

### Community 66 - "Terminal Kit: HarnessTerminalKit / HarnessTerminalSurfaceView"
Cohesion: 0.06
Nodes (30): CLICommand, CLICommandCatalog, Bool, String, CompletionGenerator, String, InstallResult, ShellCompletionInstaller (+22 more)

### Community 67 - "Terminal Kit: HarnessTerminalKit / TerminalHostView"
Cohesion: 0.14
Nodes (13): InstallResult, Profile, Shell, bash, fish, zsh, ShellProfileInstaller, Bool (+5 more)

### Community 68 - "HarnessCore: ACP / ACPMessage"
Cohesion: 0.06
Nodes (33): Completed Plans Archive, HarnessCore Package Split (v3.9.0), P10 — Terminal Performance and Convenience, P11 — Scripting & Config API (WezTerm parity), P12 — Agent Orchestration via MCP, P13 — Split Pane Parity, P14 — Embedded Browser Pane, P15 — Integration Roadmap (+25 more)

### Community 69 - "Harness App: Settings / KeyRecorderView"
Cohesion: 0.14
Nodes (9): KeyRecorderView, Any, Bool, NSCoder, NSEvent, NSPoint, String, Void (+1 more)

### Community 70 - "Harness App: UI / HarnessControls"
Cohesion: 0.33
Nodes (3): ImageProtocolTests, String, TerminalEmulator

### Community 71 - "Harness App: UI / MenuBarController"
Cohesion: 0.17
Nodes (7): ImportedTerminalConfig, Bool, Double, Float, String, TerminalConfigImporter, TerminalConfigImporterTests

### Community 73 - "Tests: HarnessDaemonTests / HookFiringTests"
Cohesion: 0.08
Nodes (18): Claude Code → Harness, Customizing, One-line install, Verifying, What gets written, Codex → Harness, One-line install, What you'll see (+10 more)

### Community 75 - "Terminal Kit: HarnessTerminalKit / GridCompositor"
Cohesion: 0.10
Nodes (19): OptionStore, OptionStore.Value, Scope, pane, session, tab, workspace, ScopedKey (+11 more)

### Community 76 - "HarnessCore: Agents / AgentSnapshot"
Cohesion: 0.15
Nodes (5): String, SessionSnapshot, String, UUID, TargetSpecTests

### Community 77 - "AIDLC: harness / ide-file-tree / outputs / domain-design"
Cohesion: 0.12
Nodes (9): State, error, indeterminate, paused, remove, set, TerminalProgressReport, TerminalEmulator (+1 more)

### Community 79 - "HarnessCore: Keybindings / KeyTable"
Cohesion: 0.06
Nodes (35): AgentStatusDot, Context, AgentChipView, BoardColumnKind, ChromeRole, sidebar, tabBar, Divider (+27 more)

### Community 80 - "Docs: AGENT-HANDBOOK"
Cohesion: 0.09
Nodes (20): Build / Test / Run, Graphify, harness-terminal — Claude Instructions, Non-obvious Constraints, Session Start, Skills, Agent handbook — Harness (extended reference), Agent integration (+12 more)

### Community 81 - "Tests: HarnessCoreTests / DaemonClientTests"
Cohesion: 0.15
Nodes (18): DaemonSubscription, UnsafeMutableRawPointer, sysClose(), sysRead(), DaemonClientTests, FrameRecorder, makeUnixSocketPair(), posixBind() (+10 more)

### Community 82 - "Tests: HarnessCoreTests / HarnessSettingsTests"
Cohesion: 0.14
Nodes (16): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+8 more)

### Community 83 - "HarnessCore: ACP / ACPTransport"
Cohesion: 0.23
Nodes (7): HarnessCLI, LSPDefinitionPayload, LSPDiagnosticsPayload, LSPStatusPayload, String, UInt64, URL

### Community 84 - "Tests: HarnessCoreTests / CommandParserTests"
Cohesion: 0.12
Nodes (19): CodingKeys, error, id, jsonrpc, method, params, result, LSPDiagnostic (+11 more)

### Community 85 - "Harness App: UI / SearchPanelView"
Cohesion: 0.11
Nodes (24): Bool, TerminalCellWidth, normal, spacerTail, wide, TerminalCursor, TerminalCursorShape, bar (+16 more)

### Community 86 - "Harness App: UI / GitPanelView"
Cohesion: 0.08
Nodes (6): HarnessPaths, HarnessPathsTests, String, HarnessSettingsTests, URL, Void

### Community 87 - "Harness App: Services / SessionCoordinator"
Cohesion: 0.04
Nodes (20): SessionCoordinator, Bool, Date, Double, Error, PaneID, PaneNode, SessionGroup (+12 more)

### Community 88 - "Docs: MULTIPLEXER_GUIDE"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 89 - "HarnessCore: Remote / SSHTunnelManager"
Cohesion: 0.13
Nodes (15): BrowserRequestPayload, close, cookies, evaluate, goBack, goForward, interact, navigate (+7 more)

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
Cohesion: 0.15
Nodes (8): C, AttachInputBatcher, Outcome, Bool, Data, UInt8, AttachInputBatcherTests, UInt8

### Community 95 - "Tests: HarnessTerminalRendererTests / FrameBuilderTests"
Cohesion: 0.15
Nodes (12): termios, AttachClient, Configuration, LiveSession, Bool, Data, DispatchSourceSignal, Int32 (+4 more)

### Community 96 - "Tests: HarnessTerminalKitTests / GridCompositorTests"
Cohesion: 0.17
Nodes (12): 1. Install Harness, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Harness Usage, More Docs (+4 more)

### Community 97 - "Onboarding: TerminalKit / PaneLayout"
Cohesion: 0.13
Nodes (11): PaneContainerView, SessionSnapshot, SurfaceID, PaneLifecycleManager, Bool, NSView, PaneID, PaneNode (+3 more)

### Community 98 - "AIDLC: harness / acp / outputs / logical-design"
Cohesion: 0.67
Nodes (3): 4.1 Architecture Pattern, 4. Technical Architecture, 4.2 Technology Stack

### Community 99 - "Harness App: Services / MainExecutor"
Cohesion: 0.14
Nodes (11): DisplayMessage, MainExecutor, RunShell, Bool, Command, MainActor, PaneID, PaneNode (+3 more)

### Community 100 - "Onboarding: Design / Components"
Cohesion: 0.36
Nodes (5): ShellInfo, ShellStepView, Bool, String, URL

### Community 101 - "Agent Memory: plans / session-group-split-session"
Cohesion: 0.10
Nodes (20): 1. Add Project Group Heuristics, 1. Keep Split State In Session/Tab Structure, 2. Introduce Sidebar Row Model, 2. UX Entry Points, 3. Build Grouped Rows From Filtered Sessions, 4. Update Table Data Source and Delegate, 5. Drag and Drop Rules, code:text (Window) (+12 more)

### Community 102 - "Harness App: Services / DaemonLauncher"
Cohesion: 0.19
Nodes (8): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, URL

### Community 103 - "Tests: HarnessTerminalEngineTests / HarnessGridTerminalTests"
Cohesion: 0.15
Nodes (13): AnyCodable, array, bool, double, int, null, object, string (+5 more)

### Community 104 - "Tests: HarnessTerminalEngineTests / CodepointRunFastPathTests"
Cohesion: 0.13
Nodes (9): AttributedString, NSColor, Recipe, RecipesStore, Bool, String, URL, UUID (+1 more)

### Community 105 - "Release Notes: CHANGELOG"
Cohesion: 0.09
Nodes (23): [1.0.0] - 2026-05-31, [2.2.0] - 2026-06-07, [2.2.2] - 2026-06-08, [2.5.2] - 2026-06-12, [3.11.4] - 2026-06-28, [3.11.7] - 2026-06-29, [3.12.0] - 2026-06-30, [3.2.1] - 2026-06-16 (+15 more)

### Community 107 - "Harness App: UI / Notch / AgentNotchViewModel"
Cohesion: 0.11
Nodes (17): AgentNotchPresentation, closed, open, peek, AgentNotchViewModel, Animation, Bool, CGFloat (+9 more)

### Community 108 - "Harness App: UI / HarnessControls"
Cohesion: 0.13
Nodes (20): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, PaneLeaf, PaneNode (+12 more)

### Community 109 - "Tests: HarnessCoreTests / PaneStyleTests"
Cohesion: 0.17
Nodes (3): DamageTrackingTests, IndexSet, TerminalEmulator

### Community 110 - "Harness CLI: HarnessCLI / AttachClient"
Cohesion: 0.14
Nodes (10): HarnessPillButton, Kind, primary, secondary, SoftIconButton, NSButton, NSCoder, NSEvent (+2 more)

### Community 112 - "Tests: HarnessTerminalEngineTests / ThaiCombiningMarkTests"
Cohesion: 0.16
Nodes (12): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, SessionSnapshot, String, Tab (+4 more)

### Community 113 - "HarnessCore: Persistence / SessionStore"
Cohesion: 0.14
Nodes (9): HarnessGridTerminal, Bool, Data, String, TerminalEmulator, TerminalGridCell, TerminalGridSnapshot, UInt8 (+1 more)

### Community 115 - "Harness App: UI / HarnessDesign"
Cohesion: 0.11
Nodes (14): header, UInt16, tooLarge, IPCCodec, Data, String, T, UInt16 (+6 more)

### Community 116 - "Harness App: UI / PrefixKeymap"
Cohesion: 0.23
Nodes (10): Array, SessionGroup, SessionSnapshot, Bool, Decoder, SessionID, String, Tab (+2 more)

### Community 117 - "Harness App: UI / WorkspaceFileTreeView"
Cohesion: 0.11
Nodes (21): BrowserLeaf, CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf (+13 more)

### Community 118 - "Theme: HarnessTheme / ThemeDiagnostics"
Cohesion: 0.12
Nodes (11): FileTreeContext, Bool, NSCoder, NSHostingView, NSWindow, SessionID, String, Void (+3 more)

### Community 119 - "Docs: COMMANDS"
Cohesion: 0.09
Nodes (22): Attaching from a plain terminal, Bindings, Board and attention, Buffers (paste store), Composition, Errors and LSP, File navigation, Harness command reference (+14 more)

### Community 122 - "Tests: HarnessTerminalEngineTests / ImageProtocolTests"
Cohesion: 0.29
Nodes (3): Install, Shell integration (OSC 133 semantic prompts), What gets emitted

### Community 123 - "HarnessCore: Commands / Command"
Cohesion: 0.08
Nodes (33): SidebarListModel, SidebarSessionRow, divider, groupHeader, session, worktree, worktreeHeader, SidebarWorktreeEntry (+25 more)

### Community 124 - "HarnessCore: Options / EnvironmentStore"
Cohesion: 0.12
Nodes (3): FormatStringExtendedVariableTests, FormatStringTests, FormatStyledTests

### Community 125 - "Terminal Engine: Screen / HistoryRingBuffer"
Cohesion: 0.09
Nodes (9): ContiguousArray, IteratorProtocol, HistoryRingBuffer, Iterator, Bool, Element, S, Sequence (+1 more)

### Community 126 - "Onboarding: Design / AgentMark"
Cohesion: 0.16
Nodes (16): AgentArt, AgentMark, AgentMarkShape, AgentVectorIcon, Scanner, SVGPath, Bool, CGFloat (+8 more)

### Community 127 - "Copy Mode: HarnessCopyMode / CopyModeReducer"
Cohesion: 0.13
Nodes (18): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, GlyphAtlasStats, GlyphKey, ShapedGlyphKey, Bool (+10 more)

### Community 129 - "HarnessCore: Settings / TerminalConfigImporter"
Cohesion: 0.08
Nodes (23): SettingsAdvancedView, Bool, String, SettingsAppearanceView, SliderRow, Bool, ClosedRange, Double (+15 more)

### Community 130 - "Daemon: HarnessDaemon / DaemonMetrics"
Cohesion: 0.10
Nodes (20): code:bash (harness-cli doctor), AI Browser Control (harness-mcp), AI chat, Build From Source, CLI, Development Builds, Documentation, Harness (+12 more)

### Community 131 - "Tests: HarnessTerminalEngineTests / VTConformanceCorpusTests"
Cohesion: 0.11
Nodes (6): Data, AgentHookInstallerTests, String, URL, AgentHookInstallerCLI, String

### Community 132 - "Terminal Kit: HarnessTerminalKit / TerminalHostView"
Cohesion: 0.16
Nodes (9): AgentHookInstaller, InstallError, unsupported, InstallResult, Any, Bool, String, URL (+1 more)

### Community 133 - "Tests: HarnessTerminalEngineTests / DamageTrackingTests"
Cohesion: 0.07
Nodes (28): IPCResponse, agentInfo, agents, browserRequest, browserSuccess, buffer, clientID, daemonStats (+20 more)

### Community 135 - "Harness App: Settings / SettingsViewController"
Cohesion: 0.12
Nodes (17): CommandIPCTranslator, CommandTarget, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID (+9 more)

### Community 136 - "Harness App: UI / AgentIconRenderer"
Cohesion: 0.26
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

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
Cohesion: 0.28
Nodes (8): NSRegularExpression, CopyModeGridSource, CopyModeReducer, Bool, Character, Range, String, GridPosition

### Community 143 - "Tests: HarnessTerminalEngineTests / TerminalBufferSearchTests"
Cohesion: 0.10
Nodes (19): 1. Find the CLI, 2. Check daemon health, 3. List what's running (like `tmux ls`), 4. Attach to a pane, 5. Create sessions/tabs from a script, 6. Drive a pane without attaching, 7. tmux control mode, 8. Remote/headless daemon (+11 more)

### Community 144 - "HarnessCore: IPC / DaemonSessionService"
Cohesion: 0.18
Nodes (6): PaneStyle, PaneStyleSet, Bool, FormatColor, String, PaneStyleTests

### Community 145 - "Tests: HarnessTerminalEngineTests / AsciiFastPathTests"
Cohesion: 0.20
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 146 - "Tests: HarnessThemeTests"
Cohesion: 0.06
Nodes (22): keys, CGImage, data, DecodedImage, ImageLimits, Bool, UInt8, ImageDecoder (+14 more)

### Community 147 - "AIDLC: harness / ide-file-tree / planning / 05-implementation"
Cohesion: 0.29
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 148 - "Harness App: Services / SessionCoordinator"
Cohesion: 0.29
Nodes (5): Mode, compatible, harness, TerminalIdentity, TerminalIdentityTests

### Community 149 - "Root Docs: README"
Cohesion: 0.20
Nodes (7): EnvironmentStore, Persisted, String, URL, global, EnvironmentStoreTests, URL

### Community 150 - "Harness App: UI / AgentChatPanelView"
Cohesion: 0.16
Nodes (5): HarnessBrowserToolsTests, URL, HarnessDaemonToolsTests, String, URL

### Community 151 - "Harness App: UI / HarnessControls"
Cohesion: 0.29
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 153 - "Harness App: UI / Notch / NotchPanelController"
Cohesion: 0.14
Nodes (10): NotchMaskAnimator, Bool, CGFloat, CGRect, NSView, NotchPanel, Bool, NSRect (+2 more)

### Community 154 - "AIDLC: harness / ide-file-tree / outputs / logical-design"
Cohesion: 0.12
Nodes (3): LiveResizeTests, HarnessTerminalSurfaceView, NSWindow

### Community 155 - "Onboarding: Install / BinaryInstaller"
Cohesion: 0.09
Nodes (27): TerminalGridSnapshot, ImagePlacementSnapshot, Bool, String, TerminalCellWidth, normal, spacerTail, wide (+19 more)

### Community 156 - "HarnessCore: Notch / AgentNotchProjection"
Cohesion: 0.08
Nodes (16): Range, String, TerminalGridCell, TerminalBufferMatch, TerminalBufferSearch, String, TerminalGridCell, TextGrid (+8 more)

### Community 158 - "Docs: IDE-SIDEBAR"
Cohesion: 0.12
Nodes (15): Architecture, Branch, Build & Preview, CMUX Pane Splitting, code:block1 (worktree-feature+acp-aidlc), code:bash (cd /tmp/hp  # symlink to worktree (socket path length limit)), code:block3 (HarnessSidebarPanelViewController — Sessions / Files / Git t), Features (+7 more)

### Community 159 - "HarnessCore: FileExplorer / FileTreeWatcher"
Cohesion: 0.20
Nodes (10): FileNode, Bool, String, FileTreeScanOptions, ScoredMatch, SearchMatcher, Bool, Character (+2 more)

### Community 160 - "Harness App: UI / CommandPaletteController"
Cohesion: 0.27
Nodes (6): AmbientBackground, Bool, CGSize, GraphicsContext, TimeInterval, UInt8

### Community 161 - "Tests: HarnessDaemonTests / VersionBannerTests"
Cohesion: 0.20
Nodes (10): RecipeItemRow, RecipePanel, RecipePickerController, RecipePickerModel, RecipePickerView, RecipeWindowDelegate, Bool, NSWindow (+2 more)

### Community 162 - "Terminal Kit: HarnessTerminalKit / TerminalFindBar"
Cohesion: 0.09
Nodes (14): NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent, NSImage (+6 more)

### Community 163 - "Terminal Kit: HarnessTerminalKit / TerminalHostView"
Cohesion: 0.11
Nodes (20): Identifiable, CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder (+12 more)

### Community 164 - "Tests: HarnessCoreTests / HarnessPathsTests"
Cohesion: 0.18
Nodes (6): Tab, SessionPersistenceTests, Bool, String, TabID, URL

### Community 165 - "Tests: HarnessCoreTests / TerminalRecordingTests"
Cohesion: 0.21
Nodes (7): ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy, NSWindow

### Community 166 - "HarnessCore: Diagnostics / DoctorRunner"
Cohesion: 0.22
Nodes (8): DecodedReplyFrame, output, reply, DecodedRequestFrame, input, request, FrameError, undecodable

### Community 167 - "HarnessCore: ACP / ACPSession"
Cohesion: 0.23
Nodes (9): AgentTableEntry, Bool, Set, String, WrapperOptionBehavior, keepScanning, matchValue, skipValue (+1 more)

### Community 170 - "Terminal Kit: HarnessTerminalKit / ThemeManager"
Cohesion: 0.25
Nodes (5): Bool, Range, String, URLDetection, StringProtocol

### Community 171 - "HarnessCore: Commands / TargetSpec"
Cohesion: 0.26
Nodes (5): Case, ReflowCorpusTests, String, TerminalEmulator, URL

### Community 173 - "HarnessCore: Shell / ShellIntegration"
Cohesion: 0.27
Nodes (5): SessionSnapshot, BoardCommandTests, BoardModelTests, SessionSnapshot, Tab

### Community 174 - "Harness CLI: HarnessCLI"
Cohesion: 0.27
Nodes (6): BinaryRefresher, Bool, URL, BinaryRefresherTests, String, URL

### Community 177 - "AIDLC: harness / acp / outputs / user-stories"
Cohesion: 0.23
Nodes (4): PaneRectSolverTests, Bool, PaneNode, PaneRect

### Community 178 - "Tests: HarnessCoreTests / SessionEditorPhase4Tests"
Cohesion: 0.16
Nodes (10): InlineAICompletionView, Bool, NSCoder, NSEvent, NSRect, NSTextField, String, TimeInterval (+2 more)

### Community 179 - "Onboarding: UI / WelcomeStepView"
Cohesion: 0.50
Nodes (4): [3.11.6] - 2026-06-29, Added, Documentation, Fixed

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
Cohesion: 0.31
Nodes (7): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL

### Community 185 - "Terminal Renderer: HarnessTerminalRenderer / TerminalFrame"
Cohesion: 0.07
Nodes (31): CodingKey, CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version (+23 more)

### Community 186 - "Tests: HarnessTerminalEngineTests / ReflowCorpusTests"
Cohesion: 0.33
Nodes (4): HarnessTerminalSurfaceView, NSImage, NSSize, String

### Community 187 - "Tests: HarnessTerminalEngineTests / ScrollbackTests"
Cohesion: 0.19
Nodes (8): AppDelegate, QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL, NSApplication, NSApplicationDelegate

### Community 188 - "Harness App: UI / ContentAreaViewController"
Cohesion: 0.12
Nodes (12): BrowserPaneView, BrowserProgressLine, NSKeyValueObservation, NSLayoutConstraint, NSStackView, NSTextField, Selector, String (+4 more)

### Community 189 - "Agent Memory: plans / p5-acp-implementation"
Cohesion: 0.12
Nodes (16): Architecture, Bounded Contexts, code:block1 (Agent Process (Claude Code / Codex / Gemini)), code:block2 (Packages/HarnessCore/Sources/HarnessCore/ACP/), code:block3 (Content-Length: 123\r\n), Estimate, Goal, Key Files (New) (+8 more)

### Community 191 - "AIDLC: harness / ide-file-tree / planning / 00-inception-plan"
Cohesion: 0.13
Nodes (6): ScriptRuntime, Any, String, JSContext, JSValue, ScriptingTests

### Community 192 - "Tests: HarnessTerminalEngineTests / HistoryRingBufferTests"
Cohesion: 0.18
Nodes (8): Bool, Data, Int32, String, TimeInterval, UInt64, UUID, Void

### Community 193 - "Terminal Renderer: HarnessTerminalRenderer / TerminalMetalRenderer"
Cohesion: 0.22
Nodes (4): HarnessCLI, Bool, String, UUID

### Community 194 - "Harness App: UI / HarnessDesign"
Cohesion: 0.11
Nodes (17): Agent Detection, Branch Detection Flow, Branch Label, Chrome Roles, Drag Reorder, File, Files, Git Branch Detection (+9 more)

### Community 195 - "Harness App: UI / HarnessDesign"
Cohesion: 0.17
Nodes (7): ResizeHUDView, DispatchWorkItem, NSCoder, NSColor, NSPoint, NSRect, TimeInterval

### Community 196 - "Harness App: UI / HarnessControls"
Cohesion: 0.43
Nodes (3): StageToggleButton, NSCoder, NSRect

### Community 197 - "HarnessCore: CLI / TerminalRecording"
Cohesion: 0.12
Nodes (12): AgentIconArt, AgentVectorIcon, Bool, CGSize, String, CoreGraphics, CoreText, ImageIO (+4 more)

### Community 198 - "Tests: HarnessCoreTests / SessionPersistenceTests"
Cohesion: 0.20
Nodes (9): Group, ParsedShortcut, PrefixCheatsheetWindow, PrefixIndicatorWindow, CGFloat, NSTextField, NSView, NSWindow (+1 more)

### Community 201 - "HarnessCore: Agents / AgentDetector"
Cohesion: 0.12
Nodes (16): Agent Config Wiring, Agents, Architecture, Browser Pane, File I/O, Git, Key Files, MCP Server (harness-mcp) (+8 more)

### Community 202 - "HarnessCore: Commands / CommandIPCTranslator"
Cohesion: 0.10
Nodes (22): CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, PaletteModel, PalettePanel (+14 more)

### Community 203 - "Docs: KEYBINDINGS"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Harness keybindings, Key spec syntax, Persistence (+1 more)

### Community 204 - "Docs: MIGRATION"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Harness the default terminal, Migrating to Harness

### Community 205 - "HarnessCore: ACP / ACPSession"
Cohesion: 0.13
Nodes (14): CopyModeMatch, CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeState (+6 more)

### Community 206 - "Tests: HarnessCoreTests / BinaryRefresherTests"
Cohesion: 0.17
Nodes (12): ConfigError, unsupportedAgent, writeFailure, MCPConfigWriter, Any, Bool, String, URL (+4 more)

### Community 207 - "HarnessCore: Paths / HarnessPaths"
Cohesion: 0.11
Nodes (9): HarnessTerminalSurfaceView, Bool, CAMetalDrawable, NSEvent, RGBColor, String, HarnessTerminalSurfaceView, CGFloat (+1 more)

### Community 208 - "Terminal Renderer: HarnessTerminalRenderer / CellColorResolver"
Cohesion: 0.17
Nodes (10): HarnessCLI, String, HarnessCLI, SessionGroup, SessionSnapshot, String, UUID, T (+2 more)

### Community 209 - "Terminal Engine: HarnessTerminalEngine / InputEncoder"
Cohesion: 0.26
Nodes (5): RemoteHost, SettingsRemoteView, Bool, RemoteHost, String

### Community 210 - "Tests: HarnessTerminalEngineTests / SemanticPromptTests"
Cohesion: 0.09
Nodes (18): PaneDragController, Any, Bool, NSEvent, NSView, NSWindow, PaneID, PaneDropZoneOverlay (+10 more)

### Community 211 - "HarnessCore: Format / FormatStyledSegment"
Cohesion: 0.11
Nodes (6): DaemonBrowserRoutingTests, String, URL, EndpointClientTests, String, URL

### Community 212 - "Tests: HarnessCoreTests / CommandIPCTranslatorTests"
Cohesion: 0.15
Nodes (7): Bool, TargetSpec, CommandIPCTranslatorTests, Bool, CommandTarget, PaneID, TabID

### Community 213 - "Tests: HarnessCoreTests / FormatStyledTests"
Cohesion: 0.07
Nodes (21): DispatchTimeInterval, RealPty, ScrollbackEntry, ScrollbackReplaySegment, Bool, CChar, DaemonSurfaceID, Data (+13 more)

### Community 214 - "HarnessCore: Notch / NotchLayoutMetrics"
Cohesion: 0.21
Nodes (8): NotchGeometry, NSScreen, NotchLayoutMetrics, NotchRect, NotchScreenMetrics, Bool, Double, NotchLayoutMetricsTests

### Community 215 - "Tests: HarnessOnboardingTests / ShellProfileInstallerTests"
Cohesion: 0.18
Nodes (7): MainMenuBuilder, Bool, NSMenu, NSMenuItem, Selector, String, Any

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
Cohesion: 0.30
Nodes (7): Bool, NSPasteboard, NSString, String, URL, TerminalServicesProvider, AutoreleasingUnsafeMutablePointer

### Community 222 - "Harness App: UI / NotificationBellButton"
Cohesion: 0.11
Nodes (16): AgentNotchDashboardProjection, AgentNotchProjection, AgentNotchRowSummary, RowKind, agent, session, Date, SessionGroup (+8 more)

### Community 223 - "AIDLC: harness / acp / outputs / domain-decomposition"
Cohesion: 0.17
Nodes (6): colors, ANSIPalette, RGBColor, UInt8, String, UInt8

### Community 224 - "Scripts: terminal_stress_runner.py"
Cohesion: 0.30
Nodes (8): ANSIPalette, CellColorResolver, ResolvedCellColors, Bool, Double, RGBColor, TerminalGridCell, TerminalGridColor

### Community 226 - "AIDLC: harness / ide-file-tree / planning / 00-inception-decisions"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 227 - "Harness CLI: HarnessCLI / RecordClient"
Cohesion: 0.09
Nodes (21): Process, Endpoint, tcp, unix, SSHTunnelError, exitedEarly, invalidConfiguration, launchFailed (+13 more)

### Community 229 - "Harness App: UI / SyntaxTextView"
Cohesion: 0.33
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 230 - "Tests: HarnessCoreTests / TabAlertTests"
Cohesion: 0.17
Nodes (4): HarnessGridTerminalTests, HarnessGridTerminal, String, TerminalGridSnapshot

### Community 231 - "Harness App: UI / HarnessSidebarPanelViewController"
Cohesion: 0.21
Nodes (8): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController

### Community 232 - "HarnessCore: Models / Workspace"
Cohesion: 0.11
Nodes (17): 1. Add a `pendingReflowTask` field to `TerminalScreen`, 2. Split `reflow(toCols:rows:)` into two helpers, 3. In `resize(cols:rows:)`, use the fast path first, Background, code:swift (// In TerminalScreen), code:swift (// Fast path — reflow only viewport + lookahead), code:swift (mutating func resize(cols nc: Int, rows nr: Int) {), code:swift (// TerminalEmulator: add a "live resize in progress" flag) (+9 more)

### Community 233 - "HarnessCore: Notifications / NotificationBus"
Cohesion: 0.23
Nodes (11): CellMetrics, CellMetrics, ComposedTerminalView, Bool, CellColorResolver, CGFloat, CGPoint, GraphicsContext (+3 more)

### Community 234 - "Harness App: Services / SessionCoordinator"
Cohesion: 0.29
Nodes (3): BellScanTests, Bool, UInt8

### Community 235 - "Terminal Kit: HarnessTerminalKit / TerminalHostView"
Cohesion: 0.12
Nodes (16): String, WorkbenchCommand, ack, agent, attention, board, cd, copyPath (+8 more)

### Community 237 - "HarnessCore: Settings / DefaultTerminalLaunchRequest"
Cohesion: 0.25
Nodes (8): CopyModeSideEffect, beginSearchEntry, cancel, copy, copyAndCancel, none, paste, pipe

### Community 238 - "Tests: HarnessCoreTests / TerminalBannerTests"
Cohesion: 0.18
Nodes (6): DefaultTerminalLaunchRequest, ShellQuoting, Bool, String, URL, DefaultTerminalLaunchRequestTests

### Community 239 - "Harness App: UI / HarnessSidebarPanelViewController"
Cohesion: 0.09
Nodes (42): MTLClearColor, MTLCommandBuffer, MTLCommandQueue, MTLLibrary, MTLPixelFormat, MTLRenderCommandEncoder, MTLRenderPipelineState, MTLSamplerState (+34 more)

### Community 240 - "Tests: HarnessOnboardingTests / BinaryInstallerVersionTests"
Cohesion: 0.17
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, Bool, Double (+3 more)

### Community 242 - "HarnessCore: Metadata / MetadataProvider"
Cohesion: 0.40
Nodes (3): HarnessGridTerminal, TerminalGridCell, TerminalEmulator

### Community 244 - "Onboarding: Design / GlassEffectView"
Cohesion: 0.14
Nodes (8): BranchSwitchHelper, FileTreeNode, FileTreeSwiftUIView, Notification.Name, Bool, NSMenuItem, SessionID, Void

### Community 245 - "Onboarding: UI / SetupStepView"
Cohesion: 0.27
Nodes (3): Configuration, Data, UInt8

### Community 246 - "Docs: MODES"
Cohesion: 0.29
Nodes (7): 1. Plain Terminal, 2. Persistent Terminal, 3. Full Terminal, 4. Agent Workspace, Experience modes, Opting into the prefix + status line without switching modes, Persistence (ephemeral vs. persistent)

### Community 247 - "Harness App: UI / MainSplitViewController"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 248 - "Tests: HarnessCoreTests / SnapshotQueryFormatterTests"
Cohesion: 0.16
Nodes (7): DaemonMetrics, Snapshot, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 249 - "Tests: HarnessTerminalEngineTests / ReflowPreviewTests"
Cohesion: 0.36
Nodes (3): ReflowPreviewTests, String, TerminalEmulator

### Community 250 - "Tests: HarnessTerminalKitTests / HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.38
Nodes (3): HarnessTerminalSurfaceWorkerTests, Bool, HarnessTerminalSurfaceView

### Community 251 - "Tests: HarnessCoreTests / TerminalConfigImporterTests"
Cohesion: 0.25
Nodes (5): SessionCoordinator, Bool, String, SurfaceID, TimeInterval

### Community 254 - "HarnessCore: Paths / ShellCompletionInstaller"
Cohesion: 0.11
Nodes (10): BoardCardView, BoardViewController, FlippedView, Bool, NSCoder, Set, TabID, Void (+2 more)

### Community 255 - "Scripts: release-hotfix.sh"
Cohesion: 0.42
Nodes (7): plist_set(), require_clean_tracked_worktree(), run(), release-hotfix.sh script, update_readme_download(), usage(), write_release_notes()

### Community 256 - "Harness App: Services / SessionCoordinator"
Cohesion: 0.25
Nodes (5): CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab

### Community 257 - "Harness App: Services / SurfaceProgressTracker"
Cohesion: 0.13
Nodes (14): 1. @MainActor + Task + Process.waitUntilExit = FREEZE (RL-052), 2. @Observable + mutation in body = infinite re-render loop (RL-053), 3. Re-entrancy guard on rebuildRows, 4. Worktree display rules, Architecture, chromeEpoch — force SwiftUI re-render from static state, Critical Lessons (bugs fixed), File tree: root at git root, expand on CWD change (+6 more)

### Community 258 - "Harness App: UI / HarnessChrome"
Cohesion: 0.11
Nodes (9): CGFloat, Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint, NSRect (+1 more)

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
Cohesion: 0.18
Nodes (11): InstallError, daemonNotFound, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, Bool, Int32 (+3 more)

### Community 263 - "Harness App: UI / FileViewerViewController"
Cohesion: 0.11
Nodes (11): HarnessSidebarPanelViewController, CGFloat, NSMenuItem, NSView, SessionGroup, String, HarnessSidebarPanelViewController, NSMenu (+3 more)

### Community 266 - "Tests: HarnessCopyModeTests / WordColumnRangeTests"
Cohesion: 0.23
Nodes (8): Scanner, SVGPathParser, Bool, CGPath, CGPoint, Character, Set, CGMutablePath

### Community 267 - "Onboarding: UI / ShellStepView"
Cohesion: 0.06
Nodes (35): BinaryInstaller, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, found, notFound (+27 more)

### Community 269 - "Terminal Kit: HarnessTerminalKit / FrameSignposter"
Cohesion: 0.20
Nodes (11): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, failed, DefaultTerminalStatus, Bool, String, URL (+3 more)

### Community 270 - "Tests: HarnessCoreTests / CompletionGeneratorTests"
Cohesion: 0.07
Nodes (26): GridCompositor, PaneBorderStatus, Bool, Command, CommandTarget, DispatchSourceSignal, DispatchWorkItem, HarnessGridTerminal (+18 more)

### Community 271 - "Tests: HarnessCoreTests / DefaultTerminalLaunchRequestTests"
Cohesion: 0.15
Nodes (12): CAMediaTimingFunction, NSAppearance, NSWindowController, HarnessOnboarding, Bool, ImmersiveOnboardingWindowController, ImmersivePanel, ImmersiveRootView (+4 more)

### Community 272 - "Tests: HarnessCoreTests / SGRMouseTests"
Cohesion: 0.10
Nodes (13): SGRMouse, SGRMouseEvent, Bool, PaneRect, S, UInt8, MouseEventKind, drag (+5 more)

### Community 273 - "Tests: HarnessCoreTests / ShellCompletionInstallerTests"
Cohesion: 0.06
Nodes (35): ScriptAPI, KeybindingsService, Bool, Command, String, OptionSet, KeySpec, Modifiers (+27 more)

### Community 274 - "Theme: HarnessTheme / ThemeFileService"
Cohesion: 0.40
Nodes (5): [2.5.0] - 2026-06-12, Added, Changed, Documentation, Fixed

### Community 275 - "AIDLC: harness / ide-file-tree / PROGRESS.md / PROGRESS"
Cohesion: 0.13
Nodes (15): Context, Non-goals, P8: macOS 27 Golden Gate Adoption, Phase 0 — Swift 6.3+ Concurrency Safety (P0, LESSONS FROM macOS 26.5 CRASH SAGA), Phase 1 — Compatibility (P0), Phase 2 — Quick Wins (P1), Phase 3 — NSTextSelectionManager (P1), Phase 4 — Gesture Recognizer Migration (P2) (+7 more)

### Community 276 - "HarnessCore: Platform / PlatformSys"
Cohesion: 0.11
Nodes (13): Notification.Name, Bool, NSCoder, NSEvent, NSRange, NSRect, NSString, NSTextView (+5 more)

### Community 277 - "Terminal Kit: HarnessTerminalKit / HarnessTerminalSurfaceView"
Cohesion: 0.20
Nodes (11): ControlModeClient, ControlModeError, daemon, noMatch, noSnapshot, unresolved, Command, Data (+3 more)

### Community 278 - "Harness App: UI / ContentAreaViewController"
Cohesion: 0.17
Nodes (12): BlockActionBar, BlockTintOverlay, Bool, CGFloat, HarnessTerminalSurfaceView, NSButton, NSCoder, NSEvent (+4 more)

### Community 279 - "HarnessCore: Models / PaneNode"
Cohesion: 0.31
Nodes (6): DisplayPanesOverlay, Any, NSEvent, NSView, SurfaceID, Void

### Community 280 - "Terminal Engine: Images / DecodedImage"
Cohesion: 0.16
Nodes (8): MainWindowController, NSRect, CGFloat, NSColor, NSPoint, NSRect, NSWindow, WindowBorderOverlayView

### Community 281 - "Terminal Kit: HarnessTerminalKit / TerminalScrollbarView"
Cohesion: 0.19
Nodes (8): Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSRect, TimeInterval, TerminalScrollbarView

### Community 283 - "Harness CLI: HarnessCLI / WindowAttachClient"
Cohesion: 0.40
Nodes (5): [3.1.0] - 2026-06-15, Added, Changed, Documentation, Fixed

### Community 285 - "LSP: HarnessLSP / LSPTransport"
Cohesion: 0.08
Nodes (24): After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md., After all done — update memory, Agent Prompt — P14 Browser Pane (PBI-001 through 005), Before writing any code, read:, code:swift (public struct BrowserLeaf: Codable, Sendable, Equatable {), code:swift (case let .browser(bl):), code:swift (// action: SplitPaneCoordinator openBrowserPane(url: URL(str), code:block4 (harnessBrowserOpen(url, direction?) → {paneId}) (+16 more)

### Community 288 - "HarnessCore: Agents / AgentHookStrategy"
Cohesion: 0.25
Nodes (7): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, ownJSONFile, ownTextFile, regionEdit, String

### Community 289 - "HarnessCore: CLI / CompletionGenerator"
Cohesion: 0.28
Nodes (4): StatusLineWidthTests, StatusLineWidth, String, StyledSegment

### Community 291 - "Tests: HarnessDaemonTests / BellScanTests"
Cohesion: 0.06
Nodes (10): HarnessCommands, HarnessSettings, JSONDecoder, JSONEncoder, TerminalRecordingCodec, DaemonStatsTests, ExperienceModeTests, Tab (+2 more)

### Community 292 - "Docs: RELEASE"
Cohesion: 0.33
Nodes (5): Local release path, One-time GitHub setup, Release runbook, Running a release from GitHub, What the workflow publishes

### Community 293 - "Harness App: UI / FileEditorView"
Cohesion: 0.14
Nodes (13): 1. Data / Geometry Separation (primary fix), 2. SnapshotCoalescer (cmux NotificationBurstCoalescer pattern), 3. Equality Guard on updateGeometry (Zed pattern), 4. Dirty Flag on setFrame (Otty/WezTerm pattern), 5. GPU Animation — CAShapeLayer Mask (Zed/Otty GPU path), 6. AgentScanner timer split, Files, Fixes Applied (layered) (+5 more)

### Community 294 - "Terminal Engine: Width / CharacterWidth"
Cohesion: 0.10
Nodes (22): PRStatusPoller, Bool, DispatchSourceTimer, SessionID, Set, String, TimeInterval, Void (+14 more)

### Community 295 - "Harness CLI: HarnessCLI / WindowAttachClient"
Cohesion: 0.07
Nodes (24): SnapshotCoalescer, MainActor, Void, RowState, Bool, AgentApprovalBar, ApprovalBarAction, hide (+16 more)

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
Cohesion: 0.13
Nodes (17): PaneBorderStatus, bottom, off, top, PaneLeaf, PaneNode, branch, leaf (+9 more)

### Community 300 - "Tests: HarnessTerminalKitTests / HarnessTerminalSurfaceDragDropTests"
Cohesion: 0.12
Nodes (23): CustomStringConvertible, Error, DaemonClientError, connectionFailed, timeout, unexpectedResponse, writeFailed, atomicWrite() (+15 more)

### Community 301 - "HarnessCore: Agents / HookNotificationParser"
Cohesion: 0.20
Nodes (8): HookNotificationParser, Parsed, Any, Data, String, HookNotificationParserTests, Data, String

### Community 302 - "AIDLC: harness / acp / outputs / brainstorming-summary"
Cohesion: 0.26
Nodes (4): RGBColor, String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 305 - "Harness App: Services / CLIInstaller"
Cohesion: 0.05
Nodes (23): CFString, NSCursor, StaticString, T, HarnessTerminalSurfaceView, CADisplayLink, Data, DispatchWorkItem (+15 more)

### Community 306 - "Harness App: UI / HarnessSidebarPanelViewController"
Cohesion: 0.18
Nodes (4): String, RegressionBugFixTests, SessionSnapshot, Tab

### Community 308 - "Release Notes: CHANGELOG"
Cohesion: 0.17
Nodes (9): Logger, os, OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, Bool (+1 more)

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
Cohesion: 0.15
Nodes (3): AgentTitleInference, Bool, AgentDetectorTests

### Community 313 - "Terminal Renderer: HarnessTerminalRenderer / RenderColorConversion"
Cohesion: 0.17
Nodes (11): ACP vs MCP vs Terminal Chat, AgentProcessManager, Architecture, CLI Print-Mode Args, Context Injection, Key Files, Key Shortcuts (I-family), Non-Obvious Constraints (+3 more)

### Community 317 - "Agent Memory: Agent Memory / memory"
Cohesion: 0.11
Nodes (17): Task Ledger Archive (Tasks 1–50), 2026-06-25 — OSC 7735:  opens sidebar file viewer, 2026-06-27 — Block output tint + AI explain (Phase 12b), Active Context, Active Decisions, Architecture Notes, Completed Sprints, Conventions (+9 more)

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
Cohesion: 0.14
Nodes (9): copyMode, fs, globalShortcuts, KEYBINDINGS, prefixTable, ROOT, shellTools, USAGE (+1 more)

### Community 324 - "HarnessCore: CLI / TerminalRecording"
Cohesion: 0.27
Nodes (7): Never, Set, String, Task, URL, Void, WorkspaceSymbolIndex

### Community 325 - "Harness CLI: HarnessCLI"
Cohesion: 0.21
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 326 - "Tests: HarnessDaemonTests / ShellLaunchProfileTests"
Cohesion: 0.24
Nodes (6): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 327 - "Tests: HarnessTerminalEngineTests / CharacterWidthTests"
Cohesion: 0.12
Nodes (4): HarnessThemeCatalog, String, ANSIPaletteTests, HarnessThemeCatalogTests

### Community 328 - "Tests: HarnessTerminalRendererTests / ThaiClusterRenderTests"
Cohesion: 0.23
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 329 - "Onboarding: Design / ImmersivePalette"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 330 - "Harness CLI: HarnessCLI / ReplayClient"
Cohesion: 0.30
Nodes (7): SurfaceProgressTracker, Bool, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void

### Community 331 - "Harness App: UI / WindowTitleStripView"
Cohesion: 0.16
Nodes (17): BoardCard, BoardColumn, BoardColumnKind, done, error, idle, needsAttention, running (+9 more)

### Community 333 - "Agent Memory: plans / completed-archive"
Cohesion: 0.50
Nodes (4): [2.0.0] - 2026-06-07, Added, Documentation, Fixed

### Community 334 - "Harness App: UI / HarnessSidebarPanelViewController"
Cohesion: 0.28
Nodes (6): Typography, SidebarBadgeView, NSCoder, NSRect, NSFont, NSPressGestureRecognizer

### Community 336 - "Scripts: run.sh"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 337 - "Harness App: UI / SyntaxTextView"
Cohesion: 0.22
Nodes (8): AnyObject, CommandExecutionError, daemonError, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor, String

### Community 338 - "Harness App: UI / HarnessControls"
Cohesion: 0.28
Nodes (3): CSIParams, TerminalGridColor, UInt8

### Community 339 - "Harness App: UI / HarnessControls"
Cohesion: 0.06
Nodes (12): AppKit, Notification.Name, Carbon, Combine, HarnessTerminalKit, HarnessTerminalRenderer, HarnessTheme, Metal (+4 more)

### Community 343 - "Harness App: AppIcon.appiconset / Contents"
Cohesion: 0.50
Nodes (4): [2.2.3] - 2026-06-09, Added, Documentation, Fixed

### Community 344 - "Release Notes: CHANGELOG"
Cohesion: 0.19
Nodes (7): FileViewerViewController, Bool, NSEvent, Set, String, URL, Void

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
Cohesion: 0.17
Nodes (5): HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 357 - "Theme: HarnessTheme / HarnessThemeCatalog"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 358 - "HarnessCore: Keybindings / ShortcutRecorderSerializer"
Cohesion: 0.50
Nodes (4): [3.5.1] - 2026-06-20, Added, Documentation, Fixed

### Community 359 - "Scripts: generate-release-notes"
Cohesion: 0.36
Nodes (5): OcclusionTests, HarnessTerminalSurfaceView, NSWindow, String, TimeInterval

### Community 360 - "LSP: HarnessLSP / LSPServerRegistry"
Cohesion: 0.28
Nodes (4): BrowserTab, UUID, WKWebView, tabs

### Community 362 - "Harness App: UI / HarnessDesign"
Cohesion: 0.24
Nodes (7): RGBColor, Bool, Decoder, Double, Encoder, String, UInt8

### Community 363 - "AIDLC: harness / acp / PROGRESS.md / PROGRESS"
Cohesion: 0.23
Nodes (8): LSPFileSession, Never, String, Task, URL, Void, URL, SyntaxDefinitionTarget

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
Cohesion: 0.27
Nodes (8): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID

### Community 368 - "Claude Instructions: CLAUDE"
Cohesion: 0.27
Nodes (9): Array, Bool, Date, Decoder, PaneID, PaneNode, String, TabID (+1 more)

### Community 369 - "HarnessCore: Keybindings / KeybindingsStore"
Cohesion: 0.20
Nodes (9): Architecture, Branch chip — CASE-020, Features, FSEvents Pattern (Swift Actor), Git Panel, History → File Editor, Real-time Refresh, v1 — CASE-009 (resolved, superseded) (+1 more)

### Community 370 - "HarnessCore: Paths / BinaryRefresher"
Cohesion: 0.17
Nodes (3): InputEncoderTests, String, UInt8

### Community 371 - "Harness App: UI / LSPFileSession"
Cohesion: 0.17
Nodes (11): Architecture, code:block1 (PaneNode (existing binary tree)), Current State, Estimate, Goal, P13 — Embedded Browser Pane (cmux parity), PBI-BROWSER-001: BrowserPaneView + PaneNode integration, PBI-BROWSER-002: Persistence (+3 more)

### Community 372 - "HarnessCore: Settings / JSONMerge"
Cohesion: 0.23
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 373 - "Tests: HarnessCoreTests / KeybindingsStoreTests"
Cohesion: 0.21
Nodes (12): code:block1 (Add a visual session state indicator to sidebar session card), code:block2 (Add keyboard-driven layout presets to the Harness terminal a), code:block3 (Add workspace-scoped local completion (autocomplete) to the ), code:block4, Context, P10 Implementation Prompts — For Agent Execution, Prompt, Task #1: CMUX Session State Indicator in Sidebar (+4 more)

### Community 374 - "Terminal Engine: Images / SixelDecoder"
Cohesion: 0.24
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 375 - "Harness App: Services / SparkleUpdater"
Cohesion: 0.36
Nodes (4): CLIInstaller, Bool, String, URL

### Community 376 - "Onboarding: Design / WindowBlur"
Cohesion: 0.47
Nodes (3): ScrollReuseTests, HarnessTerminalSurfaceView, NSWindow

### Community 377 - "Community 377"
Cohesion: 0.10
Nodes (13): CompleteStepView, Void, OnboardingStep, complete, discover, setup, shell, welcome (+5 more)

### Community 378 - "HarnessCore: Format / JSONOutputFormatter"
Cohesion: 0.33
Nodes (5): Counter, Scheduled, SurfaceProgressTrackerTests, DispatchWorkItem, TimeInterval

### Community 379 - "Onboarding: Install / HarnessCLIPaths"
Cohesion: 0.19
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

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
Cohesion: 0.05
Nodes (8): CHarnessSys, Darwin, Foundation, Glibc, HarnessIPC, JavaScriptCore, JSONOutputFormatter, HarnessVersion

### Community 389 - "Terminal Engine: Width / CharacterWidthTable"
Cohesion: 0.05
Nodes (13): HarnessCLITests, Set, String, URL, HarnessCLI, HarnessFilePreviewLoader, HarnessViewError, binaryOrUnsupportedEncoding (+5 more)

### Community 390 - "Terminal Renderer: HarnessTerminalRenderer / MetalShaders"
Cohesion: 0.22
Nodes (8): Accessibility Requirements, Files, Permission, Running, Stack, Test Strategy, UI Automation — Robot Framework (P18), Why Not Appium

### Community 391 - "Theme: HarnessTheme / BundledThemesData"
Cohesion: 0.22
Nodes (8): AppKit + Metal Patterns, CADisplayLink Lifetime on macOS (CASE-031), Metal Surface Lifecycle (CASE-003), Mouse Selection Must Use Virtual-Line Coordinates (CASE-029), NSFont Italic (CASE-010), NSView Layer Opacity — Preview Parity Pattern (CASE-011), Overlay Above Metal (CASE-004), Window Background Tint for Legibility (CASE-027)

### Community 402 - "Package.Swift: Package"
Cohesion: 0.09
Nodes (29): Color, MonoPillButtonStyle, Configuration, Configuration, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, ButtonStyle, CommandRow (+21 more)

### Community 404 - "HarnessCore: Models / Identifiers"
Cohesion: 0.22
Nodes (8): Architecture, Infinite Recursion (CASE-006), Pane Drag-and-Drop (P27), Ratio Persistence (CASE-002), Split CWD Resolution — Worktree Priority (2026-06-21), Split Panes (NSSplitView), Subview Reorder (CASE-007), Two-Axis Split Parity (P13)

### Community 408 - "Community 408"
Cohesion: 0.25
Nodes (7): Framing, IPC Architecture, Key Invariant, Overview, Process Separation, Security, Subscriptions

### Community 409 - "Tests: HarnessCLITests"
Cohesion: 0.25
Nodes (7): ⌘1-9 and ⌘[ / ⌘] = Session-level navigation (CASE-028), Data Model, Session/Tab/Pane Hierarchy & Top Bar (CASE-028), Sidebar Session Groups = One Header Per SessionGroup, Source Map, Tab Pill Visual Details, Top Bar = 1 Pill Per Session (not per-tab)

### Community 411 - "HarnessCore: Shell / ShellRCWiring"
Cohesion: 0.10
Nodes (19): Agent Prompt — Harness Terminal UI Fixes, code:block1 (▶ harness-terminal), code:block2 (▼ harness-terminal  ● Running), code:swift (urlTextField.setContentHuggingPriority(.defaultLow, for: .ho), code:swift (let bv = BrowserPaneView(url: bl.url, paneID: bl.id)), code:bash (cd /Users/supavit.cho/Git/Personal/harness-terminal), code:bash (git add -A), Commit (+11 more)

### Community 421 - "Community 421"
Cohesion: 0.22
Nodes (8): LayoutFileStore, LayoutNode, branch, leaf, LayoutTemplate, Date, PaneNode, String

### Community 422 - "Harness App: UI / HarnessDesign"
Cohesion: 0.27
Nodes (6): HintModeOverlay, Any, HarnessTerminalSurfaceView, NSEvent, NSView, String

### Community 423 - "HarnessCore: ACP / ACPClient"
Cohesion: 0.32
Nodes (4): CopyModeLine, Character, ClosedRange, String

### Community 424 - "Harness App: UI / ContentAreaViewController"
Cohesion: 0.04
Nodes (6): HarnessApp, HarnessCLI, HarnessCore, HarnessDaemonCore, HarnessMCP, XCTest

### Community 425 - "Community 425"
Cohesion: 0.55
Nodes (5): AgentIconRenderer, CGFloat, NSColor, NSImage, String

### Community 426 - "Daemon: HarnessDaemon / DaemonLifecycle"
Cohesion: 0.25
Nodes (7): Bug — Cmd+\ sidebar toggle gone after collapse, Confirmed facts, Fix, Related, Suspect A — Dead token guard (confirmed code bug), Suspect B — Zero-delta early exit trap, Symptom

### Community 427 - "Community 427"
Cohesion: 0.27
Nodes (3): DaemonReconnectPolicy, TimeInterval, DaemonReconnectPolicyTests

### Community 428 - "Terminal Renderer: HarnessTerminalRenderer / TerminalMetalRenderer"
Cohesion: 0.18
Nodes (10): 1. HarnessTerminalSurfaceView (~2,320 LOC), 2. HarnessCLI.swift (~1,841 LOC), 3. WindowAttachClient (~1,566 LOC), 4. SurfaceRegistry (~1,848 LOC), 5. GridCompositor Duplication, Context, Execution Order, Execution Status (2026-06-11) (+2 more)

### Community 429 - "Harness App: UI / SearchPanelView"
Cohesion: 0.25
Nodes (7): Case: cwd "bleed" — session worktree jumps to wrong dir during builds, Companion bug: blank panel on first open (CASE-042), Fix, Lesson, Repro (deterministic, headless — no GUI needed), Root cause, Symptom

### Community 430 - "HarnessCore: Session / SessionEditor"
Cohesion: 0.25
Nodes (7): Competitive Position (as of v3.6.1, June 2026), Feature Matrix (June 2026), Harness Gaps, Harness Wins, Known Limitations (honest assessment), Positioning Statement, Unique Selling Points (no competitor has all)

### Community 431 - "Agent Memory: plans / p6-editor-opacity-parity"
Cohesion: 0.22
Nodes (8): Actual Fix (2026-06-09), code:swift (panel.layer?.backgroundColor = c.terminalBackground), code:swift (private func refreshEditorPanelFill() {), Fix Approach, P6: File Editor Opacity Parity with Terminal, Problem, Root Cause (hypothesis), Status

### Community 432 - "Harness App: UI / HarnessDesign"
Cohesion: 0.21
Nodes (4): CopyModeReducerTests, FakeGrid, String, TerminalGridCell

### Community 433 - "Community 433"
Cohesion: 0.24
Nodes (7): LaunchdServiceInstaller, ServiceInstaller, ServiceInstallers, ServiceInstallReport, Bool, String, URL

### Community 434 - "Tests: HarnessThemeTests / ThemeCatalogEmbedTests"
Cohesion: 0.25
Nodes (7): Apple Platform Context — Transparency & Legibility, Architecture Decisions, iOS/macOS 26 — Liquid Glass introduction, iOS/macOS 27 — Liquid Glass refinements (WWDC 2026), Known Issues (Current), Project History, Sprint Timeline

### Community 435 - "Community 435"
Cohesion: 0.29
Nodes (4): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests

### Community 436 - "Tests: HarnessCoreTests / GroupedSessionTests"
Cohesion: 0.19
Nodes (7): ignoreSIGPIPE(), Channel, Bool, Int32, String, WaitForRegistry, WaitForRegistryTests

### Community 437 - "Harness App: UI / HarnessSidebarPanelViewController"
Cohesion: 0.25
Nodes (8): F1: Mobile Package Targets — P0, F2: Network Endpoint for IPC — P0, F3: Pairing and Trust — P0, F4: UIKit Terminal Surface — P0, F5: iPad Workspace UX — P1, F6: Remote Session Lifecycle — P1, F7: Files and Sharing — P2, Feature Specs

### Community 438 - "Onboarding: UI / OnboardingWizardView"
Cohesion: 0.08
Nodes (11): SessionEditor, Bool, Date, SessionID, SessionSnapshot, String, SurfaceID, TabID (+3 more)

### Community 439 - "Agent Memory: knowledge / acp-client"
Cohesion: 0.29
Nodes (7): ACP Client, Architecture, code:block1 (AgentChatPanelView (AppKit UI)), Key Files, Protocol, Shelved Status (June 2025), Tool Call Handling

### Community 440 - "Harness App: UI / CommandPaletteController"
Cohesion: 0.25
Nodes (8): Implementation Phases, Phase 0 — Feasibility Spike (P0), Phase 1 — Shared Renderer Extraction (P0), Phase 2 — Mobile IPC Transport (P0), Phase 3 — UIKit Terminal MVP (P0), Phase 4 — iPad App Shell (P1), Phase 5 — Multiplexer Parity (P1), Phase 6 — Polish and Platform Integration (P2)

### Community 441 - "Community 441"
Cohesion: 0.10
Nodes (12): RemoteHostsService, RemoteHost, String, MutationResult, RemoteHost, RemoteHostStore, Bool, String (+4 more)

### Community 443 - "Community 443"
Cohesion: 0.20
Nodes (7): BrowserPaneViewTests, MockWebView, Bool, URL, WKNavigation, WKWebView, WKWebViewConfiguration

### Community 444 - "Community 444"
Cohesion: 0.19
Nodes (9): BellScanState, esc, normal, string, stringEsc, PanePipe, SurfaceMonitor, Data (+1 more)

### Community 445 - "Community 445"
Cohesion: 0.13
Nodes (14): PaletteMode, errors, grep, normal, Section, actions, errors, files (+6 more)

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
Cohesion: 0.17
Nodes (9): ComposerPanel, Bool, NSEvent, NSTextView, NSWindow, Selector, String, Void (+1 more)

### Community 457 - "Community 457"
Cohesion: 0.11
Nodes (14): Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow, launchStart, StartupMetrics (+6 more)

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
Cohesion: 0.09
Nodes (14): RecordingEvent, input, metadata, output, resize, ReplayStep, Bool, Data (+6 more)

### Community 466 - "Community 466"
Cohesion: 0.47
Nodes (3): ReflowFastPathTests, String, TerminalEmulator

### Community 467 - "Community 467"
Cohesion: 0.12
Nodes (15): ─────────────────────────────────────────────────────, Agent Prompt — P14 PBI-BROWSER-001 + 002, BrowserPaneView shell + PaneNode integration, code:swift (public struct BrowserLeaf: Codable, Sendable, Equatable {), code:swift (case let .browser(browserLeaf):), code:block3 (feat(p14): PBI-BROWSER-001/002 — BrowserPaneView + PaneNode ), Constraints, ContentAreaViewController.swift — PaneContainerView.build() (+7 more)

### Community 473 - "Tests: GridCompositorParityTests / LiveCompositorFixture"
Cohesion: 0.11
Nodes (10): HarnessOnboarding, GridCompositorParityTests, LiveCompositorFixture, Bool, String, TerminalGridSnapshot, PortCompositorFixture, Bool (+2 more)

### Community 476 - "Community 476"
Cohesion: 0.42
Nodes (3): BrowserIntegrationController, NSView, PaneID

### Community 479 - "Community 479"
Cohesion: 0.18
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
Cohesion: 0.24
Nodes (4): GroupedSessionTests, SessionGroup, Set, SurfaceID

### Community 496 - "Tests: GridCompositorParityTests / CompositorFixtureSpec"
Cohesion: 0.29
Nodes (6): Architecture / Keybindings, CASE — Git / FS / Terminal / Architecture, Claude Code / Tooling / Environment (the agent running *inside* Harness), Command Prompt / Parser, Git / File System, Terminal / Renderer / Daemon

### Community 498 - "Community 498"
Cohesion: 0.21
Nodes (6): Bool, Int32, String, URL, SystemdUserInstaller, ServiceInstallerTests

### Community 502 - "Community 502"
Cohesion: 0.29
Nodes (6): ACP Client (Shelved), Architecture (Preserved), Re-enablement Criteria, Status: SHELVED (June 2026), What It Is, Why Shelved

### Community 503 - "Scripts: generate-width-table"
Cohesion: 0.29
Nodes (6): Build Scripts Self-Kill Protection, Detection, Fix (applied in `Scripts/run.sh`), Key Invariant, Problem, Related

### Community 506 - "Community 506"
Cohesion: 0.23
Nodes (10): AgentRow, HookState, failed, idle, installed, installing, SettingsAgentsView, Bool (+2 more)

### Community 507 - "Community 507"
Cohesion: 0.27
Nodes (6): PluginLoader, String, ScriptError, evaluationError, unsupportedPlatform, URL

### Community 509 - "Community 509"
Cohesion: 0.70
Nodes (4): main(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 510 - "Community 510"
Cohesion: 0.27
Nodes (3): ShortcutRecorderSerializer, String, ShortcutRecorderSerializerTests

### Community 511 - "Community 511"
Cohesion: 0.29
Nodes (4): SessionStore, DispatchWorkItem, SessionSnapshot, TimeInterval

### Community 512 - "Harness App: UI / OnboardingController"
Cohesion: 0.12
Nodes (17): [1.0.0] - [1.0.4] - 2026-06-01, [1.0.0] - 2026-05-31, [2.2.0] - 2026-06-07, [2.2.2] - 2026-06-08, [2.5.2] - 2026-06-12, [3.2.1] - 2026-06-16, [3.7.0] - 2026-06-21, [3.9.2] - 2026-06-22 (+9 more)

### Community 513 - "Community 513"
Cohesion: 0.08
Nodes (30): Equatable, HarnessThemeDefinition, Bool, RGBColor, String, Appearance, AppearanceKind, dark (+22 more)

### Community 518 - "Harness CLI: HarnessCLI"
Cohesion: 0.17
Nodes (10): HarnessDaemonTools, PaneOutputWaiter, PaneOutputWaitResult, Bool, CheckedContinuation, Never, PaneLeaf, String (+2 more)

### Community 521 - "Community 521"
Cohesion: 0.22
Nodes (7): PasteController, Bool, Data, NSPasteboard, String, TimeInterval, URL

### Community 522 - "Community 522"
Cohesion: 0.33
Nodes (4): ImageTextureCache, MTLDevice, MTLTexture, UInt8

### Community 526 - "Community 526"
Cohesion: 0.10
Nodes (9): IPCCodecInvariantTests, ScrollbackPersistenceTests, String, URL, ClipboardOSCTests, String, TerminalGridCellLayoutTests, HarnessTerminalSurfaceFocusTests (+1 more)

### Community 527 - "Community 527"
Cohesion: 0.29
Nodes (7): Agent hooks for Harness, CLI notification, Example Claude Code hook, Jump to waiting agent, OSC sequences (from terminal output), Per-agent guides, Set up via your IDE (copy/paste prompt)

### Community 530 - "Release Notes: CHANGELOG"
Cohesion: 0.44
Nodes (6): HarnessChrome, HarnessChromePalette, Bool, CGFloat, NSColor, String

### Community 531 - "Release Notes: CHANGELOG"
Cohesion: 0.06
Nodes (20): DECSpecialGraphics, CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16, UInt8 (+12 more)

### Community 534 - "Release Notes: CHANGELOG"
Cohesion: 0.27
Nodes (5): BrowserPaneRegistry, NSWindow, PaneID, WeakBrowserPaneView, WebKit

### Community 535 - "Community 535"
Cohesion: 0.29
Nodes (7): AgentNotification, OSCNotificationParser, DaemonSurfaceID, Data, Date, String, SurfaceID

### Community 537 - "Release Notes: CHANGELOG"
Cohesion: 0.30
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 538 - "Community 538"
Cohesion: 0.08
Nodes (18): MainActor, Void, RepoGitMetadata, SessionDividerRowView, SessionGroupHeaderRowView, SessionWorktreeHeaderRowView, SessionWorktreeRowView, BoardColumnKind (+10 more)

### Community 544 - "Community 544"
Cohesion: 0.20
Nodes (3): Bool, Double, NSEvent

### Community 546 - "Community 546"
Cohesion: 0.36
Nodes (7): LegacySnapshot, LegacyWorkspace, Bool, Date, String, TabID, WorkspaceID

### Community 547 - "Community 547"
Cohesion: 0.11
Nodes (21): SplitChromeDelegate, center, ClosureTarget, MenuActionTarget, OverlayWindow, Phase67UI, PopupWindow, Bool (+13 more)

### Community 548 - "Community 548"
Cohesion: 0.26
Nodes (6): KeyTokenParser, Bool, Data, String, KeyTokenParserTests, Phase6KeysTests

### Community 550 - "Community 550"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 551 - "Community 551"
Cohesion: 0.19
Nodes (5): DesktopNotifier, HarnessPathDisplay, Bool, MainActor, String

### Community 552 - "Community 552"
Cohesion: 0.50
Nodes (4): WriteOutcome, complete, failed, wouldBlock

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
Cohesion: 0.07
Nodes (27): clamp(), DotView, statusColor(), statusHelp(), Bool, CGFloat, Context, Date (+19 more)

### Community 570 - "Community 570"
Cohesion: 0.09
Nodes (20): CommandHistorySearchController, HistoryItemView, HistoryRowView, SearchPanel, Bool, CGFloat, NSAttributedString, NSCoder (+12 more)

### Community 578 - "Community 578"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 579 - "Community 579"
Cohesion: 0.29
Nodes (6): AppKit / Views, Architecture / Daemon, Browser / WKWebView, Git / Process, RL Lessons — harness-terminal, Swift 6 / Concurrency

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
Cohesion: 0.29
Nodes (7): DiagnosticCheck, DiagnosticStatus, fail, pass, warn, DoctorReport, Int32

### Community 587 - "Community 587"
Cohesion: 0.20
Nodes (6): LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled

### Community 589 - "Community 589"
Cohesion: 0.13
Nodes (11): DaemonSessionError, daemonError, unexpectedResponse, DaemonSessionService, LatencyMonitor, Bool, SessionSnapshot, String (+3 more)

### Community 591 - "Community 591"
Cohesion: 0.21
Nodes (9): GitStatusType, added, deleted, modified, renamed, unmodified, untracked, NodeRow (+1 more)

### Community 594 - "Community 594"
Cohesion: 0.33
Nodes (4): KeyRecorderViewTests, NSEvent, String, UInt16

### Community 596 - "Community 596"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 598 - "Community 598"
Cohesion: 0.13
Nodes (14): StatusLineView, CGFloat, FormatColor, Never, NSAttributedString, NSCoder, NSColor, NSLayoutConstraint (+6 more)

### Community 599 - "Community 599"
Cohesion: 0.31
Nodes (6): AnimatablePair, NotchShape, CGFloat, CGPath, CGRect, Path

### Community 600 - "Community 600"
Cohesion: 0.10
Nodes (15): NSRangePointer, NSTextInputClient, HarnessTerminalSurfaceView, Any, Bool, NSAttributedString, NSEvent, NSPoint (+7 more)

### Community 603 - "Community 603"
Cohesion: 0.14
Nodes (14): AgentRow, AgentRow, MenuBarController, MenuRef, CGFloat, NSImage, NSMenu, NSMenuItem (+6 more)

### Community 608 - "MatchCategory"
Cohesion: 0.22
Nodes (9): MatchCategory, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith, filenameStartsWith, fuzzy, pathContains (+1 more)

### Community 613 - "Community 613"
Cohesion: 0.20
Nodes (5): Active Plans, Completed, Pending, Plans Index — harness-terminal, Quick ref — recent completions

### Community 614 - "Community 614"
Cohesion: 0.11
Nodes (12): MainSplitViewController, Bool, CADisplayLink, CGFloat, NSColor, NSLayoutConstraint, NSRect, NSSplitView (+4 more)

### Community 617 - "Community 617"
Cohesion: 0.22
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 618 - "TriState"
Cohesion: 0.28
Nodes (7): SettingsTerminalView, Bool, String, TriState, auto, off, on

### Community 620 - "Community 620"
Cohesion: 0.14
Nodes (19): FooterIconButton, RecentProjectsMenuButton, SidebarFooterModel, SidebarFooterView, SidebarSectionLabelView, SidebarSectionModel, SidebarTabBarView, Bool (+11 more)

### Community 621 - ".webView"
Cohesion: 0.28
Nodes (3): WKNavigation, WKNavigationAction, WKWindowFeatures

### Community 622 - "Community 622"
Cohesion: 0.40
Nodes (5): [1.3.0-vit] - 2026-06-06, Added, Changed, Documentation, Fixed

### Community 623 - "Community 623"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 624 - "Community 624"
Cohesion: 0.40
Nodes (5): [2.5.0] - 2026-06-12, Added, Changed, Documentation, Fixed

### Community 626 - "Community 626"
Cohesion: 0.11
Nodes (12): NotificationCoordinator, Bool, Date, SessionCoordinator, SessionSnapshot, Set, String, SurfaceID (+4 more)

### Community 629 - "LoadCompletionState"
Cohesion: 0.42
Nodes (5): LoadCompletionState, CheckedContinuation, Error, TimeInterval, Void

### Community 630 - "Community 630"
Cohesion: 0.40
Nodes (5): [3.0.0] - 2026-06-15, Added, Changed, Documentation, Fixed

### Community 641 - "Community 641"
Cohesion: 0.40
Nodes (5): [3.10.0] - 2026-06-27, Added, Changed, Documentation, Fixed

### Community 645 - "Community 645"
Cohesion: 0.15
Nodes (12): DemoSession, GridCanvas, Bool, String, StyledSegment, TerminalGridCell, TerminalGridColor, TerminalGridSnapshot (+4 more)

### Community 646 - "Community 646"
Cohesion: 0.40
Nodes (5): [3.10.1] - 2026-06-27, Added, Changed, Documentation, Fixed

### Community 647 - ".normalizedKey"
Cohesion: 0.29
Nodes (4): ControlKeyNormalizer, Bool, String, ControlKeyNormalizerTests

### Community 648 - "Community 648"
Cohesion: 0.15
Nodes (14): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, DrainState, EchoRTT (+6 more)

### Community 650 - "Community 650"
Cohesion: 0.40
Nodes (5): [3.11.0] - 2026-06-28, Added, Changed, Documentation, Fixed

### Community 652 - "Community 652"
Cohesion: 0.05
Nodes (36): InlineAICompletionController, HarnessSettings, String, ResizeOverlayPosition, bottomRight, center, topRight, DetachedPaneOverlay (+28 more)

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
Cohesion: 0.06
Nodes (38): ChooseScope, buffer, client, session, tree, window, MenuItem, PaneTarget (+30 more)

### Community 660 - "Community 660"
Cohesion: 0.11
Nodes (14): NotificationEntry, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, NotificationRowView, Bool (+6 more)

### Community 661 - "Community 661"
Cohesion: 0.33
Nodes (5): Harness vs Competitors (Remote Development over SSH), Our Gaps (vs leaders), Our Strengths, Remote SSH — Market Comparison, Roadmap Opportunities

### Community 663 - "Community 663"
Cohesion: 0.40
Nodes (5): [3.1.2] - 2026-06-16, Added, Changed, Documentation, Fixed

### Community 664 - "Community 664"
Cohesion: 0.16
Nodes (9): CompletionPopupView, CompletionRowView, Bool, NSCoder, NSEvent, NSRect, NSTrackingArea, String (+1 more)

### Community 665 - "Community 665"
Cohesion: 0.25
Nodes (7): PathToken, PathTokenParser, Bool, String, LiveResizeGeometry, Result, Bool

### Community 666 - "Community 666"
Cohesion: 0.04
Nodes (31): AgentScanner, DispatchSourceTimer, DaemonCommandExecutor, Command, HookExecutor, DispatchQueue, SurfaceRegistry, Bool (+23 more)

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
Cohesion: 0.09
Nodes (26): AgentBridge, AgentTarget, Bool, String, SurfaceID, AgentCatalog, AgentConfig, DiskAgentConfig (+18 more)

### Community 672 - "Community 672"
Cohesion: 0.40
Nodes (4): Cursor Agent → Harness, Manual fallback, One-line install, What you'll see

### Community 674 - "Community 674"
Cohesion: 0.40
Nodes (5): [3.9.1] - 2026-06-22, Added, Changed, Documentation, Fixed

### Community 675 - ".show"
Cohesion: 0.38
Nodes (5): NSView, String, TimeInterval, Toast, ToastBody

### Community 678 - "Community 678"
Cohesion: 0.14
Nodes (9): EditorDividerView, NSLayoutConstraint, FilePreviewCoordinator, Bool, FileTabID, NSLayoutConstraint, NSView, SplitDirection (+1 more)

### Community 679 - ".load"
Cohesion: 0.43
Nodes (3): HarnessSettings, Bool, Data

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
Cohesion: 0.29
Nodes (6): TabStatus, done, error, idle, running, waiting

### Community 685 - "Community 685"
Cohesion: 0.50
Nodes (4): [1.5.1] - 2026-06-06, Added, Documentation, Fixed

### Community 686 - ".status"
Cohesion: 0.47
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
Cohesion: 0.06
Nodes (18): Int, SemanticMark, HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor, Bool (+10 more)

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
Cohesion: 0.67
Nodes (3): Result, AsyncCLIResultBox, Error

### Community 710 - "Community 710"
Cohesion: 0.33
Nodes (3): HarnessWindow, NSEvent, NSWindow

### Community 711 - "Community 711"
Cohesion: 0.19
Nodes (14): FileEditorTabBarBody, FileEditorTabBarModel, FileEditorTabBarView, FileTabPillView, Bool, FileTabID, NSCoder, NSRect (+6 more)

### Community 712 - "Community 712"
Cohesion: 0.13
Nodes (11): CornerInfo, HarnessSplitView, DispatchWorkItem, Double, NSColor, NSRect, NSTrackingArea, NSSplitView (+3 more)

### Community 713 - "Community 713"
Cohesion: 0.20
Nodes (12): Decodable, HarnessBrowserTools, Bool, Double, String, TimeInterval, Document, Bool (+4 more)

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
Cohesion: 0.12
Nodes (8): SessionLifecycleService, SessionCoordinator, SessionGroup, SessionID, String, Tab, TabID, WorkspaceID

### Community 724 - "Community 724"
Cohesion: 0.09
Nodes (17): IndexingIterator, LayoutTemplate, CGFloat, Command, Double, PaneID, PaneLeaf, PaneNode (+9 more)

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
Nodes (4): [3.9.5] - 2026-06-26, Added, Documentation, Fixed

### Community 735 - "Community 735"
Cohesion: 0.16
Nodes (5): LSPTextLocation, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 737 - "Community 737"
Cohesion: 0.15
Nodes (11): FileFuzzyMatcher, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool, Character (+3 more)

### Community 739 - "Community 739"
Cohesion: 0.53
Nodes (3): ProjectConfig, Bool, String

### Community 743 - "WatcherContext"
Cohesion: 0.50
Nodes (4): escaping, MainActor, Void, WatcherContext

### Community 744 - "Kind"
Cohesion: 0.40
Nodes (5): Kind, input, metadata, output, resize

### Community 745 - "Community 745"
Cohesion: 0.40
Nodes (3): GroupedSessionDaemonTests, String, URL

### Community 746 - "Community 746"
Cohesion: 0.67
Nodes (3): [3.11.2] - 2026-06-28, Changed, Fixed

### Community 750 - "DiffLineType"
Cohesion: 0.50
Nodes (4): DiffLineType, added, deleted, modified

### Community 753 - "[3.5.1] - 2026-06-20"
Cohesion: 0.50
Nodes (4): [3.5.1] - 2026-06-20, Added, Documentation, Fixed

### Community 754 - "Community 754"
Cohesion: 0.16
Nodes (14): CTFontSymbolicTraits, MTLDevice, GlyphRasterizer, RasterizedGlyph, ShapedGlyph, ShapedRunKey, Bool, CGContext (+6 more)

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
Cohesion: 0.50
Nodes (4): DetachKeys, absent, invalid, parsed

### Community 767 - "Community 767"
Cohesion: 0.15
Nodes (11): DaemonSyncService, Bool, Never, SessionCoordinator, SessionSnapshot, SurfaceID, Tab, TabID (+3 more)

### Community 768 - "Community 768"
Cohesion: 0.15
Nodes (10): CommandPromptController, KeyablePanel, Bool, NSControl, NSPanel, NSTextView, Selector, String (+2 more)

### Community 771 - "Community 771"
Cohesion: 0.19
Nodes (7): FileEditorView, Bool, NSCoder, NSEvent, NSRect, String, URL

### Community 779 - "Community 779"
Cohesion: 0.21
Nodes (7): BrowserTabButton, NSCoder, NSRect, WeakScriptMessageHandler, WKScriptMessage, WKScriptMessageHandler, WKUserContentController

### Community 780 - "Community 780"
Cohesion: 0.40
Nodes (5): [2.2.4] - 2026-06-11, Added, Changed, Documentation, Fixed

### Community 781 - "Community 781"
Cohesion: 0.40
Nodes (5): [2.4.0] - 2026-06-12, Added, Changed, Documentation, Fixed

### Community 786 - "Community 786"
Cohesion: 0.50
Nodes (4): [2.1.0] - 2026-06-07, Added, Documentation, Fixed

### Community 789 - "Community 789"
Cohesion: 0.50
Nodes (4): [1.5.1] - 2026-06-06, Added, Documentation, Fixed

### Community 790 - "Community 790"
Cohesion: 0.50
Nodes (4): [1.6.0] - 2026-06-07, Added, Documentation, Fixed

### Community 792 - "[3.1.3] - 2026-06-16"
Cohesion: 0.67
Nodes (3): [3.1.3] - 2026-06-16, Added, Fixed

### Community 796 - "Community 796"
Cohesion: 0.50
Nodes (4): [2.3.0] - 2026-06-11, Added, Changed, Documentation

### Community 797 - "Community 797"
Cohesion: 0.40
Nodes (5): [3.0.0] - 2026-06-15, Added, Changed, Documentation, Fixed

### Community 798 - "Community 798"
Cohesion: 0.50
Nodes (4): [3.5.0] - 2026-06-20, Added, Documentation, Fixed

### Community 799 - "[3.1.3] - 2026-06-16"
Cohesion: 0.67
Nodes (3): [3.1.3] - 2026-06-16, Added, Fixed

### Community 817 - "Community 817"
Cohesion: 0.21
Nodes (5): Bool, SessionCoordinator, String, ThemeService, HarnessOptions

### Community 841 - "Community 841"
Cohesion: 0.12
Nodes (16): 2026-06-29 — Claude Code statusLine/advisor/remote-control "broke after migrate" ✅, 2026-06-29 — Live perf profile of running Harness 3.11.7/183 ✅ (diagnosis only), 2026-06-30 — Cmd+\ sidebar toggle gone after collapse ✅ FIXED, 2026-07-01 — ACP-removal cleanup (items 1 & 2 from P23 wrap-up) ✅ FIXED, 2026-07-01 — P23 socket auto-detect (PBI-SSH-008) ✅ FIXED — P23 now Complete, 2026-07-01 — P32 interview-doc pass (before implementation), 2026-07-01 — P32 Phase 1 live verification + 2 bugs fixed, 2026-07-01 — P32 Phase 2: worktree tabs invisible to git UI ✅ FIXED (pending live confirm) (+8 more)

### Community 956 - "Community 956"
Cohesion: 0.40
Nodes (5): [3.1.2] - 2026-06-16, Added, Changed, Documentation, Fixed

### Community 1003 - "Community 1003"
Cohesion: 0.40
Nodes (5): [3.8.0] - 2026-06-22, Added, Changed, Documentation, Fixed

### Community 3120 - "Community 3120"
Cohesion: 0.28
Nodes (7): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor, NSView

### Community 3202 - "Community 3202"
Cohesion: 0.10
Nodes (21): EndpointError, connectionFailed, notYetSupported, pathTooLong, String, EndpointConnector, Int32, String (+13 more)

### Community 3203 - "Community 3203"
Cohesion: 0.15
Nodes (5): CodepointRunFastPathTests, StaticString, String, UInt, UInt8

### Community 3211 - "Community 3211"
Cohesion: 0.23
Nodes (6): CellOverlayTests, HarnessTerminalSurfaceView, IndexSet, NSWindow, String, UInt64

### Community 3257 - "Community 3257"
Cohesion: 0.09
Nodes (20): JSONRPCMessage, notification, request, response, Encoder, StdioTransportTests, Data, HarnessMCPServer (+12 more)

### Community 3320 - "Community 3320"
Cohesion: 0.12
Nodes (16): F1 — Explicit "New Task" entry point — P0, F2 — Task metadata model — P0, F3 — Per-project setup/teardown hooks — P1, F4 — Task switcher — P2, Feature Specs, First Implementation Slice, Implementation Phases, Non-goals (this plan) (+8 more)

### Community 3379 - "Community 3379"
Cohesion: 0.07
Nodes (28): Command, PaneRef, bottom, byID, byIndex, last, left, next (+20 more)

### Community 3380 - "Community 3380"
Cohesion: 0.09
Nodes (21): PendingVersionBanner, welcome, whatsNew, State, Bool, String, URL, VersionBannerStore (+13 more)

### Community 3419 - "Community 3419"
Cohesion: 0.10
Nodes (15): SettingsHostingController, SettingsWindowController, NSCoder, NSWindow, Page, advanced, appearance, remote (+7 more)

### Community 3444 - "Community 3444"
Cohesion: 0.30
Nodes (7): CommandTarget, PaneID, SessionGroup, SessionSnapshot, Tab, first, tabs

### Community 3597 - "Community 3597"
Cohesion: 0.38
Nodes (4): AnyObject, TimeInterval, ZombieHoldRegistry, ObjectIdentifier

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
Nodes (10): AgentDetector, AgentTable, Date, Int32, TimeInterval, ProcessScan, Int32, AgentSnapshot (+2 more)

## Knowledge Gaps
- **3914 isolated node(s):** `$schema`, `allow`, `ask`, `PreToolUse`, `UserPromptSubmit` (+3909 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1987 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `AboutView`, `AgentActivity`, `AgentApprovalBar`, `AgentInboxBody`, `AgentInboxPanelView` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `Community 694` to `Community 513`, `Tests: HarnessTerminalRendererTests / MetalRendererTests`, `HarnessCore: Settings / HarnessSettings`, `Terminal Renderer: HarnessTerminalRenderer / TerminalMetalRenderer`, `Harness CLI: HarnessCLI`, `Terminal Engine: Emulator / TerminalEmulator`, `Harness App: Settings / SettingsViewController`, `Tests: HarnessBenchmarks / PerformanceBenchmarks`, `Harness App: UI / TerminalTabBarView`, `Community 521`, `Community 522`, `Terminal Engine: Parser / VTParser`, `Tests: HarnessCoreTests / FormatStringTests`, `HarnessCore: ACP / ACPClient`, `Release Notes: CHANGELOG`, `Release Notes: CHANGELOG`, `Terminal Kit: HarnessTerminalKit / HarnessTerminalSurfaceView`, `Tests: HarnessDaemonTests / DaemonRoundTripTests`, `Community 538`, `Tests: HarnessTerminalRendererTests / CellColorResolverTests`, `Harness App: UI / CommandPaletteController`, `Tests: HarnessCoreTests / IPCCodecTests`, `Tests: HarnessCoreTests / JSONMergeTests`, `Tests: HarnessTerminalEngineTests / EngineConformanceTests`, `Community 546`, `Theme: HarnessTheme / ThemeDocument`, `Community 548`, `HarnessCore: Settings / HarnessSettings`, `Tests: HarnessTerminalEngineTests / ParserRobustnessTests`, `Harness CLI: HarnessCLI / WindowAttachClient`, `Tests: HarnessTerminalKitTests / RenderSchedulerTests`, `HarnessCore: Models / SessionSnapshot`, `HarnessCore: Commands / CopyModeAction`, `Tests: HarnessDaemonTests / SurfaceRegistryTests`, `Daemon: HarnessDaemon / DaemonServer`, `Harness App: UI / HarnessSidebarPanelViewController`, `Community 566`, `Tests: HarnessCoreTests / TargetSpecTests`, `Community 570`, `Tests: HarnessCoreTests / PasteBufferStoreTests`, `AIDLC: harness / ide-file-tree / outputs / domain-decomposition`, `Onboarding: TerminalKit / GridCompositor`, `Tests: HarnessTerminalKitTests / LiveResizeTests`, `Daemon: HarnessDaemon / SurfaceRegistry`, `HarnessCore: IPC / IPCCodec`, `Community 582`, `Harness App: UI / MenuBarController`, `Harness App: UI / HarnessControls`, `Terminal Kit: HarnessTerminalKit / GridCompositor`, `HarnessCore: Agents / AgentSnapshot`, `AIDLC: harness / ide-file-tree / outputs / domain-design`, `Tests: HarnessCoreTests / DaemonClientTests`, `HarnessCore: ACP / ACPTransport`, `Tests: HarnessCoreTests / CommandParserTests`, `Harness App: UI / SearchPanelView`, `Community 598`, `Harness App: Services / SessionCoordinator`, `Community 600`, `Community 603`, `Terminal Engine: HarnessTerminalEngine / InputEncoder`, `Tests: HarnessCoreTests / AttachInputBatcherTests`, `MatchCategory`, `Harness App: Services / MainExecutor`, `Community 614`, `Tests: HarnessTerminalEngineTests / HarnessGridTerminalTests`, `Harness App: UI / Notch / AgentNotchViewModel`, `Community 620`, `Tests: HarnessCoreTests / PaneStyleTests`, `Community 623`, `Tests: HarnessTerminalEngineTests / ThaiCombiningMarkTests`, `HarnessCore: Persistence / SessionStore`, `Harness App: UI / HarnessDesign`, `Harness App: UI / PrefixKeymap`, `Theme: HarnessTheme / ThemeDiagnostics`, `HarnessCore: Commands / Command`, `Terminal Engine: Screen / HistoryRingBuffer`, `Onboarding: Design / AgentMark`, `Copy Mode: HarnessCopyMode / CopyModeReducer`, `.testRenderEncodeIncrementalDamage160x48`, `HarnessCore: Settings / TerminalConfigImporter`, `Community 3202`, `Community 3203`, `Terminal Kit: HarnessTerminalKit / TerminalHostView`, `Community 645`, `Harness App: Settings / SettingsViewController`, `Community 648`, `Onboarding: UI / ImmersiveOnboardingWindowController`, `Community 3211`, `Community 652`, `Release Notes: CHANGELOG`, `Tests: HarnessTerminalEngineTests / AsciiFastPathTests`, `Tests: HarnessThemeTests`, `Community 660`, `Harness App: Services / SessionCoordinator`, `Community 664`, `Community 665`, `Community 666`, `Onboarding: Install / BinaryInstaller`, `HarnessCore: Notch / AgentNotchProjection`, `HarnessCore: FileExplorer / FileTreeWatcher`, `Tests: HarnessDaemonTests / VersionBannerTests`, `Terminal Kit: HarnessTerminalKit / TerminalFindBar`, `Terminal Kit: HarnessTerminalKit / TerminalHostView`, `Community 678`, `HarnessCore: ACP / ACPSession`, `Community 680`, `Terminal Kit: HarnessTerminalKit / ThemeManager`, `HarnessCore: Commands / TargetSpec`, `Harness CLI: HarnessCLI`, `Harness CLI: HarnessCLI / WindowAttachClient`, `Copy Mode: HarnessCopyMode / CopyModeGridSource`, `HarnessCore: Paths / LaunchAgentInstaller`, `Terminal Renderer: HarnessTerminalRenderer / TerminalFrame`, `Tests: HarnessTerminalEngineTests / ReflowCorpusTests`, `Tests: HarnessTerminalEngineTests / ScrollbackTests`, `Harness App: UI / ContentAreaViewController`, `Community 3257`, `Community 3774`, `AIDLC: harness / ide-file-tree / planning / 00-inception-plan`, `Tests: HarnessTerminalEngineTests / HistoryRingBufferTests`, `Terminal Renderer: HarnessTerminalRenderer / TerminalMetalRenderer`, `Harness App: UI / HarnessDesign`, `HarnessCore: CLI / TerminalRecording`, `AsyncCLIResultBox`, `Community 712`, `Community 713`, `HarnessCore: Commands / CommandIPCTranslator`, `.runFrameBuildBenchmark`, `HarnessCore: ACP / ACPSession`, `Tests: HarnessCoreTests / BinaryRefresherTests`, `HarnessCore: Paths / HarnessPaths`, `Community 723`, `Tests: HarnessCoreTests / CommandIPCTranslatorTests`, `Community 724`, `Tests: HarnessCoreTests / FormatStyledTests`, `Harness App: UI / PrefixKeymap`, `HarnessCore: Session / PaneRectSolver`, `Onboarding: Install / NotificationPermission`, `Harness App: UI / NotificationBellButton`, `Community 735`, `AIDLC: harness / acp / outputs / domain-decomposition`, `Community 737`, `Scripts: terminal_stress_runner.py`, `Harness CLI: HarnessCLI / RecordClient`, `Tests: HarnessCoreTests / TabAlertTests`, `Harness App: UI / HarnessSidebarPanelViewController`, `Tests: HarnessOnboardingTests / BinaryInstallerVersionTests`, `HarnessCore: Metadata / MetadataProvider`, `Community 754`, `Onboarding: UI / SetupStepView`, `ColorKind`, `Tests: HarnessCoreTests / SnapshotQueryFormatterTests`, `Tests: HarnessTerminalEngineTests / ReflowPreviewTests`, `Tests: HarnessCoreTests / TerminalConfigImporterTests`, `AIDLC: harness / ide-file-tree / audit.md / audit`, `Community 767`, `Community 768`, `Community 771`, `HarnessCore: ReleaseNotes / TerminalBanner`, `Community 777`, `Tests: HarnessCopyModeTests / WordColumnRangeTests`, `Onboarding: UI / ShellStepView`, `Tests: HarnessCoreTests / CompletionGeneratorTests`, `Tests: HarnessCoreTests / SGRMouseTests`, `Tests: HarnessCoreTests / ShellCompletionInstallerTests`, `HarnessCore: Platform / PlatformSys`, `Terminal Kit: HarnessTerminalKit / HarnessTerminalSurfaceView`, `Harness App: UI / ContentAreaViewController`, `HarnessCore: Models / PaneNode`, `Terminal Kit: HarnessTerminalKit / TerminalScrollbarView`, `Tests: HarnessCoreTests / AgentDetectorTests`, `HarnessCore: CLI / CompletionGenerator`, `Tests: HarnessCoreTests / Phase67Tests`, `Terminal Engine: Width / CharacterWidth`, `Tests: HarnessCoreTests / EndpointTests`, `Tests: HarnessCoreTests / ShellIntegrationTests`, `Release Notes: CHANGELOG`, `AIDLC: harness / acp / outputs / brainstorming-summary`, `AIDLC: harness / ide-file-tree / outputs / brainstorming-summary`, `Harness App: Services / CLIInstaller`, `Community 3380`, `Release Notes: CHANGELOG`, `Harness App: UI / Notch / NotchShape`, `HarnessCore: CLI / TerminalRecording`, `Harness CLI: HarnessCLI / ReplayClient`, `Harness App: UI / WindowTitleStripView`, `Harness App: UI / HarnessControls`, `Community 3419`, `Tests: HarnessDaemonTests / DaemonLifecycleTests`, `LSP: HarnessLSP / LSPServerRegistry`, `AIDLC: harness / acp / PROGRESS.md / PROGRESS`, `Onboarding: Design / Effects`, `Claude Instructions: CLAUDE`, `Community 3444`, `HarnessCore: Settings / JSONMerge`, `Terminal Engine: Images / SixelDecoder`, `Community 377`, `HarnessCore: Format / JSONOutputFormatter`, `HarnessCore: Keybindings / ControlKeyNormalizer`, `Community 382`, `Terminal Engine: Width / CharacterWidthTable`, `C System Shim: CHarnessSys`, `Harness App: UI / HarnessDesign`, `HarnessCore: ACP / ACPClient`, `Community 425`, `Community 427`, `Harness App: UI / HarnessDesign`, `Tests: HarnessCoreTests / GroupedSessionTests`, `Onboarding: UI / OnboardingWizardView`, `Community 445`, `Release Notes: CHANGELOG`, `Agent Memory: knowledge / index`, `Community 461`, `Tests: HarnessCoreTests / OptionValueTests`, `Community 466`, `Tests: GridCompositorParityTests / LiveCompositorFixture`, `Community 479`, `Community 510`?**
  _High betweenness centrality (0.198) - this node is a cross-community bridge._
- **Why does `HarnessCore` connect `Harness App: UI / ContentAreaViewController` to `Community 768`, `HarnessCore: Settings / TerminalConfigImporter`, `HarnessCore: HarnessCore / HarnessVersion`, `Terminal Engine: Width / CharacterWidthTable`, `Terminal Renderer: HarnessTerminalRenderer / TerminalMetalRenderer`, `Harness App: UI / FileViewerViewController`, `Community 648`, `Community 521`, `Tests: HarnessCopyModeTests / WordColumnRangeTests`, `Harness App: UI / TerminalTabBarView`, `Harness CLI: HarnessCLI`, `HarnessCore: Platform / PlatformSys`, `Community 660`, `Release Notes: CHANGELOG`, `Terminal Engine: Images / DecodedImage`, `Community 538`, `HarnessCore: FileExplorer / FileTreeWatcher`, `Community 671`, `Tests: HarnessDaemonTests / VersionBannerTests`, `Community 546`, `Community 547`, `Community 680`, `HarnessCore: Models / SessionSnapshot`, `Community 817`, `Daemon: HarnessDaemon / DaemonServer`, `Community 566`, `Tests: HarnessCoreTests / TargetSpecTests`, `Community 3257`, `Community 570`, `Tests: HarnessTerminalEngineTests / ScrollbackTests`, `Community 444`, `Tests: HarnessCoreTests / KeyTableTests`, `Community 576`, `Daemon: HarnessDaemon / SurfaceRegistry`, `Harness App: Settings / KeyRecorderView`, `Tests: HarnessCoreTests / SessionPersistenceTests`, `Community 711`, `Community 584`, `Community 713`, `HarnessCore: Commands / CommandIPCTranslator`, `HarnessCore: Keybindings / KeyTable`, `Terminal Engine: HarnessTerminalEngine / InputEncoder`, `Tests: HarnessTerminalEngineTests / SemanticPromptTests`, `Harness App: UI / HarnessControls`, `Tests: HarnessCoreTests / CommandParserTests`, `Tests: HarnessCoreTests / DaemonClientTests`, `HarnessCore: Notch / NotchLayoutMetrics`, `Tests: HarnessOnboardingTests / ShellProfileInstallerTests`, `HarnessCore: ACP / ACPTransport`, `Tests: GridCompositorParityTests / LiveCompositorFixture`, `Community 3419`, `Community 476`, `Community 603`, `Harness App: UI / NotificationBellButton`, `Tests: HarnessDaemonTests / DaemonLifecycleTests`, `Harness App: Services / MainExecutor`, `TriState`, `Community 620`, `HarnessCore: Format / JSONOutputFormatter`, `Onboarding: Design / GlassEffectView`, `Community 377`, `Community 506`, `HarnessCore: Commands / Command`, `Tests: HarnessTerminalEngineTests / ReflowFastPathTests`, `HarnessCore: Paths / ShellCompletionInstaller`?**
  _High betweenness centrality (0.040) - this node is a cross-community bridge._
- **Why does `Foundation` connect `HarnessCore: HarnessCore / HarnessVersion` to `Terminal Engine: Model / TerminalGridModel`, `Community 513`, `Harness CLI: HarnessCLI`, `Community 522`, `Community 3597`, `Terminal Engine: Parser / VTParser`, `HarnessCore: ACP / ACPClient`, `Release Notes: CHANGELOG`, `HarnessCore: Agents / AgentHookInstaller`, `Community 535`, `HarnessCore: Session / SessionEditor`, `Tests: HarnessTerminalRendererTests / CellColorResolverTests`, `Tests: HarnessCoreTests / IPCCodecTests`, `Tests: HarnessCoreTests / JSONMergeTests`, `Harness App: UI / GitPanelView`, `HarnessCore: Settings / HarnessSettings`, `Tests: HarnessTerminalEngineTests / ParserRobustnessTests`, `Harness CLI: HarnessCLI / WindowAttachClient`, `Tests: HarnessTerminalKitTests / RenderSchedulerTests`, `HarnessCore: Commands / CopyModeAction`, `HarnessCore: Events / HookRegistry`, `Daemon: HarnessDaemon / DaemonServer`, `Tests: HarnessCoreTests / PasteBufferStoreTests`, `AIDLC: harness / ide-file-tree / outputs / domain-decomposition`, `Tests: HarnessCoreTests / KeyTableTests`, `Onboarding: TerminalKit / GridCompositor`, `Community 576`, `Daemon: HarnessDaemon / SurfaceRegistry`, `Terminal Kit: HarnessTerminalKit / HarnessTerminalSurfaceView`, `Terminal Kit: HarnessTerminalKit / TerminalHostView`, `Harness App: UI / MenuBarController`, `Community 584`, `Community 586`, `Community 587`, `Terminal Kit: HarnessTerminalKit / GridCompositor`, `Community 589`, `AIDLC: harness / ide-file-tree / outputs / domain-design`, `HarnessCore: ACP / ACPTransport`, `Tests: HarnessCoreTests / CommandParserTests`, `Harness App: UI / SearchPanelView`, `Terminal Engine: HarnessTerminalEngine / InputEncoder`, `Tests: HarnessCoreTests / AttachInputBatcherTests`, `Onboarding: Design / Components`, `Tests: HarnessTerminalEngineTests / CodepointRunFastPathTests`, `Community 617`, `Harness App: UI / HarnessControls`, `Tests: HarnessTerminalEngineTests / ThaiCombiningMarkTests`, `HarnessCore: Persistence / SessionStore`, `Harness App: UI / PrefixKeymap`, `Harness App: UI / WorkspaceFileTreeView`, `Terminal Engine: Screen / HistoryRingBuffer`, `Community 3202`, `Terminal Kit: HarnessTerminalKit / TerminalHostView`, `Harness App: Settings / SettingsViewController`, `.normalizedKey`, `Community 648`, `HarnessCore: IPC / DaemonSessionService`, `Tests: HarnessThemeTests`, `Community 659`, `Harness App: Services / SessionCoordinator`, `Root Docs: README`, `Community 665`, `Onboarding: Install / BinaryInstaller`, `HarnessCore: Notch / AgentNotchProjection`, `HarnessCore: FileExplorer / FileTreeWatcher`, `Community 671`, `Terminal Kit: HarnessTerminalKit / TerminalHostView`, `DaemonClientActor`, `HarnessCore: Diagnostics / DoctorRunner`, `.load`, `Community 680`, `Community 682`, `Terminal Kit: HarnessTerminalKit / ThemeManager`, `TabStatus`, `Harness CLI: HarnessCLI`, `Community 694`, `HarnessCore: Keybindings / KeyTokenParser`, `Community 696`, `Terminal Renderer: HarnessTerminalRenderer / TerminalFrame`, `Community 3257`, `Community 702`, `HarnessCore: CLI / TerminalRecording`, `Community 711`, `Community 713`, `HarnessCore: ACP / ACPSession`, `Tests: HarnessCoreTests / BinaryRefresherTests`, `HarnessCore: Notch / NotchLayoutMetrics`, `Terminal Renderer: HarnessTerminalRenderer / GlyphAtlas`, `Harness App: UI / NotificationBellButton`, `Community 735`, `WorkbenchMRU`, `Community 737`, `Harness CLI: HarnessCLI / RecordClient`, `Community 739`, `Terminal Kit: HarnessTerminalKit / TerminalHostView`, `Tests: HarnessCoreTests / TerminalBannerTests`, `Harness App: UI / HarnessSidebarPanelViewController`, `Tests: HarnessOnboardingTests / BinaryInstallerVersionTests`, `Harness App: UI / MainSplitViewController`, `Tests: HarnessCoreTests / SnapshotQueryFormatterTests`, `Tests: HarnessTerminalEngineTests / ReflowFastPathTests`, `Harness App: Services / SessionCoordinator`, `Tests: HarnessThemeTests / ThemeFileServiceTests`, `HarnessCore: ReleaseNotes / TerminalBanner`, `Onboarding: UI / ShellStepView`, `Tests: HarnessCoreTests / SGRMouseTests`, `Tests: HarnessCoreTests / ShellCompletionInstallerTests`, `HarnessCore: Agents / AgentHookStrategy`, `Terminal Engine: Width / CharacterWidth`, `Harness CLI: HarnessCLI / WindowAttachClient`, `Tests: HarnessCoreTests / EndpointTests`, `Release Notes: CHANGELOG`, `Tests: HarnessTerminalKitTests / HarnessTerminalSurfaceDragDropTests`, `HarnessCore: Agents / HookNotificationParser`, `AIDLC: harness / acp / outputs / brainstorming-summary`, `Community 3379`, `Release Notes: CHANGELOG`, `Harness App: UI / Phase67UI`, `Harness App: UI / Notch / NotchShape`, `HarnessCore: CLI / TerminalRecording`, `Tests: HarnessDaemonTests / ShellLaunchProfileTests`, `Tests: HarnessTerminalEngineTests / CharacterWidthTests`, `Harness App: UI / WindowTitleStripView`, `Harness App: UI / SyntaxTextView`, `Harness App: UI / HarnessControls`, `Tests: HarnessDaemonTests / DaemonLifecycleTests`, `Onboarding: UI / ComposedTerminalView`, `Harness App: UI / HarnessDesign`, `Onboarding: Design / Effects`, `Claude Instructions: CLAUDE`, `HarnessCore: Settings / JSONMerge`, `HarnessCore: Format / JSONOutputFormatter`, `Onboarding: Install / HarnessCLIPaths`, `Terminal Engine: Width / CharacterWidthTable`, `Harness App: UI / ContentAreaViewController`, `Community 433`, `Tests: HarnessCoreTests / GroupedSessionTests`, `Community 441`, `Community 444`, `Tests: HarnessCoreTests / OptionValueTests`, `Tests: GridCompositorParityTests / LiveCompositorFixture`, `Community 498`, `Community 510`, `Community 511`?**
  _High betweenness centrality (0.033) - this node is a cross-community bridge._
- **Are the 43 inferred relationships involving `Int` (e.g. with `.register()` and `.coloredImage()`) actually correct?**
  _`Int` has 43 INFERRED edges - model-reasoned connections that need verification._
- **What connects `$schema`, `allow`, `ask` to the rest of the system?**
  _3934 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Tests: HarnessTerminalRendererTests / MetalRendererTests` be split into smaller, more focused modules?**
  _Cohesion score 0.05210688591983556 - nodes in this community are weakly interconnected._
- **Should `HarnessCore: Settings / HarnessSettings` be split into smaller, more focused modules?**
  _Cohesion score 0.06882591093117409 - nodes in this community are weakly interconnected._