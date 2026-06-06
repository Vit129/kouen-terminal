#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

usage() {
  cat <<'USAGE'
Usage: Scripts/run.sh [command]

Commands:
  preview   Build and launch isolated preview app (.harness-preview) [default]
  app       Build, package, sign, and open Harness.app
  build     Run swift build
  stop      Stop preview app
  graphify  Refresh graphify-out without committed HTML output

Examples:
  make run                # app bundle
  Scripts/run.sh preview  # isolated preview
  Scripts/run.sh app
  Scripts/run.sh graphify
USAGE
}

command="${1:-preview}"

case "$command" in
  preview)
    exec make preview
    ;;
  app)
    make build
    Scripts/package-app.sh debug
    codesign --force --sign - --deep Harness.app >/dev/null
    open Harness.app
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
