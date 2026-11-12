---
name: macos-swiftui
description: >
  Thai triggers: "ทำแอป Mac", "SwiftUI บน macOS", "เขียน test Swift".
  Use when working with SwiftUI on macOS: NSHostingView, NSViewRepresentable, List onDrag,
  SwiftUI drag-drop, OutlineGroup, NavigationSplitView, @Observable, Transferable,
  XCTest unit/integration testing for macOS Swift packages and apps,
  or any macOS UI component integration with AppKit.
version: 1.2.2
---

# macOS SwiftUI Skill

## Required Context

| Dependency | Purpose |
|---|---|
| `rules/coding.md` | Simplicity first, surgical changes — read before writing code |
| `rules/aodd.md` | Test-before-deliver: `swift test` must pass before declaring done |

Related: drive `@Observable` model logic Red → Green via XCTest; review view hierarchies before merge.

## Trigger
SwiftUI macOS, NSHostingView, NSViewRepresentable, List onDrag, SwiftUI drag-drop,
OutlineGroup, NavigationSplitView, @Observable, Transferable, macOS UI component,
xctest, swift test, swift unit test

---

## Load Right Reference

| Task | Load |
|------|------|
| @State, @Observable, @Binding, state wrappers | `references/state-management.md` |
| NavigationSplitView, List tree, toolbar, shortcuts | `references/ui-components.md` |
| .onDrag, .dropDestination, Transferable, UTType | `references/drag-drop.md` |
| NSHostingView, NSViewRepresentable, bridging | `references/appkit-swiftui.md` |
| Async FileManager, directory scan, lazy children | `references/filesystem.md` |
| XCTest for @Observable / @MainActor models & Robot boundary | `references/testing.md` |

---

## Anti-Patterns

| Anti-pattern | Fix |
|---|---|
| Side effects in `body` | Use `.task { }` or `.onAppear { }` |
| `@StateObject` with `@Observable` | Use `@State` with `@Observable`; `@StateObject` only for `ObservableObject` |
| NSItemProvider callback updating `@State` directly | Dispatch to `DispatchQueue.main` or `Task { @MainActor in }` |
| File I/O on main thread | `Task.detached(priority: .utility)` |
| Force-unwrap NSItemProvider loads | Always check error + nil |
| `FileRepresentation`-only Transferable | Always add `CodableRepresentation` fallback |
| Fat `@EnvironmentObject` re-rendering all | Break into focused models; use `@Observable` per-property tracking |

---

## When to Fall Back to AppKit

| Need | Reason |
|---|---|
| Drag preview customization | SwiftUI previews corrupt/invisible on macOS; use `NSDraggingItem.imageComponentsProvider` |
| Hierarchical drag-to-reorder | `List(children:)` cannot reorder hierarchical items as of macOS 14 |
| `NSSplitView` programmatic collapse | `NavigationSplitView` can't collapse programmatically |
| Rich text / `NSAttributedString` editing | `TextEditor` is too thin; need `NSTextView` |
| Per-location context menus | SwiftUI `.contextMenu` fires per-view; AppKit `NSMenu` varies by click position |
| Complex multi-column `NSTableView` | SwiftUI `Table` lacks row actions, complex cell editing |
| Menu bar status items | `MenuBarExtra` (macOS 13+) for simple; `NSStatusItem` for complex |

---

## `swift test` gotchas (SPM app with binary frameworks)

- **Test bundle fails to load: `Library not loaded: @rpath/Sparkle.framework`** (common in fresh
  git worktrees). `DYLD_FRAMEWORK_PATH` does not help. Fix: copy the framework from
  `.build/artifacts/**/<Name>.xcframework/macos-*/<Name>.framework` into
  `.build/out/Products/Debug/PackageFrameworks/`, then `swift test --skip-build`.
- **`--filter ClassName` runs 0 tests silently** in multi-target packages. Use the full
  `Module.ClassName` form (e.g. `MyAppCoreTests.FooTests`); `--list-tests` shows the names.
- **`swift test --filter X | tail` shows "Executed 0 tests"** even when X ran: `tail` lands on another
  (empty) test bundle. `grep "Executed [1-9]"` or the suite name instead.
- **Moving code out of a file breaks tests that grep that file's text** (robot/JS tests reading the
  Swift source). `grep -rn <FileName> Tests/` before the move; point those tests at the new file.
- Calling an app type's static helper from XCTest → "main actor-isolated" error if the type is
  `@MainActor` (NSViewController). Mark pure helpers `nonisolated static`.


## Self-Update (after every use)

This skill is its own memory. When using it brought a correction, a gotcha,
or a wrong/missing step, and the fix was verified, patch this file in place: a new anti-pattern, build/test gotcha, or a fallback case not yet in the tables above.
Then bump `version` (patch) and `last_improved`. Procedure: `docs/skill-learning.md`.
