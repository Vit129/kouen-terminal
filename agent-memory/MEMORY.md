# Memory — harness-terminal

## Active Decisions
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
