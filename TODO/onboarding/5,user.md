# 📘 USER API DESIGN (v1)

## 📌 Base Path

```
/api/v1/users
```

---

# 🧠 1. Concepto

El User es:

> ✅ entidad final del sistema (ya aprobada)
> 
> 
> ❌ no pasa por onboarding ni evaluación
> 

---

# 👤 2. USER ENTITY (schema)

```
{
  "id":"uuid",
  "email":"string",

  "status":"string",

  "profile": {
    "first_name":"string",
    "last_name":"string",
    "country":"string",
    "avatar_url":"string | null"
  },

  "roles": ["user"],

  "applicant_id":"uuid",

  "created_at":"datetime",
  "updated_at":"datetime",
  "last_login_at":"datetime | null",

  "is_active":"boolean"
}
```

---

# 📊 3. USER STATUS

```
active
suspended
blocked
pending_verification
deleted
```

---

## 🧠 Significado

### 🟢 active

```
Usuario normal con acceso completo
```

---

### 🟡 pending_verification

```
Casos raros (login parcial o re-verificación)
```

---

### 🔴 suspended

```
Bloqueado temporalmente (admin action)
```

---

### ⛔ blocked

```
Fraude / seguridad / abuso
```

---

### 🗑 deleted

```
Soft delete (GDPR / account removal)
```

---

# 📋 4. USER API ENDPOINTS

---

# 👤 1. Get current user (MOST IMPORTANT)

```
GET /api/v1/users/me
```

---

### Response

```
{
  "id":"uuid",
  "email":"user@email.com",
  "profile": {
    "first_name":"John",
    "last_name":"Doe",
    "country":"MX"
  },
  "status":"active",
  "roles": ["user"]
}
```

---

# ✏️ 2. Update profile

```
PATCH /api/v1/users/me
```

---

### Body

```
{
  "first_name":"John",
  "last_name":"Doe",
  "avatar_url":"https://..."
}
```

---

# 🔐 3. Change password

```
POST /api/v1/users/me/change-password
```

---

### Body

```
{
  "current_password":"old",
  "new_password":"new"
}
```

---

# 📧 4. Update email (optional)

```
POST /api/v1/users/me/update-email
```

---

### Behavior

```
1. send verification OTP
2. confirm new email
3. update user email
```

---

# 👁️ 5. Get user by ID (admin/internal)

```
GET /api/v1/users/{id}
```

---

# 🚫 6. Suspend user (admin only)

```
POST /api/v1/admin/users/{id}/suspend
```

---

# 🔓 7. Reactivate user

```
POST /api/v1/admin/users/{id}/reactivate
```

---

# ⛔ 8. Block user

```
POST /api/v1/admin/users/{id}/block
```

---

# 🗑 9. Delete account (soft delete)

```
DELETE /api/v1/users/me
```

---

# 🔐 5. AUTH FLOW RELATION

```
login → user → access system
```

---

# 🧠 6. RELACIÓN CON APPLICANT

```
applicant (approved) → user created
```

---

## Mapping

```
{
  "user_id":"uuid",
  "applicant_id":"uuid"
}
```

---

# 🔄 7. USER LIFECYCLE

```
APPROVED APPLICANT
        ↓
USER CREATED
        ↓
ACTIVE
        ↓
SUSPENDED / BLOCKED (optional)
        ↓
DELETED (soft delete)
```

---

# 📊 8. USER PERMISSIONS MODEL (simple RBAC)

```
roles:
- user
- admin
- support
- super_admin
```

---

# 🧠 9. BUSINESS RULES

---

## ❌ No hacer

- crear user antes de approve
- permitir signup directo
- cambiar status desde frontend
- bypass applicant flow

---

## ✅ Hacer

- user solo nace desde applicant.approved
- user es estable (no workflow)
- admin controla estados sensibles
- frontend solo actualiza profile

---

# 🔐 10. SECURITY RULES

- JWT auth obligatorio
- rate limiting en profile update
- email verification obligatorio si cambia email
- password hashing (argon2/bcrypt)
- soft delete en vez de hard delete

---

# 🚀 11. USER EXPERIENCE FLOW FINAL

```
WAITLIST (optional interest)
        ↓
INVITE (optional gate)
        ↓
APPLICANT (onboarding)
        ↓
ADMIN REVIEW
        ↓
USER CREATED
        ↓
LOGIN → /users/me
```

---

# 🧾 12. RESUMEN FINAL

## USER ES:

```
Entidad final del sistema:
- estable
- autenticable
- no tiene steps
- no tiene evaluación
```

---

# 🔥 CONCLUSIÓN GENERAL DEL SISTEMA

Tu arquitectura completa queda así:

```
WAITLIST → INVITE → APPLICANT → ADMIN REVIEW → USER
```

---