#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

WS_PORT="${KOUEN_MOBILE_BRIDGE_PORT:-7777}"
PAGE_PORT="${KOUEN_MOBILE_BRIDGE_PAGE_PORT:-8080}"

# Isolated state, same reasoning as preview.sh: a short /tmp path (fits
# sockaddr_un.sun_path) keyed off $ROOT, never the production KOUEN_HOME. This
# daemon starts with zero sessions of its own — Vit's real work is untouched.
MOBILE_WEB_HOME="/tmp/kouen-mobile-web-$(printf '%s' "$ROOT" | md5 | cut -c1-10)"
mkdir -p "$MOBILE_WEB_HOME"

echo "Building KouenDaemon + kouen-cli..."
swift build --product KouenDaemon
swift build --product kouen-cli
BUILD_DIR="$ROOT/.build/debug"

# Kill only a PREVIOUS mobile-web instance (via its own PID file under the
# isolated home), never the production daemon.
if [[ -f "$MOBILE_WEB_HOME/daemon.pid" ]]; then
  kill "$(cat "$MOBILE_WEB_HOME/daemon.pid")" 2>/dev/null || true
  sleep 0.3
fi
rm -f "$MOBILE_WEB_HOME/kouen.sock" "$MOBILE_WEB_HOME/daemon.pid"

cleanup() {
  [[ -n "${DAEMON_PID:-}" ]] && kill "$DAEMON_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

# The daemon now serves the pairing page itself (MobileBridgeServer.makePageListener) —
# no separate `python3 -m http.server` needed. That standalone server was also the reason
# a real production/preview daemon (no dev script involved) printed a pairing URL nothing
# was listening on; this fixes both at once.
echo "Starting isolated daemon (state: $MOBILE_WEB_HOME) — mobile bridge on ws:$WS_PORT, page:$PAGE_PORT"
KOUEN_HOME="$MOBILE_WEB_HOME" \
  KOUEN_MOBILE_BRIDGE_PORT="$WS_PORT" \
  KOUEN_MOBILE_BRIDGE_PAGE_PORT="$PAGE_PORT" \
  "$BUILD_DIR/KouenDaemon" &
DAEMON_PID=$!

cat <<EOF

Isolated dev daemon running — production Kouen.app is NOT affected.
State dir: $MOBILE_WEB_HOME
CLI:       KOUEN_HOME="$MOBILE_WEB_HOME" "$BUILD_DIR/kouen-cli" <command>

Smoke-test page (not the real W3 client — see agent-memory/plans/p25-mobile-session-switcher-design.html):
  http://127.0.0.1:$PAGE_PORT/?wsport=$WS_PORT

This daemon starts with zero sessions — use the page's "+ new" button (or
'kouen-cli new-session', shown above) to create one to attach to.

The pairing token/QR above is printed directly by the daemon (regenerates every
${KOUEN_MOBILE_BRIDGE_LIFETIME:-15}s). Ctrl+C stops it.

EOF

wait "$DAEMON_PID"
