#!/usr/bin/env python3
"""Stop hook: the Work Log (AODD "every job closes with one record").

Appends one JSON line per Stop to $AODD_WORKLOG/<YYYY-MM>.jsonl (default $AODD_HOME/work-log/):
who (project dir), tokens used, tool calls, learning signals (user corrections, fix commits).
Stop fires several times per session -> the report keeps the LAST line per session.
Sessions whose working directory matches a glob in $AODD_WORKLOG_SKIP (os.pathsep list, empty by
default) are not logged. Never blocks; fails open. Disable with CLAUDE_WORK_LOG=0.

Report (Agent Ops input): python3 work-log.py --report [YYYY-MM]
"""
import fnmatch
import importlib.util
import json
import re
import subprocess
import tempfile
import os
import sys
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import _aodd_paths  # noqa: E402

LOG_DIR = _aodd_paths.worklog()

# reuse skill-capture-nudge's transcript scan (tool calls + learning signals)
_spec = importlib.util.spec_from_file_location("nudge", Path(__file__).with_name("skill-capture-nudge.py"))
nudge = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(nudge)


def tokens(transcript: Path) -> int:
    total = 0
    with transcript.open() as f:
        for line in f:
            try:
                data = json.loads(line)
                u = data.get("message", {}).get("usage") or {}
                if u:
                    total += sum(u.get(k) or 0 for k in ("input_tokens", "output_tokens",
                                                         "cache_creation_input_tokens", "cache_read_input_tokens"))
                total += (data.get("input_tokens") or 0) + (data.get("output_tokens") or 0)  # Antigravity: top-level counts
            except (json.JSONDecodeError, AttributeError, TypeError):
                continue
    return total


TEMP_ROOTS = tuple(os.path.realpath(p) for p in (tempfile.gettempdir(), "/tmp", "/private/var/folders"))
JUNK_OWNER = re.compile(r"^(tmp\w*|output|worktrees|agent-[0-9a-f]{8,})$")  # temp dirs and agent worktrees


def skipped(real: str) -> bool:
    globs = [g for g in os.environ.get("AODD_WORKLOG_SKIP", "").split(os.pathsep) if g]
    return any(fnmatch.fnmatch(real, os.path.expanduser(g)) for g in globs)


def project_of(cwd: str):
    """Project name for a session dir: the main repo of a git worktree, None for temp dirs and skipped paths."""
    real = os.path.realpath(cwd)
    if real.startswith(TEMP_ROOTS) or skipped(real):
        return None
    try:
        common = subprocess.run(["git", "-C", real, "rev-parse", "--path-format=absolute", "--git-common-dir"],
                                capture_output=True, text=True, timeout=3).stdout.strip()
    except (OSError, subprocess.SubprocessError):
        common = ""
    return Path(common).parent.name if common.endswith("/.git") else Path(real).name


def entry(payload: dict):
    sid = payload.get("session_id") or payload.get("conversationId") or ""
    transcript = Path(payload.get("transcript_path") or payload.get("transcriptPath") or "")
    if not sid or not transcript.is_file():
        return None
    try:
        n, _, signals, *_ = nudge.scan(transcript)  # scan grew extra return values (skill-capture v2)
    except Exception:
        n, signals = 0, []
    owner_dir = payload.get("cwd") or (payload.get("workspacePaths") or [""])[0] or os.getcwd()
    owner = project_of(owner_dir)
    if not owner:
        return None
    return {
        "ts": datetime.now().isoformat(timespec="seconds"),
        "session": sid,
        "owner": owner,
        "tokens": tokens(transcript),
        "tool_calls": n,
        "signals": signals,  # corrections / errors / rework = "times corrected"
    }


FALLBACK_DIR = _aodd_paths.state() / "work-log"


def log_dir(e: dict) -> Path:
    """LOG_DIR, or FALLBACK_DIR when an explicit $AODD_WORKLOG points under a folder that does not exist
    (e.g. a central repo not cloned): the entry is never lost and says so once in its own line."""
    if os.environ.get("AODD_WORKLOG") and not LOG_DIR.parent.exists() and FALLBACK_DIR != LOG_DIR:
        e["note"] = f"fallback: {LOG_DIR.parent} missing"
        return FALLBACK_DIR
    return LOG_DIR


def report(month: str) -> str:
    paths = [p for p in (LOG_DIR / f"{month}.jsonl", FALLBACK_DIR / f"{month}.jsonl") if p.is_file()]
    if not paths:
        return f"no work log for {month}"
    last = {}
    for line in (l for p in paths for l in p.read_text().splitlines()):
        try:
            e = json.loads(line)
            last[e["session"]] = e
        except (json.JSONDecodeError, KeyError):
            continue
    by = {}
    for e in last.values():
        if JUNK_OWNER.match(e["owner"]):
            continue
        b = by.setdefault(e["owner"], [0, 0, 0])
        b[0] += 1
        b[1] += e["tokens"]
        b[2] += bool(e["signals"])
    rows = [f"| {o} | {s} | {t:,} | {c} |" for o, (s, t, c) in sorted(by.items(), key=lambda x: -x[1][1])]
    return "\n".join([f"# Work Log {month}", "", "| owner | sessions | tokens | sessions w/ rework |", "|---|---|---|---|", *rows])


def main():
    if sys.argv[1:2] == ["--report"]:
        print(report(sys.argv[2] if len(sys.argv) > 2 else datetime.now().strftime("%Y-%m")))
        return
    if os.environ.get("CLAUDE_WORK_LOG") == "0":
        return
    try:
        e = entry(json.load(sys.stdin))
        if e:
            d = log_dir(e)
            d.mkdir(parents=True, exist_ok=True)
            with (d / f"{e['ts'][:7]}.jsonl").open("a") as f:
                f.write(json.dumps(e, ensure_ascii=False) + "\n")
    except Exception:
        return


if __name__ == "__main__":
    main()
