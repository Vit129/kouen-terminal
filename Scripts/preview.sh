#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PREVIEW_HOME="$ROOT/.harness-preview"
APP="$PREVIEW_HOME/HarnessPreview.app"
mkdir -p "$PREVIEW_HOME"

# ─── Build (shared .build/debug output) ───────────────────────────────────────
# Only rebuild if sources are newer than the binary, or binary doesn't exist.
HARNESS_BIN="$ROOT/.build/debug/Harness"
if [[ ! -x "$HARNESS_BIN" ]] || [[ -n "$(find "$ROOT/Packages" "$ROOT/Apps" "$ROOT/Tools" -name '*.swift' -newer "$HARNESS_BIN" 2>/dev/null | head -n1)" ]]; then
  echo "Building debug..."
  swift build --product Harness
  swift build --product HarnessDaemon
  swift build --product harness-cli
else
  echo "Build up-to-date, skipping."
fi

BUILD_DIR="$ROOT/.build/debug"

# ─── Kill previous preview (ONLY preview, never prod) ─────────────────────────
pkill -f "$APP/Contents/MacOS/Harness" 2>/dev/null || true
pkill -f "$APP/Contents/MacOS/HarnessDaemon" 2>/dev/null || true
rm -f "$PREVIEW_HOME/harness.sock" "$PREVIEW_HOME/daemon.pid"

# ─── Package preview app bundle ───────────────────────────────────────────────
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$APP/Contents/Frameworks"
cp "$BUILD_DIR/Harness" "$APP/Contents/MacOS/Harness"
cp "$BUILD_DIR/HarnessDaemon" "$APP/Contents/MacOS/HarnessDaemon"
cp "$BUILD_DIR/harness-cli" "$APP/Contents/MacOS/harness-cli"
chmod +x "$APP/Contents/MacOS/"*
for bundle in "$BUILD_DIR"/*.bundle; do
  [[ -d "$bundle" ]] || continue
  ditto "$bundle" "$APP/Contents/Resources/$(basename "$bundle")"
done
FRAMEWORK="$BUILD_DIR/Sparkle.framework"
if [[ ! -d "$FRAMEWORK" ]]; then
  FRAMEWORK="$(find "$ROOT/.build/artifacts" "$ROOT/.build" -name Sparkle.framework -type d 2>/dev/null | head -n1 || true)"
fi
if [[ -z "$FRAMEWORK" || ! -d "$FRAMEWORK" ]]; then
  echo "error: Sparkle.framework not found under .build — build the Harness product first." >&2
  exit 1
fi
ditto "$FRAMEWORK" "$APP/Contents/Frameworks/Sparkle.framework"
if ! otool -l "$APP/Contents/MacOS/Harness" | grep -q "@executable_path/../Frameworks"; then
  install_name_tool -add_rpath "@executable_path/../Frameworks" "$APP/Contents/MacOS/Harness"
fi
if [[ -f "$ROOT/Apps/Harness/Resources/Harness.icns" ]]; then
  cp "$ROOT/Apps/Harness/Resources/Harness.icns" "$APP/Contents/Resources/Harness.icns"
fi
if [[ -f "$ROOT/Apps/Harness/Resources/HarnessLogo.png" ]]; then
  cp "$ROOT/Apps/Harness/Resources/HarnessLogo.png" "$APP/Contents/Resources/HarnessLogo.png"
fi
if [[ -d "$ROOT/Apps/Harness/Resources/Fonts" ]]; then
  ditto "$ROOT/Apps/Harness/Resources/Fonts" "$APP/Contents/Resources/Fonts"
fi
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>Harness</string>
  <key>CFBundleIconFile</key>
  <string>Harness</string>
  <key>CFBundleIdentifier</key>
  <string>com.robert.harness.preview</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>Harness Preview</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.0.0-preview</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>14.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>ATSApplicationFontsPath</key>
  <string>Fonts</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
  <key>HarnessPreviewHome</key>
  <string>$PREVIEW_HOME</string>
</dict>
</plist>
PLIST

codesign --force --sign - --deep "$APP" >/dev/null

# ─── Launch ───────────────────────────────────────────────────────────────────
# The app's DaemonLauncher detects HarnessPreviewHome and spawns an isolated
# daemon automatically — no need to pre-spawn one here.
cat <<EOF

Launching Harness Preview (isolated SIT environment).
State directory:  $PREVIEW_HOME
Socket:           $PREVIEW_HOME/harness.sock

Production app is NOT affected.

Preview CLI:
  HARNESS_HOME="$PREVIEW_HOME" "$BUILD_DIR/harness-cli" ping

EOF

if [[ "${PREVIEW_SIGNPOSTS:-0}" == "1" ]]; then
  open -n "$APP" --args -HARNESS_FRAME_SIGNPOSTS 1
else
  open -n "$APP"
fi
