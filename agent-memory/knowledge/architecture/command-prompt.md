# Command Prompt Architecture

## Layers

```
User types `:z mydir`
  → CommandPromptController.commit()
    → CommandParser.parse("z mydir")
      → resolveAlias("z") → "cd"
      → buildCommand(name: "cd", tokens: ["mydir"])
    → MainExecutor.execute(command)
```

## Key rule: every documented verb needs BOTH layers

1. **CommandParser.buildCommand** — case in switch + entry in `knownVerbs`
2. **MainExecutor** — handler for the resulting Command enum case

Missing either = `unknownCommand` error when user types it.

## Verb categories

| Category | Examples | Mechanism |
|----------|----------|-----------|
| Workbench intents | find, grep, cd, view, errors, make, agent | `.workbench(...)` → MainExecutor |
| Multiplexer | split-window, kill-pane, select-pane | `.splitWindow(...)` etc |
| Shell passthrough | fzf, zi, rg, fd, bat, eza, jq | `.sendKeys([cmd, "Enter"])` |
| Aliases | z→cd, e→view, neww→new-window | resolve before buildCommand |

## Gotchas

- `knownVerbs` tested by `CommandParserTests.testKnownVerbsAreAllParseable`
- Aliases don't need knownVerbs entry
- `:cd`/`:z` uses `MainExecutor.zoxideQuery` fallback when path doesn't exist on disk

## Files

- `Packages/HarnessCore/.../Commands/CommandParser.swift` — parser, aliases, knownVerbs
- `Apps/Harness/.../Services/MainExecutor.swift` — executor, zoxideQuery helper
- `Packages/HarnessCore/.../Workbench/WorkbenchCommand.swift` — intent enum
- `Apps/Harness/.../UI/CommandPalette/CommandPromptController.swift` — UI + history
