# Environment Config Standards — Backend (All Languages)

> **Applies to:** Node.js, Python
> **Purpose:** Manage environment-specific configuration securely and consistently, with validation at startup.

---

## Environments

| Env | Purpose |
|---|---|
| `local` | Developer's local machine |
| `sit` | System Integration Testing (default for QA) |
| `uat` | User Acceptance Testing |
| `prod` | Production |

---

## What Goes Where

| Type | Location | Examples |
|---|---|---|
| Sensitive | CI/CD secrets only — never in repo | DB passwords, JWT secrets, API keys |
| Non-sensitive config | `.env` file per environment | BASE_URL, PORT, LOG_LEVEL, TIMEOUT |
| Business test data | Fixture / seed files | companyCode, test user roles |

---

## Key Naming Convention

`SCREAMING_SNAKE_CASE` always:

```bash
PORT=3001
SERVICE_NAME=flight-service
DATABASE_URL=postgresql://user:pass@localhost:5432/flightdb
JWT_SECRET=...
LOG_LEVEL=info
API_TIMEOUT_MS=10000
```

---

## Platform Implementation

### Node.js

```bash
# .env.sit
PORT=3001
SERVICE_NAME=flight-service
DATABASE_URL=postgresql://user:pass@localhost:5432/flightdb_sit
JWT_SECRET=sit-secret-change-in-prod
LOG_LEVEL=debug
API_TIMEOUT_MS=10000

# .env.prod (secrets injected by CI/CD — never committed)
PORT=3001
SERVICE_NAME=flight-service
DATABASE_URL=${DATABASE_URL}
JWT_SECRET=${JWT_SECRET}
LOG_LEVEL=info
```

```typescript
// config.ts — validate at startup with Zod
import { z } from 'zod'
import dotenv from 'dotenv'

dotenv.config({ path: `.env.${process.env.NODE_ENV ?? 'sit'}` })

const schema = z.object({
  PORT:           z.coerce.number().default(3001),
  SERVICE_NAME:   z.string(),
  DATABASE_URL:   z.string().url(),
  JWT_SECRET:     z.string().min(16),
  LOG_LEVEL:      z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  API_TIMEOUT_MS: z.coerce.number().default(10000),
})

export const config = schema.parse(process.env)
// ⚠️ If validation fails, app crashes at startup — intentional
```

---

### Python (FastAPI — pydantic-settings)

```bash
# .env.sit
PORT=3003
SERVICE_NAME=ai-planner-service
DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/plannerdb_sit
JWT_SECRET=sit-secret-change-in-prod
LOG_LEVEL=debug
API_TIMEOUT_MS=10000
```

```python
# config.py — validate at startup with pydantic-settings
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import AnyUrl

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=f".env.{os.getenv('APP_ENV', 'sit')}",
        env_file_encoding='utf-8'
    )

    PORT: int = 3003
    SERVICE_NAME: str
    DATABASE_URL: AnyUrl
    JWT_SECRET: str
    LOG_LEVEL: str = 'info'
    API_TIMEOUT_MS: int = 10000

config = Settings()
# ⚠️ If validation fails, app crashes at startup — intentional
```

---

## Rules

1. Every service MUST have a `config.ts` / `config.py` as the single access point — never read `process.env` / `os.getenv` directly in business logic
2. Config MUST be validated at startup — app must fail fast if required values are missing
3. Sensitive values MUST use CI/CD secret injection — never committed to repo
4. All keys MUST use `SCREAMING_SNAKE_CASE`
5. Default values MUST point to `local` or `sit` — never `prod`
6. `.env.local` and files containing real secrets MUST be in `.gitignore`
7. `.env.sit` and `.env.uat` (without secrets) SHOULD be committed as templates
