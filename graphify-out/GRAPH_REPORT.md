# Graph Report - perf-pass2-de-2026-11-16  (2026-11-16)

## Corpus Check
- 974 files · ~1,066,988 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 20344 nodes · 58730 edges · 2685 communities (1543 shown, 1142 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8662 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `70cfbbcf`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 346 edges
2. `i()` - 318 edges
3. `a()` - 282 edges
4. `SessionCoordinator` - 237 edges
5. `TerminalEmulator` - 235 edges
6. `SurfaceRegistry` - 232 edges
7. `DaemonClient` - 217 edges
8. `u()` - 217 edges
9. `IPCRequest` - 211 edges
10. `KouenCLI` - 210 edges

## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 191 areas (211 edges)
2. `Command` - bridges 101 areas (108 edges)
3. `AgentKind` - bridges 83 areas (176 edges)
4. `IPCResponse` - bridges 81 areas (107 edges)
5. `KouenTerminalSurfaceView` - bridges 76 areas (346 edges)
6. `SessionCoordinator` - bridges 69 areas (237 edges)
7. `KouenGridTerminal` - bridges 65 areas (117 edges)
8. `NSView` - bridges 64 areas (193 edges)
9. `SurfaceRegistry` - bridges 63 areas (232 edges)
10. `AnyCodable` - bridges 63 areas (190 edges)

## Surprising Connections (you probably didn't know these)
- `.selectedHost` --references--> `RemoteHost`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRemoteView.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.terms` --calls--> `SearchMatcher`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/UI/History/HistorySearchEvidence.swift → Packages/KouenCore/Sources/KouenCore/Search/SearchMatcher.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/RemoteHostsService.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.selectWorkspace(byIndex:)` --references--> `SessionSnapshot`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/SessionCoordinator.swift → Packages/KouenIPC/Sources/KouenIPC/SessionSnapshot.swift

## Import Cycles
- None detected.

## Communities (2685 total, 1142 thin omitted)

### Community 0 - "CodingKey"
Cohesion: 0.01
Nodes (765): _1n(), _1t(), _3e(), _3n(), _4e(), _5n(), _6e(), _9e() (+757 more)

### Community 1 - "callingPaneTarget"
Cohesion: 0.01
Nodes (569): f(), l, V, em(), z(), _4n(), _5e(), _6n() (+561 more)

### Community 2 - ".handleNormal"
Cohesion: 0.02
Nodes (386): pe(), r, X(), A(), code(), R(), a(), aDt() (+378 more)

### Community 3 - "Changed"
Cohesion: 0.06
Nodes (58): A1(), ast(), aw(), awt(), b2(), b6(), bw(), cw() (+50 more)

### Community 4 - "EngineConformanceTests"
Cohesion: 0.22
Nodes (5): Bool, Character, NSRange, NSTextView, String

### Community 5 - "IPCRequest"
Cohesion: 0.06
Nodes (18): SessionStore, DispatchWorkItem, TimeInterval, .tab(containingPaneID:), .tab(for:), .tabIndex(surfaceKey:), .tabIndex(tabID:), .tabIndex(workspaceID:tabID:) (+10 more)

### Community 6 - "AgentNotchRootView"
Cohesion: 0.06
Nodes (20): OSSignposter, FrameDropCause, encodeFailure, nilDrawable, FrameSignposter, .event(_:), .interval(_:_:), Bool (+12 more)

### Community 7 - "Command"
Cohesion: 0.03
Nodes (90): a(), b(), c(), d(), e(), g(), h(), I() (+82 more)

### Community 8 - "LSPMessage"
Cohesion: 0.10
Nodes (39): MTLClearColor, MTLCommandBuffer, MTLLibrary, MTLRenderCommandEncoder, MTLRenderPipelineState, TerminalFrame, BgInstance, CursorCacheKey (+31 more)

### Community 9 - "TerminalEmulator"
Cohesion: 0.06
Nodes (31): TerminalModes, InputEncoder, .encode(_:modifiers:event:modes:), .encode(text:modifiers:modes:), .encode(text:shifted:modifiers:event:associatedText:modes:), KeyEventType, press, release (+23 more)

### Community 10 - "PerformanceBenchmarks"
Cohesion: 0.04
Nodes (39): .tab(forSurfaceKey:), AgentScanner, Bool, DispatchSourceTimer, TimeInterval, DaemonCommandExecutor, Command, .init(forTesting:) (+31 more)

### Community 11 - "GitPanelView.swift"
Cohesion: 0.09
Nodes (12): .receive(_:), DispatchSemaphore, FluidityBenchmarks, NSWindow, String, UInt64, KouenTerminalSurfaceWorkerTests, Bool (+4 more)

### Community 12 - "Changed"
Cohesion: 0.04
Nodes (33): NSEvent, String, Any, Bool, CGFloat, NSEvent, NSMenu, NSMenuItem (+25 more)

### Community 13 - "KittyKeyboardTests"
Cohesion: 0.02
Nodes (127): a1t(), amn(), B0, b2t(), BBe(), bC(), bCn(), Bm() (+119 more)

### Community 14 - "VTParser"
Cohesion: 0.12
Nodes (9): .captureLines(joinWrapped:), .feed(_:), .promptRows, .readGrid(scrollbackOffset:), ScrollbackTests, Character, String, SemanticPromptTests (+1 more)

### Community 15 - "HarnessTerminalSurfaceView"
Cohesion: 0.09
Nodes (27): KeySpec, Binding, .init(from:), .init(spec:command:note:repeatable:), CodingKeys, bindings, disabledSpecs, id (+19 more)

### Community 16 - ".applyPreedit"
Cohesion: 0.13
Nodes (10): DataBox, GitPanelRefreshGate, .removeWorktreeAction(path:), GitResult, Bool, GitResult, String, ValidateOutcome (+2 more)

### Community 17 - "MetalRendererTests"
Cohesion: 0.07
Nodes (44): async, .saveRecordsBatch(_:), CachedSessionEntry, AgentHistoryScanner, .parseAntigravityTranscript(sessionID:fileURL:), .parseAntigravityTranscript(sessionID:fileURL:toIndex:), .parseClaudeTranscript(fileURL:), .parseClaudeTranscript(fileURL:toIndex:) (+36 more)

### Community 18 - "HarnessUILibrary"
Cohesion: 0.04
Nodes (59): Ac(), al(), ayn(), bdn(), bIn(), cht(), Cp(), d7e() (+51 more)

### Community 19 - "SpecialKey"
Cohesion: 0.10
Nodes (8): KouenDaemonTools, .init(client:subscriptionClient:controlEnabled:), SpawnedAgentSurface, Bool, ISO8601DateFormatter, String, Tab, UUID

### Community 21 - "HarnessTerminalSurfaceView"
Cohesion: 0.14
Nodes (12): AgentDetection, AgentDetector, MatchSource, ownProcess, wrapperLaunch, RawMatch, Date, Int32 (+4 more)

### Community 22 - "CopyModeAction"
Cohesion: 0.10
Nodes (12): TerminalGridCell, HistoryLine, ImagePlacement, Pen, RewrapResult, SavedCursor, Bool, ClosedRange (+4 more)

### Community 23 - "SplitPaneCoordinator"
Cohesion: 0.12
Nodes (13): TerminalDamage, RenderColor, MetalRendererTests, .makeRenderer(device:atlasSize:atlasMaxPages:), RenderedFixture, Bool, MTLDevice, MTLTexture (+5 more)

### Community 24 - ".request"
Cohesion: 0.10
Nodes (11): .agentColorBinding, colors, PerformanceBenchmarks, SurfaceMainThreadStallSample, SurfaceOffMainStallSample, Bool, Double, String (+3 more)

### Community 25 - "WorktreeManager"
Cohesion: 0.07
Nodes (30): LSPFileSession, Bool, Never, String, Task, URL, Void, Error (+22 more)

### Community 26 - "Harness tmux-style capabilities"
Cohesion: 0.10
Nodes (19): .exit, String, String, String, String, KouenCLI, SessionID, String (+11 more)

### Community 27 - "RGBColor"
Cohesion: 0.06
Nodes (40): NSCursor, LegacyKouenSettingsCodingKeys, commandFinishedNotifications, tmuxControlsEnabled, TerminalColorGamut, auto, displayP3, sRGB (+32 more)

### Community 28 - ".parse"
Cohesion: 0.12
Nodes (21): PaletteAction, PaletteFileEntry, PaletteGrepMatch, PaletteItemRow, .body, PaletteModel, .isGrepMode, .placeholder (+13 more)

### Community 29 - "Added"
Cohesion: 0.09
Nodes (17): RealPty, .init(id:cwd:shell:rows:cols:scrollbackBytes:extraEnvironment:termProgram:termProgramVersion:scrollbackURL:), .retainedScrollbackBytesForTesting, ScrollbackEntry, ScrollbackReplaySegment, Bool, CChar, DaemonSurfaceID (+9 more)

### Community 30 - "Notification"
Cohesion: 0.06
Nodes (42): .notchSection, .notifySection, ColorHexRow, .body, .colorBinding, .currentHex, .isCustom, PaletteCell (+34 more)

### Community 32 - ".addTab"
Cohesion: 0.24
Nodes (11): a2(), akn(), ift(), p7n(), R1(), rht(), tun(), ubt() (+3 more)

### Community 33 - "Equatable"
Cohesion: 0.04
Nodes (32): CornerInfo, EditorDividerView, HitTestPassthroughView, KouenSplitView, .dividerColor, .dividerThickness, .init(coder:), PaneDragGripView (+24 more)

### Community 34 - "DaemonClient"
Cohesion: 0.10
Nodes (20): String, Array, GroupHeaderRow, .body, PickerItemRow, .badgeText, .iconName, .subtitle (+12 more)

### Community 35 - "MenuTarget"
Cohesion: 0.11
Nodes (21): .pairedAlreadyBanner, .pairingQRPanel, .sidebarEmptyView, .rootPicker, TrackedIssue, IssueTrackerPanelView, .body, .filteredIssues (+13 more)

### Community 36 - "code:bash (harness chat "Use the project map first, then inspect this r)"
Cohesion: 0.06
Nodes (31): SessionDividerRowView, .init(coder:), .init(frame:), SessionGroupHeaderRowView, .init(coder:), .init(frame:), SessionWorktreeHeaderRowView, .init(coder:) (+23 more)

### Community 37 - "String"
Cohesion: 0.07
Nodes (37): ColorKind, .base, bg, fg, underline, ComposedCell, .asGridCell, .cluster (+29 more)

### Community 38 - "code:bash (swift build)"
Cohesion: 0.10
Nodes (22): ModelKeyStore, Bool, String, Void, CustomModelEndpoint, .init(from:), .init(id:name:baseURL:modelID:), Decoder (+14 more)

### Community 39 - "TerminalColorGamut"
Cohesion: 0.11
Nodes (29): RepoGitMetadata, SidebarListModel, .toggleCollapse(id:), .toggleCollapse(rootPath:), SidebarProjectHeaderItem, .id, SidebarSessionCardItem, SidebarSessionRow (+21 more)

### Community 40 - "HarnessSettings"
Cohesion: 0.08
Nodes (24): CTFontSymbolicTraits, CellMetrics, GlyphRasterizer, .rasterize(cluster:bold:italic:), .rasterize(codepoint:bold:italic:), .rasterize(glyph:font:), .shapedRunStats, RasterizedGlyph (+16 more)

### Community 41 - "CodingKeys"
Cohesion: 0.07
Nodes (28): IndexingIterator, LayoutTemplate, Bool, Double, surfaceID, SessionEditor, .addSurface(tabID:paneID:), .addSurface(to:paneID:surfaceID:cwd:) (+20 more)

### Community 42 - "HarnessSidebarPanelViewController.swift"
Cohesion: 0.07
Nodes (16): DisplayWidth, String, Unicode, ReleaseNotes, Section, String, Run, String (+8 more)

### Community 43 - "RenderSchedulerTests"
Cohesion: 0.14
Nodes (10): AnyCodable, JSONRPCError, ShellKiller, .didFire, Bool, Int32, Pipe, String (+2 more)

### Community 44 - "HarnessOverlayBackground"
Cohesion: 0.12
Nodes (11): ScriptError, .errorDescription, evaluationError, unsupportedPlatform, ScriptRuntime, Any, String, URL (+3 more)

### Community 45 - "HarnessTerminalSurfaceView.swift"
Cohesion: 0.09
Nodes (18): BrowserPaneView, .webView(_:didCommit:), Any, DispatchWorkItem, NSPopover, ObjectIdentifier, WeakBrowserPaneView, WKWebViewConfiguration (+10 more)

### Community 46 - ".buildCommand"
Cohesion: 0.06
Nodes (35): Source, activePane, activeTab, focusedPane, focusedSurface, PaneID, SessionGroup, SessionID (+27 more)

### Community 47 - ".normalizedKey"
Cohesion: 0.10
Nodes (18): .body, FleetRowView, .body, .statusColor, .statusDot, .subtitle, FleetView, .body (+10 more)

### Community 48 - "HookEvent"
Cohesion: 0.07
Nodes (19): Configuration, Bool, Command, DispatchWorkItem, Int32, PaneID, SessionGroup, SessionID (+11 more)

### Community 49 - "DaemonServer"
Cohesion: 0.04
Nodes (56): AnyTransition, AnyView, Color, .hexString, AgentNotchPeekEvent, AgentNotchRootView, .body, .bottomRadius (+48 more)

### Community 50 - "Added"
Cohesion: 0.09
Nodes (11): FileTreeContext, NSHostingView, SessionID, String, Void, WorkspaceFileTreeView, .init(rootPath:), KouenSidebarPanelViewController (+3 more)

### Community 51 - ".keyEvent"
Cohesion: 0.07
Nodes (22): Tab, AnyObject, ObjectIdentifier, TimeInterval, ZombieHoldRegistry, BrowserIntegrationController, PaneID, PaneContainerView (+14 more)

### Community 52 - "Fixed"
Cohesion: 0.12
Nodes (14): PendingVersionBanner, welcome, whatsNew, State, Bool, String, URL, VersionBannerStore (+6 more)

### Community 53 - "Added"
Cohesion: 0.05
Nodes (23): KouenCLITests, URL, CLIInstallLocator, DetachKeys, absent, invalid, parsed, OptionalUUID (+15 more)

### Community 54 - "HarnessSplitView"
Cohesion: 0.06
Nodes (12): NWEndpoint, Bool, NWListener, Sendable, String, UInt16, MobileBridgeServer, PipeBuffer (+4 more)

### Community 55 - "TabCell"
Cohesion: 0.05
Nodes (28): DaemonClientActor, TimeInterval, DaemonSessionError, daemonError, .description, unexpectedResponse, DaemonSessionService, .endpoint (+20 more)

### Community 56 - "NSPanel"
Cohesion: 0.09
Nodes (18): KeyRecorderView, .acceptsFirstResponder, .init(coder:), .init(initial:), .isRecording, .recording, Any, Bool (+10 more)

### Community 57 - "BellScanState"
Cohesion: 0.10
Nodes (18): Process, SSHTunnelError, .description, exitedEarly, invalidConfiguration, launchFailed, notReady, SSHTunnelManager (+10 more)

### Community 58 - "PasteBufferStore"
Cohesion: 0.13
Nodes (6): azt(), F7, ibe(), mathmlBuilder(), q$e(), UHt()

### Community 59 - "3.2 สิ่งที่ implement แล้ว"
Cohesion: 0.03
Nodes (174): a6(), aJ(), Ame(), aQ(), aQt(), aUe(), aXt(), AYt() (+166 more)

### Community 60 - "ViEngine"
Cohesion: 0.09
Nodes (23): DisplayLinkTarget, MainSplitViewController, .setSidebarVisible(_:), .setSidebarVisible(_:animated:), SplitChromeDelegate, .sidebarMaxWidth, .sidebarMinWidth, .splitView(_:constrainMaxCoordinate:ofSubviewAt:) (+15 more)

### Community 61 - "FrecencyDirectoryStore"
Cohesion: 0.10
Nodes (19): object, Bool, CodingKeys, error, id, jsonrpc, method, params (+11 more)

### Community 62 - "ComposedCell"
Cohesion: 0.08
Nodes (28): AgentNotchDashboardProjection, .agentCount, .sessionCount, .waitingCount, .workingCount, AgentNotchProjection, AgentNotchRowSummary, RowKind (+20 more)

### Community 63 - "HarnessCLI+Server.swift"
Cohesion: 0.15
Nodes (5): AgentTableEntry, Bool, Set, String, AgentDetectorTests

### Community 64 - ".text"
Cohesion: 0.09
Nodes (14): ActiveTabCloseDisposition, session, tab, window, workspace, CloseConfirmationCopy, SessionLifecycleService, NSWindow (+6 more)

### Community 65 - "PrefixKeymap"
Cohesion: 0.07
Nodes (36): .init(entry:), AgentChipView, .init(coder:), .intrinsicContentSize, Colors, FontSize, IconSize, KouenMotion (+28 more)

### Community 66 - "ShellIntegration"
Cohesion: 0.07
Nodes (27): AgentHistoryFTSIndex, .deleteSession(sessionID:), .needsReindex(sessionID:mtime:fileSize:), .pruneMissingSessions(validTranscriptPaths:), .saveRecord(_:mtime:fileSize:), .search(query:limit:), .searchRanked(query:limit:includeSnippet:requireAllTokens:includeMetadata:matchingIDs:), .searchSubstring(query:includeEvidence:matchingIDs:) (+19 more)

### Community 67 - "String"
Cohesion: 0.08
Nodes (11): SessionCoordinator, .selectWorkspace(_:), Bool, Double, PaneID, String, SurfaceID, TabID (+3 more)

### Community 68 - "Completed Plans Archive"
Cohesion: 0.06
Nodes (33): CoreGraphics, CoreText, ImageIO, KouenCopyMode, KouenTerminalEngine, KouenTerminalRenderer, KouenTheme, Metal (+25 more)

### Community 69 - ".compose"
Cohesion: 0.13
Nodes (9): Bool, DispatchWorkItem, NSEvent, NSPopover, NSRange, NSString, Void, SyntaxTextView (+1 more)

### Community 70 - "worktree_isolation_cli.robot"
Cohesion: 0.08
Nodes (21): IssueKeychainStore, Bool, String, IssuePriority, .color, high, low, medium (+13 more)

### Community 71 - "ImportedTerminalConfig"
Cohesion: 0.10
Nodes (16): AgentBrowserPaneTracker, SplitPaneCoordinator, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, SessionID, Set (+8 more)

### Community 72 - "XCTestCase"
Cohesion: 0.06
Nodes (35): Executor, Hook, HookEvent, afterKillPane, afterKillTab, afterNewSession, afterNewTab, afterResizePane (+27 more)

### Community 73 - "README.md"
Cohesion: 0.11
Nodes (14): MochaTheme, ANSIPalette, UInt8, CellColorResolver, .init(palette:defaultForeground:defaultBackground:boldBrightens:faintFraction:minimumContrast:), .init(theme:boldBrightens:minimumContrast:), ResolvedCellColors, Bool (+6 more)

### Community 74 - "[2.6.0] - 2026-06-13"
Cohesion: 0.08
Nodes (20): ImagePlacementSnapshot, SemanticMark, Bool, TerminalCellWidth, normal, spacerTail, wide, TerminalColorRole (+12 more)

### Community 75 - "OptionStore"
Cohesion: 0.10
Nodes (22): DecodedImage, .byteCount, UInt8, CursorRender, CursorStyle, bar, block, underline (+14 more)

### Community 76 - ".parse"
Cohesion: 0.06
Nodes (21): KouenUILibrary, KouenUILibrary — Robot Framework keyword library for Kouen terminal automation., Verify a board column exists using kouen CLI., Run a kouen CLI command and assert exit code 0., Run kouen view and assert output contains substring., Type a string of text into the focused element via osascript keystroke., Wait for UI to settle., Verify app is still running (no crash report in last 10s). (+13 more)

### Community 77 - "TerminalProtocolCompatibilityTests"
Cohesion: 0.12
Nodes (13): DisplayMessage, MainExecutor, RunShell, .loginShell, Bool, Command, MainActor, PaneID (+5 more)

### Community 78 - "Added"
Cohesion: 0.18
Nodes (5): .snapshot, Bool, String, ThemeService, KouenOptions

### Community 79 - "HarnessDesign"
Cohesion: 0.16
Nodes (10): ContextInjectorController, ContextInjectorPanel, .canBecomeKey, Bool, NSControl, NSPanel, NSTextView, Selector (+2 more)

### Community 80 - "Agent handbook — Harness (extended reference)"
Cohesion: 0.08
Nodes (38): Configuration, TabBarIconButtonStyle, TabBarInlineIconButtonStyle, ButtonStyle, CommandRow, .body, GlassCard, .body (+30 more)

### Community 81 - "DaemonSubscription"
Cohesion: 0.08
Nodes (15): ResubscribingSlot, .init(frame:), ChromeBackdrop, .init(role:), KouenDesign, RuntimeGlassEffectView, .init(frame:), Bool (+7 more)

### Community 82 - ".firstMatch"
Cohesion: 0.08
Nodes (31): DaemonSubscription, .start(onData:onEnd:buffered:), .start(onResponse:onEnd:), PendingFrameSpool, Bool, FileHandle, Int32, TimeInterval (+23 more)

### Community 83 - "LSPClient"
Cohesion: 0.09
Nodes (14): DaemonSyncService, .logIfFailed(_:), .request(_:), .sync(metadataOnly:), StructureFingerprint, Bool, Never, PaneID (+6 more)

### Community 84 - "LSPDiagnostic"
Cohesion: 0.08
Nodes (23): DragDiagnostics, DispatchSourceTimer, String, PaneDragController, .isDragging, Any, Bool, NSEvent (+15 more)

### Community 85 - "TerminalGridCell"
Cohesion: 0.09
Nodes (26): .filteredJobs, MatchCategory, contentContains, contentContainsTokens, exactFilename, filenameContains, filenameContainsTokens, filenameEndsWith (+18 more)

### Community 86 - "HarnessPaths"
Cohesion: 0.14
Nodes (13): NaturalLanguage, .indexSession(sessionID:title:firstPrompt:fullTranscript:gitBranch:repoName:agentName:filesEdited:toolsCalled:transcriptPath:mtime:fileSize:surfaceTag:topicSegments:), AgentHistorySearch, Hit, IDFCache, Bool, Double, String (+5 more)

### Community 87 - "SessionCoordinator"
Cohesion: 0.09
Nodes (23): .init(coder:), BrowserProgressLine, .init(coder:), .init(frame:), BrowserTabButton, .init(coder:), .init(title:isActive:onSelect:onClose:), DesignModeElementInfo (+15 more)

### Community 88 - "Harness as a terminal multiplexer"
Cohesion: 0.17
Nodes (8): FileEditorView, .init(frame:), Bool, NSEvent, NSHostingView, NSRect, String, URL

### Community 89 - ".cursorPos"
Cohesion: 0.10
Nodes (14): NotchMaskAnimator, Bool, CGFloat, CGRect, NotchPanel, .canBecomeKey, .canBecomeMain, Bool (+6 more)

### Community 90 - "Zombie View Crashes on macOS 26.5 + Swift 6.3.2"
Cohesion: 0.04
Nodes (45): Already portable or mostly portable, Build matrix, Competitive Landscape (research 2026-07-04), Current Architecture Fit, D1: Transport model (P0 gate), D2: Renderer reuse boundary (P0 gate), D3: Local terminal support (explicitly deferred), Design: mobile session switcher (2026-07-04/05, recovered 2026-07-06) (+37 more)

### Community 91 - "TerminalModes"
Cohesion: 0.13
Nodes (15): .windowSection, .renderingSection, KouenSettings, .init(fontSize:fontFamily:defaultShell:defaultCWD:transparentTitlebar:sidebarVisible:sidebarOnRight:sidebarCollapsedOnLaunch:sidebarWidth:restoreWindowSize:backgroundOpacity:backgroundBlur:windowPaddingX:windowPaddingY:customBackgroundHex:customForegroundHex:customCursorHex:importedConfigSignature:prefixKey:scrollbackLines:cursorStyle:cursorBlink:copyOnSelect:selectionBackgroundHex:selectionForegroundHex:boldColorHex:cursorTextHex:paletteHex:agentColorOverrides:defaultAgentKind:agentSessionModes:claudeSessionMode:dividerHex:statusLineHex:windowBorderHex:windowBorderOpacity:systemNotificationsEnabled:notificationSoundEnabled:notchVisibilityMode:notchOpenOnHover:colorRendering:colorGamut:textRendering:vividColors:linearBlending:applyThemeToTerminalOutput:ligatures:offMainParserFramePipeline:liveResizeReflow:mobileBridgeEnabled:showPromptGutter:showStatusLine:experienceMode:kouenControlsEnabled:prefixKeyEnabled:statusLineEnabled:resizeOverlay:resizeOverlayPosition:windowPaddingBalance:minimumContrast:lightThemeName:darkThemeName:lightThemeOpacity:darkThemeOpacity:pasteProtection:commandFinishedThresholdSeconds:notificationEvents:boldIsBright:lspAutoStart:lspServers:fileClickAction:fileSearchRoots:claudeAPIKey:terminalShaderEffect:browserHomePage:), .init(from:), .scrollbackLines, ResizeOverlayPosition, bottomRight (+7 more)

### Community 92 - "P2 — Async IPC Refactor: Design Document"
Cohesion: 0.30
Nodes (4): TaskStore, tasks, URL, TaskStoreTests

### Community 93 - "code:bash (# Terminal 1: Create workspace with long-running job)"
Cohesion: 0.08
Nodes (28): CommandHistorySearchController, .tableView(_:heightOfRow:), .tableView(_:rowViewForRow:), .tableView(_:shouldSelectRow:), .tableView(_:viewFor:row:), HistoryItemView, .init(coder:), .init(command:query:) (+20 more)

### Community 94 - "AttachInputBatcher"
Cohesion: 0.11
Nodes (16): .body, json, ConfigError, .errorDescription, unsupportedAgent, writeFailure, MCPConfigWriter, Any (+8 more)

### Community 95 - "shim.c"
Cohesion: 0.11
Nodes (15): .activeTab, .init(url:paneID:webView:), .webView(_:createWebViewWith:for:windowFeatures:), BrowserTab, NSStackView, URL, UUID, WKNavigationAction (+7 more)

### Community 96 - "Harness Usage"
Cohesion: 0.07
Nodes (34): ArtifactKind, html, image, markdown, text, AutomationsFleetModel, .load(detectScheduledRuns:), AutomationSource (+26 more)

### Community 97 - "PaneContainerView"
Cohesion: 0.08
Nodes (6): CodepointRunFastPathTests, .assertAllPathsAgree(_:cols:rows:file:line:), StaticString, String, UInt, UInt8

### Community 98 - "4. Technical Architecture"
Cohesion: 0.15
Nodes (9): StringKind, apc, dcs, UInt8, UnsafeBufferPointer, VTParser, .feed(_:), VTParserHandler (+1 more)

### Community 99 - ".dispatch"
Cohesion: 0.13
Nodes (6): RenderScheduler, .hasPendingWork, Bool, Void, RenderSchedulerTests, Bool

### Community 100 - "ScriptRuntime.swift"
Cohesion: 0.05
Nodes (38): Active Plans, Completed, Plans Index — kouen-terminal, Quick ref — recent completions, Logical Design, P41 — Automations, Strategic Design, Tactical Design (+30 more)

### Community 101 - "Session Grouping and Split Session Plan"
Cohesion: 0.11
Nodes (10): NotificationCoordinator, Bool, Date, Set, String, SurfaceID, Tab, TabID (+2 more)

### Community 102 - "DaemonLauncher"
Cohesion: 0.08
Nodes (18): NSScrollView, NSWindow, Bool, CGFloat, DispatchWorkItem, NSCoder, NSColor, NSEvent (+10 more)

### Community 103 - "AnyCodable"
Cohesion: 0.09
Nodes (28): ClientRecord, CountBox, DaemonError, alreadyRunning, bindFailed, .description, listenFailed, socketFailed (+20 more)

### Community 104 - "Recipe"
Cohesion: 0.07
Nodes (18): FlippedView, .isFlipped, GitPanelView, .isHidden, .removeWorktreeAction(_:), Any, DispatchWorkItem, NSButton (+10 more)

### Community 105 - "Changelog"
Cohesion: 0.08
Nodes (24): NotificationEntry, .id, SessionID, SurfaceID, TabID, WorkspaceID, NotificationDropdownPanelView, .acceptsFirstResponder (+16 more)

### Community 106 - "domain-design.md"
Cohesion: 0.10
Nodes (27): FooterIconButton, .body, RecentProjectsMenuButton, .body, .recents, SidebarFooterModel, SidebarFooterView, .body (+19 more)

### Community 107 - "AgentNotchViewModel"
Cohesion: 0.09
Nodes (35): Encodable, ExpressibleByStringLiteral, AgyModelsPush, AISuggestionAck, AttachedAck, Body, BrowserFramePush, Cred (+27 more)

### Community 108 - ".resolve"
Cohesion: 0.05
Nodes (29): item, input, historyJSONObject(), Any, String, .readJSONLLines(from:fromOffset:), ClaudeSessionLocator, ClaudeTranscriptLine (+21 more)

### Community 109 - "DamageTrackingTests"
Cohesion: 0.14
Nodes (4): hooks, AgentHookInstallerTests, String, URL

### Community 110 - "SoftIconButton"
Cohesion: 0.07
Nodes (18): AutomationStore, KouenAutomation, Bool, Date, String, URL, UUID, AutomationScheduler (+10 more)

### Community 111 - "code:text (:workbench start swift)"
Cohesion: 0.07
Nodes (21): DaemonClient, agentWaitChannel(), ClaudeCodeHarnessIPCTests, String, URL, DaemonBrowserRoutingTests, String, URL (+13 more)

### Community 112 - ".makeSnapshot"
Cohesion: 0.07
Nodes (23): String, UInt16, Data, DecodedReplyFrame, output, reply, DecodedRequestFrame, input (+15 more)

### Community 113 - "HarnessGridTerminal"
Cohesion: 0.18
Nodes (11): SwarmSpawnSpec, CallRecorder, .cancelCalls, .closeCalls, .harnessCalls, .surfaceCalls, SwarmWorkerManagerTests, Bool (+3 more)

### Community 114 - ".firstWaitingTab"
Cohesion: 0.15
Nodes (10): LSPServerConfiguration, LSPServerRegistry, LSPSettings, Bool, FileManager, String, URL, LSPServerRegistryTests (+2 more)

### Community 115 - ".encode"
Cohesion: 0.20
Nodes (5): .onCurrentCWD, .onCurrentFile, Bool, NSTextView, String

### Community 116 - "SessionGroup"
Cohesion: 0.18
Nodes (10): Bool, CGFloat, Character, NSEvent, NSRange, NSString, NSTextView, String (+2 more)

### Community 117 - "PaneNode"
Cohesion: 0.10
Nodes (17): NSSearchFieldDelegate, Bool, CGFloat, NSButton, NSCoder, NSControl, NSEvent, NSImage (+9 more)

### Community 118 - "WorkspaceFileTreeView"
Cohesion: 0.12
Nodes (8): BrowserLeaf, URL, DaemonSyncServiceBrowserLeafIdentityTests, Tab, DaemonSyncServiceBrowserPaneMergeTests, PaneID, PaneNodeBrowserTests, PaneNodeLayoutShapeTests

### Community 119 - "Harness command reference"
Cohesion: 0.05
Nodes (35): Darwin, Glibc, KouenCore, KouenDaemonCore, EndpointConnector, Int32, String, decodeBoundedCString() (+27 more)

### Community 120 - "Added"
Cohesion: 0.14
Nodes (18): CommandParseError, .description, emptyInput, expectedCommand, invalidArgument, missingArgument, missingFlag, unknownCommand (+10 more)

### Community 121 - "Changed"
Cohesion: 0.17
Nodes (8): ClaudeCloudSessionStore, Entry, Date, String, TimeInterval, URL, String, Void

### Community 122 - "ViEngine"
Cohesion: 0.15
Nodes (12): FeatureStore, .get(id:), .get(slug:), Bool, String, URL, UUID, KouenFeature (+4 more)

### Community 123 - "Pipe"
Cohesion: 0.15
Nodes (9): FormatContext, FormatString, FormatStyle, Bool, Character, Date, String, FormatStyledTests (+1 more)

### Community 124 - "String"
Cohesion: 0.11
Nodes (11): UnsafeBufferPointer, UnsafeBufferPointer, CharacterWidth, Bool, ClosedRange, Unicode, CharacterWidthTable, UInt16 (+3 more)

### Community 125 - "HistoryRingBuffer"
Cohesion: 0.15
Nodes (8): MarkdownPreviewView, Bool, String, URL, MarkdownPreviewTests, StaticString, String, UInt

### Community 126 - ".path"
Cohesion: 0.14
Nodes (21): Hashable, AtlasEntry, ClusterGlyphKey, GlyphAtlas, .entry(for:), .entry(forCluster:bold:italic:), .entry(forShaped:font:), .stats (+13 more)

### Community 127 - "GlyphAtlas"
Cohesion: 0.21
Nodes (7): BrowserOkAck, Sendable, T, ConnectionState, ErrorAck, NWConnection, UUID

### Community 128 - "code:block1 (SessionCoordinator.snapshot ──┐)"
Cohesion: 0.10
Nodes (7): Bool, Range, Set, String, URLDetection, StringProtocol, EngineConformanceTests

### Community 129 - "SwiftUI"
Cohesion: 0.29
Nodes (13): AppIntent, AppIntents, GetTerminalOutputIntent, KouenShortcutsProvider, .appShortcuts, RunCommandIntent, SplitPaneIntent, Bool (+5 more)

### Community 130 - "Harness"
Cohesion: 0.06
Nodes (28): FilterStatus, active, all, completed, CaseIterable, ExperienceMode, agent, .displayName (+20 more)

### Community 131 - ".install"
Cohesion: 0.16
Nodes (13): AgentHookInstaller, .antigravityPayload, .claudePayload, .codexPayload, .cursorPayload, .grokPayload, .hermesHookBody, .openClawHookBody (+5 more)

### Community 132 - "AgentHookInstaller"
Cohesion: 0.19
Nodes (6): RecipePickerModel, NSWindow, RecipePickerModelMergeTests, Bool, String, SurfaceID

### Community 133 - ".load"
Cohesion: 0.13
Nodes (8): KouenMCP, tool, KouenBrowserToolsTests, URL, KouenDaemonToolsTests, String, URL, McpHardeningTests

### Community 134 - "code:js (// ~/.config/harness/init.js)"
Cohesion: 0.10
Nodes (22): ChecksStatus, fail, none, pass, CIRun, GitHubCLIClient, IssueInfo, MergeMethod (+14 more)

### Community 135 - "CommandTarget"
Cohesion: 0.08
Nodes (18): TokenCheck, accepted, expired, mismatch, noActivePairing, constantTimeEquals(), PairedDeviceRecord, PairedDeviceStore (+10 more)

### Community 136 - ".startWatching"
Cohesion: 0.13
Nodes (9): ParsedShortcut, .displayString, PrefixKeymap, Any, Bool, NSEvent, String, TimeInterval (+1 more)

### Community 137 - "ActivePaneService"
Cohesion: 0.14
Nodes (8): MutationResult, RemoteHost, RemoteHostStore, Bool, String, RemoteHostStoreTests, String, URL

### Community 138 - "User Story Mapping (MANDATORY)"
Cohesion: 0.13
Nodes (11): String, ShellLaunchProfileTests, SurfaceRegistryTests, .firstSurfaceID(for:in:), .firstSurfaceID(forSession:in:), PaneID, SessionID, String (+3 more)

### Community 139 - "แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)"
Cohesion: 0.14
Nodes (10): ScrollbackFile, .highWater, Bool, DispatchTime, DispatchWorkItem, TimeInterval, URL, ScrollbackFileTests (+2 more)

### Community 140 - "Added"
Cohesion: 0.03
Nodes (76): _2t(), ag(), ase(), aTn(), aV(), cce(), d2t(), d8n() (+68 more)

### Community 141 - ".testPaneLeafLegacyDecodeBackfillsSurfaceTabs"
Cohesion: 0.09
Nodes (18): Kind, primary, secondary, KouenPillButton, .init(title:kind:), .isHovered, .isPressed, SoftIconButton (+10 more)

### Community 142 - "CopyModeGridSource"
Cohesion: 0.14
Nodes (11): FileViewerViewController, .acceptsFirstResponder, .isDirty, Any, Bool, NSEvent, Set, String (+3 more)

### Community 143 - "How to use Harness from the terminal only (no GUI)"
Cohesion: 0.11
Nodes (19): DirectoryItemRow, .body, DirectoryPanel, .canBecomeKey, DirectoryPickerController, DirectoryPickerFooter, .body, DirectoryPickerModel (+11 more)

### Community 144 - "PaneStyleSet"
Cohesion: 0.17
Nodes (12): ProjectCategory, .init(from:), .init(id:name:sourceFolder:excludedPaths:), ProjectEntry, .id, ProjectStore, .init(userDefaults:), .init(userDefaultsSuite:) (+4 more)

### Community 145 - "AsciiFastPathTests"
Cohesion: 0.15
Nodes (9): Bool, Int32, String, URL, SystemdUserInstaller, .backendName, .isInstalled, .unitURL (+1 more)

### Community 146 - "DecodedImage"
Cohesion: 0.11
Nodes (10): ContiguousArray, IteratorProtocol, HistoryRingBuffer, .isEmpty, Iterator, Bool, Element, Iterator (+2 more)

### Community 147 - "FileTreeWatcher"
Cohesion: 0.13
Nodes (13): CKouenSys, pipe, termios, AttachClient, Configuration, LiveSession, Bool, DispatchSourceSignal (+5 more)

### Community 148 - "TriState"
Cohesion: 0.14
Nodes (10): Buffer, .preview, Configuration, PasteBufferStore, Bool, Date, String, URL (+2 more)

### Community 149 - "EnvironmentStore"
Cohesion: 0.07
Nodes (21): GitCommitCommand, String, AsyncRunCoordinator, drainOutput(), OutputBuffer, OutputCapture, ProcessCancellation, ProcessResult (+13 more)

### Community 150 - "HarnessDaemonToolsTests"
Cohesion: 0.13
Nodes (15): InstallResult, Profile, .id, Shell, bash, fish, .profilePath, zsh (+7 more)

### Community 151 - ".evaluate"
Cohesion: 0.10
Nodes (15): LSPMessage, notification, request, response, Decoder, Encoder, KeyedDecodingContainer, LSPTransport (+7 more)

### Community 152 - "Added"
Cohesion: 0.12
Nodes (17): FileNode, GitStatusType, added, deleted, modified, renamed, unmodified, untracked (+9 more)

### Community 153 - "What You Must Do When Invoked"
Cohesion: 0.15
Nodes (13): center, ComposerPanel, .canBecomeKey, .textView(_:doCommandBy:), .textView(_:shouldChangeTextIn:replacementString:), Bool, NSEvent, NSRange (+5 more)

### Community 154 - "LiveResizeTests"
Cohesion: 0.08
Nodes (26): keys, CGImage, ImageLimits, Bool, ImageDecoder, ITerm2InlineImage, .heightArg, .preserveAspectRatio (+18 more)

### Community 155 - "Int"
Cohesion: 0.17
Nodes (18): Codable, BrowserSnapshotAck, BrowserCookie, BrowserElement, BrowserElementBounds, BrowserNetworkEntry, BrowserSnapshot, BufferSummary (+10 more)

### Community 156 - "ThaiCombiningMarkTests"
Cohesion: 0.10
Nodes (19): Coordinator, DiffAnalysis, DiffFileItem, DiffFileStatus, added, .color, deleted, modified (+11 more)

### Community 157 - "Added"
Cohesion: 0.11
Nodes (13): FileFuzzyMatcher, FileSearchRootScanner, FuzzyPathResolution, ambiguous, none, unique, FuzzyPathResolver, Bool (+5 more)

### Community 158 - "Harness Terminal — IDE Sidebar Feature Branch"
Cohesion: 0.11
Nodes (15): SavedLayoutStore, Bool, String, URL, UUID, PaneLayoutShape, branch, leaf (+7 more)

### Community 159 - "MatchCategory"
Cohesion: 0.14
Nodes (16): ClosureTarget, MenuActionTarget, OverlayWindow, .canBecomeKey, Phase67UI, PopupWindow, Bool, Command (+8 more)

### Community 160 - "AmbientBackground"
Cohesion: 0.07
Nodes (14): CustomStringConvertible, KouenPaths, KouenPathsError, .description, socketPathTooLong, Bool, String, T (+6 more)

### Community 161 - "What You Must Do When Invoked"
Cohesion: 0.14
Nodes (4): CommandIPCTranslatorTests, Bool, PaneID, TabID

### Community 162 - "TerminalFindBar"
Cohesion: 0.11
Nodes (13): Array, FormatColor, none, palette, rgb, StyledSegment, Bool, Element (+5 more)

### Community 163 - "Workspace"
Cohesion: 0.13
Nodes (16): .waitingCount, FleetSessionItem, .isWaiting, .shortID, FleetSessionList, ProjectTabFilter, agents, all (+8 more)

### Community 164 - "CommandPromptController"
Cohesion: 0.09
Nodes (16): AgyModelCatalog, Catalog, Date, String, TimeInterval, AgyMobileCommands, String, ClaudeMobileCommands (+8 more)

### Community 165 - "ActiveTabCloseDisposition"
Cohesion: 0.09
Nodes (21): ModelProvider, .agentKindForLogo, aider, anthropic, azure, copilot, cursor, google (+13 more)

### Community 166 - "LiveSession"
Cohesion: 0.14
Nodes (14): CompletionPopupView, .init(coder:), .init(frame:), CompletionRowView, .init(coder:), .init(text:isSelected:), .isHovered, Bool (+6 more)

### Community 167 - "AgentTableEntry"
Cohesion: 0.13
Nodes (16): Action, DesktopNotifier, .isUNNotificationCenterAvailable, KouenPathDisplay, NotificationPresenter, .userNotificationCenter(_:didReceive:withCompletionHandler:), .userNotificationCenter(_:willPresent:withCompletionHandler:), Bool (+8 more)

### Community 168 - "Added"
Cohesion: 0.18
Nodes (4): FilePreviewCoordinator, FileTabID, Set, String

### Community 169 - "Fixed"
Cohesion: 0.13
Nodes (13): MenuBarController, MenuRef, SessionRow, CGFloat, NSImage, NSMenu, NSMenuItem, SessionGroup (+5 more)

### Community 170 - "URLDetection"
Cohesion: 0.08
Nodes (19): SnapshotCoalescer, MainActor, Void, AgentApprovalBar, .init(coder:), .init(host:prompt:kind:), ApprovalBarAction, hide (+11 more)

### Community 171 - "ReflowCorpusTests"
Cohesion: 0.06
Nodes (23): Codex → Kouen, One-line install, What you'll see, Grok Build → Kouen, One-line install, What you'll see, Hermes → Kouen, One-line install (+15 more)

### Community 172 - ".decodeKeySpec"
Cohesion: 0.08
Nodes (24): PaneBorderStatus, bottom, off, top, PaneRect, PaneRectSolver, PaneID, SurfaceID (+16 more)

### Community 173 - "BoardCard"
Cohesion: 0.06
Nodes (26): AgentRoutingResolver, String, AgentRoutingRule, Kind, path, stack, Bool, Date (+18 more)

### Community 174 - "BinaryRefresherTests"
Cohesion: 0.09
Nodes (23): BinaryInstaller, .bundledMacOSDir, CopyOutcome, copied, keptNewerInstalled, skippedIdentical, DetectionStatus, .display (+15 more)

### Community 175 - "RGBColorTests"
Cohesion: 0.14
Nodes (9): ImportedTerminalConfig, .hasTerminalColorOverrides, .signature, Bool, Double, Float, String, TerminalConfigImporter (+1 more)

### Community 176 - "Added"
Cohesion: 0.11
Nodes (17): aie(), arc(), closePath(), cRe(), cZ(), E7(), frn, hD() (+9 more)

### Community 177 - ".rects"
Cohesion: 0.05
Nodes (23): Am(), bUt(), bze(), Cm(), EQ(), FBe(), fQ, Gbe() (+15 more)

### Community 178 - "InlineAICompletionView"
Cohesion: 0.11
Nodes (8): Bool, String, UInt8, TerminalEmulator, .block(atPromptLine:), .captureLines(fromLine:toLine:), String, TerminalBlockStoreTests

### Community 179 - "[3.13.1] - 2026-07-02"
Cohesion: 0.15
Nodes (15): AgentIconRenderer, Scanner, .atEnd, SVGPathParser, Bool, CGFloat, CGPath, CGPoint (+7 more)

### Community 180 - "VTConformanceCorpusTests"
Cohesion: 0.12
Nodes (21): FileEditorTabBarBody, .body, FileEditorTabBarModel, FileEditorTabBarView, .init(coder:), .init(frame:), .onClose, FileTabPillView (+13 more)

### Community 181 - "GridCompositorTests"
Cohesion: 0.40
Nodes (4): DiffLineType, added, deleted, modified

### Community 182 - "P25 — iOS/iPadOS Support"
Cohesion: 0.14
Nodes (9): NSAttributedString, NSRegularExpression, String, SyntaxHighlighter, SyntaxHighlighterTests, NSAttributedString, NSColor, String (+1 more)

### Community 183 - "LSPServerRegistry"
Cohesion: 0.18
Nodes (10): BranchSwitchHelper, FileTreeNode, FileTreeSwiftUIView, .body, .pastedImagesSection, Notification.Name, Bool, NSMenuItem (+2 more)

### Community 184 - "targets"
Cohesion: 0.14
Nodes (10): PaneListRow, SessionListRow, SnapshotQueryFormatter, Bool, SessionGroup, String, Tab, UUID (+2 more)

### Community 185 - "SessionSnapshot"
Cohesion: 0.09
Nodes (16): Bool, NSEvent, NSPanel, String, TurnDiffPanel, .canBecomeKey, TurnDiffReviewerController, CheckpointInfo (+8 more)

### Community 186 - "Error"
Cohesion: 0.15
Nodes (16): ClaudeCodeHarness, Profile, edit, readonly, Run, RunState, cancelled, failed (+8 more)

### Community 187 - "AppDelegate"
Cohesion: 0.24
Nodes (7): .snapshotPayload, NotificationBus, .postSnapshotChanged(_:), .postSnapshotChanged(revision:), SnapshotChangedPayload, Bool, String

### Community 188 - "BrowserPaneView"
Cohesion: 0.10
Nodes (18): KouenMCPServer, String, MCPServer, String, ContentLengthRejection, SSETransport, .isRunning, .listener (+10 more)

### Community 189 - "P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client"
Cohesion: 0.11
Nodes (14): StatusLineView, .init(coder:), CGFloat, Never, NSAttributedString, NSCoder, NSColor, NSLayoutConstraint (+6 more)

### Community 190 - "user-stories.md"
Cohesion: 0.18
Nodes (7): KouenWindow, NSEvent, MainWindowController, Any, NSRect, NSWindow, NSWindowController

### Community 192 - "GlyphRasterizer"
Cohesion: 0.12
Nodes (24): .color, BoardCard, BoardColumn, .name, BoardColumnKind, .displayName, done, error (+16 more)

### Community 193 - "BinaryInstaller"
Cohesion: 0.21
Nodes (5): CopyModeReducerTests, FakeGrid, .totalLines, Set, String

### Community 194 - "Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag"
Cohesion: 0.10
Nodes (14): AgentHistoryJSONLSequence, .isValid, Iterator, Bool, Date, FileHandle, Iterator, URL (+6 more)

### Community 195 - "ResizeHUDView"
Cohesion: 0.11
Nodes (12): .readJSONLLines(from:), AntigravitySessionLocator, AntigravityTranscriptLine, Bool, Int32, NSRegularExpression, S, String (+4 more)

### Community 196 - "Feature Provenance — harness-terminal"
Cohesion: 0.11
Nodes (17): KeyRecorderRepresentable, String, Void, OverlayBackground, Context, OverlayBackground, Context, .init(coder:) (+9 more)

### Community 197 - "AgentSessionSummary"
Cohesion: 0.19
Nodes (11): SettingsRemoteView, .body, .canConnect, .hostFormPanel, .hostListPanel, .mobilePairingSection, .pairedDevicesList, .selectedHost (+3 more)

### Community 198 - ".classify"
Cohesion: 0.11
Nodes (13): SessionID, Status, ciFailing, done, mergeReady, open, running, Bool (+5 more)

### Community 199 - "code:bash (harness-cli notify --surface "$HARNESS_SURFACE" --title "Cla)"
Cohesion: 0.14
Nodes (5): Selector, String, TimeInterval, UInt64, BrowserPaneWaitTimeoutTests

### Community 200 - "BinaryInstallerVersionTests"
Cohesion: 0.11
Nodes (19): AppKit, Motion, .entrance, .spring, .standardEase, CAMediaTimingFunction, KouenOnboarding, Bool (+11 more)

### Community 201 - "MCP Server (harness-mcp)"
Cohesion: 0.07
Nodes (28): Additional `kouen-cli` subcommands, Agent safety CLI (`kouen-cli`), Agents, context and scratchpad, Attaching from a plain terminal, Bindings, Board and attention, Buffers (paste store), Composition (+20 more)

### Community 202 - "PaletteModel"
Cohesion: 0.12
Nodes (11): NSTextCheckingResult, AgentAttentionDetector, AttentionPrompt, PromptKind, approval, choice, confirmation, osc (+3 more)

### Community 203 - "Harness keybindings"
Cohesion: 0.21
Nodes (4): CommandTarget, String, UUID, TargetSpecTests

### Community 204 - "From tmux"
Cohesion: 0.10
Nodes (15): FindWindowMatcher, SearchScope, all, none, only, Bool, SessionGroup, SessionID (+7 more)

### Community 205 - "CopyModeState"
Cohesion: 0.06
Nodes (42): Equatable, CopyModeAction, CopyModeGridSource, .promptRows, CopyModeLine, .charIndex(atOrAfter:), .charIndex(atOrBefore:), .lastContentColumn (+34 more)

### Community 206 - "HarnessCLI"
Cohesion: 0.14
Nodes (15): Phase, daemonConnected, firstDrawablePresented, firstSnapshot, firstSurfaceAttached, firstWindow, launchStart, StartupMetrics (+7 more)

### Community 207 - "scheduleRender"
Cohesion: 0.29
Nodes (7): GitAheadBehind, GitResult, .isSuccess, GitWorktreeInfo, Bool, Int32, String

### Community 208 - ".testDataFrameEncodeVsJSONBase64Output"
Cohesion: 0.16
Nodes (11): AppDelegate, .application(_:open:), .application(_:openFiles:), QueuedExternalOpen, Bool, NSKeyValueObservation, String, URL (+3 more)

### Community 209 - "SettingsRemoteView"
Cohesion: 0.17
Nodes (9): DaemonLauncher, Bool, Double, Int32, MainActor, String, TimeInterval, UInt16 (+1 more)

### Community 210 - "PaneDropZoneOverlay"
Cohesion: 0.18
Nodes (8): Duration, LSPDiagnostic, LSPDefinitionPayload, LSPDiagnosticsPayload, LSPStatusPayload, String, UInt64, URL

### Community 211 - "PaneTarget"
Cohesion: 0.11
Nodes (17): .init(coder:), .init(frame:), HunkActionButton, .init(coder:), .init(title:onClick:), StageToggleButton, .init(coder:), .init(frame:) (+9 more)

### Community 212 - ".translate"
Cohesion: 0.12
Nodes (15): clamp(), statusHelp(), Date, String, T, TabID, tabDisplayTitle(), TabPillView (+7 more)

### Community 213 - "String"
Cohesion: 0.39
Nodes (3): data, SixelDecoder, UInt8

### Community 214 - "NotchLayoutMetrics"
Cohesion: 0.08
Nodes (5): KouenSettings, ExperienceModeTests, KouenSettingsTests, URL, Void

### Community 215 - ".lines"
Cohesion: 0.13
Nodes (12): DaemonLifecycle, PriorInstanceDecision, proceed, refuse, stale, Bool, pid_t, String (+4 more)

### Community 216 - "CellColorResolverTests"
Cohesion: 0.67
Nodes (3): AsyncCLIResultBox, Error, Result

### Community 217 - "GridCompositor"
Cohesion: 0.14
Nodes (9): ActivePaneService, .surfaceID(forPane:in:), .surfaceID(forPaneID:in:), Bool, PaneID, Set, SurfaceID, Tab (+1 more)

### Community 218 - "ScrollbackFile"
Cohesion: 0.16
Nodes (14): SecureInputMonitor, DispatchQueue, DispatchWorkItem, MainActor, Sendable, Set, SurfaceID, UUID (+6 more)

### Community 219 - "Prompt"
Cohesion: 0.18
Nodes (7): CGFloat, NSCoder, Void, TabNavigation, TabNavigationButtons, .init(coder:), NSStackView

### Community 220 - "Section"
Cohesion: 0.08
Nodes (24): AgentHistoryDateGroup, older, .sortOrder, thisWeek, today, yesterday, AgentSessionHistoryModel, .extraRecordsShown (+16 more)

### Community 221 - "TerminalServicesProvider"
Cohesion: 0.16
Nodes (15): ProjectGroupWatcher, StreamBox, Bool, DispatchQueue, escaping, FSEventStreamRef, MainActor, Never (+7 more)

### Community 222 - "AgentNotchRowSummary"
Cohesion: 0.13
Nodes (23): Colors, Appearance, .init(backgroundOpacity:backgroundBlur:fontFamily:fontSize:windowPaddingX:windowPaddingY:sourceColorSpace:appearance:supportsWideGamut:contrastGrade:applyToTerminalOutput:), .init(from:), AppearanceKind, dark, light, Colors (+15 more)

### Community 223 - "ANSIPalette"
Cohesion: 0.11
Nodes (11): SGRMouse, SGRMouseEvent, Bool, UInt8, MouseEventKind, drag, press, release (+3 more)

### Community 224 - "CellColorResolver"
Cohesion: 0.09
Nodes (24): aat(), c5n(), d6(), et(), GLt(), gwn(), hoe(), i9n() (+16 more)

### Community 225 - "HarnessPathDisplay"
Cohesion: 0.13
Nodes (19): AS(), bvt(), cc(), d2(), dce(), e6(), eOn(), ev() (+11 more)

### Community 226 - "FileChangeWatcher"
Cohesion: 0.15
Nodes (16): AgentMark, .body, AgentMarkShape, Scanner, .atEnd, SVGPath, Bool, CGFloat (+8 more)

### Community 227 - "SSHTunnelManagerTests"
Cohesion: 0.10
Nodes (18): CompleteStepView, Void, OnboardingStep, complete, discover, .id, setup, shell (+10 more)

### Community 229 - ".decide"
Cohesion: 0.06
Nodes (25): NSRangePointer, Bool, CAMetalDrawable, Any, NSAttributedString, NSRange, NSRect, String (+17 more)

### Community 230 - "HarnessGridTerminalTests"
Cohesion: 0.15
Nodes (9): ActivityAssertionManager, .activeAssertionCount, Bool, NSObjectProtocol, Set, String, SurfaceID, ProcessInfo (+1 more)

### Community 231 - "ExternalOpenKind"
Cohesion: 0.16
Nodes (7): CwdMetadataProvider, GitMetadataProvider, MetadataProvider, Bool, String, Tab, GitMetadataProviderTests

### Community 232 - "P10 Task: Lazy Scrollback Reflow"
Cohesion: 0.11
Nodes (16): CommandPromptController, .historyEntries, .historyURL, KeyablePanel, .canBecomeKey, Bool, NSControl, NSPanel (+8 more)

### Community 233 - "TextGrid"
Cohesion: 0.12
Nodes (8): Bool, NSDraggingInfo, NSDragOperation, NSPasteboard, URL, NSPasteboard, URL, KouenTerminalSurfaceDragDropTests

### Community 234 - ".scan"
Cohesion: 0.17
Nodes (11): NotchGeometry, .fallback, NSScreen, NotchLayoutMetrics, .peekHeight, .peekWidth, NotchRect, NotchScreenMetrics (+3 more)

### Community 235 - "WorkbenchCommand"
Cohesion: 0.08
Nodes (24): Font, .kouenBadge, .kouenBody, .kouenBodyStrong, .kouenCaption2, .kouenCaption, .kouenKbd, .kouenMono (+16 more)

### Community 236 - "Added"
Cohesion: 0.19
Nodes (8): C, AttachInputBatcher, .hasPending, Outcome, Bool, UInt8, AttachInputBatcherTests, UInt8

### Community 237 - "TerminalBlockStoreTests"
Cohesion: 0.13
Nodes (16): Dispatch, Charset, ascii, decSpecialGraphics, Counter, DrainResult, .bytesPerWakeup, .mbps (+8 more)

### Community 238 - ".make"
Cohesion: 0.12
Nodes (19): AgentRow, .agentColor, .executables, .hookButton, .hookButtonTitle, .mcpButton, HookState, failed (+11 more)

### Community 239 - "TerminalMetalRenderer"
Cohesion: 0.15
Nodes (14): Notification.Name, ObserverToken, NSCoder, NSObjectProtocol, NSRect, NSTextView, SyntaxLineNumberGutterView, .init(coder:) (+6 more)

### Community 240 - "PaneBorderStatus"
Cohesion: 0.08
Nodes (13): KeybindingsService, Bool, Command, String, .init(from:), Decoder, KeybindingsStore, .fileURL (+5 more)

### Community 241 - "Added"
Cohesion: 0.28
Nodes (7): Channel, Bool, Int32, String, WaitForRegistry, .activeChannelCount, WaitForRegistryTests

### Community 242 - "AgentBridge"
Cohesion: 0.21
Nodes (8): DaemonMetrics, Snapshot, .meanLockWaitMicros, Bool, Double, String, UInt64, DaemonMetricsTests

### Community 243 - ".make"
Cohesion: 0.15
Nodes (7): FileViewRouting, Bool, Set, String, FileEditorViewQuickLookRoutingTests, String, URL

### Community 244 - "FileNode"
Cohesion: 0.16
Nodes (3): CodexAdapter, UUID, HeadlessCLIAdapterTests

### Community 245 - "ThemeDocumentTests"
Cohesion: 0.11
Nodes (6): DaemonOffLockWorktreeTests, String, URL, EndpointClientTests, String, URL

### Community 246 - "Experience modes"
Cohesion: 0.11
Nodes (20): statusColor(), Array, Bool, Date, Decoder, PaneID, String, TabID (+12 more)

### Community 247 - ".renderFixture"
Cohesion: 0.18
Nodes (6): Range, String, TerminalBufferMatch, TerminalBufferSearch, String, TerminalBufferSearchTests

### Community 248 - "DaemonMetrics"
Cohesion: 0.12
Nodes (9): NSDraggingInfo, NSDragOperation, PasteController, Bool, NSPasteboard, String, TimeInterval, URL (+1 more)

### Community 249 - "ReflowPreviewTests"
Cohesion: 0.20
Nodes (5): KouenBrowserTools, Bool, Double, String, TimeInterval

### Community 250 - "HarnessTerminalSurfaceWorkerTests"
Cohesion: 0.20
Nodes (6): SessionGroup, SessionGroup, NSMenu, NSMenuItem, SessionGroup, SessionID

### Community 251 - "SessionCoordinator"
Cohesion: 0.10
Nodes (6): String, NSTextView, KouenApp, GitPanelViewDiffPopoverTests, GitPanelViewFSEventFilterTests, JSStringLiteralTests

### Community 252 - "NSViewRepresentable"
Cohesion: 0.24
Nodes (5): FileTreeWatcher, FileManager, Set, FileTreeWatcherTests, URL

### Community 253 - "Split Right"
Cohesion: 0.12
Nodes (16): .onSelect, agentDetail(), AgentInboxBody, .body, .needsAttentionCount, AgentInboxPanelView, .init(agents:onSelect:), .init(coder:) (+8 more)

### Community 254 - "BoardViewController"
Cohesion: 0.16
Nodes (7): BrowserPaneRegistry, .init(url:paneID:), NSRect, NSWindow, PaneID, WKScriptMessage, WKUserContentController

### Community 255 - "release-hotfix.sh"
Cohesion: 0.08
Nodes (17): .records, .searchQuery, .selectedAgents, .selectedScope, Set, UInt64, AgentUsage, .contextTokens (+9 more)

### Community 256 - "GitMetadataProvider"
Cohesion: 0.19
Nodes (5): HistorySearchQueryTests, PortableRelativeDateFormatter, Date, String, UUID

### Community 257 - "Sidebar SwiftUI Migration — Knowledge"
Cohesion: 0.11
Nodes (13): BoardCardView, .init(card:), .init(coder:), BoardViewController, .isVisible, FlippedView, .isFlipped, Bool (+5 more)

### Community 258 - "WindowTitleStripView"
Cohesion: 0.17
Nodes (19): fetchGitStatus(), ProjectCategorySection, .body, .c, ProjectDirectoryTreeModel, .isExpanded, ProjectDirectoryTreeView, .body (+11 more)

### Community 259 - "ThemeFileServiceTests"
Cohesion: 0.08
Nodes (23): 1. Create an Isolated Git Worktree, 1. Overview & Architecture Principle, 1. Transition Status, 2. Reuse Existing Worker Session & Worktree, 2. Roles & Vocabulary, 2. Spawn Worker with Atomic Prompt Delivery, 3. Dispatch Fix Prompt, 3. Step-by-Step Orchestration Lifecycle (+15 more)

### Community 260 - ".welcome"
Cohesion: 0.14
Nodes (14): InstallError, daemonNotFound, .description, launchctlFailed, writeFailed, InstallReport, LaunchAgentInstaller, .isInstalled (+6 more)

### Community 261 - "Browser Pane (P14)"
Cohesion: 0.12
Nodes (5): SessionPersistenceTests, Bool, String, TabID, URL

### Community 262 - ".install"
Cohesion: 0.08
Nodes (14): GitParsers, String, GitRunner, GitResult, String, TimeInterval, URL, GitService (+6 more)

### Community 264 - "code:bash (harness-cli install-hooks claude-code)"
Cohesion: 0.20
Nodes (3): SessionID, String, String

### Community 265 - "code:bash (harness-cli install-hooks cursor)"
Cohesion: 0.15
Nodes (7): FileManager, String, URL, ThemeFileService, String, URL, ThemeFileServiceTests

### Community 266 - ".path"
Cohesion: 0.10
Nodes (22): cardHTML(), closeSheet(), goto(), #list-count, openSession(), renderSessions(), SESSIONS, terminal on mobile research (+14 more)

### Community 267 - ".performInstall"
Cohesion: 0.17
Nodes (3): RegressionBugFixTests, Tab, TaskRequestCounter

### Community 268 - "code:bash (# Old (agent-specific):)"
Cohesion: 0.12
Nodes (6): PromptQueue, String, SurfaceID, Void, PromptQueueBar, NSWindow

### Community 269 - "DefaultTerminalManager"
Cohesion: 0.14
Nodes (19): .modifierFlags, NSEvent, BannerShortcut, .init(from:), .init(key:description:showInBanner:), BannerShortcutRegistry, .bannerShortcuts, CodingKeys (+11 more)

### Community 270 - "WindowSession"
Cohesion: 0.14
Nodes (11): NSCoder, NSEvent, NSImage, NSPanel, NSRect, String, Void, TabCell (+3 more)

### Community 272 - "SGRMouseEvent"
Cohesion: 0.12
Nodes (16): AgentSessionHistoryView, .body, .footerView, HistoryMenuProxy, Any, Bool, CGFloat, Date (+8 more)

### Community 273 - "KeySpec"
Cohesion: 0.19
Nodes (12): CGFloat, NSCoder, SessionID, String, Void, TaskDashboardBody, .body, TaskDashboardView (+4 more)

### Community 274 - "[2.5.0] - 2026-06-12"
Cohesion: 0.17
Nodes (21): Decodable, Item, ItemCompletedLine, LegacyMsgLine, Msg, String, ThreadStartedLine, AgentCommandRequest (+13 more)

### Community 275 - "P8: macOS 27 Golden Gate Adoption"
Cohesion: 0.23
Nodes (6): DoctorRunner, Bool, URL, DoctorRunnerTests, String, URL

### Community 277 - ".run"
Cohesion: 0.22
Nodes (7): EnvironmentStore, Persisted, String, URL, global, EnvironmentStoreTests, URL

### Community 278 - "BlockTintOverlay"
Cohesion: 0.33
Nodes (7): FileGraphInfo, GraphifyLSPBridge, GraphIndexCache, Date, Double, String, URL

### Community 279 - "DisplayPanesOverlay"
Cohesion: 0.16
Nodes (8): OutputTrigger, OutputTriggerStore, Bool, String, OutputTriggerMatcher, .matches(in:patterns:), String, OutputTriggerMatcherTests

### Community 280 - ".menu"
Cohesion: 0.14
Nodes (16): DaemonSurfaceID, String, Array, SessionGroup, .activeTab, .init(from:), .init(id:name:tabs:activeTabID:lastActiveTabID:sortOrder:groupID:persistent:), .isWorktreeSession (+8 more)

### Community 281 - "TerminalScrollbarView"
Cohesion: 0.22
Nodes (5): FormatContextDaemonTests, PaneID, String, SurfaceID, URL

### Community 282 - "RemoteHostStoreTests"
Cohesion: 0.33
Nodes (5): SearchBenchmarks, String, UInt64, URL, Void

### Community 283 - "FormatColor"
Cohesion: 0.19
Nodes (10): RecordClient, RecordingWriter, RecordSession, Summary, Bool, DispatchSourceSignal, FileHandle, Int32 (+2 more)

### Community 284 - "click_ui_element"
Cohesion: 0.17
Nodes (12): DefaultTerminalManager, DefaultTerminalOpener, DefaultTerminalRegistrationError, .errorDescription, failed, DefaultTerminalStatus, .isDefault, .summary (+4 more)

### Community 285 - "After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md."
Cohesion: 0.14
Nodes (10): FrecencyDirectoryStore, FrecencyEntry, Date, Double, Never, String, Task, URL (+2 more)

### Community 286 - "code:bash (harness-cli install-hooks hermes)"
Cohesion: 0.18
Nodes (20): CoreImage, AttachedAck, attachToPairedSurface(), ConnectionState, .authorized, .subscription, .surfaceID, detectHost() (+12 more)

### Community 287 - ".apply"
Cohesion: 0.22
Nodes (7): Group, PrefixCheatsheetWindow, .groups, PrefixIndicatorWindow, CGFloat, NSTextField, NSWindow

### Community 288 - "AgentHookStrategy"
Cohesion: 0.21
Nodes (7): NodeRow, .body, .parentDirectory, Error, Never, String, Void

### Community 289 - "StatusLineWidthTests"
Cohesion: 0.13
Nodes (7): TimeInterval, Logger, AgentHandoffBuilder, Bool, String, HandoffDirectoryTests, AgentHandoffBuilderTests

### Community 291 - "JSONDecoder"
Cohesion: 0.19
Nodes (8): AgentRemoteControlDaemonService, Set, String, Void, AgentRemoteControlDaemonServiceTests, LogBox, .count, String

### Community 292 - "Release runbook"
Cohesion: 0.16
Nodes (9): AgentAvailabilityChecker, Availability, installedAuthenticated, installedNeedsKey, notInstalled, Bool, String, AgentTable (+1 more)

### Community 293 - "Fixes Applied (layered)"
Cohesion: 0.27
Nodes (4): AgentNotchViewModel, Bool, CGFloat, Duration

### Community 294 - "GitHubCLIClient"
Cohesion: 0.14
Nodes (8): brn, grn, hrn(), JGe(), KGe(), prn(), qGe(), zGe()

### Community 295 - "AgentApprovalBar"
Cohesion: 0.09
Nodes (21): name, options, bundleIdPrefix, createIntermediateGroups, deploymentTarget, packages, Kouen, Sparkle (+13 more)

### Community 296 - "NotificationBus"
Cohesion: 0.16
Nodes (9): WindowInputRouterTests, KeySpecDecode, complete, incomplete, invalid, literalPrefix, UInt8, Unicode (+1 more)

### Community 298 - "jobs"
Cohesion: 0.10
Nodes (20): Agent Memory, AI-SDLC — Dev/QA Workflow Spine, AODD: the operating contract, AODD triage: every request passes this gate (silently, no announcement), Approval Gates (mandatory on the Requirement path), Audit and Done, Cheap-model delegation, Core facts (non-negotiable, not model-inferable — everything else is judgment) (+12 more)

### Community 299 - "PaneNode"
Cohesion: 0.09
Nodes (11): CommandPaletteController, PaletteCommandConfig, PaletteMode, errors, grep, normal, PalettePanel, .canBecomeKey (+3 more)

### Community 300 - "HarnessPaths.swift"
Cohesion: 0.18
Nodes (11): Never, NSRegularExpression, Set, String, Task, URL, Void, WorkspaceSymbolIndex (+3 more)

### Community 301 - ".parse"
Cohesion: 0.16
Nodes (8): CustomEndpointTester, Result, Bool, String, URL, CustomEndpointTesterTests, URLRequest, URLSession

### Community 302 - "ThemeDiagnostics"
Cohesion: 0.20
Nodes (6): Keyboard Shortcuts, AI Browser Control (kouen-mcp), HTTP/SSE authentication, Install, Shell integration (OSC 133 semantic prompts), What gets emitted

### Community 303 - ".encodeMouse"
Cohesion: 0.12
Nodes (13): CryptoKit, Network, DecodedWSFrame, Bool, ConnectionState, NWConnection, String, UInt8 (+5 more)

### Community 304 - "00-inception-plan.md"
Cohesion: 0.16
Nodes (9): AgentListFormatter, Date, String, dvn(), ht(), AgentListFormatterTests, Bool, Date (+1 more)

### Community 305 - ".script"
Cohesion: 0.17
Nodes (8): PaneStyle, .isEmpty, PaneStyleSet, .init(window:windowActive:pane:paneActive:), .isEmpty, Bool, String, PaneStyleTests

### Community 306 - "RegressionBugFixTests"
Cohesion: 0.17
Nodes (16): SessionRef, byID, byName, next, previous, String, UUID, TargetSpec (+8 more)

### Community 307 - "ViPathTokenTests"
Cohesion: 0.21
Nodes (9): BinaryRefresher, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, URL, BinaryRefresherTests, String (+1 more)

### Community 308 - "Send Ex Command"
Cohesion: 0.20
Nodes (7): Recipe, RecipesStore, Bool, String, URL, UUID, RecipesStoreTests

### Community 309 - "Browser DevTools API (P28)"
Cohesion: 0.14
Nodes (18): CodingKeys, activeSessionID, activeTabID, id, name, sessions, sortOrder, tabs (+10 more)

### Community 310 - "FrameSignposter"
Cohesion: 0.13
Nodes (13): BinaryInstaller.DetectionStatus, SetupStepView, .canInstall, .hooksDetail, .hooksTone, .hooksValue, .isSuccess, .notifTone (+5 more)

### Community 311 - "Bug: Tab-Switch Black Screen"
Cohesion: 0.18
Nodes (6): DefaultTerminalLaunchRequest, ShellQuoting, Bool, String, URL, DefaultTerminalLaunchRequestTests

### Community 312 - "AgentSnapshot"
Cohesion: 0.15
Nodes (9): _7(), A7(), a8(), bGt(), c8(), ene(), Gnn, IC() (+1 more)

### Community 313 - "Terminal AI Chat (⌘I inline overlay)"
Cohesion: 0.11
Nodes (13): Date, String, TerminalBlock, TerminalBlockStore, .block(atPromptLine:), .block(id:), .lastFinishedBlock, .block(id:) (+5 more)

### Community 314 - "code:bash (harness-cli install-hooks codex)"
Cohesion: 0.25
Nodes (5): ResolvedCanvas, String, ThemeManager, ThemePreset, ThemeManagerTests

### Community 315 - "code:bash (harness-cli install-hooks grok)"
Cohesion: 0.17
Nodes (4): AgentHistoryMultiAgentCoverageTests, Bool, String, URL

### Community 316 - "code:bash (harness-cli install-hooks opencode)"
Cohesion: 0.07
Nodes (27): CodingKeys, error, id, jsonrpc, method, JSONRPCId, int, string (+19 more)

### Community 318 - "code:bash (# In a Harness pane:)"
Cohesion: 0.10
Nodes (3): Bool, String, UUID

### Community 320 - "Focus Persistence — Per-Session-Tab Pane Focus (RL-043)"
Cohesion: 0.21
Nodes (7): AIProviderAwakeService, .closedLidOptedIn, Bool, NSObjectProtocol, Set, String, AIProviderAwakeServiceTests

### Community 321 - "UInt64"
Cohesion: 0.21
Nodes (8): SettingsAdvancedView, .body, Bool, String, SettingsFileSearchSection, .body, String, SwiftUI

### Community 322 - "DesktopNotifier"
Cohesion: 0.16
Nodes (8): NSHostingView, NSLayoutConstraint, TerminalTabBarView, .delegate, .init(frame:), .leadingInset, .mouseDownCanMoveWindow, .trailingInset

### Community 323 - "LayoutNode"
Cohesion: 0.09
Nodes (8): ScreenPos, bottom, middle, top, KouenLSP, QuickLookUI, ViDiagnosticNavigatorTests, LSPLifecycleTests

### Community 324 - "WorkspaceSymbolIndex"
Cohesion: 0.14
Nodes (10): Bool, CGFloat, NSCoder, NSLayoutConstraint, NSPoint, NSRect, WindowTitleStripView, .init(coder:) (+2 more)

### Community 325 - "FloatingPaneController"
Cohesion: 0.12
Nodes (10): KouenSyntaxResources, ObjectiveC, CGFloat, NSControl, StaticString, String, UInt, TabNavigationButtonsTests (+2 more)

### Community 326 - "worktree_isolation.robot"
Cohesion: 0.16
Nodes (5): TabID, WorkspaceID, AgentCommandTests, String, Tab

### Community 327 - ".theme"
Cohesion: 0.14
Nodes (18): ChooseScope, buffer, client, session, tree, window, Command, MenuItem (+10 more)

### Community 328 - "README.md"
Cohesion: 0.14
Nodes (9): CommandIPCTranslator, CommandTranslation, clientLocal, unresolved, Command, PaneID, String, TabID (+1 more)

### Community 329 - "ImmersivePalette.swift"
Cohesion: 0.13
Nodes (15): CodingKeys, activeWorkspaceID, keepSessionsOnQuit, revision, savedAt, themeName, version, workspaces (+7 more)

### Community 330 - ".drawGlyph"
Cohesion: 0.18
Nodes (3): ShellIntegrationTests, .repoRoot, URL

### Community 331 - ".recordReapedGenerationForTesting"
Cohesion: 0.12
Nodes (10): ClientSummary, DaemonStats, Bool, Date, Double, Int32, String, UUID (+2 more)

### Community 332 - "Added"
Cohesion: 0.12
Nodes (9): .lspPosition(characterOffset:), .lspPosition(for:), LSPPosition, LSPTextLocation, .position, LSPTextLocationParser, String, URL (+1 more)

### Community 333 - "RealPty"
Cohesion: 0.32
Nodes (3): BinaryInstallerVersionTests, String, URL

### Community 334 - "ImageProtocolTests.swift"
Cohesion: 0.20
Nodes (6): Case, ReflowCorpusTests, .corpus, .goldenDir, String, URL

### Community 335 - ".makeModel"
Cohesion: 0.23
Nodes (8): .webView(_:didFail:withError:), .webView(_:didFailProvisionalNavigation:withError:), .webView(_:didFinish:), .webView(_:didStartProvisionalNavigation:), Bool, Double, Error, WKNavigation

### Community 336 - "run.sh"
Cohesion: 0.06
Nodes (31): DetachedPaneOverlay, .init(coder:), .init(frame:style:), InputGate, .siblings, ReconnectLatch, .isTripped, Style (+23 more)

### Community 337 - "CommandExecutionError"
Cohesion: 0.19
Nodes (6): KouenOnboarding, Agent, OnboardingEnvironment, Bool, String, OnboardingEnvironmentTests

### Community 338 - "CSIParams"
Cohesion: 0.15
Nodes (11): SwarmFleetBody, .body, SwarmFleetView, .init(coder:), SwarmNodeRowView, .body, .statusColor, CGFloat (+3 more)

### Community 339 - "Foundation"
Cohesion: 0.11
Nodes (19): 10. Attach over ssh — the compositor, 11. Window search and filtering, 12. Shell integration (prompt marks + the success/failure gutter), 13. Agent hooks (notifications), 14. macOS shortcuts (no prefix), 15. One-screen cheat sheet, 1. The mental model, 2. The prefix key (+11 more)

### Community 340 - "code:bash (harness-cli install-hooks openclaw)"
Cohesion: 0.11
Nodes (18): fix ที่ค้างอยู่ใน working tree (ยังไม่ commit), Terminal grid ไม่ใช่ก้อนใหญ่ที่ระบุชนิดได้, ก้อนหลักเกี่ยวข้องกับ RenderBox, การให้ DeepSeek ตรวจเพิ่ม, ผลตรวจ preview ที่แยกจากแอปหลัก, ผลตรวจแอปหลัก, ภาคผนวก 1 — fleet 9 ต.ค. (P54) กระทบ UI ไหม → กระทบ ตรงจุด, ภาคผนวก 2 — 18 ต.ค. `8c5e0c8d` P59 (agy session, **unreviewed**) (+10 more)

### Community 341 - "code:bash (harness-cli install-hooks pi)"
Cohesion: 0.20
Nodes (9): KouenCommands, DemoSession, DemoTerminalView, .body, GridCanvas, Bool, CGFloat, String (+1 more)

### Community 342 - "Added"
Cohesion: 0.12
Nodes (17): Bool, String, WorkbenchCommand, ack, agent, attention, board, cd (+9 more)

### Community 343 - "[2.2.3] - 2026-06-09"
Cohesion: 0.15
Nodes (12): OptionStore.Value, .boolValue, .intValue, .statusLineCount, .stringValue, Bool, Value, bool (+4 more)

### Community 344 - "FileViewerViewController"
Cohesion: 0.16
Nodes (16): SwarmFleetSnapshot, SwarmLane, pty, structured, SwarmTaskNode, SwarmTaskStatus, cancelled, failed (+8 more)

### Community 345 - "README.md"
Cohesion: 0.18
Nodes (4): HookFiringTests, NSObjectProtocol, String, URL

### Community 346 - "Agent platform icons"
Cohesion: 0.19
Nodes (5): ezt(), GGe, Gwe(), Hzt(), Kp()

### Community 347 - "[3.2.0] - 2026-06-16"
Cohesion: 0.16
Nodes (4): KouenThemeCatalog, .allThemes, String, KouenThemeCatalogTests

### Community 349 - "Contents.json"
Cohesion: 0.19
Nodes (11): ControlModeClient, ControlModeError, daemon, .description, noMatch, noSnapshot, unresolved, Command (+3 more)

### Community 350 - "Background Polling & Snapshot Fanout — P22"
Cohesion: 0.22
Nodes (9): CheckResult, GitCloneUpdateChecker, .dismissFileURL, RemoteVersion, Bool, Pipe, String, TimeInterval (+1 more)

### Community 351 - "Architecture Decisions — harness-terminal"
Cohesion: 0.13
Nodes (15): .agentInfo(forWorktreePath:), Reason, errored, finished, needsInput, RowState, Bool, Comparable (+7 more)

### Community 352 - "Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)"
Cohesion: 0.15
Nodes (6): .agentInfo(forWorktreePath:tabs:), Tab, TabID, WorkspaceID, GitPanelViewWorktreeAgentTests, GitPanelViewWorktreeNavigationTests

### Community 353 - "GPU Animation Pattern — Layout Once, GPU Paints"
Cohesion: 0.12
Nodes (10): MainMenuBuilder, MenuTarget, Bool, NSMenu, NSMenuItem, Selector, String, SurfaceID (+2 more)

### Community 354 - "P10: Performance and Feature Roadmap (Terminal First, IDE Convenient)"
Cohesion: 0.19
Nodes (9): ArraySlice, Request, Any, Bool, Date, String, VSCodeChatSession, array (+1 more)

### Community 355 - ".deepMerge"
Cohesion: 0.19
Nodes (13): CancelHarnessRun, CloseSurface, CreatePTYSurface, GetHarnessRun, LaneATask, SwarmWorkerManager, Bool, Duration (+5 more)

### Community 356 - "SurfaceProgressTracker"
Cohesion: 0.16
Nodes (14): CellMetrics, KouenCompositor, CellMetrics, ComposedTerminalView, .body, .metrics, .pixelHeight, .pixelWidth (+6 more)

### Community 357 - ".handleCat"
Cohesion: 0.15
Nodes (10): HTTPURLResponse, SSETransportTests, Never, String, Task, UInt16, Void, Bool (+2 more)

### Community 358 - "[3.5.1] - 2026-06-20"
Cohesion: 0.15
Nodes (12): KouenThemeDefinition, .backgroundHex, .boldHex, .cursorHex, .cursorTextHex, .foregroundHex, .isDark, .paletteHex (+4 more)

### Community 359 - "OcclusionTests"
Cohesion: 0.18
Nodes (13): FeaturePhase, architect, completed, dev, interview, qaDesign, qaVerify, .title (+5 more)

### Community 361 - "FormatStyledSegment.swift"
Cohesion: 0.10
Nodes (10): Divergence, Bool, String, TimeInterval, WorktreeInfo, WorktreeManager, String, URL (+2 more)

### Community 362 - "RGBColor"
Cohesion: 0.22
Nodes (6): ThemeDocumentError, emptyName, malformed, unsupportedVersion, wrongPaletteCount, ThemeDocumentTests

### Community 363 - "generate-cheatsheet.js"
Cohesion: 0.11
Nodes (17): Artifacts, Client Application, Client Application, Client Application, Context, D1 — File preview (read-only), D2 — File/image attach (upload), D3 — Browser mirror (embedded, mirrors Mac's real BrowserPaneView) (+9 more)

### Community 364 - "[2.2.4] - 2026-06-11"
Cohesion: 0.40
Nodes (5): PaneOutputWaiter, PaneOutputWaitResult, CheckedContinuation, Never, UInt64

### Community 365 - "Fixes Applied (v3.9.1+)"
Cohesion: 0.29
Nodes (7): AnimatablePair, NotchShape, .animatableData, CGFloat, CGPath, CGRect, Path

### Community 366 - "Consumers"
Cohesion: 0.17
Nodes (9): GitStatusProvider, OnceResume, Bool, Duration, String, TimeInterval, GitStatusProviderLargeOutputTests, URL (+1 more)

### Community 367 - "DaemonStats"
Cohesion: 0.20
Nodes (4): Bool, String, SurfaceID, TimeInterval

### Community 368 - "Tab"
Cohesion: 0.21
Nodes (6): ExternalOpenKind, filePreview, terminal, theme, Set, ExternalOpenKindTests

### Community 369 - "Git Panel"
Cohesion: 0.25
Nodes (11): CGFloat, Never, Range, Tab, Task, Void, TabBarLayoutMetrics, .pitch (+3 more)

### Community 370 - ".encode"
Cohesion: 0.15
Nodes (8): DispatchSource, DispatchQueue, DispatchSourceFileSystemObject, Int32, URL, Void, TranscriptFileWatcher, MobileBridgeTranscriptWatcherTests

### Community 372 - "DynamicInstanceBuffer"
Cohesion: 0.21
Nodes (6): HookNotificationParser, Parsed, Any, String, HookNotificationParserTests, String

### Community 373 - "Prompt"
Cohesion: 0.20
Nodes (4): CompletionGenerator, String, .fishCompletionSource, CompletionGeneratorTests

### Community 374 - ".run"
Cohesion: 0.19
Nodes (7): Scope, pane, session, tab, workspace, ScopedKey, URL

### Community 375 - ".install"
Cohesion: 0.18
Nodes (10): AssistantLine, ClaudeAdapter, Content, Message, ResultLine, Bool, Double, String (+2 more)

### Community 376 - "ScrollReuseTests"
Cohesion: 0.18
Nodes (8): ClaudeRunSummary, Date, Double, Int32, String, UUID, String, UUID

### Community 377 - "Identifiable"
Cohesion: 0.29
Nodes (4): SwarmDAGStore, String, UUID, SwarmDAGStoreTests

### Community 378 - "SurfaceProgressTrackerTests.swift"
Cohesion: 0.26
Nodes (6): Bool, NSRange, NSString, NSTextView, String, unichar

### Community 379 - "MCPServer"
Cohesion: 0.29
Nodes (6): .captureLines(fromLine:toLine:), .captureLines(joinWrapped:), .feed(_:), Bool, String, UInt8

### Community 380 - "PromptQueue"
Cohesion: 0.15
Nodes (10): OutputCoalescer, .bufferedMemoryBytes, .bufferedSpoolBytes, .retainedChunkSlots, OutputDiskSpool, .isDrained, .remainingBytes, FileHandle (+2 more)

### Community 381 - "smoke-dmg.sh"
Cohesion: 0.26
Nodes (3): String, ThemeDiagnostics, ThemeDiagnosticsTests

### Community 382 - "ThaiClusterRenderTests"
Cohesion: 0.27
Nodes (4): ArchitectureGuardTests, .repoRoot, String, URL

### Community 383 - "terminal_stress_runner.py"
Cohesion: 0.07
Nodes (23): .effectiveResumeCommand(mode:), AgentLaunchCommands, AgentLaunchConfig, ResumeStyle, bare, flag, none, subcommand (+15 more)

### Community 384 - "NSTextField Leak in BoardViewController (P20 Performance)"
Cohesion: 0.24
Nodes (4): Tab, TabID, WorkspaceID, TabAlertTests

### Community 386 - "SKILL-LOG.md"
Cohesion: 0.22
Nodes (3): KittyGraphicsConformanceTests, String, Void

### Community 387 - "User Profile"
Cohesion: 0.27
Nodes (10): AddToWorkspaceSheet, .allSelected, .body, .folderName, .listHeight, .selectedCount, DiscoveredRepoItem, FolderScanner (+2 more)

### Community 388 - "Darwin"
Cohesion: 0.20
Nodes (8): InstallChoice, cancel, install, installAndApply, Error, String, URL, ThemeImportController

### Community 389 - "HarnessCLITests"
Cohesion: 0.57
Nodes (3): ProjectConfig, Bool, String

### Community 390 - "UI Automation — Robot Framework (P18)"
Cohesion: 0.17
Nodes (5): NotificationCenterProbe, .isKnownBad, Bool, Void, NotificationCenterProbeTests

### Community 391 - "AppKit + Metal Patterns"
Cohesion: 0.18
Nodes (10): SessionTaskRequests, Bool, escaping, Never, Sendable, String, Task, UUID (+2 more)

### Community 392 - "build-release.sh"
Cohesion: 0.09
Nodes (19): SettingsHostingController, .init(coder:), .init(page:), SettingsWindowController, NSCoder, NSWindow, Page, advanced (+11 more)

### Community 393 - "create-dmg.sh"
Cohesion: 0.30
Nodes (8): KouenChrome, KouenChromePalette, Bool, CGFloat, NSColor, String, PaletteFooter, .body

### Community 394 - "finalize-release.sh"
Cohesion: 0.30
Nodes (5): AgentNotchPeekDecider, String, AgentNotchPeekDeciderTests, Bool, String

### Community 395 - "generate-app-icon.sh"
Cohesion: 0.30
Nodes (4): Bool, OptionStore, OptionStoreTests, URL

### Community 396 - "generate-appcast.sh"
Cohesion: 0.12
Nodes (15): agy, claude, codex, copilot, hermes, kouen, __kouen_agy_next, __kouen_claude_next (+7 more)

### Community 397 - "measure-fluidity.sh"
Cohesion: 0.25
Nodes (8): Bool, String, TimeInterval, TimeoutFlag, .didFire, VerificationResult, VerificationRunner, String

### Community 398 - "preview.sh"
Cohesion: 0.21
Nodes (3): .hasAdapter(for:), Bool, ClaudeCodeHarnessTests

### Community 399 - "sign-and-notarize.sh"
Cohesion: 0.13
Nodes (15): BrowserRequestPayload, close, cookies, evaluate, goBack, goForward, interact, navigate (+7 more)

### Community 400 - "install-linux.sh"
Cohesion: 0.12
Nodes (5): Int, CSIParams, .count, UInt8, .cursorVisible

### Community 401 - "package-app.sh"
Cohesion: 0.13
Nodes (11): ResizeHUDView, .cornerConfiguration, .init(coder:), .init(frame:), DispatchWorkItem, NSCoder, NSColor, NSPoint (+3 more)

### Community 402 - "View"
Cohesion: 0.12
Nodes (15): Addendum — MAW-pattern validate gate (2026-07-23), Already matched (verified in code, not gaps), Method, Not gaps — deliberate positioning differences (no action), P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux), Phase A — Remote workflow parity (G2) — DONE 2026-07-11, Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11, Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass) (+7 more)

