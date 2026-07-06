import SwiftUI
import KouenSettings
import KouenTerminalKit

struct SettingsColorsView: View {
    var model: SettingsModel

    var body: some View {
        Form {
            terminalColorsSection
            renderingSection
            paletteSection
            chromeSection
        }
        .formStyle(.grouped)
        .navigationTitle("Colors")
    }

    // MARK: - Terminal colors

    private var terminalColorsSection: some View {
        Section("Terminal colors") {
            ColorHexRow("Background",  \.customBackgroundHex,  fallback: "#000000", model: model)
            ColorHexRow("Foreground",  \.customForegroundHex,  fallback: "#ffffff", model: model)
            ColorHexRow("Cursor",      \.customCursorHex,      fallback: "#ffffff", model: model)
            ColorHexRow("Cursor text", \.cursorTextHex,        fallback: "#000000", model: model)
            ColorHexRow("Selection",   \.selectionBackgroundHex, fallback: "#3478f6", model: model)
            ColorHexRow("Sel. text",   \.selectionForegroundHex, fallback: "#ffffff", model: model)
            ColorHexRow("Bold",        \.boldColorHex,         fallback: "#ffffff", model: model)
        }
    }

    // MARK: - Rendering

    private var renderingSection: some View {
        Section("Color rendering") {
            Toggle("Wide gamut (Display P3)", isOn: Binding(
                get: { model.settings.vividColors },
                set: { model.update(\.vividColors, $0) }
            ))

            Picker("Text rendering", selection: Binding(
                get: { model.settings.textRendering },
                set: { model.update(\.textRendering, $0) }
            )) {
                Text("Native").tag(TerminalTextRenderingMode.native)
                Text("Crisp").tag(TerminalTextRenderingMode.crisp)
                Text("Soft").tag(TerminalTextRenderingMode.soft)
            }
            .pickerStyle(.segmented)
            .help("Glyph weight: Native, Crisp (lighter), or Soft (heavier).")

            LabeledContent("Minimum contrast") {
                HStack(spacing: 8) {
                    Slider(value: Binding(
                        get: { model.settings.minimumContrast },
                        set: { model.update(\.minimumContrast, KouenSettings.clampedContrast($0)) }
                    ), in: 1...21)
                    .frame(width: 180)
                    Text(model.settings.minimumContrast <= 1.01
                         ? "Off"
                         : String(format: "%.1f:1", model.settings.minimumContrast))
                        .monospacedDigit()
                        .frame(width: 48, alignment: .trailing)
                        .foregroundStyle(.secondary)
                }
            }
            .help("Lift dim text to a WCAG contrast ratio (1 = off).")

            Toggle("Bold is bright", isOn: Binding(
                get: { model.settings.boldIsBright },
                set: { model.update(\.boldIsBright, $0) }
            ))
            .help("Bold text in colors 0–7 uses the bright palette (8–15).")

            Toggle("Theme program output", isOn: Binding(
                get: { model.settings.applyThemeToTerminalOutput },
                set: { model.update(\.applyThemeToTerminalOutput, $0) }
            ))
            Toggle("Ligatures", isOn: Binding(
                get: { model.settings.ligatures },
                set: { model.update(\.ligatures, $0) }
            ))
        }
    }

    // MARK: - ANSI palette

    private var paletteSection: some View {
        Section("ANSI palette") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(0..<16, id: \.self) { index in
                    PaletteCell(index: index, model: model)
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Chrome

    private var chromeSection: some View {
        Section("Chrome") {
            ColorHexRow("Divider lines",    \.dividerHex,     fallback: "#333333", model: model)
            ColorHexRow("Status line text", \.statusLineHex,  fallback: "#aaaaaa", model: model)
            ColorHexRow("Window border",    \.windowBorderHex, fallback: "#ffffff", model: model)
        }
    }
}

// MARK: - ColorHexRow

private struct ColorHexRow: View {
    let label: String
    let keyPath: WritableKeyPath<KouenSettings, String?>
    let fallback: String
    var model: SettingsModel

    init(_ label: String, _ keyPath: WritableKeyPath<KouenSettings, String?>, fallback: String, model: SettingsModel) {
        self.label = label
        self.keyPath = keyPath
        self.fallback = fallback
        self.model = model
    }

    private var currentHex: String { model.settings[keyPath: keyPath] ?? fallback }
    private var isCustom: Bool { model.settings[keyPath: keyPath] != nil }

    private var colorBinding: Binding<Color> {
        Binding(
            get: { Color(nsColor: NSColor.fromHex(currentHex) ?? .white) },
            set: { newColor in
                if let hex = newColor.hexString { model.update(keyPath, hex) }
            }
        )
    }

    var body: some View {
        LabeledContent(label) {
            HStack(spacing: 8) {
                ColorPicker("", selection: colorBinding, supportsOpacity: false)
                    .labelsHidden()
                if isCustom {
                    Button("Reset") { model.update(keyPath, nil) }
                        .buttonStyle(.link)
                        .font(.caption)
                }
            }
        }
    }
}

// MARK: - PaletteCell

private struct PaletteCell: View {
    static let ansiNames = [
        "0 Black", "1 Red", "2 Green", "3 Yellow", "4 Blue", "5 Magenta", "6 Cyan", "7 White",
        "8 Bright Black", "9 Bright Red", "10 Bright Green", "11 Bright Yellow",
        "12 Bright Blue", "13 Bright Magenta", "14 Bright Cyan", "15 Bright White",
    ]

    let index: Int
    var model: SettingsModel

    private var currentHex: String {
        model.settings.paletteHex[index] ?? ThemeManager.defaultBaselinePaletteHex[index]
    }

    private var colorBinding: Binding<Color> {
        Binding(
            get: { Color(nsColor: NSColor.fromHex(currentHex) ?? .gray) },
            set: { newColor in
                guard let hex = newColor.hexString else { return }
                var palette = model.settings.paletteHex
                palette[index] = hex
                model.update(\.paletteHex, palette)
            }
        )
    }

    var body: some View {
        VStack(spacing: 4) {
            ColorPicker("", selection: colorBinding, supportsOpacity: false)
                .labelsHidden()
            Text(Self.ansiNames[index])
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

// MARK: - Color ↔ hex

private extension Color {
    var hexString: String? {
        guard let ns = NSColor(self).usingColorSpace(.sRGB) else { return nil }
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ns.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
