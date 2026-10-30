# Project Structure Standard (role-based, stack-agnostic)

## Contents

- [0. Enforcement: three levels, no optional tier](#0-enforcement-three-levels-no-optional-tier)
- [1. Roles (fixed vocabulary)](#1-roles-fixed-vocabulary)
- [2. Root layout (every project)](#2-root-layout-every-project)
- [3. Source layout by size](#3-source-layout-by-size)
- [4. Dependency direction](#4-dependency-direction)
- [5. Naming](#5-naming)
- [6. Principles](#6-principles)
- [7. Review checklist](#7-review-checklist)
- [8. Not applicable](#8-not-applicable)

Same idea as `rules/playwright/pw-coding-standards.md`: fixed role names, a tree with placeholders,
dependency direction, and a review checklist. Independent of what the project does or its language.
Repos with their own enforced layout (Maven, a team template, `pw-coding-standards.md`) keep it and are out of scope. Read-only third-party clones are never touched.

## 0. Enforcement: three levels, no optional tier

| Level | Meaning | Broken, nothing recorded | To bend it |
|---|---|---|---|
| **MUST** | the core; the structure means nothing without it | FAIL | record a deviation citing a real external constraint (framework, vendored code, platform) |
| **STRONG** | important and costs real pain if ignored, but a project can have a reason | FAIL on new/changed work until fixed or recorded | record a deviation with any real reason **and a revisit date** |
| **SHOULD** | easy, cheap defaults | WARN | fix it, or record/ignore |

Every rule is one of these three. Anything not listed is not governed by this file.

**Deviation:** one line in the project's `ARCHITECTURE.md` under `## Structure deviations`:
`- §<rule> — <why> — <revisit when>`. A recorded deviation reports as `ACCEPTED`. Deviations are for real
constraints, not convenience.

**MUST:** one dir = one role (§1) · dependency direction (§4) · no hardcoded colors/thresholds outside config (§6) ·
secrets and runtime cache gitignored (§6) · **`tests/` exists, outside source (§1)** · framework's `<source-root>` name kept (§2) ·
`README.md`, `.gitignore`, `ARCHITECTURE.md` at root (§2) · **project `.claude/settings*.json` never excludes the installed rules**
(no `**/.claude/rules/**` in `claudeMdExcludes`; it silently drops them).
**STRONG:** size matches the file count (§3, including which size to start at) · `[layer]/[feature]` nesting inside a role dir (§3) ·
no stray files at root (§2) · deterministic JSON (§6) · `CLAUDE.md`, `AGENTS.md`, `CONTEXT.md` present.
**SHOULD:** canonical role names over aliases (§1) · `docs/` and `scripts/` exist · naming conventions (§5; root docs are UPPERCASE.md) ·
extra dirs (`plans/` `spikes/` ...) each have one clear purpose.

## 1. Roles (fixed vocabulary)

| Role | Canonical dir | Accepted aliases (existing projects, don't rename) | Holds |
|---|---|---|---|
| UI | `ui/` | `components/` `pages/` `screens/` `Views/` `static/` `*App` target | what the user sees |
| Feature | `features/[feature-kebab]/` | `*ViewModel` `*Service` `*Daemon` | orchestrates one feature end to end |
| Logic | `logic/` | `engine/` `hooks/` `lib/` `*Core` `*Engine` | rules, calculators — **no I/O** |
| Integration | `integrations/` | `services/` `Bridges/` `Providers/` `*Runner` `*IPC` `functions/` | API, CLI, DB, OS, network |
| Config | `config/` | `*Theme` `*Settings` `DesignSystem` `EnvConfig` | tokens, thresholds, settings |
| Models | `models/` | `types/` `*Models` `Errors` | shapes, errors, enums |
| Data | `data/` | `Resources/` `fixtures/` | seed, snapshots, word banks — **data only** |
| Tests | `tests/` | `Tests/` `src/test` | mirrors the roles above |

One directory = one role. A catch-all (`data/` holding config + logic + services + raw) is a violation.

## 2. Root layout (every project)

```
README.md  CLAUDE.md  AGENTS.md  ARCHITECTURE.md  CONTEXT.md  [PRODUCT.md  DESIGN.md]  .gitignore
[CHANGELOG.md  cliff.toml  Makefile]
docs/ (adr/)   scripts/ (tooling only)   <source-root>/   tests/   <- tests/ is MUST
```
- `<source-root>` = what the framework dictates (`src/` `app/` `Sources/` `Packages/` `scenes/`). Never rename it.
- Nothing else loose at root: no stray `fix_*.py`, one-off `*.js`, `*.txt`. Put in `scripts/` or delete.
- Test output (`playwright-report/` `test-results/` `output/`) and caches are gitignored.

### 2.1 Project runner (MAY)

One entry point so neither a person nor an agent has to guess ports or chain commands:
- **Three servers:** dev (hot reload), test (fixtures/mocks, its own port, what Playwright and QA run against), preview/prod build.
- **Runner** (`npm start`, `make start`, `scripts/start.*`): an arrow-key menu for people (commit/push/merge, dev, test, release gate, release + deploy, showing the current and next versions) that also takes the choice as an argument or env var (`npm start 2`, `START_CHOICE=dev`, `--yes` / `CI` for no prompts), so agents and CI never hit the menu. Falls back to a numbered prompt when stdin is not a TTY.
- **Desktop launcher (optional):** a double-click file (`.command` on macOS, `.bat` on Windows) that sets up the env, frees the port, starts the server, waits for a health check and opens the browser.

## 3. Source layout by size

Size is STRONG. Move up a size when a folder stops being scannable (thresholds are guides; bend with a recorded deviation). Role names stay; the container changes.

**Small (≲ 50 files)** — flat, role in filename: `[Feature][Role].ext`
```
<src>/ ConversationScreen  ConversationService  ConversationEngine  ConversationModels  EnvConfig  DesignSystem
```
**Medium** — one dir per role, features inside
```
<src>/
├── ui/[feature-kebab]/
├── features/[feature-kebab]/
├── logic/[feature-kebab]/
├── integrations/[system-kebab]/
├── config/ (theme/ metrics/ settings)
├── models/
└── data/ (baseline/ cache/ [snapshot]/)
```
**Large** — one module/package per role: `Packages/[Name]Core` `[Name]Theme` `[Name]Settings` `[Name]Daemon` `[Name]Kit`,
apps in `Apps/[Name]`. An app target must itself drop to Medium layout once it passes ~50 files.

## 4. Dependency direction

```
ui -> features -> logic
features -> integrations
ui, features, logic, integrations -> models, config
logic: NO import of ui/integrations/features.  models, config: import nothing.
```

## 5. Naming

- Root-level documentation files are UPPERCASE with `.md`, like `ARCHITECTURE.md`: `README` `ARCHITECTURE` `CONTEXT` `PRODUCT` `DESIGN` `AGENTS` `CLAUDE` `CHANGELOG` `SECURITY` (+ `LICENSE`). Files under `docs/` keep their own convention (ADRs: `docs/adr/NNNN-kebab-title.md`).
- Dirs: kebab-case (`[feature-kebab]`); Swift targets PascalCase. Files: the language's convention; small size uses `[Feature][Role]`.
- Integration files name the system: `PaymentGatewayBridge`, `CliRunner`, `mail_client.py`.
- Config files: `config/theme/colors.json`, `config/metrics/[domain].json` (`display`, `definition`, `thresholds[].level`).

## 6. Principles

- No hardcoded colors or business thresholds outside `config/`.
- Secrets/PATs gitignored (`local.config.json`, `.env`); runtime cache gitignored; leak test where feasible.
- Tracked baseline vs ignored cache; JSON writes `sort_keys=True, indent=2`, lists sorted by ID.
- **Anti-Monolith:** § Anti-Monolith & Separation Pattern in `rules/coding.md`.

## 7. Review checklist

Report each line as `PASS` / `FAIL` (MUST, or STRONG with nothing recorded) / `WARN` (SHOULD) / `ACCEPTED` (deviation recorded), with file evidence:
1. §1 one home per role.  2. §2 root files; stray files (STRONG).  3. §3 size and nesting (STRONG).
4. §4 no forbidden import.  5. `tests/` exists and sits outside source (always MUST; the only way to waive it is a recorded deviation).  6. §6 principles (including target file size ~300–400 lines and role separation).  7. Deviations section exists if any deviation is claimed.  8. `claudeMdExcludes` in the project's `.claude/settings*.json` does not match the installed `rules/**`.

## 8. Not applicable

Config repos (vendored third-party components), data mirrors, framework-mandated
plugin layouts: apply §2 and §6 only.