### Community 404 - "Split Panes (NSSplitView)"
Cohesion: 0.18
Nodes (8): BrowserFileReloadTests, CountingWebView, Nav, NSEvent, String, Void, WKNavigation, WKNavigationDelegate

### Community 405 - "AgentIconRenderer"
Cohesion: 0.16
Nodes (16): KouenTask, .init(from:), .init(id:sessionID:title:done:status:createdAt:updatedAt:cwd:), KouenTaskStatus, ciFailing, done, mergeReady, open (+8 more)

### Community 406 - "main.swift"
Cohesion: 0.27
Nodes (7): AgentCatalog, AgentConfig, DiskAgentConfig, Bool, String, .detectionSection, agents

### Community 407 - "Fixed"
Cohesion: 0.20
Nodes (7): FileChangeWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void, FileChangeWatcherTests

### Community 408 - "IPC Architecture"
Cohesion: 0.22
Nodes (9): LayoutFileStore, LayoutNode, branch, leaf, LayoutTemplate, Date, Double, String (+1 more)

### Community 409 - "Session/Tab/Pane Hierarchy & Top Bar (CASE-028)"
Cohesion: 0.13
Nodes (3): .activePaneIsDetached, SurfaceID, TerminalPaneRegistryAccess

### Community 410 - ".applyTerminalIdentity"
Cohesion: 0.17
Nodes (6): FloatingPaneController, Any, Bool, NSEvent, NSObjectProtocol, NSPanel

