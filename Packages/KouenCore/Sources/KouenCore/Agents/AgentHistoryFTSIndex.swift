import Foundation
import KouenIPC
import os
#if canImport(SQLite3)
import SQLite3
#endif

/// Extracted transcript content for full-text indexing.
public struct ExtractedTranscriptContent: Sendable, Equatable {
    public let fullTranscript: String
    public let filesEdited: String
    public let toolsCalled: String

    public init(fullTranscript: String = "", filesEdited: String = "", toolsCalled: String = "") {
        self.fullTranscript = fullTranscript
        self.filesEdited = filesEdited
        self.toolsCalled = toolsCalled
    }
}

/// A search hit from the SQLite FTS5 index.
/// Note: Typo tolerance is evaluated on light fields by SearchMatcher; the FTS index
/// performs fast token-prefix full-text searching over transcripts without loading them into memory.
public struct AgentHistoryFTSMatch: Sendable, Equatable {
    public let sessionID: String
    public let snippet: String
    public let rank: Double
    public let filesEdited: String
    public let toolsCalled: String

    public init(
        sessionID: String,
        snippet: String = "",
        rank: Double = 0.0,
        filesEdited: String = "",
        toolsCalled: String = ""
    ) {
        self.sessionID = sessionID
        self.snippet = snippet
        self.rank = rank
        self.filesEdited = filesEdited
        self.toolsCalled = toolsCalled
    }
}

/// A cached session record entry retrieved from the SQLite index.
public struct CachedSessionEntry: Sendable {
    public let record: AgentSessionRecord
    public let mtime: Date
    public let fileSize: Int
    public let transcriptPath: String

    public init(record: AgentSessionRecord, mtime: Date, fileSize: Int, transcriptPath: String? = nil) {
        self.record = record
        self.mtime = mtime
        self.fileSize = fileSize
        self.transcriptPath = transcriptPath ?? record.transcriptPath
    }
}

/// SQLite FTS5 full-text search index for agent sessions.
/// Manages indexing session metadata, transcripts, edited files, and tool names.
public final class AgentHistoryFTSIndex: @unchecked Sendable {
    public static let shared = AgentHistoryFTSIndex()
    private static let logger = Logger(subsystem: "com.vit129.kouen", category: "history")

    public static let schemaVersion: Int32 = 2

    private let dbPath: String
    #if canImport(SQLite3)
    private var db: OpaquePointer?
    #endif
    private let lock = NSLock()

    public init(dbPath: String = KouenPaths.applicationSupport.appendingPathComponent("agent_history_fts.sqlite").path) {
        self.dbPath = dbPath
        #if canImport(SQLite3)
        openDatabase()
        #endif
    }

    deinit {
        #if canImport(SQLite3)
        lock.lock()
        if let db {
            sqlite3_close(db)
        }
        lock.unlock()
        #endif
    }

    #if canImport(SQLite3)
    private func logStepFailure(_ stepResult: Int32, context: String) {
        let errMsg = db.flatMap { sqlite3_errmsg($0) }.map { String(cString: $0) } ?? "unknown error"
        Self.logger.error("[AgentHistoryFTSIndex] \(context) failed with code \(stepResult): \(errMsg)")
    }

    /// Runs a statement, logging (not ignoring) any failure. Returns false on failure.
    @discardableResult
    private func exec(_ sql: String, context: String) -> Bool {
        let rc = sqlite3_exec(db, sql, nil, nil, nil)
        if rc != SQLITE_OK { logStepFailure(rc, context: context) }
        return rc == SQLITE_OK
    }

    /// Wraps `body` in a transaction; rolls back if COMMIT fails. Caller holds `lock`.
    private func inTransaction(_ context: String, _ body: () -> Void) {
        guard exec("BEGIN TRANSACTION;", context: "\(context) BEGIN") else { return }
        body()
        if !exec("COMMIT;", context: "\(context) COMMIT") {
            exec("ROLLBACK;", context: "\(context) ROLLBACK")
        }
    }

