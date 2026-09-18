import SwiftUI
import AppKit
import KouenCore
import KouenIPC

struct AutomationsFleetView: View {
    @State var model: AutomationsFleetModel
    var isSidebar: Bool = false
    var onAddJob: (() -> Void)? = nil

    @State private var deleteTarget: FleetJobItem? = nil
    @State private var showDeleteConfirmation = false
    @State private var selectedResultJob: FleetJobItem? = nil

    init(model: AutomationsFleetModel = AutomationsFleetModel(), isSidebar: Bool = false, onAddJob: (() -> Void)? = nil) {
        self._model = State(initialValue: model)
        self.isSidebar = isSidebar
        self.onAddJob = onAddJob
    }

    var body: some View {
        VStack(spacing: 0) {
            if isSidebar {
                sidebarHeaderBar
            } else {
                headerBar
            }
            Divider()

            if model.isLoading && model.jobs.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading real jobs…")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = model.errorMessage, model.jobs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 28))
                        .foregroundStyle(.orange)
                    Text("Failed to Load Jobs")
                        .font(.system(size: 14, weight: .semibold))
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await model.load() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else if model.filteredJobs.isEmpty {
                if isSidebar {
                    sidebarEmptyView
                } else {
                    emptyFleetView
                }
            } else {
                automationsList
            }
        }
        .task {
            await model.load()
        }
        .sheet(item: $selectedResultJob) { job in
            JobResultSheetView(job: job)
        }
        .confirmationDialog(
            "Delete Job?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let target = deleteTarget {
                    Task { await model.delete(id: target.id, isAutomation: target.isAutomation) }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to remove '\(deleteTarget?.name ?? "this job")'?")
        }
    }

    // MARK: - Sidebar Compact Header

