# Graph Summary — .
_Auto-generated from graphify-out/GRAPH_REPORT.md · do not edit manually_
_Regen: `~/.claude/scripts/generate-graph-summary.sh .` after `graphify update .`_

## Summary
- 15646 nodes · 35718 edges · 767 communities (618 shown, 149 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 5276 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `e258c71d`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).


## God Nodes (most connected - your core abstractions)
1. `HarnessTerminalSurfaceView` - 368 edges
2. `SettingsViewController` - 304 edges
3. `Foundation` - 263 edges
4. `HarnessCore` - 252 edges
5. `XCTest` - 167 edges
6. `SessionCoordinator` - 166 edges
7. `SessionEditor` - 164 edges
8. `TerminalEmulator` - 158 edges
9. `HarnessSidebarPanelViewController` - 133 edges
10. `AppKit` - 130 edges


## Surprising Connections (you probably didn't know these)
- `ACPSession` --inherits--> `ACPClientDelegate`  [EXTRACTED]
  .aidlc/harness/acp/outputs/inception/domain-design.md → Packages/HarnessCore/Sources/HarnessCore/ACP/ACPClient.swift
- `connectAgentIfNeeded()` --calls--> `AgentRegistryStore`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/UI/Sidebar/HarnessSidebarPanelViewController.swift → Packages/HarnessCore/Sources/HarnessCore/ACP/AgentConfig.swift
- `register()` --calls--> `KeyTableID`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Scripting/ScriptAPI.swift → Packages/HarnessCore/Sources/HarnessCore/Keybindings/KeyTable.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/DaemonSyncService.swift → Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonSessionService.swift
- `ThemeImportController` --calls--> `ThemeFileService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/ThemeImportController.swift → Packages/HarnessTheme/Sources/HarnessTheme/ThemeFileService.swift


## Community Hubs (top 25)
- [[_COMMUNITY_Terminal Engine Model  TerminalGridModel|Terminal Engine: Model / TerminalGridModel]]
- [[_COMMUNITY_Harness CLI HarnessCLI|Harness CLI: HarnessCLI]]
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
- [[_COMMUNITY_HarnessCore Session  SessionEditor|HarnessCore: Session / SessionEditor]]

_Full map → graphify-out/GRAPH_REPORT.md · query: `graphify query "..."`_
