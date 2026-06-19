# Browser Pane (P14)

## Architecture

- `PaneNode.browser(BrowserLeaf)` — app-side-only leaf, no daemon IPC, no PTY,
  no scrollback. `BrowserLeaf { id: PaneID, url: URL }`.
- `BrowserPaneView` (`Apps/Harness/Sources/HarnessApp/UI/Chrome/BrowserPaneView.swift`)
  — `NSView` with a toolbar (back/forward/reload-stop/URL field/close) over a
  `WKWebView`. Registered in `BrowserPaneRegistry.shared` by `paneID` so MCP/UI
  code can look it up.
- `SplitPaneCoordinator.openBrowserPane(url:direction:paneID:)` inserts a
  `.browser` leaf via `insertBrowserLeaf`, splitting the active pane.
- `SplitPaneCoordinator.closeBrowserPane(paneID:)` removes the leaf via
  `removePaneNode` and calls `coord.daemonSyncService.applyLocalSnapshot(updated)`.
- Last-visited URL persists in `UserDefaults` under
  `"browserPane.\(paneID.uuidString).url"`, restored on `BrowserPaneView.init`.

## CASE: applyLocalSnapshot re-injected closed browser panes (v2.7.1)

`DaemonSyncService.applySnapshot` has a merge step that re-injects `.browser`
leaves from the *previous* snapshot into the *incoming* snapshot — this exists
because the daemon's snapshot has no concept of `.browser` leaves (they're
app-side only) and would otherwise drop them on every daemon sync.

That re-injection ran for `applyLocalSnapshot` too. So when `closeBrowserPane`
produced an updated snapshot with the leaf removed and called
`applyLocalSnapshot`, the merge step found the leaf in the *previous* snapshot
and put it right back — the close silently no-opped.

**Fix:** `applySnapshot` takes `preserveBrowserPanes: Bool = true`; the
re-injection loop is gated on it. `applyLocalSnapshot` passes `false` — a local
snapshot already reflects the desired pane tree by construction, so no
re-injection is needed (or correct).

**Lesson:** when a "preserve X across syncs" merge step exists for one call
path (remote daemon snapshots), check whether it's also applied to local/optimistic
snapshot paths — those already contain the desired state and re-merging old
state can silently undo local mutations.

## CASE: collapsed errorBanner intercepted toolbar clicks (v2.7.1)

`errorBanner`'s height constraint was set to 0 when collapsed, but the view
itself stayed visible (`isHidden` not set). Its `errorDismissButton` subview
(pinned to `errorBanner`'s trailing/centerY) still occupied a 16x16 hit-testable
area overlapping the toolbar's trailing edge — eating clicks meant for
`closePaneButton`/`reloadStopButton`.

**Fix:** toggle `errorBanner.isHidden` together with the height constraint —
`true`/`0` in `dismissErrorBanner()` and initial `setupConstraints()`,
`false`/`24` in `showErrorBanner(message:)`. `NSStackView` treats hidden views
as zero-size, and hidden views don't participate in hit-testing.

## Open Browser Pane shortcut (⌘B)

`MainMenuBuilder` Window menu "Open Browser Pane" item: `keyEquivalent: "b"`,
`keyEquivalentModifierMask = [.command]`, action `MenuTarget.openBrowserPane`.
Mirrored in `PaneSplitButtonsView` (`ContentAreaViewController.swift`) as a
"safari"-icon button next to Split Right/Split Down, both calling
`SessionCoordinator.shared.splitPaneCoordinator.openBrowserPane(url:
URL(string: "about:blank")!, direction: .horizontal)`.

## Click-to-open localhost/LAN dev-server links

`URLDetection` (`Packages/HarnessTerminalEngine`) gained two pieces:

- `detectLocalhost(in:at:)` — fallback link detector (after OSC 8 hyperlinks
  and `detectFilePath`) for bare `host:port[/path]` tokens, with or without an
  `http(s)://` prefix. Normalizes `0.0.0.0` → `localhost`. Handles bracketed
  IPv6 (`[::1]:3000`, `[fe80::1]:8080`) by extracting the host between `[` `]`
  before splitting on `:` for the port (a bare IPv6 host:port split on `:`
  would break on the address's own colons).
- `isLocalDevHost(_:)` — shared predicate: `localhost`, `127.0.0.1`, `0.0.0.0`,
  `::1`, private IPv4 (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`), and
  private IPv6 (`fe80::/10` link-local, `fc00::/7` unique-local). Covers the
  `Network: http://192.168.x.x:5173`-style address dev servers print alongside
  `localhost`.

`HarnessTerminalSurfaceView+SelectionAndLinks.swift`'s `linkRange` appends
`detectLocalhost` as a third fallback; `openLink` checks `isLocalDevHost` on
`http`/`https` URLs and, if true, posts `Notification.Name("HarnessOpenLocalhostURL")`
with `userInfo: ["url": url]` instead of `NSWorkspace.shared.open(url)`.
`MainSplitViewController` observes this notification (mirroring the existing
`HarnessOpenFilePreview` pattern) and calls
`SessionCoordinator.shared.splitPaneCoordinator.openBrowserPane(url:direction:)`.

## Multi-Tab Support (P24 Phase 3)

`BrowserPaneView` now supports multiple tabs within a single browser pane:

- **Tab model:** `BrowserTab` struct (id, webView, title) stored in `tabs: [BrowserTab]`
- **Tab bar:** `NSScrollView` + `NSStackView` of `BrowserTabButton` views above toolbar. Always visible.
- **New tab:** `+` button in tab bar or via `createTab(url:configuration:)` API
- **target=_blank:** `WKUIDelegate.createWebView` → `createTab(url:)` instead of loading in same view
- **Close tab:** `×` on each tab. Last tab close → close entire browser pane
- **Tab switch:** `selectTab(at:)` swaps `WKWebView` in `mainStack` (NSStackView)
- **Tab title:** Set from page `document.title` via `webView.title` on `didFinish`, truncated to 20 chars
- **Cookie/session:** Uses `WKWebsiteDataStore.default()` (persistent) — login state preserved across tabs and app restarts

### Layout (top to bottom in mainStack)

1. `tabBar` (28pt) — always visible
2. `toolbar` (32pt) — back/forward/reload/URL/close
3. `errorBanner` (0 or 24pt)
4. `webView` (fills remaining space)

## GitHub URL Click-to-Browser-Pane (P24)

`openLink` in `HarnessTerminalSurfaceView+SelectionAndLinks.swift` now intercepts
⌘-click on GitHub URLs (`host.contains("github.com")`) and posts
`HarnessOpenLocalhostURL` notification → opens in browser pane instead of external Safari.

Combined with PR badge click (`onPRClick` in `SidebarSessionRows.swift`) →
`splitPaneCoordinator.openBrowserPane(url:)`, users can view PRs inline.

## BUG: Tab close button unresponsive (gesture conflict)

`BrowserTabButton` uses `NSClickGestureRecognizer` for tab selection and an
`NSButton` for close (`×`). The gesture recognizer intercepts all clicks including
those on the close button.

**Fix:** `selectTapped(_:)` checks if click location is within `closeBtn.frame`
and returns early — letting the button's own target-action fire. Alternative
approach if this still fails: use `gestureRecognizer(_:shouldRequireFailureOf:)`
or remove the gesture and use `mouseUp` override instead.
