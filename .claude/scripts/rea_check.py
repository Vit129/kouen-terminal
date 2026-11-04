#!/usr/bin/env python3
"""Check REA (rea-agents) against the latest release and each agent's registration; --update fixes what is stale.

  rea_check.py [--client claude_code --client codex ...] [--update]

Read-only without --update: prints installed vs latest version and `rea doctor` per client, exit 1 if anything
needs attention (cron-friendly). --update installs the latest rea-agents globally when it is newer, then re-runs
`rea setup --client <c> --yes` for each client doctor flagged. install.sh need not be re-run for either.
Env: AODD_REA_CMD (launcher override), AODD_REA_LATEST (skip the npm lookup; tests).
"""
import argparse
import os
import re
import shlex
import shutil
import subprocess
import sys

PIN = "6.8.0"  # fallback npx version when no `rea` is installed
CLIENTS = ["claude_code", "codex", "antigravity"]


def launcher():
    if os.environ.get("AODD_REA_CMD"):
        return shlex.split(os.environ["AODD_REA_CMD"])
    if shutil.which("rea"):
        return ["rea"]
    if shutil.which("npx"):
        return ["npx", "-y", f"rea-agents@{PIN}"]
    return None


def run(cmd):
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=180)
        return p.returncode, (p.stdout + p.stderr).strip()
    except (OSError, subprocess.TimeoutExpired) as e:
        return 1, str(e)


def semver(text):
    m = re.search(r"(\d+)\.(\d+)\.(\d+)", text or "")
    return tuple(int(x) for x in m.groups()) if m else None


def fmt(v):
    return ".".join(map(str, v)) if v else "unknown"


def latest_version():
    if os.environ.get("AODD_REA_LATEST"):
        return semver(os.environ["AODD_REA_LATEST"])
    if not shutil.which("npm"):
        return None
    rc, out = run(["npm", "view", "rea-agents", "version"])
    return semver(out) if rc == 0 else None


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--client", action="append", choices=CLIENTS, help="repeatable; default all three")
    ap.add_argument("--update", action="store_true", help="install the latest rea-agents and re-run setup where doctor failed")
    a = ap.parse_args(argv)
    clients = a.client or CLIENTS
    rea = launcher()
    if not rea:
        print("FAIL  neither rea nor npx found; install Node, then ./install.sh")
        return 1

    problems = 0
    rc, out = run(rea + ["--version"])
    have, want = semver(out) if rc == 0 else None, latest_version()
    print(f"rea     installed {fmt(have)}, latest {fmt(want)}")
    updated = False
    if have and want and have < want:
        problems += 1
        print("STALE   a newer rea-agents exists")
        if a.update:
            if not shutil.which("npm"):
                print("FAIL    npm not found, cannot update")
            else:
                rc, out = run(["npm", "install", "-g", f"rea-agents@{fmt(want)}"])
                updated = rc == 0
                print("ok      updated" if updated else f"FAIL    npm install failed: {out[-300:]}")
                rea = launcher() or rea  # the global `rea` now exists

    for c in clients:
        rc, out = run(rea + ["doctor", "--client", c])
        if rc == 0 and not updated:
            print(f"ok      {c}")
            continue
        problems += 1
        print(f"FIX     {c}: doctor exit {rc}: {out[-200:]}")
        if a.update:
            rc, out = run(rea + ["setup", "--client", c, "--yes"])
            print(f"        setup {'ok' if rc == 0 else 'FAILED: ' + out[-200:]}")
    return 1 if problems and not a.update else 0


if __name__ == "__main__":
    sys.exit(main())
