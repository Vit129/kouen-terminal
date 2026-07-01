# Context — harness-terminal

## Now
- **Task:** Sidebar width/visibility polish pass done, user-confirmed live in preview — committed
- **Branch:** `main`
- **Committed (4 commits ahead of origin/main)**: d9c1ad1, 36cf813, 80b82db (+ prior 5641273) — not pushed, awaiting explicit go-ahead

### 2026-07-01 — Sidebar default width/visibility + resize-proportional-growth bug ✅ FIXED (user-confirmed)
User: sidebar too big → reduce default width `HarnessDesign.sidebarWidth` 264→220
(`Apps/Harness/Sources/HarnessApp/UI/Shared/HarnessDesign.swift:18`). Then asked for
always-open-on-launch + divider styling to match the pane-split divider from `b83773e`.

- **`sidebarVisible` default → `true`** (`Packages/HarnessSettings/Sources/HarnessSettings/HarnessSettings.swift:324`,
  init param default `false`→`true`). Test `testSidebarVisibleDefaultsToFalse` renamed/flipped to
  `testSidebarVisibleDefaultsToTrue` in `Tests/HarnessCoreTests/HarnessSettingsTests.swift`. Also had to
  hand-patch already-persisted `~/Library/Application Support/HarnessDebug/settings.json` (`sidebarVisible: true`)
  since the debug build variant's existing settings.json predates this default and isn't a fresh install.
- **Divider color** (`MainSplitViewController.swift` `resolvedDividerColor()`): now returns
  `HarnessChrome.current.paneDivider` (same token `ContentAreaViewController.swift`/`HarnessSplitView`
  use for terminal pane splits, cmd+d/cmd+shift+d) instead of the fainter `.border`/hardcoded-hex scheme —
  visually unifies the sidebar/content boundary with pane dividers.
- **Real bug (root cause of "ยังใหญ่เกือบครึ่งจอ" after width was already 220pt in code):**
  `NSSplitView` redistributes divider position **proportionally** on window resize
  (`resizeSubviews(withOldSize:)`), not just on user drag. `HarnessDesign.sidebarWidth` only sets
  the *initial* position via `setPosition(_:ofDividerAt:)` at first layout — any subsequent window
  resize/restore-to-larger-frame balloons the sidebar proportionally (confirmed via temp `NSLog`:
  480pt window → sidebar 220 correct; window then resized to 1440pt → sidebar ballooned to 661,
  exact same 45.9% ratio). `constrainMinCoordinate`/`constrainMaxCoordinate` (200–320pt cap) only
  governs **user drags**, not automatic/programmatic resize — doesn't help here.
  - **First attempt failed:** `split.setHoldingPriority(.defaultHigh/.defaultLow, forSubviewAt:)`
    had **zero effect** — holding priority only governs pure-Auto-Layout-arranged NSSplitViews;
    with a classic `constrainMinCoordinate`/`constrainMaxCoordinate` delegate present
    (`SplitChromeDelegate`), NSSplitView still uses proportional redistribution regardless.
  - **Actual fix:** implemented `NSSplitViewDelegate.splitView(_:shouldAdjustSizeOfSubview:)` on
    `SplitChromeDelegate`, returning `false` for the sidebar subview (index depends on
    `settings.sidebarOnRight`) — explicitly opts the sidebar out of auto-resize so only the
    terminal/content side absorbs window growth/shrink. Confirmed via the same `NSLog` probe:
    1440pt window → sidebar stays 220, content absorbs to 1219. User confirmed fixed live in preview.
  - Temp `NSLog` debug probe added then removed once confirmed (not committed).

See `knowledge/cases/misc.md` — worth promoting as a case: "NSSplitView holdingPriority does nothing
when a classic constrain-coordinate delegate is present; use shouldAdjustSizeOfSubview instead."

### 2026-07-01 — P32 Phase 2: worktree tabs invisible to git UI ✅ FIXED (pending live confirm)
User tested opening a tab inside a `.claude/worktrees/*` dir (created by a Claude Code agent,
real uncommitted changes on disk) and reported "git changes ไม่ขึ้น" (changes not showing).

