# Graph Summary — .
_Auto-generated from graphify-out/GRAPH_REPORT.md · do not edit manually_
_Regen: `~/.claude/scripts/generate-graph-summary.sh .` after `graphify update .`_

## Summary
- 15811 nodes · 35427 edges · 793 communities (621 shown, 172 thin omitted)
- Extraction: 86% EXTRACTED · 14% INFERRED · 0% AMBIGUOUS · INFERRED: 5106 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output


## Graph Freshness
- Built from commit: `d3a700f3`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).


## God Nodes (most connected - your core abstractions)
1. `HarnessTerminalSurfaceView` - 369 edges
2. `String` - 288 edges
3. `Foundation` - 270 edges
4. `HarnessCore` - 260 edges
5. `SessionCoordinator` - 167 edges
6. `XCTest` - 167 edges
7. `SessionEditor` - 164 edges
8. `TerminalEmulator` - 158 edges
9. `AppKit` - 130 edges
10. `SurfaceRegistry` - 125 edges


## Surprising Connections (you probably didn't know these)
- `SUI` --references--> `Color`  [INFERRED]
  Packages/HarnessOnboarding/Sources/HarnessOnboarding/Design/ImmersivePalette.swift → Apps/Harness/Sources/HarnessApp/Settings/SwiftUI/SettingsColorsView.swift
- `Notification.Name` --references--> `Notification`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/UI/FileTree/FileTreeSwiftUIView.swift → Packages/HarnessIPC/Sources/HarnessIPC/NotificationBus.swift
- `ACPSession` --inherits--> `ACPClientDelegate`  [EXTRACTED]
  .aidlc/harness/acp/outputs/inception/domain-design.md → Packages/HarnessCore/Sources/HarnessCore/ACP/ACPClient.swift
- `AppIdleThrottle` --references--> `Notification`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/AppIdleThrottle.swift → Packages/HarnessIPC/Sources/HarnessIPC/NotificationBus.swift
- `DaemonSyncService` --calls--> `DaemonSessionService`  [INFERRED]
  Apps/Harness/Sources/HarnessApp/Services/DaemonSyncService.swift → Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonSessionService.swift


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
