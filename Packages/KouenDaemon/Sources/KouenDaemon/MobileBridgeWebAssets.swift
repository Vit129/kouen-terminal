import Foundation

// MARK: - Embedded Mobile Companion Web Assets (HTML, CSS, JS, Manifest, Service Worker, Icon)
// Extracted from MobileBridgeServer to decouple daemon transport from presentation assets.

extension MobileBridgeServer {

    /// The pairing page, served by this process itself (see `makeUnifiedListener`) — not a
    /// separate file some other HTTP server has to host. Single source of truth: this used
    /// to be `Scripts/mobile-web-test.html` served by a standalone `python3 -m http.server`
    /// the dev script (`mobile-web.sh`) spun up alongside the daemon; that only ever existed
    /// in the dev flow, so the production/preview daemon (spawned by `DaemonLauncher`,
    /// no such script involved) printed a pairing URL nothing was listening on — confirmed
    /// via a direct `curl` against a real `make preview` daemon returning connection refused.
    /// P37 Phase C (W3): the real client, replacing the old bare-bones smoke-test page —
    /// xterm.js terminal (real ANSI/cursor rendering) + the session-switcher UI from
    /// `agent-memory/plans/p25-mobile-session-switcher-design.html` (dark terminal aesthetic,
    /// session list, switcher sheet). Resize now round-trips: `FitAddon` measures the
    /// container, the client sends `{"resize":{cols,rows}}`, `handleControlMessage` forwards
    /// it to `DaemonClient.resize`.
    static let embeddedPageHTML = #"""
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <title>Kouen Companion</title>
      <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">
      <meta name="theme-color" content="#000000">
      <meta name="apple-mobile-web-app-capable" content="yes">
      <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
      <link rel="manifest" href="/manifest.json">
      <link rel="icon" href="/icon.svg" type="image/svg+xml">
      <style>
      [hidden]{display:none !important}
      :root{
        --bg:#000000; --surface:#0a0a0a; --ink:#e6ebe8; --muted:#8f9b95; --line:#232825;
        --accent:#7cc4a0; --accent-ink:#06120c; --accent-soft:#14231b;
        --add:#0f2617; --add-ink:#8fdcab; --del:#2e1513; --del-ink:#f2a097;
        --warn:#f0b357; --warn-soft:#2c210d; --run:#7cc4a0; --idle:#6c7a73;
        --frame:#232825; --code-bg:#050605; color-scheme:dark;
        --f-body:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;
        --f-mono:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,"Liberation Mono",monospace;
      }
      *{box-sizing:border-box}
      html,body{height:100%}
      body{background:var(--bg);color:var(--ink);font:15px/1.45 var(--f-body);margin:0}
      .stage{min-height:100%;display:flex;justify-content:center;align-items:flex-start;gap:32px;padding-block:24px;padding-inline:16px;flex-wrap:wrap}
      .phone{width:100%;max-width:390px;height:780px;max-height:calc(100vh - 48px);min-height:560px;background:var(--surface);border:1px solid var(--frame);border-radius:28px;overflow:hidden;display:flex;flex-direction:column;position:relative}
      @media (max-width:480px){
        .stage{padding:0;gap:0}
        .phone{max-width:none;height:100%;max-height:none;border:0;border-radius:0}
        .stage{height:100%}
      }
      header.bar{display:flex;align-items:center;gap:10px;padding:14px 16px 10px;border-bottom:1px solid var(--line)}
      header.bar h2{font-size:17px;margin:0;flex:1;min-width:0;overflow:hidden}
      .sub{color:var(--muted);font-size:12px;font-family:var(--f-mono)}
      button{font:inherit;color:inherit;background:none;border:0;cursor:pointer}
      button:focus-visible,textarea:focus-visible{outline:2px solid var(--accent);outline-offset:2px}
      .icon-btn{width:36px;height:36px;border-radius:10px;display:grid;place-items:center;font-size:18px}
      .icon-btn:hover{background:var(--accent-soft)}
      .scroll{flex:1;overflow-y:auto;min-height:0}

      /* Pairing View */
      #scr-pairing{display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;padding:24px;text-align:center;gap:14px}
      #scr-pairing h3{margin:0;font-size:19px;font-weight:700}
      #scr-pairing p{margin:0;color:var(--muted);font-size:13px;max-width:280px}
      .token-input{font-family:var(--f-mono);font-size:22px;letter-spacing:0.18em;text-align:center;width:180px;padding:10px;border-radius:12px;border:1px solid var(--line);background:var(--code-bg);color:var(--ink)}

