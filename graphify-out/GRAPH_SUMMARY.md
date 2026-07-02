# Graph Summary — harness-terminal
_Auto-generated from GRAPH_REPORT.md · do not edit manually_
_Regen: `graphify update .`_

## Summary
- 14838 nodes · 30209 edges · 3092 communities (1105 shown, 1987 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 2732 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `49a67bab`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).


## God Nodes (most connected - your core abstractions)
1. `Int` - 894 edges
2. `HarnessCore` - 267 edges
3. `Foundation` - 266 edges
4. `XCTest` - 170 edges
5. `SessionEditor` - 169 edges
6. `SurfaceRegistry` - 147 edges
7. `DaemonClient` - 142 edges
8. `AppKit` - 136 edges
9. `IPCRequest` - 134 edges
10. `SessionCoordinator` - 124 edges


## Surprising Connections (you probably didn't know these)
- `SUI` --calls--> `Color`  [INFERRED]
  Packages/HarnessOnboarding/Sources/HarnessOnboarding/Design/ImmersivePalette.swift → Apps/Harness/Sources/HarnessApp/Settings/SwiftUI/SettingsColorsView.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/DaemonSyncService.swift → Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonSessionService.swift
- `ThemeImportController` --calls--> `ThemeFileService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/ThemeImportController.swift → Packages/HarnessTheme/Sources/HarnessTheme/ThemeFileService.swift
- `vfork_and_exec()` --calls--> `Process`  [INFERRED]
  Tools/harness/Sources/HarnessCLI/HarnessCLI+Workbench.swift → Apps/Harness/Sources/HarnessApp/UI/CommandPalette/CommandPaletteController.swift
- `LSPFileSession` --calls--> `LSPServerRegistry`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/UI/FileEditor/LSPFileSession.swift → Packages/HarnessLSP/Sources/HarnessLSP/LSPServerRegistry.swift


_Full map → GRAPH_REPORT.md · query: `graphify query "..."`_
