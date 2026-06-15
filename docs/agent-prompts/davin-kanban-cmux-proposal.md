# Proposal: Merging Devin/Windsurf Kanban & CMUX Multiplexer UX into Harness

## 1. Summary of Davin/Windsurf Kanban + CMUX UX
Based on current research, the modern agentic IDE/terminal landscape leverages several specialized UX patterns for managing parallel agent sessions:

*   **Devin Desktop (formerly Windsurf) Agent Command Center**:
    *   **Kanban Board**: Groups and organizes agent-led sessions/tasks into distinct status columns: *Needs Attention* (e.g. blocked, waiting for user confirmation/input), *Running* (in progress), *Done* (completed successfully), *Error* (failed/exited non-zero), and *Idle*.
    *   **Tab vs. Session View**: Allows seamless switching between a high-level command board view of all sessions and a focused editor/terminal view for a specific session.
*   **CMUX Terminal Multiplexer**:
    *   **Sidebar Metadata**: The vertical tab sidebar does not just show names; it displays rich, real-time contextual indicators including the current Git branch, active port listeners, active running command, and the latest notification text.
    *   **Notification Rings**: Uses colored borders (typically blue) around terminal panes to visually signal when a specific pane has triggered a notification (via standard OSC terminal escape sequences or CLI invoke).
    *   **Notification Panel & Navigation**: A unified panel aggregates all active agent notifications. Standard shortcut `Cmd+Shift+U` lets the user quickly jump to the next unread agent session requiring attention.
    *   **Trigger Mechanisms**: Intercepts standard terminal sequences (OSC 9, OSC 99, OSC 777) or exposes a socket/CLI command `cmux notify` to let agents trigger these alerts.

---

## 2. Integration Proposal for Harness

We propose bringing these status-at-a-glance and agent-centric multiplexing features into Harness's existing UI architecture.

### 2.1 Sidebar Sessions Panel Enhancements
*   **Aggregated Group Badges**: Reuse `BoardModel.classify(snapshot:)` to display counts of active tasks under each project group directly on `SessionGroupHeaderRowView` (e.g., small color-coded pills: `1 Running` in blue, `1 Attention` in orange).
*   **Session Row Metadata**: Enhance `WorktreeRowView` to display:
    *   The current **git branch** (right-aligned, faded).
    *   **Active ports** (e.g. green outline badges for listening ports detected by the daemon).
    *   **Notification status**: A distinct background glow or badge on the row if the session is in the `.needsAttention` state.
*   **Board View Quick-Link**: Add a special "Board View" row at the top of each project group in the sidebar. Clicking it opens the existing `BoardViewController` in the main content area, filtered specifically for that project group's sessions.

### 2.2 Per-Session Top Bar / Tab Strip Enhancements
*   **Tab Status Indicators**: Update `TerminalTabBarView` and `FileEditorTabBarView` to render a small status dot next to each tab title corresponding to its `BoardColumnKind` (blue for running, orange for needs attention, gray for idle, green/red for done/error).
*   **Active Pane Borders (Notification Rings)**:
    *   When a terminal pane or editor session has its status changed to `needsAttention` (e.g., an agent is awaiting input), draw a distinct colored border (Harness Orange or CMUX Blue) around the pane bounds inside the active split view.
    *   Once key/mouse input is received in that pane, automatically clear the state and border.
*   **Urgent Session Quick-Switching**:
    *   Implement a global shortcut (`Cmd+Shift+U`) in `ContentAreaViewController` that sweeps across all workspaces and sessions to focus the next tab in the `.needsAttention` state.

---

## 3. Concrete File-Level Change List

We propose targeting the following files to implement this vision:

1.  **`Packages/HarnessCore/Sources/HarnessCore/Board/BoardModel.swift`**
    *   Enhance `BoardCard` or `columnKind(for:)` to support additional agent notification payloads.
2.  **`Apps/Harness/Sources/HarnessApp/UI/Sidebar/SidebarSessionRows.swift`**
    *   Modify `SessionGroupHeaderRowView` to layout and display aggregated status pills.
    *   Modify `WorktreeRowView` to include a trailing label for the git branch and active listening ports.
3.  **`Apps/Harness/Sources/HarnessApp/UI/Sidebar/HarnessSidebarPanelViewController.swift`**
    *   Bind table row updates to listen to workspace/session state changes and trigger redrawing.
4.  **`Apps/Harness/Sources/HarnessApp/UI/Terminal/TerminalTabBarView.swift`**
    *   Add color-coded status indicator dots next to tab items.
    *   Apply visual alert styles (like flashing or pulsing blue borders) to tabs needing attention.
5.  **`Apps/Harness/Sources/HarnessApp/UI/Chrome/ContentAreaViewController.swift`**
    *   Introduce a decoration layer or border views around pane splits to render notification rings.
    *   Register the global `Cmd+Shift+U` hotkey handler to cycle focus to awaiting sessions.
6.  **`Packages/HarnessTerminalEngine/Sources/HarnessTerminalEngine/Parser/VTParser.swift` (or similar)**
    *   Parse OSC 9, OSC 99, or OSC 777 escape sequences to update session notification/awaiting state dynamically from the terminal stream.
7.  **`Tools/harness/Sources/HarnessCLI/HarnessCLI+Notification.swift`**
    *   Expose a `harness notify` command that pipes notification requests to the daemon socket.
