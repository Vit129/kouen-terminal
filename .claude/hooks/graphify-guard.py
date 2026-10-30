#!/usr/bin/env python3
"""graphify-guard: ONE central Claude Code hook that makes every project with a graph behave alike.

A project "has a graph" when `graphify-out/graph.json` exists at or above the session's cwd; anywhere
else every mode is a silent no-op, so new graphified projects are covered with zero setup.

  pre   (PreToolUse  Bash|Grep|Read|Glob)  graph-first lookup gate: a raw search (Grep tool, or a Bash
        grep/rg/ag/ack/fd/find) is refused until graphify was consulted once in this session; reading
        source files gets a single nudge. After one real graphify lookup raw search is allowed again
        (to confirm an exhaustive caller list, or for files graphify does not index).
  post  (PostToolUse Bash|mcp__graphify__*) records that graphify was consulted (query/grep/explain/
        affected/path/flow/dead-code/match/edit via the CLI, or any mcp__graphify__ tool).
  stop  (Stop) refreshes the graph with `graphify update .` (AST only, free) when a code file changed
        since the graph was built, so "update after editing" is guaranteed per turn.

Calls the `graphify` binary directly (the system python usually cannot import graphify, which lives
in its own tool env). Without graphify installed every mode is a silent no-op. Fails open on any error. Disable with GRAPHIFY_GUARD=0.
"""
import hashlib
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
from pathlib import Path

RAW_SEARCH = {"grep", "egrep", "fgrep", "rg", "ripgrep", "ag", "ack", "fd", "find"}
LOOKUP = {"query", "grep", "explain", "affected", "path", "flow", "dead-code", "match", "pattern", "edit"}
CODE_EXT = {
    ".py", ".js", ".jsx", ".mjs", ".cjs", ".ts", ".tsx", ".swift", ".go", ".rs", ".java", ".kt", ".kts",
    ".c", ".h", ".m", ".mm", ".cpp", ".cc", ".cxx", ".hpp", ".cs", ".rb", ".php", ".gd", ".sh", ".lua",
    ".dart", ".scala", ".vue", ".svelte",
}
GATE_MSG = (
    "graphify-first: this project has a knowledge graph (graphify-out/). Look things up through graphify "
    "before raw search: `graphify query \"<question>\"`, `graphify grep \"<text>\"` (exact text, shows the "
    "enclosing symbol), `graphify explain \"<symbol>\" --snippet`, `graphify affected \"<symbol>\"` (or the "
    "mcp__graphify__* tools). After one graphify lookup in this session, grep/find are allowed - use them to "
    "confirm an exhaustive caller list or for files graphify does not index, and say so."
)
NUDGE_MSG = (
    "graphify-out/ exists: prefer `graphify query/explain --snippet/grep/affected` over reading source files "
    "to explore; read a file when you need to edit specific lines."
)


# ---- helpers ---------------------------------------------------------------------------------
def find_root(cwd):
    p = Path(cwd).resolve()
    for d in [p, *p.parents]:
        if (d / "graphify-out" / "graph.json").is_file():
            return d
    return None


def _segments(command):
    return [s.strip() for s in re.split(r"&&|\|\||;|\n", command) if s.strip()]


def _first_words(segment):
    """Command words of a segment up to its first pipe, minus env assignments / sudo-style prefixes."""
    head = segment.split("|", 1)[0]
    try:
        words = shlex.split(head)
    except ValueError:
        words = head.split()
    while words and (re.match(r"^\w+=", words[0]) or os.path.basename(words[0]) in {"sudo", "time", "command", "nohup", "env"}):
        words = words[1:]
    return words


def is_raw_search(command):
    if "graphify-out" in command:
        return False
    return any(w and os.path.basename(w[0]) in RAW_SEARCH for w in map(_first_words, _segments(command)))


def uses_graphify(command):
    for w in map(_first_words, _segments(command)):
        if len(w) >= 2 and os.path.basename(w[0]) == "graphify" and w[1] in LOOKUP:
            return True
    return False


def _state_dir():
    if os.environ.get("GRAPHIFY_GUARD_STATE"):
        return Path(os.environ["GRAPHIFY_GUARD_STATE"])
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    import _aodd_paths
    return _aodd_paths.state() / "graphify-guard"


def _marker(session_id, root, kind):
    key = hashlib.sha1(str(root).encode()).hexdigest()[:10]
    return _state_dir() / f"{session_id}-{key}.{kind}"


def _touch(path):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.touch()


