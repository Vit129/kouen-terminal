import Foundation
import KouenCore
import KouenLSP

@MainActor
final class LSPFileSession {
    private let registry = LSPServerRegistry()
    private var client: LSPClient?
    private var diagnosticsTask: Task<Void, Never>?
    private var fileURL: URL?
    private var projectRootURL: URL?

    var onDiagnostics: (([LSPDiagnostic]) -> Void)?

    func open(url: URL, text: String, fileExtension: String) {
        diagnosticsTask?.cancel()
        diagnosticsTask = nil
        fileURL = url

        let settings = SessionCoordinator.shared.settings
        let lspSettings = LSPSettings(autoStart: settings.lspAutoStart, servers: settings.lspServers)
        guard let configuration = registry.configuration(forFile: url, settings: lspSettings) else {
            client = nil
            onDiagnostics?([])
            return
        }
        projectRootURL = configuration.rootURL

        let languageID = languageID(for: fileExtension, fallback: configuration.language)
        let newClient = LSPClient()
        client = newClient
        diagnosticsTask = Task { [weak self, newClient] in
            do {
                try await newClient.launch(configuration: configuration)
                try await newClient.initialize(rootURL: configuration.rootURL)
                try await newClient.openDocument(url: url, languageID: languageID, text: text)
                await self?.consumeDiagnostics(from: newClient, matching: url)
            } catch {
                await MainActor.run { [weak self] in
                    self?.onDiagnostics?([])
                }
            }
        }
    }

    func close() {
        diagnosticsTask?.cancel()
        diagnosticsTask = nil
        let client = client
        self.client = nil
        Task { await client?.shutdown() }
    }

    func hover(position: LSPPosition) async -> String? {
        guard let client, let fileURL else { return nil }
        let text = try? await client.hover(url: fileURL, position: position)?.plainText
        guard let graphLine = graphifyAnnotation() else { return text }
        guard let text, !text.isEmpty else { return graphLine }
        return "\(text)\n\n\(graphLine)"
    }

    /// One-line file-level graph signal (pagerank/community), appended to hover text when the
    /// project has a `graphify-out/graph.json`. File-level only — `graph.json`'s nodes are
    /// per-file, not per-symbol, so this is the same regardless of what's under the cursor.
    private func graphifyAnnotation() -> String? {
        guard let fileURL, let projectRootURL else { return nil }
        let rootPath = projectRootURL.standardizedFileURL.path
        let filePath = fileURL.standardizedFileURL.path
        guard filePath.hasPrefix(rootPath + "/") else { return nil }
        let relativePath = String(filePath.dropFirst(rootPath.count + 1))
        guard let info = GraphifyLSPBridge.lookupFileInfo(sourceFile: relativePath, projectRoot: projectRootURL)
        else { return nil }
        return "Graphify: pagerank \(String(format: "%.5f", info.pagerank)) · community \(info.community)"
    }

    func definition(position: LSPPosition) async -> SyntaxDefinitionTarget? {
        guard let client, let fileURL else { return nil }
        guard let location = try? await client.definition(url: fileURL, position: position).first else { return nil }
        guard let url = URL(string: location.uri), url.isFileURL else { return nil }
        return SyntaxDefinitionTarget(
            url: url,
            line: location.range.start.line + 1,
            column: location.range.start.character + 1
        )
    }

    private func consumeDiagnostics(from client: LSPClient, matching url: URL) async {
        for await message in await client.incomingMessages {
            guard !Task.isCancelled else { return }
            guard case let .notification(method, params) = message, method == "textDocument/publishDiagnostics" else { continue }
            guard let diagnostics = Self.decodeDiagnostics(from: params, matching: url) else { continue }
            await MainActor.run { [weak self] in
                self?.onDiagnostics?(diagnostics)
            }
        }
    }

    private static func decodeDiagnostics(from params: AnyCodable?, matching url: URL) -> [LSPDiagnostic]? {
        guard case let .object(object)? = params,
              case let .string(uri)? = object["uri"],
              uri == url.absoluteString,
              let rawDiagnostics = object["diagnostics"]
        else { return nil }
        guard let data = try? JSONEncoder().encode(rawDiagnostics) else { return nil }
        return try? JSONDecoder().decode([LSPDiagnostic].self, from: data)
    }

    private func languageID(for ext: String, fallback: String) -> String {
        switch ext.lowercased() {
        case "swift": return "swift"
        case "py": return "python"
        case "ts", "tsx": return "typescript"
        case "js", "jsx": return "javascript"
        case "rs": return "rust"
        case "go": return "go"
        default: return fallback
        }
    }
}
