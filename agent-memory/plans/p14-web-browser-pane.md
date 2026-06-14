# P14 — Embedded Browser Pane (cmux parity)

Status: **ready to implement** — P13 ✅, P12 ✅, P11 ✅ all unblocked this
Priority: **P3**
Owner surface: **HarnessApp pane UI + harness-mcp browser tools**
Depends on: P13 ✅, P12 ✅
Research: cmux (WKWebView + CLI socket), Codex Tier 3 (Atlas/WKWebView for localhost), 2026-06-14

---

## Goal

`WKWebView`-backed browser pane in the split tree + MCP agent control.
Primary use case: agent opens localhost dev server, takes snapshot, clicks/types to
reproduce a bug, without leaving Harness.

---

## Technology Decision: WKWebView (confirmed)

**WKWebView** — same choice as Codex's Tier 3 "in-app browser" (Atlas), which
OpenAI explicitly designates for localhost / dev server use.

Why not Chromium/CEF: +200MB bundle, no macOS App Store path, not needed for
localhost use case. WKWebView covers 80% via JS injection:

| Capability | WKWebView | Notes |
|---|---|---|
| navigate / load | ✅ | `WKNavigationDelegate` |
| DOM snapshot + element IDs | ✅ | `evaluateJavaScript` |
| click / type / scroll | ✅ | JS `dispatchEvent` injection |
| screenshot | ✅ | `WKSnapshotConfiguration` |
| console capture | ✅ | injected `console.log` override via `WKUserScript` |
| evalJS arbitrary | ✅ | `evaluateJavaScript` (same-origin only) |
| network intercept | ⚠️ | `WKURLSchemeHandler` for custom schemes; HTTP requires `decidePolicyFor` |
| service worker debug | ⚠️ | not exposed in WKWebView public API → PBI-BROWSER-006 |

**Remaining 20% (network intercept + service worker):** revisit in PBI-BROWSER-006
using `WKURLSchemeHandler` + `WKScriptMessageHandler` bridge pattern. This is
sufficient for production dev workflows; the gap only matters for deep network-level
debugging (HAR export, request mutation) which a separate tool handles better anyway.

---

## Architecture

```
PaneNode (HarnessCore)
├── .leaf(PaneLeaf)          terminal surface — unchanged
└── .browser(BrowserLeaf)   new leaf kind — app-side only, no daemon

BrowserLeaf { id: PaneID, url: URL }   (Codable, Sendable)

PaneContainerView.build(node:) switch:
├── .leaf   → TerminalHostView  (unchanged)
└── .browser → BrowserPaneView  (new)

BrowserPaneView (NSView)
├── toolbar (NSTextField URL bar, back/forward/reload/stop buttons)
└── WKWebView (fills remaining space)

MCP (HarnessDaemonTools.swift or HarnessBrowserTools.swift):
harnessBrowserOpen / Navigate / Wait / Snapshot / Interact / Close
```

`BrowserLeaf` lives **app-side only** — no daemon IPC, no scrollback, no PTY.
It gets a `PaneID` (UUID) so MCP can target it like any other pane.

---

## PBIs

### PBI-BROWSER-001: BrowserPaneView shell

**Files:**
- New: `Apps/Harness/Sources/HarnessApp/UI/Chrome/BrowserPaneView.swift`

**Tasks:**
- `BrowserPaneView: NSView` with `WKWebView` + compact toolbar
- Toolbar: `NSTextField` URL bar (⌘L to focus), back/forward/reload/stop `NSButton`s
- `WKNavigationDelegate`: update URL bar on navigation, show load spinner
- `WKUIDelegate`: handle `window.open` → navigate in same view
- `limitsNavigationsToAppBoundDomains = false` so localhost HTTP works
- No `PaneNode` integration yet — test standalone with `BrowserPaneView(url: URL)`

**Tests:** `BrowserPaneViewTests.swift` — verify URL bar updates on navigation delegate callbacks (mock `WKNavigation`)

---

### PBI-BROWSER-002: PaneNode integration + command wiring

**Files:**
- Touch: `Packages/HarnessCore/Sources/HarnessCore/Models/PaneNode.swift` — add `.browser(BrowserLeaf)` case + `BrowserLeaf` struct
- Touch: `Apps/Harness/Sources/HarnessApp/UI/Chrome/ContentAreaViewController.swift` — add `.browser` arm to `PaneContainerView.build()`
- Touch: `Apps/Harness/Sources/HarnessApp/Services/SplitPaneCoordinator.swift` — `openBrowserPane(url:direction:)` inserts `.browser` leaf via existing split path
- Touch: `Apps/Harness/Sources/HarnessApp/Services/MainExecutor.swift` — `open-browser <url>` command
- Touch: `Apps/Harness/Sources/HarnessApp/UI/Chrome/MainMenuBuilder.swift` — Window > "Open Browser Pane" menu item

**`BrowserLeaf`:**
```swift
public struct BrowserLeaf: Codable, Sendable, Equatable {
    public var id: PaneID
    public var url: URL
    public init(id: PaneID = UUID(), url: URL) { self.id = id; self.url = url }
}
```

**`PaneNode` switch audit:** `allSurfaceIDs`, `allPaneIDs`, `allLeaves`, `replaceSurface`, `paneKey`, `firstLeafID`, `flattenSameDirection`, `leafNode`, `neighborSurface`, `panePathLookup`, `surfaceID(forPaneID:)` — browser leaf returns empty/nil where terminal-only semantics don't apply.

