import SwiftUI
import AppKit
import KouenCore

struct SettingsKeysView: View {
    var model: SettingsModel

    var body: some View {
        Form {
            Section("Prefix") {
                LabeledContent("Prefix key") {
                    KeyRecorderRepresentable(
                        value: model.settings.prefixKey,
                        onChange: { model.update(\.prefixKey, $0) }
                    )
                    .frame(minWidth: 180, idealHeight: 28)
                }
                Text("Click to record a new shortcut. Esc cancels.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Keys")
    }
}

// MARK: - NSViewRepresentable bridge for KeyRecorderView

struct KeyRecorderRepresentable: NSViewRepresentable {
    let value: String
    let onChange: (String) -> Void

    func makeNSView(context: Context) -> KeyRecorderView {
        let view = KeyRecorderView(initial: value)
        view.onChange = onChange
        return view
    }

    func updateNSView(_ nsView: KeyRecorderView, context: Context) {
        if !nsView.isRecording { nsView.setValue(value) }
    }
}
