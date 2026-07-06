# Release runbook

> **Fork notice:** this fork has no Developer ID cert, no appcast host, no
> website repo, and (as of the Kouen rename) no GitHub Actions release
> workflow either — that CI pipeline was removed since it depended on
> secrets this fork never had configured. Sparkle auto-update is disabled
> (`SparkleUpdater.swift`, `startingUpdater: false`).

## How this fork actually releases

1. Bump the version — `Apps/Kouen/Sources/KouenApp/Resources/Info.plist`
   (`CFBundleShortVersionString` / `CFBundleVersion`) **and**
   `Packages/KouenCore/Sources/KouenCore/KouenVersion.swift` (`short` / `build`)
   in the same commit — `Scripts/package-app.sh` fails the build if the two
   disagree (v1.3.0/v1.3.1 once shipped a daemon that still reported 1.2.0).
   Move the `CHANGELOG.md` `[Unreleased]` section under the new version
   heading, then regenerate the in-app "what's new" banner:
   `swift Scripts/generate-release-notes.swift` (or `make release-notes`).
2. `swift test`
3. `make install` — builds, packages, ad-hoc signs, and installs
   `/Applications/Kouen.app` locally, so you can sanity-check the actual
   build before tagging it.
4. `git tag -a vX.Y.Z -m "..." && git push origin vX.Y.Z`
5. `gh release create vX.Y.Z --latest --title "Kouen X.Y.Z" --notes "..."`
   — no DMG asset; this just marks the commit as the release point. Anyone
   installing builds from source (`git clone` + `make install`), so there's
   nothing to sign or notarize for that path.

## Full pipeline reference (not implemented in this fork)

The rest of this document describes the upstream project's own release
pipeline — Developer ID signing, notarization, a `Release Kouen` GitHub
Actions workflow, and a Sparkle appcast hosted at a website repo. None of
it exists in this fork right now (the workflow file and its
`Scripts/release-hotfix.sh` dispatcher were deleted). Kept as reference for
what a real release pipeline would need if this fork ever stands up its own
signing/hosting/auto-update — not a description of anything currently
runnable here.

Kouen could be released from GitHub Actions on a hosted macOS runner. A
`Release Kouen` workflow would build the app, sign it with Developer ID,
notarize the app and DMG, upload the DMG to GitHub Releases, generate a
Sparkle appcast, and optionally commit that appcast to the website
repository.

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

## If the workflow existed: running a release

1. Merge the code and version bump that should ship.
2. Open **Actions -> Release Kouen -> Run workflow**.
3. Select the release branch, normally `main`.
4. Enter a tag matching `CFBundleShortVersionString`, for example `v1.0.4`.
5. Enable `deploy_appcast` only after `WEBSITE_REPOSITORY` and
   `WEBSITE_DEPLOY_TOKEN` are configured.
6. Approve the `release` environment gate when GitHub asks.

The workflow would validate that the tag version matches `Info.plist` before
signing anything. If the version still said `1.0.3`, a `v1.0.4` run would fail
fast and ask you to bump `CFBundleShortVersionString` / `CFBundleVersion`
first — the same check `Scripts/package-app.sh` already does locally.

After dispatching, verify the run's `headSha` equals the release-prep commit
before approving the `release` environment (a push that failed on a network
blip once left `workflow_dispatch` running from the OLD head). Known flake:
`hdiutil` "Resource busy" during DMG creation — rerun failed jobs and
re-approve the environment.

## What that workflow would publish

- A GitHub Release for the requested tag, created at the workflow commit if one
  does not already exist.
- `Kouen.dmg`, uploaded or replaced on that GitHub Release.
- `dist/appcast.xml`, uploaded to the GitHub Release for audit/debugging.
- Optionally, `public/appcast.xml` in the website repository.

Installed apps would only see the update after `https://kouencli.dev/appcast.xml`
serves the new appcast. If `deploy_appcast` were disabled, `dist/appcast.xml`
would need publishing to the website manually before Sparkle auto-update
could find the release.

## Full local signing path (needs a Developer ID cert; not currently used)

If this fork ever gets a Developer ID cert, the full sign/notarize/DMG/appcast
path can run entirely locally, no CI needed:

```bash
make release
SIGNING_IDENTITY="Developer ID Application: Name (TEAMID)" \
ASC_ISSUER_ID=... ASC_KEY_ID=... ASC_KEY=/path/to/AuthKey.p8 \
  make sign
make dmg
TAG=vX.Y.Z \
ASC_ISSUER_ID=... ASC_KEY_ID=... ASC_KEY=/path/to/AuthKey.p8 \
SPARKLE_EDDSA_PRIVATE_KEY_FILE=/path/to/sparkle-private-key \
DOWNLOAD_URL_PREFIX="https://github.com/Vit129/kouen-terminal/releases/download/vX.Y.Z/" \
  make finalize
```

Without `SPARKLE_EDDSA_PRIVATE_KEY_FILE`, Sparkle falls back to the private key in
the login keychain and may show an interactive "Allow" prompt.
