# ACP Client

## Status: ACTIVE (enabled June 2026)

## What It Is

ACP (Agent Client Protocol) enables IDE-like chat with CLI agents (Claude Code, Codex, Gemini)
via JSON-RPC 2.0 over stdio with `Content-Length: N\r\n\r\n{body}` framing. Harness spawns an
ACP adapter binary, sends prompts, receives streaming text/tool-call responses, and gates tool
execution through the approval bar in `AgentChatPanelView`.

## Architecture

```
Harness GUI
  └─ AgentChatPanelView (sidebar tab 3 "Agent")
       └─ ACPSession @MainActor   ← observable conversation state
            └─ ACPClient actor    ← spawns process, dispatches JSON-RPC
                 └─ ACPProcess    ← stdin/stdout pipes, AsyncStream<ACPMessage>
                      └─ adapter binary (claude-code-acp / codex-acp / gemini --acp)
```

- `ACPClient` → spawns process, encodes with `ACPTransport` (`Content-Length` framing), async dispatch
- `ACPSession` → observable conversation (`ACPChatMessage` with `.user/.assistant/.thought/.toolCall` roles), streaming last-message update
- `AgentChatPanelView` → AppKit chat UI with input field + approval bar for tool-call permission
- `AgentConfig` + `AgentRegistryStore` → UserDefaults persistence; populated via Settings > Agents > "Chat" toggle

## Compilation Gate

All ACP code is behind `#if HARNESS_ACP`. The flag is set in `Package.swift`:
- `HarnessCore` target: `swiftSettings: strictFoundationSettings + [.define("HARNESS_ACP")]`
- `HarnessApp` target: `swiftSettings: [.define("HARNESS_ACP")]`

`ACPTransport.swift` is NOT behind the flag (always compiled).

## Adapter Binaries

| Agent | npm package | Binary name |
|-------|-------------|-------------|
| Claude Code | `@zed-industries/claude-code-acp` | `claude-code-acp` |
| Codex | `@zed-industries/codex-acp` | `codex-acp` |
| Gemini / Kiro / others | built-in `--acp` flag | native binary |

Install via: `harness-cli install-acp`

## PATH Resolution

macOS `.app` bundles receive a minimal system PATH — npm-global dirs are absent.
`resolveBinaryPath()` in `SettingsViewController+Agents.swift` supplements system PATH with:
- `/usr/local/bin`, `/opt/homebrew/bin`, `/opt/homebrew/sbin`
- `~/.npm-global/bin`, `~/.local/bin`, `~/Library/pnpm`
- nvm node version bins (newest first)

## GUI Integration

- Sidebar: `["Sessions", "Files", "Git", "Agent"]` — Agent at index 3
- `selectSidebarTab(index: 3)` calls `connectAgentIfNeeded()` on first open
- Settings > Agents page includes `buildACPAgentsGroup()` (ACP agent list + "Add Agent…" button)
- "Chat" toggle in each agent row calls `chatToggleClicked(_:)` → resolves binary → writes `AgentConfig`

## Key Invariant

`ACPProcess.launch()` requires an absolute `binaryPath` — relative paths or bare names fail.
`resolveBinaryPath()` always returns an absolute path or nil; nil blocks the toggle with a Toast.
