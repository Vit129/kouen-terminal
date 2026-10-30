# Test Data Generation

Smart test data collection and generation with hierarchical reading.

## When to use
- Test data strategy needed after scenario design
- Smart data collection required
- Boundary value analysis needed

## Process

### Step 1: Analyze & Collect Data
- Extract fields needed, validation rules, and domain patterns from requirements / feature specifications
- Scan existing test scenario files in `agent-memory/plans/` or `tests/test-scenario/` for existing patterns:
  - Exact match: same system/feature folder
  - Fuzzy match: similar features (>50% keyword overlap)
  - Domain fallback: use domain patterns if no match
- Read UI Context from Figma/Image section if available

### Step 1.5: Dependency Analysis
- Analyze business rules (BL_XXX) for entity relationships
- Build dependency chain:
  - Level 1 (no deps): Role, Permission, Category
  - Level 2 (depends on L1): User (needs Role)
  - Level 3 (depends on L2): Order (needs User)
- Data sets MUST be generated in dependency order
- If circular dependency detected → flag to user

### Step 2: Generate ALL Test Data (single batch)
- Follow dependency chain order
- Synthesis: ~70% reuse existing patterns, ~30% generate new
- Coverage Strategy:
  - **Valid/Standard:** standard patterns, reused data
  - **Boundary/BVA:** Min/Max/Just Above/Just Below for numeric/date/length
  - **Edge:** Null, empty, special chars, invalid formats
  - **Pairwise Interactions:** identify logically interacting fields (Role+Permission, StartDate+EndDate), generate combinatorial test sets

## Validation Requirements
- MUST generate at least 3 basic sets (Valid, Boundary, Edge)
- MUST generate pairwise sets if interacting fields detected
- MUST include all fields from test scenarios
- MUST validate against business rules (BL_XXX)
- MUST use proper data types (string, number, boolean, date)
- MUST include realistic values (not placeholder text)

## Output Format
```markdown
## 📊 Test Data

### TD_001: Valid User Data
| Field | Value | Rule |
|-------|-------|------|
| username | user001 | BL_USERNAME_FORMAT |
| email | user@test.com | BL_EMAIL_VALIDATION |

### TD_002: Boundary - Minimum Age
| Field | Value | Rule |
|-------|-------|------|
| age | 18 | BL_AGE_MIN_18 (boundary) |
```

## Rules
- AI MUST NOT approve by itself — always wait for user
- Write all data to file before showing summary
- Show abbreviated summary (TD-ID + Description only)
