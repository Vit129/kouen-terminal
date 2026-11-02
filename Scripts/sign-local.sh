#!/usr/bin/env bash
# Sign an app bundle for installing on this Mac. An ad-hoc signature identifies a binary by
# its hash, so every rebuild loses its macOS privacy grants (TCC). A certificate plus a fixed
# identifier keeps the same identity across rebuilds. Distribution builds use
# sign-and-notarize.sh instead.
#
# Usage: Scripts/sign-local.sh <path/to/Kouen.app>
# KOUEN_SIGN_IDENTITY overrides the identity; "-" forces ad-hoc.
set -euo pipefail

APP="${1:?Usage: Scripts/sign-local.sh <path/to/Kouen.app>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENTITLEMENTS="$ROOT/Kouen.entitlements"

IDENTITY="${KOUEN_SIGN_IDENTITY:-$(security find-identity -v -p codesigning 2>/dev/null \
  | awk '/"Apple Development:/ {print $2; exit}')}"

if [[ -z "$IDENTITY" || "$IDENTITY" == "-" ]]; then
  echo "warning: no signing certificate; ad-hoc signing, macOS privacy permissions will reset on each rebuild." >&2
  codesign --force --sign - --deep "$APP" >/dev/null
  exit 0
fi

# Inside-out, not --deep: --deep would re-sign the tools below and drop their identifiers.
SPARKLE="$APP/Contents/Frameworks/Sparkle.framework"
if [[ -d "$SPARKLE" ]]; then
  for component in \
    "$SPARKLE"/Versions/*/XPCServices/*.xpc \
    "$SPARKLE"/Versions/*/Updater.app \
    "$SPARKLE"/Versions/*/Autoupdate; do
    [[ -e "$component" ]] && codesign --force --sign "$IDENTITY" "$component" >/dev/null
  done
  codesign --force --sign "$IDENTITY" "$SPARKLE" >/dev/null
fi

for tool in KouenDaemon:daemon kouen-cli:cli kouen-mcp:mcp; do
  binary="$APP/Contents/MacOS/${tool%%:*}"
  [[ -e "$binary" ]] || continue
  codesign --force --sign "$IDENTITY" --identifier "com.vit129.kouen.${tool##*:}" \
    --entitlements "$ENTITLEMENTS" "$binary" >/dev/null
done

codesign --force --sign "$IDENTITY" --entitlements "$ENTITLEMENTS" "$APP" >/dev/null
codesign --verify --deep --strict "$APP"
