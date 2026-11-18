import KouenCore
import SwiftUI

struct ProjectMoveReviewView: View {
    let categoryID: String
    @Bindable var store: ProjectStore
    let onCancel: () -> Void
    let onApplied: () -> Void
    @State private var candidates: [WorkspaceReconciliation.Candidate] = []
    @State private var selected: Set<String> = []
    @State private var preview: ProjectMovePreview?
    @State private var sourceFolder: String?
    @State private var message = "Scanning…"

    private var eligiblePaths: Set<String> {
        Set(candidates.filter { $0.confidence != "ambiguous" }.map(\.oldPath))
    }

    private var unresolvedPaths: [String] {
        store.projects
            .filter { $0.categoryID == categoryID && !FileManager.default.fileExists(atPath: $0.path) }
            .map(\.path)
            .filter { path in !candidates.contains(where: { $0.oldPath == path }) }
    }

    private var listHeight: CGFloat {
        min(max(CGFloat(candidates.count) * 62 + CGFloat(unresolvedPaths.count) * 48, 44), 200)
    }

    var body: some View {
        ProjectWorkspaceSheetFrame(
            title: "Review moved repositories",
            subtitle: "Matches use folder names only. Verify each new path before applying.",
            onBack: onCancel,
            onClose: onCancel
        ) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    if let root = sourceFolder ?? store.categories.first(where: { $0.id == categoryID })?.sourceFolder {
                        Text(root).lineLimit(1).truncationMode(.middle).help(root)
                            .font(.system(size: 11))
                    } else {
                        Text("Choose a source folder to find moved repositories.")
                            .font(.system(size: 11)).foregroundStyle(.secondary)
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

                VStack(spacing: 0) {
                    HStack {
                        Toggle(isOn: Binding(
                            get: { !eligiblePaths.isEmpty && eligiblePaths.isSubset(of: selected) },
                            set: { selected = $0 ? eligiblePaths : [] }
                        )) {
                            Text(eligiblePaths.isSubset(of: selected) && !eligiblePaths.isEmpty ? "Deselect all" : "Select all")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .toggleStyle(.checkbox)
                        Spacer()
                        Text("\(selected.count) of \(eligiblePaths.count) selected")
                            .font(.system(size: 11)).foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.primary.opacity(0.03))
                    Divider()

                    ScrollView(.vertical) {
                        LazyVStack(spacing: 0) {
                            ForEach(candidates.indices, id: \.self) { index in
                                let item = candidates[index]
                                Toggle(isOn: Binding(
                                    get: { selected.contains(item.oldPath) },
                                    set: { if $0 { selected.insert(item.oldPath) } else { selected.remove(item.oldPath) } }
                                )) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(item.oldPath).lineLimit(2).textSelection(.enabled)
                                        Text("→ " + item.newPath).lineLimit(2).textSelection(.enabled)
                                        if item.confidence == "ambiguous" {
                                            Text("Ambiguous match")
                                                .font(.system(size: 10)).foregroundStyle(.secondary)
                                        }
                                    }
                                    .font(.system(size: 11, weight: .medium))
                                }
                                .toggleStyle(.checkbox)
                                .disabled(item.confidence == "ambiguous")
                                .accessibilityIdentifier("project-move-candidate-\(index)")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                Divider().padding(.leading, 36)
                            }
                            if !unresolvedPaths.isEmpty {
                                Text("No matching repository found in this folder")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                ForEach(unresolvedPaths, id: \.self) { path in
                                    HStack(spacing: 8) {
                                        Text(path).lineLimit(2).textSelection(.enabled)
                                            .font(.system(size: 11))
                                        Spacer(minLength: 6)
                                        Button("Remove") {
                                            store.removeProject(path)
                                            onApplied()
                                            onCancel()
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)
                                        .accessibilityIdentifier("project-move-remove-\(path)")
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    Divider().padding(.leading, 12)
                                }
                            }
                        }
                    }
                    .frame(height: listHeight)
                }
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.primary.opacity(0.02)))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.primary.opacity(0.08), lineWidth: 1))

                HStack(spacing: 10) {
                    Spacer()
                    Button("Cancel", action: onCancel)
                        .keyboardShortcut(.cancelAction)
                        .buttonStyle(.bordered)
                    Button("Apply selected") {
                        guard let preview else { return }
                        let reviewed = ProjectMovePreview(projects: preview.projects, categories: preview.categories,
                                                          moves: preview.moves.filter { selected.contains($0.oldPath) })
                        guard !reviewed.moves.isEmpty, store.applyMoves(reviewed) else {
                            message = "Projects or paths changed. Close and review again."
                            return
                        }
                        onApplied()
                        onCancel()
                    }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .disabled(selected.isEmpty || preview == nil)
                    .accessibilityIdentifier("project-moves-apply")
                }

                Text(message).font(.system(size: 11)).foregroundStyle(.secondary)
            }
        }
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
            candidates = WorkspaceReconciliation.candidates(missing: missing, discovered: discovered.filter { !tracked.contains($0) })
            selected = Set(candidates.filter { $0.confidence != "ambiguous" }.map(\.oldPath))
            let mapping = Dictionary(uniqueKeysWithValues: candidates.filter { $0.confidence == "weak" }.map { ($0.oldPath, $0.newPath) })
            preview = store.previewMoves(mapping)
            message = candidates.isEmpty ? "No candidate moves found." : "Select the paths to update."
            if !mapping.isEmpty && preview == nil { message = "Paths changed. Close and review again." }
        }
    }
}
