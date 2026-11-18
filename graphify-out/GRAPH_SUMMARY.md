# Graph Summary — kouen-terminal
_Auto-generated from GRAPH_REPORT.md · do not edit manually_
_Regen: `graphify update .`_

## Summary
- 20580 nodes · 59323 edges · 2835 communities (1585 shown, 1250 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 8863 edges (avg confidence: 0.74)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `b4c2e11c`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).


## God Nodes (most connected - your core abstractions)
1. `KouenTerminalSurfaceView` - 346 edges
2. `i()` - 318 edges
3. `a()` - 282 edges
4. `SessionCoordinator` - 237 edges
5. `SurfaceRegistry` - 236 edges
6. `TerminalEmulator` - 235 edges
7. `DaemonClient` - 217 edges
8. `u()` - 217 edges
9. `KouenCLI` - 216 edges
10. `IPCRequest` - 212 edges


## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 191 areas (212 edges)
2. `Command` - bridges 101 areas (108 edges)
3. `AgentKind` - bridges 82 areas (186 edges)
4. `IPCResponse` - bridges 81 areas (108 edges)
5. `KouenTerminalSurfaceView` - bridges 77 areas (346 edges)
6. `SurfaceRegistry` - bridges 67 areas (236 edges)
7. `SessionCoordinator` - bridges 66 areas (237 edges)
8. `NSView` - bridges 64 areas (193 edges)
9. `KouenGridTerminal` - bridges 63 areas (117 edges)

## Surprising Connections (you probably didn't know these)
- `.selectedHost` --references--> `RemoteHost`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRemoteView.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift
- `.terms` --calls--> `SearchMatcher`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/UI/History/HistorySearchEvidence.swift → Packages/KouenCore/Sources/KouenCore/Search/SearchMatcher.swift
- `.cleanPrompt` --references--> `AgentSessionRecord`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/UI/History/HistorySessionDetailsView.swift → Packages/KouenCore/Sources/KouenCore/Agents/AgentHistoryScanner.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/DaemonSyncService.swift → Packages/KouenCore/Sources/KouenCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Kouen/Sources/KouenApp/Services/RemoteHostsService.swift → Packages/KouenCore/Sources/KouenCore/Remote/RemoteHostStore.swift


_Full map → GRAPH_REPORT.md · query: `graphify query "..."`_
