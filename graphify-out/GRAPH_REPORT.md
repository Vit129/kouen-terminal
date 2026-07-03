# Graph Report - harness-terminal  (2026-07-03)

## Corpus Check
- 715 files · ~850,052 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 14591 nodes · 31234 edges · 3721 communities (1230 shown, 2491 thin omitted)
- Extraction: 89% EXTRACTED · 11% INFERRED · 0% AMBIGUOUS · INFERRED: 3427 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `3ee42f82`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `SessionEditor` - 170 edges
2. `SurfaceRegistry` - 154 edges
3. `IPCRequest` - 151 edges
4. `DaemonClient` - 142 edges
5. `SessionCoordinator` - 124 edges
6. `HarnessTerminalSurfaceView` - 124 edges
7. `AnyCodable` - 109 edges
8. `Command` - 107 edges
9. `TerminalScreen` - 100 edges
10. `TerminalHostView` - 99 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 137 areas (151 edges)
2. `Command` - bridges 100 areas (107 edges)
3. `SessionCoordinator` - bridges 54 areas (124 edges)
4. `IPCResponse` - bridges 53 areas (69 edges)
5. `MenuTarget` - bridges 53 areas (60 edges)
6. `SpecialKey` - bridges 52 areas (56 edges)
7. `EngineConformanceTests` - bridges 50 areas (76 edges)
8. `AgentKind` - bridges 47 areas (92 edges)
9. `HarnessPaths` - bridges 43 areas (95 edges)
10. `SurfaceRegistry` - bridges 42 areas (154 edges)

## Surprising Connections (you probably didn't know these)
- `SUI` --calls--> `Color`  [INFERRED]
  Packages/HarnessOnboarding/Sources/HarnessOnboarding/Design/ImmersivePalette.swift → Apps/Harness/Sources/HarnessApp/Settings/SwiftUI/SettingsColorsView.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/DaemonSyncService.swift → Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/RemoteHostsService.swift → Packages/HarnessCore/Sources/HarnessCore/Remote/RemoteHostStore.swift
