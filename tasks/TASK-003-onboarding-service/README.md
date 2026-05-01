---
type: task
id: TASK-003
title: "Implementación de Microservicio de Onboarding (dh_onboarding_back)"
status: in-progress
priority: high
created: "2026-04-25"
started: "2026-04-26"
completed: null
tags: [onboarding, backend, orchestration, sqlalchemy, postgres]
---

# TASK-003: Implementación de Microservicio de Onboarding

## Descripción

Servicio `dh_onboarding_back` que orquesta el flujo de registro de nuevos usuarios (Design B — Person-first en personal-info). Acceso directo a PostgreSQL via SQLAlchemy async.

## Objetivos

- [x] Estructura base del proyecto (FastAPI + Screaming Architecture + hexagonal).
- [x] Conexión dual: MongoDB (Beanie, waitlist) + PostgreSQL (SQLAlchemy async, onboarding).
- [x] Modelos SQLAlchemy para schemas `people`, `auth`, `expedient` (referenciando a `dh_core`, `dh_auth` y `dh_expedient`).
- [x] `POST /v1/onboarding/start` — valida invite_token en MongoDB (sin escritura en DB).
- [x] `POST /v1/onboarding/personal-info` — delegar creación de `Person` a `dh_core` (pendiente refactor TASK-011).
- [x] `POST /v1/onboarding/{id}/password` — delegar a `dh_auth` (pendiente refactor TASK-004).
- [x] `POST /v1/onboarding/{id}/address` — guarda domicilio en `dh_core` (schema people).
- [x] `POST /v1/onboarding/{id}/documents` — sube documento a `dh_expedient` (schema expedient).
- [x] `POST /v1/onboarding/{id}/submit` — cambia `verification_status` a `SUBMITTED`.
- [x] `ApiResponseSingle` en todos los endpoints.
- [x] VitalTrace logging en cada acción.
- [x] PulseCore notificaciones (confirmación waitlist, invitación con token).
- [x] Enums de dominio en `app/shared/enums.py` (EVerificationStatus, EEmailType, EPhoneType, etc.).
- [x] `POST /v1/onboarding/{id}/otp/send` — conectado a `dh_mfa` vía `SERVICE_MFA_URL`.
- [x] `POST /v1/onboarding/{id}/otp/verify` — conectado a `dh_mfa` vía `challenge_id`.

## 📜 Log de Cambios
- **2026-04-26**: Renombramiento global de servicios orquestados (api_core -> dh_core, dh_auth, dh_expedient).
- **2026-04-26**: El microservicio ahora actúa estrictamente como **Orquestador**, delegando la persistencia de Personas a `dh_core` y de Usuarios a `dh_auth`.

## 📜 Log de Cambios (continuación)
- **2026-04-26**: Extracción de lógica `people.*` a `dh_core`. Los modelos SQLAlchemy de `person`, `email`, `phone`, `birth`, `legal_info`, `personal_identifier`, `address` fueron eliminados de onboarding. Los use cases `SavePersonalInfoUseCase`, `SaveAddressUseCase`, `SubmitOnboardingUseCase` ahora delegan a `dh_core` vía HTTP.
- **2026-04-26**: `AuthUser.id_person` (int FK) reemplazado por `person_uuid` (UUID lógico, sin FK cross-schema). Igual en `expedient.document`.

## Pendiente
- Reemplazar `{id_person}` en el path de cada endpoint por una cookie HTTP-only (`onboarding_session`).
