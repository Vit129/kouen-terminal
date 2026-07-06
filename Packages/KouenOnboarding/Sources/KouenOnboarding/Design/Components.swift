import SwiftUI
import AppKit

/// Shared monochrome components for the immersive onboarding wizard.
/// One calm liquid-glass plane, off-white text, sparse controls, and no decorative clutter.

enum Motion {
    @MainActor static var reduce: Bool {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    @MainActor static var spring: Animation {
        reduce
            ? .easeOut(duration: ImmersivePalette.Motion.fast)
            : .spring(response: ImmersivePalette.Motion.springResponse,
                      dampingFraction: ImmersivePalette.Motion.springDamping)
    }
}

struct StepIntro: View {
    let eyebrow: String
    let title: String
    let bodyText: String
    var maxWidth: CGFloat = 560

    var body: some View {
        VStack(spacing: 11) {
            Text(eyebrow)
                .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                .tracking(2.5)
                .textCase(.uppercase)
                .foregroundStyle(ImmersivePalette.SUI.textTertiary)
                .lineLimit(1)

            Text(title)
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.94))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: maxWidth)

            Text(bodyText)
                .font(.system(size: 14.5, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.64))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: maxWidth)
        }
    }
}

struct GlassPrimaryButtonStyle: ButtonStyle {
    var minWidth: CGFloat? = nil

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14.5, weight: .semibold))
            .frame(minWidth: minWidth, minHeight: 22)
            .padding(.horizontal, 30)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.82 : 0.94))
                    .shadow(color: .white.opacity(configuration.isPressed ? 0.04 : 0.15), radius: 24, x: 0, y: 0)
            )
            .foregroundStyle(Color.black.opacity(0.92))
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .animation(.spring(response: 0.18, dampingFraction: 0.75), value: configuration.isPressed)
    }
}

struct GlassSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13.5, weight: .semibold))
            .frame(minHeight: 20)
            .padding(.horizontal, 22)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(.white.opacity(configuration.isPressed ? 0.12 : 0.065))
                    .overlay(Capsule(style: .continuous).strokeBorder(.white.opacity(0.15), lineWidth: 1))
            )
            .foregroundStyle(Color.white.opacity(0.86))
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .animation(.spring(response: 0.18, dampingFraction: 0.75), value: configuration.isPressed)
    }
}

struct GlassSmallButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .frame(minHeight: 18)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(.white.opacity(configuration.isPressed ? 0.12 : 0.055))
                    .overlay(Capsule(style: .continuous).strokeBorder(.white.opacity(0.13), lineWidth: 1))
            )
            .foregroundStyle(Color.white.opacity(0.74))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}


struct GlassStatusButtonStyle: ButtonStyle {
    var tone: StatusPill.Tone = .success

    private var color: Color {
        switch tone {
        case .neutral: Color.white.opacity(0.58)
        case .pending: Color.white.opacity(0.82)
        case .success: ImmersivePalette.SUI.success
        case .danger:  ImmersivePalette.SUI.danger
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13.5, weight: .semibold, design: .monospaced))
            .frame(minHeight: 20)
            .padding(.horizontal, 22)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(color.opacity(configuration.isPressed ? 0.20 : 0.13))
                    .overlay(Capsule(style: .continuous).strokeBorder(color.opacity(0.28), lineWidth: 1))
            )
            .foregroundStyle(color)
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .animation(.spring(response: 0.18, dampingFraction: 0.75), value: configuration.isPressed)
    }
}

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 18
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.white.opacity(0.045))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                    )
            )
    }
}

struct QuietRow: View {
    let title: String
    let detail: String
    var value: String? = nil
    var tone: StatusPill.Tone = .neutral

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.88))
                    .lineLimit(1)
                Text(detail)
                    .font(.system(size: 11.5))
                    .foregroundStyle(Color.white.opacity(0.44))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 12)
            if let value {
                StatusPill(text: value, tone: tone)
            }
        }
    }
}

struct CommandRow: View {
    let command: String
    let note: String
    init(_ command: String, _ note: String) { self.command = command; self.note = note }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(command)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.white.opacity(0.88))
                .lineLimit(1)
                .truncationMode(.middle)
            Text(note)
                .font(.system(size: 11.5))
                .foregroundStyle(Color.white.opacity(0.44))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 2)
    }
}

struct ShortcutRow: View {
    let key: String
    let action: String

    var body: some View {
        HStack(spacing: 12) {
            Text(key)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.white.opacity(0.88))
                .frame(width: 60, alignment: .trailing)
            Text(action)
                .font(.system(size: 11.5))
                .foregroundStyle(Color.white.opacity(0.44))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 1)
    }
}

struct StatusPill: View {
    enum Tone { case neutral, pending, success, danger }
    let text: String
    var tone: Tone = .neutral

    private var color: Color {
        switch tone {
        case .neutral: Color.white.opacity(0.58)
        case .pending: Color.white.opacity(0.82)
        case .success: ImmersivePalette.SUI.success
        case .danger:  ImmersivePalette.SUI.danger
        }
    }

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .foregroundStyle(color)
            .frame(minHeight: 18)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule(style: .continuous).fill(color.opacity(0.13)))
            .overlay(Capsule(style: .continuous).strokeBorder(color.opacity(0.24), lineWidth: 1))
            .lineLimit(1)
    }
}
