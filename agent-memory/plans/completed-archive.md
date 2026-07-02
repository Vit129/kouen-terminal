# Completed Plans Archive

All plans below are **done** and merged into main.

---

## P1 — Sidebar Performance (v1.3.0)
- Cached `sidebarRows` (O(1) per NSTableView delegate call)
- `surfaceIndex` dict for O(1) surface lookup
- Theme guard (skip `applyThemeToAllHosts` when unchanged)
- Metadata probe dedup (one git probe per directory per cycle)
- Sync divider positioning (layoutSubtreeIfNeeded before setPosition)

## P3 — N-ary Split Panes (v1.5.0)
- Same-direction flatten into single NSSplitView + N subviews
- Equal distribution in `layout()` at `totalSize/N` intervals
- `isApplyingPositions` recursion guard
- Host reuse (detach before rebuild, re-insert without losing Metal)
- `viewDidMoveToSuperview()` fix for CADisplayLink restart
- Split down removed entirely

## P6 — UI Polish (v1.5.0)
- SF Symbols everywhere (disclosure chevrons, group buttons, worktree remove)
- `HarnessDesign.configurePillButton()` shared helper
- `FontSize`, `IconSize`, `symbolConfig()` design tokens
- Animated disclosure chevron rotation
- Git stage checkbox pulse animation
- Sidebar vibrancy `.sidebar` material

## Sidebar & Split Issues (v1.6.0)
- Sidebar left/right toggle — real-time (no restart)
- NSSplitView reorder via remove+reinsert (CASE-007)
- Right-click context menu for position toggle
- Traffic light inset handled for both positions

## Session Grouping (v1.3.0)
- `SidebarSessionRow` enum (groupHeader + session)
- Project group by git root
- Collapse/expand with animated chevron
- Drag/drop with session ID (not row index)
- Group header `+` and `...` buttons (SF Symbols)

## Panel Session Performance (v1.3.0)
- All P1–P6 perf fixes merged
- F1: File tree auto-update per session (git status dots, FSEvents watcher)

## P6 — File Editor Opacity Parity (v2.2.3 / Unreleased, 2026-06-09)
- `refreshEditorPanelFill()` in `ContentAreaViewController` — applies `terminalBackground × opacity` to the `fileEditorPanel` CALayer
- Wired into `applyChrome()` (responds to theme/opacity changes) and `showFileEditorSplit()` (panel creation)
- Subviews (FileEditorView, FileEditorTabBarView, SyntaxTextView, gutter) required no changes — all already transparent
- Key insight: Metal renderer handles terminal alpha itself; AppKit-only panels must apply it explicitly to their layer
- `HarnessSettings.clampedOpacity` returns `Float` — must cast to `CGFloat` for `withAlphaComponent`

## P2 — Async IPC Refactor
- IPC and metadata refresh moved off the main actor via `DaemonClientActor` and async background task contexts
- `SessionCoordinator` snapshot sync no longer blocks UI interactions on daemon round-trips

## P9 — Complexity Reduction
- Extracted `LiveResizeGeometry`, `PasteController`, and `SelectionResolver` from terminal surface code
- Split CLI handlers into `HarnessCLI+*.swift` extension files while preserving command dispatch behavior
- Extracted `WindowInputRouter` with focused CLI tests
- Extracted daemon `HookExecutor` and `FormatContextBuilder`
- Documented intentional `GridCompositor` duplication between app and onboarding packages

## P10 — Terminal Performance and Convenience
- Lazy scrollback reflow shipped for live resize performance
- Local workspace symbol completion and completion popup shipped
- IDE mode, focus mode, session state dots, diff highlighting, git preview/history improvements, and task board sidebar shipped
- ACP sidebar work remains intentionally shelved; implementation is preserved but not exposed

