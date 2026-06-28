#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────
#  Cicada — Security Audit & Fix Skill
#  One-command install for any project
#  Usage:
#    curl -fsSL https://raw.githubusercontent.com/Synthrun/Cicada/main/install.sh | bash
#    # or locally:
#    bash install.sh
# ─────────────────────────────────────────────────────

CICADA_DIR="${1:-$PWD/.cicada}"
CICADA_SKILL="$CICADA_DIR/SKILL.md"
FORCE="${FORCE:-false}"

# ── Detect project type ──────────────────────────────
detect_project_type() {
  if [ -f "pubspec.yaml" ]; then
    echo "flutter"
  elif grep -q '"react-native"' package.json 2>/dev/null; then
    echo "react-native"
  elif [ -f "package.json" ]; then
    echo "node"
  elif [ -f "requirements.txt" ] || [ -f "Pipfile" ] || [ -f "pyproject.toml" ]; then
    echo "python"
  elif [ -f "go.mod" ]; then
    echo "go"
  elif [ -f "Gemfile" ]; then
    echo "ruby"
  elif [ -f "composer.json" ]; then
    echo "php"
  elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
    echo "java"
  else
    echo "unknown"
  fi
}

PROJECT_TYPE=$(detect_project_type)
echo "→ Detected project type: $PROJECT_TYPE"

# ── Install ──────────────────────────────────────────
echo "→ Installing Cicada to $CICADA_DIR"
mkdir -p "$CICADA_DIR"

SKILL_FILE="$CICADA_DIR/SKILL.md"

if [ -f "$SKILL_FILE" ] && [ "$FORCE" != "true" ]; then
  echo "✓ Cicada already installed at $SKILL_FILE"
  echo "  Re-run with FORCE=true to overwrite."
  echo "  Run /cicada in your chat to start an audit."
  exit 0
fi

# ── Write SKILL.md ──────────────────────────────────
cat > "$SKILL_FILE" << 'SKILL_EOF'
# 🔐 Cicada — Security Audit & Fix Skill

**Command:** `/cicada`  
Audit your backend and mobile apps for vulnerabilities — and optionally fix them — without deploying or breaking anything.

**Compatible with:** CODEX, CLAUDE, OPENCODE, Cursor, Windsurf, any LLM coding agent.  
**Covers:** Node.js, Python, Go, Ruby, PHP, Java, .NET + Express, Next.js, NestJS, Django, Flask, FastAPI, Gin, Rails, Laravel, Spring Boot + Flutter, React Native.

---

## How to Invoke

```
You:  /cicada
Agent:  Choose mode:
        1 → Report only (no code changes)
        2 → Interactive fix (ask per finding)
        3 → Auto-fix all (fix everything, confirm once)
```

---

## When to Load

Load this skill when the user says:
- `/cicada` — primary command
- "security audit / security review / vulnerability scan"
- "check for vulnerabilities / find security issues"
- "is my app secure / are my auth flows safe"
- "audit login / password reset / connectors / API keys"
- "OWASP review / pentest my code / HackerOne style review"
- "is this production-ready from a security perspective"
- "fix security issues / patch vulnerabilities"
- "audit my Flutter app / React Native app"

---

## Operation Mode

**The LLM must ask the user which mode they want before proceeding.**

| Option | What happens |
|--------|-------------|
| **1 — Report only** | Read-only audit. Generate `report.md`. No code changes. |
| **2 — Interactive fix** | For each finding, ask: "Fix this? (y/n/skip all)". Generate report after. |
| **3 — Auto-fix all** | Fix every finding automatically (user confirms once). Generate report after. |

Present as a numbered list and wait for a response.

```
┌──────────────────────────────────────────────────────────┐
│ Choose mode:                                             │
│                                                          │
│  1 → Report only (no code changes)                       │
│  2 → Interactive fix (ask per finding)                   │
│  3 → Auto-fix all (fix everything, confirm once)         │
│                                                          │
│ Enter 1, 2, or 3:                                        │
└──────────────────────────────────────────────────────────┘
```

---

## Audit Scope

