---
name: kouen-file-open
description: Kouen does not open a file — cmd+click on a filename in terminal output does nothing, a file type shows blank or opens in the wrong viewer. Use for "กด cmd+click แล้วไม่ขึ้น", "เปิดไฟล์ .xxx ไม่ได้", "file preview blank", "add support for .ext".
version: 0.1.0
origin: auto-captured
created: 2026-10-16
last_improved: 2026-10-16
---

# Kouen: why a file does not open

Ask first how it was opened — there are three separate paths:

1. **cmd+click in terminal output** → `URLDetection.detectFilePath` (`Packages/KouenTerminalEngine/.../URLDetection.swift`). A bare filename (no `/`) is a link only if its extension is in `knownFileExtensions`; a missing extension means cmd+click silently does nothing. Paths with `/` always match.
2. **File explorer / sidebar** → `FileViewRouting.usesQuickLook(ext:)`, shared by `FileEditorView` and `FileViewerViewController`: text/code → editor (language map in `MarkdownPreviewView.codeExtensionToLanguage`), images/PDF/office/RAW → QuickLook. The user override `quicklook-extensions.json` (app support) still wins.
3. **Finder "Open With" / external open** → `ExternalOpenKind`.

Adding a file type usually touches 1 and 2.

## Check it worked
- `swift test --filter "EngineConformanceTests/testDetectFilePath"` (path 1) and `FileEditorViewQuickLookRoutingTests` (path 2) — write the failing case first.
- `make preview`, then cmd+click the bare filename in a terminal pane of KouenPreview.
