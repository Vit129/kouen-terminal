#!/usr/bin/env bash
# Full cycle: build first (verify) -> bump version -> commit+push -> open app.
# If build fails AFTER bump, version files are rolled back automatically.
#
# Usage:
#   Scripts/full-cycle.sh [patch|minor|major] [--version X.Y.Z] [--build N]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

usage() {
  cat <<'USAGE'
Usage:
  Scripts/full-cycle.sh [patch|minor|major] [--version X.Y.Z] [--build N]

Runs:
  1. Pre-build verification (swift build).
  2. Bump release metadata.
  3. Build production app.
  4. If prod build fails → rollback version bump.
  5. Commit and push.
  6. Open the app.
USAGE
}

case "${1:-}" in
  -h|--help|help)
    usage
    exit 0
    ;;
esac

# Step 1: Pre-build verification — catch compile errors BEFORE bumping version.
echo ""
echo "▶ Step 1: Verifying build..."
if ! swift build 2>&1 | tail -3; then
  echo ""
  echo "❌ Build failed — fix errors before releasing."
  exit 1
fi
echo "✅ Build verified."

# Step 2: Bump version.
echo ""
echo "▶ Step 2: Bumping version..."
./Scripts/prepare-release.sh "$@"

# Step 3: Build production app. Rollback on failure.
echo ""
echo "▶ Step 3: Building production app..."
if ! ./Scripts/run.sh prod; then
  echo ""
  echo "❌ Production build failed — rolling back version bump..."
  git checkout -- \
    Apps/Harness/Sources/HarnessApp/Resources/Info.plist \
    Packages/HarnessCore/Sources/HarnessCore/HarnessVersion.swift \
    Packages/HarnessCore/Sources/HarnessCore/ReleaseNotes/GeneratedReleaseNotes.swift \
    CHANGELOG.md
  echo "↩️  Version files restored. Fix the build and try again."
  exit 1
fi

# Step 4: Commit and push.
git_dir="$(git rev-parse --git-dir)"
if [[ "$git_dir" == *"worktrees"* ]]; then
  echo "Detected: running in a worktree — merging into main first."
  ./Scripts/commit-push-merge.sh

  common_dir="$(git rev-parse --git-common-dir)"
  main_repo="$(cd "$(dirname "$common_dir")" && pwd)"
  echo "Code merged to main."
  cd "$main_repo"
  git pull --ff-only origin main
else
  ./Scripts/commit-push.sh
fi

# Step 5: Tag + GitHub release.
echo ""
echo "▶ Step 5: Tagging and creating GitHub release..."
NEW_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT/Apps/Harness/Sources/HarnessApp/Resources/Info.plist")"
TAG="v${NEW_VERSION}"

# Read changelog for this version (between first two ## headers)
NOTES="$(sed -n "/^## \[${NEW_VERSION}\]/,/^## \[/{/^## \[${NEW_VERSION}\]/d;/^## \[/d;p}" CHANGELOG.md 2>/dev/null)" || NOTES=""
if [[ -z "$NOTES" ]]; then
  NOTES="Release ${TAG}"
fi

git tag -f "$TAG" -m "$TAG"
git push origin main --tags --force
gh release create "$TAG" --title "$TAG" --notes "$NOTES" 2>/dev/null \
  || gh release edit "$TAG" --title "$TAG" --notes "$NOTES" 2>/dev/null \
  || echo "⚠️  GitHub release skipped (gh CLI not configured or tag exists)"

echo ""
echo "✅ Full cycle complete. Version: $TAG"
