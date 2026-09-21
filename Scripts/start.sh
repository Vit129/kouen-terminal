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
# AI-assisted work done right after. Best-effort: graphify's own node-count safety
# check can refuse a run non-deterministically (see agent-memory/knowledge/ if this
# recurs a lot), so a failure here is reported but never blocks the actual command.
if [[ -d graphify-out ]] && command -v graphify &>/dev/null; then
  echo "▶ Refreshing graphify index..."
  if ! graphify update .; then
    echo "⚠️  graphify update failed/refused — continuing anyway (rerun manually with --force if the node-count drop is expected, e.g. after deleting files)."
  fi
  echo ""
fi

exec node Scripts/start.mjs "$@"
