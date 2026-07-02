# P33 — Visibility Gaps (PR status, cross-pane notifications, diff viewer polish)

Status: **Planning**
Priority: **P1** — closes the remaining gaps vs cmux/Supacode found in the 2026-07-02 competitor
research (web search: cmux, Supacode, WezTerm, Superset, AgentsRoom), on top of P32's
task-worktree parity work.
Owner surface: `PRStatusPoller`, `SidebarSessionListView`, `NotificationBus`/`AgentNotification`,
`SessionCoordinator`, `GitPanelView`
Created: 2026-07-02
Depends on: P32 (task-based worktrees, done) for the sidebar row pattern F1 reuses.

---

## Why

2026-07-02 competitor research (see chat) confirmed, by reading the actual code (not just
memory notes), that two of Harness's three "gap" items already have working backend code that
was simply never wired to any UI — same shape as `archiveScript` before P32 Phase 3:

- **PR status**: `PRStatusPoller.swift` polls `gh` every 30s and maintains `prBySession`, but
  `grep`-ing the whole app finds exactly one call site (`AppDelegate.swift:62`, `.start()`) —
  `onUpdate` is never assigned and `prBySession` is never read. cmux (sidebar PR badge/number)
  and Supacode (title-bar notch with PR check status) both ship this wired and visible.
- **Cross-pane agent notifications**: `AgentNotification`/`OSCNotificationParser` correctly
  parses OSC 9/99/777 + bell, but the only consumer (`SessionCoordinator.notificationPosted`,
  `SessionCoordinator.swift:112-114`) just flips a single tab's status dot. cmux's actual bar:
  a pane ring + sidebar "latest notification text" visible **across splits and tabs**, not
  just the one tab that made the noise.
- **Diff viewer**: this one is *not* a wiring gap — `GitPanelView.showCommitDetail` (per-commit)
  and `.showChangedFileDiff` (per-file uncommitted) both work today, opening a syntax-highlighted
  diff as an editor tab. The gap vs cmux-hub/Supacode is UX polish (dedicated panel vs
  open-as-tab), not missing functionality — scoped down accordingly (P2, optional).

## Non-goals (this plan)

