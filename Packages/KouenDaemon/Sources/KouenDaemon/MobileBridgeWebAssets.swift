import Foundation

// Retired in P51 (Kouen Companion mobile PWA).
// No longer bundles xterm.js or addon-fit.js — the mobile client is now a lightweight native PWA chat interface.
#if canImport(Network)
enum MobileBridgeWebAssets {
    static let xtermJS = ""
    static let xtermCSS = ""
    static let addonFitJS = ""
}
#endif
