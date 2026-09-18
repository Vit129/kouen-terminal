import AppKit
import SwiftUI
import KouenCore
import KouenIPC

public struct IssueTrackerPanelView: View {
    @State private var selectedTracker: IssueTrackerType = .linear
    @State private var issues: [TrackedIssue] = []
    @State private var searchQuery: String = ""
    @State private var isLoading = false
    @State private var showSettingsSheet = false
    @State private var patInput = ""
    @State private var toastMessage: String?

    public init() {}

    public var body: some View {
        let c = KouenDesign.chrome
        VStack(spacing: 0) {
            // Tracker Selector & Actions
            HStack(spacing: 6) {
                Picker("", selection: $selectedTracker) {
                    ForEach(IssueTrackerType.allCases) { tracker in
                        Text(tracker.rawValue).tag(tracker)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                Button(action: { refreshIssues() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(nsColor: c.textSecondary))
                }
                .buttonStyle(.plain)
                .help("Refresh issues")

                Button(action: {
                    patInput = IssueKeychainStore.loadToken(for: selectedTracker) ?? ""
                    showSettingsSheet = true
                }) {
                    Image(systemName: "key")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(nsColor: c.textSecondary))
                }
                .buttonStyle(.plain)
                .help("Configure API token in Keychain")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)

            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(nsColor: c.textTertiary))
                TextField("Search issues…", text: $searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
            }
            .padding(5)
            .background(Color(nsColor: c.sidebarBackground).opacity(0.5), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .padding(.horizontal, 10)
            .padding(.bottom, 6)

            Divider()

            // Issue Cards List
            if isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(0.8)
                Spacer()
            } else if filteredIssues.isEmpty {
                Spacer()
                VStack(spacing: 6) {
                    Image(systemName: "checklist")
                        .font(.system(size: 24))
                        .foregroundStyle(Color(nsColor: c.textTertiary))
                    Text("No issues found")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(nsColor: c.textSecondary))
                }
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 6) {
                        ForEach(filteredIssues) { issue in
                            issueCardRow(issue, c: c)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                }
            }
        }
        .background(Color(nsColor: c.sidebarBackground))
        .onAppear {
            refreshIssues()
        }
        .onChange(of: selectedTracker) { _, _ in
            refreshIssues()
        }
        .sheet(isPresented: $showSettingsSheet) {
            tokenSettingsSheet(c: c)
        }
        .overlay(alignment: .bottom) {
            if let msg = toastMessage {
                Text(msg)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.85), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private var filteredIssues: [TrackedIssue] {
        if searchQuery.isEmpty { return issues }
        return issues.filter {
            $0.key.localizedCaseInsensitiveContains(searchQuery) ||
            $0.title.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    @ViewBuilder
    private func issueCardRow(_ issue: TrackedIssue, c: KouenChromePalette) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            // Key + Priority + Status
            HStack(spacing: 6) {
                Text(issue.key)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(nsColor: c.accent))

                HStack(spacing: 2) {
                    Image(systemName: issue.priority.symbol)
                        .font(.system(size: 8, weight: .bold))
                    Text(issue.priority.rawValue)
                        .font(.system(size: 9, weight: .medium))
                }
                .foregroundStyle(issue.priority.color)

                Spacer()

                Text(issue.status)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Color(nsColor: c.textTertiary))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color(nsColor: c.textSecondary).opacity(0.12), in: RoundedRectangle(cornerRadius: 3, style: .continuous))
            }

            // Title
            Text(issue.title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(nsColor: c.textPrimary))
                .lineLimit(2)
                .truncationMode(.tail)

            if let desc = issue.description, !desc.isEmpty {
                Text(desc)
                    .font(.system(size: 10))
                    .foregroundStyle(Color(nsColor: c.textSecondary).opacity(0.7))
                    .lineLimit(2)
                    .truncationMode(.tail)
            }

            // Action Row: 1-Click "Start Agent on Issue"
            HStack {
                Spacer()
                Button(action: { startAgentOnIssue(issue) }) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 9, weight: .semibold))
                        Text("Start Agent on Issue")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(nsColor: c.accent).opacity(0.18), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .foregroundStyle(Color(nsColor: c.accent))
                }
                .buttonStyle(.plain)
                .help("Create worktree and start AI agent on \(issue.key)")
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: KouenDesign.Radius.card, style: .continuous)
                .fill(Color(nsColor: c.surfaceElevated).opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: KouenDesign.Radius.card, style: .continuous)
                        .stroke(Color(nsColor: c.border).opacity(0.3), lineWidth: 1)
                )
        )
    }

    @ViewBuilder
    private func tokenSettingsSheet(c: KouenChromePalette) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "key.fill")
                    .foregroundStyle(Color(nsColor: c.accent))
                Text("\(selectedTracker.rawValue) Keychain Token")
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Button("Close") { showSettingsSheet = false }
                    .buttonStyle(.plain)
            }

            Text("Stored securely in macOS Keychain (kSecClassGenericPassword).")
                .font(.system(size: 11))
                .foregroundStyle(Color(nsColor: c.textTertiary))

            SecureField("Personal Access Token (PAT)", text: $patInput)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Clear Token", role: .destructive) {
                    IssueKeychainStore.deleteToken(for: selectedTracker)
                    patInput = ""
                    showSettingsSheet = false
                    refreshIssues()
                    showToast("Token cleared")
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Save to Keychain") {
                    let trimmed = patInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        _ = IssueKeychainStore.saveToken(trimmed, for: selectedTracker)
                        showToast("✓ Token saved to Keychain")
                    }
                    showSettingsSheet = false
                    refreshIssues()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(16)
        .frame(width: 360)
    }

    private func refreshIssues() {
        isLoading = true
        Task {
            let fetched = await IssueTrackerService.shared.fetchAssignedIssues(tracker: selectedTracker)
            await MainActor.run {
                self.issues = fetched
                self.isLoading = false
            }
        }
    }

    private func startAgentOnIssue(_ issue: TrackedIssue) {
        guard let wsID = SessionCoordinator.shared.snapshot.activeWorkspaceID else {
            showToast("No active workspace")
            return
        }

        let branch = IssueTrackerService.sanitizeBranchName(key: issue.key, title: issue.title)
        let prompt = IssueTrackerService.generateAgentTaskPrompt(for: issue)

        // Pass nil so SessionLifecycleService falls back to the repo's own ProjectConfig.baseRef
        // rather than blindly assuming "main".
        if let errorMsg = SessionCoordinator.shared.addAgentTask(to: wsID, taskName: branch, baseBranch: nil) {
            showToast("⚠️ \(errorMsg)")
            return
        }

        // Dispatch initial prompt to the new session's surface
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if let surfaceID = SessionCoordinator.shared.activeSurfaceID {
                SessionCoordinator.shared.requestDaemon(
                    .sendData(surfaceID: surfaceID.uuidString, data: Data(prompt.utf8))
                )
            }
        }
        showToast("✓ Started Agent on \(issue.key)")
    }

    private func showToast(_ msg: String) {
        toastMessage = msg
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if toastMessage == msg { toastMessage = nil }
        }
    }
}
