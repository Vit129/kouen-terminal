# Context — harness-terminal

## Now
- **Task:** idle — last work (Git panel FSEvent filter fix) applied, built+tested, **not yet committed**
- **Branch:** `main`

### 2026-07-02 — Git sidebar panel didn't refresh after external `git commit`/`push` ✅ FIXED, not committed
User report: after `git commit`+`push` from a terminal pane, the sidebar Git tab kept showing stale
status. (Two other hypotheses investigated first and disproven via source-level tracing per
debug-mantra: split-pane shared `Tab.cwd` overwrite — ruled out, user had no split panes; Cmd+T
new-tab creation/registration/probe/propagation chain — traced end-to-end, architecturally sound,
landed on a shell-rc-race explanation for that specific symptom instead, unconfirmed.)

**Root cause:** `f6ffb0a` ("eliminate CPU spikes from FSEvent storm during agent writes") added a
blanket filter in `GitPanelView.swift`'s FSEvent callback — any event path containing `/.git/` was
ignored, to stop the panel's own auto-stage (`refresh()`'s `git add` at the time) from
self-triggering a refresh loop. But a plain `git commit`/`push` from a terminal *only* touches paths
under `.git/` (`index`, `COMMIT_EDITMSG`, `logs/HEAD`, `refs/heads/*`, `refs/remotes/*`) — no
working-tree files change — so the blanket filter also silently swallowed the exact events a
refresh should react to. `suppressingFSEvents` already guarded the panel's own `git add` write
separately; the blanket `.git/` filter was redundant *and* too broad.

**Fix:** narrowed the filter to `nonisolated static func isNoisyGitInternalPath(_:)` — only
`.git/index`, `.git/index.lock`, `.git/objects/**` are treated as noise; everything else under
`.git/` (HEAD/refs/logs/COMMIT_EDITMSG/FETCH_HEAD) now correctly triggers a refresh. Regression
test: `Tests/HarnessAppTests/GitPanelViewFSEventFilterTests.swift` (3 assertions). Build + targeted
test green; not yet run through `Tests/robot/run.sh` or committed.
**Lesson:** a blanket "ignore all noise from path X" filter meant to fix a self-triggering loop can
silently kill legitimate external events that live under the same path prefix — narrow the filter to
the specific noisy sub-paths, not the whole prefix.

### 2026-07-02 — agy logo color mismatch (preview vs prod) ✅ RESOLVED — not a Harness bug
Long investigation (many rounds, see below) into why `antigravity`/`agy`'s CLI logo rendered with
different colors in `.harness-preview` vs production. Ruled out, in order (all equal between
builds): `TERM`/`COLORTERM`/`TERM_PROGRAM`/`terminal-identity` spoofing, `terminalShaderEffect`,
`colorGamut`/`CAMetalLayer.colorspace`, sampler filtering, SGR truecolor parser
(`38;2;r;g;b;48;2;r;g;b` combined-attribute parsing), half-block bg/fg compositing. `script -q`
raw-byte capture confirmed both builds receive byte-identical `38;2` truecolor SGR from the CLI —
so it was never a rendering/parsing bug.

**Actual root cause:** `make preview`'s isolated state dir (`/tmp/harness-preview-<hash>/settings.json`,
fresh per run — by design, to avoid polluting daily-use state) doesn't inherit the user's real
`~/Library/Application Support/Harness/settings.json`. Two settings there directly recolor terminal
output: `minimumContrast` (prod: `1`=off; preview default: `3.5`, WCAG-brightens/shifts foreground)
and `paletteHex` (prod: custom 16-color; preview default: `null` → falls back to built-in theme
palette). Confirmed fixed by copying production `settings.json` into the preview state dir.

**Process note:** the winning diagnostic was empirical (raw-byte diff via `script -q`), not static
code reading — static analysis of the renderer/parser (which was exhaustive and correct) couldn't
have found this since the bug was never in code. See `knowledge/cases/misc.md` CASE-060.

