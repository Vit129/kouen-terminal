# Git Panel

## Real-time Refresh (CASE-009)

Git panel wasn't updating on commit/stage/checkout — only refreshed on sidebar tab switch.

**Fix:** DispatchSource.makeFileSystemObjectSource watching `.git` dir with 500ms debounce → auto-refresh.

## Features

- **Changes tab:** Stage/unstage files, commit with message
- **History tab:** Commit list, click → opens file in editor panel (Zed-like)
- **Worktrees tab:** List worktrees, add/remove support
- **Bottom bar:** Branch label, sync/fetch

## History → File Editor

Double-clicking a changed file in History tab opens it in the file editor panel (`ContentAreaViewController.showFileEditorSplit()`).

## Architecture

- `GitPanelView` — custom NSView with tab selector (Changes/History/Worktrees)
- Uses scroll views with stacks for each section
- DispatchSource watcher on `.git` directory for real-time updates
- `clearRoot()` / `updateRoot(path:)` API for sidebar to drive