### Community 411 - "Task 1: Redesign Session Sidebar"
Cohesion: 0.13
Nodes (12): SettingsAppearanceView, .autoTheme, .body, .themeSection, SliderRow, .body, .displayValue, Bool (+4 more)

### Community 412 - "go.json"
Cohesion: 0.13
Nodes (15): CodingKeys, excludedPaths, id, name, sourceFolder, CodingKey, CodingKeys, createdAt (+7 more)

### Community 413 - "javascript.json"
Cohesion: 0.24
Nodes (8): ProjectDropTarget, .init(coder:), .init(frame:), NSCoder, NSDraggingInfo, NSDragOperation, NSRect, URL

### Community 414 - "json.json"
Cohesion: 0.22
Nodes (10): DotView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor, NSRect (+2 more)

### Community 415 - "markdown.json"
Cohesion: 0.23
Nodes (13): kouen.bash script, agy(), claude(), codex(), copilot(), hermes(), kouen(), __kouen_agy_next() (+5 more)

### Community 417 - "rust.json"
Cohesion: 0.18
Nodes (7): CGFloat, NSColor, NSPoint, NSRect, NSWindow, WindowBorderOverlayView, .windowCornerRadius

### Community 418 - "RealPtyLifecycleTests"
Cohesion: 0.26
Nodes (4): ContextResolutionEngine, Bool, String, String

