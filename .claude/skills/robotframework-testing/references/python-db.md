# Python Database Writer

Generate Python database config and service classes for Robot Framework mobile tests.

## When to use
- Mobile tests need database connection for seed/verify/cleanup
- Need to generate Python DbConfig and DbService files for Hybrid Testing strategy

## Steps
1. Read DB Strategy from implementation plan (Phase 1 + Phase 2)
2. Generate `[system_feature_snake]_db_config.py` — uses `os.getenv` or `python-dotenv`
3. Generate `[system_feature_snake]_db_service.py` with methods:
   - `__init__()` — load config
   - `connect()` — open connection
   - `seed_[feature](**kwargs)` — parameterized INSERT with test_id
   - `verify_[feature](**kwargs)` — parameterized SELECT
   - `cleanup_[feature](**kwargs)` — DELETE by test_id
   - `seed_all(params, test_id)` — if FK dependencies, orchestrate in dependency order within single transaction, return dict of generated IDs

## Rules
- PEP8 compliance: snake_case for methods, CamelCase for classes
- All credentials from `.env` (DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME)
- All queries parameterized — no f-strings or manual string formatting
- Context managers or try-except-finally for connection safety
- Atomic business actions (e.g., `seed_active_user`), not generic query wrappers
- Every write method must receive `test_id`
- Use `INSERT IGNORE` / `IF NOT EXISTS` for idempotency
- Explicit transactions for multi-statement operations
- Test data must use prefix (`TEST_`, `AUTO_`)

## Forbidden Patterns
- ❌ Hard-coded credentials
- ❌ Missing error handling (try-except)
- ❌ Missing connection close
- ❌ Non-PEP8 naming
- ❌ Inline SQL string formatting
- ❌ Destructive queries without test_id isolation
- ❌ Missing explicit transactions for multi-statement ops
