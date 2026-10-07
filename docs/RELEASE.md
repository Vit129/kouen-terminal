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
3. `make install-graceful` — builds, packages, ad-hoc signs, and installs
   `/Applications/Kouen.app` locally, so you can sanity-check the actual
   build before tagging it.
4. `git tag -a vX.Y.Z -m "..." && git push origin vX.Y.Z`
5. `gh release create vX.Y.Z --latest --title "Kouen X.Y.Z" --notes "..."`
   — no DMG asset; this just marks the commit as the release point. Anyone
   installing builds from source (`git clone` + `make install-graceful`), so there's
   nothing to sign or notarize for that path.

## Scripted flow

`Scripts/full-cycle.sh [patch|minor|major] [--version X.Y.Z] [--build N] [--no-bump]` (menu: `make start`)
runs steps 1–5 above in order: verify the build, bump the version (rolled back if the build fails),
commit/push/merge via `commit-push-merge.sh`, graceful install (`install-graceful.sh`), then regenerate
`CHANGELOG.md` with git-cliff and create the tag and GitHub release. Older minor versions roll into
`docs/CHANGELOG-archive.md` automatically. The run ends by comparing the running daemon's build with
the app's; on mismatch it offers to run `kouen-cli install`.

## Full local signing path (needs a Developer ID cert; not currently used)

The Makefile still carries the sign/notarize/DMG/appcast targets for a fork that gets a Developer ID
cert. They run locally, no CI needed:

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

`sign`/`dmg` operate on the existing `Kouen.app` and must not re-run `release`. Without
`SPARKLE_EDDSA_PRIVATE_KEY_FILE`, Sparkle falls back to the login-keychain key and may show an
interactive "Allow" prompt.
