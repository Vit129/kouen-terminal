// Line-wrapping rules for the Companion page (`MobileBridgeServer.embeddedPageHTML`), kept apart
// from the layout CSS. Shared by every agent: Claude and agy output both arrive as plain text, so
// none of these differ per agent. `overflow-wrap:anywhere` breaks inside a word, Thai included.
extension MobileBridgeServer {
    static let textWrapCSS = """
      header.bar h2{white-space:nowrap;text-overflow:ellipsis}
      .sess .name{text-overflow:ellipsis;white-space:nowrap}
      .sess .meta{text-overflow:ellipsis;white-space:nowrap}
      .msg.user{white-space:pre-wrap;overflow-wrap:anywhere}
      .bot{overflow-wrap:anywhere}
      .tool span{text-overflow:ellipsis;white-space:nowrap}
      .card .tx span{text-overflow:ellipsis;white-space:nowrap}
      .file .path{text-overflow:ellipsis;white-space:nowrap}
      .stat{white-space:nowrap}
      .hunk div{white-space:pre}
      .chip{white-space:nowrap}
      .urlbar{text-overflow:ellipsis;white-space:nowrap}
      .chipbtn{white-space:nowrap}
      .toast span:last-child{white-space:nowrap}
      """
}
