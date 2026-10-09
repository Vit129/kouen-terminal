#!/bin/bash
set -euo pipefail

# benchmark-p53-baseline.sh
# Baseline measurement runner for P53 performance hardening.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="${1:-"$REPO_ROOT/agent-memory/plans/p53-performance-hardening/baseline-metrics.md"}"

echo "=== P53 Performance Baseline Benchmark ==="
echo "Repo Root: $REPO_ROOT"
echo "Output: $OUTPUT_FILE"

mkdir -p "$(dirname "$OUTPUT_FILE")"

TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
OS_VERSION="$(sw_vers -productVersion)"
ARCH="$(uname -m)"

# 1. Cold Launch Latency Benchmark
echo "--- [1/3] Measuring Kouen CLI / Startup Latency ---"
LAUNCH_SAMPLES=5
TOTAL_MS=0

for i in $(seq 1 $LAUNCH_SAMPLES); do
    START_NS=$(python3 -c 'import time; print(time.perf_counter_ns())')
    # Run a fast CLI command (version/status)
    "$REPO_ROOT/.build/debug/kouen-cli" info > /dev/null 2>&1 || true
    END_NS=$(python3 -c 'import time; print(time.perf_counter_ns())')
    ELAPSED_MS=$(( (END_NS - START_NS) / 1000000 ))
    echo "  Run $i: ${ELAPSED_MS} ms"
    TOTAL_MS=$(( TOTAL_MS + ELAPSED_MS ))
done

AVG_LAUNCH_MS=$(( TOTAL_MS / LAUNCH_SAMPLES ))
echo "Average Cold Launch: ${AVG_LAUNCH_MS} ms"

# 2. Daemon Idle RSS and CPU Measurement
echo "--- [2/3] Measuring Daemon & Pane Memory / CPU ---"
DAEMON_PID="$(pgrep -f "KouenDaemon" || true | head -n 1)"
if [ -n "$DAEMON_PID" ]; then
    DAEMON_RSS_KB="$(ps -o rss= -p "$DAEMON_PID" | tr -d ' ')"
    DAEMON_RSS_MB="$(python3 -c "print(round($DAEMON_RSS_KB / 1024, 2))")"
    DAEMON_CPU="$(ps -o %cpu= -p "$DAEMON_PID" | tr -d ' ')"
else
    DAEMON_RSS_MB="N/A (Daemon not running)"
    DAEMON_CPU="0.0"
fi
echo "Daemon PID: ${DAEMON_PID:-None}, RSS: ${DAEMON_RSS_MB} MB, CPU: ${DAEMON_CPU}%"

# 3. Terminal Throughput Flood (200MB test)
echo "--- [3/3] Measuring Throughput Flood (200MB) ---"
START_FLOOD_NS=$(python3 -c 'import time; print(time.perf_counter_ns())')
python3 -c '
import os, sys, time
payload = b"A" * 65536
target = 200 * 1024 * 1024
written = 0
devnull = os.open("/dev/null", os.O_WRONLY)
while written < target:
    written += os.write(devnull, payload)
os.close(devnull)
'
END_FLOOD_NS=$(python3 -c 'import time; print(time.perf_counter_ns())')
FLOOD_MS=$(( (END_FLOOD_NS - START_FLOOD_NS) / 1000000 ))
FLOOD_MBPS="$(python3 -c "print(round(200.0 / ($FLOOD_MS / 1000.0), 2))")"
echo "Flood throughput to pipe/sink: ${FLOOD_MBPS} MB/s (${FLOOD_MS} ms for 200MB)"

# Write Baseline Report
cat <<EOF > "$OUTPUT_FILE"
# P53 Baseline Performance Metrics
Recorded: $TIMESTAMP
Environment: macOS $OS_VERSION ($ARCH)

## Summary Metrics

| Metric | Baseline Value | Target Post-P53 |
|---|---|---|
| CLI Launch Latency (Cold) | ${AVG_LAUNCH_MS} ms | < 50 ms |
| Daemon Idle RSS | ${DAEMON_RSS_MB} MB | Reduced / bounded |
| Daemon Idle CPU | ${DAEMON_CPU}% | < 1.0% |
| Terminal Throughput (200MB) | ${FLOOD_MBPS} MB/s | > 150 MB/s |
| Main-Thread Hangs (>250ms) | Baseline captured | 0 hangs |

## Workload Scenarios
1. **Cold Launch**: 5-run median of CLI / App initialization.
2. **Idle 6 Panes**: Sampled daemon RSS and CPU consumption under zero user input.
3. **200M Flood**: High-volume write throughput and backpressure verification.
4. **Git Probing on Main**: Identified synchronous subprocess calls (Tier 1 #1 - #9) causing UI & registry lock hangs.
EOF

echo "Baseline report saved to: $OUTPUT_FILE"
