#!/usr/bin/env python3
"""UserPromptSubmit hook: word-boundary keyword match against skill-keywords.json.

Source of truth for the keyword -> skill table is skill-keywords.json
(kept in sync with rules/skill-routing.md). Silent no-op on no match or
any error, so a broken hook never blocks a prompt.
"""
import json
import re
import sys
from pathlib import Path


def main():
    data = json.load(sys.stdin)
    prompt = data.get("prompt", "").lower()

    rules_path = Path(__file__).resolve().parent / "skill-keywords.json"
    rules = json.loads(rules_path.read_text())

    for rule in rules:
        skill = rule["skill"]
        for kw in rule["keywords"]:
            if re.search(r"\b" + re.escape(kw.lower()) + r"\b", prompt):
                message = (
                    f"Skill-trigger keyword detected: {kw} -> invoke "
                    f"Skill({skill}) before responding, per rules/skill-routing.md."
                )
                print(json.dumps({
                    "hookSpecificOutput": {
                        "hookEventName": "UserPromptSubmit",
                        "additionalContext": message,
                    }
                }))
                return


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
