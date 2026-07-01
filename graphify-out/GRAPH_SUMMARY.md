# Graph Summary — harness-terminal
_Auto-generated from graphify-out/GRAPH_REPORT.md · do not edit manually_
_Regen: `~/.claude/scripts/generate-graph-summary.sh .` after `graphify update .`_

## Summary
- 14872 nodes · 30464 edges · 3083 communities (1094 shown, 1989 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 3023 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `b556b4fe`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).


## God Nodes (most connected - your core abstractions)
1. `IPCRequest` - 133 edges
2. `Foundation` - 266 edges
3. `HarnessCore` - 268 edges
4. `Command` - 96 edges
5. `data` - 252 edges
6. `XCTest` - 171 edges
7. `SessionCoordinator` - 123 edges
8. `AppKit` - 136 edges
9. `SessionEditor` - 166 edges
10. `SurfaceRegistry` - 147 edges


## Surprising Connections (you probably didn't know these)
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/DaemonSyncService.swift → Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonSessionService.swift
- `RemoteHostsService` --calls--> `RemoteHostStore`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/RemoteHostsService.swift → Packages/HarnessCore/Sources/HarnessCore/Remote/RemoteHostStore.swift
- `ThemeImportController` --calls--> `ThemeFileService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/ThemeImportController.swift → Packages/HarnessTheme/Sources/HarnessTheme/ThemeFileService.swift
- `handleInstallTools()` --calls--> `Process`  [INFERRED]
  Tools/harness/Sources/HarnessCLI/HarnessCLI+InstallTools.swift → Apps/Harness/Sources/HarnessApp/UI/CommandPalette/CommandPaletteController.swift
- `vfork_and_exec()` --calls--> `Process`  [INFERRED]
  Tools/harness/Sources/HarnessCLI/HarnessCLI+Workbench.swift → Apps/Harness/Sources/HarnessApp/UI/CommandPalette/CommandPaletteController.swift


## Community Hubs (top 25)
- Terminal Engine: Model / TerminalGridModel
- Tests: HarnessTerminalRendererTests / MetalRendererTests
- Terminal Engine: Screen / TerminalScreen
- HarnessCore: Settings / HarnessSettings
- HarnessCore: IPC / IPCMessage
- Terminal Renderer: HarnessTerminalRenderer / TerminalMetalRenderer
- HarnessCore: Commands / Command
- Terminal Engine: Emulator / TerminalEmulator
- Harness App: Settings / SettingsViewController
- Tests: HarnessBenchmarks / PerformanceBenchmarks
- Harness App: UI / TerminalTabBarView
- Harness App: UI / ContentAreaViewController
- Tests: HarnessTerminalEngineTests / KittyKeyboardTests
- Terminal Engine: Parser / VTParser
- Tests: HarnessCoreTests / FormatStringTests
- HarnessCore: ACP / ACPClient
- Tests: HarnessDaemonTests / ScrollbackFileTests
- Terminal Engine: HarnessTerminalEngine / InputEncoder
- HarnessCore: Notch / AgentNotchPeekDecider
- Terminal Kit: HarnessTerminalKit / HarnessTerminalSurfaceView
- HarnessCore: Agents / AgentHookInstaller
- Daemon: HarnessDaemon / RealPty
- Tests: HarnessDaemonTests / DaemonRoundTripTests
- HarnessCore: Session / SessionEditor
- Docs: HARNESS_TMUX_CAPABILITIES

_Full map → graphify-out/GRAPH_REPORT.md · query: `graphify query "..."`_
