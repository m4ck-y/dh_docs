j# 📘 AUTH API DESIGN (v1)

## 📌 Base Path

```
/api/v1/auth
```

---

# 🧠 1. Concepto

El Auth system es:

> 🔐 la capa de autenticación y emisión de sesión para USERS
> 

⚠️ Importante:

- NO maneja onboarding
- NO maneja applicants
- NO crea usuarios

Solo:

👉 login, sesión, tokens, seguridad

---

# 👤 2. AUTH FLOW GENERAL

```
USER EXISTS (approved applicant)
        ↓
LOGIN
        ↓
ACCESS TOKEN + REFRESH TOKEN
        ↓
CALL /users/me
```

---

# 📦 3. AUTH METHODS

Puedes usar 2 modelos (elige uno):

---

## 🥇 Opción recomendada: JWT + Refresh Token

- Access token corto (15 min)
- Refresh token largo (7–30 días)

---

## 🥈 Alternativa: Session-based

- Cookies httpOnly
- Server sessions

---

# 🔐 4. AUTH ENDPOINTS

---

# 🔑 1. Login

```
POST /api/v1/auth/login
```

---

## Body

```
{
  "email":"user@email.com",
  "password":"string"
}
```

---

## Response

```
{
  "access_token":"jwt",
  "refresh_token":"jwt",
  "expires_in":900,
  "user": {
    "id":"uuid",
    "email":"user@email.com",
    "status":"active"
  }
}
```

---

# 🔁 2. Refresh token

```
POST /api/v1/auth/refresh
```

---

## Body

```
{
  "refresh_token":"jwt"
}
```

---

## Response

```
{
  "access_token":"new_jwt",
  "expires_in":900
}
```

---

# 🚪 3. Logout

```
POST /api/v1/auth/logout
```

---

## Behavior

```
- invalidate refresh token
- optionally blacklist access token
```

---

# 👤 4. Get session (optional but useful)

```
GET /api/v1/auth/me
```

---

## Response

```
{
  "user_id":"uuid",
  "email":"user@email.com",
  "roles": ["user"],
  "status":"active"
}
```

---

# 🔐 5. PASSWORD MANAGEMENT

---

## 🔄 Forgot password

```
POST /api/v1/auth/forgot-password
```

---

## Body

```
{
  "email":"user@email.com"
}
```

---

## Reset password

```
POST /api/v1/auth/reset-password
```

---

## Body

```
{
  "token":"reset_token",
  "new_password":"string"
}
```

---

# 📧 6. EMAIL VERIFICATION (optional layer)

---

## Send verification

```
POST /api/v1/auth/verify-email/send
```

---

## Confirm email

```
POST /api/v1/auth/verify-email/confirm
```

---

# 🧠 7. AUTH RULES (CRÍTICO)

---

## ❌ NO hacer

- login sin user aprobado
- crear user desde auth
- permitir auth antes de applicant approval (si es gated product)
- guardar password en plaintext

---

## ✅ SÍ hacer

- auth SOLO para users existentes
- validación de status = active
- tokens con expiración
- refresh token rotation

---

# 🔐 8. AUTH GUARDS (backend rules)

```
if user.status != active:
    deny access
```

---

## Roles check

```
user → normal access
admin → admin routes
super_admin → full access
```

---

# 🧩 9. TOKEN STRUCTURE (JWT)

---

## Access token payload

```
{
  "sub":"user_id",
  "email":"user@email.com",
  "role":"user",
  "status":"active",
  "iat":123,
  "exp":123
}
```

---

# 🔄 10. SESSION LIFECYCLE

```
login → access token issued
      → refresh token stored
use API → access token validated
expired → refresh → new access token
logout → revoke refresh token
```

---

# 🧠 11. RELACIÓN CON TU SISTEMA COMPLETO

```
WAITLIST → APPLICANT → APPROVED → USER → AUTH
```

👉 AUTH SOLO ARRANCA AQUÍ:

```
APPROVED USER → AUTH ENABLED
```

---

# 🚀 12. SECURITY RECOMMENDATIONS

---

## 🔐 Must-have

- bcrypt / argon2 passwords
- refresh token rotation
- httpOnly cookies (si web app)
- rate limiting login
- brute force protection

---

## 🧠 Nice-to-have

- device tracking
- login history
- suspicious login detection
- MFA (2FA)

---

# 📊 13. AUTH SUMMARY

```
AUTH = sesión + seguridad + tokens
NO es onboarding
NO es user creation
SOLO controla acceso
```

---

# 🔥 CONCLUSIÓN FINAL DEL SISTEMA COMPLETO

Tu arquitectura total queda así:

```
WAITLIST (interest)
        ↓
INVITE (optional gate)
        ↓
APPLICANT (onboarding + evaluation)
        ↓
ADMIN APPROVE
        ↓
USER CREATED
        ↓
AUTH (login + session)
        ↓
PRODUCT ACCESS
```