| # | Domain | Key Focus |
|---|--------|-----------|
| 1 | **Auth & Session Mgmt** | login, JWT, OAuth, magic links, timing attacks, MFA |
| 2 | **Password Reset Flow** | token generation, expiry, enumeration protection |
| 3 | **Connector Security** | API keys, webhooks, DB connections, third-party SDKs |
| 4 | **API & Input Handling** | injection, rate limiting, CORS, validation, security headers |
| 5 | **Secrets & Config** | env vars, hardcoded secrets, `.env` exposure, logging |
| 6 | **Dependencies & Infrastructure** | outdated packages, HTTPS, TLS, error handling |
| 7 | **Web Framework Security** | Express, Next.js, NestJS, Django, Flask, FastAPI, Gin, Rails, Laravel, Spring Boot |
| 8 | **Mobile App Security** | Flutter, React Native — deep links, storage, SSL pinning, obfuscation |
| 9 | **Cloud & Infrastructure** | AWS/GCP/Azure configs, S3, IAM, Docker, K8s |
| 10 | **GraphQL Security** | introspection depth, query cost, auth per resolver, batching |
| 11 | **WebSocket Security** | origin validation, WS auth, message rate limiting, replay |
| 12 | **File Upload Security** | magic bytes, size limits, virus scan, path traversal, zip bombs |
| 13 | **Data Privacy & Compliance** | PII, GDPR/CCPA, encryption at rest, data retention |
| 14 | **Cryptography & Key Mgmt** | ciphers, key rotation, RNG, IVs, certificate lifecycle |
| 15 | **CI/CD & Supply Chain** | pipeline secrets, typosquatting, dep confusion, signed commits |
| 16 | **Logging & Monitoring** | audit logs, log injection, retention, alerting gaps |

---

## Check Methodology

1. **Detect** framework(s) used (see Framework Detection below).
2. **Search** the codebase for relevant patterns (grep, glob).
3. **Read** surrounding context (20–40 lines).
4. **Assess** severity using the rubric.
5. **Log** every finding.
6. **If mode 2 or 3:** apply the fix template.

---

## Framework Detection

**Before running checks, auto-detect every framework present.** Read config files and key source imports. Then run only the relevant sections below.

| Framework | Files to read | Key imports / configs to search |
|-----------|--------------|----------------------------------|
| **Node.js / Express** | `package.json` | `express`, `cors`, `helmet` |
| **Next.js** | `package.json`, `next.config.js` | `next`, `next/server` |
| **NestJS** | `package.json`, `nest-cli.json` | `@nestjs/core`, `@UseGuards` |
| **Python / Django** | `requirements.txt`, `settings.py` | `django`, `SECRET_KEY`, `DEBUG` |
| **Python / Flask** | `requirements.txt`, `app.py` | `flask`, `Flask(__name__)`, `secret_key` |
| **Python / FastAPI** | `requirements.txt`, `main.py` | `fastapi`, `FastAPI()`, `CORSMiddleware` |
| **Go / Gin** | `go.mod`, `main.go` | `gin-gonic/gin` |
| **Ruby / Rails** | `Gemfile`, `config/application.rb` | `rails`, `secret_key_base` |
| **PHP / Laravel** | `composer.json`, `.env` | `laravel/framework`, `APP_KEY` |
| **Java / Spring Boot** | `pom.xml`, `application.properties` | `spring-boot-starter-web` |
| **Flutter** | `pubspec.yaml`, `AndroidManifest.xml` | `flutter`, `flutter_secure_storage` |
| **React Native** | `package.json`, `AndroidManifest.xml` | `react-native`, `AsyncStorage` |

> Run ALL relevant sections. If multiple frameworks detected, run all checks.

---

## 1. Authentication & Session Management

### 1.1 Login Endpoint

```
Search:  /login, /signin, /auth, authenticate, passport.authenticate
```

- [ ] **Rate limiting** — is there a rate limiter on the login route?
- [ ] **Account lockout** — failed attempts tracked? Lockout threshold?
- [ ] **Brute-force protection** — CAPTCHA after N failures?
- [ ] **Credential logging** — passwords never logged?
- [ ] **Password comparison** — constant-time? (`timingSafeEqual`, `bcrypt.compare`, `hash_equals`)
- [ ] **Error messages** — generic "Invalid credentials" (not "wrong password" vs "user not found")?
- [ ] **Remember-me tokens** — securely generated and stored?
- [ ] **Enumeration** — identical timing + content for existing vs non-existing accounts?

