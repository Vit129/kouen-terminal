#!/usr/bin/env bash
# Refresh the graphify knowledge graph for harness-terminal.
#
# Uses --update (changed files only) once a graph already exists, otherwise
# does a full extraction. Standard flags: --no-viz (skip graph.html, agents
# don't need it), --wiki (agent-crawlable markdown), --exclude-hubs 99 (keep
# utility hubs out of the god-node ranking).
#
# Usage: Scripts/graphify-refresh.sh
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ -f graphify-out/graph.json ]]; then
  graphify . --update --no-viz --wiki --exclude-hubs 99
else
  graphify . --no-viz --wiki --exclude-hubs 99
fi
