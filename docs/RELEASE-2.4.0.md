# Harness 2.4.0 validation

Version 2.4.0, build 137, adds appearance, typography, file-link and key binding
controls, and makes app updates settle cleanly. The first-party coding agent remains
local development work and is excluded from the release source and packaged app.
Existing third-party coding-tool integrations remain available. Public protocol 2,
private session-host protocol 10 and terminal checkpoint schema 2 are unchanged, so
an update from 2.3.2 replaces the application daemon without interrupting shells.

## Update behavior

Crash reports and launchd state from installed 2.3.2 builds showed two problems
after updates:

- Every stop ended in a crash. Signal and parent-loss handlers were closures in the
  helpers' top-level code, so they inherited main-actor isolation while running on
  background queues, and Swift's isolation check trapped. Both helpers now use
  nonisolated functions and exit with status 0 on `SIGTERM`.
- When the app started its own service first, the launchd job found the lock held,
  exited with an error and was relaunched every five seconds. A helper that finds a
  live owner now exits successfully, and reconnecting kickstarts a loaded but idle
  launchd job so the service stays supervised. Session-service startup removes
  control sockets left behind by crashed workers.

The old 2.3.2 helpers still contain the crashing handler, so the first update can
record one crash report when they are replaced.

## Local verification

Verified on Apple silicon with macOS 27.0.1 and Swift 6.4:

- Swift debug build, optimized release build and the committed Xcode project
  (code signing disabled) built successfully. Changed-line lint is clean.
- The complete Swift suite with live socket and PTY fixtures executed 2,577 tests
  with 67 skipped. Its single failure was the release-notes guard, which ran while
  the changelog was being edited; the guard's four tests pass against the
  committed changelog and generated notes.
- In an isolated `HARNESS_HOME`, the daemon and session host each exited with
  status 0 on `SIGTERM`. A second session host started against a live owner exited
  with status 0, and a stale worker socket was removed at startup.
- Focused suites passed: daemon lifecycle (10), daemon launcher (6), launch agent
  installer (3), session-host wire (7) and live session-host signal tests (2).

Skips are opt-in performance benchmarks and fixtures that need tools or targets not
configured on this machine. Automated fixtures do not replace a human check of
Settings or an update installed through Sparkle from 2.3.2.

## Published artifact checks

The [release workflow](../.github/workflows/release.yml) builds with Xcode 26.6 on
macOS 26 and requires successful CI for the exact source commit before creating a
release draft. It verifies Developer ID signatures, notarizes and staples the app
and DMG, checks Gatekeeper acceptance and smoke-tests the installed DMG in an
isolated home before publishing downloads and updating the signed feeds on both
supported domains. Published assets and their source tag must never be replaced;
recovery uses the existing matching appcast or a new release version.
