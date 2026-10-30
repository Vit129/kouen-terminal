# Authentication & Authorization

Guidelines for securing APIs and managing user access.

## Authentication Methods

**JWT (JSON Web Tokens)**
- Stateless — no server-side session storage
- Access token (short-lived: 15-60 min) + Refresh token (long-lived: 7-30 days)
- Store access token in memory, refresh token in httpOnly cookie
- Never store JWT in localStorage (XSS vulnerable)

**OAuth2**
- Use for third-party login (Google, GitHub, Microsoft)
- Authorization Code flow for web apps (with PKCE for SPAs)
- Client Credentials flow for service-to-service
- Never use Implicit flow (deprecated)

**Session-based**
- Server stores session data, client gets session ID cookie
- Good for traditional server-rendered apps
- Use Redis for session storage in distributed systems

## Authorization Patterns

**RBAC (Role-Based Access Control)**
- Assign roles to users: admin, editor, viewer
- Check role before action: `if (user.role === 'admin')`
- Simple, works for most applications

**ABAC (Attribute-Based Access Control)**
- Policy-based: check user attributes, resource attributes, context
- More flexible than RBAC for complex rules
- Example: "user can edit document if user.department === document.department"

## Security Checklist
- Hash passwords with bcrypt (cost factor 12+) or Argon2
- Rate limit login attempts (5 per minute per IP)
- HTTPS everywhere — no exceptions
- CORS: whitelist specific origins, never `*` in production
- CSRF protection for cookie-based auth
- Validate and sanitize all input
- Log authentication events (login, logout, failed attempts)

## Token Refresh Flow
```
1. Client sends request with expired access token
2. Server returns 401
3. Client sends refresh token to /auth/refresh
4. Server validates refresh token → issues new access + refresh tokens
5. Client retries original request with new access token
```

## Tips
- Never log tokens or passwords
- Rotate refresh tokens on every use (one-time use)
- Implement account lockout after N failed attempts
- Use environment variables for secrets — never hardcode
