#!/usr/bin/env bash
# Install a locally built Kouen.app into /Applications, clearing macOS caches
# that would otherwise serve the old bundle.
#
# Usage:
#   Scripts/install-app.sh           # build release + install
#   Scripts/install-app.sh --no-build # skip build, install existing Kouen.app
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

DEST="/Applications/Kouen.app"
APP_SUPPORT="$HOME/Library/Application Support/Harness"
APP_SUPPORT_BIN="$APP_SUPPORT/bin"
LAUNCH_AGENT="$HOME/Library/LaunchAgents/com.vit129.kouen.daemon.plist"
NO_BUILD=0

for arg in "$@"; do
  case "$arg" in
    --no-build) NO_BUILD=1 ;;
    -h|--help)
      echo "Usage: Scripts/install-app.sh [--no-build]"
      echo "  --no-build  Skip build; install the existing Kouen.app at repo root"
      exit 0
      ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

# --- Stop production runtime FIRST (old binary can crash during build) ---
echo "==> Stopping production runtime..."
launchctl bootout "gui/$(id -u)" "$LAUNCH_AGENT" 2>/dev/null || true
launchctl bootout "gui/$(id -u)/com.vit129.kouen.daemon" 2>/dev/null || true
# One-time migration off each pre-rename label/plist (harmless once nothing's left under them).
launchctl bootout "gui/$(id -u)/com.vit129.harness.daemon" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/com.vit129.harness.daemon.plist"
launchctl bootout "gui/$(id -u)/com.robert.harness.daemon" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/com.robert.harness.daemon.plist"
"$ROOT/Kouen.app/Contents/MacOS/kouen-cli" daemon stop 2>/dev/null || true
pkill -f "/Applications/Kouen.app/Contents/MacOS/KouenDaemon" 2>/dev/null || true
pkill -f "$APP_SUPPORT_BIN/KouenDaemon" 2>/dev/null || true
pkill -x Kouen 2>/dev/null || true
# One-time migration: the app bundle name changed too (Harness.app -> Kouen.app), so an old
# install at the old path is a separate bundle this script never touches otherwise — quit it
# and remove it so two copies aren't left running/installed side by side.
pkill -f "/Applications/Harness.app/Contents/MacOS/Harness" 2>/dev/null || true
pkill -f "/Applications/Harness.app/Contents/MacOS/harness-mcp" 2>/dev/null || true
rm -rf "/Applications/Harness.app"
sleep 1

# --- Build ---
if [[ $NO_BUILD -eq 0 ]]; then
  echo "==> Building release (optimized)..."
  swift build -c release
  echo "==> Packaging..."
  Scripts/package-app.sh release
  echo "==> Ad-hoc signing..."
  codesign --force --sign - --deep "$ROOT/Kouen.app" >/dev/null
fi

if [[ ! -d "$ROOT/Kouen.app" ]]; then
  echo "error: Kouen.app not found at $ROOT/Kouen.app — run without --no-build" >&2
  exit 1
fi

# --- Install ---
echo "==> Installing to $DEST..."
rm -rf "$DEST"
ditto "$ROOT/Kouen.app" "$DEST"

# Keep the launchd-supervised daemon/CLI copies in sync with the installed app
# before first launch. The app also refreshes these on startup, but doing it here
# closes the window where launchd can respawn an old AppSupport daemon.
echo "==> Refreshing app-support binaries..."
mkdir -p "$APP_SUPPORT_BIN"
ditto "$DEST/Contents/MacOS/KouenDaemon" "$APP_SUPPORT_BIN/KouenDaemon"
ditto "$DEST/Contents/MacOS/kouen-cli" "$APP_SUPPORT_BIN/kouen-cli"
chmod +x "$APP_SUPPORT_BIN/KouenDaemon" "$APP_SUPPORT_BIN/kouen-cli"

Scripts/clear-runtime-state.sh

# --- Clear macOS caches ---
echo "==> Clearing quarantine..."
xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true

echo "==> Flushing LaunchServices..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -kill -r -domain local -domain system -domain user 2>/dev/null || true

# --- Run ---
echo "==> Opening $DEST..."
open "$DEST" || echo "==> (open skipped — no window server in this session; launch from Finder)"