## P5 — ACP Client (Shelved)
- ACP core implementation exists in `HarnessCore/ACP`: `ACPClient`, `ACPSession`, `ACPProcess`, `ACPTransport`, `ACPMessage`, and `AgentConfig`
- `AgentChatPanelView` and settings-side ACP agent configuration remain in the app code
- Runtime entry point is intentionally disabled in the sidebar (`[ACP SHELVED] connectAgentIfNeeded()`)
- Shelved rationale: adapter binaries not widely available, PATH resolution in .app bundles unreliable, no tool sandboxing
- Full context: `agent-memory/knowledge/patterns/acp-client.md`
- Direction: ACP = Harness→agent (embedded chat). MCP (P12) = agent→Harness (tool server). Both share `ACPMessage` framing from `HarnessCore`.
- Re-enable criteria: `brew install` for adapters, agent tool sandboxing at protocol level

## P7 — Sidebar UI Polish
- Large-screen sidebar group header button visibility/alignment completed
- Session card spacing and file editor tab bar overlap polish completed

## P4 — Terminal-First Code Viewing + LSP
- Track 1 (Syntax Highlighting): `SyntaxTextView` regex-based, 30+ languages, wired into `FileViewerViewController`
- Track 2 (Vi Navigation): `gf` path-under-cursor, `gd`/`K`/`]d`/`[d` LSP-backed, `:view`/`:edit`/`:split`/`:vsplit`/`:find`, `harness view` CLI
- Track 3 (LSP Command API): `harness lsp start/status/hover/definition/diagnostics`
- Follow-ups (`:recent`, `:grep`, `:make`) moved to P24
- MCP surface: `harnessErrors` tool in `harness-mcp` exposes LSP diagnostics to AI agents (see P12/architecture/mcp-server.md)

## P21 — Hermes-Inspired Agent Platform (Shelved → P24 partial)
- Status: Shelved — ACP adapters not publicly available
- Actionable UX layer (agent auto-start, status badges, selection via config) absorbed into P24
- Remaining layers (ACP sideband, multi-provider, brain, orchestration, execution backends) stay shelved for future re-enable
- AgentCatalog + `:agent` ex command + AgentBridge partially implemented and preserved

## P22 — Long-Session Responsiveness Hardening
- Adaptive polling (skip-on-idle when no PTY output for 10s)
- Off-main output processing for metadata refresh
- Scrollback compaction (trim to N lines when idle)
- Renderer micro-batch (coalesce rapid redraws)
- `salvageRowKeys` optimization for grid diff
- Snapshot fanout: `metadataOnly` flag prevents unnecessary UI rebuilds

## P11 — Scripting & Config API (WezTerm parity)
- `harness.config.get/set` (11 allowlisted keys)
- `harness.keys.bind/unbind/reload`
- `harness.commands.run` (Promise-based)
- Pane mutators: `sendText/split/close`, session `spawn`
- `harness.events.on/off` bridge (snapshotChanged/configReloaded)
- All in `ScriptAPI.swift`

## P12 — Agent Orchestration via MCP
- PBI-ORCH-001–005 complete
- `harness-mcp` binary: JSON-RPC 2.0 over stdin/stdout, protocol v2024-11-05
- 27 tools across 6 categories: session/pane control, file I/O, git, workbench, browser pane, agents
- Tool policy gating: `~/.config/harness/mcp-policy.json` or `HARNESS_MCP_ALLOW_CONTROL=1`
- MCP badge on tab bar via `lastMCPControlAt` timestamp on `Tab` snapshot
- Browser pane fully controllable: open/navigate/snapshot/interact/close
- Workbench tools: `harnessFind`, `harnessGrep`, `harnessRecent`, `harnessErrors` (LSP diagnostics)
- Direction: agent→Harness (opposite of shelved ACP which is Harness→agent)
- Full architecture: `agent-memory/knowledge/architecture/mcp-server.md`

## P13 — Split Pane Parity
- PBI-SPLIT-001–005 implemented
- Same-direction flatten, equal distribution, resize handles
- Pane zoom/unzoom, rotate, swap
- tmux-compatible split commands (`:sp`, `:vsp`)
- Merged via PR #10

