import Foundation
import UniformTypeIdentifiers

/// Single routing point for "Quick Look vs text editor", shared by `FileEditorView` and
/// `FileViewerViewController` (they used to carry diverging hard-coded lists).
enum FileViewRouting {
    /// Text-like formats Quick Look would otherwise claim (csv is a spreadsheet UTType) —
    /// these stay in the editor so they are copyable/searchable. `gs` (Apps Script) has no
    /// system UTType; it is JavaScript and highlighted via `codeExtensionToLanguage`.
    private static let textExtensions: Set<String> = ["csv", "tsv", "gs"]

    /// Formats UTType lookup can't resolve on every macOS version.
    private static let explicitQuickLook: Set<String> = [
        "raw", "heif", "heic", "dng", "cr2", "cr3", "nef", "arw", "raf", "orf", "rw2",
        "rtf", "rtfd", "doc", "docx", "pages", "key", "keynote", "numbers", "xls", "xlsx",
        "ppt", "pptx", "epub",
    ]

    static func usesQuickLook(ext rawExt: String) -> Bool {
        let ext = rawExt.lowercased()
        if ext.isEmpty || textExtensions.contains(ext) { return false }
        if explicitQuickLook.contains(ext) { return true }
        guard let type = UTType(filenameExtension: ext) else { return false }
        // svg is XML text but was always rendered, keep it that way.
        return type.conforms(to: .image) || type.conforms(to: .pdf)
    }
}
