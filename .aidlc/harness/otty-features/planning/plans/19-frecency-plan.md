# Implementation Plan: Phase 19 — Frecency Directory Jumping in Harness

## Status: Planning

## Objective
Implement Phase 19 (Frecency directory jumping) under `Dev Only` / `SDLC` mode:
- Create `FrecencyDirectoryStore` to track and rank visited directories.
- Wire directory tracking into `SessionCoordinator` CWD delegates.
- Implement `DirectoryPickerController` as an NSPanel fuzzy picker.

## Feature Implementation Plan

### Task 2.1: Create `FrecencyDirectoryStore.swift`
- **Location**: `Apps/Harness/Sources/HarnessApp/Services/FrecencyDirectoryStore.swift`
- **Scope**:
  - `@MainActor final class FrecencyDirectoryStore`
  - `FrecencyEntry` struct: `{ path: String, count: Double, lastVisited: Date }`
  - Backing file at `~/Library/Application Support/Harness/frecency-dirs.json`
  - Methods:
    - `recordVisit(path: String)`: standardizes path (expanding tilde or cleaning up), updates count, and resets lastVisited date.
    - `ranked() -> [String]`: sorts entries by `score = count / log(1.0 + max(1.0, seconds_since_last_visit))` and returns standard paths.

### Task 2.2: Wire Visit Recording in `SessionCoordinator`
- **Location**: `Apps/Harness/Sources/HarnessApp/Services/SessionCoordinator+HostDelegate.swift`
- **Scope**:
  - In `terminalHostDidChangeWorkingDirectory(_:surfaceID:)`, call `FrecencyDirectoryStore.shared.recordVisit(path: path)`
  - In `surfaceShellTrackerDidUpdateCwd(_:cwd:)`, call `FrecencyDirectoryStore.shared.recordVisit(path: cwd)`

### Task 2.3: Create `DirectoryPickerController.swift`
- **Location**: `Apps/Harness/Sources/HarnessApp/UI/Shared/DirectoryPickerController.swift`
- **Scope**:
  - Replace stub with full implementation.
  - `DirectoryPickerController` panel launcher.
  - `DirectoryPickerModel` (`@Observable` class, holds ranked items, filters by query).
  - `DirectoryPickerView` (SwiftUI view displaying folder name, short path, score).
  - On activation: send `cd <path>\n` to active PTY.

## Verification
- Confirm project compiles successfully.
- Verify `frecency-dirs.json` is updated when navigating directories in PTY.
- Launch directory picker via `Cmd+Shift+J`, search, select directory, and verify it executes `cd <path>`.
