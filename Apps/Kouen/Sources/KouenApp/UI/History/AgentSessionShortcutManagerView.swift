import AppKit
import KouenIPC
import SwiftUI
import UniformTypeIdentifiers

private enum AgentShortcutDragPayload {
    static let type = UTType.plainText
}

struct AgentSessionShortcutManagerView: View {
    @ObservedObject var model: AgentSessionHistoryModel
    let onDone: () -> Void
    @State private var draggedShortcut: AgentKind?
    @State private var dragToken: UUID?
    @State private var targetedShortcut: AgentKind?

    private var orderedKinds: [AgentKind] {
        AgentKind.allCases.sorted { $0.displayName < $1.displayName }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Manage shortcuts")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Choose up to five visible agents")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Text("\(model.agentShortcutKinds.count) of 5")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("\(model.agentShortcutKinds.count) of 5 shortcuts selected")
            }

            Divider()

            VStack(alignment: .leading, spacing: 5) {
                Text("Shortcut order")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                if model.agentShortcutKinds.isEmpty {
                    Text("No shortcuts selected")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(model.agentShortcutKinds.enumerated()), id: \.element) { index, kind in
                        HStack(spacing: 7) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(.secondary)
                                .frame(width: 12, height: 18)
                                .contentShape(Rectangle())
                                .accessibilityLabel("Reorder \(kind.displayName) shortcut")
                                .accessibilityHint("Drag to change shortcut order")
                                .help("Drag to reorder")
                            Text("\(index + 1)")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .frame(width: 16, alignment: .trailing)
                            Image(nsImage: AgentIconRenderer.templateOrMonogramImage(for: kind, size: 12))
                                .resizable()
                                .frame(width: 12, height: 12)
                            Text(kind.displayName)
                                .font(.system(size: 11))
                            Spacer()
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(targetedShortcut == kind ? Color.accentColor.opacity(0.16) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .contentShape(Rectangle())
                        .onDrag { beginShortcutDrag(kind) } preview: {
                            HStack(spacing: 7) {
                                Image(systemName: "line.3.horizontal")
                                    .foregroundStyle(.secondary)
                                Image(nsImage: AgentIconRenderer.templateOrMonogramImage(for: kind, size: 12))
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                Text(kind.displayName)
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .padding(8)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .onDrop(
                            of: [AgentShortcutDragPayload.type],
                            delegate: AgentShortcutReorderDropDelegate(
                                destination: kind,
                                model: model,
                                draggedShortcut: $draggedShortcut,
                                dragToken: $dragToken,
                                targetedShortcut: $targetedShortcut
                            )
                        )
                    }
                }
            }

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(orderedKinds, id: \.self) { kind in
                        let isShortcut = model.agentShortcutKinds.contains(kind)
                        Toggle(isOn: shortcutBinding(for: kind)) {
                            HStack(spacing: 7) {
                                if let shortcutIndex = model.agentShortcutKinds.firstIndex(of: kind) {
                                    Text("\(shortcutIndex + 1)")
                                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 14, alignment: .trailing)
                                }
                                Image(nsImage: AgentIconRenderer.templateOrMonogramImage(for: kind, size: 12))
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                Text(kind.displayName)
                                    .font(.system(size: 11))
                            }
                        }
                        .toggleStyle(.checkbox)
                        .disabled(!isShortcut && model.agentShortcutKinds.count >= 5)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()

            HStack {
                Text("Changes are saved automatically")
                    .font(.system(size: 9.5))
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Done", action: onDone)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(12)
        .frame(width: 280, height: 340)
        .onDisappear {
            draggedShortcut = nil
            dragToken = nil
            targetedShortcut = nil
        }
    }

    private func shortcutBinding(for kind: AgentKind) -> Binding<Bool> {
        Binding(
            get: { model.agentShortcutKinds.contains(kind) },
            set: { isSelected in
                guard isSelected != model.agentShortcutKinds.contains(kind) else { return }
                model.toggleAgentShortcut(kind)
            }
        )
    }

    private func beginShortcutDrag(_ kind: AgentKind) -> NSItemProvider {
        let token = UUID()
        draggedShortcut = kind
        dragToken = token

        return NSItemProvider(object: token.uuidString as NSString)
    }
}

private struct AgentShortcutReorderDropDelegate: DropDelegate {
    let destination: AgentKind
    let model: AgentSessionHistoryModel
    @Binding var draggedShortcut: AgentKind?
    @Binding var dragToken: UUID?
    @Binding var targetedShortcut: AgentKind?

    func validateDrop(info: DropInfo) -> Bool {
        draggedShortcut != nil
            && dragToken != nil
            && !info.itemProviders(for: [AgentShortcutDragPayload.type]).isEmpty
    }

    func dropEntered(info: DropInfo) {
        guard draggedShortcut != destination else { return }
        targetedShortcut = destination
    }

    func dropExited(info: DropInfo) {
        if targetedShortcut == destination {
            targetedShortcut = nil
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        guard
            let source = draggedShortcut,
            let token = dragToken,
            source != destination,
            let provider = info.itemProviders(for: [AgentShortcutDragPayload.type]).first
        else {
            clearDragState()
            return false
        }

        provider.loadDataRepresentation(forTypeIdentifier: AgentShortcutDragPayload.type.identifier) { data, _ in
            let matchesDrag = data.flatMap { UUID(uuidString: String(decoding: $0, as: UTF8.self)) } == token
            DispatchQueue.main.async {
                defer {
                    if dragToken == token {
                        clearDragState()
                    }
                }
                guard matchesDrag, draggedShortcut == source else { return }

                model.moveAgentShortcut(source, to: destination)
            }
        }
        return true
    }

    private func clearDragState() {
        draggedShortcut = nil
        dragToken = nil
        targetedShortcut = nil
    }
}
