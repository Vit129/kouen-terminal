# Security Scanning in CI/CD

Shift-left security — scan early in the pipeline, not just before release.
Used by both **dev** (Dockerfile, dependencies) and **qa** (test images, API security).
Written for GitHub Actions; Azure DevOps/GitLab CI use the same tools, adapt YAML syntax.

## Scanning Types

| Type | Tool | What it catches |
|------|------|-----------------|
| SCA (dependency) | Trivy, Snyk | Known CVEs in npm/pip/go packages |
| Container image | Trivy | OS packages, misconfigs in Docker image |
| SAST (static code) | CodeQL, Semgrep | Code vulnerabilities, injection patterns |
| Secret detection | Gitleaks, TruffleHog | Hardcoded tokens, API keys in code |
| IaC scanning | Trivy, Checkov | Misconfigs in Dockerfile, k8s YAML |

---

## Trivy — Container + Dependency Scanning

```yaml
# GitHub Actions — scan Docker image
- name: Scan Docker image with Trivy
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: myapp:${{ github.sha }}
    format: sarif
    output: trivy-results.sarif
    severity: CRITICAL,HIGH
    exit-code: '1'          # fail pipeline on CRITICAL/HIGH

- name: Upload Trivy results to GitHub Security
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: trivy-results.sarif
```

```yaml
# Scan filesystem (dependencies) — no Docker needed
- name: Scan dependencies with Trivy
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: fs
    scan-ref: .
    format: table
    severity: CRITICAL,HIGH
```

```bash
# Local usage
trivy image myapp:latest
trivy fs .
trivy config ./k8s/          # scan IaC configs
```

---

## CodeQL — Static Analysis (SAST)

```yaml
# .github/workflows/codeql.yml
name: CodeQL

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * 1'     # weekly Monday 2am

jobs:
  analyze:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      contents: read

    strategy:
      matrix:
        language: [javascript-typescript, python]

    steps:
      - uses: actions/checkout@v4

      - name: Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: ${{ matrix.language }}
          queries: security-extended    # broader than default

      - name: Autobuild
        uses: github/codeql-action/autobuild@v3

      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3
        with:
          category: /language:${{ matrix.language }}
```

---

## Gitleaks — Secret Detection

```yaml
# Scan for hardcoded secrets on every PR
- name: Detect secrets with Gitleaks
  uses: gitleaks/gitleaks-action@v2
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

```bash
# Local pre-commit check
brew install gitleaks
gitleaks detect --source . --verbose
```

---

## Semgrep — Fast SAST (no build needed)

```yaml
- name: Semgrep SAST scan
  uses: semgrep/semgrep-action@v1
  with:
    config: >-
      p/owasp-top-ten
      p/javascript
      p/python
  env:
    SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}
```

---

## Full DevSecOps Pipeline Pattern

```yaml
# Recommended order in CI pipeline
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # 1. Secret detection (fastest — fail early)
      - name: Secret scan
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      # 2. Dependency scan
      - name: Dependency scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: fs
          severity: CRITICAL,HIGH
          exit-code: '1'

  build:
    needs: security
    runs-on: ubuntu-latest
    steps:
      - name: Build Docker image
        run: docker build -t myapp:${{ github.sha }} .

      # 3. Image scan after build
      - name: Image scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: myapp:${{ github.sha }}
          severity: CRITICAL,HIGH
          exit-code: '1'

  sast:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
    steps:
      # 4. SAST — runs in parallel with build
      - uses: github/codeql-action/init@v3
        with:
          languages: javascript-typescript
      - uses: github/codeql-action/autobuild@v3
      - uses: github/codeql-action/analyze@v3
```

---

## Severity Policy

| Severity | Policy |
|----------|--------|
| CRITICAL | Block pipeline — must fix before merge |
| HIGH | Block pipeline — must fix before merge |
| MEDIUM | Warn only — create ticket, don't block |
| LOW | Ignore in CI — review quarterly |

## .trivyignore — Suppress False Positives

```
# .trivyignore
CVE-2023-XXXXX    # false positive — not exploitable in our context (expires: <date>)
CVE-2024-YYYYY    # upstream fix pending — tracked in JIRA-1234
```

## Rules
- Secret scan MUST run before any other step — fail fast
- CRITICAL/HIGH vulnerabilities MUST block merge to main
- Scan results MUST be uploaded to GitHub Security tab (SARIF format)
- `.trivyignore` suppressions MUST include expiry date and justification
- Never suppress CRITICAL without security team approval
