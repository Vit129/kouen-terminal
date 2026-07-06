import AppKit
import Sparkle

/// Wraps Sparkle's standard updater. This fork has no appcast of its own yet — the upstream
/// `SUFeedURL`/`SUPublicEDKey` were removed from Info.plist so this build never checks or
/// installs updates signed by the original project's key. `startingUpdater: false` keeps the
/// controller inert until this fork stands up its own release feed. The Check-for-Updates menu
/// item still targets `controller` but is a no-op without a configured feed.
@MainActor
final class SparkleUpdater {
    static let shared = SparkleUpdater()

    let controller = SPUStandardUpdaterController(
        startingUpdater: false,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )

    private init() {}

    /// The action the "Check for Updates…" menu item points at (`SPUStandardUpdaterController`
    /// implements `checkForUpdates(_:)`).
    static let checkForUpdatesAction = #selector(SPUStandardUpdaterController.checkForUpdates(_:))
}
