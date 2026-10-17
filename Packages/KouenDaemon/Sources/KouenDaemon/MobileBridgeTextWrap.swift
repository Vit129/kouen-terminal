// Line-wrapping rules for the Companion page (`MobileBridgeServer.embeddedPageHTML`), kept apart
// from the layout CSS. Shared by every agent (Claude, Codex, agy, Copilot): all their output arrives
// as plain text, so none of these differ per agent. Text wraps instead of ending in "…", so nothing
// is hidden on a phone. `break-word` keeps the browser's Thai dictionary breaks and splits inside a
// word only when one word is wider than the line (`anywhere` also split Thai at narrower widths).
// Diff hunks keep `pre` and scroll sideways: wrapping code there would misalign the +/- columns.
extension MobileBridgeServer {
    static let textWrapCSS = """
      header.bar h2{white-space:nowrap;text-overflow:ellipsis}
      .sess .name,.sess .meta{white-space:normal;overflow-wrap:break-word}
      .msg,.bot,.tool,.ask{overflow-wrap:break-word;word-break:normal;line-break:auto}
      .msg.user{white-space:pre-wrap}
      .tool span{white-space:normal;overflow-wrap:anywhere}
      .card .tx span{white-space:normal;overflow-wrap:anywhere}
      .file .path{text-overflow:ellipsis;white-space:nowrap}
      .stat{white-space:nowrap}
      .hunk div{white-space:pre}
      .chip{white-space:nowrap}
      .urlbar{text-overflow:ellipsis;white-space:nowrap}
      .chipbtn{white-space:nowrap}
      .toast span:last-child{white-space:nowrap}
      """
}
