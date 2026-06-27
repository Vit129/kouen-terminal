# Implementation Plan: Phase 11 — Recipes in Harness

## Status: Planning

## Objective
Implement Phase 11 (Recipes) under `Dev Only` / `SDLC` mode:
- Create `RecipesStore` to manage persistence of saved commands.
- Implement `RecipePickerController` as an NSPanel fuzzy picker.
- Register `recipes` shortcut (⌘⇧R) and add "Recipes…" to main menu.

## Feature Implementation Plan

### Task 1.1: Create `RecipesStore.swift`
- **Location**: `Packages/HarnessCore/Sources/HarnessCore/RecipesStore.swift`
- **Scope**:
  - `@MainActor final class RecipesStore`
  - `Recipe` struct: `{id: UUID, name: String, command: String, runImmediately: Bool}`
  - Backing file at `~/Library/Application Support/Harness/recipes.json`
  - Methods: `load()`, `save()`, `add(recipe:)`, `delete(recipe:)`, `update(recipe:)`
  - Initialize with some default recipes (e.g., "List Files", "Git Status", "Check Ports") if the file does not exist.

### Task 1.2: Support Pre-filled Text in `ComposerPanel`
- **Location**: `Apps/Harness/Sources/HarnessApp/UI/Shared/ComposerPanel.swift`
- **Scope**:
  - Update `present(relativeTo window: NSWindow?)` to `present(relativeTo window: NSWindow?, initialText: String = "")`
  - Set `textView.string = initialText`
- **Location**: `Apps/Harness/Sources/HarnessApp/Services/SessionCoordinator.swift`
  - Update `openComposer()` to `openComposer(withInitialText text: String = "")` and pass it down.

### Task 1.3: Create `RecipePickerController.swift`
- **Location**: `Apps/Harness/Sources/HarnessApp/UI/Shared/RecipePickerController.swift`
- **Scope**:
  - `RecipePickerController` wrapper (static present method, NSPanel container)
  - `RecipePickerModel` (`@Observable`, filtering and selection state)
  - `RecipePickerView` (SwiftUI view with search bar, list of matches, and hotkey hints)
  - Action on activation:
    - If `recipe.runImmediately` is true: send command + `\n` to active PTY via `host.sendInput(...)`
    - Else: call `SessionCoordinator.shared.openComposer(withInitialText: recipe.command)`

### Task 1.4: Register Keybinding and Menu Item
- **Location**: `Packages/HarnessCore/Sources/HarnessCore/ReleaseNotes/BannerShortcutRegistry.swift`
  - Add `recipes` Keybinding with shortcut `Cmd+Shift+R`.
- **Location**: `Apps/Harness/Sources/HarnessApp/UI/Chrome/MainMenuBuilder.swift`
  - Add "Recipes…" menu item pointing to `MenuTarget.recipes` using `BannerShortcutRegistry.recipes`.
  - Implement `@objc func recipes()` in `MenuTarget` class.

## Verification
- Confirm compiler compiles successfully.
- Verify `recipes.json` gets created with default recipes.
- Open picker via `Cmd+Shift+R`, filter, select and run.
- Select a recipe with `runImmediately: false` and verify it populates the composer.
