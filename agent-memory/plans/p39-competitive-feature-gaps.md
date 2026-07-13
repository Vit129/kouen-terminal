# P39 — Competitive Feature Gaps (cmux / Supacode / Superset / WezTerm / Zed / tmux)

> Refresh of `agent-memory/knowledge/meta/competitive-position.md` (stale, dated
> 2026-07-02, still calls the app "Harness"). Adds two competitors not previously
> tracked (Superset, Zed) and re-verifies claims against current code (v4.3.1, build 199).
> Web research done 2026-07-11 — see citations per gap.
>
> **tmux sweep (2026-07-11, Opus planning pass):** tmux parity is already tracked in
> depth at `docs/TMUX_PARITY.md` (scripting, copy-mode, status-line, hooks, format
> strings, session/window/pane lifecycle — all matched or exceeded via daemon
> persistence). No new gap found. The one tmux-ecosystem item (tpm-style plugin
> manager: resurrect/continuum/thumbs) was already tracked in `competitive-position.md`
> under "Extensions/plugins ecosystem" — not new, not added as a G-number here.
> Broader sweep (Warp, iTerm2, Ghostty, Kitty, Rio, Alacritty) surfaced nothing new
> either — Warp Drive (team sharing) and block-based terminal were already tracked.

## Method

For each gap: confirmed via `grep`/`graphify query` against current source, not assumed
from the old doc. Gaps the codebase already covers are marked **matched, not a gap** and
excluded from phases below.

## Already matched (verified in code, not gaps)

| Claimed competitor feature | Kouen equivalent | Evidence |
|---|---|---|
| cmux notification rings (OSC 9/99/777 + CLI hook) | `OSCNotificationParser`, `NotificationBus`, `AgentStatusDot` | `Packages/KouenIPC/Sources/KouenIPC/AgentNotification.swift` |
| Supacode persistent sessions survive app restart (bundled zmx) | Daemon process + scrollback replay from disk (stronger: survives full app quit, not just editor restart) | `RealPty.respawn()`, `Tests/KouenDaemonTests/ScrollbackPersistenceTests.swift` |
| Supacode agent busy/awaiting-input/idle badge | `AgentStatusDot` / `AgentInboxPanelView` | `Apps/Kouen/Sources/KouenApp/UI/Notifications/AgentInboxPanelView.swift` |
| Zed Agent Panel context injection (files/diagnostics/blocks) | `harness-mcp` tools (`kouenErrors`, `kouenGetBlock`, `kouenGrep`, `kouenFind`) — agent pulls context itself via MCP instead of UI @-mention | existing MCP tool list |
| Superset in-app browser + MCP | Browser pane + `harness-mcp` 27 tools | P28 |

## Real gaps (verified absent)

