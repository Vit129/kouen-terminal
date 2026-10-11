# Local macOS CI with Tartelet

The owner's Apple silicon Mac can run Harness CI directly and host isolated macOS VMs. Tart is installed; Tartelet 0.12.0 is installed in `~/Applications/Tartelet.app`. The current release supports both organization and repository runner scopes, despite the older wiki describing only organizations. See its [runner scope source](https://github.com/framna-dk/tartelet/blob/0.12.0/Packages/GitHub/Sources/GitHubDomain/GitHubRunnerScope.swift).

## Checks

Run `Scripts/ci-macos.sh` from a checkout. It reports the installed Swift/Xcode versions, builds debug and release products, runs the complete test suite with live daemon tests and coverage, and builds the committed Xcode project without distribution signing. It uses a temporary Harness home so these checks do not use normal app settings or sessions. Benchmarks are opt-in and remain separate from correctness CI.

The [Local macOS CI workflow](../.github/workflows/local-macos.yml) runs the same script on a runner labeled `harness-macos`. It is manually dispatched and restricted to `main`, with read-only repository permission and no persisted checkout credential. Pull-request jobs continue using GitHub-hosted runners. The existing protected release workflow retains signing and notarization secrets; they are not placed in the VM template.

Both macOS CI paths also run `Scripts/test-macos-upgrade.py` against the published 2.1.0 service binary, downloaded with a pinned SHA-256. In a disposable home, it verifies that restart without explicit force preserves the old service, then that an authorized restart brings up the current service with a restored terminal. This covers the running-service upgrade boundary that fresh, same-version tests missed in 2.3.0; startup recovery controls and socket-owner preservation also have focused unit coverage.

## VM template

The preparation uses the upstream image `ghcr.io/cirruslabs/macos-tahoe-xcode:27` from [Cirrus Labs](https://github.com/cirruslabs/macos-image-templates/releases/tag/27), named `harness-ci-base`. The image has the Tart guest agent for `tart exec`. The downloaded template boots macOS 26.6.2 with Xcode 27.0; `tart exec` and Remote Login were verified. Local Xcode 27 checks supplement the shipping CI/release toolchain, which remains Xcode 26.6. A VM run is not evidence of physical GPU performance; guest Metal support and skipped cases must be reported as observed.

Tartelet clones the base for each runner and discards the job VM after use. Start with one VM, 8 CPUs and 16 GB RAM. Keep source-only shared directories read-only; avoid sharing the host home or Keychain. The base image should contain build tools, not release credentials or a persistent GitHub access token.

## Repository registration

The private App `Harness Local macOS CI` (App ID `5270413`) is installed only on `robzilla1738/harness-terminal`. Tartelet's key is imported into the host Keychain, the base image and guest SSH login are configured, and `Harness Local macOS 1` has been verified online with `harness-macos`.

The [2.3.0 validation run](https://github.com/robzilla1738/harness-terminal/actions/runs/38116314695) passed at source `6ba5115a610d5b2f192ee1d18ef44f4852eb0c2f`: debug and release builds, 2,513 XCTest cases with zero failures and 65 skips, and the Xcode app build. Skips include optional benchmark/fixture and font cases; this does not establish physical GPU performance. After the job, Tartelet replaced the used registration with a fresh online, idle runner. Automatic startup remains disabled; start the fleet in Tartelet when local CI is needed.

Configure Tartelet's GitHub scope as **Repository**, owner `robzilla1738`, repository `harness-terminal`. It needs a private GitHub App installed only for this repository, its App ID, and its private key. Prepare it at [GitHub App registration](https://github.com/settings/apps/new):

- Name: `Harness Local macOS CI` (use a unique suffix if GitHub reports it taken).
- Homepage: `https://github.com/robzilla1738/harness-terminal`.
- Webhook: inactive; no callback URL, OAuth user authorization, or event subscriptions.
- Repository permissions: **Administration: Read and write**, **Metadata: Read-only**. Leave all other repository, organization, and account permissions unset.
- Installation availability: **Only on this account**. Install on **Only select repositories**, selecting `harness-terminal`.

Administration write access is required by GitHub to register repository runners and is broader than build read access. Review that grant explicitly. Generate/download the app's private key and choose it in Tartelet; Tartelet stores its credential in the host Keychain. Do not commit the PEM or place it in the VM. The App's installation access token is exchanged for short-lived runner registration tokens. Configure the extra runner label as `harness-macos`, keep default macOS/ARM64 labels, and leave automatic startup disabled until the first job is verified.

Creating or installing that GitHub App is a distinct access-grant step. Preparation of the app, VM and workflow does not establish that a runner is registered or online. Verify the runner under the repository's Actions settings, dispatch Local macOS CI for `main`, and verify the run's commit and conclusion before calling the setup complete.

The stock image and Tartelet SSH configuration need a working guest login. Confirm the template can boot, run `tart exec`, and accept the configured SSH connection before starting the fleet. The template is retained for later ephemeral jobs; completed job VMs should be removed by Tartelet.
