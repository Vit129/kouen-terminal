#!/usr/bin/env node
/**
 * generate-cheatsheet.js
 * Reads docs/KEYBINDINGS.md + USAGE.md and generates sheet-cheat.html
 * Run: node Scripts/generate-cheatsheet.js
 * Or:  make cheatsheet
 */
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const KEYBINDINGS = fs.readFileSync(path.join(ROOT, 'docs/KEYBINDINGS.md'), 'utf8');
const USAGE = fs.readFileSync(path.join(ROOT, 'USAGE.md'), 'utf8');

// --- Parsers ---

function parseMdTables(md, sectionTitle) {
    const regex = new RegExp(`## ${sectionTitle}[\\s\\S]*?\\n(\\|[\\s\\S]*?)(?=\\n## |$)`, 'm');
    const match = md.match(regex);
    if (!match) return [];
    const lines = match[1].trim().split('\n').filter(l => l.startsWith('|'));
    if (lines.length < 2) return [];
    const headers = lines[0].split('|').map(c => c.trim()).filter(Boolean);
    return lines.slice(2).map(line => {
        const cols = line.split('|').map(c => c.trim()).filter(Boolean);
        const row = {};
        headers.forEach((h, i) => row[h] = cols[i] || '');
        return row;
    });
}

function parseShellTools(usage) {
    const match = usage.match(/### Recommended Shell Tools[\s\S]*?\n(\|[\s\S]*?)(?=\n## |\n### |$)/m);
    if (!match) return [];
    const lines = match[1].trim().split('\n').filter(l => l.startsWith('|'));
    if (lines.length < 2) return [];
    const headers = lines[0].split('|').map(c => c.trim()).filter(Boolean);
    return lines.slice(2).map(line => {
        const cols = line.split('|').map(c => c.trim()).filter(Boolean);
        const row = {};
        headers.forEach((h, i) => row[h] = cols[i] || '');
        return row;
    });
}

// --- Data extraction ---

const globalShortcuts = parseMdTables(KEYBINDINGS, 'Global menu shortcuts');
const prefixTable = parseMdTables(KEYBINDINGS, 'Default `prefix` table');
const copyMode = parseMdTables(KEYBINDINGS, 'Copy-mode key table');
const viCommands = parseMdTables(KEYBINDINGS, 'Vi ex commands \\(IDE-like workflow\\)');
const shellTools = parseShellTools(USAGE);

// --- HTML generation ---

function esc(s) { return (s||'').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/`([^`]+)`/g,'<kbd>$1</kbd>'); }

function renderTable(rows, columns) {
    let html = '<table>\n<tr>' + columns.map(c => `<th>${esc(c)}</th>`).join('') + '</tr>\n';
    for (const row of rows) {
        html += '<tr>' + columns.map(c => `<td>${esc(row[c] || '')}</td>`).join('') + '</tr>\n';
    }
    return html + '</table>\n';
}

const SHELL_REFERENCE = `
<h2>fzf — Fuzzy Finder</h2>
<table>
<tr><th>Shortcut</th><th>What it does</th></tr>
<tr><td>ctrl+r</td><td>Fuzzy search command history</td></tr>
<tr><td>ctrl+t</td><td>Fuzzy pick file → paste path</td></tr>
<tr><td>alt+c</td><td>Fuzzy pick subdirectory → cd</td></tr>
<tr><td>cmd | fzf</td><td>Pipe anything into fuzzy filter</td></tr>
</table>

<h2>zoxide — Smart cd</h2>
<table>
<tr><th>Command</th><th>What it does</th></tr>
<tr><td>z keyword</td><td>Jump to frecent directory</td></tr>
<tr><td>z keyword1 keyword2</td><td>Narrow with multiple words</td></tr>
<tr><td>zi</td><td>Interactive mode (fzf picker)</td></tr>
<tr><td>z -</td><td>Jump back to previous dir</td></tr>
</table>

<h2>ripgrep (rg) — Fast Search</h2>
<table>
<tr><th>Command</th><th>What it does</th></tr>
<tr><td>rg "pattern"</td><td>Search current dir recursively</td></tr>
<tr><td>rg "pattern" path/</td><td>Search specific directory</td></tr>
<tr><td>rg -t swift "pattern"</td><td>Filter by file type</td></tr>
<tr><td>rg -l "pattern"</td><td>List only filenames</td></tr>
<tr><td>rg -i "pattern"</td><td>Case insensitive</td></tr>
<tr><td>rg -C 3 "pattern"</td><td>Show 3 lines context</td></tr>
</table>

<h2>Recommended Tools</h2>
${shellTools.length ? renderTable(shellTools, Object.keys(shellTools[0])) : '<p>See USAGE.md</p>'}
`;

const UNIX_REFERENCE = `
<h2>Navigation</h2>
<table>
<tr><th>Command</th><th>What it does</th></tr>
<tr><td>cd -</td><td>Go back to previous directory</td></tr>
<tr><td>pushd / popd</td><td>Stack-based directory history</td></tr>
<tr><td>find . -name "*.ext"</td><td>Find files by name (use fd instead)</td></tr>
<tr><td>!!</td><td>Repeat last command</td></tr>
<tr><td>!$</td><td>Last argument of previous command</td></tr>
</table>

