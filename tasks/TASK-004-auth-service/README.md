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

Crear el microservicio `dh_auth` responsable de la **Identidad y Autenticación**. Su única función es verificar quién es el usuario y emitir el JWT final, consultando los permisos al servicio de `dh_iam`.

## 🔑 Concepto: Separación Auth vs IAM
- **`dh_auth`**: Maneja el "Quién" (Email, Password, Google OAuth).
- **`dh_iam`**: Maneja el "Qué puede hacer" (Roles, Permisos, Tenants).
- **Flujo**: Tras un login exitoso, `dh_auth` solicita a `dh_iam` el contexto del usuario para inyectar los permisos en el JWT.

## Objetivos

- [ ] Inicializar el repositorio `dh_auth` con Screaming Architecture.
- [ ] **API de Registro de Usuarios**: Endpoint para crear `AuthUser` (email/password) vinculado a una `person_id`.
- [ ] Implementar login tradicional con **hashing Bcrypt** (ADR 014).
- [ ] Implementar OAuth Google como proveedor de identidad.
- [ ] **Integración con `dh_iam`**: Endpoint para solicitar membresías y permisos durante el flujo de emisión de token.
- [ ] Implementar refresh, logout y revocación de tokens.
- [ ] Configurar firma de JWTs (RSA/ECDSA).
- [ ] **Update api_middleware**: Routing de `/auth` hacia este servicio.

## No incluye

- OTP por SMS/email como segundo factor → `dh_mfa` (TASK-006).
- TOTP / Google Authenticator → `dh_mfa` (TASK-006).
- WebAuthn / biometría → `dh_mfa` (TASK-006).

## Referencia de arquitectura

Ver `docs/management/onboarding/4.auth.md` y `docs/db/postgres/auth/ERD.mmd`.

## 📜 Log de Cambios
- **2026-04-26**: Renombramiento global de servicios para consistencia (api_core -> dh_core, dh_health -> dh_clinical, dh_documents -> dh_expedient).
- **2026-04-26**: Separación oficial de responsabilidades entre dh_auth y dh_iam.

## Enlaces Rápidos

- [Plan de Ejecución](planning/README.md)
- [Registro de Progreso](progress/README.md)
