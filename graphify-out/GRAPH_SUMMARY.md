# Graph Summary — kouen-terminal
_Auto-generated from GRAPH_REPORT.md · do not edit manually_
_Regen: `graphify update .`_

## Summary
- 21350 nodes · 56931 edges · 3886 communities (1557 shown, 2329 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8413 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `66ecde74`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).


## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 345 edges
2. `i()` - 321 edges
3. `a()` - 284 edges
4. `t()` - 253 edges
5. `SessionCoordinator` - 236 edges
6. `TerminalEmulator` - 229 edges
7. `SurfaceRegistry` - 223 edges
8. `KouenCLI` - 220 edges
9. `u()` - 219 edges
10. `DaemonClient` - 210 edges


## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 185 areas (206 edges)
2. `Command` - bridges 102 areas (108 edges)
3. `t()` - bridges 90 areas (253 edges)
4. `AgentKind` - bridges 80 areas (177 edges)
5. `IPCResponse` - bridges 77 areas (101 edges)
6. `KouenTerminalSurfaceView` - bridges 76 areas (345 edges)
7. `KouenPaths` - bridges 69 areas (150 edges)
8. `KouenGridTerminal` - bridges 66 areas (117 edges)
9. `SessionCoordinator` - bridges 64 areas (236 edges)

## Surprising Connections (you probably didn't know these)
- `.selectedHost` --references--> `RemoteHost`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRemoteView.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/RemoteHostsService.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.selectWorkspace(byIndex:)` --references--> `SessionSnapshot`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/SessionCoordinator.swift → Packages/KouenIPC/Sources/KouenIPC/SessionSnapshot.swift
- `.heightArg` --calls--> `keys`  [INFERRED]
  Packages/KouenTerminalEngine/Sources/KouenTerminalEngine/Images/ITerm2InlineImage.swift → Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRootView.swift


_Full map → GRAPH_REPORT.md · query: `graphify query "..."`_
