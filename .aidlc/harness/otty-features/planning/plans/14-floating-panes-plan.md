# Implementation Plan: Phase 14 — Floating Panes in Harness

## Status: Planning

## Objective
Implement Phase 14 (Floating Panes) under `Dev Only` / `SDLC` mode:
- Implement `FloatingPaneController` managing a pool of floating NSPanels.
- Implement bootstrapping of dedicated daemon workspaces/sessions.
- Support Esc dismissal for the active floating pane.
- Wire menu item and ⌘⌥F shortcut.

## Feature Implementation Plan

### Task 1.1: Create `FloatingPaneController.swift`
- **Location**: `Apps/Harness/Sources/HarnessApp/UI/Shared/FloatingPaneController.swift`
- **Scope**:
  - `@MainActor final class FloatingPaneController: NSObject`
  - `static let shared = FloatingPaneController()`
  - Manage a pool of floating `NSPanel` objects: `private var panels: [NSPanel] = []`
  - `toggle()`:
    - If any of the managed panels is the key window (`panel.isKeyWindow` is true), hide all panels (orderOut).
    - Otherwise, show (or create) a floating pane. If we have a hidden panel, show it and make it key. If no panel exists, initiate bootstrap.
  - `bootstrap()` (async):
    - Call `SessionCoordinator.shared.requestDaemon(.newWorkspace(name: "Floating Pane"))`
    - Call `SessionCoordinator.shared.requestDaemon(.newSession(...))`
    - Fetch the surface ID, create `TerminalHostView` using `terminalHost(for:surfaceID, cwd:...)`
    - Create `NSPanel` (800×500, centered on screen, `isFloatingPanel = true`, `level = .floating`, resizable/movable, translucent background or standard window appearance).
    - Add the parent window constraint: if `NSApp.keyWindow` exists, add the floating panel as a child window (`parent.addChildWindow(panel, ordered: .above)`).
    - Keep track of the panel in `panels`.
  - Esc key monitor:
    - Install local key monitor: if key is Esc (keyCode 53) and focused window is one of our panels, order it out/hide.

### Task 1.2: Add Menu Item and Keybinding
- **Location**: `Packages/HarnessCore/Sources/HarnessCore/ReleaseNotes/BannerShortcutRegistry.swift`
  - Add `floatingPane` keybinding (⌘⌥F) or equivalent.
- **Location**: `Apps/Harness/Sources/HarnessApp/UI/Chrome/MainMenuBuilder.swift`
  - Add "New Floating Pane" menu item calling `MenuTarget.newFloatingPane`.
  - Implement `@objc func newFloatingPane()` selector in `MenuTarget` delegating to `FloatingPaneController.shared.toggle()`.

## Verification
- Build the product (`swift build --product Harness` / `make preview` or similar).
- Press ⌘⌥F and verify a new floating pane is created and centered.
- Drag the floating pane, resize it, type inside.
- Press Escape while the pane is key and verify it hides.
- Press ⌘⌥F again when it is hidden and verify it shows/reopens.
- Press ⌘⌥F when it is focused and verify it hides.
