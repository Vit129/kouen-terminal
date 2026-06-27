# Combined Agent Terminal — Plan (revised)
**Date:** 2026-06-27 | **Mode:** Dev Only | **Approach:** SDLC

---

## Already have — no work needed

| Feature | Location |
|---|---|
| `AgentActivity` (idle/working/awaiting/errored) | `HarnessIPC/AgentSnapshot.swift` |
| `TabStatus` (idle/waiting/error/running/done) | `HarnessIPC/TabStatus.swift` |
| `StatusDotView` + breathing animation | `HarnessDesign.swift` — already in tab bar |
| Data flow: daemon scan → AgentSnapshot → UI | End-to-end complete |
| Pane topology API (spawnSession/splitPane/etc.) | `harness-mcp/HarnessDaemonTools.swift` |
| Agent spawning | `harnessSpawnAgent` |
| Approval boolean flag | `TabStatus.waiting` |

~~Phase 23 (pane indicators) — already done, removed~~

---

## Phases to build

```
Phase 22: OSC 26 parse               Medium,  ~80 lines
Phase 24: Fork & Branch ⌘⇧K          Small,   ~40 lines
Phase 25: Agent approval bar          Medium,  ~90 lines
```

---

## Phase 22: OSC 26 Terminal Agent Protocol

`TerminalEmulator` handles OSC 0,2,7,8,133 — OSC 26 absent.

### Files
| File | Change |
|---|---|
| `HarnessTerminalEngine/TerminalEmulator.swift` | Add `case 26` in `parserOSC()` → parse `key=value` pairs → call `onAgentStatus?` callback |
| `HarnessTerminalKit/HarnessTerminalSurfaceView.swift` | Add `onAgentStatus: ((AgentActivity) -> Void)?` stored prop; wire to emulator |
| `HarnessCore/Agents/AgentDetector.swift` | Add `setActivity(_ activity: AgentActivity, forSurfaceKey:)` — direct override bypassing decay window |
| `HarnessApp/Services/AgentBridge.swift` or surface wiring | Subscribe `onAgentStatus` → call `AgentDetector.setActivity()` |
| `Tools/harness-cli/hooks/` | Emit `\x1b]26;identity=claude-code;status=working\x07` on hook events |

### OSC 26 format
```
ESC ] 26 ; identity=claude-code ; status=working ; progress=42 BEL
ESC ] 26 ; status=waiting_input ; prompt=Allow%20read%3F BEL
```
Keys: `identity` (AgentKind rawValue), `status` (AgentActivity rawValue + `waiting_input`), `progress` (0–100, optional), `prompt` (URL-encoded, optional — triggers Phase 25)

### Success criteria
Hook emits OSC 26 → `StatusDotView` in tab bar updates within one render cycle.

---

## Phase 24: Fork & Branch

### Files
| File | Change |
|---|---|
| `HarnessCore/BannerShortcutRegistry.swift` | Add `forkTab` keybinding `⌘⇧K` |
| `HarnessApp/UI/Chrome/MainMenuBuilder.swift` | Add "Fork Tab" menu item under Session |
| `HarnessApp/SessionCoordinator.swift` | Add `forkTab()` — reads `activeCWD` → calls `addTab(to: activeWorkspaceID, cwd: cwd)` |

### Success criteria
`⌘⇧K` → new tab opens at same CWD. Shell starts fresh.

---

## Phase 25: Agent approval bar

`TabStatus.waiting` + `notificationText` already flow through `AgentSessionSummary` — missing: UI component in pane.

### Files
| File | Change |
|---|---|
| `HarnessApp/UI/Shared/AgentApprovalBar.swift` | NEW — slim NSViewController: agent chip + prompt text + Allow (`\n`) / Deny (`\x03`) buttons |
| `HarnessApp/UI/Chrome/TerminalPaneView.swift` (or pane host) | Subscribe `TabStatus.waiting` → show/hide `AgentApprovalBar`; pass `notificationText` as prompt |

### Success criteria
Agent sets `TabStatus.waiting` with prompt text → bar slides up in active pane → Allow sends `\n` to surface → agent continues.