### 1.2 Session / Token Management

```
Search:  jwt, session, cookie, token, passport, express-session
```

- [ ] **JWT secret** — ≥ 256-bit, env var, never hardcoded?
- [ ] **JWT expiration** — access < 24h? Refresh tokens rotated?
- [ ] **JWT algorithm** — pinned (CVE-2015-9235 "none" attack)?
- [ ] **Session store** — server-side? `httpOnly`, `secure`, `sameSite` set?
- [ ] **Logout** — invalidates server-side?
- [ ] **CSRF** — protection on state-changing endpoints?
- [ ] **MFA / 2FA** — available? TOTP secret encrypted?

### 1.3 OAuth / Social Login

```
Search:  passport-google, passport-github, oauth, OAuth2Strategy
```

- [ ] **State parameter** — cryptographically random, verified?
- [ ] **Redirect URI** — strictly whitelisted?
- [ ] **Token leakage** — tokens never logged or sent to client?
- [ ] **Account linking** — verification step prevents takeover?
- [ ] **PKCE** — used for public clients (mobile, SPA)?

### 1.4 Magic Links & Email Login Links

```
Search:  magic-link, magiclink, sendSignInLink, /verify-email, /confirm
```

- [ ] **Token generation** — `crypto.randomBytes` (≥ 32 bytes)?
- [ ] **Single-use** — invalidated after login?
- [ ] **Expiry** — ≤ 15 minutes?
- [ ] **Rate limiting** — per email and per IP?
- [ ] **Enumeration** — same response whether email exists?
- [ ] **Link injection** — URLs escaped in email templates?
- [ ] **Deep-link hijacking** — App Links / Universal Links (not custom URL scheme alone)?
- [ ] **Replay prevention** — checked against server-side store?
- [ ] **Cross-account reuse** — token bound to specific email?

### 1.5 Login Timing Attack Protection

```
Search:  timingSafeEqual, constant-time, randomDelay, bcrypt.compare, hash_equals
```

- [ ] **Password comparison** — constant-time? (`timingSafeEqual`, `hash_equals`, `hmac.compare_digest`)
- [ ] **User existence** — fake user hash compared when user doesn't exist?
- [ ] **Forgot-password timing** — constant-time lookup?
- [ ] **Random keystroke delay** — stochastic delay added? (50–200ms)
- [ ] **Response padding** — fixed-length responses?

#### Fix: Random delay

```js
function timingSafeLogin(handler) {
  return async (req, res, next) => {
    const delay = 50 + Math.random() * 150;
    await new Promise(r => setTimeout(r, delay));
    return handler(req, res, next);
  };
}
app.post('/login', rateLimiter, timingSafeLogin(loginHandler));
```

---

## 2. Password Reset Flow

```
Search:  reset, forgot-password, forgot_password, /reset-password, token, resetToken
```

### 2.1 Token Generation

- [ ] **Cryptographic randomness** — `crypto.randomBytes`, not `Math.random()` / `Date.now()`?
- [ ] **Token length** — ≥ 128 bits (≥ 32 hex chars)?
- [ ] **URL-safe** — base64url or hex encoded?

#### Fix

```js
const crypto = require('crypto');
const token = crypto.randomBytes(32).toString('hex');
```

### 2.2 Token Storage & Expiry

- [ ] **Hashed in DB** — sha256 or bcrypt, not plaintext?
- [ ] **Expiry** — ≤ 1 hour, enforced server-side?
- [ ] **Single-use** — invalidated after use?
- [ ] **Invalidation** — new request invalidates old tokens?

#### Fix

```js
const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
db.resetTokens.insertOne({ tokenHash, userId, expiresAt: Date.now() + 3600000 });
```

### 2.3 Enumeration Protection

- [ ] **Response** — same for existing/non-existing email?
- [ ] **Timing** — constant-time lookup?
- [ ] **Rate limiting** — per IP and per email?

