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

/// `internal` (not `private`) so `groupByRoot`'s dedupe/grouping logic is unit-testable via
/// `@testable import KouenApp` — mirrors `RecipePickerModel`'s visibility for the same reason.
struct TaskDashboardBody: View {
    let onJumpToSession: (SessionID) -> Void

    @State private var tasks: [TaskSummary] = []
    @State private var newTaskTitle: String = ""
    @State private var isLoading = true
    /// Tasks grouped by project (git root of `task.cwd`), resolved once per `refresh()` —
    /// not a computed property, since resolving each task's git root shells out to `git`
    /// and must not re-run on every SwiftUI render. Sorted by display name for a stable
    /// order across refreshes. Same heuristic as the sidebar's project grouping
    /// (`SidebarListModel.repoRootForSession` / `KouenDesign.projectGroupDisplayName`).
    @State private var groups: [(name: String, tasks: [TaskSummary])] = []

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
                        ForEach(groups, id: \.name) { group in
                            section(title: group.name, tasks: group.tasks)
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
        let byRoot = await Self.groupByRoot(tasks)
        groups = byRoot.map { root, tasks in
            (name: KouenDesign.projectGroupDisplayName(forRootPath: root), tasks: tasks)
        }.sorted { $0.name < $1.name }
        isLoading = false
    }

    /// Groups by the git root of each task's `cwd` (nil/legacy tasks — see `KouenTask.cwd`'s
    /// doc comment — group under `""`, which `projectGroupDisplayName` turns into "Sessions").
    /// Off the main actor: `GitMetadataProvider.topLevel` shells out to `git` per unique cwd,
    /// so this must not run on every SwiftUI render. `projectGroupDisplayName` itself stays on
    /// the caller's (main) actor — it's `KouenDesign`-isolated, not because it touches UI state.
    static func groupByRoot(_ tasks: [TaskSummary]) async -> [String: [TaskSummary]] {
        await Task.detached(priority: .userInitiated) {
            var rootCache: [String: String] = [:]
            func root(for cwd: String?) -> String {
                guard let cwd, !cwd.isEmpty else { return "" }
                if let cached = rootCache[cwd] { return cached }
                let resolved = GitMetadataProvider.topLevel(at: cwd) ?? cwd
                rootCache[cwd] = resolved
                return resolved
            }
            var byRoot: [String: [TaskSummary]] = [:]
            for task in tasks {
                byRoot[root(for: task.cwd), default: []].append(task)
            }
            return byRoot
        }.value
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