### Community 419 - "typescript.json"
Cohesion: 0.24
Nodes (8): InstallResult, Shell, bash, fish, zsh, ShellIntegration, Bool, URL

### Community 420 - "yaml.json"
Cohesion: 0.22
Nodes (5): RepoResolver, Bool, String, RepoResolverTests, String

### Community 421 - "FilePreviewCoordinatorTabScopeTests"
Cohesion: 0.24
Nodes (4): Bool, Double, TerminalReplay, TerminalRecordingTests

### Community 422 - "HintModeOverlay"
Cohesion: 0.05
Nodes (34): _0t(), _at(), b_n(), bgn(), _Bt(), by(), byn(), cgn() (+26 more)

### Community 423 - "SixelDecoder"
Cohesion: 0.18
Nodes (4): AsciiFastPathTests, StaticString, String, UInt

### Community 424 - ".parseDiffHunks"
Cohesion: 0.20
Nodes (13): ern(), G4(), G7(), Jnn(), nrn(), Qnn(), sHe(), trn() (+5 more)

### Community 425 - "AgentVectorIcon"
Cohesion: 0.21
Nodes (6): SurfaceID, Tab, TabID, BrowserPaneReuseScopeTests, Tab, TabID

### Community 426 - "Bug — Cmd+\ sidebar toggle gone after collapse"
Cohesion: 0.13
Nodes (14): Artifacts, Client Application — Shader Presets (F4) — **UI REVERTED 2026-07-11, user call**, Client Application — Task Dashboard (F1), Context, Data Storage — Tasks (F1), Dev Task Progress — P40 MCP Surface Expansion + Shader Presets, Integration, Lessons applied (from `agent-memory/knowledge/rl-lessons.md`, surfaced during this session's P38 review) (+6 more)

### Community 427 - ".delay"
Cohesion: 0.19
Nodes (9): InterruptFlag, .value, ReplayClient, ReplayPlayer, Bool, DispatchSourceSignal, Double, Int32 (+1 more)

### Community 428 - "TaskDashboardView"
Cohesion: 0.22
Nodes (7): CLIInstaller, .binDirectory, .installedCLIPath, .installedDaemonPath, Bool, String, URL

### Community 429 - "Case: cwd "bleed" — session worktree jumps to wrong dir during builds"
Cohesion: 0.22
Nodes (3): RemoteHostsService, .activeHostName, String

### Community 430 - "Competitive Position (as of v3.12.0, 2026-07-02)"
Cohesion: 0.23
Nodes (5): String, TextGrid, .totalLines, .viewportRows, WordColumnRangeTests

### Community 431 - "BoardCardView"
Cohesion: 0.17
Nodes (12): SurfaceProgressTracker, Bool, DispatchWorkItem, MainActor, SurfaceID, TimeInterval, Void, Counter (+4 more)

### Community 432 - "PathToken"
Cohesion: 0.18
Nodes (3): SessionGroup, String, UUID

### Community 433 - "LaunchdServiceInstaller"
Cohesion: 0.18
Nodes (11): agentColor(), Notification.Name, SidebarBadgeLabel, .body, SidebarDividerRow, .body, SidebarSessionListView, .filterChipsHeader (+3 more)

### Community 434 - "Project History"
Cohesion: 0.19
Nodes (10): LaunchdServiceInstaller, .backendName, .isInstalled, ServiceInstaller, ServiceInstallers, .current, ServiceInstallReport, Bool (+2 more)

### Community 435 - ".init"
Cohesion: 0.22
Nodes (8): DisplayPanesChipView, .cornerConfiguration, DisplayPanesOverlay, Any, NSEvent, NSViewCornerConfiguration, SurfaceID, Void

### Community 436 - "WaitForRegistry"
Cohesion: 0.13
Nodes (11): Bool, NotificationEvent, agentFinished, agentWaiting, bell, commandFinished, .defaultEnabled, .detail (+3 more)

### Community 437 - "PickerItemRow"
Cohesion: 0.14
Nodes (14): Agent handbook — Kouen (extended reference), Agent integration, Build and test, IPC, Keyboard shortcuts, kouen-cli, Native terminal renderer, Repository map (+6 more)

### Community 438 - "SessionEditor"
Cohesion: 0.14
Nodes (4): KouenCLI, MemoCommandTests, URL, TaskCommandTests

### Community 439 - "SetupStepView"
Cohesion: 0.18
Nodes (6): JSONOutputFormatter, Bool, String, T, JSONOutputFormatterTests, T

### Community 440 - "LegacySnapshot"
Cohesion: 0.22
Nodes (6): ListeningPortScanner, Int32, Set, String, result, ListeningPortScannerTests

### Community 441 - "RemoteHostStore"
Cohesion: 0.41
Nodes (7): FeatureSummary, FeatureTaskSummary, GateSummary, Bool, Date, String, UUID

### Community 442 - "GroupedSessionDaemonTests"
Cohesion: 0.05
Nodes (25): Foundation, CodingKeys, cacheReadTokens, cacheWriteTokens, contextTokens, inputTokens, outputTokens, shortSummary (+17 more)

### Community 443 - "main.swift"
Cohesion: 0.16
Nodes (7): ProjectGroupResolver, String, String, .trimmed, AgentTitleInference, Bool, .effectiveAgentKind

### Community 444 - "BlockContextMenuTests"
Cohesion: 0.26
Nodes (7): string, AgentNotification, OSCNotificationParser, DaemonSurfaceID, Date, String, SurfaceID

### Community 445 - "Section"
Cohesion: 0.20
Nodes (5): OSCTerminatorMatch, PtyError, launchFailed, ShellLaunchProfile, .argv

### Community 446 - "Modifiers"
Cohesion: 0.23
Nodes (7): NotificationPermission, State, denied, granted, undetermined, MainActor, UNAuthorizationStatus

### Community 447 - "PaletteMode"
Cohesion: 0.29
Nodes (8): ShellInfo, ShellStepView, .allConfigured, .body, .noneConfigured, Bool, String, URL

### Community 449 - "PresentAttempt"
Cohesion: 0.14
Nodes (13): Artifacts, Category 1 — Pure refactor + extraction (no behavior change), Category 2 — Agents segment UI + aggregate refresh (A1 + A2), Category 3 — Merge/handoff action (A3), Category 4 — Regression + final gate, Context, Last updated: 2026-07-13, Lessons Learnt reviewed (+5 more)

### Community 450 - "SessionCoordinator.swift"
Cohesion: 0.14
Nodes (13): 1. Tasks — storage + MCP + IPC contracts, 2. Worktree (MCP resource) — MCP contracts only, 3. Hosts (MCP resource) — one read-only tool, 4. Shader Presets — rendering pipeline change, Host (MCP resource) — no new aggregate, Logical Design, Open items for task-design to resolve (not blocking, just unresolved here), P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets (+5 more)

### Community 451 - ".run"
Cohesion: 0.14
Nodes (13): Artifacts, Bigger finding: the planned "Add to Workspace" entry point was unreachable (2026-07-17), Bug found via real `make preview` testing (2026-07-17, post-Task-6), Client Application, Context, Dev Task Progress — Add Repo/Folder to Workspace (P43), Fourth real bug, surfaced by the label becoming honest (2026-07-17), Infrastructure / Data Storage (+5 more)

### Community 452 - "tmux parity — status, adaptations, and deliberate divergences"
Cohesion: 0.15
Nodes (11): copyMode, esc(), fs, globalShortcuts, KEYBINDINGS, prefixTable, renderTable(), ROOT (+3 more)

### Community 453 - ".deleteWorkspaceFromMenu"
Cohesion: 0.18
Nodes (9): BrowserTabRepaintTests, RepaintCountingWebView, Any, Error, MainActor, Sendable, String, TimeInterval (+1 more)

### Community 456 - "TerminalModes"
Cohesion: 0.17
Nodes (6): ScriptConfigLocator, Bool, String, ScriptHookCoordinator, Bool, String

### Community 457 - ".normalizedKey"
Cohesion: 0.18
Nodes (5): KouenFeatureMarkdownSync, Bool, String, URL, String

### Community 458 - "PaneOutputWaiter"
Cohesion: 0.24
Nodes (6): ScriptFileWatcher, DispatchSourceFileSystemObject, DispatchWorkItem, String, TimeInterval, Void

### Community 459 - ".encode"
Cohesion: 0.24
Nodes (4): HintModeOverlay, Any, NSEvent, String

### Community 460 - "RunState"
Cohesion: 0.11
Nodes (11): Bool, NSViewCornerConfiguration, String, TimeInterval, Toast, ToastBody, .body, ToastHostingView (+3 more)

### Community 461 - ".worktreeList"
Cohesion: 0.22
Nodes (11): MarkdownImageSchemeHandler, .webView(_:start:), .webView(_:stop:), Never, ObjectIdentifier, Task, URL, Void (+3 more)

### Community 462 - "AGENTS.md"
Cohesion: 0.23
Nodes (9): AttentionBeaconDotView, BeaconView, .init(coder:), .init(frame:), Bool, Context, NSCoder, NSColor (+1 more)

### Community 463 - ".deinit"
Cohesion: 0.06
Nodes (29): JSONDecoder, JSONEncoder, CodingKeys, cols, createdAt, dataBase64, rows, timeMs (+21 more)

### Community 464 - "MouseButton"
Cohesion: 0.27
Nodes (8): LegacySnapshot, LegacyWorkspace, Bool, Date, String, Tab, TabID, WorkspaceID

### Community 465 - "DirectionalAxis"
Cohesion: 0.29
Nodes (7): DaemonClientError, connectionFailed, .description, timeout, unexpectedResponse, writeFailed, Error

### Community 466 - "PlatformSys.swift"
Cohesion: 0.41
Nodes (5): InstallResult, ShellCompletionInstaller, Bool, String, URL

### Community 467 - ".moveSelection"
Cohesion: 0.21
Nodes (5): FDWatchdog, DispatchSourceTimer, String, TimeInterval, FDWatchdogTests

### Community 469 - "PresentAttempt"
Cohesion: 0.22
Nodes (3): ClaudeSessionModeTests, URL, Void

### Community 470 - "DispatchTime"
Cohesion: 0.24
Nodes (7): buffers, DynamicInstanceBuffer, MTLBuffer, MTLDevice, Range, String, T

### Community 471 - ".evaluateStyled"
Cohesion: 0.22
Nodes (5): aD(), crn, ELt(), n2e(), urn

### Community 472 - "start.sh script"
Cohesion: 0.18
Nodes (6): eKe(), irn(), mrn, _rn(), rrn(), srn()

### Community 473 - "HarnessOnboarding"
Cohesion: 0.15
Nodes (12): Artifacts, Client Application, Client Application, Client Application, Context, Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge), G1 — @ file-path picker ✅ DONE 2026-07-13, G2 — shell tab-completion suggestion strip (heuristic, best-effort) ✅ DONE 2026-07-13 (+4 more)

