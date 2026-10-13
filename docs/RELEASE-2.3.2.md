# Harness 2.3.2 validation

Version 2.3.2, build 136, contains terminal and release reliability changes. The
first-party coding agent remains local development work and is excluded from the
release source and packaged app. Existing third-party coding-tool integrations
remain available. Public protocol 2, private session-host protocol 10 and terminal
checkpoint schema 2 are unchanged.

## Local verification

Verified on Apple silicon with macOS 27.0.1 and Swift 6.4:

- Swift debug build, optimized release build and unsigned app assembly passed.
- The committed Xcode project built successfully with code signing disabled.
- The complete Swift suite discovered 2,543 tests across 15 modules: 2,484 passed,
  59 skipped and no failures. Live socket and PTY fixtures were enabled.
- Nine native pane-layout tests cover persistent view identity and focus, animated
  movement, interrupted transitions, hit testing, geometry, content changes and
  header configurations. Two real-process pane lifecycle tests cover retained
  closing views and resize requests arriving during the final output drain.
- Native disclosure-button clicks and accessibility presses both toggle the
  section and expose its expanded state correctly.
- Six daemon-launcher regressions cover healthy services, missing workers, uncertain
  replacement receipts, failed adoption and incompatible owners with live programs.
- The actual 2.1.0 upgrade fixture preserved programs without authorization, then
  performed an explicit isolated restart into 2.3.2 with saved session identities.
- Session-survival validation preserved shell identity, environment, background
  jobs, output attachments, pipe consumers and activity through daemon replacement
  and crash recovery. Failed candidate activation rolled back safely; guarded
  restart, owner-loss recovery and MCP isolation checks passed.
- The assembled app and all three helper executables are arm64, agree on version
  2.3.2/136, and contain no first-party agent executable or package.
- Release scripts passed shell syntax checks, workflow YAML parsed successfully,
  and the release helper's dry run accepted the matching version declarations.
- A disposable signing fixture generated and verified an appcast with the pinned
  Sparkle tools. Altering its signed content was rejected. The test did not access
  the production signing key.
- A CI replay-test failure was traced to macOS PTY newline conversion repeating a
  carriage return under backpressure. An independent shell/PTY fixture reproduced
  it without Harness. The replay fixture now emits exact CRLF bytes with output
  postprocessing disabled, preserving its checks for all 20,000 lines and contiguous
  byte sequences. Failure diagnostics report malformed lines without overflowing
  log viewers. All 24 daemon round-trip tests passed with coverage enabled.
- The snapshot fixture waits for asynchronous subscriber delivery before checking
  its output. Ring insertion alone does not imply delivery has completed.
- HTTP fixture startup has its own readiness deadline, exits promptly on server
  failure and reports the server log. Service-operation deadlines remain unchanged.

A separate optimized performance run enabled the benchmarks: 51 passed, with
three display-drawable fluidity measurements skipped. The normal-suite skips
comprise 54 opt-in performance benchmarks, a theme-data exporter,
two tests requiring an uninstalled font, an unsupported system Bash version and a
test requiring a separately configured SSH target. Automated native fixtures do not
replace a human evaluation of animation feel or a previous-version Sparkle install.

## Published artifact checks

The [release workflow](../.github/workflows/release.yml) builds with Xcode 26.6 on
macOS 26 and requires successful CI for the exact source commit before creating a
release draft. It verifies Developer ID signatures, notarizes and
staples the app and DMG, and checks Gatekeeper acceptance. Its DMG smoke test requires
a live terminal attached to the expected daemon and session-host build in an
isolated home. The workflow publishes downloads before comparing their public
bytes and updating the signed feeds on both supported domains. The app requires
signed-feed authentication and archive verification before extraction; generation
and verification use the same resolved Sparkle tools as the app.

The [GitHub release](https://github.com/robzilla1738/harness-terminal/releases/tag/v2.3.2)
retains the download, appcast and `SHA256SUMS`. The workflow retains the notarization
receipt. Published assets and their source tag must never be replaced; recovery
uses the existing matching appcast or a new release version.

## Publication receipts

- Release source: `2f843e5625086fbd33e58a724c632e47bfe66d1d`, tagged `v2.3.2`.
- [Shipping CI](https://github.com/robzilla1738/harness-terminal/actions/runs/38366177399)
  passed all six jobs, including the real legacy-upgrade and session-survival
  proofs. macOS CI ran 2,543 tests: 2,482 passed, 61 skipped, no failures. Its two
  additional skips require tmux and fish, which were available for the local run.
- The [release workflow](https://github.com/robzilla1738/harness-terminal/actions/runs/38366241696)
  passed, including the installed-DMG smoke test and exact live-feed comparisons.
- An independent unauthenticated download passed 42 artifact checks: DMG integrity,
  Developer ID signatures, stapled app and DMG tickets, Gatekeeper acceptance,
  version/build agreement, arm64 helpers, first-party-agent exclusion, and Ed25519
  verification of both the archive and feed using the app's public key.
- DMG notarization request `a587720a-74c1-406e-8d7c-8bb977eeadb6` was accepted.
  The public DMG exactly matches the workflow artifact and GitHub's asset digest.
- Both supported appcast domains served the exact published signed feed.
- [Website CI](https://github.com/robzilla1738/harness-website/actions/runs/38369601344)
  passed its tests, dependency audit, production build and SEO checks. The live
  documentation and machine-readable index identify 2.3.2; source links resolve
  to the shipping commit. Both appcasts remained unchanged after that deployment.

`Harness.dmg` is 36,456,579 bytes. Its SHA-256 is:

```text
4e230a4e142a51a160b1323b3d7b4e52421d8ca18113c2aff080d14beb99b6e2
```
