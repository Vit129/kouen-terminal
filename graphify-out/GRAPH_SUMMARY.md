# Graph Summary — harness-terminal
_Auto-generated from GRAPH_REPORT.md · do not edit manually_
_Regen: `graphify update .`_

## Summary
- 15060 nodes · 31519 edges · 2921 communities (935 shown, 1986 thin omitted)
- Extraction: 89% EXTRACTED · 11% INFERRED · 0% AMBIGUOUS · INFERRED: 3353 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `587fa906`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).


## God Nodes (most connected - your core abstractions)
1. `Int` - 927 edges
2. `HarnessCore` - 268 edges
3. `Foundation` - 268 edges
4. `XCTest` - 180 edges
5. `SessionEditor` - 170 edges
6. `SurfaceRegistry` - 154 edges
7. `IPCRequest` - 151 edges
8. `DaemonClient` - 142 edges
9. `AppKit` - 139 edges
10. `SessionCoordinator` - 124 edges


## Surprising Connections (you probably didn't know these)
- `SUI` --calls--> `Color`  [INFERRED]
  Packages/HarnessOnboarding/Sources/HarnessOnboarding/Design/ImmersivePalette.swift → Apps/Harness/Sources/HarnessApp/Settings/SwiftUI/SettingsColorsView.swift
- `register()` --calls--> `Int`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Scripting/ScriptAPI.swift → Packages/HarnessCommands/Sources/HarnessCommands/SGRMouse.swift
- `testingSetSelectionColors()` --references--> `HarnessTheme`  [EXTRACTED]
  Packages/HarnessTerminalKit/Sources/HarnessTerminalKit/HarnessTerminalSurfaceView.swift → Tools/harness/Sources/HarnessCLI/HarnessCLI.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/DaemonSyncService.swift → Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonSessionService.swift
- `ThemeImportController` --calls--> `ThemeFileService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/ThemeImportController.swift → Packages/HarnessTheme/Sources/HarnessTheme/ThemeFileService.swift


_Full map → GRAPH_REPORT.md · query: `graphify query "..."`_
