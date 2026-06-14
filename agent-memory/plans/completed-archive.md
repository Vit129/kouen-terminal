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

## P5 — ACP Client
- ACP core implementation exists in `HarnessCore/ACP`: `ACPClient`, `ACPSession`, `ACPProcess`, `ACPTransport`, `ACPMessage`, and `AgentConfig`
- `AgentChatPanelView` and settings-side ACP agent configuration remain in the app code
- Runtime entry point is intentionally disabled in the sidebar (`[ACP SHELVED] connectAgentIfNeeded()`)
- Shelved rationale is tracked in `agent-memory/knowledge/acp-client.md`

## P7 — Sidebar UI Polish
- Large-screen sidebar group header button visibility/alignment completed
- Session card spacing and file editor tab bar overlap polish completed
