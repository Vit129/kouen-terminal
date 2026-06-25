# Context — harness-terminal

## Now
- **Task:** None active — ready for next session
- **Branch:** main
- **Status:** idle

## Last Session (2026-06-25) — `harness view` opens sidebar viewer

**Completed:**
- `harness-cli view <file>` now opens the file in the sidebar file editor when inside Harness, instead of printing to stdout. Line numbers appear in the gutter (separate NSView) and are excluded from copy — matching the file preview behavior.
- OSC 7735 mechanism: CLI emits `\e]7735;<abs-path>\a` when `HARNESS_SURFACE_ID` is set → `TerminalEmulator.onOpenFile` → `HarnessTerminalSurfaceView.onOpenFile` → `TerminalHostView` delegate → `SessionCoordinator.terminalHostDidRequestOpenFile` → `MainExecutor.shared.executeSurfacingErrors(.workbench(.view(path:)))`
- CLI falls back to stdout when outside Harness

## Previous Session (2026-06-24) — Otty Feature Import

**Completed:**
- Hint mode (Cmd+Shift+U) — Vimium-style link picker overlay
  - `HintModeOverlay.swift` (NEW) — chip overlay + key monitor + typeahead + 3s auto-dismiss + mouse-dismiss
  - `HarnessTerminalSurfaceView+SelectionAndLinks.swift` — `visibleLinks()` + `activateHintLink()`
  - `TerminalHostView.swift` — `public var surfaceView`
  - `URLDetection.swift` — `allMatches(in:)`
  - `SessionCoordinator.swift` — `showHintMode()`
  - `BannerShortcutRegistry.swift` — `hintMode` keybinding
  - `MainMenuBuilder.swift` — View menu item + MenuTarget action
  - **Bug fix:** armed monitor without mouse-dismiss — same pattern as PrefixKeymap fix

**Skipped (intentional):**
- Vi mode — shell handles it better (`set -o vi`); CopyMode covers buffer nav
- Autocomplete — too large (Fig spec DB); AI inline (Option+Space) already exists

**Pending (low priority):**
- Send selection → AI chat (~30 lines) — context menu in `rightMouseUp` → `AITerminalChatController.prepopulate(text:)`

## Previous Session (2026-06-23) — Sidebar SwiftUI Migration Complete

**Completed (all 6 phases):**
- Phase 1: `SidebarListModel.swift` — `@Observable` model with rows, git metadata, worktrees
- Phase 2: `SidebarSessionListView.swift` — SwiftUI `LazyVStack` with all 5 row types
- Phase 3: `NSHostingView` bridge in VC — replaces NSTableView scroll
- Phase 4: `reload()` / `refreshMetadata()` wired to model — no more manual `reloadData()`
- Phase 5: Native SwiftUI `.contextMenu {}` on session and group header rows
- Phase 6: All dead NSTableView code removed — VC 1676 → 890 lines (~47KB reduction)

## Unresolved
- Cmd+\ intermittent failure — PrefixKeymap disarm-on-click fix committed but root cause unknown; next hypothesis: SwiftUI `NSHostingView` `performKeyEquivalent` interception after sidebar migration
