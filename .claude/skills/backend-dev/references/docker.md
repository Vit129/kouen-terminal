# Docker

Guidelines for containerizing backend applications.

## Dockerfile Best Practices

**Multi-stage build (Node.js):**
```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

**Multi-stage build (Python):**
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Docker Compose
```yaml
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: mydb
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  pgdata:
```

## Rules
- Use specific image tags — never `latest` in production
- Alpine images for smaller size (`node:20-alpine`, `python:3.12-slim`)
- `.dockerignore`: exclude `node_modules`, `.git`, `.env`, `dist`
- One process per container
- Non-root user: `USER node` or `USER appuser`
- Health checks for all services

## Environment Variables
- Use `environment` in docker-compose for dev
- Use secrets management (Docker Secrets, Vault, AWS SSM) for production
- Never bake secrets into images

## Tips
- `docker compose up -d` for background, `docker compose logs -f` for logs
- Use `volumes` for persistent data (DB) and hot-reload in dev
- Layer caching: copy `package.json` before source code to cache `npm install`
- Use `depends_on` with `condition: service_healthy` — not just `depends_on`
