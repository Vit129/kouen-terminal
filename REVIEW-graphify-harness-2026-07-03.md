# Review — graphify (algorithms & structure) + harness-terminal (risks & solutions)

_Date: 2026-07-03 · Reviewed: `~/Git/Personal/graphify` @ v0.14.0 (`04135eb`) · `~/Git/Personal/harness-terminal` @ `39c0c02b` (main)_

> **Independently verified by a second model (Sonnet 5).** Every line number, constant, and byte count checked out exactly. Two corrections applied post-verification: H7 (file-preview fixes) was stale — already shipped in `587fa906` — and retracted; G1/G4 were narrowed for scope gaps (an existing extractor migration plan, and a god-node filter that also needs to catch module names, not just builtins). See inline `Correction:` notes.

---

## Part 1 — graphify: algorithm & structure review

### 1.1 Architecture

Clean single-function-per-module pipeline, communicating via plain dicts and NetworkX graphs — no shared state, side effects confined to `graphify-out/`:

```
detect() → extract() → build_graph() → cluster() → analyze() → report() → export()
```

[source:ARCHITECTURE.md] — the module table matches the actual code layout.

### 1.2 Algorithm review

**Clustering (`cluster.py`) — solid, determinism-first.**
- Leiden (graspologic, `random_seed=42`) with Louvain fallback; nodes/edges are sorted into a fresh graph before partitioning so results don't depend on insertion order (`cluster.py:34-45`).
- Oversized communities (> 25 % of graph, min 10 nodes) get a second Leiden pass; low-cohesion communities (< 0.05, ≥ 50 nodes) are re-split — this specifically counters doc-hub nodes (e.g. a CLAUDE.md linked to everything) bridging unrelated subsystems (`cluster.py:209-227`).
- Hub-exclusion percentile: super-hubs are removed before partitioning and reattached by majority-vote of neighbours (`cluster.py:162-207`) — the right fix for utility nodes polluting communities.
- Community IDs are a **total order** (size desc, then sorted-member tiebreak, `cluster.py:235`), plus `remap_communities_to_previous()` (greedy overlap matching) and sha256 membership fingerprints to invalidate stale LLM labels. This is more churn-hardening than most published pipelines bother with. ✅

**God nodes (`analyze.py:100`)** — degree (default) or PageRank, with noise filters: file-level nodes, concept nodes (no real source path), JSON boilerplate keys, builtin labels. Reasonable; see 1.4 for a gap.

**Surprising connections (`analyze.py:143`)** — mode-switch: multi-file corpora → cross-file edges ranked AMBIGUOUS → INFERRED → EXTRACTED (least certain = most interesting); single-file → edge-betweenness cross-community bridges. Sensible heuristic split.

**Dedup (`dedup.py`) — the most mature algorithm in the repo.**
Pipeline: NFKC-normalize → Shannon-entropy gate → MinHash/LSH blocking (3-gram char shingles, 128 perms) → Jaro-Winkler verification → same-community boost → union-find merge. Four false-positive guards, each traceable to a numbered issue and each with regression tests (`tests/test_dedup.py`, ~20 cases):
- `_is_variant_pair` — SKU/model siblings (M1 vs M2) never merge
- `_short_label_blocked` — short labels only merge on same-length single-char substitution (true typos)
- `_numeric_tokens_differ` — digit-run multiset comparison (with the int()-overflow footnote handled via string compare)
- `_crossfile_fileanchored_blocked` — docstring/heading boilerplate never label-merges across files

This guard-plus-test discipline is the repo's strongest quality signal. ✅

### 1.3 Structure findings