#### Fix

```js
app.post('/forgot-password', async (req, res) => {
  res.json({ message: 'If that email exists, a reset link has been sent.' });
  setTimeout(async () => {
    const user = await User.findOne({ email: req.body.email });
    if (user) { /* send email */ }
  }, 100 + Math.random() * 200);
});
```

### 2.4 Password Strength

- [ ] **Min length** — ≥ 8 (recommended ≥ 12)?
- [ ] **Strength check** — zxcvbn, haveibeenpwned?
- [ ] **Confirmation** — two matching fields?
- [ ] **Hashing** — bcrypt (≥ 10) or argon2?

---

## 3. Connector Security

```
Search:  apiKey, api_key, webhook, database, stripe, sendgrid, twilio
```

### 3.1 API Keys & Secrets
- [ ] All from env vars?
- [ ] No hardcoded keys?
- [ ] `.env` in `.gitignore`?
- [ ] Key rotation mechanism?
- [ ] Least-privilege scopes?

### 3.2 Webhooks
- [ ] Signature verified? (Stripe `constructEvent`, HMAC)
- [ ] Secret from env var?
- [ ] Replay protection (timestamp window)?
- [ ] Idempotent handlers?

### 3.3 Database Connections
- [ ] Connection string in env var? Logged?
- [ ] TLS in production?
- [ ] Parameterized queries?
- [ ] Pool size appropriate?

### 3.4 Third-party SDKs
- [ ] Errors sanitized (no raw SDK errors to client)?
- [ ] Secrets scoped correctly?

---

## 4. API & Input Handling

### 4.1 Injection

```
Search:  exec, eval, $where, dangerouslySetInnerHTML, child_process
```

- [ ] **SQL/NoSQL injection** — parameterized queries?
- [ ] **Command injection** — `exec` with user input?
- [ ] **SSRF** — user-controlled URLs without host allowlist?
- [ ] **XXE** — XML parsing with external entities disabled?
- [ ] **SSTI** — template injection (Jinja2, ERB, Blade)?

#### Fix

```js
db.query('SELECT * FROM users WHERE id = $1', [req.params.id]);
```

### 4.2 Input Validation
- [ ] Schema validation (Joi, Zod, Pydantic)?
- [ ] Type coercion enforced?
- [ ] Allowlist (deny-by-default)?
- [ ] File uploads — magic bytes, size limit, outside web root?

### 4.3 CORS
- [ ] Specific origin allowlist (not `*`)?
- [ ] Credentials restricted?
- [ ] Pre-flight handled?

### 4.4 Rate Limiting
- [ ] Global limiter?
- [ ] Per-route on auth endpoints?
- [ ] Per-IP / per-user?

### 4.5 HTTP Security Headers
- [ ] Helmet / equivalent applied?
- [ ] Content-Security-Policy?
- [ ] Strict-Transport-Security (HSTS)?
- [ ] X-Frame-Options (DENY)?
- [ ] X-Content-Type-Options (nosniff)?

---

## 5. Secrets & Configuration

### 5.1 Env File Exposure
- [ ] `.env` in `.gitignore`?
- [ ] `.env.example` with placeholders?
- [ ] Hardcoded fallback defaults?
- [ ] Mobile: `google-services.json` / `GoogleService-Info.plist` committed?

### 5.2 Secrets in Source
- [ ] Regex: `['\"][A-Za-z0-9_\-]{32,}['\"]` and `-----BEGIN.*PRIVATE KEY-----`?
- [ ] Secrets in comments or TODOs?
- [ ] Commit history flagged?

### 5.3 Logging
- [ ] Credentials never logged?
- [ ] Tokens never logged?
- [ ] Stack traces not exposed to client?

#### Fix

```js
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});
```

---

## 6. Dependencies & Infrastructure

### 6.1 Outdated Packages
- [ ] `npm audit` / `pip audit` / `composer audit` passes?
- [ ] Deprecated packages?
- [ ] Dev deps in production?

### 6.2 Transport Security
- [ ] HTTP → HTTPS redirect?
- [ ] TLS 1.2+ only?

