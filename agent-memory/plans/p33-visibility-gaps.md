# P33 — Visibility Gaps (PR status, cross-pane notifications, diff viewer polish)

Status: **Phase 1-2 done, Phase 3 deferred** — build/test/robot green
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

### F2 — Cross-pane notification visibility — P0 — **premise corrected mid-implementation (again)**

Same shape as F1: the original plan assumed `AgentNotification`/`OSCNotificationParser` (OSC
9/99/777 terminal-sequence parsing) was the live notification path with only a single-tab-dot
consumer. Deeper trace before writing code found `OSCNotificationParser` is **actually dead** —
zero call sites anywhere — and the real, live path is a completely different one: the IPC
`.notify(surfaceID, title, body)` request (fired by agent hooks, e.g. Claude Code's
Notification/Stop hooks via `AgentHookInstaller`) → `SurfaceRegistry.markWaiting` →
`Tab.status = .waiting` + `Tab.notificationText`. That path already drives, all shipped and
working:
- **Per-pane glowing ring** — `TerminalHostView.drawTerminalOverlay` draws a `.systemBlue`
  4pt border on ANY pane whose tab is waiting (`NotificationCoordinator.syncWaitingRings()`
  sets `host.isWaiting` for every host, not just the active one) — this **is** cmux's "ring,"
  already built, already cross-pane.
- **Dock badge** — waiting-tab count (`NotificationCoordinator.updateDockBadge`).
- **Native macOS notification banner + sound** (`DesktopNotifier`, gated on app-not-active /
  tab-not-focused, deduped by `pushedNotificationKeys`).
- **Notch panel** (`AgentNotchRootView`) — cross-session waiting list with `notificationText`,
  jump-to-agent — opt-in via `notchVisibilityMode`/`experienceMode`, not always visible.

The one thing genuinely missing: `Tab.notificationText` is **not surfaced in the sidebar** —
the one UI element that's always visible regardless of Notch settings or which tab/split is
focused. `sessionBoardStatus` (already shown in the sidebar row) is a *different* signal
(`BoardModel.columnKind`, driven by `agent.activity`) — a coarse category label, not the actual
hook-fired message, and doesn't necessarily correlate with `tab.status == .waiting`.

