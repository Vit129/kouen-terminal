# CASE — Git / FS / Terminal / Architecture

Grep target: `grep -n "CASE-\|<keyword>" knowledge/cases/misc.md`

## Git / File System

| ID | Trigger | Fix |
|----|---------|-----|
| CASE-009 | Git panel not updating in real-time | DispatchSource on `.git` dir + 500ms debounce |
| CASE-015 | File tree 3s polling wastes CPU | FSEvents watcher + reconcile in-place (preserve expand state) |
| CASE-016 | Nested file add/delete not detected | FSEventStreamCreate on rootPath (recursive); Unmanaged for @convention(c) |
| CASE-020 | Branch chip stale after git checkout | Run git rev-parse at end of loadRoot() |
| CASE-021 | Git Changes panel not real-time | FSEventStreamCreate on rootPath (same WatcherContext pattern) |
| CASE-022 | File preview doesn't update on disk change | FileChangeWatcher (single-file DispatchSource, 0.3s debounce) |

## Terminal / Renderer / Daemon

| ID | Trigger | Fix |
|----|---------|-----|
| CASE-011 | AnyCodable no subscript for nested access | Pattern-match: `if case let .object(inner) = dict["key"]` |
| CASE-017 | Folder expand state resets on refresh | Move isExpanded to @Observable FileTreeNode (survives reconcile) |
| CASE-019 | Terminal selection highlight invisible | Pass selectionBackground from theme in FrameBuilder.init |
| CASE-023 | Garbled TUI (interleaved status fragments) | Don't clear synchronizedOutput in resetForShellPrompt; use 150ms timeout |
| CASE-033 | Tool-injected names appear as OSC 2 title | Strip suffix in daemon updateTabTitle; change pane-border-format default |

## Architecture / Keybindings

| ID | Trigger | Fix |
|----|---------|-----|
| CASE-034 | Keybinding in banner doesn't match menu binding | Centralize in `BannerShortcutRegistry.Keybinding` struct — single source of truth |

## Command Prompt / Parser

| ID | Trigger | Fix |
|----|---------|-----|
| CASE-042 | :z/:view/:edit/:agent etc throw unknownCommand | Add verb to `CommandParser.buildCommand` + `knownVerbs`. See `knowledge/architecture/command-prompt.md` |
