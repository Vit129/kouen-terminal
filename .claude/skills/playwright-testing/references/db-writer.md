# Playwright Database Writer

Generate database config and service classes for Playwright test data management.

## When to use
- Tests need database connection for seed/verify/cleanup
- Need to generate DbConfig and DbService files

## Steps
1. Read DB Strategy from implementation plan (Phase 1 + Phase 2)
2. Generate `[Feature]DbConfig.ts` — reads from `.env` (DB_HOST, DB_PORT, etc.)
3. Generate `[Feature]DbService.ts` with methods:
   - `connect()` — initialize connection
   - `checkConnection()` — health check for fallback logic
   - `seed[Feature](params, testId)` — insert test data tagged with testId
   - `verify[Feature](params)` — select and verify data state
   - `cleanup(testId)` — delete by testId (safety net)
   - `seedAll(params, testId)` — if FK dependencies exist, orchestrate in order within single transaction, return typed result object (e.g., `{ roleId, userId, orderId }`)
   - `disconnect()` — close connection

## Rules
- All credentials from `.env` — never hardcode
- All queries parameterized — no string formatting
- Dynamic import for `pg`: `await import('pg')` — never static import (Windows CI breaks)
- Every write method must receive `testId`
- Add `db-scripts/` to `tsconfig.json` exclude
- Test data must use prefix (`TEST_`, `AUTO_`)
- Never `TRUNCATE` shared tables — only `DELETE WHERE test_id = $1`
- Use `INSERT IGNORE` / `WHERE NOT EXISTS` for idempotency
- Explicit transactions (`BEGIN`/`COMMIT`) for multi-statement operations
- Never log sensitive data (passwords, full connection strings)

## Forbidden Patterns
- ❌ Hard-coded credentials
- ❌ Missing error handling for DB connection
- ❌ Missing connection close/cleanup
- ❌ Inline SQL string formatting
- ❌ Destructive queries without `testId` isolation
- ❌ Static import from `pg`
- ❌ Missing `testId` parameter in write methods
- ❌ Logging sensitive data

## Brownfield DB Strategy

When the project already has a DB that holds production data:

### Problems
- New seed data may conflict with existing records (duplicate key, FK violation)
- A faulty cleanup may delete production data

### Brownfield rules

1. **Prefix every test record** with `TEST_` or `AUTO_` in its identifier
   ```sql
   INSERT INTO users (email) VALUES ('TEST_john@example.com')
   ```

2. **Cleanup by testId only** — never cleanup by feature name or date
   ```sql
   DELETE FROM users WHERE test_id = $1  -- ✅
   DELETE FROM users WHERE created_at > $1  -- ❌ dangerous
   ```

3. **Check before insert** — use `WHERE NOT EXISTS` to prevent duplicates
   ```sql
   INSERT INTO users (email, test_id)
   SELECT $1, $2
   WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = $1)
   ```

4. **Seed inside a transaction** — roll everything back if seeding fails
   ```typescript
   await db.transaction(async (trx) => {
     await trx('users').insert({ email: 'TEST_user@test.com', test_id: testId })
     await trx('profiles').insert({ user_id: userId, test_id: testId })
   })
   ```

5. **Verify before cleanup** — check the record has a test_id before deleting
   ```typescript
   const record = await db('users').where({ id, test_id: testId }).first()
   if (!record) throw new Error(`Record ${id} not owned by test ${testId}`)
   await db('users').where({ id, test_id: testId }).delete()
   ```
