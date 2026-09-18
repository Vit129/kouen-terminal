import Foundation
import Observation
import SQLite3
import KouenCore
import KouenIPC

public struct JobResultArtifact: Identifiable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let path: String
    public let kind: ArtifactKind

    public enum ArtifactKind: String, Sendable, Equatable {
        case html = "HTML Report"
        case image = "Screenshot / Image"
        case markdown = "Markdown Note"
        case text = "Log / Text"
        case json = "JSON Data"
    }

    public var systemImage: String {
        switch kind {
        case .html: return "globe"
        case .image: return "photo"
        case .markdown: return "doc.text"
        case .text: return "doc.plaintext"
        case .json: return "curlybraces"
        }
    }
}

public struct FleetJobItem: Identifiable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let prompt: String
    public let repoPath: String
    public let agentKind: AgentKind
    public let isEnabled: Bool
    public let state: String
    public let intervalMinutes: Int?
    public let lastRunStatus: String?
    public let lastRunAt: Date?
    public let nextRunAt: Date?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let isAutomation: Bool

    // Result information
    public let outputSummary: String?
    public let detailText: String?
    public let artifacts: [JobResultArtifact]

    public var hasResults: Bool {
        (outputSummary != nil && !outputSummary!.isEmpty) ||
        (detailText != nil && !detailText!.isEmpty) ||
        !artifacts.isEmpty
    }

    public var primaryHTMLArtifact: JobResultArtifact? {
        artifacts.first(where: { $0.kind == .html })
    }

    public var isActive: Bool {
        if isAutomation {
            return isEnabled
        }
        return state == "running" || state == "blocked"
    }

    public var statusDisplay: String {
        switch state.lowercased() {
        case "running": return "Running"
        case "blocked": return "Needs Input"
        case "done", "success", "ok": return "Done"
        case "failed", "error": return "Failed"
        case "cancelled": return "Cancelled"
        default: return state.capitalized
        }
    }
}

@Observable @MainActor
final class AutomationsFleetModel {
    var jobs: [FleetJobItem] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var filterText: String = ""
    var filterStatus: FilterStatus = .all

