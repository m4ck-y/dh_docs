```jsx
                         ┌──────────────────────────┐
                         │   AUTH CENTRAL           │
                         │  auth.myapp.com          │
                         │                          │
                         │  - login/logout         │
                         │  - session mgmt         │
                         │  - JWT issuer           │
                         │  - RBAC                 │
                         │  - error codes          │
                         └──────────┬───────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
┌────────────────┐      ┌────────────────┐        ┌────────────────┐
│  ADMIN APP     │      │  DOCTOR APP    │        │  PATIENT APP   │
│ admin.domain    │      │ doctor.domain  │        │ patient.domain │
└───────┬────────┘      └───────┬────────┘        └───────┬────────┘
        │                       │                           │
        └───────────────────────┼───────────────────────────┘
                                │
                    ┌────────────────────────┐
                    │  AUDIT / LOGS APP      │
                    │  audit.domain          │
                    └────────────────────────┘
```

# 📘 AUTH CENTRAL — ERROR HANDLING DESIGN (v1)

## 📌 Principio base

El sistema de Auth Central **SIEMPRE responde con dos niveles de error:**

```
1. HTTP Status Code (estándar)
2. internal_code (lógica de negocio)
```

---

# 🔐 1. ERROR RESPONSE STANDARD

## 📦 Formato base

```
{
  "status":"error",
  "status_code":401,
  "internal_code":10,
  "message":"Sesión no iniciada"
}
```

---

# 🌐 2. HTTP STATUS CODES (PRIMER NIVEL)

Estos siguen el estándar HTTP y son usados por:

- browsers
- gateways
- proxies
- caching layers
- tooling (Postman, Axios, etc.)

---

## 🔐 Auth-related status codes

```
200 → OK
400 → Bad Request
401 → Unauthorized (no autenticado)
403 → Forbidden (autenticado pero sin permisos)
404 → Not Found
409 → Conflict
429 → Too Many Requests
500 → Internal Server Error
```

---

# 🧠 3. INTERNAL CODES (SEGUNDO NIVEL)

Los `internal_code` representan **subestados de negocio dentro de un mismo HTTP status**.

---

## 🔐 AUTH ERROR CODES (401 scope)

```
10 → Sesión no iniciada
11 → Token expirado
12 → Token inválido
13 → Usuario bloqueado
14 → Refresh token inválido o revocado
15 → Sesión revocada (logout global)
```

---

## 🚫 FORBIDDEN (403 scope)

```
20 → Sin permisos para este recurso
21 → Rol insuficiente
22 → Scope no permitido
```

---

## ⚠️ VALIDATION (400 scope)

```
30 → Email inválido
31 → Password débil
32 → OTP incorrecto
33 → Datos incompletos
```

---

# 📋 4. EJEMPLOS COMPLETOS

---

## ❌ Sesión no iniciada

```
HTTP 401
```

```
{
  "status":"error",
  "status_code":401,
  "internal_code":10,
  "message":"Sesión no iniciada"
}
```

---

## ⏳ Token expirado

```
{
  "status":"error",
  "status_code":401,
  "internal_code":11,
  "message":"Token expirado"
}
```

---

## 🚫 Usuario sin permisos

```
{
  "status":"error",
  "status_code":403,
  "internal_code":21,
  "message":"Rol insuficiente"
}
```

---

# 🧠 5. POR QUÉ ESTE MODELO ES CORRECTO

---

## ✔️ 1. HTTP status = infraestructura

Sirve para:

- routing
- caching
- browser behavior
- retry logic

👉 Es el “lenguaje universal”

---

## ✔️ 2. internal_code = lógica de producto

Sirve para:

- frontend UI logic
- analytics
- debugging
- observabilidad
- i18n (multi-idioma)

---

## ✔️ 3. evita dependencias frágiles

❌ Malo:

```
if message == "token expired"
```

✔ Bueno:

```
if internal_code == 11
```

---

## ✔️ 4. permite evolución sin romper frontend

Puedes cambiar:

```
"Token expirado"
→ "Tu sesión ha expirado"
```

👉 sin romper lógica del frontend

---

# 🧭 6. FLUJO EN TU AUTH CENTRAL

## 🔐 Request a cualquier app

```
frontend → backend
```

---

## 🔍 Backend valida cookie

```
auth_session → auth server
```

---

## ❌ si falla

```
return structured error
```

---

## 🎯 frontend decide:

```
if internal_code == 10:
    redirect → login
```

---

# 🚨 7. ERROR CRÍTICO (MUY IMPORTANTE)

## ❌ NO hacer esto:

```
usar solo HTTP 401 sin contexto
```

```
depender de mensajes string
```

---

## ✅ SÍ hacer esto:

```
HTTP 401 + internal_code 10
```

---

# 🧠 8. REGLA DE ORO

> HTTP status define “qué tipo de error es”
> 
> 
> internal_code define “por qué pasó”
> 

---

# 📊 9. RESUMEN FINAL

## TU AUTH CENTRAL DEBE RESPONDER ASÍ:

```
{
  "status":"error",
  "status_code":401,
  "internal_code":11,
  "message":"Token expirado"
}
```

---

# 🔥 CONCLUSIÓN

✔ Esto es arquitectura de nivel producción real

✔ usado en sistemas tipo Stripe / Uber / Google-style APIs

✔ mejora frontend, debugging y escalabilidad

✔ evita acoplamiento con textos