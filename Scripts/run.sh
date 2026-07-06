#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

usage() {
  cat <<'USAGE'
Usage: Scripts/run.sh [command]

Commands:
  preview   Build and launch isolated preview app (.kouen-preview) [default]
  debug     Alias for preview (kept for old muscle memory)
  prod      Build (release), package, sign, and open Kouen.app (no /Applications copy)
  run       Re-open the existing Kouen.app without rebuilding
  build     Run swift build
  stop      Stop preview app
  graphify  Refresh graphify-out without committed HTML output

Examples:
  make debug              # alias for make preview
  make prod               # build (release) + open
  make run                # just re-open the existing build
  Scripts/run.sh preview  # isolated preview
  Scripts/run.sh graphify
USAGE
}

# Kill any already-running instance so the new build is what actually loads —
# `open` on a running app just re-activates the old process.
kill_stale() {
  pkill -f "$ROOT/Kouen.app/Contents/MacOS/KouenDaemon" 2>/dev/null || true
  pkill -f "$ROOT/Kouen.app/Contents/MacOS/Kouen\$" 2>/dev/null || true
  sleep 0.5
}

# prod/run builds at the repo root share the production KOUEN_HOME
# (~/Library/Application Support/Kouen) with /Applications/Kouen.app and the
# launchd-managed daemon (`make install`). Without stopping those too, the fresh
# repo-root app reconnects to the old launchd daemon/socket and looks unchanged.
# `preview` uses an isolated KOUEN_HOME and never goes through this path.
kill_stale_prod() {
  kill_stale

  # When running inside Kouen, skip killing /Applications instance + its daemon —
  # that would destroy our own terminal session mid-script.
  if [[ "${TERM_PROGRAM:-}" == "Kouen" ]]; then
    return
  fi

  pkill -f "/Applications/Kouen.app/Contents/MacOS/KouenDaemon" 2>/dev/null || true
  pkill -f "/Applications/Kouen.app/Contents/MacOS/Kouen\$" 2>/dev/null || true
  launchctl bootout "gui/$(id -u)/com.vit129.kouen.daemon" 2>/dev/null || true
  pkill -f "$HOME/Library/Application Support/Kouen/bin/KouenDaemon" 2>/dev/null || true
  sleep 0.5
}

command="${1:-preview}"

case "$command" in
  preview)
    exec make preview
    ;;
  debug)
    echo "make debug is now an alias for make preview."
    exec make preview
    ;;
  prod)
    swift build -c release
    Scripts/package-app.sh release
    codesign --force --sign - --deep Kouen.app >/dev/null
    kill_stale_prod
    if [[ "${TERM_PROGRAM:-}" != "Kouen" ]]; then
      Scripts/clear-runtime-state.sh
    fi
    sleep 0.3
    open -n Kouen.app
    ;;
  run)
    if [[ ! -d Kouen.app ]]; then
      echo "error: Kouen.app not found at repo root — run 'make prod' first" >&2
      exit 1
    fi
    kill_stale_prod
    if [[ "${TERM_PROGRAM:-}" != "Kouen" ]]; then
      Scripts/clear-runtime-state.sh
    fi
    open -n Kouen.app
    ;;
  build)
    exec make build
    ;;
  stop)
    exec make preview-stop
    ;;
  graphify)
    graphify update . --force
    find graphify-out -type f -name '*.html' -delete
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    echo "Unknown command: $command" >&2
    usage >&2
    exit 2
    ;;
esac
