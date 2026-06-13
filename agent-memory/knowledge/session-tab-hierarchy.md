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

A session's `Tab`s are NOT shown as separate pills — switching tabs within a session
just changes that session's pill label. Splits (`Pane`s within a `Tab`'s `PaneNode`)
are also invisible at the pill level.

**Easy misread:** screenshots showing N pills look like "N tabs", but they are N
*sessions*. Verify against `reloadTabBar()` before reasoning about pill-based UI.

## ⌘1-9 and ⌘[ / ⌘] = Session-level navigation (CASE-028)

`MainMenuBuilder.swift` binds `⌘1`-`⌘9` to `MenuTarget.selectWorkspaceNumber(_:)` →
`SessionCoordinator.selectSession(workspaceID:sessionID:)` → `workspace.sessions[index]`.
This is correct and matches the top bar pills 1:1.

`⌘[` / `⌘]` bind to `MenuTarget.previousSession`/`nextSession` →
`SessionCoordinator.selectAdjacentSession(offset:)`, which cycles `workspace.sessions`
the same way — i.e. all primary navigation shortcuts now target the Session level, which
is the level actually visible as pills. `CommandPaletteController`'s
"Previous/Next Session" actions (`nav.prevSession`/`nav.nextSession`) call the same
`selectAdjacentSession`.

**Removed (CASE-028):** `selectTabNumber(_:)` (MainMenuBuilder), `SessionCoordinator
.selectTab(atIndex:)`, and the old `selectAdjacentTab(offset:)` — these operated on
`workspace.tabs` = `activeSession.tabs`, an internal collection with no separate pills,
so binding a shortcut to them was a silent no-op from the user's perspective. Per
research into WezTerm (`Workspace → Tab → Pane`, single tab bar, no secondary tab row)
and Chrome tab groups (inline, not a separate row), there is no common pattern for a
"Tab within Session" row — so this UX is intentionally **not** being built. If a future
need arises, it requires a new visible affordance first (the underlying `selectTab
(workspaceID:tabID:)` / `selectAdjacentTab`-equivalent IPC plumbing is still used
elsewhere, e.g. `closeTab`, agent notch, command palette tab list — only the *menu-level
keyboard shortcut* layer was removed).

## Source Map

- `ContentAreaViewController.swift` — `reloadTabBar()` (pill construction)
- `MainMenuBuilder.swift` — `⌘1-9` → `selectWorkspaceNumber`, `⌘[`/`⌘]` → `previousSession`/`nextSession`
- `SessionCoordinator.swift` — `selectSession`, `selectTab`, `selectAdjacentSession`
- `SessionEditor.swift` — `selectSession(workspaceID:sessionID:)`, `selectTab(workspaceID:tabID:)`