Scoped down to just that gap:
- `SidebarSessionItemRow` gains `waitingNotificationText` — shows `tab.notificationText` (in
  the ring's `.systemBlue`) in place of the generic `sessionBoardStatus` label when the tab is
  actually `.waiting`, falling back to the existing label otherwise.
- Zero new backend/polling/parsing — reuses data already flowing through the existing synced
  `SessionSnapshot` → `SidebarListModel.update(from:)` path, which already runs unconditionally
  on every metadata tick ("SwiftUI model sync — always update so badges/agent status stay
  fresh", `HarnessSidebarPanelViewController.swift:741`) specifically so fields like this stay
  current — confirmed this call is NOT gated behind `Tab.isStableEqual` (which itself does NOT
  compare `notificationText`, only `status` — a second notification's text while already
  `.waiting` wouldn't flip `status`, but since the sidebar update path is unconditional this
  doesn't matter here; noted as a latent gap for any *future* consumer that gates on
  `isStableEqual` instead).
- `rebuildRows()` (what `.update(from:)` calls) verified to be pure in-memory grouping/sorting,
  no shell-out, safe to run on every tick — same pathway already used for git-branch/status
  badges today, not a new performance surface.

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

### Phase 2 — Sidebar notification text (F2, P0) — ✅ done

- [x] Discovered the "ring"/"marker" part of this phase already ships (`TerminalHostView`
      waiting-ring, cross-pane, since before this session) — did NOT rebuild it
- [x] `SidebarSessionItemRow.waitingNotificationText` added — shows `tab.notificationText` in
      `.systemBlue` (matching the ring color) when `tab.status == .waiting`, replacing the
      generic `sessionBoardStatus` label for that row only
- [x] No new tests needed — pure view-layer read of existing synced state, no new state
      machine/async path to regress-test (unlike Phase 1's `archiveScript`, there's no new
      execution path here, just a new render branch on already-tested data)

Exit criteria: with 2+ panes open and an agent notification firing on a background one, the
user can tell which pane needs attention without switching to it — ✅ already true via the
existing ring + dock badge before this phase; this phase adds *why* (the message text) visible
in the sidebar without needing the Notch panel enabled. `swift build`/`swift test` (2
pre-existing unrelated failures only)/`Tests/robot/run.sh` all clean.

### Phase 3 — Diff viewer polish (F3, P2, optional) — ✅ done, scoped narrower than F3's original text

- User asked to see the tradeoffs before picking a redesign direction (a dedicated file-list+diff
  sidebar panel vs improving the existing tab-open flow) — while checking, found
  `GitPanelView.presentCommitDetail` was a **fully complete, already-working popover** (file-nav
  bar + colored diff via `NSPopover`, anchored to the commit card) with **zero call sites** — the
  same dead-code-next-to-live-path shape as Phase 1/2. Since the popover floats over the content
  area via `.show(relativeTo:of:preferredEdge:.maxX)`, the 220pt-pinned-sidebar-width concern
  that motivated the "which direction" question didn't actually apply.
- [x] Rewired the commit-card click gesture from `showCommitDetail` (opens a full editor tab) to
      a new `previewCommitDetail` handler that calls the existing `presentCommitDetail` popover
      instead — zero new UI code, just pointing the click at code that already existed.
- [x] Kept the old full-tab-open behavior reachable via the context menu, renamed "Show Diff" →
      "Open Full Diff in Tab", for the copy/search/keep-open case.
- Not visually verified by the agent — this session has no display access (background job,
  `screencapture` fails with "could not create image from display"); build/tests were the only
  verification until the user confirmed manually.

### Sidebar bug found + fixed during Phase 1-3 manual QA (not a P33 feature, but same branch)

- User found: sidebar renders as an empty/blurred material panel with no visible content on the
  *first* `⌘\` reveal after every launch (confirmed present in production too — predates this
  session's work entirely, not caused by F1/F2/F3).
- Root cause: `MainSplitViewController.viewDidLoad` sets
  `sidebarContainer.translatesAutoresizingMaskIntoConstraints = false` with no constraint of its
  own (only its child `sidebar.view` is pinned to its edges) — but `sidebarContainer` is an
  `NSSplitView` arranged subview, which NSSplitView positions via direct frame assignment
  (`setPosition`), not Auto Layout. `content.view` (the unaffected sibling) never had this flag
  touched. An existing fix (CASE-042 — `panel.layoutSubtreeIfNeeded()` at animation end, to flush
  blank SwiftUI content after first reveal) triggers Auto Layout to resolve `sidebarContainer`'s
  now-ambiguous geometry, collapsing it to 0-width and wiping out the frame `setPosition` had
  just set moments earlier.
- Confirmed via targeted `fputs` instrumentation (no display access to verify visually) — added,
  used to capture real frame values from the user's terminal, then fully removed before the fix
  landed. Fix: removed the `= false`. See `RL-062`/`CASE-061`.
- An earlier attempted fix (wrapping `updateSidebarPlacement()`'s `adjustSubviews()` call in
  `setPresentsWithTransaction`) was reverted — that function is only reachable via
  "Move Sidebar to Right," a different code path from the user's plain `⌘\` repro, confirmed
  inert via `settings.json` inspection before being reverted.

### Post-commit review (Opus, high effort, workflow-backed) — 4 findings, all fixed

User asked for a second-opinion structural review of the whole branch. 12-agent workflow (finder
angles + independent verifier per finding) returned 9 raw candidates, collapsed to 4 distinct
defects after dedup — all 4 confirmed via source trace (debug-mantra: fail-path traced through
actual code, not guessed) and fixed:

1. **Crash risk (most severe)** — `GitPanelView.previewCommitDetail` (new in this branch)
   captures the commit-card `NSView` before `await runGit(["show", ...])`, then anchors an
   `NSPopover` to it. Confirmed via trace: `applyState()` (called from the FSEventStream-driven
   `refresh()`) does `historyStack.arrangedSubviews.forEach { $0.removeFromSuperview() }` on
   every git-history refresh — if that fires while the `await` is in flight, the captured card
   is detached, and presenting a popover anchored to it is invalid. Fix: guard `card.window !=
   nil` after the await, bail if detached. See `RL-063`.
2. **`waitingNotificationText` only checked `activeTab ?? tabs.first`**, unlike its sibling
   `sessionBoardStatus` which scans all `session.tabs` — a background tab's notification could
   never surface, directly contradicting this same phase's stated goal ("regardless of which
   tab/split is focused"). Fix: scan all tabs, matching `sessionBoardStatus`'s pattern.
3. **`gh` path-resolution mismatch** — `SidebarListModel.cachedGhPath` (the availability guard
   for `fetchGitMetadata`) has a `which gh` fallback beyond the 3 hardcoded paths;
   `GitHubCLIClient.runGH` (the actual fetch, swapped in during Phase 1) didn't — so a user with
   `gh` at a non-standard location (MacPorts, asdf/mise shim) could pass the guard but still get
   a silently-failing fetch, breaking the PR badge with no error. Fix: added the same `which gh`
   fallback to `GitHubCLIClient`'s path resolution (cached statically) — fixes it for every
   consumer of `GitHubCLIClient`, not just this call site.
4. **Minor cleanup** — `previewCommitDetail` and `showCommitDetail` duplicated the identical
   `git show --stat --patch` invocation verbatim. Extracted to a shared `fetchCommitDiff` helper
   while fixing #1 anyway.

No new regression tests added for these — the touched code (AppKit view lifecycle timing, a
SwiftUI computed property, `Process`-based shell-out path resolution) has no existing test
scaffolding in this codebase to extend consistently with, and building fixture-based tests for
an inherently timing-dependent race (#1) would need scaffolding beyond this pass's scope.

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
