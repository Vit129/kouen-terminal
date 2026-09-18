import AppKit
import KouenIPC
import SwiftUI

/// A centralized, reusable badge for an agent brand logo and display name.
/// Reuses `AgentIconRenderer` (vector brand marks) and `AgentKind.dotHex`.
public struct AgentBadgeView: View {
    public let kind: AgentKind
    public var iconSize: CGFloat
    public var fontSize: CGFloat
    public var showName: Bool

    public init(
        kind: AgentKind,
        iconSize: CGFloat = 12,
        fontSize: CGFloat = 9.5,
        showName: Bool = true
    ) {
        self.kind = kind
        self.iconSize = iconSize
        self.fontSize = fontSize
        self.showName = showName
    }

    public var body: some View {
        let brandColor = Color(nsColor: NSColor.fromHex(kind.dotHex) ?? .secondaryLabelColor)
        HStack(spacing: 4) {
            Image(nsImage: AgentIconRenderer.templateOrMonogramImage(for: kind, size: iconSize))
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(brandColor)

            if showName {
                Text(kind.displayName)
                    .font(.system(size: fontSize, weight: .medium))
                    .foregroundStyle(brandColor)
            }
        }
    }
}
