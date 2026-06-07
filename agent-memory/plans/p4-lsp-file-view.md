# P4 — LSP + File View (Code Preview in Sidebar)

Status: **planned**  
Priority: **P1** — new feature  
Depends on: none (sidebar infrastructure exists)  

---

## Goal

Click a file in the sidebar file tree → preview its content with syntax highlighting.  
Optionally connect to a running LSP server for go-to-definition, hover, diagnostics.

## Architecture

```
Sidebar File Tree (existing WorkspaceFileTreeView)
  └─ Click file → FileViewerViewController (new)
       ├─ Track 1: Native NSTextView + TreeSitter highlighting (fast, no dependencies)
       ├─ Track 2: QLPreviewView for images/PDFs (Quick Look)
       └─ Track 3: LSP client for diagnostics/hover/goto (optional, progressive)
```

## Track 1 — Syntax-Highlighted File Viewer (MVP)

### Components
- `FileViewerViewController` — replaces file tree when file is selected, back button returns to tree
- `SyntaxTextView` — NSTextView subclass with TreeSitter grammar highlighting
- TreeSitter grammars: Swift, Python, TypeScript, JavaScript, JSON, YAML, Markdown, Rust, Go

### Steps
1. Add `FileViewerViewController` to sidebar, triggered by file tree click
2. Read file content (< 1MB guard, show "file too large" for bigger)
3. Apply TreeSitter highlighting via bundled grammars
4. Line numbers gutter
5. Read-only (no editing — terminal is the editor)
6. Copy selection, Cmd+A select all
7. Back button / Escape returns to file tree

### Grammars
Bundle as SPM resources (`tree-sitter-swift`, `tree-sitter-typescript`, etc.) — ~2MB total.

## Track 2 — Quick Look Preview

For non-code files (images, PDFs, rich documents):
- Use `QLPreviewView` embedded in the same `FileViewerViewController`
- Route by MIME type: code → SyntaxTextView, image/pdf → QLPreviewView

## Track 3 — LSP Integration (Post-MVP)

### Architecture
```
LSPClient (new, Packages/HarnessLSP/)
  ├─ Connects to running LSP server (sourcekit-lsp, tsserver, pyright, etc.)
  ├─ JSON-RPC over stdio pipe
  └─ Provides: diagnostics, hover, go-to-definition, symbol outline

FileViewerViewController
  └─ Subscribes to LSPClient for:
       - Inline diagnostics (red/yellow underlines)
       - Hover popup on mouse-over
       - Cmd+Click → go-to-definition (open that file)
       - Outline panel (document symbols)
```

### LSP Discovery
- Detect project type from root files (Package.swift → sourcekit-lsp, package.json → tsserver)
- Auto-start LSP server as child process (or reuse running one)
- Settings: `lsp.autoStart`, `lsp.servers` (custom binary paths)

### Steps
1. `LSPClient` — JSON-RPC stdio transport, initialize/shutdown lifecycle
2. `LSPServerRegistry` — auto-detect + launch LSP per project type
3. Wire diagnostics to SyntaxTextView (underlines + gutter markers)
4. Hover provider → popover with type info
5. Go-to-definition → navigate FileViewerViewController to target file:line

## Files

| File | Purpose |
|------|---------|
| `Apps/Harness/Sources/HarnessApp/UI/FileViewerViewController.swift` | New — file preview controller |
| `Apps/Harness/Sources/HarnessApp/UI/SyntaxTextView.swift` | New — highlighted text view |
| `Packages/HarnessLSP/` | New package — LSP client |
| `Apps/Harness/Sources/HarnessApp/UI/WorkspaceFileTreeView.swift` | Modify — route clicks to viewer |

## Estimate

- Track 1 (syntax viewer): 1–2 sessions
- Track 2 (Quick Look): 0.5 session
- Track 3 (LSP): 3–4 sessions
