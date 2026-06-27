# Combined Agent Terminal — Plan
**Date:** 2026-06-27
**Mode:** Dev Only | **Approach:** SDLC

---

## Already have (no work needed)

| Feature | Source | Evidence |
|---|---|---|
| Pane topology API | CMUX | `spawnSession`, `splitPane`, `closePane` in `HarnessDaemonTools.swift` |
| Screen read/write | CMUX | `readPaneOutput`, `sendPaneText`, `sendPaneKeys`, `waitForPaneOutput` |
| Agent spawning | CMUX | `harnessSpawnAgent` (claude/codex/kiro/gemini/cursor) |
| Browser automation | CMUX | full `harnessBrowser*` suite |
| Agent notifications | Otty | Claude/Codex/Cursor hooks → Agent Notch + inbox |
| Prompt Queue | Otty | `PromptQueue` + `PromptQueueBar` (⌘⇧↩) |
| Send to Chat | Otty | right-click → "Send to AI Chat" |
| Inline AI | Warp | `InlineAICompletionController` |

---

## Phases to build

```
Phase 22: OSC 26 protocol          Medium,  ~120 lines
Phase 23: Pane-state indicators    Small,   ~60 lines
Phase 24: Fork & Branch            Small,   ~50 lines
Phase 25: Agent approval feed      Medium,  ~100 lines
Phase 26: Multi-step Agent Mode    Large    ← deferred
```

---

## Phase 22: OSC 26 Terminal Agent Protocol

**Source:** Otty

### What's missing
Parser for `\x1b]26;key=value\x07` in PTY stream → store per-surface agent state.

### Files to touch
| File | Change |
|---|---|
| `HarnessTerminalEngine/OSC26Parser.swift` | NEW — parse `key=value` pairs from OSC 26 payload; emit `AgentStatusUpdate(identity:status:progress:prompt:)` |
| `HarnessTerminalEngine/TerminalStreamParser.swift` | Route OSC code 26 to `OSC26Parser` |
| `HarnessCore/AgentStatus.swift` | NEW — `AgentStatus: Sendable` enum (idle/working/waitingInput/error) + `AgentStatusUpdate` struct |
| `HarnessApp/Services/SurfaceAgentStateService.swift` | NEW — `[SurfaceID: AgentStatusUpdate]` store; subscribes to parser events; publishes via `@Published` |
| `harness-mcp/HarnessDaemonTools.swift` | Add `agentStatus` field to `paneJSON()` output — agents read their own status back |
| `Tools/harness-cli hooks` | Emit OSC 26 `identity=claude status=working` on hook events |

### OSC 26 format
```
\x1b]26;identity=claude;status=working;progress=42\x07
\x1b]26;status=waiting_input;prompt=Allow%20read%20file%3F\x07
```
URL-encode the `prompt` value so semicolons don't break parsing.

### Success criteria
Agent hook emits OSC 26 → `SurfaceAgentStateService` updates → pane indicator + approval feed react within 100ms.

---

## Phase 23: Pane-state visual indicators

**Source:** CMUX

### What's missing
Per-pane status dot + title suffix driven by `SurfaceAgentStateService`.

### Files to touch
| File | Change |
|---|---|
| `HarnessApp/UI/Chrome/PaneStatusBadge.swift` | NEW — 8pt circle `NSView`: green=idle, amber=working, red=error, blue=waitingInput; hidden when no agent |
| `HarnessApp/UI/Chrome/TerminalPaneView.swift` or pane chrome | Add `PaneStatusBadge` to pane title bar; subscribe to `SurfaceAgentStateService` |

### Success criteria
Claude working in pane → amber dot appears in pane title bar. Finishes → dot goes green. Waiting for permission → blue dot.

---

## Phase 24: Fork & Branch

**Source:** Otty

### What's missing
"Fork Tab" action — new tab at same CWD, fresh shell. One-liner on top of existing `addTab`.

### Files to touch
| File | Change |
|---|---|
| `HarnessApp/UI/Chrome/MainMenuBuilder.swift` | Add "Fork Tab" `⌘⇧K` under Session menu |
| `HarnessCore/BannerShortcutRegistry.swift` | Add `forkTab` keybinding |
| `HarnessApp/SessionCoordinator+ForkTab.swift` | NEW — `forkTab()`: reads active pane CWD → calls `addTab(to: wsID, cwd: activeCWD)` |

### Success criteria
⌘⇧K → new tab opens in same CWD as current pane. Shell starts fresh (not a copy of the session).

---

## Phase 25: Agent approval feed

**Source:** CMUX

### What's missing
When `SurfaceAgentStateService` emits `status=waiting_input` with a `prompt`, show an approval bar in the terminal pane.

### Files to touch
| File | Change |
|---|---|
| `HarnessApp/UI/Shared/AgentApprovalBar.swift` | NEW — `NSViewController` with agent name + prompt text + Allow / Deny buttons. Allow → sends `\n` to surface. Deny → sends `\x03`. |
| `HarnessApp/UI/Chrome/TerminalPaneView.swift` | Subscribe to `SurfaceAgentStateService`; show/hide `AgentApprovalBar` overlay when `waitingInput` |

### Success criteria
Claude Code emits permission prompt via OSC 26 → `AgentApprovalBar` slides up → user clicks Allow → `\n` sent to PTY → agent continues. Deny → `\x03` → agent aborts.

---

## Open questions

| # | Question | Default |
|---|---|---|
| 1 | OSC 26 — implement as proposed Otty standard or Harness-specific variant? | Start Harness-specific, align with Otty if they ratify |
| 2 | Fork & Branch — copy visible scrollback to new tab? | No — fresh shell only. Simpler, avoids stale context confusion |
| 3 | Approval bar — only for OSC 26 prompts or also detect Claude Code's native permission pattern from PTY? | Both: OSC 26 first, add PTY pattern detection in Phase 25b if needed |
| 4 | Pane indicator — show in tab bar or pane chrome? | Pane chrome (gutter dot) — tab bar already has agent badge |
| 5 | Fork keybinding ⌘⇧K — conflicts? | Check: not in `BannerShortcutRegistry`. Safe. |

---

## Files created / modified summary

| File | Type | Phase |
|---|---|---|
| `HarnessTerminalEngine/OSC26Parser.swift` | NEW | 22 |
| `HarnessCore/AgentStatus.swift` | NEW | 22 |
| `HarnessApp/Services/SurfaceAgentStateService.swift` | NEW | 22 |
| `HarnessDaemonTools.swift` | MODIFY | 22 |
| `TerminalStreamParser.swift` | MODIFY | 22 |
| `CLI hooks` | MODIFY | 22 |
| `PaneStatusBadge.swift` | NEW | 23 |
| `TerminalPaneView.swift` | MODIFY | 23, 25 |
| `SessionCoordinator+ForkTab.swift` | NEW | 24 |
| `MainMenuBuilder.swift` | MODIFY | 24 |
| `BannerShortcutRegistry.swift` | MODIFY | 24 |
| `AgentApprovalBar.swift` | NEW | 25 |

**Total estimate:** ~330 lines across 12 files. No new dependencies.