| # | Gap | Who has it | Evidence it's missing | Severity |
|---|-----|-----------|------------------------|----------|
| G1 | **Listening-port detection in sidebar** — cmux shows each pane's dev-server port live in the vertical tab sidebar. Kouen only has passive click-to-open localhost link detection in terminal output (`URLDetection.isLocalDevHost`), nothing proactive/sidebar-level. | cmux | `URLDetection.swift` only does text-pattern matching on rendered output, no port-scan/`lsof`-style sidebar badge | Medium (nice-to-have UX) |
| G2 | **SSH agent forwarding on remote mux domains** — WezTerm's `mux_enable_ssh_agent` propagates `SSH_AUTH_SOCK` to the remote host automatically for `wezterm ssh`. Kouen's `SSHTunnelManager`/Remote host manager (P23) has no agent-forwarding option. | WezTerm | `grep -rn "SSH_AUTH_SOCK\|ForwardAgent"` → zero hits outside this plan doc | Medium (remote-workflow friction, users currently need manual `ssh -A` / agent config outside Kouen) |
| G3 | **Configurable PR merge strategy (squash/rebase/merge) per worktree** — Supacode surfaces PR checks/merge-readiness in the sidebar *and* lets you pick merge strategy. Kouen has PR/CI status inline (P24/P33) but no merge-strategy picker — merging still routes through `Scripts/commit-push-merge.sh` or manual `gh`. | Supacode | `grep -rn "MergeMethod\|squash\|mergeStrategy"` → no real hits (only a docstring using the word "squashed") | Low-Medium |
| G4 | **In-app git hunk staging** (stage/unstage individual hunks without leaving the app) — Superset's diff viewer lets you stage specific hunks inline. Kouen's git panel shows diffs (commit-diff popover, P33) but staging is CLI-only. | Superset | no `hunkStage`/`stagePatch` implementation found, only a `KouenTerminalSurfaceView` false-positive match | Low-Medium |
| G5 | **Explicit multi-agent orchestration dashboard (10+ agents at a glance)** — Superset's headline pitch is running/reviewing 10+ parallel agents with a dedicated review workflow. Kouen supports parallel agents via worktree-per-session (P32 task-based worktrees) + sidebar, but there's no aggregate "N agents running, M need attention" board beyond the notification inbox. | Superset | `AgentInboxPanelView` is a flat notification list, not a fleet-status board | Low (philosophy difference — Kouen's MCP-first design lets an *external* orchestrator agent do this via `kouenList`/`kouenBoard`; may already be "solved" architecturally rather than in-UI) |

## Not gaps — deliberate positioning differences (no action)

- **Zed's built-in chat/Agent Panel UI** — Kouen removed inline AI chat deliberately
  (`c4e1e15`, 2026-06-29). Re-adding contradicts the CLI-agents-in-terminal-panes + MCP
  philosophy already documented in `competitive-position.md`. Not re-litigating here.
- **Superset/cmux Electron vs native** — Kouen's native Swift engine is already a stated
  USP; no action needed.
- **Cross-platform GUI (Win/Linux)** — pre-existing known gap (`competitive-position.md`),
  out of scope for this plan; macOS-only is a strategic choice, not an oversight.

## Phases

### Phase A — Remote workflow parity (G2) — DONE 2026-07-11
- `-A` was already a validated passthrough flag in `SSHTunnelManager.validatedUserSSHArgs`
  (no core change needed) — the gap was purely UI discoverability. Added an "Agent
  forwarding" toggle to `SettingsRemoteView`'s host form (same pattern as Port/Identity/
  Jump: synced from `sshArgs.contains("-A")` on select, appended on save).
- Files: `Apps/Kouen/Sources/KouenApp/Settings/SwiftUI/SettingsRemoteView.swift`.
- Verified: `swift build --product Kouen` clean, `swift test --filter "RemoteHost|SSHTunnel"`
  26/26 green. Not yet verified: real remote host with `git`/`gh` end-to-end (build-green
  only — see MEMORY.md 2026-07-07 lesson, live check still owed before calling this fully done).

**Code-reviewed 2026-07-13** (no remote host configured on this Mac to test live against —
`kouenHostList` returns `[]`): traced the full wiring end to end. `editAgentForwarding` syncs
from `host?.sshArgs.contains("-A")` on load and appends `"-A"` back into `sshArgs` on save
(`SettingsRemoteView.swift:363,409`); `SSHTunnelManager.swift:219` passes `host.sshArgs` through
`validatedUserSSHArgs` into the real `ssh` invocation. Genuinely wired, not just a UI toggle.
Real end-to-end verification (an actual remote host + `git`/`gh`) is still owed — flagging
honestly rather than claiming full coverage from code review alone.

### Phase B — Sidebar dev-server visibility (G1) — DONE 2026-07-11
- Confirmed passive `URLDetection` doesn't cover this: `visibleLinks()` only scans the
  currently-rendered viewport on demand, nothing retained per-surface — a background pane's
  dev server would never surface. Built the proactive daemon-side scan instead.
- `Tab.listeningPorts: [Int]` field already existed in the model (unused scaffolding, no
  writer/reader anywhere) — reused as-is.
