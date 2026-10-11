#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
CI_HOME="$(mktemp -d /tmp/harness-ci.XXXXXX)"
trap 'rm -rf "$CI_HOME"' EXIT
export HARNESS_HOME="$CI_HOME"

swift --version
xcodebuild -version
swift build
swift build -c release
HARNESS_LIVE_DAEMON_TESTS=1 swift test --enable-code-coverage
python3 Scripts/test-macos-upgrade.py
xcodebuild -project Harness.xcodeproj -scheme Harness -configuration Debug \
  -derivedDataPath .build/xcode CODE_SIGNING_ALLOWED=NO build
