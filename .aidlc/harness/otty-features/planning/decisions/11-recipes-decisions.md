# Decision Record: Phase 11 — Recipes in Harness

## Status: Decided

## Background
- **What is Recipes?** A feature to manage, find, and execute saved command snippets, layouts, or scripts in active terminal sessions.
- **Goal**: Implement a persistent JSON store (`recipes.json`) in Harness, a fuzzy picker panel for recipes (modeled after `CommandPaletteController`), and menu item / keyboard shortcut registration (Cmd+Shift+R).

---

## Outstanding Decisions

### Decision 1: Persistence Location and Format
**Context**: We need to persist recipes across launches.
**Decision**: Save to `~/Library/Application Support/Harness/recipes.json` (specifically `HarnessPaths.applicationSupport.appendingPathComponent("recipes.json")`).
**Schema**:
```swift
struct Recipe: Codable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let command: String
    public let runImmediately: Bool
}
```
**Rationale**: Using a lightweight Codable struct backed by JSON is clean, type-safe, and matches the configuration management style of the rest of the application.

---

### Decision 2: Recipe Execution Integration
**Context**: On selection of a recipe in the picker, how should it be run or pasted?
**Decision**:
- If `runImmediately` is true: send the command text followed by a newline directly to the active `TerminalHostView` using `host.sendInput(...)`.
- If `runImmediately` is false: paste the command text to the `ComposerPanel` by presenting it pre-filled with the command.
**Rationale**: This keeps implementation clean and directly leverages the existing `ComposerPanel` and active host inputs.

---

### Decision 3: Recipe Picker UI Architecture
**Context**: How to structure the fuzzy search picker?
**Decision**: Replicate the structure of `CommandPaletteController` using `NSPanel` + `NSHostingController` + `SwiftUI` View. Define `RecipePickerController` in `UI/Shared/RecipePickerController.swift` with its own `RecipePickerModel` and `RecipePickerView`.
**Rationale**: Reusing `CommandPaletteController`'s design patterns ensures visual consistency (colors, animation, fonts) and minimizes implementation risk.

---

## Decision Summary

| Decision | Chosen Option | Rationale | Impact |
|----------|---------------|-----------|--------|
| Store Path | JSON in Application Support | Fits AppKit best practices and Harness paths | Low |
| Execution | Direct PTY send or Composer pre-fill | Clean integration with SessionCoordinator | Medium |
| UI Shape | NSPanel + SwiftUI picker | Reuses proven command palette architecture | High |