## P15 — Integration Roadmap
- Sequencing plan for P4+P11+P12+P13+P14+P16
- All steps complete — coordination artifact, not a feature itself

## P16 — Agent/Session Board
- PBI-BOARD-001–005 complete (006 closed — auto-clear sufficient)
- Sidebar board tab: session cards with agent status, timing, output summary
- CLI: `harness-cli board`
- MCP read-only exposure

## P17 — Structural Refactor
- PBI-001/002/003/005 complete
- SessionCoordinator decomposed into services
- UI/ subfolder reorganization
- PBI-004 deferred (build time 9s, not worth risk)

## P18 — UI Automation (Robot Framework)
- 25 automated tests via Robot Framework + osascript (System Events)
- CLI verification paths
- No Appium/XCUITest dependency
- Accessibility identifiers added to key UI elements

## P19 — Terminal Workbench Migration Layer
- PBI-WB-001–007 fully implemented
- `:find`, `:grep`, `:make`, `:errors`, `:recent` workbench commands
- IDE migrant bridge (VS Code-like workflows in terminal)

## P20 — Harness-Term Agent (Shelved)
- Shelved — terminal-first flow sufficient (kiro-cli/claude/codex typed directly)
- Revisit when pain point emerges
- Design docs preserved for future re-enable

## P14 — Embedded Browser Pane
- PBI-BROWSER-001–005 implemented
- WKWebView pane for localhost preview
- harness-mcp browser tools (navigate, screenshot, evaluate)
- Post-release fixes in v2.7.1

## P24 — Supacode-Inspired Competitive Features (Consolidated)
- Status: Complete (archived from active plan list on 2026-06-20)
- Competitive analysis consolidated Supacode, P21 actionable agent layer, and P4 follow-ups into Harness-specific parity work.
- Key completed scope: project config/lifecycle scripts direction, agent status/auto-start UX, worktree-per-session model, GitHub PR/CI integration plan, sidebar density, and CLI scripting model.
- P21 ACP sideband/provider/brain/execution layers remain shelved separately; P4 follow-ups were absorbed into P24.

## P28 — Browser DevTools API (v3.7.0 → v3.9.0)
- harness-mcp 14 browser tools: Open, Navigate, Wait, Snapshot, Interact, Close, Screenshot, Network, Cookies, Storage, Evaluate, GoBack, GoForward, Reload
- IPC wiring: BrowserRequestPayload → DaemonServer → GUI BrowserPaneView → MCP response
- ToolPolicy gate for control tools (evaluateJS, interact, close, navigate)
- MCP config wired globally (Claude, Codex, Kiro, Gemini)
- Replaces chrome-devtools-mcp (~70-75% token savings)

## Sidebar SwiftUI Migration — Option B (v3.9.0)
- NSTableView → SwiftUI List via @Observable SidebarListModel + NSHostingView
- Eliminates RL-051 crash class (row-index out-of-range) permanently
- HarnessSidebarPanelVC reduced from 72KB → ~30KB
- Context menus via .contextMenu {} SwiftUI modifier
- snapshotChanged → model.update() (SwiftUI handles diffing)

## HarnessCore Package Split (v3.9.0)
- HarnessCore (30+ subdirs) → HarnessCore + HarnessCommands + HarnessIPC + HarnessSettings
- 20+ files moved to HarnessCommands (parser, keybindings, format, pane layout)
- IPC types moved to HarnessIPC (IPCMessage, IPCCodec, models)
- Settings moved to HarnessSettings (AIAgentConfig, HarnessSettings, ProjectConfig)
- Faster incremental builds, cleaner dependency graph

