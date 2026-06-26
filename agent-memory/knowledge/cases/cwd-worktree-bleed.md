# Case: cwd "bleed" — session worktree jumps to wrong dir during builds

confidence: 1.0 (user-validated, deterministic repro)
date: 2026-06-26

## Symptom
During `make build` / `make install` (or any time a foreground subprocess runs), a session's
**tab pill, git panel, and file tree** all jump to the wrong directory — another repo, `/`, etc.
The active session's reported `cwd` flaps between several repos while `activeSessionID` stays
constant. Side effect: a reload storm makes the sidebar panel render blank.

## Root cause
The 1.5s metadata scan (`AgentScanner` → `SurfaceRegistry.refreshSurfaceMetadata` →
`RealPty.probeWorkingDirectory`) reported the cwd of the **deepest readable foreground
descendant** (`deepestReadableDescendant(of:)`), not the shell. Any subprocess that cd's
elsewhere (a sub-build in `/tmp`, `cp` into `/Applications`, an agent in a sibling repo)
hijacked the session's displayed cwd. Because `Tab.cwd` drives the tab pill, git panel,
and file-tree root, all three desynced. The constant per-scan cwd writes also bumped the
daemon revision → reload storm → blank panel.

The model is **1 session = 1 worktree**: a session must stay pinned to where the *shell* is,
not follow transient children.

## Fix
`RealPty.probeWorkingDirectory()` now reads the shell's own cwd: `Self.cwd(for: childPID)`
instead of `Self.cwd(for: deepestReadableDescendant(of: pid) ?? pid)`. Removed the now-orphaned
`deepestReadableDescendant`. Genuine shell `cd` is still tracked (proc cwd of the shell pid
updates). `refreshCwdOnly` (500ms, `probeShellCwd`) already read the shell pid — comment fixed.

Files: `Packages/HarnessDaemon/.../RealPty.swift`, `SurfaceRegistry.swift`.

## Repro (deterministic, headless — no GUI needed)
1. `swift build --product HarnessDaemon`
2. Run daemon headless: `HARNESS_HOME=/tmp/x ./.build/debug/HarnessDaemon` (background)
3. `harness-cli new-session --workspace <id> --cwd <repoA> --name HT`
4. `harness-cli send --surface <HT> --text "bash -c 'cd <repoB> && sleep 8'\r"`
5. Poll `harness-cli list-surfaces --json` → before fix: HT.cwd = repoB (BUG); after: stays repoA.

Regression test: `RealPtyLifecycleTests.testProbeReportsShellCwdNotForegroundChild`
(gated by `HARNESS_LIVE_DAEMON_TESTS=1`).

## Lesson
When a value represents "where the user is" (worktree/session identity), probe the **shell**,
not the deepest descendant. Following descendants is right for "what command is running"
(`currentCommand`) but wrong for directory identity.
