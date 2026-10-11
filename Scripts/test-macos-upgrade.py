#!/usr/bin/env python3
"""Exercise an actual 2.1 service upgrade in a disposable home, using built products."""
import hashlib
import json
import os
from pathlib import Path
import plistlib
import subprocess
import tempfile
import threading
import time


ROOT = Path(__file__).resolve().parent.parent
LEGACY_SHA = "d5979eb96e66835298148820344922e999672bf498bbd3f12565a388bc75e2f5"
LEGACY_URL = "https://github.com/robzilla1738/harness-terminal/releases/download/v2.1.0/Harness.dmg"


def run(args, **kwargs):
    return subprocess.run(args, check=True, timeout=60, **kwargs)


def main():
    if os.uname().sysname != "Darwin":
        raise RuntimeError("This upgrade fixture requires macOS")
    products = Path(run(["swift", "build", "--show-bin-path"], cwd=ROOT,
                        capture_output=True, text=True).stdout.strip())
    cli = products / "harness-cli"
    cache = ROOT / ".build/upgrade-fixtures"
    cache.mkdir(parents=True, exist_ok=True)
    dmg = cache / "Harness-2.1.0.dmg"
    if not dmg.exists() or hashlib.sha256(dmg.read_bytes()).hexdigest() != LEGACY_SHA:
        run(["curl", "--fail", "--location", "--retry", "3", "--max-time", "55",
             "--output", str(dmg), LEGACY_URL])
    if hashlib.sha256(dmg.read_bytes()).hexdigest() != LEGACY_SHA:
        raise RuntimeError("Legacy fixture checksum mismatch")
    with open(ROOT / "Apps/Harness/Sources/HarnessApp/Resources/Info.plist", "rb") as file:
        expected = plistlib.load(file)
    # Short path keeps the Unix socket below Darwin's sockaddr_un limit.
    with tempfile.TemporaryDirectory(prefix="h-upgrade-", dir="/tmp") as directory:
        home = Path(directory)
        env = {key: value for key, value in os.environ.items()
               if key not in {"HARNESS_SERVER", "HARNESS_DAEMON_PATH"}}
        env.update(HARNESS_HOME=str(home), SHELL="/bin/sh")
        mount = home / "mount"
        mount.mkdir()
        mounted = False
        legacy = None

        def command(*args, check=True):
            result = subprocess.run([str(cli), *args], env=env, capture_output=True,
                                    text=True, timeout=20)
            if check and result.returncode != 0:
                raise RuntimeError(f"{' '.join(args)} failed: {result.stderr.strip()}")
            return result

        def wait_stats(version, build):
            deadline = time.monotonic() + 15
            while time.monotonic() < deadline:
                result = command("daemon-stats", "--json", check=False)
                if result.returncode == 0:
                    stats = json.loads(result.stdout)
                    if stats.get("version") == version and stats.get("build") == build:
                        return stats
                time.sleep(0.1)
            raise RuntimeError(f"Service did not become ready at {version}/{build}")

        try:
            run(["hdiutil", "attach", str(dmg), "-readonly", "-nobrowse",
                 "-mountpoint", str(mount)], capture_output=True)
            mounted = True
            app = home / "LegacyHarness.app"
            run(["ditto", str(mount / "Harness.app"), str(app)])
            run(["hdiutil", "detach", str(mount)], capture_output=True)
            mounted = False
            with open(home / "legacy.log", "wb") as log:
                legacy = subprocess.Popen([str(app / "Contents/MacOS/HarnessDaemon")],
                                          env=env, stdin=subprocess.DEVNULL,
                                          stdout=log, stderr=log)
            # Match launchd's reaping; otherwise this fixture's Python parent leaves
            # an exited Darwin owner as a zombie while the CLI waits for shutdown.
            threading.Thread(target=legacy.wait, daemon=True).start()
            before = wait_stats("2.1.0", 132)
            if before["surfaceCount"] < 1:
                raise RuntimeError("Legacy fixture did not create a live shell")
            session_ids = {row["id"] for row in json.loads(command("list-sessions", "--json").stdout)}
            if not session_ids:
                raise RuntimeError("Legacy fixture did not create a session")
            # Without explicit consent the old service must remain running.
            refused = command("daemon-restart", "--if-empty", check=False)
            if refused.returncode == 0 or legacy.poll() is not None:
                raise RuntimeError("Legacy service was stopped without explicit force")
            command("daemon-restart", "--force")
            after = wait_stats(expected["CFBundleShortVersionString"],
                               int(expected["CFBundleVersion"]))
            if after.get("daemonAvailable") is not True or after["surfaceCount"] < 1:
                raise RuntimeError("Upgraded service did not restore its saved terminal")
            restored_ids = {row["id"] for row in json.loads(command("list-sessions", "--json").stdout)}
            if restored_ids != session_ids:
                raise RuntimeError("Upgrade changed the saved session identities")
            legacy.wait(timeout=5)
            print(f"PASS: actual 2.1.0 service preserved without consent, then upgraded to "
                  f"{after['version']}/{after['build']} with its terminal restored")
        finally:
            # Every lifecycle command uses only this disposable home.
            command("kill-server", "--force", check=False)
            if legacy is not None and legacy.poll() is None:
                legacy.terminate()
                legacy.wait(timeout=5)
            if mounted:
                run(["hdiutil", "detach", str(mount)], capture_output=True)


if __name__ == "__main__":
    main()
