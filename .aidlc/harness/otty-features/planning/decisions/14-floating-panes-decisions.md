# Decision Record: Phase 14 — Floating Panes in Harness

## Status: Decided

## Background
- **What is Floating Panes?** A feature allowing users to toggle floating terminal panels overlaying the active workspace without disrupting the current split layout (using ⌘⌥F).
- **Goal**: Implement `FloatingPaneController` to manage floating NSPanels, create dedicated daemon workspaces/sessions for these panels, add a menu item in `MainMenuBuilder`, and keybinding in `BannerShortcutRegistry`.

---

## Outstanding Decisions

### Decision 1: Session Management Pattern
**Context**: We need a workspace and session dedicated to each floating pane.
**Decision**: Use `SessionCoordinator.shared.requestDaemon` to create a new workspace named `"Floating Pane [UUID]"` and a dedicated session, matching the lazy bootstrap pattern in `QuickTerminalController`.
**Rationale**: Reusing this pattern ensures compatibility with the existing daemon architecture and lifecycle model.

---

### Decision 2: Panel Configuration and Behavior
**Context**: How to configure the floating NSPanel.
**Decision**:
- **Style Mask**: `[.titled, .closable, .resizable, .fullSizeContentView]`
- **Floating Panel properties**: `isFloatingPanel = true`, `level = .floating`, `isMovable = true`
- **Interaction**: Centered on screen, 800×500 default size. Set as child window of `NSApp.keyWindow` if available using `addChildWindow(panel, ordered: .above)`.
- **Dismissal**: Focus local keyboard monitor that catches the Esc key (keyCode 53) to hide the focused floating panel.
**Rationale**: This matches standard macOS utility/HUD window behaviors and ensures the pane remains above the parent window.

---

### Decision 3: Menu Item & Keybinding
**Context**: Selector naming and menu/shortcut configuration.
**Decision**:
- Add `newFloatingPane` keybinding (⌘⌥F) in `BannerShortcutRegistry`.
- Add "New Floating Pane" menu item in `MainMenuBuilder` pointing to `MenuTarget.newFloatingPane`.
- Selector in `MenuTarget` delegates to `FloatingPaneController.shared.toggle()`.
**Rationale**: Fits seamlessly into the app's existing keybinding and menu builder architecture.

---

## Decision Summary

| Decision | Chosen Option | Rationale | Impact |
|----------|---------------|-----------|--------|
| Session Management | Dedicated workspace/session per floating pane | Consistency with daemon model | Medium |
| Window Hierarchy | Floating NSPanel + `addChildWindow` | Keeps panel floating over keyWindow | High |
| Dismissal | Esc key monitor | Standard UX for dismissing light overlays | Low |
