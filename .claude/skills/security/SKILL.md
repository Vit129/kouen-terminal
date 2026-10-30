---
name: security
description: >
  Thai triggers: "เช็คความปลอดภัย", "ช่องโหว่", "ทำ auth ให้ปลอดภัย", "สแกน secret".
  Unified security rules for Dev + QA — all platforms (API, Web UI, Mobile).
  Dev: secure coding (OWASP prevention, input validation, auth patterns).
  QA: security test scenario design + automation patterns (Playwright, RF).
  Triggers: "security", "OWASP", "auth test", "permission matrix", "injection",
  "secure coding", "security hardening", "security scenarios", security concern flagged during architecture/QA-design,
  "scan Docker image", "Trivy", "CodeQL", "secret detection", "Gitleaks", "SAST", "SCA", "security gate in pipeline", "shift-left security".
version: 2.2.1
---

# Security

> One source of truth — how to BUILD secure + how to TEST it's secure. `references/rules.md` covers both halves (Dev + QA) together.

## Load

| Task | Load |
|------|------|
| Secure coding, security test design, or both | `references/rules.md` |
| CI/CD pipeline scanning (Trivy, CodeQL, Gitleaks, Semgrep, Docker/IaC scans) | `references/pipeline-scanning.md` |

## Required Context

| Dependency | Purpose |
|---|---|
| `rules/coding.md` | Zero secrets in code, input validation at every boundary |
| `rules/aodd.md` | Verification gates — no secure-coding claim without a passing test |

## Related Skills

- **Dev implementation:** `backend-dev` — RBAC, token management, validation-layer code the Dev half of this skill governs.
- **QA automation:** `playwright-testing` / `robotframework-testing` — automate the auth/permission-matrix scenarios the QA half designs.
- **Pre-merge audit:** a code review of the diff — run alongside this skill's own checklist for injection/auth/PII vectors.

## When to Load This Skill

| Signal | Who | Stage |
|--------|-----|-------|
| Security concern flagged during Architect / QA-Design | QA | QA-Design + automation |
| Feature has login/auth/token | Both | Architect, QA-Design, Dev |
| Feature has role-based access | Both | Architect, QA-Design, Dev |
| Feature has user input → backend | Both | Any |
| Feature handles sensitive data (PII, financial) | Both | Any |
| "secure coding", "security hardening" | Dev | Dev Implementation |

## Secret handling in an agent session (verified)

- Never `cat`/`sed`/`head` a secret-bearing file to look at it or "redact" it — a pattern like `s/KEY=.*//` misses `export X_API_KEY="..."` and prints the key. Read only the variable you need in-process, or check presence with `grep -c` / `test -f`.
- To see a config's shape, print keys only (`jq 'paths'`, `python -c 'print(list(json.load(f)))'`), never values. Gitignored does not mean safe to print.
- If a secret was printed into a session, say so at once and tell the user which key to rotate.

## Self-Update (after every use)

This skill is its own memory. When using it brought a correction, a gotcha,
or a wrong/missing step, and the fix was verified, patch this file in place: a missed vulnerability class, a scanner false-positive pattern, a new OWASP/CI-scanning fact (`references/rules.md`, `references/pipeline-scanning.md`).
Then bump `version` (patch) and `last_improved`. Procedure: `docs/skill-learning.md`.
