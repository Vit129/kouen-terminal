# Graph Report - harness-readme-fix  (2026-07-05)

## Corpus Check
- 716 files · ~851,892 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 11906 nodes · 30867 edges · 1353 communities (802 shown, 551 thin omitted)
- Extraction: 89% EXTRACTED · 11% INFERRED · 0% AMBIGUOUS · INFERRED: 3427 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `89eda712`
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
1. `IPCRequest` - bridges 132 areas (151 edges)
2. `Command` - bridges 99 areas (107 edges)
3. `SessionCoordinator` - bridges 57 areas (124 edges)
4. `MenuTarget` - bridges 54 areas (60 edges)
5. `IPCResponse` - bridges 51 areas (69 edges)
6. `SpecialKey` - bridges 51 areas (56 edges)
7. `EngineConformanceTests` - bridges 50 areas (76 edges)
8. `AgentKind` - bridges 43 areas (92 edges)
9. `CommandParserTests` - bridges 42 areas (43 edges)
10. `HarnessPaths` - bridges 41 areas (95 edges)

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

## Communities (1353 total, 551 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.05
Nodes (48): AgentBridge, AgentTarget, Bool, String, SurfaceID, LinePos, end, firstNonBlank (+40 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.05
Nodes (29): TerminalModes, InputEncoder, KeyEventType, press, release, `repeat`, KeyModifiers, MouseButton (+21 more)

### Community 2 - ".handleNormal"
Cohesion: 0.06
Nodes (17): T, HarnessTerminalSurfaceView, PendingMainHop, SurfaceEmulatorState, SurfaceFrameBuildResult, Bool, Data, DispatchQueue (+9 more)

### Community 3 - "Changed"
Cohesion: 0.06
Nodes (23): AgentScanner, DispatchSourceTimer, DaemonCommandExecutor, Command, BellScanState, esc, normal, string (+15 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.05
Nodes (33): BoardCardView, BoardViewController, FlippedView, Bool, NSCoder, Set, TabID, Void (+25 more)

### Community 5 - "IPCRequest"
Cohesion: 0.06
Nodes (35): AgentIconArt, AgentVectorIcon, Bool, CGSize, String, AgentIconRenderer, Scanner, SVGPathParser (+27 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.08
Nodes (15): PaneBorderStatus, Bool, Command, CommandTarget, Data, DispatchWorkItem, HarnessGridTerminal, PaneID (+7 more)

### Community 7 - "Command"
Cohesion: 0.07
Nodes (24): CSIParams, State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate (+16 more)

### Community 8 - "LSPMessage"
Cohesion: 0.06
Nodes (24): CornerInfo, EditorDividerView, HarnessSplitView, HitTestPassthroughView, PaneDragGripView, PaneHoverButton, PaneSplitButtonsView, DispatchWorkItem (+16 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.08
Nodes (16): ConcurrentIndexSet, DaemonContentionTests, SubscriptionBox, String, URL, DaemonRoundTripTests, Data, Int32 (+8 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.05
Nodes (29): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, failed, DefaultTerminalStatus, Bool, String, URL (+21 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.12
Nodes (13): colors, PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Data, Double, String (+5 more)

### Community 12 - "Changed"
Cohesion: 0.08
Nodes (20): AgentDetector, AgentTable, AgentTableEntry, Bool, Date, Int32, Set, String (+12 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.08
Nodes (24): BrowserPaneRegistry, BrowserPaneView, BrowserProgressLine, BrowserTab, Double, NSCoder, NSLayoutConstraint, NSRect (+16 more)

### Community 14 - "VTParser"
Cohesion: 0.06
Nodes (32): CodingKeys, error, id, jsonrpc, method, params, JSONRPCId, int (+24 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.07
Nodes (16): Range, String, TerminalGridCell, TerminalBufferMatch, TerminalBufferSearch, String, TerminalGridCell, TextGrid (+8 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.07
Nodes (21): SurfaceProgressTracker, Bool, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void, State (+13 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.09
Nodes (6): ImagePlacement, Pen, SavedCursor, ClosedRange, Range, TerminalScreen

### Community 18 - "HarnessUILibrary"
Cohesion: 0.04
Nodes (20): HarnessDaemonCore, DaemonBrowserRoutingTests, IPCCodecInvariantTests, String, URL, RawSocketError, connectFailed, writeFailed (+12 more)

### Community 19 - "SpecialKey"
Cohesion: 0.10
Nodes (26): DaemonSubscription, Bool, Data, Int32, String, TimeInterval, UInt16, UInt64 (+18 more)

### Community 20 - "code:block1 (Agent shell process)"
Cohesion: 0.09
Nodes (21): DecodedReplyFrame, output, reply, DecodedRequestFrame, input, request, FrameError, tooLarge (+13 more)

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.08
Nodes (20): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+12 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.10
Nodes (12): SessionCoordinator, Bool, Double, PaneID, PaneNode, SessionID, SplitDirection, String (+4 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.15
Nodes (7): Bool, Date, SessionID, String, SurfaceID, TabID, WorkspaceID

### Community 24 - ".request"
Cohesion: 0.08
Nodes (17): NSDraggingInfo, NSDragOperation, HarnessTerminalSurfaceView, Any, Bool, CGFloat, NSEvent, NSMenu (+9 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.08
Nodes (16): KeyRecorderView, Any, Bool, NSCoder, NSEvent, NSPoint, String, Void (+8 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.11
Nodes (15): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, RasterizedGlyph, ShapedGlyph, ShapedRunKey, Bool, CGContext (+7 more)

### Community 27 - "RGBColor"
Cohesion: 0.11
Nodes (26): ClientRecord, CountBox, DaemonError, alreadyRunning, bindFailed, listenFailed, socketFailed, DaemonServer (+18 more)

### Community 28 - ".parse"
Cohesion: 0.06
Nodes (21): HarnessUILibrary, HarnessUILibrary — Robot Framework keyword library for Harness terminal automati, Verify a board column exists using harness CLI., Run a harness CLI command and assert exit code 0., Run harness view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 29 - "Added"
Cohesion: 0.10
Nodes (18): ConfigError, unsupportedAgent, writeFailure, MCPConfigWriter, Any, Bool, String, URL (+10 more)

### Community 30 - "Notification"
Cohesion: 0.10
Nodes (13): DisplayWidth, String, Unicode, Run, Data, ReleaseNotes, String, TerminalBanner (+5 more)

### Community 31 - "Sendable"
Cohesion: 0.10
Nodes (20): KeybindingsService, Bool, Command, String, KeySpec, Binding, CodingKeys, bindings (+12 more)

### Community 32 - ".addTab"
Cohesion: 0.11
Nodes (25): BlockSelection, CursorRender, CursorStyle, bar, block, underline, FrameBuilder, FrameImage (+17 more)

### Community 33 - "Equatable"
Cohesion: 0.08
Nodes (31): Int, TerminalGridSnapshot, ImagePlacementSnapshot, SemanticMark, Bool, String, UInt8, TerminalCellWidth (+23 more)

### Community 34 - "DaemonClient"
Cohesion: 0.11
Nodes (19): OptionStore, OptionStore.Value, Scope, pane, session, tab, workspace, ScopedKey (+11 more)

### Community 35 - "MenuTarget"
Cohesion: 0.19
Nodes (10): DaemonClient, String, HarnessCLI, String, HarnessCLI, String, HarnessCLI, Bool (+2 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.10
Nodes (21): AgentNotchDashboardProjection, AgentNotchProjection, AgentNotchRowSummary, RowKind, agent, session, Date, SessionGroup (+13 more)

### Community 37 - "String"
Cohesion: 0.07
Nodes (21): NSRangePointer, NSTextInputClient, HarnessTerminalSurfaceView, Any, Bool, NSAttributedString, NSEvent, NSPoint (+13 more)

### Community 38 - "code:bash (swift build)"
Cohesion: 0.12
Nodes (36): Codable, BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserResponsePayload, cookies, error (+28 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.06
Nodes (19): keys, CGImage, DecodedImage, ImageLimits, Bool, UInt8, ImageDecoder, Data (+11 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.12
Nodes (9): HarnessTerminalSurfaceView, CGFloat, CGRect, ClosedRange, NSEvent, NSPoint, Range, String (+1 more)

### Community 41 - "CodingKeys"
Cohesion: 0.08
Nodes (15): DaemonReconnectPolicy, DetachedPaneOverlay, ReconnectLatch, Style, detached, reconnectingChip, Bool, NSEvent (+7 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.08
Nodes (14): BrowserTabButton, Bool, NSEvent, HarnessPillButton, Kind, primary, secondary, SoftIconButton (+6 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.12
Nodes (24): RepoGitMetadata, SidebarListModel, SidebarSessionRow, divider, groupHeader, session, worktree, worktreeHeader (+16 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.15
Nodes (5): RenderScheduler, Bool, Void, RenderSchedulerTests, Bool

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.09
Nodes (15): ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy, SessionLifecycleService, NSWindow (+7 more)

### Community 46 - ".buildCommand"
Cohesion: 0.09
Nodes (21): CommandHistorySearchController, HistoryItemView, HistoryRowView, SearchPanel, Bool, CGFloat, NSAttributedString, NSCoder (+13 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.15
Nodes (10): Process, SSHTunnelManager, Bool, RemoteHost, URL, Tunnel, SSHTunnelManagerTests, RemoteHost (+2 more)

### Community 48 - "HookEvent"
Cohesion: 0.10
Nodes (17): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+9 more)

### Community 49 - "DaemonServer"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 50 - "Added"
Cohesion: 0.09
Nodes (26): Equatable, CodingKeys, error, id, jsonrpc, method, params, result (+18 more)

### Community 51 - ".keyEvent"
Cohesion: 0.08
Nodes (31): AgentChipView, BoardColumnKind, ChromeRole, sidebar, tabBar, Divider, FontSize, HarnessMotion (+23 more)

### Community 52 - "Fixed"
Cohesion: 0.12
Nodes (9): SessionEditor, DaemonSurfaceID, SessionSnapshot, String, SessionEditorPhase4Tests, PaneID, TabID, WorkspaceID (+1 more)

### Community 53 - "Added"
Cohesion: 0.08
Nodes (25): AgentArt, AgentMark, AgentMarkShape, AgentVectorIcon, Scanner, SVGPath, Bool, CGFloat (+17 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.10
Nodes (30): Color, MonoPillButtonStyle, Configuration, Configuration, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, ButtonStyle, CommandRow (+22 more)

### Community 55 - "TabCell"
Cohesion: 0.12
Nodes (12): MainSplitViewController, SplitChromeDelegate, Bool, CADisplayLink, CGFloat, NSColor, NSRect, NSSplitView (+4 more)

### Community 56 - "NSPanel"
Cohesion: 0.14
Nodes (10): IndexingIterator, LayoutTemplate, CGFloat, Command, Double, PaneID, PaneLeaf, PaneNode (+2 more)

### Community 57 - "BellScanState"
Cohesion: 0.25
Nodes (6): AnyCodable, JSONRPCError, Bool, Int32, String, ToolRegistry

### Community 58 - "PasteBufferStore"
Cohesion: 0.10
Nodes (18): PaneDragController, Any, Bool, NSEvent, NSView, NSWindow, PaneID, PaneDropZoneOverlay (+10 more)

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.14
Nodes (14): CommandPaletteController, PaletteAction, PaletteFileEntry, PaletteGrepMatch, PaletteModel, PaletteRow, header, item (+6 more)

### Community 60 - "ViEngine"
Cohesion: 0.16
Nodes (15): CommandParseError, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand, unterminatedString (+7 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.15
Nodes (8): RealPty, Bool, CChar, Int32, pid_t, String, UInt16, UnsafeMutablePointer

### Community 62 - "ComposedCell"
Cohesion: 0.28
Nodes (4): TerminalDamage, MTLTexture, RenderColor, UInt8

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.12
Nodes (19): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, GlyphAtlasStats, GlyphKey, ShapedGlyphKey, Bool (+11 more)

### Community 64 - ".text"
Cohesion: 0.14
Nodes (5): CommandIPCTranslatorTests, Bool, CommandTarget, PaneID, TabID

### Community 65 - "PrefixKeymap"
Cohesion: 0.13
Nodes (19): CopyModeMatch, ColorKind, bg, fg, underline, CompositorPane, GridCompositor, RenderCell (+11 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.15
Nodes (10): ScrollbackFile, Bool, Data, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 67 - "String"
Cohesion: 0.13
Nodes (16): SessionSnapshot, PendingVersionBanner, welcome, whatsNew, State, Bool, String, URL (+8 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.13
Nodes (18): ColorKind, bg, fg, underline, ComposedCell, ComposedFrame, CompositorPane, GridCompositor (+10 more)

### Community 69 - ".compose"
Cohesion: 0.14
Nodes (10): Bool, Data, String, UInt8, TerminalEmulator, TerminalColorRole, background, cursor (+2 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.13
Nodes (11): InlineAICompletionController, HarnessSettings, String, HarnessOptions, InputGate, CGFloat, FormatColor, HarnessSettings (+3 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.09
Nodes (21): SettingsAppearanceView, SliderRow, Bool, ClosedRange, Double, String, ColorHexRow, PaletteCell (+13 more)

### Community 72 - "XCTestCase"
Cohesion: 0.11
Nodes (16): FileViewerViewController, Bool, NSEvent, Set, String, URL, Void, LSPFileSession (+8 more)

### Community 73 - "README.md"
Cohesion: 0.13
Nodes (17): ClosureTarget, MenuActionTarget, OverlayWindow, Phase67UI, PopupWindow, Bool, Command, NSEvent (+9 more)

### Community 74 - "[2.6.0] - 2026-06-13"
Cohesion: 0.12
Nodes (9): SessionDividerRowView, SessionGroupHeaderRowView, SessionWorktreeHeaderRowView, SessionWorktreeRowView, NSEvent, NSMenu, NSTrackingArea, Void (+1 more)

### Community 75 - "OptionStore"
Cohesion: 0.11
Nodes (12): UnsafeBufferPointer, TerminalCellWidth, UnsafeBufferPointer, CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable (+4 more)

### Community 76 - ".parse"
Cohesion: 0.10
Nodes (12): AnyCancellable, NotchMaskAnimator, Bool, CGFloat, CGRect, NSView, NotchPanel, Bool (+4 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.10
Nodes (15): AnyObject, TimeInterval, ZombieHoldRegistry, PaneContainerView, SessionSnapshot, SurfaceID, PaneLifecycleManager, Bool (+7 more)

### Community 78 - "Added"
Cohesion: 0.14
Nodes (5): HarnessSidebarPanelViewController, NSMenuItem, NSView, String, SidebarTitlebarHeaderView

### Community 79 - "HarnessDesign"
Cohesion: 0.13
Nodes (14): Executor, Hook, HookEvent, HookRegistry, Bool, Command, URL, UUID (+6 more)

### Community 80 - "Agent handbook — Harness (extended reference)"
Cohesion: 0.10
Nodes (15): JSONDecoder, JSONEncoder, SessionGroup, LegacySnapshot, LegacyWorkspace, Bool, Date, String (+7 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.15
Nodes (10): Buffer, Configuration, PasteBufferStore, Bool, Data, Date, String, URL (+2 more)

### Community 82 - ".firstMatch"
Cohesion: 0.11
Nodes (17): HarnessSettings, ResizeOverlayMode, afterFirst, always, never, ResizeOverlayPosition, bottomRight, center (+9 more)

### Community 83 - "LSPClient"
Cohesion: 0.13
Nodes (15): AgentRow, AgentRow, MenuBarController, MenuRef, CGFloat, NSImage, NSMenu, NSMenuItem (+7 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.11
Nodes (14): NotificationEntry, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, NotificationRowView, Bool (+6 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.13
Nodes (12): OverlayBackground, Context, ChromeBackdrop, HarnessDesign, HarnessOverlayBackground, RuntimeGlassEffectView, Bool, CALayer (+4 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.12
Nodes (9): ContiguousArray, IteratorProtocol, HistoryRingBuffer, Iterator, Bool, Element, S, Sequence (+1 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.16
Nodes (11): AgentHookInstaller, InstallError, unsupported, InstallResult, Any, Bool, Data, String (+3 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.14
Nodes (13): DiagnosticCheck, DiagnosticStatus, fail, pass, warn, DoctorReport, DoctorRunner, Bool (+5 more)

### Community 89 - ".cursorPos"
Cohesion: 0.09
Nodes (8): HarnessThemeCatalog, String, HarnessThemeDefinition, Bool, RGBColor, String, ANSIPaletteTests, HarnessThemeCatalogTests

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.14
Nodes (7): ScriptRuntime, Any, String, URL, JSContext, JSValue, ScriptingTests

### Community 91 - "TerminalModes"
Cohesion: 0.10
Nodes (12): NotificationCoordinator, Bool, Date, SessionCoordinator, SessionSnapshot, Set, String, SurfaceID (+4 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.16
Nodes (12): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, SessionSnapshot, String, Tab (+4 more)

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.14
Nodes (13): InstallResult, Profile, Shell, bash, fish, zsh, ShellProfileInstaller, Bool (+5 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.12
Nodes (8): HarnessTerminalSurfaceView, Bool, CAMetalDrawable, NSEvent, RGBColor, String, HarnessTerminalSurfaceView, CGFloat

### Community 95 - "shim.c"
Cohesion: 0.16
Nodes (3): LiveResizeTests, HarnessTerminalSurfaceView, NSWindow

### Community 96 - "Harness Usage"
Cohesion: 0.09
Nodes (14): NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent, NSImage (+6 more)

### Community 97 - "PaneContainerView"
Cohesion: 0.15
Nodes (12): SplitPaneCoordinator, Bool, PaneID, PaneNode, SessionCoordinator, SessionID, SplitDirection, String (+4 more)

### Community 98 - "4. Technical Architecture"
Cohesion: 0.11
Nodes (13): String, WorkbenchMRU, FileEditorView, Bool, NSCoder, NSEvent, NSRect, String (+5 more)

### Community 99 - ".dispatch"
Cohesion: 0.09
Nodes (19): AgentNotchPresentation, closed, open, peek, AgentNotchViewModel, AgentNotchWindowActivator, Animation, Bool (+11 more)

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.11
Nodes (20): LocalizedError, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, found, notFound (+12 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.11
Nodes (26): PaneRef, bottom, byID, byIndex, last, left, next, previous (+18 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.18
Nodes (4): hooks, AgentHookInstallerTests, String, URL

### Community 103 - "AnyCodable"
Cohesion: 0.17
Nodes (10): Result, AsyncCLIResultBox, HarnessCLI, LSPDefinitionPayload, LSPDiagnosticsPayload, LSPStatusPayload, Error, String (+2 more)

### Community 104 - "Recipe"
Cohesion: 0.19
Nodes (7): MetalRendererTests, RenderedFixture, Bool, StaticString, String, TerminalGridSnapshot, UInt

### Community 105 - "Changelog"
Cohesion: 0.18
Nodes (7): MainExecutor, Bool, Command, PaneID, PaneNode, SessionCoordinator, SurfaceID

### Community 106 - "domain-design.md"
Cohesion: 0.13
Nodes (13): DirectoryItemRow, DirectoryPanel, DirectoryPickerController, DirectoryPickerFooter, DirectoryPickerModel, DirectoryPickerView, DirectoryWindowDelegate, String (+5 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.14
Nodes (19): FooterIconButton, RecentProjectsMenuButton, SidebarFooterModel, SidebarFooterView, SidebarSectionLabelView, SidebarSectionModel, SidebarTabBarView, Bool (+11 more)

### Community 108 - ".resolve"
Cohesion: 0.11
Nodes (13): Decodable, HarnessMCP, HarnessBrowserToolsTests, URL, HarnessDaemonToolsTests, String, URL, Document (+5 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.10
Nodes (20): CopyModeSearch, CopyModeSelectionMode, block, char, line, none, CopyModeSideEffect, beginSearchEntry (+12 more)

### Community 110 - "SoftIconButton"
Cohesion: 0.10
Nodes (25): Bool, UInt8, TerminalCellWidth, normal, spacerTail, wide, TerminalCursor, TerminalCursorShape (+17 more)

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.20
Nodes (16): BgInstance, CursorCacheKey, DecoInstance, EncodedFrameInstances, EncodedRowInstances, ImageInstance, InstanceUploadCacheKey, PendingBgSpan (+8 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.24
Nodes (8): AppKit, HarnessCopyMode, HarnessTerminalEngine, HarnessTerminalRenderer, HarnessTheme, Metal, QuartzCore, XCTest

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.15
Nodes (15): String, ChecksStatus, fail, none, pass, pending, CIRun, GitHubCLIClient (+7 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.13
Nodes (14): StatusLineView, CGFloat, FormatColor, Never, NSAttributedString, NSCoder, NSColor, NSLayoutConstraint (+6 more)

### Community 115 - ".encode"
Cohesion: 0.10
Nodes (17): CustomStringConvertible, DaemonClientError, connectionFailed, timeout, unexpectedResponse, writeFailed, DaemonSessionError, daemonError (+9 more)

### Community 116 - "SessionGroup"
Cohesion: 0.17
Nodes (13): Darwin, Foundation, Glibc, HarnessCore, FormatContextBuilder, daemonLog(), detectStaleInstance(), installSignalHandlers() (+5 more)

### Community 117 - "PaneNode"
Cohesion: 0.13
Nodes (15): Error, LSPClient, LSPClientError, missingPipe, processNotRunning, requestFailed, serverNotExecutable, AsyncStream (+7 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.20
Nodes (4): CopyModeReducerTests, FakeGrid, String, TerminalGridCell

### Community 119 - "Harness command reference"
Cohesion: 0.11
Nodes (13): LaunchdServiceInstaller, ServiceInstaller, ServiceInstallers, ServiceInstallReport, Bool, String, URL, Bool (+5 more)

### Community 120 - "Added"
Cohesion: 0.12
Nodes (21): CodingKeys, activeSurfaceID, daemonSurfaceID, id, surfaceID, surfaces, PaneLeaf, PaneNode (+13 more)

### Community 121 - "Changed"
Cohesion: 0.15
Nodes (7): ImportedTerminalConfig, Bool, Double, Float, String, TerminalConfigImporter, TerminalConfigImporterTests

### Community 122 - "ViEngine"
Cohesion: 0.12
Nodes (17): AnyTransition, AnyView, AgentNotchPeekEvent, AgentNotchRootView, HorizontalInsetRect, NotchOverviewRow, NotchRowButtonStyle, NotchStatusDot (+9 more)

### Community 123 - "Pipe"
Cohesion: 0.14
Nodes (9): ActivePaneService, Bool, PaneID, PaneNode, SessionCoordinator, Set, SurfaceID, Tab (+1 more)

### Community 124 - "String"
Cohesion: 0.11
Nodes (14): ExternalOpenKind, filePreview, terminal, theme, InstallChoice, cancel, install, installAndApply (+6 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.19
Nodes (6): FilePreviewCoordinator, FileTabID, NSView, Set, SplitDirection, String

### Community 126 - ".path"
Cohesion: 0.12
Nodes (17): CommandIPCTranslator, CommandTarget, CommandTranslation, clientLocal, requests, unresolved, Command, PaneID (+9 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.14
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.13
Nodes (13): CommandPromptController, KeyablePanel, Bool, NSControl, NSPanel, NSTextView, Selector, String (+5 more)

### Community 129 - "SwiftUI"
Cohesion: 0.17
Nodes (4): SessionSnapshot, String, UUID, TargetSpecTests

### Community 130 - "Harness"
Cohesion: 0.16
Nodes (14): Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow, launchStart, StartupMetrics (+6 more)

### Community 131 - ".install"
Cohesion: 0.13
Nodes (12): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+4 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.16
Nodes (3): DamageTrackingTests, IndexSet, TerminalEmulator

### Community 133 - ".load"
Cohesion: 0.13
Nodes (16): CLIInstallLocator, DetachKeys, absent, invalid, parsed, HarnessCLI, OptionalUUID, absent (+8 more)

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.08
Nodes (25): 10. Universal retire-hold via `removeFromSuperview()` override (definitive), 11. NSEvent local monitor installed in AppDelegate (fix #8 actually deployed), 12. `nonisolated` + `MainActor.assumeIsolated` on high-frequency AppKit callbacks (2026-06-21), 1. `TerminalPaneRegistry.retire()` — deferred dealloc (500ms), 2. Remove `nonisolated` from all layout overrides, 3. Remove `MainActor.assumeIsolated` from callbacks, 4. Detach NSHostingView on teardown (FileTreeSwiftUIView), 5. Avoid `Optional.map {}` in @MainActor code (+17 more)

### Community 135 - "CommandTarget"
Cohesion: 0.18
Nodes (8): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, URL

### Community 136 - ".startWatching"
Cohesion: 0.10
Nodes (15): PaletteCommandConfig, PaletteFooter, PaletteItemRow, PaletteMode, errors, grep, normal, PalettePanel (+7 more)

### Community 137 - "ActivePaneService"
Cohesion: 0.14
Nodes (11): FileFuzzyMatcher, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool, Character (+3 more)

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.18
Nodes (7): ParsedShortcut, PrefixKeymap, Any, Bool, NSEvent, String, TimeInterval

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.20
Nodes (8): C, AttachInputBatcher, Outcome, Bool, Data, UInt8, AttachInputBatcherTests, UInt8

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.17
Nodes (17): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, PaneLeaf, PaneNode (+9 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.13
Nodes (5): Bool, Range, String, URLDetection, StringProtocol

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.28
Nodes (5): HarnessBrowserTools, Bool, Double, String, TimeInterval

### Community 144 - "PaneStyleSet"
Cohesion: 0.14
Nodes (11): DaemonSyncService, Bool, Never, SessionCoordinator, SessionSnapshot, SurfaceID, Tab, TabID (+3 more)

### Community 145 - "AsciiFastPathTests"
Cohesion: 0.12
Nodes (15): KeyRecorderRepresentable, String, Void, OverlayBackground, Context, OverlayBackground, Context, NSViewRepresentable (+7 more)

### Community 146 - "DecodedImage"
Cohesion: 0.16
Nodes (4): ContentAreaViewController, CGFloat, TabID, Notification

### Community 147 - "FileTreeWatcher"
Cohesion: 0.15
Nodes (9): AttributedString, NSColor, Recipe, RecipesStore, Bool, String, URL, UUID (+1 more)

### Community 148 - "TriState"
Cohesion: 0.15
Nodes (8): NSAttributedString, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String, SyntaxHighlightTests

### Community 149 - "EnvironmentStore"
Cohesion: 0.15
Nodes (13): AgentApprovalBar, ApprovalBarAction, hide, noop, show, NSColor, Bool, NSButton (+5 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.18
Nodes (5): CompositorPane, GridCompositorTests, Bool, String, TerminalGridSnapshot

### Community 151 - ".evaluate"
Cohesion: 0.12
Nodes (9): SGRMouse, SGRMouseEvent, Bool, PaneRect, S, UInt8, SGRMouseTests, String (+1 more)

### Community 152 - "Added"
Cohesion: 0.14
Nodes (13): pipe, termios, AttachClient, Configuration, LiveSession, Bool, Data, DispatchSourceSignal (+5 more)

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.27
Nodes (3): HarnessDaemonTools, String, UUID

### Community 154 - "LiveResizeTests"
Cohesion: 0.17
Nodes (9): AppDelegate, QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL, TerminalServicesProvider, NSApplication (+1 more)

### Community 155 - "Int"
Cohesion: 0.20
Nodes (6): RemoteHost, RemoteHost, SettingsRemoteView, Bool, RemoteHost, String

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.15
Nodes (9): CompletionPopupView, CompletionRowView, Bool, NSCoder, NSEvent, NSRect, NSTrackingArea, String (+1 more)

### Community 157 - "Added"
Cohesion: 0.12
Nodes (14): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, Bool, NSCoder (+6 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.08
Nodes (17): Codex → Harness, One-line install, What you'll see, Cursor Agent → Harness, Manual fallback, One-line install, What you'll see, Hermes → Harness (+9 more)

### Community 159 - "MatchCategory"
Cohesion: 0.27
Nodes (7): CopyModeGridSource, CopyModeReducer, Bool, Character, Range, String, GridPosition

### Community 160 - "AmbientBackground"
Cohesion: 0.14
Nodes (7): ReplayStep, Bool, Data, Double, TerminalRecordingCodec, TerminalReplay, TerminalRecordingTests

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.16
Nodes (10): InstallResult, Shell, bash, fish, zsh, ShellIntegration, Bool, URL (+2 more)

### Community 162 - "TerminalFindBar"
Cohesion: 0.22
Nodes (8): SurfaceRegistryTests, PaneID, SessionID, SessionSnapshot, String, SurfaceID, TabID, URL

### Community 163 - "Workspace"
Cohesion: 0.14
Nodes (17): PaneBorderStatus, bottom, off, top, PaneLeaf, PaneNode, branch, leaf (+9 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.22
Nodes (7): TerminalSelection, CellOverlayTests, HarnessTerminalSurfaceView, IndexSet, NSWindow, String, UInt64

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 166 - "LiveSession"
Cohesion: 0.14
Nodes (5): CodepointRunFastPathTests, StaticString, String, UInt, UInt8

### Community 167 - "AgentTableEntry"
Cohesion: 0.15
Nodes (4): HarnessGridTerminalTests, HarnessGridTerminal, String, TerminalGridSnapshot

### Community 168 - "Added"
Cohesion: 0.18
Nodes (11): RecordClient, RecordingWriter, RecordSession, Summary, Bool, Data, DispatchSourceSignal, FileHandle (+3 more)

### Community 169 - "Fixed"
Cohesion: 0.21
Nodes (7): HarnessCLI, SessionGroup, SessionSnapshot, String, UUID, T, Void

### Community 170 - "URLDetection"
Cohesion: 0.24
Nodes (9): FileNode, Bool, String, FileTreeScanOptions, ScoredMatch, SearchMatcher, Bool, Character (+1 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.17
Nodes (7): KeybindingsStore, URL, KeybindingsStoreTests, URL, Void, HarnessCLI, String

### Community 172 - ".decodeKeySpec"
Cohesion: 0.17
Nodes (18): Appearance, AppearanceKind, dark, light, Colors, ContrastGrade, high, low (+10 more)

### Community 173 - "BoardCard"
Cohesion: 0.13
Nodes (12): DesktopNotifier, HarnessPathDisplay, NotificationPresenter, Bool, MainActor, String, Void, UNNotification (+4 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.12
Nodes (12): SettingsHostingController, SettingsWindowController, NSCoder, NSWindow, Page, advanced, appearance, remote (+4 more)

### Community 175 - "RGBColorTests"
Cohesion: 0.17
Nodes (6): FileTreeContext, SessionID, String, DispatchWorkItem, UnsafeMutableRawPointer, SessionSnapshot

### Community 176 - "Added"
Cohesion: 0.19
Nodes (3): GitPanelView, NSButton, NSScrollView

### Community 177 - ".rects"
Cohesion: 0.17
Nodes (11): RecipeItemRow, RecipePanel, RecipePickerController, RecipePickerFooter, RecipePickerModel, RecipePickerView, RecipeWindowDelegate, Bool (+3 more)

### Community 178 - "InlineAICompletionView"
Cohesion: 0.09
Nodes (21): Build / Test / Run, Graphify, graphify, harness-terminal — Claude Instructions, Non-obvious Constraints, Session Start, Skills, Agent handbook — Harness (extended reference) (+13 more)

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.15
Nodes (14): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, DrainState, EchoRTT (+6 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.11
Nodes (15): Identifiable, CompleteStepView, Void, DiscoverStepView, Point, String, OnboardingStep, complete (+7 more)

### Community 181 - "GridCompositorTests"
Cohesion: 0.25
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 183 - "LSPServerRegistry"
Cohesion: 0.14
Nodes (8): BranchSwitchHelper, FileTreeNode, FileTreeSwiftUIView, Notification.Name, Bool, NSMenuItem, SessionID, Void

### Community 184 - "targets"
Cohesion: 0.15
Nodes (12): Motion, TimeInterval, CAMediaTimingFunction, HarnessOnboarding, Bool, ImmersiveOnboardingWindowController, ImmersivePanel, ImmersiveRootView (+4 more)

### Community 185 - "SessionSnapshot"
Cohesion: 0.15
Nodes (14): GridCompositor, Configuration, Int32, SessionGroup, SessionID, SessionSnapshot, Tab, TabID (+6 more)

### Community 186 - "Error"
Cohesion: 0.16
Nodes (11): Logger, OSSignposter, FrameSignposter, Bool, StaticString, UInt64, FluidityBenchmarks, HarnessTerminalSurfaceView (+3 more)

### Community 187 - "AppDelegate"
Cohesion: 0.11
Nodes (16): Kind, input, metadata, output, resize, RecordingEvent, input, metadata (+8 more)

### Community 188 - "BrowserPaneView"
Cohesion: 0.16
Nodes (9): ScrollbackEntry, ScrollbackReplaySegment, DaemonSurfaceID, Data, UInt64, URL, UUID, Void (+1 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.18
Nodes (15): TerminalColorGamut, auto, displayP3, sRGB, TerminalColorRenderingMode, accurate, vivid, SurfaceColorProviderState (+7 more)

### Community 190 - "user-stories.md"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Harness, Sparkle (+13 more)

### Community 191 - "ScriptRuntime"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 192 - "GlyphRasterizer"
Cohesion: 0.17
Nodes (4): String, RegressionBugFixTests, SessionSnapshot, Tab

### Community 193 - "BinaryInstaller"
Cohesion: 0.29
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.14
Nodes (7): OnboardingController, HarnessOnboarding, Agent, OnboardingEnvironment, Bool, String, OnboardingEnvironmentTests

### Community 195 - "ResizeHUDView"
Cohesion: 0.15
Nodes (9): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+1 more)

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.19
Nodes (14): FileEditorTabBarBody, FileEditorTabBarModel, FileEditorTabBarView, FileTabPillView, Bool, FileTabID, NSCoder, NSRect (+6 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.21
Nodes (8): NotchGeometry, NSScreen, NotchLayoutMetrics, NotchRect, NotchScreenMetrics, Bool, Double, NotchLayoutMetricsTests

### Community 198 - ".classify"
Cohesion: 0.17
Nodes (6): HarnessSidebarPanelViewController, CGFloat, NSMenuItem, NSView, SessionGroup, String

### Community 199 - "code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)"
Cohesion: 0.19
Nodes (6): PaneStyle, PaneStyleSet, Bool, FormatColor, String, PaneStyleTests

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.15
Nodes (16): EndpointConnector, Int32, String, decodeBoundedCString(), ignoreSIGPIPE(), makeUnixStreamSocket(), setNoSigPipe(), CChar (+8 more)

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.25
Nodes (6): MutationResult, RemoteHost, RemoteHostStore, Bool, String, T

### Community 202 - "PaletteModel"
Cohesion: 0.25
Nodes (5): WorktreeManager, String, URL, UUID, WorktreeIsolationDaemonTests

### Community 203 - "Harness keybindings"
Cohesion: 0.23
Nodes (7): DaemonMetrics, Snapshot, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 204 - "From tmux"
Cohesion: 0.30
Nodes (6): Channel, Bool, Int32, String, WaitForRegistry, WaitForRegistryTests

### Community 205 - "CopyModeState"
Cohesion: 0.20
Nodes (8): SurfaceIO, Data, HarnessTerminalSurfaceView, NSCoder, SurfaceID, UInt16, UInt64, TerminalHostDelegate

### Community 206 - "HarnessCLI"
Cohesion: 0.13
Nodes (8): Bool, CGFloat, NSCoder, NSEvent, NSLayoutConstraint, NSPoint, NSRect, WindowTitleStripView

### Community 207 - "scheduleRender"
Cohesion: 0.12
Nodes (6): Bool, String, ViEngine, HarnessCLI, HarnessLSP, QuickLookUI

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.12
Nodes (5): CHarnessSys, PtyError, launchFailed, ShellLaunchProfile, ShellLaunchProfileTests

### Community 209 - "SettingsRemoteView"
Cohesion: 0.11
Nodes (11): CoreGraphics, CoreText, ImageIO, ShapedRunCacheStats, ShapedGlyphSignature, Bool, CGFloat, CGGlyph (+3 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 211 - "PaneTarget"
Cohesion: 0.11
Nodes (10): Endpoint, tcp, unix, EndpointError, connectionFailed, notYetSupported, pathTooLong, String (+2 more)

### Community 212 - ".translate"
Cohesion: 0.21
Nodes (7): EnvironmentStore, Persisted, String, URL, global, EnvironmentStoreTests, URL

### Community 213 - "String"
Cohesion: 0.18
Nodes (11): InstallError, daemonNotFound, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, Bool, Int32 (+3 more)

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.16
Nodes (9): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+1 more)

### Community 215 - ".lines"
Cohesion: 0.16
Nodes (5): LSPTextLocation, LSPTextLocationParser, String, URL, LSPTextLocationParserTests

### Community 216 - "CellColorResolverTests"
Cohesion: 0.32
Nodes (3): BinaryInstallerVersionTests, String, URL

### Community 217 - "GridCompositor"
Cohesion: 0.23
Nodes (11): ANSIPalette, CellColorResolver, MochaTheme, ResolvedCellColors, RGBColor, Bool, Double, String (+3 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.15
Nodes (9): GridCompositorParityTests, LiveCompositorFixture, Bool, String, TerminalGridSnapshot, PortCompositorFixture, Bool, String (+1 more)

### Community 219 - "Prompt"
Cohesion: 0.25
Nodes (5): SessionCoordinator, Bool, String, SurfaceID, TimeInterval

### Community 220 - "Section"
Cohesion: 0.23
Nodes (5): Bool, NSRange, NSString, Void, SyntaxTextView

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.26
Nodes (7): NSColor, NSStackView, NSTextField, String, WorktreeCardView, WorktreeEntry, NSView

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.16
Nodes (10): InlineAICompletionView, Bool, NSCoder, NSEvent, NSRect, NSTextField, String, TimeInterval (+2 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 224 - "CellColorResolver"
Cohesion: 0.35
Nodes (7): MTLClearColor, GlyphInstance, Float, RenderCell, RenderColor, SIMD4, TerminalMetalRenderer

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.19
Nodes (8): HookNotificationParser, Parsed, Any, Data, String, HookNotificationParserTests, Data, String

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.16
Nodes (15): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, Decoder (+7 more)

### Community 228 - "sessionRow"
Cohesion: 0.15
Nodes (11): FileHandle, Task, LSPTransport, LSPTransportBuffer, Data, String, TransportError, invalidContentLength (+3 more)

### Community 229 - ".decide"
Cohesion: 0.20
Nodes (10): DemoSession, DemoTerminalView, GridCanvas, Bool, CGFloat, String, StyledSegment, TerminalGridCell (+2 more)

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.13
Nodes (9): HarnessGridTerminal, Bool, Data, String, TerminalEmulator, TerminalGridCell, TerminalGridSnapshot, UInt8 (+1 more)

### Community 231 - "ExternalOpenKind"
Cohesion: 0.20
Nodes (7): Data, ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 233 - "TextGrid"
Cohesion: 0.11
Nodes (17): 2026-07-02 — agy logo color mismatch (preview vs prod) ✅ RESOLVED — not a Harness bug, 2026-07-02 — File preview: selection dropped on background reload + clicking agent tool-call paths failed ✅ FIXED and committed (`587fa906`), 2026-07-02 — File preview tabs leaked across terminal Tabs (global singleton) ✅ FIXED, not committed, 2026-07-02 — Git sidebar panel didn't refresh after external `git commit`/`push` ✅ FIXED, not committed, 2026-07-02 — Near-miss: `git revert --abort` wiped uncommitted session work, 2026-07-02 — P32 `setPaneLabel` MCP tool + P34 right-click block menu ✅ DONE, committed (`1723136`, `965f7b3e`), 2026-07-02 — P34 F1 slice 1: OSC 133 command-boundary + block command-text capture ✅ DONE, committed (`2ca7fbb`), 2026-07-02 — P34 F2 (block actions) + F3 (MCP block access) ✅ DONE, committed (`8049605`) (+9 more)

### Community 234 - ".scan"
Cohesion: 0.11
Nodes (17): Agent Detection, Branch Detection Flow, Branch Label, Chrome Roles, Drag Reorder, File, Files, Git Branch Detection (+9 more)

### Community 235 - "WorkbenchCommand"
Cohesion: 0.16
Nodes (10): center, ComposerPanel, Bool, NSEvent, NSTextView, NSWindow, Selector, String (+2 more)

### Community 236 - "Added"
Cohesion: 0.23
Nodes (7): Group, PrefixCheatsheetWindow, PrefixIndicatorWindow, CGFloat, NSTextField, NSView, NSWindow

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.13
Nodes (14): Reason, errored, finished, needsInput, RowState, Bool, Comparable, AgentActivity (+6 more)

### Community 238 - ".make"
Cohesion: 0.17
Nodes (10): agentDetail(), AgentInboxBody, AgentInboxPanelView, AgentInboxRowView, AgentStatusDot, CGFloat, Context, NSCoder (+2 more)

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.18
Nodes (12): Command, CommandTarget, PaneID, SessionGroup, SessionSnapshot, Tab, TargetKind, pane (+4 more)

### Community 240 - "PaneBorderStatus"
Cohesion: 0.20
Nodes (13): BannerShortcut, BannerShortcutRegistry, CodingKeys, description, key, showInBanner, Keybinding, MenuModifiers (+5 more)

### Community 241 - "Added"
Cohesion: 0.18
Nodes (8): BinaryInstaller, TimeInterval, BinaryInstaller.DetectionStatus, SetupStepView, Bool, String, URL, BinaryInstallerDisplayTests

### Community 242 - "AgentBridge"
Cohesion: 0.24
Nodes (4): RGBColor, String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 243 - ".make"
Cohesion: 0.11
Nodes (17): 1.1 Architecture, 1.2 Algorithm review, 1.3 Structure findings, 2.1 Structure, 2.2 Risk register (ranked), 3.1 Current implementation, 3.2 Why nothing shows (ranked root-cause candidates), 3.3 Fix plan (+9 more)

### Community 244 - "FileNode"
Cohesion: 0.16
Nodes (11): HarnessCLITests, URL, HarnessCLI, HarnessFilePreviewLoader, HarnessViewError, binaryOrUnsupportedEncoding, missingPath, tooLarge (+3 more)

### Community 246 - "Experience modes"
Cohesion: 0.18
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 248 - "DaemonMetrics"
Cohesion: 0.27
Nodes (3): ImageProtocolTests, String, TerminalEmulator

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.26
Nodes (5): Case, ReflowCorpusTests, String, TerminalEmulator, URL

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.20
Nodes (3): String, TerminalGridSnapshot, VTConformanceCorpusTests

### Community 251 - "SessionCoordinator"
Cohesion: 0.20
Nodes (11): ControlModeClient, ControlModeError, daemon, noMatch, noSnapshot, unresolved, Command, Data (+3 more)

### Community 252 - "NSViewRepresentable"
Cohesion: 0.12
Nodes (16): Agent Config Wiring, Agents, Architecture, Browser Pane, File I/O, Git, Key Files, MCP Server (harness-mcp) (+8 more)

### Community 253 - "Split Right"
Cohesion: 0.28
Nodes (8): ANSIPalette, CellColorResolver, ResolvedCellColors, Bool, Double, RGBColor, TerminalGridCell, TerminalGridColor

### Community 254 - "BoardViewController"
Cohesion: 0.16
Nodes (4): PromptQueue, String, SurfaceID, Void

### Community 255 - "release-hotfix.sh"
Cohesion: 0.16
Nodes (5): Float, Set, SurfaceID, Void, TerminalPaneRegistry

### Community 256 - "GitMetadataProvider"
Cohesion: 0.18
Nodes (4): SnapshotCoalescer, MainActor, Void, AgentApprovalBarTests

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.18
Nodes (7): HarnessWindow, NSEvent, MainWindowController, Any, NSRect, NSWindow, NSWindowController

### Community 258 - "WindowTitleStripView"
Cohesion: 0.15
Nodes (6): OptionSet, Modifiers, Decoder, String, UInt8, KeyTableTests

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.18
Nodes (13): os, FrameDropCause, encodeFailure, nilDrawable, attribute_lines(), main(), redraw_frames(), repeated_chunk() (+5 more)

### Community 260 - ".welcome"
Cohesion: 0.18
Nodes (6): ReleaseNotes, ReleaseNotes, Section, String, ReleaseNotesGuardTests, String

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.25
Nodes (5): NotificationBus, SnapshotChangedPayload, Bool, Data, String

### Community 262 - ".install"
Cohesion: 0.24
Nodes (5): HistoryLine, RewrapResult, Bool, String, TerminalGridCell

### Community 263 - "HarnessSidebarPanelViewController"
Cohesion: 0.32
Nodes (7): RenderColor, RenderColorConversion, RenderColorConverter, Float, RGBColor, SIMD4, SIMD3

### Community 264 - "code:bash (harness-cli install-hooks claude-code)"
Cohesion: 0.12
Nodes (17): AI Browser Control (harness-mcp), Build From Source, CLI, Development Builds, Documentation, Editor & LSP, Harness, How It Feels (+9 more)

### Community 265 - "code:bash (harness-cli install-hooks cursor)"
Cohesion: 0.12
Nodes (15): Architecture, Browser Auto-Retry (P24 Phase 4), Browser Pane (P14), BUG: Tab close button never fired (CASE-055 extended), BUG: Tab close button unresponsive (gesture conflict), CASE: applyLocalSnapshot re-injected closed browser panes (v2.7.1), CASE: collapsed errorBanner intercepted toolbar clicks (v2.7.1), Click-to-open localhost/LAN dev-server links (+7 more)

### Community 266 - ".path"
Cohesion: 0.17
Nodes (7): SecureInputMonitor, DispatchWorkItem, Set, String, SurfaceID, Carbon, HarnessTerminalKit

### Community 267 - ".performInstall"
Cohesion: 0.19
Nodes (8): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus, UserNotifications

### Community 268 - "code:bash (# Old (agent-specific):)"
Cohesion: 0.17
Nodes (8): BrowserPaneViewTests, MockWebView, Bool, URL, WKNavigation, WebKit, WKWebView, WKWebViewConfiguration

### Community 270 - "WindowSession"
Cohesion: 0.30
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 271 - "StatusLineView.swift"
Cohesion: 0.31
Nodes (5): HarnessSidebarPanelViewController, NSMenu, NSMenuItem, SessionGroup, SessionID

### Community 272 - "SGRMouseEvent"
Cohesion: 0.23
Nodes (11): CellMetrics, CellMetrics, ComposedTerminalView, Bool, CellColorResolver, CGFloat, CGPoint, GraphicsContext (+3 more)

### Community 273 - "KeySpec"
Cohesion: 0.12
Nodes (16): Attaching from a plain terminal, Bindings, Buffers (paste store), Composition, Harness command reference, Hooks, Inspection (CLI / control mode), Local diagnostics (+8 more)

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.16
Nodes (3): HarnessApp, FilePreviewCoordinatorTabScopeTests, NSView

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.17
Nodes (11): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, Bool, Double (+3 more)

### Community 276 - "SyntaxTextView"
Cohesion: 0.22
Nodes (3): CompletionGenerator, String, CompletionGeneratorTests

### Community 277 - ".run"
Cohesion: 0.23
Nodes (10): Array, SessionGroup, SessionSnapshot, Bool, Decoder, SessionID, String, Tab (+2 more)

### Community 278 - "BlockTintOverlay"
Cohesion: 0.16
Nodes (9): Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSPoint, NSRect, TimeInterval (+1 more)

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.17
Nodes (4): ScrollbackTests, Character, String, TerminalGridSnapshot

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.28
Nodes (8): PaneOutputWaiter, PaneOutputWaitResult, Bool, CheckedContinuation, Never, PaneLeaf, Tab, UInt64

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.20
Nodes (7): HarnessCLI, String, String, HarnessCLI, SessionID, String, Set

### Community 283 - "FormatColor"
Cohesion: 0.25
Nodes (5): HarnessCLI, Bool, Int32, Never, String

### Community 284 - "click_ui_element"
Cohesion: 0.13
Nodes (14): 1. @MainActor + Task + Process.waitUntilExit = FREEZE (RL-052), 2. @Observable + mutation in body = infinite re-render loop (RL-053), 3. Re-entrancy guard on rebuildRows, 4. Worktree display rules, Architecture, chromeEpoch — force SwiftUI re-render from static state, Critical Lessons (bugs fixed), File tree: root at git root, expand on CWD change (+6 more)

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.13
Nodes (15): Context, Non-goals, P8: macOS 27 Golden Gate Adoption, Phase 0 — Swift 6.3+ Concurrency Safety (P0, LESSONS FROM macOS 26.5 CRASH SAGA), Phase 1 — Compatibility (P0), Phase 2 — Quick Wins (P1), Phase 3 — NSTextSelectionManager (P1), Phase 4 — Gesture Recognizer Migration (P2) (+7 more)

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.13
Nodes (13): Architecture, Build & test, Coding constraints, Communication: GUI ↔ Daemon ↔ CLI, Generated files (do not hand-edit), Graphify + agent-memory, IPC safety, Package map (+5 more)

### Community 287 - ".apply"
Cohesion: 0.17
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

### Community 288 - "AgentHookStrategy"
Cohesion: 0.16
Nodes (10): GitStatusType, added, deleted, modified, renamed, unmodified, untracked, GitStatusProvider (+2 more)

### Community 289 - "StatusLineWidthTests"
Cohesion: 0.26
Nodes (8): Never, Set, String, Task, URL, Void, WorkspaceSymbolIndex, NSRegularExpression

### Community 290 - "Process"
Cohesion: 0.19
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 291 - "JSONDecoder"
Cohesion: 0.21
Nodes (11): clamp(), DotView, statusColor(), statusHelp(), Bool, Context, NSColor, String (+3 more)

### Community 292 - "Release runbook"
Cohesion: 0.18
Nodes (8): MTLRenderCommandEncoder, ImageTextureCache, MTLDevice, MTLTexture, UInt8, ImageZBand, aboveText, belowText

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.29
Nodes (5): KeyTokenParser, Bool, Data, String, KeyTokenParserTests

### Community 294 - "GitHubCLIClient"
Cohesion: 0.27
Nodes (8): SSHTunnelError, exitedEarly, invalidConfiguration, launchFailed, notReady, Int32, String, TimeInterval

### Community 295 - "AgentApprovalBar"
Cohesion: 0.21
Nodes (3): GroupedSessionTests, Set, SurfaceID

### Community 296 - "NotificationBus"
Cohesion: 0.26
Nodes (4): Bool, String, TimeInterval, WorktreeInfo

### Community 297 - "settings.json"
Cohesion: 0.13
Nodes (15): BrowserRequestPayload, close, cookies, evaluate, goBack, goForward, interact, navigate (+7 more)

### Community 298 - "jobs"
Cohesion: 0.13
Nodes (11): ExperienceMode, agent, full, persistent, plain, Bool, NotchVisibilityMode, automatic (+3 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.27
Nodes (3): HarnessSettingsTests, URL, Void

### Community 301 - ".parse"
Cohesion: 0.20
Nodes (9): InterruptFlag, ReplayClient, ReplayPlayer, Bool, Data, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.14
Nodes (11): Agent Memory Index — harness-terminal, Navigation, Edges, Files, Knowledge Index — Harness Terminal, Search Instructions, Source Map, Case Index (+3 more)

### Community 303 - ".encodeMouse"
Cohesion: 0.14
Nodes (13): ACP (Agent Client Protocol) — tried, shelved, erased, Command Palette / Power-User Terminal Features, Embedded Browser, Feature Provenance — harness-terminal, Git Panel, Harness MCP, IDE Track — File Tree / Editor / LSP (the "Zed half" made real), Notifications (+5 more)

### Community 304 - "00-inception-plan.md"
Cohesion: 0.14
Nodes (13): 1. Data / Geometry Separation (primary fix), 2. SnapshotCoalescer (cmux NotificationBurstCoalescer pattern), 3. Equality Guard on updateGeometry (Zed pattern), 4. Dirty Flag on setFrame (Otty/WezTerm pattern), 5. GPU Animation — CAShapeLayer Mask (Zed/Otty GPU path), 6. AgentScanner timer split, Files, Fixes Applied (layered) (+5 more)

### Community 305 - ".script"
Cohesion: 0.14
Nodes (14): Already portable or mostly portable, Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), First Implementation Slice, macOS-specific today, Non-goals (+6 more)

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.30
Nodes (6): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, agents

### Community 307 - "ViPathTokenTests"
Cohesion: 0.24
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 308 - "Send Ex Command"
Cohesion: 0.24
Nodes (6): HintModeOverlay, Any, HarnessTerminalSurfaceView, NSEvent, NSView, String

### Community 309 - "Browser DevTools API (P28)"
Cohesion: 0.25
Nodes (7): MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, String

### Community 310 - "FrameSignposter"
Cohesion: 0.26
Nodes (8): BlockTintOverlay, Bool, CGFloat, HarnessTerminalSurfaceView, NSCoder, NSEvent, NSPoint, NSRect

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.16
Nodes (5): NSCursor, NSPasteboard, String, UInt8, URL

### Community 312 - "AgentSnapshot"
Cohesion: 0.22
Nodes (6): merged, JSONMerge, Any, Bool, String, JSONMergeTests

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.21
Nodes (4): NotificationCenterProbe, Bool, Void, NotificationCenterProbeTests

### Community 314 - "code:bash (harness-cli install-hooks codex)"
Cohesion: 0.22
Nodes (4): Date, String, TerminalBlock, TerminalBlockStore

### Community 316 - "code:bash (harness-cli install-hooks opencode)"
Cohesion: 0.25
Nodes (4): StatusLineWidthTests, StatusLineWidth, String, StyledSegment

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.15
Nodes (12): Architecture, Browser DevTools API (P28), Config, Key Bug Fixed: Round-Trip Timeout (RL-048), Key Files, Phase 1 — Core (all via evaluateJS or WKWebView native), Phase 2 — Network, Phase 3 — Storage (+4 more)

### Community 319 - "FormatColor"
Cohesion: 0.15
Nodes (12): Bug: Tab-Switch Black Screen, Files changed, Final fast-path guard (PaneLifecycleManager.swift), FM-1: detachHostsOnly() before caching (always broken), FM-2: force=true rebuild caches the stripped container, FM-3: Host theft by another tab's build, FM-4: Cache overwrite leaks orphan containers, Instrumentation method (+4 more)

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.19
Nodes (7): PluginLoader, String, ScriptAPI, ScriptError, evaluationError, unsupportedPlatform, JavaScriptCore

### Community 321 - "UInt64"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 322 - "DesktopNotifier"
Cohesion: 0.18
Nodes (7): Error, Bool, NSView, String, TimeInterval, Toast, ToastBody

### Community 323 - "LayoutNode"
Cohesion: 0.40
Nodes (6): HarnessChrome, HarnessChromePalette, Bool, CGFloat, NSColor, String

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.18
Nodes (5): GitResult, Bool, NSEvent, NSGestureRecognizer, GitPanelViewFSEventFilterTests

### Community 325 - "FloatingPaneController"
Cohesion: 0.24
Nodes (7): Container, NotchPulseHost, Content, Context, NSCoder, NSHostingView, NSRect

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.35
Nodes (4): SidebarBadgeView, NSCoder, NSRect, NSPressGestureRecognizer

### Community 327 - ".theme"
Cohesion: 0.23
Nodes (6): CaseIterable, Mode, compatible, harness, TerminalIdentity, TerminalIdentityTests

### Community 328 - "README.md"
Cohesion: 0.19
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.28
Nodes (11): atomicWrite(), backupCorruptFile(), fnv1aHex(), HarnessPathsError, socketPathTooLong, Bool, Data, String (+3 more)

### Community 330 - ".drawGlyph"
Cohesion: 0.19
Nodes (3): RemoteHostStoreTests, String, URL

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 332 - "Added"
Cohesion: 0.27
Nodes (9): Array, Bool, Date, Decoder, PaneID, PaneNode, String, TabID (+1 more)

### Community 333 - "RealPty"
Cohesion: 0.22
Nodes (7): PasteController, Bool, Data, NSPasteboard, String, TimeInterval, URL

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.17
Nodes (7): ResizeHUDView, DispatchWorkItem, NSCoder, NSColor, NSPoint, NSRect, TimeInterval

### Community 337 - "CommandExecutionError"
Cohesion: 0.26
Nodes (3): BellScanTests, Bool, UInt8

### Community 338 - "CSIParams"
Cohesion: 0.28
Nodes (4): PaneLabelDaemonTests, String, URL, UUID

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.17
Nodes (11): ACP vs MCP vs Terminal Chat, AgentProcessManager, Architecture, CLI Print-Mode Args, Context Injection, Key Files, Key Shortcuts (I-family), Non-Obvious Constraints (+3 more)

### Community 342 - "Added"
Cohesion: 0.17
Nodes (11): 1. `SessionLifecycleService.swift` (tab bar clicks, sidebar clicks), 2. `MainExecutor.swift` (keyboard shortcuts — the actual user path), Competitive research (from Agy), Data model (correct, no changes needed), Files to read before resuming, Fix applied (compiles, not fully tested), Focus Persistence — Per-Session-Tab Pane Focus (RL-043), Restoration flow (after fix) (+3 more)

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.24
Nodes (5): CwdMetadataProvider, GitMetadataProvider, MetadataProvider, String, Tab

### Community 344 - "FileViewerViewController"
Cohesion: 0.24
Nodes (6): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 345 - "README.md"
Cohesion: 0.27
Nodes (6): DisplayPanesOverlay, Any, NSEvent, NSView, SurfaceID, Void

### Community 346 - "Agent platform icons"
Cohesion: 0.23
Nodes (10): AgentRow, HookState, failed, idle, installed, installing, SettingsAgentsView, Bool (+2 more)

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.20
Nodes (9): SettingsTerminalView, Bool, String, TriState, auto, off, on, Typography (+1 more)

### Community 348 - "DaemonLifecycleTests"
Cohesion: 0.20
Nodes (6): CGFloat, NSColor, NSPoint, NSRect, NSWindow, WindowBorderOverlayView

### Community 349 - "Contents.json"
Cohesion: 0.29
Nodes (6): Notification.Name, NSCoder, NSRect, NSTextView, SyntaxLineNumberGutterView, SyntaxTextViewInner

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.29
Nodes (3): Any, GitPanelViewDiffErrorTests, String

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.26
Nodes (5): SidebarBadgeLabel, SidebarSessionItemRow, BoardColumnKind, SessionGroup, String

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.27
Nodes (5): NSCoder, NSHostingView, NSRect, Tab, TerminalTabBarView

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.17
Nodes (12): CodingKey, CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version (+4 more)

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.36
Nodes (3): Install, Shell integration (OSC 133 semantic prompts), What gets emitted

### Community 355 - ".deepMerge"
Cohesion: 0.23
Nodes (5): cols, AgentListFormatterTests, Bool, Date, String

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.41
Nodes (5): InstallResult, ShellCompletionInstaller, Bool, String, URL

### Community 357 - ".handleCat"
Cohesion: 0.29
Nodes (4): SessionStore, DispatchWorkItem, SessionSnapshot, TimeInterval

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 360 - "State"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 362 - "RGBColor"
Cohesion: 0.29
Nodes (3): Bool, String, ThaiClusterRenderTests

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.17
Nodes (12): 1. Install Harness, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Harness Usage, More Docs (+4 more)

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.18
Nodes (10): 1. SurfaceShellTracker (proc tree walk), 2. DaemonSyncService.startMetadataRefresh (5-s loop), 3. snapshotChanged Fanout, 4. PerfCounters — Instrumentation, 5. Performance Lessons (v3.2.0), Adaptive polling, Background Polling & Snapshot Fanout — P22, Known Non-P22 Callers of syncFromDaemon (+2 more)

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.18
Nodes (10): AI / Agent Connectivity, Architecture Decisions — harness-terminal, Browser Pane, Config / Settings, File Preview / Split Panes, IPC / Daemon, Keybindings, Sessions / Tabs (+2 more)

### Community 366 - "Consumers"
Cohesion: 0.18
Nodes (10): Cause 1 — `existingHosts` strong dict in TerminalPaneRegistry (DOMINANT), Cause 2 — Insert-only AI controller dicts in SessionCoordinator, Cause 3 — Uncapped browser network capture array, Memory Leak Audit — 34 GB Long-Session Case (2026-06-26), Pattern to watch: "insert-only per-surface dict", Release, Root causes found and fixed, Symptom (+2 more)

### Community 367 - "DaemonStats"
Cohesion: 0.18
Nodes (10): Burst Coalescing (cmux NotificationBurstCoalescer), CA Mask Pattern (Harness Notch), Combine → CA Bridge, Equality Guard (Zed layout phase), GPU Animation Pattern — Layout Once, GPU Paints, Layer Coordinate System, Principle, References (+2 more)

### Community 368 - "Tab"
Cohesion: 0.31
Nodes (4): CLIInstaller, Bool, String, URL

### Community 369 - "Git Panel"
Cohesion: 0.38
Nodes (3): SettingsAdvancedView, Bool, String

### Community 371 - "P13 — Embedded Browser Pane (cmux parity)"
Cohesion: 0.25
Nodes (5): BoardColumnKind, Bool, NSColor, SessionGroup, String

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.25
Nodes (5): MTLCommandBuffer, CAMetalDrawable, MTLTexture, UInt64, TerminalRenderStats

### Community 373 - "Prompt"
Cohesion: 0.29
Nodes (7): SessionSnapshot, SurfaceSummary, Bool, Date, Decoder, String, WorkspaceID

### Community 375 - ".install"
Cohesion: 0.29
Nodes (7): AgentNotification, OSCNotificationParser, DaemonSurfaceID, Data, Date, String, SurfaceID

### Community 376 - "ScrollReuseTests"
Cohesion: 0.45
Nodes (3): data, SixelDecoder, UInt8

### Community 377 - "Identifiable"
Cohesion: 0.36
Nodes (5): ShellInfo, ShellStepView, Bool, String, URL

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.24
Nodes (7): RGBColor, Bool, Decoder, Double, Encoder, String, UInt8

### Community 379 - "MCPServer"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, String, TerminalEmulator

### Community 380 - "PromptQueue"
Cohesion: 0.31
Nodes (3): ReflowPreviewTests, String, TerminalEmulator

### Community 381 - "smoke-dmg.sh"
Cohesion: 0.33
Nodes (3): HarnessTerminalSurfaceWorkerTests, Bool, HarnessTerminalSurfaceView

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.29
Nodes (4): FrameBuilderCopyModeTests, RGBColor, String, TerminalGridSnapshot

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.20
Nodes (9): 1. Sidebar toggle (⌘\), 2. File preview open/close, 3. Tab switch (⌘1-9, ✕ close), 4. presentsWithTransaction order fix (ALL remaining flash cases) — v3.9.x+, Fixes Applied (v3.9.1+), Related Lessons, Root Cause Pattern, Rules (+1 more)

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.20
Nodes (9): 1. Board Sidebar Tab (GUI), 2. Harness CLI Command, 3. Scripting API, 4. Read-Only MCP Tool, Agent/Session Board (P16), Centralized Classification, Consumers, Data Model (PBI-BOARD-001) (+1 more)

### Community 385 - "INDEX.md"
Cohesion: 0.20
Nodes (9): Architecture, Branch chip — CASE-020, Features, FSEvents Pattern (Swift Actor), Git Panel, History → File Editor, Real-time Refresh, v1 — CASE-009 (resolved, superseded) (+1 more)

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.22
Nodes (8): AnyObject, CommandExecutionError, daemonError, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor, String

### Community 387 - "User Profile"
Cohesion: 0.20
Nodes (9): MatchCategory, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith, filenameStartsWith, fuzzy, pathContains (+1 more)

### Community 388 - "Darwin"
Cohesion: 0.36
Nodes (4): DisplayMessage, RunShell, MainActor, String

### Community 389 - "HarnessCLITests"
Cohesion: 0.33
Nodes (6): Bool, NSPasteboard, NSString, String, URL, AutoreleasingUnsafeMutablePointer

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.29
Nodes (4): Bool, SessionCoordinator, String, ThemeService

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.24
Nodes (5): Bool, NSObjectProtocol, Set, String, WorktreeAutoIsolateService

### Community 392 - "build-release.sh"
Cohesion: 0.36
Nodes (3): BrowserIntegrationController, NSView, PaneID

### Community 393 - "create-dmg.sh"
Cohesion: 0.20
Nodes (10): Section, actions, errors, files, grep, navigation, projects, recent (+2 more)

### Community 395 - "generate-app-icon.sh"
Cohesion: 0.40
Nodes (5): CGFloat, Range, TabBarLayoutMetrics, TerminalTabBarBody, TerminalTabBarModel

### Community 396 - "generate-appcast.sh"
Cohesion: 0.24
Nodes (7): MTLLibrary, MTLRenderPipelineState, CGFloat, MTLBuffer, MTLDevice, String, T

### Community 397 - "measure-fluidity.sh"
Cohesion: 0.20
Nodes (9): AgentHookStrategy, eventArrayJSON, eventMatcherJSON, ownJSONFile, ownTextFile, regionEdit, Any, Bool (+1 more)

### Community 399 - "sign-and-notarize.sh"
Cohesion: 0.20
Nodes (6): LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled

### Community 400 - "install-linux.sh"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 401 - "package-app.sh"
Cohesion: 0.27
Nodes (6): AmbientBackground, Bool, CGSize, GraphicsContext, TimeInterval, UInt8

### Community 402 - "View"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 403 - "themes.json"
Cohesion: 0.29
Nodes (8): FormatColor, none, palette, rgb, StyledSegment, Bool, String, UInt8

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.20
Nodes (6): FormatContextDaemonTests, PaneID, SessionSnapshot, String, SurfaceID, URL

### Community 405 - ".measure"
Cohesion: 0.24
Nodes (4): GroupedSessionDaemonTests, SessionGroup, String, URL

### Community 406 - "main.swift"
Cohesion: 0.33
Nodes (4): GridCompositorCopyModeTests, PaneRect, String, TerminalGridSnapshot

### Community 407 - "Fixed"
Cohesion: 0.36
Nodes (5): OcclusionTests, HarnessTerminalSurfaceView, NSWindow, String, TimeInterval

### Community 408 - "IPC Architecture"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.22
Nodes (8): CASE-063a — sound toggle, CASE-063b — click doesn't route, Files, Fix Applied, If Fix Is Insufficient, Notification Sound Toggle Ignored + Banner Click Didn't Navigate, Root Cause, Symptom

### Community 410 - ".applyTerminalIdentity"
Cohesion: 0.22
Nodes (8): Detection Method, Fix, NSTextField Leak in BoardViewController (P20 Performance), Prevention Rules, Related Files, Root Cause, Symptom, Why CPU Goes Up

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.22
Nodes (8): Accessibility Requirements, Files, Permission, Running, Stack, Test Strategy, UI Automation — Robot Framework (P18), Why Not Appium

### Community 412 - "go.json"
Cohesion: 0.22
Nodes (8): AppKit / Views, Architecture / Daemon, Browser / WKWebView, Git / Process, Notifications / UserNotifications, RL Lessons — harness-terminal, Swift 6 / Concurrency, Testing / Environment

### Community 413 - "javascript.json"
Cohesion: 0.22
Nodes (8): AppKit + Metal Patterns, CADisplayLink Lifetime on macOS (CASE-031), Metal Surface Lifecycle (CASE-003), Mouse Selection Must Use Virtual-Line Coordinates (CASE-029), NSFont Italic (CASE-010), NSView Layer Opacity — Preview Parity Pattern (CASE-011), Overlay Above Metal (CASE-004), Window Background Tint for Legibility (CASE-027)

### Community 414 - "json.json"
Cohesion: 0.22
Nodes (8): Architecture, Infinite Recursion (CASE-006), Pane Drag-and-Drop (P27), Ratio Persistence (CASE-002), Split CWD Resolution — Worktree Priority (2026-06-21), Split Panes (NSSplitView), Subview Reorder (CASE-007), Two-Axis Split Parity (P13)

### Community 415 - "markdown.json"
Cohesion: 0.22
Nodes (5): Completed Plans Archive, Active Plans, Completed, Plans Index — harness-terminal, Quick ref — recent completions

### Community 416 - "python.json"
Cohesion: 0.31
Nodes (6): AnimatablePair, NotchShape, CGFloat, CGPath, CGRect, Path

### Community 417 - "rust.json"
Cohesion: 0.36
Nodes (5): PaneLeaf, SessionGroup, Any, String, Tab

### Community 419 - "typescript.json"
Cohesion: 0.42
Nodes (5): LoadCompletionState, CheckedContinuation, Error, TimeInterval, Void

### Community 420 - "yaml.json"
Cohesion: 0.36
Nodes (3): SplitDirection, TabID, TerminalTabBarDelegate

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Harness keybindings, Key spec syntax, Persistence (+1 more)

### Community 422 - "HintModeOverlay"
Cohesion: 0.25
Nodes (4): ControlKeyNormalizer, Bool, String, ControlKeyNormalizerTests

### Community 423 - "CopyModeLine"
Cohesion: 0.22
Nodes (6): TabStatus, done, error, idle, running, waiting

### Community 424 - "HarnessCore"
Cohesion: 0.22
Nodes (7): TerminalEmulator, RawSelection, SelectionResolver, Bool, HarnessTerminalSurfaceView, String, TerminalEmulator

### Community 425 - "AgentVectorIcon"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.42
Nodes (7): plist_set(), require_clean_tracked_worktree(), run(), release-hotfix.sh script, update_readme_download(), usage(), write_release_notes()

### Community 427 - ".delay"
Cohesion: 0.47
Nodes (3): ScrollReuseTests, HarnessTerminalSurfaceView, NSWindow

### Community 428 - "P9: Code Complexity Reduction & Structural Refactoring"
Cohesion: 0.28
Nodes (5): SpecialKeyMappingTests, Bool, NSEvent, String, UInt16

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.25
Nodes (6): 2026-06-25 — OSC 7735:  opens sidebar file viewer, 2026-06-27 — Block output tint + AI explain (Phase 12b), Pruned from MEMORY.md — 2026-07-02, Pruned from MEMORY.md — 2026-07-03, Pruned from MEMORY.md — 2026-07-04, Task Ledger Archive (Tasks 1–50)

### Community 431 - "P6: File Editor Opacity Parity with Terminal"
Cohesion: 0.25
Nodes (7): Framing, IPC Architecture, Key Invariant, Overview, Process Separation, Security, Subscriptions

### Community 432 - ".initialState"
Cohesion: 0.25
Nodes (7): ⌘1-9 and ⌘[ / ⌘] = Session-level navigation (CASE-028), Data Model, Session/Tab/Pane Hierarchy & Top Bar (CASE-028), Sidebar Session Groups = One Header Per SessionGroup, Source Map, Tab Pill Visual Details, Top Bar = 1 Pill Per Session (not per-tab)

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.25
Nodes (7): Bug — Cmd+\ sidebar toggle gone after collapse, Confirmed facts, Fix, Related, Suspect A — Dead token guard (confirmed code bug), Suspect B — Zero-delta early exit trap, Symptom

### Community 434 - "Project History"
Cohesion: 0.25
Nodes (7): Case: cwd "bleed" — session worktree jumps to wrong dir during builds, Companion bug: blank panel on first open (CASE-042), Fix, Lesson, Repro (deterministic, headless — no GUI needed), Root cause, Symptom

### Community 435 - ".highlight"
Cohesion: 0.25
Nodes (7): Competitive Position (as of v3.12.0, 2026-07-02), Feature Matrix (2026-07-02), Harness Gaps, Harness Wins, Known Limitations (honest assessment), Positioning Statement, Unique Selling Points (no competitor has all)

### Community 436 - "WaitForRegistry"
Cohesion: 0.25
Nodes (7): Apple Platform Context — Transparency & Legibility, Architecture Decisions, iOS/macOS 26 — Liquid Glass introduction, iOS/macOS 27 — Liquid Glass refinements (WWDC 2026), Known Issues (Current), Project History, Sprint Timeline

### Community 437 - "Feature Specs"
Cohesion: 0.25
Nodes (8): F1: Mobile Package Targets — P0, F2: Network Endpoint for IPC — P0, F3: Pairing and Trust — P0, F4: UIKit Terminal Surface — P0, F5: iPad Workspace UX — P1, F6: Remote Session Lifecycle — P1, F7: Files and Sharing — P2, Feature Specs

### Community 438 - "SessionEditor"
Cohesion: 0.25
Nodes (8): Implementation Phases, Phase 0 — Feasibility Spike (P0), Phase 1 — Shared Renderer Extraction (P0), Phase 2 — Mobile IPC Transport (P0), Phase 3 — UIKit Terminal MVP (P0), Phase 4 — iPad App Shell (P1), Phase 5 — Multiplexer Parity (P1), Phase 6 — Polish and Platform Integration (P2)

### Community 440 - "Implementation Phases"
Cohesion: 0.36
Nodes (4): AboutPanelController, AboutView, NSWindow, NSHostingController

### Community 441 - "RemoteHostStore"
Cohesion: 0.29
Nodes (6): RepoEntry, escaping, MainActor, Void, WatcherContext, CoreServices

### Community 443 - "AgentIconRenderer"
Cohesion: 0.43
Nodes (3): StageToggleButton, NSCoder, NSRect

### Community 445 - "Section"
Cohesion: 0.32
Nodes (4): CopyModeLine, Character, ClosedRange, String

### Community 447 - "Key Files"
Cohesion: 0.25
Nodes (8): CodingKeys, createdAt, dataBase64, rows, surfaceID, timeMs, type, version

### Community 448 - "NSSplitView Patterns"
Cohesion: 0.36
Nodes (4): object, HarnessSettings, Bool, Data

### Community 449 - ".run"
Cohesion: 0.39
Nodes (4): OutputTrigger, OutputTriggerStore, Bool, String

### Community 450 - "RecordSession"
Cohesion: 0.32
Nodes (3): BrowserLeaf, URL, PaneNodeBrowserTests

### Community 451 - "FormatContext"
Cohesion: 0.36
Nodes (3): HarnessSplitViewTests, LayoutProbeView, CGFloat

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.46
Nodes (3): SessionSnapshot, Tab, WorkbenchContextResolverTests

### Community 455 - "ComposerPanel"
Cohesion: 0.36
Nodes (3): BlockContextMenuTests, HarnessTerminalSurfaceView, String

### Community 456 - "PBI-SCRIPT-001: Runtime shell and config discovery"
Cohesion: 0.29
Nodes (6): Command Prompt Architecture, Files, Gotchas, Key rule: every documented verb needs BOTH layers, Layers, Verb categories

### Community 457 - "StartupMetrics"
Cohesion: 0.29
Nodes (6): Anti-Patterns Avoided, Architecture, Key Design Decisions, Pattern, Service Decomposition — SessionCoordinator (P17), When to Apply This Pattern

### Community 458 - "code:swift (nonisolated(unsafe) var blinkTimer: Timer?)"
Cohesion: 0.29
Nodes (6): Browser Tab Close Button Unresponsive, Files, Fix Applied, If Fix Is Insufficient, Root Cause, Symptom

### Community 459 - ".encode"
Cohesion: 0.29
Nodes (6): Architecture / Keybindings, CASE — Git / FS / Terminal / Architecture, Claude Code / Tooling / Environment (the agent running *inside* Harness), Command Prompt / Parser, Git / File System, Terminal / Renderer / Daemon

### Community 460 - "Fork Context"
Cohesion: 0.29
Nodes (6): ACP Client (Shelved), Architecture (Preserved), Re-enablement Criteria, Status: SHELVED (June 2026), What It Is, Why Shelved

### Community 461 - "PaneLabelDaemonTests"
Cohesion: 0.29
Nodes (6): Build Scripts Self-Kill Protection, Detection, Fix (applied in `Scripts/run.sh`), Key Invariant, Problem, Related

### Community 462 - "AGENTS.md"
Cohesion: 0.29
Nodes (6): Architecture Preferences, Domain Expertise, Identity, Project Scope, User Profile, Workflow Preferences

### Community 464 - "element_should_exist"
Cohesion: 0.29
Nodes (5): DirectionalAxis, down, left, right, up

### Community 468 - "code:block1 (PaneNode (HarnessCore))"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 469 - "PBI-SCRIPT-002: Reload lifecycle"
Cohesion: 0.29
Nodes (7): Agent hooks for Harness, CLI notification, Example Claude Code hook, Jump to waiting agent, OSC sequences (from terminal output), Per-agent guides, Set up via your IDE (copy/paste prompt)

### Community 470 - "PBI-SCRIPT-003: Read-only API bridge"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Harness the default terminal, Migrating to Harness

### Community 471 - ".evaluateStyled"
Cohesion: 0.29
Nodes (7): 1. Plain Terminal, 2. Persistent Terminal, 3. Full Terminal, 4. Agent Workspace, Experience modes, Opting into the prefix + status line without switching modes, Persistence (ephemeral vs. persistent)

### Community 472 - "start.sh script"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Harness-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 474 - "code:json ({)"
Cohesion: 0.62
Nodes (3): AgentListFormatter, Date, String

### Community 475 - "PBI-ORCH-001: Read-only daemon connection"
Cohesion: 0.29
Nodes (6): NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, Bool

### Community 476 - ".steps"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 477 - "code:swift (public struct BrowserLeaf: Codable, Sendable, Equatable {)"
Cohesion: 0.48
Nodes (3): ANSIPalette, RGBColor, UInt8

### Community 478 - ".install"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 480 - "Command Prompt Architecture"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Harness Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 481 - "code:swift (// harnessBrowserOpen — opens new browser pane, returns pane)"
Cohesion: 0.33
Nodes (5): Codex Fix Prompt Template, FSEvents Recursive Watcher Pattern (Swift), Full Swift Actor Pattern, Single-file watch (DispatchSource is enough), When to use

### Community 482 - "code:javascript ((function() {)"
Cohesion: 0.33
Nodes (6): Active Decisions, Conventions, Knowledge Index, Memory — harness-terminal, Protocol Compliance Notes, Tech Debt

### Community 484 - "Added"
Cohesion: 0.33
Nodes (3): Date, TabPillView, Gesture

### Community 485 - "code:javascript (// click e3 → find 3rd interactive element, el.click() + dis)"
Cohesion: 0.33
Nodes (5): Claude Code → Harness, Customizing, One-line install, Verifying, What gets written

### Community 486 - "Current State"
Cohesion: 0.33
Nodes (6): Board and attention, Errors and LSP, File navigation, Search, Task runner, Workbench commands (IDE-like workflow)

### Community 487 - "[1.1.2] - 2026-06-02"
Cohesion: 0.33
Nodes (5): Local release path, One-time GitHub setup, Release runbook, Running a release from GitHub, What the workflow publishes

### Community 488 - "Non-Goals"
Cohesion: 0.33
Nodes (5): Harness vs Competitors (Remote Development over SSH), Our Gaps (vs leaders), Our Strengths, Remote SSH — Market Comparison, Roadmap Opportunities

### Community 489 - "Added"
Cohesion: 0.40
Nodes (3): HarnessGridTerminal, TerminalGridCell, TerminalEmulator

### Community 490 - "P7: Sidebar UI Polish — Large Screen Layout"
Cohesion: 0.60
Nodes (4): CLICommand, CLICommandCatalog, Bool, String

### Community 491 - "Added"
Cohesion: 0.53
Nodes (3): ProjectConfig, Bool, String

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.33
Nodes (6): RawSelection, Bool, SelectionGranularity, character, line, word

### Community 493 - "Browser Tab Close Button Unresponsive"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 494 - "PBI-BROWSER-001: Browser view shell"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 495 - "terminal-cheat-sheet.html"
Cohesion: 0.53
Nodes (3): TerminalGridCell, ThaiClusterCopyTests, ThaiGrid

### Community 498 - "SystemdUserInstaller"
Cohesion: 0.40
Nodes (3): String, URL, ThemeCatalogEmbedTests

### Community 499 - "release.yml"
Cohesion: 0.40
Nodes (5): Build matrix, Integration tests, Manual test checklist, Testing and Verification, Unit tests

### Community 500 - "RemoteHostsService"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 501 - "Fixed"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 502 - "ACP Client (Shelved)"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 503 - "Build Scripts Self-Kill Protection"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 504 - "PBI-BROWSER-003: Persistence"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 505 - "Fixed"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 506 - "KittyGraphicsCommand"
Cohesion: 0.70
Nodes (4): main(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 510 - "graphify reference: extra exports and benchmark"
Cohesion: 0.50
Nodes (3): Grok Build → Harness, One-line install, What you'll see

### Community 511 - "State"
Cohesion: 0.50
Nodes (3): __harness_osc133_postexec, __harness_osc133_preexec, __harness_osc133_prompt

### Community 512 - "Changelog Archive"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 513 - "ThemeDocument"
Cohesion: 0.50
Nodes (3): exclude_hubs, no_viz, wiki

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.50
Nodes (3): SplitDirection, horizontal, vertical

### Community 517 - "Known Gap: Divergent P4 Docs"
Cohesion: 0.50
Nodes (4): PresentAttempt, encodeFailure, nilDrawable, presented

### Community 518 - "HarnessDaemonTools"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

## Knowledge Gaps
- **1583 isolated node(s):** `unsupportedPlatform`, `unmodified`, `modified`, `added`, `deleted` (+1578 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **551 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `AboutView`, `AgentActivity`, `AgentApprovalBar`, `AgentInboxBody`, `AgentInboxPanelView` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `Equatable` to `CodingKey`, `callingPaneTarget`, `.handleNormal`, `Changed`, `EngineConformanceTests`, `IPCRequest`, `[1.3.0] - 2026-06-04`, `Command`, `LSPMessage`, `TerminalEmulator`, `AgentNotchRootView`, `GitPanelView.swift`, `Changed`, `KittyKeyboardTests`, `VTParser`, `Agent hooks for Harness`, `.applyPreedit`, `MetalRendererTests`, `code:block11 (PBI-UI-001  Add accessibilityIdentifiers     [Low effort, un)`, `SpecialKey`, `code:block1 (Agent shell process)`, `HarnessTerminalSurfaceView`, `CopyModeAction`, `SplitPaneCoordinator`, `HarnessTerminalSurfaceView`, `WorktreeManager`, `.request`, `RGBColor`, `Harness tmux-style capabilities`, `Added`, `Notification`, `Sendable`, `.addTab`, `DaemonClient`, `MenuTarget`, `code:bash (harness chat "Use the project map first, then inspect this r)`, `Fixed`, `code:bash (swift build)`, `TerminalColorGamut`, `Fixed`, `harness.resource`, `code:js (harness.profiles.use("ide-migrant-terminal"))`, `RenderSchedulerTests`, `String`, `HarnessTerminalSurfaceView.swift`, `.buildCommand`, `HarnessSettings`, `CodingKeys`, `HarnessOverlayBackground`, `Added`, `Fixed`, `Added`, `TabCell`, `NSPanel`, `BellScanState`, `3.2 สิ่งที่ implement แล้ว`, `ViEngine`, `FrecencyDirectoryStore`, `ComposedCell`, `HarnessCLI+Server.swift`, `.text`, `PrefixKeymap`, `ShellIntegration`, `String`, `Completed Plans Archive`, `.compose`, `worktree_isolation_cli.robot`, `ImportedTerminalConfig`, `XCTestCase`, `OptionStore`, `Agent handbook — Harness (extended reference)`, `DaemonSubscription`, `.firstMatch`, `LSPClient`, `LSPDiagnostic`, `HarnessPaths`, `SessionCoordinator`, `Harness as a terminal multiplexer`, `Zombie View Crashes on macOS 26.5 + Swift 6.3.2`, `Fixed`, `P2 — Async IPC Refactor: Design Document`, `AttachInputBatcher`, `Harness Usage`, `4. Technical Architecture`, `.dispatch`, `Session Grouping and Split Session Plan`, `AnyCodable`, `Recipe`, `Changelog`, `domain-design.md`, `AgentNotchViewModel`, `.resolve`, `DamageTrackingTests`, `SoftIconButton`, `code:text (:workbench start swift)`, `HarnessGridTerminal`, `.firstWaitingTab`, `Fixed`, `code:block9 (--model sonnet       (Claude: sonnet/opus/haiku))`, `PaneNode`, `WorkspaceFileTreeView`, `Changed`, `ViEngine`, `Pipe`, `HistoryRingBuffer`, `.path`, `code:bash (:agent --claude --model sonnet --effort high "fix tests")`, `code:block1 (SessionCoordinator.snapshot ──┐)`, `.install`, `AgentHookInstaller`, `ActivePaneService`, `User Story Mapping (MANDATORY)`, `แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)`, `CopyModeGridSource`, `CodingKeys`, `PaneStyleSet`, `DecodedImage`, `HarnessDaemonToolsTests`, `.evaluate`, `What You Must Do When Invoked`, `LiveResizeTests`, `ThaiCombiningMarkTests`, `Added`, `MatchCategory`, `AmbientBackground`, `Workspace`, `CommandPromptController`, `LiveSession`, `AgentTableEntry`, `Added`, `URLDetection`, `.decodeKeySpec`, `BinaryRefresherTests`, `RGBColorTests`, `.rects`, `[3.13.1] - 2026-07-02`, `VTConformanceCorpusTests`, `SessionSnapshot`, `Error`, `AppDelegate`, `BrowserPaneView`, `P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client`, `ScriptRuntime`, `BinaryInstallerVersionTests`, `Harness keybindings`, `From tmux`, `CopyModeState`, `SettingsRemoteView`, `PaneDropZoneOverlay`, `PaneTarget`, `NotchLayoutMetrics`, `.lines`, `CellColorResolverTests`, `GridCompositor`, `ScrollbackFile`, `Prompt`, `Section`, `TerminalServicesProvider`, `CellColorResolver`, `SSHTunnelManagerTests`, `sessionRow`, `.decide`, `HarnessGridTerminalTests`, `ExternalOpenKind`, `P10 Task: Lazy Scrollback Reflow`, `TerminalBlockStoreTests`, `TerminalMetalRenderer`, `Added`, `AgentBridge`, `FileNode`, `Experience modes`, `EngineConformanceTests`, `DaemonMetrics`, `ReflowPreviewTests`, `HarnessTerminalSurfaceWorkerTests`, `SessionCoordinator`, `Split Right`, `BoardViewController`, `Browser Pane (P14)`, `.install`, `P8: macOS 27 Golden Gate Adoption`, `.run`, `BlockTintOverlay`, `DisplayPanesOverlay`, `.menu`, `TerminalScrollbarView`, `RemoteHostStoreTests`, `FormatColor`, `.surfaceShellTrackerDidUpdateCwd`, `StatusLineWidthTests`, `Release runbook`, `Fixes Applied (layered)`, `GitHubCLIClient`, `AgentApprovalBar`, `Send Ex Command`, `[1.8.0] - 2026-06-07`, `FrameSignposter`, `Bug: Tab-Switch Black Screen`, `code:bash (harness-cli install-hooks codex)`, `code:bash (harness-cli install-hooks opencode)`, `LayoutNode`, `.theme`, `ImmersivePalette.swift`, `.recordReapedGenerationForTesting`, `Added`, `RealPty`, `ImageProtocolTests.swift`, `README.md`, `Contents.json`, `OcclusionTests`, `RGBColor`, `P13 — Embedded Browser Pane (cmux parity)`, `DynamicInstanceBuffer`, `Prompt`, `ScrollReuseTests`, `Added`, `MCPServer`, `PromptQueue`, `ThaiClusterRenderTests`, `User Profile`, `Darwin`, `create-dmg.sh`, `finalize-release.sh`, `generate-app-icon.sh`, `generate-appcast.sh`, `preview.sh`, `install-linux.sh`, `themes.json`, `main.swift`, `IPC Architecture`, `yaml.json`, `HarnessCore`, `BlockContextMenuTests`, `Section`, `─────────────────────────────────────────────────────`, `code:json ({)`, `code:swift (public struct BrowserLeaf: Codable, Sendable, Equatable {)`, `.install`, `Added`, `Added`, `Service Decomposition — SessionCoordinator (P17)`, `terminal-cheat-sheet.html`, `Fixed`, `Build Scripts Self-Kill Protection`, `start.mjs`?**
  _High betweenness centrality (0.369) - this node is a cross-community bridge._
- **Why does `HarnessCore` connect `SessionGroup` to `CodingKey`, `Changed`, `EngineConformanceTests`, `IPCRequest`, `LSPMessage`, `TerminalEmulator`, `PerformanceBenchmarks`, `code:block2 (HarnessApp ──→ HarnessCore (residual) ──→ HarnessIPC)`, `Changed`, `KittyKeyboardTests`, `VTParser`, `HarnessTerminalSurfaceView`, `.applyPreedit`, `HarnessUILibrary`, `SpecialKey`, `HarnessTerminalSurfaceView`, `code:bash (pip install robotframework)`, `WorktreeManager`, `RGBColor`, `Added`, `Notification`, `Sendable`, `Task Ledger Archive (Tasks 1–50)`, `.addTab`, `code:bash (harness chat "Use the project map first, then inspect this r)`, `CodingKeys`, `RenderSchedulerTests`, `HarnessTerminalSurfaceView.swift`, `.buildCommand`, `.normalizedKey`, `HookEvent`, `Added`, `.keyEvent`, `Fixed`, `TabCell`, `PasteBufferStore`, `.text`, `PrefixKeymap`, `ShellIntegration`, `String`, `worktree_isolation_cli.robot`, `ImportedTerminalConfig`, `README.md`, `[2.6.0] - 2026-06-13`, `TerminalProtocolCompatibilityTests`, `HarnessDesign`, `Agent handbook — Harness (extended reference)`, `DaemonSubscription`, `LSPClient`, `LSPDiagnostic`, `Harness as a terminal multiplexer`, `Zombie View Crashes on macOS 26.5 + Swift 6.3.2`, `TerminalModes`, `P2 — Async IPC Refactor: Design Document`, `PaneContainerView`, `.dispatch`, `AnyCodable`, `domain-design.md`, `AgentNotchViewModel`, `.resolve`, `.makeSnapshot`, `.firstWaitingTab`, `.encode`, `PaneNode`, `WorkspaceFileTreeView`, `Harness command reference`, `Changed`, `ViEngine`, `Pipe`, `String`, `GlyphAtlas`, `code:block1 (SessionCoordinator.snapshot ──┐)`, `SwiftUI`, `Harness`, `CommandTarget`, `.startWatching`, `แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)`, `Added`, `How to use Harness from the terminal only (no GUI)`, `FileTreeWatcher`, `Fixed`, `EnvironmentStore`, `HarnessDaemonToolsTests`, `.evaluate`, `Added`, `Fixed`, `LiveResizeTests`, `Int`, `Added`, `MatchCategory`, `AmbientBackground`, `What You Must Do When Invoked`, `Added`, `ReflowCorpusTests`, `BoardCard`, `BinaryRefresherTests`, `.rects`, `[3.13.1] - 2026-07-02`, `VTConformanceCorpusTests`, `P25 — iOS/iPadOS Support`, `LSPServerRegistry`, `SessionSnapshot`, `ScriptRuntime`, `GlyphRasterizer`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `ResizeHUDView`, `Feature Provenance — harness-terminal`, `AgentSessionSummary`, `.classify`, `Status: Planning`, `code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)`, `scheduleRender`, `.testDataFrameEncodeVsJSONBase64Output`, `PaneTarget`, `.translate`, `String`, `NotchLayoutMetrics`, `ScrollbackFile`, `FileChangeWatcher`, `Added`, `TerminalBlockStoreTests`, `.make`, `FileNode`, `ThemeDocumentTests`, `BoardViewController`, `Sidebar SwiftUI Migration — Knowledge`, `WindowTitleStripView`, `.welcome`, `HarnessSidebarPanelViewController`, `.path`, `.performInstall`, `code:bash (# Old (agent-specific):)`, `WindowSession`, `StatusLineView.swift`, `[2.5.0] - 2026-06-12`, `SyntaxTextView`, `TerminalScrollbarView`, `.apply`, `AgentHookStrategy`, `Process`, `JSONDecoder`, `Fixes Applied (layered)`, `AgentApprovalBar`, `PaneNode`, `.parse`, `RegressionBugFixTests`, `ViPathTokenTests`, `Browser DevTools API (P28)`, `[2.0.0] - 2026-06-07`, `AgentSnapshot`, `Terminal AI Chat (⌘I inline overlay)`, `code:bash (harness-cli install-hooks opencode)`, `Focus Persistence — Per-Session-Tab Pane Focus (RL-043)`, `.theme`, `README.md`, `.drawGlyph`, `RealPty`, `run.sh`, `CommandExecutionError`, `CSIParams`, `Agent platform icons`, `[3.2.0] - 2026-06-16`, `Contents.json`, `.deepMerge`, `State`, `Tab`, `Git Panel`, `.run`, `Darwin`, `UI Automation — Robot Framework (P18)`, `AppKit + Metal Patterns`, `build-release.sh`, `Split Panes (NSSplitView)`, `.measure`, `main.swift`, `IPC Architecture`, `rust.json`, `swift.json`, `HintModeOverlay`, `ACP Client`, `RemoteHostStore`, `Current State Snapshot (2026-06-14)`, `Real-time Refresh (CASE-009)`, `RecordSession`, `tmux parity — status, adaptations, and deliberate divergences`, `ReflowFastPathTests`, `HarnessOnboarding`, `ScrollbackTests`, `terminal-cheat-sheet.html`, `CASE — Git / FS / Terminal / Architecture`, `PBI-BROWSER-002: Pane model integration`?**
  _High betweenness centrality (0.046) - this node is a cross-community bridge._
- **Why does `AppKit` connect `.makeSnapshot` to `CodingKey`, `EngineConformanceTests`, `IPCRequest`, `[1.3.0] - 2026-06-04`, `LSPMessage`, `PerformanceBenchmarks`, `KittyKeyboardTests`, `OnboardingEnvironment`, `.request`, `WorktreeManager`, `Task Ledger Archive (Tasks 1–50)`, `String`, `TerminalColorGamut`, `CodingKeys`, `RenderSchedulerTests`, `HarnessTerminalSurfaceView.swift`, `.buildCommand`, `.keyEvent`, `Added`, `HarnessSplitView`, `TabCell`, `PasteBufferStore`, `worktree_isolation_cli.robot`, `ImportedTerminalConfig`, `README.md`, `[2.6.0] - 2026-06-13`, `.parse`, `TerminalProtocolCompatibilityTests`, `LSPClient`, `LSPDiagnostic`, `TerminalModes`, `Harness Usage`, `PaneContainerView`, `.dispatch`, `ScriptRuntime.swift`, `INDEX.md`, `domain-design.md`, `AgentNotchViewModel`, `.firstWaitingTab`, `ViEngine`, `Pipe`, `String`, `code:block1 (SessionCoordinator.snapshot ──┐)`, `.startWatching`, `AsciiFastPathTests`, `TriState`, `EnvironmentStore`, `LiveResizeTests`, `Int`, `ThaiCombiningMarkTests`, `Added`, `BoardCard`, `BinaryRefresherTests`, `.rects`, `VTConformanceCorpusTests`, `LSPServerRegistry`, `targets`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `ResizeHUDView`, `Feature Provenance — harness-terminal`, `AgentSessionSummary`, `.classify`, `HarnessCLI`, `scheduleRender`, `AgentNotchRowSummary`, `WorkbenchCommand`, `Added`, `.make`, `PaneBorderStatus`, `Added`, `Sidebar SwiftUI Migration — Knowledge`, `.path`, `.performInstall`, `code:bash (# Old (agent-specific):)`, `StatusLineView.swift`, `SGRMouseEvent`, `[2.5.0] - 2026-06-12`, `BlockTintOverlay`, `.apply`, `Process`, `JSONDecoder`, `Send Ex Command`, `Browser DevTools API (P28)`, `FrameSignposter`, `Focus Persistence — Per-Session-Tab Pane Focus (RL-043)`, `DesktopNotifier`, `LayoutNode`, `RealPty`, `ImageProtocolTests.swift`, `DaemonLifecycleTests`, `Contents.json`, `Tab`, `Darwin`, `UI Automation — Robot Framework (P18)`, `build-release.sh`, `View`, `P9: Code Complexity Reduction & Structural Refactoring`, `Implementation Phases`, `RemoteHostStore`, `FormatContext`, `ComposerPanel`, `audit.md`, `─────────────────────────────────────────────────────`, `ThaiClusterCopyTests.swift`, `start.mjs`?**
  _High betweenness centrality (0.035) - this node is a cross-community bridge._
- **Are the 43 inferred relationships involving `Int` (e.g. with `.register()` and `.coloredImage()`) actually correct?**
  _`Int` has 43 INFERRED edges - model-reasoned connections that need verification._
- **What connects `unsupportedPlatform`, `unmodified`, `modified` to the rest of the system?**
  _1603 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.052826310380267215 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.05343993267410057 - nodes in this community are weakly interconnected._