# AI Browser Control (kouen-mcp)

AI agents (Claude Code, Codex, Kiro) can see and interact with the embedded browser pane via `kouen-mcp`. No separate browser or Playwright process needed.

**What an agent can do:**

| Capability | Tool | Returns |
| --- | --- | --- |
| Open / navigate URL | `kouenBrowserOpen`, `kouenBrowserNavigate` | pane ID |
| Read DOM + elements | `kouenBrowserSnapshot` | accessibility tree with stable refs (e1, e2…) |
| Click / fill / scroll | `kouenBrowserInteract` | ok / error |
| Screenshot | `kouenBrowserScreenshot` | base64 PNG |
| Read console logs | included in snapshot | array of log strings |
| Network requests | `kouenBrowserNetwork` | url, method, status, req/res body |
| Cookies | `kouenBrowserCookies` | name, value, domain, expires, secure |
| localStorage / sessionStorage | `kouenBrowserStorage` | key/value pairs |

**Snapshot element format** — stable refs let agents interact without writing selectors:

```json
{ "id": "e7", "tag": "button", "role": "button", "text": "Save", "bounds": {"x":120,"y":340,"width":80,"height":32}, "visible": true }
```

**Default home page** is configurable in `settings.json`:

```json
{ "browserHomePage": "https://www.google.com" }
```

**Auto-close:** a browser pane an agent opened with `kouenBrowserOpen` closes itself when that agent goes idle (panes you opened, or that were reused, stay).

**Token efficiency:** snapshot returns structured data (~200–500 tokens), not screenshots or raw HTML — significantly cheaper than vision-based browser automation.

**Beyond the browser** — `kouen-mcp` registers 77 tools in total (`Tools/kouen-mcp/Sources/KouenMCP/ToolRegistry.swift`). The tables in this README cover the browser and Claude Code tools; the rest, by group:

| Group | Tools |
| --- | --- |
| Browser (also) | `kouenBrowserWait`, `kouenBrowserClose`, `kouenBrowserEvaluate`, `kouenBrowserGoBack`, `kouenBrowserGoForward`, `kouenBrowserReload`, `kouenBrowserDesignModeInfo` |
| Panes and sessions | `kouenList`, `kouenBoard`, `openDiffReview`, `readPaneOutput`, `kouenGetLastBlock`, `kouenGetBlock`, `setPaneLabel`, `sendPaneText`, `sendPaneKeys`, `spawnSession`, `splitPane`, `closePane`, `waitForPaneOutput` |
| Files and commands | `readFile`, `writeFile`, `listDirectory`, `runCommand` |
| Git | `gitStatus`, `gitDiff`, `gitLog`, `kouenPRStatus` |
| Code navigation | `kouenFind`, `kouenGrep`, `kouenRecent`, `kouenErrors` |
| Agents and swarm | `kouenSpawnAgent`, `kouenSpawnWorker`, `kouenSwarmList`, `kouenSwarmInput`, `kouenSwarmTerminate` |
| Tasks | `kouenTaskList`, `kouenTaskGet`, `kouenTaskCreate`, `kouenTaskUpdate`, `kouenTaskDelete` |
| Features (AI-SDLC) | `kouenFeatureCreate`, `kouenFeatureGet`, `kouenFeatureList`, `kouenFeatureApproveGate`, `kouenFeatureUpdatePhase`, `kouenContextResolve`, `kouenFeaturePreview` |
| Worktrees, hosts, projects | `kouenWorktreeList`, `kouenWorktreeCreate`, `kouenWorktreeRemove`, `kouenHostList`, `kouenProjectsList` |
| Automations | `kouenAutomationList`, `kouenAutomationGet`, `kouenAutomationCreate`, `kouenAutomationUpdate`, `kouenAutomationDelete`, `kouenAutomationPause`, `kouenAutomationResume`, `kouenAutomationRunNow` |
| Agent routing rules | `kouenRoutingRuleList`, `kouenRoutingRuleCreate`, `kouenRoutingRuleUpdate`, `kouenRoutingRuleDelete`, `kouenRoutingRuleReorder` |
