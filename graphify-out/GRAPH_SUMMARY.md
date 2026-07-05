# Graph Summary — harness-readme-fix
_Auto-generated from GRAPH_REPORT.md · do not edit manually_
_Regen: `graphify update .`_

## Summary
- 11906 nodes · 30867 edges · 1356 communities (805 shown, 551 thin omitted)
- Extraction: 89% EXTRACTED · 11% INFERRED · 0% AMBIGUOUS · INFERRED: 3427 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `84c5fdd5`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).


## God Nodes (most connected - your core abstractions)
1. `SessionEditor` - 170 edges
2. `SurfaceRegistry` - 154 edges
3. `IPCRequest` - 151 edges
4. `DaemonClient` - 142 edges
5. `SessionCoordinator` - 124 edges
6. `HarnessTerminalSurfaceView` - 124 edges
7. `AnyCodable` - 109 edges
8. `Command` - 107 edges
9. `TerminalScreen` - 100 edges
10. `TerminalHostView` - 99 edges


## Cross-Cutting Nodes (span the most distinct areas of the codebase)
A high-degree node isn't always architecturally central - a widely-used
utility/config file can rack up more edges than a real coupler while only
ever touching one area. This ranks by how many DIFFERENT communities a
node's neighbors span, not by raw edge count.
1. `IPCRequest` - bridges 132 areas (151 edges)
2. `Command` - bridges 99 areas (107 edges)
3. `SessionCoordinator` - bridges 57 areas (124 edges)
4. `MenuTarget` - bridges 54 areas (60 edges)
5. `IPCResponse` - bridges 51 areas (69 edges)
6. `SpecialKey` - bridges 51 areas (56 edges)
7. `EngineConformanceTests` - bridges 50 areas (76 edges)
8. `AgentKind` - bridges 43 areas (92 edges)
9. `CommandParserTests` - bridges 42 areas (43 edges)

## Surprising Connections (you probably didn't know these)
- `SUI` --calls--> `Color`  [INFERRED]
  Packages/HarnessOnboarding/Sources/HarnessOnboarding/Design/ImmersivePalette.swift → Apps/Harness/Sources/HarnessApp/Settings/SwiftUI/SettingsColorsView.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/DaemonSyncService.swift → Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/RemoteHostsService.swift → Packages/HarnessCore/Sources/HarnessCore/Remote/RemoteHostStore.swift
- `ThemeImportController` --calls--> `ThemeFileService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/ThemeImportController.swift → Packages/HarnessTheme/Sources/HarnessTheme/ThemeFileService.swift
- `WorktreeAutoIsolateService` --calls--> `WorktreeManager`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/WorktreeAutoIsolateService.swift → Packages/HarnessCore/Sources/HarnessCore/Worktree/WorktreeManager.swift


_Full map → GRAPH_REPORT.md · query: `graphify query "..."`_
