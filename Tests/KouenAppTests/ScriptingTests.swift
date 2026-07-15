import XCTest
@testable import KouenApp
import KouenCore

final class ScriptingTests: XCTestCase {

    func testConfigLocatorPrecedence() {
        // 1. $KOUEN_CONFIG_FILE takes highest precedence
        let env1 = [
            "KOUEN_CONFIG_FILE": "/custom/path/init.js",
            "XDG_CONFIG_HOME": "/xdg",
            "HOME": "/home"
        ]
        let path1 = ScriptConfigLocator.locate(environment: env1) { path in
            return path == "/custom/path/init.js" || path == "/xdg/kouen/init.js"
        }
        XCTAssertEqual(path1, "/custom/path/init.js")

        // 2. $XDG_CONFIG_HOME/kouen/init.js takes precedence if $KOUEN_CONFIG_FILE is missing
        let env2 = [
            "XDG_CONFIG_HOME": "/xdg",
            "HOME": "/home"
        ]
        let path2 = ScriptConfigLocator.locate(environment: env2) { path in
            return path == "/xdg/kouen/init.js" || path == "/home/.config/kouen/init.js"
        }
        XCTAssertEqual(path2, "/xdg/kouen/init.js")

        // 3. $HOME/.config/kouen/init.js takes precedence if XDG is missing
        let env3 = [
            "HOME": "/home"
        ]
        let path3 = ScriptConfigLocator.locate(environment: env3) { path in
            return path == "/home/.config/kouen/init.js" || path == "/home/.kouen.js"
        }
        XCTAssertEqual(path3, "/home/.config/kouen/init.js")

        // 4. $HOME/.kouen.js is the fallback
        let env4 = [
            "HOME": "/home"
        ]
        let path4 = ScriptConfigLocator.locate(environment: env4) { path in
            return path == "/home/.kouen.js"
        }
        XCTAssertEqual(path4, "/home/.kouen.js")

        // 5. None exist
        let path5 = ScriptConfigLocator.locate(environment: env4) { _ in false }
        XCTAssertNil(path5)
    }

    @MainActor
    func testMissingFileIsNoOp() {
        // If config locator returns nil, no runtime should be initialized
        let env = ["HOME": "/home"]
        let located = ScriptConfigLocator.locate(environment: env) { _ in false }
        XCTAssertNil(located)
    }

    @MainActor
    func testMinimalScriptEvaluation() throws {
        let runtime = ScriptRuntime()
        let script = """
        kouen.log("Hello from script");
        kouen.toast("Hello toast");
        var version = kouen.version;
        """
        // Evaluate script
        try runtime.evaluate(script: script, sourceURL: URL(fileURLWithPath: "/tmp/test.js"))

        #if canImport(JavaScriptCore)
        let kouenObj = runtime.context.objectForKeyedSubscript("kouen")
        XCTAssertNotNil(kouenObj)
        let expectedVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        XCTAssertEqual(kouenObj?.objectForKeyedSubscript("version")?.toString(), expectedVersion)
        #endif
    }

    @MainActor
    func testSyntaxErrorThrowsAndDoesNotCrash() {
        let runtime = ScriptRuntime()
        let badScript = """
        kouen.log("Unclosed string...
        """

        XCTAssertThrowsError(try runtime.evaluate(script: badScript, sourceURL: URL(fileURLWithPath: "/tmp/bad.js"))) { error in
            guard case let ScriptError.evaluationError(msg) = error else {
                XCTFail("Expected evaluationError, got \(error)")
                return
            }
            XCTAssertFalse(msg.isEmpty, "Error message should not be empty")
        }
    }

