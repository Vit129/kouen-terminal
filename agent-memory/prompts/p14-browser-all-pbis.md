# Agent Prompt — P14 Browser Pane (PBI-001 through 005)
# Implement all PBIs in order. After each PBI passes `swift build`, continue to the next.
# After all done, come back and update agent-memory/memory.md and agent-memory/plans/p14-web-browser-pane.md.

---

## Before writing any code, read:

1. `agent-memory/plans/p14-web-browser-pane.md` — full spec and architecture
2. `agent-memory/memory.md` — project context and lessons
3. `Packages/HarnessCore/Sources/HarnessCore/Models/PaneNode.swift`
4. `Apps/Harness/Sources/HarnessApp/UI/Chrome/ContentAreaViewController.swift` (lines 659–840)
5. `Apps/Harness/Sources/HarnessApp/Services/SplitPaneCoordinator.swift`
6. `Apps/Harness/Sources/HarnessApp/UI/Chrome/MainMenuBuilder.swift`
7. `Tools/harness-mcp/Sources/HarnessMCP/ToolRegistry.swift`
8. `Tools/harness-mcp/Sources/HarnessMCP/HarnessDaemonTools.swift` (first 100 lines for pattern)

---

## PBI-BROWSER-001: BrowserPaneView shell

**New file:** `Apps/Harness/Sources/HarnessApp/UI/Chrome/BrowserPaneView.swift`

- `@MainActor final class BrowserPaneView: NSView`
- `WKWebViewConfiguration`: `limitsNavigationsToAppBoundDomains = false`
- Layout: compact toolbar NSView (32pt tall) pinned top + `WKWebView` below it
- Toolbar: `NSTextField` URL bar (⌘L shortcut to focus), back/forward/reload/stop `NSButton`s
- `WKNavigationDelegate`: update URL bar on `didCommit`; toggle stop↔reload button on `didStartProvisionalNavigation`/`didFinish`/`didFail`
- `WKUIDelegate`: `createWebView` → navigate same view (suppress popups)
- Public API: `init(url: URL)`, `func navigate(to url: URL)`

---

## PBI-BROWSER-002: PaneNode integration + wiring

### HarnessCore — PaneNode.swift

Add at top of file (before `PaneNode` enum):

```swift
public struct BrowserLeaf: Codable, Sendable, Equatable {
    public var id: PaneID
    public var url: URL
    public init(id: PaneID = UUID(), url: URL) { self.id = id; self.url = url }
}
```

Add `.browser(BrowserLeaf)` case to `PaneNode`. Update every switch exhaustively:
- `allLeaves()` → `.browser`: return `[]`
- `allSurfaceIDs()` → `.browser`: return `[]`
- `allPaneIDs()` → `.browser`: return `[leaf.id]`
- `paneID` var → `.browser(let l)`: return `l.id`
- `surfaceID` var → `.browser`: return `nil`
- `replaceSurface` → `.browser`: no-op
- `flattenSameDirection` → `.browser`: return `[node]`
- Any other switch → `.browser`: sensible empty/nil/no-op

### ContentAreaViewController.swift — PaneContainerView.build()

Add `.browser(let bl)` arm in the `switch node` block:

```swift
case let .browser(bl):
    let bv = BrowserPaneView(url: bl.url)
    bv.translatesAutoresizingMaskIntoConstraints = false
    parent.addSubview(bv)
    NSLayoutConstraint.activate([
        bv.topAnchor.constraint(equalTo: parent.topAnchor),
        bv.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
        bv.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
        bv.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
    ])
```

Do NOT touch `collectTerminalHosts` or `detachHostsOnly` — browser panes are not Metal surfaces.

### SplitPaneCoordinator.swift

Add `func openBrowserPane(url: URL, direction: SplitDirection)`:
- Get active tab + pane ID from snapshot
- Build `.browser(BrowserLeaf(url: url))` node
- Insert as new branch alongside active pane in tab's `rootPane`
- Apply locally (no daemon IPC — browser panes are app-side only)
  Use the same local-update path used elsewhere for app-side layout changes.

### MainMenuBuilder.swift

Add "Open Browser Pane" menu item under Window menu:
```swift
// action: SplitPaneCoordinator openBrowserPane(url: URL(string:"about:blank")!, direction: .horizontal)
```

---

## PBI-BROWSER-003: Persist last URL per pane

- In `BrowserPaneView`: on each successful navigation (`didFinish`), save URL to `UserDefaults.standard` with key `"browserPane.\(paneID.uuidString).url"`
- `init(url:)` accepts a `paneID: PaneID` parameter so it can restore saved URL
- `SplitPaneCoordinator.openBrowserPane` restores saved URL if one exists for the new pane's ID (pass through `BrowserLeaf.url`)
- Do NOT use `HarnessSettings` (RL-015: GUI-only state stays in UserDefaults)

---

## PBI-BROWSER-004: MCP browser tools

