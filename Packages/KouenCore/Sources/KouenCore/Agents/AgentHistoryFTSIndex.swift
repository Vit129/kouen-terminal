import Foundation
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

/// SQLite FTS5 full-text search index for agent sessions.
/// Manages indexing session metadata, transcripts, edited files, and tool names.
public final class AgentHistoryFTSIndex: @unchecked Sendable {
    public static let shared = AgentHistoryFTSIndex()

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
    private func openDatabase() {
        lock.lock()
        defer { lock.unlock() }

        if dbPath != ":memory:" {
            try? KouenPaths.ensureDirectories()
        }

        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            return
        }

        let createMetaSQL = """
        CREATE TABLE IF NOT EXISTS session_index_meta (
            session_id TEXT PRIMARY KEY,
            transcript_path TEXT,
            mtime REAL,
            file_size INTEGER
        );
        """
        sqlite3_exec(db, createMetaSQL, nil, nil, nil)

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
        sqlite3_exec(db, createFtsSQL, nil, nil, nil)
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
        fileSize: Int
    ) {
        // The scanner's in-memory cache is empty on every app launch / CLI run, so it re-parses
        // every transcript; skip the FTS write when the stored mtime/size still match.
        guard needsReindex(sessionID: sessionID, mtime: mtime, fileSize: fileSize) else { return }
        lock.lock()
        defer { lock.unlock() }
        guard let db else { return }

        // Remove old entries if any
        let deleteFtsSQL = "DELETE FROM session_fts WHERE session_id = ?"
        var delFtsStmt: OpaquePointer?
        if sqlite3_prepare_v2(db, deleteFtsSQL, -1, &delFtsStmt, nil) == SQLITE_OK {
            sqlite3_bind_text(delFtsStmt, 1, sessionID, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_step(delFtsStmt)
            sqlite3_finalize(delFtsStmt)
        }

        let deleteMetaSQL = "DELETE FROM session_index_meta WHERE session_id = ?"
        var delMetaStmt: OpaquePointer?
        if sqlite3_prepare_v2(db, deleteMetaSQL, -1, &delMetaStmt, nil) == SQLITE_OK {
            sqlite3_bind_text(delMetaStmt, 1, sessionID, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_step(delMetaStmt)
            sqlite3_finalize(delMetaStmt)
        }

        // Insert into FTS
        let insertFtsSQL = """
        INSERT INTO session_fts(session_id, title, first_prompt, full_transcript, git_branch, repo_name, agent, files_edited, tools_called)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        var insertFtsStmt: OpaquePointer?
        if sqlite3_prepare_v2(db, insertFtsSQL, -1, &insertFtsStmt, nil) == SQLITE_OK {
            sqlite3_bind_text(insertFtsStmt, 1, sessionID, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(insertFtsStmt, 2, title, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(insertFtsStmt, 3, firstPrompt, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(insertFtsStmt, 4, fullTranscript, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(insertFtsStmt, 5, gitBranch ?? "", -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(insertFtsStmt, 6, repoName, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(insertFtsStmt, 7, agentName, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(insertFtsStmt, 8, filesEdited, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(insertFtsStmt, 9, toolsCalled, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_step(insertFtsStmt)
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
            sqlite3_step(insertMetaStmt)
            sqlite3_finalize(insertMetaStmt)
        }
    }

    /// Searches the FTS5 index for sessions matching query tokens.
    /// Returns dictionary mapping session_id to its match metadata.
    ///
    /// Note: Returns only session_id, short snippet, bm25 rank, and edited files / tools.
    /// Does not load full transcripts into memory. Typo tolerance is handled on light fields
    /// by SearchMatcher.
    public func search(query: String, limit: Int = 200) -> [String: AgentHistoryFTSMatch] {
        lock.lock()
        defer { lock.unlock() }
        guard let db else { return [:] }

        let clean = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return [:] }

        let rawTokens = clean.components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !rawTokens.isEmpty else { return [:] }

        let ftsQuery = rawTokens.map { token in
            let escaped = token.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\"*"
        }.joined(separator: " OR ")

        let sql = """
        SELECT session_id, snippet(session_fts, 3, '', '', '...', 15), bm25(session_fts), files_edited, tools_called
        FROM session_fts
        WHERE session_fts MATCH ?
        ORDER BY rank
        LIMIT ?
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [:] }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, ftsQuery, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        sqlite3_bind_int(stmt, 2, Int32(limit))

        var results: [String: AgentHistoryFTSMatch] = [:]
        while sqlite3_step(stmt) == SQLITE_ROW {
            guard let idCStr = sqlite3_column_text(stmt, 0) else { continue }
            let id = String(cString: idCStr)
            let snippet = sqlite3_column_text(stmt, 1).map { String(cString: $0) } ?? ""
            let rank = sqlite3_column_double(stmt, 2)
            let filesEdited = sqlite3_column_text(stmt, 3).map { String(cString: $0) } ?? ""
            let toolsCalled = sqlite3_column_text(stmt, 4).map { String(cString: $0) } ?? ""

            results[id] = AgentHistoryFTSMatch(
                sessionID: id,
                snippet: snippet,
                rank: rank,
                filesEdited: filesEdited,
                toolsCalled: toolsCalled
            )
        }
        return results
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
        fileSize: Int
    ) {}
    public func search(query: String, limit: Int = 200) -> [String: AgentHistoryFTSMatch] { [:] }
    #endif
}
