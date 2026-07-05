#!/usr/bin/env bash
set -euo pipefail
# Generate / refresh a Sparkle appcast — inherited from upstream, where it's hosted at
# harnesscli.dev. This fork has no appcast host or EdDSA signing key of its own yet:
# SUFeedURL/SUPublicEDKey were removed from Info.plist and SparkleUpdater starts with
# startingUpdater: false, so nothing in this fork currently checks or serves an appcast.
# Kept as reference for what standing up a real feed would need.
#
# Sparkle's `generate_appcast` scans a directory of release archives (.dmg / .zip), EdDSA-signs
# each with a private key matching whatever SUPublicEDKey this fork eventually configures, and
# writes appcast.xml into that same directory, embedding the signature + version of each build.
#
# Usage:  ./Scripts/generate-appcast.sh [archives-dir]
#   archives-dir defaults to ./dist  (drop the signed, notarized Harness.dmg there first).
#
# Optional:
#   SPARKLE_EDDSA_PRIVATE_KEY_FILE=/path/to/private-key
#     Use Sparkle's --ed-key-file mode instead of the login keychain. This is preferred for
#     headless CI runners where keychain access prompts are not possible.
#   DOWNLOAD_URL_PREFIX=https://github.com/<owner>/<repo>/releases/download/<tag>/
#     Override where Sparkle downloads archives from.
#
# Publish: upload the resulting appcast.xml to https://harnesscli.dev/appcast.xml and ensure
# the enclosure URLs written by DOWNLOAD_URL_PREFIX resolve to the matching archive(s).

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCHIVES="${1:-$ROOT/dist}"
# Where the archives are hosted. Enclosure URLs in the appcast are made absolute against
# this so Sparkle downloads from the site no matter where appcast.xml itself is fetched
# from. Override with DOWNLOAD_URL_PREFIX if you host downloads on a subpath/CDN.
DOWNLOAD_URL_PREFIX="${DOWNLOAD_URL_PREFIX:-https://harnesscli.dev/}"

# Locate generate_appcast: prefer PATH, else the resolved Sparkle SPM artifact, else Homebrew.
GEN="$(command -v generate_appcast || true)"
if [[ -z "$GEN" ]]; then
  GEN="$(find "$ROOT/.build" -type f -name generate_appcast -perm -111 2>/dev/null | head -1 || true)"
fi
if [[ -z "$GEN" && -x "/opt/homebrew/Caskroom/sparkle/latest/bin/generate_appcast" ]]; then
  GEN="/opt/homebrew/Caskroom/sparkle/latest/bin/generate_appcast"
fi
if [[ -z "$GEN" ]]; then
  echo "generate_appcast not found." >&2
  echo "Run 'swift package resolve' (Sparkle ships the tool under .build), or 'brew install --cask sparkle'." >&2
  exit 1
fi

if [[ ! -d "$ARCHIVES" ]]; then
  echo "Archives dir not found: $ARCHIVES" >&2
  echo "Create it and drop the signed Harness.dmg (or .zip) inside, then re-run." >&2
  exit 1
fi

echo "Using:    $GEN"
echo "Scanning: $ARCHIVES"
echo "URLs:     ${DOWNLOAD_URL_PREFIX}<archive>"
GEN_ARGS=(--download-url-prefix "$DOWNLOAD_URL_PREFIX")
if [[ -n "${SPARKLE_EDDSA_PRIVATE_KEY_FILE:-}" ]]; then
  [[ -f "$SPARKLE_EDDSA_PRIVATE_KEY_FILE" ]] || {
    echo "Sparkle private key file not found: $SPARKLE_EDDSA_PRIVATE_KEY_FILE" >&2
    exit 1
  }
  GEN_ARGS+=(--ed-key-file "$SPARKLE_EDDSA_PRIVATE_KEY_FILE")
fi
"$GEN" "${GEN_ARGS[@]}" "$ARCHIVES"
echo ""
echo "Wrote $ARCHIVES/appcast.xml"
echo "Next: upload appcast.xml to https://harnesscli.dev/appcast.xml and keep the archive URLs live."
