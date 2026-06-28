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

You:  /cicada audit my backend
Agent:  (loads SKILL.md, asks mode, runs audit)

You:  security audit
Agent:  (triggered by AGENTS.md, loads SKILL.md, asks mode)
```

### Tool-specific setup

| Tool | Setup |
|------|-------|
| **OPENCODE** | Place `opencode.json` + `AGENTS.md` in project root. Run `/cicada`. |
| **CLAUDE** | Place `AGENTS.md` in project root or `.claude/`. Run `/cicada`. |
| **CODEX** | Load SKILL.md directly: `/load-skill /path/to/SKILL.md` then run. |
| **Cursor / Windsurf** | Load SKILL.md directly as a rules file or use `.cicada` config. |

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
| 1 | **Auth & Session Mgmt** | login, logout, JWT, OAuth, magic links, timing attacks |
| 2 | **Password Reset Flow** | token generation, expiry, enumeration protection |
| 3 | **Connector Security** | API keys, webhooks, DB connections, third-party SDKs |
| 4 | **API & Input Handling** | injection, rate limiting, CORS, validation, security headers |
| 5 | **Secrets & Config** | env vars, hardcoded secrets, `.env` exposure, logging |
| 6 | **Dependencies & Infrastructure** | outdated packages, HTTPS, TLS, error handling |
| 7 | **Web Framework Security** | Express, Next.js, NestJS, Django, Flask, FastAPI, Gin, Rails, Laravel, Spring Boot |
| 8 | **Mobile App Security** | Flutter, React Native — deep links, storage, SSL pinning, obfuscation |
| 9 | **Cloud & Infrastructure** | AWS/Azure/GCP configs, S3 buckets, IAM roles, Docker, K8s |
| 10 | **GraphQL Security** | introspection depth, query cost, auth per resolver, batching |
| 11 | **WebSocket Security** | origin validation, WS auth, message rate limiting, replay |
| 12 | **File Upload Security** | magic bytes, size limits, virus scan, path traversal, zip bombs |
| 13 | **Data Privacy & Compliance** | PII handling, GDPR/CCPA, encryption at rest, data retention |
| 14 | **Cryptography & Key Mgmt** | ciphers, key rotation, RNG, IVs, certificate lifecycle |
| 15 | **CI/CD & Supply Chain** | pipeline secrets, typosquatting, dep confusion, signed commits |
| 16 | **Logging & Monitoring** | audit logs, log injection, retention, alerting gaps |

---

## Check Methodology

1. **Detect** framework(s) used (see Framework Detection below).
2. **Search** the codebase for relevant patterns (grep, glob).
3. **Read** surrounding context (20–40 lines) to understand the implementation.
4. **Assess** severity using the rubric at the end of this document.
5. **Log** every finding — even low-severity — into an internal findings list.
6. **If mode 2 or 3:** apply the fix template associated with each finding.

---

## Framework Detection

**Before running checks, auto-detect every framework present.** Read config files and key source imports. Then run only the relevant sections below.

### Detection Table

| Framework | Files to read | Key imports / configs to search |
|-----------|--------------|----------------------------------|
| **Node.js / Express** | `package.json` | `express`, `cors`, `helmet`, `express-rate-limit` |
| **Next.js** | `package.json`, `next.config.js`, `next.config.mjs` | `next`, `next/server`, middleware.ts |
| **NestJS** | `package.json`, `nest-cli.json` | `@nestjs/core`, `@nestjs/common`, `@UseGuards` |
| **Python / Django** | `requirements.txt`, `Pipfile`, `pyproject.toml`, `manage.py`, `settings.py` | `django`, `SECRET_KEY`, `DEBUG` |
| **Python / Flask** | `requirements.txt`, `app.py`, `config.py` | `flask`, `Flask(__name__)`, `secret_key` |
| **Python / FastAPI** | `requirements.txt`, `main.py` | `fastapi`, `FastAPI()`, `CORSMiddleware` |
| **Go / Gin** | `go.mod`, `main.go` | `gin-gonic/gin`, `gin.Default()` |
| **Ruby / Rails** | `Gemfile`, `config/application.rb`, `config/secrets.yml` | `rails`, `secret_key_base`, `config.force_ssl` |
| **PHP / Laravel** | `composer.json`, `.env`, `config/app.php` | `laravel/framework`, `APP_KEY`, `APP_DEBUG` |
| **Java / Spring Boot** | `pom.xml`, `build.gradle`, `application.properties`, `application.yml` | `spring-boot-starter-web`, `@SpringBootApplication` |
| **Flutter** | `pubspec.yaml`, `android/`, `ios/`, `lib/` | `flutter`, `flutter_secure_storage`, `http`, `webview_flutter` |
| **React Native** | `package.json`, `android/`, `ios/`, `app.json` | `react-native`, `AsyncStorage`, `react-native-config` |

> Run ALL relevant sections based on detected frameworks. If multiple frameworks are detected (e.g., Next.js backend + Flutter mobile), run checks for all of them.

---

## 7. Web Framework Security

Run this section for every detected web framework in addition to the universal checks (sections 1–6).

---

### 7.1 Node.js / Express

```
Search:  package.json, express, app.use(, router.get(, router.post(
```

- [ ] **Missing Helmet** — is `helmet()` applied globally? Without it, default security headers (CSP, HSTS, X-Frame-Options) are absent.
- [ ] **CORS misconfigured** — `cors({ origin: '*' })` in production? Should use an allowlist.
- [ ] **Rate limiting missing** — is `express-rate-limit` applied to auth routes?
- [ ] **Body parser size limit** — does `express.json({ limit: '10mb' })` have an unbounded limit? Set to `'1mb'` or `'10kb'` for small payloads.
- [ ] **HTTP parameter pollution** — does the app handle duplicate query params safely? (e.g., `?id=1&id=2`)
- [ ] **Prototype pollution** — are there any unsafe `lodash.merge`, `Object.assign(req.body, ...)`, or `for...in` patterns?
- [ ] **Cookie config** — are cookies missing `httpOnly`, `secure`, `sameSite`?
- [ ] **Express `app.set('trust proxy')`** — is it configured correctly behind a reverse proxy? If not, rate limiting may see all traffic from `127.0.0.1`.
- [ ] **Directory listing** — is `express.static` configured without `dotfiles: 'deny'`? Can attackers list directories?

#### Fix: Add Helmet + rate limiting + secure cookies

```js
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

app.use(helmet());
app.use(express.json({ limit: '1mb' }));

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: 'Too many attempts'
});
app.post('/login', authLimiter, loginHandler);

app.use(require('cookie-parser')());
app.use((req, res, next) => {
  res.cookie('session', req.sessionID, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 24 * 60 * 60 * 1000
  });
  next();
});
```

---

### 7.2 Next.js

```
Search:  package.json, next.config, middleware.ts, pages/api/, app/api/
```

- [ ] **Server Actions CSRF** — are Next.js Server Actions protected with CSRF tokens? (Next.js 14+ has built-in CSRF for Server Actions — verify it's not disabled.)
- [ ] **Middleware bypass** — does `middleware.ts` protect all sensitive routes? Check for missing `matcher` config.
- [ ] **API route exposure** — are internal API routes behind authentication middleware? Check `pages/api/` or `app/api/` for unprotected handlers.
- [ ] **`getServerSideProps` data leakage** — does `getServerSideProps` pass sensitive data (tokens, DB records) to the client without filtering?
- [ ] **`next/image` SSRF** — are remote image URLs user-controllable without a host allowlist? (CVE-2023-34247)
- [ ] **`next.config.js` exposure** — is `publicRuntimeConfig` leaking secrets to the client bundle?
- [ ] **Incremental Static Regeneration (ISR)** — are secret revalidation URLs predictable or unprotected?
- [ ] **App Router: `useSearchParams` XSS** — are search params rendered without sanitization in client components?
- [ ] **`next/script` CSP bypass** — are external scripts loaded with `strategy: 'beforeInteractive'` bypassing CSP?

#### Fix: Secure middleware

```ts
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const token = request.cookies.get('session')?.value;
  const isAuthPage = request.nextUrl.pathname.startsWith('/login');

  if (!token && !isAuthPage) {
    return NextResponse.redirect(new URL('/login', request.url));
  }
  return NextResponse.next();
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/protected/:path*']
};
```

#### Fix: Image SSRF protection

```js
// next.config.js
module.exports = {
  images: {
    remotePatterns: [
      { protocol: 'https', hostname: 'cdn.example.com' },
      { protocol: 'https', hostname: 'images.example.com' }
    ]
  }
};
```

---

### 7.3 NestJS

```
Search:  package.json, @nestjs, @UseGuards, @Controller, GraphQLModule
```

- [ ] **Missing `@UseGuards`** — are controllers/routes missing authentication guards? Check for public endpoints that should be protected.
- [ ] **DTO validation bypass** — are DTOs missing `class-validator` decorators? (`@IsEmail()`, `@IsString()`, `@MinLength(8)`)
- [ ] **GraphQL introspection enabled in production** — is `introspection: true` set in `GraphQLModule.forRoot()`? (Leaks entire schema.)
- [ ] **`@Serialize` / class-serializer exposure** — does `@Serialize` expose sensitive fields like `password`, `ssn`?
- [ ] **Rate limiting missing** — is `@nestjs/throttler` configured globally?
- [ ] **CORS misconfigured** — is `cors: true` / `origin: '*'` in `NestFactory.create()`?
- [ ] **File upload validation** — are file uploads unrestricted in size or type?
- [ ] **Validation pipe global** — is `app.useGlobalPipes(new ValidationPipe())` applied? (Without it, DTO validation is opt-in per route.)

#### Fix: Global validation + throttling

```ts
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.enableCors({
    origin: process.env.CORS_ORIGIN?.split(',') || 'http://localhost:3000',
    credentials: true
  });

  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true
  }));

  await app.listen(3000);
}
```

```ts
// app.module.ts
@Module({
  imports: [
    ThrottlerModule.forRoot([{
      ttl: 60000,
      limit: 100
    }])
  ],
  providers: [{ provide: APP_GUARD, useClass: ThrottlerGuard }]
})
```

---

### 7.4 Python / Django

```
Search:  settings.py, manage.py, requirements.txt, SECRET_KEY, DEBUG, ALLOWED_HOSTS
```

- [ ] **`SECRET_KEY` hardcoded or committed** — is the Django `SECRET_KEY` in `settings.py` instead of an env var?
- [ ] **`DEBUG = True` in production** — is `DEBUG` set to `True` in production settings? (Leaks stack traces, settings, queries.)
- [ ] **`ALLOWED_HOSTS` misconfigured** — is `['*']` used? (Permits host header injection.)
- [ ] **SQL injection via `.raw()` / `extra()`** — are raw SQL queries parameterized?
- [ ] **Mass assignment** — are Django REST Framework serializers using `fields = '__all__'` without read-only fields?
- [ ] **`mark_safe()` / `safe` filter XSS** — is `mark_safe()` used on user input in templates?
- [ ] **CSRF middleware missing** — is `CsrfViewMiddleware` in `MIDDLEWARE` settings?
- [ ] **Session cookie config** — are `SESSION_COOKIE_HTTPONLY`, `SESSION_COOKIE_SECURE`, `CSRF_COOKIE_SECURE` set?
- [ ] **File upload validation** — is `FILE_UPLOAD_MAX_MEMORY_SIZE` set? Are uploaded file types validated?
- [ ] **Django REST Framework throttle** — is `DEFAULT_THROTTLE_CLASSES` configured for auth endpoints?
- [ ] **CORS headers** — is `django-cors-headers` configured with a specific `CORS_ALLOWED_ORIGINS`, not `CORS_ALLOW_ALL_ORIGINS = True`?
- [ ] **Admin panel exposure** — is `django.contrib.admin` accessible at `/admin/` without IP restriction or VPN?

#### Fix: Secure settings.py

```python
import os

