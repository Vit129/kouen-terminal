import ObjectiveC
import WebKit

extension WKWebViewConfiguration {
    /// WebKit asks the system AppSSO service before every navigation and has no timeout.
    /// When that call never returns (seen 2026-11-01: `canPerformAuthorizationWithURL`
    /// logged, no completion), the page stays provisional at ~10% progress and the
    /// transparent web view shows the pane's black background, until the app restarts.
    /// Kouen has no SSO use, so its web views opt out.
    ///
    /// The setter is private WebKit API (`WKPreferences._setExtensibleSSOEnabled:`,
    /// macOS 12+). It is called through its IMP after a `responds(to:)` check, so an OS
    /// that lacks it leaves the default in place instead of raising an exception.
    func disableExtensibleSSO() {
        let setter = NSSelectorFromString("_setExtensibleSSOEnabled:")
        guard preferences.responds(to: setter) else { return }
        typealias SetBool = @convention(c) (AnyObject, Selector, Bool) -> Void
        let imp = preferences.method(for: setter)
        unsafeBitCast(imp, to: SetBool.self)(preferences, setter, false)
    }
}
