# Context — harness-terminal

## Now
- **Task:** idle
- **Branch:** main (fix/memory-leak-audit merged)
- **Status:** v3.9.4 released — GitHub Actions release workflow triggered

## Last Session (2026-06-26) — Memory-leak audit + v3.9.4 release prep

**Diagnosis (live pid via vmmap/footprint):** 34 GB was MALLOC_SMALL (Swift heap), NOT GPU/Metal. Dominant cause = `existingHosts` strongly pinning per-pane TerminalScreen graphs — **already fixed in `0430ed8`**; the leaking process ran a binary built Jun 24, before that Jun-25 fix. → user must rebuild+reinstall (`make install`) and re-measure over a long session.

**Fixed this session (real, smaller leaks remaining on main):**
- `SessionCoordinator.inlineAIControllers/aiChatControllers` leaked one pair per closed pane (insert-only dicts). Fix: `TerminalPaneRegistry.onRetire` hook from `retire()` (covers removeHost + prune) drops both entries.
- `BrowserPaneView` injected network capture array uncapped → cap 500 + monotonic id.
- Guard: `Tests/robot/memory_leak_guards.robot` (3 tests, green) + `Tests/robot/helpers/check_retire_coverage.py` structural guard for future dicts.

**v3.9.4 prep done:**
- Info.plist → 3.9.4 / build 170
- HarnessVersion.swift updated
- CHANGELOG.md entry written with real content (2 Added, 5 Fixed)
- GeneratedReleaseNotes.swift regenerated
- graphify updated (16146 nodes, 36693 edges)
- knowledge/cases/memory-leak-audit.md created

**Reverted:** an autoreleasepool wrap on the Metal present loop — GPU was ruled out by vmmap.

**Flagged, separate:** robot `Bug 1 - Browser Pane Reuse On Rebuild` fails on clean main (pre-existing) — `existingBrowserPanes`/`collectBrowserPanes()` gone from ContentAreaViewController; browser panes may no longer be reused across rebuilds. Needs its own look.

## Previous Sessions

### 2026-06-25 — `harness view` opens sidebar viewer
- `harness-cli view <file>` now opens the file in the sidebar file editor when inside Harness, instead of printing to stdout. OSC 7735 mechanism.

### 2026-06-24 — Otty Feature Import
- Hint mode (Cmd+Shift+U) — Vimium-style link picker overlay
- Vi mode / autocomplete intentionally skipped (shell handles it better)
- Send selection → AI chat (~30 lines) — still pending, low priority

### 2026-06-23 — Sidebar SwiftUI Migration Complete
- All 6 phases done; NSTableView removed; VC 1676 → 890 lines

## Unresolved
- Cmd+\ intermittent failure — PrefixKeymap disarm-on-click fix committed but root cause unknown
- Pre-existing robot failure: "Bug 1 - Browser Pane Reuse On Rebuild"
