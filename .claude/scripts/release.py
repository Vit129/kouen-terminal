#!/usr/bin/env python3
"""Version, changelog, tag, push, and publish an AODD release."""

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

def find_repo_root(start: Path) -> Path:
    for directory in (start, *start.parents):
        if (directory / ".git").exists() and (directory / "VERSION").is_file() and (directory / "cliff.toml").is_file():
            return directory
    raise RuntimeError("Run the release command from inside an aodd-aisdlc checkout.")


ROOT = find_repo_root(Path.cwd())
VERSION_FILE = ROOT / "VERSION"
CHANGELOG_FILE = ROOT / "CHANGELOG.md"
VERSION_RE = re.compile(r"^(\d+)\.(\d+)\.(\d+)$")


def next_version(version: str, bump: str) -> str:
    match = VERSION_RE.fullmatch(version.strip())
    if not match:
        raise ValueError(f"Invalid semver in VERSION: {version!r}")
    major, minor, patch = map(int, match.groups())
    if bump == "major":
        return f"{major + 1}.0.0"
    if bump == "minor":
        return f"{major}.{minor + 1}.0"
    return f"{major}.{minor}.{patch + 1}"


def version_tuple(version: str) -> tuple[int, int, int]:
    match = VERSION_RE.fullmatch(version.strip())
    if not match:
        raise ValueError(f"Invalid semver: {version!r}")
    return tuple(map(int, match.groups()))


def run(args: list[str], *, capture: bool = False, check: bool = True) -> subprocess.CompletedProcess:
    result = subprocess.run(args, cwd=ROOT, text=True, capture_output=capture)
    if check and result.returncode:
        detail = (result.stderr or result.stdout or "").strip()
        raise RuntimeError(f"Command failed ({' '.join(args)}): {detail}")
    return result


def output(*args: str) -> str:
    return run(list(args), capture=True).stdout.strip()


def release_exists(tag: str) -> bool:
    releases = json.loads(output("gh", "release", "list", "--limit", "1000", "--json", "tagName"))
    return any(release.get("tagName") == tag for release in releases)


def publish(tag: str, *, push_main: bool = True) -> None:
    if output("git", "status", "--porcelain"):
        raise RuntimeError("Release publishing requires a clean working tree.")
    if push_main:
        run(["git", "merge-base", "--is-ancestor", "origin/main", "HEAD"])
        run(["git", "push", "origin", "main", tag])
    else:
        run(["git", "push", "origin", tag])
    if release_exists(tag):
        print(f"GitHub Release {tag} already exists; release is complete.")
        return
    notes = output("git", "cliff", "--latest", "--strip", "header")
    if len(notes) > 125_000:
        raise RuntimeError("Generated release notes exceed GitHub's 125000-character limit.")
    run(["gh", "release", "create", tag, "--title", tag, "--notes", notes])


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("bump", nargs="?", choices=("patch", "minor", "major"), default="patch")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--resume", action="store_true", help="complete the current tagged release without bumping")
    args = parser.parse_args()

    branch = output("git", "branch", "--show-current")
    if branch != "main":
        raise RuntimeError(f"Release must run from main (current branch: {branch}).")
    remote_url = output("git", "remote", "get-url", "origin").lower()
    if "aodd-aisdlc" not in remote_url:
        raise RuntimeError(f"Refusing to release from an unexpected origin: {remote_url}")
    run(["git", "fetch", "origin", "main", "--tags"])

    version = VERSION_FILE.read_text().strip()
    tag = f"v{version}"
    tags = output("git", "tag", "--list", "v*").splitlines()
    valid_tags = [value[1:] for value in tags if VERSION_RE.fullmatch(value.removeprefix("v"))]
    latest_tag_version = max(valid_tags, key=version_tuple) if valid_tags else "0.0.0"
    head = output("git", "rev-parse", "HEAD")
    remote = output("git", "rev-parse", "origin/main")
    tag_result = run(["git", "rev-parse", "--verify", f"refs/tags/{tag}^{{commit}}"], capture=True, check=False)
    tag_commit = tag_result.stdout.strip() if tag_result.returncode == 0 else ""
    subject = output("git", "log", "-1", "--format=%s")

    # Finish a release commit that was created before its tag/push/release step failed.
    if subject == f"chore(release): {tag}":
        if tag_commit and tag_commit != head:
            raise RuntimeError(f"Tag {tag} points to {tag_commit}, but its release commit is {head}; resolve the tag mismatch manually.")
        if tag_commit != head:
            run(["git", "merge-base", "--is-ancestor", "origin/main", "HEAD"])
            if args.dry_run:
                print(f"Would tag and publish the pending release {tag} from {head}.")
                return 0
            run(["git", "tag", tag])
            publish(tag)
            return 0

    # A release tag at HEAD is either already done or needs its hosted release completed.
    if tag_commit == head:
        if args.dry_run:
            action = "resume" if args.resume else "start the next version after"
            print(f"Would {action} {tag}.")
            return 0
        if args.resume:
            publish(tag)
            return 0
        if not release_exists(tag):
            publish(tag)
            return 0

    if args.resume:
        if tag_commit:
            tagged_version = output("git", "show", f"{tag}:VERSION")
            if tagged_version != version:
                raise RuntimeError(f"Tag {tag} contains VERSION {tagged_version}, expected {version}; resolve the tag mismatch manually.")
            if args.dry_run:
                print(f"Would resume the existing {tag} release.")
                return 0
            publish(tag, push_main=False)
            return 0
        if version_tuple(version) <= version_tuple(latest_tag_version):
            raise RuntimeError(f"No pending release for VERSION {version}; latest tag is v{latest_tag_version}.")

    if output("git", "status", "--porcelain"):
        raise RuntimeError("Release requires a clean working tree; preserve and resolve all edits first.")
    if head != remote:
        raise RuntimeError("Local main differs from origin/main; synchronize before release.")
    run(["gh", "auth", "status"])
    run(["git", "cliff", "--version"])

    # A committed VERSION bump ahead of the latest tag is a pending release, not a request to skip it.
    pending_version = version_tuple(version) > version_tuple(latest_tag_version)
    new_version = version if pending_version else next_version(version, args.bump)
    new_tag = f"v{new_version}"
    changelog = output("git", "cliff", "--tag", new_tag)
    if args.dry_run:
        action = "complete" if pending_version else "create"
        print(f"Would {action} {new_tag}, update VERSION/CHANGELOG.md if needed, commit, push, and create a GitHub Release.")
        return 0

    if not pending_version:
        VERSION_FILE.write_text(f"{new_version}\n")
    CHANGELOG_FILE.write_text(changelog)
    run(["git", "add", "VERSION", "CHANGELOG.md"])
    if output("git", "diff", "--cached", "--name-only"):
        run(["git", "commit", "-m", f"chore(release): {new_tag}"])
    run(["git", "tag", new_tag])
    publish(new_tag)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, ValueError) as exc:
        print(f"release failed: {exc}", file=sys.stderr)
        raise SystemExit(1)
