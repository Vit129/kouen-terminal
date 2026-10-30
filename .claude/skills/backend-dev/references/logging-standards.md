# Logging Standards — Backend (All Languages)

> **Applies to:** Node.js (Express/Fastify/NestJS), Python (FastAPI/Django)
> **Purpose:** Consistent log levels, structured format, and security rules across all backend services.

---

## Log Levels

| Level | When to use |
|---|---|
| `debug` | Detailed flow — dev/sit only, never prod |
| `info` | Key business events (request received, booking created) |
| `warn` | Recoverable issues (retry, fallback, business error 4xx) |
| `error` | Failures needing attention (5xx, unhandled exception) |

---

## Structured Log Format (JSON)

Every log entry MUST be structured JSON in production:

```json
{
  "level": "error",
  "timestamp": "<ISO-8601 UTC timestamp>",
  "service": "flight-service",
  "context": "FlightService.search",
  "message": "Flight search failed",
  "requestId": "req-abc-123",
  "userId": "u-456",
  "error": { "code": "FLIGHT_NOT_AVAILABLE", "stack": "..." }
}
```

---

## Security Rules

**NEVER log:**
- Passwords, tokens, API keys, secrets
- Full credit card numbers, CVV
- Passport numbers, national ID
- OAuth codes or refresh tokens

**Safe to log:**
- User ID (not full profile)
- Request ID, correlation ID
- Endpoint path (not full URL with sensitive query params)
- Error codes and sanitized messages
- Duration, status codes

---

## Platform Implementation

### Node.js — Winston

```typescript
// logger.ts — single access point
import winston from 'winston'

export const logger = winston.createLogger({
  level: process.env.LOG_LEVEL ?? 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  defaultMeta: { service: process.env.SERVICE_NAME ?? 'api' },
  transports: [new winston.transports.Console()],
})

// Request logging middleware
export function requestLogger(req: Request, res: Response, next: NextFunction) {
  const start = Date.now()
  res.on('finish', () => {
    logger.info('Request completed', {
      method: req.method,
      path: req.path,
      status: res.statusCode,
      durationMs: Date.now() - start,
      requestId: req.headers['x-request-id'],
    })
  })
  next()
}

// Usage
logger.info('Booking created', { bookingId, userId, totalAmount })
logger.warn('Flight lock expired', { bookingId, expiredAt })
logger.error('Unexpected error in booking', { error: err.message, stack: err.stack, bookingId })
```

---

### Python — structlog / logging

```python
# logger.py — single access point
import structlog
import logging

structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.add_log_level,
        structlog.processors.JSONRenderer(),
    ],
    wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
)

logger = structlog.get_logger(service=os.getenv("SERVICE_NAME", "api"))

# Request logging middleware (FastAPI)
@app.middleware("http")
async def request_logger(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    logger.info("request_completed",
        method=request.method,
        path=request.url.path,
        status=response.status_code,
        duration_ms=round((time.time() - start) * 1000),
        request_id=request.headers.get("x-request-id"),
    )
    return response

# Usage
logger.info("booking_created", booking_id=booking_id, user_id=user_id)
logger.warning("flight_lock_expired", booking_id=booking_id)
logger.error("unexpected_error", error=str(err), booking_id=booking_id, exc_info=True)
```

---

## Request ID (Mandatory)

Every request MUST carry a `requestId` / `x-request-id` header for traceability across services:

```typescript
// Node.js middleware
app.use((req, res, next) => {
  req.requestId = req.headers['x-request-id'] as string ?? crypto.randomUUID()
  res.setHeader('x-request-id', req.requestId)
  next()
})
```

```python
# FastAPI middleware
@app.middleware("http")
async def request_id_middleware(request: Request, call_next):
    request_id = request.headers.get("x-request-id", str(uuid.uuid4()))
    response = await call_next(request)
    response.headers["x-request-id"] = request_id
    return response
```

---

## Rules

1. Never use `console.log()` or `print()` directly — always use the project logger
2. All logs in production MUST be structured JSON
3. `debug` logs MUST be disabled in production (`LOG_LEVEL=info` in prod)
4. Every `error` log MUST include the original exception and stack trace
5. Every request MUST be logged with method, path, status, duration, and requestId
6. Sensitive data MUST never appear in any log level
7. Service name MUST be included in every log entry via `defaultMeta` / `bind`
