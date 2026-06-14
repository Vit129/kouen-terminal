# P14 — Embedded Browser Pane (cmux parity)

Status: **idea / not started**
Priority: **P3** — start after P13 split parity and P12 MCP read/control tools
Owner surface: **HarnessApp pane UI + harness-mcp browser tools**
Depends on: **P13 split pane parity**, preferably P12 MCP control plane
Gap source: WezTerm/tmux/cmux comparison (2026-06-13) — cmux-style terminal+browser workspace

---

## Goal

Add a `WKWebView`-backed browser pane so an agent can preview and inspect a running local web app beside terminal panes.

Target user-facing behavior:

- split terminal right/down
- open browser pane in one split
- navigate to `http://localhost:<port>`
- agent can screenshot/evaluate/navigate through MCP

## Current State

- `PaneNode` currently models terminal surfaces only.
- File editor/preview is a constraint-based sibling panel, not a `PaneNode` leaf.
- No WebKit usage exists in `HarnessApp`.
- P13 is needed first so both side-by-side and top/bottom layouts are stable before adding a heavier non-terminal pane kind.

## Architecture

```
PaneNode
├── .leaf(PaneLeaf terminal)       current
└── future browser leaf            P14
        │
        ▼
BrowserPaneView
├── compact toolbar / URL field
└── WKWebView
```

Implementation should avoid reparenting existing terminal views and must preserve the no-black-flash rule from file preview work.

## PBIs

### PBI-BROWSER-001: Browser view shell

- Add `BrowserPaneView` wrapping `WKWebView`.
- Include a compact URL field, reload/stop, back/forward.
- Start as app-only UI behind a menu/command; no persistence yet.

### PBI-BROWSER-002: Pane model integration

- Decide whether browser is:
  - a new `PaneNode` leaf kind, or
  - an app-side pane-adjacent view with a mapping to a synthetic pane ID.
- Prefer `PaneNode` only after auditing every `PaneNode` switch.
- Keep terminal IPC surface keys untouched.

### PBI-BROWSER-003: Persistence

- Persist last URL per browser pane using `UserDefaults` or app-side persistence.
- Do not put GUI-only browser state in `HarnessSettings` unless it becomes cross-process contract.

### PBI-BROWSER-004: MCP control

Expose tools after P12:

- `browserNavigate(paneId, url)`
- `browserScreenshot(paneId)`
- `browserEvalJS(paneId, script)`
- optional `browserConsole(paneId)`

### PBI-BROWSER-005: Resource safety

- Verify memory/CPU with multiple browser panes.
- Ensure closed browser panes deallocate.
- Keep WebKit process failures isolated from terminal panes.

## Non-Goals

- Do not build a full browser product.
- Do not replace the user's real browser.
- Do not implement Playwright itself inside Harness.
- Do not expose browser automation without MCP/tool policy.

## Acceptance Criteria

- `swift build` passes.
- Browser pane can open localhost and resize with terminal panes.
- Closing browser pane releases its view/process resources.
- Browser pane does not cause terminal surface blink/reparent regressions.
- MCP can navigate and screenshot only after the control policy is in place.
