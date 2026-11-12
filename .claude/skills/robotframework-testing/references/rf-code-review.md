# Robot Framework Code Review

Static code audit checklist — run BEFORE executing mobile tests.
MUST read `rules/robot/` first to know the full standards.

## When to Use

- After writing/generating Robot + Python code (before first run)
- After healing loop fixes (verify fix quality)
- PR review for test code changes

## Review Process

Load standards first: `rules/robot/rf-coding-standards.md` + `android.md` or `ios.md`.
Then follow `rules/coding/review-report.md`'s Code Review Report Format process shape.

## Checklist

### Structure & Naming
- [ ] Test case names: `[TC-xxx] Descriptive Name` with scenario ID
- [ ] Tags: `Scenario:Success`, `Scenario:Error`, `Priority:High`
- [ ] AAA pattern in keywords: Arrange → Act → Assert sections
- [ ] One .robot file per feature — not one giant file
- [ ] File naming: `camelCase.robot` for test files, `camelCasePage.robot` for pages

### Locators (Critical — Mobile)
- [ ] Priority: `accessibility_id` > `id` > `xpath` (last resort)
- [ ] Identical naming across Android and iOS for shared keywords
- [ ] No hardcoded coordinates or pixel-based locators
- [ ] Locators in variables section or page object — not inline in test cases
- [ ] Platform-specific locators wrapped in IF/ELSE or separate page files

### Appium Configuration
- [ ] Desired capabilities in YAML or variables — not hardcoded
- [ ] Implicit wait configured — no `Sleep` keywords
- [ ] App lifecycle: install/launch/close handled in Suite Setup/Teardown

### Database (if applicable)
- [ ] Python DB service class — not raw SQL in .robot files
- [ ] Seed/verify/cleanup pattern: beforeAll → test → afterAll
- [ ] Connection config from environment variables

### Keywords Quality
- [ ] Keywords are reusable — not copy-pasted across files
- [ ] Arguments have default values where sensible
- [ ] Return values documented with `[Return]` or `RETURN`
- [ ] No `Sleep` — use explicit waits (`Wait Until Element Is Visible`)
- [ ] Keyword names identical across Android/iOS for dual-platform support

### Expert Gems (Advanced)
- [ ] API Hybrid Setup: use API calls for preconditions instead of UI navigation
- [ ] Self-healing logs: descriptive action logging for healer to understand intent
- [ ] YAML fixtures for test data — not hardcoded in test cases
- [ ] Secret variables for sensitive data (RF 7.4+)

### Code Quality
- [ ] Docstrings on custom Python keywords
- [ ] No commented-out test cases
- [ ] No TODO without ticket reference
- [ ] Variables section organized: locators → test data → config

## Review Report Format & Severity Guide

Shared shape across every code-review checklist in this workspace — see
`rules/coding/review-report.md`'s Code Review Report Format (QA column of the severity table).
This file adds only the `Platform: Android / iOS` header line.

**Severity criteria specific to Robot Framework:**

| Severity | Criteria |
|----------|----------|
| 🔴 High | Wrong locator strategy, missing TC-ID, platform mismatch |
| 🟡 Medium | Missing tags, no YAML fixtures, Sleep usage |
| 🟢 Low | Missing docstrings, variable ordering |
