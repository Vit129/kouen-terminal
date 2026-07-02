# Context — harness-terminal

## Now
- **Task:** P34 done (F1 `2ca7fbb`, F2/F3 `8049605`) — archived to completed-archive.md; idle
- **Branch:** `main`

### 2026-07-02 — P34 F2 (block actions) + F3 (MCP block access) ✅ DONE, committed (`8049605`)
Continuation of F1 slice 1 (`2ca7fbb`) — user said "phase 2,3" to proceed.

**F2:** Promoted `TerminalBlock` back to `public` (needed cross-module now) and replaced the F1
`commandText(atPromptLine:)` accessor with a fuller `block(atPromptLine:) -> TerminalBlock?`
(command, output line range, exit code) plus `lastBlock`/`block(id:)` and a ranged
`captureLines(fromLine:toLine:)` on `TerminalEmulator`/`HarnessGridTerminal`/
`HarnessTerminalSurfaceView`. `BlockActionBar` (`BlockTintOverlay.swift`) grew two buttons —
Copy Output Only, Copy Command Only — shown only when the pane's shell actually emitted a block
(`hasBlock` check in `showActionBar`); bash panes still get the original 2-button Copy/Re-run
bar instead of two buttons with nothing precise to act on. Re-run's fallback regex-strip is
unchanged for that same bash case.

**F3:** Found via code read (not the plan doc's assumption) that OSC-133 parsing only happens
client-side (GUI's `HarnessTerminalSurfaceView` / `harness attach`'s `HarnessGridTerminal`) — the
daemon itself is a dumb byte-relay + raw scrollback store, confirmed by `RealPty.captureGrid`
already replaying retained scrollback bytes through a **fresh** `HarnessGridTerminal` on every
call (not a live/always-on parser). This meant `harnessGetLastBlock`/`harnessGetBlock` didn't
need a new daemon-side OSC-133 subsystem — just a sibling method next to `captureGrid` that does
the same replay, then reads the replayed instance's block store. Not "retroactive backfill"
(explicitly rejected in F1's interview) since the replayed bytes contain the SAME live OSC 133
`C`/`D` sequences originally parsed — deterministic recomputation, not guessing.
New: `IPCRequest.getBlock(surfaceID:blockID:)` / `IPCResponse.blockInfo(BlockSummary?)`
(`HarnessIPC`), `RealPty.block(id:)` (daemon), `SurfaceRegistry.handle(.getBlock)`,
`HarnessDaemonTools.getBlock` + `harnessGetLastBlock`/`harnessGetBlock` MCP tool registration
(`ToolRegistry.swift`). Nil `blockID` = most recent *finished* block; a still-running block (no
`D` yet) returns nil even by exact id since there's no output range to read yet.
Tests: extended `TerminalBlockStoreTests` (full block shape, exit code, output range,
lastFinishedBlock-only), new `HarnessGridTerminalTests` cases for the wrapper forwarding
(`lastBlock`/`block(id:)`) that `RealPty.block(id:)` calls into — no daemon-level PTY-spawning
test added, matching the existing precedent that `captureGrid`/`captureRange` (same replay
shape) have never had one either.
`swift build --product Harness` clean; `swift test` (2 full runs) only the 2 pre-existing
unrelated failures; `Tests/robot/run.sh` 10/10. One transient signal-11 crash in an unrelated
Metal/GPU test (`GridCompositorCopyModeTests`) during a single full-suite run — reproduced
against the clean pre-F2/F3 baseline commit via `git stash`/re-run to rule out a regression;
did not recur across 2 more full runs with these changes present, so treated as a pre-existing
flake, not caused by this work.
**Lesson:** before assuming a daemon-side MCP tool needs new live state tracking, check whether
the daemon already has an on-demand "replay stored bytes through a fresh headless instance"
pattern for a sibling feature (`captureGrid` here) — it may already be the source of truth you
need, with no new subsystem required.

### 2026-07-02 — P34 F1 slice 1: OSC 133 command-boundary + block command-text capture ✅ DONE, committed (`2ca7fbb`)
`interview` skill (doc.md, codebase-aware) before implementing, since research found the plan
doc's own premise partly wrong: `SemanticMark` (`TerminalScreen.swift`) tracks only `exit: Int?`
per row — no command text, no persistent block model — and none of zsh/bash/fish
shell-integration scripts actually emit OSC `133;B`/`133;C` (only `A`/`D`), so the existing
"command duration" feature (`onCommandFinished`) never fires against a real shell, only
hand-fed tests. `BlockTintOverlay`'s Re-run already existed (Warp-style ⌘-click overlay,
Copy/Re-run buttons) but used a regex prompt-prefix strip to guess the command — an
already-flagged `ponytail:` ceiling comment pointed at exactly this fix.

User confirmed via interview: F1 only this pass (no F2 UI-actions/F3 MCP tools yet, same
"ทำ 1 ก่อนแล้วค่อย improve" pattern as file-preview), shell-script changes requiring re-install
on other machines acceptable, no retroactive scrollback backfill, and fix Re-run's regex-strip
now since the real data would be available. Consulted `advisor` before touching 3 shell
scripts (every pane sources them) — confirmed direction, added two corrections: (1) skip
emitting `133;B` entirely — engine code already treats it as fallback-only ("C deliberately
overwrites B"), so embedding a marker in `$PROMPT`/`PS1` (fragile against starship/p10k
dynamic-prompt themes) is unnecessary; (2) bash's only preexec mechanism is the `DEBUG` trap
(fires per pipeline-stage, needs a `PROMPT_COMMAND`/reentrancy guard) — too much of a footgun
to hand-roll into every bash user's rc without dedicated test coverage, so deferred (bash
stays A+D only, `ponytail:` comment names the ceiling and upgrade path).

