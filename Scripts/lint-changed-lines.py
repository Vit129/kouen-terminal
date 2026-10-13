#!/usr/bin/env python3
"""Fail on swift-format findings that land on lines changed since a base revision.

The tree predates `.swift-format`, so linting whole files reports thousands of existing
violations. This gate holds new and edited lines to the config without a mass reformat:

    Scripts/lint-changed-lines.py                 # against the merge base with origin/main
    Scripts/lint-changed-lines.py --base <rev>    # against a specific base (CI passes the PR base)

Uncommitted edits count as changed. Exits 1 when a blocking finding is on a changed line.

Layout findings from the pretty-printer (indentation, spacing, line breaks, trailing commas) are
printed but do not fail: house style aligns continuation lines and keeps short guards on one
line, which the printer always rewrites. Rule findings, `LineLength`, and `TrailingWhitespace`
block.
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

LINT_ROOTS = ("Apps/", "Packages/", "Tools/", "Tests/", "Package.swift")
HUNK = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@")
FINDING = re.compile(r"^(?P<path>.+?):(?P<line>\d+):(?P<column>\d+): (?:warning|error): (?P<message>.*)$")
ADVISORY = {"Indentation", "Spacing", "AddLines", "RemoveLine", "TrailingComma"}
CATEGORY = re.compile(r"^\[(\w+)\]")


def git(*args: str) -> str:
    return subprocess.run(["git", *args], check=True, capture_output=True, text=True).stdout


def resolve_base(requested: str | None) -> str:
    if requested:
        return git("merge-base", requested, "HEAD").strip()
    for candidate in ("origin/main", "main"):
        try:
            return git("merge-base", candidate, "HEAD").strip()
        except subprocess.CalledProcessError:
            continue
    sys.exit("lint-changed-lines: no base revision; pass --base")


def changed_lines(base: str) -> dict[str, set[int]]:
    diff = git("diff", "-U0", "--no-color", "--diff-filter=AMR", base, "--", "*.swift")
    changes: dict[str, set[int]] = {}
    path = None
    for line in diff.splitlines():
        if line.startswith("+++ "):
            target = line[4:]
            path = target[2:] if target.startswith("b/") else None
            if path and not path.startswith(LINT_ROOTS):
                path = None
            continue
        match = HUNK.match(line)
        if match and path:
            start, count = int(match.group(1)), int(match.group(2) or "1")
            if count:
                changes.setdefault(path, set()).update(range(start, start + count))
    return changes


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--base", help="revision to diff against (default: merge base with origin/main)")
    args = parser.parse_args()

    root = Path(git("rev-parse", "--show-toplevel").strip())
    base = resolve_base(args.base)
    changes = changed_lines(base)
    files = [path for path in changes if (root / path).is_file()]
    if not files:
        print("lint-changed-lines: no changed Swift lines")
        return 0

    result = subprocess.run(
        ["swift", "format", "lint", "--configuration", str(root / ".swift-format"), *files],
        cwd=root, capture_output=True, text=True,
    )
    blocking, advisory = [], []
    parsed_any = False
    for line in (result.stdout + result.stderr).splitlines():
        match = FINDING.match(line)
        if not match:
            continue
        parsed_any = True
        path = Path(match.group("path"))
        relative = str(path.relative_to(root)) if path.is_absolute() else str(path)
        if int(match.group("line")) not in changes.get(relative, ()):
            continue
        message = match.group("message")
        entry = f"{relative}:{match.group('line')}:{match.group('column')}: {message}"
        category = CATEGORY.match(message)
        (advisory if category and category.group(1) in ADVISORY else blocking).append(entry)
    if result.returncode != 0 and not parsed_any:
        sys.stderr.write(result.stderr)
        return result.returncode or 1

    changed_count = sum(len(lines) for lines in changes.values())
    scope = f"{changed_count} changed line(s) in {len(files)} file(s)"
    if advisory:
        print("\n".join(f"advisory: {entry}" for entry in advisory))
    if blocking:
        print("\n".join(blocking))
        print(f"lint-changed-lines: {len(blocking)} blocking finding(s) on {scope}")
        return 1
    print(f"lint-changed-lines: clean ({scope}, {len(advisory)} advisory layout note(s))")
    return 0


if __name__ == "__main__":
    sys.exit(main())