SECRET_KEY = os.environ['DJANGO_SECRET_KEY']
DEBUG = os.environ.get('DJANGO_DEBUG', 'False') == 'False'
ALLOWED_HOSTS = os.environ.get('DJANGO_ALLOWED_HOSTS', '.example.com').split(',')

SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
CSRF_COOKIE_HTTPONLY = True
SECURE_HSTS_SECONDS = 63072000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_SSL_REDIRECT = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = 'DENY'

# Rate limiting
REST_FRAMEWORK = {
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/hour',
        'user': '1000/hour'
    }
}
```

---

### 7.5 Python / Flask

```
Search:  app.py, config.py, requirements.txt, Flask(__name__), secret_key, debug=True
```

- [ ] **`secret_key` hardcoded** — is `app.secret_key` set to a static string in source?
- [ ] **`debug=True` in production** — does `app.run(debug=True)` exist? (Leaves the Werkzeug debugger and console open — RCE via debugger PIN.)
- [ ] **Jinja2 SSTI (Server-Side Template Injection)** — is `render_template_string()` used with user input?
- [ ] **Missing CSRF protection** — is `Flask-WTF` or `flask-seasurf` installed and enabled?
- [ ] **Session cookies** — are `SESSION_COOKIE_HTTPONLY`, `SESSION_COOKIE_SECURE`, `SESSION_COOKIE_SAMESITE` configured?
- [ ] **CORS wildcard** — is `flask-cors` configured with `origins='*'`?
- [ ] **Rate limiting** — is `flask-limiter` applied to auth routes?

#### Fix: Secure Flask app

```python
from flask import Flask
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_talisman import Talisman

app = Flask(__name__)
app.secret_key = os.environ['FLASK_SECRET_KEY']
app.config.update(
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SECURE=True,
    SESSION_COOKIE_SAMESITE='Lax'
)

# Security headers
Talisman(app, content_security_policy={
    'default-src': "'self'",
    'script-src': "'self'"
})

# Rate limiting
limiter = Limiter(
    get_remote_address,
    app=app,
    default_limits=["200 per day", "50 per hour"]
)

# 🚫 NEVER: app.run(debug=True)
```

---

### 7.6 Python / FastAPI

```
Search:  main.py, requirements.txt, FastAPI(), CORSMiddleware, @app.get
```

- [ ] **CORS wildcard** — is `CORSMiddleware` configured with `allow_origins=["*"]`?
- [ ] **Missing authentication** — are routes missing `Depends(get_current_user)`?
- [ ] **Pydantic validation bypass** — are request models missing Pydantic validators? (`Field(..., min_length=8)`)
- [ ] **GraphQL introspection** — if using Strawberry/Ariadne, is introspection disabled in production?
- [ ] **File upload size** — are file uploads missing `max_size` on `UploadFile`?
- [ ] **Rate limiting** — is `slowapi` or `fastapi-limiter` configured?
- [ ] **OpenAPI / Swagger exposure** — is `/docs` or `/redoc` exposed in production? (Leaks full API structure.)
- [ ] **Server info leakage** — does `uvicorn` run with `--header Server: uvicorn`? Attackers can target known uvicorn bugs.

#### Fix: Secure FastAPI

```python
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

app = FastAPI(
    docs_url=None,          # Disable Swagger in production
    redoc_url=None,         # Disable ReDoc in production
    servers=[{"url": "https://api.example.com"}]
)

app.state.limiter = limiter
app.add_exception_handler(429, _rate_limit_exceeded_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=os.environ.get('CORS_ORIGINS', '').split(','),
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
)

@app.get("/users/me")
@limiter.limit("30/minute")
async def read_users_me(current_user=Depends(get_current_user)):
    return current_user
