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
- [x] Modelos SQLAlchemy para schemas `people`, `auth`, `expedient` con `BaseModel` dual-id (Integer PK + UUID externo).
- [x] `POST /v1/onboarding/start` — valida invite_token en MongoDB (sin escritura en DB).
- [x] `POST /v1/onboarding/personal-info` — crea `Person` (PENDING) + email, phone, auth.user, birth, legal_info, CURP en PostgreSQL.
- [x] `POST /v1/onboarding/{id}/password` — guarda hash en `auth.user.password_hash`.
- [x] `POST /v1/onboarding/{id}/address` — guarda domicilio en `people.address`.
- [x] `POST /v1/onboarding/{id}/documents` — sube documento a `expedient.document` (PENDING).
- [x] `POST /v1/onboarding/{id}/submit` — cambia `verification_status` a `SUBMITTED`.
- [x] `ApiResponseSingle` en todos los endpoints.
- [x] VitalTrace logging en cada acción.
- [x] PulseCore notificaciones (confirmación waitlist, invitación con token).
- [x] Enums de dominio en `app/shared/enums.py` (EVerificationStatus, EEmailType, EPhoneType, etc.).
- [x] `POST /v1/onboarding/{id}/otp/send` — conectado a `dh_mfa` vía `SERVICE_MFA_URL`.
- [x] `POST /v1/onboarding/{id}/otp/verify` — conectado a `dh_mfa` vía `challenge_id`.
- [ ] Hashing de contraseña delegado a `app_auth` (actualmente guarda texto plano — pendiente TASK-004).

## Pendiente

- Hash de contraseña via `dh_auth` (TASK-004).
- Reemplazar `{id_person}` en el path de cada endpoint por una cookie HTTP-only (`onboarding_session`) que el backend setea al crear la Person en `POST /personal-info` y lee automáticamente en los pasos siguientes. El frontend deja de manejar y re-enviar el `id_person` en cada petición.
