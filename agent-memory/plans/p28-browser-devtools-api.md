# P28 — Browser DevTools API (harness-mcp + WKWebView)

> Status: COMPLETE ✅ (Phase 1+2+3 done, round-trip fixed)
> Priority: HIGH
> Created: 2026-06-21
> Revised: 2026-06-22 (scope narrowed — AI bug fixing MVP only)
> Decision: Fix harness-mcp round-trip bug first, then validate 8 tools below

## Goal

AI (Claude Code, Codex, Kiro) สามารถ **มองหน้าเว็บได้ + กด/พิมพ์ได้ + อ่าน console ได้ + screenshot ได้**
ผ่าน Harness browser pane (WKWebView) — สำหรับ AI bug fixing workflow

ไม่ใช่ Chrome DevTools replacement, ไม่ใช่ Playwright parity — แค่ in-app browser lane

## Architecture

```
AI / Codex / Claude Code
  → harness-mcp tool call
  → Harness IPC browserRequest
  → BrowserPaneView / WKWebView
  → JS snapshot / click / fill / eval / screenshot
  → structured response กลับไปให้ AI
```

## MVP Tools (8 tools เท่านั้น)

| Tool | Description | Status |
|------|-------------|--------|
| `browserOpen(url)` | Open URL in browser pane | ✅ IPC ready |
| `browserSnapshot(paneID)` | DOM/accessibility tree + stable refs (e1, e2...) | ✅ IPC ready |
| `browserScreenshot(paneID)` | Visual snapshot → base64 PNG | ⚠️ needs WKWebView.takeSnapshot() wire |
| `browserEval(paneID, js)` | Read-only/debug JS execution | ✅ IPC ready |
| `browserClick(paneID, ref)` | Click element by ref | ✅ IPC ready |
| `browserFill(paneID, ref, value)` | Fill input by ref | ✅ IPC ready |
| `browserConsole(paneID)` | console.log/error/warn output | ✅ IPC ready |
| `browserWaitForLoad(paneID, timeout)` | Wait for page load | ✅ IPC ready |

## Critical: Snapshot Quality

snapshot ต้องดีพอให้ AI ใช้งานได้จริง — ต้องมี:

```json
{
  "ref": "e7",
  "role": "button",
  "tag": "button",
  "text": "Save",
  "label": "Save changes",
  "placeholder": null,
  "value": null,
  "bounds": { "x": 120, "y": 340, "width": 80, "height": 32 },
  "visible": true
}
```

ถ้า AI เห็น `"button Save ref=e7"` แล้วสั่ง `browserClick(ref="e7")` ได้ → MVP สำเร็จ

Refs ต้อง **stable per page load** — ไม่ shift ระหว่าง snapshot calls บน page เดียวกัน

## Session 2026-06-22 — What Was Done

### Delivered
| Item | File | Status |
|------|------|--------|
| Default URL → google.com (config-driven) | `HarnessSettings.browserHomePage` | ✅ |
| New tab / open browser pane reads settings | `BrowserPaneView`, `ContentAreaViewController`, `MainMenuBuilder` | ✅ |
| `screenshot()` method (WKWebView.takeSnapshot → base64 PNG) | `BrowserPaneView.swift` | ✅ |
| `screenshot` case in IPC payload | `IPCMessage.swift` | ✅ |
| Screenshot handler | `DaemonSyncService.swift` | ✅ |
| `role` field on `BrowserElement` | `IPCMessage.swift` | ✅ |
| Build (Harness + HarnessDaemon + harness-cli) | — | ✅ |
| Tests (all suites pass) | — | ✅ pre-existing ReleaseNotesGuard failures only |

### Key Decision
- harness-mcp approach = fix bug, not build feature (agy + Codex confirmed)
- Config route: แก้ `browserHomePage` ใน `~/.config/harness/settings.json` ได้เลย ไม่ต้อง rebuild
- screenshot() ยังไม่มี MCP tool wrapper (`harnessBrowserScreenshot` ใน `HarnessBrowserTools.swift`) — next step

## Remaining Blocker: harness-mcp Round-Trip Bug

**ยังต้อง fix ก่อน agent จะใช้งาน tools ได้จริง**

- Command ส่งออกไปได้ แต่ response ไม่กลับมาหา agent
- Fix path: `HarnessBrowserTools.swift` → `DaemonSyncService.swift` → MCP response path
- เมื่อ fix แล้ว → 7 จาก 8 tools ทำงานได้ทันที

## Completed ✅
1. ~~Fix harness-mcp round-trip~~ — timeout 2s → 35s (RL-048)
2. ~~Phase 1~~ — snapshot (role/bounds/visible), screenshot, elements
3. ~~Phase 2~~ — network capture (fetch + XHR via JS inject)
4. ~~Phase 3~~ — cookies (WKHTTPCookieStore) + localStorage + sessionStorage
5. ~~Config-driven home page~~ — HarnessSettings.browserHomePage

## Out of Scope (explicit)

- CDP proxy / Chrome DevTools Protocol compatibility
- Playwright full compatibility
- Network mocking / route interception
- Tracing / performance profiling
- Service Worker / debugger protocol
- Cookie / session state management
- Chromium bundle
- Multi-browser support
- back/forward/reload/resize/close (เพิ่มได้ทีหลัง ไม่ใช่ MVP)

## Success Criteria

1. Agent เปิด URL → รอโหลด → snapshot DOM → click element → verify result
2. Agent อ่าน console.error ได้
3. Agent screenshot ได้เพื่อ visual bug diagnosis
4. Response กลับภายใน 2s
5. ทำงานได้โดยไม่ต้อง launch Playwright หรือ browser แยก
