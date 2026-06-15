# Agent Prompt — Harness Terminal UI Fixes

**Project:** `/Users/supavit.cho/Git/Personal/harness-terminal` (Swift 6 / AppKit macOS)

---

## Task 1: Redesign Session Sidebar

### Goal
Replace the current 2-level card structure with a cleaner group header + worktree rows.

### Current structure
```
▶ harness-terminal
  [session card]
  [session card]
```

### Target structure
```
▼ harness-terminal  ● Running
  ⎇ main              /Git/Personal/harness-terminal
  ⎇ worktree-p19      /Git/Personal/harness-terminal
```

### Rules

1. **Group header** (`SessionGroupHeaderRowView`) shows:
   - Project name (already exists)
   - Board status dot (color-coded) = highest-priority status among all sessions in group
     - 🟠 Needs Attention (agent.activity == .awaiting)
     - 🔵 Running (currentCommand set, not a shell)
     - 🟢 Done (exitStatus == 0)
     - 🔴 Error (exitStatus != 0)
     - ⚫ Idle (everything else)
   - Use `BoardModel.classify(snapshot:)` to get the status

2. **Worktree rows** (new `WorktreeRowView`) under each group:
   - Show `⎇ <branch>  <shortened-cwd>`
   - If only 1 session in group OR all sessions share same branch → show 1 row only
   - Each session with a different branch = separate worktree row
   - Click → `SessionCoordinator.shared.selectSession(workspaceID:sessionID:)`
   - Highlight active session row

3. **Remove** `SessionCardRowView` expand button entirely
4. **Remove** Board tab from sidebar:
   - `sidebarTabs` labels: `["Sessions", "Files", "Git", "Board"]` → `["Sessions", "Files", "Git"]`
   - Remove all Board tab switching logic and `boardViewController` tab switch references
   - Keep `boardViewController` instance (used by `harness board` CLI), just hide the tab

### Files to change
- `Apps/Harness/Sources/HarnessApp/UI/Sidebar/SidebarSessionRows.swift`
- `Apps/Harness/Sources/HarnessApp/UI/Sidebar/HarnessSidebarPanelViewController.swift`

---

## Task 2: Fix Browser Toolbar

**File:** `Apps/Harness/Sources/HarnessApp/UI/Chrome/BrowserPaneView.swift`

### Issues
1. **Close button (×) does not respond to clicks**
2. **Refresh button (⟳) clips off the right edge**

### Root Cause
- `closePaneButton` is added to `NSStackView(views: [..., closePaneButton])` BEFORE
  `configureNavigationButton` is called on it
- This means `translatesAutoresizingMaskIntoConstraints = false` is set after the
  stack view has already laid out the button — can break hit testing
- `urlTextField` expands to fill all available space, pushing `closePaneButton` off screen

### Fix
1. Call `configureNavigationButton(closePaneButton, symbolName: "xmark", action: #selector(closePaneClicked))` BEFORE creating the `NSStackView`
2. Verify `urlTextField` has:
   ```swift
   urlTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
   urlTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
   ```
3. Change toolbar edge insets right from `8` to `12`
4. Verify `onClosePaneRequested` is wired in `ContentAreaViewController.swift` ~line 734:
   ```swift
   let bv = BrowserPaneView(url: bl.url, paneID: bl.id)
   let paneIDCopy = bl.id
   bv.onClosePaneRequested = {
       SessionCoordinator.shared.splitPaneCoordinator.closeBrowserPane(paneID: paneIDCopy)
   }
   ```

---

## Verification

```bash
cd /Users/supavit.cho/Git/Personal/harness-terminal
swift build          # must pass with no errors
make preview         # test manually:
                     # - Session sidebar shows group + worktree rows with Board dot
                     # - Open Browser Pane via Menu → × closes it, ⟳ is visible
```

---

## Commit

```bash
git add -A
git commit -m "fix(sidebar+browser): worktree rows with Board status, browser toolbar fix"
git push origin main
```
