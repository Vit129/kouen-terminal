# Context — harness-terminal

## Now
- **Task:** otty-features — medium phases in progress
- **Branch:** main (ahead of origin by 10 commits, pushed to d9e74b9)
- **Status:** Phases 1, 3–9, 17, 20 done and pushed. Medium phases 10, 11, 18, 19 remain. Large phases 2, 12, 14, 15, 16 not started.

### This session (2026-06-27) — otty-features implementation

**Completed phases (on main):**
- Memory fix: `DispatchSource.makeMemoryPressureSource` → trims inactive scrollback (54f6a0b)
- Phase 3: right-click → Ask AI prefill (b104eed)
- Phase 4: scrollback search ⌘F; findInFiles → ⌘⇧F (5fac8a7)
- Phase 5: click-to-move cursor (ee002b8)
- Phase 6: `SecureInputMonitor` auto-enables Secure Input on password prompts (be60091)
- Phase 7: Ctrl+C copies selection first (649cf01)
- Phase 17: git branch in tab bar via `.git/HEAD` direct read (649cf01)
- Phase 1: `HintModeOverlay` ⌘⇧U (cba7cdc — pre-existed)
- Phase 8: `ComposerPanel` ⌘⇧E (f753a14)
- Phase 9: `PromptQueue` + `PromptQueueBar` ⌘⇧↩ (d9e74b9)
- Phase 20: session resurrection audit — no gaps found (window frame + scrollback already persisted)

**AI streaming fix:** double-read on pipe (`while true { let chunk = availableData }`) — 160d064

**Key decisions:**
- ⌘F = scrollback search (terminal convention), ⌘⇧F = findInFiles (IDE convention)
- Phase 14 floating panes → use ⌘⌥F (⌘⇧F taken)
- `onRawOutput` hook added to `HarnessTerminalSurfaceView` — `onOutputTrigger` is dead in prod (offMainParserFramePipelineEnabled)

### This session (2026-06-27) — XCTest coverage + skill infrastructure

**Commits:**
- `448f68a` — test: PaletteModel 9 XCTest cases + delete stale S9 orphans (HarnessSliderTests, SettingsWindowCloseProxyTests)

**Infrastructure:**
- `~/.claude/skills/xctest-macos/SKILL.md` — new skill for XCTest on macOS Swift targets
- `~/.claude/skills/xctest-macos/references/swift6-xctest.md` — @MainActor patterns, async tests, @Observable model testing
- `~/.claude/rules/routing.md` — XCTest/unit test keywords now bypass AIDLC → xctest-macos skill
- `~/.claude/skills/macos-swiftui/SKILL.md` — testing row added pointing to xctest-macos

**Testability fixes in PaletteModel:**
- `PaletteModel`: `private` → `internal`
- `PaletteFileEntry`, `PaletteGrepMatch`: `fileprivate` → `internal`

**Previous session (same day):** AppKit → SwiftUI migration CLOSED. Remaining AppKit files commented as intentional — GitPanelView, WorkspaceFileTreeView, FileViewerViewController.

### This session (2026-06-27) — SwiftUI wave 2: 4 UI components migrated

**Commits (this session):**
- `760705a` — AppKit → SwiftUI wave 2: CommandPaletteController, TerminalTabBarView, FileEditorTabBarView, AgentInboxPanelView (net −424 lines)

### Previous: 2026-06-27 — Sidebar chrome SwiftUI + Open With Harness + file tree git root

**Commits (previous session):**
- `bb68fd3` — `HarnessControls.swift` deleted (−998 lines, 9 dead AppKit classes)
- `a072edf` — sidebar section label + footer → SwiftUI
- `a6d59a9` — sidebar tab bar → SwiftUI `Picker(.segmented)`, `selectedTab` onto `SidebarSectionModel`, `@objc sidebarTabChanged` removed
- `36fde38` — Open With Harness for source files: `ExternalOpenKind.filePreview`, Info.plist `public.source-code`/`public.plain-text`, routing chain AppDelegate → MainSplitVC → sidebar
- `cabcb86` — Open With file → terminal opens at git root, tree reveals file
- `d3a700f` — file tree roots at git root; expand+scroll to CWD instead of re-root; `lastFileTreeCWD` guard in all 3 sites

**Sidebar chrome is now 100% SwiftUI:** WorkspacePillView ✓, SidebarSessionListView ✓, SidebarSectionLabelView ✓, SidebarTabBarView ✓, SidebarFooterView ✓

**Open With Harness behaviour:**
- Right-click any source file in Finder → Open With → Harness
- File tree expands to the file and scrolls to it (no viewer, no back button)
- Terminal opens at git root of that file (new session if none exists)

**Key design decision: panel-only (no back button)**
- Re-rooting on every `cd` disrupts context — instead tree stays at git root
- Expanding + scrolling is stateless: no back stack, no terminal state, no force-cd interruption

**Still AppKit (won't migrate):** SoftIconButton, SidebarTitlebarHeaderView (mouseDownCanMoveWindow), child panels (GitPanelView, WorkspaceFileTreeView, FileViewerVC)

---

### Previous: 2026-06-27 — SwiftUI wave 1 + Settings S6–S9 complete

**Wave 1 (same day):**
- HarnessSidebarPanelViewController+DragReorder.swift — deleted (dead stub)
- NotificationBellButton.swift — deleted (zero call sites)
- Toast + AboutPanelController → SwiftUI
- WorkspacePillButton → WorkspacePillModel + WorkspacePillView (chromeEpoch pattern)

**Settings S6–S9:**
- S6: SettingsAdvancedView, S7: SettingsRemoteView, S8: SettingsRootView + NavigationSplitView
- S9: 10 AppKit files deleted (−2800 lines)
- Info.plist → 3.9.5 / build 171

**Cmd+\ black flash fix:** `MainActor.assumeIsolated` + `presentsWithTransaction` bracketing

---

### Previous sessions (abbreviated)

| Date | Task | Key outcome |
|------|------|-------------|
| 2026-06-26 | cwd bleed during builds | `deepestReadableDescendant` removed; shell pid reported directly |
| 2026-06-26 | Memory-leak audit | `existingHosts` pin fixed; BrowserPaneView capped; v3.9.4 prepped |
| 2026-06-25 | `harness view` | OSC 7735 → sidebar file viewer |
| 2026-06-24 | Otty features | Hint mode (Cmd+Shift+U) |
| 2026-06-23 | Sidebar SwiftUI migration | NSTableView removed; VC 1676 → 890 lines |

## Unresolved
- Pre-existing robot failure: "Bug 1 - Browser Pane Reuse On Rebuild" (BrowserIntegrationController refactor changed call sites)