### 6.3 Error Handling
- [ ] Global error handler?
- [ ] Catch-all 404?
- [ ] `process.on('unhandledRejection')`?

---

## 7. Web Framework Security

### 7.1 Node.js / Express
- [ ] Helmet applied?
- [ ] CORS restrictived?
- [ ] Rate limiting on auth?
- [ ] Body parser size limit?
- [ ] Prototype pollution (`lodash.merge`, `Object.assign(req.body)`)?
- [ ] Cookies: `httpOnly`, `secure`, `sameSite`?
- [ ] `trust proxy` configured?

### 7.2 Next.js
- [ ] Server Actions CSRF?
- [ ] Middleware `matcher` covering all sensitive routes?
- [ ] API routes behind auth?
- [ ] `getServerSideProps` leaking to client?
- [ ] `next/image` SSRF (CVE-2023-34247)?
- [ ] ISR revalidation URLs predictable?

### 7.3 NestJS
- [ ] `@UseGuards` on all controllers?
- [ ] DTO validation (`class-validator`)?
- [ ] GraphQL introspection disabled in prod?
- [ ] `@Serialize` exposing sensitive fields?
- [ ] `@nestjs/throttler` configured?

### 7.4 Django
- [ ] `SECRET_KEY` in env var?
- [ ] `DEBUG = False` in production?
- [ ] `ALLOWED_HOSTS` not `['*']`?
- [ ] REST Framework throttling configured?
- [ ] CSRF middleware enabled?
- [ ] Session cookies secure?
- [ ] Admin panel exposed without IP restriction?

### 7.5 Flask
- [ ] `secret_key` from env var?
- [ ] `debug=True` removed? (Werkzeug RCE)
- [ ] Jinja2 SSTI via `render_template_string`?
- [ ] CSRF protection (Flask-WTF)?
- [ ] CORS restrictived?

### 7.6 FastAPI
- [ ] CORS not `allow_origins=["*"]`?
- [ ] Auth via `Depends(get_current_user)`?
- [ ] Pydantic validators on models?
- [ ] `/docs` and `/redoc` disabled in prod?

### 7.7 Go / Gin
- [ ] CORS restrictived?
- [ ] `gin.Recovery()` included?
- [ ] Rate limiting applied?
- [ ] Raw SQL with user input?

### 7.8 Rails
- [ ] `secret_key_base` exposed?
- [ ] `force_ssl = true`?
- [ ] `params.permit!` mass assignment?
- [ ] `render inline:` SSTI?
- [ ] `protect_from_forgery` enabled?

### 7.9 Laravel
- [ ] `APP_KEY` in `.env` committed?
- [ ] `APP_DEBUG=false`?
- [ ] Eloquent mass assignment protected?
- [ ] `{!! !!}` Blade XSS with user input?
- [ ] `throttle` middleware on auth?

### 7.10 Spring Boot
- [ ] Actuator endpoints secured?
- [ ] `@CrossOrigin(origins = "*")`?
- [ ] H2 console disabled in prod?
- [ ] CSRF not disabled?
- [ ] DevTools removed from production classpath?

---

## 8. Mobile App Security

### 8.1 Flutter
- [ ] API keys in Dart source?
- [ ] `flutter_secure_storage` used (not `SharedPreferences`)?
- [ ] SSL pinning configured?
- [ ] Deep links use App Links / Universal Links?
- [ ] WebView `javascriptMode` restricted?
- [ ] `obscureText: true` on password fields?
- [ ] Cleartext traffic disabled?
- [ ] ATS enabled (iOS)?
- [ ] Code obfuscation (`--obfuscate`)?
- [ ] Root/jailbreak detection?
- [ ] Exported components restricted?

### 8.2 React Native
- [ ] API keys in source or `.env` committed?
- [ ] `react-native-keychain` used (not `AsyncStorage`)?
- [ ] SSL pinning configured?
- [ ] Deep links use App Links / Universal Links?
- [ ] WebView `allowFileAccess` restricted?
- [ ] `secureTextEntry: true` on passwords?
- [ ] Cleartext traffic disabled?
- [ ] ATS enabled (iOS)?
- [ ] Hermes with obfuscation?
- [ ] `__DEV__` debugger disabled in production?
- [ ] Console logs removed in production?

