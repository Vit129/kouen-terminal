# Decision Record: Lite Inception - Memory Leak Fixes

## Status: Decided

## Background
- **What is this feature?** A performance improvement task targeting massive memory leak/growth (Harness memory usage climbing up to 2 GB) after long sessions or intensive file system operations.
- **What already exists?** Prior memory audit fixes (in `v3.9.4` build 170) resolved leaks in `TerminalPaneRegistry`, `SessionCoordinator` AI controllers, and `BrowserPaneView`. However, the app still exhibits large heap growth (specifically `NSTextField` and `NSTextFieldSimpleLabel` instances) during normal usage.
- **What is missing?** Differential reload gating in [GitPanelView.swift](file:///Users/supavit.cho/Git/Personal/harness-terminal/Apps/Harness/Sources/HarnessApp/UI/Git/GitPanelView.swift) and potentially other sidebar views. The panel currently tears down and recreates all rows in `changesStack` and `historyStack` unconditionally on any file system change.

---

## Outstanding Decisions

### Decision 1: Scope of Memory Leak Fixes
**Context**: We need to determine the scope of this performance optimization.

**Options**:
- **A) GitPanelView Only**: Focus solely on [GitPanelView.swift](file:///Users/supavit.cho/Git/Personal/harness-terminal/Apps/Harness/Sources/HarnessApp/UI/Git/GitPanelView.swift) since it is the most frequent producer of `NSTextField` objects under high FSEvents activity.
  - *Rationale*: Safe, targeted, minimal risk of regressions in other views.
  - *Consequences*: Might miss other secondary `NSTextField` leaks in other view controllers if any exist.

- **B) GitPanelView + Sidebar Sweep (Recommended)**: Fix [GitPanelView.swift](file:///Users/supavit.cho/Git/Personal/harness-terminal/Apps/Harness/Sources/HarnessApp/UI/Git/GitPanelView.swift) and also review other active sidebar elements like [WorkspaceFileTreeView.swift](file:///Users/supavit.cho/Git/Personal/harness-terminal/Apps/Harness/Sources/HarnessApp/UI/FileTree/WorkspaceFileTreeView.swift) or [FileViewerViewController.swift](file:///Users/supavit.cho/Git/Personal/harness-terminal/Apps/Harness/Sources/HarnessApp/UI/FileEditor/FileViewerViewController.swift) to verify they don't rebuild their UI unconditionally.
  - *Rationale*: Comprehensive performance cleanup, ensuring no other simple layout/rebuild leaks slip through.
  - *Consequences*: Takes slightly more time to audit, but provides a stronger guarantee.

- **C) Other** (please describe your preferred approach)

**Recommendation**: Option B because it is more thorough and prevents similar leaks in other side panels.

**Decision**: Option B (GitPanelView + Sidebar Sweep) - Inspect all sidebar views/panels for redundant rebuilds and leaks.

---

### Decision 2: GitPanelView Rebuild Optimization Strategy
**Context**: [GitPanelView.swift](file:///Users/supavit.cho/Git/Personal/harness-terminal/Apps/Harness/Sources/HarnessApp/UI/Git/GitPanelView.swift) currently destroys and recreates all stack views on any update. We need to decide how to optimize this refresh loop.

**Options**:
- **A) State Caching & Gate (Recommended)**: Cache the previous git outputs (`porcelain`, `log`, `branch`, `numstat`) and skip rebuilding the stack views entirely if the new outputs match the cached ones.
  - *Rationale*: Extremely simple to implement, low risk, matching the proven pattern used in [BoardViewController.swift](file:///Users/supavit.cho/Git/Personal/harness-terminal/Apps/Harness/Sources/HarnessApp/UI/Sidebar/BoardViewController.swift).
  - *Consequences*: When the git status actually changes, the entire view hierarchy is still rebuilt in one shot. However, this is acceptable because changes occur far less frequently than file system events/ticks.

- **B) Row-Level Diffing**: Track rows by their file paths or commit hashes and perform a surgical update (insert, delete, or modify individual row views) instead of a complete teardown of the stack view.
  - *Rationale*: Minimizes view allocations to the absolute minimum required.
  - *Consequences*: High complexity, difficult to maintain in AppKit `NSStackView`, high potential for layout/focus bugs.

- **C) Other** (please describe your preferred approach)

**Recommendation**: Option A because it is highly effective, simple, matches the project's existing patterns, and has minimal regression risk.

**Decision**: Option A (State Caching & Gate) - Cache previous states and check before doing full UI teardown.

---

## Decision Summary

| Decision | Chosen Option | Rationale | Impact |
|----------|---------------|-----------|--------|
| Decision 1: Scope | Option B | Comprehensive sweep of all side panels and view controllers to fix all memory/CPU leaks. | High |
| Decision 2: Strategy | Option A | Simplest, most reliable way to prevent redundant UI rebuilds and leaks, matching BoardViewController. | High |

## Next Steps
1. Create plan file based on these decisions
2. Reference this decision record in the plan
3. Proceed with plan approval and execution
