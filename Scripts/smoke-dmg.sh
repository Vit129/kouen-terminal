#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DMG="${1:-$ROOT/Harness.dmg}"

if [[ ! -f "$DMG" ]]; then
  echo "Usage: Scripts/smoke-dmg.sh [path/to/Harness.dmg]" >&2
  echo "DMG not found: $DMG" >&2
  exit 2
fi

# Keep the isolated control socket below Darwin's sockaddr_un path limit.
workdir="$(mktemp -d /tmp/h-dmg.XXXXXX)"
mountpoint="$workdir/mount"
install_dir="$workdir/install"
home_dir="$workdir/home"
app_log="$workdir/Harness.log"
daemon_log="$home_dir/logs/daemon.log"
app_pid=""
cli=""

# A smoke test launched inside Harness must never route to the user's current pane.
unset HARNESS_SERVER HARNESS_SOCK HARNESS_SESSION HARNESS_TAB HARNESS_SURFACE HARNESS_DAEMON_PATH
unset HARNESS_DAEMON_GENERATION HARNESS_DAEMON_SOCKET HARNESS_DAEMON_WARM HARNESS_STREAM_EPOCH
unset HARNESS_SESSION_HOST_IDENTITY HARNESS_SESSION_HOST_PID HARNESS_SESSION_HOST_SOCKET
export HARNESS_HOME="$home_dir"
export SHELL=/bin/sh

cleanup() {
  local status=$?
  if [[ -n "${app_pid:-}" ]] && kill -0 "$app_pid" 2>/dev/null; then
    kill "$app_pid" 2>/dev/null || true
    wait "$app_pid" 2>/dev/null || true
  fi
  if [[ -n "$cli" && -e "$home_dir/daemon.pid" ]]; then
    if ! "$cli" kill-server --force; then
      echo "Could not stop the isolated smoke-test service; retaining $workdir for inspection." >&2
      exit 1
    fi
  fi
  if [[ -d "$mountpoint" ]]; then
    hdiutil detach "$mountpoint" -quiet -force >/dev/null 2>&1 || true
  fi
  if [[ "$status" == 0 ]]; then
    rm -rf "$workdir"
  else
    echo "Smoke-test logs retained at $workdir." >&2
  fi
}
trap cleanup EXIT

mkdir -p "$mountpoint" "$install_dir" "$home_dir"

echo "==> Verifying DMG container..."
hdiutil verify "$DMG"

echo "==> Mounting DMG..."
hdiutil attach "$DMG" -quiet -nobrowse -readonly -mountpoint "$mountpoint"

mounted_app="$mountpoint/Harness.app"
if [[ ! -d "$mounted_app" ]]; then
  echo "Harness.app not found in mounted DMG." >&2
  find "$mountpoint" -maxdepth 2 -print >&2
  exit 1
fi

app="$install_dir/Harness.app"
echo "==> Copying app to temp install location..."
ditto "$mounted_app" "$app"
cli="$app/Contents/MacOS/harness-cli"

plist="$app/Contents/Info.plist"
version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$plist")"
build="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$plist")"
minimum="$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "$plist")"
echo "    Harness $version ($build), macOS $minimum+"

for binary in Harness HarnessSessionHost HarnessDaemon harness-cli; do
  path="$app/Contents/MacOS/$binary"
  [[ -x "$path" ]] || { echo "Missing executable: $path" >&2; exit 1; }
  if ! lipo -archs "$path" | grep -qw arm64; then
    echo "$binary is not arm64." >&2
    lipo -archs "$path" >&2
    exit 1
  fi
done

if find "$app/Contents/Resources" -maxdepth 1 -name '*.bundle' -print | grep -q .; then
  echo "Unexpected resource bundle in Harness.app:" >&2
  find "$app/Contents/Resources" -maxdepth 1 -name '*.bundle' -print >&2
  exit 1
fi

echo "==> Verifying code signature..."
codesign --verify --deep --strict --verbose=2 "$app"
xcrun stapler validate "$app"
spctl --assess --type execute --verbose "$app"

echo "==> Exercising bundled theme catalog through shipped CLI..."
"$cli" theme-preview --all >/dev/null

echo "==> Launching Harness.app from temp install location..."
"$app/Contents/MacOS/Harness" >"$app_log" 2>&1 &
app_pid=$!

for attempt in {1..120}; do
  if ! kill -0 "$app_pid" 2>/dev/null; then
    echo "Harness exited during smoke launch." >&2
    echo "--- Harness stdout/stderr ---" >&2
    sed -n '1,160p' "$app_log" >&2 || true
    echo "--- daemon log ---" >&2
    sed -n '1,160p' "$daemon_log" >&2 || true
    exit 1
  fi

  if "$cli" daemon-stats --json >"$workdir/stats.json" 2>/dev/null &&
     "$cli" list-clients --json >"$workdir/clients.json" 2>/dev/null; then
    if python3 - "$workdir" "$version" "$build" <<'PY'
import json, pathlib, sys
root, version, build = pathlib.Path(sys.argv[1]), sys.argv[2], int(sys.argv[3])
stats = json.loads((root / "stats.json").read_text())
clients = json.loads((root / "clients.json").read_text())
ready = (stats.get("version") == version and stats.get("build") == build
         and stats.get("sessionHostBuild") == build and stats.get("daemonAvailable") is True
         and stats.get("surfaceCount", 0) > 0
         and any(client.get("attachedSurfaceIDs") for client in clients))
sys.exit(0 if ready else 1)
PY
    then
      echo "==> Smoke launch passed: current app and helpers, live terminal attachment."
      exit 0
    fi
  fi

  sleep 0.25
done

echo "Harness did not attach a terminal to the expected daemon and session-host build." >&2
echo "--- Harness stdout/stderr ---" >&2
sed -n '1,160p' "$app_log" >&2 || true
echo "--- daemon log ---" >&2
sed -n '1,160p' "$daemon_log" >&2 || true
exit 1