<h2>Pipes & Redirection</h2>
<table>
<tr><th>Syntax</th><th>What it does</th></tr>
<tr><td>cmd1 | cmd2</td><td>Pipe output to next command</td></tr>
<tr><td>cmd > file</td><td>Write output to file (overwrite)</td></tr>
<tr><td>cmd >> file</td><td>Append output to file</td></tr>
<tr><td>cmd1 && cmd2</td><td>Run cmd2 only if cmd1 succeeds</td></tr>
<tr><td>cmd1 || cmd2</td><td>Run cmd2 only if cmd1 fails</td></tr>
<tr><td>xargs</td><td>Pipe lines as arguments</td></tr>
</table>

<h2>Process Control</h2>
<table>
<tr><th>Command</th><th>What it does</th></tr>
<tr><td>ctrl+z / bg / fg</td><td>Suspend / background / foreground</td></tr>
<tr><td>cmd &</td><td>Run in background</td></tr>
<tr><td>ps aux | rg name</td><td>Find running process</td></tr>
</table>
`;

const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Terminal Power Tools — Interactive Cheat Sheet</title>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: -apple-system, BlinkMacSystemFont, 'SF Mono', Menlo, monospace; background: #1a1b26; color: #c0caf5; min-height: 100vh; padding: 2rem; }
h1 { color: #7aa2f7; margin-bottom: 0.5rem; font-size: 1.8rem; }
h2 { color: #bb9af7; margin: 2rem 0 1rem; font-size: 1.3rem; border-bottom: 1px solid #3b4261; padding-bottom: 0.5rem; }
.subtitle { color: #565f89; margin-bottom: 0.3rem; }
.source { color: #3b4261; font-size: 0.8rem; margin-bottom: 2rem; }
.source a { color: #565f89; }
.tabs { display: flex; gap: 0.5rem; margin-bottom: 2rem; flex-wrap: wrap; }
.tab { padding: 0.5rem 1rem; border-radius: 6px; cursor: pointer; background: #24283b; border: 1px solid #3b4261; color: #7aa2f7; transition: all 0.2s; }
.tab:hover { background: #3b4261; }
.tab.active { background: #7aa2f7; color: #1a1b26; border-color: #7aa2f7; }
.section { display: none; }
.section.active { display: block; }
table { width: 100%; border-collapse: collapse; margin-bottom: 1.5rem; }
th { text-align: left; padding: 0.6rem 1rem; background: #24283b; color: #bb9af7; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.05em; }
td { padding: 0.5rem 1rem; border-bottom: 1px solid #292e42; }
td:first-child { color: #9ece6a; font-family: 'SF Mono', Menlo, monospace; white-space: nowrap; }
tr:hover { background: #292e42; }
kbd { background: #3b4261; padding: 0.15rem 0.4rem; border-radius: 3px; font-size: 0.85rem; }
.quiz-box { background: #24283b; border: 1px solid #3b4261; border-radius: 8px; padding: 1.5rem; margin-bottom: 1rem; }
.quiz-box h3 { color: #e0af68; margin-bottom: 1rem; font-size: 1rem; }
.quiz-input { background: #1a1b26; border: 1px solid #3b4261; color: #c0caf5; padding: 0.5rem 1rem; border-radius: 4px; font-family: 'SF Mono', Menlo, monospace; font-size: 0.95rem; width: 100%; max-width: 400px; }
.quiz-input:focus { outline: none; border-color: #7aa2f7; }
.quiz-input.correct { border-color: #9ece6a; background: #1a2e1a; }
.quiz-input.wrong { border-color: #f7768e; background: #2e1a1a; }
.hint { color: #565f89; font-size: 0.85rem; margin-top: 0.5rem; }
.score { position: fixed; top: 1rem; right: 2rem; background: #24283b; border: 1px solid #3b4261; border-radius: 8px; padding: 0.8rem 1.2rem; }
.score span { color: #9ece6a; font-weight: bold; }
</style>
</head>
<body>
<h1>⌁ Terminal Power Tools</h1>
<p class="subtitle">Interactive cheat sheet — practice mode included</p>
<p class="source">Generated from: <a href="docs/KEYBINDINGS.md">docs/KEYBINDINGS.md</a> · <a href="USAGE.md">USAGE.md</a></p>
<div class="score">Score: <span id="score">0</span> / <span id="total">0</span></div>

<div class="tabs">
<div class="tab active" data-tab="shell">Shell (fzf/zoxide/rg)</div>
<div class="tab" data-tab="unix">Unix Essentials</div>
<div class="tab" data-tab="vim">Vim / Copy Mode</div>
<div class="tab" data-tab="kouen">Kouen Shortcuts</div>
<div class="tab" data-tab="practice">🎯 Practice</div>
</div>

<div class="section active" id="shell">
${SHELL_REFERENCE}
</div>

<div class="section" id="unix">
${UNIX_REFERENCE}
</div>

<div class="section" id="vim">
<h2>Copy Mode (vi-style, in Kouen)</h2>
${renderTable(copyMode, ['Key', 'Action'])}
<h2>Vi Ex Commands (file editor)</h2>
${renderTable(viCommands, ['Command', 'IDE equivalent'])}
</div>

<div class="section" id="kouen">
<h2>Global Menu Shortcuts</h2>
${renderTable(globalShortcuts, ['Action', 'Shortcut'])}
<h2>Prefix Table (after ctrl+a)</h2>
${renderTable(prefixTable, ['Key', 'Command'])}
</div>

<div class="section" id="practice">
<h2>🎯 Practice Mode — Type the Answer</h2>
<p class="hint" style="margin-bottom:1.5rem">Answer what command/shortcut you'd use. Press Enter to check.</p>

<div class="quiz-box" data-answer="z"><h3>Jump to a directory you've visited before (smart cd)</h3><input class="quiz-input" placeholder="Type command..."><p class="hint">Hint: 1 letter command</p></div>
<div class="quiz-box" data-answer="ctrl+r"><h3>Search your command history with fuzzy matching</h3><input class="quiz-input" placeholder="Type shortcut..."><p class="hint">Hint: ctrl + ?</p></div>
<div class="quiz-box" data-answer="rg"><h3>Search text across all files recursively (fast)</h3><input class="quiz-input" placeholder="Type command..."><p class="hint">Hint: 2-letter, short for ripgrep</p></div>
<div class="quiz-box" data-answer="ctrl+t"><h3>Fuzzy pick a file and paste its path</h3><input class="quiz-input" placeholder="Type shortcut..."><p class="hint">Hint: ctrl + ?</p></div>
<div class="quiz-box" data-answer="alt+c"><h3>Fuzzy pick a subdirectory and cd into it</h3><input class="quiz-input" placeholder="Type shortcut..."><p class="hint">Hint: alt + ?</p></div>
<div class="quiz-box" data-answer="!!"><h3>(Unix) Repeat the last command</h3><input class="quiz-input" placeholder="Type..."><p class="hint">Hint: commonly used with sudo</p></div>
<div class="quiz-box" data-answer="rg -l"><h3>Search for a pattern but only show filenames</h3><input class="quiz-input" placeholder="Type command + flag..."><p class="hint">Hint: rg + flag for "list"</p></div>
<div class="quiz-box" data-answer="⌘P"><h3>(Kouen) Fuzzy jump to file or directory</h3><input class="quiz-input" placeholder="Type shortcut..."><p class="hint">Hint: like VS Code</p></div>
<div class="quiz-box" data-answer="⌘W"><h3>(Kouen) Close the active pane or tab</h3><input class="quiz-input" placeholder="Type shortcut..."><p class="hint">Hint: universal close</p></div>
<div class="quiz-box" data-answer="v"><h3>(Copy mode) Start character selection</h3><input class="quiz-input" placeholder="Type key..."><p class="hint">Hint: same as vim visual</p></div>
<div class="quiz-box" data-answer=":grep"><h3>(Vi ex) Search across the project</h3><input class="quiz-input" placeholder="Type ex command..."><p class="hint">Hint: colon + search tool name</p></div>
<div class="quiz-box" data-answer="gd"><h3>(Vi ex) Go to definition</h3><input class="quiz-input" placeholder="Type keys..."><p class="hint">Hint: g + d</p></div>
</div>

<script>
document.querySelectorAll('.tab').forEach(tab => {
    tab.addEventListener('click', () => {
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
        tab.classList.add('active');
        document.getElementById(tab.dataset.tab).classList.add('active');
    });
});
let score = 0, total = 0;
document.querySelectorAll('.quiz-box').forEach(box => {
    const input = box.querySelector('.quiz-input');
    const answer = box.dataset.answer.toLowerCase();
    input.addEventListener('keydown', e => {
        if (e.key !== 'Enter') return;
        const val = input.value.trim().toLowerCase();
        total++;
        if (val === answer) { input.classList.add('correct'); score++; }
        else { input.classList.add('wrong'); box.querySelector('.hint').innerHTML = 'Answer: <kbd>'+box.dataset.answer+'</kbd>'; box.querySelector('.hint').style.color = '#f7768e'; }
        document.getElementById('score').textContent = score;
        document.getElementById('total').textContent = total;
        input.disabled = true;
    });
});
</script>
</body>
</html>`;

fs.writeFileSync(path.join(ROOT, 'sheet-cheat.html'), html);
console.log('✓ sheet-cheat.html generated from docs/KEYBINDINGS.md + USAGE.md');
