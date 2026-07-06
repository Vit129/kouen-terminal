# Release runbook

> **Fork notice:** this describes the upstream project's own release pipeline —
> Developer ID signing, notarization, and a Sparkle appcast hosted at
> `kouencli.dev` — none of which this fork has (no Developer ID cert, no
> appcast host, no website repo). This fork's releases are plain
> `git tag` + `gh release create`; Sparkle auto-update is disabled
> (`SparkleUpdater.swift`, `startingUpdater: false`). Keep this doc as
> reference for what a real release pipeline would need if this fork ever
> stands up its own signing/hosting.

Kouen can be released from GitHub Actions on a hosted macOS runner. The
`Release Kouen` workflow builds the app, signs it with Developer ID, notarizes
the app and DMG, uploads the DMG to GitHub Releases, generates a Sparkle appcast,
and can optionally commit that appcast to the website repository.

## One-time GitHub setup

Create a protected GitHub Environment named `release` and add required reviewers
before storing release secrets there. That keeps the signing material unavailable
until a human approves a release run.

Required environment secrets:

| Secret | Purpose |
| --- | --- |
| `SIGNING_CERTIFICATE_BASE64` | Base64-encoded `.p12` export for the Developer ID Application certificate. |
| `SIGNING_CERTIFICATE_PASSWORD` | Password for the `.p12` export. |
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

The website deploy path assumes the website repository owns `kouencli.dev` and
deploys after a push, for example through Vercel's Git integration. The DMG does
not need to be copied to the website: the generated appcast points Sparkle at
the GitHub Release asset URL for the matching tag.

## Running a release from GitHub

1. Merge the code and version bump that should ship.
2. Open **Actions -> Release Kouen -> Run workflow**.
3. Select the release branch, normally `main`.
4. Enter a tag matching `CFBundleShortVersionString`, for example `v1.0.4`.
5. Enable `deploy_appcast` only after `WEBSITE_REPOSITORY` and
   `WEBSITE_DEPLOY_TOKEN` are configured.
6. Approve the `release` environment gate when GitHub asks.

The workflow validates that the tag version matches `Info.plist` before signing
anything. If the version still says `1.0.3`, a `v1.0.4` run fails fast and tells
you to bump `CFBundleShortVersionString` / `CFBundleVersion` first.

Bump `KouenVersion.swift` (`short` + `build` in `Packages/KouenCore`) in the
same commit as `Info.plist` — the daemon and CLI report versions from those
constants, and `Scripts/package-app.sh` + the workflow fail the build when the
two disagree (v1.3.0/v1.3.1 shipped daemons that reported 1.2.0). Edit the plist
as plain text; `PlistBuddy Set` re-serializes the whole file. Also move the
`CHANGELOG.md` `[Unreleased]` section under the new version heading.

After dispatching, verify the run's `headSha` equals the release-prep commit
before approving the `release` environment (a push that failed on a network
blip once left `workflow_dispatch` running from the OLD head). Known flake:
`hdiutil` "Resource busy" during DMG creation — rerun failed jobs and re-approve
the environment.

## What the workflow publishes

- A GitHub Release for the requested tag, created at the workflow commit if one
  does not already exist.
- `Kouen.dmg`, uploaded or replaced on that GitHub Release.
- `dist/appcast.xml`, uploaded to the GitHub Release for audit/debugging.
- Optionally, `public/appcast.xml` in the website repository.

Installed apps only see the update after `https://kouencli.dev/appcast.xml`
serves the new appcast. If `deploy_appcast` is disabled, manually publish
`dist/appcast.xml` to the website before expecting Sparkle auto-update to find
the release.

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

Without `SPARKLE_EDDSA_PRIVATE_KEY_FILE`, Sparkle falls back to the private key in
the login keychain and may show an interactive "Allow" prompt.
