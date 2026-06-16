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

## Sidebar Session Groups = One Header Per SessionGroup

The sidebar session list follows the same `Workspace -> SessionGroup -> Tab`
hierarchy, but it is a separate surface from the top bar pills. Each
`SessionGroup` should have a visible group header from the start, even if the
group currently contains one session row. That gives users a stable project
anchor and a predictable expand target instead of hiding the container until the
group grows.

The expand affordance should be rendered as symbol state, not as a rotated view.
Swapping the chevron symbol preserves layout in `NSStackView`/Auto Layout
surfaces and avoids the disappearing-chevron regression we hit with
`frameCenterRotation`.

**Practical read:** top bar pills represent the active tab per session; sidebar
group headers represent the session container itself. Keep both visible and do
not collapse the sidebar group model down to a tab-only list.

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

## Tab Pill Visual Details

Pill label = `tabDisplayTitle(tab)` (folder name → custom title → "Terminal").
Branch label = `tab.gitBranch` shown below title as `"⎇ <branch>"` when non-empty (always).
Status dot (6×6) = `BoardColumnKind` color, anchored after title text.

For full pill layout, drag reorder, and git branch detection details see [[tab-bar]].

## Source Map

- `ContentAreaViewController.swift` — `reloadTabBar()` (pill construction), `tabBarDidReorder()` (→ reorderSession)
- `MainMenuBuilder.swift` — `⌘1-9` → `selectWorkspaceNumber`, `⌘[`/`⌘]` → `previousSession`/`nextSession`
- `SessionCoordinator.swift` — `selectSession`, `selectTab`, `selectAdjacentSession`
- `SessionEditor.swift` — `selectSession(workspaceID:sessionID:)`, `selectTab(workspaceID:tabID:)`
- `TerminalTabBarView.swift` — `TabPillView`, `shouldShowBranch`, drag reorder
- `DaemonSyncService.swift:375` — git branch polling (5s interval, `GitMetadataProvider`)
