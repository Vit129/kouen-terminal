#!/usr/bin/env python3
"""Rebuild the generated block of <memory dir>/INDEX.md from the files on disk, so the agent never
spends tokens keeping the catalog by hand. Text outside the markers is kept. No model calls.

  python3 memory_index.py <memory dir>      # e.g. the dir that holds knowledge/ and plans/
"""
import sys
from pathlib import Path

START, END = "<!-- auto:index (memory_index.py) -->", "<!-- /auto:index -->"
PROGRESS = ("ai-sdlc-task-progress.md", "dev-task-progress.md", "qa-task-progress.md")


def title(f):
    for line in f.read_text(encoding="utf-8", errors="ignore").splitlines():
        if line.startswith("#"):
            return line.lstrip("# ").strip()[:80]
    return ""


def block(m):
    rows = ["## Knowledge", "| File | Title |", "|---|---|"]
    k = m / "knowledge"
    rows += [f"| {f.relative_to(m)} | {title(f)} |" for f in sorted(k.rglob("*.md")) if f.is_file()] if k.is_dir() else []
    rows += ["", "## Plans", "| Plan | Status | Next open box |", "|---|---|---|"]
    p = m / "plans"
    for f in sorted(x for n in PROGRESS for x in p.rglob(n)) if p.is_dir() else []:
        lines = f.read_text(encoding="utf-8", errors="ignore").splitlines()
        box = next((l.strip()[6:] for l in lines if l.lstrip().startswith("- [ ]")), "")
        status = "moved" if any(l.startswith("Moved to:") for l in lines) else "open" if box else "done"
        rows.append(f"| {f.parent.relative_to(m)} | {status} | {box[:80] if status == 'open' else ''} |")
    return "\n".join([START, *rows, END])


def rebuild(m):
    m = Path(m)
    idx = m / "INDEX.md"
    old = idx.read_text(encoding="utf-8") if idx.is_file() else "# Agent Memory Index\n"
    s, e = old.find(START), old.find(END)
    new = old[:s] + block(m) + old[e + len(END):] if s != -1 and e > s else old.rstrip() + "\n\n" + block(m) + "\n"
    idx.write_text(new, encoding="utf-8")
    return idx


if __name__ == "__main__":
    if len(sys.argv) != 2 or not Path(sys.argv[1]).is_dir():
        sys.exit("usage: memory_index.py <memory dir>")
    print(rebuild(sys.argv[1]))
