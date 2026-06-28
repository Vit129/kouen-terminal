# Dev Task Progress — Otty Features

## Context
- **Mode**: Dev Only
- **Approach**: SDLC
- **Active Workspace**: `harness-terminal`

---

## Phase 2: Vi Modal Editing ✅ (commit 5a7eb10)

- [x] `HarnessTerminalSurfaceView+ViMode.swift` — state machine (insert/normal), Esc→normal, i/a/A→insert, hjkl/wb/0$/x send escape sequences to PTY
- [x] `viModeState`, `onViModeChanged` stored props on `HarnessTerminalSurfaceView`
- [x] `handleViMode(_:)` intercept in `+Input.swift` before PTY dispatch
- [x] `setViMode(_:)` public, `toggleViMode()` in `SessionCoordinator`
- [x] `toggleViMode` keybinding (⌘⌃V) in `BannerShortcutRegistry` + menu item

---

## Phase 12: Block-based Output ✅ (commit 5a7eb10 + 0e608ce)

### 12a — Cmd+Click block selection
- [x] `promptGutterEnabled` changed from `private` to `public`
- [x] Cmd+Click in `+SelectionAndLinks.swift` — reads `promptRows` from emulator, selects block text (from prompt start to next prompt - 1)
- [x] `onBlockSelected` stored prop + fired from Cmd+Click

### 12b — Block output tint + AI explain action bar
- [x] Public API: `promptRows`, `selectionString`, `copyBlock()` on `HarnessTerminalSurfaceView`
- [x] `BlockTintOverlay: NSView` — flipped, CA-backed, alternating 2.8%/5.8% alpha tint per block; subscribes to `onScrollChanged`
- [x] `BlockActionBar` — Copy + AI ✦ buttons, shown on `onBlockSelected`, auto-dismisses on scroll
- [x] Wired in `SessionCoordinator.terminalHost(for:cwd:)` with AutoLayout

---

## Phase 14: Floating Terminal Pane (⌘⌥F) ✅

- [x] `FloatingPaneController.swift` — NSPanel, `.nonactivatingPanel`, `.floating` level, frame persisted to UserDefaults
- [x] `BannerShortcutRegistry.floatingPane` (⌘⌥F) + menu item + AppDelegate install

---

## Phase 15: Tab Thumbnails Overview (⌘⇧\) ✅

- [x] `HarnessTerminalSurfaceView+Thumbnail.swift` — `renderThumbnail(size:)` via `bitmapImageRepForCachingDisplay` (macOS 15 compatible; `CGWindowListCreateImage` removed)
- [x] `TabOverviewController.swift` — 4-column NSScrollView grid, `TabCell: NSView` subclass (avoids Swift 6 mutable global error), hover highlight, `selectTab(workspaceID:tabID:)` on click
- [x] `BannerShortcutRegistry.tabOverview` (⌘⇧\\) + menu item

---

## Phase 11: Recipes (⌘⇧R) ✅

- [x] `RecipesStore.swift`, `RecipePickerController.swift`, menu + keybinding

---

## Phase 19: Frecency Directory Jumping (⌘⇧J) ✅

- [x] `FrecencyDirectoryStore.swift`, `DirectoryPickerController.swift`, menu + keybinding

---

## Phase 20: Session Resurrection Audit ✅

- [x] Audit: window frame (`saveFrame`/`setFrameUsingName`) + scrollback (`ScrollbackFile`) already handled — no gaps

---

## Phase 20b: Picker Enhancements (⌘⇧J + zoxide + ⌘↩) ✅

- [x] `DirectoryPickerModel` — added `activateSelectedInNewTab()` and `mergeZoxide()`
- [x] `DirectoryPickerController` — queries zoxide asynchronously and merges zoxide results with frecency directory jumps
- [x] `DirectoryPickerView` — added ⌘↩ handler to open the directory in a new tab, and updated footer hints

---

## Remaining (deferred)

| Phase | Feature | Reason |
|---|---|---|
| 13 | Kitty Graphics Protocol | XL effort, no immediate demand |
| 21 | Plugin runtime (WASM) | XL effort, no immediate demand |
