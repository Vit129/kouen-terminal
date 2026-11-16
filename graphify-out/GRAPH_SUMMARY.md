# Graph Summary — performance-hardening-2026-11-16
_Auto-generated from GRAPH_REPORT.md · do not edit manually_
_Regen: `graphify update .`_

## Summary
- 20213 nodes · 58315 edges · 2679 communities (1546 shown, 1133 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8543 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `1e594b95`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).


## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 346 edges
2. `i()` - 318 edges
3. `a()` - 282 edges
4. `SessionCoordinator` - 235 edges
5. `SurfaceRegistry` - 230 edges
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
1. `IPCRequest` - bridges 187 areas (211 edges)
2. `Command` - bridges 102 areas (108 edges)
3. `AgentKind` - bridges 83 areas (176 edges)
4. `IPCResponse` - bridges 79 areas (107 edges)
5. `KouenTerminalSurfaceView` - bridges 75 areas (346 edges)
6. `SessionCoordinator` - bridges 64 areas (235 edges)
7. `NSView` - bridges 64 areas (193 edges)
8. `KouenGridTerminal` - bridges 63 areas (117 edges)
9. `SurfaceRegistry` - bridges 62 areas (230 edges)

## Surprising Connections (you probably didn't know these)
- `.selectedHost` --references--> `RemoteHost`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRemoteView.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.terms` --calls--> `SearchMatcher`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/UI/History/HistorySearchEvidence.swift → Packages/KouenCore/Sources/KouenCore/Search/SearchMatcher.swift
- `.waitingCount` --references--> `FleetSessionItem`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/UI/Terminal/FleetViewModel.swift → Packages/KouenCore/Sources/KouenCore/Fleet/FleetSessionList.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/RemoteHostsService.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift


_Full map → GRAPH_REPORT.md · query: `graphify query "..."`_