```

---

### 7.7 Go / Gin

```
Search:  go.mod, main.go, gin.Default(), router.GET(, c.Query(, db.Query(
```

- [ ] **CORS wildcard** — is `gin-contrib/cors` configured with `AllowAllOrigins: true`?
- [ ] **Missing recovery middleware** — is `gin.Recovery()` included? (Without it, panics crash the server.)
- [ ] **No rate limiting** — is `gin-limiter` or similar applied to auth routes?
- [ ] **Raw SQL injection** — are there `db.Query(fmt.Sprintf(...))` calls with user input?
- [ ] **No `TrustedPlatform`** — is `gin.TrustedPlatform` set behind a reverse proxy? (Without it, client IP detection may be wrong for rate limiting.)
- [ ] **Verbose error responses** — does the API return raw error messages or stack traces?
- [ ] **Cookie config** — are session cookies missing `HttpOnly`, `Secure`, `SameSite`?
- [ ] **No request size limit** — is `c.MaxMultipartMemory` and `gin.MaxMultipartMemory` configured?

#### Fix: Secure Gin

```go
package main

import (
    "github.com/gin-gonic/gin"
    "github.com/gin-contrib/cors"
    "golang.org/x/time/rate"
)

func main() {
    r := gin.New()
    r.Use(gin.Recovery())
    r.Use(gin.Logger())

    // CORS
    r.Use(cors.New(cors.Config{
        AllowOrigins: []string{"https://app.example.com"},
        AllowCredentials: true,
        AllowMethods: []string{"GET", "POST", "PUT", "DELETE"},
        AllowHeaders: []string{"Authorization", "Content-Type"},
    }))

    // Rate limiting
    limiter := rate.NewLimiter(rate.Limit(10), 20)
    r.Use(func(c *gin.Context) {
        if !limiter.Allow() {
            c.AbortWithStatusJSON(429, gin.H{"error": "Too many requests"})
            return
        }
        c.Next()
    })

    r.GET("/login", loginHandler)
    r.Run(":3000")
}
```

---

### 7.8 Ruby on Rails

```
Search:  Gemfile, config/application.rb, config/secrets.yml, app/controllers/
```

- [ ] **`secret_key_base` hardcoded or weak** — is `secret_key_base` in `config/secrets.yml` or `credentials.yml.enc` exposed?
- [ ] **`config.force_ssl = false`** — is HTTPS not enforced?
- [ ] **Mass assignment** — are there `params.permit!` calls that allow all attributes? (CVE-2012-2660, CVE-2012-2695)
- [ ] **Render inline SSTI** — is `render inline:` used with user input? (Server-Side Template Injection.)
- [ ] **`attr_accessible` / `attr_protected` bypass** — are sensitive model attributes protected from mass assignment?
- [ ] **SQL injection via `where()` strings** — are there `Model.where("name = '#{params[:name]}'")` calls?
- [ ] **Missing CSRF token** — is `protect_from_forgery with: :exception` in `ApplicationController`?
- [ ] **Open redirect** — are there unsafe `redirect_to params[:url]` patterns? (CVE-2023-23913)
- [ ] **N+1 queries exposed** — does the JSON API leak child records without authorization checks?
- [ ] **Cookie config** — are cookies missing `httponly`, `secure`, `samesite` in `config/initializers/session_store.rb`?

#### Fix: Secure Rails configuration

```ruby
# config/application.rb
config.force_ssl = true
config.ssl_options = { redirect: { status: 301 } }

# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store, {
  key: '_app_session',
  httponly: true,
  secure: Rails.env.production?,
  same_site: :strict,
  expire_after: 24.hours
}

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :sanitize_redirect
  private
  def sanitize_redirect
    redirect_url = params[:url]
    if redirect_url.present? && !redirect_url.start_with?('/')
      redirect_to root_path, alert: 'Invalid redirect'
    end
  end
end
```

---

### 7.9 PHP / Laravel

```
Search:  composer.json, .env, config/app.php, routes/web.php, routes/api.php
```

- [ ] **`APP_KEY` exposed** — is `APP_KEY` in `.env` committed to the repo?
- [ ] **`APP_DEBUG=true` in production** — is debug mode enabled? (Leaks full stack traces and env vars.)
- [ ] **Mass assignment** — are Eloquent models missing `$fillable` or using `$guarded = []`?
- [ ] **SQL injection via `whereRaw` / `DB::raw`** — are raw queries using string interpolation with user input?
- [ ] **Blade XSS** — is `{!! $var !!}` (unescaped Blade output) used with user-controlled content?
- [ ] **Missing CSRF** — is `@csrf` excluded from forms? Is `VerifyCsrfToken` middleware removed?
- [ ] **CORS misconfigured** — is `laravel-cors` set to `'allowed_origins' => ['*']`?
- [ ] **Rate limiting** — is `throttle` middleware applied to auth routes? (`Route::post('login', ...)->middleware('throttle:5,60')`)
- [ ] **Session config** — are sessions configured with `http_only => true`, `secure => true`?
- [ ] **Debug bar in production** — is `barryvdh/laravel-debugbar` installed and visible?
- [ ] **Artisan console exposure** — is `routes/console.php` exposing sensitive commands?

#### Fix: Secure Laravel

```php
// .env (ensure in .gitignore!)
APP_KEY=base64:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
APP_DEBUG=false
APP_URL=https://example.com

DB_CONNECTION=mysql
DB_HOST=${DB_HOST}
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}

// config/session.php
'http_only' => true,
'secure' => env('APP_ENV') === 'production',
'same_site' => 'strict',

// routes/api.php
Route::post('/login', [AuthController::class, 'login'])
    ->middleware(['throttle:5,60']);
```

---

### 7.10 Java / Spring Boot

```
Search:  pom.xml, build.gradle, application.properties, application.yml, @RestController, @RequestMapping
```

- [ ] **Actuator endpoints exposed** — are `/actuator`, `/actuator/env`, `/actuator/heapdump` accessible without authentication? (Leaks env vars — including AWS keys, DB passwords.)
- [ ] **`@CrossOrigin(origins = "*")`** — are any controllers using wildcard CORS?
- [ ] **`@PathVariable` injection** — are path variables used in SQL queries without parameterization?
- [ ] **H2 console in production** — is `spring.h2.console.enabled=true` set? (Database admin panel with no auth.)
- [ ] **Default Actuator ports** — is Actuator on the same port as the app? Should be on a separate, firewalled port.
- [ ] **No CSRF protection** — is Spring Security CSRF protection disabled? (`http.csrf().disable()`)
- [ ] **Verbose error responses** — is `server.error.include-stacktrace=always` set? (Leaks internal paths and framework details.)
- [ ] **Unvalidated file uploads** — is `spring.servlet.multipart.max-file-size` unset or too large?
- [ ] **Spring Boot DevTools in production** — is `spring-boot-devtools` on the classpath? (Remote restart and debug endpoints.)
- [ ] **Sensitive fields in JSON** — are `@JsonIgnore` annotations missing on `password`, `secret`, `token` fields?

#### Fix: Secure application.properties

```properties
# Disable actuator in production or secure it
management.endpoints.web.exposure.exclude=*
management.endpoint.health.show-details=never

# Disable H2 console
spring.h2.console.enabled=false

# Limit file uploads
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB

# No stack traces
server.error.include-stacktrace=never
server.error.include-message=never

# Force HTTPS
server.ssl.enabled=true
```

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.requireCsrfProtectionMatcher(...))
            .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .anyRequest().authenticated()
            );
        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(List.of("https://app.example.com"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE"));
        config.setAllowCredentials(true);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
```

---

## 8. Mobile App Security

Run this section when the project contains Flutter (`pubspec.yaml`) or React Native (`package.json` with `react-native`).

---

### 8.1 Flutter / Dart

```
Search:  pubspec.yaml, android/app/src/main/AndroidManifest.xml, ios/Runner/Info.plist, lib/
```

- [ ] **API keys hardcoded in Dart** — are API keys, Firebase configs, or tokens hardcoded in Dart source? (Dart code decompiles easily with `dart2js` / `flutter build apk --release` + `dex2jar`.)
- [ ] **Insecure local storage** — is sensitive data stored in `SharedPreferences` instead of `flutter_secure_storage`? (SharedPreferences is plaintext on disk.)
- [ ] **No SSL pinning** — is HTTP client created without certificate pinning? (`http.Client()` vs pinned `dio` or `http_secure`?)
- [ ] **Deep link hijacking** — are Android App Links / iOS Universal Links configured? Or does the app use custom URL schemes (e.g., `myapp://`) that any app can register?
- [ ] **WebView XSS / JS bridge** — does `webview_flutter` have `javascriptMode: JavascriptMode.unrestricted`? Does `JavaScriptChannel` expose sensitive native APIs?
- [ ] **`obscureText: false` on password fields** — are password `TextField`s missing `obscureText: true`?
- [ ] **Sensitive logging** — is `debugPrint()` or `print()` used for sensitive data? (Release builds can still have debug logging.)
- [ ] **Android: Allow cleartext traffic** — is `android:usesCleartextTraffic="true"` in `AndroidManifest.xml`?
- [ ] **iOS: ATS bypass** — is `NSAllowsArbitraryLoads = true` in `Info.plist`? (Disables App Transport Security.)
- [ ] **Root / jailbreak detection** — is there any root detection? If not, attackers can modify the app binary and extract secrets.
- [ ] **Code obfuscation** — was the app built without `--obfuscate` and `--split-debug-info`? (Without obfuscation, Dart code retains class/method names.)
- [ ] **Firebase config files** — are `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) readable and restricted to the intended app? (These contain API keys.)
- [ ] **Biometric auth** — if using biometrics, is the secret stored with `KeyStore` / `Keychain` integration (via `local_auth` + `flutter_secure_storage`)?
- [ ] **Android: Exported components** — are `Activity`, `Service`, or `BroadcastReceiver` exported without permission? (`android:exported="true"` without intent filters.)
- [ ] **iOS: Keychain accessibility** — is `kSecAttrAccessible` set to `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` for sensitive data?

#### Fix: Secure storage + SSL pinning (Flutter)

```dart
// 🚫 BAD:
final prefs = await SharedPreferences.getInstance();
await prefs.setString('auth_token', token);

// ✅ GOOD:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();
await storage.write(key: 'auth_token', value: token);
```

```dart
// 🚫 BAD:
final response = await http.get(Uri.parse('https://api.example.com/data'));

// ✅ GOOD — SSL pinning with Dio
import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: const Duration(seconds: 10),
));

(dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    (client) {
  client.badCertificateCallback = (cert, host, port) => false; // reject all
  return client;
};
```

#### Fix: Secure Android manifest

```xml
<!-- AndroidManifest.xml -->
<application
    android:usesCleartextTraffic="false"
    android:allowBackup="false"
    android:networkSecurityConfig="@xml/network_security_config">

    <!-- Only export if required -->
    <activity
        android:name=".MainActivity"
        android:exported="false" />
</application>
```

```xml
<!-- res/xml/network_security_config.xml -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">api.example.com</domain>
    </domain-config>
</network-security-config>
```

#### Fix: iOS ATS configuration

```xml
<!-- Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>api.example.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

#### Fix: Build with obfuscation

```bash
flutter build apk --obfuscate --split-debug-info=build/debug-info/
flutter build ios --obfuscate --split-debug-info=build/debug-info/
```

---

### 8.2 React Native

```
Search:  package.json, android/app/src/main/AndroidManifest.xml, ios/Info.plist, app.json
```

- [ ] **API keys in `.env` or hardcoded** — are API keys in `react-native-config` `.env` files committed? Are they hardcoded in JS source? (JS bundle is unencrypted on device.)
- [ ] **AsyncStorage for sensitive data** — is `AsyncStorage` used for tokens, secrets, or PII? (AsyncStorage is unencrypted plaintext — use `react-native-keychain` or `expo-secure-store`.)
- [ ] **No SSL pinning** — does `fetch()` or `axios` connect without certificate validation? (Use `react-native-ssl-pinning` or `axios` with `httpsAgent`.)
- [ ] **Deep link hijacking** — are Android App Links / iOS Universal Links properly configured, or does a custom URL scheme (`myapp://`) allow any app to intercept?
- [ ] **WebView vulnerabilities** — does `react-native-webview` have `allowFileAccess={true}`, `allowUniversalAccessFromFileURLs={true}`, or `javaScriptEnabled={true}` without a content allowlist?
- [ ] **`secureTextEntry: false` on password fields** — are password `TextInput`s missing `secureTextEntry={true}`?
- [ ] **`console.log` in production** — are `console.log`, `console.warn`, `console.error` statements present in production code? (They can leak data to logs accessible by other apps on device.)
- [ ] **Android: Allow cleartext traffic** — is `android:usesCleartextTraffic="true"` in `AndroidManifest.xml`?
- [ ] **iOS: ATS bypass** — is `NSAllowsArbitraryLoads = true` in `Info.plist`?
- [ ] **Firebase / Google Services** — are `google-services.json` or `GoogleService-Info.plist` committed with unrestricted API keys?
- [ ] **Code obfuscation** — is Hermes enabled without obfuscation? (JS bundle can be reverse-engineered with `react-native-decompiler`.)
- [ ] **React Native Debugger enabled** — is `__DEV__` mode exposed in production? (Debugger allows arbitrary JS execution.)
- [ ] **Flipper / Metro bundler in production** — is `react-native-flipper` or Metro bundler enabled in release builds? (Exposes debugging endpoints.)
- [ ] **Android: Exported activities** — are `Activity`s exported without permission?
- [ ] **iOS: Keychain accessibility** — is `react-native-keychain` configured with `accessControl: ACCESS_CONTROL.BIOMETRY_CURRENT_SET_OR_DEVICE_PASSCODE`?
- [ ] **Clipboard exposure** — is sensitive data (passwords, tokens) accessible via the system clipboard? (Other apps can read the clipboard on Android.)
- [ ] **Bundle ID / Package name spoofing** — does the app validate its own bundle identifier at runtime? (Without it, a malicious clone with the same bundle ID can steal keychain data.)

#### Fix: Secure storage (React Native)

```ts
// 🚫 BAD:
import AsyncStorage from '@react-native-async-storage/async-storage';
await AsyncStorage.setItem('auth_token', token);

// ✅ GOOD:
import * as Keychain from 'react-native-keychain';

await Keychain.setInternetCredentials(
  'api.example.com', // server
  'user',            // username
  token,             // password (stores token securely)
  {
    accessControl: Keychain.ACCESS_CONTROL.BIOMETRY_CURRENT_SET_OR_DEVICE_PASSCODE,
    accessible: Keychain.ACCESSIBLE.WHEN_UNLOCKED_THIS_DEVICE_ONLY
  }
);
```

#### Fix: SSL pinning (React Native)

```ts
// 🚫 BAD:
const response = await fetch('https://api.example.com/data');

// ✅ GOOD (with react-native-ssl-pinning):
import { fetch } from 'react-native-ssl-pinning';

const response = await fetch('https://api.example.com/data', {
  method: 'GET',
  sslPinning: {
    certs: ['certificate_name'] // bundled .cer files
  },
  timeoutInterval: 10000
});
```

#### Fix: Secure WebView configuration

```tsx
// 🚫 BAD:
<WebView
  source={{ uri: 'https://example.com' }}
  javaScriptEnabled={true}
  allowFileAccess={true}
/>

// ✅ GOOD:
<WebView
  source={{ uri: 'https://example.com' }}
  javaScriptEnabled={true}
  allowFileAccess={false}
  allowUniversalAccessFromFileURLs={false}
  allowFileAccessFromFileURLs={false}
  mixedContentMode="never"
  onMessage={(event) => {
    // Only accept messages if origin is trusted
    if (event.nativeEvent.url.startsWith('https://example.com')) {
      handleMessage(event.nativeEvent.data);
    }
  }}
/>
```

#### Fix: Android manifest hardening

```xml
<!-- AndroidManifest.xml -->
<application
    android:usesCleartextTraffic="false"
    android:allowBackup="false"
    android:networkSecurityConfig="@xml/network_security_config">

    <activity
        android:name=".MainActivity"
        android:exported="false"
        android:windowSoftInputMode="adjustResize">

        <!-- Deep links: use verified App Links -->
        <intent-filter android:autoVerify="true">
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="https" android:host="app.example.com" />
        </intent-filter>
    </activity>
</application>
```

#### Fix: Remove debug logs in production

```ts
// At app entry point (index.ts)
if (!__DEV__) {
  global.console.log = () => {};
  global.console.warn = () => {};
  global.console.error = () => {};
  // Keep global.console.error for crash reporting if needed
}
```

---

## 9. Cloud & Infrastructure Security

```
Search:  Dockerfile, docker-compose, kubernetes, deploy, aws, gcp, azure, s3, bucket, iam, role, policy
```

### 9.1 Container Security (Docker / K8s)

- [ ] **Root user in container** — does `Dockerfile` use `USER nobody` or `USER 1000`? Running as root inside a container allows escape on container break-out.
- [ ] **Unpinned base images** — are base images pinned to a digest (`alpine:latest@sha256:...`) or a patch version? (`FROM node:18` vs `FROM node:18.17.1-slim`)
- [ ] **Secrets in Dockerfile** — are `ENV` or `ARG` directives used for secrets? (They persist in image layers.)
- [ ] **`.dockerignore` missing** — is there a `.dockerignore`? Without it, `.env` and secrets may be copied into the image.
- [ ] **K8s: Pod security context** — do pods have `runAsNonRoot: true`, `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem: true`?
- [ ] **K8s: RBAC over-permissive** — do service accounts have `cluster-admin` or wildcard resource access?
- [ ] **K8s: Secrets not encrypted** — are `Secrets` used without encryption at rest? (K8s Secrets are base64 only by default.)
- [ ] **K8s: No network policy** — is there a `NetworkPolicy` restricting pod-to-pod traffic? (Default is allow-all.)
- [ ] **K8s: Host network / host PID** — are pods using `hostNetwork: true` or `hostPID: true`? (Escapes container isolation.)

#### Fix: Secure Dockerfile

```dockerfile
FROM node:18-slim@sha256:abc123def456

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app
COPY --chown=appuser:appuser package*.json ./
RUN npm ci --only=production

COPY --chown=appuser:appuser . .
USER appuser

EXPOSE 3000
CMD ["node", "server.js"]
```

```dockerfile
# .dockerignore
.env
.env.local
node_modules
.git
*.md
tests/
```

#### Fix: K8s pod security context

```yaml
apiVersion: v1
kind: Pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
  containers:
    - name: app
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop: ["ALL"]
```

### 9.2 Cloud Provider Configuration

- [ ] **S3 bucket public access** — are there any S3 buckets with `public-read` or `public-read-write` ACLs? (Data exposure.)
- [ ] **S3 bucket block public access** — is `BlockPublicAccess` enabled at account or bucket level?
- [ ] **IAM wildcard policies** — do IAM policies use `"Effect": "Allow", "Action": "*"` or `"Resource": "*"` unnecessarily?
- [ ] **IAM keys not rotated** — are there IAM access keys older than 90 days?
- [ ] **Cloud storage bucket encryption** — is server-side encryption (SSE-S3, SSE-KMS) enabled on storage buckets?
- [ ] **Cloud function public invocation** — are cloud functions (AWS Lambda, GCP Cloud Functions) invocable without authentication?
- [ ] **Managed DB publicly accessible** — are RDS, Cloud SQL, or Cosmos DB instances publicly accessible with a password alone?
- [ ] **Security group / firewall rules** — are there security group rules with `0.0.0.0/0` for SSH (22), RDP (3389), or database ports?
- [ ] **TLS termination** — is TLS terminated at the load balancer with a valid certificate, or are backends handling raw HTTP?
- [ ] **CloudTrail / Audit Logs** — is CloudTrail (AWS), Audit Logs (GCP), or equivalent enabled for the account?
- [ ] **Default VPC** — is the default VPC in use with open egress? Should use a custom VPC with restricted egress.

#### Fix: S3 bucket hardening

```hcl
# Terraform: Block public access
resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.example.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM least privilege
resource "aws_iam_policy" "restricted" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:ListBucket"]
      Resource = ["arn:aws:s3:::example-bucket/*",
                  "arn:aws:s3:::example-bucket"]
      Condition = {
        IpAddress = { "aws:SourceIp" = ["203.0.113.0/24"] }
      }
    }]
  })
}
```

---

## 10. GraphQL Security

```
Search:  graphql, GraphQL, Apollo, graphql-yoga, strawberry, ariadne, type-graphql, @Resolver
```

- [ ] **Introspection enabled in production** — is `introspection: true` or `GraphiQL` enabled in production? (Exposes full schema, queries, mutations, and types.)
- [ ] **No query depth limiting** — can an attacker craft deeply nested queries? (e.g., `user → friends → user → friends → ...`) Crashes the server with exponential queries.
- [ ] **No query cost / complexity analysis** — is there no cost limit per query? Attackers can request thousands of nodes in a single request (DoS).
- [ ] **No rate limiting per operation** — is there a rate limiter that covers GraphQL endpoints? (Most rate limiters count HTTP requests, not query cost — a single request can contain an expensive query.)
- [ ] **Auth missing per resolver** — is authentication applied globally instead of per resolver/resource? (A user may access another user's data through a field resolver.)
- [ ] **Batching / alias attacks** — can an attacker use aliases to run the same expensive query hundreds of times in one request? (`query { a1: users, a2: users, ..., a100: users }`)
- [ ] **N+1 query exposure** — are resolvers making N+1 database calls without DataLoader? (Performance issue that can be exploited as DoS.)
- [ ] **Field-level access control** — are sensitive fields (e.g., `email`, `ssn`, `passwordHash`) exposable without field-level authorization?
- [ ] **Mutation logging** — are sensitive mutations (e.g., `deleteUser`, `updatePassword`) logged for audit?
- [ ] **CSRF via GraphQL** — is there CSRF protection on the GraphQL endpoint? (Most GraphQL endpoints accept `application/json` — not protected by standard CSRF tokens.)

#### Fix: Secure Apollo Server (Node.js)

```ts
import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@apollo/server/express4';
import depthLimit from 'graphql-depth-limit';
import costAnalysis from 'graphql-cost-analysis';

const server = new ApolloServer({
  typeDefs,
  resolvers,
  validationRules: [
    depthLimit(7),                          // max nesting depth
    costAnalysis({
      maximumCost: 1000,
      defaultCost: 1,
      costMap: {
        Query: { users: 5, search: 20 }    // weight complex queries
      }
    })
  ],
  introspection: process.env.NODE_ENV !== 'production',
});

// Per-resolver auth
const resolvers = {
  Query: {
    user: async (_, { id }, { dataSources, userId }) => {
      if (!userId) throw new AuthenticationError('Not logged in');
      const user = await dataSources.users.getById(id);
      if (user.id !== userId && !user.isAdmin(userId)) {
        throw new ForbiddenError('Not authorized');
      }
      return user;
    }
  }
};
```

#### Fix: GraphQL rate limiting

```ts
import { createRateLimitRule } from 'graphql-rate-limit';
import { shield } from 'graphql-shield';

const rateLimitRule = createRateLimitRule({
  identifyContext: (ctx) => ctx.ip
});

const permissions = shield({
  Query: {
    users: rateLimitRule({ window: '1s', max: 5 }),
    search: rateLimitRule({ window: '10s', max: 2 })
  },
  Mutation: {
    login: rateLimitRule({ window: '15m', max: 10 })
  }
});
```

---

## 11. WebSocket Security

```
Search:  WebSocket, websocket, ws://, wss://, io(), socket.io, WebSocketServer, on('connection')
```

- [ ] **No origin validation** — does the WebSocket server validate the `Origin` header on upgrade? (Without it, any website can open a socket to your server.)
- [ ] **No authentication on connect** — does the WebSocket handshake verify a token (JWT, session cookie) before accepting the connection?
- [ ] **No message validation** — are incoming messages parsed without schema validation? (An attacker can send malformed messages to crash the server or trigger injection.)
- [ ] **No rate limiting per connection** — is there a message rate limiter per WebSocket connection? (Unlimited messages = DoS.)
- [ ] **No disconnection on idle** — are connections kept open indefinitely? (Resource exhaustion — attackers can open thousands of connections.)
- [ ] **Replay attacks** — are messages idempotent or sequenced? (Without sequence numbers or monotonic IDs, an attacker can replay a "send money" message.)
- [ ] **No message size limit** — is there a maximum message size? (An attacker can send a single multi-GB message to crash the server.)
- [ ] **Broadcasting without authorization** — does the server broadcast messages to all connected clients without checking room/channel permissions?
- [ ] **TLS not enforced** — are WebSocket connections using `wss://` in production? (`ws://` sends all data in plaintext, including any auth tokens in the handshake.)
- [ ] **No subprotocol validation** — does the server accept any subprotocol without verification? (Can confuse the server's message parser.)

#### Fix: Secure WebSocket server (Node.js)

```ts
import { WebSocketServer } from 'ws';
import { verify } from 'jsonwebtoken';
import { rateLimit } from 'express-rate-limit';

const wss = new WebSocketServer({
  port: 8080,
  // Verify the origin
  verifyClient: (info, cb) => {
    const origin = info.origin || info.req.headers.origin;
    const allowedOrigins = ['https://app.example.com'];
    cb(allowedOrigins.includes(origin));
  },
  maxPayload: 1024 * 100  // 100KB max message
});

wss.on('connection', (ws, req) => {
  // 1. Authenticate on connect
  const token = new URL(req.url, 'http://localhost').searchParams.get('token');
  if (!token) { ws.close(4001, 'Authentication required'); return; }

  let user;
  try {
    user = verify(token, process.env.JWT_SECRET);
  } catch { ws.close(4001, 'Invalid token'); return; }

  // 2. Per-connection rate limiter
  const messageCounts = new Map();
  const rateLimitWindow = 60000; // 1 minute
  const maxMessages = 60;

  const interval = setInterval(() => messageCounts.clear(), rateLimitWindow);

  ws.on('message', (data) => {
    const count = (messageCounts.get(user.id) || 0) + 1;
    messageCounts.set(user.id, count);
    if (count > maxMessages) {
      ws.close(4002, 'Rate limit exceeded');
      clearInterval(interval);
      return;
    }

    // 3. Validate message schema
    try {
      const msg = JSON.parse(data.toString());
      if (!msg.type || !msg.payload) {
        ws.send(JSON.stringify({ error: 'Invalid message format' }));
        return;
      }
      handleMessage(user, msg);
    } catch {
      ws.send(JSON.stringify({ error: 'Invalid JSON' }));
    }
  });

  // 4. Idle timeout
  ws.isAlive = true;
  ws.on('pong', () => { ws.isAlive = true; });

  const pingInterval = setInterval(() => {
    if (!ws.isAlive) { ws.terminate(); clearInterval(pingInterval); return; }
    ws.isAlive = false;
    ws.ping();
  }, 30000);

  ws.on('close', () => {
    clearInterval(interval);
    clearInterval(pingInterval);
  });
});
```

---

## 12. File Upload Security

```
Search:  upload, file, multipart, multer, formidable, UploadFile, FileField, req.file, blob
```

- [ ] **File type validation by extension only** — is file type checked by extension (`file.endsWith('.pdf')`) instead of magic bytes? (An attacker can rename `malware.exe` to `resume.pdf`.)
- [ ] **No file size limit** — is there no maximum file size? (An attacker can upload a multi-GB file to fill your disk.)
- [ ] **No virus scanning** — are uploads scanned for malware? (Users can upload infected files that then spread through your system.)
- [ ] **Path traversal in filename** — is the original filename used without sanitization? (`../../../etc/passwd` can overwrite system files.)
- [ ] **Files stored in web root** — are uploads saved inside the web root (e.g., `public/uploads/`)? (Attacker can access uploaded files directly via URL.)
- [ ] **No CDN / cloud storage** — are files stored on the application server's local disk instead of S3/GCS/Azure Blob? (Local storage = disk full = DoS.)
- [ ] **Zip bombs** — are archive files (zip, tar, gz) scanned for decompression bombs? (A small zip can expand to petabytes, crashing the server.)
- [ ] **SVG / HTML upload XSS** — are SVGs or HTML files allowed? (SVGs can contain `<script>` tags, leading to stored XSS.)
- [ ] **Filename collision** — are uploaded filenames predictable? (Without UUIDs in filenames, one user can overwrite another user's file.)
- [ ] **Exif data leakage** — are uploaded images stripped of EXIF metadata? (EXIF can contain GPS coordinates, device info, and author names.)

#### Fix: Secure file upload (Node.js + Multer + S3)

```js
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const { fromBuffer } = require('file-type');

const ALLOWED_MIME_TYPES = [
  'image/jpeg', 'image/png', 'image/webp',
  'application/pdf',
  'text/plain'
];
const MAX_SIZE = 10 * 1024 * 1024; // 10MB

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: MAX_SIZE },
  fileFilter: (req, file, cb) => {
    // Reject by extension fast
    const ext = file.originalname.split('.').pop()?.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp', 'pdf', 'txt'].includes(ext)) {
      cb(new Error('Invalid file extension'), false);
      return;
    }
    cb(null, true);
  }
});

app.post('/upload', upload.single('file'), async (req, res) => {
  // Check magic bytes (not just extension)
  const type = await fromBuffer(req.file.buffer);
  if (!type || !ALLOWED_MIME_TYPES.includes(type.mime)) {
    return res.status(400).json({ error: 'Invalid file type' });
  }

  // Sanitize filename — never trust user input
  const safeName = `${uuidv4()}.${type.ext}`;

  // Stream directly to S3 (never local disk)
  const s3 = new S3Client({ region: 'us-east-1' });
  await s3.send(new PutObjectCommand({
    Bucket: 'uploads-bucket',
    Key: `uploads/${safeName}`,
    Body: req.file.buffer,
    ContentType: type.mime,
  }));

  // EXIF stripping — use sharp for images
  if (type.mime.startsWith('image/')) {
    const sharp = require('sharp');
    const cleaned = await sharp(req.file.buffer)
      .withMetadata({ exif: false });  // strip EXIF
    // re-upload without EXIF
    await s3.send(new PutObjectCommand({
      Bucket: 'uploads-bucket',
      Key: `uploads/${safeName}`,
      Body: await cleaned.toBuffer(),
      ContentType: type.mime,
    }));
  }

  res.json({ url: `https://cdn.example.com/uploads/${safeName}` });
});
```

#### Fix: Archive / zip bomb protection

```js
const yauzl = require('yauzl');
const MAX_UNCOMPRESSED_RATIO = 100; // 1:100 expansion max

function checkZipBomb(buffer) {
  return new Promise((resolve, reject) => {
    yauzl.fromBuffer(buffer, { lazyEntries: true }, (err, zipfile) => {
      if (err) return reject(err);
      let totalCompressed = 0;
      let totalUncompressed = 0;

      zipfile.readEntry();
      zipfile.on('entry', (entry) => {
        totalCompressed += entry.compressedSize;
        totalUncompressed += entry.uncompressedSize;
        if (totalUncompressed > totalCompressed * MAX_UNCOMPRESSED_RATIO) {
          return reject(new Error('Zip bomb detected'));
        }
        zipfile.readEntry();
      });
      zipfile.on('end', () => resolve(true));
    });
  });
}
```

---

## 13. Data Privacy & Compliance

```
Search:  pii, privacy, gdpr, ccpa, consent, cookie, personal, user data, email, phone, ssn, export, delete, retention
```

- [ ] **PII not classified** — is there no data classification layer marking fields as PII? (Without it, you can't audit or control PII exposure.)
- [ ] **Cookie consent missing** — is there a cookie consent banner for non-essential cookies? (GDPR requires opt-in for tracking cookies.)
- [ ] **No user data export** — can users export all their data? (GDPR "right of access" — must be provided within 30 days.)
- [ ] **No user deletion / right to be forgotten** — can users delete their account and all associated data?
- [ ] **Data retention policy missing** — are logs, backups, and user data kept indefinitely? (GDPR requires data minimization.)
- [ ] **PII in URLs** — are user identifiers (email, user ID) in URL query params? (`/profile?email=user@example.com` — leaked in server logs, referrer headers.)
- [ ] **PII in logs** — are emails, IPs, or names logged verbatim? (Logs are often sent to third-party services.)
- [ ] **Encryption at rest missing** — is the database unencrypted at rest?
- [ ] **Backups unencrypted** — are database backups stored without encryption?
- [ ] **Third-party data sharing** — is user data shared with third-party services without disclosure in the privacy policy?
- [ ] **Consent not recorded** — is user consent for data processing stored as evidence? (GDPR requires proof of consent.)
- [ ] **Password in plaintext** — are passwords stored in plaintext or reversible encryption? (Flat violation of every privacy regulation.)

#### Fix: PII data layer + data export/delete

```ts
// PII field annotation
const PII_FIELDS = ['email', 'phone', 'ssn', 'dob', 'fullName', 'ipAddress'];

function redactPII(obj: Record<string, any>): Record<string, any> {
  const copy = { ...obj };
  for (const key of Object.keys(copy)) {
    if (PII_FIELDS.includes(key)) {
      copy[key] = '[REDACTED]';
    }
  }
  return copy;
}

// Data export endpoint
app.get('/api/user/data-export', authenticate, async (req, res) => {
  const user = await User.findById(req.userId)
    .populate('orders')
    .populate('messages')
    .populate('activityLog');

  const exportData = {
    profile: user.profile,
    orders: user.orders,
    messages: user.messages.map(redactPII),
    consentRecords: user.consentRecords,
    generatedAt: new Date().toISOString()
  };

  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Content-Disposition', 'attachment; filename=user-data.json');
  res.json(exportData);
});

// Deletion endpoint
app.delete('/api/user', authenticate, async (req, res) => {
  const userId = req.userId;

  // Anonymize PII rather than delete if you need referential integrity
  await User.findByIdAndUpdate(userId, {
    $set: {
      email: `deleted-${userId}@example.com`,
      fullName: '[DELETED]',
      phone: null,
      profilePicture: null,
    },
    $unset: { passwordHash: '', ssn: '' }
  });

  // Delete dependent data
  await Promise.all([
    Session.deleteMany({ userId }),
    ActivityLog.deleteMany({ userId }),
    ConsentRecord.deleteMany({ userId }),
  ]);

  // Log the deletion
  console.log(`User ${userId} deleted at ${new Date().toISOString()}`);

  res.json({ message: 'Account deleted' });
});
```

---

## 14. Cryptography & Key Management

```
Search:  crypto, cipher, encrypt, decrypt, hash, createHash, createCipheriv, createDecipheriv, MD5, SHA1, RSA, AES, GCM, CBC, ECB
```

- [ ] **Weak hashing algorithm** — is MD5 or SHA-1 used for security contexts? (Password hashing, signatures, integrity checks.)
- [ ] **ECB mode encryption** — is AES-ECB used? (Deterministic — identical plaintext blocks produce identical ciphertext.)
- [ ] **Static IV / nonce** — is the IV for AES-CBC or nonce for AES-GCM static or reused? (Reused nonce destroys GCM security.)
- [ ] **No key rotation** — are encryption keys never rotated? (Compromise of a static key exposes all data ever encrypted.)
- [ ] **Keys in source code** — are encryption keys, certificates, or passwords in source files?
- [ ] **Weak RSA key size** — is RSA key size < 2048 bits?
- [ ] **Weak PRNG** — is `Math.random()` used instead of `crypto.randomBytes()` or `SecureRandom` for any security-sensitive operation?
- [ ] **Hardcoded certificates** — are TLS certificates and private keys in the repo or Docker image?
- [ ] **No PBKDF2 / bcrypt / argon2** — is a fast hash (SHA-256, MD5) used for password storage instead of a slow KDF?
- [ ] **JWT algorithm confusion** — is the server vulnerable to algorithm confusion? (Accepting both symmetric `HS256` and asymmetric `RS256` tokens with the same secret.)
- [ ] **Legacy protocols** — is SSLv3, TLS 1.0, or TLS 1.1 allowed?
- [ ] **Self-signed certificates in production** — are self-signed certs used instead of a trusted CA?

#### Fix: Modern crypto practices

```js
// ✅ BCRYPT for passwords
const bcrypt = require('bcrypt');
const hash = await bcrypt.hash(password, 12);  // cost factor 12

// ✅ AES-256-GCM with random IV
const crypto = require('crypto');
function encrypt(text, key) {
  const iv = crypto.randomBytes(16);     // NEVER reuse IV
  const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);
  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  const authTag = cipher.getAuthTag().toString('hex');
  return { encrypted, iv: iv.toString('hex'), authTag };
}

// ✅ Key rotation support
const keyRing = [
  { id: 'v2', key: process.env.ENCRYPTION_KEY_V2, active: true },
  { id: 'v1', key: process.env.ENCRYPTION_KEY_V1, active: false },
];

function encryptWithKeyRing(text) {
  const active = keyRing.find(k => k.active);
  const { encrypted, iv, authTag } = encrypt(text, active.key);
  return `{key:${active.id},iv:${iv},tag:${authTag}}${encrypted}`;
}

function decryptFromKeyRing(encoded) {
  const match = encoded.match(/^\{key:(\w+),iv:(\w+),tag:(\w+)\}(.+)$/);
  if (!match) throw new Error('Invalid format');
  const [_, keyId, iv, authTag, encrypted] = match;
  const keyEntry = keyRing.find(k => k.id === keyId);
  if (!keyEntry) throw new Error('Unknown key ID');
  const decipher = crypto.createDecipheriv('aes-256-gcm', keyEntry.key, Buffer.from(iv, 'hex'));
  decipher.setAuthTag(Buffer.from(authTag, 'hex'));
  let decrypted = decipher.update(encrypted, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  return decrypted;
}
```

---

## 15. CI/CD & Supply Chain Security

```
Search:  .github/workflows, .gitlab-ci.yml, Jenkinsfile, Dockerfile, Makefile, npm install, pip install, go get
```

- [ ] **Secrets in CI logs** — are secrets (env vars, keys) printed in CI output or available to forked PRs? (GitHub: are secrets masked in logs? GitLab: are protected variables used?)
- [ ] **No dependency lock files** — is there no `package-lock.json`, `yarn.lock`, `requirements.txt` with pinned hashes? (Without locks, builds are non-deterministic — a compromised dependency version can be pushed without notice.)
- [ ] **Subresource Integrity (SRI) missing** — are CDN-loaded scripts missing integrity hashes? (`<script src="https://cdn.example.com/lib.js">` without `integrity="sha384-..."`.)
- [ ] **Dependency confusion** — does the package manager combine public and private registries without scoping? (`@scope/package` vs unscoped private packages that match public package names.)
- [ ] **Typosquatting risk** — are there any dependencies that are typo-squats of popular packages? (e.g., `cors` instead of `cors`, `bcrypt` instead of `bcryptjs`.)
- [ ] **Unsigned commits** — are commits signed with GPG or SSH? (Unsigned commits can be authored by anyone.)
- [ ] **No SBOM** — is there no Software Bill of Materials generated? (Without it, you can't audit third-party vulnerabilities comprehensively.)
- [ ] **CI pipeline self-modification** — can the CI pipeline (e.g., `.github/workflows/`) be modified by a PR before it runs? (Token theft — a PR can modify CI to exfiltrate secrets.)
- [ ] **Artifact integrity / signing** — are build artifacts signed and checksummed? (Without it, artifacts can be replaced between build and deploy.)
- [ ] **No least privilege CI** — do CI workflows use tokens with more permissions than needed? (e.g., `contents: write` on a PR workflow that only needs `contents: read`.)
- [ ] **No container image scanning** — are Docker images scanned for vulnerabilities before deployment?

#### Fix: Secure CI pipeline (GitHub Actions)

```yaml
name: CI/CD Pipeline
on: [pull_request]

# Least-privilege permissions
permissions:
  contents: read
  checks: write
  pull-requests: read

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Dependency lockfile check
      - name: Verify lockfile
        run: |
          if [ ! -f package-lock.json ] && [ ! -f yarn.lock ]; then
            echo "No lockfile found — builds are non-deterministic!"
            exit 1
          fi

      # Dependency audit
      - name: Audit
        run: npm audit --audit-level=high

      # SAST
      - name: Semgrep
        uses: semgrep/semgrep-action@v1
        with:
          config: p/default

      # Secrets scan
      - name: Gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      # SBOM
      - name: Generate SBOM
        uses: cyclonedx/gha-generate-sbom@v1
```

#### Fix: Dependency confusion protection

```bash
# npm: scope all private packages
npm init --scope=@mycompany

# .npmrc
@mycompany:registry=https://npm.mycompany.com
registry=https://registry.npmjs.org/

# pip: index-url isolation
# requirements.txt with hashes
pip install --require-hashes -r requirements.txt

# Docker: pin base images by digest
FROM node:18-slim@sha256:abc123def456...
```

---

## 16. Logging & Monitoring Security

```
Search:  log, logger, debug, info, warn, error, audit, auditLog, activityLog, winston, pino, log4j, sentry, datadog
```

- [ ] **Log injection** — are log messages constructed with user input without sanitization? (Log4j CVE-2021-44228-style — an attacker can inject `${env:AWS_SECRET_KEY}` into a log message and exfiltrate secrets via the logging framework.)
- [ ] **PII in logs** — are emails, IPs, passwords, or request/response bodies logged verbatim? (GDPR violation — logs become a data breach liability.)
- [ ] **No audit trail** — are sensitive operations (user deletion, role changes, payment actions) not logged?
- [ ] **No alerting** — are there no alerts for: repeated 401/403 errors, unusual traffic spikes, logins from new geographies?
- [ ] **Logs stored indefinitely** — are logs kept without a retention policy? (Storage cost + data breach liability.)
- [ ] **Sensitive data in error reports** — do error reporting services (Sentry, DataDog, Rollbar) capture request bodies or environment variables?
- [ ] **No structured logging** — are logs unstructured strings (harder to search, SIEM can't parse them)?
- [ ] **Centralized logging without auth** — is the log aggregation service (Kibana, Grafana Loki) accessible without authentication?
- [ ] **No monitoring for known attack patterns** — is there no WAF or IDS/IPS monitoring for SQLi, XSS, path traversal patterns?
- [ ] **Health check endpoints leak info** — do `/health`, `/ready`, or `/metrics` endpoints expose internal state, versions, or configuration?

#### Fix: Secure logging (Winston)

```js
const winston = require('winston');

const PII_PATTERNS = [
  /\b[\w\.-]+@[\w\.-]+\.\w{2,}\b/g,  // email
  /\b\d{3}-\d{2}-\d{4}\b/g,          // SSN
  /\b(?:\d{4}[ -]?){4}\b/g,          // credit card
];

function sanitize(data) {
  let str = typeof data === 'string' ? data : JSON.stringify(data);
  for (const pattern of PII_PATTERNS) {
    str = str.replace(pattern, '[REDACTED]');
  }
  return str;
}

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json(),
    winston.format((info) => {
      // Never log request bodies on auth routes
      if (info.req?.url?.includes('/login') || info.req?.url?.includes('/reset')) {
        delete info.req.body;
      }
      // Sanitize any PII in the message
      info.message = sanitize(info.message);
      return info;
    })()
  ),
  transports: [
    new winston.transports.File({
      filename: 'logs/audit.log',
      maxsize: 10 * 1024 * 1024, // 10MB per file
      maxFiles: 10,               // keep 10 rotated files
    })
  ]
});

