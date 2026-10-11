#!/usr/bin/env python3
"""Record when a fresh terminal can consume output at an explicitly specified grid.

Run from a temporary shell wrapper, followed by `exec /bin/sh`:
    python3 startup_ack_runner.py /absolute/path/ready.json 100 30
The launcher records time.clock_gettime_ns(time.CLOCK_MONOTONIC_RAW) immediately before spawning the app and
subtracts it from ready_ns. Use a fresh isolated app home, one warm-up, and five
samples. This includes shell/Python startup and a cursor-report round trip; it
does not measure GPU presentation or when the user sees a prompt.
"""
import argparse
import json
import os
import pathlib
import re
import select
import termios
import time
import tty


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("ready", type=pathlib.Path)
    parser.add_argument("columns", type=int)
    parser.add_argument("rows", type=int)
    args = parser.parse_args()
    if not os.isatty(0) or not os.isatty(1):
        parser.error("run inside a terminal pane")
    path = args.ready
    attributes = termios.tcgetattr(0)
    deadline = time.monotonic() + 10
    try:
        while time.monotonic() < deadline:
            size = os.get_terminal_size(1)
            if (size.columns, size.lines) == (args.columns, args.rows):
                break
            time.sleep(0.001)
        else:
            raise RuntimeError(f"terminal never reached {args.columns}x{args.rows}")
        tty.setraw(0)
        path.with_suffix(".armed").write_text("armed\n")
        os.write(1, b"READY\r\n\x1b[6n")
        received = b""
        while time.monotonic() < deadline:
            if select.select([0], [], [], min(0.005, max(0, deadline - time.monotonic())))[0]:
                chunk = os.read(0, 4096)
                if not chunk:
                    break
                received = (received + chunk)[-8192:]
                if re.search(rb"\x1b\[\d+;\d+R", received):
                    path.write_text(json.dumps({
                        "ready_ns": time.clock_gettime_ns(time.CLOCK_MONOTONIC_RAW),
                        "columns": size.columns,
                        "rows": size.lines,
                    }) + "\n", encoding="utf-8")
                    return
            else:
                # A pre-attach query can be replayed with replies suppressed. Retry while
                # the GUI connects; readiness includes at most 5 ms polling quantization.
                os.write(1, b"\x1b[6n")
        raise RuntimeError("terminal did not acknowledge the ready marker")
    finally:
        termios.tcsetattr(0, termios.TCSANOW, attributes)


if __name__ == "__main__":
    main()
