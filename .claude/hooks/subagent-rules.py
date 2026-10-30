#!/usr/bin/env python3
"""subagent-rules: give every subagent the core coding rules (SubagentStart).

Why: SessionStart context and the CLAUDE.md imports reach the main thread only, so a spawned
subagent writes code without the rules the main session follows. This injects a short digest
plus the path of the full rules file. Fails open on any error. Disable with SUBAGENT_RULES=0;
SUBAGENT_RULES_MATCH=<regex> limits it to matching agent types (case-insensitive).
"""
import json
import os
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import _aodd_paths  # noqa: E402

DIGEST = """AODD rules for this subagent:
- Verify in full: read every file or source your answer depends on; never infer content from a filename. Say "not checked" for anything you did not read.
- Scope is every place the change must reach (callers, tests, fixtures, config, exports); extra features are not.
- Smallest complete change: reuse what the codebase has, then stdlib/platform, then an installed dependency; never add a dependency for a few lines. No wrapper, option or "for later" code nobody asked for.
- Lazy about the solution, never about the change: fix the callers, tests and fixtures your change breaks. Moved code keeps its error handling and validation.
- Never cut: validation at trust boundaries, error handling that prevents data loss, security, anything asked for.
- A deliberate shortcut gets `shortcut: <the limit>, <when to upgrade>`.
- End with one or two lines: what you skipped or did not check, and any risk."""


def decide(payload):
    if os.environ.get("SUBAGENT_RULES") == "0":
        return None
    match = os.environ.get("SUBAGENT_RULES_MATCH")
    if match:
        try:
            if not re.search(match, str(payload.get("agent_type") or ""), re.I):
                return None
        except re.error:
            pass  # a bad regex never drops the rules
    text = DIGEST
    rules = _aodd_paths.claude_home() / "rules" / "coding.md"
    if rules.is_file():
        text += f"\nBefore editing code, read {rules}."
    return {"hookSpecificOutput": {"hookEventName": "SubagentStart", "additionalContext": text}}


if __name__ == "__main__":
    try:
        out = decide(json.loads(sys.stdin.read() or "{}"))
        if out:
            print(json.dumps(out))
    except Exception:
        pass
    sys.exit(0)
