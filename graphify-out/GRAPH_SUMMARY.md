# Graph Summary — session-history-ux-2026-11-17
_Auto-generated from GRAPH_REPORT.md · do not edit manually_
_Regen: `graphify update .`_

## Summary
- 20521 nodes · 59251 edges · 2677 communities (1544 shown, 1133 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8803 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `295f8e68`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).


## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 346 edges
2. `i()` - 318 edges
3. `a()` - 282 edges
4. `SessionCoordinator` - 237 edges
5. `TerminalEmulator` - 235 edges
6. `SurfaceRegistry` - 232 edges
7. `DaemonClient` - 217 edges
8. `u()` - 217 edges
9. `IPCRequest` - 211 edges
10. `KouenCLI` - 210 edges


## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 189 areas (211 edges)
2. `Command` - bridges 102 areas (108 edges)
3. `AgentKind` - bridges 89 areas (186 edges)
4. `IPCResponse` - bridges 79 areas (107 edges)
5. `KouenTerminalSurfaceView` - bridges 71 areas (346 edges)
6. `SessionCoordinator` - bridges 67 areas (237 edges)
7. `NSView` - bridges 65 areas (193 edges)
8. `SurfaceRegistry` - bridges 64 areas (232 edges)
9. `KouenGridTerminal` - bridges 64 areas (117 edges)

## Surprising Connections (you probably didn't know these)
- `.selectedHost` --references--> `RemoteHost`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRemoteView.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.terms` --calls--> `SearchMatcher`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/UI/History/HistorySearchEvidence.swift → Packages/KouenCore/Sources/KouenCore/Search/SearchMatcher.swift
- `.cleanPrompt` --references--> `AgentSessionRecord`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/UI/History/HistorySessionDetailsView.swift → Packages/KouenCore/Sources/KouenCore/Agents/AgentHistoryScanner.swift
- `.waitingCount` --references--> `FleetSessionItem`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/UI/Terminal/FleetViewModel.swift → Packages/KouenCore/Sources/KouenCore/Fleet/FleetSessionList.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift


_Full map → GRAPH_REPORT.md · query: `graphify query "..."`_