- New `ListeningPortScanner` (KouenCore/Agents): one batched `lsof -F pn` per scan tick
  across every surface's process-tree union (reuses `AgentDetector`'s `descendantPIDs`,
  exposed `internal` for this), not one fork per pane.
- `AgentScanner` gained a 5th timer (5s cadence — port state changes slower than agent
  activity, but a dev server should show up within ~1 tick of starting) calling
  `SurfaceRegistry.refreshListeningPorts()`, which mirrors `refreshSurfaceMetadata`'s
  off-lock-probe / re-validate-child-PID-then-commit shape.
- Sidebar: `SidebarSessionItemRow` shows the lowest listening port across all of a
  session's tabs as a badge (reusing `SidebarBadgeLabel`), click posts the same
  `KouenOpenInBrowserPaneURL` notification the passive link-click path already uses.
- Files: `Packages/KouenCore/Sources/KouenCore/Agents/{AgentDetector,ListeningPortScanner}.swift`,
  `Packages/KouenCore/Sources/KouenCore/Session/SessionEditor.swift`,
  `Packages/KouenDaemon/Sources/KouenDaemon/{SurfaceRegistry,AgentScanner}.swift`,
  `Apps/Kouen/Sources/KouenApp/UI/Sidebar/SidebarSessionListView.swift`.
- Verified: `swift build` (app + daemon + CLI) clean, `swift test` 50/50 (3 pre-existing
  live-daemon skips), `Tests/robot/run.sh` 10/10. New `ListeningPortScannerTests.swift`
  covers the `lsof -F pn` parser (IPv4/IPv6, empty input, malformed-line safety). Not yet
  verified: real dev server + real sidebar render (build/unit-green only — live check
  still owed, same caveat as Phase A).

**Partially live-tested 2026-07-13**: started a real `python3 -m http.server 8765` in a
real pane and confirmed via `readPaneOutput` it was genuinely listening — the actual test
condition the scanner needs is real, not simulated. Code-reviewed the rest (native sidebar
render, no MCP field exposes `listeningPorts`): `portScanTimer` confirmed active (5s tick,
`AgentScanner.swift`), off-lock `lsof` scan re-validates instance identity + child-PID
before committing (matches `refreshSurfaceMetadata`'s pattern, already checked by the
2026-07-11 Opus review above), sidebar renders the lowest port across all tabs correctly
(`SidebarSessionListView.swift:282`). Whether the badge actually rendered on screen for
that test server was not independently confirmed by me (no way to screenshot the native
window) — genuinely still owed.

### Phase C — Git workflow depth (G3, G4) — SPLIT 2026-07-11 (Opus planning pass)
Re-scoped after discovering `GitHubCLIClient.swift` has zero merge capability today
(read-only: PR status, checks, ahead/behind, open-URL — no merge method at all) and
`GitPanelView.swift` renders diffs read-only (no staging). Both are bigger than
originally estimated, and at very different risk levels — split by risk, not by file:

