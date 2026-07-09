# Review — kouen-terminal architecture & risk (whole codebase)

_Date: 2026-07-08 · Reviewed at: `62cd187e` (branch `p25-mobile-web-mvp`) · Read-only review_

> **Scope note:** `MobileBridgeServer.swift`, `PairedDeviceStore.swift`, `IPCMessage.swift`, `DaemonServer.swift`, `SurfaceRegistry.swift`, and `SettingsRemoteView.swift` were mid-edit by another agent during this review. They were read for context only; no style/completeness findings are reported on them, and mobile-bridge security posture is covered separately (`agent-memory/plans/p37-mobile-connect-v1.md`). Every finding below was verified against actual code or an empirical repro; nothing is speculative unless marked UNVERIFIED.

---

## Executive summary

| # | Severity | Area | Finding |
|---|----------|------|---------|
| A1 | **High** | Lifecycle | S1 daemon-reuse is self-defeating: install-graceful.sh keeps the daemon alive on protocol match, but the relaunched GUI's build-handshake staleness check restarts it seconds later — running tasks die anyway |
| A2 | **High** | Build/release | `core.hooksPath` points at the deleted pre-rename repo path (`…/harness-terminal/.githooks`) — the commit-msg Info.plist guard and post-commit hook are silently dead |
| A3 | **Med** | Lifecycle | install-graceful.sh infers the *running daemon's* protocol from the *installed CLI* — a stand-in that `refreshInstalledBinaries` invalidates at every app launch; `pgrep -f KouenDaemon` also matches preview/dev daemons |
| A4 | **Med** | IPC | The exact-equality `identifyClient` handshake is only ever sent by `kouen-cli -CC`; GUI/attach/MCP clients skip it, and response-side enum additions tear down old clients' connections (fatal on subscription channels) |
| A5 | **Med** | Persistence | `RecipesStore.load()` destroys the user's file on parse failure: seeds defaults **and immediately `save()`s over it**, bypassing `backupCorruptFile` — the one store that skips the shared helper |
| A6 | **Med** | Lifecycle | Preview/DEBUG `restartForMobileBridgeSettingChange` no-ops when the fallback daemon was spawned by a *previous* app run (`fallbackProcess` is per-process state; the fresh spawn is refused by the socket-holding prior instance) |
| A7 | **Med** | Build/release | No test gate anywhere in the release pipeline: `full-cycle.sh` Step 1 is `swift build` only; the "run `Tests/robot/run.sh` before every build" rule appears in zero scripts/Makefile targets |
| A8 | **Low** | Data path | "mktemp failed" spam in KouenDaemon test logs is a **test-env artifact**, root-caused (repro'd): tearDown deletes the temp `KOUEN_HOME` while `ScrollbackFile`'s 0.5–2 s debounced flush is still pending — not a production bug |
| A9 | **Low** | Persistence | `OutputTriggerStore` silently returns empty on a corrupt file (file preserved, but no stderr log — inconsistent with the other stores) |
| A10 | **Low** | Concurrency | `@unchecked Sendable` inventory in CLAUDE.md (8 types) is stale — `ScrollbackFile` and `DaemonSubscription` also carry manual lock/queue contracts |

**Healthy areas (verified, no findings):** RealPty lifecycle (generation-tagged reap/escalation with lock-documented invariants and dedicated tests), DaemonClient/DaemonSubscription (documented lock ownership + deadlock regression tests), the FIFO byte-order pattern (all terminal output still flows through `DispatchQueue.main.async` + `MainActor.assumeIsolated`; zero `Task { @MainActor }` on the byte path), flood bounding in the PTY→disk→subscriber pipeline, IPC frame-size/desync handling, and `ditto`'s inode behavior in install-graceful.sh (empirically creates a fresh inode — no codesigning vnode-cache hazard).

---

## Prior-review action-item status (REVIEW-graphify-harness-2026-07-03.md)

| Item | Status |
|------|--------|
| H5 — `launchctl bootout` quoting bug | **Merged & fixed.** `UID_NUM=$(id -u)` computed in the parent, interpolated into the child heredoc (`Scripts/install-graceful.sh:57,89-90`). |
| H6 — `.gitignore` graph.json/graph.html | **Merged & fixed.** `.gitignore:58-59`; `git ls-files graphify-out/` shows neither tracked (also wiki/, dated snapshots, cache). |
| S1 — compat-gated daemon reuse | **Merged** (`install-graceful.sh:59-97`, `DaemonStats.protocolVersion`, `kouen-cli protocol-version`) — **but functionally defeated by A1 below.** |
| Notification Step 1 | **Merged and exceeded.** `SessionCoordinatorTypes.swift` now runs `NSAppleScript` on the main thread with the error logged (`:96-100`), *and* a real `UNUserNotificationCenter` path with authorization logging exists (`:61-87`) — Step 3's shape has partially landed. |

---

## 1 — Process lifecycle & supervision

### A1 (High) — S1 daemon-reuse is undone at GUI relaunch by the build-handshake staleness check

**Evidence:**
- `Scripts/install-graceful.sh:59-97` — when installed and new `kouen-cli protocol-version` match, `REUSE_DAEMON=1` and the daemon is deliberately left running ("running shells/agents survive the install untouched"). The script then `open`s the new app (`:122`).
- `Apps/Kouen/Sources/KouenApp/AppDelegate.swift:82` — the relaunched GUI calls `DaemonLauncher.shared.ensureRunning` at startup.
- `Apps/Kouen/Sources/KouenApp/Services/DaemonLauncher.swift:101-104` — `ensureRunningBlocking` fetches `daemonStats` and calls `restartStaleDaemon()` when `daemonIsStale(stats)`.
- `DaemonLauncher.swift:149-152` — `daemonIsStale` = `stats.isStale(comparedTo: KouenVersion.build)` OR mtime heuristic. `Packages/KouenIPC/Sources/KouenIPC/DaemonStats.swift:55-58` — `isStale` is **`build != expectedBuild`**, protocol version is never consulted.
- `restartStaleDaemon()` → `LaunchAgentInstaller.relaunch()` → `launchctl kickstart -k` (`Packages/KouenCore/Sources/KouenCore/Paths/LaunchAgentInstaller.swift:156-158`) — kills the daemon and every PTY/agent under it.

**Failure scenario:** Release build 195 → `make start` → Full cycle → install-graceful detects protocol 3 == 3, prints "daemon (and running tasks) will keep running", installs, relaunches GUI. New GUI (build 195) asks the surviving daemon (build 194) for stats → `194 != 195` → stale → `kickstart -k`. Every running shell and agent task dies ~2 seconds after the installer promised they'd survive. The only case S1 actually protects is "GUI never relaunches" (headless CLI/MCP-only use) — and even that lasts only until the next GUI launch.

**Why this matters doubly:** `refreshInstalledBinaries()` (`DaemonLauncher.swift:98-100`) has already staged the new daemon binary into `bin/`, so the *deferred* restart the S1 design intended ("next natural daemon restart picks it up") would work — the staleness check just never lets "natural" happen.

**Smallest fix:** In `daemonIsStale`, when `stats.protocolVersion == ipcProtocolVersion` and only `build` differs, don't force a restart while the daemon has live surfaces (`stats.surfaceCount > 0`); restart immediately only on protocol mismatch or an idle daemon. That makes the app-side policy agree with the installer-side policy instead of racing it.

### A3 (Med) — installer's protocol probe reads the installed CLI, not the running daemon

**Evidence:** `install-graceful.sh:60-77` — comment admits the installed CLI is "a stand-in for the running daemon's protocol, since they were built together". But `DaemonLauncher.refreshInstalledBinaries()` (`DaemonLauncher.swift:263-272`) rewrites `bin/kouen-cli` from the app bundle at **every release-app launch** — including launches where the daemon kept running (the A1 reuse scenario, or any launch where the daemon restart was masked by `|| true` on `bootout`/`pkill`, `install-graceful.sh:89-92`). After that, the CLI on disk is newer than the daemon in memory and the stand-in lies.

**Failure scenario:** daemon running at protocol 2; a release bumps to protocol 3 but the daemon restart silently fails (bootout error masked). Installed CLI now reports 3. Next install: `3 == 3` → REUSE → the protocol-2 daemon is preserved under a protocol-3 GUI. Nothing in the GUI path detects this (see A4) except the build check — which A1's fix would relax.

Also: the gate `pgrep -f "KouenDaemon"` (`:67`) matches *any* command line containing the string — a preview daemon under `/tmp/kouen-preview-*`, a `.build/debug/KouenDaemon` dev run — so the "is the production daemon running" premise can be satisfied by the wrong process.

**Smallest fix:** the daemon already reports its live `protocolVersion` in `daemonStats` (added for exactly this purpose, `DaemonStats.swift:19-23`). Ask it: `OLD_PROTO=$("$INSTALLED_CLI" daemon-stats --json | jq .protocolVersion)` (or a tiny `kouen-cli daemon-protocol-version` that queries the socket), falling back to the stand-in only when the daemon doesn't answer. Tighten `pgrep -f` to the two absolute paths already used by the `pkill` lines.

### A6 (Med) — preview/DEBUG mobile-bridge restart no-ops across app restarts

**Evidence:** `DaemonLauncher.swift:224-234` — `spawnFallbackProcess(forceRestart:)` can only terminate a daemon recorded in `fallbackProcess`, which is in-memory state of *this* app process. A fallback daemon from a previous app run (daemons outlive the app) leaves `fallbackProcess == nil`, so `forceRestart: true` skips the terminate and spawns a duplicate — which `DaemonLifecycle.priorInstanceDecision` then refuses because the prior instance's PID is alive (`Packages/KouenDaemon/Sources/KouenDaemon/DaemonLifecycle.swift:13-53`, asserted by `DaemonLifecycleTests.testLiveKouenDaemonRefuses`). Net effect: toggling the Settings switch after an app restart silently changes nothing in DEBUG/preview — the same "fallback spawn no-op'd on setting changes" class MEMORY.md 2026-07-08 records, one level up.

**Smallest fix:** in the preview branch of `restartForMobileBridgeSettingChange`, when `fallbackProcess == nil` read `KouenPaths.daemonPIDURL` and `SIGTERM` that PID before spawning (mirroring what `daemonPIDFromFile()` already exists for).

### Lifecycle — verified non-findings
- `restartStaleDaemon`'s restart-exactly-once contract (`DaemonLauncher.swift:163-182`) is internally consistent: `install()` bootouts only on content change (`LaunchAgentInstaller.swift:109-118`), and `relaunch()` fires only when the plist was unchanged — no double-restart path found.
- install-graceful.sh's `ditto` refresh of `bin/KouenDaemon` while the reused daemon runs from it is safe: empirically `ditto` creates a **new inode** (tested: inode 98840775 → 98840776), so it's equivalent to `BinaryRefresher`'s deliberate remove-then-copy and avoids the `OS_REASON_CODESIGNING` trap documented in `BinaryRefresher.swift:8-10`.
- The H5 quoting fix is genuinely in: stop-daemon lines are built in the parent with `$UID_NUM` expanded (`install-graceful.sh:87-94`).

---

## 2 — IPC protocol evolution

### A4 (Med) — the exact-equality handshake protects almost nobody; response-side additions are the sharp edge

**Evidence:**
- `ipcProtocolVersion = 3`, enforced only on `identifyClient` (`IPCMessage.swift:16`, `DaemonServer.swift:492-494`, `.protocolRejected` + connection close).
- The **only** sender in the tree is `Tools/kouen/Sources/KouenCLI/ControlModeClient.swift:15` (`kouen-cli -CC`). GUI and `kouen-cli attach` subscription clients register through the subscribe path instead — `DaemonServer.swift:696`: "GUI/attach clients register here, never through identifyClient". One-shot CLI requests and `kouen-mcp` (which shells through `DaemonClient`) never handshake either. No client anywhere handles `.protocolRejected` (grep: zero non-daemon references), so even for `-CC` the rejection reason can never be shown — an old client lacking the enum case hits `FrameError.undecodable` and drops the connection before reading it.
- Mismatch behavior per direction (from `IPCCodec.swift` contracts, `:30-52,129-178`):
  - **new client → old daemon** (unknown `IPCRequest` case): daemon replies `.error` and keeps the connection — graceful, request-side evolution is additive-safe.
  - **new daemon → old client** (unknown `IPCResponse` case): `decodeReply`/`decodeReplyOrData` throw `undecodable` and the client **tears down the connection** — on a subscription channel this looks identical to daemon death and lands the GUI in its reconnect/backoff path. Response-side evolution is strictly breaking, guarded today only by the convention documented at `IPCMessage.swift:390-391` ("only ever sent in answer to that request, so an old client never receives it") — convention, not compiler.

**Failure scenario:** a future daemon starts *pushing* a new response case on an existing subscription channel (the natural way to add, e.g., a richer `snapshotChanged`). Every GUI/attach client one build behind loses its subscription in a loop. Because the real compat gate is the build-equality restart in A1, relaxing A1 without touching this **widens** the skew window — fix them together.

**Smallest fix:** (1) include the daemon's `protocolVersion` in the existing subscribe/attach registration reply so subscription clients can log/refuse a skew explicitly; (2) write the "never push new response cases on pre-existing channel types" rule into `IPCMessage.swift`'s version-bump comment block, which is where the next editor will be looking.

### Binary frames — verified non-finding
Only `0xF5`/`0xF6` exist; the "new magic needs a version gate — old readers see it as `tooLarge` and drop the connection" constraint is documented at the definition site (`IPCCodec.swift:84-87`), and the `maxPayloadLength ≤ 16 MiB ⇒ length high byte ≤ 0x01` disambiguation invariant is stated next to the constant it depends on. Length-prefix handling is desync-safe in both codecs (`tooLarge` = drop connection; `undecodable` = consumed frame, reply error). No unversioned new frame types found.

---

## 3 — Concurrency architecture

Spot-checked the four highest-traffic `@unchecked Sendable` types; **all pass**, with unusually good invariant documentation:

- **RealPty** (`RealPty.swift:53-230,1076-1230`): every mutable field names its guard (`lifecycleLock`, `scrollbackLock`, `subscribersLock`, or queue confinement); the generation-tagged reap/escalation machinery (`reapedGenerations` + `pendingEscalations`, `:72-91`) correctly closes the recycled-PID SIGKILL hole and has dedicated deterministic test hooks. Fan-out is on a serial `deliveryQueue` with an explicit "do not special-case one subscriber inline" ordering comment (`:1149-1157`).
- **DaemonClient / DaemonSubscription** (`DaemonClient.swift:8-11,220-239`): stateless-between-calls vs. three named locks; deadlock regressions covered (`DaemonClientTests.testSubscriptionCancelDoesNotDeadlockWhileReadLoopBlocked`).
- **SurfaceIO / InputGate** (`TerminalHostView.swift:1050-1256`): each field's guard documented, including the coalesced `.sendData` fallback rationale.
- **FIFO byte order:** every output delivery in `TerminalHostView` uses `DispatchQueue.main.async` + `MainActor.assumeIsolated` (`:795-901`), with the "an unstructured `Task { @MainActor }` is NOT order-preserving" warning inline at `:824-825`. Grepped all 34 `Task { @MainActor` sites in KouenApp/KouenTerminalKit (incl. the new `QuickTerminalController`): none is on a byte-delivery path. **No violations.**

### A10 (Low) — stale `@unchecked Sendable` inventory
CLAUDE.md's constraint list names 8 types; at minimum `ScrollbackFile` (`ScrollbackFile.swift:20`) and `DaemonSubscription` (`DaemonClient.swift:221`) also carry manual contracts (plus the in-flux mobile-bridge types). The list is what reviewers are told to protect — keep it current or say "and companions in the same files".

---

## 4 — State persistence

The shared helpers (`KouenPaths.backupCorruptFile` / `atomicWrite`, `KouenPaths.swift:284-323`) are used consistently by **nine** stores: SessionStore, OptionStore, EnvironmentStore, PasteBufferStore, KeybindingsStore, KouenSettingsIO, HookRegistry, RemoteHostStore, PairedDeviceStore. All writes found are atomic (`.atomic` or temp+`rename` in `ScrollbackFile.compactToTail`, `ScrollbackFile.swift:83-114`). Two stragglers:

### A5 (Med) — `RecipesStore` overwrites a corrupt user file with defaults
**Evidence:** `Packages/KouenCore/Sources/KouenCore/RecipesStore.swift:30-38` — `load()`'s catch block sets `self.recipes = Self.defaultRecipes` **and calls `save()`**, which atomically replaces `recipes.json`. A user file with one stray comma is unrecoverably gone on next launch. This is verbatim the anti-pattern the shared-helper comment block calls out ("preserve an unreadable file instead of overwriting it", `KouenPaths.swift:286-289`).
**Smallest fix:** in the catch, `KouenPaths.backupCorruptFile(at: fileURL, label: "RecipesStore")` before seeding defaults, and drop the eager `save()` (defaults can persist on first user mutation).

### A9 (Low) — `OutputTriggerStore` degrades silently
`OutputTriggerStore.swift:21-30` — corrupt file → `try?` → empty trigger list, no log, no backup (file at least preserved). One `fputs` in the guard-else would make a corrupt file diagnosable.

---

## 5 — Render/PTY data path & the "mktemp failed" spam

### A8 (Low) — "mktemp failed" root cause: test teardown races the debounced scrollback flush. Test-env artifact, not a product bug.

**Root-cause chain (each link verified):**
1. `SurfaceRegistryTests.setUpWithError` points `KOUEN_HOME` at `/tmp/…/kouen-registry-<UUID>` and creates it; **`tearDownWithError` deletes the directory and restores the env** without ever shutting the registry down (`Tests/KouenDaemonTests/SurfaceRegistryTests.swift:13-28`) — the forked shells and their `ScrollbackFile`s stay alive past the test.
2. `ScrollbackFile.append` debounces writes 0.5–2 s (`ScrollbackFile.swift:32-42`), so the first prompt output's flush routinely fires **after** teardown.
3. `flushPending → appendToDisk`: the file doesn't exist (dir deleted) → `KouenPaths.ensureDirectories()` + `atomicWrite` (`ScrollbackFile.swift:196-199`). But `ensureDirectories` reads the **current** `KOUEN_HOME` — already restored by teardown — so it recreates directories in the *wrong* root while the write targets the deleted one.
4. `Data.write(options: .atomic)` into a missing directory produces exactly the observed text — reproduced standalone: `NSCocoaErrorDomain Code=4 "Creating a temporary file via mktemp failed. Creating the temporary file via _amkrtemp previously also failed with errno Optional(2)"`. The string is Foundation's, which is why it greps to nothing in the repo.

**Production impact:** none — the daemon's directories exist for its lifetime and the URL is captured at surface creation. **Smallest fix (two independent halves):** (a) tests: close/flush the registry's surfaces before removing `root` in `tearDownWithError`; (b) `ScrollbackFile.appendToDisk`: create `url.deletingLastPathComponent()` instead of calling the env-dependent global `ensureDirectories()` — that also removes the "recreate prod dirs from inside a test" side effect.

### Flood behavior — verified non-findings
The pipeline is bounded at every stage, each bound documented at its site: reused 64 KiB read buffer (`RealPty.swift:96-102`), O(1)-amortized ring eviction (`:1119-1128`), `ScrollbackFile` 256 KiB pending cap with forced synchronous flush + 2 s max-delay ceiling (`:33-47`), 2× high-water compaction, serial fan-out queue whose growth is capped by the subscriber-side write-backlog/drop-stuck-client policy (`:1149-1157`). Oversized IPC payloads are refused at both encode and decode (16 MiB, `IPCCodec.swift:8,23,65`). The first thing to break under a flood is intentionally the *stuck subscriber*, not the daemon or the shell. The single point of failure remains the daemon process itself, mitigated by launchd `KeepAlive` + scrollback persistence + layout restore.

---

## 6 — Build/release pipeline

### A2 (High) — git hooks are silently disabled by a stale absolute `core.hooksPath`

**Evidence:** `git config core.hooksPath` → `/Users/supavit.cho/Git/Personal/harness-terminal/.githooks`; that path no longer exists (repo renamed to `kouen-terminal`). Git treats a missing hooks dir as "no hooks" — no warning, no error. So the `commit-msg` guard (blocks `Info.plist` riding non-version commits — the enforcement half of the 4-file version-sync invariant) and `post-commit` have both been no-ops since the rename.

**Failure scenario:** any agent/human commits a stray `Info.plist` edit (it is dirty in the working tree right now) in a feature commit; nothing objects; `Info.plist` and `KouenVersion.swift` diverge; the next daemonIsStale comparison or release prep works from mismatched versions.

**Smallest fix:** `git config core.hooksPath .githooks` (relative — survives renames/moves; it's what CLAUDE.md already documents). Consider having `Scripts/prepare-release.sh` sanity-check that the configured hooksPath exists and warn.

### A7 (Med) — no automated test gate anywhere in the release path
`Scripts/full-cycle.sh:46-54` Step 1 "verify" = `swift build` only; `grep -rn robot Makefile Scripts/` = zero hits. The "run `Tests/robot/run.sh` BEFORE every build" rule and `swift test` live entirely in CLAUDE.md discipline — one distracted session ships an untested release with a bumped version and a GitHub tag. **Smallest fix:** insert `Tests/robot/run.sh` (fast, invariant-focused by design) into full-cycle Step 1, with a `--skip-tests` escape hatch.

### Verified non-findings
- `prepare-release.sh` does update all four version surfaces in one run (Info.plist + KouenVersion.swift + `make release-notes` + CHANGELOG block, `:15-230`) and prints the combined diff. The atomicity is per-run, not transactional — acceptable given A2's hook is restored.
- `full-cycle.sh` Step 4 correctly routes through `install-graceful.sh` (the 07-03 review's fix is merged, `:82-92`) — its session-preservation promise is what A1 breaks downstream.

---

## Prioritized action list

1. **Restore the hooks (A2, one command):** `git config core.hooksPath .githooks`. Everything else about the version-sync invariant assumes this guard exists.
2. **Make daemon-reuse real (A1):** gate `DaemonLauncher.daemonIsStale` on `stats.protocolVersion == ipcProtocolVersion && stats.surfaceCount > 0` → defer restart. Do it together with the A4 comment-rule so the skew window it opens is bounded by policy.
3. **Probe the live daemon's protocol in install-graceful.sh (A3):** query `daemonStats.protocolVersion` over the socket; keep the installed-CLI value only as fallback. Tighten the `pgrep -f` patterns to absolute paths.
4. **Stop `RecipesStore` from eating user files (A5):** `backupCorruptFile` + no eager `save()` in the load-failure path (3 lines).
5. **Add the robot-test gate to full-cycle Step 1 (A7).**
6. **Fix the preview mobile-bridge restart across app runs (A6):** SIGTERM the PID from `daemon.pid` when `fallbackProcess == nil`.
7. **Quiet the test-log spam and de-globalize the flush path (A8):** registry shutdown in `SurfaceRegistryTests.tearDown`; `appendToDisk` creates its own parent dir.
8. Housekeeping: log corrupt `output-triggers.json` (A9); refresh the `@unchecked Sendable` inventory in CLAUDE.md (A10).