    enum FilterStatus: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case completed = "Done"
    }

    var totalCount: Int { jobs.count }
    var enabledCount: Int { jobs.filter(\.isActive).count }
    var runningCount: Int { jobs.filter { $0.state.lowercased() == "running" }.count }
    var failedCount: Int { jobs.filter { $0.state.lowercased() == "failed" }.count }

    var filteredJobs: [FleetJobItem] {
        var items = jobs

        switch filterStatus {
        case .all:
            break
        case .active:
            items = items.filter(\.isActive)
        case .completed:
            items = items.filter { !$0.isActive }
        }

        if !filterText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let q = filterText.lowercased()
            items = items.filter {
                $0.name.lowercased().contains(q) ||
                $0.prompt.lowercased().contains(q) ||
                $0.repoPath.lowercased().contains(q) ||
                $0.agentKind.displayName.lowercased().contains(q)
            }
        }

        return items
    }

    var groupedByRepo: [(repo: String, items: [FleetJobItem])] {
        let items = filteredJobs
        let dict = Dictionary(grouping: items, by: { $0.repoPath })
        return dict.keys.sorted().map { repo in
            let sortedItems = (dict[repo] ?? []).sorted(by: { ($0.updatedAt ?? $0.createdAt ?? .distantPast) > ($1.updatedAt ?? $1.createdAt ?? .distantPast) })
            return (repo: repo, items: sortedItems)
        }
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        var fetchedJobs: [FleetJobItem] = []

        // 1. Fetch daemon automations via IPC
        let res = await SessionCoordinator.shared.requestDaemon(.automationList)
        if case let .automations(list) = res {
            for a in list {
                let kind = AgentKind(rawValue: a.agent) ?? .claudeCode
                var artifacts: [JobResultArtifact] = []
                Self.detectRepoArtifacts(repoPath: a.repoPath, into: &artifacts)

                let item = FleetJobItem(
                    id: a.id.uuidString,
                    name: a.prompt,
                    prompt: a.prompt,
                    repoPath: a.repoPath,
                    agentKind: kind,
                    isEnabled: a.enabled,
                    state: a.lastRunStatus ?? "scheduled",
                    intervalMinutes: a.intervalMinutes,
                    lastRunStatus: a.lastRunStatus,
                    lastRunAt: a.lastRunAt,
                    nextRunAt: a.nextRunAt,
                    createdAt: a.createdAt,
                    updatedAt: a.updatedAt,
                    isAutomation: true,
                    outputSummary: nil,
                    detailText: a.lastRunStatus != nil ? "Last execution status: \(a.lastRunStatus!)" : nil,
                    artifacts: artifacts
                )
                fetchedJobs.append(item)
            }
        }

        // 2. Read genuine agent background jobs across Claude, Gemini, Copilot
        let agentJobs = await Task.detached(priority: .userInitiated) { () -> [FleetJobItem] in
            var all: [FleetJobItem] = []
            all.append(contentsOf: Self.fetchClaudeJobs())
            all.append(contentsOf: Self.fetchGeminiTasks())
            all.append(contentsOf: Self.fetchCopilotSessions())
            return all
        }.value

        fetchedJobs.append(contentsOf: agentJobs)

        // Sort by most recently updated
        self.jobs = fetchedJobs.sorted(by: { ($0.updatedAt ?? $0.createdAt ?? .distantPast) > ($1.updatedAt ?? $1.createdAt ?? .distantPast) })
        self.isLoading = false
    }

    // MARK: - Detect Project Result Files (HTML Reports, Coverage, Graphs)

    nonisolated static func detectRepoArtifacts(repoPath: String, into artifacts: inout [JobResultArtifact]) {
        let checkList: [(rel: String, name: String, kind: JobResultArtifact.ArtifactKind)] = [
            ("playwright-report/index.html", "Playwright Report (HTML)", .html),
            (".robot-output/report.html", "Robot Report (HTML)", .html),
            (".robot-output/log.html", "Robot Log (HTML)", .html),
            ("graphify-out/graph.html", "Graphify Visualizer (HTML)", .html),
            ("coverage/index.html", "Coverage Report (HTML)", .html),
            ("out/index.html", "Web Build (HTML)", .html),
            ("plans/p25-mobile-session-switcher-design.html", "Mobile Switcher Design (HTML)", .html)
        ]
        let fm = FileManager.default
        for chk in checkList {
            let p = (repoPath as NSString).appendingPathComponent(chk.rel)
            if fm.fileExists(atPath: p) {
                if !artifacts.contains(where: { $0.path == p }) {
                    artifacts.append(JobResultArtifact(id: chk.rel, name: chk.name, path: p, kind: chk.kind))
                }
            }
        }
    }

    // MARK: - Claude Background Jobs (~/.claude/jobs)

    nonisolated private static func fetchClaudeJobs() -> [FleetJobItem] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let jobsDir = home.appendingPathComponent(".claude/jobs")
        guard let entries = try? FileManager.default.contentsOfDirectory(at: jobsDir, includingPropertiesForKeys: nil) else {
            return []
        }

        let isoFormatterFractional = ISO8601DateFormatter()
        isoFormatterFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]

        var results: [FleetJobItem] = []

        for dir in entries {
            let stateFile = dir.appendingPathComponent("state.json")
            guard let data = try? Data(contentsOf: stateFile),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                continue
            }

            let jobID = dir.lastPathComponent
            let name = (json["name"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            let intent = (json["intent"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let state = (json["state"] as? String) ?? "done"
            let cwd = (json["cwd"] as? String) ?? home.path
            let flags = (json["respawnFlags"] as? [String]) ?? []

            // Extract output result summary
            var outputSummary: String? = nil
            if let outObj = json["output"] as? [String: Any] {
                outputSummary = outObj["result"] as? String
            } else if let outStr = json["output"] as? String {
                outputSummary = outStr
            }

            let detailText = (json["detail"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            let needsText = (json["needs"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)

            let displayName = name?.isEmpty == false ? name! : (intent.isEmpty ? jobID : intent)

            // Resolve AgentKind
            let kind: AgentKind
            if cwd.contains(".copilot") {
                kind = .copilot
            } else if cwd.contains(".gemini") || displayName.lowercased().contains("agy") || displayName.lowercased().contains("antigravity") {
                kind = .antigravity
            } else if cwd.contains(".kiro") {
                kind = .kiro
            } else if flags.contains("codex") {
                kind = .codex
            } else {
                kind = .claudeCode
            }

            // Dates
            let createdStr = json["createdAt"] as? String
            let updatedStr = json["updatedAt"] as? String
            let createdDate = createdStr.flatMap { isoFormatterFractional.date(from: $0) ?? isoFormatter.date(from: $0) }
            let updatedDate = updatedStr.flatMap { isoFormatterFractional.date(from: $0) ?? isoFormatter.date(from: $0) }

            let isEnabled = state == "running" || state == "blocked"

            // Scan artifacts in job directory & tmp
            var artifacts: [JobResultArtifact] = []
            if let dirFiles = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) {
                for f in dirFiles {
                    let ext = f.pathExtension.lowercased()
                    if ext == "png" || ext == "jpg" || ext == "webp" {
                        artifacts.append(JobResultArtifact(id: f.lastPathComponent, name: f.lastPathComponent, path: f.path, kind: .image))
                    } else if ext == "html" {
                        artifacts.append(JobResultArtifact(id: f.lastPathComponent, name: f.lastPathComponent, path: f.path, kind: .html))
                    } else if ext == "md" && f.lastPathComponent != "README.md" {
                        artifacts.append(JobResultArtifact(id: f.lastPathComponent, name: f.lastPathComponent, path: f.path, kind: .markdown))
                    }
                }
            }
            let tmpDir = dir.appendingPathComponent("tmp")
            if let tmpFiles = try? FileManager.default.subpathsOfDirectory(atPath: tmpDir.path) {
                for sub in tmpFiles {
                    let f = tmpDir.appendingPathComponent(sub)
                    let ext = f.pathExtension.lowercased()
                    if ext == "html" {
                        artifacts.append(JobResultArtifact(id: f.lastPathComponent, name: f.lastPathComponent, path: f.path, kind: .html))
                    } else if ext == "png" || ext == "jpg" {
                        artifacts.append(JobResultArtifact(id: f.lastPathComponent, name: f.lastPathComponent, path: f.path, kind: .image))
                    } else if ext == "md" {
                        artifacts.append(JobResultArtifact(id: f.lastPathComponent, name: f.lastPathComponent, path: f.path, kind: .markdown))
                    }
                }
            }

            // Check project reports in cwd
            detectRepoArtifacts(repoPath: cwd, into: &artifacts)

            let finalDetail = needsText != nil && !needsText!.isEmpty ? "Needs: \(needsText!)" : detailText

            let item = FleetJobItem(
                id: jobID,
                name: displayName,
                prompt: intent.isEmpty ? displayName : intent,
                repoPath: cwd,
                agentKind: kind,
                isEnabled: isEnabled,
                state: state,
                intervalMinutes: nil,
                lastRunStatus: state,
                lastRunAt: updatedDate ?? createdDate,
                nextRunAt: nil,
                createdAt: createdDate,
                updatedAt: updatedDate,
                isAutomation: false,
                outputSummary: outputSummary,
                detailText: finalDetail,
                artifacts: artifacts
            )
            results.append(item)
        }

        return results
    }

    // MARK: - Gemini / Antigravity Tasks (~/.gemini/antigravity-cli/conversation_summaries.db)

    nonisolated private static func fetchGeminiTasks() -> [FleetJobItem] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dbPath = home.appendingPathComponent(".gemini/antigravity-cli/conversation_summaries.db").path
        guard FileManager.default.fileExists(atPath: dbPath) else { return [] }

        var db: OpaquePointer?
        guard sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else {
            return []
        }
        defer { sqlite3_close(db) }

        let sql = """
        SELECT conversation_id, title, preview, last_modified_time, workspace_uris, not_fully_idle
        FROM conversation_summaries
        ORDER BY last_modified_time DESC
        LIMIT 40;
        """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            return []
        }
        defer { sqlite3_finalize(stmt) }

        var items: [FleetJobItem] = []
        let isoFormatterFractional = ISO8601DateFormatter()
        isoFormatterFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]

        while sqlite3_step(stmt) == SQLITE_ROW {
            guard let cidPtr = sqlite3_column_text(stmt, 0),
                  let titlePtr = sqlite3_column_text(stmt, 1) else {
                continue
            }
            let cid = String(cString: cidPtr)
            let title = String(cString: titlePtr)
            let preview = sqlite3_column_text(stmt, 2).map { String(cString: $0) } ?? ""
            let lastModStr = sqlite3_column_text(stmt, 3).map { String(cString: $0) }
            let urisStr = sqlite3_column_text(stmt, 4).map { String(cString: $0) } ?? ""
            let notFullyIdle = sqlite3_column_int(stmt, 5)

            // Parse repo path from workspace_uris JSON array (e.g. ["file:///path/to/repo"])
            var repo = home.path
            if let urisData = urisStr.data(using: .utf8),
               let urisArray = try? JSONSerialization.jsonObject(with: urisData) as? [String],
               let firstURI = urisArray.first,
               let url = URL(string: firstURI) {
                repo = url.path
            }

            let lastModDate = lastModStr.flatMap {
                isoFormatterFractional.date(from: $0) ?? isoFormatter.date(from: $0)
            }

            let isRunning = notFullyIdle == 1
            let state = isRunning ? "running" : "done"
            let jobTitle = title.isEmpty ? preview : title

            // Check brain directory for artifacts
            let brainDir = home.appendingPathComponent(".gemini/antigravity-cli/brain").appendingPathComponent(cid)
            var artifacts: [JobResultArtifact] = []
            if let brainFiles = try? FileManager.default.contentsOfDirectory(at: brainDir, includingPropertiesForKeys: nil) {
                for f in brainFiles {
                    let ext = f.pathExtension.lowercased()
                    if ext == "md" {
                        artifacts.append(JobResultArtifact(id: f.lastPathComponent, name: f.lastPathComponent, path: f.path, kind: .markdown))
                    } else if ext == "html" {
                        artifacts.append(JobResultArtifact(id: f.lastPathComponent, name: f.lastPathComponent, path: f.path, kind: .html))
                    } else if ext == "png" || ext == "jpg" {
                        artifacts.append(JobResultArtifact(id: f.lastPathComponent, name: f.lastPathComponent, path: f.path, kind: .image))
                    }
                }
            }

            // Check repo for common reports
            detectRepoArtifacts(repoPath: repo, into: &artifacts)

            let item = FleetJobItem(
                id: cid,
                name: jobTitle,
                prompt: preview.isEmpty ? jobTitle : preview,
                repoPath: repo,
                agentKind: .antigravity,
                isEnabled: isRunning,
                state: state,
                intervalMinutes: nil,
                lastRunStatus: state,
                lastRunAt: lastModDate,
                nextRunAt: nil,
                createdAt: lastModDate,
                updatedAt: lastModDate,
                isAutomation: false,
                outputSummary: preview.isEmpty ? nil : preview,
                detailText: nil,
                artifacts: artifacts
            )
            items.append(item)
        }

        return items
    }

    // MARK: - GitHub Copilot Sessions (~/.copilot/session-state)

    nonisolated private static func fetchCopilotSessions() -> [FleetJobItem] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let sessionStateDir = home.appendingPathComponent(".copilot/session-state")
        guard let entries = try? FileManager.default.contentsOfDirectory(at: sessionStateDir, includingPropertiesForKeys: nil) else {
            return []
        }

        // Read open sessions state to check which ones are active
        var workingSet: Set<String> = []
        let openStateFile = home.appendingPathComponent(".copilot/open-sessions-state.json")
        if let data = try? Data(contentsOf: openStateFile),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] {
            for (sid, dict) in json {
                if (dict["working"] as? Bool) == true {
                    workingSet.insert(sid)
                }
            }
        }

        let isoFormatterFractional = ISO8601DateFormatter()
        isoFormatterFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]

        var results: [FleetJobItem] = []

        for dir in entries {
            let wsFile = dir.appendingPathComponent("workspace.yaml")
            guard let content = try? String(contentsOf: wsFile, encoding: .utf8) else { continue }

            let sid = dir.lastPathComponent
            var cwd = home.path
            var name = sid
            var createdAtStr: String?
            var updatedAtStr: String?
            var repoName: String?
            var branchName: String?

            for line in content.components(separatedBy: .newlines) {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.starts(with: "cwd:") {
                    cwd = String(trimmed.dropFirst(4)).trimmingCharacters(in: .whitespaces)
                } else if trimmed.starts(with: "name:") {
                    name = String(trimmed.dropFirst(5)).trimmingCharacters(in: CharacterSet.whitespaces.union(CharacterSet(charactersIn: "'\"")))
                } else if trimmed.starts(with: "created_at:") {
                    createdAtStr = String(trimmed.dropFirst(11)).trimmingCharacters(in: .whitespaces)
                } else if trimmed.starts(with: "updated_at:") {
                    updatedAtStr = String(trimmed.dropFirst(11)).trimmingCharacters(in: .whitespaces)
                } else if trimmed.starts(with: "repository:") {
                    repoName = String(trimmed.dropFirst(11)).trimmingCharacters(in: .whitespaces)
                } else if trimmed.starts(with: "branch:") {
                    branchName = String(trimmed.dropFirst(7)).trimmingCharacters(in: .whitespaces)
                }
            }

            let isRunning = workingSet.contains(sid)
            let state = isRunning ? "running" : "done"
            let updatedDate = updatedAtStr.flatMap { isoFormatterFractional.date(from: $0) ?? isoFormatter.date(from: $0) }
            let createdDate = createdAtStr.flatMap { isoFormatterFractional.date(from: $0) ?? isoFormatter.date(from: $0) }

            var display = name
            if display == sid, let r = repoName {
                display = branchName != nil ? "\(r) (\(branchName!))" : r
            }

            var artifacts: [JobResultArtifact] = []
            detectRepoArtifacts(repoPath: cwd, into: &artifacts)

            let item = FleetJobItem(
                id: sid,
                name: display,
                prompt: display,
                repoPath: cwd,
                agentKind: .copilot,
                isEnabled: isRunning,
                state: state,
                intervalMinutes: nil,
                lastRunStatus: state,
                lastRunAt: updatedDate ?? createdDate,
                nextRunAt: nil,
                createdAt: createdDate,
                updatedAt: updatedDate,
                isAutomation: false,
                outputSummary: branchName != nil ? "Branch: \(branchName!)" : nil,
                detailText: repoName != nil ? "Repository: \(repoName!)" : nil,
                artifacts: artifacts
            )
            results.append(item)
        }

        return results
    }

    func runNow(id: String) async {
        if let uuid = UUID(uuidString: id) {
            let res = await SessionCoordinator.shared.requestDaemon(.automationRunNow(id: uuid))
            if case let .error(err) = res {
                self.errorMessage = err
            } else {
                await load()
            }
        }
    }

    func toggleEnabled(id: String, enabled: Bool) async {
        if let uuid = UUID(uuidString: id) {
            let res = await SessionCoordinator.shared.requestDaemon(.automationSetEnabled(id: uuid, enabled: enabled))
            if case let .error(err) = res {
                self.errorMessage = err
            } else {
                await load()
            }
        }
    }

    func delete(id: String, isAutomation: Bool) async {
        if isAutomation, let uuid = UUID(uuidString: id) {
            let res = await SessionCoordinator.shared.requestDaemon(.automationDelete(id: uuid))
            if case let .error(err) = res {
                self.errorMessage = err
            } else {
                await load()
            }
        } else {
            let home = FileManager.default.homeDirectoryForCurrentUser
            let claudeDir = home.appendingPathComponent(".claude/jobs").appendingPathComponent(id)
            if FileManager.default.fileExists(atPath: claudeDir.path) {
                try? FileManager.default.removeItem(at: claudeDir)
            }
            let copilotDir = home.appendingPathComponent(".copilot/session-state").appendingPathComponent(id)
            if FileManager.default.fileExists(atPath: copilotDir.path) {
                try? FileManager.default.removeItem(at: copilotDir)
            }
            await load()
        }
    }

    func openJobSession(item: FleetJobItem) {
        let coordinator = SessionCoordinator.shared
        guard let wsID = coordinator.snapshot.activeWorkspaceID else { return }
        coordinator.addSession(to: wsID, cwd: item.repoPath, name: item.name)
    }
}
