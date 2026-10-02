# Graph Summary — kouen-terminal
_Auto-generated from GRAPH_REPORT.md · do not edit manually_
_Regen: `graphify update .`_

## Summary
- 20348 nodes · 55173 edges · 2019 communities (635 shown, 1384 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8231 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `50ab333d`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).


## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 342 edges
2. `i()` - 321 edges
3. `a()` - 284 edges
4. `t()` - 253 edges
5. `SessionCoordinator` - 235 edges
6. `TerminalEmulator` - 229 edges
7. `u()` - 219 edges
8. `SurfaceRegistry` - 217 edges
9. `DaemonClient` - 210 edges
10. `IPCRequest` - 208 edges


## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `NSView` - bridges 60 areas (189 edges)
2. `KouenPaths` - bridges 59 areas (149 edges)
3. `AgentKind` - bridges 57 areas (166 edges)
4. `SessionCoordinator` - bridges 53 areas (235 edges)
5. `Process` - bridges 51 areas (105 edges)
6. `SessionSnapshot` - bridges 46 areas (181 edges)
7. `i()` - bridges 43 areas (321 edges)
8. `DaemonClient` - bridges 43 areas (210 edges)
9. `SurfaceRegistry` - bridges 39 areas (217 edges)

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
