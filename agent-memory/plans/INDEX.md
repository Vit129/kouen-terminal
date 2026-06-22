# Plans Index — harness-terminal

## Active Plans

| File | Title | Status |
|------|-------|--------|
| [swiftui-migration.md](swiftui-migration.md) | SwiftUI Migration (remaining components) | Active |
| [p25-ios-ipados-support.md](p25-ios-ipados-support.md) | P25 — iOS/iPadOS Support | Planning |
| [p23-ssh-remote-ui.md](p23-ssh-remote-ui.md) | P23 — SSH Remote Host Manager (PuTTY-style UI) | Active |
| [p8-macos27-adoption.md](p8-macos27-adoption.md) | P8 — macOS 27 Golden Gate Adoption | Active |
| [kiro-rules-restructure.md](kiro-rules-restructure.md) | Kiro Rules Restructure | Pending |

## Completed

→ [completed-archive.md](completed-archive.md)

### Quick ref — recent completions

| Plan | Version | Notes |
|------|---------|-------|
| P28 — Browser DevTools API | v3.7.0–v3.9.0 | harness-mcp 14 browser tools, replaces chrome-devtools-mcp |
| Sidebar SwiftUI Migration (Option B) | v3.9.0 | NSTableView → SwiftUI List; RL-051 eliminated permanently |
| HarnessCore Package Split | v3.9.0 | Core → Core + Commands + IPC + Settings (4 packages) |
| P27 — Pane Drag-and-Drop | v3.5.0 | Drag grip → drop zone overlay → swapPanes / joinPane |
| P26 — Agent Connection | v3.9.0 | harness-mcp 14 browser tools + terminal tools; MCP config wired globally for Claude/Codex/Kiro/Gemini |
| P12 — MCP Server | v3.9.0 | 27+ tools total; harness-mcp replaces chrome-devtools-mcp for all agents |
| P4 — LSP + Code Viewing | v3.2.0 | `harnessErrors` MCP tool surfaces LSP diagnostics to agents |
| P5 — ACP Client | Shelved | Re-enable when adapters ship natively; chat sidebar code preserved under `#if HARNESS_ACP` |
