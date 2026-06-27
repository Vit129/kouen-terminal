# Decision Record: Phase 15 — Tab Thumbnails Overview in Harness

## Status: Decided

## Background
- **What is Tab Thumbnails Overview?** A visual grid showing thumbnails of all tabs in all sessions of the active workspace (using ⌘⇧\).
- **Goal**: Implement `TabOverviewController` showing an `NSPanel` with a grid of tab thumbnails. Render the thumbnails from active `TerminalHostView`s, allow selecting a tab/session upon click, and support Esc to dismiss.

---

## Outstanding Decisions

### Decision 1: Thumbnail Capture Mechanism
**Context**: We need to draw a visual preview of each terminal pane.
**Decision**: Implement `TerminalHostView.renderThumbnail(size:)` inside `HarnessTerminalKit/TerminalHostView.swift`.
If the view size is zero or not laid out yet, or the host view is not loaded, draw a fallback card showing the tab title centered on a window background color.
**Rationale**: Guarantees we get real previews for active sessions and graceful fallbacks for others.

---

### Decision 2: UI Container & Grid Component
**Context**: How to render the visual grid.
**Decision**: Use `NSPanel` hosting a view controller with an `NSCollectionView` flow layout.
- **Panel Config**: Size 900×600, `level = .floating`, `styleMask: [.titled, .closable, .fullSizeContentView, .nonactivatingPanel, .utilityWindow]`.
- **Flow Layout**: Grid layout with item size 240×172 (allowing 240×150 for thumbnail + 22 for label).
- **Cell View**: Custom programmatic `TabOverviewItem` class (avoiding xibs/nibs for easier compilation and consistency).
**Rationale**: AppKit's programmatically-configured `NSCollectionView` is highly performant and matches the existing AppKit/SwiftUI layout ecosystem of the main app.

---

### Decision 3: Dismissal & Selection Actions
**Context**: What happens when the user clicks a cell or cancels.
**Decision**:
- Clicking a cell retrieves the associated workspace, session, and tab, then calls:
  ```swift
  SessionCoordinator.shared.selectSession(workspaceID: wsID, sessionID: sessionID)
  SessionCoordinator.shared.selectTab(workspaceID: wsID, tabID: tabID)
  ```
  and closes the overview panel.
- Pressing Esc (monitored locally) closes the overview panel.
**Rationale**: Simple, clean navigation integration.

---

## Decision Summary

| Decision | Chosen Option | Rationale | Impact |
|----------|---------------|-----------|--------|
| Capture | `TerminalHostView.renderThumbnail` with fallback drawing | Ensures visual preview is always present | Medium |
| UI Grid | Programmatic `NSCollectionView` | High performance, no nib dependency | High |
| Actions | Double coordinate selection + Close | Seamless integration | Low |
