# Quick Automation

Add or modify test scripts without running the full QA workflow.

## When to use
- "เพิ่ม test", "แก้ test script", "patch test"
- Adding test cases to existing spec files
- Fixing test logic without re-architecting

## Decision Tree

### Phase 1 — File State Check
- No implementation MD → offer to run full workflow
- Has MD but no spec file → offer to resume at Phase 3 (codeGenerator)
- Has both → continue to Phase 2

### Phase 2 — Scope Check (read actual code first)

| Check | Signal | Decision |
|---|---|---|
| Need new Service/Page/Keyword? | Multiple files affected | Escalate to Phase 2 |
| Need new Service/Page/Keyword? | Single file, pattern clear | Phase 3 |
| Need new DB helper method? | Multiple tables / complex seed | Escalate to Phase 2 |
| Need new DB helper method? | Single method, pattern clear | Phase 3 |
| Locator broken? | nth/index style, affects multiple files | Escalate to Phase 2 |
| Locator broken? | getByRole/TestId style OR single file | Phase 3 |
| New page/screen? | Existing Page Object reusable | 🟢 Quick |
| New page/screen? | Not reusable, needs new Page Object | Escalate to Phase 2 |
| Mobile: new Keyword? | Exists in both platforms, name matches | 🟢 Quick |
| Mobile: new Keyword? | Missing in one platform or name mismatch | Escalate to Phase 2 |
| Input data / assertion only | Any | 🟢 Quick |

### Full workflow triggers
- workflow_type changes (api → webui, android → ios)
- Feature scope changes entirely
- Existing architecture violates rules
- DB schema changed → affects entire DbService
- New platform from scratch

## Process (Quick Mode)
1. Read existing spec file and understand current structure
2. Read coding rules (`rules/playwright/`)
3. Adversarial review before proposing changes:
   - Does the change break existing tests?
   - Does it follow naming conventions?
   - Does it comply with AAA pattern, mandatory tags, locator priority?
   - Is test data in fixtures (not hardcoded)?
4. Propose changes to user → wait for approval
5. Implement changes
6. Run tests → verify PASS
7. If tests fail → heal (1 attempt only, no retry loop — still failing → switch to root-cause debugging, see `references/workflow.md`)

## Escalation Message
```
⚠️ Scope is too large for Quick Automation
Reason: {reason}
Recommendation: run the full workflow starting from {phase name}
```

## Platform Compliance

| Platform | Check |
|----------|-------|
| Playwright API | Schema validation (AJV), auth via globalSetup, fixtures in .ts |
| Playwright Web | Page Object Model, locator priority, storageState auth |
