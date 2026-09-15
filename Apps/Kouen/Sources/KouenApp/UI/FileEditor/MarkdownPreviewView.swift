import AppKit
import WebKit
import KouenCore
import KouenSyntaxResources

/// Full-featured Markdown and Mermaid preview view backed by WKWebView.
/// Uses bundled offline Marked.js, Highlight.js, and Mermaid.js.
@MainActor
final class MarkdownPreviewView: NSView, WKNavigationDelegate {
    private let webView: WKWebView
    private var isWebViewReady = false
    private var pendingMarkdown: String?
    private var currentFileURL: URL?
    private var currentMarkdown: String = ""

    /// Callback when user clicks a relative file link inside markdown
    var onOpenFile: ((String) -> Void)?

    private static let cachedUserScripts: [WKUserScript] = {
        var scripts: [WKUserScript] = []
        for name in ["marked.min.js", "highlight.min.js", "mermaid.min.js"] {
            if let code = MarkdownBundle.scriptString(filename: name) {
                scripts.append(WKUserScript(source: code, injectionTime: .atDocumentStart, forMainFrameOnly: true))
            }
        }
        return scripts
    }()

    override init(frame frameRect: NSRect) {
        let config = WKWebViewConfiguration()
        let userController = WKUserContentController()
        for script in Self.cachedUserScripts {
            userController.addUserScript(script)
        }
        config.userContentController = userController
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        self.webView = WKWebView(frame: frameRect, configuration: config)
        super.init(frame: frameRect)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = .clear

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.setValue(false, forKey: "drawsBackground")
        if #available(macOS 12.0, *) {
            webView.underPageBackgroundColor = .clear
        }

        addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    public static let codeExtensionToLanguage: [String: String] = [
        // Swift / Apple
        "swift": "swift", "m": "objectivec", "mm": "objectivec",
        // Web & Script
        "js": "javascript", "mjs": "javascript", "cjs": "javascript", "jsx": "javascript",
        "ts": "typescript", "mts": "typescript", "cts": "typescript", "tsx": "typescript",
        "html": "xml", "htm": "xml", "xml": "xml", "svg": "xml", "plist": "xml",
        "css": "css", "scss": "scss", "sass": "scss", "less": "less",
        // Systems & Compiled
        "c": "c", "h": "c", "cpp": "cpp", "hpp": "cpp", "cc": "cpp", "cxx": "cpp",
        "rs": "rust", "go": "go", "cs": "csharp", "java": "java", "kt": "kotlin", "kts": "kotlin",
        "wasm": "wasm",
        // Scripting & Data
        "py": "python", "pyw": "python", "rb": "ruby", "php": "php", "lua": "lua",
        "pl": "perl", "r": "r", "sh": "bash", "bash": "bash", "zsh": "bash", "fish": "bash",
        // Config & Query
        "json": "json", "jsonc": "json", "json5": "json",
        "yaml": "yaml", "yml": "yaml", "toml": "ini", "ini": "ini", "conf": "ini", "env": "ini",
        "sql": "sql", "pgsql": "sql", "psql": "sql", "mysql": "sql", "plsql": "sql", "pls": "sql",
        "graphql": "graphql", "gql": "graphql",
        "makefile": "makefile", "make": "makefile", "mk": "makefile",
        "diff": "diff", "patch": "diff",
        // Mobile & containers
        "dart": "dart", "dockerfile": "dockerfile"
    ]

    public static func isSupportedCodeExtension(_ ext: String) -> Bool {
        codeExtensionToLanguage[ext.lowercased()] != nil
    }

    public static func isRichPreviewExtension(_ ext: String) -> Bool {
        let lower = ext.lowercased()
        return ["md", "markdown", "mermaid", "mmd"].contains(lower)
    }

    /// `Dockerfile`, `Dockerfile.dev`, `Dockerfile.prod`, etc. carry the language in the bare
    /// filename, not a `.dockerfile` extension — `pathExtension` alone misses them.
    private static func filenameLanguage(_ fileName: String) -> String? {
        let lower = fileName.lowercased()
        return (lower == "dockerfile" || lower.hasPrefix("dockerfile.")) ? "dockerfile" : nil
    }

