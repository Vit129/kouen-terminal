import Foundation

public struct LSPServerConfiguration: Equatable, Sendable {
    public var language: String
    public var executablePath: String
    public var arguments: [String]
    public var rootURL: URL

    public init(language: String, executablePath: String, arguments: [String], rootURL: URL) {
        self.language = language
        self.executablePath = executablePath
        self.arguments = arguments
        self.rootURL = rootURL
    }
}

public struct LSPSettings: Codable, Equatable, Sendable {
    public var autoStart: Bool
    public var servers: [String: String]

    public init(autoStart: Bool = true, servers: [String: String] = [:]) {
        self.autoStart = autoStart
        self.servers = servers
    }
}

public struct LSPServerRegistry {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func configuration(forFile fileURL: URL, settings: LSPSettings = LSPSettings()) -> LSPServerConfiguration? {
        guard settings.autoStart else { return nil }
        let rootURL = projectRoot(containing: fileURL) ?? fileURL.deletingLastPathComponent()
        let ext = fileURL.pathExtension.lowercased()

        if hasFile("Package.swift", in: rootURL)
            || hasFileMatching(suffix: ".xcodeproj", in: rootURL)
            || hasFileMatching(suffix: ".xcworkspace", in: rootURL)
            || hasFile("Podfile", in: rootURL)
            || ["swift", "m", "mm"].contains(ext) {
            // sourcekit-lsp also serves Objective-C/Objective-C++ (.m/.mm) via its bundled clangd.
            return config(language: "swift", binary: settings.servers["swift"] ?? "sourcekit-lsp", args: [], root: rootURL)
        }
        if hasFile("package.json", in: rootURL) || ["ts", "tsx", "js", "jsx", "gs"].contains(ext) {
            let binary = settings.servers["typescript"] ?? settings.servers["javascript"] ?? "typescript-language-server"
            return config(language: "typescript", binary: binary, args: ["--stdio"], root: rootURL)
        }
        if hasFile("pyproject.toml", in: rootURL) || hasFile("requirements.txt", in: rootURL) || ext == "py" {
            return config(language: "python", binary: settings.servers["python"] ?? "pyright-langserver", args: ["--stdio"], root: rootURL)
        }
        if hasFile("Cargo.toml", in: rootURL) || ext == "rs" {
            return config(language: "rust", binary: settings.servers["rust"] ?? "rust-analyzer", args: [], root: rootURL)
        }
        if hasFile("go.mod", in: rootURL) || ext == "go" {
            return config(language: "go", binary: settings.servers["go"] ?? "gopls", args: [], root: rootURL)
        }
        if hasFile("pubspec.yaml", in: rootURL) || ext == "dart" {
            return config(language: "dart", binary: settings.servers["dart"] ?? "dart", args: ["language-server", "--protocol=lsp"], root: rootURL)
        }
        if hasFile("build.gradle.kts", in: rootURL) || ["kt", "kts"].contains(ext) {
            return config(language: "kotlin", binary: settings.servers["kotlin"] ?? "kotlin-language-server", args: [], root: rootURL)
        }
        if hasFile("pom.xml", in: rootURL) || hasFile("build.gradle", in: rootURL) || ext == "java" {
            // ponytail: no `-data` workspace dir passed to jdtls, so it falls back to its default
            // cache location and re-indexes per project on cold start. Upgrade: derive a stable
            // per-project data dir from rootURL and pass it via `args` if that becomes a problem.
            return config(language: "java", binary: settings.servers["java"] ?? "jdtls", args: [], root: rootURL)
        }
        if ext == "sql" {
            return config(language: "sql", binary: settings.servers["sql"] ?? "sql-language-server", args: ["up", "--method", "stdio"], root: rootURL)
        }
        if ["css", "scss", "sass"].contains(ext) {
            return config(language: "css", binary: settings.servers["css"] ?? "vscode-css-language-server", args: ["--stdio"], root: rootURL)
        }
        if ["html", "htm"].contains(ext) {
            return config(language: "html", binary: settings.servers["html"] ?? "vscode-html-language-server", args: ["--stdio"], root: rootURL)
        }
        if hasFile("CMakeLists.txt", in: rootURL) || hasFile("compile_commands.json", in: rootURL)
            || ["c", "cpp", "cc", "cxx", "h", "hpp", "hxx"].contains(ext) {
            return config(language: "cpp", binary: settings.servers["cpp"] ?? settings.servers["c"] ?? "clangd", args: [], root: rootURL)
        }
        if hasFileMatching(suffix: ".csproj", in: rootURL) || hasFileMatching(suffix: ".sln", in: rootURL) || ext == "cs" {
            return config(language: "csharp", binary: settings.servers["csharp"] ?? "csharp-ls", args: [], root: rootURL)
        }
        if hasFile("robot.toml", in: rootURL) || ["robot", "resource"].contains(ext) {
            return config(language: "robotframework", binary: settings.servers["robotframework"] ?? "robotcode", args: ["language-server", "--stdio"], root: rootURL)
        }
        if ext == "feature" {
            return config(language: "gherkin", binary: settings.servers["gherkin"] ?? "cucumber-language-server", args: ["--stdio"], root: rootURL)
        }
        if hasFile("composer.json", in: rootURL) || ext == "php" {
            return config(language: "php", binary: settings.servers["php"] ?? "intelephense", args: ["--stdio"], root: rootURL)
        }
        if hasFile("Gemfile", in: rootURL) || ext == "rb" {
            return config(language: "ruby", binary: settings.servers["ruby"] ?? "ruby-lsp", args: [], root: rootURL)
        }
        if ["sh", "bash", "zsh"].contains(ext) {
            return config(language: "shell", binary: settings.servers["shell"] ?? "bash-language-server", args: ["start"], root: rootURL)
        }
        if ["yml", "yaml"].contains(ext) {
            return config(language: "yaml", binary: settings.servers["yaml"] ?? "yaml-language-server", args: ["--stdio"], root: rootURL)
        }
        if ["json", "jsonc"].contains(ext) {
            return config(language: "json", binary: settings.servers["json"] ?? "vscode-json-language-server", args: ["--stdio"], root: rootURL)
        }
        if ["md", "markdown"].contains(ext) {
            return config(language: "markdown", binary: settings.servers["markdown"] ?? "marksman", args: ["server"], root: rootURL)
        }
        return nil
    }

