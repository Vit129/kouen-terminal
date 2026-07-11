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


## Browser Auto-Retry (P24 Phase 4)

When a page load fails with a connection error, `BrowserPaneView` automatically
retries loading the URL at a 3-second interval, up to 10 attempts.

- **Detection:** `webView(_:didFail:withError:)` and `webView(_:didFailProvisionalNavigation:withError:)` check if the error domain is `NSURLErrorDomain` with codes indicating the server isn't reachable yet (e.g. `NSURLErrorCannotConnectToHost`, `NSURLErrorTimedOut`, `NSURLErrorNetworkConnectionLost`, `NSURLErrorNotConnectedToInternet`).
- **Retry loop:** A `Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true)` fires `webView.load(request)` up to `maxRetries = 10`. The error banner shows "Retrying… (N/10)".
- **Auto-close:** If all 10 retries are exhausted (30s total), the browser pane closes itself via `splitPaneCoordinator.closeBrowserPane(paneID:)`.
- **Cancel on success:** `webView(_:didFinish:)` calls `cancelRetry()` which invalidates the timer and resets the attempt counter.
- **Use case:** Dev servers (Vite, Next.js) that aren't ready when the link is first clicked — the pane waits for the server to come up rather than showing a dead error page.

## CMUX-Style Redesign (2026-06-21)

### Layout (single toolbar row)

```
Row 1 (28pt): [tab1 ×][tab2 ×][+]          ← tab bar (plain NSView + NSStackView)
Row 2 (32pt): [◀][▶][🔄] [URL________] [×] ← toolbar (NSVisualEffectView blur)
──────────────────────────────────────────── ← progress line 2pt
[web content]                                ← WKWebView
```

- Tab bar: plain `NSView` (NOT `NSScrollView` — scroll view eats mouse events)
- Toolbar: `NSVisualEffectView` with `.hudWindow` material + `.behindWindow` blending
- Total chrome: 60pt (tab 28 + toolbar 32)
- URL field uses container with rounded corners + stretches via `.fill` distribution

### BUG: Tab close button never fired (CASE-055 extended)

**Symptom:** Click × on tab → nothing happens. Close pane button (toolbar ×) works fine.

**Root cause chain (3 layers):**
1. `NSScrollView` as tab bar container intercepted mouse events before subviews
2. `SoftIconButton.isTransparent = true` → NSButton never sends its action (by design)
3. `NSClickGestureRecognizer` consumed ALL mouse events before `mouseUp` could fire

**Fix:** Remove all three layers:
1. Tab bar → plain `NSView` (not NSScrollView)
2. Close icon → `SoftIconButton` for visual only (icon render)
3. NO gesture recognizer → `mouseUp` override handles both select + close

```swift
override func mouseUp(with event: NSEvent) {
    let loc = convert(event.locationInWindow, from: nil)
    if closeBtn.frame.contains(loc) {
        onClose()
    } else {
        onSelect()
    }
}
```

**Lesson (RL-043 update):** NSClickGestureRecognizer on a view consumes ALL mouse events
even with `delaysPrimaryMouseButtonEvents = false`. If you need both "select area" and
"close button" in one view, use `mouseUp` override — never gesture recognizer.

## CASE: OAuth login (Google) never completes — P35 (2026-07-06)

**Symptom:** Sign in with Google inside the browser pane reaches the Google consent
screen fine, user clicks Allow, popup shows a blank `accounts.google.com/gsi/transform`
page and never closes; opener tab (claude.ai) stays on `/login`.