// Audit log middleware
function auditLog(req, res, next) {
  const start = Date.now();
  res.on('finish', () => {
    if (res.statusCode >= 400) {
      logger.warn({
        event: 'request',
        method: req.method,
        path: req.path,
        status: res.statusCode,
        duration: Date.now() - start,
        ip: req.ip,
        userId: req.user?.id || 'anonymous'
      });
    }
  });
  next();
}
```

#### Fix: Log injection prevention

```js
// 🚫 BAD: direct interpolation
logger.info(`User ${req.body.email} logged in`);

// ✅ GOOD: structured fields
logger.info('User login', {
  event: 'login',
  userId: user.id,
  ip: req.ip,
  timestamp: new Date().toISOString()
});

// ✅ GOOD: sanitize user input if you must include it
logger.info(`Failed login for ${sanitize(req.body.email)}`);
```

---

## 1. Authentication & Session Management

### 1.1 Login Endpoint

```
Search:  /login, /signin, /auth, authenticate, passport.authenticate
```

- [ ] **Rate limiting** — is there a rate limiter on the login route? (express-rate-limit, flask-limiter, django-ratelimit, etc.)
- [ ] **Account lockout** — are failed attempts tracked? Is there a lockout threshold + cooldown?
- [ ] **Brute-force protection** — exponential backoff, CAPTCHA after N failures, or similar.
- [ ] **Credential logging** — are passwords or raw credentials ever logged?
- [ ] **Password comparison** — is a constant-time comparison used? (`crypto.timingSafeEqual`, `bcrypt.compare`, `hash_equals`, etc.)
- [ ] **Error messages** — do login failures reveal whether the *email* or *password* was wrong? (must be generic: "Invalid credentials".)
- [ ] **Remember-me / persistent sessions** — if present, is the token securely generated and stored?
- [ ] **Username/email enumeration** — is the response identical in timing and content for existing vs non-existing accounts?

### 1.2 Session / Token Management

```
Search:  jwt, session, cookie, token, passport, express-session, connect-redis
```

- [ ] **JWT secret** — at least 256-bit (32+ random chars / env var)? Never hardcoded?
- [ ] **JWT expiration** — short `exp` claim (< 24h for access tokens)? Refresh tokens rotated?
- [ ] **JWT algorithm** — pinned to `RS256` or `HS256`? `alg` header verified against an allowlist? (CVE-2015-9235 — "none" algorithm.)
- [ ] **Session store** — server-side (Redis, DB)? `httpOnly`, `secure`, `sameSite` set on cookies?
- [ ] **Logout** — does logout invalidate the session/token server-side (not just client redirect)?
- [ ] **CSRF** — CSRF protection on state-changing endpoints? (csurf, double-submit cookie, SameSite=Strict/Lax.)
- [ ] **MFA / 2FA** — available? TOTP secret stored encrypted?

### 1.3 OAuth / Social Login

```
Search:  passport-google, passport-github, oauth, OAuth2Strategy, /auth/callback
```

- [ ] **State parameter** — cryptographically random `state` parameter used and verified in callback?
- [ ] **Redirect URI validation** — are redirect URIs whitelisted strictly?
- [ ] **Token leakage** — are access/refresh tokens from the provider ever logged or sent to the client?
- [ ] **Account linking** — if merging OAuth + email accounts, is there a verification step to prevent account takeover?
- [ ] **PKCE** — is PKCE (Proof Key for Code Exchange) used for public clients (mobile, SPA)? (Without PKCE, the authorization code can be intercepted.)

### 1.4 Magic Links & Email Login Links

```
Search:  magic-link, magiclink, sendSignInLink, signInWithEmailLink, actionHandler, verify, /verify-email, /confirm
```

- [ ] **Token generation** — is the magic link token generated with `crypto.randomBytes` (≥ 32 bytes)? Not `Math.random()`, `Date.now()`, `uuid.v4()` alone?
- [ ] **Single-use** — is the link invalidated immediately after a successful login?
- [ ] **Expiry** — does the link expire in ≤ 15 minutes? (Magic links should be shorter-lived than password resets.)
- [ ] **Rate limiting** — is the "send magic link" endpoint rate-limited per email and per IP?
- [ ] **Enumeration protection** — does the endpoint return the same response whether or not the email exists?
- [ ] **Link injection in email body** — are magic link URLs properly escaped in email templates?
- [ ] **Deep-link hijacking** — are magic links restricted to the intended mobile app (Android App Links / iOS Universal Links) or does a custom URL scheme allow any app to intercept?
- [ ] **Replay prevention** — is the token checked against a server-side store, not just self-encoded in the JWT?
- [ ] **Cross-account reuse** — can user A use user B's magic link by modifying the email in the URL? (The token must be bound to the specific email/account.)

### 1.5 Login Timing Attack Protection

```
Search:  timingSafeEqual, constant-time, randomDelay, setTimeout(Math.random), bcrypt.compare, hash_equals, compareSync
```

- [ ] **Password comparison** — is a constant-time string comparison used? (`crypto.timingSafeEqual` in Node, `hash_equals` in PHP, `hmac.compare_digest` in Python, `MessageDigest.isEqual` in Java.)
  - *Note:* `bcrypt.compare()` / `argon2.verify()` are inherently constant-time.
- [ ] **User existence check** — when authenticating, is the user lookup followed by a constant-time credential comparison even if the user does not exist?
- [ ] **Forgot-password timing** — does the forgot-password endpoint use a constant-time lookup, or does it return immediately when the email is not found?
- [ ] **Random keystroke delay** — does the login endpoint add a stochastic delay (`setTimeout(() => next(), 50 + Math.random() * 150)`)?
- [ ] **Response padding** — is the response body padded to a fixed length?
- [ ] **Login link timing** — does the magic-link / reset-link endpoint always sleep a minimum amount of time?

#### Fix: Add random delay to login endpoint

```js
function timingSafeLogin(handler) {
  return async (req, res, next) => {
    const delay = 50 + Math.random() * 150; // 50–200ms jitter
    await new Promise(r => setTimeout(r, delay));
    return handler(req, res, next);
  };
}
app.post('/login', rateLimiter, timingSafeLogin(loginHandler));
```

#### Fix: Constant-time comparison (Node.js)

```js
// 🚫 BAD:
if (user.password === inputPassword) { ... }

