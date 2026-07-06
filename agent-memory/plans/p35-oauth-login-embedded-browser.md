# P35: Fix Google (and other OAuth) login inside the embedded browser

## Context

Reported: signing into a Google account (and likely other OAuth providers —
not yet confirmed which) inside Harness's embedded browser pane does not
work.

Root cause, confirmed by reading the current implementation
(`Apps/Harness/Sources/HarnessApp/UI/Chrome/BrowserPaneView.swift`): every
tab is a plain `WKWebView` with a default `WKWebViewConfiguration()` — no
`customUserAgent`, no `ASWebAuthenticationSession`. Google (and most major
OAuth providers, following the same 2016+ policy) actively detect and block
sign-in attempts from generic embedded webviews, returning "This browser or
app may not be secure" — this is a deliberate anti-phishing measure on
Google's side, not a bug in their flow. Any third-party app embedding a bare
`WKWebView`/`UIWebView`-style view hits this, regardless of platform.

This is not fixable by spoofing a Safari user-agent string alone — Google's
detection is not purely UA-string-based and that workaround is known to stop
working without notice. Apple's own sanctioned path for in-app OAuth is
`ASWebAuthenticationSession` (or falling back to the system default browser).

## Priority: P1 (quality — real user-facing "can't sign into a real account" bug, not ship-blocking)

## Options to evaluate

1. **`ASWebAuthenticationSession` for known OAuth entry points.**
   Apple's sanctioned approach. Presents as a system-managed sheet (shares
   cookies/session with Safari, supports Keychain-saved passwords and
   Passkeys), not the app's own `WKWebView` chrome. Correct fix if there's a
   specific "Sign in" action/button we control the entry point for. Wrong
   fit if the goal is "any random site's login form should just work inside
   the general-purpose browser pane" — ASWebAuthenticationSession is for a
   deliberate auth flow, not general browsing.

2. **Detect known OAuth/login hosts and hand off to the system default
   browser instead of loading them in the embedded `WKWebView`.**
   (`accounts.google.com`, `login.microsoftonline.com`, `github.com/login`,
   etc.) Simplest to implement, matches what several other embedded-browser
   apps do, but breaks the "everything stays inside one pane" experience for
   the login step specifically — user finishes signing in in Safari/Chrome,
   then has to come back to Harness.

3. **Do nothing / document the limitation.** If OAuth login inside the
   embedded pane is not actually a core use case (vs. general page browsing,
   docs, MCP-driven page inspection), this may not be worth solving at all.
   Needs a decision on whether users are expected to sign into
   Google/GitHub/etc. accounts *inside* Harness's browser pane in the first
   place, or whether that's out of scope for what the embedded browser is
   for.

## Open questions (need input before implementing)

- Which OAuth providers actually need to work — just Google, or others too
  ("or another cannot work" — which one)? What's the actual user story:
  signing into a specific site's Google-auth login *within* an agent-driven
  browser session (e.g. MCP tooling filling a form), or a general "log into
  my Google account so bookmarks/history sync" expectation?
- Is there an existing entry point (a specific button/flow) this blocks, or
  is this "I tried to log into $site inside the browser pane and it failed"
  encountered ad hoc?

## Status: Fixed (2026-07-06)

Original hypothesis above (Google's anti-phishing embedded-webview block) was wrong —
live repro reached the Google consent screen fine, which that block would have prevented.
Real root cause: `BrowserPaneView.createTab` called `.load()` on the popup webview after
WebKit had already created it via `createWebViewWith`, severing `window.opener` (WKWebView
auto-loads `navigationAction.request` into the returned view — loading it again yourself
breaks the opener link). Also missing: `webViewDidClose` (JS `window.close()` was a no-op).

Fix: `createTab(url:configuration:skipLoad:)` skips the redundant load on the popup path;
`createWebViewWith` returns the created view (was `nil`); added `webViewDidClose`.
Verified end-to-end: Google login → Allow → popup auto-closes → claude.ai loads
authenticated. Full case + diagnostic technique: `knowledge/ui/browser-pane.md` → "CASE:
OAuth login (Google) never completes — P35".

Other providers (GitHub, Microsoft, etc.) not separately tested, but same code path —
expected to work now for any provider using the standard `window.open()` popup pattern.
