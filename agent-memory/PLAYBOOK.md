# Playbook — Problem Resolution Cases

<!-- Search by domain or trigger keywords. Sequential IDs. -->
<!-- Archive rule: zero Applied+Prevented after 30 days → completed-archive.md -->
<!-- Promote rule: Applied 2+ → agent-memory/knowledge/*.md -->

## AppKit / UI

| ID | Trigger | Fix | Outcome | Applied |
|----|---------|-----|---------|---------|
| CASE-001 | NSButton checkbox not receiving clicks inside NSScrollView | Remove FlippedView scroll-wrapper; use FlippedStackView as documentView | RESOLVED | 1 |
| CASE-002 | NSSplitView subviews collapse to 0 / custom ratios lost | `autoresizingMask = [.width, .height]`; store ratio, setPosition on first non-zero layout | RESOLVED | 1 |
| CASE-005 | NSButton .recessed bezelStyle shows white in dark theme | Use .inline + isBordered=false + manual layer?.backgroundColor | RESOLVED | 1 |
| CASE-006 | NSSplitView.setPosition in layout() infinite recursion (N>2) | `isApplyingPositions` bool guard | RESOLVED | 1 |
| CASE-007 | NSSplitView subview reorder causes window collapse/black | Only remove the moved view; reinsert with addSubview(_:positioned:relativeTo:) | RESOLVED | 1 |
| CASE-008 | NSApp.keyWindow nil in menu action (AppleScript) | `keyWindow ?? mainWindow ?? windows.first(where:)` fallback chain | RESOLVED | 1 |
| CASE-010 | NSFont has no `.italicSystemFont` | `NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)` | RESOLVED | 1 |
| CASE-014 | NSSplitView.setPosition fails when bounds.width==0 | DispatchQueue.main.async retry, or use constraint multiplier | RESOLVED | 1 |
| CASE-018 | File preview drag-to-select broken | Forward mouseDown/mouseDragged/mouseUp to textView directly | RESOLVED | 1 |
| CASE-024 | Sidebar disappears after collapse+expand on launch | Set `settings.sidebarVisible=false` when forcing collapse | RESOLVED | 1 |
| CASE-027 | Translucent window unreadable on bright background | `themeColor.withAlphaComponent(max(opacity, 0.15))` floor + drop shadow | RESOLVED | 1 |
| CASE-029 | Sidebar chevron disappears on rotation/hide | Symbol state (`chevron.right`/`.down`) instead of frameCenterRotation | RESOLVED | 1 |
| CASE-030 | Multiple sessions hidden; sidebar doesn't sync selection | Remove allSameBranch; call selectActiveSessionRow in refreshMetadata | RESOLVED | 1 |
| CASE-035 | NSAlert Enter fires Close (destructive) even with Cancel focused | Clear `buttons[0].keyEquivalent = ""`; Space activates focused | RESOLVED | 1 |
| CASE-036 | Command Prompt (⌘;) can't receive keyboard input | Borderless NSPanel `canBecomeKey=false` default — use KeyablePanel subclass | RESOLVED | 1 |
| CASE-037 | SyntaxTextView mouseUp stack overflow (71K frames) | Remove mouseUp/mouseDragged forwarding — NSTextView handles internally | RESOLVED | 1 |
| CASE-038 | NSClickGestureRecognizer intercepts NSButton clicks | Check click location in handler; use mouseUp override if needed | OPEN | 0 |
| CASE-039 | NSTrackingArea on superview crashes on pane rebuild | Remove in viewDidMoveToSuperview(nil); use .inVisibleRect + rect:.zero | RESOLVED | 1 |

## AppKit / Metal / Display Link

| ID | Trigger | Fix | Outcome | Applied |
|----|---------|-----|---------|---------|
| CASE-003 | Terminal goes black after pane rebuild (remove+re-add) | stop+start display link in `viewDidMoveToSuperview()` if window!=nil | RESOLVED | 4 |
| CASE-004 | Overlay NSView above Metal surface not visible | zPosition=1000 on overlay layer (full-frame blocks Metal) | WORKAROUND | 1 |
| CASE-012 | File preview causes 1-2s black screen (Metal dies on reparent) | Constraint-based sibling panel, never reparent terminal views | RESOLVED | 1 |
| CASE-025 | Terminal flickers on file preview open/close | `presentsWithTransaction = true` during programmatic resize | RESOLVED | 1 |
| CASE-026 | New session occasionally shows black (no prompt) | Always stop+start display link in viewDidMoveToWindow | RESOLVED | 1 |
| CASE-028 | Metal surfaces accumulate (async sync skips prune) | Add `terminalHosts.prune(keeping:)` to async syncFromDaemon variant | RESOLVED | 1 |
| CASE-031 | Crash: CADisplayLink fires on deallocated surface | `deinit { renderLink?.invalidate() }` — macOS doesn't retain target | RESOLVED | 1 |

## Swift 6 / Concurrency / RL-040

| ID | Trigger | Fix | Outcome | Applied |
|----|---------|-----|---------|---------|
| CASE-013 | MainActor.assumeIsolated inside DispatchQueue.main.async | `Task { @MainActor in }` or `.main` queue directly | RESOLVED | 3 |
| CASE-032 | SwiftUI crash (swift_getObjectType) on session switch | `@Observable` class + `@Bindable var` — never replace rootView struct mid-layout | RESOLVED | 1 |
| CASE-040 | RL-040 zombie crashes: layout/resetCursorRects/mouseMoved/sendEvent | Multi-pronged: stopDisplayLink in viewWillMove, retiredBars[] hold on TabBar, retiredWindows[] on Window.close(), nonisolated(unsafe) in PrefixKeymap. **`nonisolated` does NOT suppress @objc thunk executor check on Swift 6.3.2.** | RESOLVED | 6 |

## Git / File System

| ID | Trigger | Fix | Outcome | Applied |
|----|---------|-----|---------|---------|
| CASE-009 | Git panel not updating in real-time | DispatchSource on `.git` dir + 500ms debounce | RESOLVED | 1 |
| CASE-015 | File tree 3s polling wastes CPU | FSEvents watcher + reconcile in-place (preserve expand state) | RESOLVED | 1 |
| CASE-016 | Nested file add/delete not detected | FSEventStreamCreate on rootPath (recursive); Unmanaged for @convention(c) | RESOLVED | 1 |
| CASE-020 | Branch chip stale after git checkout | Run git rev-parse at end of loadRoot() | RESOLVED | 1 |
| CASE-021 | Git Changes panel not real-time | FSEventStreamCreate on rootPath (same WatcherContext pattern) | RESOLVED | 1 |
| CASE-022 | File preview doesn't update on disk change | FileChangeWatcher (single-file DispatchSource, 0.3s debounce) | RESOLVED | 1 |

## Terminal / Renderer / Daemon

| ID | Trigger | Fix | Outcome | Applied |
|----|---------|-----|---------|---------|
| CASE-011 | AnyCodable no subscript for nested access | Pattern-match: `if case let .object(inner) = dict["key"]` | RESOLVED | 1 |
| CASE-017 | Folder expand state resets on refresh | Move isExpanded to @Observable FileTreeNode (survives reconcile) | RESOLVED | 1 |
| CASE-019 | Terminal selection highlight invisible | Pass selectionBackground from theme in FrameBuilder.init | RESOLVED | 1 |
| CASE-023 | Garbled TUI (interleaved status fragments) | Don't clear synchronizedOutput in resetForShellPrompt; use 150ms timeout | RESOLVED | 1 |
| CASE-033 | Tool-injected names appear as OSC 2 title | Strip suffix in daemon updateTabTitle; change pane-border-format default | RESOLVED | 1 |

## Architecture / Keybindings

| ID | Trigger | Fix | Outcome | Applied |
|----|---------|-----|---------|---------|
| CASE-034 | Keybinding in banner doesn't match menu binding | Centralize in `BannerShortcutRegistry.Keybinding` struct — single source of truth | RESOLVED | 1 |

## Remote SSH (P23)

| ID | Trigger | Fix | Outcome | Applied |
|----|---------|-----|---------|---------|
| CASE-041 | hitTest() on WindowTitleStripView swallows remoteBadge clicks | Check subviews for NSButton hits before returning self | RESOLVED | 1 |
| CASE-042 | saveRemoteHostClicked rename silently overwrites existing host | Add duplicate-name check; reconnect if renaming active host | RESOLVED | 1 |
| CASE-043 | connectRemoteHostClicked persists form values over saved config | Only addHost for brand-new (unsaved) hosts; existing hosts use stored config | RESOLVED | 1 |
| CASE-044 | sshArgValue(after:) fails for glued arg form (-p2222) | Use hasPrefix matching + dropFirst as fallback after exact-token match | RESOLVED | 1 |
| CASE-045 | Connect button disabled for unsaved new hosts | Enable when form is filled (name+target+socket) even without selection | RESOLVED | 1 |
| CASE-046 | Settings VC never observes connection state changes | Add activeHostDidChange + connectionDidFail observers (stored tokens) | RESOLVED | 1 |
| CASE-047 | Observer leak in buildRemotePage (block observer accumulates) | Store token in array; remove all old tokens before adding new ones | RESOLVED | 1 |
| CASE-048 | Socket path placeholder suggests tilde (SSH doesn't expand ~) | Show absolute path: `/home/user/.config/harness/harness.sock` | RESOLVED | 1 |
| CASE-049 | Concurrent connectToRemote calls → orphaned SSH processes | `isConnectingRemote` flag guards against concurrent spawns | RESOLVED | 1 |
| CASE-050 | removeHost of active host leaves GUI on dead socket | Call `applyEndpointSwitch(.localControlSocket)` when active host removed | RESOLVED | 1 |
| CASE-051 | Connect failure leaves status stuck on "Connecting…" | Post `connectionDidFail` notification with error; Settings shows ⚠️ msg | RESOLVED | 1 |
| CASE-052 | disconnect() posts notification even when already nil | Guard: `guard let name else { return }` | RESOLVED | 1 |
| CASE-053 | buildRemotePage width constraints accumulate on every visit | Guard: `if remoteNameField.constraints.isEmpty` before activating | RESOLVED | 1 |
| CASE-054 | Hardcoded page index 6 for Remote settings | `SettingsWindowController.pageRemote` named constant | RESOLVED | 1 |
| CASE-055 | RL-040 zombie crash still recurring despite retire-hold in TerminalPaneRegistry | Override `removeFromSuperview()` on HarnessTerminalSurfaceView itself — catches ALL removal paths (AppKit, SwiftUI, NSSplitView, our code) at single chokepoint. Also install NSEvent local monitor in AppDelegate. | RESOLVED | 1 |

## Command Prompt / Parser

| ID | Trigger | Fix | Outcome | Applied |
|----|---------|-----|---------|---------|
| CASE-042 | :z/:view/:edit/:agent etc throw unknownCommand | Add verb to CommandParser.buildCommand + knownVerbs (see knowledge/architecture/command-prompt.md) | RESOLVED | 1 |
