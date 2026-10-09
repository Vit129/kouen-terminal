import Foundation
import KouenCore
import XCTest

/// Search benchmarks for Agent History Search and File Tree Search.
/// Gated behind KOUEN_BENCHMARKS=1 so standard test runs stay fast and deterministic.
/// Run with:
///
///     KOUEN_BENCHMARKS=1 swift test --filter SearchBenchmarks
///
final class SearchBenchmarks: XCTestCase {

    private func skipUnlessEnabled() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["KOUEN_BENCHMARKS"] == "1",
            "Set KOUEN_BENCHMARKS=1 to run performance benchmarks."
        )
    }

    private func timedNanos(_ body: () -> Void) -> UInt64 {
        let start = DispatchTime.now().uptimeNanoseconds
        body()
        return DispatchTime.now().uptimeNanoseconds &- start
    }

    private func printBenchmark(_ name: String, nanos: UInt64, fields: [(String, String)] = []) {
        let extras = fields.map { ",\"\($0.0)\":\($0.1)" }.joined()
        print("{\"benchmark\":\"\(name)\",\"nanos\":\(nanos)\(extras)}")
    }

    // MARK: - 1. History Keystroke Search (English & Thai)

    func testBenchmarkHistoryKeystrokeSearch() throws {
        try skipUnlessEnabled()

        let (index, dbURL, records) = try makeSyntheticHistoryFixture(count: 1000)
        defer { try? FileManager.default.removeItem(at: dbURL) }

        // 1.1 English Keystrokes
        let englishKeystrokes = ["p", "pe", "per", "perf", "perfo", "perform", "sw", "swift", "audio", "terminal"]
        // Warm up
        _ = AgentHistorySearch.rank(query: "perf", records: records, index: index)

        let englishNanos = timedNanos {
            for key in englishKeystrokes {
                _ = AgentHistorySearch.rank(query: key, records: records, index: index)
            }
        }
        let avgEnglishMs = Double(englishNanos) / Double(englishKeystrokes.count) / 1_000_000.0
        printBenchmark(
            "history_keystroke_search_english_1k",
            nanos: englishNanos,
            fields: [
                ("keystrokes_count", "\(englishKeystrokes.count)"),
                ("avg_ms_per_keystroke", String(format: "%.3f", avgEnglishMs))
            ]
        )

        // 1.2 Thai Keystrokes
        let thaiKeystrokes = ["ท", "ทด", "ทดส", "ทดสอบ", "ภาษ", "ภาษา", "ภาษาไทย", "ระบบ"]
        // Warm up
        _ = AgentHistorySearch.rank(query: "ทดสอบ", records: records, index: index)

        let thaiNanos = timedNanos {
            for key in thaiKeystrokes {
                _ = AgentHistorySearch.rank(query: key, records: records, index: index)
            }
        }
        let avgThaiMs = Double(thaiNanos) / Double(thaiKeystrokes.count) / 1_000_000.0
        printBenchmark(
            "history_keystroke_search_thai_1k",
            nanos: thaiNanos,
            fields: [
                ("keystrokes_count", "\(thaiKeystrokes.count)"),
                ("avg_ms_per_keystroke", String(format: "%.3f", avgThaiMs))
            ]
        )
    }

    // MARK: - 2. History Tab Open / Initial Load

    func testBenchmarkHistoryTabInitialLoad() throws {
        try skipUnlessEnabled()

        let (index, dbURL, records) = try makeSyntheticHistoryFixture(count: 1000)
        defer { try? FileManager.default.removeItem(at: dbURL) }

        let loadNanos = timedNanos {
            // Simulate initial load: load entries from SQLite and rank empty query
            let loaded = index.loadCachedEntries()
            _ = loaded.count
        }
        let loadMs = Double(loadNanos) / 1_000_000.0
        printBenchmark(
            "history_tab_open_initial_load_1k",
            nanos: loadNanos,
            fields: [
                ("records_count", "\(records.count)"),
                ("load_ms", String(format: "%.3f", loadMs))
            ]
        )
    }

    // MARK: - 3. File Tree Search (10,000 Files)

    func testBenchmarkFileTreeSearch10kFiles() throws {
        try skipUnlessEnabled()

        let paths = makeSyntheticFilePaths(count: 10_000)
        let queries = ["main", "manager", "test", "view_controller", "component", "service"]

        let totalNanos = timedNanos {
            for query in queries {
                let matcher = SearchMatcher(query: query)
                var matches = 0
                for path in paths {
                    if matcher.matchCategory(name: path) != nil {
                        matches += 1
                    }
                }
                _ = matches
            }
        }
        let avgQueryMs = Double(totalNanos) / Double(queries.count) / 1_000_000.0
        printBenchmark(
            "file_tree_search_10k_files",
            nanos: totalNanos,
            fields: [
                ("files_count", "\(paths.count)"),
                ("queries_count", "\(queries.count)"),
                ("avg_ms_per_query", String(format: "%.3f", avgQueryMs))
            ]
        )
    }

    // MARK: - Synthetic Fixture Generators

    private func makeSyntheticHistoryFixture(count: Int) throws -> (AgentHistoryFTSIndex, URL, [AgentSessionRecord]) {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("kouen-bench-fts-\(UUID().uuidString).sqlite")
        let index = AgentHistoryFTSIndex(dbPath: tempURL.path)

        var records: [AgentSessionRecord] = []
        records.reserveCapacity(count)

        let englishTopics = [
            "fix memory leak in audio engine",
            "optimize swift compiler performance",
            "implement worktree isolation in daemon",
            "refactor terminal renderer metal shaders",
            "handle git status process deadlock on pipe buffer",
            "improve sidebar project directory tree layout"
        ]

        let thaiTopics = [
            "ทดสอบระบบการค้นหาประวัติการทำงาน",
            "แก้ไขข้อผิดพลาดภาษาไทยในการประมวลผลข้อความ",
            "ปรับปรุงความเร็วการโหลดหน้าต่างหลัก",
            "เชื่อมต่อระบบฐานข้อมูลความจำอัตโนมัติ"
        ]

        let agents: [AgentKind] = [.claudeCode, .codex, .copilot, .antigravity]

        for i in 0..<count {
            let isThai = (i % 5 == 0)
            let baseTitle = isThai ? thaiTopics[i % thaiTopics.count] : englishTopics[i % englishTopics.count]
            let title = "\(baseTitle) #\(i)"
            let branch = "feat/benchmark-branch-\(i)"
            let project = "repo-\(i % 20)"
            let agent = agents[i % agents.count]

            let record = AgentSessionRecord(
                id: "bench-sess-\(i)",
                agentKind: agent,
                title: title,
                projectPath: "/Users/tester/Projects/\(project)",
                projectName: project,
                gitBranch: branch,
                messageCount: 5,
                updatedAt: Date().addingTimeInterval(Double(-i * 60)),
                firstPrompt: isThai ? "กรุณาตรวจสอบและดำเนินการตามคำสั่ง \(i)" : "Please check and run test suite for iteration \(i)",
                latestTurns: [
                    AgentHistoryTurn(role: "user", content: "Initial prompt for task \(i)"),
                    AgentHistoryTurn(role: "assistant", content: "Implemented solution in file\(i).swift")
                ],
                transcriptPath: "/tmp/bench-\(i).jsonl",
                worktreeAvailable: false
            )
            records.append(record)

            index.saveRecord(record, mtime: Date(), fileSize: 1024)
        }

        return (index, tempURL, records)
    }

    private func makeSyntheticFilePaths(count: Int) -> [String] {
        var paths: [String] = []
        paths.reserveCapacity(count)

        let modules = ["Core", "Daemon", "Terminal", "UI", "Renderer", "Settings", "Commands", "LSP"]
        let subdirs = ["Views", "Models", "Services", "Controllers", "Utils", "Protocols", "Extensions"]
        let suffixes = ["View.swift", "Model.swift", "Service.swift", "Controller.swift", "Helper.swift", "Tests.swift"]

        for i in 0..<count {
            let mod = modules[i % modules.count]
            let sub = subdirs[(i / modules.count) % subdirs.count]
            let suf = suffixes[(i / (modules.count * subdirs.count)) % suffixes.count]
            paths.append("Sources/\(mod)/\(sub)/Feature\(i)\(suf)")
        }

        return paths
    }
}
