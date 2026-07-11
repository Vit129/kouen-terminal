import AppKit
import SwiftUI
import KouenCore

/// Floating panel listing Tasks across every session, grouped Active/Closed by
/// cross-referencing each Task's `sessionID` against the live `SessionSnapshot`
/// (P40 F1). Mirrors `AgentInboxPanelView`'s NSView-host + SwiftUI-body construction
/// and `KouenSidebarPanelViewController.showAgentsInbox`'s float-over-content
/// presentation, but owns its own async refresh — unlike the Agent Inbox, there's no
/// existing local cache of Task state to read synchronously.
@MainActor
final class TaskDashboardView: NSView {
    let preferredHeight: CGFloat = 420
    private let onJumpToSession: (SessionID) -> Void

    init(onJumpToSession: @escaping (SessionID) -> Void) {
        self.onJumpToSession = onJumpToSession
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

        let host = NSHostingView(rootView: TaskDashboardBody(onJumpToSession: onJumpToSession))
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

private struct TaskDashboardBody: View {
    let onJumpToSession: (SessionID) -> Void

    @State private var tasks: [TaskSummary] = []
    @State private var newTaskTitle: String = ""
    @State private var isLoading = true

    /// Sessions still present in the live snapshot vs. gone (closed) — read once per
    /// render from `SessionCoordinator`'s already-synced local cache (same source
    /// `agentsList()` uses), not a daemon round trip.
    private var liveSessionIDs: Set<SessionID> {
        Set(SessionCoordinator.shared.snapshot.workspaces.flatMap { $0.sessions.map(\.id) })
    }

    private var activeTasks: [TaskSummary] { tasks.filter { liveSessionIDs.contains($0.sessionID) } }
    private var closedTasks: [TaskSummary] { tasks.filter { !liveSessionIDs.contains($0.sessionID) } }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Text("Tasks")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(KouenDesign.chrome.textTertiary))
                if !tasks.isEmpty {
                    Text("· \(tasks.filter { !$0.done }.count) open")
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
            } else if tasks.isEmpty {
                Text("No tasks yet.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(KouenDesign.chrome.textSecondary))
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        if !activeTasks.isEmpty {
                            section(title: "Active sessions", tasks: activeTasks)
                        }
                        if !closedTasks.isEmpty {
                            section(title: "Closed sessions", tasks: closedTasks)
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                }
            }

            Divider()
            HStack(spacing: 6) {
                TextField("New task…", text: $newTaskTitle)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                    .onSubmit { Task { await addTask() } }
                Button("Add") { Task { await addTask() } }
                    .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(10)
        }
        .clipShape(RoundedRectangle(cornerRadius: KouenDesign.Radius.overlay, style: .continuous))
        // SwiftUI ties this task's lifetime to the view's — no manual liveness guard
        // needed the way an AppKit completion-handler callback would (RL-063 is about
        // exactly that gap; `.task` closes it structurally).
        .task { await refresh() }
    }

    private func section(title: String, tasks: [TaskSummary]) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color(KouenDesign.chrome.textTertiary))
                .padding(.horizontal, 4)
            ForEach(tasks) { task in
                TaskRowView(
                    task: task,
                    onToggleDone: { Task { await toggleDone(task) } },
                    onJump: { onJumpToSession(task.sessionID) }
                )
            }
        }
    }

    private func refresh() async {
        isLoading = true
        tasks = await TaskDaemonBridge.list(sessionID: nil)
        isLoading = false
    }

    private func addTask() async {
        let title = newTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty,
              let activeSessionID = SessionCoordinator.shared.snapshot.activeWorkspace?.activeSessionID
        else { return }
        newTaskTitle = ""
        _ = await TaskDaemonBridge.create(sessionID: activeSessionID, title: title)
        await refresh()
    }

    private func toggleDone(_ task: TaskSummary) async {
        _ = await TaskDaemonBridge.update(id: task.id, done: !task.done)
        await refresh()
    }
}

private struct TaskRowView: View {
    let task: TaskSummary
    let onToggleDone: () -> Void
    let onJump: () -> Void
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onToggleDone) {
                Image(systemName: task.done ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.done ? Color.green : Color(KouenDesign.chrome.textTertiary))
            }
            .buttonStyle(.plain)

            Text(task.title)
                .font(.system(size: 12))
                .foregroundStyle(Color(KouenDesign.chrome.textPrimary))
                .strikethrough(task.done)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, 10)
        .frame(height: 30)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isHovered ? Color(KouenDesign.chrome.textPrimary).opacity(0.06) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .onTapGesture { onJump() }
    }
}
