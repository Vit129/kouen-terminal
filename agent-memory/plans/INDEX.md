# Plans Index — kouen-terminal

## Active Plans

| File | Title | Status |
|------|-------|--------|
| [p25-ios-ipados-support.md](p25-ios-ipados-support.md) | P25 — iOS/iPadOS Support | Planning |
| [p8-macos27-adoption.md](p8-macos27-adoption.md) | P8 — macOS 27 Golden Gate Adoption | Active |

## Completed

→ [completed-archive.md](completed-archive.md)

### Quick ref — recent completions

| Plan | Version | Notes |
|------|---------|-------|
| P36 — App Icon Auto/Light/Dark | Unreleased | Runtime Dock-icon swap via appearance KVO (macOS has no static per-appearance mechanism for `idiom:mac` icons); fixed white-edge SVG bug + 17% size-mismatch bug (2026-07-06) — see completed-archive.md |
| P35 — Fix Google/OAuth login inside embedded browser | Unreleased | Root cause: popup webview double-load severed `window.opener`; added `webViewDidClose` (2026-07-06) — see completed-archive.md |
| P34 — Block-Based Terminal | Unreleased | F1 command-boundary capture (zsh/fish `133;C`), F2 Copy Output/Command Only, F3 `kouenGetLastBlock`/`kouenGetBlock` MCP tools; bookmark deferred (2026-07-02) — see completed-archive.md |
| P33 — Visibility Gaps | Unreleased | PR checks-status dot, sidebar notification text, commit-diff popover rewire, sidebar first-reveal blank-panel fix, 4-finding Opus review pass (2026-07-02) — see completed-archive.md |
| P32 — Task-Based Agent Worktrees | Unreleased | Explicit "New Agent Task" palette action, `taskName` metadata, `archiveScript` teardown wired, task switcher via existing ⌘1-9 (2026-07-01–02) — see completed-archive.md |
| P23 — SSH Remote Host Manager | v3.9.x | Settings → Remote tab, toolbar badge, `kouen-cli remote add/list/remove`, socket auto-detect via new `kouen-cli socket-path` command (2026-07-01) — see completed-archive.md |
| SwiftUI Migration | v3.9.0–v3.11.x | Sidebar, Settings, Command palette, Notifications, Agent notch, Terminal tab bar all migrated; Browser tab bar deliberately skipped (2026-07-01, low value/high risk) — see completed-archive.md |
| P30 — Otty Feature Parity | v3.11.x | Recipes, Floating Panes, Tab Thumbnails, Frecency, Session Resurrection audit — all done; Kitty Graphics + WASM plugins deferred (see completed-archive.md) |
| P28 — Browser DevTools API | v3.7.0–v3.9.0 | kouen-mcp 14 browser tools, replaces chrome-devtools-mcp |
| Sidebar SwiftUI Migration (Option B) | v3.9.0 | NSTableView → SwiftUI List; RL-051 eliminated permanently |
| KouenCore Package Split | v3.9.0 | Core → Core + Commands + IPC + Settings (4 packages) |
| P27 — Pane Drag-and-Drop | v3.5.0 | Drag grip → drop zone overlay → swapPanes / joinPane |
| P26 — Agent Connection | v3.9.0 | kouen-mcp 14 browser tools + terminal tools; MCP config wired globally for Claude/Codex/Kiro/Gemini |
| P12 — MCP Server | v3.9.0 | 27+ tools total; kouen-mcp replaces chrome-devtools-mcp for all agents |
| P4 — LSP + Code Viewing | v3.2.0 | `kouenErrors` MCP tool surfaces LSP diagnostics to agents |
| SwiftUI Settings | v3.9.4 | All settings pages migrated AppKit → SwiftUI |
| Command History Search | v3.9.x | ⌘R overlay, fuzzy match, shell history integration |
| IDE File Tree (Phase 1) | v3.9.x | Sidebar file tree, project root follows git root, session switching |
| Git Panel Memory Leak | v3.9.4 | State caching prevents NSTextField allocation spikes |
| P5 — ACP Client | Shelved | Erased entirely by `c4e1e15` ("remove: ACP + ⌘I"); P29 reactivation plan abandoned, not pursuing |
