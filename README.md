# Cicada — Security Audit & Fix Skill

[![LLM Compatible](https://img.shields.io/badge/LLM-CODEX%20%7C%20CLAUDE%20%7C%20OPENCODE-blue)](#)
[![Skill](https://img.shields.io/badge/type-security--audit-success)](#)
[![Domains](https://img.shields.io/badge/domains-16-green)](#)


<img width="1774" height="887" alt="cicada" src="https://github.com/user-attachments/assets/a6509abf-6b07-4394-a988-9e92649d55d7" />

A comprehensive security audit skill for LLM coding agents. Runs `/cicada` to scan your backend, mobile, cloud, and infra code for vulnerabilities — then optionally fixes them.

**Covers:** Node.js, Python, Go, Ruby, PHP, Java, .NET + Express, Next.js, NestJS, Django, Flask, FastAPI, Gin, Rails, Laravel, Spring Boot + Flutter, React Native + Docker, K8s, AWS, GCP.

---

## One-Line Install

Paste this in your terminal:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Synthrun/Cicada/main/install.sh)
```

Or if the repo is local, copy the `install.sh` to your project and run:

```bash
bash path/to/cicada/install.sh
```

**The LLM can also auto-install** — just say "install cicada" and it will run `install.sh` for you.

After install, just type in your LLM chat:
```
/cicada
```

| Agent | What the LLM runs |
|-------|-------------------|
| **OPENCODE** | `bash <(curl -fsSL <url>/install.sh)` then `/cicada` |
| **CLAUDE** | Reads `install.sh` from context, writes files, runs `/cicada` |
| **CODEX** | Reads `install.sh`, executes it, then `/cicada` |
| **Cursor / Windsurf** | Reads skills from `.cicada/` automatically after install |

---

## Features

- **16 security domains** — auth, password reset, connectors, API/input, secrets, dependencies, web frameworks (10), mobile (2), cloud/infra, GraphQL, WebSocket, file upload, data privacy, crypto, CI/CD supply chain, logging
- **3 operation modes** — report-only, interactive fix, auto-fix all
- **Framework auto-detection** — reads config files, runs only relevant checks
- **Fix snippets** — every check includes a copy-paste fix in the correct language
- **Timing attack detection** — login timing, random keystroke delays, constant-time comparisons
- **Mobile security** — Flutter + React Native: deep links, SSL pinning, secure storage, obfuscation
- **Read-only by default** — never modifies code unless you explicitly ask

---

## Quick Start

```bash
# One line — installs SKILL.md + configs into .cicada/
bash <(curl -fsSL https://raw.githubusercontent.com/Synthrun/Cicada/main/install.sh)

# Then in your LLM chat:
#   /cicada
```

The skill will ask:

```
Choose mode:
  1 — Report only (no code changes)
  2 — Interactive fix (ask per finding)
  3 — Auto-fix all (fix everything, confirm once)
```

Select a mode and the audit proceeds across all 16 domains.

---

## Repository Structure

```
cicada/
├── SKILL.md               ← Main skill — the security audit engine (2132 lines, 16 domains)
├── AGENTS.md              ← Agent config for CLAUDE / OPENCODE (/cicada)
├── opencode.json          ← OPENCODE agent registration (/cicada)
├── README.md              ← This file
├── report.md              ← Generated audit report
├── .gitignore             ← Standard ignores
├── .env.example           ← Secure env template
├── .cicada                ← Config marker for LLM tool discovery
└── templates/
    └── report-template.md ← Report output template
```

---

## Audit Domains

| # | Domain | What's Checked |
|---|--------|----------------|
| 1 | **Auth & Session** | Login, JWT, OAuth, magic links, timing attacks, MFA |
| 2 | **Password Reset** | Token generation, storage, expiry, enumeration protection |
| 3 | **Connectors** | API keys, webhooks, DB connections, third-party SDKs |
| 4 | **API & Input** | SQL injection, command injection, CORS, rate limiting, headers |
| 5 | **Secrets & Config** | .env exposure, hardcoded keys, credential logging |
| 6 | **Dependencies** | Outdated packages, HTTPS enforcement, error handling |
| 7 | **Web Frameworks** | Express, Next.js, NestJS, Django, Flask, FastAPI, Gin, Rails, Laravel, Spring Boot |
| 8 | **Mobile** | Flutter + React Native — deep links, storage, SSL pinning, obfuscation |
| 9 | **Cloud & Infra** | Docker, K8s, S3 buckets, IAM, CloudTrail, security groups |
| 10 | **GraphQL** | Introspection, query depth, cost analysis, per-resolver auth, batching |
| 11 | **WebSocket** | Origin validation, WS auth, rate limiting, replay, idle timeout |
| 12 | **File Upload** | Magic bytes, size limits, virus scan, path traversal, zip bombs, EXIF |
| 13 | **Data Privacy** | PII classification, GDPR/CCPA, data export/delete, retention, consent |
| 14 | **Cryptography** | Weak hashes, ECB mode, static IVs, key rotation, JWK confusion |
| 15 | **CI/CD Supply Chain** | Pipeline secrets, lockfiles, dependency confusion, typosquatting, SBOM |
| 16 | **Logging & Monitoring** | Log injection, PII in logs, audit trail, alerting, health check leaks |

---

## Operation Modes

### 1 — Report Only (Read-Only)

Best for CI or when you want a document without changes.

```
1. LLM reads every source file
2. Runs all checks from all 16 domains
3. Generates report.md with every finding + severity + file:line
4. Zero files touched
```

### 2 — Interactive Fix

Best when you want to review each fix before applying.

```
1. Full audit runs
2. For each finding, LLM asks: "Fix this? (y/n/skip-all)"
3. Fixes applied immediately on "y"
4. Final report documents what was fixed and skipped
```

### 3 — Auto-Fix All

Best when you trust the skill's fixes and want speed.

```
1. Full audit runs
2. Summary shown: "3 Critical, 5 High — fix all? (y/n)"
3. Optionally preview diffs
4. All fixes applied
5. Final report documents every change
```

---

## CI Integration

```yaml
# .github/workflows/security-audit.yml
name: Security Audit
on: [pull_request]
jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Hardcoded secrets
        run: |
          if grep -rE "['\"][A-Za-z0-9_\-]{32,}['\"]" \
            --include="*.{js,ts,py,go}" \
            --exclude-dir=node_modules --exclude-dir=.git; then
            echo "Potential hardcoded secrets found!"; exit 1
          fi
      - name: Command injection
        run: |
          if grep -rn "exec(\`" --include="*.{js,ts}" --exclude-dir=node_modules; then
            echo "Potential command injection found!"; exit 1
          fi
      - name: Weak RNG for tokens
        run: |
          if grep -rn "Math\.random\|Date\.now" --include="*.{js,ts}" \
            --exclude-dir=node_modules | grep -i "token\|secret\|reset\|magic"; then
            echo "Weak RNG used for tokens!"; exit 1
          fi
      - name: Dep audit
        run: |
          if [ -f package.json ]; then npm audit --audit-level=high; fi
```

---

## Requirements

- An LLM coding agent (CODEX, CLAUDE, OPENCODE, Cursor, Windsurf, etc.)
- A project with source code to audit

---

## License

MIT — use freely, modify, contribute.
