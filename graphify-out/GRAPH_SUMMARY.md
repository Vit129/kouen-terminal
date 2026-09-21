# Graph Summary — kouen-terminal
_Auto-generated from GRAPH_REPORT.md · do not edit manually_
_Regen: `graphify update .`_

## Summary
- 20170 nodes · 54215 edges · 2132 communities (631 shown, 1501 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8058 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `28585cf2`
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
8. `SurfaceRegistry` - 211 edges
9. `DaemonClient` - 207 edges
10. `IPCRequest` - 207 edges


## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `KouenPaths` - bridges 60 areas (143 edges)
2. `AgentKind` - bridges 55 areas (144 edges)
3. `SessionCoordinator` - bridges 54 areas (235 edges)
4. `Process` - bridges 49 areas (100 edges)
5. `SessionSnapshot` - bridges 47 areas (179 edges)
6. `KouenTerminalSurfaceView` - bridges 39 areas (343 edges)
7. `DaemonClient` - bridges 38 areas (207 edges)
8. `Notification` - bridges 37 areas (66 edges)
9. `SurfaceRegistry` - bridges 36 areas (211 edges)

## Surprising Connections (you probably didn't know these)
- `.selectedHost` --references--> `RemoteHost`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRemoteView.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/RemoteHostsService.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.selectWorkspace(byIndex:)` --references--> `SessionSnapshot`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/SessionCoordinator.swift → Packages/KouenIPC/Sources/KouenIPC/SessionSnapshot.swift
- `ThemeImportController` --calls--> `ThemeFileService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/ThemeImportController.swift → Packages/KouenTheme/Sources/KouenTheme/ThemeFileService.swift


_Full map → GRAPH_REPORT.md · query: `graphify query "..."`_
