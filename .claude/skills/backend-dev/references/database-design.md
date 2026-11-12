# Database Design

Guidelines for designing schemas, queries, and migrations.

## Schema Design
- Normalize to 3NF by default — denormalize only for proven performance needs
- Every table needs a primary key (prefer UUID or auto-increment bigint)
- Include `created_at`, `updated_at` timestamps on all tables
- Use soft delete (`deleted_at`) for data that might need recovery
- Foreign keys with appropriate ON DELETE behavior (CASCADE, SET NULL, RESTRICT)

## Naming
- Tables: plural snake_case (`users`, `order_items`)
- Columns: singular snake_case (`first_name`, `created_at`)
- Indexes: `idx_{table}_{columns}` (`idx_users_email`)
- Foreign keys: `fk_{table}_{ref_table}` (`fk_orders_user_id`)

## Indexing
- Index columns used in WHERE, JOIN, ORDER BY
- Composite indexes: most selective column first
- Don't over-index — each index slows writes
- Use EXPLAIN to verify query plans

## Migrations
- One migration per change — never modify existing migrations
- Always include both UP and DOWN
- Test migrations on a copy of production data before deploying
- Use migration tools: Prisma Migrate, Knex, Alembic, Flyway

## Query Patterns
- Use parameterized queries — never string concatenation (SQL injection)
- Pagination: `LIMIT` + `OFFSET` for simple, cursor-based for large datasets
- Avoid `SELECT *` — specify columns explicitly
- Use transactions for multi-table operations

## Database Types
- **PostgreSQL** — default choice for most applications (JSON support, full-text search, extensions)
- **MySQL** — widely supported, good for read-heavy workloads
- **MongoDB** — document store for flexible schemas, rapid prototyping
- **Redis** — in-memory cache, sessions, rate limiting, queues
- **SQLite** — embedded, great for local dev and mobile apps

## Tips
- Design for the queries you'll run, not just the data you'll store
- Add constraints at the DB level (NOT NULL, UNIQUE, CHECK) — don't rely on app code alone
- Use connection pooling in production
- Regular backups with tested restore procedures
