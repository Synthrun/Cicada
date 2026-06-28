# 🔐 Security Audit Report — Synthrun Mail

<div align="center">

**Audit date:** 2026-06-29  
**Audit mode:** Report only  
**Framework(s) detected:** Node.js/Express, Firebase Auth, Cloudflare Workers  
**Domains checked:** 16 / 16  
**Method:** Static code analysis (no runtime testing)  

</div>

---

## 📋 Executive Summary

| Severity | Count | Fixed | Notable examples |
|----------|-------|-------|-----------------|
| 🔴 **Critical** | 4 | 0 | Firebase admin key, SMTP password, Brevo API key, Telegram token on disk |
| 🟠 **High** | 2 | 0 | Debug auth bypass, client-side TOTP |
| 🟡 **Medium** | 4 | 0 | Unauthenticated file downloads, no rate limiting, shared tokens |
| 🔵 **Low** | 4 | 0 | CORS wildcard, no CSRF, wrangler cache tracked, large body limit |

---

## 🔴 Critical Findings

### [C-1] Firebase Admin SDK private key on disk

| Field | Value |
|-------|-------|
| **File** | `synthrun-site-firebase-adminsdk-fbsvc-75da2cfca3.json` |
| **Domain** | Secrets & Configuration |
| **Status** | 🔴 Unfixed |
| **CWE** | CWE-312 — Cleartext Storage of Sensitive Information |
| **Description** | Full RSA private key (`-----BEGIN PRIVATE KEY-----`) stored in the repo root with unrestricted Firestore/Auth admin access. |
| **Impact** | Any attacker with repo access (or who finds this file in a public artifact) gains full admin control of Firebase — read/write all Firestore data, create auth users, impersonate anyone. |
| **Evidence** | `-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----` |
| **Recommendation** | Revoke this key immediately in **Google Cloud Console > IAM & Admin > Service Accounts > Keys**. Remove the file from the repo. Load via `FIREBASE_PRIVATE_KEY` env var using Render secrets. |

---

### [C-2] SMTP password exposed on disk

| Field | Value |
|-------|-------|
| **File** | `.env` |
| **Domain** | Secrets & Configuration |
| **Status** | 🔴 Unfixed |
| **CWE** | CWE-312 — Cleartext Storage of Sensitive Information |
| **Description** | `SMTP_PASS=xsmtpsib-...` — active Brevo SMTP relay password. |
| **Impact** | Attacker can send unlimited emails as your domain (phishing, spam, reputation damage). |
| **Recommendation** | Rotate immediately in Brevo dashboard. Remove from `.env` file. Store as Render secret. |

---

### [C-3] Brevo API key exposed on disk

| Field | Value |
|-------|-------|
| **File** | `.env` |
| **Domain** | Secrets & Configuration |
| **Status** | 🔴 Unfixed |
| **CWE** | CWE-312 |
| **Description** | `BREVO_API_KEY=xkeysib-...` — full API access to Brevo account (email, contacts, campaigns). |
| **Impact** | Full Brevo account takeover — can send, read all emails, access contact lists, modify templates. |
| **Recommendation** | Rotate immediately in Brevo dashboard. |

---

### [C-4] Telegram bot token exposed on disk

| Field | Value |
|-------|-------|
| **File** | `.env` |
| **Domain** | Secrets & Configuration |
| **Status** | 🔴 Unfixed |
| **CWE** | CWE-312 |
| **Description** | `TELEGRAM_BOT_TOKEN=8937654458:AAFu...` — full control of Telegram bot used for file storage. |
| **Impact** | Attacker can send messages as the bot, access chat history, and use the bot's file storage. |
| **Recommendation** | Revoke via BotFather on Telegram and rotate token. |

---

## 🟠 High Findings

### [H-1] `ALLOWED_BYPASS` debug auth bypass

| Field | Value |
|-------|-------|
| **File** | `render-server.js:237-239` |
| **Domain** | Auth & Session Management |
| **Status** | 🟠 Unfixed |
| **CWE** | CWE-287 — Improper Authentication |
| **Description** | When `ALLOWED_BYPASS=1`, any request with `X-Debug-User` header bypasses Firebase auth entirely. A production failsafe exists (refuses to start with `ALLOWED_BYPASS=1` in production), but misconfiguration risk remains. |
| **Impact** | If accidentally enabled in production, anyone can impersonate any user by setting a header. |
| **Recommendation** | Remove the bypass code entirely or gate behind a compile-time flag that cannot be toggled at runtime. |

---

### [H-2] Custom client-side TOTP (not Firebase MFA)

| Field | Value |
|-------|-------|
| **File** | `login/index.html:377-419` |
| **Domain** | Auth & Session Management |
| **Status** | 🟠 Unfixed |
| **CWE** | CWE-602 — Client-Side Enforcement of Server-Side Security |
| **Description** | TOTP secret stored in Firestore (`user_settings.totpSecret`) and downloaded to browser. Entire 2FA verification happens client-side in JavaScript. |
| **Impact** | Anyone who can read Firestore (via an XSS or network interception) gets the TOTP secret. A compromised client can skip 2FA entirely. |
| **Recommendation** | Replace with **Firebase Multi-Factor Authentication** for server-enforced 2FA. This keeps the TOTP secret server-side. |

