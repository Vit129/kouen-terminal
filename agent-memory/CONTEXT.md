# Context — harness-terminal

## Now
- **Task:** tab-switch black screen ✅ + display-switch Metal fix ✅
- **Branch:** `fix/display-switch-black-screen` (ready to merge; squash debug commit `d1e0424` first)
- **Status:** All 4 failure modes fixed. See `knowledge/bugs/tab-switch-black-screen.md`.

### 2026-06-29 — Tab-switch black screen

4 fix commits on `fix/display-switch-black-screen`:
- `f6a0182` skip `detachHostsOnly()` on tab switch (FM-1: detach-then-cache)
- `2b9295d` `forceRepaint()` via `nativeView.layout()` (synchronous Metal repaint on reveal)
- `1a2ca4c` evict cache on `force=true` rebuild (FM-2: structural rebuild caches empty shell)
- `9c5c1fa` validate host set before fast-path reveal + plug orphan overwrite (FM-3 host theft, FM-4 leak)
- `0a5f2fe` restore Metal after display switch (separate fix, same branch)
- `d1e0424` NSLog debug probes — **squash before merge**

---

## Previous
- **Task:** otty-features — ALL phases complete ✅
- **Branch:** main
- **Status:** P1–P12b, P14–P20 shipped. P13 (Kitty Graphics) + P21 (WASM) deferred. P16 was pre-existing.

### This session (2026-06-27) — Phase 2 + 12 + 12b + 14 + 15

**Commits:**
- `5a7eb10` — Phase 2 (Vi modal editing) + Phase 12 (Cmd+Click block selection)
- `0e608ce` — Phase 12b (block output tint + AI explain action bar)
- Phase 14 (Floating panes ⌘⌥F) + Phase 15 (Tab thumbnails ⌘⇧\\) — in earlier commits this session

**What shipped:**

| Phase | Feature | Key files |
|-------|---------|-----------|
| P2 | Vi modal editing (Esc = normal, hjkl/wb/0$/x/i/a/A) | `+ViMode.swift`, `HarnessTerminalSurfaceView.swift` |
| P12 | Cmd+Click block selection (OSC 133 boundaries) | `+SelectionAndLinks.swift` |
| P12b | Block tint overlay + AI ✦ action bar | `BlockTintOverlay.swift`, `+Thumbnail.swift` |
| P14 | Floating terminal pane (⌘⌥F, NSPanel) | `FloatingPaneController.swift` |
| P15 | Tab overview grid (⌘⇧\\, 4-col, 200×150 thumbnails) | `TabOverviewController.swift`, `+Thumbnail.swift` |

**Architecture decisions this session:**
- `BlockTintOverlay` is a flipped `NSView` composited above Metal surface via CA compositor. Reads `promptRows` from emulator via new public accessor. Alternating 2.8% / 5.8% alpha white tints → theme-agnostic.
- `onBlockSelected` callback on surfaceView fires after Cmd+Click → overlay shows `BlockActionBar` (Copy + AI ✦). AI ✦ prefills chat via existing `onAskAI` hook.
- Tab thumbnails: `CGWindowListCreateImage` removed in macOS 15 → replaced with `bitmapImageRepForCachingDisplay(in:)` + `cacheDisplay(in:to:)`.
- `TabCell: NSView` subclass instead of NSButton + associated objects to avoid Swift 6 mutable global error.
- `QuickTerminalController` deleted — blank terminal on open, can't type; redundant with ⌘T + app switch.
- Vi mode wired at terminal-input level (NOT shell `set -o vi`): sends cursor-move escape sequences to PTY when in normal mode. Toggle ⌘⌃V from menu.

**New public API on `HarnessTerminalSurfaceView`:**
- `var promptRows: [Int]` — OSC 133 prompt buffer line indices
- `var selectionString: String?` — wraps internal `selectionTextIfAny()`
- `func copyBlock()` — wraps internal `copySelection()`
- `var onBlockSelected: ((_ startLine: Int, _ endLine: Int) -> Void)?`
- `var viModeState: ViInputMode` + `var onViModeChanged: ((ViInputMode) -> Void)?`
- `public var promptGutterEnabled: Bool` (was private)

---

### Previous session (2026-06-27) — otty-features waves 1–3

**Completed phases:**
- Phase 3: right-click → Ask AI prefill (b104eed)
- Phase 4: scrollback search ⌘F; findInFiles → ⌘⇧F (5fac8a7)
- Phase 5: click-to-move cursor (ee002b8)
- Phase 6: `SecureInputMonitor` auto-enables Secure Input on password prompts (be60091)
- Phase 7: Ctrl+C copies selection first (649cf01)
- Phase 17: git branch in tab bar via `.git/HEAD` direct read (649cf01)
- Phase 1: `HintModeOverlay` ⌘⇧U (cba7cdc — pre-existed)
- Phase 8: `ComposerPanel` ⌘⇧E (f753a14)
- Phase 9: `PromptQueue` + `PromptQueueBar` ⌘⇧↩ (d9e74b9)
- Phase 18: layout export/import `.harness-layout` JSON (LayoutFileStore)
- Phase 19: frecency directory jumping ⌘⇧J (FrecencyDirectoryStore + DirectoryPickerController)
- Phase 20: session resurrection audit — no gaps (window frame + scrollback already persisted)
- Phase 11: Recipes ⌘⇧R (RecipesStore + RecipePickerController)

### Previous: 2026-06-27 — XCTest coverage + skill infrastructure

- `448f68a` — 9 XCTest cases for PaletteModel + stale test file cleanup
- `~/.claude/skills/xctest-macos/SKILL.md` — new skill; routing.md updated

### Previous: 2026-06-27 — SwiftUI waves 1–2, Settings S6–S9

- Wave 1: Toast, AboutPanel, WorkspacePillView → SwiftUI
- Wave 2: CommandPalette, TerminalTabBar, FileEditorTabBar, AgentInbox → SwiftUI (net −424 lines)
- S6–S9: Settings panels + NSHostingView migration; −2800 lines AppKit deleted
- Info.plist → 3.9.5 / build 171

### Previous: 2026-06-27 — Sidebar chrome + Open With Harness

- Sidebar 100% SwiftUI: WorkspacePill, SessionList, SectionLabel, TabBar, Footer
- Open With Harness: right-click source file → sidebar file tree expand+scroll; terminal at git root
- File tree roots at git root; `cd` expands instead of re-rooting

### Previous sessions (abbreviated)

| Date | Task | Key outcome |
|------|------|-------------|
| 2026-06-26 | cwd bleed during builds | `deepestReadableDescendant` removed; shell pid direct |
| 2026-06-26 | Memory-leak audit | `existingHosts` pin fixed; BrowserPaneView capped; v3.9.4 |
| 2026-06-25 | `harness view` | OSC 7735 → sidebar file viewer |
| 2026-06-24 | Otty features | Hint mode (⌘⇧U) |
| 2026-06-23 | Sidebar SwiftUI migration | NSTableView removed; VC 1676 → 890 lines |

## Unresolved
- Pre-existing robot failure: "Bug 1 - Browser Pane Reuse On Rebuild" (BrowserIntegrationController refactor changed call sites)
- Statusline not showing after restart — deprioritized
