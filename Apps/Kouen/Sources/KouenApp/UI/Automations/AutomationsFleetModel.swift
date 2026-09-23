import Foundation
import Observation
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

/// Where a `FleetJobItem` actually comes from — determines which actions (Run Now,
/// Toggle, Delete) are valid, since a Kouen-daemon automation and a macOS LaunchAgent
/// are controlled through entirely different mechanisms (IPC vs. `launchctl`).
public enum AutomationSource: Sendable, Equatable {
    case daemon
    case launchAgent(label: String, plistPath: String)
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
    public let source: AutomationSource

    // Result information
    public let outputSummary: String?
    public let detailText: String?
    public let artifacts: [JobResultArtifact]

    public var isActive: Bool {
        isEnabled
    }

    /// For a LaunchAgent job, the `.sh` script the command invokes (used to re-detect the
    /// script's freshly written output artifacts on re-run). `nil` for daemon jobs or when
    /// the command has no `.sh` element. Mirrors the extraction in `fetchLaunchAgents`.
    public var launchAgentScriptPath: String? {
        guard case .launchAgent = source else { return nil }
        return prompt.split(separator: " ").first(where: { $0.hasSuffix(".sh") }).map(String.init)
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

    /// IDs of jobs currently mid-run via `runNow` (esp. LaunchAgents, whose `kickstart` is
    /// async so their persisted `state` doesn't flip to "running" on its own). Drives the
    /// spinner in the row while we wait for the script to produce fresh output.
    var runningJobIDs: Set<String> = []

    /// When true, a scheduled run detected during `load()` (i.e. the job produced a fresher
    /// artifact than last seen) auto-opens its result, matching the Run-Now behavior. The
    /// user's "run now + schedule run — auto-show result" ask. Toggleable so the auto-open
    /// can't become a nuisance if the user doesn't want scheduled reports popping open.
    var autoOpenScheduledResults: Bool = true

    /// Highest artifact mtime we've *already accounted for* per job id. Seeded on the first
    /// `load()` (so results generated before Kouen launched never auto-open — only genuinely
    /// new scheduled runs do), then advanced whenever we surface or open a fresher artifact.
    /// This is the guard that makes scheduled auto-open fire exactly once per run.
    private var lastSeenArtifactMtime: [String: Date] = [:]

    /// False until the first `load()` completes. The first load only seeds the mtime
    /// baseline; it never auto-opens (opening the last scheduled report every time the
    /// panel first appears would be the nuisance case).
    private var didSeedArtifactBaseline: Bool = false

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
            let matcher = SearchMatcher(query: filterText)
            items = items.filter { item in
                matcher.match(
                    name: "\(item.name) \(item.agentKind.displayName)",
                    relativePath: item.repoPath,
                    content: item.prompt
                ) != nil
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
        await load(detectScheduledRuns: true)
    }

    /// Loads jobs. When `detectScheduledRuns` is true and the baseline has been seeded, any
    /// job whose newest artifact is fresher than last seen is returned as a "just completed"
    /// result to auto-open (scheduled-run auto-show). The caller opens them.
    @discardableResult
    func load(detectScheduledRuns: Bool) async -> [JobResultArtifact] {
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
                    source: .daemon,
                    outputSummary: nil,
                    detailText: a.lastRunStatus != nil ? "Last execution status: \(a.lastRunStatus!)" : nil,
                    artifacts: artifacts
                )
                fetchedJobs.append(item)
            }
        }

        // 2. Real recurring scheduled work outside Kouen's own store — this user's
        // launchd-based cron jobs (morning stock report, .copilot report scripts, etc).
        // Deliberately NOT chat/session history — see fetchLaunchAgents() for the filter.
        let launchAgentJobs = await Task.detached(priority: .userInitiated) {
            Self.fetchLaunchAgents()
        }.value
        fetchedJobs.append(contentsOf: launchAgentJobs)

        // Sort by most recently updated
        self.jobs = fetchedJobs.sorted(by: { ($0.updatedAt ?? $0.createdAt ?? .distantPast) > ($1.updatedAt ?? $1.createdAt ?? .distantPast) })
        self.isLoading = false

        // Scheduled-run auto-show: compare each job's newest artifact mtime against what we
        // last accounted for. Fresher ⇒ that job ran since we last looked ⇒ surface its
        // primary artifact to open. The FIRST load only seeds the baseline (no auto-open of
        // pre-launch results).
        var freshlyCompleted: [JobResultArtifact] = []
        for job in self.jobs {
            guard let primary = job.artifacts.first else { continue }
            let newest = Self.newestMtime(of: job.artifacts.map(\.path))
            guard let newest else { continue }

            let previouslySeen = lastSeenArtifactMtime[job.id]
            let isFresher = previouslySeen == nil || newest > previouslySeen!
            // Always advance the high-water mark so we never re-open the same run.
            lastSeenArtifactMtime[job.id] = newest

            if detectScheduledRuns,
               didSeedArtifactBaseline,
               autoOpenScheduledResults,
               isFresher,
               // A job the user is actively Run-Now-ing opens through runNow's own return
               // value — don't double-open it here.
               !runningJobIDs.contains(job.id) {
                freshlyCompleted.append(primary)
            }
        }
        didSeedArtifactBaseline = true
        return freshlyCompleted
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

    // MARK: - macOS LaunchAgents (real recurring cron jobs — never chat/session history)

    /// Vendor/system LaunchAgents that are never something the user set up as "an automation" —
    /// filtered out by Label prefix so this stays a list of the user's own scheduled jobs.
    nonisolated private static let launchAgentExcludedPrefixes = [
        "com.google.", "com.amazon.", "com.apple.", "homebrew.", "com.vit129.kouen."
    ]

    nonisolated private static func fetchLaunchAgents() -> [FleetJobItem] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent("Library/LaunchAgents")
        guard let entries = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else {
            return []
        }

        var results: [FleetJobItem] = []
        for url in entries where url.pathExtension == "plist" {
            guard let data = try? Data(contentsOf: url),
                  let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
                  let label = plist["Label"] as? String else { continue }
            if launchAgentExcludedPrefixes.contains(where: { label.hasPrefix($0) }) { continue }

            let programArgs = (plist["ProgramArguments"] as? [String]) ?? []
            let commandString = programArgs.joined(separator: " ")

            // `... >> /path/to/log 2>&1` — the convention every one of this user's own
            // LaunchAgents uses for its output.
            var logPath: String? = nil
            if let range = commandString.range(of: ">> ") {
                logPath = commandString[range.upperBound...].split(separator: " ").first.map(String.init)
            }

            // The script path is usually not its own ProgramArguments element — every one of
            // this user's LaunchAgents invokes `/bin/bash -c "<script>.sh >> <log> 2>&1"` as
            // ONE compound string, so `programArgs.first(hasSuffix: ".sh")` never matches
            // (that whole element ends in "2>&1", not ".sh") — split on whitespace instead.
            let scriptPath = commandString.split(separator: " ").first(where: { $0.hasSuffix(".sh") }).map(String.init)
            let repoPath = Self.resolveProjectRoot(from: scriptPath)

            var kind: AgentKind
            if label.hasPrefix("com.claude.") { kind = .claudeCode }
            else if label.hasPrefix("com.copilot.") { kind = .copilot }
            else if label.hasPrefix("com.kiro.") { kind = .kiro }
            else if label.hasPrefix("com.codex.") { kind = .codex }
            else if label.hasPrefix("com.antigravity.") || label.hasPrefix("com.gemini.") { kind = .antigravity }
            else { kind = .generic }

            // A label with no provider baked in (e.g. "com.line-bot.*") can't be
            // classified by prefix — fall back to the job's own `.env` LLM_PROVIDER,
            // so switching providers there (agy <-> claude) updates the icon without
            // ever renaming the LaunchAgent again.
            if kind == .generic, let provider = Self.readEnvProvider(repoPath: repoPath) {
                kind = AgentTitleInference.kind(from: provider) ?? kind
            }

            let isLoaded = Self.isLaunchAgentLoaded(label: label)

            var lastRunAt: Date? = nil
            var outputSummary: String? = nil
            if let logPath {
                if let attrs = try? FileManager.default.attributesOfItem(atPath: logPath) {
                    lastRunAt = attrs[.modificationDate] as? Date
                }
                if FileManager.default.fileExists(atPath: logPath) {
                    outputSummary = Self.tailLog(path: logPath, lines: 6)
                }
            }
            // Artifacts are the script's *generated output files* — never the log itself,
            // that's what the separate Log control already shows via outputSummary above.
            var artifacts: [JobResultArtifact] = []
            if let scriptPath {
                Self.detectScriptOutputArtifacts(scriptPath: scriptPath, into: &artifacts)
            }
            detectRepoArtifacts(repoPath: repoPath, into: &artifacts)

            let item = FleetJobItem(
                id: label,
                name: Self.humanizeLaunchAgentLabel(label),
                prompt: commandString,
                repoPath: repoPath,
                agentKind: kind,
                isEnabled: isLoaded,
                state: isLoaded ? "scheduled" : "disabled",
                intervalMinutes: nil,
                lastRunStatus: nil,
                lastRunAt: lastRunAt,
                nextRunAt: nil,
                createdAt: nil,
                updatedAt: lastRunAt,
                source: .launchAgent(label: label, plistPath: url.path),
                outputSummary: outputSummary,
                detailText: Self.describeSchedule(plist: plist),
                artifacts: artifacts
            )
            results.append(item)
        }
        return results
    }

    nonisolated private static func humanizeLaunchAgentLabel(_ label: String) -> String {
        // "com.claude.stock-report" -> "Stock Report"
        let last = label.split(separator: ".").last.map(String.init) ?? label
        return last.split(separator: "-").map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined(separator: " ")
    }

    /// Finds this script's own generated report(s) rather than guessing at a fixed relative
    /// path — every one of this user's report scripts writes into its own `output/`
    /// subdirectory, one run folder per sprint (e.g. `output/2026SP19/`), each containing
    /// both a combined `all-team.html` summary and several per-team breakdown files with
    /// the *same* mtime (batch-generated together — "newest single file" can't tell them
    /// apart). So: pick the most recently modified run folder, list every `.html` in it,
    /// and rank an "all-team" summary first.
    nonisolated private static func detectScriptOutputArtifacts(scriptPath: String, into artifacts: inout [JobResultArtifact]) {
        let scriptDir = (scriptPath as NSString).deletingLastPathComponent
        let outputDir = (scriptDir as NSString).appendingPathComponent("output")
        let fm = FileManager.default

        guard let entries = try? fm.contentsOfDirectory(atPath: outputDir) else { return }
        var latestRunDir: (path: String, date: Date)?
        for entry in entries {
            let full = (outputDir as NSString).appendingPathComponent(entry)
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: full, isDirectory: &isDir), isDir.boolValue,
                  let attrs = try? fm.attributesOfItem(atPath: full),
                  let date = attrs[.modificationDate] as? Date else { continue }
            if latestRunDir == nil || date > latestRunDir!.date { latestRunDir = (full, date) }
        }
        guard let runDir = latestRunDir?.path else { return }

        var htmlFiles = Self.allFiles(under: runDir, extension: "html", maxDepth: 4)
        guard !htmlFiles.isEmpty else { return }
        htmlFiles.sort { a, b in
            let aIsSummary = a.lowercased().contains("all-team")
            let bIsSummary = b.lowercased().contains("all-team")
            if aIsSummary != bIsSummary { return aIsSummary }
            return a < b
        }
        for path in htmlFiles.prefix(12) where !artifacts.contains(where: { $0.path == path }) {
            artifacts.append(JobResultArtifact(id: path, name: (path as NSString).lastPathComponent, path: path, kind: .html))
        }
    }

    nonisolated private static func allFiles(under dir: String, extension ext: String, maxDepth: Int) -> [String] {
        guard maxDepth > 0 else { return [] }
        let fm = FileManager.default
        guard let entries = try? fm.contentsOfDirectory(atPath: dir) else { return [] }
        var result: [String] = []
        for entry in entries {
            let full = (dir as NSString).appendingPathComponent(entry)
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: full, isDirectory: &isDir) else { continue }
            if isDir.boolValue {
                result.append(contentsOf: Self.allFiles(under: full, extension: ext, maxDepth: maxDepth - 1))
            } else if full.hasSuffix(".\(ext)") {
                result.append(full)
            }
        }
        return result
    }

    /// Walks upward from `scriptPath`'s containing directory looking for `.git`. With no
    /// script path (LaunchAgent command has no `.sh` element to anchor on), search starts
    /// AT the home directory itself — not its parent, which `.deletingLastPathComponent`
    /// would produce if applied to `home.path` the same way it's applied to a real file path.
    nonisolated static func resolveProjectRoot(from scriptPath: String?) -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let start: String
        if let scriptPath, (scriptPath as NSString).isAbsolutePath {
            start = (scriptPath as NSString).deletingLastPathComponent
        } else {
            start = home
        }
        let fm = FileManager.default
        var candidate = start
        while candidate.count > 1 {
            if fm.fileExists(atPath: (candidate as NSString).appendingPathComponent(".git")) {
                return candidate
            }
            let parent = (candidate as NSString).deletingLastPathComponent
            if parent == candidate { break }
            candidate = parent
        }
        return start
    }

    /// Reads `LLM_PROVIDER=` out of `<repoPath>/.env`, for LaunchAgent labels that don't
    /// carry a provider prefix (see the `.generic` fallback in fetchLaunchAgents above).
    nonisolated private static func readEnvProvider(repoPath: String) -> String? {
        let envPath = (repoPath as NSString).appendingPathComponent(".env")
        guard let contents = try? String(contentsOfFile: envPath, encoding: .utf8) else { return nil }
        for line in contents.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("LLM_PROVIDER=") else { continue }
            let value = trimmed.dropFirst("LLM_PROVIDER=".count).trimmingCharacters(in: .whitespaces)
            return value.isEmpty ? nil : value
        }
        return nil
    }

    nonisolated private static func describeSchedule(plist: [String: Any]) -> String {
        if let interval = plist["StartInterval"] as? Int {
            let minutes = interval / 60
            return minutes > 0 ? "Every \(minutes)m" : "Every \(interval)s"
        }
        let dayNames = ["", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        func timeString(_ entry: [String: Any]) -> String {
            let hour = entry["Hour"] as? Int ?? 0
            let minute = entry["Minute"] as? Int ?? 0
            let day = (entry["Weekday"] as? Int).flatMap { $0 >= 0 && $0 <= 7 ? dayNames[$0] : nil }
            let time = String(format: "%02d:%02d", hour, minute)
            return day.map { "\($0) \(time)" } ?? time
        }
        if let entries = plist["StartCalendarInterval"] as? [[String: Any]] {
            let times = entries.map(timeString)
            // Collapse "Mon 09:00, Tue 09:00, ... Fri 09:00" to "Weekdays 09:00"
            if entries.count == 5, entries.allSatisfy({ ($0["Hour"] as? Int) == (entries[0]["Hour"] as? Int) && ($0["Minute"] as? Int) == (entries[0]["Minute"] as? Int) }),
               Set(entries.compactMap { $0["Weekday"] as? Int }) == Set(1...5) {
                return "Weekdays \(String(format: "%02d:%02d", entries[0]["Hour"] as? Int ?? 0, entries[0]["Minute"] as? Int ?? 0))"
            }
            return times.joined(separator: ", ")
        }
        if let entry = plist["StartCalendarInterval"] as? [String: Any] {
            return "Daily \(timeString(entry))"
        }
        return "Scheduled"
    }

    nonisolated private static func isLaunchAgentLoaded(label: String) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["print", "gui/\(getuid())/\(label)"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    nonisolated private static func tailLog(path: String, lines: Int) -> String? {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else { return nil }
        let allLines = content.split(separator: "\n", omittingEmptySubsequences: true)
        let tail = allLines.suffix(lines)
        return tail.isEmpty ? nil : tail.joined(separator: "\n")
    }

    /// Runs the job now and returns the result artifact that should be auto-shown once the
    /// run has actually produced fresh output, or `nil` if the run failed / produced nothing
    /// to open. The caller (view) opens it — the model stays UI-framework-free.
    ///
    /// Timing note: a daemon automation runs synchronously behind the IPC call, so its
    /// artifacts are fresh the moment it returns. A LaunchAgent `kickstart` only *starts*
    /// the script and returns immediately, so the artifact on disk is still last run's until
    /// the script rewrites it — we snapshot the primary artifact's mtime up front and wait
    /// for it to advance (bounded) before reporting it as the thing to open.
    @discardableResult
    func runNow(_ item: FleetJobItem) async -> JobResultArtifact? {
        runningJobIDs.insert(item.id)
        defer { runningJobIDs.remove(item.id) }

        switch item.source {
        case .daemon:
            guard let uuid = UUID(uuidString: item.id) else { return nil }
            let res = await SessionCoordinator.shared.requestDaemon(.automationRunNow(id: uuid))
            if case let .error(err) = res {
                self.errorMessage = err
                return nil
            }
            await load(detectScheduledRuns: false)
            return jobs.first(where: { $0.id == item.id })?.artifacts.first

        case .launchAgent(let label, _):
            // Baseline: newest mtime among the job's current (pre-run) artifacts.
            let priorArtifactPaths = item.artifacts.map(\.path)
            let baselineMtime = Self.newestMtime(of: priorArtifactPaths)

            await Task.detached { Self.runLaunchctl(["kickstart", "-k", "gui/\(getuid())/\(label)"]) }.value

            // Wait (off-main) for the script to rewrite one of its artifacts, i.e. the
            // newest artifact mtime advances past the baseline. Bounded so a slow/failing
            // script never hangs the UI — after the ceiling we just refresh without opening.
            let becameFresh = await Task.detached(priority: .userInitiated) { () -> Bool in
                let deadline = Date().addingTimeInterval(Self.runArtifactWaitSeconds)
                while Date() < deadline {
                    // Re-detect: a brand-new sprint run folder means brand-new artifact paths,
                    // so re-run detection each poll rather than only re-stat the old paths.
                    var fresh: [JobResultArtifact] = []
                    if let scriptPath = item.launchAgentScriptPath {
                        Self.detectScriptOutputArtifacts(scriptPath: scriptPath, into: &fresh)
                    }
                    Self.detectRepoArtifacts(repoPath: item.repoPath, into: &fresh)
                    let currentMtime = Self.newestMtime(of: fresh.map(\.path))
                    if let currentMtime, baselineMtime == nil || currentMtime > baselineMtime! {
                        return true
                    }
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // poll every 1s
                }
                return false
            }.value

            await load(detectScheduledRuns: false)
            guard becameFresh else { return nil }
            return jobs.first(where: { $0.id == item.id })?.artifacts.first
        }
    }

    /// Upper bound on how long `runNow` waits for a LaunchAgent script to rewrite its
    /// output before giving up on auto-opening (the manual HTML button still works after).
    nonisolated static let runArtifactWaitSeconds: TimeInterval = 120

    /// Newest modification date across the given file paths, or `nil` if none exist.
    nonisolated private static func newestMtime(of paths: [String]) -> Date? {
        let fm = FileManager.default
        var newest: Date?
        for p in paths {
            guard let attrs = try? fm.attributesOfItem(atPath: p),
                  let date = attrs[.modificationDate] as? Date else { continue }
            if newest == nil || date > newest! { newest = date }
        }
        return newest
    }

    func toggleEnabled(_ item: FleetJobItem) async {
        switch item.source {
        case .daemon:
            guard let uuid = UUID(uuidString: item.id) else { return }
            let res = await SessionCoordinator.shared.requestDaemon(.automationSetEnabled(id: uuid, enabled: !item.isEnabled))
            if case let .error(err) = res {
                self.errorMessage = err
            } else {
                await load()
            }
        case .launchAgent(let label, let plistPath):
            let isEnabled = item.isEnabled
            await Task.detached {
                if isEnabled {
                    Self.runLaunchctl(["bootout", "gui/\(getuid())/\(label)"])
                } else {
                    Self.runLaunchctl(["bootstrap", "gui/\(getuid())", plistPath])
                }
            }.value
            await load()
        }
    }

    nonisolated private static func runLaunchctl(_ arguments: [String]) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try? process.run()
        process.waitUntilExit()
    }

    func delete(_ item: FleetJobItem) async {
        // Only a daemon-owned automation is Kouen's to delete outright. A LaunchAgent is
        // the user's own scheduled job managed outside Kouen — Toggle (disable) is the
        // right control for it, not permanent deletion of a plist Kouen didn't create.
        guard case .daemon = item.source, let uuid = UUID(uuidString: item.id) else { return }
        let res = await SessionCoordinator.shared.requestDaemon(.automationDelete(id: uuid))
        if case let .error(err) = res {
            self.errorMessage = err
        } else {
            await load()
        }
    }
}
