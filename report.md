# 🔐 Security Audit Report — Cicada

<div align="center">

**Audit date:** 2026-06-29  
**Mode:** Report only (no code changes)  
**Scope:** Full backend — auth, connectors, API, config, dependencies  
**Method:** Static code analysis — no runtime testing  
**Project state:** Skeleton — no code to audit

</div>

---

## 📋 Executive Summary

| Severity | Count | Fixed | Description |
|----------|-------|-------|-------------|
| 🔴 **Critical** | 0 | 0 | Directly exploitable — RCE, SQLi, account takeover |
| 🟠 **High** | 0 | 0 | Exploitable under realistic conditions |
| 🟡 **Medium** | 0 | 0 | Weakens security posture |
| 🔵 **Low** | 0 | 0 | Best-practice deviations |
| ⚪ **Info** | 1 | — | Project is empty — this is a greenfield blueprint |

**Overall verdict:** The project directory is empty (no source files, no configuration, no dependencies). Zero vulnerabilities in the current state. This report serves as a **preventive security specification** for future code.

---

## 📂 Project Structure

```
cicada/
├── README.md               ← Repository documentation
├── SKILL.md                ← Main skill (self-contained for LLMs)
├── report.md               ← This file — generated audit report
├── .gitignore              ← Standard ignores
├── .env.example            ← Secure env template (no real secrets)
└── templates/
    └── report-template.md  ← Template for report generation
```

The skill repository itself is properly structured. No source code exists yet to audit.

---

## 🔴 Critical Vulnerabilities (Must Fix — Ship-Blocking)

> *None present. The following patterns are documented as a preventive reference.*

<details open>
<summary><b>C-1: Hardcoded Secrets in Source</b> — 🔴 Prevent</summary>

```js
// 🚫 NEVER:
const stripeKey = 'sk_live_xxxxxxxxxxxxxxxx';

// ✅ ALWAYS:
const stripeKey = process.env.STRIPE_SECRET_KEY;
```

**Impact:** Committed secrets are scraped by bots. A single leaked API key can cost thousands.

**Check:** `grep -rE "['\"][A-Za-z0-9_\-]{32,}['\"]" --include="*.{js,ts,py,go}" --exclude-dir=node_modules`
</details>

<details>
<summary><b>C-2: SQL / NoSQL Injection</b> — 🔴 Prevent</summary>

```js
// 🚫 NEVER:
db.query(`SELECT * FROM users WHERE id = '${req.params.id}'`);

// ✅ ALWAYS:
db.query('SELECT * FROM users WHERE id = $1', [req.params.id]);
```

**Check:** Search for template literals / string concatenation in query arguments.
</details>

<details>
<summary><b>C-3: Weak Password Reset Tokens</b> — 🔴 Prevent</summary>

```js
// 🚫 NEVER:
const token = Math.random().toString(36).slice(2);

// ✅ ALWAYS:
const token = crypto.randomBytes(32).toString('hex');
```

**Check:** Ensure `crypto.randomBytes` (≥ 32 bytes) is used, not `Math.random()` / `Date.now()`.
</details>

<details>
<summary><b>C-4: JWT "None" Algorithm</b> — 🔴 Prevent</summary>

```js
// 🚫 NEVER:
jwt.verify(token, secret, { algorithms: ['RS256', 'HS256', 'none'] });

// ✅ ALWAYS:
jwt.verify(token, secret, { algorithms: ['HS256'] });
```

**Check:** Every `jwt.verify` call must include `algorithms` with a single explicit value.
</details>

<details>
<summary><b>C-5: Command Injection</b> — 🔴 Prevent</summary>

```js
// 🚫 NEVER:
exec(`ping -c 4 ${req.body.hostname}`, ...);

// ✅ ALWAYS:
execFile('ping', ['-c', '4', sanitizedHostname], ...);
```

**Check:** Search for `exec(`, `shell: true`, `os.system(` with user input.
</details>

---

## 🟠 High Vulnerabilities (Should Fix — Current Sprint)

> *None present. Preventive reference:*

<details>
<summary><b>H-1: Missing Rate Limiting on Auth Routes</b></summary>

**Check:** Every route that accepts credentials must have a rate limiter (login, register, forgot-password, reset-password, MFA verify).
</details>

<details>
<summary><b>H-2: Reset Token Stored as Plaintext</b></summary>

**Check:** Reset tokens must be hashed (SHA-256 or bcrypt) before storage, never plaintext.
</details>

<details>
<summary><b>H-3: CORS with Wildcard Origin</b></summary>

**Check:** Production CORS must use a specific origin allowlist, not `*`.
</details>

<details>
<summary><b>H-4: Missing Webhook Signature Verification</b></summary>

**Check:** Every webhook handler must verify the payload signature before processing.
</details>

<details>
<summary><b>H-5: Verbose Login Error Messages</b></summary>

**Check:** Login, forgot-password endpoints must return identical responses for success/failure.
</details>

<details>
<summary><b>H-6: Login Timing Attack — No Constant-Time Comparison</b></summary>

**Check:** Password comparison must use `crypto.timingSafeEqual` (Node), `hash_equals` (PHP), `hmac.compare_digest` (Python), or a bcrypt/argon2 `compare()` function. Raw `===` is a timing leak.
</details>

