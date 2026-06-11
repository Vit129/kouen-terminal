# P10 Implementation Prompts — For Agent Execution

All tasks below are independent and can be done in parallel or sequentially.
Run `swift build` after each. Run `swift test` for tasks that add new logic.

---

## Task #1: CMUX Session State Indicator in Sidebar

### Context

The daemon already tracks pane state:
- `Tab.exitStatus: Int?` — non-nil once the pane's shell exits (0=success, nonzero=error)
- `Tab.currentCommand: String?` — foreground process name (from `proc_pidinfo` polling)
- Hook event `pane-exited` fires when a pane dies
- Format variables: `#{pane_dead}`, `#{pane_dead_status}`, `#{pane_current_command}`, `#{pane_pid}`

The sidebar session cards (`HarnessSidebarPanelViewController`) already show session name, icon, and CWD. They do NOT currently show whether the session is idle/running/exited.

### Prompt

```
Add a visual session state indicator to sidebar session cards in
`Apps/Harness/Sources/HarnessApp/UI/HarnessSidebarPanelViewController.swift`.

Each `SessionCardRowView` should show a small colored dot (6pt circle) in the
trailing edge that reflects the pane state:

- **Running** (currentCommand is non-nil AND != shell name): pulsing/filled blue dot
- **Idle** (currentCommand is nil or equals the shell): dim gray dot (or no dot)
- **Exited OK** (exitStatus == 0): green dot
- **Exited Error** (exitStatus != nil && != 0): red dot

The state comes from `SessionSnapshot` which is already available in the reload path.
Look at how `SessionCardRowView` is built in `rebuildsidebarRows()` — it already has
access to the tab's `currentCommand` and `exitStatus` fields.

Implementation:
1. Add a `stateIndicator: NSView` (6x6 circle with layer.cornerRadius=3) to
   `SessionCardRowView`, pinned trailing with 8pt margin.
2. In `refreshMetadata()` (or wherever the row is updated), set the indicator's
   `layer?.backgroundColor` based on the tab state.
3. For the "running" state, use a simple `NSColor.systemBlue` (no animation needed
   for v1 — a static dot is fine).

The `currentCommand` field is polled by the daemon every 500ms and pushed via
`snapshotChanged`. No new IPC or daemon changes needed — purely GUI-side.

Constraints:
- No daemon/core changes. Sidebar-only.
- Match existing `HarnessDesign.chrome` color palette where possible.
- `swift build` must pass.
```

---

## Task #2: Keyboard-Driven Layout Presets

### Context

The app already supports:
- File editor split panel via `ContentAreaViewController.openFileTab(path:)` / `showFileEditorSplit()`
- CMUX split panes via CLI `new-split --direction horizontal|vertical`
- Sidebar toggle via `MainSplitViewController.toggleSidebar()`
- All IPC commands are available through `SessionCoordinator.shared`

### Prompt

```
Add keyboard-driven layout presets to the Harness terminal app.

Register a new keyboard shortcut ⌘+⇧+D ("IDE Mode") in `MainMenuBuilder.swift`
that toggles between the current layout and a predefined IDE layout:

IDE Mode layout:
- Sidebar: visible (if not already)
- File editor panel: visible at 40% width
- Terminal: remaining 60%

The toggle should:
1. If editor panel is NOT showing → open it (call `contentVC.showFileEditorSplit()`)
   and ensure sidebar is visible.
2. If editor panel IS showing → close it (call `contentVC.hideFileEditorSplit()`)
   to return to full terminal mode.

Implementation:
1. In `Apps/Harness/Sources/HarnessApp/UI/MainMenuBuilder.swift`, add a new menu item
   under the View menu: "Toggle IDE Mode" with keyEquivalent "d" and modifiers [.command, .shift].
2. The action target should call a new method on `MainSplitViewController`:
   `toggleIDEMode()` which:
   - Checks if `contentVC.fileEditorPanel != nil` (editor showing)
   - If not showing: ensure sidebar visible + call `contentVC.showFileEditorSplit()`
   - If showing: call `contentVC.hideFileEditorSplit()`
3. Make `fileEditorPanel` accessible (it's currently private — expose via a computed
   `var isFileEditorVisible: Bool` property on `ContentAreaViewController`).

Constraints:
- No new files needed — just add to existing MainMenuBuilder + MainSplitViewController.
- `swift build` must pass.
- No behavior change to existing shortcuts.
```

---

## Task #3: Local Workspace Completion (Tokenizer + Popup)

### Context

`SyntaxTextView` in `Apps/Harness/Sources/HarnessApp/UI/SyntaxTextView.swift` is the
file editor's text view. It already has syntax highlighting and a find bar. There is NO
autocomplete/completion popup currently.

