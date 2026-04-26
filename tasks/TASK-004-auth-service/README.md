---
type: task
id: TASK-004
title: "Microservicio de Identidad y Autenticación (dh_auth)"
status: backlog
priority: critical
created: "2026-04-25"
updated: "2026-04-26"
started: null
completed: null
tags: [auth, identity, oauth, jwt, security]
---

# TASK-004: Microservicio de Identidad y Autenticación (dh_auth)

## Descripción

Crear el microservicio `dh_auth` responsable de todo lo relacionado con identidad y autenticación de usuarios. Este servicio es el **único punto de emisión de tokens JWT** en el ecosistema.

## Separación de responsabilidades

| Servicio | Responsabilidad |
|---|---|
| `dh_auth` | Login tradicional, OAuth/OpenID Connect (Google, etc.), emisión de JWT, refresh, logout, sesiones |
| `dh_mfa` *(TASK-006, futuro)* | TOTP (Google Authenticator), WebAuthn, políticas de segundo factor — solo si se configura como factor adicional |

> Google Login es un **proveedor de identidad externo (OAuth/OpenID Connect)**, no es MFA. Va en `dh_auth`, no en `dh_mfa`.

## Objetivos

- [ ] Inicializar el repositorio `dh_auth`.
- [ ] Implementar login tradicional (email + contraseña) con hashing Argon2.
- [ ] Implementar OAuth/OpenID Connect — Google como proveedor inicial.
- [ ] Emitir JWT (access token corto) y refresh token (largo).
- [ ] Implementar refresh, logout y revocación de tokens.
- [ ] Configurar par de llaves RSA/ECDSA para firma de JWTs verificable por otros servicios.
- [ ] Exponer `GET /v1/auth/me` — info del usuario autenticado.
- [ ] Exponer `GET /v1/auth/.well-known/jwks.json` — public keys para verificación de tokens.
- [ ] Actualizar `api_middleware` para que el routing de `/auth` apunte a `dh_auth`.
- [ ] Migrar los modelos `auth.*` de `api_core` a `dh_auth`.

## No incluye

- OTP por SMS/email como segundo factor → `dh_mfa` (TASK-006).
- TOTP / Google Authenticator → `dh_mfa` (TASK-006).
- WebAuthn / biometría → `dh_mfa` (TASK-006).

## Referencia de arquitectura

Ver `docs/management/onboarding/4.auth.md` y `docs/db/postgres/auth/ERD.mmd`.

## Enlaces Rápidos

- [Plan de Ejecución](planning/README.md)
- [Registro de Progreso](progress/README.md)
