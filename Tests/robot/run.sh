#!/bin/bash
# Run Robot Framework regression tests for Kouen terminal
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TESTS="$SCRIPT_DIR"
OUTPUT="$ROOT/.robot-output"

mkdir -p "$OUTPUT"

echo "=== Running Robot Framework tests ==="
robot --outputdir "$OUTPUT" \
      --loglevel INFO \
      "$TESTS"

EXIT=$?
if [ $EXIT -eq 0 ]; then
    echo "✅ All tests passed"
else
    echo "❌ Tests failed (exit $EXIT) — see $OUTPUT/report.html"
fi
exit $EXIT
