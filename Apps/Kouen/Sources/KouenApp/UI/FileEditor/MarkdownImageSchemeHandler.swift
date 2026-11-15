import Foundation
import UniformTypeIdentifiers
import WebKit

/// Grants image reads only beneath the current document's directory, without file-origin scripting.
@MainActor
final class MarkdownImageSchemeHandler: NSObject, WKURLSchemeHandler {
    nonisolated static let scheme = "kouen-markdown"
    var directory: URL?
    private var pending: [ObjectIdentifier: Task<Void, Never>] = [:]

    nonisolated static func imageResource(for url: URL, directory: URL?) throws -> (Data, URLResponse) {
        guard url.scheme == Self.scheme, url.host == "local", let directory else {
            throw URLError(.noPermissionsToReadFile)
        }
        let root = directory.resolvingSymlinksInPath().standardizedFileURL
        let file = URL(fileURLWithPath: url.path).resolvingSymlinksInPath().standardizedFileURL
        guard file.path.hasPrefix(root.path.hasSuffix("/") ? root.path : root.path + "/"),
              let type = UTType(filenameExtension: file.pathExtension), type.conforms(to: .image),
              let mime = type.preferredMIMEType else { throw URLError(.noPermissionsToReadFile) }
        let attributes = try FileManager.default.attributesOfItem(atPath: file.path)
        guard let size = attributes[.size] as? NSNumber, size.intValue <= 16 * 1024 * 1024 else {
            throw URLError(.dataLengthExceedsMaximum)
        }
        let data = try Data(contentsOf: file)
        return (data, URLResponse(url: url, mimeType: mime, expectedContentLength: data.count, textEncodingName: nil))
    }

    func webView(_ webView: WKWebView, start urlSchemeTask: any WKURLSchemeTask) {
        let key = ObjectIdentifier(urlSchemeTask)
        let directory = directory
        let url = urlSchemeTask.request.url
        pending[key] = Task {
            let result = await Task.detached(priority: .utility) {
                Result {
                    guard let url else { throw URLError(.badURL) }
                    return try Self.imageResource(for: url, directory: directory)
                }
            }.value
            guard !Task.isCancelled else { return }
            pending.removeValue(forKey: key)
            switch result {
            case let .success((data, response)):
                urlSchemeTask.didReceive(response)
                urlSchemeTask.didReceive(data)
                urlSchemeTask.didFinish()
            case let .failure(error):
                urlSchemeTask.didFailWithError(error)
            }
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: any WKURLSchemeTask) {
        pending.removeValue(forKey: ObjectIdentifier(urlSchemeTask))?.cancel()
    }
}