| # | Finding | Evidence | Suggestion |
|---|---------|----------|------------|
| G1 | **`extract.py` is a 16,010-line monolith** — every language extractor in one file, while an `extractors/` package already exists (csharp.py, gherkin.py, yaml_.py…). ARCHITECTURE.md still instructs adding new languages to `extract.py`. **Correction: not a neglected migration** — `graphify/extractors/MIGRATION.md` documents an active plan, 4/44 languages moved so far, explicitly deferred because the remaining extractors share a ~1,300-line config-driven core that must move as one coordinated batch, not file-by-file. | `wc -l`: 16,010; `graphify/extractors/MIGRATION.md` | Follow the existing MIGRATION.md plan rather than a fresh one-extractor-at-a-time push. |
| G2 | **`__main__.py` is 5,234 lines** — CLI parsing + command implementations fused. | `wc -l` | Split command handlers into a `cli/` package; keep `__main__.py` as dispatch. Lower priority than G1. |
| G3 | **Version skew in the live environment**: installed package 0.10.0, installed skill 0.13.0, repo at 0.14.0 — every `graphify` call prints 5 duplicate warnings. | warning spam on every query run during this review | `uv tool upgrade graphifyy` (or install the local 0.14.0 in editable mode), then `graphify install` to re-sync the skill. Also: dedupe the warning (print once per invocation, not per subcommand step). |
| G4 | God-node noise filter misses primitive types from tree-sitter output: harness-terminal's #1 god node is `Int` (927 edges). **The list also includes module names** (`HarnessCore`, `Foundation`, `XCTest`, `AppKit`) which a builtin-type allowlist would NOT catch. | GRAPH_SUMMARY.md god-node list | Broader fix than a builtin-type list: filter nodes with empty `source_file` AND a label matching either a known stdlib type OR an import-target/module-name pattern (no lowercase body, no call parens). |

Security posture (centralized `security.py`: URL scheme allowlist, `file://` redirect blocking, graph-path containment, label sanitization) and per-module test layout are both good. No algorithmic correctness issues found.

---

## Part 2 — harness-terminal: structure & risk register

### 2.1 Structure

Layered and clean: `Apps/Harness` (GUI) → 14 packages (`HarnessCore`, `HarnessDaemon`, `HarnessIPC`, `HarnessTerminalEngine/Kit/Renderer`, `HarnessLSP`, `HarnessTheme`, `HarnessSettings`, `HarnessOnboarding`, `HarnessCommands`, `HarnessCopyMode`, `HarnessSyntaxResources`, `CHarnessSys`) → `Tools` (`harness` CLI, `harness-mcp`). Graph: 15,189 nodes · 31,628 edges · 89 % EXTRACTED.

Real god nodes (after the `Int` noise): `SessionEditor` (170 edges), `SurfaceRegistry` (154), `IPCRequest` (151), `DaemonClient` (142), `SessionCoordinator` (124) — session state and IPC are the coupling center of gravity, as expected for this architecture.

### 2.2 Risk register (ranked)