---

## 9. Cloud & Infrastructure Security

### 9.1 Container Security
- [ ] Docker: non-root user (`USER nobody`)?
- [ ] Base images pinned by digest?
- [ ] No secrets in `ENV` / `ARG`?
- [ ] `.dockerignore` excludes `.env`, `node_modules`?
- [ ] K8s: `runAsNonRoot: true`, `allowPrivilegeEscalation: false`?
- [ ] K8s: RBAC least-privilege (no `cluster-admin`)?
- [ ] K8s: `NetworkPolicy` restricting pod traffic?
- [ ] K8s: Secrets encrypted at rest?

### 9.2 Cloud Provider
- [ ] S3 buckets: public access blocked?
- [ ] IAM: no wildcard `Action: "*"` or `Resource: "*"`?
- [ ] IAM keys rotated < 90 days?
- [ ] Cloud storage encrypted (SSE-KMS)?
- [ ] Cloud functions not publicly invocable?
- [ ] DB instances not publicly accessible?
- [ ] Security groups: no `0.0.0.0/0` for SSH/RDP/DB?
- [ ] CloudTrail / audit logs enabled?

---

## 10. GraphQL Security

```
Search:  graphql, GraphQL, Apollo, graphql-yoga, @Resolver
```

- [ ] Introspection disabled in production?
- [ ] Query depth limiting configured?
- [ ] Query cost/complexity analysis?
- [ ] Rate limiting per operation (not just HTTP request)?
- [ ] Auth per resolver (not just globally)?
- [ ] Alias batching prevented?
- [ ] DataLoader preventing N+1 leaks?
- [ ] Field-level access control on sensitive fields?
- [ ] Mutations logged for audit?
- [ ] CSRF protection on GraphQL endpoint?

---

## 11. WebSocket Security

```
Search:  WebSocket, websocket, ws://, wss://, io(), socket.io, WebSocketServer
```

- [ ] Origin validated on upgrade?
- [ ] Authentication on connect (JWT / session)?
- [ ] Message schema validation?
- [ ] Message rate limiting per connection?
- [ ] Idle timeout / disconnection?
- [ ] Replay protection (message sequencing)?
- [ ] Max message size limit?
- [ ] Broadcast authorization (room/channel permissions)?
- [ ] `wss://` enforced in production?
- [ ] Subprotocol validation?

---

## 12. File Upload Security

```
Search:  upload, file, multipart, multer, formidable, UploadFile, FileField, req.file
```

- [ ] File type validated by magic bytes (not just extension)?
- [ ] File size limit enforced?
- [ ] Virus scanning?
- [ ] Path traversal prevented (filenames sanitized)?
- [ ] Files stored outside web root (S3/GCS instead)?
- [ ] Zip bomb protection?
- [ ] SVG/HTML upload blocked (stored XSS)?
- [ ] UUID filenames (not predictable)?
- [ ] EXIF data stripped from images?

---

## 13. Data Privacy & Compliance

```
Search:  pii, privacy, gdpr, ccpa, consent, cookie, personal, data export, delete, retention
```

- [ ] PII fields classified and tagged?
- [ ] Cookie consent banner for non-essential cookies?
- [ ] User data export endpoint?
- [ ] User deletion / right to be forgotten?
- [ ] Data retention policy?
- [ ] PII not in URLs or logs?
- [ ] Encryption at rest enabled?
- [ ] Backups encrypted?
- [ ] Consent records stored?
- [ ] Passwords hashed (never plaintext)?

---

## 14. Cryptography & Key Management

```
Search:  crypto, cipher, encrypt, decrypt, hash, MD5, SHA1, AES, GCM, CBC, ECB, RSA
```

- [ ] No MD5 / SHA-1 for security contexts?
- [ ] No AES-ECB mode?
- [ ] IVs / nonces random (never reused)?
- [ ] Key rotation mechanism?
- [ ] Keys from env vars (not source)?
- [ ] RSA keys ≥ 2048 bits?
- [ ] `crypto.randomBytes` / `SecureRandom` used (not `Math.random`)?
- [ ] Certificates not hardcoded?
- [ ] Passwords hashed with bcrypt/argon2 (not fast hash)?
- [ ] JWT algorithm confusion prevented?
- [ ] TLS 1.2+ only (no SSLv3, TLS 1.0, 1.1)?

