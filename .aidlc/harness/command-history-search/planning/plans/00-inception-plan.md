# Implementation Plan — Command History Search Overlay

## Status: Planning

## Objective
Implement a Ctrl+R command-history search overlay (`CommandHistorySearchController`) using SwiftPM and strict Swift 6 concurrency, conforming to AppKit standards.

## Tasks

### Phase 1: CommandPromptController & MainMenuBuilder Updates (Surgical Changes)
- [ ] **Task 1.1**: Add a public accessor to `CommandPromptController` exposing `history`:
  ```swift
  var historyEntries: [String] { history }
  ```
- [ ] **Task 1.2**: Implement `presentSeeded(text:)` on `CommandPromptController` to seed the field and position the insertion point at the end:
  ```swift
  func presentSeeded(text: String) {
      present()
      field.stringValue = text
      moveInsertionPointToEnd()
  }
  ```
- [ ] **Task 1.3**: Wire the menu item and MenuTarget action handler in `MainMenuBuilder.swift`.
  - Add sibling menu item "Search Command History..." under "Command Prompt".
  - KeyEquivalent: "r", modifier mask: `.control` (Ctrl+R).
  - Calling `@objc func searchCommandHistory() { CommandHistorySearchController.shared.present() }`.

### Phase 2: CommandHistorySearchController Implementation
- [ ] **Task 2.1**: Implement `CommandHistorySearchController` in a new file `Apps/Harness/Sources/HarnessApp/UI/CommandHistorySearchController.swift`.
  - Singleton `shared`, `@MainActor final class`.
  - `NSPanel` overlay construction.
  - Search field (`NSTextField` with delegate).
  - Results view (`NSTableView` in `NSScrollView`) showing filtered history entries, most-recent-first.
  - Selection management: Up/Down arrow keys move selection (skipping headers or selecting items directly), Enter selects the item, Escape cancels.
  - Integration: Selecting an item closes overlay, calls `CommandPromptController.shared.presentSeeded(text: selectedText)`.

### Phase 3: Verification
- [ ] **Task 3.1**: Build with `swift build --product Harness` and ensure it compiles successfully with no warnings.
