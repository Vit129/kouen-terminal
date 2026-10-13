# Release runbook

Harness can be released from GitHub Actions on a hosted macOS runner. The
`Release Harness` workflow ([`.github/workflows/release.yml`](../.github/workflows/release.yml))
builds the app, signs it with Developer ID, notarizes the app and DMG, uploads the
DMG to GitHub Releases, generates a Sparkle appcast, and can optionally commit that
appcast to the website repository.

It runs on the `macos-26` runner with Xcode 26.6, the same runner and pinned
`XCODE_VERSION` as CI, so a release is built by the toolchain CI tested. Bump
`XCODE_VERSION` in `release.yml` and `ci.yml` together.

## Harness 2.3.2 (136)

This patch fixes daemon adoption after app updates, startup recovery, split-pane
movement and closure, stale terminal IO, and relocated GPU row caches. The
first-party coding agent remains in local development and is excluded from this
release's source, app, CLI and documentation. Existing integrations with installed
coding tools remain available.

See the [changelog](../CHANGELOG.md), [release validation](RELEASE-2.3.2.md), and
[terminal quality](TERMINAL-QUALITY.md). Version declarations and generated update
notes move together. Run CI on the shipping commit, then the release workflow with
`tag=v2.3.2` and `deploy_appcast=true`. The app and DMG must pass signing,
notarization and smoke testing before publication. The workflow verifies the
public download before updating either live appcast domain.

## One-time GitHub setup

Create a protected GitHub Environment named `release` and add required reviewers
before storing release secrets there. That keeps the signing material unavailable
until a human approves a release run.

Required environment secrets:

| Secret | Purpose |
| --- | --- |
| `SIGNING_CERTIFICATE_BASE64` | Base64-encoded `.p12` export for the Developer ID Application certificate. |
| `SIGNING_CERTIFICATE_PASSWORD` | Password for the `.p12` export. |
| `HISTORY_PROFILES_BASE64` | Base64-encoded gzip tar archive containing the four macOS shared-Keychain provisioning profiles at its root. |
| `SIGNING_IDENTITY` | Exact codesign identity, for example `Developer ID Application: Name (TEAMID)`. |
| `ASC_ISSUER_ID` | App Store Connect API issuer UUID. |
| `ASC_KEY_ID` | App Store Connect API key ID. |
| `ASC_PRIVATE_KEY` | Contents of the App Store Connect `AuthKey_<key-id>.p8` file. |
| `SPARKLE_EDDSA_PRIVATE_KEY` | Sparkle EdDSA private key matching `SUPublicEDKey` in `Info.plist`. |

Optional appcast deploy settings:

| Setting | Purpose |
| --- | --- |
| Environment variable `WEBSITE_REPOSITORY` | Website repository in `owner/name` form. The workflow writes `public/appcast.xml` there. |
| Secret `WEBSITE_DEPLOY_TOKEN` | Token with write access to `WEBSITE_REPOSITORY`. Use this only if `deploy_appcast` is enabled. |

The website deploy path assumes the website repository owns `thebestterminal.com` and
deploys after a push, for example through Vercel's Git integration. Keep
`harnesscli.dev` attached to the same production deployment as a compatibility
domain: versions before 2.1 still fetch their appcast from that address. Both
domains must serve the same signed feed so existing installations can upgrade. The DMG does
not need to be copied to the website: the generated appcast points Sparkle at
the GitHub Release asset URL for the matching tag.

