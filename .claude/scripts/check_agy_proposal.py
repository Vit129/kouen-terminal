#!/usr/bin/env python3
"""Reject an agy-proposal that lacks evidence, before it reaches the CEO.

Every proposal must carry the analysis and the full evidence chain from the session that produced it:
Project, Repo, What, Analysis, Code, Test, Fix, Verified, Commit, Proposed change. Checked mechanically:
each field present and non-trivial; What targets ~/.claude (project lessons belong in that project's
AGENTS.md); Repo is a git repo and Commit exists in it; Test and Verified are not the same text.
Known limit: this proves the evidence is present and the commit is real, not that the output is honest;
the Haiku triage and the CEO still judge the content.

    python3 scripts/check_agy_proposal.py <proposal.md>...   # prints "ok" or reasons; exit 1 on any reject
"""
import re
import subprocess
import sys
from pathlib import Path

FIELDS = ["Project", "Repo", "What", "Analysis", "Code", "Test", "Fix", "Verified", "Commit", "Proposed change"]
FIELD = re.compile(r"^\s*-\s*\*\*(%s):\*\*" % "|".join(map(re.escape, FIELDS)), re.M)
HASH = re.compile(r"\b[0-9a-f]{7,40}\b")
MIN_LEN = 8  # shorter than this is a placeholder ("TBD", "n/a", "yes")


def fields(text: str) -> dict:
    """{field: value}; a value runs until the next known field (so code blocks may span lines)."""
    marks = list(FIELD.finditer(text))
    return {m.group(1): text[m.end():(marks[i + 1].start() if i + 1 < len(marks) else len(text))].strip()
            for i, m in enumerate(marks)}


def problems(text: str) -> list:
    f = fields(text)
    out = [f"missing or empty **{k}:**" for k in FIELDS if len(f.get(k, "")) < MIN_LEN and k not in ("Project", "Repo", "Commit")]
    out += [f"missing **{k}:**" for k in ("Project", "Repo", "Commit") if not f.get(k)]
    what = f.get("What", "")
    if what and ".claude/" not in what:
        out.append("What does not target ~/.claude: a project lesson goes in that project's AGENTS.md on its branch")
    repo = Path(f.get("Repo", "").strip("` ").replace("~", str(Path.home()), 1))
    hashes = HASH.findall(f.get("Commit", ""))
    if f.get("Repo") and not (repo / ".git").exists():
        out.append(f"Repo is not a git repo: {repo}")
    elif f.get("Commit") and not hashes:
        out.append("Commit has no commit hash")
    elif hashes and not any(subprocess.run(["git", "-C", str(repo), "cat-file", "-e", f"{h}^{{commit}}"],
                                           capture_output=True).returncode == 0 for h in hashes):
        out.append(f"Commit {hashes[0]} does not exist in {repo}")
    if f.get("Test") and f.get("Test") == f.get("Verified"):
        out.append("Verified repeats Test: show the re-run after the fix")
    return out


def main(argv) -> int:
    bad = 0
    for path in argv:
        found = problems(Path(path).read_text(errors="ignore"))
        print(f"{path}: " + ("ok" if not found else "REJECT: " + "; ".join(found)))
        bad += bool(found)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