Root-caused to `HarnessSidebarPanelViewController.gitRoot(for:)` (private helper, designed for
**file** paths — used correctly at `openExternalFile`) being reused on **directory** (`cwd`)
inputs at 3 call sites (`selectSidebarTab`, `reload()`, `refreshMetadata()`). It always starts
its `.git`-existence walk from the input's *parent*, so for any worktree cwd (`.harness-worktrees/*`
or `.claude/worktrees/*`, both nested inside the main repo tree) it walks straight past the
worktree's own `.git` file and resolves to the **main repo** root instead — File Tree pane then
shows the main repo's (clean) status, not the worktree's real changes. The Git "Changes" panel
itself was already correct (passes raw `cwd` directly, no walk).

**Fix:** swapped `Self.gitRoot(for: cwd) ?? cwd` → `WorktreeManager().repoRoot(for: cwd) ?? cwd`
(reuses existing, already-tested `git rev-parse --show-toplevel` wrapper — same primitive
`WorktreeAutoIsolateService` already relies on) at the 3 directory-input call sites only; left
`openExternalFile`'s file-path use of `gitRoot(for:)` untouched. Verified `git rev-parse
--show-toplevel` from inside a real `.claude/worktrees/agent-*` dir correctly returns the
worktree path, not the main repo. Build clean.

Follow-up: after that fix, user reported the Git panel's Changes tab still took a moment to
populate ("ต้องรอ") rather than showing instantly. Root cause: `GitPanelView.refresh()` painted
the UI only at the very end of the function — if the worktree had unstaged files, it ran a
sequential `git add` + 2 more `git` re-fetches (auto-stage step) *before* the first paint,
adding a full extra round trip of latency before anything appeared. **Fix:** extracted the
paint logic into `applyState(...)`, called once immediately after the first parallel git-status
fetch (so Changes shows up right away), then the auto-stage add + repaint runs as a background
follow-up only if it changes anything. Build clean, preview relaunched — awaiting user's
re-test to confirm instant paint.

### 2026-07-01 — P32 Phase 1 live verification + 2 bugs fixed
Live-tested "New Agent Task" in the preview build (not production `/Applications/Harness.app` —
that's a stale install and won't reflect uncommitted work; always verify against
`.harness-preview/HarnessPreview.app`). Found and fixed:
- **Palette not appearing / clipped**: `CommandPaletteController.present()` was missing
  `panel.setContentSize(NSSize(width: 620, height: 440))` (present in the working
  `DirectoryPickerController` reference pattern) — without it the origin-centering math read a
  stale `panel.frame`. Fixed by adding the call right after `contentViewController` assignment.
- **Silent failure on "New Agent Task"**: `SessionLifecycleService.addAgentTask` had 3 silent
  `guard ... else { return }` paths (repo-root resolution, empty sanitized name, worktree create
  failure) — nothing was ever shown to the user. Root cause of "nothing happens": active tab's
  cwd was `~` (not a git repo) so `repoRoot(for:)` returned nil. Fixed by changing the method to
  return `String?` (error message) instead of silently swallowing, and showing an `NSAlert` in
  `CommandPaletteController`'s handler when non-nil. `SessionCoordinator.addAgentTask` updated to
  propagate the return value.
- **`.harness-worktrees/` was not gitignored** — task worktrees were getting staged as regular
  files. Added to `.gitignore`.
- Verified happy path: New Agent Task from a tab cd'd into the repo → new tab "testing", branch
  `testing`, worktree at `.harness-worktrees/testing`, correct cwd. Test worktree/branch removed
  after verification via `git worktree remove --force` + `git branch -D`.

### 2026-07-01 — P32 interview-doc pass (before implementation)
Cross-checked `agent-memory/plans/p32-task-based-worktrees.md` against code — 2 corrections:
- **F1/Phase 1:** integrate via existing `SessionLifecycleService.addSession(to:cwd:name:)`
  (`Apps/Harness/Sources/HarnessApp/Services/SessionLifecycleService.swift:25`), NOT a new
  pipeline — it already resolves `ProjectConfig` + auto-runs `setupScript` (P24). New task flow
  = `WorktreeManager.create()` → `addSession(cwd: wtPath, name: taskName)`.
- **F3:** `ProjectConfig.setupScript`/`archiveScript` already exist
  (`Packages/HarnessSettings/Sources/HarnessSettings/ProjectConfig.swift:7,11`) — no new config
  fields needed. `setupScript` already wired (P24); `archiveScript` exists in schema but has
  **zero call sites** — Phase 3 = wire up this dead field on task close, not invent new ones.
- `Tab.taskName` (F2) confirmed as genuinely new — `Tab.swift` has `worktreePath`/`parentRepoPath`
  but no task-name field.
- No `docs/adr/` in this repo — decisions live in the plan file itself + this CONTEXT.md, per
  existing project convention.

### 2026-07-01 — P23 socket auto-detect (PBI-SSH-008) ✅ FIXED — P23 now Complete

Added `harness-cli socket-path` (prints `HarnessPaths.socketURL.path`) as the single source of
truth; `SSHTunnelManager.detectSocketPath(sshTarget:sshArgs:)` runs it over `ssh` reusing the
tunnel's existing arg-validation seams (`validatedSSHTarget`/`validatedUserSSHArgs`,
`isSafeArgumentToken`) — no new injection surface. Consumed by both surfaces: `SettingsRemoteView`'s
new "Detect" button (async off main thread via `RemoteHostsService.detectSocketPath`) and
`harness-cli remote add --detect` (alternative to passing `--socket` by hand). 3 new unit tests in
`SSHTunnelManagerTests.swift` using the existing injectable-process-seam pattern.

`swift build --product Harness` and `--product harness-cli` both clean. `swift test` could **not**
be run to completion — see Unresolved below (pre-existing, unrelated breakage). P23 moved to
`completed-archive.md`; plan file deleted.

### 2026-06-30 — Cmd+\ sidebar toggle gone after collapse ✅ FIXED

**Root cause:** B triggers A — zero-delta early exit in `applySidebarVisibility` returned without replacing `sidebarDisplayLink`, leaving the old collapse link running. Dead token guard (A) allowed it to continue despite `sidebarAnimToken` increment. Old link completed with `_sidebarVisible=false` → `panel.isHidden=true` → sidebar gone.

**Fix (MainSplitViewController.swift):** Move `sidebarDisplayLink?.invalidate(); sidebarDisplayLink = nil` to BEFORE reading `panel.frame.width` — kills in-flight animation before any early-exit path, making all return paths safe. Removed `[DBG-sb]` instrumentation.

See `knowledge/bugs/sidebar-cmdbackslash-toggle.md`.

### 2026-06-29 — Live perf profile of running Harness 3.11.7/183 ✅ (diagnosis only)

Profiled the actually-running app (PID via `ps aux | grep MACOS/Harness`; build mtime
newer than all fix commits → fixes ARE live).
- **Memory: CLEAN** — RSS ~110 MB, delta 0 MB over 3 s. No leak. The 34 GB / 21 GB leak
  fixes are confirmed working in build 183.
- **CPU: ~42%** — `sample` shows main thread ~33% in `NSHostingView.layout()` →
  `ViewGraph.updateOutputs(at:)`, i.e. a SwiftUI hosting view re-rendering its **whole**
  ViewGraph every display frame.
- **Root cause:** SwiftUI `.repeatForever` animation near a hosting-view root. Primary
  suspect `TerminalTabBarView.swift` `workingDot` (`.easeInOut.repeatForever`) — pulses
  while any tab is `working` (an agent was working during the profile). Same class as the
  Notch CPU bug.
- **FIXED (`dd7a78c`, pushed):** both `workingDot` and notch `NotchStatusDot` pulses moved off
  SwiftUI `.repeatForever` to `CABasicAnimation`/`CAAnimationGroup` on a CALayer (render server
  paints; ViewGraph no longer re-renders per frame). Build + robot guards green. Live CPU
  re-profile pending `make install` (running instance hosts this session). See
  `knowledge/bugs/notch-cpu-animation.md` Instance 2.

### 2026-06-29 — Claude Code statusLine/advisor/remote-control "broke after migrate" ✅

**User report:** statusLine, advisor, remote-control all stopped after the SwiftUI
settings migration → blamed the migration. **It was NOT the migration.**

**Root cause:** `~/.claude/settings.json` had `skillOverrides.deep-research: "disabled"`
(invalid; valid = `on|name-only|user-invocable-only|off`). **Claude Code 2.1.195**
(updated Jun 28) tightened validation and now **skips the ENTIRE settings.json** on any
single invalid value → `statusLine`, `advisorModel`, `remoteControlAtStartup`, `tui`,
`model` all ignored. Timing coincided with the Harness migration → looked migration-caused.

**Fix:** `"disabled"` → `"off"`. Verified: statusLine invocation 0 → 36 calls.

**Diagnostic that cracked it:** `script -q /dev/null claude` (real PTY) surfaced the
`SettingsError` startup dialog — invisible in background/`-p` sessions. See
`knowledge/cases/misc.md` CASE-057.

**Secondary (separate) issues:** remote-control needs re-auth (`daemon-auth-status.json`
= `auth_required`, cooldown expired → `claude --remote-control`); advisor on/off is a
per-session toggle by design (no persist field — only `advisorModel` persists).

---

## Previous
- **Task:** CPU peaks + memory guards session ✅ (`5cbbe82`, `ffb059a`, `81fe735` on main)
  - Phase-1/Phase-2 double snapshot fanout → payload-type guard in 5 UI observers + SnapshotCoalescer
- **Task:** tab-switch black screen ✅
- **Commits:** `f6a0182`, `2b9295d`, `1a2ca4c`, `9c5c1fa`, `0a5f2fe` on main (squash-merged from fix branch)
- **4 failure modes fixed:** detach-then-cache, structural rebuild caches empty shell, host theft, orphan overwrite

### Previous sessions (abbreviated)

| Date | Task | Key outcome |
|------|------|-------------|
| 2026-06-27 | otty-features P1–P20 | All phases shipped; P13/P21 deferred |
| 2026-06-26 | Memory-leak audit | existingHosts pin, BrowserPaneView cap, AI controller retire → v3.9.4 |
| 2026-06-26 | cwd bleed | deepestReadableDescendant removed; shell pid direct |
| 2026-06-25 | harness view | OSC 7735 → sidebar file viewer |
| 2026-06-23 | Sidebar SwiftUI | NSTableView removed; VC 1676 → 890 lines |

## Unresolved
- 2 pre-existing `swift test` failures unrelated to any recent work: `ExperienceModeTests.testShowsHarnessControlsDerivesFromMode`,
  `Phase6KeysTests.testRootTableSeededAndBindable`. Not investigated this session.

### 2026-07-01 — ACP-removal cleanup (items 1 & 2 from P23 wrap-up) ✅ FIXED
- **`swift test` couldn't build** — `Tests/HarnessCoreTests/ACPTransportTests.swift` and
  `Tests/HarnessMCPTests/StdioTransportTests.swift` referenced `ACPMessage`/`ACPTransport`/`TransportBuffer`
  removed by `c4e1e15` ("remove: ACP + ⌘I — erase as if never built"). Root cause for both this and the
  robot failure below.
  - `ACPTransportTests.swift` deleted — `ACPTransport`/`TransportBuffer` have no live equivalent (pure
    ACP transport-layer types, intentionally erased with no replacement).
  - `StdioTransportTests.swift` repaired, not deleted — it tests `MCPStdioBuffer`
    (`Tools/harness-mcp/Sources/HarnessMCP/StdioTransport.swift`), which is still live and already uses
    `JSONRPCMessage`. Swapped `ACPMessage` → `JSONRPCMessage`, replaced `ACPTransport.encode` with a local
    `contentLengthFrame` helper matching the same `Content-Length: N\r\n\r\n<body>` framing `StdioTransport.send` uses.
  - `swift test` now builds and runs 1673 tests (only the 2 unrelated failures above).
- Robot "Leak A - Retiring A Host Drops Its AI Controllers" stale assertion removed from
  `Tests/robot/memory_leak_guards.robot` — it checked for `aiChatControllers.removeValue`, a dict that
  `c4e1e15` deliberately deleted along with the ⌘I feature (only `inlineAIControllers` remains). All 10
  robot tests pass.
