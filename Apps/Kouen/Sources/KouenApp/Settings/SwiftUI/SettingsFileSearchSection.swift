import AppKit
import SwiftUI

/// Settings › Advanced › File search: folders a clicked/typed file name is also looked up in
/// when the current project has no match. Scan fills it; each row can be removed or added by hand.
struct SettingsFileSearchSection: View {
    var model: SettingsModel
    @State private var scanning = false

    var body: some View {
        Section {
            ForEach(model.settings.fileSearchRoots, id: \.self) { root in
                HStack {
                    Text(root).font(.system(.body, design: .monospaced)).lineLimit(1).truncationMode(.middle)
                    Spacer()
                    Button(role: .destructive) { set(model.settings.fileSearchRoots.filter { $0 != root }) } label: {
                        Image(systemName: "minus.circle")
                    }
                    .buttonStyle(.borderless)
                    .help("Remove this folder")
                }
            }
            HStack {
                Button(scanning ? "Scanning…" : "Scan ~/Git") { scan() }.disabled(scanning)
                Button("Add Folder…") { addFolder() }
            }
        } header: {
            Text("File search")
        } footer: {
            Text("When a file name you click or open isn't in the current project, Kouen also looks in these folders, then in recent projects. Scan finds agent-memory folders under ~/Git.")
        }
    }

    private func set(_ roots: [String]) { model.update(\.fileSearchRoots, roots) }

    private func scan() {
        scanning = true
        Task.detached {
            let found = FileSearchRootScanner.scan()
            await MainActor.run {
                set(Array(NSOrderedSet(array: model.settings.fileSearchRoots + found)) as? [String] ?? found)
                scanning = false
            }
        }
    }

    private func addFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        guard panel.runModal() == .OK else { return }
        set(Array(NSOrderedSet(array: model.settings.fileSearchRoots + panel.urls.map(\.path))) as? [String] ?? [])
    }
}
