#!/usr/bin/env python3
"""
Guard: every private var [String: T] in a service file must have explicit cleanup.

Modes:
  --mode retire  (default): .removeValue call inside the onRetire closure
  --mode filter : self-reassigning .filter call (snapshot-sweep pattern)

Exit 0 = clean. Exit 1 = missing cleanup (prints offending names).
"""
import re, sys, argparse

parser = argparse.ArgumentParser()
parser.add_argument("path")
parser.add_argument("--mode", choices=["retire", "filter"], default="retire")
args = parser.parse_args()

src = open(args.path).read()

# All private [String: T] dict properties (surfaceID.uuidString-keyed)
dict_re = re.compile(r'private var (\w+):\s*\[String:\s*\w[\w<>]*\]')
dicts = dict_re.findall(src)

if not dicts:
    print("No [String: T] dicts found — nothing to check")
    sys.exit(0)

if args.mode == "retire":
    # Extract onRetire closure body (text between the opening brace and its matching close)
    retire_start = src.find('onRetire = {')
    if retire_start == -1:
        print("ERROR: onRetire closure not found")
        sys.exit(1)

    depth, retire_body = 0, ''
    for i, ch in enumerate(src[retire_start:], retire_start):
        if ch == '{':
            depth += 1
        elif ch == '}':
            depth -= 1
            if depth == 0:
                retire_body = src[retire_start:i + 1]
                break

    missing = [d for d in dicts if f'{d}.removeValue' not in retire_body]
    label = "onRetire cleanup"

elif args.mode == "filter":
    # Each dict must be reassigned via self-filter: `x = x.filter { live.contains… }`
    src_nospace = re.sub(r'\s+', '', src)
    missing = [d for d in dicts if f'{d}={d}.filter' not in src_nospace]
    label = "snapshot-sweep filter cleanup"

if missing:
    print(f"MISSING {label} for: {', '.join(missing)}")
    if args.mode == "retire":
        print(f"Add  self?.{missing[0]}.removeValue(forKey: surfaceID.uuidString)  inside onRetire")
    else:
        print(f"Add  {missing[0]} = {missing[0]}.filter {{ live.contains($0.key) }}  in the snapshot-sync sweep")
    sys.exit(1)

print(f"OK: {len(dicts)} dict(s) all have {label}: {', '.join(dicts)}")
