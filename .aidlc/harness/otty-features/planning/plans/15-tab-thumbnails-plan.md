# Implementation Plan: Phase 15 — Tab Thumbnails Overview in Harness

## Status: Planning

## Objective
Implement Phase 15 (Tab Thumbnails Overview) under `Dev Only` / `SDLC` mode:
- Add `renderThumbnail(size:)` inside `TerminalHostView.swift`.
- Create `TabOverviewController.swift` hosting the NSPanel and programmatic NSCollectionView.
- Wire selection actions to SessionCoordinator.
- Register keybinding (⌘⇧\) and add menu item to `MainMenuBuilder`.

## Feature Implementation Plan

### Task 2.1: Add `renderThumbnail` in `TerminalHostView.swift`
- **Location**: `Packages/HarnessTerminalKit/Sources/HarnessTerminalKit/TerminalHostView.swift`
- **Scope**:
  - Implement `public func renderThumbnail(size: NSSize) -> NSImage`
  - Get `surfaceView`'s bounds.
  - If bounds are zero, return a placeholder image or empty image.
  - Otherwise, create `NSImage(size: size, flipped: false)` and draw/render the `surfaceView` inside using `bitmapImageRepForCachingDisplay` and `cacheDisplay`.

### Task 2.2: Create `TabOverviewController.swift`
- **Location**: `Apps/Harness/Sources/HarnessApp/UI/Shared/TabOverviewController.swift`
- **Scope**:
  - `@MainActor final class TabOverviewController: NSObject, NSCollectionViewDataSource, NSCollectionViewDelegate`
  - `static let shared = TabOverviewController()`
  - Properties: `private var panel: NSPanel?`, `private var collectionView: NSCollectionView?`, `private var tabs: [(workspaceID: WorkspaceID, sessionID: SessionID, tab: Tab)] = []`
  - `toggle()`:
    - If panel is visible, hide it.
    - Else, gather all tabs in the active workspace:
      ```swift
      let coord = SessionCoordinator.shared
      guard let activeWorkspace = coord.snapshot.activeWorkspace else { return }
      self.tabs = activeWorkspace.sessions.flatMap { session in
          session.tabs.map { (workspaceID: activeWorkspace.id, sessionID: session.id, tab: $0) }
      }
      ```
      Bootstrap panel if needed, reload collection view, center, show.
  - `NSCollectionView` configuration:
    - Flow layout with itemSize: 240×172.
    - Register a programmatic custom `NSCollectionViewItem` subclass `TabOverviewItem`.
    - Implement `numberOfItemsInSection` and `itemForRepresentedObjectAt`.
    - Implement `didSelectItemsAt` to trigger coordinator selection and orderOut the panel.
  - Esc key monitor: local keyboard monitor to close panel on Esc.

### Task 2.3: Add Menu Item and Keybinding
- **Location**: `Packages/HarnessCore/Sources/HarnessCore/ReleaseNotes/BannerShortcutRegistry.swift`
  - Add `tabOverview` keybinding (⌘⇧\).
- **Location**: `Apps/Harness/Sources/HarnessApp/UI/Chrome/MainMenuBuilder.swift`
  - Add "Tab Overview" menu item calling `MenuTarget.tabOverview`.
  - Implement `@objc func tabOverview()` selector in `MenuTarget` delegating to `TabOverviewController.shared.toggle()`.

## Verification
- Build Harness terminal.
- Create multiple sessions and tabs with different shell outputs.
- Press ⌘⇧\ to open the tab overview.
- Verify thumbnails are rendered correctly with their respective tab titles.
- Click a thumbnail and verify it jumps to the chosen session and tab, dismissing the overview.
- Open overview, press Escape and verify it dismisses.