### Community 474 - "String"
Cohesion: 0.20
Nodes (6): KouenIntentError, .localizedStringResource, noActivePane, workspaceNotFound, CustomLocalizedStringResourceConvertible, KouenAppIntentsTests

### Community 475 - ".hitTest"
Cohesion: 0.26
Nodes (3): BellScanTests, Bool, UInt8

### Community 476 - "StatusDotView"
Cohesion: 0.26
Nodes (4): Bool, String, ThaiClusterRenderTests, .builder

### Community 477 - "SavedLayoutIPCDaemonTests"
Cohesion: 0.29
Nodes (7): FSEventStreamBox, escaping, FSEventStreamRef, MainActor, UnsafeMutableRawPointer, Void, WatcherContext

### Community 478 - ".install"
Cohesion: 0.33
Nodes (4): SecureInputPromptScanner, Bool, SecureInputPromptScannerTests, String

### Community 479 - "ScrollbackTests"
Cohesion: 0.20
Nodes (7): State, error, indeterminate, paused, remove, set, TerminalProgressReport

### Community 480 - ".isRisky"
Cohesion: 0.17
Nodes (5): DirectionalAxis, down, left, right, up

### Community 481 - "SecureInputMonitor"
Cohesion: 0.29
Nodes (4): Set, SurfaceID, Void, TerminalPaneRegistry

