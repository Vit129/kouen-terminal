#!/usr/bin/env bash
# Clear production runtime state that can make a freshly built Kouen.app
# reconnect to stale panes, scrollback, sockets, or daemon buffers.
#
# Intentionally preserves user configuration: settings, keybindings, themes,
# options, hooks, environment, and installed agent metadata.
set -euo pipefail

# Mirrors HarnessPaths.resolveDataRootName: prefer Kouen if it already exists (already
# migrated, or a fresh install); fall back to Harness if that's what's actually on disk.
if [[ -d "$HOME/Library/Application Support/Kouen" ]]; then
  APP_SUPPORT="$HOME/Library/Application Support/Kouen"
elif [[ -d "$HOME/Library/Application Support/Harness" ]]; then
  APP_SUPPORT="$HOME/Library/Application Support/Harness"
else
  APP_SUPPORT="$HOME/Library/Application Support/Kouen"
fi
CACHE_ROOT="$HOME/Library/Caches/Kouen"

echo "==> Clearing production runtime state..."
rm -rf "$APP_SUPPORT/sessions"
rm -rf "$APP_SUPPORT/tunnels"
rm -rf "$APP_SUPPORT/logs"
rm -f "$APP_SUPPORT/kouen.sock"
rm -f "$APP_SUPPORT/daemon.pid"
rm -f "$APP_SUPPORT/buffers.json"
rm -f "$APP_SUPPORT/version-state.json"
rm -f "$APP_SUPPORT/command-history.json"
rm -rf "$CACHE_ROOT/pasted-images"
