import XCTest
@testable import HarnessApp

final class ScriptingTests: XCTestCase {

    func testConfigLocatorPrecedence() {
        // 1. $HARNESS_CONFIG_FILE takes highest precedence
        let env1 = [
            "HARNESS_CONFIG_FILE": "/custom/path/init.js",
            "XDG_CONFIG_HOME": "/xdg",
            "HOME": "/home"
        ]
        let path1 = ScriptConfigLocator.locate(environment: env1) { path in
            return path == "/custom/path/init.js" || path == "/xdg/harness/init.js"
        }
        XCTAssertEqual(path1, "/custom/path/init.js")

        // 2. $XDG_CONFIG_HOME/harness/init.js takes precedence if $HARNESS_CONFIG_FILE is missing
        let env2 = [
            "XDG_CONFIG_HOME": "/xdg",
            "HOME": "/home"
        ]
        let path2 = ScriptConfigLocator.locate(environment: env2) { path in
            return path == "/xdg/harness/init.js" || path == "/home/.config/harness/init.js"
        }
        XCTAssertEqual(path2, "/xdg/harness/init.js")

        // 3. $HOME/.config/harness/init.js takes precedence if XDG is missing
        let env3 = [
            "HOME": "/home"
        ]
        let path3 = ScriptConfigLocator.locate(environment: env3) { path in
            return path == "/home/.config/harness/init.js" || path == "/home/.harness.js"
        }
        XCTAssertEqual(path3, "/home/.config/harness/init.js")

        // 4. $HOME/.harness.js is the fallback
        let env4 = [
            "HOME": "/home"
        ]
        let path4 = ScriptConfigLocator.locate(environment: env4) { path in
            return path == "/home/.harness.js"
        }
        XCTAssertEqual(path4, "/home/.harness.js")

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
        harness.log("Hello from script");
        harness.toast("Hello toast");
        var version = harness.version;
        """
        // Evaluate script
        try runtime.evaluate(script: script, sourceURL: URL(fileURLWithPath: "/tmp/test.js"))

        #if canImport(JavaScriptCore)
        let harnessObj = runtime.context.objectForKeyedSubscript("harness")
        XCTAssertNotNil(harnessObj)
        let expectedVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        XCTAssertEqual(harnessObj?.objectForKeyedSubscript("version")?.toString(), expectedVersion)
        #endif
    }

    @MainActor
    func testSyntaxErrorThrowsAndDoesNotCrash() {
        let runtime = ScriptRuntime()
        let badScript = """
        harness.log("Unclosed string...
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
        let sessionsVal = runtime.context.evaluateScript("harness.sessions.list()")
        XCTAssertNotNil(sessionsVal)
        XCTAssertTrue(sessionsVal!.isArray)

        let sessionsCount = sessionsVal!.context.evaluateScript("harness.sessions.list().length")?.toInt32() ?? 0
        XCTAssertGreaterThan(sessionsCount, 0)

        // 2. Test panes list
        let panesVal = runtime.context.evaluateScript("harness.panes.list()")
        XCTAssertNotNil(panesVal)
        XCTAssertTrue(panesVal!.isArray)

        let panesCount = panesVal!.context.evaluateScript("harness.panes.list().length")?.toInt32() ?? 0
        XCTAssertGreaterThan(panesCount, 0)

        // 3. Test non-mutating copy semantics:
        // Mutate a property on the JS object
        _ = runtime.context.evaluateScript("""
        var list = harness.sessions.list();
        if (list.length > 0) {
            list[0].name = "MutatedNameJS";
        }
        """)

        // Fetch the list again, verify the name is not mutated on the next fetch
        let refetchedName = runtime.context.evaluateScript("harness.sessions.list()[0].name")?.toString()
        XCTAssertNotEqual(refetchedName, "MutatedNameJS")
        #endif
    }

    @MainActor
    func testCommandParseBridge() throws {
        let runtime = ScriptRuntime()

        #if canImport(JavaScriptCore)
        let parsedVal = runtime.context.evaluateScript("harness.commands.parse('split-window -h')")
        XCTAssertNotNil(parsedVal)
        XCTAssertTrue(parsedVal!.isObject)

        let jsonStr = runtime.context.evaluateScript("JSON.stringify(harness.commands.parse('split-window -h'))")?.toString()
        XCTAssertNotNil(jsonStr)
        XCTAssertTrue(jsonStr?.contains("splitWindow") ?? false)

        // Test parsing error handling
        _ = runtime.context.evaluateScript("harness.commands.parse('unknown-command-xyz')")
        let exceptionStr = runtime.context.exception?.toString()
        XCTAssertNotNil(exceptionStr)
        XCTAssertTrue(exceptionStr?.contains("unknown") ?? exceptionStr?.contains("Unknown") ?? false)
        #endif
    }
}