- **C1 = G4 (hunk staging) — DONE 2026-07-11.** Discovered whole-*file* stage/unstage
  already existed (`toggleStage`, `git add`/`git restore --staged` per file) — the
  planned MVP fallback was already shipped. Built whole-hunk granularity on top: a new
  "hunks" button per changed-file row opens a popover listing that file's unstaged
  hunks (`git diff -- file`, "Stage" button) and staged hunks (`git diff --cached --
  file`, "Unstage" button), each applying `git apply --cached [-R]` against a
  temp-file patch built from the shared file header + that one hunk. No interactive
  partial-line splitting (cut, per plan).
  - New: `GitPanelView.parseDiffHunks`/`patchText` (pure, tested), `applyHunkPatch`,
    `showHunkStaging`/`presentHunkStagingPopover`/`makeHunkCard`, `HunkActionButton`.
  - File: `Apps/Kouen/Sources/KouenApp/UI/Git/GitPanelView.swift`.
  - Verified: `swift build` (app+daemon+CLI) clean, targeted test filters green
    (`GitPanelViewHunkStagingTests` 3/3 new + `GitPanelViewDiffPopoverTests`/
    `GitPanelViewToastErrorSummaryTests` unaffected), `Tests/robot/run.sh` 10/10.
    Full unfiltered `swift test` has two pre-existing unrelated failures (not caused
    by this change — neither touches git/diff code): a `UNUserNotificationCenter`
    bundle-proxy crash in `GitPanelViewDiffErrorTests` under full-suite run only
    (documented pre-existing macOS 26 notification-DB issue, see
    `agent-memory/knowledge/bugs/notification-sound-and-click-routing.md`; passes
    standalone), and an unrelated `ExperienceModeTests` assertion failure. Not yet
    verified: staging a real hunk against a real repo end-to-end (build/unit-green
    only — live check still owed, same caveat as Phases A/B).

  **Code-reviewed 2026-07-13** (native GUI-only, no MCP surface to drive it myself):
  `parseDiffHunks` splits header/hunks correctly including the trailing-newline edge
  case, `patchText` reconstructs a valid standalone single-hunk patch, `applyHunkPatch`
  writes to a temp file (avoids `Process` arg-escaping issues) and cleans up via
  `defer`, `showHunkStaging`'s async diff fetch guards `sender.window != nil` after
  the `await` (RL-063 pattern applied correctly). Logic is sound; real hunk-staging-
  against-a-real-repo still not exercised live.