| # | Risk | Evidence | Mitigation |
|---|------|----------|------------|
| H1 | **Zombie-view crash class is systemic, not fixed-once.** macOS 26.5 + Swift 6.3.2 checks executor isolation at `@objc` thunk entry — no in-body guard can help; 63 crashes across 8 distinct sites (Jun 13–18). Any new `@MainActor` AppKit view keyed to snapshot fanout re-enters this class. `NotificationCoordinator` holds `unowned let coord` (`NotificationCoordinator.swift:9`) — same lifetime-assumption family. | `agent-memory/knowledge/bugs/zombie-crash-macos26.md` | Adopt a checklist rule: every view registered with a registry must go through `retire()`-style deferred dealloc; prefer `weak` over `unowned` for coordinator back-references unless ownership is provably strict. Add a robot-test that churns pane rebuild + tab close under snapshot fanout. |
| H2 | **8 `@unchecked Sendable` types carry manual locking contracts** that `-warnings-as-errors` cannot check (`DaemonClient`, `DaemonServer`, `SurfaceRegistry`, `RealPty`, `DaemonLauncher`, `SurfaceIO`, `InputGate`, `SSHTunnelManager`). | CLAUDE.md constraints | Each type should document its lock/queue invariant at the declaration; concurrency-touching PRs to these files deserve the `review-personas` pass by default. |
| H3 | **FIFO byte order is convention-guarded, not compiler-guarded**: `TerminalHostView` relies on `DispatchQueue.main.async` + `MainActor.assumeIsolated`; refactoring to `Task { @MainActor in }` silently reorders bursty output. | CLAUDE.md | The constraint is documented; add a comment-adjacent unit test if one doesn't exist (replay burst, assert order) so a refactor fails loudly. |
| H4 | **Strict IPC `protocolVersion` equality forces daemon restart on every version bump** — the direct cause of "install kills my running tasks" (see Part 4). | `IPCMessage.swift:129-131`, `:329` | See Part 4 solution 1: only restart the daemon when the protocol version actually changed. |
| H5 | **`install-graceful.sh` quoting bug — confirmed, not speculative.** Inside the detached child script, `launchctl bootout 'gui/\$(id -u)' …` puts `$(id -u)` inside *single quotes in the child*, so it never expands — both `bootout` calls always fail (masked by `\|\| true`) and daemon shutdown silently falls through to bare `pkill`. **`KeepAlive` is in fact set** (`LaunchAgentInstaller.swift:56`, asserted by `LaunchAgentInstallerTests.swift:17`), so the respawn race during install is a real condition, not a hedge. | `Scripts/install-graceful.sh:69-70`, `LaunchAgentInstaller.swift:56` | Compute `UID_NUM=$(id -u)` in the parent and interpolate the literal value into the child script. |
| H6 | **20 MB `graph.json` (+1.9 MB `graph.html`, currently untracked) regenerated on every `graphify update`** and committed — repo history grows by tens of MB per regen. | `git status`, `ls -la graphify-out/` | Keep `GRAPH_SUMMARY.md`/`GRAPH_REPORT.md` in git; move `graph.json`/`graph.html` to `.gitignore` (MCP tools read them locally; nothing needs them from git history). At minimum, never track `graph.html`. |
| H7 | ~~Two verified bug fixes sitting uncommitted on `main`~~ — **stale, retracted.** `git log` shows both file-preview fixes already landed in `587fa906 fix(file-preview): preserve selection on reload, fix clicking agent tool-call paths`. The original draft trusted `agent-memory/CONTEXT.md` instead of checking git log directly. | `git log --oneline` → `587fa906` | None needed — already shipped. |

---

## Part 3 — macOS notifications not showing: root cause & fix

### 3.1 Current implementation

`UNUserNotificationCenter` is **deliberately disabled** — `UNUserNotificationCenter.current()` crashes on macOS 26 due to a corrupted `NSCalendarDate` in the notification database. The replacement posts via in-process AppleScript (`SessionCoordinatorTypes.swift:17-48`):

```swift
static func show(title:body:withSound:) {
    DispatchQueue.global(qos: .utility).async {          // ← background queue
        var error: NSDictionary?
        NSAppleScript(source: script)?.executeAndReturnError(&error)  // ← error discarded
    }
}
static func requestAuthorizationIfNeeded() {}             // ← no-op
static func authorizationStatus(...) { completion(.authorized) }  // ← always lies "authorized"
```

Delivery gates upstream (`NotificationCoordinator.swift`): per-event toggle → `systemNotificationsEnabled` → suppressed when `NSApp.isActive && surfaceID == activeSurfaceID` → 30 s per-surface throttle → `handleNotification` only alerts when the app is inactive.

### 3.2 Why nothing shows (ranked root-cause candidates)

1. **`NSAppleScript` off the main thread.** Apple documents `NSAppleScript` as main-thread-only; executing on a global utility queue fails intermittently or silently on newer macOS. This alone explains "sometimes/never shows".
2. **Silent failure by design.** The `error` dictionary is discarded and `authorizationStatus` hard-codes `.authorized`, so the Settings UI and the "send test" button (`SettingsAgentsView.swift:89`) report success even when every delivery fails. There is currently **no way to observe a failure**.
3. **App not authorized in System Settings ▸ Notifications.** AppleScript `display notification` still goes through the user-notification system attributed to Harness. Since the app never prompts (`requestAuthorizationIfNeeded()` is empty), Harness may be missing from the Notifications list or toggled off — banners drop silently.
4. **The same corrupted notification DB that crashes `UNUserNotificationCenter`** plausibly also drops AppleScript-posted notifications on this machine — the workaround routed around the crash, not around the broken database.
5. Environmental: Focus/Do Not Disturb, or banners suppressed because Harness is frontmost (by design, `NotificationCoordinator.swift:30,75,210`).