    private var sidebarHeaderBar: some View {
        VStack(spacing: 7) {
            HStack(spacing: 5) {
                Picker("", selection: $model.filterStatus) {
                    ForEach(AutomationsFleetModel.FilterStatus.allCases, id: \.self) { st in
                        Text(st.rawValue).tag(st)
                    }
                }
                .pickerStyle(.segmented)
                .controlSize(.mini)
                .frame(maxWidth: 160)

                Spacer()

                if model.runningCount > 0 {
                    statPill(label: "\(model.runningCount) Run", color: .blue)
                }
                statPill(label: "\(model.enabledCount) Active", color: .green)

                Button {
                    Task { await model.load() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Refresh jobs")
            }

            // Compact Search bar
            HStack(spacing: 5) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 10))
                TextField("Search jobs, repos, or AI…", text: $model.filterText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
                if !model.filterText.isEmpty {
                    Button {
                        model.filterText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(Color.secondary.opacity(0.18), lineWidth: 0.8))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
    }

    private func statPill(label: String, color: Color) -> some View {
        Text(label)
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 5)
            .padding(.vertical, 1.5)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    // MARK: - Full Window Header Bar & Metric Cards

    private var headerBar: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Jobs & Automations Fleet")
                        .font(.system(size: 16, weight: .bold))
                    Text("Multi-agent background jobs, scheduled tasks, and execution tracking")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    Task { await model.load() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
            }

            // Fleet KPI stats
            HStack(spacing: 10) {
                metricCard(title: "Total Jobs", value: "\(model.totalCount)", color: .secondary)
                metricCard(title: "Active / Blocked", value: "\(model.enabledCount)", color: .green)
                metricCard(title: "Running", value: "\(model.runningCount)", color: .blue)
                metricCard(title: "Failed", value: "\(model.failedCount)", color: model.failedCount > 0 ? .red : .secondary)
            }

            // Filter bar
            HStack {
                Picker("", selection: $model.filterStatus) {
                    ForEach(AutomationsFleetModel.FilterStatus.allCases, id: \.self) { st in
                        Text(st.rawValue).tag(st)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)

                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 11))
                TextField("Filter by job name, prompt, repo, or AI…", text: $model.filterText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                if !model.filterText.isEmpty {
                    Button {
                        model.filterText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
        }
        .padding(14)
    }

    private func metricCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.secondary.opacity(0.15), lineWidth: 1))
    }

    // MARK: - Automations List

    private var automationsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: isSidebar ? 8 : 14) {
                ForEach(model.groupedByRepo, id: \.repo) { group in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 5) {
                            Image(systemName: "folder.fill")
                                .font(.system(size: isSidebar ? 10 : 11))
                                .foregroundStyle(Color.accentColor)
                            Text(KouenDesign.pathDisplayName(group.repo))
                                .font(.system(size: isSidebar ? 11 : 12.5, weight: .bold))
                            Text(KouenDesign.shortenPath(group.repo))
                                .font(.system(size: isSidebar ? 8.5 : 10))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            Spacer()
                            Text("\(group.items.count)")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(Color.secondary.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 4)

                        ForEach(group.items) { item in
                            jobCard(item)
                        }
                    }
                }
            }
            .padding(isSidebar ? 8 : 14)
        }
    }

    // MARK: - Job Card (2 Lines Design)

    private func jobCard(_ item: FleetJobItem) -> some View {
        let c = KouenDesign.chrome

        return VStack(alignment: .leading, spacing: 6) {
            // Line 1: [Logo AI] : [ชื่องานคืออะไร]    [📁 โปรเจกต์ไหน]
            HStack(alignment: .center, spacing: 5) {
                // Logo AI (vector icon)
                Image(nsImage: AgentIconRenderer.templateOrMonogramImage(for: item.agentKind, size: 12))
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(agentColor(for: item.agentKind))
                    .frame(width: 12, height: 12)

                Text(":")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary.opacity(0.6))

                // ชื่องานที่ว่าคืออะไร
                Text(item.name.isEmpty ? item.prompt : item.name)
                    .font(.system(size: isSidebar ? 11 : 12, weight: .semibold))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(item.isActive ? Color(nsColor: c.textPrimary) : Color.primary.opacity(0.85))
                    .help(item.prompt)

                Spacer(minLength: 4)

                // อยู่โปรเจกต์ไหน
                HStack(spacing: 3) {
                    Image(systemName: "folder")
                        .font(.system(size: 8))
                    Text(KouenDesign.pathDisplayName(item.repoPath))
                        .font(.system(size: isSidebar ? 8.5 : 9.5, weight: .medium))
                        .lineLimit(1)
                }
                .foregroundStyle(Color.secondary)
                .padding(.horizontal, 4.5)
                .padding(.vertical, 1.5)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .help(item.repoPath)
            }

            // Line 2: [Status Dot + Label] [รันเมื่อไร ตอนไหน] --- Spacer --- [Result Button] [Open]
            HStack(alignment: .center, spacing: 6) {
                // Status Indicator
                statusIndicator(item)

                // รันเมื่อไร ตอนไหน (Schedule & Timing)
                timingLabel(item)

                Spacer(minLength: 4)

                // ปุ่มเปิดดู result รองรับหลายแบบ เช่น html หรืออื่นๆ
                resultControl(item)

                // Terminal / Automation Action
                if item.isAutomation {
                    Button {
                        Task { await model.runNow(id: item.id) }
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 8))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                    .help("Run automation now")
                } else {
                    Button {
                        model.openJobSession(item: item)
                    } label: {
                        HStack(spacing: 2) {
                            Image(systemName: "terminal")
                                .font(.system(size: 7.5))
                            Text("Open")
                                .font(.system(size: 8.5, weight: .medium))
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                    .help("Open terminal in \(KouenDesign.pathDisplayName(item.repoPath))")
                }

                // Delete button
                Button {
                    deleteTarget = item
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 8.5))
                        .foregroundStyle(.secondary.opacity(0.7))
                }
                .buttonStyle(.plain)
                .help("Delete job")
            }
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .stroke(item.isActive ? Color.secondary.opacity(0.2) : Color.secondary.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Status & Timing Components

    @ViewBuilder
    private func statusIndicator(_ item: FleetJobItem) -> some View {
        let st = item.state.lowercased()
        if st == "running" {
            HStack(spacing: 2.5) {
                ProgressView()
                    .controlSize(.mini)
                Text("Running")
                    .font(.system(size: 8.5, weight: .medium))
            }
            .foregroundStyle(.blue)
        } else if st == "blocked" {
            HStack(spacing: 3) {
                Circle().fill(Color.orange).frame(width: 5, height: 5)
                Text("Needs Input")
                    .font(.system(size: 8.5, weight: .medium))
            }
            .foregroundStyle(.orange)
        } else if st == "failed" || st == "error" {
            HStack(spacing: 3) {
                Circle().fill(Color.red).frame(width: 5, height: 5)
                Text("Failed")
                    .font(.system(size: 8.5, weight: .medium))
            }
            .foregroundStyle(.red)
        } else {
            HStack(spacing: 3) {
                Circle().fill(Color.green).frame(width: 5, height: 5)
                Text("Done")
                    .font(.system(size: 8.5, weight: .medium))
            }
            .foregroundStyle(.green)
        }
    }

    @ViewBuilder
    private func timingLabel(_ item: FleetJobItem) -> some View {
        HStack(spacing: 3) {
            Text("•")
                .font(.system(size: 8))
                .foregroundStyle(.secondary.opacity(0.5))

            if let interval = item.intervalMinutes {
                HStack(spacing: 2) {
                    Image(systemName: interval == 0 ? "hand.tap" : "clock")
                        .font(.system(size: 7.5))
                    Text(interval == 0 ? "Manual" : "\(interval)m")
                        .font(.system(size: 8.5, weight: .medium))
                }
                .foregroundStyle(.secondary)
            }

            if let last = item.lastRunAt {
                Text(last, style: .relative)
                    .font(.system(size: 8.5))
                    .foregroundStyle(.secondary)
            } else if let created = item.createdAt {
                Text(created, style: .date)
                    .font(.system(size: 8.5))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Result Control (Multi-Format: HTML, Screenshots, Output)

    @ViewBuilder
    private func resultControl(_ item: FleetJobItem) -> some View {
        if !item.hasResults {
            EmptyView()
        } else if let html = item.primaryHTMLArtifact, item.artifacts.count == 1 && item.outputSummary == nil {
            // Single HTML report: 1-click open directly in browser!
            Button {
                openArtifact(html)
            } label: {
                HStack(spacing: 2.5) {
                    Image(systemName: "globe")
                        .font(.system(size: 7.5))
                    Text("HTML")
                        .font(.system(size: 8.5, weight: .semibold))
                }
                .foregroundStyle(.blue)
            }
            .buttonStyle(.bordered)
            .controlSize(.mini)
            .help("Open HTML report in browser: \(html.name)")
        } else if item.artifacts.count > 1 || (item.primaryHTMLArtifact != nil && item.outputSummary != nil) {
            // Multi-format result (HTML, images, markdown, output text)
            Menu {
                if let html = item.primaryHTMLArtifact {
                    Button {
                        openArtifact(html)
                    } label: {
                        Label("Open HTML Report (\(html.name))", systemImage: "globe")
                    }
                }
                if item.outputSummary != nil || item.detailText != nil {
                    Button {
                        selectedResultJob = item
                    } label: {
                        Label("View Output Summary", systemImage: "doc.text")
                    }
                }
                ForEach(item.artifacts.filter { $0 != item.primaryHTMLArtifact }) { art in
                    Button {
                        openArtifact(art)
                    } label: {
                        Label("Open \(art.name)", systemImage: art.systemImage)
                    }
                }
                Divider()
                Button {
                    selectedResultJob = item
                } label: {
                    Label("Inspect All Results…", systemImage: "magnifyingglass")
                }
            } label: {
                HStack(spacing: 2) {
                    Image(systemName: item.primaryHTMLArtifact != nil ? "globe" : "doc.text.magnifyingglass")
                        .font(.system(size: 7.5))
                    Text("Result")
                        .font(.system(size: 8.5, weight: .medium))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 6))
                        .foregroundStyle(.secondary)
                }
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .help("View results (HTML, screenshots, logs)")
        } else {
            // Single text output or single file: opens Result Sheet or file
            Button {
                if let firstArt = item.artifacts.first {
                    openArtifact(firstArt)
                } else {
                    selectedResultJob = item
                }
            } label: {
                HStack(spacing: 2) {
                    Image(systemName: item.artifacts.first?.systemImage ?? "doc.text.magnifyingglass")
                        .font(.system(size: 7.5))
                    Text("Result")
                        .font(.system(size: 8.5, weight: .medium))
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.mini)
            .help("View output result")
        }
    }

    private func openArtifact(_ artifact: JobResultArtifact) {
        let url = URL(fileURLWithPath: artifact.path)
        NSWorkspace.shared.open(url)
    }

    private var sidebarEmptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "bolt.badge.clock")
                .font(.system(size: 28))
                .foregroundStyle(.secondary.opacity(0.6))

            VStack(spacing: 4) {
                Text("No Jobs Found")
                    .font(.system(size: 12.5, weight: .semibold))
                Text("Background agent jobs across all projects will appear here.")
                    .font(.system(size: 10.5))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }

            if let onAddJob {
                Button {
                    onAddJob()
                } label: {
                    Label("New Job", systemImage: "plus")
                        .font(.system(size: 11))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var emptyFleetView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bolt.badge.clock")
                .font(.system(size: 40))
                .foregroundStyle(.secondary.opacity(0.6))

            VStack(spacing: 6) {
                Text("No Jobs Found")
                    .font(.system(size: 15, weight: .bold))
                Text("Background tasks across all projects will be automatically tracked here.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 380)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func agentColor(for kind: AgentKind) -> Color {
        let hex = SessionCoordinator.shared.settings.agentColorHex(for: kind)
        return Color(nsColor: NSColor.fromHex(hex) ?? KouenDesign.chrome.textSecondary)
    }
}

// MARK: - Dedicated Job Result Viewer Sheet

struct JobResultSheetView: View {
    let job: FleetJobItem
    @Environment(\.dismiss) private var dismiss
    @State private var copied: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: AI Logo + Job Name + Project
            HStack(spacing: 8) {
                Image(nsImage: AgentIconRenderer.templateOrMonogramImage(for: job.agentKind, size: 16))
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(agentColor(for: job.agentKind))
                    .frame(width: 16, height: 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text(job.name.isEmpty ? job.prompt : job.name)
                        .font(.system(size: 14, weight: .bold))
                        .lineLimit(2)
                    HStack(spacing: 4) {
                        Text(job.agentKind.displayName)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(KouenDesign.pathDisplayName(job.repoPath))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                        if let last = job.lastRunAt {
                            Text("•")
                                .foregroundStyle(.secondary)
                            Text(last, style: .date)
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Output Result Section
                    if let out = job.outputSummary, !out.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Output Result")
                                    .font(.system(size: 11.5, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Button {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(out, forType: .string)
                                    copied = true
                                    Task {
                                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                                        copied = false
                                    }
                                } label: {
                                    HStack(spacing: 3) {
                                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                            .font(.system(size: 9))
                                        Text(copied ? "Copied" : "Copy")
                                            .font(.system(size: 10))
                                    }
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                            }

                            Text(out)
                                .font(.system(size: 12, design: .monospaced))
                                .textSelection(.enabled)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(nsColor: .controlBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(Color.secondary.opacity(0.15), lineWidth: 1))
                        }
                    }

                    // Execution Notes & Details
                    if let detail = job.detailText, !detail.isEmpty, detail != job.outputSummary {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Execution Notes & Status")
                                .font(.system(size: 11.5, weight: .semibold))
                                .foregroundStyle(.secondary)

                            Text(detail)
                                .font(.system(size: 11.5))
                                .textSelection(.enabled)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                    }

                    // Generated Artifacts & Reports (HTML, Screenshots, Markdown)
                    if !job.artifacts.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Generated Reports & Artifacts (\(job.artifacts.count))")
                                .font(.system(size: 11.5, weight: .semibold))
                                .foregroundStyle(.secondary)

                            VStack(spacing: 6) {
                                ForEach(job.artifacts) { art in
                                    HStack(spacing: 8) {
                                        Image(systemName: art.systemImage)
                                            .font(.system(size: 13))
                                            .foregroundStyle(art.kind == .html ? Color.blue : Color.secondary)
                                            .frame(width: 16)

                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(art.name)
                                                .font(.system(size: 11.5, weight: .medium))
                                            Text(art.path)
                                                .font(.system(size: 9.5))
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }

                                        Spacer()

                                        Button {
                                            NSWorkspace.shared.open(URL(fileURLWithPath: art.path))
                                        } label: {
                                            Text(art.kind == .html ? "Open in Browser" : "Open")
                                                .font(.system(size: 10))
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.mini)

                                        Button {
                                            NSWorkspace.shared.selectFile(art.path, inFileViewerRootedAtPath: "")
                                        } label: {
                                            Image(systemName: "folder")
                                                .font(.system(size: 10))
                                        }
                                        .buttonStyle(.plain)
                                        .help("Show in Finder")
                                    }
                                    .padding(7)
                                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.7))
                                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Divider()

            // Footer Actions
            HStack {
                Button {
                    let coordinator = SessionCoordinator.shared
                    if let wsID = coordinator.snapshot.activeWorkspaceID {
                        coordinator.addSession(to: wsID, cwd: job.repoPath, name: job.name)
                    }
                    dismiss()
                } label: {
                    Label("Open Project in Terminal", systemImage: "terminal")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Spacer()

                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .controlSize(.small)
            }
        }
        .padding(18)
        .frame(minWidth: 460, idealWidth: 520, maxWidth: 640, minHeight: 320, idealHeight: 420, maxHeight: 600)
    }

    private func agentColor(for kind: AgentKind) -> Color {
        let hex = SessionCoordinator.shared.settings.agentColorHex(for: kind)
        return Color(nsColor: NSColor.fromHex(hex) ?? KouenDesign.chrome.textSecondary)
    }
}
