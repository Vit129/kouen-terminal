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
# Usage: Scripts/commit-push-merge.sh [-m <message>] [-y|--yes] [<message>]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

msg="${COMMIT_MESSAGE:-}"
auto_yes=0

while (($#)); do
  case "$1" in
    -m|--message)
      msg="${2:?Missing value for -m/--message}"
      shift 2
      ;;
    --message=*)
      msg="${1#*=}"
      shift
      ;;
    -y|--yes)
      auto_yes=1
      shift
      ;;
    -h|--help)
      echo "Usage: Scripts/commit-push-merge.sh [-m <message>] [-y|--yes] [<message>]"
      exit 0
      ;;
    *)
      if [[ -z "$msg" ]]; then
        msg="$1"
      fi
      shift
      ;;
  esac
done

if [[ -n "$(git status --porcelain)" ]]; then
  echo ""
  git status -s
  echo ""
  echo "Conventional commit format: <type>(<scope>): <summary>"
  echo "  types: feat, fix, refactor, chore, docs, test, perf, build, ci"
  echo ""
  if [[ -z "$msg" ]]; then
    if [[ -t 0 ]]; then
      read -erp "Commit message: " msg
    else
      # Non-interactive / AI mode fallback:
      # If Info.plist is modified/staged, this is a version bump commit
      if git diff --cached --name-only | grep -q "Info.plist" || git diff --name-only | grep -q "Info.plist"; then
        ver="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Apps/Kouen/Sources/KouenApp/Resources/Info.plist 2>/dev/null || true)"
        msg="chore(release): bump version (v${ver:-unknown})"
        echo "Non-interactive / AI mode: auto-generated commit message: $msg"
      else
        echo "❌ Empty commit message — in non-interactive/AI mode, provide a message via -m \"<msg>\" or COMMIT_MESSAGE=\"<msg>\"." >&2
        exit 1
      fi
    fi
  fi
  if [[ -z "$msg" ]]; then
    echo "Empty commit message — aborting." >&2
    exit 1
  fi
  # graphify-out/ refreshes go on their own `chore(graphify)` commit, never a feature/release one.
  git add -A ':!graphify-out'

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

# If graphify-out/ was refreshed earlier, commit it on its own commit per repo rules
if [[ -n "$(git status --porcelain graphify-out)" ]]; then
  git add graphify-out
  git commit -m "chore(graphify): refresh" || true
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