## SwiftUI Migration (v3.9.0 – v3.11.x)
- Sidebar session list + chrome (pill, tab bar, section label, footer) → SwiftUI List + @Observable, `HarnessControls.swift` deleted, eliminated RL-051 (row-index out-of-range) crash class
- Settings (S1–S9) → SwiftUI, `SettingsViewController` eliminated
- Command palette → `NSHostingController(rootView: PaletteView)` (wave 2, `760705a`)
- Notifications inbox → `AgentInboxPanelView` SwiftUI (wave 2)
- Agent notch → `AgentNotchRootView: View` SwiftUI content, `NSPanel` shell (wave 2)
- Terminal tab bar → hybrid: `TerminalTabBarView: NSView` shell + SwiftUI pills (`TerminalTabBarBody`, `TabPillView`), drag-drop stays AppKit (wave 2)
- Net −424 lines across the wave-2 four components; no manual `NSTableViewDataSource`/cell-reuse left in these paths
- **Browser tab bar deliberately skipped (2026-07-01)** — still `NSStackView`/`NSButton` in `BrowserPaneView.swift`; works fine, no bug class to eliminate, not worth WKWebView-bridging regression risk

## P30 — Otty Feature Parity (v3.11.x)
- Command Recipes (⌘⇧R) — `RecipesStore` + `RecipePickerController`, fuzzy picker
- Floating Terminal (⌘⌥F) — `FloatingPaneController`, NSPanel, persisted frame
- Tab Overview (⌘⇧\\) — `TabOverviewController`, thumbnail grid, click to switch
- Frecency dir picker (⌘⇧J) — zoxide-powered, ↩ cd / ⌘↩ new tab
- Session Resurrection audit (Zellij-inspired) — verified quit/relaunch, daemon crash/restart, reboot, multi-window restore
- Block output tint + AI explain (Phase 12b/12c) — border, collapse/expand, re-run button
- Vi mode at terminal input layer
- Deferred (intentional, not blocked): Kitty Graphics Protocol, WASM plugin runtime — no demand yet

## P23 — SSH Remote Host Manager (v3.9.x – 2026-07-01)
- Settings → Remote tab: host list (add/remove/duplicate), detail form (Name/SSH target/Port/Identity/Jump/Socket path), Save/Revert, Connect/Disconnect
- Toolbar badge showing active remote host name; click disconnects (or opens Settings → Remote when local)
- Socket auto-detect (PBI-SSH-008, 2026-07-01): new `harness-cli socket-path` command prints `HarnessPaths.socketURL.path`; `SSHTunnelManager.detectSocketPath` runs it over `ssh` reusing the tunnel's arg-validation seams (`validatedSSHTarget`/`validatedUserSSHArgs`); consumed by both `SettingsRemoteView`'s "Detect" button and `harness-cli remote add --detect` (alternative to passing `--socket` by hand)
- TCP transport remains suspended — no TLS layer, SSH tunnel covers all current remote use cases