**`PaneContainerView.build()` `.browser` arm:** instantiate `BrowserPaneView(url: leaf.url)`, pin to parent edges same as `.leaf` pane shell. No `collectTerminalHosts`/`detachHostsOnly` needed — `BrowserPaneView` is not a Metal surface.

**Tests:** verify `PaneNode.allLeaves()` includes browser leaf; `PaneNode.allSurfaceIDs()` excludes it; `PaneContainerView` builds without crash.

---

### PBI-BROWSER-003: Persist last URL per pane

- `BrowserLeaf.url` saved app-side in `UserDefaults` keyed by pane ID
- Restore on tab reopen if `BrowserLeaf` is in tab's `rootPane`
- Do NOT put in `HarnessSettings` (GUI-only state, RL-015)

---

### PBI-BROWSER-004: MCP browser tools

Gated behind `HARNESS_MCP_ALLOW_CONTROL=1` except `harnessBrowserSnapshot` (read-only).

**File:** New `Tools/harness-mcp/Sources/HarnessMCP/HarnessBrowserTools.swift`

**Tools:**

```swift
// harnessBrowserOpen — opens new browser pane, returns paneId
// harnessBrowserNavigate — navigate existing pane
// harnessBrowserWait — wait for loadState "complete" (timeout 30s default)
// harnessBrowserSnapshot — returns {url, title, text, elements:[{id,tag,text,value,placeholder}]}
// harnessBrowserInteract — {action:"click"|"type"|"scroll", elementId, text?}
// harnessBrowserClose — close browser pane
```

**DOM snapshot JS** (injected via `evaluateJavaScript`):
```javascript
(function() {
  var els = [], i = 0;
  document.querySelectorAll('a,button,input,select,textarea,[role=button]')
    .forEach(function(el) {
      els.push({id:'e'+(++i), tag:el.tagName.toLowerCase(),
        text:(el.innerText||'').trim().slice(0,80),
        value:el.value||'', placeholder:el.placeholder||'',
        href:el.href||''});
    });
  return JSON.stringify({url:location.href, title:document.title,
    text:document.body.innerText.slice(0,3000), elements:els});
})()
```

Element IDs (`e1`, `e2`, …) are sequential per snapshot call — agent stores them
and uses for `harnessBrowserInteract`. IDs reset on next snapshot.

**Interact JS** (find by stable selector built during snapshot, dispatch event):
```javascript
// click e3 → find 3rd interactive element, el.click() + dispatchEvent MouseEvents
// type e3 "hello" → focus + set value + dispatchEvent input/change
```

**Implementation note:** `BrowserPaneView` exposes `func evaluateJS(_ script: String) async throws -> Any` and `func snapshot() async throws -> BrowserSnapshot`. MCP tools call these on `@MainActor` via `SessionCoordinator`'s browser pane registry.

---

### PBI-BROWSER-005: Resource safety

- `WKWebView` must deallocate when pane closes — verify with `deinit` log + Instruments
- WebContent process crash → show error banner in toolbar, don't crash Harness
- Add `WKNavigationDelegate.webView(_:didFail:withError:)` handler

---

### PBI-BROWSER-006: Network intercept + service worker (revisit)

The 20% not covered by WKWebView's public API:

- **Network intercept / HAR export:** `WKURLSchemeHandler` intercepts custom schemes (`harness://`). For HTTP/HTTPS, use `decidePolicyFor navigationAction` to log requests — full mutation not possible without private API.
- **Service worker debug:** not exposed in `WKWebView` public API. Workaround: inject `navigator.serviceWorker` hooks via `WKUserScript` to capture registration/messages; surface via `WKScriptMessageHandler`.
- **Recommendation:** if full network-level debugging is needed, consider launching a CDP-aware headless browser as a separate process and proxying MCP commands to it — keeps WKWebView for the embedded view while CDP handles deep inspection.

Gate: only start PBI-BROWSER-006 if a user explicitly requests network intercept or service worker debug capability.

---

## Non-Goals (v1)

- No `browserEvalJS` arbitrary injection tool (security surface too broad — agent uses `harnessBrowserInteract` + `harnessBrowserSnapshot` instead)
- No cross-origin cookie sharing with user's real browser
- No Playwright/WebDriver protocol
- Do not promote file editor sibling panel into `PaneNode` as part of this work

---

## Security

- `harnessBrowserSnapshot` read-only, no control flag needed
- All mutating tools (`Navigate`, `Interact`, `Open`, `Close`) require `HARNESS_MCP_ALLOW_CONTROL=1`
- WKWebView default sandbox — no custom `WKWebViewConfiguration` process pool
- Agent-provided URLs are the only navigation source (no auto-navigation from terminal output)

---

## Acceptance Criteria

- `swift build` passes
- Browser pane opens via "Window > Open Browser Pane" and via MCP `harnessBrowserOpen`
- Agent workflow: open → wait → snapshot → interact (type + click) → close
- Closing browser pane: WKWebView deallocated, terminal panes unaffected, no black flash
- DOM snapshot returns interactive element list; `harnessBrowserInteract` uses element IDs from snapshot

---

## Rollout Order

1. PBI-BROWSER-001 — BrowserPaneView shell (standalone)
2. PBI-BROWSER-002 — PaneNode + command wiring
3. PBI-BROWSER-003 — persistence
4. PBI-BROWSER-004 — MCP tools
5. PBI-BROWSER-005 — resource safety
6. PBI-BROWSER-006 — network intercept (revisit, gated on demand)