**Fix:** zsh (`add-zsh-hook preexec`) and fish (`--on-event fish_preexec`) now also emit
`133;C;<base64 command>` — the shell's own preexec hook already knows the exact typed command,
so this carries real data instead of reconstructing it from rendered terminal columns. Base64
avoids the payload colliding with the OSC-133 `;`-field-separator the parser already splits on.
`TerminalEmulator.handleSemanticPrompt` decodes it and opens a `TerminalBlock` (new file,
`Emulator/TerminalBlock.swift`) in a new per-pane `TerminalBlockStore` — deliberately decoupled
from `HistoryLine`/scrollback (own last-N cap) so a block survives `dropHistoryHead` eviction,
matching F1's "forward-only, no retroactive rescan" scope. `133;D` closes the block (exit code
+ end line). New `TerminalEmulator.commandText(atPromptLine:)` is the only new public surface
crossing into `HarnessTerminalKit` (mirrored via `HarnessTerminalSurfaceView.commandText`);
`BlockActionBar.rerunBlock()` now uses it when available, falling back to the old regex-strip
only for panes whose shell doesn't emit `C` yet (bash).
Bonus: emitting `C` also fixes the latent bug where `onCommandFinished`'s duration/"long
command finished in background" notification never fired against a real shell (`C→D` timing
now actually happens).
Tests: `Tests/HarnessTerminalEngineTests/TerminalBlockStoreTests.swift` (4 cases — capture,
no-C-no-text, unknown-prompt-line nil, two-blocks-don't-bleed), extended
`ShellIntegrationTests.testZshAndFishEmitCommandBoundary` (+ explicit bash-must-not assertion).
`swift build --product Harness` clean; `swift test` only the 2 pre-existing unrelated failures
(`ExperienceModeTests`, `Phase6KeysTests`); `Tests/robot/run.sh` 10/10.
**Lesson:** when a plan doc's "extend the shell script" step turns out to need a *payload*
(not just a boundary marker), check whether the shell's own hook already carries the data
(zsh/fish preexec receive the literal command as an argument) before reaching for
screen-scrape/regex — it's both more accurate and avoids touching fragile territory like
`$PROMPT`/`PS1` that prompt-theme frameworks reset on every render.

### 2026-07-02 — File preview tabs leaked across terminal Tabs (global singleton) ✅ FIXED, not committed
Feature request via `interview` skill (per-Tab scope confirmed with user, not per-Session/per-Pane —
split panes were just an example of already-correct isolation, not an additional requirement).
Double-clicking a file (from Git panel Changes list or file tree) opened it into a single
app-wide `FileTabManager` singleton owned by `FilePreviewCoordinator` — any Tab showed the
same file-preview state, deduped only by path, no session/tab awareness at all.

**Fix:** promoted `FileTabManager` from one `let` instance to a `var` swapped via
`switchToTab(tabID:)`, backed by `fileTabManagers: [String: FileTabManager]` keyed by tabID —
mirrors `PaneLifecycleManager.containerCache`'s exact pattern (already proven for terminal
panes) rather than inventing a new one. Wired into `ContentAreaViewController.snapshotChanged`
(switch on every snapshot tick, cheap tabID-equality guard) and `viewDidLoad` (seed initial tab
before `restoreEditorState()`, so restored paths land in the correctly-keyed manager, not an
orphaned throwaway instance). `pruneFileTabManagers(keepingTabIDs:)` added alongside
`paneLifecycle.pruneCache` on structural changes, same leak-prevention shape.
Persistence across app restart intentionally deferred (user: ship in-session scoping first,
improve to cross-restart persistence later) — `UserDefaults` keys stay flat/global for now,
so restored state on next launch reflects whichever tab last touched it, not true per-tab.
Test: `Tests/HarnessAppTests/FilePreviewCoordinatorTabScopeTests.swift` (3 cases: leak-hidden
on switch-away, correct-file-restored on switch-back, pruned-tab starts fresh).
**Lesson:** when a new per-X-scoped state need comes up, check for an existing per-tabID/
per-sessionID dictionary-cache pattern already proven elsewhere (`PaneLifecycleManager`) before
designing a new one — same shape, same pruning discipline, smaller diff.

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
