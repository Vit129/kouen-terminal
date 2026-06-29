# Memory — harness-terminal

## Active Decisions
- [2026-06-29] **Tab-switch caching invariant:** `detachHostsOnly()` = structural rebuild only. Tab-switch path (`force=false`) MUST NOT call `detachHostsOnly()` before caching — hosts are shared single-instance; detach strips the cached container, fast path reveals empty = black. Always validate `Set(displayNode.allSurfaceIDs()).isSubset(of: cachedHosts.keys)` before fast-path reveal; evict+rebuild on mismatch. See `knowledge/bugs/tab-switch-black-screen.md` (4 FM).
- [2026-06-29] **force=true rebuild must evict cache, not overwrite with empty.** `detachHostsOnly()` followed by `containerCache[prevTabID] = old` stores an empty shell → black on revisit. Fix: `containerCache.removeValue(forKey:) + removeFromSuperview()` when `force=true`. Also: evict existing orphan before `containerCache[tabID] = newContainer` to prevent hidden-Metal-surface leak.
- [2026-06-27] **GitPanelView caching gate.** Added state caching (porcelain status, branch, aheadBehind, numstat, log, and repo entries) in [GitPanelView.swift](file:///Users/supavit.cho/Git/Personal/harness-terminal/Apps/Harness/Sources/HarnessApp/UI/Git/GitPanelView.swift) to prevent tearing down and rebuilding changes/history/repos stacks on every FSEvent/refresh. This prevents massive allocation spikes of `NSTextField`/`NSTextFieldSimpleLabel` in active workspaces.
- [2026-06-27] **`.ai/` removed.** Protocol lived in CLAUDE.md already; `.ai/memory-protocol.md` was not auto-loaded by any agent and was copied not symlinked — overhead without benefit. Canonical lookup: grep `agent-memory/` for decisions/knowledge, `graphify query` for code nav, headroom for token compression, ponytail for lazy-dev mode. All projects cleaned.
- [2026-06-27] **File tree roots at git root, not CWD.** `cd` into a subdirectory expands the tree instead of re-rooting it. Guard: `lastFileTreeCWD` — `revealFileInTree` fires only when CWD changes, not every snapshot. Cleared on session change. Decision: no back button — re-rooting collapses context and a back button needs state that force-`cd` would corrupt. CASE: sidebar-swiftui-migration.
- [2026-06-27] **Panel-only UX for Open With Harness.** File opens in sidebar file tree (expand+scroll), terminal opens at git root. No file viewer, no back button, no terminal state change beyond creating/selecting a session at git root. Why: simpler, no back-stack edge cases, terminal input not interrupted.
- [2026-06-27] **chromeEpoch pattern.** Static `HarnessDesign` vars can't be observed by SwiftUI. Add `var chromeEpoch: Int = 0` to each `@Observable` sidebar model. `applyChromeColors()` increments all epochs; SwiftUI bodies consume `let _ = model.chromeEpoch` to subscribe.
- [2026-06-26] **Worktree / cwd identity rule:** `RealPty.probeWorkingDirectory()` must probe the shell's own PID, never `deepestReadableDescendant`. A session maps 1:1 to a worktree; transient foreground subprocess in another dir must NOT hijack the session's cwd → would break tab pill, git panel, file tree simultaneously. The descendant-cwd idea was intentional (follow agent cd) but wrong for directory identity. CASE-043.
- [2026-06-26] **NSSplitView animation + NSHostingView:** when driving a manual per-frame animation (`setPosition` / `split.layout()` loop), add `panel.layoutSubtreeIfNeeded()` at animation end for any panel containing SwiftUI NSHostingViews. `NSSplitView.layout()` sizes the panel but does NOT recursively flush SwiftUI's layout engine → hosting views that started at zero-frame stay blank. CASE-042.
- [2026-06-26] **Daemon headless repro pattern:** `HARNESS_HOME=/tmp/x .build/debug/HarnessDaemon` (background) + `harness-cli new-session --cwd` + `harness-cli send --surface ... --text "cmd\r"` + poll `list-surfaces --json` → deterministic data-layer test without GUI. Used to confirm cwd bleed: child subshell in repoB shows parent HT.cwd = repoB (bug) vs repoA (fixed).
- [2026-06-26] Huge-RSS triage: run `vmmap -summary <pid>` / `footprint <pid>` on the LIVE process FIRST — MALLOC_SMALL/LARGE vs IOSurface/IOAccelerator instantly separates a Swift-heap leak from a GPU/drawable leak. A 34 GB session was MALLOC_SMALL (heap), NOT GPU — an autoreleasepool "fix" would have been wrong-target. Measure the region, don't theorize from source. Also check installed-app mtime vs the fix commit before chasing a "still leaks" report (the leaking binary predated 0430ed8). (CASE: memory-leak-audit)
- [2026-06-26] Per-surface state kept OUTSIDE `TerminalPaneRegistry` (e.g. `SessionCoordinator.inlineAIControllers/aiChatControllers`) leaks one entry per closed pane. Fix pattern: `TerminalPaneRegistry.onRetire` hook fired from `retire()` — the single chokepoint both `removeHost` and `prune` funnel through. Any future per-surface dict must hook onRetire, not patch each close site.
- [2026-06-25] OSC 7735 = Harness custom sequence for CLI→app file open. Pattern reusable for any future CLI-triggered app action: emit OSC when HARNESS_SURFACE_ID set → TerminalEmulator callback → SurfaceView → TerminalHostDelegate → SessionCoordinator → MainExecutor.shared.
- [2026-06-24] Hint mode armed monitor MUST have mouse-dismiss + auto-timeout — same bug class as PrefixKeymap. Pattern: `matching: [.keyDown, .leftMouseDown, .rightMouseDown]` + `asyncAfter(3s)`.
- [2026-06-24] Vi mode at emulator layer = wrong layer. Shell (`set -o vi`) handles input editing; CopyMode handles buffer nav. Don't build terminal-level vi input mode.
- [2026-06-24] Otty autocomplete (Fig spec DB + history ghost text) too large to replicate. InlineAICompletionController (Option+Space) covers AI suggestions. Shell plugins cover history.
- [2026-06-24] `presentsWithTransaction` must be set BEFORE `drawableSize` changes in `layout()`. `viewWillMove(toWindow:nil)` resets the flag — external `setPresentsWithTransaction(true)` calls don't survive `removeFromSuperview()`.
- [2026-06-23] `NSSplitView.adjustSubviews()` in sidebar toggle path causes terminal blink — NEVER use it in paths containing Metal surfaces. Use `setSidebarWidth() + split.layout()` only. (RL-058)
- [2026-06-23] `PaneLifecycleManager` fast path: must guard with `cached !== paneContainer` to prevent skipping rebuild on in-place structural changes (e.g. adding browser pane). (RL-057)
- ACP shelved — ongoing. Re-enable when adapters ship natively with agent CLIs.
- HarnessCore package split blocked — `AgentSnapshot/AIAgentConfig/WorkbenchCommand` must be promoted to core before extraction.

## Tech Debt
- PBI-REFACTOR-004: `#if HARNESS_ACP` deferred

## Conventions
- Build: `make preview`
- Test: `swift build` + all test targets
- Services: unowned back-reference to coordinator, lazy init

## Protocol Compliance Notes
- [2026-06-22] `skill-auto-detect.md` no longer exists at `~/.claude/rules/` — skill routing is now in `routing.md`.

## Knowledge Index
- RL lessons → `knowledge/rl-lessons.md`
- Architecture decisions (done) → `knowledge/architecture/decisions.md`
- Zombie crash detail → `knowledge/bugs/zombie-crash-macos26.md`
- Browser pane → `knowledge/ui/browser-pane.md`
- Split panes → `knowledge/ui/split-panes.md`

## 2026-06-25 — OSC 7735:  opens sidebar file viewer
- New CLI→app channel via custom OSC sequence (7735). Pattern: emit OSC from CLI when HARNESS_SURFACE_ID set → TerminalEmulator callback → SurfaceView → TerminalHostDelegate → SessionCoordinator → MainExecutor.shared. Reuse this pattern for any future CLI-triggered app-layer actions.

## 2026-06-27 — Block output tint + AI explain (Phase 12b)
- `BlockTintOverlay: NSView` flipped, CA-backed, added as subview of TerminalHostView — renders above Metal surface via CA compositor. Draws alternating 2.8%/5.8% white-alpha tints per OSC 133 command block. Theme-agnostic (white alpha works on any dark terminal).
- `BlockActionBar` shown on `onBlockSelected` callback (Cmd+Click). Two buttons: Copy (wraps `copyBlock()`) + AI ✦ (prefills `onAskAI` with block text). Auto-dismisses on scroll.
- Public API added to `HarnessTerminalSurfaceView`: `promptRows`, `selectionString`, `copyBlock()`, `onBlockSelected`.
- `CGWindowListCreateImage` removed in macOS 15 → tab thumbnails use `bitmapImageRepForCachingDisplay(in:)` + `cacheDisplay(in:to:)` instead.
- `QuickTerminalController` deleted — blank terminal on open (can't type); redundant with ⌘T + app switch.
- Vi mode at terminal-input level: sends escape sequences to PTY (not `set -o vi`). Esc → normal mode; i/a/A/s → insert. State stored on `HarnessTerminalSurfaceView.viModeState`.
- `TabCell: NSView` subclass preferred over NSButton + associated objects for click handling — avoids Swift 6 `nonisolated(unsafe)` on non-Sendable `AnyObject` (mutable global state error).
