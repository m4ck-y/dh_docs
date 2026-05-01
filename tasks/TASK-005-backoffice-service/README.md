---
type: task
id: TASK-005
title: "Microservicio de Backoffice Administrativo (dh_backoffice)"
status: backlog
priority: medium
created: "2026-04-26"
started: null
completed: null
tags: [backoffice, admin, persons, staff]
---

# TASK-005: Microservicio de Backoffice Administrativo (dh_backoffice)

## Descripción

Desarrollo del microservicio administrativo para la creación y gestión directa de entidades `Person` por parte del equipo interno. Este servicio existe como alternativa al flujo de auto-registro de `dh_onboarding_back`, que es exclusivo para usuarios que se registran por cuenta propia.

Este microservicio cubre los casos que NO pasan por el flujo de onboarding:
- Alta directa de médicos, enfermeros y staff hospitalario interno.
- Importación masiva de personas desde sistemas externos (HIS, RRHH).
- Gestión administrativa del ciclo de vida de personas ya existentes (suspensión, reactivación, edición de datos).

## Contexto

`dh_onboarding_back` es el dueño del flujo de **auto-registro**. Para creación administrativa, se requiere un punto de entrada separado que no exija OTP ni token de invitación.

Ver: [2.onboarding.md](../../management/1_onboarding/2.onboarding.md)

## Objetivos

- [ ] Definir la arquitectura del microservicio (`dh_backoffice`).
- [ ] Implementar `POST /v1/admin/persons` — creación directa de Person sin flujo de onboarding.
- [ ] Implementar gestión de roles y membresías en `iam.membership`.
- [ ] Implementar endpoints de edición de datos de Person ya existentes.
- [ ] Implementar importación masiva (batch) desde CSV o sistema externo.
- [ ] Integrar con `app_logger_tracer` para auditoría de acciones administrativas.

## Enlaces Rápidos

- [Plan de Ejecución](planning/README.md)
- [Registro de Progreso](progress/README.md)