// ✅ GOOD:
if (crypto.timingSafeEqual(
  Buffer.from(user.password),
  Buffer.from(inputPassword)
)) { ... }
```

---

## 2. Password Reset Flow

```
Search:  reset, forgot-password, forgot_password, /reset-password, /forgot-password, token, resetToken
```

### 2.1 Token Generation

```
Search:  crypto.randomBytes, uuid, nanoid, token, secret, resetToken
```

- [ ] **Cryptographic randomness** — generated with `crypto.randomBytes` (or equivalent)? **Not** `Math.random()`, `Date.now()`, `uuid()` alone.
- [ ] **Token length** — ≥ 128 bits (≥ 16 bytes / ≥ 32 hex chars)?
- [ ] **Token encoding** — URL-safe (base64url, hex)?

#### Fix: Secure token generation

```js
const crypto = require('crypto');
const token = crypto.randomBytes(32).toString('hex');
```

### 2.2 Token Storage & Expiry

```
Search:  save, store, update, expiresIn, expiresAt, createdAt, tokenHash, bcrypt
```

- [ ] **Hashed in DB** — stored as a *hash* (sha256, bcrypt), not plaintext?
- [ ] **Expiry** — expires in ≤ 1 hour? Enforced server-side?
- [ ] **Single-use** — invalidated immediately after successful password change?
- [ ] **Invalidation on demand** — can a user invalidate all outstanding tokens by requesting a new one?

#### Fix: Hash token before storage

```js
const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
db.resetTokens.insertOne({ tokenHash, userId, expiresAt });
```

### 2.3 Enumeration Protection

- [ ] **Response consistency** — same status + body whether email exists or not?
- [ ] **Timing** — constant-time user lookup?
- [ ] **Rate limiting** — rate-limited per IP and/or per email?

#### Fix: Generic response + random delay

```js
app.post('/forgot-password', async (req, res) => {
  res.status(200).json({ message: 'If that email exists, a reset link has been sent.' });
  const delay = 100 + Math.random() * 200;
  setTimeout(async () => {
    const user = await User.findOne({ email: req.body.email });
    if (user) {
      const token = crypto.randomBytes(32).toString('hex');
      await sendResetEmail(email, token);
    }
  }, delay);
});
```

### 2.4 Password Strength

```
Search:  password.length, minLength, validate, strength, zxcvbn, validator
```

- [ ] **Minimum length** — ≥ 8 characters (recommended ≥ 12)?
- [ ] **Strength check** — zxcvbn, haveibeenpwned API, or similar?
- [ ] **Confirmation** — two matching fields required?
- [ ] **Hashing** — hashed with bcrypt (≥ 10 rounds) or argon2?

---

## 3. Connector Security

```
Search:  connector, webhook, apiKey, api_key, API_KEY, secretKey, clientSecret, database, mongoose, redis, stripe, sendgrid, twilio, slack, discord, webhookUrl
```

### 3.1 API Keys & Secrets

- [ ] **Environment variables** — all API keys, secrets, tokens from env vars?
- [ ] **Hardcoded keys** — any keys in source files? (Also check mobile: `.env` files in React Native, `pubspec.yaml` env vars.)
- [ ] **`.env` files** — is `.env` in `.gitignore`? Any `.env` files committed?
- [ ] **Key rotation** — mechanism to rotate keys without downtime?
- [ ] **Least privilege** — keys have minimum necessary scopes?
- [ ] **Mobile: Client-side secrets** — are API keys that MUST be secret present in mobile app code? (Mobile apps cannot hide secrets — they must use a BFF / proxy layer.)

### 3.2 Webhooks

```
Search:  webhook, /webhook, stripe.webhooks, signature, secret
```

- [ ] **Signature verification** — payload signature verified (Stripe `constructEvent`, GitHub HMAC, etc.)?
- [ ] **Secret** — webhook signing secret stored securely (env var)?
- [ ] **Replay protection** — timestamp + tolerance window?
- [ ] **Idempotency** — handlers idempotent (process each event exactly once)?

#### Fix: Webhook signature verification (Node.js)

```js
app.post('/stripe-webhook', (req, res) => {
  const sig = req.headers['stripe-signature'];
  const event = stripe.webhooks.constructEvent(
    req.body, sig, process.env.STRIPE_WEBHOOK_SECRET
  );
});
```

### 3.3 Database Connections

```
Search:  mongoose.connect, createConnection, Pool, sequelize, prisma, typeorm, redis.createClient
```

- [ ] **Connection string** — in env var? Contains credentials? Ever logged?
- [ ] **SSL/TLS** — TLS in production?
- [ ] **Query injection** — raw queries parameterized? Any `$where`, `$eval`, raw SQL fragments?
- [ ] **Connection pool** — pool size appropriate?

### 3.4 Third-party SDKs

```
Search:  stripe, sendgrid, twilio, openai, aws-sdk, @aws-sdk, google-cloud, firebase
```

- [ ] **Error handling** — errors caught and sanitized (no raw error objects to client)?
- [ ] **Secret exposure** — secrets from env vars, scoped correctly?

---

## 4. API & Input Handling

### 4.1 Injection Attacks

```
Search:  exec, eval, $where, $eval, dangerouslySetInnerHTML, innerHTML, serialize, JSON.parse, eval(), Function(, child_process
```

- [ ] **SQL/NoSQL injection** — all queries parameterized or using ORM with safe defaults? Watch `$where` in MongoDB, raw SQL in `query()`, template strings in queries.
- [ ] **Command injection** — `child_process.exec` / `subprocess.run(shell=True)` / `os.system` with user input?
- [ ] **SSRF** — does the app fetch URLs based on user input? Host allowlist?
- [ ] **XXE** — XML parsing with external entities disabled?
- [ ] **Template injection (SSTI)** — is `render_template_string` (Flask/Jinja2), `render inline:` (Rails), or `{!! !!}` (Blade) used with user input?

#### Fix: Parameterized queries

```js
// 🚫 BAD:
db.query(`SELECT * FROM users WHERE id = '${req.params.id}'`);
// ✅ GOOD:
db.query('SELECT * FROM users WHERE id = $1', [req.params.id]);
```

### 4.2 Input Validation

```
Search:  body, req.body, request.body, params, query, validator, Joi, zod, yup, express-validator, class-validator
```

- [ ] **Schema validation** — all inputs validated against a schema (Joi, Zod, Yup, Pydantic, etc.)?
- [ ] **Type coercion** — input types enforced (string, number, boolean)?
- [ ] **Allowlist approach** — deny-by-default (allowlist) rather than blocklist?
- [ ] **File uploads** — file type via magic bytes, size limit, virus scan? Stored outside web root?

### 4.3 CORS

- [ ] **Restrictive origin** — specific origin allowlist, not `*` in production?
- [ ] **Credentials** — if `credentials: true`, origins explicitly listed?
- [ ] **Pre-flight** — `OPTIONS` requests handled correctly?

### 4.4 Rate Limiting

```
Search:  rate-limit, RateLimiter, rateLimit, limiter, express-rate-limit, flask-limiter, throttle
```

- [ ] **Global limiter** — global rate limiter in place?
- [ ] **Per-route** — sensitive routes (login, register, reset-password, API) individually limited?
- [ ] **Per-IP** — rate limiting per-IP (or per-user for authenticated routes)?

### 4.5 HTTP Security Headers

```
Search:  helmet, security-headers, Content-Security-Policy, Strict-Transport-Security, X-Frame-Options, X-Content-Type-Options
```

- [ ] **Helmet / equivalent** — Helmet (Node), Talisman (Flask), Django SecurityMiddleware, or equivalent applied?
- [ ] **CSP** — Content-Security-Policy header set?
- [ ] **HSTS** — `Strict-Transport-Security` set for production?
- [ ] **X-Frame-Options** — clickjacking protection (`DENY` or `SAMEORIGIN`)?
- [ ] **X-Content-Type-Options** — `nosniff` set?

---

## 5. Secrets & Configuration

### 5.1 Env File Exposure

```
Search:  .env, .env.example, .env.local, .env.production, google-services.json, GoogleService-Info.plist
```

- [ ] **Gitignore** — is `.env` in `.gitignore`? Any `.env*` files committed?
- [ ] **Example env** — does `.env.example` exist with placeholder values (no real secrets)?
- [ ] **Fallback defaults** — hardcoded fallback defaults for secrets?
- [ ] **Mobile config files** — are `google-services.json`, `GoogleService-Info.plist`, or Firebase configs committed with unrestricted API keys?

### 5.2 Secrets in Source

```
Search:  secret, password, passwd, pwd, token, apiKey, api_key, private_key, privateKey, -----BEGIN
```

- [ ] **Hardcoded secrets** — regex for `['\"][A-Za-z0-9_\-]{32,}['\"]` and `-----BEGIN.*PRIVATE KEY-----`.
- [ ] **Comments** — secrets in code comments or TODO strings?
- [ ] **Commit history** — scan `.git/config` and recent commits (read-only — flag, don't rewrite).

### 5.3 Logging

```
Search:  console.log, logger.info, logger.debug, log.debug, log.info, debugPrint, print(
```

- [ ] **Credential logging** — request bodies logged on auth routes?
- [ ] **Token logging** — JWT tokens, reset tokens, or session IDs logged?
- [ ] **Error detail** — error responses include stack traces, DB dumps, or internal paths?

#### Fix: Sanitize error responses

```js
app.use((err, req, res, next) => {
  console.error(err.stack);  // log server-side only
  res.status(500).json({ error: 'Internal server error' });
});
```

---

## 6. Dependencies & Infrastructure

### 6.1 Outdated Packages

```
Search:  package.json, requirements.txt, go.mod, Cargo.toml, Gemfile, composer.json, pubspec.yaml
```

- [ ] **Known vulnerabilities** — would `npm audit`, `pip audit`, `go audit`, `mvn dependency-check`, `composer audit`, `flutter pub outdated` surface critical vulns?
- [ ] **Deprecated packages** — any dependencies unmaintained or deprecated?
- [ ] **Unnecessary packages** — dev/test packages in production deps?

### 6.2 Transport Security

- [ ] **HTTPS enforcement** — HTTP → HTTPS redirect?
- [ ] **TLS version** — TLS 1.2+ enforced (not SSLv3, TLS 1.0, TLS 1.1)?

### 6.3 Error Handling

- [ ] **Global error handler** — prevents stack traces reaching client?
- [ ] **Catch-all 404** — prevents path enumeration?
- [ ] **Unhandled rejections** — `process.on('unhandledRejection')` or equivalent?

---

## Interactive Fix Workflow

### Mode 2 — Interactive

```
For each finding:

  ┌─────────────────────────────────────────────────────────────┐
  │ [C-1] Flutter API key hardcoded in Dart source              │
  │ File: lib/services/api.dart:8                                │
  │ Severity: 🔴 Critical                                       │
  │                                                              │
  │   final apiKey = 'AIzaSy...';                               │
  │                                                              │
  │ Fix: Move to .env + flutter_dotenv                          │
  │                                                              │
  │ Fix this? (y/n/skip-all/skip-severity)                       │
  └─────────────────────────────────────────────────────────────┘

  - y          → apply fix immediately
  - n          → skip, document in report
  - skip-all   → skip all remaining (proceed to report)
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

Generate `report.md` after the audit/fix session:

```markdown
# Security Audit Report — `<Project Name>`

**Audit date:** YYYY-MM-DD  
**Mode:** Report only / Interactive fix / Auto-fix all  
**Framework(s) detected:** Node.js/Express + Flutter (example)  
**Scope:** Full stack — backend, mobile, cloud, infra (16 domains)  
**Method:** Static code analysis (no runtime testing)

---

## Executive Summary

| Severity | Count | Fixed | Domain examples |
|----------|-------|-------|-----------------|
| 🔴 Critical | N | N | SQLi, hardcoded secrets, weak crypto, S3 exposure, zip bombs |
| 🟠 High | N | N | Missing rate limiting, GraphQL depth, WebSocket auth, log injection |
| 🟡 Medium | N | N | No CSRF, no CSP, no file upload validation, no audit trail |
| 🔵 Low | N | N | No HSTS, no MFA, unsigned commits, long timeout |

---

## Critical Findings

### [C-1] Title
- **File:** `path/to/file.ts:42`
- **Domain:** API & Input Handling / Cloud / Mobile / ...
- **Status:** 🔴 Unfixed / ✅ Fixed
- **Description:** What the issue is.
- **Impact:** What an attacker can do.
- **Evidence:** The vulnerable code snippet (before fix).
- **Fix applied (if any):** The fixed code snippet.
```

---

## Severity Rubric

| Severity | Label | Definition | SLA |
|----------|-------|------------|-----|
| 🔴 **Critical** | Must fix | Direct, exploitable vulnerability (RCE, SQLi, account takeover, secrets leak). | < 24 hours |
| 🟠 **High** | Should fix | Exploitable under realistic conditions (SSRF, weak crypto, missing rate limiting, timing leaks). | Current sprint |
| 🟡 **Medium** | Good to fix | Weakens security posture (missing CSP, verbose errors, no CSRF). | Next sprint |
| 🔵 **Low** | Nice to fix | Best-practice deviation (no HSTS, no MFA, session timeout too long). | When convenient |
| ⚪ **Info** | Note | Observation, architecture choice. | — |

---

## Meta-Instructions

1. **Detect first** — auto-detect all frameworks before running checks. Run checks for every detected framework.
2. **Mode first** — Always ask the user which mode before doing anything.
3. **Do not change code in report-only mode.** Read-only. No exceptions.
4. **Be thorough.** If unsure, flag with lower severity and a note.
5. **Cite file:line** for every finding (`path/file.ext:123`).
6. **Include evidence** — show the vulnerable snippet in the report.
7. **Prioritize accuracy over speed.** Triple-check before reporting.
8. **Ignore generated/test dirs** unless they contain production config.
9. **Absence is a finding.** If a protection is missing, state: "No rate limiter found."
10. **Fix responsibly** — `read` the file first, then `edit` with precise oldString/newString. Never overwrite a file without reading it.
11. **Track fixes** — after each fix, verify the change is correct by reading the modified lines.
12. **Mobile sensitivity** — for Flutter/React Native, prioritize: (1) API keys in source, (2) insecure local storage, (3) missing SSL pinning, (4) deep link hijacking.
13. **16 domains** — run ALL applicable sections (1–16). Skip sections only if framework detection confirms the technology is not used.
14. **Cloud/config awareness** — for cloud checks (section 9), flag missing IaC (Terraform, CloudFormation) as informational — but flag hardcoded cloud secrets as critical.
15. **Supply chain checks** — always check for lockfiles and dependency confusion, even if CI/CD config is absent.
16. **Crypto audit** — when reviewing encryption code (section 14), test-verify: does the mode use an IV? Is it random? Is the key rotatable?

---

## Quick Reference: Fix by Severity

| Severity | Fix this first |
|----------|----------------|
| 🔴 Critical | Hardcoded secrets, SQL injection, command injection, weak reset tokens, JWT alg=none, ECB mode crypto, no SSL pinning, zip bombs, exposed S3 buckets, no WebSocket auth |
| 🟠 High | Missing rate limiting, plaintext reset tokens, wildcard CORS, missing webhook verification, no CSP, Log4j-style injection, no GraphQL depth limiting, cookie consent missing |
| 🟡 Medium | Missing CSRF, stack trace leaks, no HSTS, no file upload validation, no data retention policy, no audit trail, CI/CD secrets in logs |
| 🔵 Low | No account lockout, long session timeout, no MFA, no SBOM, unsigned commits, no EXIF stripping |