    /// The highlight.js language for `url`, checking filename-based conventions (Dockerfile)
    /// before falling back to `codeExtensionToLanguage`. Public API for callers that only have
    /// a file URL — `isSupportedCodeExtension`/`codeExtensionToLanguage` stay extension-only.
    public static func language(forFile url: URL) -> String? {
        filenameLanguage(url.lastPathComponent) ?? codeExtensionToLanguage[url.pathExtension.lowercased()]
    }

    public static func isSupportedCodeFile(_ url: URL) -> Bool {
        language(forFile: url) != nil
    }

    // MARK: - API

    static func wrapContentIfNeeded(_ raw: String, fileURL: URL?) -> String {
        guard let fileURL else { return raw }
        let ext = fileURL.pathExtension.lowercased()
        if ext == "mermaid" || ext == "mmd" {
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.hasPrefix("```") {
                return "```mermaid\n\(raw)\n```"
            }
        }
        if let lang = Self.language(forFile: fileURL) {
            let fence = String(repeating: "`", count: Self.fenceLength(for: raw))
            return "\(fence)\(lang)\n\(raw)\n\(fence)"
        }
        return raw
    }

    /// A fenced code block only closes at a run of backticks >= the opener's length (CommonMark).
    /// A hardcoded ``` breaks on any source file containing its own ``` run (docstrings,
    /// markdown-in-comments, heredocs) — use one longer than the longest run already in `raw`.
    private static func fenceLength(for raw: String) -> Int {
        var longestRun = 0
        var currentRun = 0
        for char in raw {
            if char == "`" {
                currentRun += 1
                longestRun = max(longestRun, currentRun)
            } else {
                currentRun = 0
            }
        }
        return max(3, longestRun + 1)
    }

    func load(markdown: String, fileURL: URL?) {
        let effectiveMarkdown = Self.wrapContentIfNeeded(markdown, fileURL: fileURL)
        currentMarkdown = effectiveMarkdown
        currentFileURL = fileURL
        isWebViewReady = false
        pendingMarkdown = nil

        let isDark = isAppearanceDark
        let html = generateHTML(markdown: effectiveMarkdown, isDark: isDark)
        let baseURL = fileURL?.deletingLastPathComponent() ?? URL(fileURLWithPath: NSHomeDirectory())
        webView.loadHTMLString(html, baseURL: baseURL)
    }