- `ThemeImportController` --calls--> `ThemeFileService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/ThemeImportController.swift → Packages/HarnessTheme/Sources/HarnessTheme/ThemeFileService.swift
- `WorktreeAutoIsolateService` --calls--> `WorktreeManager`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/WorktreeAutoIsolateService.swift → Packages/HarnessCore/Sources/HarnessCore/Worktree/WorktreeManager.swift

## Import Cycles
- None detected.

## Communities (3721 total, 2491 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.27
Nodes (10): OptionSet, BannerShortcut, BannerShortcutRegistry, Keybinding, MenuModifiers, Bool, Decoder, NSEvent (+2 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.12
Nodes (17): AnyTransition, AnyView, AgentNotchPeekEvent, AgentNotchRootView, HorizontalInsetRect, NotchOverviewRow, NotchRowButtonStyle, NotchStatusDot (+9 more)

### Community 8 - "LSPMessage"
Cohesion: 0.08
Nodes (24): FileHandle, CodingKeys, error, id, jsonrpc, method, params, result (+16 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.16
Nodes (5): Bool, Data, String, UInt8, TerminalEmulator

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.12
Nodes (11): PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Data, Double, String, TerminalEmulator (+3 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.32
Nodes (4): TerminalDamage, MetalRendererTests, MTLTexture, RenderColor

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.15
Nodes (3): KittyKeyboardTests, String, UInt8

### Community 14 - "VTParser"
Cohesion: 0.07
Nodes (24): CSIParams, State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate (+16 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.14
Nodes (8): HarnessTerminalSurfaceView, CGFloat, CGRect, NSEvent, NSPoint, Range, String, UInt16

### Community 17 - "MetalRendererTests"
Cohesion: 0.10
Nodes (13): DisplayWidth, String, Unicode, Run, Data, ReleaseNotes, String, TerminalBanner (+5 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.10
Nodes (13): HarnessUILibrary, Type a string of text into the focused element via osascript keystroke., Get cols x rows from active terminal via stty., Send raw keys to active terminal surface., Send :ex command via CLI., Hover over tab pill at given index (AppleScript)., Click the Sync/Fetch button in Git panel., Launch Harness app. env: 'preview' (debug) or 'staging' (release+isolated). (+5 more)

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.09
Nodes (17): NSDraggingInfo, NSDragOperation, HarnessTerminalSurfaceView, Any, Bool, CGFloat, NSEvent, NSMenu (+9 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.15
Nodes (12): SplitPaneCoordinator, Bool, PaneID, PaneNode, SessionCoordinator, SessionID, SplitDirection, String (+4 more)

### Community 24 - ".request"
Cohesion: 0.10
Nodes (14): ConcurrentIndexSet, DaemonContentionTests, SubscriptionBox, String, URL, DaemonRoundTripTests, Data, Int32 (+6 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.27
Nodes (5): WorktreeManager, String, URL, UUID, WorktreeIsolationDaemonTests

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.06
Nodes (37): 10. Status line, mouse, and options, 11. Shell integration, 12. Agent notifications, 13. Out-of-box troubleshooting, 14. One-page cheat sheet, 1. Five-minute setup, 2. Mental model, 3. Prefix key (+29 more)

### Community 27 - "RGBColor"
Cohesion: 0.23
Nodes (11): ANSIPalette, CellColorResolver, MochaTheme, ResolvedCellColors, RGBColor, Bool, Double, String (+3 more)

### Community 30 - "Notification"
Cohesion: 0.13
Nodes (5): ContentAreaViewController, Bool, CGFloat, TabID, Notification

### Community 31 - "Sendable"
Cohesion: 0.27
Nodes (14): Codable, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserSnapshot, BufferSummary, HookEntry, IPCResponse (+6 more)

### Community 32 - ".addTab"
Cohesion: 0.08
Nodes (8): SessionEditor, Phase67Tests, SessionEditorTests, SessionPersistenceTests, Bool, String, TabID, URL

### Community 33 - "Equatable"
Cohesion: 0.08
Nodes (29): BlockSelection, CursorRender, CursorStyle, bar, block, underline, FrameBuilder, FrameImage (+21 more)

### Community 34 - "DaemonClient"
Cohesion: 0.19
Nodes (4): HarnessCLI, Bool, String, UUID

### Community 35 - "MenuTarget"
Cohesion: 0.23
Nodes (8): MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, String, NSMenuDelegate

### Community 37 - "String"
Cohesion: 0.25
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 39 - "TerminalColorGamut"
Cohesion: 0.31
Nodes (7): RenderColor, RenderColorConversion, RenderColorConverter, Float, RGBColor, SIMD4, SIMD3

### Community 40 - "HarnessSettings"
Cohesion: 0.14
Nodes (17): HarnessSettings, ResizeOverlayMode, afterFirst, always, never, ResizeOverlayPosition, bottomRight, center (+9 more)

### Community 41 - "CodingKeys"
Cohesion: 0.06
Nodes (32): CodingKeys, error, id, jsonrpc, method, params, JSONRPCId, int (+24 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.09
Nodes (8): DispatchWorkItem, UnsafeMutableRawPointer, HarnessSidebarPanelViewController, NSMenuItem, NSView, String, SessionSnapshot, SidebarTitlebarHeaderView

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.15
Nodes (5): RenderScheduler, Bool, Void, RenderSchedulerTests, Bool

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.12
Nodes (10): ChromeBackdrop, HarnessDesign, HarnessOverlayBackground, RuntimeGlassEffectView, Bool, CGRect, NSColor, NSPoint (+2 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.05
Nodes (32): NSCursor, HarnessTerminalSurfaceView, PendingMainHop, PresentAttempt, encodeFailure, nilDrawable, presented, SurfaceColorProviderState (+24 more)

### Community 46 - ".buildCommand"
Cohesion: 0.33
Nodes (6): invalidArgument, missingArgument, CommandParser, Command, Set, String

### Community 47 - ".normalizedKey"
Cohesion: 0.25
Nodes (4): ControlKeyNormalizer, Bool, String, ControlKeyNormalizerTests

### Community 48 - "HookEvent"
Cohesion: 0.13
Nodes (14): Executor, Hook, HookEvent, HookRegistry, Bool, Command, URL, UUID (+6 more)

### Community 49 - "DaemonServer"
Cohesion: 0.15
Nodes (21): CHarnessSys, ClientRecord, CountBox, DaemonServer, PendingBrowserRequest, PendingWrite, CheckedContinuation, Data (+13 more)

### Community 51 - ".keyEvent"
Cohesion: 0.28
Nodes (5): SpecialKeyMappingTests, Bool, NSEvent, String, UInt16

### Community 54 - "HarnessSplitView"
Cohesion: 0.07
Nodes (17): CornerInfo, HarnessSplitView, PaneDragGripView, PaneHoverButton, PaneSplitButtonsView, DispatchWorkItem, Double, NSButton (+9 more)

### Community 55 - "TabCell"
Cohesion: 0.15
Nodes (9): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+1 more)

### Community 56 - "NSPanel"
Cohesion: 0.13
Nodes (13): DirectoryItemRow, DirectoryPanel, DirectoryPickerController, DirectoryPickerFooter, DirectoryPickerModel, DirectoryPickerView, DirectoryWindowDelegate, String (+5 more)

### Community 57 - "BellScanState"
Cohesion: 0.14
Nodes (6): Bool, Date, String, SurfaceID, TabID, WorkspaceID

### Community 58 - "PasteBufferStore"
Cohesion: 0.15
Nodes (10): Buffer, Configuration, PasteBufferStore, Bool, Data, Date, String, URL (+2 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.06
Nodes (32): 1. ภาพรวมสถาปัตยกรรม (Architecture Overview), ✅ 2.1 `sidebarRows` คำนวณซ้ำ O(N²) ทุกครั้งที่ reload ตาราง — DONE, ⚠️ 2.2 Blocking IPC บน Main Thread — PENDING (P2), ✅ 2.3 การ scan แบบ triple-nested ต่อ sync — DONE, ✅ 2.4 `applyThemeToAllHosts()` ทำงานทุก non-metadata sync — DONE, ✅ 2.5 Split view double-layout เมื่อ switch tab — DONE, ✅ 2.6 Metadata refresh probe ทุก tab ทุก 2 วินาที — DONE, 2. ปัญหาและแนวทางแก้ไข (Issues & Fixes) (+24 more)

### Community 60 - "ViEngine"
Cohesion: 0.05
Nodes (48): AgentBridge, AgentTarget, Bool, String, SurfaceID, LinePos, end, firstNonBlank (+40 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 62 - "ComposedCell"
Cohesion: 0.16
Nodes (14): ComposedCell, ComposedFrame, CompositorPane, GridCompositor, Bool, FormatColor, PaneRect, String (+6 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.13
Nodes (16): CLIInstallLocator, DetachKeys, absent, invalid, parsed, HarnessCLI, OptionalUUID, absent (+8 more)

### Community 64 - ".text"
Cohesion: 0.15
Nodes (7): RenderedFixture, Bool, StaticString, String, TerminalGridSnapshot, UInt, UInt8

### Community 65 - "PrefixKeymap"
Cohesion: 0.19
Nodes (4): PrefixKeymap, Any, NSEvent, TimeInterval

### Community 66 - "ShellIntegration"
Cohesion: 0.14
Nodes (9): InstallResult, Shell, bash, fish, zsh, Bool, URL, ShellIntegrationTests (+1 more)

### Community 67 - "String"
Cohesion: 0.14
Nodes (13): InstallResult, Profile, Shell, bash, fish, zsh, ShellProfileInstaller, Bool (+5 more)

### Community 69 - ".compose"
Cohesion: 0.20
Nodes (10): DemoSession, DemoTerminalView, GridCanvas, Bool, CGFloat, String, StyledSegment, TerminalGridCell (+2 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.16
Nodes (11): String, LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed, serverNotExecutable, Int32 (+3 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.15
Nodes (7): ImportedTerminalConfig, Bool, Double, Float, String, TerminalConfigImporter, TerminalConfigImporterTests

### Community 73 - "README.md"
Cohesion: 0.08
Nodes (17): Codex → Harness, One-line install, What you'll see, Cursor Agent → Harness, Manual fallback, One-line install, What you'll see, Hermes → Harness (+9 more)

### Community 75 - "OptionStore"
Cohesion: 0.11
Nodes (19): OptionStore, OptionStore.Value, Scope, global, pane, session, tab, workspace (+11 more)

### Community 76 - ".parse"
Cohesion: 0.17
Nodes (4): SessionSnapshot, String, UUID, TargetSpecTests

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.07
Nodes (21): SurfaceProgressTracker, Bool, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void, State (+13 more)

### Community 79 - "HarnessDesign"
Cohesion: 0.07
Nodes (32): AgentChipView, BoardColumnKind, ChromeRole, sidebar, tabBar, Divider, FontSize, HarnessMotion (+24 more)

### Community 80 - "Agent handbook — Harness (extended reference)"
Cohesion: 0.08
Nodes (21): Build / Test / Run, Graphify, graphify, harness-terminal — Claude Instructions, Non-obvious Constraints, Session Start, Skills, Agent handbook — Harness (extended reference) (+13 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.14
Nodes (20): DaemonSubscription, Bool, Data, UnsafeMutableRawPointer, sysClose(), sysRead(), Bool, DaemonClientTests (+12 more)

### Community 82 - ".firstMatch"
Cohesion: 0.14
Nodes (16): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+8 more)

### Community 83 - "LSPClient"
Cohesion: 0.17
Nodes (10): Result, AsyncCLIResultBox, HarnessCLI, LSPDefinitionPayload, LSPDiagnosticsPayload, LSPStatusPayload, Error, String (+2 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.15
Nodes (12): LSPDiagnostic, LSPDiagnosticSeverity, error, hint, information, warning, LSPHover, LSPLocation (+4 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.10
Nodes (25): Bool, UInt8, TerminalCellWidth, normal, spacerTail, wide, TerminalCursor, TerminalCursorShape (+17 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.09
Nodes (13): SessionCoordinator, Bool, Double, Error, PaneID, PaneNode, SessionID, SplitDirection (+5 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 89 - ".cursorPos"
Cohesion: 0.10
Nodes (16): DetachedPaneOverlay, Style, detached, reconnectingChip, Bool, CGFloat, FormatColor, HarnessSettings (+8 more)

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.08
Nodes (25): 10. Universal retire-hold via `removeFromSuperview()` override (definitive), 11. NSEvent local monitor installed in AppDelegate (fix #8 actually deployed), 12. `nonisolated` + `MainActor.assumeIsolated` on high-frequency AppKit callbacks (2026-06-21), 1. `TerminalPaneRegistry.retire()` — deferred dealloc (500ms), 2. Remove `nonisolated` from all layout overrides, 3. Remove `MainActor.assumeIsolated` from callbacks, 4. Detach NSHostingView on teardown (FileTreeSwiftUIView), 5. Avoid `Optional.map {}` in @MainActor code (+17 more)

### Community 91 - "TerminalModes"
Cohesion: 0.22
Nodes (10): InputEncoder, KeyEventType, press, release, `repeat`, KeyModifiers, SpecialKey, Character (+2 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.08
Nodes (25): code:swift (// DaemonSessionService.swift), code:swift (// ต้องคงเป็น sync เพราะเรียกก่อน process exit), code:swift (// ปัจจุบัน: DispatchQueue.global + DispatchQueue.main.async), code:text (1. DaemonClientActor (new file, ไม่ break อะไร)), code:text (Before:), code:swift (// DaemonClientActor.swift (new)), code:swift (func fetchSnapshot() async throws -> SessionSnapshot {), code:swift (// Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonClient) (+17 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.20
Nodes (8): C, AttachInputBatcher, Outcome, Bool, Data, UInt8, AttachInputBatcherTests, UInt8

### Community 96 - "Harness Usage"
Cohesion: 0.17
Nodes (12): 1. Install Harness, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Harness Usage, More Docs (+4 more)

### Community 97 - "PaneContainerView"
Cohesion: 0.08
Nodes (18): AnyObject, TimeInterval, ZombieHoldRegistry, HitTestPassthroughView, PaneContainerView, NSPoint, NSView, SessionSnapshot (+10 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.67
Nodes (3): 4.1 Architecture Pattern, 4. Technical Architecture, 4.2 Technology Stack

### Community 99 - ".dispatch"
Cohesion: 0.14
Nodes (11): DisplayMessage, MainExecutor, RunShell, Bool, Command, MainActor, PaneID, PaneNode (+3 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.15
Nodes (10): PluginLoader, String, ScriptHookCoordinator, Bool, String, NSView, String, TimeInterval (+2 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.10
Nodes (20): 1. Add Project Group Heuristics, 1. Keep Split State In Session/Tab Structure, 2. Introduce Sidebar Row Model, 2. UX Entry Points, 3. Build Grouped Rows From Filtered Sessions, 4. Update Table Data Source and Delegate, 5. Drag and Drop Rules, code:text (Window) (+12 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.18
Nodes (8): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, URL

### Community 103 - "AnyCodable"
Cohesion: 0.25
Nodes (6): AnyCodable, JSONRPCError, Bool, Int32, String, ToolRegistry

### Community 104 - "Recipe"
Cohesion: 0.16
Nodes (9): AttributedString, NSColor, Recipe, RecipesStore, Bool, String, URL, UUID (+1 more)

### Community 105 - "Changelog"
Cohesion: 0.11
Nodes (4): TerminalModes, InputEncoderTests, String, UInt8

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.12
Nodes (11): AgentNotchPresentation, closed, open, peek, AgentNotchViewModel, AgentNotchWindowActivator, Bool, CGFloat (+3 more)

### Community 108 - ".resolve"
Cohesion: 0.17
Nodes (17): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, PaneLeaf, PaneNode (+9 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.16
Nodes (3): DamageTrackingTests, IndexSet, TerminalEmulator

### Community 110 - "SoftIconButton"
Cohesion: 0.12
Nodes (12): HarnessPillButton, Kind, primary, secondary, SoftIconButton, NSButton, NSCoder, NSEvent (+4 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.16
Nodes (12): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, SessionSnapshot, String, Tab (+4 more)

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.13
Nodes (9): HarnessGridTerminal, Bool, Data, String, TerminalEmulator, TerminalGridCell, TerminalGridSnapshot, UInt8 (+1 more)

### Community 115 - ".encode"
Cohesion: 0.10
Nodes (20): header, DecodedReplyFrame, output, reply, DecodedRequestFrame, input, request, FrameError (+12 more)

### Community 116 - "SessionGroup"
Cohesion: 0.23
Nodes (10): Array, SessionGroup, SessionSnapshot, Bool, Decoder, SessionID, String, Tab (+2 more)

### Community 117 - "PaneNode"
Cohesion: 0.12
Nodes (21): CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf, PaneNode (+13 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.11
Nodes (17): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, FileTreeContext, Bool (+9 more)

### Community 119 - "Harness command reference"
Cohesion: 0.12
Nodes (16): Attaching from a plain terminal, Bindings, Buffers (paste store), Composition, Harness command reference, Hooks, Inspection (CLI / control mode), Local diagnostics (+8 more)

### Community 122 - "ViEngine"
Cohesion: 0.08
Nodes (23): FlippedView, GitPanelView, GitResult, RepoEntry, Any, Bool, escaping, MainActor (+15 more)

### Community 123 - "Pipe"
Cohesion: 0.17
Nodes (16): RepoGitMetadata, SidebarListModel, SidebarSessionRow, divider, groupHeader, session, worktree, worktreeHeader (+8 more)

### Community 124 - "String"
Cohesion: 0.05
Nodes (36): Never, Set, String, Task, URL, Void, WorkspaceSymbolIndex, NSRegularExpression (+28 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.12
Nodes (9): ContiguousArray, IteratorProtocol, HistoryRingBuffer, Iterator, Bool, Element, S, Sequence (+1 more)

### Community 126 - ".path"
Cohesion: 0.08
Nodes (25): AgentArt, AgentMark, AgentMarkShape, AgentVectorIcon, Scanner, SVGPath, Bool, CGFloat (+17 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.10
Nodes (21): Hashable, Modifiers, UInt8, AtlasEntry, ClusterGlyphKey, GlyphAtlas, GlyphAtlasStats, GlyphKey (+13 more)

### Community 129 - "SwiftUI"
Cohesion: 0.16
Nodes (13): ColorHexRow, PaletteCell, SettingsColorsView, Bool, String, WritableKeyPath, SettingsModel, Any (+5 more)

### Community 130 - "Harness"
Cohesion: 0.11
Nodes (17): code:bash (harness-cli doctor), AI Browser Control (harness-mcp), Build From Source, CLI, Development Builds, Documentation, Editor & LSP, Harness (+9 more)

### Community 131 - ".install"
Cohesion: 0.16
Nodes (5): Data, hooks, AgentHookInstallerTests, String, URL

### Community 132 - "AgentHookInstaller"
Cohesion: 0.19
Nodes (8): AgentHookInstaller, InstallResult, Any, Bool, String, URL, result, AgentKind

### Community 133 - ".load"
Cohesion: 0.22
Nodes (7): KeybindingsStore, URL, KeybindingsStoreTests, URL, Void, HarnessCLI, String

### Community 135 - "CommandTarget"
Cohesion: 0.12
Nodes (17): CommandIPCTranslator, CommandTarget, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID (+9 more)

### Community 136 - ".startWatching"
Cohesion: 0.26
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 137 - "ActivePaneService"
Cohesion: 0.08
Nodes (15): ActivePaneService, Bool, PaneID, PaneNode, SessionCoordinator, Set, SurfaceID, Tab (+7 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.67
Nodes (3): Future User Stories (Post-MVP), MVP User Stories (Must Implement), User Story Mapping (MANDATORY)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.11
Nodes (18): 1.1 โครงสร้างการทำงานของ Quick Look (Quick Look Architecture), 1.2 สองคลาสหลักในการใช้งาน (QLPreviewPanel vs. QLPreviewView), 1. เบื้องหลังการทำงานของระบบพรีวิวบน macOS (Under the Hood: macOS Quick Look), 2. การกำหนดลำดับขั้นการคัดแยกประเภทไฟล์ (File Routing Model), 3. แผนการแบ่งแทร็กการพัฒนา (Development Tracks), 4.1 ตัวจัดการควบคุมกลยุทธ์การพรีวิว (File Preview Strategy Protocol), 4.2 คอนโทรลเลอร์แสดงผลไฟล์หลัก (FileViewerViewController), 4.3 ตัวพรีวิวเนทีฟด้วย Quick Look (macOSQuickLookStrategy) (+10 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.27
Nodes (7): CopyModeGridSource, CopyModeReducer, Bool, Character, Range, String, GridPosition

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.10
Nodes (19): 1. Find the CLI, 2. Check daemon health, 3. List what's running (like `tmux ls`), 4. Attach to a pane, 5. Create sessions/tabs from a script, 6. Drive a pane without attaching, 7. tmux control mode, 8. Remote/headless daemon (+11 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.15
Nodes (9): Int32, String, TimeInterval, UInt16, UInt64, UUID, Void, T (+1 more)

### Community 145 - "AsciiFastPathTests"
Cohesion: 0.18
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 146 - "DecodedImage"
Cohesion: 0.10
Nodes (8): CGImage, DecodedImage, ImageLimits, Bool, UInt8, ImageDecoder, Data, HarnessTerminalSurfaceDragDropTests

### Community 147 - "FileTreeWatcher"
Cohesion: 0.37
Nodes (3): FileTreeWatcher, FileTreeWatcherTests, URL

### Community 148 - "TriState"
Cohesion: 0.20
Nodes (9): SettingsTerminalView, Bool, String, TriState, auto, off, on, Typography (+1 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.23
Nodes (6): EnvironmentStore, Persisted, String, URL, EnvironmentStoreTests, URL

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.11
Nodes (13): Decodable, HarnessMCP, HarnessBrowserToolsTests, URL, HarnessDaemonToolsTests, String, URL, Document (+5 more)

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.13
Nodes (13): PaletteWindowDelegate, RecipeItemRow, RecipePanel, RecipePickerController, RecipePickerFooter, RecipePickerModel, RecipePickerView, RecipeWindowDelegate (+5 more)

### Community 154 - "LiveResizeTests"
Cohesion: 0.16
Nodes (3): LiveResizeTests, HarnessTerminalSurfaceView, NSWindow

### Community 155 - "Int"
Cohesion: 0.07
Nodes (36): Equatable, TerminalGridSnapshot, ImagePlacementSnapshot, SemanticMark, Bool, String, UInt8, TerminalCellWidth (+28 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.05
Nodes (24): AgentListFormatter, Date, String, cols, Range, String, TerminalGridCell, TerminalBufferMatch (+16 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.12
Nodes (15): Architecture, Branch, Build & Preview, CMUX Pane Splitting, code:block1 (worktree-feature+acp-aidlc), code:bash (cd /tmp/hp  # symlink to worktree (socket path length limit)), code:block3 (HarnessSidebarPanelViewController — Sessions / Files / Git t), Features (+7 more)

### Community 159 - "MatchCategory"
Cohesion: 0.15
Nodes (15): FileTreeScanOptions, MatchCategory, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith, filenameStartsWith, fuzzy (+7 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.27
Nodes (6): AmbientBackground, Bool, CGSize, GraphicsContext, TimeInterval, UInt8

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.21
Nodes (10): DaemonClient, HarnessCLI, String, HarnessCLI, SessionGroup, SessionSnapshot, String, UUID (+2 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.06
Nodes (20): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel, NSSearchFieldDelegate, Bool (+12 more)

### Community 163 - "Workspace"
Cohesion: 0.27
Nodes (9): sessions, Decoder, SessionGroup, SessionID, String, Tab, TabID, WorkspaceID (+1 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.15
Nodes (10): CommandPromptController, KeyablePanel, Bool, NSControl, NSPanel, NSTextView, Selector, String (+2 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.12
Nodes (12): ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy, SessionLifecycleService, NSWindow (+4 more)

### Community 166 - "LiveSession"
Cohesion: 0.13
Nodes (14): pipe, termios, AttachClient, Configuration, LiveSession, Bool, Data, DispatchSourceSignal (+6 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.06
Nodes (21): AgentDetector, AgentTable, AgentTableEntry, Bool, Date, Int32, Set, String (+13 more)

### Community 170 - "URLDetection"
Cohesion: 0.13
Nodes (5): Bool, Range, String, URLDetection, StringProtocol

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.26
Nodes (5): Case, ReflowCorpusTests, String, TerminalEmulator, URL

### Community 173 - "BoardCard"
Cohesion: 0.12
Nodes (12): KeyRecorderRepresentable, String, Void, OverlayBackground, Context, AgentStatusDot, Context, OverlayBackground (+4 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.16
Nodes (13): SidebarBadgeLabel, SidebarDividerRow, SidebarGroupHeaderRow, SidebarSessionItemRow, SidebarSessionListView, SidebarWorktreeHeaderRow, BoardColumnKind, Bool (+5 more)

### Community 177 - ".rects"
Cohesion: 0.22
Nodes (4): PaneRectSolverTests, Bool, PaneNode, PaneRect

### Community 178 - "InlineAICompletionView"
Cohesion: 0.11
Nodes (13): InlineAICompletionController, HarnessSettings, String, InlineAICompletionView, Bool, NSCoder, NSEvent, NSRect (+5 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.18
Nodes (8): BrowserIntegrationController, NSView, PaneID, NSCoder, PaneID, PaneNode, SplitDirection, String

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.20
Nodes (3): String, TerminalGridSnapshot, VTConformanceCorpusTests

### Community 181 - "GridCompositorTests"
Cohesion: 0.18
Nodes (5): CompositorPane, GridCompositorTests, Bool, String, TerminalGridSnapshot

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.14
Nodes (14): Already portable or mostly portable, Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), First Implementation Slice, macOS-specific today, Non-goals (+6 more)

### Community 183 - "LSPServerRegistry"
Cohesion: 0.17
Nodes (9): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, String, URL, LSPServerRegistryTests, String (+1 more)

### Community 184 - "targets"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Harness, Sparkle (+13 more)

### Community 185 - "SessionSnapshot"
Cohesion: 0.29
Nodes (7): SessionSnapshot, SurfaceSummary, Bool, Date, Decoder, String, WorkspaceID

### Community 186 - "Error"
Cohesion: 0.10
Nodes (20): CustomStringConvertible, Error, InstallError, unsupported, DaemonClientError, connectionFailed, timeout, unexpectedResponse (+12 more)

### Community 187 - "AppDelegate"
Cohesion: 0.19
Nodes (8): AppDelegate, QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL, NSApplication, NSApplicationDelegate

### Community 188 - "BrowserPaneView"
Cohesion: 0.20
Nodes (7): BrowserPaneView, BrowserProgressLine, NSLayoutConstraint, NSStackView, NSTextField, Selector, String

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.12
Nodes (16): Architecture, Bounded Contexts, code:block1 (Agent Process (Claude Code / Codex / Gemini)), code:block2 (Packages/HarnessCore/Sources/HarnessCore/ACP/), code:block3 (Content-Length: 123\r\n), Estimate, Goal, Key Files (New) (+8 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.12
Nodes (10): ScriptError, evaluationError, unsupportedPlatform, ScriptRuntime, Any, String, URL, JSContext (+2 more)

### Community 192 - "GlyphRasterizer"
Cohesion: 0.08
Nodes (23): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, RasterizedGlyph, ShapedGlyph, ShapedRunCacheStats, ShapedRunKey, Bool (+15 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.20
Nodes (6): DetectionStatus, found, notFound, willInstall, BinaryInstaller.DetectionStatus, URL

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.11
Nodes (17): Agent Detection, Branch Detection Flow, Branch Label, Chrome Roles, Drag Reorder, File, Files, Git Branch Detection (+9 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.17
Nodes (7): ResizeHUDView, DispatchWorkItem, NSCoder, NSColor, NSPoint, NSRect, TimeInterval

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.14
Nodes (13): ACP (Agent Client Protocol) — tried, shelved, erased, Command Palette / Power-User Terminal Features, Embedded Browser, Feature Provenance — harness-terminal, Git Panel, Harness MCP, IDE Track — File Tree / Editor / LSP (the "Zed half" made real), Notifications (+5 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.23
Nodes (8): agentDetail(), AgentInboxBody, AgentInboxPanelView, AgentInboxRowView, CGFloat, NSCoder, String, Void

### Community 198 - ".classify"
Cohesion: 0.16
Nodes (12): GridCompositor, Configuration, SessionID, SessionSnapshot, Tab, TabID, WorkspaceID, TabSelector (+4 more)

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.14
Nodes (16): BinaryInstaller, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, InstallError, missingBundledTools, InstallReport (+8 more)

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.12
Nodes (16): Agent Config Wiring, Agents, Architecture, Browser Pane, File I/O, Git, Key Files, MCP Server (harness-mcp) (+8 more)

### Community 202 - "PaletteModel"
Cohesion: 0.10
Nodes (24): String, CommandPaletteController, PaletteAction, PaletteCommandConfig, PaletteFileEntry, PaletteFooter, PaletteGrepMatch, PaletteItemRow (+16 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Harness keybindings, Key spec syntax, Persistence (+1 more)

### Community 204 - "From tmux"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Harness the default terminal, Migrating to Harness

### Community 205 - "CopyModeState"
Cohesion: 0.10
Nodes (20): CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect, beginSearchEntry (+12 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.25
Nodes (6): BinaryRefresher, Bool, URL, BinaryRefresherTests, String, URL

### Community 207 - "scheduleRender"
Cohesion: 0.12
Nodes (9): HarnessTerminalSurfaceView, Bool, CAMetalDrawable, NSEvent, RGBColor, String, HarnessTerminalSurfaceView, CGFloat (+1 more)

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.18
Nodes (5): SessionID, GroupedSessionTests, SessionGroup, Set, SurfaceID

### Community 209 - "SettingsRemoteView"
Cohesion: 0.20
Nodes (6): RemoteHost, RemoteHost, SettingsRemoteView, Bool, RemoteHost, String

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.09
Nodes (18): PaneDragController, Any, Bool, NSEvent, NSView, NSWindow, PaneID, PaneDropZoneOverlay (+10 more)

### Community 211 - "PaneTarget"
Cohesion: 0.13
Nodes (19): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+11 more)

### Community 212 - ".translate"
Cohesion: 0.16
Nodes (5): CommandIPCTranslatorTests, Bool, CommandTarget, PaneID, TabID

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.21
Nodes (8): NotchGeometry, NSScreen, NotchLayoutMetrics, NotchRect, NotchScreenMetrics, Bool, Double, NotchLayoutMetricsTests

### Community 215 - ".lines"
Cohesion: 0.16
Nodes (11): Motion, CAMediaTimingFunction, HarnessOnboarding, Bool, ImmersiveOnboardingWindowController, ImmersivePanel, ImmersiveRootView, Any (+3 more)

### Community 217 - "GridCompositor"
Cohesion: 0.13
Nodes (19): CopyModeMatch, ColorKind, bg, fg, underline, CompositorPane, GridCompositor, RenderCell (+11 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.20
Nodes (8): ScrollbackFile, Bool, Data, DispatchWorkItem, URL, ScrollbackFileTests, String, URL

### Community 219 - "Prompt"
Cohesion: 0.15
Nodes (14): code:block1 (Refactor `Tools/harness/Sources/HarnessCLI/HarnessCLI.swift`), code:block2 (Extract pure input-routing logic from `Tools/harness/Sources), code:block3, code:block4, code:block5 (Decompose `Packages/HarnessDaemon/Sources/HarnessDaemon/Surf), code:block6, code:block7, code:block8 (+6 more)

### Community 220 - "Section"
Cohesion: 0.18
Nodes (6): ReleaseNotes, ReleaseNotes, Section, String, ReleaseNotesGuardTests, String

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.30
Nodes (7): Bool, NSPasteboard, NSString, String, URL, TerminalServicesProvider, AutoreleasingUnsafeMutablePointer

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.10
Nodes (21): AgentNotchDashboardProjection, AgentNotchProjection, AgentNotchRowSummary, RowKind, agent, session, Date, SessionGroup (+13 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.48
Nodes (3): ANSIPalette, RGBColor, UInt8

### Community 224 - "CellColorResolver"
Cohesion: 0.28
Nodes (8): ANSIPalette, CellColorResolver, ResolvedCellColors, Bool, Double, RGBColor, TerminalGridCell, TerminalGridColor

### Community 226 - "FileChangeWatcher"
Cohesion: 0.24
Nodes (6): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.18
Nodes (4): SSHTunnelManagerTests, RemoteHost, String, URL

### Community 229 - ".decide"
Cohesion: 0.33
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.15
Nodes (4): HarnessGridTerminalTests, HarnessGridTerminal, String, TerminalGridSnapshot

### Community 231 - "ExternalOpenKind"
Cohesion: 0.11
Nodes (14): ExternalOpenKind, filePreview, terminal, theme, InstallChoice, cancel, install, installAndApply (+6 more)

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.11
Nodes (17): 1. Add a `pendingReflowTask` field to `TerminalScreen`, 2. Split `reflow(toCols:rows:)` into two helpers, 3. In `resize(cols:rows:)`, use the fast path first, Background, code:swift (// In TerminalScreen), code:swift (// Fast path — reflow only viewport + lookahead), code:swift (mutating func resize(cols nc: Int, rows nr: Int) {), code:swift (// TerminalEmulator: add a "live resize in progress" flag) (+9 more)

### Community 233 - "TextGrid"
Cohesion: 0.19
Nodes (6): HarnessPaths, SessionStore, DispatchWorkItem, SessionSnapshot, TimeInterval, URL

### Community 234 - ".scan"
Cohesion: 0.29
Nodes (3): BellScanTests, Bool, UInt8

### Community 235 - "WorkbenchCommand"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 238 - ".make"
Cohesion: 0.16
Nodes (6): DefaultTerminalLaunchRequest, ShellQuoting, Bool, String, URL, DefaultTerminalLaunchRequestTests

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.11
Nodes (33): MTLClearColor, MTLCommandBuffer, MTLRenderCommandEncoder, TerminalFrame, BgInstance, CursorCacheKey, DecoInstance, EncodedFrameInstances (+25 more)

### Community 240 - "PaneBorderStatus"
Cohesion: 0.17
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, Bool, Double (+3 more)

### Community 242 - "AgentBridge"
Cohesion: 0.20
Nodes (11): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, failed, DefaultTerminalStatus, Bool, String, URL (+3 more)

### Community 243 - ".make"
Cohesion: 0.16
Nodes (9): ShellLaunchProfileTests, SurfaceRegistryTests, PaneID, SessionID, SessionSnapshot, String, SurfaceID, TabID (+1 more)

### Community 244 - "FileNode"
Cohesion: 0.14
Nodes (11): FileNode, Bool, String, BranchSwitchHelper, FileTreeNode, FileTreeSwiftUIView, Notification.Name, NSMenuItem (+3 more)

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.20
Nodes (7): Data, ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 246 - "Experience modes"
Cohesion: 0.29
Nodes (7): 1. Plain Terminal, 2. Persistent Terminal, 3. Full Terminal, 4. Agent Workspace, Experience modes, Opting into the prefix + status line without switching modes, Persistence (ephemeral vs. persistent)

### Community 247 - "FormatContextDaemonTests"
Cohesion: 0.16
Nodes (13): BoxDrawing, Kind, arms, dashH, dashV, halfDown, halfLeft, halfRight (+5 more)

### Community 248 - "DaemonMetrics"
Cohesion: 0.23
Nodes (7): DaemonMetrics, Snapshot, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.31
Nodes (3): ReflowPreviewTests, String, TerminalEmulator

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.33
Nodes (3): HarnessTerminalSurfaceWorkerTests, Bool, HarnessTerminalSurfaceView

### Community 251 - "SessionCoordinator"
Cohesion: 0.23
Nodes (5): SessionCoordinator, Bool, String, SurfaceID, TimeInterval

### Community 252 - "NSViewRepresentable"
Cohesion: 0.14
Nodes (9): KeyRecorderView, Any, Bool, NSCoder, NSEvent, NSPoint, String, Void (+1 more)

### Community 253 - "Split Right"
Cohesion: 0.14
Nodes (11): MTLLibrary, MTLRenderPipelineState, ImageTextureCache, MTLDevice, MTLTexture, UInt8, CGFloat, MTLBuffer (+3 more)

### Community 254 - "BoardViewController"
Cohesion: 0.05
Nodes (33): BoardCardView, BoardViewController, FlippedView, Bool, NSCoder, Set, TabID, Void (+25 more)

### Community 255 - "release-hotfix.sh"
Cohesion: 0.42
Nodes (7): plist_set(), require_clean_tracked_worktree(), run(), release-hotfix.sh script, update_readme_download(), usage(), write_release_notes()

### Community 256 - "GitMetadataProvider"
Cohesion: 0.25
Nodes (5): CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.13
Nodes (14): 1. @MainActor + Task + Process.waitUntilExit = FREEZE (RL-052), 2. @Observable + mutation in body = infinite re-render loop (RL-053), 3. Re-entrancy guard on rebuildRows, 4. Worktree display rules, Architecture, chromeEpoch — force SwiftUI re-render from static state, Critical Lessons (bugs fixed), File tree: root at git root, expand on CWD change (+6 more)

### Community 258 - "WindowTitleStripView"
Cohesion: 0.14
Nodes (8): Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint, NSRect, WindowTitleStripView

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.13
Nodes (14): Architecture, Browser Auto-Retry (P24 Phase 4), Browser Pane (P14), BUG: Tab close button never fired (CASE-055 extended), BUG: Tab close button unresponsive (gesture conflict), CASE: applyLocalSnapshot re-injected closed browser panes (v2.7.1), CASE: collapsed errorBanner intercepted toolbar clicks (v2.7.1), Click-to-open localhost/LAN dev-server links (+6 more)

### Community 262 - ".install"
Cohesion: 0.18
Nodes (11): InstallError, daemonNotFound, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, Bool, Int32 (+3 more)

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.17
Nodes (6): HarnessSidebarPanelViewController, CGFloat, NSMenuItem, NSView, SessionGroup, String

### Community 266 - ".path"
Cohesion: 0.23
Nodes (8): Scanner, SVGPathParser, Bool, CGPath, CGPoint, Character, Set, CGMutablePath

### Community 269 - "DefaultTerminalManager"
Cohesion: 0.11
Nodes (17): 1.1 Architecture, 1.2 Algorithm review, 1.3 Structure findings, 2.1 Structure, 2.2 Risk register (ranked), 3.1 Current implementation, 3.2 Why nothing shows (ranked root-cause candidates), 3.3 Fix plan (+9 more)

### Community 270 - "WindowSession"
Cohesion: 0.09
Nodes (15): PaneBorderStatus, Bool, Command, CommandTarget, Data, DispatchWorkItem, HarnessGridTerminal, PaneID (+7 more)

### Community 271 - "StatusLineView.swift"
Cohesion: 0.13
Nodes (14): StatusLineView, CGFloat, FormatColor, Never, NSAttributedString, NSCoder, NSColor, NSLayoutConstraint (+6 more)

### Community 272 - "SGRMouseEvent"
Cohesion: 0.10
Nodes (13): SGRMouse, SGRMouseEvent, Bool, PaneRect, S, UInt8, MouseEventKind, drag (+5 more)

### Community 273 - "KeySpec"
Cohesion: 0.09
Nodes (19): KeySpec, Decoder, String, Binding, CodingKeys, bindings, disabledSpecs, id (+11 more)

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.22
Nodes (9): Group, ParsedShortcut, PrefixCheatsheetWindow, PrefixIndicatorWindow, CGFloat, NSTextField, NSView, NSWindow (+1 more)

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.13
Nodes (15): Context, Non-goals, P8: macOS 27 Golden Gate Adoption, Phase 0 — Swift 6.3+ Concurrency Safety (P0, LESSONS FROM macOS 26.5 CRASH SAGA), Phase 1 — Compatibility (P0), Phase 2 — Quick Wins (P1), Phase 3 — NSTextSelectionManager (P1), Phase 4 — Gesture Recognizer Migration (P2) (+7 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.10
Nodes (17): DiffLineType, added, deleted, modified, Notification.Name, Bool, NSCoder, NSEvent (+9 more)

### Community 277 - ".run"
Cohesion: 0.20
Nodes (11): ControlModeClient, ControlModeError, daemon, noMatch, noSnapshot, unresolved, Command, Data (+3 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.26
Nodes (8): BlockTintOverlay, Bool, CGFloat, HarnessTerminalSurfaceView, NSCoder, NSEvent, NSPoint, NSRect

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.27
Nodes (6): DisplayPanesOverlay, Any, NSEvent, NSView, SurfaceID, Void

### Community 280 - ".menu"
Cohesion: 0.18
Nodes (11): LayoutFileStore, LayoutNode, branch, leaf, LayoutTemplate, Date, Double, PaneNode (+3 more)

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.16
Nodes (9): Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSPoint, NSRect, TimeInterval (+1 more)

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.20
Nodes (3): RemoteHostStoreTests, String, URL

### Community 283 - "FormatColor"
Cohesion: 0.29
Nodes (8): FormatColor, none, palette, rgb, StyledSegment, Bool, String, UInt8

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.08
Nodes (24): After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md., After all done — update memory, Agent Prompt — P14 Browser Pane (PBI-001 through 005), Before writing any code, read:, code:swift (public struct BrowserLeaf: Codable, Sendable, Equatable {), code:swift (case let .browser(bl):), code:swift (// action: SplitPaneCoordinator openBrowserPane(url: URL(str), code:block4 (harnessBrowserOpen(url, direction?) → {paneId}) (+16 more)

### Community 288 - "AgentHookStrategy"
Cohesion: 0.11
Nodes (11): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, ownJSONFile, ownTextFile, regionEdit, Any, Bool (+3 more)

### Community 289 - "StatusLineWidthTests"
Cohesion: 0.18
Nodes (5): HarnessCLI, StatusLineWidthTests, StatusLineWidth, String, StyledSegment

### Community 290 - "Process"
Cohesion: 0.17
Nodes (14): Process, SSHTunnelError, exitedEarly, invalidConfiguration, launchFailed, notReady, SSHTunnelManager, Bool (+6 more)

### Community 292 - "Release runbook"
Cohesion: 0.33
Nodes (5): Local release path, One-time GitHub setup, Release runbook, Running a release from GitHub, What the workflow publishes

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.14
Nodes (13): 1. Data / Geometry Separation (primary fix), 2. SnapshotCoalescer (cmux NotificationBurstCoalescer pattern), 3. Equality Guard on updateGeometry (Zed pattern), 4. Dirty Flag on setFrame (Otty/WezTerm pattern), 5. GPU Animation — CAShapeLayer Mask (Zed/Otty GPU path), 6. AgentScanner timer split, Files, Fixes Applied (layered) (+5 more)

### Community 294 - "GitHubCLIClient"
Cohesion: 0.18
Nodes (14): ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient, PRInfo (+6 more)

### Community 295 - "AgentApprovalBar"
Cohesion: 0.11
Nodes (14): AgentApprovalBar, ApprovalBarAction, hide, noop, show, NSColor, Bool, NSButton (+6 more)

### Community 296 - "NotificationBus"
Cohesion: 0.13
Nodes (13): string, AgentNotification, OSCNotificationParser, DaemonSurfaceID, Data, Date, String, SurfaceID (+5 more)

### Community 297 - "settings.json"
Cohesion: 0.11
Nodes (9): ScriptConfigLocator, Bool, String, ProjectTask, ProjectTaskDetector, String, Foundation, JavaScriptCore (+1 more)

### Community 298 - "jobs"
Cohesion: 0.11
Nodes (4): HarnessApp, FilePreviewCoordinatorTabScopeTests, NSView, GitPanelViewFSEventFilterTests

### Community 299 - "PaneNode"
Cohesion: 0.14
Nodes (17): PaneBorderStatus, bottom, off, top, PaneLeaf, PaneNode, branch, leaf (+9 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.28
Nodes (11): atomicWrite(), backupCorruptFile(), fnv1aHex(), HarnessPathsError, socketPathTooLong, Bool, Data, String (+3 more)

### Community 301 - ".parse"
Cohesion: 0.19
Nodes (8): HookNotificationParser, Parsed, Any, Data, String, HookNotificationParserTests, Data, String

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.24
Nodes (4): RGBColor, String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 303 - ".encodeMouse"
Cohesion: 0.25
Nodes (8): MouseButton, left, middle, right, wheelDown, wheelLeft, wheelRight, wheelUp

### Community 305 - ".script"
Cohesion: 0.22
Nodes (3): CompletionGenerator, String, CompletionGeneratorTests

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.17
Nodes (4): String, RegressionBugFixTests, SessionSnapshot, Tab

### Community 308 - "Send Ex Command"
Cohesion: 0.31
Nodes (5): HarnessSidebarPanelViewController, NSMenu, NSMenuItem, SessionGroup, SessionID

### Community 309 - "Browser DevTools API (P28)"
Cohesion: 0.15
Nodes (12): Architecture, Browser DevTools API (P28), Config, Key Bug Fixed: Round-Trip Timeout (RL-048), Key Files, Phase 1 — Core (all via evaluateJS or WKWebView native), Phase 2 — Network, Phase 3 — Storage (+4 more)

### Community 310 - "FrameSignposter"
Cohesion: 0.21
Nodes (8): Logger, OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, Bool, UInt64

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.15
Nodes (12): Bug: Tab-Switch Black Screen, Files changed, Final fast-path guard (PaneLifecycleManager.swift), FM-1: detachHostsOnly() before caching (always broken), FM-2: force=true rebuild caches the stripped container, FM-3: Host theft by another tab's build, FM-4: Cache overwrite leaks orphan containers, Instrumentation method (+4 more)

### Community 312 - "AgentSnapshot"
Cohesion: 0.12
Nodes (14): Reason, errored, finished, needsInput, RowState, Bool, Comparable, AgentActivity (+6 more)

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.17
Nodes (11): ACP vs MCP vs Terminal Chat, AgentProcessManager, Architecture, CLI Print-Mode Args, Context Injection, Key Files, Key Shortcuts (I-family), Non-Obvious Constraints (+3 more)

### Community 317 - "Memory — harness-terminal"
Cohesion: 0.13
Nodes (15): 2026-06-27 — Block output tint + AI explain (Phase 12b), Active Context, Active Decisions, Architecture Notes, Completed Sprints, Conventions, Current Sprint — ACP Client & Git Polish (post-v2.0.0), Current Sprint — IDE-like Sidebar (PBI-001) (+7 more)

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.17
Nodes (11): 1. `SessionLifecycleService.swift` (tab bar clicks, sidebar clicks), 2. `MainExecutor.swift` (keyboard shortcuts — the actual user path), Competitive research (from Agy), Data model (correct, no changes needed), Files to read before resuming, Fix applied (compiles, not fully tested), Focus Persistence — Per-Session-Tab Pane Focus (RL-043), Restoration flow (after fix) (+3 more)

### Community 321 - "UInt64"
Cohesion: 0.17
Nodes (5): HookFiringTests, NSObjectProtocol, String, URL, XCTestExpectation

### Community 323 - "LayoutNode"
Cohesion: 0.28
Nodes (5): HarnessCLI, Bool, Int32, Never, String

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.11
Nodes (5): SurfaceID, TerminalPaneRegistryAccess, HarnessTerminalKit, DaemonReconnectPolicy, DaemonReconnectPolicyTests

### Community 325 - "FloatingPaneController"
Cohesion: 0.17
Nodes (12): AgentRow, HookState, failed, idle, installed, installing, SettingsAgentsView, Bool (+4 more)

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.11
Nodes (6): DaemonBrowserRoutingTests, String, URL, EndpointClientTests, String, URL

### Community 327 - ".theme"
Cohesion: 0.09
Nodes (8): HarnessThemeCatalog, String, HarnessThemeDefinition, Bool, RGBColor, String, ANSIPaletteTests, HarnessThemeCatalogTests

### Community 328 - "README.md"
Cohesion: 0.36
Nodes (3): Install, Shell integration (OSC 133 semantic prompts), What gets emitted

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 330 - ".drawGlyph"
Cohesion: 0.23
Nodes (11): CellMetrics, CellMetrics, ComposedTerminalView, Bool, CellColorResolver, CGFloat, CGPoint, GraphicsContext (+3 more)

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.14
Nodes (11): keys, ITerm2InlineImage, Bool, String, UInt8, KittyGraphicsCommand, Bool, Character (+3 more)

### Community 333 - "RealPty"
Cohesion: 0.08
Nodes (21): PtyError, launchFailed, RealPty, ScrollbackEntry, ScrollbackReplaySegment, ShellLaunchProfile, Bool, CChar (+13 more)

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.30
Nodes (3): ImageProtocolTests, String, TerminalEmulator

### Community 336 - "run.sh"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 337 - "CommandExecutionError"
Cohesion: 0.12
Nodes (13): AnyObject, ScriptAPI, KeybindingsService, Bool, Command, String, CommandExecutionError, daemonError (+5 more)

### Community 338 - "CSIParams"
Cohesion: 0.11
Nodes (21): BrowserCookie, BrowserRequestPayload, close, cookies, evaluate, goBack, goForward, interact (+13 more)

### Community 339 - "Foundation"
Cohesion: 0.13
Nodes (15): AppKit, CoreGraphics, CoreText, HarnessCopyMode, HarnessTerminalEngine, HarnessTerminalRenderer, HarnessTheme, ImageIO (+7 more)

### Community 342 - "Added"
Cohesion: 0.13
Nodes (11): ExperienceMode, agent, full, persistent, plain, Bool, NotchVisibilityMode, automatic (+3 more)

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.27
Nodes (3): HarnessSettingsTests, URL, Void

### Community 344 - "FileViewerViewController"
Cohesion: 0.11
Nodes (15): FileViewerViewController, Bool, NSEvent, Set, String, URL, Void, LSPFileSession (+7 more)

### Community 346 - "Agent platform icons"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 348 - "DaemonLifecycleTests"
Cohesion: 0.09
Nodes (19): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+11 more)

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.18
Nodes (10): 1. SurfaceShellTracker (proc tree walk), 2. DaemonSyncService.startMetadataRefresh (5-s loop), 3. snapshotChanged Fanout, 4. PerfCounters — Instrumentation, 5. Performance Lessons (v3.2.0), Adaptive polling, Background Polling & Snapshot Fanout — P22, Known Non-P22 Callers of syncFromDaemon (+2 more)

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.18
Nodes (10): AI / Agent Connectivity, Architecture Decisions — harness-terminal, Browser Pane, Config / Settings, File Preview / Split Panes, IPC / Daemon, Keybindings, Sessions / Tabs (+2 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.18
Nodes (10): Cause 1 — `existingHosts` strong dict in TerminalPaneRegistry (DOMINANT), Cause 2 — Insert-only AI controller dicts in SessionCoordinator, Cause 3 — Uncapped browser network capture array, Memory Leak Audit — 34 GB Long-Session Case (2026-06-26), Pattern to watch: "insert-only per-surface dict", Release, Root causes found and fixed, Symptom (+2 more)

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.18
Nodes (10): Burst Coalescing (cmux NotificationBurstCoalescer), CA Mask Pattern (Harness Notch), Combine → CA Bridge, Equality Guard (Zed layout phase), GPU Animation Pattern — Layout Once, GPU Paints, Layer Coordinate System, Principle, References (+2 more)

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.22
Nodes (8): 1. Performance Optimization: Scrollback Reflow ($O(\text{history})$ Complexity), 2. convenient Features: Local completion & completion Gutter, 3. IDE Convenient: Keyboard-driven Layout Presets, 4. AI integration: Secure Local ACP Sidebar, Additional features shipped alongside:, Context, Implementation Status (2026-06-11), P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)

### Community 355 - ".deepMerge"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.25
Nodes (5): Bool, HarnessCLI, Bool, String, URL

### Community 357 - ".handleCat"
Cohesion: 0.18
Nodes (5): String, WorkspaceID, ProjectConfig, Bool, String

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.43
Nodes (3): AboutPanelController, AboutView, NSWindow

### Community 359 - "OcclusionTests"
Cohesion: 0.36
Nodes (5): OcclusionTests, HarnessTerminalSurfaceView, NSWindow, String, TimeInterval

### Community 360 - "State"
Cohesion: 0.19
Nodes (8): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus, UserNotifications

### Community 362 - "RGBColor"
Cohesion: 0.24
Nodes (7): RGBColor, Bool, Decoder, Double, Encoder, String, UInt8

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.25
Nodes (5): BrowserTab, URL, UUID, WKWebView, tabs

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.23
Nodes (4): Bool, String, TimeInterval, WorktreeInfo

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.20
Nodes (9): 1. Sidebar toggle (⌘\), 2. File preview open/close, 3. Tab switch (⌘1-9, ✕ close), 4. presentsWithTransaction order fix (ALL remaining flash cases) — v3.9.x+, Fixes Applied (v3.9.1+), Related Lessons, Root Cause Pattern, Rules (+1 more)

### Community 366 - "Consumers"
Cohesion: 0.20
Nodes (9): 1. Board Sidebar Tab (GUI), 2. Harness CLI Command, 3. Scripting API, 4. Read-Only MCP Tool, Agent/Session Board (P16), Centralized Classification, Consumers, Data Model (PBI-BOARD-001) (+1 more)

### Community 367 - "DaemonStats"
Cohesion: 0.16
Nodes (9): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+1 more)

### Community 368 - "Tab"
Cohesion: 0.15
Nodes (15): Array, Bool, Date, Decoder, PaneID, PaneNode, String, TabID (+7 more)

### Community 369 - "Git Panel"
Cohesion: 0.20
Nodes (9): Architecture, Branch chip — CASE-020, Features, FSEvents Pattern (Swift Actor), Git Panel, History → File Editor, Real-time Refresh, v1 — CASE-009 (resolved, superseded) (+1 more)

### Community 370 - ".encode"
Cohesion: 0.21
Nodes (4): NotificationCenterProbe, Bool, Void, NotificationCenterProbeTests

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.17
Nodes (11): Architecture, code:block1 (PaneNode (existing binary tree)), Current State, Estimate, Goal, P13 — Embedded Browser Pane (cmux parity), PBI-BROWSER-001: BrowserPaneView + PaneNode integration, PBI-BROWSER-002: Persistence (+3 more)

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 373 - "Prompt"
Cohesion: 0.21
Nodes (12): code:block1 (Add a visual session state indicator to sidebar session card), code:block2 (Add keyboard-driven layout presets to the Harness terminal a), code:block3 (Add workspace-scoped local completion (autocomplete) to the ), code:block4, Context, P10 Implementation Prompts — For Agent Execution, Prompt, Task #1: CMUX Session State Indicator in Sidebar (+4 more)

### Community 374 - ".run"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 375 - ".install"
Cohesion: 0.31
Nodes (4): CLIInstaller, Bool, String, URL

### Community 376 - "ScrollReuseTests"
Cohesion: 0.47
Nodes (3): ScrollReuseTests, HarnessTerminalSurfaceView, NSWindow

### Community 377 - "Identifiable"
Cohesion: 0.13
Nodes (11): CompleteStepView, Void, OnboardingStep, complete, discover, setup, shell, welcome (+3 more)

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.22
Nodes (4): Date, String, TerminalBlock, TerminalBlockStore

### Community 379 - "MCPServer"
Cohesion: 0.22
Nodes (5): BrowserPaneRegistry, NSWindow, PaneID, WeakBrowserPaneView, WebKit

### Community 380 - "PromptQueue"
Cohesion: 0.13
Nodes (5): PromptQueue, String, SurfaceID, Void, Float

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.29
Nodes (3): Bool, String, ThaiClusterRenderTests

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.40
Nodes (9): attribute_lines(), main(), redraw_frames(), repeated_chunk(), run_case(), sgr_lines(), truecolor_gradient(), unicode_lines() (+1 more)

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.22
Nodes (8): Detection Method, Fix, NSTextField Leak in BoardViewController (P20 Performance), Prevention Rules, Related Files, Root Cause, Symptom, Why CPU Goes Up

### Community 385 - "INDEX.md"
Cohesion: 0.18
Nodes (7): Agent Memory Index — harness-terminal, Navigation, Knowledge Index, Case Index, Grep Command, Open Cases, Playbook — harness-terminal

### Community 387 - "User Profile"
Cohesion: 0.29
Nodes (6): Architecture Preferences, Domain Expertise, Identity, Project Scope, User Profile, Workflow Preferences

### Community 388 - "Darwin"
Cohesion: 0.44
Nodes (3): HarnessCLI, SessionID, String

### Community 389 - "HarnessCLITests"
Cohesion: 0.16
Nodes (11): HarnessCLITests, URL, HarnessCLI, HarnessFilePreviewLoader, HarnessViewError, binaryOrUnsupportedEncoding, missingPath, tooLarge (+3 more)

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.22
Nodes (8): Accessibility Requirements, Files, Permission, Running, Stack, Test Strategy, UI Automation — Robot Framework (P18), Why Not Appium

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.22
Nodes (8): AppKit + Metal Patterns, CADisplayLink Lifetime on macOS (CASE-031), Metal Surface Lifecycle (CASE-003), Mouse Selection Must Use Virtual-Line Coordinates (CASE-029), NSFont Italic (CASE-010), NSView Layer Opacity — Preview Parity Pattern (CASE-011), Overlay Above Metal (CASE-004), Window Background Tint for Legibility (CASE-027)

### Community 402 - "View"
Cohesion: 0.09
Nodes (33): Color, MonoPillButtonStyle, Configuration, Configuration, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, ButtonStyle, CommandRow (+25 more)

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.22
Nodes (8): Architecture, Infinite Recursion (CASE-006), Pane Drag-and-Drop (P27), Ratio Persistence (CASE-002), Split CWD Resolution — Worktree Priority (2026-06-21), Split Panes (NSSplitView), Subview Reorder (CASE-007), Two-Axis Split Parity (P13)

### Community 405 - ".measure"
Cohesion: 0.37
Nodes (7): ConfigError, unsupportedAgent, writeFailure, MCPConfigWriter, Any, String, URL

### Community 408 - "IPC Architecture"
Cohesion: 0.25
Nodes (7): Framing, IPC Architecture, Key Invariant, Overview, Process Separation, Security, Subscriptions

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.25
Nodes (7): ⌘1-9 and ⌘[ / ⌘] = Session-level navigation (CASE-028), Data Model, Session/Tab/Pane Hierarchy & Top Bar (CASE-028), Sidebar Session Groups = One Header Per SessionGroup, Source Map, Tab Pill Visual Details, Top Bar = 1 Pill Per Session (not per-tab)

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.10
Nodes (19): Agent Prompt — Harness Terminal UI Fixes, code:block1 (▶ harness-terminal), code:block2 (▼ harness-terminal  ● Running), code:swift (urlTextField.setContentHuggingPriority(.defaultLow, for: .ho), code:swift (let bv = BrowserPaneView(url: bl.url, paneID: bl.id)), code:bash (cd /Users/supavit.cho/Git/Personal/harness-terminal), code:bash (git add -A), Commit (+11 more)

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.24
Nodes (3): ShortcutRecorderSerializer, String, ShortcutRecorderSerializerTests

### Community 422 - "HintModeOverlay"
Cohesion: 0.24
Nodes (6): HintModeOverlay, Any, HarnessTerminalSurfaceView, NSEvent, NSView, String

### Community 423 - "CopyModeLine"
Cohesion: 0.32
Nodes (4): CopyModeLine, Character, ClosedRange, String

### Community 424 - "HarnessCore"
Cohesion: 0.10
Nodes (14): HarnessCore, HarnessDaemonCore, IPCCodecInvariantTests, FormatContextDaemonTests, PaneID, SessionSnapshot, String, SurfaceID (+6 more)

### Community 425 - "AgentVectorIcon"
Cohesion: 0.47
Nodes (5): AgentIconArt, AgentVectorIcon, Bool, CGSize, String

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.25
Nodes (7): Bug — Cmd+\ sidebar toggle gone after collapse, Confirmed facts, Fix, Related, Suspect A — Dead token guard (confirmed code bug), Suspect B — Zero-delta early exit trap, Symptom

### Community 427 - ".delay"
Cohesion: 0.24
Nodes (7): LaunchdServiceInstaller, ServiceInstaller, ServiceInstallers, ServiceInstallReport, Bool, String, URL

### Community 428 - "P9: Code Complexity Reduction & Structural Refactoring"
Cohesion: 0.18
Nodes (10): 1. HarnessTerminalSurfaceView (~2,320 LOC), 2. HarnessCLI.swift (~1,841 LOC), 3. WindowAttachClient (~1,566 LOC), 4. SurfaceRegistry (~1,848 LOC), 5. GridCompositor Duplication, Context, Execution Order, Execution Status (2026-06-11) (+2 more)

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.25
Nodes (7): Case: cwd "bleed" — session worktree jumps to wrong dir during builds, Companion bug: blank panel on first open (CASE-042), Fix, Lesson, Repro (deterministic, headless — no GUI needed), Root cause, Symptom

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.25
Nodes (7): Competitive Position (as of v3.12.0, 2026-07-02), Feature Matrix (2026-07-02), Harness Gaps, Harness Wins, Known Limitations (honest assessment), Positioning Statement, Unique Selling Points (no competitor has all)

### Community 431 - "P6: File Editor Opacity Parity with Terminal"
Cohesion: 0.22
Nodes (8): Actual Fix (2026-06-09), code:swift (panel.layer?.backgroundColor = c.terminalBackground), code:swift (private func refreshEditorPanelFill() {), Fix Approach, P6: File Editor Opacity Parity with Terminal, Problem, Root Cause (hypothesis), Status

### Community 432 - ".initialState"
Cohesion: 0.20
Nodes (4): CopyModeReducerTests, FakeGrid, String, TerminalGridCell

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.24
Nodes (7): Container, NotchPulseHost, Content, Context, NSCoder, NSHostingView, NSRect

### Community 434 - "Project History"
Cohesion: 0.25
Nodes (7): Apple Platform Context — Transparency & Legibility, Architecture Decisions, iOS/macOS 26 — Liquid Glass introduction, iOS/macOS 27 — Liquid Glass refinements (WWDC 2026), Known Issues (Current), Project History, Sprint Timeline

### Community 435 - ".highlight"
Cohesion: 0.15
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 436 - "WaitForRegistry"
Cohesion: 0.28
Nodes (7): ignoreSIGPIPE(), Channel, Bool, Int32, String, WaitForRegistry, WaitForRegistryTests

### Community 437 - "Feature Specs"
Cohesion: 0.25
Nodes (8): F1: Mobile Package Targets — P0, F2: Network Endpoint for IPC — P0, F3: Pairing and Trust — P0, F4: UIKit Terminal Surface — P0, F5: iPad Workspace UX — P1, F6: Remote Session Lifecycle — P1, F7: Files and Sharing — P2, Feature Specs

### Community 438 - "SessionEditor"
Cohesion: 0.10
Nodes (13): IndexingIterator, LayoutTemplate, Command, Double, PaneID, PaneLeaf, PaneNode, SplitDirection (+5 more)

### Community 439 - "ACP Client"
Cohesion: 0.29
Nodes (7): ACP Client, Architecture, code:block1 (AgentChatPanelView (AppKit UI)), Key Files, Protocol, Shelved Status (June 2025), Tool Call Handling

### Community 440 - "Implementation Phases"
Cohesion: 0.25
Nodes (8): Implementation Phases, Phase 0 — Feasibility Spike (P0), Phase 1 — Shared Renderer Extraction (P0), Phase 2 — Mobile IPC Transport (P0), Phase 3 — UIKit Terminal MVP (P0), Phase 4 — iPad App Shell (P1), Phase 5 — Multiplexer Parity (P1), Phase 6 — Polish and Platform Integration (P2)

### Community 441 - "RemoteHostStore"
Cohesion: 0.25
Nodes (6): MutationResult, RemoteHost, RemoteHostStore, Bool, String, T

### Community 443 - "AgentIconRenderer"
Cohesion: 0.55
Nodes (5): AgentIconRenderer, CGFloat, NSColor, NSImage, String

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.36
Nodes (3): BlockContextMenuTests, HarnessTerminalSurfaceView, String

### Community 445 - "Section"
Cohesion: 0.20
Nodes (10): Section, actions, errors, files, grep, navigation, projects, recent (+2 more)

### Community 448 - "NSSplitView Patterns"
Cohesion: 0.40
Nodes (5): code:swift (private var isApplyingPositions = false), Infinite Recursion Guard (CASE-006), Key Invariants, NSSplitView Patterns, Safe Subview Reorder (CASE-007)

### Community 449 - ".run"
Cohesion: 0.20
Nodes (9): InterruptFlag, ReplayClient, ReplayPlayer, Bool, Data, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 450 - "RecordSession"
Cohesion: 0.18
Nodes (11): RecordClient, RecordingWriter, RecordSession, Summary, Bool, Data, DispatchSourceSignal, FileHandle (+3 more)

### Community 451 - "FormatContext"
Cohesion: 0.23
Nodes (6): CaseIterable, Mode, compatible, harness, TerminalIdentity, TerminalIdentityTests

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Harness-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 453 - ".handleViMode"
Cohesion: 0.28
Nodes (6): HarnessTerminalSurfaceView, Bool, NSEvent, ViInputMode, insert, normal

### Community 455 - "ComposerPanel"
Cohesion: 0.17
Nodes (10): center, ComposerPanel, Bool, NSEvent, NSTextView, NSWindow, Selector, String (+2 more)

### Community 457 - "StartupMetrics"
Cohesion: 0.16
Nodes (14): Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow, launchStart, StartupMetrics (+6 more)

### Community 459 - ".encode"
Cohesion: 0.19
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 461 - "PaneLabelDaemonTests"
Cohesion: 0.28
Nodes (4): PaneLabelDaemonTests, String, URL, UUID

### Community 462 - "AGENTS.md"
Cohesion: 0.13
Nodes (13): Architecture, Build & test, Coding constraints, Communication: GUI ↔ Daemon ↔ CLI, Generated files (do not hand-edit), Graphify + agent-memory, IPC safety, Package map (+5 more)

### Community 465 - "RecordingEvent"
Cohesion: 0.15
Nodes (10): RecordingEvent, input, metadata, output, resize, Date, Decoder, Encoder (+2 more)

### Community 466 - "ReflowFastPathTests"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, String, TerminalEmulator

### Community 467 - "─────────────────────────────────────────────────────"
Cohesion: 0.12
Nodes (15): ─────────────────────────────────────────────────────, Agent Prompt — P14 PBI-BROWSER-001 + 002, BrowserPaneView shell + PaneNode integration, code:swift (public struct BrowserLeaf: Codable, Sendable, Equatable {), code:swift (case let .browser(browserLeaf):), code:block3 (feat(p14): PBI-BROWSER-001/002 — BrowserPaneView + PaneNode ), Constraints, ContentAreaViewController.swift — PaneContainerView.build() (+7 more)

### Community 473 - "HarnessOnboarding"
Cohesion: 0.15
Nodes (9): GridCompositorParityTests, LiveCompositorFixture, Bool, String, TerminalGridSnapshot, PortCompositorFixture, Bool, String (+1 more)

### Community 476 - ".steps"
Cohesion: 0.24
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 478 - ".install"
Cohesion: 0.42
Nodes (6): InstallResult, ShellCompletionInstaller, Bool, String, URL, ShellIntegration

### Community 479 - "ScrollbackTests"
Cohesion: 0.17
Nodes (4): ScrollbackTests, Character, String, TerminalGridSnapshot

### Community 480 - "Command Prompt Architecture"
Cohesion: 0.29
Nodes (6): Command Prompt Architecture, Files, Gotchas, Key rule: every documented verb needs BOTH layers, Layers, Verb categories

### Community 490 - "P7: Sidebar UI Polish — Large Screen Layout"
Cohesion: 0.40
Nodes (4): Fix Approach, P7: Sidebar UI Polish — Large Screen Layout, Problems, Status

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.29
Nodes (6): Anti-Patterns Avoided, Architecture, Key Design Decisions, Pattern, Service Decomposition — SessionCoordinator (P17), When to Apply This Pattern

### Community 493 - "Browser Tab Close Button Unresponsive"
Cohesion: 0.29
Nodes (6): Browser Tab Close Button Unresponsive, Files, Fix Applied, If Fix Is Insufficient, Root Cause, Symptom

### Community 495 - "terminal-cheat-sheet.html"
Cohesion: 0.33
Nodes (4): KeyRecorderViewTests, NSEvent, String, UInt16

### Community 496 - "CASE — Git / FS / Terminal / Architecture"
Cohesion: 0.29
Nodes (6): Architecture / Keybindings, CASE — Git / FS / Terminal / Architecture, Claude Code / Tooling / Environment (the agent running *inside* Harness), Command Prompt / Parser, Git / File System, Terminal / Renderer / Daemon

### Community 498 - "SystemdUserInstaller"
Cohesion: 0.19
Nodes (6): Bool, Int32, String, URL, SystemdUserInstaller, ServiceInstallerTests

### Community 499 - "release.yml"
Cohesion: 0.25
Nodes (8): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces

### Community 502 - "ACP Client (Shelved)"
Cohesion: 0.29
Nodes (6): ACP Client (Shelved), Architecture (Preserved), Re-enablement Criteria, Status: SHELVED (June 2026), What It Is, Why Shelved

### Community 503 - "Build Scripts Self-Kill Protection"
Cohesion: 0.29
Nodes (6): Build Scripts Self-Kill Protection, Detection, Fix (applied in `Scripts/run.sh`), Key Invariant, Problem, Related

### Community 506 - "KittyGraphicsCommand"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 507 - "ThaiClusterCopyTests.swift"
Cohesion: 0.42
Nodes (5): PaneOutputWaiter, PaneOutputWaitResult, CheckedContinuation, Never, UInt64

### Community 509 - "start.mjs"
Cohesion: 0.70
Nodes (4): main(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 510 - "graphify reference: extra exports and benchmark"
Cohesion: 0.29
Nodes (6): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Carbon

### Community 511 - "State"
Cohesion: 0.38
Nodes (3): SettingsAdvancedView, Bool, String

### Community 512 - "Changelog Archive"
Cohesion: 0.20
Nodes (11): Command, CommandTarget, PaneID, SessionGroup, SessionSnapshot, Tab, TargetKind, pane (+3 more)

### Community 513 - "ThemeDocument"
Cohesion: 0.17
Nodes (18): Appearance, AppearanceKind, dark, light, Colors, ContrastGrade, high, low (+10 more)

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.16
Nodes (10): WKNavigation, BrowserPaneViewTests, MockWebView, Bool, URL, WKNavigation, WKNavigationAction, WKWebView (+2 more)

### Community 518 - "HarnessDaemonTools"
Cohesion: 0.22
Nodes (6): HarnessDaemonTools, Bool, PaneLeaf, String, Tab, UUID

### Community 521 - "PasteController"
Cohesion: 0.22
Nodes (7): PasteController, Bool, Data, NSPasteboard, String, TimeInterval, URL

### Community 522 - "ShellCompletionInstallerTests"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 526 - "Kind"
Cohesion: 0.18
Nodes (7): Kind, input, metadata, output, resize, String, TerminalRecordingCodec

### Community 527 - "Agent hooks for Harness"
Cohesion: 0.29
Nodes (7): Agent hooks for Harness, CLI notification, Example Claude Code hook, Jump to waiting agent, OSC sequences (from terminal output), Per-agent guides, Set up via your IDE (copy/paste prompt)

### Community 530 - "HarnessChrome"
Cohesion: 0.40
Nodes (6): HarnessChrome, HarnessChromePalette, Bool, CGFloat, NSColor, String

### Community 531 - "UInt32"
Cohesion: 0.11
Nodes (12): UnsafeBufferPointer, TerminalCellWidth, UnsafeBufferPointer, CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable (+4 more)

### Community 534 - "OnboardingEnvironment"
Cohesion: 0.11
Nodes (8): OnboardingController, HarnessOnboarding, Agent, OnboardingEnvironment, Bool, String, BinaryInstallerDisplayTests, OnboardingEnvironmentTests

### Community 535 - "AgentNotification"
Cohesion: 0.40
Nodes (5): FluidityBenchmarks, HarnessTerminalSurfaceView, NSWindow, String, UInt64

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.07
Nodes (21): MainActor, Void, SessionDividerRowView, SessionGroupHeaderRowView, SessionWorktreeHeaderRowView, SessionWorktreeRowView, SidebarBadgeView, BoardColumnKind (+13 more)

### Community 544 - "Task Ledger Archive (Tasks 1–50)"
Cohesion: 0.33
Nodes (4): 2026-06-25 — OSC 7735:  opens sidebar file viewer, Pruned from MEMORY.md — 2026-07-02, Pruned from MEMORY.md — 2026-07-03, Task Ledger Archive (Tasks 1–50)

### Community 546 - "LegacySnapshot"
Cohesion: 0.10
Nodes (14): JSONDecoder, JSONEncoder, LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab (+6 more)

### Community 547 - "NSObject"
Cohesion: 0.13
Nodes (17): ClosureTarget, MenuActionTarget, OverlayWindow, Phase67UI, PopupWindow, Bool, Command, NSEvent (+9 more)

### Community 548 - ".encode"
Cohesion: 0.22
Nodes (6): KeyTokenParser, Bool, Data, String, KeyTokenParserTests, Phase6KeysTests

### Community 550 - "cheat.sh"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 551 - "DesktopNotifier"
Cohesion: 0.26
Nodes (5): DesktopNotifier, Bool, MainActor, String, Void

### Community 552 - "[3.12.0] - 2026-06-30"
Cohesion: 0.27
Nodes (3): HarnessCLI, String, Set

### Community 553 - "harness.resource"
Cohesion: 0.24
Nodes (8): Page, advanced, appearance, colors, remote, terminal, SettingsRootView, String

### Community 557 - "Harness Robot Framework Tests"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Harness Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 558 - "ThemeCatalogEmbedTests"
Cohesion: 0.33
Nodes (3): String, URL, ThemeCatalogEmbedTests

### Community 559 - "FSEvents Recursive Watcher Pattern (Swift)"
Cohesion: 0.33
Nodes (5): Codex Fix Prompt Template, FSEvents Recursive Watcher Pattern (Swift), Full Swift Actor Pattern, Single-file watch (DispatchSource is enough), When to use

### Community 566 - "TerminalTabBarView.swift"
Cohesion: 0.36
Nodes (6): DotView, statusColor(), Bool, Context, NSColor, WorkingDotView

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.09
Nodes (21): CommandHistorySearchController, HistoryItemView, HistoryRowView, SearchPanel, Bool, CGFloat, NSAttributedString, NSCoder (+13 more)

### Community 574 - "CLAUDE.md"
Cohesion: 0.32
Nodes (3): SnapshotCoalescer, MainActor, Void

### Community 576 - "[3.10.0] - 2026-06-27"
Cohesion: 0.36
Nodes (5): ShellInfo, ShellStepView, Bool, String, URL

### Community 578 - "TerminalProgressReport"
Cohesion: 0.24
Nodes (5): Bool, NSObjectProtocol, Set, String, WorktreeAutoIsolateService

### Community 579 - "RL Lessons — harness-terminal"
Cohesion: 0.25
Nodes (7): AppKit / Views, Architecture / Daemon, Browser / WKWebView, Git / Process, RL Lessons — harness-terminal, Swift 6 / Concurrency, Testing / Environment

### Community 580 - "P4 — LSP + File View (Code Preview in Sidebar)"
Cohesion: 0.15
Nodes (15): Architecture, Components, Estimate, Files, Goal, Grammars, Implementation Notes (MVP — plain-text viewer), LSP Discovery (+7 more)

### Community 581 - "[2.2.3] - 2026-06-09"
Cohesion: 0.13
Nodes (15): clamp(), statusHelp(), CGFloat, Date, Range, String, T, Tab (+7 more)

### Community 582 - "FileTreeKeyboardNavigator"
Cohesion: 0.20
Nodes (10): PaneRef, bottom, byID, byIndex, last, left, next, previous (+2 more)

### Community 584 - "ScriptSnapshotModels.swift"
Cohesion: 0.36
Nodes (5): PaneLeaf, SessionGroup, Any, String, Tab

### Community 586 - "[3.8.0] - 2026-06-22"
Cohesion: 0.22
Nodes (7): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, Bool

### Community 587 - "LayoutTemplate"
Cohesion: 0.20
Nodes (6): LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled

### Community 589 - "Endpoint"
Cohesion: 0.12
Nodes (12): os, DaemonSessionError, daemonError, unexpectedResponse, DaemonSessionService, LatencyMonitor, Bool, SessionSnapshot (+4 more)

### Community 591 - "NodeRow"
Cohesion: 0.29
Nodes (3): NodeRow, Bool, String

### Community 594 - "KeyRecorderView.swift"
Cohesion: 0.13
Nodes (13): RawSelection, Bool, TerminalEmulator, SelectionGranularity, character, line, word, RawSelection (+5 more)

### Community 596 - "prepare-release.sh"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 597 - "WrapperOptionBehavior"
Cohesion: 0.28
Nodes (4): GroupedSessionDaemonTests, SessionGroup, String, URL

### Community 598 - ".load"
Cohesion: 0.36
Nodes (4): object, HarnessSettings, Bool, Data

### Community 599 - ".cgPath"
Cohesion: 0.31
Nodes (6): AnimatablePair, NotchShape, CGFloat, CGPath, CGRect, Path

### Community 600 - "HarnessTerminalSurfaceView"
Cohesion: 0.10
Nodes (15): NSRangePointer, NSTextInputClient, HarnessTerminalSurfaceView, Any, Bool, NSAttributedString, NSEvent, NSPoint (+7 more)

### Community 603 - "MenuBarController"
Cohesion: 0.14
Nodes (14): AgentRow, AgentRow, MenuBarController, MenuRef, CGFloat, NSImage, NSMenu, NSMenuItem (+6 more)

### Community 613 - "INDEX.md"
Cohesion: 0.22
Nodes (5): Completed Plans Archive, Active Plans, Completed, Plans Index — harness-terminal, Quick ref — recent completions

### Community 614 - "MainSplitViewController"
Cohesion: 0.12
Nodes (12): MainSplitViewController, SplitChromeDelegate, Bool, CADisplayLink, CGFloat, NSColor, NSRect, NSSplitView (+4 more)

### Community 617 - "ScriptFileWatcher"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 620 - "NSView"
Cohesion: 0.14
Nodes (19): FooterIconButton, RecentProjectsMenuButton, SidebarFooterModel, SidebarFooterView, SidebarSectionLabelView, SidebarSectionModel, SidebarTabBarView, Bool (+11 more)

### Community 621 - "ViEngine"
Cohesion: 0.14
Nodes (5): Bool, String, ViEngine, HarnessLSP, QuickLookUI

### Community 622 - "[1.3.0-vit] - 2026-06-06"
Cohesion: 0.39
Nodes (4): GridCompositorCopyModeTests, PaneRect, String, TerminalGridSnapshot

### Community 623 - ".decodeKeySpec"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 624 - "[2.5.0] - 2026-06-12"
Cohesion: 0.24
Nodes (5): Bool, SessionCoordinator, String, ThemeService, HarnessOptions

### Community 626 - "NotificationCoordinator"
Cohesion: 0.10
Nodes (12): NotificationCoordinator, Bool, Date, SessionCoordinator, SessionSnapshot, Set, String, SurfaceID (+4 more)

### Community 629 - "graphify reference: query, path, explain"
Cohesion: 0.22
Nodes (6): SettingsAppearanceView, SliderRow, Bool, ClosedRange, Double, String

### Community 630 - "[3.0.0] - 2026-06-15"
Cohesion: 0.29
Nodes (7): DiagnosticCheck, DiagnosticStatus, fail, pass, warn, DoctorReport, Int32

### Community 637 - "p12_mcp.robot"
Cohesion: 0.36
Nodes (3): SplitDirection, TabID, TerminalTabBarDelegate

### Community 646 - "[3.10.1] - 2026-06-27"
Cohesion: 0.20
Nodes (10): BrowserResponsePayload, cookies, error, network, ok, open, screenshot, snapshot (+2 more)

### Community 648 - "PtyDrainCeilingBenchmark"
Cohesion: 0.15
Nodes (14): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, DrainState, EchoRTT (+6 more)

### Community 650 - "[3.11.0] - 2026-06-28"
Cohesion: 0.24
Nodes (4): StageToggleButton, NSCoder, NSRect, NSUserInterfaceItemIdentifier

### Community 652 - "TerminalHostView"
Cohesion: 0.14
Nodes (12): InputGate, ReconnectLatch, SurfaceIO, Data, NSPoint, Sendable, SurfaceID, TimeInterval (+4 more)

### Community 655 - "CodingKeys"
Cohesion: 0.25
Nodes (8): CodingKeys, createdAt, dataBase64, rows, surfaceID, timeMs, type, version

### Community 656 - "Proposal: Merging Devin/Windsurf Kanban & CMUX Multiplexer UX into Harness"
Cohesion: 0.29
Nodes (6): 1. Summary of Davin/Windsurf Kanban + CMUX UX, 2.1 Sidebar Sessions Panel Enhancements, 2.2 Per-Session Top Bar / Tab Strip Enhancements, 2. Integration Proposal for Harness, 3. Concrete File-Level Change List, Proposal: Merging Devin/Windsurf Kanban & CMUX Multiplexer UX into Harness

### Community 658 - "[3.1.0] - 2026-06-15"
Cohesion: 0.42
Nodes (5): LoadCompletionState, CheckedContinuation, Error, TimeInterval, Void

### Community 660 - "NotificationEntry"
Cohesion: 0.14
Nodes (9): NotificationDropdownPanelView, NotificationRowView, Bool, CGFloat, NSCoder, NSEvent, NSScrollView, NSTrackingArea (+1 more)

### Community 661 - "Remote SSH — Market Comparison"
Cohesion: 0.33
Nodes (5): Harness vs Competitors (Remote Development over SSH), Our Gaps (vs leaders), Our Strengths, Remote SSH — Market Comparison, Roadmap Opportunities

### Community 662 - "New Tab"
Cohesion: 0.32
Nodes (6): CGFloat, ResizeDirection, down, left, right, up

### Community 663 - "[3.1.2] - 2026-06-16"
Cohesion: 0.28
Nodes (3): BrowserLeaf, URL, PaneNodeBrowserTests

### Community 664 - "CompletionPopupView"
Cohesion: 0.16
Nodes (9): CompletionPopupView, CompletionRowView, Bool, NSCoder, NSEvent, NSRect, NSTrackingArea, String (+1 more)

### Community 665 - "PathToken"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 666 - ".handle"
Cohesion: 0.07
Nodes (20): DaemonCommandExecutor, Command, BellScanState, esc, normal, stringEsc, PanePipe, SurfaceMonitor (+12 more)

### Community 667 - "[3.3.0] - 2026-06-18"
Cohesion: 0.46
Nodes (3): SessionSnapshot, Tab, WorkbenchContextResolverTests

### Community 669 - "[3.9.0] - 2026-06-22"
Cohesion: 0.13
Nodes (11): HarnessPathDisplay, NotificationEntry, NotificationPresenter, SessionID, SurfaceID, TabID, WorkspaceID, UNNotification (+3 more)

### Community 670 - "[3.9.1] - 2026-06-22"
Cohesion: 0.22
Nodes (8): CodingKey, CodingKeys, description, key, showInBanner, LegacyHarnessSettingsCodingKeys, commandFinishedNotifications, tmuxControlsEnabled

### Community 671 - "AgentKind"
Cohesion: 0.30
Nodes (6): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, agents

### Community 672 - "Toggle Sidebar"
Cohesion: 0.36
Nodes (3): NSScrollView, NSTextView, GitPanelViewDiffPopoverTests

### Community 674 - "[3.11.6] - 2026-06-29"
Cohesion: 0.42
Nodes (3): Lexer, Bool, Character

### Community 675 - ".detect"
Cohesion: 0.28
Nodes (7): TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid

### Community 676 - "[2.1.0] - 2026-06-07"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 678 - "FilePreviewCoordinator"
Cohesion: 0.16
Nodes (8): EditorDividerView, NSLayoutConstraint, FilePreviewCoordinator, FileTabID, NSView, Set, SplitDirection, String

### Community 679 - "[3.5.0] - 2026-06-20"
Cohesion: 0.14
Nodes (8): HarnessCommands, HarnessIPC, CommandParseError, emptyInput, expectedCommand, missingFlag, unknownCommand, unterminatedString

### Community 680 - "HarnessCLI+Workbench.swift"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 681 - "Cross-terminal output-stress benchmark"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 682 - "TreeSitterGrammarBundle"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 684 - "[3.9.5] - 2026-06-26"
Cohesion: 0.25
Nodes (7): CodingKeys, activeSessionID, activeTabID, id, name, sortOrder, tabs

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 686 - ".status"
Cohesion: 0.16
Nodes (10): GitStatusType, added, deleted, modified, renamed, unmodified, untracked, GitStatusProvider (+2 more)

### Community 688 - ".hold"
Cohesion: 0.29
Nodes (5): DirectionalAxis, down, left, right, up

### Community 689 - "[1.6.0] - 2026-06-07"
Cohesion: 0.47
Nodes (3): NSCoder, NSHostingView, NSRect

### Community 693 - "[2.0.0] - 2026-06-07"
Cohesion: 0.33
Nodes (5): Claude Code → Harness, Customizing, One-line install, Verifying, What gets written

### Community 694 - "TerminalScreen"
Cohesion: 0.09
Nodes (12): Int, HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor, Bool, ClosedRange (+4 more)

### Community 696 - "generate-release-notes.swift"
Cohesion: 0.60
Nodes (4): CLICommand, CLICommandCatalog, Bool, String

### Community 697 - "[2.1.0] - 2026-06-07"
Cohesion: 0.40
Nodes (3): HarnessGridTerminal, TerminalGridCell, TerminalEmulator

### Community 702 - "OutputTrigger"
Cohesion: 0.15
Nodes (7): OutputTrigger, OutputTriggerStore, Bool, String, StaticString, T, Data

### Community 704 - "harness.fish"
Cohesion: 0.50
Nodes (3): __harness_osc133_postexec, __harness_osc133_preexec, __harness_osc133_prompt

### Community 705 - "[2.3.0] - 2026-06-11"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 707 - "[3.2.0] - 2026-06-16"
Cohesion: 0.40
Nodes (5): Edges, Files, Knowledge Index — Harness Terminal, Search Instructions, Source Map

### Community 708 - "[3.4.0] - 2026-06-19"
Cohesion: 0.40
Nodes (5): Current Sprint — Post-v2.1.0 Polish & Shelving, Decisions_In_Force, Recent_Lessons, Removed / Reverted Features, Task_Ledger

### Community 709 - "ScreenPos"
Cohesion: 0.40
Nodes (5): Build matrix, Integration tests, Manual test checklist, Testing and Verification, Unit tests

### Community 710 - "MainWindowController"
Cohesion: 0.10
Nodes (13): HarnessWindow, NSEvent, MainWindowController, Any, NSRect, CGFloat, NSColor, NSPoint (+5 more)

### Community 711 - "FileTabManager"
Cohesion: 0.19
Nodes (14): FileEditorTabBarBody, FileEditorTabBarModel, FileEditorTabBarView, FileTabPillView, Bool, FileTabID, NSCoder, NSRect (+6 more)

### Community 712 - "LayoutProbeView"
Cohesion: 0.40
Nodes (3): HarnessCLI, String, String

### Community 713 - "HarnessBrowserTools"
Cohesion: 0.28
Nodes (5): HarnessBrowserTools, Bool, Double, String, TimeInterval

### Community 716 - "NotchPanelController"
Cohesion: 0.10
Nodes (12): AnyCancellable, NotchMaskAnimator, Bool, CGFloat, CGRect, NSView, NotchPanel, Bool (+4 more)

### Community 717 - "[3.9.5] - 2026-06-26"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 718 - "[2.4.0] - 2026-06-12"
Cohesion: 0.29
Nodes (4): Darwin, Glibc, HarnessCLI, String

### Community 724 - ".build"
Cohesion: 0.33
Nodes (4): FormatContextBuilder, DaemonSurfaceID, SessionSnapshot, String

### Community 728 - "[2.5.1] - 2026-06-12"
Cohesion: 0.50
Nodes (3): Grok Build → Harness, One-line install, What you'll see

### Community 729 - "[3.13.0] - 2026-07-02"
Cohesion: 0.50
Nodes (3): exclude_hubs, no_viz, wiki

### Community 730 - "Result"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 735 - ".parse"
Cohesion: 0.18
Nodes (5): LSPTextLocation, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 736 - "graphify reference: add a URL and watch a folder"
Cohesion: 0.50
Nodes (3): SplitDirection, horizontal, vertical

### Community 737 - ".resolve"
Cohesion: 0.14
Nodes (11): FileFuzzyMatcher, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool, Character (+3 more)

### Community 739 - "graphify reference: commit hook and native CLAUDE.md integration"
Cohesion: 0.50
Nodes (4): ColorKind, bg, fg, underline

### Community 742 - ".configureEnvironment"
Cohesion: 0.67
Nodes (3): DiscoverStepView, Point, String

### Community 764 - "Workbench commands (IDE-like workflow)"
Cohesion: 0.33
Nodes (6): Board and attention, Errors and LSP, File navigation, Search, Task runner, Workbench commands (IDE-like workflow)

### Community 767 - "DaemonSyncService"
Cohesion: 0.13
Nodes (11): DaemonSyncService, Bool, Never, SessionCoordinator, SessionSnapshot, SurfaceID, Tab, TabID (+3 more)

### Community 771 - "FileEditorView"
Cohesion: 0.12
Nodes (9): String, WorkbenchMRU, FileEditorView, Bool, NSCoder, NSEvent, NSRect, String (+1 more)

### Community 779 - ".userContentController"
Cohesion: 0.13
Nodes (8): BrowserTabButton, Bool, Double, NSCoder, NSEvent, NSRect, WeakScriptMessageHandler, WKScriptMessageHandler

### Community 817 - ".terminalHost"
Cohesion: 0.25
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 841 - "Now"
Cohesion: 0.11
Nodes (17): 2026-07-02 — agy logo color mismatch (preview vs prod) ✅ RESOLVED — not a Harness bug, 2026-07-02 — File preview: selection dropped on background reload + clicking agent tool-call paths failed ✅ FIXED and committed (`587fa906`), 2026-07-02 — File preview tabs leaked across terminal Tabs (global singleton) ✅ FIXED, not committed, 2026-07-02 — Git sidebar panel didn't refresh after external `git commit`/`push` ✅ FIXED, not committed, 2026-07-02 — Near-miss: `git revert --abort` wiped uncommitted session work, 2026-07-02 — P32 `setPaneLabel` MCP tool + P34 right-click block menu ✅ DONE, committed (`1723136`, `965f7b3e`), 2026-07-02 — P34 F1 slice 1: OSC 133 command-boundary + block command-text capture ✅ DONE, committed (`2ca7fbb`), 2026-07-02 — P34 F2 (block actions) + F3 (MCP block access) ✅ DONE, committed (`8049605`) (+9 more)

### Community 1331 - ".compute"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 3120 - "GlassEffectView"
Cohesion: 0.28
Nodes (7): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor, NSView

### Community 3202 - ".write"
Cohesion: 0.09
Nodes (22): Endpoint, EndpointError, connectionFailed, notYetSupported, pathTooLong, String, EndpointConnector, Int32 (+14 more)

### Community 3203 - ".assertAllPathsAgree"
Cohesion: 0.14
Nodes (5): CodepointRunFastPathTests, StaticString, String, UInt, UInt8

### Community 3211 - "TerminalSelection"
Cohesion: 0.23
Nodes (6): CellOverlayTests, HarnessTerminalSurfaceView, IndexSet, NSWindow, String, UInt64

### Community 3379 - "TargetSpec"
Cohesion: 0.18
Nodes (16): SessionRef, byID, byName, next, previous, String, UUID, TargetSpec (+8 more)

### Community 3380 - "skipUnlessLiveDaemonTests"
Cohesion: 0.14
Nodes (15): PendingVersionBanner, welcome, whatsNew, State, Bool, String, URL, VersionBannerStore (+7 more)

### Community 3419 - "Page"
Cohesion: 0.18
Nodes (6): SettingsHostingController, SettingsWindowController, NSCoder, NSWindow, NSAppearance, NSHostingController

## Knowledge Gaps
- **3724 isolated node(s):** `unsupportedPlatform`, `unmodified`, `modified`, `added`, `deleted` (+3719 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **2491 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `AboutView`, `AgentActivity`, `AgentApprovalBar`, `AgentInboxBody`, `AgentInboxPanelView` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `TerminalScreen` to `Changelog Archive`, `ThemeDocument`, `EngineConformanceTests`, `AgentNotchRootView`, `HarnessDaemonTools`, `LSPMessage`, `TerminalEmulator`, `PerformanceBenchmarks`, `GitPanelView.swift`, `PasteController`, `VTParser`, `HarnessTerminalSurfaceView`, `MetalRendererTests`, `HarnessChrome`, `UInt32`, `HarnessTerminalSurfaceView`, `.request`, `SessionGroupHeaderRowView`, `RGBColor`, `Notification`, `Sendable`, `Equatable`, `LegacySnapshot`, `DaemonClient`, `.encode`, `HarnessSettings`, `harness.resource`, `HarnessSidebarPanelViewController.swift`, `CodingKeys`, `RenderSchedulerTests`, `HarnessTerminalSurfaceView.swift`, `.buildCommand`, `DaemonServer`, `HarnessSplitView`, `NSPanel`, `BellScanState`, `CommandHistorySearchController`, `PasteBufferStore`, `ViEngine`, `ComposedCell`, `.text`, `PrefixKeymap`, `[2.2.3] - 2026-06-09`, `FileTreeKeyboardNavigator`, `worktree_isolation_cli.robot`, `.compose`, `ImportedTerminalConfig`, `OptionStore`, `TerminalProtocolCompatibilityTests`, `DaemonSubscription`, `KeyRecorderView.swift`, `LSPClient`, `LSPDiagnostic`, `TerminalGridCell`, `SessionCoordinator`, `HarnessTerminalSurfaceView`, `.cursorPos`, `MenuBarController`, `TerminalModes`, `AttachInputBatcher`, `.testRenderEncodeIncrementalDamage160x48`, `.dispatch`, `MainSplitViewController`, `AnyCodable`, `Changelog`, `AgentNotchViewModel`, `NSView`, `DamageTrackingTests`, `[1.3.0-vit] - 2026-06-06`, `.testBuildShiftedMatchesFullBuildAcrossScrollWalk`, `.makeSnapshot`, `HarnessGridTerminal`, `.decodeKeySpec`, `.encode`, `SessionGroup`, `WorkspaceFileTreeView`, `ViEngine`, `Pipe`, `String`, `p12_mcp.robot`, `.path`, `HistoryRingBuffer`, `GlyphAtlas`, `SwiftUI`, `.write`, `.assertAllPathsAgree`, `AgentHookInstaller`, `.agentJSON`, `[3.10.0] - 2026-06-27`, `CommandTarget`, `PtyDrainCeilingBenchmark`, `ActivePaneService`, `[3.11.0] - 2026-06-28`, `TerminalSelection`, `TerminalHostView`, `CopyModeGridSource`, `AsciiFastPathTests`, `DecodedImage`, `NotificationEntry`, `New Tab`, `HarnessDaemonToolsTests`, `CompletionPopupView`, `What You Must Do When Invoked`, `.handle`, `PathToken`, `ThaiCombiningMarkTests`, `Int`, `MatchCategory`, `Toggle Sidebar`, `[3.11.6] - 2026-06-29`, `Workspace`, `CommandPromptController`, `ActiveTabCloseDisposition`, `FilePreviewCoordinator`, `AgentTableEntry`, `TerminalFindBar`, `HarnessCLI+Workbench.swift`, `URLDetection`, `ReflowCorpusTests`, `[1.5.1] - 2026-06-06`, `BinaryRefresherTests`, `InlineAICompletionView`, `[1.8.0] - 2026-06-07`, `VTConformanceCorpusTests`, `GridCompositorTests`, `.currentSize`, `[2.1.0] - 2026-06-07`, `SessionSnapshot`, `AppDelegate`, `BrowserPaneView`, `ScriptRuntime`, `GlyphRasterizer`, `ResizeHUDView`, `.classify`, `BinaryInstallerVersionTests`, `LayoutProbeView`, `PaletteModel`, `[3.5.0] - 2026-06-20`, `CopyModeState`, `[3.9.5] - 2026-06-26`, `scheduleRender`, `.testDataFrameEncodeVsJSONBase64Output`, `HarnessCLI`, `PaneTarget`, `.translate`, `.build`, `CellColorResolverTests`, `GridCompositor`, `ScrollbackFile`, `AgentNotchRowSummary`, `.parse`, `ANSIPalette`, `.resolve`, `CellColorResolver`, `graphify reference: commit hook and native CLAUDE.md integration`, `HarnessGridTerminalTests`, `graphify reference: incremental update and cluster-only`, `CLAUDE.md`, `extraction-spec.md`, `TerminalMetalRenderer`, `PaneBorderStatus`, `ThemeDocumentTests`, `FormatContextDaemonTests`, `DaemonMetrics`, `skill-trigger.py`, `ReflowPreviewTests`, `SessionCoordinator`, `Split Right`, `BoardViewController`, `DaemonSyncService`, `FileEditorView`, `.welcome`, `.apply`, `.path`, `WindowSession`, `StatusLineView.swift`, `SGRMouseEvent`, `SyntaxTextView`, `.run`, `BlockTintOverlay`, `DisplayPanesOverlay`, `TerminalScrollbarView`, `FormatColor`, `.apply`, `StatusLineWidthTests`, `Process`, `GitHubCLIClient`, `NotificationBus`, `settings.json`, `PaneNode`, `HarnessPaths.swift`, `ThemeDiagnostics`, `.encodeMouse`, `TargetSpec`, `skipUnlessLiveDaemonTests`, `.compute`, `FrameSignposter`, `AgentSnapshot`, `FormatColor`, `LayoutNode`, `WorkspaceSymbolIndex`, `.recordReapedGenerationForTesting`, `RealPty`, `ImageProtocolTests.swift`, `CommandExecutionError`, `CSIParams`, `Foundation`, `FileViewerViewController`, `Page`, `.moveSelection`, `DaemonLifecycleTests`, `SurfaceProgressTracker`, `.clampedBlur`, `generate-cheatsheet.js`, `.init`, `.moveActiveSession`, `.setCellPixelSize`, `DaemonStats`, `Tab`, `DynamicInstanceBuffer`, `.run`, `Identifiable`, `SurfaceProgressTrackerTests.swift`, `PromptQueue`, `ThaiClusterRenderTests`, `.selectAdjacentSession`, `HarnessCLITests`, `.moveActiveSession`, `.cursorBackwardTabs`, `.navigateCurrentFile`, `FilePreviewCoordinatorTabScopeTests`, `HintModeOverlay`, `CopyModeLine`, `.initialState`, `WaitForRegistry`, `SessionEditor`, `.init`, `AgentIconRenderer`, `Section`, `RecordSession`, `FormatContext`, `RecordingEvent`, `ReflowFastPathTests`, `HarnessOnboarding`, `.steps`, `ScrollbackTests`, `ThaiClusterCopyTests.swift`?**
  _High betweenness centrality (0.274) - this node is a cross-community bridge._
- **Why does `HarnessCore` connect `HarnessCore` to `AgentNotchRootView`, `PasteController`, `PerformanceBenchmarks`, `ShellCompletionInstallerTests`, `HarnessSettingsTests.swift`, `MetalRendererTests`, `OnboardingEnvironment`, `SplitPaneCoordinator`, `TabAlertTests`, `SessionGroupHeaderRowView`, `.parse`, `.addTab`, `Equatable`, `LegacySnapshot`, `MenuTarget`, `NSObject`, `.encode`, `DaemonClient`, `TerminalColorGamut`, `[3.12.0] - 2026-06-30`, `harness.resource`, `CodingKeys`, `HarnessTerminalSurfaceView.swift`, `.normalizedKey`, `HookEvent`, `DaemonServer`, `HarnessSplitView`, `TabCell`, `NSPanel`, `CommandHistorySearchController`, `PasteBufferStore`, `ViEngine`, `FrecencyDirectoryStore`, `HarnessCLI+Server.swift`, `TerminalProgressReport`, `ShellIntegration`, `[2.2.3] - 2026-06-09`, `worktree_isolation_cli.robot`, `ImportedTerminalConfig`, `ScriptSnapshotModels.swift`, `.parse`, `TerminalProtocolCompatibilityTests`, `Endpoint`, `HarnessDesign`, `DaemonSubscription`, `.firstMatch`, `LSPClient`, `LSPDiagnostic`, `HarnessPaths`, `MenuBarController`, `AttachInputBatcher`, `PaneContainerView`, `.dispatch`, `ScriptRuntime.swift`, `DaemonLauncher`, `MainSplitViewController`, `Recipe`, `AgentNotchViewModel`, `NSView`, `ViEngine`, `.decodeKeySpec`, `.makeSnapshot`, `NotificationCoordinator`, `WorkspaceFileTreeView`, `ViEngine`, `Pipe`, `String`, `ToolRegistry.swift`, `.write`, `stability_release.robot`, `.load`, `graphify reference: query, path, explain`, `PtyDrainCeilingBenchmark`, `ActivePaneService`, `TerminalHostView`, `CopyModeGridSource`, `.decode`, `TriState`, `NotificationEntry`, `EnvironmentStore`, `.evaluate`, `[3.1.2] - 2026-06-16`, `What You Must Do When Invoked`, `.handle`, `[3.3.0] - 2026-06-18`, `ThaiCombiningMarkTests`, `[3.9.0] - 2026-06-22`, `HarnessDaemonToolsTests`, `MatchCategory`, `AgentKind`, `What You Must Do When Invoked`, `TerminalFindBar`, `CommandPromptController`, `ActiveTabCloseDisposition`, `LiveSession`, `AgentTableEntry`, `[3.5.0] - 2026-06-20`, `HarnessCLI+Workbench.swift`, `.status`, `BinaryRefresherTests`, `.rects`, `InlineAICompletionView`, `[3.13.1] - 2026-07-02`, `GridCompositorTests`, `Error`, `AppDelegate`, `ScrollbackFile.swift`, `ScriptRuntime`, `[2.5.1] - 2026-06-12`, `AgentSessionSummary`, `MainWindowController`, `FileTabManager`, `LayoutProbeView`, `HarnessBrowserTools`, `PaletteModel`, `.classify`, `HarnessCLI`, `[2.4.0] - 2026-06-12`, `.testDataFrameEncodeVsJSONBase64Output`, `SettingsRemoteView`, `PaneDropZoneOverlay`, `.build`, `NotchLayoutMetrics`, `GridCompositor`, `Section`, `AgentNotchRowSummary`, `SSHTunnelManagerTests`, `ExternalOpenKind`, `.make`, `graphify reference: commit hook and native CLAUDE.md integration`, `AgentBridge`, `FileNode`, `SessionCoordinator`, `NSViewRepresentable`, `BoardViewController`, `DaemonSyncService`, `.install`, `HarnessSidebarPanelViewController`, `.path`, `StatusLineView.swift`, `SGRMouseEvent`, `KeySpec`, `[2.5.0] - 2026-06-12`, `SyntaxTextView`, `[1.5.1] - 2026-06-06`, `.run`, `DisplayPanesOverlay`, `.menu`, `RemoteHostStoreTests`, `AgentHookStrategy`, `StatusLineWidthTests`, `JSONDecoder`, `AgentApprovalBar`, `settings.json`, `jobs`, `.parse`, `.terminalHost`, `RegressionBugFixTests`, `.script`, `Send Ex Command`, `skipUnlessLiveDaemonTests`, `AgentSnapshot`, `WorkspaceSymbolIndex`, `FloatingPaneController`, `.theme`, `RealPty`, `CommandExecutionError`, `Foundation`, `Page`, `DaemonLifecycleTests`, `[3.2.0] - 2026-06-16`, `.deepMerge`, `SurfaceProgressTracker`, `State`, `DaemonStats`, `.encode`, `.run`, `.install`, `Identifiable`, `MCPServer`, `PromptQueue`, `HarnessCLITests`, `FilePreviewCoordinatorTabScopeTests`, `.initialState`, `SessionEditor`, `.run`, `RecordSession`, `FormatContext`, `StartupMetrics`, `.encode`, `PaneLabelDaemonTests`, `HarnessOnboarding`, `.steps`, `AgentHookInstallerTests.swift`, `CommandIPCTranslatorTests.swift`, `CommandParserTests.swift`, `SystemdUserInstaller`, `RemoteHostsService`, `ThaiClusterCopyTests.swift`, `graphify reference: extra exports and benchmark`, `State`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **Why does `Foundation` connect `settings.json` to `Changelog Archive`, `CodingKey`, `ThemeDocument`, `LSPMessage`, `PerformanceBenchmarks`, `KittyKeyboardTests`, `Kind`, `VTParser`, `MetalRendererTests`, `UInt32`, `OnboardingEnvironment`, `SplitPaneCoordinator`, `RGBColor`, `SemanticPromptTests`, `Sendable`, `Equatable`, `DaemonClient`, `String`, `HarnessSettings`, `CodingKeys`, `[3.12.0] - 2026-06-30`, `RenderSchedulerTests`, `ThemeCatalogEmbedTests`, `.normalizedKey`, `HookEvent`, `DaemonServer`, `EngineConformanceTests.swift`, `PasteBufferStore`, `ViEngine`, `FrecencyDirectoryStore`, `CLAUDE.md`, `ComposedCell`, `[3.10.0] - 2026-06-27`, `HarnessCLI+Server.swift`, `TerminalProgressReport`, `ShellIntegration`, `String`, `worktree_isolation_cli.robot`, `ImportedTerminalConfig`, `ScriptSnapshotModels.swift`, `[3.8.0] - 2026-06-22`, `LayoutTemplate`, `OptionStore`, `TerminalProtocolCompatibilityTests`, `Endpoint`, `.firstMatch`, `LSPClient`, `LSPDiagnostic`, `TerminalGridCell`, `.load`, `TerminalModes`, `AttachInputBatcher`, `PaneContainerView`, `ScriptRuntime.swift`, `DaemonLauncher`, `Recipe`, `ScriptFileWatcher`, `CommandFinishedTests`, `AgentNotchViewModel`, `.resolve`, `ViEngine`, `DamageTrackingTests`, `.decodeKeySpec`, `CopyModeAction.swift`, `.makeSnapshot`, `NotificationCoordinator`, `.encode`, `SessionGroup`, `PaneNode`, `[3.0.0] - 2026-06-15`, `HarnessGridTerminal`, `String`, `HistoryRingBuffer`, `GlyphAtlas`, `[3.10.0] - 2026-06-27`, `.write`, `ToolRegistry.swift`, `AgentHookInstaller`, `CommandTarget`, `PtyDrainCeilingBenchmark`, `ActivePaneService`, `TerminalHostView`, `CopyModeGridSource`, `DecodedImage`, `.decode`, `EnvironmentStore`, `HarnessDaemonToolsTests`, `[3.1.2] - 2026-06-16`, `PathToken`, `.handle`, `Int`, `ThaiCombiningMarkTests`, `MatchCategory`, `AgentKind`, `What You Must Do When Invoked`, `ActiveTabCloseDisposition`, `LiveSession`, `[3.5.0] - 2026-06-20`, `AgentTableEntry`, `HarnessCLI+Workbench.swift`, `TreeSitterGrammarBundle`, `URLDetection`, `[3.9.5] - 2026-06-26`, `.status`, `.rects`, `VTConformanceCorpusTests`, `GridCompositorTests`, `TerminalScreen`, `LSPServerRegistry`, `generate-release-notes.swift`, `SessionSnapshot`, `Error`, `ScrollbackFile.swift`, `OutputTrigger`, `GlyphRasterizer`, `AgentSessionSummary.swift`, `.classify`, `FileTabManager`, `BinaryInstallerVersionTests`, `HarnessBrowserTools`, `LayoutProbeView`, `CopyModeState`, `HarnessCLI`, `[3.9.5] - 2026-06-26`, `Identifiers.swift`, `[2.4.0] - 2026-06-12`, `PaneTarget`, `.build`, `NotchLayoutMetrics`, `Hermes → Harness`, `GridCompositor`, `Result`, `Section`, `AgentNotchRowSummary`, `.parse`, `graphify reference: add a URL and watch a folder`, `.resolve`, `FileChangeWatcher`, `CellColorResolver`, `SSHTunnelManagerTests`, `TextGrid`, `WorkbenchCommand`, `TerminalBlockStoreTests`, `.make`, `TerminalMetalRenderer`, `PaneBorderStatus`, `ClipboardOSCTests`, `graphify reference: commit hook and native CLAUDE.md integration`, `DaemonMetrics`, `report.html`, `HarnessTerminalSurfaceWorkerTests`, `Split Right`, `BoardViewController`, `DaemonSyncService`, `GitMetadataProvider`, `FileEditorView`, `ThemeFileServiceTests`, `.install`, `SGRMouseEvent`, `KeySpec`, `.run`, `.menu`, `FormatColor`, `graphify reference: GitHub clone and cross-repo merge`, `AgentHookStrategy`, `Process`, `GitHubCLIClient`, `NotificationBus`, `jobs`, `PaneNode`, `HarnessPaths.swift`, `.parse`, `ThemeDiagnostics`, `.terminalHost`, `.script`, `skipUnlessLiveDaemonTests`, `FrameSignposter`, `AgentSnapshot`, `WorkspaceSymbolIndex`, `.theme`, `.recordReapedGenerationForTesting`, `RealPty`, `ImageProtocolTests.swift`, `CommandExecutionError`, `Foundation`, `Added`, `[3.2.0] - 2026-06-16`, `DaemonLifecycleTests`, `.deepMerge`, `SurfaceProgressTracker`, `.handleCat`, `State`, `RGBColor`, `[2.2.4] - 2026-06-11`, `DaemonStats`, `Tab`, `.encode`, `DynamicInstanceBuffer`, `.install`, `SurfaceProgressTrackerTests.swift`, `PromptQueue`, `HarnessCLITests`, `.measure`, `TerminalDamage.swift`, `FilePreviewCoordinatorTabScopeTests`, `HarnessCore`, `.delay`, `WaitForRegistry`, `RemoteHostStore`, `.run`, `RecordSession`, `FormatContext`, `.encode`, `.evaluateStyled`, `HarnessOnboarding`, `.install`, `SystemdUserInstaller`, `RemoteHostsService`, `ThaiClusterCopyTests.swift`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **Are the 43 inferred relationships involving `Int` (e.g. with `.register()` and `.coloredImage()`) actually correct?**
  _`Int` has 43 INFERRED edges - model-reasoned connections that need verification._
- **What connects `unsupportedPlatform`, `unmodified`, `modified` to the rest of the system?**
  _3744 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `AgentNotchRootView` be split into smaller, more focused modules?**
  _Cohesion score 0.12433862433862433 - nodes in this community are weakly interconnected._
- **Should `LSPMessage` be split into smaller, more focused modules?**
  _Cohesion score 0.07563025210084033 - nodes in this community are weakly interconnected._