import SwiftUI

/// Shared modal chrome for repository import and path review flows.
struct ProjectWorkspaceSheetFrame<Content: View>: View {
    let title: String
    let subtitle: String
    let onBack: () -> Void
    let onClose: () -> Void
    @ViewBuilder let content: Content

    init(
        title: String,
        subtitle: String,
        onBack: @escaping () -> Void,
        onClose: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.onBack = onBack
        self.onClose = onClose
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Back").font(.system(size: 12))
                    }
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("btn_projectSheetBack")

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("btn_projectSheetClose")
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            content
        }
        .padding(20)
        .frame(width: 480)
    }
}
