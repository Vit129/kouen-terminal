#!/usr/bin/env python3
"""coding-rules-gate: refuse the first code edit of a session until `rules/coding.md` was read.

  pre   (PreToolUse  Edit|Write|MultiEdit|NotebookEdit|Bash)  deny a code-file write (Edit/Write tool,
        or a Bash command that writes a code file: sed -i, perl -i, redirect/tee, open(...,"w"),
        write_text, git apply, patch) while this session has no "read" marker.
        Also denies it while the edited project's root ARCHITECTURE.md (if it has one) is unread.
  post  (PostToolUse Read|Bash)  sets a marker when rules/coding.md or ARCHITECTURE.md is read (Read
        tool, or a Bash cat/sed/head/less on it).

Why: "read the coding rules once per session" is plain text; a session that edits only through Bash
(auto mode) skips it. The rule file gate only applies when `rules/coding.md` exists in the Claude home
(or at $AODD_CODING_RULES), so a package without that file never blocks on it. Bash detection is a
heuristic; it errs toward missing an odd write form, never toward blocking reads.
Fails open on any error. Disable with CODING_RULES_GATE=0.
"""
import hashlib
import json
import os
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import _aodd_paths  # noqa: E402

CODE_EXT = (
    "py|js|jsx|mjs|cjs|ts|tsx|swift|go|rs|java|kt|kts|c|h|m|mm|cpp|cc|cxx|hpp|hh|cs|rb|php|gd|sh|lua|dart|scala|vue|svelte"
)
CODE_PATH = re.compile(rf"[\w./+~$-]+\.(?:{CODE_EXT})\b")
# Shell-level writes: matched only outside quotes and non-interpreter heredocs, so a commit message
# or PR body that merely mentions `sed -i` is not an edit.
SHELL_WRITE = re.compile(r"\bsed\s+(?:-\w*\s+)*-i|\bperl\s+-\w*i|\btee\b|>>?\s*[\w./+~$-]+\.(?:" + CODE_EXT + r")\b")
# Interpreter writes: live inside a heredoc or `-c "..."`, so matched on the quoted text.
PY_WRITE = re.compile(r"open\([^)]*['\"][wa]\+?['\"]|\.write_text\(")
HEREDOC = re.compile(r"^(?P<head>[^\n]*?)<<-?\s*['\"]?(?P<tag>\w+)['\"]?[^\n]*\n.*?^\s*(?P=tag)\s*$", re.M | re.S)
INTERPRETER = re.compile(r"\b(?:python3?|node|ruby|perl|bash|sh|zsh|swift|deno|bun)\b")
QUOTED = re.compile(r"'[^']*'|\"(?:\\.|[^\"\\])*\"")
PATCH = re.compile(r"\bgit\s+apply\b|\bpatch\s+-")  # writes code without naming a code file
RULE = "rules/coding.md"
ARCH = "ARCHITECTURE.md"
READERS = {"cat", "sed", "head", "tail", "less", "bat", "rtk"}
MSG = (
    "coding-rules-gate: read {path} before the first code edit of this session. "
    "Read it with the Read tool, then retry this edit."
)


def rule_file():
    """The coding rules file, or None when this install has none (then the rule gate stays off)."""
    f = Path(os.environ.get("AODD_CODING_RULES") or _aodd_paths.claude_home() / RULE).expanduser()
    return f if f.is_file() else None
ARCH_MSG = (
    "coding-rules-gate: this project has {path} - read it before the first code edit in this project "
    "this session then retry."
)


def _marker(sid, kind="read"):
    d = Path(os.environ.get("CODING_RULES_GATE_STATE") or _aodd_paths.state() / "coding-rules-gate")
    return d / f"{sid}.{kind}"


def is_code_write(tool, inp):
    if tool in ("Edit", "Write", "MultiEdit", "NotebookEdit"):
        path = str(inp.get("file_path") or inp.get("notebook_path") or "")
        return bool(CODE_PATH.fullmatch(path.rsplit("/", 1)[-1])) or path.endswith(".ipynb")
    if tool == "Bash":
        cmd = str(inp.get("command", ""))
        return bool(write_texts(cmd)) or any(PATCH.search(s) for s in _segments(_bare(cmd)))
    return False


def _segments(cmd):
    # Same `&&`/`||` segment only: `sed -i x.md && git add y.py` is not a code write. Not split on
    # `;`/newlines, which would cut a python heredoc's path from its open(...,"w").
    return re.split(r"&&|\|\|", cmd)