    /// Deletes `id`'s rows from each of `tables` (all keyed by session_id). Caller holds `lock`.
    private func deleteRows(_ ids: some Sequence<String>, from tables: [String], context: String) {
        for table in tables {
            var stmt: OpaquePointer?
            guard sqlite3_prepare_v2(db, "DELETE FROM \(table) WHERE session_id = ?;", -1, &stmt, nil) == SQLITE_OK else {
                logStepFailure(SQLITE_ERROR, context: "prepare \(context) \(table)")
                continue
            }
            for id in ids {
                sqlite3_reset(stmt)
                sqlite3_bind_text(stmt, 1, id, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                let rc = sqlite3_step(stmt)
                if rc != SQLITE_DONE { logStepFailure(rc, context: "\(context) \(table)") }
            }
            sqlite3_finalize(stmt)
        }
    }

    private static let sessionTables = ["session_records", "session_fts", "session_index_meta"]

    private func openDatabase() {
        lock.lock()
        defer { lock.unlock() }

        if dbPath != ":memory:" {
            try? KouenPaths.ensureDirectories()
        }

        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            logStepFailure(SQLITE_CANTOPEN, context: "open \(dbPath)")
            sqlite3_close(db)  // sqlite3_open allocates a handle even on failure
            db = nil
            return
        }

        // Schema version check and migration
        var versionStmt: OpaquePointer?
        var currentVersion: Int32 = 0
        if sqlite3_prepare_v2(db, "PRAGMA user_version;", -1, &versionStmt, nil) == SQLITE_OK {
            if sqlite3_step(versionStmt) == SQLITE_ROW {
                currentVersion = sqlite3_column_int(versionStmt, 0)
            }
            sqlite3_finalize(versionStmt)
        }

        if currentVersion != Self.schemaVersion {
            // Drop every table on version mismatch. Keeping session_index_meta would make
            // needsReindex() skip unchanged transcripts, so they'd vanish from the dropped records.
            exec("DROP TABLE IF EXISTS session_records;", context: "migrate")
            exec("DROP INDEX IF EXISTS idx_session_records_updated_at;", context: "migrate")
            exec("DROP TABLE IF EXISTS session_fts;", context: "migrate")
            exec("DROP TABLE IF EXISTS session_index_meta;", context: "migrate")
            exec("PRAGMA user_version = \(Self.schemaVersion);", context: "migrate")
        }

        let createMetaSQL = """
        CREATE TABLE IF NOT EXISTS session_index_meta (
            session_id TEXT PRIMARY KEY,
            transcript_path TEXT,
            mtime REAL,
            file_size INTEGER
        );
        """
        exec(createMetaSQL, context: "create session_index_meta")

        let createRecordsSQL = """
        CREATE TABLE IF NOT EXISTS session_records (
            session_id TEXT PRIMARY KEY,
            agent_kind TEXT NOT NULL,
            title TEXT NOT NULL,
            project_path TEXT NOT NULL,
            project_name TEXT NOT NULL,
            git_branch TEXT,
            model_name TEXT,
            message_count INTEGER NOT NULL,
            updated_at REAL NOT NULL,
            first_prompt TEXT NOT NULL,
            latest_turns_json TEXT NOT NULL,
            transcript_path TEXT NOT NULL,
            worktree_available INTEGER NOT NULL,
            placement TEXT NOT NULL,
            live_status TEXT,
            resume_command_override TEXT,
            surface_tag TEXT,
            mtime REAL NOT NULL,
            file_size INTEGER NOT NULL
        );
        CREATE INDEX IF NOT EXISTS idx_session_records_updated_at ON session_records(updated_at DESC);
        """
        exec(createRecordsSQL, context: "create session_records")

        let createFtsSQL = """
        CREATE VIRTUAL TABLE IF NOT EXISTS session_fts USING fts5(
            session_id UNINDEXED,
            title,
            first_prompt,
            full_transcript,
            git_branch,
            repo_name,
            agent,
            files_edited,
            tools_called,
            tokenize = 'unicode61'
        );
        """
        exec(createFtsSQL, context: "create session_fts")
    }

    /// Checks if a session needs to be re-indexed based on mtime and file size.
    public func needsReindex(sessionID: String, mtime: Date, fileSize: Int) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard let db else { return true }

