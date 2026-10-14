# Harness 2.4.1 validation

Version 2.4.1, build 138, fixes main-thread stalls during window resizing and groups
the host icon, name and arrow in a native AppKit menu control. Public protocol 2,
session-host protocol 10 and terminal checkpoint schema 2 are unchanged.

## Local verification

- Renderer, terminal-kit and app suites executed 566 tests with four skipped and no
  failures. The skips require an unavailable font or opt-in session-host fixtures.
- Five focused tab-spacing and dragging tests pass with the native host control.
- Debug preview build, changed-line lint and `git diff --check` pass.
- Isolated GUI stress runs cover idle and streaming terminals, split panes and deep
  history. Main-thread Metal drawable and GPU scheduling waits found in 2.4.0 are
  absent in the patched samples. See the [investigation](window-resize-stalls-2026-10-13.md)
  for methods, measurements and their limits.

## Publication checks

The release workflow requires successful main-branch CI for the exact source commit,
verifies Developer ID signatures, notarizes and staples the app and DMG, checks
Gatekeeper acceptance, and tests an isolated installation of the DMG. It compares
public downloads with the tested artifacts before updating the signed feeds on
both supported domains. Publication receipts are recorded after those checks pass.
