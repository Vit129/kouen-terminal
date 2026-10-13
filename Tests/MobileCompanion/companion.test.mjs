// Run: node Tests/MobileCompanion/companion.test.mjs
// Checks the Companion page JS embedded in MobileBridgeServer.swift: it must parse (a bare "\n" in
// the Swift literal silently breaks the whole script) and its markdown renderer must escape HTML.
import { readFileSync } from "node:fs";
import vm from "node:vm";
import assert from "node:assert/strict";

const swift = readFileSync(new URL("../../Packages/KouenDaemon/Sources/KouenDaemon/MobileBridgeServer.swift", import.meta.url), "utf8");
const page = swift.slice(swift.indexOf('static let embeddedPageHTML = #"""'), swift.indexOf('"""#', swift.indexOf('static let embeddedPageHTML')));
const script = page.slice(page.indexOf("<script>") + 8, page.lastIndexOf("</script>"));
new vm.Script(script); // throws on a syntax error

const block = script.slice(script.indexOf("// <md-start>"), script.indexOf("// <md-end>"));
const esc = t => (t || "").replace(/[&<>"']/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
const md = new Function("esc", block + "; return md;")(esc);

assert.equal(md("<img src=x onerror=alert(1)>"), "<p>&lt;img src=x onerror=alert(1)&gt;</p>");
assert.equal(md("## Title\n\n- a **b**\n- `c<d>`"), "<h4>Title</h4><ul><li>a <strong>b</strong></li><li><code>c&lt;d&gt;</code></li></ul>");
assert.equal(md("1. x\n2. y"), "<ol><li>x</li><li>y</li></ol>");
assert.match(md("| h |\n|---|\n| v |"), /<table><tr><th>h<\/th><\/tr><tr><td>v<\/td><\/tr><\/table>/);
assert.equal(md("```\n<b>\n```"), "<pre><code>&lt;b&gt;</code></pre>");
console.log("companion page js: ok");
