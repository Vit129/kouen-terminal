#!/usr/bin/env bash
# Full cycle: build first (verify) -> (optionally bump version) -> commit+push -> open app.
# If build fails AFTER bump, version files are rolled back automatically.
#
# Usage:
#   Scripts/full-cycle.sh [patch|minor|major] [--version X.Y.Z] [--build N] [--no-bump]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

usage() {
  cat <<'USAGE'
Usage:
  Scripts/full-cycle.sh [patch|minor|major] [--version X.Y.Z] [--build N] [--no-bump]

Runs:
  1. Pre-build verification (swift build).
  2. Bump release metadata (skipped with --no-bump).
  3. Build production app.
  4. If prod build fails → rollback version bump.
  5. Commit, push, CHANGELOG, tag, GitHub release.
  6. Install to /Applications via install-graceful — preserves session state, and
     skips the daemon restart (keeping running tasks alive) when the IPC protocol
     didn't change.
USAGE
}

NO_BUMP=0
BUMP_ARGS=()
for arg in "$@"; do
  if [[ "$arg" == "--no-bump" ]]; then
    NO_BUMP=1
  else
    BUMP_ARGS+=("$arg")
  fi
done

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

# Step 2: Bump version (skipped with --no-bump).
if [[ "$NO_BUMP" -eq 1 ]]; then
  echo ""
  echo "▶ Step 2: Skipping version bump (--no-bump)."
else
  echo ""
  echo "▶ Step 2: Bumping version..."
  ./Scripts/prepare-release.sh "${BUMP_ARGS[@]}"
fi

# Step 3: Commit and push.
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


# Step 4: Build production app + install to /Applications.
# Build BEFORE tagging/releasing so a broken build never creates a public tag.
# Uses install-graceful (not `make install`): it builds before touching the running
# app/daemon, preserves workspace/session state instead of wiping it, and — when the
# IPC wire protocol didn't change (the common case) — skips restarting the daemon
# entirely, so PTYs and agent tasks running under it survive this release. It also
# safely hands off to a detached process when run from inside a Kouen pane, unlike
# `make install`'s unconditional `pkill -x Kouen` which would kill this very session.
echo ""
echo "▶ Step 4: Building production app and installing (graceful)..."
if ! Scripts/install-graceful.sh; then
  echo ""
  echo "❌ Production build failed — rolling back version bump..."
  git checkout -- \
    Apps/Kouen/Sources/KouenApp/Resources/Info.plist \
    Packages/KouenCore/Sources/KouenCore/KouenVersion.swift \
    Packages/KouenCore/Sources/KouenCore/ReleaseNotes/GeneratedReleaseNotes.swift \
    CHANGELOG.md
  echo "↩️  Version files restored. Fix the build and try again."
  exit 1
fi

# Step 5: Generate CHANGELOG + tag + GitHub release via git-cliff.
echo ""
echo "▶ Step 5: Generating CHANGELOG and creating GitHub release..."
NEW_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT/Apps/Kouen/Sources/KouenApp/Resources/Info.plist")"
TAG="v${NEW_VERSION}"

if ! command -v git-cliff &>/dev/null; then
  echo "❌ git-cliff not found. Install with: brew install git-cliff"
  exit 1
fi

# Archive old minor/major versions before regenerating CHANGELOG.
# Keep: current minor (X.Y.*) + previous minor (X.Y-1.*)
# Archive: anything older than that into docs/CHANGELOG-archive.md
ARCHIVE_FILE="$ROOT/docs/CHANGELOG-archive.md"
mkdir -p "$ROOT/docs"
CURRENT_MAJOR="${NEW_VERSION%%.*}"
CURRENT_MINOR="${NEW_VERSION%.*}"; CURRENT_MINOR="${CURRENT_MINOR##*.}"
PREV_MINOR=$((CURRENT_MINOR - 1))

python3 - <<PYEOF "$ROOT/CHANGELOG.md" "$ARCHIVE_FILE" "$CURRENT_MAJOR" "$CURRENT_MINOR" "$PREV_MINOR"
import sys, re

changelog_path, archive_path, major, minor_s, prev_s = sys.argv[1:]
major, minor, prev = int(major), int(minor_s), int(prev_s)

