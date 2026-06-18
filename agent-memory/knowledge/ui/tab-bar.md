# Tab Bar (TerminalTabBarView) — Layout, Git Branch & Drag

## File

`Apps/Harness/Sources/HarnessApp/UI/Terminal/TerminalTabBarView.swift`

## Pill Layout (TabPillView)

Each pill hosts, left-to-right:
```
[persistentIcon?][agentIcon?]   [titleLabel]•[statusDot]   [shortcutLabel or closeButton]
                                [branchLabel (optional, below title)]
```

Key constraints (all in Auto Layout):
- `agentIcon` and `persistentIcon` collapse to `width = 0` when hidden
- `titleAndBranchStack` (vertical NSStackView) is centered via `centerXAnchor`
- `statusDot` (6×6 circle): `leadingAnchor = titleLabel.trailingAnchor + 4`, `centerYAnchor = titleLabel.centerYAnchor` — matches sidebar "name • status" language
- `workingDot` (2×2, Ghostty-style shuttle): overlays just before titleLabel
- `mcpBadge` ("MCP" text): `leadingAnchor = titleLabel.trailingAnchor + 3`, shown 5s after MCP tool use

**Avoid:** placing `statusDot` at `leadingAnchor` — that's visually inconsistent with the sidebar and obscures the agent icon slot.

## Branch Label

`branchLabel` (9pt, secondary color) stacks below `titleLabel` via `titleAndBranchStack`.

`shouldShowBranch(for:)` — **returns true whenever `tab.gitBranch` is non-empty**. Do not add "only show for non-main/non-master" guards; the user always wants to see the current branch.

When branch is shown:
- `branchLabel.stringValue = "⎇ \(branch)"`
- `titleLabel.font = .systemFont(ofSize: 11.5, weight: .medium)` (smaller, to fit stack in 26pt pill height)
- Without branch: `titleLabel.font = HarnessDesign.Typography.tabTitle` (13pt medium)

## Git Branch Detection

`DaemonSyncService.metadataTask` polls every **5 seconds**:
1. For each tab in the active workspace runs `git -C <cwd> rev-parse --abbrev-ref HEAD` via `GitMetadataProvider.currentBranch(at:)`
2. On change → sends `IPCRequest.updateTabGitBranch` → `SurfaceRegistry` → `SessionEditor.updateTabMetadata`
3. `syncFromDaemon(metadataOnly: true)` → `ContentAreaViewController.refreshTabBarMetadata()` → `TabPillView.update()`

Source: `HarnessCore/Metadata/MetadataProvider.swift` + `DaemonSyncService.swift:375`

**Branch shown in tab = actual current branch of the tab's cwd.** Latency ≤ 5s.

## Drag Reorder

Custom AppKit drag (no NSDraggingItem):
1. `TabPillView.mouseDragged` — threshold 4px horizontal, calls `TerminalTabBarView.handleDragChanged`
2. `handleDragChanged` — moves dragged pill frame, calls `repositionForDrag` which animates others into slots
3. `handleDragEnded` — computes `from` (orderedPills index) vs `dragTargetIndex`; if different calls `delegate?.tabBarDidReorder`
4. `tabBarDidReorder` in `ContentAreaViewController` → finds owning SessionGroup → `coordinator.reorderSession`

**Cancel on structural reload:** when `reload(tabs:activeTabID:)` fires while a drag is in progress (tab added/closed elsewhere), the drag is **cancelled** (not committed). Committing would use a `dragTargetIndex` computed against the old pill count and could place the tab in the wrong slot.

`refreshMetadata(tabs:activeTabID:)` is the light path for in-place metadata updates (title/status/branch) — it does NOT interrupt drag because it only calls `pill.update()` without rebuilding.

## Chrome Roles

Active pill: accent tint bg + accent rim + elevation1 shadow (matches selected SessionCardRowView).
Hovered: `rowHoverFill` bg, no border.
Idle: transparent.

`applyChrome(isActive:)` handles all three states including `workingDot` color (tracks `titleLabel.textColor`).

## Agent Detection

`tabAgentKind(for:)` in `TerminalTabBarView.swift` delegates to `tab.effectiveAgentKind`:

```swift
// Tab+effectiveAgentKind (HarnessCore/Models/Tab.swift)
public var effectiveAgentKind: AgentKind? {
    agent?.kind ?? AgentTitleInference.kind(from: title)
}
```

**Single source of truth** — tab bar, sidebar `WorktreeRowView`, `BoardModel`, `MenuBarController`, and `NotificationCoordinator` all use `tab.effectiveAgentKind`. Do not inline `tab.agent?.kind ?? AgentTitleInference.kind(from: tab.title)` at call sites.

## Source Map

| Symbol | File |
|--------|------|
| `TerminalTabBarView` | `UI/Terminal/TerminalTabBarView.swift` |
| `TabPillView` | same file (private nested class) |
| `GitMetadataProvider` | `HarnessCore/Metadata/MetadataProvider.swift` |
| `DaemonSyncService.metadataTask` | `HarnessApp/Services/DaemonSyncService.swift:375` |
| `ContentAreaViewController.reloadTabBar` | `UI/Chrome/ContentAreaViewController.swift` |
| `ContentAreaViewController.tabBarDidReorder` | `UI/Chrome/ContentAreaViewController.swift:345` |