def _drop_data_heredocs(cmd):
    """Heredoc bodies fed to an interpreter are code (kept); any other body (git commit -F -, cat >
    file) is data, so dropped. `cat > x.py <<EOF` still counts: the redirect is on the head line."""
    return HEREDOC.sub(lambda m: m.group(0) if INTERPRETER.search(m.group("head")) else m.group("head"), cmd)


def _bare(cmd):
    return QUOTED.sub("", _drop_data_heredocs(cmd))


def write_texts(cmd):
    """Text of each segment that writes a code file, searched for its path. Shell writes are judged
    on the bare command (`sed -i 's|x.sh|y|' AGENTS.md` edits the .md); interpreter writes on the
    quoted text, since their path is a string literal."""
    out = [s for s in _segments(_bare(cmd)) if SHELL_WRITE.search(s) and CODE_PATH.search(s)]
    out += [s for s in _segments(_drop_data_heredocs(cmd)) if PY_WRITE.search(s) and CODE_PATH.search(s)]
    return out


def reads_file(tool, inp, name):
    if tool == "Read":
        return str(inp.get("file_path", "")).endswith(name)
    if tool == "Bash":
        cmd = str(inp.get("command", ""))
        return name in cmd and any(re.search(rf"(?:^|[;&|]\s*){w}\b", cmd) for w in READERS)
    return False


def find_arch(start):
    """Dir holding the project's root ARCHITECTURE.md, walking up from `start` and stopping at the
    repo root (.git), so a repo without one never inherits a parent dir's."""
    p = Path(start).expanduser().resolve()
    for d in [p, *p.parents]:
        if (d / ARCH).is_file():
            return d
        if (d / ".git").exists():
            return None
    return None


def bash_target(cmd):
    """First absolute (or ~) code path in a Bash command: the shell's cwd is often another project
    (`cd`/absolute paths), so the file decides whose ARCHITECTURE.md applies. Relative -> None (cwd)."""
    # Write segments first; then the whole command, since a `&&` inside a heredoc string can split a
    # script's `p="/abs/x.py"` from its `open(p,"w")`.
    script = _drop_data_heredocs(cmd)
    fallback = script if PY_WRITE.search(script) else ""
    for text in (" ".join(write_texts(cmd)), fallback):
        for m in CODE_PATH.finditer(text):
            if m.group().startswith(("/", "~", "$HOME/")):
                return m.group().replace("$HOME", "~", 1)
    return None


def _arch_key(root):
    return "arch-" + hashlib.sha1(str(root).encode()).hexdigest()[:10]


def _touch(m):
    m.parent.mkdir(parents=True, exist_ok=True)
    m.touch()


def decide_pre(payload):
    if os.environ.get("CODING_RULES_GATE") == "0":
        return None
    tool, inp, sid = payload.get("tool_name"), payload.get("tool_input") or {}, payload.get("session_id")
    if not is_code_write(tool, inp):
        return None
    target = inp.get("file_path") or inp.get("notebook_path") or bash_target(str(inp.get("command", "")))
    arch = find_arch(Path(target).expanduser().parent if target else payload.get("cwd") or os.getcwd())
    missing = []
    rule = rule_file()
    if rule and not (sid and _marker(sid).exists()):
        missing.append(MSG.format(path=rule))
    if arch and not (sid and _marker(sid, _arch_key(arch)).exists()):
        missing.append(ARCH_MSG.format(path=arch / ARCH))
    if not missing:
        return None
    out = {"hookEventName": "PreToolUse"}
    if not sid:  # cannot track the session -> remind, never block
        out["additionalContext"] = " ".join(missing)
    else:
        out.update(permissionDecision="deny", permissionDecisionReason=" ".join(missing))
    return {"hookSpecificOutput": out}


def record_post(payload):
    sid, tool, inp = payload.get("session_id"), payload.get("tool_name"), payload.get("tool_input") or {}
    if not sid:
        return
    if reads_file(tool, inp, "coding.md"):
        _touch(_marker(sid))
    if reads_file(tool, inp, ARCH):
        # Read gives the exact file; for Bash, the project is the one the shell is in.
        start = Path(inp["file_path"]).parent if tool == "Read" else payload.get("cwd") or os.getcwd()
        arch = find_arch(start)
        if arch:
            _touch(_marker(sid, _arch_key(arch)))


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    try:
        payload = json.load(sys.stdin)
        out = decide_pre(payload) if mode == "pre" else record_post(payload) if mode == "post" else None
    except Exception:
        return  # fail open
    if out:
        print(json.dumps(out))


if __name__ == "__main__":
    main()
