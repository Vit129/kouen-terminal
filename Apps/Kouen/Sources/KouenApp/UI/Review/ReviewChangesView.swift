import KouenCore
import KouenGit
import KouenIPC
import SwiftUI

struct ReviewChangesView: View {
    let cwd: String
    @Bindable var draft: ReviewDraft

    @State private var changes: ReviewDiff?
    @State private var selectedFileID: String?
    @State private var selectedLine: ReviewDiff.Line?
    @State private var selectedRangeEnd: ReviewDiff.Line?
    @State private var liveTargets: [Target] = []
    @State private var comment = ""
    @State private var reattaching: UUID?
    @State private var status = ""
    @State private var isLoading = false
    @State private var isSending = false

    struct Target: Identifiable, Equatable {
        let id: UUID
        let title: String
        let cwd: String
        let agentPID: Int32
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Review Changes").font(.headline)
                Spacer()
                Button { Task { await refresh() } } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh diff")
                .disabled(isLoading || isSending)
            }
            .buttonStyle(.borderless)
            .padding(8)
            Divider()

            if let changes {
                if changes.files.isEmpty {
                    Text("No working tree changes").foregroundStyle(.secondary).padding()
                } else {
                    Picker("Changed file", selection: $selectedFileID) {
                        ForEach(changes.files) { file in
                            Text("\(file.path) · \(file.kind.rawValue)").tag(Optional(file.id))
                        }
                    }
                    .padding(8)
                    .disabled(isSending)
                    .onChange(of: selectedFileID) { _, _ in
                        selectedLine = nil
                        selectedRangeEnd = nil
                    }
                    if let file = changes.files.first(where: { $0.id == selectedFileID }) {
                        diffView(file).disabled(isSending)
                        if selectedLine != nil {
                            HStack {
                                TextField("Review comment", text: $comment)
                                Button(reattaching == nil ? "Add" : "Reattach") { saveComment(in: file) }
                                    .disabled(reattaching == nil && comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            .padding(8)
                            .disabled(isSending)
                        }
                    }
                }
                if !draft.notes.isEmpty { commentsView(changes) }
                PRFeedbackView(root: changes.root, model: draft.prFeedback, targets: liveTargets)
            }
            if !status.isEmpty {
                Text(status).font(.caption).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .task { await refresh() }
        .onReceive(NotificationCenter.default.publisher(for: NotificationBus.shared.snapshotChanged)) { _ in
            if let changes {
                let updated = targets(in: changes.root)
                if liveTargets != updated { liveTargets = updated }
            }
        }
    }

    private func diffView(_ file: ReviewDiff.File) -> some View {
        let lines = file.lines
        return ScrollView {
            if lines.isEmpty {
                Text(file.patch.isEmpty ? "No textual diff" : file.patch)
                    .font(.system(.caption, design: .monospaced))
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
                    .padding(8)
            } else {
                LazyVStack(alignment: .leading, spacing: 1) {
                    ForEach(lines) { line in
                        Button {
                            if NSEvent.modifierFlags.contains(.shift), selectedLine?.hunk == line.hunk {
                                selectedRangeEnd = line
                            } else {
                                selectedLine = line
                                selectedRangeEnd = nil
                            }
                        } label: {
                            HStack(alignment: .firstTextBaseline) {
                                Text("\(line.line)").foregroundStyle(.secondary)
                                    .frame(width: 40, alignment: .trailing)
                                Text(line.text)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundStyle(line.text.hasPrefix("+") ? Color.green
                                        : line.text.hasPrefix("-") ? Color.red : Color.primary)
                            }
                            .font(.system(.caption, design: .monospaced))
                            .padding(.trailing, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(isSelected(line) ? Color.accentColor.opacity(0.2) : .clear)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .help("Click to comment. Shift-click to select a range.")
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func commentsView(_ changes: ReviewDiff) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach($draft.notes) { $note in
                        let match = note.match(in: changes.files)
                        HStack(alignment: .firstTextBaseline) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(note.path):\(match?.line ?? note.line)").font(.caption.monospaced())
                                Text(note.body).textSelection(.enabled)
                            }
                            Spacer()
                            if match == nil && !note.resolved {
                                Button("Reattach") {
                                    reattaching = note.id
                                    selectedLine = nil
                                    status = "Select a diff line, then click Reattach."
                                }
                            }
                            Button(note.resolved ? "Reopen" : "Resolve") { note.resolved.toggle() }
                        }
                    }
                }
                .padding(8)
            }
            .frame(maxHeight: 160)
            .disabled(isSending)

            ReviewAgentPicker(title: "Send to Agent", targets: liveTargets) { target in
                await send(to: target, changes: changes)
            }
            .disabled(isSending || isLoading || liveTargets.isEmpty || draft.notes.allSatisfy(\.resolved))
            .help(liveTargets.isEmpty ? "No idle agent found in this worktree" : changes.root)
            .padding(.horizontal, 8)
        }
    }

    private func saveComment(in file: ReviewDiff.File) {
        let selected = file.lines.filter(isSelected)
        guard let first = selected.first else { return }
        let text = selected.map(\.text).joined(separator: "\n")
        if let reattaching, let index = draft.notes.firstIndex(where: { $0.id == reattaching }) {
            draft.notes[index].path = file.path
            draft.notes[index].kind = file.kind
            draft.notes[index].line = first.line
            draft.notes[index].text = text
            self.reattaching = nil
            status = ""
        } else {
            draft.notes.append(ReviewNote(path: file.path, kind: file.kind, line: first.line,
                text: text, body: comment.trimmingCharacters(in: .whitespacesAndNewlines)))
        }
        self.selectedLine = nil
        selectedRangeEnd = nil
        comment = ""
    }

    private func isSelected(_ line: ReviewDiff.Line) -> Bool {
        guard let selectedLine else { return false }
        let end = selectedRangeEnd?.id ?? selectedLine.id
        return (min(selectedLine.id, end)...max(selectedLine.id, end)).contains(line.id)
    }

    private func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        status = "Loading changes…"
        defer { isLoading = false }
        do {
            let updated = try await ReviewDiff.load(cwd: cwd)
            guard !Task.isCancelled else { return }
            changes = updated
            if !updated.files.contains(where: { $0.id == selectedFileID }) {
                selectedFileID = updated.files.first?.id
            }
            selectedLine = nil
            selectedRangeEnd = nil
            liveTargets = targets(in: updated.root)
            status = updated.root
        } catch {
            changes = nil
            status = error.localizedDescription
        }
    }

    private func targets(in root: String) -> [Target] {
        let workspace = SessionCoordinator.shared.snapshot.activeWorkspace
        return (workspace?.sessions ?? []).flatMap(\.tabs).flatMap { tab in
            tab.rootPane.allLeaves().flatMap(\.surfaces).compactMap { surface in
                guard let agent = tab.paneAgents?[surface.id.uuidString],
                      agent.activity == .idle,
                      let cwd = surface.cwd,
                      cwd == root || cwd.hasPrefix(root + "/") else { return nil }
                return Target(id: surface.id, title: "\(tab.title) · \(surface.label ?? surface.title) · \(agent.kind.displayName)", cwd: cwd, agentPID: agent.pid)
            }
        }
    }

    private func send(to target: Target, changes: ReviewDiff) async {
        guard !isSending else { return }
        isSending = true
        defer { isSending = false }
        let unresolved = draft.notes.filter { !$0.resolved }
        let selection = changes.files.filter { file in
            unresolved.contains { $0.path == file.path && $0.kind == file.kind }
        }
        async let verifiedRoot = try? ReviewDiff.worktreeRoot(cwd: target.cwd)
        let freshDiff = try? await ReviewDiff.load(cwd: changes.root, restrictingTo: selection)
        let targetRoot = await verifiedRoot
        guard let freshDiff, freshDiff.root == changes.root else {
            status = "Could not refresh changes. The review draft is still available."
            return
        }
        let live = targets(in: changes.root).first { $0.id == target.id && $0.cwd == target.cwd }
        let allowed: Set<UUID> = targetRoot == changes.root && live != nil ? [target.id] : []
        let result = await draft.send(to: target.id, allowed: allowed, files: freshDiff.files) { id, text in
            let clean = String(text.unicodeScalars.filter {
                $0 == "\n" || $0 == "\t" || !CharacterSet.controlCharacters.contains($0)
            })
            let response = await SessionCoordinator.shared.requestDaemon(.sendData(
                surfaceID: id.uuidString,
                data: AgentHandoffBuilder.bracketedPasteData(for: clean),
                origin: .human
            ))
            if case .ok? = response { return true }
            return false
        }
        switch result {
        case .sent:
            status = "Sent to \(target.title)"
        case .needsReattachment(let notes):
            // Keep Reattach controls in sync with the fresh patches used to validate sending.
            let refreshedIDs = Set(selection.map(\.id))
            let freshByID = Dictionary(uniqueKeysWithValues: freshDiff.files.map { ($0.id, $0) })
            let updatedFiles = changes.files.compactMap { file in
                refreshedIDs.contains(file.id) ? freshByID[file.id] : file
            }
            self.changes = ReviewDiff(root: changes.root, files: updatedFiles)
            if self.changes?.files.contains(where: { $0.id == selectedFileID }) != true {
                selectedFileID = self.changes?.files.first?.id
            }
            selectedLine = nil
            selectedRangeEnd = nil
            let locations = notes.map { "\($0.path):\($0.line)" }.joined(separator: ", ")
            status = "Reattach before sending: \(locations)"
        case .unavailable:
            status = "Could not send. Check that the agent is still idle in this worktree."
        case .deliveryFailed:
            status = "Could not send. The review draft is still available."
        }
    }
}