### Community 482 - ".resolve"
Cohesion: 0.14
Nodes (8): PluginLoader, String, ScriptAPI, JavaScriptCore, ConsoleLineCapTests, NetworkCaptureDecisionTests, Bool, String

### Community 484 - "CopilotAdapter"
Cohesion: 0.20
Nodes (9): BlockTintOverlay, .init(coder:), .init(surfaceView:), .isFlipped, Bool, CGFloat, NSCoder, NSPoint (+1 more)

### Community 485 - ".testKouenRendererFixtureLigatureShapingPathReportsPlausibleGlyphs"
Cohesion: 0.17
Nodes (12): Architecture Decisions (dated log), Commit preparation, Communication Protocols, Constraints & System Invariants, Dev & QA Verification Invariants, Kouen Terminal — System Architecture, Markdown preview trust boundary, Post-P50 changes (v4.20.2 → v4.20.11, 2026-10-01 → 2026-10-06) (+4 more)

### Community 486 - "TabPillView"
Cohesion: 0.17
Nodes (12): 1. Install Kouen, 2. Install The CLI On PATH, 3. Pick An Experience Mode, 4. Agent Notifications, 5. Recommended Shell Tools, 6. Troubleshooting, Kouen Usage, More Docs (+4 more)

### Community 487 - "bC"
Cohesion: 0.14
Nodes (12): .setupPrompt, AgentHookStrategy, eventArrayJSON, eventMatcherJSON, .filename, namedGroupJSON, ownJSONFile, ownTextFile (+4 more)

### Community 488 - "R1"
Cohesion: 0.24
Nodes (9): DiagnosticCheck, DiagnosticStatus, fail, .label, pass, warn, DoctorReport, .exitCode (+1 more)

### Community 489 - "SurfaceIO"
Cohesion: 0.33
Nodes (6): Bool, NSPasteboard, NSString, String, URL, AutoreleasingUnsafeMutablePointer

### Community 490 - "ccRunGet"
Cohesion: 0.26
Nodes (5): Mode, compatible, kouen, TerminalIdentity, TerminalIdentityTests

### Community 491 - ".update"
Cohesion: 0.26
Nodes (6): SwarmFleetSnapshotWire, SwarmTaskNodeWire, Date, Double, String, UUID

### Community 492 - "Service Decomposition — SessionCoordinator (P17)"
Cohesion: 0.24
Nodes (7): GlassEffectView, RuntimeGlassEffectView, Bool, CGFloat, Context, NSColor, .panelBackground

### Community 493 - "ccRunStart"
Cohesion: 0.17
Nodes (12): CodingKeys, appearance, applyToTerminalOutput, backgroundBlur, backgroundOpacity, contrastGrade, fontFamily, fontSize (+4 more)

### Community 494 - "ccRunInfo"
Cohesion: 0.17
Nodes (11): Competitive comparison (2026-07-13, post Phase D+E), Current architecture (as shipped, build 195), P37 — Mobile Connect v1: QR + Tailscale pairing, hardened + usable, Phase A — Hardening (daemon only, no UI), Phase B — In-app pairing UX (macOS Settings), Phase C — Real mobile client (W3, replaces smoke-test page) — DONE 2026-07-09, uncommitted, Phase D — File preview, file attach, browser mirror (v1.1 — the former W4/W4b/W5, now scoped), Phase F — candidates from competitive research (not scoped, not scheduled) (+3 more)

