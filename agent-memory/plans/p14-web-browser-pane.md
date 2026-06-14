# P14 — Embedded Browser Pane (cmux parity)

Status: **planned / not started** — P13 ✅, P12 ✅, P11 ✅ all unblocked this
Priority: **P3**
Owner surface: **HarnessApp pane UI + harness-mcp browser tools**
Depends on: P13 split pane parity ✅, P12 MCP control plane ✅
Gap source: WezTerm/tmux/cmux comparison (2026-06-13); cmux research 2026-06-14

---

## Goal

Add a `WKWebView`-backed browser pane so agents (and humans) can preview running
local apps, docs, or any URL beside terminal panes.

Agent-facing target behavior (mirrors cmux's browser CLI, delivered via MCP):

```
// agent workflow
harnessBrowserOpen({paneId: "new", url: "http://localhost:3000"})
harnessBrowserWait({paneId, loadState: "complete"})
const snap = harnessBrowserSnapshot({paneId, interactive: true})
// snap.elements = [{id:"e3", tag:"input", placeholder:"Search"}, ...]
harnessBrowserInteract({paneId, action:"type", elementId:"e3", text:"hello"})
harnessBrowserInteract({paneId, action:"click", elementId:"e7"})
```

---

## What cmux does (research, 2026-06-14)

cmux ships `WKWebView` as a first-class split pane using the WebKit engine (same as
Safari). Key design decisions worth copying:

- **Browser is a real pane** — lives in the same split tree as terminal panes;
  `new-pane --type browser` creates it via the same IPC socket as `new-split`.
- **DOM snapshot is the agent interface** — `browser snapshot --interactive` returns
  simplified DOM text with short element IDs (`e10`, `e14`). Agent uses those IDs
  for subsequent `type`/`click` commands instead of coordinates or XPath. This is
  the key insight: no screenshot parsing, no Playwright, just a text snapshot.
- **`browser wait --load-state complete`** — agent blocks until `WKNavigationDelegate`
  signals load completion before issuing interact commands.
- **All browser commands route through the same Unix socket** — no second MCP
  server; browser tools are just more commands in the existing IPC vocabulary.

Harness equivalent: route through `harness-mcp` tools (already established pattern
from P12) rather than CLI shell commands.

---

## Architecture

```
PaneNode
├── .leaf(PaneLeaf)          terminal surface (current)
└── .browser(BrowserLeaf)   new leaf kind (P14)
         │
         ▼
BrowserPaneView (NSView)
├── compact toolbar (URL field, back/forward/reload/stop, ⌘L to focus)
└── WKWebView (fills remaining space)
```

`BrowserLeaf` is a plain struct stored app-side (like `PaneLeaf`) with:
- `id: UUID`
- `url: URL`

No daemon involvement — browser panes are GUI-only, like file editor panels.
They get a synthetic `paneId` for MCP targeting (UUID string, same convention as
`PaneLeaf.id`).

---

## PBIs

### PBI-BROWSER-001: `BrowserPaneView` shell

Files:
- New: `Apps/Harness/Sources/HarnessApp/UI/Panes/BrowserPaneView.swift`

Tasks:
- `WKWebView` + compact toolbar (URL field, back/forward/reload, ⌘L focus).
- Navigate on URL field Enter; update field on `WKNavigationDelegate` callbacks.
- No persistence, no MCP, no `PaneNode` integration yet.
- Verify: open `http://localhost:<port>` and resize without terminal blink.

### PBI-BROWSER-002: `PaneNode` integration

Files:
- Touch: `Packages/HarnessCore/Sources/HarnessCore/Panes/PaneNode.swift`
- Touch: `Apps/Harness/Sources/HarnessApp/UI/Panes/PaneContainerView.swift`
- New: `Packages/HarnessCore/Sources/HarnessCore/Panes/BrowserLeaf.swift`

Tasks:
- Add `.browser(BrowserLeaf)` case to `PaneNode`.
- `PaneContainerView` builds `BrowserPaneView` for `.browser` leaves; all existing
  `.leaf` switch arms stay unchanged.
- Wire `new-browser <url>` command → `SessionCoordinator.openBrowserPane(url:)`.
- Audit every `PaneNode` switch for exhaustiveness (should be ~5 call sites).
- Menu item "Open Browser Pane" under Window menu.

### PBI-BROWSER-003: Persistence

- `BrowserLeaf.url` saved app-side (UserDefaults or in-memory, not `HarnessSettings`).
- Restore last URL on relaunch if pane was open at quit.

### PBI-BROWSER-004: MCP browser tools

Gated behind `HARNESS_MCP_ALLOW_CONTROL=1` same as existing mutating tools.

New tools in `HarnessDaemonTools.swift` (or `HarnessBrowserTools.swift`):

| Tool | Description |
|------|-------------|
| `harnessBrowserOpen` | Open new browser pane with URL; returns `paneId` |
| `harnessBrowserNavigate` | Navigate existing browser pane to URL |
| `harnessBrowserWait` | Wait until `loadState: "complete"` (or timeout) |
| `harnessBrowserSnapshot` | Returns page title + current URL + text content; with `interactive:true` returns element list with short IDs |
| `harnessBrowserInteract` | `action: "click"\|"type"\|"scroll"` + `elementId` from snapshot |
| `harnessBrowserClose` | Close browser pane |

**DOM snapshot format** (mirrors cmux `--interactive`):
```json
{
  "url": "https://localhost:3000",
  "title": "My App",
  "text": "...",
  "elements": [
    {"id": "e1", "tag": "input", "placeholder": "Search", "value": ""},
    {"id": "e2", "tag": "button", "text": "Submit"}
  ]
}
```
Elements include: `input`, `button`, `a`, `select`, `textarea` only (interactive
elements, not full DOM). IDs are short sequential strings scoped to the snapshot
(reset on each call).

Implementation note: use `WKWebView.evaluateJavaScript` to extract the snapshot.
`harnessBrowserInteract` injects a small JS snippet to find the element by its
stable selector (built from tag + index during snapshot) and dispatch
`click`/`input` events.

### PBI-BROWSER-005: Resource safety

- Verify `WKWebView` deallocates when pane closes (use Instruments leak check).
- Keep WebContent process crashes isolated — show error state in toolbar, don't
  crash Harness.
- Throttle/suspend background browser panes same as `AppIdleThrottle` for terminal.

---

## Non-Goals

- No full Playwright / WebDriver protocol.
- No cross-origin cookie/session sharing with the user's real browser.
- No `browserEvalJS` (arbitrary JS injection) in v1 — too broad a security surface;
  defer to PBI-BROWSER-006 if needed, gated behind a separate env flag.
- Do not move file editor sibling panel into `PaneNode` as part of this PBI —
  scope that separately if ever needed.

---

## Security

- `HARNESS_MCP_ALLOW_CONTROL=1` gates all mutating browser tools (same policy as P12).
- DOM snapshot (`harnessBrowserSnapshot`) is read-only, available without the flag.
- Browser panes load only URLs explicitly provided by the agent or user — no
  auto-navigation from terminal output.
- `WKWebView` default config (no custom `WKWebViewConfiguration`) — inherits
  WebKit's standard sandbox.

---

## Acceptance Criteria

- `swift build` passes.
- Browser pane opens via menu and via MCP `harnessBrowserOpen`.
- Agent can: open → wait → snapshot → interact (type + click) → close.
- Closing browser pane releases `WKWebView` resources; terminal panes unaffected.
- No terminal surface blink or black-flash regression.
- DOM snapshot returns interactive element list usable for subsequent interact calls.

---

## Rollout Order

1. PBI-BROWSER-001 — view shell, no model integration
2. PBI-BROWSER-002 — `PaneNode` integration + command wiring
3. PBI-BROWSER-003 — persistence
4. PBI-BROWSER-004 — MCP tools (requires 001+002)
5. PBI-BROWSER-005 — resource safety audit
