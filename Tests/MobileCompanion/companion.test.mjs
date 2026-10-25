// Run: node Tests/MobileCompanion/companion.test.mjs
// Checks the Companion page JS embedded in MobileBridgeServer.swift: it must parse (a bare "\n" in
// the Swift literal silently breaks the whole script) and its markdown renderer must escape HTML.
import { readFileSync } from "node:fs";
import vm from "node:vm";
import assert from "node:assert/strict";

const swift = readFileSync(new URL("../../Packages/KouenDaemon/Sources/KouenDaemon/MobileBridgeWebAssets.swift", import.meta.url), "utf8");
const page = swift.slice(swift.indexOf('static let embeddedPageHTML = #"""'), swift.indexOf('"""#', swift.indexOf('static let embeddedPageHTML')));
// Swift fills \#(agentIconsJS) at runtime; stand in the shape it emits.
const script = page.slice(page.indexOf("<script>") + 8, page.lastIndexOf("</script>"))
  .replace("\\#(agentIconsJS)", 'const AGENT_ICONS = {"codex":{"c":"#10a37f","svg":"<svg/>"},"generic":{"c":"#9aa0a6"}};');
new vm.Script(script); // throws on a syntax error

const block = script.slice(script.indexOf("// <md-start>"), script.indexOf("// <md-end>"));
const esc = t => (t || "").replace(/[&<>"']/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
const md = new Function("esc", block + "; return md;")(esc);

assert.equal(md("<img src=x onerror=alert(1)>"), "<p>&lt;img src=x onerror=alert(1)&gt;</p>");
assert.equal(md("## Title\n\n- a **b**\n- `c<d>`"), "<h4>Title</h4><ul><li>a <strong>b</strong></li><li><code>c&lt;d&gt;</code></li></ul>");
assert.equal(md("1. x\n2. y"), "<ol><li>x</li><li>y</li></ol>");
assert.match(md("| h |\n|---|\n| v |"), /<table><tr><th>h<\/th><\/tr><tr><td>v<\/td><\/tr><\/table>/);
assert.equal(md("```\n<b>\n```"), "<pre><code>&lt;b&gt;</code></pre>");
const lineFilter = new RegExp(script.match(/filter\(l => \/(.+?)\/u\.test\(l\)\)/)[1], "u");
assert.ok(["◉ \u{F0E7}", "○ ", "╭──╮"].every(l => !lineFilter.test(l)), "spinner/border noise must be dropped");
assert.ok(["Working", "ทดสอบ", "42"].every(l => lineFilter.test(l)));
// Thai sara am written as nikhahit + sara aa is composed before display.
const escFn = new Function(script.match(/function esc\(t\) \{.*\}/)[0] + "; return esc;")();
assert.equal(escFn("ตําแหน่ง"), "ตำแหน่ง");
console.log("companion page js: ok");