      /* Sessions */
      .list{display:flex;flex-direction:column}
      .sess{display:grid;grid-template-columns:auto 1fr auto;gap:4px 12px;align-items:center;padding:14px 16px;border-bottom:1px solid var(--line);text-align:left;width:100%}
      .sess:hover{background:var(--accent-soft)}
      .dot{width:10px;height:10px;border-radius:50%;grid-row:span 2}
      .dot.run{background:var(--run);box-shadow:0 0 0 4px var(--accent-soft)}
      .dot.wait{background:var(--warn);box-shadow:0 0 0 4px var(--warn-soft)}
      .dot.idle{background:var(--idle)}
      .sess .name{font-weight:700;min-width:0;overflow:hidden}
      .sess .meta{grid-column:2;color:var(--muted);font-size:12px;font-family:var(--f-mono);min-width:0;overflow:hidden}
      .pill{font-size:11px;font-weight:700;padding:2px 8px;border-radius:999px;letter-spacing:.03em;grid-row:span 2}
      .pill.wait{background:var(--warn-soft);color:var(--warn)}
      .pill.run{background:var(--accent-soft);color:var(--accent)}
      .pill.idle{background:var(--code-bg);color:var(--muted)}
      .agent{font-family:var(--f-mono);font-size:11px;color:var(--muted);border:1px solid var(--line);border-radius:6px;padding:0 5px;margin-left:6px;font-weight:400}
      .section-label{font-size:11px;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);padding:14px 16px 6px}

      /* Chat */
      .out{padding:14px 16px 20px;display:flex;flex-direction:column;gap:12px}
      .msg{min-width:0}
      .msg.user{align-self:flex-end;background:var(--accent);color:var(--accent-ink);padding:9px 13px;border-radius:16px 16px 4px 16px;max-width:85%}
      .bot{min-width:0;font-size:15px;line-height:1.55}
      .bot p{margin:0 0 8px}
      .bot p:last-child,.bot ul:last-child,.bot ol:last-child{margin-bottom:0}
      .bot ul,.bot ol{margin:0 0 8px;padding-left:20px}
      .bot li{margin-bottom:4px}
      .bot strong{font-weight:700}
      .bot h4{font-size:15px;margin:10px 0 4px}
      .bot code{font-family:var(--f-mono);font-size:12.5px;background:var(--code-bg);border:1px solid var(--line);border-radius:5px;padding:0 4px}
      .bot pre{margin:0 0 8px;background:var(--code-bg);border:1px solid var(--line);border-radius:8px;padding:8px 10px;overflow-x:auto}
      .bot pre code{border:0;padding:0;background:none}
      .bot .tbl{overflow-x:auto;margin:0 0 8px}
      .bot table{border-collapse:collapse;font-size:13px;min-width:100%}
      .bot th,.bot td{border-bottom:1px solid var(--line);padding:5px 8px;text-align:left;vertical-align:top}
      .bot th{color:var(--muted);font-weight:700}
      .more{color:var(--accent);font-weight:700;font-size:13px;padding:2px 0;text-align:left}
      .clamp{max-height:260px;overflow:hidden;-webkit-mask-image:linear-gradient(#000 70%,transparent);mask-image:linear-gradient(#000 70%,transparent)}
      .tools{display:flex;flex-direction:column;gap:2px}
      .tool{font-family:var(--f-mono);font-size:12px;color:var(--muted);display:flex;gap:8px;align-items:baseline;min-width:0}
      .tool b{color:var(--ink);font-weight:600;flex:none}
      .tool span{min-width:0;overflow:hidden}
      .toolsum{font-family:var(--f-mono);font-size:12px;color:var(--muted);text-align:left;padding:4px 0}
      .img{align-self:flex-end;border-radius:12px;border:1px solid var(--line);background:linear-gradient(135deg,var(--code-bg),var(--accent-soft));padding:10px 16px;font-size:12px;color:var(--muted);font-family:var(--f-mono)}
      .working{font-size:13px;color:var(--muted);display:flex;gap:8px;align-items:center}
      .working i{width:8px;height:8px;border-radius:50%;background:var(--run)}
      @media (prefers-reduced-motion:no-preference){.working i{animation:pulse 1.2s ease-in-out infinite}@keyframes pulse{50%{opacity:.25}}}
      .ask{border:1px solid var(--warn);background:var(--warn-soft);border-radius:12px;padding:10px 12px;display:flex;flex-direction:column;gap:8px}
      .ask strong{color:var(--warn)}
      .ask .row{display:flex;gap:8px}
      .btn{padding:8px 14px;border-radius:10px;font-weight:700;font-size:14px}
      .btn.primary{background:var(--accent);color:var(--accent-ink)}
      .btn.ghost{border:1px solid var(--line);background:var(--surface)}

      /* Cards */
      .card{border:1px solid var(--line);border-radius:12px;padding:10px 12px;display:flex;align-items:center;gap:10px;text-align:left;width:100%;background:var(--surface);color:inherit;text-decoration:none}
      .card:hover{background:var(--accent-soft)}
      .card .ic{width:30px;height:30px;border-radius:8px;background:var(--code-bg);display:grid;place-items:center;font-family:var(--f-mono);font-size:13px;flex:none}
      .card .tx{flex:1;min-width:0}
      .card .tx b{display:block;font-size:14px}
      .card .tx span{font-size:12px;color:var(--muted);font-family:var(--f-mono);display:block;overflow:hidden}
      .card .go{color:var(--accent);font-weight:700;font-size:13px}

      /* Diff */
      .files{display:flex;flex-direction:column}
      .file{border-bottom:1px solid var(--line)}
      .file summary{list-style:none;display:flex;gap:8px;align-items:center;padding:12px 16px;cursor:pointer}
      .file summary::-webkit-details-marker{display:none}
      .file .path{font-family:var(--f-mono);font-size:13px;flex:1;min-width:0;overflow:hidden;direction:rtl;text-align:left}
      .stat{font-family:var(--f-mono);font-size:12px}
      .stat .a{color:var(--add-ink)} .stat .d{color:var(--del-ink)}
      .hunk{font-family:var(--f-mono);font-size:12px;line-height:1.55;overflow-x:auto;background:var(--code-bg)}
      .hunk div{padding:0 12px}
      .hunk .h{color:var(--muted);padding-block:4px}
      .hunk .add{background:var(--add);color:var(--add-ink)}
      .hunk .del{background:var(--del);color:var(--del-ink)}
      .badge{font-size:10px;font-weight:700;letter-spacing:.05em;padding:1px 6px;border-radius:6px;background:var(--warn-soft);color:var(--warn)}

      /* Preview */
      .pv-src{display:flex;gap:6px;padding:10px 16px;overflow-x:auto}
      .chip{padding:6px 12px;border-radius:999px;border:1px solid var(--line);font-size:13px}
      .chip[aria-pressed="true"]{background:var(--ink);color:var(--surface);border-color:var(--ink)}
      .urlbar{margin:0 16px;font-family:var(--f-mono);font-size:12px;color:var(--muted);background:var(--code-bg);border-radius:8px;padding:6px 10px;overflow:hidden}
      .mock{margin:10px 16px 16px;border:1px solid var(--line);border-radius:12px;overflow:hidden;background:var(--bg)}
      .mock .hero{padding:22px 16px;background:var(--accent);color:var(--accent-ink)}
      .mock .hero b{display:block;font-size:20px}
      .caption{font-size:12px;color:var(--muted);padding:0 16px 12px}

      /* Composer */
      .composer{border-top:1px solid var(--line);padding:8px 10px calc(10px + env(safe-area-inset-bottom,0px));display:flex;flex-direction:column;gap:6px;background:var(--surface)}
      .inrow{display:flex;gap:6px;align-items:flex-end}
      .inrow textarea{flex:1;min-width:0;resize:none;border:1px solid var(--line);border-radius:14px;padding:9px 12px;font:inherit;background:var(--bg);color:var(--ink);max-height:120px}
      .send{background:var(--accent);color:var(--accent-ink);border-radius:12px;width:40px;height:40px;font-size:18px}
      .send.stopping{background:var(--del);color:var(--del-ink);font-size:14px}
      .ctl{display:flex;gap:6px;align-items:center;overflow-x:auto;padding:2px 0}
      .chipbtn{display:inline-flex;align-items:center;gap:5px;border:1px solid var(--line);border-radius:999px;padding:5px 11px;font-size:13px;min-height:32px}
      .chipbtn:hover{background:var(--accent-soft)}
      .chipbtn:disabled{opacity:.6;cursor:default}
      .chipbtn .k{color:var(--muted)}
      .chipbtn .car{color:var(--muted);font-size:10px}
      .chipbtn.mode-plan{border-color:var(--warn);color:var(--warn)}
      .pick{display:flex;flex-direction:column;padding:6px 8px 14px}
      .pick h5{font-size:11px;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);margin:12px 8px 6px;font-weight:700}
      .opt{display:grid;grid-template-columns:1fr auto;gap:2px 10px;text-align:left;padding:10px;border-radius:10px;align-items:center}
      .opt:hover{background:var(--accent-soft)}
      .opt .t{font-weight:700}
      .opt .d{grid-column:1;font-size:12.5px;color:var(--muted)}
      .opt .ck{grid-row:span 2;color:var(--accent);font-weight:700;visibility:hidden}
      .opt[aria-checked="true"] .ck{visibility:visible}
      .seg{display:grid;grid-template-columns:repeat(5,1fr);gap:4px;background:var(--code-bg);border:1px solid var(--line);border-radius:12px;padding:4px;margin:0 8px}
      .seg button{padding:9px 2px;border-radius:9px;font-size:13px;font-weight:700;color:var(--muted)}
      .seg button[aria-pressed="true"]{background:var(--surface);color:var(--ink);box-shadow:0 1px 3px rgba(0,0,0,.12)}
      .hint{font-size:12.5px;color:var(--muted);margin:8px 10px 0}
      .panel.small{height:auto;max-height:88%}
      .attach-list{display:flex;gap:6px;flex-wrap:wrap}
      .att{font-size:12px;background:var(--accent-soft);color:var(--accent);border-radius:8px;padding:2px 8px}

      /* Slide-up Panels & Sheets */
      .panel-bg{position:absolute;inset:0;background:rgba(0,0,0,.35);display:flex;align-items:flex-end;z-index:5}
      .panel{background:var(--surface);width:100%;height:88%;border-radius:20px 20px 0 0;display:flex;flex-direction:column;min-height:0}
      .grab{width:40px;height:5px;border-radius:3px;background:var(--line);margin:8px auto 2px}
      .panel-h{display:flex;align-items:center;gap:8px;padding:6px 12px 10px 16px;border-bottom:1px solid var(--line)}
      .panel-h h3{margin:0;font-size:16px;flex:1}
      @media (prefers-reduced-motion:no-preference){.panel{animation:up .22s ease-out}}
      .edit-link{cursor:pointer;text-decoration:underline dotted;text-underline-offset:3px}

      .menu{position:absolute;top:56px;right:12px;z-index:4;background:var(--surface);border:1px solid var(--line);border-radius:12px;padding:4px;display:flex;flex-direction:column;min-width:190px;box-shadow:0 8px 24px rgba(0,0,0,.18)}
      .menu button{text-align:left;padding:10px 12px;border-radius:8px;display:flex;justify-content:space-between;gap:12px}
      .menu button:hover{background:var(--accent-soft)}
      .menu button:disabled{opacity:.4}

      .toast{position:absolute;left:16px;right:16px;bottom:96px;background:var(--ink);color:var(--surface);border-radius:12px;padding:10px 14px;font-size:14px;display:flex;justify-content:space-between;gap:10px;z-index:10}
      .toast span:last-child{font-family:var(--f-mono);font-size:12px;opacity:.8}
        \#(textWrapCSS)
        \#(agentIconCSS)
      </style>
    </head>
    <body>
    <div class="stage">
      <div class="phone" id="phone">
        <!-- Pairing screen -->
        <section id="scr-pairing" hidden>
          <div class="dot wait" style="width:24px;height:24px;margin-bottom:8px"></div>
          <h3>Pair Kouen Companion</h3>
          <p>Scan the QR code in Kouen or enter the 6-digit pairing code from the desktop app.</p>
          <input type="text" id="pair-token" class="token-input" maxlength="6" placeholder="000000" autofocus>
          <button class="btn primary" id="pair-btn" style="width:180px">Pair Device</button>
        </section>

        <!-- Sessions screen -->
        <section id="scr-list" style="display:contents">
          <header class="bar">
            <h2>Kouen</h2>
            <span class="sub" id="header-host">tailnet</span>
          </header>
          <div class="scroll">
            <div class="section-label">Needs you</div>
            <div class="list" id="list-wait"></div>
            <div class="section-label">Working</div>
            <div class="list" id="list-run"></div>
            <div class="section-label">Idle</div>
            <div class="list" id="list-idle"></div>
          </div>
        </section>

        <!-- Session screen -->
        <section id="scr-sess" hidden style="display:none">
          <header class="bar">
            <button class="icon-btn" id="back" aria-label="Back to sessions">‹</button>
            <div style="flex:1;min-width:0">
              <h2 id="s-name"></h2>
              <div class="sub" id="s-meta"></div>
            </div>
            <button class="icon-btn" id="more" aria-label="More actions" aria-expanded="false">⋯</button>
            <div class="menu" id="menu" hidden>
              <button id="diff-btn">Diff <span class="stat"><span class="a" id="d-add">+0</span> <span class="d" id="d-del">−0</span></span></button>
              <button id="pv-btn">Preview</button>
              <button id="pr-btn">Draft PR → GitHub</button>
            </div>
          </header>
          <div class="scroll" id="pane"></div>
          <div class="composer">
            <div class="attach-list" id="atts"></div>
            <div class="inrow">
              <label class="icon-btn" for="file" aria-label="Attach file" style="cursor:pointer">📎</label>
              <input type="file" id="file" hidden multiple>
              <textarea id="msg" rows="1" placeholder="Message the agent…"></textarea>
              <button class="send" id="send" aria-label="Send">↑</button>
            </div>
            <div class="ctl" id="ctl" hidden>
              <button class="chipbtn" id="model-chip" aria-haspopup="dialog"></button>
              <button class="chipbtn" id="mode-chip" aria-haspopup="dialog"></button>
              <button class="chipbtn" id="usage-chip" aria-haspopup="dialog" hidden></button>
            </div>
          </div>
        </section>

        <!-- Slide-up Panel (Diff / Preview) -->
        <div class="panel-bg" id="panel" hidden>
          <div class="panel" id="panel-box" role="dialog" aria-labelledby="panel-t">
            <div class="grab"></div>
            <div class="panel-h"><h3 id="panel-t"></h3><button class="icon-btn" id="panel-x" aria-label="Close">✕</button></div>
            <div class="scroll" id="panel-body"></div>
          </div>
        </div>


        <!-- Toast -->
        <div class="toast" id="toast" hidden><span id="toast-t"></span><span id="toast-s"></span></div>
      </div>
    </div>

    <script>
    \#(agentIconsJS)
    // Brand mark tinted like the Mac sidebar; a two-letter monogram for agents without one.
    function aiIcon(s) {
      const k = s && s.kind, a = AGENT_ICONS[k] || AGENT_ICONS.generic || { c: '#9aa0a6' };
      const inner = a.svg || esc(((s && s.agent) || '?').slice(0, 2).toUpperCase());
      return `<span class="ai" style="--c:${a.c}" aria-hidden="true">${inner}</span>`;
    }
    const LABEL = { wait: "WAITING", run: "WORKING", idle: "IDLE" };
    const $ = id => document.getElementById(id);
    let ws = null, sessions = [], cur = null, atts = [], pv = "local", authed = false;
    let needsAttach = null, failedRetries = 0; // needsAttach: null = socket not open yet
    const params = new URLSearchParams(location.search);
    const wsPort = params.get('wsport') || location.port;
    // Keyed by host:port: the installed Kouen (8080) and a preview (8081) share a hostname but are
    // different daemons with different paired-device stores.
    const credKey = 'kouenDeviceCreds:' + location.host;
    let sentCreds = false;
    function storedCreds() { try { return JSON.parse(localStorage.getItem(credKey)); } catch { return null; } }
    // Which session was open plus each session's picked model/effort and transcript feed, so a
    // reload or an iOS background kill comes back to the same screen instead of the list.
    const viewKey = 'kouenView:' + location.host;
    let view = (() => { try { return JSON.parse(localStorage.getItem(viewKey)) || {}; } catch { return {}; } })();
    view.s = view.s || {};
    let saveTimer = null;
    function saveView() {
      clearTimeout(saveTimer);
      saveTimer = setTimeout(() => {
        view.open = cur ? cur.id : null;
        if (cur) view.s[cur.id] = { modelName: cur.modelName, effort: cur.effort, usage: cur.usage, out: cur.transcript ? cur.out.slice(-150) : undefined };
        try { localStorage.setItem(viewKey, JSON.stringify(view)); } catch {}
      }, 500);
    }

    // Some models emit sara am as nikhahit + sara aa (ํา), which iOS draws with a dotted circle.
    function esc(t) { return (t || '').replace(/ํา/g, 'ำ').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c])); }
    function stripANSI(str) {
      return (str || '')
        .replace(/\x1b\][^\x07\x1b]*(\x07|\x1b\\)/g, '')
        .replace(/\x1b\[[0-?]*[ -\/]*[@-~]/g, '')
        .replace(/\x1b[()*+\-.\/][ -~]/g, '')
        .replace(/\x1b[@-Z\\-_]/g, '')
        .replace(/\r\n/g, '\n')
        .replace(/\r/g, '');
    }

    function renderList() {
      $("header-host").textContent = location.hostname + " · tailnet";
      ["wait", "run", "idle"].forEach(st => {
        const box = $("list-" + st);
        box.innerHTML = "";
        const matched = sessions.filter(s => s.state === st);
        if (matched.length === 0) {
          const empty = document.createElement("div");
          empty.style.padding = "10px 16px";
          empty.style.color = "var(--muted)";
          empty.style.fontSize = "13px";
          empty.textContent = "No " + LABEL[st].toLowerCase() + " sessions";
          box.appendChild(empty);
          return;
        }
        matched.forEach(s => {
          const add = s.files ? s.files.reduce((a, f) => a + f[1], 0) : 0;
          const del = s.files ? s.files.reduce((a, f) => a + f[2], 0) : 0;
          const b = document.createElement("button");
          b.className = "sess";
          const fileStat = (s.files && s.files.length)
            ? `${s.files.length} files +${add} −${del}`
            : (s.filesCount ? `${s.filesCount} files +${s.filesAdditions || 0} −${s.filesDeletions || 0}` : 'clean');
          const branchDisplay = s.branch ? esc(s.branch) : '—';
          b.innerHTML = `<span class="dot ${st}"></span><span class="name">${aiIcon(s)}${esc(s.name)}<span class="agent">${esc(s.agent)}</span></span><span class="pill ${st}">${LABEL[st]}</span><span class="meta">${branchDisplay} · ${fileStat}</span>`;
          b.onclick = () => openSession(s);
          box.appendChild(b);
        });
      });
    }

    function openSession(s) {
      cur = s;
      const saved = view.s[s.id];
      if (saved) {
        cur.modelName = cur.modelName || saved.modelName;
        cur.effort = cur.effort || saved.effort;
        cur.usage = cur.usage || saved.usage;
        if (saved.out && cur.out.length <= 1) cur.out = saved.out;
      }
      saveView();
      $("scr-list").hidden = true; $("scr-list").style.display = "none";
      $("scr-sess").hidden = false; $("scr-sess").style.display = "contents";
      $("s-name").innerHTML = aiIcon(s) + esc(s.name);
      $("s-meta").textContent = s.agent + " · " + s.branch;
      if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify({ attach: s.id }));
        ws.send(JSON.stringify({ gitDiff: { path: s.cwd } }));
      }
      renderPane();
    }

    function back() {
      $("scr-sess").hidden = true; $("scr-sess").style.display = "none";
      $("scr-list").hidden = false; $("scr-list").style.display = "contents";
      if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify({ detach: true }));
      }
      cur = null;
      saveView();
      renderList();
    }
    $("back").onclick = back;

    // <md-start> small markdown subset. Source is untrusted agent output: everything is
    // HTML-escaped first, markup is only ever produced from the escaped text.
    function mdInline(t) { return esc(t).replace(/`([^`]+)`/g, "<code>$1</code>").replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>"); }
    function md(src) {
      const L = String(src || "").split("\n"); let h = "", i = 0;
      while (i < L.length) {
        const l = L[i];
        if (!l.trim()) { i++; continue; }
        if (/^```/.test(l)) {
          const code = []; i++;
          while (i < L.length && !/^```/.test(L[i])) code.push(L[i++]);
          i++;
          h += "<pre><code>" + esc(code.join("\n")) + "</code></pre>"; continue;
        }
        if (/^#{1,6} /.test(l)) { h += "<h4>" + mdInline(l.replace(/^#+ /, "")) + "</h4>"; i++; continue; }
        if (/^\|/.test(l)) {
          const rows = [];
          while (i < L.length && /^\|/.test(L[i])) { if (!/^\|[-| :]+\|$/.test(L[i])) rows.push(L[i].split("|").slice(1, -1).map(c => c.trim())); i++; }
          h += '<div class="tbl"><table>' + rows.map((r, j) => "<tr>" + r.map(c => j ? "<td>" + mdInline(c) + "</td>" : "<th>" + mdInline(c) + "</th>").join("") + "</tr>").join("") + "</table></div>"; continue;
        }
        if (/^[-*] /.test(l)) { h += "<ul>"; while (i < L.length && /^[-*] /.test(L[i])) h += "<li>" + mdInline(L[i++].slice(2)) + "</li>"; h += "</ul>"; continue; }
        if (/^\d+\. /.test(l)) { h += "<ol>"; while (i < L.length && /^\d+\. /.test(L[i])) h += "<li>" + mdInline(L[i++].replace(/^\d+\. /, "")) + "</li>"; h += "</ol>"; continue; }
        h += "<p>" + mdInline(l) + "</p>"; i++;
      }
      return h;
    }
    // <md-end>

    const MODEL_OPTS = [
      ["opus", "Opus", "Hardest work: plans, reviews, tricky bugs"],
      ["sonnet", "Sonnet", "Everyday coding"],
      ["haiku", "Haiku", "Fast, cheap: summaries, search"],
      ["fable", "Fable", "Largest model"]];
    // agy's list arrives from the daemon (it runs `agy models`), asked for once per page load the
    // first time an agy session is open. Empty until then: the daemon only accepts what agy lists.
    let agyModelOpts = [], agyEfforts = [], agyAsked = false;
    const isAgy = () => !!cur && /antigravity|agy/i.test(cur.agent || "");
    const modelOpts = () => isAgy() ? agyModelOpts : MODEL_OPTS;
    const effortOpts = () => isAgy() ? agyEfforts : EFFORTS;
    function askAgyModels() {
      if (agyAsked || !isAgy() || !ws || ws.readyState !== WebSocket.OPEN) return;
      agyAsked = true;
      ws.send(JSON.stringify({ agyModels: true }));
    }
    const EFFORTS = ["low", "medium", "high", "xhigh", "max"];
    const EFFORT_LABEL = { low: "Low", medium: "Medium", high: "High", xhigh: "XHigh", max: "Max" };
    const MODE_OPTS = [
      ["auto", "Auto", "The agent handles permission decisions"],
      ["manual", "Manual", "Ask before every change"],
      ["acceptEdits", "Accept edits", "Accept file edits, ask for commands"],
      ["plan", "Plan", "Write a plan before changing anything"]];
    const modeName = id => { const m = MODE_OPTS.find(x => x[0] === id); return m ? m[1] : id; };
    function modelLabel(id) {
      const m = /^claude-([a-z]+)-(\d{1,2})(?:-(\d{1,2})(?!\d))?/.exec(id || "");
      if (!m) return id || "";
      return m[1][0].toUpperCase() + m[1].slice(1) + " " + m[2] + (m[3] ? "." + m[3] : "");
    }
    // The model/effort/mode controls drive Claude Code's or agy's own TUI slash commands; other agents
    // have no verified mechanism. Mode (Shift+Tab cycle) is only verified for Claude.
    const canControl = () => !!cur && (cur.transcript || /claude/i.test(cur.agent || "") || isAgy());

    // Working = the agent still owes a reply. With a transcript: last item is the user's message or a
    // tool call, and the daemon does not say idle/waiting. Without: the daemon's activity state.
    function isWorking() {
      if (!cur) return false;
      if (cur.transcript) {
        const last = [...cur.out].reverse().find(x => x[0] === "user" || x[0] === "agent" || x[0] === "tool" || x[0] === "img");
        if (!last || last[0] === "agent") return false;
        return cur.state === "run" || (cur.sentAt && Date.now() - cur.sentAt < 4000);
      }
      return cur.state === "run";
    }

    function renderPane() {
      if (!cur) return;
      const p = $("pane");
      const wasAtBottom = (p.scrollHeight - p.scrollTop - p.clientHeight) < 60;
      const items = cur.out;
      let h = "", i = 0;
      while (i < items.length) {
        const [k, t] = items[i];
        if (k === "tool") {
          const run = []; const start = i;
          while (i < items.length && items[i][0] === "tool") run.push(items[i++][1]);
          const rows = run.map(x => { const sp = x.indexOf(" "); return sp < 0 ? [x, ""] : [x.slice(0, sp), x.slice(sp + 1)]; });
          if (rows.length === 1 || cur["tools" + start]) {
            h += '<div class="tools">' + rows.map(([n, a]) => `<div class="tool"><b>${esc(n)}</b><span>${esc(a)}</span></div>`).join("") +
              (rows.length > 1 ? `<button class="toolsum" data-tools="${start}">▾ Hide</button>` : "") + "</div>";
          } else {
            h += `<button class="toolsum" data-tools="${start}">▸ ${rows.length} tool calls · ${esc([...new Set(rows.map(r => r[0]))].join(", "))}</button>`;
          }
          continue;
        }
        const idx = i++;
        if (k === "user") h += `<div class="msg user">${esc(t)}</div>`;
        else if (k === "img") h += `<div class="img" role="img" aria-label="Attached image">▣ image</div>`;
        else if (k === "agent") {
          const long = t.length > 520 && !cur["open" + idx];
          h += `<div class="bot${long ? " clamp" : ""}">${md(t)}</div>` + (long ? `<button class="more" data-more="${idx}">Show more</button>` : "");
        }
        else if (k === "diff") {
          const a = cur.files.reduce((x, f) => x + f[1], 0), d = cur.files.reduce((x, f) => x + f[2], 0);
          h += `<button class="card" data-c="diff"><span class="ic">±</span><span class="tx"><b>${cur.files.length} files changed</b><span>+${a} −${d} · ${esc(cur.files.map(f => f[0].split("/").pop()).join(", "))}</span></span><span class="go">Diff</span></button>`;
        }
        else if (k === "preview") h += `<button class="card" data-c="pv"><span class="ic">◳</span><span class="tx"><b>Dev server running</b><span>${esc(t)}</span></span><span class="go">Open</span></button>`;
        else if (k === "pr") h += `<button class="card" data-c="pr"><span class="ic">⇡</span><span class="tx"><b>Ready for review</b><span>${esc(cur.branch)} → main</span></span><span class="go">Create draft PR</span></button>`;
        else if (k === "prdone") {
          const rawUrl = (cur.pr && cur.pr.url) ? String(cur.pr.url) : '';
          const isSafe = rawUrl.startsWith("https://github.com/");
          const safeUrl = isSafe ? esc(rawUrl) : '#';
          const displayUrl = isSafe ? esc(rawUrl.replace('https://', '')) : 'invalid URL';
          const prNum = esc(String(cur.pr ? cur.pr.n : ''));
          h += `<a class="card" href="${safeUrl}" target="_blank" rel="noopener noreferrer"><span class="ic">⇡</span><span class="tx"><b>Draft PR #${prNum} opened</b><span>${displayUrl}</span></span><span class="go">GitHub ↗</span></a>`;
        }
        else if (k === "ask") h += `<div class="ask"><div><strong>Approval needed</strong></div><div class="tool"><span>${esc(t)}</span></div><div class="row"><button class="btn primary" data-a="y">Allow</button><button class="btn ghost" data-a="n">Deny</button></div></div>`;
        else h += `<div class="bot"><p>${esc(t)}</p></div>`;
      }
      if (isWorking()) h += '<div class="working"><i></i>Working…</div>';
      p.innerHTML = '<div class="out">' + h + '</div>';

      p.querySelectorAll("[data-more]").forEach(b => b.onclick = () => { cur["open" + b.dataset.more] = 1; renderPane(); });
      p.querySelectorAll("[data-tools]").forEach(b => b.onclick = () => { const k = "tools" + b.dataset.tools; cur[k] = !cur[k]; renderPane(); });
      p.querySelectorAll("[data-a]").forEach(b => {
        b.onclick = () => {
          const ans = b.dataset.a;
          if (ws && ws.readyState === WebSocket.OPEN) ws.send(new TextEncoder().encode(ans + '\r'));
          cur.out.push(["tool", (ans === "y" ? "✓ allowed" : "✗ denied")]);
          renderPane();
        };
      });
      p.querySelectorAll("[data-c]").forEach(c => {
        c.onclick = () => ({ diff: openDiff, pv: openPreview, pr: openPR })[c.dataset.c]();
      });

      if (wasAtBottom) p.scrollTop = p.scrollHeight;
      const add = cur.files ? cur.files.reduce((x, f) => x + f[1], 0) : 0;
      const del = cur.files ? cur.files.reduce((x, f) => x + f[2], 0) : 0;
      $("d-add").textContent = "+" + add;
      $("d-del").textContent = "−" + del;
      $("diff-btn").disabled = !cur.files || !cur.files.length;
      renderComposer();
      syncSend();
    }

    function renderComposer() {
      askAgyModels();
      const show = canControl();
      $("ctl").hidden = !show;
      if (!show) return;
      const eff = cur.effort ? ` <span class="k">· ${EFFORT_LABEL[cur.effort] || esc(cur.effort)}</span>` : "";
      $("model-chip").innerHTML = `${esc(cur.modelName || "Model")}${eff} <span class="car">▾</span>`;
      const inCycle = MODE_OPTS.some(x => x[0] === cur.mode);
      const mc = $("mode-chip");
      mc.hidden = !cur.mode;
      mc.disabled = !inCycle; // a mode outside Shift+Tab's cycle (e.g. bypass) is shown, not switchable
      mc.className = "chipbtn" + (cur.mode === "plan" ? " mode-plan" : "");
      mc.innerHTML = `${esc(modeName(cur.mode || ""))}${inCycle ? ' <span class="car">▾</span>' : ""}`;
      const uc = $("usage-chip");
      const u = cur.usage;
      let summary = u ? (u.shortSummary || null) : null;
      if (!summary && u) {
        if (u.totalCostUSD != null && u.totalCostUSD > 0.0001) summary = `$${u.totalCostUSD.toFixed(2)}`;
        else {
          const ctx = (u.contextTokens != null) ? u.contextTokens : ((u.inputTokens || 0) + (u.cacheReadTokens || 0));
          if (ctx > 0) summary = (ctx >= 1000 ? (ctx / 1000).toFixed(1) + "k" : ctx) + " ctx";
          else if (u.outputTokens) summary = (u.outputTokens >= 1000 ? (u.outputTokens / 1000).toFixed(1) + "k" : u.outputTokens) + " out";
        }
      }
      if (summary) {
        uc.hidden = false;
        uc.innerHTML = `📊 ${esc(summary)} <span class="car">▾</span>`;
      } else {
        uc.hidden = true;
      }
    }

    function sendAgentCommand(kind, value) {
      const agent = isAgy() ? "antigravity" : "claude-code";
      if (ws && ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify({ agentCommand: { kind, value, agent } }));
    }
    function openModel() {
      panel("Model", `<div class="pick" role="radiogroup" aria-label="Model">
        ${modelOpts().map(([id, name, d]) => `<button class="opt" role="radio" aria-checked="${cur.modelName === name || (cur.modelName || "").toLowerCase().startsWith(id)}" data-m="${id}"><span class="t">${name}</span><span class="ck">✓</span><span class="d">${esc(d)}</span></button>`).join("")}
        <h5>Effort</h5>
        <div class="seg" role="group" aria-label="Effort">${effortOpts().map(e => `<button data-e="${e}" aria-pressed="${e === cur.effort}">${EFFORT_LABEL[e]}</button>`).join("")}</div>
        ${isAgy() && !agyModelOpts.length ? '<p class="hint">agy\'s model list hasn\'t loaded yet — reopen this in a moment (it comes from `agy models` on the Mac).</p>' : ""}
        <p class="hint">Sent to ${isAgy() ? "agy" : "Claude Code"} as /model and /effort. ${isAgy() ? "The model" : "The effort"} can't be read back, so it shows what you last picked here.</p></div>`, true);
      $("panel-body").querySelectorAll("[data-m]").forEach(b => b.onclick = () => {
        const o = modelOpts().find(x => x[0] === b.dataset.m);
        sendAgentCommand("model", o[0]); cur.modelName = o[1]; renderComposer(); saveView(); $("panel").hidden = true;
      });
      $("panel-body").querySelectorAll("[data-e]").forEach(b => b.onclick = () => {
        sendAgentCommand("effort", b.dataset.e); cur.effort = b.dataset.e; renderComposer(); saveView(); $("panel").hidden = true;
      });
    }
    function openMode() {
      panel("Mode", `<div class="pick" role="radiogroup" aria-label="Mode">${MODE_OPTS.map(([id, name, d]) => `<button class="opt" role="radio" aria-checked="${id === cur.mode}" data-o="${id}"><span class="t">${name}</span><span class="ck">✓</span><span class="d">${esc(d)}</span></button>`).join("")}</div>`, true);
      $("panel-body").querySelectorAll("[data-o]").forEach(b => b.onclick = () => {
        sendAgentCommand("mode", b.dataset.o); cur.mode = b.dataset.o; renderComposer(); $("panel").hidden = true; toast("Mode: " + modeName(cur.mode), "Shift+Tab");
      });
    }
    function openUsage() {
      if (!cur || !cur.usage) return;
      const u = cur.usage;
      const fmt = n => (n != null ? n.toLocaleString() : "—");
      const computedCtx = (u.contextTokens != null) ? u.contextTokens : ((u.inputTokens || 0) + (u.cacheReadTokens || 0));
      const ctx = computedCtx > 0 ? fmt(computedCtx) : (u.inputTokens != null ? fmt(u.inputTokens) : "—");
      const cost = u.totalCostUSD != null ? `$${u.totalCostUSD.toFixed(3)}` : (u.costUSD != null ? `$${u.costUSD.toFixed(3)}` : null);
      const html = `<div style="padding: 12px 14px; font-size: 14px; line-height: 1.6;">
        <div style="font-weight: 700; margin-bottom: 8px; color: var(--accent);">Token & Cost Breakdown</div>
        <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
          <tr><td style="padding: 4px 0; color: var(--muted);">Context Window:</td><td style="text-align: right; font-weight: 600;">${ctx}</td></tr>
          <tr><td style="padding: 4px 0; color: var(--muted);">Input Tokens:</td><td style="text-align: right; font-weight: 600;">${fmt(u.inputTokens)}</td></tr>
          <tr><td style="padding: 4px 0; color: var(--muted);">Output Tokens:</td><td style="text-align: right; font-weight: 600;">${fmt(u.outputTokens)}</td></tr>
          <tr><td style="padding: 4px 0; color: var(--muted);">Cache Read:</td><td style="text-align: right; font-weight: 600;">${fmt(u.cacheReadTokens)}</td></tr>
          <tr><td style="padding: 4px 0; color: var(--muted);">Cache Creation:</td><td style="text-align: right; font-weight: 600;">${fmt(u.cacheWriteTokens)}</td></tr>
          ${u.thinkingTokens ? `<tr><td style="padding: 4px 0; color: var(--muted);">Thinking Tokens:</td><td style="text-align: right; font-weight: 600;">${fmt(u.thinkingTokens)}</td></tr>` : ""}
          ${cost ? `<tr style="border-top: 1px solid var(--line);"><td style="padding: 6px 0 0 0; font-weight: 700; color: var(--ink);">Total Cost:</td><td style="padding: 6px 0 0 0; text-align: right; font-weight: 700; color: var(--accent);">${cost}</td></tr>` : ""}
        </table>
      </div>`;
      panel("Session Usage", html, true);
    }

    function panel(title, html, small) {
      $("panel-t").textContent = title;
      $("panel-body").innerHTML = html;
      $("panel-box").className = "panel" + (small ? " small" : "");
      $("panel").hidden = false;
    }
    $("panel-x").onclick = () => { $("panel").hidden = true; };
    $("panel").onclick = e => { if (e.target.id === "panel") $("panel").hidden = true; };

    function openDiff() {
      if (!cur || !cur.files || !cur.files.length) return;
      panel(`Diff · ${cur.files.length} files`,
        '<div class="files">' + cur.files.map(([path, a, d, unc, h], i) => `
          <details class="file" ${i === 0 ? "open" : ""}>
            <summary>
              <span class="path">${esc(path)}</span>
              ${unc ? '<span class="badge">UNCOMMITTED</span>' : ''}
              <span class="stat"><span class="a">+${a}</span> <span class="d">−${d}</span></span>
            </summary>
            <div class="hunk">${(h || []).map(l => `<div class="${l.startsWith("@@") ? "h" : l[0] === "+" ? "add" : l[0] === "-" ? "del" : ""}">${esc(l)}</div>`).join("")}</div>
          </details>
        `).join("") + '</div>'
      );
    }

    // Artifact link formats per agent. Claude, Copilot and Antigravity are taken from real
    // session logs; Codex is its cloud-task URL; anything else artifact-like is a generic "Link".
    // Antigravity artifacts are local files it rewrites in place (brain/<conversation>/<name>),
    // so the file on disk is always the newest version; the daemon reads it for the phone.
    const ARTIFACT_KINDS = [
      ["Claude", /^https:\/\/claude\.ai\/(?:code\/)?artifacts?\//i],
      ["Copilot", /^https:\/\/github\.com\/copilot\/tasks\//i],
      ["Codex", /^https:\/\/chatgpt\.com\/codex\/tasks\//i],
      ["Antigravity", /^file:\/\/\/.*\/antigravity-cli\/brain\/[0-9a-f-]+\/[^/.][^/]*\.(?:md|html?)$/i],
      ["Link", /^https?:.*(?:artifact|preview|page)/i],
    ];

    // One entry per link, each at its newest version: links that differ only by a version
    // marker (?v=N, /v/N, /versions/N) or query/hash collapse to the last one printed.
    // Order is by agent kind, then first appearance, so chips don't reshuffle as versions stream in.
    function latestArtifactLinks(text) {
      const latest = new Map();
      for (const m of (text || "").matchAll(/(?:https?|file):\/\/[^\s<>"'`)\]]+/gi)) {
        const url = m[0].replace(/[.,;:]+$/, "");
        const kind = ARTIFACT_KINDS.find(([, re]) => re.test(url));
        if (!kind) continue;
        const key = url.replace(/[?#].*$/, "").replace(/\/(?:v|versions?)\/[^/]+\/?$/i, "").replace(/\/$/, "");
        latest.set(key, [kind[0], url]); // re-set keeps the key's first-seen position, updates the URL
      }
      const links = [...latest.values()];
      return ARTIFACT_KINDS.flatMap(([k]) => {
        const ofKind = links.filter(l => l[0] === k);
        return ofKind.map((l, i) => [ofKind.length > 1 ? `${k} ${i + 1}` : k, l[1]]);
      });
    }

    function openPreview() {
      if (!cur) return;
      const port = (cur.ports && cur.ports[0]) || (cur.rawOutput && cur.rawOutput.includes('localhost:') ? (cur.rawOutput.match(/localhost:(\d+)/) || [])[1] : null);
      const htmlFile = cur.files ? cur.files.find(f => f[0].toLowerCase().endsWith('.html')) : null;
      const arts = latestArtifactLinks(cur.rawOutput);

      const src = {};
      if (port) {
        src.local = ["Dev server", `http://localhost:${port}/`];
      }
      if (htmlFile) {
        src.html = ["HTML file", htmlFile[0]];
      }
      arts.forEach((a, i) => { src["art" + i] = a; });

      if (!src[pv]) pv = Object.keys(src)[0];
      if (!pv) {
        panel("Preview", `<p class="caption">No dev server, HTML file or artifact link seen in this session yet.</p>`);
        return;
      }
      const url = src[pv][1];
      const localFile = url.startsWith("file://");

      let bodyHTML = "";
      let captionText = "";
      if (pv === "local") {
        bodyHTML = `
          <div class="pv-viewport" style="background:#fff;border-radius:8px;overflow:hidden;border:1px solid var(--line);min-height:240px;display:flex;align-items:center;justify-content:center;position:relative">
            <div id="pv-loading" style="padding:40px 16px;text-align:center;color:var(--muted);font-size:13px">Connecting to browser mirror…</div>
            <img id="pv-frame" style="width:100%;display:none;object-fit:contain" alt="Preview frame" />
          </div>
          <div class="pv-bar" style="display:flex;gap:8px;margin-top:8px">
            <button class="btn ghost" id="pv-reload" style="padding:6px 12px;font-size:12px">↻ Reload</button>
            <button class="btn ghost" id="pv-snap" style="padding:6px 12px;font-size:12px">📸 Capture</button>
          </div>
        `;
        captionText = "Mirrored live from Mac via Kouen browser mirror.";
      } else if (pv === "html" || localFile) {
        bodyHTML = `
          <div id="pv-html-content" style="background:#fff;border-radius:8px;min-height:200px;border:1px solid var(--line);padding:12px">
            <div style="color:var(--muted);font-size:13px;text-align:center;padding:24px 0">Loading workspace file…</div>
          </div>
        `;
        captionText = "Rendered from workspace file.";
      } else {
        bodyHTML = `
          <div style="background:var(--surface);border:1px solid var(--line);border-radius:10px;padding:20px;text-align:center">
            <p style="margin:0 0 12px 0;font-size:14px;color:var(--ink)">External artifact detected</p>
            <a class="btn primary" href="${esc(url)}" target="_blank" rel="noopener noreferrer" style="display:inline-block;padding:8px 16px;text-decoration:none">Open artifact ↗</a>
          </div>
        `;
        captionText = "External link.";
      }

      panel("Preview", `
        <div class="pv-src">${Object.entries(src).map(([k, v]) => `<button class="chip" data-pv="${k}" aria-pressed="${k === pv}">${esc(v[0])}</button>`).join("")}</div>
        <div class="urlbar">${esc(url)}</div>
        <div class="mock">${bodyHTML}</div>
        <p class="caption">${esc(captionText)}</p>
      `);

      $("panel-body").querySelectorAll("[data-pv]").forEach(b => {
        b.onclick = () => { pv = b.dataset.pv; openPreview(); };
      });

      if (pv === "local") {
        if (ws && ws.readyState === WebSocket.OPEN) {
          ws.send(JSON.stringify({ browserNavigate: { url } }));
        }
        const rBtn = $("pv-reload");
        if (rBtn) rBtn.onclick = () => { if (ws && ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify({ browserReload: true })); };
        const sBtn = $("pv-snap");
        if (sBtn) sBtn.onclick = () => { if (ws && ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify({ browserScreenshot: true })); };
      } else if (pv === "html" || localFile) {
        const fullPath = localFile ? decodeURIComponent(url.slice("file://".length))
          : cur.cwd ? (cur.cwd.replace(/\/$/, '') + '/' + url) : url;
        if (ws && ws.readyState === WebSocket.OPEN) {
          ws.send(JSON.stringify({ readFile: { path: fullPath } }));
        }
      }
    }

    function syncSend() {
      const stop = isWorking() && !$("msg").value.trim() && !atts.length;
      const b = $("send");
      b.textContent = stop ? "■" : "↑";
      b.classList.toggle("stopping", stop);
      b.setAttribute("aria-label", stop ? "Stop agent" : "Send");
    }

    function renderAtts() {
      $("atts").innerHTML = atts.map(a => {
        const name = typeof a === 'object' ? a.name : a;
        const loading = typeof a === 'object' && a.loading;
        return `<span class="att">${loading ? '⏳' : '📎'} ${esc(name)}</span>`;
      }).join("");
    }

    function send(text) {
      if (!text.trim() && !atts.length) {
        if (isWorking()) {
          if (ws && ws.readyState === WebSocket.OPEN) {
            ws.send(JSON.stringify({ stop: true }));
          }
          cur.out.push(["tool", "■ stopping (Esc sent to pane)"]);
          renderPane();
          toast("Stopping " + cur.name, "Esc sent");
        }
        return;
      }
      if (atts.some(a => typeof a === 'object' && a.loading)) {
        toast("Still uploading", "wait for the attachment");
        return;
      }
      const readyPaths = atts.map(a => typeof a === 'object' ? (a.path || a.name) : a).filter(Boolean);
      const toSend = text.trim() + (readyPaths.length ? (text.trim() ? " " : "") + readyPaths.join(" ") : "");
      if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send(new TextEncoder().encode(toSend + '\r'));
      }
      const attNames = atts.map(a => typeof a === 'object' ? a.name : a);
      const fullDisplay = text + (attNames.length ? (text ? "\n" : "") + "📎 " + attNames.join(", ") : "");
      cur.out.push(["user", fullDisplay]);
      cur.sentAt = Date.now();
      setTimeout(() => { if (cur) renderPane(); }, 4100);
      atts = [];
      renderAtts();
      $("msg").value = "";
      renderPane();
    }

    function toast(t, s) {
      $("toast-t").textContent = t;
      $("toast-s").textContent = s || '';
      $("toast").hidden = false;
      clearTimeout(toast.h);
      toast.h = setTimeout(() => { $("toast").hidden = true; }, 3200);
    }

    function closeMenu() { $("menu").hidden = true; $("more").setAttribute("aria-expanded", "false"); }
    $("more").onclick = e => {
      e.stopPropagation();
      const m = $("menu");
      m.hidden = !m.hidden;
      $("more").setAttribute("aria-expanded", String(!m.hidden));
    };
    document.addEventListener("click", e => { if (!e.target.closest("#menu") && !e.target.closest("#more")) closeMenu(); });
    $("diff-btn").onclick = () => { closeMenu(); openDiff(); };
    $("pv-btn").onclick = () => { closeMenu(); openPreview(); };
    $("pr-btn").onclick = () => { closeMenu(); openPR(); };

    function openPR() {
      if (!cur) return;
      if (cur.pr) {
        if (cur.pr.url && String(cur.pr.url).startsWith("https://github.com/")) {
          window.open(cur.pr.url, '_blank');
        }
        return;
      }
      toast("Creating draft PR…", "gh pr create --draft");
      if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify({ createDraftPR: { title: cur.name || "Draft PR", path: cur.cwd } }));
      }
    }

    $("msg").addEventListener("input", syncSend);
    $("model-chip").onclick = openModel;
    $("mode-chip").onclick = openMode;
    $("usage-chip").onclick = openUsage;
    $("send").onclick = () => send($("msg").value);
    $("msg").addEventListener("keydown", e => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        send($("msg").value);
      }
    });

    $("file").onchange = e => {
      const files = Array.from(e.target.files);
      for (const f of files) {
        const item = { name: f.name, path: null, loading: true };
        atts.push(item);
        const reader = new FileReader();
        reader.onload = ev => {
          const b64 = ev.target.result.split(',')[1];
          if (ws && ws.readyState === WebSocket.OPEN) {
            ws.send(JSON.stringify({
              attachFile: {
                name: f.name,
                mimeType: f.type || "application/octet-stream",
                content: b64
              }
            }));
          }
        };
        reader.readAsDataURL(f);
      }
      renderAtts();
      e.target.value = "";
      syncSend();
    };

    function showPairing() {
      $("scr-pairing").hidden = false;
      $("scr-list").hidden = true; $("scr-list").style.display = "none";
      $("scr-sess").hidden = true; $("scr-sess").style.display = "none";
    }
    function hidePairing() {
      $("scr-pairing").hidden = true;
      if (!cur) {
        $("scr-list").hidden = false; $("scr-list").style.display = "contents";
      }
    }
    $("pair-btn").onclick = () => {
      const val = $("pair-token").value.trim();
      if (val && ws && ws.readyState === WebSocket.OPEN) {
        ws.send(val);
      }
    };

    // P57: the daemon tails the agent's own session file and sends typed items. Once any arrive,
    // this session renders from them (real user/agent bubbles + one-line tool rows) and the raw
    // PTY stream stops feeding the transcript — it still feeds rawOutput for Preview/port detection.
    const CARD_KINDS = ["diff", "preview", "pr", "prdone"];
    function applyTranscript(t) {
      if (!cur) return;
      if (t.reset || !cur.transcript) {
        cur.transcript = true;
        cur.seen = new Set();
        cur.out = cur.out.filter(x => CARD_KINDS.includes(x[0]));
      }
      for (const it of t.items || []) {
        if (cur.seen.has(it.id)) continue;
        cur.seen.add(it.id);
        if (it.attachment) cur.out.push(["img", it.attachment]);
        else if (it.role === "user") cur.out.push(["user", it.text]);
        else if (it.role === "assistant") cur.out.push(["agent", it.text]);
        else {
          const line = (it.toolName || "Tool") + (it.toolTarget ? " " + it.toolTarget : "");
          cur.out.push(["tool", line]);
          if (it.toolName === "Edit" || it.toolName === "Write" || it.toolName === "MultiEdit") scheduleGitDiff();
        }
      }
      if (cur.out.length > 400) cur.out = cur.out.slice(-400);
      if (t.model) cur.modelName = modelLabel(t.model);
      if (t.mode) cur.mode = t.mode;
      if (t.usage) cur.usage = t.usage;
      renderPane();
      saveView();
    }

    function handleWSJSON(msg) {
      if (msg.pong !== undefined) { onPong(); return; }
      if (msg.deviceCredentials) {
        localStorage.setItem(credKey, JSON.stringify(msg.deviceCredentials));
        authed = true;
        hidePairing();
      }
      if (msg.sessions) {
        authed = true;
        hidePairing();
        sessions = msg.sessions.map(s => {
          const existing = (cur && cur.id === s.surfaceID) ? cur : (sessions.find(x => x.id === s.surfaceID) || {});
          return {
            id: s.surfaceID,
            name: s.tabTitle || s.cwd.split('/').pop() || 'Session',
            agent: s.agent || (s.tabTitle && s.tabTitle.toLowerCase().includes('claude') ? 'claude' : 'agent'),
            kind: s.kind,
            state: s.state || (s.waiting ? 'wait' : 'idle'),
            cwd: s.cwd,
            branch: s.branch || '—',
            ports: s.ports || [],
            files: existing.files || [],
            filesCount: s.filesCount,
            filesAdditions: s.filesAdditions,
            filesDeletions: s.filesDeletions,
            out: existing.out || [["text", "Attached to session " + (s.tabTitle || s.surfaceID.slice(0, 8))]],
            rawOutput: existing.rawOutput || "",
            pr: existing.pr || null
          };
        });
        renderList();
        // First list after a (re)connect: reopen the saved session, or re-attach the one on screen —
        // the new socket has no attachment, so without this the open session silently goes stale.
        if (needsAttach) {
          needsAttach = false;
          const target = sessions.find(s => s.id === (cur ? cur.id : view.open));
          if (target) openSession(cur ? Object.assign(cur, { cwd: target.cwd }) : target);
        }
        if (cur) {
          const updated = sessions.find(s => s.id === cur.id);
          if (updated) {
            cur.state = updated.state;
            cur.branch = updated.branch;
            cur.agent = updated.agent;
            cur.kind = updated.kind;
            $("s-meta").textContent = cur.agent + " · " + cur.branch;
            renderComposer();
            if (cur.state === "idle" && cur.files && cur.files.length > 0 && cur.branch && cur.branch !== 'main' && cur.branch !== 'master' && cur.branch !== '—' && !cur.out.some(x => x[0] === 'pr' || x[0] === 'prdone')) {
              cur.out.push(["pr"]);
              renderPane();
            }
            syncSend();
          }
        }
      }
      if (msg.transcript) applyTranscript(msg.transcript);
      if (msg.agyModels) {
        agyModelOpts = msg.agyModels.models.map(([id, label]) => [id, label, id]);
        agyEfforts = msg.agyModels.efforts;
      }
      if (msg.ok === "attached") {
        if (cur) ws.send(JSON.stringify({ gitDiff: { path: cur.cwd } }));
      }
      if (msg.gitDiff && msg.gitDiff.files) {
        if (cur) {
          cur.files = msg.gitDiff.files.map(f => [f.path, f.additions, f.deletions, f.uncommitted, f.lines]);
          if (cur.files.length > 0 && !cur.out.some(x => x[0] === 'diff')) {
            cur.out.push(["diff"]);
          }
          if (cur.state === "idle" && cur.files.length > 0 && cur.branch && cur.branch !== 'main' && cur.branch !== 'master' && cur.branch !== '—' && !cur.out.some(x => x[0] === 'pr' || x[0] === 'prdone')) {
            cur.out.push(["pr"]);
          }
          renderPane();
        }
      }
      if (msg.ok === "draftPRCreated" || msg.draftPRCreated) {
        if (cur) {
          const prUrl = msg.url || (msg.draftPRCreated && msg.draftPRCreated.url);
          const prNum = msg.number || (msg.draftPRCreated && msg.draftPRCreated.number) || 1;
          cur.pr = { n: prNum, url: prUrl };
          const prIdx = cur.out.findIndex(x => x[0] === 'pr');
          if (prIdx >= 0) cur.out[prIdx] = ["prdone"];
          else if (!cur.out.some(x => x[0] === 'prdone')) cur.out.push(["prdone"]);
          renderPane();
          toast(`Draft PR #${cur.pr.n} opened`, 'launching GitHub…');
          if (prUrl && prUrl.startsWith('https://github.com/')) {
            window.open(prUrl, '_blank');
          }
        }
      }
      if (msg.ok === "fileAttached" || msg.fileAttached) {
        const filePath = msg.path || (msg.fileAttached && msg.fileAttached.path) || '';
        const fileName = msg.name || (msg.fileAttached && msg.fileAttached.name);
        const item = atts.find(a => typeof a === 'object' && a.loading && (!fileName || a.name === fileName))
                  || atts.find(a => typeof a === 'object' && a.loading);
        if (item) {
          item.path = filePath;
          item.loading = false;
        }
        renderAtts();
        syncSend();
        toast('File attached', (fileName || filePath.split('/').pop()));
      }
      if (msg.ok === "browserOpened" || msg.ok === "browserNavigated") {
        if (ws && ws.readyState === WebSocket.OPEN) {
          ws.send(JSON.stringify({ browserScreenshot: true }));
        }
      }
      if (msg.browserFrame) {
        const frameImg = $("pv-frame");
        if (frameImg) {
          frameImg.src = "data:image/png;base64," + msg.browserFrame.png;
          frameImg.style.display = "block";
          const loading = $("pv-loading");
          if (loading) loading.style.display = "none";
        }
      }
      if (msg.file) {
        const container = $("pv-html-content");
        if (container) {
          container.innerHTML = `<iframe sandbox srcdoc="${esc(msg.file.content)}" style="width:100%;height:320px;border:0;background:#fff;border-radius:8px"></iframe>`;
        }
      }
      if (msg.error) {
        toast('Error', msg.error);
        if (!authed && msg.error.includes('token')) showPairing();
      }
    }

    let gitDiffTimer = null;
    function scheduleGitDiff() {
      if (!cur) return;
      clearTimeout(gitDiffTimer);
      gitDiffTimer = setTimeout(() => {
        if (cur && ws && ws.readyState === WebSocket.OPEN) {
          ws.send(JSON.stringify({ gitDiff: { path: cur.cwd } }));
        }
      }, 1000);
    }

    // Fallback view only (agents with no transcript): drop TUI chrome that is not conversation.
    const CHROME_LINE = /[\u2500-\u259f\u2800-\u28ff]|CLAUDE CODE \||\bctx [░█ ]|\brem:\d+%|shift\+tab|\? for shortcuts|esc to interrupt|accept edits on|bypass permissions on/i;
    const PLACEHOLDER = /\[(?:Image|Pasted text|Pasted image)[^\]]*#\d+[^\]]*\]/g;
    function stripChrome(line) {
      if (CHROME_LINE.test(line)) return "";
      return line.replace(PLACEHOLDER, "");
    }

    function handleTerminalBytes(raw) {
      if (!cur) return;
      const clean = stripANSI(raw);
      if (!clean.trim()) return;
      cur.rawOutput += clean;
      if (cur.rawOutput.length > 65536) cur.rawOutput = cur.rawOutput.slice(-65536);
      const portMatch = clean.match(/localhost:(\d+)/);
      if (portMatch) {
        const pUrl = "http://localhost:" + portMatch[1] + "/";
        if (!cur.out.some(x => x[0] === 'preview' && x[1] === pUrl)) {
          cur.out.push(["preview", pUrl]);
        }
      }
      if (cur.transcript) return;
      // A line with no letter or digit is TUI redraw noise once cursor moves are stripped
      // (Copilot's "◉ " spinner frames, box borders) — each frame would otherwise become a row.
      const lines = clean.split('\n').map(stripChrome).filter(l => /[\p{L}\p{N}]/u.test(l));
      for (const line of lines) {
        const trimmed = line.trim();
        if (trimmed.startsWith('> ') || trimmed.startsWith('$ ')) {
          cur.out.push(["user", trimmed.slice(2)]);
        } else if (trimmed.startsWith('Edit ') || trimmed.startsWith('Read ') || trimmed.startsWith('Bash: ') || trimmed.startsWith('Running ') || trimmed.startsWith('View ')) {
          cur.out.push(["tool", trimmed]);
          if (trimmed.startsWith('Edit ')) {
            scheduleGitDiff();
          }
        } else if (trimmed.includes('(y/n)') || trimmed.includes('[y/n]') || trimmed.toLowerCase().includes('approval needed') || trimmed.toLowerCase().includes('permission to')) {
          cur.out.push(["ask", trimmed]);
        } else {
          cur.out.push(["text", trimmed]);
        }
      }
      if (cur.out.length > 200) cur.out = cur.out.slice(-200);
      renderPane();
    }

    let sawServerError = false;
    let ptyDecoder = new TextDecoder();
    function showError(msg) { toast('Notice', msg); }

    function connectWS() {
      if (ws && (ws.readyState === WebSocket.OPEN || ws.readyState === WebSocket.CONNECTING)) return;
      const isHttps = location.protocol === 'https:';
      const proto = isHttps ? 'wss:' : 'ws:';
      const portPart = (location.port && location.port !== "80" && location.port !== "443")
        ? ':' + location.port
        : (isHttps ? '' : (wsPort ? ':' + wsPort : ''));
      const wsUrl = proto + '//' + location.hostname + portPart + location.pathname + location.search;
      ws = new WebSocket(wsUrl);
      ws.binaryType = 'arraybuffer';
      ws.onopen = () => {
        needsAttach = true;
        ptyDecoder = new TextDecoder();
        const creds = storedCreds();
        sentCreds = !!creds;
        if (creds) {
          ws.send(JSON.stringify({ deviceAuth: creds }));
        } else if (params.get('token')) {
          ws.send(params.get('token'));
        } else {
          showPairing();
        }
      };
      ws.onmessage = e => {
        if (typeof e.data === 'string') {
          try { handleWSJSON(JSON.parse(e.data)); } catch (err) {}
        } else if (e.data instanceof ArrayBuffer) {
          // One streaming decoder: a Thai character (3 UTF-8 bytes) split across two frames
          // would otherwise decode as two U+FFFD halves.
          handleTerminalBytes(ptyDecoder.decode(e.data, { stream: true }));
        }
      };
      ws.onclose = (ev) => {
        // iOS drops the socket on every background/lock and the retry reconnects silently, so a
        // plain drop only becomes a notice once retries keep failing while the page is in view.
        const wasOpen = needsAttach !== null;
        failedRetries = wasOpen ? 0 : failedRetries + 1;
        needsAttach = null;
        // Stored credentials this daemon doesn't know (revoked, or another daemon's): drop them and
        // retry, so the QR token / pairing screen gets a turn instead of being rejected forever.
        if (ev.code === 1008 && sentCreds) {
          try { localStorage.removeItem(credKey); } catch {}
          sentCreds = false;
          setTimeout(connectWS, 300);
          return;
        }
        if (!sawServerError && (ev.code === 1008 || (failedRetries === 3 && document.visibilityState === 'visible'))) {
          showError(ev.code === 1008
            ? 'Pairing rejected — rescan the QR code.'
            : 'Connection lost — check the daemon is running and try again.');
        }
        setTimeout(connectWS, 2000);
      };
      ws.onerror = () => console.error('[kouen mobile] websocket error');
    }

    if ('serviceWorker' in navigator) navigator.serviceWorker.register('/sw.js').catch(() => {});
    // Liveness: iOS can leave a socket OPEN but dead after the page was in the background, so
    // OPEN alone proves nothing. Ping every 20s and on every return; no pong within 3s → drop it,
    // and reconnect now (re-attach replays the transcript, so nothing is lost). The dead socket's
    // onclose is detached first: on iOS it may fire much later and would clobber the new one.
    let pingSeq = 0, pongTimer = null;
    function checkAlive() {
      if (!authed || !ws || ws.readyState !== WebSocket.OPEN || pongTimer) return;
      const sock = ws;
      sock.send(JSON.stringify({ ping: ++pingSeq }));
      pongTimer = setTimeout(() => {
        pongTimer = null;
        if (ws !== sock) return;
        sock.onclose = null; sock.onmessage = null;
        try { sock.close(); } catch {}
        ws = null;
        connectWS();
      }, 3000);
    }
    function onPong() { clearTimeout(pongTimer); pongTimer = null; }
    setInterval(() => { if (document.visibilityState === 'visible') checkAlive(); }, 20000);
    function onReturn() {
      if (!ws || ws.readyState === WebSocket.CLOSED) connectWS(); else checkAlive();
    }
    document.addEventListener('visibilitychange', () => { if (document.visibilityState === 'visible') onReturn(); });
    window.addEventListener('pageshow', e => { if (e.persisted) onReturn(); });
    window.addEventListener('online', onReturn);
    connectWS();
    renderList();
    </script>
    </body>
    </html>
    """#


    /// Minimal header parse — just enough to detect a WS upgrade (`Upgrade: websocket` +
    /// `Connection: ... Upgrade ...` + `Sec-WebSocket-Key`) versus a plain page GET. The
    /// request line and path are ignored either way: this listener only ever serves the one
    /// page or the one bridge protocol, regardless of what path a client asks for.
    private static let manifestJSON = """
    {
      "name": "Kouen Companion",
      "short_name": "Kouen",
      "description": "Mobile companion for Kouen Terminal and AI Agents",
      "start_url": "/",
      "display": "standalone",
      "background_color": "#171d1a",
      "theme_color": "#2f6b4f",
      "icons": [
        {
          "src": "/icon.svg",
          "sizes": "any",
          "type": "image/svg+xml"
        }
      ]
    }
    """

    static let manifestResponse: Data = {
        let body = manifestJSON
        return Data("""
        HTTP/1.1 200 OK\r
        Content-Type: application/manifest+json; charset=utf-8\r
        Content-Length: \(body.utf8.count)\r
        Connection: close\r
        \r
        \(body)
        """.utf8)
    }()

    private static let serviceWorkerJS = """
    const CACHE_NAME = 'kouen-companion-v1';
    self.addEventListener('install', e => { self.skipWaiting(); });
    self.addEventListener('activate', e => { e.waitUntil(clients.claim()); });
    self.addEventListener('fetch', e => {
      if (e.request.url.includes('/?') || e.request.headers.get('Upgrade') === 'websocket') return;
      e.respondWith(fetch(e.request).catch(() => caches.match(e.request)));
    });
    """

    static let serviceWorkerResponse: Data = {
        let body = serviceWorkerJS
        return Data("""
        HTTP/1.1 200 OK\r
        Content-Type: application/javascript; charset=utf-8\r
        Content-Length: \(body.utf8.count)\r
        Connection: close\r
        \r
        \(body)
        """.utf8)
    }()

    private static let iconSVG = """
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
      <rect width="100" height="100" rx="22" fill="#2f6b4f"/>
      <path d="M28 25 L40 25 L40 45 L58 25 L74 25 L52 48 L76 75 L60 75 L40 52 L40 75 L28 75 Z" fill="#ffffff"/>
    </svg>
    """

    static let iconResponse: Data = {
        let body = iconSVG
        return Data("""
        HTTP/1.1 200 OK\r
        Content-Type: image/svg+xml; charset=utf-8\r
        Content-Length: \(body.utf8.count)\r
        Connection: close\r
        \r
        \(body)
        """.utf8)
    }()

}
