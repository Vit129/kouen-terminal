# Terminal AI Chat (⌘I inline overlay)

## Status: ❌ REMOVED (`c4e1e15`, 2026-06-29) — "erase as if never built." Kept for historical record only; do not treat any content below as current.

## What It Is

Warp-style inline AI chat that overlays the focused terminal pane. No sidebar, no ACP — spawns
agent CLIs directly via Foundation.Process. `⌘I` opens the input bar; response streams as a
floating block above it.

## Key Shortcuts (I-family)

| Key | Action |
|-----|--------|
| `⌘I` | Toggle inline AI chat (open/clear) |
| `⌘⇧I` | Toggle Agent Notch panel |
| `⌃⌘I` | Show Notifications (moved from `⌘⇧U`) |

## Architecture

```
⌘I → PrefixKeymap (root table) → MainExecutor → SessionCoordinator.toggleAIChat()
  → AITerminalChatController.toggle()
       ├── AIQueryInputView      — bottom-pinned input bar (agent pill + text field)
       └── AIResponseBlockView   — streaming block ([▶ Run] [⎘ Copy] [✕])
            └── AgentProcessManager.query() — spawns CLI, streams stdout
```

### AgentProcessManager

- Resolves binary via `/bin/zsh -l -c "which <name>"` (login shell, respects homebrew/nix/mise)
- Caches resolved paths for lifetime of actor
- Injects context on stdin (last N pane lines from `captureVisibleLines()`), closes stdin before launch
- Streams stdout line-by-line via `availableData` loop → `AsyncStream<Chunk>`
- On non-zero exit: reads stderr, yields `.error`

### CLI Print-Mode Args

| Agent | Binary | Args |
|-------|--------|------|
| Claude Code | `claude` | `-p "<query>"` |
| Codex | `codex` | `exec "<query>"` |
| Antigravity (Gemini) | `agy` | `-p "<query>"` |
| Kiro | `kiro` | `-p "<query>"` |

### Context Injection

`TerminalHostView.captureVisibleLines(maxLines: config.contextLines)` (default 80 lines) →
written to stdin pipe → closed before `proc.run()`. Agent gets terminal context before the query.

## ACP vs MCP vs Terminal Chat

| | MCP | Terminal Chat | ACP |
|-|-----|--------------|-----|
| Direction | Agent → Harness | User → Agent (via Harness) | Harness → Agent |
| Standard | Open (Anthropic) | n/a (CLI print mode) | Proprietary |
| Status | ✅ Shipped (P26A) | ✅ Shipped (P26B) | ❌ Shelved |
| Use case | Agent controls terminal | User asks AI while in terminal | Sidebar chat (replaced by terminal chat) |

## Key Files

- `HarnessCore/AI/AIAgentConfig.swift` — `activeAgent`, `binaryPathOverride`, `contextLines`, CLI args per kind
- `HarnessCore/AI/AgentProcessManager.swift` — actor: path resolution, stdin injection, stdout streaming
- `HarnessApp/UI/AIChat/AIQueryInputView.swift` — floating input bar NSView
- `HarnessApp/UI/AIChat/AIResponseBlockView.swift` — streaming response block NSView
- `HarnessApp/UI/AIChat/AITerminalChatController.swift` — @MainActor orchestrator
- `HarnessApp/Services/SessionCoordinator.swift` — owns `aiChatControllers` dict, `toggleAIChat()`
- `HarnessApp/Services/MainExecutor.swift` — `case .openAIChat`
- `HarnessCore/Commands/Command.swift` — `case openAIChat`
- `HarnessCore/Keybindings/KeyTable.swift` — root table: `⌘I → .openAIChat`

## Non-Obvious Constraints

- `AITerminalChatController` is `@MainActor`; `AgentProcessManager` is an `actor` — bridge via `Task { await }` in submit path
- `addSubview(_:positioned: .above, relativeTo: nil)` pattern (same as CompletionPopupView) — don't use `wantsLayer = true` on the overlay itself or Metal surface goes dark
- `repositionBlocks()` removes constraints by `firstAttribute == .bottom` — fragile if NSLayoutConstraint internal representation changes; safer long-term: use a `NSStackView` container for response blocks
- stdin context must be written and closed BEFORE `proc.run()` — Pipe buffers data, closing before launch ensures agent reads clean EOF
- B-8 (Settings AI tab) deferred — agent switcher can be done later without blocking ⌘I flow
