#!/usr/bin/env python3
"""UserPromptSubmit hook: word-boundary keyword match against skill-keywords.json.

skill-keywords.json is the sole source of truth for the keyword -> skill
table (there is no separate rules/skill-routing.md in this project — skill
names here must match a real invocable skill name exactly, e.g. a plugin
must be prefixed like "9arm-skills:debug-mantra"). Silent no-op on no
match or any error, so a broken hook never blocks a prompt.
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
        skills = rule["skill"] if isinstance(rule["skill"], list) else [rule["skill"]]
        for kw in rule["keywords"]:
            if re.search(r"\b" + re.escape(kw.lower()) + r"\b", prompt):
                invoke = ", ".join(f"Skill({s})" for s in skills)
                message = (
                    f"Skill-trigger keyword detected: {kw} -> invoke "
                    f"{invoke} before responding, per "
                    f".claude/hooks/skill-keywords.json."
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