### 3.3 Fix plan

**Step 1 — make failures visible (small, do first):**
- Execute `NSAppleScript` on the **main thread** (it's a fire-and-forget one-liner; cost is negligible), or shell out to `/usr/bin/osascript` from the background queue (process isolation, thread-safe, also shields the app from any Apple-event crash).
- Log `error` when non-nil; make `sendTest()` surface the result as a toast ("delivered" / actual AppleScript error) instead of pretending success.

**Step 2 — repair the machine (likely the real fix):**
The crash comment says the notification **database** is corrupted. Reset it:
```bash
# quit apps first; this clears notification history + per-app permission state
rm ~/Library/Group\ Containers/group.com.apple.usernoted/db2/db*
killall usernoted   # relaunches with a fresh DB; then re-allow Harness in System Settings
```
Then verify `UNUserNotificationCenter.current()` no longer crashes (it was crashing on *reading* the corrupt DB).

**Step 3 — restore the real API behind a probe:**
Once Step 2 verifies, re-enable the `UNUserNotificationCenter` path (proper authorization prompt, foreground-presentation delegate, action buttons) with a survivable guard: probe `UNUserNotificationCenter.current()` once at launch inside a crash-isolated check (e.g. a tiny helper process or an OS-version + defaults flag `notificationCenterKnownBad`), falling back to the AppleScript path only when the probe fails. This removes the permanent lie in `authorizationStatus` and gives Settings a truthful permission state.

---

## Part 4 — build & install without disrupting running tasks

### 4.1 Current behavior matrix (self-hosted: Harness building Harness)

| Command | Effect on your running production Harness + agent tasks |
|---|---|
| `make preview` | **None.** Fully isolated bundle id, socket, state dir. Already the correct dev-iteration path. |
| `make prod` / `make run` | **Safe when run inside Harness**: `kill_stale_prod()` returns early when `TERM_PROGRAM == Harness` (`Scripts/run.sh:45-49`) — only the repo-root test instance is killed. Run from another terminal, it **kills the production daemon** (`run.sh:51-54`). |
| `make install` | **Disruptive**: kills app + daemon, no session preservation. |
| `make install-graceful` | **Partly graceful**: detached installer survives its own pane dying; workspace layout + pane CWDs restored — but "running shell processes are restarted fresh (daemon must restart for new binary)" (`install-graceful.sh:2-4`). **Running agent tasks are still killed.** |

### 4.2 The actual gap

The only reason a task dies during deploy is the **daemon restart**. PTYs (and the agent processes inside them) live in `HarnessDaemon`; the GUI is just a subscriber that reattaches through `DaemonClient`. The daemon restart is forced by the strict handshake: `identifyClient(label:protocolVersion:)` must equal `ipcProtocolVersion` exactly (`IPCMessage.swift:129-131`), so any new app binary is assumed incompatible with the old daemon — even when the protocol didn't change (the overwhelmingly common case for UI-only releases).

### 4.3 Solutions (ranked)

**S1 — Compat-gated daemon reuse in `install-graceful.sh` (recommended, small):**
1. Before killing the daemon, compare protocol versions: ask the running daemon its `ipcProtocolVersion` (expose it via an existing stats/hello reply if not already there; `harness-cli` can print it), and read the new binary's version (`Harness.app/Contents/MacOS/harness-cli --ipc-protocol-version`).
2. **Equal → skip daemon shutdown entirely**: install the app bundle, relaunch the GUI, it reattaches to the still-running old daemon. PTYs, shells, and running agents survive with zero downtime. Stage the new `HarnessDaemon` binary into `Application Support/bin` so the *next* natural daemon restart picks it up.
3. **Different → current behavior** (restart daemon, restore layout).

Effort: mostly shell script + one small IPC/CLI exposure. Coverage: every release that doesn't touch the wire protocol — i.e. almost all of them. Fix H5 (the `launchctl bootout` quoting bug) in the same pass.

**S2 — True zero-downtime daemon upgrade (only if S1's coverage proves insufficient):**
nginx-style binary handoff — old daemon passes PTY master fds + session state to the new daemon over a Unix socket (`SCM_RIGHTS`), then exits. Survives protocol bumps too, but is a significant engineering effort (fd inventory, mid-stream state serialization, both-versions-alive window). Don't build this until S1's gap (protocol-bump releases) actually hurts.

**S3 — Workflow discipline available today (no code):**
- Iterate with `make preview` (zero impact by construction); when testing prod builds from inside Harness, `make prod` already protects your production instance.
- Deploy with `make install-graceful`, timed when no agent is mid-task — the `agentFinished` notification (Part 3, once it actually shows) is exactly the "safe to deploy now" signal. These two parts of this review compose.

---

## Action checklist

- [ ] **graphify:** upgrade installed package to 0.14.0 + re-sync skill (G3, 5 min)
- [ ] **graphify:** continue `extractors/MIGRATION.md`'s existing batch plan (G1 — not a fresh migration)
- [ ] **graphify:** broaden god-node noise filter to catch module names too, not just builtins (G4)
- [x] ~~commit the two file-preview fixes~~ — already shipped in `587fa906` (H7 retracted)
- [x] **harness:** notification Step 1 — `DesktopNotifier.show` now runs `NSAppleScript` on the main thread (was a background queue — the API is documented main-thread-only), logs the AppleScript error instead of discarding it, and `sendTest`/Settings UI now show the real success/failure instead of pretending. (`SessionCoordinatorTypes.swift`, `SettingsAgentsView.swift`)
- [ ] **harness:** notification Step 2 — reset corrupted notification DB, verify UN crash is gone (system-level action, needs you to run it)
- [ ] **harness:** notification Step 3 — probe-guarded return to `UNUserNotificationCenter`
- [x] **harness:** fixed the `bootout` quoting bug (H5) — `UID_NUM=$(id -u)` now computed in the parent and interpolated as a literal into the detached child script, so both `launchctl bootout` calls actually target the real `gui/<uid>` domain instead of a never-expanded literal string.
- [x] **harness:** S1 compat-gated daemon reuse shipped. Added `DaemonStats.protocolVersion` (daemon reports its `ipcProtocolVersion`), a new no-daemon-required `harness-cli protocol-version` command (prints the compile-time constant baked into that binary), and `install-graceful.sh` now runs the currently-installed `harness-cli` and the freshly-built one side by side — if their protocol versions match, the daemon (and every running PTY/agent task under it) is left untouched; only the GUI restarts. Falls back to full daemon restart on any mismatch or when the check is inconclusive. Verified: `swift build` clean, `swift test --filter DaemonStatsTests` 6/6, isolated dry-run of the match/mismatch branches, `Tests/robot/run.sh` 10/10.
- [x] **harness:** discovered `make start` → **Full cycle** (the actual day-to-day release flow) did NOT go through `install-graceful.sh` at all — its Step 4 called `make install` (`Scripts/install-app.sh`), a different, always-disruptive installer: it kills the daemon *and* the GUI unconditionally, **before build**, with no protocol check, and unconditionally wipes session state via `clear-runtime-state.sh`. It also has no self-hosted-pane safety net (`install-graceful.sh`'s detached-nohup handoff), so running the release from inside a Harness pane would kill its own session mid-flow. Fixed: `Scripts/full-cycle.sh` Step 4 now calls `Scripts/install-graceful.sh` directly instead of `make install` — so S1's daemon-reuse protection, session-state preservation, and self-hosted-pane safety now actually apply to the release path you use day to day, not just to the standalone `make install-graceful` target.
- [x] **harness:** `.gitignore`'d `graphify-out/graph.json` + `graph.html` (H6) and untracked `graph.json` from git (kept on disk, `git rm --cached`)
- [ ] **harness:** `.gitignore` `graphify-out/graph.json` + `graph.html` (H6)
