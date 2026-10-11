#!/usr/bin/env python3
"""Measure file-fed admission and DSR-fenced parsing; generation is outside timing.

Generate: consumer_ack_runner.py --generate payloads --agent-session session.cast
Run inside a pane: consumer_ack_runner.py harness results.jsonl --payloads payloads
Sample zero warms up; samples one through five are measured. DSR fences parsing,
not GPU presentation. cat startup and the query/reply round trip are included.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import select
import subprocess
import termios
import time
import tty

import terminal_stress_runner as stress


def acknowledge():
    stress.write_all(b"\x1b[6n")
    received = b""
    deadline = time.monotonic() + 30
    while time.monotonic() < deadline:
        if select.select([0], [], [], max(0, deadline - time.monotonic()))[0]:
            chunk = os.read(0, 4096)
            if not chunk:
                break
            received = (received + chunk)[-8192:]
            if re.search(rb"\x1b\[\d+;\d+R", received):
                return
    raise RuntimeError("cursor report did not acknowledge consumption within 30 seconds")


def generate(directory, agent_session, selected=None):
    directory.mkdir(parents=True, exist_ok=True)
    size = 64 * 1024 * 1024
    cases = [
        ("plain_ascii", stress.repeated_chunk(b"the quick brown fox jumps over the lazy dog 0123456789\r\n", size)),
        ("ansi_sgr", stress.sgr_lines(size)),
        ("unicode_mixed", stress.unicode_lines(size)),
    ]
    manifest = []
    if selected:
        cases = [(name, chunks) for name, chunks in cases if name in selected]
    for name, chunks in cases:
        path = directory / (name + ".vt")
        with path.open("wb") as output:
            for chunk in chunks:
                output.write(chunk)
        data = path.read_bytes()
        manifest.append({"case": name, "file": path.name, "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()})
    if agent_session and (not selected or "agent_session" in selected):
        events = [json.loads(line) for line in agent_session.read_text().splitlines()]
        data = b"".join(event[2].encode() for event in events[1:] if event[1] == "o")
        # Recorded TUIs ask for cursor reports themselves. Those replies would let the
        # measurement mistake an earlier query for the final consumption fence.
        data = re.sub(rb"\x1b\[[?>]?[0-9;]*n", b"", data)
        if not data:
            raise ValueError("agent recording contains no output")
        path = directory / "agent_session.vt"
        path.write_bytes(data)
        manifest.append({"case": "agent_session", "file": path.name, "bytes": len(data),
                         "sha256": hashlib.sha256(data).hexdigest(), "recording": str(agent_session)})
    if selected and set(selected) != {case["case"] for case in manifest}:
        raise ValueError("requested generation case is unavailable")
    (directory / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("label", nargs="?")
    parser.add_argument("results", nargs="?", type=Path)
    parser.add_argument("--generate", type=Path)
    parser.add_argument("--agent-session", type=Path)
    parser.add_argument("--payloads", type=Path)
    parser.add_argument("--samples", type=int, default=5)
    parser.add_argument("--case", action="append", help="Run only named cases from the manifest")
    args = parser.parse_args()
    if args.generate:
        generate(args.generate, args.agent_session, args.case)
        return
    if not args.label or not args.results or not args.payloads or args.samples < 1:
        parser.error("provide label, results, --payloads, and a positive sample count")
    if not os.isatty(0) or not os.isatty(1):
        parser.error("run the measurement inside the terminal pane")
    manifest = json.loads((args.payloads / "manifest.json").read_text())
    if args.case:
        manifest = [case for case in manifest if case["case"] in args.case]
        if not manifest or set(args.case) != {case["case"] for case in manifest}:
            parser.error("requested case is missing from the manifest")
    for case in manifest:
        data = (args.payloads / case["file"]).read_bytes()
        if len(data) != case["bytes"] or hashlib.sha256(data).hexdigest() != case["sha256"]:
            raise ValueError("payload does not match manifest: " + case["file"])
    attributes = termios.tcgetattr(0)
    try:
        tty.setraw(0)
        with args.results.open("w", encoding="utf-8") as output:
            for sample in range(args.samples + 1):
                for case in manifest:
                    stress.write_all(b"\x1b[0m\x1b[3J\x1b[2J\x1b[H")
                    termios.tcflush(0, termios.TCIFLUSH)
                    acknowledge()
                    start = time.perf_counter_ns()
                    subprocess.run(["/bin/cat", str(args.payloads / case["file"])], check=True)
                    written = time.perf_counter_ns()
                    acknowledge()
                    end = time.perf_counter_ns()
                    size = os.get_terminal_size(1)
                    output.write(json.dumps({
                        "variant": args.label, "sample": sample, "case": case["case"],
                        "bytes": case["bytes"], "sha256": case["sha256"],
                        "columns": size.columns, "rows": size.lines,
                        "write_ms": (written - start) / 1e6,
                        "consumer_ms": (end - start) / 1e6,
                        "consumer_mbps": case["bytes"] / ((end - start) / 1e9) / 1e6,
                    }) + "\n")
                    output.flush()
    finally:
        termios.tcsetattr(0, termios.TCSANOW, attributes)


if __name__ == "__main__":
    main()