**Root cause:** `createWebViewWith` (WKUIDelegate, target=_blank / `window.open()`) called
`createTab(url:configuration:)`, which — like the "+ new tab" path — always did
`newWeb.load(URLRequest(url:))`. Per Apple's documented contract, once you return the
`WKWebView` from `createWebViewWith`, **WebKit itself loads `navigationAction.request`
into it** — calling `.load()` yourself starts a second, disconnected navigation that
severs `window.opener` for that browsing context. Confirmed via injected diagnostic JS
(`console.log('opener=' + (window.opener ? 'set' : 'null'))` + a `message` event listener,
piped through the existing `kouenConsoleLog` → `/tmp/kouen-browser-<paneID>.log` file —
NOT app stdout/NSLog, that's a separate pipe): `window.opener` was `null` on *every*
navigation inside the Google popup, from the very first one. Ruled out Google's
anti-phishing embedded-webview block (P35's original hypothesis) since the repro reached
the consent screen — that block fires *before* login, not after. Ruled out
Cross-Origin-Opener-Policy since that would also break the same flow in real Safari.

Also found: `webViewDidClose(_:)` was never implemented, so the popup's JS
`window.close()` (part of Google GSI's postMessage-then-close handoff) was a silent no-op
— even after fixing `window.opener`, the tab would've stayed open.

**Fix (`BrowserPaneView.swift`):**
1. `createTab(url:configuration:skipLoad:)` — new `skipLoad` param, `true` only when
   called from `createWebViewWith`.
2. `createWebViewWith` returns the created `WKWebView` (was `nil` — also wrong: returning
   `nil` cancels `window.open()` at the JS level).
3. Added `webViewDidClose(_:)` → finds the tab by `webView` identity, calls `closeTab`.

**Lesson:** `WKUIDelegate.createWebViewWith` has a hard invariant — return the view you
created, never call `.load()`/`.loadFileURL()` on it yourself. Any future popup-handling
code in this file must respect that. Diagnostic technique worth reusing: page-side
`console.log` already routes to a per-pane `/tmp/kouen-browser-<paneID>.log` file (find
the newest one; `$TMPDIR` for a GUI app launched outside a shell is `/var/folders/.../T/`,
not `/tmp`) — cheaper than attaching Safari Web Inspector for this kind of opener/postMessage
question.

## CASE: Nested cross-origin iframe won't wheel-scroll — FIXED, confirmed (2026-07-06)

**Symptom:** A claude.ai "artifact" URL (`claude.ai/code/artifact/<id>`, content rendered in
a nested cross-origin iframe at `<uuid>.frame.claudeusercontent.com`) doesn't respond to
mouse-wheel/trackpad scroll over the embedded content in the browser pane. Scrollbar-thumb
drag works fine. Ordinary pages (wikipedia, a google search) wheel-scroll fine in the same
pane. The identical artifact URL opened in real Safari.app (same WebKit engine) scrolls
fine — this is Kouen-specific, not upstream/WebKit-wide.

**Root cause (researched via Opus subagent, not guessed):** WebKit's async scrolling
*thread* never builds a scrolling-tree node for this nested iframe's scrollable content at
initial layout in this app's WKWebView embedding — wheel scroll runs through that thread,
so with no node it silently no-ops (matches WebKit bugzilla 124139, "wheel events dropped
from iframe on first load"). Scrollbar drag works because that path runs in the *web
process*, where the `RenderLayer` genuinely is scrollable — a completely different code
path from wheel delivery. A pinch-to-zoom (magnification change) forces a scrolling-tree
*commit*, which is why the user's manual pinch made scroll start working — that observation
was the key clue that cracked this (see ledger below).

**Diagnostic ledger (each ruled a candidate in or out — don't re-run these):**
1. `allowsMagnification` / `allowsBackForwardNavigationGestures` disabled, rebuilt,
   retested → no change. Not the cause.
2. `customUserAgent` spoofed to real desktop Safari UA, rebuilt, retested → no change. Not
   UA-sniffed server-side content variance.
3. Injected `wheel` listener at bubble phase (not capture — capture-phase logging gave a
   false "not prevented" reading earlier since it fires *before* the page's own bubble
   handlers) confirmed: event dispatches with correct `deltaY`/`deltaX`,
   `defaultPrevented=false` on every event, in both the nested iframe and the outer
   claude.ai document. Not the artifact's own JS eating the event.
4. Grepped/graphed the whole codebase for anything in Kouen's own AppKit layer that could
   intercept wheel before WKWebView sees it: no `scrollWheel(_:)` override near the browser
   pane (the only two exist in `KouenTerminalKit`, used only by `.terminal` leaves), no
   custom `NSGestureRecognizer` on any ancestor, no ancestor `NSScrollView`, no global/local
   `NSEvent` monitor anywhere in the app. Ruled out the native-interception family entirely.

**Fix attempts:**
- v1 (abandoned): JS polyfill — detect via `requestAnimationFrame` whether native scroll
  moved `scrollTop`, manually drive it if not. First version re-probed every wheel event,
  racing the burst of events one trackpad gesture fires (an earlier event's manual nudge
  made a later event's own check falsely read "native works"). Fixed to decide once and
  commit — user reported "scrolled a little then stopped" anyway. Removed entirely once the
  magnification clue arrived; don't resurrect this pattern without a new reason.
- v2 (in code now, **confirmed** via repeated-scroll manual retest — multiple gestures over
  several seconds, `moved=true` persisted, the revert-to-original step did not re-drop the
  scroll-tree node):
  `kickCompositorRelayout(for:)` nudges `webView.magnification` by `+0.01` (delta has to
  clear WebKit's internal rounding — `0.0001` in an earlier attempt was likely coalesced
  into a no-op) then reverts 50ms later, guarded by `compositorKickInFlight`. Triggered by
  an in-frame injected script (`forMainFrameOnly:false`, so it runs inside the nested
  iframe) that posts a `kouenCompositorKick` message on the **first `pointermove` over the
  frame** (pre-emptive, before the user scrolls) with the first `wheel` as an independent
  one-shot backstop — replaces an earlier blind `didFinish + 1.2s` timer that fired before
  the nested iframe had even mounted (confirmed via console-log timing: the iframe's own
  connection handshake lands ~2-3s after the outer page's `didFinish`).
- **Known risk, called out by the investigation itself:** the kick commits the scroll-tree
  build at `+0.01`, then the revert *re-runs* the tree build at the original scale. If the
  node is fragile, the revert could re-drop it — reproducing the v1 "scrolled a little then
  stopped" symptom by a different mechanism. A `#if DEBUG`-gated probe
  (`console.log('kouen.scrollprobe … moved=true/false')`, reusing the existing
  `kouenConsoleLog` pipe) logs whether the nearest scrollable ancestor's `scrollTop` actually
  changed after each wheel event in a nested frame — **the definitive test is `moved=true`
  persisting across several repeated scroll gestures over multiple seconds, not a single
  scroll.** If it flips back to `moved=false` on a later gesture, the fallback is to hold the
  magnification at the nudged value instead of reverting (must toggle against a captured
  baseline per-navigation, not `current + 0.01` repeatedly, or it accumulates).

**Lesson:** when a wheel-scroll bug reproduces only for a *nested* frame and not the
top-level document in the same WKWebView, and the DOM event fires correctly with
`defaultPrevented=false`, suspect the async scrolling-tree/compositor layer, not JS event
handling or AppKit-level event interception — a scale/geometry change that forces a
scrolling-tree commit (magnification, or potentially a genuine frame-size nudge) is the
right category of fix, not a JS `scrollTop` polyfill. Log `deltaPrevented` in the
**bubble** phase, not capture — a capture-phase listener fires before the page's own bubble
handlers and gives a false "nothing prevented this" reading.

## CASE: Google/Apple OAuth blocked by default WKWebView user agent (2026-07-10)

**Symptom:** "Sign in with Google" / "Sign in with Apple" buttons on third-party sites
loaded in the browser pane classify into Google's restricted OAuth flow
(`flowName=GeneralOAuthLite` vs the standard `GeneralOAuthFlow`) instead of the normal
consent flow — precursor to the `disallowed_useragent` interstitial ("This browser or app
may not be secure"). Root cause: `WKWebViewConfiguration()`'s default UA omits the
`Version/x.y Safari/605.1.15` suffix real Safari sends; Google/Apple's OAuth endpoints key
embedded-webview detection off that. Popup/opener handoff itself (P35, 2026-07-06,
`db5c34d9`) was already correct — this is a separate, earlier-stage gate.

**Fix (`BrowserPaneView.swift`):** `customUserAgent = desktopSafariUserAgent` (a hardcoded
Safari-format UA string) set on the `WKWebView` at all 3 construction sites: `init`
(non-warmed path), `createTab` (new tab / popup path), `BrowserPaneRegistry.prewarm` (warm
pool). All 3 must be covered — a warmed webview from the pool skips `init`'s branch
entirely, and popup tabs go through `createTab`, not `init`.

**Verified:** curl'd `accounts.google.com/o/oauth2/v2/auth` with the pre-fix (no
Version/Safari suffix) vs post-fix UA — server-side `flowName` differs
(`GeneralOAuthLite` → `GeneralOAuthFlow`), confirming Google's endpoint reclassifies the UA
as fixed. Could not drive an actual `disallowed_useragent` interstitial or a full login
(needs a valid OAuth client + real account), so this confirms the classification gate
moved, not that end-to-end login now succeeds — verify with a real account/site before
calling OAuth login fully working.

**Known ceiling (`ponytail:` in code):** the UA string is hardcoded to the Safari version
installed at fix time (26.5) and will rot as WebKit ships new versions — Google's
classifier may eventually key off the specific version number lagging too far behind. No
runtime derivation of the "real" UA was attempted (WKWebView has no sync API for its
default UA — only observable via an async JS eval after a page loads).

**Follow-up (2026-07-10, same day):** `setupConsoleLogRedirection` (console-log capture,
compositor-kick, `#if DEBUG` scroll probe) and `setupNetworkCapture` (fetch/XHR override,
captures request/response bodies incl. tokens, exposed via `kouenBrowserNetwork` MCP tool)
all inject JS into every page at `.atDocumentStart`, `forMainFrameOnly: false` — exactly
the "read every keystroke / intercept session" capability Google's embedded-webview policy
warns about, even though Kouen's intent is only local debugging. Added
`oauthGuardJS` (`Self.oauthGuardJS`, near `desktopSafariUserAgent`) — a one-line
`if ([hosts].indexOf(location.hostname) !== -1) return;` prepended inside all 4 injected
IIFEs — so none of these scripts run at all on `accounts.google.com` / `appleid.apple.com`.
Deliberately narrow allowlist (`oauthOriginBlocklist`): only hosts whose *entire* surface is
auth, not broad app domains (`github.com`, `facebook.com`) where a wildcard would also kill
debugging on unrelated pages. Extend the array if a new provider's login page needs the same
protection.

**Out of scope (explicitly deferred, not built):**
- Native `Sign in with Apple` (`ASAuthorizationController`) — needs a new entitlement +
  Associated Domains (`webcredentials:`); web-based Apple ID sign-in rides the same UA fix
  as Google and needs neither.
- `ASWebAuthenticationSession` / system-browser OAuth handoff — structurally doesn't fit:
  Kouen's browser pane is a general browser where the *site* owns the OAuth client and
  redirect target (not Kouen), so a system-browser session would land the callback in
  Safari, not the WKWebView tab the user is looking at.
- Per-pane/incognito `WKWebsiteDataStore` isolation — panes intentionally keep the current
  shared persistent store (login state shared across tabs/restarts).
- WebAuthn/passkey and SMS/TOTP 2FA — no code changes made; WKWebView's built-in
  `navigator.credentials` support (macOS 13+) and plain page-content OTP entry are expected
  to work once the OAuth UA gate above is cleared, but this needs a real-account
  verification pass, not just a claim.

## Local HTML Rendering (2026-07-04)

Double-clicking a `.html`/`.htm` file in the file tree (`FileTreeSwiftUIView.openFile()`)
now routes into the Browser Pane via `openBrowserPane(url: URL(fileURLWithPath:))` instead
of opening as syntax-highlighted source (single-click preview is unchanged — still text).
Motivated by wanting the same rendered view for local static HTML (e.g. a course/report
site with sibling `.js`/`.css`) that ⌘B already gives for remote/localhost URLs.

- `BrowserPaneView.navigate(to:)` and `createTab(url:)` branch on `url.isFileURL` →
  `webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())`.
  Plain `webView.load(URLRequest(url:))` (the http(s) path) silently fails for `file://`
  — WKWebView requires the dedicated API plus an explicit sandbox read-access grant on the
  *directory*, not just the file, so relative `<script src="course.js">`/`<link
  href="style.css">` references next to the HTML resolve too.
- **Toggle back to source:** new toolbar button `viewSourceButton` (only visible when the
  active tab's URL is a local `.html`/`.htm` file — gated via
  `updateViewSourceButtonVisibility(for:)`, called at all 4 existing `urlTextField`
  sync points: `navigate(to:)`, `selectTab`, `didCommit`, `didFinish`). Clicking it posts
  the existing `HarnessOpenFilePreview` notification (same one `BrowserIntegrationController`
  already used for close-pane symmetry) — `MainSplitViewController.openFilePreviewFromTerminal`
  picks it up and opens the file as source in a normal file tab. No new notification needed.
- Test: `BrowserPaneViewTests.testViewSourceButtonVisibleOnlyForLocalHTML`.
