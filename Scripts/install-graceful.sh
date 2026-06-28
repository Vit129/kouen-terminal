#!/usr/bin/env bash
# Graceful install: preserve session layout across version updates.
# Workspace structure and pane CWDs are restored after restart;
# running shell processes are restarted fresh (daemon must restart for new binary).
#
# Crucially, this script can be run from *inside* a Harness pane:
# the install work is handed off to a detached background process before
# Harness is asked to quit, so the pane dying doesn't abort the install.
#
# Usage:
#   Scripts/install-graceful.sh           # build release + graceful install
#   Scripts/install-graceful.sh --no-build # skip build, install existing Harness.app
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

DEST="/Applications/Harness.app"
APP_SUPPORT="$HOME/Library/Application Support/Harness"
APP_SUPPORT_BIN="$APP_SUPPORT/bin"
LAUNCH_AGENT="$HOME/Library/LaunchAgents/com.robert.harness.daemon.plist"
LOG="$APP_SUPPORT/install-graceful.log"
NO_BUILD=0

for arg in "$@"; do
  case "$arg" in
    --no-build) NO_BUILD=1 ;;
    -h|--help)
      echo "Usage: Scripts/install-graceful.sh [--no-build]"
      echo "  --no-build  Skip build; install the existing Harness.app at repo root"
      exit 0
      ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

# --- Build ---
if [[ $NO_BUILD -eq 0 ]]; then
  echo "==> Building release (optimized)..."
  swift build -c release
  echo "==> Packaging..."
  Scripts/package-app.sh release
  echo "==> Ad-hoc signing..."
  codesign --force --sign - --deep "$ROOT/Harness.app" >/dev/null
fi

if [[ ! -d "$ROOT/Harness.app" ]]; then
  echo "error: Harness.app not found at $ROOT/Harness.app — run without --no-build" >&2
  exit 1
fi

# Absolute paths for the detached helper (it runs in a different cwd)
SRC_ABS=$(cd "$ROOT" && pwd)/Harness.app
DEST_ABS="$DEST"

if pgrep -x Harness > /dev/null 2>&1; then
  echo "==> Flushing session state (waiting for layout debounce)..."
  sleep 1

  echo "==> Scheduling background installer..."
  # Hand install + relaunch off to a process that survives Harness dying.
  nohup bash -c "
    echo '-- waiting for Harness GUI to exit'
    for i in \$(seq 1 100); do
      pgrep -x Harness > /dev/null 2>&1 || break
      sleep 0.1
    done
    echo '-- stopping daemon'
    launchctl bootout 'gui/\$(id -u)' '$LAUNCH_AGENT' 2>/dev/null || true
    launchctl bootout 'gui/\$(id -u)/com.robert.harness.daemon' 2>/dev/null || true
    pkill -f '/Applications/Harness.app/Contents/MacOS/HarnessDaemon' 2>/dev/null || true
    pkill -f '$APP_SUPPORT_BIN/HarnessDaemon' 2>/dev/null || true
    sleep 0.5
    echo '-- installing $SRC_ABS -> $DEST_ABS'
    rm -rf '$DEST_ABS'
    ditto '$SRC_ABS' '$DEST_ABS'
    mkdir -p '$APP_SUPPORT_BIN'
    ditto '$DEST_ABS/Contents/MacOS/HarnessDaemon' '$APP_SUPPORT_BIN/HarnessDaemon'
    ditto '$DEST_ABS/Contents/MacOS/harness-cli' '$APP_SUPPORT_BIN/harness-cli'
    chmod +x '$APP_SUPPORT_BIN/HarnessDaemon' '$APP_SUPPORT_BIN/harness-cli'
    xattr -dr com.apple.quarantine '$DEST_ABS' 2>/dev/null || true
    sleep 0.3
    echo '-- launching'
    open '$DEST_ABS'
    echo '-- done'
  " >> "$LOG" 2>&1 &

  echo "==> Quitting Harness — will restart with new build momentarily..."
  echo "    (log: $LOG)"
  osascript -e 'tell application "Harness" to quit' 2>/dev/null || \
    pkill -TERM Harness 2>/dev/null || true

else
  # Not running — install directly (same as install-app.sh minus the state wipe)
  echo "==> Stopping any stale daemon..."
  launchctl bootout "gui/$(id -u)" "$LAUNCH_AGENT" 2>/dev/null || true
  launchctl bootout "gui/$(id -u)/com.robert.harness.daemon" 2>/dev/null || true
  pkill -f "/Applications/Harness.app/Contents/MacOS/HarnessDaemon" 2>/dev/null || true
  pkill -f "$APP_SUPPORT_BIN/HarnessDaemon" 2>/dev/null || true
  sleep 0.5

  echo "==> Installing to $DEST..."
  rm -rf "$DEST"
  ditto "$ROOT/Harness.app" "$DEST"
  mkdir -p "$APP_SUPPORT_BIN"
  ditto "$DEST/Contents/MacOS/HarnessDaemon" "$APP_SUPPORT_BIN/HarnessDaemon"
  ditto "$DEST/Contents/MacOS/harness-cli" "$APP_SUPPORT_BIN/harness-cli"
  chmod +x "$APP_SUPPORT_BIN/HarnessDaemon" "$APP_SUPPORT_BIN/harness-cli"
  xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true

  echo "==> Opening $DEST..."
  open "$DEST"
fi
