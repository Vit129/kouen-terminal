#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DMG="${1:-$ROOT/Kouen.dmg}"

if [[ ! -f "$DMG" ]]; then
  echo "Usage: Scripts/smoke-dmg.sh [path/to/Kouen.dmg]" >&2
  echo "DMG not found: $DMG" >&2
  exit 2
fi

workdir="$(mktemp -d "${TMPDIR:-/tmp}/kouen-dmg-smoke.XXXXXX")"
mountpoint="$workdir/mount"
install_dir="$workdir/install"
home_dir="$workdir/home"
app_log="$workdir/Kouen.log"
daemon_log="$home_dir/logs/daemon.log"
app_pid=""

cleanup() {
  if [[ -n "${app_pid:-}" ]] && kill -0 "$app_pid" 2>/dev/null; then
    kill "$app_pid" 2>/dev/null || true
    wait "$app_pid" 2>/dev/null || true
  fi
  if [[ -d "$mountpoint" ]]; then
    hdiutil detach "$mountpoint" -quiet -force >/dev/null 2>&1 || true
  fi
  rm -rf "$workdir"
}
trap cleanup EXIT

mkdir -p "$mountpoint" "$install_dir" "$home_dir"

echo "==> Verifying DMG container..."
hdiutil verify "$DMG"

echo "==> Mounting DMG..."
hdiutil attach "$DMG" -quiet -nobrowse -readonly -mountpoint "$mountpoint"

mounted_app="$mountpoint/Kouen.app"
if [[ ! -d "$mounted_app" ]]; then
  echo "Kouen.app not found in mounted DMG." >&2
  find "$mountpoint" -maxdepth 2 -print >&2
  exit 1
fi

app="$install_dir/Kouen.app"
echo "==> Copying app to temp install location..."
ditto "$mounted_app" "$app"

plist="$app/Contents/Info.plist"
version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$plist")"
build="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$plist")"
minimum="$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "$plist")"
echo "    Kouen $version ($build), macOS $minimum+"

for binary in Kouen KouenDaemon kouen-cli; do
  path="$app/Contents/MacOS/$binary"
  [[ -x "$path" ]] || { echo "Missing executable: $path" >&2; exit 1; }
  if ! lipo -archs "$path" | grep -qw arm64; then
    echo "$binary is not arm64." >&2
    lipo -archs "$path" >&2
    exit 1
  fi
done

if find "$app/Contents/Resources" -maxdepth 1 -name '*.bundle' -print | grep -q .; then
  echo "Unexpected resource bundle in Kouen.app:" >&2
  find "$app/Contents/Resources" -maxdepth 1 -name '*.bundle' -print >&2
  exit 1
fi

echo "==> Verifying code signature..."
codesign --verify --deep --strict --verbose=2 "$app"

echo "==> Exercising bundled theme catalog through shipped CLI..."
KOUEN_HOME="$home_dir" "$app/Contents/MacOS/kouen-cli" theme-preview --all >/dev/null

echo "==> Launching Kouen.app from temp install location..."
KOUEN_HOME="$home_dir" "$app/Contents/MacOS/Kouen" >"$app_log" 2>&1 &
app_pid=$!

for attempt in {1..40}; do
  if ! kill -0 "$app_pid" 2>/dev/null; then
    echo "Kouen exited during smoke launch." >&2
    echo "--- Kouen stdout/stderr ---" >&2
    sed -n '1,160p' "$app_log" >&2 || true
    echo "--- daemon log ---" >&2
    sed -n '1,160p' "$daemon_log" >&2 || true
    exit 1
  fi

  if KOUEN_HOME="$home_dir" "$app/Contents/MacOS/kouen-cli" ping >/dev/null 2>&1; then
    echo "==> Smoke launch passed."
    exit 0
  fi

  sleep 0.25
done

echo "Kouen launched but daemon did not answer ping." >&2
echo "--- Kouen stdout/stderr ---" >&2
sed -n '1,160p' "$app_log" >&2 || true
echo "--- daemon log ---" >&2
sed -n '1,160p' "$daemon_log" >&2 || true
exit 1
