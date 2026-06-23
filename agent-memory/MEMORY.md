# Memory — harness-terminal

## Active Decisions
- [2026-06-24] `presentsWithTransaction` must be set BEFORE `drawableSize` changes in `layout()`. `viewWillMove(toWindow:nil)` resets the flag — external `setPresentsWithTransaction(true)` calls don't survive `removeFromSuperview()`.
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
