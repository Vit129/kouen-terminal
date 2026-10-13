#!/usr/bin/env python3
"""Pass `swift test` output through and end with executed, failed, and skipped totals.

`swift test` runs many XCTest bundles plus swift-testing suites and prints a summary per
bundle, so a skipped live-daemon suite is easy to miss. Usage:

    set -o pipefail; swift test 2>&1 | python3 Scripts/test-summary.py

Skips are grouped by reason. Exits 1 when any test failed or when no test ran at all, so
an over-narrow filter does not read as a green run.
"""

from __future__ import annotations

import re
import sys
from collections import Counter

XCTEST_RESULT = re.compile(r"^Test Case '-\[(?P<name>[^\]]+)\]' (?P<result>passed|failed|skipped)")
XCTEST_SKIP_REASON = re.compile(r"-\[(?P<name>[^\]]+)\] : Test skipped(?: - (?P<reason>.*))?$")
TESTING_RUN = re.compile(r"Test run with (?P<count>\d+) tests? .*(?P<result>passed|failed)")
TESTING_ISSUES = re.compile(r"with (?P<issues>\d+) issues?")
TESTING_SKIP = re.compile(r"Test (?P<name>\S+) skipped(?:: \"?(?P<reason>[^\"]*)\"?)?")


def main() -> int:
    counts = Counter()
    failed_names: list[str] = []
    skip_reasons: dict[str, str] = {}
    skips = Counter()
    for raw in sys.stdin:
        sys.stdout.write(raw)
        line = raw.strip()
        if match := XCTEST_SKIP_REASON.search(line):
            skip_reasons[match.group("name")] = (match.group("reason") or "no reason given").strip()
        if match := XCTEST_RESULT.match(line):
            counts[match.group("result")] += 1
            if match.group("result") == "failed":
                failed_names.append(match.group("name"))
            elif match.group("result") == "skipped":
                skips[skip_reasons.get(match.group("name"), "no reason given")] += 1
        elif match := TESTING_RUN.search(line):
            total = int(match.group("count"))
            if match.group("result") == "failed":
                issues = TESTING_ISSUES.search(line)
                counts["testing_failed"] += int(issues.group("issues")) if issues else 1
            counts["testing"] += total
        elif match := TESTING_SKIP.search(line):
            counts["testing_skipped"] += 1
            skips[match.group("reason") or "no reason given"] += 1
    sys.stdout.flush()

    executed = counts["passed"] + counts["failed"] + counts["testing"]
    failed = counts["failed"] + counts["testing_failed"]
    skipped = counts["skipped"] + counts["testing_skipped"]
    print("\n== test summary ==")
    print(f"executed {executed} (XCTest {counts['passed'] + counts['failed']}, swift-testing {counts['testing']})")
    print(f"failed   {failed}")
    print(f"skipped  {skipped}")
    for reason, count in skips.most_common():
        print(f"  {count:>4}  {reason}")
    for name in failed_names[:20]:
        print(f"  FAILED {name}")
    if executed == 0:
        print("no tests ran: check the filter", file=sys.stderr)
        return 1
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