### Community 495 - ".open"
Cohesion: 0.17
Nodes (11): A — detection core (`AgentDetector`, pure logic), B — Claude Code Task-subagent hook push (in-process detection), C — IPC / Tab plumbing, Concurrency contract, Corrections to the original plan text (verified against live source, not assumed), D — Client UI indicator, Open items deferred out of this phase (documented, not silently dropped), P38 Phase B — Subagent/Teammate Visibility (+3 more)

### Community 496 - ".testProceduralBoxAndBlockCellsDoNotEnterShapedRunCache"
Cohesion: 0.35
Nodes (3): ShellCompletionInstallerTests, String, URL

### Community 497 - ".bind"
Cohesion: 0.24
Nodes (6): DaemonAsyncReplyRoutingTests, Int32, String, TimeInterval, UInt8, URL

### Community 498 - ".runGitDiff"
Cohesion: 0.20
Nodes (4): SavedLayoutIPCDaemonTests, String, URL, UUID

### Community 499 - "GlassEffectView"
Cohesion: 0.17
Nodes (3): String, URL, TaskIPCDaemonTests

### Community 500 - "zO"
Cohesion: 0.24
Nodes (5): RiskyCommandClassifier, Bool, NSRegularExpression, String, RiskyCommandClassifierTests

### Community 501 - "Fixed"
Cohesion: 0.36
Nodes (3): GitPanelViewHunkStagingTests, String, URL

### Community 502 - "Kouen Terminal — System Architecture"
Cohesion: 0.25
Nodes (6): AboutPanelController, AboutView, .body, MonoPillButtonStyle, Configuration, NSWindow

### Community 503 - "Kouen Features"
Cohesion: 0.21
Nodes (8): FileTreeKeyboardNavigator, FileTreeKeyboardState, Bool, NSEvent, String, Void, NSEvent, Observation

### Community 504 - "String"
Cohesion: 0.22
Nodes (3): Notification.Name, KouenGit, os

### Community 505 - ".tickFeatureWorktreeSweepLocked"
Cohesion: 0.18
Nodes (11): Typography, .badge, .kbd, .paletteHeader, .paletteTitle, .rowMeta, .rowTitle, .sectionLabel (+3 more)

### Community 508 - "qLt"
Cohesion: 0.23
Nodes (3): MobileBridgeAttachFileTests, String, URL

### Community 509 - "start.mjs"
Cohesion: 0.24
Nodes (8): AmbientBackground, .body, Bool, CGSize, GraphicsContext, TimeInterval, UInt8, .body

### Community 510 - "PromptQueue"
Cohesion: 0.18
Nodes (11): State, csiEntry, csiIgnore, csiIntermediate, csiParam, escape, escapeIntermediate, ground (+3 more)

