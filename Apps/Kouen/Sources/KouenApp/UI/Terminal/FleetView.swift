import SwiftUI
import KouenIPC

/// One screen listing every live session across every workspace — P46 Pillar 6 gap 6. Layout
/// pattern (list + text filter, needs-attention sorted first) mirrors `AutomationsFleetView`;
/// not the file itself, since that one lists scheduled jobs and run history, not live sessions.
public struct FleetView: View {
    var model: FleetViewModel
    var onSelect: ((FleetSessionItem) -> Void)?

    public init(model: FleetViewModel, onSelect: ((FleetSessionItem) -> Void)? = nil) {
        self.model = model
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            if model.items.isEmpty {
                emptyState
            } else if model.filteredItems.isEmpty {
                Text("No sessions match '\(model.filterText)'")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(model.filteredItems) { item in
                    FleetRowView(item: item)
                        .contentShape(Rectangle())
                        .onTapGesture { onSelect?(item) }
                }
                .listStyle(.plain)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            TextField("Filter sessions…", text: Binding(
                get: { model.filterText },
                set: { model.filterText = $0 }
            ))
            .textFieldStyle(.plain)
            .font(.system(size: 12))
            if model.waitingCount > 0 {
                Text("\(model.waitingCount) waiting")
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange, in: Capsule())
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 22))
                .foregroundStyle(.tertiary)
            Text("No live sessions")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct FleetRowView: View {
    let item: FleetSessionItem

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            statusDot
                .padding(.top, 4)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(item.title)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                    if let agentName = item.agentName {
                        Text(agentName)
                            .font(.system(size: 9.5, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Color.secondary.opacity(0.12), in: Capsule())
                    }
                }
                Text(subtitle)
                    .font(.system(size: 10.5))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if let notificationText = item.notificationText, item.isWaiting {
                    Text(notificationText)
                        .font(.system(size: 10.5))
                        .foregroundStyle(Color.orange)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }

    private var subtitle: String {
        var parts = [item.workspaceName]
        if let taskName = item.taskName { parts.append(taskName) }
        if let branch = item.gitBranch { parts.append("⎇ \(branch)") }
        parts.append(item.cwd)
        return parts.joined(separator: " · ")
    }

    private var statusDot: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 7, height: 7)
    }

    private var statusColor: Color {
        switch item.status {
        case .waiting: return .orange
        case .error: return .red
        case .done: return .green
        default: return item.activity == "working" ? .blue : .secondary.opacity(0.4)
        }
    }
}
