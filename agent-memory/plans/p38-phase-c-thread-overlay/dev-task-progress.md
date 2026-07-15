# P38 Phase C — Agent Thread UX on Existing Block Capture — Dev Task Progress

Design: `design.md` (same folder) — see "Pivot" section at the top; the original overlay-based
plan (tasks below marked "original, superseded") was built, gated green, then deleted mid live-test
and replaced by a merge into the existing Recipes picker. Current architecture:
`Apps/Kouen/Sources/KouenApp/UI/Shared/RecipePickerController.swift`.

## Stage 1-2 — Engine/surface plumbing (built 2026-07-14, unchanged by the pivot, still in use)

- [x] 1. `TerminalEmulator.swift`: `public var blocks: [TerminalBlock] { blockStore.blocks }`.
- [x] 2. Test: `Tests/KouenTerminalEngineTests/TerminalBlockStoreTests.swift` — accessor returns order + running/finished mix.
- [x] 3. `KouenTerminalSurfaceView`: `public var blocks: [TerminalBlock]` (via `emulatorSync`), `public func jumpToBlock(promptLine:)` in `+Scrollback.swift`, delegates to `scrollToBufferLine` (already clamps).

## Original overlay build (built 2026-07-14, gated green, then deleted 2026-07-15 mid live-test)

- [x] 4. ~~`TerminalThreadOverlay.swift` (NSTableView-based full-pane overlay)~~ — **deleted**. Close button collided with `PaneSplitButtonsView` (fixed once, top-anchor offset 44pt matching `TerminalFindBar`), but double-click and the filter affordance never worked and root cause was never found before the pivot below made the whole class moot.
- [x] 5. ~~`TerminalHostView.toggleThreadView()`/`showThreadView()`/`hideThreadView()`~~ — **reverted**, removed entirely.
- [x] 6. ~~`SessionCoordinator.toggleThreadView()` + `BannerShortcutRegistry.threadView` (⇧⌘L) + "Thread View" menu item~~ — **reverted**, removed entirely. `toggleFindBar()` back to its original simple form.
- [x] 7. ~~Contextual ⌘F routing to the overlay's filter field~~ — **reverted** along with the overlay.
- [x] 8. ~~`Tests/KouenTerminalKitTests/ThreadOverlayTests.swift` (5 tests)~~ — **deleted** along with the overlay it tested.
- [x] 9. Gate at the time (build/test/robot green, 26/26) — moot now; superseded by the gate under "Pivot" below.

## Pivot — merge into the Recipes picker (2026-07-15)

- [x] 10. `RecipePickerController.swift`: added `PickerItem` enum (`.recipe`/`.historyBlock`), rewrote `RecipePickerModel` to hold both, most-recent-history-first ordering, `activateSelected()` branches per case (recipe → send/composer as before; history block → `host.jumpToBlock(promptLine:)`, new).
- [x] 11. `RecipePickerView`/`PickerItemRow` (renamed from `RecipeItemRow`): renders both item kinds — history rows get a clock icon, red-tinted "exit N" subtitle on failure, "Jump" badge; recipe rows unchanged. Search placeholder updated to "Search recipes & history...".
- [x] 12. Single shortcut: removed the duplicate `BannerShortcutRegistry.threadView` (⇧⌘L) and its "Recent Commands" menu item alias — ⌘⇧R is the only entry point, per explicit user request after confirming the merged picker worked. Menu item renamed "Recipes…" → "Recipes & History…".
- [x] 13. Gate: `swift build --product Kouen` green, `Tests/robot/run.sh` green (26/26).
- [x] 14. `Tests/KouenAppTests/RecipePickerModelMergeTests.swift` (11 tests) — `PickerItem` id/searchableText per kind, merge ordering (history before recipes, caller order preserved), query filtering across both kinds (case-insensitive, empty-query restore, no-match clears), `selectedIndex` clamp-on-shrink, `moveSelection` wrap-around both directions and no-op on empty. `TerminalBlock` fixtures built via real OSC 133 feed through `TerminalEmulator` (same pattern as `TerminalBlockStoreTests` — the struct's memberwise init is internal to `KouenTerminalEngine`, can't construct directly cross-module). Does not cover `activateSelected()`'s dispatch to `jumpToBlock`/send/composer — that needs a live `SessionCoordinator`/`TerminalHostView`, no meaningful way to assert it without one; left for the live check below.
- [ ] 15. **Live check (required, not done)**: open ⌘⇧R, confirm the list shows both saved recipes and recent history in one flat list, search filters both, and selecting a history item (click / double-click / Enter) jumps the terminal viewport to that command's output correctly — this exact interaction was the one that never worked in the deleted overlay and has not been re-verified since the rewrite.

## Summary

Completed: 14 (3 still-valid plumbing tasks + 6 overlay tasks now moot/reverted + 5 pivot tasks).
Remaining: 1 — live check of the jump-to-block interaction in the new UI (15).

## Status: Implementation pivoted mid-phase from a standalone overlay to a merge into the existing
Recipes picker, per explicit user direction during live testing. Build/test/robot green, including
a new regression test for the merge/filter logic. Still missing the live check that would confirm
whether the original double-click/jump bug survived the rewrite — `activateSelected()`'s dispatch
to `jumpToBlock` is the one path the unit test above can't reach without a live coordinator.
