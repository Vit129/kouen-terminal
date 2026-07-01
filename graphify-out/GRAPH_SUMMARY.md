# Graph Summary — harness-terminal
_Auto-generated from GRAPH_REPORT.md · do not edit manually_
_Regen: `graphify update .`_

## Summary
- 14861 nodes · 30420 edges · 3088 communities (1087 shown, 2001 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 3021 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `976088c3`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).


## God Nodes (most connected - your core abstractions)
1. `HarnessCore` - 267 edges
2. `Foundation` - 266 edges
3. `data` - 252 edges
4. `XCTest` - 170 edges
5. `SessionEditor` - 166 edges
6. `SurfaceRegistry` - 147 edges
7. `AppKit` - 136 edges
8. `DaemonClient` - 134 edges
9. `IPCRequest` - 132 edges
10. `SessionCoordinator` - 124 edges


## Surprising Connections (you probably didn't know these)
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/DaemonSyncService.swift → Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonSessionService.swift
- `ThemeImportController` --calls--> `ThemeFileService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/ThemeImportController.swift → Packages/HarnessTheme/Sources/HarnessTheme/ThemeFileService.swift
- `WorktreeAutoIsolateService` --calls--> `WorktreeManager`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/WorktreeAutoIsolateService.swift → Packages/HarnessCore/Sources/HarnessCore/Worktree/WorktreeManager.swift
- `handleStartServer()` --calls--> `Process`  [INFERRED]
  Tools/harness/Sources/HarnessCLI/HarnessCLI+Server.swift → Apps/Harness/Sources/HarnessApp/UI/CommandPalette/CommandPaletteController.swift
- `vfork_and_exec()` --calls--> `Process`  [INFERRED]
  Tools/harness/Sources/HarnessCLI/HarnessCLI+Workbench.swift → Apps/Harness/Sources/HarnessApp/UI/CommandPalette/CommandPaletteController.swift


_Full map → GRAPH_REPORT.md · query: `graphify query "..."`_
