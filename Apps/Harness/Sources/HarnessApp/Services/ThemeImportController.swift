import AppKit
import HarnessCore
import HarnessTheme

/// How an externally-opened URL should be handled. Pure classification so the routing
/// decision in `AppDelegate.enqueueExternalOpen` is unit-testable without AppKit state.
enum ExternalOpenKind: Equatable {
    /// A `.harnesstheme` document — import + install + offer to apply.
    case theme
    /// Directories, shell scripts, executables, and non-file URLs open in a terminal session.
    case terminal
    /// Regular source/text files open in the sidebar file viewer.
    case filePreview

    // Shell-script extensions that should open in a terminal, not the viewer.
    private static let shellExtensions: Set<String> = [
        "command", "tool", "sh", "zsh", "bash", "csh", "ksh", "fish",
    ]

    init(for url: URL) {
        guard url.isFileURL else { self = .terminal; return }
        let ext = url.pathExtension.lowercased()
        if ext == ThemeDocument.fileExtension { self = .theme; return }
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        if isDir.boolValue || Self.shellExtensions.contains(ext) { self = .terminal; return }
        self = .filePreview
    }
}

/// Imports `.harnesstheme` files opened from the Finder (double-click / "Open With Harness").
/// Reads + validates the document, installs it into the user's themes folder for re-sharing,
/// then offers to apply it. Parse failures surface as a loud alert instead of silently doing
/// nothing — the old behavior routed theme files through the shell-script opener.
@MainActor
enum ThemeImportController {
    private static let fileService = ThemeFileService()

    /// Handle one opened theme file end-to-end.
    static func handle(_ url: URL) {
        let document: ThemeDocument
        do {
            document = try fileService.importTheme(from: url)
        } catch {
            presentFailure(url: url, error: error)
            return
        }

        switch presentInstallChoice(for: document) {
        case .cancel:
            return
        case .install:
            install(document)
        case .installAndApply:
            install(document)
            SessionCoordinator.shared.applyImportedTheme(document)
        }
    }

    private enum InstallChoice {
        case install
        case installAndApply
        case cancel
    }

    /// Persist the document into the user's themes folder so it survives relaunch and can be
    /// re-exported/shared. A write failure is non-fatal — the theme can still be applied in-memory.
    private static func install(_ document: ThemeDocument) {
        _ = try? fileService.install(document, into: HarnessPaths.themesDirectory)
    }

    private static func presentInstallChoice(for document: ThemeDocument) -> InstallChoice {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Install theme “\(document.name)”?"
        var info = "Add this theme to Harness."
        if let author = document.author, !author.isEmpty {
            info += " By \(author)."
        }
        alert.informativeText = info
        // First button is the default (return-key) action; order them install / apply / cancel.
        alert.addButton(withTitle: "Install")
        alert.addButton(withTitle: "Install and Apply")
        alert.addButton(withTitle: "Cancel")
        switch alert.runModal() {
        case .alertFirstButtonReturn: return .install
        case .alertSecondButtonReturn: return .installAndApply
        default: return .cancel
        }
    }

    private static func presentFailure(url: URL, error: Error) {
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = "Couldn’t open theme “\(url.lastPathComponent)”"
        alert.informativeText = describe(error)
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    /// Human-readable text for the theme parse/validation errors so the alert is actionable.
    private static func describe(_ error: Error) -> String {
        guard let error = error as? ThemeDocumentError else {
            return (error as NSError).localizedDescription
        }
        switch error {
        case let .unsupportedVersion(version):
            return "This theme uses format version \(version), which this version of Harness can’t read. Update Harness and try again."
        case .emptyName:
            return "The theme file is missing a name."
        case let .wrongPaletteCount(count):
            return "The theme has \(count) ANSI colors but exactly 16 are required."
        case let .malformed(detail):
            return "The theme file isn’t valid: \(detail)"
        }
    }
}
