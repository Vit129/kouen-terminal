#!/usr/bin/env bash
set -euo pipefail
CONFIG="${1:-release}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT/.build/$CONFIG"
APP="$ROOT/Harness.app"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"

cp "$BUILD_DIR/Harness" "$APP/Contents/MacOS/Harness"
cp "$BUILD_DIR/HarnessDaemon" "$APP/Contents/MacOS/HarnessDaemon"
cp "$BUILD_DIR/harness-cli" "$APP/Contents/MacOS/harness-cli"
cp "$ROOT/Apps/Harness/Sources/HarnessApp/Resources/Info.plist" "$APP/Contents/Info.plist"

# SwiftPM resource bundles (for example HarnessTheme's bundled themes.json) are
# emitted next to the built products. The app is assembled by this script rather
# than by Xcode, so copy those bundles into Contents/Resources explicitly.
for bundle in "$BUILD_DIR"/*.bundle; do
  [[ -d "$bundle" ]] || continue
  ditto "$bundle" "$APP/Contents/Resources/$(basename "$bundle")"
done

# Embed Sparkle.framework (the only external dependency, GUI-only). SwiftPM links it via
# `@rpath`, so the app binary needs an rpath into Contents/Frameworks. `ditto` preserves the
# framework's version symlinks + nested code signatures (a plain `cp` would flatten them).
FRAMEWORK="$BUILD_DIR/Sparkle.framework"
if [[ -d "$FRAMEWORK" ]]; then
  mkdir -p "$APP/Contents/Frameworks"
  ditto "$FRAMEWORK" "$APP/Contents/Frameworks/Sparkle.framework"
  if ! otool -l "$APP/Contents/MacOS/Harness" | grep -q "@executable_path/../Frameworks"; then
    install_name_tool -add_rpath "@executable_path/../Frameworks" "$APP/Contents/MacOS/Harness"
  fi
else
  echo "warning: $FRAMEWORK not found — build the Harness product first (Sparkle won't load)." >&2
fi

ICON="$ROOT/Apps/Harness/Resources/Harness.icns"
if [[ ! -f "$ICON" ]]; then
  "$ROOT/Scripts/generate-app-icon.sh"
fi
cp "$ICON" "$APP/Contents/Resources/Harness.icns"

# Transparent brand logo for onboarding + settings (loaded via Bundle.main).
LOGO="$ROOT/Apps/Harness/Resources/HarnessLogo.png"
if [[ -f "$LOGO" ]]; then
  cp "$LOGO" "$APP/Contents/Resources/HarnessLogo.png"
fi

chmod +x "$APP/Contents/MacOS/"*

echo "Created $APP"
