# P8: macOS 27 Golden Gate Adoption

## Context
WWDC26 announced macOS 27 Golden Gate (ships ~Sep 2026). Harness Terminal
currently targets macOS 26 Tahoe. This plan covers compatibility testing,
new API adoption, and visual alignment with the refined Liquid Glass system.

Key sessions:
- "Modernize your AppKit app" (WWDC26/289)
- "What's new in SwiftUI" (WWDC26/269)
- "Use SwiftUI with AppKit and UIKit" (WWDC26/272)
- Metal guide (no breaking changes for our renderer)

## Priority: High (P0 = ship-blocking, P1 = quality, P2 = nice-to-have)

---

## Phase 0 — Swift 6.3+ Concurrency Safety (P0, LESSONS FROM macOS 26.5 CRASH SAGA)

Critical findings from the 40-crash zombie incident (Jun 16–18, 2026).
These MUST be maintained on any macOS 27 SDK upgrade.

### Rules (enforced, not optional)

1. **Never use `nonisolated` on AppKit overrides** (`layout()`, `viewDidMoveToWindow()`, etc.)
   - Swift 6.3+ allows `@MainActor` class to override without `nonisolated`
   - `nonisolated` causes `@objc` thunk to add runtime executor check → crash on zombie

2. **Never use `MainActor.assumeIsolated`** in Timer/NotificationCenter/completion callbacks
   - Use `Task { @MainActor in }` instead
   - `assumeIsolated` can dereference NULL task context on macOS 26.5+

3. **Always `guard window != nil` in `updateTrackingAreas()`**
   - AppKit calls it during dealloc/layout after view left window
   - Without guard: tracking area re-created → event dispatched to zombie

4. **Deferred dealloc (500ms) for terminal hosts**
   - `TerminalPaneRegistry.retire()` holds host alive after removal
   - Covers keyUp, mouseMoved, resetCursorRects that arrive in later event iterations

5. **Avoid `Optional.map {}` closures in `@MainActor` code**
   - Closure triggers executor check → NULL if no task context
   - Use `if let` instead

6. **Kill app BEFORE build in install scripts**
   - Prevents crash loop where old binary crashes repeatedly during build

### Verification checklist for macOS 27 beta

- [ ] Run `grep -rn "override nonisolated" Apps/ Packages/` — must return 0 results
- [ ] Run `grep -rn "MainActor.assumeIsolated" Apps/` — only allowed in TerminalHostView hot path (with [weak self]+guard)
- [ ] Run app for 2+ hours without crash
- [ ] Check `heap <PID> | grep NSTextField` — count should be stable (no growth)
- [ ] Confirm `updateTrackingAreas` all have `guard window != nil`

See: `agent-memory/knowledge/bugs/zombie-crash-macos26.md` for full details.

---

## Phase 1 — Compatibility (P0)

Ensure Harness builds and runs correctly on macOS 27 beta without regressions.

- [ ] Build with Xcode 27 beta, fix any deprecation warnings-as-errors
- [ ] Verify Liquid Glass doesn't break custom sidebar chrome (`HarnessDesign`,
      `ChromeBackdrop`, `WindowBlur.apply()`)
- [ ] Verify window corner radius change doesn't clip terminal content or overlays
- [ ] Test NSStatusItem (`MenuBarController`) with new expanded interface session API
- [ ] Confirm Metal renderer still works (no display pipeline changes expected)
- [ ] Run full test suite on macOS 27

## Phase 2 — Quick Wins (P1)

Low-effort adoptions that improve quality immediately.

- [ ] Set `window.autorecalculatesKeyViewLoop = true` on `MainWindowController`
- [ ] Set `preventsApplicationTerminationWhenModal = false` on non-critical sheets
      (about panel, settings, command palette)
- [ ] Adopt `NSViewCornerConfiguration` + `.containerConcentric` on:
  - `ToastLabel`
  - `DisplayPanesOverlay` chips
  - `ResizeHUDView`
  - `NotificationDropdownPanelView`
- [ ] Adopt sidebar semi-bold selection text style (if system doesn't auto-apply
      due to custom sidebar)

## Phase 3 — NSTextSelectionManager (P1)

Replace manual mouse-forwarding in file preview with system text selection.

- [ ] Evaluate `NSTextSelectionManager` for `SyntaxTextView` (file editor)
- [ ] Evaluate for `FileViewerViewController` QuickLook text selection
- [ ] If viable, remove manual `mouseDown/mouseDragged/mouseUp` forwarding
      (currently needed per RL-010/CASE-018)
- [ ] Test bidirectional selection, drag-and-drop text

## Phase 4 — Gesture Recognizer Migration (P2)

Long-term tech debt: replace mouseDown overrides with gesture recognizers.
Not urgent but aligns with Apple's direction.

Priority targets (most complex mouseDown logic):
- [ ] `TerminalTabBarView` — drag reorder + context menu
- [ ] `SessionCardRowView` — click + hover + context menu
- [ ] `HarnessControls` (slider, toggle, select) — tracking loops
- [ ] `ContentAreaViewController` split divider drag

Lower priority (simpler or less frequent):
- [ ] `SoftIconButton`, `HarnessPillButton`, `NotificationBellButton`
- [ ] `WorkspacePillButton`, `WorkspaceSwitcherRow`

## Phase 5 — State Restoration (P2)

Adopt `NSWindowRestoration` for seamless relaunch after system updates.

- [ ] Evaluate overlap with existing `SessionStore` persistence
- [ ] Implement `encodeRestorableState` on `MainWindowController` (sidebar
      width, selected tab, sidebar visibility, active workspace)
- [ ] Implement `restoreWindow(withIdentifier:)` in restoration class
- [ ] Call `invalidateRestorableState()` on relevant state changes
- [ ] Keep `SessionStore` for daemon-side session state (pane tree, surfaces)
      — restoration handles window chrome only

## Phase 6 — SwiftUI Performance (Free wins)

These require no code changes, just running on macOS 26+/27:

- List 100k+ items 6x faster → benefits `FileTreeSwiftUIView`
- Nested layouts 2x faster resize → benefits sidebar SwiftUI views
- `@State` lazy init (macro) → reduces reconciliation overhead

Verify:
- [ ] File tree with large repos (10k+ files) — measure scroll perf on 27 vs 26

---

## Non-goals
- Liquid Glass full redesign (keep custom chrome for brand identity)
- 3D charts / spatial layout (not relevant for terminal)
- Document API (not a document-based app)
- MetalFX upscaling (2D glyph renderer, not 3D)

## Risks
- Custom `NSVisualEffectView` / `WindowBlur` may conflict with system Liquid
  Glass in unexpected ways — need early beta testing
- `NSTextSelectionManager` may not support our use case (syntax-highlighted
  attributed text with line numbers) — evaluate before committing
- Gesture recognizer migration is large scope, defer if time-constrained

## Timeline
- **Beta 1–3 (Jun–Aug 2026):** Phase 1 + 2
- **RC (Sep 2026):** Phase 3 evaluated, Phase 6 verified
- **Post-release:** Phase 4 + 5 as time allows