- Multi-agent "teams" orchestration UI, mobile/cross-machine oversight (AgentsRoom's category)
  — different product surface, not a gap in the terminal-only comparison set the user asked for.
- Team sharing / cloud sync, SOC2/compliance tooling (Superset's enterprise features) — not
  relevant to a local single-user open-source app.
- Rebuilding the Board view's task-card status UI — already exists (`BoardViewController`,
  fixed this session in `49a67ba`) and already matches what Superset calls "task cards."

---

## Feature Specs

### F1 — PR status in sidebar — P0 — **premise corrected mid-implementation**

`PRStatusPoller` was a **red herring**: it's dead/duplicate code, but a *second*, fully-wired
PR mechanism already existed and was live in production — `SidebarListModel.fetchGitMetadata`
(shells `gh pr view --json number,url` directly) feeding `SidebarSessionItemRow`'s `#123` badge
(clickable, `onPRClick`, ahead/behind counts) in `SidebarSessionListView.swift:270-286`. Found
only by reading the actual row-rendering code, not by grepping for `PRStatusPoller` alone.

The real (much smaller) gap: that live path fetched `number`/`url` only — no CI checks status,
so a badge existed but never showed pass/fail/pending. Implemented:
- `SidebarListModel.fetchGitMetadata` now calls `GitHubCLIClient().prForCurrentBranch(repoPath:)`
  (which already parses `statusCheckRollup` into `.pass`/`.fail`/`.pending`/`.none`) instead of
  its own hand-rolled `gh pr view --json number,url` `Process` call — dedupes two near-identical
  GitHub CLI wrappers into one.
- `RepoGitMetadata` gained `prChecksStatus: GitHubCLIClient.ChecksStatus?`.
- `SidebarSessionItemRow` renders a small colored dot (green/red/yellow) next to the `#123`
  badge, with a `.help()` tooltip ("Checks passing/failing/pending").
- Deleted `PRStatusPoller.swift` and its dead `AppDelegate.swift:62` call site — duplicate
  polling of the same data the sidebar already fetches on its own 60s cache cycle.

### F2 — Cross-pane notification visibility — P0

- Backend (`AgentNotification`, `OSCNotificationParser`) is correct and reusable as-is —
  scope is presentation only.
- Add a small per-session "last notification" surface in the sidebar row (mirrors cmux's
  "latest notification text" in the vertical-tab sidebar) — reuse the same row-insertion pattern
  as F1/P32-Phase2's task name.
- Add a visual cue on the pane/tab itself when a notification lands on a *background* pane —
  today `notificationPosted` only updates the status dot of the tab that received it; extend so
  a pane in an inactive split also gets a visible marker (cmux's "ring"), not just the tab bar.
- Keep scope to presentation — do not touch the OSC parsing or `NotificationBus` transport.

### F3 — Diff viewer polish — P2 (optional, defer unless requested)

- Current `showCommitDetail`/`showChangedFileDiff` behavior (open diff as a temp-file editor
  tab) is functional, not broken — this is UX preference, not a missing capability.
- If pursued: a dedicated side panel (list of changed files + inline diff pane) instead of
  opening each diff as a separate tab, closer to cmux-hub/Supacode's inline review UX.
- Explicitly lower priority than F1/F2 since both of those are "wired backend already exists,
  zero risk" fixes, while this is a UI redesign with real design-decision surface — recommend
  confirming direction with user before starting, not bundling into the same pass as F1/F2.

---

## Implementation Phases

### Phase 1 — PR checks-status dot (F1, P0) — ✅ done

- [x] `SidebarListModel.fetchGitMetadata` fetches `checksStatus` via `GitHubCLIClient`
- [x] `RepoGitMetadata.prChecksStatus` added
- [x] Colored dot (pass=green/fail=red/pending=yellow) rendered next to the existing `#123`
      PR badge in `SidebarSessionItemRow`, with tooltip
- [x] Deleted dead `PRStatusPoller.swift` (never wired) instead of wiring it — the sidebar's
      own `gitMetadataCache` (60s TTL) already did the job; wiring a second poller would have
      been duplicate work, not a fix

Exit criteria: a session on a branch with an open PR shows the PR number (already existed) +
check-status dot in the sidebar. ✅ `swift build`/`swift test` (only the 2 pre-existing unrelated
failures)/`Tests/robot/run.sh` all clean.

### Phase 2 — Cross-pane notification visibility (F2, P0)

- [ ] Sidebar row shows the session's most recent `AgentNotification.title`/`.body` (truncated),
      keyed the same way `prBySession` is keyed
- [ ] Background pane (not the active one in its split) gets a visible marker when it receives
      a notification, cleared on becoming active/focused
- [ ] Unit test: notification landing on a non-active pane sets the marker; switching to that
      pane clears it

Exit criteria: with 2+ panes open and an agent notification firing on a background one, the user
can tell which pane needs attention without switching to it first.

### Phase 3 — Diff viewer polish (F3, P2, optional)

- [ ] Deferred — confirm scope/direction with user before starting (design surface, not a
      wiring fix like Phase 1/2)

---

## Testing and Verification

- [ ] `swift build --product Harness` clean after each phase
- [ ] `swift test` — new tests for PR badge rendering logic + notification marker state
- [ ] `Tests/robot/run.sh` — no regressions
- [ ] Manual: open a repo with an active PR, confirm badge appears/updates; trigger an OSC 9
      notification on a background pane, confirm marker visibility

---

## Risks

- `PRStatusPoller` shells out to `gh` every 30s per non-default-branch session — already rate
  limited by the existing poll interval, but wiring it to actually render means poll failures
  need to fail silently (already the case — `guard available == true else { return }`).
- Notification marker on background panes must not leak/accumulate if a pane is closed while
  marked — reuse existing per-surface cleanup pattern (`terminalHosts.removeHost`) rather than a
  new dictionary that needs its own eviction logic.

---

## First Implementation Slice

1. Wire `PRStatusPoller.onUpdate` → sidebar refresh (Phase 1), verify with a real repo that has
   an open PR.
2. Add the PR badge to `SidebarSessionListView` next to the existing status label.
3. Layer in notification visibility (Phase 2) using the same row-insertion pattern.
4. Leave diff viewer polish (Phase 3) for a separate session once user confirms it's wanted.