---

## 🟡 Medium Findings

### [M-1] No auth on `/attachment/:fileId`

| Field | Value |
|-------|-------|
| **File** | `render-server.js:465` |
| **Domain** | API & Input Handling |
| **Status** | 🟡 Unfixed |
| **CWE** | CWE-306 — Missing Authentication |
| **Description** | Anyone with a file ID can download any attachment. No auth check. |
| **Recommendation** | Add Firebase auth verification or implement expiring signed URLs. |

---

### [M-2] No rate limiting on `/send`

| Field | Value |
|-------|-------|
| **File** | `render-server.js` |
| **Domain** | API & Input Handling |
| **Status** | 🟡 Unfixed |
| **CWE** | CWE-770 — Allocation of Resources Without Limits |
| **Description** | No rate limiting, throttling, or per-user quotas on email sending. |
| **Recommendation** | Add `express-rate-limit` with per-user and per-IP limits. |

---

### [M-3] Shared static token for inbound email

| Field | Value |
|-------|-------|
| **File** | `render-server.js:842-845` |
| **Domain** | API & Input Handling |
| **Status** | 🟡 Unfixed |
| **CWE** | CWE-798 — Use of Hardcoded Credentials |
| **Description** | `RECEIVE_TOKEN` env var is a single shared Bearer token for all inbound mail. |
| **Recommendation** | Use per-sender HMAC tokens or IP allowlisting. |

---

### [M-4] No SPF/DKIM/DMARC verification on inbound email

| Field | Value |
|-------|-------|
| **File** | `mailfwds_index.js` |
| **Domain** | API & Input Handling |
| **Status** | 🟡 Unfixed |
| **CWE** | CWE-345 — Insufficient Verification of Data Authenticity |
| **Description** | Cloudflare Worker accepts any email sent to the domain without sender verification. |
| **Recommendation** | Add SPF/DKIM/DMARC verification before writing to Firestore. |

---

## 🔵 Low Findings

### [L-1] CORS defaults to `*`

| Field | Value |
|-------|-------|
| **File** | `render-server.js` |
| **Domain** | API & Input Handling |
| **Status** | 🔵 Unfixed |
| **CWE** | CWE-942 — Permissive Cross-domain Policy |
| **Description** | `ALLOWED_ORIGIN` defaults to `*` if not set. |
| **Recommendation** | Set `ALLOWED_ORIGIN` to the specific frontend domain. |

---

### [L-2] No CSRF protection on password reset

| Field | Value |
|-------|-------|
| **File** | `reset-password/index.html` |
| **Domain** | Auth & Session Management |
| **Status** | 🔵 Unfixed |
| **CWE** | CWE-352 — Cross-Site Request Forgery |
| **Description** | Reset form has no CSRF token. |
| **Recommendation** | Add CSRF token or use same-site cookies. |

---

### [L-3] Cloudflare account ID exposed in cache

| Field | Value |
|-------|-------|
| **File** | `cloudflare/send-worker/.wrangler/cache/wrangler-account.json` |
| **Domain** | Secrets & Configuration |
| **Status** | 🔵 Unfixed |
| **CWE** | CWE-200 — Information Exposure |
| **Description** | Account ID `10a32f6ca4db95f2b25c24f20d2629b5` in tracked cache file. |
| **Recommendation** | Add `.wrangler/` to `.gitignore`. |

---

### [L-4] No size limits on individual fields in `/send`

| Field | Value |
|-------|-------|
| **File** | `render-server.js` |
| **Domain** | API & Input Handling |
| **Status** | 🔵 Unfixed |
| **CWE** | CWE-770 — Allocation of Resources Without Limits |
| **Description** | `express.json({ limit: '50mb' })` is permissive with no per-field validation. |
| **Recommendation** | Add Zod/Joi validation with per-field size limits. |

---

## ✅ Verified Secure

| Check | Status |
|-------|--------|
| Firebase token verification (`verifyIdToken`) | ✅ Proper |
| Firestore security rules (domain + ownership checks) | ✅ Well-written |
| `.env` in `.gitignore` | ✅ Excluded from git |
| Admin SDK JSON in `.gitignore` | ✅ Excluded from git |
| Google sign-in domain restriction | ✅ Restricted to `@synthrun.site` |
| User enumeration prevention on password reset | ✅ Generic responses |
| Android `google-services.json` (public-by-design) | ✅ No issue |
| Chrome extension (no secrets, minimal permissions) | ✅ No issue |
| HTML escaping in email bodies | ✅ Proper |

---

> **Report path:** `cicada/report-2026-06-29-143022.md`  
> **Generated by:** Cicada Security Audit Skill — https://github.com/Synthrun/Cicada