        let sql = "SELECT mtime, file_size FROM session_index_meta WHERE session_id = ?"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return true }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, sessionID, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        if sqlite3_step(stmt) == SQLITE_ROW {
            let existingMtime = sqlite3_column_double(stmt, 0)
            let existingSize = sqlite3_column_int64(stmt, 1)
            let diff = abs(existingMtime - mtime.timeIntervalSince1970)
            if diff < 0.001 && existingSize == Int64(fileSize) {
                return false
            }
        }
        return true
    }

    /// Persists multiple agent session records and their file metadata in a single transaction
    /// reusing a prepared statement.
    public func saveRecordsBatch(_ entries: [(record: AgentSessionRecord, mtime: Date, fileSize: Int)]) {
        lock.lock()
        defer { lock.unlock() }
        guard let db, !entries.isEmpty else { return }

        let sql = """
        INSERT OR REPLACE INTO session_records (
            session_id, agent_kind, title, project_path, project_name,
            git_branch, model_name, message_count, updated_at, first_prompt,
            latest_turns_json, transcript_path, worktree_available, placement,
            live_status, resume_command_override, surface_tag, mtime, file_size
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            logStepFailure(SQLITE_ERROR, context: "prepare saveRecordsBatch")
            return
        }
        defer { sqlite3_finalize(stmt) }

        let encoder = JSONEncoder()
        inTransaction("saveRecordsBatch") {
            for entry in entries {
                let record = entry.record
                let turnsData = try? encoder.encode(record.latestTurns)
                let turnsJSON = turnsData.flatMap { String(data: $0, encoding: .utf8) } ?? "[]"

                sqlite3_reset(stmt)
                sqlite3_clear_bindings(stmt)

                sqlite3_bind_text(stmt, 1, record.id, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                sqlite3_bind_text(stmt, 2, record.agentKind.rawValue, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                sqlite3_bind_text(stmt, 3, record.title, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                sqlite3_bind_text(stmt, 4, record.projectPath, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                sqlite3_bind_text(stmt, 5, record.projectName, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                if let gitBranch = record.gitBranch {
                    sqlite3_bind_text(stmt, 6, gitBranch, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                } else {
                    sqlite3_bind_null(stmt, 6)
                }
                if let modelName = record.modelName {
                    sqlite3_bind_text(stmt, 7, modelName, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                } else {
                    sqlite3_bind_null(stmt, 7)
                }
                sqlite3_bind_int64(stmt, 8, Int64(record.messageCount))
                sqlite3_bind_double(stmt, 9, record.updatedAt.timeIntervalSince1970)
                sqlite3_bind_text(stmt, 10, record.firstPrompt, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                sqlite3_bind_text(stmt, 11, turnsJSON, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                sqlite3_bind_text(stmt, 12, record.transcriptPath, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                sqlite3_bind_int(stmt, 13, record.worktreeAvailable ? 1 : 0)
                sqlite3_bind_text(stmt, 14, record.placement.rawValue, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                if let liveStatus = record.liveStatus {
                    sqlite3_bind_text(stmt, 15, liveStatus, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                } else {
                    sqlite3_bind_null(stmt, 15)
                }
                if let resumeOverride = record.resumeCommandOverride {
                    sqlite3_bind_text(stmt, 16, resumeOverride, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                } else {
                    sqlite3_bind_null(stmt, 16)
                }
                if let surfaceTag = record.surfaceTag {
                    sqlite3_bind_text(stmt, 17, surfaceTag, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                } else {
                    sqlite3_bind_null(stmt, 17)
                }
                sqlite3_bind_double(stmt, 18, entry.mtime.timeIntervalSince1970)
                sqlite3_bind_int64(stmt, 19, Int64(entry.fileSize))

                let stepRes = sqlite3_step(stmt)
                if stepRes != SQLITE_DONE {
                    logStepFailure(stepRes, context: "step saveRecordsBatch for session \(record.id)")
                }
            }
        }
    }

    /// Persists multiple cached session entries in a single transaction.
    public func saveRecordsBatch(_ entries: [CachedSessionEntry]) {
        saveRecordsBatch(entries.map { (record: $0.record, mtime: $0.mtime, fileSize: $0.fileSize) })
    }

    /// Persists an agent session record and its file metadata to SQLite.
    public func saveRecord(_ record: AgentSessionRecord, mtime: Date, fileSize: Int) {
        saveRecordsBatch([(record: record, mtime: mtime, fileSize: fileSize)])
    }

    /// Loads all cached session entries stored in SQLite.
    /// Returns entries ordered by updatedAt descending.
    public func loadCachedEntries() -> [CachedSessionEntry] {
        lock.lock()
        defer { lock.unlock() }
        guard let db else { return [] }

        var entries: [CachedSessionEntry] = []
        let sql = """
        SELECT session_id, agent_kind, title, project_path, project_name,
               git_branch, model_name, message_count, updated_at, first_prompt,
               latest_turns_json, transcript_path, worktree_available, placement,
               live_status, resume_command_override, surface_tag, mtime, file_size
        FROM session_records
        ORDER BY updated_at DESC;
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            defer { sqlite3_finalize(stmt) }
            let decoder = JSONDecoder()
            while sqlite3_step(stmt) == SQLITE_ROW {
                guard let idCStr = sqlite3_column_text(stmt, 0),
                      let kindCStr = sqlite3_column_text(stmt, 1),
                      let titleCStr = sqlite3_column_text(stmt, 2),
                      let projectPathCStr = sqlite3_column_text(stmt, 3),
                      let projectNameCStr = sqlite3_column_text(stmt, 4),
                      let firstPromptCStr = sqlite3_column_text(stmt, 9),
                      let turnsJSONCStr = sqlite3_column_text(stmt, 10),
                      let transcriptPathCStr = sqlite3_column_text(stmt, 11),
                      let placementCStr = sqlite3_column_text(stmt, 13) else {
                    continue
                }

                let id = String(cString: idCStr)
                let kindRaw = String(cString: kindCStr)
                let kind = AgentKind(rawValue: kindRaw) ?? .claudeCode
                let title = String(cString: titleCStr)
                let projectPath = String(cString: projectPathCStr)
                let projectName = String(cString: projectNameCStr)
                let gitBranch = sqlite3_column_text(stmt, 5).map { String(cString: $0) }
                let modelName = sqlite3_column_text(stmt, 6).map { String(cString: $0) }
                let messageCount = Int(sqlite3_column_int64(stmt, 7))
                let updatedAt = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 8))
                let firstPrompt = String(cString: firstPromptCStr)
                let turnsJSON = String(cString: turnsJSONCStr)
                let transcriptPath = String(cString: transcriptPathCStr)
                let worktreeAvailable = sqlite3_column_int(stmt, 12) != 0
                let placementRaw = String(cString: placementCStr)
                let placement = AgentSessionPlacement(rawValue: placementRaw) ?? .local
                let liveStatus = sqlite3_column_text(stmt, 14).map { String(cString: $0) }
                let resumeOverride = sqlite3_column_text(stmt, 15).map { String(cString: $0) }
                let surfaceTag = sqlite3_column_text(stmt, 16).map { String(cString: $0) }
                let mtime = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 17))
                let fileSize = Int(sqlite3_column_int64(stmt, 18))

                let turnsData = turnsJSON.data(using: .utf8) ?? Data()
                let turns = (try? decoder.decode([AgentHistoryTurn].self, from: turnsData)) ?? []

                let record = AgentSessionRecord(
                    id: id,
                    agentKind: kind,
                    title: title,
                    projectPath: projectPath,
                    projectName: projectName,
                    gitBranch: gitBranch,
                    modelName: modelName,
                    messageCount: messageCount,
                    updatedAt: updatedAt,
                    firstPrompt: firstPrompt,
                    latestTurns: turns,
                    transcriptPath: transcriptPath,
                    worktreeAvailable: worktreeAvailable,
                    placement: placement,
                    liveStatus: liveStatus,
                    resumeCommandOverride: resumeOverride,
                    surfaceTag: surfaceTag
                )
                entries.append(CachedSessionEntry(
                    record: record,
                    mtime: mtime,
                    fileSize: fileSize,
                    transcriptPath: transcriptPath
                ))
            }
        }

        return entries
    }

    /// Prunes session_records, session_fts, and session_index_meta rows whose transcript_path
    /// no longer exists on disk or was not seen in the scan, executed in a single transaction.
    public func pruneMissingSessions(validTranscriptPaths: Set<String>) {
        // Read candidates under the lock, but stat the disk outside it so main-thread callers
        // (loadCachedEntries / needsReindex) never wait on per-row file-system I/O.
        var candidates: [(id: String, path: String)] = []
        lock.lock()
        if let db {
            let sql = "SELECT session_id, transcript_path FROM session_records UNION SELECT session_id, transcript_path FROM session_index_meta;"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                while sqlite3_step(stmt) == SQLITE_ROW {
                    guard let idC = sqlite3_column_text(stmt, 0), let pathC = sqlite3_column_text(stmt, 1) else { continue }
                    candidates.append((String(cString: idC), String(cString: pathC)))
                }
                sqlite3_finalize(stmt)
            }
        }
        lock.unlock()

        let deadIDs = Set(candidates.lazy.filter { c in
            !c.path.isEmpty && !c.path.hasPrefix("cloud://")
                && !validTranscriptPaths.contains(c.path) && !FileManager.default.fileExists(atPath: c.path)
        }.map(\.id))
        guard !deadIDs.isEmpty else { return }

        lock.lock()
        defer { lock.unlock() }
        guard db != nil else { return }
        inTransaction("prune") {
            deleteRows(deadIDs, from: Self.sessionTables, context: "prune delete")
        }
    }

    /// Deletes a session from session_records, session_fts, and session_index_meta.
    public func deleteSession(sessionID: String) {
        lock.lock()
        defer { lock.unlock() }
        guard db != nil else { return }
        deleteRows([sessionID], from: Self.sessionTables, context: "delete")
    }

    /// Indexes or updates a session in the FTS5 virtual table and metadata table.
    public func indexSession(
        sessionID: String,
        title: String,
        firstPrompt: String,
        fullTranscript: String,
        gitBranch: String?,
        repoName: String,
        agentName: String,
        filesEdited: String,
        toolsCalled: String,
        transcriptPath: String,
        mtime: Date,
        fileSize: Int,
        surfaceTag: String? = nil,
        topicSegments: [String]? = nil
    ) {
        // The scanner's in-memory cache is empty on every app launch / CLI run, so it re-parses
        // every transcript; skip the FTS write when the stored mtime/size still match.
        guard needsReindex(sessionID: sessionID, mtime: mtime, fileSize: fileSize) else { return }
        lock.lock()
        defer { lock.unlock() }
        guard let db else { return }

        // Remove old entries if any
        deleteRows([sessionID], from: ["session_fts", "session_index_meta"], context: "reindex delete")

        // Insert into FTS
        let insertFtsSQL = """
        INSERT INTO session_fts(session_id, title, first_prompt, full_transcript, git_branch, repo_name, agent, files_edited, tools_called)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        var insertFtsStmt: OpaquePointer?
        if sqlite3_prepare_v2(db, insertFtsSQL, -1, &insertFtsStmt, nil) == SQLITE_OK {
            let ftsAgent = (surfaceTag?.isEmpty == false) ? "\(agentName) \(surfaceTag!)" : agentName
            let transcriptToStore: String
            if let topicSegments, !topicSegments.isEmpty {
                transcriptToStore = "\(fullTranscript)\nMilestones: " + topicSegments.joined(separator: " · ")
            } else {
                transcriptToStore = fullTranscript
            }
            sqlite3_bind_text(insertFtsStmt, 1, sessionID, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(insertFtsStmt, 2, title, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(insertFtsStmt, 3, firstPrompt, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(insertFtsStmt, 4, transcriptToStore, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(insertFtsStmt, 5, gitBranch ?? "", -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(insertFtsStmt, 6, repoName, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(insertFtsStmt, 7, ftsAgent, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(insertFtsStmt, 8, filesEdited, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(insertFtsStmt, 9, toolsCalled, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            let stepRes = sqlite3_step(insertFtsStmt)
            if stepRes != SQLITE_DONE { logStepFailure(stepRes, context: "insert session_fts") }
            sqlite3_finalize(insertFtsStmt)
        }

        // Insert into meta
        let insertMetaSQL = "INSERT INTO session_index_meta(session_id, transcript_path, mtime, file_size) VALUES (?, ?, ?, ?)"
        var insertMetaStmt: OpaquePointer?
        if sqlite3_prepare_v2(db, insertMetaSQL, -1, &insertMetaStmt, nil) == SQLITE_OK {
            sqlite3_bind_text(insertMetaStmt, 1, sessionID, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(insertMetaStmt, 2, transcriptPath, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_double(insertMetaStmt, 3, mtime.timeIntervalSince1970)
            sqlite3_bind_int64(insertMetaStmt, 4, Int64(fileSize))
            let stepRes = sqlite3_step(insertMetaStmt)
            if stepRes != SQLITE_DONE { logStepFailure(stepRes, context: "insert session_index_meta") }
            sqlite3_finalize(insertMetaStmt)
        }
    }

    /// Searches the FTS5 index for sessions matching query tokens, ranked using bm25() with column weights.
    /// Returns array of matches ordered by bm25 rank (best first).
    public func searchRanked(query: String, limit: Int = 200, includeSnippet: Bool = false) -> [AgentHistoryFTSMatch] {
        lock.lock()
        defer { lock.unlock() }
        guard let db else { return [] }

        let clean = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return [] }

        let rawTokens = clean.components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !rawTokens.isEmpty else { return [] }

        let ftsQuery = rawTokens.map { token in
            let escaped = token.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\"*"
        }.joined(separator: " OR ")

        // Column weights matching Swift field weights:
        // 0: session_id UNINDEXED = 0.0
        // 1: title = 3.0
        // 2: first_prompt = 1.0
        // 3: full_transcript = 1.0
        // 4: git_branch = 2.5
        // 5: repo_name = 1.5
        // 6: agent = 1.5
        // 7: files_edited = 2.5
        // 8: tools_called = 2.5
        let sql = includeSnippet ? """
        SELECT session_id,
               snippet(session_fts, 3, '', '', '...', 15),
               bm25(session_fts, 0.0, 3.0, 1.0, 1.0, 2.5, 1.5, 1.5, 2.5, 2.5) AS weighted_rank,
               files_edited,
               tools_called
        FROM session_fts
        WHERE session_fts MATCH ?
        ORDER BY weighted_rank ASC
        LIMIT ?;
        """ : """
        SELECT session_id,
               '' AS snippet,
               bm25(session_fts, 0.0, 3.0, 1.0, 1.0, 2.5, 1.5, 1.5, 2.5, 2.5) AS weighted_rank,
               files_edited,
               tools_called
        FROM session_fts
        WHERE session_fts MATCH ?
        ORDER BY weighted_rank ASC
        LIMIT ?;
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, ftsQuery, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        sqlite3_bind_int(stmt, 2, Int32(limit))

        var results: [AgentHistoryFTSMatch] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            guard let idCStr = sqlite3_column_text(stmt, 0) else { continue }
            let id = String(cString: idCStr)
            let snippet = sqlite3_column_text(stmt, 1).map { String(cString: $0) } ?? ""
            let rank = sqlite3_column_double(stmt, 2)
            let filesEdited = sqlite3_column_text(stmt, 3).map { String(cString: $0) } ?? ""
            let toolsCalled = sqlite3_column_text(stmt, 4).map { String(cString: $0) } ?? ""

            results.append(AgentHistoryFTSMatch(
                sessionID: id,
                snippet: snippet,
                rank: rank,
                filesEdited: filesEdited,
                toolsCalled: toolsCalled
            ))
        }
        return results
    }

    /// Searches the FTS5 index for sessions matching query tokens.
    /// Returns dictionary mapping session_id to its match metadata.
    public func search(query: String, limit: Int = 200) -> [String: AgentHistoryFTSMatch] {
        let ranked = searchRanked(query: query, limit: limit, includeSnippet: true)
        var dict: [String: AgentHistoryFTSMatch] = [:]
        dict.reserveCapacity(ranked.count)
        for match in ranked {
            dict[match.sessionID] = match
        }
        return dict
    }
    #else
    public func needsReindex(sessionID: String, mtime: Date, fileSize: Int) -> Bool { false }
    public func indexSession(
        sessionID: String,
        title: String,
        firstPrompt: String,
        fullTranscript: String,
        gitBranch: String?,
        repoName: String,
        agentName: String,
        filesEdited: String,
        toolsCalled: String,
        transcriptPath: String,
        mtime: Date,
        fileSize: Int,
        surfaceTag: String? = nil,
        topicSegments: [String]? = nil
    ) {}
    public func saveRecordsBatch(_ entries: [(record: AgentSessionRecord, mtime: Date, fileSize: Int)]) {}
    public func saveRecordsBatch(_ entries: [CachedSessionEntry]) {}
    public func saveRecord(_ record: AgentSessionRecord, mtime: Date, fileSize: Int) {}
    public func loadCachedEntries() -> [CachedSessionEntry] { [] }
    public func pruneMissingSessions(validTranscriptPaths: Set<String>) {}
    public func deleteSession(sessionID: String) {}
    public func searchRanked(query: String, limit: Int = 200, includeSnippet: Bool = false) -> [AgentHistoryFTSMatch] { [] }
    public func search(query: String, limit: Int = 200) -> [String: AgentHistoryFTSMatch] { [:] }
    #endif
}
