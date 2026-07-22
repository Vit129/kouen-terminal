import AppKit
import SwiftUI
import KouenCore

/// Popover-style panel listing **every running agent** (not just the ones that
/// have pinged you), waiting agents first. Clicking a row jumps to that agent's
/// pane. A minimal read-only "Agent Inbox" built on the same row/panel idiom as
/// `NotificationDropdownPanelView`, fed by `SessionCoordinator.agentsList()`.
///
/// Distinct from the notification bell + dropdown, which only surfaces tabs in
/// `.waiting` state and clears the alert on open; this inbox is a passive roster
/// and never clears notifications.
@MainActor
final class AgentInboxPanelView: NSView {
    private let agents: [AgentSessionSummary]
    private let onSelect: (AgentSessionSummary) -> Void
    let preferredHeight: CGFloat

    init(
        agents: [AgentSessionSummary],
        onSelect: @escaping (AgentSessionSummary) -> Void
    ) {
        self.agents = agents
        self.onSelect = onSelect
        let visibleRowCount = min(agents.count, 6)
        let bodyHeight = agents.isEmpty ? 64 : CGFloat(visibleRowCount * 52 + 6)
        self.preferredHeight = 28 + bodyHeight + 12
        super.init(frame: .zero)

        // Panel chrome — stay on NSView layer so it matches the AppKit overlay pattern
        wantsLayer = true
        layer?.cornerRadius = KouenDesign.Radius.overlay
        layer?.cornerCurve = .continuous
        layer?.masksToBounds = false
        let c = KouenDesign.chrome
        layer?.backgroundColor = (c.terminalBackground.blended(withFraction: c.isDark ? 0.06 : 0.04, of: c.textPrimary) ?? c.sidebarBackground).cgColor
        layer?.borderWidth = 1
        layer?.borderColor = c.textPrimary.withAlphaComponent(c.isDark ? 0.11 : 0.14).cgColor
        KouenDesign.applyShadow(.overlay, to: layer)

        let host = NSHostingView(rootView: AgentInboxBody(agents: agents, onSelect: onSelect))
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

// MARK: - SwiftUI Content

private struct AgentInboxBody: View {
    let agents: [AgentSessionSummary]
    let onSelect: (AgentSessionSummary) -> Void

    /// P39 G5: fleet-at-a-glance counts in the header — a human watching several agents run
    /// gets this without opening an MCP client; `agents` is already the roster this popover
    /// renders, no new data plumbing.
    private var needsAttentionCount: Int { agents.filter(\.waiting).count }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 6) {
                Text("Agents")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(KouenDesign.chrome.textTertiary))
                if !agents.isEmpty {
                    Text("· \(agents.count) running")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(KouenDesign.chrome.textTertiary))
                }
                if needsAttentionCount > 0 {
                    Text("· \(needsAttentionCount) need you")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.red)
                }
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 28)

            // Body
            if agents.isEmpty {
                Text("No agents running.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(KouenDesign.chrome.textSecondary))
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
            } else {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(agents) { agent in
                            AgentInboxRowView(agent: agent) {
                                onSelect(agent)
                            }
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                }
            }

            Spacer(minLength: 8)
        }
        // Clip to panel corner so SwiftUI background doesn't bleed past the layer corner
        .clipShape(RoundedRectangle(cornerRadius: KouenDesign.Radius.overlay, style: .continuous))
    }
}

private struct AgentInboxRowView: View {
    let agent: AgentSessionSummary
    let onClick: () -> Void
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            AgentStatusDot(agent: agent)
                .frame(width: 14, height: 14)

            VStack(alignment: .leading, spacing: 1) {
                Text(agent.agentName)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(Color(KouenDesign.chrome.textPrimary))
                    .lineLimit(1)
                Text(agentDetail(agent))
                    .font(.system(size: 11))
                    .foregroundStyle(Color(KouenDesign.chrome.textTertiary))
                    .lineLimit(1)
            }

            Spacer()

            Text(AgentListFormatter.age(from: agent.lastActivityAt))
                .font(.system(size: 9.5, weight: .medium).monospacedDigit())
                .foregroundStyle(Color(KouenDesign.chrome.textTertiary))
        }
        .padding(.horizontal, 10)
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isHovered ? Color(KouenDesign.chrome.textPrimary).opacity(0.06) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .onTapGesture { onClick() }
    }
}

// Wraps AppKit StatusDotView to preserve the brand-tinted breathing-halo animation.
private struct AgentStatusDot: NSViewRepresentable {
    let agent: AgentSessionSummary

    func makeNSView(context: Context) -> StatusDotView {
        StatusDotView(diameter: 14)
    }

    func updateNSView(_ dot: StatusDotView, context: Context) {
        if agent.waiting {
            dot.style = .waiting
        } else {
            let hex = SessionCoordinator.shared.settings.agentColorHex(for: agent.kind)
            dot.style = .agent(hex: hex)
        }
    }
}

/// Mirrors `AgentNotchProjection.agentDetail`: `project (branch) · tab-title · workspace`.
private func agentDetail(_ agent: AgentSessionSummary) -> String {
    var parts: [String] = []
    let path = (agent.cwd as NSString).lastPathComponent
    if !path.isEmpty {
        parts.append(agent.gitBranch.map { "\(path) (\($0))" } ?? path)
    }
    if !agent.tabTitle.isEmpty, agent.tabTitle != agent.agentName, agent.tabTitle != path {
        parts.append(agent.tabTitle)
    }
    parts.append(agent.workspaceName)
    if !agent.sessionName.isEmpty, agent.sessionName != path {
        parts.append(agent.sessionName)
    }
    // Fleet-at-a-glance parity with the sidebar's per-session port badge (P39 G1) —
    // this popover previously showed agent status without the port a human would need
    // to actually open the dev server it's running.
    if let ports = agent.listeningPorts, !ports.isEmpty {
        parts.append(":\(ports.sorted().map(String.init).joined(separator: ","))")
    }
    return parts.joined(separator: " · ")
}
