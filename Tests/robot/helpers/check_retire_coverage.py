#!/usr/bin/env python3
"""
Guard: every private var [String: T] in SessionCoordinator must have a
.removeValue call inside the terminalHosts.onRetire closure.

Exit 0 = clean. Exit 1 = missing cleanup (prints offending names).
"""
import re, sys

path = sys.argv[1] if len(sys.argv) > 1 else None
if not path:
    print("usage: check_retire_coverage.py <SessionCoordinator.swift>")
    sys.exit(2)

src = open(path).read()

# All private [String: T] dict properties (surfaceID.uuidString-keyed)
dict_re = re.compile(r'private var (\w+):\s*\[String:\s*\w[\w<>]*\]')
dicts = dict_re.findall(src)

if not dicts:
    print("No [String: T] dicts found — nothing to check")
    sys.exit(0)

# Extract onRetire closure body (text between the opening brace and its matching close)
retire_start = src.find('onRetire = {')
if retire_start == -1:
    print("ERROR: onRetire closure not found")
    sys.exit(1)

depth, i, retire_body = 0, retire_start, ''
for i, ch in enumerate(src[retire_start:], retire_start):
    if ch == '{':
        depth += 1
    elif ch == '}':
        depth -= 1
        if depth == 0:
            retire_body = src[retire_start:i + 1]
            break

missing = [d for d in dicts if f'{d}.removeValue' not in retire_body]

if missing:
    print(f"MISSING onRetire cleanup for: {', '.join(missing)}")
    print(f"Add  self?.{missing[0]}.removeValue(forKey: surfaceID.uuidString)  inside onRetire")
    sys.exit(1)

print(f"OK: {len(dicts)} dict(s) all have retire cleanup: {', '.join(dicts)}")