The file tree watcher (`FileTreeWatcher`) at
`Packages/HarnessCore/Sources/HarnessCore/FileExplorer/FileTreeWatcher.swift` already
scans the workspace directory.

### Prompt

```
Add workspace-scoped local completion (autocomplete) to the file editor's SyntaxTextView.

The feature:
- While typing in SyntaxTextView, after 2+ characters, show a floating completion popup
  below the cursor with matching symbols from the workspace.
- Symbols = identifiers extracted from files in the workspace directory (functions,
  classes, variables, type names).
- Press Tab/Enter to accept, Escape to dismiss, arrow keys to navigate.

Implementation — 3 parts:

### Part A: WorkspaceSymbolIndex (new file)
Create `Apps/Harness/Sources/HarnessApp/Services/WorkspaceSymbolIndex.swift`:

```swift
/// Scans workspace files and extracts identifiers for local completion.
/// Runs off-main. Debounced rescan on file changes.
@MainActor
final class WorkspaceSymbolIndex {
    private(set) var symbols: Set<String> = []
    private var scanTask: Task<Void, Never>?

    func scan(root: String) {
        scanTask?.cancel()
        scanTask = Task.detached(priority: .utility) {
            let result = Self.extractSymbols(root: root)
            await MainActor.run { self.symbols = result }
        }
    }

    /// Extract identifiers from source files using a simple regex.
    /// Matches: func/class/struct/enum/let/var/def/const/function declarations.
    private static func extractSymbols(root: String) -> Set<String> {
        // Walk directory (max depth 4, skip hidden/node_modules/build/.git)
        // For each .swift/.ts/.js/.py/.go/.rs/.rb file:
        //   Regex: \b(?:func|class|struct|enum|protocol|let|var|def|const|function|type|interface)\s+([A-Za-z_]\w*)
        //   Collect capture group 1 into the set
        // Also collect all identifiers (bare \b[A-Za-z_]\w{3,}\b) from the current file
        // for word completion fallback.
        // Cap at 10,000 symbols. Skip files > 100KB.
    }

    func completions(prefix: String, limit: Int = 20) -> [String] {
        symbols.filter { $0.hasPrefix(prefix) && $0 != prefix }
            .sorted()
            .prefix(limit)
            .map { String($0) }
    }
}
```

### Part B: CompletionPopupView (new file)
Create `Apps/Harness/Sources/HarnessApp/UI/CompletionPopupView.swift`:

A small NSView (max 200pt tall) showing a list of completion candidates.
- NSScrollView + NSStackView with selectable rows
- Highlight current selection (arrow keys)
- Tab/Enter confirms, Escape dismisses
- Anchored below the text cursor position in SyntaxTextView

### Part C: Wire into SyntaxTextView
In `SyntaxTextView.swift`:
- Add a `var symbolIndex: WorkspaceSymbolIndex?` property
- Override `textDidChange(_:)` — after each edit, extract the word prefix at cursor.
  If prefix.count >= 2, query `symbolIndex.completions(prefix:)` and show the popup.
  If empty results or prefix < 2, dismiss popup.
- Handle keyDown for Tab/Enter/Escape/Arrow when popup is visible.

### Wiring
In `ContentAreaViewController` or `FileEditorView`, when a file tab loads:
- Get the workspace root from `SessionCoordinator.shared.settings` or the active
  session's CWD.
- Call `symbolIndex.scan(root:)` once (it debounces internally).
- Pass the symbolIndex to `syntaxView.symbolIndex = index`.

Constraints:
- Off-main scanning only. Never block the main thread.
- Skip binary files, files > 100KB, hidden dirs, node_modules, .git, build, dist.
- Max 10,000 symbols in the index (drop extras).
- `swift build` must pass.
- The popup should use `HarnessDesign.chrome` colors for consistency.
```

---

## Task #4: Git History Right-Click Context Menu (already done — verify only)

Already implemented in this session. Verify that `makeHistoryCard` has:
- Right-click menu with: Copy Commit ID, Copy Commit Message, Copy summary, Show Diff
- `showCommitDetail` handles both `NSClickGestureRecognizer` and `NSMenuItem` sender

Just run `swift build` to confirm.

---

## Verification Checklist

After completing all tasks:
1. `swift build` — must succeed with zero errors
2. `swift test` — full suite must pass
3. Test manually with `make preview`:
   - Sidebar cards show state dots (Task 1)
   - ⌘+⇧+D toggles IDE mode (Task 2)
   - Typing in file editor shows completion popup (Task 3)
   - Right-click on history commit shows context menu (Task 4)