def _hso(**kw):
    return {"hookSpecificOutput": {"hookEventName": "PreToolUse", **kw}}


# ---- pre -------------------------------------------------------------------------------------
def decide_pre(payload):
    if os.environ.get("GRAPHIFY_GUARD") == "0":
        return None
    root = find_root(payload.get("cwd") or os.getcwd())
    if root is None:
        return None
    tool, inp, sid = payload.get("tool_name"), payload.get("tool_input") or {}, payload.get("session_id")
    if tool == "Grep" or (tool == "Bash" and is_raw_search(str(inp.get("command", "")))):
        if sid and _marker(sid, root, "used").exists():
            return None
        if not sid:  # cannot track the session -> never block, only remind
            return _hso(additionalContext=GATE_MSG)
        return _hso(permissionDecision="deny", permissionDecisionReason=GATE_MSG)
    if tool in ("Read", "Glob") and sid:
        target = str(inp.get("file_path") or inp.get("pattern") or "")
        if "graphify-out" in target or Path(target).suffix.lower() not in CODE_EXT:
            return None
        nudged = _marker(sid, root, "nudged")
        if nudged.exists():
            return None
        _touch(nudged)
        return _hso(additionalContext=NUDGE_MSG)
    return None


# ---- post ------------------------------------------------------------------------------------
def record_post(payload):
    root = find_root(payload.get("cwd") or os.getcwd())
    sid = payload.get("session_id")
    if root is None or not sid:
        return
    tool = str(payload.get("tool_name") or "")
    if tool.startswith("mcp__graphify__") or (
        tool == "Bash" and uses_graphify(str((payload.get("tool_input") or {}).get("command", "")))
    ):
        _touch(_marker(sid, root, "used"))


# ---- stop ------------------------------------------------------------------------------------
def changed_since_graph(root):
    graph = root / "graphify-out" / "graph.json"
    try:
        built = graph.stat().st_mtime
        out = subprocess.run(
            ["git", "-C", str(root), "status", "--porcelain", "-z"], capture_output=True, text=True, timeout=10
        )
    except (OSError, subprocess.SubprocessError):
        return []
    if out.returncode != 0:
        return []
    changed, entries, i = [], out.stdout.split("\0"), 0
    while i < len(entries):
        e = entries[i]
        i += 1
        if len(e) < 4:
            continue
        status, path = e[:2], e[3:]
        if status[0] in "RC":
            i += 1  # the next entry is the original path
        if path.startswith("graphify-out/") or Path(path).suffix.lower() not in CODE_EXT:
            continue
        f = root / path
        if "D" in status or (f.is_file() and f.stat().st_mtime > built + 0.5):
            changed.append(path)
    return sorted(set(changed))


def run_update(root):
    exe = shutil.which("graphify") or str(Path.home() / ".local" / "bin" / "graphify")
    if not os.path.exists(exe):
        return 127, "graphify not installed"
    try:
        r = subprocess.run(
            [exe, "update", "."], cwd=root, capture_output=True, text=True, timeout=150,
            env={**os.environ, "GRAPHIFY_NO_OPEN": "1"},
        )
    except subprocess.TimeoutExpired:
        return 124, "timed out after 150s"
    except OSError as exc:
        return 127, str(exc)
    tail = " ".join((r.stdout + r.stderr).strip().splitlines()[-2:])
    return r.returncode, tail[:240]


def decide_stop(payload):
    if payload.get("stop_hook_active") or os.environ.get("GRAPHIFY_GUARD") == "0":
        return None
    root = find_root(payload.get("cwd") or os.getcwd())
    if root is None:
        return None
    changed = changed_since_graph(root)
    if not changed or not (shutil.which("graphify") or (Path.home() / ".local/bin/graphify").exists()):
        return None  # graphify not installed: nothing to refresh, stay silent
    rc, tail = run_update(root)
    if rc == 0:
        return {"systemMessage": f"graphify: graph refreshed ({len(changed)} changed file(s))"}
    return {"systemMessage": f"graphify: update failed (exit {rc}): {tail} - run `graphify update .` (add --force if code was deleted)"}


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    try:
        payload = json.load(sys.stdin)
        if mode == "pre":
            out = decide_pre(payload)
        elif mode == "post":
            record_post(payload)
            out = None
        elif mode == "stop":
            out = decide_stop(payload)
        else:
            out = None
    except Exception:
        return  # fail open
    if out:
        print(json.dumps(out))


if __name__ == "__main__":
    main()