---

## 15. CI/CD & Supply Chain Security

```
Search:  .github/workflows, .gitlab-ci.yml, Jenkinsfile, Dockerfile
```

- [ ] CI secrets masked in logs?
- [ ] Lockfiles present (`package-lock.json`, `yarn.lock`)?
- [ ] Subresource Integrity (SRI) on CDN scripts?
- [ ] Dependency confusion prevented (scoped packages)?
- [ ] Typosquatting risk checked?
- [ ] Commits signed (GPG/SSH)?
- [ ] SBOM generated?
- [ ] CI pipeline not self-modifiable by PRs?
- [ ] Artifacts signed / checksummed?
- [ ] CI tokens least-privilege?

---

## 16. Logging & Monitoring Security

```
Search:  log, logger, debug, info, warn, error, audit, sentry, datadog, winston, pino
```

- [ ] Log injection prevented (user input sanitized)?
- [ ] PII redacted in logs?
- [ ] Audit trail for sensitive operations?
- [ ] Alerts for: repeated 401/403, traffic spikes, new geos?
- [ ] Log retention policy?
- [ ] Error reports don't capture request bodies / env vars?
- [ ] Structured logging (JSON, not plaintext)?
- [ ] Log aggregation requires auth?
- [ ] WAF / IDS monitoring for attack patterns?
- [ ] Health endpoints don't leak internal state?

---

## Interactive Fix Workflow

### Mode 2 — Interactive

```
For each finding:

  ┌─────────────────────────────────────────────┐
  │ [C-1] Flutter API key in Dart source        │
  │ File: lib/services/api.dart:8               │
  │ Severity: 🔴 Critical                       │
  │                                              │
  │ Fix this? (y/n/skip-all/skip-severity)       │
  └─────────────────────────────────────────────┘

  - y          → apply fix
  - n          → skip, document in report
  - skip-all   → skip all remaining
  - skip-{sev} → skip all remaining of this severity
```

### Mode 3 — Auto-fix all

```
  Found: 3 Critical, 5 High, 2 Medium, 1 Low
  Apply all fixes? (y/n)
  Show detailed diff first? (y/n)
```

---

## Report Template

```markdown
# Security Audit Report — `<Project Name>`

**Audit date:** YYYY-MM-DD  
**Mode:** Report only / Interactive fix / Auto-fix all  
**Framework(s):** Node.js/Express + Flutter  
**Domains:** 16 domains checked

| Severity | Count | Fixed |
|----------|-------|-------|
| 🔴 Critical | N | N |
| 🟠 High | N | N |
| 🟡 Medium | N | N |
| 🔵 Low | N | N |

### [C-1] Title
- **File:** `path/to/file.ts:42`
- **Domain:** API & Input / Cloud / Mobile / ...
- **Status:** 🔴 Unfixed / ✅ Fixed
- **Evidence:** vulnerable code snippet
- **Fix applied:** fixed code snippet
```

---

## Severity Rubric

| Severity | Label | Definition | SLA |
|----------|-------|------------|-----|
| 🔴 **Critical** | Must fix | RCE, SQLi, account takeover, secrets leak, zip bombs, exposed S3 | < 24h |
| 🟠 **High** | Should fix | SSRF, weak crypto, missing rate limiting, timing leaks, GraphQL depth | Sprint |
| 🟡 **Medium** | Good to fix | Missing CSP, verbose errors, no CSRF, no audit trail | Next sprint |
| 🔵 **Low** | Nice to fix | No HSTS, no MFA, unsigned commits, no SBOM | When convenient |
| ⚪ **Info** | Note | Architecture choice | — |

---

## Meta-Instructions

