# Changelog / Release Automation

Sub-file of `rules/coding.md`; read when cutting a release.

**`git-cliff`** (`brew install git-cliff`) is the standard tool for `CHANGELOG.md` generation and GitHub Release notes on any project that publishes tagged releases — parses the Commit Style types above via `cliff.toml`'s `commit_parsers` (feat→Added, fix→Fixed, refactor/perf→Changed, docs→Documentation; test/chore/build/ci/style skipped). Skip it for repos with no GitHub Releases, or a fork whose release pipeline is upstream's to own — check for an existing release script before adding one.

**Release gate (before the bump and tag; one place, the workflow files point here):**
1. **Security / pen test:** secret scan, dependency vulnerabilities, SAST; for anything reachable from outside (web app, API, open port), test the auth and trust boundaries as an attacker would, at least the surfaces Phase 2 flagged (`security` skill if installed).
2. **Performance:** against the NFRs set in ai-sdlc Phase 2, or when the project has a perf budget or the change touches a hot path: a k6 load test against the test server (thresholds on p95 latency and error rate; `performance-testing` skill), compared with the last release; bundle size or Core Web Vitals for a front end. Nothing to measure → say so in the release notes, don't skip silently.
3. **Audit:** `scripts/audit.py` PASS on this diff (an earlier PASS counts if nothing changed since).
4. **Version + changelog:** semver bump, `git-cliff --tag vX.Y.Z --output CHANGELOG.md`, commit `chore(release): vX.Y.Z`, tag.

A typical per-project `scripts/release.sh` bumps the version (file convention varies: `package.json`/`pyproject.toml`/`Info.plist`/git-tag-only), runs `git-cliff --tag vX.Y.Z --output CHANGELOG.md`, tags, pushes, then `gh release create --notes "$NOTES"`.

**Deployment integrity (all production targets, regardless of host):**
- **One release identity:** decide the version, tag, source commit, and target environment once. The version shown by the app/package, Git tag, changelog, hosted release, and deployed artifact must refer to that same source. If a manifest is needed to establish this, include the source commit and relevant external/shared dependency commits.
- **Reproducible inputs:** test and build the committed release source with locked dependencies. A build that reads another local repository or generated input must pin and record that input, or verify that it is clean and synchronized before publishing; never silently deploy bytes from uncommitted or moving sources.
- **Validate before publishing:** finish required tests, build checks, and release gates before pushing a release commit/tag or publishing to a production target. A full-cycle command must stop on commit, push, test, or build failure; it must not continue to deploy an older or unpushed tree.
- **Deploy only an identified release:** production deploy-only commands should deploy the artifact for a tagged/released source and target. If a project intentionally supports deploying an arbitrary snapshot, label it separately and keep it out of the production release path.
- **Retry the same release:** make release steps idempotent. On retry, inspect which version, commit, tag, hosted release, and deployment already exist; complete the missing step for that same version. Do not silently bump to the next version because a previous publish or deploy step failed. Repair partial pushes with a safe fast-forward and matching tag push; do not force-push production refs as recovery.
- **Preserve ambiguous work:** if failure occurs before the release commit and the working tree contains partial metadata changes, do not infer ownership from filenames or overwrite them automatically. Report the affected paths and give a safe recovery path that preserves user edits.
- **Verify and record the result:** after deploy, verify the live target reports the intended version and source/dependency identity (or an equivalent health/revision signal). Keep a concise deployment history with target, release version, source identity, time, outcome, and a short explanation for exceptions or recovery.

**Never swallow `gh release create`/`gh release edit` errors with `2>/dev/null`** — capture stderr separately and print it on failure, or a broken release step silently ships empty-body releases. Also guard `$NOTES` length — GitHub's release-body cap is 125000 chars, and a wrong previous-tag range can silently dump full project history past that limit and 422 every time.

**Don't call `release.sh --version X.Y.Z` to skip ahead in the version sequence** — always drive the bump through `major`/`minor`/`patch` so the number tracks actual accumulated changes. `--version` exists for genuine exceptions (aligning to an externally-mandated number, recovering from a botched tag), not to make a release "feel" more milestone-worthy. If `--version` is genuinely the right call, say why in the release commit message.
