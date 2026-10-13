SHELL := /bin/bash

.PHONY: build test test-live lint bench bench-record bench-check preview preview-stop preview-clean release release-notes package dmg smoke-dmg sign appcast finalize hotfix-release icon clean

build:
	swift build

# Unit suites. Live daemon/PTY suites skip without HARNESS_LIVE_DAEMON_TESTS=1, and the
# summary at the end counts them so a skipped suite never reads as a pass.
test:
	set -o pipefail; swift test 2>&1 | python3 Scripts/test-summary.py

# Everything `test` runs plus the live daemon/PTY integration suites (what CI runs).
test-live:
	set -o pipefail; HARNESS_LIVE_DAEMON_TESTS=1 swift test 2>&1 | python3 Scripts/test-summary.py

# swift-format findings on lines changed since the merge base with origin/main (CI gate).
lint:
	python3 Scripts/lint-changed-lines.py

bench:
	HARNESS_BENCHMARKS=1 swift test -c release --filter HarnessBenchmarks

# Record the current run as the committed benchmark baseline (do this deliberately, in the
# same PR as an intentional performance change, on the hardware class you gate on).
bench-record:
	set -o pipefail; HARNESS_BENCHMARKS=1 swift test -c release --filter HarnessBenchmarks 2>&1 \
		| python3 Scripts/benchmarks/compare_benchmarks.py --record benchmark-baselines.json

# Compare a fresh run against the committed baseline; exits non-zero on a >15% regression, or
# when a baselined benchmark did not run or a new one is unrecorded (--strict).
bench-check:
	set -o pipefail; HARNESS_BENCHMARKS=1 swift test -c release --filter HarnessBenchmarks 2>&1 \
		| python3 Scripts/benchmarks/compare_benchmarks.py --strict --baseline benchmark-baselines.json

preview:
	./Scripts/preview.sh

# Stop only this preview GUI. The service uses an atomic empty check; explicit
# FORCE=1 passes --force and interrupts the isolated preview's shells/programs.
preview-stop:
	@pattern="$$(python3 -c 'import re,sys; print(re.escape(sys.argv[1]) + "$$")' "$(CURDIR)/.harness-preview/HarnessPreview.app/Contents/MacOS/Harness")"; pkill -f "$$pattern" 2>/dev/null || true
	@products="$$(swift build --show-bin-path)"; \
	if [ -e .harness-preview/daemon.pid ] || [ -e .harness-preview/harness.sock ]; then \
		authorization=--if-empty; \
		if [ "$(FORCE)" = 1 ]; then authorization=--force; fi; \
		HARNESS_HOME="$(CURDIR)/.harness-preview" "$$products/harness-cli" kill-server "$$authorization"; \
	fi

preview-clean: preview-stop
	rm -rf .harness-preview

icon:
	./Scripts/generate-app-icon.sh

# Regenerate the post-update banner's notes from the top CHANGELOG.md block.
# Run in release prep after editing CHANGELOG.md (guarded by ReleaseNotesGuardTests).
release-notes:
	swift Scripts/generate-release-notes.swift

release: icon
	./Scripts/build-release.sh

package: release

# Release order: make release -> make sign -> make dmg -> make finalize.
# dmg/sign/finalize operate on the EXISTING Harness.app so a prior signature is never
# rebuilt away. (When dmg/sign depended on `release`, running `make dmg` after `make sign`
# re-created an UNSIGNED Harness.app and shipped an unsigned DMG.) Each script fails clearly
# if Harness.app is missing, so run `make release` first.
dmg:
	./Scripts/create-dmg.sh

smoke-dmg:
	./Scripts/smoke-dmg.sh

sign:
	./Scripts/sign-and-notarize.sh

# Generate/refresh the Sparkle appcast from signed archives in ./dist (see the script header).
appcast:
	./Scripts/generate-appcast.sh

# Finalize a release: notarize + staple the DMG, re-upload to the GitHub release, build the
# appcast, optionally deploy it to the site. Needs ASC_ISSUER_ID (or APPLE_ID/APPLE_TEAM_ID/
# APPLE_APP_PASSWORD) and one keychain Allow for the Sparkle key. See Scripts/finalize-release.sh.
finalize:
	./Scripts/finalize-release.sh

hotfix-release:
	./Scripts/release-hotfix.sh

clean:
	swift package clean
	rm -rf Harness.app Harness.dmg Harness-notarize.zip dist .dmg-staging .icon-staging.iconset