1. **Detect first** — auto-detect all frameworks. Run checks for every detected framework.
2. **Mode first** — ask which mode before doing anything else.
3. **Read-only in mode 1.** No exceptions.
4. **Cite file:line** for every finding (`path/file.ext:123`).
5. **Include evidence** — show vulnerable snippet.
6. **Absence is a finding** — "No rate limiter found" is valid.
7. **16 domains** — run ALL applicable sections (1–16).
8. **Fix responsibly** — `read` first, then `edit` with precise oldString/newString.
9. **Track fixes** — verify after each change.
10. **Mobile sensitivity** — prioritize: API keys → storage → SSL pinning → deep links.

---

## Quick Reference: Fix by Severity

| Severity | Fix this first |
|----------|----------------|
| 🔴 Critical | Hardcoded secrets, SQL injection, CMD injection, weak reset tokens, JWT alg=none, ECB crypto, no SSL pinning, zip bombs, public S3, no WS auth |
| 🟠 High | Missing rate limiting, plaintext reset tokens, wildcard CORS, no webhook verification, no CSP, log injection, no GraphQL depth limit, no cookie consent |
| 🟡 Medium | No CSRF, stack traces, no HSTS, no file validation, no retention policy, no audit trail, CI secrets exposed |
| 🔵 Low | No lockout, long timeout, no MFA, no SBOM, unsigned commits, no EXIF stripping |
SKILL_EOF

echo "✓ Created $SKILL_FILE ($(wc -l < "$SKILL_FILE") lines)"

# ── Write AGENTS.md ────────────────────────────────
cat > "$CICADA_DIR/AGENTS.md" << 'AGENTS_EOF'
# Cicada — Security Audit Agent

## Command
- `/cicada` — Run a full security audit (asks for mode first)

## Triggers
- "security audit" / "vulnerability scan" / "check for vulnerabilities"
- "audit my app / backend / auth / login" / "is my app secure"
- "pentest my code" / "fix security issues"

## Workflow
1. Load SKILL.md
2. Ask user for mode: Report only / Interactive fix / Auto-fix all
3. Detect frameworks
4. Run all relevant checks (16 domains)
5. Generate report.md
6. (If fix mode) Apply fixes
AGENTS_EOF
echo "✓ Created $CICADA_DIR/AGENTS.md"

# ── Write opencode.json ────────────────────────────
cat > "$CICADA_DIR/opencode.json" << 'OPENCODE_EOF'
{
  "name": "cicada",
  "description": "Security audit & fix skill for web and mobile apps",
  "version": "1.0.0",
  "agents": {
    "cicada": {
      "description": "Run a full security audit (16 domains) with optional auto-fix",
      "skills": ["SKILL.md"],
      "command": "/cicada",
      "triggers": ["security audit", "vulnerability scan", "/cicada"]
    }
  }
}
OPENCODE_EOF
echo "✓ Created $CICADA_DIR/opencode.json"

# ── Write .cicada config ───────────────────────────
cat > "$CICADA_DIR/.cicada" << 'CICADA_EOF'
command: /cicada
description: Security audit for web, mobile, cloud, and infra
skill: SKILL.md
modes: [report, interactive, auto-fix]
domains: 16
CICADA_EOF
echo "✓ Created $CICADA_DIR/.cicada"

# ── Symlink to project root (optional) ─────────────
if [ "$CICADA_DIR" != "$PWD/.cicada" ]; then
  for f in AGENTS.md opencode.json; do
    if [ -f "$CICADA_DIR/$f" ] && [ ! -f "$PWD/$f" ]; then
      ln -sf ".cicada/$f" "$PWD/$f"
      echo "→ Linked $f to project root"
    fi
  done
fi

# ── Done ───────────────────────────────────────────
echo ""
echo "┌──────────────────────────────────────────────────────────┐"
echo "│  ✓ Cicada installed successfully!                        │"
echo "│                                                          │"
echo "│  Run in your LLM chat:                                   │"
echo "│    /cicada                                                │"
echo "│                                                          │"
echo "│  Or say:                                                  │"
echo "│    \"security audit\"                                       │"
echo "│                                                          │"
echo "│  Installed at: $CICADA_DIR                    │"
echo "│  Domains covered: 16                                      │"
echo "└──────────────────────────────────────────────────────────┘"