#!/usr/bin/env bash
# Interactive build & release menu for Kouen.app (delegates to Node.js).
#
# Usage:
#   Scripts/start.sh        # interactive menu
#   make start              # same, via Makefile
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Refresh the knowledge graph before any of the menu options run (commit/PR/merge,
# preview, or full-cycle release) — a stale graphify-out/ silently misleads any
# AI-assisted work done right after. Reuses run.sh's own `graphify` subcommand
# (already forces the rebuild + strips stray HTML output) rather than duplicating
# it here. Best-effort: never blocks the actual command on a graphify hiccup.
if [[ -d graphify-out ]] && command -v graphify &>/dev/null; then
  echo "▶ Refreshing graphify index..."
  ./Scripts/run.sh graphify || echo "⚠️  graphify refresh failed — continuing anyway."
  echo ""
fi

exec node Scripts/start.mjs "$@"
