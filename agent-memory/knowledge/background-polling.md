# Background Polling & Snapshot Fanout — P22

Created: 2026-06-16. Covers the three always-on background paths investigated in P22 long-session responsiveness work.

---

## 1. SurfaceShellTracker (proc tree walk)

**File:** `Apps/Harness/Sources/HarnessApp/Services/SurfaceShellTracker.swift`

- Runs a `DispatchSourceTimer` on `.main` at 500ms (active) / 2s (backgrounded)
- Each tick: `computeSurfaceCwds()` on `scanQueue` (off-main) → `applyCwds()` on `@MainActor`
- `applyCwds` only calls `coordinator.surfaceShellTrackerDidUpdateCwd` when cwd actually changed
- `scanning` flag prevents piling up ticks if a scan exceeds the interval
- Idle back-off controlled by `AppIdleThrottle` (`screensDidSleepNotification` / wake)

**Instrumented counter:** `PerfCounters.shared.shellTrackerTicks` / `.shellTrackerCwdChanges`

In steady state (user idle, no cd commands): expect >90% no-op ticks. If `cwdChanges/ticks > 0.1` in a long session, users are actively navigating.

---

## 2. DaemonSyncService.startMetadataRefresh (5-s loop)

**File:** `Apps/Harness/Sources/HarnessApp/Services/DaemonSyncService.swift`

```
startMetadataRefresh()
  └─ Task (background) — loops every 5s
      ├─ guard !AppIdleThrottle.shared.isSuspended  ← skip when screen asleep
      ├─ collect tabs from active workspace
      ├─ for each unique cwd: git.refresh(tab:)      ← shells out to `git branch`
      ├─ guard !updates.isEmpty                      ← skip sync when no branch changed
      └─ MainActor: logIfFailed(.updateTabGitBranch) + coord.syncFromDaemon(metadataOnly:true)
```

**Bug fixed (P22.2):** Before the fix, `syncFromDaemon(metadataOnly: true)` was called unconditionally even when `updates` was empty — causing a full metadata snapshot pull + `snapshotChanged` fanout every 5s regardless of any git state change.

**Instrumented counters:** `metadataRefreshWakeups`, `metadataRefreshSkippedIdle`, `metadataRefreshGitChecks`, `metadataRefreshSyncFired`, `metadataRefreshSyncSkipped`

---

## 3. snapshotChanged Fanout

**Posted by:** `DaemonSyncService.applySnapshot(_:metadataOnly:)` via `NotificationCenter.default.post`

**userInfo keys:**
- `"revision"` — daemon snapshot revision (Int)
- `"structureChanged"` — Bool; true when pane tree / session layout changed
- `"chromeChanged"` — Bool; true when theme/opacity changed (same as `!metadataOnly`)
- `"metadataOnly"` — Bool; true for branch/cwd/title-only refreshes

**Consumers and their gate logic (post-P22.4 fixes):**

| Consumer | File | Gate |
|---|---|---|
| `MainSplitViewController` | `UI/Chrome/MainSplitViewController.swift` | Routes to `sidebar.refreshMetadata()` vs `sidebar.reload()` |
| `HarnessSidebarPanelViewController` | `UI/Sidebar/…` | **No direct observer** — driven only by MainSplitViewController (removed double-sub P22.4) |
| `BoardViewController` | `UI/Sidebar/BoardViewController.swift` | `guard metadataOnly != true` before `reload()` |
| `NotchPanelController` | `UI/Notch/NotchPanelController.swift` | `guard metadataOnly != true` before `refreshVisibility()` |
| `ContentAreaViewController` | `UI/Chrome/ContentAreaViewController.swift` | Has own `reloadIfNeeded` guard (structure key diff) |

**Double-subscription bug fixed (P22.4):** `HarnessSidebarPanelViewController` had its own `addObserver(selector: #selector(reload), name: snapshotChanged)` alongside `MainSplitViewController` also routing to `sidebar.reload()` — every non-metadata snapshot triggered two full sidebar rebuilds.

---

## 4. PerfCounters — Instrumentation

**File:** `Apps/Harness/Sources/HarnessApp/Services/PerfCounters.swift`

`@MainActor` singleton. Dumps to `harnessStderr` every 30 minutes (rate/hr shown alongside raw counts). Start with `PerfCounters.shared.start()` in `AppDelegate.applicationDidFinishLaunching`.

**Reading the report:**
- `metadataRefreshSyncSkipped / metadataRefreshWakeups` ≈ 1.0 → git branches stable (good)
- `shellTrackerCwdChanges / shellTrackerTicks` ≈ 0 → user idle (expected)
- `fanoutSidebarReload` high but `snapshotAppliedStructural` low → revision subscription firing too often (investigate daemon side)
- `snapshotAppliedMetadataOnly` ≫ `metadataRefreshSyncFired` → other callers posting metadata syncs (MenuBarController, AppIdleThrottle wake, etc.)

---

## Known Non-P22 Callers of syncFromDaemon

These callers are intentional (user-triggered, wake-from-sleep, etc.) and should NOT be guarded:
- `AppIdleThrottle.shared` — wake from screen sleep → single resync
- `MenuBarController` — on menu open (metadataOnly: true)
- `AppDelegate` — startup sync
- `SessionLifecycleService` — session create/close/select
- `HarnessSidebarPanelViewController+SessionMenu` — user-triggered session actions
- `ScriptAPI` — scripted `harness.commands.run`
