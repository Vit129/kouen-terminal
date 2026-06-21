# P28 — Browser DevTools API (harness-mcp + WKWebView)

> Status: PLANNED
> Priority: HIGH (next after MCP round-trip fix)
> Created: 2026-06-21
> Reference: Playwright CLI (playwright.dev/agent-cli), Chrome DevTools Protocol

## Goal

Agent (Claude Code, Codex, Kiro) สั่ง inspect/control browser pane ผ่าน `harness-mcp` ได้
เหมือน Playwright CLI แต่ฝังใน terminal ไม่ต้อง launch headless browser แยก

## Reference: Playwright CLI Commands (ที่เราจะ map)

### Core (Phase 1 — WKWebView native)

| Playwright CLI | Harness equivalent | WKWebView API |
|----------------|-------------------|---------------|
| `open <url>` | `browserOpen` | `navigate(to:)` ✅ มีแล้ว |
| `goto <url>` | `browserNavigate` | `navigate(to:)` ✅ มีแล้ว |
| `snapshot` | `browserSnapshot` | `snapshot()` ✅ มีแล้ว (DOM + elements + console) |
| `screenshot` | `browserScreenshot` | `WKWebView.takeSnapshot()` ⚠️ ต้องเพิ่ม |
| `click <ref>` | `browserClick` | `evaluateJS("el.click()")` ✅ ได้เลย |
| `fill <ref> <text>` | `browserFill` | `evaluateJS("el.value='...'")` ✅ ได้เลย |
| `eval <js>` | `browserEval` | `evaluateJS(_:)` ✅ มีแล้ว |
| `console` | `browserConsole` | `consoleLogs[]` ✅ มีแล้ว |
| `go-back` / `go-forward` | `browserBack` / `browserForward` | `webView.goBack/goForward()` ✅ |
| `reload` | `browserReload` | `webView.reload()` ✅ |
| `close` | `browserClose` | `closeBrowserPane()` ✅ |
| `resize` | `browserResize` | WKWebView frame ✅ |

### Network (Phase 2 — needs JS injection)

| Playwright CLI | Harness approach |
|----------------|-----------------|
| `network` (list requests) | Inject `PerformanceObserver` + `fetch` monkey-patch → capture to array |
| `route` (mock) | Inject Service Worker or `fetch` override → return mock response |
| `network-state-set` (offline) | WKWebView doesn't support — skip or simulate via route |

### DevTools (Phase 2)

| Playwright CLI | Harness approach |
|----------------|-----------------|
| `console` | ✅ Already captured via message handler |
| `tracing-start/stop` | `WKWebView` has no native tracing — use Performance API via JS |
| `pdf` | `WKWebView.createPDF()` ✅ macOS native |

### Storage (Phase 3)

| Playwright CLI | Harness approach |
|----------------|-----------------|
| `cookie-list/set/delete` | `WKHTTPCookieStore` API ✅ |
| `localstorage-*` | `evaluateJS("localStorage.getItem()")` ✅ |
| `sessionstorage-*` | `evaluateJS("sessionStorage.getItem()")` ✅ |
| `state-save/load` | Serialize cookies + localStorage → JSON file |

## Strategy Change

**harness-mcp ปล่อยไว้ก่อน (broken round-trip)** — ใช้ Playwright CLI/MCP เป็น agent ↔ browser bridge แทน

แนวคิด: Harness browser pane = **visible WKWebView** ที่ Playwright CLI connect เข้ามาควบคุมได้
เหมือน `playwright-cli attach` กับ browser ที่เปิดอยู่แล้ว

ดู setup MCP config ที่มีอยู่ → agent ใช้ playwright-mcp tools กับ Harness browser pane ได้เลย
ไม่ต้อง fix harness-mcp round-trip ก่อน — bypass ไปใช้ mature tooling ที่ทำงานได้อยู่แล้ว

## Revised Architecture

```
Agent (Claude Code + playwright-mcp)
  → Playwright CLI commands (snapshot, click, fill, eval)
  → connects to Harness WKWebView (via CDP or direct JS bridge)
  → User เห็น browser pane update real-time
```

**ต้องศึกษา:**
1. Playwright CLI `attach` mode — connect กับ existing browser ได้ไหม (ปกติ connect ผ่าน CDP)
2. WKWebView ไม่มี CDP — ต้องทำ bridge หรือ proxy
3. Alternative: Harness expose WebSocket server ที่ translate Playwright commands → WKWebView evaluateJS

## Implementation Options

### Option A: WKWebView + JS Bridge (ง่ายสุด)
- Harness expose WebSocket on localhost
- Agent ใช้ playwright-mcp → route ผ่าน WebSocket → Harness evaluateJS
- ไม่ต้อง CDP protocol เต็ม แค่ subset ที่ WKWebView ทำได้

### Option B: Launch Chromium inside Harness pane (เหมือน CMUX)  
- ใช้ Chromium แทน WKWebView → CDP available natively
- Playwright CLI connect ได้ตรง
- แต่ heavy (bundle Chromium)

### Option C: Hybrid — WKWebView for display, Playwright for heavy lifting
- Browser pane = WKWebView (lightweight, display)
- Agent ต้อง deep inspect → spawn headless Playwright session ข้างหลัง
- Harness sync URL between WKWebView ↔ Playwright session

### Phase 1: Core browser commands (covers 90% use cases)
- Wire existing methods through IPC: navigate, snapshot, evaluateJS, console, back/forward/reload/close
- Add: `browserScreenshot` (WKWebView.takeSnapshot → base64 PNG)
- Add: `browserClick(ref:)` / `browserFill(ref:value:)` (JS dispatch via element refs from snapshot)
- Add: `browserWaitForLoad(timeout:)`
- **Output format: match Playwright CLI** — snapshot returns accessibility tree with refs

### Phase 2: Network + DevTools
- JS-injected network capture (fetch/XHR monkey-patch)
- Console already done
- PDF export via `createPDF()`
- Performance metrics via `performance.getEntriesByType()`

### Phase 3: Storage + State
- Cookie management via `WKHTTPCookieStore`
- localStorage/sessionStorage via evaluateJS
- State save/load (serialize all to JSON)

## What We DON'T Need (leave to Playwright MCP)

- Headless browser launch/management
- Full CDP protocol compatibility
- Video recording
- Test code generation
- Multi-browser support (Firefox, WebKit variants)
- Service Worker debugging

## CLI Interface Design (harness-cli)

```bash
# Phase 1
harness-cli browser-open --url "https://example.com"
harness-cli browser-snapshot --pane <id>
harness-cli browser-screenshot --pane <id> --output screenshot.png
harness-cli browser-eval --pane <id> --js "document.title"
harness-cli browser-click --pane <id> --ref "e3"
harness-cli browser-fill --pane <id> --ref "e5" --value "hello"
harness-cli browser-console --pane <id>
harness-cli browser-close --pane <id>

# Phase 2
harness-cli browser-network --pane <id>
harness-cli browser-pdf --pane <id> --output page.pdf

# Phase 3
harness-cli browser-cookies --pane <id>
harness-cli browser-storage --pane <id> --type local
```

## Success Criteria

- Agent can: open URL → wait for load → snapshot DOM → click element → verify result
- All without launching a separate browser or Playwright process
- Response returns to agent within 2s for any command
- Console logs visible to agent in real-time (via snapshot)