### 2026-07-02 — Near-miss: `git revert --abort` wiped uncommitted session work
Found an unexpected in-progress `git revert eb0c89b` (REVERT_HEAD set, conflicts pre-resolved and
staged) while preparing to commit — not something this session started. User confirmed intent was
to keep the current (later) state, not actually revert. `git revert --abort` was the wrong recovery
step here: it does `git reset --merge` back to the pre-revert HEAD, which discarded **all**
working-tree edits to every file that had been part of the revert's index — not just the revert's
own changes — including hand-written fixes made *after* the revert began. Files reset: `CONTEXT.md`,
`HarnessSidebarPanelViewController.swift`, `SidebarSessionListView.swift`, `TerminalTabBarView.swift`.
Recovered by reconstructing each diff from conversation history (`CONTEXT.md`/`MEMORY.md` had scratch
backups; the 3 Swift files were retyped from diffs already read earlier in the session) — full
recovery confirmed via `git diff` matching pre-abort content exactly, build+test green.
**Lesson:** `git revert --abort` / `git merge --abort` mid-operation is NOT safe to run casually
when working-tree files were edited after the operation started — it discards those edits too, not
just the operation's own changes. Back up (or `git stash`) any files touched since the operation
began before aborting. See RL-060 in `knowledge/rl-lessons.md`.

### 2026-07-02 — Sidebar status classification/color unification + Board tab flip bug ✅ FIXED, committed & pushed (`49a67ba`)

Chain of fixes across one session, each surfaced by the user spotting a visual mismatch:

1. **Classification duplication regression** — staged (uncommitted) edits to `SidebarListModel.swift`
   had grown a local `columnKind(for:)` copy that dropped the `agent.activity == .working` check
   `BoardModel.columnKind` (the single classifier `eb0c89b` introduced) relies on. Restored: doc
   comment + `.working` check back in `BoardModel.swift`; `SidebarListModel` now calls
   `BoardModel.columnKind(for:)` directly, no local copy.
2. **Sidebar row visual regression** — same staged diff had also dropped the real agent icon
   (`AgentIconRenderer.templateOrMonogramImage`) from `SidebarSessionItemRow`, replacing it with a
   static branch glyph + ad-hoc dot color. Restored icon to match `TabPillView`'s pattern; dot
   color bugs fixed twice — first wrong-mapped (`.running`→green instead of blue), fixed to use
   canonical `BoardColumnKind.color`; then per user's actual ask, replaced the dot entirely with a
   colored status **text** label (`sessionBoardStatus.displayName` at `sessionBoardStatus.color`)
   for all non-idle states, mirroring the existing "Needs Attention" text pattern.
3. **Board tab visual bug (CASE-059 / RL-059)** — switching Sessions→Board showed the first column
   header ("Needs Attention (0)") squashed to a sliver, later reduced to "shifted down slightly"
   after several timing nudges (`reload(force:)`, `layoutSubtreeIfNeeded()`, `displayIfNeeded()`,
   `scrollToTop()` in that order). None of these were the real fix — root cause was
   `BoardViewController`'s scroll `documentView` being a plain non-flipped `NSView()`, so content
   anchors bottom-left and `scroll(to: .zero)` scrolled to the bottom, not the top. Fixed with a
   flipped `documentView` subclass (same pattern as `GitPanelView.swift`'s existing `FlippedView`).
   **Lesson:** when several small timing nudges only partially converge on a layout bug, stop
   nudging and check `isFlipped` before adding a 6th nudge.

## Previous sessions (abbreviated)

Full detail for anything below → `COMPLETED-TASKS-ARCHIVE.md` (rows 56–63 = 2026-06-29 to 07-01).

| Date | Task | Key outcome |
|------|------|-------------|
| 2026-06-27 | otty-features P1–P20 | All phases shipped; P13/P21 deferred |
| 2026-06-26 | Memory-leak audit | existingHosts pin, BrowserPaneView cap, AI controller retire → v3.9.4 |
| 2026-06-26 | cwd bleed | deepestReadableDescendant removed; shell pid direct |
| 2026-06-25 | harness view | OSC 7735 → sidebar file viewer |
| 2026-06-23 | Sidebar SwiftUI | NSTableView removed; VC 1676 → 890 lines |

## Unresolved
- 2 pre-existing `swift test` failures unrelated to any recent work: `ExperienceModeTests.testShowsHarnessControlsDerivesFromMode`,
  `Phase6KeysTests.testRootTableSeededAndBindable`. Not investigated — check if still failing before next test-suite work.
