import AppKit
import SwiftUI

/// Self-contained design tokens for the Kouen CLI Onboarding app.
/// 
/// Values were lightly snapshotted at project creation time from the main Kouen
/// app's KouenChromePalette + KouenDesign (for visual consistency with the
/// terminal's glass/monochrome language) — there is NO runtime or build dependency.
/// This file is the single source of truth for colors, spacing, radius, and motion
/// inside this standalone wizard.
@MainActor
enum ImmersivePalette {
    // MARK: - Base surface (strict monochrome — pure black/white, matching Kouen's
    // single-flat-surface Liquid Glass language; chrome paints the exact terminal bg,
    // everything else is the foreground at low alpha. No color accent anywhere.)
    static let terminalBackground = NSColor.black                                     // #000000
    static let foreground = NSColor.white

    // Derived surfaces (flat chrome = exact terminal bg, elevated cards lift subtly)
    static let sidebarBackground = terminalBackground
    static let surfaceElevated: NSColor = foreground.withAlphaComponent(0.07)

    static let border: NSColor = foreground.withAlphaComponent(0.08)
    static let borderStrong: NSColor = foreground.withAlphaComponent(0.14)

    // "Accent" is monochrome white — energy comes from glass, motion, and contrast,
    // not from hue (exactly like the main Kouen chrome).
    static let accent = foreground
    static let accentSoft = foreground.withAlphaComponent(0.16)

    static let focusRing = foreground.withAlphaComponent(0.5)

    static let textPrimary = foreground
    static let textSecondary = foreground.withAlphaComponent(0.66)
    static let textTertiary = foreground.withAlphaComponent(0.40)

    static let rowSelectedFill = foreground.withAlphaComponent(0.08)
    static let rowHoverFill = foreground.withAlphaComponent(0.05)
    static let iconHoverFill = foreground.withAlphaComponent(0.08)

    // Status / semantic — the ONLY non-monochrome hues, used solely for functional
    // install/shell feedback (success check, errors), matching Kouen's status palette.
    static let success = NSColor(srgbRed: 0.59, green: 0.83, blue: 0.55, alpha: 1.0)
    static let warning = NSColor(srgbRed: 0.96, green: 0.78, blue: 0.32, alpha: 1.0)
    static let danger  = NSColor(srgbRed: 0.93, green: 0.49, blue: 0.55, alpha: 1.0)

    // MARK: - Spacing (exact match to Kouen for muscle-memory density)
    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 6
        static let md:  CGFloat = 8
        static let lg:  CGFloat = 12
        static let xl:  CGFloat = 16
        static let xxl: CGFloat = 22
        static let xxxl: CGFloat = 32
    }

    // MARK: - Radius (continuous corners everywhere)
    enum Radius {
        static let card:    CGFloat = 10
        static let pill:    CGFloat = 6
        static let badge:   CGFloat = 5
        static let control: CGFloat = 7
        static let overlay: CGFloat = 12
        static let capsule: CGFloat = 999
    }

    // MARK: - Motion (short, delightful, springy)
    enum Motion {
        static let micro: TimeInterval = 0.10
        static let fast:  TimeInterval = 0.16
        static let standard: TimeInterval = 0.24
        static let slow:  TimeInterval = 0.38

        /// The signature "glass entrance" spring used for the main panel, cards, and CTAs.
        static let springResponse: Double = 0.48
        static let springDamping: Double = 0.72
    }

    // MARK: - Typography helpers (SwiftUI)
    static let titleFont = NSFont.systemFont(ofSize: 28, weight: .semibold)
    static let headlineFont = NSFont.systemFont(ofSize: 17, weight: .semibold)
    static let bodyFont = NSFont.systemFont(ofSize: 13.5, weight: .regular)
    static let monoFont = NSFont.monospacedSystemFont(ofSize: 12, weight: .medium)

    // MARK: - SwiftUI Color convenience (keeps view code terse + monochrome-correct)
    //
    // Defined as plain `Color` literals (not derived from the `@MainActor` NSColor
    // statics) so they're usable from any isolation context. Kept in lockstep with the
    // NSColor values above.
    enum SUI {
        static let background = Color.black
        static let surfaceElevated = Color.white.opacity(0.07)
        static let border = Color.white.opacity(0.08)
        static let borderStrong = Color.white.opacity(0.14)
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.66)
        static let textTertiary = Color.white.opacity(0.40)
        static let success = Color(.sRGB, red: 0.59, green: 0.83, blue: 0.55, opacity: 1)
        static let warning = Color(.sRGB, red: 0.96, green: 0.78, blue: 0.32, opacity: 1)
        static let danger  = Color(.sRGB, red: 0.93, green: 0.49, blue: 0.55, opacity: 1)
    }
}