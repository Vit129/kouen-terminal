#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

usage() {
  cat <<'USAGE'
Usage: Scripts/release-hotfix.sh --tag vX.Y.Z --build N [options]

Release an already prepared, committed main branch. Update Info.plist,
HarnessVersion.swift, CHANGELOG.md and generated release notes before running.

  --version X.Y.Z       Optional consistency check against --tag.
  --release-name NAME   Defaults to Harness X.Y.Z (N).
  --no-deploy-appcast   Publish downloads without changing the live updater feed.
  --skip-tests          Skip local tests; GitHub CI must still pass.
  --dry-run             Validate and print the release plan without publishing.
  -h, --help            Show this help.

Published tags and assets are never replaced. If website deployment fails after
publication, recover the existing release's appcast as described in docs/RELEASE.md.
USAGE
}

tag=""
version=""
build=""
release_name=""
deploy_appcast=true
run_tests=1
dry_run=0
while (($#)); do
  case "$1" in
    --tag) tag="${2:?Missing tag}"; shift 2 ;;
    --version) version="${2:?Missing version}"; shift 2 ;;
    --build) build="${2:?Missing build}"; shift 2 ;;
    --release-name) release_name="${2:?Missing release name}"; shift 2 ;;
    --no-deploy-appcast) deploy_appcast=false; shift ;;
    --skip-tests) run_tests=0; shift ;;
    --dry-run) dry_run=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done
[[ "$tag" =~ ^v[0-9]+[.][0-9]+[.][0-9]+$ && "$build" =~ ^[0-9]+$ ]] || { usage >&2; exit 2; }
version="${version:-${tag#v}}"
[[ "$version" == "${tag#v}" ]] || { echo "Version must match tag." >&2; exit 2; }
release_name="${release_name:-Harness $version ($build)}"

python3 - "$version" "$build" <<'PY'
from pathlib import Path
import plistlib, re, sys
version, build = sys.argv[1:]
with open("Apps/Harness/Sources/HarnessApp/Resources/Info.plist", "rb") as source:
    plist = plistlib.load(source)
code = Path("Packages/HarnessCore/Sources/HarnessCore/HarnessVersion.swift").read_text()
if (plist["CFBundleShortVersionString"] != version or plist["CFBundleVersion"] != build
        or re.search(r'static let short = "([^"]+)"', code)[1] != version
        or re.search(r'static let build = (\d+)', code)[1] != build):
    raise SystemExit("Prepare matching app, daemon and CLI versions before releasing.")
if f"## [{version}] - " not in Path("CHANGELOG.md").read_text():
    raise SystemExit("Add this version's public release notes to CHANGELOG.md first.")
PY

echo "Release $release_name from main; deploy appcast: $deploy_appcast; local tests: $run_tests."
if [[ "$dry_run" == 1 ]]; then exit 0; fi
[[ "$(git branch --show-current)" == main ]] || { echo "Run from main." >&2; exit 1; }
[[ -z "$(git status --porcelain)" ]] || { echo "Commit all release changes first." >&2; exit 1; }
git fetch origin main --tags
git merge-base --is-ancestor origin/main HEAD || { echo "Integrate origin/main and review the release again." >&2; exit 1; }
if git show-ref --verify --quiet "refs/tags/$tag"; then
  echo "Tag $tag already exists; recover its release or choose a new version." >&2
  exit 1
fi

if [[ "$run_tests" == 1 ]]; then
  swift build
  HARNESS_LIVE_DAEMON_TESTS=1 HARNESS_TEST_PRODUCTS="$(swift build --show-bin-path)" swift test
fi
git push origin main
head_sha="$(git rev-parse HEAD)"

wait_for_run() {
  local workflow="$1" id=""
  for _ in {1..30}; do
    id="$(gh run list --workflow "$workflow" --branch main --commit "$head_sha" --limit 1 --json databaseId --jq '.[0].databaseId // empty')"
    if [[ -n "$id" ]]; then gh run watch "$id" --exit-status; return; fi
    sleep 2
  done
  echo "No $workflow run found for $head_sha." >&2
  return 1
}
wait_for_run ci.yml
gh workflow run release.yml --ref main -f "tag=$tag" -f "release_name=$release_name" -f "deploy_appcast=$deploy_appcast"
wait_for_run release.yml
echo "Published $release_name. Verify the public download and update README's checksum without moving the release tag."