The app requires signed feeds and verification before archive extraction, using
the existing `SUPublicEDKey`. `generate-appcast.sh` uses the resolved Sparkle tools
to generate and verify the signed feed. Never hand-edit signed XML; changes require
regeneration with the existing release key. See [Sparkle's signing settings](https://sparkle-project.org/documentation/customization/).

## Running a release from GitHub

1. Merge the code and version bump that should ship, and check that CI is green
   on that commit (see [CI](#ci) below).
2. Open **Actions -> Release Harness -> Run workflow**.
3. Select the release branch, normally `main`.
4. Enter `tag` (required): `vX.Y.Z` matching `CFBundleShortVersionString`, for
   example `v2.3.2`.
5. Optionally enter `release_name`; it defaults to `Harness <version> (<build>)`.
6. Enable `deploy_appcast` (default off) only after `WEBSITE_REPOSITORY` and
   `WEBSITE_DEPLOY_TOKEN` are configured.
7. Approve the `release` environment gate when GitHub asks.

The workflow validates the tag before signing anything: it must look like
`vX.Y.Z`, its version must match `CFBundleShortVersionString` in
`Apps/Harness/Sources/HarnessApp/Resources/Info.plist`, and
`HarnessVersion.short` / `HarnessVersion.build` must match the plist's
`CFBundleShortVersionString` / `CFBundleVersion`. If the version still says
`1.0.3`, a `v1.0.4` run fails fast and tells you to bump them first. It then
checks that every required secret is set (and, with `deploy_appcast`, the website
settings). Only one release runs at a time; a second dispatch queues behind it.

Bump `HarnessVersion.swift` (`short` + `build` in `Packages/HarnessCore`) in the
same commit as `Info.plist` — the daemon and CLI report versions from those
constants, and `Scripts/package-app.sh` + the workflow fail the build when the
two disagree (v1.3.0/v1.3.1 shipped daemons that reported 1.2.0). Edit the plist
as plain text; `PlistBuddy Set` re-serializes the whole file. Also move the
`CHANGELOG.md` `[Unreleased]` section under the new version heading, then run
`make release-notes` to regenerate the post-update banner's notes from the top
`CHANGELOG.md` block (`ReleaseNotesGuardTests` fails when they are stale).

After dispatching, verify the run's `headSha` equals the release-prep commit
before approving the `release` environment (a push that failed on a network
blip once left `workflow_dispatch` running from the OLD head). Known flake:
`hdiutil` "Resource busy" during DMG creation — rerun failed jobs and re-approve
the environment.

## What the workflow does

1. Reject a published version or an existing tag pointing to a different commit.
2. Build the app, verify package contents, sign and notarize the app, and create
   the DMG containing its already stapled ticket.
3. Create or resume a draft release. Sign, notarize and staple the final DMG,
   then generate its signed Sparkle appcast and `SHA256SUMS`.
4. Mount and copy the DMG to an isolated install location. Verify the app's
   signature, ticket, Gatekeeper assessment and arm64 helpers; load every bundled
   theme; launch it and require an attached terminal using the expected daemon
   and session-host build. Stop only this test's isolated service afterward.
5. Upload `Harness.dmg`, `appcast.xml` and `SHA256SUMS` to the draft and publish it.
6. Download the public DMG and appcast without authentication and compare their
   bytes with the verified artifacts.
7. With `deploy_appcast`, commit the signed feed to the website repository and
   verify that both `thebestterminal.com` and `harnesscli.dev` serve the exact feed.

The workflow retains the DMG, appcast, checksum and DMG notarization receipt as
its `harness-release-<tag>` artifact. Its temporary signing keychain is always
removed. The final DMG is notarized once; no archive is rebuilt after verification.

## Publication and recovery

Published versions and tags are immutable. A failed run before publication may
resume its draft at the same source commit. If publication succeeds but download
or website verification fails, keep the last live feed unchanged and recover the
existing release instead of rebuilding it:

1. Download that release's `Harness.dmg`, `SHA256SUMS` and `appcast.xml`.
2. Verify the checksum, signature and notarization of the downloaded artifact.
3. Copy the unchanged signed `appcast.xml` to the website's `public/appcast.xml`,
   commit and deploy it, then compare both live domains with the downloaded feed.

If artifact bytes must change, create a new version and build number. README
checksum or validation-document updates may land on `main` afterward; never move
the release tag to those later documentation commits. When `deploy_appcast` is
disabled, publish the verified feed only after the public download works.

## CI

[`.github/workflows/ci.yml`](../.github/workflows/ci.yml) runs on pushes to
`main` and `claude/**` branches and on pull requests:

| Job | Runner | What it checks |
| --- | --- | --- |
| Build & test (macOS) | `macos-26`, Xcode 26.6 | `swift build`, `swift build -c release`, and `swift test --enable-code-coverage` with `HARNESS_LIVE_DAEMON_TESTS=1`; exercises a real 2.1 upgrade and live session survival; uploads coverage. |
| Build & test (Linux, headless daemon) | `ubuntu-24.04`, `swift:6.0` container | Debug and release builds of the daemon, CLI, and pure libraries, then `swift test` with the live daemon tests. |
| Xcode project builds | `macos-26`, Xcode 26.6 | `xcodebuild` Debug build of the committed `Harness.xcodeproj`, so drift between `project.yml` and the targets is caught. |
| Manifest version agreement | `ubuntu-24.04` | The Sparkle version agrees across `Package.swift`, `project.yml`, and `project.pbxproj`. |
| Format lint (advisory) | `macos-26` | `swift format lint`; never blocks. |
| Benchmarks (non-blocking) | `macos-26` | `swift test -c release --filter HarnessBenchmarks`; never blocks. |

Releases build with SwiftPM (`make release`), so the macOS build-and-test job is
the one a release depends on.

## Local macOS CI

[Local macOS CI](LOCAL-MACOS-CI.md) documents the shared check script and manually
dispatched Tartelet runner workflow. Local Xcode 27 checks supplement the pinned
Xcode 26.6 shipping CI. Runner registration must be verified before dispatch.

## Local release path

The local path still works:

```bash
make release
SIGNING_IDENTITY="Developer ID Application: Name (TEAMID)" \
ASC_ISSUER_ID=... ASC_KEY_ID=... ASC_KEY=/path/to/AuthKey.p8 \
  make sign
make dmg
TAG=vX.Y.Z \
ASC_ISSUER_ID=... ASC_KEY_ID=... ASC_KEY=/path/to/AuthKey.p8 \
SPARKLE_EDDSA_PRIVATE_KEY_FILE=/path/to/sparkle-private-key \
DOWNLOAD_URL_PREFIX="https://github.com/robzilla1738/harness-terminal/releases/download/vX.Y.Z/" \
  make finalize
```

`make finalize` produces the final notarized DMG, signed appcast and checksum
locally. It does not publish files or change the website. Run `make smoke-dmg`,
then follow the publication order above. `Scripts/release-hotfix.sh --tag vX.Y.Z
--build N` can dispatch the protected workflow from a clean, already prepared
`main`; it waits for CI and never rewrites versions or published tags.
