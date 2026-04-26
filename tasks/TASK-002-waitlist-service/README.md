---
type: task
id: TASK-002
title: "Implementación de Módulo Waitlist en dh_onboarding_back (MongoDB/Beanie)"
status: completed
priority: high
created: "2026-04-25"
started: "2026-04-26"
completed: "2026-04-26"
tags: [onboarding, mongodb, beanie, waitlist]
---

# TASK-002: Implementación de Módulo Waitlist en dh_onboarding_back

## Descripción

Módulo de Waitlist dentro de `dh_onboarding_back` usando MongoDB + Beanie ODM.

## Objetivos

- [x] Configurar conexión MongoDB con Beanie (`AsyncMongoClient`, `tz_aware=True`, lifespan).
- [x] Definir el esquema de la colección `waitlist` (`WaitlistLead` con todos los campos, Field + examples, enums).
- [x] `POST /v1/waitlist` — registrar lead + email de confirmación vía PulseCore + log a VitalTrace.
- [x] `GET /v1/waitlist` — listar leads paginado con filtros `status` y `source`.
- [x] `GET /v1/waitlist/check/{email}` — verificar si un email ya está registrado.
- [x] `POST /v1/waitlist/{email}/invite` — generar token seguro (7 días), status `INVITED`, email de invitación vía PulseCore.
- [x] Emails en minúsculas forzados en DTO y use cases.
- [x] `ApiResponseSingle` / `ApiResponsePaginated` en todos los endpoints.
- [x] Legacy router en `/v1/onboarding/legacy/` para compatibilidad con el frontend existente.

## Notas

- El endpoint de conversión de lead a applicant (`CONVERTED`) se activa automáticamente en `POST /v1/onboarding/personal-info` cuando se valida el invite_token.
- Ver TASK-003 para el flujo de onboarding completo.
