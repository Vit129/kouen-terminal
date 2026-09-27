# Graph Summary — kouen-terminal
_Auto-generated from GRAPH_REPORT.md · do not edit manually_
_Regen: `graphify update .`_

## Summary
- 20336 nodes · 54888 edges · 2055 communities (634 shown, 1421 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8141 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `e0409fad`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).


## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 343 edges
2. `i()` - 321 edges
3. `a()` - 284 edges
4. `t()` - 253 edges
5. `SessionCoordinator` - 235 edges
6. `TerminalEmulator` - 229 edges
7. `u()` - 219 edges
8. `SurfaceRegistry` - 215 edges
9. `DaemonClient` - 210 edges
10. `IPCRequest` - 208 edges


## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `KouenPaths` - bridges 60 areas (149 edges)
2. `Process` - bridges 55 areas (105 edges)
3. `SessionCoordinator` - bridges 54 areas (235 edges)
4. `AgentKind` - bridges 54 areas (158 edges)
5. `SessionSnapshot` - bridges 46 areas (181 edges)
6. `DaemonClient` - bridges 41 areas (210 edges)
7. `t()` - bridges 39 areas (253 edges)
8. `SurfaceRegistry` - bridges 39 areas (215 edges)
9. `Notification` - bridges 37 areas (67 edges)

## Surprising Connections (you probably didn't know these)
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/RemoteHostsService.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.selectWorkspace(byIndex:)` --references--> `SessionSnapshot`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/SessionCoordinator.swift → Packages/KouenIPC/Sources/KouenIPC/SessionSnapshot.swift
- `ThemeImportController` --calls--> `ThemeFileService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/ThemeImportController.swift → Packages/KouenTheme/Sources/KouenTheme/ThemeFileService.swift
- `WorktreeAutoIsolateService` --calls--> `WorktreeManager`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/WorktreeAutoIsolateService.swift → Packages/KouenCore/Sources/KouenCore/Worktree/WorktreeManager.swift


_Full map → GRAPH_REPORT.md · query: `graphify query "..."`_
