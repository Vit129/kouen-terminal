# ACP Client (Shelved)

## Status: SHELVED (June 2026)

## What It Is

ACP (Agent Client Protocol) enables IDE-like chat with CLI agents (Claude Code, Codex, Gemini) via JSON-RPC 2.0 over stdio. The client spawns an agent binary, sends prompts, receives streaming responses, and handles tool-call permission requests.

## Why Shelved

1. **Adapter binaries required** — Claude Code needs `@agentclientprotocol/claude-agent-acp` (npm), not `claude --acp` directly
2. **PATH resolution in .app bundles** — macOS sandboxed apps don't see `~/.volta/bin`, `~/.hermes/node/bin`, etc.
3. **No tool control** — Can't restrict which tools an agent invokes; agents may execute arbitrary commands

## Architecture (Preserved)

- `ACPClient` actor → spawns process, sends/receives `Content-Length: N\r\n\r\n{body}` frames
- `ACPSession` model → observable conversation state, streaming, tool calls
- `AgentChatPanelView` → AppKit chat UI (was sidebar tab 4 "Agent")
- `AgentConfig` + `AgentRegistryStore` → UserDefaults persistence

## Re-enablement Criteria

- ACP adapters widely installable (single `brew install` or bundled)
- Agent sandboxing (restrict tool set at protocol level)
- Reliable PATH resolution for .app bundles (or bundle adapters inside Harness.app)
