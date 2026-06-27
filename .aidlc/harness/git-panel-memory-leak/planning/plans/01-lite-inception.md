# Plan: Lite Inception - Memory Leak & CPU Sweep

## Status: Completed

## Objective
Thoroughly audit and optimize the Harness app sidebar view controllers (specifically [GitPanelView.swift](file:///Users/supavit.cho/Git/Personal/harness-terminal/Apps/Harness/Sources/HarnessApp/UI/Git/GitPanelView.swift), [WorkspaceFileTreeView.swift](file:///Users/supavit.cho/Git/Personal/harness-terminal/Apps/Harness/Sources/HarnessApp/UI/FileTree/WorkspaceFileTreeView.swift), and [FileViewerViewController.swift](file:///Users/supavit.cho/Git/Personal/harness-terminal/Apps/Harness/Sources/HarnessApp/UI/FileEditor/FileViewerViewController.swift)) to eliminate redundant UI rebuilds, NSTextField accumulation, memory leaks, and CPU spikes.

## Decision Reference
**Based on decisions from**: [../decisions/01-lite-inception.md](file:///Users/supavit.cho/Git/Personal/harness-terminal/.aidlc/harness/git-panel-memory-leak/planning/decisions/01-lite-inception.md)

## Task Breakdown

### Phase 1: Audit and Analysis - Status: Completed
- [x] **Task 1.1**: Audit [GitPanelView.swift](file:///Users/supavit.cho/Git/Personal/harness-terminal/Apps/Harness/Sources/HarnessApp/UI/Git/GitPanelView.swift) for how often `refresh()` is called, checking how FS events trigger it and verifying what data objects are created.
- [x] **Task 1.2**: Audit [WorkspaceFileTreeView.swift](file:///Users/supavit.cho/Git/Personal/harness-terminal/Apps/Harness/Sources/HarnessApp/UI/FileTree/WorkspaceFileTreeView.swift) and [FileViewerViewController.swift](file:///Users/supavit.cho/Git/Personal/harness-terminal/Apps/Harness/Sources/HarnessApp/UI/FileEditor/FileViewerViewController.swift) for unconditional stack rebuilds or leak patterns (such as block observers or gestures).

### Phase 2: Implementation - Status: Completed
- [x] **Task 2.1**: Implement a state caching gate in [GitPanelView.swift](file:///Users/supavit.cho/Git/Personal/harness-terminal/Apps/Harness/Sources/HarnessApp/UI/Git/GitPanelView.swift) (tracking branch, numstat, porcelain, log, worktrees, repos) to skip tearing down and rebuilding `changesStack`, `historyStack`, `worktreesStack`, and `reposStack` if no state changed.
- [x] **Task 2.2**: Optimize memory deallocation in [GitPanelView.swift](file:///Users/supavit.cho/Git/Personal/harness-terminal/Apps/Harness/Sources/HarnessApp/UI/Git/GitPanelView.swift) by ensuring targets and gestures are cleaned up or using weak bindings.
- [x] **Task 2.3**: If Phase 1 audits reveal other redundant rebuilds, implement equivalent caching gates or optimization structures in those views.

### Phase 3: Verification & Review - Status: Completed
- [x] **Task 3.1**: Build the app using `make debug` or `make preview` to verify successful compilation.
- [x] **Task 3.2**: Run the app and verify the object count (e.g. `heap <PID> -s | grep NSTextField`) is stable under file system changes or simulated activity.
- [x] **Task 3.3**: Execute the Harness test suites (`swift test`) and stability/memory robot tests (`Tests/robot/memory_leak_guards.robot`) to verify no regressions.

## Success Criteria (Process Validation)
- [x] Decisions file exists and has been approved.
- [x] Gated checks prevent redundant UI rebuilds in GitPanelView and other audited view controllers.
- [x] App compiles cleanly without concurrency or deprecation warnings.
- [x] Heap analysis confirms `NSTextField` count does not accumulate rapidly under file updates.
- [x] All unit and UI robot tests pass successfully.