- **C2 = G3 (PR merge) — DONE 2026-07-11.** User sign-off received ("C until the end
  of all phase") before implementing — this is a new capability (the app gaining the
  ability to execute `gh pr merge` against the user's real GitHub repo), materially
  different risk than anything else in this plan.
  - `GitHubCLIClient.merge(repoPath:prNumber:method:)` — `MergeMethod` enum
    (`.squash`/`.rebase`/`.merge`), every caller must pass one explicitly, no default.
    `PRInfo` gained `baseRefName` + `mergeable` (`true` only for GitHub's exact
    `"MERGEABLE"` string — `"CONFLICTING"`/`"UNKNOWN"`/missing all parse to `false`,
    tested).
  - Sidebar row context menu: "Merge PR #N…", disabled unless
    `prChecksStatus == .pass && prMergeable == true`. Click opens an `NSAlert` with
    PR number/title/target branch + a method `NSPopUpButton` defaulted to a
    "Choose merge method…" placeholder — hitting Merge while the placeholder is
    still selected is treated as cancel, not "pick one for me". Result (success or
    `gh`'s stderr on failure) shown in a follow-up alert.
  - No app-side force-merge path — `gh pr merge`'s own branch-protection refusal is
    the only backstop, as designed.
  - Files: `Packages/KouenCore/Sources/KouenCore/GitHub/GitHubCLIClient.swift`,
    `Apps/Kouen/Sources/KouenApp/UI/Sidebar/{SidebarListModel,SidebarSessionListView}.swift`.
  - Verified: `swift build` (app+daemon+CLI) clean, new `GitHubCLIClientTests` 5/5
    (mergeable-parse cases — the load-bearing gate logic), `Tests/robot/run.sh`
    10/10. Not yet verified: an actual merge against a real PR (build/unit-green
    only — live check still owed, same caveat as every other phase; this one
    especially warrants a real end-to-end try before relying on it).

  **Code-reviewed 2026-07-13, deliberately not live-tested.** No default merge method
  (every caller must pass one explicitly, no silent auto-pick), `--delete-branch=false`,
  zero app-side force path, `mergeable` strictly parses the literal `"MERGEABLE"` string
  (anything else defaults safely to `false`). Sound and conservative. A real merge was
  **not** executed to "verify" this — it's a destructive, hard-to-reverse GitHub action
  with no open PR to test against safely; code review is the appropriate bar here, not
  execution.

**All five phases (A, B, C1, C2, D) done as of 2026-07-11.** Every phase still owes
its "live check against a real daemon/repo" gate (see Verification gates below) —
build/test-green was achieved throughout, but no phase has been exercised against
real hardware yet (real SSH host, real dev server, real hunk, real PR, real
multi-agent session).

**2026-07-13 verification pass.** All five gaps are native GUI-only (no MCP tool surfaces
any of them directly), so a genuine runtime live-check wasn't reachable through the tools
available this session — code-reviewed all five instead (see each phase's own
"Code-reviewed 2026-07-13" note above), plus started a real listening dev server for G1/B
to at least make the underlying test condition real rather than hypothetical. No new bugs
found; the 2026-07-11 Opus review had already caught and fixed what needed fixing. Real
on-screen confirmation (does the sidebar badge actually render, does a real merge/hunk/SSH
session actually work end-to-end) is still genuinely owed — this pass raises confidence,
it doesn't close the live-check gate.

## Post-implementation review (Opus, 2026-07-11)

User asked for a second-pass review checked specifically against this repo's own
`agent-memory/knowledge/` lesson history (rl-lessons.md, cases/appkit-ui.md,
cases/swift6-concurrency.md, cases/remote-ssh.md) before treating the work as done.

- **CASE-040/RL-043** (button click not firing / gesture-recognizer conflict) —
  checked against the new `hunksButton` (C1): **refuted**. `StageToggleButton`
  (same file, same `momentaryChange`+no-bezel pattern, no `mouseUp` override) has
  shipped in the core staging workflow through the entire post-macOS-26 period with
  zero not-firing reports — CASE-040's actual root cause was `SoftIconButton`'s
  child `NSImageView` stealing hitTest, which `hunksButton` doesn't have. Row's
  `NSClickGestureRecognizer` delegate already excludes all `NSButton` hits.
- **RL-052** (`Task {}` on a `@MainActor` NSView blocking main thread on
  `DaemonClient.request()`, which is synchronous despite its callers being
  `async`) — **confirmed, pre-existing pattern** (`runAndRefresh`/Sync button had
  the same issue already). **Fixed at the root**: `runGitWithStatus` itself now
  wraps its body in `Task.detached(priority: .utility)`, so every caller (Sync
  button, worktree remove, the new hunk-apply) gets it fixed in one place, not
  patched per-caller.
- **RL-063** (view captured across an `await` without a liveness guard) — checked
  `showHunkStaging`/`presentHunkStagingPopover`/`makeHunkCard`: compliant,
  `sender.window != nil` guarded after every await.
- **Daemon timer re-validation** (Phase B) — checked `refreshListeningPorts`
  against `refreshSurfaceMetadata`'s exact pattern: correct, re-validates both
  instance identity and child-PID-hasn't-respawned before committing.
- **PR merge blast radius** (C2) — checked: safe, no accidental-method path, no
  app-side force-merge, `Task.detached` already used correctly (this was the
  reference the `runGitWithStatus` fix above was brought in line with).
- **Real gap found and closed**: `GitPanelViewHunkStagingTests` only covered
  `parseDiffHunks` parsing, never exercised the reconstructed patch through a real
  `git apply --cached`. Added `testStagingOneHunkLeavesTheOtherUnstaged` — real
  temp repo, two-hunk file, stages one hunk via the actual patch-file path, asserts
  the index/worktree split, then reverses via `apply --cached -R` and confirms a
  clean index. This is the test that would have caught a subtly wrong patch header
  or hunk-boundary bug; the pure-parsing tests couldn't.
- **SSH toggle "gap" — investigated 2026-07-11, closed as no-op, not a real bug.**
  The reviewer's flagged scenario ("`-oForwardAgent=yes` shows the toggle off while
  forwarding is actually on") cannot occur: `SSHTunnelManager.validatedUserSSHArgs`
  (`Packages/KouenCore/Sources/KouenCore/Remote/SSHTunnelManager.swift:225`) only
  allows `-4/-6/-A/-a/-T/-q/-v/-vv/-vvv` (no-value) and `-p/-i/-J/-l` (value) — `-o`
  is not in either allowlist. Any host with `-oForwardAgent=yes` in `sshArgs` would
  already fail to connect (`SSHTunnelError.invalidConfiguration`) before agent
  forwarding could ever matter — so a host can never be "actually forwarding via
  `-o`" while the toggle reads off; toggle-off is the accurate read for that state.
  The only way such a flag reaches storage at all is a manual JSON edit or CLI
  bypassing Settings' own form (which only ever writes `-A`) — a save-time
  validation gap (`RemoteHostStore` doesn't validate `sshArgs`, only
  `SSHTunnelManager` does, at connect time), not a toggle-detection gap. User
  confirmed: close as no-op, no code change.

No ship-blockers found. `runGitWithStatus`'s `Task.detached` fix + the new
integration test are the only code changes from this review pass — re-verified:
`swift build` clean, `GitPanelViewHunkStagingTests` 4/4 (including the new
integration test), `Tests/robot/run.sh` 10/10.

### Phase D — Fleet visibility (G5) — DONE 2026-07-11
Built the lightweight aggregation Opus recommended, reusing existing state (no new
data plumbing, as scoped):
- Footer "Agents" (sparkles) button gets a small red count badge when any agent is
  `.waiting` — computed inline from `SessionCoordinator.shared.agentsList()`,
  piggybacking on `SidebarFooterModel`'s existing `chromeEpoch`-driven re-render.
- Agent Inbox popover header now reads "Agents · N running · M need you" instead of
  just "Agents".
- Files: `Apps/Kouen/Sources/KouenApp/UI/Sidebar/SidebarWorkspaceViews.swift`,
  `Apps/Kouen/Sources/KouenApp/UI/Notifications/AgentInboxPanelView.swift`.
- Verified: `swift build` (app+daemon+CLI) clean, `Tests/robot/run.sh` 10/10. No new
  unit test — trivial view composition + a one-line `.filter(\.waiting).count` over
  already-tested data, no new logic to regress. Not yet verified: real multi-agent
  session with the badge visibly updating (live check still owed, same caveat as
  every other phase in this doc).

**Code-reviewed 2026-07-13** (native sidebar UI, no MCP surface — `kouenBoard`/`kouenList`
are separate pre-existing tools, not this feature; do not conflate a `kouenBoard` check with
verifying this badge). `.filter(\.waiting).count` over `SessionCoordinator.shared.agentsList()`
reads correctly as a simple derived count, no new state to get out of sync. Real visual
confirmation (does the red count badge actually render/update on the real sidebar) still
not done.

### Phase D — Fleet visibility (G5) — RE-SCOPED 2026-07-11 (Opus planning pass)
Not closing as "solved via MCP" — `kouenBoard`/`kouenList` solve the *agent-
orchestrator* case, not the *human-at-a-glance* case a human watching 10 running
agents actually has (Superset's headline feature is explicitly human-facing). The
sidebar's per-row status dots + `AgentInboxPanelView`'s flat notification list
partially cover this but don't aggregate.
- Build a **lightweight** native aggregation, not a big Superset-style dashboard:
  running-agent count + a "needs-attention" list (agents awaiting input), reusing
  existing `AgentStatusDot`/`AgentInboxPanelView` state — no new data plumbing.
- Stays lowest priority of the four remaining gaps; small enough to fold into a
  slow afternoon, not urgent.

## Verification gates (every phase)
- `swift build` + `swift test` green, `Tests/robot/run.sh` 10/10
- Live check against a real daemon, not just build-green (see MEMORY.md 2026-07-07 lesson)

## Sources (2026-07-11 research)
- cmux: https://github.com/manaflow-ai/cmux
- Supacode: https://supacode.sh/ , https://github.com/supabitapp/supacode
- Superset: https://superset.sh/ , https://github.com/superset-sh/superset
- WezTerm: https://wezterm.org/config/lua/config/mux_enable_ssh_agent.html
- Zed: https://zed.dev/docs/ai/agent-panel , https://andrew.ooo/answers/what-is-zed-terminal-threads-may-2026/
