# Input Validation Standards — Backend (All Languages)

> **Applies to:** Node.js (Express/Fastify/NestJS), Python (FastAPI/Django)
> **Purpose:** Validate all incoming data at the edge consistently, return structured errors, and never trust client input.

---

## Validation Rules

1. Validate at the **edge** (middleware / controller / route handler) — not deep in services
2. Return **all field errors at once** — not one at a time
3. Use **typed schemas** — not manual if/else checks
4. Error response MUST follow the standard format from `error-handling-standards.md`

---

## Platform Implementation

### Node.js — Zod

```typescript
// schemas/flightSearch.schema.ts
import { z } from 'zod'

export const flightSearchSchema = z.object({
  origin:      z.string().length(3, 'Must be 3-letter IATA code'),
  destination: z.string().length(3, 'Must be 3-letter IATA code'),
  date:        z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Must be YYYY-MM-DD'),
  tripType:    z.enum(['ONE_WAY', 'ROUND_TRIP', 'MULTI_CITY']),
  passengers:  z.number().int().min(1).max(9),
})

export type FlightSearchInput = z.infer<typeof flightSearchSchema>

// middleware/validate.middleware.ts
export function validate(schema: z.ZodSchema) {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body ?? req.query)
    if (!result.success) {
      const details = result.error.errors.map(e => ({
        field: e.path.join('.'),
        message: e.message,
      }))
      throw new ValidationError('Validation failed', details)
    }
    req.validated = result.data
    next()
  }
}

// Usage in route
router.get('/search', validate(flightSearchSchema), flightController.search)
```

---

### Node.js — NestJS (class-validator)

```typescript
// dto/flight-search.dto.ts
import { IsString, Length, IsEnum, IsInt, Min, Max, Matches } from 'class-validator'

export class FlightSearchDto {
  @IsString() @Length(3, 3)
  origin: string

  @IsString() @Length(3, 3)
  destination: string

  @Matches(/^\d{4}-\d{2}-\d{2}$/)
  date: string

  @IsEnum(['ONE_WAY', 'ROUND_TRIP', 'MULTI_CITY'])
  tripType: string

  @IsInt() @Min(1) @Max(9)
  passengers: number
}

// Controller — ValidationPipe handles automatically
@Get('search')
search(@Query() dto: FlightSearchDto) { ... }
```

---

### Python — FastAPI (Pydantic)

```python
# schemas/flight_search.py
from pydantic import BaseModel, field_validator, model_validator
from enum import Enum
import re

class TripType(str, Enum):
    ONE_WAY    = 'ONE_WAY'
    ROUND_TRIP = 'ROUND_TRIP'
    MULTI_CITY = 'MULTI_CITY'

class FlightSearchInput(BaseModel):
    origin:      str
    destination: str
    date:        str
    trip_type:   TripType
    passengers:  int

    @field_validator('origin', 'destination')
    @classmethod
    def must_be_iata(cls, v: str) -> str:
        if len(v) != 3 or not v.isalpha():
            raise ValueError('Must be 3-letter IATA code')
        return v.upper()

    @field_validator('date')
    @classmethod
    def must_be_date(cls, v: str) -> str:
        if not re.match(r'^\d{4}-\d{2}-\d{2}$', v):
            raise ValueError('Must be YYYY-MM-DD')
        return v

    @field_validator('passengers')
    @classmethod
    def valid_passengers(cls, v: int) -> int:
        if not 1 <= v <= 9:
            raise ValueError('Must be between 1 and 9')
        return v

# FastAPI auto-validates and returns 422 with field errors
@router.get('/search')
async def search_flights(params: FlightSearchInput = Depends()):
    ...
```

---

### Python — Django REST Framework

```python
# serializers/flight_search.py
from rest_framework import serializers

class FlightSearchSerializer(serializers.Serializer):
    origin      = serializers.CharField(min_length=3, max_length=3)
    destination = serializers.CharField(min_length=3, max_length=3)
    date        = serializers.DateField()
    trip_type   = serializers.ChoiceField(choices=['ONE_WAY', 'ROUND_TRIP', 'MULTI_CITY'])
    passengers  = serializers.IntegerField(min_value=1, max_value=9)

# Usage in view
def get(self, request):
    serializer = FlightSearchSerializer(data=request.query_params)
    serializer.is_valid(raise_exception=True)  # auto returns 400 with field errors
    data = serializer.validated_data
```

---

## Rules

1. Every endpoint with input (body, query, path params) MUST have a schema
2. Validation MUST happen at the route/controller layer — never in the service layer
3. All field errors MUST be returned at once — not one at a time
4. Schema types MUST be exported and reused — never duplicate inline
5. Enum values MUST be defined as typed enums / Literal types — not plain strings
6. Never trust client input in services — always use `req.validated` / `serializer.validated_data`
