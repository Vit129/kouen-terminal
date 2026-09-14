import AppKit
import SwiftUI
import KouenCore

/// Agent Swarm Core fleet dashboard — one table row per headless worker (Lane A/structured or
/// Lane B/pty), instead of one Tab/Pane per worker. This is the payoff of the whole feature: a
/// human can see 20-50 workers' status without 20-50 terminal grid cells eating Metal buffers.
/// Mirrors `TaskDashboardView`'s NSView-host + SwiftUI-body construction and floating-panel
/// presentation (`KouenSidebarPanelViewController.showTaskDashboard`'s pattern).
///
/// Sketch-tier for now (see `agent-memory/plans/agent-swarm-core/design.md`, Slice 5): polls
/// `.swarmList` on a timer rather than a push subscription — there's no `SwarmDAGStore`→GUI
/// push channel yet (only the layout snapshot has one, via `snapshotChanged`). Good enough for
/// an initial fleet-at-a-glance view; a real push channel is a natural follow-up once this is
/// actually used, not built speculatively now.
@MainActor
final class SwarmFleetView: NSView {
    let preferredHeight: CGFloat = 420

    init() {
        super.init(frame: .zero)

        wantsLayer = true
        layer?.cornerRadius = KouenDesign.Radius.overlay
        layer?.cornerCurve = .continuous
        layer?.masksToBounds = false
        let c = KouenDesign.chrome
        layer?.backgroundColor = (c.terminalBackground.blended(withFraction: c.isDark ? 0.06 : 0.04, of: c.textPrimary) ?? c.sidebarBackground).cgColor
        layer?.borderWidth = 1
        layer?.borderColor = c.textPrimary.withAlphaComponent(c.isDark ? 0.11 : 0.14).cgColor
        KouenDesign.applyShadow(.overlay, to: layer)

        let host = NSHostingView(rootView: SwarmFleetBody())
        host.translatesAutoresizingMaskIntoConstraints = false
        addSubview(host)
        NSLayoutConstraint.activate([
            host.topAnchor.constraint(equalTo: topAnchor),
            host.leadingAnchor.constraint(equalTo: leadingAnchor),
            host.trailingAnchor.constraint(equalTo: trailingAnchor),
            host.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

struct SwarmFleetBody: View {
    /// Polling cadence while the panel is open. Not configurable — this is a sketch-tier
    /// dashboard, not a setting worth exposing yet.
    private static let pollInterval: Duration = .seconds(2)

    @State private var nodes: [SwarmTaskNodeWire] = []
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Text("Agent Fleet")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(KouenDesign.chrome.textTertiary))
                if !nodes.isEmpty {
                    Text("· \(nodes.count) worker\(nodes.count == 1 ? "" : "s")")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(KouenDesign.chrome.textTertiary))
                }
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 28)

            if isLoading {
                Spacer()
                ProgressView().controlSize(.small)
                Spacer()
            } else if nodes.isEmpty {
                Text("No fleet workers running.\nSpawn one with kouenSpawnWorker(headless: true).")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(KouenDesign.chrome.textSecondary))
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(nodes) { node in
                            SwarmNodeRowView(node: node, onTerminate: { await terminate(node) })
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: KouenDesign.Radius.overlay, style: .continuous))
        .task { await pollLoop() }
    }

    /// Runs for as long as the view stays on screen — `.task` cancels this automatically when
    /// the view is torn down (dismissing the panel), same structural-lifetime guarantee
    /// `TaskDashboardView`'s doc comment calls out for its own one-shot `.task { await refresh() }`.
    private func pollLoop() async {
        while !Task.isCancelled {
            await refresh()
            try? await Task.sleep(for: Self.pollInterval)
        }
    }

    private func refresh() async {
        let snapshot = await SwarmDaemonBridge.list()
        nodes = snapshot.nodes.sorted { $0.startedAt > $1.startedAt }
        isLoading = false
    }

    private func terminate(_ node: SwarmTaskNodeWire) async {
        _ = await SwarmDaemonBridge.terminate(taskID: node.id)
        await refresh()
    }
}

private struct SwarmNodeRowView: View {
    let node: SwarmTaskNodeWire
    let onTerminate: () async -> Void
    @State private var isHovered = false

    private var statusColor: Color {
        switch node.status {
        case "working": return .blue
        case "waitingInput": return .orange
        case "succeeded": return .green
        case "failed": return .red
        case "cancelled": return Color(KouenDesign.chrome.textTertiary)
        default: return Color(KouenDesign.chrome.textTertiary) // queued, spawning
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 7, height: 7)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(node.agentKind.displayName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(KouenDesign.chrome.textPrimary))
                    Text(node.lane == "pty" ? "pty" : "headless")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color(KouenDesign.chrome.textTertiary))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color(KouenDesign.chrome.textTertiary).opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                }
                Text(node.summary ?? node.role ?? node.status)
                    .font(.system(size: 11))
                    .foregroundStyle(Color(KouenDesign.chrome.textSecondary))
                    .lineLimit(1)
            }

            Spacer()

            if isHovered {
                Button(action: { Task { await onTerminate() } }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(KouenDesign.chrome.textTertiary))
                }
                .buttonStyle(.plain)
                .help("Terminate")
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isHovered ? Color(KouenDesign.chrome.textPrimary).opacity(0.06) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
    }
}
