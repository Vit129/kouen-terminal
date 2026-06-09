# Git Panel

## Real-time Refresh

### v1 — CASE-009 (resolved, superseded)
Git panel wasn't updating on commit/stage/checkout only.
Fix: DispatchSource.makeFileSystemObjectSource watching `.git` dir with 500ms debounce.
**Limitation:** Non-recursive — doesn't detect working tree file edits/creates/deletes.

### v2 — CASE-021 (current)
Git Changes panel didn't update when files were edited/created/deleted in the working tree.
Root cause: DispatchSource on `.git` only fires on index/HEAD changes, not working tree changes.
**Fix:** Replaced with FSEventStreamCreate on `rootPath` — recursive, catches all working tree changes.
Pattern: same `WatcherContext + Unmanaged.passRetained` as `FileTreeWatcher` (see CASE-016).

### Branch chip — CASE-020
Branch chip showed stale branch after `git checkout`.
Root cause: `refreshGitBranch()` reads `SessionCoordinator.snapshot` (may be stale). `loadRoot()` never updated it.
**Fix:** Run `git rev-parse --abbrev-ref HEAD` at end of `loadRoot()` and set `gitBranch` directly.

## FSEvents Pattern (Swift Actor)

```swift
// WatcherContext: bridges Swift closure to @convention(c) callback
private final class WatcherContext: @unchecked Sendable {
    let onChange: @MainActor () -> Void
}

// Pass via Unmanaged (retained)
let ptr = UnsafeMutableRawPointer(Unmanaged.passRetained(contextWrapper).toOpaque())
var context = FSEventStreamContext(version: 0, info: ptr, retain: nil, release: nil, copyDescription: nil)

let callback: FSEventStreamCallback = { _, clientInfo, _, _, _, _ in
    let wrapper = Unmanaged<WatcherContext>.fromOpaque(clientInfo!).takeUnretainedValue()
    Task { @MainActor in wrapper.onChange() }
}

// Flags: file-level events, no defer, CFTypes
FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagNoDefer | kFSEventStreamCreateFlagUseCFTypes)

// Schedule on utility queue
FSEventStreamSetDispatchQueue(stream, DispatchQueue.global(qos: .utility))
FSEventStreamStart(stream)

// Cleanup: stop → invalidate → release stream, then release context pointer
FSEventStreamStop(stream); FSEventStreamInvalidate(stream); FSEventStreamRelease(stream)
Unmanaged<WatcherContext>.fromOpaque(ptr).release()
```

## Features

- **Changes tab:** Stage/unstage files, commit with message
- **History tab:** Commit list, click → opens file in editor panel (Zed-like)
- **Worktrees tab:** List worktrees, add/remove support
- **Bottom bar:** Branch label (real-time via git rev-parse), sync/fetch

## History → File Editor

Double-clicking a changed file in History tab opens it in the file editor panel (`ContentAreaViewController.showFileEditorSplit()`).

## Architecture

- `GitPanelView` — custom NSView with tab selector (Changes/History/Worktrees)
- FSEvents recursive watcher on `rootPath` (utility queue, 500ms latency)
- `clearRoot()` / `updateRoot(path:)` API for sidebar to drive