    private func config(language: String, binary: String, args: [String], root: URL) -> LSPServerConfiguration {
        LSPServerConfiguration(language: language, executablePath: resolve(binary), arguments: args, rootURL: root)
    }

    private func projectRoot(containing fileURL: URL) -> URL? {
        var url = fileURL.hasDirectoryPath ? fileURL : fileURL.deletingLastPathComponent()
        while url.path != "/" {
            if hasFile(".git", in: url)
                || hasFile("Package.swift", in: url)
                || hasFile("package.json", in: url)
                || hasFile("pyproject.toml", in: url)
                || hasFile("Cargo.toml", in: url)
                || hasFile("go.mod", in: url)
                || hasFile("pubspec.yaml", in: url)
                || hasFile("build.gradle.kts", in: url)
                || hasFile("build.gradle", in: url)
                || hasFile("pom.xml", in: url)
                || hasFile("CMakeLists.txt", in: url)
                || hasFile("compile_commands.json", in: url)
                || hasFile("robot.toml", in: url)
                || hasFile("composer.json", in: url)
                || hasFile("Gemfile", in: url)
                || hasFileMatching(suffix: ".xcodeproj", in: url)
                || hasFileMatching(suffix: ".xcworkspace", in: url)
                || hasFileMatching(suffix: ".csproj", in: url)
                || hasFileMatching(suffix: ".sln", in: url) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return nil
    }

    private func hasFile(_ name: String, in directory: URL) -> Bool {
        fileManager.fileExists(atPath: directory.appendingPathComponent(name).path)
    }

    private func hasFileMatching(suffix: String, in directory: URL) -> Bool {
        guard let entries = try? fileManager.contentsOfDirectory(atPath: directory.path) else { return false }
        return entries.contains { $0.hasSuffix(suffix) }
    }

    private func resolve(_ binary: String) -> String {
        if binary.hasPrefix("/") || binary.hasPrefix("~") {
            return (binary as NSString).expandingTildeInPath
        }
        let candidates = [
            "/opt/homebrew/bin/\(binary)",
            "/usr/local/bin/\(binary)",
            "/usr/bin/\(binary)",
        ]
        return candidates.first(where: { fileManager.isExecutableFile(atPath: $0) }) ?? binary
    }
}