**New file:** `Tools/harness-mcp/Sources/HarnessMCP/HarnessBrowserTools.swift`

Tools (all `async`):

```
harnessBrowserOpen(url, direction?) → {paneId}
harnessBrowserNavigate(paneId, url) → {ok}          [requires ALLOW_CONTROL]
harnessBrowserWait(paneId, timeoutSeconds?) → {ok}   [requires ALLOW_CONTROL]
harnessBrowserSnapshot(paneId, interactive?) → {url, title, text, elements:[{id,tag,text,value,placeholder}]}
harnessBrowserInteract(paneId, action, elementId, text?) → {ok}  [requires ALLOW_CONTROL]
harnessBrowserClose(paneId) → {ok}                   [requires ALLOW_CONTROL]
```

DOM snapshot JS to inject via `WKWebView.evaluateJavaScript`:
```javascript
(function(){
  var els=[],i=0;
  document.querySelectorAll('a,button,input,select,textarea,[role=button]').forEach(function(el){
    els.push({id:'e'+(++i),tag:el.tagName.toLowerCase(),
      text:(el.innerText||'').trim().slice(0,80),
      value:el.value||'',placeholder:el.placeholder||'',href:el.href||''});
  });
  return JSON.stringify({url:location.href,title:document.title,
    text:document.body.innerText.slice(0,3000),elements:els});
})()
```

Interact JS (click example — adapt for type/scroll):
```javascript
(function(){
  var all=document.querySelectorAll('a,button,input,select,textarea,[role=button]');
  var el=all[INDEX-1]; // INDEX = numeric part of elementId e.g. "e3" → 3
  if(!el) return JSON.stringify({ok:false,error:'element not found'});
  el.click();
  return JSON.stringify({ok:true});
})()
```

`BrowserPaneView` must expose:
```swift
func evaluateJS(_ script: String) async throws -> Any
func snapshot(interactive: Bool) async throws -> BrowserSnapshot  // calls evaluateJS
func navigate(to url: URL)
func waitForLoad(timeout: TimeInterval) async throws
```

`HarnessBrowserTools` needs a registry of live `BrowserPaneView` instances keyed by `PaneID`. Add a simple `@MainActor` registry (dict) on `SessionCoordinator` or a standalone `BrowserPaneRegistry.shared`.

Register tool definitions in `ToolRegistry.swift` alongside existing tools. Gate mutating tools with `isToolAllowed` same as `sendPaneText`/`splitPane`.

---

## PBI-BROWSER-005: Resource safety

- Add `deinit` to `BrowserPaneView` with `NSLog("[BrowserPane] deinit \(paneID)")` to verify deallocation
- `WKNavigationDelegate.webView(_:didFail:withError:)` and `didFailProvisionalNavigation`: show inline error banner in toolbar (red label, dismissible)
- WebContent process termination: implement `WKNavigationDelegate.webViewWebContentProcessDidTerminate` → reload page + show "Page crashed, reloading…" banner
- Ensure `BrowserPaneView` is not retained by `BrowserPaneRegistry` after pane close — use `[weak self]` or remove from registry in `removeFromSuperview` override

---

## Hard constraints

- **RL-004 / no black flash:** never reparent existing `TerminalHostView` instances
- **Swift 6 / strict concurrency:** `BrowserPaneView` is `@MainActor`; `WKWebView` on main thread only; all JS evaluation must `await` on main actor
- **HarnessCore `-warnings-as-errors`:** every `PaneNode` switch must be exhaustive with no warnings
- **No daemon IPC for browser panes** — they are app-side GUI-only; no PTY, no scrollback, no daemon surfaceID

---

## Tests to write

- `BrowserPaneViewTests.swift`: URL bar updates via mock `WKNavigationDelegate` callbacks
- `PaneNodeBrowserTests.swift`:
  - `allSurfaceIDs()` returns `[]` for `.browser` leaf
  - `allPaneIDs()` returns `[leaf.id]` for `.browser` leaf
  - `allLeaves()` returns `[]` for `.browser` leaf
  - Branch with `.leaf` + `.browser` → `allLeaves()` returns 1 leaf

---

## Verification

After each PBI: `swift build` must pass.
After all PBIs: `swift test --filter HarnessAppTests` must pass.

Final commit:
```
feat(p14): PBI-BROWSER-001..005 — embedded browser pane + MCP tools

WKWebView pane in PaneNode split tree. MCP tools: harnessBrowserOpen/
Navigate/Wait/Snapshot/Interact/Close. DOM snapshot returns interactive
element IDs for agent click/type. No daemon IPC — browser panes are
app-side only. swift build + HarnessAppTests pass.
```

---

## After all done — update memory

Update `agent-memory/memory.md` Task_Ledger: add new row marking P14 PBI-001..005 done.
Update `agent-memory/plans/p14-web-browser-pane.md` Status line to `**done**`.
