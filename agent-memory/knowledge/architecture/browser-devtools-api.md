# Browser DevTools API (P28)

## Summary

P28 wires AI agent browser control through `harness-mcp` → IPC → `BrowserPaneView` (WKWebView).
Agents can snapshot DOM, capture network, read storage, take screenshots — without launching a separate browser.

## Architecture

```
AI (Claude Code / Codex)
  → harness-mcp tool call (JSON-RPC over stdio)
  → DaemonClientActor.request(browserSnapshot/browserOpen/...) [timeout: 35s]
  → DaemonServer.forwardBrowserRequest()
      → snapshotSubscribers.first (GUI subscription fd)
      → sends IPCResponse.browserRequest(id:paneID:req:) to GUI
  → DaemonSyncService.handleBrowserRequest()
      → BrowserPaneView / WKWebView (evaluateJS, takeSnapshot, cookieStore)
      → IPCRequest.browserResponse(id:response:) back to daemon
  → DaemonServer resumes pendingBrowserRequests[id].continuation
  → IPCResponse.browserSuccess(payload) → MCP → agent
```

## Tools (Phase 1–3)

### Phase 1 — Core (all via evaluateJS or WKWebView native)
| Tool | IPC case | Notes |
|------|----------|-------|
| `harnessBrowserOpen` | `.open(url:direction:)` | opens new browser pane |
| `harnessBrowserNavigate` | `.navigate(paneID:url:)` | navigates existing pane |
| `harnessBrowserWait` | `.wait(paneID:timeoutSeconds:)` | waits for page load |
| `harnessBrowserSnapshot` | `.snapshot(paneID:interactive:)` | DOM + elements + console |
| `harnessBrowserScreenshot` | `.screenshot(paneID:)` | base64 PNG via WKWebView.takeSnapshot |
| `harnessBrowserInteract` | `.interact(paneID:action:elementID:text:)` | click / type / scroll |
| `harnessBrowserClose` | `.close(paneID:)` | closes pane |

### Phase 2 — Network
| Tool | IPC case | Notes |
|------|----------|-------|
| `harnessBrowserNetwork` | `.network(paneID:)` | reads `window.__harnessNetwork` |

Network capture is injected at `atDocumentStart` via `WKUserScript` — monkey-patches `fetch` and `XHR`.

### Phase 3 — Storage
| Tool | IPC case | Notes |
|------|----------|-------|
| `harnessBrowserCookies` | `.cookies(paneID:)` | via WKHTTPCookieStore.getAllCookies |
| `harnessBrowserStorage` | `.storage(paneID:storageType:)` | localStorage or sessionStorage via evaluateJS |

## Snapshot Element Format

```json
{
  "id": "e7",
  "tag": "button",
  "role": "button",
  "text": "Save changes",
  "value": "",
  "placeholder": "",
  "href": "",
  "bounds": { "x": 120, "y": 340, "width": 80, "height": 32 },
  "visible": true
}
```

Refs are stable per page load. Agent calls `browserInteract(action:"click", elementID:"e7")`.

## Key Bug Fixed: Round-Trip Timeout (RL-048)

**Root cause:** `DaemonClientActor.request()` default timeout = 2s. WKWebView operations (evaluateJS, DOM traverse, takeSnapshot) can take 2–5s on complex pages → MCP throws `.timeout` before response arrives.

**Fix:** `HarnessBrowserTools.send()` passes `timeout: 35` — matches daemon's 30s internal timeout + 5s buffer.

## Config

`HarnessSettings.browserHomePage: String` — default URL for new browser panes and tabs.
- Default: `"https://www.google.com"`
- Override: `~/.config/harness/settings.json` → `"browserHomePage": "https://your-url.com"`
- Read at: `BrowserPaneView.addNewTab()`, `ContentAreaViewController.openBrowserPane()`, `MainMenuBuilder.openBrowserPane()`

## Key Files

| File | Role |
|------|------|
| `Apps/Harness/Sources/HarnessApp/UI/Chrome/BrowserPaneView.swift` | snapshot, screenshot, network capture, storage, cookies |
| `Apps/Harness/Sources/HarnessApp/Services/DaemonSyncService.swift` | IPC handler → WKWebView bridge |
| `Packages/HarnessCore/Sources/HarnessCore/IPC/IPCMessage.swift` | BrowserRequestPayload, BrowserResponsePayload, BrowserElement, BrowserNetworkEntry, BrowserCookie |
| `Tools/harness-mcp/Sources/HarnessMCP/HarnessBrowserTools.swift` | MCP tool implementations |
| `Packages/HarnessDaemon/Sources/HarnessDaemon/DaemonServer.swift` | forwardBrowserRequest, pendingBrowserRequests, snapshotSubscribers |
| `Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonClientActor.swift` | async IPC wrapper (timeout: 35s for browser ops) |

## Testing

```bash
# 1. UI: open browser pane → should load google.com
make preview

# 2. MCP round-trip: requires Harness app running
echo '{"jsonrpc":"2.0","id":1,"method":"harnessBrowserOpen","params":{"url":"https://example.com"}}' | harness-mcp

# 3. Build + types
swift build --product Harness --product HarnessDaemon --product harness-cli
swift test
```
