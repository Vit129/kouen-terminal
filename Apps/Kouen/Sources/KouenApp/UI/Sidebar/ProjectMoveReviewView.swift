import KouenCore
import SwiftUI

struct ProjectMoveReviewView: View {
    let categoryID: String
    @Bindable var store: ProjectStore
    @Environment(\.dismiss) private var dismiss
    @State private var candidates: [WorkspaceReconciliation.Candidate] = []
    @State private var selected: Set<String> = []
    @State private var preview: ProjectMovePreview?
    @State private var sourceFolder: String?
    @State private var message = "Scanning…"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Review moved repositories").font(.headline)
            Text("Matches use folder names only. Verify every path before applying.")
                .font(.caption).foregroundStyle(.secondary)
            HStack {
                if let root = sourceFolder ?? store.categories.first(where: { $0.id == categoryID })?.sourceFolder {
                    Text(root).lineLimit(1).truncationMode(.middle).help(root)
                }
                Spacer(minLength: 8)
                Button("Choose Source Folder…") {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.prompt = "Scan"
                    if panel.runModal() == .OK { sourceFolder = panel.url?.path }
                }
                .accessibilityIdentifier("btn_chooseSourceFolder_projectMoveReview")
            }
            List(candidates.indices, id: \.self) { index in
                let item = candidates[index]
                Toggle(isOn: Binding(
                    get: { selected.contains(item.oldPath) },
                    set: { if $0 { selected.insert(item.oldPath) } else { selected.remove(item.oldPath) } }
                )) {
                    VStack(alignment: .leading) {
                        Text(item.oldPath).lineLimit(2).textSelection(.enabled)
                        Text("→ " + item.newPath).lineLimit(2).textSelection(.enabled)
                        if item.confidence == "ambiguous" { Text("Ambiguous match").foregroundStyle(.secondary) }
                    }
                }
                .disabled(item.confidence == "ambiguous")
                .accessibilityIdentifier("project-move-candidate-\(index)")
            }.frame(minHeight: 150)
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Apply selected") {
                    guard let preview else { return }
                    let reviewed = ProjectMovePreview(projects: preview.projects, categories: preview.categories,
                                                      moves: preview.moves.filter { selected.contains($0.oldPath) })
                    guard !reviewed.moves.isEmpty, store.applyMoves(reviewed) else {
                        message = "Projects or paths changed. Close and review again."
                        return
                    }
                    dismiss()
                }.disabled(selected.isEmpty || preview == nil)
                    .accessibilityIdentifier("project-moves-apply")
            }
            Text(message).font(.caption).foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(minWidth: 460, minHeight: 300)
        .task(id: sourceFolder) {
            candidates = []
            selected = []
            preview = nil
            message = "Scanning…"
            guard let category = store.categories.first(where: { $0.id == categoryID }),
                  let root = sourceFolder ?? category.sourceFolder else {
                message = "Choose a source folder to find moved repositories."
                return
            }
            let projects = store.projects
            let missing = projects.filter { $0.categoryID == categoryID && !FileManager.default.fileExists(atPath: $0.path) }.map(\.path)
            let discovered = await Task.detached(priority: .utility) { try? WorkspaceRepositoryScanner.scan(root: root) }.value
            guard !Task.isCancelled else { return }
            guard let discovered else { message = "Source folder is unavailable."; return }
            let tracked = Set(projects.map(\.path))
            guard store.projects == projects, store.categories.first(where: { $0.id == categoryID }) == category else {
                message = "Projects changed. Close and review again."
                return
            }
            candidates = WorkspaceReconciliation.candidates(missing: missing, discovered: discovered.filter { !tracked.contains($0) && !category.excludedPaths.contains($0) })
            let mapping = Dictionary(uniqueKeysWithValues: candidates.filter { $0.confidence == "weak" }.map { ($0.oldPath, $0.newPath) })
            preview = store.previewMoves(mapping)
            message = candidates.isEmpty ? "No candidate moves found." : "Select the paths to update."
            if !mapping.isEmpty && preview == nil { message = "Paths changed. Close and review again." }
        }
    }
}
