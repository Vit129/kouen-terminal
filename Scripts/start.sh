#!/usr/bin/env bash
# Interactive build & release menu for Harness.app.
#
# Usage:
#   Scripts/start.sh        # interactive menu
#   make start               # same, via Makefile
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

INFO_PLIST="Apps/Harness/Sources/HarnessApp/Resources/Info.plist"
RELEASE_NOTES_SWIFT="Packages/HarnessCore/Sources/HarnessCore/ReleaseNotes/GeneratedReleaseNotes.swift"

current_version() {
  /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$INFO_PLIST"
}

current_build() {
  /usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFO_PLIST"
}

changelog_version() {
  grep -m1 -oE '^## \[[^]]+\]' CHANGELOG.md | sed -E 's/^## \[(.+)\]$/\1/'
}

commit_and_push() {
  if [[ -z "$(git status --porcelain)" ]]; then
    echo "Nothing to commit — working tree is clean."
    return
  fi

  echo ""
  git status -s
  echo ""
  echo "Conventional commit format: <type>(<scope>): <summary>"
  echo "  types: feat, fix, refactor, chore, docs, test, perf, build, ci"
  echo ""
  read -rp "Commit message: " msg
  if [[ -z "$msg" ]]; then
    echo "Empty commit message — aborting." >&2
    exit 1
  fi

  git add -A
  git commit -m "$msg"

  local branch
  branch="$(git branch --show-current)"
  git push -u origin "$branch"

  if [[ "$branch" != "main" ]]; then
    read -rp "Open a PR for '$branch' into main? (y/N): " open_pr
    if [[ "$open_pr" =~ ^[Yy]$ ]]; then
      gh pr create --fill --base main --head "$branch" || gh pr view --web
    fi
  fi
}

# Bumps Info.plist + git tag from the unreleased CHANGELOG.md entry, then offers
# to dispatch Scripts/release-hotfix.sh (the actual signed/notarized CI release —
# requires explicit confirmation since it publishes to all users).
prepare_release() {
  local plist_version plist_build cl_version
  plist_version="$(current_version)"
  plist_build="$(current_build)"
  cl_version="$(changelog_version)"

  echo ""
  echo "Info.plist version/build: $plist_version ($plist_build)"
  echo "CHANGELOG.md top version:  $cl_version"
  echo ""

  if [[ "$cl_version" == "$plist_version" ]]; then
    echo "CHANGELOG.md's top entry ($cl_version) matches the shipped Info.plist version." >&2
    echo "Add a new '## [X.Y.Z] - $(date +%Y-%m-%d)' section to CHANGELOG.md describing" >&2
    echo "this release's changes, commit it (option 1), then re-run." >&2
    exit 1
  fi

  local next_build=$((plist_build + 1))
  read -rp "Build number for $cl_version [$next_build]: " build_input
  local build="${build_input:-$next_build}"

  echo ""
  echo "Regenerating release notes from CHANGELOG.md [$cl_version]..."
  make release-notes

  if ! git diff --quiet -- "$RELEASE_NOTES_SWIFT" CHANGELOG.md; then
    git add CHANGELOG.md "$RELEASE_NOTES_SWIFT"
    git commit -m "chore: release notes for v$cl_version"
    git push origin main
  fi

  echo ""
  echo "Ready to release v$cl_version via Scripts/release-hotfix.sh."
  echo "This bumps Info.plist to $cl_version ($build), pushes, tags v$cl_version,"
  echo "and triggers the signed/notarized GitHub Actions release — published to all users."
  echo ""
  read -rp "Run release-hotfix.sh now? (y/N): " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    exec ./Scripts/release-hotfix.sh --tag "v$cl_version" --version "$cl_version" --build "$build"
  else
    echo "Skipped. Run manually when ready:"
    echo "  ./Scripts/release-hotfix.sh --tag v$cl_version --version $cl_version --build $build"
  fi
}

echo ""
echo "Harness build & release"
echo ""
echo "  1) Commit + push changes"
echo "  2) Build app and install to /Applications"
echo "  3) Build app only (you copy Harness.app to /Applications yourself)"
echo "  4) Prepare release (changelog -> release notes -> tag -> CI release)"
echo ""
read -rp "Enter choice (1-4): " choice

case "$choice" in
  1)
    commit_and_push
    ;;
  2)
    exec Scripts/install-app.sh
    ;;
  3)
    make release
    echo ""
    echo "Done. Harness.app is at $ROOT/Harness.app"
    echo "Copy it to /Applications when you're ready."
    ;;
  4)
    prepare_release
    ;;
  *)
    echo "Invalid choice" >&2
    exit 1
    ;;
esac
