# P13 — Embedded Browser Pane (cmux parity)

Status: **idea / not started**
Priority: **P3** — largest scope of the three gap items, least aligned with "terminal first"
Depends on: none, but touches the same pane tree as [[split-panes]]
Gap source: WezTerm/tmux/cmux comparison (2026-06-13) — cmux ships a scriptable embedded browser
pane (Playwright-equivalent control) alongside terminal panes; neither WezTerm nor tmux nor
Harness has this today.

---

## Goal

Add a `WKWebView`-backed browser as a third pane kind (alongside terminal and file-editor panes),
with a minimal scriptable surface (`navigate(url)`, `screenshot()`, `evaluateJS()`) reachable from
`harness-mcp` (P12) so an agent can preview a running dev server side-by-side with its terminal.

## Current State

- `PaneNode` (binary tree, per [[split-panes]]) currently models two leaf kinds: terminal surface
  and file-editor split (`ContentAreaViewController.showFileEditorSplit()` — constraint-based
  sibling panel, *not* part of the `PaneNode` tree)
- No WebKit usage anywhere in `HarnessApp` today

## Architecture

```
PaneNode (existing binary tree)
├── .terminal(surfaceID)
├── .editor(...)              (currently sibling-panel, may need to become a PaneNode case)
└── .browser(BrowserPaneState)   ← NEW leaf kind
        │
        ▼
BrowserPaneView (WKWebView wrapper)
├── URL bar (NSTextField, AppKit)
└── WKWebView content
```

## PBIs

### PBI-BROWSER-001: BrowserPaneView + PaneNode integration
- New `.browser` case in `PaneNode`; `BrowserPaneView` (WKWebView + URL bar)
- Split/close/resize wiring through existing `HarnessSplitView` / `PaneContainerView` — **must
  not** disturb terminal pane reorder/recursion guards (see [[split-panes]] RL notes)

### PBI-BROWSER-002: Persistence
- Save/restore last URL per pane via `UserDefaults` (RL-015 — GUI-only state, not
  `HarnessSettings`)

### PBI-BROWSER-003: Scriptable control (depends on P12)
- `harness-mcp` tools: `browserNavigate(paneId, url)`, `browserScreenshot(paneId)`,
  `browserEvalJS(paneId, script)` via `WKWebView.evaluateJavaScript`
- Optional: console log capture (`WKUserContentController` message handler) surfaced to agent

## Risks

- `PaneNode` is currently a clean terminal/editor binary tree; adding a third leaf kind touches
  every switch over `PaneNode` (split logic, persistence, snapshot restore) — audit before
  starting
- WKWebView is heavyweight relative to terminal surfaces; verify memory/CPU impact with multiple
  browser panes open (Activity Monitor check, similar to CASE-027 Metal surface leak check)

## Estimate

4–5 sessions (pane integration is the bulk; scripting is small once P12 exists)