    @MainActor
    func testScriptFileWatcherReloadAndReArm() async throws {
        // Create temp file
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("script-watch-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let scriptFile = tempDir.appendingPathComponent("init.js")
        try Data("console.log('v1')".utf8).write(to: scriptFile)

        let watcher = ScriptFileWatcher(debounceInterval: 0.05)

        let expectation = self.expectation(description: "Watcher fires")
        var fireCount = 0

        watcher.start(path: scriptFile.path) {
            fireCount += 1
            expectation.fulfill()
        }

        // Write to file to trigger reload
        try Data("console.log('v2')".utf8).write(to: scriptFile)

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(fireCount, 1)

        // Now test re-arm: re-start watcher on the same file (like loadScript does)
        let expectation2 = self.expectation(description: "Watcher fires again after re-arm")
        watcher.start(path: scriptFile.path) {
            fireCount += 1
            expectation2.fulfill()
        }

        // Perform atomic save emulation: delete and recreate/write
        try FileManager.default.removeItem(at: scriptFile)
        try Data("console.log('v3')".utf8).write(to: scriptFile)

        await fulfillment(of: [expectation2], timeout: 2.0)
        XCTAssertEqual(fireCount, 2)

        watcher.stop()
    }

    @MainActor
    func testReadOnlySnapshotAPIAndNonMutating() throws {
        let runtime = ScriptRuntime()

        #if canImport(JavaScriptCore)
        // 1. Test sessions list
        let sessionsVal = runtime.context.evaluateScript("kouen.sessions.list()")
        XCTAssertNotNil(sessionsVal)
        XCTAssertTrue(sessionsVal!.isArray)

        let sessionsCount = sessionsVal!.context.evaluateScript("kouen.sessions.list().length")?.toInt32() ?? 0
        XCTAssertGreaterThan(sessionsCount, 0)

        // 2. Test panes list
        let panesVal = runtime.context.evaluateScript("kouen.panes.list()")
        XCTAssertNotNil(panesVal)
        XCTAssertTrue(panesVal!.isArray)

        let panesCount = panesVal!.context.evaluateScript("kouen.panes.list().length")?.toInt32() ?? 0
        XCTAssertGreaterThan(panesCount, 0)

        // 3. Test non-mutating copy semantics:
        // Mutate a property on the JS object
        _ = runtime.context.evaluateScript("""
        var list = kouen.sessions.list();
        if (list.length > 0) {
            list[0].name = "MutatedNameJS";
        }
        """)

        // Fetch the list again, verify the name is not mutated on the next fetch
        let refetchedName = runtime.context.evaluateScript("kouen.sessions.list()[0].name")?.toString()
        XCTAssertNotEqual(refetchedName, "MutatedNameJS")
        #endif
    }

    /// P16 PBI-BOARD-005: `kouen.board.list()` returns `BoardModel.classify(...)`
    /// columns, same shape as the `kouenBoard` MCP tool.
    @MainActor
    func testBoardListReturnsAllColumns() throws {
        let runtime = ScriptRuntime()

        #if canImport(JavaScriptCore)
        let boardVal = runtime.context.evaluateScript("kouen.board.list()")
        XCTAssertNotNil(boardVal)
        XCTAssertTrue(boardVal!.isArray)

        let columnCount = runtime.context.evaluateScript("kouen.board.list().length")?.toInt32() ?? 0
        XCTAssertEqual(Int(columnCount), BoardColumnKind.allCases.count)

        let firstColumnName = runtime.context.evaluateScript("kouen.board.list()[0].kind")?.toString()
        XCTAssertEqual(firstColumnName, BoardColumnKind.needsAttention.rawValue)

        // Default SessionCoordinator snapshot has at least one idle tab (count varies by
        // test ordering since SessionCoordinator.shared is a singleton).
        let idleCardCount = runtime.context.evaluateScript("""
        kouen.board.list().find(c => c.kind === 'idle').cards.length
        """)?.toInt32() ?? -1
        XCTAssertGreaterThanOrEqual(Int(idleCardCount), 0)
        #endif
    }

    /// P15 step 3: `kouen.events.on/off` dispatch JS handlers synchronously via
    /// `ScriptRuntime.dispatchEvent`, which `NotificationBus`-bridged notifications
    /// (`snapshotChanged`, `configReloaded`) drive.
    @MainActor
    func testEventsOnDispatchesHandlerWithPayload() throws {
        let runtime = ScriptRuntime()

        #if canImport(JavaScriptCore)
        var capturedRevision: Int32?
        let captureBlock: @convention(block) (Int32) -> Void = { revision in
            capturedRevision = revision
        }
        runtime.context.setObject(captureBlock, forKeyedSubscript: "__testCapture" as NSString)

        try runtime.evaluate(script: """
        kouen.events.on("snapshotChanged", function(e) { __testCapture(e.revision); });
        """, sourceURL: URL(fileURLWithPath: "/tmp/events-on.js"))

        runtime.dispatchEvent("snapshotChanged", payload: ["revision": 42])

        XCTAssertEqual(capturedRevision, 42)
        #endif
    }

    /// P38 Phase E: `paneCreated`/`paneRemoved` were documented in `ScriptAPI.swift`'s
    /// `kouen.plugin.on` comment but never actually dispatched anywhere — this is the bridge-level
    /// contract test (payload shape), mirroring `testEventsOnDispatchesHandlerWithPayload`.
    @MainActor
    func testPaneCreatedAndRemovedDispatchWithPaneIDPayload() throws {
        let runtime = ScriptRuntime()

        #if canImport(JavaScriptCore)
        var createdPaneID: String?
        var removedPaneID: String?
        let captureCreated: @convention(block) (String) -> Void = { createdPaneID = $0 }
        let captureRemoved: @convention(block) (String) -> Void = { removedPaneID = $0 }
        runtime.context.setObject(captureCreated, forKeyedSubscript: "__testCaptureCreated" as NSString)
        runtime.context.setObject(captureRemoved, forKeyedSubscript: "__testCaptureRemoved" as NSString)

        try runtime.evaluate(script: """
        kouen.events.on("paneCreated", function(e) { __testCaptureCreated(e.paneID); });
        kouen.events.on("paneRemoved", function(e) { __testCaptureRemoved(e.paneID); });
        """, sourceURL: URL(fileURLWithPath: "/tmp/events-pane-diff.js"))

        runtime.dispatchEvent("paneCreated", payload: ["paneID": "abc-123"])
        runtime.dispatchEvent("paneRemoved", payload: ["paneID": "def-456"])

        XCTAssertEqual(createdPaneID, "abc-123")
        XCTAssertEqual(removedPaneID, "def-456")
        #endif
    }

    /// Regression guard for the fix in `registerNotificationBridge` — the pane-diff baseline
    /// must be seeded from whatever panes already exist at `ScriptRuntime` init, NOT an empty
    /// set. Without that seed, the very first diff after script load would fire a spurious
    /// `paneCreated` for every pane already open. Calls `dispatchPaneDiff()` directly rather
    /// than posting through `NotificationBus` — a real post fans out to `NotificationCoordinator`,
    /// which crashes outside a real app process (RL-065, `UNUserNotificationCenter` needs a
    /// bundle context bare `swift test` doesn't have).
    @MainActor
    func testNoSpuriousPaneCreatedOnFirstDiffAfterInit() throws {
        let runtime = ScriptRuntime()

        #if canImport(JavaScriptCore)
        var fireCount = 0
        let captureBlock: @convention(block) () -> Void = { fireCount += 1 }
        runtime.context.setObject(captureBlock, forKeyedSubscript: "__testCapture" as NSString)

        try runtime.evaluate(script: """
        kouen.events.on("paneCreated", function() { __testCapture(); });
        """, sourceURL: URL(fileURLWithPath: "/tmp/events-pane-no-spurious.js"))

        // The pane set hasn't changed since init — this must be a no-op for paneCreated.
        runtime.dispatchPaneDiff()

        XCTAssertEqual(fireCount, 0, "no real pane change occurred — paneCreated must not fire")
        #endif
    }

    @MainActor
    func testEventsOffRemovesHandler() throws {
        let runtime = ScriptRuntime()

        #if canImport(JavaScriptCore)
        var callCount = 0
        let captureBlock: @convention(block) () -> Void = {
            callCount += 1
        }
        runtime.context.setObject(captureBlock, forKeyedSubscript: "__testCapture" as NSString)

        try runtime.evaluate(script: """
        function handler(e) { __testCapture(); }
        kouen.events.on("snapshotChanged", handler);
        kouen.events.off("snapshotChanged", handler);
        """, sourceURL: URL(fileURLWithPath: "/tmp/events-off.js"))

        runtime.dispatchEvent("snapshotChanged", payload: ["revision": 1])

        XCTAssertEqual(callCount, 0)
        #endif
    }

    /// A throwing handler is caught and does not propagate or crash; the JS
    /// exception is cleared so subsequent dispatches are unaffected.
    @MainActor
    func testEventsHandlerErrorDoesNotCrashOrLeakException() throws {
        let runtime = ScriptRuntime()

        #if canImport(JavaScriptCore)
        try runtime.evaluate(script: """
        kouen.events.on("snapshotChanged", function(e) { throw new Error("boom"); });
        """, sourceURL: URL(fileURLWithPath: "/tmp/events-error.js"))

        runtime.dispatchEvent("snapshotChanged", payload: ["revision": 1])
        runtime.dispatchEvent("snapshotChanged", payload: ["revision": 2])

        XCTAssertNil(runtime.context.exception)
        #endif
    }

    /// End-to-end: `NotificationBus.shared.postConfigReloaded` (fired by
    /// `ScriptHookCoordinator` after (re)loading the config) reaches a
    /// `kouen.events.on("configReloaded", ...)` handler.
    @MainActor
    func testNotificationBusConfigReloadedReachesScriptHandler() async throws {
        let runtime = ScriptRuntime()

        #if canImport(JavaScriptCore)
        var fired = false
        let captureBlock: @convention(block) () -> Void = {
            fired = true
        }
        runtime.context.setObject(captureBlock, forKeyedSubscript: "__testCapture" as NSString)

        try runtime.evaluate(script: """
        kouen.events.on("configReloaded", function() { __testCapture(); });
        """, sourceURL: URL(fileURLWithPath: "/tmp/events-config-reloaded.js"))

        NotificationBus.shared.postConfigReloaded()

        for _ in 0..<20 where !fired {
            try await Task.sleep(nanoseconds: 10_000_000)
        }

        XCTAssertTrue(fired)
        #endif
    }

    @MainActor
    func testCommandParseBridge() throws {
        let runtime = ScriptRuntime()

        #if canImport(JavaScriptCore)
        let parsedVal = runtime.context.evaluateScript("kouen.commands.parse('split-window -h')")
        XCTAssertNotNil(parsedVal)
        XCTAssertTrue(parsedVal!.isObject)

        let jsonStr = runtime.context.evaluateScript("JSON.stringify(kouen.commands.parse('split-window -h'))")?.toString()
        XCTAssertNotNil(jsonStr)
        XCTAssertTrue(jsonStr?.contains("splitWindow") ?? false)

        // Test parsing error handling
        _ = runtime.context.evaluateScript("kouen.commands.parse('unknown-command-xyz')")
        let exceptionStr = runtime.context.exception?.toString()
        XCTAssertNotNil(exceptionStr)
        XCTAssertTrue(exceptionStr?.contains("unknown") ?? exceptionStr?.contains("Unknown") ?? false)
        #endif
    }

    // MARK: - P11 PBI-SCRIPT-004: kouen.config

    /// Valid allowlisted key: `set` updates the in-memory `KouenSettings`, persists to
    /// `KouenPaths.settingsURL`, and `get` reflects the new value.
    @MainActor
    func testConfigGetSetValidKeyPersists() throws {
        // Force SessionCoordinator's lazy daemon client to initialize against the real
        // default KOUEN_HOME *before* we point KOUEN_HOME at a temp dir below — it
        // captures its socket endpoint at first access and must not be left pointing at
        // a directory this test deletes on teardown.
        _ = SessionCoordinator.shared.snapshot

        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("script-config-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let previousHome = getenv("KOUEN_HOME").map { String(cString: $0) }
        setenv("KOUEN_HOME", tempDir.path, 1)
        defer {
            if let previousHome { setenv("KOUEN_HOME", previousHome, 1) } else { unsetenv("KOUEN_HOME") }
        }

        let runtime = ScriptRuntime()

        #if canImport(JavaScriptCore)
        _ = runtime.context.evaluateScript("kouen.config.set('fontSize', 16)")
        XCTAssertNil(runtime.context.exception)

        let fontSize = runtime.context.evaluateScript("kouen.config.get('fontSize')")?.toDouble()
        XCTAssertEqual(fontSize, 16)
        XCTAssertEqual(SessionCoordinator.shared.settings.fontSize, 16)

        _ = runtime.context.evaluateScript("kouen.config.set('defaultShell', '/bin/zsh')")
        XCTAssertNil(runtime.context.exception)
        XCTAssertEqual(runtime.context.evaluateScript("kouen.config.get('defaultShell')")?.toString(), "/bin/zsh")
        XCTAssertEqual(SessionCoordinator.shared.settings.defaultShell, "/bin/zsh")

        // Persisted to KOUEN_HOME's settings.json (the same path Settings UI saves to).
        XCTAssertTrue(FileManager.default.fileExists(atPath: KouenPaths.settingsURL.path))
        #endif
    }

    /// An unknown key, or a value of the wrong type for a known key, throws and leaves
    /// `KouenSettings` unchanged (no persisted write).
    @MainActor
    func testConfigSetInvalidKeyOrTypeThrowsWithoutMutating() throws {
        let runtime = ScriptRuntime()

        #if canImport(JavaScriptCore)
        let before = SessionCoordinator.shared.settings.fontSize

        _ = runtime.context.evaluateScript("kouen.config.set('notAKey', 1)")
        XCTAssertNotNil(runtime.context.exception)
        runtime.context.exception = nil

        _ = runtime.context.evaluateScript("kouen.config.set('fontSize', 'not-a-number')")
        XCTAssertNotNil(runtime.context.exception)
        runtime.context.exception = nil

        XCTAssertEqual(SessionCoordinator.shared.settings.fontSize, before)

        _ = runtime.context.evaluateScript("kouen.config.get('notAKey')")
        XCTAssertNotNil(runtime.context.exception)
        #endif
    }

    // MARK: - P11 PBI-SCRIPT-004: kouen.keys

    /// A valid bind on an allowlisted table parses the command via `CommandParser`, is
    /// reflected in `KeybindingsService`, and persists through `KeybindingsStore`; unbind
    /// reverses both.
    @MainActor
    func testKeysBindUnbindValidPersists() throws {
        // See testConfigGetSetValidKeyPersists: warm the daemon client's socket endpoint
        // against the real KOUEN_HOME before pointing it at a temp dir below.
        _ = SessionCoordinator.shared.snapshot

        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("script-keys-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let previousHome = getenv("KOUEN_HOME").map { String(cString: $0) }
        setenv("KOUEN_HOME", tempDir.path, 1)
        defer {
            if let previousHome { setenv("KOUEN_HOME", previousHome, 1) } else { unsetenv("KOUEN_HOME") }
        }

        guard let spec = KeySpec.parse("C-y") else {
            XCTFail("KeySpec.parse('C-y') should succeed")
            return
        }

        let runtime = ScriptRuntime()

        #if canImport(JavaScriptCore)
        _ = runtime.context.evaluateScript("kouen.keys.bind('prefix', 'C-y', 'split-window -h')")
        XCTAssertNil(runtime.context.exception)

        let bound = KeybindingsService.shared.bindings(in: .prefix)
        XCTAssertTrue(bound.contains { $0.spec == spec && $0.command == .splitWindow(direction: .vertical) })

        let onDisk = KeybindingsStore.load()
        XCTAssertTrue(onDisk.table(.prefix)?.bindings.contains { $0.spec == spec } ?? false)

        _ = runtime.context.evaluateScript("kouen.keys.unbind('prefix', 'C-y')")
        XCTAssertNil(runtime.context.exception)

        let afterUnbind = KeybindingsService.shared.bindings(in: .prefix)
        XCTAssertFalse(afterUnbind.contains { $0.spec == spec })

        let onDiskAfterUnbind = KeybindingsStore.load()
        XCTAssertFalse(onDiskAfterUnbind.table(.prefix)?.bindings.contains { $0.spec == spec } ?? true)
        #endif
    }

    /// An unknown table, or a command source that fails to parse, throws and leaves the
    /// table's bindings unchanged.
    @MainActor
    func testKeysBindInvalidTableOrCommandThrowsWithoutMutating() throws {
        let runtime = ScriptRuntime()

        #if canImport(JavaScriptCore)
        let before = KeybindingsService.shared.bindings(in: .prefix).count

        _ = runtime.context.evaluateScript("kouen.keys.bind('bogus-table', 'C-z', 'split-window -h')")
        XCTAssertNotNil(runtime.context.exception)
        runtime.context.exception = nil

        _ = runtime.context.evaluateScript("kouen.keys.bind('prefix', 'C-z', 'unknown-command-xyz')")
        XCTAssertNotNil(runtime.context.exception)
        runtime.context.exception = nil

        XCTAssertEqual(KeybindingsService.shared.bindings(in: .prefix).count, before)
        #endif
    }

    // MARK: - P11 PBI-SCRIPT-005: kouen.commands.run

    /// `__runSync` parses `commandSource` and executes it through `MainExecutor` — using
    /// `reload-keybindings`, a daemon-independent command (`KeybindingsService.reload()` +
    /// `PrefixKeymap.rebuildFromSettings()`) that is safe and deterministic headless.
    @MainActor
    func testCommandsRunSyncExecutesValidCommandAndRejectsInvalid() throws {
        let runtime = ScriptRuntime()

        #if canImport(JavaScriptCore)
        let result = runtime.context.evaluateScript("kouen.commands.__runSync('reload-keybindings')")
        XCTAssertNil(runtime.context.exception)
        XCTAssertEqual(result?.objectForKeyedSubscript("ok")?.toBool(), true)

        _ = runtime.context.evaluateScript("kouen.commands.__runSync('unknown-command-xyz')")
        XCTAssertNotNil(runtime.context.exception)
        #endif
    }

    /// `kouen.commands.run` wraps `__runSync` in a Promise, matching the documented
    /// `Promise<Result>` signature.
    @MainActor
    func testCommandsRunReturnsPromise() throws {
        let runtime = ScriptRuntime()

        #if canImport(JavaScriptCore)
        let isPromise = runtime.context.evaluateScript("kouen.commands.run('reload-keybindings') instanceof Promise")?.toBool()
        XCTAssertEqual(isPromise, true)
        #endif
    }

    // MARK: - P11 PBI-SCRIPT-005: mutating pane/session API surface

    /// `kouen.panes.list()` entries expose `sendText`/`split`/`close`, and
    /// `kouen.sessions.list()` entries expose `spawn`, as documented mutators. Calling
    /// them is exercised manually in a preview build (per the plan's smoke-test note)
    /// since it routes through a live daemon connection; this test only verifies the API
    /// surface is wired up.
    @MainActor
    func testPaneAndSessionMutatorsAreExposedAsFunctions() throws {
        let runtime = ScriptRuntime()

        #if canImport(JavaScriptCore)
        let paneFns = runtime.context.evaluateScript("""
        (function() {
            var p = kouen.panes.list()[0];
            return [typeof p.sendText, typeof p.split, typeof p.close];
        })()
        """)?.toArray() as? [String]
        XCTAssertEqual(paneFns, ["function", "function", "function"])

        let sessionSpawnType = runtime.context.evaluateScript("typeof kouen.sessions.list()[0].spawn")?.toString()
        XCTAssertEqual(sessionSpawnType, "function")
        #endif
    }
}
