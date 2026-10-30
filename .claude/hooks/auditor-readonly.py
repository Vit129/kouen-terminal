#!/usr/bin/env python3
"""PreToolUse: an auditor run (AODD_AUDITOR=1, set by scripts/audit.py) may read and run checks, never write.

Denies Edit/Write/MultiEdit/NotebookEdit outright and Bash commands that write files or history.
audit.py also voids the audit if `git status` changed, so this is prevention, that is detection.
Known limit: Bash writes are caught by pattern (redirects, sed -i, rm/mv/cp, git commit/push...);
an interpreter writing a file (`python -c open(...,'w')`) slips past here and is caught by audit.py's git check.
"""
import json
import os
import re
import sys

WRITE_TOOLS = {"Edit", "Write", "MultiEdit", "NotebookEdit", "apply_patch"}  # apply_patch = Codex's edit tool (live-verified: tool_input {"command": "<patch>"}; its shell tool arrives as "Bash" with tool_input.command)
BASH_WRITE = re.compile(
    r"(?<![<>&0-9])>{1,2}(?!&|\s*/dev/null)"           # > file, >> file (not 2>&1, >/dev/null)
    r"|\bsed\s+(-\w*\s+)*-i|\bperl\s+-\w*i"
    r"|\b(rm|mv|cp|tee|touch|mkdir|rmdir|chmod|ln|truncate|dd)\b"
    r"|\bgit\s+(commit|push|add|reset|checkout|switch|merge|rebase|restore|clean|branch\s+-[dD]|stash(?!\s+(list|show)\b))\b"
    r"|\bgit\s+tag\s+(?!-l\b|--list\b|-n\b|--contains\b|--points-at\b)[^\s;&|]"  # bare `git tag` / `-l` / `stash list` only read
    r"|\bgh\s+(pr|issue)\s+(create|merge|edit|comment|close)\b")


def decide(payload: dict):
    if os.environ.get("AODD_AUDITOR") != "1":
        return None
    tool = payload.get("tool_name", "")
    if tool in WRITE_TOOLS:
        return f"auditor is read-only: {tool} denied"
    if tool == "Bash":
        cmd = str((payload.get("tool_input") or {}).get("command", ""))
        if BASH_WRITE.search(cmd):
            return "auditor is read-only: this command writes files or git history. Run read-only checks only."
    return None


def main():
    try:
        reason = decide(json.load(sys.stdin))
    except Exception:
        return
    if reason:
        print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse",
                                                 "permissionDecision": "deny", "permissionDecisionReason": reason}}))


if __name__ == "__main__":
    main()
