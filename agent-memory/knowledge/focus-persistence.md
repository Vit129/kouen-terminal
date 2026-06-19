# Focus Persistence — Per-Session-Tab Pane Focus (RL-043)

**Status:** Partial fix applied, not fully verified working (2026-06-19)
**Feature:** When switching between session tabs (workspaces/session groups), each tab should restore its previously focused split pane.

---

## User scenario

- SST1 (workspace/session tab 1): has 3 panes, pane 2 focused
- SST2: has 6 panes, pane 5 focused
- Switching via `cmd+1/2/3` or `cmd+shift+[/]` should restore per-tab focus
- Current bug: always focuses the wrong pane (globally last used, not per-tab remembered)

---

## Data model (correct, no changes needed)

```
Workspace.activeSessionID        → which session is active in this workspace
SessionGroup.activeTabID         → which tab is active in this session
Tab.activePaneID                 → which pane is active in this tab (daemon-authoritative)
Tab.lastActivePaneID             → previous pane (for select-pane -l)
```

Every pane click sends `.selectPane(tabID:paneID:)` IPC to daemon → daemon stores `tab.activePaneID`. So the daemon correctly remembers per-tab focus.

---

## Root cause

`SessionCoordinator.activeSurfaceID` is a GUI-side variable that holds the currently focused surface. It is NOT reset when switching tabs/workspaces.

In `ActivePaneService.ensureActivePane(for: Tab)`:
```swift
if let active = coord.activeSurfaceID, surfaces.contains(active) {
    target = active          // ← wrong: stale surface from other tab wins
} else if let paneID = tab.activePaneID, ... {
    target = sid             // ← correct: daemon-authoritative restore
}
```

If `activeSurfaceID` still points to a surface from the previous tab, and that surface happens to be in the new tab's surface list (unlikely but possible), it takes the wrong branch. More critically, `reflectRemoteActivePane()` (called inside `applySnapshot`) sets `activeSurfaceID` to the correct value only if `surfaceID != coord.activeSurfaceID`. If `activeSurfaceID` is stale but the guard passes, the restore is correct. If the guard fails due to some edge case, restore is skipped.

The reliable fix: **nil `activeSurfaceID` before `syncFromDaemon()`** so `reflectRemoteActivePane` always runs unconditionally.

---

## Fix applied (compiles, not fully tested)

### 1. `SessionLifecycleService.swift` (tab bar clicks, sidebar clicks)
```swift
func selectWorkspace(_ id: WorkspaceID) {
    coord.requestDaemon(.selectWorkspace(id: id))
    coord.activeSurfaceID = nil   // ← added
    coord.syncFromDaemon()
}

func selectSession(workspaceID: WorkspaceID, sessionID: SessionID) {
    ...
    coord.requestDaemon(.selectSession(...))
    coord.activeSurfaceID = nil   // ← added
    coord.syncFromDaemon()
}

func selectTab(workspaceID: WorkspaceID, tabID: TabID) {
    ...
    coord.requestDaemon(.selectTab(...))
    coord.activeSurfaceID = nil   // ← added
    coord.syncFromDaemon()
}
```

### 2. `MainExecutor.swift` (keyboard shortcuts — the actual user path)
```swift
// cycleActiveTab — cmd+shift+[ / ]
coordinator.requestDaemon(.selectTab(...))
coordinator.activeSurfaceID = nil   // ← added
coordinator.syncFromDaemon()

// selectTab(atIndex:) — cmd+1, cmd+2, cmd+3
coordinator.requestDaemon(.selectTab(...))
coordinator.activeSurfaceID = nil   // ← added
coordinator.syncFromDaemon()

// find-window — palette search
coordinator.requestDaemon(.selectTab(...))
coordinator.activeSurfaceID = nil   // ← added
coordinator.syncFromDaemon()
```

---

## Restoration flow (after fix)

1. `activeSurfaceID = nil`
2. `syncFromDaemon()` → `applySnapshot()` → `reflectRemoteActivePane()`:
   - reads `tab.activePaneID` from daemon snapshot
   - finds surface for that pane via `surfaceID(forPaneID:in:)`
   - calls `setActiveSurface(surfaceID)` with `suppressActivePaneSync = true`
3. `snapshotChanged` notification → `reloadIfNeeded(force: true)` → `ensureActivePane`
4. `ensureActivePane`: `activeSurfaceID` is now the correct surface → `focusTerminal()` called ✓

---

## Why it may still not work

Not confirmed. Possible remaining issues:
- **Mapping failure**: `surfaceID(forPaneID:in:)` uses `leaf.surfaceID` (not `leaf.activeSurfaceID`) — could fail for linked panes or panes with active surface override
- **AppKit auto-focus**: During pane container rebuild, AppKit might auto-assign first responder to the first terminal view, calling `terminalHostDidChangeFocus` → `setActiveSurface` with wrong surface AFTER `reflectRemoteActivePane` ran
- **Additional bypass paths**: Other code paths in `MainExecutor` or elsewhere that call `requestDaemon(.selectTab/selectWorkspace)` + `syncFromDaemon()` without nil-ing `activeSurfaceID`
- **`nextTab`/`prevTab` command**: Line 717 in `MainExecutor` — fixed. But check if there are tmux-compat command aliases that route differently

---

## Files to read before resuming

- `Apps/Harness/Sources/HarnessApp/Services/ActivePaneService.swift` — `ensureActivePane`, `reflectRemoteActivePane`, `setActiveSurface`
- `Apps/Harness/Sources/HarnessApp/Services/DaemonSyncService.swift` — `applySnapshot`, `structureFingerprint`
- `Apps/Harness/Sources/HarnessApp/Services/SessionLifecycleService.swift` — all select* functions
- `Apps/Harness/Sources/HarnessApp/Services/MainExecutor.swift` — keyboard shortcut handlers
- `Apps/Harness/Sources/HarnessApp/UI/Chrome/ContentAreaViewController.swift` — `reloadIfNeeded`, `ensureActivePane` call site
- `Packages/HarnessTerminalKit/Sources/HarnessTerminalKit/HarnessTerminalSurfaceView+Input.swift` — `becomeFirstResponder` → focus callback chain
- `Apps/Harness/Sources/HarnessApp/Services/SessionCoordinator+HostDelegate.swift` — `terminalHostDidChangeFocus` → `setActiveSurface`

---

## Competitive research (from Agy)

| Tool | Focus storage | Mechanism |
|------|--------------|-----------|
| tmux | Daemon in-memory | `window.active_pane` pointer per session |
| Zellij | Cache KDL files | `pane focus=true` attribute, auto-serialized |
| Warp | SQLite DB | `activeTerminalInstanceId` per workspace |
| VS Code | SQLite `state.vscdb` | `activeTerminalGroupId` + `activeTerminalInstanceId` |
| Zed | SQLite DB | Pane split tree with active flag |

Harness uses daemon-authoritative model (like tmux/Zellij) — correct approach. The bug is purely in GUI-side state not being cleared on switch.
