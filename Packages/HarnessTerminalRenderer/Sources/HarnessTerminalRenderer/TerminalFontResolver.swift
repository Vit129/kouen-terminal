import CoreGraphics
import CoreText
import Foundation

public struct ResolvedTerminalFont: Equatable, Sendable {
    public let requestedFamily: String
    public let effectiveFamily: String
    public let effectivePostScriptName: String
    public let pointSize: CGFloat
    public let fallbackUsed: Bool
    public let fallbackFamily: String?
    public var fallbackFamilies: [String] = []
    public var features: [String: Int] = [:]

    public init(
        requestedFamily: String,
        effectiveFamily: String,
        effectivePostScriptName: String,
        pointSize: CGFloat,
        fallbackUsed: Bool,
        fallbackFamily: String?
    ) {
        self.requestedFamily = requestedFamily
        self.effectiveFamily = effectiveFamily
        self.effectivePostScriptName = effectivePostScriptName
        self.pointSize = pointSize
        self.fallbackUsed = fallbackUsed
        self.fallbackFamily = fallbackFamily
    }
}

public enum TerminalFontResolver {
    public static let defaultFontFamily = "JetBrainsMono Nerd Font"
    public static let fallbackFontFamilies = [defaultFontFamily, "Menlo", "Monaco"]

    public static func resolve(
        fontFamily requestedFamily: String,
        size pointSize: CGFloat,
        fallbackFamilies: [String] = [],
        features: [String: Int] = [:]
    ) -> ResolvedTerminalFont {
        var resolved = resolvePrimary(fontFamily: requestedFamily, size: pointSize)
        resolved.fallbackFamilies = fallbackFamilies.map(normalizedRequest).filter { !$0.isEmpty }
        resolved.features = features
        return resolved
    }

    private static func resolvePrimary(fontFamily requestedFamily: String, size pointSize: CGFloat) -> ResolvedTerminalFont {
        let requested = normalizedRequest(requestedFamily)
        if requested.isEmpty {
            return menloFallback(requestedFamily: requested, size: pointSize)
        }
        if let candidate = exactFont(named: requested, size: pointSize) {
            return ResolvedTerminalFont(
                requestedFamily: requested,
                effectiveFamily: candidate.family,
                effectivePostScriptName: candidate.postScriptName,
                pointSize: pointSize,
                fallbackUsed: false,
                fallbackFamily: nil
            )
        }

        for fallback in fallbackFontFamilies where !sameFontName(fallback, requested) {
            if let candidate = exactFont(named: fallback, size: pointSize) {
                return ResolvedTerminalFont(
                    requestedFamily: requested,
                    effectiveFamily: candidate.family,
                    effectivePostScriptName: candidate.postScriptName,
                    pointSize: pointSize,
                    fallbackUsed: true,
                    fallbackFamily: fallback
                )
            }
        }

        return menloFallback(requestedFamily: requested, size: pointSize)
    }

    private static func menloFallback(requestedFamily: String, size pointSize: CGFloat) -> ResolvedTerminalFont {
        let font = CTFontCreateWithName("Menlo" as CFString, pointSize, nil)
        return ResolvedTerminalFont(
            requestedFamily: requestedFamily,
            effectiveFamily: CTFontCopyFamilyName(font) as String,
            effectivePostScriptName: CTFontCopyPostScriptName(font) as String,
            pointSize: pointSize,
            fallbackUsed: true,
            fallbackFamily: "Menlo"
        )
    }

    static func makeFont(from resolved: ResolvedTerminalFont) -> CTFont {
        let font = CTFontCreateWithName(resolved.effectivePostScriptName as CFString, resolved.pointSize, nil)
        var attributes: [CFString: Any] = [:]
        let cascade = resolved.fallbackFamilies.compactMap { name in
            exactFont(named: name, size: resolved.pointSize).map { CTFontCopyFontDescriptor($0.font) }
        }
        if !cascade.isEmpty { attributes[kCTFontCascadeListAttribute] = cascade }
        let features = resolved.features.sorted { $0.key < $1.key }.compactMap { tag, value -> [CFString: Any]? in
            guard tag.utf8.count == 4, tag.utf8.allSatisfy({ (32 ... 126).contains($0) }), value >= 0 else { return nil }
            return [kCTFontOpenTypeFeatureTag: tag, kCTFontOpenTypeFeatureValue: value]
        }
        if !features.isEmpty { attributes[kCTFontFeatureSettingsAttribute] = features }
        guard !attributes.isEmpty else { return font }
        let descriptor = CTFontDescriptorCreateWithAttributes(attributes as CFDictionary)
        return CTFontCreateCopyWithAttributes(font, resolved.pointSize, nil, descriptor)
    }

    private static func normalizedRequest(_ family: String) -> String {
        family.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func exactFont(named name: String, size: CGFloat) -> (font: CTFont, family: String, postScriptName: String)? {
        let font = CTFontCreateWithName(name as CFString, size, nil)
        let family = CTFontCopyFamilyName(font) as String
        let postScriptName = CTFontCopyPostScriptName(font) as String
        let fullName = CTFontCopyFullName(font) as String
        let displayName = CTFontCopyDisplayName(font) as String
        let resolvedNames = [family, postScriptName, fullName, displayName]
        guard resolvedNames.contains(where: { sameFontName($0, name) }) else { return nil }
        return (font, family, postScriptName)
    }

    private static func sameFontName(_ lhs: String, _ rhs: String) -> Bool {
        lhs.trimmingCharacters(in: .whitespacesAndNewlines)
            .caseInsensitiveCompare(rhs.trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame
    }
}
