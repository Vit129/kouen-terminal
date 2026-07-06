import XCTest
import KouenLSP

/// Covers the language servers added for Android/Flutter/SQL/CSS/HTML support — each language
/// resolves to its expected server binary and args, matching the swift/typescript/python/rust/go
/// cases already covered by production usage in KouenCLI+LSP.swift.
final class LSPServerRegistryTests: XCTestCase {
    /// Always plants a `.git` marker so `projectRoot()`'s upward walk stops here — otherwise it
    /// keeps climbing into the shared system temp tree, where stray files (other tools' caches)
    /// can coincidentally satisfy a glob marker like `.csproj`/`.sln` and produce a flaky match.
    private func makeRoot(markerFile: String? = nil) -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: dir.appendingPathComponent(".git").path, contents: nil)
        if let markerFile {
            FileManager.default.createFile(atPath: dir.appendingPathComponent(markerFile).path, contents: nil)
        }
        return dir
    }

    func testDartResolvesViaPubspecOrExtension() {
        let registry = LSPServerRegistry()
        let root = makeRoot(markerFile: "pubspec.yaml")
        let config = registry.configuration(forFile: root.appendingPathComponent("lib/main.dart"))
        XCTAssertEqual(config?.language, "dart")
        XCTAssertEqual(config?.arguments, ["language-server", "--protocol=lsp"])
    }

    func testKotlinResolvesViaGradleKtsOrExtension() {
        let registry = LSPServerRegistry()
        let root = makeRoot(markerFile: "build.gradle.kts")
        let config = registry.configuration(forFile: root.appendingPathComponent("app/src/Main.kt"))
        XCTAssertEqual(config?.language, "kotlin")
    }

    func testJavaResolvesViaPomOrGradleOrExtension() {
        let registry = LSPServerRegistry()
        let root = makeRoot(markerFile: "pom.xml")
        let config = registry.configuration(forFile: root.appendingPathComponent("src/Main.java"))
        XCTAssertEqual(config?.language, "java")
    }

    func testSqlResolvesViaExtension() {
        let registry = LSPServerRegistry()
        let root = makeRoot()
        let config = registry.configuration(forFile: root.appendingPathComponent("query.sql"))
        XCTAssertEqual(config?.language, "sql")
        XCTAssertEqual(config?.arguments, ["up", "--method", "stdio"])
    }

    func testCssResolvesViaExtension() {
        let registry = LSPServerRegistry()
        let root = makeRoot()
        for ext in ["css", "scss", "sass"] {
            let config = registry.configuration(forFile: root.appendingPathComponent("style.\(ext)"))
            XCTAssertEqual(config?.language, "css", "expected css language server for .\(ext)")
        }
    }

    func testHtmlResolvesViaExtension() {
        let registry = LSPServerRegistry()
        let root = makeRoot()
        let config = registry.configuration(forFile: root.appendingPathComponent("index.html"))
        XCTAssertEqual(config?.language, "html")
        XCTAssertEqual(config?.arguments, ["--stdio"])
    }

    func testObjectiveCResolvesViaXcodeprojOrExtension() {
        let registry = LSPServerRegistry()
        let root = makeRoot()
        FileManager.default.createFile(atPath: root.appendingPathComponent("App.xcodeproj").path, contents: nil)
        let config = registry.configuration(forFile: root.appendingPathComponent("AppDelegate.m"))
        XCTAssertEqual(config?.language, "swift")
        XCTAssertEqual(config?.executablePath.hasSuffix("sourcekit-lsp"), true)
    }

    func testCppResolvesViaCMakeOrExtension() {
        let registry = LSPServerRegistry()
        let root = makeRoot(markerFile: "CMakeLists.txt")
        let config = registry.configuration(forFile: root.appendingPathComponent("src/main.cpp"))
        XCTAssertEqual(config?.language, "cpp")
    }

    func testCSharpResolvesViaCsprojOrExtension() {
        let registry = LSPServerRegistry()
        let root = makeRoot()
        FileManager.default.createFile(atPath: root.appendingPathComponent("App.csproj").path, contents: nil)
        let config = registry.configuration(forFile: root.appendingPathComponent("Program.cs"))
        XCTAssertEqual(config?.language, "csharp")
    }

    func testRobotFrameworkResolvesViaExtension() {
        let registry = LSPServerRegistry()
        let root = makeRoot()
        let config = registry.configuration(forFile: root.appendingPathComponent("suite.robot"))
        XCTAssertEqual(config?.language, "robotframework")
        XCTAssertEqual(config?.arguments, ["language-server", "--stdio"])
    }

    func testPhpResolvesViaComposerOrExtension() {
        let registry = LSPServerRegistry()
        let root = makeRoot(markerFile: "composer.json")
        let config = registry.configuration(forFile: root.appendingPathComponent("index.php"))
        XCTAssertEqual(config?.language, "php")
        XCTAssertEqual(config?.arguments, ["--stdio"])
    }

    func testRubyResolvesViaGemfileOrExtension() {
        let registry = LSPServerRegistry()
        let root = makeRoot(markerFile: "Gemfile")
        let config = registry.configuration(forFile: root.appendingPathComponent("app.rb"))
        XCTAssertEqual(config?.language, "ruby")
    }

    func testShellResolvesViaExtension() {
        let registry = LSPServerRegistry()
        let root = makeRoot()
        for ext in ["sh", "bash", "zsh"] {
            let config = registry.configuration(forFile: root.appendingPathComponent("script.\(ext)"))
            XCTAssertEqual(config?.language, "shell", "expected shell language server for .\(ext)")
        }
        XCTAssertEqual(
            registry.configuration(forFile: root.appendingPathComponent("script.sh"))?.arguments,
            ["start"]
        )
    }

    func testYamlResolvesViaExtension() {
        let registry = LSPServerRegistry()
        let root = makeRoot()
        let config = registry.configuration(forFile: root.appendingPathComponent("config.yaml"))
        XCTAssertEqual(config?.language, "yaml")
    }

    func testJsonResolvesViaExtension() {
        let registry = LSPServerRegistry()
        let root = makeRoot()
        let config = registry.configuration(forFile: root.appendingPathComponent("settings.json"))
        XCTAssertEqual(config?.language, "json")
    }

    func testMarkdownResolvesViaExtension() {
        let registry = LSPServerRegistry()
        let root = makeRoot()
        let config = registry.configuration(forFile: root.appendingPathComponent("README.md"))
        XCTAssertEqual(config?.language, "markdown")
        XCTAssertEqual(config?.arguments, ["server"])
    }

    func testReactAndNextJsUseExistingTypescriptServer() {
        let registry = LSPServerRegistry()
        let root = makeRoot(markerFile: "package.json")
        let tsx = registry.configuration(forFile: root.appendingPathComponent("app/page.tsx"))
        XCTAssertEqual(tsx?.language, "typescript")
        XCTAssertEqual(tsx?.executablePath.hasSuffix("typescript-language-server"), true)
    }

    func testGoogleAppsScriptUsesExistingTypescriptServer() {
        let registry = LSPServerRegistry()
        let root = makeRoot()
        let config = registry.configuration(forFile: root.appendingPathComponent("Code.gs"))
        XCTAssertEqual(config?.language, "typescript")
    }

    func testGherkinResolvesViaExtension() {
        let registry = LSPServerRegistry()
        let root = makeRoot()
        let config = registry.configuration(forFile: root.appendingPathComponent("login.feature"))
        XCTAssertEqual(config?.language, "gherkin")
        XCTAssertEqual(config?.arguments, ["--stdio"])
    }

    func testCustomServerOverrideWins() {
        let registry = LSPServerRegistry()
        let root = makeRoot()
        let config = registry.configuration(
            forFile: root.appendingPathComponent("query.sql"),
            settings: LSPSettings(servers: ["sql": "/usr/local/bin/my-sqls"])
        )
        XCTAssertEqual(config?.executablePath, "/usr/local/bin/my-sqls")
    }
}