    func update(markdown: String) {
        let effectiveMarkdown = Self.wrapContentIfNeeded(markdown, fileURL: currentFileURL)
        currentMarkdown = effectiveMarkdown
        guard isWebViewReady else {
            pendingMarkdown = effectiveMarkdown
            return
        }

        guard let encoded = try? JSONEncoder().encode(effectiveMarkdown),
              let jsonString = String(data: encoded, encoding: .utf8) else { return }

        let js = "window.renderMarkdown && window.renderMarkdown(\(jsonString));"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        let isDark = isAppearanceDark
        let js = "window.setDarkMode && window.setDarkMode(\(isDark));"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    @objc func copy(_ sender: Any?) {
        NSApp.sendAction(#selector(NSText.copy(_:)), to: webView, from: sender)
    }

    override var acceptsFirstResponder: Bool { true }

    private var isAppearanceDark: Bool {
        if #available(macOS 11.0, *) {
            return effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        }
        return true
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isWebViewReady = true
        let textToRender = pendingMarkdown ?? currentMarkdown
        pendingMarkdown = nil
        if !textToRender.isEmpty {
            guard let encoded = try? JSONEncoder().encode(textToRender),
                  let jsonString = String(data: encoded, encoding: .utf8) else { return }
            let js = "if (window.renderMarkdown) { window.renderMarkdown(\(jsonString)); }"
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        guard navigationAction.navigationType == .linkActivated,
              let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // Intra-document anchor link (#section)
        if let fragment = url.fragment, !fragment.isEmpty,
           url.path == currentFileURL?.path || url.path.isEmpty || url.absoluteString.hasPrefix("about:") {
            decisionHandler(.allow)
            return
        }

        // Web links
        if url.scheme == "http" || url.scheme == "https" {
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        // Local file link
        if url.scheme == "file" {
            if let onOpenFile {
                onOpenFile(url.path)
                decisionHandler(.cancel)
                return
            }
        }

        decisionHandler(.allow)
    }

    // MARK: - HTML Template

    private func generateHTML(markdown: String, isDark: Bool) -> String {
        let encodedMarkdown: String
        if let data = try? JSONEncoder().encode(markdown),
           let json = String(data: data, encoding: .utf8) {
            encodedMarkdown = json
        } else {
            encodedMarkdown = "\"\""
        }

        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            :root {
              --font-body: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Segoe UI", Helvetica, Arial, sans-serif;
              --font-mono: ui-monospace, "SF Mono", Menlo, Monaco, Consolas, monospace;
              --bg-color: \(isDark ? "#161618" : "#ffffff");
              --text-primary: \(isDark ? "#e6edf3" : "#1f2328");
              --text-secondary: \(isDark ? "#8b949e" : "#656d76");
              --text-muted: \(isDark ? "#6e7681" : "#8c959f");
              --border-color: \(isDark ? "rgba(255, 255, 255, 0.12)" : "#d0d7de");
              --code-bg: \(isDark ? "rgba(255, 255, 255, 0.05)" : "#f6f8fa");
              --code-header-bg: \(isDark ? "rgba(255, 255, 255, 0.08)" : "#eaecf0");
              --blockquote-border: \(isDark ? "#e06c75" : "#0969da");
              --blockquote-bg: \(isDark ? "rgba(224, 108, 117, 0.06)" : "#f6f8fa");
              --table-zebra: \(isDark ? "rgba(255, 255, 255, 0.02)" : "#f6f8fa");
              --table-border: \(isDark ? "rgba(255, 255, 255, 0.1)" : "#d0d7de");
              --link-color: \(isDark ? "#58a6ff" : "#0969da");
              --accent-color: \(isDark ? "#e06c75" : "#0969da");
            }

            body.light {
              --bg-color: #ffffff;
              --text-primary: #1f2328;
              --text-secondary: #656d76;
              --text-muted: #8c959f;
              --border-color: #d0d7de;
              --code-bg: #f6f8fa;
              --code-header-bg: #eaecf0;
              --blockquote-border: #0969da;
              --blockquote-bg: #f6f8fa;
              --table-zebra: #f6f8fa;
              --table-border: #d0d7de;
              --link-color: #0969da;
              --accent-color: #0969da;
            }

            body.dark {
              --bg-color: #161618;
              --text-primary: #e6edf3;
              --text-secondary: #8b949e;
              --text-muted: #6e7681;
              --border-color: rgba(255, 255, 255, 0.12);
              --code-bg: rgba(255, 255, 255, 0.05);
              --code-header-bg: rgba(255, 255, 255, 0.08);
              --blockquote-border: #e06c75;
              --blockquote-bg: rgba(224, 108, 117, 0.06);
              --table-zebra: rgba(255, 255, 255, 0.02);
              --table-border: rgba(255, 255, 255, 0.1);
              --link-color: #58a6ff;
              --accent-color: #e06c75;
            }

            * { box-sizing: border-box; }
            html, body {
              margin: 0;
              padding: 0;
              background-color: var(--bg-color);
              color: var(--text-primary);
              font-family: var(--font-body);
              font-size: 14px;
              line-height: 1.6;
              -webkit-font-smoothing: antialiased;
            }

            .markdown-body {
              max-width: 900px;
              margin: 0 auto;
              padding: 24px 28px;
            }

            h1, h2, h3, h4, h5, h6 {
              margin-top: 24px;
              margin-bottom: 12px;
              font-weight: 600;
              line-height: 1.25;
              color: var(--text-primary);
            }
            h1 { font-size: 26px; padding-bottom: 8px; border-bottom: 1px solid var(--border-color); margin-top: 8px; }
            h2 { font-size: 20px; padding-bottom: 6px; border-bottom: 1px solid var(--border-color); }
            h3 { font-size: 16px; }
            h4 { font-size: 14px; }
            h5 { font-size: 13px; }
            h6 { font-size: 12px; color: var(--text-muted); }

            p { margin: 0 0 14px 0; }
            a { color: var(--link-color); text-decoration: none; }
            a:hover { text-decoration: underline; }

            strong { font-weight: 600; }
            em { font-style: italic; }
            del { text-decoration: line-through; opacity: 0.8; }
            hr { border: 0; height: 1px; background-color: var(--border-color); margin: 24px 0; }

            ul, ol { padding-left: 24px; margin: 0 0 14px 0; }
            li { margin: 4px 0; }
            li.task-list-item { list-style-type: none; margin-left: -20px; }
            input[type="checkbox"] {
              vertical-align: middle;
              margin-right: 6px;
              accent-color: var(--accent-color);
            }

            blockquote {
              margin: 14px 0;
              padding: 8px 16px;
              border-left: 4px solid var(--blockquote-border);
              background: var(--blockquote-bg);
              color: var(--text-secondary);
              border-radius: 0 6px 6px 0;
            }
            blockquote p:last-child { margin-bottom: 0; }

            /* GitHub Alert Callouts */
            .markdown-alert {
              margin: 16px 0;
              padding: 10px 14px;
              border-left: 4px solid #58a6ff;
              border-radius: 0 6px 6px 0;
              background: var(--code-bg);
            }
            .markdown-alert-title {
              font-weight: 600;
              font-size: 13px;
              margin-bottom: 4px;
              display: flex;
              align-items: center;
              gap: 6px;
            }
            .markdown-alert-note { border-color: #58a6ff; }
            .markdown-alert-note .markdown-alert-title { color: #58a6ff; }
            .markdown-alert-tip { border-color: #3fb950; }
            .markdown-alert-tip .markdown-alert-title { color: #3fb950; }
            .markdown-alert-important { border-color: #a371f7; }
            .markdown-alert-important .markdown-alert-title { color: #a371f7; }
            .markdown-alert-warning { border-color: #d29922; }
            .markdown-alert-warning .markdown-alert-title { color: #d29922; }
            .markdown-alert-caution { border-color: #f85149; }
            .markdown-alert-caution .markdown-alert-title { color: #f85149; }

            /* Inline code */
            code {
              font-family: var(--font-mono);
              font-size: 0.88em;
              padding: 2px 5px;
              border-radius: 4px;
              background-color: var(--code-bg);
              border: 1px solid var(--border-color);
            }

            /* Code containers */
            .code-container {
              margin: 16px 0;
              border: 1px solid var(--border-color);
              border-radius: 8px;
              background-color: var(--code-bg);
              overflow: hidden;
            }
            .code-header {
              display: flex;
              justify-content: space-between;
              align-items: center;
              padding: 6px 14px;
              background-color: var(--code-header-bg);
              border-bottom: 1px solid var(--border-color);
              font-family: var(--font-mono);
              font-size: 11px;
              color: var(--text-secondary);
            }
            .copy-btn {
              background: transparent;
              border: 1px solid var(--border-color);
              border-radius: 4px;
              color: var(--text-secondary);
              font-family: var(--font-mono);
              font-size: 11px;
              padding: 2px 8px;
              cursor: pointer;
              transition: all 0.15s ease;
            }
            .copy-btn:hover {
              background: var(--border-color);
              color: var(--text-primary);
            }
            .code-with-lines {
              display: flex;
              align-items: stretch;
              background-color: var(--code-bg);
            }
            .line-numbers-pre {
              margin: 0;
              padding: 12px 10px 12px 14px;
              font-family: var(--font-mono);
              font-size: 12.5px;
              line-height: 1.5;
              color: var(--text-muted);
              user-select: none;
              -webkit-user-select: none;
              text-align: right;
              border-right: 1px solid var(--border-color);
              background-color: var(--code-header-bg);
              opacity: 0.55;
              white-space: pre;
              flex-shrink: 0;
            }
            .code-with-lines pre.code-pre {
              flex: 1;
              margin: 0;
              padding: 12px 14px;
              overflow-x: auto;
              font-family: var(--font-mono);
              font-size: 12.5px;
              line-height: 1.5;
              white-space: pre;
            }
            .code-with-lines pre.code-pre code {
              background: transparent;
              border: none;
              padding: 0;
              font-size: inherit;
              white-space: pre;
            }
            pre {
              margin: 0;
              padding: 12px 14px;
              overflow-x: auto;
              font-family: var(--font-mono);
              font-size: 12.5px;
              line-height: 1.5;
            }
            pre code {
              background: transparent;
              border: none;
              padding: 0;
              font-size: inherit;
            }

            /* Tables */
            table {
              border-collapse: collapse;
              width: 100%;
              margin: 16px 0;
              display: block;
              overflow-x: auto;
            }
            th, td {
              border: 1px solid var(--table-border);
              padding: 8px 14px;
              font-size: 13.5px;
            }
            th {
              background-color: var(--code-header-bg);
              font-weight: 600;
              text-align: left;
            }
            tr:nth-child(even) {
              background-color: var(--table-zebra);
            }

            /* Images */
            img {
              max-width: 100%;
              height: auto;
              border-radius: 6px;
              margin: 8px 0;
            }

            /* Mermaid */
            .mermaid-wrap {
              margin: 20px 0;
              padding: 18px;
              border: 1px solid var(--border-color);
              border-radius: 8px;
              background-color: var(--code-bg);
              overflow-x: auto;
              display: flex;
              justify-content: center;
              align-items: center;
            }
            .mermaid {
              display: flex;
              justify-content: center;
              width: 100%;
            }
            .mermaid svg {
              max-width: 100%;
              height: auto;
            }
            .mermaid-error {
              padding: 12px;
              background: rgba(224, 108, 117, 0.1);
              border: 1px solid #e06c75;
              border-radius: 6px;
              color: #e06c75;
              font-family: var(--font-mono);
              font-size: 12px;
              width: 100%;
            }
            .mermaid-error-title {
              font-weight: 600;
              margin-bottom: 6px;
            }
          </style>
        </head>
        <body class="\(isDark ? "dark" : "light")">
          <div id="content" class="markdown-body"></div>

          <script>
            window.isDarkMode = \(isDark ? "true" : "false");

            function escapeHtml(str) {
              return String(str).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
            }

            let librariesConfigured = false;
            function setupLibraries() {
              if (librariesConfigured) return;
              if (typeof mermaid !== 'undefined') {
                mermaid.initialize({
                  startOnLoad: false,
                  theme: window.isDarkMode ? 'dark' : 'default',
                  securityLevel: 'loose',
                  fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif'
                });
              }

              if (typeof marked !== 'undefined') {
                marked.use({
                  gfm: true,
                  breaks: true,
                  renderer: {
                    code({ text, lang }) {
                      if (lang === 'mermaid') {
                        return `<div class="mermaid-wrap"><div class="mermaid">${escapeHtml(text)}</div></div>`;
                      }
                      let highlighted = text;
                      if (typeof hljs !== 'undefined') {
                        if (lang && hljs.getLanguage(lang)) {
                          try {
                            highlighted = hljs.highlight(text, { language: lang, ignoreIllegals: true }).value;
                          } catch (e) {
                            highlighted = escapeHtml(text);
                          }
                        } else {
                          try {
                            highlighted = hljs.highlightAuto(text).value;
                          } catch (e) {
                            highlighted = escapeHtml(text);
                          }
                        }
                      } else {
                        highlighted = escapeHtml(text);
                      }
                      const langLabel = lang || 'text';
                      const rawLines = text.split('\n');
                      if (rawLines.length > 1 && rawLines[rawLines.length - 1] === '') rawLines.pop();
                      let codeBodyHtml = '';
                      if (rawLines.length > 1) {
                        const lineNums = rawLines.map((_, i) => i + 1).join('\n');
                        codeBodyHtml = `<div class="code-with-lines"><pre class="line-numbers-pre">${lineNums}</pre><pre class="code-pre"><code class="hljs ${lang ? 'language-' + escapeHtml(lang) : ''}">${highlighted}</code></pre></div>`;
                      } else {
                        codeBodyHtml = `<div class="code-with-lines"><pre class="code-pre"><code class="hljs ${lang ? 'language-' + escapeHtml(lang) : ''}">${highlighted}</code></pre></div>`;
                      }
                      return `<div class="code-container"><div class="code-header"><span class="code-lang">${escapeHtml(langLabel)}</span><button class="copy-btn" onclick="copyCode(this)">Copy</button></div>${codeBodyHtml}</div>`;
                    }
                  }
                });
                librariesConfigured = true;
              }
            }

            function processAlerts(html) {
              return html.replace(/<blockquote>\\s*<p>\\s*\\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\\]\\s*<br>([\\s\\S]*?)<\\/blockquote>/gi, (match, type, content) => {
                const t = type.toUpperCase();
                const icons = { NOTE: 'ℹ️', TIP: '💡', IMPORTANT: '❗', WARNING: '⚠️', CAUTION: '🛑' };
                return `<div class="markdown-alert markdown-alert-${t.toLowerCase()}"><div class="markdown-alert-title"><span>${icons[t] || 'ℹ️'}</span> ${t}</div><div class="markdown-alert-body"><p>${content}</div></div>`;
              });
            }

            let diagramCounter = 0;
            async function renderMermaidDiagrams() {
              if (typeof mermaid === 'undefined') return;
              const nodes = document.querySelectorAll('.mermaid:not([data-processed="true"])');
              for (const node of nodes) {
                node.setAttribute('data-processed', 'true');
                const code = node.textContent;
                const id = 'mermaid-diag-' + (++diagramCounter);
                try {
                  const { svg } = await mermaid.render(id, code);
                  node.innerHTML = svg;
                } catch (err) {
                  node.innerHTML = `<div class="mermaid-error"><div class="mermaid-error-title">⚠️ Mermaid Syntax Error</div><pre>${escapeHtml(err.message || String(err))}</pre></div>`;
                  const tempEl = document.getElementById('d' + id);
                  if (tempEl) tempEl.remove();
                }
              }
            }

            window.copyCode = function(button) {
              const container = button.closest('.code-container');
              const codeEl = container.querySelector('pre.code-pre code') || container.querySelector('code');
              if (codeEl) {
                const text = codeEl.innerText || codeEl.textContent;
                navigator.clipboard.writeText(text).then(() => {
                  button.textContent = 'Copied!';
                  setTimeout(() => { button.textContent = 'Copy'; }, 2000);
                });
              }
            };

            window.setDarkMode = function(isDark) {
              window.isDarkMode = isDark;
              document.body.className = isDark ? 'dark' : 'light';
              if (typeof mermaid !== 'undefined') {
                mermaid.initialize({
                  startOnLoad: false,
                  theme: isDark ? 'dark' : 'default',
                  securityLevel: 'loose'
                });
              }
            };

            window.renderMarkdown = async function(rawMarkdown) {
              setupLibraries();
              const contentEl = document.getElementById('content');
              if (!contentEl) return;
              if (!rawMarkdown) {
                contentEl.innerHTML = '';
                return;
              }
              if (typeof marked === 'undefined') {
                contentEl.innerHTML = '<pre style="padding:16px;white-space:pre-wrap;font-family:var(--font-mono);font-size:13px;color:var(--text-primary);">' + escapeHtml(rawMarkdown) + '</pre>';
                return;
              }
              try {
                let html = marked.parse(rawMarkdown);
                html = processAlerts(html);
                contentEl.innerHTML = html;
                await renderMermaidDiagrams();
              } catch (e) {
                console.error('renderMarkdown error:', e);
                contentEl.innerHTML = '<pre style="padding:16px;white-space:pre-wrap;font-family:var(--font-mono);font-size:13px;color:var(--text-primary);">' + escapeHtml(rawMarkdown) + '</pre>';
              }
            };

            function init() {
              setupLibraries();
              const initial = \(encodedMarkdown);
              if (initial !== undefined && initial !== null) {
                window.renderMarkdown(initial);
              }
            }

            if (document.readyState === 'loading') {
              document.addEventListener('DOMContentLoaded', init);
            } else {
              init();
            }
          </script>
        </body>
        </html>
        """
    }
}
