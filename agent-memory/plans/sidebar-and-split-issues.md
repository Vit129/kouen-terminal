# Issues Analysis: Right Sidebar & Multi-Pane Split Squeezing

This document provides a detailed breakdown of two layout issues in Harness Terminal:
1. **Right Sidebar**: Sidebar can be moved to the right, but settings revert on restart, and the real-time layout transition has visual anomalies.
2. **Split Right (>3 Panes)**: Splitting panes horizontally 4-5 times causes the middle panes to be squeezed/compressed.

---

## 1. Sidebar Right Alignment & Persistence Issues

### A. Settings Revert on Restart
* **Behavior**: Setting `sidebarOnRight: true` in `settings.json` is automatically reset to `false` when the application launches.
* **Analysis**: 
  - Unit tests confirm that `HarnessSettings.load()` correctly decodes `sidebarOnRight` from JSON.
  - The reversion happens during the application bootstrap phase. Either:
    1. A default `HarnessSettings` instance is initialized without loading the existing file, then saved on top.
    2. An onboarding or layout initialization flow overrides the loaded settings object.
    3. `settings.save()` is called early with a stale in-memory settings state.
* **Planned Fix**: Locate all settings saves or overrides during launch and ensure the loaded `sidebarOnRight` boolean is preserved.

### B. Not Smooth/Clean Real-time Transitions
* **Behavior**: Toggling the sidebar side in real-time shows visual glitches, and the tab bar overlaps with macOS window traffic lights.
* **Analysis**:
  - **Traffic Light Clearing**: macOS window control buttons (traffic lights) are always at the top-left. When the sidebar is on the left, it acts as a buffer. When the sidebar moves to the right, the terminal content area begins at `x = 0`. The tab bar must be padded on the left by `effectiveTrafficLightInset` to clear the buttons.
  - Currently in `ContentAreaViewController.swift`:
    ```swift
    func setTabBarLeadingInset(_ inset: CGFloat) {
        if sidebarOnRight {
            tabBar.setLeadingInset(0) // Overlaps traffic lights!
        } else {
            tabBar.setLeadingInset(inset)
        }
    }
    ```
    This causes tabs to sit under the traffic lights when the sidebar is on the right.
  - **Vibrancy and Sidebar Toggle Buttons**: The chevron buttons and side-toggle icons do not adjust their constraints or visibility flags cleanly in real-time, requiring a full window relayout.
* **Planned Fix**:
  1. Modify `setTabBarLeadingInset` to respect the traffic light inset even when the sidebar is on the right.
  2. Adjust the sidebar toggle button constraints dynamically when the sidebar side changes.

---

## 2. Multi-Pane Split Squeezing (Split Right > 3)

### A. Core Behavior & Mismatch
* **Behavior**: Splitting panes horizontally 4-5 times in the same direction makes the middle panes extremely narrow (squeezed) while the outer panes remain wide, especially after window resizing or sidebar toggles.
* **Analysis**:
  - **GUI vs Daemon Mismatch**:
    - **GUI**: In `ContentAreaViewController.swift`, same-direction splits are flattened into a single `HarnessSplitView` with N children. Because it is flattened, `split.ratio` is set to `nil` to distribute them equally (e.g., 20% width per pane for 5 panes).
    - **Daemon**: The daemon's tree structure is still a binary tree. It computes absolute column sizes using the binary tree and ratio parameters. For 5 panes, it splits as `0.5`, `2/3` (~0.66), `3/4` (0.75), `4/5` (0.8) recursively, which mathematically distributes them equally (20% each).
  - **The Squeezing Trigger (Layout Lock-in)**:
    - In `HarnessSplitView.layout()`, equal distribution is performed **only once** (when `appliedRatio` is first set to `true`).
    - When the window resizes (e.g., when toggling the sidebar or resizing the app window), `appliedRatio` prevents redistributing equally. `NSSplitView` falls back to its default subview resizing algorithm, which resizes subviews unequally and severely compresses the middle panes.
    - Because the GUI's child sizes are squeezed, they trigger `onResize`, which propagates these unequal dimensions back to the daemon's PTY processes, causing the text inside to squeeze.
  - **No Ratio Persistence**:
    - Because of the N-ary flattening in the GUI, `firstPaneID` and `secondPaneID` are never set on `HarnessSplitView`.
    - This causes `persistRatio()` to return early, preventing the user from manually adjusting the squeezed panes by dragging.

### B. Planned Fix
1. **Dynamic Equal Resizing**:
   - If `ratio == nil` (equal distribution mode), we must re-distribute panes equally during any resize event, instead of guarding it with `appliedRatio = true`.
   - Implement `splitView(_:resizeSubviewsWithOldSize:)` in `HarnessSplitView` to distribute the new width/height proportionally and equally among all subviews when `ratio` is `nil`.
2. **Restore Divider Drag Persistence**:
   - We must assign `firstPaneID` and `secondPaneID` properly or implement N-ary ratio mapping so that dragging dividers actually updates the ratios of the binary tree in the daemon.
