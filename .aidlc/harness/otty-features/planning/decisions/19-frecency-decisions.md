# Decision Record: Phase 19 — Frecency Directory Jumping in Harness

## Status: Decided

## Background
- **What is Frecency Directory Jumping?** A feature to track directory visits, calculate their frecency score, and allow the user to jump directly to any directory via a fuzzy picker panel.
- **Goal**: Implement a persistent store (`frecency-dirs.json`), update it on PTY CWD change notifications, and show a fuzzy picker panel on Cmd+Shift+J to execute a `cd` command in the active session.

---

## Outstanding Decisions

### Decision 1: Frecency Score Computation
**Context**: We need to score directories by frequency and recency.
**Formula**: `score = count / log(1.0 + max(1.0, seconds_since_last_visit))`
- **Frequency**: Every time the shell tracker updates CWD to a directory, we increment its visit count.
- **Recency**: Elapsed time in seconds since the last visit.
- **Guard**: Prevent division by zero if visited instantly by using `max(1.0, seconds_since_last_visit)`.
**Rationale**: This formula prioritizes frequently and recently visited directories. Using a natural log scaling for recency avoids over-discounting slightly older but highly frequent paths.

---

### Decision 2: Integration with CWD Update Event
**Context**: Where should we update the frecency records?
**Decision**: In `SessionCoordinator+HostDelegate.swift`:
- `surfaceShellTrackerDidUpdateCwd(_:cwd:)` is called when a pane's shell updates CWD.
- `terminalHostDidChangeWorkingDirectory(_:surfaceID:)` is called on other folder changes.
We will invoke `FrecencyDirectoryStore.shared.recordVisit(path: cwd)` inside these two delegate methods.
**Rationale**: This ensures all directory changes across all terminal hosts are tracked automatically without introducing ad-hoc event observers.

---

### Decision 3: Directory Picker UI Architecture
**Context**: How to structure the directory fuzzy picker?
**Decision**: Follow the same architecture as `RecipePickerController` and `CommandPaletteController` using `NSPanel` + `SwiftUI` hosted inside `DirectoryPickerController`.
- On selection, send `cd <path>\n` to the active PTY.
**How to send command**:
```swift
if let surfaceID = SessionCoordinator.shared.activeSurfaceID,
   let host = SessionCoordinator.shared.terminalHostIfExists(for: surfaceID) {
    host.sendInput(("cd \(path)\n").data(using: .utf8) ?? Data())
}
```
**Rationale**: This ensures directory jumping is fast, native, and behaves exactly like other pickers.

---

## Decision Summary

| Decision | Chosen Option | Rationale | Impact |
|----------|---------------|-----------|--------|
| Score Formula | `count / log(1 + max(1, age))` | Simple, effective, and safe from div-by-zero | Low |
| Event Hook | HostDelegate CWD methods | Centralized observation point in SessionCoordinator | Medium |
| Execution | Direct PTY send input | Cleanest PTY write path | Medium |
