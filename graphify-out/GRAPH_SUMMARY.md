# Graph Summary — harness-terminal
_Auto-generated from GRAPH_REPORT.md · do not edit manually_
_Regen: `graphify update .`_

## Summary
- 14577 nodes · 31198 edges · 3732 communities (1230 shown, 2502 thin omitted)
- Extraction: 89% EXTRACTED · 11% INFERRED · 0% AMBIGUOUS · INFERRED: 3427 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `39c0c02b`
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


## Surprising Connections (you probably didn't know these)
- `SUI` --calls--> `Color`  [INFERRED]
  Packages/HarnessOnboarding/Sources/HarnessOnboarding/Design/ImmersivePalette.swift → Apps/Harness/Sources/HarnessApp/Settings/SwiftUI/SettingsColorsView.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/DaemonSyncService.swift → Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/RemoteHostsService.swift → Packages/HarnessCore/Sources/HarnessCore/Remote/RemoteHostStore.swift
- `ThemeImportController` --calls--> `ThemeFileService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/ThemeImportController.swift → Packages/HarnessTheme/Sources/HarnessTheme/ThemeFileService.swift
- `GitHubCLIClient` --calls--> `Process`  [INFERRED]
  Packages/HarnessCore/Sources/HarnessCore/GitHub/GitHubCLIClient.swift → Apps/Harness/Sources/HarnessApp/UI/CommandPalette/CommandPaletteController.swift


_Full map → GRAPH_REPORT.md · query: `graphify query "..."`_