## P32 — Task-Based Agent Worktrees (2026-07-01 – 2026-07-02)
- Explicit "New Agent Task" command-palette action — `SessionLifecycleService.addAgentTask(to:taskName:)` calls `WorktreeManager.create` then the existing `addSession(to:cwd:name:)`, reusing P24's `setupScript` auto-run for free; failure path (no git repo) shows `NSAlert` instead of silently no-oping
- `Tab.taskName: String?` added (optional-backfill decode pattern); `displaySubtitle`/sidebar title precedence now `taskName > gitBranch > cwd`
- Bonus fix: `worktreePath`/`parentRepoPath`/`taskName` were never actually threaded from the GUI's `addAgentTask` → `.newSession` IPC call (only the CLI did) — wired through for real
- `archiveScript` (schema-only, zero call sites before this) wired into `SurfaceRegistry.handle(.closeSession)`, runs via `/bin/sh -c` with a 30s hard-kill timer before `WorktreeManager.remove`
- Task switcher: no new UI needed — existing ⌘1-9 (`MenuTarget.selectWorkspaceNumber`) already reaches task-worktree sessions as regular workspace entries
- `.harness-worktrees/` added to `.gitignore` (was getting staged as regular files)
- Tests: `WorktreeIsolationTests` (core), `WorktreeIsolationDaemonTests` (archiveScript teardown) — both 10/10; `Tests/robot/run.sh` 10/10
- **Shipped (2026-07-02) — `setPaneLabel` MCP tool for pane purpose/label tagging.** Backlog item from 2026-07-02 (below, corrected on build): the original note assumed reusing `IPCRequest.updateTabTitle` needed "no new schema/field." That assumption was wrong on inspection — `updateTabTitle` actually mutates `Tab.title` (tab-scoped, via `SessionEditor.updateTabTitle`'s `tabIndex(surfaceID:)` lookup), not `PaneSurface.title`, and is gated on the per-tab `automatic-rename` flag so it silently no-ops or gets clobbered by the next OSC title update — unusable as a durable per-pane label, and the wrong granularity besides (can't protect one pane's label without breaking OSC titles for its sibling in the same tab). Also found `PaneSurface.title` itself was never mutated anywhere in the codebase (vestigial). Built instead: a dedicated `PaneSurface.label: String?` field (`PaneNode.swift:101`), never touched by OSC/shell output; `PaneNode.setSurfaceLabel(_:label:)` tree-mutator; `SessionEditor.setPaneLabel`; new `IPCRequest.setPaneLabel(surfaceID:label:)` + `SurfaceRegistry` handler; exposed as `"label"` in `harnessList`'s `paneJSON`; policy-gated `setPaneLabel` MCP tool (`ToolPolicy.dangerousTools`, mirrors `sendPaneText`). Tests: `PaneLabelDaemonTests` (4/4 — set/read-back, nil clears, doesn't touch `title`, unknown surface errors). `swift build`/`swift test` (2 pre-existing unrelated failures only)/`Tests/robot/run.sh` 10/10 clean.

## P33 — Visibility Gaps: PR status, cross-pane notifications, diff popover (2026-07-02)
- PR checks-status dot: found `PRStatusPoller` was dead/duplicate code — the *live* PR path was already `SidebarListModel.fetchGitMetadata`. Swapped its hand-rolled `gh pr view` call for `GitHubCLIClient().prForCurrentBranch` (which parses `statusCheckRollup`), added `RepoGitMetadata.prChecksStatus`, rendered as a green/red/yellow dot next to the existing `#123` badge. Deleted `PRStatusPoller.swift` + its dead `AppDelegate` call site.
- Sidebar notification text: found `OSCNotificationParser` (OSC 9/99/777) has zero call sites — the *live* path is IPC `.notify` → `SurfaceRegistry.markWaiting` → `Tab.status/.notificationText`, which already drove a per-pane glowing ring, dock badge, native notification, and Notch panel. Only the sidebar itself was missing the message text — added `SidebarSessionItemRow.waitingNotificationText`, shown in `.systemBlue` when `tab.status == .waiting`.
- Diff popover: `GitPanelView.presentCommitDetail` was a fully-built, zero-call-site popover (file-nav bar + colored diff, same dead-code-next-to-live-path shape). Rewired the commit-card click to it (`previewCommitDetail`); old full-tab-open flow kept via context menu ("Open Full Diff in Tab").
- Same-session bug found + fixed: sidebar rendered blank/blurred on first `⌘\` reveal after every launch, predating this work — root cause was `sidebarContainer.translatesAutoresizingMaskIntoConstraints = false` with no constraint of its own, colliding with an existing CASE-042 fix (`layoutSubtreeIfNeeded()`) that collapsed it to 0-width. Fix: removed the `= false`. See RL-062/CASE-061.
- Post-commit review (Opus, 12-agent workflow) found + fixed 4 defects: a popover-anchored-to-detached-view crash race in `previewCommitDetail` (guard `card.window != nil` after await, RL-063), `waitingNotificationText` only checking `activeTab` instead of scanning all tabs (contradicted its own "regardless of focus" goal), a `gh` path-resolution mismatch between the sidebar's availability guard and `GitHubCLIClient`'s actual fetch (added the same `which gh` fallback to both), and a duplicated `git show` invocation (extracted to `fetchCommitDiff`).
- `swift build`/`swift test` (only the 2 pre-existing unrelated failures)/`Tests/robot/run.sh` all clean throughout.

## P34 — Block-Based Terminal / Command Grouping (2026-07-02)
- F1: zsh/fish shell-integration now emit `133;C;<base64 command>` via their native preexec hooks (the shell's own knowledge of the typed command, not a screen-scrape guess) — no shell previously emitted this boundary at all. bash deferred (DEBUG-trap footgun, no reentrancy guard yet). New per-pane `TerminalBlockStore`/`TerminalBlock` (`HarnessTerminalEngine/Emulator/TerminalBlock.swift`), decoupled from scrollback so a block survives `dropHistoryHead` eviction. Fixed the pre-existing `ponytail:`-flagged Re-run regex-prompt-strip to use the real command text. Bonus: emitting `C` also fixes the latent bug where `onCommandFinished`'s duration/"long command finished in background" notification never fired against a real shell.
- F2: `BlockActionBar` gained Copy Output Only / Copy Command Only (shown only when the pane's shell actually captured a block — bash panes keep the original 2-button bar). `TerminalBlock` promoted back to public; `block(atPromptLine:)`/`lastBlock`/`block(id:)`/ranged `captureLines(fromLine:toLine:)` added across `TerminalEmulator`→`HarnessGridTerminal`→`HarnessTerminalSurfaceView`. Bookmark explicitly deferred by user, not built.
- F3: `harnessGetLastBlock`/`harnessGetBlock` MCP tools. Found the daemon never parses OSC 133 live (only client-side `TerminalEmulator` instances do) — reused `RealPty.captureGrid`'s existing "replay retained scrollback through a fresh headless instance on demand" pattern instead of building a new always-on daemon parser; not retroactive backfill since the replayed bytes contain the same live `C`/`D` sequences originally parsed. New `IPCRequest.getBlock`/`IPCResponse.blockInfo(BlockSummary?)` (`HarnessIPC`), `RealPty.block(id:)`, `SurfaceRegistry.handle(.getBlock)`.
- Interviewed before implementing (plan doc's own premise was partly wrong — no shell emitted `133;B`/`133;C` at all, and `SemanticMark` never persisted command text); consulted `advisor` before touching 3 shell scripts and again before the F3 daemon-architecture question. A transient signal-11 crash in an unrelated Metal/GPU test during one full-suite run was confirmed pre-existing/order-dependent via `git stash` A/B against the clean baseline commit, not caused by this work.
- Tests: `TerminalBlockStoreTests`, `HarnessGridTerminalTests` block-forwarding cases, extended `ShellIntegrationTests`. `swift build`/`swift test` (2 pre-existing unrelated failures only)/`Tests/robot/run.sh` 10/10 clean throughout.
- **Shipped (2026-07-02) — replaced ⌘-click with a right-click context menu for block actions.** Resolves the 2026-07-02 backlog decision below (direction (a) chosen over (b) via user pick). `BlockTintOverlay`'s `BlockActionBar` (~95 lines) removed entirely; ⌘-click in `HarnessTerminalSurfaceView+SelectionAndLinks.swift` now only opens links (matching other terminal apps' convention). Block actions (Copy Output Only / Copy Command Only / Re-run) moved into `menu(for:)` (`+Find.swift`), gated on whether the clicked line falls in a captured OSC-133 block; degrades to Re-run-only for shells that only emit `A`/`D` (bash). `cell(at:)` widened from `private` to internal (cross-file access within the same type's extensions needs internal, not private). Orphaned `selectionString`/`copyBlock()` wrappers deleted (zero remaining call sites after the move). Tests: `BlockContextMenuTests` (2/2 — full menu when a block is captured, Re-run-only otherwise).
