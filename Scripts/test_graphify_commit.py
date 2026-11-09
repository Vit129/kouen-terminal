#!/usr/bin/env python3
"""Exercise shell delivery and compiled daemon commit commands in isolated Git repos."""
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class GraphCommitTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.build = tempfile.TemporaryDirectory(prefix="kouen graph swift ")
        build = Path(cls.build.name)
        (build / "main.swift").write_text('''import Foundation
let result = GitCommitCommand.run(Array(CommandLine.arguments.dropFirst()), in: FileManager.default.currentDirectoryPath)
FileHandle.standardOutput.write(Data(result.stdout.utf8))
FileHandle.standardError.write(Data(result.stderr.utf8))
exit(result.exitCode)
''')
        cls.binary = build / "commit"
        subprocess.run(["swiftc", "-swift-version", "6", "-warnings-as-errors",
                        str(ROOT / "Packages/KouenCore/Sources/KouenCore/Platform/ProcessRunner.swift"),
                        str(ROOT / "Packages/KouenCore/Sources/KouenCore/Platform/GitCommitCommand.swift"),
                        str(build / "main.swift"), "-o", str(cls.binary)], check=True)

    @classmethod
    def tearDownClass(cls):
        cls.build.cleanup()

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="kouen graph fixture ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.env = {**os.environ}
        self.real_git = shutil.which("git")
        self.git("init", "-b", "main")
        self.git("config", "user.name", "Fixture")
        self.git("config", "user.email", "fixture@example.invalid")
        self.git("config", "core.hooksPath", str(self.root / ".git/hooks"))
        (self.root / "graphify-out").mkdir()
        (self.root / "graphify-out/graph.json").write_text("old")
        (self.root / "product").write_text("old")
        self.git("add", "product", "graphify-out/graph.json")
        self.git("-c", "core.hooksPath=/dev/null", "commit", "-m", "fixture")
        (self.root / "product").write_text("new")
        self.git("add", "product")
        (self.root / "bin").mkdir()
        (self.root / "Scripts").mkdir()
        for name in ["graphify-commit.sh", "commit-push-merge.sh", "full-cycle.sh"]:
            shutil.copyfile(ROOT / "Scripts" / name, self.root / "Scripts" / name)
        (self.root / ".git/info/exclude").write_text("bin/\nScripts/\ngraphify-out/cache.tmp\n")
        self.stub("graphify", 'test "$PYTHONHASHSEED" = 0 || exit 8\necho fresh > graphify-out/graph.json\necho local > graphify-out/cache.tmp\n')
        # Keep git real for commits, but never fetch/push to an external service.
        import shlex
        self.stub("git", 'case "$1" in fetch) exit 0;; push) echo pushed >> .git/pushed; exit 0;; esac\nexec ' + shlex.quote(self.real_git) + ' "$@"\n')
        self.env["PATH"] = str(self.root / "bin") + os.pathsep + self.env["PATH"]
        for name, body in [("post-commit", '[ "$GRAPHIFY_SKIP_HOOK" = 1 ] || echo dirty >> graphify-out/graph.json\n'),
                           ("pre-commit", "echo checked > .git/pre-commit-ran\n")]:
            path = self.root / ".git/hooks" / name
            path.write_text("#!/bin/sh\n" + body)
            path.chmod(0o755)

    def stub(self, name, body):
        path = self.root / "bin" / name
        path.write_text("#!/bin/sh\n" + body)
        path.chmod(0o755)

    def git(self, *args):
        return subprocess.check_output([self.real_git, *args], cwd=self.root, text=True, env=self.env).strip()

    def invoke(self, route, fail=False):
        if fail:
            self.stub("graphify", "exit 9\n")
        if route == "full-cycle":
            self.stub("swift", "exit 0\n")
            args = ["bash", "Scripts/full-cycle.sh", "--no-bump", "-m", "fix: fixture", "-y"]
        elif route == "menu":
            args = ["bash", "Scripts/commit-push-merge.sh", "-m", "fix: fixture"]
        elif route == "release":
            args = ["bash", "-c", 'source Scripts/graphify-commit.sh; commit_with_graph -m "chore(release): fixture"']
        else:
            args = [str(self.binary), "commit", "-m", "fix: fixture's $message `literal`"]
        return subprocess.run(args, cwd=self.root, env=self.env, capture_output=True, text=True)

    def assert_committed(self):
        self.assertEqual(self.git("show", "HEAD:product"), "new")
        self.assertEqual(self.git("show", "HEAD:graphify-out/graph.json"), "fresh")
        self.assertEqual(self.git("diff", "--name-only"), "")
        self.assertEqual(self.git("rev-list", "--count", "HEAD"), "2")
        self.assertNotIn("cache.tmp", self.git("ls-tree", "-r", "--name-only", "HEAD"))
        self.assertTrue((self.root / ".git/pre-commit-ran").exists())

    def test_normal_menu_and_full_cycle_commit_entrypoint(self):
        result = self.invoke("menu")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_committed()
        self.assertTrue((self.root / ".git/pushed").exists())

    def test_normal_flow_failure_never_commits_or_pushes(self):
        result = self.invoke("menu", fail=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.git("rev-list", "--count", "HEAD"), "1")
        self.assertEqual(self.git("diff", "--cached", "--name-only"), "product")
        self.assertFalse((self.root / ".git/pushed").exists())

    def test_full_cycle_graph_failure_stops_before_install_or_push(self):
        result = self.invoke("full-cycle", fail=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Step 2: Skipping", result.stdout)
        self.assertNotIn("Step 4:", result.stdout)
        self.assertEqual(self.git("rev-list", "--count", "HEAD"), "1")
        self.assertFalse((self.root / ".git/pushed").exists())

    def test_release_commit_includes_graph(self):
        result = self.invoke("release")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_committed()

    def test_daemon_command_includes_graph_and_quotes_message(self):
        result = self.invoke("daemon")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_committed()
        self.assertEqual(self.git("log", "-1", "--format=%s"), "fix: fixture's $message `literal`")

    def test_daemon_failure_preserves_staging(self):
        result = self.invoke("daemon", fail=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.git("rev-list", "--count", "HEAD"), "1")
        self.assertEqual(self.git("diff", "--cached", "--name-only"), "product")

    def test_daemon_commit_without_graph_is_plain(self):
        self.git("rm", "-r", "-q", "--cached", "graphify-out")
        shutil.rmtree(self.root / "graphify-out")
        self.stub("graphify", "exit 9\n")
        result = self.invoke("daemon")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.git("rev-list", "--count", "HEAD"), "2")

    def test_unrelated_hook_failure_still_blocks(self):
        (self.root / ".git/hooks/pre-commit").write_text("#!/bin/sh\nexit 7\n")
        self.assertNotEqual(self.invoke("daemon").returncode, 0)
        self.assertEqual(self.git("rev-list", "--count", "HEAD"), "1")


if __name__ == "__main__":
    unittest.main()
