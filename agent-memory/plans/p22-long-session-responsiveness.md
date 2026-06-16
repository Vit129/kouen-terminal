# P22 — Long-Session Responsiveness Hardening

Status: **planned**
Priority: **P1** — user-visible responsiveness regression after long uptime
Owner surface: HarnessApp, SessionCoordinator, DaemonSyncService, SurfaceShellTracker, UI snapshot observers
Created: 2026-06-16
Scope: background polling, metadata refresh, snapshot fanout, observer/timer lifecycle, long-run profiling
Depends on: P17 (service decomposition), P18 (UI automation), P20 (harness-term agent), existing snapshot bus

---

## Problem

Users report that Harness becomes less responsive after roughly 6+ hours of continuous use.

The current codebase shows several always-on background paths that can accumulate churn over time:

- `SurfaceShellTracker` scans the process tree every 500 ms to refresh cwd state.
- `DaemonSyncService.startMetadataRefresh()` wakes every 5 s, shells out to `git`, and always calls `syncFromDaemon(metadataOnly: true)`.
- `snapshotChanged` broadcasts fan out into sidebar, tab bar, status line, and content refresh paths.

This plan focuses on reducing unnecessary work in the steady state and proving which path is responsible before changing behavior broadly.

---

## Hypotheses

### H1: Metadata refresh is too expensive when nothing changed

`startMetadataRefresh()` performs process + git work on a fixed cadence and still forces a metadata-only snapshot sync even when no branch changed.

### H2: CWD polling is the main long-run CPU drag

`SurfaceShellTracker` runs indefinitely once started and keeps scanning process trees on the main actor every 500 ms, even if the user is idle.

### H3: Snapshot fanout does more UI work than necessary

Metadata-only updates still reach multiple observers that may refresh more state than needed for a branch/cwd/title tick.

### H4: Long-session slowdown may be amplified by retained timers/observers

The app has many long-lived notification observers and timers. Even if each is correct, a repeated refresh storm can look like a leak.

---

## Success Criteria

- App stays responsive after extended continuous use.
- Idle CPU remains stable instead of creeping upward over time.
- Metadata-only updates do not trigger unnecessary full UI rebuilds.
- No new leaks, observer duplication, or timer buildup are introduced.

---

## Workstreams

### P22.1 Instrument the hot paths

Add lightweight counters or logging around:

- metadata refresh wakeups
- git branch refresh calls
- `syncFromDaemon(metadataOnly:)` calls
- `snapshotChanged` UI fanout
- `SurfaceShellTracker` ticks and applyCwds changes

Goal: confirm which loop is actually responsible before changing cadence.

### P22.2 Reduce metadata refresh churn

Refine `DaemonSyncService.startMetadataRefresh()` so it only triggers snapshot sync when there is an actual metadata delta.

Potential changes:

- skip `syncFromDaemon(metadataOnly: true)` when no branch or cwd value changed
- dedupe updates per workspace/tab more aggressively
- consider backoff when the app is idle or the active workspace is unchanged

### P22.3 Throttle or gate cwd process scanning

Revisit `SurfaceShellTracker` polling policy.

Potential changes:

- pause or slow the scan when the app is idle or backgrounded
- avoid main-actor work when the scan result is identical to the previous pass
- keep the process-tree walk off-main and minimize main-thread apply work

### P22.4 Narrow snapshot fanout

Audit `snapshotChanged` consumers and separate:

- structural updates
- metadata-only updates
- cosmetic/theme updates

Goal: metadata-only churn should refresh only the views that truly depend on cwd/title/branch state.

### P22.5 Verify for regressions

Validate the steady-state behavior with:

- `swift build`
- long-run manual use
- targeted UI checks for tab bar, sidebar, status line, and cwd/branch updates

---

## Proposed PBI Breakdown

### PBI-RESP-001: Performance tracing

Add counters/logging to the metadata refresh and cwd tracking paths.

### PBI-RESP-002: Metadata refresh guardrails

Avoid unconditional snapshot sync when branch metadata did not change.

### PBI-RESP-003: Shell tracker idle optimization

Reduce or suspend cwd scanning when it cannot change visible state.

### PBI-RESP-004: Snapshot fanout narrowing

Limit metadata-only refreshes to the minimal UI surface needed.

### PBI-RESP-005: Long-run verification

Confirm the app remains responsive under extended continuous use.

---

## Notes

- Do not start with speculative broad refactors.
- Prove the expensive loop first, then narrow the fix.
- Preserve existing correctness for session selection, cwd updates, and branch display while reducing background churn.

