# Decision Record: Inception — Command History Search Overlay

## Status: Decided

## Background
- **Harness `:` Command Prompt**: Harness provides a `:` command prompt (`CommandPromptController.shared`) to execute commands.
- **Command History**: It loads and saves commands to `~/Library/Application Support/Harness/command-history.json` and cycles through history via arrow keys.
- **What is missing?**: A convenient, interactive fuzzy search overlay (like Ctrl+R) to query, filter, and execute past commands without cycling one by one.

---

## Decisions

### Decision 1: Overlay UI Construction
**Context**: We need to display a floating text field with a results list below it.
**Options**:
- **A) NSPanel with search field and NSTableView**: Build a custom controller `CommandHistorySearchController` using `NSPanel` to match `CommandPromptController`'s floating appearance, with an `NSTableView` inside an `NSScrollView`.
- **B) Reusing CommandPaletteController**: Adapt `CommandPaletteController` to show command history.
- **C) Custom SwiftUI view inside NSHostingController**: Use SwiftUI for the UI.

**Decision**: A (NSPanel with search field and NSTableView)
**Additional Rationale**: Reusing patterns from `CommandPaletteController` (like `PaletteRowView`) ensures visual consistency (dark mode, transparency, borderless style). Modifying `CommandPaletteController` is blocked as another agent is working on it. SwiftUI is not needed for this simple list.

---

### Decision 2: Text Matching Logic
**Context**: We need a way to filter history items based on search input.
**Options**:
- **A) Full FuzzyMatcher logic from CommandPaletteController**: Duplicate the complex subsequence/scoring enum.
- **B) Simple Subsequence / Substring Match**: Check if query characters exist in history items in order, and use recency (order in history array) as a tiebreaker.

**Decision**: B (Simple Subsequence / Substring Match)
**Additional Rationale**: Command history is typically small (max 100 items), so simple matching with recency (most-recent-first) is fast, lightweight, and completely sufficient.

---

### Decision 3: Seed/Execution Integration with CommandPromptController
**Context**: How to transition from selection in the search overlay to the command prompt?
**Options**:
- **A) Add `presentSeeded(text:)` to CommandPromptController**: Expose an internal method that sets the search field string and positions the caret at the end.
- **B) Reuse `presentTemplate(prompts:template:)`**: Call template presenting and let it select the text.

**Decision**: A (Add `presentSeeded(text:)`)
**Additional Rationale**: Reusing `presentTemplate` is designed for placeholders (`%%`, `%1`) and could select text unexpectedly if the history entry contains those characters. A dedicated, explicit `presentSeeded(text:)` avoids side effects.

---

## Decision Summary

| Decision | Chosen Option | Rationale | Impact |
|----------|---------------|-----------|--------|
| Overlay UI | A (NSTableView + NSPanel) | Matches visual design; avoids editing blocked files | High |
| Matching | B (Simple subsequence) | Simple, lightweight, recency-first | Medium |
| Integration | A (presentSeeded) | Clean interface, avoids template placeholder side-effects | Medium |
