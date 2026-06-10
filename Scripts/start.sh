#!/usr/bin/env bash
# Interactive build menu for Harness.app.
#
# Usage:
#   Scripts/start.sh        # interactive menu
#   make start               # same, via Makefile
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo ""
echo "Harness build"
echo ""
echo "  1) Build app and install to /Applications"
echo "  2) Build app only (you copy Harness.app to /Applications yourself)"
echo ""
read -rp "Enter choice (1-2): " choice

case "$choice" in
  1)
    exec Scripts/install-app.sh
    ;;
  2)
    make release
    echo ""
    echo "Done. Harness.app is at $ROOT/Harness.app"
    echo "Copy it to /Applications when you're ready."
    ;;
  *)
    echo "Invalid choice" >&2
    exit 1
    ;;
esac
