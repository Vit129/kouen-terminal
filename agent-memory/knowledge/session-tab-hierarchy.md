# Session/Tab/Pane Hierarchy & Top Bar (CASE-028)

## Data Model

`Workspace` (macOS window, `⌘⇧N`/`⌘⇧W`) → `SessionGroup` ("Session") → `Tab` → `PaneNode` tree → `Pane` → `Surface` (PTY).

- A `Workspace` has `sessions: [SessionGroup]`.
- Each `SessionGroup` has `tabs: [Tab]` and an `activeTab`.
- `workspace.tabs` is shorthand for `activeSession.tabs` — NOT all tabs across all sessions.

## Top Bar = 1 Pill Per Session (not per-tab)

`ContentAreaViewController.reloadTabBar()` builds the top bar pills from
`workspace.sessions.compactMap { session.activeTab ?? session.tabs.first }` —
**one pill per `SessionGroup`**, labeled with that session's currently-active `Tab`.

A session's `Tab`s (switched via `⌘⇧[`/`⌘⇧]` → `selectAdjacentTab`) are NOT shown as
separate pills — switching tabs within a session just changes that session's pill label.
Splits (`Pane`s within a `Tab`'s `PaneNode`) are also invisible at the pill level.

**Easy misread:** screenshots showing N pills look like "N tabs", but they are N
*sessions*. Verify against `reloadTabBar()` before reasoning about pill-based UI.

## ⌘1-9 = Switch to Session N (CASE-028)

`MainMenuBuilder.swift` binds `⌘1`-`⌘9` to `MenuTarget.selectWorkspaceNumber(_:)` →
`SessionCoordinator.selectSession(workspaceID:sessionID:)` → `workspace.sessions[index]`.
This is correct and matches the top bar pills 1:1 — **do not** rebind `⌘1-9` to
`selectTabNumber(_:)` / `SessionCoordinator.selectTab(atIndex:)` (operates on
`workspace.tabs` = `activeSession.tabs`, an internal collection with no separate pills).
That rebind compiles fine but is a silent no-op from the user's perspective — pressing
`⌘1-9` does nothing visible because the targeted "tab" isn't what's on screen.

`selectTabNumber(_:)` / `selectTab(atIndex:)` remain pre-existing dead code (from commit
f82b1b1), unbound to any key. Any future "switch Tab within active Session" UX needs a
*new* visible affordance (e.g. a secondary row of pills) before binding a shortcut to it
— `⌘⇧[`/`⌘⇧]` already cycle tabs but only change the active session's pill label.

## Source Map

- `ContentAreaViewController.swift` — `reloadTabBar()` (pill construction)
- `MainMenuBuilder.swift` — `⌘1-9` → `selectWorkspaceNumber`, `⌘⇧[`/`⌘⇧]` → `previousTab`/`nextTab`
- `SessionCoordinator.swift` — `selectSession`, `selectTab`, `selectAdjacentTab`, `selectTab(atIndex:)`
- `SessionEditor.swift` — `selectSession(workspaceID:sessionID:)`, `selectTab(workspaceID:tabID:)`
