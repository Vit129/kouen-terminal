# Error Handling Standards — Backend (All Languages)

> **Applies to:** Node.js (Express/Fastify/NestJS), Python (FastAPI/Django)
> **Purpose:** Consistent error catching, response format, and logging across all backend services.

---

## Error Response Format (All Services)

Every error response MUST follow this structure:

```json
{
  "error": {
    "code": "FLIGHT_NOT_AVAILABLE",
    "message": "The selected flight is no longer available",
    "details": [
      { "field": "flightId", "message": "Flight FL001 has no available seats" }
    ]
  }
}
```

- `code` — machine-readable constant in SCREAMING_SNAKE_CASE
- `message` — human-readable, safe to show to client
- `details` — optional array for field-level validation errors

---

## Error Code Convention

```
[DOMAIN]_[PROBLEM]

FLIGHT_NOT_AVAILABLE
BOOKING_EXPIRED
BOOKING_LOCK_EXPIRED
PASS_NOT_ACTIVE
SEAT_NOT_AVAILABLE
INVALID_DATE_RANGE
PLAN_OVERLOADED
TICKET_SOLD_OUT
FAST_PASS_ALREADY_USED
FAST_PASS_EXPIRED
```

---

## HTTP Status Code Mapping

| Situation | Status |
|---|---|
| Validation failed (client input) | 400 |
| Unauthenticated | 401 |
| Forbidden (no permission) | 403 |
| Resource not found | 404 |
| Conflict (duplicate, lock expired) | 409 |
| Business rule violation | 422 |
| Resource gone (expired) | 410 |
| Server error | 500 |

---

## Platform Implementation

### Node.js (Express)

```typescript
// errors.ts — typed error classes
export class AppError extends Error {
  constructor(
    public readonly code: string,
    public readonly message: string,
    public readonly status: number,
    public readonly details?: object[]
  ) { super(message) }
}

export class NotFoundError extends AppError {
  constructor(code: string, message: string) { super(code, message, 404) }
}
export class ConflictError extends AppError {
  constructor(code: string, message: string) { super(code, message, 409) }
}
export class GoneError extends AppError {
  constructor(code: string, message: string) { super(code, message, 410) }
}
export class ValidationError extends AppError {
  constructor(message: string, details: object[]) {
    super('VALIDATION_ERROR', message, 400, details)
  }
}

// errorHandler.middleware.ts — centralized handler
export function errorHandler(err: Error, req: Request, res: Response, next: NextFunction) {
  if (err instanceof AppError) {
    logger.warn('Business error', { code: err.code, status: err.status, path: req.path })
    return res.status(err.status).json({
      error: { code: err.code, message: err.message, details: err.details }
    })
  }
  logger.error('Unexpected error', err, { path: req.path })
  res.status(500).json({ error: { code: 'INTERNAL_ERROR', message: 'Something went wrong' } })
}

// Usage in service
if (!flight || flight.availableSeats === 0) {
  throw new NotFoundError('FLIGHT_NOT_AVAILABLE', 'The selected flight is no longer available')
}
```

---

### Node.js (NestJS)

```typescript
// exceptions.ts
export class FlightNotAvailableException extends HttpException {
  constructor() {
    super({ error: { code: 'FLIGHT_NOT_AVAILABLE', message: 'Flight is no longer available' } }, HttpStatus.NOT_FOUND)
  }
}

// global-exception.filter.ts
@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp()
    const res = ctx.getResponse<Response>()
    const req = ctx.getRequest<Request>()

    if (exception instanceof HttpException) {
      return res.status(exception.getStatus()).json(exception.getResponse())
    }
    logger.error('Unexpected error', exception, { path: req.url })
    res.status(500).json({ error: { code: 'INTERNAL_ERROR', message: 'Something went wrong' } })
  }
}
```

---

### Python (FastAPI)

```python
# errors.py — typed exception classes
class AppError(Exception):
    def __init__(self, code: str, message: str, status: int, details: list = None):
        self.code = code
        self.message = message
        self.status = status
        self.details = details or []

class NotFoundError(AppError):
    def __init__(self, code: str, message: str):
        super().__init__(code, message, 404)

class ConflictError(AppError):
    def __init__(self, code: str, message: str):
        super().__init__(code, message, 409)

class GoneError(AppError):
    def __init__(self, code: str, message: str):
        super().__init__(code, message, 410)

# main.py — global exception handler
@app.exception_handler(AppError)
async def app_error_handler(request: Request, exc: AppError):
    logger.warning(f"Business error: {exc.code}", extra={"path": request.url.path})
    return JSONResponse(
        status_code=exc.status,
        content={"error": {"code": exc.code, "message": exc.message, "details": exc.details}}
    )

@app.exception_handler(Exception)
async def unexpected_error_handler(request: Request, exc: Exception):
    logger.error("Unexpected error", exc_info=exc, extra={"path": str(request.url)})
    return JSONResponse(
        status_code=500,
        content={"error": {"code": "INTERNAL_ERROR", "message": "Something went wrong"}}
    )

# Usage in service
if not flight or flight.available_seats == 0:
    raise NotFoundError("FLIGHT_NOT_AVAILABLE", "The selected flight is no longer available")
```

---

### Python (Django REST Framework)

```python
# exceptions.py
from rest_framework.exceptions import APIException
from rest_framework import status

class FlightNotAvailableError(APIException):
    status_code = status.HTTP_404_NOT_FOUND
    default_code = 'FLIGHT_NOT_AVAILABLE'
    default_detail = 'The selected flight is no longer available'

# exception_handler.py — custom DRF handler
def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)
    if response is not None:
        response.data = {
            'error': {
                'code': exc.default_code if hasattr(exc, 'default_code') else 'ERROR',
                'message': str(exc.detail),
            }
        }
    return response
```

---

## Rules

1. Every service MUST have a global/centralized error handler — no unhandled exceptions
2. Error codes MUST be SCREAMING_SNAKE_CASE constants — never free-form strings
3. Error responses MUST follow the standard format — never expose stack traces to clients
4. Sensitive data (tokens, passwords, internal paths) MUST NOT appear in error responses
5. Business errors (4xx) → log as `warn`. Unexpected errors (5xx) → log as `error` with full stack
6. Error code constants MUST be defined in a shared file — not scattered inline
