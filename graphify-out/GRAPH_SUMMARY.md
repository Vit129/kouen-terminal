# Graph Summary — kouen-terminal
_Auto-generated from GRAPH_REPORT.md · do not edit manually_
_Regen: `graphify update .`_

## Summary
- 14818 nodes · 33001 edges · 3391 communities (921 shown, 2470 thin omitted)
- Extraction: 89% EXTRACTED · 11% INFERRED · 0% AMBIGUOUS · INFERRED: 3686 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `4989bc0a`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).


## God Nodes (most connected - your core abstractions)
1. `SurfaceRegistry` - 176 edges
2. `SessionEditor` - 171 edges
3. `IPCRequest` - 171 edges
4. `DaemonClient` - 153 edges
5. `AnyCodable` - 147 edges
6. `SessionCoordinator` - 124 edges
7. `KouenTerminalSurfaceView` - 124 edges
8. `JSONRPCError` - 112 edges
9. `KouenPaths` - 109 edges
10. `Command` - 107 edges


## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 151 areas (171 edges)
2. `Command` - bridges 100 areas (107 edges)
3. `IPCResponse` - bridges 60 areas (82 edges)
4. `SessionCoordinator` - bridges 56 areas (124 edges)
5. `MenuTarget` - bridges 53 areas (60 edges)
6. `SpecialKey` - bridges 52 areas (56 edges)
7. `SurfaceRegistry` - bridges 50 areas (176 edges)
8. `EngineConformanceTests` - bridges 50 areas (76 edges)
9. `KouenPaths` - bridges 45 areas (109 edges)

## Surprising Connections (you probably didn't know these)
- `SUI` --calls--> `Color`  [INFERRED]
  Packages/KouenOnboarding/Sources/KouenOnboarding/Design/ImmersivePalette.swift → Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsColorsView.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/RemoteHostsService.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `ThemeImportController` --calls--> `ThemeFileService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/ThemeImportController.swift → Packages/KouenTheme/Sources/KouenTheme/ThemeFileService.swift
- `WorktreeAutoIsolateService` --calls--> `WorktreeManager`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/WorktreeAutoIsolateService.swift → Packages/KouenCore/Sources/KouenCore/Worktree/WorktreeManager.swift


_Full map → GRAPH_REPORT.md · query: `graphify query "..."`_
