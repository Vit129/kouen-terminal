# Plans Index — kouen-terminal

## Active Plans

| File | Title | Status |
|------|-------|--------|
| [p43-add-repo-to-workspace/dev-task-progress.md](p43-add-repo-to-workspace/dev-task-progress.md) | P43 — Add Repo/Folder to Workspace (`Workspace.extraRepoRoots`, daemon-synced, picker on Files/Git tabs) | **REVERTED 2026-07-17** — built + live-verified (browse-only), a same-day "open session here" follow-up didn't work on first test, user chose to tear the whole feature down rather than keep debugging |
| [p42-workspace-sidebar-panels/design.md](p42-workspace-sidebar-panels/design.md) | P42 — Workspace Sidebar Panels (stacked always-visible Sessions/Files/Git panes) | **CLOSED/SUPERSEDED 2026-07-17** — built + shipped (Tasks 1-2), reverted after real `make preview` use: too cramped in a narrow sidebar. Real ask was "Add to Workspace" (merge another repo's Files/Git in, tab-switch style) — continues as P43 |
| [p37-phase-g-autocomplete/dev-task-progress.md](p37-phase-g-autocomplete/dev-task-progress.md) | P37 Phase G — Autocomplete (@ file-path, shell completion strip, AI suggestion via `claude` CLI) | Completed (28/28), Opus review passed |
| [p37-phase-d-file-browser/dev-task-progress.md](p37-phase-d-file-browser/dev-task-progress.md) | P37 Phase D — File preview, file attach, browser mirror | Completed (15/15) + Phase E built + post-ship bug-fix pass (real-phone testing) |
| [p41-automations/dev-task-progress.md](p41-automations/dev-task-progress.md) | P41 — Automations (scheduled agent launches, `kouen-mcp`) | All tasks built, build/test/robot green, live-check pending |
| [p40-mcp-surface-and-shader-presets/dev-task-progress.md](p40-mcp-surface-and-shader-presets/dev-task-progress.md) | P40 — MCP Surface Expansion (Tasks/Worktrees/Hosts) + Shader Presets | Completed + live-checked (2026-07-13): Task Dashboard + new `cwd` field verified via real `make preview`, Worktree/Host verified via real MCP calls; shader UI was reverted earlier (user call), nothing to check there |
| [p39-competitive-feature-gaps.md](p39-competitive-feature-gaps.md) | P39 — Competitive Feature Gaps (cmux/Supacode/Superset/WezTerm/Zed) | All 5 gaps built + code-reviewed 2026-07-13 (all native-GUI-only, no MCP surface to live-test directly) — real on-screen confirmation still owed for each |
| [p38-competitive-feature-gaps.md](p38-competitive-feature-gaps.md) | P38 — Competitive Feature Gaps (cross-agent diff dashboard/subagent pane visibility/thread-view/image protocol/scripting hook) | **CLOSED 2026-07-16** (user decision) — all 5 phases (A-E) built 2026-07-14, build/test/robot green throughout; B/C/D/E's live interactive click-through was explicitly skipped, not performed — see each phase's own sub-plan |
| [p38-phase-a-diff-dashboard/dev-task-progress.md](p38-phase-a-diff-dashboard/dev-task-progress.md) | P38 Phase A — Cross-agent worktree diff/review dashboard (Agents segment in GitPanelView + merge/handoff action) | Completed (10/10), code-reviewed + fixed, live-verified by user 2026-07-14 (merge/conflict flow tested in real make preview) |
| [p38-phase-b-subagent-visibility/dev-task-progress.md](p38-phase-b-subagent-visibility/dev-task-progress.md) | P38 Phase B — Subagent visibility (badge indicator + proc-scan + Claude Code hook push, not literal auto-split pane — see design.md for why) | Closed 23/23 (2026-07-16) — rewritten from scratch after original pass was lost to a concurrent git operation; build/test (87/87)/robot (26/26) green; live check SKIPPED unverified per user decision |
| [p38-phase-c-thread-overlay/dev-task-progress.md](p38-phase-c-thread-overlay/dev-task-progress.md) | P38 Phase C — Thread overlay (captured-command list on top of P34 block capture, ⇧⌘L) | Closed 20/20 (2026-07-16) — build/test (17/17)/robot (26/26) green, zero regression on P34's own suite; live check SKIPPED unverified (cross-pane jump-to-block untested) per user decision |
| [p38-phase-d-kitty-conformance/dev-task-progress.md](p38-phase-d-kitty-conformance/dev-task-progress.md) | P38 Phase D — Kitty graphics conformance slice (a=q query, a=t/a=p place-by-id, a=d delete) | Closed 8/8 (2026-07-16) — D1 finding: image protocols were NOT deferred (shipped 2026-05-30, INDEX/plan-doc corrected); conformance slice build/test (22/22)/robot (26/26) green; live check against a real client SKIPPED unverified per user decision |
| [p38-phase-e-scripting-hooks/dev-task-progress.md](p38-phase-e-scripting-hooks/dev-task-progress.md) | P38 Phase E — Scripting hook parity audit (fixed `paneCreated`/`paneRemoved` doc-vs-reality gap) | Closed 6/6 (2026-07-16) — audit found capability parity already existed, no hook-parity build needed; build/test/robot green; low-priority live check SKIPPED per user decision |
| [p37-mobile-connect-v1.md](p37-mobile-connect-v1.md) | P37 — Mobile Connect v1 (QR+Tailscale hardening, in-app QR, real client) | Active — F2/F3/F4 done (F4 reconnect resilience live-verified 2026-07-13), F5 deferred pending web feature completion, F6 parked, F1 blocked on user's own APNs cert setup |
| [p25-ios-ipados-support.md](p25-ios-ipados-support.md) | P25 — iOS/iPadOS Support | Planning (W1 done → continued as P37) |
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
| P30 — Otty Feature Parity | v3.11.x | Recipes, Floating Panes, Tab Thumbnails, Frecency, Session Resurrection audit — all done; WASM plugins deferred. Kitty Graphics/Sixel/iTerm2 image protocols were NOT deferred — shipped 2026-05-30 (`0fc22101`/`1a07a4aa`), this line was stale until corrected 2026-07-14 during P38 Phase D (see completed-archive.md) |
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
