import WebKit

extension WKWebView {
    /// macOS can report a window the user is looking at as occluded. WebKit then marks the
    /// page hidden and stops painting, leaving a black pane that repaint nudges cannot wake.
    /// A tab that is not selected is detached from the window, so it still counts as hidden.
    ///
    /// The setter is private WebKit API. It is called through its IMP after a `responds(to:)`
    /// check, so a WebKit that lacks it keeps the default instead of raising an exception.
    func ignoreWindowOcclusion() {
        let setter = NSSelectorFromString("_setWindowOcclusionDetectionEnabled:")
        guard responds(to: setter) else { return }
        typealias SetBool = @convention(c) (AnyObject, Selector, Bool) -> Void
        unsafeBitCast(method(for: setter), to: SetBool.self)(self, setter, false)
    }
}
