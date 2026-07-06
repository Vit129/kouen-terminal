#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PREVIEW_HOME="$ROOT/.kouen-preview"
APP="$PREVIEW_HOME/KouenPreview.app"
mkdir -p "$PREVIEW_HOME"

# KOUEN_HOME (and therefore the control socket path) must fit inside
# sockaddr_un.sun_path (103 bytes on Darwin). A worktree checkout under
# .claude/worktrees/<random-name> can push "$PREVIEW_HOME/kouen.sock" over
# that limit, so keep the actual runtime state in a short, stable path under
# /tmp keyed off $ROOT instead of inside the repo.
PREVIEW_KOUEN_HOME="/tmp/kouen-preview-$(printf '%s' "$ROOT" | md5 | cut -c1-10)"
mkdir -p "$PREVIEW_KOUEN_HOME"

xml_escape() {
  local value="${1:-}"
  value="${value//&/&amp;}"
  value="${value//</&lt;}"
  value="${value//>/&gt;}"
  value="${value//\"/&quot;}"
  value="${value//\'/&apos;}"
  printf '%s' "$value"
}

GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || printf 'unknown')"
GIT_SHA="$(git rev-parse --short HEAD 2>/dev/null || printf 'unknown')"
GIT_SUBJECT="$(git log -1 --pretty=%s 2>/dev/null || printf 'no git commit')"
GIT_DIRTY=""
if [[ -n "$(git status --short 2>/dev/null || true)" ]]; then
  GIT_DIRTY="+dirty"
fi
PREVIEW_BUILT_AT="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
PREVIEW_TASK_LABEL="${KOUEN_PREVIEW_TASK:-${PREVIEW_TASK:-}}"
if [[ -n "$PREVIEW_TASK_LABEL" ]]; then
  PREVIEW_BUILD_LABEL="$PREVIEW_TASK_LABEL · $GIT_BRANCH@$GIT_SHA$GIT_DIRTY"
else
  PREVIEW_BUILD_LABEL="$GIT_BRANCH@$GIT_SHA$GIT_DIRTY · $GIT_SUBJECT"
fi

# ─── Build (shared .build/debug output) ───────────────────────────────────────
# Only rebuild if sources are newer than the binary, or binary doesn't exist.
KOUEN_BIN="$ROOT/.build/debug/Kouen"
if [[ ! -x "$KOUEN_BIN" ]] || [[ -n "$(find "$ROOT/Packages" "$ROOT/Apps" "$ROOT/Tools" -name '*.swift' -newer "$KOUEN_BIN" 2>/dev/null | head -n1)" ]]; then
  echo "Building debug..."
  swift build --product Kouen
  swift build --product KouenDaemon
  swift build --product kouen-cli
else
  echo "Build up-to-date, skipping."
fi

BUILD_DIR="$ROOT/.build/debug"

# ─── Kill previous preview (ONLY preview, never prod) ─────────────────────────
pkill -f "$APP/Contents/MacOS/Kouen" 2>/dev/null || true
pkill -f "$APP/Contents/MacOS/KouenDaemon" 2>/dev/null || true
rm -f "$PREVIEW_KOUEN_HOME/kouen.sock" "$PREVIEW_KOUEN_HOME/daemon.pid"

# ─── Package preview app bundle ───────────────────────────────────────────────
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$APP/Contents/Frameworks"
cp "$BUILD_DIR/Kouen" "$APP/Contents/MacOS/Kouen"
cp "$BUILD_DIR/KouenDaemon" "$APP/Contents/MacOS/KouenDaemon"
cp "$BUILD_DIR/kouen-cli" "$APP/Contents/MacOS/kouen-cli"
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
  echo "error: Sparkle.framework not found under .build — build the Kouen product first." >&2
  exit 1
fi
ditto "$FRAMEWORK" "$APP/Contents/Frameworks/Sparkle.framework"
if ! otool -l "$APP/Contents/MacOS/Kouen" | grep -q "@executable_path/../Frameworks"; then
  install_name_tool -add_rpath "@executable_path/../Frameworks" "$APP/Contents/MacOS/Kouen"
fi
if [[ -f "$ROOT/Apps/Kouen/Resources/Kouen.icns" ]]; then
  cp "$ROOT/Apps/Kouen/Resources/Kouen.icns" "$APP/Contents/Resources/Kouen.icns"
fi
if [[ -f "$ROOT/Apps/Kouen/Resources/KouenLogo.png" ]]; then
  cp "$ROOT/Apps/Kouen/Resources/KouenLogo.png" "$APP/Contents/Resources/KouenLogo.png"
fi
if [[ -d "$ROOT/Apps/Kouen/Resources/Fonts" ]]; then
  ditto "$ROOT/Apps/Kouen/Resources/Fonts" "$APP/Contents/Resources/Fonts"
fi
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>Kouen</string>
  <key>CFBundleIconFile</key>
  <string>Kouen</string>
  <key>CFBundleIdentifier</key>
  <string>com.vit129.kouen.preview</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>Kouen Preview</string>
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
  <key>KouenPreviewHome</key>
  <string>$PREVIEW_KOUEN_HOME</string>
  <key>KouenPreviewBuildLabel</key>
  <string>$(xml_escape "$PREVIEW_BUILD_LABEL")</string>
  <key>KouenPreviewBuiltAt</key>
  <string>$(xml_escape "$PREVIEW_BUILT_AT")</string>
  <key>KouenPreviewGitBranch</key>
  <string>$(xml_escape "$GIT_BRANCH")</string>
  <key>KouenPreviewGitSHA</key>
  <string>$(xml_escape "$GIT_SHA")</string>
  <key>KouenPreviewGitDirty</key>
  <string>$(xml_escape "$GIT_DIRTY")</string>
  <key>KouenPreviewGitSubject</key>
  <string>$(xml_escape "$GIT_SUBJECT")</string>
</dict>
</plist>
PLIST

codesign --force --sign - --entitlements "$ROOT/Kouen.entitlements" "$APP/Contents/MacOS/Kouen" >/dev/null
codesign --force --sign - --entitlements "$ROOT/Kouen.entitlements" "$APP/Contents/MacOS/KouenDaemon" >/dev/null
codesign --force --sign - --entitlements "$ROOT/Kouen.entitlements" "$APP/Contents/MacOS/kouen-cli" >/dev/null
codesign --force --sign - --deep "$APP" >/dev/null

# ─── Launch ───────────────────────────────────────────────────────────────────
# The app's DaemonLauncher detects KouenPreviewHome and spawns an isolated
# daemon automatically — no need to pre-spawn one here.
cat <<EOF

Launching Kouen Preview (isolated SIT environment).
App bundle:       $APP
State directory:  $PREVIEW_KOUEN_HOME
Socket:           $PREVIEW_KOUEN_HOME/kouen.sock
Build label:      $PREVIEW_BUILD_LABEL

Production app is NOT affected.

Preview CLI:
  KOUEN_HOME="$PREVIEW_KOUEN_HOME" "$BUILD_DIR/kouen-cli" ping

EOF

if [[ "${PREVIEW_SIGNPOSTS:-0}" == "1" ]]; then
  KOUEN_HOME="$PREVIEW_KOUEN_HOME" "$APP/Contents/MacOS/Kouen" -KOUEN_FRAME_SIGNPOSTS 1 &
else
  KOUEN_HOME="$PREVIEW_KOUEN_HOME" "$APP/Contents/MacOS/Kouen" &
fi
