# Test Scenario Maintenance

Two modes for working with *existing* scenario files (as opposed to `ts-design.md`, which is for designing new ones): **Edit Mode** (add/modify/delete a scenario) and **Read Mode** (parse existing scenarios into a list an automation architect can consume).

## Edit Mode

Quickly add, modify, or delete test scenarios in an existing Markdown file and synchronize the CSV.

### When to use
- "เพิ่มเคส", "ลบเคส TS-002", "แก้ไขเคส"
- Adding or modifying scenarios without the full design workflow

### Mode Detection (Step 0)
- 🟢 **Quick** — change does NOT affect existing scenarios (add/remove/edit while others remain valid)
- 🔴 **Escalate to full workflow** — change causes existing scenarios to require redesign (single→multi-select, major flow change, business rule change, new feature with no existing file)

### Process
1. **Context Gathering** — identify feature context, load existing MD file, extract last TS-ID
2. **Formulate Edits** — generate new/modified scenarios following `references/ts-design.md`'s Part A guidelines and §14 output format
3. **Adversarial Review:**
   - Title: must be `[TestType][Prefix] + Thai verb + Object + Context`
   - TS-ID: must not duplicate existing IDs
   - Section: Success → Success, Alternative/Edge → Alternative
4. **Show proposed changes** → wait for user approval
5. **Apply changes to Markdown**
6. **Test Data Review** — check if existing test data is still valid, offer to add if needed
7. **Self-Check** — no duplicate IDs, sequential within sections, all 9 fields present
8. **Update CSV** — directly update or add the matching row in the `.csv` file per `references/ts-design.md` §15

### Rules
- Never rewrite entire file unless necessary — surgical edits only
- If deleting → re-sequence within same section only (not across sections)
- Always ask approval before writing
- Directly sync changes to CSV alongside Markdown edits

---

## Read Mode

Parse test scenario files (CSV or Markdown) and extract automatable test cases for automation architecture (feeds `rules/ai-sdlc-workflow.md` Phase 3 QA-Design).

### When to use
- Have existing test scenarios in CSV or Markdown format
- Need to filter for automatable cases only
- Need to extract test metadata (feature, business rules, parameters) for QA-Design automation

### How it works
1. **Read CSV file** — locate `testScenario-{feature}.csv` or `testScenario-{feature}-{platform}.csv` in the test-scenario directory
2. **Filter automatable** — keep only rows where `Automation Status` = "Automatable" (col 9)
3. **Filter by type and priority** — there is no separate `Test_type` column; parse the `[TestType]` bracket from `Title` (col 2), e.g. `[UI][Success] ...` → `UI`. Match against the caller's `workflow_type` if one was passed:
   - `[API]` / `workflow_type = api_automation` → include all priorities (Critical, High, Medium, Low)
   - `[UI]` / `workflow_type = webui_automation` → include Critical and High only
   - `[Mobile]` (Android) / `workflow_type = android_automation` → include Critical and High only
   - `[Mobile]` (iOS) / `workflow_type = ios_automation` → include Critical and High only
4. **Extract metadata from MD file** — system name, feature name, business rules, invariants
5. **Output as simple list** — write to implementation plan in this format, not a complex table

### Derive Mode
When test scenarios exist for one platform but not another:
1. Read existing scenarios
2. Derive equivalent:
   - UI "fill form and submit" → API "POST with same data"
   - UI "verify display" → API "GET and verify response"
3. Tag derived scenarios with `[DERIVED-FROM-UI]` or `[DERIVED-FROM-API]`
4. Show derived scenarios to user for approval before adding

### Output per test case
```
TS-001: [Title]
- Priority: [Critical/High/Medium/Low]
- Pre-conditions: [conditions]
- Test Steps: [numbered list]
- Expected Results: [list]
```

### Rules
- If no matching test type found, offer to derive cases from available types (or warn user if 0 rows remain)
- Verify CSV and/or MD files exist before starting
