#!/usr/bin/env bash
set -euo pipefail
# Finalize a Harness release: notarize the (already Developer-ID-signed) DMG, staple it,
# generate the Sparkle appcast and checksum, and leave publication to release.yml.
# This step needs an Apple credential and a Sparkle signing key —
# secrets that intentionally live with the human or a protected CI environment, not the repo.
#
# Prereq: ./Scripts/build-release.sh && SIGNING_IDENTITY=… ./Scripts/sign-and-notarize.sh && \
#         ./Scripts/create-dmg.sh   (in that order) so the DMG contains the stapled app.
#
# Auth — provide ONE of:
#   App Store Connect API key (recommended):
#     ASC_ISSUER_ID=<issuer-uuid>            # App Store Connect → Users and Access → Integrations → Keys
#     ASC_KEY_ID=<key-id>                    # required when ASC_ISSUER_ID is set (no baked-in default)
#     ASC_KEY=~/Downloads/AuthKey_<ASC_KEY_ID>.p8   # defaults to ~/Downloads/AuthKey_<ASC_KEY_ID>.p8
#   …or an Apple ID app-specific password:
#     APPLE_ID=you@example.com APPLE_TEAM_ID=<team-id> APPLE_APP_PASSWORD=xxxx-xxxx-xxxx-xxxx
#
# Optional (all default sensibly — no personal values are hardcoded):
#   TAG=vX.Y.Z                               # release tag; defaults to v<CFBundleShortVersionString>
#   SIGNING_IDENTITY="Developer ID Application: …"  # defaults to the identity that signed Harness.app
#   DOWNLOAD_URL_PREFIX=https://github.com/<owner>/<repo>/releases/download/<tag>/
#                                             # appcast enclosure URL prefix
#   SPARKLE_EDDSA_PRIVATE_KEY_FILE=/path/to/private-key
#                                             # use Sparkle's --ed-key-file mode instead of keychain
#
# Usage:  ASC_ISSUER_ID=<uuid> ASC_KEY_ID=<key-id> ./Scripts/finalize-release.sh

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
APP="$ROOT/Harness.app"
DMG="$ROOT/Harness.dmg"

[[ -d "$APP" ]] || { echo "Harness.app missing — run build-release.sh + sign-and-notarize.sh + create-dmg.sh first." >&2; exit 1; }
[[ -f "$DMG" ]] || { echo "Harness.dmg missing — run create-dmg.sh first." >&2; exit 1; }

# Single-source the version: derive it (and the default release TAG) from the *built* app's
# Info.plist — the one thing that's authoritative about what's actually being shipped — instead of
# hardcoding a literal that silently drifts from the bundle on every bump.
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist" 2>/dev/null || true)"
[[ -n "$VERSION" ]] || { echo "Could not read CFBundleShortVersionString from $APP/Contents/Info.plist" >&2; exit 1; }
TAG="${TAG:-v$VERSION}"
[[ "$TAG" == "v$VERSION" ]] || { echo "TAG must match the built app version." >&2; exit 1; }

# Sign the final DMG with the app's Developer ID identity.
SIGNING_IDENTITY="${SIGNING_IDENTITY:-$(codesign -dvv "$APP" 2>&1 | awk -F= '/^Authority=Developer ID Application/{print substr($0, index($0, "=") + 1); exit}')}"
[[ -n "$SIGNING_IDENTITY" ]] || { echo "Set SIGNING_IDENTITY (could not read it from $APP's signature)." >&2; exit 1; }

# Build the notarytool auth args from whichever credential set is present.
NOTARY_AUTH=()
if [[ -n "${ASC_ISSUER_ID:-}" ]]; then
  KEY_ID="${ASC_KEY_ID:?Set ASC_KEY_ID to your App Store Connect API key id when using ASC_ISSUER_ID}"
  KEY="${ASC_KEY:-$HOME/Downloads/AuthKey_${KEY_ID}.p8}"
  [[ -f "$KEY" ]] || { echo "API key not found: $KEY" >&2; exit 1; }
  NOTARY_AUTH=(--key "$KEY" --key-id "$KEY_ID" --issuer "$ASC_ISSUER_ID")
  echo "Notarizing with App Store Connect API key $KEY_ID (issuer $ASC_ISSUER_ID)."
elif [[ -n "${APPLE_ID:-}" && -n "${APPLE_TEAM_ID:-}" && -n "${APPLE_APP_PASSWORD:-}" ]]; then
  NOTARY_AUTH=(--apple-id "$APPLE_ID" --team-id "$APPLE_TEAM_ID" --password "$APPLE_APP_PASSWORD")
  echo "Notarizing with Apple ID $APPLE_ID (team $APPLE_TEAM_ID)."
else
  cat >&2 <<'MSG'
No notarization credentials. Set EITHER:
  ASC_ISSUER_ID=<issuer-uuid>  [ASC_KEY_ID=…] [ASC_KEY=…]      (App Store Connect API key)
or:
  APPLE_ID=…  APPLE_TEAM_ID=9F2JXY8TCK  APPLE_APP_PASSWORD=…   (Apple ID app-specific password)
MSG
  exit 1
fi

# The app must already carry its ticket before it is copied into the DMG.
xcrun stapler validate "$APP"
codesign --verify --deep --strict "$APP"
spctl --assess --type execute --verbose "$APP"

echo "==> Signing and notarizing the final DMG…"
codesign --force --sign "$SIGNING_IDENTITY" --timestamp "$DMG"
mkdir -p "$ROOT/dist"
xcrun notarytool submit "$DMG" "${NOTARY_AUTH[@]}" --wait --output-format json > "$ROOT/dist/dmg-notarization.json"
python3 - "$ROOT/dist/dmg-notarization.json" <<'PYNOTARY'
import json, sys
result = json.load(open(sys.argv[1]))
print("DMG notarization:", result["id"], result["status"])
if result["status"] != "Accepted":
    raise SystemExit("DMG notarization was not accepted; inspect the submission log.")
PYNOTARY
xcrun stapler staple "$DMG"
codesign --verify --strict "$DMG"
spctl -a -t open --context context:primary-signature -v "$DMG"
xcrun stapler validate "$DMG"

cp "$DMG" "$ROOT/dist/Harness.dmg"
"$ROOT/Scripts/generate-appcast.sh" "$ROOT/dist"
shasum -a 256 Harness.dmg > "$ROOT/dist/SHA256SUMS"
echo "Final artifacts ready for $TAG. Smoke-test, publish and verify the download before deploying dist/appcast.xml."
