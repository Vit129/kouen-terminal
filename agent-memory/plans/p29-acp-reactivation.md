# P29 — ACP Reactivation (Terminal + IDE)

**Status:** Planning
**Supersedes:** `.aidlc/harness/acp/` (shelved Jun 5) + `.aidlc/harness/acp-reactivation/`

## Summary

Un-shelve ACP (Agent Client Protocol), implement standard adapter-based approach (same as Zed/JetBrains). Dual surface: terminal overlay + IDE sidebar panel.

## Approach: Standard ACP Adapters (stdio JSON-RPC)

Spawn adapter binary (e.g. `claude-code-acp`) as sidecar alongside PTY session. Agent still runs in terminal; ACP provides structured metadata.

## Phases

| # | Phase | Est. | Status |
|---|-------|------|--------|
| 1 | Remove `#if HARNESS_ACP` + adapter resolver | 2-3d | Not started |
| 2 | Terminal overlay (tool calls, file edits in sidebar) | 3-4d | Not started |
| 3 | IDE panel (chat, diff, approve/reject, ⌘I) | 5-7d | Not started |
| 4 | Settings + registry + fallback | 2-3d | Not started |

## Adapter Resolution Order

1. Bundled: `Harness.app/Contents/Resources/acp-adapters/<name>`
2. Homebrew: `/opt/homebrew/bin/<name>-acp`
3. User: `~/.config/harness/acp-adapters/<name>`
4. System PATH

## Key Decisions

- Graceful fallback: no adapter = plain terminal (current behavior)
- Dual surface: terminal users see overlay, IDE users see sidebar panel
- ⌘I → agent panel, ⌘⇧I → send selection

## Dependencies

- `claude-code-acp` (github.com/zed-industries/claude-code-acp)
- Gemini CLI (native ACP support)
- Codex ACP (github.com/cola-io/codex-acp, in progress)
