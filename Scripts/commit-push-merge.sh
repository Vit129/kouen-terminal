#!/usr/bin/env bash
# Commit + push + auto-merge into main. Used by `make start` option 1, and by
# full-cycle.sh's Step 3 (worktree or plain checkout, main or feature branch)
# so a release always ends up actually merged instead of leaving an
# unmerged PR that the rest of the cycle silently builds/tags around.
#
# - Commits any pending changes (prompts for a Conventional Commit message).
# - Rebases onto origin/main, pushes (force-with-lease, retries on conflict).
# - If already on main, push is sufficient.
# - Otherwise opens (or reuses) a PR into main, merges it, then deletes
#   the branch.
#
# Usage: Scripts/commit-push-merge.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ -n "$(git status --porcelain)" ]]; then
  echo ""
  git status -s
  echo ""
  echo "Conventional commit format: <type>(<scope>): <summary>"
  echo "  types: feat, fix, refactor, chore, docs, test, perf, build, ci"
  echo ""
  msg="${COMMIT_MESSAGE:-${1:-}}"
  if [[ -z "$msg" ]]; then
    read -erp "Commit message: " msg
  fi
  if [[ -z "$msg" ]]; then
    echo "Empty commit message — aborting." >&2
    exit 1
  fi
  git add -A

  # A release commit (full-cycle.sh's Step 2 stages Info.plist on every bump) needs a
  # version/bump/release/build keyword or .githooks/commit-msg rejects it — auto-tag so
  # the guardrail never blocks on a forgotten keyword. Inert on a non-bumping commit
  # (Info.plist isn't staged then), so this is safe to run unconditionally here.
  if git diff --cached --name-only | grep -q "Info.plist" && ! echo "$msg" | grep -qiE "version|bump|release|build|[0-9]+\.[0-9]+\.[0-9]+"; then
    ver="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Apps/Kouen/Sources/KouenApp/Resources/Info.plist 2>/dev/null || true)"
    if [[ -n "$ver" ]]; then
      msg="${msg} (release v${ver})"
    fi
  fi

  git commit -m "$msg"
else
  echo "Nothing to commit — using existing commit(s)."
fi

echo ""
echo "Fetching origin/main..."
git fetch origin main

branch="$(git branch --show-current)"

if [[ "$branch" != "main" ]]; then
  echo "Rebasing onto origin/main..."
  git rebase origin/main
fi

echo "Pushing to origin/$branch..."
if ! git push origin "HEAD:$branch" --force-with-lease; then
  echo "Push rejected — pulling and retrying..." >&2
  git pull --rebase origin "$branch"
  git push origin "HEAD:$branch" --force-with-lease
fi

if [[ "$branch" == "main" ]]; then
  echo ""
  echo "Already on main — push complete. No PR needed."
  exit 0
fi

echo ""
echo "Creating pull request..."
pr_url="$(gh pr create --base main --head "$branch" --fill 2>/dev/null || true)"
if [[ -z "$pr_url" ]]; then
  pr_url="$(gh pr view "$branch" --json url --jq .url)"
  echo "Using existing PR: $pr_url"
else
  echo "PR created: $pr_url"
fi

gh pr ready "$pr_url" 2>/dev/null || true

echo "Merging into main..."
gh pr merge "$pr_url" --merge

git push origin --delete "$branch" 2>/dev/null || true

echo ""
echo "Done — changes merged into main."