with open(changelog_path, 'r') as f:
    content = f.read()

# Split into header + version blocks
header_match = re.match(r'(.*?)(?=^## \[)', content, re.DOTALL | re.MULTILINE)
header = header_match.group(1) if header_match else ''
blocks = re.findall(r'^## \[.*?(?=^## \[|\Z)', content, re.DOTALL | re.MULTILINE)

keep, archive = [], []
for block in blocks:
    m = re.match(r'^## \[(\d+)\.(\d+)\.\d+\]', block)
    if m:
        v_major, v_minor = int(m.group(1)), int(m.group(2))
        if v_major == major and v_minor >= prev:
            keep.append(block)
        else:
            archive.append(block)
    else:
        keep.append(block)

if archive:
    archive_header = "# Changelog Archive\n\nOlder releases. See [CHANGELOG.md](../CHANGELOG.md) for recent versions.\n\n"
    existing_archive = ''
    try:
        with open(archive_path, 'r') as f:
            existing = f.read()
            # strip header
            existing_archive = re.sub(r'^.*?(?=^## \[)', '', existing, flags=re.DOTALL|re.MULTILINE)
    except FileNotFoundError:
        pass
    with open(archive_path, 'w') as f:
        f.write(archive_header + ''.join(archive) + existing_archive)
    print(f"Archived {len(archive)} version block(s) to docs/CHANGELOG-archive.md")

with open(changelog_path, 'w') as f:
    f.write(header + ''.join(keep))
PYEOF

# Generate full CHANGELOG.md from all tags
git-cliff --tag "$TAG" --output CHANGELOG.md

# Generate release notes for this tag only (since previous tag)
PREV_TAG="$(git tag --sort=-v:refname | grep -v "^${TAG}$" | head -1)"
if [[ -n "$PREV_TAG" ]]; then
  NOTES="$(git-cliff "${PREV_TAG}..${TAG}" --strip header 2>/dev/null)" || NOTES="Release ${TAG}"
else
  NOTES="$(git-cliff --tag "$TAG" --strip header 2>/dev/null)" || NOTES="Release ${TAG}"
fi
# GitHub release-notes body caps at 125000 chars — an empty/wrong PREV_TAG (e.g. a
# broken tag lookup) would silently dump full project history past that limit and
# 422 on every create/edit attempt below.
NOTES_LEN=$(echo -n "$NOTES" | wc -c | tr -d ' ')
if [[ $NOTES_LEN -gt 120000 ]]; then
  echo "⚠️  generated notes are ${NOTES_LEN} chars, over the safe limit — truncating"
  NOTES="$(echo "$NOTES" | head -c 119000)"$'\n\n'"...(truncated, see CHANGELOG.md for the rest)"
fi

# Commit the updated CHANGELOG
git add CHANGELOG.md docs/CHANGELOG-archive.md 2>/dev/null || git add CHANGELOG.md
git commit -m "chore(release): update CHANGELOG for ${TAG}" || true

git tag -f "$TAG" -m "$TAG"
git push origin main
git push origin "refs/tags/$TAG" --force
# Errors are NOT swallowed here (previously 2>/dev/null on both attempts hid every
# failure — 20 releases went out with empty "Release vX.Y.Z" stub bodies over several
# weeks before anyone noticed, because nothing ever printed why). A create/edit
# failure is loud now but non-fatal: the tag/push already succeeded by this point, and
# the release can be fixed after the fact with `gh release edit "$TAG" --notes "..."`.
create_err="$(gh release create "$TAG" --title "$TAG" --notes "$NOTES" 2>&1 >/dev/null)"
if [[ $? -ne 0 ]]; then
  edit_err="$(gh release edit "$TAG" --title "$TAG" --notes "$NOTES" 2>&1 >/dev/null)"
  if [[ $? -ne 0 ]]; then
    echo "⚠️  GitHub release create AND edit both failed for $TAG:"
    echo "   create: $create_err"
    echo "   edit:   $edit_err"
    echo "   Fix manually with: gh release edit \"$TAG\" --notes \"\$(git-cliff <prev>..$TAG --strip header)\""
  fi
fi

echo ""
echo "✅ Full cycle complete. Version: $TAG"
