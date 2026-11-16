# Graph Summary — close-release-2026-11-16
_Auto-generated from GRAPH_REPORT.md · do not edit manually_
_Regen: `graphify update .`_

## Summary
- 20298 nodes · 58543 edges · 2667 communities (1540 shown, 1127 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8605 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `e36acbfb`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).


## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 346 edges
2. `i()` - 318 edges
3. `a()` - 282 edges
4. `SessionCoordinator` - 235 edges
5. `SurfaceRegistry` - 231 edges
6. `TerminalEmulator` - 229 edges
7. `DaemonClient` - 217 edges
8. `u()` - 217 edges
9. `IPCRequest` - 211 edges
10. `KouenCLI` - 210 edges


## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 191 areas (211 edges)
2. `Command` - bridges 102 areas (108 edges)
3. `IPCResponse` - bridges 82 areas (107 edges)
4. `AgentKind` - bridges 81 areas (176 edges)
5. `KouenTerminalSurfaceView` - bridges 73 areas (346 edges)
6. `SessionCoordinator` - bridges 69 areas (235 edges)
7. `SurfaceRegistry` - bridges 66 areas (231 edges)
8. `KouenGridTerminal` - bridges 66 areas (117 edges)
9. `NSView` - bridges 64 areas (193 edges)

## Surprising Connections (you probably didn't know these)
- `.selectedHost` --references--> `RemoteHost`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRemoteView.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.terms` --calls--> `SearchMatcher`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/UI/History/HistorySearchEvidence.swift → Packages/KouenCore/Sources/KouenCore/Search/SearchMatcher.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/RemoteHostsService.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.selectWorkspace(byIndex:)` --references--> `SessionSnapshot`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/SessionCoordinator.swift → Packages/KouenIPC/Sources/KouenIPC/SessionSnapshot.swift


_Full map → GRAPH_REPORT.md · query: `graphify query "..."`_
