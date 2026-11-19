import KouenIPC
import SwiftUI

struct ReviewAgentPicker: View {
    let title: String
    let targets: [ReviewChangesView.Target]
    let select: (ReviewChangesView.Target) async -> Void

    var body: some View {
        Menu(title) {
            ForEach(targets) { target in
                Button { Task { await select(target) } } label: { Text(verbatim: target.title) }
            }
        }
        .disabled(targets.isEmpty)
    }
}

struct PRFeedbackView: View {
    let root: String
    let model: PRFeedbackModel
    let targets: [ReviewChangesView.Target]
    @State private var expanded = false

    var body: some View {
        DisclosureGroup("PR feedback", isExpanded: $expanded) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Button("Refresh PR feedback") { Task { await model.refresh(root: root) } }
                        .accessibilityIdentifier("review.prFeedback.refresh")
                        .disabled(model.busy)
                    if model.busy { ProgressView().controlSize(.small) }
                }
                if let snapshot = model.snapshot {
                    Text(verbatim: "PR #\(snapshot.head.number) · \(snapshot.head.headRefOid.prefix(8)) · \(root)")
                        .font(.caption).foregroundStyle(.secondary)
                    if snapshot.checks.isEmpty && snapshot.threads.isEmpty && snapshot.complete {
                        Text("No failed checks or unresolved threads.").foregroundStyle(.secondary)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(snapshot.checks) { check in
                                    selection(check.id, title: "\(check.name) · \(check.conclusion)")
                                }
                                ForEach(snapshot.threads) { thread in
                                    let author = thread.comments.nodes.first?.author?.login ?? "Unknown author"
                                    selection(thread.id, title: "\(thread.path) · \(author)\(thread.isOutdated ? " · Outdated" : "")")
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 105)
                        ReviewAgentPicker(title: "Choose agent and preview", targets: targets) { target in
                            await model.preview(surfaceID: target.id, agentPID: target.agentPID, request: request)
                        }
                        .accessibilityIdentifier("review.prFeedback.target")
                        .disabled(model.busy || model.deliveryUnknown || model.selected.isEmpty)
                    }
                }
                if let draft = model.draft {
                    let target = targets.first { $0.id.uuidString == draft.target.surfaceID && $0.agentPID == draft.target.agentPID }
                    Text(verbatim: target?.title ?? "Selected pane is no longer idle")
                        .font(.caption.weight(.semibold))
                    ScrollView {
                        Text(verbatim: draft.text)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 135)
                    .accessibilityIdentifier("review.prFeedback.preview")
                    HStack {
                        Button(model.deliveryUnknown ? "Check delivery" : "Send (paste only)") {
                            Task { await model.send(root: root, request: request) }
                        }
                        .accessibilityIdentifier("review.prFeedback.send")
                        .disabled(model.busy || !model.canSend || (target == nil && !model.deliveryUnknown))
                        Button("Discard draft") { model.discard() }
                            .disabled(model.busy)
                    }
                }
                if !model.message.isEmpty {
                    Text(verbatim: model.message).font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(.top, 6)
        }
        .padding(8)
    }

    private func selection(_ id: String, title: String) -> some View {
        Toggle(isOn: Binding(get: { model.selected.contains(id) }, set: { model.select(id, enabled: $0) })) {
            Text(verbatim: title).lineLimit(2)
        }
        .disabled(model.busy || model.deliveryUnknown)
    }

    private func request(_ message: IPCRequest) async -> IPCResponse? {
        await SessionCoordinator.shared.requestDaemon(message)
    }
}
