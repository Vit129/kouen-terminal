# Graph Summary — harness-terminal
_Auto-generated from graphify-out/GRAPH_REPORT.md · do not edit manually_
_Regen: `~/.claude/scripts/generate-graph-summary.sh .` after `graphify update .`_

## Summary
- 15753 nodes · 27659 edges · 1046 communities (769 shown, 277 thin omitted)
- Extraction: 89% EXTRACTED · 11% INFERRED · 0% AMBIGUOUS · INFERRED: 2987 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `b6c97baf`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).


## God Nodes (most connected - your core abstractions)
1. `HarnessTerminalSurfaceView` - 334 edges
2. `SettingsViewController` - 259 edges
3. `SessionEditor` - 162 edges
4. `TerminalEmulator` - 154 edges
5. `SessionCoordinator` - 147 edges
6. `HarnessCLI` - 130 edges
7. `IPCRequest` - 105 edges
8. `SurfaceRegistry` - 103 edges
9. `ViEngine` - 94 edges
10. `HarnessSidebarPanelViewController` - 94 edges


## Surprising Connections (you probably didn't know these)
- `handleStartServer()` --calls--> `Process`  [INFERRED]
  /Users/supavit.cho/Git/harness-terminal/Tools/harness/Sources/HarnessCLI/HarnessCLI+Server.swift → Apps/Harness/Sources/HarnessApp/UI/CommandPalette/CommandPaletteController.swift
- `handleStartServer()` --calls--> `Process`  [INFERRED]
  /Users/supavit.cho/Git/harness-terminal/Tools/harness/Sources/HarnessCLI/HarnessCLI+Server.swift → Apps/Harness/Sources/HarnessApp/UI/CommandPaletteController.swift
- `vfork_and_exec()` --calls--> `Process`  [INFERRED]
  Tools/harness/Sources/HarnessCLI/HarnessCLI+Workbench.swift → Apps/Harness/Sources/HarnessApp/UI/CommandPalette/CommandPaletteController.swift
- `tunnelSocketURL()` --calls--> `character`  [INFERRED]
  /Users/supavit.cho/Git/harness-terminal/Packages/HarnessCore/Sources/HarnessCore/Paths/HarnessPaths.swift → Packages/HarnessTerminalKit/Sources/HarnessTerminalKit/HarnessTerminalSurfaceView.swift
- `refresh()` --calls--> `character`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/UI/Git/GitPanelView.swift → Packages/HarnessTerminalKit/Sources/HarnessTerminalKit/HarnessTerminalSurfaceView.swift


## Community Hubs (top 25)
- [[_COMMUNITY_Terminal Engine Model  TerminalGridModel|Terminal Engine: Model / TerminalGridModel]]
- [[_COMMUNITY_Harness CLI HarnessCLI|Harness CLI: HarnessCLI]]
- [[_COMMUNITY_Tests HarnessTerminalRendererTests  MetalRendererTests|Tests: HarnessTerminalRendererTests / MetalRendererTests]]
- [[_COMMUNITY_Terminal Engine Screen  TerminalScreen|Terminal Engine: Screen / TerminalScreen]]
- [[_COMMUNITY_HarnessCore Settings  HarnessSettings|HarnessCore: Settings / HarnessSettings]]
- [[_COMMUNITY_HarnessCore IPC  IPCMessage|HarnessCore: IPC / IPCMessage]]
- [[_COMMUNITY_Terminal Renderer HarnessTerminalRenderer  TerminalMetalRenderer|Terminal Renderer: HarnessTerminalRenderer / TerminalMetalRenderer]]
- [[_COMMUNITY_HarnessCore Commands  Command|HarnessCore: Commands / Command]]
- [[_COMMUNITY_Terminal Engine Emulator  TerminalEmulator|Terminal Engine: Emulator / TerminalEmulator]]
- [[_COMMUNITY_Harness App Settings  SettingsViewController|Harness App: Settings / SettingsViewController]]
- [[_COMMUNITY_Tests HarnessBenchmarks  PerformanceBenchmarks|Tests: HarnessBenchmarks / PerformanceBenchmarks]]
- [[_COMMUNITY_Harness App UI  TerminalTabBarView|Harness App: UI / TerminalTabBarView]]
- [[_COMMUNITY_Harness App UI  ContentAreaViewController|Harness App: UI / ContentAreaViewController]]
- [[_COMMUNITY_Tests HarnessTerminalEngineTests  KittyKeyboardTests|Tests: HarnessTerminalEngineTests / KittyKeyboardTests]]
- [[_COMMUNITY_Terminal Engine Parser  VTParser|Terminal Engine: Parser / VTParser]]
- [[_COMMUNITY_Tests HarnessCoreTests  FormatStringTests|Tests: HarnessCoreTests / FormatStringTests]]
- [[_COMMUNITY_Terminal Renderer HarnessTerminalRenderer  GlyphRasterizer|Terminal Renderer: HarnessTerminalRenderer / GlyphRasterizer]]
- [[_COMMUNITY_HarnessCore ACP  ACPClient|HarnessCore: ACP / ACPClient]]
- [[_COMMUNITY_Tests HarnessDaemonTests  ScrollbackFileTests|Tests: HarnessDaemonTests / ScrollbackFileTests]]
- [[_COMMUNITY_Terminal Engine HarnessTerminalEngine  InputEncoder|Terminal Engine: HarnessTerminalEngine / InputEncoder]]
- [[_COMMUNITY_HarnessCore Notch  AgentNotchPeekDecider|HarnessCore: Notch / AgentNotchPeekDecider]]
- [[_COMMUNITY_Terminal Kit HarnessTerminalKit  HarnessTerminalSurfaceView|Terminal Kit: HarnessTerminalKit / HarnessTerminalSurfaceView]]
- [[_COMMUNITY_HarnessCore Agents  AgentHookInstaller|HarnessCore: Agents / AgentHookInstaller]]
- [[_COMMUNITY_Daemon HarnessDaemon  RealPty|Daemon: HarnessDaemon / RealPty]]
- [[_COMMUNITY_Tests HarnessDaemonTests  DaemonRoundTripTests|Tests: HarnessDaemonTests / DaemonRoundTripTests]]

_Full map → graphify-out/GRAPH_REPORT.md · query: `graphify query "..."`_
