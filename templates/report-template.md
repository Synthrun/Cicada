# 🔐 Security Audit Report — {{PROJECT_NAME}}

<div align="center">

**Audit date:** {{DATE}}  
**Mode:** {{MODE}}  
**Framework(s) detected:** {{FRAMEWORKS}}  
**Scope:** Full stack — backend + mobile  
**Method:** Static code analysis — no runtime testing  

</div>

---

## 📋 Executive Summary

| Severity | Count | Fixed | Description |
|----------|-------|-------|-------------|
| 🔴 **Critical** | {{C_COUNT}} | {{C_FIXED}} | RCE, SQLi, account takeover, secrets leak, mobile: API keys in source |
| 🟠 **High** | {{H_COUNT}} | {{H_FIXED}} | SSRF, weak crypto, timing leaks, missing SSL pinning, insecure storage |
| 🟡 **Medium** | {{M_COUNT}} | {{M_FIXED}} | Missing CSP, verbose errors, no deep link validation |
| 🔵 **Low** | {{L_COUNT}} | {{L_FIXED}} | No HSTS, no MFA, debug logs in production |
| ⚪ **Info** | {{I_COUNT}} | — | Observations, no action required |

**Overall verdict:** {{VERDICT}}

---

## 🔴 Critical Findings

{{CRITICAL_LISTING}}

---

## 🟠 High Findings

{{HIGH_LISTING}}

---

## 🟡 Medium Findings

{{MEDIUM_LISTING}}

---

## 🔵 Low Findings

{{LOW_LISTING}}

---

## ⚪ Informational

{{INFO_LISTING}}

---

## 🛡️ Security Checklist

### Universal
- [ ] Rate limiting on auth routes
- [ ] Constant-time password comparison
- [ ] CSRF protection on state-changing endpoints
- [ ] Content Security Policy header
- [ ] HSTS header (production)
- [ ] `.env` in `.gitignore`
- [ ] No hardcoded secrets
- [ ] Password reset tokens hashed in DB, expire ≤ 1 hour
- [ ] Same response for existing/non-existing email on forgot-password
- [ ] Login timing attack countermeasures (random keystroke delay)
- [ ] Magic links — single-use, short expiry, server-side validation
- [ ] Webhook signature verification
- [ ] CORS restricted to known origins
- [ ] Error messages do not leak stack traces
- [ ] Global error handler in place
- [ ] Dependency audit passes

### Web Framework
{{FRAMEWORK_CHECKS}}

### Mobile — Flutter / React Native
- [ ] No API keys in Dart/JS source
- [ ] Secure storage used (flutter_secure_storage / react-native-keychain)
- [ ] SSL pinning configured
- [ ] Deep links use App Links / Universal Links (not custom URL schemes alone)
- [ ] WebView locked down (no file access, origin validated)
- [ ] No cleartext traffic (Android: usesCleartextTraffic=false, iOS: ATS enabled)
- [ ] Code obfuscation enabled
- [ ] No debug logs in production builds
- [ ] Biometric auth with secure enclave storage
- [ ] Exported components restricted

---

## Appendix

- **Domains checked:** Auth, Password Reset, Connectors, API/Input, Secrets, Dependencies, Web Framework, Mobile
- **Framework(s) detected:** {{FRAMEWORKS}}
- **Checks performed:** {{CHECK_COUNT}}
- **Findings before fix attempt:** {{FINDINGS_BEFORE}}
- **Findings after fix attempt:** {{FINDINGS_AFTER}}

---

*Report generated {{DATE}} by the Cicada Security Audit Skill. Covers web + mobile frameworks.*