<details>
<summary><b>H-7: Magic Link — Missing Single-Use / Expiry Enforcement</b></summary>

**Check:** Magic login links must be single-use, expire in ≤ 15 minutes, and be verified server-side against a token store.
</details>

---

## 🟡 Medium Vulnerabilities (Good to Fix — Next Sprint)

> *None present. Preventive reference:*

<details>
<summary><b>M-1: Missing CSRF Protection</b></summary>

**Check:** State-changing endpoints need CSRF tokens even with SameSite cookies.
</details>

<details>
<summary><b>M-2: No Content Security Policy (CSP)</b></summary>

**Check:** The server should set a `Content-Security-Policy` header to prevent XSS.
</details>

<details>
<summary><b>M-3: Stack Traces in Error Responses</b></summary>

**Check:** Production error handlers must not expose stack traces to clients.
</details>

<details>
<summary><b>M-4: Reset Token Never Expires</b></summary>

**Check:** Reset tokens must expire in ≤ 1 hour, enforced server-side.
</details>

<details>
<summary><b>M-5: Missing HSTS Header</b></summary>

**Check:** `Strict-Transport-Security` header should be set for production deployments.
</details>

<details>
<summary><b>M-6: Magic Link — No Rate Limiting on Send</b></summary>

**Check:** The "send magic link" endpoint must be rate-limited per email and per IP.
</details>

---

## 🔵 Low Vulnerabilities (Nice to Fix)

> *None present. Preventive reference:*

| ID | Issue | Recommendation |
|----|-------|----------------|
| L-1 | No account lockout | Lock after 5 failed attempts for 15 min |
| L-2 | Session timeout too long | Access token: 15 min, Refresh: 7 days |
| L-3 | No MFA / 2FA | Recommended for admin panels and PII-handling apps |
| L-4 | No random keystroke delay on login | Add 50–200ms stochastic delay to obscure timing |

---

## ⚪ Informational

| # | Note |
|---|------|
| I-1 | **Empty project** — this is a greenfield audit. All findings above are **preventive documentation** of patterns to avoid. When code is added, re-run the skill against it. |
| I-2 | **Skill now supports interactive mode** — run with `SKILL.md` in CODEX/CLAUDE/OPENCODE, choose Report-only / Interactive fix / Auto-fix all. |
| I-3 | **3 new audit domains added** — Login Timing Attack Protection (1.5), Magic Links (1.4), and randomized keystroke delay checks integrated into auth. |

---

## 🛡️ Security Checklist (CI-ready)

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
            echo "Command injection found!"; exit 1
          fi
      - name: Weak RNG for tokens
        run: |
          if grep -rn "Math\.random\|Date\.now" --include="*.{js,ts}" \
            --exclude-dir=node_modules | grep -i "token\|secret\|reset\|magic"; then
            echo "Weak RNG used for token generation!"; exit 1
          fi
      - name: Check HTTP headers
        run: |
          if ! grep -rn "helmet\|Strict-Transport-Security\|Content-Security-Policy" \
            --include="*.{js,ts}" --exclude-dir=node_modules; then
            echo "Warning: No security headers middleware found"
          fi
      - name: Dependency audit
        run: |
          if [ -f package.json ]; then npm audit --audit-level=high; fi
```

---

## 📖 How to Use This Skill

```
┌──────────────────────────────────────────────────────────┐
│  1. Add source code to your project                       │
│  2. Run: /cicada                                          │
│     Or: load SKILL.md into your LLM agent                 │
│  3. Choose an operation mode:                             │
│      1 → Report only (read-only audit)                    │
│      2 → Interactive fix (ask per finding)                │
│      3 → Auto-fix all (fix everything)                    │
│  4. Fix Critical → High → Medium (in that order)          │
│  5. Re-audit to confirm fixes                             │
└──────────────────────────────────────────────────────────┘
```

---

## 📚 Reference: Severity Rubric

| Severity | Label | Definition | SLA |
|----------|-------|------------|-----|
| 🔴 **Critical** | Must fix | RCE, SQLi, account takeover, auth bypass, secrets leak, zip bombs, exposed S3 | < 24 hours |
| 🟠 **High** | Should fix | SSRF, weak crypto, missing rate limiting, timing leaks, GraphQL depth | Current sprint |
| 🟡 **Medium** | Good to fix | Missing CSP, verbose errors, no CSRF, no HSTS, no audit trail | Next sprint |
| 🔵 **Low** | Nice to fix | No account lockout, long session timeout, no MFA, no SBOM | When convenient |
| ⚪ **Info** | Note | Architecture choices, observations | — |

---

## Appendix

- **Domains checked (16 total):** Auth, Password Reset, Connectors, API/Input, Secrets, Dependencies, Web Frameworks (10), Mobile (2), Cloud/Infra, GraphQL, WebSocket, File Upload, Data Privacy, Cryptography, CI/CD Supply Chain, Logging & Monitoring
- **Checks performed (skill):** 200+
- **Findings:** 0 (no source code to scan)
- **Preventive patterns documented:** 50+ across all severity levels
- **False positive rate:** N/A — no code scanned

---

*Report generated 2026-06-29 by the Cicada Security Audit Skill. Zero lines of code were modified. The skill now covers 16 security domains across backend, mobile, cloud, and infrastructure.*