### Community 511 - ".panePathLookup"
Cohesion: 0.18
Nodes (10): Current architecture relevant to these gaps, P38 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed), Phase A — Cross-agent diff/review dashboard (biggest gap vs Superset/Supacode) — ✅ DONE 2026-07-13, see p38-phase-a-diff-dashboard/{design.md,dev-task-progress.md}, Phase B — Subagent/teammate visibility as panes (vs cmux) — ✅ CLOSED 2026-07-16 (build/test/robot green, live check skipped per user decision), Phase C — Agent "thread" UX on top of existing block capture (vs Zed Terminal Threads) — ⚠️ pivoted 2026-07-15, ✅ CLOSED 2026-07-16 (build/test/robot green, cross-pane jump-to-block live check skipped per user decision), see p38-phase-c-thread-overlay/{design.md,dev-task-progress.md}, Phase D — Terminal image protocol (Kitty Graphics) — vs WezTerm — ✅ D1 DONE 2026-07-14 (finding: NOT deferred), D3 conformance slice built, ✅ CLOSED 2026-07-16 (build/test/robot green, real-client live check skipped per user decision), Phase E — Scripting hook parity (JS vs WezTerm's Lua) — low priority — ✅ DONE 2026-07-14, ✅ CLOSED 2026-07-16 (low-priority live check skipped per user decision), Phases (+2 more)

### Community 512 - ".setAttribute"
Cohesion: 0.18
Nodes (10): cmd-F contract (C2) — contextual, not a rewrite of `updateFind`, Design: overlay, not a new render subtree, Known caveat (pre-existing, inherited not fixed), Open decisions (not decided here, confirm before Stage 4 if it matters), Original design (2026-07-14, deleted 2026-07-15 — kept for history only), P38 Phase C — Agent Thread UX on Existing Block Capture, Pivot (2026-07-15, mid live-test) — supersedes the original design below, Regression risk: near-zero by construction (+2 more)

### Community 514 - "graphify reference: extra exports and benchmark"
Cohesion: 0.22
Nodes (7): PickerItem, .groupLabel, historyBlock, .id, recipe, .searchableText, SurfaceID

### Community 516 - "terminal_stress_runner.py"
Cohesion: 0.40
Nodes (3): ReflowFastPathTests, .feeds, String

### Community 517 - "KouenCLI+Workbench.swift"
Cohesion: 0.17
Nodes (11): LinePos, end, firstNonBlank, start, ViDiagnosticNavigator, ViMode, insert, normal (+3 more)

### Community 518 - "Bool"
Cohesion: 0.29
Nodes (5): AgentNotchPresentation, closed, open, peek, AgentNotchWindowActivator

### Community 519 - ".gestureRecognizer"
Cohesion: 0.36
Nodes (6): HistorySearchEvidence, .body, .terms, Bool, String, Text

### Community 520 - "WriteOutcome"
Cohesion: 0.20
Nodes (10): Agent Safety Net (Checkpoints, Verification, Write Guards), Claude Code Harness, Editor & LSP, How It Feels, Kouen Features, Mobile, Remote And Headless, Stack (+2 more)

### Community 521 - ".daemonIsStale"
Cohesion: 0.23
Nodes (5): KeyTokenParser, Bool, String, .remaining, KeyTokenParserTests

### Community 522 - ".viewDidLoad"
Cohesion: 0.20
Nodes (10): PaneRef, bottom, byID, byIndex, last, left, next, previous (+2 more)

### Community 523 - "fFe"
Cohesion: 0.13
Nodes (7): ControlKeyNormalizer, Bool, String, ShortcutRecorderSerializer, String, ControlKeyNormalizerTests, ShortcutRecorderSerializerTests

### Community 524 - "รายงานตรวจสอบการใช้หน่วยความจำสูงของ Kouen Terminal"
Cohesion: 0.21
Nodes (5): ImageTextureCache, MTLDevice, MTLTexture, Set, UInt8

### Community 525 - ".encodeAndWait"
Cohesion: 0.25
Nodes (4): ProjectStoreSyncTests, .tempPath, String, URL

### Community 526 - "Kind"
Cohesion: 0.47
Nodes (4): PathToken, PathTokenParser, Bool, String

### Community 527 - ".show"
Cohesion: 0.31
Nodes (5): AgyAdapter, Result, ResultLine, String, UUID

### Community 528 - "worktree_review_dashboard.robot"
Cohesion: 0.20
Nodes (7): HeadlessRunEvent, assistantText, result, sessionID, Bool, Double, String

### Community 529 - "WorktreeAutoIsolateService"
Cohesion: 0.22
Nodes (9): ImmersivePalette, Motion, Radius, Spacing, SUI, CGFloat, Double, NSColor (+1 more)

### Community 531 - "BrowserProgressLine"
Cohesion: 0.27
Nodes (3): DaemonReconnectPolicy, TimeInterval, DaemonReconnectPolicyTests

### Community 532 - "OpenClaw → Kouen"
Cohesion: 0.40
Nodes (9): attribute_lines(), main(), redraw_frames(), repeated_chunk(), run_case(), sgr_lines(), truecolor_gradient(), unicode_lines() (+1 more)

### Community 534 - "p12_mcp.robot"
Cohesion: 0.20
Nodes (3): AgentRoutingRuleIPCDaemonTests, String, URL

### Community 535 - "AgentNotification"
Cohesion: 0.20
Nodes (3): AutomationIPCDaemonTests, String, URL

### Community 536 - ".readGrid(scrollbackOffset:)"
Cohesion: 0.24
Nodes (3): String, URL, WorktreeMCPIPCDaemonTests

### Community 537 - "NSObject"
Cohesion: 0.22
Nodes (6): String, URL, ThemeCatalogEmbedTests, .embedSwift, .repoRoot, .sourceJSON

### Community 538 - "SessionGroupHeaderRowView"
Cohesion: 0.51
Nodes (9): fuzzyFindFiles(), handleErrors(), handleFind(), handleGrep(), handleMake(), handleRecent(), Int32, String (+1 more)

### Community 539 - "SavedLayoutIPCDaemonTests"
Cohesion: 0.29
Nodes (7): AppEnum, SplitDirectionAppEnum, horizontal, .ipcDirection, vertical, DisplayRepresentation, TypeDisplayRepresentation

### Community 542 - ".init(from:)"
Cohesion: 0.23
Nodes (3): ContentAreaViewController, String, Notification

### Community 543 - ".bufferLine"
Cohesion: 0.27
Nodes (4): Bool, String, TokenGuard, ContextResolutionEngineTests

### Community 544 - "CodingKeys"
Cohesion: 0.28
Nodes (5): Bundle, NSImage, WelcomeStepView, .body, .logo

### Community 545 - ".characterIndex"
Cohesion: 0.22
Nodes (9): Command prompt, Copy-mode key table, Customizing, Default `prefix` table, Global menu shortcuts, Key spec syntax, Kouen keybindings, Persistence (+1 more)

### Community 546 - "LegacySnapshot"
Cohesion: 0.36
Nodes (7): CLICommand, CLICommandCatalog, .allInvocationNames, .canonicalNames, .jsonCommands, Bool, String

### Community 547 - "NSObject"
Cohesion: 0.33
Nodes (5): AssistantMessageLine, CopilotAdapter, ResultLine, String, UUID

### Community 548 - ".encode"
Cohesion: 0.22
Nodes (7): KouenCLIPaths, .applicationSupport, .binDirectory, .installedCLIPath, .installedDaemonPath, .launchAgentURL, URL

### Community 549 - ".init(from:)"
Cohesion: 0.38
Nodes (4): requireActiveSurfaceID(), SurfaceID, IntentResult, ReturnsValue

### Community 551 - ".init(red:green:blue:alpha:)"
Cohesion: 0.22
Nodes (8): Build order (unchanged from interview decision), G1 — @ file-path picker, G2 — shell tab-completion suggestion strip (heuristic, explicitly best-effort), G3 — AI command suggestion (via `claude` CLI subprocess), Logical Design, P37 Phase G — Autocomplete (mobile bridge), Strategic Design, Tactical Design

### Community 552 - "PaneLabelDaemonTests"
Cohesion: 0.22
Nodes (8): Artifacts, Client Application — Slice 1 (stacked panes, no persistence), Client Application — Slice 2 (per-workspace divider memory), Context, Dev Task Progress — Workspace Sidebar Panels (P42), Integration, Note on task re-sequencing (2026-07-17), Summary

### Community 553 - "harness.resource"
Cohesion: 0.22
Nodes (9): Contributors, Documentation, Install, Key features, Kouen, License, Requirements, Update (+1 more)

### Community 554 - "eFe"
Cohesion: 0.44
Nodes (8): digest(), firstMatch(), flushBullet(), Section, stripMarkdown(), summarize(), String, swiftLiteral()

### Community 555 - "code:bash (harness view <file>                        # syntax-highligh)"
Cohesion: 0.33
Nodes (3): String, WorkspaceID, DaemonSyncServiceBranchNotifyTests

### Community 557 - ".viewWillMove"
Cohesion: 0.10
Nodes (10): KouenTerminalKit, OcclusionTests, NSWindow, String, TimeInterval, SpecialKeyMappingTests, Bool, NSEvent (+2 more)

### Community 559 - "ScrollbackPersistenceTests"
Cohesion: 0.22
Nodes (7): block, escFn, lineFilter, md, page, script, swift

### Community 560 - "AgentNotification"
Cohesion: 0.39
Nodes (4): SessionGroup, Any, String, Tab

### Community 561 - "CodexTranscriptTests"
Cohesion: 0.32
Nodes (4): SwarmDaemonBridge, Bool, String, UUID

### Community 562 - "BrowserResponsePayload"
Cohesion: 0.25
Nodes (4): Bool, NSEvent, NSEvent, NSEvent

### Community 563 - "AgentNotchViewModel.swift"
Cohesion: 0.32
Nodes (3): ReflowPreviewTests, .feeds, String

### Community 564 - "📁 IDE Sidebar"
Cohesion: 0.29
Nodes (3): ChromeRole, sidebar, tabBar

### Community 565 - ".hold"
Cohesion: 0.25
Nodes (7): Avoid, Colors, Components, Design Direction, Design System, Spacing / Radius / Motion, Typography

### Community 566 - "AutomationsFleetModelTests"
Cohesion: 0.25
Nodes (8): A `claude` typed by hand, Claude Code → Kouen, Customizing, One-line install, Session mode: Remote Control / cloud / local, The reverse direction: a session opened in Claude showing up in Kouen, Verifying, What gets written

### Community 567 - "Cross-terminal output-stress benchmark"
Cohesion: 0.32
Nodes (4): PaneID, SessionGroup, Tab, first

### Community 570 - "CommandHistorySearchController"
Cohesion: 0.40
Nodes (4): .webView(_:decidePolicyFor:decisionHandler:), MainActor, Sendable, WKNavigationAction

### Community 572 - "LayoutProbeView"
Cohesion: 0.40
Nodes (5): WrapperOptionBehavior, keepScanning, matchValue, skipValue, stopScanning

### Community 573 - "tHe"
Cohesion: 0.25
Nodes (7): Claude Code hook push (in-process Task subagent detection), Client UI indicator, Detection core (AgentDetector, pure logic), IPC / Tab plumbing, P38 Phase B — Subagent Visibility — Dev Task Progress, Status: Rewritten 2026-07-14 after original implementation (tasks 1-5) was lost to a concurrent git operation before commit. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 574 - "FileTreeKeyboardNavigator"
Cohesion: 0.25
Nodes (7): Original overlay build (built 2026-07-14, gated green, then deleted 2026-07-15 mid live-test), P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress, Pivot — merge into the Recipes picker (2026-07-15), Stage 1-2 — Engine/surface plumbing (built 2026-07-14, unchanged by the pivot, still in use), Status: Implementation pivoted mid-phase from a standalone overlay to a merge into the existing, Summary, Thread grouping — Zed framing folded into the same picker (2026-07-15)

### Community 575 - ".toastErrorSummary"
Cohesion: 0.25
Nodes (7): Core Features, Core Problems, Out of Scope, Product, Success Metrics, Target Users, Vision

### Community 576 - ".groupByRoot"
Cohesion: 0.25
Nodes (7): #kouen, #practice, #score, #shell, #total, #unix, #vim

### Community 577 - "concurrency.md"
Cohesion: 0.20
Nodes (9): AnyObject, CommandExecutionError, daemonError, .description, noActiveSurface, targetNotFound, unsupportedInThisContext, CommandExecutor (+1 more)

### Community 579 - "main.swift"
Cohesion: 0.25
Nodes (3): FlushSessionStateTests, String, URL

### Community 582 - ".groupByRoot"
Cohesion: 0.33
Nodes (5): AgentBridge, AgentTarget, Bool, String, SurfaceID

### Community 584 - "GUt"
Cohesion: 0.29
Nodes (7): TabContextCommand, close, closeOthers, rename, splitHorizontal, splitVertical, togglePersistent

### Community 585 - ".closeActivePane"
Cohesion: 0.29
Nodes (7): Bringing your `.tmux.conf` over, Deliberate divergences, From tmux, Import Terminal Colors And Fonts, Key-by-key translation, Make Kouen the default terminal, Migrating to Kouen

### Community 586 - ".parseWorktreePorcelain"
Cohesion: 0.29
Nodes (7): 1. Plain Terminal, 2. Persistent Terminal, 3. Full Terminal, 4. Agent Workspace, Experience modes, Opting into the prefix + status line without switching modes, Persistence (ephemeral vs. persistent)

### Community 587 - "sheet-cheat.html"
Cohesion: 0.29
Nodes (7): Adapted (same capability, Kouen-shaped), At parity, Deferred (tracked, unimplemented), Implemented (previously deferred, now shipped), Invariants this ledger protects, Rejected (with rationale), tmux parity — status, adaptations, and deliberate divergences

### Community 588 - "jHt"
Cohesion: 0.33
Nodes (6): Command, .targetKind, TargetKind, pane, session, window

### Community 590 - "lrn"
Cohesion: 0.60
Nodes (3): BlockSummary, Date, String

### Community 591 - "main.swift"
Cohesion: 0.43
Nodes (4): AgentRoutingRuleSummary, Bool, String, UUID

### Community 592 - "commit-push.sh"
Cohesion: 0.38
Nodes (3): Bool, String, WorktreeInfoSummary

### Community 593 - "dO"
Cohesion: 0.38
Nodes (5): Result, ShellRCWiring, Bool, String, URL

### Community 595 - "full-cycle.sh"
Cohesion: 0.43
Nodes (3): MarkdownBundle, String, URL

### Community 596 - ".userContentController"
Cohesion: 0.29
Nodes (6): Locked decisions (user-confirmed), Logical Design, P38 Phase A — Cross-Agent Worktree Diff/Review Dashboard — Design, Strategic Design, Tactical Design, Verification gate (this phase)

### Community 597 - "mBt"
Cohesion: 0.29
Nodes (6): Logical Design, Next Step, P42 — Workspace Sidebar Panels, Parked (not in scope), Strategic Design, Tactical Design

### Community 598 - ".encode"
Cohesion: 0.33
Nodes (6): emitArray(), hex(), referenceWidth(), String, T, UInt8

### Community 599 - ".terminalHostIfExists"
Cohesion: 0.29
Nodes (6): Any, Error, MainActor, Sendable, String, Void

### Community 601 - "Hwe"
Cohesion: 0.20
Nodes (6): LayoutTemplate, evenHorizontal, evenVertical, mainHorizontal, mainVertical, tiled

### Community 602 - "Build locally"
Cohesion: 0.20
Nodes (10): BrowserResponsePayload, cookies, error, network, ok, open, screenshot, snapshot (+2 more)

### Community 603 - "fut"
Cohesion: 0.29
Nodes (6): Accessibility Identifiers Required, Architecture, Kouen Robot Framework Tests, Prerequisites, Run, Troubleshooting

### Community 605 - "gmn"
Cohesion: 0.67
Nodes (3): WriteOrigin, automation, human

### Community 606 - "Quick start"
Cohesion: 0.47
Nodes (4): AgentBadgeView, .body, Bool, CGFloat

### Community 612 - "DecoKind"
Cohesion: 0.33
Nodes (6): DecoKind, curly, dashed, dotted, double, solid

### Community 613 - "shim.c"
Cohesion: 0.47
Nodes (5): AgentIconArt, AgentVectorIcon, Bool, CGSize, String

### Community 614 - "MainSplitViewController"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase D — Kitty Graphics Conformance Slice, Scope (locked), Tests

### Community 615 - "fences"
Cohesion: 0.33
Nodes (5): Gate, Implementation, P38 Phase E — Scripting Hook Parity (JS vs WezTerm's Lua), Scope (locked), Tests

### Community 616 - "bump-version.sh"
Cohesion: 0.33
Nodes (5): Logical Design, Next Step, P43 — Add Repo/Folder to Workspace, Strategic Design, Tactical Design

### Community 617 - "ScriptFileWatcher"
Cohesion: 0.33
Nodes (5): Build, Release & Git Workflow, Build / Test / Run, Graphify before every delivery commit, Release packaging order, Worktree constraint

### Community 618 - "parse"
Cohesion: 0.53
Nodes (4): display_menu(), run(), prepare-release.sh script, usage()

### Community 619 - "_0n"
Cohesion: 0.60
Nodes (5): main(), printHelp(), runCommand(), selectWithArrows(), selectWithReadline()

### Community 621 - "ViEngine"
Cohesion: 0.40
Nodes (3): String, URL, WorktreeSignatureTests

### Community 624 - "gmn"
Cohesion: 0.47
Nodes (3): URL, TimeoutError, WorktreeLargeOutputRegressionTests

### Community 627 - "ActiveTabCloseDisposition"
Cohesion: 0.60
Nodes (3): ProjectTask, ProjectTaskDetector, String

### Community 632 - "Cursor Agent → Kouen"
Cohesion: 0.40
Nodes (4): Cursor Agent → Kouen, Manual fallback, One-line install, What you'll see

### Community 633 - "g_n"
Cohesion: 0.40
Nodes (4): Findings, Sources, What this means for Kouen, Who creates branches / worktrees in AI coding tools

### Community 634 - "Q: animateSidebar setContentLeadingInset MainSplitViewController"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: animateSidebar setContentLeadingInset MainSplitViewController, Source Nodes

### Community 635 - "E9"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: ProjectCategory FolderScanner ProjectDirectoryTree, Source Nodes

### Community 636 - ".handleCopyModeKey"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: BrowserPaneView createTab openBrowserPane navigation WebKit, Source Nodes

### Community 637 - "TerminalScrollbarView"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: KouenPreviewHome environment key daemon launch at startup, Source Nodes

### Community 638 - "FormatStringExtendedVariableTests"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: session history search ranking branch best matches, Source Nodes

### Community 639 - "gpn"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Kouen terminal product features agent workspace browser daemon session persistence remote control, Source Nodes

### Community 640 - "zpt"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: session persistence focus routing browser disposal memory bounded checkpoint undo verify worktree, Source Nodes

### Community 641 - "[3.10.0] - 2026-06-27"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: How should CheckpointManager.restore preserve the user staged index?, Source Nodes

### Community 642 - "qut"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Where are the Wave 1 deadlock, HTTP transport and markdown preview paths?, Source Nodes

### Community 646 - "gmn"
Cohesion: 0.24
Nodes (4): GraphifyLSPBridgeTests, Any, String, URL

### Community 649 - "TreeSitterGrammarBundle"
Cohesion: 0.50
Nodes (3): String, URL, TreeSitterGrammarBundle

### Community 650 - "hjt"
Cohesion: 0.50
Nodes (3): LiveResizeGeometry, Result, Bool

### Community 651 - "u0n"
Cohesion: 0.40
Nodes (4): Cross-terminal output-stress benchmark, Run, The faithful scoreboard, What it measures — and what it does NOT

### Community 652 - "TerminalHostView"
Cohesion: 0.70
Nodes (4): restart_daemon(), rollback_version_bump(), full-cycle.sh script, usage()

### Community 653 - "iOn"
Cohesion: 0.70
Nodes (4): kill_stale(), kill_stale_prod(), run.sh script, usage()

### Community 654 - "BlockContextMenuTests"
Cohesion: 0.40
Nodes (4): #connect, #log, #term, tokenFromQR

### Community 660 - "qAn"
Cohesion: 0.50
Nodes (3): Kouen Terminal — Domain Language, Language, Relationships

### Community 661 - ".compute"
Cohesion: 0.50
Nodes (3): Caveats, Keep awake with the lid closed, Setup

### Community 662 - "I$e"
Cohesion: 0.50
Nodes (4): Full local signing path (needs a Developer ID cert; not currently used), How this fork actually releases, Release runbook, Scripted flow

### Community 663 - "m6e"
Cohesion: 0.50
Nodes (3): Agent platform icons, Lobe Icons — MIT License, Third-party notices

### Community 664 - "P37 Phase G — Autocomplete (mobile bridge)"
Cohesion: 0.50
Nodes (3): exclude_hubs, no_viz, wiki

### Community 665 - "nb"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: SSETransport auth token isRunning

### Community 666 - "BrowserIntegrationController"
Cohesion: 0.50
Nodes (3): Answer, Outcome, Q: What commands build and test Kouen and prepare Graphify before commit?

### Community 669 - "PaneLabelDaemonTests"
Cohesion: 0.50
Nodes (4): dO(), m8(), rfn(), zfn()

### Community 670 - "pie"
Cohesion: 0.67
Nodes (4): FVe(), hJ(), qVe(), Zme()

### Community 671 - "AntigravityTranscriptTurnsTests"
Cohesion: 0.50
Nodes (4): q2n(), rH(), ttt(), z2n()

### Community 672 - "ColorKind"
Cohesion: 0.50
Nodes (3): P38 Phase D — Kitty Conformance — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped., Summary

### Community 673 - "qte"
Cohesion: 0.50
Nodes (3): P38 Phase E — Scripting Hooks — Dev Task Progress, Status: Implementation complete, build/test/robot green. Closed 2026-07-16 on user instruction, live check skipped (was already lowest priority of B/C/D/E)., Summary

### Community 674 - "t2e"
Cohesion: 0.50
Nodes (3): Generated files (regenerate, never hand-edit), IPC framing, IPC Protocol & Generated Files

### Community 675 - ".detect"
Cohesion: 0.83
Nodes (3): entries(), cheat.sh script, usage()

### Community 676 - "vne"
Cohesion: 0.67
Nodes (3): commit_with_graph(), prepare_graph_for_commit(), graphify-commit.sh script

### Community 683 - ".init(coder:)"
Cohesion: 0.67
Nodes (3): bVe(), nJt(), pVe()

### Community 684 - "CommandParseError"
Cohesion: 0.67
Nodes (3): cat(), Hwe(), kYe()

### Community 685 - "[1.5.1] - 2026-06-06"
Cohesion: 0.67
Nodes (3): cfn(), fut(), qYe()

### Community 686 - "k0t"
Cohesion: 0.67
Nodes (3): dht(), k0t(), l1n()

### Community 689 - ".availableAgentKinds"
Cohesion: 0.67
Nodes (3): iRe(), jNt(), zNt()

### Community 2688 - "ToolPolicy"
Cohesion: 0.36
Nodes (7): Document, Bool, Set, String, URL, ToolPolicy, .defaultURL

### Community 2693 - "Q: TerminalEmulator kittyPending VTParser oscBuffer TerminalMetalRenderer drawImages"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: TerminalEmulator kittyPending VTParser oscBuffer TerminalMetalRenderer drawImages, Source Nodes

### Community 2694 - "Modifiers"
Cohesion: 0.25
Nodes (6): OptionSet, .description, .init(key:modifiers:), Modifiers, String, UInt8

### Community 2695 - "ResizeDirection"
Cohesion: 0.40
Nodes (5): ResizeDirection, down, left, right, up

### Community 2696 - "Motion"
Cohesion: 0.40
Nodes (5): Motion, .reduce, .spring, Animation, Bool

## Knowledge Gaps
- **2394 isolated node(s):** `AppIntents`, `noActivePane`, `.localizedStringResource`, `horizontal`, `vertical` (+2389 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1142 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.
- **15 possibly unreachable function(s):** `.addSurface(tabID:paneID:)`, `.agentInfo(forWorktreePath:tabs:)`, `.block(atPromptLine:)`, `.block(atPromptLine:)`, `.blocks` (+10 more)
  Not reached from any recognized entry point - could be dead code, or dynamically dispatched/decorator-registered.

## Work-memory lessons

**Known dead ends** — questions that led nowhere; don't re-derive.
- "KouenPreviewHome environment key daemon launch at startup" -> `KouenPaths`

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Int` connect `install-linux.sh` to `RD`, `EngineConformanceTests`, `IPCRequest`, `AgentNotchRootView`, `.gestureRecognizer`, `LSPMessage`, `.daemonIsStale`, `.viewDidLoad`, `PerformanceBenchmarks`, `Changed`, `TerminalEmulator`, `Kind`, `VTParser`, `.applyPreedit`, `MetalRendererTests`, `GitPanelView.swift`, `BrowserProgressLine`, `รายงานตรวจสอบการใช้หน่วยความจำสูงของ Kouen Terminal`, `HarnessTerminalSurfaceView`, `CopyModeAction`, `SplitPaneCoordinator`, `.request`, `WorktreeManager`, `SpecialKey`, `RGBColor`, `.parse`, `Added`, `Notification`, `.init(from:)`, `.bufferLine`, `Equatable`, `DaemonClient`, `MenuTarget`, `code:bash (harness chat "Use the project map first, then inspect this r)`, `String`, `NSObject`, `TerminalColorGamut`, `HarnessSettings`, `CodingKeys`, `HarnessSidebarPanelViewController.swift`, `RenderSchedulerTests`, `terminal_stress_runner.py`, `HarnessTerminalSurfaceView.swift`, `.normalizedKey`, `HookEvent`, `DaemonServer`, `Added`, `AgentNotchViewModel.swift`, `Fixed`, `Added`, `HarnessSplitView`, `Cross-terminal output-stress benchmark`, `TabCell`, `ViEngine`, `FrecencyDirectoryStore`, `ComposedCell`, `HarnessCLI+Server.swift`, `.text`, `ShellIntegration`, `String`, `Completed Plans Archive`, `.compose`, `README.md`, `[2.6.0] - 2026-06-13`, `OptionStore`, `TerminalProtocolCompatibilityTests`, `lrn`, `main.swift`, `int`, `.firstMatch`, `LSPClient`, `string`, `TerminalGridCell`, `HarnessPaths`, `.encode`, `Harness as a terminal multiplexer`, `TerminalModes`, `code:bash (# Terminal 1: Create workspace with long-running job)`, `AttachInputBatcher`, `shim.c`, `Harness Usage`, `PaneContainerView`, `4. Technical Architecture`, `.dispatch`, `DaemonLauncher`, `AnyCodable`, `Recipe`, `Changelog`, `domain-design.md`, `AgentNotchViewModel`, `.resolve`, `SoftIconButton`, `code:text (:workbench start swift)`, `.makeSnapshot`, `gmn`, `.encode`, `SessionGroup`, `Harness command reference`, `Added`, `ViEngine`, `Pipe`, `String`, `HistoryRingBuffer`, `.path`, `GlyphAtlas`, `code:block1 (SessionCoordinator.snapshot ──┐)`, `ToolPolicy`, `Harness tmux-style capabilities`, `.diffLines`, `AgentHookInstaller`, `code:js (// ~/.config/harness/init.js)`, `.delay`, `hjt`, `แผนงานการสร้างระบบพรีวิวและแสดงผลไฟล์ (File Viewer & Preview Integration Plan)`, `SyntaxDefinitionTarget`, `How to use Harness from the terminal only (no GUI)`, `k0n`, `DecodedImage`, `TriState`, `SessionGroupHeaderRowView`, `.evaluate`, `Added`, `LiveResizeTests`, `Int`, `ThaiCombiningMarkTests`, `Added`, `Any`, `nje`, `AmbientBackground`, `What You Must Do When Invoked`, `TerminalFindBar`, `LiveSession`, `TriState`, `Added`, `Fixed`, `.decodeKeySpec`, `BoardCard`, `BinaryRefresherTests`, `codex`, `RGBColorTests`, `InlineAICompletionView`, `smoke-dmg.sh`, `GridCompositorTests`, `targets`, `SessionSnapshot`, `AppDelegate`, `BrowserPaneView`, `P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client`, `ScriptRuntime`, `GlyphRasterizer`, `BinaryInstaller`, `Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag`, `ResizeHUDView`, `die`, `Harness keybindings`, `CopyModeState`, `scheduleRender`, `.testDataFrameEncodeVsJSONBase64Output`, `PaneDropZoneOverlay`, `.translate`, `String`, `CellColorResolverTests`, `GridCompositor`, `Prompt`, `Section`, `AgentNotchRowSummary`, `ANSIPalette`, `SSHTunnelManagerTests`, `sessionRow`, `.decide`, `HarnessGridTerminalTests`, `P10 Task: Lazy Scrollback Reflow`, `Added`, `TerminalBlockStoreTests`, `TerminalMetalRenderer`, `Added`, `AgentBridge`, `remote-ssh.md`, `Experience modes`, `.renderFixture`, `ColorKind`, `SessionCoordinator`, `.effectivePrefixKey`, `Split Right`, `release-hotfix.sh`, `f4`, `HarnessSidebarPanelViewController`, `code:bash (# Old (agent-specific):)`, `StatusLineView.swift`, `SGRMouseEvent`, `[2.5.0] - 2026-06-12`, `P8: macOS 27 Golden Gate Adoption`, `BlockTintOverlay`, `.menu`, `RemoteHostStoreTests`, `FormatColor`, `JSONDecoder`, `Fixes Applied (layered)`, `settings.json`, `PaneNode`, `HarnessPaths.swift`, `.parse`, `.encodeMouse`, `RegressionBugFixTests`, `ViPathTokenTests`, `Browser DevTools API (P28)`, `inlineText`, `Terminal AI Chat (⌘I inline overlay)`, `paragraph`, `code:bash (harness-cli install-hooks opencode)`, `Memory — harness-terminal`, `setOptions`, `.init`, `LayoutNode`, `.testingRenderSynchronized`, `FloatingPaneController`, `.theme`, `README.md`, `ImmersivePalette.swift`, `.recordReapedGenerationForTesting`, `Added`, `RealPty`, `ImageProtocolTests.swift`, `run.sh`, `code:bash (harness-cli install-hooks pi)`, `[2.2.3] - 2026-06-09`, `FileViewerViewController`, `DaemonLifecycleTests`, `Contents.json`, `Background Polling & Snapshot Fanout — P22`, `Architecture Decisions — harness-terminal`, `OcclusionTests`, `FormatStyledSegment.swift`, `RGBColor`, `[2.2.4] - 2026-06-11`, `DaemonStats`, `Git Panel`, `P17 — Structural Refactor`, `Identifiable`, `SurfaceProgressTrackerTests.swift`, `MCPServer`, `PromptQueue`, `smoke-dmg.sh`, `ThaiClusterRenderTests`, `P2 — Async IPC Refactor`, `INDEX.md`, `SKILL-LOG.md`, `User Profile`, `build-release.sh`, `create-dmg.sh`, `generate-app-icon.sh`, `package-app.sh`, `RealPtyLifecycleTests`, `FilePreviewCoordinatorTabScopeTests`, `SixelDecoder`, `Competitive Position (as of v3.12.0, 2026-07-02)`, `BoardCardView`, `.init`, `LegacySnapshot`, `RemoteHostStore`, `mobile_bridge_pairing_bugs.robot`, `.normalizedKey`, `.encode`, `.deinit`, `MouseButton`, `.moveSelection`, `DispatchTime`, `StatusDotView`, `ScrollbackTests`, `CopilotAdapter`, `ccRunGet`, `.update`, `Kouen Features`, `.parseGitDiffOutput`?**
  _High betweenness centrality (0.281) - this node is a cross-community bridge._
- **Why does `AgentSessionSummary` connect `ComposedCell` to `String`, `Fixes Applied (layered)`, `Session Grouping and Split Session Plan`, `Architecture Decisions — harness-terminal`, `terminal_stress_runner.py`, `AnyCodable`, `From tmux`, `CopyModeState`, `00-inception-plan.md`, `install-linux.sh`, `MetalRendererTests`, `DispatchSourceWrite`, `Int`, `Section`, `Split Right`, `NSOutlineViewDataSource`, `NSOutlineViewDelegate`?**
  _High betweenness centrality (0.191) - this node is a cross-community bridge._
- **Why does `fbt()` connect `callingPaneTarget` to `CodingKey`, `00-inception-plan.md`?**
  _High betweenness centrality (0.101) - this node is a cross-community bridge._
- **Are the 19 inferred relationships involving `KouenTerminalSurfaceView` (e.g. with `InputEncoder` and `OutputTriggerMatcher`) actually correct?**
  _`KouenTerminalSurfaceView` has 19 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppIntents`, `noActivePane`, `.localizedStringResource` to the rest of the system?**
  _2414 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CodingKey` be split into smaller, more focused modules?**
  _Cohesion score 0.0052488473814871735 - nodes in this community are weakly interconnected._
- **Should `callingPaneTarget` be split into smaller, more focused modules?**
  _Cohesion score 0.012725408238532441 - nodes in this community are weakly interconnected._